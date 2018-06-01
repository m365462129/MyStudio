-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("CowBoy.TableResultModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



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
	local resultList = data.resultList
	local roomInfo = data.roomInfo
	 --roomInfo = {
	 --	roomNum = 123456,
	 --	timestamp = os.time(),
		-- tableInfo = {
		--	 ruleTable = {
     --
		--	 },
		--	 curRoundNum = 0,
		--	 totalRoundCount = 0,
		-- }
	 --}
	 --resultList= {}
	 --for i=1,2 do
	 --	local result = {}
	 --	result.totalScore = i * 5
	 --	result.isCreator = i == 1
	 --	result.hasNiuTimes = i * 3
	 --	result.playerId = i + 110
	 --	result.noNiuTimes = i * 4
	 --	result.winTimes = i
	 --	result.loseTimes = i * 2
		-- result.isDissolver = i == 1
		--
	 --	table.insert(resultList, result)
	 --end
	
	
	-- print(ModuleCache.Json.encode(resultList))
	

	
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
	if(data.playerInfo and data.playerInfo.userId)then
		local player = {}
		player.uid = data.playerInfo.userId
		player.nickname = data.playerInfo.nickname
		player.headImg = data.playerInfo.headImg
		data.player = player
		callback(nil)
		return
	end
	self.tableResultModel:get_userinfo(data.playerId, function(err, playerData)
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
		ModuleCache.ModuleManager.destroy_package("cowboy")
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



