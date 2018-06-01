-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MuseumCostPowerView = Class('museumCostPowerView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local costNum = 0

function MuseumCostPowerView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/museumcostpower/henanmj_museumcostpower.prefab", "HeNanMJ_MuseumCostPower", 1)
    self.scrollView = GetComponentWithPath(self.root, "Center/Scroll View", ComponentTypeName.ScrollRect)
    self.copyItem = GetComponentWithPath(self.root, "Center/CopyItem", ComponentTypeName.Transform).gameObject
    self.copyParent = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content", ComponentTypeName.Transform).gameObject
    --self.imageTitle = GetComponentWithPath(self.root, "Center/Image/Image", ComponentTypeName.Image)
    --self.titleHolder = GetComponentWithPath(self.root, "Center/Image/Image", "SpriteHolder")
    self.titleText = GetComponentWithPath(self.root, "Center/Image/Text", ComponentTypeName.Text)
    self.payTypeTitle = {"亲友圈", "大赢家", "房费均摊"}

    self.items = TableUtil.get_all_child(self.copyParent)
end

function MuseumCostPowerView:get_round_data(data)
    for i=1,#data.configs do
        local config = data.configs[i]
        if(config.round == data.roundCount) then
            return config
        end
    end
    return nil
end

function MuseumCostPowerView:initLoopScrollViewList(data)
    costNum = 0
    self.showVals = {}
    local config = self:get_round_data(data)
    local datas = string.split(config.coinNums, ",")
    costNum = #datas

    --parlorChargingType 1以房间为基准 2以人数为基准
    if data.parlorChargingType == 1 then
        if(data.payType == 1 or data.payType == 2) then
             for i=1,#datas do
                self.showVals[i] = tonumber(datas[i])
            end
        else
            for i=1,#datas do
                self.showVals[i] = math.ceil(tonumber(datas[i])/data.playerCount)
            end
        end
    elseif data.parlorChargingType == 2 then
        if(data.payType == 3) then
             for i=1,#datas do
                self.showVals[i] = tonumber(datas[i])

                 if not AppData.isPokerGame() and data.playerCount == 2 then
                     self.showVals[i] = math.ceil(tonumber(datas[i]) *3 / 2)
                 end
            end
        else
            for i=1,#datas do
                self.showVals[i] = tonumber(datas[i])*data.playerCount

                if not AppData.isPokerGame() and data.playerCount == 2 then
                    self.showVals[i] = tonumber(datas[i])*3
                end
            end
        end

    end

    self.posVals = {}
    for i=1,costNum do
        self.posVals[i] = 1 - (i - 1)/(costNum - 1)
    end
    local jumpIndex = 1
    --self.imageTitle.sprite = self.titleHolder:FindSpriteByName(data.payType .. "")
    --self.imageTitle:SetNativeSize()
    self.titleText.text = self.payTypeTitle[tonumber(data.payType)]


    self:reset()
    self.items = {}
    for i=1,2 do
        self:fillItem(self:get_item(nil, i), true)
    end
    for i=3,costNum + 2 do
        local index = i - 2
        local item = nil
        item = self:get_item(self.showVals[index], i)
        if(data.payNum == self.showVals[index]) then
            jumpIndex = index
        end
        self:fillItem(item, false)
        table.insert(self.items, item)
    end
    for i=costNum + 3,costNum + 4 do
        self:fillItem(self:get_item(nil, i), true)
    end
    local selectIndex = jumpIndex
    self.scrollView.verticalNormalizedPosition = self.posVals[selectIndex]
    self.selectPower = self:get_power(selectIndex, data)
    self:select_item(jumpIndex)
end

function MuseumCostPowerView:get_item(data, i)
    local obj = nil
    local item = {}
    if(i<=#self.contents) then
        obj = self.contents[i]
    else
        obj = TableUtil.clone(self.copyItem,self.copyParent,Vector3.zero)
    end
    obj.name = "item_" .. i 
    ComponentUtil.SafeSetActive(obj, true)  
    item.gameObject = obj
    item.data = data
    return item
end

function MuseumCostPowerView:reset()
    self.contents = TableUtil.get_all_child(self.copyParent)
    for i=1,#self.contents do
        ComponentUtil.SafeSetActive(self.contents[i], false)
    end
end

function MuseumCostPowerView:fillItem(item, isEmpty)
    local data = item.data
    local objFull = GetComponentWithPath(item.gameObject, "Full", ComponentTypeName.Transform).gameObject
    local objEmpty = GetComponentWithPath(item.gameObject, "Empty", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(objFull, not isEmpty)
    ComponentUtil.SafeSetActive(objEmpty, isEmpty)
    if(data) then
        item.powerText = GetComponentWithPath(objFull, "Text", ComponentTypeName.Text)
        item.imageBg = GetComponentWithPath(objFull, "Image", ComponentTypeName.Image)
        item.powerText.text = data .. ""
        item.selectLight = GetComponentWithPath(item.gameObject, "Full/ImageArrow", ComponentTypeName.Transform).gameObject
    end
end

function MuseumCostPowerView:get_power(index, data)
    return self.items[index].data
end

function MuseumCostPowerView:select_item(index)
    for i = 1, #self.items do
        local item = self.items[i]
        if(i == index) then
            item.powerText.text = item.data .. ""
            item.imageBg.color = Color.New(1,1,1,1)
            item.selectLight:SetActive(true)
        else
            item.powerText.text = string.format("<size=29><color=#84590f>%d</color></size>",item.data)
            item.imageBg.color = Color.New(1,1,1,0.65)
            item.selectLight:SetActive(false)
        end
    end
end

return MuseumCostPowerView