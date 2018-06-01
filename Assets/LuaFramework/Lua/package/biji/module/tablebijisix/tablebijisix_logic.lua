---
--- Created by tanqiang.
--- DateTime: 2018/5/8 16:20
---
local class = require("lib.middleclass")
local TableBiJiSixLogic = class('TableBiJiSixLogic')
local list = require("list")
local ModuleCache = ModuleCache
local FunctionManager = ModuleCache.FunctionManager
local Application = UnityEngine.Application
local CSmartTimer = CSmartTimer

function TableBiJiSixLogic:initialize(module)
    self.module = module
    self.modelData = module.modelData
    self.view = module.view
    self.model = module.model
    self.myHandPokers = module.myHandPokers

    self.waitPlayingFinishFunsQueue = list:new()
    self.isPlayingAnimCount = 0
    self.modelData.curTableData = { }
    self.modelData.curTableData.roomInfo = { }
    self.modelData.curTableData.roomInfo.mySeatInfo = { }
    self.modelData.curTableData.roomInfo.seatInfoList = { }
    for i = 1, self.view:getTotalSeatCount() do
        local seatInfo = { };
        seatInfo.seatIndex = i;
        table.insert(self.modelData.curTableData.roomInfo.seatInfoList, seatInfo);
    end
end


function TableBiJiSixLogic:on_press_up(obj, arg)
    if (obj.name == "ButtonMic") then return end
    if (obj.name == "PressLook") then
        self:unlook_matchOver_poker(obj)
        return
    end
    self.myHandPokers.lastSelectPoker = nil
    self.myHandPokers:onClickPokersOnMatch(obj);
end

function TableBiJiSixLogic:on_drag(obj, arg)
    if (obj.name == "ButtonMic") then return end
    self.myHandPokers:cancel_all_change_poker()
    local count = arg.hovered.Count
    for i = 0, count - 1 do
        local go = arg.hovered[i]
        if (go and go.name == 'poker' and go.transform.parent and go.transform.parent.parent and go.transform.parent.parent.gameObject == self.view.pokers) then
            if (go ~= self.myHandPokers.lastSelectPoker) then
                self.myHandPokers.lastSelectPoker = go
                self.myHandPokers:selectPoker(go)
            end
        end
    end
end

function TableBiJiSixLogic:on_press(obj, arg)
    if (obj.name == "PressLook") then
        self:look_matchOver_poker(obj)
        return
    end
    if (obj.transform.parent and obj.transform.parent.parent and obj.transform.parent.parent.gameObject == self.view.pokers) then
        self.myHandPokers.lastSelectPoker = obj
        self.myHandPokers:selectPoker(obj)
    end
end

function TableBiJiSixLogic:on_click(obj, arg)
    if obj == self.view.buttonRule.gameObject then
        self:on_click_rule_info(obj, arg)
    elseif obj == self.view.btnGameSetting.gameObject then
        self.view.leftRoot.gameObject:SetActive(false)
        self.module:on_click_setting_btn(obj, arg)
    elseif obj == self.view.btnGameExit.gameObject then
        self.view.leftRoot.gameObject:SetActive(false)
        self:on_click_leave_btn()
    elseif obj == self.view.btnGameRule.gameObject then
        self.view.leftRoot.gameObject:SetActive(false)
        self:on_click_game_rule()
    elseif obj == self.view.buttonResult.gameObject then
        self:on_click_result(obj, arg)
    elseif obj == self.view.buttonPair or obj == self.view.buttonStraight or obj == self.view.buttonFlush
            or obj == self.view.buttonStraightFlush or obj == self.view.buttonThreeOfAKind then
        self:on_click_pokers_tips(obj, arg)
    elseif obj == self.view.buttonSurrender.gameObject then
        self:on_click_surrender()
    elseif obj == self.view.buttonSubmit.gameObject then
        self:on_click_submit()
    elseif obj.name == "ImageNoPokers" and string.match(obj.transform.parent.name, "match_") then
        self:on_click_match(obj)
    elseif obj.name == "CloseMatchBtn" and string.match(obj.transform.parent.name, "match_") then
        self:on_click_cancel_match(obj)
    elseif obj == self.view.btnOrderBySize.gameObject then
        self:on_click_sort_pokers(self.view.SORT_POKER_TYPE.SIZE)
    elseif obj == self.view.btnOrderByColor.gameObject then
        self:on_click_sort_pokers(self.view.SORT_POKER_TYPE.COLOR)
    elseif obj == self.view.buttonResetAll.gameObject then
        self:on_click_match_resetall()
    elseif obj.name == "ButtonKick" then
        self:on_click_kick_player(obj)
    elseif obj ==  self.view.winDealPanelBtn then
        self:on_click_cancel_select()
    end
