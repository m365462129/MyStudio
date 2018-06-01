--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_poker.base_table_module')
local DouDiZhuTableModule = class('tableModule', ModuleBase)

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

function DouDiZhuTableModule:initialize(...)
	ModuleBase.initialize(self, "doudizhu_table_view", "doudizhu_table_model", ...)
	
	self.packageName = "doudizhu"
	self.moduleName = "doudizhu_table"
	self.config = require('package.doudizhu.config')
	self.myHandPokers = (require("package/doudizhu/module/doudizhu_table/handpokers")):new(self)
	self.logic = require('package.doudizhu.module.doudizhu_table.doudizhu_game_logic'):new(self)

end




function DouDiZhuTableModule:on_model_event_bind()
	ModuleBase.on_model_event_bind(self)

	self:subscibe_model_event("Event_Table_Show_Cards", function(eventHead, eventData)     --明牌应答		
		self:on_table_show_cards_rsp(eventData)
	end)

	self:subscibe_model_event("Event_Table_Show_Cards_Notify", function(eventHead, eventData)     --明牌通知		
		self:on_table_show_cards_notify(eventData)
	end)

	self:subscibe_model_event("Event_Table_GrabLandLord", function(eventHead, eventData)     --抢地主应答		
		self:on_table_grablandlord_rsp(eventData)
	end)

	self:subscibe_model_event("Event_Table_GrabLandLord_Notify", function(eventHead, eventData)     --抢地主通知	
		self:on_table_grablandlord_notify(eventData)
	end)

	self:subscibe_model_event("Event_Table_Start_GrabLandLord_Notify", function(eventHead, eventData)     --开始抢地主通知	
		self:on_table_start_grablandlord_notify(eventData)
	end)

	self:subscibe_model_event("Event_Table_GrabLandLord_Result_Notify", function(eventHead, eventData)     --抢地主结果通知	
		self:on_table_grablandlord_result_notify(eventData)
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

	self:subscibe_model_event("Msg_Table_OwnerChangeNotify", function(eventHead, eventData)
		print("=================Msg_Table_OwnerChangeNotify")

		--if self.modelData.roleData.RoomType == 2 then--亲友圈快速组局
		--    self.modelData.curTableData.roomInfo.owner = eventData.new_ownerid
		--
		--    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
		--
		--
		--    if (tonumber(eventData.new_ownerid) == tonumber(self.modelData.roleData.userID)) then
		--        -- 是房主
		--        self.view.switcher:SwitchState("Three");
		--
		--        local seatsInfo = self.modelData.curTableData.roomInfo.seatInfoList;
		--        for key, v in ipairs(seatsInfo) do
		--            if(tonumber(v.playerId) ~= tonumber(eventData.new_ownerid) and tonumber(v.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)  and tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0) then
		--                --TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
		--                local seatHolder = self.tableView.seatHolderArray[v.localSeatIndex]
		--                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,true)
		--            end
		--        end
		--
		--    else
		--        self.view.switcher:SwitchState("Two");
		--    end
		--
		--    local seatInfo = self:getSeatInfoByPlayerId(eventData.new_ownerid, seatInfoList)
		--    self.view:refreshSeatInfo(seatInfo)
		--end
	end)

	self:subscibe_model_event("Msg_Table_CancelReadyNotify", function(eventHead, eventData)
		print("=================Msg_Table_CancelReadyNotify")
		ModuleCache.ModuleManager.hide_public_module("netprompt")

		if self.modelData.roleData.RoomType == 2 then--亲友圈快速组局
			local seatInfo =self:getSeatInfoByPlayerId(eventData.playerid,self.modelData.curTableData.roomInfo.seatInfoList)
			if(seatInfo) then
				seatInfo.isReady = false
				self.view:refreshSeatState(seatInfo)

				if tonumber(eventData.playerid) == tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
					self.view:showReadyBtn_three(true)
				end
			else
				print("====没有找到玩家id=",tostring(eventData.playerid))
			end
		end
	end)

	-- 亲友圈 快速组局 踢人倒计时
	self:subscibe_model_event("Event_Table_KickPlayerExpire", function(eventHead, eventData)
		ModuleCache.ModuleManager.hide_public_module("netprompt")
		print("------------------收到踢人倒计时：", eventData.expire)
		-- self.modelData.roleData.RoomType == 0 --0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
		if self.kickedTimeId then
			CSmartTimer:Kill(self.kickedTimeId)
		end

		self.view.ready_count_down_obj:SetActive(true)
		self.kickedTimeId = self:subscibe_time_event(eventData.expire, false, 1):OnUpdate( function(t)
			t = t.surplusTimeRound
			self.view.ready_count_down_tex.text = "(" .. t .. ")"
		end ):OnComplete( function(t)
			self.view.ready_count_down_obj:SetActive(false)
		end ).id

	end )

