
local class = require("lib.middleclass")
---@class TableZhaJinNiuLogic
---@field tableView TableView_ZhaJinNiu
---@field tableModule TableModule_ZhaJinNiu
---@field tableModel TableModel_ZhaJinNiu
local TableZhaJinNiuLogic = class('TableZhaJinNiuLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance

local TableManagerPoker = TableManagerPoker


local RoomState = { }
RoomState.waitReady = 0			-- 等待玩家准备状态
RoomState.waitSetBanker = 1		-- 等待定庄状态
RoomState.waitBet = 2			-- 等待下注状态
RoomState.waitResult = 3		-- 等待结算状态

local SeatPlayState = { }
SeatPlayState.hasNotCheck = 1	-- 未看牌
SeatPlayState.hasCheck = 2		-- 已看牌
SeatPlayState.hasDrop = 3		-- 已弃牌
SeatPlayState.compareFail = 4	-- 比牌失败

function TableZhaJinNiuLogic:initialize(module)
    self.tableModule = module
    self.modelData = module.modelData
    self.tableView = self.tableModule.tableView
    self.tableModel = self.tableModule.tableModel
    self.tableHelper = self.tableModule.tableHelper
    self.SeatPlayState = SeatPlayState

    self:resetSeatHolderArray(6)
    self.RoomState = RoomState
end

function TableZhaJinNiuLogic:on_show()

end

function TableZhaJinNiuLogic:on_hide()

end

function TableZhaJinNiuLogic:update()

    if (not self.modelData.curTableData or(not self.modelData.curTableData.roomInfo)) then
        return
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

end

function TableZhaJinNiuLogic:on_destroy()
    self.showResultViewSmartTimer_id = nil

end


-- 进入房间回包
function TableZhaJinNiuLogic:on_table_enter_rsp(data)

end

-- 进入房间广播
function TableZhaJinNiuLogic:on_table_enter_notify(data)
    local posInfo = data.pos_info
    local seatInfo = self.tableHelper:getSeatInfoByRemoteSeatIndex(posInfo.pos_index, self.modelData.curTableData.roomInfo.seatInfoList)
    seatInfo.playerId = tostring(posInfo.player_id)
    seatInfo.isSeated = self:getBoolState(posInfo.player_id)
    -- 判断座位上是否有玩家
    seatInfo.isReady = self:getBoolState(posInfo.is_ready)
    -- 是否已准备
    if (self:getBoolState(posInfo.player_id)) then
        -- 判断是否玩家自己，单独记录自己的座位
        if (seatInfo.playerId == self.modelData.curTablePlayerId) then
            self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo
            seatInfo.isOffline = false
        end
    end
    self.tableModule:addSeatInfo2ChatCurTableData(seatInfo)
    self.tableView:refreshSeat(seatInfo, seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo)
end

-- 离开房间回包
function TableZhaJinNiuLogic:on_table_leave_rsp(data)
    -- print("on_table_leave_rsp-----------")
end

-- 离开房间广播
function TableZhaJinNiuLogic:on_table_leave_notify(data)
    -- print("on_table_leave_notify-----------")
end

-- 解散房间回包
function TableZhaJinNiuLogic:on_table_dissolve_rsp(data)
    -- print("on_table_dissolve_rsp-----------")
end

-- 解散房间广播
function TableZhaJinNiuLogic:on_table_dissolve_notify(data)
    -- print("on_table_dissolve_notify-----------")
end

-- 同步消息包
function TableZhaJinNiuLogic:on_table_synchronize_notify(data)
    if (self.tableView.goldList and #self.tableView.goldList > 0) then
        for i = 1, #self.tableView.goldList do
            local goGold = self.tableView.goldList[i]
            UnityEngine.GameObject.Destroy(goGold)
        end
        self.tableView.goldList = { }
    end
    self:initTableSeatData(data)

    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

    local showPokerTableFrameData = {
        roomNumber=roomInfo.roomNum,
        rule = roomInfo.rule,
        show_location_btn = false,
    }
    if(self.modelData.tableCommonData.isGoldTable)then
        showPokerTableFrameData.show_shop_btn = true
    else
        showPokerTableFrameData.show_shop_btn = false
    end
    self.pokerTableFrameModule = ModuleCache.ModuleManager.show_module("public", "pokertableframe", showPokerTableFrameData)
    self.pokerTableFrameModule:check_activity_is_open()

    -- 刷新房间信息显示
    self.tableView:setRoomInfo(roomInfo)

    -- 刷新每个座位状态的显示
    local seatList = roomInfo.seatInfoList
    for i = 1, #seatList do
        seatList[i].inHandPokerList = seatList[i].inHandPokerList or { }
        self.tableView:refreshSeat(seatList[i])
        if (roomInfo.curSpeakingPlayerId and roomInfo.curSpeakingPlayerId ~= 0 and seatList[i].isSeated and seatList[i].isReady) then
            self.tableView:showSeatCostGold(seatList[i], true)
        end
    end
    -- 隐藏tips
    self.tableView:showCenterTips(false)

    -- 刷新玩家自己桌面
    self:refreshMyTableViewState()

    -- local showReadyBtn = (not mySeatInfo.isReady) and (roomInfo.state == self.RoomState.waitReady)
    -- self.tableView:showReadyBtn(showReadyBtn)	

    if mySeatInfo.isReady == false then
        -- 自动准备
        ----0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
        self:onclick_ready_btn();
        if self.modelData.roleData.RoomType ~= 2 then

        else
            --self.tableView.buttonReady_fastStart.gameObject:SetActive(self.modelData.curTableData.roomInfo.curRoundNum == 0)
        end
    end

    if roomInfo.curRoundNum == 0 then
        -- 刷新准备状态
        self.tableView:refreshReadyState(mySeatInfo.isCreator);
    else
        -- 隐藏所有选择按钮
        self.tableView:hideAllReadyButton();
    end

    local roomInfo = self.modelData.curTableData.roomInfo
    if (roomInfo.state == RoomState.waitBet or roomInfo.state == RoomState.waitResult) then
        self.tableView:refreshClock(self.modelData.curTableData.roomInfo.mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    end

    -- 如果有人正在说话，说明牌局已经开始
    self.tableView:showBetBtns(false)

    if (roomInfo.curSpeakingPlayerId and roomInfo.curSpeakingPlayerId ~= 0) then
        self.tableView:showCurRoundBetScore(true, roomInfo.curRoundBetScore)
        if (mySeatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop or mySeatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail or(not mySeatInfo.isReady)) then
            self.tableView:showZhaJinNiuBtns(false)
        else
            self.tableView:showZhaJinNiuBtns(true)

        end

        self:onSeatSpeaking()

        -- 给其他玩家手牌填充假的数据
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            if (seatInfo.isSeated and seatInfo.isReady) then
                -- 显示玩家的手牌
                self.tableView:refreshSeat(seatInfo, false)


                if (seatInfo == mySeatInfo) then
                    -- 显示玩家手牌
                    self.tableView:showInHandCards(seatInfo, true)
                    --self.tableView:refreshSeatPlayState(mySeatInfo, true)
                    local show = seatInfo.zhaJinNiu_state ~= self.SeatPlayState.hasNotCheck
                    self.tableView:refreshInHandCards(seatInfo, show, false)
                    -- 显示牛名
                    self.tableView:showNiuName(mySeatInfo, show, mySeatInfo.combo_type, seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail or seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop)
                    if(seatInfo.zhaJinNiu_state == SeatPlayState.hasDrop)then
                        self.tableView:showSeatCostGold(seatInfo, false)
                    elseif(seatInfo.zhaJinNiu_state == SeatPlayState.compareFail)then
                        self.tableView:showSeatCostGold(seatInfo, false)
                    end
                else
                    if(seatInfo.zhaJinNiu_state == SeatPlayState.hasDrop)then
                        self.tableView:showInHandCards(seatInfo, false)
                        self.tableView:showSeatCostGold(seatInfo, false)
                    elseif(seatInfo.zhaJinNiu_state == SeatPlayState.compareFail)then
                        self.tableView:showInHandCards(seatInfo, false)
                        self.tableView:showSeatCostGold(seatInfo, false)
                    else
                        -- 显示玩家手牌
                        self.tableView:showInHandCards(seatInfo, true)
                        self.tableView:refreshInHandCards(seatInfo, false, false)
                    end

                end
            end

        end
    else
        self.tableView:showCurRoundBetScore(false)
        self.tableView:showZhaJinNiuBtns(false)
    end

    -- 初始化金币堆
    self.tableView:genGoldHeap(roomInfo.curRoundBetScoreList, roomInfo.ruleTable.baseScore or 1)

end 

function TableZhaJinNiuLogic:onlyShowFollowAlwaysBtn()
    local roomInfo = self.modelData.curTableData.roomInfo
    -- 比牌按钮
    self.tableView:showComparePokersButton(false, false)
    self.tableView:showFollowAlwaysButton(true)

    self.tableView:showFollowButton(false, false)
    self.tableView:showRaiseButton(false, false)
    self.tableView:showMoreBtns(false, false)
    self.tableView:showBetBtns(false)
    self.tableView:refreshBetBtns(roomInfo.canBetScoreList, roomInfo.ruleTable.baseScore or 1, self:get_original_bet_list())
    self.tableView:showDropPokersButton(true, true)
end


-- 上一局的结算通知
function TableZhaJinNiuLogic:on_table_zhajinniu_ago_settle_accounts_notify(data)
    local resultList = data.zhaJinNiu_settleAccounts
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if (mySeatInfo.isReady) then
        return
    end
    roomInfo.state = RoomState.waitReady
    local tmpTable = {}
    local tmpResultSeatList = {}
    local winnerSeatInfo
    local winScore
    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        table.insert(tmpResultSeatList, seatInfo)
        seatInfo.curRound = { }
        seatInfo.curRound.score = result.winScore
        tmpTable[seatInfo.playerId] = result.winScore
        if (result.isWinner) then
            winnerSeatInfo = seatInfo
            winScore = result.winScore
        end

        seatInfo.zhaJinNiu_state = result.zhaJinNiu_state
        seatInfo.isCalculatedResult = true
        if (result.needShowPokers) then
            seatInfo.curRound.niuName = result.combo_type
            seatInfo.inHandPokerList = { }
            local pokerList = result.pokers
            for i = 1, #pokerList do
                local poker = { }
                poker.colour = pokerList[i].colour
                poker.number = pokerList[i].number
                table.insert(seatInfo.inHandPokerList, poker)
            end
            -- 展示玩家手牌	
            self.tableView:showInHandCards(seatInfo, true)
            self.tableView:refreshInHandCards(seatInfo, true, false)


            local niuName = seatInfo.curRound.niuName
            -- 显示牛名
            self.tableView:showNiuName(seatInfo, true, niuName, seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail or seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop)

        else
            seatInfo.inHandPokerList = { }
            for i = 1, 5 do
                local poker = { }
                poker.colour = "S"
                poker.number = "3"
                table.insert(seatInfo.inHandPokerList, poker)
            end
            -- 显示背面
            self.tableView:showInHandCards(seatInfo, false)
            --self.tableView:refreshInHandCards(seatInfo, false, false)
        end
        seatInfo.curRound = nil
        self.tableView:refreshSeat(seatInfo)

        if (result.needShowPokers) then
            self.tableView:refreshSeatPlayState(seatInfo, seatInfo ~= mySeatInfo)
        else
            self.tableView:refreshSeatPlayState(seatInfo)
        end
        if(seatInfo ~= mySeatInfo)then
            self.tableView:showSeatCostGold(seatInfo, false)
        else
            self.tableView:showSeatCostGold(seatInfo, true)
        end
    end


    self:refreshMyTableViewState()
    -- 显示继续按钮
    -- self.tableView:showReadyBtn(false)
    self.tableView:showContinueBtn(true)
    self:startWaitContinue()
    -- 初始化金币堆
    self.tableView:genGoldHeap(data.curRoundBetScoreList, roomInfo.ruleTable.baseScore or 1)
    -- 刷新第几轮
    roomInfo.curBetRoundNum = data.curBetRoundNum
    self.tableView:setRoomInfo(roomInfo)
    roomInfo.curBetRoundNum = 0

    self.tableView:showZhaJinNiuBtns(false)
    self:hideAllSeatSpeakingTimeLimitEffect()

    self.tableModule:subscibe_time_event(1, false, 0):OnComplete( function(t)
        self:playCoinFlySound()
        self.tableView:goldFlyToSeat(winnerSeatInfo, function()
            -- 播放分数动画
            for i, v in pairs(tmpResultSeatList) do
                local score = tmpTable[v.playerId]
                self.tableView:showSeatRoundScoreAnim(v, true, score)
            end
        end )
    end)
end

-- 结算通知
function TableZhaJinNiuLogic:on_table_zhajinniu_settle_accounts_notify(data)
    if (self.isPlayingComparePoker) then
        self.delayInvoke_on_table_zhajinniu_settle_accounts_notify = function()
            self:on_table_zhajinniu_settle_accounts_notify(data)
        end
        return
    end

    local resultList = data.zhaJinNiu_settleAccounts
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

    roomInfo.state = RoomState.waitReady
    local tmpTable = {}
    local tmpResultSeatList = {}
    local winnerSeatInfo
    local winScore
    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        table.insert(tmpResultSeatList, seatInfo)
        seatInfo.curRound = { }
        seatInfo.curRound.score = result.winScore
        tmpTable[seatInfo.playerId] = result.winScore
        if (result.isWinner) then
            winnerSeatInfo = seatInfo
            seatInfo.curRound.score = result.winScore
            winScore = result.winScore
        end
        seatInfo.score = result.score
        seatInfo.zhaJinNiu_state = result.zhaJinNiu_state
        seatInfo.isCalculatedResult = true
        if (result.needShowPokers) then
            seatInfo.curRound.niuName = result.combo_type
            seatInfo.inHandPokerList = { }
            local pokerList = result.pokers
            for i = 1, #pokerList do
                local poker = { }
                poker.colour = pokerList[i].colour
                poker.number = pokerList[i].number
                table.insert(seatInfo.inHandPokerList, poker)
            end
            -- 展示玩家手牌
            self.tableView:showInHandCards(seatInfo, true)
            self.tableView:refreshInHandCards(seatInfo, true, false)


            local niuName = seatInfo.curRound.niuName
            -- 显示牛名
            self.tableView:showNiuName(seatInfo, true, niuName, seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail or seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop)
        else
            seatInfo.inHandPokerList = { }
            for i = 1, 5 do
                local poker = { }
                poker.colour = "S"
                poker.number = "3"
                table.insert(seatInfo.inHandPokerList, poker)
            end
            -- 显示背面
            self.tableView:showInHandCards(seatInfo, false)
            self.tableView:refreshInHandCards(seatInfo, false, false)
        end

        self.tableView:refreshSeat(seatInfo)
        if (result.needShowPokers) then
            self.tableView:refreshSeatPlayState(seatInfo, seatInfo ~= mySeatInfo)
        else
            self.tableView:refreshSeatPlayState(seatInfo)
        end
        if(seatInfo ~= mySeatInfo)then
            self.tableView:showSeatCostGold(seatInfo, false)
        else
            self.tableView:showSeatCostGold(seatInfo, true)
        end
    end

    -- 重置数据
    self:resetRoundState()

    self:refreshMyTableViewState()
    -- 显示继续按钮
    -- self.tableView:showReadyBtn(false)
    self.tableView:showContinueBtn(true)
    self:startWaitContinue()

    self.tableView:showZhaJinNiuBtns(false)
    self:hideAllSeatSpeakingTimeLimitEffect()

    self.tableModule:subscibe_time_event(1, false, 0):OnComplete( function(t)
        self:playWinnerSound()
        self.tableView:playSeatWinAnim(winnerSeatInfo.localSeatIndex)
        self:playCoinFlySound()
        self.tableView:goldFlyToSeat(winnerSeatInfo, function()
            -- 播放分数动画
            self:playPiaoShuZiSound()
            for i, v in pairs(tmpResultSeatList) do
                local score = tmpTable[v.playerId]
                self.tableView:showSeatRoundScoreAnim(v, true, score)
            end
        end )
    end )
end

-- 准备回包
function TableZhaJinNiuLogic:on_table_ready_rsp(data)
    if (data.err_no == "0") then
        local roomInfo = self.modelData.curTableData.roomInfo
        local mySeatInfo = roomInfo.mySeatInfo
        mySeatInfo.isReady = true
        self:refreshResetState()
        self:refreshMyTableViewState()
        self.tableView:showCurRoundBetScore(false)

        -- self.tableView:showReadyBtn(false)	

        self.tableView:showContinueBtn(false)
        for i = 1, #roomInfo.seatInfoList do
            local seatInfo = roomInfo.seatInfoList[i]
            self.tableView:showSeatCostGold(seatInfo, false)
            self.tableView:showInHandCards(seatInfo, false)
            self.tableView:refreshSeat(seatInfo)
        end

    else

    end
end

-- 准备广播
function TableZhaJinNiuLogic:on_table_ready_notify(data)
    local posInfo = data.pos_info
    local seatInfo = self.tableHelper:getSeatInfoByRemoteSeatIndex(posInfo.pos_index, self.modelData.curTableData.roomInfo.seatInfoList)
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    seatInfo.isReady = posInfo.is_ready ~= 0

    -- 判断当前牌桌的状态,是否可以开局		
    self:refreshMyTableViewState()
    self.tableView:refreshSeatState(seatInfo)


end

-- 开始回包
function TableZhaJinNiuLogic:on_table_start_rsp(data)

end

-- 开始广播
function TableZhaJinNiuLogic:on_table_start_notify(data)
    if(self.pokerTableFrameModule)then
        self.pokerTableFrameModule:check_activity_is_open()
    end

    self:hide_start_btn()
    -- 标识已开始当前局
    local roomInfo = self.modelData.curTableData.roomInfo
    roomInfo.roundStarted = true
    roomInfo.curRoundBetScore = 0
    roomInfo.state = RoomState.waitBet
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            seatInfo.curRound = { }
            seatInfo.isBetting = false
            seatInfo.zhaJinNiu_betScore = 1
            seatInfo.score = seatInfo.score - seatInfo.zhaJinNiu_betScore
            seatInfo.zhaJinNiu_state = self.SeatPlayState.hasNotCheck
            self.tableView:refreshSeat(seatInfo, false)
            roomInfo.curRoundBetScore = roomInfo.curRoundBetScore + seatInfo.zhaJinNiu_betScore
            self.tableView:goldFlyToGoldHeapFromSeat(seatInfo, seatInfo.zhaJinNiu_betScore, roomInfo.ruleTable.baseScore or 1)
            self:playCoinChangeSound()
        end

    end
    if(not data.game_loop_cnt or data.game_loop_cnt == 0)then
        roomInfo.curRoundNum = roomInfo.curRoundNum + 1
    else
        roomInfo.curRoundNum = data.game_loop_cnt
    end

    -- 隐藏所有准备按钮
    self.tableView:hideAllReadyButton();

    -- 给其他玩家手牌填充假的数据
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local tmpSeatList = {}
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            table.insert(tmpSeatList, seatInfo)
            seatInfo.combo_type = nil
            seatInfo.inHandPokerList = { }
            for i = 1, 5 do
                local poker = { }
                poker.colour = "S"
                poker.number = "3"
                table.insert(seatInfo.inHandPokerList, poker)
            end

            -- 显示玩家的手牌
            self.tableView:refreshSeat(seatInfo, false)

            self.tableView:showSeatCostGold(seatInfo, true)

        end
        self.tableView:refreshSeat(seatInfo, false)
    end

    table.sort(tmpSeatList, function(t1, t2)
        return t1.seatIndex < t2.seatIndex
    end)

    self.is_playing_fapai = true
    local onFinishFaPai = function()
        -- 显示炸金牛按钮组
        self.tableView:showZhaJinNiuBtns(true)
        if (roomInfo.curSpeakingPlayerId == tonumber(mySeatInfo.playerId)) then
            self:showMySeatSpeaking()
            self:tryShowDropAndCheckBtn()
        else
            self:onlyShowFollowAlwaysBtn()
            self:tryShowDropAndCheckBtn()
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
        self.tableModule:subscibe_time_event(0.1 * (i - 1), false, 0):OnComplete(function()
            self.tableView:refreshSeat(seatInfo, false)
            local onFinish = function()
                finishCount = finishCount + 1
                if(finishCount == count)then
                    onFinishFaPai()
                end
            end
            -- 显示玩家手牌
            self.tableView:showInHandCards(seatInfo, true)
            self.tableView:refreshInHandCards(seatInfo, false, false)
            self:playFaPaiAnim(seatInfo, onFinish, #self:get_all_seated_ready_seats())
        end)
    end


    -- 刷新房间信息显示
    self.tableView:setRoomInfo(roomInfo)
    self.tableView:showCurRoundBetScore(true, roomInfo.curRoundBetScore)
    -- 取消自动跟注
    self.tableView.toggleFollowAlways.isOn = false
    mySeatInfo.isAlwaysFollow = false
end


-- 房间结算通知
function TableZhaJinNiuLogic:on_table_lastsettleAccounts_Notify(data)
    if (self.isPlayingComparePoker) then
        self.delayInvoke_on_table_lastsettleAccounts_Notify = function()
            self:on_table_lastsettleAccounts_Notify(data)
        end
        return
    end

    TableManagerPoker:disconnect_game_server()
    local resultList = { }
    for i = 1, #data.LastSettleAccounts do
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.LastSettleAccounts[i].playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        local result = { }
        result.totalScore = data.LastSettleAccounts[i].score
        result.winTimes = data.LastSettleAccounts[i].win_count
        result.loseTimes = data.LastSettleAccounts[i].lost_count
        result.hasNiuTimes = data.LastSettleAccounts[i].cow_count
        result.noNiuTimes = data.LastSettleAccounts[i].not_cow_count
        result.playerId = data.LastSettleAccounts[i].playerId
        result.isRoomCreator = seatInfo.isCreator
        result.playerInfo = seatInfo.playerInfo
        table.insert(resultList, result)
    end
    self.modelData.curTableData.roomInfo.isRoomEnd = true
    self.modelData.curTableData.roomInfo.roomResultList = resultList
    local delayTime = 5
    if (self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount) then
        delayTime = 5
    else
        delayTime = 1
    end
    self.showResultViewSmartTimer_id = nil
    local timeEvent = nil
    timeEvent = self.tableModule:subscibe_time_event(delayTime, false, 0):OnComplete( function(t)
        ModuleCache.ModuleManager.show_module("cowboy", "tableresult", { resultList = resultList, roomInfo = { roomNum = self.modelData.curTableData.roomInfo.roomNum, tableInfo = self.modelData.curTableData.roomInfo, timestamp = os.time() } })
        self.showResultViewSmartTimer_id = nil
    end ):OnKill( function(t)

    end )
    self.showResultViewSmartTimer_id = timeEvent.id
end



-- 到期时间通知
function TableZhaJinNiuLogic:on_table_expire_time_notify(data)

end

-- 等待玩家说话广播
function TableZhaJinNiuLogic:on_table_waitspeak_notify(data)
    self:hideAllSeatSelectCompare()
    if (self.isPlayingComparePoker) then
        self.delayInvoke_on_table_waitspeak_notify = function()
            self:on_table_waitspeak_notify(data)
        end
        return
    end

    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    roomInfo.curSpeakingPlayerId = data.player_id
    roomInfo.canCompare = data.canCompare
    roomInfo.canBetScoreList = {}
    for i = 1, #data.canBetScoreList do
        roomInfo.canBetScoreList[i] = data.canBetScoreList[i]
    end

    -- 刷新第几轮
    roomInfo.curBetRoundNum = data.curBetRoundNum
    self.tableView:setRoomInfo(roomInfo)

    if (data.player_id == tonumber(mySeatInfo.playerId)) then
        if (mySeatInfo.isAlwaysFollow) then
            self.isDelayAlwaysFollow = true
            self.tableModule:subscibe_time_event(1, false, 0):OnComplete( function(t)
                if (self.isDelayAlwaysFollow and mySeatInfo.isAlwaysFollow) then
                    self.isDelayAlwaysFollow = false
                    self.tableModel:request_call_bet(roomInfo.canBetScoreList[1])
                end

            end )
            -- return
        end
    end
    self:onSeatSpeaking()
end

function TableZhaJinNiuLogic:onSeatSpeaking()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(roomInfo.curSpeakingPlayerId, roomInfo.seatInfoList)
    self:hideAllSeatSpeakingTimeLimitEffect()
    if (seatInfo) then
        self.tableView:showSeatTimeLimitEffect(seatInfo, true, 10, nil, -1)
    end
    if (seatInfo == mySeatInfo) then
        self:playBtnShowSound()
        -- 比牌按钮
        self:showMySeatSpeaking()
        self:tryShowDropAndCheckBtn()
    else
        -- self.tableView:refreshBetBtns(roomInfo.canBetScoreList)
        self:onlyShowFollowAlwaysBtn()
    end
end

function TableZhaJinNiuLogic:showMySeatSpeaking()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local show = not(mySeatInfo.isAlwaysFollow or false)
    self.tableView:showComparePokersButton(true,(roomInfo.canCompare and show) or false)
    self.tableView:showFollowAlwaysButton(true)
    self.tableView:refreshBetBtns(roomInfo.canBetScoreList, roomInfo.ruleTable.baseScore or 1, self:get_original_bet_list())
    self.tableView:showFollowButton(true, show)
    self.tableView:showRaiseButton(true, #roomInfo.canBetScoreList > 1 and show)
    self.tableView:showMoreBtns(true, #roomInfo.canBetScoreList > 1 and show)
    self.tableView:showDropPokersButton(true, true)
end

function TableZhaJinNiuLogic:tryShowDropAndCheckBtn()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    self.tableView:showCheckPokersButton(mySeatInfo.zhaJinNiu_state == self.SeatPlayState.hasNotCheck or false)
end

-- 弃牌返回
function TableZhaJinNiuLogic:on_table_droppokers_rsp(data)
    self:hideAllSeatSelectCompare()
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.zhaJinNiu_state = self.SeatPlayState.hasDrop
    mySeatInfo.combo_type = data.combo_type

    mySeatInfo.inHandPokerList = { }
    -- 填充手牌信息
    for i = 1, #data.pokers do
        local poker = { }
        poker.colour = data.pokers[i].colour
        poker.number = data.pokers[i].number
        table.insert(mySeatInfo.inHandPokerList, poker)
    end

    self.tableView:showInHandCards(mySeatInfo, true)
    self.tableView:refreshInHandCards(mySeatInfo, true, false)
    self.tableView:refreshSeatPlayState(mySeatInfo)
    self.tableView:setInHandCardsMaskColor(mySeatInfo, true)
    self.tableView:showNiuName(mySeatInfo, true, mySeatInfo.combo_type, true)
    -- 播放弃牌音效
    self:playDropPokerSound(mySeatInfo)
    self.tableView:showZhaJinNiuBtns(false)
end

-- 弃牌广播
function TableZhaJinNiuLogic:on_table_droppokers_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, roomInfo.seatInfoList)
    seatInfo.zhaJinNiu_state = self.SeatPlayState.hasDrop
    self.tableView:refreshSeatPlayState(seatInfo)
    --弃牌改为别人看不到自己的牌，但是自己可以看到自己的牌
    if(seatInfo == mySeatInfo)then
        self.tableView:setInHandCardsMaskColor(seatInfo, true)
    else
        self.tableView:showInHandCards(seatInfo, false)
    end
    self.tableView:showSeatCostGold(seatInfo, false)
    -- 播放弃牌音效
    self:playDropPokerSound(seatInfo)
end

-- 看牌返回
function TableZhaJinNiuLogic:on_table_checkpokers_rsp(data)
    self:hideAllSeatSelectCompare()
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.zhaJinNiu_state = self.SeatPlayState.hasCheck
    mySeatInfo.combo_type = data.combo_type

    mySeatInfo.inHandPokerList = { }
    -- 填充手牌信息
    for i = 1, #data.pokers do
        local poker = { }
        poker.colour = data.pokers[i].colour
        poker.number = data.pokers[i].number
        table.insert(mySeatInfo.inHandPokerList, poker)
    end
    self:playKanPaiEffectSound()
    -- 显示牛名
    self.tableView:showNiuName(mySeatInfo, true, mySeatInfo.combo_type)
    self.tableView:showInHandCards(mySeatInfo, true)
    self.tableView:refreshInHandCards(mySeatInfo, true, true)
    self.tableView:refreshSeatPlayState(mySeatInfo)
    self:showMySeatSpeaking()
    self:tryShowDropAndCheckBtn()
    -- 取消自动跟注
    self.tableView.toggleFollowAlways.isOn = false
    mySeatInfo.isAlwaysFollow = false

    -- 播放看牌音效
    self:playCheckPokerSound(mySeatInfo)
end

-- 看牌广播
function TableZhaJinNiuLogic:on_table_checkpokers_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, roomInfo.seatInfoList)
    seatInfo.zhaJinNiu_state = self.SeatPlayState.hasCheck
    self.tableView:refreshSeatPlayState(seatInfo)
    -- 播放看牌音效
    self:playCheckPokerSound(seatInfo)
end

-- 比牌返回
function TableZhaJinNiuLogic:on_table_comparepokers_rsp(data)
    -- 隐藏所有的比牌选择框
    self:hideAllSeatSelectCompare()

    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    mySeatInfo.score = mySeatInfo.score - data.betScore
    mySeatInfo.zhaJinNiu_betScore = mySeatInfo.zhaJinNiu_betScore + data.betScore
    roomInfo.curRoundBetScore = roomInfo.curRoundBetScore + data.betScore

    -- 刷新分数
    self.tableView:refreshSeat(mySeatInfo)
    self.tableView:refreshSeatPlayState(mySeatInfo)

    self.tableView:showSeatCostGold(mySeatInfo, true)
    -- 飞金币动画
    self.tableView:goldFlyToGoldHeapFromSeat(mySeatInfo, data.betScore, roomInfo.ruleTable.baseScore or 1)
    self.tableView:showCurRoundBetScore(true, roomInfo.curRoundBetScore)
    local srcSeatInfo = mySeatInfo
    local dstSeatInfo = self.tableHelper:getSeatInfoByPlayerId(self.compare_target_player_id, roomInfo.seatInfoList)
    local winnerSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.winnerPlayer_id, roomInfo.seatInfoList)
    -- 播放比牌音效
    self:playComparePokerSound(srcSeatInfo)
    -- 播放比牌动画
    self:playComparePokerEffect(mySeatInfo, dstSeatInfo, winnerSeatInfo, function()
        local loserSeatInfo
        if (srcSeatInfo == winnerSeatInfo) then
            loserSeatInfo = dstSeatInfo
        else
            loserSeatInfo = srcSeatInfo
        end
        loserSeatInfo.zhaJinNiu_state = self.SeatPlayState.compareFail
        -- 显示比牌失败
        self.tableView:refreshSeatPlayState(loserSeatInfo)
        self.tableView:showInHandCards(loserSeatInfo, false)
        self.tableView:showSeatCostGold(loserSeatInfo, false)

        self.tableView:showZhaJinNiuBtns(winnerSeatInfo == mySeatInfo)

        if (self.delayInvoke_on_table_comparefail_notify) then
            local fun = self.delayInvoke_on_table_comparefail_notify
            self.delayInvoke_on_table_comparefail_notify = nil
            fun()
        end
        if (self.delayInvoke_on_table_waitspeak_notify) then
            local fun = self.delayInvoke_on_table_waitspeak_notify
            self.delayInvoke_on_table_waitspeak_notify = nil
            fun()
        end
        if (self.delayInvoke_on_table_zhajinniu_settle_accounts_notify) then
            local fun = self.delayInvoke_on_table_zhajinniu_settle_accounts_notify
            self.delayInvoke_on_table_zhajinniu_settle_accounts_notify = nil
            fun()
        end
        if (self.delayInvoke_on_table_lastsettleAccounts_Notify) then
            local fun = self.delayInvoke_on_table_lastsettleAccounts_Notify
            self.delayInvoke_on_table_lastsettleAccounts_Notify = nil
            fun()
        end
    end )
end

-- 比牌广播
function TableZhaJinNiuLogic:on_table_comparepokers_noitfy(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local srcSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.srcPlayer_id, roomInfo.seatInfoList)
    local dstSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.dstPlayer_id, roomInfo.seatInfoList)
    local winnerSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.winnerPlayer_id, roomInfo.seatInfoList)
    srcSeatInfo.score = srcSeatInfo.score - data.betScore
    srcSeatInfo.zhaJinNiu_betScore = srcSeatInfo.zhaJinNiu_betScore + data.betScore
    roomInfo.curRoundBetScore = roomInfo.curRoundBetScore + data.betScore

    -- 刷新分数
    self.tableView:refreshSeat(srcSeatInfo)
    self.tableView:showSeatCostGold(srcSeatInfo, true)
    -- 飞金币动画
    self.tableView:goldFlyToGoldHeapFromSeat(srcSeatInfo, data.betScore, roomInfo.ruleTable.baseScore or 1)
    self.tableView:showCurRoundBetScore(true, roomInfo.curRoundBetScore)
    -- 播放金币变化音效
    self:playCoinChangeSound()
    -- 播放比牌音效
    self:playComparePokerSound(srcSeatInfo)
    -- 播放比牌动画
    self:playComparePokerEffect(srcSeatInfo, dstSeatInfo, winnerSeatInfo, function()
        local loserSeatInfo
        if (srcSeatInfo == winnerSeatInfo) then
            loserSeatInfo = dstSeatInfo
        else
            loserSeatInfo = srcSeatInfo
        end
        loserSeatInfo.zhaJinNiu_state = self.SeatPlayState.compareFail
        -- 显示比牌失败
        self.tableView:refreshSeatPlayState(loserSeatInfo)

        self.tableView:showInHandCards(loserSeatInfo, false)
        self.tableView:showSeatCostGold(loserSeatInfo, false)

        if (self.delayInvoke_on_table_comparefail_notify) then
            local fun = self.delayInvoke_on_table_comparefail_notify
            self.delayInvoke_on_table_comparefail_notify = nil
            fun()
        end
        if (self.delayInvoke_on_table_waitspeak_notify) then
            local fun = self.delayInvoke_on_table_waitspeak_notify
            self.delayInvoke_on_table_waitspeak_notify = nil
            fun()
        end
        if (self.delayInvoke_on_table_zhajinniu_settle_accounts_notify) then
            local fun = self.delayInvoke_on_table_zhajinniu_settle_accounts_notify
            self.delayInvoke_on_table_zhajinniu_settle_accounts_notify = nil
            fun()
        end
        if (self.delayInvoke_on_table_lastsettleAccounts_Notify) then
            local fun = self.delayInvoke_on_table_lastsettleAccounts_Notify
            self.delayInvoke_on_table_lastsettleAccounts_Notify = nil
            fun()
        end

    end )

end

-- 比牌失败广播
function TableZhaJinNiuLogic:on_table_comparefail_notify(data)
    if (self.isPlayingComparePoker) then
        self.delayInvoke_on_table_comparefail_notify = function()
            self:on_table_comparefail_notify(data)
        end
        return
    end

    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.zhaJinNiu_state = self.SeatPlayState.compareFail
    mySeatInfo.combo_type = data.combo_type

    mySeatInfo.inHandPokerList = { }
    -- 填充手牌信息
    for i = 1, #data.pokers do
        local poker = { }
        poker.colour = data.pokers[i].colour
        poker.number = data.pokers[i].number
        table.insert(mySeatInfo.inHandPokerList, poker)
    end

    self.tableView:showInHandCards(mySeatInfo, true)
    self.tableView:refreshInHandCards(mySeatInfo, true, true)
    self.tableView:setInHandCardsMaskColor(mySeatInfo, true)
    self.tableView:refreshSeatPlayState(mySeatInfo)
    self.tableView:showNiuName(mySeatInfo, true, mySeatInfo.combo_type, true)
    self.tableView:showZhaJinNiuBtns(false)
    self.tableView:showCheckPokersButton(false)
end

-- 跟注返回
function TableZhaJinNiuLogic:on_table_callbet_rsp(data)
    self:hideAllSeatSelectCompare()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    mySeatInfo.zhaJinNiu_betScore = mySeatInfo.zhaJinNiu_betScore + data.betScore
    mySeatInfo.score = mySeatInfo.score - data.betScore
    roomInfo.curRoundBetScore = roomInfo.curRoundBetScore + data.betScore
    -- 刷新分数
    self.tableView:refreshSeat(mySeatInfo)
    self.tableView:refreshSeatPlayState(mySeatInfo)
    self:onlyShowFollowAlwaysBtn()
    if (data.betScore > roomInfo.canBetScoreList[1]) then
        -- 播放加注音效
        self:playRaiseBetSound(mySeatInfo)
    else
        -- 播放跟注音效
        self:playFollowBetSound(mySeatInfo)
    end
    self.tableView:showSeatCostGold(roomInfo.mySeatInfo, true)
    -- 飞金币动画
    self.tableView:goldFlyToGoldHeapFromSeat(roomInfo.mySeatInfo, data.betScore, roomInfo.ruleTable.baseScore or 1)
    self.tableView:showCurRoundBetScore(true, roomInfo.curRoundBetScore)
    -- 播放金币变化音效
    self:playCoinChangeSound()
end

-- 跟注广播
function TableZhaJinNiuLogic:on_table_callbet_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, roomInfo.seatInfoList)
    seatInfo.zhaJinNiu_betScore = seatInfo.zhaJinNiu_betScore + data.betScore
    seatInfo.score = seatInfo.score - data.betScore
    roomInfo.curRoundBetScore = roomInfo.curRoundBetScore + data.betScore

    self.tableView:refreshSeat(seatInfo)
    if (data.betType == 1) then
        -- 跟注
        self:playFollowBetSound(seatInfo)
    elseif (data.betType == 2) then
        -- 加注
        self:playRaiseBetSound(seatInfo)
    end

    self.tableView:showSeatCostGold(seatInfo, true)
    -- 飞金币动画
    self.tableView:goldFlyToGoldHeapFromSeat(seatInfo, data.betScore, roomInfo.ruleTable.baseScore or 1)
    self.tableView:showCurRoundBetScore(true, roomInfo.curRoundBetScore)
    -- 播放金币变化音效
    self:playCoinChangeSound()