end


function TableBiJiSixLogic:on_click_kick_player(obj)
    if obj == nil then return end
    local index = self.view.kickBtns[obj]
    if index == nil then return end
    local seatInfo = self.module:getSeatInfoBySeatIndex(index, self.modelData.curTableData.roomInfo.seatInfoList)
    if seatInfo ~= nil and seatInfo.playerId ~= nil and seatInfo.playerId ~= 0 then
        self.model:request_kick_player(seatInfo.playerId)
    end
end

--进入房间通知游戏基本信息
function TableBiJiSixLogic:on_table_gameinfo_notify(eventData)
    if(eventData.err_no and eventData.err_no ~= '0')then
        return
    end
    self:initTableData(eventData)
    local roomInfo = self.modelData.curTableData.roomInfo
    self:init_seat_info(eventData.seatInfo)
    self.module:on_enter_room_event(roomInfo)
    self:show_base_roominfo(roomInfo)
    local voicePath = Application.persistentDataPath .. "/voice"
    if (eventData.roomInfo.roomNum ~= eventData.roomInfo.roomNum) then
        ModuleCache.FileUtility.DirectoryDelete(voicePath, true)
        ModuleCache.FileUtility.DirectoryCreate(voicePath)
    end
end

function TableBiJiSixLogic:initTableData(data)
    local roomInfo = {
        roomNum = data.roomInfo.roomNum,
        roomHostID = data.roomInfo.roomHostID,
        curRoundNum = data.roomInfo.curRoundNum,
        totalRoundCount = data.roomInfo.totalRoundNum,
        roomStatus = data.roomInfo.roomStatus,
        roomId = data.roomInfo.roomId,
    }
    self.modelData.curTableData.roomInfo.roomNum = roomInfo.roomNum;
    self.modelData.curTableData.roomInfo.roomHostID = roomInfo.roomHostID;
    self.modelData.curTableData.roomInfo.curRoundNum = roomInfo.curRoundNum;
    self.modelData.curTableData.roomInfo.totalRoundCount = roomInfo.totalRoundCount;
    self.modelData.curTableData.roomInfo.roomStatus = roomInfo.roomStatus;
    self.modelData.curTableData.roomInfo.timeOffset =(data.roomInfo.serverNow or os.time()) - os.time()
    roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
    self.modelData.curTableData.roomInfo.rule = roomInfo.rule;
    roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule);
    self.modelData.curTableData.roomInfo.roomId = roomInfo.roomId;
    self.pokersNum = roomInfo.ruleTable.pokersNum;
    if (roomInfo.ruleTable.pokersNum == nil) then
        self.pokersNum = 9;
    end
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    self.modelData.curTableData.roomInfo.ruleDesc = ruleDesc
    self.modelData.curTableData.roomInfo.wanfaName = wanfaName
    self.modelData.curTableData.roomInfo.ruleTable = roomInfo.ruleTable;

    for i = 1, #data.seatInfo do
        if (tonumber(self.modelData.roleData.userID) == tonumber(data.seatInfo[i].userID)) then
            self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex = data.seatInfo[i].seatNum;
        end
    end
end

--通知进入房间
function TableBiJiSixLogic:on_enter_room_rsp(eventData)

end

--开始游戏 清理本次准备状态
function TableBiJiSixLogic:clear_ready_status()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (seatInfo.playerId ~= nil and seatInfo.playerId ~= 0) then
            if self.myHandPokers.isJoinAfterStart == false then
                seatInfo.isReady = false;
                -- TODO XLQ ： 快速组局 中途进入的玩家点击准备后，收到第一局小结算时不需要重新准备
            end
            self.view:refreshSeat(seatInfo);
        end
    end
end

--房间基本信息
function TableBiJiSixLogic:show_base_roominfo(roomInfo)
    self.view:setRoomInfo(roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount,  roomInfo.wanfaName)
    self.view:showSurrenderBtn(roomInfo.ruleTable.allowSurrender)
end

--刷新房间游戏次数
function TableBiJiSixLogic:refresh_round_info(curRoundNum)
    self.modelData.curTableData.roomInfo.curRoundNum = curRoundNum;
    self:show_base_roominfo(self.modelData.curTableData.roomInfo);
end