end

function DouDiZhuTableModule:on_module_event_bind()
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

function DouDiZhuTableModule:on_click_leave_btn(obj, arg)
	self.logic:on_click_leave_btn(obj, arg)
end

------------------------------------------------------------
--消息处理

--踢人回包
function DouDiZhuTableModule:on_kick_player_rsp(eventData)
	if(not eventData.err_no or eventData.err_no == '0')then

	end
end

--踢人通知
function DouDiZhuTableModule:on_kick_player_notify(eventData)
	self.view.ready_count_down_obj:SetActive(false)
	local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
	local playerId = eventData.player_id
	if(playerId == mySeatInfo.playerId)then
		if(self.logic.isGoldTable)then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("由于长时间未准备，系统将您移出房间")
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您被房主踢出房间")
		end
		self:onLeaveRoomSuccess()
	else
		self:on_leave_room_notify({player_id=playerId})
	end
end

--离开房间通知
function DouDiZhuTableModule:on_leave_room_notify(eventData)
	self.view.ready_count_down_obj:SetActive(false)
	ModuleBase.on_leave_room_notify(self, eventData)
end

--进入房间响应
function DouDiZhuTableModule:on_enter_room_rsp(eventData)
	ModuleBase.on_enter_room_rsp(self, eventData)
	self.logic:on_enter_room_rsp(eventData)
end

--进入房间通知
function DouDiZhuTableModule:on_enter_notify(eventData)
	ModuleBase.on_enter_notify(self, eventData)
end

--准备响应
function DouDiZhuTableModule:on_ready_rsp(eventData)
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
function DouDiZhuTableModule:on_ready_notify(eventData)
	ModuleBase.on_ready_notify(self, eventData)
	if(self:isAllSeatReady())then
		local roomInfo = self.modelData.curTableData.roomInfo
		local mySeatInfo = roomInfo.mySeatInfo
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
end

--开始响应
function DouDiZhuTableModule:on_start_rsp(eventData)
	ModuleBase.on_start_rsp(self, eventData)
end

--开始通知
function DouDiZhuTableModule:on_start_notify(eventData)
	ModuleBase.on_start_notify(self, eventData)
	self.logic:on_start_notify(eventData)
end

--明牌应答
function DouDiZhuTableModule:on_table_show_cards_rsp(eventData)
	self.logic:on_table_show_cards_rsp(eventData)
end

--明牌通知
function DouDiZhuTableModule:on_table_show_cards_notify(eventData)
	self.logic:on_table_show_cards_notify(eventData)
end

--抢地主应答
function DouDiZhuTableModule:on_table_grablandlord_rsp(eventData)
	self.logic:on_table_grablandlord_rsp(eventData)
end

--抢地主通知
function DouDiZhuTableModule:on_table_grablandlord_notify(eventData)
	self.logic:on_table_grablandlord_notify(eventData)
end

--开始抢地主通知
function DouDiZhuTableModule:on_table_start_grablandlord_notify(eventData)
	self.logic:on_table_start_grablandlord_notify(eventData)
end

--抢地主结果通知
function DouDiZhuTableModule:on_table_grablandlord_result_notify(eventData)
	self.logic:on_table_grablandlord_result_notify(eventData)
end

function DouDiZhuTableModule:on_table_discard_rsp(eventData)
	self.logic:on_table_discard_rsp(eventData)
end

function DouDiZhuTableModule:on_table_discard_notify(eventData)
	self.logic:on_table_discard_notify(eventData)
end

function DouDiZhuTableModule:on_table_currentaccount_notify(eventData)
	self.logic:on_table_currentaccount_notify(eventData)
end

function DouDiZhuTableModule:on_table_gameinfo_notify(eventData)
	self:check_activity_is_open()
	self.logic:on_table_gameinfo_notify(eventData)
	local roomInfo = self.modelData.curTableData.roomInfo
	local mySeatInfo = roomInfo.mySeatInfo
	if(not roomInfo.isRoundStarted and  self:isAllSeatReady())then
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
end

function DouDiZhuTableModule:on_shotsettle_notify(eventData)
	self.logic:on_shotsettle_notify(eventData)
end


function DouDiZhuTableModule:on_press_up(obj, arg)
	-- print("on_press_up", obj.name)
	ModuleBase.on_press_up(self, obj, arg)
	self.logic:on_press_up(obj, arg)
