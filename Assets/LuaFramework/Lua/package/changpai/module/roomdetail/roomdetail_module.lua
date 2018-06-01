-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
local BranchPackageName = AppData.BranchChangPaiName
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("RoomDetailModule", ModuleBase)
local ModuleCache = ModuleCache
local Buffer = ModuleCache.net.Buffer


function RoomDetailModule:initialize(...)
    ModuleBase.initialize(self, "roomDetail_view", nil, ...)
end

function RoomDetailModule:on_show(data)

    self.roomDetailView:init(data)
    self.players = data.players
end


function RoomDetailModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.roomDetailView.buttonBack.gameObject then
        ModuleCache.ModuleManager.destroy_module(BranchPackageName, "roomdetail");
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
    self:get_videoData(recordId, self.players)
end

function RoomDetailModule:get_videoData(recordId, players)
    self:get_play_back_info(recordId, function(gamestates, data)
        local index = 1
        for i = 1, #players do
            local userId = players[i].userId
            if userId .. "" == self.modelData.roleData.userID then
                index = i
            end
        end
        TableManager.curTableData =
        {
            isPlayBack = true,
            SeatID = index - 1,
            videoData = data,
            modelData = self.modelData,
            gamestates = gamestates,
            players = players
        }
        ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.destroy_package("changpai")
        ModuleCache.ModuleManager.destroy_package("public")
        ModuleCache.ModuleManager.show_module_only("changpai", "table")
        ModuleCache.ModuleManager.show_module("changpai", "playback")
    end)
end

function RoomDetailModule:get_play_back_info(playbackId, callback)
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local requestData = {
        params = {
            uid = self.modelData.roleData.userID,
            recordId = playbackId
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/playback?",
    }

    ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        if (string.find(www.text, "ret") ~= nil and string.find(www.text, "{") ~= nil) then
            local retData = ModuleCache.Json.decode(www.text)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            return
        end
        local buffer = Buffer.Create(0)  --会在C#层自动回收
        local videoData = buffer:GetPlayBackInfo(www.bytes)
        if not videoData then
            print("回放数据非法")
            return
        end
        local videoTable = nil
        if videoData.rule then
            videoTable = {}
            videoTable.gamerule = videoData.rule
        else
            videoTable = self:unpack_msg_new("Msg_VideoCode", videoData.headData)
        end
        local gamestates = {}
        for i = 1, videoData.frames.Count do
            local retData, error = self:unpack_msg_new("Msg_Table_GameStateNTF", videoData.frames[i - 1].buffer)
            table.insert(gamestates, retData)
        end

        callback(gamestates, videoTable)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
    end, function(error)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
    end)
end

function RoomDetailModule:unpack_msg_new(msgName, dataBuffer)
    local api = require("package.changpai.model.net.net_msg_data_map")
    local ret = api:create_ret_data(msgName)
    ret:ParseFromString(dataBuffer)
    return ret
end

return RoomDetailModule