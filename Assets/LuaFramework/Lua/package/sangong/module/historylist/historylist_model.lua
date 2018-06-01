--- 三公历史激励
--- Created by 袁海洲
--- DateTime: 2017/12/7 10:18
---
-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

--
local HistoryListModel = Class("historyListModel", Model)

function HistoryListModel:initialize(...)
    Model.initialize(self, ...)

end


return HistoryListModel