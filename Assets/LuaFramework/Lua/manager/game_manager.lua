--
-- User: dred
-- Date: 2016/12/13
-- Time: 11:12
-- 基于
local ModuleCache = ModuleCache
--local print = print
local UnityEngine = UnityEngine
local PlayerPrefs = UnityEngine.PlayerPrefs
local GameObject = UnityEngine.GameObject
local AppData = AppData
local Util = Util
local string = string

require 'tolua.reflection'
tolua.loadassembly('Assembly-CSharp')

---@class GameManager
local GameManager = {}

GameManager.developmentMode = false
-- 初始化地址
GameManager.Server_Host = nil

-- 大众玩法的地址
GameManager.Public_Server_Host = nil

GameManager.appVersion = UnityEngine.Application.version
GameManager.appAssetVersion = 0
GameManager.appLocalAssetVersion = 0
GameManager.curPackageVersion = 0
-- 锁定版本不更新
GameManager.lockAssetUpdate = false

GameManager.netAdress = {}
GameManager.netAdress.httpCurApiUrl = nil
-- 当前的服务器ip
GameManager.netAdress.curServerHostIp = nil

GameManager.netAdress._httpApiUrlList = nil

--Android=1 iOS=2 用于版本升级、审核
GameManager.customOsType = nil
--Android 或者 IPhonePlayer  用于更新资源、地址分配
GameManager.customPlatformName = nil
-- 是否为手机设备
GameManager.deviceIsMobile = nil

-- ios版本是否在审核
GameManager.iosAppStoreIsCheck = false

-- 是否需要热更新资源
GameManager.needCheckVersionData = true

-- 在进入大厅时是否需要自动显示活动界面
GameManager.isNeedShowActivity = true

-- 当前选择的省份
GameManager.curProvince = 0
-- 是否第一次进游戏
GameManager.isFirstInGame = false

-- 当前选择的玩法的gameid
GameManager.curGameId = 0
-- 当前选择的玩法所在地区
GameManager.curLocation = 1

GameManager.isEditor = false

-- 是否开启服务器灰度测试
GameManager.openGameServerGradationTest = false

-- 是否为测试者
GameManager.isTestUser = false

-- 版本更新资源数据
GameManager.appAssetVersionUpdateData = {
    appData = nil,
    assetData = nil,
}



GameManager.print_toggle_data = {}

GameManager.gameRoot = nil

function GameManager.init()
    GameManager.modeData = require("package.henanmj.model.model_data")

    UnityEngine.Application.targetFrameRate = 30
    GameManager.set_client_asset_version()
    GameManager.developmentMode = ModuleCache.GameConfigProject.developmentMode
    GameManager.customPlatformName = ModuleCache.CustomerUtil.platform
    GameManager.gameConfigProjectHttpApiUrl = ModuleCache.GameConfigProject.httpApiUrl

    if GameManager.customPlatformName == "iOS" then
        GameManager.customOsType = 2
        GameManager.customPlatformName = "IPhonePlayer"
        GameManager.deviceIsMobile = true
    elseif GameManager.customPlatformName == "Windows" then
        GameManager.customOsType = 3
        --GameManager.developmentMode = true
    elseif GameManager.customPlatformName == "OSX" then
        GameManager.customOsType = 4
        --GameManager.developmentMode = true
    else
        GameManager.customOsType = 1
        GameManager.deviceIsMobile = true
    end

    GameManager.needCheckVersionData = true
    local runtimePlatform = tostring(UnityEngine.Application.platform)
    GameManager.runtimePlatform = runtimePlatform

    GameManager.isEditor = false
    if runtimePlatform == "OSXEditor" or runtimePlatform == "WindowsEditor" then
        GameManager.isEditor = true
        if ModuleCache.GameConfigProject.assetLoadType == 0 then
            GameManager.needCheckVersionData = false
            GameManager.deviceIsMobile = false
        end
    end

    GameManager.select_province_id(UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PROVINCE, 0))
    ModuleCache.WechatManager._onGetIpsByHttpDNSResult = function(ipList)
        GameManager.set_net_adress(ipList)
    end
    GameManager.set_upgrade_net_adres()
    GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))

    local t = typeof('UnityEngine.SystemInfo')
    local property = tolua.getproperty(t, 'deviceModel')

    GameManager.deviceModel = property:Get(nil, nil)
    GameManager.isiPhoneX = GameManager.deviceModel ~= "iPhone10,3"
    local user = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "noUser")
    GameManager.isFirstInGame = UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 0) == 0
    GameManager.lockAssetUpdate = UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_LOCK_ASSET, 0) == 1


    if not GameManager.isFirstInGame then
        if GameManager.curGameId ~= 0 and GameManager.curProvince ~= 0 then
            UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 1)
            GameManager.isFirstInGame = false
        end
    end
    --GameManager.get_mw_data("%7b%22parlorId%22%3a%220%22%2c%22ruleMsg%22%3a%228%e5%b1%80%204%e4%ba%ba%e7%8e%a9%e6%b3%95%20%e5%ba%84%e5%ae%b6%e5%b8%a6%202%e9%a9%ac%20%e5%8a%a0%e9%a9%ac%202%e9%a9%ac%20%e9%a9%ac%e8%b7%9f%e6%9d%a0%20%e5%b0%81%e9%a1%b6%2010%e9%a9%ac%20AA%e6%94%af%e4%bb%98%20%22%2c%22local%22%3a%22%e6%99%ae%e5%ae%81%e5%ae%a2%e5%ae%b6%22%2c%22gameName%22%3a%22DHGDQP_PNMJ%22%2c%22roomType%22%3a0%2c%22roomId%22%3a%22771463%22%2c%22type%22%3a2%7d")
