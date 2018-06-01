---
--- Created by chenz.
--- DateTime: 2017/11/1 15:39
---
---@type CardTool CardTool
local CardTool = require('package.laoyancai.module.table_laoyancai.card_tool')

---@type CardCommon CardCommon
local CardCommon = require('package.laoyancai.module.table_laoyancai.gamelogic_common')
---@class CardDeal
local CardDeal = {}


--添加一张牌到牌列表
local doAddOneCard = function(result, name, color, cards_removed)
    local card_idx = 0
    local remove_flag = false;
    card_idx = CardCommon.FormatCardIndex(name, color)
    for _, c in ipairs(cards_removed) do
        if (c == card_idx) then
            remove_flag = true
            break
        end
    end
    if not remove_flag then
        table.insert(result, card_idx)
    end
end

--洗牌
function CardDeal.shuffle(cards_removed, randomseed)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local card_names = CardCommon.GenerateRandomSequence(CardCommon.max_normal_card_name);
    local colors = { CardCommon.color_black_heart, CardCommon.color_red_heart, CardCommon.color_plum, CardCommon.color_square };
    local cards = {}

    for idx = 1, CardCommon.max_normal_card_name do
        local color_idx = CardCommon.GenerateRandomSequence(4)
        for i = 1, 4 do
            doAddOneCard(cards, card_names[idx], colors[color_idx[i]], cards_removed)
        end
    end
    local cards_return_idx = CardCommon.GenerateRandomSequence(#cards);
    local cards_return = {}
    for _, v in ipairs(cards_return_idx) do
        table.insert(cards_return, cards[v])
    end
    return cards_return
end

--发两张牌
function CardDeal.deal(cards, player_cnt)
    assert(cards)
    local player_cards = { }
    local used_cards = {}
    for i = 1, player_cnt do
        local tempcard = {}
        for j = 1, 2 do
            local facard = cards[i + player_cnt * (j - 1)]
            table.insert(tempcard, facard)
            table.insert(used_cards, facard)
        end
        table.insert(player_cards, tempcard)
    end
    return player_cards, CardTool.TableSubtract(cards, used_cards)
end

--牌的点数
function CardDeal.cards_score(cards)
    local add = 0
    for _, card in ipairs(cards) do
        add = CardCommon.NameIdx2Value(card) + add
    end
    return add % 10
end

--牌型
function CardDeal.cards_type(cards)
    if #cards < 2 then
        return CardCommon.normal
    end
    local cardsvalue, cards_color = {}, {}
    for _, card in ipairs(cards) do
        local t = CardCommon.ResolveCardIdx(card)
        table.insert(cardsvalue, t[1])
        table.insert(cards_color, t[2])
    end
    local cardtype = CardCommon.normal
    local twol1 = CardTool.remove_two_same(cardsvalue)
    local twol2 = CardTool.remove_three_same(cards_color)
    if #cards == 3 then
        local threel1 = CardTool.remove_three_same(cardsvalue)
        local threel2 = CardTool.remove_three_same(cards_color)
        if #threel1 == 1 then
            cardtype = CardCommon.sanpi
        elseif #threel2 == 2 then
            cardtype = CardCommon.sanyan
        elseif #twol1 == 1 or #twol2 == 1 then
            cardtype = CardCommon.shuangyan
        end
    elseif #cards == 2 then
        if #twol1 == 1 or #twol2 == 1 then
            cardtype = CardCommon.shuangyan
        end
    end
    return cardtype
end
--返回牌的大小  返回0 打平
function CardDeal.cards_size(data1, data2)
    local cards1, cards2 = data1.cards, data2.cards
    local playerid1, playerid2 = data1.playerid, data2.playerid
    local cardsvale1 = CardDeal.cards_score(cards1)
    local cardsvale2 = CardDeal.cards_score(cards2)
    if cardsvale1 > cardsvale2 then
        return playerid1
    elseif cardsvale2 > cardsvale1 then
        return playerid2
    else
        return 0
    end
end

return CardDeal