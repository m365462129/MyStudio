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
	self.packageName = "wushik"
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
	
	 --local result = {}
	 --result.roomInfo = {
	 --	roomNum=122222,
	 --	curRoundNum = 1,
	 --	totalRoundCount = 10,
	 --}
	 --result.startTime = os.time()
	 --result.endTime = os.time() + 100000
	 --result.myPlayerId = 101
	 --result.players = {}
	 --for i=1,4 do
	 --	local player = {}
	 --	player.playerId = 100 + i
	 --	player.playerName = 'helo'..i
	 --	player.score = -2 + i
	 --	player.jianFen = i
		--player.teamJianFen = i
		--player.multiple = i
		--player.rank = 4 - i
	 --	player.cards = {}
	 --	if(i == 1)then
	 --		player.isRoomCreator = true
	 --		player.isBanker = true
	 --	end
     --
		--player.cards = {}
		--for j=1,10 do
		--	player.cards[j] = j
		--end
		--player.played_cards = {}
		--for i = 1, 3 do
		-- player.played_cards[i] = {}
		-- for j = 1, 3 do
		--	 player.played_cards[i][j] = i + j
		-- end
		--end
     --
	 --	result.players[i] = player
	 --end

	table.sort(result.players, function(p1, p2)
		if(p1.score == p2.score)then
			if(p1.rank == p2.rank)then
				return p1.playerId < p2.playerId
			end
			return p1.rank < p2.rank
		end
		return p1.score > p2.score
	end)
	self.view:refresh_view(result)
end


return  OneGameResultModule