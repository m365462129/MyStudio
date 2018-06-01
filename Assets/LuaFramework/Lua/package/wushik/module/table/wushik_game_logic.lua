
local class = require("lib.middleclass")
local list = require('list')
---@class WuShiKGameLogic
---@field view WuShiKTableView
---@field myHandPokers WuShiKHandPokers
local GameLogic = class('GameLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence
---@type WuShiK_CardCommon
local CardCommon = require('package.wushik.module.table.gamelogic_common')
local cardCommon = CardCommon
---@type WuShiK_CardPattern
local CardPattern = require('package.wushik.module.table.gamelogic_pattern')
---@type WuShiK_CardSet
local CardSet = require('package.wushik.module.table.gamelogic_set')
local CardSort = require('package.wushik.module.table.gamelogic_sort')
local tableSound = require('package.wushik.module.table.table_sound')
--是否打开自动甩牌功能
local open_drop_cards = false

function GameLogic:initialize(module)
    self.module = module    
    self.modelData = module.modelData
    self.view = module.view
    self.model = module.model
    self.myHandPokers = module.myHandPokers
	self.tableSound = tableSound
	self.isFinishFaPai = true
	--self:testFaPai()
end

function GameLogic:genPokers()
	local list = {}
	for i=0,26 do
		local code = i % 13 + 1
		table.insert( list, code)
		self.myHandPokers:genPokerHolderList({code}, nil, true)
	end	
end

function GameLogic:testFaPai()
	self.myHandPokers:removeAll()
	self:genPokers()
	self.myHandPokers:show_handPokers(true, false)
	self.myHandPokers:resetPokers(true)
	self.myHandPokers:playFaPaiAnim()
	self.myHandPokers.custom_on_finish_drag_pokers_fun = function()
		self:on_select_liang_pai()
	end
end

function GameLogic:testResult()
	 local data = {
	 	curAccountData = {},
	 	roomInfo = {roomNum=11111},
	 	packageName = self.module.packageName
	 }
	 data.curAccountData.players = {}
	 for i=1,4 do
	 	local player = {}
	 	player.player_id = 180 + i
	 	player.uid = player.player_id
	 	player.nickname = player.player_id
	 	player.playerName = player.player_id
	 	player.score = i
	 	player.win_cnt = i
	 	player.lost_cnt = i
	 	data.curAccountData.players[i] = player
	 end
	 ModuleCache.ModuleManager.show_module('public', "poker_tableresult", data)
end

function GameLogic:testDiscards()
	self.view:resetSeatHolderArray(4)
	local cards = {}
	for i=0,25 do
		local code = i % 13 + 1
		table.insert(cards, code)
	end
	self.view:playDispatchPokers(1, true, cards, {},false, nil)
	self.view:playDispatchPokers(2, true, cards, {},false, nil)
	self.view:playDispatchPokers(3, true, cards, {},false, nil)
	self.view:playDispatchPokers(4, true, cards, {},false, nil)
end

function GameLogic:testPlayDuPaiAnim()
	self.view:resetSeatHolderArray(4)
	self.tableSound:playDuPaiEffectSound()
	self.view:showSeatLordTag(1, false)
	self.view:playDuPaiAnim(1, function()
		self.view:showSeatLordTag(1, true)
	end)
end

function GameLogic:testPlayJiaoJiAnim()
	self.view:resetSeatHolderArray(4)
	self.tableSound:playFriendEffectSound()
	self.view:showSeatFriendTag(2, false)
	self.view:playAppearTeamMateAnim(2, function()
		self.view:showSeatFriendTag(2, true)
	end)
end

function GameLogic:testJiapPaiAnim()
	self.view:resetSeatHolderArray(4)
	self.tableSound:playJiaoPaiEffectSound()
	self.view:playConfirmTeamCardAnim(53, function()

	end)
	self.view:playOwnTeamCardTipAnim()
end

function GameLogic:testShowOwnTipsAnim()
	self.view:playOwnTeamCardTipAnim()
end

function GameLogic:testPattern()
	local codeList = {
		53,
		53,
		54,
		54,
		1,
		1,
		2,
		2,
		3,
		3,
		4,
		4,
	}
	local logicCodeList = {
		2,
		2,
		2,
		2,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
	}

	--是否使用第1种（黄石玩法）牌型大小比较序列
	CardPattern.confirmPatternCompareSeqs(false)
	CardCommon.enableMagicCards(true)
	print_table(codeList, 'codeList #seatInfo.handCodeList'..27 )
	local selectedPatternList = CardPattern.new(codeList, logicCodeList, 27)
	print_table(selectedPatternList)
end

function GameLogic:on_select_liang_pai(onFinish)
	local pokerHolderList, pokerList, selectedCodeList, selectedIdList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList, real_selectedIdList = self.myHandPokers:getSelectedPokers()
	table.sort(pokerHolderList, function(t1, t2)
		return t1.selected_time > t2.selected_time
	end)
	if(#selectedCodeList > 0)then
		self.myHandPokers:selectPokerHolders({pokerHolderList[1]})
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

function GameLogic:on_show()
    
end

function GameLogic:on_hide()
    
end

function GameLogic:update()

end

function GameLogic:on_destroy()
	self.showResultViewSmartTimer = nil
	if(self.timerMap)then
		for k,v in pairs(self.timerMap) do
			SmartTimer.Kill(v.id)
		end
	end
end


function GameLogic:on_press_up(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press_up(obj,arg)
	end
end

function GameLogic:on_drag(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_drag(obj,arg)
	end
end

function GameLogic:on_press(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press(obj,arg)
	end
end

function GameLogic:on_click(obj, arg)
	if(self.is_playing_select_poker_anim or self.myHandPokers.is_playing_select_poker_anim)then
		return
	end
	if(obj == self.view.imageMask.gameObject)then
		self.myHandPokers:resetPokers(true)
		--self:testDiscards()
		--self:testFaPai()
		--self:testPlayDuPaiAnim()
		--self:testPlayJiaoJiAnim()
		--self:testJiapPaiAnim()
		--self:testShowOwnTipsAnim()
	elseif(obj == self.view.buttonChuPai.gameObject)then
		self:on_click_chupai_btn(obj, arg)
	elseif(obj == self.view.buttonTiShi.gameObject)then
		self:on_click_tishi_btn(obj, arg)
	elseif(obj == self.view.buttonYaoBuQi.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif(obj == self.view.buttonBuChu.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif(obj == self.view.buttonRule.gameObject)then
		self:on_click_rule_info(obj, arg)
	elseif(obj == self.view.buttonLiPai.gameObject)then
		self:on_click_lipai_btn(obj, arg)
	elseif(obj == self.view.button50K.gameObject)then
		self:on_click_50k_btn(obj, arg)
	elseif(obj == self.view.buttonDuPai.gameObject)then
		self:on_click_du_pai_btn(obj, arg)
	elseif(obj == self.view.buttonBuDu.gameObject)then
		self:on_click_bu_du_btn(obj, arg)
	elseif(obj.name == 'KickBtn')then
		self:on_click_kick_btn(obj, arg)
	elseif(obj.transform.parent.gameObject == self.view.askWindowHolder.root)then
		self:on_click_ask_window_btns(obj, arg)
	elseif(obj.name == 'TestBtnReconnection')then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("点击触发断线重连")
		TableManagerPoker:heartbeat_timeout_reconnect_game_server()
	end
end


--------------------------------------------------------------------------
--按钮点击

--点击踢人按钮
function GameLogic:on_click_kick_btn(obj, arg)
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
function GameLogic:on_click_rule_info(obj, arg)
	ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
end

--点击离开按钮
function GameLogic:on_click_leave_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(mySeatInfo.isCreator)then
		self.model:request_dissolve_room(true)
	else
		self.model:request_exit_room()
	end
end


function GameLogic:on_click_buchu_btn(obj, arg)
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
	self.view:showChuPaiButtons(false)
	self.myHandPokers:resetPokers(true)
end


function GameLogic:on_click_tishi_btn(obj, arg)
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
		if(true)then
			return
		end
		--先显示后逻辑start
        mySeatInfo.round_discard_cnt = 0
        mySeatInfo.round_discard_info = {}
		mySeatInfo.round_discard_pattern = nil
        --播放不出动画
        self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
		self:playPassSound(mySeatInfo)
		--end

		self.model:request_discard(true, nil, self.discard_serno)
		self.view:showChuPaiButtons(false)
		self.myHandPokers:resetPokers(true)
		return
	end
	local pattern = self.tiShiFunction()
	if(not pattern)then
		if(true)then
			return
		end
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

function GameLogic:can_chu_pai()
	if(true)then
		return true
	end
	local selectedPokerHolders, selectPokerList, selectedCodeList, selectedIdList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList, real_selectedIdList = self.myHandPokers:getSelectedPokers()
	local lastPattern = nil
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(roomInfo.lastDisCardSeatInfo)then
		lastPattern = roomInfo.lastDisCardSeatInfo.round_discard_pattern
	end
	if(not real_selectedCodeList or #real_selectedCodeList == 0)then
		return false
	end
	local canChuPai, cardPatternList = self:checkCanChuPai(lastPattern, real_selectedCodeList, mySeatInfo)
	if(not canChuPai)then	
		return false
	end
	if(cardPatternList and #cardPatternList > 0)then
		return true
	end
	return false
end

function GameLogic:on_click_chupai_btn(obj, arg)
	local selectedPokerHolders, selectPokerList, selectedCodeList, selectedIdList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList, real_selectedIdList = self.myHandPokers:getSelectedPokers()
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
	local canChuPai, cardPatternList = self:checkCanChuPai(lastPattern, real_selectedCodeList, mySeatInfo)
	if(not canChuPai)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
		return
	end
	self.selected_chupai_PokerHolders = real_selectedPokerHolders
	self.selected_chupai_cardPatternList = cardPatternList

	if(cardPatternList and #cardPatternList > 0)then
		--先显示后逻辑start
		local cardPattern = cardPatternList[1]
		mySeatInfo.round_discard_pattern = cardPattern
		self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

		self:refreshMySeatDiscardView()			
		--end
		self.model:request_discard(false, cardPattern.cards, self.discard_serno)
		self.view:showChuPaiButtons(false)
		return
	end
	ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
end

--点击理牌按钮
function GameLogic:on_click_lipai_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local sort_pattern_type = self.myHandPokers.sort_pattern_type
	local target_sort_type
	if(sort_pattern_type and sort_pattern_type == 1)then
		target_sort_type = 2
	elseif(sort_pattern_type and sort_pattern_type == 2)then
		target_sort_type = 3
	else
		target_sort_type = 1
	end
	self:re_sort_myhandcards(target_sort_type)
	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.show_cards)then
			self:re_sort_handcards(seatInfo)
			self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList)
		end
	end
end

--点击50k按钮
function GameLogic:on_click_50k_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(not self.tiShiFunction_50k)then
		local tiShiFunction_50k, count = mySeatInfo.handCardSet:hintIterator(nil, {CardCommon.PT_N510K, CardCommon.PT_P510K})
		if(count ~= 0)then
			self.tiShiFunction_50k = tiShiFunction_50k
		end
	end

	if(self.tiShiFunction_50k)then
		local pattern = self.tiShiFunction_50k()
		if(not pattern)then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('没有五十K牌型')
			return
		end
		self.myHandPokers:selectPokers(pattern.cards)
		self.is_playing_select_poker_anim = true
		self.myHandPokers:refreshPokerSelectState(false, function()
			self.is_playing_select_poker_anim = false
		end)
	else
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('没有五十K牌型')
	end

end

--点击重新开始按钮
function GameLogic:on_click_restart_btn(obj, arg)
	self.model:request_redeal_cards()
end

function GameLogic:on_click_du_pai_btn(obj, arg)
	self.view:showAskWindow(true, '确定要选择独牌进行一对三吗？', function(result)
		if(result)then
			local mySeatInfo = self.roomInfo.mySeatInfo
			self.model:request_du_pai(mySeatInfo.playerId, true)
		end
	end)
end

function GameLogic:on_click_bu_du_btn(obj, arg)
	local mySeatInfo = self.roomInfo.mySeatInfo
	self.model:request_du_pai(mySeatInfo.playerId, false)
end

--点击询问窗口相关按钮
function GameLogic:on_click_ask_window_btns(obj, arg)
	if(obj == self.view.askWindowHolder.buttonConfirm.gameObject)then
		local callback = self.view.askWindowHolder.callback
		if(callback)then
			callback(true)
			self.view.askWindowHolder.callback = nil
		end
		self.view:showAskWindow(false)
	elseif(obj == self.view.askWindowHolder.buttonCancel.gameObject)then
		local callback = self.view.askWindowHolder.callback
		if(callback)then
			callback(false)
			self.view.askWindowHolder.callback = nil
		end
		self.view:showAskWindow(false)
	end
end

function GameLogic:re_sort_handcards(seatInfo, target_sort_type)
	target_sort_type = target_sort_type or self.myHandPokers.sort_pattern_type
	if(not seatInfo.handCodeList)then
		return
	end
	local handCardSet = CardSet.new(seatInfo.handCodeList, #seatInfo.handCodeList)
	self:sort_pattern_by_type(handCardSet.cards, target_sort_type)
	seatInfo.handCodeList = handCardSet.cards
end

function GameLogic:re_sort_myhandcards(target_sort_type)
	target_sort_type = target_sort_type or self.myHandPokers.sort_pattern_type
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	self.myHandPokers:set_sort_pattern_type(target_sort_type)

	mySeatInfo.handCodeList = mySeatInfo.handCardSet.cards
	self:sort_cards_by_sorttype(mySeatInfo.handCodeList, target_sort_type)
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
function GameLogic:on_enter_room_rsp(eventData)
	self.isEnterRoom = true
end

--准备应答
function GameLogic:on_ready_rsp(eventData)
	--清除牌桌上的牌
	self:cleanDesk()
	if(tostring(eventData.err_no) == "0") then
		local roomInfo = self.modelData.curTableData.roomInfo
		local show_leave_invite = not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0
		self.view:show_leave_ready_invite_btn(show_leave_invite, false)
	end
end

function GameLogic:on_ready_notify(eventData)
	local roomInfo = self.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local show_leave_invite = not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0
	self.view:show_leave_ready_invite_btn(show_leave_invite, not mySeatInfo.isReady)
end

--开始通知
function GameLogic:on_start_notify(eventData)
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



--出牌响应
function GameLogic:on_table_discard_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)
		TableManagerPoker:heartbeat_timeout_reconnect_game_server()
		return
	end
	self.tiShiFunction = nil
	self.tiShiFunction_50k = nil
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	mySeatInfo.handCodeList = {}
	for i=1,#eventData.cards do
		mySeatInfo.handCodeList[i] = eventData.cards[i]
	end
	
	mySeatInfo.leftCardCount = #eventData.cards
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	self.view:showChuPaiButtons(false)
	self:re_sort_myhandcards()
end

--出牌通知
function GameLogic:on_table_discard_notify(eventData)
	self.discard_notify_received = true
	self.discard_serno = eventData.discard_serial_no
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfoList = roomInfo.seatInfoList
	
    local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
    seatInfo.warning_flag = eventData.warning_flag
    seatInfo.leftCardCount = eventData.rest_card_cnt

	local lastDisCardSeatInfo = roomInfo.lastDisCardSeatInfo
	if(eventData.is_first_pattern)then
		roomInfo.lastDisCardSeatInfo = nil
	else
		if(not eventData.is_passed)then
			roomInfo.lastDisCardSeatInfo = seatInfo
		end
	end
    roomInfo.next_player_id = eventData.next_player_id
	local last_loopPickedPoints = roomInfo.loopPickedPoints
	roomInfo.loopPickedPoints = eventData.loopPickedPoints


    local onFinish = function()
		self.view:showZhuoMianFen(roomInfo.isRoundStarted and roomInfo.battleMode == 2, roomInfo.loopPickedPoints, last_loopPickedPoints == roomInfo.loopPickedPoints)
		if(not eventData.is_passed)then
			local male = (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) or false
			if(seatInfo.leftCardCount == 1)then
				self.tableSound:playWarningSound(male, true)
			elseif(seatInfo.leftCardCount == 2)then
				self.tableSound:playWarningSound(male, false)
			end
			if(eventData.teamCard ~= 0)then
				local _, teamPlayers = self:getFriendIdByPlayerId(roomInfo.bankerId)
				if(teamPlayers)then
					teamPlayers[1] = roomInfo.bankerId
					teamPlayers[2] = seatInfo.playerId
				end
				roomInfo.bankerFriendId = seatInfo.playerId
				seatInfo.isBankerFriend = true
				self.tableSound:playFriendEffectSound()
				self.view:playAppearTeamMateAnim(seatInfo.localSeatIndex, function()
					self.view:showSeatFriendTag(seatInfo.localSeatIndex, true, mySeatInfo.isBanker or mySeatInfo.isBankerFriend)
				end)
			end
		end

        for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, seatInfo.leftCardCount > 1)
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, true, seatInfo.leftCardCount)
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, seatInfo.warning_flag and seatInfo.rank == 0)
			self.view:showSeatRankTag(seatInfo.localSeatIndex, seatInfo.rank ~= 0 and (not seatInfo.isLord), seatInfo.rank)

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
			local is_first_pattern = eventData.is_first_pattern
			if(open_drop_cards and is_first_pattern and canDrop and patternList and #patternList > 0)then
				--先显示后逻辑start
				local pattern = patternList[1]
				mySeatInfo.round_discard_pattern = pattern
				self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

				self:refreshMySeatDiscardView()
				--end
				self.model:request_discard(false, pattern.cards, self.discard_serno)
				self.view:showChuPaiButtons(false)
			else
				self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
				local enable = self:can_chu_pai()
				self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
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
		roomInfo.desk_logic_cards = {}
		seatInfo.rank = eventData.rank
        seatInfo.round_discard_cnt = #eventData.cards or 0
		seatInfo.round_discard_info = {}
		seatInfo.round_discard_logic_info = {}
		for i=1,#eventData.cards do
			seatInfo.round_discard_info[i] = eventData.cards[i]
			seatInfo.round_discard_logic_info[i] = eventData.logic_cards[i]
			roomInfo.desk_cards[i] = eventData.cards[i]
			roomInfo.desk_logic_cards[i] = eventData.logic_cards[i]
		end

		local cardPatternList = CardPattern.new(seatInfo.round_discard_info, seatInfo.round_discard_logic_info, seatInfo.leftCardCount + #seatInfo.round_discard_info) or {}
		local cardPattern = cardPatternList[1]
		if(cardPattern)then
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
		 end
    end
end

--结算通知
function GameLogic:on_table_currentaccount_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local is_summary_account = eventData.isSummarySettle
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
			player.isBanker = seatInfo.isBanker or false
			player.isLord = seatInfo.isLord or false
			self.view:refreshSeatState(seatInfo)

			player.totalScore = tmpPlayer.score or 0
			player.score = tmpPlayer.current_score or 0
			player.multiple = tmpPlayer.multiple
			player.rank = tmpPlayer.rank
			player.jianFen = tmpPlayer.pickedPoints
			player.teamJianFen = tmpPlayer.teamPickedPoints
			player.bomb_times = tmpPlayer.bomb_cnt
			player.no1_times = tmpPlayer.no1_times

			player.cards = {}
			player.played_cards = {}
			if string.sub(tmpPlayer.cards,1,1) == "[" then
				local cards = ModuleCache.Json.decode(tmpPlayer.cards)
				if(cards)then
					for i = 1, #cards do
						local code = cards[i]
						table.insert(player.cards, code)
					end
				end
			end

			self.myHandPokers:sortCodeList(player.cards)

			data.players[i] = player
		end
		table.sort(data.players, function(p1,p2)
			return p1.seatIndex < p2.seatIndex
		end)
		data.roomInfo = roomInfo
		data.isMuseumRoom = self.modelData.roleData.HallID > 0
		data.free_sponsor = eventData.free_sponsor
		data.startTime = eventData.startTime
		data.endTime = eventData.endTime
		data.myPlayerId = mySeatInfo.playerId
		data.roomDesc = roomInfo.wanfaName

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
			if(data.free_sponsor == 0)then
				self.is_showing_round_settle = true
				self:showAllSeatLeftCards(true, data.players)
				ModuleCache.ModuleManager.show_module(self.module.packageName, "onegameresult", data)
			end

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
		self:reset_round_data()
	end
	if(self.discard_notify_received)then
		self.discard_notify_received = nil
		if(not is_summary_account)then
			self.module:subscibe_time_event(3, false, 0):OnComplete(function(t)
				onFinishDelay()
			end)
		else
			onFinishDelay()
		end
	else
		onFinishDelay()
	end
end

function GameLogic:on_reset_notify(evenData)
	self:reset_round_data()
end

function GameLogic:reset_round_data()
	local roomInfo = self.roomInfo
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
		seatInfo.bomb_cnt = 0
		seatInfo.round_jianfen = 0
		seatInfo.isLord = false
		seatInfo.rank = 0
	end
	roomInfo.state = 0
	roomInfo.isRoundStarted = false
	roomInfo.teamCard = 0
	roomInfo.battleMode = 0
	roomInfo.lord_id = nil
end

function GameLogic:on_table_gameinfo_notify(eventData)
	self:initTableData(eventData)
	--初始化主牌
	self.tableSound:init(function()
		return self.module:getCurLocationSetting()
	end)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	if(not self.pokerTableFrameModule)then
		local showPokerTableFrameData = {
			roomNumber=roomInfo.roomNum,
			rule = roomInfo.rule,
			show_location_btn = false,
			show_shop_btn = false,
			roomInfo = roomInfo,
			style = 2,
		}
		self.pokerTableFrameModule = ModuleCache.ModuleManager.show_module("public", "pokertableframe", showPokerTableFrameData)
	end
	self.pokerTableFrameModule:check_activity_is_open()

	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)

	self.myHandPokers.on_finish_drag_pokers_reselect_fun = function()
		self:on_finish_drag_pokers_reselect_fun()
	end
	self.myHandPokers.on_select_pokers_changed = function()
		local enable = self:can_chu_pai()
		self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
	end
	self.view:showKickBtns(mySeatInfo.isCreator and roomInfo.curRoundNum == 0 and (not roomInfo.isRoundStarted), mySeatInfo.localSeatIndex)
	self.view:SetRuleBtnActive(true)

	local is_first_pattern = roomInfo.desk_player_id == 0 or roomInfo.desk_player_id == roomInfo.next_player_id
	if(is_first_pattern)then
		roomInfo.lastDisCardSeatInfo = nil
	else
		roomInfo.lastDisCardSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.desk_player_id, seatInfoList)
	end
	
	self.module:on_enter_room_event(roomInfo)
	
	--设置牌局和房间信息
	local wanfaName = roomInfo.wanfaName
	self.view:setRoomInfo(roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount, wanfaName)

	local playerCount = 0
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, false)
		self.view:showSeatRankTag(seatInfo.localSeatIndex, seatInfo.rank ~= 0, seatInfo.rank)
		self.view:refreshSeatState(seatInfo, seatInfo.lastLocalSeatIndex)
		if(seatInfo.lastLocalSeatIndex == seatInfo.localSeatIndex)then
			self.view:refreshSeatPlayerInfo(seatInfo)
			self.view:refreshSeatOfflineState(seatInfo)
		else

		end
		if(seatInfo.playerId ~= 0)then
			playerCount = playerCount + 1
		end
		self.view:showSeatJianFen(seatInfo.localSeatIndex, roomInfo.isRoundStarted  and roomInfo.battleMode == 2, seatInfo.round_jianfen, true)
	end

	if(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0)then
		self.module:refresh_share_clip_board()
	end
	self.view:show_leave_ready_invite_btn(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0, not mySeatInfo.isReady)


	self.view:showChuPaiButtons(false)

	if(self.isEnterRoom)then
		self.isEnterRoom = false
	end
	local initFunction = function()
		self.isFinishFaPai = true
		self.view:showZhuoMianFen(roomInfo.isRoundStarted and roomInfo.battleMode == 2, roomInfo.loopPickedPoints, true)
		--判断游戏是否已经开局
		if(roomInfo.isRoundStarted)then
			self.view:showJiaoPaiFrame(roomInfo.battleMode == 2)
			self.view:refreshJiaoPai(roomInfo.battleMode == 2, roomInfo.teamCard)
			self.view:showLiPaiBtn(true)
			self.view:show50KBtn(true)
			for i=1,#seatInfoList do
				local seatInfo = seatInfoList[i]
				self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, seatInfo.leftCardCount > 1)
				self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, true, seatInfo.leftCardCount)
				self.view:showSeatWarningIcon(seatInfo.localSeatIndex, seatInfo.warning_flag and seatInfo.rank == 0)
				self.view:showSeatLordTag(seatInfo.localSeatIndex, seatInfo.isLord or false)
				self.view:showSeatFriendTag(seatInfo.localSeatIndex, seatInfo.isBankerFriend or false, mySeatInfo.isBanker or mySeatInfo.isBankerFriend)
				if(seatInfo.round_discard_cnt == 0)then --已过牌
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, true)
				elseif(seatInfo.round_discard_cnt > 0)then --已出牌
					self:sort_pattern_by_type(seatInfo.round_discard_pattern)
					local cards = seatInfo.round_discard_pattern.sorted_cards
					local logic_cards = seatInfo.round_discard_pattern.sorted_logic_cards
					self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, logic_cards, true)
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
			if(roomInfo.state == 1)then		--确定对战模式中
				if(roomInfo.next_player_id == mySeatInfo.playerId)then
					self.view:showDuPaiBtn(true)
				end
				return
			elseif(roomInfo.next_player_id == mySeatInfo.playerId)then
				local canDrop, patternList, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
				canBigger = canBigger or false
				if(open_drop_cards and is_first_pattern and canDrop and patternList and #patternList > 0)then
					--先显示后逻辑start
					local pattern = patternList[1]
					mySeatInfo.round_discard_pattern = pattern
					self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)
					self:refreshMySeatDiscardView()
					--end
					self.model:request_discard(false, pattern.cards, self.discard_serno)
					self.view:showChuPaiButtons(false)
				else
					self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
					local enable = self:can_chu_pai()
					self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
				end
			end
		else
			self.view:showJiaoPaiFrame(false)
			self.view:refreshJiaoPai(false)
		end
	end
	self.view:showLiPaiBtn(false)
	self.view:show50KBtn(false)
	if(eventData.isHandingCards)then
		local fapaiFun = function(onFinish)
			local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1
			self:sort_cards_by_sorttype(mySeatInfo.handCodeList, sort_pattern_type)
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
		self:sort_cards_by_sorttype(mySeatInfo.handCodeList, sort_pattern_type)
		self.myHandPokers:removeAll()
		self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, nil)
		self.myHandPokers:show_handPokers(true, true)
		self.myHandPokers:resetPokers(true)
		self.selected_chupai_PokerHolders = {}
		self.selected_chupai_CodeList = {}
		initFunction()
	end


