
local class = require("lib.middleclass")
--- @class TableDouNiuLogic_GoldCoin
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_GoldCoin = class('TableDouNiuLogic_GoldCoin')
local CSmartTimer = ModuleCache.SmartTimer.instance

function TableDouNiuLogic_GoldCoin :initialize(...)
	self.parentClass.initialize(self, ...)
	self.isGoldUnlimited = self.modelData.tableCommonData.isGoldUnlimited
	self.tableView.uistatewitcher_goldcoin_ready:SwitchState('Ready_Only')
	--去掉换桌功能
	--if(self.isGoldUnlimited)then
	--	self.tableView.uistatewitcher_goldcoin_ready:SwitchState('Ready_Only')
	--else
	--	self.tableView.uistatewitcher_goldcoin_ready:SwitchState('Change_Ready')
	--end

	self.tableModel.request_start = function() end
	ModuleCache.ComponentUtil.SafeSetActive(self.tableView.switcher.gameObject, false)
	self.tableView.setRoomInfo = function() end
	self.tableView.refreshClock = self.tableView.refreshDigitalClock
	self.tableView.showBetBtns = function()	end
	self.tableView.showBetBtns_Custom = function(view, show, array, multipleArray, originalScoreList)
		--print_table({}, 'showBetBtns_Custom-----' .. (show and 'true' or 'false'))
		if (show) then
			for i=1,#view.goldCoinBetArray do
				ModuleCache.ComponentUtil.SafeSetActive(view.goldCoinBetArray[i].button.gameObject, false)
			end

			for i,v in ipairs(originalScoreList) do
				local goldCoinBetHolder = view.goldCoinBetArray[i]
				goldCoinBetHolder.text.text = v
				goldCoinBetHolder.text_gray.text = v
				if(array[i])then
					goldCoinBetHolder.val = multipleArray[i]
					goldCoinBetHolder.button.enabled = true
					view:setGray(goldCoinBetHolder.button.gameObject, false, true)
					ModuleCache.ComponentUtil.SafeSetActive(goldCoinBetHolder.text_gray.gameObject, false)
					ModuleCache.ComponentUtil.SafeSetActive(goldCoinBetHolder.text.gameObject, true)
				else
					goldCoinBetHolder.button.enabled = false
					view:setGray(goldCoinBetHolder.button.gameObject, true, true)
					ModuleCache.ComponentUtil.SafeSetActive(goldCoinBetHolder.text_gray.gameObject, true)
					ModuleCache.ComponentUtil.SafeSetActive(goldCoinBetHolder.text.gameObject, false)
				end
				ModuleCache.ComponentUtil.SafeSetActive(goldCoinBetHolder.button.gameObject, true)
			end
			ModuleCache.ComponentUtil.SafeSetActive(view.goGoldCoinBetBtnsRoot, true)
		else
			ModuleCache.ComponentUtil.SafeSetActive(view.goGoldCoinBetBtnsRoot, false)
		end
	end
	self.tableView.showQiangZhuangBeiShuBtns_Custom = function(view, show, array, originalBeiShuList)
		if (show) then
			for i=1,10 do
				ModuleCache.ComponentUtil.SafeSetActive(view['buttonQiangZhuang_'..i].gameObject, false)
			end
			for i,v in ipairs(originalBeiShuList) do
				local key = 'buttonQiangZhuang_'..v
				local key_text = 'textQiangZhuang_'..v
				local key_text_gray = 'textGrayQiangZhuang_'..v
				if(view[key])then
					ModuleCache.ComponentUtil.SafeSetActive(view[key].gameObject, true)
				end
				local include = false
				for j = 1, #array do
					local value = array[j]
					if(value == v)then
						include = true
					end
				end
				if(include)then
					view[key].enabled = true
					view:setGray(view[key].gameObject, false, true)
					ModuleCache.ComponentUtil.SafeSetActive(view[key_text].gameObject, true)
					ModuleCache.ComponentUtil.SafeSetActive(view[key_text_gray].gameObject, false)
				else
					view[key].enabled = false
					view:setGray(view[key].gameObject, true, true)
					ModuleCache.ComponentUtil.SafeSetActive(view[key_text].gameObject, false)
					ModuleCache.ComponentUtil.SafeSetActive(view[key_text_gray].gameObject, true)
				end
			end
			ModuleCache.ComponentUtil.SafeSetActive(view.goQiangZhuangBtnsRoot, true)
		else
			ModuleCache.ComponentUtil.SafeSetActive(view.goQiangZhuangBtnsRoot, false)
		end
	end

	self.tableHelper.setBetScore = function(helper, seatHolder, seatData, show)
		show = show or false
		show = show and seatData.betScore ~= 0
		ModuleCache.ComponentUtil.SafeSetActive(seatHolder.text_goldCoin_betScore.transform.parent.gameObject, show and (not seatData.isBanker))
		ModuleCache.ComponentUtil.SafeSetActive(seatHolder.text_goldCoin_betScore.gameObject, show and (not seatData.isBanker))
		if(show)then
			local roomInfo = self.modelData.curTableData.roomInfo
			seatHolder.text_goldCoin_betScore.text = 'x' .. seatData.betScore * roomInfo.baseCoinScore
		end
	end
	self.tableHelper.refreshSeatInfo_old = self.tableHelper.refreshSeatInfo
	self.tableHelper.refreshSeatInfo = function(helper, seatHolder, seatInfo)
		self.tableHelper.refreshSeatInfo_old(helper, seatHolder, seatInfo)
		if(seatInfo.playerId and (seatInfo.playerId ~= 0 and seatInfo.playerId ~= "0"))then
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)
		else
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, true)
		end
	end

	self.tableView:showRoomInfoAndRuleBtn(false)
	for i,v in ipairs(self.tableView.srcSeatHolderArray) do
		self.tableHelper:showSeatGoldCoin(v, true)
	end
	ModuleCache.ComponentUtil.SafeSetActive(self.tableView.button_goldCoin_exit.gameObject, true)
	ModuleCache.ComponentUtil.SafeSetActive(self.tableView.button_wanfashuoming.gameObject, true)
	ModuleCache.ComponentUtil.SafeSetActive(self.tableView.button_tableshop.gameObject, true)