end




function TableZhaJinNiuLogic:onclick_start_btn(obj)
    if (self.tableHelper:getSeatedSeatCount(self.modelData.curTableData.roomInfo.seatInfoList) == 1) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("至少需要两位玩家")
        return
    end

    local roomInfo = self.modelData.curTableData.roomInfo
    -- 是否要显示开始按钮	
    local isAllPlayerReady, seatedCount = self.tableHelper:checkIsAllReady(roomInfo.seatInfoList);
    if not isAllPlayerReady then

        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("有玩家未准备")
        return
    end
    self.tableModel:request_start()
end

function TableZhaJinNiuLogic:onclick_ready_btn(obj)
    if (self.waitReadyTimeEventId) then
        CSmartTimer:Kill(self.waitReadyTimeEventId)
        self.waitReadyTimeEventId = nil
    end
    self.tableModel:request_ready()
end

-- 点击继续按钮
function TableZhaJinNiuLogic:onclick_continue_btn(obj)
    if (self.modelData.curTableData.roomInfo.isRoomEnd) then
        if (self.showResultViewSmartTimer_id) then
            CSmartTimer:Kill(self.showResultViewSmartTimer_id)
            self.showResultViewSmartTimer_id = nil
        end

        local roomInfo = self.modelData.curTableData.roomInfo
        ModuleCache.ModuleManager.show_module("cowboy", "tableresult", { resultList = roomInfo.roomResultList, roomInfo = { roomNum = self.modelData.curTableData.roomInfo.roomNum, tableInfo = self.modelData.curTableData.roomInfo, timestamp = os.time() } })
        return
    else
        -- 停止播放结果音效
        self.tableHelper:playResultSound(false, self.curRoundScore and self.curRoundScore > 0)
        if (self.waitReadyTimeEventId) then
            CSmartTimer:Kill(self.waitReadyTimeEventId)
            self.waitReadyTimeEventId = nil
        end
        self.tableModel:request_ready()
    end
