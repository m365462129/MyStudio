-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local PlayerInfoDetailModule = class("PlayerInfoDetailModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function PlayerInfoDetailModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "playerinfodetail_view", "playerinfodetail_model", ...)
end


function PlayerInfoDetailModule:on_show(data)

    self.view:hide();

    -- 请求获取用户信息协议
    self.model:getUserInfo(data);
end

-- 绑定model层事件，模块内交互    model层初始化结束后自动调用
function PlayerInfoDetailModule:on_model_event_bind()

    local onGetUserInfo = function(eventHead, eventData)

        self.view:show();
        -- 初始化
        self.view:init(eventData.showType, eventData.data, self);
    end
    -- 监听获取用户信息事件
    self:subscibe_model_event("Event_PlayerInfo_GetUserInfo", onGetUserInfo);

    local onSaveSign = function(eventHead, eventData)

        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("签名保存成功");
    end
    -- 监听保存签名事件
    self:subscibe_model_event("Event_PlayerInfo_SaveSign", onSaveSign);
end


function PlayerInfoDetailModule:on_click(obj, arg)

    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.buttonBack.gameObject then
        ModuleCache.ModuleManager.destroy_module("henanmj", "playerinfodetail");

        -- 复制按钮
    elseif obj == self.view.buttonCopy.gameObject then
        local playerID = self.view.userInfo.userId
        if playerID then
            -- 复制玩家id到剪切板
            ModuleCache.FunctionManager.CopyToClipBoard(playerID);

            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("复制成功");
        end
        -- 退出游戏按钮
    elseif obj == self.view.buttonExitGame.gameObject then
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您确定要退出游戏？"), function()
            UnityEngine.Application.Quit()
        end , nil)
        -- 更换账号按钮
    elseif obj == self.view.buttonChangeAccount.gameObject then
        ModuleCache.GameManager.logout(true);
    elseif obj.name == "SpriteAvatar" then
        if self.modelData.roleData.agentUrl and self.modelData.roleData.agentUrl ~= "" then
            ModuleCache.ModuleManager.show_module("public", "agentpage",{link=self.modelData.roleData.agentUrl});
        end
    end
end




return PlayerInfoDetailModule;