end

function TableDouNiuLogic_GoldCoin:initTableSeatData(data)
	self.parentClass.initTableSeatData(self, data)
end

--同步消息
function TableDouNiuLogic_GoldCoin:on_table_synchronize_notify(data)
	self.is_first_synchronize = true
	self.parentClass.on_table_synchronize_notify(self, data)
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.roomNum = self.modelData.roleData.myRoomSeatInfo.RoomID
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.scramble_banker_state == 1)then
			self.tableView:showQiangZhuangBeiShuBubble(seatInfo, true, seatInfo.qiangZhuangBeiShu)
		else
			self.tableView:showQiangZhuangBeiShuBubble(seatInfo, false)
		end

	end
	self.tableView:showGoldCoinDiZhu(true, roomInfo.baseCoinScore)
end

--开始通知
function TableDouNiuLogic_GoldCoin:on_table_start_notify(data)
	self.parentClass.on_table_start_notify(self, data)
	self.tableView:showCenterTips(true, string.format('本局服务费%d金币', self.modelData.curTableData.roomInfo.feeNum))
	self.tableModule:subscibe_time_event(2, false, 0):OnComplete(function (t)
		self.tableView:showCenterTips(false)
		self:refreshMyTableViewState()
	end)
	local roomInfo = self.modelData.curTableData.roomInfo
	self.tableView:showGoldCoinDiZhu(true, roomInfo.baseCoinScore)
end

