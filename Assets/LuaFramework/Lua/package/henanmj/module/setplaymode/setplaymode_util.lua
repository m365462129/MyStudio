local require = require
local string = string
local table = table
local tonumber = tonumber
local setmetatable = setmetatable
local tostring = tostring
local ModuleCache = ModuleCache

---@class PlayModeUtil
local PlayModeUtil = {}

PlayModeUtil.config = nil
PlayModeUtil.provinceConfig = require("package.henanmj.module.playmodeconfigs.all_configs")

-- 每次切换省份时自动刷新当前所用玩法配置
function PlayModeUtil.setCurConfig(curProvince)
    -- print_table(PlayModeUtil.provinceConfig)
    local getConfig = PlayModeUtil.getProvinceById(curProvince)
    PlayModeUtil.config = require(getConfig.modName)
end

function PlayModeUtil.getProvinceById(provinceId)
    for i = 1, #PlayModeUtil.provinceConfig.provinceList do
        if PlayModeUtil.provinceConfig.provinceList[i] then
            if(provinceId == PlayModeUtil.provinceConfig.provinceList[i].id) then
                return PlayModeUtil.provinceConfig.provinceList[i]
            end
        end
    end

    return PlayModeUtil.getProvinceById(1)
end

function PlayModeUtil.getPlayModeConfigByAppName(appName)

    local config = nil

    for k, v in ipairs(PlayModeUtil.provinceConfig.provinceList) do
        if string.lower(v.appName) == string.lower(appName) then
            config = v
        end
    end
    if(config == nil) then
        print("AppName 不对，找不到对应的省份配置！")
        return nil
    end
    return require(config.modName)
end

function PlayModeUtil.getProvinceByAppName(appName)
    for i = 1, #PlayModeUtil.provinceConfig.provinceList do
        if PlayModeUtil.provinceConfig.provinceList[i] then
            if(appName == PlayModeUtil.provinceConfig.provinceList[i].appName) then
                return PlayModeUtil.provinceConfig.provinceList[i]
            end
        end
    end
    return PlayModeUtil.getProvinceById(1)
end

-- 获取选择玩法使用的排序后的配置表
function PlayModeUtil.getSortConfig(config)
    if config == nil then
        config = PlayModeUtil.config
    end
    local tempConfig = PlayModeUtil.getDeepCopyTable(config)
    local curMode = PlayModeUtil.getListByGameId(ModuleCache.GameManager.curGameId,tempConfig)
    if(curMode.showIndex == 1) then
        return tempConfig
    end
    
    local downMode = PlayModeUtil.getDeepCopyTable(tempConfig[2])
    local upMode = PlayModeUtil.getDeepCopyTable(PlayModeUtil.getListByGameId(ModuleCache.GameManager.curGameId, tempConfig))
    local showIndex = upMode.showIndex
    local tempMode = downMode
    tempConfig[2] = upMode
    tempConfig[2].showIndex = 2
    tempConfig[showIndex] = tempMode
    tempConfig[showIndex].showIndex = showIndex
    -- print_table(PlayModeUtil.config)
    return tempConfig
end


function PlayModeUtil.getDeepCopyTable(copyTable)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(copyTable)
end

function PlayModeUtil.getListByGameId(gameId, config)
    if(config == nil) then config = PlayModeUtil.config end

    for i=1,#config do
        if config[i]then
            local data = config[i]
            for j=1,#data.playModeList do
                if data.playModeList[j] then
                    if(data.playModeList[j].gameId == gameId) then
                        return data
                    end
                end
            end
        end
    end
     print("get list can not find gameId = "..tostring(gameId))
    return PlayModeUtil.getListByGameId(1,config)
end

function PlayModeUtil.getInfoByGameNameAndName(gameName, name, config)
    if(config == nil) then config = PlayModeUtil.config end
    for i=1,#config do
        if config[i]then
            local data = config[i]
            for j=1,#data.playModeList do
                if data.playModeList[j] then
                    if(data.playModeList[j].gameName == gameName and data.playModeList[j].name == name) then
                        return data.playModeList[j]
                    end
                end
            end
        end
    end
    return PlayModeUtil.getInfoByGameNameAndName("HZMJ", "红中麻将", config)
end

function PlayModeUtil.getConfigByGameName(gameName,  config)
    if (config == nil) then
        config = PlayModeUtil.config
    end
    for i = 1, #config do
        if config[i] then
            local data = config[i]
            for j = 1, #data.playModeList do
                if data.playModeList[j] then
                    if (data.playModeList[j].gameName == gameName) then
                        return data.playModeList[j]
                    end
                end
            end
        end
    end
    return nil
