--
-- Created by IntelliJ IDEA.
-- User: 朱腾芳
-- Date: 2016/12/7
-- Time: 18:17
-- To change this template use File | Settings | File Templates.
--
local class = require("lib.middleclass")
local ModuleBase = require("package.huapai.module.tablebase.tablebase_module")

---@class PaoHuZiTableModule:TableBaseModule
---@field view PaoHuZiTableView
---@field model PaoHuZiTableModel
local TableModule = class("HuaPai.TableModule", ModuleBase)

PaoHuZi_TableModule = TableModule

local ModuleCache = ModuleCache
local ModuleManager = ModuleCache.ModuleManager

local PlayerView = require("package.huapai.module.table.player_view")
local CardCtrlView = require("package.huapai.module.table.cardctrl_view")
local HandCardView = require("package.huapai.module.table.handcard_view")
local SoundManager = require("package.huapai.module.table.sound_manager")

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

local ComponentUtil = ModuleCache.ComponentUtil
local DoTween = DG.Tweening.DOTween

local UnityEngine = UnityEngine
local Input = UnityEngine.Input

local curTableData  -- 牌桌数据

local TOTAL_SEAT = 3 -- 座位数
FunctionPaoHuZi = FunctionPaoHuZi or {}


function TableModule:initialize(...)
    
    require("package.huapai.module.table.table_module_huifang")
    require("package.huapai.module.table.table_module_gameState")
    require("package.huapai.module.table.table_module_other")
    require("package.huapai.module.table.table_module_userState")

    self:init_userState()
    curTableData = TableManager.phzTableData



    -- 开始初始化                     view               model
    ModuleBase.initialize(self, "table_view", "table_model", ...)
    FunctionPaoHuZi.TableModule = self

    TableUtilPaoHuZi.CloneGameObject = self.view.cloneRoot
    TableUtilPaoHuZi.viewRoot = self.view

    self:SetZP_ZPPaiLeiStart()
    self:bind_handcard_view()
    self:bind_players_view()
    self:bind_ctrl_view()

    self:set_room_id()
    self:set_wanfa()

    
    self:refresh_round(1)


    self:check_activity_is_open()

    Manager.SetActive(self.view.btnReconnect.gameObject, false)
    self:init_playback_data()

    self.view.buttonWarning.onClick:AddListener(
        function()
            self:ShowGpsInfo()
        end
    )

    self.view.btnLeave1.onClick:AddListener(
        function()
            if DataHuaPai.Msg_Table_GameStateNTF == nil then
                self:request_exit_room()
            else
                self:dispatch_module_event("dissolveroom", "Event_DissolvedRoom", 1)
            end
        end
    )
    self.view.btnSettings1.onClick:AddListener(
        function()
            self:show_settings()
        end
    )
    self.view.ButtonRuleExplain1.onClick:AddListener(
        function()
            ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
        end
    )

    self.view.ButtonRule1.onClick:AddListener(
        function()
            ModuleManager.show_module("henanmj", "tablerule", curTableData.Rule)
        end
    )
    

    self:InitGameStateCon()
    self:reset()

    self:show_leave_btn(true)
    self:show_invite_btn(true)
    self:fangzuobiPiPei()

    self:subscibe_package_event("Event_RoomSetting_ZiPaiSheZhi", function(eventHead, eventData)
        self:Event_RoomSetting_ZiPaiSheZhi()
    end)

    self:subscibe_package_event("Event_RoomSetting_RefreshBg", function(eventHead, eventData)
        self.view:refresh_table_bg()
    end)

    self:init_other()

end


--- 绑定玩家视图
function TableModule:bind_players_view()
    self.playersView = {}
    DataHuaPai.playersView = self.playersView
    for i = 1, #self.view.playersHolder do
        ---@type PlayerView
        self.playersView[i] = PlayerView:new(self.view.playersHolder[i], i, self.view.cloneRoot, self)
    end
    --- 初始化自己的角色信息
    if (not curTableData.isPlayBack) then
        local mySeatData = {
            UserID = curTableData.modelData.roleData.userID,
            SeatID = curTableData.SeatID
        }
        self.playersView[1]:refresh_player_info(mySeatData)
    end
