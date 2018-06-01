
local class = require("lib.middleclass")
local list = require('list')
local TableGuanDanLogic = class('GuanDanLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence
local CardCommon = require('package.guandan.module.guandan_table.gamelogic_common')
local cardCommon = CardCommon
local CardPattern = require('package.guandan.module.guandan_table.gamelogic_pattern')
local CardSet = require('package.guandan.module.guandan_table.gamelogic_set')
local tableSound = require('package.guandan.module.guandan_table.table_sound')


function TableGuanDanLogic:initialize(module)
    self.module = module    
    self.modelData = module.modelData
    self.view = module.view
    self.model = module.model
    self.myHandPokers = module.myHandPokers
	self.tableSound = tableSound

	self.isFinishFaPai = true

    -- self:genPokers()
	-- self.myHandPokers:repositionPokers(self.myHandPokers.colList)

	-- local data = {
	-- 	curAccountData = {},
	-- 	roomInfo = {roomNum=11111},
	-- 	packageName = self.module.packageName
	-- }
	-- data.curAccountData.players = {}
	-- for i=1,4 do
	-- 	local player = {}
	-- 	player.player_id = 180 + i
	-- 	player.uid = player.player_id
	-- 	player.nickname = player.player_id
	-- 	player.playerName = player.player_id
	-- 	player.score = i
	-- 	player.win_cnt = i
	-- 	player.lost_cnt = i
	-- 	data.curAccountData.players[i] = player
	-- end
	-- ModuleCache.ModuleManager.show_module('public', "poker_tableresult", data)


end

function TableGuanDanLogic:genPokers()
	local list = {}
	for i=0,26 do
		local pokerHolder = self.myHandPokers:genPokerHolder({
			code = i % 13 + 1
		})
		
		table.insert( list, pokerHolder )
		if(i % 1 == 0)then
			table.insert( self.myHandPokers.colList, list)
			list = {}
		end
	end
	table.insert( self.myHandPokers.colList, list )
end

function TableGuanDanLogic:on_show()
    
end

function TableGuanDanLogic:on_hide()
    
end

function TableGuanDanLogic:update()

end

function TableGuanDanLogic:on_destroy()
	self.showResultViewSmartTimer = nil
	if(self.timerMap)then
		for k,v in pairs(self.timerMap) do
			SmartTimer.Kill(v.id)
		end
	end

end



--初始化牌桌数据
function TableGuanDanLogic:initTableData(data)
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
	roomInfo.desk_player_id = data.desk_player_id
	roomInfo.next_player_id = data.next_player_id
	roomInfo.desk_cards = {}
	if(data.desk_cards)then
		for i=1,#data.desk_cards do
			roomInfo.desk_cards[i] = data.desk_cards[i]
		end
	end
	roomInfo.desk_logic_cards = {}
	if(data.desk_logic_cards)then
		for i=1,#data.desk_logic_cards do
			roomInfo.desk_logic_cards[i] = data.desk_logic_cards[i]
		end
	end
	roomInfo.timeOffset = data.time - os.time()
	roomInfo.tribute_infos = {}
	roomInfo.state = data.state
    roomInfo.isRoundStarted = roomInfo.state ~= 0
	roomInfo.multiple = data.multiple
	roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
	roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc

	roomInfo.pos_card = data.pos_card
	roomInfo.pos_card_player = data.pos_card_player

	roomInfo.major_cardList = {}
	for i=1,#data.major_card do
		roomInfo.major_cardList[i] = data.major_card[i]
	end
	
	roomInfo.major_turn = data.major_turn
	roomInfo.major_card = roomInfo.major_cardList[roomInfo.major_turn]
	CardCommon.GenerateCardInfo(roomInfo.major_card)
	self.rankList = {}

	for i=1,#data.tribute_infos do
		local tributeInfo = {}
		tributeInfo.player_id = data.tribute_infos[i].player_id
		tributeInfo.recv_card = data.tribute_infos[i].recv_card
		tributeInfo.send_card = data.tribute_infos[i].send_card
		tributeInfo.type = data.tribute_infos[i].type
		roomInfo.tribute_infos[i] = tributeInfo
	end

	local seatInfoList
	local seatCount = 4
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
			seatInfo.warning_flag = false
			seatInfo.score = 0
			seatInfo.winTimes = 0
			seatInfo.lostTimes = 0
			seatInfo.leftCardCount = 0
			seatInfo.bondCardList = {}
			seatInfo.rank = 0
			seatInfo.round_discard_cnt = -1
			seatInfo.round_discard_info = nil
			seatInfo.tribute_state = nil	--上贡状态 0表示已经完成上贡动作 1表示需要上贡 -1表示等待上贡 2表示需要返贡 -2表示等待返贡
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
		seatInfo.isCreator = remotePlayerInfo.is_owner
		seatInfo.isOffline = remotePlayerInfo.is_offline
		seatInfo.warning_flag = remotePlayerInfo.warning_flag	--是否报警
		seatInfo.score = remotePlayerInfo.score
		seatInfo.winTimes = remotePlayerInfo.win_cnt
		seatInfo.lostTimes = remotePlayerInfo.lost_cnt
		seatInfo.leftCardCount = remotePlayerInfo.rest_card_cnt	--剩余手牌数
		seatInfo.bondCardList = remotePlayerInfo.bond_cards		--喜牌
		seatInfo.rank = remotePlayerInfo.rank or 0
		seatInfo.round_discard_cnt = remotePlayerInfo.round_discard_cnt or -1	--本轮出牌情况 -1 还未轮到 0 已过牌 其他表示出牌数量
		--print(seatInfo.localSeatIndex, seatInfo.round_discard_cnt, remotePlayerInfo.round_discard_cnt)
		seatInfo.round_discard_info = {}
		seatInfo.round_discard_logic_info = {}
		if(remotePlayerInfo.round_discard_info)then	--当前出牌
			for i=1,#remotePlayerInfo.round_discard_info do
				seatInfo.round_discard_info[i] = remotePlayerInfo.round_discard_info[i]
				seatInfo.round_discard_logic_info[i] = remotePlayerInfo.round_discard_logic_info[i]
			end
		end

		local cardPatternList = CardPattern.new(seatInfo.round_discard_info, seatInfo.round_discard_logic_info)
		if(cardPatternList)then
			seatInfo.round_discard_pattern = cardPatternList[1]
		else
			seatInfo.round_discard_pattern = nil
		end

		seatInfo.tribute_state = remotePlayerInfo.tribute_state			--上贡状态 0表示已经完成上贡动作 1表示需要上贡 -1表示等待上贡 2表示需要返贡 -2表示等待返贡
		seatInfo.can_deny_tribute = remotePlayerInfo.can_deny_tribute		--是否可抗贡
		seatInfo.handCodeList = {}
		
		if(seatInfo.playerId == tonumber(self.modelData.curTablePlayerId))then
			roomInfo.mySeatInfo = seatInfo
			seatInfo.isOffline = false
            for i=1,#data.cards do
                seatInfo.handCodeList[i] = data.cards[i]
            end
		end
	end

	self.view:resetSeatHolderArray(seatCount)
	local mySeatIndex = roomInfo.mySeatInfo.seatIndex
	local lastMySeatIndex = roomInfo.mySeatInfo.lastSeatIndex
	for i=1,seatCount do
        local seatInfo = seatInfoList[i]
        --转换为本地位置索引
		seatInfo.localSeatIndex = self.module:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, mySeatIndex, seatCount)
		seatInfo.lastLocalSeatIndex = self.module:getLocalIndexFromRemoteSeatIndex(seatInfo.lastSeatIndex, lastMySeatIndex, seatCount)
		local index = ((seatInfo.seatIndex == 1 or seatInfo.seatIndex == 3) and 1) or 2
		seatInfo.major_card = roomInfo.major_cardList[index]
	end


    
	roomInfo.seatInfoList = seatInfoList	
	self.modelData.curTableData.roomInfo = roomInfo
	self:resetPartner()
