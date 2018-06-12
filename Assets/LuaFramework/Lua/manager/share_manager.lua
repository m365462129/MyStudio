local ModuleCache = ModuleCache
local UnityEngine = ModuleCache.UnityEngine
local WechatManager = ModuleCache.WechatManager
local Application = UnityEngine.Application
local GameManager = ModuleCache.GameManager
local AppData = ModuleCache.AppData
local ShareManager = { }
local Util = ModuleCache.GameUtil
local base = _G
local Time = Time



local title = UnityEngine.Application.productName

local screenShotDirPath = Application.persistentDataPath .. "/screenShot"
local screenShotPath = screenShotDirPath .. "/screenShot.jpg"

local shareImageTimeLine = 0

-- 不显示图片的分享
local screenPortrait = false -- 是否竖屏


ShareManager.shareAppType = {
    Wechat = "Wechat",
    Alipay = "Alipay",
    XianLiao = "XianLiao"
}

ShareManager.shareSceneType = {
    Wechat = "Wechat",
    Alipay = "Alipay",
    XianLiao = "XianLiao"
}


function ShareManager._init()
    ShareManager._init = true
    ShareManager.screenCameraObj = ModuleCache.ComponentManager.Find(ModuleCache.GameManager.gameRoot, "Game/UIRoot/CameraShareOnly")
    print(ShareManager.screenCameraObj, "====")
    ShareManager.screenCamera = ModuleCache.ComponentManager.GetComponent(ShareManager.screenCameraObj, "UnityEngine.Camera")
    ShareManager.screenCanvasObj = ModuleCache.ComponentManager.Find(ModuleCache.GameManager.gameRoot, "Game/UIRoot/UIWindowParent/CanvasShareOnly")
end




function ShareManager.share_url() 

end

function ShareManager.share_text()

end

function ShareManager.share_image()

end

function ShareManager.share_game()

end

-- 分享应用的下载地址
function ShareManager.shareAppDownload(shareData, timeLine, callback)
    ShareManager.getShareConfig(shareData, function(data)
        local title = data.title
        local url = data.url
        local content = data.message

        if (timeLine) then
            WechatManager.share_url(1, title, content, url)
        else
            WechatManager.share_url(0, title, content, url)
        end
        if callback ~= nil then
            callback();
        end
    end )
end

-- 分享房间
function ShareManager.shareRoomNum(shareData, timeLine)
    ShareManager.getShareConfig(shareData, function(data)
        local title = data.title
        local url = data.url
        local content = data.message
        if (timeLine) then
            WechatManager.share_url(1, title, content, url)
        else
            WechatManager.share_url(0, title, content, url)
        end
    end )
end

-- 纯文本文字分享房间信息，为异步接口，需要注意回调
function ShareManager.share_room_info_text(shareData)
    if ModuleCache.GameManager.iosAppStoreIsCheck then
        return
    end

    ShareManager._startShareRoomInfoText = true
    local get_create_text = function(url)
        if ShareManager._startShareRoomInfoText then
            ModuleCache.GameSDKInterface:CopyToClipboard(ShareManager.createText(shareData, url))
            if ShareManager._curShareRoomTextShowTipsKey ~= shareData.roomId then
                ShareManager._curShareRoomTextShowTipsKey = shareData.roomId
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("房间信息已复制，切换至微信可快速粘贴房间信息")
            end
        end
    end

    if ShareManager._curShareRoomTextClickUrl and ShareManager._curShareRoomKey == shareData.roomId then
        get_create_text(ShareManager._curShareRoomTextClickUrl)
        return
    end

    ShareManager.getShareConfig(shareData, function(data)
        ShareManager._curShareRoomKey = shareData.roomId
        ShareManager._curShareRoomTextClickUrl = data.url
        get_create_text(ShareManager._curShareRoomTextClickUrl)
    end, function (error)
        ShareManager._curShareRoomKey = nil
        ShareManager._curShareRoomTextClickUrl = nil
        get_create_text(ShareManager._curShareRoomTextClickUrl)
    end, true)
