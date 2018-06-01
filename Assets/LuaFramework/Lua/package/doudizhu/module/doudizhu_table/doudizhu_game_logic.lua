
local class = require("lib.middleclass")
local list = require('list')
local DouDiZhuGameLogic = class('GuanDanLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence
local CardCommon = require('package.doudizhu.module.doudizhu_table.gamelogic_common')
local cardCommon = CardCommon
local CardPattern = require('package.doudizhu.module.doudizhu_table.gamelogic_pattern')
local CardSet = require('package.doudizhu.module.doudizhu_table.gamelogic_set')
local tableSound = require('package.doudizhu.module.doudizhu_table.table_sound')


function DouDiZhuGameLogic:initialize(module)
    self.module = module    
    self.modelData = module.modelData
    self.view = module.view
    self.model = module.model
    self.myHandPokers = module.myHandPokers
	self.tableSound = tableSound
	self.isGoldTable = self.modelData.tableCommonData.isGoldTable
	self.isGoldSettle = self.modelData.tableCommonData.isGoldSettle
	self.isGoldUnlimited = self.modelData.tableCommonData.isGoldUnlimited
	self.isFinishFaPai = true

	if(self.isGoldTable)then
		self.view:showGoldCoinTable(true)
	end

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

function DouDiZhuGameLogic:genPokers()
	local list = {}
	for i=0,16 do
		local code = i % 13 + 1
		table.insert( list, code)
		self.myHandPokers:genPokerHolderList({code}, nil, true)
	end	
end

function DouDiZhuGameLogic:on_show()
    
end

function DouDiZhuGameLogic:on_hide()
    
end

function DouDiZhuGameLogic:update()

end

function DouDiZhuGameLogic:on_destroy()
	self.showResultViewSmartTimer = nil
	if(self.timerMap)then
		for k,v in pairs(self.timerMap) do
			SmartTimer.Kill(v.id)
		end
	end

end


function DouDiZhuGameLogic:on_press_up(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press_up(obj,arg)
	end
end

function DouDiZhuGameLogic:on_drag(obj, arg)	
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_drag(obj,arg)
	end
end

function DouDiZhuGameLogic:on_press(obj, arg)
	if(obj ~= self.view.buttonMic.gameObject)then
		self.myHandPokers:on_press(obj,arg)
	end
end

function DouDiZhuGameLogic:on_click(obj, arg)	
	if(self.is_playing_select_poker_anim or self.myHandPokers.is_playing_select_poker_anim)then
		return
	end
	if(obj == self.view.imageMask.gameObject)then
		self.myHandPokers:resetPokers(true)
	elseif(obj.transform.parent == self.view.goGrabLordBtns.transform)then
		self:on_click_grablord_btn(obj, arg)
	elseif(obj == self.view.buttonChuPai.gameObject)then
		self:on_click_chupai_btn(obj, arg)
	elseif(obj == self.view.buttonTiShi.gameObject)then
		self:on_click_tishi_btn(obj, arg)
	elseif(obj == self.view.buttonYaoBuQi.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif(obj == self.view.buttonBuChu.gameObject)then
		self:on_click_buchu_btn(obj, arg)
	elseif( obj == self.view.buttonShowCard.gameObject)then
		self:on_click_showcards_btn(obj, arg)
	elseif(obj == self.view.buttonRule.gameObject)then
		self:on_click_rule_info(obj, arg)
	elseif(obj.name == 'KickBtn')then
		self:on_click_kick_btn(obj, arg)
	elseif(obj == self.view.button_gold_ready.gameObject)then
		self:on_click_goldcoin_ready_btn(obj, arg)
	elseif(obj == self.view.button_goldCoin_exit.gameObject)then
		self:on_click_goldcoin_exit_btn(obj, arg)
	elseif(obj == self.view.button_wanfashuoming.gameObject)then
		self:on_click_goldcoin_wanfashuoming_btn(obj, arg)
	elseif(obj == self.view.button_tableshop.gameObject)then
		self:on_click_goldcoin_tableshop_btn(obj, arg)
	elseif(obj == self.view.buttonCancelInstrust.gameObject or obj == self.view.buttonCancelInstrust.transform.parent.gameObject)then
		self:on_click_goldcoin_cancelinstrust_btn(obj, arg)
	end
end

--------------------------------------------------------------------------
--按钮点击
--点击金币场准备按钮
function DouDiZhuGameLogic:on_click_goldcoin_ready_btn(obj, arg)
	self.model:request_ready()
end

--点击金币场退出按钮
function DouDiZhuGameLogic:on_click_goldcoin_exit_btn(obj, arg)
	UnityEngine.PlayerPrefs.SetInt("ChangeTable", 0)
	self.module:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
end

--点击金币场玩法说明按钮
function DouDiZhuGameLogic:on_click_goldcoin_wanfashuoming_btn(obj, arg)
	ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
end

--点击金币场商店按钮
function DouDiZhuGameLogic:on_click_goldcoin_tableshop_btn(obj, arg)
	ModuleCache.ModuleManager.show_module("public", "goldadd")
end

--点击取消托管按钮
function DouDiZhuGameLogic:on_click_goldcoin_cancelinstrust_btn(obj, arg)
	self.model:request_intrust(2)
end

--点击踢人按钮
function DouDiZhuGameLogic:on_click_kick_btn(obj, arg)
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
function DouDiZhuGameLogic:on_click_rule_info(obj, arg)
	ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
end

--点击离开按钮
function DouDiZhuGameLogic:on_click_leave_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(mySeatInfo.isCreator and self.modelData.roleData.RoomType ~= 2)then
		self.model:request_dissolve_room(true)
	else
		self.model:request_exit_room()
	end
end

--点击抢地主
function DouDiZhuGameLogic:on_click_grablord_btn(obj, arg)
	for i=1,#self.view.buttonGrabLordBtns do
		if(obj == self.view.buttonGrabLordBtns[i].gameObject)then
			self.model:request_grablord(i - 1)
			return
		end
	end
end

function DouDiZhuGameLogic:on_click_buchu_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(not self.isGoldTable)then
		--先显示后逻辑start
		mySeatInfo.round_discard_cnt = 0
		mySeatInfo.round_discard_info = {}
		mySeatInfo.round_discard_pattern = nil
		--播放不出动画
		self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
		self:playPassSound(mySeatInfo)
		--end
	end
	self.model:request_discard(true)
	self.myHandPokers:resetPokers(true)
end


function DouDiZhuGameLogic:on_click_tishi_btn(obj, arg)
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
		if(not self.isGoldTable)then
			--先显示后逻辑start
			mySeatInfo.round_discard_cnt = 0
			mySeatInfo.round_discard_info = {}
			mySeatInfo.round_discard_pattern = nil
			--播放不出动画
			self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
			self:playPassSound(mySeatInfo)
			--end
		end

		self.model:request_discard(true)
		self.myHandPokers:resetPokers(true)
		return
	end
	local pattern = self.tiShiFunction()
	if(not pattern)then
		if(not self.isGoldTable)then
			--先显示后逻辑start
			mySeatInfo.round_discard_cnt = 0
			mySeatInfo.round_discard_info = {}
			mySeatInfo.round_discard_pattern = nil
			--播放不出动画
			self.view:playSeatPassAnim(mySeatInfo.localSeatIndex, true, false, nil)
			self:playPassSound(mySeatInfo)
			--end
		end

		self.model:request_discard(true)
		self.myHandPokers:resetPokers(true)
		return
	end
	self.myHandPokers:selectPokers(pattern.cards)
	self.is_playing_select_poker_anim = true
	self.myHandPokers:refreshPokerSelectState(false, function()
		self.is_playing_select_poker_anim = false
	end)
end

function DouDiZhuGameLogic:on_click_chupai_btn(obj, arg)
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
	local canChuPai, cardPattern = self:checkCanChuPai(lastPattern, real_selectedCodeList)
	if(not canChuPai)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
		return
	end
	self.selected_chupai_PokerHolders = real_selectedPokerHolders
	self.selected_chupai_cardPattern = cardPattern

	if(cardPattern)then
		if(not self.isGoldTable)then
			--先显示后逻辑start
			mySeatInfo.round_discard_pattern = cardPattern
			self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

			self:refreshMySeatDiscardView()
			--end
		end

		self.model:request_discard(false, cardPattern.cards)
		return
	end
	ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牌型")	
end

--点击明牌按钮
function DouDiZhuGameLogic:on_click_showcards_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	self.model:request_show_cards(roomInfo.showcards_stage)
end

-------------------------------------------------------------------------------
--消息处理

--进入房间应答
function DouDiZhuGameLogic:on_enter_room_rsp(eventData)
	self.isEnterRoom = true
end

--准备应答
function DouDiZhuGameLogic:on_ready_rsp(eventData)
	if(eventData.err_no == '-888')then
		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
			ModuleCache.ModuleManager.show_module("public", "goldadd")
		end, nil, true, "确 认", "取 消")
	end
	if(eventData.err_no and (eventData.err_no ~= '' and eventData.err_no ~= '0'))then
		return
	end
	--清除牌桌上的牌
	self:cleanDesk()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	self.view:showSeatClock(mySeatInfo.localSeatIndex, false)
end

--开始通知
function DouDiZhuGameLogic:on_start_notify(eventData)
	if(eventData.err_no and eventData.err_no ~= '0')then
		return
	end
	self.isWaitingFaPai = true
	self.isFinishFaPai = false
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	roomInfo.state = 1
	roomInfo.isRoundStarted = true
	if(self.isGoldTable)then
		self.view:showGoldCoinTips(true, string.format('本局服务费%d金币', roomInfo.feeNum))
		self.module:subscibe_time_event(2, false, 0):OnComplete(function (t)
			self.view:showGoldCoinTips(false)
		end)
	end
end

--明牌响应
function DouDiZhuGameLogic:on_table_show_cards_rsp(eventData)
	if(eventData.is_ok)then
		self.view:showMingPaiBtn(false)
	end
end

--明牌通知
function DouDiZhuGameLogic:on_table_show_cards_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local seatInfo = self.module:getSeatInfoByPlayerId(eventData.playerid, seatInfoList)
	seatInfo.show_cards = true
	if(eventData.stage == 1)then
	else
		seatInfo.handCodeList = {}
		for i=1,#eventData.cards do
			seatInfo.handCodeList[i] = eventData.cards[i]
		end
		self.myHandPokers:sortCodeList(seatInfo.handCodeList)
	end
	
	if(mySeatInfo == seatInfo)then
		self.myHandPokers.show_mingpai_tag = true
		self.myHandPokers:repositionPokers(nil, true)
		self.view:showMingPaiBtn(false)
	else
		self.myHandPokers.show_mingpai_tag = false
		self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
		self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList)
	end
	self.view:playMingPaiEffect(seatInfo)
	--显示明牌标签、播放音效
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playMingPaiSound(false)
	else
		self.tableSound:playMingPaiSound(true)
	end
end

--抢地主应答
function DouDiZhuGameLogic:on_table_grablandlord_rsp(eventData)
	if(not eventData.is_ok)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.desc)	
		return
	end
	self.view:showGrabLordBtns(false)