end

function TableGuanDanLogic:resetPartner()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.seatIndex == 1)then
			seatInfo.partner = self.module:getSeatInfoBySeatIndex(3, seatInfoList)
		elseif(seatInfo.seatIndex == 2)then
			seatInfo.partner = self.module:getSeatInfoBySeatIndex(4, seatInfoList)
		elseif(seatInfo.seatIndex == 3)then
			seatInfo.partner = self.module:getSeatInfoBySeatIndex(1, seatInfoList)
		elseif(seatInfo.seatIndex == 4)then
			seatInfo.partner = self.module:getSeatInfoBySeatIndex(2, seatInfoList)
		end
	end
end

function TableGuanDanLogic:on_press_up(obj, arg)
	if(obj == self.view.buttonShowDesktop.gameObject)then
		self.myHandPokers:show_handPokers(true)
	end
end

function TableGuanDanLogic:on_drag(obj, arg)	
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_drag(obj,arg)
	end
end

function TableGuanDanLogic:on_press(obj, arg)
	if(obj == self.view.buttonShowDesktop.gameObject)then
		self.myHandPokers:show_handPokers(false)
	elseif(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press(obj,arg)
	end
	
end

function TableGuanDanLogic:on_click(obj, arg)
	if((not self.modelData.curTableData) or (not self.modelData.curTableData.roomInfo))then
		return
	end
	if(obj == self.view.buttonOneCol.gameObject)then
		self.myHandPokers:sortSelected2OneCol()
	elseif(obj == self.view.buttonSequence.gameObject)then
		self:on_click_flushstraight_btn(obj, arg)
	elseif(obj == self.view.buttonReset.gameObject)then
		self.myHandPokers:resetPokers()
	elseif(obj == self.view.buttonBuChu.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif(obj == self.view.buttonTiShi.gameObject)then
		self:on_click_tishi_btn(obj, arg)
	elseif(obj == self.view.buttonChuPai.gameObject)then
		self:on_click_chupai_btn(obj, arg)
	elseif(obj == self.view.imageMask.gameObject)then
		self.myHandPokers:unSelectAllPokers()
		self.myHandPokers:refreshPokersState(self.myHandPokers.colList)
	elseif(obj == self.view.buttonShangGong.gameObject)then
		self:on_click_tribute_btn(obj, arg)
	elseif(obj == self.view.buttonKangGong.gameObject)then
		self:on_click_kanggong_btn(obj, arg)
	elseif(obj == self.view.buttonHuanGong.gameObject)then
		self:on_click_huangong_btn(obj, arg)
	elseif(obj.transform.parent.name == 'WaitSelectCards')then
		self:on_click_wait_select_cards(obj, arg)
	elseif(obj == self.view.selectCardsPanelHolder.root)then
		self:on_click_wait_select_mask(obj, arg)
	elseif(obj == self.view.ruleHint.gameObject)then
		self:on_click_rule_info(obj, arg)

	elseif(obj.name == "ButtonKick") then
		self:on_click_kick_btn(obj, arg)
	end
end

--------------------------------------------------------------------------
--按钮点击

--点击踢人按钮
function TableGuanDanLogic:on_click_kick_btn(obj, arg)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i,v in ipairs(seatInfoList) do
		local seatHolder = self.view.seatHolderArray[v.localSeatIndex]
		if(seatHolder)then
			if(seatHolder.kickBtn.gameObject == obj and v.playerId and v.playerId ~= 0)then
				self.model:request_kick_player(v.playerId)
			end
		end
	end
end

--规则信息按钮
function TableGuanDanLogic:on_click_rule_info(obj, arg)
	ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
end

function TableGuanDanLogic:on_click_leave_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(mySeatInfo.isCreator)then
		if self.modelData.roleData.RoomType == 2 then
			self.model:request_exit_room()
		else
			self.model:request_dissolve_room(true)
		end

	else
		self.model:request_exit_room()
	end
end

function TableGuanDanLogic:on_click_buchu_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	--先显示后逻辑start
	mySeatInfo.round_discard_cnt = 0
	mySeatInfo.round_discard_info = {}
	mySeatInfo.round_discard_logic_info = {}
	mySeatInfo.round_discard_pattern = nil
	--播放不出动画
	self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
	self:playPassSound(mySeatInfo)
	--end

	self.model:request_discard(true)

end

function TableGuanDanLogic:on_click_tishi_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(not self.tiShiFunction)then
		local lastPattern = nil
		if(roomInfo.lastDisCardSeatInfo)then
			lastPattern = roomInfo.lastDisCardSeatInfo.round_discard_pattern
		end
		-- print('---------------------------', lastPattern)
		-- if(lastPattern)then
		-- 	print_table(lastPattern)
		-- end
		self.tiShiFunction = mySeatInfo.handCardSet:hintIterator(lastPattern)
	end
	
	if(not self.tiShiFunction)then	--要不起
		--先显示后逻辑start
        mySeatInfo.round_discard_cnt = 0
        mySeatInfo.round_discard_info = {}
		mySeatInfo.round_discard_logic_info = {}
		mySeatInfo.round_discard_pattern = nil
        --播放不出动画
        self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
		self:playPassSound(mySeatInfo)
		--end

		self.model:request_discard(true)
		return
	end
	local pattern = self.tiShiFunction()
	self.myHandPokers:selectPokers(pattern.cards)
	self.myHandPokers:refreshPokersState(self.myHandPokers.colList)
end

function TableGuanDanLogic:on_click_chupai_btn(obj, arg)
	local selectedPokerHolders, selectPokerList, selectedCodeList = self.myHandPokers:getSelectedPokers()
	local lastPattern = nil
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(roomInfo.lastDisCardSeatInfo)then
		lastPattern = roomInfo.lastDisCardSeatInfo.round_discard_pattern
	end
	if(not selectedCodeList or #selectedCodeList == 0)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择要出的牌")	
		return
	end
	local canChuPai, cardPatternList = self:checkCanChuPai(lastPattern, selectedCodeList)
	if(not canChuPai)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
	end
	self.selected_chupai_PokerHolders = selectedPokerHolders
	self.selected_chupai_cardPatternList = cardPatternList

	if(cardPatternList)then
		if(#cardPatternList > 1)then
			self.view:showSelectCardsPanel(true, cardPatternList[1].cards, cardPatternList[1].logic_cards, cardPatternList[2].cards, cardPatternList[2].logic_cards)
			return
		elseif(#cardPatternList > 0)then
			--先显示后逻辑start
			if(cardPatternList)then
				mySeatInfo.round_discard_pattern = cardPatternList[1]
			else
				mySeatInfo.round_discard_pattern = nil
			end
			self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

			self:refreshMySeatDiscardView()			
			--end
			self.model:request_discard(false, cardPatternList[1].cards, cardPatternList[1].logic_cards)
			return
		end
	end
	ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
end

--点击上贡按钮
function TableGuanDanLogic:on_click_tribute_btn(obj, arg)
	local selectedPokerHolders, _, selectedCodeList = self.myHandPokers:getSelectedPokers()
	if(not selectedCodeList or #selectedCodeList ~= 1)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择要上贡的牌")	
		return 
	end
	self.selected_tribute_PokerHolders = selectedPokerHolders
	self.selected_tribute_CodeList = selectedCodeList
	self.model:request_tribute(self.modelData.roleData.userID, selectedCodeList[1])
end

--点击抗贡按钮
function TableGuanDanLogic:on_click_kanggong_btn(obj, arg)
	self.model:request_tribute(self.modelData.roleData.userID, 0)
end

--点击还贡按钮
function TableGuanDanLogic:on_click_huangong_btn(obj, arg)
	local selectedPokerHolders, _, selectedCodeList = self.myHandPokers:getSelectedPokers()
	if(not selectedCodeList or #selectedCodeList ~= 1)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择要还贡的牌")	
		return 
	end
	self.selected_tribute_PokerHolders = selectedPokerHolders
	self.selected_tribute_CodeList = selectedCodeList
	self.model:request_tribute(self.modelData.roleData.userID, selectedCodeList[1])
end

--点击待选牌型的牌型
function TableGuanDanLogic:on_click_wait_select_cards(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local index = 1
	if(obj == self.view.selectCardsPanelHolder.goPokersRoot1)then
		index = 1	
	elseif(obj == self.view.selectCardsPanelHolder.goPokersRoot2)then
		index = 2
	else
		return
	end
	if(self.selected_chupai_cardPatternList and #self.selected_chupai_cardPatternList > 1)then
		local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
		--先显示后逻辑start
		local patternList = self.selected_chupai_cardPatternList
		if(patternList)then
			mySeatInfo.round_discard_pattern = patternList[index]
		else
			mySeatInfo.round_discard_pattern = nil
		end
		self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

		self:refreshMySeatDiscardView()			
		--end
		self.model:request_discard(false, self.selected_chupai_cardPatternList[index].cards, self.selected_chupai_cardPatternList[index].logic_cards)
	else
		print('--------------err,self.selected_chupai_cardPatternList == nil')
	end
end

--点击选牌型的mask
function TableGuanDanLogic:on_click_wait_select_mask(obj, arg)
	self.view:showSelectCardsPanel(false)
end

--点击同花顺按钮
function TableGuanDanLogic:on_click_flushstraight_btn(obj, arg)
	if(self.findFlushStraightFun)then
		local pattern = self.findFlushStraightFun()
		if(pattern)then
			self.myHandPokers:selectPokers(pattern.cards)
			self.myHandPokers:refreshPokersState(self.myHandPokers.colList)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('未找到对应牌型')	
		end
	else
		self:tryshowFlushStraightBtn()
	end
end

-------------------------------------------------------------------------------
--消息处理

function TableGuanDanLogic:on_enter_room_rsp(eventData)
	self.isEnterRoom = true
end

function TableGuanDanLogic:on_ready_rsp(eventData)
	if(eventData.err_no == '0')then
		--清除牌桌上的牌
		self:cleanDesk()
	end
end

function TableGuanDanLogic:on_start_notify(eventData)
	self.rankList = {}
	self.isWaitingFaPai = true
	self.isFinishFaPai = false
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	roomInfo.state = 1
	roomInfo.isRoundStarted = true
	self.view:showRoundInfo(true)
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		seatInfo.is_sended_tribute = false
		seatInfo.is_finished_tribute = false
	end
end


function TableGuanDanLogic:on_table_tribute_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)	
		return
	end
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	mySeatInfo.handCodeList = {}
	for i=1,#eventData.cards do
		mySeatInfo.handCodeList[i] = eventData.cards[i]
	end
	mySeatInfo.leftCardCount = #eventData.cards
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	self.view:showHuanGongButton(false)
	self.view:showShangGongButton(false)
	self.view:showKangGongButton(false)
end

function TableGuanDanLogic:on_table_tribute_notify(eventData)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
	local card = eventData.card
	local tribute_states = eventData.tribute_states
	for i=1,#tribute_states do
		local tribute_state = tribute_states[i]
		local tmpSeatInfo = self.module:getSeatInfoByPlayerId(tribute_state.player_id, seatInfoList)
		tmpSeatInfo.tribute_state = tribute_state.tribute_state
	end

	if(card == 0)then	--抗贡
		seatInfo.is_sended_tribute = false
		seatInfo.is_finished_tribute = false
		seatInfo.tribute_state = 0
		local oppsite_seatInfo = self.module:getSeatInfoByPlayerId(eventData.oppsite_player_id, seatInfoList)
		if(oppsite_seatInfo == mySeatInfo)then
			--隐藏等待上贡图标
			
		end
		self.view:showKangGongAnim(seatInfo.localSeatIndex, true, true)
	else
		seatInfo.is_sended_tribute = true
		seatInfo.is_finished_tribute = false
		local tribute_info = self:getTributeInfosByPlayerId(eventData.player_id)
		if(tribute_info)then
			tribute_info.send_card = card
		end
		self.view:showTributeCard(seatInfo.localSeatIndex, true, card)
	end


	if(seatInfo == mySeatInfo)then
		self.view:showHuanGongButton(false)
		self.view:showShangGongButton(false)
		self.view:showKangGongButton(false)
		local removeresult = self.myHandPokers:removePokerHolders(self.selected_tribute_PokerHolders)
		self.myHandPokers:repositionPokers(self.myHandPokers.colList, false, nil, true)
		self.selected_tribute_PokerHolders = {}
		self.selected_tribute_CodeList = {}
	end
end

function TableGuanDanLogic:on_table_tribute_result_notify(eventData)
	self.test = function()
		self:on_table_tribute_result_notify(eventData)
	end
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.tribute_infos = {}
	for i=1,#eventData.tribute_infos do
		local tributeInfo = {}
		tributeInfo.player_id = eventData.tribute_infos[i].player_id
		tributeInfo.recv_card = eventData.tribute_infos[i].recv_card
		tributeInfo.send_card = eventData.tribute_infos[i].send_card
		tributeInfo.type = eventData.tribute_infos[i].type
		roomInfo.tribute_infos[i] = tributeInfo
	end
	roomInfo.next_player_id = eventData.next_player_id
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	self:matchingTributeSenderReceiver()


	self.module:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
		self:playTributeCardChangeAnim(function()
			for i=1,#seatInfoList do
				local seatInfo = seatInfoList[i]
				self.view:showKangGongAnim(seatInfo.localSeatIndex, false)
			end
			if(self:is_finished_huangong())then
				--开始打牌
				for i=1,#seatInfoList do
					local seatInfo = seatInfoList[i]
					if(seatInfo.playerId == roomInfo.next_player_id)then
						self.view:showSeatClock(seatInfo.localSeatIndex, true, seatInfo == mySeatInfo)
						--清除下一个出牌玩家的桌面
						self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
						self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
						if(seatInfo == mySeatInfo)then
							self.view:showChuPaiButtons(true, true)
						end
					end
				end
			else
				self:showTributeStateView()
			end
		end)
	end)
end

function TableGuanDanLogic:on_table_discard_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)	
		return
	end
	self.tiShiFunction = nil

	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	mySeatInfo.handCodeList = {}
	for i=1,#eventData.cards do
		mySeatInfo.handCodeList[i] = eventData.cards[i]
	end
	
	mySeatInfo.leftCardCount = #eventData.cards
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	self.view:showChuPaiButtons(false)
	self.view:showSelectCardsPanel(false)
end

--出牌通知
function TableGuanDanLogic:on_table_discard_notify(eventData)
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
	local partnerSeatInfo = mySeatInfo.partner
    local seatInfoList = roomInfo.seatInfoList
	
    local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
	local last_warning_flag = seatInfo.warning_flag
    seatInfo.warning_flag = eventData.warning_flag
    seatInfo.leftCardCount = eventData.rest_card_cnt
	
	if(eventData.hand_cards and (seatInfo == mySeatInfo or seatInfo == partnerSeatInfo))then
		partnerSeatInfo.handCodeList = {}
		for i=1,#eventData.hand_cards do
			partnerSeatInfo.handCodeList[i] = eventData.hand_cards[i]
		end
	end

	local lastDisCardSeatInfo = roomInfo.lastDisCardSeatInfo
	if(eventData.is_first_pattern)then
		roomInfo.lastDisCardSeatInfo = nil
	else
		if(not eventData.is_passed)then
			roomInfo.lastDisCardSeatInfo = seatInfo
		end
	end
    roomInfo.next_player_id = eventData.next_player_id
	roomInfo.multiple = eventData.multiple
	self.view:refreshMultiple(roomInfo.multiple)

    local onFinish = function()
        for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
            --下一个玩家首发，则清除牌桌上的牌
            if(eventData.is_first_pattern)then
                self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
                self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
			elseif(not eventData.is_passed)then
				-- if(eventData.player_id ~= seatInfo.playerId)then
				-- 	self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
				-- 	self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
				-- end
            end
        end
        
        local nextDisCardSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.next_player_id, seatInfoList)
		if(nextDisCardSeatInfo)then
			self.view:showSeatClock(nextDisCardSeatInfo.localSeatIndex, true, nextDisCardSeatInfo == mySeatInfo)
			--清除下一个出牌玩家的桌面
			self.view:playSeatPassAnim(nextDisCardSeatInfo.localSeatIndex, false)
			self.view:playDispatchPokers(nextDisCardSeatInfo.localSeatIndex, false)
		end

		if(nextDisCardSeatInfo == mySeatInfo)then
			local canDrop, patternList, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
			canBigger = canBigger or false
			if(canDrop and patternList and #patternList > 0)then
				if(#patternList > 1)then
					self.view:showSelectCardsPanel(true, patternList[1].cards, patternList[1].logic_cards, patternList[2].cards, patternList[2].logic_cards)
				else
					--先显示后逻辑start
					if(patternList)then
						mySeatInfo.round_discard_pattern = patternList[1]
					else
						mySeatInfo.round_discard_pattern = nil
					end
					self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

					self:refreshMySeatDiscardView()			
					--end
					self.model:request_discard(false, patternList[1].cards, patternList[1].logic_cards)
				end
			end
			self.view:showChuPaiButtons(true, eventData.is_first_pattern, not canBigger)
		end
    end

	self.view:showSeatClock(seatInfo.localSeatIndex, false)
    if(eventData.is_passed)then
        seatInfo.round_discard_cnt = 0
        seatInfo.round_discard_info = {}
		seatInfo.round_discard_logic_info = {}
		seatInfo.round_discard_pattern = nil
		if(seatInfo == mySeatInfo)then
        --播放不出动画
        --self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, false, onFinish)
		--self:playPassSound(seatInfo)
			onFinish()
		else
        	--播放不出动画
			self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, false, onFinish)
			self:playPassSound(seatInfo)
		end
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
    else
		roomInfo.lastDisCardSeatInfo = seatInfo
		roomInfo.desk_player_id = eventData.player_id
		roomInfo.desk_cards = {}
		roomInfo.desk_logic_cards = {}
        seatInfo.round_discard_cnt = #eventData.cards or 0
		seatInfo.round_discard_info = {}
		seatInfo.round_discard_logic_info = {}
		for i=1,#eventData.cards do
			seatInfo.round_discard_info[i] = eventData.cards[i]
			roomInfo.desk_cards[i] = eventData.cards[i]
		end
		if(eventData.logic_cards)then
			for i=1,#eventData.logic_cards do
				seatInfo.round_discard_logic_info[i] = eventData.logic_cards[i]
				roomInfo.desk_logic_cards[i] = eventData.logic_cards[i]
			end
        end
		local cardPatternList = CardPattern.new(seatInfo.round_discard_info, seatInfo.round_discard_logic_info)
		if(cardPatternList)then
			seatInfo.round_discard_pattern = cardPatternList[1]
		else
			seatInfo.round_discard_pattern = nil
		end
		 
		 if(seatInfo == mySeatInfo)then
        --播放出牌动画		
		--self:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
			onFinish()
		 else
        	--播放出牌动画		
			self:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
			self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
		 end


		--牌已出完
		if(seatInfo.leftCardCount == 0)then
			table.insert( self.rankList, seatInfo)
			seatInfo.rank = #self.rankList
		end

		self.module:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
			--显示排名
			self.view:showRankTag(seatInfo.localSeatIndex, seatInfo.rank)		
		end)

		if(seatInfo == mySeatInfo)then
			--self:refreshMySeatDiscardView()
		else
			self:tryShowSeatWarningIcon(seatInfo, last_warning_flag)
		end
		self:tryShowPartnerHandPoker(seatInfo)
		self:tryshowFlushStraightBtn()

		--隐藏上游打的牌
		for i=1,#seatInfoList do
			local tmpSeatInfo = seatInfoList[i]
			if(tmpSeatInfo ~= seatInfo)then
				if(tmpSeatInfo.leftCardCount == 0)then
					self.view:playDispatchPokers(tmpSeatInfo.localSeatIndex, false)
				end
			end
		end
    end
    

end

--结算通知
function TableGuanDanLogic:on_table_currentaccount_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		seatInfo.isReady = false
		--显示排名
		seatInfo.rank = - 1
	end
	roomInfo.state = 0
	roomInfo.isRoundStarted = false

	if(eventData.is_summary_account)then
		self.module.TableManager:disconnect_game_server()
		ModuleCache.net.NetClientManager.disconnect_all_client()
	end

	local onFinish = function()
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			self.view:refreshSeatState(seatInfo)
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, false)
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
			--显示排名
			self.view:showRankTag(seatInfo.localSeatIndex, seatInfo.rank)
		end
		self:cleanDesk()
		self.view:showReadyBtn_three(false)
		self.view:showChuPaiButtons(false)

		if(not eventData.is_summary_account)then
			local data = {
				players={}
			}
			for i=1,#eventData.players do
				local tmpPlayer = eventData.players[i]
				local seatInfo = self.module:getSeatInfoByPlayerId(tmpPlayer.player_id, seatInfoList)
				local player = {}
				player.playerId = tmpPlayer.player_id
				player.playerInfo = seatInfo.playerInfo
				player.seatIndex = seatInfo.seatIndex
				player.score = tmpPlayer.current_score or 0
				seatInfo.score = tmpPlayer.score
				player.isRoomCreator = seatInfo.isCreator or false
				self.view:refreshSeatState(seatInfo)
				player.uplevel = tmpPlayer.uplevel or 0
				player.multiple = tmpPlayer.multiple or 0
				player.rank = tmpPlayer.rank or -1
				data.players[i] = player
				if(seatInfo == mySeatInfo)then
					if(player.score < 0)then
						self.tableSound:playGameLoseSound()
					else
						self.tableSound:playGameWinSound()
					end
				end
			end
			table.sort(data.players, function(p1,p2)
				return p1.seatIndex < p2.seatIndex
			end)
			data.roomInfo = roomInfo
			data.time = self.module:getServerNowTime()
			data.myPlayerId = mySeatInfo.playerId
			ModuleCache.ModuleManager.show_module(self.module.packageName, "onegameresult", data)
		else
			local data = {
				curAccountData = {},
				roomNum = roomInfo.roomNum,
				curRoundNum = roomInfo.curRoundNum,
				totalRoundCount = roomInfo.totalRoundCount,
				packageName = self.module.packageName,
				free_sponsor = eventData.free_sponsor,	--申请解散者id
			}
			if(roomInfo.ruleTable.playingMethod == 2)then
				data.roomDesc = '团团转'
			else
				data.roomDesc = '经典玩法'
			end
			data.curAccountData.players = {}
			for i=1,#eventData.players do
				local tmpPlayer = eventData.players[i]
				local seatInfo = self.module:getSeatInfoByPlayerId(tmpPlayer.player_id, seatInfoList)
				local player = {}
				player.player_id = tmpPlayer.player_id
				player.uid = tmpPlayer.player_id
				if(seatInfo.playerInfo)then
					player.nickname = seatInfo.playerInfo.playerName
					player.playerName = seatInfo.playerInfo.playerName
					player.headImg = seatInfo.playerInfo.headImg
					player.spriteHeadImage = seatInfo.playerInfo.spriteHeadImage
				end

				player.score = tmpPlayer.score or 0
				player.win_cnt = tmpPlayer.win_cnt or 0
				player.lost_cnt = tmpPlayer.lost_cnt or 0
				if(tmpPlayer.player_id == eventData.free_sponsor)then
					player.isDissolver = true
				end
				player.isRoomCreator = seatInfo.isCreator or false
				if(seatInfo == mySeatInfo)then
					player.isSelf = true
				end
				data.curAccountData.players[i] = player
			end
			self.tableSound:playMathWinSound()
			ModuleCache.ModuleManager.show_module('public', "poker_tableresult", data)
			ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
		end
	end

	if(eventData.isPrevSettle)then
		onFinish()
	else
		self.module:subscibe_time_event(2, false, 0):OnComplete(function()
			onFinish()
		end)
	end
end

function TableGuanDanLogic:on_table_gameinfo_notify(eventData)
	self:initTableData(eventData)
	--初始化主牌
	
	self:check_tribute_state()
	local roomInfo = self.modelData.curTableData.roomInfo
	self.myHandPokers.roomNum = roomInfo.roomNum
	self.myHandPokers.curRoundNum = roomInfo.curRoundNum
	self.myHandPokers.userID = self.modelData.roleData.userID
	self.module:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, nil)
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	self:tryshowFlushStraightBtn()
	local is_first_pattern = roomInfo.desk_player_id == 0
	if(is_first_pattern)then
		roomInfo.lastDisCardSeatInfo = nil
	else
		roomInfo.lastDisCardSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.desk_player_id, seatInfoList)
	end
	
	self.module:on_enter_room_event(roomInfo)
	
	--设置牌局和房间信息
	self.view:setRoomInfo(roomInfo)
	self.view:showMajorCard(true, self:getDisplayNameFromName(roomInfo.major_card))
	self.view:refreshMultiple(roomInfo.multiple)
	--显示双方主牌
	local oppoSeatIndex = ((mySeatInfo.seatIndex == 1 or mySeatInfo.seatIndex == 3) and 2) or 1
	local oppoSeatInfo = self.module:getSeatInfoBySeatIndex(oppoSeatIndex, seatInfoList)
	--print(mySeatInfo.major_card, oppoSeatInfo.major_card)
	self.view:refreshTeamMajorCard(self:getDisplayNameFromName(mySeatInfo.major_card), self:getDisplayNameFromName(oppoSeatInfo.major_card))
	self.view:showRoundInfo(roomInfo.curRoundNum > 0)

	local playerCount = 0
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:refreshSeatState(seatInfo, seatInfo.lastLocalSeatIndex)
		if(seatInfo.lastLocalSeatIndex == seatInfo.localSeatIndex)then
			self.view:refreshSeatPlayerInfo(seatInfo)
			self.view:refreshSeatOfflineState(seatInfo)
			--显示排名
			self.view:showRankTag(seatInfo.localSeatIndex, seatInfo.rank)
		else

		end
		if(seatInfo.playerId ~= 0)then
			playerCount = playerCount + 1
		end
	end

		if self.modelData.roleData.RoomType == 2 then
			self.view:showInviteBtn(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0  )
		else
			self.view:showInviteBtn(playerCount ~= 4 )
		end

		--显示离开按钮
		if(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0)then
			self.module:refresh_share_clip_board()
			self.view:showLeaveBtn(true)
		else
			self.view:showLeaveBtn(false)
		end


		self.view:showChuPaiButtons(false)
		if(mySeatInfo.isReady)then
			self.view:showReadyBtn_three(false)
		else
			self.view:showReadyBtn_three(true)
		end


		if(self.isEnterRoom)then
			self.isEnterRoom = false
		end
		local initFunction = function()
			self.isFinishFaPai = true
			--判断游戏是否已经开局
			if(roomInfo.isRoundStarted)then
				local isFinishTribute = self:is_finished_huangong()
				for i=1,#seatInfoList do
					local seatInfo = seatInfoList[i]

					if(seatInfo.round_discard_cnt == 0)then --已过牌
						self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, true)
					elseif(seatInfo.round_discard_cnt > 0 and roomInfo.desk_player_id == seatInfo.playerId)then --已出牌
						self:sort_pattern_by_type(seatInfo.round_discard_pattern)
						local cards = seatInfo.round_discard_pattern.sorted_cards
						local logic_cards = seatInfo.round_discard_pattern.sorted_logic_cards
						self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, logic_cards, true)
					else
						self.view:playSeatPassAnim(seatInfo.localSeatIndex, false, true)
					end

					if(self:tryShowPartnerHandPoker(seatInfo))then

					else
						self:tryShowSeatWarningIcon(seatInfo, true)
					end

					if(isFinishTribute and seatInfo.playerId == roomInfo.next_player_id)then
						self.view:showSeatClock(seatInfo.localSeatIndex, true, seatInfo == mySeatInfo)
						--清除下一个出牌玩家的桌面
						self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
						self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
					end
				end

				if(isFinishTribute)then
					if(roomInfo.next_player_id == mySeatInfo.playerId)then
						local canDrop, patternList = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
						if(canDrop and patternList and #patternList > 0)then
							if(#patternList > 1)then
								self.view:showSelectCardsPanel(true, patternList[1].cards, patternList[1].logic_cards, patternList[2].cards, patternList[2].logic_cards)
							else
								--先显示后逻辑start
								if(patternList)then
									mySeatInfo.round_discard_pattern = patternList[1]
								else
									mySeatInfo.round_discard_pattern = nil
								end
								self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

								self:refreshMySeatDiscardView()
								--end
								self.model:request_discard(false, patternList[1].cards, patternList[1].logic_cards)
							end
						end
						self.view:showChuPaiButtons(true, is_first_pattern)
					end
				else
					self:showTributeStateView()
					self:showAllSeatInfoTributeCard()
				end
			else

			end
		end

		if(self.isWaitingFaPai)then
			self.isWaitingFaPai = false
			self.myHandPokers:clean_memory()
			local fapaiFun = function(onFinish)
				local len = #mySeatInfo.handCodeList
				for i=1,len do
					local code = mySeatInfo.handCodeList[i]
					self.module:subscibe_time_event((i-1) * 0.05, false, 0):OnComplete(function(t)
						self.tableSound:playFaPaiSound()
						self.myHandPokers:genPokerHolderList({code}, roomInfo.major_card, i ~= 1)
						self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
						if(i == len)then
							self.myHandPokers:resetPokers()
							if(onFinish)then
								onFinish()
							end
						end
					end)
				end
			end
			if(roomInfo.ruleTable.playingMethod == 2)then	--团团转
				local changePosFun = function(onFinish)
					local need_change, need_change_seatList = self:is_need_change_seat_pos()
					--print("是否需要交换", need_change)
					if(need_change)then
						local isCalledFinish = false
						self.view:showChangeSeatInfoPanel(true, need_change_seatList[1].lastLocalSeatIndex, need_change_seatList[2].lastLocalSeatIndex)
						self.module:subscibe_time_event(3, false, 0):OnComplete(function()
							self.view:showChangeSeatInfoPanel(false)
							if((not isCalledFinish) and onFinish)then
								isCalledFinish = true
								onFinish()
							end
						end)
						--交换座位
						local count = 0
						local finishCount = 0
						for i=1,#seatInfoList do
							local seatInfo = seatInfoList[i]
							if(seatInfo.localSeatIndex ~= seatInfo.lastLocalSeatIndex)then
								count = count + 1
								self.view:playChangeSeatPosAnim(seatInfo.lastLocalSeatIndex, seatInfo.localSeatIndex, function()
									finishCount = finishCount + 1
									self.view:refreshSeatPlayerInfo(seatInfo)
									self.view:refreshSeatState(seatInfo)
									self.view:refreshSeatOfflineState(seatInfo)
									--显示排名
									self.view:showRankTag(seatInfo.localSeatIndex, seatInfo.rank)
									if(finishCount == count)then
										if((not isCalledFinish) and onFinish)then
											isCalledFinish = true
											onFinish()
										end
									end
								end)
							end
						end
					else
						self.view:showNoSeatChangePanel(true)
						self.module:subscibe_time_event(2, false, 0):OnComplete(function()
							self.view:showNoSeatChangePanel(false)
							if(onFinish)then
								onFinish()
							end
						end)
					end
				end

				--亮牌
				self:playLiangPaiAnim(roomInfo.pos_card, function()
					fapaiFun(function()
						--显示明牌背景
						self:showAllSeatInfoMingPaiBg(true)
						local seatInfo1, seatInfo2 = self:getLiangPaiSeatInfo(roomInfo.next_player_id, roomInfo.pos_card_player)
						if(not seatInfo2)then
							self:playSeatLiangPaiAnim(seatInfo1.lastLocalSeatIndex, seatInfo1.lastLocalSeatIndex, roomInfo.pos_card, function()
								self:showAllSeatInfoMingPaiBg(false)
								changePosFun(initFunction)
							end)
						else
							self:playSeatLiangPaiAnim(seatInfo1.lastLocalSeatIndex, seatInfo2.lastLocalSeatIndex, roomInfo.pos_card, function()
								self:showAllSeatInfoMingPaiBg(false)
								changePosFun(initFunction)
							end)
						end
					end)
				end)
			else
				fapaiFun(initFunction)
			end
		elseif(not self.isFinishFaPai)then

		else
			self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, roomInfo.major_card)
			self.myHandPokers:resetPokers(true, true)
			initFunction()
		end


		end

function TableGuanDanLogic:matchingTributeSenderReceiver()
	local roomInfo = self.modelData.curTableData.roomInfo
	for i=1,#roomInfo.tribute_infos do
		local send_card = roomInfo.tribute_infos[i].send_card
		if(not roomInfo.tribute_infos[i].recv_player_id)then
			for j=1,#roomInfo.tribute_infos do
				local recv_card = roomInfo.tribute_infos[j].recv_card
				if(send_card == recv_card and roomInfo.tribute_infos[i].type ~= roomInfo.tribute_infos[j].type)then
					if(not roomInfo.tribute_infos[j].from_player_id)then
						roomInfo.tribute_infos[j].from_player_id = roomInfo.tribute_infos[i].player_id
						roomInfo.tribute_infos[i].recv_player_id = roomInfo.tribute_infos[j].player_id
						break
					end
				end
			end

		end
	end
end

--显示上贡界面
function TableGuanDanLogic:showTributeStateView()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	self.view:showShangGongButton(false)
	self.view:showKangGongButton(false)
	self.view:showHuanGongButton(false)

	if(mySeatInfo.tribute_state == 0)then

	elseif(mySeatInfo.tribute_state == 1)then
		self.view:showKangGongButton(mySeatInfo.can_deny_tribute or false)
		self.view:showShangGongButton(not (mySeatInfo.can_deny_tribute or false))
	elseif(mySeatInfo.tribute_state == -1)then

	elseif(mySeatInfo.tribute_state == 2)then
		self.view:showHuanGongButton(true)
	elseif(mySeatInfo.tribute_state == -2)then

	end
end

function TableGuanDanLogic:showAllSeatInfoTributeCard(summary)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local tribute_infos = roomInfo.tribute_infos
	for i=1,#tribute_infos do
		local tribute_info = tribute_infos[i]
		local seatInfo = self.module:getSeatInfoByPlayerId(tribute_info.player_id, seatInfoList)
		self.view:showTributeCard(seatInfo.localSeatIndex, false)
		if(summary)then
			if(tribute_info.send_card and tribute_info.send_card ~= 0)then
				self.view:showTributeCard(seatInfo.localSeatIndex, true, tribute_info.send_card)
			end
		else
			if(tribute_info.type ~= 0)then		--需要上贡
				if(seatInfo.tribute_state == 0)then	--已完成上贡动作

				elseif(seatInfo.tribute_state == 1)then	--需要上贡
				elseif(seatInfo.tribute_state == -1)then		--等待上贡

				elseif(seatInfo.tribute_state == 2)then	--需要返贡
				elseif(seatInfo.tribute_state == -2)then	--等待返贡
					if(not self:is_finished_tribute())then
						self.view:showTributeCard(seatInfo.localSeatIndex, true, tribute_info.send_card)
					end
				elseif(seatInfo.tribute_state == -3)then	--等待上贡结算
					self.view:showTributeCard(seatInfo.localSeatIndex, true, tribute_info.send_card)
				end

			else 	--不需要上贡

			end
		end

	end
end

function TableGuanDanLogic:getTributeInfosByPlayerId(playerId)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local tribute_infos = roomInfo.tribute_infos
	for i=1,#tribute_infos do
		local tribute_info = tribute_infos[i]
		if(tribute_info.player_id == playerId)then
			return tribute_info
		end
	end
	return nil
end

function TableGuanDanLogic:check_tribute_state()
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local tribute_infos = roomInfo.tribute_infos
	for i=1,#tribute_infos do
		local tribute_info = tribute_infos[i]
		if(tribute_info.type ~= 0)then
			local seatInfo = self.module:getSeatInfoByPlayerId(tribute_info.player_id, seatInfoList)
			if(seatInfo.tribute_state == -2)then
				seatInfo.is_sended_tribute = true
				if(self:is_finished_tribute())then
					seatInfo.is_finished_tribute = true
				else
					seatInfo.is_finished_tribute = false
				end
			elseif(seatInfo.tribute_state == -3)then
				seatInfo.is_sended_tribute = true
				seatInfo.is_finished_tribute = false
			end
		end
	end
end

--是否完成上贡
function TableGuanDanLogic:is_finished_tribute()
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.tribute_state == 0)then	--已经完成上贡动作
		elseif(seatInfo.tribute_state == 1)then	--需要上贡
			return false
		end
	end
	return true
