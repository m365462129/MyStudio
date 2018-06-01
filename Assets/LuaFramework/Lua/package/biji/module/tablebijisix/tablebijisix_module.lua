---
--- Created by tanqiang.
--- DateTime: 2018/5/8 15:48
---
local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_poker.base_table_module')
local TableBiJiSixModule = class('TableBiJiSixModule', ModuleBase)
local ModuleCache = ModuleCache

function TableBiJiSixModule:initialize(...)
    ModuleBase.initialize(self, "tablebijisix_view", "tablebijisix_model", ...)
    self.packageName = "biji"
    self.moduleName = "tablebijisix"
    self.myHandPokers = (require("package.biji.module.tablebijisix.handpokers")):new(self)
    self.logic = require('package.biji.module.tablebijisix.tablebijisix_logic'):new(self)
    self.config = require('package.biji.config')
end

function TableBiJiSixModule:on_model_event_bind()
    ModuleBase.on_model_event_bind(self)

    self:subscibe_model_event("Event_Table_Enter_Room", function(eventHead, eventData)
        self.logic:on_table_gameinfo_notify(eventData)
    end )

    --重新连接
    self:subscibe_model_event("Event_Table_Reconnect", function(eventHead, eventData)
        self.myHandPokers:setOringinalServerPokers(eventData.pokers)
        self.logic:reconnect(eventData);
    end )

    self:subscibe_model_event("Event_Get_Poker", function(eventHead, eventData)
        if self.result_coroutine ~= nil then self:stop_lua_coroutine(self.result_coroutine) end
        self.view:closeResultTable()
        self.logic:refresh_round_info(eventData.curRoundNum);
        self.logic:refresh_seat_game_count();
        self.view:showSortBtn(self.view.SORT_POKER_TYPE.COLOR)
        self.myHandPokers:setOringinalServerPokers(eventData.Pokers)
        self.myHandPokers:setPokersInHand(eventData.Pokers, true);
        self.logic:show_other_players_pokers();
        self.logic:clear_ready_status()
        self.myHandPokers:clearMatchingTable();
        --self.logic:hide_kick_button();
        self.view:showEnterMatchBtn(false)
        self.view:showReadyBtn(false)

        if not self.modelData.curTableData.roomInfo.ruleTable.offlineAutoReady then
            self:show_match_poker_time(60);
        end
    end )

    --被踢出房间
    self:subscibe_model_event("Event_Table_Kick_Player_Notify", function(eventHead, eventData)
        if (eventData.err_no and eventData.err_no == "0") then
            self:onLeaveRoomSuccess()
            if self.modelData.roleData.RoomType == 2 then
                --牌友圈快速组局
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已被踢出房间！")
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已被房主踢出房间！")
            end
        end
    end )


    self:subscibe_model_event("Event_Table_Complete_Match_Rsp", function(eventHead, eventData)
        self.myHandPokers:checkedSequence(eventData.err_no, eventData.pokers);
    end )

    --小结算
    self:subscibe_model_event("Event_Table_Get_Result", function(eventHead, eventData)
        local onFinishPlayStartCompareAnim = function()
            self.result_coroutine =  self:start_lua_coroutine(function () self.logic:show_match_poker_result(eventData); end)
        end
        local seatInfo = self:getSeatInfoByPlayerId( tonumber(self.modelData.roleData.userID), self.modelData.curTableData.roomInfo.seatInfoList);
        self.view:playStartCompareAnim(seatInfo, onFinishPlayStartCompareAnim)
        self.isOver = self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount
        --self.logic:clear_ready_status();
    end )

    -- 大结算
    self:subscibe_model_event("Event_Table_LastSettleAccounts_Notify", function(eventHead, eventData)
        self:onLastSettleAccounts_Notify(eventData)
    end )

    --确定选牌
    self:subscibe_model_event("Event_Table_Comfirm", function(eventHead, eventData)
        self.logic:refresh_player_confirm_status(eventData);
    end )


    -- 牌友圈 快速组局 踢人倒计时
    self:subscibe_model_event("Event_Table_KickPlayerExpire", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        print("------------------收到踢人倒计时：", eventData.expire)
        -- self.modelData.roleData.RoomType == 0 --0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
        -- if(self.modelData.roleData.RoomType == 3) then
        if self.kickedTimeId then
            self.CSmartTimer:Kill(self.kickedTimeId)
        end

        self.kickedTimeId = self:subscibe_time_event(eventData.expire, false, 1):OnUpdate( function(t)
            t = t.surplusTimeRound
            self.view.readyCountDown.text = "(" .. t .. ")"
        end ):OnComplete( function(t)

        end ).id

    end )

    --超时托管
    self:subscibe_model_event("Event_Table_ExpiresInfo_Notify", function(eventHead, eventData)
        self:show_system_trusteeship(eventData)
    end )
