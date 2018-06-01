--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local list = require("list")
local ModuleBase = require('core.mvvm.module_base')
---@class PaoHuZiTableBaseModule
---@field model PaoHuZiTableBaseModel
---@field tableBaseModel PaoHuZiTableBaseModel
---@field view PaoHuZiTableBaseView
---@field tableBaseView PaoHuZiTableBaseView
local TableBaseModule = class('tableBaseModule', ModuleBase)
local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameSDKInterface = ModuleCache.GameSDKInterface
local WechatManager = ModuleCache.WechatManager
local Time = UnityEngine.Time
local TableManager = TableManager
local delayRefreshTime = 0.2
local audioMusic = ModuleCache.SoundManager.audioMusic
local string = string
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")


function TableBaseModule:initialize(...)
    ModuleBase.initialize(self, ...)
    self.netClient = self.modelData.bullfightClient
    self.table_gift_module = ModuleCache.ModuleManager.show_module('public','table_gift')
    self.table_voice_module = ModuleCache.ModuleManager.show_module('public','table_voice')
    
    self:on_module_initedSelf()

    self.resultWait = true
    self.view:refresh_voice_shake()

    

    self:start_lua_coroutine(function ()
        while self.view do
            self:on_update_per_secondOn()
            coroutine.wait(1)
        end
    end)


end




function TableBaseModule:on_module_initedSelf(...)

    self.lastPingTime = Time.realtimeSinceStartup
    self.model.lastReceiveHeartPackTime = Time.realtimeSinceStartup

    
    self.gameClient = self.modelData.gameClient
end

