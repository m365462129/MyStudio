-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
-- ==========================================================================
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath


local TableResult_BasePanel = require("package.shisanzhang.module.tableresult.game.tableresult_base_panel")
local TableResult_BiJiPanel = Class("tableResult_BiJiPanel", TableResult_BasePanel)

function TableResult_BiJiPanel:initialize(module)
    TableResult_BasePanel.initialize(self, module)
end

function TableResult_BiJiPanel:initPanel()
    TableResult_BasePanel.initPanel(self)
    
    self.prefabItem = GetComponentWithPath(self.view.root, "Holder/BiJiItem", ComponentTypeName.Transform).gameObject
end

function TableResult_BiJiPanel:refreshPanel(data, maxScore,dissolverId)
    TableResult_BasePanel.refreshPanel(self, data, maxScore,dissolverId)
end

function TableResult_BiJiPanel:fillItem(item, playerResult,roomInfo,dissolverId)
    TableResult_BasePanel.fillItem(self, item, playerResult,roomInfo,dissolverId)

    if  roomInfo.ruleTable.balance == 6 then
        if self.module.shisanzhang_gametype == 2 then
            GetComponentWithPath(item, "DetailScore/SpadeATimes", ComponentTypeName.Transform).gameObject:SetActive(true)
            GetComponentWithPath(item, "DetailScore/SpadeATimes/value", ComponentTypeName.Text).text = playerResult.spadeACount .. ""

            GetComponentWithPath(item, "DetailScore/SoloKillTimes", ComponentTypeName.Transform).gameObject:SetActive(true)
            GetComponentWithPath(item, "DetailScore/SoloKillTimes/value", ComponentTypeName.Text).text = playerResult.soloKillCount .. ""

            GetComponentWithPath(item, "DetailScore/AllKillTimes", ComponentTypeName.Transform).gameObject:SetActive(true)
            GetComponentWithPath(item, "DetailScore/AllKillTimes/value", ComponentTypeName.Text).text = playerResult.allKillCount .. ""  or "0"
        end
    elseif(roomInfo.ruleTable.balance == 5 or roomInfo.ruleTable.balance == 3) then
        GetComponentWithPath(item, "DetailScore/SpadeATimes", ComponentTypeName.Transform).gameObject:SetActive(true)
        GetComponentWithPath(item, "DetailScore/SoloKillTimes", ComponentTypeName.Transform).gameObject:SetActive(false)
        if self.module.shisanzhang_gametype == 2 then
            GetComponentWithPath(item, "DetailScore/AllKillTimes", ComponentTypeName.Transform).gameObject:SetActive(true)
            GetComponentWithPath(item, "DetailScore/AllKillTimes/value", ComponentTypeName.Text).text = playerResult.allKillCount .. ""  or "0"
        end

        GetComponentWithPath(item, "DetailScore/SpadeATimes/value", ComponentTypeName.Text).text = playerResult.spadeACount .. ""
    else
        GetComponentWithPath(item, "DetailScore/SpadeATimes", ComponentTypeName.Transform).gameObject:SetActive(false)
        GetComponentWithPath(item, "DetailScore/SoloKillTimes", ComponentTypeName.Transform).gameObject:SetActive(true)
        GetComponentWithPath(item, "DetailScore/AllKillTimes", ComponentTypeName.Transform).gameObject:SetActive(true)
        GetComponentWithPath(item, "DetailScore/SoloKillTimes/value", ComponentTypeName.Text).text = playerResult.soloKillCount .. ""
        GetComponentWithPath(item, "DetailScore/AllKillTimes/value", ComponentTypeName.Text).text = playerResult.allKillCount .. ""
    end
    GetComponentWithPath(item, "DetailScore/WinFirstTimes/value", ComponentTypeName.Text).text = playerResult.paiWinCount[1] .. ""
    GetComponentWithPath(item, "DetailScore/WinMidTimes/value", ComponentTypeName.Text).text = playerResult.paiWinCount[2] .. ""
    GetComponentWithPath(item, "DetailScore/WinLastTimes/value", ComponentTypeName.Text).text = playerResult.paiWinCount[3] .. ""
    GetComponentWithPath(item, "DetailScore/XiPaiTimes/value", ComponentTypeName.Text).text = playerResult.xipaiCount  .. ""
    
    
end

return TableResult_BiJiPanel