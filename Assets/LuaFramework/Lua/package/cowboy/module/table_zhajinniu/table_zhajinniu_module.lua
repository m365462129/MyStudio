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
---@class TableModule_ZhaJinNiu:ModuleBase
---@field tableLogic TableZhaJinNiuLogic
local TableModule_ZhaJinNiu = class('table_zhajinniuModule', ModuleBase)
local TableHelper = require("package/cowboy/module/table_zhajinniu/table_zhajinniu_helper")

local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local System = UnityEngine.System

local GameSDKInterface = ModuleCache.GameSDKInterface
local WechatManager = ModuleCache.WechatManager

local TableManagerPoker = TableManagerPoker


local ChatMsgType = { }
ChatMsgType.shotMsg = 1
ChatMsgType.emojiMsg = 2
ChatMsgType.text = 3
ChatMsgType.voiceMsg = 0
ChatMsgType.gift = 10

local allChatMsgs = { }
local lastRoomNum

local voicePath = Application.persistentDataPath .. "/voice"

local onAppFocusCallback

function TableModule_ZhaJinNiu:initialize(...)


    ModuleBase.initialize(self, "table_zhajinniu_view", "table_zhajinniu_model", ...)
    self.chatConfig = require('package.cowboy.config')

    self.tableHelper = TableHelper
    self.tableHelper.module = self
    self.tableLogic = require("package/cowboy/module/table_zhajinniu/table_zhajinniu_logic"):new(self)
    -- print(self.tableLogic)
    local rule = ModuleCache.Json.decode(self.modelData.roleData.myRoomSeatInfo.Rule)


    self.doubleClickInterval = 0.4

    self.tableHelper.modelData = self.modelData

    self.netClient = self.modelData.cowboyClient
    self.table_gift_module = ModuleCache.ModuleManager.show_module('public','table_gift')
    self.table_voice_module = ModuleCache.ModuleManager.show_module('public','table_voice')

    TableManagerPoker:registLoginGameCallbacks( function(data)
        if (not data.err_no or data.err_no == "0") then
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.SoundManager.stop_music("cowboy")
            ModuleCache.ModuleManager.show_module("cowboy", "table_zhajinniu")
        else
            TableManagerPoker:disconnect_game_server()
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
        end
    end )

    onAppFocusCallback = function(eventHead, eventData)
        self.tableModel:request_TempLeave(not eventData)
    end
    self:subscibe_app_focus_event(onAppFocusCallback)

    self:begin_location( function()
        self:UploadIpAndAddress()
    end )
end


function TableModule_ZhaJinNiu:on_module_inited()
    self.lastUpdateBeatTime = 0
    self.gameClient = self.modelData.bullfightClient
end


function TableModule_ZhaJinNiu:on_module_event_bind()
    self:subscibe_module_event("joinroom", "Event_Table_Ping", function(eventHead, eventData)

    end )


    -- self:subscibe_module_event("dissolveroom", "Event_DissolvedRoom", function(eventHead, eventData)
    -- 	self.tableModel:request_dissolve_room(eventData)
    -- end)

    -- self:subscibe_module_event("roomsetting", "Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
    -- 	self.tableModel:request_dissolve_room(true)
    -- end)

    -- self:subscibe_module_event("roomsetting", "Event_RoomSetting_ExitRoom", function(eventHead, eventData)
    -- 	self.tableModel:request_exit_room()
    -- end)

    self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(true)
    end )

    self:subscibe_package_event("Event_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData == 2)
    end )

    self:subscibe_package_event("Event_RoomSetting_LeaveRoom", function(eventHead, eventData)
        self.model:request_exit_room()
    end )

    self:subscibe_module_event("tablechat", "Event_Send_ChatMsg", function(eventHead, eventData)
        if (eventData.isShotMsg) then
            self.tableModel:request_chat(ChatMsgType.shotMsg, eventData.content)
        elseif (eventData.isEmojiMsg) then
            self.tableModel:request_chat(ChatMsgType.emojiMsg, eventData.content)
        end
    end )


    self:subscibe_package_event("Event_Send_ChatMsg", function(eventHead, eventData)
        local msgType, text = nil, nil
        if (eventData.chatType == 1) then
            -- 短语
            msgType = ChatMsgType.shotMsg
            text = eventData.content
        elseif (eventData.chatType == 2) then
            -- 表情
            msgType = ChatMsgType.emojiMsg
            text = eventData.content
        elseif (eventData.chatType == 3) then
            -- 文本消息
            msgType = ChatMsgType.text
            text = eventData.content
        else
            return
        end

        self.model:request_chat(msgType, text)
    end )

    self:subscibe_package_event("Event_PokerTableFrame_Click_Leave", function(eventHead, eventData)
        self:on_click_exit_btn()
    end )
    self:subscibe_package_event("Event_PokerTableFrame_Click_Setting", function(eventHead, eventData)
        self:on_click_room_setting_btn()
    end )
    self:subscibe_package_event("Event_PokerTableFrame_Click_TestReconnect", function(eventHead, eventData)
        self:on_click_test_reconnect_btn()
    end )

    self:subscibe_package_event("Event_TableVoice_StartPlayVoice", function(eventHead, eventData)
        self:show_hide_seat_speak_amin(eventData, true)
    end)
    self:subscibe_package_event("Event_TableVoice_StopPlayVoice", function(eventHead, eventData)
        self:show_hide_seat_speak_amin(eventData, false)
    end)
    self:subscibe_package_event("Event_TableVoice_SendVoice", function(eventHead, eventData)
        self.model:request_chat(ChatMsgType.voiceMsg, eventData)
    end)

    self:subscibe_package_event("Event_PlayerInfo_SendGift", function(eventHead, eventData)
        local gift = {
            receiver = eventData.receiver,
            giftName = eventData.giftName,
        }
        local text = ModuleCache.Json.encode(gift)
        self.model:request_chat(ChatMsgType.gift, text)
    end)
