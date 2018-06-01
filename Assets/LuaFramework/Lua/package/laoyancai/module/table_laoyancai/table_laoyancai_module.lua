--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_poker.base_table_module')
local LaoYanCaiTableModule = class('laoYanCaiTableModule', ModuleBase)

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

function LaoYanCaiTableModule:initialize(...)
	ModuleBase.initialize(self, "table_laoyancai_view", "table_laoyancai_model", ...)
	
	self.packageName = "laoyancai"
	self.moduleName = "table_laoyancai"
	self.config = require('package.laoyancai.config')
	--self.myHandPokers = (require("package/guandan/module/guandan_table/handpokers")):new(self)
	self.logic = require('package.laoyancai.module.table_laoyancai.table_laoyancai_gamelogic'):new(self)
end

function LaoYanCaiTableModule:on_enter_room_rsp(evenData)
	ModuleBase.on_enter_room_rsp(self, eventData)
	self.logic:on_enter_room_rsp(eventData)
end

function LaoYanCaiTableModule:on_enter_notify(eventData)
	ModuleBase.on_enter_notify(self, eventData)
	local seatIndex = eventData.pos_info.pos_index
	local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[seatIndex]
	self.view:SetSeatActive(seatInfo.localSeatIndex,true);
end

function LaoYanCaiTableModule:on_ready_rsp(eventData)
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

function LaoYanCaiTableModule:on_ready_notify(eventData)
	ModuleBase.on_ready_notify(self, eventData)
	if(self:isAllSeatReady())then
		local roomInfo = self.modelData.curTableData.roomInfo
		local mySeatInfo = roomInfo.mySeatInfo
		if(mySeatInfo.isCreator)then
			--self.view:showStartBtn(true)
		end
	end
end

function LaoYanCaiTableModule:on_start_rsp(eventData)
	ModuleBase.on_start_rsp(self, eventData)
end

--开始通知
function LaoYanCaiTableModule:on_start_notify(eventData)
	ModuleBase.on_start_notify(self, eventData)
	self.logic:on_start_notify(eventData)
	self:check_activity_is_open()
end

function LaoYanCaiTableModule:on_model_event_bind()
	ModuleBase.on_model_event_bind(self)
	self:subscibe_model_event("Event_Start_Operation_Notify", function(eventHead, eventData)     				
		self.logic:StartOperation(eventData);
	end)
	self:subscibe_model_event("Event_Table_Confirm_Banker_Notify", function(eventHead, eventData)     				
		self.logic:ConfirmBanker(eventData);
	end)
	self:subscibe_model_event("Event_Table_GameInfo", function(eventHead, eventData)     				
		self.logic:ReceiveGameInfo(eventData);
		local roomInfo = self.modelData.curTableData.roomInfo
		local mySeatInfo = roomInfo.mySeatInfo
		if(eventData.room_state == 0 and eventData.game_loop_cnt == 0)then
			if(mySeatInfo.isCreator)then
				self.view:showStartStatus(true)
			else
				self.view:showStartStatus(false)
			end
		end
		if(not roomInfo.isRoundStarted and roomInfo.curRoundNum == 0) then
			self.model:request_ready();
		end
		ModuleBase:on_enter_room_event(roomInfo)
		
	end)
	self:subscibe_model_event("Event_Table_Start_Banker_Notify", function(eventHead, eventData)     				
		self.logic:StartBanker(eventData)
	end)
	self:subscibe_model_event("Event_Table_Knock_Banker_Notify", function(eventHead, eventData)     -- 抢庄通知		
		self.logic:OthersKnockBanker(eventData)
	end)
	self:subscibe_model_event("Event_Table_Knock_Banker", function(eventHead, eventData)     				
		self.logic:KnockBankerRsp(eventData)
	end)
	self:subscibe_model_event("Event_Table_Chip_Off_Notify",function(eventHead,eventData)
		self.logic:ChipOffNotify(eventData);
	end)
	self:subscibe_model_event("Event_Operation",function(eventHead,eventData)
		self.logic:OperationResult(eventData);
	end)
	self:subscibe_model_event("Event_Operation_Notify",function(eventHead,eventData)
		self.logic:OperationNotify(eventData);
	end)
	self:subscibe_model_event("Event_Compare_Notify",function(eventHead,eventData)
		self.logic:CompareResult(eventData);
	end)
	self:subscibe_model_event("Event_View_Card_Notify",function(eventHead,eventData)
		self.logic:ViewOthersPokers(eventData);
	end)
	self:subscibe_model_event("Event_Queue_Banker_Notify",function(eventHead,eventData)
		self.logic:SetBankerQueue(eventData);
	end)
	self:subscibe_model_event("Event_Table_CurrentGameAccount",function(eventHead,eventData)
		self:GetGameResult(eventData);
	end)
	
end

