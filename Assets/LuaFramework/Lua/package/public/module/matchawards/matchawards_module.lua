-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MatchAwardsModule = class("Public.matchAwardsModule", ModuleBase)
local MatchingManager = require("package.public.matching_manager")
-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function MatchAwardsModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "matchawards_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function MatchAwardsModule:on_module_inited()

end

-- 绑定module层的交互事件
function MatchAwardsModule:on_module_event_bind()
end

-- 绑定loginModel层事件，模块内交互
function MatchAwardsModule:on_model_event_bind()


end

function MatchAwardsModule:on_show(data)
    -- 获取比赛结果
    MatchingManager:getmatchbyid(data.matchId, data.stageId, function(retData)
        local info = {
            time = "",
            name = retData.data.matchName,
            awardstr = ""
        }
        if retData.data.startTime and type(retData.data.startTime) == "string" then
            info.time = retData.data.startTime
        end
        for i = 1, #retData.data.awards do
            if tonumber(retData.data.awards[i].rank) == tonumber(data.rank) then
                info.awardstr = MatchingManager:goodsName(retData.data.awards[i].awardType, retData.data.awards[i].awardNum,
                retData.data.awards[i].itemName, retData.data.awards[i].awardOther)
            end
        end
        info.rank = data.rank;
        -- 更新比赛结果弹窗视图
        self.view:updateResultTipsView(info);
    end, function()
        local info = {}
        info.rank = data.rank
        info.time = os.date("%Y/%m/%d", os.time())
        info.name = ""
        info.awardstr = ""
        self.view:updateResultTipsView(info);
    end);
end

function MatchAwardsModule:on_click(obj, arg)
    print("点击", obj.name, obj.transform.parent.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj.name == "ButtonMatchYes" then
        ModuleCache.ModuleManager.destroy_module("public", "matchawards")
        self:dispatch_package_event('Event_GoldMatching_Quit')
        self:dispatch_package_event("Event_GoldJump_error")
    end
end

return MatchAwardsModule



