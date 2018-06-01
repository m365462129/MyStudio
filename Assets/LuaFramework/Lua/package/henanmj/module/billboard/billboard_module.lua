-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local BillBoardModule = class("BullFight.BillBoardModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache


function BillBoardModule:initialize(...)
	-- 开始初始化                view        model           模块数据
	ModuleBase.initialize(self, "billBoard_view", nil, ...)
end


function BillBoardModule:on_show(content)
	self.billBoardView:initBillBoardText(content)
	self.view:refreshPlayMode()
end


function BillBoardModule:on_click(obj, arg)	
	print_debug(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.billBoardView.buttonClose.gameObject then
		--ModuleCache.ModuleManager.destroy_module("henanmj", "billboard")
		ModuleCache.ModuleManager.hide_module("henanmj", "billboard")			
	end
end


return BillBoardModule



