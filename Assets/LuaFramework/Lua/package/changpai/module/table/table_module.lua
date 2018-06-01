local require = require
local Manager = require("manager.function_manager")
local ModuleCache = ModuleCache
local TableUtil = require("package.changpai.module.table.table_util")
local class = require("lib.middleclass")
local ModuleBase = require('package.changpai.module.tablebase.tablecpbase_module')

local TableModule = class('TableModule', ModuleBase)
local TableManager = require("package.henanmj.table_manager")

local Input = UnityEngine.Input
local dragYLimit = 110
local math = math
local string = string

function TableModule:initialize(...)
    ModuleBase.initialize(self, "table_view", "table_model", ...)
    local def = TableUtil.get_int_def_prefs()
    self.modelData.fan = Manager.GetPlayerPrefsInt("NTCP_FAN", def) == 0 -- 0:繁体 1:简体
    self.modelData.upright = Manager.GetPlayerPrefsInt("NTCP_UPRIGHT", def) == 1 -- 1:正立 0:倒立
    self.view.uprigh = self.modelData.upright
    --print(tostring(def) .. tostring(self.modelData.fan) .. " " .. tostring(self.modelData.upright))
    Manager.SetActive(self.view.jianObj, self.modelData.fan)
    Manager.SetActive(self.view.fanObj, not self.modelData.fan)
    self:set_activity_active()
end

function TableModule:set_activity_active()
    local object =
    {
        buttonActivity=self.view.buttonActivity,
        spriteRedPoint = self.view.spriteActivityRedPoint
    }
    ModuleCache.ModuleManager.show_public_module("activity", object)
end

function TableModule:on_module_inited(...)
    ModuleBase.on_module_inited(self)
end

function TableModule:on_module_event_bind()
    ModuleBase.on_module_event_bind(self)

    self:subscibe_module_event("tablestrategy", "Event_TableStragy_BeginGame", function(eventHead, eventData)
        self.model:request_select_piao(eventData)
    end)
    -- 一局结束开始下一局
    self:subscibe_module_event("tablestrategy", "Event_Show_TableStrategy", function(eventHead, eventData)
        self.view.ReadyTing = false
        self.view:reset_seat_all_mj()
        self.showOneResult = false
        self.model:request_restart_mj()
        self:set_activity_active()
    end)

    self:subscibe_model_event("Event_Msg_ReturnKickedTimeOutNTF", function(eventHead, eventData)
        if self.kickedTimeId then
            Manager.KillSmartTimer(self.kickedTimeId)
        end
        self.view:readyBtn_showCountDown(true)
        self.kickedTimeId = self:subscibe_time_event(eventData.Time, false, 0):OnUpdate(function(t)
            t = t.surplusTimeRound
            self.view.buttonBegin_countDownTex.text = "(" .. t .. "s)"
        end):OnComplete(function(t)
            self.view:readyBtn_showCountDown(false)
        end).id
    end)

    -- 退出房间
    self:subscibe_model_event("Event_Msg_Exit_Room", function(eventHead, eventData)
        -- 这个侯震哥哥注释掉的我为什么要加上呢
        if (eventData.Error and eventData.Error == 0) then
            if ModuleCache.ModuleManager.module_is_active("changpai", "totalgameresult") then
                TableManager:disconnect_all_client_no_exit_room()
                self:dispatch_module_event("roomsetting", "Event_Receive_Msg_Exit_Room")
            else
                self:exit_room()
            end
        else
            Manager.ShowTextPrompt("离开房间失败:" .. eventData.Error)
        end
    end)

    self:subscibe_package_event("Event_Send_ChatMsg", function(eventHead, eventData)
        self.model:request_chat(eventData)
    end)

    self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData)
    end )

    self:subscibe_package_event("Event_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData)
    end)

    self:subscibe_package_event("Event_PlayBackFrame", function(eventHead, eventData)
        if (eventData) then
            self.gameState = eventData
            if (not self.resultWait and self.gameState.Result == 0) then
                self.resultWait = true
            end
            print("refresh game state-----------------------------------------------")
            self.view:refresh_game_state(eventData)
            self:show_game_result(eventData)
        end
    end)

    self:subscibe_package_event("Event_Msg_Table_UserStateNTF", function(eventHead, eventData)
        self:refresh_user_state(eventData)
        self.view:refresh_user_state(eventData)
    end)

    --UpdateBeat:Add(self.on_update, self)
