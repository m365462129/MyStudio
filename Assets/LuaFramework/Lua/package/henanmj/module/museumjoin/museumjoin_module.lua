-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MuseumJoinModule = class("museumJoinModule", ModuleBase)
local GameManager = ModuleCache.GameManager
-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local PlayerPrefs = UnityEngine.PlayerPrefs


function MuseumJoinModule:initialize(...)
	ModuleBase.initialize(self, "museumjoin_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function MuseumJoinModule:on_module_inited()		
	
end



-- 绑定module层的交互事件
function MuseumJoinModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function MuseumJoinModule:on_model_event_bind()
	
end

function MuseumJoinModule:on_show(parlorNum)
	 self.parlorNum = parlorNum
end

function MuseumJoinModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj.name == "ButtonCancel" then
		ModuleCache.ModuleManager.hide_module("henanmj", "museumjoin")
	elseif(obj.name == "ButtonConfirm") then
		self:join_museum(self.parlorNum) 
	end
end

function MuseumJoinModule:join_museum(parlorNum)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/applyMember?",
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = parlorNum
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("申请成功，请等待馆主审核", function ()
				self:dispatch_module_event("chessmuseum", "Event_Update_OneChessMuseum")
				ModuleCache.ModuleManager.hide_module("henanmj", "museumjoin")
			end)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
			ModuleCache.ModuleManager.hide_module("henanmj", "museumjoin")
		end
	end, function(wwwErrorData)
		ModuleCache.ModuleManager.hide_module("henanmj", "museumjoin")
        print(wwwErrorData.error)
	end)
end


return MuseumJoinModule



