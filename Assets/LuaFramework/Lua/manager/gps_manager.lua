local ModuleCache = ModuleCache
local UnityEngine = UnityEngine
local tonumber = tonumber
local string = string
local math = math
--[[
      1.初始化游戏,获取自己的GPS信息,调用ModuleCache.GPSManager.StartGetMyGPSInfo()
      2.进入游戏后将自己的GPS信息发给服务器,自己的的GPS信息:ModuleCache.GPSManager.gps_info
      3.进入牌桌,玩家进来,将玩家的GPS信息保存ModuleCache.GPSManager.AddPlayerGPSInfo()
      4.如果玩家离开删除玩家的GPS信息调用ModuleCache.GPSManager.DeletePlayerGPSInfo(),如果牌桌解散调用ModuleCache.GPSManager.ClearGPSInfo()
      5.玩家都准备好开始玩牌,计算距离调用ModuleCache.GPSManager.StartCalculateGPS()
]]

local GPSManager = {}

local reasonableDiffTime

function GPSManager._get_cache_data(forbidUserCacheData)
    local gpsInfo = ModuleCache.PlayerPrefsManager.GetString("GPSINFO", "0")
    if gpsInfo ~= "0" then
        local gpsInfoGetTime = ModuleCache.PlayerPrefsManager.GetInt("UpdateGPSINFOTime", 0)
        if forbidUserCacheData then
            reasonableDiffTime = 300
        else
            reasonableDiffTime = 1200
        end
        -- 20分钟内的GPS信息立刻上报
        if gpsInfoGetTime ~= 0 and os.time() - gpsInfoGetTime < reasonableDiffTime then
            local data = {}
            local infoStrs = string.split(gpsInfo, ",")
            data.latitude = tonumber(infoStrs[1])
            data.longitude = tonumber(infoStrs[2])
            data.address = infoStrs[3]
            ModuleCache.GPSManager.gps_info = data.latitude .. "," .. data.longitude .. "," .. data.address
            ModuleCache.GPSManager.gpsAddress = data.address
            return data
        end
    end
end


---begin_location
---@param callback table
---@param forbidUserCacheData table 需要实时获取准确位置
function GPSManager.begin_location(callback, forbidUserCacheData)
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return
    end

    if callback then
        local cacheData = GPSManager._get_cache_data(forbidUserCacheData)
        if cacheData then
            ModuleCache.GPSManager.gps_info = cacheData.latitude .. "," .. cacheData.longitude .. "," .. cacheData.address
            ModuleCache.GPSManager.gpsAddress = cacheData.address
            callback(cacheData)
            callback = nil

            if os.time() - ModuleCache.PlayerPrefsManager.GetInt("UpdateGPSINFOTime", 0) < 60 then
                return
            end
        end
    end

    ModuleCache.WechatManager.onBeginLocation(true, function(data)
        print_table(data, "onBeginLocation")
        if (not data) then
            data = {}
        end
        if (not data.address) then
            local cacheData = GPSManager._get_cache_data(forbidUserCacheData)
            if not cacheData then
                data.address = "未开启位置获取功能"
                data.latitude = 0
                data.longitude = 0
            else
                data = cacheData
            end
        else
            if data.address ~= "" then
                ModuleCache.PlayerPrefsManager.SetString("GPSINFO", data.latitude .. "," .. data.longitude .. "," .. data.address)
                ModuleCache.PlayerPrefsManager.SetInt("UpdateGPSINFOTime", os.time())
            end
        end
        ModuleCache.GPSManager.gps_info = data.latitude .. "," .. data.longitude .. "," .. data.address
        ModuleCache.GPSManager.gpsAddress = data.address
        if callback then
            callback(data)
        end
    end)
end

--- 计算距离
function GPSManager.caculate_distance(latitude1, longitude1, latitude2, longitude2)
    -- print(longitude1,latitude1,longitude2,latitude2)
    if (longitude1 and latitude1 and longitude2 and latitude2) then
        local var2 = 0.01745329251994329
        local var4 = longitude1
        local var6 = latitude1
        local var8 = longitude2
        local var10 = latitude2
        var4 = var4 * 0.01745329251994329
        var6 = var6 * 0.01745329251994329
        var8 = var8 * 0.01745329251994329
        var10 = var10 * 0.01745329251994329
        local var12 = math.sin(var4)
        local var14 = math.sin(var6)
        local var16 = math.cos(var4)
        local var18 = math.cos(var6)
        local var20 = math.sin(var8)
        local var22 = math.sin(var10)
        local var24 = math.cos(var8)
        local var26 = math.cos(var10)
        local var28 = { }
        local var29 = { }
        var28[1] = var18 * var16
        var28[2] = var18 * var12
        var28[3] = var14
        var29[1] = var26 * var24
        var29[2] = var26 * var20
        var29[3] = var22
        local var30 = math.sqrt((var28[1] - var29[1]) *(var28[1] - var29[1]) +(var28[2] - var29[2]) *(var28[2] - var29[2]) +(var28[3] - var29[3]) *(var28[3] - var29[3]))
        return(math.asin(var30 / 2.0) * 1.27420015798544E7)
    else
        print("非法坐标值")
        return -1
    end
end





return GPSManager 