--//广播 结算信息 一把打玩发送
--message CurrentGameAccount {
    --message Player {
        --optional int32 player_id = 1; //玩家ID
        --optional int32 score = 2; //总积分
        --optional int32 win_cnt = 3; //胜利次数
        --optional int32 lost_cnt = 4; //失败次数
        --optional int32 sanpi_times = 5; //三批次数
        --optional int32 sanyan_times = 6; //三腌次数
        --optional int32 shuangyan_times = 7; //双腌次数
    --}
    --repeated Player players = 1;
    --optional string endTime = 2; //牌局结束时间(秒)
    --optional int32 game_count = 3; //总游戏局数
    --optional bool is_summary_account = 4; //是否大结
    --optional bool is_free_room = 5; //是否是解散房间
    --optional string startTime = 6; //牌局开始时间(秒)
--}

function LaoYanCaiTableModule:on_kick_player_notify(eventData)
	print_table(eventData);
	if(eventData.player_id == self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已被房主移出房间！")
		TableManagerPoker:disconnect_game_server()
        ModuleCache.net.NetClientManager.disconnect_all_client()
        ModuleCache.ModuleManager.destroy_package("laoyancai")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
	else
		ModuleCache.ModuleManager.hide_public_module("netprompt")
        ModuleBase.on_leave_room_notify(self,eventData)
	end
end

function LaoYanCaiTableModule:on_pre_share_room_num()
	local totalPlayer = self.modelData.curTableData.roomInfo.ruleTable.playerCount;
	local totalGames = self.modelData.curTableData.roomInfo.ruleTable.roundCount
	local comeIn= self.modelData.curTableData.roomInfo.ruleTable.allowEnter
	local curPlayer = self.logic:GetCurPlayerCount()
	ModuleBase:setShareData(totalPlayer, totalGames, comeIn,curPlayer)
end

function LaoYanCaiTableModule:GetGameResult(data)
	local isLastGame = data.is_summary_account
	if(not isLastGame) then
		return;
	end
	local players = data.players;
	local totalRoundCount = data.game_count;
	local startTime = os.date("%Y-%m-%d %H:%M",data.startTime);
	local endTime = os.date("%Y-%m-%d %H:%M",data.endTime);
	local roomInfo =
    {
    	roomNum = self.modelData.curTableData.roomInfo.roomNum,
        curRoundNum = self.modelData.curTableData.roomInfo.curRoundNum,
        totalRoundNum = self.modelData.curTableData.roomInfo.totalRoundCount,
        startTime = startTime,
        endTime = endTime
    }
	local gameName = "LaoYanCai";
	local resultList = {};
	for i = 1,#players do
		seatInfo = self.logic:GetSeatInfoById(players[i].player_id)
		local result = {};
		result.timeSanPi = players[i].sanpi_times;
		result.timeSanYan = players[i].sanyan_times;
		result.timeShuangYan = players[i].shuangyan_times;
		result.timeZhaKai = players[i].zhakai_times;
		result.playerId = players[i].player_id;
        result.isRoomCreator = seatInfo.isCreator
        result.playerInfo = seatInfo.playerInfo
		result.totalScore = players[i].score;
		table.insert(resultList,result);
	end
	self.showResultViewSmartTimer_id = nil
    local timeEvent = nil
	print(data.startTime)
	print(data.endTime)
	local delayTime = 5;
	if(totalRoundCount > self.modelData.curTableData.roomInfo.curRoundNum) then
		delayTime = 1;
	end
    timeEvent = self:subscibe_time_event(delayTime, false, 0):OnComplete( function(t)
        --local game = "";
        --if (self.TableBiJiLogic.roomInfo.ruleTable.gameType == 0) then
           -- game = "极速比鸡";
        --elseif (self.TableBiJiLogic.roomInfo.ruleTable.gameType == 1) then
            --game = "舒城比鸡";
        --end
		local dissolverId = data.free_sponsor;
		ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
        ModuleCache.ModuleManager.show_module("laoyancai", "tableresult", { gameName = gameName,dissolverId = dissolverId, resultList = resultList, roomInfo =  roomInfo}, gameName)
        self.showResultViewSmartTimer_id = nil
    end ):OnKill( function(t)

    end )
    self.showResultViewSmartTimer_id = timeEvent.id
end

function LaoYanCaiTableModule:on_click_leave_btn(obj, arg)
	self.logic:on_click_leave_btn(obj, arg)
end

function LaoYanCaiTableModule:on_module_event_bind()
	ModuleBase.on_module_event_bind(self)
end

function LaoYanCaiTableModule:on_press_up(obj, arg)
	ModuleBase.on_press_up(self, obj, arg)
	self.logic:on_press_up(obj, arg)
end

function LaoYanCaiTableModule:on_drag(obj, arg)	
	--print("on_drag ", obj.name)
	ModuleBase.on_drag(self, obj, arg)
	self.logic:on_drag(obj, arg)
end

function LaoYanCaiTableModule:on_press(obj, arg)
	--print("on press ", obj.name)
	ModuleBase.on_press(self, obj, arg)
	self.logic:on_press(obj, arg)
end

function LaoYanCaiTableModule:on_click(obj, arg)	
	ModuleBase.on_click(self, obj, arg)
	self.logic:on_click(obj, arg)
end


return LaoYanCaiTableModule