--刷新玩家游戏次数
function TableBiJiSixLogic:refresh_seat_game_count()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
        if (seatInfo.playerId and seatInfo.playerId ~= 0) then
            seatInfo.gameCount =(seatInfo.gameCount or 0) + 1
        end
    end
end

--隐藏 提人按钮
function TableBiJiSixLogic:hide_kick_button()
    if(tonumber(self.modelData.roleData.userID) ~= self.modelData.curTableData.roomInfo.roomHostID) then
        return;
    end
    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
    for key, v in ipairs(seatsInfo) do
        if(v.playerId and v.playerId ~= 0) then
            v.canBeKicked = false;
            self.view:refreshSeat(v);
        end
    end
end

--显示其他玩家的牌
function TableBiJiSixLogic:show_other_players_pokers()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatInfoList do
        if (seatInfoList[i].localSeatIndex and seatInfoList[i].localSeatIndex ~= 1 and seatInfoList[i].playerId ~= 0 and seatInfoList[i].playerId ~= nil) then
            self.view:showOtherPlayersPokers(seatInfoList[i].localSeatIndex, self.pokersNum);
        end
    end
end

function TableBiJiSixLogic:_getSeatInfo(seatData)
    local seatInfo = { };
    seatInfo.seatIndex = seatData.seatNum
    seatInfo.playerId = tonumber(seatData.userID)
    seatInfo.isCreator = tonumber(seatData.userID) == tonumber(self.modelData.curTableData.roomInfo.roomHostID)
    seatInfo.isReady = seatData.readyStatus == 1
    seatInfo.isTemporaryLeave = seatData.isTemporaryLeave;
    seatInfo.isOffline = seatData.isOffline;
    seatInfo.gameCount = seatData.gameCount;
    seatInfo.hasConfirmed = seatData.isConfirmed;
    seatInfo.isSeated = seatInfo.playerId ~= 0
    seatInfo.canBeKicked = false;
    if(tonumber(seatInfo.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.roomHostID) and seatInfo.gameCount == 0) then
        seatInfo.canBeKicked = true
    end
    seatInfo.curScore = seatData.curScore
    seatInfo.roomInfo = seatData.roomInfo
    local mySeatIndex = self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex
    seatInfo.localSeatIndex = self.module:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, mySeatIndex, #self.modelData.curTableData.roomInfo.seatInfoList)
    if (tonumber(seatData.userID) == tonumber(self.modelData.roleData.userID)) then
        self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo;
    end
    return seatInfo
end


function TableBiJiSixLogic:init_seat_info(seatData)
    if seatData == nil then return end
    self.view:resetSeatHolderArray(seatCount)
    for i = 1, #seatData do
        local seatInfo = self:_getSeatInfo(seatData[i])
        self.modelData.curTableData.roomInfo.seatInfoList[seatInfo.seatIndex] = seatInfo;
        self.view:refreshSeat(seatInfo)
    end
    --首轮进来做自动准备
    if (self.modelData.curTableData.roomInfo.curRoundNum == 0) then
        self.model:request_ready(tonumber(self.modelData.roleData.userID))
    end
end

--进入房间
function TableBiJiSixLogic:on_enter_notify(data)
    self.tablePlayerNum = data.playercnt
    ---- 会收到其他玩家的中途进入包，其他玩家在没准备的情况下中途进入也会影响自己的按钮
    --local my_seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[self.modelData.roleData.myRoomSeatInfo.SeatID];
    --if self.modelData.roleData.userID == data.seatInfo.userID or(my_seatInfo and not my_seatInfo.isReady and self.modelData.curTableData.roomInfo.curRoundNum == 0) then
    --    self:ResetReadyBtn()
    --end

    local seatInfo = self:_getSeatInfo(data.seatInfo)
    self.modelData.curTableData.roomInfo.seatInfoList[seatInfo.seatIndex] = seatInfo;
    self.view:refreshSeat(seatInfo)
end

function TableBiJiSixLogic:reset_ready_btn(data)
        local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
        for key, v in ipairs(seatsInfo) do
            if(tonumber(v.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.roomHostID) and v.gameCount == 0) then
                v.canBeKicked = true;
                self.view:refreshSeat(v);
            end
        end
end

--刷新当前分数
function TableBiJiSixLogic:refresh_curScore(data)
    for key, v in ipairs(data.players) do
        self.modelData.curTableData.roomInfo.seatInfoList[v.seatNum].curScore = v.curScore;
        self.view:refreshSeat(self.modelData.curTableData.roomInfo.seatInfoList[v.seatNum]);
    end
