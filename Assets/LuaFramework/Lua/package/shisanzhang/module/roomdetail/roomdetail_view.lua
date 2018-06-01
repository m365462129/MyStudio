-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local RoomDetailView = Class('roomDetailView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local Instantiate = ModuleCache.ComponentUtil.InstantiateLocal;

function RoomDetailView:initialize(...)
    -- 初始View
    View.initialize(self, "shisanzhang/module/roomdetail/shisanzhang_windowroomdetail.prefab", "ShiSanZhang_WindowRoomDetail", 1)

    self.textRuleDesc = GetComponentWithPath(self.root, "Top/Child/SpriteRule/LabelRuleName", ComponentTypeName.Text)

    self.buttonClose = GetComponentWithPath(self.root, "TopLeft/Child/ImageBack", ComponentTypeName.Button)
    self.itemPrefab = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content/item0", ComponentTypeName.Transform).gameObject;
    self.scrollViewContent = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content", ComponentTypeName.Transform);
    self.spriteAsset = GetComponentWithPath(self.root, "Top/PokerAssetHolder", "SpriteHolder");
    self.textRoomRoundInfo = GetComponentWithPath(self.root, "Top/Child/Title/Text", ComponentTypeName.Text);
    -- self.quickGrid = GetComponentWithPath(self.root, "Top/Panels/QuickGrid", ComponentTypeName.QuickGrid)
    local onDataChange = function(item)

        self:fillItem(item)
    end
    -- self.quickGrid.OnItemDataChange = onDataChange;
end


function RoomDetailView:initRoomInfo(roomInfo)
    --    self.textRoomID.text = "房号:" .. roomInfo.roomNumber
    --    self.textCreateTime.text = roomInfo.createTime
    -- print("Rest------------------")
    -- 玩法信息
    local wanfaName, wanfaRule = TableUtil.get_rule_name(roomInfo.playRule);
    self.textRuleDesc.text = wanfaRule

    for i = 1, 4 do
        local labelPlayerName = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. i, ComponentTypeName.Text);
        ComponentUtil.SafeSetActive(labelPlayerName.gameObject, false)
    end
    print_table(roomInfo)
    local ruleTable = ModuleCache.Json.decode(roomInfo.playRule);
    self.balance = ruleTable.balance;
    local contentChildCount = self.scrollViewContent.childCount;
    for i = contentChildCount - 1, 1, -1 do
        local item = self.scrollViewContent:GetChild(i).gameObject;
        UnityEngine.Object.Destroy(item);
    end
    -- self.quickGrid:SetData(nil, 0);
end

