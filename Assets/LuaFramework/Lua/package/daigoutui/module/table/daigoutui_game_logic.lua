
local class = require("lib.middleclass")
local list = require('list')
local DaiGouTuiGameLogic = class('DaiGouTuiLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence
local CardCommon = require('package.daigoutui.module.table.gamelogic_common')
local cardCommon = CardCommon
local CardPattern = require('package.daigoutui.module.table.gamelogic_pattern')
local CardSet = require('package.daigoutui.module.table.gamelogic_set')
local tableSound = require('package.daigoutui.module.table.table_sound')


function DaiGouTuiGameLogic:initialize(module)
    self.module = module    
    self.modelData = module.modelData
    self.view = module.view
    self.model = module.model
    self.myHandPokers = module.myHandPokers
	self.tableSound = tableSound

	self.isFinishFaPai = true

    -- self:genPokers()
	-- self.myHandPokers:show_handPokers(true, false)
	-- self.myHandPokers:resetPokers(true)
	-- self.myHandPokers:playFaPaiAnim()

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

function DaiGouTuiGameLogic:genPokers()
	local list = {}
	for i=0,38 do
		local code = i % 13 + 1
		table.insert( list, code)
		self.myHandPokers:genPokerHolderList({code}, nil, true)
	end	
end

function DaiGouTuiGameLogic:on_show()
    
end

function DaiGouTuiGameLogic:on_hide()
    
end

function DaiGouTuiGameLogic:update()

end

function DaiGouTuiGameLogic:on_destroy()
	self.showResultViewSmartTimer = nil
	if(self.timerMap)then
		for k,v in pairs(self.timerMap) do
			SmartTimer.Kill(v.id)
		end
	end

end


function DaiGouTuiGameLogic:on_press_up(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press_up(obj,arg)
	end
end

function DaiGouTuiGameLogic:on_drag(obj, arg)	
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_drag(obj,arg)
	end
end

function DaiGouTuiGameLogic:on_press(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press(obj,arg)
	end
end

function DaiGouTuiGameLogic:on_click(obj, arg)	
	if(self.is_playing_select_poker_anim or self.myHandPokers.is_playing_select_poker_anim)then
		return
	end
	if(obj == self.view.imageMask.gameObject)then
		self.myHandPokers:resetPokers(true)
	elseif(obj == self.view.buttonChuPai.gameObject)then
		self:on_click_chupai_btn(obj, arg)
	elseif(obj == self.view.buttonTiShi.gameObject)then
		self:on_click_tishi_btn(obj, arg)
	elseif(obj == self.view.buttonYaoBuQi.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif(obj == self.view.buttonBuChu.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif( obj == self.view.buttonShowCard.gameObject)then
		self:on_click_showcards_btn(true)
	elseif( obj == self.view.buttonNotShowCard.gameObject)then
		self:on_click_showcards_btn(false)
	elseif(obj == self.view.buttonRule.gameObject)then
		self:on_click_rule_info(obj, arg)
	elseif(obj == self.view.buttonMingPai_1vs4.gameObject)then
		self:on_click_showcards_btn(true)
	elseif(obj == self.view.buttonAnPai_1vs4.gameObject)then
		self:on_click_showcards_btn(false)
	elseif(obj == self.view.buttonCallServant.gameObject)then
		self:on_click_call_servant_btn(obj, arg)
	elseif(obj == self.view.buttonRestart.gameObject)then
		self:on_click_restart_btn(obj, arg)
	elseif(obj == self.view.buttonLiPai.gameObject)then
		self:on_click_lipai_btn(obj, arg)
	elseif(obj.name == 'KickBtn')then
		self:on_click_kick_btn(obj, arg)
	elseif(obj.transform.parent.name == 'ChouTi')then
		self:on_click_chouti_btn(obj, arg)
	end
end


--------------------------------------------------------------------------
--按钮点击

--点击踢人按钮
function DaiGouTuiGameLogic:on_click_kick_btn(obj, arg)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i,v in ipairs(seatInfoList) do
		local seatHolder = self.view.seatHolderArray[v.localSeatIndex]
		if(seatHolder)then
			if(seatHolder.buttonKick.gameObject == obj and v.playerId and v.playerId ~= 0)then
				self.model:request_kick_player(v.playerId)
			end
		end
	end
end

--规则信息按钮
function DaiGouTuiGameLogic:on_click_rule_info(obj, arg)
	ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
end

--点击离开按钮
function DaiGouTuiGameLogic:on_click_leave_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(mySeatInfo.isCreator)then
		self.model:request_dissolve_room(true)
	else
		self.model:request_exit_room()
	end
end


function DaiGouTuiGameLogic:on_click_buchu_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	--先显示后逻辑start
	mySeatInfo.round_discard_cnt = 0
	mySeatInfo.round_discard_info = {}
	mySeatInfo.round_discard_pattern = nil
	--播放不出动画
	self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
	self:playPassSound(mySeatInfo)
	--end

	self.model:request_discard(true, nil, self.discard_serno)
	self.myHandPokers:resetPokers(true)
end


function DaiGouTuiGameLogic:on_click_tishi_btn(obj, arg)
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
		self.tiShiFunction = mySeatInfo.handCardSet:hintIterator(lastPattern, roomInfo.servant_card, mySeatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
	end
	
	if(not self.tiShiFunction)then	--要不起
		--if(true)then
		--	return
		--end
		--先显示后逻辑start
        mySeatInfo.round_discard_cnt = 0
        mySeatInfo.round_discard_info = {}
		mySeatInfo.round_discard_pattern = nil
        --播放不出动画
        self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
		self:playPassSound(mySeatInfo)
		--end

		self.model:request_discard(true, nil, self.discard_serno)
		self.myHandPokers:resetPokers(true)
		return
	end
	local pattern = self.tiShiFunction()
	if(not pattern)then
		--if(true)then
		--	return
		--end
		--先显示后逻辑start
        mySeatInfo.round_discard_cnt = 0
        mySeatInfo.round_discard_info = {}
		mySeatInfo.round_discard_pattern = nil
        --播放不出动画
        self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
		self:playPassSound(mySeatInfo)
		--end

		self.model:request_discard(true, nil, self.discard_serno)
		self.myHandPokers:resetPokers(true)
		return
	end
	self.myHandPokers:selectPokers(pattern.cards)
	self.is_playing_select_poker_anim = true
	self.myHandPokers:refreshPokerSelectState(false, function()
		self.is_playing_select_poker_anim = false
	end)
end

function DaiGouTuiGameLogic:can_chu_pai()
	--if(true)then
	--	return true
	--end
	local selectedPokerHolders, selectPokerList, selectedCodeList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList = self.myHandPokers:getSelectedPokers()
	local lastPattern = nil
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(roomInfo.lastDisCardSeatInfo)then
		lastPattern = roomInfo.lastDisCardSeatInfo.round_discard_pattern
	end
	if(not real_selectedCodeList or #real_selectedCodeList == 0)then
		return false
	end
	local canChuPai, cardPattern = self:checkCanChuPai(lastPattern, real_selectedCodeList, mySeatInfo)
	if(not canChuPai)then	
		return false
	end
	if(cardPattern)then
		print_table(cardPattern.cards)
		return true
	end
	return false
end

function DaiGouTuiGameLogic:on_click_chupai_btn(obj, arg)
	local selectedPokerHolders, selectPokerList, selectedCodeList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList = self.myHandPokers:getSelectedPokers()
	local lastPattern = nil
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(roomInfo.lastDisCardSeatInfo)then
		lastPattern = roomInfo.lastDisCardSeatInfo.round_discard_pattern
	end
	if(not real_selectedCodeList or #real_selectedCodeList == 0)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择要出的牌")	
		return
	end
	local canChuPai, cardPattern = self:checkCanChuPai(lastPattern, real_selectedCodeList, mySeatInfo)
	if(not canChuPai)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
		return
	end
	self.selected_chupai_PokerHolders = real_selectedPokerHolders
	self.selected_chupai_cardPattern = cardPattern

	if(cardPattern)then
		--先显示后逻辑start
		mySeatInfo.round_discard_pattern = cardPattern
		self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

		self:refreshMySeatDiscardView()			
		--end
		self.model:request_discard(false, cardPattern.cards, self.discard_serno)
		return
	end
	ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
end

--点击明牌按钮
function DaiGouTuiGameLogic:on_click_showcards_btn(show)
	self.model:request_show_cards(show)
end

--点击叫狗腿按钮
function DaiGouTuiGameLogic:on_click_call_servant_btn(obj, arg)
	self.model:request_call_servant()
end

--点击抽屉按钮
function DaiGouTuiGameLogic:on_click_chouti_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	for i,v in ipairs(seatInfoList) do
		local seatHolder = self.view.seatHolderArray[v.localSeatIndex]
		if(seatHolder.handPokerHolder.buttonTag.gameObject == obj)then
			seatHolder.handPokerHolder.isChouTiOpen = (not (seatHolder.handPokerHolder.isChouTiOpen or false))
			self.view:showChouTi(v.localSeatIndex, seatHolder.handPokerHolder.isChouTiOpen)
		end	
	end
	
end

--点击理牌按钮
function DaiGouTuiGameLogic:on_click_lipai_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local sort_pattern_type = self.myHandPokers.sort_pattern_type
	local target_sort_type
	if(sort_pattern_type and sort_pattern_type == 1)then
		target_sort_type = 2
	else
		target_sort_type = 1
	end
	self:re_sort_myhandcards(target_sort_type)
	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.show_cards)then
			self:re_sort_handcards(seatInfo)
			self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList, roomInfo.servant_card)
		end
	end
end

--点击重新开始按钮
function DaiGouTuiGameLogic:on_click_restart_btn(obj, arg)
	self.model:request_redeal_cards()
end

function DaiGouTuiGameLogic:re_sort_handcards(seatInfo, target_sort_type)
	target_sort_type = target_sort_type or self.myHandPokers.sort_pattern_type
	if(not seatInfo.handCodeList)then
		return
	end
	local roomInfo = self.modelData.curTableData.roomInfo
	local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
	local handCardSet = CardSet.new(seatInfo.handCodeList, #seatInfo.handCodeList)
	handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, seatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
	seatInfo.handCodeList = handCardSet.cards
end

function DaiGouTuiGameLogic:re_sort_myhandcards(target_sort_type)
	target_sort_type = target_sort_type or self.myHandPokers.sort_pattern_type
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	self.myHandPokers:set_sort_pattern_type(target_sort_type)
	mySeatInfo.handCardSet:SortByPattern(target_sort_type, roomInfo.servant_card, mySeatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
	mySeatInfo.handCodeList = mySeatInfo.handCardSet.cards
	self.myHandPokers:removeAll()
	self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList)
	self.myHandPokers:show_handPokers(true, true)
	self.myHandPokers:resetPokers(true)
	self.selected_chupai_PokerHolders = {}
	self.selected_chupai_CodeList = {}
end

-------------------------------------------------------------------------------
--消息处理

--进入房间应答
function DaiGouTuiGameLogic:on_enter_room_rsp(eventData)
	self.isEnterRoom = true
end

--准备应答
function DaiGouTuiGameLogic:on_ready_rsp(eventData)
	--清除牌桌上的牌
	self:cleanDesk()
	if(tostring(eventData.err_no) == "0") then
		local roomInfo = self.modelData.curTableData.roomInfo
		local show_leave_invite = not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0
		self.view:show_leave_ready_invite_btn(show_leave_invite, false)
	end
end

--开始通知
function DaiGouTuiGameLogic:on_start_notify(eventData)
	if(eventData.err_no and eventData.err_no ~= '0')then
		return
	end
	self.isWaitingFaPai = true
	self.isFinishFaPai = false
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	roomInfo.state = 1
	roomInfo.isRoundStarted = true
end

--明牌响应
function DaiGouTuiGameLogic:on_table_show_cards_rsp(eventData)
	if(eventData.is_ok)then
		local roomInfo = self.modelData.curTableData.roomInfo
		local is_first_pattern = roomInfo.desk_player_id == 0 or roomInfo.desk_player_id == roomInfo.next_player_id
		local canDrop, pattern, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
		canBigger = canBigger or false
		self.view:showMingPaiBtn(false)
		self.view:showCallServantBtns(false)
		self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
		local enable = self:can_chu_pai()
		self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
	end
end

--明牌通知
function DaiGouTuiGameLogic:on_table_show_cards_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
	seatInfo.show_cards = eventData.show_or_not
	roomInfo.is_1v4 = eventData.is_1v4
	local fengDingText = ''
	if(roomInfo.is_1v4)then
		fengDingText = '一打四'
	end
	self.view:showFengDingText(true, fengDingText)

	if(seatInfo.show_cards)then
		seatInfo.handCodeList = {}
		for i=1,#eventData.cards do
			seatInfo.handCodeList[i] = eventData.cards[i]
		end
		local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
		local handCardSet = CardSet.new(seatInfo.handCodeList, #seatInfo.handCodeList)
		handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, seatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
		seatInfo.handCodeList = handCardSet.cards
		
		if(seatInfo.playerId == eventData.servant_player_id)then
			roomInfo.servant_player_id = eventData.servant_player_id
			seatInfo.isServant = true
			self.view:showSeatServantIcon(seatInfo.localSeatIndex, true)
			self.tableSound:playServantCardShowEffectSound()
		end

		if(mySeatInfo == seatInfo)then
			self.view:showMingPaiBtn(false)
			self.view:showMingPaiTag(mySeatInfo.localSeatIndex, true)
		else
			self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
			self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList, roomInfo.servant_card)
			local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
			seatHolder.handPokerHolder.isChouTiOpen = true
			self.view:showChouTi(seatInfo.localSeatIndex, seatHolder.handPokerHolder.isChouTiOpen)
		end

		self.view:playMingPaiEffect(seatInfo)
		--显示明牌标签、播放音效
		if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
			self.tableSound:playMingPaiSound(false)
		else
			self.tableSound:playMingPaiSound(true)
		end
	else

	end
end

--叫狗腿应答
function DaiGouTuiGameLogic:on_table_callservant_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)	
		return
	end
	self.view:showCallServantBtns(false)
end

--叫狗腿通知
function DaiGouTuiGameLogic:on_table_callservant_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	roomInfo.servant_card = eventData.servant_card
	self.view:playSelectServantCardAnim(roomInfo.servant_card)
	roomInfo.need_call_servant = false
	if(roomInfo.next_player_id == mySeatInfo.playerId and mySeatInfo.isLord)then
		local canDrop, pattern, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
		canBigger = canBigger or false
		if(roomInfo.can_apply_showcard)then
			self.view:showMingPaiBtn(true, true)
			self.view:showChuPaiButtons(false)
		end
	end
	self.view:showCallServantBtns(false)
	self.myHandPokers.servantCard = roomInfo.servant_card
	self.myHandPokers:repositionPokers(nil, true)
	if(not mySeatInfo.isLord)then
		local hasServantCard = mySeatInfo.handCardSet:count(roomInfo.servant_card) == 1
		mySeatInfo.isServant = mySeatInfo.isServant or hasServantCard
		self.view:showSeatServantIcon(mySeatInfo.localSeatIndex, mySeatInfo.isServant)
	end
end


--出牌响应
function DaiGouTuiGameLogic:on_table_discard_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)	
		return
	end
	self.discard_serno = eventData.discard_serno
	self.tiShiFunction = nil

	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	mySeatInfo.handCodeList = {}
	for i=1,#eventData.cards do
		mySeatInfo.handCodeList[i] = eventData.cards[i]
	end
	
	mySeatInfo.leftCardCount = #eventData.cards
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	self.view:showChuPaiButtons(false)
	self.view:showMingPaiBtn(false)
	self:re_sort_myhandcards()
end

--出牌通知
function DaiGouTuiGameLogic:on_table_discard_notify(eventData)
	self.discard_notify_received = true
	self.discard_serno = eventData.discard_serno
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfoList = roomInfo.seatInfoList
	
    local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
	local last_warning_flag = seatInfo.warning_flag
    seatInfo.warning_flag = eventData.warning_flag == 1
    seatInfo.leftCardCount = eventData.rest_card_cnt
	seatInfo.last_multiple = seatInfo.multiple
	seatInfo.multiple = eventData.multiple

	local lastDisCardSeatInfo = roomInfo.lastDisCardSeatInfo
	if(eventData.is_first_pattern)then
		roomInfo.lastDisCardSeatInfo = nil
	else
		if(not eventData.is_passed)then
			roomInfo.lastDisCardSeatInfo = seatInfo
		end
	end
    roomInfo.next_player_id = eventData.next_player_id
	roomInfo.can_apply_showcard = eventData.can_apply_showcard
	roomInfo.bomb_cnt = eventData.bomb_cnt
	roomInfo.is_1v4 = eventData.is_1v4
	local fengDingText = ''
	if(roomInfo.is_1v4)then
		fengDingText = '一打四'
	end
	self.view:showFengDingText(true, fengDingText)

	if(seatInfo.playerId == eventData.servant_player_id)then
		roomInfo.servant_player_id = eventData.servant_player_id
		seatInfo.isServant = true
	end
	local hasServantCard = false
    local onFinish = function()
		if(hasServantCard)then
			self.tableSound:playServantCardShowEffectSound()
		end
		if(not eventData.is_passed)then
			local male = (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) or false
			if(seatInfo.leftCardCount == 1)then
				self.tableSound:playWarningSound(male, true)
			elseif(seatInfo.leftCardCount == 2)then
				self.tableSound:playWarningSound(male, false)
			end
		end

		if(self:need_show_xipai())then
			if(seatInfo.multiple and seatInfo.multiple > 0)then
				self.view:playXiPaiMultipleTag(seatInfo.localSeatIndex, true, seatInfo.last_multiple, seatInfo.multiple, seatInfo.last_multiple == seatInfo.multiple)
			else
				self.view:playXiPaiMultipleTag(seatInfo.localSeatIndex, false)
			end
		end


        for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, seatInfo.leftCardCount <= 10 or roomInfo.ruleTable.showCardsCount)
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, (seatInfo.leftCardCount <= 10 or roomInfo.ruleTable.showCardsCount) and seatInfo ~= mySeatInfo, seatInfo.leftCardCount)
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, seatInfo.warning_flag or false)
			self.view:showSeatServantIcon(seatInfo.localSeatIndex, seatInfo.isServant)
			if(seatInfo.playerId == eventData.servant_player_id)then

			end
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
			if(roomInfo.can_apply_showcard)then
				self.view:showMingPaiBtn(true)
				self.view:showChuPaiButtons(false)
			else
				local canDrop, pattern, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
				canBigger = canBigger or false
				local is_first_pattern = eventData.is_first_pattern
				if(is_first_pattern and canDrop and pattern)then
					--先显示后逻辑start
					mySeatInfo.round_discard_pattern = pattern
					self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

					self:refreshMySeatDiscardView()				
					--end
					self.model:request_discard(false, pattern.cards, self.discard_serno)
				else
					self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
					local enable = self:can_chu_pai()
					self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
				end
			end
		end
    end

	self.view:showSeatClock(seatInfo.localSeatIndex, false)
    if(eventData.is_passed)then
        seatInfo.round_discard_cnt = 0
        seatInfo.round_discard_info = {}
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
        seatInfo.round_discard_cnt = #eventData.cards or 0
		seatInfo.round_discard_info = {}
		for i=1,#eventData.cards do
			seatInfo.round_discard_info[i] = eventData.cards[i]
			roomInfo.desk_cards[i] = eventData.cards[i]
		end

		local cardPattern = CardPattern.new(seatInfo.round_discard_info, roomInfo.servant_card, seatInfo.isLord, seatInfo.roomInfo.ruleTable.most_great_servant_card_1v4 or false)
		cardPattern.type = eventData.type
		cardPattern.value = eventData.value
		if(cardPattern)then
			hasServantCard = cardPattern:count(roomInfo.servant_card) == 1
			seatInfo.round_discard_pattern = cardPattern
		else
			seatInfo.round_discard_pattern = nil
		end
		 
		 if(seatInfo == mySeatInfo)then
        --播放出牌动画		
		--self:dispatchPoker(seatInfo, nil, onFinish)
			 if(not lastDisCardSeatInfo)then
				 self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, nil)
			 else
				 self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, lastDisCardSeatInfo.round_discard_pattern)
			 end
			onFinish()
		 else
			 --播放出牌动画
			 self:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
			 if(not lastDisCardSeatInfo)then
				 self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, nil)
			 else
				 self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, lastDisCardSeatInfo.round_discard_pattern)
			 end
			 self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
			 if(seatInfo.show_cards)then
				 self:removeCodeListFromList(seatInfo.handCodeList, seatInfo.round_discard_info)
				 self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
				 local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
				 local handCardSet = CardSet.new(seatInfo.handCodeList, #seatInfo.handCodeList)
				 handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, seatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
				 seatInfo.handCodeList = handCardSet.cards
				 self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList, roomInfo.servant_card)
			 end
		 end


		--牌已出完
		if(seatInfo.leftCardCount == 0)then
		else
			
		end
    end
