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
	self.packageName = "doudizhu"
	self.moduleName = "onegameresult"
end


function OneGameResultModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if(self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup)then
		return
	end
	if(obj.name == "BtnRestart" or obj.name == 'ButtonReady') then
		ModuleCache.ModuleManager.destroy_module(self.packageName, self.moduleName)
		self:dispatch_module_event(self.moduleName, "Event_continue_game")
	elseif(obj.name == "BtnShare") then
		ModuleCache.ShareManager().shareImage(false)
	elseif(obj.name == "ButtonBack") then
		ModuleCache.ModuleManager.destroy_module(self.packageName, self.moduleName)
	end
end

function OneGameResultModule:on_show(result)
	
	 --local result = {}
	 --result.roomInfo = {
	 --	roomNum=122222,
	 --	curRoundNum = 1,
	 --	totalRoundCount = 10,
     --
	 --}
	 --result.startTime = os.time()
	 --result.endTime = os.time() + 100000
	 --result.myPlayerId = 101
	 --result.players = {}
	 --for i=1,4 do
	 --	local player = {}
	 --	player.playerId = 100 + i
	 --	player.playerName = 'helo'..i
	 --	player.spring = true
	 --	player.show_cards = true
	 --	player.score = i > 1 and 0 or i
	 --	player.bombCount = i
		-- player.multiple = i
	 --	player.cards = {}
	 --	for j=1,10 do
	 --		player.cards[j] = j
	 --	end
		-- player.played_cards = {}
		-- for i = 1, 10 do
		--	 player.played_cards[i] = {}
		--	 for j = 1, 1 do
		--		 player.played_cards[i][j] = i + j
		--	 end
		-- end
     --
	 --	result.players[i] = player
	 --end
	
	self.view:refresh_view(result)
end


return  OneGameResultModule