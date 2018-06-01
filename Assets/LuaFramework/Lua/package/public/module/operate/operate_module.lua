-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local OperateModule = class("operateModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local UnityEngine = UnityEngine

function OperateModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "operate_view", "operate_model", ...)

end

function OperateModule:on_update()
    self.view:update()
end

function OperateModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.buttonBack.gameObject then

        self.view:stop_auto_play_adcontent();
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您确定要退出游戏？"), function()
            UnityEngine.Application.Quit()
        end , nil)
        -- ModuleCache.ModuleManager.destroy_module("public", "operate");
        -- 复制按钮
    elseif obj == self.view.buttonCopy.gameObject then
        local playerID = self.view.userData.userId
        if playerID then
            -- 复制玩家id到剪切板
            ModuleCache.GameSDKInterface:CopyToClipboard(playerID);

            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("游戏ID复制成功");
        end
        -- 头像按钮
    elseif obj == self.view.buttonRole.gameObject then
        local data = {
            showType = 1,
            uid = self.modelData.roleData.userID,
        }
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfodetail", data)
        -- 更多游戏按钮
    elseif obj == self.view.buttonMoreGame.gameObject then
       -- ModuleCache.ModuleManager.hide_module("public", "operate");
        ModuleCache.ModuleManager.show_module('henanmj', "setplaymode", ModuleCache.GameManager.getCurProvinceId())
        -- 体力按钮
    elseif obj == self.view.buttonPower.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "shop", 2);
    elseif (obj.name == "ButtonHall") then
        self:hide()
        --ModuleCache.ModuleManager.show_module("henanmj", "hall")
    end
end

function OperateModule:on_show(showFromHall)

    self.view:hide();

    -- 请求获取发行配置协议
    self.model:getOperateConfig();

    -- 请求获取用户信息协议
    self.model:getUserInfo();

    self.view.goShowHall:SetActive(showFromHall)
end

-- 绑定model层事件，模块内交互    model层初始化结束后自动调用
function OperateModule:on_model_event_bind()

    local onGetOperateConfig = function(eventHead, eventData)

        self.view:show();
        -- 初始化
        self.view:init(eventData, self);
    end
    -- 监听请求获取发行配置事件
    self:subscibe_model_event("Event_Operate_GetConfig", onGetOperateConfig);

    local onGetUserInfo = function(eventHead, eventData)

        -- 更新用户信息视图
        self.view:updateUserInfoView(eventData);
    end
    -- 监听请求获取发行配置事件
    self:subscibe_model_event("Event_Operate_GetUserInfo", onGetUserInfo);

    local onGetMuseumList = function(eventHead, eventData)

        -- 更新亲友圈视图
        self.view:updateMuseumView(eventData);
    end
    -- 监听请求获取亲友圈列表事件
    self:subscibe_model_event("Event_Operate_OnGetMuseumList", onGetMuseumList);
end

function OperateModule:on_begin_drag(obj, arg)
    if (obj.name == "ad_item") then
        self.view:stop_auto_play_adcontent()
        self.view:onBeginDragAdContent(obj, arg)
    end
end

function OperateModule:on_drag(obj, arg)
    self.view:onDragAdContent(obj, arg)
end

function OperateModule:on_end_drag(obj, arg)
    if (self.view and obj.name == "ad_item") then
        self.view:onEndDragAdContent(nil, obj, arg)
        self.view:start_auto_play_adcontent()
    end
end

return OperateModule