end

--抢地主通知
function DouDiZhuGameLogic:on_table_grablandlord_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo

	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfo = self.module:getSeatInfoByPlayerId(eventData.playerid, seatInfoList)
	seatInfo.grablord_score = eventData.score
	--显示抢地主倍数
	self.view:playCallLordScore(seatInfo.localSeatIndex, seatInfo.grablord_score >= 0, seatInfo.grablord_score, false)

	self.view:showSeatClock(seatInfo.localSeatIndex, false)
	--显示叫分、播放音效
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playGrabLordSound(false, seatInfo.grablord_score)
	else
		self.tableSound:playGrabLordSound(true, seatInfo.grablord_score)
	end

	roomInfo.cur_grablord_id = eventData.nextid
	roomInfo.auto_ready_time = eventData.auto_ready_time
	roomInfo.grablord_score_list = eventData.scoreList	
	if(roomInfo.cur_grablord_id and roomInfo.cur_grablord_id ~= 0)then
		self:on_next_grablord(roomInfo.cur_grablord_id, roomInfo.grablord_score_list)
	end
end

--开始抢地主通知
function DouDiZhuGameLogic:on_table_start_grablandlord_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.cur_grablord_id = eventData.playerid
	roomInfo.auto_ready_time = eventData.auto_ready_time
	roomInfo.grablord_score_list = eventData.scoreList
	self:on_next_grablord(roomInfo.cur_grablord_id, roomInfo.grablord_score_list)
	self.view:showMingPaiBtn(false)