end

--结算通知
function DaiGouTuiGameLogic:on_table_currentaccount_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local is_summary_account = eventData.is_summary_account
	if(not is_summary_account)then
		self.is_showing_round_settle = true
	end
	local onFinishDelay = function()
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			self.view:refreshSeatState(seatInfo)
			self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, false)
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, false)
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
			self.view:showSeatLandLordIcon(seatInfo.localSeatIndex, false)
			self.view:showSeatServantIcon(seatInfo.localSeatIndex, false)
		end

		self.view:showReadyBtn(false)
		self.view:showChuPaiButtons(false)

		self:cleanDesk(true)
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
			
			seatInfo.score = tmpPlayer.score
			player.isRoomCreator = seatInfo.isCreator or false
			player.isShowCard = seatInfo.show_cards
			self.view:refreshSeatState(seatInfo)
			player.bond_score = tmpPlayer.bond_score
			player.nongmin_times = tmpPlayer.farmer_cnt
			player.xipai_times = tmpPlayer.bond_pattern_cnt
			player.dizhu_times = tmpPlayer.lord_cnt
			player.goutui_times = tmpPlayer.servant_cnt

			player.totalScore = tmpPlayer.score or 0
			player.score = tmpPlayer.current_score or 0
			player.cards = {}
			if(eventData.need_show_round_settle)then
				for i = 1, #tmpPlayer.cards do
					local code = tmpPlayer.cards[i]
					table.insert(player.cards, code)
				end
				self.myHandPokers:sortCodeList(player.cards)
			end


			if(tmpPlayer.identity == 1)then
				player.isLord = true
			elseif(tmpPlayer.identity == 2)then
				player.isServant = true
			elseif(tmpPlayer.identity == 3)then
				player.isFarmer = true
			end

			data.players[i] = player
		end
		table.sort(data.players, function(p1,p2)
			return p1.seatIndex < p2.seatIndex
		end)
		data.roomInfo = roomInfo
		data.roomInfo.roomTitle = TableUtil.get_rule_name(roomInfo.rule)
		data.base_score = eventData.base_score or roomInfo.ruleTable.baseScore
		data.multiple = eventData.show_card_multiple
		data.startTime = eventData.startTime
		data.endTime = eventData.endTime
		data.free_sponsor = eventData.free_sponsor	--申请解散者id
		data.myPlayerId = mySeatInfo.playerId
		data.lordid = eventData.lordid
		if(self:need_show_xipai())then
			data.hideXiPai = false
		else
			--江苏五人斗地主
			data.hideXiPai = true
		end
		if(roomInfo.ruleTable.game_type == 0)then
			data.roomDesc = '经典玩法'
		end

		for i,v in ipairs(data.players) do
			if(v.playerId == mySeatInfo.playerId)then
				if(v.score < 0)then
					self.tableSound:playGameLoseSound()
				else
					self.tableSound:playGameWinSound()
				end
			end
		end
		if(not is_summary_account)then
			self.is_showing_round_settle = true
			self:showAllSeatLeftCards(true, data.players)
			ModuleCache.ModuleManager.show_module(self.module.packageName, "onegameresult", data)
		else
			self.module.TableManager:disconnect_game_server()
			ModuleCache.net.NetClientManager.disconnect_all_client()
			ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
			self.summary_account_fun = function()
				self.tableSound:playMathWinSound()
				ModuleCache.ModuleManager.show_module(self.module.packageName, "tableresult", data)
				self.modelData.curTableData.roomInfo = nil	
			end
			if(not self.is_showing_round_settle)then
				self.summary_account_fun()
			end
		end
	end
	if(self.discard_notify_received)then
		self.discard_notify_received = nil
		if(not is_summary_account)then
			self.module:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
				onFinishDelay()
			end)
		else
			onFinishDelay()
		end
	else
		onFinishDelay()
	end