end

function GameManager.getCurGameId()
    local provinceId = GameManager.getCurProvinceId()
    local province = ModuleCache.PlayModeUtil.getProvinceById(provinceId)
    local gameId = UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE .. "_" .. province.gameName, 0)
    -- 湖北大冶的玩法全部转到黄石市下
    if provinceId == 10 then
        if gameId == 201 then
            gameId = 302
        elseif gameId == 202 then
            gameId = 303
        elseif gameId == 701 then
            gameId = 201
        end
    end
    return gameId
end

function GameManager.getCurProvinceId()
    return UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PROVINCE, 0)
end

-- 设置GameManager中的Server_Host，这是游戏中真正用于请求的ip
function GameManager.set_server_host()
    if not AppData.ServerHostData then
        return
    end
    if GameManager.deviceIsMobile and UnityEngine.PlayerPrefs.GetInt(ModuleCache.AppData.USE_TEST_DEVELOP_MOD, 0) > 0 then
        ModuleCache.GameConfigProject.developmentMode = true
        GameManager.developmentMode = true
        GameManager.isTestUser = true
        if UnityEngine.PlayerPrefs.GetInt(ModuleCache.AppData.USE_TEST_DEVELOP_MOD, 0) == 2 and AppData.ServerHostData.test2 then
            GameManager.Server_Host = AppData.ServerHostData.test2
        else
            GameManager.Server_Host = AppData.ServerHostData.test
        end
    else
        if ModuleCache.GameConfigProject.developmentMode and string.find(GameManager.gameConfigProjectHttpApiUrl, "test") == 1 then
            if UnityEngine.PlayerPrefs.GetInt(ModuleCache.AppData.USE_TEST_DEVELOP_MOD, 0) == 2 and AppData.ServerHostData.test2 then
                GameManager.Server_Host = AppData.ServerHostData.test2
            else
                GameManager.Server_Host = AppData.ServerHostData.test
            end
            GameManager.isTestUser = true
        else
            local playGameCount = UnityEngine.PlayerPrefs.GetInt(ModuleCache.AppData.PLAYER_PREFS_KEY_PLAYGAMECOUNT .. ModuleCache.AppData.App_Name, 0)
            -- 加起来小局数超过
            if playGameCount > 100 then
                GameManager.Server_Host = AppData.ServerHostData.vip
            else
                GameManager.Server_Host = AppData.ServerHostData.api
            end
        end
    end
end