function RoomDetailView:ShowDetailResult(goItem, showIndex, result)
    local playerRoot = GetComponentWithPath(goItem, "Players/player" .. showIndex, ComponentTypeName.Transform).gameObject;
    for i = 1, 3 do
        local curMatchScoreText = GetComponentWithPath(playerRoot, "Match" .. i .. "/Text", ComponentTypeName.Text);
        local curMatchOfResult = { }
        if (i == 1) then
            if (result.firstMatchScore >= 0) then
                curMatchScoreText.text = "<color=#e20c0c>+" .. result.firstMatchScore .. "</color>";
            else
                curMatchScoreText.text = "<color=#7a5844>" .. result.firstMatchScore .. "</color>";
            end
            curMatchOfResult = result.firstMatch;
        elseif (i == 2) then
            if (result.secondMatchScore >= 0) then
                curMatchScoreText.text = "<color=#e20c0c>+" .. result.secondMatchScore .. "</color>";
            else
                curMatchScoreText.text = "<color=#7a5844>" .. result.secondMatchScore .. "</color>";
            end
            curMatchOfResult = result.secondMatch;
        elseif (i == 3) then
            if (result.thirdMatchScore >= 0) then
                curMatchScoreText.text = "<color=#e20c0c>+" .. result.thirdMatchScore .. "</color>";
            else
                curMatchScoreText.text = "<color=#7a5844>" .. result.thirdMatchScore .. "</color>";
            end
            curMatchOfResult = result.thirdMatch;
        end
        local indexMax = 5;
        if(i == 1) then
            indexMax = 3;
        end       
        for j = 1, indexMax do
            if (result.isSurrender == 0) then
                local curPokerImage = GetComponentWithPath(playerRoot, "Match" .. i .. "/Pokers/" .. j, ComponentTypeName.Image);
                local sprite = self.spriteAsset:FindSpriteByName(self:GetSpriteFromPoker(curMatchOfResult[j]));
                curPokerImage.sprite = sprite;
            else
                local surrenderSprite = self.spriteAsset:FindSpriteByName("paibei");
                local curPokerImage = GetComponentWithPath(playerRoot, "Match" .. i .. "/Pokers/" .. j, ComponentTypeName.Image);
                local sprite = surrenderSprite;
                curPokerImage.sprite = sprite;
            end
        end

    end
    local scoreText = GetComponentWithPath(goItem, "Players/player" .. showIndex .. "/Text", ComponentTypeName.Text);
    if (result.roundScore > 0) then
        scoreText.text = "<color=#7a5844>通关</color><color=#e20c0c>" .. result.roundScore .. "</color> "
    end
    local isSpecial = false;
    if (result.xipaiInfo) then
        for i = 1, 4 do
            if (result.xipaiInfo[i].xipai == "") then
                break;
            end
            isSpecial = true;
            scoreText.text = scoreText.text .. "<color=#ab4612>" .. result.xipaiInfo[i].xipai .. " </color><color=#e20c0c>+" .. result.xipaiInfo[i].score .. "</color> "
        end
    end
    if(isSpecial) then
        return;
    end
    if(self.balance < 3 or self.balance == 4 ) then
        print_table(result)

        if self.balance == 4 then
            if(result.soloKillScore >= 0) then
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "打枪" .. "</color><color=#e20c0c>+".. result.soloKillScore .."</color> "
            else
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "打枪" .. "</color><color=#7A5844>".. result.soloKillScore .."</color> "
            end
            if(result.allKillScore >= 0) then
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "全垒打" .. "</color><color=#e20c0c>+".. result.allKillScore .."</color> "
            else
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "全垒打" .. "</color><color=#7A5844>".. result.allKillScore .."</color> "
            end
        else
            if(result.soloKillScore >= 0) then
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "单杀" .. "</color><color=#e20c0c>+".. result.soloKillScore .."</color> "
            else
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "单杀" .. "</color><color=#7A5844>".. result.soloKillScore .."</color> "
            end
            if(result.allKillScore >= 0) then
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "通杀" .. "</color><color=#e20c0c>+".. result.allKillScore .."</color> "
            else
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "通杀" .. "</color><color=#7A5844>".. result.allKillScore .."</color> "
            end
        end

    elseif self.balance == 3 or self.balance == 5 then
        if(result.spadeAScore >= 0) then
            scoreText.text = scoreText.text.."<color=#ab4612>" .. "黑A " .. "</color><color=#e20c0c>+".. result.spadeAScore .."</color> "
        else
            scoreText.text = scoreText.text.."<color=#ab4612>" .. "黑A " .. "</color><color=#7A5844>".. result.spadeAScore .."</color> "
        end

        if self.balance == 5 then
            local _allkillscore = result.allKillScore or 0
            if(_allkillscore >= 0) then
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "全垒打" .. "</color><color=#e20c0c> +".. _allkillscore .."</color> "
            else
                scoreText.text = scoreText.text.."<color=#ab4612>" .. "全垒打" .. "</color><color=#7A5844> ".. _allkillscore .."</color> "
            end
        end
    end
end

function RoomDetailView:GetSpriteFromPoker(poker)
    -- S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
    local colorStr
    if (poker.color == 4) then
        colorStr = "heitao";
    elseif (poker.color == 3) then
        colorStr = "hongtao";
    elseif (poker.color == 2) then
        colorStr = "meihua";
    elseif (poker.color == 1) then
        colorStr = "fangkuai";
    end
    local numberStr
    if (poker.number == 14) then
        numberStr = "1";
    else
        numberStr = "" .. poker.number;
    end;
    local spriteName = colorStr .. "_" .. numberStr;
    if (poker.number == 15 and poker.color == 2) then
        spriteName = "wang_da"
    end
    if (poker.number == 15 and poker.color == 1) then
        spriteName = "wang_xiao"
    end
    return spriteName;
end

function RoomDetailView:initLoopScrollViewList(roomList, creatorID)
    self.creatorID = creatorID;

    for key, value in ipairs(roomList) do
        local item = { };
        local itemNew = Instantiate(self.itemPrefab, self.scrollViewContent.gameObject);
        itemNew:SetActive(true);
        item.data = value;
        item.gameObject = itemNew;
        self:fillItem(item);
    end
    -- print("set data -----------------------------------------")
    -- self.quickGrid:SetData(roomList, 0);
end

