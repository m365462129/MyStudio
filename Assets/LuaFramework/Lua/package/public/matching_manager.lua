local NetClientManager = ModuleCache.net.NetClientManager
local AppData = AppData
local class = require("lib.middleclass")
local Model = require('core.mvvm.model_base')
local ModuleEventBase = require('core.mvvm.module_event_base')
---@class MatchingManager
local MatchingManager = class('MatchingManager', Model)
local CSmartTimer = ModuleCache.SmartTimer.instance
local ModuleCache = ModuleCache
local max_reconnect_game_server_times = 7
local PlayerPrefs = UnityEngine.PlayerPrefs
local TableManager = TableManager
local Util = require('util.game_util')
local ComponentUtil = ModuleCache.ComponentUtil
--local ModuleEventBase = require('core.mvvm.module_event_base')

function MatchingManager:gold_continue(goldid,coin,minJoinCoin,maxJoinCoin,onFinish)
    if coin >= minJoinCoin and coin < maxJoinCoin then
        ModuleCache.ModuleManager.show_module("public", "tablematch")
        TableManager:disconnect_game_server()
        TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,goldid, nil, nil)
        if onFinish then
            onFinish()
        end
    else
        self:get_quickJoin_data(function (data)
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
                    "您的金币不匹配当前场次，是否去往" .. data.goldName .. "?", function()
                        TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,
                                data.goldId, nil, nil)
                        if onFinish then
                            onFinish()
                        end
                    end, function()
                        ModuleEventBase:dispatch_package_event("Event_GoldJump_error")
                    end, true, "确定", "取消")
        end,function ()
            ModuleEventBase:dispatch_package_event("Event_GoldJump_error")
        end)
    end
end


function MatchingManager:getGoldById(goldid,func)
    local addStr = "gold/getById?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            goldId = goldid,
            uid = self.modelData.roleData.userID
        }
    }
    Util.http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            func(retData.data)
        else
            ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
    end )
end

function MatchingManager:gold_jump(goldid)
    local addStr = "gold/getById?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            goldId = goldid,
            uid = self.modelData.roleData.userID
        }
    }
    Util.http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            self:gold_jump_deal(retData.data)
        else
            ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
    end )
end
--小于2000 -> 救济金次数 > 0 -> 弹出救济金 否则弹出充值
function MatchingManager:gold_jump_deal(info)
    self:get_userinfo(function(roleData)
        if roleData.gold < info.minJoinCoin then
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
                    "您的金币不足" .. info.minJoinCoin .. ",无法进入" .. info.goldName .. "!是否需要充值", function()
                        ModuleCache.ModuleManager.show_module("henanmj", "shop",5)
                        ModuleEventBase:dispatch_package_event("Event_GoldJump_error")
                    end, function()
                        ModuleEventBase:dispatch_package_event("Event_GoldJump_error")
                    end, true, "充值", "取消", "金币不足")
        elseif roleData.gold > info.maxJoinCoin then
            self:get_quickJoin_data(function(data)
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
                        "您的金币超过" .. info.maxJoinCoin .. ",无法进入" .. info.goldName .. "!是否去往" .. data.goldName, function()
                            TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,
                                    data.goldId, nil, nil)
                        end, function()
                            ModuleEventBase:dispatch_package_event("Event_GoldJump_error")
                        end, true, "确定", "取消")
            end, function()
                ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
            end)
        else
            TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,
                    info.goldId, nil, nil)
        end
    end, function()
        ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
    end)

end
--弹出救济金
function MatchingManager:jump_jiujijin()
    self:get_userinfo(function(roleData)
        if roleData.gold < 2000 then
            self:jiujijin(function(times)
                if times > 0 then
                    ModuleCache.ModuleManager.show_module("public", "relief")
                end
            end)
        end
    end)
end

function MatchingManager:jiujijin(f, errorcallback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/getBankruptcyDetail?",
        showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
        }
    }

    Util.http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        if retData.ret == 0 then
            f(retData.data.receiveCount)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
            if errorcallback then
                errorcallback()
            end
        end

    end, function(wwwErrorData)
        print(wwwErrorData.error)
        if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
            if wwwErrorData.www.text then
                local retData = wwwErrorData.www.text
                retData = ModuleCache.Json.decode(retData)
                if retData.errMsg then
                    retData = ModuleCache.Json.decode(retData.errMsg)
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
                end
            end
        end
        if errorcallback then
            errorcallback()
        end
    end)