end

-- 还是得用刷帧的方式来拖动
function TableModule:on_update()
    if self.isDrag and self.checkTouchCount then
        if Input.touchCount < 1 then
            self:on_end_drag(self.isDragMjobj)
        else
            self:on_update_dragbj_pos(self.isDragMjobj.transform)
        end
    end
end

function TableModule:on_press_up(obj, arg)
    if (obj and obj.name == "ButtonMic") then
        ModuleBase.press_up_voice(self, obj, arg)
    end

end

function TableModule:can_drag_mj(obj)
    return (obj and string.sub(obj.name, 1, 4) == "inMJ" or string.sub(obj.name, 1, 10) == "readyChuMJ" or string.sub(obj.name, 1, 6) == "dragMJ") and self.view:is_me_chu_mj(obj)
    and (not self.view:is_liaolong_state())
end

-- on_press_up -> on_click -> on_end_drag
function TableModule:on_begin_drag(obj, arg)
    -- 手机上可以多点操作，所以过滤掉
    if self.isDragMjobj then
        return
    end

    if (self:can_drag_mj(obj)) then
        --self.beginSiblingIndex = obj.transform:GetSiblingIndex()
        --obj.transform:SetAsLastSibling()
        self.beginPressPos = obj.transform.localPosition
        self.isDrag = true
        self.isDragMjobj = obj
        self.checkTouchCount = Input.touchCount > 0
        self.view:ready_chu_mj(obj, false)
        self.view:ready_drag_mj(obj, true)
    end
end

function TableModule:on_update_dragbj_pos(transform)
    if self.checkTouchCount and Input.touchCount > 0 then
        transform.position = self.view:get_world_pos(Input.GetTouch(0).position, transform.position.z)
    else
        transform.position = self.view:get_world_pos(Input.mousePosition, transform.position.z)
    end
    local x = transform.localPosition.x
    local y = transform.localPosition.y
    local lowLimit = 0
    local def = TableUtil.get_int_def_prefs()
    local isNew = Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT", def) == 0 -- 0:新界面 1:老界面
    if (isNew) then
        lowLimit = -160
    end
    y = math.max(lowLimit, y)
    -- if(y < dragYLimit) then
    -- 	x = self.beginPressPos.x
    -- end
    transform.localPosition = Vector3.New(x, y, 0)
end

function TableModule:on_drag(obj, arg)
    -- print("on_drag", obj.name)
    if (obj and obj == self.isDragMjobj) then
        if not self.checkTouchCount then
            self:on_update_dragbj_pos(obj.transform)
        end
    elseif (obj and obj.name == "ButtonMic") then
        ModuleBase.on_drag_voice(self, obj, arg)
    end
end

-- 拖拽结束
function TableModule:on_end_drag(obj, arg)
    if obj == self.isDragMjobj then
        self.isDrag = false
        local y = obj.transform.localPosition.y
        y = math.max(0, y)

        local canChuPai = self.view:can_chu_mj()
        if y < dragYLimit or canChuPai == false then
            local x = self.beginPressPos.x
            y = 0
            obj.name = "inMJ_" .. self.view:get_mj_pai(obj)
            obj.transform.localPosition = self.beginPressPos --Manager.Vector3(x, self.beginPressPos.y, 0)
            --obj.transform:SetSiblingIndex(self.beginSiblingIndex)
            self.view:reset_drag_mj()
        else
            local pai = self.view:get_mj_pai(obj)
            if pai then
                self.view.feipai_pos = obj.transform.position
                self.view:chu_mj(obj, pai)
                self.model:request_chu_mj(pai, self.view.ReadyTing)

                if self.view.ReadyTing then
                    self.view.ReadyTing = false
                    self.view:show_not_ting(false)
                end
            end
        end
        self.isDragMjobj = nil
    end
