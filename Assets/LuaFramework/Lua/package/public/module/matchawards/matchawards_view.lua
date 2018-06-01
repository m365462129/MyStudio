-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MatchAwardsView = Class('matchAwardsView', View)

local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local Vector3 = Vector3
local MatchingManager = require("package.public.matching_manager")
function MatchAwardsView:initialize(...)
    -- 初始View
    View.initialize(self, "public/module/matchawards/public_windowmatchawards.prefab", "Public_WindowMatchAwards", 1)

    View.set_1080p(self)

    -- 比赛内容标签
    self.labelMatchMessage = GetComponentWithPath(self.root, "ResultTips/LabelMatchMessage", ComponentTypeName.Text);
    -- 比赛排名标签
    self.labelMatchRank = GetComponentWithPath(self.root, "ResultTips/LabelMatchRank", ComponentTypeName.Text);
    -- 比赛奖励标签
    self.labelMatchAward = GetComponentWithPath(self.root, "ResultTips/LabelMatchAward", ComponentTypeName.Text);
    ComponentUtil.SafeSetActive(self.root, false)
end

-- 更新比赛结果弹窗视图
function MatchAwardsView:updateResultTipsView(data)

    -- 比赛内容
    self.labelMatchMessage.text = "恭喜您于" .. data.time .. "在" .. data.name .. "比赛中荣获:";
    -- 比赛排名
    self.labelMatchRank.text = "第" .. data.rank .. "名";
    -- 比赛奖励
    if data.awardstr == "" then
        self.labelMatchAward.text = data.awardstr;
    else
        self.labelMatchAward.text = "特此奖励:" .. data.awardstr;
    end
    ComponentUtil.SafeSetActive(self.root, true)
end

return MatchAwardsView