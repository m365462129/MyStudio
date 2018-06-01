--- @class TableUtilPaoHuZi
TableUtilPaoHuZi = {}

local TableUtilPaoHuZi = TableUtilPaoHuZi
local ModuleCache = ModuleCache
local TableManager = require("package.henanmj.table_manager")
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameObject = UnityEngine.GameObject
local ComponentUtil = ModuleCache.ComponentUtil
local bit = require("bit")
local Manager = require("package.public.module.function_manager")
local UnityEngine = UnityEngine
local isEditor = UnityEngine.Application.isEditor
local AppData = AppData


--- 设置帧率
--- @param draggingCard boolean 正在拖动手牌
--- @param playingAnim boolean 正在播放动画
function TableUtilPaoHuZi.set_frame_rate(draggingCard, playingAnim)
    TableUtilPaoHuZi.draggingCard = draggingCard
    TableUtilPaoHuZi.playingAnim = playingAnim
    
    local frame = AppData.tableTargetFrameRate
    
    if draggingCard or playingAnim then
        frame = 60
    end
    
    UnityEngine.Application.targetFrameRate = frame
end

-- 将服务器的做座位索引转换为本地位置索引
function TableUtilPaoHuZi.get_local_seat(seatIndex, mySeatIndex, seatCount, seatTable)
    local localSeat = 1
    if (not seatTable) then
        localSeat = (seatIndex + seatCount - mySeatIndex) % seatCount + 1
    else
        local index = seatTable[seatIndex + 1]
        localSeat = (index + seatCount - mySeatIndex) % seatCount + 1
    end
    --if (seatCount == 3 and localSeat == 3) then
    --    localSeat = 4
    --end
    return localSeat
end

-- 获取所有子物体
function TableUtilPaoHuZi.get_all_child(parent, filterName)
    local childs = {}
    local index = 1
    for i = 1, parent.transform.childCount do
        local obj = parent.transform:GetChild(i - 1).gameObject
        if (not filterName or (filterName and obj.name == filterName)) then
            childs[index] = obj
            index = index + 1
        end
    end
    return childs
end

-- 移到克隆池中
function TableUtilPaoHuZi.move_clone(obj, cloneParent)
    obj.transform:SetParent(cloneParent.transform)
    ComponentUtil.SafeSetActive(obj, false)
end

-- 添加到对象池
function TableUtilPaoHuZi.add_poor(obj, poorObjs, cloneParent)
    TableUtilPaoHuZi.move_clone(obj, cloneParent)
    if not poorObjs then
        poorObjs = {}
    end
    if not poorObjs[obj.name] then
        poorObjs[obj.name] = {}
    end
    table.insert(poorObjs[obj.name], obj)
    return poorObjs
end

-- 从对象池取出
function TableUtilPaoHuZi.poor(objName, parent, pos, poorObjs, clones, scale)
    local targetObj = nil
    if (not poorObjs) then
        poorObjs = {}
    end
    if poorObjs[objName] then
        if #poorObjs[objName] ~= 0 then
            targetObj = poorObjs[objName][1]
            targetObj.transform:SetParent(parent.transform)
            targetObj.transform.localPosition = pos
            targetObj.name = objName
            table.remove(poorObjs[objName], 1)
        else
            targetObj = TableUtilPaoHuZi.clone(TableUtilPaoHuZi.get_clone_obj(objName, clones), parent, pos)
        end
    else
        targetObj = TableUtilPaoHuZi.clone(TableUtilPaoHuZi.get_clone_obj(objName, clones), parent, pos)
    end
    ComponentUtil.SafeSetActive(targetObj, true)
    if (scale) then
        targetObj.transform.localScale = scale
    end
    return targetObj
end

-- 获取克隆物体
function TableUtilPaoHuZi.get_clone_obj(objName, clones)
    for i = 1, #clones do
        if clones[i].name == objName then
            return clones[i]
        end
    end
    return nil
end

-- 克隆
function TableUtilPaoHuZi.clone(obj, parent, pos)
    local target = ComponentUtil.InstantiateLocal(obj, parent, pos)
    target.name = obj.name
    ComponentUtil.SafeSetActive(target, true)
    return target
end

--- 设置牌颜色
function TableUtilPaoHuZi.set_card_color(cardObj, color)
    local childs = TableUtilPaoHuZi.get_all_child(cardObj)
    for i = 1, #childs do
        local image = ComponentUtil.GetComponent(childs[i], ComponentTypeName.Image)
        if (image) then
            image.color = color
        end
    end
end

