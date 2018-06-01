-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local BindInviteCodeView = Class('bindInviteCodeView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function BindInviteCodeView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/bindinvitecode/henanmj_windowbindinvitecode.prefab", "HeNanMJ_WindowBindInviteCode", 1)

    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

    self.buttonCancel = GetComponentWithPath(self.root, "Center/Buttons/CancelBtn", ComponentTypeName.Button)
    self.buttonConfirm = GetComponentWithPath(self.root, "Center/Buttons/ConfirmBtn", ComponentTypeName.Button)

    self.inputfieldInviteCode = GetComponentWithPath(self.root, "Center/InputField", ComponentTypeName.InputField)
    self.textAdContent = GetComponentWithPath(self.root, "Center/AdContent/Text", ComponentTypeName.Text)
end

function BindInviteCodeView:on_view_init()
    self:refreshAdContent("")    
end


function BindInviteCodeView:refreshAdContent(adContent)
    self.textAdContent.text = adContent
end

return BindInviteCodeView