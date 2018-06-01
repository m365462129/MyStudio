local BranchPackageName = AppData.BranchRunfastName
local class = require("lib.middleclass")
---@class TableRunfastLogic
local TableRunfastLogic = class('TableRunfastLogic')
local CardSet = require(string.format("package/%s/module/tablerunfast/gamelogic_set",BranchPackageName))
local CardCommon = require(string.format("package/%s/module/tablerunfast/gamelogic_common",BranchPackageName))
local CardPattern = require(string.format("package/%s/module/tablerunfast/gamelogic_pattern",BranchPackageName))
local UIHelper = require(string.format("package/%s/module/uihelper/uihelper",BranchPackageName))
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

local CSmartTimer = ModuleCache.SmartTimer.instance
local GameSDKInterface = ModuleCache.GameSDKInterface

local table = table

local RoomState = {}
RoomState.waitReady = 0			--等待玩家准备状态
RoomState.waitSetBanker = 1		--等待定庄状态
RoomState.waitBet = 2			--等待下注状态
RoomState.waitResult = 3		--等待结算状态

function TableRunfastLogic:initialize(module)
	self.TableRunfastModule = module    
    self.modelData = module.modelData
    self.TableRunfastView = self.TableRunfastModule.TableRunfastView
    self.TableRunfastModel = self.TableRunfastModule.TableRunfastModel
    self.TableRunfastHelper = self.TableRunfastModule.TableRunfastHelper

	self.timerMap = {}
    self:resetSeatHolderArray(self.TableRunfastHelper.seatMaxCount)
	self.RoomState = RoomState
end


function TableRunfastLogic:on_show()
end


function TableRunfastLogic:on_hide()
end

------每贞更新
function TableRunfastLogic:update()
    if(not self.modelData.curTableData or (not self.modelData.curTableData.roomInfo))then
		return
	end

	if((not self.lastEverySecond)  or (self.lastEverySecond + 1 < Time.realtimeSinceStartup)) then
		self.lastEverySecond = Time.realtimeSinceStartup
		self:UpdateEverySecond()
	end
end

------每秒更新
function TableRunfastLogic:UpdateEverySecond()
	--print("==每秒更新=")
end

function TableRunfastLogic:on_destroy()
    self.showResultViewSmartTimer = nil
	for k,v in pairs(self.timerMap) do
		SmartTimer.Kill(v.id)
	end
end


function TableRunfastLogic:add_to_timermap(timer)
	self.timerMap[tostring(timer.id)] = timer
end


function TableRunfastLogic:remove_from_timermap(timer)
	self.timerMap[tostring(timer.id)] = nil
end

------进入房间回包
function TableRunfastLogic:on_table_enter_rsp(data)
end

------开始回包
function TableRunfastLogic:on_table_start_rsp(data) 
    self.TableRunfastView:showStartBtn(false)
end

------开始广播通知
function TableRunfastLogic:on_table_start_notify(data)
    -- 标识已开始当前局
    --local roomInfo = self.modelData.curTableData.roomInfo
    --roomInfo.roundStarted = true
    --self.TableRunfastModule:clean_share_clip_board()
end

------牌桌中有玩家进入房间的通知
function TableRunfastLogic:on_table_enter_notify(data)
    local posInfo = data.pos_info
	local seatInfo = self.TableRunfastHelper:getSeatInfoByRemoteSeatIndex(posInfo.pos_index, self.modelData.curTableData.roomInfo.seatInfoList)
	seatInfo.playerId = tostring(posInfo.player_id)
	seatInfo.isSeated = self:getBoolState(posInfo.player_id)--判断座位上是否有玩家
	seatInfo.isReady = self:getBoolState(posInfo.is_ready)--是否已准备
	if(self:getBoolState(posInfo.player_id)) then
	    --判断是否玩家自己，单独记录自己的座位
		if(seatInfo.playerId == self.modelData.curTablePlayerId) then
			self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo
			seatInfo.isOffline = false
		end
	end

	self.TableRunfastView:refreshSeat(seatInfo, seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo)
	self.TableRunfastModule:refresh_share_clip_board()
end

------同步消息包:每个玩家的信息
function TableRunfastLogic:on_table_synchronize_notify(data)
    self:initTableSeatData(data)
	self.TableRunfastView:setRoomInfo(self.modelData.curTableData.roomInfo)--刷新房间信息显示
	--刷新每个座位状态的显示
	local seatList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatList do
		seatList[i].inHandPokerList = seatList[i].inHandPokerList or {}			
		self.TableRunfastView:refreshSeat(seatList[i], seatList[i] == self.modelData.curTableData.roomInfo.mySeatInfo)
	end	


	self:refreshMyTableViewState()--刷新玩家自己桌面
end 

--上一局的结算通知
function TableRunfastLogic:on_table_ago_settle_accounts_notify(data)

end

------设置庄家通知
function TableRunfastLogic:on_table_setbanker_notify(data)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		seatInfoList[i].isBanker = false
		self.TableRunfastView:refreshSeatInfo(seatInfoList[i])
	end

	local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(data.player_id, seatInfoList)
	seatInfo.isBanker = true
	seatInfo.isBetting = false
	local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]

    self:refreshMyTableViewState()
	self.TableRunfastView:showContinueBtn(false)
end


------重置座位  seatCount
function TableRunfastLogic:resetSeatHolderArray(RealPlayerCount)
	local newSeatHolderArray = {}
    local seatHolderArray = self.TableRunfastView.srcSeatHolderArray
	local maxPlayerCount = RealPlayerCount
	if(maxPlayerCount == 4) then
		newSeatHolderArray[1] = seatHolderArray[1]
		newSeatHolderArray[2] = seatHolderArray[2]
		newSeatHolderArray[3] = seatHolderArray[4]
		newSeatHolderArray[4] = seatHolderArray[3]
	else
		newSeatHolderArray = seatHolderArray
	end

	for i,v in ipairs(seatHolderArray) do
		ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, false)   
	end

	for i,v in ipairs(newSeatHolderArray) do
		ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, true)   
	end

	self.TableRunfastView.seatHolderArray = newSeatHolderArray

    local ruleTable = nil
    if(TableManager.RunfastRuleJsonString ~= nil and TableManager.RunfastRuleJsonString ~= "") then
		ruleTable = ModuleCache.Json.decode(TableManager.RunfastRuleJsonString)
	end
	if(ruleTable ~= nil and ruleTable.playerCount < 4) then
		local seatHolder = self.TableRunfastView.seatHolderArray[4]
		if(seatHolder) then
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, false)  
		end
    end
end



function TableRunfastLogic:initTableSeatData(data)
end


------获取布尔值
function TableRunfastLogic:getBoolState(value)
	if(value) then
		return value ~= 0 and value ~= "0"
	end
	return false
end

------刷新TableRunfastView的状态
function TableRunfastLogic:refreshMyTableViewState()
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo

	if(self.TableRunfastView:isJinBiChang()) then
		if(mySeatInfo.isReady) then
			self.TableRunfastView:SetJinBiChangStateSwitcher(false)
		else
			self.TableRunfastView:SetJinBiChangStateSwitcher("Center")
		end
		return
	end

	--是否要显示准备按钮
	self.TableRunfastView:EnterTableShowBtn(roomInfo.curRoundNum <= 0,mySeatInfo.isCreator)
	self:AutoReady()


	--是否要显示开始按钮	
	local isAllPlayerReady = self.TableRunfastHelper:checkIsAllReady(roomInfo.seatInfoList)
	local isShowStartBtn = (not roomInfo.roundStarted) and isAllPlayerReady and mySeatInfo.isCreator
	self.TableRunfastView:showStartBtn(isShowStartBtn)
end


function TableRunfastLogic:resetRoundState()
    -- local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    -- for i=1,#seatInfoList do
    --     local seatInfo = seatInfoList[i]
	-- 	seatInfo.curRound = nil
	-- 	seatInfo.isReady = false		
	-- 	seatInfo.isBanker = false				
	-- 	seatInfo.betScore = 0
	-- 	seatInfo.isBetting = false				
	-- 	seatInfo.inHandPokerList = {}
	-- end
	-- self.modelData.curTableData.roomInfo.roundStarted = false
end


------刷新重置状态
function TableRunfastLogic:refreshResetState()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]	
		--self.TableRunfastView:showSeatWinScoreCurRound(seatInfo, false, nil)
		self.TableRunfastView:refreshSeat(seatInfo, false)
	end

	self:refreshMyTableViewState()  
	self.TableRunfastView:showContinueBtn(false)
end

------到期时间通知
function TableRunfastLogic:on_table_expire_time_notify(data)
	local expires = data.expires
	for i=1,#expires do
		local expireInfo = expires[i]
		if(expireInfo.state == 0)then	--房间等待准备状态			
			self.modelData.curTableData.roomInfo.expireTimes[0] = expireInfo.expire
		elseif(expireInfo.state == 1)then	--定庄状态			
			self.modelData.curTableData.roomInfo.expireTimes[1] = expireInfo.expire
		elseif(expireInfo.state == 2)then	--下注状态			
			self.modelData.curTableData.roomInfo.expireTimes[2] = expireInfo.expire			
		elseif(expireInfo.state == 3)then	--等待结算状态			
			self.modelData.curTableData.roomInfo.expireTimes[3] = expireInfo.expire			
		else
		end
	end
end

------点击准备的回包
function TableRunfastLogic:on_table_ready_rsp(data)
	print("====on_table_ready_rsp")

	if self.modelData.curTableData then
		if (data.err_no == "0")then
			local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
			mySeatInfo.isReady = true
			self:RefreshReadyBtn()
			self.TableRunfastView:SetJinBiChangStateSwitcher(false)
		end
		self:ResetPokerSlot()
		self:ResetFirstThrowPoker()
		self:ResetClockTimeDown()
	end
end

------准备的广播通知
function TableRunfastLogic:on_table_ready_notify(data)
	print("====on_table_ready_notify")
	if self.modelData.curTableData then
		local posInfo = data.pos_info

		local player_id = posInfo.player_id
		local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(player_id, self.modelData.curTableData.roomInfo.seatInfoList)
		if(seatInfo == nil) then
			return
		end
		seatInfo.isReady = (posInfo.is_ready == 1)
		self:RefreshReadyBtn()
		self:ResetPokerSlot()
		self:ResetFirstThrowPoker()
		self:ResetClockTimeDown()
	end

end

------点击开始
function TableRunfastLogic:onclick_start_btn(obj)
    if(self.TableRunfastHelper:getSeatedSeatCount(self.modelData.curTableData.roomInfo.seatInfoList) <= 1) then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("至少需要两位玩家")	
		return
	end
	self.TableRunfastModel:request_start()
end


function TableRunfastLogic:onclick_ready_btn(obj)
    self.TableRunfastModel:request_ready()
end

--点击继续按钮
function TableRunfastLogic:onclick_continue_btn(obj)
end

------发牌的通知
function TableRunfastLogic:on_table_fapai_notify(data)

end

--单局结算通知
function TableRunfastLogic:on_table_settleAccounts_Notify(data)    

end


--房间结算通知
function TableRunfastLogic:on_table_lastsettleAccounts_Notify(data)
end


------播放发牌动画
function TableRunfastLogic:playFaPaiAnim(seatInfo, onFinish)
	local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
	local delay = 0.2
	local duration = 0.1
	local finishCount = 0
	local cardHolderList = seatHolder.inhandCardsArray
	local count = #cardHolderList
	if(seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo)then	
		
		for i=1,#cardHolderList do			
			local cardHolder = cardHolderList[i]
			
			ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.x, false)
    		ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.y, false)  
			local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
			cardHolder.cardRoot.transform.localScale = pokerHeapCardScale


			self.TableRunfastHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration, (i - 1) * delay, function()
				ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.x, true)
    			ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.y, true)
			end)	

			self.TableRunfastHelper:playCardScaleAnim(cardHolder, cardHolder.cardLocalScale.x, duration, (i - 1) * delay, nil)
									
			self.TableRunfastHelper:playCardTurnAnim(cardHolder, true, duration, (i - 1) * delay, function()
				finishCount = finishCount + 1
				if(finishCount == count)then
					if(onFinish)then
						onFinish()
					end
				end
			end)
		end
		
	else		
		local startIndex = 1
		local endIndex = #cardHolderList
		local step = 1
		if(seatHolder.isInRight)then
			startIndex = #cardHolderList
			endIndex = 1
			step = -1
		end	
		local index = 0
		for i=startIndex,endIndex, step do
			index = index + 1
			local cardHolder = cardHolderList[i]

			ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.x, false)
    		ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.y, false)  
			local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
			cardHolder.cardRoot.transform.localScale = pokerHeapCardScale

			self.TableRunfastHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration, (index - 1) * 0.1, function()
				finishCount = finishCount + 1
				if(finishCount == count)then
					if(onFinish)then
						onFinish()
					end
				end
			end)			
		end
	end
end

------获取服务器现在的时间
function TableRunfastLogic:getServerNowTime()
	return self.modelData.curTableData.roomInfo.timeOffset + os.time()
end

------对赌加倍的回应
function TableRunfastLogic:on_table_bet_rsp(data)
    --记录当前下注分
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.betScore = self.TableRunfastModule.selectedBetScore
	mySeatInfo.isBetting = false
	
	self:refreshMyTableViewState()  
	self.TableRunfastView:refreshSeat(self.modelData.curTableData.roomInfo.mySeatInfo, true)--刷新自己座位显示状态
end

------对赌加倍的广播通知
function  TableRunfastLogic:on_table_bet_notify(data)      
	local playerId = data.player_id
	local betScore = data.bet
	local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(tostring(playerId), self.modelData.curTableData.roomInfo.seatInfoList)
	seatInfo.betScore = betScore
	seatInfo.isBetting = false
	--刷新做为的下注分显示
	self.TableRunfastView:refreshSeat(seatInfo, seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo)
end

