--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('core.mvvm.module_base')
local OneGameResultModule = class('oneGameResultModule', ModuleBase)
local PlayerPrefs = UnityEngine.PlayerPrefs

function OneGameResultModule:initialize(...)
    ModuleBase.initialize(self, "onegameresult_view", nil, ...)
	self.netClient = self.modelData.bullfightClient
end


function OneGameResultModule:on_module_inited()

end

function OneGameResultModule:on_module_event_bind()

end

function OneGameResultModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if(self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup)then
		return
	end
	if(obj.name == "BtnRestart" or obj.name == "BtnContinue") then
		if(self.gameState.Result ~= 3) then
			local sendData = nil
			if(self.view.ConfigData.isKaWuXing and TableManager.curTableData.ruleJsonInfo.YouPiao) then
				sendData = {xiaojiScore = TableManager.curTableData.kaWuXingPiao, paoScore = -1}
			end
			self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy", sendData)
		else
			self:dispatch_module_event("tablestrategy", "Event_QiShouHu_Continue")
		end
		ModuleCache.ModuleManager.destroy_module("majiang", "onegameresult")
	elseif(obj.name == "BtnLookTotal") then
		self.view:show_totalgameresult_module()	-- 显示总结算
	elseif(obj.name == "BtnShare") then
		ModuleCache.ShareManager().shareImage(false)
	elseif(obj.name == "ButtonExit") then
		UnityEngine.PlayerPrefs.SetInt("ChangeTable", -1)
		self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
	elseif(obj.name == "ButtonChangeTable") then
		UnityEngine.PlayerPrefs.SetInt("ChangeTable", 1)
		self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
	elseif(obj.name == "BtnPreTabel"or obj.name == "BtnReturn") then
		self:dispatch_module_event("onegameresult", "Event_Close_OneGameResult")
		ModuleCache.ModuleManager.destroy_module("majiang", "onegameresult")
	elseif(string.sub(obj.name, 1, 9) == "ButtonPao") then
		local pao = tonumber(string.sub(obj.name, 10, 10)) - 1
		if(self.view.ConfigData.isKaWuXing) then
			PlayerPrefs.SetInt(string.format("%s_kawuxing_piao",TableManager.curTableData.ruleJsonInfo.GameType), pao + 1)
			self.view:kawuxing_piao()
			return
		end
	end
end

function OneGameResultModule:on_show(gameState)
	self.gameState = gameState
	self.view:refresh_view(self.gameState)
	if # self.gameState.MaiMa >0 then
		self.view:Init_MaiMaPanel(self.gameState)
	end
end

---设置自动跳转大结算
function OneGameResultModule:set_auto_goto_total_result(autoOpenTotalResultTime)
	if self.view.btnLookTotal.activeSelf and autoOpenTotalResultTime then  ---定时自动打开大结算
	self.view.timeEventID = self:subscibe_time_event(autoOpenTotalResultTime, false, 0):OnComplete(function(t)
		self.view:show_totalgameresult_module()
	end).id
	end
end

function OneGameResultModule:reconnect()
	self.oneGameResultModel.clientConnected = false
	self.oneGameResultModel:connect_server()
end



return  OneGameResultModule