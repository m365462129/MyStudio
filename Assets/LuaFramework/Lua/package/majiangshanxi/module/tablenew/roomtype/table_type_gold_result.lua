
--- 麻将模式(正常 比赛场 快速组局 金币场 金币结算)
local class = require("lib.middleclass")
local Base = require('package.majiangshanxi.module.tablenew.roomtype.table_type_gold')
---@class TableTypeGoldResult:TableTypeGold
---@field view TableCommonView
local TableTypeGoldResult = class('tableTypeGoldResult', Base)

return  TableTypeGoldResult