end

function PlayModeUtil.getInfoByGameName(gameName, config)
    if(config == nil) then config = PlayModeUtil.config end
    for i=1,#config do
        if config[i]then
            local data = config[i]
            for j=1,#data.playModeList do
                if data.playModeList[j] then
                    if(data.playModeList[j].gameName == gameName) then
                        return data.playModeList[j]
                    end
                end
            end
        end
    end
    return PlayModeUtil.getInfoByGameId(1, config)
end

function PlayModeUtil.getInfoByGameId(gameId, config)
    if(config == nil) then config = PlayModeUtil.config end
    --print_table(config)
    for i=1,#config do
        if config[i]then
            local data = config[i]
            for j=1,#data.playModeList do
                if data.playModeList[j] then
                    if(data.playModeList[j].gameId == gameId) then
                        return data.playModeList[j]
                    end
                end
            end
        end
    end
    return PlayModeUtil.getInfoByGameId(1, config)
end

function PlayModeUtil.getInfoByIdAndLocation(gameId,location,config)
    -- print_table(PlayModeUtil.config[location])
    if(config == nil) then config = PlayModeUtil.config end
    for i=1,#config[location].playModeList do
        if config[location].playModeList[i] then
            if(config[location].playModeList[i].gameId == gameId) then
                return config[location].playModeList[i]
            else
                return PlayModeUtil.getInfoByGameId(gameId, config)
            end
        end
    end

    return PlayModeUtil.getInfoByIdAndLocation(1,1,config)
end

-- 测试模式，
function PlayModeUtil.test_mode(open)
    if(ModuleCache.GameManager.iosAppStoreIsCheck)then return end

    for k, v in ipairs(PlayModeUtil.provinceConfig.provinceList) do
        if(not v.isOpenUrl) then
            v.isOpen = true
            v.isOnline = true
        end
    end



    for k, v in ipairs(PlayModeUtil.config) do
        v.isOpen = true
        for key, value in ipairs(v.playModeList) do
            value.isOpen = true
            if(not value.isOpenUrl) then
                value.isOnline = true
            end
        end
    end
end

function PlayModeUtil.getLocationNameById(gameId, config)
    if(config == nil) then config = PlayModeUtil.config end
    for i=1,#config do
        if config[i]then
            local data = config[i]
            for j=1,#data.playModeList do
                if data.playModeList[j] then
                    if(data.playModeList[j].gameId == gameId) then
                        return data.name
                    end
                end
            end
        end
    end
    print("can not find location, gameId = "..gameId)
    return nil
end

-- 主界面背景大图
function PlayModeUtil.getBgRes()
    local config = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)

    local path = string.lower(config.package).."/module/setplaymodedata/"
    path = path..string.lower(config.package).."_setplaymodedata"..string.lower(config.bg)..".atlas"

    if not ModuleCache.AssetBundleManager:AssetBundleExist(path) then
        -- 如果资源包不存在 则直接获取henanmj资源包
        print("没有资源包:"..path)
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedatabackgroundhongzhong.atlas"
    end
    local img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.bg)
    if(img == nil) then
        -- 包内找不到，则在henanmj默认文件夹内再找一次
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedata"..string.lower(config.bg)..".atlas"
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.bg)
    end
    if(img == nil) then
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle("henanmj/module/setplaymodedata/henanmj_setplaymodedatabackgroundhongzhong.atlas", "BackgroundHongZhong")
    end
    return img
end



-- 主界面中间Button icon
function PlayModeUtil.getBtnRes(btnName)
    if(btnName == nil) then btnName = "CreateRoomBtn" end
    local iconName = ""

    if(btnName == "CreateRoomBtn") then iconName = "创建" end
    if(btnName == "JoinRoomBtn") then iconName = "加入" end
    if(btnName == "MuseumBtn") then iconName = "亲友圈" end
    if(btnName == "GoldRoomBtn") then iconName = "金币场" end

    local config = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)
    local path = string.lower(config.package).."/module/setplaymodedata/"
    path = path..string.lower(config.package).."_setplaymodedata.atlas"


    if not ModuleCache.AssetBundleManager:AssetBundleExist(path) then
        -- 如果资源包不存在 则直接获取henanmj资源包
        print("没有资源包:"..path)
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedata.atlas"
    end
    -- print("load btnImg path = "..path.." Assets = "..config.btnImg..iconName)
    local img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.btnImg..iconName)
    if(img == nil) then
        -- 包内找不到，则在henanmj默认文件夹内再找一次
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedata.atlas"
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.btnImg..iconName)
    end
    if(img == nil) then
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, "HongZhong_Main_入口_图标_"..iconName)
    end
    return img
