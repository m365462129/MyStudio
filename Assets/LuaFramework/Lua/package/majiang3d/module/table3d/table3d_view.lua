--- 3D麻将 view
--- Created by 袁海洲
--- DateTime: 2017/12/25 14:18
---
local class = require("lib.middleclass")
local ViewBaseBase = require('package.majiang.module.tablebase.tablebase_view')
local ViewBase = require('package.majiang.module.tablenew.table_view') ---继承于2D麻将桌面
--- @class Table3dView:TableMJView
local Table3dView = class('table3dView', ViewBase)
local TableManager = TableManager


function Table3dView:on_initialize(prefabPath, prefabName, layer)
    ViewBaseBase.initialize(self, "majiang3d/module/table3d/mj_table3d.prefab", "MJ_Table3D", layer, true)
end

function Table3dView:init_play_mode()
    if(TableManager:cur_game_is_gold_room_type()) then
        self.roomType = require('package.majiang3d.module.table3d.roomtype.table3d_type_gold'):new(self)
        ---模式 正常 回放
        if(not self.curTableData.isPlayBack) then
            ---@type TableCustom
            self.playType = require('package.majiang.module.tablenew.playtype.table_custom'):new(self)
        else
            self.playType = require('package.majiang.module.tablenew.playtype.table_playback'):new(self)
        end
    else
        ViewBase.init_play_mode(self)
    end
end

return Table3dView