end

function TableModule_ZhaJinNiu:show_hide_seat_speak_amin(playerId, show)
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
    if(seatInfo)then
        if(show)then
            self.view:show_voice(seatInfo.localSeatIndex)
        else
            self.view:hide_voice(seatInfo.localSeatIndex)
        end
    end

end

function TableModule_ZhaJinNiu:on_model_event_bind()

    -- 进入房间
    self:subscibe_model_event("Event_Table_Enter_Room", function(eventHead, eventData)
        if (tostring(eventData.err_no) == "0") then

        else
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("进入房间失败")
        end
    end )

    -- 上一局结算广播
    self:subscibe_model_event("Event_Table_AgoSettleAccounts_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_ago_settle_accounts_notify(eventData)
    end )

    -- 准备
    self:subscibe_model_event("Event_Table_Ready_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (tostring(eventData.err_no) == "0") then
            self.tableLogic:on_table_ready_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("准备错误err:" .. eventData.err_no)
        end

    end )

    -- 开始
    self:subscibe_model_event("Event_Table_Start_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (tostring(eventData.err_no) == "0") then
            self.tableLogic:on_table_start_rsp()
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err_no)
        end
    end )

    -- 进入房间通知
    self:subscibe_model_event("Event_Table_EnterRoom_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_enter_notify(eventData)
    end )

    -- 离开房间
    self:subscibe_model_event("Event_Table_Leave_Room_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已离开房间")
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("离开房间失败:" .. eventData.err_no)
        end
    end )

    -- 离开房间广播
    self:subscibe_model_event("Event_Table_Leave_Room_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        local playerId = eventData.player_id
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        seatInfo.playerId = "0"
        seatInfo.playerInfo = nil
        seatInfo.isSeated = false
        self.tableView:refreshSeat(seatInfo, false)

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 是否显示定位图标
        TableManagerPoker:isShowLocation(playerInfoList, self.tableView.buttonLocation);
    end )


    -- 开始广播
    self:subscibe_model_event("Event_Table_Start_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_start_notify(eventData)
    end )

    -- 单局结算广播
    self:subscibe_model_event("Event_Table_SettleAccounts_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_settleAccounts_Notify(eventData)
    end )

    -- 房间结算广播
    self:subscibe_model_event("Event_Table_LastSettleAccounts_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_lastsettleAccounts_Notify(eventData)
        ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
    end )


    -- 准备广播
    self:subscibe_model_event("Event_Table_Ready_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_ready_notify(eventData)
    end )


    -- 重连广播
    self:subscibe_model_event("Event_Table_Reconnect_Notify", function(eventHead, eventData)
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
        seatInfo.isOffline = false
        seatInfo.isTempLeave = false
        self.tableView:refreshSeatInfo(seatInfo)
    end )

    -- 断线广播
    self:subscibe_model_event("Event_Table_Disconnect_Notify", function(eventHead, eventData)
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
        seatInfo.isOffline = true
        seatInfo.isTempLeave = false
        self.tableView:refreshSeatOfflineState(seatInfo)
    end )

    -- 到期时间广播
    self:subscibe_model_event("Event_Table_SynExpire_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_expire_time_notify(eventData)
    end )


    -- 聊天相关
    self:subscibe_model_event("Event_Table_Chat", function(eventHead, eventData)

    end )

    self:subscibe_model_event("Event_Table_Chat_Notify", function(eventHead, eventData)
        local playerId = eventData.player_id
        -- print("chatmsg playerid=" .. playerId)
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        if (seatInfo) then
            local chatMsg = eventData.chatMsg
            local chatData = { }
            chatData.userId = playerId
            chatData.chatType = chatMsg.msgType
            chatData.content = ''
            chatData.SeatID = seatInfo.seatIndex

            if (chatMsg.msgType == ChatMsgType.text) then
                self.view:show_chat_bubble(seatInfo.localSeatIndex, chatMsg.text)
                chatData.content = chatMsg.text
                table.insert(allChatMsgs, chatData)
            elseif (chatMsg.msgType == ChatMsgType.shotMsg) then
                local textIndex = tonumber(chatMsg.text)
                local text = self:getShotTextByShotTextIndex(textIndex)
                self.tableView:show_chat_bubble(seatInfo.localSeatIndex, text)
                self:playerShotVocieByShotTextIndex(textIndex, seatInfo)
                chatData.content = text
                table.insert(allChatMsgs, chatData)
            elseif (chatMsg.msgType == ChatMsgType.emojiMsg) then
                local emojiId = tonumber(chatMsg.text)
                self.tableView:show_chat_emoji(seatInfo.localSeatIndex, emojiId)
            elseif (chatMsg.msgType == ChatMsgType.voiceMsg) then
                local data = {
                    playerId = seatInfo.playerId,
                    fileid = chatMsg.text,
                }
                self:dispatch_package_event("Event_TableVoice_VoiceComing", data)
                chatData.content = chatMsg.text
                table.insert(allChatMsgs, chatData)
            elseif(chatMsg.msgType == ChatMsgType.gift)then
                self:on_send_gift_chat_msg(playerId, chatMsg.text)
            end
            self:dispatch_package_event("Event_Refresh_ChatMsg")
        end
    end )

    -- 解散房间相关
    self:subscibe_model_event("Event_Table_Dissolve_Room_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then

        else

        end
    end )
    self:subscibe_model_event("Event_Table_Dissolve_RoomRequest_Notify", function(eventHead, eventData)
        local freeRoomData, isFree, disAgreeSeatInfo = self:genFreeRoomData(eventData)
        self.freeRoomData = freeRoomData
        self.freeRoomData.dataType = "bullfight"
        if (disAgreeSeatInfo) then
            self.is_freeing_room = false
            ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
        else
            self.is_freeing_room = true
            ModuleCache.ModuleManager.show_module("henanmj", "dissolveroom", self.freeRoomData)
        end

    end )
    self:subscibe_model_event("Event_Table_Dissolve_Room_Notify", function(eventHead, eventData)
        TableManagerPoker:disconnect_game_server()
        ModuleCache.net.NetClientManager.disconnect_all_client()
        ModuleCache.ModuleManager.destroy_package("cowboy")
        ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
    end )

    -- 暂时离开广播
    self:subscibe_model_event("Event_Table_TemporaryLeave_Notify", function(eventHead, eventData)
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
        seatInfo.isTempLeave = eventData.is_temporary_leave
        seatInfo.isOffline = false
        self.tableView:refreshSeatOfflineState(seatInfo)
    end )
    --------------------------------------------------
    -- 同步广播
    self.tableModel.subscibe_event(TableManagerPoker, "Event_Table_ZhaJinNiu_Sync_Notify", function(eventHead, eventData)
        if (eventData.room_info.roomNum ~= lastRoomNum) then
            allChatMsgs = { }
            ModuleCache.FileUtility.DirectoryDelete(voicePath, true)
            ModuleCache.FileUtility.DirectoryCreate(voicePath)
        end
        lastRoomNum = eventData.room_info.roomNum
        self.tableLogic:on_table_synchronize_notify(eventData)
    end )

    -- 同步广播
    self:subscibe_model_event("Event_Table_ZhaJinNiu_Sync_Notify", function(eventHead, eventData)
        if (eventData.room_info.roomNum ~= lastRoomNum) then
            allChatMsgs = { }
            ModuleCache.FileUtility.DirectoryDelete(voicePath, true)
            ModuleCache.FileUtility.DirectoryCreate(voicePath)
        end
        lastRoomNum = eventData.room_info.roomNum
        self.tableLogic:on_table_synchronize_notify(eventData)
    end )

    -- 等待玩家说话广播
    self:subscibe_model_event("Event_Table_WaitSpeak_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_waitspeak_notify(eventData)
    end )

    -- 弃牌
    self:subscibe_model_event("Event_Table_DropPokers", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.errCode and eventData.errCode == 0) then
            self.tableLogic:on_table_droppokers_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.errMsg)
        end
    end )

    -- 弃牌广播
    self:subscibe_model_event("Event_Table_DropPokers_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_droppokers_notify(eventData)
    end )

    -- 看牌
    self:subscibe_model_event("Event_Table_CheckPokers", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.errCode and eventData.errCode == 0) then
            self.tableLogic:on_table_checkpokers_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.errMsg)
        end
    end )

    -- 看牌广播
    self:subscibe_model_event("Event_Table_CheckPokers_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_checkpokers_notify(eventData)
    end )

    -- 比牌
    self:subscibe_model_event("Event_Table_ComparePokers", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.errCode and eventData.errCode == 0) then
            self.tableLogic:on_table_comparepokers_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.errMsg)
        end
    end )

    -- 比牌广播
    self:subscibe_model_event("Event_Table_ComparePokers_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_comparepokers_noitfy(eventData)
    end )

    -- 跟注
    self:subscibe_model_event("Event_Table_CallBet", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.errCode and eventData.errCode == 0) then
            self.tableLogic:on_table_callbet_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.errMsg)
        end
    end )

    -- 跟注广播
    self:subscibe_model_event("Event_Table_CallBet_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_callbet_notify(eventData)
    end )

    -- 结算广播
    self:subscibe_model_event("Event_Table_ZhaJinNiu_SettleAccounts_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_zhajinniu_settle_accounts_notify(eventData)
    end )

    -- 上一局结算广播
    self:subscibe_model_event("Event_Table_ZhaJinNiu_AgoSettleAccounts_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_zhajinniu_ago_settle_accounts_notify(eventData)
    end )

    -- 比牌失败广播
    self:subscibe_model_event("Event_Table_ZhaJinNiu_CompareFail_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_comparefail_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_CustomInfoChangeBroadcast", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_CustomInfoChangeBroadcast(eventData)
    end )

    --房主易位 通知
    self:subscibe_model_event("Event_Table_OwnerChangeBroadcast", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")

        -- eventData.userid == tonumber(self.modelData.roleData.userID)  是房主
        self.view:refreshReadyState(eventData.userid == tonumber(self.modelData.roleData.userID) );

        if eventData.userid == tonumber(self.modelData.roleData.userID)  and self.modelData.curTableData then
            local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
            for key, v in ipairs(seatsInfo) do
                if v.playerId and tostring(v.playerId) ~= "" and tostring(v.playerId) ~= "0" then
                    if( tonumber(v.playerId) ~= tonumber(eventData.userid) and tonumber(v.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)  and tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0) then
                        --TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
                        local seatHolder = self.tableView.seatHolderArray[v.localSeatIndex]
                        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,true)
                    end
                end
            end
        end

        --TODO XLQ:更新房主
        if self.modelData.curTableData then
            self.modelData.curTableData.roomInfo.roomHostID = eventData.userid
            self.modelData.curTableData.roomInfo.mySeatInfo.isCreator = eventData.userid == tonumber(self.modelData.roleData.userID)

            local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
            local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.userid, seatInfoList)
            self.tableView:refreshSeatInfo(seatInfo)
        end

    end)

    -- 监听踢人响应
    self:subscibe_model_event("Event_Table_KickPlayerBroadcast", function(eventHead, eventData)
        if eventData.player_id == tonumber(self.modelData.roleData.userID) then
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
            return
        end

        ModuleCache.ModuleManager.hide_public_module("netprompt")
        local playerId = eventData.player_id
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        seatInfo.playerId = "0"
        seatInfo.playerInfo = nil
        seatInfo.isSeated = false
        self.tableView:refreshSeat(seatInfo, false)

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 是否显示定位图标
        TableManagerPoker:isShowLocation(playerInfoList, self.tableView.buttonLocation);

    end)