-- 上一局的结算通知
function TableDouNiuLogic_GoldCoin:on_table_ago_settle_accounts_notify(data)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(not mySeatInfo.inHandPokerList or #mySeatInfo.inHandPokerList == 0)then
		-- 重置数据
		self:resetRoundState()
		if(not mySeatInfo.isReady)then
			self:startContinueBtn()
		end
		return
	end
	self:on_table_settleAccounts_Notify(data)
end

-- 单局结算通知
function TableDouNiuLogic_GoldCoin:on_table_settleAccounts_Notify(data)
	local roomInfo = self.modelData.curTableData.roomInfo
	local resultList = data.settleAccounts
	for i = 1, #resultList do
		local result = resultList[i]
		result.score = result.score * roomInfo.baseCoinScore
	end
	self.parentClass.on_table_settleAccounts_Notify(self, data)
end

function TableDouNiuLogic_GoldCoin:table_settle_effect(resultList, onFinish)
	self.is_received_reset_notify = false
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	local mySeatInfo = roomInfo.mySeatInfo
	local bankerSeatInfo
	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo.isBanker)then
			bankerSeatInfo = seatInfo
		end
	end
	local loseSeatList = {}
	local winSeatList = {}
	local bankerSeatIndex = bankerSeatInfo.seatIndex
	local tmpList = {}
	for i = 1, #resultList do
		local result = resultList[i]
		local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, seatInfoList)
		seatInfo.localOffsetBanker = self.tableHelper:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, bankerSeatIndex, self.seatCount)
		if(seatInfo == bankerSeatInfo)then

		else
			table.insert(tmpList, seatInfo)
			local score = seatInfo.curRound.score
			if(score > 0)then
				table.insert(winSeatList, seatInfo)
			elseif(score < 0)then
				table.insert(loseSeatList, seatInfo)
			end
		end
	end
	table.sort(tmpList, function (t1,t2)
		return t1.localOffsetBanker > t2.localOffsetBanker
	end)
	table.insert(tmpList, bankerSeatInfo)

	local playRoundResultScoreEffect = function()
		for i = 1, #resultList do
			local result = resultList[i]
			local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, seatInfoList)
			local score = result.score
			if(seatInfo)then
				self:playRoundResultScore(seatInfo, score)
			end
		end
	end

	local playGoldFlyEffect = function(seatList, banker, toBanker, onFinish)
		if(#seatList == 0)then
			if(onFinish)then
				onFinish()
				return
			end
		end
		local totalCount = #seatList
		local finishCount = 0
		for i = 1, totalCount do
			local seatInfo = seatList[i]
			local from = banker
			local to = seatInfo
			if(toBanker)then
				from = seatInfo
				to = banker
			end
			self.tableView:flyGoldToSeat(from.localSeatIndex, to.localSeatIndex, function ()
				finishCount = finishCount + 1
				if(finishCount == totalCount)then
					if(onFinish)then
						onFinish()
					end
				end
			end)
		end
		if(totalCount > 0)then
			self:playCoinFlySound()
		end
	end

	local on_finish_show_result = function()
		playGoldFlyEffect(loseSeatList, bankerSeatInfo, true,function ()
			playGoldFlyEffect(winSeatList, bankerSeatInfo, false, function()
				playRoundResultScoreEffect()
				if(onFinish)then
					onFinish()
				end
				self.is_playing_result_effect = false
				self.tableModule:subscibe_time_event(1, false, 0):OnComplete(function ()
					if(self.start_continue_fun and self.is_received_reset_notify)then
						self.start_continue_fun()
						self.start_continue_fun = nil
					end
				end)
			end)
		end)
	end

	self.is_playing_result_effect = true
	local totalCount = #tmpList
	local finishCount = 0
	for i = 1, #tmpList do
		local seatInfo = tmpList[i]
		local score = seatInfo.curRound.score
		local niuName = seatInfo.curRound.niuName
		--self.tableModule:subscibe_time_event((i - 1) * 1, false, 0):OnComplete(function(t)
		--
		--end)
		if(not seatInfo.isDoneComputeNiu)then
			-- 展示玩家手牌
			self.tableView:refreshSeat(seatInfo, true, (not seatInfo.isDoneComputeNiu) and seatInfo ~= mySeatInfo, true)
			--if (niuName == "cow10" or niuName == "silvercow") then
			--	-- 播放牛牛动画
			--	self.tableView:showNiuNiuEffect(seatInfo, true, 0.5, 1, 0, function()
			--		if (mySeatInfo.isReady) then
			--			-- 已经点击了继续按钮
			--			-- 显示牛名
			--			self.tableView:showNiuName(seatInfo, false, niuName)
			--		else
			--			-- 显示牛名
			--			self.tableView:showNiuName(seatInfo, true, niuName)
			--		end
            --
			--	end)
			--else
			--	-- 显示牛名
			--	self.tableView:showNiuName(seatInfo, true, niuName)
			--end
			self.tableView:showNiuName(seatInfo, true, niuName)
			local isFemale =(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1)
			self.tableHelper:playNiuNameSound(niuName, isFemale)
		else
			self.tableView:refreshSeat(seatInfo, true, false, true)
		end

		if (seatInfo == mySeatInfo) then
			if(score > 0)then
				self.tableHelper:playResultSound(true, score > 0)
			end
		end
		finishCount = finishCount + 1
		if(totalCount == finishCount)then
			self.tableModule:subscibe_time_event(2, false, 0):OnComplete(function(t)
				on_finish_show_result()
			end)
		end

	end

	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		seatInfo.isReady = false
	end
end

function TableDouNiuLogic_GoldCoin:check_need_ready_fun()

	local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
	local show = not mySeatInfo.isReady and (not roomInfo.roundStarted)
	self.is_need_delayshow_changeroom = self.is_first_synchronize and not mySeatInfo.isReady
	self.is_first_synchronize = false
	self.tableView:showReadyBtn(show)
	if(not self.isGoldUnlimited)then
		--去掉换桌按钮
		--if(show)then
		--	if(self.is_need_delayshow_changeroom)then
		--		local delayTime = 5
		--		self.changeBtn_delay_endTime = self:getServerNowTime() + delayTime
		--		self.tableView:showChangeRoomBtn(show, true, delayTime)
		--		local timeEvent = self.tableModule:subscibe_time_event(delayTime, false, 0):OnComplete(function (t)
		--			self.changeBtn_delaying_timeevent_id = nil
		--			self.is_need_delayshow_changeroom = nil
		--			self.tableView:showChangeRoomBtn(true, false)
		--		end):SetIntervalTime(0.1, function(t)
		--			local leftSecs = math.max(0, self.changeBtn_delay_endTime - self:getServerNowTime())
		--			self.tableView:showChangeRoomBtn(true, true, leftSecs)
		--		end)
		--		self.changeBtn_delaying_timeevent_id = timeEvent.id
		--	else
		--		self.tableView:showChangeRoomBtn(true)
		--	end
		--else
		--	self.is_need_delayshow_changeroom = nil
		--	if(self.changeBtn_delaying_timeevent_id)then
		--		CSmartTimer:Kill(self.changeBtn_delaying_timeevent_id)
		--		self.changeBtn_delaying_timeevent_id = nil
		--	end
		--	self.tableView:showChangeRoomBtn(false)
		--end
	end


	if (self.waitReadyTimeEventId) then
		CSmartTimer:Kill(self.waitReadyTimeEventId)
		self.waitReadyTimeEventId = nil
	end
	if(show)then
		mySeatInfo.not_ready_timeout = mySeatInfo.not_ready_timeout or self:getServerNowTime()
		local duration = mySeatInfo.not_ready_timeout - self:getServerNowTime()
		duration = math.max(duration, 0)

		local timeEvent = self.tableModule:subscibe_time_event(duration, false, 0):OnComplete( function(t)
			--self.tableView:showWaitReadyTips(false)
		end ):SetIntervalTime(0.1, function(t)
			local leftSecs = math.max(0, mySeatInfo.not_ready_timeout - self:getServerNowTime())
			self.tableView:showWaitReadyTips(true, leftSecs)
		end )
		self.waitReadyTimeEventId = timeEvent.id;
	else
		self.tableView:showWaitReadyTips(false)
	end
end

--点击下注按钮
function TableDouNiuLogic_GoldCoin:on_click_goldcoin_bet_btn(obj, arg)
	for i,v in ipairs(self.tableView.goldCoinBetArray) do
		if(v.button.gameObject == obj)then
			self.selectedBetScore = v.val
			self.tableModel:request_bet_custom(self.selectedBetScore)
			return
		end
	end
end

--点击设置按钮
function TableDouNiuLogic_GoldCoin:on_click_setting_btn(obj, arg)
	local intentData = { }
	intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_" .. "BULLFIGHT"
	intentData.canExitRoom = false
	intentData.canDissolveRoom = false
	intentData.tableBackgroundSprite = self.tableView.tableBackgroundSprite
	ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", intentData)
end

function TableDouNiuLogic_GoldCoin:getDefaultBetScore()
    local xiaZhuScoreList, targetXiaZhuBeiShuList, originalScoreList, xiaZhuBeiShuList = self:getCanXiaZhuScoreList()
	if(xiaZhuBeiShuList and #xiaZhuBeiShuList > 0)then
		return xiaZhuBeiShuList[1]
	else
		return 0
	end
end

-- 准备回包
function TableDouNiuLogic_GoldCoin:on_table_ready_rsp(data)
	self.parentClass.on_table_ready_rsp(self, data)
	self:check_need_ready_fun()
end

function TableDouNiuLogic_GoldCoin:startContinueBtn()
	self.start_continue_fun = function()
		local roomInfo = self.modelData.curTableData.roomInfo
		local seatInfoList = roomInfo.seatInfoList
		for i = 1, #seatInfoList do
			local seatInfo = seatInfoList[i]
			self.tableView:showSeatRoundScoreAnim(seatInfo, false)
		end
		self:startWaitContinue()
	end
end

function TableDouNiuLogic_GoldCoin:startWaitContinue()
	self.tableView:showContinueBtn(false)
	self:check_need_ready_fun()

	self:refreshResetState()
	self.tableView:hideAllNiuNiuEffect()
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.tableView:showQiangZhuangBeiShuTag(seatInfo, false)
	end
end

function TableDouNiuLogic_GoldCoin:getCanQiangZhuangScoreList()
	--公式：抢庄倍数*最小底分*最大牌型*人数
	local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
	local diZhuScore = roomInfo.baseCoinScore
	local maxPaiXingBeiShu = self:get_max_paixing_beishu(roomInfo.ruleTable)
	local ownGoldCoin = mySeatInfo.gold
	local totalSeatCount = self.tableHelper:getSeatedSeatCount(roomInfo.seatInfoList)
	local minDiZhuScore = self:getDefaultBetScore() * diZhuScore
	local list = self.parentClass.getCanQiangZhuangScoreList(self)
	local scoreList = {}
	for i=1,#list do
		local tmpScore = list[i]
		if(ownGoldCoin >= tmpScore * minDiZhuScore * maxPaiXingBeiShu * totalSeatCount)then
			table.insert( scoreList, tmpScore)
		end
	end
	return scoreList, list
end

function TableDouNiuLogic_GoldCoin:getCanXiaZhuScoreList()
	--公式：抢庄倍数*底分*牌型*1
	local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
	local diZhuScore = roomInfo.baseCoinScore
	local maxPaiXingBeiShu = self:get_max_paixing_beishu(roomInfo.ruleTable)
	local qiangZhuangBeiShu = self:getMaxQiangZhuangBeiShu()
	local ownGoldCoin = mySeatInfo.gold
	local xiaZhuBeiShuList = self:getCanXiaZhuBeiShuList()
	local targetXiaZhuBeiShuList = {}
	local xiaZhuScoreList = {}
	local originalScoreList = {}
	for i=1,#xiaZhuBeiShuList do
		local tmpScore = diZhuScore * xiaZhuBeiShuList[i]
		local maxPay = qiangZhuangBeiShu * tmpScore * maxPaiXingBeiShu * 1
		table.insert(originalScoreList, tmpScore)
		if(i == 1)then
			table.insert(xiaZhuScoreList, tmpScore)
			table.insert(targetXiaZhuBeiShuList, xiaZhuBeiShuList[i])
		elseif(ownGoldCoin >= maxPay)then
			table.insert(xiaZhuScoreList, tmpScore)
			table.insert(targetXiaZhuBeiShuList, xiaZhuBeiShuList[i])
		end
	end
	return xiaZhuScoreList, targetXiaZhuBeiShuList, originalScoreList, xiaZhuBeiShuList
end


function TableDouNiuLogic_GoldCoin:on_reset_notify(eventData)
	self.is_received_reset_notify = true
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.state = self.RoomState.waitReady
    local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#eventData.pos_infos do
		local pos_info = eventData.pos_infos[i]
		local seatInfo = self.tableHelper:getSeatInfoByRemoteSeatIndex(pos_info.pos_index, self.modelData.curTableData.roomInfo.seatInfoList)
		seatInfo.not_ready_timeout = pos_info.not_ready_timeout
	end
	if(self.is_playing_result_effect)then
		return
	end
	if(not mySeatInfo.inHandPokerList or #mySeatInfo.inHandPokerList == 0)then
		-- 重置数据
		self:resetRoundState()
		if(not mySeatInfo.isReady)then
			self:startContinueBtn()
		end
	end
	if(self.start_continue_fun)then
		self.start_continue_fun()
	end
	self.start_continue_fun = nil
end


function TableDouNiuLogic_GoldCoin:getMaxQiangZhuangBeiShu()
	return 1
end

--点击退出房间按钮
function TableDouNiuLogic_GoldCoin:on_click_goldcoin_exit_btn(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(roomInfo.roundStarted and mySeatInfo.isReady)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("牌局进行中，无法离开游戏")
		return
	end
	UnityEngine.PlayerPrefs.SetInt("ChangeTable", 0)
	self.tableModule:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
end

--点击玩法说明按钮
function TableDouNiuLogic_GoldCoin:on_click_wanfashuoming_btn(obj, arg)
	ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
end

function TableDouNiuLogic_GoldCoin:can_invite_wechat_friend()
	if (ModuleCache.GameManager.iosAppStoreIsCheck) then
		return false
	end
	return true
end

function TableDouNiuLogic_GoldCoin:get_max_paixing_beishu(ruleTable)
	local max_paixing_beishu = 1
	if(ruleTable.yiTiaoLong_beiShu)then
		if(max_paixing_beishu < ruleTable.yiTiaoLong_beiShu)then
			max_paixing_beishu = ruleTable.yiTiaoLong_beiShu
		end
	end
	if(ruleTable.niu7_beiShu)then
		if(max_paixing_beishu < ruleTable.niu7_beiShu)then
			max_paixing_beishu = ruleTable.niu7_beiShu
		end
	end
	if(ruleTable.niu8_beiShu)then
		if(max_paixing_beishu < ruleTable.niu8_beiShu)then
			max_paixing_beishu = ruleTable.niu8_beiShu
		end
	end
	if(ruleTable.niu9_beiShu)then
		if(max_paixing_beishu < ruleTable.niu9_beiShu)then
			max_paixing_beishu = ruleTable.niu9_beiShu
		end
	end
	if(ruleTable.niu10_beiShu)then
		if(max_paixing_beishu < ruleTable.niu10_beiShu)then
			max_paixing_beishu = ruleTable.niu10_beiShu
		end
	end
	if(ruleTable.jinNiu_beiShu)then
		if(max_paixing_beishu < ruleTable.jinNiu_beiShu)then
			max_paixing_beishu = ruleTable.jinNiu_beiShu
		end
	end
	if(ruleTable.siZha_beiShu)then
		if(max_paixing_beishu < ruleTable.siZha_beiShu)then
			max_paixing_beishu = ruleTable.siZha_beiShu
		end
	end
	if(ruleTable.wuXiaoNiu_beiShu)then
		if(max_paixing_beishu < ruleTable.wuXiaoNiu_beiShu)then
			max_paixing_beishu = ruleTable.wuXiaoNiu_beiShu
		end
	end
	return max_paixing_beishu
end

-- 播放金币飞翔音效
function TableDouNiuLogic_GoldCoin:playCoinFlySound()
	local soundName = "coin_fly"
	ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableDouNiuLogic_GoldCoin:refreshMyTableViewState()
	self.parentClass.refreshMyTableViewState(self)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local isWatchState = true
	if self.modelData.roleData.RoomType == 2 then
		isWatchState =(mySeatInfo.gameCnt == 0 and roomInfo.curRoundNum ~= mySeatInfo.gameCnt and (mySeatInfo.betScore == 0)
		and(roomInfo.state ~= self.RoomState.waitBet) and not mySeatInfo.is_self_exists)
	else
		isWatchState = (not mySeatInfo.isReady) and(mySeatInfo.betScore == 0) and(roomInfo.state ~= self.RoomState.waitReady)
	end

	if (isWatchState) then
		return
	end
	-- 是否要显示下注按钮
	local needShowBet = mySeatInfo.betScore == 0 and roomInfo.state == self.RoomState.waitBet and(not mySeatInfo.isBanker) and mySeatInfo.isReady
	self.tableView:showBetBtns(false)
	self.tableView:showBetBtns_Custom(needShowBet, self:getCanXiaZhuScoreList())

	--是否要显示选牛面板
	local isWaitXuanNiu = (not mySeatInfo.isDoneComputeNiu) and roomInfo.state == self.RoomState.waitResult
	self.tableView:showAutoSelectToggleBtn(roomInfo.state == self.RoomState.waitResult)
	self.tableView:showSelectNiuPanel(isWaitXuanNiu)
	if(isWaitXuanNiu)then
		if(self.isAutoSelectNiu)then
			self.tableView:showComfirmNiuBtns(false)
			self:autoSelectNiu()
		else
			self.tableView:showComfirmNiuBtns(true)
		end
	else
		self.tableView:showComfirmNiuBtns(false)
	end
end

return TableDouNiuLogic_GoldCoin