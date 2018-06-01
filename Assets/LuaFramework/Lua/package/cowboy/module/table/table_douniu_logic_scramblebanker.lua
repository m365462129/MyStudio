local class = require("lib.middleclass")
local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic")
--- @class TableDouNiuLogic_ScrambleBanker:TableDouNiuLogic
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_ScrambleBanker = class('tableDouNiuLogic_ScrambleBanker', TableDouNiuLogic)
local ModuleCache = ModuleCache
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence

function TableDouNiuLogic_ScrambleBanker :initialize(...)
	TableDouNiuLogic.initialize(self, ...)
	self.RoomState.waitLastPoker = 4		--等待发最后一张牌
	self.RoomState.waitCuoPai = 5			--等待搓牌
	local goCamera = ModuleCache.ComponentUtil.Find(UnityEngine.GameObject.Find("GameRoot"), "Game/UIRoot/UICamera")
	self.uiCamera = ModuleCache.ComponentManager.GetComponent(goCamera, "UnityEngine.Camera")
end

--同步消息
function TableDouNiuLogic_ScrambleBanker:on_table_synchronize_notify(data)
	TableDouNiuLogic.on_table_synchronize_notify(self, data)

	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfoList = roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		self.tableView:showQiangZhuangBeiShuTag(seatInfo, seatInfo.isBanker, seatInfo.qiangZhuangBeiShu)
	end

	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	self.tableView:showQiangZhuangBtns(roomInfo.state == self.RoomState.waitSetBanker and mySeatInfo.scramble_banker_state == 0 and mySeatInfo.isReady)
end

function TableDouNiuLogic_ScrambleBanker:initTableSeatData(data)
	TableDouNiuLogic.initTableSeatData(self, data)
	--缓存座位信息
	local remoteSeatInfoList = data.seatInfoList		
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	local seatCount = #remoteSeatInfoList
	for i=1,#remoteSeatInfoList do
		local remoteSeatInfo = remoteSeatInfoList[i]
		local seatInfo = seatInfoList[i]
		seatInfo.scramble_banker_state = remoteSeatInfo.scramble_banker_state		
		seatInfo.qiangZhuangBeiShu = remoteSeatInfo.multiple
	end
end

function TableDouNiuLogic_ScrambleBanker:refreshMyTableViewState()
	TableDouNiuLogic.refreshMyTableViewState(self)
end

--上一局结算通知
function TableDouNiuLogic_ScrambleBanker:on_table_ago_settle_accounts_notify(data)
	TableDouNiuLogic.on_table_ago_settle_accounts_notify(self, data)

end

--准备响应
function TableDouNiuLogic_ScrambleBanker:on_table_ready_rsp(data)
	TableDouNiuLogic.on_table_ready_rsp(self, data)

end

--准备通知
function TableDouNiuLogic_ScrambleBanker:on_table_ready_notify(data)
	TableDouNiuLogic.on_table_ready_notify(self, data)
end

--开始响应
function TableDouNiuLogic_ScrambleBanker:on_table_start_rsp(data)
	TableDouNiuLogic.on_table_start_rsp(self, data)
end

--开始通知
function TableDouNiuLogic_ScrambleBanker:on_table_start_notify(data)
	TableDouNiuLogic.on_table_start_notify(self, data)
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.roundStarted = true
	roomInfo.state = self.RoomState.waitSetBanker
	self.tableView:refreshSeat(self.modelData.curTableData.roomInfo.mySeatInfo, true)
	if(roomInfo.state == self.RoomState.waitSetBanker and roomInfo.ruleTable.kanPaiCount and roomInfo.ruleTable.kanPaiCount == 0)then
		--显示抢庄按钮
		self.tableView:showQiangZhuangBtns(true)
	end

	--隐藏下注按钮
	self.tableView:showBetBtns(false)
end

--进入房间通知
function TableDouNiuLogic_ScrambleBanker:on_table_enter_notify(data)
	TableDouNiuLogic.on_table_enter_notify(self, data)
end

--抢庄响应
function TableDouNiuLogic_ScrambleBanker:on_table_scramblebanker_rsp(data)
	--隐藏抢庄按钮
	self.tableView:showQiangZhuangBtns(false)

	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	mySeatInfo.scramble_banker_state = (data.is_scramble and 1) or 2
	--显示抢庄的标签
	self.tableView:showQiangZhuangTag(mySeatInfo, true, data.is_scramble)
	--播放抢庄音效
	local isFemale = (mySeatInfo.playerInfo and mySeatInfo.playerInfo.gender ~= 1)
	self.tableHelper:playScrmbleBankerSound(data.is_scramble, isFemale)
