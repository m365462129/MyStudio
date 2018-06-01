local list = require("list")
local class = require("lib.middleclass")
--- @class TableDouNiuLogic
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic = class('TableDouNiuLogic')

local CSmartTimer = ModuleCache.SmartTimer.instance

local RoomState = { }
RoomState.waitReady = 0			-- 等待玩家准备状态
RoomState.waitSetBanker = 1		-- 等待定庄状态
RoomState.waitBet = 2			-- 等待下注状态
RoomState.waitResult = 3		-- 等待结算状态
RoomState.waitFaPai = 4         --等待发牌
RoomState.waitReset = 5         --等待重置

local TableManager = TableManagerPoker


function TableDouNiuLogic:initialize(module)
    self.tableModule = module
    self.modelData = module.modelData
    self.tableView = self.tableModule.tableView
    self.tableModel = self.tableModule.tableModel
    self.tableHelper = self.tableModule.tableHelper


    self:resetSeatHolderArray(6)
    self.RoomState = RoomState
    self.const_wait_other_ready_tips = '请等待其他玩家准备'
    self.const_wait_start_tips = '请等待开始'
    self.const_ready_tips = '请准备'
    self.const_wait_other_bet_tips = '请等待其他玩家下注'
    self.const_bet_tips = '请选择下注金额'
    self.const_select_banker_tips = '请选择抢庄倍数'
    self.const_wait_other_select_banker_tips = '请等待其他玩家抢庄'
    self.const_start_tips = '请开始游戏'
    self.fapai_seatDelayTime = 0.06
end

function TableDouNiuLogic:on_show()

end

function TableDouNiuLogic:on_hide()

end

