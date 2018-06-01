local AppData = AppData
local BranchPackageName = AppData.BranchZhaJinHuaName
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local class = require("lib.middleclass")
local list = require("list")
local ModuleBase = require('core.mvvm.module_base')
---@class table_zhajinhuaModule
local TableModule_ZhaJinHua = class('table_zhajinhuaModule', ModuleBase)
local TableHelper = require(string.format("package/%s/module/table_zhajinhua/table_zhajinhua_helper", BranchPackageName))

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

function TableModule_ZhaJinHua:initialize(...)
    ModuleBase.initialize(self, "table_zhajinhua_view", "table_zhajinhua_model", ...)
    self.chatConfig = require(string.format("package.%s.config", BranchPackageName))
    self.tableHelper = TableHelper
    self.tableHelper.module = self
    self.tableLogic = require(string.format("package/%s/module/table_zhajinhua/table_zhajinhua_logic", BranchPackageName)):new(self)
    local rule = ModuleCache.Json.decode(self.modelData.roleData.myRoomSeatInfo.Rule)
    self.doubleClickInterval = 0.4
    self.tableHelper.modelData = self.modelData

    self.netClient = self.modelData.cowboyClient
    TableManagerPoker:registLoginGameCallbacks( function(data)
        if (not data.err_no or data.err_no == "0") then
            ModuleCache.ModuleManager.destroy_package(BranchPackageName)
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.SoundManager.stop_music()
            ModuleCache.ModuleManager.show_module(BranchPackageName, "table_zhajinhua")
        else
            TableManagerPoker:disconnect_game_server()
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
            ModuleCache.ModuleManager.destroy_package(BranchPackageName)
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
        end
    end )

    self.table_gift_module = ModuleCache.ModuleManager.show_module('public','table_gift')
    self.table_voice_module = ModuleCache.ModuleManager.show_module('public','table_voice')

    onAppFocusCallback = function(eventHead, eventData)
        self.tableModel:request_TempLeave(not eventData)
    end
    self:subscibe_app_focus_event(onAppFocusCallback)

    self:begin_location(function()
        self:UploadIpAndAddress()
    end )

    --self:check_activity_is_open(function(isOpen)
    --    self.tableView:SetState_BtnActivityRoot(isOpen or false)
    --end)
    local object =
    {
        buttonActivity = self.tableView.BtnActivity,
        spriteRedPoint = self.tableView.ActivityRedPoint
    }
    ModuleCache.ModuleManager.show_public_module("activity", object)
end


function TableModule_ZhaJinHua:on_module_inited()

end

