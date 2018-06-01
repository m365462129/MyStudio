--
-- Created by IntelliJ IDEA.
-- User: Jufeng01
-- Date: 2016/12/7
-- Time: 21:56
-- To change this template use File | Settings | File Templates.
--
local class = require("lib.middleclass")

--- @class PlayerView
--- @field module TableModule
--- @field view UnityEngine.GameObject
--- @field actionID number
--- @field chuzhang UnityEngine.GameObject
--- @field clone table
--- @field chutx UnityEngine.GameObject
--- @field chuzhangLight1 UnityEngine.GameObject
--- @field chuzhangLight2 UnityEngine.GameObject
local PlayerView = class("PaoHuZi.PlayerView")

local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local SoundManager = require("package.paohuzi.module.table.sound_manager")
local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")

local SmartTime = LuaBridge.SmartTimer.instance

local curTableData

local XIA_ZHANG_OFFSET = {43, -43, 43}
local QI_ZHANG_OFFSET = {{-32, -32}, {-32, 32}, {32, 32}}
local QI_ZHANG_ROW_COUNT = {10, 8, 8}
local SHOU_ZHANG_OFFSET = {0, 43, -43}

local ACTION_NAME = {"吃", "碰", "偎", "跑", "提", "胡", "弃", "出", "将"}

local V3_ZERO = Vector3.New(0, 0, 0)
local V3_ONE = Vector3.New(1, 1, 1)
local coroutine = require("coroutine")

function PlayerView:initialize(view, index, cloneRoot, module)
    curTableData = TableManager.phzTableData
    if not view then
        return
    end
    
    self.module = module
    self.view = view
    self.seatIndex = index
    self.siblingIndex = self.view.transform:GetSiblingIndex()
    
    -- 各个父节点
    self.holder = {
        xia_zhang = Manager.FindObject(view, "XiaZhangHolder"),
        qi_zhang = Manager.FindObject(view, "QiZhangHolder"),
        chuzhang = Manager.FindObject(view, "ChuZhangHolder"),
        pinzhang = Manager.FindObject(view, "PinZhangHolder/Holder"),
        chutx = Manager.FindObject(view, "TeXiaoHolder"),
        seat = Manager.FindObject(view, "SeatHolder"),
        playbackGrid = Manager.FindObject(view, "PlayBackGrid"),
        shou_zhang = Manager.FindObject(view, "ShouZhangHolder"),
        clock = Manager.FindObject(view, "ClockHolder")
    }
    
    -- 克隆 对象
    self.clone = {
        seat = Manager.FindObject(cloneRoot, "Seat"),
        shou_zhang = Manager.FindObject(cloneRoot, "ShouZhang"),
        qi_zhang = Manager.FindObject(cloneRoot, "QiZhang"),
        chuzhang = Manager.FindObject(cloneRoot, "ChuZhang"),
        xia_zhang = Manager.FindObject(cloneRoot, "XiaZhang"),
        pinzhang = Manager.FindObject(cloneRoot, "PinZhang"),
        chutx = Manager.FindObject(cloneRoot, "ChuTX" .. AppData.Game_Name)
    }
    
    self:bind_seat()
end

---绑定座位
---@param seatClone UnityEngine.GameObject
---@param seatIndex number
function PlayerView:bind_seat()
    if self.view then
        local root = TableUtilPaoHuZi.clone(self.clone.seat, self.holder.seat, V3_ZERO)
        self.seat = {
            root = root,
            objNone = Manager.FindObject(root, "NotSeatDown"),
            objNoneB = Manager.GetButton(root, "NotSeatDown"),
            FangZuoBi = Manager.GetButton(root, "FangZuoBi"),
            objInfo = Manager.FindObject(root, "Info"),
            objState = Manager.FindObject(root, "State"),
            head = Manager.GetImage(root, "Info/Avatar/Mask/Image"),
            btnHead = Manager.GetButton(root, "Info/Avatar/Image"),
            name = Manager.GetText(root, "Info/TextName"),
            highlight = Manager.FindObject(root, "Info/HighLight"),
            score = Manager.GetText(root, "Info/Point/Text"),
            leave = Manager.FindObject(root, "Info/ImageStateLeave"),
            offline = Manager.FindObject(root, "Info/ImageStateDisconnect"),
            kick = Manager.GetButton(root, "Info/ButtonKick"),
            banker = Manager.FindObject(root, "Info/ImageBanker"),
            ImageDuo = Manager.FindObject(root, "Info/ImageDuo"),
            objHuxi = Manager.FindObject(root, "Info/Huxi"),
            huxi = Manager.GetText(root, "Info/Huxi/Text"),
            objClock = Manager.FindObject(root, "Info/Clock"),
            clockNum = Manager.GetComponentWithPath(root, "Info/Clock/Image/Text", "TextWrap"),
            ready = Manager.FindObject(root, "State/Group/ImageReady"),
            tuoguanz = Manager.FindObject(root, "State/Group/ImageTuoGuanz"),
            tuoguany = Manager.FindObject(root, "State/Group/ImageTuoGuany"),
            speak = Manager.FindObject(root, "State/Group/Speak"),
            objBubble = Manager.FindObject(root, "State/Group/ChatBubble"),
            textLeft = Manager.GetText(root, "State/Group/ChatBubble/TextBgLeft/Text"),
            textRight = Manager.GetText(root, "State/Group/ChatBubble/TextBgRight/Text"),
            objFace = Manager.FindObject(root, "State/Group/ChatFace")
        }
        
        self.seat.face = TableUtilPaoHuZi.get_all_child(self.seat.objFace)
        
        local sw = Manager.GetComponent(self.seat.root, "UIStateSwitcher")
        if self.seatIndex == 2 then
            sw:SwitchState("Right")
        else
            sw:SwitchState("Left")
        end
        
        self.seat.objFace.transform.position = self.seat.head.transform.position
        self.seat.objClock.transform.position = self.holder.clock.transform.position
        self.seat.name.text = ""
        self:show_huxi(false)


        Manager.AddButtonListener(
            self.seat.objNoneB,
            function()
                FunctionPaoHuZi.invite_friend()
            end
    )   
        Manager.AddButtonListener(
            self.seat.btnHead,
            function()
                if self.playerInfo and not curTableData.isPlayBack then
                    ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", self.playerInfo)
                end
            end
    )   

    if self.seat.FangZuoBi then
        Manager.AddButtonListener(
            self.seat.FangZuoBi,
            function()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("开局后显示玩家信息")
            end
    ) 
    end

        
    end
