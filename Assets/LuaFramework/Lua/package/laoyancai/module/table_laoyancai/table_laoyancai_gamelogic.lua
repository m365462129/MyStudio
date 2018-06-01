local class = require("lib.middleclass")
local list = require('list')
local TableLaoYanCaiLogic = class('LaoYanCaiLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence
local cardLogic = require('package.laoyancai.module.table_laoyancai.gamelogic_card')
local commonLogic = require('package.laoyancai.module.table_laoyancai.gamelogic_common')
local cardTool = require('package.laoyancai.module.table_laoyancai.card_tool')

function TableLaoYanCaiLogic:initialize(module)
    self.module = module    
    self.modelData = module.modelData
    self.view = module.view
    self.model = module.model
	self.showedPlayers = {}		--已展示手牌玩家
	self:ResetShowedPlayers();
	self.viewPokersFlag = false;
end

function TableLaoYanCaiLogic:ResetShowedPlayers()
	for i = 1,7 do
		self.showedPlayers[i] = false;
	end
end

function TableLaoYanCaiLogic:on_click(obj,arg)
	print(obj.name);
	if(obj.name == "ButtonKick")then
		local index = obj.transform.parent.parent.parent.gameObject.name;
    	self:onClickKickBtn(index)
	end
    if(obj == self.view.buttonGetMorePoker.gameObject) then
        self.model:request_operation(3,self.modelData.curTableData.roomInfo.mySeatInfo)
		self.view:PlayOperationSound(3,self.modelData.curTableData.roomInfo.mySeatInfo)
    elseif(obj == self.view.buttonNotGetPoker.gameObject) then
        self.model:request_operation(4,self.modelData.curTableData.roomInfo.mySeatInfo)
		self.view:PlayOperationSound(4,self.modelData.curTableData.roomInfo.mySeatInfo)
    elseif(obj == self.view.buttonExplode.gameObject) then
        self.model:request_operation(2,self.modelData.curTableData.roomInfo.mySeatInfo)
		--self.view:PlayOperationSound(2,self.modelData.curTableData.roomInfo.mySeatInfo)
	elseif(obj == self.view.buttonRob.gameObject) then
		self.model:request_knock_banker(true)
		--self.view:SetRobButtonsActive(false)
		--self.view:HideTip()	
		self.view:PlayKnockBankerSound(true,self.modelData.curTableData.roomInfo.mySeatInfo)
	elseif(obj == self.view.buttonNotRob.gameObject) then
		self.model:request_knock_banker(false)
		--self.view:SetRobButtonsActive(false)
		--self.view:HideTip()	
		self.view:PlayKnockBankerSound(false,self.modelData.curTableData.roomInfo.mySeatInfo)
	elseif(obj == self.view.buttonBet1.gameObject) then
		self:onBetScore(1);
	elseif(obj == self.view.buttonBet2.gameObject) then
		self:onBetScore(2);
	elseif(obj == self.view.buttonBet3.gameObject) then
		self:onBetScore(3);
	elseif(obj == self.view.buttonBet4.gameObject) then
		self:onBetScore(4);
	elseif(obj == self.view.buttonBetMaBao.gameObject) then
		self:onBetScore(5);
	elseif(obj.transform.parent.parent.parent.parent.gameObject.name == "Seats") then
		self:onViewOthersCard(obj)
	elseif(obj == self.view.buttonJoinBankerQueue.gameObject) then
		self:BankerQueue(true)
	elseif(obj == self.view.buttonExitBankerQueue.gameObject) then
		self:BankerQueue(false)
	elseif(obj == self.view.buttonRule.gameObject or obj == self.view.ruleHint.gameObject)then
		self:on_click_rule_info(obj, arg)
	
    end
end

function TableLaoYanCaiLogic:onClickKickBtn(index)
	local playerId;
    for key,v in ipairs(self.modelData.curTableData.roomInfo.seatInfoList) do
        if(v.localSeatIndex == tonumber(index)) then
            playerId = v.playerId
        end
    end
    self.model:request_kick_player(playerId);
end

function TableLaoYanCaiLogic:on_click_rule_info(obj, arg)
	ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
end

function TableLaoYanCaiLogic:BankerQueue(isJoin)
	if(isJoin) then
		self.model:request_queue_banker(0)
	else
		self.model:request_queue_banker(1)
	end
	self.view:SetBankerQueueButtonActive(not isJoin)
end

function TableLaoYanCaiLogic:OthersKnockBanker(data)
	if(not data.qiang) then
		return;
	end
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i = 1,#seatInfoList do
		if(seatInfoList[i].playerId == data.playerid) then
			self.view:ShowKnockBankerIcon(seatInfoList[i].localSeatIndex)
		end
	end
end

function TableLaoYanCaiLogic:ConfirmBanker(data)
	self.view:HideReadyWindow()
	self.view:SetRobButtonsActive(false)
    self.view:HideTip()
	print(self.modelData.roleData.userID)
	
	self.view:HideChips();
	self.view:HideAllKonckBankerIcons()
	local betTime = data.xiafen_time;
	local getPokerTime = data.fapai_time
	local chipValues = data.xiafen;
	local bankerId = data.brankerid;
	local restPokerNum = data.surcard_cnt;
	self.view:SetRestPokerNum(restPokerNum);
	self.modelData.curTableData.roomInfo.bankerId = data.brankerid
	self.module:subscibe_time_event(1, false, 0):OnComplete( function(t)
		local betScores = data.have_xiafen;
		if(betScores == 0 and self.inGamePlayers[1]) then
			self.chipValues = chipValues;
		
			if(bankerId ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
				local text = "请选择下注分数！"
    			self.view:ShowCountDownText(text,betTime)
				self.view:ShowChips(chipValues);	
			else
				local text = "等待闲家下注！"	
				self.view:ShowOperationTip(text,10)
			end
		else

		end
		if(data.baopai_fen and data.baopai_fen > 0 and self.inGamePlayers[1]) then
			self.view:ShowBaoChips(data.baopai_fen)
			table.insert(self.chipValues,data.baopai_fen)	
		end
		if(self.modelData.curTableData.roomInfo.ruleTable.playType == 1) then
			local bankerId = self.modelData.curTableData.roomInfo.bankerId;
			local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
			for i = 1,#seatInfoList do
				if(seatInfoList[i].playerId == bankerId) then
					self.view:SetBankerQueue(1,seatInfoList[i].playerInfo)
					self.view.bankerQueue:SetActive(true);
				end
			end
			if(bankerId == self.modelData.curTableData.roomInfo.mySeatInfo.playerId and self.inGamePlayers[1]) then
				self.view:SetBankerQueueButtonActive(true);
			end
		end
		print_table(self.modelData.curTableData.roomInfo.seatInfoList)
		for i = 1,#self.modelData.curTableData.roomInfo.seatInfoList do
			local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
			if(seatInfo.playerId == bankerId) then
				seatInfo.isBanker = true;
				self.view:refreshSeatPlayerInfo(seatInfo);	
			else
				seatInfo.isBanker = false;
				self.view:refreshSeatPlayerInfo(seatInfo);				
			end
		
		end
		for key,v in pairs(self.inGamePlayers) do
			if(v) then
				self.view:ShowPokersBack(key)
				self.view:playFaPaiAnim(key,nil);
			end
		end
		self.view:PlayGetPokerSound();
	end)
end

function TableLaoYanCaiLogic:GetCurPlayerCount()
    local count = 0;
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        if(self.modelData.curTableData.roomInfo.seatInfoList[i].playerId and self.modelData.curTableData.roomInfo.seatInfoList[i].playerId ~= 0) then
            count = count + 1;
        end
    end
    print("=================",count)
    return count;
end

function TableLaoYanCaiLogic:KnockBankerRsp(data)
	if(not data.is_ok) then
		return;
	end
    self.view:SetRobButtonsActive(false)
    self.view:HideTip()
end

function TableLaoYanCaiLogic:ChipOffNotify(data)
	local playerId = data.playerid;
	local score = data.fen;
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i = 1, #seatInfoList do
		if(seatInfoList[i].playerId == playerId) then
			local index = seatInfoList[i].localSeatIndex;
			self.view:ShowBetScore(index,score)
			return;
		end
	end
end

function TableLaoYanCaiLogic:ReceiveGameInfo(data)
	self:InitTableData(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    self.view:setRoomInfo(self.modelData.curTableData.roomInfo)
    --self.view:showInviteBtn(playerCount ~= 4)
	

    if(roomInfo.mySeatInfo.isReady)then
        self.view:showReadyBtn(false)
    else
        self.view:showReadyBtn(true)
    end
    --显示离开按钮
	if(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0)then
		self.view:showLeaveBtn(true)
	else
		self.view:showLeaveBtn(false)
	end

	if(roomInfo.ruleTable.playType == 1 and self.isEnterRoom) then
		if(data.game_loop_cnt > 0) then
			local roomInfo = self.modelData.curTableData.roomInfo
			local seatInfoList = roomInfo.seatInfoList
			for i = 1, #seatInfoList do
				if(seatInfoList[i].playerId == 0) then
					self.view:SetSeatActive(seatInfoList[i].localSeatIndex,false);
				end
			end
		end
		self.module:subscibe_time_event(0.5, false, 0):OnComplete( function(t)
            local bankerId = data.brankerid;
			if(bankerId == 0) then
				return;
			end
			local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
			for i = 1,#seatInfoList do
				if(seatInfoList[i].playerId == bankerId) then
					self.view:SetBankerQueue(1,seatInfoList[i].playerInfo)
					self.view.bankerQueue:SetActive(true);
				end
			end
			if(bankerId == self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
				self.view:SetBankerQueueButtonActive(true);
			end
			if(#data.queue_list > 0) then
				self.view:SetBankerQueueActive(#data.queue_list);
				for i = 1,#data.queue_list do
					for j = 1,#seatInfoList do
						if(seatInfoList[j].playerId == data.queue_list[i]) then
							self.view:SetBankerQueue(i + 1,seatInfoList[j].playerInfo)
						end
					end
				end
			end
        end)
		
		if (roomInfo.curRoundNum ~= 0 ) then
			self.view:SetMaBaoPlayTypeUI()
		end
	end
--message Player {
    --required int32 player_id = 1; //玩家ID
    --required int32 player_pos = 2; //玩家位置
    --required int32 enter_cnt = 3; //进入次数
    --required bool is_offline = 4; //是否掉线
    --required bool is_ready = 6;
    --required int32 score = 7; //积分
    --repeated int32 cards = 8; //只有可以亮的牌才有
    --optional int32 third_card = 9; //捞牌的牌（只有捞牌后才有）
--}

	if(self.isEnterRoom) then
		if(roomInfo.state == 1) then

		elseif(roomInfo.state == 2) then

		elseif(roomInfo.state == 3) then
			local players = data.players;
			local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
			for i = 1,#players do
				for j = 1,#seatInfoList do
					if(players[i].player_id == seatInfoList[j].playerId) then
						if(#players[i].cards > 0) then
							print("~~~~~~~~~~~~~~~~~~~~~~~~~~~",seatInfoList[j].localSeatIndex)
							if(not self.showedPlayers[seatInfoList[j].localSeatIndex]) then		
								print("****************",seatInfoList[j].localSeatIndex)	
								self.view:ShowPlayerPokers(seatInfoList[j].localSeatIndex,1,players[i].cards[1]);
								self.view:ShowPlayerPokers(seatInfoList[j].localSeatIndex,2,players[i].cards[2]);
								self.showedPlayers[seatInfoList[j].localSeatIndex] = true;
								local point = players[i].point;
								local pokersType = players[i].type;
								local text = self:GetPokerTypeText(point,pokersType)
								self.view:SetPokerTypeText(seatInfoList[j].localSeatIndex,text,#players[i].cards)
							end
						else
							if(players[i].inplay) then
								self.view:ShowPokersBack(seatInfoList[j].localSeatIndex);
							end
						end
						if(players[i].third_card > 0) then
							self.view:ShowPlayerPokers(seatInfoList[j].localSeatIndex,3,players[i].third_card)
						end
					end
				end
			end
		elseif(roomInfo.state == 4) then
			local bankerId = data.brankerid
			local players = data.players;
			for i = 1, #players do
				local seatInfo = self:GetSeatInfoById(players[i].player_id);
				for j = 1,#players[i].cards do
					self.view:ShowPlayerPokers(seatInfo.localSeatIndex,j,players[i].cards[j]);
				end
				local point = players[i].point;
				local pokersType = players[i].type;
				local text = self:GetPokerTypeText(point,pokersType)
				self.view:SetPokerTypeText(seatInfo.localSeatIndex,text,#players[i].cards)
				if(players[i].player_id == bankerId) then
					self.view:ShowBetScore(seatInfo.localSeatIndex,players[i].win_score)
				else
					self.view:ShowBetScore(seatInfo.localSeatIndex,players[i].xiafen)
				end
				self.module:subscibe_time_event(1, false, 0):OnComplete( function(t)
					self.view:ShowResult(seatInfo.localSeatIndex,players[i].win_score,#players[i].cards)
				end)
				
			end
		end
		for i = 1,#data.players do
			if(data.players[i].player_id == self.modelData.curTableData.roomInfo.mySeatInfo.playerId and data.game_loop_cnt ~= 0) then
				if(data.players[i].inplay or roomInfo.state == 0 or roomInfo.state == 4) then
					self.view:SetTip4Active(false);
				else
					self.view:SetTip4Active(true);
				end
			end	
		end
	end
	if(self.modelData.curTableData.roomInfo.mySeatInfo.isCreator and data.game_loop_cnt == 0) then
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
		for i = 1,#seatInfoList do
			if(seatInfoList[i].playerId ~= 0 and seatInfoList[i].playerId ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
					self.view:SetKickButtonActive(seatInfoList[i].localSeatIndex,true);
			end
		end
	end
	self.isEnterRoom = false
    --self.players = data.players;
    --self.roomId = data.room_id;
    --self.roomInfo = {}
    --self.roomInfo.roomId = data.room_id;
    --self.roomInfo.curRoundNum = data.game_loop_cnt;
    --self.roomInfo.totalRoundCount = data.game_total_cnt;
    --self.roomInfo.ownerId = data.ownerid;
    --self.roomInfo.rate = data.rate;
    --self.
end

function TableLaoYanCaiLogic:onBetScore(index)
	local betScore = self.chipValues[index]
	self.model:request_chip_off(betScore);
	self.view:HideChips();
	self.view:HideTip();
	self.view.buttonBetMaBao.gameObject:SetActive(false);
end

function TableLaoYanCaiLogic:InitTableData(data)
	local roomInfo
	if(self.isEnterRoom)then
		roomInfo = {}
		self.modelData.curTableData = {}
	else
		roomInfo = self.modelData.curTableData.roomInfo
	end
	roomInfo.roomNum = data.room_id
	roomInfo.totalRoundCount = data.game_total_cnt
	roomInfo.curRoundNum = data.game_loop_cnt
	roomInfo.bankerId = data.brankerid
	roomInfo.timeOffset = data.time - os.time()
	roomInfo.state = data.room_state
    roomInfo.isRoundStarted = roomInfo.state ~= 0
	roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
	roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
	roomInfo.ruleDesc = self:formatRuleDesc(roomInfo.ruleTable)	 
    roomInfo.ownerId = data.ownerid;
	local seatInfoList
	local seatCount = 7
	if(self.isEnterRoom)then
		seatInfoList = {}
		for i=1,seatCount do
			local remotePlayerInfo = data.players[i]
			local seatInfo = {}
			seatInfo.playerId = 0
			seatInfo.seatIndex = i
			seatInfo.lastSeatIndex = seatInfo.seatIndex
			seatInfo.isReady = false
			seatInfo.isSeated = false
			seatInfo.roomInfo = roomInfo
			seatInfo.isCreator = false
			seatInfo.isOffline = true
			seatInfo.score = 0
			seatInfo.isBanker = false;
			table.insert(seatInfoList, seatInfo)
		end
	else
		seatInfoList = roomInfo.seatInfoList
	end

	
	for i=1,#data.players do
		local remotePlayerInfo = data.players[i]
		local seatInfo
		if(self.isEnterRoom)then
			seatInfo = seatInfoList[remotePlayerInfo.player_pos]
		else
			seatInfo = self.module:getSeatInfoByPlayerId(remotePlayerInfo.player_id, seatInfoList)
		end
		

		seatInfo.lastSeatIndex = seatInfo.seatIndex
		seatInfo.seatIndex = remotePlayerInfo.player_pos
		seatInfo.playerId = remotePlayerInfo.player_id
		seatInfo.isSeated = seatInfo.playerId ~= 0
		seatInfo.isReady = remotePlayerInfo.is_ready
		seatInfo.isCreator = remotePlayerInfo.player_id == roomInfo.ownerId
		seatInfo.isOffline = remotePlayerInfo.is_offline
		seatInfo.score = remotePlayerInfo.score
		seatInfo.isBanker = (seatInfo.playerId == data.brankerid);
		seatInfo.betScore = remotePlayerInfo.xiafen;
		--print(seatInfo.localSeatIndex, seatInfo.round_discard_cnt, remotePlayerInfo.round_discard_cnt)
        if(seatInfo.playerId == tonumber(self.modelData.curTablePlayerId))then
			roomInfo.mySeatInfo = seatInfo
			seatInfo.isOffline = false
		end
		
	end
	self.modelData.curTableData.roomInfo = roomInfo
	self.view:resetSeatHolderArray(seatCount)
	local mySeatIndex = roomInfo.mySeatInfo.seatIndex
	local lastMySeatIndex = roomInfo.mySeatInfo.lastSeatIndex
	for i=1,seatCount do
        local seatInfo = seatInfoList[i]
        --转换为本地位置索引
		seatInfo.localSeatIndex = self.module:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, mySeatIndex, seatCount)
        self.view:refreshSeatPlayerInfo(seatInfo);
		self.view:refreshSeatOfflineState(seatInfo);
		self.view:refreshSeatState(seatInfo)
		if(seatInfo.betScore and seatInfo.betScore ~= 0 and seatInfo.playerId ~= 0) then
			if(roomInfo.state ~= 0 and roomInfo.state ~= 4) then
				self.view:ShowBetScore(seatInfo.localSeatIndex,seatInfo.betScore)
			end
		end
	end
	
    
	roomInfo.seatInfoList = seatInfoList	
	self.modelData.curTableData.roomInfo = roomInfo
	self.inGamePlayers = {}
	for i = 1,#data.players do
		for j = 1,#seatInfoList do
			if (data.players[i].player_id == seatInfoList[j].playerId) then
				self.inGamePlayers[seatInfoList[j].localSeatIndex] = data.players[i].inplay;
			end
		end
	end
	print_table(self.inGamePlayers)
end

function TableLaoYanCaiLogic:StartBanker(data)
    local time = data.time;
    local state = data.qiangzhuang_state
    if(not state) then
        state = 0;
    end
    self.view:HideReadyWindow()
    self.view:ShowStartBankerStatus(state,time);
	local playType = self.modelData.curTableData.roomInfo.ruleTable.playType;
	if(playType == 1) then
		self.view:SetMaBaoPlayTypeUI();
	end
end

function TableLaoYanCaiLogic:StartOperation(data)
    local pokers = data.cards;
    local stateInfo = data.op;
    local pokersType = data.cardtype;
    local point = data.point
    self.selfPokers = {};
	if(not self.showedPlayers[1]) then
		print("~~~~~~~~~~~~~~~","in")
		local text = self:GetPokerTypeText(point,pokersType)
		self.view:SetPokerTypeText(1,text,#pokers)
		for i = 1,#pokers do
        	self.view:ShowPlayerPokers(1,i,pokers[i],text);
    	end
		self.showedPlayers[1] = true;
	end	
    self.view:HideChips();
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1,#stateInfo do
		for j = 1,#seatInfoList do
			if(stateInfo[i].playerid == seatInfoList[j].playerId) then
				if(stateInfo[i].op == 2 or stateInfo[i].op == 3) then
					self.view:showSeatTimeLimitEffect(seatInfoList[j], true, 10, nil, 1);
				else
					self.view:showSeatTimeLimitEffect(seatInfoList[j], false, 10, nil, 1);
				end
			end
		end
        if(stateInfo[i].playerid == self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
			--local time = stateInfo[i].time
			local time = 10; --该时间暂时由客户端来指定
            self.view:ShowOperationButton(stateInfo[i].op,time);
			if(stateInfo[i].op == 3) then
				self.viewPokersFlag = true;
			end
            break;
        end
    end
end

function TableLaoYanCaiLogic:SetBankerQueue(data)
	local queue = data.queue_list;
	local bankerId = self.modelData.curTableData.roomInfo.bankerId;
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
	self.view:SetBankerQueueActive(#queue);
	for i = 1,#seatInfoList do
		if(seatInfoList[i].playerId == bankerId) then
			if(bankerId == 0) then
				break;
			end
			self.view:SetBankerQueue(1,seatInfoList[i].playerInfo)
		end
	end
	for i = 1,#queue do
		for j = 1,#seatInfoList do
			if(seatInfoList[j].playerId == queue[i]) then
				self.view:SetBankerQueue(i + 1,seatInfoList[j].playerInfo)
			end
		end
		if(queue[i] == self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
			self.view:SetBankerQueueButtonActive(false)
		end
	end
end

function TableLaoYanCaiLogic:OperationResult(data)
	if(not data.is_ok) then
		return;
	end
	local poker = data.card
	if(poker ~= 0) then
		local point = data.point
		local pokerType = data.cardtype
		local text = self:GetPokerTypeText(point,pokerType)
		self.view:ShowThirdPoker(1,poker,text,true)
	end
	self.view:SetOperationButtonActive(1,false)
    self.view:SetOperationButtonActive(2,false)
    self.view:SetOperationButtonActive(3,false)
	if(self.modelData.curTableData.roomInfo.bankerId ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
		self.view:ShowWaitOthersTip();
	end
end

		--optional int32 playerid = 1; //玩家id
        --repeated int32 cards = 2; //玩家手牌
        --optional int32 win_score = 3; //输赢分数
        --optional int32 score = 4; //玩家分数
        --optional int32 point = 5; //点数
        --optional int32 cardtype = 6; //牌型 1，双腌 2三腌 3 三批

function TableLaoYanCaiLogic:CompareResult(data)
	self.viewPokersFlag = false;
	local results = data.player;
	local startReadyTime = data.startready_time;
	local readyTime = data.ready_time;
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
	local bankerLocalIndex = 0;
	for j = 1,#seatInfoList do
		if(seatInfoList[j].playerId == self.modelData.curTableData.roomInfo.bankerId) then
			bankerLocalIndex = seatInfoList[j].localSeatIndex;
			break;
		end
	end
	local bankerWinScore = 0;
	local bankerLoseScore = 0;
	local winnerCount = 0;
	for i = 1,#results do
		local playerId = results[i].playerid;
		local scoreInThisGame = results[i].win_score;
		if(playerId ~= self.modelData.curTableData.roomInfo.bankerId) then
			if(scoreInThisGame > 0) then -- 闲家这个分数大于0时意味着庄家输给他这么多分
				bankerLoseScore = bankerLoseScore + scoreInThisGame;
			else
				bankerWinScore = bankerWinScore + scoreInThisGame;				
				winnerCount = winnerCount + 1;
			end
		end
	end
	self.view:ShowBetScore(bankerLocalIndex,0);
	for i = 1,#results do
		local seatInfo = nil;
		for j = 1,#seatInfoList do
			if(seatInfoList[j].playerId == results[i].playerid) then
				seatInfo = seatInfoList[j];
				break;
			end
		end
		local pokers = results[i].cards;
		local point = results[i].point;
		local pokerType = results[i].cardtype;
		local score = results[i].score;
		local scoreInThisGame = results[i].win_score;
		seatInfo.score = score;
		self.view:refreshSeatPlayerInfo(seatInfo)
		self.view:refreshSeatState(seatInfo)
		self.view:DisplayScore(seatInfo.localSeatIndex,scoreInThisGame);
		self.module:subscibe_time_event(1.5, false, 0):OnComplete( function(t)
			self.view:ShowResult(seatInfo.localSeatIndex,scoreInThisGame,#pokers)
		end)
		if(results[i].playerid ~= self.modelData.curTableData.roomInfo.bankerId) then
			if(scoreInThisGame < 0) then
				self.module:subscibe_time_event(1.5, false, 0):OnComplete( function(t)
					self.view:PlayCoinFliesToBankerAnim(seatInfo.localSeatIndex,bankerLocalIndex,bankerWinScore)
				end)
				
			elseif(scoreInThisGame > 0) then
				self.module:subscibe_time_event(1.5, false, 0):OnComplete( function(t)
					local score = bankerLoseScore + bankerWinScore
					self.view:PlayBankerCoinFliesAnim(seatInfo.localSeatIndex,bankerLocalIndex,score,winnerCount)--bankerLoseScore
				end)	
			end
		end
		if(results[i].playerid ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
			if(not self.showedPlayers[seatInfo.localSeatIndex]) then
				for j = 1,2 do
					self.view:ShowPlayerPokers(seatInfo.localSeatIndex,j,pokers[j]);
				end
				self.showedPlayers[seatInfo.localSeatIndex] = true;
			end
			local text = self:GetPokerTypeText(point,pokerType,#pokers)
			self.view:SetPokerTypeText(seatInfo.localSeatIndex,text,#pokers)
		else
			self.module:subscibe_time_event(0.5, false, 0):OnComplete( function(t)
				self.view:PlayCompareSound(point,pokerType,seatInfo)
			end)
		end
	end
	for i = 1,#seatInfoList do
		self.view:showSeatTimeLimitEffect(seatInfoList[i], false, 10, nil, 1);
	end
	self.view:HideTip()
    self.view:SetOperationButtonActive(1,false)
    self.view:SetOperationButtonActive(2,false)
    self.view:SetOperationButtonActive(3,false)
	self.view:ShowReadyButton(3.5)
	self.view.gameStartAnim:SetActive(false);
	self.modelData.curTableData.roomInfo.isRoundStarted = false;
	self:ResetShowedPlayers();
	self.view:SetTip4Active(false);
end

function TableLaoYanCaiLogic:OperationNotify(data)
	local playerId = data.playerid
	local operation = data.op;
	local restPokerNum = data.surcard_cnt
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
	self.view:SetRestPokerNum(restPokerNum);
	if(playerId == self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
		if(operation == 2) then
			self.view:PlayExplodeAnim();
			for i = 1,#seatInfoList do
				self.view:showSeatTimeLimitEffect(seatInfoList[i], false, 10, nil, 1);
			end
			self.view:PlayOperationSound(2,self.modelData.curTableData.roomInfo.mySeatInfo)
		end
		self.view:showSeatTimeLimitEffect(self.modelData.curTableData.roomInfo.mySeatInfo, false, 10, nil, 1);
		return;
	end
	local restPokerNum = data.surcard_cnt
	self.view:SetRestPokerNum(restPokerNum);
	local operationSeat = nil;
	for i = 1,#seatInfoList do
		if(seatInfoList[i].playerId == playerId) then
			operationSeat = seatInfoList[i];
			break;
		end
	end
	if(operation == 2 and playerId ~= self.modelData.curTableData.roomInfo.bankerId) then
		local pokers = data.xian_cards
		local localSeatIndex = operationSeat.localSeatIndex;
		local point = data.point;
		local pokerType = data.cardtype;

		if(not self.showedPlayers[localSeatIndex]) then
			for i = 1,#pokers do
				self.view:ShowPlayerPokers(localSeatIndex,i,pokers[i])
			end
			self.showedPlayers[localSeatIndex] = true;
		end
		self.view:PlayExplodeAnim();
		local text = self:GetPokerTypeText(point,pokerType,#pokers)
		self.view:SetPokerTypeText(localSeatIndex,text,#pokers)
		self.view:PlayOperationSound(2,self.modelData.curTableData.roomInfo.mySeatInfo)
		for i = 1,#seatInfoList do
			self.view:showSeatTimeLimitEffect(seatInfoList[i], false, 10, nil, 1);
		end
	elseif(operation == 3) then
		local poker = data.card;
		local localSeatIndex = operationSeat.localSeatIndex;
		self.view:ShowThirdPoker(localSeatIndex,poker,"",false)
	end
	self.view:showSeatTimeLimitEffect(operationSeat, false, 10, nil, 1);
end

function TableLaoYanCaiLogic:ClaerTable()

end

function TableLaoYanCaiLogic:GetPokerTypeText(point,pokerType) --1，双腌 2三腌 3 三批
	local text = "";
	if(pokerType == 1) then
		text = "双腌";
	elseif(pokerType == 2) then
		text = "三腌";
	elseif(pokerType == 3) then
		text = "三批";
	end
	text = text .. point;
	if(point == 0) then
		text = text.."灰";
	elseif(point < 8) then
		text = text.."蓝";
	elseif(point < 11) then
		text = text.."黄";
	end
	return text;
end

function TableLaoYanCaiLogic:on_press(obj,arg)

end

function TableLaoYanCaiLogic:on_press_up(obj,arg)

end

function TableLaoYanCaiLogic:on_drag(obj,arg)

end

function TableLaoYanCaiLogic:on_enter_room_rsp(data)
    self.isEnterRoom = true;
end

function TableLaoYanCaiLogic:on_ready_rsp(eventData)
	if(eventData.err_no == "0") then
		self.view:ClearTable()
	end
end

function TableLaoYanCaiLogic:on_start_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	roomInfo.state = 1
	roomInfo.isRoundStarted = true
	if(roomInfo.ruleTable.playType == 1 and roomInfo.ruleTable.brankType == 3) then
		self.view:ShowRestPokerNum();
	end
	self.view.gameStartAnim:SetActive(true);
	self.view:PlayStartSound()
	for i = 1, #seatInfoList do
		if(seatInfoList[i].playerId == 0) then
			self.view:SetSeatActive(seatInfoList[i].localSeatIndex,false);
		end
	end
	if(self.modelData.curTableData.roomInfo.mySeatInfo.isCreator) then
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
		for i = 1,#seatInfoList do
			if(seatInfoList[i].playerId ~= 0 and seatInfoList[i].playerId ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
				self.view:SetKickButtonActive(seatInfoList[i].localSeatIndex,false);
			end
		end
	end
	--self.view:showRoundInfo(true)
end

function TableLaoYanCaiLogic:on_click_leave_btn(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(mySeatInfo.isCreator)then
		self.model:request_dissolve_room(true)
	else
		self.model:request_exit_room()
	end
end

function TableLaoYanCaiLogic:formatRuleDesc(rule)
	print_table(rule)
	local desc = ""
	desc = rule.roundCount.."局,"..(rule.diFen).."分,"; -- 0为1分，1为2分
	
	if(rule.brankScore ~= 0) then
		desc = desc .. rule.brankScore.."分上庄,"
	end
	if(rule.brankType == 0) then
		desc = desc .. "抢庄,"
	elseif(rule.brankType == 1) then
		desc = desc .. "轮庄,"
	elseif(rule.brankType == 2) then
		desc = desc .. "抢庄,"
	elseif(rule.brankType == 3) then
		desc = desc .. "一副牌换庄,"
	end
	if(rule.startNum == 4) then
		desc = desc .. "满4人开局,"
	end
	if(autoBet) then
		desc = desc .. "超时自动下注,"
	end
	if(rule.sanpi == 1) then
		desc = desc .. "三批炸弹,"
	end
	if(rule.color) then
		desc = desc .. "大小+花色比牌,"
	end
	if(rule.allowEnter) then
		desc =desc .. "允许中途加入,"
	end
	if(rule.payType == 0) then
		desc =desc .. "AA支付"
	elseif(rule.payType == 1) then
		desc =desc .. "房主支付"
	end
    return desc
end

function TableLaoYanCaiLogic:onViewOthersCard(obj)
	if(self.modelData.curTableData.roomInfo.bankerId ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
		return;
	end
	if(not self.viewPokersFlag) then
		return;
	end
    local localSeatIndex = tonumber(obj.transform.parent.parent.parent.gameObject.name)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
	local playerId = 0;
	for i = 1,#seatInfoList do
		if(seatInfoList[i].localSeatIndex == localSeatIndex) then
			playerId = seatInfoList[i].playerId;
			break;
		end
	end
	self.model:request_view_card(playerId);
end

function TableLaoYanCaiLogic:ViewOthersPokers(data)
	local playerId = data.playerid;
	local pokers = data.cards;
	local point = data.point;
	local pokersType = data.cardtype
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
	local localSeatIndex = 0;
	for i = 1,#seatInfoList do
		if(seatInfoList[i].playerId == playerId) then
			localSeatIndex = seatInfoList[i].localSeatIndex;
			break;
		end
	end
	if(localSeatIndex == 0) then
		return;
	end
	print_table(self.showedPlayers)
	if(not self.showedPlayers[localSeatIndex]) then
		for i = 1,#pokers do
			self.view:ShowPlayerPokers(localSeatIndex,i,pokers[i]);
		end
		local text = self:GetPokerTypeText(point,pokersType);
		self.view:SetPokerTypeText(localSeatIndex,text,#pokers)
		self.showedPlayers[localSeatIndex] = true;
	end
end

function TableLaoYanCaiLogic:GetSeatInfoById(playerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
	for i = 1,#seatInfoList do
		if(seatInfoList[i].playerId == playerId) then
			return seatInfoList[i];
		end
	end
end


return TableLaoYanCaiLogic