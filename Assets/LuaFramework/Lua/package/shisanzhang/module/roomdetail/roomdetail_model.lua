-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

-- 
local RoomDetailModel = Class("roomDetailModel", Model)

function RoomDetailModel:initialize(...)
    Model.initialize(self, ...)

end


return RoomDetailModel