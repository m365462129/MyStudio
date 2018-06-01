local AppData = AppData
local BranchPackageName = AppData.BranchZhaJinHuaName
local class = require("lib.middleclass")
---@class TableZhaJinHuaLogic
local TableZhaJinHuaLogic = class('TableZhaJinHuaLogic')
local CSmartTimer = ModuleCache.SmartTimer.instance
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local TableManagerPoker = TableManagerPoker
local ZjhLogic = require(string.format("package.%s.module.table_zhajinhua.zjh_logic",BranchPackageName))
local CardCommon = require "package/zhajinhua/module/table_zhajinhua/gamelogic_common"

local RoomState = { }
RoomState.waitReady = 0			-- 等待玩家准备状态
RoomState.waitSetBanker = 1		-- 等待定庄状态
RoomState.waitBet = 2			-- 等待下注状态
RoomState.waitResult = 3		-- 等待结算状态

local SeatPlayState = { }
SeatPlayState.notStart = 0      -- 未开始牌局
SeatPlayState.hasNotCheck = 1	-- 未看牌
SeatPlayState.hasCheck = 2		-- 已看牌
SeatPlayState.hasDrop = 3		-- 已弃牌
SeatPlayState.compareFail = 4	-- 比牌失败

function TableZhaJinHuaLogic:initialize(module)
    self.tableModule = module
    self.modelData = module.modelData
    self.tableView = self.tableModule.tableView
    self.tableModel = self.tableModule.tableModel
    self.tableHelper = self.tableModule.tableHelper
    self.SeatPlayState = SeatPlayState

    self:resetSeatHolderArray(6)
    self.RoomState = RoomState
end

function TableZhaJinHuaLogic:on_show()

end

function TableZhaJinHuaLogic:on_hide()

end

function TableZhaJinHuaLogic:update()

    if (not self.modelData.curTableData or(not self.modelData.curTableData.roomInfo)) then
        return
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo

end

function TableZhaJinHuaLogic:on_destroy()
    self.showResultViewSmartTimer_id = nil
end


-- 进入房间回包
function TableZhaJinHuaLogic:on_table_enter_rsp(data)

end

-- 进入房间广播
function TableZhaJinHuaLogic:on_table_enter_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    local posInfo = data.pos_info
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(posInfo.player_id, seatInfoList) 
    if(seatInfo == nil) then
        seatInfo = {}
        seatInfo.seatIndex = posInfo.pos_index
        seatInfo.playerId = tostring(posInfo.player_id)
        seatInfo.isSeated = self:getBoolState(posInfo.player_id)
        seatInfo.isBanker = false
        seatInfo.isCreator = false
        seatInfo.isReady = false
        seatInfo.score = 0
        seatInfo.isOffline = false
        seatInfo.isWatchState = true
        seatInfo.coinBalance = posInfo.coinBalance
        seatInfo.cur_game_loop_cnt = posInfo.cur_game_loop_cnt or 0		--玩家进行的游戏局数

        self:RefreshSeatInfo_InHandPokerList(seatInfo)
        table.insert(seatInfoList, seatInfo)
        local seatCount = #seatInfoList
        self:resetSeatHolderArray(seatCount)
        local mySeatIndex = roomInfo.mySeatInfo.seatIndex
        for i=1,seatCount do
            local seatInfo = seatInfoList[i]
            if (roomInfo.roundStarted) then
                seatInfo.curRound = { }
            end
            seatInfo.localSeatIndex = self.tableHelper:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, mySeatIndex, 6)
        end
        if(self.tableView:isGoldSettle()) then
            local seatHolder = self.tableView:GetSeatHolderBySeatInfo(seatInfo)
            seatHolder.CurrencyUIStateSwitcher:SwitchState("Gold")
            self.tableView:SetState_rechargeState(seatInfo,false)
        end
        self.tableView:SetState_HeadGray(seatInfo,seatInfo.isWatchState and self:IsGameDoing())
    end
end

-- 离开房间回包
function TableZhaJinHuaLogic:on_table_leave_rsp(data)
    -- print("on_table_leave_rsp-----------")
end

-- 离开房间广播
function TableZhaJinHuaLogic:on_table_leave_notify(data)
    -- print("on_table_leave_notify-----------")
end

-- 解散房间回包
function TableZhaJinHuaLogic:on_table_dissolve_rsp(data)
    -- print("on_table_dissolve_rsp-----------")
end

-- 解散房间广播
function TableZhaJinHuaLogic:on_table_dissolve_notify(data)
    -- print("on_table_dissolve_notify-----------")
end

-- 同步消息包
function TableZhaJinHuaLogic:on_table_synchronize_notify(data)
end 

-- 上一局的结算通知
function TableZhaJinHuaLogic:on_table_zhajinniu_ago_settle_accounts_notify(data)
end

-- 结算通知
function TableZhaJinHuaLogic:on_table_zhajinniu_settle_accounts_notify(data)
end

function TableZhaJinHuaLogic:on_table_ready_rsp(data)
    print("====准备回包给自己")
    self:HideContinueBtn()
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.isReady = true
    self.tableView:refreshSeatInfoImageReadyState(mySeatInfo)  
    self.tableView:SetJinBiChangStateSwitcher(false)
    self.tableView:StopCoinCountdown()
    self.tableView:SwitchState_NewStateRoot(mySeatInfo,true)
    if(self:IsWaitReadyState()) then
        self.tableView:showCenterTips(false)
    else
        if(mySeatInfo.isWatchState) then
            self.tableView:showCenterTips(true, self.tableView:GetWatchStateShowText())
        end
    end
end

-- 准备广播
function TableZhaJinHuaLogic:on_table_ready_notify(data)
    print("=====on_table_ready_notify 准备的玩家=",data.pos_info.player_id)
    local posInfo = data.pos_info
    local seatInfo =self.tableHelper:getSeatInfoByPlayerId(posInfo.player_id,self.modelData.curTableData.roomInfo.seatInfoList)
    if(seatInfo) then
        seatInfo.isReady = posInfo.is_ready == 1
        self.tableView:refreshSeatInfoImageReadyState(seatInfo)
        self:AlreadyReadyResetUI(seatInfo)
    else
        print("====没有找到玩家id=",tostring(data.pos_info.player_id))
    end
end

function TableZhaJinHuaLogic:AlreadyReadyResetUI(seatInfo)
    self.tableView:showSeatCostGold(seatInfo, false)
    self.tableView:showInHandCards(seatInfo, false)
    self.tableView:SwitchState_NewStateRoot(seatInfo,true)
end

-- 开始回包
function TableZhaJinHuaLogic:on_table_start_rsp(data)

end

-- 开始广播
function TableZhaJinHuaLogic:on_table_start_notify(data)
    print("====on_table_start_notify")
end

-- 到期时间通知
function TableZhaJinHuaLogic:on_table_expire_time_notify(data)

end

-- 等待玩家说话广播
function TableZhaJinHuaLogic:on_table_waitspeak_notify(data)
    self:hideAllSeatSelectCompare()
    if (self.isPlayingComparePoker) then
        self.delayInvoke_on_table_waitspeak_notify = function()
            self:on_table_waitspeak_notify(data)
        end
        return
    end

    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    roomInfo.cur_operation_playerid = data.player_id
    roomInfo.canCompare = data.canCompare
    roomInfo.canBetScoreList = data.canBetScoreList
    -- 刷新第几轮
    roomInfo.cur_circle = data.cur_circle
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

function TableZhaJinHuaLogic:onSeatSpeaking()
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(roomInfo.cur_operation_playerid, roomInfo.seatInfoList)
    --print("=====roomInfo.cur_operation_playerid=",roomInfo.cur_operation_playerid)
    self:hideAllSeatSpeakingTimeLimitEffect()
    if (seatInfo) then
        self.tableView:showSeatTimeLimitEffect(seatInfo, true, 10, nil, -1)
    end
end

function TableZhaJinHuaLogic:xuepin_notify(data)
    print("====血拼xuepin_notify")
    local OpId = data.playerid
    self.tableView:SetState_EffectRanShaoRoot(true)
    local roomInfo = self.modelData.curTableData.roomInfo
    roomInfo.xuepin_status = 1
    roomInfo.xuepin_id = roomInfo.xuepin_id or OpId
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(OpId, roomInfo.seatInfoList)
    if(seatInfo == nil) then
        print("=====seatInfo == nil")
    else
        self:playXuePinSound(seatInfo)
        self:StartSoundXuePinBeiJing()
        self:playCoinChangeSound()
        self.tableView:GoldBullionFlyToPoolFromSeat(seatInfo, self:GetXuePinCount())
        self.tableView:showSeatCostGold(seatInfo, true)
        if(seatInfo == roomInfo.mySeatInfo) then
            self.tableView:StopCoinCountdown()
            self.tableView:SetState_AddBetRoot(false)
            seatInfo.isAlwaysFollow = false
        end
    end
end


-- 弃牌返回
function TableZhaJinHuaLogic:on_table_droppokers_rsp(data)
    print("====弃牌的回复逻辑")
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.zhaJinNiu_state = self.SeatPlayState.hasDrop
    self:RefreshSeatInfo_InHandPokerList(mySeatInfo,data.cards)
    self.tableView:showInHandCards(mySeatInfo, true)
    self.tableView:refreshInHandCards(mySeatInfo, mySeatInfo.inHandPokerListIsRealData, true,true)
    self.tableView:setInHandCardsMaskColor(mySeatInfo, true)
    self.tableView:showZhaJinNiuBtns(false)   
    self.tableView:StopCoinCountdown()
end

-- 弃牌广播
function TableZhaJinHuaLogic:on_table_droppokers_notify(data)
    print("====弃牌广播")
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.playerid, roomInfo.seatInfoList)
    seatInfo.zhaJinNiu_state = self.SeatPlayState.hasDrop
    self.tableView:showSelectCompare(seatInfo, false)
    self.tableView:SwitchState_NewStateRoot(seatInfo)
    self.tableView:setInHandCardsMaskColor(seatInfo, true)
    self:playDropPokerSound(seatInfo)-- 播放弃牌音效
    self.tableView:SwitchState_NewStateRoot(seatInfo)
    self.tableView:SetState_HeadGray(seatInfo,true)
    if(seatInfo == roomInfo.mySeatInfo) then
        self.tableView:StopCoinCountdown()
        self.tableView:SetState_AddBetRoot(false)
    else
        --print("====别人弃牌")
        self.tableView:showSeatCostGold(seatInfo, false)
        self.tableView:showInHandCards(seatInfo, false)
    end
end


function TableZhaJinHuaLogic:on_table_checkpokers_rsp(data)
    print("====看牌的回复逻辑")
    self:hideAllSeatSelectCompare()
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.zhaJinNiu_state = self.SeatPlayState.hasCheck
    self.tableView:SetPokerType(mySeatInfo, true, data.cards)
    self:RefreshSeatInfo_InHandPokerList(mySeatInfo,data.cards)
    self.tableView:showInHandCards(mySeatInfo, true)              --显示牌的节点         
    self.tableView:refreshInHandCards(mySeatInfo, mySeatInfo.inHandPokerListIsRealData, true)     --刷新牌面
    self:playSound_KanPaiFanPai()
    if(self.tableView.toggleFollowAlways.isOn) then
        mySeatInfo.isAlwaysFollow = false
        self.tableView.toggleFollowAlways.isOn = false
        self.tableView:SetFollowAlwaysInstructionsLable(mySeatInfo.isAlwaysFollow and "取消跟注" or "自动跟注")
    end
