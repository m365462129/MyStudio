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
---@class DaiGouTuiTableVideoModule:ModuleBase
---@field view DaiGouTuiTableVideoView
local DaiGouTuiTableVideoModule = class('daiGouTuiTableVideoModule', ModuleBase)
local CardCommon = require('package.daigoutui.module.table.gamelogic_common')
local CardPattern = require('package.daigoutui.module.table.gamelogic_pattern')
local CardSet = require('package.daigoutui.module.table.gamelogic_set')
local tableSound = require('package.daigoutui.module.table.table_sound')

function DaiGouTuiTableVideoModule:initialize(...)
	ModuleBase.initialize(self, "table_video_view", nil, ...)
	self.packageName = "daigoutui"
	self.moduleName = "table_video"
	self.tableSound = tableSound
	self.myHandPokers = (require("package/daigoutui/module/table/handpokers")):new(self)
	self.view.firstViewHandPokers = self.myHandPokers
end

function DaiGouTuiTableVideoModule:on_show(intentData)
	self:initData(intentData)
end


function DaiGouTuiTableVideoModule:initData(videoData)
	--local json = '[{"to":0,"msg":{"name":"Room.ResetBroadcast","msg":{"pos_infos":[{"is_ready":1,"player_id":504,"pos_index":2},{"is_ready":1,"player_id":506,"pos_index":3},{"is_ready":1,"player_id":501,"pos_index":1},{"is_ready":1,"player_id":502,"pos_index":5},{"is_ready":1,"player_id":503,"pos_index":4}]}}},{"msg":{"name":"Room.StartRsp","msg":{"err_no":"0"}}},{"to":0,"msg":{"name":"Room.StartBroadcast","msg":{"err_no":"0"}}},{"to":504,"msg":{"name":"1","msg":{"1":330594,"14":504,"3":1,"2":[{"19":504,"33":0,"27":0,"35":false,"25":0,"24":true,"28":38,"29":-1,"20":2,"26":0,"22":false,"23":false},{"19":506,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":3,"26":0,"22":false,"23":false},{"19":501,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":1,"26":0,"22":false,"23":true},{"19":502,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":5,"26":0,"22":false,"23":false},{"19":503,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":4,"26":0,"22":false,"23":false}],"5":0,"18":1,"34":[265,521,777,269,525,781,273,529,785,277,533,789,281,537,793,285,541,797,289,545,801,293,549,805,297,553,261,262,263,264,517,518,519,520,773,774,775,776],"6":{},"9":1513089820,"15":false,"4":4,"17":0,"7":504,"12":286,"11":1,"8":true}}},{"to":506,"msg":{"name":"1","msg":{"1":330594,"14":504,"3":1,"2":[{"19":504,"33":0,"27":0,"35":false,"25":0,"24":true,"28":38,"29":-1,"20":2,"26":0,"22":false,"23":false},{"19":506,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":3,"26":0,"22":false,"23":false},{"19":501,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":1,"26":0,"22":false,"23":true},{"19":502,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":5,"26":0,"22":false,"23":false},{"19":503,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":4,"26":0,"22":false,"23":false}],"5":0,"18":1,"34":[266,522,270,526,274,530,278,534,282,538,286,542,290,546,294,550,298,554,302,558,305,306,561,817,258,259,514,769,313,569,825],"6":{},"9":1513089820,"15":false,"4":4,"17":0,"7":504,"12":286,"11":1,"8":true}}},{"to":501,"msg":{"name":"1","msg":{"1":330594,"14":504,"3":1,"2":[{"19":504,"33":0,"27":0,"35":false,"25":0,"24":true,"28":38,"29":-1,"20":2,"26":0,"22":false,"23":false},{"19":506,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":3,"26":0,"22":false,"23":false},{"19":501,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":1,"26":0,"22":false,"23":true},{"19":502,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":5,"26":0,"22":false,"23":false},{"19":503,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":4,"26":0,"22":false,"23":false}],"5":0,"18":1,"34":[267,523,778,271,782,275,786,279,790,283,794,287,798,291,802,295,806,299,810,303,814,307,562,818,257,513,515,770,309,565,821],"6":{},"9":1513089820,"15":false,"4":4,"17":0,"7":504,"12":286,"11":1,"8":true}}},{"to":502,"msg":{"name":"1","msg":{"1":330594,"14":504,"3":1,"2":[{"19":504,"33":0,"27":0,"35":false,"25":0,"24":true,"28":38,"29":-1,"20":2,"26":0,"22":false,"23":false},{"19":506,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":3,"26":0,"22":false,"23":false},{"19":501,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":1,"26":0,"22":false,"23":true},{"19":502,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":5,"26":0,"22":false,"23":false},{"19":503,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":4,"26":0,"22":false,"23":false}],"5":0,"18":1,"34":[268,779,272,527,783,276,531,787,280,535,791,284,539,795,288,543,799,547,803,551,807,555,809,811,559,813,815,563,819,260,771],"6":{},"9":1513089820,"15":false,"4":4,"17":0,"7":504,"12":286,"11":1,"8":true}}},{"to":503,"msg":{"name":"1","msg":{"1":330594,"14":504,"3":1,"2":[{"19":504,"33":0,"27":0,"35":false,"25":0,"24":true,"28":38,"29":-1,"20":2,"26":0,"22":false,"23":false},{"19":506,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":3,"26":0,"22":false,"23":false},{"19":501,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":1,"26":0,"22":false,"23":true},{"19":502,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":5,"26":0,"22":false,"23":false},{"19":503,"33":0,"27":0,"35":false,"25":0,"24":true,"28":31,"29":-1,"20":4,"26":0,"22":false,"23":false}],"5":0,"18":1,"34":[524,780,528,784,532,788,536,792,540,796,544,800,292,548,804,296,552,808,300,556,812,301,304,557,560,816,308,564,820,516,772],"6":{},"9":1513089820,"15":false,"4":4,"17":0,"7":504,"12":286,"11":1,"8":true}}},{"to":504,"msg":{"name":"Game.ShowCardReply","msg":{"is_ok":true}}},{"to":0,"msg":{"name":"Game.ShowCardNotify","msg":{"show_or_not":false,"player_id":504}}},{"to":504,"msg":{"name":"3","msg":{"1":true,"4":1,"3":[265,521,777,269,525,781,273,529,785,277,533,789,281,537,793,285,541,797,289,545,801,293,549,805,261,262,263,264,517,518,519,520,773,774,775,776],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":504,"3":[297,553],"2":false,"5":506,"4":false,"7":false,"6":36,"9":0,"15":2,"12":2,"14":11,"10":true}}},{"to":506,"msg":{"name":"Game.ShowCardReply","msg":{"is_ok":true}}},{"to":0,"msg":{"name":"Game.ShowCardNotify","msg":{"show_or_not":false,"player_id":506}}},{"to":506,"msg":{"name":"3","msg":{"1":true,"4":2,"3":[266,522,270,526,274,530,278,534,282,538,286,542,290,546,294,550,298,554,302,558,305,306,561,817,258,259,514,769,313,569,825],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":506,"3":{},"2":true,"5":503,"4":false,"7":false,"6":31,"9":0,"15":3,"10":true}}},{"to":503,"msg":{"name":"Game.ShowCardReply","msg":{"is_ok":true}}},{"to":0,"msg":{"name":"Game.ShowCardNotify","msg":{"show_or_not":false,"player_id":503}}},{"to":503,"msg":{"name":"3","msg":{"1":true,"4":3,"3":[524,780,528,784,532,788,536,792,540,796,544,800,292,548,804,296,552,808,300,556,812,301,304,557,560,816,308,564,820,516,772],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":503,"3":{},"2":true,"5":502,"4":false,"7":false,"6":31,"9":0,"15":4,"10":true}}},{"to":502,"msg":{"name":"Game.ShowCardReply","msg":{"is_ok":true}}},{"to":0,"msg":{"name":"Game.ShowCardNotify","msg":{"show_or_not":false,"player_id":502}}},{"to":502,"msg":{"name":"3","msg":{"1":true,"4":4,"3":[268,779,272,527,783,276,531,787,280,535,791,284,539,795,288,543,799,547,803,551,807,555,809,811,559,813,815,563,819,260,771],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":502,"3":{},"2":true,"5":501,"4":false,"7":false,"6":31,"9":0,"15":5,"10":true}}},{"to":501,"msg":{"name":"Game.ShowCardReply","msg":{"is_ok":true}}},{"to":0,"msg":{"name":"Game.ShowCardNotify","msg":{"show_or_not":false,"player_id":501}}},{"to":501,"msg":{"name":"3","msg":{"1":true,"4":5,"3":[267,523,778,271,782,275,786,279,790,283,794,287,798,291,802,295,806,299,810,303,814,307,562,818,257,513,515,770,309,565,821],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":501,"3":{},"2":true,"5":504,"4":false,"7":true,"6":31,"9":0,"15":6,"10":false}}},{"to":504,"msg":{"name":"3","msg":{"1":true,"4":6,"3":[269,525,781,273,529,785,277,533,789,281,537,793,285,541,797,289,545,801,293,549,805,261,262,263,264,517,518,519,520,773,774,775,776],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":504,"3":[265,521,777],"2":false,"5":506,"4":false,"7":false,"6":33,"9":0,"15":7,"12":3,"14":3,"10":false}}},{"to":506,"msg":{"name":"3","msg":{"1":true,"4":7,"3":[266,522,270,526,274,530,278,534,282,538,286,542,290,546,294,550,298,554,302,558,305,306,561,817,258,259,514,769,313,569,825],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":506,"3":{},"2":true,"5":503,"4":false,"7":false,"6":31,"9":0,"15":8,"10":false}}},{"to":503,"msg":{"name":"3","msg":{"1":true,"4":8,"3":[524,780,528,784,532,788,536,792,540,796,544,800,292,548,804,296,552,808,300,556,812,301,304,557,560,816,308,564,820,516,772],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":503,"3":{},"2":true,"5":502,"4":false,"7":false,"6":31,"9":0,"15":9,"10":false}}},{"to":502,"msg":{"name":"3","msg":{"1":true,"4":9,"3":[268,779,272,527,783,276,531,787,280,535,791,284,539,795,288,543,799,547,803,551,807,555,809,811,559,813,815,563,819,260,771],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":502,"3":{},"2":true,"5":501,"4":false,"7":false,"6":31,"9":0,"15":10,"10":false}}},{"to":501,"msg":{"name":"3","msg":{"1":true,"4":10,"3":[267,523,778,271,782,275,786,279,790,283,794,287,798,291,802,295,806,299,810,303,814,307,562,818,257,513,515,770,309,565,821],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":501,"3":{},"2":true,"5":504,"4":false,"7":true,"6":31,"9":0,"15":11,"10":false}}},{"to":504,"msg":{"name":"3","msg":{"1":true,"4":11,"3":[261,262,263,264,517,518,519,520,773,774,775,776],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":504,"3":[269,525,781,273,529,785,277,533,789,281,537,793,285,541,797,289,545,801,293,549,805],"2":false,"5":506,"4":false,"7":false,"6":12,"9":0,"15":12,"12":11,"14":10,"10":false}}},{"to":506,"msg":{"name":"3","msg":{"1":true,"4":12,"3":[266,522,270,526,274,530,278,534,282,538,286,542,290,546,294,550,298,554,302,558,305,306,561,817,258,259,514,769,313,569,825],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":506,"3":{},"2":true,"5":503,"4":false,"7":false,"6":31,"9":0,"15":13,"10":false}}},{"to":503,"msg":{"name":"3","msg":{"1":true,"4":13,"3":[524,780,528,784,532,788,536,792,540,796,544,800,292,548,804,296,552,808,300,556,812,301,304,557,560,816,308,564,820,516,772],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":503,"3":{},"2":true,"5":502,"4":false,"7":false,"6":31,"9":0,"15":14,"10":false}}},{"to":502,"msg":{"name":"3","msg":{"1":true,"4":14,"3":[268,779,272,527,783,276,531,787,280,535,791,284,539,795,288,543,799,547,803,551,807,555,809,811,559,813,815,563,819,260,771],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":502,"3":{},"2":true,"5":501,"4":false,"7":false,"6":31,"9":0,"15":15,"10":false}}},{"to":501,"msg":{"name":"3","msg":{"1":true,"4":15,"3":[267,523,778,271,782,275,786,279,790,283,794,287,798,291,802,295,806,299,810,303,814,307,562,818,257,513,515,770,309,565,821],"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":501,"3":{},"2":true,"5":504,"4":false,"7":true,"6":31,"9":0,"15":16,"10":false}}},{"to":504,"msg":{"name":"3","msg":{"1":true,"4":16,"3":{},"2":""}}},{"to":0,"msg":{"name":"2","msg":{"1":504,"3":[261,262,263,264,517,518,519,520,773,774,775,776],"2":false,"5":0,"4":false,"7":false,"6":0,"9":10,"15":17,"12":4,"14":916}}},{"to":0,"msg":{"name":"4","msg":{"1":[{"12":0,"13":0,"19":1,"18":{},"11":82,"14":82,"9":504,"15":10,"16":76,"23":1,"20":1,"21":0,"22":0,"10":0},{"12":0,"13":0,"19":1,"18":[266,522,270,526,274,530,278,534,282,538,286,542,290,546,294,550,298,554,302,558,305,306,561,817,258,259,514,769,313,569,825],"11":-8,"14":-8,"9":506,"15":1,"16":-14,"23":2,"20":0,"21":1,"22":0,"10":31},{"12":0,"13":0,"19":1,"18":[267,523,778,271,782,275,786,279,790,283,794,287,798,291,802,295,806,299,810,303,814,307,562,818,257,513,515,770,309,565,821],"11":-18,"14":-18,"9":501,"15":1,"16":-14,"23":3,"20":0,"21":0,"22":1,"10":31},{"12":0,"13":0,"19":0,"18":[268,779,272,527,783,276,531,787,280,535,791,284,539,795,288,543,799,547,803,551,807,555,809,811,559,813,815,563,819,260,771],"11":-28,"14":-28,"9":502,"15":0,"16":-24,"23":3,"20":0,"21":0,"22":1,"10":31},{"12":0,"13":0,"19":0,"18":[524,780,528,784,532,788,536,792,540,796,544,800,292,548,804,296,552,808,300,556,812,301,304,557,560,816,308,564,820,516,772],"11":-28,"14":-28,"9":503,"15":0,"16":-24,"23":3,"20":0,"21":0,"22":1,"10":31}],"8":true,"3":false,"2":4,"5":1513089844,"4":1513089820,"7":1}}}]'
	--local record_table = ModuleCache.Json.decode(json)
	local record_table = videoData

	local videoDataTable = {};
	for i = 1,#record_table do
		table.insert(videoDataTable, {to=record_table[i].to, msg=CardCommon.ProtoDecode(record_table[i].msg)})
	end

	local ruleTable = self:getRuleTable(videoDataTable)
	if(ruleTable)then
		CardCommon.enableSequentialSingle = ruleTable.enableSequentialSingle
		CardCommon.enableBondCardScore = ruleTable.enableBondCardScore
	end

	local list, seatInfoList, seatDataTable, firstViewPlayerId, firstViewSeatIndex, roomInfo = self:parseMsgQueue(videoDataTable)
	self.roomInfo = {
		roomNum = roomInfo.room_id or 0,
		curRoundNum = roomInfo.game_loop_cnt or 0,
		totalRoundCount = roomInfo.game_total_cnt or 0,
		isRoundStarted = true,
		servant_card = roomInfo.servant_card,
	}
	self.view:resetSeatHolderArray(#seatInfoList)
	self.view:setRoomInfo(self.roomInfo)
	self.view:showServantCards(true, roomInfo.servant_card)
	self.firstViewPlayerId = firstViewPlayerId
	self.firstViewSeatIndex = firstViewSeatIndex
	self.seatInfoList = seatInfoList
	self.seatDataTable = seatDataTable
	self.videoDataList = list
	for k,v in pairs(seatInfoList) do
		self:refreshSeatAll(v, true)
	end
	
end

function DaiGouTuiTableVideoModule:getRuleTable(msgList)
	local ruleTable
	for i, v in pairs(msgList) do
		if(v.msg.name == 'Room.PlayRule')then
			ruleTable = v.msg.msg
			break
		end
	end
	return ruleTable
end

function DaiGouTuiTableVideoModule:on_step(step, back)
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
			seatInfo.localSeatIndex = self:getLocalIndexFromRemoteSeatIndex(seatInfo.seatIndex, self:getFirstViewSeatIndex(), 5)
			if(gameData.cur_player_id)then
				self:refreshSeatAll(seatInfo, gameData.cur_player_id ~= seatInfo.playerId or back, gameData)
			else
				self:refreshSeatAll(seatInfo, false or back, gameData)
			end
		end
	end

end

function DaiGouTuiTableVideoModule:addCode2List(code, list)
	table.insert( list, code)
	self:sortCodeList(list)
end

function DaiGouTuiTableVideoModule:removeCodeFromList(code, list)
	for i=1,#list do
		if(code == list[i])then
			table.remove( list, i)
			return
		end
	end
end

function DaiGouTuiTableVideoModule:removeCodeListFromList(codeList, list)
	for i,v in ipairs(codeList) do
		self:removeCodeFromList(v, list)
	end
end


function DaiGouTuiTableVideoModule:deep_clone(table)
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


function DaiGouTuiTableVideoModule:sortFun(name1, color1, name2, color2)
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

function DaiGouTuiTableVideoModule:sortCodeList(list)
    table.sort( list, function(code1, code2) 
        local card1 = CardCommon.ResolveCardIdx(code1)
        local card2 = CardCommon.ResolveCardIdx(code2)
        local result = self:sortFun(card1.name, card1.color, card2.name, card2.color)
        return result < 0
    end)
end

function DaiGouTuiTableVideoModule:getFirstViewSeatIndex()
	return self.seatDataTable[self.firstViewPlayerId].seatIndex, self.seatDataTable[self.firstViewPlayerId].new_seatIndex
end

function DaiGouTuiTableVideoModule:changeSeatsPos(firstViewPlayerId)
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

function DaiGouTuiTableVideoModule:parseMsgQueue(msgList)
	local list = {}
	local lastGameData = {}
	local gameData = {}
	local seatInfoList = {}
	local seatInfoTable
	gameData.roomInfo = {}
	gameData.seatInfoList = {}
	gameData.playerId_seatInfo_table = {}
	local hasFinishFirstInitGameData = false
	local firstViewSeatIndex
	local firstViewPlayerId
	local isAllSeatHasCards = function()
		local count = 0
		for i, v in pairs(gameData.playerId_seatInfo_table) do
			if(not v.cards or #v.cards == 0)then
				return false
			end
			count = count + 1
		end
		return count == 5
	end

	local calcSeatInfoList = function()
		seatInfoTable = lastGameData.playerId_seatInfo_table
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

	local parseGameInfoMsg = function(msgData)
		if(isAllSeatHasCards())then
			return
		end
		local msg = msgData.msg.msg
		local roomInfo = gameData.roomInfo
		local seatInfo = gameData.playerId_seatInfo_table[msgData.to]
		if(not seatInfo)then
			seatInfo = {}
			seatInfo.playerId = msgData.to
			gameData.playerId_seatInfo_table[msgData.to] = seatInfo
		end
		roomInfo.room_id = msg.room_id
		roomInfo.roomNum = roomInfo.room_id
		roomInfo.curRoundNum = msg.game_loop_cnt
		roomInfo.totalRoundCount = msg.game_total_cnt
		roomInfo.lord_player_id = msg.lord_player_id
		roomInfo.game_total_cnt = msg.game_total_cnt
		roomInfo.next_player_id = msg.next_player_id
		roomInfo.can_call_servant = msg.can_call_servant
		roomInfo.game_loop_cnt = msg.game_loop_cnt
		roomInfo.servant_card = msg.servant_card
		roomInfo.desk_player_id = msg.desk_player_id
		roomInfo.time = msg.time
		roomInfo.isRoundStarted = true
		seatInfo.cards = {}
		for i = 1, #msg.cards do
			table.insert(seatInfo.cards, msg.cards[i])
		end

		for i = 1, #msg.players do
			local player = msg.players[i]
			local tmpSeatInfo = gameData.playerId_seatInfo_table[player.player_id]
			if(not tmpSeatInfo)then
				tmpSeatInfo = {}
				gameData.playerId_seatInfo_table[player.player_id] = tmpSeatInfo
			end
			tmpSeatInfo.playerId = player.player_id
			tmpSeatInfo.seatIndex = player.player_pos
			if(tmpSeatInfo.playerId == tonumber(self.modelData.roleData.userID))then
				firstViewPlayerId = tmpSeatInfo.playerId
				firstViewSeatIndex = tmpSeatInfo.seatIndex
			end
			tmpSeatInfo.show_card = player.show_card
			tmpSeatInfo.is_owner = player.is_owner
			tmpSeatInfo.score = player.score
			tmpSeatInfo.is_offline = false
			tmpSeatInfo.multiple = player.multiple
			tmpSeatInfo.round_discard_cnt = player.round_discard_cnt
			tmpSeatInfo.lost_cnt = player.lost_cnt
			tmpSeatInfo.isReady = true
			tmpSeatInfo.isLord = msg.lord_player_id == tmpSeatInfo.playerId
			if(tmpSeatInfo == seatInfo)then
				tmpSeatInfo.rest_card_cnt = player.rest_card_cnt
			end
		end

		local handCardSet = CardSet.new(seatInfo.cards, #seatInfo.cards)
		handCardSet:SortByPattern(1, roomInfo.servant_card, seatInfo.isLord, false)
		if(handCardSet:count(roomInfo.servant_card) == 1)then
			seatInfo.isServant = true and (not seatInfo.isLord)
		else
			seatInfo.isServant = false
		end
		seatInfo.cards = handCardSet.cards
		if(isAllSeatHasCards())then
			lastGameData = self:deep_clone(gameData)
			table.insert(list, lastGameData)
			if(not hasFinishFirstInitGameData)then
				hasFinishFirstInitGameData = true
				calcSeatInfoList()
			end
		end
	end

	local parseDiscardReplyMsg = function(msgData, discard_notify_table)
		gameData.cur_player_id = msgData.to
		local roomInfo = gameData.roomInfo
		local msg = msgData.msg.msg
		local seatInfo = gameData.playerId_seatInfo_table[msgData.to]
		if(not msg.is_ok)then
			seatInfo.discards = msg.desc
			lastGameData = self:deep_clone(gameData)
			table.insert(list, lastGameData)
			return
		end
		local notify = discard_notify_table[msg.discard_serno + 1].msg.msg
		if(notify.is_passed)then
			seatInfo.discards = 'pass'
		else
			seatInfo.discards = notify.cards
			local cardPattern = CardPattern.new(seatInfo.discards, roomInfo.servant_card, seatInfo.isLord, false)
			cardPattern.type = notify.type
			cardPattern.value = notify.value
			seatInfo.discard_pattern = cardPattern
		end
		seatInfo.cards = msg.cards
		local handCardSet = CardSet.new(seatInfo.cards, #seatInfo.cards)
		handCardSet:SortByPattern(1, roomInfo.servant_card, seatInfo.isLord, false)
		seatInfo.cards = handCardSet.cards
		roomInfo.next_player_id = notify.next_player_id
		roomInfo.is_first_pattern = notify.is_first_pattern
		roomInfo.is_1v4 = notify.is_1v4
		seatInfo.multiple = notify.multiple

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

	local parseShowCardNotify = function(msgData)
		local msg = msgData.msg.msg
		local seatInfo = gameData.playerId_seatInfo_table[msg.player_id]
		seatInfo.show_card = msg.show_or_not
	end

	local parseCallServantNotifyMsg = function(msgData)
		local servant_card = msgData.msg.msg.servant_card
		for i, v in pairs(list) do
			v.roomInfo.servant_card = servant_card
			for j, val in pairs(gameData.playerId_seatInfo_table) do
				local seatInfo = val
				local roomInfo = gameData.roomInfo
				local handCardSet = CardSet.new(seatInfo.cards, #seatInfo.cards)
				handCardSet:SortByPattern(1, roomInfo.servant_card, seatInfo.isLord, false)
				if(handCardSet:count(roomInfo.servant_card) == 1)then
					seatInfo.isServant = true and (not seatInfo.isLord)
				else
					seatInfo.isServant = false
				end
				seatInfo.cards = handCardSet.cards
			end
		end
		gameData.roomInfo.servant_card = servant_card
		for i, v in pairs(gameData.playerId_seatInfo_table) do
			local seatInfo = v
			local roomInfo = gameData.roomInfo
			local handCardSet = CardSet.new(seatInfo.cards, #seatInfo.cards)
			handCardSet:SortByPattern(1, roomInfo.servant_card, seatInfo.isLord, false)
			if(handCardSet:count(roomInfo.servant_card) == 1)then
				seatInfo.isServant = true and (not seatInfo.isLord)
			else
				seatInfo.isServant = false
			end
			seatInfo.cards = handCardSet.cards
		end
	end

	local parseCurrentGameAccountMsg = function(msgData)
		local gameResultData = {players={}}
		local msg = msgData.msg.msg
		local is_summary_account = msg.is_summary_account
		if(not is_summary_account)then
			for i=1,#msg.players do
				local tmpPlayer = msg.players[i]
				local seatInfo = gameData.playerId_seatInfo_table[tmpPlayer.player_id]
				local player = {}
				player.playerId = tmpPlayer.player_id
				player.playerInfo = nil
				player.seatIndex = seatInfo.seatIndex

				seatInfo.score = tmpPlayer.score
				player.isShowCard = seatInfo.show_card or false
				player.isRoomCreator = seatInfo.isCreator or false
				player.bond_score = tmpPlayer.bond_score
				player.nongmin_times = tmpPlayer.farmer_cnt
				player.xipai_times = tmpPlayer.bond_pattern_cnt
				player.dizhu_times = tmpPlayer.lord_cnt
				player.goutui_times = tmpPlayer.servant_cnt

				player.totalScore = tmpPlayer.score or 0
				player.score = tmpPlayer.current_score or 0
				player.cards = {}


				if(tmpPlayer.identity == 1)then
					player.isLord = true
				elseif(tmpPlayer.identity == 2)then
					player.isServant = true
				elseif(tmpPlayer.identity == 3)then
					player.isFarmer = true
				end

				gameResultData.players[i] = player
			end
			table.sort(gameResultData.players, function(p1,p2)
				return p1.seatIndex < p2.seatIndex
			end)
			gameResultData.roomInfo = gameData.roomInfo
			gameResultData.base_score = msg.base_score or 0
			gameResultData.multiple = msg.show_card_multiple
			gameResultData.startTime = msg.startTime
			gameResultData.endTime = msg.endTime
			gameResultData.free_sponsor = msg.free_sponsor	--申请解散者id
			gameResultData.myPlayerId = 0
			gameResultData.lordid = msg.lordid
			gameResultData.roomDesc = '经典玩法'
			gameResultData.hide_shareBtn = true
			gameResultData.hide_restartBtn = true
			gameData.gameResultData = gameResultData
			lastGameData = self:deep_clone(gameData)
			table.insert(list, lastGameData)
		end
	end

	local msg_list = {}
	local discard_notify_table = {}
	local settle_notify_list = {}
	for i = 1, #msgList do
		local msgData = msgList[i]
		if(msgData.msg.name == 'Game.GameInfo')then
			table.insert(msg_list, msgData)
		elseif(msgData.msg.name == 'Game.DiscardNotify')then
			discard_notify_table[msgData.msg.msg.discard_serno] = msgData
		elseif(msgData.msg.name == 'Game.DiscardReply')then
			table.insert(msg_list, msgData)
		elseif(msgData.msg.name == 'Game.CurrentGameAccount')then
			table.insert(settle_notify_list, msgData)
		elseif(msgData.msg.name == 'Game.CallServantNotify')then
			table.insert(msg_list, msgData)
		elseif(msgData.msg.name == 'Game.ShowCardNotify')then
			table.insert(msg_list, msgData)
		end
	end

	for i = 1, #msg_list do
		local msgData = msg_list[i]
		if(msgData.msg.name == 'Game.GameInfo')then
			parseGameInfoMsg(msgData)
		elseif(msgData.msg.name == 'Game.ShowCardNotify')then
			parseShowCardNotify(msgData, discard_notify_table)
		elseif(msgData.msg.name == 'Game.DiscardReply')then
			parseDiscardReplyMsg(msgData, discard_notify_table)
		elseif(msgData.msg.name == 'Game.CallServantNotify')then
			parseCallServantNotifyMsg(msgData)
		end
	end

	for i = 1, #settle_notify_list do
		local msgData = settle_notify_list[i]
		parseCurrentGameAccountMsg(msgData)
	end

	return list, seatInfoList, seatInfoTable, firstViewPlayerId, firstViewSeatIndex, gameData.roomInfo
end


function DaiGouTuiTableVideoModule:refreshSeatAll(seatInfo, withoutAnim, gameData)
	seatInfo.roomInfo = self.roomInfo
	self.view:refreshSeatPlayerInfo(seatInfo)
	self.view:refreshSeatState(seatInfo)
	self.view:showSeatLandLordIcon(seatInfo.localSeatIndex, seatInfo.isLord or false)
	self.view:showSeatServantIcon(seatInfo.localSeatIndex, seatInfo.isServant or false)
	local discards = seatInfo.discards
	local discard_pattern = seatInfo.discard_pattern

	self.view:showSeatHandPokers(seatInfo.localSeatIndex, true)
	self.view:refreshSeatHandPokers(seatInfo.localSeatIndex, seatInfo.cards or {}, self.roomInfo.servant_card)
	self.view:playSeatPassAnim(seatInfo.localSeatIndex, discards == 'pass' or false, withoutAnim)
	if(discards == 'pass')then
		if(not withoutAnim)then
			self:playPassSound(seatInfo)
		end
	end
	if(type(discards) == 'table' and (discards ~= 'pass'))then
		self.view:playDispatchPokers(seatInfo.localSeatIndex, true, discards, self.roomInfo.servant_card, withoutAnim)
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
function DaiGouTuiTableVideoModule:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		return localIndex - seatCount
	else
		return localIndex
	end
end

function DaiGouTuiTableVideoModule:isPlayingAnim()
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

function DaiGouTuiTableVideoModule:on_click(obj, arg)
	if(self:isPlayingAnim())then
		return
	end
	if(obj.name == "Image") then
		self:on_click_player_image(obj, arg)
	end
end


function DaiGouTuiTableVideoModule:on_click_player_image(obj, arg)
	local seatInfo = self:getSeatInfoByHeadImageObj(obj)
	if(not seatInfo)then
		print_debug("seatInfo is not exist")
		return
	end
	self:changeSeatsPos(seatInfo.playerId)
end

function DaiGouTuiTableVideoModule:getSeatInfoByHeadImageObj(obj)
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
function DaiGouTuiTableVideoModule:playCardPatternSoundAndEffect(seatInfo, cardPattern, deskPattern)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
		self.tableSound:playPokerTypeSound(false, cardPattern, deskPattern)
	else
		self.tableSound:playPokerTypeSound(true, cardPattern, deskPattern)
	end
	self.tableSound:playPokerTypeEffectSound(cardPattern)
	local type = cardPattern.type
	local disp_type = cardPattern.disp_type
	if(type == CardCommon.type_bomb)then	--炸弹
		self.view:playZhaDanEffect(seatInfo)
	elseif(type == CardCommon.type_triple_p2)then	--3带2
		self.view:playSanDaiErEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_double)then	--连对
		self.view:playLianDuiEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_triple_p2)then --蝴蝶
		self.view:playHuDieEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_single)then --顺子
		self.view:playShunZiEffect(seatInfo)
	elseif(type == CardCommon.type_sequence_triple)then	--三顺
		self.view:playSanShunEffect(seatInfo)
	end


end

--播放不出音效
function DaiGouTuiTableVideoModule:playPassSound(seatInfo)
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then	
		self.tableSound:playPassSound(false)
	else
		self.tableSound:playPassSound(true)
	end
end

function DaiGouTuiTableVideoModule:on_destroy()
	self.oneGameResultModule = nil
	ModuleCache.ModuleManager.destroy_module(self.packageName, "onegameresult")
end


return DaiGouTuiTableVideoModule 