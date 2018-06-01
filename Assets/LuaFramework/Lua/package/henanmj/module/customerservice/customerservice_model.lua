-- ========================== 默认依赖 =======================================
local class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================
local json = require("cjson")

local ModuleCache = ModuleCache

local CustomerServiceModel = class("customerServiceModel", Model)

function CustomerServiceModel:initialize(...)
    Model.initialize(self, ...)

end

-- 请求客服配置协议
function CustomerServiceModel:getImageShareConfig()

    local requestData = {
        params =
        {
            uid = self.modelData.roleData.userID,
            customData = ModuleCache.ShareManager().get_hall_share_custom_data(),
            type = 3,
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "public/getImageShareConfig?",
    }

    local onResponse = function(wwwOperation)

        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then

            -- 客服背景图片为空
            if retData.data.backgroundImgUrl == "" then
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("客服功能未开启");
                return;
            end
            -- 下载玩家头像
            local onDownComplete = function(sprite)
                -- 下载图片失败
                if not sprite then
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("加载超时");
                else
                    retData.data.customerBgSprite = sprite;
                    Model.dispatch_event(self, "Event_CustomerService_GetImageShareConfig", retData.data);
                end
            end
            self:startDownLoadHeadIcon(retData.data.backgroundImgUrl, onDownComplete);
        else

        end
    end

    local onError = function(data)
        print(data.error);
    end

    self:http_get(requestData, onResponse, onError);
end

-- 下载头像
function CustomerServiceModel:startDownLoadHeadIcon(url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if (callback and(not self.isDestroy)) then
                callback(tex)
            end
        else
            if (callback and(not self.isDestroy)) then
                callback(tex)
            end
        end
    end , nil, false)
end

return CustomerServiceModel;