end

function GameLogic:on_table_fight_alone_rsp(eventData)
	if(not eventData.ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.msg)
	end
end

function GameLogic:on_table_fight_alone_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.battleMode = eventData.battleMode
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local playerId = eventData.fightAlonePlayer
	local seatInfo = self.module:getSeatInfoByPlayerId(playerId, seatInfoList)
	self.view:showSeatClock(seatInfo.localSeatIndex, false)
	local nextSeatInfo = self.module:getSeatInfoByPlayerId(eventData.nextPlayerId, seatInfoList)
	self.view:showDuPaiBtn(false)

	local on_next_discard = function(seatInfo)
		self.view:showZhuoMianFen(roomInfo.isRoundStarted and roomInfo.battleMode == 2, roomInfo.loopPickedPoints, true)
		for i = 1, #seatInfoList do
			local tmpSeatInfo = seatInfoList[i]
			self.view:showSeatJianFen(tmpSeatInfo.localSeatIndex, roomInfo.isRoundStarted and roomInfo.battleMode == 2, tmpSeatInfo.round_jianfen, true)
		end
		self.view:showSeatClock(seatInfo.localSeatIndex, true, seatInfo == mySeatInfo)
		--清除下一个出牌玩家的桌面
		self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		if(seatInfo == mySeatInfo)then
			local canDrop, patternList, canBigger = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
			canBigger = canBigger or false
			if(open_drop_cards and  canDrop and patternList and #patternList > 0)then
				--先显示后逻辑start
				local pattern = patternList[1]
				mySeatInfo.round_discard_pattern = pattern
				self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)
				self:refreshMySeatDiscardView()
				--end
				self.model:request_discard(false, pattern.cards, self.discard_serno)
				self.view:showChuPaiButtons(false)
			else
				self.view:showChuPaiButtons(true, true, not canBigger)
				local enable = self:can_chu_pai()
				self.view:setChuPaiBtnGrayAndEnable(not enable, enable)
			end
		end
	end

	if(eventData.battleMode == 0)then	--对战模式未确定
		self.view:showSeatClock(nextSeatInfo.localSeatIndex, true, nextSeatInfo == mySeatInfo)
		self.view:showDuPaiBtn(nextSeatInfo == mySeatInfo)
	elseif(eventData.battleMode == 1)then
		roomInfo.lord_id = playerId
		seatInfo.isLord = true
		self.tableSound:playDuPaiEffectSound(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1)
		self.view:playDuPaiAnim(seatInfo.localSeatIndex, function()
			self.view:showSeatLordTag(seatInfo.localSeatIndex, seatInfo.isLord)
			on_next_discard(nextSeatInfo)
		end)
	elseif(eventData.battleMode == 2)then
		roomInfo.next_player_id = eventData.nextPlayerId
		roomInfo.teamCard = eventData.teamCard
		self.myHandPokers:setTeamCard(roomInfo.teamCard)
		self.myHandPokers:refreshAllPokerTeamCardMask()
		self.tableSound:playJiaoPaiEffectSound()

		if(not mySeatInfo.isBanker)then
			local contains = false
			for i, v in pairs(mySeatInfo.handCodeList) do
				if(v == roomInfo.teamCard)then
					contains = true
					break
				end
			end
			if(contains)then
				self.view:playOwnTeamCardTipAnim()
			end
		end
		self.view:playConfirmTeamCardAnim(roomInfo.teamCard, function()
			on_next_discard(nextSeatInfo)
		end)
	end