end

function TableZhaJinHuaLogic:on_table_checkpokers_notify(data)
    print("====看牌广播")
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.playerid, roomInfo.seatInfoList)
    if(seatInfo == nil) then
        print("====没有玩家信息,请检查玩家是否存在Id:",data.playerid)
    else
        self.tableView:showSeatCostGold(seatInfo, true)
        seatInfo.zhaJinNiu_state = self.SeatPlayState.hasCheck --状态
        seatInfo.viewcard = true
        if(seatInfo ~= mySeatInfo) then
            self.tableView:SwitchState_NewStateRoot(seatInfo)
        end
        self:playCheckPokerSound(seatInfo)-- 播放看牌音效
    end
end

function TableZhaJinHuaLogic:new_comparepokers_notify(data)

    self:hideAllSeatSelectCompare()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local srcSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.compare_info.sponsorid, roomInfo.seatInfoList)--发起者
    local dstSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.compare_info.compareid, roomInfo.seatInfoList)--比牌对象
    local winnerSeatInfo = self.tableHelper:getSeatInfoByPlayerId(data.compare_info.winner, roomInfo.seatInfoList)--比牌赢家
    --比牌扔金币
    if(srcSeatInfo == mySeatInfo) then
        self.tableView:StopCoinCountdown()
        self.tableView:SetState_AddBetRoot(false)
    end
    self.tableView:showSeatCostGold(srcSeatInfo, true)
    self.tableView:GoldFlyToPoolFromSeat(srcSeatInfo, data.op_score)
    self:playCoinChangeSound()--播放金币变化音效
    --比牌声音
    self:playComparePokerSound(srcSeatInfo)
    --播放比牌动画
    self:playComparePokerEffectNew(srcSeatInfo,dstSeatInfo,winnerSeatInfo,function ()
        local loserSeatInfo
        if (srcSeatInfo == winnerSeatInfo) then
            loserSeatInfo = dstSeatInfo
        else
            loserSeatInfo = srcSeatInfo
        end
        loserSeatInfo.zhaJinNiu_state = self.SeatPlayState.compareFail
        self.tableView:SetState_HeadGray(loserSeatInfo,true)

        --显示比牌失败
        if (loserSeatInfo == mySeatInfo) then
            print("======自己比牌失败,显示自己的牌")
            self:RefreshSeatInfo_InHandPokerList(mySeatInfo,data.compare_info.cards)
            self.tableView:SwitchState_NewStateRoot(mySeatInfo, true)
            self.tableView:showZhaJinNiuBtns(false)
            self.tableView:refreshInHandCards(mySeatInfo, mySeatInfo.inHandPokerListIsRealData, false,true)
        else
            self.tableView:SwitchState_NewStateRoot(loserSeatInfo)
            self.tableView:showSeatCostGold(loserSeatInfo, false)
            self.tableView:showInHandCards(loserSeatInfo, false)
            self.tableView:SwitchState_NewStateRoot(loserSeatInfo)
        end
        
        self.tableView:setInHandCardsMaskColor(loserSeatInfo, true)

        if (self.delayInvoke_CurrentGameAccount) then
            local fun = self.delayInvoke_CurrentGameAccount
            self.delayInvoke_CurrentGameAccount = nil
            fun()
        end

        if (self.delayInvoke_CheckAlwaysFollow) then
            local fun = self.delayInvoke_CheckAlwaysFollow
            self.delayInvoke_CheckAlwaysFollow = nil
            fun()
        end
        
        if(self.modelData.curTableData.roomInfo.IsGameOverClearTable) then
            self.tableModule:subscibe_time_event(0.3, false, 0):OnComplete(function(t)
                self:GameOverClearTable()
            end)
        end
    end)
end

-- 跟注返回
function TableZhaJinHuaLogic:on_table_callbet_rsp(data)
end

-- 跟注广播
function TableZhaJinHuaLogic:on_table_callbet_notify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    roomInfo.pool_score = data.pool_score

    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.playerid, roomInfo.seatInfoList)
    seatInfo.in_score = data.in_score
    seatInfo.score = data.sur_score
    self.tableView:refreshSeat(seatInfo)
    self.tableView:showSeatCostGold(seatInfo, true)
    if (data.op == 2 or data.op == 3) then
        self:playFollowBetSound(seatInfo) --跟注
    elseif (data.op == 4) then
        self:playRaiseBetSound(seatInfo) --加注
        if(seatInfo == roomInfo.mySeatInfo) then
            self.modelData.curTableData.roomInfo.mySeatInfo.cur_follow_score = data.op_score
        end
    end
    self.tableView:GoldFlyToPoolFromSeat(seatInfo, data.op_score)--飞金币动画
    self:playCoinChangeSound()--播放金币变化音效
    if(seatInfo == roomInfo.mySeatInfo) then
        self.tableView:StopCoinCountdown()
        self.tableView:SetState_AddBetRoot(false)
    end
end


function TableZhaJinHuaLogic:onclick_start_btn(obj)
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

function TableZhaJinHuaLogic:onclick_ready_btn(obj)
    if(self.tableView:isJinBiChang()) then
        
    else
        if (self.tableHelper:getSeatedSeatCount(self.modelData.curTableData.roomInfo.seatInfoList) == 1) then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("至少需要两位玩家")
            return
        end
    end

    if (self.waitReadyTimeEventId) then
        CSmartTimer:Kill(self.waitReadyTimeEventId)
        self.waitReadyTimeEventId = nil
    end
    self.tableModel:request_ready()
end

-- 点击继续按钮
function TableZhaJinHuaLogic:onclick_continue_btn(obj)
    if (self.modelData.curTableData.roomInfo.isRoomEnd) then
        if(self.tableresultEvent) then
            self.tableresultEvent()
        end
        return
    else
        -- 停止播放结果音效
        --self.tableHelper:playResultSound(false, self.curRoundScore and self.curRoundScore > 0)
        --if (self.waitReadyTimeEventId) then
        --    CSmartTimer:Kill(self.waitReadyTimeEventId)
        --    self.waitReadyTimeEventId = nil
        --end
        self.tableModel:request_ready()
    end
end

function TableZhaJinHuaLogic:resetSeatHolderArray(seatCount)
    local newSeatHolderArray = { }
    local seatHolderArray = self.tableView.srcSeatHolderArray
    -- local maxPlayerCount = seatCount
    -- if (maxPlayerCount == 3) then
    --     newSeatHolderArray[1] = seatHolderArray[1]
    --     newSeatHolderArray[2] = seatHolderArray[3]
    --     newSeatHolderArray[3] = seatHolderArray[5]
    -- elseif (maxPlayerCount == 4) then
    --     newSeatHolderArray[1] = seatHolderArray[1]
    --     newSeatHolderArray[2] = seatHolderArray[3]
    --     newSeatHolderArray[3] = seatHolderArray[4]
    --     newSeatHolderArray[4] = seatHolderArray[5]
    -- elseif (maxPlayerCount == 5) then
    --     newSeatHolderArray[1] = seatHolderArray[1]
    --     newSeatHolderArray[2] = seatHolderArray[3]
    --     newSeatHolderArray[3] = seatHolderArray[4]
    --     newSeatHolderArray[4] = seatHolderArray[5]
    --     newSeatHolderArray[5] = seatHolderArray[6]
    -- else
    --     newSeatHolderArray = seatHolderArray
    -- end
    newSeatHolderArray = seatHolderArray

    -- for i, v in ipairs(seatHolderArray) do
    --     ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, false)
    -- end
    -- for i, v in ipairs(newSeatHolderArray) do
    --     ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, true)
    -- end
    self.tableView.seatHolderArray = newSeatHolderArray
    
end

