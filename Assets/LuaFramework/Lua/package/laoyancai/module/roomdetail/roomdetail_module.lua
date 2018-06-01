-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("BullFight.RoomDetailModule", ModuleBase)

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
        ModuleCache.ModuleManager.hide_module("laoyancai", "roomdetail")
        return
        --    elseif obj == self.roomDetailView.buttonBack.gameObject then
        --        ModuleCache.ModuleManager.hide_module("biji", "roomdetail")
        --        print(2222);
        --        return
    elseif obj.name == "shareBtn" then
        local loopBaseNode = ModuleCache.ComponentManager.GetComponent(obj.transform.parent.parent.gameObject, "LoopBaseNode")
        local data = loopBaseNode.data
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("分享录像 id = " .. data.videoId)
    elseif obj.name == "playVideoBtn" then
        local loopBaseNode = ModuleCache.ComponentManager.GetComponent(obj.transform.parent.parent.gameObject, "LoopBaseNode")
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
    print("##############################")
    print_table(data.players)
    print_table(data)
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
                    playerObject.headImg = player.headImg
                    --playerObject.headImg = player.
                    playerList[key] = playerObject;
                end
            end
        end
        -- 玩家数据列表
        roundObject.player = playerList;
        -- 总局数
        roundObject.roundCount = data.roundCount;
        roundObject.disUser = data.disUserId;
        -- 当前局数
        roundObject.roundNumber = round.roundNumber;
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
    local recordTable = ModuleCache.Json.decode(record)
    local records = recordTable["DHYNQP_LAOYANCAI_LAOYANCAI"].info;
    return records;
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