end

function TableZhaJinNiuLogic:resetSeatHolderArray(seatCount)
    local newSeatHolderArray = { }
    local seatHolderArray = self.tableView.srcSeatHolderArray
    local maxPlayerCount = seatCount
    if (maxPlayerCount == 3) then
        newSeatHolderArray[1] = seatHolderArray[1]
        newSeatHolderArray[2] = seatHolderArray[3]
        newSeatHolderArray[3] = seatHolderArray[5]
    elseif (maxPlayerCount == 4) then
        newSeatHolderArray[1] = seatHolderArray[1]
        newSeatHolderArray[2] = seatHolderArray[3]
        newSeatHolderArray[3] = seatHolderArray[4]
        newSeatHolderArray[4] = seatHolderArray[5]
    elseif (maxPlayerCount == 5) then
        newSeatHolderArray[1] = seatHolderArray[1]
        newSeatHolderArray[2] = seatHolderArray[3]
        newSeatHolderArray[3] = seatHolderArray[4]
        newSeatHolderArray[4] = seatHolderArray[5]
        newSeatHolderArray[5] = seatHolderArray[6]
    else
        newSeatHolderArray = seatHolderArray
    end

    for i, v in ipairs(seatHolderArray) do
        ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, false)
    end
    for i, v in ipairs(newSeatHolderArray) do
        ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, true)
    end
    self.tableView.seatHolderArray = newSeatHolderArray
