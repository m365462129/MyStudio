--- 3D麻将 麻将组件
--- Created by 袁海洲
--- DateTime: 2017/12/28 11:30
---

---@type Mj3dPool
local Mj3dPool = require("package.majiangshanxi3d.module.table3d.Mj3dPool")

local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentTypeName = ModuleCache.ComponentTypeName
local DOTween = DG.Tweening.DOTween
local Color = Color
local Vector3 = Vector3
---@type Table3DDef
local table3dDef = require("package.majiangshanxi3d.module.table3d.table3d_def")
local Vector2 = Vector2
require("UnityEngine.Collider")
require("UnityEngine.BoxCollider")
require("UnityEngine.MeshRenderer")
require("UnityEngine.Material")

--- @class Mj3d
local Mj3d = {}

local activedMj3ds = {}

function Mj3d:Create(pai,parent)
    ---@type Mj3d
    local mj3d = {}
    setmetatable(mj3d, { __index = Mj3d })
    mj3d.pai = pai
    local go = Mj3dPool:Get(pai,parent) ---实例化MJ gameobject
    mj3d.gameObject = go
    mj3d.transform =  go.transform
    mj3d.goInstanceId = mj3d.gameObject:GetInstanceID()

    mj3d.collider = GetComponentWithPath(mj3d.gameObject,"","UnityEngine.BoxCollider")

    mj3d.meshRootObj = GetComponentWithPath(mj3d.gameObject,"majian",ComponentTypeName.Transform).gameObject

    mj3d.meshObj = GetComponentWithPath(mj3d.meshRootObj,"majian_n",ComponentTypeName.Transform).gameObject
    mj3d.hMeshObj = GetComponentWithPath(mj3d.meshRootObj,"majian_h",ComponentTypeName.Transform).gameObject
    mj3d.outlineMeshObj = GetComponentWithPath(mj3d.meshRootObj,"majian_outline",ComponentTypeName.Transform).gameObject
    mj3d.grayMeshObj = GetComponentWithPath(mj3d.meshRootObj,"majian_gray",ComponentTypeName.Transform).gameObject

    mj3d.tagMeshObj =  GetComponentWithPath(mj3d.meshRootObj,"tag",ComponentTypeName.Transform).gameObject

    mj3d.kuangEffectObj =  GetComponentWithPath(mj3d.gameObject,"paikuan/DaPai",ComponentTypeName.Transform).gameObject

    mj3d.meshRender = GetComponentWithPath(mj3d.meshObj,"","UnityEngine.MeshRenderer")
    mj3d.hMeshRender = GetComponentWithPath(mj3d.hMeshObj,"","UnityEngine.MeshRenderer")
    mj3d.outlineMeshRender = GetComponentWithPath(mj3d.outlineMeshObj,"","UnityEngine.MeshRenderer")
    mj3d.tagMeshRender = GetComponentWithPath(mj3d.tagMeshObj,"","UnityEngine.MeshRenderer")

    mj3d.tagMat = mj3d.tagMeshRender.material

    mj3d.arrowObj = GetComponentWithPath(mj3d.gameObject,"Arrow", ComponentTypeName.Transform).gameObject

    mj3d.tingArrowObj = GetComponentWithPath(mj3d.gameObject,"TingArrow", ComponentTypeName.Transform).gameObject

    ComponentUtil.SafeSetActive(mj3d.gameObject, true)

    mj3d:setColliderState(true)
    mj3d:setTag(nil)
    mj3d:setMj3dDefState(Mj3d.mj3dState.normal)
    mj3d:setMj3dState(Mj3d.mj3dState.normal)
    mj3d:setMj3Active(true)
    mj3d:resetLocalTransState()
    mj3d:setArrowState(false)
    mj3d:setKuangEffectState(false)
    mj3d:setShowZhangData(nil)
    mj3d:setTingArrowState(false)

    table.insert(activedMj3ds,mj3d)
    return mj3d
end

---设置麻将手张数据
function Mj3d:setShowZhangData(shouzhang)
    self.shouZhangData = shouzhang
end

function Mj3d:getShouZhangData()
    return self.shouZhangData
end

---设置麻将的层级
---layer 定义
---8 3dobj
---9 3dhandmj
---10 3dbg
---11 3dmj
---12 3dtable
---13 3dmjother
---14 3dmjdisonscreen
function Mj3d:setLayer(layer)
    if not self.gameObject then
        return
    end
    self.gameObject.layer = layer

    self.meshObj.layer = layer
    self.hMeshObj.layer = layer
    self.outlineMeshObj.layer = layer
    self.kuangEffectObj.layer = layer
    self.grayMeshObj.layer = layer

    self.tagMeshObj.layer = layer

    self.arrowObj.layer = layer
    self.tingArrowObj.layer = layer
