-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("RoomDetailModule", ModuleBase)
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine


function RoomDetailModule:initialize(...)
    ModuleBase.initialize(self, "roomDetail_view", nil, ...)
end

function RoomDetailModule:on_show(data)

    self.roomDetailView:init(data);
end


function RoomDetailModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.roomDetailView.buttonBack.gameObject then
        ModuleCache.ModuleManager.destroy_module('daigoutui', "roomdetail");
        return
    elseif obj == self.roomDetailView.buttonLookMatch.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "playvideo", function(data)
            if(data.ret and data.ret == 0)then
                ModuleCache.ModuleManager.destroy_module("henanmj", "playvideo")
                local recordID = data.data.recordId
                self:playVideo(recordID)
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
            end
        end)
    elseif obj.name == "ButtonShare" then
        local recordID = self.view:getPlayerScoreList(obj.transform.parent.parent.name).recordId
        TableManager:share_play_back_id(recordID, self.view:getRoomID())
    elseif obj.name == "ButtonPlayVideo" then
        local recordID = self.view:getPlayerScoreList(obj.transform.parent.parent.name).recordId
        self:playVideo(recordID)
    end
end

function RoomDetailModule:playVideo(recordId)
    self:get_videoData(recordId, function(data)
        self:on_videoData(data)
    end)
end

function RoomDetailModule:on_videoData(data)
    if(data.ret and data.ret ~= 0)then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.errMsg)
        return
    end
    local intentData = {
        packageName = 'daigoutui',
        moduleName = 'table_video',
        videoData = data,
    }
    ModuleCache.ModuleManager.show_module("daigoutui", "table_video_player", intentData)
end

function RoomDetailModule:get_videoData(recordId, callback)
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

return RoomDetailModule