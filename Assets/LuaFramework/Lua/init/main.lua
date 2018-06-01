-- =================================================================================================================== --
-- User: dred
-- Date: 2016/12/4
-- Time: 9:29
-- Desc: 整个游戏的主入口，用来启动游戏
-- =================================================================================================================== --
local require= require


local LuaBridge = LuaBridge
local UnityEngine = UnityEngine
--local ComponentTypeName = ComponentTypeName


local GameConfigProject = LuaBridge.GameConfigProject.instance
require("util.log")

local ComponentUtil = LuaBridge.ComponentUtil

local GameObject = UnityEngine.GameObject
local AssetBundleManager = LuaBridge.AssetBundleManager.instance
AssetBundleManager:Initialize()

UnityEngine.Screen.sleepTimeout = 0

local gameRoot = GameObject.Find("GameRoot")
if not gameRoot then
    local asset = AssetBundleManager:LoadAssetBundle("public/ui/init/gameroot.bytes"):GetAsset("GameRoot", false)
    gameRoot = ComponentUtil.InstantiateLocal(asset)
    gameRoot.name = "GameRoot"
end

local gameLauncher = GameObject.Find("GameLauncher")
if gameLauncher then
    gameLauncher:SetActive(false)
    GameObject.Destroy(gameLauncher)
end

-- 需要严格控制加载顺序
require("core.unity3d")
require("core.structure")
require("core.application_event")
require("core.ui_event_handle")
require("const.app_data")
require("const.module_cache")
require("util.log")


local ModuleCache = ModuleCache
ModuleCache.load_init_module()
ModuleCache.load_net_module()
ModuleCache.GameManager.gameRoot = gameRoot

local ComponentTypeName = ComponentTypeName

local canvasScaler = ModuleCache.ComponentManager.GetComponentWithPath(gameRoot, "Game/UIRoot/UIWindowParent/Canvas/CanvasScaler", ComponentTypeName.RectTransform)
if UnityEngine.Screen.width * 1.0 / UnityEngine.Screen.height > 1.8 then
    local canvas = ModuleCache.ComponentManager.GetComponentWithPath(gameRoot, "Game/UIRoot/UIWindowParent/Canvas", ComponentTypeName.RectTransform)
    local camera = ModuleCache.ComponentManager.GetComponentWithPath(gameRoot, "Game/UIRoot/UICamera", ComponentTypeName.Camera)
    if string.find(ModuleCache.GameManager.deviceModel, "iPhone10,") then
        camera.rect = UnityEngine.Rect(0.05, 0, 0.9, 1)
        canvas.sizeDelta = Vector2(canvasScaler.sizeDelta.x * 0.9, canvasScaler.sizeDelta.y)
    else
        canvas.sizeDelta = canvasScaler.sizeDelta
    end
    canvas.localScale = canvasScaler.localScale
end
canvasScaler.gameObject:SetActive(false)


ModuleCache.LogManager.register()

if not GameConfigProject.developmentMode then
    -- 非调试模式下关闭log
    GameConfigProject.netTransferDataShow = false
    ModuleCache.GameManager.close_print()
    ModuleCache.GameManager.print_toggle_data.print = print
    print = function ( ... ) end
else
    --require("mobdebug").start()
end

UnityEngine.Screen.sleepTimeout = -1
---------------------------------------------------------------------------------

local accountID = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
if accountID ~= "0" then
    ModuleCache.GameSDKInterface:BuglySetUserId(accountID)
end

ModuleCache.ModuleManager.show_module("henanmj", "login")



