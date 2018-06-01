
local class = require("lib.middleclass")
local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic")
--- @class TableDouNiuLogic_GuangDong:TableDouNiuLogic
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_GuangDong = class('tableDouNiuLogic_GuangDong', TableDouNiuLogic)
local CSmartTimer = ModuleCache.SmartTimer.instance

function TableDouNiuLogic_GuangDong :initialize(...)
	TableDouNiuLogic.initialize(self, ...)	
end

function TableDouNiuLogic_GuangDong:initTableSeatData(data)
	TableDouNiuLogic.initTableSeatData(self, data)
	self.isAutoSelectNiu = false
	self.tableView.toggleAutoSelectNiu.isOn = false
end


-- 发牌通知
function TableDouNiuLogic_GuangDong:on_table_fapai_notify(data)
    local pokers = data.pokers
    local roomInfo = self.modelData.curTableData.roomInfo
    roomInfo.state = 100
    local mySeatInfo = roomInfo.mySeatInfo
    mySeatInfo.inHandPokerList = { }
    -- 填充手牌信息
    for i = 1, #pokers do
        local poker = { }
        poker.colour = pokers[i].colour
        poker.number = pokers[i].number
        table.insert(mySeatInfo.inHandPokerList, poker)
    end

    -- 给其他玩家手牌填充假的数据
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local tmpSeatList = {}
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            table.insert(tmpSeatList, seatInfo)
            if (seatInfo ~= mySeatInfo) then
                seatInfo.inHandPokerList = { }
                for j = 1, #pokers do
                    local poker = { }
                    poker.colour = "S"
                    poker.number = "A"
                    table.insert(seatInfo.inHandPokerList, poker)
                end
            end
            if (seatInfo.betScore == 0) then
                seatInfo.betScore = self:getDefaultBetScore()
            end
            -- 显示玩家的手牌
            seatInfo.isBetting = false
        end
    end

    table.sort(tmpSeatList, function(t1, t2)
        return t1.seatIndex > t2.seatIndex
    end)

    self.is_playing_fapai = true
    local onFinishFaPai = function()
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
            self.tableView:refreshSeat(seatInfo, false)
            local onFinish = function()
                roomInfo.state = self.RoomState.waitResult
                if (seatInfo == mySeatInfo) then
                    self.tableView:refreshSeatCardsSelect(mySeatInfo)
                    -- 隐藏下注按钮
                    self:refreshMyTableViewState()
                end
                finishCount = finishCount + 1
                if(finishCount == count)then
                    onFinishFaPai()
                end
            end
            self:playFaPaiAnim(seatInfo, onFinish, #self:get_all_seated_ready_seats())
        end)
    end

    -- 隐藏tips
    self.tableView:showCenterTips(false)

    -- 刷新选牛数字
    self.tableView:refreshSelectedNiuNumbers()

end

--设置庄家通知
function TableDouNiuLogic_GuangDong:on_table_setbanker_notify(data)
	TableDouNiuLogic.on_table_setbanker_notify(self, data)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		----print(seatInfoList[i].playerId, seatInfoList[i].isBanker)
		if(seatInfoList[i].isBanker)then
			seatInfoList[i].isBetting = false
		else
			seatInfoList[i].isBetting = true
		end
		self.tableView:refreshSeatState(seatInfoList[i])		
	end
end

-- 单局结算通知
function TableDouNiuLogic_GuangDong:on_table_settleAccounts_Notify(data)
	TableDouNiuLogic.on_table_settleAccounts_Notify(self, data)
	self.tableView:showAutoSelectToggleBtn(true)
end

function TableDouNiuLogic_GuangDong:refreshMyTableViewState()
	TableDouNiuLogic.refreshMyTableViewState(self)
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

function TableDouNiuLogic_GuangDong:getDefaultBetScore()
    local list = self:getCanXiaZhuScoreList()
	if(list and #list > 0)then
		return list[1]
	else
		return 0
	end
end

--点击自动选牛
function TableDouNiuLogic:onclick_autoselectniu_toggle(obj)
	self.isAutoSelectNiu = self.tableView.toggleAutoSelectNiu.isOn
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	local isWaitXuanNiu = (not mySeatInfo.isDoneComputeNiu) and roomInfo.state == self.RoomState.waitResult
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

--点击下注按钮
function TableDouNiuLogic_GuangDong:on_click_bet_btn(obj, arg)
    if (obj == self.tableView.buttonBet1.gameObject) then
        self.selectedBetScore = 1
    elseif (obj == self.tableView.buttonBet2.gameObject) then
        self.selectedBetScore = 2
    elseif (obj == self.tableView.buttonBet3.gameObject) then
        self.selectedBetScore = 3
    elseif (obj == self.tableView.buttonBet4.gameObject) then
        self.selectedBetScore = 4
    elseif (obj == self.tableView.buttonBet5.gameObject) then
        self.selectedBetScore = 5
    elseif (obj == self.tableView.buttonBet6.gameObject) then
        self.selectedBetScore = 6
	elseif (obj == self.tableView.buttonBet7.gameObject) then
        self.selectedBetScore = 7
	elseif (obj == self.tableView.buttonBet8.gameObject) then
        self.selectedBetScore = 8
    elseif (obj == self.tableView.buttonBet9.gameObject) then
        self.selectedBetScore = 9
    elseif (obj == self.tableView.buttonBet10.gameObject) then
        self.selectedBetScore = 10
	else
		return
    end
	self.tableModel:request_bet_custom(self.selectedBetScore)
end

function TableDouNiuLogic_GuangDong:startWaitContinue()
    if (self.waitReadyTimeEventId) then
        CSmartTimer:Kill(self.waitReadyTimeEventId)
        self.waitReadyTimeEventId = nil
    end
    local duration = 3
    self.continueShowStartTime = Time.realtimeSinceStartup
    self.tableView:refreshContinueTimeLimitText(duration)
    local timeEvent = self.tableModule:subscibe_time_event(duration, false, 0):OnComplete( function(t)
        if(not self.tableModule.is_freeing_room)then
            -- self.tableModel:request_ready()
        end
    end ):SetIntervalTime(0.05, function(t)
        local leftSecs = math.ceil(self.continueShowStartTime + duration - Time.realtimeSinceStartup)
        leftSecs = math.max(leftSecs, 0)
        self.tableView:refreshContinueTimeLimitText(leftSecs)
    end )
    self.waitReadyTimeEventId = timeEvent.id;
end

function TableDouNiuLogic_GuangDong:on_pre_share_room_num()
    local roomInfo = self.modelData.curTableData.roomInfo
    local curPlayerCount = self.tableHelper:getSeatedSeatCount(roomInfo.seatInfoList)
    self.tableModule:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, roomInfo.ruleTable.halfEnter, curPlayerCount)
end

return TableDouNiuLogic_GuangDong