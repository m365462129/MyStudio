--- 3D麻将 view
--- Created by 袁海洲
--- DateTime: 2017/12/25 14:18
---
local class = require("lib.middleclass")
local ViewBaseBase = require('package.majiangshanxi.module.tablebase.tablebase_view')
local ViewBase = require('package.majiangshanxi.module.tablenew.table_view') ---继承于2D麻将桌面
--- @class Table3dView:TableMJView
local Table3dView = class('table3dView', ViewBase)

function Table3dView:on_initialize(prefabPath, prefabName, layer)
    ViewBaseBase.initialize(self, "majiangshanxi3d/module/table3d/mj_table3d.prefab", "MJ_Table3D", layer, true)
end

return Table3dView