end

--- 绑定手牌视图
function TableModule:bind_handcard_view()
    HandCardView.view = self.view
    HandCardView.table_model = self
    HandCardView:bind_view(self, self.view.handcardHolder, self.view.cloneRoot, self.view.line)
end

-- 播放当前玩家的 出牌动画
function TableModule:selfChuPaiDongHua(value)
    for i=1,#self.playersView do
        if self.playersView[i].seatIndex == 1 then
            self.playersView[i]:show_chuzhangSelf(value, true)
        end
    end
    local data = DataHuaPai.Msg_Table_GameStateNTF
    if data then
        self:refresh_paiju(data,value)
    end
end


--- 绑定控制视图
function TableModule:bind_ctrl_view()
    CardCtrlView:bind_view(self, self.view.ctrlHolder, self.view.cloneRoot)
end

--- 重置牌桌数据
function TableModule:reset()
    self:refresh_remainder_cards()
    HandCardView:clear()
    CardCtrlView:clear()
    for i = 1, #self.playersView do
        self.playersView[i]:clear_cards()
        self.playersView[i]:show_light(false)
    end
    self.gameState = nil
    self.lastGameState = nil
    self.playingGameState = false
    self.playJiangpai = false
    self.showSingleResult = false
    self:set_jiang(false)
end


--- 隐藏所有玩家出张
function TableModule:hide_players_chuzhang()
    for i = 1, #self.playersView do
        self.playersView[i]:hide_chuzhang()
    end
end

--- 注册刷帧
function TableModule:on_update()
    if self.isDrag and self.checkTouchCount then
        HandCardView:on_drag_update()
    end
end

--- 抬起状态
function TableModule:on_press_up(obj, arg)
    if (obj and obj.name == "Voice") then
        ModuleBase.press_up_voice(self, obj, arg)
    end

    self.isDrag = false
    self.isDragObj = nil
    HandCardView:on_drag_end()
end

--- 开始拖动
--- on_press_up -> on_click -> on_end_drag
function TableModule:on_begin_drag(obj, arg)
    -- 手机上可以多点操作，所以过滤掉
    self.checkTouchCount = Input.touchCount > 0
    if self.isDragObj then
        return
    end
end

--- 拖动状态中
function TableModule:on_drag(obj, arg)
    if (obj and obj == self.isDragObj) then
        if not self.checkTouchCount then
            HandCardView:on_drag_update()
        end
    elseif (obj and obj.name == "Voice") then
        ModuleBase.on_drag_voice(self, obj, arg)
    end
end

--- 结束拖动
function TableModule:on_end_drag(obj, arg)
    if obj == self.isDragObj then
        HandCardView:on_drag_end()
    end

    self.isDragObj = nil
    self.isDrag = false
    TableUtilPaoHuZi.set_frame_rate(false, TableUtilPaoHuZi.playingAnim)
end

--- 开始按下状态
function TableModule:on_press(obj, arg)

    print('无语哎')
    if curTableData.isPlayBack then
        return
    end

    if (obj.name == "Voice") then
        ModuleBase.press_voice(self, obj, arg)
    elseif (type(tonumber(obj.name)) == "number") then
        
    end

    

    self:on_pressOfShouPai(obj)
end

function TableModule:on_pressOfShouPai(obj)

    print(obj.name)
    if string.find(obj.name, "__") then
        print('真的无语哎')
        self.isDrag = true
        self.isDragObj = obj
        TableUtilPaoHuZi.set_frame_rate(true, TableUtilPaoHuZi.playingAnim)
        HandCardView:on_drag_begin(obj)
    end
end