--- 获取Upgrade升级的专用地址
function GameManager.set_upgrade_net_adres(forceUserTestUrl)
    local url = nil
    if GameManager.deviceIsMobile and UnityEngine.PlayerPrefs.GetInt(ModuleCache.AppData.USE_TEST_DEVELOP_MOD, 0) == 1 then
        url = AppData.Server_Host_Datas[string.lower(AppData.Const_App_Name)].test
    else
        if ModuleCache.GameConfigProject.developmentMode and (forceUserTestUrl or string.find(GameManager.gameConfigProjectHttpApiUrl, "test.") == 1) then
            url = AppData.Server_Host_Datas[string.lower(AppData.Const_App_Name)].test
        else
            url = AppData.Server_Host_Datas[string.lower(AppData.Const_App_Name)].api
        end
    end

    local newServerHost = ModuleCache.GameSDKInterface:GetIpsByHttpDNS(url)
    local dataList = ModuleCache.GameUtil.split(newServerHost, ',')
    GameManager.netAdress.appUpgradeHttpCurApiUrl = "http://" .. dataList[math.random(1, #dataList)] .. ":8080/" .. AppData.App_Upgrade_Net_Url_Root_Directory .. "/api/"

end

--- 并发获取可用的IP地址
function GameManager.get_and_set_net_adress()
    local newServerHost = ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host)
    GameManager.set_net_adress(newServerHost)
    local dataList = ModuleCache.GameUtil.split(newServerHost, ',')
    for i, v in ipairs(dataList) do
        dataList[i] = "http://" .. v .. ":8080/" .. AppData.Net_Url_Root_Directory .. "/api/ping?" .. v
    end

    ModuleCache.WWWUtil.GetConcurrence(dataList, 3, function(data)
        print(data.text, "最快的反馈")

        if string.sub(data.text, 1, 1) ~= "{" then
            GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))
            return
        end

        local retData = ModuleCache.Json.decode(data.text)
        if retData and retData.ret == 0 then
            GameManager.set_net_adress(retData.data)
        end
    end, function(error)
        print(error.error)
        GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))
    end)
end


--- 获取基准分辨率， 返回width,height
function GameManager.get_basis_screen_resolution()
    if not GameManager.basis_screen_resolution then
        GameManager.basis_screen_resolution = {}
        --        LuaHelper.GetComponentWithPath(view.gameObject, "Player/DefaultHead", IMAGE)
        local canvasSizeDelta = ModuleCache.ComponentManager.GetComponentWithPath(UnityEngine.GameObject.Find("GameRoot"), "Lobby/UIRoot/UIWindowParent/Canvas", ComponentTypeName.RectTransform).sizeDelta
        local math = math
        GameManager.basis_screen_resolution.width = math.ceil(canvasSizeDelta.x)
        GameManager.basis_screen_resolution.height = math.ceil(canvasSizeDelta.y)
    end
    return GameManager.basis_screen_resolution
end

function GameManager.set_client_asset_version()
    local platform = ModuleCache.CustomerUtil.platform
    local appAssetVersion
    local appInternalAssetVersion = 0
    local text = ModuleCache.GameSDKInterface:ReadFileFromeAssets(ModuleCache.FileUtility.EncryptFilePath(platform .. "/AssetDataBytes/version.txt"))
    print("app内置资源版本号", text)
    appInternalAssetVersion = tonumber(text)
    appAssetVersion = appInternalAssetVersion or 0
    GameManager.appInternalAssetVersion = appAssetVersion
    local file, error = io.open(ModuleCache.AppData.ASSETS_DATA_ROOT .. "version.txt")
    if file then
        local persistentAssetVersion = file:read("*n")
        file:close()
        if persistentAssetVersion >= appInternalAssetVersion then
            appAssetVersion = persistentAssetVersion
        else
            print("app包中的资源比磁盘中的资源要新，需要把磁盘中的资源删除掉", appInternalAssetVersion)
            ModuleCache.FileUtility.DirectoryDelete(ModuleCache.AppData.ASSETS_DATA_ROOT, true)
        end
        print("本地资源版本号", persistentAssetVersion)
    else
        print("磁盘中不存在version.txt：", error)
    end
    GameManager.appAssetVersion = appAssetVersion
end


-- 账号注销
function GameManager.logout(clearCacheAccount)
    if clearCacheAccount then
        UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
    end
    GameManager.isLogout = true
    -- 暂时先屏蔽掉
     ModuleCache.JMsgManager.clean()
    ModuleCache.net.NetClientManager.disconnect_all_client()
    ModuleCache.ModuleManager.destroy_public_package(true)
    for k,v in pairs(AppData.allPackageConfig) do
        ModuleCache.ModuleManager.destroy_package(v.package_name)
    end
    ModuleCache.ModuleManager.show_module("henanmj", "login")

end