end

function TableBiJiSixModule:on_module_event_bind()
    ModuleBase.on_module_event_bind(self)
end

--踢人回包
function TableBiJiSixModule:on_kick_player_rsp(eventData)
    if(not eventData.err_no or eventData.err_no == '0')then

    end
end

--踢人通知
function TableBiJiSixModule:on_kick_player_notify(eventData)
    self.view.ready_count_down_obj:SetActive(false)
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local playerId = eventData.player_id
    if(playerId == mySeatInfo.playerId)then
        if(self.logic.isGoldTable)then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("由于长时间未准备，系统将您移出房间")
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您被房主踢出房间")
        end
        self:onLeaveRoomSuccess()
    else
        self:on_leave_room_notify({player_id=playerId})
    end
end

--进入房间响应
function TableBiJiSixModule:on_enter_room_rsp(eventData)
    ModuleBase.on_enter_room_rsp(self, eventData)
    self.logic:on_enter_room_rsp(eventData)
end

--进入房间通知
function TableBiJiSixModule:on_enter_notify(eventData)
    --ModuleBase.on_enter_notify(self, eventData)
    self.logic:on_enter_notify(eventData)
end

--准备响应
function TableBiJiSixModule:on_ready_rsp(eventData)
    self.logic:get_ready_rsp(eventData)
end

function TableBiJiSixModule:on_click_ready_btn()
    if self.isOver then
        if self.readyTimeId then
            self.CSmartTimer:Kill(self.readyTimeId)
            self.readyTimeId = nil
        end
        if self.antoShowOverId then
            self.CSmartTimer:Kill(self.antoShowOverId)
            self.antoShowOverId = nil
        end
        self:show_result_info()
        return
    end
    self.model:request_ready(tonumber(self.modelData.roleData.userID))
end

--准备通知
function TableBiJiSixModule:on_ready_notify(eventData)
    self.logic:refresh_ready_status(eventData)
end


--开始响应
function TableBiJiSixModule:on_start_rsp(eventData)
    ModuleBase.on_start_rsp(self, eventData)
end

--开始通知
function TableBiJiSixModule:on_start_notify(eventData)
    ModuleBase.on_start_notify(self, eventData)
    self.logic:on_start_notify(eventData)
end

--重写退出房间事件 BIJI退出协议不一样
function TableBiJiSixModule:on_click_leave_btn()
    self.logic:on_click_leave_btn()
end

--离开房间通知
function TableBiJiSixModule:on_leave_room_notify(eventData)
    print_table(eventData);
    local playerId = eventData.player_id
    self:removeSeatInfoFromChatCurTableData(playerId)
    local seatInfo = self:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
    if(not seatInfo)then
        return
    end
    seatInfo.playerId = 0
    seatInfo.playerInfo = nil
    seatInfo.isSeated = false
    self.view:refreshSeatPlayerInfo(seatInfo)
    self.view:refreshSeatOfflineState(seatInfo)
    self.view:refreshSeatState(seatInfo)

    if self.checkLocation then
        self:checkLocation();
    end
end

function TableBiJiSixModule:on_pre_share_room_num()
    local roomInfo = self.modelData.curTableData.roomInfo
    local curPlayerCount = #self:getSeatedSeatList(roomInfo.seatInfoList)
    self:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, false, curPlayerCount)
end

