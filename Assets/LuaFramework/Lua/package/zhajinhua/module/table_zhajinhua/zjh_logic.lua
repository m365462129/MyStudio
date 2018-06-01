---
--- Created by chenz.
--- DateTime: 2017/9/28 15:59
---

---@type CardTool CardTool
local CardTool = require "package/zhajinhua/module/table_zhajinhua/card_tool" --require "card_tool"
---@type CardCommon CardCommon
local CardCommon = require "package/zhajinhua/module/table_zhajinhua/gamelogic_common" --"gamelogic_common"



---@class ZjhLogic
local ZjhLogic = {}


---@return 牌列表转换为牌值
---@param cards table,cards
function ZjhLogic.idx2value(cards)
    if not CardTool.table_nil_or_null(cards) then
        return cards
    else
        local newcards = {}
        for i, j in ipairs(cards) do
            table.insert(newcards, CardCommon.NameIdx2Value(j))
        end
        return newcards
    end
end

---@return 牌值转换为牌
---@param cards table,cards
function ZjhLogic.idx2name(cards)
    if not CardTool.table_nil_or_null(cards) then
        return cards
    else
        local newcards = {}
        for i, j in ipairs(cards) do
            table.insert(newcards, CardCommon.Value2Name(j))
        end
        return newcards
    end