function TableModule_ZhaJinHua:getTableKeyCount(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function TableModule_ZhaJinHua:on_module_event_bind()
    self:subscibe_module_event("joinroom", "Event_Table_Ping", function(eventHead, eventData)
    end )

    self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(true)
    end )

    self:subscibe_package_event("Event_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData == 2)
    end )

    self:subscibe_package_event("Event_RoomSetting_LeaveRoom", function(eventHead, eventData)
        self.model:request_exit_room()
    end )

    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.model:request_UserCoinBalanceReq()
    end )

    self:subscibe_module_event("tablechat", "Event_Send_ChatMsg", function(eventHead, eventData)
        if (eventData.isShotMsg) then
            self.tableModel:request_chat(ChatMsgType.shotMsg, eventData.content)
        elseif (eventData.isEmojiMsg) then
            self.tableModel:request_chat(ChatMsgType.emojiMsg, eventData.content)
        end
    end )
    self:subscibe_package_event("Event_Close_TableShop", function(eventHead, eventData)
        self.tableModel:request_UserRechargeReq(false)
    end)

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

    self:subscibe_package_event("Event_TableVoice_StartPlayVoice", function(eventHead, eventData)
        local playerId = eventData
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        if(seatInfo)then
            self.tableView:show_voice(seatInfo.localSeatIndex)
        end
    end)
    self:subscibe_package_event("Event_TableVoice_StopPlayVoice", function(eventHead, eventData)
        local playerId = eventData
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        if(seatInfo)then
            self.tableView:hide_voice(seatInfo.localSeatIndex)
        end
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

function TableModule_ZhaJinHua:on_model_event_bind()

    -- 进入房间
    self:subscibe_model_event("Event_Table_Enter_Room", function(eventHead, eventData)
        if (tostring(eventData.err_no) == "0") then

        else
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package(BranchPackageName)
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
            if (eventData.err_no == "-888") then
                --self.tableView:ShowGoldNotEnoughUI()
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
                    if self.model then
                        self.model:request_UserRechargeReq(true)
                        ModuleCache.ModuleManager.show_module("public", "goldadd")
                    end
                end, nil, true, "确 认", "取 消")
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("无法准备")
            end
        end
    end)

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
        self:refresh_share_clip_board()
    end )

    -- 离开房间
    self:subscibe_model_event("Event_Table_Leave_Room_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            if (self.tableView:isJinBiChang()) then
                TableManagerPoker:disconnect_game_server()
                if UnityEngine.PlayerPrefs.GetInt("ChangeTable", 1) ~= 1 then
                    ModuleCache.ModuleManager.destroy_package(BranchPackageName)
                    ModuleCache.ModuleManager.show_module("henanmj", "hall")
                else
                    ModuleCache.UnityEngine.PlayerPrefs.SetInt("ChangeTable", 0)
                    TableManager:join_room(nil, ModuleCache.UnityEngine.PlayerPrefs.GetString("LastJoinWanfaName", ""), nil,
                    ModuleCache.UnityEngine.PlayerPrefs.GetInt("LastJoinGoldFieldID", 1))
                end
                return
            end
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package(BranchPackageName)
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
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        local playerId = eventData.player_id
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, seatInfoList)

        seatInfo.playerId = "0"
        seatInfo.playerInfo = nil
        seatInfo.isSeated = false
        self.tableView:refreshSeat(seatInfo, false)
        self.tableView:showInHandCards(seatInfo, false)
        self.tableView:showSeatCostGold(seatInfo, false)
        self.tableView:SetPokerType(seatInfo, false)
        self.tableView:SwitchState_NewStateRoot(seatInfo, true)
        for i = 1, #seatInfoList do
            local locSeatInfo = seatInfoList[i]
            if (locSeatInfo.playerId == "0") then
                table.remove(seatInfoList, i)
                break
            end
        end
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 是否显示定位图标
        TableManagerPoker:isShowLocation(playerInfoList, self.tableView.buttonLocation);
        self:refresh_share_clip_board()
    end )


    -- 开始广播
    self:subscibe_model_event("Event_Table_Start_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        --self.tableLogic:on_table_start_notify(eventData)
    end )

    -- 单局结算广播
    self:subscibe_model_event("Event_Table_SettleAccounts_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_settleAccounts_Notify(eventData)
    end )

    -- 房间结算广播
    self:subscibe_model_event("Event_Table_LastSettleAccounts_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
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
        if (seatInfo) then
            seatInfo.isOffline = false
            seatInfo.isTempLeave = false
            self.tableView:refreshSeatInfo(seatInfo)
        else
            print("error=====没找到这个玩家=", tostring(eventData.player_id))
        end
    end )

    -- 断线广播
    self:subscibe_model_event("Event_Table_Disconnect_Notify", function(eventHead, eventData)
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
        if(seatInfo == nil) then
            print("error====seatInfo=nil 断线广播,没有这个玩家,怎么断线?id=",tostring(eventData.player_id))
        else
            seatInfo.isOffline = true
            seatInfo.isTempLeave = false
            self.tableView:refreshSeatOfflineState(seatInfo)
        end
    end)

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
            chatData.playerInfo = seatInfo.playerInfo
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
                    playerId = playerId,
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
        self.freeRoomData.dataType = AppData.BranchZhaJinHuaName
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
        self:ResetChatMsgs()
        ModuleCache.net.NetClientManager.disconnect_all_client()
        ModuleCache.ModuleManager.destroy_package(BranchPackageName)
        ModuleCache.ModuleManager.destroy_package("henanmj")
        --ModuleCache.ModuleManager.hide_module("public", "goldadd")
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
            print("======比牌回应")
            -- self.tableLogic:on_table_comparepokers_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.errMsg)
        end
    end )

    -- 比牌广播
    self:subscibe_model_event("Event_Table_ComparePokers_Notify", function(eventHead, eventData)
        -- self.tableLogic:on_table_comparepokers_noitfy(eventData)
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
    end)

    -- 比牌失败广播
    self:subscibe_model_event("Event_Table_ZhaJinNiu_CompareFail_Notify", function(eventHead, eventData)
        -- self.tableLogic:on_table_comparefail_notify(eventData)
    end)

    self:subscibe_model_event("Event_Table_CustomInfoChangeBroadcast", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self:subscibe_time_event(2, false, 0):OnComplete( function(t)
            self.tableLogic:on_table_CustomInfoChangeBroadcast(eventData)
        end)

    end )

    self:subscibe_model_event("Event_Table_GameInfo", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_gameinfo(eventData)
    end)

    self:subscibe_model_event("Event_Table_DeductNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:DeductNotify(eventData)
    end)

    self:subscibe_model_event("Event_Table_StartOperationNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:StartOperationNotify(eventData)
    end)

    self:subscibe_model_event("Event_Table_OperationRet", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:OperationRet(eventData)
    end)

    self:subscibe_model_event("Event_Table_OperationNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:OperationNotify(eventData)
    end)

    self:subscibe_model_event("Msg_Table_CompareListRet", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:CompareListRet(eventData)
    end)

    self:subscibe_model_event("Msg_Table_MaxCircleNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
    end)

    self:subscibe_model_event("Msg_Table_CurrentGameAccount", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:CurrentGameAccount(eventData)
    end)

    self:subscibe_model_event("Msg_Table_OneShotSettleNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:OneShotSettleNotify(eventData)
    end)

    self:subscibe_model_event("Msg_Table_IntrustRsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:IntrustRsp(eventData)
    end)

    self:subscibe_model_event("Msg_Table_IntrustNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:IntrustNotify(eventData)
    end)

    self:subscibe_model_event("Msg_Table_KickPlayerRsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        print("====踢人回复")
    end)

    self:subscibe_model_event("Msg_Table_KickPlayerBroadcast", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        print("====踢人广播通知")

        self:FilterGold_ResetChatMsgs()
        local player_id = eventData.player_id
        local myId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
        if (player_id == myId) then
            print("====被踢的是自己,退出房间,到主城界面去")
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package(BranchPackageName)
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
            return
        else
            print("====被踢的是=", player_id)
            local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
            local seatInfo = self.tableHelper:getSeatInfoByPlayerId(player_id, seatInfoList)
            if (seatInfo == nil) then
                print("====没有找到这个玩家,被踢的是=", player_id)
            else
                seatInfo.playerId = "0"
                seatInfo.playerInfo = nil
                seatInfo.isSeated = false
                self.tableView:refreshSeat(seatInfo, false)
                for i = 1, #seatInfoList do
                    local locSeatInfo = seatInfoList[i]
                    if (locSeatInfo.playerId == "0") then
                        table.remove(seatInfoList, i)
                        break
                    end
                end
            end
            self.tableView:CheckLocationUI()
        end
    end)

    self:subscibe_model_event("Msg_Table_GoldNotEnoughNotify", function(eventHead, eventData)
        print("====Msg_Table_GoldNotEnoughNotify")
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        local roomInfo = self.modelData.curTableData.roomInfo
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.playerid, roomInfo.seatInfoList)
        if (seatInfo == nil) then
            print("==seatInfo == nil")
        else
            if (seatInfo == roomInfo.mySeatInfo) then
                --self.tableView:ShowGoldNotEnoughUI()
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
                    self.model:request_UserRechargeReq(true)
                    ModuleCache.ModuleManager.show_module("public", "goldadd")
                end, nil, true, "确 认", "取 消")
                --self.tableView:StartCoinCountdown(eventData.time)
                if(roomInfo.mySeatInfo.isAlwaysFollow) then
                    self.tableView.toggleFollowAlways.isOn = false
                    roomInfo.mySeatInfo.isAlwaysFollow = false
                    self.tableView:showFollowButton(true)
                end
            end
        end
    end)

    --补充金币通知
    self:subscibe_model_event("Msg_Table_UserRechargeNotify", function(eventHead, eventData)
        print("====UserRechargeNotify")
        local roomInfo = self.modelData.curTableData.roomInfo
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.playerid, roomInfo.seatInfoList)
        if (seatInfo == nil) then
            print("==seatInfo == nil")
        else
            --可删除
            -- self.tableView:RefreshRechargeSatus(seatInfo,roomInfo.mySeatInfo,eventData)
            --if(seatInfo == roomInfo.mySeatInfo and self.tableLogic:IsMyCurOperation()
            --and eventData.time and eventData.time ~= 0) then
            --    self.tableView:StartCoinCountdown(eventData.time)
            --end
            if(eventData.time and eventData.time ~= 0) then
                self.tableView:showSeatTimeLimitEffect(seatInfo,true,eventData.time,nil,1)
            end

            local seatHolder = self.tableView:GetSeatHolderBySeatInfo(seatInfo)
            if(seatHolder and seatHolder.rechargeState) then
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.rechargeState.gameObject, eventData.open)
            end
        end
    end)

    self:subscibe_model_event("Msg_Table_AllInCompareNotify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:AllInCompareNotify(eventData)
    end)


    self:subscibe_model_event("Msg_Table_OwnerChangeNotify", function(eventHead, eventData)
        print("=================Msg_Table_OwnerChangeNotify")
        ModuleCache.ModuleManager.hide_public_module("netprompt")

        if self.modelData.roleData.RoomType == 2 then
            if self.modelData.curTableData and ( not self.modelData.curTableData.roomInfo.mySeatInfo.cur_game_loop_cnt
            or self.modelData.curTableData.roomInfo.mySeatInfo.cur_game_loop_cnt == 0) then--亲友圈快速组局

                self.modelData.curTableData.roomInfo.owner = eventData.new_ownerid

                local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
                local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.new_ownerid, seatInfoList)
                self.tableView:refreshSeatInfo(seatInfo)

                if (tonumber(eventData.new_ownerid) == tonumber(self.modelData.roleData.userID)) then
                    -- 是房主
                    self.view.switcher:SwitchState("Three");

                    local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
                    for key, v in ipairs(seatsInfo) do
                        if(tonumber(v.playerId) ~= tonumber(eventData.new_ownerid) and tonumber(v.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)  and tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0) then
                            --TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
                            local seatHolder = self.tableView.seatHolderArray[v.localSeatIndex]
                            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,true)
                        end
                    end

                else
                    self.view.switcher:SwitchState("Two");
                end

                print("--------------Msg_Table_OwnerChangeNotify--------isCreator:",tonumber(eventData.new_ownerid) == tonumber(self.modelData.roleData.userID))
            end
        end

    end)

    self:subscibe_model_event("Msg_Table_CancelReadyNotify", function(eventHead, eventData)
        print("=================Msg_Table_CancelReadyNotify")
        ModuleCache.ModuleManager.hide_public_module("netprompt")

        if self.modelData.roleData.RoomType == 2 then--亲友圈快速组局
            local seatInfo =self.tableHelper:getSeatInfoByPlayerId(eventData.playerid,self.modelData.curTableData.roomInfo.seatInfoList)
            if(seatInfo) then
                seatInfo.isReady = false
                self.tableView:refreshSeatInfoImageReadyState(seatInfo)
                self.tableView:MuseumReadyState(true)
            else
                print("====没有找到玩家id=",tostring(eventData.playerid))
            end
        end
    end)

