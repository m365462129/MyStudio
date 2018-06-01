--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local list = require("list")
local ModuleBase = require('core.mvvm.module_base')
---@class WuShiKTableVideoModule:ModuleBase
---@field view WuShiKTableVideoView
local WuShiKTableVideoModule = class('WuShiKTableVideoModule', ModuleBase)
local CardCommon = require('package.wushik.module.table.gamelogic_common')
local CardPattern = require('package.wushik.module.table.gamelogic_pattern')
local CardSet = require('package.wushik.module.table.gamelogic_set')
local tableSound = require('package.wushik.module.table.table_sound')


function WuShiKTableVideoModule:initialize(...)
	ModuleBase.initialize(self, "table_video_view", nil, ...)
	self.packageName = "wushik"
	self.moduleName = "table_video"
	self.tableSound = tableSound
	self.myHandPokers = (require("package/wushik/module/table/handpokers")):new(self)
	self.view.firstViewHandPokers = self.myHandPokers
end

function WuShiKTableVideoModule:on_show(intentData)
	self:initData(intentData)
end


function WuShiKTableVideoModule:initData(videoData)
	--local json = '{"DHHUBEIQP_WUSHIK_WUSHIK":{"roomConfig":{"game_type":1,"GameType":1,"playerCount":4,"HallID":0,"isKingMagic":true,"SameIpForbidden":false,"VoiceChatForbidden":false,"roundCount":4, "DiFen":1, "PayType":1,"gameName":"DHHUBEIQP_WUSHIK_WUSHIK","GameID":"DHHUBEIQP_WUSHIK"},"teamInfo":{"teamCard":34,"team2":[733,731],"team1":[734,732]},"current_game_loop_count":1,"info":{"731":{"pos_index":3,"rest_cnt":2,"cards":[50,17,18,19,53,5,8,2,45,46,47,47,48,44,35,29,31,25,27,28,22,23,13,14,15,9,12],"current_score":-2,"score":-2},"734":{"pos_index":1,"rest_cnt":0,"cards":[51,52,37,39,40,18,20,20,53,5,3,41,43,44,33,34,36,30,30,32,32,26,23,13,14,10,11],"current_score":2,"score":2},"732":{"pos_index":2,"rest_cnt":0,"cards":[49,51,52,38,38,39,40,54,6,7,2,45,48,42,43,33,34,29,25,27,21,21,22,24,24,15,10],"current_score":2,"score":2},"733":{"pos_index":4,"rest_cnt":7,"cards":[49,50,37,17,19,54,6,7,8,1,1,3,4,4,46,41,42,35,36,31,26,28,16,16,9,11,12],"current_score":-2,"score":-2}},"sum_game_loop_count":4,"change_pos":{},"played_cards":{"53":{"logic_cards":[0,0,0],"pos_index":1,"is_first_pattern":false,"played_cards":[37,39,40],"player_id":734},"43":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"73":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"63":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"47":{"logic_cards":[0],"pos_index":3,"is_first_pattern":false,"played_cards":[44],"player_id":731},"37":{"logic_cards":[0],"pos_index":1,"is_first_pattern":false,"played_cards":[26],"player_id":734},"67":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"57":{"logic_cards":[0],"pos_index":1,"is_first_pattern":false,"played_cards":[52],"player_id":734},"27":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"17":{"is_first_pattern":false,"played_cards":"PASS","player_id":734,"pos_index":1},"13":{"logic_cards":[0,0,0],"pos_index":1,"is_first_pattern":false,"played_cards":[18,20,20],"player_id":734},"33":{"is_first_pattern":false,"played_cards":"PASS","player_id":734,"pos_index":1},"23":{"logic_cards":[0,0,0,0,0],"pos_index":3,"is_first_pattern":false,"played_cards":[45,46,47,47,48],"player_id":731},"42":{"logic_cards":[0,0,0,0,0],"pos_index":2,"is_first_pattern":false,"played_cards":[21,21,22,24,24],"player_id":732},"52":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"62":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"72":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"36":{"logic_cards":[0],"pos_index":4,"is_first_pattern":false,"played_cards":[19],"player_id":733},"46":{"logic_cards":[0],"pos_index":2,"is_first_pattern":false,"played_cards":[10],"player_id":732},"56":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"66":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"16":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"26":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"12":{"logic_cards":[0,0,0],"pos_index":4,"is_first_pattern":false,"played_cards":[9,11,12],"player_id":733},"22":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"32":{"logic_cards":[0,0,38],"pos_index":4,"is_first_pattern":false,"played_cards":[17,49,54],"player_id":733},"71":{"logic_cards":[0,0,0],"pos_index":3,"is_first_pattern":false,"played_cards":[25,27,28],"player_id":731},"61":{"logic_cards":[0,0,0],"pos_index":1,"is_first_pattern":false,"played_cards":[41,43,44],"player_id":734},"51":{"logic_cards":[0,0,0],"pos_index":3,"is_first_pattern":false,"played_cards":[17,18,19],"player_id":731},"41":{"logic_cards":[0,0,0],"pos_index":1,"is_first_pattern":false,"played_cards":[33,34,36],"player_id":734},"65":{"logic_cards":[0,0],"pos_index":1,"is_first_pattern":false,"played_cards":[10,11],"player_id":734},"55":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"45":{"is_first_pattern":false,"played_cards":"PASS","player_id":734,"pos_index":1},"35":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"59":{"logic_cards":[0],"pos_index":3,"is_first_pattern":false,"played_cards":[2],"player_id":731},"49":{"logic_cards":[0],"pos_index":1,"is_first_pattern":false,"played_cards":[51],"player_id":734},"39":{"logic_cards":[0,0,0],"pos_index":3,"is_first_pattern":false,"played_cards":[13,14,15],"player_id":731},"29":{"logic_cards":[0],"pos_index":1,"is_first_pattern":false,"played_cards":[5],"player_id":734},"79":{"logic_cards":[0,0],"pos_index":2,"is_first_pattern":false,"played_cards":[45,48],"player_id":732},"69":{"logic_cards":[0,0],"pos_index":1,"is_first_pattern":false,"played_cards":[13,14],"player_id":734},"1":{"logic_cards":[0],"pos_index":1,"is_first_pattern":false,"played_cards":[23],"player_id":734},"3":{"logic_cards":[0],"pos_index":3,"is_first_pattern":false,"played_cards":[35],"player_id":731},"2":{"logic_cards":[0],"pos_index":2,"is_first_pattern":false,"played_cards":[29],"player_id":732},"19":{"logic_cards":[0,0,30],"pos_index":3,"is_first_pattern":false,"played_cards":[29,31,53],"player_id":731},"4":{"logic_cards":[0],"pos_index":4,"is_first_pattern":false,"played_cards":[37],"player_id":733},"7":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"6":{"logic_cards":[0],"pos_index":2,"is_first_pattern":false,"played_cards":[6],"player_id":732},"25":{"is_first_pattern":false,"played_cards":"PASS","player_id":734,"pos_index":1},"15":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"31":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"21":{"logic_cards":[0,0,0,0,30],"pos_index":1,"is_first_pattern":false,"played_cards":[30,30,32,32,53],"player_id":734},"11":{"logic_cards":[0,0],"pos_index":3,"is_first_pattern":false,"played_cards":[5,8],"player_id":731},"60":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"70":{"logic_cards":[0,0],"pos_index":2,"is_first_pattern":false,"played_cards":[42,43],"player_id":732},"40":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"50":{"logic_cards":[0],"pos_index":2,"is_first_pattern":false,"played_cards":[7],"player_id":732},"54":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"64":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"34":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"44":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"48":{"logic_cards":[0],"pos_index":4,"is_first_pattern":false,"played_cards":[46],"player_id":733},"58":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"28":{"logic_cards":[0],"pos_index":4,"is_first_pattern":false,"played_cards":[31],"player_id":733},"38":{"logic_cards":[0],"pos_index":2,"is_first_pattern":false,"played_cards":[2],"player_id":732},"68":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"78":{"logic_cards":[0,0],"pos_index":4,"is_first_pattern":false,"played_cards":[16,16],"player_id":733},"82":{"logic_cards":[0],"pos_index":2,"is_first_pattern":false,"played_cards":[15],"player_id":732},"81":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"80":{"is_first_pattern":false,"played_cards":"PASS","player_id":731,"pos_index":3},"77":{"logic_cards":[0,0],"pos_index":3,"is_first_pattern":false,"played_cards":[9,12],"player_id":731},"76":{"is_first_pattern":false,"played_cards":"PASS","player_id":732,"pos_index":2},"18":{"logic_cards":[0,0,26],"pos_index":2,"is_first_pattern":false,"played_cards":[25,27,54],"player_id":732},"75":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"74":{"logic_cards":[0],"pos_index":3,"is_first_pattern":false,"played_cards":[50],"player_id":731},"14":{"logic_cards":[0,0,0],"pos_index":2,"is_first_pattern":false,"played_cards":[49,51,52],"player_id":732},"24":{"logic_cards":[0,0,0,0,0],"pos_index":4,"is_first_pattern":false,"played_cards":[1,1,3,4,4],"player_id":733},"5":{"logic_cards":[0],"pos_index":1,"is_first_pattern":false,"played_cards":[3],"player_id":734},"9":{"is_first_pattern":false,"played_cards":"PASS","player_id":734,"pos_index":1},"20":{"logic_cards":[0,0,0],"pos_index":4,"is_first_pattern":false,"played_cards":[6,7,8],"player_id":733},"30":{"logic_cards":[0,0,0,0],"pos_index":2,"is_first_pattern":false,"played_cards":[38,38,39,40],"player_id":732},"8":{"is_first_pattern":false,"played_cards":"PASS","player_id":733,"pos_index":4},"10":{"logic_cards":[0,0],"pos_index":2,"is_first_pattern":false,"played_cards":[33,34],"player_id":732}},"room_id":208000,"settle_account":{"name":"Game.SettleInfo","msg":{"players":[{"cards":"{}","remain_card_cnt":0,"player_id":732,"teamPickedPoints":125,"score":2,"rank":2,"current_score":2,"played_cards":"{}","lost_cnt":0,"win_cnt":1},{"cards":"[50,41,42,35,36,26,28]","remain_card_cnt":7,"player_id":733,"teamPickedPoints":65,"score":-2,"rank":0,"current_score":-2,"played_cards":"{}","lost_cnt":1,"win_cnt":0},{"cards":"{}","remain_card_cnt":0,"player_id":734,"teamPickedPoints":125,"score":2,"rank":1,"current_score":2,"played_cards":"{}","lost_cnt":0,"win_cnt":1},{"cards":"[22,23]","remain_card_cnt":2,"player_id":731,"teamPickedPoints":65,"score":-2,"rank":0,"current_score":-2,"played_cards":"{}","lost_cnt":1,"win_cnt":0}],"totalRound":4,"endTime":1526031387,"startTime":1526031141490,"round":1}}}}'
	--local record_table = ModuleCache.Json.decode(json).DHHUBEIQP_WUSHIK_WUSHIK
	local record_table = videoData[AppData.allPackageConfig.wushik:get_full_game_name()]

	local list, seatInfoList, seatDataTable, firstViewPlayerId, firstViewSeatIndex, roomInfo = self:parseMsgQueue(record_table)
	self.roomInfo = {
		roomNum = roomInfo.room_id or 0,
		curRoundNum = roomInfo.game_loop_cnt or 0,
		totalRoundCount = roomInfo.game_total_cnt or 0,
		isRoundStarted = true,
		team_card = roomInfo.team_card,
		ruleTable = roomInfo.ruleTable,
		rule = roomInfo.rule,
		wanfaName = roomInfo.wanfaName,
	}
	if(roomInfo.ruleTable.isKingMagic)then
		CardCommon.enableMagicCards(true)
	else
		CardCommon.enableMagicCards(false)
	end

	self.view:resetSeatHolderArray(#seatInfoList)
	self.view:setRoomInfo(self.roomInfo.roomNum, self.roomInfo.curRoundNum, self.roomInfo.totalRoundCount, self.roomInfo.wanfaName)
	if(self.roomInfo.team_card and self.roomInfo.team_card ~= 0)then
		self.view:showJiaoPaiFrame(true)
		self.view:refreshJiaoPai(true, self.roomInfo.team_card)
	else
		self.view:showJiaoPaiFrame(false)
	end
	self.firstViewPlayerId = firstViewPlayerId
	self.firstViewSeatIndex = firstViewSeatIndex
	self.seatInfoList = seatInfoList
	self.seatDataTable = seatDataTable
	self.videoDataList = list
	for k,v in pairs(seatInfoList) do
		self:refreshSeatAll(v, true)
	end
	
end

function WuShiKTableVideoModule:on_step(step, back)
	local gameData = step.data
	self.gameData = gameData
	if(gameData)then
		if(gameData.gameResultData)then
			self.oneGameResultModule = ModuleCache.ModuleManager.show_module(self.packageName, "onegameresult", gameData.gameResultData)
			return
		elseif(self.oneGameResultModule)then
			self.oneGameResultModule = nil
			ModuleCache.ModuleManager.destroy_module(self.packageName, "onegameresult")
		end

		for i, v in pairs(gameData.playerId_seatInfo_table) do
			local seatInfo = v
			seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), #self.seatInfoList)
			if(gameData.cur_player_id)then
				self:refreshSeatAll(seatInfo, gameData.cur_player_id ~= seatInfo.playerId or back, gameData)
			else
				self:refreshSeatAll(seatInfo, false or back, gameData)
			end
		end
	end

