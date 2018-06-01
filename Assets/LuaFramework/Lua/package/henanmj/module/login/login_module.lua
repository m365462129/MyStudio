-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")

---@class LoginModule:ModuleBase
---@field model LoginModel
---@field loginModel LoginModel
---@field view LoginView
---@field loginView LoginView
local LoginModule = require("lib.middleclass")("BullFight.LoginModule", ModuleBase)
local Config = require("package.public.config.config")
TableManager = require("package.henanmj.table_manager")
TableManagerPoker = require("package.henanmj.table_manager_poker")
TableUtil = require("package.henanmj.table_util")
UserUtil = require("package.henanmj.module.playerinfo.user_util")

-- 常用模块引用
local ModuleCache = ModuleCache
local UnityEngine = UnityEngine
local PlayModeUtil = ModuleCache.PlayModeUtil
local GameManager = ModuleCache.GameManager

local iPhoneSpeaker

function LoginModule:initialize(...)
	self._get_app_upgrade_info_count = 0
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "login_view", "login_model", ...)
	self.modelData.reset()
	if ModuleCache.GameConfigProject.developmentMode then
		PlayModeUtil.test_mode(true)
	end
	--关闭多点触控
	UnityEngine.Input.multiTouchEnabled = false

	if ModuleCache.GameManager.customPlatformName == "IPhonePlayer" and ModuleCache.GameManager.appVersion == "1.6.1" then
		iPhoneSpeaker = iPhoneSpeaker or require("iPhoneSpeaker")
		if iPhoneSpeaker then
			iPhoneSpeaker.ForceToSpeaker()
		end
	end

	self:subscibe_app_focus_event(function (eventHead, state)
		if not self.view:is_active() then
			return
		end

		if state then
			self:process_mwenter()
		end
	end)
end

function LoginModule:on_show()

	self:showPlayMode()

	--ModuleCache.AssetBundleManager:LoadAssetBundleAsync("henanmj/module/hall/henanmj_windowhall.prefab", "HeNanMJ_WindowHall", nil)
	--ModuleCache.AssetBundleManager:LoadAssetBundleAsync("henanmj/module/hall/henanmj_windowhall.prefab", "HeNanMJ_WindowHall", nil)
	--ModuleCache.AssetBundleManager:LoadAssetBundleAsync("henanmj/module/table/henanmj_table.prefab", "HeNanMJ_Table", nil)
	-- ModuleCache.AssetBundleManager:LoadAssetBundleAsync("runfast/module/tablerunfast/runfast_table.prefab", "Runfast_Table", nil)
	-- ModuleCache.AssetBundleManager:LoadAssetBundleAsync("biji/module/tablebiji/biji_table.prefab", "BiJi_Table", nil)
	--self:subscibe_time_event(0.01, false, 0):OnComplete(function ( ... )
	--	ModuleCache.PreLoadManager.preLoad()
	--end)
	self:process_mwenter()
end

function LoginModule:process_mwenter()
	--ModuleCache.GameSDKCallback.instance.mwEnterRoomID = "%7B%22local%22%3A%22%E7%BA%A2%E4%B8%AD%E9%BA%BB%E5%B0%86%22%2C%22roomId%22%3A%22938353%22%2C%22parlorId%22%3A%220%22%2C%22ruleMsg%22%3A%228%E5%B1%80%204%E4%BA%BA%E7%8E%A9%E6%B3%95%20%E5%8F%AF%E6%8E%A5%E7%82%AE%20%E7%BA%A2%E4%B8%AD%20%E4%B8%8D%E5%8F%AF%E5%90%83%E7%89%8C%204%E7%BA%A2%E4%B8%AD%E8%83%A1%E7%89%8C%20%E6%89%8E2%E7%A0%81%20AA%E6%94%AF%E4%BB%98%20%22%2C%22roomType%22%3A0%2C%22gameName%22%3A%22DHHNQP_HZMJ__DHQGQPBID%22%2C%22type%22%3A2%7D"
	--ModuleCache.GameSDKCallback.instance.mwEnterRoomID = "%7b%22scene%22%3a%22hallshare%22%2c%22appGameName%22%3a%22DHGXQP_SANGONG%22%7d"
	local mwData = ModuleCache.GameManager.get_mw_data()
	if mwData then
		if mwData.appName and mwData.appName ~= ModuleCache.AppData.get_app_name() then
			if ModuleCache.GameManager.change_game_buy_appName_gameName(mwData.appName, mwData.gameName) then
				ModuleCache.GameManager.logout()
			end
		end
	end
end