end

function TableModule_ZhaJinHua:on_send_gift_chat_msg(senderPlayerId, content)
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

function TableModule_ZhaJinHua:_on_model_event_unbind()
    self.tableModel.unsubscibe_event_by_name(TableManagerPoker, "Event_Table_ZhaJinNiu_Sync_Notify")
end

function TableModule_ZhaJinHua:genFreeRoomData(data)
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
            if (freeRoomSeatData.isAnswered and (not freeRoomSeatData.agree)) then
                disAgreeSeatInfo = freeRoomSeatData.seatInfo
            end
            isAllAgree = isAllAgree and freeRoomSeatData.agree
            isAllAnswered = isAllAnswered and freeRoomSeatData.isAnswered
        end
    end

    return freeRoomData, isAllAgree and isAllAnswered, disAgreeSeatInfo
end


function TableModule_ZhaJinHua:getShotTextByShotTextIndex(index)
    local config = self.chatConfig
    return config.chatShotTextList[index]
end

function TableModule_ZhaJinHua:playerShotVocieByShotTextIndex(index, seatInfo)
    local voiceName = ""
    if (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
        voiceName = "chat_female_" .. index
    else
        voiceName = "chat_male_" .. index
    end
    ModuleCache.SoundManager.play_sound("zhajinhua", "zhajinhua/sound/zhajinniu/" .. voiceName .. ".bytes", voiceName)
end

function TableModule_ZhaJinHua:on_press_up(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressUpMic', data)
    end
end

function TableModule_ZhaJinHua:on_drag(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnDragMic', data)
    end
end

function TableModule_ZhaJinHua:on_press(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressMic', data)
    end
end

function TableModule_ZhaJinHua:on_click(obj, arg)
    self.lastClickObj = obj
    self.lastClickTime = Time.realtimeSinceStartup
    -- print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if (self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup) then
        return
    end
    if (obj == self.tableView.buttonSetting.gameObject) then
        local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and (not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
        local intentData = { }
        intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_" .. "BULLFIGHT"
        intentData.canExitRoom = canLeaveRoom
        intentData.canDissolveRoom = not canLeaveRoom
        intentData.tableBackgroundSprite = self.view.tableBackgroundSprite
        if (self.tableView:isJinBiChang()) then
            intentData.canExitRoom = false
            intentData.canDissolveRoom = false
        end
        ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", intentData)
        -- 根据房间是否开始的状态传值
    elseif (obj == self.tableView.buttonLocation.gameObject) then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 获取位置信息文本
        local tipText, distanceText = TableManagerPoker:get_gps_warn_text(playerInfoList);
        ModuleCache.ModuleManager.show_module("henanmj", "tablegps2", tipText .. "," .. distanceText)
    elseif (obj == self.tableView.buttonStart.gameObject or obj == self.tableView.ButtonReady.gameObject) then
        if self.modelData.roleData.RoomType == 2 then
            print("----------onclick_start_btn-----------",self.modelData.roleData.RoomType)
            self.tableLogic:onclick_start_btn(obj)
        else
            self.tableLogic:onclick_ready_btn()
        end
    elseif (obj == self.tableView.buttonExit.gameObject) then
        local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and (not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
        if canLeaveRoom then
            self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
        else
            self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)
        end
    elseif (obj == self.tableView.buttonContinue.gameObject) then
        self.tableLogic:onclick_continue_btn(obj)
    elseif (obj.name == "NotSeatDown" or obj == self.tableView.buttonInvite.gameObject) then
        self.lastClickInviteTime = Time.realtimeSinceStartup
        self:inviteWeChatFriend()
    elseif (obj.name == "BtnActivity") then
         local object = 
        {
        showRegionType = "table",
        showType="Manual",
        }
	    ModuleCache.ModuleManager.show_public_module("activity", object)
    elseif (obj.name == "ButtonChat") then
        ModuleCache.ModuleManager.show_module("henanmj", "tablechat", { is_New_Sever = true, allChatMsgs = allChatMsgs, curTableData = self.chatCurTableData, config = self.chatConfig })
    elseif (obj.name == "SelectCompare") then
        self.tableLogic:onclick_selectCompare(obj, arg)
    elseif (obj.name == "Info") then
        local headObj = obj.transform:Find("HeadBg/Avatar/Mask/Image").gameObject
        local seatInfo = self:getSeatInfoByHeadImageObj(headObj)
        if (not seatInfo or (not seatInfo.playerInfo)) then
            -- print("seatInfo is not exist")
            return
        end
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", seatInfo.playerInfo)
    elseif (obj == self.tableView.buttonComparePoker.gameObject) then
        self.tableLogic:onClickComparePokerBtn(obj, arg)
    elseif (obj == self.tableView.buttonDropPoker.gameObject) then
        self.tableLogic:onClickDropPokerBtn(obj, arg)
    elseif (obj == self.tableView.ButtonCheck.gameObject) then
        self.tableLogic:onclick_check_pokers_btn(obj, arg)
    elseif (obj == self.tableView.BtnXuePin.gameObject) then
        --if(self.tableView:isJinBiChang()) then
        --    local cur_op_list = self.modelData.curTableData.roomInfo.cur_op_list
        --    if(cur_op_list.allin) then
        --        self.tableLogic:onclick_XuePinBtn(obj, arg)
        --    else
        --        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("仅剩两个玩家时才可发起血拼")
        --    end
        --else
        --    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("仅在金币场才可发起血拼")
        --end
        local cur_op_list = self.modelData.curTableData.roomInfo.cur_op_list
        if(cur_op_list.allin) then
            self.tableLogic:onclick_XuePinBtn(obj, arg)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("必闷轮结束后，仅剩2个玩家才可发起血拼")
        end
    elseif (obj == self.tableView.BtnXuePinFollow.gameObject) then
        self.tableLogic:onclick_BtnXuePinFollow(obj, arg)
    elseif (obj == self.tableView.AddBetRootBtnClose.gameObject) then
        self.tableView:SetState_AddBetRoot(false)
    elseif (obj == self.tableView.toggleFollowAlways.gameObject) then
        self.tableLogic:onclick_follow_always_btn(obj, arg)
    elseif (obj == self.tableView.buttonFollow.gameObject) then
        self.tableLogic:onclick_follow_btn(obj, arg)
    elseif (obj == self.tableView.BtnAdd.gameObject) then
        self.tableLogic:onclick_more_btn(obj, arg)
    elseif (obj.transform.parent.gameObject == self.tableView.goMoreBtns) then
        self.tableLogic:onclick_more_bet_btn(obj, arg)
    elseif (obj.transform.parent.parent.gameObject == self.tableView.AddBetRoot) then
        self.tableLogic:onclick_AddBetBtn(obj, arg)
    elseif (obj == self.tableView.ButtonJinBiChangExit.gameObject) then
        if(self.tableView:isJinBiChang()) then
            --print("=====金币场离开房间")
            UnityEngine.PlayerPrefs.SetInt("ChangeTable", 0)
            self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
        else
            local canExitRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and (not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
            local canDissolveRoom = not canExitRoom
            if(canDissolveRoom) then
                --print("=====好友场解散房间")
                self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)
            else
                --print("=====好友场离开房间")
                self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
            end
        end
    elseif (obj == self.tableView.ButtonRuleExplain.gameObject) then
        ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
    elseif (obj == self.tableView.ButtonReplaceTable.gameObject) then
        TableManager.LastChangeTableTime = Time.realtimeSinceStartup
        UnityEngine.PlayerPrefs.SetInt("ChangeTable", 1)
        self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
    elseif (obj == self.tableView.ButtonRule.gameObject) then
        ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
    elseif (obj == self.tableView.TestBtnReconnection.gameObject) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("点击触发断线重连")
        TableManagerPoker:heartbeat_timeout_reconnect_game_server()
    elseif (obj.name == "ButtonShop") then
        --ModuleCache.ModuleManager.show_module("henanmj", "shop", 7)
        self.model:request_UserRechargeReq(true)
        ModuleCache.ModuleManager.show_module("public", "goldadd")
    elseif (obj == self.tableView.BtnLeftOpen.gameObject) then
        self.tableView:SetState_LeftRoot(true)
    elseif (obj == self.tableView.BtnLeftClose.gameObject) then
        self.tableView:SetState_LeftRoot(false)

        --TODO XLQ:亲友圈快速组局  手动准备
    elseif (obj == self.view.buttonReady_museum.gameObject) then
        self.model:request_ready()
        self.view:MuseumReadyState(false)

        --TODO XLQ:亲友圈快速组局   踢人
    elseif (obj.name == "KickBtn") then
        local seatInfo = self:GetSeatInfoByKickBtn(obj)
        if(seatInfo == nil) then
            print("=====seatInfo is not exist")
            return
        end
        self.model:request_KickPlayerReq(tonumber(seatInfo.playerId) )
    end
end

function TableModule_ZhaJinHua:on_double_click(obj, arg)

end

function TableModule_ZhaJinHua:GetSeatInfoByKickBtn(obj)
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

function TableModule_ZhaJinHua:getSeatInfoByHeadImageObj(obj)
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

function TableModule_ZhaJinHua:refresh_share_clip_board()
    self:share_room_info_text(self:get_share_data())
end

function TableModule_ZhaJinHua:clean_share_clip_board()
    self:clear_share_room_info_text()
end

function TableModule_ZhaJinHua:get_share_data()
    local roomInfo = self.modelData.curTableData.roomInfo

    local ruleTable = roomInfo.ruleTable
    local shareData = { }
    shareData.type = 2
    shareData.rule = roomInfo.ruleTable
    shareData.baseScore = self.tableView:GetCurBaseCoinScore()
    local proStr = ModuleCache.PlayModeUtil.get_province_data(AppData.App_Name).shortName
    local wanfaName, ruleDesc = TableUtil.get_rule_name(roomInfo.rule, self.modelData.roleData.HallID > 0)
    local gameType = roomInfo.ruleTable.GameType or roomInfo.ruleTable.gameType or roomInfo.ruleTable.game_type or roomInfo.ruleTable.bankerType or 3
    local _, name, wanfaName = Config.GetWanfaIdx(gameType)
    if (string.find(wanfaName, proStr)) then
        shareData.title = wanfaName
    else
        shareData.title = proStr .. wanfaName
    end
    if (AppData.App_Name == "DHAHQP") then
        shareData.title = wanfaName
    end
    shareData.ruleName = ruleDesc .. ""
    shareData.userID = self.modelData.roleData.userID
    shareData.roomType = 0
    shareData.roomId = tostring(roomInfo.roomNum)
    shareData.gameName = AppData.get_url_game_name()
    if (self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0) then
        shareData.parlorId = self.modelData.roleData.HallID .. ""
        shareData.roomType = self.modelData.roleData.RoomType
    else
        shareData.roomType = 0
    end

    shareData.totalPlayer = ruleTable.playerCount
    shareData.totalGames = ruleTable.roundCount
    shareData.comeIn = ruleTable.allowEnter
    shareData.curPlayer = #roomInfo.seatInfoList

    if self.modelData.roleData.RoomType == 2 then--快速组局
        shareData.parlorId = shareData.parlorId ..  string.format("%06d",ModuleCache.GameManager.curGameId)
    end

    print("--------------share-----------shareData.type:",shareData.type,shareData.parlorId,shareData.matchId)

    print("====分享内容")
    print_table(shareData)
    return shareData
end

function TableModule_ZhaJinHua:inviteWeChatFriend()
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return
    end
    local shareData = self:get_share_data()
    ModuleCache.ShareManager().shareRoomNum(shareData, false)
end




function TableModule_ZhaJinHua:selectCardsByPokerArray(pokerArray)
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


function TableModule_ZhaJinHua:resetSelectedPokers()
    local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
    for i = 1, #cardsArray do
        if (cardsArray[i].selected) then
            cardsArray[i].selected = false
        end
    end
    self.tableView.seatHolderArray[1].selectedPokersArray = { }
end




function TableModule_ZhaJinHua:on_show(intentData)
    self.lastUpdateBeatTime = 0
    UpdateBeat:Add(self.UpdateBeat, self)
    self.gameClient = self.modelData.bullfightClient
    self.tableLogic:on_show()
end

function TableModule_ZhaJinHua:on_hide()
    UpdateBeat:Remove(self.UpdateBeat, self)
    self.tableLogic:on_hide()
end

function TableModule_ZhaJinHua:on_destroy()
    self:_on_model_event_unbind()
    UpdateBeat:Remove(self.UpdateBeat, self)
    self.tableLogic = nil
    self:FilterGold_ResetChatMsgs()
    if(self.table_voice_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_voice')
    end
    if(self.table_gift_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_gift')
    end
end


function TableModule_ZhaJinHua:UpdateBeat()
    if (not self.tableView.root.activeSelf) then
        return
    end

    self.tableLogic:update()
    -- 每几秒刷新一次电池,时间,网络
    if ((not self.lastBatteryTime) or (self.lastBatteryTime + 2 < Time.realtimeSinceStartup)) then
        self.lastBatteryTime = Time.realtimeSinceStartup
        self.tableView:refreshBatteryAndTimeInfo()
    end

    if ((not self.lastRefreshPingValTime) or (self.lastRefreshPingValTime + 1 < Time.realtimeSinceStartup)) then
        self.lastRefreshPingValTime = Time.realtimeSinceStartup
        if (self.model.lastPingReqeustTime) then
            self.view:show_ping_delay(true, UnityEngine.Time.realtimeSinceStartup - self.model.lastPingReqeustTime)
        elseif (self.model.pingDelayTime) then
            self.view:show_ping_delay(true, self.model.pingDelayTime)
        else
            self.view:show_ping_delay(true, 0.05)
        end
    end


    if ((self.lastUpdateBeatTime ~= 0) and ((not self.lastPingTime) or (self.lastPingTime + 3 < Time.realtimeSinceStartup))) then
        self.lastPingTime = Time.realtimeSinceStartup
        if (TableManagerPoker.clientConnected) then
            self.tableModel:request_ping()
        end
    end
    self.lastUpdateBeatTime = Time.realtimeSinceStartup
    if self.gameClient.clientConnected and (self.gameClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
        TableManagerPoker:heartbeat_timeout_reconnect_game_server()
    end

    if ((not self.OneSecond) or (self.OneSecond + 0.5 < Time.realtimeSinceStartup)) then
        self.OneSecond = Time.realtimeSinceStartup
        self:CheckBgMusic()
    end

end

function TableModule_ZhaJinHua:CheckBgMusic()
    local audioMusic = ModuleCache.SoundManager.audioMusic
    if (not audioMusic.isPlaying) then
        if(self.tableLogic:IsXuePinDoing()) then
            self.tableLogic:playSound_XuePinBeiJing()
            return
        end
        local bgMusic1 = "bgm_fangjian"
        local bgMusic2 = "bgmfight2"
        if ((not audioMusic.clip) or audioMusic.clip.name ~= bgMusic1) then
            --ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic1 .. ".bytes", bgMusic1)
            ModuleCache.SoundManager.play_music(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. bgMusic1 .. ".bytes", bgMusic1)
        else
            --ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic2 .. ".bytes", bgMusic2)
            ModuleCache.SoundManager.play_music(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. bgMusic1 .. ".bytes", bgMusic1)
        end
    else
        if(self.tableLogic:IsXuePinDoing()) then
            if(audioMusic.clip and audioMusic.clip.name == "bgm_xuepin") then
            else
                self.tableLogic:playSound_XuePinBeiJing()
            end
        end
    end
end

function TableModule_ZhaJinHua:PauseMusic()
    SoundManager.audioMusic.mute = true
end

function TableModule_ZhaJinHua:UnPauseMusic()
    SoundManager.audioMusic.mute = false
end


function TableModule_ZhaJinHua:addSeatInfo2ChatCurTableData(seatInfo)
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

function TableModule_ZhaJinHua:removeSeatInfoFromChatCurTableData(playerId)
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
function TableModule_ZhaJinHua:UploadIpAndAddress()
    print("UploadIpAndAddress")
    local newTable = { }
    newTable.address = ModuleCache.GPSManager.gpsAddress
    newTable.gpsInfo = ModuleCache.GPSManager.gps_info
    self.model:request_CustomInfoChange(ModuleCache.Json.encode(newTable))
end


function TableModule_ZhaJinHua:ResetChatMsgs( ... )
    allChatMsgs = { }
end

function TableModule_ZhaJinHua:FilterGold_ResetChatMsgs( ... )
    if (self.tableView:isJinBiChang()) then
        self:ResetChatMsgs()
    end
end


-- 获取活动左侧列表协议
function TableModule_ZhaJinHua:check_activity_is_open(callback)
    local requestData = {
        params =
        {
            uid = self.modelData.roleData.userID,
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getActivityViewList?",
    }

    local onResponse = function(wwwOperation)

        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            if(callback)then
                callback(retData.data and #retData.data ~= 0)
            end
        end
    end

    local onError = function(data)
        print(data.error);
    end
    self:http_get(requestData, onResponse, onError);
end


return TableModule_ZhaJinHua 