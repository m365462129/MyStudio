-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MuseumNoticeView = Class('museumNoticeView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function MuseumNoticeView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/museumnotice/henanmj_museumnotice.prefab", "HeNanMJ_MuseumNotice", 1)
    self.inputFieldNotice = GetComponentWithPath(self.root, "Center/InputField", ComponentTypeName.InputField)
    self.textNotice = GetComponentWithPath(self.root, "Center/Custom/Text", ComponentTypeName.Text)
    self.UIStateSwitcher = ModuleCache.ComponentManager.GetComponent(self.root, "UIStateSwitcher")
end

function MuseumNoticeView:update_view(data)
    if(data.playerRole == "OWNER") then
        self.inputFieldNotice.text = data.notice
        self.UIStateSwitcher:SwitchState("Master")
    else
        self.textNotice.text = data.notice
        self.UIStateSwitcher:SwitchState("Custom")
    end
end

return MuseumNoticeView