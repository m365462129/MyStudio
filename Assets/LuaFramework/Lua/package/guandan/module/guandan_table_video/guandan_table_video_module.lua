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
local GuanDanTableVideoModule = class('guanDanTableVideoModule', ModuleBase)
local tableSound = require('package.guandan.module.guandan_table.table_sound')
local CardCommon = require('package.guandan.module.guandan_table.gamelogic_common')
local CardPattern = require('package.guandan.module.guandan_table.gamelogic_pattern')

function GuanDanTableVideoModule:initialize(...)
	ModuleBase.initialize(self, "guandan_table_video_view", nil, ...)
	self.packageName = "guandan"
	self.moduleName = "guandan_table_video"
	self.tableSound = tableSound
end

function GuanDanTableVideoModule:on_show(intentData)
	self.view:resetSeatHolderArray(4)
	self:initData(intentData)
end


function GuanDanTableVideoModule:initData(videoData)
	--local json = '{"DHAHQP_GUANDAN_GD":{"open_card":{"pos_card":53,"pos_card_player":[28093182,28093109]},"change_pos":{"after_pos":[28091309,28093109,28091306,28093182],"befor_pos":[28093109,28091309,28091306,28093182]},"played_cards":{"53":{"played_cards":[19],"player_id":28093109,"logic_cards":[0]},"43":{"played_cards":"PASS","player_id":28091309},"63":{"played_cards":"PASS","player_id":28091306},"47":{"played_cards":[21,21,24],"player_id":28093109,"logic_cards":[0,0,0]},"37":{"played_cards":[29,30,31,32,32],"player_id":28093182,"logic_cards":[0,0,0,0,0]},"57":{"played_cards":"PASS","player_id":28091306},"27":{"played_cards":"PASS","player_id":28093109},"17":{"played_cards":[45,48,49,49,50],"player_id":28093182,"logic_cards":[0,0,0,0,0]},"13":{"played_cards":[43],"player_id":28093182,"logic_cards":[0]},"33":{"played_cards":[17,17,20,20],"player_id":28093182,"logic_cards":[0,0,0,0]},"23":{"played_cards":"PASS","player_id":28093109},"42":{"played_cards":"PASS","player_id":28091306},"52":{"played_cards":"PASS","player_id":28091309},"62":{"played_cards":[53],"player_id":28093109,"logic_cards":[0]},"36":{"played_cards":"PASS","player_id":28091306},"46":{"played_cards":"PASS","player_id":28091309},"56":{"played_cards":[41],"player_id":28093109,"logic_cards":[0]},"16":{"played_cards":"PASS","player_id":28091306},"26":{"played_cards":"PASS","player_id":28091309},"12":{"played_cards":"PASS","player_id":28091306},"22":{"played_cards":"PASS","player_id":28091309},"32":{"played_cards":"PASS","player_id":28091306},"61":{"played_cards":"PASS","player_id":28091309},"51":{"played_cards":"PASS","player_id":28091306},"41":{"played_cards":[11,12,14,14,15],"player_id":28093109,"logic_cards":[0,0,0,0,0]},"65":{"played_cards":[45,46,47,48],"player_id":28093109,"logic_cards":[0,0,0,0]},"55":{"played_cards":"PASS","player_id":28091309},"45":{"played_cards":"PASS","player_id":28091306},"35":{"played_cards":"PASS","player_id":28093109},"59":{"played_cards":[4],"player_id":28093109,"logic_cards":[0]},"49":{"played_cards":"PASS","player_id":28091309},"39":{"played_cards":"PASS","player_id":28093109},"29":{"played_cards":[53],"player_id":28093182,"logic_cards":[0]},"1":{"played_cards":[9,10,13,16,16],"player_id":28093182,"logic_cards":[0,0,0,0,0]},"3":{"played_cards":"PASS","player_id":28093109},"2":{"played_cards":"PASS","player_id":28091309},"19":{"played_cards":"PASS","player_id":28093109},"4":{"played_cards":"PASS","player_id":28091306},"7":{"played_cards":"PASS","player_id":28093109},"6":{"played_cards":"PASS","player_id":28091309},"25":{"played_cards":[7,8],"player_id":28093182,"logic_cards":[0,0]},"15":{"played_cards":"PASS","player_id":28093109},"31":{"played_cards":"PASS","player_id":28093109},"21":{"played_cards":[2,3],"player_id":28093182,"logic_cards":[0,0]},"11":{"played_cards":"PASS","player_id":28093109},"60":{"played_cards":"PASS","player_id":28091306},"40":{"played_cards":"PASS","player_id":28091306},"50":{"played_cards":[5,5,38,39,39],"player_id":28093109,"logic_cards":[0,0,0,0,0]},"54":{"played_cards":"PASS","player_id":28091306},"64":{"played_cards":"PASS","player_id":28091309},"34":{"played_cards":"PASS","player_id":28091309},"44":{"played_cards":[26,27,30,31,34,35],"player_id":28093109,"logic_cards":[0,0,0,0,0,0]},"48":{"played_cards":"PASS","player_id":28091306},"58":{"played_cards":"PASS","player_id":28091309},"28":{"played_cards":"PASS","player_id":28091306},"38":{"played_cards":"PASS","player_id":28091309},"18":{"played_cards":"PASS","player_id":28091309},"14":{"played_cards":"PASS","player_id":28091309},"24":{"played_cards":"PASS","player_id":28091306},"5":{"played_cards":[22],"player_id":28093182,"logic_cards":[0]},"9":{"played_cards":[36],"player_id":28093182,"logic_cards":[0]},"20":{"played_cards":"PASS","player_id":28091306},"30":{"played_cards":"PASS","player_id":28091309},"8":{"played_cards":"PASS","player_id":28091306},"10":{"played_cards":"PASS","player_id":28091309}},"first_player_id":28093182,"info":{"28093109":{"cards":[48,46,27,41,38,15,53,45,30,39,26,4,35,31,24,47,5,14,19,11,34,12,5,39,21,14,21],"score":3,"rest_cnt":0,"current_score":3,"tribute_info":{"send_card":0,"type":-1,"player_id":28093109,"recv_card":0}},"28091306":{"cards":[22,3,44,7,37,42,10,40,1,29,26,6,33,37,25,23,51,25,27,35,42,8,18,43,47,11,1],"score":-3,"rest_cnt":27,"current_score":-3,"tribute_info":{"send_card":0,"type":1,"player_id":28091306,"recv_card":0}},"28091309":{"cards":[18,15,41,44,28,51,23,34,40,50,36,4,33,13,24,46,19,6,12,38,9,57,52,57,52,2,28],"score":-3,"rest_cnt":27,"current_score":-3,"tribute_info":{"send_card":0,"type":1,"player_id":28091309,"recv_card":0}},"28093182":{"cards":[7,22,17,29,3,20,9,49,53,13,17,49,31,32,10,2,16,20,50,16,8,32,45,48,36,30,43],"score":3,"rest_cnt":0,"current_score":3,"tribute_info":{"send_card":0,"type":-1,"player_id":28093182,"recv_card":0}}}}}'
	--local json = '{"DHAHQP_GUANDAN_GD":{"open_card":{},"change_pos":{"after_pos":[28093109,28091309,28091311,28093182],"befor_pos":[28093109,28091309,28091311,28093182]},"played_cards":{"1":{"is_first_pattern":true,"played_cards":[9,11,13,13,14],"player_id":28093109,"logic_cards":[0,0,0,0,0]},"2":{"played_cards":"PASS","player_id":28091309},"3":{"played_cards":"PASS","player_id":28091311},"4":{"played_cards":"PASS","player_id":28093182},"5":{"is_first_pattern":true,"played_cards":[22,23,28,28,30,31],"player_id":28093109,"logic_cards":[0,0,0,0,0,0]},"6":{"played_cards":"PASS","player_id":28091309},"7":{"played_cards":"PASS","player_id":28091311},"8":{"played_cards":"PASS","player_id":28093182},"9":{"is_first_pattern":true,"played_cards":[32,35,37,41,45],"player_id":28093109,"logic_cards":[0,0,0,0,0]},"10":{"played_cards":"PASS","player_id":28091309},"11":{"played_cards":"PASS","player_id":28091311},"12":{"played_cards":"PASS","player_id":28093182},"13":{"is_first_pattern":true,"played_cards":[48],"player_id":28093109,"logic_cards":[0]},"14":{"played_cards":"PASS","player_id":28091309},"15":{"played_cards":"PASS","player_id":28091311},"16":{"played_cards":"PASS","player_id":28093182},"17":{"is_first_pattern":true,"played_cards":[2],"player_id":28093109,"logic_cards":[0]},"18":{"played_cards":"PASS","player_id":28091309},"19":{"played_cards":"PASS","player_id":28091311},"20":{"played_cards":"PASS","player_id":28093182},"21":{"is_first_pattern":true,"played_cards":[43,43],"player_id":28093109,"logic_cards":[0,0]},"22":{"played_cards":"PASS","player_id":28091309},"23":{"played_cards":"PASS","player_id":28091311},"24":{"played_cards":"PASS","player_id":28093182},"25":{"is_first_pattern":true,"played_cards":[7,8],"player_id":28093109,"logic_cards":[0,0]},"26":{"played_cards":"PASS","player_id":28091309},"27":{"played_cards":"PASS","player_id":28091311},"28":{"played_cards":"PASS","player_id":28093182},"29":{"is_first_pattern":true,"played_cards":[57],"player_id":28093109,"logic_cards":[0]},"30":{"played_cards":"PASS","player_id":28091309},"31":{"played_cards":"PASS","player_id":28091311},"32":{"played_cards":"PASS","player_id":28093182},"33":{"is_first_pattern":true,"played_cards":[49,50,51,51],"player_id":28093109,"logic_cards":[0,0,0,0]},"34":{"played_cards":"PASS","player_id":28091309},"35":{"played_cards":"PASS","player_id":28091311},"36":{"played_cards":"PASS","player_id":28093182},"37":{"is_first_pattern":true,"played_cards":[10,15,17,21,25],"player_id":28091311,"logic_cards":[0,0,0,0,0]},"38":{"played_cards":"PASS","player_id":28093182},"39":{"played_cards":"PASS","player_id":28091309},"40":{"is_first_pattern":true,"played_cards":[12],"player_id":28091311,"logic_cards":[0]},"41":{"played_cards":"PASS","player_id":28093182},"42":{"played_cards":"PASS","player_id":28091309},"43":{"is_first_pattern":true,"played_cards":[18,24,25,29,33],"player_id":28091311,"logic_cards":[0,0,0,0,0]},"44":{"played_cards":"PASS","player_id":28093182},"45":{"played_cards":"PASS","player_id":28091309},"46":{"is_first_pattern":true,"played_cards":[20],"player_id":28091311,"logic_cards":[0]},"47":{"played_cards":"PASS","player_id":28093182},"48":{"played_cards":"PASS","player_id":28091309},"49":{"is_first_pattern":true,"played_cards":[26,27],"player_id":28091311,"logic_cards":[0,0]},"50":{"played_cards":"PASS","player_id":28093182},"51":{"played_cards":"PASS","player_id":28091309},"52":{"is_first_pattern":true,"played_cards":[34,39,42,47,52],"player_id":28091311,"logic_cards":[0,0,0,0,0]},"53":{"played_cards":"PASS","player_id":28093182},"54":{"played_cards":"PASS","player_id":28091309},"55":{"is_first_pattern":true,"played_cards":[40,40,1,4,4],"player_id":28091311,"logic_cards":[0,0,0,0,0]},"56":{"played_cards":"PASS","player_id":28093182},"57":{"played_cards":"PASS","player_id":28091309},"58":{"is_first_pattern":true,"played_cards":[44],"player_id":28091311,"logic_cards":[0]},"59":{"played_cards":"PASS","player_id":28093182},"60":{"played_cards":"PASS","player_id":28091309},"61":{"is_first_pattern":true,"played_cards":[8],"player_id":28091311,"logic_cards":[0]},"62":{"played_cards":"PASS","player_id":28093182},"63":{"played_cards":"PASS","player_id":28091309},"64":{"is_first_pattern":true,"played_cards":[57],"player_id":28091311,"logic_cards":[0]}},"first_player_id":28093109,"info":{"28091309":{"cards":[45,38,22,27,47,39,16,20,10,1,36,19,52,37,34,14,32,23,21,3,36,42,9,30,53,11,26],"score":-3,"rest_cnt":27,"current_score":-3,"tribute_info":{"send_card":45,"type":1,"player_id":28091309,"recv_card":33}},"28091311":{"cards":[21,1,12,39,24,47,4,40,17,27,25,57,26,25,52,40,29,20,15,10,8,44,18,34,42,4,33],"score":3,"rest_cnt":0,"current_score":3,"tribute_info":{"send_card":33,"type":-1,"player_id":28091311,"recv_card":45}},"28093109":{"cards":[43,37,23,45,13,30,9,43,22,32,41,28,51,50,31,51,35,7,13,28,48,2,14,8,57,49,11],"score":3,"rest_cnt":0,"current_score":3,"tribute_info":{"send_card":11,"type":-1,"player_id":28093109,"recv_card":46}},"28093182":{"cards":[19,17,33,48,38,2,7,49,50,35,12,24,5,6,53,44,3,31,46,18,5,16,41,46,6,29,15],"score":-3,"rest_cnt":27,"current_score":-3,"tribute_info":{"send_card":46,"type":1,"player_id":28093182,"recv_card":11}}}}}'
	--local videoData = ModuleCache.Json.decode(json)
	local data = videoData[AppData.GuanDan_GameName]
	self.roomInfo = {
		roomNum = data.room_id or 0,
		curRoundNum = data.current_game_loop_count or 0,
		totalRoundCount = data.sum_game_loop_count or 0,
	}
	local list, seatInfoList = self:genGameData(data)
	self.view:setRoomInfo(self.roomInfo.roomNum, self.roomInfo.curRoundNum, self.roomInfo.totalRoundCount)
	self.seatInfoList = seatInfoList
	self.videoDataList = list
	for k,v in pairs(seatInfoList) do
		self:refreshSeatAll(v, true)
	end
	self.view:showMajorCard(true, self.majorCardTable[self.major_turn])
	local firstViewSeatIndex = self:getFirstViewSeatIndex()
	if(firstViewSeatIndex == 1 or firstViewSeatIndex == 3)then
		self.view:refreshTeamMajorCard(self.majorCardTable[1], self.majorCardTable[2])
	else
		self.view:refreshTeamMajorCard(self.majorCardTable[2], self.majorCardTable[1])
	end
