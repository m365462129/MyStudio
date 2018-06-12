-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("TableResultModule", ModuleBase)
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

local Util = Util

function TableResultModule:initialize(...)
	ModuleBase.initialize(self, "poker_tableresult_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function TableResultModule:on_module_inited()		
end

-- 绑定module层的交互事件
function TableResultModule:on_module_event_bind()
end

-- 绑定loginModel层事件，模块内交互
function TableResultModule:on_model_event_bind()
end

function TableResultModule:on_show(data)

	--data = {
	--	curAccountData = {
	--		players = {}
	--	},
	--	roomNum = 100000,
	--	roomDesc = "hello",
	--	curRoundNum = 1,
	--	totalRoundCount = 10,
	--}
	--for i=1,4 do
	--	local player = {}
	--	player.player_id = 110 + i
	--	player.isRoomCreator = i == 1
	--	player.bomb_cnt = i
	--	player.score = i
	--	player.win_cnt = i * 4
	--	player.lost_cnt = i
	--	player.isRoomCreator = player.player_id == 111
	--	player.isSelf = player.player_id == 111
	--	player.isDissolver = i == 1
	--	table.insert(data.curAccountData.players, player)
	--end
	


	self.view:refreshRoomInfo(data.roomNum, data.roomDesc, os.time(), data.curRoundNum, data.totalRoundCount)
	self.curPackageName = data.packageName or "henanmj"
	local playerlist = data.curAccountData.players
	local resultList = {}
	for i=1,#playerlist do
		local result = {}
		result.player_id = playerlist[i].player_id
		result.bomb_cnt = playerlist[i].bomb_cnt
		result.score = playerlist[i].score
		result.win_cnt = playerlist[i].win_cnt
		result.lost_cnt = playerlist[i].lost_cnt
		result.isRoomCreator = playerlist[i].isRoomCreator
		result.isDissolver = playerlist[i].isDissolver
		result.isSelf = playerlist[i].isSelf
		table.insert(resultList,result)
	end
	--print(ModuleCache.Json.encode(resultList))

	local count = #resultList
	if(count ~= 0)then
		ModuleCache.ModuleManager.show_public_module("netprompt")
	end

	local finishCount = 0
	local maxScore = 0
	for i=1,count do
		if(maxScore < resultList[i].score)then
			maxScore = resultList[i].score
		end

		self:getPlayerInfo(resultList[i], function(err)
			finishCount = finishCount + 1			
			if(finishCount == count)then
				ModuleCache.ModuleManager.hide_public_module("netprompt")
				self.view:init_view(resultList, maxScore)
			end
		end)
	end
end

function TableResultModule:getPlayerInfo(data, callback)
	print("data.player_id="..tostring(data.player_id))
	self:get_userinfo(data.player_id, function(err, playerData)
		if(err)then
			self:getPlayerInfo(data, callback)
			return
		end
		print("finish get userInfo")
		if(err)then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(err)	
			ModuleCache.ModuleManager.hide_public_module("netprompt")
			return
		end
		local player = {}
		player.uid = playerData.userId
		player.nickname = playerData.nickname
		player.headImg = playerData.headImg
		data.player = player
		callback(err)
	end)
end


function TableResultModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonBack.gameObject then
		--self.modelData.curTableData.roomInfo = nil		
		ModuleCache.ModuleManager.destroy_package(self.curPackageName)
		ModuleCache.ModuleManager.destroy_package("henanmj")
		ModuleCache.ModuleManager.destroy_module("public", "poker_tableresult")
		ModuleCache.ModuleManager.show_module("henanmj", "hall")
		return
	elseif obj == self.view.buttonShare.gameObject then
		ModuleCache.ShareManager().shareImage(false)
		return
	end
end


return TableResultModule