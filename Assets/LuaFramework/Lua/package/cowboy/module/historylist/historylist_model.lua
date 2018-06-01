-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

-- 
local HistoryListModel = Class("historyListModel", Model)

function HistoryListModel:initialize(...)
    Model.initialize(self, ...)
    print("1111")
    print("1111")
end


return HistoryListModel