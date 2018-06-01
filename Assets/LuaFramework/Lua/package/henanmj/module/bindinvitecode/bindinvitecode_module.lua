-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local BindInviteCodeModule = class("BullFight.BindInviteCodeModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function BindInviteCodeModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "bindInviteCode_view", nil, ...)
	self.moduleName = "bindinvitecode"
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function BindInviteCodeModule:on_module_inited()		
	if((not self.bindInviteCodeModel.adContent) or self.bindInviteCodeModel.adContent == "") then
		self.bindInviteCodeModel:request_get_adcontent()
	end
end


-- 绑定module层的交互事件
function BindInviteCodeModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function BindInviteCodeModule:on_model_event_bind()

end

function BindInviteCodeModule:on_show()
	self.bindInviteCodeView.inputfieldInviteCode.text = ""
end


function BindInviteCodeModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("hennanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.bindInviteCodeView.buttonCancel.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "bindinvitecode")
		return
	elseif obj == self.bindInviteCodeView.buttonConfirm.gameObject then
		self:bindInviteCode(self.bindInviteCodeView.inputfieldInviteCode.text)		
		return;
	end
end

function  BindInviteCodeModule:bindInviteCode(strInviteCode)
	if(strInviteCode == "") then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("邀请码为空！，请填写正确的邀请码")
		return;
	end
	self.request_bind_invitecode(strInviteCode)
end

function  BindInviteCodeModule:request_bind_invitecode(inviteCode)
    local requestData = {
		params = {
			uid = self.modelData.roleData.userID,
		},
		showModuleNetprompt = true,
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/bind?",
	}
    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        print(www.text)
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
            self.modelData.roleData.coins = retData.data.coins
            self.modelData.roleData.hasBindInviteCode = true
			ModuleCache.ModuleManager.hide_module("henanmj", self.moduleName)
			ModuleCache.ModuleManager.show_module("henanmj", "shop")
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("绑定邀请码成功！")

            -- Model.dispatch_event(self, "Event_BindInviteCode_BindInviteCode", {data = retData.data})
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err)
        end
    end, function(error)
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(error.error)
    end)
end


return BindInviteCodeModule