--- 判断是否有动作ID
function TableModule:has_action(data)
    if not data or not data.action or #data.action == 0 then
        TableUtilPaoHuZi.print("<color=red>动作长度</color>", #data.action)
        return false
    end

    return true
end



--- 播放下一个状态
function TableModule:play_next()

end




--- 显示取消托管按钮
function TableModule:quxiaoTuoGuan(datat)
    if not self.view.btnTuoGuan then
        return
    end
    if datat and DataHuaPai.Msg_Table_GameStateNTF.result == 0 then
        self.view.btnTuoGuan.gameObject:SetActive(datat.IntrustState == 1)
    else
        self.view.btnTuoGuan.gameObject:SetActive(false)
    end
end

--- 判断回调并执行
function TableModule:do_callback(callbak)
    if callbak then
        callbak()
    end
end



--- 单独聊天信息
function TableModule:refresh_private_message(data)
    TableUtilPaoHuZi.print("单独聊天信息")
end


function TableModule:showJinPlayerErr()
    local datas = {}
    datas.gameType = "huapai"

    local seatHolderArray = {}
    for i, v in ipairs(self.playersView) do
        seatHolderArray[i] = v.playerInfo
    end

    if #seatHolderArray < 3 then
        return
    end
    datas.seatHolderArray = seatHolderArray

    if not self.tablelocation then
       return
    end

    local s = self.tablelocation:showJinPlayerErr(datas)


    if s ~= "" then
        self:start_lua_coroutine(
            function()
                self.view.GpsErrText.text = s
                self.view.GpsErr.transform.localPosition = UnityEngine.Vector3.New(0, 100, 0)
                for i = 1, 80 do
                    coroutine.wait(0)
                    self.view.GpsErr.transform.localPosition = UnityEngine.Vector3.New(0, 100 - i, 0)
                end
                coroutine.wait(2)
                for i = 1, 80 do
                    coroutine.wait(0)
                    self.view.GpsErr.transform.localPosition = UnityEngine.Vector3.New(0, 20 + i, 0)
                end
            end
        )
    end
end



--- 播放短语
function TableModule:player_shot_voice(index, seatId)
    local localSeatID = self:get_local_seat(seatId)
    local text = TableUtilPaoHuZi.get_chat_text(index)
    self.playersView[localSeatID]:show_chat_bubble(text)
    self.playersView[localSeatID]:play_shot_voice(index)
end

--- 显示表情
function TableModule:show_chat_face(SeatID, emoticonIdx)
    local localSeatID = self:get_local_seat(SeatID)
    self.playersView[localSeatID]:show_chat_face(emoticonIdx)
end

--- 显示文本
function TableModule:show_chat_bubble(SeatID, text)
    local localSeatID = self:get_local_seat(SeatID)
    self.playersView[localSeatID]:show_chat_bubble(text)
end

--- 显示语音
function TableModule:show_voice(SeatID)
    local localSeatID = self:get_local_seat(SeatID)
    self.playersView[localSeatID]:show_voice(true)
end

--- 隐藏语音
function TableModule:hide_voice(SeatID)
    local localSeatID = self:get_local_seat(SeatID)
    self.playersView[localSeatID]:show_voice()
end

function TableModule:update_seat_location(SeatID, data)
    local localSeatID = self:get_local_seat(SeatID)
    self.playersView[localSeatID]:update_location_data(data)
end

--- 设置将牌（无动画效果）
function TableModule:set_jiang(value)
 
end



--- 根据服务器座位  获取本地座位
function TableModule:get_local_seat(seatID)
    local localSeatID = TableUtilPaoHuZi.get_local_seat(seatID, curTableData.SeatID, TOTAL_SEAT)
    return localSeatID
end

--- 设置房号
function TableModule:set_room_id()
    if curTableData.HallID and curTableData.HallID > 0 then
        self.view.txtRoomID.text = AppData.MuseumName .."房号:" .. curTableData.RoomID
    else
        self.view.txtRoomID.text = "房号:" .. curTableData.RoomID
    end


end


function TableModule:get_gaohuziWanfa()
    local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)

    local str = ""

    if ruleInfo.DiFen then
        str = str .. '底芬' .. ruleInfo.DiFen/1000 .. '   '
    end

    str = str .. "15胡起胡   "

    if ruleInfo.roundCount then
        str = str .. ruleInfo.roundCount.."胡息结算   "
    end


    if ruleInfo.FengDing then
        str = str .. ' 封顶' .. ruleInfo.FengDing .. '胡息   '
    end

   
    if ruleInfo.DaTuo == 0 then
        str = str .. '不打坨   '
    elseif ruleInfo.DaTuo == 1 then
        str = str .. '打坨   '
    end

    if ruleInfo.JiePaoFengDing == 0 and AppData.Game_Name == "LDZP" then
        str = str .. '接炮不封顶   '
    elseif ruleInfo.JiePaoFengDing == 100 and AppData.Game_Name == "LDZP" then
        str = str .. '接炮100封顶   '
    end

    if ruleInfo.CheckIPAddress == true then
        str = str .. 'GPS检测开启   '
    end

    if ruleInfo.NeedOpenGPS == true then
        str = str .. '相同IP检测   '
    end

    if ruleInfo.SeatRule == 1 then
        str = str .. '不换位   '
    elseif ruleInfo.SeatRule == 2 then
        str = str .. '每局换位   '
    end

    return str
