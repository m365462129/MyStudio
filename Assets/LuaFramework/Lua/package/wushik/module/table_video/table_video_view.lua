--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath

local class = require("lib.middleclass")
local View = require('package.wushik.module.table.base_table_view')
---@class WuShiKTableVideoView:WuShiKTableBaseView
local WuShiKTableVideoView = class('WuShiKTableVideoView', View)

function WuShiKTableVideoView:initialize(...)
    View.initialize(self, 'wushik/module/table/wushik_table_video.prefab', 'WuShiK_Table_Video', 1)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonMic.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonSetting.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChat.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonLocation.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingValue.transform.parent.gameObject, false)

end

function WuShiKTableVideoView:setRoomInfo(roomNum, curRoundNum, totalRoundCount, wanfaName)
    self.textRoomNum.text = "房号:" .. roomNum
    self.textRoundNum.text = string.format('%s 第%d/%d局', wanfaName, curRoundNum, totalRoundCount)
    self.textRoundNum.gameObject:SetActive(true)
end

return  WuShiKTableVideoView