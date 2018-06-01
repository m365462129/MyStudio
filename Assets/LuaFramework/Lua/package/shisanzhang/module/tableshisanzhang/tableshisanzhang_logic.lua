local ModuleCache = ModuleCache
local gamelogic = require("package.shisanzhang.module.tableshisanzhang.gamelogic")

local class = require("lib.middleclass")
local list = require("list")
local arithmetic = require("util.arithmetic")

--- @class TableShiSanZhangLogic
--- @field tableShiSanZhangView TableBiJiView
local TableShiSanZhangLogic = class('TableShiSanZhangLogic')
local TableShiSanZhangHelper = require("package/shisanzhang/module/tableshisanzhang/tableshisanzhang_helper")
local combinations = { };
local _paixing = { };

local CSmartTimer = ModuleCache.SmartTimer.instance
local table = table
local tonumber = tonumber
local ipairs = ipairs


function TableShiSanZhangLogic:initialize(module)
    self.tableModule = module;
    self.modelData = module.modelData;
    self.myRoomSeatInfo = self.modelData.roleData.myRoomSeatInfo;
    self.tableShiSanZhangView = self.tableModule.tableShiSanZhangView;
    self.tableShiSanZhangModel = self.tableModule.tableShiSanZhangModel;
    self.modelData.curTableData = { };
    self.modelData.curTableData.roomInfo = { };
    self.sortSequence = false;
    self.tenthPoker = { };
    -- self.inHandPokerList = {};
    self.modelData.curTableData.roomInfo.mySeatInfo = { };
    self.modelData.curTableData.roomInfo.seatInfoList = { };
    for i = 1, 4 do
        local seatInfo = { };
        seatInfo.seatIndex = i;
        table.insert(self.modelData.curTableData.roomInfo.seatInfoList, seatInfo);
    end
    -- self.tableShiSanZhangView:SetRoomInfo(self.modelData.curTableData.roomInfo);
    self.pokersInDesc = { };
    self.modelData.FirstMatching = { };
    self.modelData.SecondMatching = { };
    self.modelData.ThirdMatching = { };
    self.modelData.selectList = { };
    self.player = { };
    self.player.XiPai = { }
    self.isPlayingAnimCount = 0;
    self.waitPlayingFinishFunsQueue = list:new()
    self.resultData = { };
    for i = 1, 11 do
        self.player.XiPai[i] = false
        -- 1,三清;2,全黑;3,全红;4,双顺清;5,三顺清;6,双三条;7,全三条;8,四个头(1);9,四个头(2);10,连顺;11,清连顺;12,三顺子
    end

    -- S:黑桃 H:红桃 C:梅花 D
    -- self.pokercolor={"S","S","D","S","C","H","D","H","D"};
    -- self.pokernum={5,11,13,2,4,5,6,2,4};
    self.exchangePoker = { };
    self.isExchangeFinish = true;
    self.btnname = "";
    self.selectindex = 1;
    self.restcount = 0;
    self.tableShiSanZhangHelper = TableShiSanZhangHelper
    self.pokersNum = 13;
    self.tablePlayerNum = 0
    TableShiSanZhangHelper.module = require("package/shisanzhang/module/tableshisanzhang/tableshisanzhang_module")
    TableShiSanZhangHelper.modelData = self.modelData
    -- 牌局中的人数
end


function TableShiSanZhangLogic:on_press(obj, arg)
    if (obj.transform.parent and obj.transform.parent.parent and obj.transform.parent.parent.gameObject == self.tableShiSanZhangView.goDealWinPokers) then
        self.lastHoverPoker = obj
        self:on_select_poker(obj)
    end
end

function TableShiSanZhangLogic:on_press_up(obj, arg)
    self.lastHoverPoker = nil
end

function TableShiSanZhangLogic:GetStrPokerType(index)
    local strResult = ""
    --1 三顺 2 三顺鸡 3 三顺两鸡 4 三顺三鸡  5 八怪 6 四对 7 四条 8 双四条 9 杂龙 10 清龙
    if(index == 1) then
        strResult = "三顺"
    elseif(index == 2) then
        strResult = "三顺鸡"
    elseif(index == 3) then
        strResult = "三顺两鸡"
    elseif(index == 4) then
        strResult = "三顺三鸡"
    elseif(index == 5) then
        strResult = "八怪"
    elseif(index == 6) then
        strResult = "四对"
    elseif(index == 7) then
        strResult = "四条"
    elseif(index == 8) then
        strResult = "双四条"
    elseif(index == 9) then
        strResult = "杂龙"
    elseif(index == 10) then
        strResult = "清龙"
    end
    return strResult
end

