-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("BaiBaZhang.RoomDetailModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function RoomDetailModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "roomDetail_view", "roomDetail_model", ...)

    --  self.roomDetailView:initLoopScrollViewList( { roundList = { } })
end


function RoomDetailModule:on_show(roomInfo)
    self.creatorId = roomInfo.creatorId
    self.roomDetailView:initRoomInfo(roomInfo)
    self:getRoomList(roomInfo)
end


function RoomDetailModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    print(obj.gameObject.name);
    if obj == self.roomDetailView.buttonClose.gameObject then
        ModuleCache.ModuleManager.hide_module("baibazhang", "roomdetail")
        return
        --    elseif obj == self.roomDetailView.buttonBack.gameObject then
        --        ModuleCache.ModuleManager.hide_module("biji", "roomdetail")
        --        print(2222);
        --        return
    elseif obj.name == "shareBtn" then
        local loopBaseNode = ModuleCache.ComponentUtil.GetComponent(obj.transform.parent.parent.gameObject, "LoopBaseNode")
        local data = loopBaseNode.data
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("分享录像 id = " .. data.videoId)
    elseif obj.name == "playVideoBtn" then
        local loopBaseNode = ModuleCache.ComponentUtil.GetComponent(obj.transform.parent.parent.gameObject, "LoopBaseNode")
        local data = loopBaseNode.data
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放录像 id = " .. data.videoId)
    end
end

function RoomDetailModule:getRoomList(roomInfo)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/roundlist/v2?",
        showModuleNetprompt = true,
        params =
        {
            uid = self.modelData.roleData.userID,
            roomid = roomInfo.id
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        if (retData.ret and retData.ret == 0) then
            local roundList = self:parseRoundList(retData.data)

            print_table(roundList);
            self.roomDetailView:initLoopScrollViewList(roundList,self.creatorId)
        else
            print(wwwData.www.text)
        end

    end , function(errorData)
        print(errorData.error)
    end )
end

function RoomDetailModule:sortPlayer(data)
    local newPlayerList = {}
--    local index = 2
--    for i, v in ipairs(data.players) do
--        if (self.creatorId == v.userId) then
--            newPlayerList[1] = v
--        else
--            newPlayerList[index] = v
--            index = index + 1
--        end
--    end


     -- 自己排在最前面
    for i = 1, #data.players do
        if data.players[i].userId == tonumber(self.modelData.roleData.userID) then
            local temp = data.players[1]
            data.players[1] = data.players[i]
            data.players[i] = temp
        end
    end
    return data.players;
end

function RoomDetailModule:parseRoundList(data)
    self.recordInfo = {};
    local sortPlayers = self:sortPlayer(data)
    -- 所有局列表
    local roundList = { };
    for roundCount, round in ipairs(data.list) do

        -- 每局对象列表
        local roundObject = { };
        -- 玩家数据列表
        local playerList = { };
        for key, scoreObject in ipairs(round.scores) do
            -- print_table(data.players)
            -- 找出座位id相同的玩家名字
            for key1, player in ipairs(data.players) do
                local playerObject = nil;
                if scoreObject.seatId == player.seatId then
                    playerObject = {}
                    -- 玩家名字
                    playerObject.playerName = player.playerName;
                    -- 玩家分数
                    playerObject.score = scoreObject.score;
                    playerObject.userId = player.userId
                    playerObject.showIndex = self:getPlayerIndex(player.userId,sortPlayers)
                    playerList[key] = playerObject;
                end
            end
        end
        -- 玩家数据列表
        roundObject.player = playerList;
        -- 总局数
        roundObject.roundCount = data.roundCount;
        -- 当前局数
        roundObject.roundNumber = round.roundNumber;
        roundObject.disUser = data.disUserId;
        local record = round.recordId;
        local result = self:DecodeRecord(record);
        roundObject.result = result;
        roundList[roundCount] = roundObject;
    end
    print_table(self.recordInfo);

    print_table(roundList)

    return roundList;

    -- local roomData = {}
    -- roomData.roundCount = data.roundCount

    -- local roundList = {}
    -- roomData.roundList = roundList
    -- local mySeatInfo = {}
    -- mySeatInfo.playerName = data.myName
    -- mySeatInfo.seatId = data.mySeatId	

    -- for i=1,#data.list do
    -- 	local tmp = data.list[i]
    -- 	local roundData = {}
    -- 	roundData.playRule = playRule
    -- 	roundData.playTime = tmp.playTime
    -- 	roundData.recordId = tmp.recordId
    -- 	roundData.roundNumber = tmp.roundNumber
    -- 	roundData.roundCount = data.roundCount

    -- 	local winner = self:getPlayerInfoByName(tmp.winnerName, data.players)


    -- 	local seatList = {}
    -- 	roundData.seatList = seatList
    -- 	for j=1,#tmp.scores do
    -- 		local seat = tmp.scores[j]
    -- 		local player = self:getPlayerInfoBySeatId(seat.seatId, data.players)
    -- 		seat.playerName = player.playerName
    -- 		seat.userId = player.userId
    -- 		seat.isWinner = player.userId == winner.userId
    -- 		table.insert( seatList, seat)
    -- 	end
    -- 	table.sort( seatList, function(t1,t2)
    -- 		if(t1.seatId < t2.seatId)then
    -- 			return true
    -- 		else
    -- 			return false
    -- 		end
    -- 	end)


    -- 	table.insert( roundList, roundData )
    -- end
    -- table.sort( roundList, function(t1,t2)
    -- 	if(t1.roundNumber < t2.roundNumber)then
    -- 		return true
    -- 	else
    -- 		return false
    -- 	end
    -- end)
    -- return roomData
end

function RoomDetailModule:DecodeRecord(record)
    local curString = "";
    local recordLength = string.len(record);
    local curCount = 0;
    local recordIndex = 0;
    local recordInfo = {};
    local records = {};
    for i = 1, recordLength do
        local curChar = string.sub(record, i, i);
        if(curChar == "|") then
            curCount = curCount + 1;
            if(curCount == 3) then
                recordInfo.playerId = tonumber(curString);
            elseif(curCount == 4) then
                recordInfo.firstMatchScore = tonumber(curString);
            elseif(curCount == 5) then
                recordInfo.secondMatchScore = tonumber(curString);
            elseif(curCount == 6) then
                recordInfo.thirdMatchScore = tonumber(curString);
            elseif(curCount == 7) then
                recordInfo.roundScore = tonumber(curString);
            elseif(curCount == 11) then
                recordInfo.isSurrender = tonumber(curString);
            elseif(curCount == 12) then    
                recordInfo.firstMatch = self:DecodeMatchRecord(curString);
            elseif(curCount == 13) then    
                recordInfo.secondMatch = self:DecodeMatchRecord(curString);
            elseif(curCount == 14) then    
                recordInfo.thirdMatch = self:DecodeMatchRecord(curString);
            elseif(curCount == 15) then    
                recordInfo.xipaiInfo = self:DecodeXipaiRecord(curString);
            end
            curString = "";
        else
            curString = curString..curChar;
        end
        if(curString == "BIJI" or i == recordLength) then
            if(recordIndex > 0) then
                table.insert( records, recordInfo);
                recordInfo = {};
            end
            curCount = 1;
            recordIndex = recordIndex + 1;
        end
    end
    table.insert(self.recordInfo, records);
    return records;
end

function RoomDetailModule:DecodeMatchRecord(record)
    local match = {};
    local curStrPoker = "";
    for i = 1, string.len(record) do
        local curChar = string.sub(record, i, i) ;
        if(curChar == ",") then
            local poker = self:DecordStrPoker(curStrPoker);
            table.insert( match,poker)
            curStrPoker = "";
        else
            curStrPoker = curStrPoker .. curChar;        
        end
    end
    return match;
end

function RoomDetailModule:DecodeXipaiRecord(record)
    local match = {};
    local curStrXipaiInfo = "";
    for i = 1, string.len(record) do
        local curChar = string.sub(record, i, i) ;
        if(curChar == ",") then
            local xipai,score = self:DecordXipaiAndScore(curStrXipaiInfo);
            local xipaiInfo = {};
            xipaiInfo.xipai = xipai;
            xipaiInfo.score = score;
            table.insert( match,xipaiInfo)
            curStrXipaiInfo = "";
        else
            curStrXipaiInfo = curStrXipaiInfo .. curChar;        
        end
    end
    return match;
end

function RoomDetailModule:DecordXipaiAndScore(strXipai)
    local curStrXipaiInfo = "";
    local xipai = "";
    local score = 0;
    for i = 1, string.len(strXipai) do
        local curChar = string.sub(strXipai, i, i) ;
        if(curChar == "_") then
            score = tonumber(string.sub(strXipai,i+1,-1));
            local xipaiType = tonumber(string.sub(strXipai,1,i-1));
            xipai = self:DecodeXipaiType(xipaiType);
            curStrXipaiInfo = "";
        else
            curStrXipaiInfo = curStrXipaiInfo .. curChar;        
        end
    end
    return xipai,score;
end

function RoomDetailModule:DecodeXipaiType(xipaiType)
    --1,三清;2,全黑;3,全红;4,双顺清;5,三顺清;6,双三条;7,全三条;8,四个头(1);9,四个头(2);10,连顺;11,清连顺;12,三顺子
    local strXipai = "";
    if(xipaiType == 1) then
        strXipai = "三顺"
    elseif(xipaiType == 2) then
        strXipai = "三顺鸡"
    elseif(xipaiType == 3) then
        strXipai = "三顺两鸡"
    elseif(xipaiType == 4) then
        strXipai = "三顺三鸡"
    elseif(xipaiType == 5) then
        strXipai = "八怪"
    elseif(xipaiType == 6) then
        strXipai = "四对"
    elseif(xipaiType == 7) then
        strXipai = "四条"
    elseif(xipaiType == 8) then
        strXipai = "双四条"
    elseif(xipaiType == 9) then
        strXipai = "杂龙"
    elseif(xipaiType == 10) then
        strXipai = "清龙"
    end
    return strXipai;
end

function RoomDetailModule:DecordStrPoker(strPoker)
    local number = string.sub(strPoker,1,-3);
    local color = string.sub(strPoker,-1,-1);
    local poker = {};
    poker.number = tonumber(number);
    poker.color = tonumber (color);
    return poker;
end

function RoomDetailModule:getPlayerInfoBySeatId(seatId, playerList)
    for i, v in ipairs(playerList) do
        if (seatId == v.seatId) then
            return v
        end
    end
end

function RoomDetailModule:getPlayerInfoByName(name, playerList)
    for i, v in ipairs(playerList) do
        if (name == v.playerName) then
            return v
        end
    end
end

function RoomDetailModule:getPlayerNameBySeatId(seatId,playerList)
    for i, v in ipairs(playerList) do
        if (seatId == v.seatId) then
            return v.playerName
        end
    end
end

function RoomDetailModule:getUserIdBySeatId(seatId,playerList)
    for i, v in ipairs(playerList) do
        if (seatId == v.seatId) then
            return v.userId
        end
    end
end

function RoomDetailModule:getPlayerIndex( userId,playerList )
    for i, v in ipairs(playerList) do
        if (userId == v.userId) then
            return i
        end
    end
end


return RoomDetailModule



