local BranchPackageName = 'daigoutui'
local CardCommon = require(string.format("package/%s/module/table/gamelogic_common",BranchPackageName))
-- CardCommon = require "gamelogic_common"
-- 牌型类
local CardPattern={}

-- 牌名索引 （牌名-1）* 4 + 花色, 前端收到的永远只是牌名索引，但可通过牌名索引计算出牌名与花色
-- 前后端及传输协议中保存的都是牌名索引

-- 新建并初始化一个牌型实例 return instance of CardPattern
function CardPattern.new(cards, servant_card, is_lord_player,most_great_servant_card_1v4)
	return CardPattern.NewPattern(cards, servant_card, is_lord_player, most_great_servant_card_1v4);
end

function CardPattern.UniqueCombine(repeat_info, new_info_list)
    if not repeat_info  then
        return new_info_list;
    end
    if not new_info_list then
        return repeat_info;
    end
    for _,new_info in ipairs(new_info_list) do
        local is_unique = true;
        for _,info in ipairs(repeat_info) do
            if (info.value == new_info.value 
                and info.type == new_info.type
                and info.color == new_info.color) 
            then
                is_unique = false;
                break;
            end
        end
        if (is_unique) then 
            table.insert(repeat_info, new_info);
        end
    end
end

-- 判断两次出牌的牌型是否匹配
function CardPattern:compable(card_obj)
    if (card_obj == nil) then
        return false;
    end;

    if self.type == CardCommon.type_bomb or card_obj.type == CardCommon.type_bomb then
        return true;
    end
    return self.card_cnt == card_obj.card_cnt and self.type == card_obj.type;
end


function CardPattern:ResolveBond(card_type_stat,card_name_info,card_name_stat)
    if (self.card_cnt < 3) then
        return nil;
    end
    if (self.type ~= CardCommon.type_bomb) then
        return nil;
    end 
    --是否启用喜牌分,为false直接返回nil
    if not CardCommon.enableBondCardScore then
        return nil
    end
    local small_king_cnt =  card_name_stat[CardCommon.card_small_king];
    local big_king_cnt = card_name_stat[CardCommon.card_big_king];

    if (small_king_cnt + big_king_cnt) >= 4  then  
        local bt_types = {CardCommon.bt_bomb_king_4,CardCommon.bt_bomb_king_5,CardCommon.bt_bomb_king_6};
        if ((small_king_cnt == 3 or big_king_cnt == 3) and (small_king_cnt + big_king_cnt) == 4) then 
            return {CardCommon.bt_bomb_king_3p1}
        end
        return {bt_types[small_king_cnt + big_king_cnt-3]};
    elseif (small_king_cnt == 3) then 
        return {CardCommon.bt_bomb_small_king};
    elseif (big_king_cnt == 3) then 
        return {CardCommon.bt_bomb_big_king};
    else 
        local black_cnt =0;
        local red_cnt = 0;
        for i=1,self.card_cnt do
            local cardinfo = CardCommon.ResolveCardIdx(self.cards[i]);
            if (cardinfo.color % 2 == 1) then
                black_cnt = black_cnt + 1;
            else
                red_cnt = red_cnt+ 1;
            end
        end
        local return_types = {};
        local bt_types = {CardCommon.bt_bomb_7,CardCommon.bt_bomb_8,CardCommon.bt_bomb_9,CardCommon.bt_bomb_10,CardCommon.bt_bomb_11,CardCommon.bt_bomb_12};
        if (self.card_cnt > 6 ) then 
            table.insert(return_types, bt_types[self.card_cnt-6]);
        end
        local bt_types = {CardCommon.bt_bomb_color_5, CardCommon.bt_bomb_color_6}
        if (red_cnt >= 5) then 
            table.insert(return_types, bt_types[red_cnt-4]);
        end
        if (black_cnt >= 5) then 
            table.insert(return_types, bt_types[black_cnt-4]);
        end
        return return_types;
    end
end

-- 判断两次出牌的大小 小于等于返回真，否则返回假
function CardPattern:le(card_obj)
	-- 牌型系数说明,影响牌值比较
	local CardTypeFactor={0,0,0,(CardCommon.max_card_value)*1,0,0}
	-- 要求调用此函数之前必须先调用compable
	assert(self:compable(card_obj))
	-- 牌值合法性检查
    return self.value <= card_obj.value;
end

function CardPattern.Encap(obj)    
    setmetatable(obj, {__index=CardPattern})
    return obj;
end