end

function DaiGouTuiGameLogic:on_reset_notify(evenData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		seatInfo.isReady = false
		seatInfo.show_cards = false
		seatInfo.handCodeList = {}
		seatInfo.round_discard_cnt = 0
		seatInfo.leftCardCount = 0
		seatInfo.round_discard_info = nil
		seatInfo.beishu = 1
		seatInfo.bomb_cnt = 0
		seatInfo.grablord_score = -1
		seatInfo.isLord = false
		seatInfo.isServant = false
	end
	roomInfo.state = 0
	roomInfo.isRoundStarted = false
	roomInfo.lordid = 0
	
end

function DaiGouTuiGameLogic:on_table_gameinfo_notify(eventData)
	self:initTableData(eventData)
	--初始化主牌
	
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	if(not mySeatInfo.isLord)then
		local hasServantCard = mySeatInfo.handCardSet:count(roomInfo.servant_card) == 1
		mySeatInfo.isServant = mySeatInfo.isServant or hasServantCard
	end

	self.myHandPokers.on_finish_drag_pokers_reselect_fun = function()
		self:on_finish_drag_pokers_reselect_fun()
	end
	self.myHandPokers.on_select_pokers_changed = function()
		local enable = self:can_chu_pai()
		self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
	end
	self.view:showKickBtns(false and mySeatInfo.isCreator and roomInfo.curRoundNum == 0 and (not roomInfo.isRoundStarted), mySeatInfo.localSeatIndex)
	self.view:SetRuleBtnActive(true)

	local is_first_pattern = roomInfo.desk_player_id == 0 or roomInfo.desk_player_id == roomInfo.next_player_id
	if(is_first_pattern)then
		roomInfo.lastDisCardSeatInfo = nil
	else
		roomInfo.lastDisCardSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.desk_player_id, seatInfoList)
	end
	
	self.module:on_enter_room_event(roomInfo)
	
	--设置牌局和房间信息
	local wanfaName = '经典玩法'
	self.view:setRoomInfo(roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount, wanfaName)

	local fengDingText = ''
	if(roomInfo.is_1v4)then
		fengDingText = '一打四'
	end
	self.view:showFengDingText(true, fengDingText)

	local playerCount = 0
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, false)
		self.view:refreshSeatState(seatInfo, seatInfo.lastLocalSeatIndex)
		self.view:showSeatLandLordIcon(seatInfo.localSeatIndex, seatInfo.isLord)
		self.view:showSeatServantIcon(seatInfo.localSeatIndex, seatInfo.isServant)
		if(seatInfo.lastLocalSeatIndex == seatInfo.localSeatIndex)then
			self.view:refreshSeatPlayerInfo(seatInfo)
			self.view:refreshSeatOfflineState(seatInfo)
		else

		end
		if(seatInfo.playerId ~= 0)then
			playerCount = playerCount + 1
		end
		--显示明牌
		if(seatInfo.show_cards)then
			if(seatInfo ~= mySeatInfo)then
				self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
				self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList, roomInfo.servant_card)
			else
				self.view:showMingPaiTag(seatInfo.localSeatIndex, true)
			end
		else
			self.view:showMingPaiTag(seatInfo.localSeatIndex, false)
			self.view:showSeatHandPokers(seatInfo.localSeatIndex, false)
		end
		
	end

	--显示离开按钮
	if(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0)then
		self.module:refresh_share_clip_board()
	end
	self.view:show_leave_ready_invite_btn(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0, not mySeatInfo.isReady)


	self.view:showChuPaiButtons(false)
	self.view:showServantCards(false)

	if(self.isEnterRoom)then
		self.isEnterRoom = false
	end
	local initFunction = function()
		self.isFinishFaPai = true
		--判断游戏是否已经开局
		if(roomInfo.isRoundStarted)then
			self.view:showLiPaiBtn(true)
			self.view:showServantCards(true, roomInfo.servant_card)
			for i=1,#seatInfoList do
				local seatInfo = seatInfoList[i]
				self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, seatInfo.leftCardCount <= 10 or roomInfo.ruleTable.showCardsCount)
				self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, (seatInfo.leftCardCount <= 10  or roomInfo.ruleTable.showCardsCount) and seatInfo ~= mySeatInfo, seatInfo.leftCardCount)
				self.view:showSeatWarningIcon(seatInfo.localSeatIndex, seatInfo.warning_flag or false)
				if(self:need_show_xipai())then
					self.view:playXiPaiMultipleTag(seatInfo.localSeatIndex, seatInfo.multiple and seatInfo.multiple > 0,seatInfo.last_multiple, seatInfo.multiple, true)
				end

				if(seatInfo.round_discard_cnt == 0)then --已过牌
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, true)
				elseif(seatInfo.round_discard_cnt > 0)then --已出牌
					self:sort_pattern_by_type(seatInfo.round_discard_pattern)
					local cards = seatInfo.round_discard_pattern.sorted_cards
					self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, roomInfo.servant_card, true)
				else
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, false, true)
				end

				if(seatInfo.playerId == roomInfo.next_player_id)then
					self.view:showSeatClock(seatInfo.localSeatIndex, true, seatInfo == mySeatInfo)
					--清除下一个出牌玩家的桌面
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
					self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
				end
			end
			if(roomInfo.block_operation == 1)then		--地主无炸弹
				self.view:showTips(true, '不符合开局流程，重新发牌')
				if(mySeatInfo.isLord)then
					self.module:subscibe_time_event(3, false, 0):OnComplete(function(t)
						self.model:request_redeal_cards()
					end)
				end
				self.view:showCallServantBtns(false, false, true)
				return
			elseif(roomInfo.block_operation == 2)then		--地主无法叫狗腿
				if(mySeatInfo.isLord and roomInfo.need_call_servant)then
					self.view:showCallServantBtns(true, false, false)
				end
			elseif(roomInfo.next_player_id == mySeatInfo.playerId)then
				local canDrop, pattern, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
				canBigger = canBigger or false
				if(roomInfo.can_apply_showcard)then
					if(mySeatInfo.isLord)then
						if(roomInfo.need_call_servant)then
							self.view:showCallServantBtns(true, true, false)
						else
							self.view:showCallServantBtns(false)
							self.view:showMingPaiBtn(true)
							self.view:showChuPaiButtons(false)
						end
					else
						self.view:showMingPaiBtn(true)
						self.view:showChuPaiButtons(false)
					end
				elseif(is_first_pattern and canDrop and pattern)then
					--先显示后逻辑start
					mySeatInfo.round_discard_pattern = pattern
					self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

					self:refreshMySeatDiscardView()
					--end
					self.model:request_discard(false, pattern.cards, self.discard_serno)
				else
					self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
					local enable = self:can_chu_pai()
					self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
				end
			end
		else
			self.view:showMingPaiBtn(false)
			self.view:showCallServantBtns(false)
		end
	end
	self.view:showLiPaiBtn(false)
	if(self.isWaitingFaPai)then
		self.isWaitingFaPai = false
		local fapaiFun = function(onFinish)
			local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
			mySeatInfo.handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, mySeatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
			mySeatInfo.handCodeList = mySeatInfo.handCardSet.cards
			self.myHandPokers:removeAll()
			self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, nil, false)
			self.myHandPokers:show_handPokers(true, false)
			self.myHandPokers:resetPokers(true)
			self.myHandPokers:playFaPaiAnim(onFinish, function()
				self.tableSound:playFaPaiSound()
			end)
			self.selected_chupai_PokerHolders = {}
			self.selected_chupai_CodeList = {}
		end
		fapaiFun(initFunction)
	elseif(not self.isFinishFaPai)then
		
	else
		local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
		mySeatInfo.handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, mySeatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
		mySeatInfo.handCodeList = mySeatInfo.handCardSet.cards
		self.myHandPokers:removeAll()
		self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, nil)
		self.myHandPokers:show_handPokers(true, true)
		self.myHandPokers:resetPokers(true)
		self.selected_chupai_PokerHolders = {}
		self.selected_chupai_CodeList = {}
		initFunction()
	end


