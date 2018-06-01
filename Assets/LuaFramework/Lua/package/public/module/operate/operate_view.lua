-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local OperateView = Class('operateView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local ComponentUtil = ModuleCache.ComponentUtil
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple
local CSmartTimer = ModuleCache.SmartTimer.instance
local PlayModeUtil = ModuleCache.PlayModeUtil
local GestureType = {
    None = 0,
    Left = 1,
    Right= 2,
}

function OperateView:initialize(...)
    -- 初始View
    View.initialize(self, "public/module/operate/public_operate.prefab", "Public_Operate", 0);
    View.set_1080p(self);


    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);

    -- 用户信息组件
    -- 玩家头像
    self.spritePlayerIcon = GetComponentWithSimple(self.root, "SpritePlayerIcon", ComponentTypeName.Image);
    -- 玩家名字标签
    self.labelPlayerName = GetComponentWithSimple(self.root, "LabelPlayerName", ComponentTypeName.Text);
    -- 玩家ID标签
    self.labelPlayerID = GetComponentWithSimple(self.root, "LabelPlayerID", ComponentTypeName.Text);
    -- 体力标签
    self.labelPower = GetComponentWithSimple(self.root, "LabelPower", ComponentTypeName.Text);
    -- 复制按钮
    self.buttonCopy = GetComponentWithSimple(self.root, "ButtonCopyID", ComponentTypeName.Button);
    -- 头像按钮
    self.buttonRole = GetComponentWithSimple(self.root, "ButtonRole", ComponentTypeName.Button);
    -- 体力按钮
    self.buttonPower = GetComponentWithSimple(self.root, "Gem", ComponentTypeName.Button);

    -- 运营活动模板
    self.itemOperateActivity = GetComponentWithSimple(self.root, "ItemOperateActivity", ComponentTypeName.Transform).gameObject;
    self.itemOperateActivity:SetActive(false);
    -- 推荐游戏模板
    self.itemGame = GetComponentWithSimple(self.root, "itemGame", ComponentTypeName.Transform).gameObject;
    self.itemGame:SetActive(false);
    -- 亲友圈模板
    self.itemMuseum = GetComponentWithSimple(self.root, "itemMuseum", ComponentTypeName.Transform).gameObject;
    self.itemMuseum:SetActive(false);

    -- 推荐游戏toggle
    self.toggleGame = GetComponentWithSimple(self.root, "ToggleGame", ComponentTypeName.Toggle);
    local onToggleGame = function(flag)
        -- 点击发行toggle
        self:onToggleOperate(flag, 1);
    end
    self.toggleGame.onValueChanged:AddListener(onToggleGame);
    -- 亲友圈toggle
    self.toggleMuseum = GetComponentWithSimple(self.root, "ToggleMuseum", ComponentTypeName.Toggle);
    local onToggleMuseum = function(flag)
        -- 点击发行toggle
        self:onToggleOperate(flag, 2);
    end
    self.toggleMuseum.onValueChanged:AddListener(onToggleMuseum);

    -- 更多游戏按钮
    self.buttonMoreGame = GetComponentWithSimple(self.root, "ItemMoreGame", ComponentTypeName.Button);

    self.spriteHolder = GetComponentWithSimple(self.root, "SpriteHolder", "SpriteHolder");

    self.goShowHall = ModuleCache.ComponentManager.Find(self.root, "Center/ButtonHall");

    -- 发行翻页组件
    self.adContentInfo = { }
    self.adContentInfo.curIndex = 0
    -- self.adContentInfo.cellSize = { x = 1920, y = 1080 }
    self.adContentInfo.cellSize = { x = self.rootTransform.sizeDelta.x, y = self.rootTransform.sizeDelta.y }
    self.adContentInfo.root = GetComponentWithSimple(self.root, "AdContent", ComponentTypeName.Transform).gameObject
    self.adContentInfo.scrollRectAdContent = GetComponentWithSimple(self.root, "ADScrollView", ComponentTypeName.ScrollRect)
    self.adContentInfo.prefabItem = GetComponentWithSimple(self.root, "ADItem", ComponentTypeName.Transform).gameObject
    self.adContentInfo.prefabPageTag = GetComponentWithSimple(self.root, "ADPoint", ComponentTypeName.Transform).gameObject
    self.spriteHolder = GetComponentWithSimple(self.root, "SpriteHolder", "SpriteHolder");
    -- 广告翻页item列表
    self.adItemList = { };