end

--抢地主结果通知
function DouDiZhuGameLogic:on_table_grablandlord_result_notify(eventData)
	if(not eventData.lordid or eventData.lordid == 0)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips('无人抢地主，重新发牌')	
		return
	end
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo

	roomInfo.lordid = eventData.lordid
	roomInfo.cur_grablord_id = 0
	roomInfo.grablord_score_list = {}
	roomInfo.next_player_id = roomInfo.lordid
	roomInfo.auto_op_time = eventData.auto_op_time
	roomInfo.rate = eventData.score
	roomInfo.di_cards = eventData.di_cards
	for i,v in ipairs(seatInfoList) do
		v.grablord_score = -1
	end

	for i = 1, #eventData.players do
		local player = eventData.players[i]
		local seatInfo = self.module:getSeatInfoByPlayerId(player.playerid, seatInfoList)
		seatInfo.beishu = player.beishu
	end
	--显示倍数
	self.view:showMultiple(true, mySeatInfo.beishu)
	self.tableSound:playSetLordEffectSound()
	--播放定地主动画
	local lordSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.lordid, seatInfoList)
	lordSeatInfo.isLord = true
	lordSeatInfo.leftCardCount = lordSeatInfo.leftCardCount + #roomInfo.di_cards
	if(lordSeatInfo.show_cards and lordSeatInfo ~= mySeatInfo)then
		for i=1,#roomInfo.di_cards do
			table.insert(lordSeatInfo.handCodeList, roomInfo.di_cards[i])
		end
		self.myHandPokers:sortCodeList(lordSeatInfo.handCodeList)
	end

	local onFinish = function()
		for i,v in ipairs(seatInfoList) do
			--显示抢地主倍数
			self.view:playCallLordScore(v.localSeatIndex, false)
		end
		if(mySeatInfo.isLord)then
			self.myHandPokers.show_lord_tag = true
			for i=1,#roomInfo.di_cards do
				table.insert(mySeatInfo.handCodeList, roomInfo.di_cards[i])
			end
			mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
			self.tiShiFunction = nil
		else
			self.myHandPokers.show_lord_tag = false
		end

		--播放底牌显示动画
		self.view:showDeskLeftCards(true)
		self.view:refreshDeskLeftCards(roomInfo.di_cards, false, function()
			self.view:refreshLeftHandCardCount(lordSeatInfo.localSeatIndex, roomInfo.ruleTable.showCardsCount and lordSeatInfo ~= mySeatInfo, lordSeatInfo.leftCardCount)
			self.view:showSeatWarningIcon(lordSeatInfo.localSeatIndex, lordSeatInfo.warning_flag or false)
			if(lordSeatInfo.show_cards and lordSeatInfo ~= mySeatInfo)then
				self.view:showSeatHandPokers(lordSeatInfo.localSeatIndex, true)
				self.view:refreshSeatHandPokers(lordSeatInfo.localSeatIndex, lordSeatInfo.handCodeList)
			else
				self.view:showSeatHandPokers(lordSeatInfo.localSeatIndex, false)
			end

			if(lordSeatInfo == mySeatInfo)then
				local pokerHolderList = self.myHandPokers:genPokerHolderList(roomInfo.di_cards, nil, true)
				self.myHandPokers:resetPokers(false, function()
					for i=1,#pokerHolderList do
						local pokerHolder = pokerHolderList[i]
						pokerHolder.selected = true
					end
					self.myHandPokers:refreshPokerSelectState(true)
					self.myHandPokers:show_handPokers(true, true)
					self.module:subscibe_time_event(1, false, 0):OnComplete(function(t)
						for i=1,#pokerHolderList do
							local pokerHolder = pokerHolderList[i]
							pokerHolder.selected = false
						end
						self.is_playing_select_poker_anim = true
						self.myHandPokers:refreshPokerSelectState(false, function()
							self.is_playing_select_poker_anim = false
							self.is_playing_set_lord_anim = false
							local canDrop, pattern, canBigger, count = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
							canBigger = canBigger or false
							self.view:showChuPaiButtons(true, true, not canBigger)
							self.view:showMingPaiBtn(true and (not mySeatInfo.show_cards), true)
							
							local is_then_same = self.myHandPokers:is_the_same(mySeatInfo.handCodeList)
							if(not is_then_same)then
								if ModuleCache.GameManager.isEditor then
									ModuleCache.GameSDKInterface:PauseEditorApplication(true)
								else
									ModuleCache.GameManager.logout()
								end
								print_table(mySeatInfo.handCodeList, "牌型数据错误，触发断线重连")
								ModuleCache.GameSDKInterface:BuglyPrintLog(5, "牌型数据错误，触发断线重连")
								-- 故意设置错误代码好上报Bugly
								local test = kjkd > 0
							end

						end)
					end)
				end)
			else
				self.is_playing_set_lord_anim = false
			end

			--下一个出牌玩家显示
			local nextDisCardSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.next_player_id, seatInfoList)
			if(nextDisCardSeatInfo)then
				self.view:showSeatClock(nextDisCardSeatInfo.localSeatIndex, true, nextDisCardSeatInfo == mySeatInfo, self:get_chupai_left_secs())
				--清除下一个出牌玩家的桌面
				self.view:playSeatPassAnim(nextDisCardSeatInfo.localSeatIndex, false)
				self.view:playDispatchPokers(nextDisCardSeatInfo.localSeatIndex, false)
			end	
		end)
	end
	self.is_playing_set_lord_anim = true
	onFinish()
	self:playSetLordEffect(lordSeatInfo, nil, function()
		self.view:showSeatLandLordIcon(lordSeatInfo.localSeatIndex, true)
	end)
end

