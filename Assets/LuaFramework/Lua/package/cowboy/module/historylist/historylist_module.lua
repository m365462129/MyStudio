-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local HistoryListModule = class("CowBoy.HistoryListModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function HistoryListModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "historyList_view", "historyList_model", ...)
	self.historyListView:initLoopScrollViewList({})
	-- self:getRoomList()
end


function HistoryListModule:on_show(data)
	self.historyListView:initLoopScrollViewList(data)
end


function HistoryListModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.historyListView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("cowboy", "historylist")
		self:dispatch_package_event("Event_Show_Hall_Anim")
	elseif obj == self.historyListView.buttonCheckRoundVideo.gameObject then
		ModuleCache.ModuleManager.show_module("cowboy", "playvideo")
	elseif obj.transform.parent.parent.parent.gameObject == self.historyListView.loopScrollView.gameObject then
		local loopBaseNode = ModuleCache.ComponentManager.GetComponent(obj, "LoopBaseNode")
		local data = loopBaseNode.data		
		ModuleCache.ModuleManager.show_module("cowboy", "roomdetail", data)
	end
end


function HistoryListModule:on_begin_drag(obj, arg)	
	if(obj.transform.parent.name == "Content")then
		self.dragObj = obj
	end	
end

function HistoryListModule:on_end_drag(obj, arg)
	if(obj.transform.parent.name == "Content")then
		if(self.dragObj == obj)then
			if(self.historyListView.lastScrollValue and self.historyListView.lastScrollValue < 0)then

			end
		end
	end	
end



return HistoryListModule