function LoginModule:showPlayMode( )
	if(ModuleCache.GameManager.getCurProvinceId() == 0 or ModuleCache.GameManager.getCurGameId() == 0 ) then
		self.loginView.textPlayMode.text = "未选择玩法"
		return
	end

	if ModuleCache.GameManager.getCurProvinceId() ~= 0 then
		ModuleCache.GameManager.select_province_id(ModuleCache.GameManager.getCurProvinceId())
	end

	if ModuleCache.GameManager.getCurGameId() ~= 0 then
		ModuleCache.GameManager.select_game_id(ModuleCache.GameManager.getCurGameId())
	end

	--local province = ModuleCache.PlayModeUtil.getProvinceById(ModuleCache.GameManager.getCurProvinceId())
	--local provinceName = province.name .. " "
	--local config = require(province.modName)
    --
	--local sortConfig = PlayModeUtil.getSortConfig(config)
	--local playMode = PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.getCurGameId(),sortConfig)
	--self.loginView.textPlayMode.text = "<color=#F6DB77FF>" .. provinceName.. "</color>" .. playMode.hallName
end


-- 模块初始化完成回调，包含了view，loginModel初始化完成
function LoginModule:on_module_inited()
	if ModuleCache.GameManager.deviceIsMobile and not ModuleCache.GameConfigProject.developmentMode then
		self.loginView.toggleUseAccount.isOn = false
		self.loginView.goPannelTest:SetActive(false)
	else
		local accountName = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT)
		if accountName then
			self.loginView.inputAccount.text = accountName
		end

		self.loginView.toggleUseAccount.isOn = UnityEngine.PlayerPrefs.GetInt(ModuleCache.AppData.PLAYER_PREFS_KEY_TOGGLE_USE_ACCOUNT, 0) == 1
		self.loginView.inputAccount.gameObject:SetActive(self.loginView.toggleUseAccount.isOn)
		self.loginView.toggleUseAccount.onValueChanged:AddListener(function(state)
			self.loginView.inputAccount.gameObject:SetActive(state)
		end)
	end

	self.loginView.textVersion.text = ModuleCache.GameManager.appVersion .. "|" .. (ModuleCache.GameManager.appInternalAssetVersion or "0") .. "_" .. (ModuleCache.GameManager.appAssetVersion or "0")

	-- 设置进入主界面弹出活动界面
	GameManager.isNeedShowActivity = true
	-- self:CheckIosNetError()
	ModuleCache.PackageManager.init()
	self:_get_app_upgrade_info()
end

-- 先屏蔽掉
function LoginModule:CheckIosNetError()
	if GameManager.customPlatformName == "IPhonePlayer" then
		if(ModuleCache.GameSDKInterface:IsUserCloseNetWork()) then
			ModuleCache.ModuleManager.show_module("henanmj", "iosneterrorfix",nil)
			return

		end
	end
	self:_get_app_upgrade_info()
end

-- 绑定module层的交互事件
function LoginModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function LoginModule:on_model_event_bind()
	self:subscibe_model_event("Event_Login_LoginSucess", function(eventHead, eventData)
		if ModuleCache.GameManager.curProvince ~= 0 and ModuleCache.GameManager.curGameId ~= 0 then
			ModuleCache.ModuleManager.show_module_only("henanmj", "hall")
		end
		self.isLogin = true

		if(ModuleCache.GameManager.curProvince == 0) then
			--ModuleCache.ModuleManager.show_module('henanmj',"setprovince")
            ModuleCache.ModuleManager.show_public_module("operate");
			return
		end

		if(ModuleCache.GameManager.curGameId == 0) then
--			ModuleCache.ModuleManager.show_module('henanmj',"setprovince")
--			ModuleCache.ModuleManager.show_module("henanmj", "setplaymode",ModuleCache.GameManager.curProvince)
            ModuleCache.ModuleManager.show_public_module("operate");
			return
		end
	end)

	self:subscibe_package_event("Event_Set_Play_Mode",function(eventHead, eventData)
		self:showPlayMode( )
		---- 这里应该是第一次选择用
		--if self.isLogin then
		--	if ModuleCache.GameManager.curProvince ~= 0 and ModuleCache.GameManager.curGameId ~= 0 then
		--		local config = PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
		--		if not ModuleCache.PackageManager.get_app_package_update_info(config.package) then
		--			ModuleCache.ModuleManager.show_module_only("henanmj", "hall")
		--		end
		--	end
		--end
	end
	)
end



