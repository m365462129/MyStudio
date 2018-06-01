--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameObject = UnityEngine.GameObject
local GameSDKInterface = ModuleCache.GameSDKInterface
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
---@class TableCPBaseView : View
local TableCPBaseView = class('TableCPBaseView', View)
local ComponentUtil = ModuleCache.ComponentUtil
local PlayerPrefs = UnityEngine.PlayerPrefs

function TableCPBaseView:initialize(...)
    View.initialize(self, ...)
    local gameRoot = GameObject.Find("GameRoot")
    self.uicamera = GetComponentWithPath(gameRoot, "Game/UIRoot/UICamera", "UnityEngine.Camera")
    self.sliderBattery = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/Battery", ComponentTypeName.Slider)
    self.batteryCharging = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/Battery/ImageCharging", ComponentTypeName.Transform).gameObject
    self.textTime = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/Time/Text", ComponentTypeName.Text)
    self.goWifiStateArray = {}    
    for i=1,5 do
        local goState = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end
    
    self.goGState2G = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/GState/4g", ComponentTypeName.Transform).gameObject

    self.textPingState = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/TextPingState", ComponentTypeName.Text)
    self.tableBg1 = ModuleCache.ComponentUtil.Find(self.root, "Center/ImageBackground")
    self.tableBg2 = ModuleCache.ComponentUtil.Find(self.root, "Center/ImageBackground2")
    self.tableBg3 = ModuleCache.ComponentUtil.Find(self.root, "Center/ImageBackground3")
end

function TableCPBaseView:refresh_voice_shake()
    self.openVoice = (PlayerPrefs.GetFloat("openVoiceVolume", 0.5) > 0)
    self.openShake = (PlayerPrefs.GetInt("openShake", 1) == 0)
    self.openGuoHu = (PlayerPrefs.GetInt("openGuoHu", 1) == 0)
    self.openFast = false and (PlayerPrefs.GetInt("openFast", 1) == 1)
end

function TableCPBaseView:get_world_pos(screenPos, z)
    return self.uicamera:ScreenToWorldPoint(Vector3.New(screenPos.x, screenPos.y, z))
end

function TableCPBaseView:refresh_battery_time_info()

    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue / 100
    self.sliderBattery.value = batteryValue
    self.textTime.text = os.date("%H:%M", os.time())

    local signalType = GameSDKInterface:GetCurSignalType()

    if(signalType == "none")then
        self:show_wifi_state(true, 0)
        self:show_4g_state(false)
    elseif(signalType == "wifi")then
        local wifiLevel = GameSDKInterface:GetCurSignalStrenth()             
        self:show_wifi_state(true, math.ceil(wifiLevel))
        self:show_4g_state(false)
    else
        self:show_wifi_state(false)
        self:show_4g_state(true, signalType)
    end
    ModuleCache.ComponentUtil.SafeSetActive(self.batteryCharging, GameSDKInterface:GetCurChargeState())
end

function TableCPBaseView:show_wifi_state(show, wifiLevel)    
    for i=1,#self.goWifiStateArray do        
        ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)   
    end
end

function TableCPBaseView:show_4g_state(show, signalType)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")       
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")       
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")       
end

function TableCPBaseView:show_ping_delay(show, delaytime)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingState.gameObject, show)       
    if(not show)then
        return
    end
    delaytime = math.floor(delaytime * 1000)
    local content = ''
    if(delaytime >= 1000)then
        delaytime = delaytime / 1000
        delaytime = Util.getPreciseDecimal(delaytime, 2)
        content = '<color=#a31e2a>' .. delaytime .. 's</color>'
    elseif(delaytime >= 200)then
        content = '<color=#a31e2a>' .. delaytime .. 'ms</color>'
    elseif(delaytime >= 100)then
        content = '<color=#b5a324>' .. delaytime .. 'ms</color>'
    else
        content = '<color=#44b916>' .. delaytime .. 'ms</color>'
    end
    self.textPingState.text = content
end

-- 延时刷新state
function TableCPBaseView:pre_delay_state_time(newGameState)
    for i=1,#newGameState.Action do
        local action = newGameState.Action[i]
        if (9 == action.Action) then
            return -1
        end
    end
    return 0
end

function TableCPBaseView:get_chat_short_text(index)
    return TableUtil.get_chat_text(index)
end

--- 刷新游戏状态
function TableCPBaseView:refresh_game_state(gameState)

end

--- 刷新用户状态
function TableCPBaseView:refresh_user_state(userState)

end

--- 重置
function TableCPBaseView:reset_mj(refresh)

end

---获取当前时候显示听牌提示列表
function TableCPBaseView:getIsShowTingSetting()
    local gameInfo = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
    local keyName = gameInfo.createName.."_isShowTing" ---游戏创建名，全局唯一
    local isShowTingSetting = UnityEngine.PlayerPrefs.GetInt(keyName,1) == 1 and true or false
    return isShowTingSetting
end
---设置当前时候显示听牌提示列表
function TableCPBaseView:setIsShowTingSetting(isOpen)
    local gameInfo = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
    local keyName = gameInfo.createName.."_isShowTing" ---游戏创建名，全局唯一
    PlayerPrefs.SetInt(keyName,isOpen and 1 or 2)
end


return  TableCPBaseView