------重连:游戏的信息:发牌,断线重连,玩家进入
function TableRunfastLogic:on_table_gameinfo(data)
	if(data.game_loop_cnt > 0 and self.isDataInited and data.reconn_player_id and self.modelData.curTablePlayerId) then
		if(data.reconn_player_id == 0 or data.reconn_player_id == self.modelData.curTablePlayerId) then
			--print("===自己断线重连data.reconn_player_id=",data.reconn_player_id)
		else
			print("===别人断线重连data.reconn_player_id=",data.reconn_player_id)
			return
		end
	end

	self.TableRunfastView:SetNotAllowActionMaskLastPokerAutoState(false)
	self:AllowPlayerAction(true)
	self:initTableSeatDataMy(data)
	local roomInfo = self.modelData.curTableData.roomInfo
	if(roomInfo.curRoundNum == 0 and #roomInfo.seatInfoList ~= roomInfo.maxPlayerCount)then
		self.TableRunfastModule:refresh_share_clip_board()
	else
		self.TableRunfastModule:clean_share_clip_board()
	end
	roomInfo.JustReceived_gameinfo = true
	self.TableRunfastModule:subscibe_time_event(2, false, 0):OnComplete(function(t)
		roomInfo.JustReceived_gameinfo = false
	end)
	self.TableRunfastView:setRoomInfo(roomInfo)--刷新房间信息显示
	--刷新每个座位状态的显示
	local seatList = roomInfo.seatInfoList
	for i=1,#seatList do
		seatList[i].inHandPokerList = seatList[i].inHandPokerList or {}			
		self.TableRunfastView:refreshSeat(seatList[i], seatList[i] == roomInfo.mySeatInfo)
	end	
	self:refreshMyTableViewState()--刷新玩家自己桌面
	local isAllPlayerReady = self.TableRunfastHelper:checkIsAllReady(seatList)
	local IsHavePlayerOffline = self:CheckIsHavePlayerOffline()
	if(isAllPlayerReady) then
		if(roomInfo.mySeatInfo.isCreator) then
			if(data.cards == nil or #data.cards <=0) then
				print("====on_table_gameinfo.onclick_start_btn   return")
				if(IsHavePlayerOffline) then
					print("====有玩家离线,不发牌")
				else
					self:onclick_start_btn()
				end
				return
			end
		end
	else
		print("====有玩家没准备")
		self:RefreshReadyBtn()
		return
	end

	------这里游戏可以打牌了
	--隐藏上局别人打的牌
	self:ResetOtherThrowPoker()
	--隐藏OK图标
	self.TableRunfastView:HideOkIcon()
	--检查是否新的开局
	if(data.desk_player_id <= 0 and #data.desk_cards <= 0) then	
		--print("====新的开局")
		self.modelData.curTableData.roomInfo.isNewRound = true--新的开局
		self.preSoundName = nil
		self:ResetPokerSlot()
		self:ResetFirstThrowPoker()
		self:ResetClockTimeDown()
		self:CheckHeiTao3Fly()
		if(self.TableRunfastView:isJinBiChang() and not roomInfo.is_deal) then
			self.TableRunfastView:SetTipsServiceFee(roomInfo.feeNum)
			self:ResetAllSeatInfoRechargeState()
		end
	else
		self.modelData.curTableData.roomInfo.isNewRound = false
	end
	
	if(data.desk_player_id > 0 and #data.desk_cards > 0) then
		self:ResetClockTimeDown()
	end
	
    --发牌
	if(data.cards and #data.cards > 0) then
	    ModuleCache.ModuleManager.hide_module(BranchPackageName, "tablerule")
		self:OnlyTwoPlayerHandlerThirdSeatShow()
		self:MyCards(data)
		self.TableRunfastView:EnterTableAlreadyStartGameClearBtn()
		self:SetKickBtnShowState(false)
		roomInfo.accountWaitReady = false
		roomInfo.gamePhaseState = 2
	else
		self:RefreshReadyBtn()
	end

	self:initCurThorwPoker()--显示上局的出牌
	self.TableRunfastView:HideOthersBackPoker()
	self.TableRunfastView:RefreshRemainPokerInHand()
	self:TurnWhoThrowPokerEffect()--轮到谁出牌
	self:unSelectedAllPoker()
	self:CheckIntrust()
	self:OnlyTwoPlayerHandlerThirdSeatShow()

	self.TableRunfastView:PBUI2()
	self.TableRunfastView:CheckAnticheatUI()

	if(data.reconn_player_id and data.reconn_player_id > 0 and data.reconn_player_id == tonumber(self.modelData.curTablePlayerId)) then
		print("===自己断线重连data.reconn_player_id=",data.reconn_player_id)
		ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
	end
end

------当前这局的小结
function TableRunfastLogic:on_table_currentgameaccount(data)
	--print("===当前这局的小结")
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.gamePhaseState = 3
	self.modelData.curTableData.roomInfo.accountWaitReady = true
	self.TableRunfastView:SetNotAllowActionMaskLastPokerAutoState(false)
	self:AllowPlayerAction(true)
	roomInfo.isNewRoundAlreadyFaPai = false
	self.TableRunfastView:CheckAnticheatUI()
	self:HideAllPlayerNotAfford()
	self:ResetClockTimeDown()
	self:ResetSingle()
	self:ResetAllSeatInfoRechargeState()
	self.TableRunfastView:SetCancelIntrustState(false)
	self.preSoundName = ""
	roomInfo.curAccountData = data
	roomInfo.isJinBiChang = self.TableRunfastView:isJinBiChang()
	roomInfo.isGoldSettle = self.TableRunfastView:isGoldSettle()
	self.TableRunfastModule:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
		ModuleCache.ModuleManager.show_module(BranchPackageName, "currentgameaccount",self.modelData)
		--清理桌面
		self:ResetOtherThrowPoker()
		self:ResetPokerSlot()
		self:ResetFirstThrowPoker()
		self.TableRunfastView:SetState_RecordPokerShowRoot(false)
		self.TableRunfastView:SetState_RecordPokerTimeRoot(false)
		if(not roomInfo.JustReceived_gameinfo) then
			self:ResetAllPlayerReadyState()
		end
		if(self.TableRunfastView:isJinBiChang()) then
			self.TableRunfastView:SetJinBiChangStateSwitcher("Center")
		else
			self:ResetClockTimeDown()
		end

		--刷新积分
		if(data.players ~= nil and #data.players > 0) then
			for i=1,#data.players do
				local player_id = data.players[i].player_id
				local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(player_id, self.modelData.curTableData.roomInfo.seatInfoList)
				if(seatInfo ~= nil) then
					seatInfo.score = data.players[i].score
					self.TableRunfastView:RefreshSeatInfoCurrency(seatInfo)
				end
			end
		end

	end)
end

function TableRunfastLogic:on_table_discardreply(data)
	self.IsWaitDiscardreply = nil
	if(self.WaitDiscardreplyEventId) then
		--print("====已经回应,杀死等待函数")
		CSmartTimer:Kill(self.WaitDiscardreplyEventId)
		self.WaitDiscardreplyEventId = nil
	end

	self.myfn = nil

	if(data.cards ~= nil and #data.cards >= 0)  then
	   self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable = data.cards
	   self:refreshMyHandPokerListBySeverData(self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable)
	end

	if(data.is_ok == false) then
		-- 第一局首发必须包含黑桃3
		-- 牌型不匹配
		-- 牌点太小了
		-- 对方爆单，请出最大牌
		-- 不可以出手上没有的牌
		-- 最少要出一张
		-- 出牌数量大于最大手牌数量
		-- 有大必管，逃避不是办法
		-- 首发必须出牌
		if(string.find(data.desc,"还没轮到你出牌") ~= nil
		or string.find(data.desc,"重复点击无效") ~= nil) then
			return
		else
			-- if(string.find(data.desc,"对方爆单") ~= nil) then
			-- 	self:ResetFirstThrowPoker()
			-- end
			self.TableRunfastModule:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
				TableManagerPoker:heartbeat_timeout_reconnect_game_server()
    		end)
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.desc)
	   	end
	end
end

------轮到谁出牌的效果
function TableRunfastLogic:TurnWhoThrowPokerEffect()
	local next_player_id = tonumber(self.modelData.curTableData.roomInfo.next_player_id)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	--闪烁效果
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		local seatInfoPlayerId = tonumber(seatInfo.playerId)
		local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
		ModuleCache.ComponentUtil.SafeSetActive(seatHolder.HeadSelected.gameObject, (seatInfoPlayerId == next_player_id))
	end

	--闹钟效果
	local next_seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(next_player_id,seatInfoList)
	if(next_seatInfo) then
		if(self.TableRunfastView:isJinBiChang() or self.TableRunfastView.isPlayBacking) then

		else
			local locTime = 15
			if(self.IsWaitOnClickNotAfford and self.NotAffordWaitTime > 2) then
				locTime = self.NotAffordWaitTime
			end
			self:StartClockTimeDown(next_seatInfo,locTime)
		end
	end
end

function TableRunfastLogic:ShowClock2(seatHolder,boolShow,localSeatIndex,seatInfoPlayerId)	
	if(self.TableRunfastView.isPlayBacking) then
		boolShow = false
	end
	seatHolder.clockHolder.textClockTime = 15
	ModuleCache.ComponentUtil.SafeSetActive(seatHolder.clockHolder.goClock.gameObject, boolShow)
	if(boolShow) then
		self.modelData.curTableData.curTimeDownLocalSeatIndex = localSeatIndex
		--print("=====self.NotAffordWaitTime="..tostring(self.NotAffordWaitTime))
		--print("=====self.IsWaitOnClickNotAfford="..tostring(self.IsWaitOnClickNotAfford))
		if(self.IsWaitOnClickNotAfford and self.NotAffordWaitTime > 2) then
			seatHolder.clockHolder.textClockTime = self.NotAffordWaitTime
		end
	end
	seatHolder.clockHolder.textClock.text = tostring(seatHolder.clockHolder.textClockTime)
end


function TableRunfastLogic:ResetClockTimeDown()
	self.modelData.curTableData.curTimeDownLocalSeatIndex = nil
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
		seatHolder.clockHolder.textClockTime = 15
		ModuleCache.ComponentUtil.SafeSetActive(seatHolder.clockHolder.goClock.gameObject,false)
	end
end

------收到出牌信息
function TableRunfastLogic:on_table_discardnotify(data)
	self:SetAllowAutoThrowPokerState(false,3)
	self.myfn = nil
	self.modelData.curTableData.roomInfo.discard_serial_no = data.discard_serial_no
	self.modelData.curTableData.roomInfo.next_player_id = data.next_player_id
	self.modelData.curTableData.roomInfo.curThorwCardPlayerId = data.player_id
	self.modelData.curTableData.roomInfo.next_player_discard_bomb = data.next_player_discard_bomb
	if(not data.is_passed) then
		self.modelData.curTableData.roomInfo.lastThrowPokerPlayerId = data.player_id
	end
	self.modelData.curTableData.roomInfo.black3_player = data.black3_player
	local next_player_id = tonumber(self.modelData.curTableData.roomInfo.next_player_id)
	local myId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
	local currThrowId = tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)
	
	self:HideNotAffordByPlayerId(next_player_id)

	if(true) then
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		for i=1,#seatInfoList  do
			local seatInfo = seatInfoList[i]
			local seatInfoPlayerId = tonumber(seatInfo.playerId)
			if(seatInfoPlayerId == currThrowId and currThrowId ~= myId) then
			elseif(seatInfoPlayerId == next_player_id) then
			    --print("===seatInfo.localSeatIndex="..seatInfo.localSeatIndex)
				self:HideOtherThrowCards(seatInfo)
			end
		end
	end 

	if(data.is_passed) then
		if(currThrowId == myId) then
			--print("====自己过牌")
			self:unSelectedAllPoker()
		else
			--print("====别人过牌")
			--self:HideOtherThrowCards(seatInfo)
		end
		self:NotAffordEffect()
	else
	   	if(currThrowId == myId) then
			--print("====自己出牌:把牌扔出去")
	   		self.modelData.curTableData.roomInfo.mySeatInfo.rest_card_cnt = data.rest_card_cnt
			self.modelData.curTableData.roomInfo.mySeatInfo.is_single = (data.warning_flag == 1)

		    if(self.TableRunfastView:isJinBiChang()) then
			    self:ResetJinBiChangTimeDown(true)
		    end
		    if(self:IsJinBiChangAndIntrust() and data.cards and #data.cards > 0
		    or self.IsJustCancelIntrust) then
			    local numList = self:PokerListSort(data.cards)
			    self:FirstThrowPoker(numList)
			    self:throwPokerType(data.cards,true)
			    self.IsJustCancelIntrust = false
		    end
		else
		    --print("====别人出牌:记录别人这次出的牌")
			if(data.cards ~=nil and #data.cards >= 0) then
				self.modelData.curTableData.roomInfo.curPokerTable = {}
				self.TableRunfastHelper:NumTableInsertToNewTable(self.modelData.curTableData.roomInfo.curPokerTable,data.cards)

				--别人显示牌
	    		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	    		for i=1,#seatInfoList do
					local seatInfo = seatInfoList[i]
					local seatInfoPlayerId = tonumber(seatInfo.playerId)
					if(seatInfoPlayerId == currThrowId and currThrowId ~= myId) then
		    			seatInfo.rest_card_cnt = data.rest_card_cnt
						seatInfo.is_single = (data.warning_flag == 1)
						--print("===别人出牌显示seatInfoPlayerId="..seatInfoPlayerId.." 剩余牌数="..tostring(data.rest_card_cnt))
						self:otherThrowCards(seatInfo,data.cards)
						self:throwPokerType(data.cards)
						self.TableRunfastView:SetRemainPokerInHand(seatInfo)
					elseif(seatInfoPlayerId == next_player_id) then
			    		self:HideOtherThrowCards(seatInfo)
					end
				end
			end
	    end
	end
	
	
	local curRuleTable = self.modelData.curTableData.roomInfo.createRoomRule
	local nextPlayerIsMy = self:nextPlayerIsMy()
	local isCanAfford = true
	local fn = nil
	local intJiZhongChuPaiFangShi = nil 
	local boolZhiJieChuPai = false--是否可以直接出牌
	local isLastHintPoker = false --是否是最后一手牌
	--如果下一个是我出牌隐藏我已经出的牌,检查是否要的起,如果要不起直接过,不需要用户点击要不起
	if(nextPlayerIsMy) then
	    self:ResetFirstThrowPoker()
		--print("===是否首发:"..tostring(data.is_first_pattern))
		self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern = data.is_first_pattern
			local myHandPokerTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable--我手上的牌
			local otherThrowPokerTable = self.modelData.curTableData.roomInfo.curPokerTable--别人打的牌
			local set = CardSet.new(myHandPokerTable)
			local otherThrowPokerCP = nil
			if(data.is_first_pattern) then
				otherThrowPokerCP = nil
			else
				local locPlayId = self.modelData.curTableData.roomInfo.lastThrowPokerPlayerId or self.modelData.curTableData.roomInfo.curThorwCardPlayerId
				otherThrowPokerCP = CardPattern.new(otherThrowPokerTable,#otherThrowPokerTable,self:Is_black3_player(nil,tonumber(locPlayId)))
				if(otherThrowPokerCP == nil) then
					print("====别人打的牌不符合规则")
				end
			end

			--提示接口
			local locIsMaxPoker = self:IsMustThrowMaxPoker()
			fn,intJiZhongChuPaiFangShi,boolZhiJieChuPai = set:hintIterator(otherThrowPokerCP,nil,locIsMaxPoker,self:Is_black3_player())
			
			--接牌时检查是否要的起
			if(data.is_first_pattern) then
				--print("首发,那么就是要的起")
				isCanAfford = true
			else
				if(fn == nil) then
					isCanAfford = false
					--print("自动检查要不起fn == nil")
					self:WaitNotAffordAndAction()
				else
					--print("自动检查要不起fn ~= nil")
					isCanAfford = true
					if(intJiZhongChuPaiFangShi == 1) then --只有一种出牌方式
						local pt = fn()
						local onlyOnePokerTable = pt.cards
						if(self:IsJinBiChangAndIntrust()) then
						else
							self:UpPoker(onlyOnePokerTable)
						end
					end 
				end
			end

			--最后一手自动出牌
			if(fn ~= nil and boolZhiJieChuPai == true) then
				local pt = fn()
				local lastThrowPokerTable = pt.cards --最后一手的牌
				if(lastThrowPokerTable ~= nil and #lastThrowPokerTable > 0) then
					--print("====最后一手强制自动出牌")
					self:LastForceThrowPoker(lastThrowPokerTable)
				end
			end
	end
	--如果下一个是我并且要的起,显示操作按钮
	--下一个出牌的是我并且要的起牌并且不是安徽玩法
	local boolShowDoing = true
	if(nextPlayerIsMy) then
		if(self.TableRunfastView.isPlayBacking) then
			boolShowDoing = false
		elseif(curRuleTable.allow_pass) then
			boolShowDoing = true
		else
			boolShowDoing = true--isCanAfford
		end
	else
		boolShowDoing = false
	end

	self:SetDoingState(boolShowDoing)
	self.TableRunfastView:RefreshRemainPokerInHand()
	self:TurnWhoThrowPokerEffect()
	self:CheckZhaDanFlyScore(data)
	if(data.is_first_pattern) then
		self:HideAllPlayerNotAfford()
	end
end

function TableRunfastLogic:HideAllPlayerNotAfford()
	self.TableRunfastModule:subscibe_time_event(1.2, false, 0):OnComplete(function(t)
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		for i=1,#seatInfoList  do
			local seatInfo = seatInfoList[i]
			local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
			if(seatHolder and seatHolder.NotAffordEffectRoot ) then
				ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotAffordEffectRoot.gameObject, false)
			end
		end
    end)
end

function TableRunfastLogic:HideNotAffordByPlayerId(_PlayerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList  do
		local seatInfo = seatInfoList[i]
		if(tonumber(_PlayerId) == tonumber(seatInfo.playerId)) then
			local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
			if(seatHolder and seatHolder.NotAffordEffectRoot ) then
				ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotAffordEffectRoot.gameObject, false)
			end
		end
	end
end


function TableRunfastLogic:SoundNotAfford(boolMale)
	local resultvoiceName = ""
	local genderName = "male_"
	local soundName = "buyao"

	if(not boolMale) then
		genderName = "female_"
	end

	soundName = "buyao" .. tostring(math.random(1,2))
	if(self.preSoundName) then
		if(self.preSoundName == "buyao1") then
			soundName = "buyao2"
		elseif(self.preSoundName == "buyao2") then
			soundName = "buyao1"
		end
	end
	self.preSoundName = soundName

	resultvoiceName = genderName..soundName
	ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/table/" .. resultvoiceName .. ".bytes", resultvoiceName)
end

function TableRunfastLogic:SoundThrowPoker(boolMale,soundName)
	local resultvoiceName = ""
	local genderName = "male_"
	if(not boolMale) then
		genderName = "female_"
	end

	if(self.preSoundName ~= nil and self.preSoundName == soundName) then
		if(soundName == "shunzi" or soundName == "sandaier" or soundName == "liandui" or soundName == "feiji") then
			soundName = "dashang"..tostring(math.random(1,3))
		end
	end
	self.preSoundName = soundName

	resultvoiceName = genderName..soundName
	ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/table/" .. resultvoiceName .. ".bytes", resultvoiceName)
end

function TableRunfastLogic:throwPokerType(cardsNumTable,IsMySelf)
	local curThrowPlayId = tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)--出牌的人玩家Id
	if(IsMySelf) then
		curThrowPlayId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)--出牌的人玩家Id
	end
	local throwPokerLocalIndexId = self:getLocalSeatIndex(curThrowPlayId)--出牌的人本地坐标
	local is_black3_player = self:Is_black3_player(nil,tonumber(curThrowPlayId))
	local pt = CardPattern.new(cardsNumTable,#cardsNumTable,is_black3_player)--出牌的类型
	if(pt ~= nil) then
		local boolMale = self:GetPlayerIsMaleByPlayerId(curThrowPlayId)
		self:SoundThrowPoker(boolMale,pt.disp_type)--出牌的声音
		self:PlayThrowPokerEffect(throwPokerLocalIndexId,pt.disp_type)--出牌特效
	end
end

--回放的出牌类型
function TableRunfastLogic:PB_ThrowPokerType(seatInfo,throwPokerTable)
	local localSeatIndex = seatInfo.localSeatIndex
	local pt = CardPattern.new(throwPokerTable,#throwPokerTable,self:Is_black3_player())--出牌的类型
	if(pt ~= nil) then
		local boolMale = true--self:GetPlayerIsMaleByPlayerId(curThrowPlayId)
		self:SoundThrowPoker(boolMale,pt.disp_type)--出牌的声音
		--self:PlayThrowPokerEffect(localSeatIndex,pt.disp_type)--出牌特效
	end
end

------别人出牌显示:seatInfo谁出牌,cardsNumTable出了什么牌
function TableRunfastLogic:otherThrowCards(seatInfo,cardsNumTable)
	local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
	for i=1,#cardsNumTable do
		local pokerSlot = seatHolder.otherThrowPokerSlotTable[i]
		self:setCardInfo2(pokerSlot,cardsNumTable[i])
		self.TableRunfastHelper:PlayScaleAnim(pokerSlot.gameObject,0.5,1,0.2)
	end

	if(self.TableRunfastView.isPlayBacking) then
		self.TableRunfastModule:PB_RefreshInHandPokerForOthers(seatInfo,cardsNumTable)
	end
end


function TableRunfastLogic:ResetOtherThrowPoker()
	local myId = tostring(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList  do
		local seatInfo = seatInfoList[i]
		local seatInfoPlayerId = tostring(seatInfo.playerId)
		if(seatInfoPlayerId == myId) then
		else
			self:HideOtherThrowCards(seatInfo)
		end
	end
end

------隐藏别人出过的牌
function TableRunfastLogic:HideOtherThrowCards(seatInfo)
	local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
	local slotTable = seatHolder.otherThrowPokerSlotTable
	if(slotTable == nil) then
	    return
	end 

	for i=1,#slotTable do
		local pokerSlot = slotTable[i]
		if(pokerSlot ~= nil) then
		   ModuleCache.ComponentUtil.SafeSetActive(pokerSlot.gameObject, false)
		end
	end
end


function TableRunfastLogic:onClickPoker(obj,IsClickEnter)
	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--手上所有的牌
	local selectedPokersArray = self.TableRunfastView.seatHolderArray[1].selectedPokersArray or {}--已经选了的牌

	local isPickUpHint = false
	if(IsClickEnter and self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern and self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern == false) then
		isPickUpHint = #self:GetSelectedPokerList() == 0
	end

	for i=1,#cardsArray do
	    if(obj==cardsArray[i].cardRoot) then
			--已经扔出去,已经隐藏,灰暗的牌都不能点击
			if(cardsArray[i].isThrowed or cardsArray[i].isHide or cardsArray[i].isDarkness) then
			    return
			end

			if(cardsArray[i].selected) then
			    cardsArray[i].selected = false
				for j=1,#selectedPokersArray do
					if(selectedPokersArray[j] == cardsArray[i].poker) then
						table.remove(selectedPokersArray, j)
						break
					end
				end	
				self.TableRunfastView:refreshCardSelect(cardsArray[i])
			else
				cardsArray[i].selected = true				
				table.insert(selectedPokersArray, cardsArray[i].poker)	
				self.TableRunfastView:refreshCardSelect(cardsArray[i])
			end
		end
	end
	self.TableRunfastView.seatHolderArray[1].selectedPokersArray = selectedPokersArray	
	self:CheckPickUpClickHint(isPickUpHint)
	self:CheckSelectPokerRule()
end

function TableRunfastLogic:CheckPickUpClickHint(isPickUpHint)
	if(not isPickUpHint) then
		return
	end
	local selectedPokerList = self:GetSelectedPokerList() 
	if(#selectedPokerList ~= 1) then
		return
	end

	local myHandPokerNumTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable--我手上的牌
	local pokerNumTable = self.modelData.curTableData.roomInfo.curPokerTable--别人打的牌	
	local othersThrowPokerCP = CardPattern.new(pokerNumTable,#pokerNumTable,false)
	local set = CardSet.new(myHandPokerNumTable)
	local essential_card = selectedPokerList[1]
	print("=====essential_card",essential_card)
	local locfn = set:hintIterator(othersThrowPokerCP,essential_card,false,false)
	if(locfn ~= nil) then
		print("========可以接牌提示2=")
		local pt = locfn()
		if(pt == nil) then
			print("====pt == nil")
		elseif (pt.cards == nil) then
			print("====pt.cards == nil")
		else
			print("========可以接牌提示3=")
			print_table(pt.cards)
			local needUpPokerList = {}
			local oldPokerList = pt.cards
			for i=1,#oldPokerList do
				if(oldPokerList[i] ~= essential_card) then
					table.insert(needUpPokerList,oldPokerList[i])
				end
			end
			self:UpPoker(needUpPokerList)
			print_table(needUpPokerList)
		end
	end
	locfn = nil
end

function TableRunfastLogic:onDragPokerEffect(startIndex,endIndex)
	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--手上所有的牌
	for i=1,#cardsArray do
		if(i >= startIndex and i <= endIndex)then
			if (cardsArray[i].isThrowed or cardsArray[i].isHide) then
			else
				self.TableRunfastHelper:enableGradientColor(cardsArray[i],true)
			end
		else
			self.TableRunfastHelper:enableGradientColor(cardsArray[i],false)
		end
	end
end


function TableRunfastLogic:onDragPoker(startIndex,endIndex)
    local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--手上所有的牌
	local selectedPokersArray = self.TableRunfastView.seatHolderArray[1].selectedPokersArray or {}--已经选了的牌
	for i=startIndex,endIndex do
		if (cardsArray[i].isThrowed or cardsArray[i].isHide or cardsArray[i].isDarkness) then 
			--这样的牌不让拖
		else
		    if(cardsArray[i].selected) then
		        cardsArray[i].selected = false
			    for j=1,#selectedPokersArray do
					if(selectedPokersArray[j] == cardsArray[i].poker) then
						table.remove(selectedPokersArray, j)
						break
					end
			    end
			    self.TableRunfastView:refreshCardSelect(cardsArray[i])
            else
		         cardsArray[i].selected = true
			     table.insert(selectedPokersArray, cardsArray[i].poker)
			     self.TableRunfastView:refreshCardSelect(cardsArray[i])	
		    end
		end
	end
	self.TableRunfastView.seatHolderArray[1].selectedPokersArray = selectedPokersArray
	self:CheckSelectPokerRule()
end

------不选择牌
function TableRunfastLogic:unSelectedAllPoker()
	self.TableRunfastView.seatHolderArray[1].selectedPokersArray = {}
	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--牌槽
	for i=1,#cardsArray do
		cardsArray[i].selected = false
		if (cardsArray[i].isThrowed or cardsArray[i].isHide) then 
		else
		   self.TableRunfastView:refreshCardSelect(cardsArray[i])
		end
	end
	self:CheckSelectPokerRule()
end

------出牌准备阶段
function TableRunfastLogic:onReadyThrowCard()
	--1.0检查是否在等待
	if(self.IsWaitDiscardreply) then
		return
	end

	--1.1检查是否有数据
	self:AllowPlayerAction(false)
	local numList = self:GetSelectedPokerList()
	if(numList == nil or #numList <= 0) then
		if(GameSDKInterface:GetPlatformName() == "WindowsEditor") then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("你没有选择任何牌")
		end
		self:AllowPlayerAction(true)
		return
	end

	--1.2检查第一局首发必须包含黑桃3
	local mustThrowNum = self:GetMustThrowNum()
	if(mustThrowNum) then
		print("====必出牌="..tostring(mustThrowNum))
		if(not self.TableRunfastHelper:IsNumTableContains(numList,mustThrowNum)) then
			if(mustThrowNum == self:GetHeiTao3RepresentativeNum()) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("首发必须包含黑桃3")
			end
			self:unSelectedAllPoker()
			self:AllowPlayerAction(true)
			return
		end
	end

	--2.0发送数据
	numList = self:PokerListSort(numList)
	self.TableRunfastModel:request_discardInfo(numList,self.modelData.curTableData.roomInfo.discard_serial_no)

	--3.把牌打出去
	self:FirstThrowPoker()
	self:throwPokerType(numList,true)
	self:SetDoingState(false)
	self:AllowPlayerAction(true,1.5)

	--4.0等待服务器回应
	self.IsWaitDiscardreply = true
	self.WaitDiscardreplyEventId = self.TableRunfastModule:subscibe_time_event(3, false, 0):OnComplete(function(t)
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("等待超时,重新连接")
		TableManagerPoker:heartbeat_timeout_reconnect_game_server()
    end).id
end

function TableRunfastLogic:PokerListSort(numList)
	if(numList == nil or #numList <= 0) then
		return numList
	end

	local boolsandaier = false
	local pt = CardPattern.new(numList,#numList,false)--出牌的类型
	if(pt ~= nil) then
		if(pt.disp_type == "sandaier" or pt.disp_type == "feiji") then
			boolsandaier = true
		end
	end

	if(boolsandaier) then
		local tableSanZhang = {}
		local tableLiangZhang = {}
		local tableDanZhang = {}
		local  card_type_stat,card_name_info,card_name_stat = CardCommon.InitParse(numList)
		--[[
		print("=============card_type_stat")
		print_table(card_type_stat)
		print("=============card_name_info")
		print_table(card_name_info)
		print("=============card_name_stat")
		print_table(card_name_stat)
		]]

		for i=1,#card_name_info do
			local  card_name_info_Table = card_name_info[i]
			if(card_name_info_Table ~= nil ) then
				if(#card_name_info_Table == 3) then--三个的
					for m=1,#card_name_info_Table do
						--print("====3card_name_info_Table[m]="..tostring(card_name_info_Table[m]))
						table.insert(tableSanZhang,card_name_info_Table[m])
					end
				elseif (#card_name_info_Table == 2) then--对子
					for m=1,#card_name_info_Table do
						--print("====card_name_info_Table[m]="..tostring(card_name_info_Table[m]))
						table.insert(tableLiangZhang,card_name_info_Table[m])
					end
				else --单牌
					for m=1,#card_name_info_Table do
						table.insert(tableDanZhang,card_name_info_Table[m])
					end
				end
			end
		end
		--把两张的加入
		for i=1,#tableLiangZhang do
			table.insert(tableSanZhang,tableLiangZhang[i])
		end
		--把单张的加入
		CardCommon.Sort(tableDanZhang)
		for i=1,#tableDanZhang do
			table.insert(tableSanZhang,tableDanZhang[i])
		end
		return tableSanZhang
	else
		CardCommon.Sort(numList)
	end
	return numList
end
--获取选中的牌
function TableRunfastLogic:GetSelectedPokerList()
	-- local selectedPokersArray = self.TableRunfastView.seatHolderArray[1].selectedPokersArray or {}--已经选了的牌
	-- if(selectedPokersArray == nil or #selectedPokersArray <= 0) then
	--    return nil
	-- end
	-- local resultNumList = {}
	-- for i=1,#selectedPokersArray do
	-- 	table.insert(resultNumList, selectedPokersArray[i].PokerNum)
	-- end
	-- return resultNumList
	return self:GetMoveUpPokerList()
end
--获取拉上去的牌
function TableRunfastLogic:GetMoveUpPokerList()
	local resultNumList = {}
	local pokerSlotTable = self.TableRunfastView.seatHolderArray[1].inhandCardsArray
	--print("====GetMoveUpPokerList")
	for i=1,#pokerSlotTable do
		local cardHolder = pokerSlotTable[i]--牌槽
		if(cardHolder.cardRoot.transform.localPosition.y > 5) then
			if(cardHolder.poker and cardHolder.poker.PokerNum) then
				table.insert(resultNumList, cardHolder.poker.PokerNum)
			end
		end
        --
		--if(cardHolder.isThrowed or cardHolder.isHide) then
		--	--
		--else
		--	if(cardHolder.cardRoot.transform.localPosition.y > 5) then
		--		if(cardHolder.poker and cardHolder.poker.PokerNum) then
		--			table.insert(resultNumList, cardHolder.poker.PokerNum)
		--		end
		--	end
		--	-- if(cardHolder.selected) then
		--	-- 	if(cardHolder.poker and cardHolder.poker.PokerNum) then
		--	-- 		table.insert(resultNumList, cardHolder.poker.PokerNum)
		--	-- 	end
		--	-- end
		--end
	end
	--print("====#resultNumList="..tostring(#resultNumList))
	--print_table(resultNumList)
	return resultNumList
end

------重置第一人称出牌的扑克
function TableRunfastLogic:ResetFirstThrowPoker()
	local FirstThrowPokerSlotArray = self.TableRunfastView.FirstThrowPokerSlotArray
	for i=1,#FirstThrowPokerSlotArray do
		local FirstThrowPokerSlot = FirstThrowPokerSlotArray[i]
		ModuleCache.ComponentUtil.SafeSetActive(FirstThrowPokerSlot.PrefabGo,false)
	end
end

------第一人称出牌的扑克
function TableRunfastLogic:FirstThrowPoker(ThrowPokerList)
	local selectedPokersArray = ThrowPokerList or self.TableRunfastView.seatHolderArray[1].selectedPokersArray or {}--已经选了的牌
	if(selectedPokersArray == nil or #selectedPokersArray <= 0) then
	   return
	end

	--重置出牌的槽
	self:ResetFirstThrowPoker()
	--出牌的动画
	local FirstThrowPokerSlotArray = self.TableRunfastView.FirstThrowPokerSlotArray
	local resultNumList = ThrowPokerList or self:GetSelectedPokerList()
	resultNumList = self:PokerListSort(resultNumList)
	for i=1,#resultNumList do
		local FirstThrowPokerSlot = FirstThrowPokerSlotArray[i]
		FirstThrowPokerSlot.FaceImage.sprite = self.TableRunfastHelper:GetPokerSprite(resultNumList[i],nil)
		ModuleCache.ComponentUtil.SafeSetActive(FirstThrowPokerSlot.PrefabGo,true)
		local locOffestY = 227
		self.TableRunfastHelper:PlayMoveYAnim(FirstThrowPokerSlot.FaceImage,0,locOffestY,0.1)
	end

	-- --隐藏你手中已经出过的牌
	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--牌槽
	for i=1,#cardsArray do
		for m=1,#selectedPokersArray do
		    if(cardsArray[i].poker == selectedPokersArray[m]) then
				cardsArray[i].isThrowed = true
				cardsArray[i].isHide = true
				cardsArray[i].selected = false
				ModuleCache.ComponentUtil.SafeSetActive(cardsArray[i].cardRoot.transform.parent.transform.gameObject,false)
		    end
		end
	end

	--没有选中任何牌
	self:unSelectedAllPoker()
end

------重置牌槽
function TableRunfastLogic:ResetPokerSlot()
	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--牌槽
	for i=1,#cardsArray do
		 cardsArray[i].isThrowed = false--已经扔出去
		 cardsArray[i].selected = false--已经选择
		 cardsArray[i].isHide = false--是否隐藏
		 cardsArray[i].isDarkness = false--是否变灰暗
		 self.TableRunfastHelper:enableGradientColor(cardsArray[i],false)
		 cardsArray[i].cardRoot.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,0,0)
		 ModuleCache.ComponentUtil.SafeSetActive(cardsArray[i].cardRoot.transform.gameObject,true)
		 ModuleCache.ComponentUtil.SafeSetActive(cardsArray[i].cardRoot.transform.parent.transform.gameObject,false)
	end
end


--等待自动点击要不起和后面的行为操作
function TableRunfastLogic:WaitNotAffordAndAction()
	if(self:IsJinBiChangAndIntrust()) then
		return
	end

	self.IsWaitOnClickNotAfford = true
	local serial_no = self.modelData.curTableData.roomInfo.discard_serial_no
	self.WaitNotAffordAndActionId = self.TableRunfastModule:subscibe_time_event(self.NotAffordWaitTime, false, 0):OnComplete(function(t)
		self:onClickNotAfford(serial_no)
	end).id
	self:MySelfShowNotAffordWarning(true)
end

------初始化要不起等待的时间
function TableRunfastLogic:InitiNotAffordWaitTime()
	self.NotAffordWaitTime = 0.6
	local curRule = self.modelData.curTableData.roomInfo.createRoomRule
	if(curRule ~= nil) then
		if(curRule.allow_pass) then
			self.NotAffordWaitTime = 5
		elseif(curRule.playerCount == 2) then
			self.NotAffordWaitTime = 1.2
		end
	end
end
------点击要不起
function TableRunfastLogic:onClickNotAfford(serial_no_local)
	if(self:IsJinBiChangAndIntrust()) then
		return
	end

	local clientClickMethod = serial_no_local and  "自动" or "手动"
	self.IsWaitOnClickNotAfford = nil
	serial_no_local = serial_no_local or self.modelData.curTableData.roomInfo.discard_serial_no
	self.TableRunfastModel:request_discardInfo(nil,serial_no_local,clientClickMethod)	--发送请求
	self:MySelfShowNotAffordWarning(false)
	self:SetDoingState(false)
	if(self.WaitNotAffordAndActionId) then
		CSmartTimer:Kill(self.WaitNotAffordAndActionId)
		self.WaitNotAffordAndActionId = nil
	end
end
------我手上的牌要不起提示
function TableRunfastLogic:MySelfShowNotAffordWarning(boolShow)
	ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.NotAffordWarningRoot,boolShow)
	self:SetMyInHandPokerDarkness(boolShow)
end

------点击要不起的效果
function TableRunfastLogic:NotAffordEffect()
	local currThrowId = tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList  do
		local seatInfo = seatInfoList[i]
		local seatInfoPlayerId = tonumber(seatInfo.playerId)
		if(seatInfoPlayerId == currThrowId) then
			local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
			if(seatHolder and seatHolder.NotAffordEffectRoot ) then
				self.TableRunfastHelper:PlayScaleAnim(seatHolder.NotAffordEffectRoot.gameObject,0,1,0.1)
				self:SoundNotAfford(self:GetPlayerIsMaleByPlayerId(seatInfo.playerId))
			end
			return
		end
	end
end

function TableRunfastLogic:initTableSeatDataMy(data)
	self.isDataInited = true
	self:InitiTempSeatInfoList()
	self.modelData.curTableData = self.modelData.curTableData or {}
	local roomInfo = self.modelData.curTableData.roomInfo or {}
	self.modelData.curTableData = {}
	--local roomInfo = {}
	roomInfo.roomNum = data.room_id   --房间号码
	roomInfo.roomType = 1 ---= remoteRoomInfo.ruleType--规则类型
	roomInfo.totalRoundCount = data.game_total_cnt
	roomInfo.curRoundNum = data.game_loop_cnt
	roomInfo.maxPlayerCount = data.max_player_cnt
	roomInfo.next_player_id = data.next_player_id
	roomInfo.timestamp = data.time
	roomInfo.is_deal = data.is_deal or false
	roomInfo.black3_player = data.black3_player
	roomInfo.discard_serial_no = data.discard_serial_no
	roomInfo.CurTip = ""
	roomInfo.feeNum = data.feeNum
	roomInfo.baseCoinScore = data.baseCoinScore or 0
	--roomInfo.gamePhaseState = data.gamePhaseState

	roomInfo.CurRuleJsonString = nil
	if(self.modelData.roleData and self.modelData.roleData.myRoomSeatInfo and self.modelData.roleData.myRoomSeatInfo.Rule) then
		roomInfo.CurRuleJsonString = self.modelData.roleData.myRoomSeatInfo.Rule
	end
	if(roomInfo.CurRuleJsonString and roomInfo.CurRuleJsonString ~= "") then
		roomInfo.CurRuleTable = ModuleCache.Json.decode(roomInfo.CurRuleJsonString)
		-- print("==房间规则="..tostring(roomInfo.CurRuleJsonString))
	end

	--roomInfo.state = remoteRoomInfo.state
	if(roomInfo.expireTimes == nil ) then
	   	roomInfo.expireTimes = {}
	    roomInfo.expireTimes[0] = 0
	    roomInfo.expireTimes[1] = 0
	    roomInfo.expireTimes[2] = 0
	    roomInfo.expireTimes[3] = 0
	end
	roomInfo.ruleDesc = "跑得快"
	roomInfo.timeOffset = data.time - os.time()
	if(roomInfo.roundStarted == nil or roomInfo.roundStarted == false) then
		 roomInfo.roundStarted = data.cards and #data.cards > 0
	end
	roomInfo.gamePhaseState = 1
	self.modelData.curTableData.roomInfo = roomInfo

	--房间的规则
	if(TableManager.RunfastRuleJsonString ~= nil and TableManager.RunfastRuleJsonString ~= "") then
		local locRoomRule = ModuleCache.Json.decode(TableManager.RunfastRuleJsonString)
		if(self.TableRunfastView:isJinBiChang()) then
			locRoomRule.GameType = 2
			locRoomRule.game_type = 2
			TableManager.RunfastRuleJsonString = ModuleCache.Json.encode(locRoomRule)
		end
		self.modelData.curTableData.roomInfo.createRoomRule = locRoomRule
		local wanfa = nil
		if(string.find(locRoomRule.gameName,"DHJSQP_RUNFAST_RUNFAST") ~= nil) then
			wanfa = "jiangsu"
		end
		CardCommon.InitConf(locRoomRule.no_triple_p1,locRoomRule.tripleA_is_bomb,locRoomRule.allow_unruled_multitriple,wanfa,locRoomRule.pay_all)
		roomInfo.CurTip = TableManager:GetCurTip(locRoomRule.game_type)
		-- roomInfo.CurRuleJsonString = TableManager.RunfastRuleJsonString
		-- roomInfo.CurRuleTable = locRoomRule
		print("==跑得快房间规则:"..TableManager.RunfastRuleJsonString)
	end
	self:InitiNotAffordWaitTime()--初始化要不起等待的时间
	

	--缓存座位信息
	local remoteSeatInfoList = data.players
	local seatInfoList = {}
	local seatCount = #remoteSeatInfoList
	for i=1,#remoteSeatInfoList do
		local remoteSeatInfo = remoteSeatInfoList[i]
		local seatInfo = {}
		seatInfo.seatIndex = remoteSeatInfo.player_pos
		seatInfo.playerId = tostring(remoteSeatInfo.player_id or 0)
		seatInfo.player_id = remoteSeatInfo.player_id or 0
		seatInfo.isSeated = self:getBoolState(remoteSeatInfo.player_id)--判断座位上是否有玩家
		seatInfo.isCreator = (self:getBoolState(remoteSeatInfo.is_owner))--是否是房主
		seatInfo.isReady = (self:getBoolState(remoteSeatInfo.is_ready))--是否已准备 
		seatInfo.score = (remoteSeatInfo.score) or 0  --玩家房间内积分
		seatInfo.winTimes = remoteSeatInfo.win_cnt --玩家房间内赢得次数
		seatInfo.isOffline = remoteSeatInfo.is_offline --玩家是否掉线
		seatInfo.is_single = remoteSeatInfo.is_single
		seatInfo.is_single_soundplayed = remoteSeatInfo.is_single

		seatInfo.enter_cnt = remoteSeatInfo.enter_cnt
		seatInfo.isBreakLineReconnection = seatInfo.enter_cnt > 2--大于2表示断线重连
		seatInfo.rest_card_cnt = remoteSeatInfo.rest_card_cnt
		seatInfo.coinBalance = remoteSeatInfo.coinBalance
		seatInfo.IntrustState = remoteSeatInfo.state

		--这里是为了获取缓存的GPS信息.因为GPS信息只会在进入房间和断线重新登入房间才会发广播一次.
		--发牌的消息包会把玩家信息重置,这个时候seatInfo.playerInfo里面就没有GPS信息了.只能获取缓存
		local playerInfo = self:GetTempSeatInfoListPlayerInfo(seatInfo.player_id)
		if(playerInfo == nil) then
			print("=====playerInfo == nil")
		else
			seatInfo.playerInfo = playerInfo
		end



		seatInfo.roomInfo = roomInfo
		table.insert(seatInfoList, seatInfo)
		--绑定玩家到座位
		if(self:getBoolState(remoteSeatInfo.player_id)) then
		    --判断是否玩家自己，单独记录自己的座位
			if(tonumber(seatInfo.playerId) == tonumber(self.modelData.curTablePlayerId)) then
				self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo
				seatInfo.isOffline = false
		    end
		end
	end

	self:resetSeatHolderArray(roomInfo.maxPlayerCount)
	if(self.modelData.curTableData.roomInfo.curRoundNum <= 0) then
		self:OnlyTwoPlayerHandlerThirdSeatShow()
	end
	
	local mySeatIndex = self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex
	local seatInfoListCount= #seatInfoList
	for i=1,seatInfoListCount do
		local seatInfo = seatInfoList[i]
		--转换为本地位置索引
		seatInfo.localSeatIndex = self.TableRunfastHelper:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, mySeatIndex, roomInfo.maxPlayerCount)
		--print("本地坐标=localSeatIndex="..seatInfo.localSeatIndex.." 玩家坐标="..seatInfo.seatIndex)
	end

	roomInfo.seatInfoList = seatInfoList

	--记录上局的数据
	self.modelData.curTableData.roomInfo.next_player_id = data.next_player_id
	self.modelData.curTableData.roomInfo.curThorwCardPlayerId = data.desk_player_id
	local myId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
	local currThrowId = tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)
	self.modelData.curTableData.roomInfo.curPokerTable = {}
	self.modelData.curTableData.roomInfo.my_desk_cards = {}
	if(data.desk_cards ~= nil and #data.desk_cards > 0) then
    	if(currThrowId ~= myId) then
			self.TableRunfastHelper:NumTableInsertToNewTable(self.modelData.curTableData.roomInfo.curPokerTable,data.desk_cards)
		elseif(not self:nextPlayerIsMy()) then
			self.TableRunfastHelper:NumTableInsertToNewTable(self.modelData.curTableData.roomInfo.my_desk_cards,data.desk_cards)
	   	end
	end

	if(data.desk_player_id <= 0 and #data.desk_cards <= 0) then--新的开局
		self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern = self:nextPlayerIsMy()
	else--重连
		if(self:nextPlayerIsMy()) then
			self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern = (currThrowId == myId)
		else
			self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern = false
		end
	end
	--print("==检查是否是自己首发 "..tostring(self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern))

	self.TableRunfastModule:subscibe_time_event(3, false, 0):OnComplete(function(t)
		self:ResetBreakLineReconnection()
    end)
	
	self.TableRunfastView:CheckLayoutUI(self.modelData.curTableData.roomInfo.createRoomRule)
end

------发牌我的牌
function TableRunfastLogic:MyCards(data)
	local set = CardSet.new(data.cards)
	CardCommon.Sort(set.cards)
	local numList = set.cards--data.cards--手上的扑克牌
	local roomInfo = self.modelData.curTableData.roomInfo--房间信息
	roomInfo.state = RoomState.waitResult--房间状态
	local mySeatInfo = roomInfo.mySeatInfo--我的座位信息
	self:ResetPokerSlot()
	mySeatInfo.inHandPokerList = {}--填充我的手牌信息
	mySeatInfo.inHandPokerNumList = numList
	for i=1,#numList do
		local locPoker = self.TableRunfastHelper:NumberToPokerTable(numList[i])
		table.insert(mySeatInfo.inHandPokerList, locPoker)
	end
	self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable = data.cards

	--给其他玩家手牌填充假的数据
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
		if(seatInfo.isSeated and seatInfo.isReady)then
			if(seatInfo ~= mySeatInfo)then            
                seatInfo.inHandPokerList = {}
				if(self.TableRunfastView.isPlayBacking) then--回放模式
					local locPlayId = seatInfo.playerId
					local inHandData = self.TableRunfastModule:PB_GetHandDataByPlayerId(locPlayId)
					if(inHandData ~= nil) then
						local locSet = CardSet.new(inHandData.cards)
						CardCommon.Sort(locSet.cards)
						inHandData.cards = locSet.cards

						for i=1,#inHandData.cards do
							local locCardNum = inHandData.cards[i]
							local locPoker = self.TableRunfastHelper:NumberToPokerTable(locCardNum)
							table.insert(seatInfo.inHandPokerList, locPoker)
						end
						print_table(seatInfo.inHandPokerList)
					end
				else --正常打牌模式
					for i=1,#mySeatInfo.inHandPokerList do
						local poker = self.TableRunfastHelper:NumberToPokerTable(10)
				   	 	table.insert(seatInfo.inHandPokerList, poker)
			    	end	
				end
				
            end	
			if(seatInfo.betScore == 0) then
				seatInfo.betScore = 1
			end

			--显示玩家的手牌
			seatInfo.isBetting = false
			self.TableRunfastView:refreshSeat(seatInfo, false)--不分自己还是其他玩家
			local onFinish = nil
			if(seatInfo == mySeatInfo)then
				onFinish = function()
					self.TableRunfastView:refreshSeatCardsSelect(mySeatInfo)
				end
			end
			self:SetMyPokerFace()				
		end
	end

    --谁出牌的操作按钮
	local boolShowDoingRoot = self:nextPlayerIsMy() and (not self.TableRunfastView.isPlayBacking)
	local locSetDoingStateWaitTime = 0
	if(boolShowDoingRoot and self.modelData.curTableData.roomInfo.isNewRound) then
		locSetDoingStateWaitTime = 0.8
	end
	--self:SetDoingState(boolShowDoingRoot,locSetDoingStateWaitTime)
	self:SetDoingState(boolShowDoingRoot)
end

------是首局
function TableRunfastLogic:IsFirstRound()
	local curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum
	return curRoundNum and curRoundNum == 1
end

--获取黑桃3代表的数字
function TableRunfastLogic:GetHeiTao3RepresentativeNum()
	return 9
end

------手上的扑克牌是否包含黑桃3
function TableRunfastLogic:IsContainsHeiTao3(numList)
    local heitao3 = self:GetHeiTao3RepresentativeNum()
	for i=1,#numList do
		if(numList[i] and numList[i] == heitao3) then
		     return true
		end
	end
	return false
end

--获取必出牌:3人或4人玩法首局首发必出黑桃3数字代号是
function TableRunfastLogic:GetMustThrowNum()
	if(self:IsFirstMustBlack3()) then
		local roomInfo = self.modelData.curTableData.roomInfo
		local InMyHandPokerNumTable = roomInfo.mySeatInfo.InMyHandPokerNumTable
		--没出过牌,并且手中有黑桃3
		if(roomInfo.CurRuleTable.init_card_cnt == #InMyHandPokerNumTable 
		and self:IsContainsHeiTao3(InMyHandPokerNumTable)) then 
			return self:GetHeiTao3RepresentativeNum()
		end
	end
	return nil
end

function TableRunfastLogic:Is_black3_player(black3_player,playerId)
	black3_player = black3_player or self.modelData.curTableData.roomInfo.black3_player
	playerId = playerId or tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
	print("==black3_player="..tostring(black3_player).." playerId="..tostring(playerId))
	return black3_player == playerId
end

--检查我的下家是否报单
function TableRunfastLogic:myNextPlayerIsSingle()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil and seatInfo.localSeatIndex == 2) then
			return seatInfo.is_single
		end
	end
	return false
end

------下一个出牌是我吗
function TableRunfastLogic:nextPlayerIsMy()
	local myId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
	local nextId = tonumber(self.modelData.curTableData.roomInfo.next_player_id)
	return myId == nextId
end

------设置自己手中的扑克牌为正面
function TableRunfastLogic:SetMyPokerFace()
    local inMyHandCards = self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerList
	local pokerSlotList = self.TableRunfastView.seatHolderArray[1].inhandCardsArray
	for i=1,#pokerSlotList do
		local pokerSlot = pokerSlotList[i]
		if(i <= #inMyHandCards ) then
		   self.TableRunfastHelper:showCardFace(pokerSlot)
		else
		   pokerSlot.isThrowed = true
		   pokerSlot.isHide = true
		end
	end
end


function TableRunfastLogic:setCardInfo2(PokerSlot, num)
	--PokerSlot牌槽,num牌代表的数字:将牌填到牌槽里面去
	local poker = self.TableRunfastHelper:NumberToPokerTable(num)
    local sprite = self.TableRunfastView.cardAssetHolder:FindSpriteByName(poker.SpriteName)
	self.TableRunfastHelper:initCardHolder2(PokerSlot,sprite)
end

------点击提示:isHeiTao3黑桃3开局提示,isFirst下一个出牌的玩家是否首发
function TableRunfastLogic:onClickHint()
	self:unSelectedAllPoker()
	local myHandPokerNumTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable--我手上的牌
	local pokerNumTable = self.modelData.curTableData.roomInfo.curPokerTable--别人打的牌	
	if(self.myfn == nil) then
		--print("onClickHint====myfn初始化")
		local locIsMaxPoker = self:IsMustThrowMaxPoker()
		local locIsFirstRound = self:IsFirstRound()
		local ruleTable = self.modelData.curTableData.roomInfo.createRoomRule
		local locIsContainsHeiTao3 = ruleTable.black3_on_firstloop and self:IsContainsHeiTao3(myHandPokerNumTable) 
		local locIsFirstPattern = self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern		

		local set = CardSet.new(myHandPokerNumTable)
		local othersThrowPokerCP = nil
		local startPokerNum = nil
		if(locIsFirstRound and locIsContainsHeiTao3 and ruleTable.init_card_cnt == #myHandPokerNumTable ) then
			print("onClickHint====开局黑桃3")
			othersThrowPokerCP = nil
			startPokerNum = self:GetMustThrowNum()
		elseif(locIsFirstPattern == true) then
			print("onClickHint====别人要不起自己首发")
			othersThrowPokerCP = nil
		else
			print("onClickHint====检查是否接的上牌")
			local locPlayId = self.modelData.curTableData.roomInfo.lastThrowPokerPlayerId or self.modelData.curTableData.roomInfo.curThorwCardPlayerId
			print("locPlayId",locPlayId)
			othersThrowPokerCP = CardPattern.new(pokerNumTable,#pokerNumTable,self:Is_black3_player(nil,tonumber(locPlayId)))
			if(othersThrowPokerCP == nil) then
				print("====别人打的牌异常")
			else
				print("last patttern",othersThrowPokerCP.type, othersThrowPokerCP.value, othersThrowPokerCP.disp_type,self:Is_black3_player(nil,tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)) )
			end
		end
		self.myfn = set:hintIterator(othersThrowPokerCP,startPokerNum,locIsMaxPoker,self:Is_black3_player())
	end

	if(myHandPokerNumTable == nil or #myHandPokerNumTable <= 0) then 
		--print("onClickHint==自己手上没有牌") 
	end
	if(pokerNumTable == nil or #pokerNumTable <=0) then  
		--print("onClickHint==上家没出牌") 
	end

	if(self.myfn == nil) then
		--print("onClickHint======点击提示反馈:要不起")
		self:onClickNotAfford()
	else
		--print("onClickHint======点击提示反馈:要得起")
		local pt = self.myfn()
		self:UpPoker(pt.cards)--将牌拖出来
	end
end

function TableRunfastLogic:AutoThrowPokerClickHint()
end

------检查是否要的起
function TableRunfastLogic:checkCanAfford()
	-- local myHandPokerNumTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable--我手上的牌
	-- local pokerNumTable = self.modelData.curTableData.roomInfo.curPokerTable--别人打的牌	
	-- if(myHandPokerNumTable == nil or pokerNumTable == nil or #pokerNumTable <=0 or  #myHandPokerNumTable <= 0)  then
	--    return true
	-- end

	-- local result = true
	-- local set = CardSet.new(myHandPokerNumTable)
	-- local throwPokerCP = CardPattern.new(pokerNumTable)
	-- if(throwPokerCP == nil) then
	-- 	local pokerNumTableJsonStr = "==error检查别人打的牌不符合牌型,别人打的牌=" .. ModuleCache.Json.encode(pokerNumTable)
	-- 	ModuleCache.GameSDKInterface:BuglyPrintLog(5, pokerNumTableJsonStr)
	-- 	TableManagerPoker:heartbeat_timeout_reconnect_game_server()
	-- 	return true
	-- end

	-- local fn,intJiZhongChuPaiFangShi,boolZhiJieChuPai = set:hintIterator(throwPokerCP)
	-- result = not (fn == nil)
	-- self.myfn = nil
	-- return  result,boolZhiJieChuPai
end

--最后一手强制自动出牌,lastThrowPokerTable最后一手你要强制出的牌
function TableRunfastLogic:LastForceThrowPoker(lastThrowPokerTable)
	if(self:IsJinBiChangAndIntrust()) then
		return
	end

	self.TableRunfastView:SetNotAllowActionMaskLastPokerAutoState(true)
	self:unSelectedAllPoker()
	--延迟
	self.TableRunfastModule:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
		self.TableRunfastView:SetNotAllowActionMaskLastPokerAutoState(true)
		self:unSelectedAllPoker()
		self:UpPoker(lastThrowPokerTable)
		self:onReadyThrowCard()
		self.TableRunfastView:SetNotAllowActionMaskLastPokerAutoState(false,1.5)
    end)
end

--------是否允许自动出牌
function TableRunfastLogic:IsAllowAutoThrowPoker()
	if(self.modelData.curTableData.roomInfo.isAllowAutoThrowPoker == nil) then
		self.modelData.curTableData.roomInfo.isAllowAutoThrowPoker = true
	end
	return  self.modelData.curTableData.roomInfo.isAllowAutoThrowPoker
end
--------设置允许自动出牌的状态
function TableRunfastLogic:SetAllowAutoThrowPokerState(boolAllow,WaitTimeAutoRecover)
	self.modelData.curTableData.roomInfo.isAllowAutoThrowPoker = boolAllow
	if(WaitTimeAutoRecover ~= nil and WaitTimeAutoRecover > 0) then
		self.TableRunfastModule:subscibe_time_event(WaitTimeAutoRecover, false, 0):OnComplete(function(t)
			self.modelData.curTableData.roomInfo.isAllowAutoThrowPoker = not boolAllow
    	end)
	end
end
------自动出牌
function TableRunfastLogic:autoThrowPoker()
	if(not self:IsAllowAutoThrowPoker() or  not self:nextPlayerIsMy()) then
		return
	end
	self:AllowPlayerAction(false,1.5)
	self.TableRunfastModule:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
		self:onReadyThrowCard()
    end)
end

------将提示的牌点出来 
function TableRunfastLogic:UpPoker(pokerNumTable)
	if(pokerNumTable == nil or #pokerNumTable <= 0) then
		return
	end

	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--手上所有的牌
	for i=1,#pokerNumTable do
		local locPokerNum = pokerNumTable[i]--提示的牌的数字
		for m=1,#cardsArray do
		    if(cardsArray[m].isHide or cardsArray[m].isThrowed or cardsArray[m].poker == nil) then
			    --已经打出的牌
			else
			    local cardNum = cardsArray[m].poker.PokerNum
			    if(cardNum == locPokerNum) then
					self:onClickPoker(cardsArray[m].cardRoot)
			    end
			end
		end
	end
end

--通过名字寻找poker
function TableRunfastLogic:FindPokerByName(pokerName)
	local cardsArray = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--手上所有的牌
	for i=1,#cardsArray do
		if(cardsArray[i] and cardsArray[i].cardRoot) then
			if(cardsArray[i].cardRoot.transform.parent.name == pokerName) then
				return cardsArray[i]
			end
		end
	end
	return  nil
end

------初始化上家出的牌
function TableRunfastLogic:initCurThorwPoker()
	local myId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)--我的id
	local locPlayId = tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)--上个出牌的id
	local next_player_id = tonumber(self.modelData.curTableData.roomInfo.next_player_id) --下一个出牌的id
	local locPokerTable = self.modelData.curTableData.roomInfo.curPokerTable--上手牌
	if(locPlayId == nil or locPlayId == 0 or locPlayId == "0" or locPlayId == next_player_id  or #locPokerTable <= 0 or myId == locPlayId) then
		--后面新增:断线重连后,显示自己出过的牌
		if(myId == locPlayId and not self:nextPlayerIsMy()) then
			if(#self.modelData.curTableData.roomInfo.my_desk_cards > 0) then
				self:ResetFirstThrowPoker()
				local FirstThrowPokerSlotArray = self.TableRunfastView.FirstThrowPokerSlotArray
				local resultNumList = self.modelData.curTableData.roomInfo.my_desk_cards
				resultNumList = self:PokerListSort(resultNumList)
				for i=1,#resultNumList do
					local FirstThrowPokerSlot = FirstThrowPokerSlotArray[i]
					FirstThrowPokerSlot.FaceImage.sprite = self.TableRunfastHelper:GetPokerSprite(resultNumList[i],nil)
					ModuleCache.ComponentUtil.SafeSetActive(FirstThrowPokerSlot.PrefabGo,true)
					self.TableRunfastHelper:PlayMoveYAnim(FirstThrowPokerSlot.FaceImage,250,250,0)
				end
				self.modelData.curTableData.roomInfo.my_desk_cards = {}
			end
		end
		return
	else
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(locPlayId,seatInfoList)
		locPokerTable = self:PokerListSort(locPokerTable)
		self:otherThrowCards(seatInfo,locPokerTable)
	end
end

------通过玩家ID获取本地下标
function TableRunfastLogic:getLocalSeatIndex(playId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil and tonumber(seatInfo.playerId) == playId) then
			return seatInfo.localSeatIndex
		end
	end
	return nil
end


------出牌特效
function TableRunfastLogic:PlayThrowPokerEffect(localSeatIndex,effectName)
	local effectRoot = nil
	local seatHolder = self.TableRunfastView.seatHolderArray[localSeatIndex]
	if(seatHolder ~= nil) then
		if(effectName == "shunzi") then
			effectRoot = seatHolder.EffectType.Effect_Shunzi
		elseif(effectName=="sandaiyi") then
			effectRoot = seatHolder.EffectType.Effect_Sandaiyi
		elseif(effectName=="sandaier") then
			effectRoot = seatHolder.EffectType.Effect_Sandaier
		elseif(effectName=="liandui") then
			effectRoot = seatHolder.EffectType.Effect_Liandui
		elseif(effectName=="feiji") then
			effectRoot = seatHolder.EffectType.Effect_Feiji
		elseif(effectName=="zhadan") then
			effectRoot = seatHolder.EffectType.Effect_Zhadan
		end
	end

	if(effectRoot ~= nil) then
		ModuleCache.ComponentUtil.SafeSetActive(effectRoot.gameObject,false)
		ModuleCache.ComponentUtil.SafeSetActive(effectRoot.gameObject,true)
		local waitTime = 2
		if(effectRoot == seatHolder.EffectType.Effect_Feiji) then
			waitTime = 1.2
		end

		self.TableRunfastModule:subscibe_time_event(waitTime, false, 0):OnComplete(function(t)
	 		ModuleCache.ComponentUtil.SafeSetActive(effectRoot.gameObject,false)
    	end)
	end
end

------是否允许玩家操作,WaitTimeAutoRecover等待时间自动恢复
function TableRunfastLogic:AllowPlayerAction(boolAllowAction,delayTime)
	self.TableRunfastView:SetNotAllowActionMaskState(not boolAllowAction,delayTime)
end

------重置报单的数据
function TableRunfastLogic:ResetSingle()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			seatInfo.is_single = false
			seatInfo.is_single_soundplayed = false
			if(seatInfo.localSeatIndex ~= 1) then
				local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
				if(seatHolder ~= nil) then
					ModuleCache.ComponentUtil.SafeSetActive(seatHolder.Warning.gameObject, false)
					ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerRoot.gameObject, false)
				end
			end
		end
	end
end

------通过玩家id获取玩家是否是男性
function TableRunfastLogic:GetPlayerIsMaleByPlayerId(_PlayerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			if(tostring(seatInfo.playerId) == tostring(_PlayerId)) then
				return  seatInfo.playerInfo ~= nil and seatInfo.playerInfo.gender == 1
			end
		end
	end
	return false
end

------收到包:客户自定义的信息变化广播
function TableRunfastLogic:on_table_CustomInfoChangeBroadcast(data)
	--print("==on_table_CustomInfoChangeBroadcast")
	--print_table(data.customInfoList)
	if(self.modelData ==nil or self.modelData.curTableData == nil 
		or self.modelData.curTableData.roomInfo == nil 	
		or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
		return
	end
	if(data ==nil or data.customInfoList == nil or #data.customInfoList <= 0) then
		return
	end
	for i=1,#data.customInfoList do
		local player_id = data.customInfoList[i].player_id
		local customInfo = data.customInfoList[i].customInfo
		if(customInfo == nil or customInfo == "") then
			print("==customInfo == nil or customInfo ==")
		else
			local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList	
			for m=1,#seatInfoList do
				local seatInfo = seatInfoList[m]
				if(tostring(seatInfo.playerId) == tostring(player_id)) then
					local locTable = ModuleCache.Json.decode(customInfo)
					if(seatInfo.playerInfo == nil) then
						print("====seatInfo.playerInfo == nil")
					else
						--print("==ip="..locTable.ip.."  address="..locTable.address)
						--seatInfo.playerInfo.ip = locTable.ip
						seatInfo.playerInfo.locationData = seatInfo.playerInfo.locationData or {}
						seatInfo.playerInfo.locationData.address = locTable.address
						seatInfo.playerInfo.locationData.gpsInfo = locTable.gpsInfo
					end
				end
			end
		end
	end

	self:CheckLocation()
end

------检查位置
function TableRunfastLogic:CheckLocation()
	if ModuleCache.GameManager.iosAppStoreIsCheck then
		return
	end
--	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
--    --获取玩家信息列表
--    local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList)
--    -- 是否显示定位图标
--    TableManagerPoker:isShowLocation(playerInfoList,self.TableRunfastView.BtnLocation)

    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local data ={};
    data.gameType="runfast";
    data.seatHolderArray = seatInfoList;
    data.buttonLocation = self.TableRunfastView.BtnLocation;
    data.roomID=self.modelData.curTableData.roomInfo.roomNum;
    data.tableCount=self.modelData.curTableData.roomInfo.maxPlayerCount;
    data.isShowLocation=false;
    --打开定位功能界面
    ModuleCache.ModuleManager.show_module("henanmj", "tablelocation",data);
end

------检查是否中途退出这局游戏
function TableRunfastLogic:CheckIsDroppedOutThisRoundGame()
	return self.modelData.curTableData.roomInfo.curRoundNum > 0 and self.modelData.curTableData.roomInfo.totalRoundCount ~= self.modelData.curTableData.roomInfo.curRoundNum
end

------自动准备
function TableRunfastLogic:AutoReady()
	-- print("---------------------------------------------------1.1只有还没开始前才能自动开始")
	if(self.modelData.curTableData.roomInfo.curRoundNum <= 0) then
		--print("1.2   >=3人玩法都自动开始")

		--self.modelData.roleData.RoomType == 2 快速组局
		if self.modelData.roleData.RoomType == 2 then
			self.TableRunfastView:refreshAllBtnState()
			return
		end

		if(self.modelData.curTableData.roomInfo.maxPlayerCount >= 3) then
			if(not self.modelData.curTableData.roomInfo.mySeatInfo.isReady) then
				--print("====AutoReady3")
				self.TableRunfastModel:request_ready()
				self:SetKickBtnShowState(false)
				return
			end
		else
			--print("1.3  2人玩法房主不自动准备")
			local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
			if(#seatInfoList == 2) then
				ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.ButtonInviteFriendDray.gameObject, true)
			elseif(#seatInfoList == 1) then
				ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.ButtonInviteFriendDray.gameObject, false)
			end
			if(self.modelData.curTableData.roomInfo.mySeatInfo.isCreator) then
				--房主不自动准备
				if(#seatInfoList == 2) then
					ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.ButtonLeave.gameObject, false)
					ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.buttonReady.gameObject, true)
				elseif(#seatInfoList == 1) then
					ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.ButtonLeave.gameObject, true)
					ModuleCache.ComponentUtil.SafeSetActive(self.TableRunfastView.buttonReady.gameObject, false)
				end
				self:SetKickBtnShowState(true)
			else
				self.TableRunfastModel:request_ready()
				return
			end
		end
	end
end

function TableRunfastLogic:ClickButtonReadyAction()
	if(self.modelData.curTableData.roomInfo.maxPlayerCount <=2) then
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		if(#seatInfoList <= 1) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("等待其他玩家进入房间")
			return
		end

		local myseatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			if(seatInfo ~= nil) then
				if(myseatInfo == seatInfo) then
					--自己不管
				else
					if(seatInfo.isReady) then
						self.TableRunfastModel:request_ready()
					else
						ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("等待其他玩家先准备")
					end
				end
			end
		end
	end
end

function TableRunfastLogic:SetKickBtnShowState(_isShow)
	local myIsCreator = self.modelData.curTableData.roomInfo.mySeatInfo.isCreator
	if(not myIsCreator
	or self.modelData.curTableData.roomInfo.curRoundNum > 0
	or self.modelData.curTableData.roomInfo.maxPlayerCount >= 3
	or self.modelData.roleData.RoomType == 2--RoomType == 2为快速组局，快速组局没有踢人功能
	or self.modelData.roleData.RoomType == 3--RoomType == 3为比赛场，没有踢人
	) then
		_isShow = false
	end

	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			local localSeatIndex = seatInfo.localSeatIndex
			local seatHolder = self.TableRunfastView.seatHolderArray[localSeatIndex]
			if(localSeatIndex == 2) then
				ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,_isShow)
			else
				ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,false)
			end 
		end
	end
end

function TableRunfastLogic:OnClickKickBtn(_PlayerId)
	self.TableRunfastModel:request_KickPlayerReq(_PlayerId)
end

------检查是否有玩家离线
function TableRunfastLogic:CheckIsHavePlayerOffline()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil and seatInfo.isOffline) then
			 return true
		end
	end
	return false
end

------只有两个玩家时处理第三个玩家的座位显示
function TableRunfastLogic:OnlyTwoPlayerHandlerThirdSeatShow()
	if(self.modelData.curTableData.roomInfo.maxPlayerCount >=3) then
		return
	end

	local seatHolder = self.TableRunfastView.seatHolderArray[3]
	ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotSeatRoot.gameObject,false)
	ModuleCache.ComponentUtil.SafeSetActive(seatHolder.ThirdSeatShow,true)
	if(self.modelData.curTableData.roomInfo.createRoomRule ~= nil) then
		local ruleTable = self.modelData.curTableData.roomInfo.createRoomRule
		seatHolder.ThirdSeatShowText.text = string.format( "剩余:%d张",ruleTable.init_card_cnt)
	end
end

function TableRunfastLogic:ResetAllPlayerReadyState()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			seatInfo.isReady = false
		end
	end
end


function TableRunfastLogic:RefreshReadyBtn()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			local localSeatIndex = seatInfo.localSeatIndex
			local seatHolder = self.TableRunfastView.seatHolderArray[localSeatIndex]
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject,seatInfo.isReady)
		end
	end

	--收到准备广播 刷新所以按钮状态
	self.TableRunfastView:refreshAllBtnState()
end


function TableRunfastLogic:ResetBreakLineReconnection()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			seatInfo.isBreakLineReconnection = false
		end
	end
end

function TableRunfastLogic:IsBreakLineReconnectionByPlayerId(_PlayerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			if(tostring(seatInfo.playerId) == tostring(_PlayerId)) then
				return seatInfo.isBreakLineReconnection
			end
		end
	end
end

--通过服务器刷新我手中的牌
function TableRunfastLogic:refreshMyHandPokerListBySeverData(myHandPokerTableFromSever)
	local myHandPokerNumTable = myHandPokerTableFromSever
	if(myHandPokerNumTable == nil or #myHandPokerNumTable <= 0) then
		myHandPokerNumTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable --我手上的牌
	end

	if(myHandPokerNumTable == nil or #myHandPokerNumTable <= 0) then
		print("==error自己手上没有牌,牌局结束了")
		self:ResetPokerSlot()
		return
	end

	--1.1排序
	local set = CardSet.new(myHandPokerNumTable)
	CardCommon.Sort(set.cards)
	myHandPokerNumTable = set.cards

	--1.2设置数据
	local pokerSlotTable = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--牌的预设
	for i=1,#pokerSlotTable do
		local cardHolder = pokerSlotTable[i]--牌槽
		if(i <= #myHandPokerNumTable) then
			local locPoker = self.TableRunfastHelper:NumberToPokerTable(myHandPokerNumTable[i])
			self.TableRunfastHelper:setCardInfo(cardHolder,locPoker)
			cardHolder.isThrowed = false
			cardHolder.isHide = false
			cardHolder.isDarkness = false
			cardHolder.cardRoot.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,0,0)
		else
			cardHolder.isThrowed = true
			cardHolder.isHide = true
			cardHolder.isDarkness = true
			cardHolder.cardRoot.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,0,0)
		end
		cardHolder.selected = false
		self.TableRunfastHelper:enableGradientColor(cardHolder,cardHolder.isDarkness)
		ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot.transform.parent.transform.gameObject,not cardHolder.isHide)
	end
end


--设置自己手上的牌变灰暗
function TableRunfastLogic:SetMyInHandPokerDarkness(_boolDarkness)
	local InMyHandPoker = self.TableRunfastView.seatHolderArray[1].inhandCardsArray--手上所有的牌
	for i=1,#InMyHandPoker do
		local locPoker = InMyHandPoker[i]
		if(locPoker == nil or locPoker.isThrowed or locPoker.isHide) then
			--这些牌不用管了
		else
			locPoker.isDarkness = _boolDarkness
			self.TableRunfastHelper:enableGradientColor(locPoker,_boolDarkness)
		end
	end
end

--检查选择的牌型规则,是否可以将牌打出去
function TableRunfastLogic:CheckSelectPokerRule()
	if(not self:nextPlayerIsMy()) then
		return
	end

	self.TableRunfastView:SetBtnNotAffordState(not self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern)

	--print("==1.1检查是否有选牌")
	local selectedPokerList = self:GetSelectedPokerList()
	if(selectedPokerList == nil or #selectedPokerList <= 0) then
		--print("====你没有选择牌!")
		self.TableRunfastView:SetBtnThrowCardState(false)
		return
	end

	--print("==1.2检查牌型是否符合出牌规则")
	local myHandPokerNumTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable
	if(myHandPokerNumTable == nil or #myHandPokerNumTable <= 0) then
		self:ResetPokerSlot()
		print("==error自己手上没有牌,牌局结束了")
		return
	end
	if(#selectedPokerList > #myHandPokerNumTable) then
		--print("====error 你选择要出的牌大于你上手的牌=")
		ModuleCache.GameSDKInterface:BuglyPrintLog(5, "==error 你选择要出的牌的数量大于你上手的牌的数量")
		TableManagerPoker:heartbeat_timeout_reconnect_game_server()
		return
	end
	local mySelectedPokerCP = CardPattern.new(selectedPokerList,#myHandPokerNumTable,self:Is_black3_player())
	if(mySelectedPokerCP == nil) then
		--print("====你选择的牌不符合出牌规则!")
		self.TableRunfastView:SetBtnThrowCardState(false)
		return
	end
	--print("==1.3检查下家是否报单,报单要出最大牌")
	if(self:myNextPlayerIsSingle()) then
		local RuleTable = self.modelData.curTableData.roomInfo.createRoomRule
		print("====下家报单,检查放走包赔RuleTable.pay_all=",RuleTable.pay_all)
		if(#selectedPokerList == 1 and RuleTable.pay_all == false) then
			local single_wrong = self:CheckSingle_wrong(myHandPokerNumTable,mySelectedPokerCP)
			--print("=======single_wrong="..tostring(single_wrong))
			if(single_wrong) then
				self.TableRunfastView:SetBtnThrowCardState(false)
				return
			end
		end
	end

	if(self.TableRunfastView:isJinBiChang()
	and self.modelData.curTableData.roomInfo.createRoomRule.black3_on_firstloop
	and self.modelData.curTableData.roomInfo.createRoomRule.init_card_cnt == #myHandPokerNumTable) then
		local locIsContainsHeiTao3 = self:IsContainsHeiTao3(myHandPokerNumTable)
		local MySelcetIsHeiTao3 = self:IsContainsHeiTao3(selectedPokerList)
		if(locIsContainsHeiTao3 and not MySelcetIsHeiTao3) then
			self.TableRunfastView:SetBtnThrowCardState(false)
			return
		end
	end

	--print("==1.3检查是否首发,如果是首发就不需要进行下一步判断了")
	if(self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern) then
		self.TableRunfastView:SetBtnThrowCardState(true)
		return
	end

	--print("==1.4检查接牌时能否大的起别人的牌")
	--print("==1.4.1检查别人打的牌")
	local pokerNumTable = self.modelData.curTableData.roomInfo.curPokerTable--别人打的牌
	if(pokerNumTable == nil or #pokerNumTable <= 0 ) then
		print("==error别人打的牌数据为空")
		self.TableRunfastView:SetBtnThrowCardState(true)
		ModuleCache.GameSDKInterface:BuglyPrintLog(5, "==error别人打的牌数据为空")
		return
	end
	--print("==1.4.1检查别人打的牌是否是符合牌型")
	local throwPokerCP = CardPattern.new(pokerNumTable,#pokerNumTable,self:Is_black3_player(nil,tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)))
	if(throwPokerCP == nil) then
	    local pokerNumTableJsonStr = "==error检查别人打的牌不符合牌型,别人打的牌=" .. ModuleCache.Json.encode(pokerNumTable)
		ModuleCache.GameSDKInterface:BuglyPrintLog(5, pokerNumTableJsonStr)
		TableManagerPoker:heartbeat_timeout_reconnect_game_server()
		return
	end
	if (mySelectedPokerCP:compable(throwPokerCP) and not mySelectedPokerCP:le(throwPokerCP)) then
		--这里你可以打起别人,可以显示按钮
	else
		--print("====你的牌打不起别人")
		self.TableRunfastView:SetBtnThrowCardState(false)
		return
	end

	--print("==1.5最后你可以点击出牌按钮")
	self.TableRunfastView:SetBtnThrowCardState(true)
end

--检查报单的提醒
function TableRunfastLogic:CheckSingle_wrong(myHandPokerNumTable,mySelectedPokerCP)
	local single_wrong = false
	for _, c in ipairs(myHandPokerNumTable) do
        local cm = CardCommon.NameIdx2Value(c)
		if(cm > mySelectedPokerCP.value) then
            single_wrong = true;
            break;
        end
    end
	return single_wrong
end

function TableRunfastLogic:SetDoingState(boolShowDoing)
	self.TableRunfastView:SetDoingState(boolShowDoing)
	if(boolShowDoing) then 
		self:CheckSelectPokerRule()
	end
end


function TableRunfastLogic:SeatInfoListRemoveDataByPlayerId(_PlayerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			if(tonumber(seatInfo.playerId) == tonumber(_PlayerId)) then
				table.remove(seatInfoList, i)
				return
			end
		else
			table.remove(seatInfoList, i)
		end
	end
end

function TableRunfastLogic:InitiTempSeatInfoList()
	if(self.tempSeatInfoList == nil) then
		if(self.modelData ~= nil
		and self.modelData.curTableData ~= nil 
		and self.modelData.curTableData.roomInfo ~= nil 
		and self.modelData.curTableData.roomInfo.seatInfoList ~= nil) then
			self.tempSeatInfoList = {}
			local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
			for i=1,#seatInfoList do
				table.insert(self.tempSeatInfoList,seatInfoList[i])
			end
		end
	end

	self.TableRunfastModule:subscibe_time_event(1, false, 0):OnComplete(function(t)
		self.tempSeatInfoList = nil
    end)
end

function TableRunfastLogic:GetTempSeatInfoListPlayerInfo(_PlayerId)
	local seatInfoList = self.tempSeatInfoList
	if(seatInfoList == nil or #seatInfoList <= 0) then
		return nil
	end

	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo ~= nil) then
			if(tonumber(seatInfo.playerId) == tonumber(_PlayerId)) then
				return seatInfo.playerInfo
			end
		end
	end

	return nil
end

--检查炸弹,记录状态
-- function TableRunfastLogic:CheckZhaDan(disp_type)
-- 	if(disp_type == "zhadan") then
-- 		self.IsZhaDan = true
-- 		self.ThrowZhaDanPlayerId = tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)
-- 		--print("===记录打炸弹的Id="..tostring(ThrowZhaDanPlayerId))
-- 	else
-- 		self.IsZhaDan =  nil
-- 		self.ThrowZhaDanPlayerId = nil
-- 	end
-- end

--检查炸弹,是否要飞的效果
function TableRunfastLogic:CheckZhaDanFlyScore(data)
	-- if(not data.is_first_pattern or self.IsZhaDan == nil or self.ThrowZhaDanPlayerId == nil) then
	-- 	return
	-- end
	-- print("====data.next_player_discard_bomb=",tostring(data.next_player_discard_bomb))
	-- print("====data.is_first_pattern=",tostring(data.is_first_pattern))
	-- print("====data.next_player_id=",tostring(data.next_player_id))
	if(data.next_player_discard_bomb and data.is_first_pattern) then
		local curRoomRule = self.modelData.curTableData.roomInfo.createRoomRule
		local count = 10 * (curRoomRule.rate or 1)
		local locThrowZhaDanPlayerId = data.next_player_id--self.ThrowZhaDanPlayerId
		local fromPosTable = {}
		local targetPos = nil
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			if(seatInfo ~= nil) then
				local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
				if(locThrowZhaDanPlayerId == tonumber(seatInfo.playerId)) then
					--加分的玩家
					--print("加分的玩家="..tostring(seatInfo.playerId))
					targetPos = seatHolder.imagePlayerHead.transform.position
					local scoreVar = (count * (curRoomRule.playerCount - 1))
					seatInfo.score = seatInfo.score + scoreVar
					ModuleCache.ComponentUtil.SafeSetActive(seatHolder.ZhaDanEffectPread,false)
					self.TableRunfastModule:subscibe_time_event(1, false, 0):OnComplete(function(t)
						self.TableRunfastHelper:PlayScaleAnim(seatHolder.ZhaDanEffectPread,1,1.3,0.6,0.6)
    				end)
					self:ZhaDanEffectScore(seatHolder,true,scoreVar)
				else
					--减分的玩家
					--print("减分的玩家="..tostring(seatInfo.playerId))
					local fromPos = seatHolder.imagePlayerHead.transform.position
					table.insert( fromPosTable, fromPos)
					seatInfo.score = seatInfo.score - count
					self:ZhaDanEffectScore(seatHolder,false,count)
				end
				self.TableRunfastModule:subscibe_time_event(1, false, 0):OnComplete(function(t)
					--seatHolder.textScore.text = tostring(seatInfo.score)
					self.TableRunfastView:RefreshSeatInfoCurrency(seatInfo)
    			end)
			end
		end


		if(fromPosTable ~= nil and #fromPosTable > 0 and targetPos ~= nil) then
			local len = count
			local cloneObj = self.TableRunfastView.ZhaDanScorePrefab
			local parentObj = self.TableRunfastView.ZhaDanScoreRoot
			local duration = 0.6
			local delayTime = nil
			local autoDestory = true
			for i=1,#fromPosTable do
				local fromPos = fromPosTable[i]
				self.TableRunfastHelper:FlyToTarget(len,cloneObj,parentObj,fromPos,targetPos,duration,delayTime,autoDestory)
			end
			ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/table/zhadanscore.bytes", "zhadanscore")
		end
	end
end
--炸弹,加减分数的效果
function TableRunfastLogic:ZhaDanEffectScore(seatHolder,isAdd,scoreCount,WaitTime)
	WaitTime = WaitTime or 0.8
	self.TableRunfastModule:subscibe_time_event(WaitTime, false, 0):OnComplete(function(t)
		local locRoot = seatHolder.ZhaDanEffectMoveRoot
		local textWrapAddScore = GetComponentWithPath(locRoot, "AddScore", "TextWrap")
		local textWrapReduceScore = GetComponentWithPath(locRoot, "ReduceScore", "TextWrap")
		ModuleCache.ComponentUtil.SafeSetActive(textWrapAddScore.gameObject,isAdd)
		ModuleCache.ComponentUtil.SafeSetActive(textWrapReduceScore.gameObject,not isAdd)
		if(isAdd) then
			textWrapAddScore.text = "+" .. tostring(scoreCount)
		else
			textWrapReduceScore.text = "-" .. tostring(scoreCount)
		end
		self.TableRunfastHelper:PlayMoveYAnim(locRoot,-35,0,0.2,0.4)
    end)
end

--是否别人断线重连
function TableRunfastLogic:IsOtherBreakLineReconnection(breakLineReconnectionPlayerId,myId)
	if(breakLineReconnectionPlayerId ~= nil) then
		return breakLineReconnectionPlayerId ~= myId
	end
	return false
end

--是否必须出最大牌
function TableRunfastLogic:IsMustThrowMaxPoker()
	return self:myNextPlayerIsSingle()
end 

--滑牌提示
function TableRunfastLogic:DragHint()
	-- print("=========DragHint=")
    local upList = self:GetMoveUpPokerList()
    -- print_table(upList)
    if(#upList > 5) then
        self.myfn = nil
        local myHandPokerNumTable = upList
        local pokerNumTable = self.modelData.curTableData.roomInfo.curPokerTable
        local locIsMaxPoker = false
		local locIsFirstRound = self:IsFirstRound()
		local ruleTable = self.modelData.curTableData.roomInfo.createRoomRule
		local locIsContainsHeiTao3 = ruleTable.black3_on_firstloop and self:IsContainsHeiTao3(myHandPokerNumTable) 
        local locIsFirstPattern = self.modelData.curTableData.roomInfo.mySeatInfo.is_first_pattern	
        local set = CardSet.new(myHandPokerNumTable)
        local othersThrowPokerCP = nil
        local startPokerNum = self:GetMustThrowNum()
        if(locIsFirstRound and locIsContainsHeiTao3) then
			print("onClickHint====开局黑桃3")
			othersThrowPokerCP = nil
		elseif(locIsFirstPattern == true) then
			print("onClickHint====别人要不起自己首发")
			othersThrowPokerCP = nil
		else
			print("onClickHint====检查是否接的上牌")
			local locPlayId = self.modelData.curTableData.roomInfo.lastThrowPokerPlayerId or self.modelData.curTableData.roomInfo.curThorwCardPlayerId
			print("locPlayId",locPlayId)
			othersThrowPokerCP = CardPattern.new(pokerNumTable,#pokerNumTable,self:Is_black3_player(nil,tonumber(locPlayId)))
			if(othersThrowPokerCP == nil) then
				print("====别人打的牌异常")
			else
				print("last patttern",othersThrowPokerCP.type, othersThrowPokerCP.value, othersThrowPokerCP.disp_type,self:Is_black3_player(nil,tonumber(self.modelData.curTableData.roomInfo.curThorwCardPlayerId)) )
			end
		end
		self.myfn = set:hintIterator(othersThrowPokerCP,startPokerNum,locIsMaxPoker,self:Is_black3_player())
        if(self.myfn == nil) then
        else
            print("======11111111")
            self:unSelectedAllPoker()
            local pt = self.myfn()
            self:UpPoker(pt.cards)--将牌拖出来
        end
    end
end


function TableRunfastLogic:CurRoundIsBlack3First()
	--print("--当局是否黑桃3首发")
	local roomInfo = self.modelData.curTableData.roomInfo
	if(roomInfo.CurRuleTable) then
		if(roomInfo.CurRuleTable.playerCount <= 2) then
			return fasle
		elseif(roomInfo.CurRuleTable.every_round_black3_first) then
			return true
		else
			if(roomInfo.curRoundNum == 1) then
				return true
			end
		end
	else
		print("error====没有规则字段请检查问题")
	end
	return false
end

function TableRunfastLogic:IsFirstMustBlack3()
	--print("--首出必出黑桃三")
	return self:CurRoundIsBlack3First() and self.modelData.curTableData.roomInfo.CurRuleTable.first_must_black3
end

function TableRunfastLogic:CheckHeiTao3Fly()
	--print("--首發玩家黑桃三飛牌")
	local roomInfo = self.modelData.curTableData.roomInfo
	if(roomInfo.isNewRound and not roomInfo.is_deal) then
		if(self:CurRoundIsBlack3First()) then
			local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(roomInfo.next_player_id,roomInfo.seatInfoList)
			if(seatInfo) then
				if(seatInfo ~= roomInfo.mySeatInfo) then
					local seatHolder = self.TableRunfastView.seatHolderArray[seatInfo.localSeatIndex]
					self.TableRunfastView:PlayHeiTao3Anim(seatHolder.NotSeatRoot.transform.position)
				end
			end
		end
	end
end

function TableRunfastLogic:OneShotSettleNotify(data)
	print("====OneShotSettleNotify")
	if(data.players ~= nil and #data.players > 0) then
		local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		for i=1,#data.players do
			local locData = data.players[i]
			if(locData) then
				local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(locData.player_id,seatInfoList)
				if(seatInfo) then
					seatInfo.coinBalance = locData.coinBalance
					self.TableRunfastView:RefreshSeatInfoCurrency(seatInfo)
				end
			end
		end
	end
end

function TableRunfastLogic:IntrustRsp(data)
	print("====IntrustRsp托管回应")
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	mySeatInfo.IntrustState = data.status
	self.TableRunfastView:SetCancelIntrustState(mySeatInfo.IntrustState == 1)
	if(mySeatInfo.IntrustState == 0) then
		print("====刚刚取消托管状态")
		self.IsJustCancelIntrust = true
	end
end

function TableRunfastLogic:IntrustNotify(data)
	print("====IntrustNotify托管通知")
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(data.player_id,roomInfo.seatInfoList)
	if(seatInfo == nil) then
		print("warning====seatInfo == nil ")
	else
		seatInfo.IntrustState = data.status
		if(seatInfo == roomInfo.mySeatInfo) then
			self.TableRunfastView:SetCancelIntrustState(seatInfo.IntrustState == 1)
		end
	end
end

function TableRunfastLogic:IsJinBiChangAndIntrust( ... )
	return self.TableRunfastView:isJinBiChang() and self:MySelfIsIntrust()
end

function TableRunfastLogic:MySelfIsIntrust()
	--print("====我是否是托管状态")
	return self.modelData.curTableData.roomInfo.mySeatInfo.IntrustState == 1
end

function TableRunfastLogic:CheckIntrust()
	if(self.TableRunfastView:isJinBiChang()) then
		--print("====检查托管状态",self:MySelfIsIntrust())
		self.TableRunfastView:SetCancelIntrustState(self:MySelfIsIntrust())
	end
end

function TableRunfastLogic:TimeoutNotify(data)
	--print("====TimeoutNotify")
	-- ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("TimeoutNotify")
	if(data.timeout == nil or data.timeout <= 0) then
		data.timeout = 0
	end
	local roomInfo = self.modelData.curTableData.roomInfo
	local timeOverIsAutoHide = false
	if(data.event == nil or data.event == 0) then
		-- print("--准备")
	elseif(data.event == 1) then
		-- print("--等待出牌，超时托管")
		timeOverIsAutoHide = true
	elseif(data.event == 2) then
		-- print("--等待充值，超时破产  ")
	else
		-- self:ResetJinBiChangTimeDown(true)
	end
	if(data.player_id == nil or data.player_id == 0) then
		self:StartClockTimeDown(roomInfo.mySeatInfo,data.timeout,timeOverIsAutoHide)
	else
		local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(data.player_id,roomInfo.seatInfoList)
		if(seatInfo == roomInfo.mySeatInfo) then
			self:StartClockTimeDown(roomInfo.mySeatInfo,data.timeout,timeOverIsAutoHide)
		end
	end
end

function TableRunfastLogic:BankruptNotify(data)
	print("====BankruptNotify")
	-- ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("破产通知BankruptNotify")
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(data.player_id,roomInfo.seatInfoList)
	if(seatInfo == nil) then
		print("====seatInfo == nil")
	else
		if(data.coinBalance and data.coinBalance ~= 0) then
			seatInfo.coinBalance = data.coinBalance
			self.TableRunfastView:RefreshSeatInfoCurrency(seatInfo)
		end
		if(data.state == 0) then
			--0恢复正常状态
			if(data.waitCnt == nil or data.waitCnt == 0) then
				self:ResetJinBiChangTimeDown(true)
			end
		elseif(data.state == 1) then
			--1恢复成托管状态
			if(data.waitCnt == nil or data.waitCnt == 0) then
				self:ResetJinBiChangTimeDown(true)
			end
		elseif(data.state == 2) then
			--2 正等待玩家充值
			if(seatInfo == roomInfo.mySeatInfo) then
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
					self.TableRunfastModel:request_RechargeReq(true)
					ModuleCache.ModuleManager.show_module("public", "goldadd")
				end, function()
					--不充值，确认破产
					self.TableRunfastModel:request_BankruptConfirmReq(3)
				end, true, "确 认", "取 消")
			end
		elseif(data.state == 3) then
			--3 已确认破产
			if(data.waitCnt == nil or data.waitCnt == 0) then
				self:ResetJinBiChangTimeDown(true)
			end
		end
	end
end

function TableRunfastLogic:StartClockTimeDown(seatInfo,time,timeOverIsAutoHide)
	print("====开始闹钟倒计时","seatInfo.playerId="..tostring(seatInfo.playerId),"time="..tostring(time))
	local seatHolder = self.TableRunfastView:GetSeatHolderBySeatInfo(seatInfo)
	if(seatHolder == nil) then
		return
	end
	self:ResetJinBiChangTimeDown(true)
	if(time <= 0) then
		return
	end
	ModuleCache.ComponentUtil.SafeSetActive(seatHolder.clockHolder.goClock.gameObject,true)
	self.ClockTimeDownId = self.TableRunfastModule:subscibe_time_event(time, false, 1):OnUpdate( function(t)
		t = t.surplusTimeRound
		seatHolder.clockHolder.textClock.text = t
		if(t <= 3) then
			self:PlayClockDownSound()
		end

		if(self.modelData.curTableData.roomInfo.curAccountData) then
			--结算界面的倒计时
			self.TableRunfastModule:dispatch_package_event("Event_CurrentGameAccountTimeDown",t)
		end
	end):OnComplete( function(t)
		if(timeOverIsAutoHide) then
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.clockHolder.goClock.gameObject,false)
		end
	end).id
end

function TableRunfastLogic:ResetJinBiChangTimeDown(IsHideClock)
	if self.ClockTimeDownId then
		CSmartTimer:Kill(self.ClockTimeDownId)
		self.ClockTimeDownId = nil
	end
	if(IsHideClock) then
		self:ResetClockTimeDown()
	end
end

function TableRunfastLogic:PlayClockDownSound()
	ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/table/clockdown.bytes", "clockdown")
end

function TableRunfastLogic:RechargeNotify(data)
	print("====Msg_Table_RechargeNotify")
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(data.player_id,roomInfo.seatInfoList)
	self:SetSeatInfoRechargeState(seatInfo,data.open)
end

function TableRunfastLogic:ResetAllSeatInfoRechargeState()
	--print("====重置重置状态")
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		self:SetSeatInfoRechargeState(seatInfo,false)
	end
end

function TableRunfastLogic:SetSeatInfoRechargeState(seatInfo,show)
	--print("===设置状态")
	if(seatInfo == nil)then
		print("====seatInfo == nil")
	else
		local seatHolder = self.TableRunfastView:GetSeatHolderBySeatInfo(seatInfo)
		if(seatHolder) then
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RechargeGoldRoot.gameObject, show)
		end
	end
end


function TableRunfastLogic:GetGameType(gametype)
	if(self.TableRunfastView:isJinBiChang()) then
		return 2
	else
		return gametype
	end
end

function TableRunfastLogic:ResetSeatToNotSeatDown(seatInfo)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	if(seatInfo == nil) then
	else
		-- print("====没有找到这个玩家,但是被踢了=")
		local seatHolder = self.TableRunfastView:GetSeatHolderBySeatInfo(seatInfo)
		if(seatHolder) then
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotSeatRoot.gameObject, true)
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, false)
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RechargeGoldRoot.gameObject, false)
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotAffordEffectRoot,false)
		end
		print("====#seatInfoList",#self.modelData.curTableData.roomInfo.seatInfoList )
		for i=1,#seatInfoList do
			local locSeatInfo = seatInfoList[i]
			if (locSeatInfo == seatInfo) then
				table.remove(seatInfoList, i)
				break
			end
		end
		print("====#seatInfoList",#self.modelData.curTableData.roomInfo.seatInfoList )

	end
end

function TableRunfastLogic:CardRecorderMsg(data)
	local roomInfo = self.modelData.curTableData.roomInfo
	local seatInfo = self.TableRunfastHelper:getSeatInfoByPlayerId(data.playerId,roomInfo.seatInfoList)
	if(seatInfo == nil) then
		print("error====seatInfo == nil")
	else
		if(data.items and #data.items > 0) then
			self.TableRunfastView:SetRecordPokerCountSlotArrayData(data.items)
		end
		seatInfo.effectiveDuration = data.effectiveDuration
		if(seatInfo.effectiveDuration and seatInfo.effectiveDuration > 0) then
			local locShowTime  = self:GetCardRecorderShowTime(seatInfo.effectiveDuration)
			if(locShowTime ~= "") then
				self.TableRunfastView.RecordPokerTimeText.text = locShowTime
			end
		end
	end
end

function TableRunfastLogic:GetCardRecorderShowTime(effectiveDuration)
	-- effectiveDuration = 58
	local result = ""
	local tianshu = math.floor(effectiveDuration / 86400 )
	local xiaoshi = nil
	local fenzhong = nil
	if(tianshu > 0) then
		result = result .. tianshu .. "天"
		xiaoshi = math.floor((effectiveDuration % 86400) / 3600)
		if(xiaoshi > 0) then
			result = result .. xiaoshi .. "小时"
		end
	else
		xiaoshi = math.floor(effectiveDuration / 3600 )
		if(xiaoshi > 0) then
			result = result .. xiaoshi .. "小时"
		end
		fenzhong = math.floor((effectiveDuration % 3600) / 60)
		if(fenzhong > 0) then
			result = result .. fenzhong .. "分钟"
		end
	end
	return result
end

function TableRunfastLogic:IsCardRecorderState(seatInfo)
	return (seatInfo.effectiveDuration and seatInfo.effectiveDuration > 0)
end



function TableRunfastLogic:IsHave2MustPressA()
	--print("====有2必压A")
	local CurRuleTable = self.modelData.curTableData.roomInfo.CurRuleTable
	if(CurRuleTable) then
		if(CurRuleTable.allow_pass) then
			return CurRuleTable.have2mustpressA
		end
	else
		print("error====没有创建房间的规则信息,请检查")
	end
	return false
end

function TableRunfastLogic:GetHeiTao2RepresentativeNum()
	--print("====获取黑桃2代表的数字")
	return 5
end

function TableRunfastLogic:IsMyHandHasHeiTao2()
	local myHandPokerNumTable = self.modelData.curTableData.roomInfo.mySeatInfo.InMyHandPokerNumTable
	return self.TableRunfastHelper:IsNumTableContains(myHandPokerNumTable,self:GetHeiTao2RepresentativeNum())
end

function TableRunfastLogic:IsOtherThrowSingleA()
	--print("====别人是否打了单张A")
	local pokerNumTable = self.modelData.curTableData.roomInfo.curPokerTable--别人打的牌
	if(pokerNumTable and #pokerNumTable == 1) then
		local Num = pokerNumTable[1]
		local poker = self.TableRunfastHelper:NumberToPokerTable(Num)
		return poker.nameNum == 1
	end
	return false
end

function TableRunfastLogic:CheckHave2MustPressA()
	if(self:IsHave2MustPressA()) then --检查是否勾选了规则
		if(self:IsMyHandHasHeiTao2()) then --检查自己手上是否有2
			if(self:IsOtherThrowSingleA()) then --检查别人是否打了一张A
				return true
			end
		end
	end
	return false
end



return TableRunfastLogic