end

function TableModule_ZhaJinNiu:on_send_gift_chat_msg(senderPlayerId, content)
    if(string.sub(content, 1, 1) == "{")then
        local gift = ModuleCache.Json.decode(content)
        local senderSeatInfo = self.tableHelper:getSeatInfoByPlayerId(senderPlayerId, self.modelData.curTableData.roomInfo.seatInfoList)
        local receiverSeatInfo = self.tableHelper:getSeatInfoByPlayerId(gift.receiver, self.modelData.curTableData.roomInfo.seatInfoList)
        if(senderSeatInfo and receiverSeatInfo)then
            local sendSeatHolder = self.view.seatHolderArray[senderSeatInfo.localSeatIndex]
            local receiverSeatHolder = self.view.seatHolderArray[receiverSeatInfo.localSeatIndex]
            local data = {
                giftName = gift.giftName,
                fromPos = sendSeatHolder.imagePlayerHead.transform.position,
                toPos = receiverSeatHolder.imagePlayerHead.transform.position,
            }
            self:dispatch_package_event('Event_Table_Play_SendGift', data)
        end
    end
end

function TableModule_ZhaJinNiu:_on_model_event_unbind()
    self.tableModel.unsubscibe_event_by_name(TableManagerPoker, "Event_Table_ZhaJinNiu_Sync_Notify")
