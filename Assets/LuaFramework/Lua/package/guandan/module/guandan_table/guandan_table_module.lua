--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_poker.base_table_module')
local GuanDanTableModule = class('tableModule', ModuleBase)

local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local System = UnityEngine.System
local isPress = false
local isUpload = false
local isRecording = false
local timeEvent = nil
local recordPath = ""
local downloadPath = ""
local GameSDKInterface = ModuleCache.GameSDKInterface
local WechatManager = ModuleCache.WechatManager

function GuanDanTableModule:initialize(...)
	ModuleBase.initialize(self, "guandan_table_view", "guandan_table_model", ...)
	self:set_gameinfo_coming_time(nil)
	self.packageName = "guandan"
	self.moduleName = "guandan_table"
	self.config = require('package.guandan.config')
	self.myHandPokers = (require("package/guandan/module/guandan_table/handpokers")):new(self)
	self.logic = require('package.guandan.module.guandan_table.base_logic'):new(self)
	
end




function GuanDanTableModule:on_model_event_bind()
	ModuleBase.on_model_event_bind(self)
	self:subscibe_model_event("Event_Table_Tribute", function(eventHead, eventData)     --上贡应答				
		self:on_table_tribute_rsp(eventData)
	end)
	self:subscibe_model_event("Event_Table_Tribute_Notify", function(eventHead, eventData)     --上贡通知
		self:on_table_tribute_notify(eventData)
	end)
	self:subscibe_model_event("Event_Table_Tribute_Result_Notify", function(eventHead, eventData)     --上贡结果通知				
		self:on_table_tribute_result_notify(eventData)
	end)
	self:subscibe_model_event("Event_Table_Discard", function(eventHead, eventData)     --出牌应答		
		self:on_table_discard_rsp(eventData)
	end)
	self:subscibe_model_event("Event_Table_Discard_Notify", function(eventHead, eventData)     --出牌通知			
		self:on_table_discard_notify(eventData)
	end)
	self:subscibe_model_event("Event_Table_CurrentAccount_Notify", function(eventHead, eventData)     --小结算通知
		self:on_table_currentaccount_notify(eventData)
	end)
	self:subscibe_model_event("Event_Table_GameInfo_Notify", function(eventHead, eventData)     --同步包			
		self:on_table_gameinfo_notify(eventData)
	end)

	self:subscibe_model_event("Event_Table_KickPlayerExpire", function(eventHead, eventData)     --同步包
		print("@@@@@@@@@@@@@@@@@------------------收到踢人倒计时：", eventData.expire)
		-- self.modelData.roleData.RoomType == 0 --0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间

		if self.kickedTimeId then
			CSmartTimer:Kill(self.kickedTimeId)
		end
		self.view.readyBtn_countDown_obj:SetActive(true)
		self.kickedTimeId = self:subscibe_time_event(eventData.expire, false, 1):OnUpdate( function(t)
			t = t.surplusTimeRound

			self.view.readyBtn_countDown_tex.text ="(".. t .. "s)"
		end ):OnComplete( function(t)
			self.view.readyBtn_countDown_obj:SetActive(false)
		end ).id
	end)

end

function GuanDanTableModule:on_module_event_bind()
	ModuleBase.on_module_event_bind(self)
	self:subscibe_module_event("onegameresult", "Event_continue_game", function(eventHead, eventData)
		self.model:request_ready()
	end)
	
	-- self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
	-- 	self.model:request_dissolve_room(true)
	-- end)
end


------------------------------------------
--点击按钮

function GuanDanTableModule:on_click_leave_btn(obj, arg)
	self.logic:on_click_leave_btn(obj, arg)
end

------------------------------------------------------------
--消息处理

--进入房间响应
function GuanDanTableModule:on_enter_room_rsp(eventData)
	ModuleBase.on_enter_room_rsp(self, eventData)
	self.logic:on_enter_room_rsp(eventData)
end

function GuanDanTableModule:on_enter_notify(eventData)
	ModuleBase.on_enter_notify(self, eventData)
end

function GuanDanTableModule:on_ready_rsp(eventData)
	if(not self.modelData or (not self.modelData.curTableData) or (not self.modelData.curTableData.roomInfo))then
		return
	end
	ModuleBase.on_ready_rsp(self, eventData)
	if(self:isAllSeatReady())then
		local roomInfo = self.modelData.curTableData.roomInfo
		local mySeatInfo = roomInfo.mySeatInfo
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
	self.logic:on_ready_rsp(eventData)
end

function GuanDanTableModule:on_ready_notify(eventData)
	ModuleBase.on_ready_notify(self, eventData)
	if(self:isAllSeatReady())then
		local roomInfo = self.modelData.curTableData.roomInfo
		local mySeatInfo = roomInfo.mySeatInfo
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
end

function GuanDanTableModule:on_start_rsp(eventData)
	ModuleBase.on_start_rsp(self, eventData)
end

--开始通知
function GuanDanTableModule:on_start_notify(eventData)
	ModuleBase.on_start_notify(self, eventData)
	self.logic:on_start_notify(eventData)
end

function GuanDanTableModule:on_table_tribute_rsp(eventData)
	self.logic:on_table_tribute_rsp(eventData)

end

function GuanDanTableModule:on_table_tribute_notify(eventData)
	self.logic:on_table_tribute_notify(eventData)
end

function GuanDanTableModule:on_table_tribute_result_notify(eventData)
	self.logic:on_table_tribute_result_notify(eventData)
end

function GuanDanTableModule:on_table_discard_rsp(eventData)
	self.logic:on_table_discard_rsp(eventData)
