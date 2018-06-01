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
---@class TableBaseModule:ModuleBase
---@field model TableBaseModel
---@field tableBaseModel TableBaseModel
---@field view TableBaseView
---@field tableBaseView TableBaseView
local TableBaseModule = class('tableBaseModule', ModuleBase)
local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameSDKInterface = ModuleCache.GameSDKInterface
local WechatManager = ModuleCache.WechatManager
local Time = UnityEngine.Time
local voicePath = Application.persistentDataPath .. "/voice"
local TableManager = TableManager
local delayRefreshTime = 0.2
local audioMusic = ModuleCache.SoundManager.audioMusic
local string = string
local MatchingManager = require("package.public.matching_manager")

function TableBaseModule:initialize(...)
	ModuleBase.initialize(self, ...)
	self.curTableData = TableManager.curTableData
	self.netClient = self.modelData.bullfightClient
	self.table_gift_module = ModuleCache.ModuleManager.show_module('public','table_gift')
	self.table_voice_module = ModuleCache.ModuleManager.show_module('public','table_voice')
	self.resultWait = true
	self.view:refresh_voice_shake()
	self:begin_location(function(data)
		data.chatType = 4
		self.model:request_chat(data)
	end)
end

function TableBaseModule:on_module_inited(...)
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

	self:subscibe_model_event("Event_Msg_Table_GameStateNTF", function(eventHead, eventData)
		if(not self.gameState) then
			self:dispatch_package_event("Event_Package_Table_LoginAndExit", false)
		end
		self.autoPlayStates = self.autoPlayStates or {}
		self.totalDelayTime = self.totalDelayTime or 0
		table.insert(self.autoPlayStates, eventData)
		local preDelayTime = self.view:pre_delay_state_time(eventData)
		if(preDelayTime < 0) then  ---去掉延迟，用pre_delay_state_time返回值小于零，来判断是否自动出牌
			self.autoOutMJ = true
			preDelayTime = 0
		end
		self.totalDelayTime = self.totalDelayTime + preDelayTime
		print("延迟刷新", self.totalDelayTime)
		local smartTimer = self:subscibe_time_event(self.totalDelayTime, false, 0):OnComplete(function(t)
			local newGameState = self.autoPlayStates[1]
			self.gameState = newGameState
			if(not self.resultWait and self.gameState.Result == 0) then
				self.resultWait = true
				self.view:reset_mj(true)
			end
			self.seqNoAssignmentBegin = true
            self.model.SeqNo = newGameState.SeqNo
            self.seqNoAssignmentBegin = false
			self:refresh_game_state(newGameState)
			self.view:refresh_game_state(newGameState)
			if(newGameState.Result ~= 0) then
				self:show_game_result(newGameState)
			end
			table.remove(self.autoPlayStates, 1)
			if(#self.autoPlayStates == 0) then
				self.totalDelayTime = 0
				self.autoOutMJ = false
			end
		end)
		if(self.totalDelayTime ~= 0 or eventData.Result ~= 0) then
			smartTimer:Start()
		end
		if(eventData.DelayMo  and eventData.DelayMo ~= 0) then
			self.totalDelayTime = self.totalDelayTime + eventData.DelayMo / 1000
		end
		self:clear_share_room_info_text()
	end)

	self:subscibe_model_event("Event_Msg_RoomUserInfoNTF", function(eventHead, eventData)
		self:refresh_seat_info(eventData)
		self.view:refresh_seat_info(eventData)
	end)

	self:subscibe_model_event("Event_Msg_Table_UserStateNTF", function(eventHead, eventData)
		self:refresh_user_state(eventData)
		self.view:refresh_user_state(eventData)
	end)

	self:subscibe_model_event("Event_Msg_RoomUserOnlineNTF", function(eventHead, eventData)
		self.view:refresh_user_online(eventData)
	end)

	self:subscibe_model_event("Event_Msg_RoomUserOfflineNTF", function(eventHead, eventData)
		self.view:refresh_user_offline(eventData)
	end)

	self:subscibe_model_event("Event_Msg_KickedNTF", function(eventHead, eventData)
		self:exit_room("您已被房主踢出房间")	
	end)

	self:subscibe_model_event("Event_Msg_SameUserLoginNTF", function(eventHead, eventData)
		-- ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("您已经断开连接，请重新登陆", function()
		-- 	ModuleCache.GameManager.logout(true);    
		-- end) 
	end)

	self:subscibe_model_event("Event_Msg_DismissNTF", function(eventHead, eventData)
		if(#eventData.Action == 0) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("牌局中无法退出游戏")
			ModuleCache.ModuleManager.hide_module("henanmj", "dissolveroom")
		else
			-- eventData.dataType = "henanmj"
			-- 这是个坑啊，不能这样添加
			ModuleCache.ModuleManager.show_module("henanmj", "dissolveroom", eventData)
		end
	end)

	self:subscibe_model_event("Event_Msg_RoomDismissedNTF", function(eventHead, eventData)
		self:exit_room("已解散房间")	
	end)

	self:subscibe_model_event("Event_Msg_ReportStateNTF", function(eventHead, eventData)
		self.view:refresh_report_state(eventData)
	end)
	

	self:subscibe_model_event("Event_Msg_MessageNTF", function(eventHead, eventData)--收到聊天消息
		if(eventData.SeatID >3 or eventData.SeatID < 0) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.Message)
			return
		end

		if string.sub(eventData.Message,1,1) ~= "{" then
			return
		end

		local chatData = ModuleCache.Json.decode(eventData.Message)
		if not chatData then
			return 
		end
		-- for k,v tin pairs(chatData) do
		-- 	print("###########eventData.Message:",k,v)
		-- end

		if(not chatData.chatType ) then
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
					chatData.chatType =2
				end
			end
			
		end

		if(chatData.chatType == 1) then
			local textIndex = tonumber(chatData.content)
			local text = self.view:get_chat_short_text(textIndex)
			self.view:show_chat_bubble(eventData.SeatID, text)--短句
			if(self.view.openVoice) then
				self.view:show_shot_voice(textIndex, eventData.SeatID)
			end
		elseif(chatData.chatType == 2) then--表情
			local emoticonIdx =tonumber( chatData.content or chatData.emoticon)
			if emoticonIdx >100 then
				emoticonIdx =emoticonIdx/100
			end
			 
			self.view:show_chat_face(eventData.SeatID, emoticonIdx)
		elseif(chatData.chatType == 3) then--文字
			chatData.SeatID = eventData.SeatID
			table.insert(TableManager.chatMsgs, chatData)
			self:dispatch_package_event("Event_Refresh_ChatMsg")
			self.view:show_chat_bubble(eventData.SeatID, chatData.content or chatData.words)
		elseif(chatData.chatType == 0) then--语音
			chatData.SeatID = eventData.SeatID
			table.insert(TableManager.chatMsgs, chatData)--TODO:XLQ语音聊天消息加入聊天记录

			local data = {
				playerId = eventData.SeatID,
				fileid = chatData.content,
			}
			self:dispatch_package_event("Event_TableVoice_VoiceComing", data)
		elseif(chatData.chatType == 10)then
			self:on_send_gift_chat_msg(eventData.SeatID, chatData.content)
		elseif(chatData.chatType == 4) then--定位
			self.view:update_seat_location(eventData.SeatID, chatData)
		end
	end)

	self:subscibe_model_event("Event_Private_MessageNTF", function(eventHead, eventData)
		self.view:refresh_private_message(eventData)
	end)

	-- 离开房间
	self:subscibe_module_event("roomsetting", "Event_RoomSetting_ExitRoom", function(eventHead, eventData)
		self.model:request_exit_room()
	end)

	self:subscibe_package_event("Event_Send_ChatMsg", function(eventHead, eventData)
		self.model:request_chat(eventData)
	end)

	self:subscibe_module_event("tablechat", "Event_Client_ChatMsg", function(eventHead, eventData)
		local textIndex = tonumber(eventData.content)
		if(self.view.openVoice) then
			self.view:show_shot_voice(textIndex, TableManager.curTableData.SeatID)
		end
	end)

	self:subscibe_package_event("Event_DissolvedRoom", function(eventHead, eventData)
		self.model:request_dissolve_room(eventData)
	end)

	self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
		self.model:request_dissolve_room(eventData)
	end)

	self:subscibe_package_event("Event_Refresh_Voice_Shake", function(eventHead, eventData)
		self.view:refresh_voice_shake()
		TableManager:refresh_voice_shake()
	end)

	self:subscibe_package_event("Event_RoomSetting_RefreshBg", function(eventHead, eventData)
		self.view:refresh_table_bg()
	end)

	self:subscibe_module_event("playback", "Event_PlayBackFrame", function(eventHead, eventData)
		if(eventData) then
			self.gameState = eventData
			if(not self.resultWait and self.gameState.Result == 0) then
				self.resultWait = true
			end
			self:refresh_game_state(eventData)
			self.view:refresh_game_state(eventData)
			self:show_game_result(eventData)
		end
	end)

	self:subscibe_module_event("playback", "Event_Msg_Table_UserStateNTF", function(eventHead, eventData)
		self:refresh_user_state(eventData)
		self.view:refresh_user_state(eventData)
	end)

	self:subscibe_model_event("Event_Msg_RoomAwardMessageNTF", function(eventHead, eventData)
		local roomAwardTable = self.view:get_room_award_table(eventData)
		if(roomAwardTable) then
			ModuleCache.ModuleManager.show_public_module("redpacket", roomAwardTable)
		end
	end)

	self:subscibe_package_event("Event_Close_TableShop", function(eventHead, eventData)
		self.model:request_add_gold_done()
	end)

	self:subscibe_package_event("Event_TableVoice_StartPlayVoice", function(eventHead, eventData)
		if eventData ~=nil then
			self.view:show_voice(eventData)
		end
	end)
	self:subscibe_package_event("Event_TableVoice_StopPlayVoice", function(eventHead, eventData)
		if eventData ~=nil then
			self.view:hide_voice(eventData)
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
		for i, v in pairs(TableManager.curTableData.seatUserIdInfo) do
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
end

function TableBaseModule:on_send_gift_chat_msg(seatId, content)
	if(string.sub(content, 1, 1) == "{")then
		local gift = ModuleCache.Json.decode(content)
		local senderLocalSeatIndex = TableUtil.get_local_seat(seatId, self.view.mySeat, TableManager.curTableData.totalSeat, TableManager.seatNumTable)
		local receiverLocalSeatIndex = TableUtil.get_local_seat(gift.receiver, self.view.mySeat, TableManager.curTableData.totalSeat, TableManager.seatNumTable)
		local sendSeatHolder = self.view.seatHolderArray[senderLocalSeatIndex]
		local receiverSeatHolder = self.view.seatHolderArray[receiverLocalSeatIndex]
		local data = {
			giftName = gift.giftName,
			fromPos = sendSeatHolder.imagePlayerHead.transform.position,
			toPos = receiverSeatHolder.imagePlayerHead.transform.position,
		}
		self:dispatch_package_event('Event_Table_Play_SendGift', data)
	end
end

-- 离开房间
function TableBaseModule:exit_room(tip)
	TableManager:disconnect_login_server()
    TableManager:disconnect_game_server()
	ModuleCache.net.NetClientManager.disconnect_all_client()
	ModuleCache.ModuleManager.hide_public_module("netprompt")

	--TODO XLQ 金币场换桌
	local SeatID = UnityEngine.PlayerPrefs.GetInt("ChangeTable", -1)  ---获取金币场继续标记
	ModuleCache.UnityEngine.PlayerPrefs.SetInt("ChangeTable",-1) ---重置金币场继续标记
	---少年，你想知道为啥要判断这个self.gameState为空吗，因为重装软件会有概率出现PlayerPrefs 中 ChangeTable 没清理的BUG，然后你懂的
	if SeatID ~= -1 and self.gameState then
		---进入金币场
		local goldid = self.modelData.tableCommonData.goldFildId
		local myPlayer = self.gameState.Player[SeatID + 1]
		MatchingManager:getGoldById(goldid,function (info)
			print("继续金币场 ： "..tostring(goldid).." blance : "..tostring(myPlayer.Balance))
			MatchingManager:gold_continue(goldid,myPlayer.Balance,info.minJoinCoin,info.maxJoinCoin,function ()
				ModuleCache.ModuleManager.destroy_package("henanmj")
				ModuleCache.ModuleManager.destroy_package("majiang")
				ModuleCache.ModuleManager.destroy_package("majiang3d")
			end)
		end)
	else
		ModuleCache.ModuleManager.destroy_package("henanmj")
		ModuleCache.ModuleManager.destroy_package("majiang")
		ModuleCache.ModuleManager.destroy_package("majiang3d")
		ModuleCache.ModuleManager.show_module("henanmj", "hall")
	end

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
	if(obj == self.view.buttonMic.gameObject) then
		local data = {
			obj = obj,
			arg = arg,
		}
		self:dispatch_package_event('Event_TableVoice_OnDragMic', data)
	end
end

function TableBaseModule:press_voice(obj, arg)
	if(obj == self.view.buttonMic.gameObject) then
		local data = {
			obj = obj,
			arg = arg,
		}
		self:dispatch_package_event('Event_TableVoice_OnPressMic', data)
	end
end

function TableBaseModule:on_show()
	--self.lastUpdateBeatTime = 0
	self.lastPingTime = Time.realtimeSinceStartup
	self.model.lastReceiveHeartPackTime = Time.realtimeSinceStartup
	self.gameClient = self.modelData.gameClient
	--self:UpdateBeat()

	-- local bgMusic = "bgmfight2"
	-- ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic .. ".bytes", bgMusic, true)


	--UpdateBeat:Add(self.UpdateBeat, self)
