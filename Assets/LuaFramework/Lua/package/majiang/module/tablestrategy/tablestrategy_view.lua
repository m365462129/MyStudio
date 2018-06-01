-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableStrategyView = Class('tableStrategyView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function TableStrategyView:initialize(...)
    -- 初始View
    View.initialize(self, "majiang/module/tablestrategy/henanmj_tablestrategy.prefab", "HeNanMJ_TableStrategy", 1)
    self.selectObj = GetComponentWithPath(self.root, "Center/Panel/Selects", ComponentTypeName.Transform).gameObject
    self.diTuoToggle = {}
    self.diTuoToggle[1] = GetComponentWithPath(self.selectObj, "DiTuo/Image/DiTuo", ComponentTypeName.Toggle)
    self.diceToggle = {}
    self.diceToggle[1] = GetComponentWithPath(self.selectObj, "ResetDice/ResetDice", ComponentTypeName.Toggle)
    self.frontToggle = {}
    self.frontToggle[1] = GetComponentWithPath(self.selectObj, "Image/FrontPiao/10", ComponentTypeName.Toggle)
    self.frontToggle[2] = GetComponentWithPath(self.selectObj, "Image/FrontPiao/20", ComponentTypeName.Toggle)
    self.backToggle = {}
    self.backToggle[1] = GetComponentWithPath(self.selectObj, "Image/BackPiao/10", ComponentTypeName.Toggle)
    self.backToggle[2] = GetComponentWithPath(self.selectObj, "Image/BackPiao/20", ComponentTypeName.Toggle)
    self.toggles = {}
    table.insert(self.toggles, self.diTuoToggle)
    table.insert(self.toggles, self.diceToggle)
    table.insert(self.toggles, self.frontToggle)
    table.insert(self.toggles, self.backToggle)
    self.textTimeDown = GetComponentWithPath(self.root, "Center/Panel/Text", ComponentTypeName.Text)
    self.diTuo = GetComponentWithPath(self.root, "Center/Panel/Selects/DiTuo/Image/DiTuo/textTitle", ComponentTypeName.Text)
end

function TableStrategyView:refresh_dice_toggle()
    self.diceToggle[1].interactable = self.diTuoToggle[1].isOn
    local selectObj = GetComponentWithPath(self.diceToggle[1].gameObject, "bg/select", ComponentTypeName.Image).gameObject
    local grayObj = GetComponentWithPath(self.diceToggle[1].gameObject, "bg/gray", ComponentTypeName.Image).gameObject
    ComponentUtil.SafeSetActive(selectObj, self.diTuoToggle[1].isOn)
    ComponentUtil.SafeSetActive(grayObj, not self.diTuoToggle[1].isOn)
end

function TableStrategyView:update_beat(timeDown)
    self.textTimeDown.text =  string.format("等待其他玩家选择，<color=#b13a1f><size=30>%s</size></color> 秒后自动开始", timeDown)
end

function TableStrategyView:get_send_data()
    local sendData = {}
    sendData.DiTuo = self.diTuoToggle[1].isOn
    sendData.xiaojiScore = 0
    sendData.paoScore = 0
    if(self.frontToggle[1].isOn) then 
        sendData.xiaojiScore = 10
    elseif(self.frontToggle[2].isOn) then 
        sendData.xiaojiScore = 20
    end
    if(self.backToggle[1].isOn) then 
        sendData.paoScore = 10
    elseif(self.backToggle[2].isOn) then 
        sendData.paoScore = 20
    end
    return sendData
end

return TableStrategyView