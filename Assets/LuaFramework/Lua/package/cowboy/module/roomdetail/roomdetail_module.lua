-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("CowBoy.RoomDetailModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function RoomDetailModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "roomDetail_view", "roomDetail_model", ...)

	--self.roomDetailView:initLoopScrollViewList({roundList={}})
end


function RoomDetailModule:on_show(roomInfo)
	self.roomInfo = roomInfo
	self.roomDetailView:initRoomInfo(roomInfo)
	self.roomDetailView:initLoopScrollViewList(nil)
	self:getRoomList(roomInfo)	
end


function RoomDetailModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.roomDetailView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("cowboy", "roomdetail")
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
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		if(retData.ret and retData.ret == 0)then
			local roomData = self:parseRoundList(retData.data, roomInfo.playRule)			
			self.roomDetailView:initLoopScrollViewList(roomData)
		else
			print(wwwData.www.text)
		end
		
	end, function(errorData)
		print(errorData.error)
	end)
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
		roundObject.disUserId = data.disUserId
        roundObject.result = self:getRecord(round.recordId)
        roundList[roundCount] = roundObject;
	end
	-- print_table(roundList)
	return roundList
end

-- 处理牌局详细信息
-- "recordId" = "1|789|-10|cow0|C_3,H_7,D_A,H_5,C_5,|5|2017-08-16 10:40:06^0|328|10|cow9|S-9,S-A,S-7,C-2,D-10|1|2017-08-16 10:40:06^"  服务端发来的极速牛仔的随机坐庄数据样式
-- "recordId" = "|ZHAJINNIU|1|789|13|18|cow0|S_9,D_7,C_10,H_6,C_J,|0|2017-08-16 10:50:12^|ZHAJINNIU|0|328|18|-18|cow0|H_2,S_A,S_8,C_4,C_3,|4|2017-08-16 10:50:12^" 炸金牛样式
function RoomDetailModule:getRecord(record)
	local recordData = {}
	local playerStrList = string.split(record,"^")                            -- 将每个用户的数据字符串分割出来
	-- print_table(playerStrList)
	for i=1,#playerStrList do
		local playerRecod = playerStrList[i]
		if(playerRecod ~= "") then
			local infos = string.split(playerRecod,"|")                        -- 将单独的用户牌局信息分割出来
			-- print_table(infos)
			if(infos[2] == "ZHAJINNIU") then
				-- 牌局是炸金牛
				local playerId = infos[4]
				recordData[playerId] = {}
				recordData[playerId].cards = string.split(infos[8],",")     -- 将牌型信息分割出来
				recordData[playerId].banker = infos[3]                      -- 坐庄信息 1庄 0否
				recordData[playerId].cow = infos[7]                         -- 牛信息  cow1 -> 牛1
				recordData[playerId].time = infos[10]					    -- 时间	
			else
				-- 牌局是极速牛牛
				local playerId = infos[2]
				recordData[playerId] = {}
				recordData[playerId].cards = string.split(infos[5],",")     -- 将牌型信息分割出来
				recordData[playerId].banker = infos[1]
				recordData[playerId].cow = infos[4]
				recordData[playerId].time = infos[7]
			end
		end
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