end

-- 因为share_room_info_text()为异步接口，所以在清除分享文字的时候需要调用此接口，此接口只删除与房间分享信息匹配的剪切板内容
function ShareManager.clear_share_room_info_text()
    if base.string.find(ModuleCache.FunctionManager.GetTextFromClipboard(), ModuleCache.UnityEngine.Application.productName) then
        ModuleCache.FunctionManager.ClearClipBoard()
    end
    ShareManager._startShareRoomInfoText = false
end

---  w m  占三个空格    i j 占一个空格    其他二个空格
function ShareManager.get_space_num(s)
    local spaceNum  = 0
    local curByte
    local curChar
    for i=1,#s do
        curByte = string.byte(s, i)
        curChar = string.char(curByte)

        if curByte > 127 then
            spaceNum = spaceNum+3
        else
            if curChar == "w" or curChar == "m"then
                spaceNum = spaceNum+3
            elseif curChar == "i" or curChar == "l" or curChar == "j" or curChar == "f" or curChar == "." or curChar == "," then
                spaceNum = spaceNum+1
            else
                spaceNum = spaceNum+2
            end
        end
    end

    return spaceNum
end

---share_room_result_text 纯文本文字分享战绩信息
---@param resultData table
--- resultData.hallID 选填
--- resultData.roomID 必填
--- resultData.playerDatas 必填，玩家分数，数组 [{playerName, score}, {playerName, score}]
--- resultData.startTime, resultData.endTime 选填
--- resultData.dissRoomPlayName 选填 解散房间玩家名字
local shareFormatType ={{"%Y/%m/%d %H:%M:%S","%m/%d %H:%M"},{"总成绩",""} }
function ShareManager.share_room_result_text(resultData)
    if ModuleCache.GameManager.iosAppStoreIsCheck then
        return
    end

    print_table(resultData,"#############share_room_result_text")
    if resultData then
        local copyType = 2--1 -- 1 正常复制    2 是分享到亲友圈聊天
        --if resultData.hallID and resultData.hallID ~= 0 and GameManager.modeData.AppGlobalConfig.parlor_push_settle_enable then
        --    copyType = 2
        --end

        ShareManager._startShareRoomInfoText = false

        local copyText = ""
        if resultData.hallID and resultData.hallID ~= 0 then
            copyText = copyText .. "亲友圈" .. resultData.hallID .. " "
        end

        local startTime, endTime
        if resultData.startTime then
            if type(resultData.startTime) == "string" then
                if copyType == 1 then
                    startTime = base.string.format("开始时间：%s\n", resultData.startTime)
                elseif copyType ==2 then
                    local timeArr = string.split(resultData.startTime, "/")
                    startTime = base.string.format("开始时间：%s\n", timeArr[2].."/"..timeArr[3])
                end

            else
                startTime = base.string.format("开始时间：%s\n", base.os.date(shareFormatType[1][copyType], base.tonumber(resultData.startTime - 2208988800 - 3600 * 8)))
            end
        else
            startTime = ""
        end

        if resultData.endTime then
            if type(resultData.endTime) == "string" then

                if copyType == 1 then
                    endTime = resultData.endTime
                elseif copyType ==2 then
                    local timeArr = string.split(resultData.endTime, "/")
                    endTime = timeArr[2].."/"..timeArr[3]
                end

            else
                endTime = base.os.date(shareFormatType[1][copyType], base.tonumber(resultData.endTime - 2208988800 - 3600 * 8))
            end
        else
            endTime = base.os.date(shareFormatType[1][copyType], base.os.time())
        end
        copyText = copyText .. base.string.format("房号%s\n%s结束时间：%s\n", resultData.roomID, startTime, endTime)

        if resultData.dissRoomPlayName then
            copyText = copyText .. base.string.format("【%s】申请解散\n", resultData.dissRoomPlayName)
        end

       local getChinaNum = function(s)
            local count = 0
            for i=1,#s do
                if string.byte(s, i) >128 then
                    count=count+1
                end
            end

            return   math.min(count/3,4)
        end

        local daYingJia = {name =resultData.playerDatas[1][1], score = resultData.playerDatas[1][2]}
        for i = 1, #resultData.playerDatas do
            --copyText = copyText .. base.string.format("【%-13s%s】%s", Util.filterPlayerName(resultData.playerDatas[i][1],13),"\t", resultData.playerDatas[i][2])

            copyText = copyText .. base.string.format("【%s】 %s", Util.filterPlayerName(resultData.playerDatas[i][1],13), resultData.playerDatas[i][2])
            --copyText = copyText .. base.string.format("【%s】 %s %s", Util.filterPlayerName(resultData.playerDatas[i][1],13),string.rep(" ", math.max(13-  ShareManager.get_space_num(resultData.playerDatas[i][1]) , 0)  ), resultData.playerDatas[i][2])
            if i ~= #resultData.playerDatas then
                copyText = copyText .. "\n"
            end

            if tonumber(resultData.playerDatas[i][2]) > daYingJia.score then
                daYingJia.name = resultData.playerDatas[i][1]
                daYingJia.score = resultData.playerDatas[i][2]
            end
        end

        local shareToMuseum = function(useData)
            print("-----------------大结算  userID=",GameManager.modeData.roleData.userID,string.sub(useData.nickname, 1, 9),string.sub(daYingJia.name, 1, 9),daYingJia.score,GameManager.modeData.AppGlobalConfig.parlor_push_settle_enable)
            if GameManager.modeData.AppGlobalConfig.parlor_push_settle_enable and string.sub(useData.nickname, 1, 9) == string.sub(daYingJia.name, 1, 9) then
                local timestamp = os.time()
                if(GameManager.modeData.getTimeStamp)then
                    timestamp = GameManager.modeData.getTimeStamp()
                end

                ModuleCache.JMsgManager.sendGroupTextMsg(copyText, 1,0, useData,function(data)
                    if data.result == "0" or data.result == 0 then
                        print("#############发送战绩成功#################")
                    else
                        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.desc)
                    end
                end, timestamp)
            end
        end

        local copy = function()
            ShareManager.copyText = copyText
            ModuleCache.FunctionManager.CopyToClipBoard(copyText)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("战绩信息已复制，切换至微信可快速粘贴战绩")

            if resultData.hallID and resultData.hallID ~= 0 then
                if GameManager.modeData.roleData.nickname then
                    shareToMuseum(GameManager.modeData.roleData)
                else
                    local requestData = {
                        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
                        showModuleNetprompt = true,
                        params = {
                            uid = GameManager.modeData.roleData.userID,
                        }
                    }

                    Util.http_get(requestData, function(wwwData)
                        local retData = wwwData.www.text
                        retData = ModuleCache.Json.decode(retData)
                        if(retData.success) then
                            if retData.data then
                                shareToMuseum(retData.data)
                            end
                        else
                            if  retData.errMsg then

                            end
                        end
                    end, function(wwwErrorData)

                    end)
                end
            end
        end

        if resultData.roomID then
            local requestData = {
                baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "room/getUrl?",
                params = {
                    uid = GameManager.modeData.roleData.userID,
                    gameId = ModuleCache.AppData.get_app_and_game_name(),
                    roomNumber = resultData.roomID
                },
            }
            Util.http_get(requestData, function(wwwData)
                local retData = ModuleCache.Json.decode(wwwData.www.text)
                if (retData.ret and retData.ret == 0 and retData.data ~= "") then
                    local url = base.string.gsub(retData.data,"http://","http:// ")
                    copyText = copyText .. "\n查看详情：" .. url
                    copy();
                else
                    copy();
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
                end

            end , function(errorData)
                --base.print(errorData.error)
                copy();
            end )
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请传入roomID")
            if not ModuleCache.GameManager.developmentMode then
                copy()
            end
        end


        --ModuleCache.FunctionManager.CopyToClipBoard(copyText)
        --ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("战绩信息已复制，切换至微信可快速粘贴战绩")


    end