end

-- 初始化相关数据
function TableZhaJinNiuLogic:initTableSeatData(data)
    self.isDataInited = true
    self.modelData.curTableData = { }
    local remoteRoomInfo = data.room_info
    -- 缓存房间信息
    local roomInfo = { }
    roomInfo.roomNum = remoteRoomInfo.roomNum
    roomInfo.roomType = remoteRoomInfo.ruleType
    roomInfo.totalRoundCount = remoteRoomInfo.totalRoundCount
    roomInfo.curRoundNum = remoteRoomInfo.curRoundNum
    roomInfo.state = remoteRoomInfo.state
    roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
    roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc
    roomInfo.timeOffset = remoteRoomInfo.serverNow - os.time()

    -- 注金池中的分数列表
    roomInfo.curRoundBetScoreList = data.curRoundBetScoreList
    -- 注金池总分数
    roomInfo.curRoundBetScore = 0
    for i = 1, #data.curRoundBetScoreList do
        roomInfo.curRoundBetScore = roomInfo.curRoundBetScore + data.curRoundBetScoreList[i]
    end
    -- 第几轮下注
    roomInfo.curBetRoundNum = data.curBetRoundNum
    -- 共多少轮下注
    roomInfo.totalBetRoundCount = data.totalBetRoundCount
    -- 是否能够比牌
    roomInfo.canCompare = data.canCompare
    -- 当前正在说话的玩家
    roomInfo.curSpeakingPlayerId = data.player_id

    -- 能够下注的分数列表
    roomInfo.canBetScoreList = {}
    for i = 1, #data.canBetScoreList do
        roomInfo.canBetScoreList[i] = data.canBetScoreList[i]
    end


    --TODO XLQ:房主id
    roomInfo.roomHostID = remoteRoomInfo.roomHostID

    self.modelData.curTableData.roomInfo = roomInfo

    if (roomInfo.state == RoomState.waitReady) then
        roomInfo.roundStarted = false
    else
        roomInfo.roundStarted = true
    end
    -- 缓存座位信息
    local remoteSeatInfoList = data.seatInfoList
    local seatInfoList = { }
    local seatCount = #remoteSeatInfoList
    for i = 1, #remoteSeatInfoList do
        local remoteSeatInfo = remoteSeatInfoList[i]
        local seatInfo = { }
        seatInfo.inHandPokerList = { }
        if (remoteSeatInfo.pokers) then
            for i = 1, #remoteSeatInfo.pokers do
                local poker = { }
                local tmp = string.split(remoteSeatInfo.pokers[i], "-")
                poker.colour = tmp[1]
                poker.number = tmp[2]
                table.insert(seatInfo.inHandPokerList, poker)
                -- print('poker='..poker.colour, poker.number)
            end
        end

        ----玩家的当前局数
        --seatInfo.gameCnt = remoteSeatInfo.gameCnt

        seatInfo.seatIndex = remoteSeatInfo.seatIndex
        seatInfo.playerId = tostring(remoteSeatInfo.player_id or 0)
        seatInfo.isSeated = self:getBoolState(remoteSeatInfo.player_id)
        -- 判断座位上是否有玩家	
        seatInfo.isBanker =(seatInfo.isSeated and self:getBoolState(remoteSeatInfo.is_banker)) or false
        -- 是否是庄家
        seatInfo.isCreator =(seatInfo.isSeated and self:getBoolState(remoteSeatInfo.is_owner)) or false
        -- 是否是房主
        seatInfo.isReady =(seatInfo.isSeated and self:getBoolState(remoteSeatInfo.isReady)) or false
        -- 是否已准备		
        seatInfo.betScore =(seatInfo.isSeated and remoteSeatInfo.bet) or 0
        -- 下注的分数
        seatInfo.isBetting = seatInfo.isReady and #seatInfo.inHandPokerList ~= 0 and(not seatInfo.isBanker)
        -- 判断是否已下注

        seatInfo.score =(seatInfo.isSeated and remoteSeatInfo.score) or 0
        -- 玩家房间内积分
        seatInfo.winTimes =(seatInfo.isSeated and remoteSeatInfo.winTimes) or 0
        -- 玩家房间内赢得次数
        seatInfo.isOffline =(not seatInfo.isSeated) or remoteSeatInfo.isOffline ~= 0
        -- 玩家是否掉线

        seatInfo.isDoneComputeNiu = false
        -- 玩家是否已经完成选牛
        seatInfo.isCalculatedResult = false
        -- 是否已经结算
        seatInfo.roomInfo = roomInfo

        if (remoteSeatInfo.zhaJinNiu_state == 0) then
            seatInfo.zhaJinNiu_state = self.SeatPlayState.hasNotCheck
            -- 1:未看牌,2:已看牌,3:弃牌,4:比牌失败
        else
            seatInfo.zhaJinNiu_state = remoteSeatInfo.zhaJinNiu_state or self.SeatPlayState.hasNotCheck
            -- 1:未看牌,2:已看牌,3:弃牌,4:比牌失败
        end

        seatInfo.zhaJinNiu_betScore = remoteSeatInfo.zhaJinNiu_betScore
        -- 已下注的分数
        seatInfo.combo_type = remoteSeatInfo.combo_type

        table.insert(seatInfoList, seatInfo)
        if (seatInfo.isSeated) then
            self.tableModule:addSeatInfo2ChatCurTableData(seatInfo)
        end
        -- 绑定玩家到座位
        if (self:getBoolState(remoteSeatInfo.player_id)) then
            -- 判断是否玩家自己，单独记录自己的座位
            if (seatInfo.playerId == self.modelData.curTablePlayerId) then
                self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo
                seatInfo.isOffline = false
            end
        else

        end

    end

    self:resetSeatHolderArray(seatCount)
    local mySeatIndex = self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex
    for i = 1, seatCount do
        local seatInfo = seatInfoList[i]
        -- 判断是否下注中状态
        seatInfo.isBetting =(roomInfo.state == 0) and seatInfo.isReady and #seatInfo.inHandPokerList ~= 0 and(not seatInfo.isBanker)
        if (roomInfo.roundStarted) then
            seatInfoList[i].curRound = { }
        end
        -- 转换为本地位置索引
        seatInfoList[i].localSeatIndex = self.tableHelper:getLocalIndexFromRemoteSeatIndex(seatInfoList[i].seatIndex, mySeatIndex, seatCount)
    end

    roomInfo.seatInfoList = seatInfoList