--出牌响应
function DouDiZhuGameLogic:on_table_discard_rsp(eventData)
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
	self.view:showMingPaiBtn(false)
	if(not self.isGoldTable)then
		local is_then_same = self.myHandPokers:is_the_same(mySeatInfo.handCodeList)
		if(not is_then_same)then
			if ModuleCache.GameManager.isEditor then
				ModuleCache.GameSDKInterface:PauseEditorApplication(true)
			else
				ModuleCache.GameManager.logout()
			end
			print_table(mySeatInfo.handCodeList, "牌型数据错误，触发断线重连")
			ModuleCache.GameSDKInterface:BuglyPrintLog(5, "牌型数据错误，触发断线重连")
			-- 故意设置错误代码好上报Bugly
			local test = kjkd > 0
		end
	end
end

--出牌通知
function DouDiZhuGameLogic:on_table_discard_notify(eventData)
	self.discard_notify_received = true
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfoList = roomInfo.seatInfoList
	
    local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
    seatInfo.warning_flag = eventData.warning_flag ~= 0
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
	roomInfo.bomb_cnt = eventData.bomb_cnt
	roomInfo.auto_op_time = eventData.auto_op_time

	for i=1,#eventData.players do
		local player = eventData.players[i]
		local tmpSeatInfo = self.module:getSeatInfoByPlayerId(player.playerid, seatInfoList)
		tmpSeatInfo.beishu = player.beishu
	end

    local onFinish = function()
		if(not eventData.is_passed)then
			local male = (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) or false
			if(eventData.warning_flag == 1)then
				self.tableSound:playWarningSound(male, true)
			elseif(eventData.warning_flag == 2)then
				self.tableSound:playWarningSound(male, false)
			end
		end
        for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, roomInfo.ruleTable.showCardsCount and seatInfo ~= mySeatInfo, seatInfo.leftCardCount)
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, seatInfo.warning_flag or false)
            --下一个玩家首发，则清除牌桌上的牌
            if(eventData.is_first_pattern)then
                -- self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
                -- self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
			elseif(not eventData.is_passed)then
				-- if(eventData.player_id ~= seatInfo.playerId)then
				-- 	self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
				-- 	self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
				-- end
            end
        end

        --显示倍数
		self.view:showMultiple(true, mySeatInfo.beishu)

        local nextDisCardSeatInfo = self.module:getSeatInfoByPlayerId(roomInfo.next_player_id, seatInfoList)
		if(nextDisCardSeatInfo)then
			self.view:showSeatClock(nextDisCardSeatInfo.localSeatIndex, true, nextDisCardSeatInfo == mySeatInfo, self:get_chupai_left_secs())
			--清除下一个出牌玩家的桌面
			self.view:playSeatPassAnim(nextDisCardSeatInfo.localSeatIndex, false)
			self.view:playDispatchPokers(nextDisCardSeatInfo.localSeatIndex, false)
		end

		if(nextDisCardSeatInfo == mySeatInfo)then
			local canDrop, pattern, canBigger, count = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
			canBigger = canBigger or false
			local is_first_pattern = eventData.is_first_pattern
			if(is_first_pattern and canDrop and pattern)then
				if(not self.isGoldTable)then
					--先显示后逻辑start
					mySeatInfo.round_discard_pattern = pattern
					self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

					self:refreshMySeatDiscardView()
					--end
				end

				self.model:request_discard(false, pattern.cards)
			else
				self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
				if(canBigger and count == 1)then
					self:on_click_tishi_btn()
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
			if(self.isGoldTable)then
				--播放不出动画
				self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, false, onFinish)
				self:playPassSound(seatInfo)
			else
				onFinish()
			end
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

		local cardPattern = CardPattern.new(seatInfo.round_discard_info)
		if(cardPattern)then
			seatInfo.round_discard_pattern = cardPattern
		else
			seatInfo.round_discard_pattern = nil
		end
		 
		 if(seatInfo == mySeatInfo)then
			 if(self.isGoldTable)then
				 mySeatInfo.round_discard_pattern = cardPattern
				 mySeatInfo.handCodeList = {}
				 for i = 1, #eventData.out_player_cards do
					 mySeatInfo.handCodeList[i] = eventData.out_player_cards[i]
				 end
				 self:dispatchPoker(mySeatInfo, lastDisCardSeatInfo, onFinish)
				 self:refreshMySeatDiscardView()
			 else
				 onFinish()
			 end
		 else
        	--播放出牌动画		
			self:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
			self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
			if(seatInfo.show_cards)then
				self:removeCodeListFromList(seatInfo.handCodeList, seatInfo.round_discard_info)
				self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
				self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList)
			end
		 end


		--牌已出完
		if(seatInfo.leftCardCount == 0)then
		else
			
		end
    end
end

