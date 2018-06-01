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
local DouDiZhuTableVideoModule = class('douDiZhuTableVideoModule', ModuleBase)
local CardCommon = require('package.doudizhu.module.doudizhu_table.gamelogic_common')
local CardPattern = require('package.doudizhu.module.doudizhu_table.gamelogic_pattern')
local tableSound = require('package.doudizhu.module.doudizhu_table.table_sound')

function DouDiZhuTableVideoModule:initialize(...)
	ModuleBase.initialize(self, "table_video_view", nil, ...)
	self.packageName = "doudizhu"
	self.moduleName = "table_video"
	self.tableSound = tableSound
end

function DouDiZhuTableVideoModule:on_show(intentData)
	self:initData(intentData)
end


function DouDiZhuTableVideoModule:initData(videoData)
	-- local json = '{"DHAHQP_DOUDIZHU_DOUDIZHU":{"settle_account":{"players":[{"cards":[32,36,27,31,49,39,3,18,17,9,51,2,48,8,7,22,26],"show_cards":false,"spring":false,"player_id":964,"current_score":-3,"current_bomb_cnt":0,"bomb_cnt":0,"score":-3,"remain_card_cnt":3,"played_cards":{"1":"PASS","3":[26,27],"2":"PASS","5":[17,18],"4":[49,51],"7":[31,32],"6":[2,3],"9":[9],"8":[7,8],"12":"PASS","11":"PASS","10":[39]},"lost_cnt":1,"win_cnt":0},{"cards":[41,19,45,6,38,37,20,4,10,15,53,28,50,33,47,30,44],"show_cards":false,"spring":false,"player_id":965,"current_score":-3,"current_bomb_cnt":0,"bomb_cnt":0,"score":-3,"remain_card_cnt":8,"played_cards":{"1":"PASS","3":[37,38],"2":"PASS","5":[41,44],"4":"PASS","7":[45,47],"6":"PASS","9":[15],"8":"PASS","12":"PASS","11":[53],"10":[50]},"lost_cnt":1,"win_cnt":0},{"cards":[35,5,42,14,21,46,16,52,25,11,40,24,13,57,43,12,34],"show_cards":true,"spring":false,"player_id":963,"current_score":6,"current_bomb_cnt":0,"bomb_cnt":0,"score":6,"remain_card_cnt":0,"played_cards":{"1":[1,52,46,42,40,34,29,25,21],"3":[23,24],"2":[13,14,16,11,12],"5":"PASS","4":"PASS","7":"PASS","6":"PASS","9":"PASS","8":"PASS","13":[43],"12":[57],"11":[5],"10":[35]},"lost_cnt":0,"win_cnt":1}],"game_count":4,"endTime":1508399133,"startTime":1508399041,"is_free_room":false},"dipai":[1,29,23],"info":{"964":{"cards":[32,36,27,31,49,39,3,18,17,9,51,2,48,8,7,22,26],"score":-3,"beishu":1,"rest_cnt":3,"bomb_cnt":0,"pos":2,"show_card":false},"965":{"cards":[41,19,45,6,38,37,20,4,10,15,53,28,50,33,47,30,44],"score":-3,"beishu":1,"rest_cnt":8,"bomb_cnt":0,"pos":3,"show_card":false},"963":{"cards":[35,5,42,14,21,46,16,52,25,11,40,24,13,57,43,12,34],"score":6,"beishu":3,"rest_cnt":0,"bomb_cnt":0,"pos":1,"show_card":true}},"round_count":1,"roomid":509528,"played_cards":{"37":{"cards":[43],"player_id":963,"is_first":true},"35":{"player_id":964,"cards":"PASS"},"29":{"player_id":964,"cards":[39]},"1":{"cards":[1,52,46,42,40,34,29,25,21],"player_id":963,"is_first":true},"3":{"player_id":965,"cards":"PASS"},"2":{"player_id":964,"cards":"PASS"},"5":{"player_id":964,"cards":"PASS"},"4":{"cards":[13,14,16,11,12],"player_id":963,"is_first":true},"7":{"cards":[23,24],"player_id":963,"is_first":true},"6":{"player_id":965,"cards":"PASS"},"9":{"player_id":965,"cards":[37,38]},"8":{"player_id":964,"cards":[26,27]},"27":{"player_id":965,"cards":[15]},"17":{"player_id":964,"cards":[2,3]},"13":{"player_id":963,"cards":"PASS"},"21":{"player_id":965,"cards":[45,47]},"11":{"player_id":964,"cards":[49,51]},"23":{"player_id":964,"cards":[7,8]},"36":{"player_id":965,"cards":"PASS"},"34":{"player_id":963,"cards":[57]},"28":{"player_id":963,"cards":[35]},"33":{"player_id":965,"cards":[53]},"32":{"player_id":964,"cards":"PASS"},"31":{"player_id":963,"cards":[5]},"30":{"player_id":965,"cards":[50]},"15":{"player_id":965,"cards":[41,44]},"18":{"player_id":965,"cards":"PASS"},"19":{"player_id":963,"cards":"PASS"},"25":{"player_id":963,"cards":"PASS"},"14":{"cards":[17,18],"player_id":964,"is_first":true},"24":{"player_id":965,"cards":"PASS"},"16":{"player_id":963,"cards":"PASS"},"26":{"cards":[9],"player_id":964,"is_first":true},"20":{"cards":[31,32],"player_id":964,"is_first":true},"12":{"player_id":965,"cards":"PASS"},"22":{"player_id":963,"cards":"PASS"},"10":{"player_id":963,"cards":"PASS"}},"total_count":4,"lordid":963}}'
	-- local videoData = ModuleCache.Json.decode(json)
	local data = videoData[AppData.DouDiZhu_GameName]
	self.roomInfo = {
		roomNum = data.roomid or 0,
		curRoundNum = data.round_count or 0,
		totalRoundCount = data.total_count or 0,
		isRoundStarted = true,
		di_cards = data.dipai
	}
	local list, seatInfoList = self:genGameData(data)
	self.view:resetSeatHolderArray(#seatInfoList)
	self.view:setRoomInfo(self.roomInfo)
	self.view:showDeskLeftCards(true)
	self.view:refreshDeskLeftCards(self.roomInfo.di_cards)
	self.seatInfoList = seatInfoList
	self.videoDataList = list
	for k,v in pairs(seatInfoList) do
		self:refreshSeatAll(v, true)
	end
	
end

function DouDiZhuTableVideoModule:on_step(step, back)
	local data = step.data
	local seatInfoList = self.seatInfoList
	if(data)then
		if(data.gameResultData)then
			self.oneGameResultModule = ModuleCache.ModuleManager.show_module(self.packageName, "onegameresult", data.gameResultData)
			return
		elseif(self.oneGameResultModule)then
			self.oneGameResultModule = nil
			ModuleCache.ModuleManager.destroy_module(self.packageName, "onegameresult")
		end
		for i=1,#self.seatInfoList do
			local seatInfo = self.seatInfoList[i]
			seatInfo.data = data.seatData[seatInfo.playerId]
			seatInfo.seatIndex = seatInfo.data.seatIndex
			seatInfo.new_seatIndex = seatInfo.data.new_seatIndex
		end
		for i,v in ipairs(self.seatInfoList) do
			local seatInfo = v
			seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), 3)
			if(data.cur_player_id)then
				self:refreshSeatAll(seatInfo, data.cur_player_id ~= seatInfo.playerId or back, data)
			else
				self:refreshSeatAll(seatInfo, false or back, data)
			end
			
		end
	end