function TableDouNiuLogic:update()

    if (not self.modelData.curTableData or(not self.modelData.curTableData.roomInfo)) then
        return
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if (roomInfo.state == RoomState.waitBet) then
        self.tableView:refreshClock(mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    elseif (roomInfo.state == RoomState.waitResult) then
        self.tableView:refreshClock(mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    elseif (roomInfo.state == RoomState.waitSetBanker) then
        self.tableView:refreshClock(mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    else
        self.tableView:refreshClock(mySeatInfo, false)
    end
end

function TableDouNiuLogic:on_destroy()
    self.showResultViewSmartTimer_id = nil

end


-- 进入房间回包
function TableDouNiuLogic:on_table_enter_rsp(data)

end

-- 进入房间广播
function TableDouNiuLogic:on_table_enter_notify(data)
    local posInfo = data.pos_info
    local seatInfo = self.tableHelper:getSeatInfoByRemoteSeatIndex(posInfo.pos_index, self.modelData.curTableData.roomInfo.seatInfoList)
    seatInfo.playerId = tostring(posInfo.player_id)
    seatInfo.isSeated = self:getBoolState(posInfo.player_id)
    -- 判断座位上是否有玩家
    seatInfo.isReady = self:getBoolState(posInfo.is_ready)

    local oneShotSettlePlayer = data.oneShotSettlePlayer
    if(oneShotSettlePlayer)then
        for i = 1, #oneShotSettlePlayer do
            if(oneShotSettlePlayer[i].player_id == posInfo.player_id)then
                seatInfo.gold = oneShotSettlePlayer[i].coinBalance
            end
        end
    end


    -- 是否已准备
    if (self:getBoolState(posInfo.player_id)) then
        -- 判断是否玩家自己，单独记录自己的座位
        if (seatInfo.playerId == self.modelData.curTablePlayerId) then
            self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo
            seatInfo.isOffline = false
        end
    end
    self.tableModule:addSeatInfo2ChatCurTableData(seatInfo)
    self.tableView:refreshSeat(seatInfo, seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo, false, false)
end

-- 离开房间回包
function TableDouNiuLogic:on_table_leave_rsp(data)
    -- print("on_table_leave_rsp-----------")
end

-- 离开房间广播
function TableDouNiuLogic:on_table_leave_notify(data)
    -- print("on_table_leave_notify-----------")
end

-- 解散房间回包
function TableDouNiuLogic:on_table_dissolve_rsp(data)
    -- print("on_table_dissolve_rsp-----------")
end

-- 解散房间广播
function TableDouNiuLogic:on_table_dissolve_notify(data)
    -- print("on_table_dissolve_notify-----------")
end

-- 同步消息包
function TableDouNiuLogic:on_table_synchronize_notify(data)
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
    self.tableView:showGoldCoinDiZhu(true, nil, roomInfo.curRoundNum, roomInfo.totalRoundCount)
    -- 刷新每个座位状态的显示
    local seatList = roomInfo.seatInfoList
    for i = 1, #seatList do
        seatList[i].inHandPokerList = seatList[i].inHandPokerList or { }
        self.tableView:refreshSeat(seatList[i], seatList[i].isDoneComputeNiu or seatList[i] == roomInfo.mySeatInfo, false, false)
        if(seatList[i].isDoneComputeNiu)then
            self.tableView:showNiuName(seatList[i], true, seatList[i].niuName)
        end
    end
    -- 隐藏tips
    self.tableView:showCenterTips(false)

    -- 刷新玩家自己桌面
    self:refreshMyTableViewState()

    -- local showReadyBtn = (not mySeatInfo.isReady) and (roomInfo.state == self.RoomState.waitReady)
    -- self.tableView:showReadyBtn(showReadyBtn)	

    self.tableView:showContinueBtn(false)

    local roomInfo = self.modelData.curTableData.roomInfo
    if (roomInfo.state == RoomState.waitBet or roomInfo.state == RoomState.waitResult) then
        self.tableView:refreshClock(self.modelData.curTableData.roomInfo.mySeatInfo, true, roomInfo.expireTimes[roomInfo.state], self:getServerNowTime())
    end

    if(self.check_need_ready_fun)then
        self:check_need_ready_fun()
    else
        if mySeatInfo.isReady == false then
            -- 自动准备
            self:onclick_ready_btn();

            --print_table(self.modelData,"--------self.modelData-------------")
            --
            ------0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
            --if self.modelData.roleData.RoomType ~= 2 then
            --
            --end
        end
    end

    if roomInfo.curRoundNum == 0 then
        self.tableModule:refresh_share_clip_board()
        -- 刷新准备状态
        self.tableView:refreshReadyState(mySeatInfo.isCreator);
    else
        -- 隐藏所有选择按钮
        self.tableView:hideAllReadyButton();
    end

end 

-- 上一局的结算通知
function TableDouNiuLogic:on_table_ago_settle_accounts_notify(data)

    local resultList = data.settleAccounts
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if (mySeatInfo.isReady) then
        return
    end
    roomInfo.state = RoomState.waitReady
    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        seatInfo.curRound = { }
        seatInfo.curRound.score = result.score
        seatInfo.curRound.niuName = result.combo_type
        if (result.score > 0) then
            seatInfo.winTimes = seatInfo.winTimes + 1
        end

        seatInfo.isCalculatedResult = true
        seatInfo.inHandPokerList = { }
        local pokerList = result.pokers
        for i = 1, #pokerList do
            local poker = { }
            poker.colour = pokerList[i].colour
            poker.number = pokerList[i].number
            table.insert(seatInfo.inHandPokerList, poker)
        end

        self:playRoundResultScore(seatInfo, seatInfo.curRound.score)
        -- 展示玩家手牌
        self.tableView:refreshSeat(seatInfo, true, false, true)

        local niuName = seatInfo.curRound.niuName
        -- 显示牛名
        self.tableView:showNiuName(seatInfo, true, niuName)

    end

    -- 重置数据
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        seatInfo.curRound = nil
        -- seatInfo.isReady = false		
        seatInfo.isBanker = false
        -- seatInfo.betScore = 0
        -- seatInfo.isBetting = false			
        seatInfo.isDoneComputeNiu = false
        -- 玩家是否已经完成选牛
        seatInfo.isCalculatedResult = false
        -- 是否已经结算		
        seatInfo.inHandPokerList = { }
    end
    self.modelData.curTableData.roomInfo.roundStarted = false

    self:refreshMyTableViewState()
    --    --显示继续按钮
    -- self.tableView:showReadyBtn(false)

    self.tableView:showContinueBtn(true)
    self:startWaitContinue()

    -- 重置之前的选牛界面
    self.tableModule:resetSelectedPokers()
    self.tableView:resetSelectedPokers()
end



-- 准备回包
function TableDouNiuLogic:on_table_ready_rsp(data)
    if (data.err_no == "0") then
        local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
        mySeatInfo.isReady = true
        self:refreshResetState()
        self:refreshMyTableViewState()

        -- 	self.tableView:showReadyBtn(false)	

        -- 	self.tableView:showContinueBtn(false)

        self.tableView:hideAllNiuNiuEffect()

    else
        if(data.err_no == '-888')then
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
                ModuleCache.ModuleManager.show_module("public", "goldadd")
            end, nil, true, "确 认", "取 消")
        end
    end
end

-- 准备广播
function TableDouNiuLogic:on_table_ready_notify(data)
    local posInfo = data.pos_info
    local seatInfo = self.tableHelper:getSeatInfoByRemoteSeatIndex(posInfo.pos_index, self.modelData.curTableData.roomInfo.seatInfoList)
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    seatInfo.isReady = posInfo.is_ready ~= 0

    -- 判断当前牌桌的状态,是否可以开局		
    self:refreshMyTableViewState()
    self.tableView:refreshSeatState(seatInfo)
    self.tableView:refreshSeatInfo(seatInfo)
    self.tableView:showQiangZhuangBeiShuTag(seatInfo, false)
    if (mySeatInfo.isReady) then
        -- 刷新显示对应座位的准备状态
        self.tableView:showNiuName(seatInfo, false)
        self.tableView:refreshSeat(seatInfo, false)
        self.tableView:showSeatWinScoreCurRound(seatInfo, false, nil)
    end

end

-- 开始回包
function TableDouNiuLogic:on_table_start_rsp(data)

end

-- 开始广播
function TableDouNiuLogic:on_table_start_notify(data)
    if(data.err_no and data.err_no ~= '0')then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
        self.startRequested = false
        self:refreshMyTableViewState()
        return
    end
    if(self.pokerTableFrameModule)then
        self.pokerTableFrameModule:check_activity_is_open()
    end
    self:hide_start_btn()
    -- 标识已开始当前局
    local roomInfo = self.modelData.curTableData.roomInfo
    roomInfo.roundStarted = true
    roomInfo.state = RoomState.waitBet
    if(not data.game_loop_cnt or data.game_loop_cnt == 0)then
        roomInfo.curRoundNum = roomInfo.curRoundNum + 1
    else
        roomInfo.curRoundNum = data.game_loop_cnt
    end
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
        seatInfo.curRound = { }
        seatInfo.isBetting = false
        self.tableView:refreshSeat(seatInfo, false)
    end

    --自己的局数
    roomInfo.mySeatInfo.gameCnt = data.gameCnt
    -- 隐藏tips
    self.tableView:showCenterTips(false)

    -- 刷新房间信息显示
    self.tableView:setRoomInfo(roomInfo)
    self.tableView:showGoldCoinDiZhu(true, nil, roomInfo.curRoundNum, roomInfo.totalRoundCount)
    -- 刷新桌面
    self:refreshMyTableViewState()

    self.tableView:showBetBtns(false)

    -- 隐藏所有准备按钮
    self.tableView:hideAllReadyButton();
end

-- 下注回包
function TableDouNiuLogic:on_table_bet_rsp(data)
    -- 记录当前下注分
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.betScore = self.selectedBetScore
    mySeatInfo.isBetting = false

    -- 隐藏tips
    self.tableView:showCenterTips(false)

    self:refreshMyTableViewState()
    -- 刷新自己座位显示状态
    self.tableView:refreshSeat(self.modelData.curTableData.roomInfo.mySeatInfo, true)
end

-- 下注通知
function TableDouNiuLogic:on_table_bet_notify(data)
    local playerId = data.player_id
    local betScore = data.bet
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(tostring(playerId), self.modelData.curTableData.roomInfo.seatInfoList)
    seatInfo.betScore = betScore
    seatInfo.isBetting = false
    -- 刷新做为的下注分显示
    self.tableView:refreshSeat(seatInfo, seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo)
end

-- 发牌通知
function TableDouNiuLogic:on_table_fapai_notify(data)
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
                roomInfo.state = RoomState.waitResult
                if (seatInfo == mySeatInfo) then
                    --self.tableView:refreshSeatCardsSelect(mySeatInfo)
                    -- 隐藏下注按钮
                    self:refreshMyTableViewState()
                    -- 刷新选牛数字
                    self.tableView:refreshSelectedNiuNumbers()
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

    -- 隐藏下注按钮
    self:refreshMyTableViewState()
    -- 刷新选牛数字
    self.tableView:refreshSelectedNiuNumbers()

end

-- 算牛回包
function TableDouNiuLogic:on_table_compute_rsp(data)
    -- 标识完成选牛步骤
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if (mySeatInfo.isDoneComputeNiu) then
        return
    end
    mySeatInfo.isDoneComputeNiu = true

    -- 刷新手牌的位置
    self.tableView:refreshSeat(self.modelData.curTableData.roomInfo.mySeatInfo, true, false, true)

    local niuName = data.combo_type
    -- 显示牛名
    self.tableView:showNiuName(mySeatInfo, true, niuName)
    local isFemale =(mySeatInfo.playerInfo and mySeatInfo.playerInfo.gender ~= 1)
    self.tableHelper:playNiuNameSound(niuName, isFemale)

    -- 重置之前的选牛状态
    self.tableModule:resetSelectedPokers()
    self.tableView:resetSelectedPokers()
    -- 隐藏选牛面板
    self:refreshMyTableViewState()
end

-- 算牛通知
function TableDouNiuLogic:on_table_compute_notify(data)
    local playerId = data.player_id
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(tostring(playerId), roomInfo.seatInfoList)
    if (seatInfo.isDoneComputeNiu) then
        return
    end
    seatInfo.isDoneComputeNiu = true
    seatInfo.inHandPokerList = {}
    for i = 1, #data.pokers do
        table.insert(seatInfo.inHandPokerList, data.pokers[i])
    end
    local do_show = function()
        -- 展示玩家手牌
        self.tableView:refreshSeat(seatInfo, true, seatInfo ~= mySeatInfo, true)

        local niuName = data.combo_type
        --if (niuName == "cow10" or niuName == "silvercow") then
        --    -- 播放牛牛动画
        --    self.tableView:showNiuNiuEffect(seatInfo, true, 0.5, 1, 0, function()
        --        self.tableView:showNiuName(seatInfo, true, niuName)
        --    end)
        --else
        --    -- 显示牛名
        --    self.tableView:showNiuName(seatInfo, true, niuName)
        --end
        self.tableView:showNiuName(seatInfo, true, niuName)
        local isFemale =(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1)
        self.tableHelper:playNiuNameSound(niuName, isFemale)

        if(seatInfo == roomInfo.mySeatInfo)then
            -- 重置之前的选牛状态
            self.tableModule:resetSelectedPokers()
            self.tableView:resetSelectedPokers()
        end
    end
    if(not self.is_playing_fapai)then
        do_show()
    else
        if(not self.on_finish_fapai_fun_list)then
            self.on_finish_fapai_fun_list = {}
        end
        table.insert(self.on_finish_fapai_fun_list, do_show)
    end

end

-- 单局结算通知
function TableDouNiuLogic:on_table_settleAccounts_Notify(data)
    local resultList = data.settleAccounts
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    roomInfo.state = RoomState.waitReady
    if mySeatInfo.isReady then
        mySeatInfo.is_self_exists = true
    end

    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        seatInfo.isBetting = false
        -- 展示玩家手牌
        if(seatInfo ~= mySeatInfo)then
            self.tableView:refreshSeat(seatInfo)
        end

        seatInfo.gameCnt = result.gameCnt  --更新当前玩家玩的局数

        seatInfo.curRound = { }
        seatInfo.curRound.score = result.score
        seatInfo.curRound.niuName = result.combo_type
        seatInfo.score = seatInfo.score + result.score
        seatInfo.gold = result.coinBalance
        if (result.score > 0) then
            seatInfo.winTimes = seatInfo.winTimes + 1
        end

        seatInfo.isCalculatedResult = true
        seatInfo.inHandPokerList = { }
        local pokerList = result.pokers
        for j = 1, #pokerList do
            local poker = { }
            poker.colour = pokerList[j].colour
            poker.number = pokerList[j].number
            table.insert(seatInfo.inHandPokerList, poker)
        end
        self.curRoundScore = seatInfo.curRound.score
    end


    local onFinish = function()
        local tmpFun = function()
            -- 重置数据
            self:resetRoundState()

            self:refreshMyTableViewState()

            -- --隐藏准备和邀请按钮
            -- self.tableView:showReadyBtn(false)

            -- 重置之前的选牛界面
            self.tableModule:resetSelectedPokers()
            self.tableView:resetSelectedPokers()
        end
        if(self.on_finish_fapai_fun_list and #self.on_finish_fapai_fun_list > 0)then
            table.insert(self.on_finish_fapai_fun_list, tmpFun)
        else
            tmpFun()
        end
    end

    self:table_settle_effect(resultList, onFinish)
    self:startContinueBtn()
    -- 是否要显示选牛面板
    local isWaitXuanNiu =(not mySeatInfo.isDoneComputeNiu) and roomInfo.state == RoomState.waitResult
    self.tableView:showSelectNiuPanel(isWaitXuanNiu)
    self.tableView:showComfirmNiuBtns(isWaitXuanNiu)

    -- 重置之前的选牛界面
    self.tableModule:resetSelectedPokers()
    self.tableView:resetSelectedPokers()
end

function TableDouNiuLogic:table_settle_effect(resultList, onFinish)
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    local mySeatInfo = roomInfo.mySeatInfo
    for i = 1, #resultList do
        local result = resultList[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(result.playerId, seatInfoList)
        local curScore = seatInfo.curRound.score
        self.tableModule:subscibe_time_event(2, false, 0):OnComplete(function()
            self:playRoundResultScore(seatInfo, curScore, true)
        end)
        if(not seatInfo.isDoneComputeNiu)then
            -- 展示玩家手牌
            self.tableView:refreshSeat(seatInfo, true, (not seatInfo.isDoneComputeNiu) and seatInfo ~= mySeatInfo, true)

            local niuName = seatInfo.curRound.niuName
            --if (niuName == "cow10" or niuName == "silvercow") then
            --    -- 播放牛牛动画
            --    self.tableView:showNiuNiuEffect(seatInfo, true, 0.5, 1, 0, function()
            --        if (mySeatInfo.isReady) then
            --            -- 已经点击了继续按钮
            --            -- 显示牛名
            --            self.tableView:showNiuName(seatInfo, false, niuName)
            --        else
            --            -- 显示牛名
            --            self.tableView:showNiuName(seatInfo, true, niuName)
            --        end
            --
            --    end )
            --else
            --    -- 显示牛名
            --    self.tableView:showNiuName(seatInfo, true, niuName)
            --end
            self.tableView:showNiuName(seatInfo, true, niuName)
            if (seatInfo == mySeatInfo) then
                local isFemale =(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1)
                self.tableHelper:playNiuNameSound(niuName, isFemale)
            end
        else
            self.tableView:refreshSeat(seatInfo, true, false, true)
        end
        if(seatInfo == mySeatInfo)then
            self.tableHelper:playResultSound(true, seatInfo.curRound.score > 0)
            self.tableHelper:playResultSound(true, seatInfo.curRound.score > 0)
        end
    end
    if(onFinish)then
        onFinish()
    end
end


function TableDouNiuLogic:playRoundResultScore(seatInfo, roundScore, stillShow)
    -- 显示玩家当局赢得分数
    self.tableView:showSeatWinScoreCurRound(seatInfo, true, roundScore)
    -- 播放分数动画
    self.tableView:showSeatRoundScoreAnim(seatInfo, true, roundScore, stillShow)
end

function TableDouNiuLogic:startContinueBtn()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

    self.tableModule:subscibe_time_event(2, false, 0):OnComplete( function(t)
        -- 显示继续按钮
        self.tableView:showContinueBtn(true)
        self:startWaitContinue()

    end )

    ---- 中途进入 第0局
    --local HalfwayJoin_one = (mySeatInfo.gameCnt == 0 and roomInfo.curRoundNum ~= mySeatInfo.gameCnt)
    --
    --if self.modelData.roleData.RoomType ~= 2 then
    --    self.tableModule:subscibe_time_event(2, false, 0):OnComplete( function(t)
    --        -- 显示继续按钮
    --        self.tableView:showContinueBtn(true)
    --        self:startWaitContinue()
    --
    --    end )
    --elseif not HalfwayJoin_one then
    --    self.tableModule:subscibe_time_event(2, false, 0):OnComplete( function(t)
    --        -- 显示继续按钮
    --        self.tableView:showContinueBtn(true)
    --        self:startWaitContinue()
    --
    --    end )
    --end
end

-- 房间结算通知
function TableDouNiuLogic:on_table_lastsettleAccounts_Notify(data)
    TableManager:disconnect_game_server()
    local resultList = self:get_last_account_resultlist(data)
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
        self:showGameResult({ resultList = resultList, roomInfo = { roomNum = self.modelData.curTableData.roomInfo.roomNum, tableInfo = self.modelData.curTableData.roomInfo, timestamp = os.time() } })
        self.showResultViewSmartTimer_id = nil
    end ):OnKill( function(t)

    end )
    self.showResultViewSmartTimer_id = timeEvent.id
end

function TableDouNiuLogic:showGameResult(data)
    ModuleCache.ModuleManager.show_module("cowboy", "tableresult", data)
end

function TableDouNiuLogic:get_last_account_resultlist(data)
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
        result.coin = data.LastSettleAccounts[i].coin
        result.restcoin = data.LastSettleAccounts[i].restcoin
        result.restRedPackage = result.restcoin / 1000
        result.coinbalance = data.LastSettleAccounts[i].coinbalance
        if(result.playerId == data.free_sponsor)then
            result.isDissolver = true
        end
        table.insert(resultList, result)
    end
    return resultList
end

-- 设置庄家通知
function TableDouNiuLogic:on_table_setbanker_notify(data)
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList

    for i = 1, #seatInfoList do
        seatInfoList[i].isBanker = false
        self.tableView:refreshSeatInfo(seatInfoList[i])
    end

    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id, seatInfoList)

    seatInfo.isBanker = true
    seatInfo.isBetting = false
    local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
    self.tableHelper:playSetTargetSeatAsBanker(seatHolder, function()
        self.tableView:refreshSeatInfo(seatInfo)
        -- 刷新座位状态
        self.tableView:refreshSeatState(seatInfo)
        self:refreshMyTableViewState()
    end )

end


-- 到期时间通知
function TableDouNiuLogic:on_table_expire_time_notify(data)

    local expires = data.expires
    for i = 1, #expires do
        local expireInfo = expires[i]
        if (expireInfo.state == 0) then
            -- 房间等待准备状态
            self.modelData.curTableData.roomInfo.expireTimes[0] = expireInfo.expire

        elseif (expireInfo.state == 1) then
            -- 定庄状态
            self.modelData.curTableData.roomInfo.expireTimes[1] = expireInfo.expire

        elseif (expireInfo.state == 2) then
            -- 下注状态
            self.modelData.curTableData.roomInfo.expireTimes[2] = expireInfo.expire
        elseif (expireInfo.state == 3) then
            -- 等待结算状态
            self.modelData.curTableData.roomInfo.expireTimes[3] = expireInfo.expire
        else

        end
    end
end

function TableDouNiuLogic:on_table_scramblebanker_rsp(data)

end

function TableDouNiuLogic:on_table_scramblebanker_notify(data)

end

function TableDouNiuLogic:onclick_start_btn(obj)
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

function TableDouNiuLogic:onclick_ready_btn(obj)
    if (self.waitReadyTimeEventId) then
        CSmartTimer:Kill(self.waitReadyTimeEventId)
        self.waitReadyTimeEventId = nil
    end
    self.tableModel:request_ready()
end

-- 点击继续按钮
function TableDouNiuLogic:onclick_continue_btn(obj)
    if (self.modelData.curTableData.roomInfo.isRoomEnd) then
        if (self.showResultViewSmartTimer_id) then
            CSmartTimer:Kill(self.showResultViewSmartTimer_id)
            self.showResultViewSmartTimer_id = nil
        end
        -- 隐藏牛牛特效
        self.tableView:hideAllNiuNiuEffect()
        local roomInfo = self.modelData.curTableData.roomInfo
        self:showGameResult({ resultList = roomInfo.roomResultList, roomInfo = { roomNum = self.modelData.curTableData.roomInfo.roomNum, tableInfo = self.modelData.curTableData.roomInfo, timestamp = os.time() } })
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

function TableDouNiuLogic:resetSeatHolderArray(seatCount)
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

function TableDouNiuLogic:initTableSeatData(data)
    self.isDataInited = true
    self.modelData.curTableData = { }
    local remoteRoomInfo = data.room_info
    -- 缓存房间信息
    local roomInfo = { }
    roomInfo.roomNum = remoteRoomInfo.roomNum
    print(roomInfo.roomNum, '---------------------------------------------')
    roomInfo.roomType = remoteRoomInfo.ruleType
    roomInfo.totalRoundCount = remoteRoomInfo.totalRoundCount
    roomInfo.curRoundNum = remoteRoomInfo.curRoundNum
    roomInfo.feeNum = remoteRoomInfo.feeNum     --金币场房费
    roomInfo.state = remoteRoomInfo.state
    roomInfo.expireTimes = { }
    roomInfo.expireTimes[0] = 0
    roomInfo.expireTimes[1] = 0
    roomInfo.expireTimes[2] = 0
    roomInfo.expireTimes[3] = 0
    roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule
    roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc
    roomInfo.timeOffset = remoteRoomInfo.serverNow - os.time()
    --金币场底分
    roomInfo.baseCoinScore = remoteRoomInfo.baseCoinScore

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
    self.seatCount = seatCount
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
                ----print('poker='..poker.colour, poker.number)
            end
        end
        --玩家的当前局数
        seatInfo.gameCnt = remoteSeatInfo.gameCnt

        seatInfo.seatIndex = remoteSeatInfo.seatIndex
        seatInfo.playerId = tostring(remoteSeatInfo.player_id or 0)
        seatInfo.isSeated = self:getBoolState(remoteSeatInfo.player_id)
        -- 判断座位上是否有玩家
        seatInfo.isBanker =(seatInfo.isSeated and self:getBoolState(remoteSeatInfo.is_banker)) or false
        -- 是否是庄家
        seatInfo.isCreator =(seatInfo.isSeated and self:getBoolState(remoteSeatInfo.is_owner)) or false
        -- 是否是房主
        seatInfo.isReady =(seatInfo.isSeated and self:getBoolState(remoteSeatInfo.isReady)) or false
        --未准备倒计时（金币场）
        seatInfo.not_ready_timeout = remoteSeatInfo.not_ready_timeout
        --金币场玩家余额
        seatInfo.gold = remoteSeatInfo.coinBalance
        -- 是否已准备
        seatInfo.betScore =(seatInfo.isSeated and remoteSeatInfo.bet) or 0
        -- 下注的分数
        seatInfo.isBetting = seatInfo.isReady and #seatInfo.inHandPokerList ~= 0 and #seatInfo.inHandPokerList ~= 5 and(not seatInfo.isBanker)
        -- 判断是否已下注

        seatInfo.score =(seatInfo.isSeated and remoteSeatInfo.score) or 0
        -- 玩家房间内积分
        seatInfo.winTimes =(seatInfo.isSeated and remoteSeatInfo.winTimes) or 0
        -- 玩家房间内赢得次数
        seatInfo.isOffline =(not seatInfo.isSeated) or remoteSeatInfo.isOffline ~= 0
        -- 玩家是否掉线

        seatInfo.isDoneComputeNiu = remoteSeatInfo.isFinishComputePoker
        seatInfo.niuName = remoteSeatInfo.combo_type
        -- 玩家是否已经完成选牛
        seatInfo.isCalculatedResult = false
        -- 是否已经结算
        seatInfo.roomInfo = roomInfo

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

function TableDouNiuLogic:getBoolState(value)
    if (value) then
        return value ~= 0 and value ~= "0"
    else
        return false
    end
end

function TableDouNiuLogic:refreshMyTableViewState()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

    --RoomState.waitReady = 0			-- 等待玩家准备状态
    --RoomState.waitSetBanker = 1		-- 等待定庄状态
    --RoomState.waitBet = 2			-- 等待下注状态
    --RoomState.waitResult = 3		-- 等待结算状态
    
    local isWatchState = true
    if self.modelData.roleData.RoomType == 2 then
        isWatchState =(mySeatInfo.gameCnt == 0 and roomInfo.curRoundNum ~= mySeatInfo.gameCnt and (mySeatInfo.betScore == 0)
        and(roomInfo.state ~= RoomState.waitBet) and not mySeatInfo.is_self_exists)
    else
        isWatchState = (not mySeatInfo.isReady) and(mySeatInfo.betScore == 0) and(roomInfo.state ~= RoomState.waitReady)
    end
    self.tableView:showCenterTips(false)
   -- print("--------------mySeatInfo.gameCnt:",mySeatInfo.gameCnt,roomInfo.curRoundNum, mySeatInfo.is_self_exists, isWatchState)
    if (isWatchState) then
        self.tableView:showCenterTips(true, "等待此牌局结束")
        self.tableView:showSelectNiuPanel(false)
        self.tableView:showComfirmNiuBtns(false)
        self.tableView:showBetBtns(false)
        --if self.modelData.roleData.RoomType == 2 and mySeatInfo.isReady == false then
        --    self.tableView.buttonReady_fastStart.gameObject:SetActive(true)
        --end
        return
    end


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
            --     		self.tableView:showStartBtn(mySeatInfo.isCreator and canStartRound)
        end )
        self.waitStartTimeEventId = timeEvent.id;
    end
    print("-------------------canStartRound:",canStartRound,mySeatInfo.isCreator,roomInfo.curRoundNum ~= 0,self.startRequested)
    if (canStartRound and mySeatInfo.isCreator and roomInfo.curRoundNum ~= 0 and(not self.startRequested)) then
        self.startRequested = true
        self.tableModel:request_start()
    end

    if (mySeatInfo.isCreator) then
        if (not isAllPlayerReady) then
            if (mySeatInfo.roomInfo.state == RoomState.waitReady) then
                 --self.tableView:showCenterTips(mySeatInfo.isReady, "请等待其他玩家准备")
            end
        else
            if (mySeatInfo.roomInfo.state == RoomState.waitReady) then
                 --self.tableView:showCenterTips(mySeatInfo.isReady, "请点击开始")
            end
        end
    end

    -- 是否要显示下注按钮
    local needShowBet = mySeatInfo.betScore == 0 and roomInfo.state == RoomState.waitBet and(not mySeatInfo.isBanker) and mySeatInfo.isReady
    self.tableView:showBetBtns(needShowBet, roomInfo.ruleTable.isBigBet, roomInfo.ruleTable.bankerType == 2)
    if (needShowBet) then
        -- self.tableView:showCenterTips(true, "加倍")
    elseif (roomInfo.state == RoomState.waitBet) then
        -- self.tableView:showCenterTips(true, "等待其他玩家加倍")
    end

    -- 是否要显示选牛面板
    local isWaitXuanNiu =(not mySeatInfo.isDoneComputeNiu) and roomInfo.state == RoomState.waitResult
    self.tableView:showSelectNiuPanel(isWaitXuanNiu)
    self.tableView:showComfirmNiuBtns(isWaitXuanNiu)

    if(roomInfo.state == self.RoomState.waitReady)then
        if(self.modelData.tableCommonData.isGoldTable)then
            self:showReadyStateTips()
        end
    elseif(roomInfo.state == self.RoomState.waitBet)then
        self:showBetStateTips()
    elseif(roomInfo.state == self.RoomState.waitSetBanker)then
        self:showSetBankerStateTips()
    end

end

function TableDouNiuLogic:showReadyStateTips()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local isAllPlayerReady, seatedCount = self.tableHelper:checkIsAllReady(roomInfo.seatInfoList)
    if(mySeatInfo.isReady)then
        if(not isAllPlayerReady)then
            self.tableView:showCenterTips(true, self.const_wait_other_ready_tips)
        else
            --if(mySeatInfo.isCreator)then
            --    self.tableView:showCenterTips(true, self.const_start_tips)
            --else
            --    self.tableView:showCenterTips(true, self.const_wait_start_tips)
            --end
        end
    else
        self.tableView:showCenterTips(true, self.const_ready_tips)
    end
end

function TableDouNiuLogic:showBetStateTips()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if(mySeatInfo.isBanker)then
        self.tableView:showCenterTips(true, self.const_wait_other_bet_tips)
    else
        if(not mySeatInfo.betScore or mySeatInfo.betScore == 0)then
            self.tableView:showCenterTips(true, self.const_bet_tips)
        else
            self.tableView:showCenterTips(true, self.const_wait_other_bet_tips)
        end
    end
end

function TableDouNiuLogic:showSetBankerStateTips()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

end

function TableDouNiuLogic:resetRoundState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList

    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        seatInfo.curRound = nil

        --if self.modelData.roleData.RoomType == 2 then
        --    local HalfwayJoin_one =(seatInfo.gameCnt == 0 and self.modelData.curTableData.roomInfo.curRoundNum ~= seatInfo.gameCnt)
        --    --print(seatInfo.playerId,"------resetRoundState-----",seatInfo.gameCnt == 0,HalfwayJoin_one)
        --    if not HalfwayJoin_one then
        --        seatInfo.isReady = false
        --    end
        --else
            seatInfo.isReady = false
        --end


        seatInfo.isBanker = false
        seatInfo.betScore = 0
        seatInfo.isBetting = false
        seatInfo.isDoneComputeNiu = false
        -- 玩家是否已经完成选牛
        seatInfo.isCalculatedResult = false
        -- 是否已经结算
        seatInfo.inHandPokerList = { }
        seatInfo.qiangZhuangBeiShu = 0
    end
    self.modelData.curTableData.roomInfo.roundStarted = false
    self.on_finish_fapai_fun_list = nil
end

function TableDouNiuLogic:refreshResetState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]

        self.tableView:showNiuName(seatInfo, false)
        self.tableView:showSeatWinScoreCurRound(seatInfo, false, nil)

        self.tableView:refreshSeat(seatInfo, false)
    end

    self:refreshMyTableViewState()

    self.tableView:showContinueBtn(false)

    --if self.modelData.roleData.RoomType == 2 then
    --    self.tableView.buttonReady_fastStart.gameObject:SetActive(false)
    --end