--结算通知
function DouDiZhuGameLogic:on_table_currentaccount_notify(eventData)
	local onFinishDelay = function()
		self.view:showInstrustingMask(false)
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
			self.view:refreshSeatState(seatInfo)
			self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, false)
			self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, false)
			self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
			self.view:showSeatLandLordIcon(seatInfo.localSeatIndex, false)
			self.view:playCallLordScore(seatInfo.localSeatIndex, false)
		end
		roomInfo.state = 0
		roomInfo.isRoundStarted = false
		roomInfo.lordid = 0
		roomInfo.di_cards = {}
		roomInfo.auto_ready_time = eventData.auto_ready_time

		self.view:showDeskLeftCards(false)
		self.view:showChuPaiButtons(false)

		self:cleanDesk()
		if(self.isGoldTable)then
			self.view:showReadyBtn(true)
			self.view:showSeatClock(mySeatInfo.localSeatIndex, true, true, self:get_ready_left_secs())
		else
			self.view:showReadyBtn(false)
		end

		local is_summary_account = eventData.is_summary_account
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
			seatInfo.coinBalance = tmpPlayer.coinBalance
			player.isRoomCreator = seatInfo.isCreator or false
			self.view:refreshSeatState(seatInfo)
			player.show_cards = tmpPlayer.show_cards
			player.spring = tmpPlayer.spring
			player.spring_times = tmpPlayer.spring_times
			player.show_cards_times = tmpPlayer.show_cards_times
			player.bomb_cnt = tmpPlayer.bomb_cnt
			player.bombCount = tmpPlayer.current_bomb_cnt
			player.win_cnt = tmpPlayer.win_cnt or 0
			player.totalScore = tmpPlayer.score or 0
			player.score = tmpPlayer.current_score or 0
			player.multiple = tmpPlayer.beishu or 1
			player.restCoin = tmpPlayer.restCoin		--金币场未结清的输赢
			player.restRedPackage = tmpPlayer.restCoin * 0.001
			player.coin = tmpPlayer.Coin
			player.coinBalance = tmpPlayer.coinBalance
			if(not is_summary_account)then
				if(self.isGoldSettle)then
					player.coin = player.coin + player.restCoin
				end
			end

			player.played_cards = {}
			if(tmpPlayer.played_cards ~= '')then
				local played_cards = ModuleCache.Json.decode(tmpPlayer.played_cards)
				local len = 0
				for i, v in pairs(played_cards) do
					len = len + 1
				end
				for i = 1, len do
					local cards = played_cards[i .. '']
					if(cards ~= 'PASS')then
						table.insert(player.played_cards, cards)
						self.myHandPokers:sortCodeList(cards, true)
					end
				end
			end

			player.handcards = ModuleCache.Json.decode(tmpPlayer.cards)
			player.cards = tmpPlayer.sur_cards
			self.myHandPokers:sortCodeList(player.cards, true)
			self.myHandPokers:sortCodeList(player.handcards)

			if(player.playerId == eventData.lordid)then
				player.isLord = true
			end
			data.players[i] = player
		end
		table.sort(data.players, function(p1,p2)
			return p1.seatIndex < p2.seatIndex
		end)
		data.roomInfo = roomInfo
		data.startTime = eventData.startTime
		data.endTime = eventData.endTime
		data.myPlayerId = mySeatInfo.playerId
		data.lordid = eventData.lordid
		data.free_sponsor = eventData.free_sponsor	--申请解散者id
		data.is_free_room = eventData.is_free_room
		if(roomInfo.ruleTable.game_type == 0)then
			data.roomDesc = '经典玩法'
		end
		local isSpring = false
		for i,v in ipairs(data.players) do
			if(v.spring >= 1)then
				isSpring = true
			end
			if(v.playerId == mySeatInfo.playerId)then
				if(v.score < 0)then
					self.tableSound:playGameLoseSound()
				else
					self.tableSound:playGameWinSound()
				end
			end
		end
		if(self.isGoldTable)then
			data.is_gold_settle = true
			data.is_gold_table_settle = true
			data.auto_ready_timestamp = roomInfo.auto_ready_time + os.time()
		elseif(self.isGoldSettle)then
			data.is_gold_settle = true
			data.is_gold_table_settle = false
		end
		if(not eventData.have_jiesuan)then
			if(isSpring)then
				self.view:playChunTianEffect(mySeatInfo, function()
					ModuleCache.ModuleManager.show_module(self.module.packageName, "onegameresult", data)
				end)
			else
				ModuleCache.ModuleManager.show_module(self.module.packageName, "onegameresult", data)
			end
		end
		if(is_summary_account)then
			self.module.TableManager:disconnect_game_server()
			ModuleCache.net.NetClientManager.disconnect_all_client()
			ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
			self.summary_account_fun = function()
				self.tableSound:playMathWinSound()
				ModuleCache.ModuleManager.show_module('doudizhu', "tableresult", data)
				self.modelData.curTableData.roomInfo = nil	
			end
			if(eventData.have_jiesuan)then
				self.summary_account_fun()
			end
		end
	end
	if(eventData.is_free_room)then
		onFinishDelay()
	else
		if(self.discard_notify_received)then
			self.discard_notify_received = nil
			self.module:subscibe_time_event(1.5, false, 0):OnComplete(function(t)	
				onFinishDelay()
			end)
		else
			onFinishDelay()
		end
	end
end

