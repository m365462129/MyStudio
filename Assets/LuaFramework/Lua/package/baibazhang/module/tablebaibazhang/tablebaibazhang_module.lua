local class = require("lib.middleclass");
local list = require("list")
local ModuleBase = require('core.mvvm.module_base');
--- @class TableBaiBaZhangModule
--- @field TableBaiBaZhangLogic TableBaiBaZhangLogic
--- @field tableBaiBaZhangView TableBiJiVie
--- @field view TableBiJiView
--- @field model TableBiJiModel
local TableBaiBaZhangModule = class('tableBiJiModule', ModuleBase);
local View = require('core.mvvm.view_base')
local TableView = class('tableView', View)
local doubleClickInterval = 0.4
local ModuleCache = ModuleCache
local TableBaiBaZhangHelper = require("package/baibazhang/module/tablebaibazhang/tablebaibazhang_helper")
local GameSDKInterface = ModuleCache.GameSDKInterface
local WechatManager = ModuleCache.WechatManager
local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local voicePath = Application.persistentDataPath .. "/voice"
local Time = Time
local ChatMsgType = { }
ChatMsgType.shotMsg = 1
ChatMsgType.emojiMsg = 2
ChatMsgType.text = 3
ChatMsgType.voiceMsg = 0
ChatMsgType.gift = 10

local allChatMsgs = { }
local lastRoomNum

local onAppFocusCallback



function TableBaiBaZhangModule:initialize(...)
    ModuleBase.initialize(self, "tablebaibazhang_view", "tablebaibazhang_model", ...);
    self.chatConfig = require('package.baibazhang.config')
    self.TableBaiBaZhangLogic = require("package/baibazhang/module/tablebaibazhang/tablebaibazhang_logic"):new(self);
    self.tableBaiBaZhangHelper = TableBaiBaZhangHelper
    self.tableBaiBaZhangHelper.module = self
    self.tableBaiBaZhangHelper.modelData = self.modelData
    -- self.TableBaiBaZhangLogic:setTestData();

    self.table_gift_module = ModuleCache.ModuleManager.show_module('public','table_gift')
    self.table_voice_module = ModuleCache.ModuleManager.show_module('public','table_voice')
    onAppFocusCallback = function(eventHead, eventData)
        if (eventData) then
            self.tableBaiBaZhangModel:request_temporary_leave(false, self.modelData.roleData.userID)
        else
            self.tableBaiBaZhangModel:request_temporary_leave(true, self.modelData.roleData.userID)
        end
    end
    self:subscibe_app_focus_event(onAppFocusCallback)

    -- self:CoroutineUploadIpAndAddress()
    self:begin_location( function()
        self:UploadIpAndAddress()
    end )
    self:check_activity_is_open()
end

function TableBaiBaZhangModule:on_module_inited()
    self.gameClient = self.modelData.bullfightClient
end

function TableBaiBaZhangModule:on_show(intentData)
    --self.lastUpdateBeatTime = 0
    self.gameClient = self.modelData.bullfightClient
    --UpdateBeat:Add(self.UpdateBeat, self)
    --self:UpdateBeat()
    -- self.tablebijiLogic:on_show()
end

function TableBaiBaZhangModule:on_hide()
    --UpdateBeat:Remove(self.UpdateBeat, self)
    -- self.tableLogic:on_hide()
end

function TableBaiBaZhangModule:on_destroy()
    self:_on_model_event_unbind()
    --UpdateBeat:Remove(self.UpdateBeat, self)
    if (self.showResultViewSmartTimer_id) then
        SmartTimer.Kill(self.showResultViewSmartTimer_id)
        self.showResultViewSmartTimer_id = nil
    end
    if(self.table_voice_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_voice')
    end
    if(self.table_gift_module)then
        ModuleCache.ModuleManager.destroy_module('public','table_gift')
    end
end

function TableBaiBaZhangModule:_on_model_event_unbind()
    self.tableBaiBaZhangModel.unsubscibe_event_by_name(TableManagerPoker, "Event_Table_Synchronize_Notify")
end

function TableBaiBaZhangModule:get_userinfo(playerId, callback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params =
        {
            uid = playerId,
        },
        cacheDataKey = "user/info?uid=" .. playerId
    }

    self.module:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            -- OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end , function(error)
        print(error.error)
        callback(error.error, nil);
    end , function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then
            -- OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end )
end

function TableBaiBaZhangModule:getPlayerInfo(data, callback)
    self:get_userinfo(data.playerId, function(err, playerData)
        print("finish get userInfo")
        if (err) then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(err)
            -- ModuleCache.ModuleManager.hide_public_module("netprompt")
            return
        end
        local player = { }
        player.uid = playerData.userId
        player.nickname = playerData.nickname
        player.headImg = playerData.headImg
        data.player = player
        callback(err)
    end )
end

function TableBaiBaZhangModule:setSeatTableData()

end

