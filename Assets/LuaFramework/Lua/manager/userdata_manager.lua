--
-- User: dred
-- Date: 2017/1/7
-- Time: 17:15
--
local ModuleCache = ModuleCache
local UserDataManager = { }

local rootPath = UnityEngine.Application.persistentDataPath
local cachePath = rootPath .. "/cachefiles"
local coroutine = coroutine

UserDataManager._userDataCaches = { }


--self.modelData.roleData.cards = data.cards
--self.modelData.roleData.coins = data.coins
--self.modelData.roleData.male = data.gender == 1
--self.modelData.roleData.gender = data.gender
--self.modelData.roleData.hasBind = data.hasBind
--self.modelData.roleData.headImg = data.headImg
--self.modelData.roleData.lostCount = data.lostCount
--self.modelData.roleData.nickname = data.nickname
--self.modelData.roleData.score = data.score
--self.modelData.roleData.tieCount = data.tieCount
--self.modelData.roleData.winCount = data.winCount
--self.modelData.roleData.userId = data.userId
--self.modelData.roleData.breakRate = data.breakRate
--self.modelData.roleData.unionId = data.unionId
--self.modelData.roleData.ip = data.ip
--self.modelData.roleData.gold = data.gold


function UserDataManager.init()
    require("UnityEngine.AsyncOperation")
    require("UnityEngine.Texture2D")
    UserDataManager._init = true
end


--获取静态数据，比如昵称、头像、性别
---get_static_data 如果有headImgCallback的话
---@param userID table
---@param finishCallback
function UserDataManager.get_static_data(userID, finishCallback, headImgCallback)
    local cacheData = UserDataManager._userDataCaches[userID]
    if finishCallback and cacheData then
        finishCallback(cacheData)

        if headImgCallback then
            headImgCallback(cacheData.headImgSprite)
        end

        return
    end
    UserDataManager._get_userinfo(userID, false,function (text)
        local retData = ModuleCache.Json.decode(text)

        if retData.ret and retData.ret == 0 then
            UserDataManager.set_user_data(retData.data, function (cacheUserData)
                if finishCallback and cacheUserData then
                    finishCallback(cacheUserData)
                end
            end, headImgCallback)
        end
    end)
end


function UserDataManager.set_user_data(data, finishCallback, headImgCallback)
    local cacheData = UserDataManager._userDataCaches[data.userId] or {}
    cacheData.cards = data.cards
    cacheData.coins = data.coins
    cacheData.male = data.gender == 1
    cacheData.gender = data.gender
    cacheData.hasBind = data.hasBind
    cacheData.headImg = data.headImg
    cacheData.headImgUrl = data.headImg
    cacheData.lostCount = data.lostCount
    -- 昵称
    cacheData.nickname = data.nickname
    -- 缩略昵称
    cacheData.contractionsNickname = ModuleCache.GameUtil.filterPlayerName(cacheData.nickname, 10)
    cacheData.score = data.score
    cacheData.tieCount = data.tieCount
    cacheData.winCount = data.winCount
    cacheData.userId = data.userId
    cacheData.breakRate = data.breakRate
    cacheData.unionId = data.unionId
    cacheData.ip = data.ip
    cacheData.gold = data.gold

    if finishCallback and headImgCallback then
        finishCallback(cacheData)
    end

    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(cacheData.headImgUrl, function (error, sprite)
        if sprite then
            cacheData.headImgSprite = sprite
        else
            cacheData.headImgSprite = nil
        end
        UserDataManager._userDataCaches[cacheData.userId] = cacheData
        if finishCallback and not headImgCallback then
            finishCallback(cacheData)
        end

        if headImgCallback then
            headImgCallback(cacheData.headImgSprite)
        end
    end)
end

--获取通用数据，不能用于货币的获取
function UserDataManager.get_general_data(userID, finishCallback, headImgCallback)
    UserDataManager._get_userinfo(userID, false,function (text)
        local retData = ModuleCache.Json.decode(text)

        if retData.ret and retData.ret == 0 then
            UserDataManager.set_user_data(retData.data, function (cacheUserData)
                if finishCallback and cacheUserData then
                    finishCallback(cacheUserData)
                    return
                end
            end, headImgCallback)
        end
    end)
end

--获取货币数据
function UserDataManager.get_currency_data(userID, finishCallback, headImgCallback)
    UserDataManager._get_userinfo(userID, true,function (text)
        local retData = ModuleCache.Json.decode(text)

        if retData.ret and retData.ret == 0 then
            UserDataManager.set_user_data(retData.data, function (cacheUserData)
                if finishCallback and cacheUserData then
                    finishCallback(cacheUserData)
                    return
                end
            end, headImgCallback)
        end
    end)
end

-- 如果是超时需要提供重试功能
function UserDataManager._get_userinfo(userID, getCurrencyData, finishCallback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = userID,
        },
    }

    if getCurrencyData then
        requestData.cacheDataKey = string.format("user/info?uid=%s&gameName=%s", userID, ModuleCache.AppData.get_url_game_name())
    else
        requestData.cacheDataKey = string.format("user/info?uid=%s", userID)
    end

    ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
        if finishCallback then
            finishCallback(wwwOperation.www, nil)
        end
    end , function(error)
        print(error.error)
    end , function(cacheDataText)
        if finishCallback then
            finishCallback(cacheDataText, nil)
        end
    end)
end




return UserDataManager;


