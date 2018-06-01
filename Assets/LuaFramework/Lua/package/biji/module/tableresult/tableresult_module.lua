-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("BullFight.TableResultModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local PlayerPrefsManager = ModuleCache.PlayerPrefsManager



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
	gameName = gameName or 'biji'
	local path = "package.biji.module.tableresult.game.tableresult_"
	self.panel = require(path..string.lower(gameName).."_panel"):new(self)

	print_table(data)

	local resultList = data.resultList
	local roomInfo = data.roomInfo
	local name = data.gameName;
	local dissolverId = data.dissolverId;


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
			if(finishCount == count)then
				ModuleCache.ModuleManager.hide_public_module("netprompt")
				self.panel:refreshPanel(resultList, maxScore,dissolverId)
			end
		end)
	end	
	--]]
	self.selectTextShare =  PlayerPrefsManager.GetInt("Biji_ShareType_Toggle", 0) == 1
	self.tableResultView:showShareText(self.selectTextShare)

	self:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
		self:share_result_text(data)
	end)

	self.tableResultView.buttonShare.gameObject:SetActive(not ModuleCache.GameManager.iosAppStoreIsCheck)
	self.tableResultView.btnSelectShareObj:SetActive(not (ModuleCache.GameSDKInterface:GetPlatformName() == "IPhonePlayer"))
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
		ModuleCache.ModuleManager.destroy_package("biji")
		ModuleCache.ModuleManager.show_module("henanmj", "hall")
		return
	elseif obj == self.tableResultView.buttonShare.gameObject then
		if self.selectTextShare then
			ModuleCache.WechatManager.share_text(0, "", ModuleCache.ShareManager().copyText or "获取内容异常~-~")
		else
			ModuleCache.ShareManager().shareImage(false)
		end

	elseif obj == self.tableResultView.btnSelectText.gameObject then
		self:on_click_select_text()
	end
end

--选择或者取消文字分享
function TableResultModule:on_click_select_text()
	self.selectTextShare = not self.selectTextShare
	self.tableResultView:showShareText(self.selectTextShare)
	PlayerPrefsManager.SetInt("Biji_ShareType_Toggle" ,self.selectTextShare and 1 or 0)
end

function TableResultModule:share_result_text(data)
	local resultShareData = {
		roomID = data.roomInfo.roomNum,
		hallID = self.modelData.roleData.HallID,
		playerDatas = {}
	}

	if data.roomInfo.startTime then
		resultShareData.startTime = data.roomInfo.startTime
	end

	if data.roomInfo.endTime then
		resultShareData.endTime = data.roomInfo.endTime
	end

	local resultList = data.resultList
	local count = #resultList

	for i=1,count do
		if resultList[i].player then
			resultShareData.playerDatas[i] = {resultList[i].player.nickname, resultList[i].totalScore}
		else
			resultShareData.playerDatas[i] = {"ID:" .. resultList[i].playerInfo.userId, resultList[i].totalScore}
		end

		if data.dissolverId and resultList[i].playerInfo.userId == data.dissolverId then
			if resultList[i].player then
				resultShareData.dissRoomPlayName = resultList[i].player.nickname
			else
				resultShareData.dissRoomPlayName = "ID:" .. resultList[i].playerInfo.userId
			end
		end
	end

	ModuleCache.ShareManager().share_room_result_text(resultShareData)
end



return TableResultModule



