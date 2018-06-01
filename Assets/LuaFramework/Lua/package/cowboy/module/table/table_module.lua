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
--- @class CowBoy_TableModule
local TableModule = class('tableModule', ModuleBase)

local TableData = require("package/cowboy/module/table/table_data")
-- local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic")
local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local System = UnityEngine.System
local Time = Time
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

function TableModule:initialize(...)
    ModuleBase.initialize(self, "table_view", "table_model", ...)
    self.modelData.curTableData = nil
    self.tableHelper = self.view.tableHelper
    self.tableHelper.module = self
    self.tableHelper.modelData = self.modelData
    self.tableHelper.ruleTable = self.modelData.roleData.myRoomSeatInfo.RuleTable
    self.chatConfig = require('package.cowboy.config')
    local rule = ModuleCache.Json.decode(self.modelData.roleData.myRoomSeatInfo.Rule)

    self.tableData = TableData
    self.tableData:init()

    self.doubleClickInterval = 0.4

    print('>>>>>>>>>>>>>>>>>>', self.modelData.tableCommonData.isGoldTable, self.modelData.tableCommonData.isGoldSettle)
    local logicPath = ''
    local endName = ''
    if(self.modelData.tableCommonData.isGoldTable)then
        endName = '_goldcoin'
    elseif(self.modelData.tableCommonData.isGoldSettle)then
        endName = '_goldsettle'
    end
    if (rule.bankerType == 1) then
        if(self.tableHelper:isGuangDong())then    --广东棋牌
            logicPath = "package/cowboy/module/table/table_douniu_logic_randombanker_guangdong" .. endName
        else
            logicPath = "package/cowboy/module/table/table_douniu_logic_randombanker" .. endName
        end
    elseif (rule.bankerType == 2) then
        if(self.tableHelper:isGuangDong())then    --广东棋牌
            logicPath = "package/cowboy/module/table/table_douniu_logic_scramblebanker_guangdong" .. endName
        else
            logicPath = "package/cowboy/module/table/table_douniu_logic_scramblebanker" .. endName
        end
    else
        if(self.tableHelper:isGuangDong())then    --广东棋牌
            if(rule.name == 'TongbiNiu')then
                logicPath = "package/cowboy/module/table/table_douniu_logic_guangdong_tongbi" .. endName
            else
                logicPath = "package/cowboy/module/table/table_douniu_logic_guangdong" .. endName
            end
        else
            logicPath = "package/cowboy/module/table/table_douniu_logic_onebyone" .. endName
        end
    end
    print(logicPath)
    self.tableLogic = require(logicPath):new(self)

    self.netClient = self.modelData.cowboyClient
    self.table_gift_module = ModuleCache.ModuleManager.show_module('public','table_gift')
    self.table_voice_module = ModuleCache.ModuleManager.show_module('public','table_voice')
    TableManagerPoker:registLoginGameCallbacks( function(data)
        if (not data.err_no or data.err_no == "0") then
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.SoundManager.stop_music()
            ModuleCache.ModuleManager.show_module("cowboy", "table")
        else
            TableManagerPoker:disconnect_game_server()
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
            ModuleCache.ModuleManager.destroy_package("cowboy")
            ModuleCache.ModuleManager.destroy_package("henanmj")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
        end
    end )


    onAppFocusCallback = function(eventHead, eventData)
        ----print("onAppFocusCallback", eventData)
        self.tableModel:request_TempLeave(not eventData)
    end
    self:subscibe_app_focus_event(onAppFocusCallback)

    self:begin_location( function()
        self:UploadIpAndAddress()
    end )
end


function TableModule:on_module_inited()

end