end

function DouDiZhuTableVideoModule:addCode2List(code, list)
	table.insert( list, code)
	self:sortCodeList(list)
end

function DouDiZhuTableVideoModule:removeCodeFromList(code, list)
	for i=1,#list do
		if(code == list[i])then
			table.remove( list, i)
			return
		end
	end
end

function DouDiZhuTableVideoModule:removeCodeListFromList(codeList, list)
	for i,v in ipairs(codeList) do
		self:removeCodeFromList(v, list)
	end
end


function DouDiZhuTableVideoModule:deep_clone(table)
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


function DouDiZhuTableVideoModule:sortFun(name1, color1, name2, color2)
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

function DouDiZhuTableVideoModule:sortCodeList(list)
    table.sort( list, function(code1, code2) 
        local card1 = CardCommon.ResolveCardIdx(code1)
        local card2 = CardCommon.ResolveCardIdx(code2)
        local result = self:sortFun(card1.name, card1.color, card2.name, card2.color)
        return result < 0
    end)
end

function DouDiZhuTableVideoModule:getFirstViewSeatIndex()
	return self.seatInfoTable[self.firstViewPlayerId].seatIndex, self.seatInfoTable[self.firstViewPlayerId].new_seatIndex
end

function DouDiZhuTableVideoModule:changeSeatsPos(firstViewPlayerId)
	self.firstViewPlayerId = firstViewPlayerId
	local seatCount = #self.seatInfoList
	for i=1,seatCount do
		local seatInfo = self.seatInfoList[i]
		seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), seatCount)
		self:refreshSeatAll(seatInfo, true)
	end
