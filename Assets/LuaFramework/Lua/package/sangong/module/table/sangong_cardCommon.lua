--- 三公扑克牌通用处理
--- Created by 袁海洲
--- DateTime: 2017/11/22 13:17
---
local CardCommon = {}

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
CardCommon.color_black_heart = 1
CardCommon.color_red_heart = 2
CardCommon.color_plum = 3
CardCommon.color_square = 4
CardCommon.no_triple_p1 = true
CardCommon.tripleA_is_bomb = true
CardCommon.allow_unruled_multitriple = true
-- 牌值定义，下标对应到牌名
CardCommon.CardValue = { 12, 14, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16, 18 }
CardCommon.SortedCardName = {
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
    CardCommon.card_A,
    CardCommon.card_2,
    CardCommon.card_small_king,
    CardCommon.card_big_king
}
CardCommon.max_card_value = 15
CardCommon.max_card_name = CardCommon.card_big_king
CardCommon.max_normal_card_name = 13
CardCommon.max_card_cnt = 13 * 4 + 2

function CardCommon.ResolveCardIdx(name_idx)
    local name = math.modf((name_idx - 1) / 4 + 1)
    local color = name_idx - (name - 1) * 4
    return { name = name, color = color }
end

function CardCommon:getImageNameFromCode(code, majorCardLevel)
    if 0 == code then
        return 'paibei'
    end
    local card = self.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function CardCommon:getImageNameFromCard(card, majorCardLevel)
    local color = card.color
    local number = card.name
    if(number == self.card_small_king)then
        return 'little_boss'
    elseif(number == self.card_big_king)then
        return 'big_boss'
    end

    if(color == self.color_black_heart)then
        return 'heitao_' .. number
    elseif(color == self.color_red_heart)then
        if(majorCardLevel)then
            return 'xing_' .. number
        end
        return 'hongtao_' .. number
    elseif(color == self.color_plum)then
        return 'meihua_' .. number
    elseif(color == self.color_square)then
        return 'fangkuai_' .. number
    else

    end
end

return CardCommon