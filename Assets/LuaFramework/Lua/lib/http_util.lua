local uWWWUtil = LuaBridge.WWWUtil

local HttpUtil = {}
HttpUtil.commonParameter = {}

--==============================--
--desc:设置公共参数
--time:2017-06-08 10:03:36
--@key:
--@value:
--return 
--==============================--
function HttpUtil.set_common_parameter(key, value)
    if not HttpUtil.commonParameter then
        HttpUtil.commonParameter = {}
    end
    HttpUtil.commonParameter.key = value
end

function HttpUtil.format_params_for_http(t)
    local str = ""
    local index = 0
    for k,v in pairs(t) do        
        if index == 0 then
            str = k .. "=" .. HttpUtil.encode_url(v)
        else
            str = str .. "&" .. k .. "=" .. HttpUtil.encode_url(v)
        end
        index = 1
    end
    return str
end

function HttpUtil.encode_url(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end


-- @param requestData baseUrl 
-- @param requestData params                --请求参数，如果有uid 那么会自动添加token
-- @param requestData showModuleNetprompt   --是否显示ModuleNetprompt 以阻塞界面
-- @param respone 标题 
-- @param responeError 内容 
function HttpUtil.get(requestData, responeSuccessCallback, responeErrorCallback)
    local requestUrl = requestData.baseUrl
    if requestData.params then
        if requestData.params.uid and not requestData.notRequiredToken then
            requestData.params.token, requestData.params.timestamp = Util.get_tokenAndTimestamp(requestData.params.uid)
        end
        requestUrl = requestUrl .. HttpUtil.format_params_for_http(requestData.params)
    end
    if HttpUtil.commonParameter then
        requestUrl = requestUrl .. HttpUtil.format_params_for_http(HttpUtil.commonParameter)
    end

    if requestData.showModuleNetprompt then
	    ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    
    ModuleCache.WWWUtil.GetSafe(requestUrl, 12):Subscribe(function(wwwData)
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

function HttpUtil.getSafe(url, overTime)
    return uWWWUtil.GetSafe(url, overTime)
end

-- 并发请求
function HttpUtil.getConcurrence(urls, overTime, sucess, error)
    
    return uWWWUtil.Get(url)
end

return WWWUtil