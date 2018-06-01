-- 模快的加载缓存，方便管理、提高性能
local require = require

--- @class ModuleCache
--- @field public GameManager GameManager
--- @field public ComponentUtil ComponentUtil
--- @field public PlayModeUtil PlayModeUtil
--- @field public ModuleManager ModuleManager
--- @field public JMsgManager JMsgManager
--- @field public JpushManager JpushManager
--- @field public TalkingDataMgr TalkingDataMgr
ModuleCache = {}

local ModuleCache = ModuleCache


local LuaBridge = LuaBridge

function ModuleCache.load_init_module()
    ModuleCache.LuaBridge = LuaBridge
    ModuleCache.UnityEngine = UnityEngine
    ModuleCache.Coroutine = {
        WaitForSeconds = WaitForSeconds,
        StartCoroutine = StartCoroutine,
        StopCoroutine = StopCoroutine,
        Yield = Yield,
        WaitForEndOfFrame = WaitForEndOfFrame,
        WaitForFixedUpdate = WaitForFixedUpdate,
        WaitForSeconds = WaitForSeconds,
    }

    ModuleCache.AssetBundleManager = LuaBridge.AssetBundleManager.instance
    ModuleCache.ComponentUtil = LuaBridge.ComponentUtil
    ModuleCache.CustomerUtil = LuaBridge.CustomerUtil
    ModuleCache.FileUtility = LuaBridge.FileUtility
    ModuleCache.GameConfigProject = LuaBridge.GameConfigProject.instance
    ModuleCache.GameSDKInterface = LuaBridge.GameSDKInterface.instance
    ModuleCache.GameSDKCallback = LuaBridge.GameSDKCallback
    ModuleCache.LuaBridge = LuaBridge
    ModuleCache.LuaHelper = LuaBridge.LuaHelper
    ModuleCache.SmartTimer = LuaBridge.SmartTimer
    ModuleCache.CSmartTimer = LuaBridge.SmartTimer.instance
    ModuleCache.TransformUtil = LuaBridge.TransformUtil
    ModuleCache.ViewUtil = LuaBridge.ViewUtil
    ModuleCache.WWWUtil = LuaBridge.WWWUtil
    ModuleCache.BestHttpUtil = LuaBridge.BestHttpUtil
    ModuleCache.AudioPlayUtil = LuaBridge.AudioPlayUtil
    ModuleCache.WavUtility = LuaBridge.WavUtility
    ModuleCache.AsyncFileUtil = LuaBridge.AsyncFileUtil
    ModuleCache.SecurityUtil = LuaBridge.SecurityUtil

    require("const.define")
    require("core.application_event")
    ModuleCache.Log = require("util.log")
    ModuleCache.AppData = AppData
    ModuleCache.ComponentTypeName = ComponentTypeName
    ModuleCache.PackageManager = require("manager.package_manager")
    ModuleCache.ComponentManager = require("manager.component_manager")
    ModuleCache.FunctionManager = require("manager.function_manager")
    ModuleCache.GameUtil = require("util.game_util")
    ModuleCache.ModuleManager = require("core.module_manager")
    ModuleCache.JMsgManager = require("manager.jmsg_manager")
    ModuleCache.WechatManager = require("manager.wechat_manager")
    ModuleCache.TextureCacheManager = require("manager.texturecache_manager")
    ModuleCache.UserDataManager = require("manager.userdata_manager")
    ModuleCache.SoundManager = require("manager.sound_manager")
    ModuleCache.Json = require("cjson")
    ModuleCache.GVoiceManager = require("manager.gvoice_manager")
    ModuleCache.CustomVoiceManager = require("manager.custom_voice_manager")
    ModuleCache.CustomImageManager = require("manager.custom_image_manager")
    ModuleCache.GPSManager = require("manager.gps_manager")
    ModuleCache.PlayModeUtil = require("package.henanmj.module.setplaymode.setplaymode_util")
    ModuleCache.GameManager = require("manager.game_manager")
    ModuleCache.ShareManager = require("manager.share_manager")
    ModuleCache.PreLoadManager = require("manager.preload_manager");
    ModuleCache.DOTweenAnimationTool = require("manager.DOTweenAnimationTool");
    ModuleCache.PlayerPrefsManager = require("manager.playerprefs_manager")
    ModuleCache.JpushManager = require("manager.jpush_manager")
    ModuleCache.TalkingDataMgr = require("manager.tkdata_manager")

    ModuleCache.ShareManager = function()
        ModuleCache._ShareManager = ModuleCache._ShareManager or require("manager.share_manager")
        return ModuleCache._ShareManager
    end

    ModuleCache.ShareSDKManager = function()
        ModuleCache._ShareSDKManager = ModuleCache._ShareSDKManager or require("manager.sharesdk_manager")
        return ModuleCache._ShareSDKManager
    end
    ModuleCache.LogManager = require("manager.log_manager")
    ModuleCache.OssManager = require("manager.oss_manager")
end

-- 加注net相关的模块
function ModuleCache.load_net_module()
    if ModuleCache.net then
        return
    end
    ModuleCache.net = { }
    ModuleCache.net.Buffer = LuaBridge.Buffer
    ModuleCache.net.NetworkManager = LuaBridge.NetworkManager
    ModuleCache.net.NetClientManager = require("core.net.net_client_manager")
    ModuleCache.net.PbcUtil = require('protobuf.protobuf')
    ModuleCache.net.PbcUtilEditor = require("core.net.pbc_editor_util")
    ModuleCache.net.NetMsgHandler = require('core.net.net_msg_handler')
end