end


--规则信息按钮
function TableBiJiSixLogic:on_click_rule_info(obj, arg)
    ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
end

--战绩按钮
function TableBiJiSixLogic:on_click_result(obj, arg)
    local roomInfo = { }
    roomInfo.creatorId = self.modelData.curTableData.roomInfo.roomHostID
    roomInfo.id = self.modelData.curTableData.roomInfo.roomId
    roomInfo.curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum
    roomInfo.totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount
    roomInfo.gameType = self.modelData.curTableData.roomInfo.ruleTable.gameType
    ModuleCache.ModuleManager.show_module("biji", "innerroomdetail", roomInfo)
end

--离开房间按钮
function TableBiJiSixLogic:on_click_leave_btn()
    if self.modelData.curTableData.roomInfo.curRoundNum == 0 then
        if not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator then
            self.model:request_exit_room(tonumber(self.modelData.roleData.userID))
        else
            self.model:request_dissolve_room(true)
        end
    else
        self.model:request_dissolve_room(true)
    end

end

--开始游戏
function TableBiJiSixLogic:on_start_notify()
    self.view:showStartSeat(self.modelData.curTableData.roomInfo.seatInfoList)
end

--点击对子 同花等按钮 提示选牌事件
function TableBiJiSixLogic:on_click_pokers_tips(obj, arg)
    self.myHandPokers:showSelectPokersTips(obj)
end

--投降
function TableBiJiSixLogic:on_click_surrender()
    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_confirm_cancel("<size=30>确定投降吗？</size>\n\n<size=22>Tips:投降则每道牌都判为输，但不算通关和喜牌的减分</size>", function()
        self.model:request_surrender(tonumber(self.modelData.roleData.userID));
    end, nil)
end

--排序类型按钮
function TableBiJiSixLogic:on_click_sort_pokers(sortType)
    self.view:showSortBtn(sortType)
    self.myHandPokers:setPokersInHand(self.myHandPokers.handPokers, false)
end

function TableBiJiSixLogic:on_click_match(obj)
    local btnName = string.split(obj.transform.parent.name, "_")
    if btnName[2] == nil then return end
    self.myHandPokers:setMatchByIndex(tonumber(btnName[2]))
end

--游戏玩法事件
function TableBiJiSixLogic:on_click_game_rule()
    ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
end

--取消某道牌
function TableBiJiSixLogic:on_click_cancel_match(obj)
    local btnName = string.split(obj.transform.parent.name, "_")
    if btnName[2] == nil then return end
    self.myHandPokers:cancelMatchByIndex(tonumber(btnName[2]))
end

--取消掉所有的牌
function TableBiJiSixLogic:on_click_match_resetall()
    self.myHandPokers:resetMatchAll()
end

--确定配牌
function TableBiJiSixLogic:on_click_submit()
    local pokers = self.myHandPokers:checkIsCanSubmitPokers()
    if pokers == nil then return end
    self.model:request_submit(pokers, self.modelData.roleData.userID);
end

--收到玩家确定配牌的消息
function TableBiJiSixLogic:refresh_player_confirm_status(data)
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (tonumber(seatInfo.playerId) == tonumber(data.userID)) then
            seatInfo.hasConfirmed = true
            if (tonumber(seatInfo.playerId) == tonumber(self.modelData.roleData.userID)) then
                self.view:showDealTable(false)
                self.view:setSelfImageActive(true)
                self:setMatchOverPokersData()
            end
            self.view:setMatchingActive(seatInfo.localSeatIndex, false); --TODO
            self.isPlayingAnimCount = self.isPlayingAnimCount + 1;
            local isAllConfirm = self:is_all_confirmed()
            self.view:playConfirmPokerAnimStep1(seatInfo.localSeatIndex, self.pokersNum, function(...)
                self.view:playComfirmPokerAnimStep2(seatInfo.localSeatIndex, function(...)
                    self.isPlayingAnimCount = self.isPlayingAnimCount - 1;
                    if (self.isPlayingAnimCount == 0) then
                        local func = self.waitPlayingFinishFunsQueue:shift()
                        while func do
                            func()
                            func = self.waitPlayingFinishFunsQueue:shift()
                        end
                    end
                end , isAllConfirm)
            end , isAllConfirm)
        end
    end
end