function CardPattern.NewPattern(cards, servant_card, is_lord_player, most_great_servant_card_1v4)
    if most_great_servant_card_1v4 == nil then
        if (not is_lord_player) then 
            servant_card = 0;
        end 
    elseif (not most_great_servant_card_1v4) or (not is_lord_player) then 
        servant_card = 0;
    end 
    if (cards == nil or #cards == 0) then
        return nil;
    end;
    local pt = {};
    setmetatable(pt, {__index=CardPattern})
    pt.cards = {}
      
    pt.card_cnt = #cards
    pt.repeat_cnt = 1;
    CardCommon.Combine(pt.cards, cards);
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(pt.cards, false, servant_card)
    local small_king_cnt =  card_name_stat[CardCommon.card_small_king];
    local big_king_cnt = card_name_stat[CardCommon.card_big_king];
    local king_cnt = big_king_cnt+small_king_cnt;
    
    if king_cnt >= 4 and king_cnt == pt.card_cnt then 
        pt.type = CardCommon.type_bomb;    
        pt.value = 550 + (king_cnt - 4 ) * 200
        pt.bond_list = pt:ResolveBond(card_type_stat,card_name_info,card_name_stat)
        return pt;
    end
    if pt.card_cnt == 3 then 
        if small_king_cnt == 3 then 
            pt.type = CardCommon.type_bomb
            pt.value = 250;
            pt.bond_list = pt:ResolveBond(card_type_stat,card_name_info,card_name_stat)
            return pt;
        elseif big_king_cnt == 3 then
            pt.type = CardCommon.type_bomb
            pt.value = 350;
            pt.bond_list = pt:ResolveBond(card_type_stat,card_name_info,card_name_stat)
            return pt;
        end
    end 
    --炸弹
    local is_same_card = false;
    for i=1,#card_type_stat do 
        if #card_type_stat[i] > 0 and pt.card_cnt == i then
            is_same_card = true;
            break;
        end
    end
    if is_same_card then 
        local cardinfo = CardCommon.ResolveCardIdx(pt.cards[1]);
        if pt.card_cnt == 1 then 
            if (pt.cards[1] == servant_card and is_lord_player) then
                pt.type = CardCommon.type_bomb
                pt.value = 1000;
            else 
                pt.type = CardCommon.type_single;    
                pt.value = CardCommon.Name2Value(cardinfo.name);
            end
        elseif pt.card_cnt == 2 then 
            pt.type = CardCommon.type_double;    
            pt.value = CardCommon.Name2Value(cardinfo.name);
        elseif pt.card_cnt == 3 then 
            pt.type = CardCommon.type_triple;    
            pt.value = CardCommon.Name2Value(cardinfo.name);
        elseif pt.card_cnt >= 4 then 
            pt.type = CardCommon.type_bomb;    
            pt.value = CardCommon.Name2Value(cardinfo.name)+(pt.card_cnt - 3)*100;
            pt.bond_list = pt:ResolveBond(card_type_stat, card_name_info, card_name_stat)
        end
        return pt;
    else  --不是相同的牌（同牌名可不同花色）
        if CardCommon.enableSequentialSingle and pt.card_cnt >= 5 then
            --单张牌顺子
            local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_single],card_name_stat)
            if max_repeat.repeat_cnt == pt.card_cnt then 
                pt.type = CardCommon.type_sequence_single;    
                pt.value = CardCommon.Name2Value(max_repeat.card_end);
                pt.repeat_cnt = max_repeat.repeat_cnt
                return pt
            end
        end

        if pt.card_cnt == 5 then
            --三带二
            if #card_type_stat[3] == 1 and card_type_stat[3][1] < CardCommon.card_small_king and #card_type_stat[2] == 1 then 
                pt.type = CardCommon.type_triple_p2;    
                pt.value = CardCommon.Name2Value(card_type_stat[3][1]);
                return pt;
            end
            return nil;
        elseif pt.card_cnt <= 4 then
            return nil;
        elseif pt.card_cnt % 2 == 0 or pt.card_cnt % 3 == 0 or pt.card_cnt % 5 == 0 then
            if pt.card_cnt % 2 == 0 then 
                local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_double],card_name_stat)
                if max_repeat.repeat_cnt * 2 == pt.card_cnt then 
                    pt.type = CardCommon.type_sequence_double;    
                    pt.value = CardCommon.Name2Value(max_repeat.card_end);
                    pt.repeat_cnt = max_repeat.repeat_cnt
                    return pt;
                end
            end 
            if pt.card_cnt % 3 == 0 then 
                local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_triple],card_name_stat)
                if max_repeat.repeat_cnt * 3 == pt.card_cnt then 
                    pt.type = CardCommon.type_sequence_triple;    
                    pt.value = CardCommon.Name2Value(max_repeat.card_end);
                    pt.repeat_cnt = max_repeat.repeat_cnt
                    return pt;
                end
            end 
            if pt.card_cnt % 5 == 0 then 
                local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_triple],card_name_stat)
                local max_repeat2, repeat_list2 = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_double],card_name_stat)
                if (max_repeat.repeat_cnt == 2 and max_repeat2.repeat_cnt == 2 and pt.card_cnt == 10)
                    or (max_repeat.repeat_cnt > 2 and #card_type_stat[CardCommon.type_double] == max_repeat.repeat_cnt and max_repeat.repeat_cnt*5 == pt.card_cnt)
                then 
                    pt.type = CardCommon.type_sequence_triple_p2;    
                    pt.value = CardCommon.Name2Value(max_repeat.card_end);
                    pt.repeat_cnt = max_repeat.repeat_cnt
                    return pt;
                end
            end 
            return nil; 
        else
            return nil;
        end
    end
end

function CardPattern:clone()
    local o = {};
    setmetatable(o, {__index=CardPattern})
    o.card_cnt = self.card_cnt;
    o.cards = {};
    CardCommon.Combine(o.cards, self.cards);
    o.type = self.type;
    o.value = self.value;
    o.repeat_cnt = self.repeat_cnt;
    return o;
end

-- 判断是否为合法牌型，合法返回true,否则返回假 
function CardPattern:parse(cards, servant_card, is_lord_player, most_great_servant_card_1v4)
	if CardPattern.new(cards, servant_card, is_lord_player, most_great_servant_card_1v4) then 
        return true;
    end 
    return false;
end

function CardPattern:count(card,ignore_id)
    local cnt = 0;

    for _,c in ipairs(self.cards) do
        if ignore_id then 
            if (c % 256) == (card) then
		        cnt = cnt + 1
            end
	    elseif (c == card) then
		    cnt = cnt + 1
	    end
    end
    return cnt;
end
return CardPattern