-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local PlayerInfoModule = class("BullFight.PlayerInfoModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function PlayerInfoModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "PlayerInfo_view", nil, ...)
end


function PlayerInfoModule:on_show(playerInfo)
    if type(playerInfo) == "number" then
        self.playerId = playerInfo
    else
        self.playerId = playerInfo.playerId
    end

    self.view:hide();

    local onUserInfo = function(userInfo)
        self.view:show();
        if type(playerInfo) == "number" then
            self.playerInfoView:init(userInfo);
        else
            self.playerInfoView:init(playerInfo);
        end

        -- 更新个人签名视图
        self.view:updateSignView(userInfo);
        if(self.playerId..'' == self.modelData.roleData.userID..'')then
            self.view:show_gift_panel(false)
        else
            --暂时屏蔽礼物
            self.view:show_gift_panel(true)
        end
    end
    -- 获取玩家信息协议
    self:getUserInfo(self.playerId, onUserInfo);
end


function PlayerInfoModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    -- 返回按钮
    if obj == self.view.buttonBack.gameObject or obj == self.view.buttonMask.gameObject then
        ModuleCache.ModuleManager.hide_module("henanmj", "playerinfo");
        return;

        -- 复制按钮
    elseif obj == self.view.buttonCopy.gameObject then
        local playerID = self.view.playerInfo.playerId;
        -- 复制玩家id到剪切板
        ModuleCache.GameSDKInterface:CopyToClipboard(playerID);

        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("复制成功");
    elseif(obj.transform.parent.gameObject == self.view.goGiftPanel)then
        self:on_click_gift_btn(obj, arg)
    end
end

function PlayerInfoModule:on_click_gift_btn(obj, arg)
    for i, v in pairs(self.view.giftButtonHolders) do
        if(obj == v.button.gameObject)then
            self:dispatch_package_event("Event_PlayerInfo_SendGift", {receiver = self.playerId, giftName = v.key})
            self.view:set_last_send_time()
            ModuleCache.ModuleManager.hide_module("henanmj", "playerinfo")
        end
    end

end

-- 获取玩家信息协议
function PlayerInfoModule:getUserInfo(playerID, callback)

    local requestData = {
        params =
        {
            uid = playerID,
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
    }

    local onResponse = function(wwwOperation)

        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then

            if callback then
                callback(retData.data);
            end
        else

        end
    end

    local onError = function(data)
        print(data.error);
    end
    local onSystemError = function(data)
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.message)
    end

    self:http_get(requestData, onResponse, onError, nil, onSystemError);
end


return PlayerInfoModule



