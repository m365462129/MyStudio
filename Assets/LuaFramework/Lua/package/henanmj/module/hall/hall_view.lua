-- ========================== 默认依赖 =======================================
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local ModuleCache = ModuleCache
local PlayModeUtil = ModuleCache.PlayModeUtil

--- @class HallView : View
local HallView = class('hallView', View)
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentTypeName = ComponentTypeName


function HallView:initialize()
    -- 初始View
    View.initialize(self, "henanmj/module/hall/henanmj_windowhall.prefab", "HeNanMJ_WindowHall")
    View.set_1080p(self)
    -- 分享奖励图标
    self.spriteShareReward = GetComponentWithPath(self.root, "Footer/Menu/But (4)/ButtonShare/SpriteReward", ComponentTypeName.Image);

    self.buttonCreateRoom = GetComponentWithPath(self.root, "MainMenu/Create", ComponentTypeName.Button)
    self.buttonJoinRoom = GetComponentWithPath(self.root, "MainMenu/Join", ComponentTypeName.Button)
    self.buttonMuseum = GetComponentWithPath(self.root, "Footer/PaiYouQuan", ComponentTypeName.Button)
    self.buttonGoldRoom = GetComponentWithPath(self.root, "MainMenu/GoldBtn", ComponentTypeName.Button)
    self.goldLock = GetComponentWithPath(self.root, "MainMenu/GoldBtn/Lock", ComponentTypeName.Transform).gameObject
    --比赛场
    self.buttonMatch = GetComponentWithPath(self.root, "MainMenu/Match", ComponentTypeName.Button)
    self.matchLock = GetComponentWithPath(self.root,"MainMenu/Match/Lock",ComponentTypeName.Transform).gameObject

    -- 活动按钮
    self.buttonActivity = GetComponentWithPath(self.root, "Footer/Menu/But (1)/ButtonActivity", ComponentTypeName.Button)
    -- 客服按钮
    self.buttonCustomerService = GetComponentWithPath(self.root, "Footer/Menu/But (2)/ButtonCustomerService", ComponentTypeName.Button)
    -- 背包按钮
    self.buttonBag = GetComponentWithPath(self.root, "Footer/Menu/But (6)/ButtonBag", ComponentTypeName.Button)
    -- 背包红点
    self.spriteBagRed = GetComponentWithPath(self.root, "Footer/Menu/But (6)/ButtonBag/SpriteRed", ComponentTypeName.Image)
    self.buttonCheckResult = GetComponentWithPath(self.root, "Footer/Menu/But (3)/ButtonResult", ComponentTypeName.Button)
    self.buttonShop = GetComponentWithPath(self.root, "Footer/Menu/But (5)/ButtonShop", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Footer/Menu/But (4)/ButtonShare", ComponentTypeName.Button)
    self.buttonPlayingInstrution = GetComponentWithPath(self.root, "Bottom/StatusBar/ButtonHowToPlay", ComponentTypeName.Button)
    self.buttonSetting = GetComponentWithPath(self.root, "Footer/Menu/But (7)/ButtonSettings", ComponentTypeName.Button)
    -- self.buttonBillboard = GetComponentWithPath(self.root, "Bottom/StatusBar/ButtonBillboard", ComponentTypeName.Button)
    self.buttonRole = GetComponentWithPath(self.root, "Header/User/Head/Role", ComponentTypeName.Button)
    self.buttonAddRoomCard = GetComponentWithPath(self.root, "Header/User/Currency/Gem", ComponentTypeName.Button)
    -- 免费领钻按钮
    self.buttonFreeDiamond = GetComponentWithPath(self.root, "Operate/Activity (1)", ComponentTypeName.Button)
    self.buttonFreeDiamond.gameObject:SetActive(false);

    self.buttonHongBaoHuoDong = GetComponentWithPath(self.root, "Operate/buttonHongBaoHuoDong", ComponentTypeName.Button)
    self.buttonHongBaoHuoDong.gameObject:SetActive(false);


    -- 红包雨按钮
    self.goHongBao = ModuleCache.ComponentManager.Find(self.root, "Operate/ActivityHongBao")
    self.goHongBao:SetActive(false);


    --幸运转盘
    self.buttonLucky = GetComponentWithPath(self.root,"Operate/Activity (2)", ComponentTypeName.Button)
    self.buttonLucky.gameObject:SetActive(false);

    -- 实名认证按钮
    self.buttonVerify = GetComponentWithPath(self.root, "Operate/Activity (3)", ComponentTypeName.Button)
    -- 排行榜按钮
    self.buttonRanking = GetComponentWithPath(self.root, "Side/LeaderBordBtn", ComponentTypeName.Button)
    self.buttonVerify.gameObject:SetActive(false);

    self.textPlayerName = GetComponentWithPath(self.root, "Header/User/Head/TextName", ComponentTypeName.Text)
    self.imagePlayerHeadIcon = GetComponentWithPath(self.root, "Header/User/Head/Avatar/Image", ComponentTypeName.Image)
    self.textPlayerID = GetComponentWithPath(self.root, "Header/User/Name/TextID", ComponentTypeName.Text)
    self.textCardNum = GetComponentWithPath(self.root, "Header/User/Currency/Gem/TextNum", ComponentTypeName.Text)
    -- self.textCoinName = GetComponentWithPath(self.root, "Top/StatusBar/DiamondCard/TextName", ComponentTypeName.Text)
    self.textGoldNum = GetComponentWithPath(self.root, "Header/User/Currency/Gold/TextNum", ComponentTypeName.Text)

    self.textPlayerName.text = ''
    self.textPlayerID.text = ''
    self.textCardNum.text = ''
    -- self.textCoinName.text = ""

    -- self.adContentInfo = { }
    -- self.adContentInfo.curIndex = 0
    -- self.adContentInfo.cellSize = { x = 240, y = 355 }
    -- self.adContentInfo.root = GetComponentWithPath(self.root, "Center/AdContent", ComponentTypeName.Transform).gameObject
    -- self.adContentInfo.root:SetActive(false)
    -- self.adContentInfo.scrollRectAdContent = GetComponentWithPath(self.root, "Center/AdContent/Scroll View", ComponentTypeName.ScrollRect)
    -- self.adContentInfo.prefabItem = GetComponentWithPath(self.root, "Center/AdContent/Scroll View/item", ComponentTypeName.Transform).gameObject
    -- self.adContentInfo.prefabPageTag = GetComponentWithPath(self.root, "Center/AdContent/Tags/Point", ComponentTypeName.Transform).gameObject

    self.systemAnnounceRoot = ModuleCache.ComponentUtil.Find(self.root, "SystemAnnounce")
    self.systemAnnounceTextTransform = self.rootTransform:Find("SystemAnnounce/Image/Mask/Text")
    self.systemAnnounceText = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "SystemAnnounce/Image/Mask/Text", ComponentTypeName.Text)
    self.systemAnnounceRoot:SetActive(false)

    self.goUpdateVersionBubble = GetComponentWithPath(self.root, "Footer/Menu/But (7)/ButtonSettings/VersionBubble", ComponentTypeName.Transform).gameObject
    self.color = { }
    self.color[1] = Color.New(6 / 255, 73 / 255, 107 / 255, 1)
    self.color[2] = Color.New(134 / 255, 55 / 255, 8 / 255, 1)
    self.color[3] = Color.New(50 / 255, 108 / 255, 6 / 255, 1)
    self.color[4] = Color.New(17 / 255, 90 / 255, 30 / 255, 1)
    self.leftLayout = GetComponentWithPath(self.root, "Operate", ComponentTypeName.GridLayoutGroup)
    self.uiStateSwitcher = GetComponentWithPath(self.root, "Footer/Menu", "UIStateSwitcher")
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        self.uiStateSwitcher:SwitchState("IosCheck")
        ModuleCache.ComponentManager.GetComponent(self.root, "UnityEngine.Animator").enabled = false
    else
        -- 实例化免费领钻预置
        -- self.freeDiamondPrefab = ViewUtil.InitGameObject("public/effect/mianfeilingzuan/prefab/anim_mianfeilingzuan.prefab", "Anim_MianFeiLingZuan", self.buttonFreeDiamond.gameObject);
        -- self.freeDiamondPrefab.transform:SetAsFirstSibling()
    end


    if ModuleCache.GameManager.lockAssetUpdate then
        self.goUpdateVersionBubble:SetActive(true)
        GetComponentWithPath(self.root, "Footer/Menu/But (7)/ButtonSettings/VersionBubble/Text", ComponentTypeName.Text).text = "锁定版本，不再更新任何资源"
    end
    self.test = GetComponentWithPath(self.root, "Test", ComponentTypeName.Transform).gameObject
    -- print("是否为测试模式：",ModuleCache.GameManager.isTestUser,self.test)
    ModuleCache.ComponentUtil.SafeSetActive(self.test, ModuleCache.GameManager.isTestUser)
