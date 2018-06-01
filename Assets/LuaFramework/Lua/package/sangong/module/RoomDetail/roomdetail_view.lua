--- 三公历史战绩房间详情 view
--- Created by 袁海洲
--- DateTime: 2017/12/7 10:58
---
-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local RoomDetailView = Class('roomDetailView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local ComponentUtil = ModuleCache.ComponentUtil
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local cardCommon = require('package.sangong.module.table.sangong_cardCommon')

function RoomDetailView:initialize(...)
    -- 初始View
    View.initialize(self, "sangong/module/roomdetail/sangong_windowroomdetail.prefab", "SanGong_WindowRoomDetail", 1)


    self.buttonClose       = GetComponentWithPath(self.root, "TopLeft/Child/ImageBack", ComponentTypeName.Button)
    self.cloneObj          = GetComponentWithPath(self.root,"Top/Panels/ItemHolder/item0",ComponentTypeName.Transform).gameObject
    self.content           = GetComponentWithPath(self.root,"Top/Panels/Scroll View/Viewport/Content",ComponentTypeName.Transform)
    self.textRule          = GetComponentWithPath(self.root,"Top/Child/Image/lbRule",ComponentTypeName.Text)

    -- 扑克图集
    self.spriteAsset = GetComponentWithPath(self.root,"Top/PokerAssetHolder","SpriteHolder")
    -- 红色图集
    self.redAtlas    = GetComponentWithPath(self.root, "Top/RedNumbersHolder", "SpriteAtlas")
    -- 绿色图集
    self.greenAtlas  = GetComponentWithPath(self.root, "Top/GreenNumbersHolder", "SpriteAtlas")

end


function RoomDetailView:initRoomInfo(roomInfo)
    -- print_table(roomInfo)
    self.creatorId = roomInfo.creatorId
    self.textRule.text = self:getPlayRuleString(roomInfo.playRule)
end

function RoomDetailView:getPlayRuleString(playRuleString)
    local playRule = ModuleCache.Json.decode(playRuleString)
    local ruleStr = "三公 "
    if playRule.game_type == 1 then
        ruleStr = "自由下注 "
    elseif playRule.game_type == 2 then
        ruleStr = "自由抢庄 "
    end

    ruleStr = ruleStr..playRule.roundCount.."局 "..playRule.playerCount.."人 "

    --[[if playRule.isBigBet then
        if playRule.isBigBet == 0 then ruleStr = ruleStr.."小倍场 " end
        if playRule.isBigBet == 1 then ruleStr = ruleStr.."大倍场 " end
    end--]]

    --[[if playRule.haveJQK == 1 then
        ruleStr = ruleStr.."带花牌 "
    end--]]

    if playRule.payType == 0 then
        ruleStr = ruleStr.."AA支付"
    elseif playRule.payType == 1 then
        ruleStr = ruleStr.."房主支付"
    elseif playRule.payType == 2 then
        ruleStr = ruleStr.."大赢家支付"
    end

    --[[if playRule.maxBetScore then
        ruleStr = ruleStr.." 加注上限:"..playRule.maxBetScore
    end--]]
    return ruleStr
end

function RoomDetailView:initLoopScrollViewList(roomData,disUserId)
    local roundList = roomData
    local contents = TableUtil.get_all_child(self.content)
    self.disUserId = disUserId
    ComponentUtil.SafeSetActive(self.content.gameObject, false)
    for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end
    if(roomData == nil) then return end
    for i=1, #roundList do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(self.cloneObj,self.content.gameObject,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)
        item.gameObject = obj
        item.data = roundList[i]
        self:fillItem(item,i)

    end
    self.content.transform.localPosition = Vector3.New(self.content.transform.localPosition.x, 0, self.content.transform.localPosition.z)
    ComponentUtil.SafeSetActive(self.content.gameObject, true)
end

function RoomDetailView:fillItem(item,index)

    local data = item.data
    print_table(data)

    local disInfoText =  GetComponentWithPath(item.gameObject, "DisInfoText", ComponentTypeName.Text);
    disInfoText.text = ""
    local lineObj = GetComponentWithPath(item.gameObject, "Players/Line", ComponentTypeName.Transform).gameObject;
    ComponentUtil.SafeSetActive(lineObj, true)
    local imageObj = GetComponentWithPath(item.gameObject, "Title/Image", ComponentTypeName.Transform).gameObject;
    ComponentUtil.SafeSetActive(imageObj,true)

    local curRound = GetComponentWithPath(item.gameObject, "Title/RoundNumLbl", ComponentTypeName.Text);
    curRound.text = data.roundNumber

    for i = 1, 6 do
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject;
        ComponentUtil.SafeSetActive(playerGo, false)
    end

    for k,v in ipairs(data.player) do
        local showIndex = v.showIndex
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. showIndex, ComponentTypeName.Transform).gameObject;
        self:showPlayerInfo(playerGo,data.result[v.userId],v,1 == index)
        ComponentUtil.SafeSetActive(playerGo, true)
    end
