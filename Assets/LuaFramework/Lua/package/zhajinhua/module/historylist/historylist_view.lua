-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
local HistoryListView = Class('historyListView', View)
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local BranchPackageName = AppData.BranchZhaJinHuaName;
local ComponentUtil = ModuleCache.ComponentUtil

function HistoryListView:initialize(...)
    View.initialize(self, BranchPackageName .. "/module/historylist/zhajinhua_windowhistorylist.prefab", "ZhaJinHua_WindowHistoryList", 1)

    -- 历史记录列表
    self.historyList = { };

    -- 返回按钮
    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);
    -- 查看对局按钮
    self.buttonLookMatch = GetComponentWithSimple(self.root, "ButtonLookMatch", ComponentTypeName.Button);

    -- 空数据实体
    self.emptyDataGB = GetComponentWithSimple(self.root, "SpriteEmpty", ComponentTypeName.Transform).gameObject;

    -- 历史记录item
    self.item        = GetComponentWithPath(self.root, "Top/item", ComponentTypeName.Transform).gameObject;
    self.itemContent = GetComponentWithPath(self.root, "Top/ScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject;
    -- 玩家item
    self.playerItem     = GetComponentWithPath(self.root, "Top/playerItem", ComponentTypeName.Transform).gameObject;

    -- 金币场需要隐藏的物件
    self.titleObj  = GetComponentWithPath(self.root, "Top/Child", ComponentTypeName.Transform).gameObject;
    self.replayObj = GetComponentWithPath(self.root, "TopRight",  ComponentTypeName.Transform).gameObject;
    self.backObj   = GetComponentWithPath(self.root, "TopLeft",   ComponentTypeName.Transform).gameObject;
    self.maskObj   = GetComponentWithPath(self.root, "Center",    ComponentTypeName.Transform).gameObject;
end

-- 初始化
function HistoryListView:init(historyDataList)

    -- 没有历史数据,显示空数据实体
    if #historyDataList == 0 then

        self.emptyDataGB:SetActive(true);
    else
        self.emptyDataGB:SetActive(false);
    end
    self.listData = historyDataList;
    -- 更新历史战绩视图
    self:updateHistoryView(historyDataList);
end

-- 更新历史战绩视图
function HistoryListView:updateHistoryView(historyDataList)

    local contents = TableUtil.get_all_child(self.itemContent.transform)
    for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end

    for i = 1, #historyDataList do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(self.item,self.itemContent,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)
        item.gameObject = obj
        item.data = historyDataList[i]
        self:fillItem(item, i)
    end
end

function HistoryListView:fillItem(item, index)
    local historyList = item.data
    self.historyList[index] = historyList;
    local itemClone = item.gameObject;

    -- 房号标签
    local labelRoomName = GetComponentWithSimple(itemClone, "LabelRoomName", ComponentTypeName.Text);
    -- 时间标签
    local labelTime = GetComponentWithSimple(itemClone, "LabelTime", ComponentTypeName.Text);

    local playercontent  = GetComponentWithPath(itemClone, "PlayerLayout", ComponentTypeName.Transform).gameObject;

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

    local contents = TableUtil.get_all_child(playercontent.transform)
    for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end

    for i = 1, #historyList.players do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(self.playerItem, playercontent,Vector3.zero)
        end
        ComponentUtil.SafeSetActive(obj, true)
        item.gameObject = obj
        item.data = historyList.players[i]
        self:fillPlayer(item, historyList,isShowGoldIcon,i)
    end

end

function HistoryListView:fillPlayer(item, historyList,isShowGoldIcon, index)
    local playerItemClone = item.gameObject;
    playerItemClone.name = playerItemClone.name .. index;
    local player = item.data

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