end

function GameLogic:on_table_points_picked_notify(eventData)
	local playerId = eventData.playerId
	local totalPoints = eventData.totalPoints
	local points = eventData.points
	local roomInfo = self.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local seatInfo = self.module:getSeatInfoByPlayerId(playerId, seatInfoList)
	if(seatInfo)then
		seatInfo.round_jianfen = totalPoints
		self.view:showSeatJianFen(seatInfo.localSeatIndex, roomInfo.isRoundStarted  and roomInfo.battleMode == 2, seatInfo.round_jianfen)
	end
end

function GameLogic:cleanDesk(ignoreDispatchPokers)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
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
		self.view:showSeatLordTag(seatInfo.localSeatIndex, false)
		self.view:showSeatFriendTag(seatInfo.localSeatIndex, false)
		self.view:showSeatRankTag(seatInfo.localSeatIndex, false)
		self.view:showSeatJianFen(seatInfo.localSeatIndex, false)
		self.view:showZhuoMianFen(false)
	end

	self.view:showLiPaiBtn(false)
	self.view:show50KBtn(false)
	self.myHandPokers:resetPokers(true)
	self.myHandPokers:removeAll()
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
	self.view:showTips(false)
end

--初始化牌桌数据
function GameLogic:initTableData(data)
	local roomInfo
	if(self.isEnterRoom)then
		roomInfo = {}
		self.modelData.curTableData = {}
	else
		roomInfo = self.modelData.curTableData.roomInfo
	end
	self.roomInfo = roomInfo
	roomInfo.roomNum = data.room_id
	roomInfo.totalRoundCount = data.totalRound
	roomInfo.curRoundNum = data.currentRound
	roomInfo.desk_player_id = data.desk_player_id
	roomInfo.next_player_id = data.next_player_id
	roomInfo.loopPickedPoints = data.loopPickedPoints	--桌面分
	roomInfo.bankerId = data.bankerId	--庄家id
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

	roomInfo.state = data.state
	roomInfo.magicCards = {}	--癞子牌
	for i = 1, #data.magicCards do
		roomInfo.magicCards[i] = data.magicCards[i]
	end
	roomInfo.battleMode = data.battleMode	--对战模式，1:独牌模式（1v3）; 2:搭挡模式（2v2）

	roomInfo.team1Players = {}
	for i = 1, #data.team1Players do
		roomInfo.team1Players[i] = data.team1Players[i]
	end
	roomInfo.team2Players = {}
	for i = 1, #data.team2Players do
		roomInfo.team2Players[i] = data.team2Players[i]
	end
	roomInfo.teamCard = data.teamCard
	self.myHandPokers:setTeamCard(roomInfo.teamCard)

	if(roomInfo.battleMode == 1)then
		roomInfo.lord_id = roomInfo.team1Players[1]
		roomInfo.bankerFriendId = nil
	else
		roomInfo.lord_id = nil
		if(data.teamCardAppeared)then
			roomInfo.bankerFriendId = self:getFriendIdByPlayerId(roomInfo.bankerId)
		else
			roomInfo.bankerFriendId = nil
		end
	end

	roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
	roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc or ''
	roomInfo.wanfaName = wanfaName

	roomInfo.isRoundStarted = roomInfo.state == 1 or roomInfo.state == 2
	self.discard_serno = data.discard_serial_no

	--是否使用第1种（黄石玩法）牌型大小比较序列
	CardPattern.confirmPatternCompareSeqs(roomInfo.ruleTable.GameType == 2)
	CardCommon.enableMagicCards(roomInfo.ruleTable.isKingMagic, roomInfo.magicCards)
	self.myHandPokers:setMagicCards(roomInfo.ruleTable.isKingMagic, roomInfo.magicCards)
	self.view:setMagicCards(roomInfo.ruleTable.isKingMagic, roomInfo.magicCards)

	local seatInfoList
	local seatCount = 4
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
			seatInfo.round_jianfen = 0
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
		seatInfo.isBanker = roomInfo.bankerId ~= 0 and roomInfo.bankerId == seatInfo.playerId
		seatInfo.isBankerFriend = seatInfo.playerId == roomInfo.bankerFriendId
		seatInfo.isOffline = remotePlayerInfo.is_offline
		seatInfo.warning_flag = remotePlayerInfo.warning_flag--是否报警
		seatInfo.score = remotePlayerInfo.score
		seatInfo.winTimes = remotePlayerInfo.win_cnt
		seatInfo.lostTimes = remotePlayerInfo.lost_cnt
		seatInfo.leftCardCount = remotePlayerInfo.rest_card_cnt	--剩余手牌数
		seatInfo.round_jianfen = remotePlayerInfo.pickedPoints	--捡分值
		seatInfo.rank = remotePlayerInfo.rank
		seatInfo.isLord = seatInfo.playerId == roomInfo.lord_id

		seatInfo.round_discard_cnt = remotePlayerInfo.round_discard_cnt or -1	--本轮出牌情况 -1 还未轮到 0 已过牌 其他表示出牌数量
		seatInfo.round_discard_info = {}
		seatInfo.round_discard_logic_info = {}
		if(remotePlayerInfo.round_discard_info)then	--当前出牌
			for i=1,#remotePlayerInfo.round_discard_info do
				seatInfo.round_discard_info[i] = remotePlayerInfo.round_discard_info[i]
				seatInfo.round_discard_logic_info[i] = remotePlayerInfo.round_discard_logic_info[i]
			end
		end

		local cardPatternList = CardPattern.new(seatInfo.round_discard_info, seatInfo.round_discard_logic_info, seatInfo.leftCardCount) or {}
		local cardPattern = cardPatternList[1]
		if(cardPattern)then
			seatInfo.round_discard_pattern = cardPattern
		else
			seatInfo.round_discard_pattern = nil
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
function GameLogic:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	if(type == CardCommon.PT_BOMB3
	or type == CardCommon.PT_BOMB4
	or type == CardCommon.PT_BOMB5
	or type == CardCommon.PT_BOMB6
	or type == CardCommon.PT_BOMB7
	or type == CardCommon.PT_BOMB8)then	--炸弹
		self.view:playZhaDanEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_STRAIGHT)then	--顺子
		self.view:playShunZiEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_CPAIR)then	--连对
		self.view:playLianDuiEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_BOMB_KING2)then --对王炸
		self.view:playWangZhaEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_BOMB_KING3)then --三王炸
		self.view:playWangZhaEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_BOMB_KING4)then --四王炸
		self.view:playWangZhaEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_N510K)then	--副五十K
		self.view:play50KEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_P510K)then	--正五十K
		self.view:play50KEffect(seatInfo.localSeatIndex)
	end