end


function ShareManager.createText(shareData, url)
    local maxPlayer = 6

    if shareData.rule then
        if(type(shareData.rule) == 'table')then
            if shareData.rule.PlayerNum then
                maxPlayer = shareData.rule.PlayerNum
            elseif shareData.rule.playerCount then
                maxPlayer = shareData.rule.playerCount
            end
        elseif(type(shareData.rule) == 'string' and shareData.rule ~= '')then
            local ruleTable = ModuleCache.Json.decode(shareData.rule)
            if ruleTable.PlayerNum then
                maxPlayer = ruleTable.PlayerNum
            elseif ruleTable.playerCount then
                maxPlayer = ruleTable.playerCount
            end
        else
            maxPlayer = shareData.totalPlayer
        end
    else
        maxPlayer = shareData.totalPlayer
    end



    local text = "【" .. shareData.title..", "
    -- 0 麻将馆外的房间   1 麻将馆普通开房  2 麻将馆快速组局的房间 3麻将馆比赛场
    if shareData.roomType == 1 then
        text = text .. "自由开房" .. shareData.roomId .. ", "
    elseif shareData.roomType == 2 then
        text = text .. "快速组局" .. shareData.roomId .. ", "
    else
        text = text .. "房号" .. shareData.roomId .. ", "
    end
    text = text .. shareData.curPlayer .."缺"..(maxPlayer - shareData.curPlayer).."】\n【"..shareData.ruleName.."】\n"
    if url then
        url = base.string.gsub(url,"http://","http:// ")
        text = text.. "【点击链接:" .. url.." 加入房间】\n"
    end
    text = text.."#".. ModuleCache.GameUtil.encodeBase64(ModuleCache.AppData.get_app_and_game_name()) .."#长按复制本信息后打开“"..ModuleCache.UnityEngine.Application.productName.."”即可快速加入房间"
    ModuleCache.Log.print(text, "shareManager.createText")
    return text
