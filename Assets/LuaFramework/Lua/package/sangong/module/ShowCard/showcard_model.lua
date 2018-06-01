--- 搓牌 model
--- Created by 袁海洲
--- DateTime: 2017/12/19 14:05
---
-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

--
local ShowCardModel = Class("ShowCardModel", Model)

function ShowCardModel:initialize(...)
    Model.initialize(self, ...)
end

return ShowCardModel