end


--- 刷新角色信息
function PlayerView:refresh_player_info(data)
    if data then
        if not curTableData.isPlayBack then
            if not data.UserID or data.UserID == "0" then
                self.playerInfo = nil
                ComponentUtil.SafeSetActive(self.seat.objInfo, false)
                ComponentUtil.SafeSetActive(self.seat.objState, false)
                ComponentUtil.SafeSetActive(self.seat.objNone, true)
            else
                if (not curTableData.seatUserIdInfo) then
                    curTableData.seatUserIdInfo = {}
                end
                if not self.playerInfo then
                    self.playerInfo = {}
                end


                if data.Balance and data.Balance > 0 then
                    self:update_score(data.Balance)
                end
                
                self.playerInfo.playerId = data.UserID
                curTableData.seatUserIdInfo[data.SeatID .. ""] = data.UserID
                ComponentUtil.SafeSetActive(self.seat.objInfo, true)
                ComponentUtil.SafeSetActive(self.seat.objState, true)
                ComponentUtil.SafeSetActive(self.seat.objNone, false)

                --TODO XLQ:亲友圈快速组局 房主没有踢人功能
                if data.SeatID ~= 0 and curTableData.SeatID == 0 and not self.module.roundStart  and curTableData.RoomType ~= 2 then
                    self:show_kick( not (self.module:is_all_ready() and not DataPaoHuZi.Msg_Table_GameStateNTF ))
                    Manager.AddButtonListener(
                        self.seat.kick,
                        function()
                            self.module.model:request_kick_player(data.UserID)
                        end
                )
                else
                    self:show_kick(false)
                end

                --TODO XLQ:亲友圈 允许在线玩家踢出离线玩家     data.State 用户状态信息：0、在线；1、离开（休息）；2、离线
                if curTableData.RoomType == 2 and (not DataPaoHuZi.Msg_Table_GameStateNTF or DataPaoHuZi.Msg_Table_GameStateNTF.RealyRound == 0)  then
                    if  DataPaoHuZi.Msg_ReportStateNTF_Table and 
                    DataPaoHuZi.Msg_Table_GameStateNTF == nil and
                    DataPaoHuZi.Msg_ReportStateNTF_Table[data.SeatID] and 
                    tonumber(DataPaoHuZi.Msg_ReportStateNTF_Table[data.SeatID].State) == 2 then
                        self:show_kick(not (self.module:is_all_ready() and not DataPaoHuZi.Msg_Table_GameStateNTF ))
                        Manager.AddButtonListener(
                        self.seat.kick,
                        function()
                            self.module.model:request_kick_player(data.UserID)
                        end
                        )
                    end
                end


                self:show_clock(false)
                
                TableUtilPaoHuZi.download_seat_detail_info(
                    data.UserID,
                    function(playerInfo)
                        if not self.module.view then
                            return
                        end
                        self.seat.head.sprite = playerInfo.headImage
                        self.playerInfo.spriteHeadImage = self.seat.head.sprite

                        
                    end,
                    function(playerInfo)
                        if not self.module.view then
                            return
                        end

                        self.seat.name.text = string.gsub(Util.filterPlayerName(self.playerInfo.playerName,10), "%.", "")

                        self.man = playerInfo.gender == 1
                        self.ip = playerInfo.ip
                        if self.playerInfo then
                            self.playerInfo.ip = playerInfo.ip
                            self.playerInfo.playerName = playerInfo.playerName
                            self.playerInfo.gender = playerInfo.gender
                        end
                    end
            )
            end
        else

            ComponentUtil.SafeSetActive(self.seat.objInfo, true)
            ComponentUtil.SafeSetActive(self.seat.objState, false)
            ComponentUtil.SafeSetActive(self.seat.objNone, false)

            self.seat.name.text = string.gsub(Util.filterPlayerName(data.playerName,10), "%.", "")
            if self.dataStateoyl and self.dataStateoyl.total_hu_xi > 0 then
                self:update_score(self.dataStateoyl.total_hu_xi)
            else
                self:update_score(data.playerScore)
            end

            
            
            TableUtilPaoHuZi.only_download_head_icon(self.seat.head, data.headImg)
            self:show_light(false)
            self:show_banker(false)

        end
    else
        ComponentUtil.SafeSetActive(self.seat.objInfo, false)
        ComponentUtil.SafeSetActive(self.seat.objState, false)
        ComponentUtil.SafeSetActive(self.seat.objNone, true)
    end
end

--- 更新位置信 息
function PlayerView:update_location_data(data)
    if not self.playerInfo then
        self.playerInfo = {}
    end
    self.playerInfo.locationData = data
end

