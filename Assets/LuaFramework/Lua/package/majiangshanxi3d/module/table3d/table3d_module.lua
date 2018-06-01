--- 3D麻将 module
--- Created by 袁海洲
--- DateTime: 2017/12/25 14:17
---
local class = require("lib.middleclass")

local ModuleBaseBase = require('package.majiangshanxi.module.tablebase.tablebase_module')
local ModuleBase = require('package.majiangshanxi.module.tablenew.tablenew_module')
---@class Table3DModule:TableMJModule
local Table3DModule = class('table3dModule', ModuleBase) ---继承于2D麻将module

local Table3DEvent = require('package.majiangshanxi3d.module.table3D.table3d_event') ---3D事件系统
local Mj3dHelper = require("package.majiangshanxi3d.module.table3d.table3d_helper") ---3D麻将帮助类
local ApplicationEvent = ApplicationEvent

function Table3DModule:on_initialize(...)

    local config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))
    local wanfaType = Config.GetWanfaIdx(self.curTableData.ruleJsonInfo.GameType)
    if(wanfaType > #config.createRoomTable) then
        wanfaType = 1
    end
    self.ConfigData = config.createRoomTable[wanfaType]
    if(self.ConfigData.view) then
        ModuleBaseBase.initialize(self,"view."..self.ConfigData.view.."_3d","table3d_model",...)
    else
        ModuleBaseBase.initialize(self,"view.table3dcommon_view", "table3d_model",...)
    end
    if(self.ConfigData.controller) then
        self.controller = require('package.majiangshanxi.module.tablenew.controller.' .. self.ConfigData.controller):new(self)
    else
        self.controller = require('package.majiangshanxi.module.tablenew.controller.tablecommon_controller'):new(self)
    end

    Mj3dHelper:Init(self)  ---初始化帮助类
    self:init_3d_event()
    --self:set_next_state_delay_time(0.5) ---设置最小刷新间隔
end

function Table3DModule:init_3d_event()
    self.CheckOpen = false

    self.table3DEvent = Table3DEvent:Create(self.view.cam3d,8)
    self.table3DEvent:RegOnClick(self.onClick3d)
    self.table3DEvent:RegOnPress(self.onPress3d)
    self.table3DEvent:RegOnDrag(self.onDrag3d)
    self.table3DEvent:RegOnDrop(self.onDrop3d)

    self.myHandMj3DEvent = Table3DEvent:Create(self.view.myHandMjCam,9)

    self.onApplicationFocus = function (eventHead, eventData)
        self.table3DEvent:Check(false)  ---当程序获的焦点发生变化时，处理一次3D事件检测
    end
    ApplicationEvent.subscibe_app_focus_event(self.onApplicationFocus)

    self.view:init_my_seat_event()  ---初始化我自己桌位的事件
end

function Table3DModule:on_module_event_bind()
    self.packageName = "majiangshanxi"
    ModuleBase.on_module_event_bind(self)
end

---使用UI的弹起事件来触发3D事件的检测
function Table3DModule:on_press_up(obj, arg)
    ModuleBase.on_press_up(self,obj, arg)
    if self.CheckOpen then
        self.CheckOpen = false
        self.table3DEvent:Check(false)
        self.myHandMj3DEvent:Check(false)
    end
end
---使用UI的按下事件来触发3D事件的检测
function Table3DModule:on_press(obj, arg)
    ModuleBase.on_press(self,obj, arg)
    if obj == self.view.disRtObj then
        self.CheckOpen = true
        self.table3DEvent:Check(true)
        self.myHandMj3DEvent:Check(true)
    end
end
---使用UI的拖动事件来触发3D的拖动事件
function Table3DModule:on_drag(obj, arg)
    ModuleBase.on_drag(self,obj,arg)
    self.table3DEvent:updateDrag()
    self.myHandMj3DEvent:updateDrag()
end

function Table3DModule:on_begin_drag(obj, arg)

end

function Table3DModule:on_end_drag(obj, arg)

end

---3D按下弹起事件
function Table3DModule.onPress3d(obj,state)
    print("按下 ： "..obj.name)
end
---3D点击事件
function Table3DModule.onClick3d(obj)
    print("点击 ： "..obj.name)
end
---3D拖动事件
function Table3DModule.onDrag3d(obj)
    print("拖动 ： "..obj.name)
end
---3D拖放事件
function Table3DModule.onDrop3d(obj,targetObj)
    print("拖放 ： "..obj.name)
end

function Table3DModule:on_update()

end

function Table3DModule:on_begin_drag(obj, arg)

end

function Table3DModule:on_destroy()
    ApplicationEvent.unsubscibe_app_focus_event(self.onApplicationFocus)
end

return Table3DModule