end

function TableZhaJinNiuLogic:getBoolState(value)
    if (value) then
        return value ~= 0 and value ~= "0"
    else
        return false
    end
end

function TableZhaJinNiuLogic:refreshMyTableViewState()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

    local isWatchState = (not mySeatInfo.isReady) and(mySeatInfo.betScore == 0) and(roomInfo.state ~= RoomState.waitReady)

    if (isWatchState) then
        self.tableView:showCenterTips(true, "等待此牌局结束")
        --if self.modelData.roleData.RoomType == 2 and mySeatInfo.isReady == false then
        --    self.tableView.buttonReady_fastStart.gameObject:SetActive(true)
        --end
        return
    end
    self.tableView:showCenterTips(false)

    -- 是否要显示开始按钮	
    local isAllPlayerReady, seatedCount = self.tableHelper:checkIsAllReady(roomInfo.seatInfoList)
    local canStartRound = roomInfo.state == RoomState.waitReady and(not roomInfo.roundStarted) and isAllPlayerReady and seatedCount > 1

    if (roomInfo.curRoundNum == 0) then
        -- self.tableView:showStartBtn(mySeatInfo.isCreator and canStartRound)
    else
        if (self.waitStartTimeEventId) then
            CSmartTimer:Kill(self.waitStartTimeEventId)
            self.waitStartTimeEventId = nil
        end
        local timeEvent = self.tableModule:subscibe_time_event(2, false, 0):OnComplete( function(t)
            -- self.tableView:showStartBtn(mySeatInfo.isCreator and canStartRound)
        end )
        self.waitStartTimeEventId = timeEvent.id;
    end



    if (canStartRound and mySeatInfo.isCreator and roomInfo.curRoundNum ~= 0 and(not self.startRequested)) then
        self.startRequested = true
        self.tableModel:request_start()
    end

    if (mySeatInfo.isCreator) then
        if (not isAllPlayerReady) then
            if (mySeatInfo.roomInfo.state == RoomState.waitReady) then
                -- self.tableView:showCenterTips(true, "等待其他玩家准备")
            end
        else
            if (mySeatInfo.roomInfo.state == RoomState.waitReady) then
                -- self.tableView:showCenterTips(true, "点击开始")
            end
        end
    end