end

function DouDiZhuTableVideoModule:genGameData(videoData)
	local seatInfoList = {}
	local seatInfoTable = {}
	self.seatInfoList = seatInfoList
	self.seatInfoTable = seatInfoTable
	self.majorCardTable = {}
	local seatDataTable = {}
	local firstViewSeatIndex = 1
	local new_firstViewSeatIndex = 1
	self.firstViewPlayerId = nil
	local totalPokerCount = 0
	local lastGameData = nil
	local gameData = {seatData={}}
	if(videoData.roomtype)then
		self.isGoldSettle = videoData.roomtype ~= 0
	else
		self.isGoldSettle = false
	end
	local seatIndexData = self:getSeatIndexData(videoData)

	for k,v in pairs(videoData.info) do
		local playerId = tonumber(k)
		local seatInfo = {}
		seatInfo.roomInfo = self.roomInfo
		seatInfo.playerId = playerId
		if(playerId == videoData.lordid)then
			seatInfo.isLord = true
		end
		seatInfo.seatIndex = seatIndexData[playerId].seatIndex
		seatInfo.new_seatIndex = seatIndexData[playerId].new_seatIndex
		seatInfo.isSeated = true
		seatInfo.isReady = true
		seatInfo.isOffline = false
		seatInfo.score = v.score
		seatInfo.original_hand_cards = v.cards or {}
		seatInfo.show_card = v.show_card
		seatInfo.beishu = v.beishu
		seatInfo.coinBalance = v.coinBalance or v.coinbalance or 0
		self:sortCodeList(seatInfo.original_hand_cards)
		if(playerId == tonumber(self.modelData.roleData.userID))then
			firstViewSeatIndex = seatInfo.seatIndex
		end
		if(firstViewSeatIndex == seatInfo.seatIndex)then
			self.firstViewPlayerId = playerId
		end
		table.insert( seatInfoList, seatInfo)
		seatInfoTable[playerId] = seatInfo
	end


	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), #seatInfoList)
	end

	local list = {}
	local index = 1
	local last_dis_player_id 
	local last_dis_cards

	local fapaiFun = function()
		gameData = {seatData={}}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local data = {}
			data.state = 1		--发牌
			data.seatIndex = seatInfo.new_seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.played_cards = nil
			data.hand_cards = self:deep_clone(seatInfo.original_hand_cards)
			data.beishu = seatInfo.beishu
			data.after_hand_cards = self:deep_clone(data.hand_cards)
			totalPokerCount = totalPokerCount + #data.hand_cards
			seatDataTable[seatInfo.playerId] = self:deep_clone(data)
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
		local seatCount = #self.seatInfoList
		for i=1,seatCount do
			local seatInfo = self.seatInfoList[i]
			seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), seatCount)
		end
	end


	local playFun = function()
		local index = 1
		while index < 1000 do
			local cardsData = videoData.played_cards[index .. '']
			if(not cardsData)then
				break
			end
			
			gameData = {seatData={}}
			gameData.cur_player_id = cardsData.player_id
			gameData.last_desk_cards = lastGameData.last_desk_cards
			local is_first_pattern = cardsData.is_first
			for i=1,#seatInfoList do
				local seatInfo = seatInfoList[i]
				local data = {}
				data.state = 7
				data.seatIndex = seatInfo.new_seatIndex
				data.new_seatIndex = seatInfo.new_seatIndex
				data.beishu = lastGameData.seatData[seatInfo.playerId].beishu
				if(cardsData.beishu_change)then
					for i,v in ipairs(cardsData.beishu_change) do
						if(v.playerid == seatInfo.playerId)then
							data.beishu = v.beishu
						end
					end
				end
				if(seatInfo.playerId == gameData.cur_player_id)then
					data.played_cards = cardsData.cards
					if(index == 1)then
						data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].after_hand_cards)
					else
						data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
					end
					if(type(data.played_cards) == 'table')then
						self:removeCodeListFromList(data.played_cards, data.hand_cards)
					end
					if(is_first_pattern)then
						gameData.desk_cards = nil
						if(type(data.played_cards) == 'table')then
							gameData.last_desk_cards = self:deep_clone(data.played_cards)
						end
					else
						gameData.desk_cards = self:deep_clone(lastGameData.last_desk_cards)
						if(type(data.played_cards) == 'table')then
							gameData.last_desk_cards = self:deep_clone(data.played_cards)
						else

						end

					end
				else
					if(is_first_pattern)then
						
					else
						data.played_cards = lastGameData.seatData[seatInfo.playerId].played_cards
					end
					if(index == 1)then
						data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].after_hand_cards)
					else
						data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
					end
					if(#data.hand_cards == 0)then
						data.played_cards = nil
					end
				end
				
				gameData.seatData[seatInfo.playerId] = data
			end
			lastGameData = self:deep_clone(gameData)
			table.insert(list, gameData)
			index = index + 1
		end
	end


	local gameResultFun = function()
		if(not videoData.settle_account)then
			return
		end
		gameData = {seatData={}}
		gameData.gameResultData = {
			players = {},
			hide_shareBtn = true,
			hide_restartBtn = true,
		}
		local players = videoData.settle_account.players

		for i=1,#players do
			local player = {}
			player.playerId = players[i].player_id
			local seatInfo = seatInfoTable[player.playerId]
			player.playerInfo = seatInfo.playerInfo
			player.seatIndex = seatInfo.new_seatIndex
			player.score = players[i].current_score
			player.spring =  players[i].spring
			player.bombCount =  players[i].bombCount or 0
			player.show_cards = players[i].show_cards
			player.cards = players[i].cards
			player.multiple = players[i].beishu or 1
			player.restCoin = players[i].restCoin		--金币场未结清的输赢
			player.restRedPackage = (players[i].restCoin or 0) * 0.001
			player.coin = players[i].Coin
			player.coinBalance = players[i].coinBalance

			self:sortCodeList(player.cards)
			player.isLord = seatInfo.isLord
			if(self.isGoldSettle)then
				player.coin = player.coin + player.restCoin
			end
			gameData.gameResultData.players[i] = player
		end
		table.sort(gameData.gameResultData.players, function(p1,p2)
			return p1.seatIndex < p2.seatIndex
		end)
		gameData.gameResultData.roomInfo = self.roomInfo
		gameData.gameResultData.endTime = videoData.settle_account.endTime
		gameData.gameResultData.startTime = videoData.settle_account.startTime
		gameData.gameResultData.free_sponsor = videoData.settle_account.free_sponsor
		gameData.gameResultData.is_free_room = videoData.settle_account.is_free_room
		gameData.gameResultData.myPlayerId = tonumber(self.modelData.roleData.userID)
		if(self.isGoldSettle)then
			gameData.gameResultData.is_gold_settle = true
			gameData.gameResultData.is_gold_table_settle = false
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
	end

	fapaiFun()	
	playFun()
	gameResultFun()

	return list, seatInfoList, seatInfoTable
end


function DouDiZhuTableVideoModule:getSeatIndexData(videoData)
	local seatIndexData = {}
	local after_pos = {}
	for k,v in pairs(videoData.info) do
		after_pos[v.pos] = tonumber(k)
	end
	local befor_pos = after_pos
	for i,v in ipairs(befor_pos) do
		seatIndexData[v] = {}
		seatIndexData[v].seatIndex = i
		seatIndexData[v].playerId = v
	end
	for i,v in ipairs(after_pos) do
		seatIndexData[v].new_seatIndex = i
	end
	return seatIndexData
end


function DouDiZhuTableVideoModule:refreshSeatAll(seatInfo, withoutAnim, gameData)
	self.view:showSeatGoldCoin(seatInfo.localSeatIndex, self.isGoldSettle, not self.isGoldSettle)
	self.view:refreshSeatPlayerInfo(seatInfo)
	self.view:refreshSeatState(seatInfo)
	self.view:showSeatLandLordIcon(seatInfo.localSeatIndex, seatInfo.isLord or false)
	local data = seatInfo.data
	if(not data)then
		self.view:showSeatHandPokers(seatInfo.localSeatIndex, false)
		self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
	else
		self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
		local cardAssetHolder = nil
		if(seatInfo.seatIndex == self:getFirstViewSeatIndex())then
			cardAssetHolder = self.view.cardAssetHolder
		end
		self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, data.hand_cards or {}, seatInfo.isLord, seatInfo.show_card, cardAssetHolder)
		self.view:playSeatPassAnim(seatInfo.localSeatIndex, data.played_cards == 'PASS' or false, withoutAnim)	
		if(data.played_cards == 'PASS')then
			if(not withoutAnim)then
				self:playPassSound(seatInfo)
			end
		end
		if(data.played_cards and (data.played_cards ~= 'PASS'))then
			self.view:playDispatchPokers(seatInfo.localSeatIndex, true, data.played_cards, seatInfo.isLord, withoutAnim)
			if(not withoutAnim)then
				local cardPattern = CardPattern.new(data.played_cards)
				local desk_pattern = nil
				if(gameData and gameData.desk_cards)then
					desk_pattern = CardPattern.new(gameData.desk_cards)
				end
				if(cardPattern)then
					self:playCardPatternSoundAndEffect(seatInfo, cardPattern, desk_pattern)
				else
					
				end
			end
		else
			self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		end
		if(self.firstViewPlayerId == seatInfo.playerId)then
			self.view:showMultiple(true, data.beishu)
		end
	end