end

function TableModule_ZhaJinNiu:genFreeRoomData(data)
    local freeRoomData = { }
    local freeRoomStateList = data.freeRoomStateList
    local isAllAgree = true
    local isAllAnswered = true
    local disAgreeSeatInfo = nil
    freeRoomData.expire = data.expire
    for i, v in ipairs(self.modelData.curTableData.roomInfo.seatInfoList) do
        if (v.isSeated) then
            local freeRoomSeatData = { }
            freeRoomSeatData.seatInfo = v
            freeRoomSeatData.isSponsor = false
            freeRoomSeatData.isAnswered = false
            freeRoomSeatData.agree = false
            table.insert(freeRoomData, freeRoomSeatData)
            if (v == self.modelData.curTableData.roomInfo.mySeatInfo) then
                freeRoomData.mySeatFreeRoomData = freeRoomSeatData
            end
            for j, value in ipairs(freeRoomStateList) do
                if (freeRoomSeatData.seatInfo == self.tableHelper:getSeatInfoByPlayerId(value.player_id, self.modelData.curTableData.roomInfo.seatInfoList)) then
                    freeRoomSeatData.isSponsor = value.sponsor == value.player_id
                    freeRoomSeatData.isAnswered = true
                    freeRoomSeatData.agree = value.agree
                end
            end
            if (freeRoomSeatData.isAnswered and(not freeRoomSeatData.agree)) then
                disAgreeSeatInfo = freeRoomSeatData.seatInfo
            end
            isAllAgree = isAllAgree and freeRoomSeatData.agree
            isAllAnswered = isAllAnswered and freeRoomSeatData.isAnswered
        end
    end

    return freeRoomData, isAllAgree and isAllAnswered, disAgreeSeatInfo
