-- UICreator 自动生成
-- 层级调整请改变 View.initialize(self, value1, value2, value3) 的Value3
-- 若是特殊UI，请自行调整

-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local GoldStoreView = Class('goldStoreView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function GoldStoreView:initialize(...)
    -- 初始View 
    View.initialize(self, "public/module/goldstore/public_windowgoldstore.prefab", "Public_WindowGoldStore", 1)
    GoldStoreView.set_1080p(self)
    -- buttons
    self.btnClose     =  GetComponentWithPath(self.root, "Title/closeBtn",                    ComponentTypeName.Button)
    self.btnIn        =  GetComponentWithPath(self.root, "Center/Selector/Button1",           ComponentTypeName.Button)
    self.btnOut       =  GetComponentWithPath(self.root, "Center/Selector/Button2",           ComponentTypeName.Button)
    self.btnStoreIn   =  GetComponentWithPath(self.root, "Center/Panels/GoldIn/InBtn",        ComponentTypeName.Button)
    self.btnStoreout  =  GetComponentWithPath(self.root, "Center/Panels/GoldOut/OutBtn",      ComponentTypeName.Button)
    self.btnInMax     =  GetComponentWithPath(self.root, "Center/Panels/GoldIn/InMaxBtn",     ComponentTypeName.Button)
    self.btnOutMax    =  GetComponentWithPath(self.root, "Center/Panels/GoldOut/OutMaxBtn",   ComponentTypeName.Button)

    -- inputs
    self.inputIn      =  GetComponentWithPath(self.root, "Center/Panels/GoldIn/InGoldInput",  ComponentTypeName.InputField)
    self.inputOut     =  GetComponentWithPath(self.root, "Center/Panels/GoldOut/OutGoldInput",ComponentTypeName.InputField)

    -- roomCards
    self.goldTextNum  =  GetComponentWithPath(self.root, "Center/Infos/GoldCard/TextNum",     ComponentTypeName.Text)
    self.storeTextNum =  GetComponentWithPath(self.root, "Center/Infos/StoreCard/TextNum",    ComponentTypeName.Text)

    -- ui state
    self.uiState      = GetComponentWithPath(self.root, "Center",                             "UIStateSwitcher")

    -- main
    self.center       = GetComponentWithPath(self.root, "Center",                             ComponentTypeName.Transform).gameObject
    self:hideMain()
end

function GoldStoreView:hideMain()
    ComponentUtil.SafeSetActive(self.center, false)
end

function GoldStoreView:showUI(curPage)
    local showName = "In"
    if curPage ~= 1 then
        showName = "Out"
    end
    self.inputIn.text = ""
    self.inputOut.text = ""
    self.uiState:SwitchState(showName)
    ComponentUtil.SafeSetActive(self.center, true)
end

function GoldStoreView:refreshInfos(goldData)
    self.goldTextNum.text = goldData.goldAmount
    self.storeTextNum.text = goldData.coffersAmount
end

return GoldStoreView