end

function GuanDanTableVideoModule:on_step(step, back)
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
			seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), 4)
			if(data.cur_player_id)then
				self:refreshSeatAll(seatInfo, data.cur_player_id ~= seatInfo.playerId or back, data)
			else
				self:refreshSeatAll(seatInfo, false or back, data)
			end
			
			if(data.open_card)then
				self.view:showSeatMingPaiBg(true, seatInfo.localSeatIndex)
			else
				self.view:showSeatMingPaiBg(false, seatInfo.localSeatIndex)
			end
		end

		local firstViewSeatIndex = self:getFirstViewSeatIndex()
		if(firstViewSeatIndex == 1 or firstViewSeatIndex == 3)then
			self.view:refreshTeamMajorCard(self.majorCardTable[1], self.majorCardTable[2])
		else
			self.view:refreshTeamMajorCard(self.majorCardTable[2], self.majorCardTable[1])
		end

		if(data.open_center_card)then
			self.view:showCenterMingPai(true, data.open_center_card)
		else
			self.view:showCenterMingPai(false)
		end


		if(data.changePos)then
			if(data.changePos.needChange)then
				local needChangePlayerIds = data.changePos.needChangePlayerIds
				local needChangeSeatInfoList = {}
				for i,v in ipairs(needChangePlayerIds) do
					needChangeSeatInfoList[i] = data.seatData[v]
				end
				local localSeatIndex1 = self:getLocalIndexFromRemoteSeatIndex(needChangeSeatInfoList[1].seatIndex, self:getFirstViewSeatIndex(), 4)
				local localSeatIndex2 = self:getLocalIndexFromRemoteSeatIndex(needChangeSeatInfoList[2].seatIndex, self:getFirstViewSeatIndex(), 4)
				self.view:showChangeSeatInfoPanel(true, localSeatIndex1 ,localSeatIndex2)
				self.view:showNoSeatChangePanel(false)
				local count = 0
				local finishCount = 0
				local onFinishChangePos = function()
					for i,v in ipairs(seatInfoList) do
						local seatInfo = v
						seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), 4)
						self.view:refreshSeatPlayerInfo(seatInfo)
					end
				end
				local firstViewSeatIndex,new_firstViewSeatIndex = self:getFirstViewSeatIndex() 
				--交换座位
				for i=1,#seatInfoList do
					local seatInfo = seatInfoList[i]
					local data = data.seatData[seatInfo.playerId]
					
					local localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(data.new_seatIndex, new_firstViewSeatIndex, 4)
					local lastLocalSeatIndex = self:getLocalIndexFromRemoteSeatIndex(data.seatIndex, firstViewSeatIndex, 4)
					--print('-------------',seatInfo.playerId, lastLocalSeatIndex, localSeatIndex, data.seatIndex, data.new_seatIndex, firstViewSeatIndex)
					seatInfo.seatIndex = seatInfo.data.new_seatIndex
					if(localSeatIndex ~= lastLocalSeatIndex)then
						seatInfo.is_playing_change_pos_anim = true
						count = count + 1
						self.view:playChangeSeatPosAnim(lastLocalSeatIndex, localSeatIndex, function()
							finishCount = finishCount + 1
							seatInfo.is_playing_change_pos_anim = false
							if(finishCount == count)then
								onFinishChangePos()
							end
						end)
					end
				end
			else
				self.view:showChangeSeatInfoPanel(false)
				self.view:showNoSeatChangePanel(true)
			end
		else
			self.view:showChangeSeatInfoPanel(false)
			self.view:showNoSeatChangePanel(false)
		end

	end

