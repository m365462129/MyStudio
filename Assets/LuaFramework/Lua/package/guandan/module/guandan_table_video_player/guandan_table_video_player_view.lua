--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local class = require("lib.middleclass")
local View = require('package.public.module.table_video_player.base_table_video_player_view')
local GuanDanTableVideoPlayerView = class('guanDanTableVideoPlayerView', View)

function GuanDanTableVideoPlayerView:initialize(...)
    View.initialize(self, "guandan/module/table/guandan_table_video_player.prefab", "GuanDan_Table_Video_Player", 2)
end

return  GuanDanTableVideoPlayerView