-- 初始化相关数据
function TableZhaJinHuaLogic:initTableSeatData(data)
    self.isDataInited = true
    self.modelData.curTableData = { }
    -- 缓存房间信息
    local roomInfo = { }
    roomInfo.roomNum = data.room_id
    roomInfo.roomType = 1
    roomInfo.rule = self.modelData.roleData.myRoomSeatInfo.Rule      --规则字符串
    print("====房间规则:"..tostring(roomInfo.rule))
    roomInfo.ruleTable = ModuleCache.Json.decode(roomInfo.rule)      --规则table
    roomInfo.ruleDesc = "炸金花"
    roomInfo.curRoundNum = data.game_loop_cnt or 0        --当前局数
    roomInfo.totalRoundCount = data.game_total_cnt or 0   --总局数
    roomInfo.cur_operation_playerid = data.cur_operation_player or 0 --当前操作的玩家id
    roomInfo.timeOffset = data.time - os.time()            --服务器时间cuo
    roomInfo.cur_base_score = data.rate or 1                  --底分
    roomInfo.is_deal = data.is_deal                        --是否已经发牌  
    roomInfo.cur_score = data.cur_score                    --当前跟注的筹码
    roomInfo.brankerid = data.brankerid                    --庄家id
    roomInfo.cur_circle = data.cur_circle or 0             --下注的当前轮数 
    roomInfo.max_circle = data.max_circle or 0             --下注的上限轮数
    roomInfo.state = data.room_state                       --房间状态
    roomInfo.pool_score = data.pool_score or 0             --奖池中的分数

    roomInfo.pool_gold = data.pool_gold                    --奖池金币
    roomInfo.baseCoinScore = data.baseCoinScore            --金币底分
    roomInfo.feeNum = data.feeNum                          --台费
    roomInfo.auto_ready_time = data.auto_ready_time        --倒计时时间
    roomInfo.auto_op_time = data.auto_op_time              --操作倒计时时间
    roomInfo.xuepin_status = data.xuepin_status            --血拼状态
    roomInfo.xuepin_id = data.xuepin_id                    --血拼发起者

    roomInfo.owner = data.owner                            --房主

    roomInfo.minJoinCoin = data.minJoinCoin
    roomInfo.minForceExitCoin = data.minForceExitCoin
    roomInfo.curRoundWinner = data.winner
    self.modelData.curTableData.roomInfo = roomInfo
    if (roomInfo.state == RoomState.waitReady) then
        roomInfo.roundStarted = false
    else
        roomInfo.roundStarted = true
    end
    -- 缓存座位信息
    local remoteSeatInfoList = data.players
    local seatInfoList = { }
    local seatCount = #remoteSeatInfoList
    for i = 1, #remoteSeatInfoList do
        local remoteSeatInfo = remoteSeatInfoList[i]
        local seatInfo = { }
        seatInfo.seatIndex = remoteSeatInfo.player_pos
        seatInfo.playerId = tostring(remoteSeatInfo.player_id or 0)
        seatInfo.isSeated = self:getBoolState(remoteSeatInfo.player_id)             --判断座位上是否有玩家	
        seatInfo.isBanker = remoteSeatInfo.player_id == roomInfo.brankerid          --是否是庄家
        seatInfo.isCreator = self:getBoolState(remoteSeatInfo.is_owner) or false    --是否是房主
        seatInfo.isReady = self:getBoolState(remoteSeatInfo.is_ready) or false      --是否准备
        --seatInfo.betScore =(seatInfo.isSeated and remoteSeatInfo.bet) or 0
        seatInfo.score = remoteSeatInfo.score or 0              --玩家本次加入的房间总积分
        seatInfo.winTimes = remoteSeatInfo.win_cnt or 0         --玩家房间内赢的次数
        seatInfo.lostTimes = remoteSeatInfo.lost_cnt or 0       --玩家房间内输的次数
        seatInfo.isOffline = remoteSeatInfo.is_offline          --玩家是否掉线
        seatInfo.viewcard = remoteSeatInfo.viewcard             --玩家是否已看牌
        seatInfo.compareidList = remoteSeatInfo.compareid
        if (remoteSeatInfo.play_state == 0) then
            seatInfo.zhaJinNiu_state = self.SeatPlayState.notStart
        elseif (remoteSeatInfo.play_state == 2) then
            seatInfo.zhaJinNiu_state = self.SeatPlayState.hasDrop
        elseif (remoteSeatInfo.play_state == 3) then
            seatInfo.zhaJinNiu_state = self.SeatPlayState.compareFail
        elseif (seatInfo.viewcard) then
            seatInfo.zhaJinNiu_state = self.SeatPlayState.hasCheck
        else
            seatInfo.zhaJinNiu_state = self.SeatPlayState.hasNotCheck
        end
        seatInfo.in_score = remoteSeatInfo.in_score or 0        --玩家这局已经下了注在奖金池中的分数
        seatInfo.coinBalance = remoteSeatInfo.coinBalance or 0
        seatInfo.in_gold = remoteSeatInfo.in_gold or 0
        seatInfo.cur_follow_score = remoteSeatInfo.cur_follow_score  --当前实际跟注的筹码

        seatInfo.cur_game_loop_cnt = remoteSeatInfo.cur_game_loop_cnt or 0

        table.insert(seatInfoList, seatInfo)
        if (seatInfo.isSeated) then
            self.tableModule:addSeatInfo2ChatCurTableData(seatInfo)
        end
        -- 绑定玩家到座位
        if (self:getBoolState(remoteSeatInfo.player_id)) then
            -- 判断是否玩家自己，单独记录自己的座位
            if (tonumber(seatInfo.playerId) == tonumber(self.modelData.curTablePlayerId)) then
                self.modelData.curTableData.roomInfo.mySeatInfo = seatInfo
                seatInfo.isOffline = false
            end
        end

        self:RefreshSeatInfo_InHandPokerList(seatInfo,remoteSeatInfo.cards)

        --if(roomInfo.roundStarted and seatInfo.zhaJinNiu_state == self.SeatPlayState.notStart) then
        --    seatInfo.isWatchState = true
        --else
        --    seatInfo.isWatchState = false
        --end
        if(self:IsGameDoing() and seatInfo.zhaJinNiu_state == self.SeatPlayState.notStart) then
            seatInfo.isWatchState = true
        else
            seatInfo.isWatchState = false
        end
        print("123=====",seatInfo.playerId,tostring(seatInfo.isWatchState))
    end

    self:resetSeatHolderArray(seatCount)
    local mySeatIndex = self.modelData.curTableData.roomInfo.mySeatInfo.seatIndex
    for i = 1, seatCount do
        local seatInfo = seatInfoList[i]
        if (roomInfo.roundStarted) then
            seatInfoList[i].curRound = { }
        end
        -- 转换为本地位置索引
        seatInfoList[i].localSeatIndex = self.tableHelper:getLocalIndexFromRemoteSeatIndex(seatInfoList[i].seatIndex, mySeatIndex, 6)
    end
    roomInfo.seatInfoList = seatInfoList
    roomInfo.IsGameOverClearTable = false
    print_table(roomInfo)
end

function TableZhaJinHuaLogic:getBoolState(value)
    if (value) then
        return value ~= 0 and value ~= "0"
    else
        return false
    end
end

function TableZhaJinHuaLogic:refreshMyTableViewState()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if (mySeatInfo.isWatchState) then
        if(self:IsWaitReadyState()) then
            --print("=======等待此牌局结束1")
        else
            --print("====等待此牌局结束2")
            self.tableView:showCenterTips(true, self.tableView:GetWatchStateShowText())
        end
        return
    end
    self.tableView:showCenterTips(false)

    -- 是否要显示开始按钮	
    local isAllPlayerReady, seatedCount = self.tableHelper:checkIsAllReady(roomInfo.seatInfoList)
    local canStartRound = roomInfo.state == RoomState.waitReady and(not roomInfo.roundStarted) and isAllPlayerReady and seatedCount > 1

    if (canStartRound and mySeatInfo.isCreator and roomInfo.curRoundNum ~= 0 and(not self.startRequested)) then
        self.startRequested = true
        self.tableModel:request_start()
    end
end

function TableZhaJinHuaLogic:resetRoundState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        seatInfo.curRound = nil
        seatInfo.isReady = false
        seatInfo.isBanker = false
        seatInfo.betScore = 0
        seatInfo.isDoneComputeNiu = false
        -- 是否已经结算		
        seatInfo.inHandPokerList = { }
        seatInfo.zhaJinNiu_state = self.SeatPlayState.hasNotCheck
        -- 0:未看牌,1:已看牌,2:弃牌
        seatInfo.zhaJinNiu_betScore = 0
        -- 已下注的分数
        seatInfo.combo_type = nil
    end
    self.modelData.curTableData.roomInfo.roundStarted = false
    self.modelData.curTableData.roomInfo.pool_score = 0
end

function TableZhaJinHuaLogic:refreshResetState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        self.tableView:showNiuName(seatInfo, false)
        self.tableView:refreshSeat(seatInfo, false)
    end
    self:refreshMyTableViewState()
    self:HideContinueBtn()
end

function TableZhaJinHuaLogic:HideContinueBtn()
    if (self.waitReadyTimeEventId) then
        CSmartTimer:Kill(self.waitReadyTimeEventId)
        self.waitReadyTimeEventId = nil
    end
    self.tableView:showContinueBtn(false)
end


