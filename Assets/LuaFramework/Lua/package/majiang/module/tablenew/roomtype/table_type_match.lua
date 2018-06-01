
--- 麻将模式(正常 比赛场 快速组局 金币场)
local class = require("lib.middleclass")
local Base = require('package.majiang.module.tablenew.roomtype.table_type_common')
---@class TableTypeMatch:TableTypeCommon
---@field view TableCommonView
local TableTypeMatch = class('tableTypeMatch', Base)
local ModuleCache = ModuleCache

function TableTypeMatch:on_initialize()
    ModuleCache.ModuleManager.show_module("majiang", "tablematch")
end

--- 开始刷新gameState
function TableTypeMatch:game_state_begin(gameState)
    self.view:begin_time_down(gameState.IntrustRestTime, function (t)
        self:show_time_down(t)
    end)
end

--- 显示局数
function TableTypeMatch:show_round(gameState)
    self.view.jushu.text = "第" .. gameState.CurRound .. "/" .. self.curTableData.RoundCount
    if(self.view.ConfigData.roundTitle and self.view.ruleJsonInfo.isDoubleQuan) then
        self.view.jushu.text = self.view.jushu.text .. self.view.ConfigData.roundTitle
    else
        self.view.jushu.text = self.view.jushu.text .. "局"
    end
end

return  TableTypeMatch