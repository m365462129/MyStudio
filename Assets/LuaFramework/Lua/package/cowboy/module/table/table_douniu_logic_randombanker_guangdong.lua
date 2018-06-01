
local class = require("lib.middleclass")
local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic_guangdong")
--- @class TableDouNiuLogic_RandomBanker_GuangDong:TableDouNiuLogic_GuangDong
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_RandomBanker_GuangDong = class('tableDouNiuLogic_RandomBanker_GuangDong', TableDouNiuLogic)
local CSmartTimer = ModuleCache.SmartTimer.instance


function TableDouNiuLogic_RandomBanker_GuangDong :initialize(...)
	TableDouNiuLogic.initialize(self, ...)
end

function TableDouNiuLogic_RandomBanker_GuangDong:update()

    if (not self.modelData.curTableData or(not self.modelData.curTableData.roomInfo)) then
        return
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if (roomInfo.state == self.RoomState.waitBet) then
        self.tableView:refreshClock(mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    elseif (roomInfo.state == self.RoomState.waitResult) then
        self.tableView:refreshClock(mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    else
        self.tableView:refreshClock(mySeatInfo, false)
    end
end

-- 开始广播
function TableDouNiuLogic_RandomBanker_GuangDong:on_table_start_notify(data)
	TableDouNiuLogic.on_table_start_notify(self, data)
    if(data.err_no and data.err_no ~= '0')then
        return
    end
	-- 标识已开始当前局
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.state = self.RoomState.waitSetBanker
end

--设置庄家通知
function TableDouNiuLogic_RandomBanker_GuangDong:on_table_setbanker_notify(data)
	-- 标识已开始当前局
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.roundStarted = true

	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	local randomSeatInfoList = {}
	for i=1,#seatInfoList do
		seatInfoList[i].isBanker = false
		self.tableView:refreshSeatInfo(seatInfoList[i])	

		if(seatInfoList[i].isSeated and seatInfoList[i].isReady)then
			table.insert( randomSeatInfoList, seatInfoList[i])
		end
	end

	for i=1,#randomSeatInfoList do
		if(randomSeatInfoList[i].isBanker)then
			randomSeatInfoList[i].isBetting = false
		else
			randomSeatInfoList[i].isBetting = true
		end
	end

	self:showSeatsRandomEffect(randomSeatInfoList, false)
	self.tableView:showBetBtns(false)	

	local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, roomInfo.seatInfoList)
	seatInfo.isBanker = true
	seatInfo.isBetting = false
	local onFinishRandomBanker = function()
		roomInfo.state = self.RoomState.waitBet
		local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
		self.tableHelper:playSetTargetSeatAsBanker(seatHolder, function()
			self.tableView:refreshSeatInfo(seatInfo)
			self:refreshMyTableViewState()

			for i=1,#randomSeatInfoList do
				self.tableView:refreshSeatState(randomSeatInfoList[i])
			end
		end)


	end
	if(#randomSeatInfoList == 1)then
		onFinishRandomBanker()
	else
		self.tableView:showBetBtns(false)
		self.tableView:showCenterTips(false)
		self:showSeatsRandomBankerEffect(randomSeatInfoList, seatInfo, function()
			self:showSeatsRandomEffect(randomSeatInfoList, false)
			self:showSeatRandomEffect(seatInfo, true)
			onFinishRandomBanker()
		end)
	end
end

function TableDouNiuLogic_RandomBanker_GuangDong:on_pre_share_room_num()
	local roomInfo = self.modelData.curTableData.roomInfo
	local curPlayerCount = self.tableHelper:getSeatedSeatCount(roomInfo.seatInfoList)
	self.tableModule:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, roomInfo.ruleTable.halfEnter, curPlayerCount)
end

return TableDouNiuLogic_RandomBanker_GuangDong