end

function WuShiKTableVideoModule:addCode2List(code, list)
	table.insert( list, code)
	self:sortCodeList(list)
end

function WuShiKTableVideoModule:removeCodeFromList(code, list)
	for i=1,#list do
		if(code == list[i])then
			table.remove( list, i)
			return
		end
	end
end

function WuShiKTableVideoModule:removeCodeListFromList(codeList, list)
	for i,v in ipairs(codeList) do
		self:removeCodeFromList(v, list)
	end
end


function WuShiKTableVideoModule:deep_clone(table)
	local newTable = {}
	if(type(table) == 'table')then
		for k,v in pairs(table) do
			newTable[k] = self:deep_clone(v)
		end
	else
		return table
	end
	return newTable
end


function WuShiKTableVideoModule:sortFun(name1, color1, name2, color2)
    if(name1 == CardCommon.card_A)then
        name1 = CardCommon.card_K + 0.1
    elseif(name1 == CardCommon.card_2)then
        name1 = CardCommon.card_K + 0.2
    end
    if(name2 == CardCommon.card_A)then
        name2 = CardCommon.card_K + 0.1
    elseif(name2 == CardCommon.card_2)then
        name2 = CardCommon.card_K + 0.2
    end

    if(name1> name2)then
        return -1
    elseif(name1 == name2)then
        if(color1 < color2)then
            return -1
        elseif(color1 == color2)then
            return 0
        else
            return 1
        end
    else
        return 1
    end
