--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
local TableGiftView = class('TableGiftView', View)

local localPos_0 = UnityEngine.Vector3.zero

function TableGiftView:initialize(...)

end

function TableGiftView:init()
    if(self.is_inited)then
        return
    end
    View.initialize(self, "public/module/tablegift/tablegift.prefab", "TableGift", 1)
    self.tranTmp = GetComponentWithPath(self.root, "tmp", ComponentTypeName.Transform)
    self.pathHolder = GetComponentWithPath(self.root, "Path", 'DG.Tweening.DOTweenPath')
    local goCamera = ModuleCache.ComponentUtil.Find(UnityEngine.GameObject.Find("GameRoot"), "Game/UIRoot/UICamera")
    self.uiCamera = ModuleCache.ComponentManager.GetComponent(goCamera, "UnityEngine.Camera")

    self.goGiftHolder = GetComponentWithPath(self.root, "GiftHolder", ComponentTypeName.Transform).gameObject
    self.giftTablePrefabHolder = {}
    local giftNameTable = {'rose', 'ring', 'bomb', 'egg', 'brick', 'kiss'}
    for i, v in pairs(giftNameTable) do
        self.giftTablePrefabHolder[v] = GetComponentWithPath(self.root, 'Holder/' .. v, ComponentTypeName.Transform).gameObject
    end

    self.is_inited = true
    View.show(self)
end

function TableGiftView:create_send_gift_anim(giftData)
    local needDelay = not self.is_inited
    self:init()
    if(needDelay)then
        self:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
            self:play_send_gift_anim(giftData)
        end)
    else
        self:play_send_gift_anim(giftData)
    end
end

function TableGiftView:play_send_gift_anim(giftData)
    local goPrefab = self.giftTablePrefabHolder[giftData.giftName]
    if(goPrefab)then
        local clone = ModuleCache.ComponentUtil.InstantiateLocal(goPrefab, self.goGiftHolder, localPos_0)
        local effect = GetComponentWithPath(clone, "effect", ComponentTypeName.Transform)
        local go = GetComponentWithPath(clone, "go", ComponentTypeName.Transform)
        if(effect and go)then
            ModuleCache.ComponentUtil.SafeSetActive(go.gameObject, true)
            ModuleCache.ComponentUtil.SafeSetActive(effect.gameObject, false)
        end
        clone.transform.position = giftData.fromPos
        local localFromPos = self:worldPosToLocal(giftData.fromPos)
        local localToPos = self:worldPosToLocal(giftData.toPos)
        local duration = 0.5
        self:flyFromTo(clone, localFromPos, localToPos, duration, function()

        end, true)
        self:subscibe_time_event(duration - 0.1, false, 0):OnComplete(function(t)
            if(effect and go)then
                ModuleCache.ComponentUtil.SafeSetActive(go.gameObject, false)
                ModuleCache.ComponentUtil.SafeSetActive(effect.gameObject, true)
                ModuleCache.SoundManager.play_sound("public", string.format("publictable/sound/tablegift/%s.bytes", giftData.giftName), giftData.giftName)
            end
            local effectTime = 1
            self:subscibe_time_event(effectTime, false, 0):OnComplete(function(t)
                UnityEngine.GameObject.Destroy(clone)
            end)
        end)
    end
end

function TableGiftView:flyTest(obj, arg)
    self:init()
    local from = UnityEngine.Vector3.New(-500, 200, 0)
    local screenPos = UnityEngine.Input.mousePosition
    local position = self.uiCamera:ScreenToWorldPoint(Vector3.New(screenPos.x, screenPos.y, 0))
    self.tranTmp.position = position
    local to = self.tranTmp.localPosition
    self:flyFromTo(self.goSeat, from, to)
end

function TableGiftView:worldPosToLocal(pos)
    self.tranTmp.position = pos
    return self.tranTmp.localPosition
end

function TableGiftView:flyFromTo(go, from, to, duration, onFinish, useDirectMove)
    self:init()
    duration = duration or 0.7
    go.transform.localPosition = from
    local keyPos = self:calcKeyPos(from, to)
    local keyPosList = self.pathHolder.wps
    keyPosList:Clear()
    keyPosList:Add(from)
    keyPosList:Add(keyPos)
    keyPosList:Add(to)
    local array = keyPosList:ToArray()
    local sequence = self:create_sequence()
    if(useDirectMove)then
        sequence:Append(go.transform:DOLocalMove(to, duration, false):SetEase(DG.Tweening.Ease.Linear))
    else
        sequence:Append(go.transform:DOLocalPath(array, duration, DG.Tweening.PathType.CatmullRom):SetEase(DG.Tweening.Ease.Linear))
    end
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

function TableGiftView:calcKeyPos(from, to)
    local distance = 200
    local y1_y2 = from.y - to.y
    local x2_x1 = to.x - from.x
    if(x2_x1 == 0)then
        x2_x1 = 0.5
    end
    local x1x2 = from.x + to.x
    local y1y2 = from.y + to.y
    local tmp = distance * math.sqrt(1/(math.pow(y1_y2/x2_x1, 2) + 1))
    local targetX = tmp * (y1_y2 / x2_x1) + x1x2 * 0.5
    local targetY = tmp + y1y2 * 0.5
    local targetX1 = -tmp * (y1_y2 / x2_x1) + x1x2 * 0.5
    local targetY1 = -tmp + y1y2 * 0.5
    if(math.abs(targetX) > math.abs(targetX1))then
        targetX = targetX1
    end
    if(math.abs(targetY) > math.abs(targetY1))then
        targetY = targetY1
    end
    return UnityEngine.Vector3.New(targetX, targetY, 0)
end


function TableGiftView:show(showTop)
    if(self.is_inited)then
        View.show(self, showTop)
    end
end

function TableGiftView:set_1080p()
    if(self.is_inited)then
        View.set_1080p(self)
    end
end

function TableGiftView:set_image_fill(image,size)
    if(self.is_inited)then
        View.set_image_fill(self)
    end
end

function TableGiftView:hide()
    if(self.is_inited)then
        View.hide(self)
    end
end

function TableGiftView:is_active()
    if(self.is_inited)then
        return View.is_active(self)
    end
    return false
end

function TableGiftView:destroy()
    if(self.is_inited)then
        View.destroy(self)
    end
end

return  TableGiftView