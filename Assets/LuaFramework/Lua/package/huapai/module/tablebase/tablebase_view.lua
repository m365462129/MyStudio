--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameObject = UnityEngine.GameObject
local GameSDKInterface = ModuleCache.GameSDKInterface
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
---@class PaoHuZiTableBaseView
local TableBaseView = class('tableBaseView', View)
local ComponentUtil = ModuleCache.ComponentUtil
local PlayerPrefs = UnityEngine.PlayerPrefs

local coroutine = require("coroutine")
local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

function TableBaseView:initialize(...)
	View.initialize(self, ...)
	local gameRoot = GameObject.Find("GameRoot")
	self.uicamera = GetComponentWithPath(gameRoot, "Game/UIRoot/UICamera", "UnityEngine.Camera")
	self.sliderBattery = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/Battery", ComponentTypeName.Slider)
	self.batteryCharging = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/Battery/ImageCharging", ComponentTypeName.Transform).gameObject
	self.textTime = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/Time/Text", ComponentTypeName.Text)
	self.goWifiStateArray = {}	
	for i = 1, 5 do
		local goState = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/WifiState/state" ..(i - 1), ComponentTypeName.Transform).gameObject
		table.insert(self.goWifiStateArray, goState)
	end
	
	self.goGState2G = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/GState/2g", ComponentTypeName.Transform).gameObject
	self.goGState3G = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/GState/3g", ComponentTypeName.Transform).gameObject
	self.goGState4G = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/GState/4g", ComponentTypeName.Transform).gameObject
	
	self.textPingState = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/TextPingState", ComponentTypeName.Text)
	self.tableBg1 = ModuleCache.ComponentUtil.Find(self.root, "Center/Bg" .. AppData.Game_Name)
	self.tableBg2 = ModuleCache.ComponentUtil.Find(self.root, "Center/Bg" .. AppData.Game_Name .. '1')
	self.tableBg3 = ModuleCache.ComponentUtil.Find(self.root, "Center/Bg" .. AppData.Game_Name .. '2')

	self.bgMoRen = ModuleCache.ComponentUtil.Find(self.root, "Center/Bg")
	self.bgMoRen.gameObject:SetActive(false)

	self:refresh_table_bg()

	self.btnStartZhunBei_museum =  GetComponentWithPath(self.root, "CenterBtn/btnStartZhunBei_museum",ComponentTypeName.Button)


	if self.btnStartZhunBei_museum then
		self.btnStartZhunBei_museum_cd_obj =  GetComponentWithPath(self.root, "CenterBtn/btnStartZhunBei_museum/Count down",ComponentTypeName.Transform).gameObject
		self.btnStartZhunBei_museum_cd_tex =  GetComponentWithPath(self.root, "CenterBtn/btnStartZhunBei_museum/Count down/Text",ComponentTypeName.Text)
	else
		self.btnStartZhunBei_museum_cd_obj = UnityEngine.GameObject.New()

	end
end

function TableBaseView:refresh_table_bg()
	local tableBg = PlayerPrefs.GetInt("RoomSetting_TableBackground_Name_" .. "PHZ", 1)

	ModuleCache.ComponentUtil.SafeSetActive(self.tableBg1, tableBg == 1)
	ModuleCache.ComponentUtil.SafeSetActive(self.tableBg2, tableBg == 2)
	ModuleCache.ComponentUtil.SafeSetActive(self.tableBg3, tableBg == 3)
end

function TableBaseView:refresh_voice_shake()
	self.openVoice =(PlayerPrefs.GetFloat("openVoiceVolume", 0.5) > 0)
	self.openShake =(PlayerPrefs.GetInt("openShake", 1) == 1)
	self.openGuoHu =(PlayerPrefs.GetInt("openGuoHu", 1) == 1)
	self.openFast =(PlayerPrefs.GetInt("openFast", 1) ==  1)
end

function TableBaseView:get_world_pos(screenPos, z)
	return self.uicamera:ScreenToWorldPoint(Vector3.New(screenPos.x, screenPos.y, z))
end

-- 实时刷新
function TableBaseView:update_beat()
	
end

-- 实时刷新游戏状态
--function TableBaseView:refresh_game_state(data)
--
--end
-- 房间内用户上线
--function TableBaseView:refresh_user_online(data)
--
--end
-- 房间内用户离线
--function TableBaseView:refresh_user_offline(data)
--
--end
-- 玩家即时反馈的状态
--function TableBaseView:refresh_report_state(data)
--
--end
-- 单独聊天信息
--function TableBaseView:refresh_private_message(data)
--
--end
-- 刷新用户状态
--function TableBaseView:refresh_user_state(data)
--
--end
-- 刷新座位信息
--function TableBaseView:refresh_seat_info(data)
--
--end
function TableBaseView:refresh_battery_time_info()
	
	local batteryValue = GameSDKInterface:GetCurBatteryLevel()
	batteryValue = batteryValue / 100
	self.sliderBattery.value = batteryValue
	self.textTime.text = os.date("%H:%M", os.time())
	
	local signalType = GameSDKInterface:GetCurSignalType()
	
	if(signalType == "none") then
		self:show_wifi_state(true, 0)
		self:show_4g_state(false)
	elseif(signalType == "wifi") then
		local wifiLevel = GameSDKInterface:GetCurSignalStrenth()			
		self:show_wifi_state(true, math.ceil(wifiLevel))
		self:show_4g_state(false)
	else
		self:show_wifi_state(false)
		self:show_4g_state(true, signalType)
	end
	ModuleCache.ComponentUtil.SafeSetActive(self.batteryCharging, GameSDKInterface:GetCurChargeState())
end

function TableBaseView:show_wifi_state(show, wifiLevel)	
	for i = 1, #self.goWifiStateArray do		
		ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)
	end
end

function TableBaseView:show_4g_state(show, signalType)
	ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")	
	ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")	
	ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")	
end

function TableBaseView:show_ping_delay(show, delaytime)
	ModuleCache.ComponentUtil.SafeSetActive(self.textPingState.gameObject, show)	
	if(not show) then
		return
	end
	delaytime = math.floor(delaytime * 1000)
	local content = ''
	if(delaytime >= 1000) then
		delaytime = delaytime / 1000
		delaytime = Util.getPreciseDecimal(delaytime, 2)
		content = '<color=#a31e2a>' .. delaytime .. 's</color>'
	elseif(delaytime >= 200) then
		content = '<color=#a31e2a>' .. delaytime .. 'ms</color>'
	elseif(delaytime >= 100) then
		content = '<color=#b5a324>' .. delaytime .. 'ms</color>'
	else
		content = '<color=#44b916>' .. delaytime .. 'ms</color>'
	end
	self.textPingState.text = content
end

function TableBaseView:show_chat_bubble(seat, content)
	
end

function TableBaseView:show_voice(seat)
	
end

function TableBaseView:hide_voice(seat)
	
end

function TableBaseView:on_show()
	
end

return TableBaseView 