function TableBaseModule:getTableKeyCount(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function TableBaseModule:on_module_event_bind()

    ---实时游戏状态
    self:subscibe_model_event("Event_Msg_Table_GameStateNTF", function(eventHead, eventData)
        self.gameState = eventData
        self:refresh_game_state(self.gameState)
    end)

    self:subscibe_model_event("Event_Msg_RoomUserInfoNTF", function(eventHead, eventData)
        self:refresh_seat_info(eventData)
    end)

    self:subscibe_model_event("Event_Msg_Table_UserStateNTF", function(eventHead, eventData)
        
        self:refresh_user_state(eventData)

        --进入牌桌请求同步踢人倒计时  断线重连
        self.model:request_get_kicked_timeout()
    end)

    self:subscibe_model_event("Event_Msg_RoomUserOnlineNTF", function(eventHead, eventData)
        self:refresh_user_online(eventData)
    end)

    self:subscibe_model_event("Event_Msg_RoomUserOfflineNTF", function(eventHead, eventData)
        self:refresh_user_offline(eventData)
    end)

    self:subscibe_model_event("Event_Msg_KickedNTF", function(eventHead, eventData)
        self:exit_room("您已被房主踢出房间")
    end)

    self:subscibe_model_event("Event_Msg_SameUserLoginNTF", function(eventHead, eventData)
        ModuleCache.ModuleManager.destroy_module("paohuzi", "table")
        ModuleCache.ModuleManager.destroy_package("paohuzi")
        -- ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("您已经断开连接，请重新登陆", function()
        -- 	ModuleCache.GameManager.logout(true);
        -- end)
    end)

    self:subscibe_model_event("Event_Msg_DismissNTF", function(eventHead, eventData)
        if (#eventData.Action == 0) then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已拒绝解散房间，游戏继续")
            ModuleCache.ModuleManager.hide_module("paohuzi", "dissolveroom")
        else
            ModuleCache.ModuleManager.show_module("paohuzi", "dissolveroom", eventData)
        end
    end)

    self:subscibe_model_event("Event_Msg_RoomDismissedNTF", function(eventHead, eventData)
        self:exit_room("已解散房间")
    end)

    self:subscibe_model_event("Event_Msg_ReportStateNTF", function(eventHead, eventData)
        self:refresh_report_state(eventData)
    end)


    self:subscibe_model_event("Event_Msg_MessageNTF", function(eventHead, eventData)
        --收到聊天消息
        TableUtilPaoHuZi.print("收到聊天消息")
        self:refresh_chat_message(eventData)
    end)

    self:subscibe_model_event("Event_Private_MessageNTF", function(eventHead, eventData)
        self:refresh_private_message(eventData)
    end)


    



    -- 退出房间
    self:subscibe_model_event("Event_Msg_Exit_Room", function(eventHead, eventData)
        -- 这个侯震哥哥注释掉的我为什么要加上呢
        if (eventData.Error and eventData.Error == 0) then
            self:exit_room()
            --if ModuleCache.ModuleManager.module_is_active("paohuzi", "totalresult") then
            --    TableManager:disconnect_all_client_no_exit_room()
            --    self:dispatch_module_event("roomsetting", "Event_Receive_Msg_Exit_Room")
            --else
            --    self:exit_room()
            --end
        else
            TableUtilPaoHuZi.print("退出房间=====================")
            if ModuleCache.ModuleManager.module_is_active("paohuzi", "totalresult") then
                self:exit_room()
            else
                if eventData.Error == -1 then
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("牌局进行中,无法离开游戏")
                else
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("离开房间失败:" .. eventData.Error)
                end
            end
        end
    end)

    -- 离开房间
    self:subscibe_module_event("roomsetting", "Event_RoomSetting_ExitRoom", function(eventHead, eventData)
        self.model:request_exit_room()
    end)
    -- 离开房间
    self:subscibe_module_event("totalresult", "Event_RoomSetting_ExitRoom", function(eventHead, eventData)
        self.model:request_exit_room()
        
    end)


    self:subscibe_module_event("tablechat", "Event_Send_ChatMsg", function(eventHead, eventData)
        self.model:request_chat(eventData)
    end)

    self:subscibe_package_event("Event_Send_ChatMsg", function(eventHead, eventData)
        TableUtilPaoHuZi.print("发送聊天消息请求》》")
        self.model:request_chat(eventData)
    end)
    self:subscibe_package_event("Event_Client_ChatMsg", function(eventHead, eventData)
        local textIndex = tonumber(eventData.content)
        TableUtilPaoHuZi.print("--------", textIndex)
        if (self.view.openVoice) then
            self:player_shot_voice(textIndex, TableManager.phzTableData.SeatID)
        end
    end)

    self:subscibe_module_event("dissolveroom", "Event_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData)
    end)

    self:subscibe_module_event("roomsetting", "Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData)
    end)

    self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData)
    end )

    self:subscibe_package_event("Event_Refresh_Voice_Shake", function(eventHead, eventData)
        self.view:refresh_voice_shake()
        TableManager:refresh_voice_shake()
    end)



    --self:subscibe_module_event("playback", "Event_PlayBackFrame", function(eventHead, eventData)
    --    if (eventData) then
    --        self.gameState = eventData
    --        self:refresh_game_state(eventData)
    --    end
    --end)

    --self:subscibe_module_event("playback", "Event_Msg_Table_UserStateNTF", function(eventHead, eventData)
    --    self:refresh_user_state(eventData)
    --    --self:refresh_user_state(eventData)
    --end)

    self:subscibe_model_event("Event_Msg_RoomAwardMessageNTF", function(eventHead, eventData)
        local roomAwardTable = self:get_room_award_table(eventData)
        if (roomAwardTable) then
            ModuleCache.ModuleManager.show_public_module("redpacket", roomAwardTable)
        end
    end)

    self:subscibe_package_event("Event_TableVoice_StartPlayVoice", function(eventHead, eventData)
        if eventData ~=nil then
            self:show_voice(eventData)
        end
    end)
    self:subscibe_package_event("Event_TableVoice_StopPlayVoice", function(eventHead, eventData)
        if eventData ~=nil then
            self:hide_voice(eventData)
        end
    end)
    self:subscibe_package_event("Event_TableVoice_SendVoice", function(eventHead, eventData)
        local chatTextBubbleData =
        {
            content = eventData,
            voice = eventData,
            chatType = 0,
            userId = self.modelData.roleData.userID
        }
        self.model:request_chat(chatTextBubbleData)
    end)

    self:subscibe_package_event("Event_PlayerInfo_SendGift", function(eventHead, eventData)
        local seatId
        for i, v in pairs(TableManager.phzTableData.seatUserIdInfo) do
            if(v == eventData.receiver)then
                seatId = tonumber(i)
            end
        end
        if(seatId)then
            local gift = {
                receiver = seatId,
                giftName = eventData.giftName,
            }
            local text = ModuleCache.Json.encode(gift)
            local chatTextBubbleData =
            {
                content = text,
                voice = text,
                chatType = 10,
                userId = self.modelData.roleData.userID
            }
            self.model:request_chat(chatTextBubbleData)
        end
    end)

    self.onAppFocusCallback = function(eventHead, eventData)
        if eventData then
            self.model:request_report_player(0)

            --后台切换请求同步踢人倒计时
            self.model:request_get_kicked_timeout()
        else
            self.model:request_report_player(1)
        end
    end
    self:subscibe_app_focus_event(self.onAppFocusCallback)

    --进入牌桌请求同步踢人倒计时  断线重连
    self.model:request_get_kicked_timeout()


    self:subscibe_model_event("Event_Table_Leave_Room_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            --TODO XLQ 金币场
            TableManagerPoker:disconnect_game_server()

            -- 金币场 退出
            ModuleCache.ModuleManager.destroy_package("paohuzi")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_Leave_Room_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
       
    end )

    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.model:request_ACTION_REFRESH_COINS()
    end)

    --TODO XLQ:踢人倒计时
    self:subscibe_model_event("Event_Msg_ReturnKickedTimeOutNTF", function(eventHead, eventData)
        print("============Kickedtimeout :",eventData.Time)
        self.view.btnStartZhunBei_museum_cd_obj:SetActive(true)

        if self.kickedTimeId then
            CSmartTimer:Kill(self.kickedTimeId)
        end

        self.kickedTimeId = self:subscibe_time_event(eventData.Time, false, 1):OnUpdate(function(t)
            t = t.surplusTimeRound
            if self.view.btnStartZhunBei_museum_cd_tex then
                self.view.btnStartZhunBei_museum_cd_tex.text = "("..t.."s)"
            end
        end):OnComplete(function(t)
            self.view.btnStartZhunBei_museum_cd_obj:SetActive(false)
        end).id
    end)

