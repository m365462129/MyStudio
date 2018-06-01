-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================
local ModuleCache = ModuleCache
local UnityEngine = UnityEngine

---@class LoginModel
local LoginModel = Class("loginModel", Model)
local CSmartTimer = ModuleCache.SmartTimer.instance
function LoginModel:initialize(...)
	Model.initialize(self, ...)	
	
end


function LoginModel:connect_login_server(userId, password, weiXinCode, testUserId)
	TableManager:connect_login_server(function()
		TableManager:request_login_login_server(userId, password, weiXinCode)
	end,
	--登录成功回调
	function(data)
		if data.UserID ~= "0" then
			ModuleCache.LogManager.uid = data.UserID
			ModuleCache.GameSDKInterface:BuglySetUserId(data.UserID)
			if testUserId then
				self.testUserId = testUserId
			end
			self:set_role_data(data)
			ModuleCache.CustomVoiceManager.uid = data.UserID
			UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, data.UserID)
			UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_USERID, data.UserID)
			UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_PASSWORD, data.Password)
			UnityEngine.PlayerPrefs.Save()

			if(data.RoomID and data.RoomID ~= 0) then
				local jsonTable = ModuleCache.Json.decode(data.LoginArgs)
				if data.LoginEnv == "match" then
					self.modelData.tableCommonData.tableType = 2
				elseif data.LoginEnv == "new_gold" then
					self.modelData.tableCommonData.tableType = 1
					self.modelData.tableCommonData.goldFildId = jsonTable.GoldID
				else
					self.modelData.tableCommonData.tableType = 0
				end
				TableManager:request_join_room_login_server(data.RoomID)
			elseif (data.LoginEnv == 'match') then
				local jsonTable = ModuleCache.Json.decode(data.LoginArgs)
				if TableManager.checkLoginTimeId then
					CSmartTimer:Kill(TableManager.checkLoginTimeId)
					TableManager.checkLoginTimeId = nil
				end

				TableManager:request_matching_enter(jsonTable.MatchID, jsonTable.StageID)

			elseif (data.LoginEnv == 'new_gold') then
				local jsonTable = ModuleCache.Json.decode(data.LoginArgs)
				if TableManager.checkLoginTimeId then
					CSmartTimer:Kill(TableManager.checkLoginTimeId)
					TableManager.checkLoginTimeId = nil
				end
				TableManager:request_goldmatching_enter(jsonTable.GoldID, userId)
			else
				TableManager:disconnect_login_server()
				if(ModuleCache.GameManager.curGameId == 0) then

				end
				Model.dispatch_event(self, "Event_Login_LoginSucess", { data = retData })
				--ModuleCache.PreLoadManager.registerFinishPreLoadCallback(function()
				--	--UnityEngine.Application.backgroundLoadingPriority = UnityEngine.ThreadPriority.High
				--	ModuleCache.ModuleManager.show_module_only("henanmj", "hall")
				--end)
				--ModuleCache.ModuleManager.show_module_only("henanmj", "hall")
			end
			self:get_is_agent()
			ModuleCache.JpushManager.init(data.UserID)
			if ModuleCache.TalkingDataMgr then
				local loginType = ModuleCache.TalkingDataMgr.LoginType.REGISTERED
				if self.modelData.weXinUserData then
					loginType = ModuleCache.TalkingDataMgr.LoginType.WeChat
				end
				ModuleCache.TalkingDataMgr.setAccount(self.modelData.roleData, loginType)
			end
		else
			UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
			UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_PASSWORD, "0")
			if(data.ErrorInfo) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)	
			else
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("登录失败，请重试")	
			end
			TableManager:disconnect_login_server()
		end		
	end,
	nil, nil, function()
		TableManager:showNetErrDialog(nil)
	end)
end

-- 是否为代理
function LoginModel:get_is_agent()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/isAgent?",
		params = {
			uid = self.modelData.roleData.userID,
		}
	}

	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		self.modelData.roleData.agentUrl = retData.data
	end, function(errorData)
		print(errorData.error)
	end)
end


function LoginModel:set_role_data(data)
	self.modelData.reset()
	self.modelData.roleData.userID	= data.UserID;       --用户ID。为0表示微信登录
	if ModuleCache.GameManager.runtimePlatform == "OSXEditor" or ModuleCache.GameManager.runtimePlatform == "WindowsEditor" then
		if self.testUserId and self.testUserId ~= "" then
			print("-------------------self.testUserId = "..self.testUserId)
			self.modelData.roleData.userID = self.testUserId
		end
    	--self.modelData.roleData.userID      = "32017257";  --用户ID。为0表示微信登录
	end
	self.modelData.roleData.password	= data.Password      --密码
	self.modelData.roleData.WeiXinCode = data.WeiXinCode;   --微信授权码。如果是用ID和密码登录，则忽略该参数
	self.modelData.roleData.Platform	= data.Platform;   --系统平台
	self.modelData.roleData.RoomID	= data.RoomID
	self.modelData.roleData.GameName	= data.GameName	
end


return LoginModel 