end


--将服务器的做座位索引转换为本地位置索引
function DouDiZhuTableVideoModule:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		return localIndex - seatCount
	else
		return localIndex
	end
end

function DouDiZhuTableVideoModule:isPlayingAnim()
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

function DouDiZhuTableVideoModule:on_click(obj, arg)
	if(self:isPlayingAnim())then
		return
	end
	if(obj.name == "Image") then
		self:on_click_player_image(obj, arg)
	end
end


function DouDiZhuTableVideoModule:on_click_player_image(obj, arg)
	local seatInfo = self:getSeatInfoByHeadImageObj(obj)
	if(not seatInfo)then
		print_debug("seatInfo is not exist")
		return
	end
	self:changeSeatsPos(seatInfo.playerId)
end

function DouDiZhuTableVideoModule:getSeatInfoByHeadImageObj(obj)
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
function DouDiZhuTableVideoModule:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	if(type == CardCommon.zhadan)then
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.huojian)then
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.liandui)then	--3连对
		self.view:playLianDuiEffect(seatInfo)
	elseif(type == CardCommon.feiji)then --飞机
		self.view:playFeiJiEffect(seatInfo)
	elseif(type == CardCommon.shunzi)then
		self.view:playShunZiEffect(seatInfo)
	end

end

--播放不出音效
function DouDiZhuTableVideoModule:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

function DouDiZhuTableVideoModule:on_destroy()
	self.oneGameResultModule = nil
	ModuleCache.ModuleManager.destroy_module(self.packageName, "onegameresult")
end


return DouDiZhuTableVideoModule 