-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local BiSaiView = Class('biSaiView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function BiSaiView:initialize(...)
    -- 初始View
    View.initialize(self, "public/module/bisai/public_windowbisai.prefab", "Public_WindowBiSai", 1)
    View.set_1080p(self)
    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath


    self.goldNum = GetComponentWithPath(self.root, "TopRight/Currency/Gold/TextNum", ComponentTypeName.Text)
    self.diamondNum = GetComponentWithPath(self.root, "TopRight/Currency/Gem/TextNum", ComponentTypeName.Text)

end

function BiSaiView:refreshPlayerInfo(roleData)
    if ((not roleData) or (not roleData.cards)) then
        return
    end
    self.diamondNum.text = Util.filterPlayerGoldNum(tonumber(roleData.cards) )
    if roleData.gold then
        self.goldNum.text = Util.filterPlayerGoldNum(roleData.gold)
    else
        self.goldNum.text = "0"
    end
end

return BiSaiView