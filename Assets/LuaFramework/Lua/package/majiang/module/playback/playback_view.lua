-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local PlayBackView = Class('playBackView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function PlayBackView:initialize(...)
    -- 初始View
    View.initialize(self, "majiang/module/playback/henanmj_playback.prefab", "HeNanMJ_PlayBack", 1)
    self.ButtonExit = GetComponentWithPath(self.root, "TopRight/Child/ButtonExit", ComponentTypeName.Button).gameObject
    self.ButtonReset = GetComponentWithPath(self.root, "TopRight/Child/ButtonReset", ComponentTypeName.Button).gameObject
    self.ButtonPause = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonPause", ComponentTypeName.Button).gameObject
    self.ButtonUnPause = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonUnPause", ComponentTypeName.Button).gameObject
    self.ButtonFront = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonFront", ComponentTypeName.Button).gameObject
    self.ButtonBack = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonBack", ComponentTypeName.Button).gameObject
end

return PlayBackView