-- 重启游戏
function GameManager.reboot(clearAllDownloadAsset)
    if clearAllDownloadAsset then
        ModuleCache.FileUtility.DirectoryDelete(ModuleCache.AppData.ASSETS_DATA_ROOT, true)
    end

    print("游戏内部重启")
    --return
    local uiCamera = ModuleCache.ComponentUtil.Find(GameObject.Find("GameRoot"), "Game/UIRoot/UICamera")
    if not uiCamera then
        uiCamera = ModuleCache.ComponentUtil.Find(GameObject.Find("GameRoot"), "Public/UIRoot/UICamera")
    end
    uiCamera:SetActive(false)
    -- GameObject.Find("GameRoot"):SetActive(false)
    ModuleCache.AssetBundleManager:Reset(true)  --清空所有的值
    ModuleCache.AssetBundleManager:Initialize() -- 必须要初始化才能再次使用
    local asset = ModuleCache.AssetBundleManager:LoadAssetBundle("public/ui/init/gamelauncher.bytes"):GetAsset("GameLauncher", false)
    local gameLauncher = ModuleCache.ComponentUtil.InstantiateLocal(asset)
    gameLauncher.name = "GameLauncher"
    GameObject.DontDestroyOnLoad(gameLauncher);
    ModuleCache.CustomerUtil.ReloadCurScene()
end

-- 选择游戏玩法
function GameManager.select_game_id(gameID)
    if AppData.App_Name == "DHAMQP" then  --澳门金币场不保存本地
        GameManager.select_game_id_not_record(gameID)
    else
        local playMode = ModuleCache.PlayModeUtil.getInfoByGameId(gameID)

        if(AppData.App_Name == "DHAHQP" and playMode) then
            AppData.select_province_id(AppData.App_Name, playMode.gameName)
            GameManager.set_server_host()
            if GameManager.Server_Host then
                GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))
            end
        end

        if gameID == 0 then
            gameID = 1
        else
            if (GameManager.curProvince > 0) then
                local province = ModuleCache.PlayModeUtil.getProvinceById(GameManager.curProvince)
                UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE .. "_" .. province.gameName, gameID)
                local user = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "noUser")
                local isFirst = UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 0) == 0
                if isFirst then
                    UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 1)
                    GameManager.isFirstInGame = false
                end
            end
        end

        ---@field curGameId @comment 当前选择的游戏id
        GameManager.curGameId = gameID

        if (playMode == nil) then
            UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE, 0)
            GameManager.curProvince = 0
            GameManager.curGameId = 0
            GameManager.curLocation = 1
            return nil
        end

        GameManager.curLocation = playMode.location
        AppData.Game_Name = playMode.gameName  -- AppData.Game_Names[gameID]
    end
end

-- 选择游戏玩法
function GameManager.select_game_id_not_record(gameID)
    local playMode = ModuleCache.PlayModeUtil.getInfoByGameId(gameID)
    if gameID == 0 then
        gameID = 1
    end
    ---@field curGameId @comment 当前选择的游戏id
    GameManager.curGameId = gameID
    if (playMode == nil) then
        UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE, 0)
        GameManager.curProvince = 0
        GameManager.curGameId = 0
        GameManager.curLocation = 1
        return nil
    end
    GameManager.curLocation = playMode.location
    AppData.Game_Name = playMode.gameName  -- AppData.Game_Names[gameID]
end

function GameManager.get_cur_package_version()
    local packageName = ModuleCache.PlayModeUtil.getInfoByGameId(GameManager.curGameId)
    if packageName then
        packageName = packageName.package
    end

    if packageName then
        return ModuleCache.PackageManager.get_cur_package_version(packageName)
    end

    return nil
end


-- 获取当前玩法数据
function GameManager.get_cur_playmodel_config_info()
    return ModuleCache.PlayModeUtil.getInfoByGameId(GameManager.curGameId)
end



-- 选择身份
function GameManager.select_province_id(provinceId)
    if provinceId == 12 then  --澳门金币场不保存本地
        GameManager.select_province_id_not_record(provinceId)
    else
        GameManager.curProvince = provinceId
        if (provinceId == 0) then
            provinceId = 1
        else
            UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PROVINCE, provinceId)
        end
        ModuleCache.PlayModeUtil.setCurConfig(provinceId)
        local province = ModuleCache.PlayModeUtil.getProvinceById(provinceId)
        if (GameManager.iosAppStoreIsCheck) then
            GameManager.select_game_id(UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE .. "_" .. province.gameName, 1))
        else
            GameManager.select_game_id(UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE .. "_" .. province.gameName, 0))--updatePlayModeId))
        end
        AppData.select_province_id(province.appName, AppData.Game_Name)
        GameManager.set_server_host()
        if GameManager.Server_Host then
            GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))
        end
    end
end


-- 选择身份
function GameManager.select_province_id_not_record(provinceId)
    GameManager.curProvince = provinceId
    if (provinceId == 0) then
        provinceId = 1
    end
    ModuleCache.PlayModeUtil.setCurConfig(provinceId)
    local province = ModuleCache.PlayModeUtil.getProvinceById(provinceId)
    AppData.select_province_id(province.appName, AppData.Game_Name)
    GameManager.set_server_host()
    if GameManager.Server_Host then
        GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))
    end