end

function HallView:on_view_init()


end

-- 刷新与玩法相关的显示
function HallView:refreshPlayMode()
    local playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
    --local bgImg = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image)
    local playModeText = GetComponentWithPath(self.root, "Header/Switch/Text", ComponentTypeName.Text)
    ModuleCache.ComponentUtil.SafeSetActive(self.goldLock.gameObject, not playMode.isOpenGold)
    playModeText.text = playMode.hallName
    --bgImg.sprite = PlayModeUtil.getBgRes()
end

-- 设置中间按钮
function HallView:setCenterBtn(btn, img)
    local centerSp = GetComponentWithPath(btn.gameObject, "Anim", ComponentTypeName.Image)
    centerSp.sprite = PlayModeUtil.getBtnRes(btn.gameObject.name)
    centerSp:SetNativeSize()
end

-- 通过游戏ID设置Image组件的sprite
function HallView:SetImageSpriteByGameId(_targetImage, _targetSpriteHolder, _targetSp)
    local sprite = _targetSpriteHolder:FindSpriteByName(_targetSp)
    if (sprite == nil) then
        sprite = _targetSpriteHolder:FindSpriteByName("HongZhong")
    end
    _targetImage.sprite = sprite
end



function HallView:refreshPlayerInfo(roleData)
    if ((not roleData) or(not roleData.cards)) then
        return
    end
    self.textCardNum.text = Util.filterPlayerGoldNum(tonumber(roleData.cards) + tonumber(roleData.coins))
    if roleData.gold then
        self.textGoldNum.text = Util.filterPlayerGoldNum(roleData.gold)
    else
        self.textGoldNum.text = "0"
    end
    local that = self
    UserUtil.saveUser(roleData, function(saveData)
        if not self.isDestroy then
            that:showPlayerInfo(saveData)
        end
    end )
