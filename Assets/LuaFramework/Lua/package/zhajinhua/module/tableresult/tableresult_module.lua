-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("TableResultModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local BranchPackageName = AppData.BranchZhaJinHuaName



function TableResultModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "tableResult_view", "tableResult_model", ...)

	local onAppFocusCallback = function ( eventHead, eventData )
		if(ModuleCache.GameSDKCallback.instance.mwEnterRoomID == "0")then
			return
		end
       ModuleCache.ModuleManager.destroy_package("cowboy")
	   ModuleCache.ModuleManager.destroy_package("henanmj")
	   ModuleCache.ModuleManager.show_module("henanmj", "hall")
    end

    local onMWEnterCallbackd = function(roomId)
		if(ModuleCache.GameSDKCallback.instance.mwEnterRoomID == "0")then
			return
		end
		ModuleCache.ModuleManager.destroy_package("cowboy")
		ModuleCache.ModuleManager.destroy_package("henanmj")
	   	ModuleCache.ModuleManager.show_module("henanmj", "hall")
    end

    ModuleCache.WechatManager.registMWEnterRoomCallback(onMWEnterCallbackd)
    self:subscibe_app_focus_event(onAppFocusCallback)
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
	TableManagerPoker:disconnect_game_server()
	ModuleCache.ModuleManager.destroy_package("henanmj")
	local resultList = data.resultList
	local roomInfo = data.roomInfo
	self.tableResultView:refreshRoomInfo(roomInfo.roomNum, roomInfo.tableInfo,roomInfo.timestamp)
	local finishCount = 0
	local count = #resultList
	if(count ~= 0)then
		ModuleCache.ModuleManager.show_public_module("netprompt")
	end

	local maxScore = 0
	for i=1,count do
		if(maxScore < resultList[i].totalScore)then
			maxScore = resultList[i].totalScore
		end
		self:getPlayerInfo(resultList[i], function(err)
			finishCount = finishCount + 1			
			if(finishCount == count)then
				ModuleCache.ModuleManager.hide_public_module("netprompt")
				self.tableResultView:init_view(resultList, maxScore)
			end
		end)
	end	
	--]]
end

function TableResultModule:getPlayerInfo(data, callback)
	if(data.playerInfo and data.playerInfo.playerId)then
		print("=====大结算getPlayerInfo1")
		print(data.playerInfo)
		local player = {}
		
		player.uid = data.playerInfo.playerId
		player.nickname = data.playerInfo.nickname
		player.headImg = data.playerInfo.headImg
		player.spriteHeadImage = data.playerInfo.spriteHeadImage
		data.player = player
		callback(nil)
		return
	end
	print("=====大结算getPlayerInfo2")

	self.tableResultModel:get_userinfo(data.playerId, function(err, playerData)
		print("finish get userInfo")
		if(err)then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(err)	
			ModuleCache.ModuleManager.hide_public_module("netprompt")
			return
		end
		local player = {}
		player.uid = data.playerInfo.playerId--playerData.userId
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
		ModuleCache.ModuleManager.destroy_package(BranchPackageName)
		ModuleCache.ModuleManager.destroy_package("henanmj")
		ModuleCache.ModuleManager.show_module("henanmj", "hall")
		return
	elseif obj == self.tableResultView.buttonShare.gameObject then
		if(self.lastClickShareButtonTime and self.lastClickShareButtonTime + 1 > Time.realtimeSinceStartup)then
			return
		end
		self.lastClickShareButtonTime = Time.realtimeSinceStartup
		ModuleCache.ShareManager().shareImage(false)
		return;
	end
end




return TableResultModule



