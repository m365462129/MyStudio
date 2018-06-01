--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_poker.base_table_module')
---@class DaiGouTuiTableModule
---@field view WuShiKTableView
---@field logic WuShiKGameLogic
local WuShiKTableModule = class('tableModule', ModuleBase)

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

function WuShiKTableModule:initialize(...)
	ModuleBase.initialize(self, "table_view", "table_model", ...)
	
	self.packageName = "wushik"
	self.moduleName = "table"
	self.config = require('package.wushik.config')
	self.myHandPokers = (require("package/wushik/module/table/handpokers")):new(self)
	self.logic = require('package.wushik.module.table.wushik_game_logic'):new(self)
end




function WuShiKTableModule:on_model_event_bind()
	ModuleBase.on_model_event_bind(self)

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
	self:subscibe_model_event("Event_Table_FightAlone", function(eventHead, eventData)     --同步包
		self:on_table_fight_alone_rsp(eventData)
	end)
	self:subscibe_model_event("Event_Table_FightAlone_Notify", function(eventHead, eventData)     --同步包
		self:on_table_fight_alone_notify(eventData)
	end)
	self:subscibe_model_event("Event_Table_PointsPicked_Notify", function(eventHead, eventData)     --同步包
		self:on_table_points_picked_notify(eventData)
	end)

end

function WuShiKTableModule:on_module_event_bind()
	ModuleBase.on_module_event_bind(self)
	self:subscibe_module_event("onegameresult", "Event_continue_game", function(eventHead, eventData)
		self.logic:on_click_gameresule_continue_btn()
	end)
	
	-- self:subscibe_package_event("Event_RoomSetting_DissolvedRoom", function(eventHead, eventData)
	-- 	self.model:request_dissolve_room(true)
	-- end)
end


------------------------------------------
--点击按钮

function WuShiKTableModule:on_click_leave_btn(obj, arg)
	self.logic:on_click_leave_btn(obj, arg)
end

------------------------------------------------------------
--消息处理

function WuShiKTableModule:on_reset_notify(eventData)
	self.logic:on_reset_notify(eventData)
end

--踢人回包
function WuShiKTableModule:on_kick_player_rsp(eventData)
	if(not eventData.err_no or eventData.err_no == '0')then

	end
end

--踢人通知
function WuShiKTableModule:on_kick_player_notify(eventData)
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	local playerId = eventData.player_id
	if(playerId == mySeatInfo.playerId)then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您被房主踢出房间")	
		self:onLeaveRoomSuccess()
	else
		self:on_leave_room_notify({player_id=playerId})
	end
end

--进入房间响应
function WuShiKTableModule:on_enter_room_rsp(eventData)
	ModuleBase.on_enter_room_rsp(self, eventData)
	self.logic:on_enter_room_rsp(eventData)
end

--进入房间通知
function WuShiKTableModule:on_enter_notify(eventData)
	ModuleBase.on_enter_notify(self, eventData)
end

--准备响应
function WuShiKTableModule:on_ready_rsp(eventData)
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

--准备通知
function WuShiKTableModule:on_ready_notify(eventData)
	ModuleBase.on_ready_notify(self, eventData)
	if(self:isAllSeatReady())then
		local roomInfo = self.modelData.curTableData.roomInfo
		local mySeatInfo = roomInfo.mySeatInfo
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
	self.logic:on_ready_notify(eventData)
end

--开始响应
function WuShiKTableModule:on_start_rsp(eventData)
	ModuleBase.on_start_rsp(self, eventData)
end

--开始通知
function WuShiKTableModule:on_start_notify(eventData)
	ModuleBase.on_start_notify(self, eventData)
	self.logic:on_start_notify(eventData)
end

function WuShiKTableModule:on_table_discard_rsp(eventData)
	self.logic:on_table_discard_rsp(eventData)
end

function WuShiKTableModule:on_table_discard_notify(eventData)
	self.logic:on_table_discard_notify(eventData)
end

function WuShiKTableModule:on_table_currentaccount_notify(eventData)
	self.logic:on_table_currentaccount_notify(eventData)
end

function WuShiKTableModule:on_table_gameinfo_notify(eventData)
	self.logic:on_table_gameinfo_notify(eventData)
end

function WuShiKTableModule:on_table_fight_alone_rsp(eventData)
	self.logic:on_table_fight_alone_rsp(eventData)
end

function WuShiKTableModule:on_table_fight_alone_notify(eventData)
	self.logic:on_table_fight_alone_notify(eventData)
end

function WuShiKTableModule:on_table_points_picked_notify(eventData)
	self.logic:on_table_points_picked_notify(eventData)
end

function WuShiKTableModule:on_press_up(obj, arg)
	-- print("on_press_up", obj.name)
	ModuleBase.on_press_up(self, obj, arg)
	self.logic:on_press_up(obj, arg)
end

function WuShiKTableModule:on_drag(obj, arg)
	-- print("on_drag ", obj.name)
	ModuleBase.on_drag(self, obj, arg)
	self.logic:on_drag(obj, arg)
end

function WuShiKTableModule:on_press(obj, arg)
	-- print("on press ", obj.name)
	ModuleBase.on_press(self, obj, arg)
	self.logic:on_press(obj, arg)
end

function WuShiKTableModule:on_click(obj, arg)
	-- print("on_click", obj.name)
	ModuleBase.on_click(self, obj, arg)
	self.logic:on_click(obj, arg)
end

function WuShiKTableModule:play_shot_vocie(key, seatInfo)
	local voiceName = "chat_" .. key
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then		
		ModuleCache.SoundManager.play_sound(self.packageName, self.packageName .. "/sound/woman/chat/" .. voiceName .. ".bytes", voiceName)
	else
		ModuleCache.SoundManager.play_sound(self.packageName, self.packageName .. "/sound/man/chat/" .. voiceName .. ".bytes", voiceName)
	end
end

function WuShiKTableModule:playBgm()
	self.logic:playBgm()
end

function WuShiKTableModule:on_free_room_notify(eventData)
	if(self.logic.is_summary_account)then
		return
	end
	ModuleBase.on_free_room_notify(self, eventData)
end

function WuShiKTableModule:on_pre_share_room_num()
	local roomInfo = self.modelData.curTableData.roomInfo
	local curPlayerCount = #self:getSeatedSeatList(roomInfo.seatInfoList)
	self:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, false, curPlayerCount)
end

function WuShiKTableModule:fillRoomSetting_PokerFaceChangeData(intentData)
	ModuleBase.fillRoomSetting_PokerFaceChangeData(self, intentData)
	if(self.logic)then
		self.logic:fillRoomSetting_PokerFaceChangeData(intentData)
	end
end

-- function DaiGouTuiTableModule:on_click_setting_btn(obj, arg)
-- 	self.logic:testfun()
-- end

function WuShiKTableModule:on_click_poker_table_frame_leave_btn()
	self.logic:on_click_leave_btn()
end


function WuShiKTableModule:checkLocation()
	local roomInfo = self.logic.roomInfo
	local seatInfoList = roomInfo.seatInfoList
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
	data.roomID=roomInfo.roomNum;
	data.tableCount=4;
	data.isShowLocation=false;

	--打开定位功能界面
	ModuleCache.ModuleManager.show_module("henanmj", "tablelocation",data);
end

--点击定位按钮
function WuShiKTableModule:on_click_location_btn(obj, arg)
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

return WuShiKTableModule