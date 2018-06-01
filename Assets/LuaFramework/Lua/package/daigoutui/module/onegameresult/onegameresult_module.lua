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
	self.packageName = "daigoutui"
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
	elseif(obj.name == "BtnShare") then
		ModuleCache.ShareManager().shareImage(false)
	end
end

function OneGameResultModule:on_press(obj, arg)
	if(obj.name == 'showTableMask')then
		ModuleCache.ComponentManager.SafeSetActive(self.view.goRoot.gameObject, false)
		ModuleCache.ComponentManager.SafeSetActive(self.view.goBottom.gameObject, false)
	end
end

function OneGameResultModule:on_press_up(obj, arg)
	ModuleCache.ComponentManager.SafeSetActive(self.view.goRoot.gameObject, true)
	ModuleCache.ComponentManager.SafeSetActive(self.view.goBottom.gameObject, true)
end

function OneGameResultModule:on_show(result)
	
	-- local result = {}
	-- result.roomInfo = {
	-- 	roomNum=122222,
	-- 	curRoundNum = 1,
	-- 	totalRoundCount = 10,
	-- 	base_score = 100,
	-- 	multiple = 2,
	-- }
	-- result.startTime = os.time()
	-- result.endTime = os.time() + 100000
	-- result.myPlayerId = 101
	-- result.players = {}
	-- for i=1,5 do
	-- 	local player = {}
	-- 	player.playerId = 100 + i
	-- 	player.playerName = 'helo'..i
	-- 	player.score = i > 1 and 0 or i
	-- 	player.bond_score = i
	-- 	player.cards = {}
	-- 	if(i == 1)then
	-- 		player.isRoomCreator = true
	-- 		player.isLord = true
	-- 	end
	-- 	if(i == 2)then
	-- 		player.isServant = true
	-- 	end
	-- 	result.players[i] = player
	-- end
	
	self.view:refresh_view(result)
end


return  OneGameResultModule