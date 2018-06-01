-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
local HistoryListView = Class('historyListView', View)
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local BranchPackageName = AppData.BranchDouDiZhuName;
local ComponentUtil = ModuleCache.ComponentUtil

function HistoryListView:initialize(...)
    View.initialize(self, BranchPackageName .. "/module/historylist/doudizhu_windowhistorylist.prefab", "DouDiZhu_WindowHistoryList", 1)

    -- 历史记录列表
    self.historyList = { };
    -- 历史记录模板列表
    self.historyItemList = { };

    -- 返回按钮
    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);
    -- 查看对局按钮
    self.buttonLookMatch = GetComponentWithSimple(self.root, "ButtonLookMatch", ComponentTypeName.Button);

    -- 空数据实体
    self.emptyDataGB = GetComponentWithSimple(self.root, "SpriteEmpty", ComponentTypeName.Transform).gameObject;

    -- 历史记录item
    self.item = GetComponentWithSimple(self.root, "item", ComponentTypeName.Transform).gameObject;
    self.item.gameObject:SetActive(false);

    -- 金币场需要隐藏的物件
    self.titleObj = GetComponentWithPath(self.root, "Top/Child", ComponentTypeName.Transform).gameObject;
    self.replayObj = GetComponentWithPath(self.root, "TopRight", ComponentTypeName.Transform).gameObject;
    self.backObj = GetComponentWithPath(self.root, "TopLeft", ComponentTypeName.Transform).gameObject;
    self.maskObj = GetComponentWithPath(self.root, "Center", ComponentTypeName.Transform).gameObject;
end

-- 初始化
function HistoryListView:init(historyDataList)

    -- 没有历史数据,显示空数据实体
    if #historyDataList == 0 then

        self.emptyDataGB:SetActive(true);
    else
        self.emptyDataGB:SetActive(false);
    end
    -- 更新历史战绩视图
    self:updateHistoryView(historyDataList);
end

-- 更新历史战绩视图
function HistoryListView:updateHistoryView(historyDataList)

    for key, historyItem in ipairs(self.historyItemList) do
        UnityEngine.Object.Destroy(historyItem);
    end
    self.historyItemList = { };

    for key, historyList in ipairs(historyDataList) do

        self.historyList[key] = historyList;
        local itemClone = self:clone(self.item.gameObject, self.item.transform.parent.gameObject, Vector3.zero);
        table.insert(self.historyItemList, itemClone);
        itemClone.gameObject:SetActive(true);
        itemClone.name = key;

        -- 房号标签
        local labelRoomName = GetComponentWithSimple(itemClone, "LabelRoomName", ComponentTypeName.Text);
        -- 时间标签
        local labelTime = GetComponentWithSimple(itemClone, "LabelTime", ComponentTypeName.Text);
        -- 玩家item
        local playerItem = GetComponentWithSimple(itemClone, "playerItem", ComponentTypeName.Transform).gameObject;

        -- 房间号
        labelRoomName.text = string.format("房号:%d", historyList.roomNumber);
        -- 时间
        labelTime.text = historyList.createTime;

        -- historyList.settleType = 1;
        local isShowGoldIcon = false;
        -- 金币
        if historyList.settleType == 1 then
            isShowGoldIcon = true;
        end

        -- 自己排在最前面
        for i = 1, #historyList.players do
            if historyList.players[i].userId == tonumber(self.modelData.roleData.userID) then
                local temp = historyList.players[1]
                historyList.players[1] = historyList.players[i]
                historyList.players[i] = temp
            end
        end

        for key1, player in ipairs(historyList.players) do

            local playerItemClone = self:clone(playerItem, playerItem.transform.parent.gameObject, Vector3.zero);
            playerItemClone.name = playerItemClone.name .. key1;

            -- 玩家昵称标签
            local labelNickname = GetComponentWithSimple(playerItemClone, "LabelNickname", ComponentTypeName.Text);

            -- 房主图标
            local spriteRoomOwner = GetComponentWithSimple(playerItemClone, "SpriteRoomOwner", ComponentTypeName.Image);
            -- 玩家头像
            local spritePlayerIcon = GetComponentWithSimple(playerItemClone, "SpritePlayerIcon", ComponentTypeName.Image);
            -- 金币图标
            local spriteGoldIcon = GetComponentWithSimple(playerItemClone, "SpriteGoldIcon", ComponentTypeName.Image);
            -- 玩家分数
            local labelScore = GetComponentWithSimple(playerItemClone, "LabelScore", ComponentTypeName.Text);

            -- 金币图标
            spriteGoldIcon.gameObject:SetActive(isShowGoldIcon);
            local score = nil;
            if isShowGoldIcon then
                score = player.playerCoin + player.playerRestCoin;
                score = Util.filterPlayerGoldNum(score);
            else
                score = player.playerScore;
            end

            local matchScore = nil;
            if isShowGoldIcon then
                matchScore = player.playerCoin + player.playerRestCoin;
            else
                matchScore = player.playerScore;
            end
            -- 当前积分为nil,显示0积分
            if matchScore == nil then
                labelScore.text = "<color=#e20c0c>+0</color>";
            else
                if matchScore >= 0 then
                    labelScore.text = "<color=#e20c0c>+" .. score .. "</color>";
                else
                    labelScore.text = "<color=#02c714>" .. score .. "</color>";
                end
            end

            -- 过滤玩家名字
            local filterPlayerName = Util.filterPlayerName(player.playerName, 10);
            -- 判断房主
            if tonumber(player.userId) == tonumber(historyList.creatorId) then

                spriteRoomOwner.gameObject:SetActive(true);
                -- 玩家昵称
                labelNickname.text = "<color=#B13A1FFF>" .. filterPlayerName .. "</color>";
            else
                spriteRoomOwner.gameObject:SetActive(false);
                -- 玩家昵称
                labelNickname.text = filterPlayerName;
            end

            local onDownLoadIcon = function(sprite)

                if sprite ~= nil then
                    -- 玩家头像
                    spritePlayerIcon.sprite = sprite;
                end
            end
            -- 下载头像
            self:startDownLoadHeadIcon(spritePlayerIcon, player.headImg, onDownLoadIcon);

        end
    end
end

-- 克隆
function HistoryListView:clone(obj, parent, pos)
    local target = ComponentUtil.InstantiateLocal(obj, parent, pos);
    target.name = obj.name;
    ComponentUtil.SafeSetActive(target, true);
    return target;
end

-- 下载头像
function HistoryListView:startDownLoadHeadIcon(targetImage, url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if (self) then
                    -- self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if (callback) then
                callback(tex)
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end )
end

-- 通过索引获取历史战绩信息
function HistoryListView:getHistoryDataByIndex(index)

    return self.historyList[tonumber(index)];
end

function HistoryListView:showGold(isbool)
    ComponentUtil.SafeSetActive(self.titleObj, isbool)
    ComponentUtil.SafeSetActive(self.replayObj, isbool)
    ComponentUtil.SafeSetActive(self.backObj, isbool)
    ComponentUtil.SafeSetActive(self.maskObj, isbool)
end

return HistoryListView