end

function OperateView:init(operateList, module)

    self.operateList = operateList;
    self.model = module.model;
    self.module = module;
    -- 发行页签类型
    self.typeOperate = 1;

    -- 更新推荐游戏视图
    self:updateRecommendGameView();
    -- 更新运营活动视图
    self:updateOperateActivityView();

    -- 切换页签
    self:switchToggle();

    self:refreshAdContent()
    self:start_auto_play_adcontent()
end

-- 更新用户信息视图
function OperateView:updateUserInfoView(userData)

    self.userData = userData;
    local onPlayerAvatar = function(sprite)
        -- 玩家头像
        self.spritePlayerIcon.sprite = sprite;
    end
    self:startDownLoadHeadIcon(userData.headImg, onPlayerAvatar);

    -- 玩家名字
    self.labelPlayerName.text = Util.filterPlayerName(userData.nickname, 10);
    -- 玩家id
    self.labelPlayerID.text = "ID:" .. userData.userId;
    -- 体力
    self.labelPower.text = Util.filterPlayerGoldNum(tonumber(userData.coins));
end

-- 更新运营活动视图
function OperateView:updateOperateActivityView()

    -- 重复利用itemOperateActivity模板
    local childCount = self.itemOperateActivity.transform.parent.childCount;
    for i = 0, childCount - 1 do

        self.itemOperateActivity.transform.parent:GetChild(i).gameObject:SetActive(false);
    end

    for key, operateActivity in ipairs(self.operateList.func) do
        -- 重复利用itemOperateActivity模板
        local itemClone = nil;
        if key > childCount - 1 then
            itemClone = self:clone(self.itemOperateActivity.gameObject, self.itemOperateActivity.transform.parent.gameObject, Vector3.zero);
            itemClone.name = itemClone.name .. key;
        else
            itemClone = self.itemOperateActivity.transform.parent:GetChild(key).gameObject;
            itemClone:SetActive(true);
        end

        -- 运营活动按钮
        local buttonOperateActivity = GetComponentWithSimple(itemClone, itemClone.name, ComponentTypeName.Button);
        buttonOperateActivity.onClick:RemoveAllListeners();

        local onClickButtonActivity = function()
            -- 点击运营活动按钮
            self:onClickOperateActivityButton(operateActivity);
        end
        buttonOperateActivity.onClick:AddListener(onClickButtonActivity);

        -- 活动标题标签
        local labelOpeateActivity = GetComponentWithSimple(itemClone, "LabelOperateActivity", ComponentTypeName.Text);
        labelOpeateActivity.text = operateActivity.content;
    end

end