end


function TableDouNiuLogic:onClickPoker(obj)
    if (self.modelData.curTableData.roomInfo.mySeatInfo.isDoneComputeNiu or(not self.modelData.curTableData.roomInfo.roundStarted)) then
        return
    end

    local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
    local selectedPokersArray = self.tableView.seatHolderArray[1].selectedPokersArray or { }
    for i = 1, #cardsArray do
        -- print("obj="..obj.name .. "&root="..cardsArray[i].cardRoot.name)
        if (obj == cardsArray[i].cardRoot) then
            if (cardsArray[i].selected) then

                cardsArray[i].selected = false
                for j = 1, #selectedPokersArray do
                    if (selectedPokersArray[j] == cardsArray[i].poker) then
                        table.remove(selectedPokersArray, j)
                        break
                    end
                end
                self.tableView:refreshCardSelect(cardsArray[i])
            elseif (#selectedPokersArray ~= 3) then
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

function TableDouNiuLogic:playFaPaiAnim(seatInfo, onFinish, seatCount, seatDelayTime)
    local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
    local delay = (seatCount) * self.fapai_seatDelayTime
    local duration = 0.3
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
                self.tableHelper:playFaPaiSound()
            end)

            self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration,(i - 1) * delay, function()
                ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.x, true)
                ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.y, true)
            end )
            self.tableHelper:playCardScaleAnim(cardHolder, cardHolder.cardLocalScale.x, duration,(i - 1) * delay, nil)
            self.tableHelper:playCardTurnAnim(cardHolder, true, duration,(i - 1) * delay, function()
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

            self.tableModule:subscibe_time_event((index - 1) * delay, false, 0):OnComplete(function()
                self.tableHelper:playFaPaiSound()
            end)
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

function TableDouNiuLogic:getServerNowTime()
    return self.modelData.curTableData.roomInfo.timeOffset + os.time() + 1
end

function TableDouNiuLogic:showSeatsRandomBankerEffect(seatInfoList, targetSeatInfo, onFinish)
    local totalDuration = 2

    local count = #seatInfoList
    local totalCount = 0
    for i = 1, #seatInfoList do
        if (seatInfoList[i] == targetSeatInfo) then
            totalCount = i + count * 2
        end
    end

    while (totalCount < 6 * 2) do
        totalCount = totalCount + count
    end
    local duration2 = totalDuration /(6 + totalCount)
    local duration1 = 2 * duration2
    local index = 1
    local showEffect
    showEffect = function(i, isFirstRound)
        local curSeatInfo = seatInfoList[i]
        self.tableView:showRandomBankerEffect(curSeatInfo, true)
        ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/table/random_banker_sound.bytes", "random_banker_sound")
        self.tableModule:subscibe_time_event((isFirstRound and duration1) or duration2, false, 0):OnComplete( function(t)
            ModuleCache.SoundManager.stop_sound("cowboy", "cowboy/sound/table/random_banker_sound.bytes", "random_banker_sound")
            self.tableView:showRandomBankerEffect(curSeatInfo, false)
            if (index == totalCount) then
                if (onFinish) then
                    onFinish()
                end
            else
                if (i == count) then
                    i = 1
                else
                    i = i + 1
                end
                index = index + 1
                showEffect(i, index < 6)
            end
        end )
    end

    showEffect(1, true)
end

function TableDouNiuLogic:showSeatsRandomEffect(seatInfoList, show)
    for i = 1, #seatInfoList do
        self.tableView:showRandomBankerEffect(seatInfoList[i], show)
    end
end

function TableDouNiuLogic:showSeatRandomEffect(seatInfo, show)
    self.tableView:showRandomBankerEffect(seatInfo, show)
end

function TableDouNiuLogic:on_dragMaskPoker(obj, arg)

end

function TableDouNiuLogic:on_press_downMaskPoker(obj, arg)

end

function TableDouNiuLogic:on_press_upMaskPoker(obj, arg)

end


function TableDouNiuLogic:onClickHasNiuBtn()
    local selectedPokersArray = self.tableView.seatHolderArray[1].selectedPokersArray or { }
    local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(selectedPokersArray)
    if (not hasNiu) then
        --[[
		self.hasNiuDealTimeEvent_id = nil
    	local timeEvent = nil
    	timeEvent = self.tableModule:subscibe_time_event(self.tableModule.doubleClickInterval, false, 0):OnComplete(function(t)
			if(self.hasNiuDealTimeEvent_id)then
				CSmartTimer:Kill(self.hasNiuDealTimeEvent_id)
				self.hasNiuDealTimeEvent_id = nil
			end
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请选择正确的牛")
		end)
		self.hasNiuDealTimeEvent_id = timeEvent.id
		--]]

        self.tableModule:resetSelectedPokers()
        local result = { }
        hasNiu = self.tableHelper:checkHasNiuFormPokerArray(self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerList, result)

        if (hasNiu) then
            self.tableModule:selectCardsByPokerArray(result.pokers)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("必须是10的倍数哦")
        end
        return
    else
        -- 向服务器请求
        self.tableModel:request_compute_poker()
    end

end

function TableDouNiuLogic:onDoubleClickHasNiuBtn()
    --[[
	if(not self.hasNiuDealTimeEvent_id)then
		return
	end
	CSmartTimer:Kill(self.hasNiuDealTimeEvent_id)
	--]]
    self.hasNiuDealTimeEvent_id = nil
    local selectedPokersArray = self.tableView.seatHolderArray[1].selectedPokersArray or { }
    local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(selectedPokersArray)
    if (not hasNiu) then
        self.tableModule:resetSelectedPokers()
        local result = { }
        hasNiu = self.tableHelper:checkHasNiuFormPokerArray(self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerList, result)

        if (hasNiu) then
            self.tableModule:selectCardsByPokerArray(result.pokers, true)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("必须是10的倍数哦")
        end
        return
    else
        -- 向服务器请求
        self.tableModel:request_compute_poker()
    end
end

function TableDouNiuLogic:onClickNoNiuBtn()
    local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerList)
    if (hasNiu) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("真的有牛，不信再算算...")
        self.tableModule:resetSelectedPokers()
        self.tableView:resetSelectedPokers()
        self.tableView:refreshSelectedNiuNumbers()
        return
    else
        -- 向服务器请求
        self.tableModel:request_compute_poker()
    end
