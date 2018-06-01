-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MuseumJoinView = Class('museumJoinView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function MuseumJoinView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/museumjoin/henanmj_museumjoin.prefab", "HeNanMJ_MuseumJoin", 1)
    
end

return MuseumJoinView