end



function ShareManager.share_play_back(userID, playbackId)
    local ShareData = {
        userID = userID
    }
    ShareManager.getShareConfig(ShareData, function(data)
        local title = data.title
        local url = data.url
        local config = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId) or { }
        local name = config.name or ''
        local content = name .. "-快来看我的回放吧，回放码：【" .. playbackId .. "】"
        WechatManager.share_url(0, title, content, url)
    end )
end

-- hide == true 不需要显示该图片，即该图片处于 CameraShareOnly 摄像机下，物体挂载在 CanvasShareOnly 中
-- portrait == true 竖屏，false 横屏
-- 注：分享后会隐藏所有物体，如若下次分享，需要自行显示自己的物体
function ShareManager.shareImage(timeLine, hide, portrait)
    ModuleCache.ModuleManager.hide_public_module("textprompt")

    ShareManager._shareImageTime = ShareManager._shareImageTime or 0

    -- 如果2秒内的话就不让重复
    if Time.realtimeSinceStartup - ShareManager._shareImageTime < 2 then
        return
    end
    ShareManager._shareImageTime = Time.realtimeSinceStartup

    shareImageTimeLine = timeLine

    --ModuleCache.FileUtility.DirectoryDelete(screenShotDirPath, true)
    if not ModuleCache.FileUtility.DirectoryExists(screenShotDirPath) then
        ModuleCache.FileUtility.DirectoryCreate(screenShotDirPath)
    end
    screenPortrait = portrait
    if not hide then
        ModuleCache.Coroutine.StartCoroutine(ShareManager.captureCamera)
    else
        ModuleCache.Coroutine.StartCoroutine(ShareManager.captureCameraNotShow)
    end
end

function ShareManager.captureCameraNew()
    ModuleCache.Coroutine.WaitForEndOfFrame()
    ModuleCache.CustomerUtil.ScreenShotScale(screenShotPath, 50)
    if (shareImageTimeLine) then
        WechatManager.share_image(1, title, screenShotPath)
    else
        WechatManager.share_image(0, title, screenShotPath)
    end
end

