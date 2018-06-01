---
--- Created by ju.
--- DateTime: 2017/10/30 10:47
---

--- @class PlaybackView

local ViewBase = require("core.mvvm.view_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")

local PlaybackView = Class("HuaPai.PlaybackView", ViewBase)

local AssetBundleName = "huapai/module/playback/paohuzi_playback.prefab"
local AssetName = "PaoHuZi_Playback"

function PlaybackView:initialize(...)
    ViewBase.initialize(self, AssetBundleName, AssetName, 2)

    self.btnPlay = Manager.GetButton(self.root, "Play")
    self.btnPause = Manager.GetButton(self.root, "Pause")
end

return PlaybackView