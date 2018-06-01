--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--
local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_video_player.base_table_video_player_module')
local WuShiKTableVideoPlayerModule = class('WuShiKTableVideoPlayerModule', ModuleBase)

function WuShiKTableVideoPlayerModule:initialize(...)
	ModuleBase.initialize(self, "table_video_player_view", nil, ...)
	self.packageName = "wushik"
	self.moduleName = "table_video_player"
end

return WuShiKTableVideoPlayerModule