end

function TableDouNiuLogic:onClickLiangPaiBtn()
    self.tableModel:request_compute_poker()
end

function TableDouNiuLogic:startWaitContinue()
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
        leftSecs = math.max(leftSecs, 0)
        self.tableView:refreshContinueTimeLimitText(leftSecs)
    end )
    self.waitReadyTimeEventId = timeEvent.id;
end

------收到包:客户自定义的信息变化广播
function TableDouNiuLogic:on_table_CustomInfoChangeBroadcast(data)
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
                    seatInfo.on_get_userinfo_callback_queue = seatInfo.on_get_userinfo_callback_queue or list:new()
                    local cb = function(seatInfo)
                        seatInfo.playerInfo.ip = tmpData.ip
                        seatInfo.playerInfo.locationData = seatInfo.playerInfo.locationData or {}
                        seatInfo.playerInfo.locationData.address = tmpData.address
                        seatInfo.playerInfo.locationData.gpsInfo = tmpData.gpsInfo
                        seatInfo.playerInfo.locationData.latitude = tmpData.latitude
                        seatInfo.playerInfo.locationData.longitude = tmpData.longitude
                    end
                    seatInfo.on_get_userinfo_callback_queue:push(cb)
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


function TableDouNiuLogic:hide_start_btn()
    local roomInfo = self.modelData.curTableData.roomInfo
    if (self.waitStartTimeEventId) then
        CSmartTimer:Kill(self.waitStartTimeEventId)
        self.waitStartTimeEventId = nil
    end
    ----隐藏开始按钮
    -- self.tableView:showStartBtn(false)
    self.startRequested = false