end


--是否完成还贡
function TableGuanDanLogic:is_finished_huangong()
	local roomInfo = self.modelData.curTableData.roomInfo
	if(roomInfo.ruleTable.tribute == 2)then		--不需要上贡
		return true
	end
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.tribute_state == 0)then	--已经完成上贡动作

		elseif(seatInfo.tribute_state == 2)then	--需要返贡
			return false
		else
			return false
		end
	end
	return true
end


function TableGuanDanLogic:tryShowSeatWarningIcon(seatInfo, last_warning_flag)
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	if(seatInfo == mySeatInfo)then
		return false
	end
	if(seatInfo == mySeatInfo.partner and mySeatInfo.leftCardCount == 0)then
		self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
		return
	end
	if(seatInfo.warning_flag)then
		if(seatInfo.leftCardCount > 0)then
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, true)
			if(not last_warning_flag)then
				--self.view:playWarningEffect(seatInfo)
				self.tableSound:playWarningSound()
			end
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, true, seatInfo.leftCardCount)
			return true
		elseif(seatInfo.leftCardCount == 0)then
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, true, seatInfo.leftCardCount)
		end
	end
	return false
end

function TableGuanDanLogic:tryShowPartnerHandPoker(seatInfo)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(seatInfo ~= mySeatInfo.partner and seatInfo ~= mySeatInfo)then
		return false
	end

	seatInfo = mySeatInfo.partner
	if(mySeatInfo.leftCardCount == 0)then
		self.view:showSeatHandPokers(seatInfo, true)
		local pokerList = self.myHandPokers:genPokerList(seatInfo.handCodeList, roomInfo.major_card)
		for i=1,#pokerList do
			pokerList[i].id = i
			pokerList[i].poker = pokerList[i]
		end
		self.myHandPokers:sortList(pokerList)
		local codeList = {}
		for i=1,#pokerList do
			codeList[i] = pokerList[i].code
		end
		self.view:refreshSeatHandPokers(seatInfo, codeList)
		self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, false)
		self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
	end

	return true