end



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
function ZjhLogic.shuffle(cards_removed, randomseed)
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
    --doAddOneCard(cards, CardCommon.card_small_king, CardCommon.color_black_heart, cards_removed)
    --doAddOneCard(cards, CardCommon.card_big_king, CardCommon.color_black_heart, cards_removed)
    local cards_return_idx = CardCommon.GenerateRandomSequence(#cards);
    local cards_return = {}
    for _, v in ipairs(cards_return_idx) do
        table.insert(cards_return, cards[v])
    end
    return cards_return
end

--发牌
function ZjhLogic.deal(cards, player_cnt)
    assert(cards)
    local player_cards = { }
    for i = 1, player_cnt do
        local tempcard = {}
        for j = 1, 3 do
            table.insert(tempcard, cards[i + player_cnt * (j - 1)])
        end
        table.insert(player_cards, tempcard)
    end
    return player_cards
end





---@return 是否是豹子
---@param cards table
function ZjhLogic.is_baozi(cards)
    local cardvalues = ZjhLogic.idx2value(cards)
    if CardTool.table_same_value(cardvalues) then
        return cardvalues[1]
    else
        return false
    end
end

---@return 是否是顺金
---@param cards table
function ZjhLogic.is_shunjin(cards, smallorsecond)
    local shunzi = ZjhLogic.is_shunzi(cards, smallorsecond)
    if ZjhLogic.is_jinhua(cards) and shunzi then
        return shunzi
    else
        return false
    end
end

---@return 是否是金花
---@param cards table
function ZjhLogic.is_jinhua(cards)
    local colorvalue = CardTool.table_num_remain(cards, 4)
    if CardTool.table_same_value(colorvalue) then
        return CardCommon.NameIdx2Value(CardTool.Max(cards))
    else
        return false
    end
end

---@return 是否是顺子
---@param cards table
---@param smallorsecond bool 123是最小的顺子
function ZjhLogic.is_shunzi(cards, smallorsecond)
    local cardvalues = ZjhLogic.idx2value(cards)
    if CardTool.table_value_shunzi(cardvalues) then
        local maxvalue = CardTool.Max(cardvalues)
        if smallorsecond then
            return maxvalue
        else
            if maxvalue == CardCommon.max_normal_card_name then
                return maxvalue + 1
            else
                return maxvalue
            end
        end
    else
        local namevalue = ZjhLogic.idx2name(cardvalues)
        if CardTool.table_value_shunzi(namevalue) then
            if smallorsecond then
                return 0
            else
                return CardCommon.max_normal_card_name
            end
        else
            return false
        end
    end
end

---@return 是否是特殊牌型2，3，5
---@param cards table
function ZjhLogic.is_special(cards)
    local cardvalues = CardTool.sort_ascend(ZjhLogic.idx2value(cards))
    if not ZjhLogic.is_jinhua(cards) and #cardvalues == 3 and cardvalues[1] == 2 and cardvalues[2] == 3 and cardvalues[3] == 5 then
        return true
    else
        return false
    end
end


---@return 是否是对子
---@param cards table
function ZjhLogic.is_duizi(cards)
    local cardvalues = ZjhLogic.idx2value(cards)
    local twol = CardTool.remove_two_same(cardvalues)
    if #twol > 0 then
        return twol[1]
    else
        return false
    end
end

---@return 返回牌型
---@param cards table
---@param special boolean 是否返回特殊牌型
function ZjhLogic.cards_type(cards, special)
    if type(cards) ~= "table" or #cards ~= 3 then
        return CardCommon.unknown
    else
        if ZjhLogic.is_baozi(cards) then
            return CardCommon.baozi
        elseif ZjhLogic.is_shunjin(cards, true) then
            return CardCommon.shunjin
        elseif ZjhLogic.is_jinhua(cards) then
            return CardCommon.jinhua
        elseif ZjhLogic.is_shunzi(cards) then
            return CardCommon.shunzi
        elseif ZjhLogic.is_duizi(cards) then
            return CardCommon.duizi
        elseif ZjhLogic.is_special(cards) then
            if special then
                return CardCommon.special
            else
                return CardCommon.danzhang
            end
        else
            return CardCommon.danzhang
        end
    end
end


---@return 比较普通牌型大小
---@param data table {{playerid=,cards = {}},...}
---@param color  int 0，不比花色，打平 1,比较花色 2，不比花色谁先开牌谁输
---@param firstid int 比牌者id
function ZjhLogic.compare_normal(data1, data2, color, firstid)
    local cards1, cards2 = data1.cards, data2.cards
    local playerid1, playerid2 = data1.playerid, data2.playerid
    local type1 = ZjhLogic.cards_type(cards1, false)
    local type2 = ZjhLogic.cards_type(cards2, false)
    local secondid = playerid1
    if firstid == playerid1 then
        secondid = playerid2
    end
    if type1 > type2 then
        return playerid1
    elseif type1 < type2 then
        return playerid2
    else
        local resultid = 0
        if type1 == CardCommon.duizi then
            resultid = ZjhLogic.compare_duizi(data1, data2, color)
        elseif type1 == CardCommon.baozi then
            resultid = ZjhLogic.compare_baozi(data1, data2, color)
        else
            resultid = ZjhLogic.compare_danpai(data1, data2, color)
        end
        if resultid == 2 then
            resultid = secondid
        end
        return resultid
    end
end

---@return 比较多个牌型大小
---@param data table {{playerid=,cards = {}},...}
---@param color  int 0，不比花色，打平 1,比较花色 2，不比花色谁先开牌谁输
---@param firstid int 比牌者id
---@param special_all_baozi boolean 大于所有豹子 true 大于AAA false
function ZjhLogic.compare_more(data, special_all_baozi)
    if #data >= 2 then
        local have_baozi = false
        local have_special = false
        local winnerid = 0
        for i, j in pairs(data) do
            local ct = ZjhLogic.cards_type(j.cards, true)
            if ct == CardCommon.special then
                have_special = true
                winnerid = j.playerid
            elseif ct == CardCommon.baozi then
                have_baozi = true
            end
        end
        if have_baozi and have_special then
            return winnerid
        else
            table.sort(data, function(a, b)
                return ZjhLogic.compare_size(a, b, 2, 0, special_all_baozi)
            end)
        end
    else
        return 0
    end
end

---@return 比较牌型大小
---@param data table {{playerid=,cards = {}},...}
---@param color  int 0，不比花色，打平 1,比较花色 2，不比花色谁先开牌谁输
---@param firstid int 比牌者id
---@param special_all_baozi boolean 大于所有豹子 true 大于AAA false
function ZjhLogic.compare_size(data1, data2, color, firstid, special_all_baozi)
    local cards1, cards2 = data1.cards, data2.cards
    local playerid1, playerid2 = data1.playerid, data2.playerid
    local type1 = ZjhLogic.cards_type(cards1, true)
    local type2 = ZjhLogic.cards_type(cards2, true)
    if type1 == CardCommon.special and type2 == CardCommon.baozi then
        if special_all_baozi then
            return playerid1
        else
            local baozi_value = ZjhLogic.is_baozi(cards2)
            if baozi_value and CardCommon.Value2Name(baozi_value) == CardCommon.card_A then
                return playerid1
            else
                return ZjhLogic.compare_normal(data1, data2, color, firstid)
            end
        end
    elseif type2 == CardCommon.special and type1 == CardCommon.baozi then
        if special_all_baozi then
            return playerid2
        else
            local baozi_value = ZjhLogic.is_baozi(cards1)
            if baozi_value and CardCommon.Value2Name(baozi_value) == CardCommon.card_A then
                return playerid2
            else
                return ZjhLogic.compare_normal(data1, data2, color, firstid)
            end
        end
    else
        return ZjhLogic.compare_normal(data1, data2, color, firstid)
    end
end


---@return 对子比较大小
---@param data1 table {playerid=,cards = {}}
---@param data2 table {playerid=,cards = {}}
---@param color int 0，不比花色，打平 1,比较花色 2，不比花色谁先开牌谁输
function ZjhLogic.compare_duizi(data1, data2, color)
    local cards1, cards2 = data1.cards, data2.cards
    local playerid1, playerid2 = data1.playerid, data2.playerid
    local cardvalue1 = ZjhLogic.is_duizi(cards1)
    local cardvalue2 = ZjhLogic.is_duizi(cards2)
    if cardvalue1 and cardvalue2 then
        if cardvalue1 > cardvalue2 then
            return playerid1
        elseif cardvalue1 < cardvalue2 then
            return playerid2
        else
            local surcard1 = CardTool.TableSubtract(cards1, ZjhLogic.value2have_idx(cardvalue1, cards1))
            local surcard2 = CardTool.TableSubtract(cards2, ZjhLogic.value2have_idx(cardvalue2, cards1))
            local surcard1value = CardCommon.NameIdx2Value(surcard1)
            local surcard2value = CardCommon.NameIdx2Value(surcard2)
            if surcard1value > surcard2value then
                return playerid1
            elseif surcard1value < surcard2value then
                return playerid2
            else
                if color == 1 then
                    local maxcard1, maxcard2 = CardTool.Max(cards1), CardTool.Max(cards2)
                    if maxcard1 > maxcard2 then
                        return playerid1
                    else
                        return playerid2
                    end
                else
                    return color
                end
            end
        end
    else
        return 0
    end
end

---@return 比较豹子大小
---@param data1 table {playerid=,cards = {}}
---@param data2 table {playerid=,cards = {}}
function ZjhLogic.compare_baozi(data1, data2)
    local cards1, cards2 = data1.cards, data2.cards
    local playerid1, playerid2 = data1.playerid, data2.playerid
    local cardvalue1 = ZjhLogic.is_baozi(cards1)
    local cardvalue2 = ZjhLogic.is_baozi(cards2)
    if cardvalue1 and cardvalue2 then
        if cardvalue1 > cardvalue2 then
            return playerid1
        else
            return playerid2
        end
    else
        return 0
    end
end
---@return 比较单牌大小
---@param data1 table {playerid=,cards = {}}
---@param data2 table {playerid=,cards = {}}
---@param color int 0，不比花色，打平 1,比较花色 2，不比花色谁先开牌谁输
function ZjhLogic.compare_danpai(data1, data2, color)
    local cards1, cards2 = data1.cards, data2.cards
    local playerid1, playerid2 = data1.playerid, data2.playerid
    local cards1value = CardTool.sort_descend(ZjhLogic.idx2value(cards1))
    local cards2value = CardTool.sort_descend(ZjhLogic.idx2value(cards2))
    local bigger, i = 0, 1
    while (bigger == 0 and i < 4) do
        if cards1value[i] > cards2value[i] then
            bigger = playerid1
        elseif cards1value[i] < cards2value[i] then
            bigger = playerid2
        end
        i = i + 1
    end
    if bigger > 0 then
        return bigger
    else
        if color == 1 then
            local maxcard1, maxcard2 = CardTool.Max(cards1), CardTool.Max(cards2)
            if maxcard1 > maxcard2 then
                return playerid1
            else
                return playerid2
            end
        else
            return color
        end
    end
end


---@return 牌值转换为手牌中的索引（全部拥有的牌）
---@param cardvalue int
---@param handcard table
function ZjhLogic.value2have_idx(cardvalue, handcard)
    local cardl = ZjhLogic.value2idx(cardvalue)
    local havecardl = {}
    for i, j in ipairs(cardl) do
        if CardTool.TableMember(handcard, j) then
            table.insert(havecardl, j)
        end
    end
    havecardl = CardTool.sort_ascend(havecardl)
    return havecardl
end

---@return 牌值转换为牌中的索引
---@param cardvalue int
function ZjhLogic.value2idx(cardvalue)
    local cardname = CardCommon.card_unknown
    for i, j in ipairs(CardCommon.CardValue) do
        if cardvalue == j then
            cardname = i
        end
    end
    return {
        CardCommon.FormatCardIndex(cardname, CardCommon.color_black_heart),
        CardCommon.FormatCardIndex(cardname, CardCommon.color_red_heart),
        CardCommon.FormatCardIndex(cardname, CardCommon.color_plum),
        CardCommon.FormatCardIndex(cardname, CardCommon.color_square)
    }
end


return ZjhLogic