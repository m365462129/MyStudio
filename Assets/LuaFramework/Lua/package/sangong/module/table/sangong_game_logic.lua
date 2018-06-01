--- 三公数据适配器
--- Created by 袁海洲
--- DateTime: 2017/11/21 18:06
---

local SanGongGameLogic = {}
local Json = require ("cjson")

function SanGongGameLogic:initTableData(data,module)
    local roomInfo
    local modelData =  module.modelData
    if( not modelData.curTableDatas
        or not modelData.curTableData.roomInfo)then
        roomInfo = {}
        modelData.curTableData = {}
        modelData.curTableData.roomInfo = roomInfo
    else
        roomInfo = modelData.curTableData.roomInfo
    end

    roomInfo.roomNum = data.room_id
    roomInfo.roomHistoryId = data.room_history_id
    roomInfo.curRoundNum = data.game_loop_cnt
    roomInfo.totalRoundCount = data.game_total_cnt
    roomInfo.timeOffset = data.time - os.time()
    roomInfo.bankerId = data.banker_player_id
    roomInfo.bankerRate = data.banker_rate

    roomInfo.rule = modelData.roleData.myRoomSeatInfo.Rule
    local ruleData = Json.decode(roomInfo.rule)
    roomInfo.ruleData = ruleData

    --data.state 房间的状态,游戏过程中由客户端自己维护此字段
    --0（需要准备、分结算准备与牌桌开始期间的准备，如果是结算阶段会紧接着收到结算包）
    --1 下注阶段（需要下注）
    --2 抢庄阶段（需要抢庄）
    --3 开牌阶段（等待开牌）
    roomInfo.state = data.state
    roomInfo.isRoundStarted = data.state ~= 0 --当前局是否已经开始
    roomInfo.isRoomStarted = data.game_loop_cnt > 0 -- 房间是否已经开始游戏

    local seatInfoList
    local seatCount = module.view:getTotalSeatCount()
    --创建玩家数据列表
    if(not modelData.curTableData.roomInfo.seatInfoList) then
        seatInfoList = {}
        for i=1,seatCount do
            local seatInfo = {}
            seatInfo.playerId = 0
            seatInfo.seatIndex = i
            seatInfo.lastSeatIndex = seatInfo.seatIndex
            seatInfo.isReady = false
            seatInfo.isSeated = false
            seatInfo.roomInfo = roomInfo
            seatInfo.isCreator = false
            seatInfo.isOffline = true
            seatInfo.score = 0
            seatInfo.winTimes = 0
            seatInfo.lostTimes = 0

            seatInfo.isBanker = false

            seatInfo.cards = {}
            seatInfo.showCard = false
            seatInfo.stake = 0
            seatInfo.bankerRate = 0
            seatInfo.state = 0
            seatInfo.cardType = 0

            table.insert(seatInfoList, seatInfo)
        end
        modelData.curTableData.roomInfo.seatInfoList = seatInfoList
    else
        seatInfoList = roomInfo.seatInfoList
    end
    --初始化玩家数据
    local curPlayer = 0
    for i=1,#data.players do
        local remotePlayerInfo = data.players[i]
        local seatInfo = seatInfoList[remotePlayerInfo.player_pos]

        seatInfo.lastSeatIndex = seatInfo.seatIndex
        seatInfo.playerId = remotePlayerInfo.player_id
        seatInfo.seatIndex = remotePlayerInfo.player_pos
        seatInfo.isReady = remotePlayerInfo.is_ready
        seatInfo.isSeated = seatInfo.playerId ~= 0
        if seatInfo.isSeated then
            curPlayer = curPlayer + 1
        end
        seatInfo.roomInfo = roomInfo
        seatInfo.isCreator = remotePlayerInfo.is_owner
        if seatInfo.isCreator then
            roomInfo.CreatorId = remotePlayerInfo.player_id ---房主ID
        end
        seatInfo.isOffline = remotePlayerInfo.is_offline
        seatInfo.score = remotePlayerInfo.score
        seatInfo.winTimes = remotePlayerInfo.win_cnt
        seatInfo.lostTimes = remotePlayerInfo.lost_cnt

        seatInfo.isBanker = remotePlayerInfo.player_id == data.banker_player_id

        table.clear(seatInfo.cards)
        for j=1,#remotePlayerInfo.cards do
            table.insert(seatInfo.cards,remotePlayerInfo.cards[j])
        end

        seatInfo.showCard = remotePlayerInfo.show_card
        seatInfo.stake = remotePlayerInfo.stake
        seatInfo.bankerRate = remotePlayerInfo.banker_rate
        seatInfo.state = remotePlayerInfo.state
        seatInfo.cardType = remotePlayerInfo.card_type

        --TODO XLQ 玩家已参与的游戏局数 （发牌后 +1）
        seatInfo.playedRoundCount = remotePlayerInfo.playedRoundCount

        if(seatInfo.playerId == tonumber(modelData.curTablePlayerId))then
            roomInfo.mySeatInfo = seatInfo
        end
    end

    module.view:resetSeatHolderArray(seatCount)

    local mySeatIndex = roomInfo.mySeatInfo.seatIndex
    local lastMySeatIndex = roomInfo.mySeatInfo.lastSeatIndex

    for i=1,seatCount do
        local seatInfo = seatInfoList[i]
        --转换为本地位置索引
        seatInfo.localSeatIndex = module:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, mySeatIndex, seatCount)
        seatInfo.lastLocalSeatIndex = module:getLocalIndexFromRemoteSeatIndex(seatInfo.lastSeatIndex, lastMySeatIndex, seatCount)
    end

    local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, modelData.roleData.HallID > 0)
    roomInfo.ruleDesc = ruleDesc

    roomInfo.ruleTable = {}
    roomInfo.ruleTable.game_type = roomInfo.ruleData.game_type

    modelData.curTableData.roomInfo = roomInfo

    module:updateShareData()
    module:on_enter_room_event(modelData.curTableData.roomInfo)
end

return SanGongGameLogic