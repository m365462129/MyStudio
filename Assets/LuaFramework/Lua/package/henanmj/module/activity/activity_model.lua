-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

-- 
local ActivityModel = Class("activityModel", Model)

function ActivityModel:initialize(...)
    Model.initialize(self, ...)
end

function ActivityModel:init_view_data()

end

return ActivityModel