end

function DouDiZhuTableModule:on_drag(obj, arg)	
	-- print("on_drag ", obj.name)
	ModuleBase.on_drag(self, obj, arg)
	self.logic:on_drag(obj, arg)
end

function DouDiZhuTableModule:on_press(obj, arg)
	-- print("on press ", obj.name)
	ModuleBase.on_press(self, obj, arg)
	self.logic:on_press(obj, arg)
end

function DouDiZhuTableModule:on_click(obj, arg)	
	-- print("on_click", obj.name)
	ModuleBase.on_click(self, obj, arg)
	self.logic:on_click(obj, arg)
end

function DouDiZhuTableModule:play_shot_vocie(key, seatInfo)	
	local voiceName = "chat_" .. key
	if(seatInfo.playerInfo and seatInfo.playerInfo.gender ~= 1) then		
		ModuleCache.SoundManager.play_sound(self.packageName, self.packageName .. "/sound/woman/chat/" .. voiceName .. ".bytes", voiceName)
	else
		ModuleCache.SoundManager.play_sound(self.packageName, self.packageName .. "/sound/man/chat/" .. voiceName .. ".bytes", voiceName)
	end
end

function DouDiZhuTableModule:playBgm()
	self.logic:playBgm()
end

function DouDiZhuTableModule:on_event_tableshop_open(open)
	open = open or false
	if(self.logic.isGoldTable)then
		self.model:request_recharge(open)
	end
end

function DouDiZhuTableModule:on_event_refresh_userinfo()
	if(self.logic.isGoldTable)then
		self.model:request_refresh_user_coin()
	end
end

function DouDiZhuTableModule:on_instrust_rsp(eventData)
	self.logic:on_instrust_rsp(eventData)
end

function DouDiZhuTableModule:on_intrust_notify(eventData)
	self.logic:on_intrust_notify(eventData)
end

function DouDiZhuTableModule:on_recharge_notify(eventData)
	self.logic:on_recharge_notify(eventData)
end

function DouDiZhuTableModule:on_pre_share_room_num()
	local roomInfo = self.modelData.curTableData.roomInfo
	local curPlayerCount = #self:getSeatedSeatList(roomInfo.seatInfoList)
	self:setShareData(roomInfo.ruleTable.playerCount, roomInfo.totalRoundCount, false, curPlayerCount)
end

-- function DouDiZhuTableModule:on_click_setting_btn(obj, arg)
-- 	self.logic:testfun()
-- end

function DouDiZhuTableModule:getRoomSettingData()
	local intentData = ModuleBase.getRoomSettingData(self)
	if(self.logic.isGoldTable)then
		intentData.canExitRoom = false
		intentData.canDissolveRoom = false
	end
	return intentData
end

function DouDiZhuTableModule:canInviteWaChatFriend()
	if(self.logic.isGoldTable)then
		return true
	else
		return self.modelData.curTableData.roomInfo.curRoundNum == 0
	end

end

------收到包:客户自定义的信息变化广播
function DouDiZhuTableModule:on_table_CustomInfoChangeBroadcast(data)
    ModuleBase.on_table_CustomInfoChangeBroadcast(self,data);
	if(self.modelData ==nil or self.modelData.curTableData == nil
	or self.modelData.curTableData.roomInfo == nil
	or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
		return
	end
   self:checkLocation();
end

function DouDiZhuTableModule:checkLocation()
	print_table({},"checkLocation---------------")
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
    data.gameType="doudizhu";
    data.seatHolderArray = seatInfoList;
    data.buttonLocation = self.view.buttonLocation;
    data.roomID=self.modelData.curTableData.roomInfo.roomNum;
    data.tableCount=3;
    data.isShowLocation=false;

    --打开定位功能界面
    ModuleCache.ModuleManager.show_module("henanmj", "tablelocation",data);
end

--点击定位按钮
function DouDiZhuTableModule:on_click_location_btn(obj, arg)
	if(self.modelData ==nil or self.modelData.curTableData == nil
	or self.modelData.curTableData.roomInfo == nil
	or self.modelData.curTableData.roomInfo.seatInfoList == nil) then
		return
	end
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    local data ={};
    data.gameType="doudizhu";
    data.seatHolderArray = seatInfoList;
    data.tableCount=3;
    data.isShowLocation=true;
    --打开定位功能界面
    ModuleCache.ModuleManager.show_module("henanmj", "tablelocation",data);
end

return DouDiZhuTableModule 