end

--播放不出音效
function GameLogic:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

--判断是否能够出牌
function GameLogic:checkCanChuPai(srcPattern, codeList, seatInfo)
	local selectedPatternList = CardPattern.new(codeList, nil, seatInfo.leftCardCount)
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


function GameLogic:getDisplayNameFromName(card_name)
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

function GameLogic:seatIndex_pos(srcSeatIndex, dstSeatIndex)
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


function GameLogic:sort_pattern_by_type(pattern)
	print_table(pattern, 'sort_pattern_by_type')
	pattern.sorted_cards = {}
	pattern.sorted_logic_cards = {}
	for i=1,#pattern.cards do
		pattern.sorted_cards[i] = pattern.cards[i]
		pattern.sorted_logic_cards[i] = pattern.logic_cards[i]
	end
end

--自己打完牌后刷新手牌和桌面
function GameLogic:refreshMySeatDiscardView()
	self.view:showChuPaiButtons(false)
	self.myHandPokers:removePokerHolders(self.selected_chupai_PokerHolders)
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
	self.selected_chupai_PokerHolders = {}
	self.selected_chupai_CodeList = {}
end

--出牌动画、音效播放
function GameLogic:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
	self:sort_pattern_by_type(seatInfo.round_discard_pattern)
	local cards = seatInfo.round_discard_pattern.sorted_cards
	local logic_cards = seatInfo.round_discard_pattern.sorted_logic_cards
	local roomInfo = seatInfo.roomInfo
	self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, logic_cards, false, onFinish)