end

---获取麻将的牌面值
function Mj3d:Pai()
    return self.pai
end
---设置麻将的碰撞状态
function Mj3d:setColliderState(state)
    if not self.gameObject then
        return
    end
    self.collider.enabled = state
end
---设置麻将的右上角标记
function Mj3d:setTag(texture)
    if not self.gameObject then
        return
    end
    self.tagIsHasTex = (nil ~= texture)
    if texture then
        self.tagMeshObj:SetActive(true)
        self.tagMat.mainTexture = texture
    else
        self.tagMeshObj:SetActive(false)
    end
end
---设置角标状态，如果没有角标则无法这是为激活状态
function Mj3d:setTagState(state)
    if not self.gameObject then
        return
    end
    if not self.tagIsHasTex then
        state = false
    end
    self.tagMeshObj:SetActive(state)
end

---播放麻将倒下的动画
function Mj3d:doDown()
    if not self.gameObject then
        return
    end
end

function Mj3d:setMj3Active(isActive)
    if not self.gameObject then
        return
    end
    self.gameObject:SetActive(isActive)
end

---@field mj3dStates
Mj3d.mj3dState =
{
    hide = 0,
    normal = 1,
    hlight = 2,
    outline = 3,
    gray = 4,
}

---设置麻将状态，0 隐藏 ，1 普通， 2 高亮 , 3 描边 , 4 变暗
function Mj3d:setMj3dState(state)
    if not self.gameObject then
        return
    end
    ComponentUtil.SafeSetActive(self.tagMeshObj,(0 ~= state) and self.tagIsHasTex)
    ComponentUtil.SafeSetActive(self.meshObj,false)
    ComponentUtil.SafeSetActive(self.hMeshObj,false)
    ComponentUtil.SafeSetActive(self.outlineMeshObj,false)
    ComponentUtil.SafeSetActive(self.grayMeshObj,false)
    if 0 == state then

    elseif 1 == state then
        ComponentUtil.SafeSetActive(self.meshObj,true)
    elseif 2 == state then
        ComponentUtil.SafeSetActive(self.hMeshObj,true)
    elseif 3 == state then
        ComponentUtil.SafeSetActive(self.outlineMeshObj,true)
    elseif 4 == state then
        ComponentUtil.SafeSetActive(self.grayMeshObj,true)
    end
end
---设置麻将的默认状态
function Mj3d:setMj3dDefState(state)
    self.defState = state
end
---重置麻将为默认状态
function Mj3d:resetDefState()
    self:setMj3dState(self.defState)
end

function Mj3d:setArrowState(state)
    if not self.gameObject then
        return
    end
    self.arrowObj:SetActive(state)
end

function Mj3d:setTingArrowState(state)
    if not self.gameObject then
        return
    end
    self.tingArrowObj:SetActive(state)
end

function Mj3d:setKuangEffectState(state)
    if not self.gameObject then
        return
    end
    self.kuangEffectObj:SetActive(state)
end

---重置mj3d对象,不要调用，不要调用，不要调用，请使用table3d_helper中的清理麻将函数
---@private
function Mj3d:reset()
    for i=1,#activedMj3ds do
        if activedMj3ds[i] == self then
            table.remove(activedMj3ds,i)
            break
        end
    end

    self:setLayer(11)
    self:resetLocalTransState()
    self:setArrowState(false)
    self:setTag(nil)

    self.pai = nil
    self.gameObject = nil
    self.transform = nil
    self.goInstanceId = nil
    self.collider = nil

    self.meshRootObj = nil
    self.meshObj = nil
    self.hMeshObj = nil
    self.outlineMeshObj = nil
    self.tagMeshObj = nil

    self.kuangEffectObj = nil

    self.meshRender = nil
    self.hMeshRender = nil
    self.outlineMeshRender = nil
    self.grayMeshObj = nil

    self.tagMeshRender = nil

    self.tagMat = nil

    self.arrowObj = nil
    self.tingArrowObj = nil
end

function Mj3d:resetLocalTransState()
    if not self.gameObject then
        return
    end
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject.transform.localPosition = Vector3.zero
    self.gameObject.transform.localEulerAngles =  Vector3.zero
    self.meshObj.transform.localPosition = Vector3.zero
end

---操作所有激活的mj3d对象
function Mj3d:OptActiedMj3ds(optCallBack)
    for i=1,#activedMj3ds do
        if optCallBack then
            optCallBack(activedMj3ds[i])
        end
    end
end

function Mj3d:Init()
    activedMj3ds = {}
end

return Mj3d