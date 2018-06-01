-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MatchRecordView = Class('matchRecordView', View)

local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local Vector3 = Vector3
local MatchingManager = require("package.public.matching_manager")
function MatchRecordView:initialize(...)
    -- 初始View
    View.initialize(self, "public/module/matchrecord/public_windowmatchrecord.prefab", "Public_WindowMatchRecord", 1)

    View.set_1080p(self)

    self.item = GetComponentWithPath(self.root, "Center/ScrollView/Viewport/Content/item", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(self.item, false)
    self.goodsSpriteHolder = ModuleCache.ComponentManager.GetComponent(self.root, "SpriteHolder");
    self.rankSpriteHolder = GetComponentWithPath(self.root, "Center", "SpriteHolder");
end

function MatchRecordView:record_list(data)
    for i = 1, #data do
        local info = data[i]
        local target = ComponentUtil.InstantiateLocal(self.item, Vector3.zero)
        target.transform:SetParent(self.item.transform.parent)
        target.transform.localScale = Vector3.one
        target.transform.localPosition = Vector3.zero
        local iconImg = GetComponentWithPath(target, "Icon", ComponentTypeName.Image)
        local nameText = GetComponentWithPath(target, "Name", ComponentTypeName.Text)
        local timeText = GetComponentWithPath(target, "Time", ComponentTypeName.Text)
        local rankIcon = GetComponentWithPath(target, "RankIcon", ComponentTypeName.Image)
        local reward = GetComponentWithPath(target, "Reward/Fee", ComponentTypeName.Transform).gameObject
        local goodsImg = GetComponentWithPath(target, "Reward/Fee/Icon", ComponentTypeName.Image)
        local goodsText = GetComponentWithPath(target, "Reward/Fee/Text", ComponentTypeName.Text)
        local none = GetComponentWithPath(target, "Reward/None", ComponentTypeName.Transform).gameObject
        MatchingManager:startDownLoadHeadIcon(iconImg, info.matchImg)
        nameText.text = info.matchName
        if info.receiveTime and type(info.receiveTime) == "string" then
            timeText.text = "获奖日期 " .. info.receiveTime
        elseif info.createTime and type(info.createTime) == "string" then
            timeText.text = "获奖日期 " .. info.createTime
        end
        rankIcon.sprite = self.rankSpriteHolder:FindSpriteByName(info.rank)
        if info.resultAwards and type(info.resultAwards) == "table" then
            ComponentUtil.SafeSetActive(reward, true)
            ComponentUtil.SafeSetActive(none, false)
            MatchingManager:goodsNameAndIcon(info.resultAwards[1].awardType, goodsImg, goodsText, info.resultAwards[1].awardNum,
                    info.resultAwards[1].awardItemName, info.resultAwards[1].awardItemIcon, info.resultAwards[1].awardOther, info.resultAwards[1].awardOtherImg,self.goodsSpriteHolder )
        else
            ComponentUtil.SafeSetActive(reward, false)
            ComponentUtil.SafeSetActive(none, true)
        end

        ComponentUtil.SafeSetActive(target, true)
    end
end

return MatchRecordView