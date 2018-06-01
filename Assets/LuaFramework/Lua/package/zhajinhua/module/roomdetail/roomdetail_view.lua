-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
local BranchPackageName = AppData.BranchZhaJinHuaName
local RoomDetailView = Class('roomDetailView', View)
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple
local ComponentUtil = ModuleCache.ComponentUtil


function RoomDetailView:initialize(...)
    View.initialize(self, BranchPackageName .. "/module/roomdetail/zhajinhua_windowroomdetail.prefab", "ZhaJinHua_WindowRoomDetail", 1)

    -- 房间列表
    self.roomList = { };
    -- 玩家分数列表
    self.playerScoreList = { };

    -- 局数item
    self.item = GetComponentWithSimple(self.root, "RoundItem", ComponentTypeName.Transform).gameObject;

    -- 返回按钮
    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);
    -- 查看对局按钮
    self.buttonLookMatch = GetComponentWithSimple(self.root, "ButtonLookMatch", ComponentTypeName.Button);

    -- 玩法名标签
    self.labelRuleName = GetComponentWithSimple(self.root, "LabelRuleName", ComponentTypeName.Text);
end

-- 初始化
function RoomDetailView:init(roomList)

    self.roomList = roomList;
    self.playerScoreList = roomList.list;
    self.disUserId = roomList.disUserName --解散房间的玩家id

    -- 更新战绩详情视图
    self:updateRoomDetailView();
end