end

--抢庄通知
function TableDouNiuLogic_ScrambleBanker:on_table_scramblebanker_notify(data)
	local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, self.modelData.curTableData.roomInfo.seatInfoList)
	seatInfo.scramble_banker_state = (data.is_scramble and 1) or 2
	seatInfo.qiangZhuangBeiShu = data.multiple
	--显示抢庄的标签
	self.tableView:showQiangZhuangTag(seatInfo, true, data.is_scramble)
	--播放抢庄音效
	local isFemale = (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1)
	self.tableHelper:playScrmbleBankerSound(data.is_scramble, isFemale)
	self:refreshMyTableViewState()
end


--下注响应
function TableDouNiuLogic_ScrambleBanker:on_table_bet_rsp(data)
	TableDouNiuLogic.on_table_bet_rsp(self, data)
end

--下注通知
function TableDouNiuLogic_ScrambleBanker:on_table_bet_notify(data)
	TableDouNiuLogic.on_table_bet_notify(self, data)
	local playerId = data.player_id
	local seatInfo = self.tableHelper:getSeatInfoByPlayerId(tostring(playerId), self.modelData.curTableData.roomInfo.seatInfoList)
	self.tableView:showQiangZhuangTag(seatInfo, false)
end

--发牌通知
function TableDouNiuLogic_ScrambleBanker:on_table_fapai_notify(data)
	local pokers = data.pokers
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.state = 100
	local mySeatInfo = roomInfo.mySeatInfo
	
	if(#pokers == 1)then
		local poker = {}
		poker.colour = pokers[1].colour
		poker.number = pokers[1].number
		mySeatInfo.inHandPokerList[5] = poker	
	else
		mySeatInfo.inHandPokerList = {}
		--填充手牌信息
		for i=1,#pokers do
			local poker = {}
			poker.colour = pokers[i].colour
			poker.number = pokers[i].number
			table.insert(mySeatInfo.inHandPokerList, poker)			
		end
	end
    
	if(#pokers == 4)then
		local poker = {}
		poker.colour = "S"
        poker.number = "A"
		table.insert(mySeatInfo.inHandPokerList, poker)
		self:showMaskPoker(true, false)
	else		
		self:showMaskPoker(true, true)
		self:showDragPokerGuideAnim(true)
	end

    --给其他玩家手牌填充假的数据
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	local tmpSeatList = {}
	for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
		if(seatInfo.isSeated and seatInfo.isReady)then
			table.insert(tmpSeatList, seatInfo)
			if(seatInfo ~= mySeatInfo)then      
				if(#pokers == 1)then
					local poker = {}
                    poker.colour = "S"
                    poker.number = "A"
				    table.insert(seatInfo.inHandPokerList, poker)
				else
					seatInfo.inHandPokerList = {}
			    	for j=1,#pokers do
                    	local poker = {}
                    	poker.colour = "S"
                    	poker.number = "A"
				    	table.insert(seatInfo.inHandPokerList, poker)
			   		end	
					if(#pokers == 4)then
						local poker = {}
						poker.colour = "S"
            			poker.number = "A"
						table.insert(seatInfo.inHandPokerList, poker)
					end
				end      
                				
            end	

			if(#pokers ~= 4) then
				if(seatInfo.betScore == 0)then
					seatInfo.betScore = self:getDefaultBetScore()
				end
				
			end
			--显示玩家的手牌
			seatInfo.isBetting = false
		end
			
	end

	table.sort(tmpSeatList, function(t1, t2)
		return t1.seatIndex > t2.seatIndex
	end)
	self.is_playing_fapai = true
	local onFinishFaPai = function()
		if(#pokers == 4)then
			roomInfo.state = self.RoomState.waitSetBanker
		else
			roomInfo.state = self.RoomState.waitCuoPai
		end
		self:refreshMyTableViewState()
		if(roomInfo.state == self.RoomState.waitSetBanker)then
			--显示抢庄按钮
			self.tableView:showQiangZhuangBtns(true)
		end
		self.tableModule:subscibe_time_event(1, false, 0):OnComplete(function()
			self.is_playing_fapai = false
			if(self.on_finish_fapai_fun_list)then
				local fun_list = self.on_finish_fapai_fun_list
				self.on_finish_fapai_fun_list = nil
				for i = 1, #fun_list do
					fun_list[i]()
				end
			end
		end)
	end
	local count = #tmpSeatList
	local finishCount = 0
	for i = 1, #tmpSeatList do
		local seatInfo = tmpSeatList[i]
		self.tableModule:subscibe_time_event(self.fapai_seatDelayTime * (i - 1), false, 0):OnComplete(function()
			self.tableView:refreshSeat(seatInfo, seatInfo == mySeatInfo)
			local onFinish = function()
				if(seatInfo == mySeatInfo)then
					self.tableView:refreshSeatCardsSelect(mySeatInfo)
				end
				finishCount = finishCount + 1
				if(finishCount == count)then
					onFinishFaPai()
				end
			end

			if(#pokers == 4)then
				self:playFaPaiAnim(seatInfo, onFinish, #self:get_all_seated_ready_seats())
			else
				--self:playFaPaiLastPoker(seatInfo, onFinish)
			end
		end)
	end
	
	--隐藏tips
	self.tableView:showCenterTips(false)

	--隐藏下注按钮
	self:refreshMyTableViewState()
	self.tableView:showSelectNiuPanel(false)
    --刷新选牛数字
	self.tableView:refreshSelectedNiuNumbers()  
end

--算牛响应
function TableDouNiuLogic_ScrambleBanker:on_table_compute_rsp(data)
	TableDouNiuLogic.on_table_compute_rsp(self, data)
end

--算牛通知
function TableDouNiuLogic_ScrambleBanker:on_table_compute_notify(data)
	TableDouNiuLogic.on_table_compute_notify(self, data)
end

--单局结算通知
function TableDouNiuLogic_ScrambleBanker:on_table_settleAccounts_Notify(data)
	TableDouNiuLogic.on_table_settleAccounts_Notify(self, data)
	self:showDragPokerGuideAnim(false)
	self:showMaskPoker(false, false)
end

--最终结算通知
function TableDouNiuLogic_ScrambleBanker:on_table_lastsettleAccounts_Notify(data)
	TableDouNiuLogic.on_table_lastsettleAccounts_Notify(self, data)
end

--更新到期时间通知
function TableDouNiuLogic_ScrambleBanker:on_table_expire_time_notify(data)
	TableDouNiuLogic.on_table_expire_time_notify(self, data)
end

--设置庄家通知
function TableDouNiuLogic_ScrambleBanker:on_table_setbanker_notify(data)

	--隐藏抢庄按钮
	self.tableView:showQiangZhuangBtns(false)

	-- 标识已开始当前局
	local roomInfo = self.modelData.curTableData.roomInfo
	
	local mySeatInfo = roomInfo.mySeatInfo
	local seatInfoList = {}
	for i=1,#data.scramble_banker_list do
		local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.scramble_banker_list[i], roomInfo.seatInfoList)
		seatInfoList[i] = seatInfo
	end

	if(#seatInfoList == 0)then
		for i = 1, #roomInfo.seatInfoList do
			local seatInfo = roomInfo.seatInfoList[i]
			if(seatInfo.isReady)then
				table.insert(seatInfoList, seatInfo)
			end
		end
	end

	for i=1,#seatInfoList do
		seatInfoList[i].isBanker = false
		self.tableView:refreshSeatInfo(seatInfoList[i])
		seatInfoList[i].isBetting = true
	end

	local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, roomInfo.seatInfoList)
	seatInfo.isBanker = true
	seatInfo.isBetting = false

	local onFinishRandomBanker = function()
		local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
		self.tableHelper:playSetTargetSeatAsBanker(seatHolder, function()
			self.tableView:refreshSeatInfo(seatInfo)	

			for i=1,#roomInfo.seatInfoList do
				local seatInfo = roomInfo.seatInfoList[i]
				self.tableView:refreshSeatState(seatInfo)
				self.tableView:refreshSeatInfo(seatInfo)
				self.tableView:showQiangZhuangBeiShuBubble(seatInfo, false)
				self.tableView:showQiangZhuangBeiShuTag(seatInfo, seatInfo.isBanker, seatInfo.qiangZhuangBeiShu)
			end

			--隐藏抢庄标签
			self:hideAllSeatScrambleBankerTag()
			self:refreshMyTableViewState()
			self.tableView:showBetBtns((not mySeatInfo.isBanker) and mySeatInfo.isReady, roomInfo.ruleTable.isBigBet, roomInfo.ruleTable.bankerType == 2)
		end)
		roomInfo.state = self.RoomState.waitBet

		

	end

	if(#seatInfoList == 1)then
		onFinishRandomBanker()
	else
		self.tableView:showBetBtns(false)
		self.tableView:showCenterTips(false)		
		self:showSeatsRandomBankerEffect(seatInfoList, seatInfo, function()
			self:showSeatsRandomEffect(seatInfoList, false)
			self:showSeatRandomEffect(seatInfo, true)
			self.tableView:showQiangZhuangBeiShuBubble(seatInfo, false)
			onFinishRandomBanker()
		end)
	end
end

function TableDouNiuLogic_ScrambleBanker:update()
	TableDouNiuLogic.update(self)

	if(not self.modelData.curTableData or (not self.modelData.curTableData.roomInfo))then
		return
	end
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(roomInfo.state == self.RoomState.waitCuoPai)then
		self.tableView:refreshClock(mySeatInfo, true, roomInfo.expireTimes[self.RoomState.waitResult], self:getServerNowTime())
	end
end


function TableDouNiuLogic_ScrambleBanker:onClickPoker(obj)
	if(self.modelData.curTableData.roomInfo.mySeatInfo.isDoneComputeNiu or (not self.modelData.curTableData.roomInfo.roundStarted))then		
		return
	end

	if(self.modelData.curTableData.roomInfo.state ~= self.RoomState.waitResult)then
		return
	end

	local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
	local selectedPokersArray = self.tableView.seatHolderArray[1].selectedPokersArray or {}
	for i=1,#cardsArray do
		--print("obj="..obj.name .. "&root="..cardsArray[i].cardRoot.name)
		if(obj == cardsArray[i].cardRoot) then					
			if(cardsArray[i].selected) then
				
				cardsArray[i].selected = false					
				for j=1,#selectedPokersArray do
					if(selectedPokersArray[j] == cardsArray[i].poker) then
						table.remove(selectedPokersArray, j)
						break
					end
				end		
				self.tableView:refreshCardSelect(cardsArray[i])
			elseif(#selectedPokersArray ~= 3) then				
				cardsArray[i].selected = true				
				table.insert(selectedPokersArray, cardsArray[i].poker)	
				self.tableView:refreshCardSelect(cardsArray[i])							
			else
				return
			end					
		end
	end

	self.tableView.seatHolderArray[1].selectedPokersArray = selectedPokersArray	
	self.tableView:refreshSelectedNiuNumbers()
end


function TableDouNiuLogic_ScrambleBanker:playFaPaiLastPoker(seatInfo, onFinish, lastCount, seatCount)
	local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
	local delay = 0.1 * seatCount
	local duration = 0.2
	local cardHolderList = seatHolder.inhandCardsArray
	local count = #cardHolderList
	for i = 1, lastCount do
		local index = count - lastCount + i
		if(seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo)then
			local cardHolder = cardHolderList[index]
			ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.x, false)
			ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.y, false)
			local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
			cardHolder.cardRoot.transform.localScale = pokerHeapCardScale

			self.tableModule:subscibe_time_event((i - 1) * delay, false, 0):OnComplete(function()
				self.tableHelper:playFaPaiSound()
			end)
			self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration, (i - 1) * delay, function()
				ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.x, true)
				ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.y, true)
			end)
			self.tableHelper:playCardScaleAnim(cardHolder, cardHolder.cardLocalScale.x, duration, (i - 1) *  delay, nil)
			self.tableHelper:playCardTurnAnim(cardHolder, true, duration, (i - 1) * delay, function()
				if(onFinish)then
					onFinish()
				end
			end)

		else
			local endIndex = count - lastCount + i
			local index = i
			if(seatHolder.isInRight)then
				endIndex = i
				index = lastCount - i + 1
			end
			local cardHolder = cardHolderList[endIndex]

			ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.x, false)
			ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.y, false)
			local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
			cardHolder.cardRoot.transform.localScale = pokerHeapCardScale
			self.tableModule:subscibe_time_event((index - 1) * delay, false, 0):OnComplete(function()
				self.tableHelper:playFaPaiSound()
			end)
			self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration, (index - 1) * delay, function()
				if(onFinish)then
					onFinish()
				end
			end)
		end
	end
end



function TableDouNiuLogic_ScrambleBanker:hideAllSeatScrambleBankerTag()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		seatInfoList[i].scramble_banker_state = 0
		self.tableView:showQiangZhuangTag(seatInfoList[i], false)
	end
end

function TableDouNiuLogic_ScrambleBanker:on_dragMaskPoker(obj, arg)
	local position = self.uiCamera:ScreenToWorldPoint(arg.position)
	self:showDragPokerGuideAnim(false)
	local maskPokerPos = self.maskPokerPosOffset + position
	ModuleCache.TransformUtil.SetX(obj.transform, maskPokerPos.x, false)
	ModuleCache.TransformUtil.SetY(obj.transform, maskPokerPos.y, false)
end

function TableDouNiuLogic_ScrambleBanker:on_press_downMaskPoker(obj, arg)
	local position = self.uiCamera:ScreenToWorldPoint(arg.position)
	self.maskPokerPosOffset = obj.transform.position - position
end

function TableDouNiuLogic_ScrambleBanker:on_press_upMaskPoker(obj, arg)
	local roomInfo = self.modelData.curTableData.roomInfo
	local position = obj.transform.localPosition
	if((position.x) > 43 or (position.y < -34) or (position.x < -116) or (position.y > 163))then
		roomInfo.state = self.RoomState.waitResult
		self:fadeOutMaskPoker(obj)
		--隐藏下注按钮
		self:refreshMyTableViewState() 	
    	--刷新选牛数字
		self.tableView:refreshSelectedNiuNumbers() 
	else
		local sequence = self.tableModule:create_sequence()
    	sequence:Append(obj.transform:DOLocalMove(ModuleCache.CustomerUtil.ConvertVector3(0,0,0), 0.2, false))    
    	sequence:OnComplete(function()
        	    
    	end)
	end

end

function TableDouNiuLogic_ScrambleBanker:fadeOutMaskPoker(goMaskPoker)
	self:showMaskPoker(false, false)
end

function TableDouNiuLogic_ScrambleBanker:showDragPokerGuideAnim(show)
	ModuleCache.ComponentUtil.SafeSetActive(self.tableView.goFingerRoot, show)
end

function TableDouNiuLogic_ScrambleBanker:showMaskPoker(show, canDrag)
	ModuleCache.ComponentUtil.SafeSetActive(self.tableView.buttonMaskPoker.gameObject, show)
	self.tableView.buttonMaskPoker.enabled = canDrag
	if(show)then
		ModuleCache.TransformUtil.SetX(self.tableView.buttonMaskPoker.transform, 0, true)
		ModuleCache.TransformUtil.SetY(self.tableView.buttonMaskPoker.transform, 0, true)
	end
end

function TableDouNiuLogic_ScrambleBanker:onDoubleClickHasNiuBtn()
	TableDouNiuLogic.onDoubleClickHasNiuBtn(self)
	local selectedPokersArray = self.tableView.seatHolderArray[1].selectedPokersArray or {}	
	local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(selectedPokersArray)
	if(hasNiu)then
		self:showMaskPoker(false, false)
		self:showDragPokerGuideAnim(false)
	end
end

function TableDouNiuLogic_ScrambleBanker:onClickNoNiuBtn()
	TableDouNiuLogic.onClickNoNiuBtn(self)
	local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerList)
	if(not hasNiu)then
		self:showMaskPoker(false, false)
		self:showDragPokerGuideAnim(false)
	end
end

function TableDouNiuLogic_ScrambleBanker:onClickHasNiuBtn()
	TableDouNiuLogic.onClickHasNiuBtn(self)
	local selectedPokersArray = self.tableView.seatHolderArray[1].selectedPokersArray or {}	
	local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(selectedPokersArray)
	if(hasNiu)then
		self:showMaskPoker(false, false)
		self:showDragPokerGuideAnim(false)
	end
end

function TableDouNiuLogic_ScrambleBanker:showSetBankerStateTips()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(mySeatInfo.qiangZhuangBeiShu == 0)then
		self.tableView:showCenterTips(true, self.const_select_banker_tips)
	else
		self.tableView:showCenterTips(true, self.const_wait_other_select_banker_tips)
	end
end

return TableDouNiuLogic_ScrambleBanker