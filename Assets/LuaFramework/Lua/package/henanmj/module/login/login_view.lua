-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

---@class LoginView
local LoginView = Class('loginView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function LoginView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/login/henanmj_windowlogin.prefab", "HeNanMJ_WindowLogin", 0)
    self.goPannelTest = ModuleCache.ComponentUtil.Find(self.root, "PannelTest")

    self.inputAccount = GetComponentWithPath(self.root, "PannelTest/InputAccount", ComponentTypeName.InputField)
    self.toggleUseAccount = GetComponentWithPath(self.root, "PannelTest/ToggleUseAccount", ComponentTypeName.Toggle)
    self.textVersion = GetComponentWithPath(self.root, "TextVersion", ComponentTypeName.Text)
    self.toggleUserAgreement = GetComponentWithPath(self.root, "ToggleUserAgreement", ComponentTypeName.Toggle)
    
    self.buttonLogin = GetComponentWithPath(self.root, "ButtonLogin", ComponentTypeName.Button)
    self.buttonAnonymity = GetComponentWithPath(self.root, "ButtonAnonymity", ComponentTypeName.Button)

    self.textPlayMode = GetComponentWithPath(self.root, "BtnSetPlayMode/Text", ComponentTypeName.Text)

    self.goSetPlayMode = ModuleCache.ComponentUtil.Find(self.root, "BtnSetPlayMode")
    self.testPanel = GetComponentWithPath(self.root, "TestPanel",ComponentTypeName.Transform).gameObject
    self.testIdInput = GetComponentWithPath(self.root, "TestPanel/InputField",ComponentTypeName.InputField)

    self.goSetPlayMode:SetActive(false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonLogin.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonAnonymity.gameObject, false)

    if not ModuleCache.GameConfigProject.developmentMode then
        ModuleCache.ComponentUtil.SafeSetActive(self.testPanel, false)
    end
end

function LoginView:on_view_init() 
end

return LoginView