end

function TableModule:set_wanfa()
    if not self.gamerule then
        self.gamerule = curTableData.Rule
        self.wanfaName,
            self.ruleName,
            self.playerNum,
            self.wanfaTable = TableUtilPaoHuZi.get_rule_name(curTableData.Rule, curTableData.HallID == 0)
    end

    local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)
    
    print_table(ruleInfo)

    if AppData.Game_Name == "GLZP" then
        local str = ""
        str = str .. ruleInfo.HuPaiRule .. "胡起胡 "
        str = str .. ruleInfo.SettleRule .. "胡1子 "

        if ruleInfo.ZiMoRule == 1 then
            str = str .. "自摸加1 "
        elseif ruleInfo.ZiMoRule == 2 then
            str = str .. "自摸翻倍 "
        end

        if ruleInfo.SeatRule == 1 then
            str = str .. "不换位 "
        elseif ruleInfo.SeatRule == 2 then
            str = str .. "每局换位 "
        end

        if ruleInfo.DiaoPaoRule == true then
            str = str .. "可点炮 "
        else
            str = str .. "不可点炮 "
        end

        if ruleInfo.ShangXingRule == true then
            str = str .. "上醒 "
        end

        if ruleInfo.BenXingRule == true then
            str = str .. "中醒 "
        end

        if ruleInfo.XiaXingRule == true then
            str = str .. "下醒 "
        end
        self.view.txtWanFaShow.text = str

        self.view.txtWanFa.text = "桂林字牌"
    elseif AppData.Game_Name == "XXZP"  then
        self.view.txtWanFa.text = "湘乡告胡子"
       
        
        if AppData.App_Name == 'DHHNQP' then
            self.view.txtWanFa.text ="            15胡起胡 "..ruleInfo.roundCount.."胡息结算 "
        end

    elseif AppData.Game_Name == "DYZP"  then
        self.view.txtWanFa.text = self.wanfaTable
    elseif AppData.Game_Name == "LDZP"  then
        self.view.txtWanFa.text = "            15胡起胡 "..ruleInfo.roundCount.."胡息结算 "
    else
        
    end

    if ruleInfo.baseScore then
        self.view.txtWanFa.text = self.view.txtWanFa.text .. ' 底注:' .. ruleInfo.baseScore
    end
end

--- 刷新剩余多少牌
function TableModule:refresh_remainder_cards(num)
    if DataHuaPai.Msg_Table_GameStateNTF and DataHuaPai.Msg_Table_GameStateNTF.result ~= 0 then
        Manager.SetActive(self.view.remainderCardObj, false)
        return
    end

    TableUtilPaoHuZi.print("刷新剩余张数", num)
    if not num or type(num) ~= "number" or num == 0 then
        Manager.SetActive(self.view.remainderCardObj, false)
        return
    end

    for i=1,#self.view.PaiBeiMenChildren do
        self.view.PaiBeiMenChildren[i].gameObject:SetActive(true)
    end

    local t1,t2 = math.modf(num*6/20);


    for i=1,#self.view.PaiBeiMenChildren do
        if i > t1 + 1 then
            self.view.PaiBeiMenChildren[6 -i + 1].gameObject:SetActive(false)
        end
    end 

    Manager.SetActive(self.view.remainderCardObj, true)
   
 
    --self.view.remainderCardImg.sprite = self.view.remainderCardSpriteHolder:FindSpriteByName(tostring(level))
    self.view.remainderCardNum.text = tostring(num)
