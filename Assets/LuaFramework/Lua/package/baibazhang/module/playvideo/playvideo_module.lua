-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local PlayVideoModule = class("BullFight.PlayVideoModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function PlayVideoModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "playVideo_view", "playVideo_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function PlayVideoModule:on_module_inited()		
	
end


-- 绑定module层的交互事件
function PlayVideoModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function PlayVideoModule:on_model_event_bind()
	
end

function PlayVideoModule:on_show()

end


function PlayVideoModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.playVideoView.buttonCancel.gameObject then
		ModuleCache.ModuleManager.hide_module("biji", "playvideo")
		return
	elseif obj == self.playVideoView.buttonConfirm.gameObject then
		self:playVideo(self.playVideoView.inputfieldVideoId.text)
		return;
	end
end

function  PlayVideoModule:playVideo(strVideoId)
	if(strVideoId == "") then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码为空！，请填写正确的回放码")
		return
	else

	end
	
end




return PlayVideoModule