end

function GuanDanTableModule:on_table_discard_notify(eventData)
	self.logic:on_table_discard_notify(eventData)
end

function GuanDanTableModule:on_table_currentaccount_notify(eventData)
	self.logic:on_table_currentaccount_notify(eventData)
end

function GuanDanTableModule:on_table_gameinfo_notify(eventData)
	self:check_activity_is_open()
	self:set_gameinfo_coming_time(Time.realtimeSinceStartup)
	self.logic:on_table_gameinfo_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(not roomInfo.isRoundStarted and  self:isAllSeatReady())then
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
end

--离开房间通知
function GuanDanTableModule:on_leave_room_notify(eventData)
	self.view.readyBtn_countDown_obj:SetActive(false)

	ModuleBase.on_leave_room_notify(self,eventData)
end

--踢人通知
function GuanDanTableModule:on_kick_player_notify(eventData)
	self.view.readyBtn_countDown_obj:SetActive(false)
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	local playerId = eventData.player_id
	if(playerId == mySeatInfo.playerId)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您被房主踢出房间")
		self:onLeaveRoomSuccess()
	else
		self:on_leave_room_notify({player_id=playerId})
	end
end



function GuanDanTableModule:on_press_up(obj, arg)
	ModuleBase.on_press_up(self, obj, arg)
	self.logic:on_press_up(obj, arg)
end

function GuanDanTableModule:on_drag(obj, arg)	
	--print("on_drag ", obj.name)
	ModuleBase.on_drag(self, obj, arg)
	self.logic:on_drag(obj, arg)
end

function GuanDanTableModule:on_press(obj, arg)
	--print("on press ", obj.name)
	ModuleBase.on_press(self, obj, arg)
	self.logic:on_press(obj, arg)
end

function GuanDanTableModule:on_click(obj, arg)
	ModuleBase.on_click(self, obj, arg)
	self.logic:on_click(obj, arg)
	if(obj == self.view.buttonTextReconnect.gameObject)then
		self:dispatch_package_event('Event_PokerTableFrame_Click_TestReconnect')
	end
end

function GuanDanTableModule:play_shot_vocie(key, seatInfo)	
	local voiceName = ""
	local index = tonumber(key)
	if(index >= 6 and index <= 9)then
		index = index + 1
	end
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then		
		voiceName = "quick_" .. index
		ModuleCache.SoundManager.play_sound("guandan", "guandan/sound/woman/" .. voiceName .. ".bytes", voiceName)
	else
		voiceName = "m_quick_" .. index
		ModuleCache.SoundManager.play_sound("guandan", "guandan/sound/man/" .. voiceName .. ".bytes", voiceName)
	end
end

function GuanDanTableModule:playBgm()
	self.logic:playBgm()
end

function GuanDanTableModule:getShotTextByShotTextIndex(index, seatInfo)
	local num = tonumber(index)
	if(num == 8)then
		if(seatInfo and seatInfo.gender ~= 1)then
			index = '9'
		end
	end
	return ModuleBase.getShotTextByShotTextIndex(self, index, seatInfo)
end

function GuanDanTableModule:getChatShowShotText()
	local config = {
		chatShotTextList = {}
	}
	for i=1,#self.config.chatShotTextList do
		config.chatShotTextList[i] = self.config.chatShotTextList[i]
	end
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	if(mySeatInfo.gender == 1)then
		table.remove(config.chatShotTextList, 9)
	else
		table.remove(config.chatShotTextList, 8)
	end
	return config
end

function GuanDanTableModule:on_pre_share_room_num()
	local roomInfo = self.modelData.curTableData.roomInfo
	local curPlayerCount = #self:getSeatedSeatList(roomInfo.seatInfoList)
	self:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, false, curPlayerCount)
end

-- function GuanDanTableModule:on_click_setting_btn(obj, arg)
-- 	self.logic:testfun()
-- end

------收到包:客户自定义的信息变化广播
function GuanDanTableModule:on_table_CustomInfoChangeBroadcast(data)
    ModuleBase.on_table_CustomInfoChangeBroadcast(self,data);
	if(self.modelData ==nil or self.modelData.curTableData == nil
	or self.modelData.curTableData.roomInfo == nil
	or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
		return
	end
   self:checkLocation();
end

function GuanDanTableModule:checkLocation()

    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		local playerInfo = seatInfo.playerInfo
		if(playerInfo)then
			local locationData = self:get_location_data_by_playerid(seatInfo.playerId)
			if(locationData)then
				playerInfo.locationData = locationData
				playerInfo.ip = locationData.ip
			end
		end
	end
    local data ={};
    data.gameType="guandan";
    data.seatHolderArray = seatInfoList;
    data.buttonLocation = self.view.buttonLocation;
    data.roomID=self.modelData.curTableData.roomInfo.roomNum;
    data.tableCount=4;
    data.isShowLocation=false;

    --打开定位功能界面
    ModuleCache.ModuleManager.show_module("henanmj", "tablelocation",data);
end

--点击定位按钮
function GuanDanTableModule:on_click_location_btn(obj, arg)
	if(self.modelData ==nil or self.modelData.curTableData == nil
	or self.modelData.curTableData.roomInfo == nil
	or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
		return
	end
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local data ={};
    data.gameType="guandan";
    data.seatHolderArray = seatInfoList;
    data.tableCount=4;
    data.isShowLocation=true;
    --打开定位功能界面
    ModuleCache.ModuleManager.show_module("henanmj", "tablelocation",data);
end

return GuanDanTableModule 