-- UICreator 自动生成
-- 层级调整请改变 View.initialize(self, value1, value2, value3) 的Value3
-- 若是特殊UI，请自行调整

-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local EnterGameDlgView = Class('enterGameDlgView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function EnterGameDlgView:initialize(...)
    -- 初始View 
    View.initialize(self, "public/module/entergamedlg/public_windowentergamedlg.prefab", "Public_WindowEnterGameDlg", 1)
    self.btnOK      = GetComponentWithPath(self.root, "Center/ButtonOK", ComponentTypeName.Button)
    self.btnCancel  = GetComponentWithPath(self.root, "Center/ButtonCancel", ComponentTypeName.Button)
    self.title      = GetComponentWithPath(self.root, "Center/Title/TextTitle", ComponentTypeName.Text)
    self.contentTxt = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content/TextItem", ComponentTypeName.Text)
end

return EnterGameDlgView