end

--- 显示离开座位按钮
function TableModule:show_leave_btn(show)
    local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)
    if ruleInfo.baseScore then
        Manager.SetActive(self.view.btnLeave.gameObject, false)
    else
        Manager.SetActive(self.view.btnLeave.gameObject, not self.roundStart and show)
    end

end

--- 显示邀请好友按钮  
function TableModule:show_invite_btn(show)
    local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)
    if ruleInfo.baseScore then
        Manager.SetActive(self.view.btnInvite.gameObject, false)
    else
        Manager.SetActive(self.view.btnInvite.gameObject, not self.roundStart and show)
    end
end


function TableModule:Init10DaoJsButton()
    if self.Init10DaoJsButtonFlag then
        return
    end

    self.Init10DaoJsButtonFlag = self:start_lua_coroutine(function ()
        for i=DataHuaPai.Msg_Table_UserStateNTF_Self.RestTime,1,-1 do
            coroutine.wait(0.96)
            if not self.view.btnStartZhunBei.gameObject.activeSelf then
                break
            end
            self.view.btnStartZhunBeiText.text = tostring(i)
        end
        --self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy
        self.Init10DaoJsButtonFlag = nil
    end)
end

function TableModule:on_show(intentData)
    ModuleBase.on_show(self)
end

function TableModule:on_module_event_bind()
    ModuleBase.on_module_event_bind(self)

    --- 一局结束开始下一局
    self:subscibe_module_event(
        "tablestrategy",
        "Event_Show_TableStrategy",
        function(eventHead, eventData)
            if DataHuaPai.Msg_Table_GameStateNTF == nil or DataHuaPai.Msg_Table_GameStateNTF.SeqNo > 3 then
                self:reset()
            end

            self.model:request_restart()
        end
    )


    --Event_Msg_Table_Restart
    --- 回放播放按钮点击事件
    self:subscibe_module_event(
        "Playback",
        "Event_Playback_Play",
        function(eventHead, eventData)
            self:playback_play()
        end
    )
    --- 回放暂停按钮点击事件
    self:subscibe_module_event(
        "Playback",
        "Event_Playback_Pause",
        function(eventHead, eventData)
            self:playback_pause()
        end
    )
    --- 回放后退按钮点击事件
    self:subscibe_module_event(
        "Playback",
        "Event_Playback_Back",
        function(eventHead, eventData)
            self:playback_back()
        end
    )
    --- 回放前进按钮点击事 件
    self:subscibe_module_event(
        "Playback",
        "Event_Playback_Front",
        function(eventHead, eventData)
            self:playback_front()
        end
    )
    --- 回放重置按钮点击事  件
    self:subscibe_module_event(
        "Playback",
        "Event_Playback_Reset",
        function(eventHead, eventData)
            self:playback_reset()
            self.playingPlayback = true
        end
    )
    --- 回放退出按钮点击事件
    self:subscibe_module_event(
        "Playback",
        "Event_Playback_Exit",
        function(eventHead, eventData)
            ModuleManager.destroy_module("huapai", "table")
            ModuleManager.show_module("henanmj", "hall")
        end
    )
end