end

function TableZhaJinNiuLogic:resetRoundState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        seatInfo.curRound = nil

        seatInfo.isReady = false

        seatInfo.isBanker = false
        seatInfo.betScore = 0
        seatInfo.isBetting = false
        seatInfo.isDoneComputeNiu = false
        -- 玩家是否已经完成选牛
        seatInfo.isCalculatedResult = false
        -- 是否已经结算		
        seatInfo.inHandPokerList = { }
        seatInfo.zhaJinNiu_state = self.SeatPlayState.hasNotCheck
        -- 0:未看牌,1:已看牌,2:弃牌
        seatInfo.zhaJinNiu_betScore = 0
        -- 已下注的分数
        seatInfo.combo_type = nil
    end
    self.modelData.curTableData.roomInfo.roundStarted = false
    self.modelData.curTableData.roomInfo.curRoundBetScore = 0
end

function TableZhaJinNiuLogic:refreshResetState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]

        self.tableView:showNiuName(seatInfo, false)

        self.tableView:refreshSeat(seatInfo, false)
    end

    self:refreshMyTableViewState()

    self.tableView:showContinueBtn(false)

    --if self.modelData.roleData.RoomType == 2 then
    --    self.tableView.buttonReady_fastStart.gameObject:SetActive(false)
    --end
end