end

--重新发牌响应
function DaiGouTuiGameLogic:on_table_redealcard_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)
		return
	end
end

--重新发牌通知
function DaiGouTuiGameLogic:on_table_redealcard_notify(eventData)
	self.view:showCallServantBtns(false)
	self:cleanDesk()
	if(eventData.reason == 1)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('地主无炸弹，重新发牌')
	elseif(eventData.reason == 2)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('地主无法叫狗腿，选择重新发牌')
	end
end


function DaiGouTuiGameLogic:cleanDesk(ignoreDispatchPokers)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	self.view:showMingPaiTag(mySeatInfo.localSeatIndex, false)
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(ignoreDispatchPokers)then

		else
			self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
			self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		end
		self.view:showSeatHandPokers(seatInfo.localSeatIndex, false)
		self.view:showSeatClock(seatInfo.localSeatIndex, false)
		self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
		self.view:playXiPaiMultipleTag(seatInfo.localSeatIndex, false)
	end
	self.view:showCallServantBtns(false)
	self.view:showLiPaiBtn(false)
	self.myHandPokers:resetPokers(true)
	self.myHandPokers:removeAll()
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
	self.view:showTips(false)
end


function DaiGouTuiGameLogic:on_next_grablord(playerId, scoreList)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local nextSeatInfo = self.module:getSeatInfoByPlayerId(playerId, seatInfoList)
	if(nextSeatInfo == mySeatInfo)then
		self.view:showGrabLordBtns(true, scoreList)
	end
	--显示下一个叫分的玩家
	self.view:showSeatClock(nextSeatInfo.localSeatIndex, true, nextSeatInfo == mySeatInfo)
