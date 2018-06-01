-- -
--- Created by jyz.
--- DateTime: 2018/1/4 下午2:30
--- 注释 是为了更好的遗忘
-- -

local ModuleCache = ModuleCache
local UnityEngine = UnityEngine
local json = require("cjson")
local ModuleEventBase = require('core.mvvm.module_event_base')

local tostring = tostring
--- @class JpushManager
local manager = { }
local iosTagStyle = '{"tags":[%s]}'
local iosAStyle = '{"alias":"%s"}'
manager.data = { }
manager.taglist = { }
manager.aliaslist = { }
function manager.init(userId)
    manager.data.platform = tostring(UnityEngine.Application.platform)
    ModuleCache.GameSDKInterface:JPushInit()
    manager.data.userId = userId
    manager.setTag()
    manager.setAlias()
    ModuleCache.WechatManager.onJPushRecvMessage = manager.onRecv
    print("jpush init ok")
end
function manager.setTag()
    local tagStr = ''
    local plus = ""
    if manager.data.platform == 'IPhonePlayer' then
        plus = '"'
    end
    if manager.taglist then
        for k, v in ipairs(manager.taglist) do
            tagStr = tagStr .. plus .. v .. plus .. ','
        end
    end
    tagStr = tagStr .. plus .. ModuleCache.AppData.get_url_game_name() .. plus .. ','
    if ModuleCache.GameManager.developmentMode then
        tagStr = tagStr .. plus .. 'TAG_TEST' .. plus .. ','
    end
    if manager.data.platform == 'Android' then
        tagStr = tagStr .. plus .. 'TAG_ANDROID' .. plus
    end
    if manager.data.platform == 'IPhonePlayer' then
        tagStr = tagStr .. plus .. 'TAG_IOS' .. plus
        tagStr = string.format(iosTagStyle, tagStr)
    end
    print("Jpush SetTags: ", tagStr)
    -- print("ios style",string.format(iosTagStyle,tagStr))
    ModuleCache.GameSDKInterface:JPushSetTags(tagStr)
end
function manager.setAlias(userId)
    if userId then
        manager.data.userId = userId
    else
        userId = manager.data.userId
    end
    local aliasStr = ''
    aliasStr = aliasStr .. userId
    if manager.data.platform == 'IPhonePlayer' then
        aliasStr = string.format(iosAStyle, aliasStr)
    end
    print("Jpush SetAlias: ", aliasStr)
    -- print("ios style",string.format(iosAStyle,aliasStr))
    ModuleCache.GameSDKInterface:JPushSetAlias(aliasStr)
end
function manager.setTagWithPyq(pyqId)
    manager.taglist = { }
    local pyq = "parlor_"..pyqId
    manager.taglist[1] = pyq
    manager.setTag()
    manager.taglist = { }
end
function manager.onRecv(data)
    print("onJPushRecvMessage", data)
    local xxoo = ModuleCache.Json.decode(data)
    print_table(xxoo,"-----------jpush_manager-------onRecv--------")
    if xxoo.type == "custom_notify" then
        return
    end
    local isLogin = ModuleCache.ModuleManager.module_is_active("henanmj", "login")

    if xxoo.type == "broadcast_message" then
        local content = ModuleCache.Json.decode(xxoo.message).content
        ModuleCache.ModuleManager.show_public_module("textprompt"):add_system_announce(content)
    end

    if not isLogin and xxoo.type == "room_message" then
        local content = ModuleCache.Json.decode(xxoo.message).content
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips_redpacket(content);
    end

    if ModuleCache.ModuleManager.module_is_active("henanmj", "chessmuseum") then
        ModuleCache.ModuleManager.get_module("henanmj","chessmuseum"):dispatch_module_event("jPush_manager","jPush_recv_msg",xxoo)
    end

end
return manager