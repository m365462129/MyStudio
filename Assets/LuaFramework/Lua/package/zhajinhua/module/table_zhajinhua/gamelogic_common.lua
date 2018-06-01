---
--- Created by chenz.
--- DateTime: 2017/9/30 14:03
---
---@class CardCommon
local CardCommon = {}

CardCommon.unknown = 0             --未知牌型
CardCommon.danzhang = 1            --单张
CardCommon.duizi = 2               --对子
CardCommon.shunzi = 3              --顺子
CardCommon.jinhua = 4              --金花
CardCommon.shunjin = 5             --顺金
CardCommon.baozi = 6               --豹子
CardCommon.special = 7               --特殊牌型


-- 牌名说明 取值范围1~15   11代表J, 12代表Q, 13代表K, 1代表A, 2~10代表2~10 14代表小王 15代表大王
CardCommon.card_unknown = 0
CardCommon.card_A = 1
CardCommon.card_2 = 2
CardCommon.card_3 = 3
CardCommon.card_4 = 4
CardCommon.card_5 = 5
CardCommon.card_6 = 6
CardCommon.card_7 = 7
CardCommon.card_8 = 8
CardCommon.card_9 = 9
CardCommon.card_10 = 10
CardCommon.card_J = 11
CardCommon.card_Q = 12
CardCommon.card_K = 13
CardCommon.card_small_king = 14
CardCommon.card_big_king = 15
-- 花色说明 取值范围1~4   1代表黑桃 2代表红桃 3代表梅花 4代表方块
CardCommon.color_unkown = 0
CardCommon.color_black_heart = 4
CardCommon.color_red_heart = 3
CardCommon.color_plum = 2
CardCommon.color_square = 1
-- 牌值定义，下标对应到牌名
CardCommon.CardValue = { 13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
CardCommon.SortedCardName = {
    CardCommon.card_2,
    CardCommon.card_3,
    CardCommon.card_4,
    CardCommon.card_5,
    CardCommon.card_6,
    CardCommon.card_7,
    CardCommon.card_8,
    CardCommon.card_9,
    CardCommon.card_10,
    CardCommon.card_J,
    CardCommon.card_Q,
    CardCommon.card_K,
    CardCommon.card_A
}
CardCommon.max_normal_card_name = 13
CardCommon.max_card_cnt = 13 * 4 + 2

CardCommon.kanpai = 1
CardCommon.xiazhu = 2
CardCommon.genzhu = 3
CardCommon.jiazhu = 4
CardCommon.bipai = 5
CardCommon.qipai = 6
CardCommon.liangpai = 7


function CardCommon.NameIdx2Value(name_idx)
    return CardCommon.CardValue[math.modf((name_idx - 1) / 4 + 1)]
end
function CardCommon.Name2Value(name)
    return CardCommon.CardValue[name]
end

function CardCommon.Value2Name(value)
    for name, val in ipairs(CardCommon.CardValue) do
        if val == value then
            return name;
        end
    end
    return CardCommon.card_unknown;
end


function CardCommon.ResolveCardIdx(name_idx)
    local name = math.modf((name_idx - 1) / 4 + 1)
    local color = name_idx - (name - 1) * 4
    return { name = name, color = color }
end

function CardCommon.FormatCardIndex(name, color)
    return (name - 1) * 4 + color
end
function CardCommon.Sort(cards)
    table.sort(cards, function(a, b)
        local index_a = math.modf((a - 1) / 4 + 1)
        local index_b = math.modf((b - 1) / 4 + 1)
        if (CardCommon.Name2Value(index_a) == CardCommon.Name2Value(index_b)) then
            return a < b
        else
            return CardCommon.Name2Value(index_a) > CardCommon.Name2Value(index_b)
        end

    end)
end
function CardCommon.SortAsc(cards)
    table.sort(cards, function(a, b)
        local index_a = math.modf((a - 1) / 4 + 1)
        local index_b = math.modf((b - 1) / 4 + 1)
        if (CardCommon.Name2Value(index_a) == CardCommon.Name2Value(index_b)) then
            return a < b
        else
            return CardCommon.Name2Value(index_a) < CardCommon.Name2Value(index_b)
        end

    end)
end


function CardCommon.Combine(a, b)
    if a == nil then
        return b
    end
    if b then
        for i, v in ipairs(b) do
            table.insert(a, v)
        end
    end
    return a
end
function CardCommon.GenerateRandomSequence(cnt)
    local orignal = {}
    local rand_sequence = {}
    for idx = 1, cnt do
        table.insert(orignal, idx)
    end
    local rand_cnt = 0
    while (rand_cnt < cnt) do
        local x = math.random(1, cnt - rand_cnt);
        table.insert(rand_sequence, orignal[x])
        table.remove(orignal, x)
        rand_cnt = rand_cnt + 1
    end
    return rand_sequence

end

return CardCommon