function ShareManager.captureCamera()
    -- 需要使用携程，避免ReadPixels was called to read pixels from system frame buffer, while not inside drawing frame
    ModuleCache.Coroutine.WaitForEndOfFrame()
    local screenWith = UnityEngine.Screen.width
    local screenHeight = UnityEngine.Screen.height
    local texture2D_ScreenShot = UnityEngine.Texture2D(screenWith, screenHeight)
    texture2D_ScreenShot:ReadPixels(UnityEngine.Rect(0, 0, screenWith, screenHeight), 0, 0, false);
    texture2D_ScreenShot:Apply()

    --if screenWith > 1280 then
    --    local height = math.ceil(1280 / screenWith * screenHeight)
    --    LuaBridge.TextureScaler.scale(texture2D_ScreenShot, 1280, height, 1)
    --end


    local bytes = UnityEngine.ImageConversion.EncodeToJPG(texture2D_ScreenShot, 50)
    ModuleCache.FileUtility.SaveFile(screenShotPath, bytes, false)
    if (shareImageTimeLine) then
        WechatManager.share_image(1, title, screenShotPath)
    else
        WechatManager.share_image(0, title, screenShotPath)
    end
end

function ShareManager.captureCameraNotShow()
    if not ShareManager.screenCameraObj then
        ShareManager._init()
    end

    ModuleCache.Coroutine.WaitForEndOfFrame()

    -- 显示摄像机
    ShareManager.screenCameraObj:SetActive(true)
    -- 显示画布
    ShareManager.screenCanvasObj:SetActive(true)

    if screenPortrait then
        ShareManager.screenCamera.orthographicSize = 16 / 9
        ModuleCache.CustomerUtil.CaptureCamera(screenShotPath, ShareManager.screenCamera, 0, 0, 720, 1280)
    else
        ShareManager.screenCamera.orthographicSize = 1
        ModuleCache.CustomerUtil.CaptureCamera(screenShotPath, ShareManager.screenCamera, 0, 0, UnityEngine.Screen.width, UnityEngine.Screen.height)
    end

    if (shareImageTimeLine) then
        WechatManager.share_image(1, title, screenShotPath)
    else
        WechatManager.share_image(0, title, screenShotPath)
    end

    -- 隐藏摄像机
    ShareManager.screenCameraObj:SetActive(false)
    -- 隐藏画布
    ShareManager.screenCanvasObj:SetActive(false)
    -- 隐藏画布下的所有子物体
    local children = ModuleCache.ComponentUtil.GetAllChild(ShareManager.screenCanvasObj)
    for i = 0, children.Length - 1 do
        children[i].gameObject:SetActive(false)
    end
    -- 重置横屏
    screenPortrait = false
end

-- 压缩图片，尚未测试，禁用
function ShareManager.CompressPngToJpg(path, width, height, compressRate)
    local width = width or UnityEngine.Screen.width
    local height = height or UnityEngine.Screen.height
    local compressRate = compressRate or 0.5
    return GameManager.CompressPngToJpg(path, width, height, compressRate)
end

-- 获取大厅分享的customdata
function ShareManager.get_hall_share_custom_data()
    local customData = {
        scene = "hallshare",
        appGameName = AppData.get_url_game_name()
    }
    return Util.table_encode_to_json(customData)
end

