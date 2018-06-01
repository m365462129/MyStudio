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
    ModuleBase.initialize(self, "onegameresult_view", nil, ...)
	self.packageName = "shisanzhang"
	self.moduleName = "onegameresult"
end


function OneGameResultModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	
	if(self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup)then
		return
	end
	if(obj.name == "BtnRestart") then
		ModuleCache.ModuleManager.destroy_module(self.packageName, self.moduleName)
		self:dispatch_module_event(self.moduleName, "Event_continue_game")
	elseif(obj.name == "BtnShowDesk") then
		--ModuleCache.ShareManager().shareImage(false)
		ModuleCache.ModuleManager.destroy_module(self.packageName, self.moduleName)
	end
end

function OneGameResultModule:on_show(result)
	--[[
	local result = {}
	result.roomInfo = {
		roomNum=122222,
		curRoundNum = 1,
		totalRoundCount = 10,

	}
	result.myPlayerId = 101
	result.players = {}
	for i=1,4 do
		local player = {}
		player.playerId = 100 + i
		player.playerName = 'helo'..i
		player.uplevel = i
		player.multiple = i
		player.score = i > 1 and 0 or i
		player.rank = i
		result.players[i] = player
	end
	--]]
	self.view:refresh_view(result)
end


return  OneGameResultModule