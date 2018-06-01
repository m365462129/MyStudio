-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("ShiSanZhang.TableResultModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function TableResultModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "tableResult_view", "tableResult_model", ...)
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

function TableResultModule:on_show(data, gameName)
	ModuleCache.net.NetClientManager.disconnect_all_client()

	self.shisanzhang_gametype = self.modelData.curTableData.shisanzhang_gametype
	gameName = gameName or 'biji'
	local path = "package.shisanzhang.module.tableresult.game.tableresult_"
	self.panel = require(path..string.lower(gameName).."_panel"):new(self)

	print_table(data)

	local resultList = data.resultList
	local roomInfo = data.roomInfo
	local name = data.gameName;
	local dissolverId = data.dissolverId;
	print(name);
	--[[
	roomInfo = {
		roomNum = 121223,
		timestamp = 0,
	}
	resultList= {}
	for i=1,6 do
		local result = {}
		result.totalScore = i * 5
		result.isCreator = i == 1
		result.xipaiCount = i * 3
		result.userId = self.modelData.roleData.userID
		result.tongguanCount = i * 4
		result.paiWinCount  = {i, i * 2, i * 3}						
		
		table.insert(resultList, result)
	end
	
	--]]
	--print(ModuleCache.Json.encode(resultList))

	

	
	self.tableResultView:refreshRoomInfo(roomInfo.roomNum,name,roomInfo.curRoundNum,roomInfo.totalRoundNum,roomInfo.startTime,roomInfo.endTime)

	local finishCount = 0
	local count = #resultList
	if(count ~= 0)then
		--ModuleCache.ModuleManager.show_public_module("netprompt")
	end

	local maxScore = 0
	for i=1,count do
		if(maxScore < resultList[i].totalScore)then
			maxScore = resultList[i].totalScore
		end
		self:getPlayerInfo(resultList[i], function(err)
			finishCount = finishCount + 1
			print(finishCount,count)			
			if(finishCount == count)then
				ModuleCache.ModuleManager.hide_public_module("netprompt")
				self.panel:refreshPanel(data, maxScore,dissolverId)
			end
		end)
	end	
	--]]

	self.tableResultView.buttonShare.gameObject:SetActive(not ModuleCache.GameManager.iosAppStoreIsCheck)
end

function TableResultModule:getPlayerInfo(data, callback)
	if(data.playerInfo and data.playerInfo.userId)then
		local player = {}
		player.uid = data.playerInfo.userId
		player.nickname = data.playerInfo.nickname
		player.headImg = data.playerInfo.headImg
		data.player = player
		callback(nil)
		return
	end
	local userId = data.playerId or data.userId
	self.tableResultModel:get_userinfo(userId, function(err, playerData)
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
	if obj == self.tableResultView.buttonBack.gameObject then
		self.modelData.curTableData.roomInfo = nil		
		ModuleCache.ModuleManager.destroy_package("shisanzhang")
		ModuleCache.ModuleManager.show_module("henanmj", "hall")
		return
	elseif obj == self.tableResultView.buttonShare.gameObject then
		ModuleCache.ShareManager().shareImage(false)
		return;
	elseif obj == self.tableResultView.buttonOnceMore.gameObject then

	end
end




return TableResultModule



