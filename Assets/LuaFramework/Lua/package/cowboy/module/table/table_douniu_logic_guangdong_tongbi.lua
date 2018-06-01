
local class = require("lib.middleclass")
local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic_guangdong")
--- @class TableDouNiuLogic_GuangDong_TongBi:TableDouNiuLogic_GuangDong
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_GuangDong_TongBi = class('tableDouNiuLogic_GuangDong_TongBi', TableDouNiuLogic)
local CSmartTimer = ModuleCache.SmartTimer.instance

function TableDouNiuLogic_GuangDong_TongBi :initialize(...)
	TableDouNiuLogic.initialize(self, ...)	
end

function TableDouNiuLogic_GuangDong_TongBi:initTableSeatData(data)
	TableDouNiuLogic.initTableSeatData(self, data)
	self.isAutoSelectNiu = false
	self.tableView.toggleAutoSelectNiu.isOn = false
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        -- 判断是否下注中状态
        seatInfo.isBetting = false
    end
end

--开始通知
function TableDouNiuLogic_GuangDong_TongBi:on_table_start_notify(data)
	TableDouNiuLogic.on_table_start_notify(self, data)
	local roomInfo = self.modelData.curTableData.roomInfo
	roomInfo.roundStarted = true
	roomInfo.state = self.RoomState.waitFaPai
	self.tableView:refreshSeat(self.modelData.curTableData.roomInfo.mySeatInfo, true)
	--隐藏下注按钮
	self.tableView:showBetBtns(false)
end

-- 发牌通知
function TableDouNiuLogic_GuangDong_TongBi:on_table_fapai_notify(data)
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
function TableDouNiuLogic_GuangDong_TongBi:on_table_setbanker_notify(data)

end

function TableDouNiuLogic_GuangDong_TongBi:getDefaultBetScore()
    return 0
end

function TableDouNiuLogic_GuangDong_TongBi:on_pre_share_room_num()
    local roomInfo = self.modelData.curTableData.roomInfo
    local curPlayerCount = self.tableHelper:getSeatedSeatCount(roomInfo.seatInfoList)
    self.tableModule:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, roomInfo.ruleTable.halfEnter, curPlayerCount)
end

return TableDouNiuLogic_GuangDong_TongBi