end

function WuShiKTableVideoModule:sortCodeList(list)
    table.sort( list, function(code1, code2) 
        local card1 = CardCommon.solveCard(code1)
        local card2 = CardCommon.solveCard(code2)
        local result = self:sortFun(card1.name, card1.color, card2.name, card2.color)
        return result < 0
    end)
end

function WuShiKTableVideoModule:getFirstViewSeatIndex()
	return self.seatDataTable[self.firstViewPlayerId].seatIndex, self.seatDataTable[self.firstViewPlayerId].new_seatIndex
end

function WuShiKTableVideoModule:changeSeatsPos(firstViewPlayerId)
	self.firstViewPlayerId = firstViewPlayerId
	local seatCount = #self.seatInfoList
	for i=1,seatCount do
		local seatInfo = self.seatInfoList[i]
		seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), seatCount)
		if(self.gameData)then
			local tmpSeatInfo = self.gameData.playerId_seatInfo_table[seatInfo.playerId]
			tmpSeatInfo.localSeatIndex = seatInfo.localSeatIndex
			seatInfo = tmpSeatInfo
		end
		self:refreshSeatAll(seatInfo, true)
	end
end

function WuShiKTableVideoModule:parseMsgQueue(record_table)
	local list = {}
	local lastGameData = {}
	local gameData = {}
	local seatInfoList = {}
	local seatInfoTable
	gameData.roomInfo = {}
	gameData.seatInfoList = {}
	gameData.playerId_seatInfo_table = {}

	local firstViewSeatIndex
	local firstViewPlayerId

	local calcSeatInfoList = function(gameData)
		gameData = gameData or lastGameData
		seatInfoTable = gameData.playerId_seatInfo_table
		for i, v in pairs(seatInfoTable) do
			if(v.seatIndex == 1)then
				if(not firstViewPlayerId)then
					firstViewPlayerId = i
					firstViewSeatIndex = v.seatIndex
				end
			end
			table.insert(seatInfoList, v)
		end

		for i, v in ipairs(seatInfoList) do
			v.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(v.seatIndex, firstViewSeatIndex, #seatInfoList)
		end
	end

	local parseGameInfoMsg = function(record_table)
		local room_id = record_table.room_id
		local info = record_table.info
		local teamInfo = record_table.teamInfo
		local roomInfo = {}
		roomInfo.room_id = room_id
		roomInfo.roomNum = roomInfo.room_id
		roomInfo.curRoundNum = record_table.current_game_loop_count
		roomInfo.game_loop_cnt = record_table.current_game_loop_count
		roomInfo.totalRoundCount = record_table.sum_game_loop_count
		roomInfo.game_total_cnt = record_table.sum_game_loop_count
		roomInfo.isRoundStarted = true
		roomInfo.team_card = teamInfo.teamCard
		roomInfo.team1 = teamInfo.team1
		roomInfo.team2 = teamInfo.team2
		roomInfo.banker_id = record_table.banker_id
		roomInfo.ruleTable = record_table.roomConfig
		roomInfo.rule = ModuleCache.Json.encode(roomInfo.ruleTable)
		roomInfo.ruleDesc = ''
		roomInfo.wanfaName = ''
		roomInfo.loopPickedPoints = 0
		roomInfo.next_is_first_pattern = true
		if(TableUtil)then
			local wanfaName, ruleDesc ,totalSeat = TableUtil.get_rule_name(roomInfo.rule, false)
			roomInfo.ruleDesc = ruleDesc or ''
			roomInfo.wanfaName = wanfaName or ''
		end


		local lord_id
		local bankerFriend_id
		if(roomInfo.team_card and roomInfo.team_card ~= 0)then
			for i, v in pairs(roomInfo.team1) do
				if(v ~= roomInfo.banker_id)then
					bankerFriend_id = v
				end
			end
		else
			lord_id = roomInfo.team1[1]
		end
		roomInfo.lord_id = lord_id
		gameData.roomInfo = roomInfo

		for i, v in pairs(info) do
			local seatInfo = {}
			seatInfo.playerId = tonumber(i)
			seatInfo.seatIndex = v.pos_index
			seatInfo.score = v.score
			seatInfo.is_offline = false
			seatInfo.round_discard_cnt = 0
			seatInfo.isReady = true
			if(seatInfo.playerId == tonumber(self.modelData.roleData.userID))then
				firstViewPlayerId = seatInfo.playerId
				firstViewSeatIndex = seatInfo.seatIndex
			end
			seatInfo.isBanker = seatInfo.playerId == roomInfo.banker_id
			seatInfo.isLord = seatInfo.playerId == lord_id
			seatInfo.isBankerFriend = seatInfo.playerId == bankerFriend_id
			seatInfo.pickedPoints = 0
			seatInfo.cards = {}
			for i = 1, #v.cards do
				table.insert(seatInfo.cards, v.cards[i])
			end
			gameData.playerId_seatInfo_table[seatInfo.playerId] = seatInfo
		end

		lastGameData = self:deep_clone(gameData)
		calcSeatInfoList(lastGameData)
		table.insert(list, lastGameData)
	end

	local parseDiscardMsg = function(msgData, nextMsgData)
		gameData.cur_player_id = msgData.player_id
		local roomInfo = gameData.roomInfo
		local lastLoopPickedPoints = roomInfo.loopPickedPoints
		roomInfo.loopPickedPoints = msgData.loopPickedPoints
		roomInfo.loopPickedPoints_changed = lastLoopPickedPoints ~= roomInfo.loopPickedPoints
		for i, v in pairs(gameData.playerId_seatInfo_table) do
			v.pickedPoints_changed = false
		end
		local seatInfo = gameData.playerId_seatInfo_table[msgData.player_id]
		if(msgData.pickedPoints)then
			seatInfo.pickedPoints = seatInfo.pickedPoints + msgData.pickedPoints
			seatInfo.pickedPoints_changed = true
		end
		if(msgData.played_cards == 'PASS')then
			seatInfo.discards = 'pass'
		else
			seatInfo.discards = msgData.played_cards
			seatInfo.logic_cards = msgData.logic_cards
			local cardPatternList = CardPattern.new(seatInfo.discards, seatInfo.logic_cards)
			if(cardPatternList)then
				seatInfo.discard_pattern = cardPatternList[1]
			end
			--assert(cardPatternList, '牌型生成错误')
			self:removeCodeListFromList(msgData.played_cards, seatInfo.cards)
		end

		local handCardSet = CardSet.new(seatInfo.cards, #seatInfo.cards)
		seatInfo.cards = handCardSet.cards
		seatInfo.rank = msgData.rank or 0
		roomInfo.next_is_first_pattern = msgData.is_first_pattern
		roomInfo.is_first_pattern = roomInfo.next_is_first_pattern
		if(roomInfo.is_first_pattern)then
			for i, v in pairs(gameData.playerId_seatInfo_table) do
				if(v ~= seatInfo)then
					v.discards = nil
					v.logic_cards = nil
				end
			end
		end
		if(nextMsgData)then
			roomInfo.next_player_id = nextMsgData.player_id
		end

		lastGameData = self:deep_clone(gameData)
		table.insert(list, lastGameData)

		if(roomInfo.is_first_pattern)then
			roomInfo.lastDisCardSeatInfo = nil
			for i, v in pairs(gameData.playerId_seatInfo_table) do
				v.discards = nil
				v.discard_pattern = nil
			end
		else
			roomInfo.lastDisCardSeatInfo = seatInfo
		end
	end

	local parseCurrentGameAccountMsg = function(msgData)
		local gameResultData = {players={}}
		local msg = msgData.msg
		for i=1,#msg.players do
			local tmpPlayer = msg.players[i]
			local seatInfo = gameData.playerId_seatInfo_table[tmpPlayer.player_id]
			local player = {}
			player.playerId = tmpPlayer.player_id
			player.playerInfo = nil
			player.seatIndex = seatInfo.seatIndex

			seatInfo.score = tmpPlayer.score
			player.rank = tmpPlayer.rank
			player.isRoomCreator = seatInfo.isCreator or false
			player.isBanker = seatInfo.isBanker or false
			player.isLord = seatInfo.isLord or false
			player.jianFen = tmpPlayer.pickedPoints
			player.teamJianFen = tmpPlayer.teamPickedPoints

			player.totalScore = tmpPlayer.score or 0
			player.score = tmpPlayer.current_score or 0
			player.multiple = tmpPlayer.multiple
			player.cards = {}
			player.played_cards = {}
			local cards = ModuleCache.Json.decode(tmpPlayer.cards)
			if(cards)then
				for i = 1, #cards do
					local code = cards[i]
					table.insert(player.cards, code)
				end
			end

			gameResultData.players[i] = player
		end
		table.sort(gameResultData.players, function(p1,p2)
			return p1.seatIndex < p2.seatIndex
		end)

		gameResultData.roomInfo = gameData.roomInfo
		gameResultData.startTime = msg.startTime
		gameResultData.endTime = msg.endTime
		gameResultData.myPlayerId = tonumber(self.modelData.roleData.userID)
		gameResultData.roomDesc = gameData.roomInfo.wanfaName
		gameResultData.hide_shareBtn = true
		gameResultData.hide_restartBtn = true
		gameData.gameResultData = gameResultData
		lastGameData = self:deep_clone(gameData)
		table.insert(list, lastGameData)
	end


	parseGameInfoMsg(record_table)

	local index = 1
	local isEnd = false
	while(not isEnd)do
		local msgData = record_table.played_cards[index .. '']
		if(not msgData)then
			isEnd = true
		else
			index = index + 1
			local nextMsgData = record_table.played_cards[(index + 1) .. '']
			parseDiscardMsg(msgData, nextMsgData)
		end
	end

	parseCurrentGameAccountMsg(record_table.settle_account)

	return list, seatInfoList, seatInfoTable, firstViewPlayerId, firstViewSeatIndex, gameData.roomInfo
end


function WuShiKTableVideoModule:refreshSeatAll(seatInfo, withoutAnim, gameData)
	seatInfo.roomInfo = self.roomInfo
	self.view:refreshSeatPlayerInfo(seatInfo)
	self.view:refreshSeatState(seatInfo)
	self.view:showSeatRankTag(seatInfo.localSeatIndex, seatInfo.rank ~= 0)
	self.view:showSeatLordTag(seatInfo.localSeatIndex, seatInfo.isLord or false)
	self.view:showSeatFriendTag(seatInfo.localSeatIndex, seatInfo.isBankerFriend or false)
	local roomInfo = self.roomInfo
	if(gameData)then
		roomInfo = gameData.roomInfo
	end
	self.view:showZhuoMianFen(not roomInfo.lord_id, roomInfo.loopPickedPoints, roomInfo.loopPickedPoints_changed or false)
	self.view:showSeatJianFen(seatInfo.localSeatIndex, not roomInfo.lord_id, seatInfo.pickedPoints, seatInfo.pickedPoints_changed or false)
	local discards = seatInfo.discards
	local logic_discards = seatInfo.logic_cards
	local discard_pattern = seatInfo.discard_pattern

	self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
	self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.cards or {})
	self.view:playSeatPassAnim(seatInfo.localSeatIndex, discards == 'pass' or false, withoutAnim)
	if(discards == 'pass')then
		if(not withoutAnim)then
			self:playPassSound(seatInfo)
		end
	end
	if(type(discards) == 'table' and (discards ~= 'pass'))then
		self.view:playDispatchPokers(seatInfo.localSeatIndex, true, discards, logic_discards, withoutAnim)
		if(not withoutAnim)then
			local lastDisCardSeatInfo = gameData.roomInfo.lastDisCardSeatInfo
			if(lastDisCardSeatInfo)then
				self:playCardPatternSoundAndEffect(seatInfo, discard_pattern, lastDisCardSeatInfo.discard_pattern)
			else
				self:playCardPatternSoundAndEffect(seatInfo, discard_pattern, nil)
			end
		end
	else
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
	end

end


--将服务器的做座位索引转换为本地位置索引
function WuShiKTableVideoModule:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		return localIndex - seatCount
	else
		return localIndex
	end
end

function WuShiKTableVideoModule:isPlayingAnim()
	for k,v in pairs(self.seatInfoList) do
		if(v.is_playing_tribute_result_amin)then
			return true
		end
		if(v.is_playing_change_pos_anim)then
			return true
		end
		if(v.is_playing_delay_refresh_amin)then
			return true
		end
	end
	return false
end

function WuShiKTableVideoModule:on_click(obj, arg)
	if(self:isPlayingAnim())then
		return
	end
	if(obj.name == "Image") then
		self:on_click_player_image(obj, arg)
	end
end


function WuShiKTableVideoModule:on_click_player_image(obj, arg)
	local seatInfo = self:getSeatInfoByHeadImageObj(obj)
	if(not seatInfo)then
		print_debug("seatInfo is not exist")
		return
	end
	self:changeSeatsPos(seatInfo.playerId)
end

function WuShiKTableVideoModule:getSeatInfoByHeadImageObj(obj)
	local seatInfoList = self.seatInfoList
	for i=1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
		if(seatHolder.imagePlayerHead.gameObject == obj)then
			return seatInfo
		end
	end
	return nil
end


--播放牌型音效
function WuShiKTableVideoModule:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	if(type == CardCommon.PT_BOMB3
	or type == CardCommon.PT_BOMB4
	or type == CardCommon.PT_BOMB5
	or type == CardCommon.PT_BOMB6
	or type == CardCommon.PT_BOMB7
	or type == CardCommon.PT_BOMB8)then	--炸弹
		self.view:playZhaDanEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_STRAIGHT)then	--顺子
		self.view:playShunZiEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_CPAIR)then	--连对
		self.view:playLianDuiEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_BOMB_KING2)then --对王炸
		self.view:playWangZhaEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_BOMB_KING3)then --三王炸
		self.view:playWangZhaEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_BOMB_KING4)then --四王炸
		self.view:playWangZhaEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_N510K)then	--副五十K
		self.view:play50KEffect(seatInfo.localSeatIndex)
	elseif(type == CardCommon.PT_P510K)then	--正五十K
		self.view:play50KEffect(seatInfo.localSeatIndex)
	end


end

--播放不出音效
function WuShiKTableVideoModule:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

function WuShiKTableVideoModule:on_destroy()
	self.oneGameResultModule = nil
	ModuleCache.ModuleManager.destroy_module(self.packageName, "onegameresult")
end


return WuShiKTableVideoModule