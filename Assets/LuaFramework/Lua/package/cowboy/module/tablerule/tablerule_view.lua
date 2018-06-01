
-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableRuleView = Class('tableRuleView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function TableRuleView:initialize(...)
    -- 初始View
    View.initialize(self, "cowboy/module/tablerule/cowboy_tablerule.prefab", "CowBoy_TableRule", 1)

    self.buttonClose     = GetComponentWithPath(self.root, "Center/Child/ImageBack", ComponentTypeName.Button)
    self.title           = GetComponentWithPath(self.root, "Center/Child/Title/bg/Text", ComponentTypeName.Text)
    self.uiStateSwitcher = GetComponentWithPath(self.root, "Top", "UIStateSwitcher")

    self.niuNiuPanel = ModuleCache.ComponentUtil.Find(self.root, "Top/Child/Panels/NiuNiu/Panel/Scroll View/Viewport/Content/Selects")
    self.zhaJinNiuPanel = ModuleCache.ComponentUtil.Find(self.root, "Top/Child/Panels/ZhaJinNiu/Panel/Selects")

    local niuNiuPanel = self.niuNiuPanel
    local zhaJinNiuPanel = self.zhaJinNiuPanel

    

    self.beiLvSelector = {};
    self.beiLvSelector.toggeleSmall = GetComponentWithPath(niuNiuPanel, "BeilvSelect/Selects/NoKing", ComponentTypeName.Toggle)
    self.beiLvSelector.toggeleBig = GetComponentWithPath(niuNiuPanel, "BeilvSelect/Selects/DoubleKing", ComponentTypeName.Toggle)

    
    self.zuozhuangSelector = {}
    self.zuozhuangSelector.toggle1 = GetComponentWithPath(niuNiuPanel, "ZuozhuangSelect/Selects/1", ComponentTypeName.Toggle)
    self.zuozhuangSelector.toggle2 = GetComponentWithPath(niuNiuPanel, "ZuozhuangSelect/Selects/2", ComponentTypeName.Toggle)
    self.zuozhuangSelector.toggle3 = GetComponentWithPath(niuNiuPanel, "ZuozhuangSelect/Selects/3", ComponentTypeName.Toggle)


    self.wanfaSelector = {}
    self.wanfaSelector.toggle1 = GetComponentWithPath(niuNiuPanel, "WanfaSelect/Selects/NoHalfEnter", ComponentTypeName.Toggle)
    self.wanfaSwitcher = {}
    self.wanfaSwitcher.swicher1 = GetComponentWithPath(niuNiuPanel, "WanfaSelect/Selects/NoHalfEnter", "UIStateSwitcher")

    self.yazhuSelector = {}
    self.yazhuSelector.toggle1 = GetComponentWithPath(zhaJinNiuPanel, "YaZhuSelect/Selects/1", ComponentTypeName.Toggle)
    self.yazhuSelector.toggle2 = GetComponentWithPath(zhaJinNiuPanel, "YaZhuSelect/Selects/2", ComponentTypeName.Toggle)


    self.paySelector = {}
    self.paySelector.toggle1 = GetComponentWithPath(self.root, "Top/Child/PayInfo/AA", ComponentTypeName.Toggle)
    self.paySelector.toggle2 = GetComponentWithPath(self.root, "Top/Child/PayInfo/master", ComponentTypeName.Toggle)
    self.paySelector.toggle3 = GetComponentWithPath(self.root, "Top/Child/PayInfo/bigWin", ComponentTypeName.Toggle)


end

function TableRuleView:initVie(rule)
    local ruleTable = rule.ruleInfo
    self.title.text = "极速牛仔"
    local panel = self.niuNiuPanel
    if(rule.name == "ZhaJinNiu") then
        self.title.text = "炸金牛"
        panel = self.zhaJinNiuPanel
    else
        if(ruleTable.bankerType == 0) then self.title.text = "轮流坐庄" end
        if(ruleTable.bankerType == 1) then self.title.text = "随机坐庄" end
        if(ruleTable.bankerType == 2) then self.title.text = "看牌抢庄" end
    end
    self.uiStateSwitcher:SwitchState(rule.name)
    
    self.roundSelector = {};
    self.huapaiiMode = {};
    self.roundSwitcher = {}
    self.huapaiiSwitcher = {}

    self.roundSelector.toggele10= GetComponentWithPath(panel,"RoundCountSelect/Selects/Round10",ComponentTypeName.Toggle);
    self.roundSelector.toggele20 = GetComponentWithPath(panel,"RoundCountSelect/Selects/Round20",ComponentTypeName.Toggle);
    self.roundSelector.toggele30 = GetComponentWithPath(panel,"RoundCountSelect/Selects/Round30",ComponentTypeName.Toggle);
    self.roundSelector.toggele8= GetComponentWithPath(panel,"RoundCountSelect/Selects/Round8",ComponentTypeName.Toggle);
    self.roundSelector.toggele16 = GetComponentWithPath(panel,"RoundCountSelect/Selects/Round16",ComponentTypeName.Toggle);


    
    self.huapaiiMode.toggeleHave = GetComponentWithPath(panel,"HuapaiSelect/Selects/Normal",ComponentTypeName.Toggle);
    self.huapaiiMode.toggeleNot= GetComponentWithPath(panel,"HuapaiSelect/Selects/Certain",ComponentTypeName.Toggle);
end

return TableRuleView