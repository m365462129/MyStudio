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
    View.initialize(self, "henanmj/module/museumacc/henanmj_museumacc.prefab", "HeNanMJ_MuseumAcc", 1)
    View.set_1080p(self)

    self.powerNumTex = GetComponentWithPath(self.root, "Center/power/Text", ComponentTypeName.Text)
    self.cashNumTex = GetComponentWithPath(self.root, "Center/cash/Text", ComponentTypeName.Text)

    self.inputField_power = GetComponentWithPath(self.root, "Center/InputField_power", ComponentTypeName.InputField)
    self.inputField_cash = GetComponentWithPath(self.root, "Center/InputField_cash", ComponentTypeName.InputField)

    self.myPowerNumTex = GetComponentWithPath(self.root, "Center/BottomBar/powerBtn/Text", ComponentTypeName.Text)
    self.myCashNumTex = GetComponentWithPath(self.root, "Center/BottomBar/cashBtn/Text", ComponentTypeName.Text)
end

function MuseumNoticeView:update_museum_coins(data)
    self.powerNumTex.text ="剩余数量:".. Util.filterPlayerGoldNum(tonumber(data.coins))
    self.cashNumTex.text ="剩余数量:".. Util.filterPlayerGoldNum(tonumber(data.cards))

    self.inputField_power.text = ""
    self.inputField_cash.text = ""
end

function MuseumNoticeView:update_my_coins(data)
    self.myPowerNumTex.text = Util.filterPlayerGoldNum(tonumber(data.coins))
    self.myCashNumTex.text = Util.filterPlayerGoldNum(tonumber(data.cards))
end

return MuseumNoticeView