function TableModule:on_module_event_bind()
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

    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.model:request_refresh_user_coin()
    end)


    self:subscibe_package_event("Event_PokerTableFrame_Click_Leave", function(eventHead, eventData)
        if(self.modelData.tableCommonData.isGoldTable)then
            self:on_click_exit_btn()
        else
            self:on_click_leave_btn()
        end
    end )
    self:subscibe_package_event("Event_PokerTableFrame_Click_Setting", function(eventHead, eventData)
        self:on_click_setting_btn()
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


function TableModule:show_hide_seat_speak_amin(playerId, show)
    local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
    if(seatInfo)then
        if(show)then
            self.view:show_voice(seatInfo.localSeatIndex)
        else
            self.view:hide_voice(seatInfo.localSeatIndex)
        end
    end

end

function TableModule:on_model_event_bind()

    self:subscibe_model_event("Event_Table_Enter_Room", function(eventHead, eventData)
        -- 登陆成功				
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

    self.tableModel.subscibe_event(TableManagerPoker, "Event_Table_Synchronize_Notify", function(eventHead, eventData)
        -- 登陆成功			
        if (eventData.room_info.roomNum ~= lastRoomNum) then
            allChatMsgs = { }
            ModuleCache.FileUtility.DirectoryDelete(voicePath, true)
            ModuleCache.FileUtility.DirectoryCreate(voicePath)
        end
        lastRoomNum = eventData.room_info.roomNum
        self.tableLogic:on_table_synchronize_notify(eventData)
    end )


    self:subscibe_model_event("Event_Table_AgoSettleAccounts_Notify", function(eventHead, eventData)
        -- 登陆成功
        self.tableLogic:on_table_ago_settle_accounts_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_Reset_Notify", function(eventHead, eventData)
        --重置广播
        if(self.tableLogic.on_reset_notify)then
            self.tableLogic:on_reset_notify(eventData)
        end
    end )


    self:subscibe_model_event("Event_Table_Ready_Rsp", function(eventHead, eventData)
        -- 登陆成功		
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_ready_rsp(eventData)

    end )

    self:subscibe_model_event("Event_Table_Start_Rsp", function(eventHead, eventData)
        -- 登陆成功		
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (tostring(eventData.err_no) == "0") then
            self.tableLogic:on_table_start_rsp()
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_EnterRoom_Notify", function(eventHead, eventData)
        -- 登陆成功		
        self.tableLogic:on_table_enter_notify(eventData)
        self:refresh_share_clip_board()
    end )

    self:subscibe_model_event("Event_Table_Leave_Room_Rsp", function(eventHead, eventData)
        -- 登陆成功		
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            self:exit_room()
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_Leave_Room_Notify", function(eventHead, eventData)
        -- 登陆成功		
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        local playerId = eventData.player_id
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        seatInfo.playerId = "0"
        seatInfo.playerInfo = nil
        seatInfo.isSeated = false

        self.tableView:refreshSeat(seatInfo, false)
        -- 显示玩家当局赢得分数
        self.tableView:showSeatWinScoreCurRound(seatInfo, false)
        -- 播放分数动画
        self.tableView:showSeatRoundScoreAnim(seatInfo, false)
        -- 显示牛名
        self.tableView:showNiuName(seatInfo, false)

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 是否显示定位图标
        TableManagerPoker:isShowLocation(playerInfoList, self.tableView.buttonLocation);
        self:refresh_share_clip_board()
    end )


    self:subscibe_model_event("Event_Table_Bet", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            self.tableLogic:on_table_bet_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_Bet_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_bet_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_Start_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_start_notify(eventData)
        self:clean_share_clip_board()
    end )

    self:subscibe_model_event("Event_Table_ComputePoker", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_compute_rsp(eventData)

    end )

    self:subscibe_model_event("Event_Table_ComputePoker_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_compute_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_SettleAccounts_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_settleAccounts_Notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_LastSettleAccounts_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_lastsettleAccounts_Notify(eventData)
        ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
    end )

    self:subscibe_model_event("Event_Table_Deal_Poker_Notify", function(eventHead, eventData)
        -- 登陆成功		
        -- print("Event_Table_Deal_Poker_Notify")
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.tableLogic:on_table_fapai_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_Ready_Notify", function(eventHead, eventData)
        -- 登陆成功				
        self.tableLogic:on_table_ready_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_Synchronize_Notify", function(eventHead, eventData)
        if (eventData.room_info.roomNum ~= lastRoomNum) then
            allChatMsgs = { }
            ModuleCache.FileUtility.DirectoryDelete(voicePath, true)
            ModuleCache.FileUtility.DirectoryCreate(voicePath)
        end
        lastRoomNum = eventData.room_info.roomNum
        self.tableLogic:on_table_synchronize_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_SetBanker_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_setbanker_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_ScrambleBanker", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            self.tableLogic:on_table_scramblebanker_rsp(eventData)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_ScrambleBanker_Notify", function(eventHead, eventData)
        self.tableLogic:on_table_scramblebanker_notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_Reconnect_Notify", function(eventHead, eventData)
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
        seatInfo.isOffline = false
        seatInfo.isTempLeave = false
        self.tableView:refreshSeatInfo(seatInfo)
    end )

    self:subscibe_model_event("Event_Table_Disconnect_Notify", function(eventHead, eventData)
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        local seatInfo = self.tableHelper:getSeatInfoByPlayerId(eventData.player_id, seatInfoList)
        seatInfo.isOffline = true
        seatInfo.isTempLeave = false
        self.tableView:refreshSeatOfflineState(seatInfo)
    end )

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
    ----亲友圈 快速组局 踢人倒计时
    --self:subscibe_model_event("Event_Table_KickPlayerExpire", function(eventHead, eventData)
    --    ModuleCache.ModuleManager.hide_public_module("netprompt")
    --    print("---------------------Event_Table_KickPlayerExpire.expire=",eventData.expire)
    --    --if(self.modelData.curTableData.RoomType == 3) then
    --
    --    self.view.buttonReady_fastStart.gameObject:SetActive(true)
    --    if self.kickedTimeId then
    --        CSmartTimer:Kill(self.kickedTimeId)
    --    end
    --
    --    self.kickedTimeId = self:subscibe_time_event(eventData.expire, false, 1):OnUpdate(function(t)
    --        t = t.surplusTimeRound
    --        self.view.textFastStartLimitTime.text = "("..t..")"
    --    end):OnComplete(function(t)
    --
    --    end).id
    --
    --end)

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

    self:subscibe_model_event("Event_Table_ShotSettle_Notify", function(eventHead, eventData)
        if(self.tableLogic.on_shotsettle_notify)then
            self.tableLogic:on_shotsettle_notify(eventData)
        end
    end )
end


function TableModule:on_send_gift_chat_msg(senderPlayerId, content)
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

function TableModule:_on_model_event_unbind()
    self.tableModel.unsubscibe_event_by_name(TableManagerPoker, "Event_Table_Synchronize_Notify")
end

-- 离开房间
function TableModule:exit_room(tip)
	TableManager:disconnect_login_server()
    TableManagerPoker:disconnect_game_server()
	ModuleCache.net.NetClientManager.disconnect_all_client()
	ModuleCache.ModuleManager.hide_public_module("netprompt")

	--TODO XLQ 金币场换桌
	if UnityEngine.PlayerPrefs.GetInt("ChangeTable", 0) ==0 then
        ModuleCache.ModuleManager.destroy_package("cowboy")
        ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
	else
		TableManager:join_room(
		nil,
			UnityEngine.PlayerPrefs.GetString("LastJoinWanfaName",""),
		nil,
			UnityEngine.PlayerPrefs.GetInt("LastJoinGoldFieldID",1)
		)
		UnityEngine.PlayerPrefs.SetInt("ChangeTable",0)
	end

	if (tip) then
    	ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(tip)		
	end
end

function TableModule:genFreeRoomData(data)
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


function TableModule:getShotTextByShotTextIndex(index)
    local config = self.chatConfig
    return config.chatShotTextList[index]
end

function TableModule:playerShotVocieByShotTextIndex(index, seatInfo)
    local voiceName = ""
    if (seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then
        voiceName = "chat_female_" .. index
    else
        voiceName = "chat_male_" .. index
    end
    ModuleCache.SoundManager.play_sound("publictable", "publictable/sound/tablepoker/" .. voiceName .. ".bytes", voiceName)
end

function TableModule:on_press_up(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressUpMic', data)
    elseif (obj == self.tableView.buttonMaskPoker.gameObject) then
        self.tableLogic:on_press_upMaskPoker(obj, arg)
    end
end

function TableModule:on_drag(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnDragMic', data)
    elseif (obj == self.tableView.buttonMaskPoker.gameObject) then
        self.tableLogic:on_dragMaskPoker(obj, arg)
    end
end

function TableModule:on_press(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressMic', data)
    elseif (obj == self.tableView.buttonMaskPoker.gameObject) then
        self.tableLogic:on_press_downMaskPoker(obj, arg)
    end
end

function TableModule:on_click(obj, arg)
    --[[
	if(self.lastClickObj == obj and self.lastClickTime + self.doubleClickInterval > Time.realtimeSinceStartup)then
		self:on_double_click(obj, arg)
		return
	end
	--]]

    self.lastClickObj = obj
    self.lastClickTime = Time.realtimeSinceStartup
    -- print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if (self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup) then
        return
    end
    local startIndex, endIndex = string.find(obj.name, "Poker")
    if (startIndex == 1) then
        self.tableLogic:onClickPoker(obj)
    elseif (obj == self.tableView.buttonSetting.gameObject) then
        self:on_click_setting_btn(obj, arg)
        -- 根据房间是否开始的状态传值
    elseif (obj == self.tableView.buttonLocation.gameObject) then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表
        local playerInfoList = TableManagerPoker:getPlayerInfoList(seatInfoList);
        -- 获取位置信息文本
        local tipText, distanceText = TableManagerPoker:get_gps_warn_text(playerInfoList);
        ModuleCache.ModuleManager.show_module("henanmj", "tablegps2", tipText .. "," .. distanceText)
        -- 根据房间是否开始的状态传值
    elseif (obj == self.tableView.buttonLiangPai.gameObject) then
        self.tableLogic:onClickLiangPaiBtn()
    elseif (obj == self.tableView.buttonHasNiu.gameObject) then
        self.tableLogic:onClickHasNiuBtn()
    elseif (obj == self.tableView.buttonNoNiu.gameObject) then
        self.tableLogic:onClickNoNiuBtn()
    elseif (obj == self.tableView.buttonBetNone.gameObject) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("不下注")
    elseif(obj == self.tableView.buttonTestReconnect.gameObject) then
        self:on_click_test_reconnect_btn(obj, arg)
    elseif (obj == self.tableView.buttonQiangZhuang.gameObject) then
        self.tableModel:request_scrambleBanker(true)
    elseif (obj == self.tableView.buttonNotQiangZhuang.gameObject) then
        self.tableModel:request_scrambleBanker(false)
    elseif(obj.transform.parent.name == 'SelectMultiple')then
        self.tableLogic:on_click_bet_btn(obj, arg)
    elseif(obj.transform.parent.name == 'GoldCoinBetBtns')then
        self.tableLogic:on_click_goldcoin_bet_btn(obj, arg)
    elseif(obj.transform.parent.name == 'QiangZhuangBtns')then
        self.tableLogic:on_click_qiangzhuang_btn(obj, arg)
    elseif (obj == self.tableView.buttonStart.gameObject) then
        self.tableLogic:onclick_start_btn(obj)
    elseif (obj == self.tableView.buttonExit.gameObject) then
        self:on_click_exit_btn(obj, arg)
    elseif (obj == self.tableView.button_goldCoin_exit.gameObject) then
        if(self.tableLogic.on_click_goldcoin_exit_btn)then
            self.tableLogic:on_click_goldcoin_exit_btn(obj, arg)
        end
    elseif (obj == self.tableView.button_wanfashuoming.gameObject) then
        if(self.tableLogic.on_click_wanfashuoming_btn)then
            self.tableLogic:on_click_wanfashuoming_btn(obj, arg)
        end
    elseif(obj == self.tableView.buttonChangeRoom.gameObject)then
        UnityEngine.PlayerPrefs.SetInt("ChangeTable", 1)
        self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
    elseif (obj == self.tableView.buttonReady.gameObject) then
        self.tableLogic:onclick_ready_btn(obj)
    elseif (obj == self.tableView.button_goldcoin_ready.gameObject) then
        self.tableLogic:onclick_ready_btn(obj)
    elseif (obj == self.tableView.buttonContinue.gameObject) then
        self.tableLogic:onclick_continue_btn(obj)
	elseif(obj == self.tableView.toggleAutoSelectNiu.gameObject) then		
		self.tableLogic:onclick_autoselectniu_toggle(obj)	
    elseif (obj.name == "NotSeatDown" or obj == self.tableView.buttonInvite.gameObject) then
        if(self.tableLogic.on_click_invite_btn)then
            self.tableLogic:on_click_invite_btn(obj, arg)
            return
        end
        self.lastClickInviteTime = Time.realtimeSinceStartup
        self:inviteWeChatFriend()
    elseif (obj.name == "ButtonChat") then
        ModuleCache.ModuleManager.show_module("henanmj", "tablechat", { is_New_Sever = true, allChatMsgs = allChatMsgs, curTableData = self.chatCurTableData, config = self.chatConfig })
    elseif (obj.name == "ButtonMic") then

    elseif (obj.name == "Image") then
        local seatInfo = self:getSeatInfoByHeadImageObj(obj)
        if (not seatInfo or (not seatInfo.playerInfo)) then
            -- print("seatInfo is not exist")
            return
        end
        if(self.tableLogic.playerCustomInfoMap)then
            local locationData = self.tableLogic.playerCustomInfoMap[seatInfo.playerId]
            seatInfo.playerInfo.locationData = locationData
            if(locationData) and locationData.ip then
                seatInfo.playerInfo.ip = locationData.ip
            end
        end
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", seatInfo.playerInfo)
    elseif obj.name == "ButtonRule" then
        local rule = { };
        rule = ModuleCache.Json.decode(self.modelData.curTableData.roomInfo.rule);
        rule.name = "DouNiu"
        if (rule.ruleType == nil) then
            rule.name = "ZhaJinNiu"
        end
        rule = ModuleCache.Json.encode(rule);
        --print_table(rule.ruleInfo)
        --ModuleCache.ModuleManager.show_module("cowboy", "tablerule", rule)
	    ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
    elseif (obj.name == "ButtonShop") then
        --ModuleCache.ModuleManager.show_module("henanmj", "shop", 7)
        ModuleCache.ModuleManager.show_module("public", "goldadd")

    elseif (obj.name == "KickBtn") then--TODO XLQ:亲友圈快速组局   踢人
        local seatInfo = self:GetSeatInfoByKickBtn(obj)
        if(seatInfo == nil) then
            print("=====seatInfo is not exist")
            return
        end
        self.model:request_KickPlayerReq(tonumber(seatInfo.playerId) )
    end
end

function TableModule:on_click_exit_btn(obj, arg)
    UnityEngine.PlayerPrefs.SetInt("ChangeTable", 0)
    if(self.modelData.tableCommonData.isGoldTable)then
        self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
        return
    end
    local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and(not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
    if canLeaveRoom or self.modelData.roleData.RoomType == 2 then--快速组局都发离开请求
        self:dispatch_package_event("Event_RoomSetting_LeaveRoom", 1)
    else
        self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)
    end
end

function TableModule:on_click_test_reconnect_btn(obj, arg)
    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("点击触发断线重连")
    TableManagerPoker:heartbeat_timeout_reconnect_game_server()
end

function TableModule:on_click_setting_btn(obj, arg)
    if(self.tableLogic.on_click_setting_btn)then
        self.tableLogic:on_click_setting_btn()
        return
    end
    local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and(not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
    local intentData = { }
    intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_" .. "BULLFIGHT"
    intentData.canExitRoom = canLeaveRoom
    intentData.canDissolveRoom = not canLeaveRoom
    intentData.tableBackgroundSprite = self.view.tableBackgroundSprite
    ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", intentData)
end

function TableModule:on_click_leave_btn(obj, arg)
    local canLeaveRoom = self.modelData.curTableData.roomInfo.curRoundNum == 0 and(not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator)
    if(canLeaveRoom)then
        self.model:request_exit_room()
    else
        self.model:request_dissolve_room(true)
    end
end


function TableModule:on_double_click(obj, arg)
    if (obj == self.tableView.buttonHasNiu.gameObject) then
        self.tableLogic:onDoubleClickHasNiuBtn()
    end
end

function TableModule:GetSeatInfoByKickBtn(obj)
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

function TableModule:getSeatInfoByHeadImageObj(obj)
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

function TableModule:setShareData(totalPlayer, totalGames, comeIn, curPlayer)
    self.share_totalPlayer = totalPlayer
    self.share_totalGames = totalGames
    self.share_comeIn = comeIn
    self.share_curPlayer = curPlayer
end

function TableModule:refresh_share_clip_board()
    self:share_room_info_text(self:get_share_data())
end

function TableModule:clean_share_clip_board()
    self:clear_share_room_info_text()
end

function TableModule:get_share_data()
    if(self.tableLogic.on_pre_share_room_num)then
        self.tableLogic:on_pre_share_room_num()
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local ruleTable = roomInfo.ruleTable
    local shareData = { }
    shareData.type = 2
    shareData.roomId = ""
    shareData.rule = roomInfo.ruleTable             --规则
    shareData.baseScore = roomInfo.baseCoinScore    --底分
    shareData.goldId = self.modelData.tableCommonData.goldFieldID

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
    shareData.totalPlayer = self.share_totalPlayer
    shareData.totalGames = self.share_totalGames
    shareData.comeIn = self.share_comeIn
    shareData.curPlayer = self.share_curPlayer
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
    return shareData
end

function TableModule:inviteWeChatFriend()
    if(not self.tableLogic:can_invite_wechat_friend())then
        return
    end
    local shareData = self:get_share_data()
    ModuleCache.ShareManager().shareRoomNum(shareData, false)
end




function TableModule:selectCardsByPokerArray(pokerArray, withoutAnim)
    local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
    local selectedPokersArray = { }
    for i = 1, #cardsArray do
        cardsArray[i].selected = false
        self.tableView:refreshCardSelect(cardsArray[i], withoutAnim)
        for j = 1, #pokerArray do
            if (cardsArray[i].poker == pokerArray[j]) then
                cardsArray[i].selected = true
                table.insert(selectedPokersArray, cardsArray[i].poker)
                self.tableView:refreshCardSelect(cardsArray[i], withoutAnim)
            end
        end
    end
    self.tableView.seatHolderArray[1].selectedPokersArray = selectedPokersArray
    self.tableView:refreshSelectedNiuNumbers()
end


function TableModule:resetSelectedPokers()
    local cardsArray = self.tableView.seatHolderArray[1].inhandCardsArray
    for i = 1, #cardsArray do
        if (cardsArray[i].selected) then
            cardsArray[i].selected = false
        end
    end
    self.tableView.seatHolderArray[1].selectedPokersArray = { }
end




function TableModule:on_show(intentData)
    self.lastUpdateBeatTime = 0
    self.gameClient = self.modelData.bullfightClient
    UpdateBeat:Add(self.UpdateBeat, self)
    self.tableLogic:on_show()
end

function TableModule:on_hide()
    UpdateBeat:Remove(self.UpdateBeat, self)
    self.tableLogic:on_hide()
end

function TableModule:on_destroy()
    self:_on_model_event_unbind()
    UpdateBeat:Remove(self.UpdateBeat, self)
    self.tableLogic = nil
    self.modelData.curTableData = nil
    self:dispatch_package_event('Event_On_PokerTable_Destroy')
    if(self.table_voice_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_voice')
    end
    if(self.table_gift_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_gift')
    end
end


function TableModule:UpdateBeat()
    if (self.isDestroy) then
        return
    end
    if (self.lastUpdateBeatTime + 0.5 > Time.realtimeSinceStartup) then
        return
    end

    local pingDelayTime = 0.05
    if (self.model.lastPingReqeustTime) then
        pingDelayTime = UnityEngine.Time.realtimeSinceStartup - self.model.lastPingReqeustTime
        self.view:show_ping_delay(true, pingDelayTime)
    elseif (self.model.pingDelayTime) then
        pingDelayTime = self.model.pingDelayTime
        self.view:show_ping_delay(true, pingDelayTime)
    else
        self.view:show_ping_delay(true, 0.05)
    end
    self:dispatch_package_event('Event_Refresh_Ping_Value', pingDelayTime)
    self.tableLogic:update()
    self.tableView:refreshBatteryAndTimeInfo()
    if ((self.lastUpdateBeatTime ~= 0) and((not self.lastPingTime) or(self.lastPingTime + 3 < Time.realtimeSinceStartup))) then
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
        local bgMusic3 = 'bgm_fangjian'
        ModuleCache.SoundManager.play_music("cowboy", "cowboy/sound/table/" .. bgMusic3 .. ".bytes", bgMusic3)
    end
end

function TableModule:PauseMusic()
    SoundManager.audioMusic.mute = true
end

function TableModule:UnPauseMusic()
    SoundManager.audioMusic.mute = false
end


function TableModule:addSeatInfo2ChatCurTableData(seatInfo)
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

function TableModule:removeSeatInfoFromChatCurTableData(playerId)
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


--------上传IP和地址
-- function TableModule:CoroutineUploadIpAndAddress()
-- local loclCO = coroutine.create(function()
-- 	WaitForSeconds(1)
-- 	self:UploadIpAndAddress()
-- end)
-- coroutine.resume(loclCO)
-- end


-- function TableModule:UploadIpAndAddress(_ip,_address)
-- local newTable = {}
-- newTable.ip = _ip or ""
-- if(_ip == nil and self.modelData.curTableData.roomInfo.mySeatInfo.playerInfo ~= nil) then
-- 	newTable.ip = self.modelData.curTableData.roomInfo.mySeatInfo.playerInfo.ip or ""
-- end
--
-- newTable.address =_address or ModuleCache.GPSManager.gpsAddress or ""
-- if(self.modelData.curTableData.roomInfo.mySeatInfo.playerInfo ~= nil) then
-- 	self.modelData.curTableData.roomInfo.mySeatInfo.playerInfo.locationData = self.modelData.curTableData.roomInfo.mySeatInfo.playerInfo.locationData or {}
-- 	self.modelData.curTableData.roomInfo.mySeatInfo.playerInfo.locationData.address = newTable.address
-- end
--
-- print("==ip="..tostring(newTable.ip),"address="..tostring(newTable.address))
-- self.model:request_CustomInfoChange(ModuleCache.Json.encode(newTable))
-- end

-- 上传IP和地址
function TableModule:UploadIpAndAddress()
    print("UploadIpAndAddress")
    local newTable = { }
    newTable.address = ModuleCache.GPSManager.gpsAddress
    newTable.gpsInfo = ModuleCache.GPSManager.gps_info
    if(self.modelData.curTableData and self.modelData.curTableData.roomInfo and self.modelData.curTableData.roomInfo.mySeatInfo)then
        local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
        if(mySeatInfo.playerInfo)then
            newTable.ip = mySeatInfo.playerInfo.ip
        else
            mySeatInfo.on_get_userinfo_callback_queue = mySeatInfo.on_get_userinfo_callback_queue or list:new()
            local cb = function(seatInfo)
                self:UploadIpAndAddress()
            end
            mySeatInfo.on_get_userinfo_callback_queue:push(cb)
            return
        end
    end
    if self.model then
        self.model:request_CustomInfoChange(ModuleCache.Json.encode(newTable))
    end
end


return TableModule 