local TimeWenziDongHua = 0.8 -- 文字动 画
local TimeChuhangYiDong = 0.3
local TimeQiZhangYiDong = 0.5
local TimeShouZhangYidong = 0.1
local TimeXiaZhangYiDong = 0.15
--- 刷新游戏状态
function PlayerView:refresh_game_state(data, actionID, stay)

    print(actionID .. '  OAOA')

    if data then
        self:showHuPai()

        if actionID == 16 or actionID == 17 then
            return
        end
        if self.module.firstGameState or actionID == 0 then
            -- 如果是本人则  且为庄家 0.3秒后将牌隐藏
            self:refresh_xiazhang(data.xia_zhang, false)
            self:refresh_qizhang(data)
        elseif DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 then
            self:refresh_xiazhang(data.xia_zhang, false)
            self:refresh_qizhang(data)
        elseif actionID == 13 then
            self:show_chutx(actionID)
            self:show_chuzhang(data.qi_zhang[#data.qi_zhang], true)
            coroutine.wait(1)
            --self:add_dangdi()
            coroutine.wait(1)
            self:hide_chuzhang()
        elseif (actionID >= 1 and actionID <= 6) or (actionID >= 10 and actionID <= 15) or actionID == 18 or actionID == 19  then
            --ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('呵呵' .. actionID)

            if actionID == 10 then
                SoundManager:play_action(4, self.man)
                self:show_chutx(4)
            end

            if actionID == 14 then
                SoundManager:play_action(12, self.man)
                self:show_chutx(12)

            end

         
            if actionID == 14 or actionID == 15 then
                actionID = 10
            end

         

            if self.xiazhangList and actionID == 1 and #data.xia_zhang - #self.xiazhangList > 1 then
                SoundManager:play_name("bi",self.man)
            else
                if actionID == 6 and AppData.Game_Name == 'GLZP' then
                else

                    if actionID == 18 or actionID == 19 then
                        SoundManager:play_action(5, self.man) 
                    else
                        SoundManager:play_action(actionID, self.man)
                    end
                end
            end


            self:show_chutx(actionID)
           

            self:refresh_xiazhang(data.xia_zhang, true, actionID)

            for i=1,3 do
                if actionID ~= 18 and actionID ~= 19 then
                    self.playersViewAll[i]:hide_chuzhang()
                end
            end

     
            coroutine.wait(0.1)
        elseif actionID == 7 then
            self:add_qizhang(data.qi_zhang[#data.qi_zhang], true)
        elseif actionID == 8 then
            self:show_chuzhang(data.qi_zhang[#data.qi_zhang], true)
            SoundManager:play_nameroot('fanpai')

        elseif actionID == 9 then
          
        end

       
        self:add_shouzhang(data)
        self:update_huxi()
        self:update_tuoguan()

        if DataPaoHuZi.Msg_Table_GameStateNTF.result == 0 then
            self:refresh_xiazhangData(data.xia_zhang)
        end

        if DataPaoHuZi.Msg_Table_GameStateNTF and DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 then
            self:show_clock(false)
        end

    end
end


function PlayerView:showHuPai()
    --repeated int32 hu_fa_action 		= 21;     // 胡法的类型 0、流局 1、平胡 2、自摸 3、天胡  4、地胡  5、三笼五坎 6、接炮 7、点炮
    --optional bool is_dian_pao			 = 22;//是否点炮
   

    DataPaoHuZi.PlayerView_WaitTime = 0
    -- 点炮了
    local dataStateoyl = self.dataStateoyl
    if dataStateoyl.hu_fa_action ~= nil and #dataStateoyl.hu_fa_action > 0 then
        local hu_fa_action = dataStateoyl.hu_fa_action[1]

        if hu_fa_action >= 1 then
            --   点炮--->接炮  改为了  点炮--->胡      这个胡还是没音效的
            if hu_fa_action == 6 then
                hu_fa_action = 1
            end

            if hu_fa_action ~= 6 then
                SoundManager:play_name("k" .. hu_fa_action, self.man)
            end
            self:show_chutx(100 + hu_fa_action)
        end
    end
end


function PlayerView:clear_sequence()
    if self.chuzhangSeq then
        self.chuzhangSeq:Kill(false)
        self.chuzhangSeq = nil
    end
    
    if self.qizhangSeq then
        self.qizhangSeq:Kill(false)
        self.qizhangSeq = nil
    end
    
    if self.xiazhangSeq then
        self.xiazhangSeq:Kill(false)
        self.xiazhangSeq = nil
    end
end

function PlayerView:clear()
    self:clear_sequence()
    if self.clockEventId then
        SmartTime:Kill(self.clockEventId)
        self.clockEventId = nil
    end
    self.seat.name.text = ""
    self.seat.score.text = ""
    self.seat.objInfo:SetActive(false)
    self.huxi = 0
    self:show_light(false)
    self:show_offline(false)
    self:show_ready(false)
    self:show_banker(false)
    self:clear_cards()
end

function PlayerView:clear_cards()
   
    self.huxi = 0
    self:show_huxi(false)
    self:hide_chuzhang()
    self.xiazhangList = nil
    self.qizhangList = nil
    Manager.DestroyChildren(self.holder.xia_zhang)
    Manager.DestroyChildren(self.holder.qi_zhang)
    Manager.DestroyChildren(self.holder.pinzhang)
    Manager.DestroyChildren(self.holder.shou_zhang)
end

---更新胡息数
---@param huxi number
function PlayerView:update_huxi()
    self:SetRealHuXi()

    if not self.huxi then
        self.huxi = 0
    end
    self:show_huxi(true)
    if DataPaoHuZi.Msg_Table_GameStateNTFNew and DataPaoHuZi.Msg_Table_GameStateNTFNew.result == 2 then
        return
    end


    self.seat.huxi.text = self.huxi .. "胡"

  
end


---更新胡息数
---@param huxi number
function PlayerView:update_tuoguan()
    if not self.seat.tuoguanz then
        return
    end

    self.seat.tuoguanz.gameObject:SetActive(false)
    self.seat.tuoguany.gameObject:SetActive(false)

    local tuoguan = nil
    if self.seatIndex == 2 then
        tuoguan = self.seat.tuoguanz
    end

    if self.seatIndex == 3 then
        tuoguan = self.seat.tuoguany
    end

    if self.seatIndex == 1 then
        return
    end

    if self.dataStateoyl and self.dataStateoyl.IntrustState then
        tuoguan.gameObject:SetActive(self.dataStateoyl.IntrustState ~= 0)
    end
end

--- 显示胡息
function PlayerView:show_huxi(show)
    ComponentUtil.SafeSetActive(self.seat.objHuxi, show)
    ComponentUtil.SafeSetActive(self.seat.huxi.gameObject, show)
end

---更新分数
---@param score number
function PlayerView:update_score(score)
   
    self.module:start_lua_coroutine(
        function()
            if DataPaoHuZi.Msg_Table_GameStateNTF and DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 and self.view then
                coroutine.wait(3)
                if AppData.Game_Name == 'GLZP' then
                    coroutine.wait(5)
                end
            end
            local str = tostring(score)
            if score >= 100000000 then
                local yi = tostring(score / 100000000)
                local subIndex = string.find(yi, ".")
                str = string.sub(yi, 1, subIndex + 2) .. "亿"
            elseif score >= 10000 then
                local wan = tostring(score / 10000)
                local subIndex = string.find(wan, ".")
                str = string.sub(wan, 1, subIndex + 2) .. "万"
            end

            if self.dataStateoyl and (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
                self.seat.score.text = tostring(self.dataStateoyl.total_hu_xi)
            else
                self.seat.score.text = str
            end

            
        end
    )
end

---显示高亮
---@param b boolean
function PlayerView:show_light(b)
    self:show_clock(b)
    self.seat.highlight:SetActive(b)
end

---显示倒计时闹钟
---@param b boolean
function PlayerView:show_clock(b)
    if curTableData.isPlayBack then
        self.seat.objClock:SetActive(false)
        return
    end

    if DataPaoHuZi.Msg_Table_GameStateNTF and DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 then
        self.seat.objClock:SetActive(false)
        return
    end

    self.seat.objClock:SetActive(b)
    if self.clockEventId then
        SmartTime:Kill(self.clockEventId)
        self.clockEventId = nil
    end

    if self.show_clock_coroutine then
        coroutine.stop(self.show_clock_coroutine)
        self.show_clock_coroutine = nil
    end
    
    if not b then
        return
    end

    local time = DataPaoHuZi.Msg_Table_GameStateNTF.IntrustRestTime

    local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)
    if ruleInfo.baseScore then
        
    else
        time = 15
    end

    self.show_clock_coroutine = self.module:start_lua_coroutine(function ()
        self.indexofccsa = self.indexofccsa or 0
        self.indexofccsa = self.indexofccsa + 1


        for i=time,1,-1 do
            self:set_clock_num(i)

            local indexofccsa = self.indexofccsa

            coroutine.wait(1)
            if indexofccsa ~= self.indexofccsa then
                break
            end
            self.seat.objClock:SetActive(true)
            if i <= 5 then
                SoundManager:play_clock()
            end
            if DataPaoHuZi.Msg_Table_GameStateNTF and DataPaoHuZi.Msg_Table_GameStateNTF.result ~= 0 or self:has_actionWhat(6) then
                self.seat.objClock:SetActive(false)
                return
            end
        end
        if not self.module.view.openShake then
            ModuleCache.GameSDKInterface:ShakePhone(1000)
        end
        self.seat.objClock:SetActive(false)
    end)

end

---设置倒计时闹钟数字
---@param num number
function PlayerView:set_clock_num(num)
    self.seat.clockNum.num = num
end

---显示离线
---@param b boolean
function PlayerView:show_offline(b)
    self.seat.offline:SetActive(b)
end

--- 显示离开
--- @param b boolean
function PlayerView:show_leave(b)
    self.seat.leave:SetActive(b)
end

---显示庄家
---@param b boolean
function PlayerView:show_banker(b)
    self.seat.banker:SetActive(b)
end
---显示 duo 
---@param b boolean
function PlayerView:show_ImageDuo(b)
    if self.seat.ImageDuo then
        self.seat.ImageDuo:SetActive(b)
    end
end


---显示准 备
---@param b boolean
function PlayerView:show_ready(b)
    self.seat.ready:SetActive(b)
    if DataPaoHuZi.Msg_Table_GameStateNTF and DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 then
          -- self.seat.ready:SetActive(false)
    end
end

--- 显示踢人
function PlayerView:show_kick(b)
    ComponentUtil.SafeSetActive(self.seat.kick.gameObject, b)
end

function PlayerView:show_chuzhangSelf(value, playAnim)
    self.module:start_lua_coroutine(function ()
        self:show_chuzhang(value, true)
    end)
    --dself.chuzhangSelf = self.chuzhang
end


---显示出张
---@param value number
---@param isZhua boolean
function PlayerView:show_chuzhang(value, playAnim)
    -- 3.8 加入代码。即当前有出张，  则不播放出张动画了
   -- print(DataPaoHuZi.chuzhangValue,DataPaoHuZi.chuzhangLocalIndex,self:getIsHaveChuZhang())
    if self.chuzhang and self:getIsHaveChuZhang() and DataPaoHuZi.chuzhangValue == value and DataPaoHuZi.chuzhangLocalIndex == self.seatIndex then
       if self.chuzhang then
          self.chuzhang.gameObject:SetActive(true)
       end
       return
    end
    DataPaoHuZi.chuzhangValue = value
    DataPaoHuZi.chuzhangLocalIndex = self.seatIndex
    

    if not self.chuzhang then
        self.chuzhang = TableUtilPaoHuZi.clone(self.clone.chuzhang, self.holder.chuzhang, V3_ZERO)
        self.chuzhang.gameObject:SetActive(false)
        self.chuzhangLight1 = Manager.FindObject(self.chuzhang, "Image/1")
        self.chuzhangLight2 = Manager.FindObject(self.chuzhang, "Image/2")
    end

    local bg1 = Manager.FindObject(self.chuzhang, "Image/1")
    local bg2 = Manager.FindObject(self.chuzhang, "Image/2")
    bg1:SetActive(false)
    bg2:SetActive(false)

    if DataPaoHuZi.ZP_ZPPaiLei == 3 then
        bg2:SetActive(true)
    else
        bg1:SetActive(true)
    end

    --print(self.chuzhangSelf , self.seatIndex == 1)
    if self.chuzhangSelf and self.seatIndex == 1 then
        self.chuzhangSelf = nil
        return
    end


    DataPaoHuZi.ChuZhangObj = self.chuzhang
    DataPaoHuZi.chuzhangPosThis = self.chuzhang.transform.position

    if playAnim then
        if value ~= 0 then
            SoundManager:play_card(value, self.man)
        end
    end

    TableUtilPaoHuZi.set_card(self.chuzhang, value, nil, "ZiPai_CurPutCards")
    
    --ZiPai_CurPutCards  ZiPai_HandCards
    if self.module.firstGameState or not playAnim then
        self.chuzhang.transform.localScale = V3_ONE
        self.chuzhang:SetActive(true)
    else
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, true)
        local stayTime = 0
        TableUtilPaoHuZi.print("播放出张 动画")
        self.chuzhang.transform.localScale = V3_ZERO
        self.chuzhang:SetActive(true)

        
        DataPaoHuZi.chuzhangPos = self.holder.chuzhang.transform.position

        self.chuzhang.transform.position = self.holder.chuzhang.transform.position

        local isPaiDui = false
        -- 代表牌堆当中出来的牌
        if DataPaoHuZi.Msg_Table_GameStateNTFLast ~= nil then
            if #DataPaoHuZi.Msg_Table_GameStateNTFLast.dun - #DataPaoHuZi.Msg_Table_GameStateNTF.dun == 1 then
                self.chuzhang.transform.position = TableUtilPaoHuZi.viewRoot.TopPos
                isPaiDui = true
                --timejiange = 0.2
            end
        end




      

        local time = 0.15

        if isPaiDui then
           time = TimeChuhangYiDong
        end


        self.chuzhangSeq = self.module.view:create_sequence()
        local tw = Manager.DoScale(self.chuzhang, V3_ONE, time)
        local tw1 = Manager.Move(self.chuzhang, DataPaoHuZi.chuzhangPos, time)
        self.chuzhangSeq:Append(tw)
        self.chuzhangSeq:Join(tw1)
        self.chuzhangSeq:AppendInterval(stayTime)
        self.chuzhangSeq:SetAutoKill(true)

        local boolFalgAi = true
        self.chuzhangSeq:OnComplete(
            function()
                boolFalgAi = false
                TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, false)
            end
        )
        self.chuzhangSeq:Play()

        for i=1,300 do
            coroutine.wait(0.1)
            if not boolFalgAi then
                break
            end
        end

        
    end
--self.chuzhangLight1:SetActive(isZhua)  .self.viewRoot.CenterPos
--self.chuzhangLight2:SetActive(not isZhua)
end

function PlayerView:show_dangdi(value)
end

---隐藏出张
function PlayerView:hide_chuzhang()

    if self.chuzhang then
        self.chuzhang:SetActive(false)
        self.chuzhang.transform.localScale = V3_ZERO
        self.chuzhang.transform.position = TableUtilPaoHuZi.viewRoot.CenterPos
    end
end

--是否有出张
function PlayerView:getIsHaveChuZhang()
    if self.chuzhang then
        return self.chuzhang.gameObject.activeInHierarchy
    end
    return false
end


---添加挡抵
function PlayerView:add_dangdi()
    local qizhangSeq = self.module.view:create_sequence()
    self.chuzhang:SetActive(true)
    self.chuzhang.transform.position = TableUtilPaoHuZi.viewRoot.CenterPos
    local tw1 = Manager.Move(self.chuzhang, self.holder.chuzhang.transform.position, 0.2)
    qizhangSeq:Append(tw1)
    qizhangSeq:OnComplete(
        function()
            
        end
    )
    qizhangSeq:Play()
end

--- 刷新弃张
function PlayerView:refresh_qizhang(data)
    if curTableData.isPlayBack then
        self.qizhangList = nil
        Manager.DestroyChildren(self.holder.qi_zhang)
    end
    local qizhangCount = 0
    if self.qizhangList then
        qizhangCount = #self.qizhangList
    end
    if qizhangCount < #data.qi_zhang then
        for i = qizhangCount + 1, #data.qi_zhang do
            if i == #data.qi_zhang and data.chu_pai then
                self:show_chuzhang(data.qi_zhang[i], false)
            else
                self:add_qizhang(data.qi_zhang[i], false)
            end
        end
    end
end

--- 刷新弃张
function PlayerView:refresh_qizhangMy(data)
    data = self.dataStateoyl
    if not self.holder then
        return
    end

    self.qizhangList = nil
    Manager.DestroyChildren(self.holder.qi_zhang)
    
    for i = 1, #data.qi_zhang do
        self:add_qizhangMy(data.qi_zhang[i])
    end
end

function PlayerView:add_qizhangMy(value)
    self.qizhangList = self.qizhangList or {}
    table.insert(self.qizhangList, value)
    local x = ((#self.qizhangList - 1) % QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][1]
    local y =
        math.floor((#self.qizhangList - 1) / QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][2]
    local pos = Vector3.New(x, y, 0)
    ---@type UnityEngine.GameObject
    local qi_zhang = TableUtilPaoHuZi.clone(self.clone.qi_zhang, self.holder.qi_zhang, pos)
    qi_zhang:SetActive(true)
    TableUtilPaoHuZi.set_card(qi_zhang, value, nil, "ZiPai_PlayCards")
    --ZiPai_CurPutCards  ZiPai_HandCards
    qi_zhang.transform.localScale = V3_ONE
    qi_zhang:SetActive(true)
end

---添加弃张
---@param value number
function PlayerView:add_qizhang(value, playAnim, stay)

    local boolCao = true

    DataPaoHuZi.chuzhangValue = DataPaoHuZi.chuzhangValue or 0
    if DataPaoHuZi.chuzhangValue == value then
        boolCao = false
    end
    if boolCao and playAnim then
        return
    end


    local stayTime = 0
    TableUtilPaoHuZi.print("添加弃张", value)
    if not self.qizhangList then
        self.qizhangList = {}
    end
    table.insert(self.qizhangList, value)
    local x = ((#self.qizhangList - 1) % QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][1]
    local y =
        math.floor((#self.qizhangList - 1) / QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][2]
    local pos = Vector3.New(x, y, 0)
    ---@type UnityEngine.GameObject
    local qi_zhang = TableUtilPaoHuZi.clone(self.clone.qi_zhang, self.holder.qi_zhang, pos)
    TableUtilPaoHuZi.set_card(qi_zhang, value, nil, "ZiPai_PlayCards")
    --ZiPai_CurPutCards  ZiPai_HandCards .transform.position = TableUtilPaoHuZi.viewRoot.CenterPos
    qi_zhang.transform.localScale = V3_ZERO
    
    qi_zhang:SetActive(true)
    if self.module.firstGameState or not playAnim then
        TableUtilPaoHuZi.print("没播弃张动画，执行回调 " )
        qi_zhang.transform.localScale = V3_ONE
        
        for i=1,3 do
            for i=1,3 do
                --self.playersViewAll[i]:hide_chuzhang()
            end
        end

        if DataPaoHuZi.booIsLoadAll_ZiPai then
            self:refresh_qizhangMy()
        end
    else
        TableUtilPaoHuZi.print("播放弃张动画  ")
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, true)
        local time = TimeQiZhangYiDong
        if self.qizhangSeq then
            self.qizhangSeq:Kill(false)
            self.qizhangSeq = nil
        end

        DataPaoHuZi.chuzhangPos = DataPaoHuZi.chuzhangPos or TableUtilPaoHuZi.viewRoot.CenterPos

        self.qizhangSeq = self.module.view:create_sequence()
        self.qizhangSeq:AppendInterval(stayTime)
     

        if not self.chuzhang then
            self.chuzhang = UnityEngine.GameObject.New()
        end

        self.chuzhang:SetActive(true)
        self.chuzhang.transform.localScale = V3_ONE
        self.chuzhang.transform.position = DataPaoHuZi.chuzhangPos
        local tw1 = Manager.Move(self.chuzhang, qi_zhang.transform.position, time)
        local tw2 = Manager.DoScale(self.chuzhang, 0.3, time)
        self.qizhangSeq:Append(tw1)
        self.qizhangSeq:Join(tw2)
        --seq:PrependInterval(0.05)
        self.qizhangSeq:SetAutoKill(true)

        local boolFlag = true
        self.qizhangSeq:OnComplete(
            function()
                boolFlag = false
                -- 播放完毕 弃张动画后       直接刷新所有 弃张
                self:hide_chuzhang()
                --qi_zhang.transform.localScale = V3_ONE
                TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, false)
                self:refresh_qizhangMy()
            end
        )

        self.qizhangSeq:Play()

        for i=1,0 do
            coroutine.wait(0.1)
            if not boolFlag then
                break
            end
        end

    
    end
end

function PlayerView:refresh_xiazhangData(data)
    self.xiazhangList = nil
    Manager.DestroyChildren(self.holder.xia_zhang)
    self.xiazhangList = nil
    self.huxi = 0
    for i = 1, #data do
        local obj = self:add_xiazhangData(data[i])
        obj.transform.localScale = V3_ONE
    end
    self:update_huxi()
end


--- 刷新下张
function PlayerView:refresh_xiazhang(data, playAnim, actionID)

    if curTableData.isPlayBack and not playAnim then
        self.xiazhangList = nil
        self.huxi = 0
        self.xiazhangList = nil
        Manager.DestroyChildren(self.holder.xia_zhang)
        Manager.DestroyChildren(self.holder.pinzhang)
    end
    if not self.xiazhangList then
        self.xiazhangList = {}
    end
    
    local act = actionID
    local booIsLoadAll = act and (act == 4 or act == 5 or (act >= 10 and act <= 12))
   
    local xia_zhang = {}
    
    if actionID == 6 and self.seatIndex == 2 then
        for i = #data, #self.xiazhangList + 1, -1 do
            table.insert(xia_zhang, self:add_xiazhang(data[i]))
        end
    else
        for i = #self.xiazhangList + 1, #data do
            table.insert(xia_zhang, self:add_xiazhang(data[i]))
        end

        --print(booIsLoadAll,#xia_zhang,'呵呵笑什么笑啊哎2')
        if booIsLoadAll and #xia_zhang == 0 and actionID then
            local valuesis = DataPaoHuZi.chuzhangValue or 0   
            local kan = {}
            local pai = {}
            pai[1] = DataPaoHuZi.chuzhangValue
            pai[2] = DataPaoHuZi.chuzhangValue
            pai[3] = DataPaoHuZi.chuzhangValue
            pai[4] = DataPaoHuZi.chuzhangValue
            kan.pai = pai
            kan.des = ''
            kan.status = {}
            kan.status[1] = 0
            kan.hu_xi = 0
            table.insert(xia_zhang, self:add_xiazhang(kan))
        end
    end


    if self.module.firstGameState or not playAnim then
        for i = 1, #xia_zhang do
            xia_zhang[i].transform.localScale = V3_ONE
        end
        Manager.DestroyChildren(self.holder.pinzhang)
    else
        self.view.transform:SetAsLastSibling()
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, true)
        local time = 0.16
        if self.xiazhangSeq then
            self.xiazhangSeq:Kill(false)
            self.xiazhangSeq = nil
        end
        self.xiazhangSeq = self.module.view:create_sequence()
        self.xiazhangSeq:AppendInterval(0.2)
        if not xia_zhang or #xia_zhang == 0 then
            self.xiazhangSeq:Kill(false)
            self.xiazhangSeq = nil
            Manager.DestroyChildren(self.holder.pinzhang)

            
            return
        end

        local pos = xia_zhang[1].transform.position
        if #xia_zhang > 2 then
            pos = xia_zhang[2].transform.position
        end

        DataPaoHuZi.chuzhangPos = DataPaoHuZi.chuzhangPos or TableUtilPaoHuZi.viewRoot.CenterPos

        if actionID ~= 18 and actionID ~= 19 then
            if DataPaoHuZi.ChuZhangObj then
                DataPaoHuZi.ChuZhangObj.gameObject:SetActive(false)
            end
        end

        if DataPaoHuZi.ChuZhangObj then
            local obj234234 = TableUtilPaoHuZi.clone(DataPaoHuZi.ChuZhangObj, self.holder.chuzhang, V3_ONE)
            obj234234.gameObject:SetActive(true)
            obj234234.transform.position = DataPaoHuZi.chuzhangPos
            local imgssss = obj234234:GetComponent('CanvasGroup')
            imgssss:DOFade(0,0.6)
        end
        
        self.holder.pinzhang.transform.position = self.holder.pinzhang.transform.position
        self.holder.pinzhang.transform.localScale = V3_ONE
        local tw1 = Manager.Move(self.holder.pinzhang, pos, TimeXiaZhangYiDong)
        local tw2 = Manager.DoScale(self.holder.pinzhang, 0.5, TimeXiaZhangYiDong)
        self.xiazhangSeq:Append(tw1)
        self.xiazhangSeq:Join(tw2)
        self.xiazhangSeq:PrependInterval(0.5)
        self.xiazhangSeq:SetAutoKill(true)

        local boofalgcao = true
        self.xiazhangSeq:OnComplete(
            function()
                boofalgcao = false
                self.view.transform:SetSiblingIndex(self.siblingIndex)
                --- 胡的时候把所有下张清除重新生成，规避偎、跑、       提后胡牌导致的下张显示重复问题

                if actionID == 6 or booIsLoadAll or DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 then
                    self.xiazhangList = nil
                    Manager.DestroyChildren(self.holder.xia_zhang)
                    self.xiazhangList = nil
                    self.huxi = 0
                    for i = 1, #data do
                        local obj = self:add_xiazhang(data[i])
                        obj.transform.localScale = V3_ONE
                    end
                    self:update_huxi()
                else
                    for i = 1, #xia_zhang do
                        self.module:start_lua_coroutine(
                            function()
                                self.module:start_lua_coroutine(
                                    function()
                                        xia_zhang[i].transform.localScale = V3_ONE
                                    end
                            )
                            end
                    )
                    end
                end
                
                Manager.DestroyChildren(self.holder.pinzhang)
                self.holder.pinzhang.transform.localScale = V3_ZERO
                self.holder.pinzhang.transform.localPosition = V3_ZERO
                TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, false)
            end
        )
        self.xiazhangSeq:Play()

        for i=1,300 do
            coroutine.wait(0.1)
            if not boofalgcao then
                break
            end
        end
        

    end


    if DataPaoHuZi.Msg_Table_GameStateNTF.result == 1 and not playAnim or DataPaoHuZi.booIsLoadAll_ZiPai then
        self.xiazhangList = nil
        Manager.DestroyChildren(self.holder.xia_zhang)
        self.xiazhangList = nil
        self.huxi = 0
        for i = 1, #data do
            local obj = self:add_xiazhang(data[i])
            obj.transform.localScale = V3_ONE
        end
        self:update_huxi()
    end
end

function PlayerView:bianse()

end

function PlayerView:SetRealHuXi()
    if self.dataStateoyl then
        local hu_xi = 0

        for i=1,#self.dataStateoyl.xia_zhang do
            local kan = self.dataStateoyl.xia_zhang[i]
            hu_xi = hu_xi + kan.hu_xi
        end

        if hu_xi > self.huxi then
            self.huxi = hu_xi
        end
    else
        self.huxi = 0
        
    end
end


function PlayerView:add_xiazhangData(cards)
    if not self.xiazhangList then
        self.xiazhangList = {}
    end
    
    table.insert(self.xiazhangList, cards)
    if not self.huxi then
        self.huxi = 0
    end
    self.huxi = self.huxi + cards.hu_xi

    
    local x = (#self.xiazhangList - 1) * XIA_ZHANG_OFFSET[self.seatIndex]
    ---@type UnityEngine.GameObject
    local xia_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, self.holder.xia_zhang, Vector3.New(x, 0, 0))
  
    for i = 1, 4 do
        local obj = Manager.FindObject(xia_zhang, tostring(i))
        if cards.pai[i] then
            local status = nil 
            if DataPaoHuZi.Msg_Table_GameStateNTF.result == 0 then
                status = cards.status[i]
            end
            GRAYYanse = GRAYYanse or Color.New(0.8, 0.8, 0.8, 1)    

            if cards.status[i] == 1 then
                TableUtilPaoHuZi.set_card(obj, cards.pai[i], GRAYYanse, "ZiPai_PlayCards", status)
            else
                TableUtilPaoHuZi.set_card(obj, cards.pai[i], nil, "ZiPai_PlayCards", status) 
            end
            --ZiPai_CurPutCards  ZiPai_HandCards
            obj:SetActive(true)
        else
            obj:SetActive(false)
        end
    end
    xia_zhang.transform.localScale = V3_ZERO
    xia_zhang:SetActive(true)
    
    return xia_zhang
end

---添加下张
---@param cards table
function PlayerView:add_xiazhang(cards)
    if not self.xiazhangList then
        self.xiazhangList = {}
    end
    
    table.insert(self.xiazhangList, cards)
    if not self.huxi then
        self.huxi = 0
    end
    self.huxi = self.huxi + cards.hu_xi

    
    local x = (#self.xiazhangList - 1) * XIA_ZHANG_OFFSET[self.seatIndex]
    ---@type UnityEngine.GameObject
    local xia_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, self.holder.xia_zhang, Vector3.New(x, 0, 0))
    ---@type UnityEngine.GameObject
    local pinzhang = TableUtilPaoHuZi.clone(self.clone.pinzhang, self.holder.pinzhang, V3_ZERO)
    self.holder.pinzhang.transform.localScale = V3_ZERO
    self.holder.pinzhang.transform.localPosition = V3_ZERO
    for i = 1, 4 do
        local obj = Manager.FindObject(xia_zhang, tostring(i))
        local pinObj = Manager.FindObject(pinzhang, tostring(i))
        if cards.pai[i] then
            local status = nil 
            if DataPaoHuZi.Msg_Table_GameStateNTF.result == 0 then
                status = cards.status[i]
            end
            GRAYYanse = GRAYYanse or Color.New(0.8, 0.8, 0.8, 1)    

            if cards.status[i] == 1 then
                TableUtilPaoHuZi.set_card(obj, cards.pai[i], GRAYYanse, "ZiPai_PlayCards", status)
            else
                TableUtilPaoHuZi.set_card(obj, cards.pai[i], nil, "ZiPai_PlayCards", status) 
            end
            --ZiPai_CurPutCards  ZiPai_HandCards
            obj:SetActive(true)


            TableUtilPaoHuZi.set_card(pinObj, cards.pai[i], nil, "ZiPai_CurPutCards")
            pinObj:SetActive(true)

            -- 屏蔽出张
            self:PingBiChuZhang(cards.pai[i])
        else
            obj:SetActive(false)
            pinObj:SetActive(false)
        end
    end
    xia_zhang.transform.localScale = V3_ZERO
    xia_zhang:SetActive(true)
    
    return xia_zhang
end

function PlayerView:PingBiChuZhang(value)
    local dataLast = DataPaoHuZi.Msg_Table_GameStateNTFLast

end

--- 添加手张
function PlayerView:add_shouzhang(data)
    Manager.DestroyChildren(self.holder.shou_zhang)

    local result = DataPaoHuZi.Msg_Table_GameStateNTF.result

    if self.seatIndex ~= 1 or (self.seatIndex == 1 and result == 1 and not curTableData.isPlayBack)  then
        local shouzhangList = {}
        for i = 1, #data.fixed_pai do
            table.insert(shouzhangList, data.fixed_pai[i])
        end
        for i = 1, #data.shou_zhang do
            table.insert(shouzhangList, data.shou_zhang[i])
        end
        
        local startX = 0
        if not curTableData.isPlayBack and self.xiazhangList then
            --startX = #self.xiazhangList * XIA_ZHANG_OFFSET[self.seatIndex] + SHOU_ZHANG_OFFSET[self.seatIndex] / 2
            startX = #self.xiazhangList * XIA_ZHANG_OFFSET[self.seatIndex]
        end
        for i = 1, #shouzhangList do
            local holder, x
            
            if curTableData.isPlayBack then
                holder = self.holder.shou_zhang
                x = startX + (i - 1) * SHOU_ZHANG_OFFSET[self.seatIndex]
            else
                holder = self.holder.xia_zhang
                x = startX + (i - 1) * XIA_ZHANG_OFFSET[self.seatIndex]
            end
            --local shou_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, self.holder.xia_zhang, Vector3.New(x, 15, 0))
            local shou_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, holder, Vector3.New(x, 0, 0))
            
            if curTableData.isPlayBack then
                --shou_zhang.transform.localScale = Vector3.New(1.18, 1.18, 1)
            end
            
            --local index = 0
            for j = 1, 4 do
                --index = index + 1
                local obj = Manager.FindObject(shou_zhang, tostring(j))
                if shouzhangList[i].pai[j] then
                    local color2 = nil
                    
                    TableUtilPaoHuZi.set_card(obj, shouzhangList[i].pai[j].pai, color2, "ZiPai_PlayCards")
                    Manager.SetActive(obj, true)
                else
                    Manager.SetActive(obj, false)
                end
            end
        end
    end
end

---显示要牌特效
---@param index number
function PlayerView:show_chutx(actionID)
    local boolF = false
    if actionID == 11 or actionID == 12 or actionID == 10 or actionID == 13 or actionID > 90 or actionID == 18 or actionID == 19 then
        boolF = true
    end
    if (actionID >= 1 and actionID <= 6) or boolF then
        if actionID == 18 or actionID == 19 then
            actionID = 5
        end


        if actionID == 4 and AppData.Game_Name == "GLZP" then
            actionID = 19
        end


        if actionID == 1 or actionID == 2 then
            SoundManager:play_nameroot('chipeng')
        end

        if actionID == 6 and AppData.Game_Name == "GLZP" then
            return
        end
        


        if not self.chutx then
            self.chutx = Manager.CopyObject(self.clone.chutx, self.holder.chutx)
            self.chutxImg1 = Manager.GetImage(self.chutx, "Animator/WenBen")
            self.chutxImg2 = Manager.GetImage(self.chutx, "Animator/GaoLiang")
            self.chutxImg3 = Manager.GetImage(self.chutx, "Animator/DiBu")
            self.chutxSpriteHolder = Manager.GetComponent(self.chutx, "SpriteHolder")
        end
        local sprite = self.chutxSpriteHolder:FindSpriteByName(tostring(actionID))
        -- 去掉动画：放炮、胡、自摸、档底 ss            1、平胡 2、自摸 3、天胡  4、地胡  5、三笼五坎 6、接炮 7、点炮
        self.chutxImg1.sprite = sprite
        self.chutxImg2.sprite = sprite
        self.chutxImg1:SetNativeSize()
        self.chutxImg2:SetNativeSize()
        self.chutxImg3:SetNativeSize()
        self.chutx:SetActive(false)
        self.chutx:SetActive(true)
        if actionID ~= 1 and actionID ~= 2 then
            --coroutine.wait(TimeWenziDongHua)
        end

    end

end

--- 判断是否有动作ID
function PlayerView:has_actionWhat(id)
    local data = DataPaoHuZi.Msg_Table_GameStateNTF

    for i = 1, #data.player do

        if data.action then
            for j = 1, #data.action do
                if data.action[j].action == id then
                    return true
                end
            end
        end
    end

    return false
end

--- 播放短 语
function PlayerView:play_shot_voice(index)
    if self.module.view.openVoice then
        TableUtilPaoHuZi.print("播放短语    ", index)
        SoundManager:play_shot_voice(index, self.man)
    end
end

--- 显示聊天文字
function PlayerView:show_chat_bubble(text)
    Manager.SetActive(self.seat.objBubble, true)
    self.seat.textRight.text = text
    self.seat.textLeft.text = text
    Manager.SetActive(self.seat.textRight.gameObject, self.seatIndex == 2)
    Manager.SetActive(self.seat.textLeft.gameObject, self.seatIndex ~= 2)
    self.view.transform:SetAsLastSibling()
    self:insert_callback(
        3,
        function()
            self.view.transform:SetSiblingIndex(self.siblingIndex)
            Manager.SetActive(self.seat.objBubble, false)
            Manager.SetActive(self.seat.textRight.gameObject, false)
            Manager.SetActive(self.seat.textLeft.gameObject, false)
        end
)
end

--- 显示聊天表情
function PlayerView:show_chat_face(index)
    if not self.seat.face[index] then
        return
    end

    self.selfFaceList = self.selfFaceList or {}
    table.insert(self.selfFaceList, index)

    self.XunHuanFace_coroutine = self.XunHuanFace_coroutine or self.module:start_lua_coroutine(
        function()
            while true do
                if #self.selfFaceList > 0 then
                    local dex = self.selfFaceList[1]
                    table.remove(self.selfFaceList, 1)

                    Manager.SetActive(self.seat.objFace, true)
                    Manager.SetActive(self.seat.face[dex], true)

                    coroutine.wait(3) 

                    Manager.SetActive(self.seat.objFace, false)
                    Manager.SetActive(self.seat.face[dex], false)
                end
                coroutine.wait(0.05) 
            end
        end
    )
end

--- 显示语音
function PlayerView:show_voice(show)
    Manager.SetActive(self.seat.speak, show)
end

function PlayerView:insert_callback(t, callback)
    local seq = self.module.view:create_sequence()
    seq:InsertCallback(
        t,
        function()
            if callback then
                callback()
            end
        end
    )
    seq:SetAutoKill(true)
    seq:Play()
end

return PlayerView
