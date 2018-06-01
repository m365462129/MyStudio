-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local BillBoardView = Class('billBoardView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName



function BillBoardView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/billboard/henanmj_windowbillboard.prefab", "HeNanMJ_WindowBillBoard", 1)

    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    

    self.buttonClose = GetComponentWithPath(self.root, "Title/closeBtn", ComponentTypeName.Button)    
    self.textBillBoard = GetComponentWithPath(self.root, "Center/Panels/BillBoard/Text", ComponentTypeName.Text)    

end

function BillBoardView:initBillBoardText(content)
    self.textBillBoard.text = content
end

function BillBoardView:refreshPlayMode()
    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    local GetComponent = ModuleCache.ComponentManager.GetComponent
    local playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)
    local holder  = GetComponentWithPath(self.root, "BaseBackground/bg (1)", "SpriteHolder")
    local imageBg = GetComponent(holder.gameObject, ComponentTypeName.Image)
    self:SetImageSpriteByGameId(imageBg,holder,playMode.color)

    holder  = GetComponentWithPath(self.root, "Title/closeBtn", "SpriteHolder")
    local imageCloseBtnBg = GetComponent(holder.gameObject, ComponentTypeName.Image)
    self:SetImageSpriteByGameId(imageCloseBtnBg,holder,playMode.color)
end

return BillBoardView