function RoomDetailView:fillItem(item)
    -- print("item.name = "..item.name)
    local roundObject = item.data;

    -- 当前局数
    local labelRoundNumber = GetComponentWithPath(item.gameObject, "Title/RoundNumLbl", ComponentTypeName.Text);
    -- 红色图集
    local redAtlas = GetComponentWithPath(item.gameObject, "RedNumbersHolder", "SpriteAtlas");
    -- 绿色图集
    local greenAtlas = GetComponentWithPath(item.gameObject, "GreenNumbersHolder", "SpriteAtlas");

    labelRoundNumber.text = roundObject.roundNumber;

    -- 2017/8/7 修改 by Jyz
    -- for i = 1, 5 do
    --     -- 玩家分数实体
    --     local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject;
    --     -- 玩家名字标签
    --     local labelPlayerName = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. i, ComponentTypeName.Text);
    --     -- 玩家分数标签
    --     local labelWrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")

    --     -- 有多少个玩家就显示多少个,其他玩家的信息隐藏
    --     if (i <= #roundObject.player) then
    --         ComponentUtil.SafeSetActive(playerGo, true)
    --         ComponentUtil.SafeSetActive(labelPlayerName.gameObject, true)

    --         if roundObject.player[i].score >= 0 then
    --             labelWrapRedScore.atlas = redAtlas
    --         else
    --             labelWrapRedScore.atlas = greenAtlas
    --         end

    --         labelWrapRedScore.text = roundObject.player[i].score;
    --         labelPlayerName.text = roundObject.player[i].playerName.." "..roundObject.player[i].userId;

    --     else
    --         ComponentUtil.SafeSetActive(playerGo, false)
    --         ComponentUtil.SafeSetActive(labelPlayerName.gameObject, false)
    --     end
    -- end

    for i = 1, 4 do
        -- 玩家分数实体
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject;

        -- 玩家名字标签
        local labelPlayerName = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. i, ComponentTypeName.Text);
        ComponentUtil.SafeSetActive(playerGo, false)
        ComponentUtil.SafeSetActive(labelPlayerName.gameObject, false)
    end

    -- print_table(item.data.player)
    for k, v in ipairs(item.data.player) do
        -- print("11111: "..k)
        local showIndex = v.showIndex
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. showIndex, ComponentTypeName.Transform).gameObject;
        local labelPlayerName = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. showIndex, ComponentTypeName.Text);
        local spriteCreatorIcon = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. showIndex .. "/fangzhu", ComponentTypeName.Image);
        local spriteDissolverIcon = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. showIndex .. "/dissolver", ComponentTypeName.Image);
        local labelWrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")
        local userID = v.userId;
        for key, value in ipairs(item.data.result) do
            if (value.playerId == v.userId) then
                self:ShowDetailResult(item.gameObject, showIndex, value);
            end
        end

        -- 玩家id等于创建id,显示房主图标
        if tonumber(userID) == tonumber(self.creatorID) then
            spriteCreatorIcon.gameObject:SetActive(true);
        else
            spriteCreatorIcon.gameObject:SetActive(false);
        end

        local disUser = item.data.disUser;
        if(disUser and disUser ~= 0) then
            local isDissolver = tonumber(disUser) == tonumber(userID);
            print(isDissolver)
            spriteDissolverIcon.gameObject:SetActive(isDissolver);
        end

        ComponentUtil.SafeSetActive(playerGo, true)
        ComponentUtil.SafeSetActive(labelPlayerName.gameObject, true)

        if v.score >= 0 then
            labelWrapRedScore.atlas = redAtlas
        else
            labelWrapRedScore.atlas = greenAtlas
        end

        labelWrapRedScore.text = v.score;
        local playerName = Util.filterPlayerName(v.playerName, 8);
        -- if(string.len(playerName) > 4) then
        --     playerName = string.sub( playerName, 1,3 ).."..."
        -- end
        labelPlayerName.text = playerName
    end


    -- 2017/8/7 修改 End


    --    local textRoundNum = GetComponentWithPath(item.gameObject, "Title/RoundNumLbl", ComponentTypeName.Text)
    --    local textVideoId = GetComponentWithPath(item.gameObject, "Title/VideoIdLbl", ComponentTypeName.Text)
    --    local textTime = GetComponentWithPath(item.gameObject, "Title/TimeLbl", ComponentTypeName.Text)
    --    textRoundNum.text = data.roundNumber .. "/" .. data.roundCount .. "局"
    --    if(not data.playRule or data.playRule == "")then
    --        textVideoId.text = ""
    --    else
    --        textVideoId.text = ShareManager:formatRuleDesc(ModuleCache.Json.decode(data.playRule))
    --    end

    --    --textTime.text = os.date("%Y-%m-%d   %H:%M", data.time)
    --    textTime.text = data.playTime
    --    for i=1,6 do
    --        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject
    --        if (#data.seatList < i) then
    --            ModuleCache.ComponentUtil.SafeSetActive(playerGo, false)
    --        else
    --            ModuleCache.ComponentUtil.SafeSetActive(playerGo, true)
    --            local textPlayerName = GetComponentWithPath(playerGo, "nameLbl", ComponentTypeName.Text)
    --            local textWrapGreenScore = GetComponentWithPath(playerGo, "greenScore", "TextWrap")
    --            local textWrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")
    --            local seatData = data.seatList[i]
    --            if(i == 1)then
    --                textPlayerName.text = seatData.playerName
    --            else
    --                textPlayerName.text = "<color=#7F5F54>" .. seatData.playerName .. "</color>"
    --            end

    --            if(seatData.score < 0) then
    --                ModuleCache.ComponentUtil.SafeSetActive(textWrapGreenScore.gameObject, true)
    --                ModuleCache.ComponentUtil.SafeSetActive(textWrapRedScore.gameObject, false)
    --                textWrapGreenScore.text = "" .. seatData.score
    --            else
    --                ModuleCache.ComponentUtil.SafeSetActive(textWrapGreenScore.gameObject, false)
    --                ModuleCache.ComponentUtil.SafeSetActive(textWrapRedScore.gameObject, true)
    --                textWrapRedScore.text = "+" .. seatData.score
    --            end
    --        end


    --    end
end


return RoomDetailView