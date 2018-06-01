-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local ShareMuseumView = Class('shareMuseumView', View)

local ModuleCache = ModuleCache
local ViewUtil = ModuleCache.ViewUtil;
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function ShareMuseumView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/sharemuseum/share_museum.prefab", "Share_Museum", 1)

    self.buttonClose = GetComponentWithPath(self.root, "Center/Child/closeBtn", ComponentTypeName.Button)
    self.buttonTimeLine = GetComponentWithPath(self.root, "Center/Child/timeLineBtn", ComponentTypeName.Button)
    self.buttonChat = GetComponentWithPath(self.root, "Center/Child/chatBtn", ComponentTypeName.Button)

    -- 二维码
    self.qrCodeImg = GetComponentWithPath(self.root, "Center/Child/SpriteQRCode", ComponentTypeName.Image);
    self.labelReward = GetComponentWithPath(self.root, "Center/Child/LabelGameName", ComponentTypeName.Text);

    -- 截屏画布实体
    self.shareCanvasGB = UnityEngine.GameObject.Find("GameRoot/Game/UIRoot/UIWindowParent/CanvasShareOnly");
end

function ShareMuseumView:on_view_init()

end

-- 更新分享图片视图
function ShareMuseumView:updateShareImage(data, spriteShareImage)

    if self.shareImagePrefab == nil then
        -- 实例化分享图片预置
        self.shareImagePrefab = ViewUtil.InitGameObject("henanmj/module/shareimage/shareimage_museum.prefab", "ShareImage_Museum", self.shareCanvasGB);
        -- 二维码图片
        self.spriteQRCode = GetComponentWithPath(self.shareImagePrefab, "Center/Child/SpriteQRCode", ComponentTypeName.Image);
        -- 游戏名标签
        self.labelGameName = GetComponentWithPath(self.shareImagePrefab, "Center/Child/LabelGameName", ComponentTypeName.Text);

    else
        self.shareImagePrefab:SetActive(true);
    end

    self.spriteQRCode.sprite = spriteShareImage;
    self.labelGameName.text = string.format( "亲友圈%d的微信群二维码",data.parlorNum)
end

return ShareMuseumView