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

function OneGameResultModule:initialize(...)
    ModuleBase.initialize(self, "onegameresultpuning_view", nil, ...)
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
		ModuleCache.ModuleManager.destroy_module("majiangshanxi", "onegameresultpuning")
		self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
	elseif(obj.name == "BtnLookTotal") then
		self.view:show_totalgameresult_module()	-- 显示总结算
	elseif(obj.name == "BtnShare") then
		ModuleCache.ShareManager().shareImage(false)
	elseif(obj.name == "BtnPreTabel" or obj.name == "BtnReturn") then
		self:dispatch_module_event("onegameresult", "Event_Close_OneGameResult")
		ModuleCache.ModuleManager.destroy_module("majiangshanxi", "onegameresultpuning")
	end
end

function OneGameResultModule:on_show(gameState)
	self.view:refresh_view(gameState)
	if # gameState.MaiMa >0 then
		self.view:Init_MaiMaPanel(gameState)
	end
end


function OneGameResultModule:reconnect()
	self.oneGameResultModel.clientConnected = false
	self.oneGameResultModel:connect_server()
end



return  OneGameResultModule