end


function GameManager.change_game_buy_appName_gameName(appName, gameName)
    print(appName .. gameName)
    local provinceConf = ModuleCache.PlayModeUtil.getProvinceByAppName(appName)
    local playModeConf  = ModuleCache.PlayModeUtil.getDeepCopyTable(require(provinceConf.modName))
    local playMode = ModuleCache.PlayModeUtil.getInfoByGameName(gameName,playModeConf)
    GameManager.select_province_id(provinceConf.id)
    GameManager.select_game_id(playMode.gameId)
    return true
end



-- 主动变更游戏玩法
-- gameName: 游戏名  如：池州市-CZMJ
-- name: 玩法名 如: 青阳辣子
-- notChangeAppName 不切换App
function GameManager.change_game_by_gameName(creatName, notChangeAppName)
    print("change_game_by_gameName == ", creatName)
    local appNameStrs = string.split(creatName, "_")
    local appNewConfig = ModuleCache.PlayModeUtil.getPlayModeConfigByAppName(appNameStrs[1])
    local playModeData = ModuleCache.PlayModeUtil.get_playmodel_data_poker(creatName, appNewConfig)
    if not playModeData then
        appNewConfig = ModuleCache.PlayModeUtil.getPlayModeConfigByAppName("DHAHQP")
        playModeData = ModuleCache.PlayModeUtil.get_playmodel_data_poker(creatName, appNewConfig)
    end
    --TODO 江苏南通长牌改名，特别处理
    if not playModeData and creatName == "DHJSQP_NTCP_NT" then
        creatName = "DHJSQP_NTCP"
        appNameStrs = string.split(creatName, "_")
        appNewConfig = ModuleCache.PlayModeUtil.getPlayModeConfigByAppName(appNameStrs[1])
        playModeData = ModuleCache.PlayModeUtil.get_playmodel_data_poker(creatName, appNewConfig)
    end

    local appName = appNameStrs[1]
    local curAppName = appName
    local needLogout = false
    if(appName ~= "DHAHQP" and (string.find(appName,"WJMJ") ~= nil or string.find(appName,"LAMJ") ~= nil or string.find(appName,"DHWBMJ") ~= nil)) then
        appName = "DHAHQP"
        needLogout = true
        notChangeAppName = true
    end
    if (not notChangeAppName) then
        local isbool = false
        local province
        for i = 1, #ModuleCache.PlayModeUtil.provinceConfig.provinceList do
            if (ModuleCache.PlayModeUtil.provinceConfig.provinceList[i] and ModuleCache.PlayModeUtil.provinceConfig.provinceList[i].appName == appName) then
                UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_LAST .. "_" .. ModuleCache.PlayModeUtil.provinceConfig.provinceList[i].gameName, ModuleCache.GameManager.curGameId)
                UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE .. "_" .. ModuleCache.PlayModeUtil.provinceConfig.provinceList[i].gameName, 0)
                ModuleCache.GameManager.select_province_id(ModuleCache.PlayModeUtil.provinceConfig.provinceList[i].id)
                province = ModuleCache.PlayModeUtil.provinceConfig.provinceList[i]
                isbool = true
            end
        end
        if(appName == "DHAHQP") then
            AppData.select_province_id(appName, appNameStrs[2])
            GameManager.set_server_host()
            if GameManager.Server_Host then
                GameManager.set_net_adress(ModuleCache.GameSDKInterface:GetIpsByHttpDNS(GameManager.Server_Host))
            end
            isbool = true
        end
        if (not isbool) then
            return false
        end
        local config = ModuleCache.PlayModeUtil.getInfoByGameNameAndName(playModeData.gameName, playModeData.name)
        GameManager.curGameId = config.gameId
        GameManager.curLocation = config.location
        AppData.Game_Name = config.gameName
        UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE .. "_" .. province.gameName, ModuleCache.GameManager.curGameId)
        -- config.gameName写死吧，等以后有多套中继服了再
        --AppData.Net_Url_Root_Directory = string.lower(AppData.App_Name .. "/" .. config.gameName)
        return true
    else
        local config = ModuleCache.PlayModeUtil.getInfoByGameNameAndName(playModeData.gameName, playModeData.name)
        GameManager.curGameId = config.gameId
        GameManager.curLocation = config.location
        AppData.Game_Name = config.gameName
        return true
    end