---设置牌
---@param cardObj UnityEngine.GameObject
---@param value number
---@param color UnityEngine.Color
---@param name String
function TableUtilPaoHuZi.set_card(cardObj, value, color, name,status)
    if cardObj then
        local img = Manager.GetImage(cardObj, "Image")
        local spriteHolder = nil
        name = TableUtilPaoHuZi.get_real_spriteHolder(name)
        if name == nil then
            spriteHolder = Manager.GetComponentWithPath(cardObj, "Image", "SpriteHolder")
        else
            TableUtilPaoHuZi.spriteHolderDC = TableUtilPaoHuZi.spriteHolderDC or {}
            if TableUtilPaoHuZi.spriteHolderDC[name] == nil then
                print(name,value)
                TableUtilPaoHuZi.spriteHolderDC[name] = TableUtilPaoHuZi.CloneGameObject.transform:Find(name).gameObject:GetComponent("SpriteHolder")
                print(TableUtilPaoHuZi.spriteHolderDC[name].gameObject.name,value)
            end
            
            if value > 0 and value <= 20 then
                if value % 2 == 0 then
                    value = value / 2 + 10
                else
                    value = (value + 1) / 2
                end
            end
            spriteHolder = TableUtilPaoHuZi.spriteHolderDC[name]
        end
        
        if img and spriteHolder then
            img.sprite = spriteHolder:FindSpriteByName(tostring(value))
            img.color = not color and Color.New(1, 1, 1, 1) or color
        else
            for i=1,10 do
                print(i)
            end
        end

        if status == 1 then
            local Bg = Manager.FindObject(cardObj, "bg")
            if Bg then
                Bg:SetActive(true)
            end
        else

        end
    end
end

function TableUtilPaoHuZi.getcardSprite(value, name)
    name = TableUtilPaoHuZi.get_real_spriteHolder(name)
    TableUtilPaoHuZi.spriteHolderDC = TableUtilPaoHuZi.spriteHolderDC or {}
    if TableUtilPaoHuZi.spriteHolderDC[name] == nil then
        print(name)
        TableUtilPaoHuZi.spriteHolderDC[name] =
            TableUtilPaoHuZi.CloneGameObject.transform:Find(name).gameObject:GetComponent("SpriteHolder")
        print(TableUtilPaoHuZi.spriteHolderDC[name].name)
    end

    if value > 0 and value <= 20 then
        if value % 2 == 0 then
            value = value / 2 + 10
        else
            value = (value + 1) / 2
        end
    end

  
    spriteHolder = TableUtilPaoHuZi.spriteHolderDC[name]

    return spriteHolder:FindSpriteByName(tostring(value))
end

function TableUtilPaoHuZi.get_real_spriteHolder(name)
    if name == nil then
        return name
    end

    local str = ""
    if DataPaoHuZi.ZP_ZPPaiLei == 2 then
        str = "1"
    end

    if DataPaoHuZi.ZP_ZPPaiLei == 3 then
        str = "2"
    end

    return string.gsub(name, "ZiPai", "ZiPai" .. str) 
end




--- 打印跑胡子日志
function TableUtilPaoHuZi.print(...)
    if isEditor then
        --print("<color=#00FF2CFF>========跑胡子Log========</color>", ...)
    end
end

--- 添加一个Sequence事件
--- @param seq DG.Tweening.Sequence
function TableUtilPaoHuZi.add_sequence(seq)
    if not TableUtilPaoHuZi.sequenceList then
        TableUtilPaoHuZi.sequenceList = {}
    end
    table.insert(TableUtilPaoHuZi.sequenceList, seq)
end

--- 清除所有Sequence事件
function TableUtilPaoHuZi.clear_all_sequence()
    if TableUtilPaoHuZi.sequenceList then
        for k, v in pairs(TableUtilPaoHuZi.sequenceList) do
            if v then
                v:Kill(false)
            end
        end
    end
    TableUtilPaoHuZi.sequenceList = nil
end

-- 转换utf-8
function TableUtilPaoHuZi.utf8_text(text, n)
    local vals = {0x3f, 0x1f, 0x0f, 0x07, 0x03, 0x01}
    local beginVal = string.byte(text, n)
    for i = 0, 5 do
        if (bit.rshift(beginVal, 8 - (6 - i)) == vals[i + 1]) then
            return string.sub(text, n, n + (6 - i) - 1), n + (6 - i) - 1
        end
    end
    return string.sub(text, n, n), n
end

-- 截取文本
function TableUtilPaoHuZi.cut_text(widthText, content, controllWidth)
    local addStr = ""
    local newStr = ""
    local char = ""
    local index = 0
    for j = 1, string.len(content) do
        if (j > index) then
            char, index = TableUtilPaoHuZi.utf8_text(content, j)
            addStr = addStr .. char
            widthText.text = addStr
            if (widthText.preferredWidth > controllWidth) then
                newStr = newStr .. "\n" .. char
                addStr = char
            else
                newStr = newStr .. char
            end
            if (index == string.len(content)) then
                break
            end
        end
    end
    return newStr
end