function DouDiZhuGameLogic:on_table_gameinfo_notify(eventData)
	self:initTableData(eventData)
	--初始化主牌
	
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	
	mySeatInfo.handCardSet = CardSet.new(mySeatInfo.handCodeList, #mySeatInfo.handCodeList)
	self.myHandPokers.on_finish_drag_pokers_reselect_fun = function()
		self:on_finish_drag_pokers_reselect_fun()
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
	local wanfaName = '经典玩法'
	if(roomInfo.ruleTable.game_type == 1)then
		wanfaName = ''
	end
	self.view:setRoomInfo(roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount, wanfaName)


	self.view:showFengDingText(true, self:get_rule_tips())

	--显示倍数
	self.view:showMultiple(true, mySeatInfo.beishu)

	if(mySeatInfo.isLord)then
		self.myHandPokers.show_lord_tag = true
	else
		self.myHandPokers.show_lord_tag = false
	end
	if(mySeatInfo.show_cards)then
		self.myHandPokers.show_mingpai_tag = true
	else
		self.myHandPokers.show_mingpai_tag = false
	end

	local showCoin = self.isGoldTable or self.isGoldSettle
	local playerCount = 0
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, false)
		self.view:showSeatGoldCoin(seatInfo.localSeatIndex, showCoin, not showCoin)
		self.view:refreshSeatState(seatInfo, seatInfo.lastLocalSeatIndex)
		self.view:showSeatLandLordIcon(seatInfo.localSeatIndex, seatInfo.isLord)
		if(seatInfo.lastLocalSeatIndex == seatInfo.localSeatIndex)then
			self.view:refreshSeatPlayerInfo(seatInfo)

			if self.modelData.roleData.RoomType == 2 then
				local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
				ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, false)
			end

			self.view:refreshSeatOfflineState(seatInfo)
		else

		end
		if(seatInfo.playerId ~= 0)then
			playerCount = playerCount + 1
		end
		--显示明牌
		if(seatInfo.show_cards and seatInfo ~= mySeatInfo)then
			self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
			self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.handCodeList)
		else
			self.view:showSeatHandPokers(seatInfo.localSeatIndex, false)
		end
	end

	if(self.isGoldTable)then
		if(not mySeatInfo.isReady)then
			self.view:showReadyBtn(true)
			self.view:showSeatClock(mySeatInfo.localSeatIndex, true, true, self:get_ready_left_secs())
		end
		self.view:showInstrustingMask(mySeatInfo.intrustState == 1)
	else
		if self.modelData.roleData.RoomType ~= 2 then
			self.view:showInviteBtn(playerCount ~= 3)
		else
			self.view:showInviteBtn(not roomInfo.isRoundStarted)
		end

		--显示离开按钮
		if(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0)then
			self.module:refresh_share_clip_board()
			if self.modelData.roleData.RoomType ~= 2 then
				self.view:showLeaveBtn(playerCount ~= 3)
			else
				self.view:showLeaveBtn(true)
			end

			if(mySeatInfo.isReady)then
				self.view:showReadyBtn_three(false)
			else
				if self.modelData.roleData.RoomType == 2 then
					self.view:showReadyBtn_three(true)
				else
					self.model:request_ready()
				end

			end
		else
			self.view:showLeaveBtn(false)
			if(mySeatInfo.isReady)then
				self.view:showReadyBtn(false)
			else
				self.view:showReadyBtn(true)
			end
		end
	end

	self.view:showChuPaiButtons(false)

	if(self.isEnterRoom)then
		self.isEnterRoom = false
	end
	local initFunction = function()
		self.isFinishFaPai = true
		--判断游戏是否已经开局
		if(roomInfo.isRoundStarted)then
			roomInfo.showcards_stage = 3
			for i=1,#seatInfoList do
				local seatInfo = seatInfoList[i]
				self.view:showLeftHandCardCountBg(seatInfo.localSeatIndex, true)
				self.view:refreshLeftHandCardCount(seatInfo.localSeatIndex, roomInfo.ruleTable.showCardsCount and seatInfo ~= mySeatInfo, seatInfo.leftCardCount)
				self.view:showSeatWarningIcon(seatInfo.localSeatIndex, seatInfo.warning_flag or false)
				--显示抢地主倍数
				self.view:playCallLordScore(seatInfo.localSeatIndex, seatInfo.grablord_score >= 0, seatInfo.grablord_score, true)

				if(seatInfo.round_discard_cnt == 0)then --已过牌
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, true, true)
				elseif(seatInfo.round_discard_cnt > 0 and roomInfo.desk_player_id == seatInfo.playerId)then --已出牌
					self:sort_pattern_by_type(seatInfo.round_discard_pattern)
					local cards = seatInfo.round_discard_pattern.sorted_cards
					self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, seatInfo.isLord, true)
				else
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, false, true)
				end

				
				if(seatInfo.playerId == roomInfo.next_player_id)then
					self.view:showSeatClock(seatInfo.localSeatIndex, true, seatInfo == mySeatInfo, self:get_chupai_left_secs())
					--清除下一个出牌玩家的桌面
					self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
					self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
				end
			end

			if(roomInfo.next_player_id == mySeatInfo.playerId)then
				local canDrop, pattern, canBigger, count = self:can_drop_cards(roomInfo.lastDisCardSeatInfo)
				canBigger = canBigger or false
				if(is_first_pattern and canDrop and pattern)then
					if(not self.isGoldTable)then
						--先显示后逻辑start
						mySeatInfo.round_discard_pattern = pattern
						self:dispatchPoker(mySeatInfo, roomInfo.lastDisCardSeatInfo, nil)

						self:refreshMySeatDiscardView()
						--end
					end

					self.model:request_discard(false, pattern.cards)
				else
					self.view:showChuPaiButtons(true, is_first_pattern, not canBigger)
					if(canBigger and count == 1)then
						self:on_click_tishi_btn()
					end
				end
			end

			if((not roomInfo.lordid or roomInfo.lordid == 0))then
				if(roomInfo.cur_grablord_id and roomInfo.cur_grablord_id ~= 0)then
					self:on_next_grablord(roomInfo.cur_grablord_id, roomInfo.grablord_score_list)
				else
					self.view:showMingPaiBtn(true and (not mySeatInfo.show_cards))
				end
			else
				if(mySeatInfo.isLord and mySeatInfo.leftCardCount == 20)then
					self.view:showMingPaiBtn(true and (not mySeatInfo.show_cards), true)
				else
					self.view:showMingPaiBtn(false)
				end
			end
			self.view:showDeskLeftCards(true)
			self.view:refreshDeskLeftCards(roomInfo.di_cards, true)
		else
			roomInfo.showcards_stage = 1
			self.view:showMingPaiBtn(false)
			self.view:showDeskLeftCards(false)
		end
	end

	if(self.isWaitingFaPai)then
		self.isWaitingFaPai = false
		local fapaiFun = function(onFinish)
			roomInfo.showcards_stage = 2
			self.view:showMingPaiBtn(true and (not mySeatInfo.show_cards))
			self.tableSound:playFaPaiSound()
			self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, nil, false)
			self.myHandPokers:show_handPokers(true, false)
			self.myHandPokers:resetPokers(true)
			self.myHandPokers:playFaPaiAnim(onFinish)
		end
		fapaiFun(initFunction)
	elseif(not self.isFinishFaPai)then
		
	else
		if(not self.is_playing_set_lord_anim)then
			self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, nil)
			self.myHandPokers:show_handPokers(true, true)
			self.myHandPokers:resetPokers(true)
		end
		initFunction()
	end


end

function DouDiZhuGameLogic:cleanDesk()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		self.view:showSeatHandPokers(seatInfo.localSeatIndex, false)
		self.view:showSeatClock(seatInfo.localSeatIndex, false)
		self.view:showSeatWarningIcon(seatInfo.localSeatIndex, false)
	end
	self.myHandPokers:removeAll()
	self.myHandPokers:repositionPokers(self.myHandPokers.colList)
end


function DouDiZhuGameLogic:on_next_grablord(playerId, scoreList)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local nextSeatInfo = self.module:getSeatInfoByPlayerId(playerId, seatInfoList)
	if(nextSeatInfo == mySeatInfo)then
		self.view:showGrabLordBtns(true, scoreList)
	end
	--显示下一个叫分的玩家
	self.view:showSeatClock(nextSeatInfo.localSeatIndex, true, nextSeatInfo == mySeatInfo, self:get_ready_left_secs())
end

