
--- 血战到底
local class = require("lib.middleclass")
local Base = require('package.majiangshanxi.module.tablenew.view.tablexueliuchenghe_view')
---@class TableXueZhanDaoDiView:TableXueLiuChengHeView
local TableXueZhanDaoDiView = class('tableXueZhanDaoDiView', Base)
local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local TableUtil = TableUtil

function TableXueZhanDaoDiView:on_init_ui()
    self.bigHuaSwitchState:SwitchState("Normal")
    self.actionNang = GetComponentWithPath(self.waitAction, "Button_Nang", ComponentTypeName.Transform).gameObject
end

---获取操作的特效
function TableXueZhanDaoDiView:get_action_tx(action)
    if(not self.curTableData.isPlayBack and action == self.actions.pass) then
        return 0
    end
    return action
end

---可听
function TableXueZhanDaoDiView:show_ke_ting(show)
    if(#self.gameState.Dun <= 10) then
        return
    end
    self.actionNang:SetActive(show)
    if(show) then
        self:show_wait_action()
    end
end

--- 可以显示过
function TableXueZhanDaoDiView:can_show_guo()
    return not (self.actionHu.activeSelf and #self.gameState.Dun <= 10)
end

return  TableXueZhanDaoDiView