-- 过滤用户名
function TableUtilPaoHuZi.filter_player_name(name)
    if (true) then
        return name
    end
    local newName = ""
    local charNum = 0
    for ch in string.gmatch(name, "[\\0-\127\194-\244][\128-\191]*") do
        if (#ch ~= 1) then
            if (charNum + 2 > 8) then
                return newName .. ".."
            end
            charNum = charNum + 2
            newName = newName .. ch
        else
            if (charNum + 1 > 8) then
                return newName .. ".."
            end
            charNum = charNum + 1
            newName = newName .. ch
        end
    end
    return newName .. ".."
end

function TableUtilPaoHuZi.get_chat_text(index)
    return Config.chatShotTextList[index]
end

-- 获取玩家信息
function TableUtilPaoHuZi.get_player_info(playerId, url, callbackHead, callbackInfo)
    local playerInfo = {}
    local requestData = {
        params =
        {
            uid = playerId,
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
    }
    if playerId then
        requestData.cacheDataKey = "httpcache:user/info?uid=" .. (playerId or "0")
    end
    
    Util.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            -- OK
            TableUtilPaoHuZi.set_player_info(retData.data, playerInfo, callbackHead, callbackInfo)
        else
            
            end
    end, function(error)
        print(error.error)
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then
            -- OK
            TableUtilPaoHuZi.set_player_info(retData.data, playerInfo, callbackHead, callbackInfo)
        else
            
            end
    end)
end

-- 填写玩家信息
function TableUtilPaoHuZi.set_player_info(playerData, playerInfo, callbackHead, callbackInfo)
    playerInfo.playerId = playerData.userId
    playerInfo.playerName = playerData.nickname
    playerInfo.headUrl = playerData.headImg
    playerInfo.gender = playerData.gender
    playerInfo.ip = playerData.ip
    if (playerInfo.playerId ~= 0) then
        if (callbackInfo) then
            callbackInfo(playerInfo)
        end
        if (callbackHead) then
            TableUtilPaoHuZi.start_download_head_icon(playerInfo, callbackHead)
        end
    else
        return
    end
end

-- 下载头像
function TableUtilPaoHuZi.start_download_head_icon(playerInfo, callbackHead)
    if (not playerInfo.headUrl or playerInfo.headUrl == nil) then
        playerInfo.headImage = nil1
        if (callbackHead) then
            callbackHead(playerInfo)
        end
        return
    end
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(playerInfo.headUrl, function(err, sprite)
        if (err) then
            -- print('down load '.. playerInfo.headUrl .. 'failed:')
            if (callbackHead) then
                callbackHead(playerInfo)
            end
        else
            playerInfo.headImage = sprite
            if (callbackHead) then
                callbackHead(playerInfo)
            end
        end
    end)
end

function TableUtilPaoHuZi.only_download_head_icon(targetImage, url)
    if (not url or url == "") then
        targetImage.sprite = nil
        return
    end
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, sprite)
        if (err) then
            -- print('down load '.. url .. 'failed:')
            else
            targetImage.sprite = sprite
        -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end)
end

-- 下载座位详细信息
function TableUtilPaoHuZi.download_seat_detail_info(userId, callbackHead, callbackInfo)
    if (not TableManager.phzTableData) then
        return
    end
    
    userId = userId or 0
    local playerInfo = TableUtilPaoHuZi.get_user_info(userId .. "")
    if (not playerInfo) then
        TableUtilPaoHuZi.get_player_info(userId, ModuleCache.GameManager.netAdress.httpCurApiUrl, function(info)
            TableUtilPaoHuZi.update_user_info(info)
            if (callbackHead) then
                callbackHead(info)
            end
        end, function(info)
            TableUtilPaoHuZi.update_user_info(info)
            if (callbackInfo) then
                callbackInfo(info)
            end
        end)
    else
        if (callbackInfo) then
            callbackInfo(playerInfo)
        end
        if (callbackHead) then
            if (not playerInfo.headImage) then
                TableUtilPaoHuZi.start_download_head_icon(playerInfo, function(info)
                    TableUtilPaoHuZi.update_user_info(info)
                    callbackHead(info)
                end)
            else
                callbackHead(playerInfo)
            end
        end
    end
end

-- 更新座位玩家信息
function TableUtilPaoHuZi.update_user_info(info)
    if (not TableManager.phzTableData) then
        return
    end
    if (not TableManager.phzTableData.userInfos) then
        TableManager.phzTableData.userInfos = {}
    end
    TableManager.phzTableData.userInfos[info.playerId .. ""] =
        {
            playerId = info.playerId,
            playerName = info.playerName,
            gender = info.gender,
            ip = info.ip,
            headUrl = info.headUrl
        }
    if (info.headImage) then
        TableManager.phzTableData.userInfos[info.playerId .. ""].headImage = info.headImage
    end
end

