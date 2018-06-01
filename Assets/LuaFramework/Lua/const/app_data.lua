local string = string
AppData = { }
local AppData = AppData

AppData.Server_Host_Datas = {
    -- 安徽
    dhahqp =
    {
        test = "test.dhahqp.sincebest.com",
        test2 = "test.dhanhuiqp.sincebest.com",
        api = "api.dhahqp.sincebest.com",
        vip = "vip.dhahqp.sincebest.com",
        defaultGameName = "hzmj"
    },

    -- 河南、中原
    dhzyqp =
    {
        test = "test.dhzyqp.sincebest.com",
        api = "api.dhzyqp.sincebest.com",
        vip = "vip.dhzyqp.sincebest.com",
        defaultGameName = "dzmj"
    },

    -- 江苏
    dhjsqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhjsqp.sincebest.com",
        vip = "vip.dhjsqp.sincebest.com",
        defaultGameName = "bullfight"
    },

    -- 广东
    dhgdqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhgdqp.sincebest.com",
        vip = "vip.dhgdqp.sincebest.com",
        defaultGameName = "bullfight",
    },

    -- 陕西
    dhsxqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhsxqp.sincebest.com",
        vip = "vip.dhsxqp.sincebest.com",
        defaultGameName = "bullfight"
    },

    -- 云南
    dhynqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhynqp.sincebest.com",
        vip = "vip.dhynqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 湖南
    dhhnqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhhnqp.sincebest.com",
        vip = "vip.dhhnqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 湖北
    dhhubeiqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhhubeiqp.sincebest.com",
        vip = "vip.dhhubeiqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 广州
    dhgzqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhgzqp.sincebest.com",
        vip = "vip.dhgzqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 广西
    dhgxqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhgxqp.sincebest.com",
        vip = "vip.dhgxqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 新疆
    dhxjqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhxjqp.sincebest.com",
        vip = "vip.dhxjqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 六安
    dhlamj =
    {
        test = "test.dhlamj.sincebest.com",
        api = "api.dhlamj.sincebest.com",
        vip = "vip.dhlamj.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 安庆
    dhaqmj =
    {
        test = "test.dhaqmj.sincebest.com",
        api = "api.dhaqmj.sincebest.com",
        vip = "vip.dhaqmj.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 皖北
    dhwbmj =
    {
        test = "test.dhwbmj.sincebest.com",
        api = "api.dhwbmj.sincebest.com",
        vip = "vip.dhwbmj.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 澳门
    dhamqp =
    {
        test = "test.dhamqp.sincebest.com",
        api = "api.dhamqp.sincebest.com",
        vip = "vip.dhamqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 江西
    dhjxqp =
    {
        test = "test.dhjxqp.sincebest.com",
        api = "api.dhjxqp.sincebest.com",
        vip = "vip.dhjxqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    -- 江西
    dhshxqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhshxqp.sincebest.com",
        vip = "vip.dhshxqp.sincebest.com",
        defaultGameName = "bullfight"
    },
    dhgsqp =
    {
        test = "test.dhahqp.sincebest.com",
        api = "api.dhgsqp.sincebest.com",
        vip = "vip.dhgsqp.sincebest.com",
        defaultGameName = "bullfight"
    },
}

AppData.Const_App_Name = "DHGDQP"
AppData.Const_App_Bundle_ID = "DHQGQPBID"

-- 用于检测是否有升级信息
AppData.Get_App_Upgrade_Info_Url = nil
AppData.Get_App_Upgrade_Info_Url_Game_Name = "DHGDQP_RUNFAST"
AppData.App_Upgrade_Net_Url_Root_Directory = "dhgdqp/bullfight"

AppData.ServerHostData = nil
AppData.CommonServerHostData = AppData.Server_Host_Datas
AppData.Common_Net_Url_Root_Directory = "dhahqp/bullfight"
AppData.App_Name = AppData.Const_App_Name
-- 游戏名
AppData.Game_Name = nil


AppData.GVoiceCloudID = "1009944782"
AppData.GVoiceCloudKey = "774efff9a827a9ed851bce91b8c4c876"



AppData.Biji_GameName = AppData.App_Name .. "_BIJI_BJ"
AppData.Runfast_GameName = AppData.App_Name .. "_RUNFAST_RUNFAST"
AppData.ZhaJinHua_GameName = AppData.App_Name .. "_ZHAJINHUA_ZHAJINHUA"
AppData.CowBoy_GameName = AppData.App_Name .. "_BULLFIGHT_BF"
AppData.GuanDan_GameName = AppData.App_Name .. "_GUANDAN_GD"
AppData.DouDiZhu_GameName = AppData.App_Name .. "_DOUDIZHU_DOUDIZHU"


-- 微信ID，Android，ios在游戏中调用
AppData.WECHAT_APPID = "wxc447c56c56f0ddde"
-- AppData.WECHAT_APPID = "wx0a7f5f39ad3e8c5d"
AppData.WECHAT_APPSECRET = ""
-- 是否由客户端获取UNIONID
AppData.OPEN_CLIENT_GET_UNIONID = false

-- Appstore充值
AppData.AppStoreProductName = "dhqpyx_1"

AppData.MuseumName = "亲友圈"

AppData.tableTargetFrameRate = 42


-- 不常改变数据
AppData.DESKey = "15880288"
AppData.SALT_A = "SbtATxjoo989000x*29lyp"
AppData.SALT_B = "SbtB009XVVWDVLXX89#S)X"

AppData.PLAYER_PREFS_KEY_OpenDevelopmentMode = "PlayerPrefs_OpenDevelopmentMode"
AppData.PLAYER_PREFS_KEY_ACCOUNT = "PlayerPrefs_Login_AccountName"
AppData.PLAYER_PREFS_KEY_PASSWORD = "PlayerPrefs_Login_Password"
AppData.PLAYER_PREFS_KEY_USERID = "PlayerPrefs_Login_USERID"
AppData.PLAYER_PREFS_KEY_PLAY_MODE = "PlayerPrefs_Play_Mode"
AppData.PLAYER_PREFS_KEY_PLAY_MODE_LAST = "PlayerPrefs_Play_Mode_Last"
AppData.PLAYER_PREFS_KEY_PROVINCE = "PlayerPrefs_Province"
AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET = "PlayerPrefs_Play_Mode_set"
AppData.PLAYER_PREFS_KEY_TOGGLE_USE_ACCOUNT = "PlayerPrefs_Login_ToggleUseACCOUNT"
AppData.PLAYER_PREFS_KEY_PLAYGAMECOUNT = "PlayerPrefs_PlayGameCount_"
AppData.PLAYER_PREFS_KEY_USED_PLAYMODE = "PlayerPrefs_Used_Play_Mode"
AppData.PLAYER_PREFS_KEY_LOCK_ASSET = "PlayerPrefs_GameManager_Lock_Asset"
-- 是否使用测试模式
AppData.USE_TEST_DEVELOP_MOD = "USE_TEST_DEVELOP_MOD"
AppData.PLAYER_PREFS_KEY_LAST_HALL_OPEN_MODULE = "PLAYER_PREFS_KEY_LAST_HALL_OPEN_MODULE"
AppData.PLAYER_PREFS_KEY_LAST_PROVINCE_GAME = "PLAYER_PREFS_KEY_LAST_PROVINCE_GAME"

AppData.ASSETS_DOWNLOAD_ROOT = UnityEngine.Application.persistentDataPath .. "/temp/"
AppData.ASSETS_DATA_ROOT = UnityEngine.Application.persistentDataPath .. "/assetsdata/"

-- 跑得快分支名
AppData.BranchRunfastName = "runfast"
AppData.BranchZhaJinHuaName = "zhajinhua"
-- 掼蛋分支名
AppData.BranchGuanDanName = "guandan"
AppData.BranchDouDiZhuName = "doudizhu"
-- 长牌分支名
AppData.BranchChangPaiName = "changpai"
-- 扎金花分支名
AppData.BranchZhaJinHuaName = "zhajinhua"

AppData.allPackageConfig = {
    ['doudizhu'] = {
        package_name = 'doudizhu',
        table_module_name = 'doudizhu_table',
        is_skynet_framework = true,
        short_game_name = '_DOUDIZHU_DOUDIZHU',
        game_name = 'DOUDIZHU',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['guandan'] = {
        package_name = 'guandan',
        table_module_name = 'guandan_table',
        is_skynet_framework = true,
        short_game_name = '_GUANDAN_GD',
        game_name = 'GUANDAN',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['runfast'] = {
        package_name = 'runfast',
        table_module_name = 'tablerunfast',
        is_skynet_framework = true,
        short_game_name = '_RUNFAST_RUNFAST',
        game_name = 'RUNFAST',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['zhajinhua'] = {
        package_name = 'zhajinhua',
        table_module_name = 'table_zhajinhua',
        is_skynet_framework = true,
        short_game_name = '_ZHAJINHUA_ZHAJINHUA',
        game_name = 'ZHAJINHUA',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['biji'] = {
        package_name = 'biji',
        table_module_name = 'tablebiji',
        is_skynet_framework = true,
        short_game_name = '_BIJI_BJ',
        game_name = 'BIJI',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['cowboy'] = {
        package_name = 'cowboy',
        table_module_name = 'table',
        is_skynet_framework = true,
        short_game_name = '_BULLFIGHT_BF',
        game_name = 'BULLFIGHT',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['laoyancai'] = {
        package_name = 'laoyancai',
        table_module_name = 'table_laoyancai',
        is_skynet_framework = true,
        short_game_name = '_LAOYANCAI_LAOYANCAI',
        game_name = 'LAOYANCAI',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['baibazhang'] = {
        package_name = 'baibazhang',
        table_module_name = 'tablebaibazhang',
        is_skynet_framework = true,
        short_game_name = '_BAIBAZHANG_BBZ',
        game_name = 'BAIBAZHANG',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['shisanzhang'] = {
        package_name = 'shisanzhang',
        table_module_name = 'tableshisanzhang',
        is_skynet_framework = true,
        short_game_name = '_SHISANZHANG_SSZ',
        game_name = 'SHISANZHANG',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['henanmj'] = {
        package_name = 'henanmj',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['paohuzi'] = {
        package_name = 'paohuzi',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['changpai'] = {
        package_name = 'changpai',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['sangong'] = {
        package_name = 'sangong',
        table_module_name = 'table',
        is_skynet_framework = true,
        short_game_name = '_SANGONG_SANGONG',
        game_name = 'SANGONG',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['daigoutui'] = {
        package_name = 'daigoutui',
        table_module_name = 'table',
        is_skynet_framework = true,
        short_game_name = '_DAIGOUTUI_DAIGOUTUI',
        game_name = 'DAIGOUTUI',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['majiang'] = {
        package_name = 'majiang',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['majiang3d'] = {
        package_name = 'majiang3d',
        table_module_name = 'table3d',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['majiangshanxi'] = {
        package_name = 'majiangshanxi',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['majiangshanxi3d'] = {
        package_name = 'majiangshanxi3d',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
    ['wushik'] = {
        package_name = 'wushik',
        table_module_name = 'table',
        is_skynet_framework = true,
        short_game_name = '_WUSHIK_WUSHIK',
        game_name = 'WUSHIK',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },

	['huapai'] = {
        package_name = 'huapai',
        table_module_name = 'table',
        is_skynet_framework = false,
        short_game_name = '',
        game_name = '',
        get_full_game_name = function(t) return AppData.App_Name .. t.short_game_name end
    },
}


function AppData.select_province_id(appName, gameName)
    --print_debug("select_province_id：" .. appName)
    local lowerAppName = string.lower(appName or AppData.Const_App_Name)
    --if(lowerAppName == "dhahqp" and gameName ~= "LAMJ" and string.find(gameName, "LAMJ") ~= nil) then
    --    lowerAppName = "dhlamj"
    --end
    --if(lowerAppName == "dhahqp" and string.find(gameName, "WJMJ") ~= nil) then
    --    lowerAppName = "dhaqmj"
    --end
    --if(lowerAppName == "dhahqp" and string.find(gameName, "DHWBMJ") ~= nil) then
    --    lowerAppName = "dhwbmj"
    --end
    if not AppData.Server_Host_Datas[lowerAppName] then
        print("选择的省份不存在")
        return
    end

    AppData.App_Name = appName
    AppData.ServerHostData = AppData.Server_Host_Datas[lowerAppName]
    --print_table(AppData.ServerHostData)
    AppData.Net_Url_Root_Directory = string.lower(lowerAppName .. "/" .. AppData.ServerHostData.defaultGameName)
    if(lowerAppName == "dhlamj" or lowerAppName == "dhaqmj" or lowerAppName == "dhwbmj" ) then
        AppData.Net_Url_Root_Directory = lowerAppName
    end
    --print(AppData.Net_Url_Root_Directory)
    -- if appName == "DHGDQP" or appName == "DHJSQP" or appName == "DHZYQP" then
    --    appName = "DHAHQP"
    -- end
    -- 如果是连的测试服那就使用DHAHQP_
    AppData.Biji_GameName = appName .. "_BIJI_BJ"
    AppData.Runfast_GameName = appName .. "_RUNFAST_RUNFAST"
    AppData.ZhaJinHua_GameName = appName .. "_ZHAJINHUA_ZHAJINHUA"
    AppData.CowBoy_GameName = appName .. "_BULLFIGHT_BF"
    AppData.GuanDan_GameName = appName .. "_GUANDAN_GD"
    AppData.DouDiZhu_GameName = appName .. "_DOUDIZHU_DOUDIZHU"
    AppData.LaoYanCai_GameName = appName .. "_LAOYANCAI_LAOYANCAI"
    AppData.BaiBaZhang_GameName = appName .. "_BAIBAZHANG_BBZ"
    AppData.ShiSanZhang_GameName = appName .. "_SHISANZHANG_SSZ"
end

-- 设置poker系列的GameName，以避免在测试服需要部署多套服务器
function AppData.set_poker_gamename(testServer)
    local appName = AppData.App_Name
    if testServer then
        appName = "DHAHQP"
    end
    AppData.Biji_GameName = appName .. "_BIJI_BJ"
    AppData.Runfast_GameName = appName .. "_RUNFAST_RUNFAST"
    AppData.ZhaJinHua_GameName = appName .. "_ZHAJINHUA_ZHAJINHUA"
    AppData.CowBoy_GameName = appName .. "_BULLFIGHT_BF"
    AppData.GuanDan_GameName = appName .. "_GUANDAN_GD"
    AppData.DouDiZhu_GameName = appName .. "_DOUDIZHU_DOUDIZHU"
    AppData.LaoYanCai_GameName = appName .. "_LAOYANCAI_LAOYANCAI"
    AppData.DouDiZhu_GameName = appName .. "_DOUDIZHU_DOUDIZHU"
    AppData.BaiBaZhang_GameName = appName .. "_BAIBAZHANG_BBZ"
    AppData.ShiSanZhang_GameName = appName .. "_SHISANZHANG_SSZ"
end


function AppData.isPokerRule(rule)
    if not rule then
        return false
    end

    for k,v in pairs(AppData.allPackageConfig) do
        if(v.short_game_name and v.short_game_name ~= '' and string.find(rule, v.short_game_name))then
            return v.is_skynet_framework or false, v
        end
    end
    return false
end

function AppData.isPokerBijiRule(rule)
    if string.find(rule, "_BIJI_BJ") then
        return true
    end
end

function AppData.isPokerBullfightRule(rule)
    if rule and string.find(rule, "_BULLFIGHT_") then
        return true
    end
end



function AppData.isPokerGame()
    for k,v in pairs(AppData.allPackageConfig) do
        if(v.game_name == AppData.Game_Name)then
            return v.is_skynet_framework or false, v
        end
    end
    return false
end

function AppData.get_url_game_name()
    return AppData.get_app_and_game_name()
end

function AppData.get_cur_server_host_ip()
    return ModuleCache.GameManager.netAdress.curServerHostIp

end
--特殊处理
function AppData.get_app_and_game_name()
    --if(AppData.App_Name == "DHAHQP" and AppData.Game_Name ~= "LAMJ" and string.find(AppData.Game_Name, "LAMJ") ~= nil) then
    --    return "LAMJ"
    --end
    --if(AppData.App_Name == "DHAHQP" and string.find(AppData.Game_Name, "WJMJ") ~= nil) then
    --    return "WJMJ"
    --end
    --if(AppData.App_Name == "DHAHQP" and string.find(AppData.Game_Name, "DHWBMJ") ~= nil) then
    --    return "DHWBMJ"
    --end
    return AppData.App_Name .. "_" .. AppData.Game_Name
end

-- 要适配六安、安庆、皖北和大胡棋牌游戏的通打，好爽
function AppData.get_app_name()
    --if(AppData.App_Name == "DHAHQP" and AppData.Game_Name ~= "LAMJ" and string.find(AppData.Game_Name, "LAMJ") ~= nil) then
    --    return "LAMJ", true
    --end
    --if(AppData.App_Name == "DHAHQP" and string.find(AppData.Game_Name, "WJMJ") ~= nil) then
    --    return "WJMJ", true
    --end
    --if(AppData.App_Name == "DHAHQP" and string.find(AppData.Game_Name, "DHWBMJ") ~= nil) then
    --    return "DHWBMJ", true
    --end
    return AppData.App_Name
end
-- AppData.select_province_id(AppData.Const_App_Name)



