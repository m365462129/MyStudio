---
--- Created by apple.
--- DateTime: 2018/1/10 上午11:53
---
local ParamBase = require("manager.jmessage.msg_param_base")
---@class ParamVoice : ParamBase
local ParamVoice= ParamBase:new()

function ParamVoice:new()

    local self = {}

    setmetatable( self , {__index = ParamVoice})

    self.voicePath = ""
    self.voiceSize = 0
    self.voiceTime = 0

    return self
end
return ParamVoice