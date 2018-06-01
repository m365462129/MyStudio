-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local PlayVideoView = Class('playVideoView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function PlayVideoView:initialize(...)
    -- 初始View
    View.initialize(self, "biji/module/playvideo/bullfight_windowplayvideo.prefab", "BullFight_WindowPlayVideo", 1)

    local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath    

    self.buttonCancel = GetComponentWithPath(self.root, "Center/Buttons/CancelBtn", ComponentTypeName.Button)
    self.buttonConfirm = GetComponentWithPath(self.root, "Center/Buttons/ConfirmBtn", ComponentTypeName.Button)

    self.inputfieldVideoId = GetComponentWithPath(self.root, "Center/InputField", ComponentTypeName.InputField)    
end

function PlayVideoView:on_view_init()
     
end


return PlayVideoView