end

function TableGuanDanLogic:tryshowFlushStraightBtn()
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	self.findFlushStraightFun = mySeatInfo.handCardSet:hintIterator(nil, CardCommon.type_five_same_color)
	--显示同花顺按钮
	if(self.findFlushStraightFun)then
		local pattern = self.findFlushStraightFun()
		if(pattern)then
			self.view:showFlushStraightBtn(true, true, false)
		else
			self.view:showFlushStraightBtn(true, false, true)
		end
	else
		self.view:showFlushStraightBtn(true, false, true)
	end
end

function TableGuanDanLogic:cleanDesk()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		self.view:showSeatHandPokers(seatInfo, false)
		self.view:showSeatClock(seatInfo.localSeatIndex, false)
		self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
	end
	self.myHandPokers:removeAll()
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, false, nil, true)
end

--播放牌型音效
function TableGuanDanLogic:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	if(type == CardCommon.type_four
	or type == CardCommon.type_five
	or type == CardCommon.type_six
	or type == CardCommon.type_seven
	or type == CardCommon.type_eight
	or type == CardCommon.type_four_king)then
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.type_five_same_color)then
		--self.view:playTongHuaShunEffect(seatInfo)
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.type_triple2)then	--3连对
		self.view:playLianDuiEffect(seatInfo)
	elseif(type == CardCommon.type_double3)then --飞机
		self.view:playFeiJiEffect(seatInfo)
	elseif(type == CardCommon.type_single_5)then
		self.view:playShunZiEffect(seatInfo)
	end

