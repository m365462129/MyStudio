-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MuseumNoticeModule = class("museumNoticeModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine


function MuseumNoticeModule:initialize(...)
	ModuleBase.initialize(self, "museumnotice_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function MuseumNoticeModule:on_module_inited()		
	
end



-- 绑定module层的交互事件
function MuseumNoticeModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function MuseumNoticeModule:on_model_event_bind()
	
end

function MuseumNoticeModule:on_show(data)
	 self.view:update_view(data)
	 self.parlorNum = data.parlorNum
end


function MuseumNoticeModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj.name == "ButtonCancel" or obj.name == "BgMask" then
		ModuleCache.ModuleManager.hide_module("henanmj", "museumnotice")
	elseif(obj.name == "ButtonConfirm") then
		local data =
		{
			toNotice = true,
			showMsg = true,
			parlorNum = self.parlorNum,
			notice = self.view.inputFieldNotice.text
		}
		self:dispatch_module_event("chessmuseum", "Event_Update_Notice", data)
		ModuleCache.ModuleManager.hide_module("henanmj", "museumnotice")
	end
end




return MuseumNoticeModule