end


--是否能够一手丢
function GameLogic:can_drop_cards(lastDisCardSeatInfo)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local lastCardPattern = nil
	if(lastDisCardSeatInfo)then
		lastCardPattern = lastDisCardSeatInfo.round_discard_pattern
	end
	local tiShiFunction, count = mySeatInfo.handCardSet:hintIterator(lastCardPattern)
	if(tiShiFunction and count > 0)then
		--自动甩牌不要了
		for i=1,count do
			local pattern = tiShiFunction()
			if(pattern and #pattern.cards == #mySeatInfo.handCodeList)then
				local patternList = CardPattern.new(pattern.cards, nil, mySeatInfo.leftCardCount)
				self.myHandPokers:selectPokers(pattern.cards)
				self.myHandPokers:refreshPokerSelectState(true)
				local selectedPokerHolders, selectPokerList, selectedCodeList, selectedIdList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList, real_selectedIdList = self.myHandPokers:getSelectedPokers()
				self.selected_chupai_PokerHolders = real_selectedPokerHolders
				self.selected_chupai_cardPatternList = patternList
				return true, patternList, true
			end
		end
		return false, nil, true
	else
		return false
	end
	return false
end

function GameLogic:playBgm()
	self.tableSound:playBgm()
end


function GameLogic:testfun()
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

function GameLogic:on_finish_drag_pokers_reselect_fun(onFinish)
	local pokerHolderList, pokerList, selectedCodeList, selectedIdList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList, real_selectedIdList = self.myHandPokers:getSelectedPokers()
	if(#selectedCodeList > 0)then
		--print_table(selectedCodeList, 'selectedCodeList')
		self.myHandPokers:selectPokers(selectedCodeList, selectedIdList)
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

function GameLogic:removeCodeListFromList(srcCodeList, codeList)
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
function GameLogic:playSetLordEffect(seatInfo, onFinish1, onFinish2)
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

function GameLogic:on_click_gameresule_continue_btn()
	self.is_showing_round_settle = false
	self:showAllSeatLeftCards(false)
	if(self.summary_account_fun)then
		self.summary_account_fun()
	else
		self.model:request_ready()
	end
end

function GameLogic:showAllSeatLeftCards(show, players)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	if(show)then
		for i=1,#players do
			local player = players[i]
			local seatInfo = self.module:getSeatInfoByPlayerId(player.playerId, seatInfoList)
			if(seatInfo == mySeatInfo)then
				local sort_pattern_type = self.myHandPokers.sort_pattern_type or 1

				mySeatInfo.handCodeList = mySeatInfo.handCardSet.cards
				self.myHandPokers:removeAll()
				self.myHandPokers:genPokerHolderList(player.cards, nil)
				self.myHandPokers:show_handPokers(true, true)
				self.myHandPokers:resetPokers(true)
				self.selected_chupai_PokerHolders = {}
				self.selected_chupai_CodeList = {}
			else
				self.view:showLeftHandCards(seatInfo.localSeatIndex, true, player.cards)
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

function GameLogic:getBankerSeatInfo()
	local roomInfo = self.roomInfo
	if(not roomInfo.bankerId or roomInfo.bankerId == 0)then
		return nil
	end
	local seatInfoList = roomInfo.seatInfoList
	local seatInfo = self.module:getSeatInfoByPlayerId(roomInfo.bankerId, seatInfoList)
	return seatInfo
end

function GameLogic:getFriendIdByPlayerId(playerId)
	if(not playerId or playerId == 0)then
		return nil, {}
	end
	local roomInfo = self.roomInfo
	local searchFun = function(teamPlayers, playerId)
		for i, v in pairs(teamPlayers) do
			if(playerId ~= v)then
				return v, teamPlayers
			end
		end
		return nil, teamPlayers
	end
	for i, v in pairs(roomInfo.team1Players) do
		if(playerId == v)then
			return searchFun(roomInfo.team1Players, playerId)
		end
	end
	for i, v in pairs(roomInfo.team2Players) do
		if(playerId == v)then
			return searchFun(roomInfo.team2Players, playerId)
		end
	end
end

function GameLogic:getBankerFriendSeatInfo()
	local roomInfo = self.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local playerId = self:getFriendIdByPlayerId(roomInfo.bankerId)
	if(playerId)then
		return self.module:getSeatInfoByPlayerId(playerId, seatInfoList)
	else
		return nil
	end
end

function GameLogic:sort_cards_by_sorttype(cards, sort_type)
	if(sort_type == 1)then
		CardSort.sortBySpec(cards)
	elseif(sort_type == 2)then
		CardSort.sortBySpec2(cards, false)
	elseif(sort_type == 3)then
		CardSort.sortBySpec1(cards)
	end
end

function GameLogic:fillRoomSetting_PokerFaceChangeData(intentData)
	local commonPokerSettingData = {}
	commonPokerSettingData.pokerCodeList = {
		CardCommon.makeCard(CardCommon.card_A,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_2,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_3,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_4,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_5,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_6,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_7,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_8,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_9,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_10,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_J,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_Q,CardCommon.color_square),
		CardCommon.makeCard(CardCommon.card_K,CardCommon.color_square),
	}
	commonPokerSettingData.get_sprite_by_code_fun = function(code, assetHolder)
		local spriteName = self.view:getImageNameFromCode(code)
		return assetHolder:FindSpriteByName(spriteName);
	end
	commonPokerSettingData.on_change_poker_face = function(assetHolder)
		self.view.myCardAssetHolder = assetHolder
		self.view.cardAssetHolder = assetHolder
		for i = 1, 3 do
			local cardAssetHolder = self.view['cardAssetHolder'..i]
			if(cardAssetHolder == assetHolder)then
				UnityEngine.PlayerPrefs.SetInt('last_wushik_card_face_style', i)
				break
			end
		end
		self.view:refresh_all_dispatched_poker_face()
		self.myHandPokers:refreshAllPokerFace()
	end
	local pokerDataList = {}
	for i = 1, 3 do
		local data = {}
		local assetHolder = self.view['cardAssetHolder'..i]
		if(assetHolder)then
			data.assetHolder = assetHolder
			table.insert(pokerDataList, data)
		end
	end
	commonPokerSettingData.pokerDataList = pokerDataList
	commonPokerSettingData.lastAssetHolder = self.view.cardAssetHolder
	intentData.openCommonPokerFaceChange = true
	intentData.commonPokerSettingData = commonPokerSettingData
end

return GameLogic