-- 更新推荐游戏视图
function OperateView:updateRecommendGameView()

    -- 重复利用itemOperateActivity模板
    local childCount = self.itemGame.transform.parent.childCount;
    for i = 0, childCount - 1 do

        self.itemGame.transform.parent:GetChild(i).gameObject:SetActive(false);
    end

    for key, operateGame in ipairs(self.operateList.games) do
        -- 重复利用itemOperateActivity模板
        local itemClone = nil;
        if key > childCount - 1 then
            itemClone = self:clone(self.itemGame.gameObject, self.itemGame.transform.parent.gameObject, Vector3.zero);
            itemClone.name = itemClone.name .. key;
        else
            itemClone = self.itemGame.transform.parent:GetChild(key).gameObject;
            itemClone:SetActive(true);
        end

        -- 推荐游戏按钮
        local buttonGame = GetComponentWithSimple(itemClone, itemClone.name, ComponentTypeName.Button);

        -- 推荐游戏名字标签
        local labelGameName = GetComponentWithSimple(itemClone, "LabelGameName", ComponentTypeName.Text);

        -- 推荐游戏底板
        local spriteBase = GetComponentWithSimple(itemClone, itemClone.name, ComponentTypeName.Image);
        local spriteBaseTemp = nil;
        -- 默认
        if operateGame.type == -1 then
            spriteBaseTemp = self.spriteHolder:FindSpriteByName("defaultBase");
            -- 推荐(0=无标签 1=推荐 2=热门)
        elseif operateGame.type == 0 or operateGame.type == 1 or operateGame.type == 2 then
            spriteBaseTemp = self.spriteHolder:FindSpriteByName("recommendBase");
            -- 官方
        elseif operateGame.type == -99 then
            spriteBaseTemp = self.spriteHolder:FindSpriteByName("officialBase");
        end
        spriteBase.sprite = spriteBaseTemp;
        -- 游戏icon
        local spriteGameIcon = GetComponentWithSimple(itemClone, "SpriteGameIcon", ComponentTypeName.Image);
        local provinceConf = ModuleCache.PlayModeUtil.getProvinceByAppName(operateGame.province)
        local playModeConf = PlayModeUtil.getDeepCopyTable(require(provinceConf.modName))
        local gameName = string.split(operateGame.gameId, "_")[2]
        local playMode = PlayModeUtil.getInfoByGameName(gameName, playModeConf)
        spriteGameIcon.sprite = ModuleCache.PlayModeUtil.getHeadIconRes(playMode, provinceConf.id);
        spriteGameIcon:SetNativeSize();

        buttonGame.onClick:RemoveAllListeners();
        local onClickButtonGame = function()
            -- 点击推荐游戏按钮
            self:onClickOperateGameButton(provinceConf.id, playMode);
        end
        buttonGame.onClick:AddListener(onClickButtonGame);

        -- 推荐游戏名字
        labelGameName.text = playMode.name;
    end
end

-- 更新亲友圈视图
function OperateView:updateMuseumView(museumList)
    -- 重复利用itemOperateActivity模板
    local childCount = self.itemMuseum.transform.parent.childCount;
    for i = 0, childCount - 1 do

        self.itemMuseum.transform.parent:GetChild(i).gameObject:SetActive(false);
    end

    for key, museum in ipairs(museumList) do
        -- 重复利用itemOperateActivity模板
        local itemClone = nil;
        if key > childCount - 1 then
            itemClone = self:clone(self.itemMuseum.gameObject, self.itemMuseum.transform.parent.gameObject, Vector3.zero);
            itemClone.name = itemClone.name .. key;
        else
            itemClone = self.itemMuseum.transform.parent:GetChild(key).gameObject;
            itemClone:SetActive(true);
        end

        -- 亲友圈按钮
        local buttonMuseum = GetComponentWithSimple(itemClone, itemClone.name, ComponentTypeName.Button);
        local provinceConf = ModuleCache.PlayModeUtil.getProvinceByAppName(museum.province)
        local playModeConf = PlayModeUtil.getDeepCopyTable(require(provinceConf.modName))
        local gameName = string.split(museum.gameId, "_")[2]
        local playMode = PlayModeUtil.getInfoByGameName(gameName, playModeConf)
        buttonMuseum.onClick:RemoveAllListeners();
        local onClickButtonMuseum = function()
            -- 点击推荐游戏按钮
            self:onClickMuseumButton(provinceConf.id, playMode, museum);
        end
        buttonMuseum.onClick:AddListener(onClickButtonMuseum);
        -- 亲友圈号标签
        local labelMusuemNumber = GetComponentWithSimple(itemClone, "LabelMuseumNumber", ComponentTypeName.Text);
        -- 亲友圈圈名标签
        local labelMusuemName = GetComponentWithSimple(itemClone, "LabelMuseumName", ComponentTypeName.Text);
        -- 亲友圈icon
        local spriteMusuemIcon = GetComponentWithSimple(itemClone, "SpriteMuseumIcon", ComponentTypeName.Image);
        local onMuseumIcon = function(sprite)
            -- 亲友圈icon
            spriteMusuemIcon.sprite = sprite;
        end
        self:startDownLoadHeadIcon(museum.parlorLogo, onMuseumIcon);

        -- 亲友圈号
        labelMusuemNumber.text = "0" .. museum.parlorNum;
        -- 亲友圈名
        labelMusuemName.text = museum.gameName;
    end