end

--播放不出音效
function TableGuanDanLogic:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

--判断是否能够出牌
function TableGuanDanLogic:checkCanChuPai(srcPattern, codeList)
	local selectedPatternList = CardPattern.new(codeList)
	if(not selectedPatternList)then
		return false
	end
	if(not srcPattern)then
		if(not selectedPatternList)then
			print('not selectedPattern')
			return false
		else
			return true, selectedPatternList
		end
	else
		local list = {}
		for i=1,#selectedPatternList do
			local pattern = selectedPatternList[i]
			local compable = pattern:compable(srcPattern)
			if(not compable)then

			else
				local le = pattern:le(srcPattern)
				if(le)then

				else
					table.insert( list, pattern)
				end
			end
		end
		return #list ~= 0, list
	end

end

--播放贡牌交换动画
function TableGuanDanLogic:playTributeCardChangeAnim(onFinish)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local finishCount = 0
	local count = 0
	for i=1,#roomInfo.tribute_infos do
		local tributeInfo = roomInfo.tribute_infos[i]
		local seatInfo = self.module:getSeatInfoByPlayerId(tributeInfo.recv_player_id, seatInfoList)
		if(seatInfo)then
			seatInfo.tribute_recv_card = tributeInfo.send_card
		end
	end
	for i=1,#roomInfo.tribute_infos do
		local tributeInfo = roomInfo.tribute_infos[i]

		if(tributeInfo.type ~= 0)then
			local seatInfo = self.module:getSeatInfoByPlayerId(tributeInfo.player_id, seatInfoList)
			if(seatInfo.is_sended_tribute and (not seatInfo.is_finished_tribute))then	--等待返贡或者等待上贡结算
				seatInfo.is_finished_tribute = true
				count = count + 1
				local recv_seatInfo = self.module:getSeatInfoByPlayerId(tributeInfo.recv_player_id, seatInfoList)
				self.view:playChangeTributeCardAnim(seatInfo.localSeatIndex, recv_seatInfo.localSeatIndex,function()
					self.view:showTributeCard(seatInfo.localSeatIndex, false)
					self.view:showTributeCard(recv_seatInfo.localSeatIndex, true, recv_seatInfo.tribute_recv_card)
					self.module:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
						if(mySeatInfo == recv_seatInfo)then
							self:playMyRecvTributeCardFly2HandPokers(function()
								finishCount = finishCount + 1
								if(finishCount == count)then
									if(onFinish)then
										onFinish()
									end
								end
							end)
						else
							self.view:playTributeCardFly2Head(recv_seatInfo.localSeatIndex, function()
								self.view:showTributeCard(recv_seatInfo.localSeatIndex, false)
								finishCount = finishCount + 1
								if(finishCount == count)then
									if(onFinish)then
										onFinish()
									end
								end
							end)
						end
					end)
				end)
			end
		end

	end
	if(count == 0)then
		if(onFinish)then
			onFinish()
		end
	end
