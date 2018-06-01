--- 三公战绩详情
--- Created by 袁海洲
--- DateTime: 2017/12/7 10:58
---

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("sangong.RoomDetailModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local cjson = require("cjson");



function RoomDetailModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "roomDetail_view", "roomDetail_model", ...)

    --self.roomDetailView:initLoopScrollViewList({roundList={}})
end


function RoomDetailModule:on_show(roomInfo)
    print("@@@@roomInfo")
    print_table(roomInfo)
    self.roomInfo = roomInfo
    self.view:initRoomInfo(roomInfo)
    self.view:initLoopScrollViewList(nil)
    self.isReverseOrder = roomInfo.isReverseOrder
    self.isUseCache = roomInfo.isUseCache
    self:getRoomList(roomInfo)
end


function RoomDetailModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.buttonClose.gameObject then
        ModuleCache.ModuleManager.hide_module("sangong", "roomdetail")
        return
    end
end

function RoomDetailModule:getRoomList(roomInfo)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/roundlist/v2?",
        showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
            roomid = roomInfo.id
        }
    }
    if self.isUseCache and self.cache then
        self.view:initLoopScrollViewList(self.cache.roundList,self.cache.disUserId)
    end
    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        if(retData.ret and retData.ret == 0)then
            local roomData = self:parseRoundList(retData.data, roomInfo.playRule)
            local roundList = {}
            if self.isReverseOrder then
                for i=#roomData,1,-1 do
                    table.insert(roundList,roomData[i])
                end
            else
                roundList = roomData
            end
            self.view:initLoopScrollViewList(roundList,retData.data.disUserId)
            if self.isUseCache then
                self.cache = {}
                self.cache.roundList = roundList
                self.cache.disUserId = retData.data.disUserId
            end
        else
            print(wwwData.www.text)
        end

    end, function(errorData)
        print(errorData.error)
    end)
end

function RoomDetailModule:getDisUserName(data)
    local players = data.players
    for i=1,#players do
        if data.disUserId == players[i].userId then
            return players[i].playerName
        end
    end
end

function RoomDetailModule:sortPlayer(data)
    local newPlayerList = {}
    local index = 2
    for i, v in ipairs(data.players) do
        if (tostring(self.modelData.roleData.userID) == tostring(v.userId)) then
            newPlayerList[1] = v
        else
            newPlayerList[index] = v
            index = index + 1
        end
    end
    return newPlayerList
end

function RoomDetailModule:parseRoundList(data)

    -- print_table(data)
    self.recordInfo = {}
    local sortPlayers = self:sortPlayer(data)

    local roundList = {}
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
        roundObject.result = self:getRecord(round.recordId)
        roundList[roundCount] = roundObject;
    end
    -- print_table(roundList)
    return roundList
end

-- 处理牌局详细信息
function RoomDetailModule:getRecord(record)
    local recordData = {}
    local jsonData = cjson.decode(record)
    local players = jsonData.players
    for i=1,#players do
        local playerRecod = players[i]
        local playerId = playerRecod.player_id
        recordData[playerId] = {}
        recordData[playerId].cards = playerRecod.cards
        recordData[playerId].banker = jsonData.banker ==  playerId and "1" or "0"
        recordData[playerId].cardType = playerRecod.card_type
        recordData[playerId].time = ""
    end
    return recordData
end

function RoomDetailModule:getPlayerIndex( userId,playerList )
    for i, v in ipairs(playerList) do
        if (tostring(userId) == tostring(v.userId)) then
            return i
        end
    end
end

function RoomDetailModule:getPlayerInfoBySeatId(seatId, playerList)
    for i,v in ipairs(playerList) do
        if(seatId == v.seatId)then
            return v
        end
    end
end

function RoomDetailModule:getPlayerInfoByName(name, playerList)
    for i,v in ipairs(playerList) do
        if(name == v.playerName)then
            return v
        end
    end
end


return RoomDetailModule