end

-- 点击推荐游戏按钮
function OperateView:onClickOperateGameButton(provinceId, playMode)

    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    -- 请求发送发名单协议
    self.model:sendWhilt(self.module, provinceId, playMode);
end

-- 点击亲友圈按钮
function OperateView:onClickMuseumButton(provinceId, playMode, museum)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")

    -- 请求点击亲友圈按钮协议
    self.model:getClickParlor(museum.parlorId);

    local onComplete = function()
        local module = ModuleCache.ModuleManager.show_module("henanmj", "hall");
        -- 打开亲友圈
        module:get_museum_list();
    end
    -- 请求发送发名单协议
    self.model:sendWhilt(self.module, provinceId, playMode, onComplete);
end

-- 点击运营活动按钮
function OperateView:onClickOperateActivityButton(operateActivity)

    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    local data = {
        link = operateActivity.url,
        style = 3,
        hide = false
    }
    -- 展示h5界面
    ModuleCache.ModuleManager.show_module("henanmj", "webview", data);
end

-- 点击发行toggle
function OperateView:onToggleOperate(flag, type)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if flag then

        -- 防重复点击
        if self.typeOperate ~= type then
            self.typeOperate = type;
            print("11111===", self.typeOperate);

            -- 亲友圈
            if self.typeOperate == 2 then
                -- 请求获取亲友圈列表协议
                self.model:getParlorList();
            end
        end
    end
end

-- 切换页签
function OperateView:switchToggle()

    -- 推荐游戏
    if self.typeOperate == 1 then

        self.toggleGame.isOn = true;
        self.toggleMuseum.isOn = false;
        -- 亲友圈
    elseif agentType == 2 then

        self.toggleGame.isOn = false;
        self.toggleMuseum.isOn = true;
    end
end

