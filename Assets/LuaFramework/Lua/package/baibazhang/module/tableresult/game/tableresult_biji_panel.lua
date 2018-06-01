-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
-- ==========================================================================
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath


local TableResult_BasePanel = require("package.baibazhang.module.tableresult.game.tableresult_base_panel")
local TableResult_BiJiPanel = Class("tableResult_BiJiPanel", TableResult_BasePanel)

function TableResult_BiJiPanel:initialize(module)
    TableResult_BasePanel.initialize(self, module)
end

function TableResult_BiJiPanel:initPanel()
    TableResult_BasePanel.initPanel(self)
    
    self.prefabItem = GetComponentWithPath(self.view.root, "Holder/BiJiItem", ComponentTypeName.Transform).gameObject
end

function TableResult_BiJiPanel:refreshPanel(list, maxScore,dissolverId)
    TableResult_BasePanel.refreshPanel(self, list, maxScore,dissolverId)
end

function TableResult_BiJiPanel:fillItem(item, playerResult,dissolverId)
    TableResult_BasePanel.fillItem(self, item, playerResult,dissolverId)


    GetComponentWithPath(item, "DetailScore/WinFirstTimes/value", ComponentTypeName.Text).text = playerResult.paiWinCount[1] .. ""
    GetComponentWithPath(item, "DetailScore/WinMidTimes/value", ComponentTypeName.Text).text = playerResult.paiWinCount[2] .. ""
    GetComponentWithPath(item, "DetailScore/WinLastTimes/value", ComponentTypeName.Text).text = playerResult.paiWinCount[3] .. ""
    GetComponentWithPath(item, "DetailScore/XiPaiTimes/value", ComponentTypeName.Text).text = playerResult.xipaiCount  .. ""
    --GetComponentWithPath(item, "DetailScore/TongGuanTimes/value", ComponentTypeName.Text).text = playerResult.tongguanCount .. ""

end

return TableResult_BiJiPanel