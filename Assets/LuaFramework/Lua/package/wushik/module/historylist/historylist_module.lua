-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local HistoryListModule = class("HistoryListModule", ModuleBase)
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local cjson = require("cjson");

function HistoryListModule:initialize(...)
    ModuleBase.initialize(self, "historyList_view", nil, ...)
end

function HistoryListModule:on_show(data)

    self.historyListView:init(data);
end

function HistoryListModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")

    -- 返回按钮
    if obj == self.historyListView.buttonBack.gameObject then
        ModuleCache.ModuleManager.destroy_module('wushik', "historylist");
        -- 查看对局按钮
    elseif obj == self.historyListView.buttonLookMatch.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "playvideo", function(data)
            if(data.ret and data.ret == 0)then
                ModuleCache.ModuleManager.destroy_module("henanmj", "playvideo")
                local recordID = data.data.recordId
                self:playVideo(recordID)
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
            end
        end)
        -- 点击战绩item模板
    elseif obj.transform.parent.gameObject == self.historyListView.item.transform.parent.gameObject then
        -- 通过索引获取历史战绩信息
        local historyData = self.historyListView:getHistoryDataByIndex(obj.name);
        -- 请求获取房间列表协议
        self:getRoomList(historyData);
    end
end

-- 请求获取房间列表协议
function HistoryListModule:getRoomList(roomInfo)
    print_table(roomInfo);
    print("==api=" .. ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/roundlist/v3?")
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/roundlist/v3?",
        showModuleNetprompt = true,
        params =
        {
            uid = self.modelData.roleData.userID,
            roomid = roomInfo.id
        },
    }

    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            -- OK
            --            local sendData =
            --            {
            --                roomInfo = roomInfo,
            retData.data.creatorId = roomInfo.creatorId;
            retData.data.roomID=roomInfo.id
            retData.data.playRule = roomInfo.playRule

            --            }
            -- print("====================sendData")
            -- print_table(sendData)
            ModuleCache.ModuleManager.show_module('wushik', "roomdetail", retData.data)
        else

        end
    end , function(error)
        print("==error=" .. error.error)
    end )
end


function HistoryListModule:playVideo(recordId)
    self:get_videoData(recordId, function(data)
        self:on_videoData(data)
    end)
end

function HistoryListModule:on_videoData(data)
    if(data.ret and data.ret ~= 0)then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.errMsg)
        return
    end
    local intentData = {
        packageName = 'wushik',
        moduleName = 'table_video',
        videoData = data,
    }
    ModuleCache.ModuleManager.show_module("wushik", "table_video_player", intentData)
end

function HistoryListModule:get_videoData(recordId, callback)
    local requestData = 
    {
        showModuleNetprompt = true,
		params = 
        {
			uid = self.modelData.roleData.userID,
            recordId = recordId
		},
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/playback?",
	}
    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
            if(callback)then
                callback(retData)
            end
    end , function(errorData)
        print(errorData.error)
    end )
end
return HistoryListModule