end

function TableModule:on_press(obj, arg)
    if obj.name == "ButtonMic" then
        ModuleBase.press_voice(self, obj, arg)
    elseif string.sub(obj.name, 1, 10) == "readyChuMJ" and self.view.openFast then
        self.isDrag = false
        if (self.view:can_chu_mj()) then
            local pai = self.view:get_mj_pai(obj)
            if pai then
                self.view.feipai_pos = obj.transform.position
                self.view:chu_mj(obj, pai)
                self.model:request_chu_mj(pai, self.view.ReadyTing)
                if self.view.ReadyTing then
                    self.view.ReadyTing = false
                    self.view:show_not_ting(false)
                end
            end
        end
    end
end

function TableModule:on_click(obj, arg)
    local playerClickButtonSound = true

    if self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup then
        return
    end

    if obj == self.view.buttonSetting.gameObject then
        local intentData = {}
        intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_NTCP"
        intentData.canDissolveRoom = not self.view.inviteAndExit.activeSelf
        intentData.tableBackgroundSprite = self.view.tableBackgroundSprite
        intentData.tableBackgroundSprite2 = self.view.tableBackgroundSprite2
        intentData.tableBackgroundSprite3 = self.view.tableBackgroundSprite3
        Manager.ShowModule("henanmj", "roomsetting", intentData)

    elseif obj == self.view.buttonWarning.gameObject then
        --Manager.ShowModule("henanmj", "tablegps", self.view.tipText .. "," .. self.view.distanceText)
        local data = {};
        data.gameType = "majiang";
        data.seatHolderArray = self.view.seatHolderArray;
        data.tableCount = self.curTableData.totalSeat;
        data.isPlay = self.view:all_is_ready();
        data.isShowLocation = true;
        ModuleCache.ModuleManager.show_module("henanmj", "tablelocation", data);
    elseif obj == self.view.buttonJianFan.gameObject then
        --简繁体切换
        self.modelData.fan = not self.modelData.fan
        Manager.SetPlayerPrefsInt("NTCP_FAN", self.modelData.fan and 0 or 1)
        self.view:change_jian_fan()
    elseif obj == self.view.buttonLayout.gameObject then
        --界面切换
        self.view:changeSaveLayout()
        self.view:change_layout()
    elseif obj == self.view.buttonFanzhuan.gameObject then
        --牌翻转
        self.modelData.upright = not self.modelData.upright
        Manager.SetPlayerPrefsInt("NTCP_UPRIGHT", self.modelData.upright and 1 or 0)
        self.view.upright = self.modelData.upright
        self.view:fanzhuan()
    elseif obj == self.view.buttonLeftMenu then
        --打开左侧菜单
        ModuleCache.ComponentUtil.SafeSetActive(self.view.leftMenuObj, true)
    elseif obj == self.view.leftMenuEventMask then
        --关闭左侧菜单
        ModuleCache.ComponentUtil.SafeSetActive(self.view.leftMenuObj, false)
    elseif obj.name == "ButtonBack" then
        if self.view:check_is_exit_room() then
            self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom", 1)
        else
            self:dispatch_module_event("roomsetting", "Event_RoomSetting_DissolvedRoom", 1)
            self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)
        end
    elseif obj.name == "ButtonInvite" then
        self.lastClickInviteTime = Time.realtimeSinceStartup
        self:inviteWeChatFriend()
    elseif obj.name == "ButtonChat" then
        local intentData = {
            is_New_Sever = self:is_new_version(),
            config = Config,
            backgroundStyle = "BackgroundStyle_1"
        }
        Manager.ShowModule("henanmj", "tablechat", intentData)
        ---new add
    elseif obj.name == "Chupai_Button_Close" then
        --出牌页面关闭
        self.view:showChuPaiPanel(false)
    elseif obj.name == "ButtonChuPai" then
        --打开出牌页面
        self.view:showChuPaiPanel(true)
    elseif obj.name == "ButtonActivity" then
        --打开活动页面
        local object =
        {
            showRegionType = "table",
            showType="Manual",
        }
        ModuleCache.ModuleManager.show_public_module("activity", object)
    elseif obj.name == "ButtonMic" then
        --手牌点击
    elseif string.sub(obj.name, 1, 4) == "inMJ" then
        if (not self.view:is_gray(obj)) then
            playerClickButtonSound = false
            self.view:ready_chu_mj(obj)
        end
        --准备出牌点击 点击后出牌
    elseif string.sub(obj.name, 1, 10) == "readyChuMJ" then
        if (self.view:can_chu_mj() == true) then
            --能出牌
            if not self.view.openFast then
                if self.isDrag then
                    self:on_end_drag(self.isDragMjobj)
                    self.isDragMjobj = nil
                    self.isDrag = false
                else
                    local pai = self.view:get_mj_pai(obj)
                    if pai then
                        self.view.feipai_pos = obj.transform.position
                        self.view:chu_mj(obj, pai)
                        self.model:request_chu_mj(pai, self.view.ReadyTing)
                        if self.view.ReadyTing then
                            self.view.ReadyTing = false
                            self.view:show_not_ting(false)
                        end
                    end
                end
            end
        end
    elseif obj.name == "Button_Chi" then
        if #self.gameState.KeChi == 1 and #self.gameState.KeChi[1].ChiFa == 1 then
            self:guo_hu_action(function()
                self.model:request_chi_mj(self.gameState.KeChi[1].Pai, self.gameState.KeChi[1].ChiFa[1])
                self.view:hide_wait_action_select_card()
            end)
        else
            self.view:show_chigrid()
        end

    elseif obj.name == "Button_Peng" then
        self:guo_hu_action(function()
            if self.view.openGuoHu and self.view.wanfaName == "红中麻将" and #self.gameState.KeGang > 0 then
                -- 只有红中麻将才需要这个提示，各个红中麻将的提示又不一样
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common("您是否确认要放弃杠牌？\n放弃杠牌后本局游戏中不允许再杠此牌", function()
                    if (#self.gameState.KePeng == 1) then
                        if self.view.ReadyTing then
                            self.view.ReadyTing = false
                            self.view:show_not_ting(false)
                        end

                        self.model:request_peng_mj(self.gameState.KePeng[1])
                        self.view:hide_wait_action_select_card()
                    else
                        self.view:show_penggrid()
                    end
                end, nil)
            else
                if (#self.gameState.KePeng == 1) then
                    if self.view.ReadyTing then
                        self.view.ReadyTing = false
                        self.view:show_not_ting(false)
                    end

                    self.model:request_peng_mj(self.gameState.KePeng[1])
                    self.view:hide_wait_action_select_card()
                else
                    self.view:show_penggrid()
                end
            end
        end)

    elseif obj.name == "Button_Gang" then
        if #self.gameState.KeGang == 1 then
            self:guo_hu_action(function()
                self.model:request_gang_mj(self.gameState.KeGang[1])
                if self.view.ReadyTing then
                    self.view.ReadyTing = false
                    self.view:show_not_ting(false)
                end
                self.view:hide_wait_action_select_card()
                self.view:hide_ting_hu_grid()
            end)
        else
            self.view:hide_wait_action_select_card()
            self.view:show_ganggrid()
        end

    elseif obj.name == "Button_BuHua" then
        self:guo_hu_action(function()
            self.model:request_buhua_mj()
            self.view:hide_wait_action_select_card()
        end)

    elseif obj.name == "Button_Hu" then
        self.model:request_hu_mj()
        self.view:hide_wait_action_select_card()

    elseif obj.name == "Button_Guo" then
        if self.view.ReadyTing then
            self.view.ReadyTing = false
            self.view:show_not_ting(false)
        end
        self.model:request_guo_mj()
        self.view:hide_wait_action_select_card()

    elseif obj.name == "Button_Ting" then
        self:guo_hu_action(function()
            if self.view.TingPaiState == 1 then
                -- TingPaiState = 1 开局可听    TingPaiState = 2 牌局过程中的可以听
                self.model:request_kai_ju_ting_mj()
                self.view:hide_wait_action_select_card()
            elseif self.view.TingPaiState == 2 then
                self.view:show_not_ting(true)
                obj.gameObject:SetActive(false)
                self.view.ReadyTing = true
                self.view.showWaitAction = false
            end
        end)

    elseif (obj.name == "Button_KaiGang") then

    elseif (obj.name == "Button_HaiDi") then

    elseif (obj.name == "Button_Diao") then
        if (#self.gameState.KeDiaoDui == 1) then
            self:guo_hu_action(function()
                self.model:request_diao_dui(self.gameState.KeDiaoDui[1])
                self.view:hide_wait_action_select_card()
            end)
        else
            self.view:show_diaogrid()
        end

    elseif (string.sub(obj.name, 1, 3) == "Chi") then
        self:guo_hu_action(function()
            local array = string.split(obj.name, "_")
            self.model:request_chi_mj(tonumber(array[4]), tonumber(array[3]))
            self.view:hide_wait_action_select_card()
        end)

    elseif (string.sub(obj.name, 1, 4) == "Peng") then
        self:guo_hu_action(function()
            local array = string.split(obj.name, "_")
            self.model:request_peng_mj(tonumber(array[3]))
            self.view:hide_wait_action_select_card()
        end)

    elseif (string.sub(obj.name, 1, 4) == "Gang") then
        self:guo_hu_action(function()
            local array = string.split(obj.name, "_")
            self.model:request_gang_mj(tonumber(array[3]))
            self.view:hide_wait_action_select_card()
            self.view:hide_ting_hu_grid()
        end)

    elseif (string.sub(obj.name, 1, 4) == "Diao") then
        self:guo_hu_action(function()
            local array = string.split(obj.name, "_")
            self.model:request_diao_dui(tonumber(array[3]))
            self.view:hide_wait_action_select_card()
        end)

    elseif (obj.name == "BtnNoSelectCard") then
        self.view:refresh_wait_action()
        self.view:hide_select_card_childs()

    elseif (obj.name == "ButtonExit") then
        self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")

    elseif (obj.name == "ButtonBegin") then
        self.model:request_restart_mj()

    elseif (obj.name == "ButtonKick") then
        local playerId, playerName = self.view:get_kick_player_name(obj)
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("是否将%s踢出本房间？", playerName), function()
            self.model:request_kick_player(playerId)
        end, nil)

    elseif (obj.name == "Image") then
        self.view:look_player_info(obj)

    elseif (obj.name == "ButtonPiao") then
        if(TableUtil.is_ntcp()) then
            self.model:request_new_maizhuang(1)
        else
            self.model:request_maizhuang(1)
        end
        self.view:hide_select_hua()
        self.view:hide_wait_action_select_card()

    elseif (obj.name == "ButtonNoPiao") then
        if(TableUtil.is_ntcp()) then
            self.model:request_new_maizhuang(0)
        else
            self.model:request_maizhuang(0)
        end
        self.view:hide_select_hua()
        self.view:hide_wait_action_select_card()

    elseif (string.sub(obj.name, 1, 3) == "Zun") then
        local zun = tonumber(string.sub(obj.name, 4, 4))
        self.model:request_select_piao(zun)

    elseif (obj.name == "ButtonRule") then
        Manager.ShowModule("henanmj", "tablerule", self.view.gamerule)

    elseif "ImageBackground2" == obj.name then
        self:cancel_chu_mj()

    elseif "ImageBackground" == obj.name then
        self:cancel_chu_mj()

    elseif "NanTongQuXiao" == obj.name then
        self.model:request_guo_mj()

    elseif "NanTongJiaoPai" == obj.name then
        local pai = nil
        for i = 1, #self.gameState.Player do
            local localIndex = TableUtil.get_local_seat(i - 1, self.view.mySeat, TableManager.curTableData.totalSeat)
            if localIndex == 1 then
                pai = self.gameState.Player[i].KeJiaoPai[1]
                if(pai~=nil) then
                    self.model:request_jiaopai(pai)
                end
                break
            end
        end

    elseif "NanTongLiaoLong" == obj.name then
        local pai = nil
        for i = 1, #self.gameState.Player do
            local localIndex = TableUtil.get_local_seat(i - 1, self.view.mySeat, TableManager.curTableData.totalSeat)
            if localIndex == 1 then
                pai = self.gameState.Player[i].KeJiaoPai[1]
                if(pai~=nil) then
                    self.model:request_liaolong(pai)
                end
                break
            end
        end
    end

    if playerClickButtonSound then
        ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    end
end

-- 点击其他地方，取消出牌选中
function TableModule:cancel_chu_mj()
    local seatHolder = self.view.seatHolderArray[1]
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    for i, v in ipairs(rightChildren) do
        local str = string.sub(v.name, 1, 10)
        if str == "readyChuMJ" then
            Manager.SetLocalPos(v, v.transform.localPosition.x, 0, 0)
            local id = string.sub(v.name, 12, string.len(v.name))
            v.name = "inMJ_" .. id
        end
    end
    self.view:change_mj_color(-1) -- 不会有-1的牌，所以所有的牌会变回原色
end

function TableModule:guo_hu_action(callback)
    if (self.view.openGuoHu and self.view.canHu) then
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("放弃胡牌后需要再次摸牌之后才能胡牌，是否确认放弃胡牌？"), function()
            if (callback) then
                callback()
            end
        end, nil)
    elseif (callback) then
        callback()
    end
end

-- 实时刷新游戏状态
function TableModule:show_game_result(newGameState)
    if not newGameState then
        return
    end

    local showDissolve = ModuleCache.ModuleManager.module_is_active("henanmj", "dissolveroom")
    if newGameState.Result == 1 or newGameState.Result == 3 then
        local waitTime = 2
        if #newGameState.MaiMa > 0 then
            waitTime = #newGameState.MaiMa * 0.2 + 1.3
            self:subscibe_time_event(1, false, 0):OnComplete(function(t)
                self.view:Init_MaiMaPanel(newGameState)
            end)
        end

        self:play_hu_sound(newGameState)
        self.resultWait = false
        self.showOneResult = true
        self:subscibe_time_event(waitTime, false, 0):OnComplete(function(t)
            if #newGameState.MaiMa > 0 then
                self.view.MaiMaPanel:SetActive(false)
            end
            if not self.view.seatHolderArray[1].ready or TableManager.curTableData.isPlayBack then
                ModuleCache.ModuleManager.show_module("changpai", "onegameresult", newGameState)
            end
        end)
        -- 总结算不直接显示，又小结算点击后显示
    elseif ((showDissolve and newGameState.Result == 2) or (newGameState.Result == 2 and (not self.showOneResult ) )) then
        ModuleCache.ModuleManager.hide_module("henanmj", "dissolveroom")
        ModuleCache.ModuleManager.show_module("changpai", "totalgameresult")
        self.resultWait = false
    end

    --刷新游戏状态   是否显示  托管
    self:dispatch_module_event("table", "Event_Refresh_State", newGameState)
end


function TableModule:play_hu_sound(newGameState)
    local ziMoIndex = 0
    print_pbc_table(newGameState)
    for i = 1, #newGameState.Player do
        local state = newGameState.Player[i]
        --TODO 修复流局播放自摸的音效  state.HuPai 在胡的时候已经清空
        if (newGameState.DianPao == -1 and #state.HuFa ~= 0) then
            --没有点炮
            ziMoIndex = i
            print("有人自摸了")
        end
    end

    for i = 1, #newGameState.Player do
        local state = newGameState.Player[i]
        local localSeat = TableUtil.get_local_seat(i - 1, TableManager.curTableData.SeatID, TableManager.curTableData.totalSeat)
        local seatHolder = self.view.seatHolderArray[localSeat]
        if localSeat == 1 then
            if state.BeiShu <= 0 then
                self.view:play_voice("common/loss")
            else
                self.view:play_voice("common/win")
            end
        end
        if newGameState.DianPao ~= -1 then
            --有点炮
            if (state.BeiShu > 0) then
                self.view:play_action_sound(6, seatHolder)
                break
            end
        elseif i == ziMoIndex then
            --自摸
            if not self.view.tianhu_sound then
                -- 播放天胡的情况下，不播放胡音效
                self.view:play_action_sound(8, seatHolder)
            end
            break
        end
    end
end

--- 刷新单个玩家状态
function TableModule:refresh_seat_info(data)
    -- 代表有玩家离开
    if data.UserID == "0" then
        self.view:readyBtn_showCountDown(false)
    end

    ModuleBase.refresh_seat_info(self, data)
end

function TableModule:refresh_user_state(data)
    ModuleBase.refresh_user_state(self, data)
    for i = 1, #data.State do
        local seat = TableUtil.get_local_seat(i - 1, TableManager.curTableData.SeatID, TableManager.curTableData.totalSeat)
        local seatHolder = self.view.seatHolderArray[seat]
        if(TableUtil.is_ntcp() == false) then
            if TableManager.curTableData.SeatID == i - 1 then
                -- 自己弹出是否买庄
                if 1 == data.State[i].PiaoType then
                    ModuleCache.ComponentUtil.SafeSetActive(self.view.selectHua, true)
                else
                    ModuleCache.ComponentUtil.SafeSetActive(self.view.selectHua, false)
                end
            end
            if 1 == data.State[i].PiaoNum then
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.piaoZun, true)
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.piaoSprite.transform.parent.gameObject, true)
            else
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.piaoZun, false)
            end
        end
        --准备按钮显示后请求一次踢人倒计时
        if (not data.State[i].Ready and data.State[i].SeatID == self.view.mySeat and self.gameState == nil ) then
            self.model:request_get_kicked_timeout()
        end
    end

    self:dispatch_module_event("table", "Event_All_Player_Ready", self:all_player_ready_done(data))
end

function TableModule:all_player_ready_done(data)
    local allReady = true
    for i, v in ipairs(data.State) do
        if v.Ready == false then
            allReady = false
            break
        end
    end
    return allReady
end

function TableModule:on_show()
    ModuleBase.on_show(self)
end

-- 离开房间
function TableModule:exit_room(tip)
    TableManager:disconnect_login_server()
    TableManager:disconnect_game_server()
    ModuleCache.net.NetClientManager.disconnect_all_client()
    ModuleCache.ModuleManager.hide_module("henanmj", "dissolveroom")
    ModuleCache.ModuleManager.hide_public_module("netprompt")
    ModuleCache.ModuleManager.destroy_package("changpai")
    ModuleCache.ModuleManager.destroy_package("henanmj")
    --ModuleCache.ModuleManager.destroy_module("changpai", "table")
    ModuleCache.ModuleManager.show_module("henanmj", "hall")
    if (tip) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(tip)
    end
end

-- 服务器版本是否是新版本
function TableModule:is_new_version()
    return TableManager.curTableData.serverIsNew
end

function TableModule:on_destroy()
    ModuleBase.on_destroy(self)

    TableManager.chatMsgs = {}
    --UpdateBeat:Remove(self.on_update, self)
end

return TableModule