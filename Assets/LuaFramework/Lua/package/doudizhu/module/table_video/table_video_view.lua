--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--


local class = require("lib.middleclass")
local View = require('package.doudizhu.module.doudizhu_table.doudizhu_base_table_view')
local DouDiZhuTableVideoView = class('DouDiZhuTableVideoView', View)

function DouDiZhuTableVideoView:initialize(...)
    View.initialize(self, 'doudizhu/module/table/doudizhu_table_video.prefab', 'DouDiZhu_Table_Video', 1)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonMic.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonSetting.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChat.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonLocation.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingValue.transform.parent.gameObject, false)
end

return  DouDiZhuTableVideoView