function TableBaiBaZhangModule:on_update_per_second()
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
    -- self.tableBiJiLogic:update()
    self.tableBaiBaZhangView:refreshBatteryAndTimeInfo()

    if (((not self.lastPingTime) or(self.lastPingTime + 3 < Time.realtimeSinceStartup))) then  --(self.lastUpdateBeatTime ~= 0) and
        self.lastPingTime = Time.realtimeSinceStartup
        if self.gameClient.clientConnected then
            self.tableBaiBaZhangModel:request_ping()
        end
    end

    --self.lastUpdateBeatTime = Time.realtimeSinceStartup
    if ((not self.lastCheckTime) or(self.lastCheckTime + 1.5 < Time.realtimeSinceStartup)) then
        self.lastCheckTime = Time.realtimeSinceStartup
        self.tableBaiBaZhangView:CheckSpriteInHand()
        self.tableBaiBaZhangView:CheckSpriteInMatch()
    end

    -- print("心跳超时包", (self.gameClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup))
    if self.gameClient.clientConnected and(self.gameClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
        TableManagerPoker:heartbeat_timeout_reconnect_game_server()
    end

    local audioMusic = ModuleCache.SoundManager.audioMusic
    if (not audioMusic.isPlaying) then
        local bgMusic1 = "bgmfight1"
        local bgMusic2 = "bgmfight2"
        if ((not audioMusic.clip) or audioMusic.clip.name ~= bgMusic1) then
            ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic1 .. ".bytes", bgMusic1)
        else
            ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic2 .. ".bytes", bgMusic2)
        end
    end
end