end

function RoomDetailView:fillDisInfo(item,disUserName)
    local data = item.data
    local disInfoText =  GetComponentWithPath(item.gameObject, "DisInfoText", ComponentTypeName.Text);
    local lineObj = GetComponentWithPath(item.gameObject, "Players/Line", ComponentTypeName.Transform).gameObject;
    ComponentUtil.SafeSetActive(lineObj, false)
    local imageObj = GetComponentWithPath(item.gameObject, "Title/Image", ComponentTypeName.Transform).gameObject;
    ComponentUtil.SafeSetActive(imageObj, false)
    disInfoText.text = disUserName.." 解散了房间"
    local curRound = GetComponentWithPath(item.gameObject, "Title/RoundNumLbl", ComponentTypeName.Text);
    curRound.text = ""
    for i = 1, 6 do
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject;
        ComponentUtil.SafeSetActive(playerGo, false)
    end
end

function RoomDetailView:showPlayerInfo(playerGo, recordData, playerInfo,needShowDisTag)
    local name         = GetComponentWithPath(playerGo, "lbName", ComponentTypeName.Text)
    local bankerIcon   = GetComponentWithPath(playerGo, "banker", ComponentTypeName.Transform).gameObject
    local cardTypeName = GetComponentWithPath(playerGo, "lbCow", ComponentTypeName.Text)
    local wrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")
    local uiState      = GetComponentWithPath(playerGo, "Pokers", "UIStateSwitcher")
    local disBankerIcon = GetComponentWithPath(playerGo, "disBanker", ComponentTypeName.Transform).gameObject
    name.text = Util.filterPlayerName(playerInfo.playerName,8)
    local scoreText = tostring(playerInfo.score)
    if playerInfo.score >= 0 then
        wrapRedScore.atlas = self.redAtlas
        scoreText = "+"..scoreText
    else
        wrapRedScore.atlas = self.greenAtlas
    end

    wrapRedScore.text = scoreText
    ComponentUtil.SafeSetActive(bankerIcon, recordData.banker == "1")
    ComponentUtil.SafeSetActive(disBankerIcon,needShowDisTag and playerInfo.userId == self.disUserId)

    cardTypeName.text = self:getCardTypeName(recordData.cardType)
    local showCards = recordData.cards
    for i=1,5 do
        local card = GetComponentWithPath(playerGo, "Pokers/"..i, ComponentTypeName.Image)
        if i > #showCards then
            ComponentUtil.SafeSetActive(card.gameObject,false)
        else
            ComponentUtil.SafeSetActive(card.gameObject,true)
            local cardSp = self.spriteAsset:FindSpriteByName(self:GetSpriteFromPoker(showCards[i]))
            card.sprite = cardSp
            card.color = Color.New(1,1,1,1)
        end
    end
end

function RoomDetailView:getCardTypeName(cardType)
    if  cardType == 0 then
        return "零点"
    end
    if  cardType == 1 then
        return "一点"
    end
    if  cardType == 2 then
        return "二点"
    end
    if  cardType == 3 then
        return "三点"
    end
    if  cardType == 4 then
        return "四点"
    end
    if  cardType == 5 then
        return "五点"
    end
    if  cardType == 6 then
        return "六点"
    end
    if  cardType == 7 then
        return "七点"
    end
    if  cardType == 8 then
        return "八点"
    end
    if  cardType == 9 then
        return "九点"
    end
    if  cardType == 10 then
        return "混三公"
    end
    if  cardType == 11 then
        return "小三公"
    end
    if  cardType == 12 then
        return "大三公"
    end
    if  cardType == 13 then
        return "三张三"
    end
end

function RoomDetailView:GetSpriteFromPoker(card)
    local poker = cardCommon.ResolveCardIdx(card)
    local color = poker.color
    local number = poker.name
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

function RoomDetailView:SetDisInfo(text)

end

return RoomDetailView