-------------------- 发行翻页---------------------------------
function OperateView:start_auto_play_adcontent()
    self.autoPlayAdTimeEventID = self:subscibe_time_event(5, false, 0):OnComplete( function(t)
        if (self.adContentInfo.isDraging) then
            return
        end

        if (self.lastIndex == 1) then
            self.auto_play_offset = 1
        elseif (self.lastIndex == #self.adContentInfo.pageSelectImageArray) then
            self.auto_play_offset = -1
        end
        if (not self.auto_play_offset) then
            self.auto_play_offset = 1
        end

        self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition = self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition + 0.01 * self.auto_play_offset

        self:onBeginDragAdContent()
        self:onEndDragAdContent(self.auto_play_offset)
        self:stop_auto_play_adcontent()
        self:start_auto_play_adcontent()
    end ).id
end

function OperateView:stop_auto_play_adcontent()
    if (self.autoPlayAdTimeEventID) then
        CSmartTimer:Kill(self.autoPlayAdTimeEventID)
        self.autoPlayAdTimeEventID = nil
    end
end

function OperateView:refreshAdContent()

    for key, item in ipairs(self.adItemList) do
        UnityEngine.Object.Destroy(item);
    end

    --    local adSpriteList = { };
    --    for i = 1, 5 do
    --        local adSprite = self.spriteHolder:FindSpriteByName(i .. "");
    --        table.insert(adSpriteList, adSprite);
    --    end

    local adSpriteList = self.operateList.spriteImageList;
    -- 广告图片只有一张,禁止拖拽和隐藏标签
    local isShowTag = true;
    if #adSpriteList == 1 then
        isShowTag = false;
    end
    self.adContentInfo.prefabPageTag.transform.parent.gameObject:SetActive(isShowTag);

    self.adContentInfo.ads = adSpriteList
    self.adContentInfo.gameObjectAds = { }
    local len = #adSpriteList
    local x = len * self.adContentInfo.cellSize.x
    local y = self.adContentInfo.scrollRectAdContent.content.sizeDelta.y
    self.adContentInfo.scrollRectAdContent.content.sizeDelta = ModuleCache.CustomerUtil.ConvertVector2(x, y)
    self.adContentInfo.pageSelectImageArray = { }

    for i = 1, len do
        local item = ModuleCache.ComponentUtil.InstantiateLocal(self.adContentInfo.prefabItem, self.adContentInfo.scrollRectAdContent.content.gameObject)
        item.name = "ad_item"
        local itemRectTransform = GetComponentWithSimple(item, item.name, ComponentTypeName.RectTransform)
        itemRectTransform.sizeDelta = Vector2.New(self.rootTransform.sizeDelta.x, self.rootTransform.sizeDelta.y);
        table.insert(self.adItemList, item);
        local x =(i - 1) * self.adContentInfo.cellSize.x
        ModuleCache.TransformUtil.SetX(item.transform, x, true)
        ModuleCache.TransformUtil.SetY(item.transform, 0, true)
        item:SetActive(true)
        local spriteAD = GetComponentWithSimple(item, item.name, ComponentTypeName.Image);
        spriteAD.sprite = adSpriteList[i];
        table.insert(self.adContentInfo.gameObjectAds, item)


        local pageTag = ModuleCache.ComponentUtil.InstantiateLocal(self.adContentInfo.prefabPageTag, self.adContentInfo.prefabPageTag.transform.parent.gameObject)
        table.insert(self.adItemList, pageTag);
        pageTag:SetActive(true)
        local imageSelect = ModuleCache.ComponentUtil.GetComponentWithPath(pageTag, "Select", ComponentTypeName.Image)
        table.insert(self.adContentInfo.pageSelectImageArray, imageSelect)
    end
    self.lastIndex = self.lastIndex == nil and 1  or self.lastIndex
    self:setScrollViewDragStatus()
    self:refreshAdsPageTag(self.lastIndex)
end


function OperateView:update()
    if self.adContentInfo.isDraging and  #self.adContentInfo.pageSelectImageArray > 1 then
        if (self.lastIndex == 1 and self:getGestureDir() == GestureType.Left) or
                (self.lastIndex == #self.adContentInfo.pageSelectImageArray and self:getGestureDir() == GestureType.Right)then
            self.adContentInfo.scrollRectAdContent.horizontal = true
        end
    end
end

--获取拖拽时手势方向
function OperateView:getGestureDir()
    local lastPosX = ModuleCache.UnityEngine.Input.mousePosition.x;
    if lastPosX - self.startDragPosX > 0 then
        return GestureType.Right
    elseif lastPosX - self.startDragPosX < 0 then
        return GestureType.Left
    else
        return GestureType.None
    end
end

function OperateView:onBeginDragAdContent(obj, arg)
    self.adContentInfo.isDraging = true
    self.startDragPosX = ModuleCache.UnityEngine.Input.mousePosition.x
end

function OperateView:onDragAdContent(obj, arg)
    self.onDragDelta = arg.delta
    local targetPos, targetIndex = self:getNearestScrollViewPos()
    self:refreshAdsPageTag(targetIndex)
end



function OperateView:refreshAdsPageTag(targetIndex)
    for i = 1, #self.adContentInfo.pageSelectImageArray do
        if (targetIndex == i) then
            ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.pageSelectImageArray[i].gameObject, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.pageSelectImageArray[i].gameObject, false)
        end
    end

end

function OperateView:onEndDragAdContent(offsetIndex, obj, arg)
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

    self:setScrollViewDragStatus()
end

--设置广告ScrollView是否禁用拖拽
function OperateView:setScrollViewDragStatus()
    if self.lastIndex == 1  or self.lastIndex == #self.adContentInfo.pageSelectImageArray then
        self.adContentInfo.scrollRectAdContent.horizontal = false
    else
        self.adContentInfo.scrollRectAdContent.horizontal = true
    end
end


function OperateView:getNearestScrollViewPos(offsetIndex, offset)
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
-----------------------------------------------------------------

-- 下载头像
function OperateView:startDownLoadHeadIcon(url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if (self) then
                    -- self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if (callback and(not self.isDestroy)) then
                callback(tex)
            end
        end
    end , nil, true)
end

-- 克隆
function OperateView:clone(obj, parent, pos)
    local target = ComponentUtil.InstantiateLocal(obj, parent, pos);
    target.name = obj.name;
    ComponentUtil.SafeSetActive(target, true);
    return target;
end

return OperateView