end


function GameManager.set_net_adress(ipList)
    local dataList = ModuleCache.GameUtil.split(ipList, ',')
    if (not dataList) then
        return
    end
    local ip = dataList[1]
    GameManager.netAdress.curServerHostIp = ip .. ":8080/" .. AppData.Net_Url_Root_Directory .. "/"
    GameManager.netAdress.httpCurApiUrl = "http://" .. ip .. ":8080/" .. AppData.Net_Url_Root_Directory .. "/api/"
end

function GameManager.set_conmmon_net_adress(ipList)
    local dataList = ModuleCache.GameUtil.split(ipList, ',')
    if (not dataList) then
        return
    end
    local ip = dataList[1]
    GameManager.netAdress.curServerHostIp = ip .. ":8080/" .. AppData.Net_Url_Root_Directory .. "/"
    GameManager.netAdress.httpCurApiUrl = "http://" .. ip .. ":8080/" .. AppData.Net_Url_Root_Directory .. "/api/"
end

--==============================--
--desc:获取版本升级数据
--time:2017-04-26 11:34:34
--@wwwData:
--@wwwDataError:
--return
--==============================--
function GameManager.get_app_upgrade_info(sucessCallback, errorCallback, showNetprompt)
    local requestData = {
        baseUrl = GameManager.netAdress.appUpgradeHttpCurApiUrl .. "upgrade/getAppUpgradeInfo?",
        showModuleNetprompt = showNetprompt,
        notRequiredToken = true,
        params = {
            osType = GameManager.customOsType,
            appVer = GameManager.appVersion,
            -- appVer = "1.0.0",
            gameName = ModuleCache.AppData.Get_App_Upgrade_Info_Url_Game_Name,
            sv = 1,
            bundleID = UnityEngine.Application.identifier,
            uid = UnityEngine.PlayerPrefs.GetString(AppData.PLAYER_PREFS_KEY_USERID, "0"),
            platformName = GameManager.customPlatformName,
            channelName = "none",
            assetVersion = GameManager.appAssetVersion
        },
        cacheDataKey = "httpcache:upgrade/getAppUpgradeInfo?"
    }

    local sucessHttpGet = function(wwwBytes)
        local retData  = ModuleCache.SecurityUtil.DESDecode(wwwBytes, AppData.DESKey)
        retData = ModuleCache.Json.decode(retData)
        print_table(retData)
        if retData.success then
            if not ModuleCache.GameManager.lockAssetUpdate and retData.map and retData.map.assetVersion and retData.map.assetVersion.updateContent then
                if not ModuleCache.GameManager.iosAppStoreIsCheck then
                    ModuleCache.FileUtility.SaveFile(ModuleCache.AppData.ASSETS_DATA_ROOT.."package.txt",retData.map.assetVersion.updateContent)
                    ModuleCache.PackageManager.set_package_asset_data(retData.map.assetVersion.updateContent)
                end
            end
            GameManager._set_app_asset_version_update_data(retData.map)
        end
        if sucessCallback then
            sucessCallback(retData)
        end
    end


    Util.http_get(requestData, function(wwwData)
        sucessHttpGet(wwwData.www.text)
    end, function(wwwErrorData)
        -- 如果获取失败那么就自动切
        GameManager.get_and_set_net_adress()
        if errorCallback then
            errorCallback(wwwErrorData.error)
        end
    end, function(cacheDataText)
        -- 如果本地有缓存数据，使用缓存数据
        GameManager.get_and_set_net_adress()
        sucessHttpGet(cacheDataText)
    end)
end


-- 单独获取版本资源
function GameManager.get_app_asset_data_info(sucessCallback, errorCallback)
    if GameManager.iosAppStoreIsCheck then
        GameManager.appAssetVersionUpdateData.appData = nil
        GameManager.appAssetVersionUpdateData.assetData = nil
        return
    end

    GameManager.get_app_upgrade_info(function(wwwData)
        if wwwData.success == true then
            if sucessCallback then
                sucessCallback(GameManager.appAssetVersionUpdateData)
            end
        else
            -- GameManager.get_app_asset_data_info()
        end
    end, function(wwwDataError)
        if errorCallback then
            errorCallback(wwwDataError)
        end
    end, false)
end


