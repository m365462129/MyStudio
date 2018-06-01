--
-- User: dred
-- Date: 2016/12/6
-- Time: 10:37
-- 文字消息提示模块

local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local Time = Time

---@class NetPromptModule : ModuleBase
---@field view NetPromptView
local NetPromptModule = class("Public.NetPromptModule", ModuleBase)

local ModuleCache = ModuleCache

function NetPromptModule:initialize(...)
    -- 开始初始化
    ModuleBase.initialize(self, "netprompt_view", nil, ...)
end

function NetPromptModule:on_show(intentData)
    self._lastShowTime =  Time.realtimeSinceStartup
    self:clear_time_event()

    self._autoHideTimeEventId = self:subscibe_time_event(13):OnComplete( function(t)
        self:hide()
    end).id

    -- 如果立刻显示
    if intentData then
        self.view.imageDelay:SetActive(true)
    else
        self._delayShowTimeEventId = self:subscibe_time_event(0.1):OnComplete( function(t)
            self.view.imageDelay:SetActive(true)
        end).id
    end
end

function NetPromptModule:on_hide(intentData)
    self:clear_time_event()
    self.view.imageDelay:SetActive(false)
    --ModuleCache.Log.print(Time.realtimeSinceStartup - self._lastShowTime, "NetPromptModule:on_hide")
end

function NetPromptModule:clear_time_event()
    if (self._delayShowTimeEventId) then
        ModuleCache.CSmartTimer:Kill(self._delayShowTimeEventId)
        self._delayShowTimeEventId = nil
    end

    if (self._autoHideTimeEventId) then
        ModuleCache.CSmartTimer:Kill(self._autoHideTimeEventId)
        self._autoHideTimeEventId = nil
    end
end

function NetPromptModule:auto_hide_ui()

end

return NetPromptModule