end
function MatchingManager:get_quickJoin_data(f, errorcallback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/quickJoin?",
        params = {
            uid = self.modelData.roleData.userID,
            tagCode = self.gameType
        }
    }
    Util.http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            if type(retData.data ) == "table" then
                f(retData.data)
            else
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否需要充值？", function()
                    ModuleCache.ModuleManager.show_module("henanmj", "shop",5)
                end, function()
                    print("点击取消充值，销毁牌桌")
                    ModuleEventBase:dispatch_package_event("Event_GoldJump_error")
                end, true, "充值", "关闭", "金币不足")
            end
        else
            if errorcallback then
                errorcallback()
            end
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        if errorcallback then
            errorcallback()
        end
    end)
end

function MatchingManager:getmatchbyid(id, stageId, successCallback, errorCallback)
    local addStr = "match/getById?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
            matchId = id,
            stageNum = stageId
        }
    }
    Util.http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) and successCallback then
            successCallback(retData)
        else
            if errorCallback then
                errorCallback()
            end

        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        if errorCallback then
            errorCallback()
        end
    end )
end

function MatchingManager:goodsName(type, num, name, othername)

    if type == 10 then
        return name .. " x" .. num
    elseif type == 12 then
        return othername .. " x" .. num
    elseif type == 1 then
        return "钻石x" .. num
    elseif type == 5 then
        return "金币x" .. Util.filterPlayerGoldNumWan(num)
    else
        return num .. ""
    end
end
function MatchingManager:goodsNameAndIcon(type, icon, text, num, name, url, othername, othericon, spriteholder)
    if type == 10 then
        self:startDownLoadHeadIcon(icon, url )
        text.text = name .. " x" .. num
        ComponentUtil.SafeSetActive( icon.transform.gameObject, true);
    elseif type == 12 then
        self:startDownLoadHeadIcon(icon, othericon )
        text.text = othername .. " x" .. num
        ComponentUtil.SafeSetActive( icon.transform.gameObject, true);
    elseif type == 11 then
        text.text = "红包" .. num
        ComponentUtil.SafeSetActive( icon.transform.gameObject, false);
    elseif type == 13 then
        text.text = "随机"
        ComponentUtil.SafeSetActive( icon.transform.gameObject, false);
    elseif type == 1 or type == 5 then
        icon.sprite = spriteholder:FindSpriteByName(type .. "");
        text.text = Util.filterPlayerGoldNumWan(num)
        ComponentUtil.SafeSetActive( icon.transform.gameObject, true);
    else
        text.text = ""
        ComponentUtil.SafeSetActive( icon.transform.gameObject, false);
    end
end
--下载头像
function MatchingManager:startDownLoadHeadIcon(targetImage, url)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (not err) then
            if targetImage then
                targetImage.sprite = tex
                targetImage:SetNativeSize();
            end
        end
    end)
end
--显示名次
function MatchingManager:matchAwards(matchid, stageid, rank)
    if rank <= 3 then
        local data = {
            matchId = matchid,
            stageId = stageid,
            rank = rank
        }
        ModuleCache.ModuleManager.show_public_module("matchawards", data)
    else
        local onYesButton = function()
            -- 返回大厅
            ModuleEventBase:dispatch_package_event( 'Event_GoldMatching_Quit')
            ModuleEventBase:dispatch_package_event( 'Event_GoldJump_error')
        end
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("确定", onYesButton);
        local data = {
            text = "本次比赛结束,您获得了" .. rank .. "名!再接再厉~",
            title = "比赛结束",
        }
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_custom(data);
    end
end


--获取幸运宝箱次数
function MatchingManager:get_luckybox_times(callback, errorcallback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getActivityListByCode?",
        showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
            gameId = AppData.get_app_and_game_name(),
            code = "open_chest"
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) and retData.data and #retData.data > 0 then
            if callback then
                callback(retData.data[1])
            end
        else
            if errorcallback then
                errorcallback()
            end

        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        if errorcallback then
            errorcallback()
        end
    end )
end

--获取幸运宝箱开启状态
function MatchingManager:get_luckybox_status(callback, errorcallback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getOpenChest?",
        params = {
            uid = self.modelData.roleData.userID,
            gameId = AppData.get_app_and_game_name()
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) and callback then
            callback(retData.data)
        else
            if errorcallback then
                errorcallback()
            end
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        if errorcallback then
            errorcallback()
        end
    end )
end

function MatchingManager:get_userinfo(callback, errorcallback)
    if not self.modelData.roleData.userID then
        return
    end
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = self.modelData.roleData.userID,
        }
    }
    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            -- OK
            callback(retData.data)
        else
            if errorcallback then
                errorcallback()
            end
        end
    end, function(error)
        print(error.error)
        if errorcallback then
            errorcallback()
        end

    end, nil )
end

function MatchingManager:initialize(...)
    Model.initialize(self, ...)
    self.modelData = require("package.henanmj.model.model_data")
end

MatchingManager:initialize('public')

return MatchingManager