-- 获取座位玩家信息
function TableUtilPaoHuZi.get_user_info(userId)
    if (not userId or userId == "0") then
        return nil
    end
    if (TableManager.phzTableData and TableManager.phzTableData.userInfos and TableManager.phzTableData.userInfos[userId]) then
        return TableManager.phzTableData.userInfos[userId]
    end
    return nil
end

function TableUtilPaoHuZi.color_text(color, text)
    return string.format("<color=#%s>%s</color>", color, text)
end

-- 转换规则
function TableUtilPaoHuZi.convert_rule(rule)
    local ruleInfo = ModuleCache.Json.decode(rule)
    if AppData.Game_Name == 'LDZP' or AppData.Game_Name == 'XXZP' then
        if not ruleInfo.JieSuanHuXi then
            ruleInfo.JieSuanHuXi  = 100
        end
    end

    
    return ruleInfo
end

function TableUtilPaoHuZi.get_rule_name(rule, customPay)
    local ruleName = ""
    local wanfaName = ""
    local renshu = 4
    local wanfaTable = ""
    local ruleInfo = TableUtilPaoHuZi.convert_rule(rule)
    local ruleJson = ModuleCache.Json.encode(ruleInfo)
    
    local localConfig = require(string.format("package.public.config.%s.config_%s", AppData.App_Name, AppData.Game_Name))
    
    --比鸡掼蛋用的是gameType，跑得快用的是game_type，斗牛用的是bankerType，而麻将用的是GameType，蛋疼！
    local gameType = ruleInfo.GameType
    if AppData.Game_Name == "BIJI" or AppData.Game_Name == "GUANDAN" then
        gameType = ruleInfo.gameType
    end
    if AppData.Game_Name == "RUNFAST" then
        gameType = ruleInfo.game_type
    end
    if AppData.Game_Name == "BULLFIGHT" then
        if ruleInfo.bankerType ~= nil then
            gameType = ruleInfo.bankerType
        else
            gameType = 3 --炸金牛
        end
    end
    local wanfa, wanfaName = Config.GetWanfaIdx(gameType)
    local createTable = localConfig.createRoomTable[wanfa]
    print("-------------------gameType:", gameType, wanfa, wanfaName, ModuleCache.GameManager.curGameId)
    for i = 2, #createTable do
        local list = createTable[i].list
        for j = 1, #list do
            local groupData = list[j]
            for k = 1, #groupData do
                local toggleData = groupData[k]
                
                local addName = (toggleData.ruleTitle or toggleData.toggleTitle)
                if toggleData.json and (string.find(rule, toggleData.json) ~= nil and string.find(ruleName, addName) == nil) then
                    ruleName = ruleName .. addName .. " "
                    if string.find(toggleData.json, "DianPaoBaoPei") then
                        wanfaTable = addName
                    end
                end
            end
        end
    end
    renshu = ruleInfo.PlayerNum or ruleInfo.playerCount
    return wanfaName, ruleName, renshu, wanfaTable
end

function TableUtilPaoHuZi.copy_data(data)
    local copyData = {}
    for i, v in pairs(data) do
        copyData[i] = v
    end
    return copyData
end

-- 计算距离
function TableUtilPaoHuZi.caculate_distance(latitude1, longitude1, latitude2, longitude2)
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
        local var28 = {}
        local var29 = {}
        var28[1] = var18 * var16
        var28[2] = var18 * var12
        var28[3] = var14
        var29[1] = var26 * var24
        var29[2] = var26 * var20
        var29[3] = var22
        local var30 = math.sqrt((var28[1] - var29[1]) * (var28[1] - var29[1]) + (var28[2] - var29[2]) * (var28[2] - var29[2]) + (var28[3] - var29[3]) * (var28[3] - var29[3]))
        return (math.asin(var30 / 2.0) * 1.27420015798544E7)
    else
        print("非法坐标值")
        return -1
    end
end

function TableUtilPaoHuZi.hide_childs(parent, filterName)
    local childs = TableUtilPaoHuZi.get_all_child(parent, filterName)
    for i = 1, #childs do
        ComponentUtil.SafeSetActive(childs[i], false)
    end
end

function TableUtilPaoHuZi.get_or_clone(index, objName, parent, pos, poorObjs, clones, notFilter)
    local childs = nil
    if (notFilter) then
        childs = TableUtilPaoHuZi.get_all_child(parent)
    else
        childs = TableUtilPaoHuZi.get_all_child(parent, objName)
    end
    local obj = nil
    if (index <= #childs) then
        obj = childs[index]
    else
        obj = TableUtilPaoHuZi.poor(objName, parent, pos, poorObjs, clones, scale)
    end
    ComponentUtil.SafeSetActive(obj, true)
    obj.transform.localPosition = pos
    if (scale) then
        obj.transform.localScale = scale
    end
    return obj
end

return TableUtilPaoHuZi
