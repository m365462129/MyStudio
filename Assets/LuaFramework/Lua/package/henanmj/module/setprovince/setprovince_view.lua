-- UICreator 自动生成
-- 层级调整请改变 View.initialize(self, value1, value2, value3) 的Value3
-- 若是特殊UI，请自行调整

-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
---@class SetProvinceView
local SetProvinceView = Class('setProvinceView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local configs = ModuleCache.PlayModeUtil.provinceConfig
local tween = nil


function SetProvinceView:initialize(...)
    -- 初始View 
    View.initialize(self, "henanmj/module/setprovince/henanmj_windowsetprovince.prefab", "HeNanMJ_WindowSetProvince", 1)
    ---@field btnBack
    self.btnBack = GetComponentWithPath(self.root, "TopLeft/Child/ImageBack", ComponentTypeName.Button)
    ---@field btns
    self.btns = {}
    self.btnObjs = {}
    self.popBtns = {}
    self.btnImgs = {}
    self.tweenCtrs = {}
    for i = 1, #configs.provinceList do
        local province = configs.provinceList[i]
        self.btns[province.id] = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content/Item/"..province.btnName.."/"..province.btnName, ComponentTypeName.Button)
        self.btnObjs[province.id] = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content/Item/"..province.btnName, ComponentTypeName.Transform).gameObject
        self.btnImgs[province.id] = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content/Item/"..province.btnName.."/"..province.btnName, ComponentTypeName.Image)
        self.popBtns[province.id] = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content/Item/"..province.btnName.."/Pop",ComponentTypeName.Button)
        self.tweenCtrs[province.id] = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content/Item/"..province.btnName.."/Pop", "TweenButton")
        self.btnImgs[province.id].alphaHitTestMinimumThreshold = 0.01
        ModuleCache.ComponentUtil.SafeSetActive(self.btns[province.id].gameObject, configs.provinceList[i].isOpen)
        ModuleCache.ComponentUtil.SafeSetActive(self.popBtns[province.id].gameObject, configs.provinceList[i].isOpen)
    end

    self.scrollRect = GetComponentWithPath(self.root, "Center/Scroll View", ComponentTypeName.RectTransform).rect
    self.content = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content", ComponentTypeName.Transform)

    if(self.scrollRect.height < 800) then
        self.content.localPosition = Vector3.New(self.content.localPosition.x,350,self.content.localPosition.z)
    end

    -- print_table(self.tweenCtrs)
end

function SetProvinceView:tweenSelect()
    if ModuleCache.GameManager.curProvince == 0 then return end
    for k, v in ipairs(self.btns) do
        --print(self.btnObjs[k].name.." is show? "..tostring(self.btnObjs[k].activeSelf))
        if self.btnObjs[k].activeSelf then
            self.tweenCtrs[k].isNeedPopUp = k == ModuleCache.GameManager.curProvince
            self.tweenCtrs[k]:TweenPopUp()
        end
    end
end

return SetProvinceView