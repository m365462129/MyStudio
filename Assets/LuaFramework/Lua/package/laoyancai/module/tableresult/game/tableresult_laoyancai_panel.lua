-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
-- ==========================================================================
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath


local TableResult_BasePanel = require("package.laoyancai.module.tableresult.game.tableresult_base_panel")
local TableResult_LaoYanCaiPanel = Class("tableResult_LaoYanCaiPanel", TableResult_BasePanel)

function TableResult_LaoYanCaiPanel:initialize(module)
    TableResult_BasePanel.initialize(self, module)
end

function TableResult_LaoYanCaiPanel:initPanel()
    TableResult_BasePanel.initPanel(self)
    
    self.prefabItem = GetComponentWithPath(self.view.root, "Holder/LaoYanCaiItem", ComponentTypeName.Transform).gameObject
end

function TableResult_LaoYanCaiPanel:refreshPanel(list, maxScore,dissolverId)
    TableResult_BasePanel.refreshPanel(self, list, maxScore,dissolverId)
end

function TableResult_LaoYanCaiPanel:fillItem(item, playerResult,dissolverId)
    TableResult_BasePanel.fillItem(self, item, playerResult,dissolverId)


    GetComponentWithPath(item, "DetailScore/SanPi/value", ComponentTypeName.Text).text = playerResult.timeSanPi .. ""
    GetComponentWithPath(item, "DetailScore/SanYan/value", ComponentTypeName.Text).text = playerResult.timeSanYan .. ""
    GetComponentWithPath(item, "DetailScore/ShuangYan/value", ComponentTypeName.Text).text = playerResult.timeShuangYan .. ""
    GetComponentWithPath(item, "DetailScore/ZhaKai/value", ComponentTypeName.Text).text = playerResult.timeZhaKai  .. ""

end

return TableResult_LaoYanCaiPanel