function TableModule:on_click(obj, arg)
    if not obj then
        return
    end

    self:on_pressOfShouPai(obj)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")

    if obj and string.find(obj.name, "__") then
        HandCardView:on_drag_endReal()
    end
    
    if obj == self.view.btnRule.gameObject then
        
        ModuleManager.show_module("henanmj", "tablerule", curTableData.Rule)
    elseif obj == self.view.btnInvite.gameObject then
        self:invite_friend()
    elseif obj == self.view.btnLeave.gameObject then
        self:request_exit_room()
    elseif obj == self.view.buttonWarning.gameObject then

    elseif obj == self.view.btnStartZhunBei.gameObject or obj == self.view.btnStartZhunBei_museum.gameObject then
        self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
        self.view.btnStartZhunBei.gameObject:SetActive(false)
        self.view.btnStartZhunBei_museum.gameObject:SetActive(false)
    elseif obj == self.view.btnStart.gameObject then
        -- 发送准备协议
        self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
    elseif obj == self.view.btnChat.gameObject then
        self:show_chat()
    elseif obj == self.view.btnSettings.gameObject then
        self:show_settings()
    elseif obj == self.view.btnReconnect.gameObject then
        ModuleCache.GameManager.logout()
    elseif obj == self.view.ButtonDaTuo.gameObject then

        SoundManager:play_name("datuo", true)
        self.view.ShiFouDaTuo.gameObject:SetActive(false)
        self.model:request_Msg_ACTION_PIAO(1)
      

    elseif obj == self.view.ButtonBuDaTuo.gameObject then

        
        SoundManager:play_name("datuono", true)
        self.view.ShiFouDaTuo.gameObject:SetActive(false)
        self.model:request_Msg_ACTION_PIAO(0)
    elseif obj == self.view.ButtonActivity.gameObject then
        local object = 
        {
        showRegionType = "table",
        showType="Manual",
        }
         ModuleCache.ModuleManager.show_public_module("activity", object)

    end

    --

    if not self.view.ButtonJinBiChangExit then
        return
    end

    if obj == self.view.ButtonJinBiChangExit.gameObject then
        local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)
        if ruleInfo.baseScore then
            self:request_exit_room()
        else
            local num = 0
            for key, v in pairs(DataHuaPai.Msg_Table_UserStateNTF.State) do
                if v.UserID ~= "0" and v.UserID ~= nil then
                    num = num + 1
                end
            end

            if num > 2 then
                self:dispatch_module_event("roomsetting", "Event_RoomSetting_DissolvedRoom", 1)
            else
                self:request_exit_room()
            end
        end
    elseif obj == self.view.ButtonSettings.gameObject then
        self:show_settings()
    elseif obj == self.view.ButtonShop.gameObject then
        ModuleCache.ModuleManager.show_module("public", "goldadd")
    elseif obj == self.view.ButtonRuleExplain.gameObject then
        self.view.Public_WindowGoldHowToPlay.gameObject:SetActive(true)
    elseif obj == self.view.ButtonRule.gameObject then
        ModuleManager.show_module("henanmj", "tablerule", curTableData.Rule)

        if "WindowsEditor" == tostring(UnityEngine.Application.platform) or tostring(UnityEngine.Application.platform) =='WindowsPlayer' then
            self.model:request_quxiaoTuoGuan(1)
        end
        
    elseif obj == self.view.btnTuoGuan.gameObject then
        self.model:request_quxiaoTuoGuan()
        self.view.btnTuoGuan.gameObject:SetActive(false)
    end

end

--- 刷新局数
function TableModule:refresh_round(round)
    
    self.view.txtJushu.text = string.format("第 %d/%d 局", round, curTableData.RoundCount)
    
end

