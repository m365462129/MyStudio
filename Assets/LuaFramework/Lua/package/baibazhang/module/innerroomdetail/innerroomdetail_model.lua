-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

-- 
local InnerRoomDetailModel = Class("innerRoomDetailModel", Model)

function InnerRoomDetailModel:initialize(...)
    Model.initialize(self, ...)

end


return InnerRoomDetailModel