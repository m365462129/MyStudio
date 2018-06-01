-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local PlayerInfoModule = class("BullFight.PlayerInfoModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function PlayerInfoModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "PlayerInfo_view", nil, ...)
end


function PlayerInfoModule:on_show(playerInfo)
	self.playerInfoView:refreshView(playerInfo)
end


function PlayerInfoModule:on_click(obj, arg)	

	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.playerInfoView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("biji", "playerinfo")
		return
	end
end




return PlayerInfoModule