--- 邀请好友
function TableModule:invite_friend(shareToClipboard)
    if not self then
        self = FunctionPaoHuZi.TableModule
    end
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return
    end

    local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)
    if ruleInfo.baseScore and ruleInfo.isPrivateRoom ~= true then
        if not DataHuaPai.Msg_Table_GameStateNTF or DataHuaPai.Msg_Table_GameStateNTF.result ~= 0 then
            return
        end
    end

    --TODO XLQ 牌友圈分享不显示支付方式
    if curTableData.RoomType == 2 then
        ruleInfo.PayType = -1
    end


    if not self.gamerule then
        self.gamerule = curTableData.Rule
        self.wanfaName,
            self.ruleName,
            self.playerNum,
            self.wanfaTable = TableUtilPaoHuZi.get_rule_name(curTableData.Rule, curTableData.HallID == 0)
    end
    local shareData = {}
    shareData.type = 2
    shareData.roomId = curTableData.RoomID .. ""
    shareData.rule = self.gamerule
    shareData.ruleName =  "金币场-匹配模式 " .. self.ruleName


    local config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))

    if not DataHuaPai.Msg_Table_UserStateNTF then
        return
    end
    
    if DataHuaPai.Msg_Table_UserStateNTF.BaseCoinScore then
        shareData.ruleName = string.format('金币场-匹配模式 底分:%d ', DataHuaPai.Msg_Table_UserStateNTF.BaseCoinScore)
    end

    if DataHuaPai.Msg_Table_UserStateNTF.BaseCoinScore == 0 then
        shareData.ruleName = string.format('好友场 ')
    end

    local str = ""
    if ruleInfo.PayType ~= nil then
        if ruleInfo.PayType == 0 then
            str = '房主支付 '
        end

        if ruleInfo.PayType == 1 then
            str = 'AA支付 '
        end

        if ruleInfo.PayType == 2 then
            str = '大赢家支付 '
        end
    end


    if AppData.Game_Name == 'GLZP' or AppData.Game_Name == 'DYZP' then
        shareData.ruleName = str .. curTableData.RoundCount .. '局 ' .. self.view.txtWanFaShow.text
    end


    if (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
        shareData.ruleName = str .. self:get_gaohuziWanfa()
    end

    shareData.title = self.wanfaName
    shareData.userID = self.modelData.roleData.userID
    if (curTableData.HallID > 0) then
        shareData.parlorId = curTableData.HallID .. ""
        shareData.roomType = curTableData.RoomType
    else
        shareData.roomType = 0
    end

    if (curTableData.RoomType == 3) then
        -- 比赛场分享
        shareData.type = 4
        shareData.matchId = curTableData.MatchID
    elseif curTableData.RoomType == 2 then
        --快速组局
        shareData.parlorId = shareData.parlorId .. string.format("%06d", ModuleCache.GameManager.curGameId)
    end



    shareData.curPlayer = self:getDangQianRenShu()


    shareData.totalPlayer = 3
    shareData.totalGames = curTableData.RoundCount
    shareData.comeIn = false

    shareData.type = 2

    print_debug("--------------share-----------shareData.type:", shareData.type, shareData.parlorId, shareData.matchId)
    if not shareToClipboard then
        ModuleCache.ShareManager().shareRoomNum(shareData, false)
    else
        self:share_room_info_text(shareData)
    end
end
FunctionPaoHuZi.invite_friend = TableModule.invite_friend


function TableModule:getDangQianRenShu()
    return DataHuaPai.Msg_Table_UserStateNTFNumAll
end

--- 离开房间
function TableModule:request_exit_room()
    TableUtilPaoHuZi.print("离开房间")
    self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
end

--- 显示设置
function TableModule:show_settings()
    local intentData = {}
    intentData.canDissolveRoom = not self.view.btnInvite.gameObject.activeSelf
    intentData.tableBackgroundSprite = self.view.bgSprite1
    intentData.tableBackgroundSprite2 = self.view.bgSprite2
    intentData.tableBackgroundSprite3 = self.view.bgSprite3



    ModuleManager.show_module("henanmj", "roomsetting", intentData)
end

--- 显示聊天
function TableModule:show_chat()
    local temp = {
        is_New_Sever = true,
        config = Config,
        backgroundStyle = "BackgroundStyle_1"
    }
    ModuleManager.show_module("henanmj", "tablechat", temp)
end

function TableModule:clear()
    TableManager.chatMsgs = {}
    --- 清空聊天信息

    if self.playersView then
        for i = 1, 3 do
            if self.playersView[i] then
                self.playersView[i]:clear()
            end
        end
    end
    self.playersView = nil

    HandCardView:clear()
    CardCtrlView:set_active(false)
end

--- 延时回调
function TableModule:insert_callback(t, fun)
    local seq = DoTween.Sequence()
    seq:InsertCallback(
        t,
        function()
            if fun then
                fun()
            end
        end
    )
    seq:SetAutoKill(true)
    seq:Play()
end

function TableModule:on_destroy()


    ModuleManager.destroy_module("huapai", "playback")
    ModuleManager.destroy_module("huapai", "singleresult")
    ModuleManager.destroy_module("huapai", "totalresult")
    ModuleManager.destroy_module("henanmj", "roomsetting")
    ModuleManager.destroy_module("henanmj", "tablerule")
    ModuleManager.destroy_module("henanmj", "tablechat")
    ModuleBase.on_destroy(self)
    self:clear()
    self.isDestroy = true
end

return TableModule