function LoginModule:on_click(obj, arg)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	local _cmd = obj.name
	print(_cmd)
	if "ButtonLogin" == _cmd then
		self:login()
	elseif "ButtonAnonymity" == _cmd then
		self:anonymity_login()
	elseif "ButtonTest" == _cmd then
		--ModuleCache.GameSDKInterface:BuglyPrintLog(5, "牌型数据错误，触发断线重连")
		--ModuleCache.GameSDKInterface:CopyTextToClipboard()
		--print(ModuleCache.GameSDKInterface:AndroidIsRoot())
		--print(ModuleCache.GameSDKInterface:AndroidIsSimulator())
		ModuleCache.ShareManager().shareImage(false)
		--UnityEngine.Screen.orientation = UnityEngine.ScreenOrientation.LandscapeRight
		--local uiCamera = ModuleCache.ComponentManager.GetComponentWithPath(UnityEngine.GameObject.Find("GameRoot"), "Game/UIRoot/UICamera", ComponentTypeName.Camera)
		--ModuleCache.CustomerUtil.MirrorCamera(uiCamera, UnityEngine.Vector3(-1, -1, 1))
	elseif "BtnSetPlayMode" == _cmd then
--		if ModuleCache.GameManager.getCurProvinceId() == 0 then
--			ModuleCache.ModuleManager.show_module('henanmj',"setprovince")
--		else
--			ModuleCache.ModuleManager.show_module('henanmj',"setplaymode", ModuleCache.GameManager.getCurProvinceId())
--		end
            ModuleCache.ModuleManager.hide_module("henanmj","login");
            ModuleCache.ModuleManager.show_public_module("operate");
	elseif "ButtonClearCache" == _cmd then
		ModuleCache.FileUtility.DirectoryDelete(UnityEngine.Application.persistentDataPath, true)
	elseif obj == self.loginView.toggleUserAgreement.gameObject then
		self.loginView.toggleUserAgreement.isOn = true
		ModuleCache.ModuleManager.show_module("henanmj", "useragreement")
	end
end

-- 登录账号
function LoginModule:login(autoLogin)
	if autoLogin and (not ModuleCache.GameManager.deviceIsMobile)  then
		return
	end
	--print(autoLogin, UnityEngine.PlayerPrefs.GetString(AppData.PLAYER_PREFS_KEY_USERID, "0"), GameManager.isLogout)
	if self.loginView.toggleUseAccount.isOn then
		local inputAccount = self.loginView.inputAccount
		local text = inputAccount.text
		if string.len(text) < 2 then
			if not autoLogin then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("账户输入错误")
			end
		else
			UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, text)
			self._loginAccountText = text
			self.loginModel:connect_login_server(tonumber(text), "liuyu", nil,self.view.testIdInput.text)
		end
	else
		local accountID = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
		local password = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_PASSWORD, "0")
		if accountID ~= "0" and password ~= "0" and password ~= "" then
			self.loginModel:connect_login_server(tonumber(accountID), password, nil,self.view.testIdInput.text)
		else
			local lastUerID = UnityEngine.PlayerPrefs.GetString(AppData.PLAYER_PREFS_KEY_USERID, "0")
			-- 需要自动登录
			-- not autoLogin 代表手动点击
			if not autoLogin or (lastUerID == "0" and (not GameManager.isLogout)) then
				ModuleCache.WechatManager.login(function(data)
					print_table(data, "WeChatManager.login")
					self.modelData.weXinUserData = data
					if data.token and data.token ~= "" then
						self.loginModel:connect_login_server(0, "", data.token)
					end
				end, function(error)
					ModuleCache.ModuleManager.hide_public_module("netprompt")
					print_table(error)
				end)
			end
		end
	end
	GameManager.isLogout = false
	if self.loginView.toggleUseAccount.isOn then
		UnityEngine.PlayerPrefs.SetInt(ModuleCache.AppData.PLAYER_PREFS_KEY_TOGGLE_USE_ACCOUNT, 1)
	else
		UnityEngine.PlayerPrefs.SetInt(ModuleCache.AppData.PLAYER_PREFS_KEY_TOGGLE_USE_ACCOUNT, 0)
	end

	ModuleCache.ShareSDKManager().init()
end


function LoginModule:anonymity_login()
	local accountID = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
	if accountID ~= "0" then
		local password = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_PASSWORD, "0")
		self.loginModel:connect_login_server(tonumber(accountID), password, nil,self.view.testIdInput.text)
	else
		self.loginModel:connect_login_server(0, "", "youke",self.view.testIdInput.text)
	end
end

function LoginModule:_get_app_upgrade_info()
	self._get_app_upgrade_info_count = self._get_app_upgrade_info_count + 1
	ModuleCache.GameManager.get_app_upgrade_info(function(wwwData)
		if wwwData.success == true then
			if self.isDestroy then  -- 要注意缓存回调时有可能view已经销毁了
            	return
        	end
			self:_on_app_upgrade_info(wwwData.map)
		else
			if self._get_app_upgrade_info_count > 3 then
				self._get_app_upgrade_info_count = 0
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("版本检测失败，请重试\n<size=20>" .. wwwData.resultCode .."</size>", function()
					self:_get_app_upgrade_info()
				end)
			else
				self:_get_app_upgrade_info()
			end
		end
	end, function(wwwErrorString)
		if self._get_app_upgrade_info_count > 3 then
			self._get_app_upgrade_info_count = 0
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("版本检测失败，请重试\n<size=20>" .. wwwErrorString .."</size>", function()
				self:_get_app_upgrade_info()
			end)
		else
			self:_get_app_upgrade_info()
		end
	end, true)