end

function TableDouNiuLogic:getDefaultBetScore()
    local roomInfo = self.modelData.curTableData.roomInfo
    if(roomInfo.ruleTable.isBigBet == 1)then
        return 3
    else
        return 2
    end
end

function TableDouNiuLogic:getCanXiaZhuBeiShuList()
    local roomInfo = self.modelData.curTableData.roomInfo
    local xiaZhuBeiShuList = {}
    for i = 1, 10 do
        if(roomInfo.ruleTable['xiaZhuScore_'..i])then
            table.insert(xiaZhuBeiShuList, i)
        end
    end
    return xiaZhuBeiShuList
end

function TableDouNiuLogic:autoSelectNiu()
	self.tableModule:resetSelectedPokers()
	local result = {}
	local hasNiu = self.tableHelper:checkHasNiuFormPokerArray(self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerList, result)
	
	if(hasNiu) then
		self.tableModule:selectCardsByPokerArray(result.pokers, true)
	else
			
	end
	--向服务器请求
	self.tableModel:request_compute_poker()		
end

--点击下注按钮
function TableDouNiuLogic:on_click_bet_btn(obj, arg)
    if (obj == self.tableView.buttonBet1.gameObject) then
        self.selectedBetScore = 1
    elseif (obj == self.tableView.buttonBet2.gameObject) then
        self.selectedBetScore = 2
        self.tableModel:request_bet(self.selectedBetScore)
    elseif (obj == self.tableView.buttonBet3.gameObject) then
        self.selectedBetScore = 3
        self.tableModel:request_bet(self.selectedBetScore)
    elseif (obj == self.tableView.buttonBet4.gameObject) then
        self.selectedBetScore = 4
        self.tableModel:request_bet(self.selectedBetScore)
    elseif (obj == self.tableView.buttonBet5.gameObject) then
        self.selectedBetScore = 5
        self.tableModel:request_bet(self.selectedBetScore)
    elseif (obj == self.tableView.buttonBet8.gameObject) then
        self.selectedBetScore = 8
        self.tableModel:request_bet(self.selectedBetScore)
    elseif (obj == self.tableView.buttonBet10.gameObject) then
        self.selectedBetScore = 10
        self.tableModel:request_bet(self.selectedBetScore)
    end
