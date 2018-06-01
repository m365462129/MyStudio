
local class = require("lib.middleclass")
local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic_guangdong_tongbi")
--- @class TableDouNiuLogic_GuangDong_TongBi_GoldCoin:TableDouNiuLogic_GuangDong_TongBi
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_GuangDong_TongBi_GoldCoin = class('TableDouNiuLogic_GuangDong_TongBi_GoldCoin', TableDouNiuLogic)
local TableDouNiuLogic_GoldCoin = require("package/cowboy/module/table/table_douniu_logic_goldcoin")

function TableDouNiuLogic_GuangDong_TongBi_GoldCoin :initialize(...)
    self.parentClass = TableDouNiuLogic
    TableDouNiuLogic_GoldCoin.initialize(self, ...)
end

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.initTableSeatData = TableDouNiuLogic_GoldCoin.initTableSeatData

--同步消息
TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_table_synchronize_notify = TableDouNiuLogic_GoldCoin.on_table_synchronize_notify

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_table_start_notify = TableDouNiuLogic_GoldCoin.on_table_start_notify

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_table_ago_settle_accounts_notify = TableDouNiuLogic_GoldCoin.on_table_ago_settle_accounts_notify

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_table_settleAccounts_Notify = TableDouNiuLogic_GoldCoin.on_table_settleAccounts_Notify


function TableDouNiuLogic_GuangDong_TongBi_GoldCoin:table_settle_effect(resultList, onFinish)
    self.is_received_reset_notify = false
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    local mySeatInfo = roomInfo.mySeatInfo
    local lastShowSeatInfo
    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, seatInfoList)
        if(seatInfo.playerId ~= '0' and seatInfo.playerId ~= 0)then
            lastShowSeatInfo = seatInfo
            break
        end
    end
    local loseSeatList = {}
    local winSeat
    local lastShowSeatIndex = lastShowSeatInfo.seatIndex
    local tmpList = {}
    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, seatInfoList)
        seatInfo.localOffsetBanker = self.tableHelper:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, lastShowSeatIndex, self.seatCount)
        if(seatInfo == lastShowSeatInfo)then

        else
            table.insert(tmpList, seatInfo)
        end
        local score = seatInfo.curRound.score
        if(score > 0)then
            winSeat = seatInfo
        elseif(score < 0)then
            table.insert(loseSeatList, seatInfo)
        end
    end
    table.sort(tmpList, function (t1,t2)
        return t1.localOffsetBanker > t2.localOffsetBanker
    end)
    table.insert(tmpList, lastShowSeatInfo)

    local playRoundResultScoreEffect = function()
        for i = 1, #resultList do
            local result = resultList[i]
            local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, seatInfoList)
            local score = result.score
            self:playRoundResultScore(seatInfo, score)
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
        playGoldFlyEffect(loseSeatList, winSeat, true,function ()
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
            self.tableView:refreshSeat(seatInfo, true, (not seatInfo.isDoneComputeNiu) and seatInfo ~= mySeatInfo)
            if (niuName == "cow10" or niuName == "silvercow") then
                -- 播放牛牛动画
                self.tableView:showNiuNiuEffect(seatInfo, true, 0.5, 1, 0, function()
                    if (mySeatInfo.isReady) then
                        -- 已经点击了继续按钮
                        -- 显示牛名
                        self.tableView:showNiuName(seatInfo, false, niuName)
                    else
                        -- 显示牛名
                        self.tableView:showNiuName(seatInfo, true, niuName)
                    end

                end )
            else
                -- 显示牛名
                self.tableView:showNiuName(seatInfo, true, niuName)
            end
            local isFemale =(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1)
            self.tableHelper:playNiuNameSound(niuName, isFemale)
        else
            self.tableView:refreshSeat(seatInfo, true, false)
        end

        if (seatInfo == mySeatInfo) then
            if(score > 0)then
                self.tableHelper:playResultSound(true, score > 0)
            end
        end
        finishCount = finishCount + 1
        if(totalCount == finishCount)then
            -- 重置数据
            self:resetRoundState()
            self.tableModule:subscibe_time_event(2, false, 0):OnComplete(function(t)
                on_finish_show_result()
            end)
        end
    end

end

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.check_need_ready_fun = TableDouNiuLogic_GoldCoin.check_need_ready_fun

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_click_goldcoin_bet_btn = TableDouNiuLogic_GoldCoin.on_click_goldcoin_bet_btn

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_click_setting_btn = TableDouNiuLogic_GoldCoin.on_click_setting_btn

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.getDefaultBetScore = TableDouNiuLogic_GoldCoin.getDefaultBetScore

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_table_ready_rsp = TableDouNiuLogic_GoldCoin.on_table_ready_rsp

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.startContinueBtn = TableDouNiuLogic_GoldCoin.startContinueBtn

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.startWaitContinue = TableDouNiuLogic_GoldCoin.startWaitContinue

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.getCanQiangZhuangScoreList = TableDouNiuLogic_GoldCoin.getCanQiangZhuangScoreList

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.getCanXiaZhuScoreList = TableDouNiuLogic_GoldCoin.getCanXiaZhuScoreList

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_reset_notify = TableDouNiuLogic_GoldCoin.on_reset_notify

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.getMaxQiangZhuangBeiShu = TableDouNiuLogic_GoldCoin.getMaxQiangZhuangBeiShu

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_click_goldcoin_exit_btn = TableDouNiuLogic_GoldCoin.on_click_goldcoin_exit_btn

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.on_click_wanfashuoming_btn = TableDouNiuLogic_GoldCoin.on_click_wanfashuoming_btn

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.can_invite_wechat_friend = TableDouNiuLogic_GoldCoin.can_invite_wechat_friend

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.get_max_paixing_beishu = TableDouNiuLogic_GoldCoin.get_max_paixing_beishu

TableDouNiuLogic_GuangDong_TongBi_GoldCoin.playCoinFlySound = TableDouNiuLogic_GoldCoin.playCoinFlySound

return TableDouNiuLogic_GuangDong_TongBi_GoldCoin