end

function HallView:showPlayerInfo(data)

    if data.headSprite then
        self.imagePlayerHeadIcon.sprite = data.headSprite
    end
    self.textPlayerName.text = Util.filterPlayerName(data.nickname, 10)
    self.textPlayerID.text = "ID:" .. data.userId
end


function HallView:refreshAdContent(ads)
    print("ads len = " .. #ads)
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        self.adContentInfo.root:SetActive(false)
    else
        self.adContentInfo.root:SetActive(false)
    end

    self.adContentInfo.ads = ads
    self.adContentInfo.gameObjectAds = { }
    local len = #ads
    local x = len * self.adContentInfo.cellSize.x
    local y = self.adContentInfo.scrollRectAdContent.content.sizeDelta.y
    self.adContentInfo.scrollRectAdContent.content.sizeDelta = ModuleCache.CustomerUtil.ConvertVector2(x, y)
    self.adContentInfo.pageSelectImageArray = { }

    if (self.adGameObjects) then
        for k, v in pairs(self.adGameObjects) do
            UnityEngine.GameObject.Destroy(v.gameObject)
        end
    end
    self.adGameObjects = { }
    for i = 1, len do
        local item = ModuleCache.ComponentUtil.InstantiateLocal(self.adContentInfo.prefabItem, self.adContentInfo.scrollRectAdContent.content.gameObject)
        table.insert(self.adGameObjects, item)
        item.name = "ad_item"
        local x =(i - 1) * self.adContentInfo.cellSize.x
        ModuleCache.TransformUtil.SetX(item.transform, x, true)
        ModuleCache.TransformUtil.SetY(item.transform, 0, true)
        item:SetActive(true)
        self:fillItem(item, ads[i].img)
        table.insert(self.adContentInfo.gameObjectAds, item)


        local pageTag = ModuleCache.ComponentUtil.InstantiateLocal(self.adContentInfo.prefabPageTag, self.adContentInfo.prefabPageTag.transform.parent.gameObject)
        table.insert(self.adGameObjects, pageTag)
        pageTag:SetActive(true)
        local imageSelect = ModuleCache.ComponentManager.GetComponentWithPath(pageTag, "Select", ComponentTypeName.Image)
        table.insert(self.adContentInfo.pageSelectImageArray, imageSelect)
    end
    self:refreshAdsPageTag(1)
end


function HallView:fillItem(item, url)
    local image = ModuleCache.ComponentManager.GetComponent(item, ComponentTypeName.Image)
    TableUtil.only_download_head_icon(image, url)
end


function HallView:onBeginDragAdContent(obj, arg)
    self.adContentInfo.isDraging = true
end

function HallView:onDragAdContent(obj, arg)
    self.onDragDelta = arg.delta
    local targetPos, targetIndex = self:getNearestScrollViewPos()
    self:refreshAdsPageTag(targetIndex)
end



function HallView:refreshAdsPageTag(targetIndex)
    for i = 1, #self.adContentInfo.pageSelectImageArray do
        if (targetIndex == i) then
            ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.pageSelectImageArray[i].gameObject, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.pageSelectImageArray[i].gameObject, false)
        end
    end