end

--播放贡牌飞向牌堆动画
function TableGuanDanLogic:playMyRecvTributeCardFly2HandPokers(onFinish)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo

	local my_recv_card = mySeatInfo.tribute_recv_card
	mySeatInfo.tribute_recv_card = nil
	if(my_recv_card)then
		local list = self.myHandPokers:genPokerHolderList({my_recv_card}, roomInfo.major_card, true)
		local goPoker = list[1].root
		goPoker:SetActive(false)

		local seatHolder = self.view.seatHolderArray[mySeatInfo.localSeatIndex]
		local sequence = self.module:create_sequence()
		local duration = 0.2
		local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
		local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)

		goPoker.transform.position = seatHolder.tributeCardHolder.pokerHolder.root.transform.position
		goPoker.transform.localEulerAngles = targetRotate

		sequence:Append(seatHolder.tributeCardHolder.pokerHolder.root.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):OnComplete(function()
			seatHolder.tributeCardHolder.pokerHolder.root.transform.localEulerAngles = originalRotate
			self.view:showTributeCard(mySeatInfo.localSeatIndex, false)
			goPoker:SetActive(true)
		end))
		sequence:Append(goPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))
		sequence:OnComplete(function ()
			self.myHandPokers:resetPokers(false)
			if(onFinish)then
				onFinish()
			end
		end)
	end
