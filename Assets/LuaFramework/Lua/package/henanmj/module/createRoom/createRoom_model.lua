-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

-- 
local CreateRoomModel = Class("createRoomModel", Model)

function CreateRoomModel:initialize(...)
    Model.initialize(self, ...)

end



return CreateRoomModel