---
--- Created by apple.
--- DateTime: 2018/1/10 上午11:53
---
local ParamBase = require("manager.jmessage.msg_param_base")
---@class ParamFile : ParamBase
local ParamFile= ParamBase:new()

function ParamFile:new()

    local self = {}

    setmetatable( self , {__index = ParamFile})

    self.filePath = ""
    self.fileSize = 0
    self.fileExten = ""

    return self
end
return ParamFile