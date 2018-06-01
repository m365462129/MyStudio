--- 麻将堆基类
--- Created by houzhen.
--- DateTime: 2018/1/18 10:20
---
---@type Mj2DHeap
local Mj2DHeap = require('package.majiangshanxi.module.tablenew.mj.mj2dheap')
local class = require("lib.middleclass")
---@type Mj2D
local Mj2D = require('package.majiangshanxi.module.tablenew.mj.mj2d')
---@type Mj2DManager
local MjManager = require('package.majiangshanxi.module.tablenew.mj2d_manager')
---@class Mj2DHeapHua:Mj2DHeap
local Mj2DHeapHua = class("mj2dHeapHua", Mj2DHeap)
local Color = Color
local Vector3 = Vector3
local outGridCell =  --弃张摆放宫格位移
{
    {82,104},
    {-54,36},
    {-82,-104},
    {54,-36},
}

--- 添加一个麻将
function Mj2DHeapHua:add_mj(params)
    ---@type Mj2D
    local mj = Mj2D:new(params.huaData, params.seatHolder.huaPoint,
        {cloneName = params.localSeat .. "_HuaMJ", index = params.huaIndex,
            spriteHolder = params.spriteHolder, tagSpriteHolder = params.tagSpriteHolder})
    mj:set_skin(self.view.mjColorSet, self.view.mjScaleSet)
    params.mj = mj
    self:set_mj(params)
    mj:set_color(Color.white)
    mj:hide_tag()
    if(self.view:is_laizi(params.huaData)) then
        mj:set_lai_zi(false,self.view.ConfigData.laiziTag or 4, nil, params.notYellow)
    end
    if(params.localSeat == 4) then
        mj.transform:SetAsFirstSibling()
    end
    MjManager.insert(mj, MjManager.mjType.hua,params.localSeat)
    return mj
end

--- 设置麻将相关
function Mj2DHeapHua:set_mj(params)
    local addIndex = params.huaIndex
    local localSeat = params.localSeat
    local mj = params.mj
    local seatHolder = params.seatHolder
    if(localSeat == 1 or localSeat == 3) then
        mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(-outGridCell[localSeat][1] * (addIndex - 1), 0, 0)
    else
        mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(0, -outGridCell[localSeat][2]  * (addIndex - 1), 0)
    end
end

return Mj2DHeapHua