function ShareManager.getShareConfig(shareData, callback, errorCallback, notShowModuleNetprompt)
    if (not shareData) then
        shareData = { }
    end

    if(shareData.rule and shareData.rule ~= '' )then
        local modelData = require("package.henanmj.model.model_data")
        local ruleTable
        if(type(shareData.rule) == 'table')then
            ruleTable = shareData.rule
        else
            ruleTable = ModuleCache.Json.decode(shareData.rule)
        end
        local gameType = ruleTable.GameType or ruleTable.gameType or ruleTable.game_type or ruleTable.bankerType or 3
        local _,name,wanfaName = Config.GetWanfaIdx(gameType)
        local config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))
        if(modelData.tableCommonData.isGoldTable and shareData.baseScore)then
            shareData.ruleName = string.format('金币场-匹配模式 底分:%d %s', shareData.baseScore, config.PlayRuleText[1])
        end
    end

    if not shareData.userID then
        print("请传入userID")
    end

    if (not shareData.ruleName) then
        -- 规则名
        shareData.ruleName = ""
    end
    if (not shareData.roomId) then
        -- 房间号或者麻将馆房间号
        shareData.roomId = "0"
    end
    if (not shareData.goldId) then
        -- 是否在金币场
        shareData.goldId = 0
    end
    if (not shareData.type) then
        -- 0 麻将馆大厅 1 大厅 2 房间 3 将馆成员分享：30s内申请直接加入
        shareData.type = 1
    end
    if (not shareData.roomType) then
        -- 0 麻将馆外的房间   1 麻将馆普通开房  2 麻将馆快速组局的房间 3麻将馆比赛场
        shareData.roomType = 0
    end
    if (not shareData.parlorId) then
        -- 麻将馆id
        shareData.parlorId = "0"
    end
    if (not shareData.title) then
        -- 名字
        shareData.title = title
    end
    local gameName = AppData.get_url_game_name()

    if (shareData.gameName) then
        gameName = shareData.gameName
    end

    --[[if(shareData.roomType ~= 0) then
        local rules = string.split(shareData.rule, ",")
        local wanfaType = tonumber(rules[2]) + 1
        gameName = Config.wanfaCreateNames[wanfaType]
    end]]

--    -- 根据省id获取省配置表
--    local provinceConfig = PlayModeUtil.getProvinceById(ModuleCache.GameManager.curProvince);
--    -- 根据游戏id获取市配置表
--    local cityConfig = PlayModeUtil.getListByGameId(ModuleCache.GameManager.curGameId);
--    -- 大众玩法需要加上省名
--    if cityConfig.showIndex == 1 then
--        shareData.title = provinceConfig.name .. shareData.title;
--    end

    print_table(shareData)

    local customData = {
        ruleMsg = shareData.ruleName,
        roomId = shareData.roomId,
        parlorId = shareData.parlorId,
        type = shareData.type,
        roomType = shareData.roomType,
        ["local"] = shareData.title,
        goldId = shareData.goldId,
        appGameName = gameName,
        gameName_full = shareData.gameName_full,
    }
    if(shareData.totalPlayer) then ---总人数
        customData.totalPlayer = shareData.totalPlayer
    end
    if(shareData.curPlayer) then ---当前人数
        customData.curPlayer = shareData.curPlayer
    end
    if(shareData.totalGames) then ---总局数
        customData.totalGames = shareData.totalGames
    end
    if(shareData.comeIn) then ---是否可以中途加入
        customData.comeIn = shareData.comeIn
    end

    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "public/getShareConfig?",
        --showModuleNetprompt = true,
        params =
        {
            uid = shareData.userID,
            version = GameManager.appAssetVersion,
            bandId = Application.identifier,
            ruleMsg = shareData.ruleName,
            roomId = shareData.roomId,
            parlorId = shareData.parlorId,
            type = shareData.type,
            roomType = shareData.roomType,
            gameName = gameName,
            ["local"] = shareData.title,
        },
    }

    if not notShowModuleNetprompt then
        requestData.showModuleNetprompt = true
    end

    customData.gameName = requestData.params.gameName
    --if ModuleCache.AppData.Const_App_Bundle_ID then
    --    --requestData.params.gameName = AppData.get_url_game_name() .. "__" .. ModuleCache.AppData.Const_App_Bundle_ID
    --    customData.gameName = requestData.params.gameName
    --end

    requestData.params.customData = Util.table_encode_to_json(customData)

    Util.http_get(requestData, function(wwwData)
        base.print(wwwData.www.text)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        if (retData.ret and retData.ret == 0) then
            callback(retData.data)
        else
            base.print(wwwData.www.text)
        end

    end , function(errorData)
        if errorCallback then
            errorCallback(errorData.error)
        end
        base.print(errorData.error)
    end )
end

return ShareManager