end

-- 选择玩法界面 玩法ICON
function PlayModeUtil.getIconRes(config,provinceId)
    if(config == nil) then config = PlayModeUtil.getInfoByIdAndLocation(1,1) end
    if provinceId == nil then provinceId = ModuleCache.GameManager.curProvince end
    --print("provinceId = "..provinceId.."----------------------")
    --print("config.gameId = "..config.gameId)
    --print_table(config)
    local strs = string.split(config.img, ',')
    if #strs == 2 then
        local iconImg = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(strs[1], strs[2])
        if iconImg ~= nil then
            return iconImg
        end
    end


    local gameConfig = PlayModeUtil.config
    local getConfig = PlayModeUtil.getProvinceById(provinceId)
    if provinceId ~= ModuleCache.GameManager.curProvince then
        gameConfig = require(getConfig.modName)
    end
    local cofList = PlayModeUtil.getListByGameId(config.gameId,gameConfig)



    local provinceName = string.lower(getConfig.gameName)
    --print("provinceName = "..provinceName)
    --print("cofList.name = "..cofList.name)
    if cofList.name == "大众玩法" then
        provinceName = "public"
    end



    local path = string.lower(config.package).."/module/setplaymodedata/"
    path = path..string.lower(config.package).."_setplaymodedata"..provinceName..".atlas"

    --print("load icon path = "..path.." Assets = "..config.img)
    if not ModuleCache.AssetBundleManager:AssetBundleExist(path) then
        -- 如果资源包不存在 则直接获取henanmj资源包
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedata"..provinceName..".atlas"
    end
    local img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.img)
    if(img == nil)then 
        -- 包内找不到，则在henanmj默认文件夹内再找一次
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedatapublic.atlas"
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.img)
    end
    if(img == nil) then
        -- 找不到资源 用默认资源替代
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, "Public_Electorate_按钮_图标_发财_麻将通用")
    end
    return img
end

-- 主界面右上角游戏名
function PlayModeUtil.getHallImgRes()
    local config = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)

    local cofList = PlayModeUtil.getListByGameId(ModuleCache.GameManager.curGameId)
    local getConfig = PlayModeUtil.getProvinceById(ModuleCache.GameManager.curProvince)
    local provinceName = string.lower(getConfig.gameName)
    if cofList.name == "大众玩法" then
        provinceName = "public"
    end

    local path = string.lower(config.package).."/module/setplaymodedata/"
    path = path..string.lower(config.package).."_setplaymodedata"..provinceName..".atlas"
    if not ModuleCache.AssetBundleManager:AssetBundleExist(path) then
        -- 如果资源包不存在 则直接获取henanmj资源包
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedata"..provinceName..".atlas"
    end
    -- print("load icon path = "..path.." Assets = "..config.hallImg)
    local img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.hallImg)
    if(img == nil) then
        -- 包内找不到，则在henanmj默认文件夹内再找一次
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedatapublic.atlas"
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.hallImg)
    end
    if(img == nil) then
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, "Public_Main_玩法_红中麻将")
    end
    return img
end

function PlayModeUtil.getHeadIconRes(config,provinceId)
    if(config == nil) then config = PlayModeUtil.getInfoByIdAndLocation(1,1) end


    local strs = string.split(config.headIcon, ',')
    if #strs == 2 then
        local headimg = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(strs[1], strs[2])
        if headimg ~= nil then
            return headimg
        end
    end


    if provinceId == nil then provinceId = ModuleCache.GameManager.curProvince end
    local gameConfig = PlayModeUtil.config
    local getConfig = PlayModeUtil.getProvinceById(provinceId)
    if provinceId ~= ModuleCache.GameManager.curProvince then
        gameConfig = require(getConfig.modName)
    end
    local cofList = PlayModeUtil.getListByGameId(config.gameId,gameConfig)
    local provinceName = string.lower(getConfig.gameName)
    if cofList.name == "大众玩法" then
        provinceName = "public"
    end

    local path = "henanmj/module/setplaymodedata/henanmj_setplaymodedata"..provinceName..".atlas"
    local img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.headIcon)
    if(img == nil)then
        -- 包内找不到，则在henanmj默认文件夹内再找一次
        path = "henanmj/module/setplaymodedata/henanmj_setplaymodedatapublic.atlas"
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, config.headIcon)
    end
    if(img == nil) then
        -- 找不到资源 用默认资源替代
        img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, "Main_入口_通用玩法")
    end
    return img