end

--初始化牌桌数据
function DaiGouTuiGameLogic:initTableData(data)
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
	roomInfo.can_apply_showcard = data.can_apply_showcard		--下一个玩家是否可以明牌
	roomInfo.need_call_servant = data.can_call_servant
	roomInfo.is_1v4 = data.is_1v4
	roomInfo.block_operation = data.block_operation				--阻塞操作 1 地主无炸弹 2 地主无法叫狗腿
	roomInfo.desk_cards = {}
	if(data.desk_cards)then
		for i=1,#data.desk_cards do
			roomInfo.desk_cards[i] = data.desk_cards[i]
		end
	end

	roomInfo.timeOffset = data.time - os.time()

	roomInfo.state = data.state

	roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
	roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
	CardCommon.enableSequentialSingle = roomInfo.ruleTable.enableSequentialSingle
	CardCommon.enableBondCardScore = roomInfo.ruleTable.enableBondCardScore
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc

	roomInfo.lordid = data.lord_player_id		--地主id
	roomInfo.servant_card = data.servant_card 	--狗腿牌
	self.myHandPokers.servantCard = roomInfo.servant_card
	roomInfo.servant_player_id = data.servant_player_id	--狗腿id
	roomInfo.isRoundStarted = roomInfo.state ~= 0
	self.discard_serno = data.discard_serno

	local seatInfoList
	local seatCount = 5
	if(self.isEnterRoom)then
		seatInfoList = {}
		for i=1,seatCount do
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
			seatInfo.isLord = false
			seatInfo.isServant = false
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
		seatInfo.warning_flag = remotePlayerInfo.warning_flag--是否报警
		seatInfo.score = remotePlayerInfo.score
		seatInfo.winTimes = remotePlayerInfo.win_cnt
		seatInfo.lostTimes = remotePlayerInfo.lost_cnt
		seatInfo.leftCardCount = remotePlayerInfo.rest_card_cnt	--剩余手牌数
		seatInfo.multiple = remotePlayerInfo.multiple		--倍数
		seatInfo.isLord = data.lord_player_id == seatInfo.playerId
		seatInfo.isServant = data.servant_player_id == seatInfo.playerId

		seatInfo.show_cards = remotePlayerInfo.show_card		--是否明牌
		seatInfo.round_discard_cnt = remotePlayerInfo.round_discard_cnt or -1	--本轮出牌情况 -1 还未轮到 0 已过牌 其他表示出牌数量
		--print(seatInfo.localSeatIndex, seatInfo.round_discard_cnt, remotePlayerInfo.round_discard_cnt)
		seatInfo.round_discard_info = {}
		if(remotePlayerInfo.round_discard_info)then	--当前出牌
			for i=1,#remotePlayerInfo.round_discard_info do
				seatInfo.round_discard_info[i] = remotePlayerInfo.round_discard_info[i]
			end
		end

		local cardPattern = CardPattern.new(seatInfo.round_discard_info, roomInfo.servant_card, seatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
		if(cardPattern)then
			cardPattern.type = remotePlayerInfo.round_discard_type
			cardPattern.value = remotePlayerInfo.round_discard_value
			seatInfo.round_discard_pattern = cardPattern
		else
			seatInfo.round_discard_pattern = nil
		end

		if(seatInfo.show_cards)then
			seatInfo.handCodeList = {}
			for i=1,#remotePlayerInfo.cards do
                seatInfo.handCodeList[i] = remotePlayerInfo.cards[i]
            end
			local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
			local handCardSet = CardSet.new(seatInfo.handCodeList, #seatInfo.handCodeList)
			handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, seatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
			seatInfo.handCodeList = handCardSet.cards
		end
		

		if(seatInfo.playerId == tonumber(self.modelData.curTablePlayerId))then
			seatInfo.handCodeList = {}
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
	end

	roomInfo.seatInfoList = seatInfoList	
	self.modelData.curTableData.roomInfo = roomInfo
end

--播放牌型音效
function DaiGouTuiGameLogic:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	local disp_type = cardPattern.disp_type
	if(type == CardCommon.type_bomb)then	--炸弹
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.type_triple_p2)then	--3带2
		self.view:playSanDaiErEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_double)then	--连对
		self.view:playLianDuiEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_triple_p2)then --蝴蝶
		self.view:playHuDieEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_single)then --顺子
		self.view:playShunZiEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_triple)then	--三顺
		self.view:playSanShunEffect(seatInfo)
	end