end

--点击抢庄倍数
function TableDouNiuLogic:on_click_qiangzhuang_btn(obj, arg)
    for i=0,10 do
        local button = self.tableView['buttonQiangZhuang_'..i]
        if(button)then
            if(button.gameObject == obj)then
                self.tableModel:request_scrambleBanker(i ~= 0, i)
                return
            end
        end
    end
    if(self.tableView.buttonQiangZhuang_Qiang.gameObject == obj)then
        self.tableModel:request_scrambleBanker(true, 1)
    elseif(self.tableView.buttonQiangZhuang_BuQiang.gameObject == obj)then
        self.tableModel:request_scrambleBanker(false, 1)
    end
end

function TableDouNiuLogic:getCanXiaZhuScoreList()
	local roomInfo = self.modelData.curTableData.roomInfo
	local ruleTable = roomInfo.ruleTable

	local list = {}
	if(ruleTable.xiaZhuScore_1)then
		table.insert(list, 1)
	end
	if(ruleTable.xiaZhuScore_2)then
		table.insert(list, 2)
	end
	if(ruleTable.xiaZhuScore_3)then
		table.insert(list, 3)
	end
	if(ruleTable.xiaZhuScore_4)then
		table.insert(list, 4)
	end
	if(ruleTable.xiaZhuScore_5)then
		table.insert(list, 5)
	end
	if(ruleTable.xiaZhuScore_6)then
		table.insert(list, 6)
	end
	if(ruleTable.xiaZhuScore_7)then
		table.insert(list, 7)
	end
	if(ruleTable.xiaZhuScore_8)then
		table.insert(list, 8)
	end
	if(ruleTable.xiaZhuScore_9)then
		table.insert(list, 9)
	end
	if(ruleTable.xiaZhuScore_10)then
		table.insert(list, 10)
	end
	return list