-- 更新战绩详情视图
function RoomDetailView:updateRoomDetailView()

    -- 按照顺序获取玩家信息(先从自己玩家获取)
    local playerList = self:getPlayerList(self.roomList);

    -- 更新玩家信息视图
    self:updatePlayerView(playerList);

    local isShowGoldIcon = false;
    -- 金币
    if self.roomList.settleType == 1 then
        isShowGoldIcon = true;
    end

    for key, room in ipairs(self.roomList.list) do

        local itemClone = self:clone(self.item.gameObject, self.item.transform.parent.gameObject, Vector3.zero);
        itemClone.name = key;

        -- 局数标签
        local labelRound = GetComponentWithSimple(itemClone, "LabelRound", ComponentTypeName.Text);
        -- 异常结束标签
        local labelExceptionEnd = GetComponentWithSimple(itemClone, "LabelExceptionEnd", ComponentTypeName.Text);

        -- 玩家item
        local playerItem = GetComponentWithSimple(itemClone, "PlayerItem", ComponentTypeName.Transform).gameObject;

        -- 局数
        labelRound.text = tostring(key);

        local playerScoreList = { };
        for key1, player in ipairs(playerList) do
            -- 获取当局玩家分数信息
            playerScoreList[key1] = self:getPlayerScores(room.scores, player.seatId);
        end

        -- 遍历生成玩家分数信息
        for key1, score in ipairs(playerScoreList) do

            -- 玩家item
            local playerItemClone = self:clone(playerItem, playerItem.transform.parent.gameObject, Vector3.zero);
            playerItemClone.name = playerItemClone.name .. key1;

            -- 金币图标
            local spriteGoldIcon = GetComponentWithSimple(playerItemClone, "SpriteGoldIcon", ComponentTypeName.Image);
            -- 玩家分数
            local labelScore = GetComponentWithSimple(playerItemClone, "LabelScore", ComponentTypeName.Text);

            -- 金币图标
            spriteGoldIcon.gameObject:SetActive(isShowGoldIcon);
            local scoreTemp = score.score;
            if isShowGoldIcon then
                scoreTemp = score.coin + score.restCoin;
                scoreTemp = Util.filterPlayerGoldNum(scoreTemp);
            end

            local matchScore = nil;
            if isShowGoldIcon then
                matchScore = score.coin + score.restCoin;
            else
                matchScore = score.score;
            end

            -- 当前积分为nil,显示0积分
            if matchScore then
                if matchScore >= 0 then
                    labelScore.text = "<color=#e20c0c>+" .. scoreTemp .. "</color>";
                else
                    labelScore.text = "<color=#02c714>" .. scoreTemp .. "</color>";
                end
            else
                labelScore.text = "<color=#e20c0c>+0</color>";
            end
        end
    end

    --解散房间的发起者
    if(self.disUserName == nil) then
        --print("====不是解散的")
    else
        local itemClone = self:clone(self.item.gameObject, self.item.transform.parent.gameObject, Vector3.zero)
        local Title = GetComponentWithSimple(itemClone.gameObject, "Title", ComponentTypeName.Transform).gameObject
        local PlayerLayout = GetComponentWithSimple(itemClone.gameObject, "PlayerLayout", ComponentTypeName.Transform).gameObject
        local DissolveRoomInfo = GetComponentWithSimple(itemClone.gameObject, "DissolveRoomInfo", ComponentTypeName.Transform).gameObject
        local DissolveRoomInfoName = GetComponentWithSimple(DissolveRoomInfo.gameObject, "Name", ComponentTypeName.Text)
        ModuleCache.ComponentUtil.SafeSetActive(Title.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(PlayerLayout.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(DissolveRoomInfo.gameObject, true)
        DissolveRoomInfoName.text = self.disUserName
    end
end

-- 更新玩家信息视图
function RoomDetailView:updatePlayerView(playerList)

    for i = 1, 6 do

        -- 玩家名称标签
        local labelPlayerName = GetComponentWithSimple(self.root, "LabelPlayer" .. i, ComponentTypeName.Text);
        -- 房主图标
        local spriteRoomOwner = GetComponentWithSimple(self.root, "SpriteRoomOwner" .. i, ComponentTypeName.Image);

        print("玩家数量=", #playerList);
        -- 玩家列表长度小于等于ui默认玩家标签数量,显示玩家信息,否则隐藏玩家标签
        if i <= #playerList then

            -- 过滤玩家名字
            local filterPlayerName = Util.filterPlayerName(playerList[i].playerName, 8)
            -- 玩家名称
            labelPlayerName.text = filterPlayerName;
            -- 玩家id等于创建id,显示房主图标
            -- if tonumber(playerList[i].userId) == tonumber(self.roomList.creatorId) then
            --     spriteRoomOwner.gameObject:SetActive(true);
            -- end
            if(self.disUserId and not self.disUserName) then
                if(tonumber(playerList[i].userId) == tonumber(self.disUserId)) then
                    self.disUserName = filterPlayerName
                    print("====解散房间的玩家的名字=",tostring(filterPlayerName))
                end
            end
        else
            labelPlayerName.gameObject:SetActive(false);
        end
    end

    -- 获取扎金花规则描述
    self.labelRuleName.text = self:GetZhaJinHuaRuleText(self.roomList.playRule);
end


-- 获取扎金花规则描述
function RoomDetailView:GetZhaJinHuaRuleText(RuleJsonString)
    local playRule = ModuleCache.Json.decode(RuleJsonString)
    local ruleStr = "飘三叶 "
    ruleStr = ruleStr .. playRule.roundCount .. "局 ";
    -- 可不闷
    if playRule.menNum == 0 then
        ruleStr = ruleStr .. "可不闷 ";
        -- 闷1圈或闷5圈
    else
        ruleStr = ruleStr .. "闷" .. playRule.menNum .. "圈 ";
    end
    ruleStr = ruleStr .. "最多压" .. playRule.maxScore .. "分 ";
    -- 235大于豹子
    if playRule.special == 0 then
        ruleStr = ruleStr .. "235大于豹子 ";
        -- 235仅大于aaa
    elseif playRule.special == 1 then
        ruleStr = ruleStr .. "235仅大于AAA ";
    end
    if playRule.leopardAddScore then
        ruleStr = ruleStr .. "豹子10分 ";
    end
    if playRule.shunKingAddScore then
        ruleStr = ruleStr .. "顺金5分 ";
    end
    if playRule.payType == 0 then
        ruleStr = ruleStr .. "AA支付"
    elseif playRule.payType == 1 then
        ruleStr = ruleStr .. "房主支付"
    elseif playRule.payType == 2 then
        ruleStr = ruleStr .. "大赢家支付"
    end
    return ruleStr
end

-- 获取当局玩家分数信息
function RoomDetailView:getPlayerScores(scoreList, seatID)

    local scoreData = nil;
    for key, score in ipairs(scoreList) do

        if tonumber(score.seatId) == tonumber(seatID) then
            scoreData = score;
            return scoreData;
        end
    end

    return scoreData;
end

-- 按照顺序获取玩家信息(先从玩家自己获取)
function RoomDetailView:getPlayerList(roomList)

    local playerList = { };
    local mySeatID = roomList.mySeatId;
    print_table(roomList);
    local playerIndex = 1;
    for key, player in ipairs(roomList.players) do

        if tonumber(player.seatId) == tonumber(mySeatID) then
            table.insert(playerList, player)
            --playerList[playerIndex] = player;
        end
    end

    for key, player in ipairs(roomList.players) do

        if tonumber(player.seatId) ~= tonumber(mySeatID) then
            table.insert(playerList, player)
            --playerIndex = playerIndex + 1;
            --playerList[playerIndex] = player;
        end
    end

    return playerList;
end

-- 获取玩家分数列表
function RoomDetailView:getPlayerScoreList(index)

    return self.playerScoreList[tonumber(index)];
end

-- 获取房间id
function RoomDetailView:getRoomID()

    return self.roomList.roomID;
end

-- 克隆
function RoomDetailView:clone(obj, parent, pos)
    local target = ComponentUtil.InstantiateLocal(obj, parent, pos);
    target.name = obj.name;
    ComponentUtil.SafeSetActive(target, true);
    return target;
end

return RoomDetailView