end

--播放不出音效
function DaiGouTuiGameLogic:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

--判断是否能够出牌
function DaiGouTuiGameLogic:checkCanChuPai(srcPattern, codeList, seatInfo)
	local selectedPattern = CardPattern.new(codeList, seatInfo.roomInfo.servant_card, seatInfo.isLord, seatInfo.roomInfo.ruleTable.most_great_servant_card_1v4 or false)
	if(not selectedPattern)then
		return false
	end
	if(not srcPattern)then
		if(not selectedPattern)then
			print('not selectedPattern')
			return false
		else
			return true, selectedPattern
		end
	else
		local pattern = selectedPattern
		local compable = pattern:compable(srcPattern)
		if(not compable)then
			-- print('not compable', pattern.type, srcPattern.type)
			return false
		else
			local le = pattern:le(srcPattern)
			if(le)then
				-- print('le', pattern.type, srcPattern.type)
				return false
			else
				return true, pattern
			end
		end
	end

end


function DaiGouTuiGameLogic:getDisplayNameFromName(card_name)
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

function DaiGouTuiGameLogic:seatIndex_pos(srcSeatIndex, dstSeatIndex)
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


function DaiGouTuiGameLogic:sort_pattern_by_type(pattern)
	pattern.sorted_cards = {}
	for i=1,#pattern.cards do
		pattern.sorted_cards[i] = pattern.cards[i]
	end