end

--- 实时刷新游戏状态
--- @param data GAME_STATE
function TableBaseModule:refresh_game_state(data)

end

--- 房间内用户上线
function TableBaseModule:refresh_user_online(data)

end

--- 房间内用户离线
function TableBaseModule:refresh_user_offline(data)

end

--- 玩家即时反馈的状态
function TableBaseModule:refresh_report_state(data)

end

--- 单独聊天信息
function TableBaseModule:refresh_private_message(data)

end

----- 刷新用户状态
--function TableBaseModule:refresh_user_state(data)
--    self:invite_friend(true)
--end

--- 刷新座位信息
function TableBaseModule:refresh_seat_info(data)
    self:invite_friend(true)
end

--- 播放短语
function TableBaseModule:player_shot_voice(index, seatId)

end

function TableBaseModule:show_chat_face(SeatID, emoticonIdx)

end

function TableBaseModule:show_chat_bubble(SeatID, text)

end

function TableBaseModule:show_voice(SeatID)

end

function TableBaseModule:hide_voice(SeatID)

end

function TableBaseModule:update_seat_location(SeatID, data)
    if DataPaoHuZi.playersView and DataPaoHuZi.playersView[SeatID] then
        DataPaoHuZi.playersView[SeatID].playerInfo.locationData = data
    end
end

--- 刷新聊天消息
function TableBaseModule:refresh_chat_message(eventData)
    if (eventData.SeatID > 3 or eventData.SeatID < 0) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.Message)
        return
    end

    if string.sub(eventData.Message, 1, 1) ~= "{" then
        return
    end

    local chatData = ModuleCache.Json.decode(eventData.Message)
    if not chatData then
        return
    end
    -- for k,v tin pairs(chatData) do
    -- 	print("###########eventData.Message:",k,v)
    -- end

    if (not chatData.chatType ) then
        if chatData.voice then
            local data = {
                playerId = eventData.SeatID,
                fileid = chatData.voice,
            }
            self:dispatch_package_event("Event_TableVoice_VoiceComing", data)
            return
        else
            if chatData.words then
                chatData.chatType = 3
            elseif chatData.emoticon then
                chatData.chatType = 2
            end
        end

    end

    if (chatData.chatType == 1) then
        local textIndex = tonumber(chatData.content)
        self:player_shot_voice(textIndex, eventData.SeatID)
    elseif (chatData.chatType == 2) then
        --表情
        local emoticonIdx = tonumber( chatData.content or chatData.emoticon)
        if emoticonIdx > 100 then
            emoticonIdx = emoticonIdx / 100
        end

        self:show_chat_face(eventData.SeatID, emoticonIdx)
    elseif (chatData.chatType == 3) then
        --文字
        chatData.SeatID = eventData.SeatID
        chatData.userId = TableManager.phzTableData.seatUserIdInfo[tostring(eventData.SeatID)]
        table.insert(TableManager.chatMsgs, chatData)
        --self:dispatch_module_event("table", "Event_Refresh_ChatMsg")
        self:dispatch_package_event("Event_PaoHuZi_Refresh_ChatMsg")
        self:show_chat_bubble(eventData.SeatID, chatData.content or chatData.words)
    elseif (chatData.chatType == 0) then
        --语音
        chatData.SeatID = eventData.SeatID
        table.insert(TableManager.chatMsgs, chatData)--TODO:XLQ语音聊天消息加入聊天记录

        local data = {
            playerId = eventData.SeatID,
            fileid = chatData.content,
        }
        self:dispatch_package_event("Event_TableVoice_VoiceComing", data)
    elseif(chatData.chatType == 10)then
        self:on_send_gift_chat_msg(eventData.SeatID, chatData.content)
    elseif (chatData.chatType == 4) then
        TableUtilPaoHuZi.print("定位信息", eventData.SeatID, chatData)
        --定位
        self:update_seat_location(eventData.SeatID, chatData)
    end