--初始化牌桌数据
function DouDiZhuGameLogic:initTableData(data)
	local roomInfo
	if(self.isEnterRoom)then
		roomInfo = {}
		self.modelData.curTableData = {}
	else
		roomInfo = self.modelData.curTableData.roomInfo
	end
	roomInfo.showcards_stage = 1
	roomInfo.roomNum = data.room_id
	roomInfo.totalRoundCount = data.game_total_cnt
	roomInfo.curRoundNum = data.game_loop_cnt
	roomInfo.desk_player_id = data.desk_player_id
	roomInfo.next_player_id = data.next_player_id
	roomInfo.baseCoinScore = data.baseCoinScore
	roomInfo.desk_cards = {}
	if(data.desk_cards)then
		for i=1,#data.desk_cards do
			roomInfo.desk_cards[i] = data.desk_cards[i]
		end
	end

	roomInfo.di_cards = {}
	if(data.di_cards)then
		for i=1,#data.di_cards do
			roomInfo.di_cards[i] = data.di_cards[i]
		end
	end

	roomInfo.server_timestamp = data.time
	roomInfo.timeOffset = data.time - os.time()

	roomInfo.state = data.state
    roomInfo.isRoundStarted = data.is_deal		--是否已经发牌
	if(data.dealcard)then
		self.isWaitingFaPai = true
		self.isFinishFaPai = false
		roomInfo.isRoundStarted = true
	end

	roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
	roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc

	roomInfo.rate = data.rate		--底分
	roomInfo.lordid = data.lordid		--地主id
	roomInfo.stage_desc = data.stage_desc 	--房间描述信息

	roomInfo.cur_grablord_id = data.cur_grablord_id
	roomInfo.grablord_score_list = data.grablord_score_list
	roomInfo.feeNum = data.feeNum     --金币场房费
	roomInfo.bomb_cnt = data.bomb_cnt		--炸弹数

	roomInfo.auto_op_time = data.auto_op_time	--出牌时间
	roomInfo.auto_ready_time = data.auto_ready_time	--准备时间

	local seatInfoList
	local seatCount = 3
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
			seatInfo.beishu = 0
			seatInfo.isLord = false
			seatInfo.intrustState = 0
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
		if seatInfo.isCreator then
			roomInfo.CreatorId = remotePlayerInfo.player_id ---房主ID
		end

		seatInfo.isOffline = remotePlayerInfo.is_offline
		seatInfo.warning_flag = remotePlayerInfo.is_single--是否报警
		seatInfo.score = remotePlayerInfo.score
		seatInfo.winTimes = remotePlayerInfo.win_cnt
		seatInfo.lostTimes = remotePlayerInfo.lost_cnt
		seatInfo.leftCardCount = remotePlayerInfo.rest_card_cnt	--剩余手牌数
		seatInfo.beishu = remotePlayerInfo.beishu		--倍数
		seatInfo.intrustState = remotePlayerInfo.intrustState	--1 代表托管状态  0 代表取消托管状态
		seatInfo.coinBalance = remotePlayerInfo.coinBalance

		--TODO XLQ 玩家已参与的游戏局数 （发牌后 +1）
		seatInfo.playedRoundCount =  data.game_total_cnt

		seatInfo.isLord = false
		if(not data.lordid or data.lordid == 0)then
			seatInfo.grablord_score = remotePlayerInfo.grablord_score
		else
			seatInfo.grablord_score = -1
			if(data.lordid == seatInfo.playerId)then
				seatInfo.isLord = true
			end
		end

		seatInfo.show_cards = remotePlayerInfo.show_cards		--是否明牌
		seatInfo.round_discard_cnt = remotePlayerInfo.round_discard_cnt or -1	--本轮出牌情况 -1 还未轮到 0 已过牌 其他表示出牌数量
		--print(seatInfo.localSeatIndex, seatInfo.round_discard_cnt, remotePlayerInfo.round_discard_cnt)
		seatInfo.round_discard_info = {}
		if(remotePlayerInfo.round_discard_info)then	--当前出牌
			for i=1,#remotePlayerInfo.round_discard_info do
				seatInfo.round_discard_info[i] = remotePlayerInfo.round_discard_info[i]
			end
		end

		local cardPattern = CardPattern.new(seatInfo.round_discard_info)
		if(cardPattern)then
			seatInfo.round_discard_pattern = cardPattern
		else
			seatInfo.round_discard_pattern = nil
		end

		if(seatInfo.playerId == tonumber(self.modelData.curTablePlayerId))then
			if(not self.is_playing_set_lord_anim)then
				seatInfo.handCodeList = {}
				roomInfo.mySeatInfo = seatInfo
				seatInfo.isOffline = false
				for i=1,#data.cards do
					seatInfo.handCodeList[i] = data.cards[i]
				end
			end
		elseif(seatInfo.show_cards)then
			seatInfo.handCodeList = {}
			for i=1,#remotePlayerInfo.cards do
                seatInfo.handCodeList[i] = remotePlayerInfo.cards[i]
            end
			self.myHandPokers:sortCodeList(seatInfo.handCodeList)
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
function DouDiZhuGameLogic:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	local disp_type = cardPattern.disp_type
	if(type == CardCommon.zhadan)then
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.huojian)then	--火箭
		self.view:playWangZhaEffect(seatInfo)
	elseif(type == CardCommon.liandui)then	--连对
		self.view:playLianDuiEffect(seatInfo)
	elseif(type == CardCommon.feiji)then --飞机
		self.view:playFeiJiEffect(seatInfo)
	elseif(type == CardCommon.shunzi)then
		self.view:playShunZiEffect(seatInfo)
	end

end

--播放不出音效
function DouDiZhuGameLogic:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

--判断是否能够出牌
function DouDiZhuGameLogic:checkCanChuPai(srcPattern, codeList)
	local selectedPattern = CardPattern.new(codeList)
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


function DouDiZhuGameLogic:getDisplayNameFromName(card_name)
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

function DouDiZhuGameLogic:seatIndex_pos(srcSeatIndex, dstSeatIndex)
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


function DouDiZhuGameLogic:sort_pattern_by_type(pattern)
	local sortedCardHolderList = {}
	local name_count_table = {}
	for i=1,#pattern.cards do
		local holder = {}
		holder.cardCode = pattern.cards[i]
		holder.card = CardCommon.ResolveCardIdx(pattern.cards[i])
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
			if(type == cardCommon.sandaiyi)then
				return name_count_table[t1.card.name] > name_count_table[t2.card.name]
			else
				if(type == cardCommon.shunzi
				or type == cardCommon.feiji
				or type == cardCommon.liandui)then
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
	for i=1,#sortedCardHolderList do
		pattern.sorted_cards[i] = sortedCardHolderList[i].cardCode
	end
end

