-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomSettingModule = class("roomSettingModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local PlayerPrefs = UnityEngine.PlayerPrefs


function RoomSettingModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "RoomSetting_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function RoomSettingModule:on_module_inited()		
	self.roomSettingView.toggleMusic.onValueChanged:AddListener(function()
		local musicVolume = 0
		if(self.roomSettingView.toggleMusic.isOn) then
			self.lastMusicVolume = self.view.sliderMusic.value
			musicVolume = 0
		else
			musicVolume = self.lastMusicVolume or self.view.sliderMusic.value
			if(musicVolume == 0) then
				musicVolume = 1
			end
		end
		ModuleCache.SoundManager.set_music_volume(musicVolume)
    	self.roomSettingView:refresh_music_volume()
	end)
	
	self.roomSettingView.sliderMusic.onValueChanged:AddListener(function()
		local value = self.roomSettingView.sliderMusic.value;
		ModuleCache.SoundManager.set_music_volume(value)
		self.roomSettingView:refresh_music_volume()
	end)

	self.roomSettingView.sliderSound.onValueChanged:AddListener(function()
		local value = self.roomSettingView.sliderSound.value;
		ModuleCache.SoundManager.set_sound_volume(value)
		self.roomSettingView:refresh_sound_volume()
	end)

	self.roomSettingView.sliderYuYin.onValueChanged:AddListener(function()
		local value = self.roomSettingView.sliderYuYin.value;
		ModuleCache.PlayerPrefsManager.SetFloat("openVoiceVolume", value)
		self.roomSettingView:refresh_YuYin()
	end)

	self.roomSettingView.toggleSound.onValueChanged:AddListener(function()
		local soundVolume = 0
		if(self.roomSettingView.toggleSound.isOn) then
			self.lastSoundVolume = self.view.sliderSound.value
			soundVolume = 0
		else
			soundVolume = self.lastSoundVolume or self.view.sliderSound.value
			if(soundVolume == 0) then
				soundVolume = 1
			end
		end
		ModuleCache.SoundManager.set_sound_volume(soundVolume)
		self.roomSettingView:refresh_sound_volume()
	end)
	self.roomSettingView.toggleYuYin.onValueChanged:AddListener(function()
		local yuyinVolume = 0
		if(self.roomSettingView.toggleYuYin.isOn) then
			self.lastYuYinVolume = self.view.sliderYuYin.value
			yuyinVolume = 0
		else
			yuyinVolume = self.lastYuYinVolume or self.view.sliderYuYin.value
			if(yuyinVolume == 0) then
				yuyinVolume = 1
			end
		end
		ModuleCache.PlayerPrefsManager.SetFloat("openVoiceVolume", yuyinVolume)
		self.roomSettingView:refresh_YuYin()
	end)

	self.roomSettingView.toggleZhenDong.onValueChanged:AddListener(function()
		if(self.roomSettingView.toggleZhenDong.isOn) then
			ModuleCache.PlayerPrefsManager.SetInt("openShake", 0)
		else
			ModuleCache.PlayerPrefsManager.SetInt("openShake", 1)
		end
		self.roomSettingView:refresh_ZhenDong()
	end)

	self.roomSettingView.toggleRecomOut.onValueChanged:AddListener(function()
		local key = string.format("%s_IsRecommendOutPai",ModuleCache.GameManager.curGameId)
		if(self.roomSettingView.toggleRecomOut.isOn) then
			ModuleCache.PlayerPrefsManager.SetInt(key,1)
		else
			ModuleCache.PlayerPrefsManager.SetInt(key,0)
		end
		self.roomSettingView:refresh_recommend_out_pai_setting()
		self:dispatch_package_event("Event_RoomSetting_recommendOutPai_settting")
	end)

	self.roomSettingView.toggleGuoHu.onValueChanged:AddListener(function()
		local curGuohuOpt = ModuleCache.PlayerPrefsManager.GetInt("openGuoHu", self.roomSettingData.defGuoHu or 1)
		ModuleCache.PlayerPrefsManager.SetInt("openGuoHu", 0 == curGuohuOpt and 1 or 0)
		--[[if(self.roomSettingView.toggleGuoHu.isOn) then
			ModuleCache.PlayerPrefsManager.SetInt("openGuoHu", 0)
		else
			ModuleCache.PlayerPrefsManager.SetInt("openGuoHu", 1)
		end--]]
		self.roomSettingView:refresh_guo_hu()
	end)

	self.roomSettingView.toggleFast.onValueChanged:AddListener(function()
		local curGuohuOpt = ModuleCache.PlayerPrefsManager.GetInt("openGuoHu", self.roomSettingData.defGuoHu or 1)
		ModuleCache.PlayerPrefsManager.SetInt("openGuoHu", 0 == curGuohuOpt and 1 or 0)
		--[[if(self.roomSettingView.toggleGuoHu.isOn) then
			ModuleCache.PlayerPrefsManager.SetInt("openGuoHu", 0)
		else
			ModuleCache.PlayerPrefsManager.SetInt("openGuoHu", 1)
		end--]]
		self.roomSettingView:refresh_guo_hu()
	end)

    --self.roomSettingView.togleMajongTextBig.onValueChanged:AddListener(function()
		--local sizeIndex = 0
		--if(self.roomSettingView.togleMajongTextSmall.isOn) then sizeIndex = 1 end
		--self.view:SetMajongTextSize(sizeIndex);
		--if(self.view.curTableData) then
		--	ModuleCache.PlayerPrefsManager.SetInt(string.format("%s_MJScale",self.view.curTableData.ruleJsonInfo.GameType), sizeIndex)
		--	self:dispatch_package_event("Event_Refresh_Mj_Scale_Color")
		--	self.view.mjScaleSet = sizeIndex
		--end
    --end)
    --
    --self.roomSettingView.togleMajongGreen.onValueChanged:AddListener(function()
		--local colorIndex = 1
		--if(self.roomSettingView.togleMajongGreen.isOn) then colorIndex = 0 end
		--self.view:SetMajongColor(colorIndex);
		--if(self.view.curTableData) then
		--	ModuleCache.PlayerPrefsManager.SetInt(string.format("%s_MJColor",self.view.curTableData.ruleJsonInfo.GameType), colorIndex)
		--	self:dispatch_package_event("Event_Refresh_Mj_Scale_Color")
		--	self.view.mjColorSet = colorIndex
		--end
    --end)
    --
    --for i=1,#self.view.togleZiPaiMen do
    --    self.view.togleZiPaiMen[i].onValueChanged:AddListener(function(s)
    --        if not s then
    --            return
		--	end
		--	if not self.diyiciJiaZaiZiPai then
		--		self.diyiciJiaZaiZiPai = true
		--	end
    --
    --        for k=1,#self.view.togleZiPaiMen do
    --            if self.view.togleZiPaiMen[k].isOn then
    --                ModuleCache.PlayerPrefsManager.SetInt('ZP_ZPPaiLei', k)
    --
    --                self:dispatch_package_event("Event_RoomSetting_ZiPaiSheZhi", 2)
    --            end
    --        end
    --        self.view.goZiPai_ZheDang.gameObject:SetActive(true)
    --        self:start_lua_coroutine(function ()
    --            coroutine.wait(0.8)
    --            if self.view then
    --                self.view.goZiPai_ZheDang.gameObject:SetActive(false)
    --            end
    --        end)
    --    end)
    --end

end




function RoomSettingModule:on_show_addListener()


	self:start_lua_coroutine(function ()
		self.IsLoadThisOnShow = true
		coroutine.wait(0.15)
		self.IsLoadThisOnShow = false
	end)

	if self.isAddlistener then

		return
	end
	self.isAddlistener = true

	if self.roomSettingData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_MJ" then
        local textChangeCallBack =  function()
            local sizeIndex = 0
            if(self.roomSettingView.togleMajongTextSmall.isOn) then
                sizeIndex = 1
            elseif(self.roomSettingView.togleMajongTextType3.isOn) then
                sizeIndex = 2
            end
            self.view:SetMajongTextSize(sizeIndex);
            if(self.view.curTableData) then
                ModuleCache.PlayerPrefsManager.SetInt(string.format("%s_MJScale",self.view.curTableData.ruleJsonInfo.GameType), sizeIndex)
                self:dispatch_package_event("Event_Refresh_Mj_Scale_Color")
                self.view.mjScaleSet = sizeIndex
				print("保存 sizeIndex ："..tostring(sizeIndex))
            end
        end
		self.roomSettingView.togleMajongTextBig.onValueChanged:AddListener(function()
            textChangeCallBack()
		end)
        self.roomSettingView.togleMajongTextSmall.onValueChanged:AddListener(function()
            textChangeCallBack()
        end)
        self.roomSettingView.togleMajongTextType3.onValueChanged:AddListener(function()
            textChangeCallBack()
        end)
        local colorChangeCallBack = function()
            local colorIndex = 1
            if(self.roomSettingView.togleMajongGreen.isOn) then
                colorIndex = 0
            elseif(self.roomSettingView.togleMajongType3.isOn) then
                colorIndex = 2
            end
            self.view:SetMajongColor(colorIndex);
            if(self.view.curTableData) then
                ModuleCache.PlayerPrefsManager.SetInt(string.format("%s_MJColor",self.view.curTableData.ruleJsonInfo.GameType), colorIndex)
                self:dispatch_package_event("Event_Refresh_Mj_Scale_Color")
                self.view.mjColorSet = colorIndex
				print("保存 colorIndex ："..tostring(colorIndex))
			end
        end
		self.roomSettingView.togleMajongGreen.onValueChanged:AddListener(function()
            colorChangeCallBack()
		end)
        self.roomSettingView.togleMajongYellow.onValueChanged:AddListener(function()
            colorChangeCallBack()
        end)
        self.roomSettingView.togleMajongType3.onValueChanged:AddListener(function()
            colorChangeCallBack()
        end)
		local mj3dSkinChangeCallBack = function()
			local skinType = 1
			if(self.roomSettingView.mj3dSkinType1.isOn) then
				skinType = 1
			elseif(self.roomSettingView.mj3dSkinType2.isOn) then
				skinType = 2
			elseif(self.roomSettingView.mj3dSkinType3.isOn) then
				skinType = 3
			end
			if(self.view.curTableData) then
				ModuleCache.PlayerPrefsManager.SetInt(string.format("%s_Mj3d_Skin",self.view.curTableData.ruleJsonInfo.GameType),skinType)
				self:dispatch_package_event("Event_Refresh_Mj3d_Skin")
				print("保存 Mj3d_Skin ："..tostring(skinType))
			end
		end
		self.roomSettingView.mj3dSkinType1.onValueChanged:AddListener(function(change)
			if change then
				mj3dSkinChangeCallBack()
			end
		end)
		self.roomSettingView.mj3dSkinType2.onValueChanged:AddListener(function(change)
			if change then
				mj3dSkinChangeCallBack()
			end
		end)
		self.roomSettingView.mj3dSkinType3.onValueChanged:AddListener(function(change)
			if change then
				mj3dSkinChangeCallBack()
			end
		end)

	elseif self.roomSettingData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_PHZ" then
		for i=1,#self.view.togleZiPaiMen do
			self.view.togleZiPaiMen[i].onValueChanged:AddListener(function(s)
				self:start_lua_coroutine(function ()
					coroutine.wait(0.05)
					if not self.view then
						return
					end

					if self.IsLoadThisOnShow then
						return
					end
					
					if not s then
						return
					end
	
					for k=1,#self.view.togleZiPaiMen do
						if self.view.togleZiPaiMen[k].isOn then
							ModuleCache.PlayerPrefsManager.SetInt('ZP_ZPPaiLei'.. AppData.Game_Name, k)
	
							self:dispatch_package_event("Event_RoomSetting_ZiPaiSheZhi", 2)
						end
					end
					self.view.goZiPai_ZheDang.gameObject:SetActive(true)
					
					coroutine.wait(0.8)
					if self.view then
						self.view.goZiPai_ZheDang.gameObject:SetActive(false)
					end
				end)
			end)
		end
	elseif self.roomSettingData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_RUNFAST" then
		self.view:SetRunfastInitToggle(ModuleCache.PlayerPrefsManager.GetInt("RunfastPokerStyleType"))
		local togleRunfastArr = self.view.togleRunfastArr
		for i=1,#togleRunfastArr do
			local togleRunfast = togleRunfastArr[i]
			togleRunfast.onValueChanged:AddListener(function()
				local RunfastPokerStyleType = self:ChangedStyleType_Runfast()
		    end)
		end
	end
end

function RoomSettingModule:ChangedStyleType_Runfast()
	if(self.Refreshing) then
		return
	end
	local togleRunfastArr = self.view.togleRunfastArr
	for i=1,#togleRunfastArr do
		local togleRunfast = togleRunfastArr[i]
		if(togleRunfast.isOn) then
			print("=========切换:跑得快牌面样式",i)
			ModuleCache.PlayerPrefsManager.SetInt("RunfastPokerStyleType",i)
			self:dispatch_package_event("Event_Refresh_StyleType_Runfast",i)
			self.Refreshing = true
			self:subscibe_time_event(0.3, false, 1):OnComplete( function(t)
				self.Refreshing = false
			end)
			return i
		end
	end
	return 1
end



-- 绑定module层的交互事件
function RoomSettingModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function RoomSettingModule:on_model_event_bind()
	
end

function RoomSettingModule:on_show(data)
	self.roomSettingData = data
	self.tableBackgroundSpriteSetName = data.tableBackgroundSpriteSetName
	self.roomSettingView:refreshView(data)	--先屏蔽解散房间的功能

	self:on_show_addListener()

	self:start_lua_coroutine(function ()
		coroutine.wait(0)
		local str = AppData.Game_Name
		if string.sub(str, 3) == 'ZP' then
			self.view:SetLabel(5)
			self.view:ShowWindow(5)
		end
	end)
end



function RoomSettingModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.roomSettingView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "roomsetting")
		self:dispatch_package_event("Event_Refresh_Voice_Shake")
		return
	elseif obj == self.roomSettingView.buttonDissolveRoom.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "roomsetting")
		self:dispatch_module_event("roomsetting", "Event_RoomSetting_DissolvedRoom", 1)
		self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)
	elseif obj == self.roomSettingView.buttonExitRoom.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "roomsetting")
		self:dispatch_module_event("roomsetting", "Event_RoomSetting_LeaveRoom", 1)
		self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
	elseif(obj.name == "ButtonBg1") then
		local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
		local bgSetKey = string.format("%s_MJBackground",gameType)
		ModuleCache.PlayerPrefsManager.SetInt(bgSetKey or self.tableBackgroundSpriteSetName, 1)
		ModuleCache.PlayerPrefsManager.SetInt(self.view.bgSetKey or self.tableBackgroundSpriteSetName, 1)
		self.view:refresh_bg(1)
		self:dispatch_package_event("Event_RoomSetting_RefreshBg", 1)
	elseif(obj.name == "ButtonBg2") then
		local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
		local bgSetKey = string.format("%s_MJBackground",gameType)
		ModuleCache.PlayerPrefsManager.SetInt(bgSetKey or self.tableBackgroundSpriteSetName, 2)
		ModuleCache.PlayerPrefsManager.SetInt(self.view.bgSetKey or self.tableBackgroundSpriteSetName, 2)
		self.view:refresh_bg(2)
		self:dispatch_package_event("Event_RoomSetting_RefreshBg", 2)
	elseif(obj.name == "ButtonBg3") then
		local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
		local bgSetKey = string.format("%s_MJBackground",gameType)
		ModuleCache.PlayerPrefsManager.SetInt(bgSetKey or self.tableBackgroundSpriteSetName, 3)
		ModuleCache.PlayerPrefsManager.SetInt(self.view.bgSetKey or self.tableBackgroundSpriteSetName, 3)
		self.view:refresh_bg(3)
		self:dispatch_package_event("Event_RoomSetting_RefreshBg", 3)
	elseif(obj.name == "Button2d") then
		local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
		local GameID = AppData.get_app_and_game_name()
		local def3dOr2d = Config.get_mj3dSetting(GameID).def3dOr2d
		local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",gameType)
		local curSet = ModuleCache.PlayerPrefsManager.GetInt(mj2dOr3dSetKey,def3dOr2d)
		if 2 ~= curSet then
			local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",gameType)
			ModuleCache.PlayerPrefsManager.SetInt(mj2dOr3dSetKey,2)
			self.view:refresh_mj_3d_or_2d(2)
			self:dispatch_package_event("Event_RoomSetting_Refresh2dOr3d", 2)
		end
	elseif(obj.name == "Button3d") then
		local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
		local GameID = AppData.get_app_and_game_name()
		local def3dOr2d = Config.get_mj3dSetting(GameID).def3dOr2d
		local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",gameType)
		local curSet = ModuleCache.PlayerPrefsManager.GetInt(mj2dOr3dSetKey,def3dOr2d)
		if 1 ~= curSet then
			ModuleCache.PlayerPrefsManager.SetInt(mj2dOr3dSetKey,1)
			self.view:refresh_mj_3d_or_2d(1)
			self:dispatch_package_event("Event_RoomSetting_Refresh2dOr3d", 1)
		end
	elseif(obj.name == "MaJiangSetting") then
		self.view:SetLabel(1)
		self.view:ShowWindow(1)
	elseif(obj.name == "BackgroundSetting") then
		self.view:SetLabel(2)
		self.view:ShowWindow(2)
	elseif(obj.name == "MusicSetting") then
		self.view:SetLabel(3)
		self.view:ShowWindow(3)
	elseif(obj.name == "GameSetting") then
		self.view:SetLabel(4)
		self.view:ShowWindow(4)
	elseif(obj.name == "ZiPaiSetting") then
		self.view:SetLabel(5)
		self.view:ShowWindow(5)
	elseif(obj.name == "RunfastSetting") then
		self.view:SetLabel(6)
		self.view:ShowWindow(6)
	elseif(obj.name == "CommonPokerSetting") then
		self.view:SetLabel(7)
		self.view:ShowWindow(7)
	elseif(obj.name == "ZheDang") then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("正在切换牌，请1秒后再选择")
	elseif(obj.name == "Common") then
		local key = string.format("%s_LocationSetting",ModuleCache.GameManager.curGameId)
		ModuleCache.PlayerPrefsManager.SetInt(key,0)
		self.view:refresh_location_settting()
		self:dispatch_package_event("Event_RoomSetting_location_settting")
	elseif(obj.name == "Location") then
		local key = string.format("%s_LocationSetting",ModuleCache.GameManager.curGameId)
		ModuleCache.PlayerPrefsManager.SetInt(key,1)
		self.view:refresh_location_settting()
		self:dispatch_package_event("Event_RoomSetting_location_settting")
	else
		if(self.view.commponPokerSettingHolderList)then
			for i, v in pairs(self.view.commponPokerSettingHolderList) do
				local holder = v
				if(obj == holder.root)then
					self.view:RefreshCommonPokerFaceSettingPanel(holder.toggle)
					if(holder.on_change_poker_face)then
						holder.on_change_poker_face(holder.assetHolder)
					end
					break
				end
			end
		end
	end
end




return RoomSettingModule