end

function PlayModeUtil.getPopIcon(provinceId)
    local province = PlayModeUtil.getProvinceById(provinceId)
    local path = "henanmj/module/setprovince/henanmj_setprovince.atlas"
    if not ModuleCache.AssetBundleManager:LoadAssetBundle(path) then
        -- 如果资源包不存在 则直接获取henanmj资源包
        print("没有资源包:"..path)
        return nil
    end
    local img = ModuleCache.ViewUtil.GetSpriteFromeAssetBundle(path, province.popIcon)
    return img
end



-- 根据玩法type或者gameName获取金币场数据
function PlayModeUtil.get_gold_playmodel_data(gameName, config)
    if (config == nil) then
        config = PlayModeUtil.config
    end
    if (gameName) then
        local list = {}
        local playModeData
        for i = 1, #config do
            if (config[i]) then
                local data = config[i]
                for j = 1, #data.playModeList do
                    if (data.playModeList[j] and data.playModeList[j].gameName == gameName and data.playModeList[j].isOnline) then
                        playModeData = data.playModeList[j]
                    end
                end
            end
        end
        if (#list == 0) then
            local names = string.split(playModeData.goldRoomName, "|")
            local wanfaTypes = string.split(playModeData.playTypeName, "|")
            for i = 1, #names do
                local data = { name = names[i], wanfaType = wanfaTypes[i], playModName = playModeData.name }
                table.insert( list, data)
            end
        end
        return list
    end
end

-- 根据玩法type或者gameName获取数据
function PlayModeUtil.get_playmodel_data(wanfaType, gameName, gameId, config)
    if (config == nil) then
        config = PlayModeUtil.config
    end
    if (wanfaType and not AppData.isPokerGame()) then
        for i = 1, #config do
            if (config[i]) then
                local data = config[i]
                for j = 1, #data.playModeList do
                    --print("========",j,data.playModeList[j].wanfaType,data.playModeList[j].playTypeName)
                    if (string.find(data.playModeList[j].wanfaType, wanfaType)) or
                            (data.playModeList[j].playTypeName and string.find(data.playModeList[j].playTypeName, wanfaType)) then
                        return data.playModeList[j]
                    end
                end
            end
        end
    end
    if (gameName) then
        local list = {}
        local playModeData = nil
        for i = 1, #config do
            if (config[i]) then
                local data = config[i]
                for j = 1, #data.playModeList do
                    if (data.playModeList[j] and data.playModeList[j].gameName == gameName and data.playModeList[j].isOnline) then
                        --print_table(data.playModeList[j].tips,"hhgggg")
                        if (not data.playModeList[j].tips) then
                            table.insert(list, data.playModeList[j])
                        else
                            playModeData = data.playModeList[j]
                        end
                    end
                end
            end
        end
        if (#list == 0) then
            local names = string.split(playModeData.tips, "|")
            local wanfaTypes = string.split(playModeData.wanfaType, "|")
            local createNames = string.split(playModeData.createName, "|")
            for i = 1, #names do
                local createName = playModeData.createName
                if (#createNames > 1) then
                    createName = createNames[i]
                end
                local data = { name = names[i], wanfaType = wanfaTypes[i], createName = createName, playModName = playModeData.name }
                table.insert( list, data)
            end
        end

        return list
    end
    if (gameId) then
        for i = 1, #config do
            if (config[i]) then
                local data = config[i]
                for j = 1, #data.playModeList do
                    if (data.playModeList[j] and data.playModeList[j].gameId == gameId and data.playModeList[j].isOnline) then
                        return j
                    end
                end
            end
        end
    end
end

-- 根据createName获取数据(棋牌类专用)
function PlayModeUtil.get_playmodel_data_poker(createName, config)
    if(config == nil) then config = PlayModeUtil.config end
    for i=1,#config do
        if(config[i]) then
            local data = config[i]
            for j=1,#data.playModeList do
                if data.playModeList[j]then
                    if(string.find(data.playModeList[j].createName, createName) and data.playModeList[j].isOnline) then
                        return data.playModeList[j]
                    end
                end
            end
        end
    end
end




function PlayModeUtil.get_province_data(appName)

    for k, v in ipairs(PlayModeUtil.provinceConfig.provinceList) do
        if string.lower(v.appName) == string.lower(appName) then
            return v
        end
    end
    return nil
end

return PlayModeUtil
