local ModuleCache = ModuleCache
local Log = ModuleCache.Log
local UnityEngine = UnityEngine
local base = _G
-- local GameManager = ModuleCache.GameManager
local AppData = AppData
local string = string
local table = table
local io = io
Util = {}
local Util = Util

function Util.split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end
    local result = {}
    for match in(str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function Util.get_tokenAndTimestamp(userID)
    local timestamp = os.time()
    local token = ModuleCache.SecurityUtil.Getmd5JiaMi(timestamp, userID, AppData.SALT_A, AppData.SALT_B)
    return token, timestamp
end

function Util.formatParamsForHttp(t)
    local str = ""
    local index = 0
    for k,v in pairs(t) do        
        if(index == 0)then
            str = k .. "=" .. Util.encodeURL(v)
        else
          --  print("#########################"..k.."="..v..".")
            str = str .. "&" .. k .. "=" .. Util.encodeURL(v)
        end
        index = 1
    end
    return str
end

function Util.guid()
    local seed = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'}
    local tb = {}
    for i=1,32 do
        table.insert( tb, seed[math.random( 1, 16 )])
    end
    local sid = table.concat(tb)
    return string.format('%s-%s-%s-%s-%s',
        string.sub( sid, 1, 8),
        string.sub( sid, 9, 12),
        string.sub( sid, 13, 16),
        string.sub( sid, 17, 20),
        string.sub( sid, 21, 32)     
    )
end


function Util.getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    
    n = n or 0;
    n = math.floor(n)
    local fmt = '%.' .. n .. 'f'
    local nRet = tonumber(string.format(fmt, nNum))

    return nRet;
end

function Util.filterPlayerGoldNumWan(num)
    local str = ""
    if (num == nil or type(num) ~= "number") then
        return ""
    end
    if (num > 9999 and num < 100000000) then
        str = string.format("%0.1f万", math.floor(num / 10000 * 10) / 10)
    elseif (num > 99999999) then
        str = string.format("%0.2f亿", math.floor(num / 100000000 * 100) / 100)
    else
        return ("" .. num)
    end
    local len = string.len(str)
    local lnum = string.sub(str, len - 3, len - 3)
    local danwei = string.sub(str, len - 2, len)
    local zheng = string.sub(str, 1, len - 5)
    if lnum == "0" then
        str = zheng .. danwei
    end
    return str
end

function Util.filterPlayerGoldNum(num)
    if(num == nil or type(num) ~= "number") then
        return ""
    end

    if(num > 99999 or num < -99999) then
        return string.format("%0.1f万", num / 10000)
    end
    return ("" .. num)
end

function Util.filterPlayerName(name, maxCharLen)
    if(not name or type(name) ~= "string" or name == "") then
        return ""
    end
    maxCharLen = maxCharLen or 8
    local newName = ""
    name = name or ""
    local lenInByte = #name
    local width = 0
    local inputLen = 0
    local i = 1
    local lastNewName = ""
    while (i<=lenInByte) 
    do
        local curByte = string.byte(name, i)
        local byteCount = 1;
        local addLen = 0
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
            addLen = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                               --双字节字符
            addLen = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                               --汉字
            addLen = 2
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
            addLen = 2
        else
            byteCount = 3
            addLen = 2
        end
        if(inputLen + addLen > maxCharLen)then
            return lastNewName .. ".."
        end
        inputLen = inputLen + addLen
        local char = string.sub(name, i, i+byteCount-1)
        i = i + byteCount                                              -- 重置下一字节的索引
        width = width + 1                                             -- 字符的个数（长度）
        lastNewName = newName
        newName = newName .. char
    end
    return newName
end

function string.widthSingle(inputstr)
    -- 计算字符串宽度
    -- 可以计算出字符宽度，用于显示使用
   local lenInByte = #inputstr
   local width = 0
   local i = 1
    while (i<=lenInByte) 
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1                                               --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2                                               --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3                                               --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4                                               --4字节字符
        end
         
        local char = string.sub(inputstr, i, i+byteCount-1)
--        print(char)                                                          --看看这个字是什么
        i = i + byteCount                                              -- 重置下一字节的索引
        width = width + 1                                             -- 字符的个数（长度）
    end
    return width
end

-- @param requestData baseUrl 
-- @param requestData params                --请求参数，如果有uid 那么会自动添加token
-- @param requestData showModuleNetprompt   --是否显示ModuleNetprompt 以阻塞界面
-- @param respone 标题 
-- @param responeError 内容 
-- @param responeCacheData 缓存的数据返回
function Util.http_get(requestData, responeSuccessCallback, responeErrorCallback, responeCacheData, serverErrorCodeCallback)
    local requestUrl = requestData.baseUrl
    if(ModuleCache.GameManager.netAdress and ModuleCache.GameManager.netAdress.httpCurApiUrl)then
        if(requestUrl == ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?")then
            --如果用缓存中的玩家信息则立马返回缓存中的数据，并且继续向远程请求来更新缓存
            if requestData.params and requestData.params.uid and (requestData.use_cache or requestData.only_use_cache)then
                local userInfo_json = Util.get_cache_user_info(requestData.params.uid)
                if(userInfo_json)then
                    local wwwData = {www={text=userInfo_json}}
                    responeSuccessCallback(wwwData)
                end
            end
        end
    end

    if requestData.params then
        if(not requestData.params.gameName) then
            requestData.params.gameName = AppData.get_url_game_name()
        end

        --if requestData.params.userId and not requestData.requestData.params.uid then
        --    requestData.params.uid = requestData.params.userId
        --end

        if requestData.params.uid and not requestData.notRequiredToken then
            requestData.params.token, requestData.params.timestamp = Util.get_tokenAndTimestamp(requestData.params.uid)
        end
        requestData.params.platform = Util.platform
        requestData.params.bundleIdentifier = Util.identifier
        requestData.params.appversion = Util.appversion
        requestData.params.appAssetVersion = ModuleCache.GameManager.appAssetVersion

        requestUrl = requestUrl .. Util.formatParamsForHttp(requestData.params)
    end
    if requestData.showModuleNetprompt then
	    ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    
    local timeOut = 10
    if requestData.cacheDataKey then
        timeOut = 5
    end
    ModuleCache.WWWUtil.GetSafe(requestUrl, timeOut):Subscribe(function(wwwData)
        if requestData.showModuleNetprompt then 
	        ModuleCache.ModuleManager.hide_public_module("netprompt")
        end

        --如果用缓存中的玩家信息则只刷新缓存，不再回调
        if(ModuleCache.GameManager.netAdress and ModuleCache.GameManager.netAdress.httpCurApiUrl)then
            if(requestData.baseUrl == ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?")then
                if requestData.params and requestData.params.uid then
                    local retData = ModuleCache.Json.decode(wwwData.www.text)
                    if retData.ret and retData.ret == 0 then    --OK
                        Util.set_cache_user_info(requestData.params.uid, wwwData.www.text)
                    end
                    if(requestData.only_use_cache)then
                        return
                    end
                end
            end
        end

        -- 因为之前的WWWUtil错误的时候，不会抛出错误，所以打了个补丁
        if responeSuccessCallback then
            responeSuccessCallback(wwwData)
        end

        if requestData.cacheDataKey and wwwData.www.text ~= "" then
            UnityEngine.PlayerPrefs.SetString(requestData.cacheDataKey, wwwData.www.text)
        end

    end, function(wwwData)
        if requestData.showModuleNetprompt then
	        ModuleCache.ModuleManager.hide_public_module("netprompt")
        end

        -- 是否缓存数据,
        if requestData.cacheDataKey and responeCacheData then
            local text = UnityEngine.PlayerPrefs.GetString(requestData.cacheDataKey, "")
            if text ~= "" then
                responeCacheData(text)
                return
            end
        end

        if responeErrorCallback then 
            responeErrorCallback(wwwData)
        end 

        if(wwwData.error and wwwData.error ~= '')then
            local data = Util.parseServerError(wwwData)
            if(data and serverErrorCodeCallback)then
                serverErrorCodeCallback(data)
            end
        end

        print(wwwData.error)
    end)
end

function Util.post_data(requestData, responeSuccessCallback, responeErrorCallback)
    local requestUrl = requestData.baseUrl
    local headers = ModuleCache.CustomerUtil.GenerateEmptyStringStringDic()
    if requestData.headers then
        for i, v in pairs(requestData.headers) do
            headers:Add(i .. '', v .. '')
        end
    end

    if requestData.showModuleNetprompt then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end

    ModuleCache.WWWUtil.Post_Data(requestUrl, requestData.data, headers):Subscribe(function(wwwData)
        if requestData.showModuleNetprompt then
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end

        if responeSuccessCallback then
            responeSuccessCallback(wwwData)
        end
    end, function(wwwData)
        if requestData.showModuleNetprompt then
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
        if responeErrorCallback then
            responeErrorCallback(wwwData)
        end
        print(wwwData.error)
    end)
end

function Util.besthttp_put(requestData, responeSuccessCallback, onProgressCallback, responeErrorCallback)
    local requestUrl = requestData.baseUrl
    local headers = ModuleCache.CustomerUtil.GenerateEmptyStringStringDic()
    if requestData.headers then
        for i, v in pairs(requestData.headers) do
            headers:Add(i .. '', v .. '')
        end
    end

    if requestData.showModuleNetprompt then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    local operation = ModuleCache.BestHttpUtil.Create(requestUrl, 'Put', headers, 0)
    if (requestData.uploadFile) then
        operation:SetUploadStream(requestData.filePath)
    elseif (requestData.uploadBytes) then
        operation:SetStreamData(requestData.bytes)
    end

    operation:Subscribe(function(bestHttpOperation)
        if requestData.showModuleNetprompt then
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end

        if responeSuccessCallback then
            responeSuccessCallback(bestHttpOperation.httpRsp)
        end
    end, nil, function(err)
        if requestData.showModuleNetprompt then
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
        if responeErrorCallback then
            responeErrorCallback(err)
        end
        print(err)
    end)
    operation:Start()
end

function Util.parseServerError(wwwData)
    if tostring(wwwData.error):find("500") ~= nil or tostring(wwwData.error):find("internal server error") ~= nil then
        if wwwData.www.text then
            local retData = wwwData.www.text
            retData = ModuleCache.Json.decode(retData)
            if retData and retData.errMsg then
                retData = ModuleCache.Json.decode(retData.errMsg)
                if retData.code == "INVALID_USER" then
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
                    ModuleCache.GameManager.logout(true)
                end
                return retData
            end
        end
    end
    return nil
end


function Util.encodeURL(s)
    return (string.gsub(s, "([^A-Za-z0-9_])", function(c)
        return string.format("%%%02x", string.byte(c))
    end))
end

function Util.decodeURL(s)
    return (string.gsub(s, "%%(%x%x)", function(hex)
        return string.char(base.tonumber(hex, 16))
    end))
end

--==============================--
--desc:并行请求
--time:2017-04-24 03:33:30
--@requestData:
--@responeSuccessCallback:
--@responeErrorCallback:错误回调，需要等所有的请求都失败才会回调
--return 
--==============================--
function Util.http_get_concurrence(requestData, responeSuccessCallback, responeErrorCallback)
    local requestUrl = requestData.baseUrl
    if requestData.params then
        if requestData.params.uid then
            requestData.params.token, requestData.params.timestamp = Util.get_tokenAndTimestamp(requestData.params.uid)
        end
        requestUrl = requestUrl .. Util.formatParamsForHttp(requestData.params)
    end
    if requestData.showModuleNetprompt then
	    ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    ModuleCache.WWWUtil.GetSafe(requestUrl, 10):Subscribe(function(wwwData)
        if requestData.showModuleNetprompt then 
	        ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
        if responeSuccessCallback then
            responeSuccessCallback(wwwData)
        end
    end, function(wwwData)
        if requestData.showModuleNetprompt then
	        ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
        if responeErrorCallback then 
            responeErrorCallback(wwwData)
        end 
        print(wwwData.error)
    end)
end

--@responeErrorCallback:错误回调，需要等所有的请求都失败才会回调
--return
--==============================--
function Util.http_get_concurrence(requestData, responeSuccessCallback, responeErrorCallback)
    local requestUrl = requestData.baseUrl
    if requestData.params then
        if requestData.params.uid then
            requestData.params.token, requestData.params.timestamp = Util.get_tokenAndTimestamp(requestData.params.uid)
        end
        requestUrl = requestUrl .. Util.formatParamsForHttp(requestData.params)
    end
    if requestData.showModuleNetprompt then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    ModuleCache.WWWUtil.GetSafe(requestUrl, 10):Subscribe(function(wwwData)
        if requestData.showModuleNetprompt then
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
        if responeSuccessCallback then
            responeSuccessCallback(wwwData)
        end
    end, function(wwwData)
        if requestData.showModuleNetprompt then
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
        if responeErrorCallback then
            responeErrorCallback(wwwData)
        end
        print(wwwData.error)
    end)
end


---转换成table
---@param text json内容
---@param urlDecode
function Util.json_decode_to_table(text, urlDecode)
    if urlDecode then
        text = Util.decodeURL(text)
    end
    return ModuleCache.Json.decode(text)
end

---table转换成json
---@param text table
---@param urlEncode table
function Util.table_encode_to_json(text, urlEncode)
    local retData = ModuleCache.Json.encode(text)
    print(retData)
    if urlEncode then
        retData = Util.encodeURL(retData)
    end
    return retData
end

---转换成table
---@param text json内容
---@param urlDecode
function Util.json_decode_to_table(text, urlDecode)
    if urlDecode then
        text = Util.decodeURL(text)
    end
    return ModuleCache.Json.decode(text)
end

---table转换成json
---@param text table
---@param urlEncode table
function Util.table_encode_to_json(text, urlEncode)
    local retData = ModuleCache.Json.encode(text)
    print(retData)
    if urlEncode then
        retData = Util.encodeURL(retData)
    end
    return retData
end

-- 去除字符串两边的空格  
function Util.trim(s)   
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))  
end

function Util.file_copy(sourceFilePath, targetFilePath)
    local file, error = io.open(sourceFilePath, "r")
    if file then
        local text
        if ModuleCache.FunctionManager.isEditor or ModuleCache.GameManager.customPlatformName == "Windows" then
            text = ModuleCache.FileUtility.ReadAllBytes(sourceFilePath)
            ModuleCache.FileUtility.SaveFile(targetFilePath, text, false)
        else
            text = file:read("*all")
            file:close()

            file, error = io.open(targetFilePath, "w")
            if file then
                file:write(text)
                file:close()
            else
                print("保存文件失败：" .. error)
                return false
            end
        end



    else
        print("读取文件失败：" .. error)
        return false
    end
    return true
end

function Util.file_load(filename, model)
    local file
    if filename == nil then
        file = io.stdin
    else
        local err
        file, err = io.open(filename, model or "rb")
        if file == nil then
            Log.print(("Unable to read '%s': %s"):format(filename, err))
            return nil
        end
    end
    local data = file:read("*a")

    if filename ~= nil then
        file:close()
    end

    if data == nil then
        Log.print("Failed to read " .. filename)
    end

    return data
end

function Util.file_save(filename, data, model)
    local file
    if filename == nil then
        file = io.stdout
    else
        local err
        file, err = io.open(filename, model or "wb")
        if file == nil then
            Log.print(("Unable to write '%s': %s"):format(filename, err))
            return nil
        end
    end
    file:write(data)
    if filename ~= nil then
        file:close()
    end
end

function Util.encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end


--解压base64编码的字符串
 function Util.decodeBase64(str64)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local temp={}
    for i=1,64 do
        temp[string.sub(b64chars,i,i)] = i
    end
    temp['=']=0
    local str=""
    for i=1,#str64,4 do
        if i>#str64 then
            break
        end
        local data = 0
        local str_count=0
        for j=0,3 do
            local str1=string.sub(str64,i+j,i+j)
            if not temp[str1] then
                return
            end
            if temp[str1] < 1 then
                data = data * 64
            else
                data = data * 64 + temp[str1]-1
                str_count = str_count + 1
            end
        end
        for j=16,0,-8 do
            if str_count > 0 then
                str=str..string.char(math.floor(data/math.pow(2,j)))
                data=math.fmod(data,math.pow(2,j))
                str_count = str_count - 1
            end
        end
    end
    local check_last = tonumber(string.byte(str, string.len(str), string.len(str)))  
    if check_last == 0 then  
        str = string.sub(str, 1, string.len(str) - 1)  
    end
    return str
end

Util.platform = ModuleCache.CustomerUtil.platform
Util.identifier = UnityEngine.Application.identifier
Util.appversion = UnityEngine.Application.version

function Util.set_cache_user_info(uid, userInfo_json)
    if(not uid)then
        return
    end
    UnityEngine.PlayerPrefs.SetString('cached_userInfo_' .. uid, userInfo_json)
end

function Util.get_cache_user_info(uid)
    if(not uid)then
        return nil
    end
    local userInfo_json = UnityEngine.PlayerPrefs.GetString('cached_userInfo_' .. uid, '')
    if(userInfo_json == '')then
        return nil
    end
    return userInfo_json
end


return Util