end


function TableModule_ZhaJinNiu:getShotTextByShotTextIndex(index)
    local config = self.chatConfig
    return config.chatShotTextList[index]
end

function TableModule_ZhaJinNiu:playerShotVocieByShotTextIndex(index, seatInfo)
    local voiceName = ""
    if (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
        voiceName = "chat_female_" .. index
    else
        voiceName = "chat_male_" .. index
    end
    ModuleCache.SoundManager.play_sound("publictable", "publictable/sound/tablepoker/" .. voiceName .. ".bytes", voiceName)
end

function TableModule_ZhaJinNiu:on_press_up(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressUpMic', data)
    end
end

function TableModule_ZhaJinNiu:on_drag(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnDragMic', data)
    end
end

function TableModule_ZhaJinNiu:on_press(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressMic', data)
    end
end

function TableModule_ZhaJinNiu:on_click(obj, arg)
    self.lastClickObj = obj
    self.lastClickTime = Time.realtimeSinceStartup
     --print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if (self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup) then
        return
    end
    if (obj == self.tableView.buttonSetting.gameObject) then
        self:on_click_room_setting_btn(obj, arg)
        -- 根据房间是否开始的状态传值
    elseif (obj == self.tableView.buttonLocation.gameObject) then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 获取位置信息文本
        local tipText, distanceText = TableManagerPoker:get_gps_warn_text(playerInfoList);
        ModuleCache.ModuleManager.show_module("henanmj", "tablegps2", tipText .. "," .. distanceText)
    elseif (obj == self.tableView.buttonStart.gameObject) then
        self.tableLogic:onclick_start_btn(obj)
    elseif (obj == self.tableView.buttonExit.gameObject) then
        self:on_click_exit_btn(obj, arg)
    elseif (obj == self.tableView.buttonReady.gameObject or obj == self.tableView.buttonReady_fastStart.gameObject) then
        self.tableLogic:onclick_ready_btn(obj)
    elseif (obj == self.tableView.buttonContinue.gameObject) then
        self.tableLogic:onclick_continue_btn(obj)
    elseif (obj.name == "NotSeatDown" or obj == self.tableView.buttonInvite.gameObject) then
        self.lastClickInviteTime = Time.realtimeSinceStartup
        self:inviteWeChatFriend()
    elseif (obj.name == "ButtonChat") then
        ModuleCache.ModuleManager.show_module("henanmj", "tablechat", { is_New_Sever = true, allChatMsgs = allChatMsgs, curTableData = self.chatCurTableData, config = self.chatConfig })
        -- ModuleCache.ModuleManager.show_module("cowboy", "tablechat")
    elseif (obj.name == "ButtonMic") then
        -- self.tableLogic:on_click_mic_btn()
    elseif (obj.name == "SelectCompare") then
        self.tableLogic:onclick_selectCompare(obj, arg)
    elseif (obj.name == "Image") then
        local seatInfo = self:getSeatInfoByHeadImageObj(obj)
        if (not seatInfo or (not seatInfo.playerInfo)) then
            -- print("seatInfo is not exist")
            return
        end
        if(self.tableLogic.playerCustomInfoMap)then
            local locationData = self.tableLogic.playerCustomInfoMap[seatInfo.playerId]
            seatInfo.playerInfo.locationData = locationData
            if(locationData)then
                seatInfo.playerInfo.ip = locationData.ip
            end
        end
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", seatInfo.playerInfo)
    elseif (obj == self.tableView.buttonComparePoker.gameObject) then
        self.tableLogic:onClickComparePokerBtn(obj, arg)
    elseif (obj == self.tableView.buttonDropPoker.gameObject) then
        self.tableLogic:onClickDropPokerBtn(obj, arg)
    elseif (obj == self.tableView.buttonCheckPoker.gameObject) then
        self.tableLogic:onclick_check_pokers_btn(obj, arg)
    elseif (obj == self.tableView.toggleFollowAlways.gameObject) then
        self.tableLogic:onclick_follow_always_btn(obj, arg)
    elseif (obj == self.tableView.buttonFollow.gameObject) then
        self.tableLogic:onclick_follow_btn(obj, arg)
    elseif (obj == self.tableView.buttonRaise.gameObject) then
        self.tableLogic:onclick_raise_btn(obj, arg)
    elseif (obj == self.tableView.buttonMore.gameObject) then
        self.tableLogic:onclick_more_btn(obj, arg)
    elseif (obj == self.tableView.buttonHideMore.gameObject) then
        self.tableLogic:onclick_hide_more_btn(obj, arg)
    elseif (obj == self.tableView.buttonHideMore.gameObject) then
        self.tableLogic:onclick_hide_more_btn(obj, arg)
    elseif (obj.transform.parent.gameObject == self.tableView.goMoreBtns) then
        self.tableLogic:onclick_more_bet_btn(obj, arg)
    elseif obj.name == "ButtonRule" then
        local rule = { };
        rule = ModuleCache.Json.decode(self.modelData.curTableData.roomInfo.rule);
        rule.name = "ZhaJinNiu"
        rule = ModuleCache.Json.encode(rule);
        -- ModuleCache.ModuleManager.show_module("cowboy", "tablerule", rule)
	    ModuleCache.ModuleManager.show_module("henanmj", "tablerule", rule)
    elseif (obj.name == "KickBtn") then--TODO XLQ:亲友圈快速组局   踢人
        local seatInfo = self:GetSeatInfoByKickBtn(obj)
        if(seatInfo == nil) then
            print("=====seatInfo is not exist")
            return
        end
        self.model:request_KickPlayerReq(tonumber(seatInfo.playerId) )
    end
end

--点击离开房间按钮
function TableModule_ZhaJinNiu:on_click_exit_btn(obj, arg)
    local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and(not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
    if canLeaveRoom or (self.modelData.roleData.RoomType == 2 and self.modelData.curTableData.roomInfo.curRoundNum == 0) then--快速组局都发离开请求
        self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
    else
        self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)
    end
end

--点击房间设置按钮
function TableModule_ZhaJinNiu:on_click_room_setting_btn(obj, arg)
    local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and(not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
    local intentData = { }
    intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_" .. "BULLFIGHT"
    intentData.canExitRoom = canLeaveRoom
    intentData.canDissolveRoom = not canLeaveRoom
    intentData.tableBackgroundSprite = self.view.tableBackgroundSprite
    ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", intentData)
end


--点击断线重连按钮
function TableModule_ZhaJinNiu:on_click_test_reconnect_btn(obj, arg)
    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("点击触发断线重连")
    TableManagerPoker:heartbeat_timeout_reconnect_game_server()
end

function TableModule_ZhaJinNiu:on_double_click(obj, arg)

end

function TableModule_ZhaJinNiu:GetSeatInfoByKickBtn(obj)
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if(seatInfo ~= nil) then
            local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
            if (seatHolder.KickBtn.gameObject == obj) then
                return seatInfo
            end
        end
    end
    return nil
end

function TableModule_ZhaJinNiu:getSeatInfoByHeadImageObj(obj)
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        local seatHolder = self.tableView.seatHolderArray[seatInfo.localSeatIndex]
        if (seatHolder.imagePlayerHead.gameObject == obj) then
            return seatInfo
        end
    end
    return nil
end

function TableModule_ZhaJinNiu:inviteWeChatFriend()
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    if (roomInfo.curRoundNum > 0) then
        return
    end

    local ruleTable = roomInfo.ruleTable
    local shareData = { }
    shareData.type = 2
    shareData.roomId = ""
    shareData.rule = ""
    
    local proStr = ModuleCache.PlayModeUtil.get_province_data(AppData.App_Name).shortName
    local wanfaName = TableUtil.get_rule_name(roomInfo.rule)
    local gameType = roomInfo.ruleTable.GameType or roomInfo.ruleTable.gameType or roomInfo.ruleTable.game_type or roomInfo.ruleTable.bankerType or 3
    local _,name,wanfaName = Config.GetWanfaIdx(gameType)
	if(string.find( wanfaName,proStr))then
		shareData.title = wanfaName
	else
		shareData.title = proStr .. wanfaName
	end
    if(AppData.App_Name == "DHAHQP") then
        shareData.title = wanfaName
    end
    shareData.ruleName = name .. ' ' .. roomInfo.ruleDesc
    shareData.userID = self.modelData.roleData.userID
    shareData.parlorId = ""
    shareData.roomType = 0
    shareData.roomId = tostring(roomInfo.roomNum)
    shareData.gameName = AppData.get_url_game_name()
    if(self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0) then
        shareData.parlorId = self.modelData.roleData.HallID .. ""
        shareData.roomType = self.modelData.roleData.RoomType
    else
        shareData.roomType = 0
    end
    if(self.modelData.roleData.RoomType == 3) then-- 比赛场分享
        shareData.type = 4
        shareData.matchId = self.modelData.roleData.MatchID
    elseif self.modelData.roleData.RoomType == 2 then--快速组局
        shareData.parlorId = shareData.parlorId ..  string.format("%06d",ModuleCache.GameManager.curGameId)
    end
    print("--------------share-----------shareData.type:",shareData.type,shareData.parlorId,shareData.matchId)
    ModuleCache.ShareManager().shareRoomNum(shareData, false)
end




function TableModule_ZhaJinNiu:selectCardsByPokerArray(pokerArray)
    local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
    local selectedPokersArray = { }
    for i = 1, #cardsArray do
        cardsArray[i].selected = false
        self.tableView:refreshCardSelect(cardsArray[i])
        for j = 1, #pokerArray do
            if (cardsArray[i].poker == pokerArray[j]) then
                cardsArray[i].selected = true
                table.insert(selectedPokersArray, cardsArray[i].poker)
                self.tableView:refreshCardSelect(cardsArray[i])
            end
        end
    end
    self.tableView.seatHolderArray[1].selectedPokersArray = selectedPokersArray
    self.tableView:refreshSelectedNiuNumbers()
end


function TableModule_ZhaJinNiu:resetSelectedPokers()
    local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
    for i = 1, #cardsArray do
        if (cardsArray[i].selected) then
            cardsArray[i].selected = false
        end
    end
    self.tableView.seatHolderArray[1].selectedPokersArray = { }
end




function TableModule_ZhaJinNiu:on_show(intentData)
    --self.lastUpdateBeatTime = 0
    --UpdateBeat:Add(self.UpdateBeat, self)
    self.gameClient = self.modelData.bullfightClient
    self.tableLogic:on_show()
end

function TableModule_ZhaJinNiu:on_hide()
    --UpdateBeat:Remove(self.UpdateBeat, self)
    self.tableLogic:on_hide()
end

function TableModule_ZhaJinNiu:on_destroy()
    self:_on_model_event_unbind()
    --UpdateBeat:Remove(self.UpdateBeat, self)
    self.tableLogic = nil
    self:dispatch_package_event('Event_On_PokerTable_Destroy')
    if(self.table_voice_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_voice')
    end
    if(self.table_gift_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_gift')
    end
end


function TableModule_ZhaJinNiu:on_update()
    if (self.isDestroy) then
        return
    end
    local pingDelayTime = 0.05
    if((not self.lastRefreshPingValTime) or (self.lastRefreshPingValTime + 1 < Time.realtimeSinceStartup))then
        self.lastRefreshPingValTime = Time.realtimeSinceStartup
        if(self.model.lastPingReqeustTime)then
            pingDelayTime = UnityEngine.Time.realtimeSinceStartup - self.model.lastPingReqeustTime
            self.view:show_ping_delay(true, pingDelayTime)
        elseif(self.model.pingDelayTime)then
            pingDelayTime = self.model.pingDelayTime
            self.view:show_ping_delay(true, self.model.pingDelayTime)
        else
            self.view:show_ping_delay(true, 0.05)
        end
    end
    if (not self.lastUpdateBeatTime or self.lastUpdateBeatTime + 1 > Time.realtimeSinceStartup) then
        self:dispatch_package_event('Event_Refresh_Ping_Value', pingDelayTime)
    else
        self.lastUpdateBeatTime = Time.realtimeSinceStartup
    end

    self.tableLogic:update()
    self.tableView:refreshBatteryAndTimeInfo()
    if ((self.lastUpdateBeatTime ~= 0) and ((not self.lastPingTime) or(self.lastPingTime + 3 < Time.realtimeSinceStartup))) then
        self.lastPingTime = Time.realtimeSinceStartup
        if (TableManagerPoker.clientConnected) then
            self.tableModel:request_ping()
        end
    end
    self.lastUpdateBeatTime = Time.realtimeSinceStartup
    if self.gameClient.clientConnected and(self.gameClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
        TableManagerPoker:heartbeat_timeout_reconnect_game_server()
    end

    local audioMusic = ModuleCache.SoundManager.audioMusic
    if (not audioMusic.isPlaying) then
        local bgMusic1 = "bgm_fangjian"
        ModuleCache.SoundManager.play_music("cowboy", "cowboy/sound/zhajinniu/" .. bgMusic1 .. ".bytes", bgMusic1)
    end
end

function TableModule_ZhaJinNiu:PauseMusic()
    SoundManager.audioMusic.mute = true
end

function TableModule_ZhaJinNiu:UnPauseMusic()
    SoundManager.audioMusic.mute = false
end


function TableModule_ZhaJinNiu:addSeatInfo2ChatCurTableData(seatInfo)
    if (not self.chatCurTableData) then
        self.chatCurTableData = { }
    end
    if (not self.chatCurTableData.seatHolderArray) then
        self.chatCurTableData.seatHolderArray = { }
    end
    local tmp = { }
    tmp.SeatID = seatInfo.seatIndex
    tmp.playerId = seatInfo.playerId
    seatInfo.chatDataSeatHolder = tmp
    table.insert(self.chatCurTableData.seatHolderArray, tmp)
end

function TableModule_ZhaJinNiu:removeSeatInfoFromChatCurTableData(playerId)
    if (not self.chatCurTableData) then
        return
    end
    if (not self.chatCurTableData.seatHolderArray) then
        return
    end
    for i = 1, #self.chatCurTableData.seatHolderArray do
        local tmp = self.chatCurTableData.seatHolderArray[i]
        if (tmp.playerId == playerId) then
            table.remove(self.chatCurTableData.seatHolderArray, i)
            return
        end
    end
end


-- 上传IP和地址
function TableModule_ZhaJinNiu:UploadIpAndAddress()
    print("UploadIpAndAddress")
    local newTable = { }
    newTable.address = ModuleCache.GPSManager.gpsAddress
    newTable.gpsInfo = ModuleCache.GPSManager.gps_info
    self.model:request_CustomInfoChange(ModuleCache.Json.encode(newTable))
end


return TableModule_ZhaJinNiu 