end

function TableGuanDanLogic:is_need_change_seat_pos()
	local roomInfo = self.modelData.curTableData.roomInfo
	if(roomInfo.ruleTable.playingMethod ~= 2)then		--不是团团转
		return false
	end
	local seatInfoList = roomInfo.seatInfoList
	local needChangeSeatList = {}
	local is_need_change = false
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.lastSeatIndex and seatInfo.lastSeatIndex ~= seatInfo.seatIndex)then
			is_need_change = true
			--print('needchange', seatInfo.playerId, seatInfo.lastSeatIndex, seatInfo.seatIndex, seatInfo.lastLocalSeatIndex, seatInfo.localSeatIndex)
			table.insert( needChangeSeatList, seatInfo)
		end
	end
	return is_need_change, needChangeSeatList
end

function TableGuanDanLogic:getDisplayNameFromName(card_name)
	if(card_name == CardCommon.card_J)then
		return 'J'
	elseif(card_name == CardCommon.card_Q)then
		return 'Q'
	elseif(card_name == CardCommon.card_K)then
		return 'K'
	else
		return card_name .. ''
	end
end

function TableGuanDanLogic:seatIndex_pos(srcSeatIndex, dstSeatIndex)
	if(dstSeatIndex - srcSeatIndex == 1 or dstSeatIndex - srcSeatIndex == -3)then
		return false, true, false, false
	elseif(dstSeatIndex - srcSeatIndex == -1 or dstSeatIndex - srcSeatIndex == 3)then
		return true, false, false, false
	elseif(dstSeatIndex - srcSeatIndex == 0)then
		return false, false, true, false
	elseif(dstSeatIndex - srcSeatIndex == 2 or dstSeatIndex - srcSeatIndex == -2)then
		return false, false, false, true
	else

	end