-- 选择的牌
function TableShiSanZhangLogic:on_select_poker(obj)
    local count = #self.modelData.selectList;

    -- local seatinfo = self.modelData.curTableData.roomInfo.seatInfoList[1];
    self.selectindex = 1;
    for key, v in ipairs(self.handPokers) do
        if (v.image.gameObject == obj) then
            if v.selected then
                if count > 0 then
                    -- body
                    v.selected = false;
                    for key2, v2 in ipairs(self.modelData.selectList) do
                        if v.image.gameObject == v2.image.gameObject then
                            -- body
                            table.remove(self.modelData.selectList, key2);
                            break;
                        end
                    end
                else
                    return;
                end
                -- body
            else
                if (count < 5) then
                    v.selected = true;
                    table.insert(self.modelData.selectList, v);
                else
                    return;
                end
            end
            if (#self.exchangePoker > 0 and self.exchangePoker[1].indexMatch ~= 5) then

            else
                self.tableShiSanZhangView:refreshCardSelect(v, true);
            end
            break;
        end
    end
end

function TableShiSanZhangLogic:on_drag(obj, arg)
    local count = arg.hovered.Count
    for i = 0, count - 1 do
        local go = arg.hovered[i]
        if (go and go.name == 'poker' and go.transform.parent and go.transform.parent.parent and go.transform.parent.parent.gameObject == self.tableShiSanZhangView.goDealWinPokers) then
            if (go ~= self.lastHoverPoker) then
                self.lastHoverPoker = go
                self:on_select_poker(go)
            end
        end
    end
end


function TableShiSanZhangLogic:LeaveRoom(data)
    local playerID = data.player_id

    self.tablePlayerNum = data.playercnt
    -- 会收到其他玩家的中途进入包，其他玩家在没准备的情况下中途进入也会影响自己的按钮
    local my_seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[self.modelData.roleData.myRoomSeatInfo.SeatID];
    if (my_seatInfo and not my_seatInfo.isReady and self.modelData.curTableData.roomInfo.curRoundNum == 0) then
        self:ResetReadyBtn()
    end

    if (playerID == self.modelData.roleData.userID) then
        return;
    end
    self.tableModule:removeSeatInfoFromChatCurTableData(playerID)
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        if (tonumber(self.modelData.curTableData.roomInfo.seatInfoList[i].playerId) == tonumber(playerID)) then
            -- local seatInfo = {};
            -- seatInfo.seatIndex = self.modelData.curTableData.roomInfo.seatInfoList[i].seatIndex;
            -- self.modelData.curTableData.roomInfo.seatInfoList[i] = seatInfo;
            self.modelData.curTableData.roomInfo.seatInfoList[i].playerId = 0;
        end
        -- self.tableShiSanZhangView:refreshSeat(seatInfo);
    end
    self:RefreshAllSeats();
end

function TableShiSanZhangLogic:RefreshAllSeats()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (seatInfo.playerId == nil) then
            return;
        end
        self.tableShiSanZhangView:refreshSeat(seatInfo);
    end
end

function TableShiSanZhangLogic:InitSeatsInfo(data)
    self.tableShiSanZhangView:SetAllDefaultImageActive(false);
    local maxPlayerNum = self.modelData.curTableData.roomInfo.ruleTable.playerCount
    for i = 1, 4 do
        local localSeatIndex = self.tableShiSanZhangHelper:getLocalIndexFromRemoteSeatIndex(i, self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex, #self.modelData.curTableData.roomInfo.seatInfoList)
        self.tableShiSanZhangView:SetDefaultImageActive(localSeatIndex,true);
    end
    for i = 1, #data.seatInfo do
        local seatInfo = { };
        seatInfo.seatIndex = data.seatInfo[i].seatNum
        seatInfo.playerId = tostring(data.seatInfo[i].userID)
        if (tonumber(data.seatInfo[i].userID) == tonumber(self.modelData.curTableData.roomInfo.roomHostID)) then
            seatInfo.isCreator = true;
        else
            seatInfo.isCreator = false;
        end
        if (data.seatInfo[i].readyStatus == 1) then
            seatInfo.isReady = true;
        else
            seatInfo.isReady = false;
        end
        seatInfo.isTemporaryLeave = data.seatInfo[i].isTemporaryLeave;
        seatInfo.isOffline = data.seatInfo[i].isOffline;
        seatInfo.gameCount = data.seatInfo[i].gameCount;
        seatInfo.hasConfirmed = data.seatInfo[i].isConfirmed;
        seatInfo.canBeKicked = false;
        if(tonumber(self.modelData.roleData.userID) == self.modelData.curTableData.roomInfo.roomHostID) then
            if(tonumber(seatInfo.playerId) ~= self.modelData.curTableData.roomInfo.roomHostID and seatInfo.gameCount == 0) then
                seatInfo.canBeKicked = true;
            end
        end
        seatInfo.curScore = data.seatInfo[i].curScore;
        -- 玩家房间内积分
        -- seatInfo.winTimes = (seatInfo.isSeated and remoteSeatInfo.winTimes) or 0             --玩家房间内赢得次数
        -- seatInfo.isOffline = (not seatInfo.isSeated) or remoteSeatInfo.isOffline ~= 0      --玩家是否掉线

        -- seatInfo.isDoneComputeNiu = false			            --玩家是否已经完成选牛
        -- seatInfo.isCalculatedResult = false                     --是否已经结算
        seatInfo.roomInfo = data.roomInfo
        seatInfo.localSeatIndex = self.tableShiSanZhangHelper:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex, #self.modelData.curTableData.roomInfo.seatInfoList)
        self.modelData.curTableData.roomInfo.seatInfoList[seatInfo.seatIndex] = seatInfo;
        if (tonumber(data.seatInfo[i].userID) == tonumber(self.modelData.roleData.userID)) then
            self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo;
        end

        self.tableModule:addSeatInfo2ChatCurTableData(seatInfo)
        self:resetSeatHolderArray(#data.seatInfo);
        self.tableShiSanZhangView:refreshSeat(seatInfo);
    end
end

function TableShiSanZhangLogic:RefreshSeatOfflineStatus(playerID, isOffline)
    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
    for key, v in ipairs(seatsInfo) do
        if (tonumber(v.playerId) == tonumber(playerID)) then
            v.isOffline = isOffline;
            v.isTemporaryLeave = false;
            self.tableShiSanZhangView:refreshSeat(v);
        end
    end
end

function TableShiSanZhangLogic:RefreshCurScore(data)
    for key, v in ipairs(data.players) do
        self.modelData.curTableData.roomInfo.seatInfoList[v.seatNum].curScore = v.curScore;
        self.tableShiSanZhangView:refreshSeat(self.modelData.curTableData.roomInfo.seatInfoList[v.seatNum]);
    end
end

function TableShiSanZhangLogic:RefreshRoundInfo(curRoundNum)
    self.modelData.curTableData.roomInfo.curRoundNum = curRoundNum;
    self.tableShiSanZhangView:SetRoomInfo(self.modelData.curTableData.roomInfo);
end

function TableShiSanZhangLogic:RefreshTotalRoundInfo(totalRoundNum)
    self.modelData.curTableData.roomInfo.totalRoundCount = totalRoundNum;
    self.tableShiSanZhangView:SetRoomInfo(self.modelData.curTableData.roomInfo);
end

function TableShiSanZhangLogic:onClickKickBtn(index)
    local playerId;
    for key,v in ipairs(self.modelData.curTableData.roomInfo.seatInfoList) do
        if(v.localSeatIndex == tonumber(index)) then
            playerId = v.playerId
        end
    end
    self.tableShiSanZhangModel:request_kick_player(playerId);
end

function TableShiSanZhangLogic:HideKickButton()
    if(tonumber(self.modelData.roleData.userID) ~= self.modelData.curTableData.roomInfo.roomHostID) then
        return;
    end
    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
    for key, v in ipairs(seatsInfo) do
        if(v.playerId and v.playerId ~= 0) then
            v.canBeKicked = false;
            self.tableShiSanZhangView:refreshSeat(v);
        end
    end
end

function TableShiSanZhangLogic:onClickSurrenderBtn(obj)
    self.tableShiSanZhangModel:request_surrender(self.modelData.roleData.userID);
    self.tableShiSanZhangView:SetDealWindowActive(false);
    -- self.tableShiSanZhangView:SetSurrenderConfirmWindow(false);
    self.tableShiSanZhangView:ShowSelfSurrender()
    self.tableShiSanZhangView:SetSelfImageActive(true);
    self.tableShiSanZhangView:SetClockActive(false);
    -- body
end

-- 配牌
function TableShiSanZhangLogic:onClickPokersOnMatch(obj)
    if (obj.transform.parent.name ~= "pokersOnMatch" and obj.transform.parent.parent.name ~= "pockers") then
        return;
    end
    self.tableShiSanZhangView:SetExchangeHintActive(false);
    local index;

    if (obj.transform.parent.name == "pokersOnMatch") then
        index = tonumber(obj.name) + 1;
    end
    local curMatch = { };
    -- 1代表第一道牌，2代表第二道牌，3代表第三道牌，4代表第10张牌，5代表手牌
    local indexMatch = 0;
    if (obj.transform.parent.parent.gameObject.name == "first") then
        curMatch = self.modelData.FirstMatching;
        indexMatch = 1;
    elseif (obj.transform.parent.parent.gameObject.name == "second") then
        curMatch = self.modelData.SecondMatching;
        indexMatch = 2;
    elseif (obj.transform.parent.parent.gameObject.name == "third") then
        curMatch = self.modelData.ThirdMatching;
        indexMatch = 3;
    end
    if (self.pokersNum == 10 and obj.name == "10") then
        -- 当选中第10张牌时indexMatch为4
        index = 1;
        indexMatch = 4;
        table.insert(curMatch, self.tenthPoker)
    end
    if (obj.transform.parent.parent.gameObject.name == "pockers") then
        -- 当选中手牌时indexMatch为5
        index = tonumber(obj.transform.parent.gameObject.name) + 1;
        indexMatch = 5;
        curMatch = self.handPokers;
        if (#self.modelData.selectList > 1) then
            self.exchangePoker = { };
            return;
        end
    end

    if (#self.exchangePoker == 0) then
        -- 当未选中牌时
        local poker = { };
        if (obj.transform.parent.parent.gameObject.name == "pockers") then
            if (#self.modelData.selectList == 1) then
                poker.index = self:GetSelectedPokerIndex();
                poker.indexMatch = indexMatch;
                poker.number = self.modelData.selectList[1].number;
                poker.colour = self.modelData.selectList[1].colour;
            else
                return;
            end
        else
            if (#self.modelData.selectList > 1) then
                return;
            end
            poker.index = index;
            poker.indexMatch = indexMatch;
            poker.number = curMatch[index].number;
            poker.colour = curMatch[index].colour;
        end
        table.insert(self.exchangePoker, poker);
        self.tableShiSanZhangView:SetExchangePokerColor(indexMatch, index, true);
    elseif (#self.exchangePoker == 1) then
        -- 当选中牌时
        local oldMatch = { };
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        if (indexMatch == oldIndexMatch) then
            self.exchangePoker = { };
            self.tableShiSanZhangView:SetExchangePokerColor(oldIndexMatch, oldIndex, false);
            return;
        end
        self.isExchangeFinish = false;
        local poker = { };
        poker.index = index;
        poker.indexMatch = indexMatch;
        poker.number = curMatch[index].number;
        poker.colour = curMatch[index].colour;
        curMatch[index].colour = self.exchangePoker[1].colour;
        curMatch[index].Color = self.exchangePoker[1].colour;
        curMatch[index].number = self.exchangePoker[1].number;
        curMatch[index].Number = self.exchangePoker[1].number;
        -- self.tableShiSanZhangView:setMatchingShow(indexMatch,curMatch,0,false);
        if (indexMatch <= 3) then
            self:sortPoker(curMatch, false);
            self:check_handpokers_in_oringinalPokers(curMatch);
            
            local res, value = gamelogic.ComputePaixing(curMatch, self.mask)
            self.tableShiSanZhangView:SetPokerTypeHint(indexMatch, res);
            --self:sortPoker(curMatch, true);
            self.tableShiSanZhangView:setMatchingShow(indexMatch, curMatch, 0, false);
        end
        if (self.pokersNum == 10 and indexMatch == 4) then
            self.tableShiSanZhangView:Show10thPokerImage(self.tenthPoker);
        end
        if (indexMatch == 5) then
            self:SetPokersInHand(curMatch, false, self.sortSequence);
        end
        local oldMatch = { };
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        if (oldIndexMatch == 1) then
            oldMatch = self.modelData.FirstMatching
        elseif (oldIndexMatch == 2) then
            oldMatch = self.modelData.SecondMatching;
        elseif (oldIndexMatch == 3) then
            oldMatch = self.modelData.ThirdMatching;
        elseif (self.pokersNum == 10 and oldIndexMatch == 4) then
            table.insert(oldMatch, self.tenthPoker)
        elseif (oldIndexMatch == 5) then
            oldMatch = self.handPokers;
        end
        self.tableShiSanZhangView:SetExchangePokerColor(oldIndexMatch, oldIndex, false);
        oldMatch[oldIndex].colour = poker.colour;
        oldMatch[oldIndex].Color = poker.colour;
        oldMatch[oldIndex].number = poker.number;
        oldMatch[oldIndex].Number = poker.number;
        self:sortPoker(oldMatch, false);
        if (oldIndexMatch ~= 5) then
            
            if (oldIndexMatch <= 3) then
                local res, value = gamelogic.ComputePaixing(oldMatch, self.mask)
                self.tableShiSanZhangView:SetPokerTypeHint(oldIndexMatch, res);
            end
            --self:sortPoker(oldMatch, true);
            self.tableShiSanZhangView:setMatchingShow(self.exchangePoker[1].indexMatch, oldMatch, 0, false);
        else
            self:SetPokersInHand(self.handPokers, false, self.sortSequence);
        end
        if (self.pokersNum == 10 and oldIndexMatch == 4) then
            self.tableShiSanZhangView:Show10thPokerImage(self.tenthPoker);
        end

        -- 如果已经放了三道牌上去
        if (#self.modelData.FirstMatching == 3 and #self.modelData.SecondMatching == 5 and #self.modelData.ThirdMatching == 5) then
            self:LocalCheckSequence();
        end
        self.tableShiSanZhangView:ClearSelectedSuggestion();
        self.specialType = 0;
        if(#self.modelData.FirstMatching == 3) then
            self:sortPoker(self.modelData.FirstMatching, false);
            self.tableShiSanZhangView:setMatchingShow(1, self.modelData.FirstMatching, 0, false);
            self.tableShiSanZhangView:ShowMatchingShow(1);
        end
        if(#self.modelData.SecondMatching == 5) then
            self:sortPoker(self.modelData.SecondMatching, false);
            self.tableShiSanZhangView:setMatchingShow(2, self.modelData.SecondMatching, 0, false);
            self.tableShiSanZhangView:ShowMatchingShow(2);
        end
        if(#self.modelData.ThirdMatching == 5) then
            self:sortPoker(self.modelData.ThirdMatching, false);
            self.tableShiSanZhangView:setMatchingShow(3, self.modelData.ThirdMatching, 0, false);
            self.tableShiSanZhangView:ShowMatchingShow(3);
        end
        self.exchangePoker = { };
    end
end

function TableShiSanZhangLogic:GetCurPlayerCount()
    local count = 0;
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        if(self.modelData.curTableData.roomInfo.seatInfoList[i].playerId and self.modelData.curTableData.roomInfo.seatInfoList[i].playerId ~= 0) then
            count = count + 1;
        end
    end
    print("=================",count)
    return count;
end

function TableShiSanZhangLogic:GetSelectedPokerIndex()
    for i = 1, #self.handPokers do
        if (self.handPokers[i].selected) then
            return i;
        end
    end
    return -1;
end

function TableShiSanZhangLogic:onClickSubmitSpecialType()
    --local pokers = ;
    --local pokerType = ;
    self.tableShiSanZhangModel:request_submit(pokers, self.modelData.roleData.userID,pokerType);
end

function TableShiSanZhangLogic:onClickSubmitConfirmBtn(obj)
    if(self.sequenceFlag == 1) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("中道必须大于头道！")
        return;
    elseif(self.sequenceFlag == 2) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("尾道必须大于中道！")
        return;
    end
    local pokers = { };
    for key, v in ipairs(self.modelData.FirstMatching) do
        local poker = { };
        poker.Color = v.colour;
        poker.Number = v.number;
        table.insert(pokers, poker);
    end
    for key, v in ipairs(self.modelData.SecondMatching) do
        local poker = { };
        poker.Color = v.colour;
        poker.Number = v.number;
        table.insert(pokers, poker);
    end
    for key, v in ipairs(self.modelData.ThirdMatching) do
        local poker = { };
        poker.Color = v.colour;
        poker.Number = v.number;
        table.insert(pokers, poker);
    end
    if (#self.modelData.FirstMatching ~= 3 or #self.modelData.SecondMatching ~= 5 or #self.modelData.ThirdMatching ~= 5) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("未完成配牌！")
        return;
    end
    self.tableShiSanZhangModel:request_submit(pokers, self.modelData.roleData.userID,self.specialType);
    -- self.tableShiSanZhangView:SetConfirmWindowActive(false);
    self.tableShiSanZhangView:SetDealWindowActive(false);
    self.tableShiSanZhangView:SetSelfImageActive(true);
    self.tableShiSanZhangView:SetClockActive(false);
    self.tableShiSanZhangView:ShowSelfResultBackTable();
    self:SetMatchingStatus();
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    for key, v in ipairs(seatInfoList) do
        if (not v.hasConfirmed) then
            if (v.playerId ~= 0 and v.playerId ~= nil and v.localSeatIndex ~= 1 and v.localSeatIndex ~= nil and v.gameCount ~= 0) then
                self.tableShiSanZhangView:ShowOthersPokerBack(v.localSeatIndex, false, self.pokersNum)
            end
        end
    end
    if (self.pokersNum == 10) then
        self.tenthPoker = { };
    end
end

function TableShiSanZhangLogic:SetMatchingStatus()
    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatsInfo do
        if (seatsInfo[i].localSeatIndex ~= 1 and seatsInfo[i].localSeatIndex ~= nil) then
            self.tableShiSanZhangView:SetMatchingActive(seatsInfo[i].localSeatIndex, true);
        end
    end
end

function TableShiSanZhangLogic:ExitRoom()
    self.tableShiSanZhangModel:request_exit_room(tonumber(self.modelData.roleData.userID));
end

function TableShiSanZhangLogic:resetSeatHolderArray(seatCount)
    local newSeatHolderArray = { }
    local seatHolderArray = self.tableShiSanZhangView.srcSeatHolderArray
    local maxPlayerCount = seatCount
    maxPlayerCount = 6
    if (maxPlayerCount == 3) then
        newSeatHolderArray[1] = seatHolderArray[1]
        newSeatHolderArray[2] = seatHolderArray[3]
        newSeatHolderArray[3] = seatHolderArray[5]
    elseif (maxPlayerCount == 4) then
        newSeatHolderArray[1] = seatHolderArray[1]
        newSeatHolderArray[2] = seatHolderArray[3]
        newSeatHolderArray[3] = seatHolderArray[4]
        newSeatHolderArray[4] = seatHolderArray[5]
    elseif (maxPlayerCount == 5) then
        newSeatHolderArray[1] = seatHolderArray[1]
        newSeatHolderArray[2] = seatHolderArray[3]
        newSeatHolderArray[3] = seatHolderArray[4]
        newSeatHolderArray[4] = seatHolderArray[5]
        newSeatHolderArray[5] = seatHolderArray[6]
        newSeatHolderArray[6] = seatHolderArray[7]
    else
        newSeatHolderArray = seatHolderArray
    end

    for i, v in ipairs(seatHolderArray) do
        ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, false)
    end
    for i, v in ipairs(newSeatHolderArray) do
        ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, true)
    end
    self.tableShiSanZhangView.seatHolderArray = newSeatHolderArray
end


--- 重置单道牌
--- @param obj table
function TableShiSanZhangLogic:onClickResetBtn(obj)
    if (obj.transform.parent.gameObject.name == "first") then
        for key, v in ipairs(self.modelData.FirstMatching) do
            v.showed = true;
            v.selected = false;
            local poker = { };
            poker.number = v.number;
            poker.Number = v.Number;
            poker.colour = v.colour;
            poker.Color = v.Color;
            poker.showed = v.showed;
            poker.selected = v.selected;
            poker.gameObject = v.gameObject;
            poker.image = v.image;
            table.insert(self.handPokers, poker);
            self.tableShiSanZhangView:refreshCardSelect(v, false);
        end
        self.tableShiSanZhangView:ClearMatchingShow(1);
        self.modelData.FirstMatching = { };
        self.tableShiSanZhangView:SetResetBtnActive(1, false);
        self.tableShiSanZhangView:SetNoPokersImageActive(1, true);
        self.tableShiSanZhangView:ClearPaiXingHint(1);
    end
    if (obj.transform.parent.gameObject.name == "second") then
        for key, v in ipairs(self.modelData.SecondMatching) do
            v.showed = true;
            v.selected = false;
            local poker = { };
            poker.number = v.number;
            poker.Number = v.Number;
            poker.colour = v.colour;
            poker.Color = v.Color;
            poker.showed = v.showed;
            poker.selected = v.selected;
            poker.gameObject = v.gameObject;
            poker.image = v.image;
            table.insert(self.handPokers, poker);
            self.tableShiSanZhangView:refreshCardSelect(v, false);
            -- self.tableShiSanZhangView:setInHandPokerActive(v, true);
        end
        self.tableShiSanZhangView:ClearMatchingShow(2);
        self.modelData.SecondMatching = { };
        self.tableShiSanZhangView:SetResetBtnActive(2, false);
        self.tableShiSanZhangView:SetNoPokersImageActive(2, true);
        self.tableShiSanZhangView:ClearPaiXingHint(2);
    end
    if (obj.transform.parent.gameObject.name == "third") then
        for key, v in ipairs(self.modelData.ThirdMatching) do
            v.showed = true;
            v.selected = false;
            local poker = { };
            poker.number = v.number;
            poker.Number = v.Number;
            poker.colour = v.colour;
            poker.Color = v.Color;
            poker.showed = v.showed;
            poker.selected = v.selected;
            poker.gameObject = v.gameObject;
            poker.image = v.image;
            table.insert(self.handPokers, poker);
            self.tableShiSanZhangView:refreshCardSelect(v, false);
            -- self.tableShiSanZhangView:setInHandPokerActive(v, true);
        end
        self.tableShiSanZhangView:ClearMatchingShow(3);
        self.modelData.ThirdMatching = { };
        self.tableShiSanZhangView:SetResetBtnActive(3, false);
        self.tableShiSanZhangView:SetNoPokersImageActive(3, true);
        self.tableShiSanZhangView:ClearPaiXingHint(3);
    end
    if (self.pokersNum == 10 and self.tenthPoker.number ~= nil) then
        local poker = { };
        poker.number = self.tenthPoker.number;
        poker.Number = self.tenthPoker.Number;
        poker.colour = self.tenthPoker.colour;
        poker.Color = self.tenthPoker.Color;
        poker.showed = self.tenthPoker.showed;
        poker.selected = self.tenthPoker.selected;
        poker.gameObject = self.tenthPoker.gameObject;
        poker.image = self.tenthPoker.image;
        table.insert(self.handPokers, poker);
        self.tableShiSanZhangView:refreshCardSelect(self.tenthPoker, false);
        self.tableShiSanZhangView:Set10thPokersActive(false);
        self.tenthPoker = { };
    end
    local pokersReset = { };
    for key, v in ipairs(self.handPokers) do
        local pokerReset = { };
        pokerReset.Color = v.colour;
        pokerReset.Number = v.number;
        table.insert(pokersReset, pokerReset)
    end
    self:SetPokersInHand(pokersReset, false, self.sortSequence);
    self:SetDealBtnActive();
    self.tableShiSanZhangView:ShowXiPai("");
    self.tableShiSanZhangView:SetResetAllActive(false);
    --self:onClickOrderBtn(true);
    self.tableShiSanZhangView:ClearSelectedSuggestion();
    self.tableShiSanZhangView:SetExchangeHintActive(false);
    self.tableShiSanZhangView:SetErrHintActive(false);
    if (#self.exchangePoker > 0) then
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        self.tableShiSanZhangView:SetExchangePokerColor(oldIndexMatch, oldIndex, false)
        self.exchangePoker = { };
    end
end

function TableShiSanZhangLogic:onClickResetAllBtnNew(obj)
    self.tableShiSanZhangView:ClearMatchingShow(1);
    self.tableShiSanZhangView:ClearMatchingShow(2);
    self.tableShiSanZhangView:ClearMatchingShow(3);
    self.tableShiSanZhangView:SetResetBtnActive(1, false);
    self.tableShiSanZhangView:SetResetBtnActive(2, false);
    self.tableShiSanZhangView:SetResetBtnActive(3, false);
    self.modelData.FirstMatching = { };
    self.modelData.SecondMatching = { };
    self.modelData.ThirdMatching = { };
    self.modelData.selectList = { }
    self:SetDealBtnActive();
    self.tableShiSanZhangView:ShowXiPai("");
    self.tableShiSanZhangView:SetResetAllActive(false);
    --self:onClickOrderBtn(true);
    self.tableShiSanZhangView:ClearSelectedSuggestion();
    self.tableShiSanZhangView:SetExchangeHintActive(false);
    self.tableShiSanZhangView:SetErrHintActive(false);
    if (#self.exchangePoker > 0) then
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        self.tableShiSanZhangView:SetExchangePokerColor(oldIndexMatch, oldIndex, false)
        self.exchangePoker = { };
    end
    if (self.pokersNum == 10 and self.tenthPoker.number ~= nil) then
        self.tenthPoker = { };
        self.tableShiSanZhangView:Set10thPokersActive(false);
    end
    self:SetPokersInHand(self.oringinalServerPokers, false, self.sortSequence);
    for i = 1, 3 do
        self.tableShiSanZhangView:ClearPaiXingHint(i);
    end
end


function TableShiSanZhangLogic:RefreshTemporaryLeaveStatus(data)
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (tonumber(seatInfo.playerId) == tonumber(data.player_id) and seatInfo.playerId ~= nil) then
            self.modelData.curTableData.roomInfo.seatInfoList[i].isTemporaryLeave = data.is_temporary_leave;
            self.tableShiSanZhangView:refreshSeat(seatInfo);
        end
    end
end

function TableShiSanZhangLogic:SetRoomInfo(data)
    if (not data.err_no or data.err_no == '0') then
        self.roomInfo = {
            roomNum = data.roomInfo.roomNum,
            roomHostID = data.roomInfo.roomHostID,
            curRoundNum = data.roomInfo.curRoundNum,
            totalRoundCount = data.roomInfo.totalRoundNum,
            roomStatus = data.roomInfo.roomStatus,
            roomId = data.roomInfo.roomId
        }
        self.modelData.curTableData.roomInfo.roomNum = self.roomInfo.roomNum;
        self.modelData.curTableData.roomInfo.roomHostID = self.roomInfo.roomHostID;
        self.modelData.curTableData.roomInfo.curRoundNum = self.roomInfo.curRoundNum;
        self.modelData.curTableData.roomInfo.totalRoundCount = self.roomInfo.totalRoundCount;
        self.modelData.curTableData.roomInfo.roomStatus = self.roomInfo.roomStatus;
        self.modelData.curTableData.roomInfo.timeOffset =(data.roomInfo.serverNow or os.time()) - os.time()
        self.roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
        self.modelData.curTableData.roomInfo.rule = self.roomInfo.rule;
        self.roomInfo.ruleTable = ModuleCache.Json.decode(self.roomInfo.rule);
        print_table(self.roomInfo.ruleTable)
        self.roomInfo.ruleDesc = self:GetStrRoomRule();
        self.tableShiSanZhangView.centerRule.text = self.roomInfo.ruleDesc;
        self.modelData.curTableData.roomInfo.roomId = self.roomInfo.roomId;
        -- self.roomInfo.wanfaName,self.roomInfo.ruleDesc = TableUtil.get_rule_name(self.roomInfo.rule)
        self.pokersNum = self.roomInfo.ruleTable.pokersNum;
        self.pokersNum = 13;
        self.modelData.curTableData.roomInfo.ruleDesc = self.roomInfo.ruleDesc;
        self.modelData.curTableData.roomInfo.ruleTable = self.roomInfo.ruleTable;
        local straightRule = self.modelData.curTableData.roomInfo.ruleTable.straightRule
        gamelogic.setStraightRule(straightRule)
        local flushRule = self.modelData.curTableData.roomInfo.ruleTable.flushRule
        gamelogic.setFlushRule(flushRule)
        if (self.roomInfo.curRoundNum == 0) then

        end
        self:convertMaskCode(self.roomInfo.ruleTable)
        -- self.modelData.curTableData.roomInfo = self.roomInfo;
        -- self.modelData.curTableData.roomInfo.mySeatInfo = {};
        for i = 1, #data.seatInfo do
            if (tonumber(self.modelData.roleData.userID) == tonumber(data.seatInfo[i].userID)) then
                self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex = data.seatInfo[i].seatNum;
            end
        end
        self.tableShiSanZhangView:SetRoomInfo(self.roomInfo);
    end
end

function TableShiSanZhangLogic:GetStrRoomRule()
    local strRule = "";
    local rule = self.roomInfo.ruleTable;
    strRule = strRule .. rule.roundCount .. "局 ";
    strRule = strRule .. rule.playerCount .. "人 ";
    if(rule.flushRule == 1) then
        strRule = strRule.."同花色优先比花色 "
    elseif(rule.flushRule == 2) then
        strRule = strRule.."同花色优先比大小 "
    end
    if(rule.straightRule == 1) then
        strRule = strRule.."A2345为第二大顺子 "
    elseif(rule.straightRule == 2) then
        strRule = strRule.."A2345为最小顺子 "
    end
    if(rule.balance == 1) then
        strRule = strRule.."单杀、通杀翻倍 "
    elseif(rule.balance == 2) then
        strRule = strRule.."单杀、通杀翻倍加底分 "
    elseif(rule.balance == 3) then
        strRule = strRule.."黑桃A翻倍 "
    elseif(rule.balance == 4) then
        strRule = strRule.."打枪翻倍 "
    elseif(rule.balance == 5) then
        strRule = strRule.."黑桃A翻倍 "
    elseif(rule.balance == 6) then
        strRule = strRule.."打枪+黑桃A翻倍 "
    end
    if (tonumber(rule.payType) == 0) then
        strRule = strRule .. "AA支付 ";
    elseif (tonumber(rule.payType) == 1) then
        strRule = strRule .. "房主支付 ";
    elseif (tonumber(rule.payType) == 2) then
        strRule = strRule .. "大赢家支付 ";
    end
    return strRule;
end

function TableShiSanZhangLogic:GetCenterRoomRule()
    local strRule = "";
    local rule = self.roomInfo.ruleTable;
    if(rule.rule == 1) then
        strRule = strRule.."整副牌 "
    elseif(rule.rule == 2) then
        strRule = strRule.."去2-6 "
    elseif(rule.rule == 3) then
        strRule = strRule.."去2-8 "
    end
    if(rule.playerCount == 6) then
        if(rule.rule == 2 or rule.rule == 3) then
            strRule = strRule .. "6人(2副牌) "
        else
            strRule = strRule .. "6人 "
        end
    elseif(rule.playerCount == 4) then
        if(rule.rule == 3) then
            strRule = strRule .. "4人(2副牌) "
        else
            strRule = strRule .. "4人 "
        end
    elseif(rule.playerCount == 3) then
        strRule = strRule .. "3人 "
    end
    if (tonumber(rule.payType) == 0) then
        strRule = strRule .. "AA支付 ";
    elseif (tonumber(rule.payType) == 1) then
        strRule = strRule .. "房主支付 ";
    elseif (tonumber(rule.payType) == 2) then
        strRule = strRule .. "大赢家支付 ";
    end
    return strRule;
end

function TableShiSanZhangLogic:GetReadyRsp(data)
    if (data.err_no == "0") then
        self.readyRsp = true;

        self.tableShiSanZhangView:SetReadyCancel(true);
        self:refreshSelfReadyStatus(true);
        -- self.tableShiSanZhangView:SetBtnInviteActive(false);
        self.tableShiSanZhangView:CloseResultTable();
    else
        self.readyRsp = false;
    end
end

function TableShiSanZhangLogic:SetReadyBtnType(data)
    if ((tonumber(data.isJoinAfterStart) == 1) and tonumber(data.roomInfo.roomStatus) == 1) then
        self.tableShiSanZhangView:SetReadyBtn(1);
        self.tableShiSanZhangView:ShowPlayingNotify();
        self.isJoinAfterStart = true;
        return;
    end
    if (data.isJoinAfterStart and tonumber(data.isJoinAfterStart) == 1) then
        self.isJoinAfterStart = true;
    else
        self.isJoinAfterStart = false;
    end
    self.tableShiSanZhangView:ClosePlayingNotify();
    if (self.isJoinAfterStart) then
        if self.modelData.roleData.RoomType ~= 2 then
            -- TODO XLQ:麻将馆随机组局 中途进入的玩家 已经准备后 第一局小结算不再显示准备按钮
            self.tableShiSanZhangView:SetReadyBtn(3);
        end
        self.isJoinAfterStart = false;
        return;
    end

    if (self.modelData.curTableData.roomInfo.curRoundNum == 0) then
        self.tableShiSanZhangView:SetBtnInviteActive(true);
        self:ResetReadyBtn()
        if self.modelData.roleData.RoomType ~= 2 then
            -- 0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
            self:onClickReadyBtn(true);
            -- 自动准备    除了随机组局其他都需要自动准备
        end

    else
        local my_seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[self.modelData.roleData.myRoomSeatInfo.SeatID];
        if not my_seatInfo.isReady then
            self.tableShiSanZhangView:SetBtnInviteActive(false);
            self.tableShiSanZhangView:SetReadyBtn(2);
        end

    end
    if (ModuleCache.GameManager.isEditor and ModuleCache.GameManager.developmentMode) then
        -- self:onClickReadyBtn()
    end
end

function TableShiSanZhangLogic:ResetReadyBtn(data)
    --  print_table(self.modelData,"-----------self.modelData-------ResetReadyBtn--")
    if self.modelData.roleData.RoomType == 2 then
        -- 快速开房
        if (tonumber(self.modelData.curTableData.roomInfo.roomHostID) == tonumber(self.modelData.roleData.userID)) then
            if self.tablePlayerNum > 1 then
                self.tableShiSanZhangView:SetReadyBtn(4);
                -- 显示倒计时准备按钮
            else
                self.tableShiSanZhangView:SetReadyBtn(0);
            end
        else
            -- 非房主
            if self.tablePlayerNum > 1 then
                self.tableShiSanZhangView:SetReadyBtn(3);
                -- 显示倒计时准备按钮
            else
                self.tableShiSanZhangView:SetReadyBtn(1);
            end

        end
    else
        if (tonumber(self.modelData.curTableData.roomInfo.roomHostID) == tonumber(self.modelData.roleData.userID)) then
            self.tableShiSanZhangView:SetReadyBtn(0);
        else
            -- 非房主
            self.tableShiSanZhangView:SetReadyBtn(1);
            if (data and data.isJoinAfterStart == 1) then
                if (tonumber(data.roomInfo.roomStatus) == 1) then
                    self.tableShiSanZhangView:SetReadyBtn(1);
                else
                    self.tableShiSanZhangView:SetBtnInviteActive(false);
                    self.tableShiSanZhangView:SetReadyBtn(2);
                end
            end
        end
    end

    -- print("----------ResetReadyBtn------------------tablePlayerNum:",self.tablePlayerNum,self.roomInfo.roomHostID,self.modelData.roleData.userID,self.modelData.curTableData.roomInfo.roomHostID)
end

-- 测试所有的牌排列
function TableShiSanZhangLogic:TestAllPokersArrange(handPokers)
    local numData = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
    local groupData = arithmetic.allCombinationGroup(numData, 3)

    print_table(handPokers)
    for i = 1, #groupData do
        local singleGroupData = groupData[i]
        -- print_table(singleGroupData)
        self.modelData.FirstMatching = { }
        self.modelData.SecondMatching = { }
        self.modelData.ThirdMatching = { }
        for j = 1, 9 do
            if j < 3 then
                table.insert(self.modelData.FirstMatching, handPokers[singleGroupData[j]])
            elseif j > 2 and j < 6 then
                table.insert(self.modelData.SecondMatching, handPokers[singleGroupData[j]])
            else
                table.insert(self.modelData.ThirdMatching, handPokers[singleGroupData[j]])
            end
        end
        self:LocalCheckSequence()
    end

end

--- 本地排序三道牌
function TableShiSanZhangLogic:LocalCheckSequence(onlyCompute)
    local matches = { };
    local pokers = { };
    local mask = { };
    for i = 1, 3 do
        matches[i] = { };
        if (i == 1) then
            for j = 1, 3 do
                local poker = { };
                poker.colour = self.modelData.FirstMatching[j].colour;
                poker.number = self.modelData.FirstMatching[j].number;
                poker.Color = self.modelData.FirstMatching[j].colour;
                poker.Number = self.modelData.FirstMatching[j].number;
                mask[poker.Number * 4 + poker.Color] = true;
                table.insert(matches[i], poker);
            end
            matches[i]["index"] = 1;
        end
        if (i == 2) then
            for j = 1, 5 do
                local poker = { };
                poker.colour = self.modelData.SecondMatching[j].colour;
                poker.number = self.modelData.SecondMatching[j].number;
                poker.Color = self.modelData.SecondMatching[j].colour;
                poker.Number = self.modelData.SecondMatching[j].number;
                mask[poker.Number * 4 + poker.Color] = true;
                table.insert(matches[i], poker);
            end
            matches[i]["index"] = 2;
        end
        if (i == 3) then
            for j = 1, 5 do
                local poker = { };
                poker.colour = self.modelData.ThirdMatching[j].colour;
                poker.number = self.modelData.ThirdMatching[j].number;
                poker.Color = self.modelData.ThirdMatching[j].colour;
                poker.Number = self.modelData.ThirdMatching[j].number;
                mask[poker.Number * 4 + poker.Color] = true;
                table.insert(matches[i], poker);
            end
            matches[i]["index"] = 3;
        end
    end
    self.sequenceFlag = gamelogic.SortHBTPai(matches, mask)
    -- print_table(matches)

    local needToChange = false;
    for i = 1, 3 do
        local srcIndex = matches[i]["index"];
        local desIndex = i;
        if (srcIndex ~= desIndex) then
            needToChange = true;
        end
    end
    if (needToChange) then
        -- 自动变牌
        self.tableShiSanZhangView:SetErrHintActive(true);
    end

    for i = 1, 3 do
        local indexMax = 5;
        if(i == 1) then
            indexMax = 3;
        end
        for j = 1, indexMax do
            table.insert(pokers, matches[i][j])
        end
        self.tableShiSanZhangView:SetPokerTypeHint(i, matches[i].px)
    end
    if ModuleCache.GameManager.isEditor then
        -- local tmpData = {}
        -- table.insert(tmpData, {3,6})
        -- table.insert(tmpData, {4,6})
        -- table.insert(tmpData, {4,14})
        -- table.insert(tmpData, {2,2})
        -- table.insert(tmpData, {2,3})
        -- table.insert(tmpData, {2,10})
        -- table.insert(tmpData, {3,3})
        -- table.insert(tmpData, {3,12})
        -- table.insert(tmpData, {3,13})
        --
        -- for i = 1, #tmpData do
        --    pokers[i].colour = tmpData[i][1]
        --    pokers[i].Color = tmpData[i][1]
        --    pokers[i].number = tmpData[i][2]
        --    pokers[i].Number = tmpData[i][2]
        -- end
    end

    self:CheckedSequence(1, pokers);
    return needToChange;
end

function TableShiSanZhangLogic:SetOthersPokers()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatInfoList do
        if (seatInfoList[i].localSeatIndex and seatInfoList[i].localSeatIndex ~= 1 and seatInfoList[i].playerId ~= 0 and seatInfoList[i].playerId ~= nil) then
            self.tableShiSanZhangView:ShowOthersPokerBack(seatInfoList[i].localSeatIndex, true, self.pokersNum);
        end
    end
end

-- 排序
function TableShiSanZhangLogic:CheckedSequence(err_no, pokers)
    print_table(pokers);
    self:check_handpokers_in_oringinalPokers(pokers)
    local error = tonumber(err_no);
    local pai = { };
    if (error == 0) then
        -- 与服务器交互后
        table.insert(pai, self.modelData.FirstMatching);
        table.insert(pai, self.modelData.SecondMatching);
        table.insert(pai, self.modelData.ThirdMatching);
        self.player.Poker = self.pokersInDesc;
        self.player.Pai = pai;
        gamelogic.ComputeXiPai(self.player.Pai, self.player.Poker, self.player.XiPai, self.maskXiPai);
        -- strXiPai = self:GetStrXiPai();
        -- self.tableShiSanZhangView:ShowXiPai(strXiPai);
        -- self:ClearXiPai();
        return;
    end

    for i = 1, 3 do
        -- local match = {};
        -- for j = 1,3 do
        -- local poker = {};
        -- poker.colour =pokers[j + (i-1)*3].Color;
        -- poker.number =tonumber(pokers[j + (i-1)*3].Number);
        -- poker.selected = false;
        -- poker.showed = false;
        -- table.insert(match,poker);
        -- end
        if (i == 1) then
            for j = 1, 3 do
                -- local poker = {};
                self.modelData.FirstMatching[j].colour = pokers[j +(i - 1) * 3].colour;
                self.modelData.FirstMatching[j].number = tonumber(pokers[j +(i - 1) * 3].number);
                self.modelData.FirstMatching[j].Color = pokers[j +(i - 1) * 3].colour;
                self.modelData.FirstMatching[j].Number = tonumber(pokers[j +(i - 1) * 3].number);
                self.modelData.FirstMatching[j].selected = false;
                self.modelData.FirstMatching[j].showed = false;
                -- self.modelData.FirstMatching[j].gameObject = self:GetGameObjectInHandFromColorAndNum(self.modelData.FirstMatching[j].colour, self.modelData.FirstMatching[j].number);
            end
        end
        if (i == 2) then
            for j = 1, 5 do
                -- local poker = {};
                self.modelData.SecondMatching[j].colour = pokers[j +(i - 1) * 3].colour;
                self.modelData.SecondMatching[j].number = tonumber(pokers[j +(i - 1) * 3].number);
                self.modelData.SecondMatching[j].Color = pokers[j +(i - 1) * 3].colour;
                self.modelData.SecondMatching[j].Number = tonumber(pokers[j +(i - 1) * 3].number);
                self.modelData.SecondMatching[j].selected = false;
                self.modelData.SecondMatching[j].showed = false;
                -- self.modelData.SecondMatching[j].gameObject = self:GetGameObjectInHandFromColorAndNum(self.modelData.SecondMatching[j].colour, self.modelData.SecondMatching[j].number);
            end
        end
        if (i == 3) then
            for j = 1, 5 do
                -- local poker = {};
                self.modelData.ThirdMatching[j].colour = pokers[j +(i - 1) * 5 - 2].colour;
                self.modelData.ThirdMatching[j].number = tonumber(pokers[j +(i - 1) * 5 - 2].number);
                self.modelData.ThirdMatching[j].Color = pokers[j +(i - 1) * 5 - 2].colour;
                self.modelData.ThirdMatching[j].Number = tonumber(pokers[j +(i - 1) * 5 - 2].number);
                self.modelData.ThirdMatching[j].selected = false;
                self.modelData.ThirdMatching[j].showed = false;
                -- self.modelData.ThirdMatching[j].gameObject = self:GetGameObjectInHandFromColorAndNum(self.modelData.ThirdMatching[j].colour, self.modelData.ThirdMatching[j].number);
            end
        end
    end
    table.insert(pai, self.modelData.FirstMatching);
    table.insert(pai, self.modelData.SecondMatching);
    table.insert(pai, self.modelData.ThirdMatching);
    -- log_table(pai)
    -- self:check_handpokers_in_oringinalPokers(self.modelData.FirstMatching)
    -- self:check_handpokers_in_oringinalPokers(self.modelData.SecondMatching)
    -- self:check_handpokers_in_oringinalPokers(self.modelData.ThirdMatching)
    self.tableShiSanZhangView:setMatchingShow(1, self.modelData.FirstMatching, 0, false)
    self.tableShiSanZhangView:setMatchingShow(2, self.modelData.SecondMatching, 0, false)
    self.tableShiSanZhangView:setMatchingShow(3, self.modelData.ThirdMatching, 0, false)
    self.player.Poker = self.pokersInDesc;
    self.player.Pai = pai;
    -- 思源同学说可以删除了
    -- gamelogic.ComputeXiPai(self.player.Pai,self.player.Poker,self.player.XiPai,self.maskXiPai);
    -- strXiPai = self:GetStrXiPai();
    -- self:ClearXiPai();
end


function TableShiSanZhangLogic:ReceiveStartRsp(data)
    if (not data.err_no or data.err_no == '0') then
        self.tableShiSanZhangView:ShowDealTable();
        self.startBtn.transform.parent.gameObject:SetActive(false);
        self.tableShiSanZhangView:SetAllDefaultImageActive(false);
    else
        if (tonumber(self.modelData.curTableData.roomInfo.roomHostID) ~= tonumber(self.modelData.roleData.userID)) then
            return;
        end
        local err_info = data.err_no;
        self.tableShiSanZhangView:ShowNotReadyNotice(err_info);
    end
end

function TableShiSanZhangLogic:ShowSurrenderConfirmWindow()
    self.tableShiSanZhangView:SetSurrenderConfirmWindow(true);
end

function TableShiSanZhangLogic:RefreshReadyStatus(data)
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (tonumber(seatInfo.playerId) == tonumber(data.pos_info.player_id)) then
            if (data.pos_info.is_ready == 1) then
                self.modelData.curTableData.roomInfo.seatInfoList[i].isReady = true;
            else
                self.modelData.curTableData.roomInfo.seatInfoList[i].isReady = false;
            end
            self.tableShiSanZhangView:refreshSeat(seatInfo);
        end
    end
end

function TableShiSanZhangLogic:GetSeatPositionByID(playerID)
    for key,v in ipairs(self.modelData.curTableData.roomInfo.seatInfoList) do
        if(v.playerId == playerID) then
            local position = self.tableShiSanZhangView:GetSeatPosition(v.localSeatIndex);
            return position;
        end 
    end
end

function TableShiSanZhangLogic:GetLocalSeatIndexByID(playerID)
    for key,v in ipairs(self.modelData.curTableData.roomInfo.seatInfoList) do
        if(v.playerId == playerID) then
            return v.localSeatIndex;
        end 
    end
end

function TableShiSanZhangLogic:RefreshConfirmStatus(data)
    local onFinishCount = 0
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (tonumber(seatInfo.playerId) == tonumber(data.userID)) then
            seatInfo.hasConfirmed = true
            if (seatInfo.localSeatIndex ~= 1) then
                --self.tableShiSanZhangView:SetMatchingActive(seatInfo.localSeatIndex, false);
                self.isPlayingAnimCount = self.isPlayingAnimCount + 1;
                local isAllConfirm = self:isAllConfirmed()
                self.tableShiSanZhangView:playConfirmPokerAnimStep1(seatInfo.localSeatIndex, self.pokersNum, function(...)
                    self.tableShiSanZhangView:playComfirmPokerAnimStep2(seatInfo.localSeatIndex, function(...)
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
end

function TableShiSanZhangLogic:isAllConfirmed()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (seatInfo.playerId and seatInfo.playerId ~= 0 and seatInfo.gameCount > 0 and not seatInfo.hasConfirmed) then
            return false
        end
    end
    return true
end


function TableShiSanZhangLogic:ClearReadyStatus()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        if (seatInfo.playerId ~= nil and seatInfo.playerId ~= 0) then

            if self.isJoinAfterStart == false then
                seatInfo.isReady = false;
                -- TODO XLQ ： 快速组局 中途进入的玩家点击准备后，收到第一局小结算时不需要重新准备
            end

            --  print(self.isJoinAfterStart,"-------------------------seatInfo.playerId:",seatInfo.playerId,seatInfo.isReady)
            self.tableShiSanZhangView:refreshSeat(seatInfo);
        end
    end
end

function TableShiSanZhangLogic:onClicCancelSurrenderBtn(obj)
    self.tableShiSanZhangView:SetSurrenderConfirmWindow(false);
end


function TableShiSanZhangLogic:Reconnect(data)

    gamelogic.setSpecialPaiType(data.gametype or 1)

    self.tablePlayerNum = data.playercnt
    if (tonumber(data.reconnectStatus) == 1) then
        -- if(data.roomInfo.roomHostID == tonumber(self.modelData.roleData.userID)) then
        --     self.tableShiSanZhangView:SetReadyBtn(0);
        -- end
        self:ResetReadyBtn(data)
        return;
    elseif (tonumber(data.reconnectStatus) == 2) then
        self:ResetFastMatch();
        -- 服务器的原始数据
        self.oringinalServerPokers = data.pokers
        self:SetPokersInHand(data.pokers, true, true);
        -- self:SetOthersPokers();
        self:RevertTable(data)
        self:ClearMatchingTable();
        self:ClearXiPaiHint();
        -- self:SetDealBtnActive();
        self.tableShiSanZhangView:HideReadyBtn();
        self.tableShiSanZhangView:SetAllDefaultImageActive(false);
        self.tableShiSanZhangView:SetRuleBtnActive(false);
    elseif (tonumber(data.reconnectStatus) == 3) then
        self:RevertTable(data);
        self.tableShiSanZhangView:HideReadyBtn();
        self.tableShiSanZhangView:SetAllDefaultImageActive(false);
        self.tableShiSanZhangView:ShowSelfResultBackTable();
        self.tableShiSanZhangView:SetRuleBtnActive(false);
    elseif (tonumber(data.reconnectStatus) == 4) then
        local eventData = { };
        eventData.players = data.players;
        eventData.err_no = data.isJoinAfterStart;
        eventData.killedPlayerList = data.killedPlayerList;
        eventData.allKillScore = data.allKillScore
        eventData.spadeAPlayerList = data.spadeAPlayerList;
        eventData.spadeAPlayerID = data.spadeAPlayerID;
        self.tableShiSanZhangView:HideReadyBtn()
        local onFinishPlayStartCompareAnim = function()
            self.tableShiSanZhangView:ShowResultTable();
            self:DealWithResult(eventData);
        end
        self.tableShiSanZhangView:playStartCompareAnim(onFinishPlayStartCompareAnim)
        self.tableShiSanZhangView:SetAllDefaultImageActive(false);
        self.tableShiSanZhangView:SetRuleBtnActive(false);
    elseif (tonumber(data.reconnectStatus) == 5) then
        -- if(data.roomInfo.roomHostID ~=tonumber(self.modelData.roleData.userID)) then
        --    self.tableShiSanZhangView:HideReadyBtn();
        if (data.roomInfo.curRoundNum ~= 0) then
            self.tableShiSanZhangView:SetAllDefaultImageActive(false);
        end
        self.tableShiSanZhangView:SetRuleBtnActive(false);
        -- end
    end
end

function TableShiSanZhangLogic:OnClickInviteBtn(obj)

end

function TableShiSanZhangLogic:onClickReadyBtn(isAutoReady)
    self.tableShiSanZhangModel:request_ready(1, tonumber(self.modelData.roleData.userID));
    if (not isAutoReady and self.modelData.roleData.RoomType ~= 2) then
        self.tableShiSanZhangView:SetReadyBtn(5)
    end
end

function TableShiSanZhangLogic:refreshSelfReadyStatus(isReady)
    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatsInfo do
        if (seatsInfo[i].playerId ~= nil) then
            if (seatsInfo[i].playerId == self.modelData.roleData.userID) then
                seatsInfo[i].isReady = isReady;
                self.tableShiSanZhangView:refreshSeat(seatsInfo[i]);
            end
        end
    end
end

function TableShiSanZhangLogic:SetBtnKickActive(localSeatIndex, isActive)

end

function TableShiSanZhangLogic:onClickCancelBtn(obj)
    self.tableShiSanZhangView:SetReadyCancel(false);
    self.tableShiSanZhangModel:request_ready(0);
end

function TableShiSanZhangLogic:RevertTable(data)
    local seatsInfo = data.seatInfo;
    for i = 1, #seatsInfo do
        local localSeatIndex = self.modelData.curTableData.roomInfo.seatInfoList[seatsInfo[i].seatNum].localSeatIndex;
        if (localSeatIndex ~= 1) then
            self.tableShiSanZhangView:ShowReadyStatus(localSeatIndex, seatsInfo[i].isConfirmed, self.pokersNum);
        end
    end
end


function TableShiSanZhangLogic:GetGameObjectInHandFromColorAndNum(Color, Number)
    for key, v in ipairs(self.handPokers) do
        if (v.colour == Color and v.number == Number) then
            return v.gameObject;
        end
    end
end

function TableShiSanZhangLogic:DelayGettingReady()
    local onFinish = function()

        -- self:onClickReadyBtn()
        -- body
        -- 震动次数太多，先关闭
        -- ModuleCache.GameSDKInterface:ShakePhone(1000)
    end

    if self.tableModule.kickedTimeId then
        CSmartTimer:Kill(self.tableModule.kickedTimeId)
    end
    self.tableShiSanZhangView:DelayToGetReady(onFinish);
end

function TableShiSanZhangLogic:DealWithResult(data)
    local roomData = { };
    roomData.roomInfo = { };
    roomData.roomInfo.roomHostID = self.modelData.curTableData.roomInfo.roomHostID
    roomData.roomInfo.roomStatus = 0;
    self:ClearAllMatchingData()
    if (tonumber(data.err_no) == 0) then
        self.tableShiSanZhangView:ShowResultTable();
    end
    if (tonumber(data.err_no) == 1) then
        self:SetReadyBtnType(roomData);
        self.isJoinAfterStart = true;
    end
    local players = data.players;
    self.resultData = players;
    
    local selfSeatNum;
    local selfPlayer;
    for key, v in ipairs(players) do
        if (tonumber(v.userID) == tonumber(self.modelData.roleData.userID)) then
            selfPlayer = v;
        end
    end
    local onFinishCount = 0
    local onFinish = function()
        onFinishCount = onFinishCount + 1
        if (onFinishCount ~= #players) then
            return
        end
        local oneGameData = {};
        oneGameData.roomInfo = self.modelData.curTableData.roomInfo;
        oneGameData.players = players;
        oneGameData.myPlayerId = tonumber(self.modelData.roleData.userID)
        local balance = self.modelData.curTableData.roomInfo.ruleTable.balance;
        local onFinishKill = function ()

            if(balance == 5 or balance == 3 ) then -- TODO XLQ: 黑a翻倍
                self.tableShiSanZhangView:ShowStats(selfPlayer,1);
            elseif balance == 6 then
                self.tableShiSanZhangView:ShowStats(selfPlayer,2);
            else
                self.tableShiSanZhangView:ShowStats(selfPlayer,0);
            end

            local duration = 1
            if self.modelData.curTableData.shisanzhang_gametype == 2 then
                duration = 0.5
            end

            self.tableModule:subscibe_time_event(1*duration, false, 0):OnComplete( function(t)
                ModuleCache.ModuleManager.show_module("shisanzhang", "onegameresult",oneGameData);
                self:SetReadyBtnType(roomData);
                self.tableShiSanZhangView:ShowReadyBtn()
                self:RefreshCurScore(data);
                self:DelayGettingReady();
            end )
        end


        if (not data.killedPlayerList or (data.killedPlayerList and #data.killedPlayerList == 0 ) )
        and (not data.allKillScore or (data.allKillScore and #data.allKillScore == 0 )) then -- TODO XLQ: 没有打枪 没有通杀
            if (balance == 5 or balance == 3 or  balance == 6) then
                self.tableShiSanZhangView:PlaySpadeAAnim(data.spadeAPlayerList,data.spadeAPlayerID,onFinishKill); -- TODO XLQ: 黑a翻倍
            else
                onFinishKill()  -- TODO:没有黑A 没有打枪 打开结算
            end

        else    -- TODO XLQ: 有打枪或通杀
            --local isDaqiang = false
            if (balance == 5 or balance == 3 or  balance == 6)  then --TODO:XLQ 有黑A 有打枪或通杀
                --isDaqiang = true
                self.tableModule:subscibe_time_event(2.5, false, 0):OnComplete( function(t)
                    self.tableShiSanZhangView:PlayKillAnim(data.killedPlayerList,data.allKillScore,onFinishKill);
                end )


                self.tableShiSanZhangView:PlaySpadeAAnim(data.spadeAPlayerList,data.spadeAPlayerID,function()
                    --if isDaqiang == false and ( balance == 5 or  balance == 3) then
                    --    onFinishKill()
                    --end
                end);

            else
                self.tableShiSanZhangView:PlayKillAnim(data.killedPlayerList,data.allKillScore,onFinishKill);
            end
        end

    end
    
    local isAllSurrender = self:CheckIsAllSurrender(players);
    for key, v in ipairs(players) do
        if (tonumber(v.userID) == tonumber(self.modelData.roleData.userID)) then
            local tmpFunc = function()
                self.tableShiSanZhangView:ShowSelfResult(v, onFinish, isAllSurrender);
                selfSeatNum = v.seatNum;
            end
            if (self.isPlayingAnimCount ~= 0) then
                self.waitPlayingFinishFunsQueue:push(tmpFunc)
            else
                tmpFunc()
            end
        end
    end

    for key, v in ipairs(players) do
        if (tonumber(v.userID) ~= tonumber(self.modelData.roleData.userID)) then
            for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
                if (tonumber(v.userID) == tonumber(self.modelData.curTableData.roomInfo.seatInfoList[i].playerId)) then
                    local tmpFunc = function()
                        local isJoinAfterStart = false;
                        if(self.modelData.curTableData.roomInfo.seatInfoList[i].gameCount == 0) then
                            isJoinAfterStart = true
                        end
                        self.tableShiSanZhangView:ShowOthersResult(v, self.modelData.curTableData.roomInfo.seatInfoList[i].localSeatIndex, onFinish, isAllSurrender,isJoinAfterStart);
                    end
                    if (self.isPlayingAnimCount ~= 0) then
                        self.waitPlayingFinishFunsQueue:push(tmpFunc)
                    else
                        tmpFunc()
                    end
                end
            end
        end
    end

end

function TableShiSanZhangLogic:CheckIsAllSurrender(players)
    local isAllSurrender = true;
    for key, v in ipairs(players) do
        if (not v.isSurrender) then
            isAllSurrender = false;
            return isAllSurrender;
        end
    end
    return isAllSurrender;
end

function TableShiSanZhangLogic:RefreshEnterRoomStatus(data)
    self.tablePlayerNum = data.playercnt
    -- 会收到其他玩家的中途进入包，其他玩家在没准备的情况下中途进入也会影响自己的按钮
    local my_seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[self.modelData.roleData.myRoomSeatInfo.SeatID];
    if self.modelData.roleData.userID == data.seatInfo.userID or(my_seatInfo and not my_seatInfo.isReady and self.modelData.curTableData.roomInfo.curRoundNum == 0) then
        self:ResetReadyBtn()
    end

    print("-------RefreshEnterRoomStatus-----------", self.tablePlayerNum)
    local seatInfo = { };
    seatInfo.seatIndex = data.seatInfo.seatNum;
    seatInfo.playerId = tostring(data.seatInfo.userID)
    seatInfo.gameCount = data.seatInfo.gameCount or 0
    self.tableModule:addSeatInfo2ChatCurTableData(seatInfo)
    if (tonumber(data.seatInfo.userID) == tonumber(self.modelData.curTableData.roomInfo.roomHostID)) then
        seatInfo.isCreator = true;
    else
        seatInfo.isCreator = false;
    end
    if (data.seatInfo.readyStatus == 1) then
        seatInfo.isReady = true;
    else
        seatInfo.isReady = false;
    end
    seatInfo.hasConfirmed = data.isConfirmed;
    seatInfo.isTemporaryLeave = data.isTemporaryLeave;
    seatInfo.canBeKicked = false;
    if(tonumber(self.modelData.roleData.userID) == self.modelData.curTableData.roomInfo.roomHostID) then
        if(seatInfo.playerId ~= self.modelData.curTableData.roomInfo.roomHostID and seatInfo.gameCount == 0) then
            seatInfo.canBeKicked = true;
        end
    end    
    seatInfo.curScore = data.seatInfo.curScore;
    -- 玩家房间内积分
    -- seatInfo.winTimes = (seatInfo.isSeated and remoteSeatInfo.winTimes) or 0             --玩家房间内赢得次数
    -- seatInfo.isOffline = (not seatInfo.isSeated) or remoteSeatInfo.isOffline ~= 0      --玩家是否掉线

    -- seatInfo.isDoneComputeNiu = false			            --玩家是否已经完成选牛
    -- seatInfo.isCalculatedResult = false                     --是否已经结算
    seatInfo.roomInfo = data.roomInfo;
    seatInfo.localSeatIndex = self.tableShiSanZhangHelper:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex, #self.modelData.curTableData.roomInfo.seatInfoList)
    self.modelData.curTableData.roomInfo.seatInfoList[seatInfo.seatIndex] = seatInfo;
    -- table.insert(self.modelData.curTableData.roomInfo.seatInfoList,seatInfo);
    -- self.modelData.curTableData.roomInfo.seatInfoList = seatsInfo;
    self:resetSeatHolderArray(#self.modelData.curTableData.roomInfo.seatInfoList);
    self.tableShiSanZhangView:refreshSeat(seatInfo);
end

function TableShiSanZhangLogic:onClicPoer(obj)
    local x = 1;
end

--- 点击配牌窗口
--- @param index 配牌选项
--- @param isFastMatching 是否为快速配牌，也就是推荐配牌
function TableShiSanZhangLogic:onClickMatching(index, isFastMatching)
    local fullIndex = 0;
    if (#self.modelData.FirstMatching ~= 0) then
        fullIndex = 1;
    elseif (#self.modelData.SecondMatching ~= 0) then
        fullIndex = 2;
    elseif (#self.modelData.ThirdMatching ~= 0) then
        fullIndex = 3;
    end
    local selectNum = #self.modelData.selectList;
    if(index == 1) then
        selectNum = selectNum + 2;
    end
    if selectNum ~= 5 then
        -- body
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("选牌数量错误！")
        return;
    end

    if (index == 1) then
        if (#self.modelData.FirstMatching ~= 0) then
            return;
        end
        for key, v in ipairs(self.modelData.selectList) do
            v.showed = false;
            v.selected = false;
            local poker = { };
            poker.number = v.number;
            poker.Number = v.Number;
            poker.colour = v.colour;
            poker.Color = v.Color;
            poker.showed = v.showed;
            poker.selected = v.selected;
            poker.gameObject = v.gameObject;
            poker.image = v.image;
            table.insert(self.modelData.FirstMatching, poker);
            for k, value in ipairs(self.handPokers) do
                if (v.number == value.number and v.colour == value.colour) then
                    table.remove(self.handPokers, k);
                end
            end
            -- self.tableShiSanZhangView:setInHandPokerActive(v, false);
        end
        if(self.specialType == 0) then
            self:sortPoker(self.modelData.FirstMatching, false);
        end
        print_table(self.modelData.selectList)
        print_table(self.handPokers)
        self:SetPokersInHand(self.handPokers, false, self.sortSequence);
        if (fullIndex == 0) then
            -- self:check_handpokers_in_oringinalPokers(self.modelData.FirstMatching);
            self.tableShiSanZhangView:setMatchingShow(index, self.modelData.FirstMatching, 0, true);
        else
            -- self:check_handpokers_in_oringinalPokers(self.modelData.FirstMatching);
            self.tableShiSanZhangView:setMatchingShow(index, self.modelData.FirstMatching, 0, false);
        end
        self.modelData.selectList = { };
        self.tableShiSanZhangView:SetResetBtnActive(1, true);
        self.tableShiSanZhangView:SetNoPokersImageActive(1, false);
        self.tableShiSanZhangView:ShowMatchingShow(1);
        local res, value = gamelogic.ComputePaixing(self.modelData.FirstMatching, self.mask)
        self.tableShiSanZhangView:SetPokerTypeHint(1, res);
    elseif (index == 2) then
        -- if not self.modelData.FirstMatching or #self.modelData.FirstMatching ~= 3 then
        -- return;
        -- end
        if (#self.modelData.SecondMatching ~= 0) then
            return;
        end
        for key, v in ipairs(self.modelData.selectList) do
            v.showed = false;
            v.selected = false;
            local poker = { };
            poker.number = v.number;
            poker.Number = v.Number;
            poker.colour = v.colour;
            poker.Color = v.Color;
            poker.showed = v.showed;
            poker.selected = v.selected;
            poker.gameObject = v.gameObject;
            poker.image = v.image;
            table.insert(self.modelData.SecondMatching, poker);
            for k, value in ipairs(self.handPokers) do
                if (v.number == value.number and v.colour == value.colour) then
                    table.remove(self.handPokers, k);
                end
            end
        end
        if(self.specialType == 0) then
            self:sortPoker(self.modelData.SecondMatching, false);
        end
        
        self:SetPokersInHand(self.handPokers, false, self.sortSequence);
        if (fullIndex == 0) then
            -- self:check_handpokers_in_oringinalPokers(self.modelData.SecondMatching);
            self.tableShiSanZhangView:setMatchingShow(index, self.modelData.SecondMatching, 0, true);
        else
            -- self:check_handpokers_in_oringinalPokers(self.modelData.SecondMatching);
            self.tableShiSanZhangView:setMatchingShow(index, self.modelData.SecondMatching, 0, false);
        end
        self.modelData.selectList = { };
        self.tableShiSanZhangView:SetResetBtnActive(2, true);
        self.tableShiSanZhangView:SetNoPokersImageActive(2, false);
        self.tableShiSanZhangView:ShowMatchingShow(2);
        local res, value = gamelogic.ComputePaixing(self.modelData.SecondMatching, self.mask)
        self.tableShiSanZhangView:SetPokerTypeHint(2, res);
    elseif (index == 3) then
        if (#self.modelData.ThirdMatching ~= 0) then
            return;
        end
        for key, v in ipairs(self.modelData.selectList) do
            v.showed = false;
            v.selected = false;
            local poker = { };
            poker.number = v.number;
            poker.Number = v.Number;
            poker.colour = v.colour;
            poker.Color = v.Color;
            poker.showed = v.showed;
            poker.selected = v.selected;
            poker.gameObject = v.gameObject;
            poker.image = v.image;
            table.insert(self.modelData.ThirdMatching, poker);
            for k, value in ipairs(self.handPokers) do
                if (v.number == value.number and v.colour == value.colour) then
                    table.remove(self.handPokers, k);
                end
            end
        end
        if(self.specialType == 0) then
            self:sortPoker(self.modelData.ThirdMatching, false);
        end
        
        self:SetPokersInHand(self.handPokers, false, self.sortSequence);
        if (fullIndex == 0) then
            -- self:check_handpokers_in_oringinalPokers(self.modelData.ThirdMatching);
            self.tableShiSanZhangView:setMatchingShow(index, self.modelData.ThirdMatching, 0, true);
        else
            -- self:check_handpokers_in_oringinalPokers(self.modelData.ThirdMatching);
            self.tableShiSanZhangView:setMatchingShow(index, self.modelData.ThirdMatching, 0, false);
        end
        self.modelData.selectList = { };
        self.tableShiSanZhangView:SetResetBtnActive(3, true);
        self.tableShiSanZhangView:SetNoPokersImageActive(3, false);
        self.tableShiSanZhangView:ShowMatchingShow(3);
        local res, value = gamelogic.ComputePaixing(self.modelData.ThirdMatching, self.mask)
        self.tableShiSanZhangView:SetPokerTypeHint(3, res);
    end

    -- 不是快速配牌
    local emptyNum = 0;
    if(#self.modelData.FirstMatching == 0) then
        emptyNum = emptyNum + 1;
    end
    
    if(#self.modelData.SecondMatching == 0) then
        emptyNum = emptyNum + 1;
    end
    
    if(#self.modelData.ThirdMatching == 0) then
        emptyNum = emptyNum + 1;
    end
    if (not isFastMatching and emptyNum == 1 and self.pokersNum == 13) then
        -- 出现大BUG了，因为最后的手牌不是3张了
        if self.handPokers and #self.handPokers ~= 5 and #self.modelData.FirstMatching ~= 0 then
            if self.modelData.bullfightClient.clientConnected then
                TableManagerPoker:heartbeat_timeout_reconnect_game_server()
                return
            end
        elseif(self.handPokers and #self.handPokers ~= 3 and #self.modelData.FirstMatching == 0) then
            if self.modelData.bullfightClient.clientConnected then
                TableManagerPoker:heartbeat_timeout_reconnect_game_server()
                return
            end
        end
        local onFinish = function()
            -- self:LocalCheckSequence();
        end
        if (#self.modelData.FirstMatching == 0) then
            -- self.modelData.FirstMatching = self.handPokers;
            local count = 0;
            for key, v in ipairs(self.handPokers) do
                v.showed = false;
                v.selected = false;
                local poker = { };
                poker.number = v.number;
                poker.Number = v.Number;
                poker.colour = v.colour;
                poker.Color = v.Color;
                poker.showed = v.showed;
                poker.selected = v.selected;
                poker.gameObject = v.gameObject;
                poker.image = v.image;
                table.insert(self.modelData.FirstMatching, poker);
                local _index = tonumber(v.gameObject.name) + 1;
                self.tableShiSanZhangView:PlayAnimHandToMatch(_index, 1, count + 1, onFinish);
                count = count + 1;
                -- self.tableShiSanZhangView:setInHandPokerActive(v, false);
            end
            if(self.specialType == 0) then
                self:sortPoker(self.modelData.FirstMatching, false);
            end
            
            -- self:check_handpokers_in_oringinalPokers(self.modelData.FirstMatching);
            self.tableShiSanZhangView:setMatchingShow(1, self.modelData.FirstMatching, 0, false);
            self.tableShiSanZhangView:SetResetBtnActive(1, true);
            self.tableShiSanZhangView:SetNoPokersImageActive(1, false);
            self.tableShiSanZhangView:ShowMatchingShow(1);
            local res, value = gamelogic.ComputePaixing(self.modelData.FirstMatching, self.mask)
            self.tableShiSanZhangView:SetPokerTypeHint(1, res);
        end
        if (#self.modelData.SecondMatching == 0) then
            -- self.modelData.SecondMatching = self.handPokers;
            local count = 0;
            for key, v in ipairs(self.handPokers) do
                v.showed = false;
                v.selected = false;
                local poker = { };
                poker.number = v.number;
                poker.Number = v.Number;
                poker.colour = v.colour;
                poker.Color = v.Color;
                poker.showed = v.showed;
                poker.selected = v.selected;
                poker.gameObject = v.gameObject;
                poker.image = v.image;
                table.insert(self.modelData.SecondMatching, poker);
                local _index = tonumber(v.gameObject.name) + 1;
                self.tableShiSanZhangView:PlayAnimHandToMatch(_index, 2, count + 1, onFinish);
                count = count + 1;
                -- self.tableShiSanZhangView:setInHandPokerActive(v, false);
            end
            if(self.specialType == 0) then
                self:sortPoker(self.modelData.SecondMatching, false);
            end
            
            -- self:check_handpokers_in_oringinalPokers(self.modelData.SecondMatching);
            self.tableShiSanZhangView:setMatchingShow(2, self.modelData.SecondMatching, 0, false);
            self.tableShiSanZhangView:SetResetBtnActive(2, true);
            self.tableShiSanZhangView:SetNoPokersImageActive(2, false);
            self.tableShiSanZhangView:ShowMatchingShow(2);
            local res, value = gamelogic.ComputePaixing(self.modelData.SecondMatching, self.mask)
            self.tableShiSanZhangView:SetPokerTypeHint(2, res);
        end
        if (#self.modelData.ThirdMatching == 0) then
            -- self.modelData.ThirdMatching = self.handPokers;
            local count = 0;
            for key, v in ipairs(self.handPokers) do
                v.showed = false;
                v.selected = false;
                local poker = { };
                poker.number = v.number;
                poker.Number = v.Number;
                poker.colour = v.colour;
                poker.Color = v.Color;
                poker.showed = v.showed;
                poker.selected = v.selected;
                poker.gameObject = v.gameObject;
                poker.image = v.image;
                table.insert(self.modelData.ThirdMatching, poker);
                local _index = tonumber(v.gameObject.name) + 1;
                self.tableShiSanZhangView:PlayAnimHandToMatch(_index, 3, count + 1, onFinish);
                count = count + 1;
                -- self.tableShiSanZhangView:setInHandPokerActive(v, false);
            end
            if(self.specialType == 0) then
                self:sortPoker(self.modelData.ThirdMatching, false);
            end
            
            -- self:check_handpokers_in_oringinalPokers(self.modelData.ThirdMatching);
            self.tableShiSanZhangView:setMatchingShow(3, self.modelData.ThirdMatching, 0, false);
            self.tableShiSanZhangView:SetResetBtnActive(3, true);
            self.tableShiSanZhangView:SetNoPokersImageActive(3, false);
            self.tableShiSanZhangView:ShowMatchingShow(3);
            local res, value = gamelogic.ComputePaixing(self.modelData.ThirdMatching, self.mask)
            self.tableShiSanZhangView:SetPokerTypeHint(3, res);
        end
        self.handPokers = { };
    end




    if (self.modelData.FirstMatching == nil or self.modelData.SecondMatching == nil or self.modelData.ThirdMatching == nil) then
        return;
    end

    if (#self.modelData.FirstMatching == 3 and #self.modelData.SecondMatching == 5 and #self.modelData.ThirdMatching == 5) then
        local pokers = { };
        for key, v in ipairs(self.modelData.FirstMatching) do
            local poker = { };
            poker.Color = v.colour;
            poker.Number = v.number;
            table.insert(pokers, poker);
        end
        for key, v in ipairs(self.modelData.SecondMatching) do
            local poker = { };
            poker.Color = v.colour;
            poker.Number = v.number;
            table.insert(pokers, poker);
        end
        for key, v in ipairs(self.modelData.ThirdMatching) do
            local poker = { };
            poker.Color = v.colour;
            poker.Number = v.number;
            table.insert(pokers, poker);
        end
        local curMatching;
        for i = 1, 3 do
            if (i == 1) then
                curMatching = self.modelData.FirstMatching
            elseif (i == 2) then
                curMatching = self.modelData.SecondMatching
            elseif (i == 3) then
                curMatching = self.modelData.ThirdMatching
            end
            local res, value = gamelogic.ComputePaixing(curMatching, self.mask)
            self.tableShiSanZhangView:SetPokerTypeHint(i, res);
        end
        if(self.specialType == 0) then
            local isNeedToChange = self:LocalCheckSequence();
            if (isNeedToChange) then
                self.tableModule:subscibe_time_event(3, false, 0):OnComplete( function(t)
                    if (#self.handPokers > 0) then
                        return;
                    end
                    self.tableShiSanZhangView:SetExchangeHintActive(true);
                end )
            else
                self.tableShiSanZhangView:SetExchangeHintActive(true);
            end;
        end
        
        -- 0.1s后再显示重制和确定按钮
        self.tableShiSanZhangView:SetResetAllActive(true);
        -- self.tableModule:subscibe_time_event(0.2, false, 0):OnComplete(function(t)
        -- self.tableShiSanZhangView:SetResetAllActive(true);
        -- end)
        if (self.pokersNum == 10) then
            if (#self.handPokers ~= 1) then
                print_table(self.handPokers);
                print("手牌数出错");
                return;
            end
            self.tableShiSanZhangView:Set10thPokersActive(true);
            local poker = { }
            self.handPokers[1].showed = false;
            self.handPokers[1].selected = false;
            local poker = { };
            poker.number = self.handPokers[1].number;
            poker.Number = self.handPokers[1].Number;
            poker.colour = self.handPokers[1].colour;
            poker.Color = self.handPokers[1].Color;
            poker.showed = self.handPokers[1].showed;
            poker.selected = self.handPokers[1].selected;
            poker.gameObject = self.handPokers[1].gameObject;
            poker.image = self.handPokers[1].image;
            self.handPokers = { };
            self.tenthPoker = poker;
            self.tableShiSanZhangView:Show10thPokerImage(self.tenthPoker);
            self:SetPokersInHand(self.handPokers, false);
        end
        -- self.tableShiSanZhangModel:request_complete_match(pokers , self.modelData.roleData.userID);
    end
    self:SetDealBtnActive();
end
-- 大小排序，true为大到小 flagSequence为false时是按大小排序，为true时按照花色排序
function TableShiSanZhangLogic:sortPoker(poker, flag, flagSequence)
    if poker and #poker == 0 then
        return
    end
    self:check_handpokers_in_oringinalPokers(poker);
    -- log_table(poker)
    for i = 1, #poker - 1 do
        local index = i
        for j = i, #poker do
            local num1, num2
            if not flagSequence then
                num1 = poker[j].Number * 4 + poker[j].Color
                num2 = poker[index].Number * 4 + poker[index].Color
            else
                if poker[j].Number == 15 then
                    num1 = poker[j].Number +(poker[j].Color + 4) * 14
                else
                    num1 = poker[j].Number + poker[j].Color * 14
                end
                if poker[index].Number == 15 then
                    num2 = poker[index].Number +(poker[index].Color + 4) * 14
                else
                    num2 = poker[index].Number + poker[index].Color * 14
                end
            end
            if (flag and num1 > num2) or(not flag and num1 < num2) then
                index = j
            end
        end
        local temp = poker[index]
        poker[index] = poker[i]
        poker[i] = temp
    end
    self:check_handpokers_in_oringinalPokers(poker)
end

function TableShiSanZhangLogic:onClickOrderBtn(isSequence)
    self.sortSequence = isSequence;
    self:SetPokersInHand(self.handPokers, false, self.sortSequence);
    self.tableShiSanZhangView:SetOrderSequenceActive(isSequence);
end
-- 点击对子，顺子，同花等按钮
function TableShiSanZhangLogic:onClickDealBtn(btnname)
    local _typepokers = self:setTypePokers(btnname);
    if not _typepokers or #_typepokers ~= 5 then
        return;
    end

    if #self.modelData.selectList <= 5 then
        for key, v in ipairs(self.modelData.selectList) do
            v.selected = false;
            self.tableShiSanZhangView:refreshCardSelect(v, false);
        end
    end
    self.modelData.selectList = { };
    local _pokers = self.handPokers;
    for key, v in ipairs(_typepokers) do
        for _key1, v1 in ipairs(_pokers) do
            if v.number == v1.number and v.colour == v1.colour then
                v1.selected = true;
                table.insert(self.modelData.selectList, v1);
                self.tableShiSanZhangView:refreshCardSelect(v1, true);
                break;
            end
        end
    end

end

function TableShiSanZhangLogic:ResetFastMatch()
    self.fastMatches = nil;
end

function TableShiSanZhangLogic:SetFastMatching()
    for i = 1, 3 do
        if (self.fastMatches[i] ~= nil) then 
            if(self.fastMatches[i].XiPaiType == 0) then
                local matches = { }
                for j = 1, 3 do
                    table.insert(matches, self.fastMatches[i][j].px);
                end
                print_table(matches)
                self.tableShiSanZhangView:SetFastMatchingHint(i, matches,0)
            else
                self.tableShiSanZhangView:SetFastMatchingHint(i, nil, self.fastMatches[i].XiPaiType)
            end
        end
    end
end

function TableShiSanZhangLogic:onClickSuggestionBtn(index)
    -- self:onClickResetAllBtn();
    self.modelData.FirstMatching = { }
    self.modelData.SecondMatching = { }
    self.modelData.ThirdMatching = { }
    local pokers = self.oringinalPokers;
    self.specialType = self.fastMatches[index].XiPaiType;
    -- print_table(self.fastMatches);
    for i = 1, 3 do
        self.modelData.selectList = { }
        local indexMax = 5;
        if(i == 1) then
            indexMax = 3;
        end
        for j = 1, indexMax do
            local poker = { };
            for key, v in ipairs(pokers) do
                if (self.fastMatches[index][i][j].Color == v.Color and self.fastMatches[index][i][j].Number == v.Number) then
                    poker = v;
                    -- print_table(poker);
                end
            end
            table.insert(self.modelData.selectList, poker);
        end
        self:onClickMatching(i, true);
    end
    self:SetPokersInHand( { }, false);
    self.tableShiSanZhangView:SetSelectedSuggestion(index);
    if (#self.exchangePoker > 0) then
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        self.tableShiSanZhangView:SetExchangePokerColor(oldIndexMatch, oldIndex, false)
        self.exchangePoker = { };
    end
    
end

function TableShiSanZhangLogic:OnClickSpecialTypeConfirm()
    local callback = self.funcSubmitSpecialType;
    callback();
end

function TableShiSanZhangLogic:OnClickSpecialTypeCancel()
    self.tableShiSanZhangView.winSpecialType:SetActive(false);
    self.tableShiSanZhangView.TransMatching.gameObject:SetActive(true)
end

-- 设置整个牌的界面显示
function TableShiSanZhangLogic:SetDealBtnActive(isFirst)
    local _restpokers = { };
    local pokers = { };
    self._paixing = { };
    local gpai = { }
    -- 手上的牌
    for key, v in ipairs(self.handPokers) do
        local poker = { };
        poker.Number = v.number;
        poker.Color = tonumber(v.colour);
        poker.number = v.number;
        poker.colour = tonumber(v.colour);
        table.insert(pokers, poker);
    end
    local _pokers = pokers;
    self:sortPoker(_pokers, false);
    for key, v in ipairs(_pokers) do
        if (not v.showed) then
            table.insert(_restpokers, v);
        end
    end
    if (true) then
        self.restcount = #_restpokers;
        self.btnname = "";
        local combinations = { };
        gamelogic.CombinePoker(_restpokers,combinations,gpai)
        gamelogic.Classification(combinations,self._paixing)
        
        if (self.fastMatches == nil and #_pokers == self.pokersNum) then
            self.fastMatches=gamelogic.GenerateHBT(_pokers,gpai)
            --XiPaiType
        end
        if(false) then
            local text = self:GetStrPokerType(xipai[1].XiPaiType)
            self.tableShiSanZhangView.winSpecialType:SetActive(true)
            self.tableShiSanZhangView.TransMatching.gameObject:SetActive(false)
            self.tableShiSanZhangView:SetSpecialTypeText(text);
            self.funcSubmitSpecialType = function ()
                local pokers = {}
                for i = 1, 3 do
                    local indexMax = 5;
                    if(i == 1) then
                        indexMatch = 3;
                    end
                    for j = 1, indexMax do
                        table.insert(pokers,xipai[1][i][j] )
                    end
                end
                self.tableShiSanZhangModel:request_submit(pokers, self.modelData.roleData.userID,xipai[1].XiPaiType);
    -- self.tableShiSanZhangView:SetConfirmWindowActive(false);
                self.tableShiSanZhangView:SetDealWindowActive(false);
                self.tableShiSanZhangView:SetSelfImageActive(true);
                self.tableShiSanZhangView:SetClockActive(false);
                self.tableShiSanZhangView:ShowSelfResultBackTable();
                self:SetMatchingStatus();
                local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
                for key, v in ipairs(seatInfoList) do
                    if (not v.hasConfirmed) then
                        if (v.playerId ~= 0 and v.playerId ~= nil and v.localSeatIndex ~= 1 and v.localSeatIndex ~= nil and v.gameCount ~= 0) then
                            self.tableShiSanZhangView:ShowOthersPokerBack(v.localSeatIndex, false, self.pokersNum)
                        end
                    end
                end
            end
            --ModuleCache.ModuleManager.show_public_module("alertdialog"):show_confirm_cancel_titile("特殊牌型","<size=32>获得特殊牌型<color=#b13a1f>("..text..")</color>是否选择不参与三道牌的比牌？</size>\n\n\n<size=25><color=#b13a1f>(确定将不参与普通牌的比较，直接得分)</color></size>", function()
                
            --end , nil)
        else
            self.tableShiSanZhangView.TransMatching.gameObject:SetActive(true)
        end
        -- 散牌 1 对子 2 两对 3 三条 4 顺子 5 同花 6 葫芦 7 四条 8 同花顺 9  
        -- 对子
        if (#self._paixing[1] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(1, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(1, true);
        end

        -- 顺子
        if (#self._paixing[2] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(2, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(2, true);
        end
        if (#self._paixing[3] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(3, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(3, true);
        end
        if (#self._paixing[4] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(4, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(4, true);
        end
        if (#self._paixing[5] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(5, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(5, true);
        end
        if (#self._paixing[6] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(6, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(6, true);
        end
        if (#self._paixing[7] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(7, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(7, true);
        end
        if (#self._paixing[8] == 0) then
            self.tableShiSanZhangView:SetDealBtnActive(8, false);
        else
            self.tableShiSanZhangView:SetDealBtnActive(8, true);
        end
        --if (#_paixing[5] == 0) then
            --self.tableShiSanZhangView:SetDealBtnActive(5, false);
        --else
            --self.tableShiSanZhangView:SetDealBtnActive(5, true);
        --end
    end
    -- local _typepokers = self:setTypePokers(btnname);
end

function TableShiSanZhangLogic:ClearXiPaiHint()
    self.tableShiSanZhangView:ShowXiPai("");
end

function TableShiSanZhangLogic:ClearMatchingTable()
    self.modelData.FirstMatching = { };
    self.modelData.SecondMatching = { };
    self.modelData.ThirdMatching = { };
    for i = 1, 3 do
        self.tableShiSanZhangView:ClearMatchingShow(i);
        self.tableShiSanZhangView:SetResetBtnActive(i, false);
        self.tableShiSanZhangView:SetNoPokersImageActive(i, true);
        self.tableShiSanZhangView:ClearPaiXingHint(i);
    end
    self.tableShiSanZhangView:ClearFastMatchingHint();
    self.tableShiSanZhangView:ClearSelectedSuggestion();
    self.tableShiSanZhangView:SetGameLogoActive(0, false);
    self.tableShiSanZhangView:SetErrHintActive(false);
    self.tableShiSanZhangView:SetExchangeHintActive(false);
    self.tableShiSanZhangView:Set10thPokersActive(false);
    self.tableShiSanZhangView.TransMatching.gameObject:SetActive(false);
    self.tableShiSanZhangView.winSpecialType:SetActive(false)

end

function TableShiSanZhangLogic:ShowReadyTable()
    self.tableShiSanZhangView:ShowReadyBtn();
end

function TableShiSanZhangLogic:setTestPokers()
    math.randomseed(os.time())
    local type = math.random(0, 1)
    if (type < 0.5) then
        self:onClickSuggestionBtn(1);
    else
        for i = 1, 2 do
            local randomList = self:getRandomList(9 -(i - 1) * 3);
            for j = 1, 3 do
                local index = randomList[j];
                local pokerGameObject = self.tableShiSanZhangView.inHandPokers[index]["gameobject"].transform:GetChild(0).gameObject
                self:on_select_poker(pokerGameObject);
            end
            self:onClickMatching(i, false);
        end
    end
end

function TableShiSanZhangLogic:getRandomList(length)
    local temp = { };
    local chosen_list = { };
    for i = 1, length do
        table.insert(chosen_list, i)
    end
    for i = 1, length do
        local r = math.random(1, #chosen_list);
        temp[i] = chosen_list[r];
        table.remove(chosen_list, r);
    end
    return temp
end


--- SetPokersInHand
--- @param handPokers
--- @param isFirst true代表新发牌
--- @param isSequence 为false时是按大小排序，为true时按照花色排序
function TableShiSanZhangLogic:SetPokersInHand(handPokers, isFirst, isSequence)
    self:check_handpokers_in_oringinalPokers(handPokers)
    self.tableShiSanZhangView:SetDealWindowActive(true);
    if (self.modelData ~= nil) then
        -- self.modelData.curTableData = {};
        self.modelData.selectList = { };
    end
    self.handPokers = { };
    if (isFirst) then
        self.specialType = 0;
        self:ClearAllMatchingData()
        self.oringinalPokers = { };
    end
    for j = 1, #handPokers do
        local poker = { }
        -- local tmp = string.split(remoteSeatInfo.pokers[i], "-")
        poker.colour = handPokers[j].Color;
        poker.number = tonumber(handPokers[j].Number);
        poker.Color = handPokers[j].Color;
        poker.Number = tonumber(handPokers[j].Number);
        poker.selected = false;
        poker.showed = false;
        table.insert(self.handPokers, poker);
        if (isFirst) then
            table.insert(self.oringinalPokers, poker);
        end
    end
    self:sortPoker(self.handPokers,true,self.sortSequence)

    if (isFirst) then
        if ModuleCache.GameManager.isEditor then
            --self:TestAllPokersArrange(self.oringinalPokers)
        end
        self.pokersInDesc = { };
        local duration = 0.25;
        local onFinish = function()
            self:SetDealBtnActive();
            self:SetFastMatching();
            -- if (ModuleCache.GameManager.isEditor and ModuleCache.GameManager.developmentMode) then
            -- self:setTestPokers();
            -- local reset = math.random( 0,2 );
            -- if(reset > 1) then
            -- self:onClickResetAllBtnNew();
            -- self:setTestPokers();
            -- end
            -- local time = math.random(0,3)
            -- self.tableModule:subscibe_time_event(time, false, 0):OnComplete(function(t)
            -- self:onClickSubmitConfirmBtn()
            -- end)
            -- end
        end
        self:sortPoker(self.oringinalPokers, true, self.sortSequence);
        for key, v in ipairs(self.oringinalPokers) do
            table.insert(self.pokersInDesc, v);
        end
        self:sortPoker(self.pokersInDesc, false);
        print(gamelogic);
        --local gamelogic = require("package.shisanzhang.module.tableshisanzhang.gamelogic")
        self.mask = gamelogic.PokerToMask(self.pokersInDesc);
        self.tableShiSanZhangView:SetSelfImageActive(false);
        self:check_handpokers_in_oringinalPokers(self.oringinalPokers)

        self.tableShiSanZhangView:refreshPokersInHand(self.handPokers, isFirst, onFinish);
        self.tableShiSanZhangView:SetClockActive(true);
        self.tableShiSanZhangView:StartClockCountdown(60);
        self.tableShiSanZhangView:SetOrderSequenceActive(self.sortSequence);
    else
        self:check_handpokers_in_oringinalPokers(self.handPokers)

        self.tableShiSanZhangView:refreshPokersInHand(self.handPokers, isFirst);
    end
    local _index = 1;
    for key, v in ipairs(self.handPokers) do
        v.gameObject = self.tableShiSanZhangView.inHandPokers[_index]["gameobject"];
        v.image = self.tableShiSanZhangView.inHandPokers[_index]["image"];
        self.tableShiSanZhangView:refreshCardSelect(v);
        _index = _index + 1;
        if (isFirst) then
            self.isJoinAfterStart = false;
        end
    end
    -- self.handPokers = {};
    -- for key, v in ipairs(self.inHandPokerList) do
    -- table.insert(self.handPokers, v);
    -- end

    -- self:check_handpokers_in_oringinalPokers(self.handPokers)
    if (not isFirst) then
        self:SetDealBtnActive();
    end
    -- self.tableShiSanZhangView:refreshSeat(seatList[i]);
end

function TableShiSanZhangLogic:set_oringinalServerPokers(pokers)
    self.oringinalServerPokers = { }
    for i = 1, #pokers do
        self.oringinalServerPokers[i] = { }
        self.oringinalServerPokers[i].Color = pokers[i].Color
        self.oringinalServerPokers[i].Number = pokers[i].Number
    end
end

-- 新增牌的检测，因为遇到过有重复拍的问题
function TableShiSanZhangLogic:check_handpokers_in_oringinalPokers(needCheckPokers)
    if not needCheckPokers then
        print("needCheckPokers is nil")
        return
    end

    local inOringinalPokers = true
    -- self.handPokers[10] = {}
    -- needCheckPokers[9].Number = needCheckPokers[1].Number
    -- needCheckPokers[9].Color = needCheckPokers[1].Color
    if #needCheckPokers < 14 then
        -- self.handPokers[1].Number = 12
        -- self.handPokers[1].Color = 1
        local handPokersCount = { }
        local keyTmp = nil
        for i = 1, #needCheckPokers do
            -- 需要过滤重复的牌
            keyTmp = needCheckPokers[i].Number .. "_" .. needCheckPokers[i].Color
            handPokersCount[keyTmp] =(handPokersCount[keyTmp] or 0) + 1
            if handPokersCount[keyTmp] > 1 then
                inOringinalPokers = false
                break
            end

            for j = 1, #self.oringinalServerPokers do
                if needCheckPokers[i].Color == self.oringinalServerPokers[j].Color and needCheckPokers[i].Number == self.oringinalServerPokers[j].Number then
                    inOringinalPokers = true
                    break
                else
                    inOringinalPokers = false
                end
            end
        end
    else
        inOringinalPokers = false
    end


    if #needCheckPokers > 0 and not inOringinalPokers then
        if ModuleCache.GameManager.isEditor then
            ModuleCache.GameSDKInterface:PauseEditorApplication(true)
        else
            ModuleCache.GameManager.logout()
        end
        print_table(needCheckPokers, "牌型数据错误，触发断线重连")
        ModuleCache.GameSDKInterface:BuglyPrintLog(5, "牌型数据错误，触发断线重连")
        if self.oringinalServerPokers then
            log_table(self.oringinalServerPokers)
            log_table(needCheckPokers)
        end
        -- 故意设置错误代码好上报Bugly
        local test = kjkd > 0
    end
end

function TableShiSanZhangLogic:onClickStartBtn(obj)
    self.startBtn = obj;
    self.tableShiSanZhangModel:request_start();
    self.tableShiSanZhangView:CloseResultTable();
    -- self.tableShiSanZhangView:ShowDealTable();
    -- obj.transform.parent.gameObject:SetActive(false);
end

-- 根据点击提示按钮设置牌型提示
function TableShiSanZhangLogic:setTypePokers(name)
    local _restpokers = { };
    local _pokers = self.handPokers;
    
    local gpai = { }
    for key, v in ipairs(_pokers) do
        if (not v.showed) then
            table.insert(_restpokers, v);
        end
    end

    if (self.restcount ~= #_restpokers) then
    --if (true) then
        self.restcount = #_restpokers;
        self.btnname = "";
        local combinations = { };
        self._paixing = {};
        gamelogic.CombinePoker(_restpokers, combinations, gpai);
        
        gamelogic.Classification(combinations,_paixing)
    end
    if self.btnname ~= name then
        self.selectindex = 1;
        self.btnname = name;
    else
        self.selectindex = self.selectindex + 1;
    end

    if name == "pair" then
        local _count = #self._paixing[1];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[1][self.selectindex];
        else
            return nil;
        end
    elseif name == "doublepair" then
        local _count = #self._paixing[2];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[2][self.selectindex];

        else
            return nil;
        end
    elseif name == "threeofakind" then
        local _count = #self._paixing[3];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[3][self.selectindex];

        else
            return nil;
        end
    elseif name == "straight" then
        local _count = #self._paixing[4];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[4][self.selectindex];

        else
            return nil;
        end
    elseif name == "flush" then
        local _count = #self._paixing[5];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[5][self.selectindex];

        else
            return nil;
        end
    elseif name == "gourd" then
        local _count = #self._paixing[6];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[6][self.selectindex];

        else
            return nil;
        end
    elseif name == "fourofakind" then
        local _count = #self._paixing[7];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[7][self.selectindex];

        else
            return nil;
        end
    elseif name == "straightflush" then
        local _count = #self._paixing[8];
        if (_count ~= 0) then
            if self.selectindex > _count then
                self.selectindex = 1;
            end
            return self._paixing[8][self.selectindex];

        else
            return nil;
        end
    end
end



function TableShiSanZhangLogic:onClickConfirmNotReadyBtn(obj)
    self.tableShiSanZhangView:CloseNotReadyWindow();
end

function TableShiSanZhangLogic:convertMaskCode(ruleTable)
    local mask = ruleTable.extraScoreTypes or 15
    self.extraScoreTypes = ruleTable.extraScoreTypes;
    self.maskXiPai = { }
    for i = 1, 11 do
        self.maskXiPai[i] = false
    end
    if mask % 2 == 1 then
        self.maskXiPai[5] = true
        self.maskXiPai[7] = true
        self.maskXiPai[10] = true
        self.maskXiPai[11] = true
    end
    if (math.floor(mask / 2)) % 2 == 1 then
        self.maskXiPai[1] = true
        self.maskXiPai[8] = true
        self.maskXiPai[9] = true
    end
    if (math.floor(mask / 4)) % 2 == 1 then
        self.maskXiPai[4] = true
        self.maskXiPai[6] = true
    end
    if (math.floor(mask / 8)) % 2 == 1 then
        self.maskXiPai[2] = true
        self.maskXiPai[3] = true
    end
end

function TableShiSanZhangLogic:on_table_start_notify(eventData)
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i];
        seatInfo.hasConfirmed = false
    end
    self:refreshSeatGameCount()
    self:RefreshRoundInfo(self.modelData.curTableData.roomInfo.curRoundNum + 1)
end

function TableShiSanZhangLogic:refreshSeatGameCount()
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
        if (seatInfo.playerId and seatInfo.playerId ~= 0) then
            seatInfo.gameCount =(seatInfo.gameCount or 0) + 1
        end
    end
end

------收到包:客户自定义的信息变化广播


function TableShiSanZhangLogic:ClearAllMatchingData()
    self.modelData.selectList = { };
    self.modelData.FirstMatching = { };
    self.modelData.SecondMatching = { };
    self.modelData.ThirdMatching = { };
    self.handPokers = { };
    self.oringinalPokers = { };
    -- 发给服务器的数据
    self.pokersInDesc = { };
    -- self.inHandPokerList = {};
end

function TableShiSanZhangLogic:on_table_CustomInfoChangeBroadcast(data)
    print("==on_table_CustomInfoChangeBroadcast")
    -- print_table(data.customInfoList)
    if (self.modelData == nil or self.modelData.curTableData == nil
        or self.modelData.curTableData.roomInfo == nil
        or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
        return
    end
    if (data == nil or data.customInfoList == nil or #data.customInfoList <= 0) then
        return
    end
    for i = 1, #data.customInfoList do
        local player_id = data.customInfoList[i].player_id
        local customInfo = data.customInfoList[i].customInfo
        if (customInfo == nil or customInfo == "") then
            print("==customInfo == nil or customInfo ==")
            return
        end

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for m = 1, #seatInfoList do
            local seatInfo = seatInfoList[m]
            if seatInfo.chatDataSeatHolder then

                if (tostring(seatInfo.chatDataSeatHolder.playerId) == tostring(player_id)) then
                    local locTable = ModuleCache.Json.decode(customInfo)
                    if (seatInfo.chatDataSeatHolder.playerInfo == nil) then
                        print("====seatInfo.playerInfo == nil")
                    else
                        print("address=" .. locTable.address)
                        -- seatInfo.playerInfo.ip = locTable.ip
                        seatInfo.chatDataSeatHolder.playerInfo.locationData = seatInfo.chatDataSeatHolder.playerInfo.locationData or { }
                        seatInfo.chatDataSeatHolder.playerInfo.locationData.address = locTable.address
                        seatInfo.chatDataSeatHolder.playerInfo.locationData.gpsInfo = locTable.gpsInfo
                    end
                end
            end

        end
    end
    self:CheckLocation()
end

------检查位置
function TableShiSanZhangLogic:CheckLocation()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    -- 获取玩家信息列表(比鸡专用)
    local playerInfoList = TableManagerPoker:getPlayerInfoListByBiJi(seatInfoList)
    -- 是否显示定位图标
    TableManagerPoker:isShowLocation(playerInfoList, self.tableShiSanZhangView.buttonLocation)
end

return TableShiSanZhangLogic