end

--function TableBaseModule:on_hide()
--	UpdateBeat:Remove(self.UpdateBeat, self)
--end

function TableBaseModule:on_destroy()
	--UpdateBeat:Remove(self.UpdateBeat, self)
	GVoiceManager.clear_event_listener()
	if (self.table_voice_module) then
		ModuleCache.ModuleManager.destroy_module('public','table_voice')
	end
	if(self.table_gift_module)then
		ModuleCache.ModuleManager.destroy_module('public','table_gift')
	end
end

function TableBaseModule:reconnect()
	
end

function TableBaseModule:on_update_per_second()
	--if self.lastUpdateBeatTime + 1 > Time.realtimeSinceStartup then
	--	return
	--end

	if self.seqNoAssignmentBegin then
		self.seqNoAssignmentBegin = false
		TableManager:heartbeat_timeout_reconnect_game_server()
		return
	end

	if(self.model.lastPingReqeustTime)then
		self.view:show_ping_delay(true, UnityEngine.Time.realtimeSinceStartup - self.model.lastPingReqeustTime)
	elseif(self.model.pingDelayTime)then
		self.view:show_ping_delay(true, self.model.pingDelayTime)
	else
		self.view:show_ping_delay(true, 0.05)
	end
	

    if(not audioMusic.isPlaying) then
		local bgMusic1 = "bgmfight1"
		local bgMusic2 = "bgmfight2"		
		if((not audioMusic.clip) or audioMusic.clip.name ~= bgMusic2)then
			ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic2 .. ".bytes", bgMusic2)
		else
			ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic1 .. ".bytes", bgMusic1)
		end
	end

	self.view:refresh_battery_time_info()
	--self.lastUpdateBeatTime = Time.realtimeSinceStartup

	if(TableManager.curTableData.isPlayBack) then
		return
	end

	if self.gameClient.clientConnected and (self.gameClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
		TableManager:heartbeat_timeout_reconnect_game_server()
	end

	if self.gameClient.clientConnected and (self.lastPingTime + 3 < Time.realtimeSinceStartup) then
		self.lastPingTime = Time.realtimeSinceStartup	
		if TableManager.clientConnected then
			self.tableModel:request_heartbeat()
		end
	end
end

function TableBaseModule:PauseMusic()
	SoundManager.audioMusic.mute = true
end

function TableBaseModule:UnPauseMusic()
	SoundManager.audioMusic.mute = false
end

--- 刷新单个玩家状态
function TableBaseModule:refresh_seat_info(data)
	self.curTableData.seatUserIdInfo = self.curTableData.seatUserIdInfo or {}
	self.curTableData.seatUserIdInfo[data.SeatID .. ""] = data.UserID
	self:update_user_state()
	-- 代表有玩家离开
	if data.UserID == "0" then
		self:get_share_data_copy_to_clipboard()
	end
end

function TableBaseModule:update_user_state()
	self.curPlayer = 0
	if(not self.curTableData.seatUserIdInfo) then
		return
	end
	for key, value in pairs(self.curTableData.seatUserIdInfo) do
		if(value and value ~= "0") then
			self.curPlayer = self.curPlayer + 1
		end
	end
end

--- 刷新所有玩家状态，但是单个玩家离开后不会即时
function TableBaseModule:refresh_user_state(data)
	self.curTableData.seatUserIdInfo = {}
	for i=1,#data.State do
		self.curTableData.seatUserIdInfo[data.State[i].SeatID .. ""] = data.State[i].UserID
	end
	self:update_user_state()
	self:get_share_data_copy_to_clipboard()
end

function TableBaseModule:get_share_data_copy_to_clipboard()
	if(not self.gameState and not self.curTableData.isPlayBack and( not TableManager:cur_game_is_gold_room_type())) then
		if(self.curTableData.totalSeat > self.curPlayer) then
			self:share_room_info_text(self:get_share_data())
		end
	end
end

--- 刷新游戏状态
function TableBaseModule:refresh_game_state(gameState)

end

function TableBaseModule:get_share_data()
	local curTableData = TableManager.curTableData
	local shareData = {}
	shareData.type = 2
	shareData.roomId = curTableData.RoomID .. ""
	shareData.rule = self.view.ruleJsonInfo
	shareData.baseScore = self.view.baseCoinScore or 0
	if(curTableData.RoundCount > 0) then
		shareData.ruleName = curTableData.RoundCount .. "局 " .. self.view.ruleName
	else
		shareData.ruleName = self.view.ruleName
	end
	shareData.title = self.view.wanfaName
	shareData.userID = self.modelData.roleData.userID
	if(curTableData.HallID > 0) then
		shareData.parlorId = curTableData.HallID .. ""
		shareData.roomType = curTableData.RoomType
	else
		shareData.roomType = 0
	end

	if(curTableData.RoomType == 3) then-- 比赛场分享
		shareData.type = 4
		shareData.matchId = curTableData.MatchID
	elseif curTableData.RoomType == 2 then--快速组局
		shareData.parlorId = shareData.parlorId ..  string.format("%06d",ModuleCache.GameManager.curGameId)
	end
	shareData.totalPlayer = curTableData.totalSeat
	shareData.curPlayer = self.curPlayer
	shareData.totalGames = curTableData.RoundCount
	shareData.comeIn = 0


	local gameName = ""
	if curTableData.ruleJsonInfo.gameName and curTableData.ruleJsonInfo.gameName ~= "" then
		gameName = curTableData.ruleJsonInfo.gameName
	else--有得rule里没有 playRule.gameName
		local wanfaType = Config.GetWanfaIdx(curTableData.ruleJsonInfo.GameType)
		gameName = Config.get_create_name(wanfaType)
	end

	shareData.gameName_full = gameName
	print_table(shareData)
	print(shareData.gameName_full,"--------------share-----------shareData.type:",shareData.type,shareData.parlorId,shareData.matchId)
	return shareData
end

--- 邀请好友
function TableBaseModule:inviteWeChatFriend()
	if(ModuleCache.GameManager.iosAppStoreIsCheck)then
		return
	end
	local shareData = self:get_share_data()
	shareData.ruleName = string.gsub(shareData.ruleName, "分", "芬")
	ModuleCache.ShareManager().shareRoomNum(shareData, false)
end

return  TableBaseModule