end

function TableBaseModule:on_send_gift_chat_msg(seatId, content)
    if(string.sub(content, 1, 1) == "{")then
        local gift = ModuleCache.Json.decode(content)
        local sendPlayerView = DataPaoHuZi.playersView[self:get_local_seat(seatId)]
        local receiverPlayerView = DataPaoHuZi.playersView[self:get_local_seat(gift.receiver)]
        print(sendPlayerView, receiverPlayerView)
        if(sendPlayerView and receiverPlayerView)then
            local data = {
                giftName = gift.giftName,
                fromPos = sendPlayerView.seat.head.transform.position,
                toPos = receiverPlayerView.seat.head.transform.position,
            }
            self:dispatch_package_event('Event_Table_Play_SendGift', data)
        end
    end
end

--- 离开房间
function TableBaseModule:exit_room(tip)
    TableManager:disconnect_login_server()
    TableManager:disconnect_game_server()
    ModuleCache.net.NetClientManager.disconnect_all_client()
    ModuleCache.ModuleManager.hide_public_module("netprompt")
    ModuleCache.ModuleManager.hide_package("henanmj")
    ModuleCache.ModuleManager.destroy_module("paohuzi", "table")
    ModuleCache.ModuleManager.destroy_package("paohuzi")
    ModuleCache.ModuleManager.show_module("henanmj", "hall")
    if (tip) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(tip)
    end

end

function TableBaseModule:press_up_voice(obj, arg)
    local data = {
        obj = obj,
        arg = arg,
    }
    self:dispatch_package_event('Event_TableVoice_OnPressUpMic', data)
end

function TableBaseModule:on_drag_voice(obj, arg)
    local data = {
        obj = obj,
        arg = arg,
    }
    self:dispatch_package_event('Event_TableVoice_OnDragMic', data)
end

function TableBaseModule:press_voice(obj, arg)
    local data = {
        obj = obj,
        arg = arg,
    }
    self:dispatch_package_event('Event_TableVoice_OnPressMic', data)
end

function TableBaseModule:on_show()
    --self.lastUpdateBeatTime = 0
    self.lastPingTime = Time.realtimeSinceStartup
    self.model.lastReceiveHeartPackTime = Time.realtimeSinceStartup
    self.gameClient = self.modelData.gameClient
    self:on_update()
end



function TableBaseModule:on_destroy()
    --UpdateBeat:Remove(self.UpdateBeat, self)
    GVoiceManager.clear_event_listener()
    if(self.table_voice_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_voice')
    end
    if(self.table_gift_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_gift')
    end
end

function TableBaseModule:reconnect()

end
function TableBaseModule:on_update(t)
    if not self.view then
        return
    end
    self.view:update_beat()
end

function TableBaseModule:on_update_per_secondOn()
    if not self.view then
        return
    end
    --self.view:update_beat()
    --if self.lastUpdateBeatTime + 1 > Time.realtimeSinceStartup then
    --    return
    --end

    if (self.model.lastPingReqeustTime) then
        self.view:show_ping_delay(true, UnityEngine.Time.realtimeSinceStartup - self.model.lastPingReqeustTime)
    elseif (self.model.pingDelayTime) then
        self.view:show_ping_delay(true, self.model.pingDelayTime)
    else
        self.view:show_ping_delay(true, 0.05)
    end

    if (not audioMusic.isPlaying) then
        local bgMusic1 = "bgmfight1"
        local bgMusic2 = "bgmfight2"
        if ((not audioMusic.clip) or audioMusic.clip.name ~= bgMusic2) then
            ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic2 .. ".bytes", bgMusic2)
        else
            ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic1 .. ".bytes", bgMusic1)
        end
    end

    self.view:refresh_battery_time_info()
    --self.lastUpdateBeatTime = Time.realtimeSinceStartup

    if (TableManager.phzTableData.isPlayBack) then
        return
    end

    if self.gameClient.clientConnected and (self.gameClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
        TableManager:heartbeat_timeout_reconnect_game_server()
    end

    if self.gameClient.clientConnected and (self.lastPingTime + 3 < Time.realtimeSinceStartup) then
        self.lastPingTime = Time.realtimeSinceStartup
        if TableManager.clientConnected then
            self.model:request_heartbeat()
        end
    end
end

function TableBaseModule:PauseMusic()
    SoundManager.audioMusic.mute = true
end

function TableBaseModule:UnPauseMusic()
    SoundManager.audioMusic.mute = false
end

return TableBaseModule