--自己打完牌后刷新手牌和桌面
function DouDiZhuGameLogic:refreshMySeatDiscardView()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	self.view:showChuPaiButtons(false)
	if(self.isGoldTable)then
		self.myHandPokers:genPokerHolderList(mySeatInfo.handCodeList, nil, false)
		self.myHandPokers:show_handPokers(true, true)
		self.myHandPokers:resetPokers(true)
	else
		self.myHandPokers:removePokerHolders(self.selected_chupai_PokerHolders)
		self.myHandPokers:repositionPokers(self.myHandPokers.colList)
		self.selected_chupai_PokerHolders = {}
		self.selected_chupai_CodeList = {}
	end
end

--出牌动画、音效播放
function DouDiZhuGameLogic:dispatchPoker(seatInfo, lastDisCardSeatInfo, onFinish)
	self:sort_pattern_by_type(seatInfo.round_discard_pattern)
	local cards = seatInfo.round_discard_pattern.sorted_cards

	self.view:playDispatchPokers(seatInfo.localSeatIndex, true, cards, seatInfo.isLord, false, onFinish)
	if(not lastDisCardSeatInfo)then
		self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, nil)
	else
		self:playCardPatternSoundAndEffect(seatInfo, seatInfo.round_discard_pattern, lastDisCardSeatInfo.round_discard_pattern)
	end
end


--是否能够一手丢
function DouDiZhuGameLogic:can_drop_cards(lastDisCardSeatInfo)
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
				self.myHandPokers:selectPokers(pattern.cards)
				self.myHandPokers:refreshPokerSelectState(true)
				local selectedPokerHolders, selectPokerList, selectedCodeList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList = self.myHandPokers:getSelectedPokers()
				self.selected_chupai_PokerHolders = real_selectedPokerHolders
				self.selected_chupai_cardPattern = pattern
				return true, pattern, true, count
			end
		end
		return false, nil, true, count
	else
		return false
	end
	return false
end

function DouDiZhuGameLogic:playBgm()
	self.tableSound:playBgm()
end


function DouDiZhuGameLogic:testfun()
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

function DouDiZhuGameLogic:on_finish_drag_pokers_reselect_fun()
	local pokerHolderList, pokerList, selectedCodeList, real_selectedPokerHolders, real_selectPokerList, real_selectedCodeList = self.myHandPokers:getSelectedPokers()
	if(#selectedCodeList > 0)then
		local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
		local pattern = mySeatInfo.handCardSet:choose_hintIterator(selectedCodeList)
		if(pattern)then
			self.myHandPokers:selectPokers(pattern.cards)
			self.is_playing_select_poker_anim = true
			self.myHandPokers:refreshPokerSelectState(false, function()
				self.is_playing_select_poker_anim = false
			end)
		end
	end
end

function DouDiZhuGameLogic:removeCodeListFromList(srcCodeList, codeList)
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
function DouDiZhuGameLogic:playSetLordEffect(seatInfo, onFinish1, onFinish2)
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

function DouDiZhuGameLogic:on_click_gameresule_continue_btn()
	if(self.summary_account_fun)then
		self.summary_account_fun()
	else
		self.model:request_ready()
	end
end

--金币变化通知
function DouDiZhuGameLogic:on_shotsettle_notify(data)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local oneShotSettlePlayer = data.players
	for i = 1, #oneShotSettlePlayer do
		local player = oneShotSettlePlayer[i]
		local seatInfo = self.module:getSeatInfoByPlayerId(player.player_id, seatInfoList)
		seatInfo.coinBalance = player.coinBalance
	end

	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		self.view:refreshSeatState(seatInfo)
	end
end

function DouDiZhuGameLogic:on_instrust_rsp(eventData)

end

function DouDiZhuGameLogic:on_intrust_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local seatInfo = self.module:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
	if(seatInfo)then
		seatInfo.intrustState = eventData.status
		if(seatInfo == mySeatInfo)then
			self.view:showInstrustingMask(seatInfo.intrustState == 1)
		else
			self.view:refreshSeatState(seatInfo)
		end
	end
end

function DouDiZhuGameLogic:on_recharge_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	local seatInfo = self.module:getSeatInfoByPlayerId(eventData.playerid, seatInfoList)
	if(seatInfo)then
		seatInfo.isRecharging = eventData.open
		if(roomInfo.next_player_id == seatInfo.playerId)then
			if(eventData.time ~= 0)then
				roomInfo.auto_op_time = eventData.time
				self.view:showSeatClock(seatInfo.localSeatIndex, true, seatInfo == mySeatInfo, self:get_chupai_left_secs())
			end
		end
		self.view:refreshSeatState(seatInfo)
	end
end

function DouDiZhuGameLogic:get_chupai_left_secs()
	local roomInfo = self.modelData.curTableData.roomInfo
	if(self.isGoldTable)then
		return roomInfo.auto_op_time
	end
	return 16
end

function DouDiZhuGameLogic:get_ready_left_secs()
	local roomInfo = self.modelData.curTableData.roomInfo
	if(self.isGoldTable)then
		return roomInfo.auto_ready_time
	end
	return 16
end

function DouDiZhuGameLogic:get_rule_tips()
	local roomInfo = self.modelData.curTableData.roomInfo
	local ruleTable = roomInfo.ruleTable
	local fengDingText = ''
	if(ruleTable.showCardsCount)then
		fengDingText = '显示剩余牌数'
	else
		fengDingText = '不显示剩余牌数'
	end

	if(ruleTable.maxbeishu == 4)then
		fengDingText = fengDingText .. ' ' .. '4倍封顶'
	elseif(ruleTable.maxbeishu == 8)then
		fengDingText = fengDingText .. ' ' .. '8倍封顶'
	elseif(ruleTable.maxbeishu == 0)then
		fengDingText = fengDingText .. ' ' .. '不封顶'
	end

	if(self.isGoldTable)then
		fengDingText = fengDingText .. ' 底分:' .. roomInfo.baseCoinScore
	elseif(self.isGoldSettle)then
		fengDingText = fengDingText .. ' 底分:' .. ruleTable.baseScore
	end

	if(ruleTable.isPrivateRoom)then
		fengDingText = fengDingText .. ' 私人房'
	end

	return fengDingText
end

return DouDiZhuGameLogic