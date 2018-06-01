--- 3D麻将 3D对象事件
--- Created by 袁海洲
--- DateTime: 2017/12/29 10:17
---

local Physics = UnityEngine.Physics
local Input = UnityEngine.Input
local Time = UnityEngine.Time
local Application = UnityEngine.Application

---@class Table3DEvent
local Mj3dEvent = {}

---创建一个3d事件管理器
function Mj3dEvent:Create(Cam,Layer)
    ---@type Table3DEvent
    local event = {}
    setmetatable(event, { __index = Mj3dEvent })
    event:Init(Cam,Layer)

    event.onClick = {}
    event.onPress = {}
    event.onDrag = {}
    event.onDrop = {}

    return event
end

---初始化3d事件
---3d摄像机
---3d对象所在的层级
function Mj3dEvent:Init(Cam,Layer)
    self.Cam = Cam
    self.Layer = 2 ^ Layer
    self.curFocus = nil ---当前焦点的3D对象(本质就是一个Collider所在的GameObject)
    self.lastFocusTime = nil ---最近的一次有3D对象获得焦点的时间
    self.dragStarted = false  ---当前是否已经开始拖动事件
end

function Mj3dEvent:RegOnClick(onClick)
    table.insert(self.onClick,onClick)
end
function Mj3dEvent:RegOnPress(onPress)
    table.insert(self.onPress,onPress)
end
function Mj3dEvent:RegOnDrag(onDrag)
    table.insert(self.onDrag,onDrag)
end
function Mj3dEvent:RegOnDrop(onDrop)
    table.insert(self.onDrop,onDrop)
end

function Mj3dEvent:RemoveOnClick(onClick)
    for i=1,#self.onClick do
        if self.onClick[i] == onClick then
            table.remove(self.onClick,i)
            break
        end
    end
end
function Mj3dEvent:RemoveOnPress(onPress)
    for i=1,#self.onPress do
        if self.onPress[i] == onPress then
            table.remove(self.onPress,i)
            break
        end
    end
end
function Mj3dEvent:RemoveOnDrag(onDrag)
    for i=1,#self.onDrag do
        if self.onDrag[i] == onDrag then
            table.remove(self.onDrag,i)
            break
        end
    end
end
function Mj3dEvent:RemoveOnDrop(onDrop)
    for i=1,#self.onDrop do
        if self.onDrop[i] == onDrop then
            table.remove(self.onDrop,i)
            break
        end
    end
end

---进行检查，触发事件
---state 是否是开始触碰屏幕， true 触碰屏幕，false 离开屏幕
function Mj3dEvent:Check(state)
    if (not self.Cam) or (not self.Cam.gameObject.activeSelf) then
        return
    end
    if state then
        local curGo = nil
        local mousePos = self:curScreenPos()
        local ray = self.Cam:ScreenPointToRay(mousePos)
        local flag ,hit = Physics.Raycast(ray,nil,9999,self.Layer)
        if flag then
            local collider = hit.collider
            curGo = collider.gameObject
        end
        if self.curFocus and self.curFocus ~= curGo then
            self:resetFocus()
        end
        if curGo then
            self:setFocus(curGo)
        end
    else
        self:resetFocus()
    end
end
---设置焦点
function Mj3dEvent:setFocus(go)
    self.curFocus = go
    self.lastFocusTime = Time.time
    for i=1,#self.onPress do
        self.onPress[i](self.curFocus,true)
    end
    self.dragStarted = false
end
---重置焦点
function Mj3dEvent:resetFocus()
    if self.curFocus then
        local mousePos = self:curScreenPos()
        local ray = self.Cam:ScreenPointToRay(mousePos)
        local hitArray = Physics.RaycastAll(ray,9999,self.Layer)
        if self.dragStarted then
            local dropTargetObj = nil
            if hitArray.Length > 0 then
                for i=0, hitArray.Length - 1 do
                    local hit = hitArray[i]
                    if hit.collider.gameObject ~= self.curFocus then
                        dropTargetObj = hit.collider.gameObject
                        break
                    end
                end
            end
            for j=1,#self.onDrop do
                self.onDrop[j](self.curFocus,dropTargetObj)
            end
        else
            if hitArray.Length > 0 then
                for i=0, hitArray.Length - 1 do
                    local hit = hitArray[i]
                    if hit.collider.gameObject == self.curFocus then
                        for j=1,#self.onClick do
                            self.onClick[j](hit.collider.gameObject)
                        end
                        break
                    end
                end
            end
        end
        for i=1,#self.onPress do
            self.onPress[i](self.curFocus,false)
        end
    end
    self.curFocus = nil
    self.dragStarted = false
end
---更新拖动
function Mj3dEvent:updateDrag()
    if not self.curFocus then
        return
    end
    self.dragStarted = true
    for i=1,#self.onDrag do
        self.onDrag[i](self.curFocus)
    end
end
---当前操作的屏幕坐标
function Mj3dEvent:curScreenPos()
    local runtimePlatform = tostring(Application.platform)
    if runtimePlatform == "iOS" or runtimePlatform == "Android" then
        if Input.touchCount > 0 then
            return Input.GetTouch(0).position
        end
    else
        return Input.mousePosition
    end
end

return Mj3dEvent