function TableZhaJinNiuLogic:playFaPaiAnim(seatInfo, onFinish, seatCount)
    local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
    local delay = 0.1 * seatCount
    local duration = 0.2
    local finishCount = 0
    local cardHolderList = seatHolder.inhandCardsArray
    local count = #cardHolderList
    if (seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo) then

        for i = 1, #cardHolderList do
            local cardHolder = cardHolderList[i]

            ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.x, false)
            ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.y, false)
            local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
            cardHolder.cardRoot.transform.localScale = pokerHeapCardScale

            self.tableModule:subscibe_time_event((i - 1) * delay, false, 0):OnComplete(function()
                self:playFaPaiSound()
            end)

            self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration,(i - 1) * delay, function()
                ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.x, true)
                ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.y, true)
            end )
            self.tableHelper:playCardScaleAnim(cardHolder, cardHolder.cardLocalScale.x, duration,(i - 1) * delay, function()
                finishCount = finishCount + 1
                if (finishCount == count) then
                    if (onFinish) then
                        onFinish()
                    end
                end
            end )

        end

    else
        local startIndex = 1
        local endIndex = #cardHolderList
        local step = 1
        if (seatHolder.isInRight) then
            startIndex = #cardHolderList
            endIndex = 1
            step = -1
        end
        local index = 0
        for i = startIndex, endIndex, step do
            index = index + 1
            local cardHolder = cardHolderList[i]

            ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.x, false)
            ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, seatHolder.goTmpPokerHeapPos.transform.position.y, false)
            local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
            cardHolder.cardRoot.transform.localScale = pokerHeapCardScale

            self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration,(index - 1) * delay, function()
                finishCount = finishCount + 1
                if (finishCount == count) then
                    if (onFinish) then
                        onFinish()
                    end
                end
            end )
        end
    end
end

function TableZhaJinNiuLogic:getServerNowTime()
    return self.modelData.curTableData.roomInfo.timeOffset + os.time() + 1
end


-- 隐藏所有的比牌选择框
function TableZhaJinNiuLogic:hideAllSeatSelectCompare()
    local roomInfo = self.modelData.curTableData.roomInfo
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = roomInfo.seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            self.tableView:showSelectCompare(seatInfo, false)
        end
    end
end

-- 隐藏所有座位的倒计时
function TableZhaJinNiuLogic:hideAllSeatSpeakingTimeLimitEffect()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        self.tableView:showSeatTimeLimitEffect(seatInfoList[i], false)
    end
end