end

function TableDouNiuLogic:getCanQiangZhuangScoreList()
	local roomInfo = self.modelData.curTableData.roomInfo
	local ruleTable = roomInfo.ruleTable

	local list = {0}
	if(ruleTable.qiangZhuangScore_1)then
		table.insert(list, 1)
	end
	if(ruleTable.qiangZhuangScore_2)then
		table.insert(list, 2)
	end
	if(ruleTable.qiangZhuangScore_3)then
		table.insert(list, 3)
	end
	if(ruleTable.qiangZhuangScore_4)then
		table.insert(list, 4)
	end
	if(ruleTable.qiangZhuangScore_5)then
		table.insert(list, 5)
	end
	if(ruleTable.qiangZhuangScore_6)then
		table.insert(list, 6)
	end
	if(ruleTable.qiangZhuangScore_7)then
		table.insert(list, 7)
	end
	if(ruleTable.qiangZhuangScore_8)then
		table.insert(list, 8)
	end
	if(ruleTable.qiangZhuangScore_9)then
		table.insert(list, 9)
	end
	if(ruleTable.qiangZhuangScore_10)then
		table.insert(list, 10)
	end
	return list
end

--金币变化通知
function TableDouNiuLogic:on_shotsettle_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    local oneShotSettlePlayer = data.oneShotSettlePlayer
    for i = 1, #oneShotSettlePlayer do
        local player = oneShotSettlePlayer[i]
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(player.player_id, seatInfoList)
        seatInfo.gold = player.coinBalance
        local coin = player.coin
    end

    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        self.tableView:refreshSeatInfo(seatInfo)
    end
end

function TableDouNiuLogic:can_invite_wechat_friend()
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return false
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    if (roomInfo.curRoundNum > 0) then
        return false
    end
    return true
end

function TableDouNiuLogic:get_all_seated_ready_seats()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local list = {}
    for i, v in pairs(seatInfoList) do
        if(v.isSeated and v.isReady)then
            table.insert(list, v)
        end
    end
    return list
end

function TableDouNiuLogic:on_pre_share_room_num()
    local roomInfo = self.modelData.curTableData.roomInfo
    local curPlayerCount = self.tableHelper:getSeatedSeatCount(roomInfo.seatInfoList)
    self.tableModule:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, true, curPlayerCount)
end

return TableDouNiuLogic