end

--自己打完牌后刷新手牌和桌面
function DaiGouTuiGameLogic:refreshMySeatDiscardView()
	self.view:showChuPaiButtons(false)
	self.myHandPokers:removePokerHolders(self.selected_chupai_PokerHolders)
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
	self.selected_chupai_PokerHolders = {}
	self.selected_chupai_CodeList = {}
end

--出牌动画、音效播放
function DaiGouTuiGameLogic:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
	self:sort_pattern_by_type(seatInfo.round_discard_pattern)
	local cards = seatInfo.round_discard_pattern.sorted_cards
	local roomInfo = seatInfo.roomInfo
	self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, roomInfo.servant_card, false, onFinish)
end


--是否能够一手丢
function DaiGouTuiGameLogic:can_drop_cards(lastDisCardSeatInfo)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local lastCardPattern = nil
	if(lastDisCardSeatInfo)then
		lastCardPattern = lastDisCardSeatInfo.round_discard_pattern
	end
	local tiShiFunction, count = mySeatInfo.handCardSet:hintIterator(lastCardPattern, roomInfo.servant_card, mySeatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
	if(tiShiFunction and count > 0)then
		--自动甩牌不要了
		for i=1,count do
			local pattern = tiShiFunction()
			if(pattern and #pattern.cards == #mySeatInfo.handCodeList)then
				self.myHandPokers:selectPokers(pattern.cards)
				self.myHandPokers:refreshPokerSelectState(true)
				local selectedPokerHolders, selectPokerList, selectedCodeList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList = self.myHandPokers:getSelectedPokers()
				self.selected_chupai_PokerHolders = real_selectedPokerHolders
				self.selected_chupai_cardPattern = pattern
				return true, pattern, true
			end
		end
		return false, nil, true
	else
		return false
	end
	return false
end

function DaiGouTuiGameLogic:playBgm()
	self.tableSound:playBgm()
end


function DaiGouTuiGameLogic:testfun()
	local pokerHolderList = self.myHandPokers:genPokerHolderList({20,21,22}, nil, true)
	self.myHandPokers:resetPokers(false, function()
		for i=1,#pokerHolderList do
			local pokerHolder = pokerHolderList[i]
			self.myHandPokers:playSelectPokerAnim(pokerHolder.root, true, true)
		end
		self.myHandPokers:show_handPokers(true, true)
		self.module:subscibe_time_event(1, false, 0):OnComplete(function(t)	
			for i=1,#pokerHolderList do
				local pokerHolder = pokerHolderList[i]
				self.myHandPokers:playSelectPokerAnim(pokerHolder.root, false, false)
			end
		end)
	end)

end

function DaiGouTuiGameLogic:on_finish_drag_pokers_reselect_fun(onFinish)
	local pokerHolderList, pokerList, selectedCodeList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList = self.myHandPokers:getSelectedPokers()
	if(#selectedCodeList > 0)then
		self.myHandPokers:selectPokers(selectedCodeList)
		self.is_playing_select_poker_anim = true
		self.myHandPokers:refreshPokerSelectState(false, function()
			self.is_playing_select_poker_anim = false
			if(onFinish)then
				onFinish()
			end
		end)
	end
	if(onFinish)then
		onFinish()
	end
end

function DaiGouTuiGameLogic:removeCodeListFromList(srcCodeList, codeList)
	local removeFromCodeList = function(code, list)
		for i=1,#list do
			if(code == list[i])then
				table.remove( list, i)
				return true
			end
		end
		return false
	end
	for i=1,#codeList do
		if( not removeFromCodeList(codeList[i], srcCodeList))then
			print('code 不在list中')
		end
	end
end

--播放定地主特效
function DaiGouTuiGameLogic:playSetLordEffect(seatInfo, onFinish1, onFinish2)
	local go
	go = self.view:playLordEffect(function()
		local sequence = self.module:create_sequence()
		local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
		local dstPos = seatHolder.goEffect_dizhu.transform.position
		local duration = 0.7
		sequence:Append(go.transform:DOMove(dstPos, duration, false))
		sequence:OnComplete(function ()
			if(onFinish1)then
				onFinish1()
			end
			self.module:subscibe_time_event(0.3, false, 0):OnComplete(function ()
				ModuleCache.ComponentUtil.SafeSetActive(go, false)
			end)
			self.view:playSetLordEffect(seatInfo, onFinish2)
		end)
	end)
end

function DaiGouTuiGameLogic:on_click_gameresule_continue_btn()
	self.is_showing_round_settle = false
	self:showAllSeatLeftCards(false)
	if(self.summary_account_fun)then
		self.summary_account_fun()
	else
		self.model:request_ready()
	end
end

function DaiGouTuiGameLogic:showAllSeatLeftCards(show, players)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	if(show)then
		for i=1,#players do
			local player = players[i]
			local seatInfo = self.module:getSeatInfoByPlayerId(player.playerId, seatInfoList)
			if(seatInfo == mySeatInfo)then
				local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
				mySeatInfo.handCardSet:SortByPattern(sort_pattern_type, roomInfo.servant_card, mySeatInfo.isLord, roomInfo.ruleTable.most_great_servant_card_1v4 or false)
				mySeatInfo.handCodeList = mySeatInfo.handCardSet.cards
				self.myHandPokers:removeAll()
				self.myHandPokers:genPokerHolderList(player.cards, nil)
				self.myHandPokers:show_handPokers(true, true)
				self.myHandPokers:resetPokers(true)
				self.selected_chupai_PokerHolders = {}
				self.selected_chupai_CodeList = {}
			else
				self.view:showLeftHandCards(seatInfo.localSeatIndex, true, player.cards, roomInfo.servant_card)
			end
			
		end
	else
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			if(seatInfo == mySeatInfo)then
				self.myHandPokers:resetPokers(true)
				self.myHandPokers:removeAll()
				self.myHandPokers:repositionPokers(nil, true)
			else
				self.view:showLeftHandCards(seatInfo.localSeatIndex, false)
			end
		end
	end
end

function DaiGouTuiGameLogic:need_show_xipai()
	local ruleTable = self.modelData.curTableData.roomInfo.ruleTable
	return ruleTable.enableBondCardScore
end

return DaiGouTuiGameLogic