-- 点击比牌按钮
function TableZhaJinNiuLogic:onClickComparePokerBtn(obj, arg)
    -- print("点击比牌")
    -- 高亮显示可以选择的玩家
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local list = { }
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = roomInfo.seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            -- print(seatInfo.playerId, seatInfo.zhaJinNiu_state)
            if (seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop or seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail) then
                self.tableView:showSelectCompare(seatInfo, false)
            else
                if (seatInfo == mySeatInfo) then
                    self.tableView:showSelectCompare(seatInfo, false)
                else
                    self.tableView:showSelectCompare(seatInfo, true)
                    table.insert(list, seatInfo)
                end
            end
        end
    end

    if (#list == 1) then
        self.compare_target_player_id = list[1].playerId
        self.isDelayAlwaysFollow = false
        self.tableModel:request_compare_pokers(tonumber(list[1].playerId))
        self:hideAllSeatSelectCompare()
    end

end

-- 点击弃牌按钮
function TableZhaJinNiuLogic:onClickDropPokerBtn(obj, arg)
    self.isDelayAlwaysFollow = false
    self.tableModel:request_drop_pokers()
end

-- 点击看牌按钮
function TableZhaJinNiuLogic:onclick_check_pokers_btn(obj, arg)
    self.tableModel:request_check_pokers()
end

-- 点击跟到底按钮
function TableZhaJinNiuLogic:onclick_follow_always_btn(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    mySeatInfo.isAlwaysFollow = self.tableView.toggleFollowAlways.isOn
    if (roomInfo.curSpeakingPlayerId == tonumber(mySeatInfo.playerId)) then
        self:showMySeatSpeaking()
        self:tryShowDropAndCheckBtn()
        if(mySeatInfo.isAlwaysFollow)then
            self.tableModel:request_call_bet(roomInfo.canBetScoreList[1])
        end
    else
        -- self.tableView:refreshBetBtns(roomInfo.canBetScoreList)
        self:onlyShowFollowAlwaysBtn()
        self:tryShowDropAndCheckBtn()
    end
end

-- 点击加注按钮
function TableZhaJinNiuLogic:onclick_raise_btn(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
    if (roomInfo.curSpeakingPlayerId == tonumber(roomInfo.mySeatInfo.playerId) and #roomInfo.canBetScoreList > 1) then
        local score = roomInfo.canBetScoreList[2]
        self.isDelayAlwaysFollow = false
        self.tableModel:request_call_bet(score)
    else
        self:onSeatSpeaking()
    end
end

-- 点击跟注按钮
function TableZhaJinNiuLogic:onclick_follow_btn(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
    if (roomInfo.curSpeakingPlayerId == tonumber(roomInfo.mySeatInfo.playerId) and #roomInfo.canBetScoreList > 0) then
        local score = roomInfo.canBetScoreList[1]
        self.isDelayAlwaysFollow = false
        self.tableModel:request_call_bet(score)
    else
        self:onSeatSpeaking()
    end
end

-- 点击更多按钮
function TableZhaJinNiuLogic:onclick_more_btn(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
    self.tableView:showBetBtns(true)
    self.tableView:refreshBetBtns(roomInfo.canBetScoreList, roomInfo.ruleTable.baseScore or 1, self:get_original_bet_list())
end

-- 点击隐藏更多按钮
function TableZhaJinNiuLogic:onclick_hide_more_btn(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
    self.tableView:showMoreBtns(true, #roomInfo.canBetScoreList > 2)
    self.tableView:showBetBtns(false)
end

-- 点击更多下注按钮
function TableZhaJinNiuLogic:onclick_more_bet_btn(obj, arg)
    local betBtnHolderArray = self.tableView.betBtnHolderArray
    for i, v in pairs(betBtnHolderArray) do
        local holder = v
        if(obj == v.button.gameObject)then
            self.isDelayAlwaysFollow = false
            self.tableModel:request_call_bet(v.value)
        end
    end
end


-- 点击比牌选择框
function TableZhaJinNiuLogic:onclick_selectCompare(obj, arg)
    local roomInfo = self.modelData.curTableData.roomInfo
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = roomInfo.seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
            if (obj == seatHolder.goSelectCompare) then
                self.compare_target_player_id = seatInfo.playerId
                self.isDelayAlwaysFollow = false
                self.tableModel:request_compare_pokers(tonumber(seatInfo.playerId))
                return
            end
        end

    end
end

-- 点击选择比牌Mask
function TableZhaJinNiuLogic:onclick_selectCompareMask(obj, arg)
    self:hideAllSeatSelectCompare()
end


function TableZhaJinNiuLogic:testGoldFly(obj, arg)
    if (not self.goldList) then
        self.goldList = { }
    end
    local goldList = { }
    for i = 1, 3 do
        local gold = ModuleCache.ComponentUtil.InstantiateLocal(self.tableView.prefabGold3, self.tableView.holderGolds.root)
        ModuleCache.ComponentUtil.SafeSetActive(gold, true)
        goldList[i] = gold
        table.insert(self.goldList, gold)
    end
    self.tableHelper:goldFlyToGoldHeap(goldList, obj.transform.position, self.tableView.goldHeapRect, 0.5)

    self.minScore = self.minScore or 1
    self.minScore = self.minScore + 1
    self.tableView:refreshBetBtns(self.minScore)
end


function TableZhaJinNiuLogic:testGoldFly1(obj, arg)
    if (self.goldList) then
        self.tableHelper:goldFlyToSeat(self.goldList, obj.transform.position, 0.5, 0, true, function(...)

            -- print("finish--------------")
        end )
        self.goldList = { }
    end

    self.minScore = self.minScore or 8
    self.minScore = self.minScore - 1
    self.tableView:refreshBetBtns(self.minScore)
end

-- 播放比牌特效
function TableZhaJinNiuLogic:playComparePokerEffect(srcSeatInfo, dstSeatInfo, winnerSeatInfo, onFinish)
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    --local leftSeatInfo
    --local rightSeatInfo
    --if (srcSeatInfo == mySeatInfo) then
    --    if (dstSeatInfo.localSeatIndex <= 3) then
    --        leftSeatInfo = mySeatInfo
    --        rightSeatInfo = dstSeatInfo
    --    else
    --        leftSeatInfo = dstSeatInfo
    --        rightSeatInfo = mySeatInfo
    --    end
    --elseif (dstSeatInfo == mySeatInfo) then
    --    if (srcSeatInfo.localSeatIndex <= 3) then
    --        leftSeatInfo = mySeatInfo
    --        rightSeatInfo = srcSeatInfo
    --    else
    --        leftSeatInfo = srcSeatInfo
    --        rightSeatInfo = mySeatInfo
    --    end
    --else
    --    if (srcSeatInfo.localSeatIndex < dstSeatInfo.localSeatIndex) then
    --        leftSeatInfo = dstSeatInfo
    --        rightSeatInfo = srcSeatInfo
    --    else
    --        leftSeatInfo = srcSeatInfo
    --        rightSeatInfo = dstSeatInfo
    --    end
    --end
    --
    --local isLeftWin = leftSeatInfo == winnerSeatInfo
    --self.isPlayingComparePoker = true
    --self.tableView:showMask(true)
    --
    --self.tableView:showSeatPokerFly2ComparePosEffect(leftSeatInfo, true, true, function()
    --    self.tableView:showConstrastEffect(true, isLeftWin, function()
    --        self.tableView:showConstrastEffect(false)
    --        self.tableView:showComparePokerFly2SeatPosEffect(leftSeatInfo, true, true, function(...)
    --            self.tableView:showComparePokerFly2SeatPosEffect(leftSeatInfo, false)
    --            self.isPlayingComparePoker = false
    --            self.tableView:showMask(false)
    --            if (onFinish) then
    --                onFinish()
    --            end
    --        end )
    --        self.tableView:showComparePokerFly2SeatPosEffect(rightSeatInfo, true, false, function(...)
    --            self.tableView:showComparePokerFly2SeatPosEffect(rightSeatInfo, false)
    --        end )
    --    end )
    --end )
    --self.tableView:showSeatPokerFly2ComparePosEffect(rightSeatInfo, true, false, function()
    --
    --end )

    self.isPlayingComparePoker = true
    local isLeftWin = winnerSeatInfo == srcSeatInfo
    self.tableView:showConstrastEffect_New(true, srcSeatInfo, dstSeatInfo, isLeftWin, function()
        self.tableView:showConstrastEffect_New(false)
        self.isPlayingComparePoker = false
        if(onFinish)then
            onFinish()
        end
    end)

end


-- 播放比牌音效
function TableZhaJinNiuLogic:playComparePokerSound(seatInfo)
    local soundName = self:getSoundHead(seatInfo) .. "compare_poker"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

-- 播放弃牌音效
function TableZhaJinNiuLogic:playDropPokerSound(seatInfo)
    local soundName = self:getSoundHead(seatInfo) .. "drop_poker"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

-- 播放看牌音效
function TableZhaJinNiuLogic:playCheckPokerSound(seatInfo)
    local soundName = self:getSoundHead(seatInfo) .. "check_poker"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end


-- 播放跟注音效
function TableZhaJinNiuLogic:playFollowBetSound(seatInfo)
    local soundName = self:getSoundHead(seatInfo) .. "follow_bet"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

-- 播放加注音效
function TableZhaJinNiuLogic:playRaiseBetSound(seatInfo)
    local soundName = self:getSoundHead(seatInfo) .. "raise_bet"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

-- 播放金币变化音效
function TableZhaJinNiuLogic:playCoinChangeSound(seatInfo)
    local soundName = "coin_change"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

-- 播放金币飞翔音效
function TableZhaJinNiuLogic:playCoinFlySound(seatInfo)
    local soundName = "coin_fly"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

--播放呼出下注按钮音效
function TableZhaJinNiuLogic:playBtnShowSound()
    local soundName = "b_anniushoufang"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

--播放倒计时音效
function TableZhaJinNiuLogic:playDaoJiShiSound()
    local soundName = "b_daojishi"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

--播放赢家音效
function TableZhaJinNiuLogic:playWinnerSound()
    local soundName = "b_yingjiazhanshi"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

--播放发牌音效
function TableZhaJinNiuLogic:playFaPaiSound()
    local soundName = "b_fapai"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

--播放发牌音效
function TableZhaJinNiuLogic:playKanPaiEffectSound()
    local soundName = "b_kanpai"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end
--播放飘数字音效
function TableZhaJinNiuLogic:playPiaoShuZiSound()
    local soundName = "b_piaoshuzi"
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end



function TableZhaJinNiuLogic:getSoundHead(seatInfo)
    if (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
        return "female_"
    else
        return "male_"
    end
end

function TableZhaJinNiuLogic:getRandomNumber(min, max)
    local val = math.random(min, max)
    return val
end

function TableZhaJinNiuLogic:startWaitContinue()
    if (self.waitReadyTimeEventId) then
        CSmartTimer:Kill(self.waitReadyTimeEventId)
        self.waitReadyTimeEventId = nil
    end
    local duration = 3
    self.continueShowStartTime = Time.realtimeSinceStartup
    self.tableView:refreshContinueTimeLimitText(duration)
    local timeEvent = self.tableModule:subscibe_time_event(duration, false, 0):OnComplete( function(t)
        if(not self.tableModule.is_freeing_room)then
            self.tableModel:request_ready()
        end
    end ):SetIntervalTime(0.05, function(t)
        local leftSecs = math.ceil(self.continueShowStartTime + duration - Time.realtimeSinceStartup)
        self.tableView:refreshContinueTimeLimitText(leftSecs)
    end )
    self.waitReadyTimeEventId = timeEvent.id;
end

------收到包:客户自定义的信息变化广播
function TableZhaJinNiuLogic:on_table_CustomInfoChangeBroadcast(data)
    print("==on_table_CustomInfoChangeBroadcast")
    -- print_table(data.customInfoList)
    if (self.modelData == nil or self.modelData.curTableData == nil
        or self.modelData.curTableData.roomInfo == nil
        or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
        return
    end
    if (data == nil or data.customInfoList == nil or #data.customInfoList <= 0) then
        return
    end
    for i = 1, #data.customInfoList do
        local player_id = data.customInfoList[i].player_id
        local customInfo = data.customInfoList[i].customInfo
        if (customInfo == nil or customInfo == "") then
            print("==customInfo == nil or customInfo ==")
        end

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for m = 1, #seatInfoList do
            local seatInfo = seatInfoList[m]
            if (tostring(seatInfo.playerId) == tostring(player_id) and (customInfo and customInfo ~= '')) then
                local locTable = ModuleCache.Json.decode(customInfo)
                locTable.gpsInfo = locTable.gpsInfo or ''
                local tmpData = {}
                tmpData.ip = locTable.ip
                tmpData.address = locTable.address
                tmpData.gpsInfo = locTable.gpsInfo
                local locationStr = string.split(locTable.gpsInfo, ",")
                if(#locationStr > 0) then
                    tmpData.latitude = tonumber(locationStr[1])
                    tmpData.longitude = tonumber(locationStr[2])
                end

                if (seatInfo.playerInfo == nil) then
                    print("====seatInfo.playerInfo == nil")
                else
                    -- print("==ip="..locTable.ip.."  address="..locTable.address)
                    -- seatInfo.playerInfo.ip = locTable.ip
                    seatInfo.playerInfo.locationData = seatInfo.playerInfo.locationData or { }
                    seatInfo.playerInfo.locationData.address = locTable.address
                    seatInfo.playerInfo.locationData.gpsInfo = locTable.gpsInfo
                end
                if(not self.playerCustomInfoMap)then
                    self.playerCustomInfoMap = {}
                end
                self.playerCustomInfoMap[seatInfo.playerId] = tmpData
            end
        end
    end

    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    -- 获取玩家信息列表
    local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
    -- 是否显示定位图标
    TableManagerPoker:isShowLocation(playerInfoList, self.tableView.buttonLocation);
end

function TableZhaJinNiuLogic:hide_start_btn()
    local roomInfo = self.modelData.curTableData.roomInfo
    if (self.waitStartTimeEventId) then
        CSmartTimer:Kill(self.waitStartTimeEventId)
        self.waitStartTimeEventId = nil
    end
    -- 隐藏开始按钮
    -- self.tableView:showStartBtn(false)
    self.startRequested = false
end

function TableZhaJinNiuLogic:get_all_seated_ready_seats()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local list = {}
    for i, v in pairs(seatInfoList) do
        if(v.isSeated and v.isReady)then
            table.insert(list, v)
        end
    end
    return list
end

function TableZhaJinNiuLogic:get_original_bet_list()
    local roomInfo = self.modelData.curTableData.roomInfo
    local ruleTable = roomInfo.ruleTable
    local mySeatInfo = roomInfo.mySeatInfo
    if(mySeatInfo.zhaJinNiu_state == SeatPlayState.hasNotCheck)then
        if(ruleTable.maxBetScore == 3)then
            return {2, 3}
        elseif(ruleTable.maxBetScore == 5)then
            return {2, 3, 4, 5}
        else
            return {}
        end
    else
        if(ruleTable.maxBetScore == 3)then
            return {4, 6}
        elseif(ruleTable.maxBetScore == 5)then
            return {4, 6, 8, 10}
        else
            return {}
        end
    end
end

return TableZhaJinNiuLogic