end


function TableGuanDanLogic:sort_pattern_by_type(pattern)
	local sortedCardHolderList = {}
	local name_count_table = {}
	for i=1,#pattern.cards do
		local holder = {}
		holder.cardCode = pattern.cards[i]
		holder.logic_cardCode = pattern.logic_cards[i]
		if(pattern.logic_cards[i] and pattern.logic_cards[i] ~= 0)then
			holder.card = CardCommon.ResolveCardIdx(pattern.logic_cards[i])
		else
			holder.card = CardCommon.ResolveCardIdx(pattern.cards[i])
		end
		if(not name_count_table[holder.card.name])then
			name_count_table[holder.card.name] = 0
		end
		name_count_table[holder.card.name] = name_count_table[holder.card.name] + 1
		holder.id = i
		sortedCardHolderList[i] = holder
	end
	local type = pattern.type
	table.sort( sortedCardHolderList, function(t1,t2)
		if(t1.card.name == t2.card.name)then
			if(t1.card.color == t2.card.color)then
				return t1.id > t2.id
			end
			return t1.card.color > t2.card.color
		else
			if(type == cardCommon.type_three_p2)then
				return name_count_table[t1.card.name] > name_count_table[t2.card.name]
			else
				if(type == cardCommon.type_five_same_color
				or type == cardCommon.type_single_5
				or type == cardCommon.type_triple2
				or type == cardCommon.type_double3)then
					if(t1.card.name == cardCommon.card_A and t2.card.name ~= cardCommon.card_A)then
						if(name_count_table[cardCommon.card_K] and name_count_table[cardCommon.card_K] ~= 0)then
							return t1.card.name < t2.card.name
						end
					elseif(t2.card.name == cardCommon.card_A and t1.card.name ~= cardCommon.card_A)then
						if(name_count_table[cardCommon.card_K] and name_count_table[cardCommon.card_K] ~= 0)then
							return t1.card.name < t2.card.name
						end
					end

				end
				return t1.card.name > t2.card.name
			end

		end
	end)
	pattern.sorted_cards = {}
	pattern.sorted_logic_cards = {}
	for i=1,#sortedCardHolderList do
		pattern.sorted_cards[i] = sortedCardHolderList[i].cardCode
		pattern.sorted_logic_cards[i] = sortedCardHolderList[i].logic_cardCode
	end
end

--自己打完牌后刷新手牌和桌面
function TableGuanDanLogic:refreshMySeatDiscardView()
	self:tryshowFlushStraightBtn()
	self.view:showChuPaiButtons(false)
	self.myHandPokers:removePokerHolders(self.selected_chupai_PokerHolders)
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, false, nil, true)
	self.selected_chupai_PokerHolders = {}
	self.selected_chupai_CodeList = {}
end

--出牌动画、音效播放
function TableGuanDanLogic:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
	self:sort_pattern_by_type(seatInfo.round_discard_pattern)
	local cards = seatInfo.round_discard_pattern.sorted_cards
	local logic_cards = seatInfo.round_discard_pattern.sorted_logic_cards

	self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, logic_cards, false, onFinish)
	if(not lastDisCardSeatInfo)then
		self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, nil)
	else
		self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, lastDisCardSeatInfo.round_discard_pattern)
	end
end


--是否能够一手丢
function TableGuanDanLogic:can_drop_cards(lastDisCardSeatInfo)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local lastCardPattern = nil
	if(lastDisCardSeatInfo)then
		lastCardPattern = lastDisCardSeatInfo.round_discard_pattern
	end
	local tiShiFunction, count = mySeatInfo.handCardSet:hintIterator(lastCardPattern)
	if(tiShiFunction and count > 0)then
		--自动甩牌不要了
		-- for i=1,count do
		-- 	local pattern = tiShiFunction()
		-- 	if(#pattern.cards == #mySeatInfo.handCodeList)then
		-- 		local patternList = CardPattern.new(pattern.cards)
		-- 		self.myHandPokers:selectPokers(pattern.cards)
		-- 		self.myHandPokers:refreshPokersState(self.myHandPokers.colList)
		-- 		local selectedPokerHolders, selectPokerList, selectedCodeList = self.myHandPokers:getSelectedPokers()
		-- 		self.selected_chupai_PokerHolders = selectedPokerHolders
		-- 		self.selected_chupai_cardPatternList = patternList
		-- 		return true, patternList, true
		-- 	end
		-- end
		return false, nil, true
	else
		return false
	end
	return false
end

function TableGuanDanLogic:playBgm()
	self.tableSound:playBgm()
end

--亮牌
function TableGuanDanLogic:playLiangPaiAnim(card, onFinish)
	--print('亮牌', card)
	self.view:showCenterMingPai(true, card)
	self.module:subscibe_time_event(3, false, 0):OnComplete(function()
		self.view:showCenterMingPai(false)
		if(onFinish)then
			onFinish()
		end
	end)
end

--座位亮牌
function TableGuanDanLogic:playSeatLiangPaiAnim(localSeatIndex1, localSeatIndex2, card, onFinish)
	--print('座位亮牌', seatInfo1.seatIndex, seatInfo2.seatIndex, card)
	self.view:playSeatMingPaiSecond(false, localSeatIndex2)
	self.view:showSeatMingPaiMain(true, localSeatIndex1, card)
	self.module:subscibe_time_event(2, false, 0):OnComplete(function()
		self.view:playSeatMingPaiSecond(true, localSeatIndex2, card, function()
			self.view:showSeatMingPaiMain(false, localSeatIndex1)
			self.view:playSeatMingPaiSecond(false, localSeatIndex2)
			if(onFinish)then
				onFinish()
			end
		end)
	end)
end

function TableGuanDanLogic:showAllSeatInfoMingPaiBg(show)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:showSeatMingPaiBg(show, seatInfo.localSeatIndex)
	end
end

function TableGuanDanLogic:getLiangPaiSeatInfo(next_player_id, pos_card_player)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	local seatInfo1 = self.module:getSeatInfoByPlayerId(next_player_id, seatInfoList)
	for i=1,#pos_card_player do
		local player_id = pos_card_player[i]
		if(player_id ~= next_player_id)then
			local seatInfo2 = self.module:getSeatInfoByPlayerId(player_id, seatInfoList)
			return seatInfo1, seatInfo2
		end
	end
	return seatInfo1
end

-- function TableGuanDanLogic:testfun()
-- 	local selectedPokerHolders, selectedPokerList, selectedCodeList = self.myHandPokers:getSelectedPokers()
-- 	if(selectedCodeList)then

-- 	end
-- 	self.view:showSelectCardsPanel(true, {8,9,10,11,12},{0,0,0,0,3},{21,22,23,24,25},{0,0,0,0,3})
-- end

return TableGuanDanLogic