function TableZhaJinHuaLogic:playFaPaiAnim(seatInfo, onFinish)
    local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
    local delay = 0.2
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

            self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration,(i - 1) * delay, function()
                ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.x, true)
                ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.y, true)
            end )
            self.tableHelper:playCardScaleAnim(cardHolder, cardHolder.cardLocalScale.x, duration,(i - 1) * delay, function()
                self:playSound_FaPai()
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

            self.tableHelper:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration,(index - 1) * 0.1, function()
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

function TableZhaJinHuaLogic:getServerNowTime()
    return self.modelData.curTableData.roomInfo.timeOffset + os.time() + 1
end


-- 隐藏所有的比牌选择框
function TableZhaJinHuaLogic:hideAllSeatSelectCompare()
    self.tableView:SetComparePokerSelectTimeDown(false)
    local roomInfo = self.modelData.curTableData.roomInfo
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = roomInfo.seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            self.tableView:showSelectCompare(seatInfo, false)
        end
    end
end

-- 隐藏所有座位的倒计时
function TableZhaJinHuaLogic:hideAllSeatSpeakingTimeLimitEffect()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        self.tableView:showSeatTimeLimitEffect(seatInfoList[i], false)
    end
end

function TableZhaJinHuaLogic:onClickComparePokerBtn(obj, arg)
    print("==点击比牌按钮")
    self.tableModel:request_CompareListReq()
end

function TableZhaJinHuaLogic:onClickDropPokerBtn(obj, arg)
    print("==点击弃牌按钮")
    self.isDelayAlwaysFollow = false
    local verify_circle = self.modelData.curTableData.roomInfo.cur_verify_circle 
    self.tableModel:request_operation(verify_circle,6)
end

function TableZhaJinHuaLogic:onclick_check_pokers_btn(obj, arg)
    print("==点击看牌按钮")
    local verify_circle = self.modelData.curTableData.roomInfo.cur_verify_circle 
    self.tableModel:request_operation(verify_circle,1)
end


function TableZhaJinHuaLogic:onclick_XuePinBtn(obj, arg)
    print("=====点击血拼按钮")
    local verify_circle = self.modelData.curTableData.roomInfo.cur_verify_circle
    self.tableModel:request_operation(verify_circle,8)
end

function TableZhaJinHuaLogic:onclick_BtnXuePinFollow(obj, arg)
    print("=====点击血拼!比牌按钮")
    local verify_circle = self.modelData.curTableData.roomInfo.cur_verify_circle
    self.tableModel:request_operation(verify_circle,8)
end

function TableZhaJinHuaLogic:onclick_follow_always_btn(obj, arg)
    print("==点击跟到底按钮")
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    mySeatInfo.isAlwaysFollow = self.tableView.toggleFollowAlways.isOn
    self.tableView:SetFollowAlwaysInstructionsLable(mySeatInfo.isAlwaysFollow and "取消跟注" or "自动跟注")
    self:RefreshMyCurOperationState()
    self:GlobalOperation()
end

function TableZhaJinHuaLogic:onclick_raise_btn(obj, arg)
    print("==点击加注按钮")
    if(self:IsMyCurOperation()) then
        local roomInfo = self.modelData.curTableData.roomInfo
        if(#roomInfo.canBetScoreList > 1) then
            local score = roomInfo.canBetScoreList[2]
            if(score == nil or score <=0) then
                print("==点击跟牌按钮_加注分数有问题")
            end
            self.isDelayAlwaysFollow = false
            local verify_circle = roomInfo.cur_verify_circle
            self.tableModel:request_operation(verify_circle,4,score)
        else
            print("==点击跟牌按钮_不可加注")
        end
    else
        print("==点击跟牌按钮_不是我操作")
    end
end

function TableZhaJinHuaLogic:onclick_follow_btn(obj, arg)
    print("==点击跟注按钮")
    if(self:IsMyCurOperation()) then
        local roomInfo = self.modelData.curTableData.roomInfo
        self.isDelayAlwaysFollow = false
        local verify_circle = roomInfo.cur_verify_circle
        local actionId = 3 --跟注
        if(roomInfo.cur_op_list.xiazhu) then
            actionId = 2 --下注
        end
        local locCount = self:GetMySelf_cur_follow_score()
        self.tableModel:request_operation(verify_circle,actionId,locCount)
    else
        print("==点击跟牌按钮_不是我操作")
    end
end

function TableZhaJinHuaLogic:onclick_more_btn(obj, arg)
    print("==点击更多按钮展开加注的分数")
    local isShow = not self.tableView.AddBetRoot.activeInHierarchy
    self.tableView:SetState_AddBetRoot(isShow)
    if(isShow) then
        local cur_op_list = self.modelData.curTableData.roomInfo.cur_op_list
        if(cur_op_list and cur_op_list.add_list and #cur_op_list.add_list > 0) then
            self.tableView:SetAddBetBtnListShow(cur_op_list.add_list)
        end
    end
end

function TableZhaJinHuaLogic:onclick_hide_more_btn(obj, arg)
    print("==点击更多按钮隐藏")
    local roomInfo = self.modelData.curTableData.roomInfo
    self.tableView:showBtnAdd(true, #roomInfo.canBetScoreList > 2)
    self.tableView:showBetBtns(false)
end

function TableZhaJinHuaLogic:onclick_more_bet_btn(obj, arg)
    print("==点击更多里面的加注分数")
    local roomInfo = self.modelData.curTableData.roomInfo
    for i = 3, 20 do
        local btnName = "ButtonBet" .. i
        if (obj.name == btnName) then
            print("==点击更多里面的加注分数_加注分数=",i)
            self.isDelayAlwaysFollow = false
            local verify_circle = roomInfo.cur_verify_circle
            local locAddScore = i
            self.tableModel:request_operation(verify_circle,4,locAddScore)
        end
    end
end

function TableZhaJinHuaLogic:onclick_AddBetBtn(obj, arg)
    print("==点击新的加注分数=",obj.name)
    local roomInfo = self.modelData.curTableData.roomInfo
    self.isDelayAlwaysFollow = false
    local verify_circle = roomInfo.cur_verify_circle
    self.tableModel:request_operation(verify_circle,4,tonumber(obj.name))
end

function TableZhaJinHuaLogic:onclick_selectCompare(obj, arg)
    print("==点击比牌选择框")
    local roomInfo = self.modelData.curTableData.roomInfo
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = roomInfo.seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
            if (obj == seatHolder.goSelectCompare) then
                self.compare_target_player_id = seatInfo.playerId
                self.isDelayAlwaysFollow = false
                local verify_circle = roomInfo.cur_verify_circle
                self.tableModel:request_operation(verify_circle,5,nil,tonumber(seatInfo.playerId))
                return
            end
        end
    end
end

function TableZhaJinHuaLogic:onclick_selectCompareMask(obj, arg)
    print("==点击选择比牌Mask")
    self:hideAllSeatSelectCompare()
end

function TableZhaJinHuaLogic:playComparePokerEffect(srcSeatInfo, dstSeatInfo, winnerSeatInfo, onFinish)
    --print("=======playComparePokerEffect1")
    --local roomInfo = self.modelData.curTableData.roomInfo
    --local mySeatInfo = roomInfo.mySeatInfo
    --local leftSeatInfo = srcSeatInfo
    --local rightSeatInfo = dstSeatInfo
    --local isLeftWin = leftSeatInfo == winnerSeatInfo
    --self.isPlayingComparePoker = true
    --self.tableView:showMask(true)
    --print("=======playComparePokerEffect2")
    --print("1====左边飞")
    --self.tableView:showSeatPokerFly2ComparePosEffect(leftSeatInfo, true, true, function()
    --    print("2====PK动画")
    --    self.tableView:showConstrastEffect(true, isLeftWin, function()
    --        print("3====隐藏PK动画")
    --        self.tableView:showConstrastEffect(false)
    --        print("3====左边回去")
    --        self.tableView:showComparePokerFly2SeatPosEffect(leftSeatInfo, true, true, function()
    --            print("4====回去后重置")
    --            self.isPlayingComparePoker = false
    --            self.tableView:showComparePokerFly2SeatPosEffect(leftSeatInfo, false)
    --            self.tableView:showMask(false)
    --            if (onFinish) then
    --                onFinish()
    --            end
    --        end)
    --        print("3====右边回去")
    --        self.tableView:showComparePokerFly2SeatPosEffect(rightSeatInfo, true, false, function()
    --            print("4====回去后重置")
    --            self.tableView:showComparePokerFly2SeatPosEffect(rightSeatInfo, false,false)
    --        end)
    --    end)
    --end)
    --
    --print("1====右边飞")
    --self.tableView:showSeatPokerFly2ComparePosEffect(rightSeatInfo, true, false, function()
    --
    --end)
end

function TableZhaJinHuaLogic:playComparePokerEffectNew(srcSeatInfo, dstSeatInfo, winnerSeatInfo, onFinish)
    print("=======playComparePokerEffect1")
    local roomInfo = self.modelData.curTableData.roomInfo
    --local mySeatInfo = roomInfo.mySeatInfo
    local leftSeatInfo = srcSeatInfo
    local rightSeatInfo = dstSeatInfo
    local isLeftWin = leftSeatInfo == winnerSeatInfo
    local seatHolderLeft = self.tableView:GetSeatHolderBySeatInfo(leftSeatInfo)
    local seatHolderRight = self.tableView:GetSeatHolderBySeatInfo(rightSeatInfo)
    self.isPlayingComparePoker = true

    local PKWinRoot = self.tableView.PK_Left_Win_Go
    local PKAnimator = self.tableView.PK_Left_Win_Animator
    if(isLeftWin) then
    else
        PKWinRoot = self.tableView.PK_Right_Win_Go
        PKAnimator = self.tableView.PK_Right_Win_Animator
    end
    local ZuoBianHead = GetComponentWithPath(PKWinRoot.gameObject,"ZuoBian/Avatar/Mask/Image", ComponentTypeName.Image)
    local ZuoBianHeadGray = GetComponentWithPath(PKWinRoot.gameObject,"ZuoBian/Avatar/Mask/HeadGray", ComponentTypeName.Image)
    local ZuoBianName = GetComponentWithPath(PKWinRoot.gameObject,"ZuoBian/TextName", ComponentTypeName.Text)
    local YouBianHead = GetComponentWithPath(PKWinRoot.gameObject,"YouBian /Avatar/Mask/Image", ComponentTypeName.Image)
    local YouBianHeadGray = GetComponentWithPath(PKWinRoot.gameObject,"YouBian /Avatar/Mask/HeadGray", ComponentTypeName.Image)
    local YouBianName = GetComponentWithPath(PKWinRoot.gameObject,"YouBian /TextName", ComponentTypeName.Text)
    ZuoBianHead.sprite = seatHolderLeft.imagePlayerHead.sprite
    ZuoBianName.text = seatHolderLeft.textPlayerName.text
    YouBianHead.sprite = seatHolderRight.imagePlayerHead.sprite
    YouBianName.text = seatHolderRight.textPlayerName.text
    ModuleCache.ComponentUtil.SafeSetActive(ZuoBianHeadGray.gameObject, not isLeftWin)
    ModuleCache.ComponentUtil.SafeSetActive(YouBianHeadGray.gameObject, isLeftWin)
    ModuleCache.ComponentUtil.SafeSetActive(self.tableView.PokerPKRoot.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(PKWinRoot.gameObject, true)
    self.tableModule:subscibe_time_event(0.4, false, 0):OnComplete( function(t)
        ModuleCache.SoundManager.play_sound("zhajinhua", "zhajinhua/sound/zhajinniu/b_bipaijianguang.bytes", "b_bipaijianguang")
    end)

    self.tableModule:subscibe_time_event(2.5, false, 0):OnComplete( function(t)
        ModuleCache.ComponentUtil.SafeSetActive(self.tableView.PokerPKRoot.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(PKWinRoot.gameObject, false)
        self.isPlayingComparePoker = false
        if (onFinish) then
            onFinish()
        end
    end)
end

-- 播放比牌特效
function TableZhaJinHuaLogic:playComparePokerEffect2(srcSeatInfo, dstSeatInfo, winnerSeatInfo, onFinish)
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local leftSeatInfo
    local rightSeatInfo
    if (srcSeatInfo == mySeatInfo) then
        if (dstSeatInfo.localSeatIndex <= 3) then
            leftSeatInfo = mySeatInfo
            rightSeatInfo = dstSeatInfo
        else
            leftSeatInfo = dstSeatInfo
            rightSeatInfo = mySeatInfo
        end
    elseif (dstSeatInfo == mySeatInfo) then
        if (srcSeatInfo.localSeatIndex <= 3) then
            leftSeatInfo = mySeatInfo
            rightSeatInfo = srcSeatInfo
        else
            leftSeatInfo = srcSeatInfo
            rightSeatInfo = mySeatInfo
        end
    else
        if (srcSeatInfo.localSeatIndex < dstSeatInfo.localSeatIndex) then
            leftSeatInfo = dstSeatInfo
            rightSeatInfo = srcSeatInfo
        else
            leftSeatInfo = srcSeatInfo
            rightSeatInfo = dstSeatInfo
        end
    end

    local isLeftWin = leftSeatInfo == winnerSeatInfo
    self.isPlayingComparePoker = true
    self.tableView:showMask(true)
    self.tableView:showSeatPokerFly2ComparePosEffect(leftSeatInfo, true, true, function()
        self.tableView:showConstrastEffect(true, isLeftWin, function()
            self.tableView:showConstrastEffect(false)
            self.tableView:showComparePokerFly2SeatPosEffect(leftSeatInfo, true, true, function(...)
                self.tableView:showComparePokerFly2SeatPosEffect(leftSeatInfo, false)
                self.isPlayingComparePoker = false
                self.tableView:showMask(false)
                if (onFinish) then
                    onFinish()
                end
            end )
            self.tableView:showComparePokerFly2SeatPosEffect(rightSeatInfo, true, false, function(...)
                self.tableView:showComparePokerFly2SeatPosEffect(rightSeatInfo, false)
            end )
        end )
    end )
    self.tableView:showSeatPokerFly2ComparePosEffect(rightSeatInfo, true, false, function()
    end )
end



function TableZhaJinHuaLogic:playComparePokerSound(seatInfo)
    --print("==播放比牌音效")
    local soundName = self:getSoundHead(seatInfo) .. "compare_poker"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playDropPokerSound(seatInfo)
    --print("==播放弃牌音效")
    local soundName = self:getSoundHead(seatInfo) .. "drop_poker" .. self:getRandomNumber(1, 2)
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playCheckPokerSound(seatInfo)
    --print("==播放看牌音效")
    local soundName = self:getSoundHead(seatInfo) .. "check_poker" .. self:getRandomNumber(1, 2)
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playFollowBetSound(seatInfo)
    --print("==播放跟注音效")
    local soundName = self:getSoundHead(seatInfo) .. "follow_bet" .. self:getRandomNumber(1, 2)
    ModuleCache.SoundManager.play_sound(BranchPackageName,BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playRaiseBetSound(seatInfo)
    --print("==播放加注音效")
    local soundName = self:getSoundHead(seatInfo) .. "raise_bet" .. self:getRandomNumber(1, 2)
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playCoinChangeSound(seatInfo)
    --print("==播放金币变化音效")
    local soundName = "coin_change"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playCoinFlySound(seatInfo)
    --print("==播放金币飞翔音效")
    local soundName = "coin_fly"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playXuePinSound(seatInfo)
    --print("==播放血拼音效")
    local soundName = self:getSoundHead(seatInfo) .. "xuepin1"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playSound_XuePinBeiJing()
    local soundName = "bgm_xuepin"
    --print("==播放血拼背景音效")
    ModuleCache.SoundManager.play_music(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName,true)
end

function TableZhaJinHuaLogic:StartSoundXuePinBeiJing()
    self:playSound_XuePinBeiJing()
end

function TableZhaJinHuaLogic:StopSoundXuePinBeiJing()
    if(self:IsXuePinDoing()) then
        ModuleCache.SoundManager.stop_music()
    end

end

function TableZhaJinHuaLogic:playSound_FaPai()
    --print("==播放发牌音效")
    local soundName = "b_fapai"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playSound_KanPaiFanPai()
    --print("==播放看牌翻牌音效")
    local soundName = "b_kanpaifanpai"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playSound_YingJiaZhanShi()
    --print("==播放赢家展示音效")
    local soundName = "b_yingjiazhanshi"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playSound_DaoJiShi()
    --print("==播放赢家展示音效")
    local soundName = "b_daojishi"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end

function TableZhaJinHuaLogic:playSound_PaioShuZi()
    --print("==播放飘数字音效")
    local soundName = "b_piaoshuzi"
    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
end



function TableZhaJinHuaLogic:getSoundHead(seatInfo)
    if (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
        return "female_"
    else
        return "male_"
    end
end

function TableZhaJinHuaLogic:getRandomNumber(min, max)
    local val = math.random(min, max)
    return val
end

function TableZhaJinHuaLogic:startWaitContinue()
    self.tableView:showContinueBtn(true)

    --if (self.waitReadyTimeEventId) then
    --    CSmartTimer:Kill(self.waitReadyTimeEventId)
    --    self.waitReadyTimeEventId = nil
    --end
    --local duration = self.modelData.curTableData.roomInfo.autoready_time or 5
    --self.continueShowStartTime = Time.realtimeSinceStartup
    ----self.tableView:refreshContinueTimeLimitText(duration)
    --local timeEvent = self.tableModule:subscibe_time_event(duration, false, 0):OnComplete( function(t)
    --end ):SetIntervalTime(0.05, function(t)
    --    local leftSecs = math.ceil(self.continueShowStartTime + duration - Time.realtimeSinceStartup)
    --    if(leftSecs >= 0) then
    --        --self.tableView:refreshContinueTimeLimitText(leftSecs)
    --        self.tableView:showContinueBtn(true)
    --    end
    --end )
    --self.waitReadyTimeEventId = timeEvent.id;
end

------收到包:客户自定义的信息变化广播
function TableZhaJinHuaLogic:on_table_CustomInfoChangeBroadcast(data)
    --print("==on_table_CustomInfoChangeBroadcast")
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
                if (seatInfo.playerInfo == nil) then
                    print("====seatInfo.playerInfo == nil")
                else
                    seatInfo.playerInfo.locationData = seatInfo.playerInfo.locationData or { }
                    seatInfo.playerInfo.locationData.address = locTable.address
                    seatInfo.playerInfo.locationData.gpsInfo = locTable.gpsInfo
                end
            end
        end
    end

    self.tableView:CheckLocationUI()
end

function TableZhaJinHuaLogic:hide_start_btn()
    local roomInfo = self.modelData.curTableData.roomInfo
    -- 隐藏开始按钮
    self.startRequested = false
end

function TableZhaJinHuaLogic:on_table_gameinfo(data)
    --print("======on_table_gameinfo")
    self.tableView:showCenterTips(false)-- 隐藏tips
    if (self.tableView.goldList and #self.tableView.goldList > 0) then
        for i = 1, #self.tableView.goldList do
            local goGold = self.tableView.goldList[i]
            UnityEngine.GameObject.Destroy(goGold)
        end
        self.tableView.goldList = { }
    end
    --初始化数据
    self:initTableSeatData(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    if(roomInfo.curRoundNum == 0 and #roomInfo.seatInfoList ~= roomInfo.maxPlayerCount)then
        self.tableModule:refresh_share_clip_board()
    else
        self.tableModule:clean_share_clip_board()
    end
    local mySeatInfo = roomInfo.mySeatInfo
    self.tableView:setRoomInfo(roomInfo)--刷新房间信息显示
    --刷新每个座位状态的显示
    local seatList = roomInfo.seatInfoList
    for i = 1, #seatList do
        local seatInfo = seatList[i]
        self.tableView:refreshSeat(seatInfo)
        --self.tableView:showSeatCostGold(seatInfo,roomInfo.roundStarted and not seatInfo.isWatchState) --刷新座位上已经下注的分数
    end
    self:refreshMyTableViewState()-- 刷新玩家自己桌面

    if roomInfo.curRoundNum == 0 then
        self.tableView:refreshReadyState(mySeatInfo.isCreator)-- 刷新准备状态
    else
        self.tableView:hideAllReadyButton()-- 隐藏所有选择按钮
    end

    if self.modelData.roleData.RoomType == 2 then--亲友圈快速组局
        --TODO XLQ:亲友圈快速组局
        self.tableView:MuseumReadyState(not mySeatInfo.isReady)
    end

    self.tableView:showBetBtns(false)

    if(self:IsGameDoing()) then
         print("======断线重连显示牌的状态")
        local seatInfoList = roomInfo.seatInfoList
        for i=1,#seatInfoList do
            local seatInfo = seatInfoList[i]
            if(seatInfo.isWatchState) then
                -- print("====等待此牌局结束isWatchState")
                if(seatInfo == mySeatInfo) then
                    self.tableView:showCenterTips(self.tableView:isJinBiChang(), self.tableView:GetWatchStateShowText())
                end
                self.tableView:showInHandCards(seatInfo, false)
                if(seatInfo.isReady) then
                    self.tableView:refreshSeatInfoImageReadyState(seatInfo)
                end
            else
                local locIsShow = false
                if(seatInfo == mySeatInfo) then
                    locIsShow = true
                else
                    if(seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop or seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail) then
                        locIsShow = false
                    else
                        locIsShow = true
                        self.tableView:SwitchState_NewStateRoot(seatInfo)
                    end
                end
                self.tableView:showCenterTips(false)
                self.tableView:showSeatCostGold(seatInfo, locIsShow)
                self.tableView:showInHandCards(seatInfo, locIsShow)
                self.tableView:refreshInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData, false)
            end
        end

        if(self:IsXuePinDoing()) then
            self.tableView:SetState_EffectRanShaoRoot(true)
        end
    end


    --这些放到最后面刷新
    if(roomInfo.pool_score > 0) then
        self.tableView:showCurRoundBetScore(true)--断线重连显示牌桌的金币数量文本
        if(not self:IsWaitReadyState()) then
            self.tableView:PoolScoreShowGold(roomInfo.pool_score)         --断线重连显示牌桌的金币
        end
    end
    
    self:CheckMyPokerType()--检查我的牌型
    self:CheckSeatState()--检查座位的状态


    if(self:IsWaitReadyState()) then
        print("====是否有继续游戏的按钮:等待准备")
        self:HideAllPlayerFlashingEffect()
        roomInfo.cur_circle = 0
        self.tableView:setRoomInfo(roomInfo)
        if(mySeatInfo.isReady) then
            self.tableView:refreshSeatInfoImageReadyState(mySeatInfo)
        else
            if(self.tableView:isJinBiChang()) then
            else
                self:startWaitContinue()
            end
        end

        local locWinSeatInfo = nil
        if(roomInfo.curRoundWinner and roomInfo.curRoundWinner > 0) then
            locWinSeatInfo = self.tableHelper:getSeatInfoByPlayerId(roomInfo.curRoundWinner,roomInfo.seatInfoList)
        end

        local seatInfoList = roomInfo.seatInfoList
        for i=1,#seatInfoList do
            local seatInfo = seatInfoList[i]
            self.tableView:refreshSeatInfoImageReadyState(seatInfo)
            if(seatInfo.isWatchState) then
                -- print("====刚刚进来的没开始玩的玩家")
                self.tableView:SetPokerType(seatInfo, false)
            elseif seatInfo.isReady then

            else
                local locIsShow = false
                if(seatInfo == mySeatInfo) then
                    locIsShow = true
                else
                    if(seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop or seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail) then
                        locIsShow = false
                    else
                        locIsShow = true
                    end
                end
                --print("==============seatInfo.zhaJinNiu_state",seatInfo.zhaJinNiu_state)
                --print("==============locIsShow",locIsShow)
                if(self.tableView:isJinBiChang()) then
                    self.tableView:showSeatCostGold(seatInfo, locIsShow)
                    self.tableView:showInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData)
                    self.tableView:refreshInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData, false,true)
                else
                    self.tableView:showSeatCostGold(seatInfo, locIsShow)
                    self.tableView:showInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData)
                    self.tableView:refreshInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData, false,true)
                    if(locIsShow) then
                        if(locWinSeatInfo and locWinSeatInfo == seatInfo) then

                        else
                            self.tableView:setInHandCardsMaskColor(seatInfo, true)
                        end
                    end
                end
            end
        end
        self.tableView:ClearAllNewStateRoot()
    else
        self:SetCurOperationPlayerFlashingEffect() --到谁出牌的的闪烁效果
    end

    self.tableView:CheckUI()
    if(self.tableView:isJinBiChang()) then
        if(mySeatInfo.isReady)  then
            self.tableView:StopCoinCountdown()
            self.tableView:SetJinBiChangStateSwitcher(false)
        else
            --self.tableView:StartCoinCountdown(roomInfo.auto_ready_time)
            --self.tableView:SetJinBiChangStateSwitcher("Center",roomInfo.auto_ready_time)
            if(mySeatInfo.isWatchState) then
                --self.tableView:showCenterTips(false)
                self.tableView:StopCoinCountdown()
            end
        end
    end

    self:CheckReadyState()--检查准备按钮
    self:CheckHeadGray()
    self.tableView:CheckCreatorIcon()
end


----扣除底注发牌通知
function TableZhaJinHuaLogic:DeductNotify(data)
    self:hide_start_btn()
    self:HideContinueBtn()
    self.tableView:hideAllReadyButton()
    self.tableView:SetJinBiChangStateSwitcher(false)
    self.tableView:ReplaceTableNow()
    self.tableView:SetState_WaitOthersReadyRoot(false)
    self.tableView:SetState_AddBetRoot(false)
    self.tableView:SetState_MyWinEffectRoot(false)
    self:ResetXuePin()
    self.tableView:ResetAllRechargeSatus()
    self.tableView:SetFollowAlwaysInstructionsLable("自动跟注")
    self.tableView:ResetAllPlayerHeadGray()
    local roomInfo = self.modelData.curTableData.roomInfo
    roomInfo.pool_score = data.pool_score
    roomInfo.curRoundNum = data.game_loop_cnt
    roomInfo.brankerid = data.brankerid
    roomInfo.pool_gold = data.pool_gold

    if(self.tableView:isJinBiChang()) then
        if(roomInfo.feeNum and roomInfo.feeNum > 0) then
            self.tableView:SetTipsServiceFee(roomInfo.feeNum)
        else
            print("warning====服务器没有发送台费过来")
        end
    end

    if(data.players ~= nil and #data.players > 0) then
        for i=1,#data.players do
            local locData = data.players[i]
            local seatInfo = self.tableHelper:getSeatInfoByPlayerId(locData.playerid,roomInfo.seatInfoList)
            if(seatInfo ~= nil) then
                seatInfo.score = locData.score
                seatInfo.coinBalance = locData.coinBalance
                seatInfo.in_score = locData.in_score
                seatInfo.in_gold = locData.in_gold
                self.tableView:refreshseatInfoScore(seatInfo)
                self.tableView:showSeatCostGold(seatInfo, true)
            end
        end
    end 
    self.tableView:setRoomInfo(roomInfo)
    self.tableView:PoolScoreShowGold(roomInfo.pool_score)
    if(roomInfo.roundStarted) then
        self.tableView:showCurRoundBetScore(true)
    else
        self.tableView:showCurRoundBetScore(false)
    end

    -- 给玩家手牌填充假的数据
    local mySeatInfo = roomInfo.mySeatInfo
    local seatInfoList = roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if (seatInfo.isSeated and seatInfo.isReady) then
            self:RefreshSeatInfo_InHandPokerList(seatInfo)
            self.tableView:refreshSeat(seatInfo, false)
            local onFinish = nil
            if (seatInfo == mySeatInfo) then
                onFinish = function()
                    self.tableView:showZhaJinNiuBtns(true)
                end
            end

            
            self.tableView:showInHandCards(seatInfo, true)
            self.tableView:refreshInHandCards(seatInfo, false, false)
            self.tableView:SwitchState_NewStateRoot(seatInfo,true)
            self:playFaPaiAnim(seatInfo, onFinish)
        end
    end
    self.tableView.toggleFollowAlways.isOn = false
    mySeatInfo.isAlwaysFollow = false
    self.tableView:CheckCreatorIcon()
end

----开始操作通知
function TableZhaJinHuaLogic:StartOperationNotify(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    if(self:IsWaitReadyState()) then
        return
    end
    roomInfo.cur_operation_playerid = data.playerid--玩家id
    roomInfo.cur_verify_circle = data.verify_circle--验证轮数,验证步骤
    roomInfo.cur_score = data.cur_score            --当前单柱分数
    roomInfo.cur_circle = data.circle              --打牌轮数
    roomInfo.StartOperationNotify_auto_time = data.auto_time
    roomInfo.canBetScoreList = {}                  --可以下注的分数列表
    roomInfo.cur_op_list = data.op_list            --可以操作的列表
    roomInfo.global_op_list = data.global_op_list  --全局可以操作的列表
    local cur_op_list = roomInfo.cur_op_list
    if(cur_op_list ~= nil) then
        --跟注的分数
        if(cur_op_list.cur_follow_score ~= nil and cur_op_list.cur_follow_score > 0) then
            if(self:IsMyCurOperation()) then
                self.modelData.curTableData.roomInfo.mySeatInfo.cur_follow_score = cur_op_list.cur_follow_score
            end
            table.insert(roomInfo.canBetScoreList,cur_op_list.cur_follow_score)
        end

        --加注的分数
        if(cur_op_list.add_list and #cur_op_list.add_list > 0) then
            for i = 1, #cur_op_list.add_list do
                local addData = cur_op_list.add_list[i]
                local IsContains = self.tableHelper:IsNumTableContains(roomInfo.canBetScoreList,addData.score)
                if(not IsContains) then
                    table.insert(roomInfo.canBetScoreList,addData.score)
                end
            end

            if(self.tableView.AddBetRoot.activeInHierarchy) then
                self.tableView:SetAddBetBtnListShow(cur_op_list.add_list)
            end
        end
    else
        print("error====cur_op_list == nil")
    end

    self:RefreshMyCurOperationState()
    self:GlobalOperation()
    self.tableView:setRoomInfo(roomInfo)
    self:SetCurOperationPlayerFlashingEffect()
end

--刷新当前操作按钮的状态
function TableZhaJinHuaLogic:RefreshMyCurOperationState()
    if(self:IsWaitReadyState()) then
        return
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local cur_op_list = roomInfo.cur_op_list
    local mySeatInfo = roomInfo.mySeatInfo
    local IsXuePinDoing = self:IsXuePinDoing()
    local locIsXuePinId = IsXuePinDoing and roomInfo.xuepin_id == tonumber(self:GetMyPlayerId())
    if(self:IsMyCurOperation()) then
        local showFollowButton = not (mySeatInfo.isAlwaysFollow or false)
        self.tableView:showCheckPokersButton(showFollowButton and cur_op_list.kanpai) --看牌
        self.tableView:showDropPokersButton(showFollowButton,cur_op_list.qipai,true)  --弃牌
        self.tableView:showBtnXuePin(showFollowButton,true,true)    --血拼
        self.tableView.BtnXuePinText.text = cur_op_list.allin and self:GetXuePinCount() or "?"
        self.tableView:showBtnAdd(showFollowButton,cur_op_list.jiazhu,true) --加注
        self.tableView:showComparePokersButton(showFollowButton,cur_op_list.bipai,true)     --比牌
        self.tableView:showFollowAlwaysButton(not showFollowButton,nil,true)   --跟到底按钮
        self.tableView:showFollowButton(showFollowButton,nil,true)             --跟注按钮
        self.tableView:showBtnXuePinFollow(false)
        self:CheckAlwaysFollow()
        local pokerNumList = self:GetSeatInfoPokerNumList(mySeatInfo)
        self.tableView:SetPokerType(mySeatInfo, true, pokerNumList)
        if(IsXuePinDoing) then
            self.tableView:showBtnXuePin(false)                --血拼
            self.tableView:showBtnAdd(false)                 --加注
            self.tableView:showComparePokersButton(false)      --比牌按钮
            self.tableView:showFollowAlwaysButton(false)       --自动跟注
            self.tableView:showFollowButton(false)             --跟注按钮
            self.tableView.BtnXuePinFollowText.text = cur_op_list.allin and self:GetXuePinCount() or ""
            self.tableView:showBtnXuePinFollow(true and not locIsXuePinId)
            if(locIsXuePinId) then
                self.tableView:showDropPokersButton(false)
            end
        end
    else
        --self.tableView:showCheckPokersButton(cur_op_list.kanpai) --看牌
        self.tableView:showDropPokersButton(true,nil,true)          --弃牌
        self.tableView:showBtnXuePin(false,nil,true)                --血拼
        self.tableView:showBtnAdd(false,nil,true)                 --加注
        self.tableView:showComparePokersButton(false,nil,true)      --比牌按钮
        self.tableView:showFollowAlwaysButton(true,nil,true)        --自动跟注
        self.tableView:showFollowButton(false,nil,true)             --跟注按钮
        self.tableView:showBtnXuePinFollow(false)
        if(not mySeatInfo.isWatchState) then
            self.tableView:StopCoinCountdown()
        end

        if(IsXuePinDoing) then
            self.tableView:showFollowAlwaysButton(false)
            if(locIsXuePinId) then
                self.tableView:showDropPokersButton(false)
            end
        end
    end
    --self.tableView:refreshBetBtns(roomInfo.canBetScoreList)   --刷新下注的分数列表
    self.tableView:refreshBetBtnTextCount(self:GetMySelf_cur_follow_score())


    local isCanPlay = not mySeatInfo.isWatchState
    local isShowOperationBtns = nil
    if(mySeatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail 
    or mySeatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop) then
        isShowOperationBtns = false
    end
    self.tableView:showZhaJinNiuBtns(isCanPlay and isShowOperationBtns == nil)                      --显示操作节点
    self.tableView:showInHandCards(mySeatInfo, isCanPlay)   --显示牌的节点
    self.tableView:refreshInHandCards(mySeatInfo, mySeatInfo.inHandPokerListIsRealData, false)--刷新牌面
end

function TableZhaJinHuaLogic:GlobalOperation()
    if(self:IsXuePinDoing() or self:IsMyCurOperation()) then
        return
    end
    local global_op_list = self.modelData.curTableData.roomInfo.global_op_list
    if(global_op_list and #global_op_list > 0) then
        for i = 1, #global_op_list do
            local locData = global_op_list[i]
            if(locData.playerid == tonumber(self:GetMyPlayerId())) then
                print("==无条件相信GlobalOperation")
                local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
                local showFollowButton = not (mySeatInfo.isAlwaysFollow or false)
                self.tableView:showDropPokersButton(showFollowButton and true,locData.qipai)
                --print("==看过牌了,无论如何都不能显示看牌按钮")
                if(self.modelData.curTableData.roomInfo.mySeatInfo.inHandPokerListIsRealData) then
                    self.tableView:showCheckPokersButton(false)
                else
                    self.tableView:showCheckPokersButton(locData.kanpai)
                end
            end
        end
    end
end


function TableZhaJinHuaLogic:IsWaitReadyState()
    return self.modelData.curTableData.roomInfo.state == 2
end

function TableZhaJinHuaLogic:IsGameDoing()
    return self.modelData.curTableData.roomInfo.state == 1
end

function TableZhaJinHuaLogic:IsGameNotStarted()
    return self.modelData.curTableData.roomInfo.state == 0
end

----当前是我自己操作吗
function TableZhaJinHuaLogic:IsMyCurOperation()
    return self.modelData.curTableData.roomInfo.cur_operation_playerid == tonumber(self:GetMyPlayerId())
end

----获取我自己的玩家id
function TableZhaJinHuaLogic:GetMyPlayerId()
    return self.modelData.curTablePlayerId
end

----操作回复
function TableZhaJinHuaLogic:OperationRet(data)
    if(data.is_ok) then         
        if(data.cards ~= nil and #data.cards > 0) then
            if(data.op == 1) then
                self:on_table_checkpokers_rsp(data) --看牌的回复逻辑
            elseif(data.op == 6) then
                self:on_table_droppokers_rsp(data)
            end
        end

        if(data.op == 8) then
            print("====血拼的回复")
            self.modelData.curTableData.roomInfo.xuepin_status = 1
            self.modelData.curTableData.roomInfo.xuepin_id = tonumber(self:GetMyPlayerId())
        end
    else
        if(data.desc ~= nil) then
            if(string.find(data.desc,"操作轮数不对") ~= nil) then
                print("====这里不需要提示")
            else
                if (ModuleCache.GameManager.developmentMode) then
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.desc)
                end
            end
        end
    end
    self:hideAllSeatSelectCompare()
end

function TableZhaJinHuaLogic:OperationNotify(data)
    print("=====OperationNotify")
    print_table(data)
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.playerid,roomInfo.seatInfoList)
    if(seatInfo == nil) then
        print("==seatInfo == nil")
    else
        roomInfo.pool_score = data.pool_score
        seatInfo.in_score = data.in_score
        seatInfo.score = data.sur_score

        roomInfo.pool_gold = data.pool_gold
        seatInfo.in_gold = data.in_gold
        seatInfo.coinBalance = data.coinBalance

        if(data.cur_follow_score  and data.cur_follow_score > 0) then
            local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
            mySeatInfo.cur_follow_score = data.cur_follow_score
            --print("=======data.cur_follow_score=",data.cur_follow_score)
            self.tableView:refreshBetBtnTextCount(mySeatInfo.cur_follow_score)
        end

        local opId = data.op
        if(opId == 1) then --看牌
            self:on_table_checkpokers_notify(data)
        elseif (opId == 2 or opId == 3 or opId == 4) then --下注,跟注,加注
            self:on_table_callbet_notify(data)
        elseif (opId == 5) then --比牌
            self:new_comparepokers_notify(data)
        elseif (opId == 6) then --弃牌
            self:on_table_droppokers_notify(data)
        elseif (opId == 8) then --血拼
            self:xuepin_notify(data)
        end

        
        self.tableView:showCurRoundBetScore(true)       --刷新本局总下注分数
        --self.tableView:showSeatCostGold(seatInfo, true) --刷新玩家座位已经的下注分数
        self.tableView:refreshseatInfoScore(seatInfo)
    end
end

----刷新座位上玩家信息的手牌
function TableZhaJinHuaLogic:RefreshSeatInfo_InHandPokerList(seatInfo,pokerNumList)
    if(seatInfo == nil) then
        print("error====seatInfo == nil or pokerNumList == nil or #pokerNumList ~= self.tableHelper.PokerCount")
        return
    end

    seatInfo.inHandPokerList = {}
    if(pokerNumList == nil or #pokerNumList <= 0) then
        seatInfo.inHandPokerListIsRealData = false
        for i=1,self.tableHelper.PokerCount do
            local poker = self.tableHelper:NumberToPokerTable(10,false)
            table.insert(seatInfo.inHandPokerList,poker)
        end
        --print("====填充假的数据到玩家信息的手牌playerId=",seatInfo.playerId)
    else
        seatInfo.inHandPokerListIsRealData = true
        CardCommon.Sort(pokerNumList)
        for i=1,#pokerNumList do
            local poker = self.tableHelper:NumberToPokerTable(pokerNumList[i],true)
            table.insert(seatInfo.inHandPokerList,poker)
        end
        -- print("====手上的牌真实数据playerId=",seatInfo.playerId)
    end
end


function TableZhaJinHuaLogic:MaxCircleNotify(data)
    print("=====MaxCircleNotify")
end



function TableZhaJinHuaLogic:CheckAlwaysFollow(data)
    print("=====CheckAlwaysFollow")
    if (self.isPlayingComparePoker) then
        self.delayInvoke_CheckAlwaysFollow = function()
            self:CheckAlwaysFollow(data)
        end
        return
    end

    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    if(self:IsXuePinDoing()) then
        mySeatInfo.isAlwaysFollow = false
        return
    end
    if(self:IsMyCurOperation()) then
        if(mySeatInfo.isAlwaysFollow) then
            self.tableModule:subscibe_time_event(1, false, 0):OnComplete( function(t)
                print("=====自动跟到底5")
                self:onclick_follow_btn()
            end)
        end
    end
end

function TableZhaJinHuaLogic:GetSeatInfoPokerNumList(seatInfo)
    --print("====获取玩家的扑克数字的列表")
    local result = nil
    if(seatInfo ~= nil and seatInfo.inHandPokerListIsRealData) then
        result = {}
        local inHandPokerList = seatInfo.inHandPokerList
        for i=1,#inHandPokerList do
            local poker = inHandPokerList[i]
            table.insert(result,poker.PokerNum)
        end
    end
    return result
end

function TableZhaJinHuaLogic:CheckMyPokerType()
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local pokerNumList = self:GetSeatInfoPokerNumList(mySeatInfo)
    self.tableView:SetPokerType(mySeatInfo, true, pokerNumList)
end

function TableZhaJinHuaLogic:SetCurOperationPlayerFlashingEffect()
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        local show = tonumber(seatInfo.playerId) == tonumber(roomInfo.cur_operation_playerid)
        if(self.tableView:isJinBiChang()) then
            local locTime = roomInfo.StartOperationNotify_auto_time
            if(locTime and locTime > 0) then
                self.tableView:showSeatTimeLimitEffect(seatInfo, show, locTime, nil,1)
            end
        else
            local locTime = roomInfo.StartOperationNotify_auto_time
            if(locTime and locTime > 0) then
                self.tableView:showSeatTimeLimitEffect(seatInfo, show, locTime, nil,1)
            else
                self.tableView:showSeatTimeLimitEffect(seatInfo, show, 10, nil, -1)
            end
        end
    end
end

function TableZhaJinHuaLogic:HideAllPlayerFlashingEffect()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        self.tableView:showSeatTimeLimitEffect(seatInfo, false)
    end
end


function TableZhaJinHuaLogic:CompareListRet(data)
    print("====CompareListRet返回可以比较的玩家列表")
    self:hideAllSeatSelectCompare()
    self.tableView:SetState_AddBetRoot(false)
    local roomInfo = self.modelData.curTableData.roomInfo
    --local list = { }
    if(data.players ~= nil and #data.players > 0) then
        if(#data.players == 1) then -- 只有一个玩家自动比牌
            self.compare_target_player_id = data.players[1]
            self.isDelayAlwaysFollow = false
            self.tableModel:request_operation(roomInfo.cur_verify_circle,5,nil,tonumber(self.compare_target_player_id))
        else
            for i=1,#data.players do
                local locPlayerId = data.players[i]
                local seatInfo = self.tableHelper:getSeatInfoByPlayerId(locPlayerId,roomInfo.seatInfoList)
                if(seatInfo == nil) then
                    print("error====检查是否有这个玩家Id=",locPlayerId)
                else
                    self.tableView:showSelectCompare(seatInfo, true)
                end
            end
            self.tableView:SetComparePokerSelectTimeDown(true)
        end
    end
end


function TableZhaJinHuaLogic:CurrentGameAccount(data)
    print("=====CurrentGameAccount")
    if (self.isPlayingComparePoker) then
        self.delayInvoke_CurrentGameAccount = function()
            self.isPlayingComparePokerGameAccount = true
            self:CurrentGameAccount(data)
        end
        return
    end
    self:StopSoundXuePinBeiJing()
    self.tableView:showZhaJinNiuBtns(false)
    self:HideAllPlayerFlashingEffect()--隐藏闪烁
    self.tableView:SetState_AddBetRoot(false)
    self:ResetXuePin()
    self.tableView:showCheckPokersButton(false)
    self.tableView:SetComparePokerSelectTimeDown(false)

    
    local is_summary_account = data.is_summary_account
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    roomInfo.state = 2


    if(not data.is_free_room) then
        print("====小结算:等待开始下一局")
        local winnerInfo = self.tableHelper:getSeatInfoByPlayerId(data.winnerid, roomInfo.seatInfoList)
        if(roomInfo.curRoundNum > 0 or self.tableView:isJinBiChang()) then
            roomInfo.autoready_time = 5
            for i=1,#data.players do
                local locData = data.players[i]
                local seatInfo = self.tableHelper:getSeatInfoByPlayerId(locData.player_id, roomInfo.seatInfoList)   
                if(seatInfo) then
                    --seatInfo.compareidList = data.compareid

                    --显示玩家的牌
                    if(seatInfo == mySeatInfo) then
                        if(locData.cards and #locData.cards > 0) then
                            --print("===自己牌任何情况都可以看到")
                            self:RefreshSeatInfo_InHandPokerList(seatInfo,locData.cards)
                            self.tableView:showInHandCards(seatInfo, true)              --显示牌的节点     
                            self.tableView:refreshInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData, false,true)    --刷新牌面
                            self.tableView:setInHandCardsMaskColor(seatInfo, seatInfo ~= winnerInfo)
                        end
                    else
                        if(locData.cards and #locData.cards > 0) then
                            --print("===其他情况显示牌")
                            self:RefreshSeatInfo_InHandPokerList(seatInfo,locData.cards)
                            self.tableView:showInHandCards(seatInfo, true)              --显示牌的节点     
                            self.tableView:refreshInHandCards(seatInfo, seatInfo.inHandPokerListIsRealData, true,true)    --刷新牌面
                            self.tableView:setInHandCardsMaskColor(seatInfo, seatInfo ~= winnerInfo)
                        end
                        if(roomInfo.cur_circle >= roomInfo.max_circle) then
                            self.tableView:setInHandCardsMaskColor(seatInfo, seatInfo ~= winnerInfo)
                        end
                    end

                    --顺金飘分效果
                    if(locData.shunjin and #locData.shunjin > 0) then
                        local shunjinAdd = locData.shunjin[2]
                        if(shunjinAdd > 0) then
                            --print("======顺金加分效果")
                            self.tableModule:subscibe_time_event(0.5, false, 0):OnComplete( function(t)
                                self:playCoinFlySound()
                                self.tableView:showSeatRoundScoreAnim(seatInfo, true, shunjinAdd)
                            end)
                        end
                    end
                    --豹子飘分效果
                    if(locData.baozi and #locData.baozi > 0) then
                        local baoziAdd = locData.baozi[2]
                        if(baoziAdd > 0) then
                            --print("======豹子加分效果")
                            self.tableModule:subscibe_time_event(0.5, false, 0):OnComplete( function(t)
                                self:playCoinFlySound()
                                self.tableView:showSeatRoundScoreAnim(seatInfo, true, baoziAdd)
                            end)
                        end
                    end
                    --本局输赢飘分效果
                    if(self.tableView:isGoldSettle()) then
                        self.tableModule:subscibe_time_event(2, false, 0):OnComplete( function(t)
                            self.tableView:showSeatRoundScoreAnim(seatInfo, true, locData.Coin)
                            if(i==1) then --只播一次
                                self:playSound_PaioShuZi()
                            end
                        end)
                    else
                        self.tableModule:subscibe_time_event(1, false, 0):OnComplete( function(t)
                            self.tableView:showSeatRoundScoreAnim(seatInfo, true, locData.normal_win_score)
                            if(i==1) then
                                self:playSound_PaioShuZi()
                            end
                        end)
                    end
                    --刷新玩家显示的分数
                    self.tableModule:subscibe_time_event(2, false, 0):OnComplete( function(t)
                        seatInfo.score = locData.score
                        seatInfo.coinBalance = locData.coinBalance
                        self.tableView:refreshseatInfoScore(seatInfo)
                    end)
                end
            end
        end
        self:resetRoundState()
        self:refreshMyTableViewState()
        self.tableView:showZhaJinNiuBtns(false)

        if(self.tableView:isJinBiChang()) then
            
        else
            if(not mySeatInfo.isWatchState) then
                self:startWaitContinue()    
            end
        end


        if(winnerInfo) then
            --赢了特效
            if(winnerInfo == mySeatInfo) then
                self.tableView:SetState_MyWinEffectRoot(true,true)
            else
                self.tableView:SetState_WinnerEffectRoot(winnerInfo,true,true)
            end
            self:playSound_YingJiaZhanShi()

            --桌面上的筹码飞向赢家
            self.tableModule:subscibe_time_event(1, false, 0):OnComplete( function(t)
                self:playCoinFlySound()
                self.tableView:goldFlyToSeat(winnerInfo)
            end)

            --
            self.tableView:SetSeatInfoState_imageHasCheck(winnerInfo,false)
        end
    end


    if(is_summary_account) then
        print("====大结算")
        self.tableModule:ResetChatMsgs()
        roomInfo.isRoomEnd = true
        roomInfo.roomResultList = resultList
        roomInfo.free_sponsor = nil
        if(data.is_free_room) then
            roomInfo.free_sponsor = data.free_sponsor
        end
        self.tableresultEvent = function()
            local resultList = { }
            for i=1,#data.players do
                local playerData = data.players[i]
                local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerData.player_id, roomInfo.seatInfoList)
                local result = { }
                result.totalScore = playerData.score
                result.winTimes = playerData.win_cnt
                result.loseTimes = playerData.lost_cnt
                result.playerId = playerData.player_id
                result.isRoomCreator = seatInfo.isCreator
                result.playerInfo = seatInfo.playerInfo
                if(result.playerInfo.spriteHeadImage == nil) then
                    result.playerInfo.spriteHeadImage = self:GetSeatInfoPlayerHeadImageSprite(seatInfo)
                end

                if(self.tableView:isGoldSettle()) then
                    result.isGoldSettle = true
                    result.allCoin = playerData.allCoin
                    result.restCoin = playerData.restCoin
                end

                table.insert(resultList, result)
            end
            ModuleCache.ModuleManager.show_module(BranchPackageName, "tableresult", { resultList = resultList, roomInfo = { roomNum = roomInfo.roomNum, tableInfo = roomInfo, timestamp = os.time() } })
            self.tableresultEvent = nil
            roomInfo.isRoomEnd = false
        end

        if(data.is_free_room) then
            self.tableresultEvent()
        end
    end

    --亮牌过一段时间后清空
    self.modelData.curTableData.roomInfo.IsGameOverClearTable = false
    if(self.tableView:isJinBiChang()) then
        -- print("===亮牌时间=",data.show_time,"===准备时间=",data.ready_time)
        self.tableModule:subscibe_time_event(data.show_time, false, 0):OnComplete( function(t)

            self:GameOverClearTable()
            ModuleCache.ComponentUtil.SafeSetActive(self.tableView.goCurRoundBetScore, false) 
            local locReadyTime = data.ready_time
            if(self.isPlayingComparePokerGameAccount) then
                locReadyTime = data.ready_time - 2
                self.isPlayingComparePokerGameAccount = false
            end

            --if(mySeatInfo.isWatchState) then
            --else
            --    self.tableView:SetJinBiChangStateSwitcher("Center",locReadyTime)
            --    self.tableView:ClearAllNewStateRoot()
            --end
            --self.tableView:StartCoinCountdown(locReadyTime)
            self.tableView:SetJinBiChangStateSwitcher("Center",locReadyTime)
            self.tableView:ClearAllNewStateRoot()
            self.tableView:showCenterTips(false)
        end)
    end
    roomInfo.cur_circle = 0
    self.tableView:setRoomInfo(roomInfo)
end

function TableZhaJinHuaLogic:GetSeatInfoPlayerHeadImageSprite(seatInfo)
    if(seatInfo) then
        if(seatInfo.playerInfo and seatInfo.playerInfo.spriteHeadImage) then
            return seatInfo.playerInfo.spriteHeadImage
        else
            local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
            if(seatHolder and seatHolder.imagePlayerHead and seatHolder.imagePlayerHead.sprite) then
                return seatHolder.imagePlayerHead.sprite
            end
        end
    end
    return nil
end

function TableZhaJinHuaLogic:HideAllPlayerPokerType()
    -- print("====隱藏所有人牌面的類型")
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        self.tableView:SetPokerType(seatInfoList[i],false)
    end
end

function TableZhaJinHuaLogic:IsWaitContinueGame()
    -- print("====IsWaitContinueGame")
    local roomInfo = self.modelData.curTableData.roomInfo
    if(roomInfo.curRoundNum > 0 and roomInfo.state == RoomState.waitReady) then
        local isAllPlayerReady = self.tableHelper:checkIsAllReady(roomInfo.seatInfoList)
        if(not isAllPlayerReady) then
            return true
        end
    end
    return false
end


function TableZhaJinHuaLogic:CheckSeatState()
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList

    local locShow = true
    for i=1,#self.tableView.seatHolderArray do
        local seatHolder = self.tableView.seatHolderArray[i]
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, locShow)  
    end
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        if(seatInfo ~= nil and seatInfo.isSeated) then
            local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, true)   
        end
    end 
end

function TableZhaJinHuaLogic:CheckReadyState()
    local roomInfo = self.modelData.curTableData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    if(self:IsGameNotStarted() or self:IsWaitReadyState()) then
        if(mySeatInfo.isReady) then
            --已经准备了
        else
            if(self.tableView:isJinBiChang()) then
                self.tableView:SetJinBiChangStateSwitcher("Center",roomInfo.auto_ready_time)
            end
        end
    end
end



function TableZhaJinHuaLogic:IsHaveWatchState()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        if(seatInfo and seatInfo.isWatchState) then
            return true
        end
    end
    return false
end


function TableZhaJinHuaLogic:KillEventId(EventId)
    if(EventId) then
        CSmartTimer:Kill(EventId)
        EventId = nil
    end
end


function TableZhaJinHuaLogic:OneShotSettleNotify(data)
    -- print("====OneShotSettleNotify")
    if(data.players ~= nil and #data.players > 0) then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i=1,#data.players do
            local locData = data.players[i]
            if(locData) then
                local seatInfo = self.tableHelper:getSeatInfoByPlayerId(locData.player_id,seatInfoList)
                if(seatInfo) then
                    seatInfo.coinBalance = locData.coinBalance
                    if(data.refreshView) then
                        self.tableView:refreshseatInfoScore(seatInfo)
                    end
                end
            end
        end
    end
end


function TableZhaJinHuaLogic:GameOverClearTable()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        if(seatInfo) then
            self.tableView:showInHandCards(seatInfo, false)  
            self.tableView:showSeatCostGold(seatInfo,false) 
            self.tableView:SetPokerType(seatInfo, false)
        end
    end
    self.modelData.curTableData.roomInfo.IsGameOverClearTable = true
end



function TableZhaJinHuaLogic:IntrustRsp(data)
    print("====IntrustRsp托管回应")
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    mySeatInfo.IntrustState = data.status
end

function TableZhaJinHuaLogic:IntrustNotify(data)
    print("====IntrustNotify托管通知")
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(data.player_id,self.modelData.curTableData.roomInfo.seatInfoList)
    if(seatInfo == nil) then
        print("warning====seatInfo == nil ")
    else
        seatInfo.IntrustState = data.status
        print("====刷新UI")
    end
end

function TableZhaJinHuaLogic:AllInCompareNotify(data)
    print("====AllInCompareNotify血拼比牌通知")
    local sponsorid --发起者id
    local compareid --比牌对象id
    local winnerid = data.winner --比赢id
    local roomInfo = self.modelData.curTableData.roomInfo
    if(data) then
        if(data.compareids and #data.compareids > 0) then
            for i = 1, #data.compareids do
                local locId = data.compareids[i]
                --1.0效果
                local seatInfo = self.tableHelper:getSeatInfoByPlayerId(locId,roomInfo.seatInfoList)
                if(seatInfo) then
                    if(seatInfo == roomInfo.mySeatInfo) then
                        self.tableView:SetState_EffectRanShaoRoot(true)
                    end
                end

                --2.0 理清楚发起者,比牌者,赢者
                if(i==1) then
                    sponsorid = locId --发起者
                else
                    compareid = locId --接受者
                end
            end
        end
    end

    local mySeatInfo = roomInfo.mySeatInfo
    local sponsorInfo = self.tableHelper:getSeatInfoByPlayerId(sponsorid, roomInfo.seatInfoList)
    local compareInfo = self.tableHelper:getSeatInfoByPlayerId(compareid, roomInfo.seatInfoList)
    local winnerInfo = self.tableHelper:getSeatInfoByPlayerId(winnerid, roomInfo.seatInfoList)
    if(sponsorInfo == nil) then
        print("====血拼发起者:",tostring(sponsorid),"血拼接受者:",tostring(compareid))
        return
    end

    self:playComparePokerEffectNew(sponsorInfo,compareInfo,winnerInfo,function ()
        local lostInfo
        if(sponsorInfo == winnerInfo) then
            lostInfo = compareInfo
        else
            lostInfo = sponsorInfo
        end
        lostInfo.zhaJinNiu_state = self.SeatPlayState.compareFail

        --显示比牌失败
        if (loserSeatInfo == mySeatInfo) then
            print("======自己比牌失败,显示自己的牌")
            --self:RefreshSeatInfo_InHandPokerList(mySeatInfo,data.compare_info.cards)
            self.tableView:SwitchState_NewStateRoot(mySeatInfo, true)
            self.tableView:showZhaJinNiuBtns(false)
            self.tableView:refreshInHandCards(mySeatInfo, mySeatInfo.inHandPokerListIsRealData, false,true)
        else
            self.tableView:SwitchState_NewStateRoot(lostInfo)
            self.tableView:showSeatCostGold(lostInfo, false)
            self.tableView:showInHandCards(lostInfo, false)
            self.tableView:SwitchState_NewStateRoot(lostInfo)
        end

        self.tableView:setInHandCardsMaskColor(lostInfo, true)

        if (self.delayInvoke_CurrentGameAccount) then
            local fun = self.delayInvoke_CurrentGameAccount
            self.delayInvoke_CurrentGameAccount = nil
            fun()
        end

        if(self.modelData.curTableData.roomInfo.IsGameOverClearTable) then
            self.tableModule:subscibe_time_event(0.3, false, 0):OnComplete(function(t)
                self:GameOverClearTable()
            end)
        end
    end)
end

function TableZhaJinHuaLogic:IsXuePinDoing()
    if(self.modelData and self.modelData.curTableData and self.modelData.curTableData.roomInfo) then
        local roomInfo = self.modelData.curTableData.roomInfo
        return roomInfo.xuepin_status == 1 or roomInfo.xuepin_status == 2
    end
    return false
end

function TableZhaJinHuaLogic:ResetXuePin()
    self.modelData.curTableData.roomInfo.xuepin_status = nil
    self.modelData.curTableData.roomInfo.xuepin_id = nil
    self.tableView:SetState_EffectRanShaoRoot(false)
end

function TableZhaJinHuaLogic:GetMySelf_cur_follow_score()
    return self.modelData.curTableData.roomInfo.mySeatInfo.cur_follow_score
end

function TableZhaJinHuaLogic:CheckHeadGray()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if(seatInfo) then
            if(seatInfo.isWatchState
            or seatInfo.zhaJinNiu_state == self.SeatPlayState.hasDrop
            or seatInfo.zhaJinNiu_state == self.SeatPlayState.compareFail) then
                self.tableView:SetState_HeadGray(seatInfo,true)
            end
        end
    end
end

function TableZhaJinHuaLogic:GetXuePinCount()
    local cur_op_list = self.modelData.curTableData.roomInfo.cur_op_list
    if(cur_op_list) then
        if(cur_op_list.allin) then
            if(self.tableView:isJinBiChang()) then
                return cur_op_list.allin_gold
            else
                return cur_op_list.allin_score
            end
        end
    end
    return 0
end




return TableZhaJinHuaLogic