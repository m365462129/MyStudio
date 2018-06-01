--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local class = require("lib.middleclass")
local View = require('package.public.module.table_video_player.base_table_video_player_view')
local DaiGouTuiTableVideoPlayerView = class('daiGouTuiTableVideoPlayerView', View)

function DaiGouTuiTableVideoPlayerView:initialize(...)
    View.initialize(self, "daigoutui/module/table/daigoutui_table_video_player.prefab", "DaiGouTui_Table_Video_Player", 2)
end

return  DaiGouTuiTableVideoPlayerView