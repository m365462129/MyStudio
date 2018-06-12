---
--- Created by Jyz.
--- DateTime: 2018/1/10 上午11:53
---
local ParamBase = require("manager.jmessage.msg_param_base")
---@class ParamImg : ParamBase
local ParamImg= ParamBase:new()

function ParamImg:new()

    local self = {}

    setmetatable( self , {__index = ParamImg})
    self.imgPath = ""
    self.imgSize = 0
    return self
end
return ParamImg