-- 设置版本更新信息
function GameManager._set_app_asset_version_update_data(data)
    if not ModuleCache.CustomerUtil.VersionCompare(GameManager.appVersion, data.version) then
        print("data.forceUpgrade", data.forceUpgrade, GameManager.appVersion, data.version)
        GameManager.appAssetVersionUpdateData.appData = {
            forceUpgrade = data.forceUpgrade,
            url = data.url,
            serverAppVersion = data.version,
            versionDesc = data.versionDesc
        }
    else
        GameManager.appAssetVersionUpdateData.appData = nil
    end

    if not ModuleCache.GameManager.lockAssetUpdate and data.assetVersion then
        GameManager.appAssetVersionUpdateData.assetData = {}
        GameManager.appAssetVersionUpdateData.assetData.isForceUpdate = data.assetVersion.isForceUpdate
    else
        GameManager.appAssetVersionUpdateData.assetData = nil
    end
    --    GameManager.appAssetVersionUpdateData.assetData = {}
    --    GameManager.appAssetVersionUpdateData.assetData.isForceUpdate = false
    --end

    ---- 需要判断服务器资源版本号是否大于本地资源版本号
    --if not ModuleCache.GameManager.lockAssetUpdate and data.assetVersion and data.assetVersion.serverAssetVersion > GameManager.appAssetVersion then
    --    local downloadFileData = {}
    --    downloadFileData.isForceUpdate = data.assetVersion.isForceUpdate
    --    if ModuleCache.GameManager.appAssetVersion == data.assetVersion.preAssetVersion then
    --        downloadFileData.filePath = data.assetVersion.incrementalFilePath
    --        downloadFileData.fileName = "incremental.pkg"
    --        downloadFileData.fileSize = data.assetVersion.incrementalFileSize
    --    else
    --        downloadFileData.filePath = data.assetVersion.wholeFilePath
    --        downloadFileData.fileName = "whole.pkg"
    --        downloadFileData.fileSize = data.assetVersion.wholeFileSize
    --    end
    --
    --    downloadFileData.packages = data.assetVersion.updateContent
    --    GameManager.appAssetVersionUpdateData.assetData = downloadFileData
    --else
    --    GameManager.appAssetVersionUpdateData.assetData = nil
    --end
end

---获取魔窗数据
---@param text table
function GameManager.get_mw_data()
    local text = ModuleCache.GameSDKCallback.instance.mwEnterRoomID
    if (not text or text == "0") then
        return GameManager.get_mw_data_by_Clipboard()
    end
    local mwData
    if string.lower(string.sub(text, 1, 1) ) == "{" then
        mwData = Util.json_decode_to_table(text)
        if mwData.appGameName then
            local strs = string.split(mwData.appGameName, "_")
            mwData.appName = strs[1]
            mwData.gameName = strs[2]
        end
    else
        mwData = {}
        mwData.roomId = tonumber(text)
    end

    if string.find(text, "GPS检测") then
        mwData.NeedOpenGPS = true
    end

    if string.find(text, "相同IP检测") then
        mwData.CheckIPAddress = true
    end

    print_table(mwData, "get_mw_data")
    return mwData
end

-- 通过剪切版转换数据
function GameManager.get_mw_data_by_Clipboard()
    local text = ModuleCache.GameSDKInterface:GetTextFromClipboard()
    if (not text or text == "" or not string.find(text, ModuleCache.UnityEngine.Application.productName)) then
        return nil
    end

    text = string.split(text, "#")
    if #text ~= 3 then
        return nil
    end

    local mwData = {}
    local tmpContent = string.split(ModuleCache.GameUtil.decodeBase64(text[2]), "_")
    mwData.appName = tmpContent[1]
    mwData.gameName = tmpContent[2]

    if string.find(text[1], "GPS检测") then
        mwData.NeedOpenGPS = true
    end

    if string.find(text[1], "相同IP检测") then
        mwData.CheckIPAddress = true
    end

    mwData.roomId = tonumber(string.match(text[1], '%d%d%d%d%d%d'))
    print_table(mwData, "get_mw_data_by_Clipboard")
    return mwData
end



function GameManager.close_print()
    GameManager.print_toggle_data.print = print
    GameManager.print_toggle_data.print_table = print_table
    GameManager.print_toggle_data.print_debug = print_debug
    GameManager.print_toggle_data.print_traceback = print_traceback
    GameManager.print_toggle_data.print_pbc_table = print_pbc_table
    print = function( ... )
    end
    print_table = function( ... )
    end
    print_debug = function( ... )
    end
    print_traceback = function( ... )
    end
    print_pbc_table = function( ... )
    end
end

