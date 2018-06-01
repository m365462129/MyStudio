-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local RoomDetailView = Class('roomDetailView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local Instantiate = ModuleCache.ComponentUtil.InstantiateLocal;
local cardCommon = require('package.laoyancai.module.table_laoyancai.gamelogic_common')

function RoomDetailView:initialize(...)
    -- 初始View
    View.initialize(self, "laoyancai/module/roomdetail/laoyancai_windowroomdetail.prefab", "LaoYanCai_WindowRoomDetail", 1)

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

    for i = 1, 5 do
        local labelPlayerName = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. i, ComponentTypeName.Text);
        ComponentUtil.SafeSetActive(labelPlayerName.gameObject, false)
    end
    local contentChildCount = self.scrollViewContent.childCount;
    for i = contentChildCount - 1, 1, -1 do
        local item = self.scrollViewContent:GetChild(i).gameObject;
        UnityEngine.Object.Destroy(item);
    end
    -- self.quickGrid:SetData(nil, 0);
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
    print("????????????????????????????")
    print_table(roomList)
    local max = 0;
    for key, value in ipairs(roomList) do
        if(value.roundNumber > max) then
            max = value.roundNumber;
        end
    end
    self.maxRoundNumber = max;
    for key, value in ipairs(roomList) do
        local item = { };
        local itemNew = Instantiate(self.itemPrefab, self.scrollViewContent.gameObject);
        local stateSwitcher = GetComponentWithPath(itemNew,"","UIStateSwitcher");
        if(#value.player > 4) then
            stateSwitcher:SwitchState("8Players")
        else
            stateSwitcher:SwitchState("4Players")
        end
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

    for i = 1, 7 do
        -- 玩家分数实体
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject;

        -- 玩家名字标签
        --local labelPlayerName = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. i, ComponentTypeName.Text);
        ComponentUtil.SafeSetActive(playerGo, false)
        --ComponentUtil.SafeSetActive(labelPlayerName.gameObject, false)
    end
    print_table(roundObject.result)
    local bankerId = roundObject.result.records.branker;
    print_table(roundObject);
    -- print_table(item.data.player)
    local sortPlayers = self:sortPlayer(item.data)

    for k, v in ipairs(item.data.player) do
        --print("11111111111111111111111: "..k)
        local showIndex = self:getPlayerIndex(v.userId,sortPlayers) 
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. showIndex, ComponentTypeName.Transform).gameObject;
        local labelPlayerName = GetComponentWithPath(playerGo, "Character/TextName", ComponentTypeName.Text);
        local labelPlayerID = GetComponentWithPath(playerGo, "Character/TextID", ComponentTypeName.Text);
        local spriteCreatorIcon = GetComponentWithPath(self.root, "Top/Child/Image/Player" .. showIndex .. "/fangzhu", ComponentTypeName.Image);
        local labelWrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")
        local spritePlayerIcon = GetComponentWithPath(playerGo,"Character/Image", ComponentTypeName.Image)
        local spriteDissolverIcon = GetComponentWithPath(playerGo,"Character/ImageDissolver", ComponentTypeName.Image)
        local pointGO = GetComponentWithPath(playerGo,"Pokers/Point",ComponentTypeName.Transform).gameObject
        local bankerImage = GetComponentWithPath(playerGo,"Character/ImageBanker",ComponentTypeName.Transform).gameObject
        local userID = v.userId;
        local strUserID = tostring(userID)
        labelPlayerID.text = userID;
        local result = item.data.result[strUserID]
        if(userID == bankerId) then
            bankerImage:SetActive(true);
        end
        if(#result.cards > 0) then
            for i = 1, #result.cards do
                local pokerSpriteName = self:getImageNameFromCode(result.cards[i]);
                local pokerSprite = self.spriteAsset:FindSpriteByName(pokerSpriteName);
                local image = GetComponentWithPath(playerGo,"Pokers/Panel/"..i,ComponentTypeName.Image);
                image.gameObject:SetActive(true);
                image.sprite = pokerSprite;
            end
        else
            local textNotice = GetComponentWithPath(playerGo,"Pokers/Text",ComponentTypeName.Transform).gameObject
            textNotice:SetActive(true);
        end
        local pokerTypeText = self:GetPokerTypeText(result.point,result.type)
        self:SetPokerTypeText(pointGO,pokerTypeText,#result.cards)
        -- 玩家id等于创建id,显示房主图标
        if tonumber(userID) == tonumber(self.creatorID) then
            --spriteCreatorIcon.gameObject:SetActive(true);
        else
            --spriteCreatorIcon.gameObject:SetActive(false);
        end
        local disUser = item.data.disUser;
        if(disUser and disUser ~= 0 and roundObject.roundNumber == self.maxRoundNumber) then
            local isDissolver = tonumber(disUser) == tonumber(userID);
            print(isDissolver)
            spriteDissolverIcon.gameObject:SetActive(isDissolver);
        end
        ComponentUtil.SafeSetActive(playerGo, true)
        ComponentUtil.SafeSetActive(labelPlayerName.gameObject, true)

        if v.score >= 0 then
            labelWrapRedScore.atlas = redAtlas
            labelWrapRedScore.text = "+" .. v.score;
        else
            labelWrapRedScore.atlas = greenAtlas
            labelWrapRedScore.text = v.score;
        end

        
        local playerName = Util.filterPlayerName(v.playerName, 10);
        -- if(string.len(playerName) > 4) then
        --     playerName = string.sub( playerName, 1,3 ).."..."
        -- end
        labelPlayerName.text = playerName

        local onDownLoadIcon = function(sprite)

            if sprite ~= nil then
                    -- 玩家头像
                spritePlayerIcon.sprite = sprite;
            end
        end
            -- 下载头像
        self:startDownLoadHeadIcon(spritePlayerIcon, v.headImg, onDownLoadIcon);
    end
end

function RoomDetailView:startDownLoadHeadIcon(targetImage, url, callback)
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

function RoomDetailView:getImageNameFromCode(code)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function RoomDetailView:getImageNameFromCard(card)
    local color = card.color
    local number = card.name
    if(number == cardCommon.card_small_king)then
        return 'little_boss'
    elseif(number == cardCommon.card_big_king)then
        return 'big_boss'
    end
    if(color == cardCommon.color_black_heart)then
        return 'heitao_' .. number
    elseif(color == cardCommon.color_red_heart)then
        return 'hongtao_' .. number
    elseif(color == cardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == cardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end

function RoomDetailView:GetPokerTypeText(point,pokerType) --1，双腌 2三腌 3 三批
	local text = "";
	if(pokerType == 1) then
		text = "双腌";
	elseif(pokerType == 2) then
		text = "三腌";
	elseif(pokerType == 3) then
		text = "三批";
	end
	text = text .. point;
	if(point == 0) then
		text = text.."灰";
	elseif(point < 8) then
		text = text.."蓝";
	elseif(point < 11) then
		text = text.."黄";
	end
	return text;
end

function RoomDetailView:SetPokerTypeText(pointGO,text,textIndex) --textIndex 显示2张牌的文字还是3张牌的文字，为0时隐藏
    if(text == "") then
        return;
    end
    local maskImage3 = GetComponentWithPath(pointGO,"ImageFor3",ComponentTypeName.Transform).gameObject;
    local maskImage2 = GetComponentWithPath(pointGO,"ImageFor2",ComponentTypeName.Transform).gameObject;

    local text3 = GetComponentWithPath(pointGO,"TextFor3","TextWrap");
    local text2 = GetComponentWithPath(pointGO,"TextFor2","TextWrap");
    if(textIndex == 3) then
        maskImage2:SetActive(false)
        maskImage3:SetActive(true);
        text2.gameObject:SetActive(false)
        text3.gameObject:SetActive(true);
        text3.text = text;
    elseif(textIndex == 2) then
        maskImage2:SetActive(true)
        maskImage3:SetActive(false);
        text2.gameObject:SetActive(true)
        text3.gameObject:SetActive(false);
        text2.text = text;
    elseif(textIndex == 0) then
        maskImage2:SetActive(false)
        maskImage3:SetActive(false);
        text2.gameObject:SetActive(false)
        text3.gameObject:SetActive(false);
        text2.text = text;
        text3.text = text;
    end
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

function RoomDetailView:sortPlayer(data)
    local newPlayerList = {}
--    local index = 2
--    for i, v in ipairs(data.players) do
--        if (self.creatorId == v.userId) then
--            newPlayerList[1] = v
--        else
--            newPlayerList[index] = v
--            index = index + 1
--        end
--    end


     -- 自己排在最前面
    for i = 1, #data.player do
        if data.player[i].userId == tonumber(self.modelData.roleData.userID) then
            local temp = data.player[1]
            data.player[1] = data.player[i]
            data.player[i] = temp
        end
    end
    return data.player;
end

function RoomDetailView:getPlayerIndex( userId,playerList )
    for i, v in ipairs(playerList) do
        if (userId == v.userId) then
            return i
        end
    end
end

return RoomDetailView