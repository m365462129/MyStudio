---
--- Created by chenz.
--- DateTime: 2017/9/30 14:03
---
---@class CardCommon
local CardCommon = {}

CardCommon.unknown = 0             -->未知牌型
CardCommon.danpai = 1              -->单牌：单张的牌（例如黑桃K）；
CardCommon.duizi = 2               -->对子：牌面数字相同的2张牌（例如黑桃K+红桃K）；
CardCommon.sandaiyi = 3            -->三带一：牌面数字相同的3张牌+1张单牌或对子（例如KKK+8或QQQ+44）；
CardCommon.feiji = 4               -->飞机：2个或更多的连续三张牌型，飞机牌型中每1个三张都可+1张单牌或对子（例如：333444+78或333444+7788）；
CardCommon.shunzi = 5              -->顺子：5张或更多的连续单牌（例如78910J，3456789）；
CardCommon.liandui = 6             -->连对：3对或以上的连续对子牌型（例如334455，991010JJQQ）；
CardCommon.zhadan = 7              -->炸弹：牌面数字相同的4张牌（例如KKKK，QQQQ，3333）；
CardCommon.huojian = 8             -->火箭：双王，即大小王，最大的牌；
CardCommon.sidaier = 9             -->四带二：牌面数字相同的4张牌+2张牌（例如KKKK+89，8888+AA）。

CardCommon.tishi = {3,4,5,8,6,7,2,1,0}    --飞机>连对>顺子>三张>对子>单牌>炸弹》火箭

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

function CardCommon.InitConf(no_triple_p1, tripleA_is_bomb, allow_unruled_multitriple)
    CardCommon.no_triple_p1 = no_triple_p1
    CardCommon.tripleA_is_bomb = tripleA_is_bomb
    CardCommon.allow_unruled_multitriple = allow_unruled_multitriple;
end

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

-- 初始牌型分析，仅统计单牌、对牌、三张及王炸的个数
function CardCommon.InitParse(cards)
    for _,c in ipairs(cards) do
        local name = CardCommon.ResolveCardIdx(c)
        --print(_,c, name, CardValue[name])
    end
    table.sort(cards)
    for _,c in ipairs(cards) do
        local name = CardCommon.ResolveCardIdx(c)
        --print(_,c, name, CardValue[name])
    end
    CardCommon.SortAsc(cards)
    --[[table.sort(cards, function (a,b)
        local index_a = math.modf((a-1)/4+1)
        local index_b = math.modf((b-1)/4+1)
        if (CardCommon.Name2Value(index_a) == CardCommon.Name2Value(index_b)) then
            return a < b
        else
            return CardCommon.Name2Value(index_a) < CardCommon.Name2Value(index_b)
        end

    end)--]]
    for _,c in ipairs(cards) do
        local name = CardCommon.ResolveCardIdx(c)
        --print(_,c, name, CardValue[name])
    end
    -- 牌型数量统计
    local card_type_stat={{},{},{},{}}
    local card_name_info={}
    -- 针对各张牌名的数量统计
    local card_name_stat={}
    for idx=1,CardCommon.max_card_name
    do
        card_name_stat[idx] = 0
        card_name_info[idx] = {}
    end
    local last_card = CardCommon.card_unknown
    local card_repeat_cnt = 0
    for _,c in ipairs(cards)
    do
        assert(c > 0)
        local name = math.modf((c-1)/4+1)
        card_name_stat[name] = card_name_stat[name]+1
        table.insert(card_name_info[name],c)
        -- 暂时支持一副牌
        assert(card_name_stat[name] <= 4)
        --table.insert(card_type_stat[card_name_stat[name]],name)
        if last_card == CardCommon.card_unknown then
            last_card = name
            card_repeat_cnt = 1
        elseif name ~= last_card  then
            if (card_repeat_cnt == 4) then
                table.insert(card_type_stat[4],last_card)
            else
                for i=1,card_repeat_cnt do
                    table.insert(card_type_stat[i],last_card)
                end
            end
            last_card = name
            card_repeat_cnt = 1
        else
            card_repeat_cnt = card_repeat_cnt + 1
        end

    end
    if (card_repeat_cnt == 4) then
        table.insert(card_type_stat[4],last_card)
    else
        for i=1,card_repeat_cnt do
            table.insert(card_type_stat[i],last_card)
        end
    end
    return card_type_stat,card_name_info,card_name_stat
end

function CardCommon.StatRepeatCnt (card_type_stat, card_name_stat)
    local repeat_info = {}
    if ((card_type_stat == nil) or (#card_type_stat == 0)) then
        return nil, nil
    end
    local card_cnt = #card_type_stat
    local last_value = 0
    local total_cards_cnt = 0
    for _, cnt in ipairs(card_name_stat) do
        total_cards_cnt = total_cards_cnt + cnt;
    end

    for name_idx = 1, card_cnt
    do
        --print("index=",name_idx, " value=",CardCommon.Name2Value(card_type_stat[name_idx]))
        local value = CardCommon.Name2Value(card_type_stat[name_idx])
        if name_idx == 1 then
            info = { repeat_cnt = 1
                , card_start = card_type_stat[name_idx]
                , card_end = card_type_stat[name_idx]
                , cards = { card_type_stat[name_idx] } }
            table.insert(repeat_info, info)
            max_repeat_info = info
        elseif value == last_value + 1 then
            info.card_end = card_type_stat[name_idx]
            info.repeat_cnt = info.repeat_cnt + 1
            table.insert(info.cards, card_type_stat[name_idx])
        else
            if (info.repeat_cnt > max_repeat_info.repeat_cnt) then
                max_repeat_info = info
            end
            info = { repeat_cnt = 1
                , card_start = card_type_stat[name_idx]
                , card_end = card_type_stat[name_idx]
                , cards = { card_type_stat[name_idx] } }
            table.insert(repeat_info, info)
        end
        last_value = value
    end
    if ((not max_repeat_info) or (info.repeat_cnt > max_repeat_info.repeat_cnt)) then
        max_repeat_info = info
    end
    max_repeat_info.total_cards_cnt = total_cards_cnt;
    return max_repeat_info, repeat_info
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