end

function GuanDanTableVideoModule:addCode2List(code, list)
	table.insert( list, code)
	table.sort( list, function(t1,t2)
		return t1 > t2
	end)
end

function GuanDanTableVideoModule:removeCodeFromList(code, list)
	for i=1,#list do
		if(code == list[i])then
			table.remove( list, i)
			return
		end
	end
end

function GuanDanTableVideoModule:removeCodeListFromList(codeList, list)
	for i,v in ipairs(codeList) do
		self:removeCodeFromList(v, list)
	end
end


function GuanDanTableVideoModule:deep_clone(table)
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

function GuanDanTableVideoModule:getFirstViewSeatIndex()
	return self.seatInfoTable[self.firstViewPlayerId].seatIndex, self.seatInfoTable[self.firstViewPlayerId].new_seatIndex
end

function GuanDanTableVideoModule:genGameData(videoData)
	local seatInfoList = {}
	local seatInfoTable = {}
	self.seatInfoList = seatInfoList
	self.seatInfoTable = seatInfoTable
	self.majorCardTable = {}
	local seatDataTable = {}
	local tribute_info_table = {}
	local tribute_infos = {}
	local firstViewSeatIndex = 1
	local new_firstViewSeatIndex = 1
	self.firstViewPlayerId = nil
	local totalPokerCount = 0
	local lastGameData = nil
	local gameData = {seatData={}}

	local seatIndexData = self:getSeatIndexData(videoData)

	for k,v in pairs(videoData.info) do
		local playerId = tonumber(k)
		local seatInfo = {}
		seatInfo.playerId = playerId
		seatInfo.seatIndex = seatIndexData[playerId].seatIndex
		seatInfo.new_seatIndex = seatIndexData[playerId].new_seatIndex
		seatInfo.isSeated = true
		seatInfo.isReady = true
		seatInfo.isOffline = false
		seatInfo.score = v.current_score
		seatInfo.last_sccore = v.score
		seatInfo.original_hand_cards = v.cards
		table.sort(seatInfo.original_hand_cards, function(t1,t2) 
			return t1 > t2
		end)
		if(playerId == tonumber(self.modelData.roleData.userID))then
			firstViewSeatIndex = seatInfo.seatIndex
		end
		if(firstViewSeatIndex == seatInfo.seatIndex)then
			self.firstViewPlayerId = playerId
		end
		table.insert( seatInfoList, seatInfo)
		seatInfoTable[playerId] = seatInfo
		if(v.tribute_info)then
			table.insert( tribute_infos, v.tribute_info)
			tribute_info_table[playerId] = v.tribute_info
		end
	end


	for i=1,#seatInfoList do
		local seatInfo = seatInfoList[i]
		seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), 4)
	end

	local list = {}
	local index = 1
	local last_dis_player_id 
	local last_dis_cards
	local last_dis_logic_cards

	local fapaiFun = function()
		gameData = {seatData={}}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local data = {}
			data.state = 1		--发牌
			data.seatIndex = seatInfo.new_seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.played_cards = nil
			data.logic_cards = nil
			data.hand_cards = self:deep_clone(seatInfo.original_hand_cards)
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

	local liangCenterCardFun = function()
		if(not videoData.open_card or (not videoData.open_card.pos_card))then
			return
		end
		gameData = {seatData={}}
		gameData.open_center_card = videoData.open_card.pos_card
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local data = {}
			data.state = 1
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
	end

	local liangPaiFun = function()
		if(not videoData.open_card or (not videoData.open_card.pos_card))then
			return
		end

		gameData = {seatData={}}
		gameData.open_card = videoData.open_card.pos_card
		gameData.cur_player_id = videoData.open_card.pos_card_player[1]
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local data = {}
			data.state = 2
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			if(gameData.cur_player_id == seatInfo.playerId)then
				data.open_main_card = videoData.open_card.pos_card
			end
			data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)

		gameData = {seatData={}}
		gameData.open_card = videoData.open_card.pos_card
		if(#videoData.open_card.pos_card_player == 1)then
			gameData.cur_player_id = videoData.open_card.pos_card_player[1]
		else
			gameData.cur_player_id = videoData.open_card.pos_card_player[2]
		end
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local data = {}
			data.state = 3
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			if(gameData.cur_player_id == seatInfo.playerId)then
				data.open_second_card = videoData.open_card.pos_card
			else
				
			end
			data.open_main_card = lastGameData.seatData[seatInfo.playerId].open_main_card
			data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			data.after_hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
	end

	local shangGongFun = function()
		if(#tribute_infos == 0)then
			return
		end
		self:matchingTributeSenderReceiver(tribute_infos)
		gameData = {seatData={}}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local tribute_info = tribute_info_table[seatInfo.playerId]
			local data = {}
			data.state = 4
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			data.tribute_type = tribute_info.type
			if(tribute_info.type == 1)then
				data.tribute_card = tribute_info.send_card
				self:removeCodeFromList(data.tribute_card, data.hand_cards)
			end
			data.after_hand_cards = self:deep_clone(data.hand_cards)
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
		if(self:isAllKangGong(tribute_infos))then
			return
		end
		gameData = {seatData={}}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local tribute_info = tribute_info_table[seatInfo.playerId]
			local data = {}
			data.state = 4
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			data.tribute_type = tribute_info.type
			if(tribute_info.type == -1)then
				data.receive_card = tribute_info.recv_card
				if(data.receive_card and data.receive_card > 0)then
					data.after_hand_cards = self:deep_clone(data.hand_cards)
					self:addCode2List(data.receive_card, data.after_hand_cards)
				end
			end
			if(tribute_info.type == 1)then
				data.tribute_card = tribute_info.send_card
				if(tribute_info.send_card and tribute_info.send_card ~= 0)then
					data.recv_player_id = tribute_info.recv_player_id
				end
			end
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)

		gameData = {seatData={}}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local tribute_info = tribute_info_table[seatInfo.playerId]
			local data = {}
			data.state = 4
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.tribute_type = tribute_info.type
			if(tribute_info.type == -1)then
				data.tribute_card = tribute_info.send_card
				if(tribute_info.recv_card and tribute_info.recv_card > 0)then
					data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].after_hand_cards)
				else
					data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)	
				end
				if(data.tribute_card and data.tribute_card > 0)then
					self:removeCodeFromList(data.tribute_card, data.hand_cards)
				end
			else
				data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			end
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)

		gameData = {seatData={}}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local tribute_info = tribute_info_table[seatInfo.playerId]
			local data = {}
			data.state = 4
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			data.tribute_type = tribute_info.type
			if(tribute_info.type == 1)then
				data.receive_card = tribute_info.recv_card
				data.after_hand_cards = self:deep_clone(data.hand_cards)
				if(data.receive_card and data.receive_card > 0)then
					self:addCode2List(data.receive_card, data.after_hand_cards)
				end
			elseif(tribute_info.type == -1)then
				data.tribute_card = tribute_info.send_card
				if(tribute_info.send_card and tribute_info.send_card ~= 0)then
					data.recv_player_id = tribute_info.recv_player_id
				end
				data.after_hand_cards = self:deep_clone(data.hand_cards)
			else
				data.after_hand_cards = self:deep_clone(data.hand_cards)
			end
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)

	end

	local changePosFun = function()
		if(not videoData.open_card or (not videoData.open_card.pos_card))then
			return
		end
		gameData = {seatData={}}
		local needChange = false
		local needChangePlayers = {}
		for k,v in pairs(seatIndexData) do
			if(v.seatIndex ~= v.new_seatIndex)then
				needChange = true
				table.insert(needChangePlayers, v.playerId)
			end
		end
		gameData.changePos = {
			needChange = needChange,
			needChangePlayerIds = needChangePlayers,
		}
		for i=1,#seatInfoList do
			local seatInfo = seatInfoList[i]
			local data = {}
			data.state = 4
			data.seatIndex = seatInfo.seatIndex
			data.new_seatIndex = seatInfo.new_seatIndex
			data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			data.after_hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
			gameData.seatData[seatInfo.playerId] = data
		end
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
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
			local is_first_pattern = cardsData.is_first_pattern
			for i=1,#seatInfoList do
				local seatInfo = seatInfoList[i]
				local data = {}
				data.state = 7
				data.seatIndex = seatInfo.new_seatIndex
				data.new_seatIndex = seatInfo.new_seatIndex
				data.multiple = cardsData.multiple
				if(seatInfo.playerId == gameData.cur_player_id)then
					data.played_cards = cardsData.played_cards
					data.logic_cards = cardsData.logic_cards
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
						gameData.desk_logic_cards = nil
						if(type(data.played_cards) == 'table')then
							gameData.last_desk_cards = self:deep_clone(data.played_cards)
							gameData.last_desk_logic_cards = self:deep_clone(data.logic_cards)
						end
					else
						gameData.desk_cards = self:deep_clone(lastGameData.last_desk_cards)
						gameData.desk_logic_cards = self:deep_clone(lastGameData.last_desk_logic_cards)
						if(type(data.played_cards) == 'table')then
							gameData.last_desk_cards = self:deep_clone(data.played_cards)
							gameData.last_desk_logic_cards = self:deep_clone(data.logic_cards)
						else

						end

					end
				else
					if(is_first_pattern)then

					else
						data.played_cards = lastGameData.seatData[seatInfo.playerId].played_cards
						data.logic_cards = lastGameData.seatData[seatInfo.playerId].logic_cards
					end
					if(index == 1)then
						data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].after_hand_cards)
					else
						data.hand_cards = self:deep_clone(lastGameData.seatData[seatInfo.playerId].hand_cards)
					end
					if(#data.hand_cards == 0)then
						data.played_cards = nil
						data.logic_cards = nil
					end
				end
				
				gameData.seatData[seatInfo.playerId] = data
			end
			lastGameData = self:deep_clone(gameData)
			table.insert(list, gameData)
			index = index + 1
		end
	end

	local initMajorCard = function()
		self.majorCardTable[1] = videoData.major_card[1]
		self.majorCardTable[3] = videoData.major_card[1]
		self.majorCardTable[2] = videoData.major_card[2]
		self.majorCardTable[4] = videoData.major_card[2]
		self.major_turn = videoData.major_turn
	end

	local gameResultFun = function()
		if(not videoData.settle_account or (not videoData.settle_account.msg) or (not videoData.settle_account.msg.players))then
			return
		end
		gameData = {seatData={}}
		gameData.gameResultData = {
			players = {},
			hide_shareBtn = true,
			hide_restartBtn = true,
		}
		local players = videoData.settle_account.msg.players
		for i=1,#players do
			
			local player = {}
			player.playerId = players[i].player_id
			local seatInfo = seatInfoTable[player.playerId]
			player.playerInfo = seatInfo.playerInfo
			player.seatIndex = seatInfo.new_seatIndex
			player.score = players[i].current_score
			player.uplevel =  players[i].uplevel or 0
			player.multiple =  players[i].multiple or 0
			player.rank = players[i].rank
			gameData.gameResultData.players[i] = player
		end
		table.sort(gameData.gameResultData.players, function(p1,p2)
			return p1.seatIndex < p2.seatIndex
		end)
		gameData.gameResultData.roomInfo = self.roomInfo
		gameData.gameResultData.time = videoData.settle_account.msg.endTime
		gameData.gameResultData.myPlayerId = tonumber(self.modelData.roleData.userID)
		lastGameData = self:deep_clone(gameData)
		table.insert(list, gameData)
	end

	liangCenterCardFun()
	liangPaiFun()
	changePosFun()
	fapaiFun()
	initMajorCard()
	shangGongFun()
	playFun()
	gameResultFun()

	return list, seatInfoList, seatInfoTable
end


function GuanDanTableVideoModule:getSeatIndexData(videoData)
	local seatIndexData = {}
	local after_pos = videoData.change_pos.after_pos
	local befor_pos = videoData.change_pos.before_pos or videoData.change_pos.befor_pos
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

function GuanDanTableVideoModule:matchingTributeSenderReceiver(tribute_infos)
	for i=1,#tribute_infos do
		local send_card = tribute_infos[i].send_card
		if(not tribute_infos[i].recv_player_id)then
			for j=1,#tribute_infos do
				local recv_card = tribute_infos[j].recv_card
				if(send_card == recv_card and tribute_infos[i].type ~= tribute_infos[j].type)then
					if(not tribute_infos[j].from_player_id)then
						tribute_infos[j].from_player_id = tribute_infos[i].player_id
						tribute_infos[i].recv_player_id = tribute_infos[j].player_id
						break
					end
				end
			end
		end
	end
	--print_table(tribute_infos)
end

function GuanDanTableVideoModule:isAllKangGong(tribute_infos)
	for i,v in ipairs(tribute_infos) do
		if(v.send_card and v.send_card ~= 0)then
			return false
		end
	end
	return true
end

function GuanDanTableVideoModule:changeSeatsPos(firstViewPlayerId)
	self.firstViewPlayerId = firstViewPlayerId
	local seatCount = #self.seatInfoList
	for i=1,seatCount do
		local seatInfo = self.seatInfoList[i]
		seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), seatCount)
		self:refreshSeatAll(seatInfo, true)
	end
	local firstViewSeatIndex = self:getFirstViewSeatIndex()
	if(firstViewSeatIndex == 1 or firstViewSeatIndex == 3)then
		self.view:refreshTeamMajorCard(self.majorCardTable[1], self.majorCardTable[2])
	else
		self.view:refreshTeamMajorCard(self.majorCardTable[2], self.majorCardTable[1])
	end
