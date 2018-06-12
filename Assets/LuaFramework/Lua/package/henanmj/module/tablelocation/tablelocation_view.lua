-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableLocationView = Class('tableLocationView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local ComponentUtil = ModuleCache.ComponentUtil
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple

function TableLocationView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/tablelocation/henanmj_tablelocation.prefab", "HeNanMJ_TableLocation", 1);

    -- 返回按钮
    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);

    self.spriteHolder = GetComponentWithSimple(self.root, "SpriteHolder", "SpriteHolder");
    self.itemPlayer = GetComponentWithSimple(self.root, "PlayerItem", ComponentTypeName.Transform).gameObject;
    self.itemPlayer:SetActive(false);

    -- 二人位置父物体
    self.locationTwoParent = GetComponentWithSimple(self.root, "LocationTwo", ComponentTypeName.Transform).gameObject;
    self.locationTwoParent:SetActive(false);

    -- 三人位置父物体
    self.locationThreeParent = GetComponentWithSimple(self.root, "LocationThree", ComponentTypeName.Transform).gameObject;
    self.locationThreeParent:SetActive(false);

    -- 四人位置父物体
    self.locationFourParent = GetComponentWithSimple(self.root, "LocationFour", ComponentTypeName.Transform).gameObject;
    self.locationFourParent:SetActive(false);
end

function TableLocationView:init(playerInfoList)

    self.playerInfoList = playerInfoList;
    self.currentLocation = nil;

    -- 更新定位视图
    self:updateLocationView();
end

-- 更新定位视图
function TableLocationView:updateLocationView()

    print_table(self.playerInfoList);
    if #self.playerInfoList == 2 then

        self.locationTwoParent:SetActive(true);
        self.locationThreeParent:SetActive(false);
        self.locationFourParent:SetActive(false);
        self.currentLocation = self.locationTwoParent;
        -- 显示三人定位界面
    elseif #self.playerInfoList == 3 then

        self.locationTwoParent:SetActive(false);
        self.locationThreeParent:SetActive(true);
        self.locationFourParent:SetActive(false);
        self.currentLocation = self.locationThreeParent;
        -- 显示四人定位界面
    elseif #self.playerInfoList == 4 then

        self.locationTwoParent:SetActive(false);
        self.locationThreeParent:SetActive(false);
        self.locationFourParent:SetActive(true);
        self.currentLocation = self.locationFourParent;
    end

    -- 重复利用itemRight模板
    local childCount = self.itemPlayer.transform.parent.childCount;
    for i = 0, childCount - 1 do

        self.itemPlayer.transform.parent:GetChild(i).gameObject:SetActive(false);
    end

    local animationTable = { };
    for key, playerInfo in ipairs(self.playerInfoList) do

        -- 重复利用itemRight模板
        local itemClone = nil;
        if key > childCount - 1 then
            itemClone = self:clone(self.itemPlayer.gameObject, self.itemPlayer.transform.parent.gameObject, Vector3.zero);
            itemClone.name = itemClone.name .. key;
        else
            itemClone = self.itemPlayer.transform.parent:GetChild(key).gameObject;
            itemClone:SetActive(true);
        end
        local itemCloneRectTransform = GetComponentWithSimple(itemClone, itemClone.name, ComponentTypeName.RectTransform);
        local itemPointRectTransform = GetComponentWithSimple(self.currentLocation, "PlayerPoint" .. key, ComponentTypeName.RectTransform);
        itemClone:SetActive(true);
        itemCloneRectTransform.anchoredPosition = itemPointRectTransform.anchoredPosition;

        -- 玩家头像
        local spritePlayerIcon = GetComponentWithSimple(itemClone, "SpritePlayerImage", ComponentTypeName.Image);
        -- 玩家名字标签
        local labelPlayerName = GetComponentWithSimple(itemClone, "LabelPlayerName", ComponentTypeName.Text);
        -- gps状态标签
        local labelGPS = GetComponentWithSimple(itemClone, "LabelGPS", ComponentTypeName.Text);

        -- 下载玩家头像
        if playerInfo.imgUrl then
            local onDownComplete = function(sprite)
                if sprite then
                    spritePlayerIcon.sprite = sprite;
                end
            end
            self:startDownLoadHeadIcon(playerInfo.imgUrl, onDownComplete);
        else
            spritePlayerIcon.sprite = self.spriteHolder:FindSpriteByName("default");
        end

        if playerInfo.spriteHeadImage then
            spritePlayerIcon.sprite = playerInfo.spriteHeadImage;
        end

        -- 玩家名字
        labelPlayerName.text = playerInfo.playerName;
        -- 未开启gps状态
        labelGPS.gameObject:SetActive(playerInfo.isShowDotGPS);

        local playerLineParent = GetComponentWithSimple(self.currentLocation, "PlayerLine" .. key, ComponentTypeName.RectTransform);
        -- 遍历显示玩家线数据
        for key1, location in ipairs(playerInfo.locationList) do

            local playerLine = playerLineParent.transform:GetChild(key1 - 1).gameObject;
            playerLine:SetActive(true);

            -- 距离标签
            local labelDistance = GetComponentWithSimple(playerLine, "distance", ComponentTypeName.Text);
            -- ip标签
            local labelIP = GetComponentWithSimple(playerLine, "ip", ComponentTypeName.Text);

            labelDistance.text = location.distance;
            labelIP.gameObject:SetActive(location.isShowIP);

            if location.isShowIP then
                table.insert(animationTable, labelIP.gameObject);
            end

            -- 小于100米
            if location.isDistanceNear then
                table.insert(animationTable, labelDistance.gameObject);
            end
        end
    end

    for key, animationGB in ipairs(animationTable) do
        ModuleCache.DOTweenAnimationTool.DORestart(animationGB, true);
    end


end

-- 克隆
function TableLocationView:clone(obj, parent, pos)
    local target = ComponentUtil.InstantiateLocal(obj, parent, pos);
    target.name = obj.name;
    ComponentUtil.SafeSetActive(target, true);
    return target;
end

-- 下载头像
function TableLocationView:startDownLoadHeadIcon(url, callback)
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
    end , nil, false)
end

return TableLocationView;