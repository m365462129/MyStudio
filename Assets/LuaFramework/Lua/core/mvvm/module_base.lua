local require = require
local string = string
local type = type
local class = require("lib.middleclass")
local ModuleEventBase = require('core.mvvm.module_event_base')
local UnityEngine = UnityEngine

---@class ModuleBase : ModuleEventBase
---@class Module : ModuleEventBase
---@field view View
---@field modle Model
local Module = class('Module', ModuleEventBase)

local UpdateBeat = UpdateBeat
local Time = Time
local ApplicationEvent = ApplicationEvent

--@viewName 这里
function Module:initialize(viewName, modleName, packageModuleSimpleData, intentData)
    do
        self._initializeSucess = false
        ModuleEventBase.initialize(self)
        if self.moduleInitializeMonitoring then
            self._initializeSucessTimeEventId = self:subscibe_time_event(13, false, 1):OnComplete(function(t)
                if (not self._initializeSucess) and (not self.isDestroy) then
                    -- 如果监控到了模块初始化错误
                    ModuleCache.GameManager.reboot(true)
                end
            end)
        end

        self.packageName = packageModuleSimpleData.packageName
        self.moduleName = packageModuleSimpleData.moduleName
        local modelData
        modelData = require("package.henanmj.model.model_data")
        --dataConfig = require(modelPath .. ".model.data_config")

        self.modelData = modelData
        --self.dataConfig = dataConfig


        if viewName then
            self.view = require(string.format("%s.%s", packageModuleSimpleData.modulePath, viewName)):new(packageModuleSimpleData.packageName, packageModuleSimpleData.moduleName, intentData)
            if self.view.class.name then
                self[self.view.class.name] = self.view
            end


            self.view.modelData = modelData
            --self.view.dataConfig = dataConfig
            if self.on_view_inited then
                self:on_view_inited(intentData)
            end
        end

        if modleName then
            self.model = require(string.format("%s.%s", packageModuleSimpleData.modulePath, modleName)):new(packageModuleSimpleData.packageName, modelData)
            if self.model.class.name then
                self[self.model.class.name] = self.model
            end
            if self.on_model_inited then
                self:on_model_inited(intentData)
            end
            if self.on_model_event_bind then
                self:on_model_event_bind()
            end
        end

        if self.on_module_event_bind then
            self:on_module_event_bind()
        end
        if self.on_package_event_bind then
            self:on_package_event_bind()
        end
        --if self.on_update or self.on_update_per_second then
        --    self._addUpdateBeat = true
        --    UpdateBeat:Add(self._update, self)
        --end
        --
        --if self.on_update_per_second then
        --    self:on_update_per_second(intentData)
        --end

        self.onApplicaiontFocusProcessPressUp = function (eventHead, eventData)
            self:on_application_focus_process_pressData()
        end
        ApplicationEvent.subscibe_app_focus_event(self.onApplicaiontFocusProcessPressUp)
        self.curPressDatas = {}

        self._initializeSucess = true
    end
end


function Module:base_init_end(intentData)
    if self.on_module_inited then
        self:on_module_inited(intentData)
    end
    if self.on_update or self.on_update_per_second then
        self._addUpdateBeat = true
        UpdateBeat:Add(self._update, self)
    end

    if self.on_update_per_second then
        self:on_update_per_second(intentData)
    end
end

function Module:view_initialize()

end


function Module:set_per_update_time(t)
    self.per_update_time = t
end

function Module:_update(t)
    if self.on_update then
        self:on_update(t)
    end
    if not self.per_update_time then
        self.per_update_time = 1
    end
    if self.on_update_per_second and ( not self._lastUpdatePerSecond or Time.realtimeSinceStartup > self._lastUpdatePerSecond + self.per_update_time ) then
        self._lastUpdatePerSecond = Time.realtimeSinceStartup
        self:on_update_per_second(t)
    end
end



-- 订阅model层的事件，用来处理model层与所属module之间的交互
function Module:subscibe_model_event(eventName, callback)
    if self.model then
        self.model:subscibe_event(eventName, callback)
    end
end

-- 取消订阅model层的事件
function Module:unsubscibe_model_event(eventName, callback)
    if self.model then
        self.model:unsubscibe_event(eventName, callback)
    end
end

-- Unity中的ugui事件，对应ui_event_handle中的事件
-- e.g: on_press on_click on_drag on_drop on_customer
function Module:on_ui_event(methodName, sender,...)
    local fn = self[methodName]
    if methodName == "on_press" then
        local pressData = {}
        pressData.sender = sender
        pressData.arg = ...
        table.insert(self.curPressDatas,pressData)
    elseif methodName == "on_press_up" then
        for i=1,#self.curPressDatas do
            local obj = self.curPressDatas[i].sender
            if obj == sender then
                table.remove(self.curPressDatas,i)
                break
            end
        end
    end
    if type(fn) == "function" then
        fn(self,sender,...)
    end --fn(self,{...})
end
--当程序焦点发生变化，弹起所有的按下事件
function Module:on_application_focus_process_pressData()
    local fn = self["on_press_up"]
    local t = type(fn)
    if t == "function" then
        for i=1,#self.curPressDatas do
            local pressData = self.curPressDatas[i]
            fn(self,pressData.sender,pressData.arg)
        end
    end
    table.clear(self.curPressDatas)
end

-- 显示
function Module:show(intentData)
    if self.view then
        self.view:show(true)
    end
    if self.on_show then
        self:on_show(intentData)
    end
end



-- 隐藏
function Module:hide(intentData)
    if self.view then
        self.view:hide()
    end
    if self.on_hide then
        self:on_hide(intentData)
    end
end

function Module:view_is_active()
    if self.view then
        return self.view:is_active()
    end
    return false
end


-- 销毁模块
function Module:destroy()
    if self._addUpdateBeat then
        UpdateBeat:Remove(self._update, self)
    end

    ModuleEventBase.base_destroy(self)
    if self.view then
        self.view:destroy()
        self.view = nil
    end
    if self.model then
        self.model:destroy()
        self.model = nil
    end
    ApplicationEvent.unsubscibe_app_focus_event(self.onApplicaiontFocusProcessPressUp)
    if self.on_destroy then
        self:on_destroy()
    end
    self.isDestroy = true

end

return Module