function TableBaiBaZhangModule:on_model_event_bind()

    -- self:subscibe_model_event("Event_Table_Start_Notify", function(eventHead, eventData)
    -- ModuleCache.ModuleManager.hide_public_module("netprompt")
    -- self.TableBaiBaZhangLogic:on_table_start_notify(eventData)
    -- self.tableBaiBaZhangView:SetAllDefaultImageActive(false);
    -- end)
    self:subscibe_model_event("Event_Get_Poker", function(eventHead, eventData)
        self:check_activity_is_open()
        local curRoundNum = eventData.curRoundNum;
        self.TableBaiBaZhangLogic:RefreshRoundInfo(curRoundNum);
        self.TableBaiBaZhangLogic:refreshSeatGameCount();
        if ModuleCache.GameManager.isEditor then
            -- local tmpData = {}
            -- table.insert(tmpData, {3,6})
            -- table.insert(tmpData, {4,6})
            -- table.insert(tmpData, {4,14})
            -- table.insert(tmpData, {2,2})
            -- table.insert(tmpData, {2,3})
            -- table.insert(tmpData, {2,10})
            -- table.insert(tmpData, {3,3})
            -- table.insert(tmpData, {3,12})
            -- table.insert(tmpData, {3,13})
            --
            -- for i = 1, #tmpData do
            -- eventData.Pokers[i].Color = tmpData[i][1]
            -- eventData.Pokers[i].Number = tmpData[i][2]
            -- end
        end
        self.tableBaiBaZhangView:SetAllDefaultImageActive(false);
        self.TableBaiBaZhangLogic:ClearAllMatchingData()
        self.TableBaiBaZhangLogic:set_oringinalServerPokers(eventData.Pokers)
        self.tableBaiBaZhangView:set_oringinalServerPokers(eventData.Pokers)
        self.TableBaiBaZhangLogic:ResetFastMatch();
        self.TableBaiBaZhangLogic:SetPokersInHand(eventData.Pokers, true, false);
        self.TableBaiBaZhangLogic:SetOthersPokers();
        self.TableBaiBaZhangLogic:ClearMatchingTable();
        self.TableBaiBaZhangLogic:ClearXiPaiHint();
        self.TableBaiBaZhangLogic:HideKickButton();
        -- self.TableBaiBaZhangLogic:SetDealBtnActive();
        self.TableBaiBaZhangLogic:ClearReadyStatus();
        self.tableBaiBaZhangView:SetResetAllActive(false);
        self.tableBaiBaZhangView:SetBtnInviteActive(false);
        self.tableBaiBaZhangView:SetRuleBtnActive(false);
    end )

    self:subscibe_model_event("Event_Table_Disconnect_Notify", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:RefreshSeatOfflineStatus(eventData.player_id, true);
    end )

    self:subscibe_model_event("Event_Table_Kick_Player_Notify", function(eventHead, eventData)
        --ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            TableManagerPoker:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package("baibazhang")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
            if self.modelData.roleData.RoomType == 2 then--亲友圈快速组局
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("由于长时间未准备，已被踢出房间！")
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已被房主踢出房间！")
            end


        else
            --ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("离开房间失败:" .. eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_Complete_Match_Rsp", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:CheckedSequence(eventData.err_no, eventData.pokers);
    end )

    self:subscibe_model_event("Event_Table_Get_Result", function(eventHead, eventData)
        local onFinishPlayStartCompareAnim = function()
            self.tableBaiBaZhangView:ShowResultTable();
            self.TableBaiBaZhangLogic:DealWithResult(eventData);
        end
        self.tableBaiBaZhangView:playStartCompareAnim(onFinishPlayStartCompareAnim)

        -- self.TableBaiBaZhangLogic:ShowReadyTable();

        self.TableBaiBaZhangLogic:ClearReadyStatus();
    end )

    self:subscibe_model_event("Event_Table_Start_Rsp", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:ReceiveStartRsp(eventData);
    end )

    self:subscibe_model_event("Event_Table_Enter_Room", function(eventHead, eventData)
        if (tostring(eventData.err_no) == "0") then
            
        else
            TableManager:disconnect_game_server()
            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package("baibazhang")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("进入房间失败")
        end

    end )

    -- 大结算广播
    self:subscibe_model_event("Event_Table_LastSettleAccounts_Notify", function(eventHead, eventData)
        self:onLastSettleAccounts_Notify(eventData)
    end )

    self:subscibe_model_event("Event_Table_Temporary_Leave_Notify", function(eventHead, eventData)
        if eventData.player_id ~= tonumber(self.modelData.roleData.userID) then
            self.TableBaiBaZhangLogic:RefreshTemporaryLeaveStatus(eventData)
        end
    end )

    self:subscibe_model_event("Event_Table_Reconnect", function(eventHead, eventData)
        -- self.TableBaiBaZhangLogic:set_oringinalServerPokers(eventData.pokers)
        if (eventData.roomInfo.roomNum ~= lastRoomNum) then
            allChatMsgs = { }
            ModuleCache.FileUtility.DirectoryDelete(voicePath, true)
            ModuleCache.FileUtility.DirectoryCreate(voicePath)
        end
        lastRoomNum = eventData.roomInfo.roomNum
        self.TableBaiBaZhangLogic:SetRoomInfo(eventData);
        self.TableBaiBaZhangLogic:InitSeatsInfo(eventData);
        self.TableBaiBaZhangLogic:SetReadyBtnType(eventData);
        local curRoundNum = eventData.roomInfo.curRoundNum;
        local totalRoundNum = eventData.roomInfo.totalRoundNum;
        self.TableBaiBaZhangLogic:RefreshRoundInfo(curRoundNum);
        self.TableBaiBaZhangLogic:RefreshTotalRoundInfo(totalRoundNum);

        self.tableBaiBaZhangView:set_oringinalServerPokers(eventData.pokers)
        self.TableBaiBaZhangLogic:Reconnect(eventData);
        
    end )

    self:subscibe_model_event("Event_Table_Reconnect_Notify", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:RefreshSeatOfflineStatus(eventData.player_id, false);
        local data = { }
        data.playerId = eventData.player_id;
        data.is_temporary_leave = false;
        -- self.TableBaiBaZhangLogic:RefreshTemporaryLeaveStatus(data)
    end )

    self:subscibe_model_event("Event_Table_Ready_Notify", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:RefreshReadyStatus(eventData);
    end )

    self:subscibe_model_event("Event_Table_Ready_Rsp", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:GetReadyRsp(eventData);
    end )

    self:subscibe_model_event("Event_Table_EnterRoom_Notify", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:RefreshEnterRoomStatus(eventData);
    end )

    self:subscibe_model_event("Event_Table_Comfirm", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:RefreshConfirmStatus(eventData);
    end )

    self:subscibe_model_event("Event_Table_Leave_Room_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then
            TableManagerPoker:disconnect_game_server()


            ModuleCache.net.NetClientManager.disconnect_all_client()
            ModuleCache.ModuleManager.destroy_package("baibazhang")
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("离开房间失败:" .. eventData.err_no)
        end
    end )

    self:subscibe_model_event("Event_Table_Leave_Room_Notify", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        self.TableBaiBaZhangLogic:LeaveRoom(eventData);

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表(比鸡专用)
        local playerInfoList = TableManagerPoker:getPlayerInfoListByBiJi(seatInfoList);
        -- 是否显示定位图标
        TableManagerPoker:isShowLocation(playerInfoList, self.view.buttonLocation);
    end )
    -- 解散房间相关
    self:subscibe_model_event("Event_Table_Dissolve_Room_Rsp", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        if (eventData.err_no and eventData.err_no == "0") then

        else

        end
    end )
    
    self:subscibe_model_event("Event_Table_Red_Packet_Notify", function(eventHead, eventData)
        local isRewarded = (self.modelData.roleData.userID == eventData.UserID )
        local param = {
                position = self.TableBaiBaZhangLogic:GetSeatPositionByID(eventData.UserID),
                awardMsg = eventData.Message,
                isMe = isRewarded,
                canRob=eventData.canRob,
                sign=eventData.sign,
            }
        ModuleCache.ModuleManager.show_module("public", "redpacket", param)
    end)
    self:subscibe_model_event("Event_Table_Dissolve_RoomRequest_Notify", function(eventHead, eventData)
        local freeRoomData, isFree, disAgreeSeatInfo = self:genFreeRoomData(eventData)
        self.freeRoomData = freeRoomData
        self.freeRoomData.dataType = "baibazhang"
        if (disAgreeSeatInfo) then
            ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
        else
            local isInHall = ModuleCache.ModuleManager.module_is_active("henanmj", "hall");
            if (isInHall) then
                return;
            end
            ModuleCache.ModuleManager.show_module("henanmj", "dissolveroom", self.freeRoomData)
        end

    end )
    self:subscibe_model_event("Event_Table_Dissolve_Room_Notify", function(eventHead, eventData)
        TableManagerPoker:disconnect_game_server()
        ModuleCache.net.NetClientManager.disconnect_all_client()
        ModuleCache.ModuleManager.destroy_package("baibazhang")
        ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
        ModuleCache.ModuleManager.destroy_module("henanmj", "roomsetting")
        local isShowChatUI = ModuleCache.ModuleManager.module_is_active("henanmj", "tablechat")
        if (isShowChatUI) then
            ModuleCache.ModuleManager.destroy_module("henanmj", "tablechat")
        end
        local isShowPlayerInfo = ModuleCache.ModuleManager.module_is_active("henanmj", "playerinfo")
        if (isShowPlayerInfo) then
            ModuleCache.ModuleManager.destroy_module("henanmj", "playerinfo")
        end
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
    end )
    -- 聊天相关
    self:subscibe_model_event("Event_Table_Chat_Notify", function(eventHead, eventData)
        local playerId = eventData.player_id
        local seatInfo = self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(playerId, self.modelData.curTableData.roomInfo.seatInfoList)
        if (seatInfo) then
            local chatMsg = eventData.chatMsg
            local chatData = { }
            chatData.userId = playerId
            chatData.chatType = chatMsg.msgType
            chatData.content = ''
            chatData.SeatID = seatInfo.seatIndex

            if (chatMsg.msgType == ChatMsgType.text) then
                self.view:show_chat_bubble(seatInfo, chatMsg.text)
                chatData.content = chatMsg.text
                table.insert(allChatMsgs, chatData)
            elseif (chatMsg.msgType == ChatMsgType.shotMsg) then
                local textIndex = chatMsg.text
                local text = self:getShotTextByShotTextIndex(textIndex)
                self.view:show_chat_bubble(seatInfo, text)
                self:play_shot_vocie(textIndex, seatInfo)
                chatData.content = text
                table.insert(allChatMsgs, chatData)
            elseif (chatMsg.msgType == ChatMsgType.emojiMsg) then
                local emojiId = tonumber(chatMsg.text)
                self.view:show_chat_emoji(seatInfo, emojiId)
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

    self:subscibe_model_event("Event_Table_CustomInfoChangeBroadcast", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
          -- 延迟处理
        self:subscibe_time_event(2, false, 0):OnComplete( function(t)
               self.TableBaiBaZhangLogic:on_table_CustomInfoChangeBroadcast(eventData)
        end )    
    end )


    -- 房主易位 通知
    self:subscibe_model_event("Event_Table_OwnerChangeBroadcast", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        -- 会收到其他玩家的中途进入包，其他玩家在没准备的情况下中途进入也会影响自己的按钮
        local my_seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[self.modelData.roleData.myRoomSeatInfo.SeatID];
        local isReady = false

        if my_seatInfo then
            isReady = my_seatInfo.isReady
        end

        self.modelData.curTableData.roomInfo.roomHostID = eventData.userid
        print("------------------房主易位 通知", eventData.userid, self.modelData.roleData.userID)
        if (tonumber(eventData.userid) == tonumber(self.modelData.roleData.userID)) then
            -- 是房主
            if eventData.playernum > 1 and not isReady then
                self.tableBaiBaZhangView:SetReadyBtn(4);
                -- 显示倒计时准备按钮
            else
                self.tableBaiBaZhangView:SetReadyBtn(0);
            end

        else
            -- 非房主
            if eventData.playernum > 1 and not isReady then
                self.tableBaiBaZhangView:SetReadyBtn(3);
                -- 显示倒计时准备按钮
            else
                self.tableBaiBaZhangView:SetReadyBtn(1);
            end

        end
    end )
    -- 亲友圈 快速组局 踢人倒计时
    self:subscibe_model_event("Event_Table_KickPlayerExpire", function(eventHead, eventData)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        print("------------------收到踢人倒计时：", eventData.expire)
        -- self.modelData.roleData.RoomType == 0 --0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
        -- if(self.modelData.roleData.RoomType == 3) then
        if self.kickedTimeId then
            CSmartTimer:Kill(self.kickedTimeId)
        end

        self.kickedTimeId = self:subscibe_time_event(eventData.expire, false, 1):OnUpdate( function(t)
            t = t.surplusTimeRound
            self.view.readyCountDown.text = "(" .. t .. ")"
        end ):OnComplete( function(t)

        end ).id

    end )


end

function TableBaiBaZhangModule:on_send_gift_chat_msg(senderPlayerId, content)
    if(string.sub(content, 1, 1) == "{")then
        local gift = ModuleCache.Json.decode(content)
        local senderSeatInfo = self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(senderPlayerId, self.modelData.curTableData.roomInfo.seatInfoList)
        local receiverSeatInfo = self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(gift.receiver, self.modelData.curTableData.roomInfo.seatInfoList)
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

function TableBaiBaZhangModule:on_module_event_bind()
    self:subscibe_module_event("onegameresult", "Event_continue_game", function(eventHead, eventData)
        --ModuleCache.ModuleManager.show_module("baibazhang","tablebaibazhang")
		self.TableBaiBaZhangLogic:onClickReadyBtn(false);
	end)

    self:subscibe_module_event("dissolveroom", "Event_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData)
    end )

    self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(true)
    end )

    self:subscibe_package_event("Event_DissolvedRoom", function(eventHead, eventData)
        self.model:request_dissolve_room(eventData == 2)
    end )

    self:subscibe_package_event("Event_RoomSetting_LeaveRoom", function(eventHead, eventData)
        self.TableBaiBaZhangLogic:ExitRoom()
    end )

    self:subscibe_package_event("Event_RoomSetting_RefreshBg", function(eventHead, eventData)
        self.view:refresh_table_bg()
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

    self:subscibe_package_event("Event_TableVoice_StartPlayVoice", function(eventHead, eventData)
        local seatInfo = self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(eventData, self.modelData.curTableData.roomInfo.seatInfoList)
        if(seatInfo)then
            self.view:show_voice(seatInfo)
        end
    end)
    self:subscibe_package_event("Event_TableVoice_StopPlayVoice", function(eventHead, eventData)
        local seatInfo = self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(eventData, self.modelData.curTableData.roomInfo.seatInfoList)
        if(seatInfo)then
            self.view:hide_voice(seatInfo)
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


function TableBaiBaZhangModule:on_click(obj, arg)
    if (self.lastClickObj == obj and self.lastClickTime + doubleClickInterval > Time.realtimeSinceStartup) then
        self:on_double_click(obj, arg)
        return
    end
    self.lastClickObj = obj
    self.lastClickTime = Time.realtimeSinceStartup
    -- print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if (self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup) then
        return
    end

    -- local startIndex, endIndex = string.find(obj.name, "Poker")
    if (obj.transform.parent.gameObject.name == "first" and obj.name == "ImageNoPokers") then
        self.TableBaiBaZhangLogic:onClickMatching(1);
    elseif (obj.transform.parent.gameObject.name == "second" and obj.name == "ImageNoPokers") then
        self.TableBaiBaZhangLogic:onClickMatching(2);
    elseif (obj.transform.parent.gameObject.name == "third" and obj.name == "ImageNoPokers") then
        self.TableBaiBaZhangLogic:onClickMatching(3);
    elseif (obj.name == "pair" or obj.name == "straight" or obj.name == "flush" or obj.name == "straightflush" or obj.name == "threeofakind") then
        self.TableBaiBaZhangLogic:onClickDealBtn(obj.name);
    elseif (obj.name == "reset") then
        -- 重置单道牌
        self.TableBaiBaZhangLogic:onClickResetBtn(obj);
    elseif (obj.name == "start") then
        self.TableBaiBaZhangLogic:onClickStartBtn(obj);
    elseif (obj.name == "Submit") then
        self.TableBaiBaZhangLogic:onClickSubmitConfirmBtn(obj);
    elseif (obj.name == "Surrender") then
        -- 头像
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_confirm_cancel("<size=30>确定投降吗？</size>\n\n<size=22>Tips:投降则每道牌都判为输，但不算通关和喜牌的减分</size>", function()
            self.TableBaiBaZhangLogic:onClickSurrenderBtn(obj);
        end , nil)
    elseif (obj.name == "ResetAll") then
        -- 重置所有
        self.TableBaiBaZhangLogic:onClickResetAllBtnNew(obj);
    elseif (obj.name == "OrderBySequence") then
        self.TableBaiBaZhangLogic:onClickOrderBtn(false);
    elseif (obj.name == "OrderByColor") then
        self.TableBaiBaZhangLogic:onClickOrderBtn(true);
    elseif (obj.name == "ready") then
        if (self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount) then
            if (self.showResultViewSmartTimer_id) then
                CSmartTimer:Kill(self.showResultViewSmartTimer_id)
                self.showResultViewSmartTimer_id = nil
            end
            local game = "摆八张";
            local dissolverId = self.dissolverId;
            ModuleCache.ModuleManager.show_module("baibazhang", "tableresult", {
                gameName = game,
                dissolverId = dissolverId,
                resultList = self.modelData.curTableData.roomInfo.roomResultList,
                roomInfo =
                {
                    roomNum = self.modelData.curTableData.roomInfo.roomNum,
                    curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum,
                    totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount,
                    startTime = self.modelData.curTableData.roomInfo.startTime,
                    endTime = self.modelData.curTableData.roomInfo.endTime
                }
            } , "baibazhang")
            return
        end
        self.TableBaiBaZhangLogic:onClickReadyBtn(false);
    elseif (obj.name == "ready2") then
        if (self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount) then
            if (self.showResultViewSmartTimer_id) then
                CSmartTimer:Kill(self.showResultViewSmartTimer_id)
                self.showResultViewSmartTimer_id = nil
            end
            local game = "摆八张";
            local dissolverId = self.dissolverId;
            ModuleCache.ModuleManager.show_module("baibazhang", "tableresult", {
                gameName = game,
                resultList = self.modelData.curTableData.roomInfo.roomResultList,
                dissolverId = dissolverId,
                roomInfo =
                {
                    roomNum = self.modelData.curTableData.roomInfo.roomNum,
                    curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum,
                    totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount,
                    startTime = self.modelData.curTableData.roomInfo.startTime,
                    endTime = self.modelData.curTableData.roomInfo.endTime
                }
            } , "biji")
            return
        end
        self.TableBaiBaZhangLogic:onClickReadyBtn(false);
    elseif(obj.name == "ButtonKick") then
        local index = obj.transform.parent.parent.parent.gameObject.name;
        self.TableBaiBaZhangLogic:onClickKickBtn(index)
    elseif (obj.name == "cancel") then
        self.TableBaiBaZhangLogic:onClickCancelBtn(obj);
    elseif (obj.name == "confirmNotReady") then
        self.TableBaiBaZhangLogic:onClickConfirmNotReadyBtn(obj);
    elseif (obj.name == "confirmSurrender") then
        self.TableBaiBaZhangLogic:onClickSurrenderBtn(obj);
    elseif (obj.name == "cancelSurrender") then
        self.TableBaiBaZhangLogic:onClicCancelSurrenderBtn(obj);
    elseif (obj.name == "Invite") then
        self.lastClickInviteTime = Time.realtimeSinceStartup
        self:inviteWeChatFriend()
    elseif (obj.name == "ButtonChat") then
        ModuleCache.ModuleManager.show_module("henanmj", "tablechat", { is_New_Sever = true, allChatMsgs = allChatMsgs, curTableData = self.chatCurTableData, config = self.chatConfig, backgroundStyle = "BackgroundStyle_2" })
    elseif (obj.name == "ButtonMic") then

    elseif (obj.name == "ButtonConfirm") then
        self.TableBaiBaZhangLogic:OnClickSpecialTypeConfirm();
    elseif (obj.name == "ButtonCancel") then
        self.TableBaiBaZhangLogic:OnClickSpecialTypeCancel();
    elseif (obj.name == "exit") then
        self.TableBaiBaZhangLogic:ExitRoom()
    elseif (obj.name == "exit2") then
        self.model:request_dissolve_room(true)
    elseif (obj.name == "NotSitDown") then
        self.lastClickInviteTime = Time.realtimeSinceStartup
        self:inviteWeChatFriend()
    elseif (obj.name == "Image") then
        local seatInfo = self:getSeatInfoByHeadImageObj(obj)
        if (not seatInfo or(not seatInfo.playerInfo)) then
            print("=====seatInfo is not exist")
            return
        end
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", seatInfo.playerInfo)
    elseif (obj.name == "Suggestion1") then
        self.TableBaiBaZhangLogic:onClickSuggestionBtn(1);
    elseif (obj.name == "Suggestion2") then
        self.TableBaiBaZhangLogic:onClickSuggestionBtn(2);
    elseif (obj.name == "Suggestion3") then
        self.TableBaiBaZhangLogic:onClickSuggestionBtn(3);
    elseif (obj.name == "ButtonRule" or obj.name == "RuleHint") then
        local rule = { };
        rule.name = "baibazhang"
        rule.ruleInfo = ModuleCache.Json.decode(self.modelData.curTableData.roomInfo.rule);

        ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
    elseif (obj.name == "ButtonDetail") then
        local roomInfo = { };
        roomInfo.creatorId = self.modelData.curTableData.roomInfo.roomHostID
        roomInfo.id = self.modelData.curTableData.roomInfo.roomId
        roomInfo.curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum;
        roomInfo.totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount;
        ModuleCache.ModuleManager.show_module("baibazhang", "innerroomdetail", roomInfo)
    elseif (obj == self.view.buttonLocation.gameObject) then
        -- 位置按钮
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
        -- 获取玩家信息列表(比鸡专用)
        local playerInfoList = TableManagerPoker:getPlayerInfoListByBiJi(seatInfoList);
        -- 获取位置信息文本
        local tipText, distanceText = TableManagerPoker:get_gps_warn_text(playerInfoList);
        ModuleCache.ModuleManager.show_module("henanmj", "tablegps2", tipText .. "," .. distanceText)
    elseif (obj == self.view.buttonSetting.gameObject) then
        -- 这里应该怎么判断
        local canLeaveRoom =((self.modelData.curTableData.roomInfo.mySeatInfo.gameCount == 0 or self.modelData.curTableData.roomInfo.curRoundNum == 0) and(not self.modelData.curTableData.roomInfo.mySeatInfo.isCreator))
        local intentData = { }
        intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_" .. "BIJI"
        intentData.canExitRoom = false;
        intentData.canDissolveRoom = not canLeaveRoom
        if (self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount) then
            local isComparing = self.TableBaiBaZhangLogic.isComparing;
            if (isComparing) then
                intentData.canDissolveRoom = false;
            end
        end
        intentData.tableBackgroundSprite = self.view.tableBackgroundImage.sprite
        --intentData.tableBackgroundSprite2 = self.view.tableBackgroundImage2.sprite
        ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", intentData)
        -- 根据房间是否开始的状态传值
    elseif(obj.name == 'ButtonActivity')then
        self:on_click_activity_btn(obj, arg)
    end
end

------通过头像获取座位信息
function TableBaiBaZhangModule:getSeatInfoByHeadImageObj(obj)
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
        if (seatHolder.imagePlayerHead.gameObject == obj) then
            return seatInfo
        end
    end
    return nil
end


-- function ShareManager:shareBiJiRoomNum(roomNum, ruleDesc, timeLine)
--     self:getShareConfig(2, tostring(roomNum), ruleDesc, function(data)
--         local title = data.title
--         local url = data.url
--         local content = data.message
--         if(timeLine)then
--             WechatManager.share_url(1, title, content, url)
--         else
--             WechatManager.share_url(0, title, content, url)
--         end
--     end)
-- end

function TableBaiBaZhangModule:on_click_activity_btn(obj, arg)
     local object = 
        {
        showRegionType = "table",
        showType="Manual",
        }
	ModuleCache.ModuleManager.show_public_module("activity", object)
end

function TableBaiBaZhangModule:on_click_location_btn(obj, arg)
    if (not self.modelData.curTableData) then
        return
    end
    if (not self.playerCustomInfoMap) then
        self.playerCustomInfoMap = { }
    end
    local roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = roomInfo.seatInfoList
    local mySeatInfo = roomInfo.mySeatInfo
    local list = { }
    local getingStr = '正在获取..'
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if (seatInfo.playerId and seatInfo.playerId ~= 0) then
            if (seatInfo ~= mySeatInfo) then
                local data = self.playerCustomInfoMap[seatInfo.playerId]
                if (data) then
                    local tmpData = { }
                    tmpData.playerShowName = getingStr
                    tmpData.ip = data.ip
                    tmpData.locationData = data
                    print_table(seatInfo.playerInfo)
                    if (seatInfo.playerInfo) then
                        seatInfo.playerInfo.locationData = data
                        seatInfo.playerInfo.ip = data.ip
                        tmpData.playerShowName = Util.filterPlayerName(seatInfo.playerInfo.playerName) or getingStr
                    end
                    table.insert(list, tmpData)
                else

                end
            end
        end
    end
    -- for i=1,3 do
    -- 	local tmpData = {}
    -- 	tmpData.playerShowName = 'this is ' .. i
    -- 	tmpData.ip = '1.1.1.1'
    -- 	tmpData.locationData = {
    -- 		address = 'this is address',
    -- 		longitude = 100,
    -- 		latitude = 100,
    -- 	}
    -- 	table.insert( list, tmpData)
    -- end
    ModuleCache.ModuleManager.show_module("henanmj", "tablegps", { seatInfoList = list })
end

function TableBaiBaZhangModule:inviteWeChatFriend()
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return
    end

    local shareData = { }
    shareData.type = 2
    shareData.title = "摆八张"
    if(self.modelData.roleData.HallID > 0) then
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


    shareData.roomId = self.modelData.curTableData.roomInfo.roomNum .. ""
    shareData.ruleName = string.sub(self.modelData.curTableData.roomInfo.ruleDesc, 1, -2);
    shareData.userID = self.modelData.roleData.userID
    shareData.totalPlayer = self.modelData.curTableData.roomInfo.ruleTable.playerCount;
    shareData.totalGames = self.modelData.curTableData.roomInfo.ruleTable.roundCount;
    shareData.comeIn = self.modelData.curTableData.roomInfo.ruleTable.allowHalfEnter;
    shareData.curPlayer = self.TableBaiBaZhangLogic:GetCurPlayerCount();
    ModuleCache.ShareManager().shareRoomNum(shareData, false)
    -- ModuleCache.ShareManager:shareBiJiRoomNum(self.modelData.curTableData.roomInfo.roomNum, self.modelData.curTableData.roomInfo.ruleDesc, false)
end

function TableBaiBaZhangModule.on_double_click(obj, arg)
end


function TableBaiBaZhangModule:on_press_up(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressUpMic', data)
    else
        self.TableBaiBaZhangLogic:on_press_up(obj, arg);
        self.TableBaiBaZhangLogic:onClickPokersOnMatch(obj);
    end
end

function TableBaiBaZhangModule:on_drag(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnDragMic', data)
    else
        self.TableBaiBaZhangLogic:on_drag(obj, arg);
    end
end

function TableBaiBaZhangModule:on_press(obj, arg)
    if (obj.name == "ButtonMic") then
        local data = {
            obj = obj,
            arg = arg,
        }
        self:dispatch_package_event('Event_TableVoice_OnPressMic', data)
    else
        self.TableBaiBaZhangLogic:on_press(obj, arg);
    end

end

function TableBaiBaZhangModule:onLastSettleAccounts_Notify(data)
    TableManagerPoker:disconnect_game_server()
    local isShowDisUI = ModuleCache.ModuleManager.module_is_active("henanmj", "dissolveroom")
    if (isShowDisUI) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
    end
    local isShowSetUI = ModuleCache.ModuleManager.module_is_active("henanmj", "roomsetting")
    if (isShowSetUI) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "roomsetting")
    end
    local isShowChatUI = ModuleCache.ModuleManager.module_is_active("henanmj", "tablechat")
    if (isShowChatUI) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "tablechat")
    end
    local isShowPlayerInfo = ModuleCache.ModuleManager.module_is_active("henanmj", "playerinfo")
    if (isShowPlayerInfo) then
        ModuleCache.ModuleManager.destroy_module("henanmj", "playerinfo")
    end
    local resultList = { }
    local sTime = ""
    local eTime = ""
    for i = 1, #data.LastSettleAccounts do
        local seatInfo = self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(data.LastSettleAccounts[i].userId, self.modelData.curTableData.roomInfo.seatInfoList)
        local result = { }
        result.totalScore = data.LastSettleAccounts[i].totalScore
        result.xipaiCount = data.LastSettleAccounts[i].xipaiCount
        result.paiWinCount = data.LastSettleAccounts[i].paiWinCount
        result.tongguanCount = data.LastSettleAccounts[i].tongguanCount
        result.playerId = data.LastSettleAccounts[i].userId
        result.isRoomCreator = seatInfo.isCreator
        result.playerInfo = seatInfo.playerInfo
        if (seatInfo.isCreator) then
            print("is creator ------------------------------")
            sTime = data.LastSettleAccounts[i].startTime
            eTime = data.LastSettleAccounts[i].endTime
        end
        table.insert(resultList, result)
    end
    self.modelData.curTableData.roomInfo.isRoomEnd = true
    self.modelData.curTableData.roomInfo.roomResultList = resultList
    self.modelData.curTableData.roomInfo.startTime = sTime
    self.modelData.curTableData.roomInfo.endTime = eTime
    local delayTime = 8
    if (self.modelData.curTableData.roomInfo.curRoundNum == self.modelData.curTableData.roomInfo.totalRoundCount) then
        delayTime = 8
    else
        delayTime = 1
    end
    self.showResultViewSmartTimer_id = nil
    local timeEvent = nil
    print("sTime = " .. sTime)
    print("eTime = " .. eTime)
    timeEvent = self:subscibe_time_event(delayTime, false, 0):OnComplete( function(t)
        local game = "摆八张";
        local dissolverId = data.free_sponsor;
        self.dissolverId = data.free_sponsor;
        ModuleCache.ModuleManager.show_module("baibazhang", "tableresult", { gameName = game,dissolverId = dissolverId, resultList = resultList, roomInfo = { roomNum = self.modelData.curTableData.roomInfo.roomNum, curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum, totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount, startTime = sTime, endTime = eTime } }, "biji")
        ModuleCache.ModuleManager.destroy_module("baibazhang", "ongameresult")
        self.showResultViewSmartTimer_id = nil
    end ):OnKill( function(t)

    end )
    self.showResultViewSmartTimer_id = timeEvent.id
end

function TableBaiBaZhangModule:genFreeRoomData(data)
    local freeRoomData = { }
    local freeRoomStateList = data.freeRoomStateList
    local isAllAgree = true
    local isAllAnswered = true
    local disAgreeSeatInfo = nil
    freeRoomData.expire = data.expire
    for i, v in ipairs(self.modelData.curTableData.roomInfo.seatInfoList) do
        if (v.playerId and v.playerId ~= '0' and v.playerId ~= 0) then
            local freeRoomSeatData = { }
            freeRoomSeatData.seatInfo = v
            freeRoomSeatData.isSponsor = false
            freeRoomSeatData.isAnswered = false
            freeRoomSeatData.agree = false
            table.insert(freeRoomData, freeRoomSeatData)
            print(v.playerId, self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
            if (v.playerId == self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
                freeRoomData.mySeatFreeRoomData = freeRoomSeatData
            end
            for j, value in ipairs(freeRoomStateList) do
                if (freeRoomSeatData.seatInfo == self.tableBaiBaZhangHelper:getSeatInfoByPlayerId(value.player_id, self.modelData.curTableData.roomInfo.seatInfoList)) then
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


function TableBaiBaZhangModule:PauseMusic()
    SoundManager.audioMusic.mute = true
end

function TableBaiBaZhangModule:UnPauseMusic()
    SoundManager.audioMusic.mute = false
end

function TableBaiBaZhangModule:getShotTextByShotTextIndex(key)
    local config = self.chatConfig
    return config.chatShotTextList[key]
end

function TableBaiBaZhangModule:play_shot_vocie(key, seatInfo)
    local voiceName = ""
    -- 男性播女声
    if (seatInfo.playerInfo and seatInfo.playerInfo.gender == 2) then
        voiceName = "chat_female_" .. key
    else
        voiceName = "chat_male_" .. key
    end
    ModuleCache.SoundManager.play_sound("publictable", "publictable/sound/tablepoker/" .. voiceName .. ".bytes", voiceName)
end

function TableBaiBaZhangModule:play_voice(path)
    local array = string.split(path, "/")
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/" .. path .. ".bytes", array[#array])
end

function TableBaiBaZhangModule:addSeatInfo2ChatCurTableData(seatInfo)
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

function TableBaiBaZhangModule:addSeatInfo2ChatCurTableData(seatInfo)
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

function TableBaiBaZhangModule:removeSeatInfoFromChatCurTableData(playerId)
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
function TableBaiBaZhangModule:UploadIpAndAddress()
    print("UploadIpAndAddress")
    local newTable = { }
    newTable.address = ModuleCache.GPSManager.gpsAddress
    newTable.gpsInfo = ModuleCache.GPSManager.gps_info
    self.tableBaiBaZhangModel:request_CustomInfoChange(ModuleCache.Json.encode(newTable))
end

-- 获取活动左侧列表协议
function TableBaiBaZhangModule:check_activity_is_open()
    local object =
    {
        buttonActivity=self.view.buttonActivity,
        spriteRedPoint = self.view.spriteActivityRedPoint
    }
    ModuleCache.ModuleManager.show_public_module("activity", object);
end

return TableBaiBaZhangModule;