--大结算
function TableBiJiSixModule:onLastSettleAccounts_Notify(data)
    TableManagerPoker:disconnect_game_server()
    local isShowDisUI = ModuleCache.ModuleManager.module_is_active("henanmj", "dissolveroom")
    if (isShowDisUI) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
    end
    local isShowSetUI = ModuleCache.ModuleManager.module_is_active("henanmj", "roomsetting")
    if (isShowSetUI) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "roomsetting")
    end
    local isShowChatUI = ModuleCache.ModuleManager.module_is_active("henanmj", "tablechat")
    if (isShowChatUI) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "tablechat")
    end
    local isShowPlayerInfo = ModuleCache.ModuleManager.module_is_active("henanmj", "playerinfo")
    if (isShowPlayerInfo) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "playerinfo")
    end
    local resultList = { }
    local sTime = ""
    local eTime = ""
    for i = 1, #data.LastSettleAccounts do
        local seatInfo = self:getSeatInfoByPlayerId(data.LastSettleAccounts[i].userId, self.modelData.curTableData.roomInfo.seatInfoList)
        local result = { }
        result.totalScore = data.LastSettleAccounts[i].totalScore
        result.xipaiCount = data.LastSettleAccounts[i].xipaiCount
        result.paiWinCount = data.LastSettleAccounts[i].paiWinCount
        result.tongguanCount = data.LastSettleAccounts[i].tongguanCount
        result.playerId = data.LastSettleAccounts[i].userId
        if seatInfo ~= nil then
            result.isRoomCreator = seatInfo.isCreator
            result.playerInfo = seatInfo.playerInfo
            if (seatInfo.isCreator) then
                print("is creator ------------------------------")
                sTime = data.LastSettleAccounts[i].startTime
                eTime = data.LastSettleAccounts[i].endTime
            end
        end
        table.insert(resultList, result)
    end
    self.modelData.curTableData.roomInfo.isRoomEnd = true
    self.modelData.curTableData.roomInfo.roomResultList = resultList
    self.modelData.curTableData.roomInfo.startTime = sTime
    self.modelData.curTableData.roomInfo.endTime = eTime
    self.dissolverId = data.free_sponsor;
    self.isOver = self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount
    if not self.isOver then
        self:show_result_info()
    else
        if self.modelData.curTableData.roomInfo.ruleTable.offlineAutoReady then
            self.antoShowOverId = self:subscibe_time_event(25 , false, 0):OnComplete(function(t)
                self:show_result_info()
            end).id
            self:show_ready_btn_time(25)
        end
    end
end

--显示最终结果
function TableBiJiSixModule:show_result_info()
    ModuleCache.ModuleManager.show_module("biji", "tableresult",
            {
                gameName = self.modelData.curTableData.roomInfo.wanfaName,
                dissolverId = self.dissolverId,
                resultList = self.modelData.curTableData.roomInfo.roomResultList,
                roomInfo = {
                    roomNum = self.modelData.curTableData.roomInfo.roomNum,
                    curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum,
                    totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount,
                    startTime = self.modelData.curTableData.roomInfo.startTime,
                    endTime = self.modelData.curTableData.roomInfo.endTime
                }
    }, "biji")
end

--系统托管
function TableBiJiSixModule:show_system_trusteeship(data)
    local timeConfig  = tonumber(data.expire)
    if data.state == 4 then --托管准备
        self:show_ready_btn_time(timeConfig)
    elseif data.state == 5 then --托管配牌
        self:show_match_poker_time(timeConfig)
    end
end

--显示配牌时间
function TableBiJiSixModule:show_match_poker_time(residueTime)
    if self.matchTimeId then
        self.CSmartTimer:Kill(self.matchTimeId)
        self.matchTimeId = nil
    end
    self.matchTimeId = self:subscibe_time_event(residueTime, false, 1):OnUpdate(function(t)
        t = t.surplusTimeRound
        self.view.matchTimeText.text = t
    end):OnComplete( function(t)   end).id
    self.view:showMatchPokerTimeObj(true)
end

--显示准备时间按钮
function TableBiJiSixModule:show_ready_btn_time(residueTime)
    if self.readyTimeId then
        self.CSmartTimer:Kill(self.readyTimeId)
        self.readyTimeId = nil
    end
    self.readyTimeId = self:subscibe_time_event(residueTime , false, 1):OnUpdate(function(t)
        t = t.surplusTimeRound
        self.view.readyCountDown.text ="(".. t..")";
    end):OnComplete( function(t)
        if not self.modelData.curTableData.roomInfo.ruleTable.offlineAutoReady and self.isOver then
            self:show_result_info()
        end
    end ).id
end

function TableBiJiSixModule:on_press_up(obj, arg)
    ModuleBase.on_press_up(self, obj, arg)
    self.logic:on_press_up(obj, arg)
end

function TableBiJiSixModule:on_drag(obj, arg)
    ModuleBase.on_drag(self, obj, arg)
    self.logic:on_drag(obj, arg)
end

function TableBiJiSixModule:on_press(obj, arg)
    ModuleBase.on_press(self, obj, arg)
    self.logic:on_press(obj, arg)
end

function TableBiJiSixModule:on_click(obj, arg)
    ModuleBase.on_click(self, obj, arg)
    self.logic:on_click(obj, arg)
end

function TableBiJiSixModule:playBgm()
    local bgMusic = "bg"
    if((not self.SoundManager.audioMusic.clip) or self.SoundManager.audioMusic.clip.name ~= bgMusic) then
        ModuleCache.SoundManager.play_music("biji", "biji/sound/bijisound/" .. bgMusic .. ".bytes", bgMusic, true)
    end
end

return TableBiJiSixModule