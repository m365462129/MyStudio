---
--- Created by ju.
--- DateTime: 2017/10/30 10:47
---

--- @class PlaybackModule

local ModuleBase = require("core.mvvm.module_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")

local ModuleCache = ModuleCache

local PlaybackModule = Class("PaoHuZi.PlaybackModule", ModuleBase)

function PlaybackModule:initialize(...)
    ModuleBase.initialize(self, "playback_view", nil, ...)
end

function PlaybackModule:on_click(obj, arg)
    if not obj then
        return
    end
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")

    if obj.name == "Play" then
        self:dispatch_module_event("Playback", "Event_Playback_Play")
    elseif obj.name == "Pause" then
        self:dispatch_module_event("Playback", "Event_Playback_Pause")
    elseif obj.name == "Back" then
        self:dispatch_module_event("Playback", "Event_Playback_Back")
    elseif obj.name == "Front" then
        self:dispatch_module_event("Playback", "Event_Playback_Front")
    elseif obj.name == "Reset" then
        self:dispatch_module_event("Playback", "Event_Playback_Reset")
    elseif obj.name == "Exit" then
        self:dispatch_module_event("Playback", "Event_Playback_Exit")
    end
end

function PlaybackModule:show_btn_play(show)
    if not self.view then
        return
    end
    Manager.SetActive(self.view.btnPlay.gameObject, show)
    Manager.SetActive(self.view.btnPause.gameObject, not show)
end



return PlaybackModule