function GameManager.open_print()
    if not GameManager.print_toggle_data.print then
        return
    end
    ModuleCache.GameConfigProject.netTransferDataShow = true
    print = GameManager.print_toggle_data.print
    print_table = GameManager.print_toggle_data.print_table
    print_debug = GameManager.print_toggle_data.print_debug
    print_traceback = GameManager.print_toggle_data.print_traceback
    print_pbc_table = GameManager.print_toggle_data.print_pbc_table
end

function GameManager.get_used_playMode()
    local usedJson =  UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_USED_PLAYMODE, "noUsed")
    if usedJson == "noUsed" then
        return nil
    end
    return ModuleCache.Json.decode(usedJson)
end

function GameManager.set_used_playMode(provinceId, gameId)
    if not provinceId or not gameId then
        provinceId = GameManager.curProvince
        gameId = GameManager.curGameId
    end
    if provinceId == 12 then
        return 
    end
    --print("--------start set use play mode----------")
    --print("provinceId = "..provinceId)
    local tb = GameManager.get_used_playMode()
    if not tb then
        tb = {}
    end
    --print("last store ")
    --print_table(tb)
    local temp = {}
    local simpleTb = nil
    for i = 1, #tb do
        --print("i = "..i)
        --print("tb[i].provinceId = "..tb[i].provinceId)
        --print("tb[i].gameId = "..tb[i].gameId)
        if tb[i].provinceId == provinceId and tb[i].gameId == gameId then
            simpleTb = tb[i]
            --print("set simpleTb")
            break
        end
    end
    if simpleTb then
        --print("simple start ")
        for i = 1, #tb do
            local lTemp = tb[i]
            if i > 1 then
                tb[i] = temp
            else
                tb[i] = simpleTb
            end
            temp = lTemp
            --print("i = "..i)
            --print_table(tb)
        end
    else
        --print("no simple start ")
        for i = 1, 3 do
            local lTemp = {}
            if tb[i] then
                lTemp = tb[i]
            else
                lTemp.provinceId = provinceId
                lTemp.gameId = gameId
            end

            if i > 1 then
                tb[i] = temp
            else
                --print(" i <= 1")
                tb[i] = {}
                tb[i].provinceId = provinceId
                tb[i].gameId = gameId
            end
            temp = lTemp
            --print("i = "..i)
            --print_table(tb)
        end
    end


    local json = ModuleCache.Json.encode(tb)

    print("---------存储的常用玩法为: "..json)
    UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_USED_PLAYMODE, json)
end

function GameManager.encodeRoomId(roomId)
    local encodeId = ""
    local str = tostring(roomId)
    print("str = "..str)
    print("#str = "..#str)
    for i = 1,6 do
        local  num = string.sub(str,i,i)
        if     num == "1" then encodeId = encodeId.."Q"
        elseif num == "2" then encodeId = encodeId.."w"
        elseif num == "3" then encodeId = encodeId.."E"
        elseif num == "4" then encodeId = encodeId.."M"
        elseif num == "5" then encodeId = encodeId.."Z"
        elseif num == "6" then encodeId = encodeId.."p"
        elseif num == "7" then encodeId = encodeId.."j"
        elseif num == "8" then encodeId = encodeId.."l"
        elseif num == "9" then encodeId = encodeId.."T"
        end
    end
    print("encodeId = "..encodeId)
    return encodeId
end

function GameManager.decodeRoomId(str)
    local decodeId = ""
    print(str)
    for i = 1,6 do
        local  num = string.sub(str,i,i)
        print("Num = "..num)
        if     num == "Q" then decodeId = decodeId.."1"
        elseif num == "w" then decodeId = decodeId.."2"
        elseif num == "E" then decodeId = decodeId.."3"
        elseif num == "M" then decodeId = decodeId.."4"
        elseif num == "Z" then decodeId = decodeId.."5"
        elseif num == "p" then decodeId = decodeId.."6"
        elseif num == "j" then decodeId = decodeId.."7"
        elseif num == "l" then decodeId = decodeId.."8"
        elseif num == "T" then decodeId = decodeId.."9"
        end
    end
    print("decodeId = " ..decodeId)
    if #decodeId < 6 then
        return "0000001"
    end
    return decodeId
end

function GameManager.player_switch_majiang3D()
    local GameID = AppData.get_app_and_game_name()
    local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
    local Is3D = Config.get_mj3dSetting(GameID).Is3D
    local def3dOr2d = Config.get_mj3dSetting(GameID).def3dOr2d
    local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d", gameType)
    local curSetting = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
    if 1 == Is3D and 1 == curSetting then
        return true
    end
    return false
end

GameManager.init()
return GameManager