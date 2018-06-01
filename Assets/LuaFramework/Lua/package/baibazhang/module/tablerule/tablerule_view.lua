-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableRuleView = Class('tableRuleView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath

function TableRuleView:initialize(...)
    -- 初始View
    View.initialize(self, "biji/module/tablerule/bullfight_tablerule.prefab", "BiJi_TableRule", 1)

    self.buttonClose = GetComponentWithPath(self.root, "Center/Child/ImageBack", ComponentTypeName.Button)
    self.panels = GetComponentWithPath(self.root, "Top/Child/Panels", ComponentTypeName.Transform).gameObject
    self.panelChilds = TableUtil.get_all_child(self.panels)

    self.titleTex = GetComponentWithPath(self.root,"Center/Child/Title/bg/Text",ComponentTypeName.Text)
    
    --比鸡开始--
    self.bijiTable = {};
    local goBiJiPanel = ModuleCache.ComponentUtil.Find(self.root, "Top/Child/Panels/BiJiPanel/BiJiPanel/Selects")
    self.bijiTable.buttonNomalModeTips = GetComponentWithPath(goBiJiPanel, "XipaiSelect/Selects/Normal/bg/Tips/btn", ComponentTypeName.Button)
    self.bijiTable.buttonCertainModeTips = GetComponentWithPath(goBiJiPanel, "XipaiSelect/Selects/Certain/bg/Tips/btn", ComponentTypeName.Button)

    self.normalModeTips = GetComponentWithPath(goBiJiPanel, "XipaiSelect/Selects/Normal/bg/Tips/tip", ComponentTypeName.Transform).gameObject
    self.certainModeTips = GetComponentWithPath(goBiJiPanel, "XipaiSelect/Selects/Certain/bg/Tips/tip", ComponentTypeName.Transform).gameObject
    self.normalModeNewTips = GetComponentWithPath(goBiJiPanel, "XipaiSelect/Selects/Normal/bg/Tips/tipNew", ComponentTypeName.Transform).gameObject
    self.certainModeNewTips = GetComponentWithPath(goBiJiPanel, "XipaiSelect/Selects/Certain/bg/Tips/tipNew", ComponentTypeName.Transform).gameObject
    self.roundSelector = {};
    self.roundSelector.toggeleEight = GetComponentWithPath(goBiJiPanel,"RoundCountSelect/Selects/Round8",ComponentTypeName.Toggle);
    self.roundSelector.toggeleSixteen = GetComponentWithPath(goBiJiPanel,"RoundCountSelect/Selects/Round16",ComponentTypeName.Toggle);
    self.roundSelector.toggeleTwentyFourteen = GetComponentWithPath(goBiJiPanel,"RoundCountSelect/Selects/Round24",ComponentTypeName.Toggle);
    self.hasKingSelector = {};
    self.hasKingSelector.toggleNoKing = GetComponentWithPath(goBiJiPanel, "HasKingSelect/Selects/NoKing", ComponentTypeName.Toggle)
    self.hasKingSelector.toggleDoubleKing = GetComponentWithPath(goBiJiPanel, "HasKingSelect/Selects/DoubleKing", ComponentTypeName.Toggle)
    self.xipaiMode = {};
    self.xipaiMode.toggeleNormal = GetComponentWithPath(goBiJiPanel,"XipaiSelect/Selects/Normal",ComponentTypeName.Toggle);
    self.xipaiMode.toggeleCertain = GetComponentWithPath(goBiJiPanel,"XipaiSelect/Selects/Certain",ComponentTypeName.Toggle);
    self.xipaiMode.normalText = GetComponentWithPath(goBiJiPanel,"XipaiSelect/Selects/Normal/bg/Tips/tip/Text",ComponentTypeName.Text)
    self.xipaiMode.certainText = GetComponentWithPath(goBiJiPanel,"XipaiSelect/Selects/Certain/bg/Tips/tip/Text",ComponentTypeName.Text)
    self.xipaiMode.normalNewText = GetComponentWithPath(goBiJiPanel,"XipaiSelect/Selects/Normal/bg/Tips/tipNew/Text",ComponentTypeName.Text)
    self.xipaiMode.certainNewText = GetComponentWithPath(goBiJiPanel,"XipaiSelect/Selects/Certain/bg/Tips/tipNew/Text",ComponentTypeName.Text)
    self.scoreMode = {};
    self.scoreMode.toggeleNormal = GetComponentWithPath(goBiJiPanel,"ScoreSelect/Selects/Normal",ComponentTypeName.Toggle);
    self.scoreMode.toggeleCertain = GetComponentWithPath(goBiJiPanel,"ScoreSelect/Selects/Certain",ComponentTypeName.Toggle);
    self.payMode = {};
    self.payMode.toggeleAA = GetComponentWithPath(self.root,"Top/Child/Panels/PayType/PaySelect/Selects/AAPay",ComponentTypeName.Toggle);
    self.payMode.toggeleCreator = GetComponentWithPath(self.root,"Top/Child/Panels/PayType/PaySelect/Selects/CreatorPay",ComponentTypeName.Toggle);
    self.payMode.toggeleWinner = GetComponentWithPath(self.root,"Top/Child/Panels/PayType/PaySelect/Selects/WinnerPay",ComponentTypeName.Toggle);
    self.pokersNumber = {};
    self.pokersNumber.toggleNine = GetComponentWithPath(goBiJiPanel,"PokersNumberSelect/Selects/9Pokers",ComponentTypeName.Toggle);
    self.pokersNumber.toggleTen = GetComponentWithPath(goBiJiPanel,"PokersNumberSelect/Selects/10Pokers",ComponentTypeName.Toggle);
    self.halfEnterSelector = {}
    self.halfEnterSelector.toggleNoHalfEnter = GetComponentWithPath(goBiJiPanel, "HelfEnterSelect/Selects/NoHalfEnter", ComponentTypeName.Toggle)
    --self.bijiTable.goTips = GetComponentWithPath(goBiJiPanel, "Center/Panels/PublicPanel/Tips/tip", ComponentTypeName.Transform).gameObject
    --self.bijiTable.goTipsMask = GetComponentWithPath(goBiJiPanel, "TipMask", ComponentTypeName.Transform).gameObject
    --比鸡结束--

    self.payTypeObj = GetComponentWithPath(self.root, "Top/Child/Panels/PayType", ComponentTypeName.Transform).gameObject
    self.payTypeObj_museum = GetComponentWithPath(self.root, "Top/Child/Panels/PayType_museum", ComponentTypeName.Text)
end

return TableRuleView