end


function LoginModule:_on_app_upgrade_info(data)
	GameManager.iosAppStoreIsCheck = false
	if GameManager.customPlatformName == "IPhonePlayer" and data.checkVersion then
		local dataList = ModuleCache.GameUtil.split(data.checkVersion, ',')
		for _i, _v in ipairs(dataList) do
			if _v == GameManager.appVersion then
				GameManager.iosAppStoreIsCheck = true	--审核状态下不自动登录
				-- 提审时选择广东省的跑得快玩法
				ModuleCache.GameManager.select_province_id(2)
				ModuleCache.GameManager.select_game_id(1)
				print("处于审核状态！")
				break
			end
		end
	end

	if ModuleCache.GameManager.isEditor then
		--GameManager.iosAppStoreIsCheck = true
		--ModuleCache.GameManager.select_province_id(2)
		--ModuleCache.GameManager.select_game_id(1)
		--ModuleCache.ComponentUtil.SafeSetActive(self.view.goSetPlayMode, not GameManager.iosAppStoreIsCheck)
	end
	if GameManager.iosAppStoreIsCheck then
		self.loginView.goSetPlayMode:SetActive(false)
		ModuleCache.ComponentUtil.SafeSetActive(self.loginView.buttonLogin.gameObject, false)
		ModuleCache.ComponentUtil.SafeSetActive(self.loginView.buttonAnonymity.gameObject, true)
		-- GameManager.select_game_id(UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE, 1))
		-- 返回不会自动登录
		return
	else
		local lastUerID = UnityEngine.PlayerPrefs.GetString(AppData.PLAYER_PREFS_KEY_USERID, "0")
		if lastUerID == "0" then
			self.loginView.goSetPlayMode:SetActive(false)
		else
			--self.loginView.goSetPlayMode:SetActive(true)
		end

		self:begin_location()
		ModuleCache.ComponentUtil.SafeSetActive(self.loginView.buttonLogin.gameObject, true)
    	ModuleCache.ComponentUtil.SafeSetActive(self.loginView.buttonAnonymity.gameObject, false)
		--ModuleCache.GPSManager.StartGetMyGPSInfo()
	end



	if GameManager.needCheckVersionData then
		self:_check_asset_version_data(data)
	end
end

---_check_asset_version_data 检查是否数据需要更新
---@param data table
function LoginModule:_check_asset_version_data(data)
	local package = "public"
	if (GameManager.curGameId ~= 0) then
		local playMode = ModuleCache.PlayModeUtil.getInfoByGameId(GameManager.curGameId)
		package = playMode.package
	end


	ModuleCache.PackageManager.update_package_version(package, function()
		-- 更新完所有资源再去检测是否有apk、ipa需要更新
		self:process_app_version_update()
	end)
end


---process_app_version_update 处理App大版本的更新
function LoginModule:process_app_version_update()
	--是否有App新版本
	if GameManager.appAssetVersionUpdateData.appData  then
		local appData = GameManager.appAssetVersionUpdateData.appData
		if appData.forceUpgrade == 1 then
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(appData.versionDesc, function()
				if ModuleCache.GameManager.customPlatformName == "IPhonePlayer" then
					UnityEngine.Application.OpenURL(appData.url)
				else
					ModuleCache.ModuleManager.hide_public_module("alertdialog")
					self:_check_apk_version_data(appData)
				end
			end, true)
		else
			local text = "<size=33>检测到新版本，是否更新？</size>\n\n" .. appData.versionDesc
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_confirm_cancel(text, function()
				if ModuleCache.GameManager.customPlatformName == "IPhonePlayer" then
					UnityEngine.Application.OpenURL(appData.url)
				else
					ModuleCache.ModuleManager.hide_public_module("alertdialog")
					self:_check_apk_version_data(appData)
				end
			end, function()
				self:login(true)
			end)
		end
	else
		self:login(true)
	end
end


function LoginModule:_check_apk_version_data(data)
	if(data)then
		local saveDirPath = UnityEngine.Application.persistentDataPath .. "/apk"
		local intentData = {
			appData = {
				saveFilePath =  saveDirPath .. "/" .. AppData.App_Name .. "-" .. data.serverAppVersion .. ".apk",
				url = data.url,
				fileSize = 1024 * 1024 * 20,
			},
			updateFailureCallback = function(ret)	-- 更新失败需要再次走更新逻辑
				self:_get_app_upgrade_info()
			end,
		}
		ModuleCache.ModuleManager.show_module("henanmj", "update", intentData)
	else

	end
end

return LoginModule



