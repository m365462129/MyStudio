--- 三公战绩详情 model
--- Created by 袁海洲
--- DateTime: 2017/12/7 10:56
---
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