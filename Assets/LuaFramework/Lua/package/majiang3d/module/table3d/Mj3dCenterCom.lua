--- 3D 麻将 桌子中间的那个控件
--- Created by 袁海洲
--- DateTime: 2018/1/22 17:44
---
---@class Mj3dCenterCom
local Mj3dCenterCom = {}

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local TableUtil = TableUtil
local Vector3 = Vector3

function Mj3dCenterCom:Init(view,parent)
    ---@type Table3dCommonView
    self.view = view
    self.rootTrans = parent

    self.windTagRoot = GetComponentWithPath(self.rootTrans.gameObject,"dongxinanbei/", ComponentTypeName.Transform).gameObject
    self.disableObj = GetComponentWithPath(self.windTagRoot,"disable", ComponentTypeName.Transform).gameObject
    self.windTags = {}
    for i=1,4 do
        local windTag = {}
        windTag.obj = GetComponentWithPath(self.windTagRoot,tostring(i), ComponentTypeName.Transform).gameObject
        windTag.liang = GetComponentWithPath(windTag.obj,"liang", ComponentTypeName.Transform).gameObject
        windTag.an = GetComponentWithPath(windTag.obj,"an", ComponentTypeName.Transform).gameObject
        windTag.localSeat = 0
        self.windTags[#self.windTags + 1] = windTag
    end

    self.timingSprite = GetComponentWithPath(self.rootTrans.gameObject, "TimingSprite", "SpriteHolder")
    self.TmingObj = GetComponentWithPath(self.rootTrans.gameObject, "TimingObj",  ComponentTypeName.Transform).gameObject

    self.tenNumbers =
    TableUtil.get_all_child(GetComponentWithPath(self.TmingObj,"1",ComponentTypeName.Transform).gameObject)
    self.unitNumbers =
    TableUtil.get_all_child(GetComponentWithPath(self.TmingObj,"2",ComponentTypeName.Transform).gameObject)

    self.diceObj = GetComponentWithPath(self.rootTrans.gameObject, "DiceObj",  ComponentTypeName.Transform).gameObject
    self.dice1Obj =  GetComponentWithPath(self.diceObj, "tuozi/Cube_1",  ComponentTypeName.Transform).gameObject
    self.dice2Obj =  GetComponentWithPath(self.diceObj, "tuozi/Cube_2",  ComponentTypeName.Transform).gameObject

    self.dice1s = {}
    for i=1,6 do
        local obj = self.dice1Obj.transform:Find(tostring(i)).gameObject
        self.dice1s[#self.dice1s + 1] = obj
    end
    self.dice2s = {}
    for i=1,6 do
        local obj = self.dice2Obj.transform:Find(tostring(i)).gameObject
        self.dice2s[#self.dice2s + 1] = obj
    end
end

---播放打色动效
function Mj3dCenterCom:playDiceAni(dice1,dice2,callBack)
    for i=1,#self.dice1s do
        self.dice1s[i]:SetActive(false)
    end
    for i=1,#self.dice2s do
        self.dice2s[i]:SetActive(false)
    end
    local dice1Obj = self.dice1s[dice1]
    local dice2Obj = self.dice2s[dice2]
    dice1Obj:SetActive(true)
    dice2Obj:SetActive(true)
    self.diceObj:SetActive(false)
    self.diceObj:SetActive(true)
    self.TmingObj:SetActive(false)
    self.view:play_voice("common/touzi")
    self.view:subscibe_time_event(1.8, false, 0):OnComplete(function()
        self.TmingObj:SetActive(true)
        self.diceObj:SetActive(false)
        if callBack then
            callBack()
        end
    end)
end

---初始化标记
function Mj3dCenterCom:initWindTag(masterLocalSeat)
    local index = masterLocalSeat
    if 1 == masterLocalSeat then
        self.windTagRoot.transform.localEulerAngles = Vector3(0,0,0)
    elseif 2 == masterLocalSeat then
        self.windTagRoot.transform.localEulerAngles = Vector3(0,-90,0)
    elseif 3 == masterLocalSeat then
        self.windTagRoot.transform.localEulerAngles = Vector3(0,-180,0)
    elseif 4 == masterLocalSeat then
        self.windTagRoot.transform.localEulerAngles = Vector3(0,-270,0)
    end
    for i=1,4 do
        local windTag = self.windTags[i]
        windTag.localSeat = index
        index = index + 1
        if index > 4 then
            index = 1
        end
    end
end

---刷新标记状态
function Mj3dCenterCom:refreshWindTagState(masterLocalSeat)
    for i = 1,#self.windTags do
        local windTag = self.windTags[i]
        if windTag.localSeat == masterLocalSeat then
            windTag.liang:SetActive(true)
            windTag.an:SetActive(false)
        else
            windTag.liang:SetActive(false)
            windTag.an:SetActive(true)
        end
    end
end

---设置标记开启隐藏状态
function Mj3dCenterCom:setTagActive(state)
    self.disableObj:SetActive(not state)
    for i=1,4 do
        local windTag = self.windTags[i]
        windTag.obj:SetActive(state)
    end
end

---设置倒计时文字
function Mj3dCenterCom:setTimingText(tenValue,unitValue)
    tenValue = tenValue or -1
    unitValue = unitValue or -1
    for i=0,#self.tenNumbers - 1 do
        self.tenNumbers[i + 1]:SetActive(i == tenValue)
    end
    for i=0,#self.unitNumbers - 1 do
        self.unitNumbers[i + 1]:SetActive(i == unitValue)
    end
end

---@field disableStyle
Mj3dCenterCom.disableStyle =
{
    normal = 1, ---普通模式
    gold = 2, ---金币场模式
}
---设置标记隐藏状态样式
function Mj3dCenterCom:switchDisableTagType(disableStyle)
    local styleObj = nil
    if 1 == disableStyle then
        styleObj = GetComponentWithPath(self.windTagRoot,"disable", ComponentTypeName.Transform).gameObject
    elseif 2 == disableStyle then
        styleObj = GetComponentWithPath(self.windTagRoot,"disable_gold", ComponentTypeName.Transform).gameObject
    end
    styleObj:SetActive(self.disableObj.activeSelf)
    self.disableObj:SetActive(false)
    self.disableObj = styleObj
end

return Mj3dCenterCom