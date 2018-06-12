-- ========================== 默认依赖 =======================================
local class = require("lib.middleclass")
local ViewBase = require('core.mvvm.view_base')
-- ==========================================================================

---@class UpdateView : View
local UpdateView = class('updateView', ViewBase)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function UpdateView:initialize(...)
    -- 初始View
    ViewBase.initialize(self, "henanmj/module/update/henanmj_windowupdate.prefab", "HeNanMJ_WindowUpdate", 1)

    -- self.sliderProgress = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "Style1/Slider", ComponentTypeName.Slider)
    -- self.textInfo = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "Style1/Slider/TextInfo", ComponentTypeName.Text)
    self.textVersion = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "TextVersion", ComponentTypeName.Text)
    
    self.sliderProgress = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "Style2/Center/Slider", ComponentTypeName.Slider)
    self.textSliderInfo = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "Style2/Center/Slider/TextInfo", ComponentTypeName.Text)
    self.textInfo = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "Style2/Center/TipInfo", ComponentTypeName.Text)
    self.goButtonUpdateApkRetry = ModuleCache.ComponentUtil.Find(self.root, "Style2/Center/ButtonUpdateApkRetry")

    self:set_1080p()
--    self.toggleUseAccount = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "ToggleUseAccount", ComponentTypeName.Toggle)
--    self.textVersion = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "TextVersion", ComponentTypeName.Text)
end

function UpdateView:on_view_init()
end

return UpdateView