end

function HallView:onEndDragAdContent(offsetIndex, obj, arg)
    if (not self.adContentInfo.isDraging) then
        return
    end
    local targetPos, targetIndex, curPos = self:getNearestScrollViewPos()

    local offset = 0
    if (arg and self.onDragDelta.x < 0) then
        if (self.lastIndex == targetIndex) then
            if (targetPos < curPos) then
                offset = 1
            end
        else

        end
    elseif (arg and self.onDragDelta.x > 0) then
        if (self.lastIndex == targetIndex) then
            if (targetPos > curPos) then
                offset = -1
            end
        else

        end
    end

    self.adContentInfo.isDraging = false
    targetPos, targetIndex, curPos = self:getNearestScrollViewPos(offsetIndex, offset)
    ModuleCache.CustomerUtil.ToGeterSeterFloat( function()
        if not self.adContentInfo then
            print("已经销毁了")
            return
        end
        return self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition
    end ,
    function(x)
        if self.isDestroy then
            return
        end
        if self.adContentInfo and self.adContentInfo.scrollRectAdContent then
            self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition = x
            if (Util.getPreciseDecimal(x, 3) == Util.getPreciseDecimal(targetPos, 3)) then
                self:refreshAdsPageTag(targetIndex)
                self.lastIndex = targetIndex
            end
        end
    end ,
    targetPos, 0.2)
end


function HallView:getNearestScrollViewPos(offsetIndex, offset)
    offsetIndex = offsetIndex or 0
    offset = offset or 0
    local curPos = self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition
    local minOffset = 1
    local targetPosX = curPos
    local targetIndex = 1
    local len = #self.adContentInfo.gameObjectAds
    for i = 1, len do
        local pos =(i - 1) /(len - 1)
        local tmpOffset = math.abs(curPos - pos)
        if (minOffset > tmpOffset) then
            minOffset = tmpOffset
            targetPosX = math.min(math.max((i - 1 + offsetIndex + offset) /(len - 1), 0), 1)
            targetIndex = math.min(math.max(i + offsetIndex + offset, 1), len)
        end
    end
    return targetPosX, targetIndex, curPos
end

-- 更新奖励视图
function HallView:updateRewardView(activityList, code)

    -- 通过code获取活动数据
    local activity = self:getActivityByCode(activityList, code);
    -- 空数据,奖励图标不显示
    if activity == nil then

        activity = { };
        activity.isReceive = 1;
    end

    local isReceive = activity.isReceive;

    -- 是否显示奖励图标
    local isShowReward = false;
    -- 0未领取 1=已领取
    if isReceive == 0 then

        isShowReward = true;
    elseif isReceive == 1 then
        isShowReward = false;
    end

    self.buttonFreeDiamond.gameObject:SetActive(isShowReward);
    self:setGridActive()
end

-- 更新主界面红点(此方法目前只有背包)
function HallView:updateMainRedPoint(data)

    if data.packItemHighlightNum then
        if data.packItemHighlightNum > 0 then
            self.spriteBagRed.gameObject:SetActive(true);
        elseif data.packItemHighlightNum == 0 then
            self.spriteBagRed.gameObject:SetActive(false);
        end
    end

end

function HallView:updateVerifyStatus(view)
    self.buttonVerify.gameObject:SetActive(view);
    self:setGridActive()
end

function HallView:updateLuckyStatus(view)
    self.buttonLucky.gameObject:SetActive(view)
    self.setGridActive()
end

function HallView:updateRedStatus(show, data)
    self.goHongBao:SetActive(show)
    --if data.partner then
    --    self.buttonRedName.gameObject:SetActive(true)
    --    self.buttonRedName.text = data.partner
    --else
    --    self.buttonRedName.gameObject:SetActive(false)
    --end
    --self:setGridActive()
end


function HallView:setGridActive()
    self.leftLayout.enabled = false
    self.leftLayout.enabled = true
    local layout = function()
        WaitForEndOfFrame()
        if not self.isDestroy then
            self.leftLayout.enabled = false
        end
    end
    self:start_unity_coroutine(layout)
end

-- 通过code获取活动数据
function HallView:getActivityByCode(activityList, code)

    for key, activityTemp in ipairs(activityList) do

        if activityTemp.code == code then

            activity = activityTemp;
            return activity;
        end
    end

    return activity;
end

function HallView:CalcNearestPos()

end

return HallView