end

function GuanDanTableVideoModule:refreshSeatAll(seatInfo, withoutAnim, gameData)
	self.view:refreshSeatPlayerInfo(seatInfo)
	local data = seatInfo.data
	if(not data)then
		self.view:showSeatHandPokers(seatInfo, false)
		self.view:playSeatPassAnim(seatInfo.localSeatIndex, false)
		self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		self.view:showKangGongAnim(seatInfo.localSeatIndex, false)
		self.view:showTributeCard(seatInfo.localSeatIndex, false)
		self.view:showSeatMingPaiMain(false, seatInfo.localSeatIndex)
		self.view:playSeatMingPaiSecond(false, seatInfo.localSeatIndex)
	else
		self.view:showSeatHandPokers(seatInfo, true)
		self.view:refreshSeatHandPokers(seatInfo, data.hand_cards or {})
		self.view:playSeatPassAnim(seatInfo.localSeatIndex, data.played_cards == 'PASS' or false, withoutAnim)	
		if(data.played_cards == 'PASS')then
			if(not withoutAnim)then
				self:playPassSound(seatInfo)
			end
		end
		if(data.played_cards and (data.played_cards ~= 'PASS'))then
			self.view:playDispatchPokers(seatInfo.localSeatIndex, true, data.played_cards,data.logic_cards,withoutAnim)
			if(not withoutAnim)then
				local cardPatternList = CardPattern.new(data.played_cards, data.logic_cards)
				local desk_pattern = nil
				if(gameData and gameData.desk_cards)then
					local desk_cardPatternList = CardPattern.new(gameData.desk_cards, gameData.desk_logic_cards)
					if(desk_cardPatternList)then
						desk_pattern = desk_cardPatternList[1]
					end
				end
				if(cardPatternList)then
					self:playCardPatternSoundAndEffect(seatInfo, cardPatternList[1], desk_pattern)
				else
					
				end
			end
		else
			self.view:playDispatchPokers(seatInfo.localSeatIndex, false)
		end

		if(data.open_main_card)then
			self.view:showSeatMingPaiMain(true, seatInfo.localSeatIndex, data.open_main_card)
		else
			self.view:showSeatMingPaiMain(false, seatInfo.localSeatIndex)
		end
		if(data.open_second_card)then
			self.view:playSeatMingPaiSecond(true, seatInfo.localSeatIndex, data.open_second_card, withoutAnim)
		else
			self.view:playSeatMingPaiSecond(false, seatInfo.localSeatIndex)
		end

		if(data.tribute_card)then
			if(data.tribute_card == 0)then
				if(data.tribute_type == 1)then
					self.view:showKangGongAnim(seatInfo.localSeatIndex, true)
				end
				self.view:showTributeCard(seatInfo.localSeatIndex, false)
			else
				if(data.recv_player_id)then	
					local recv_seatInfo = self.seatInfoTable[data.recv_player_id]
					if(withoutAnim)then
						seatInfo.is_playing_delay_refresh_amin = true
						self:subscibe_time_event(0.01, false, 0):OnComplete(function(t)
							seatInfo.is_playing_delay_refresh_amin = false
							self.view:refreshSeatHandPokers(recv_seatInfo, recv_seatInfo.data.after_hand_cards)
						end)
						
						-- print(data.recv_player_id, recv_seatInfo.playerInfo.playerName, #recv_seatInfo.data.after_hand_cards)
						-- print_table(recv_seatInfo.data.after_hand_cards)
					else
						self.view:showTributeCard(seatInfo.localSeatIndex, true, data.tribute_card, true)
						seatInfo.is_playing_tribute_result_amin = true
						self.view:playChangeTributeCardAnim(seatInfo.localSeatIndex, recv_seatInfo.localSeatIndex, function()
							self.view:showTributeCard(seatInfo.localSeatIndex, false)
							self.view:showTributeCard(recv_seatInfo.localSeatIndex, true, data.tribute_card, true)
							self.view:playTributeCardFly2Head(recv_seatInfo.localSeatIndex, function()
								self.view:showTributeCard(recv_seatInfo.localSeatIndex, false)
								self.view:refreshSeatHandPokers(recv_seatInfo, recv_seatInfo.data.after_hand_cards)
								seatInfo.is_playing_tribute_result_amin = false
							end)
						end)
					end
				else
					self.view:showTributeCard(seatInfo.localSeatIndex, true, data.tribute_card)
				end
			end
		else
			self.view:showKangGongAnim(seatInfo.localSeatIndex, false)
			self.view:showTributeCard(seatInfo.localSeatIndex, false)
		end

	end

end

function GuanDanTableVideoModule:hideAllSeatTributeCard()
	for k,v in pairs(self.seatInfoList) do
		self.view:showTributeCard(v.localSeatIndex, false)
		self.view:showKangGongAnim(v.localSeatIndex, false)
	end
end

--将服务器的做座位索引转换为本地位置索引
function GuanDanTableVideoModule:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		return localIndex - seatCount
	else
		return localIndex
	end
end

function GuanDanTableVideoModule:isPlayingAnim()
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

function GuanDanTableVideoModule:on_click(obj, arg)
	if(self:isPlayingAnim())then
		return
	end
	if(obj.name == "Image") then
		self:on_click_player_image(obj, arg)
	end
end


function GuanDanTableVideoModule:on_click_player_image(obj, arg)
	local seatInfo = self:getSeatInfoByHeadImageObj(obj)
	if(not seatInfo)then
		print_debug("seatInfo is not exist")
		return
	end
	self:changeSeatsPos(seatInfo.playerId)
end

function GuanDanTableVideoModule:getSeatInfoByHeadImageObj(obj)
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
function GuanDanTableVideoModule:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	if(type == CardCommon.type_four
	or type == CardCommon.type_five
	or type == CardCommon.type_six
	or type == CardCommon.type_seven
	or type == CardCommon.type_eight
	or type == CardCommon.type_four_king)then
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.type_five_same_color)then
		--self.view:playTongHuaShunEffect(seatInfo)
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.type_triple2)then	--3连对
		self.view:playLianDuiEffect(seatInfo)
	elseif(type == CardCommon.type_double3)then --飞机
		self.view:playFeiJiEffect(seatInfo)
	elseif(type == CardCommon.type_single_5)then
		self.view:playShunZiEffect(seatInfo)
	end

end

--播放不出音效
function GuanDanTableVideoModule:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

function GuanDanTableVideoModule:on_destroy()
	self.oneGameResultModule = nil
	ModuleCache.ModuleManager.destroy_module(self.packageName, "onegameresult")
end


return GuanDanTableVideoModule 