--拼接本地配牌数据 主要是确定配牌后查看的数据
function TableBiJiSixLogic:setMatchOverPokersData()
    self.view.pressLookTips:SetActive(true)
    self.isShowResulting =  false
    self.modelData.matchOverPokersData = {}
    self.modelData.matchOverPokersData.pokers = {}
    for _, v in ipairs(self.modelData.matchPokers) do
        if v == nil or #v ~= 3 then break end
        for _, pokerData in ipairs(v) do
            self.modelData.matchOverPokersData.pokers[#self.modelData.matchOverPokersData.pokers + 1]  = {Color = pokerData.Color, Number = pokerData.Number}
        end
    end
    if #self.modelData.matchOverPokersData.pokers == self.myHandPokers.pokersNum then return end
    self.modelData.matchOverPokersData.pokers = self.myHandPokers.oringinalServerPokers
end


--开始显示配牌结果
function TableBiJiSixLogic:show_match_poker_result(data)
    self.isShowResulting = true
    local roomData = { };
    roomData.roomInfo = { };
    roomData.roomInfo.roomHostID = self.modelData.curTableData.roomInfo.roomHostID
    roomData.roomInfo.roomStatus = 0;
    self.myHandPokers:clearAllMatchingData()
    if (tonumber(data.err_no) == 0) then
        self.view:showResultTable(true);
    end
    --TODO
    --if (tonumber(data.err_no) == 1) then
    --    self:SetReadyBtnType(roomData);
    --    self.myHandPokers.isJoinAfterStart = true;
    --end
    local players = data.players;
    self.resultData = players;
    self.isComparing = true;

    --local isAllSurrender = self:is_all_surrender(players);

    local playerDatas = {}
    local waitTime = 0.2
    for matchIndex = 1, 3 do
        local tempIndex = {}
        for _, v in ipairs(players) do
            --投降给个分数为-999 应该没有比这更大的了吧
            tempIndex[#tempIndex + 1] = { id = tonumber(v.userID), socre = not v.isSurrender and  v.scoreOfPokers[matchIndex]  or -999, resultData = v}
        end
        table.sort(tempIndex, function (a, b) return a.socre < b.socre end)
        coroutine.wait(matchIndex == 1 and 0 or 0.5)
        for i = 1, #tempIndex do
            coroutine.wait(tempIndex[i].resultData.isSurrender and 0 or waitTime)
            local seatInfo = self.module:getSeatInfoByPlayerId(tempIndex[i].id, self.modelData.curTableData.roomInfo.seatInfoList)
            self.view:showOncePlayersResult(seatInfo, matchIndex, tempIndex[i].resultData)
            if playerDatas[tempIndex[i].id] == nil then
                playerDatas[tempIndex[i].id] = { seatData =  seatInfo, resultData = tempIndex[i].resultData}
            end
        end
    end
    coroutine.wait(1)
    self:refresh_curScore(data);
    for _, v in pairs(playerDatas) do
        self.view:showLastResult(v.seatData, v.resultData)
    end
    self.view:showReadyBtn(true)
    if not self.modelData.curTableData.roomInfo.ruleTable.offlineAutoReady then
        self.module:show_ready_btn_time(10);
    end
end


--是否全部投降
function TableBiJiSixLogic:is_all_surrender(players)
    local isAllSurrender = true;
    for key, v in ipairs(players) do
        if (not v.isSurrender) then
            isAllSurrender = false;
            return isAllSurrender;
        end
    end
    return isAllSurrender;
end

--是否全部确定
function TableBiJiSixLogic:is_all_confirmed()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (seatInfo.playerId and seatInfo.playerId ~= 0 and seatInfo.gameCount > 0 and not seatInfo.hasConfirmed) then
            return false
        end
    end
    return true
end

function TableBiJiSixLogic:get_ready_rsp(data)
    if (data.err_no == "0") then
        self.readyRsp = true;
        --self.view:SetReadyCancel(true);
        self:refresh_self_ready_status(true);
        self.view:closeResultTable();
    else
        self.readyRsp = false;
    end
end

--自己的准备状态
function TableBiJiSixLogic:refresh_self_ready_status(isReady)
    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatsInfo do
        if (seatsInfo[i].playerId ~= nil) then
            if (seatsInfo[i].playerId == self.modelData.roleData.userID) then
                seatsInfo[i].isReady = isReady;
                self.view:refreshSeat(seatsInfo[i]);
            end
        end
    end
end

--玩家其他玩家准备状态
function TableBiJiSixLogic:refresh_ready_status(data)
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (tonumber(seatInfo.playerId) == tonumber(data.pos_info.player_id)) then
            if (data.pos_info.is_ready == 1) then
                self.modelData.curTableData.roomInfo.seatInfoList[i].isReady = true;
            else
                self.modelData.curTableData.roomInfo.seatInfoList[i].isReady = false;
                if self.modelData.roleData.RoomType == 2 and self.tablePlayerNum > 1 then--快速组局 牌局中人数大于一个人时 三分钟未开始服务器发送取消准备 显示不带倒计时的准备按钮
                    self.view:showReadyBtn(true)
                end
            end
            self.view:refreshSeat(seatInfo);
        end
    end
end


--显示是否确定配牌
function TableBiJiSixLogic:set_confirmed_status(seatInfo)
    if seatInfo == nil then return end
    for _, playerInfo in ipairs(seatInfo) do
        local seatData =  self.modelData.curTableData.roomInfo.seatInfoList[playerInfo.seatNum]
        if seatData.localSeatIndex ~= nil then
            if playerInfo.isConfirmed then
                self.view:playComfirmPokerAnimStep2(seatData.localSeatIndex)
            else
                self.view:showOtherPlayersPokers(seatData.localSeatIndex, self.pokersNum)
            end
        end
    end
end

--确定配牌后查看自己的配牌情况
function TableBiJiSixLogic:look_matchOver_poker(obj)
    if self.isShowResulting then return end
    if not self.modelData.curTableData.roomInfo.mySeatInfo.hasConfirmed  then return end
    self.view:lookMyPokersMatch(true, self.modelData.curTableData.roomInfo.mySeatInfo, self.modelData.matchOverPokersData)
end

--确定配牌后取消查看自己的配牌情况
function TableBiJiSixLogic:unlook_matchOver_poker(obj)
    if self.isShowResulting then return end
    if not self.modelData.curTableData.roomInfo.mySeatInfo.hasConfirmed then return end
    self.view:lookMyPokersMatch(false, self.modelData.curTableData.roomInfo.mySeatInfo)
end

--取消选中的牌
function TableBiJiSixLogic:on_click_cancel_select()
    self.myHandPokers:cancelSelectPokers()
end

--重连
function TableBiJiSixLogic:reconnect(data)
    self.tablePlayerNum = data.playercnt
    if (tonumber(data.reconnectStatus) == 1) then
        self:reset_ready_btn(data)
    elseif (tonumber(data.reconnectStatus) == 2) then
        self.myHandPokers.fastMatches = nil
        -- 服务器的原始数据
        self.view:showSortBtn(self.view.SORT_POKER_TYPE.SIZE)
        self.view:showMatchPokerTimeObj(false)
        self.oringinalServerPokers = data.pokers
        self.myHandPokers:setPokersInHand(data.pokers, true);
        self.myHandPokers:clearMatchingTable();
        if not self.modelData.curTableData.roomInfo.ruleTable.offlineAutoReady then
            self.module:show_match_poker_time(60);
        end
        self:set_confirmed_status(data.seatInfo)
    elseif (tonumber(data.reconnectStatus) == 3) then
        self.view:showReadyBtn(false)
        self:set_confirmed_status(data.seatInfo)
        self.modelData.matchOverPokersData = {}
        self.modelData.matchOverPokersData.pokers = data.pokers
    elseif (tonumber(data.reconnectStatus) == 4) then
        self.isShowResulting = true
        local eventData = { };
        eventData.players = data.players;
        eventData.err_no = data.isJoinAfterStart;
        self:set_confirmed_status(data.seatInfo)
        self.view:showReadyBtn(false)
        local onFinishPlayStartCompareAnim = function()
            self.view:showResultTable();
            self.module.result_coroutine =  self.module:start_lua_coroutine(function () self:show_match_poker_result(eventData)  end)
        end
        local seatInfo = self.module:getSeatInfoByPlayerId( tonumber(self.modelData.roleData.userID), self.modelData.curTableData.roomInfo.seatInfoList);
        self.view:playStartCompareAnim(seatInfo, onFinishPlayStartCompareAnim)
    elseif (tonumber(data.reconnectStatus) == 5) then
        if (data.roomInfo.curRoundNum ~= 0) then
            --self.tableBiJiView:SetAllDefaultImageActive(false);
        end
        --self.tableBiJiView:SetRuleBtnActive(false);
    end
    if (data.roomInfo.curRoundNum ~= 0) then
        self.view:showStartSeat(self.modelData.curTableData.roomInfo.seatInfoList)
    end
end

return TableBiJiSixLogic