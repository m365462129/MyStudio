--
-- Created by IntelliJ IDEA.
-- User: 朱腾芳
-- Date: 2017/10/9
-- Time: 16:18
-- To change this template use File | Settings | File Templates.
--

local class = require("lib.middleclass")
local ModelBase = require('package.paohuzi.module.tablebase.tablebase_model')

---@class PaoHuZiTableModel:TableBaseModel
local TableModel = class("PaoHuZi.TableModel", ModelBase)

function TableModel:initialize(...)
    ModelBase.initialize(self, ...)
end

return TableModel