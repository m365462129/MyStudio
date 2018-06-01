--- 3D麻将 弃张组件
--- Created by 袁海洲
--- DateTime: 2017/12/28 18:01
---
local Mj3d = require("package.majiangshanxi3d.module.table3d.Mj3d")
local Mj3dHelper = require("package.majiangshanxi3d.module.table3d.table3d_helper")

local GameObject = UnityEngine.GameObject
local Vector3 = Vector3

---@class Mj3dThrowMj
local Mj3dThrowMj = {}

function Mj3dThrowMj:Create(transform)
    local mj3dThrowMj = {}
    setmetatable(mj3dThrowMj, { __index = Mj3dThrowMj })
    mj3dThrowMj.gameObject = transform.gameObject
    mj3dThrowMj.Mjs = {}

    mj3dThrowMj.HSpaceing = 2.7  ---普通麻将横向间隔
    mj3dThrowMj.VSpaceing = -3.55  ---普通麻将纵向间隔

    return mj3dThrowMj
end

---刷新弃牌
function Mj3dThrowMj:refreshThrowMj(QiZhang,RowMaxCount)
    Mj3dHelper:clearMj3dTabel(self.Mjs)
    for i=1,#QiZhang do
        local pai = QiZhang[i]
        self:AddThrowMj(pai)
    end
    self:processLayout(RowMaxCount)
end
---添加弃张
function Mj3dThrowMj:AddThrowMj(pai,showPointer)
    local mj3d = Mj3d:Create(pai,self.gameObject.transform)
    mj3d:setLayer(13)
    ---处理弃张中的赖子
    if(Mj3dHelper:getModule().view:is_laizi(mj3d:Pai())) then
        Mj3dHelper:set_LaiZi(mj3d,false)
    end
    table.insert(self.Mjs,mj3d)
    mj3d:setArrowState(showPointer)
    return mj3d
end
---处理弃张的布局
function Mj3dThrowMj:processLayout(RowMaxCount)
    local rowCount = 0
    local lineCount = 0
    for i=1,#self.Mjs do
        local mj3d = self.Mjs[i]
        if rowCount >= RowMaxCount then
            lineCount = lineCount + 1
            rowCount = 0
        end
        mj3d.gameObject.transform.localPosition = Vector3.New(rowCount * self.HSpaceing,0,lineCount * self.VSpaceing)
        rowCount = rowCount + 1
    end
end

---获取下一个弃张所在的局部坐标
function Mj3dThrowMj:getNextLocalPos(RowMaxCount)
    local rowCount = 0
    local lineCount = 0
    local nextCount = #self.Mjs + 1
    local nextLocalPos = nil
    for i=1,nextCount do
        if rowCount >= RowMaxCount then
            lineCount = lineCount + 1
            rowCount = 0
        end
        nextLocalPos = Vector3.New(rowCount * self.HSpaceing,0,lineCount * self.VSpaceing)
        rowCount = rowCount + 1
    end
    return nextLocalPos
end
---获取最后一张弃牌
function Mj3dThrowMj:getLastMj3d()
    return self.Mjs[#self.Mjs]
end
---从弃张中指定删除某个mj3d
function Mj3dThrowMj:deleteMj3d(mj3d)
    for i=1,#self.Mjs do
        if self.Mjs[i] == mj3d then
            Mj3dHelper:clearMj3d(mj3d)
            table.remove(self.Mjs,i)
            break
        end
    end
end
---清空弃张
function Mj3dThrowMj:clear()
    Mj3dHelper:clearMj3dTabel(self.Mjs)
end

return Mj3dThrowMj