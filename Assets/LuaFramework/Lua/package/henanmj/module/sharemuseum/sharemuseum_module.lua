-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local ShareMuseumModule = class("ShareMuseumModule", ModuleBase)



-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local WechatManager = ModuleCache.WechatManager
local Util = Util

function ShareMuseumModule:initialize(...)
    ModuleBase.initialize(self, "sharemuseum_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function ShareMuseumModule:on_module_inited()
  
end


function ShareMuseumModule:on_click(obj, arg)
    print(obj.name)
   
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.buttonClose.gameObject then
       ModuleCache.ModuleManager.hide_module("henanmj", "sharemuseum")
    elseif obj == self.view.buttonTimeLine.gameObject then
        -- 更新分享图片视图
        self.view:updateShareImage(self.museumData, self.museumData.qrCodeSpr);
        -- 调用微信图片分享功能
        ModuleCache.ShareManager().shareImage(true, true, false);

        ModuleCache.ModuleManager.hide_module("henanmj", "sharemuseum")

        return
    elseif obj == self.view.buttonChat.gameObject then
        -- 更新分享图片视图
        self.view:updateShareImage(self.museumData, self.museumData.qrCodeSpr);
        -- 调用微信图片分享功能
        ModuleCache.ShareManager().shareImage(false, true, false);
        ModuleCache.ModuleManager.hide_module("henanmj", "sharemuseum")
        return;
    end
end


function ShareMuseumModule:on_show(data)
    self.museumData = data
    self.view.labelReward.text = string.format( "亲友圈%d的微信群二维码",self.museumData.parlorNum)
     self.view.qrCodeImg.sprite = self.museumData.qrCodeSpr
end

return ShareMuseumModule



