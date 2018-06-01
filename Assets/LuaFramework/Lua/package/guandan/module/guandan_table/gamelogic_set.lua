local CardPattern = require "package.guandan.module.guandan_table.gamelogic_pattern"
local CardCommon = require "package.guandan.module.guandan_table.gamelogic_common"

--local Utils = require "utils"
-- �Ƽ���
local CardSet={}
CardSet.card_cnt = 0
CardSet.cards={}

-- �����µ��Ƽ����� return instance of CardSet
function CardSet.new(cards,card_cnt)
	local o = {}
	setmetatable(o, {__index=CardSet});
	if (cards ~= nil)then
		o.cards = {}
		for i,c in ipairs(cards)
		do
			table.insert(o.cards,c)
		end
	end
	if (card_cnt == nil) then
		card_cnt = #(o.cards)
	end
	o.card_cnt = card_cnt
	return o
end

local doGetCardsNormal=function (cards, start_idx, end_idx, multiplicity, card_name_info)
	local obj_card={}
	for idx=start_idx,end_idx do
		local name= cards[idx]
        for i=1,multiplicity do 
		    table.insert(obj_card,card_name_info[name][i])
        end
	end
	return CardPattern.new(obj_card);
end
local doGetCardsSameColor=function (cards, start_idx, card_name_info, color)
	local obj_card={}
    local obj_logic_card={}
	for idx=start_idx,start_idx+4 do
		local name= cards[idx]

        if name ~= CardCommon.magic_card then
            table.insert(obj_card, CardCommon.FormatCardIndex(name,color))
        else
            table.insert(obj_card, CardCommon.MagicCard);
        end
		
	end
	return CardPattern.new(obj_card);
end

CardSet.enum = {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil};

CardSet.enum_full = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_single](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_double](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_three](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_three_p2](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_triple2](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_double3](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_single_5](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt,true))
    return hintList;
end


CardSet.enum[CardCommon.type_single] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt,calc_bomb_pattern)
    --���Ƶ�������
    local hintList = {}
    local obj_type = CardCommon.type_single
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 1, repeat_cnt=1, value = 0}
    end
    local card_cnt = 1;
    local major_card = CardCommon.ResolveCardIdx(CardCommon.MagicCard).name;
    while #hintList == 0 and card_cnt < 4 do 
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            local major_cnt = cnt;
            if card == major_card then
                cnt = cnt + magic_cnt
            end
            if cnt == card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
                if card == major_card then
                    if major_cnt == 0 then 
                        local card_pattern = {cards={CardCommon.MagicCard}
                            , type = obj_type
                            , repeat_cnt=1
                            , card_cnt = pattern.card_cnt
                            , value = CardCommon.Name2Value(card,0) }
                        table.insert(hintList, CardPattern.Encap(card_pattern))  
                    else
                        local card_pattern = {cards={card_name_info[card][1]}
                            , type = obj_type
                            , repeat_cnt=1
                            , card_cnt = pattern.card_cnt
                            , value = CardCommon.Name2Value(card,0) }
                        table.insert(hintList, CardPattern.Encap(card_pattern))  
                    end
                else
                    local card_pattern = {cards={card_name_info[card][1]}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))    
                end
                

            end

        end
        card_cnt = card_cnt + 1
        if (pattern.value == 0) then
            break;
        end
    end
    
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end 
    return hintList;
end


CardSet.enum[CardCommon.type_single_5] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt,calc_bomb_pattern)
    local hintList = {}
    local obj_type = CardCommon.type_single_5
    if not pattern then 
        pattern = {type = obj_type, card_cnt=5, repeat_cnt=5, value = 0}
    end
    local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,1,pattern.repeat_cnt);
    CardPattern.UniqueCombine(hintList, CardPattern.NewPatternList(repeat_info, pattern))
    if magic_cnt and magic_cnt > 0 then
        local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,1,pattern.repeat_cnt,magic_cnt);
        CardPattern.UniqueCombine(hintList, CardPattern.NewPatternList(repeat_info, pattern))
    end
    
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end
    
    --����ը��
    return hintList;
end
CardSet.enum[CardCommon.type_double] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt, calc_bomb_pattern)
    local hintList = {}
    local obj_type = CardCommon.type_double
    if not pattern then 
        pattern = {type = obj_type, card_cnt=2, repeat_cnt=1, value = 0}
    end
    local card_cnt = 2;
    local major_card = CardCommon.ResolveCardIdx(CardCommon.MagicCard).name;
    while #hintList == 0 and card_cnt < 4 do 
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            local major_cnt = cnt;
            if card == major_card then
                cnt = cnt + magic_cnt
            end
            if cnt == card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
                
                if card == major_card  then
                    if major_cnt ==1 then 
                        local card_pattern = {cards={card_name_info[card][1],CardCommon.MagicCard}
                            , type = obj_type
                            , repeat_cnt=1
                            , card_cnt = pattern.card_cnt
                            , value = CardCommon.Name2Value(card,0) }
                        table.insert(hintList, CardPattern.Encap(card_pattern))
                    elseif  major_cnt >= 2 then
                        local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2]}
                            , type = obj_type
                            , repeat_cnt=1
                            , card_cnt = pattern.card_cnt
                            , value = CardCommon.Name2Value(card,0) }
                        table.insert(hintList, CardPattern.Encap(card_pattern))
                    elseif major_cnt == 0 then
                        local card_pattern = {cards={CardCommon.MagicCard,CardCommon.MagicCard}
                            , type = obj_type
                            , repeat_cnt=1
                            , card_cnt = pattern.card_cnt
                            , value = CardCommon.MagicValue }
                        table.insert(hintList, CardPattern.Encap(card_pattern))
                    end
                else 
                    local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2]}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end 
            end
        end
        card_cnt = card_cnt + 1;
        if (pattern.value == 0) then
            break;
        end
    end
    if magic_cnt and magic_cnt > 0 and #hintList == 0 then 
        if magic_cnt == 1 and #hintList == 0 and pattern.value ~= 0 then 
            for _,card in ipairs(CardCommon.SortedCardName) do
                cnt = #card_name_info[card]
                if cnt == 1 and CardCommon.Name2Value(card,0) > pattern.value and CardCommon.IsNormalCard(card,CardCommon.card_unknown) then
                    local card_pattern = {cards={card_name_info[card][1],CardCommon.MagicCard}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end
            end
        end
    end
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end
    
    return hintList;
end
CardSet.enum[CardCommon.type_triple2] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt,calc_bomb_pattern)
    
    local hintList = {}
    local obj_type = CardCommon.type_triple2
    if not pattern then 
        pattern = {type = obj_type, card_cnt=6, repeat_cnt=3, value = 0}
    end
    
    local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,2,pattern.repeat_cnt);
    CardPattern.UniqueCombine(hintList, CardPattern.NewPatternList(repeat_info, pattern))
    if magic_cnt and magic_cnt > 0 then
        local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,2,pattern.repeat_cnt,magic_cnt);
        CardPattern.UniqueCombine(hintList, CardPattern.NewPatternList(repeat_info, pattern))
    end
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end
    --����ը��
    return hintList;
end
CardSet.enum[CardCommon.type_three] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt, calc_bomb_pattern)
    local obj_type = CardCommon.type_three
    local hintList = {}
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 3, repeat_cnt=1, value = 0}
    end
    local major_card = CardCommon.ResolveCardIdx(CardCommon.MagicCard).name;
    local major_cnt = card_name_stat[major_card];
    local function GetPatternList(pattern, card3s_list)
        local pattern_set = {}

        for _,card3s in ipairs(card3s_list) do
            local _card2s = nil;
            if CardCommon.NameIdx2Value(card3s[1],0) > pattern.value then 
                local card_pattern = {cards={card3s[1],card3s[2],card3s[3]}
                    , type = pattern.type
                    , repeat_cnt=1
                    , card_cnt = pattern.card_cnt
                    , value = CardCommon.NameIdx2Value(card3s[1],0) }
                table.insert(pattern_set, CardPattern.Encap(card_pattern))
            end
        end
        return pattern_set
    end
    local card3_list = {{},{},{}}
    for _,card in ipairs(CardCommon.SortedCardName) do
        local card_cnt = #card_name_info[card];
        if card ~= major_card and card_cnt == 3 then
            table.insert(card3_list[1], {card_name_info[card][1],card_name_info[card][2],card_name_info[card][3]})
        end
    end 
    if magic_cnt > 0 then 
        for _,card in ipairs(CardCommon.SortedCardName) do
            local card_cnt = #card_name_info[card];
            if card ~= major_card and card_cnt == 2 and CardCommon.IsNormalCard(card,CardCommon.card_unknown) then
                table.insert(card3_list[2], {card_name_info[card][1],card_name_info[card][2],CardCommon.MagicCard})
            end
        end 
        
    end
    if magic_cnt == 2 then 
        for _,card in ipairs(CardCommon.SortedCardName) do
            local card_cnt = #card_name_info[card];
            if card ~= major_card and card_cnt == 1 and CardCommon.IsNormalCard(card,CardCommon.card_unknown) then
                table.insert(card3_list[3], {card_name_info[card][1],CardCommon.MagicCard,CardCommon.MagicCard})
            end
        end 
    end
    
    if magic_cnt+major_cnt == 3 then
        if magic_cnt == 0 then
            table.insert(card3_list[1], {card_name_info[major_card][1],card_name_info[major_card][2],card_name_info[major_card][3]})
        elseif magic_cnt == 1 then
            table.insert(card3_list[2], {card_name_info[major_card][1],card_name_info[major_card][2],CardCommon.MagicCard})
        elseif magic_cnt == 2 then
            table.insert(card3_list[3], {card_name_info[major_card][1],CardCommon.MagicCard,CardCommon.MagicCard})
        end
    end
    CardPattern.UniqueCombine(hintList,GetPatternList(pattern, card3_list[1]));
    CardPattern.UniqueCombine(hintList,GetPatternList(pattern, card3_list[2]));
    CardPattern.UniqueCombine(hintList,GetPatternList(pattern, card3_list[3]));
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end
    return hintList;
end
CardSet.enum[CardCommon.type_three_p2] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt,calc_bomb_pattern)
    local obj_type = CardCommon.type_three_p2
    local hintList = {}
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 5, repeat_cnt=1, value = 0}
    end
    local major_card = CardCommon.ResolveCardIdx(CardCommon.MagicCard).name;
    local major_cnt = card_name_stat[major_card];
    local function GetPatternList(pattern, card3s_list, used_magic_cnt, rest_magic_cnt, card2_list_all)
        local pattern_set = {}

        for _,card3s in ipairs(card3s_list) do
            local _card2s = nil;
            if CardCommon.NameIdx2Value(card3s[1],0) > pattern.value then 
                for _,card2s in ipairs(card2_list_all[1]) do
                    if CardCommon.ResolveCardIdx(card2s[1]).name ~= CardCommon.ResolveCardIdx(card3s[1]).name then
                        _card2s = card2s;
                        break;
                    end
                end
                if (_card2s == nil) then  
                    if  used_magic_cnt == 1 and rest_magic_cnt == 1 then
                        for _,card2s in ipairs(card2_list_all[2]) do
                            if CardCommon.ResolveCardIdx(card2s[1]).name ~= CardCommon.ResolveCardIdx(card3s[1]).name then
                                _card2s = card2s;
                                break;
                            end
                        end
                    elseif  used_magic_cnt == 0 and rest_magic_cnt > 0 then
                        for _,card2s in ipairs(card2_list_all[2]) do
                            if CardCommon.ResolveCardIdx(card2s[1]).name ~= CardCommon.ResolveCardIdx(card3s[1]).name then
                                _card2s = card2s;
                                break;
                            end
                
                        end
                        if _card2s == nil and rest_magic_cnt == 2 then 
                            for _,card2s in ipairs(card2_list_all[3]) do
                                if CardCommon.ResolveCardIdx(card2s[1]).name ~= CardCommon.ResolveCardIdx(card3s[1]).name then
                                    _card2s = card2s;
                                    break;
                                end
                
                            end
                        end
                    end
                end
                if (_card2s ~= nil) then
                    local card_pattern = {cards={card3s[1],card3s[2],card3s[3],_card2s[1],_card2s[2]}
                        , type = CardCommon.type_three_p2
                        , repeat_cnt=1
                        , card_cnt = 5
                        , value = CardCommon.NameIdx2Value(card3s[1],0) }
                    table.insert(pattern_set, CardPattern.Encap(card_pattern))
                end
            end
        end
        return pattern_set
    end
    local cnt = 2;
    local card2_list = {{},{},{}};
    local card3_list = {{},{},{}}
    while cnt < 4 do
        for _,card in ipairs(CardCommon.SortedCardName) do
            local card_cnt = #card_name_info[card];
            if card ~= major_card and card_cnt == cnt then
                table.insert(card2_list[1], {card_name_info[card][1],card_name_info[card][2]})
            end
        end 
        cnt = cnt + 1
    end
    for _,card in ipairs(CardCommon.SortedCardName) do
        local card_cnt = #card_name_info[card];
        if card ~= major_card and card_cnt == 3 then
            table.insert(card3_list[1], {card_name_info[card][1],card_name_info[card][2],card_name_info[card][3]})
        end
    end 
    if magic_cnt > 0 then 
        for _,card in ipairs(CardCommon.SortedCardName) do
            local card_cnt = #card_name_info[card];
            if card ~= major_card and card_cnt == 2  and CardCommon.IsNormalCard(card,CardCommon.card_unknown) then
                table.insert(card3_list[2], {card_name_info[card][1],card_name_info[card][2],CardCommon.MagicCard})
            end
        end 
        
        for _,card in ipairs(CardCommon.SortedCardName) do
            local card_cnt = #card_name_info[card];
            if card ~= major_card and card_cnt == 1  and CardCommon.IsNormalCard(card,CardCommon.card_unknown) then
                table.insert(card2_list[2], {card_name_info[card][1],CardCommon.MagicCard})
            end
        end 
    end
    if magic_cnt == 2 then 
        for _,card in ipairs(CardCommon.SortedCardName) do
            local card_cnt = #card_name_info[card];
            if card ~= major_card and card_cnt == 1  and CardCommon.IsNormalCard(card,CardCommon.card_unknown)  then
                table.insert(card3_list[3], {card_name_info[card][1],CardCommon.MagicCard,CardCommon.MagicCard})
            end
        end 
        table.insert(card2_list[3], {CardCommon.MagicCard,CardCommon.MagicCard})
    end
    
    if magic_cnt+major_cnt == 3 then
        if magic_cnt == 0 then
            table.insert(card3_list[1], {card_name_info[major_card][1],card_name_info[major_card][2],card_name_info[major_card][3]})
        elseif magic_cnt == 1 then
            table.insert(card3_list[2], {card_name_info[major_card][1],card_name_info[major_card][2],CardCommon.MagicCard})
        elseif magic_cnt == 2 then
            table.insert(card3_list[3], {card_name_info[major_card][1],CardCommon.MagicCard,CardCommon.MagicCard})
        end
    end
    if magic_cnt+major_cnt == 2 then
        if magic_cnt == 0 then
            table.insert(card2_list[1], {card_name_info[major_card][1],card_name_info[major_card][2]})
        elseif magic_cnt == 1 then
            table.insert(card2_list[2], {card_name_info[major_card][1],CardCommon.MagicCard})
        elseif magic_cnt ==2 then
            table.insert(card2_list[3], {CardCommon.MagicCard,CardCommon.MagicCard})
        end
    end
    CardPattern.UniqueCombine(hintList,GetPatternList(pattern, card3_list[1], 0, magic_cnt, card2_list));
    if magic_cnt > 0 then 
        CardPattern.UniqueCombine(hintList,GetPatternList(pattern, card3_list[2], 1, magic_cnt-1, card2_list));
        if magic_cnt == 2 then 
            CardPattern.UniqueCombine(hintList,GetPatternList(pattern, card3_list[3], 2, 0, card2_list));
        end
    end
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end
    
    return hintList;
end
CardSet.enum[CardCommon.type_double3] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt,calc_bomb_pattern)
    
    local hintList = {}
    local obj_type = CardCommon.type_double3
    if not pattern then 
        pattern = {type = obj_type, card_cnt=6, repeat_cnt=2, value = 0}
    end
    local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,3,pattern.repeat_cnt);
    CardPattern.UniqueCombine(hintList, CardPattern.NewPatternList(repeat_info, pattern))
    
    if magic_cnt and magic_cnt > 0 then
        local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,3,pattern.repeat_cnt,magic_cnt);
        CardPattern.UniqueCombine(hintList, CardPattern.NewPatternList(repeat_info, pattern))
    end
    if calc_bomb_pattern then
        CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four](nil,card_type_stat, card_name_info,card_name_stat,magic_cnt));
    end
    --����ը��
    return hintList;

end
CardSet.enum[CardCommon.type_four] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    local obj_type = CardCommon.type_four
    if not pattern then 
        pattern = {type = obj_type, card_cnt=4, repeat_cnt=1, value = 0}
    end

    for _,card in ipairs(CardCommon.SortedCardName) do
        cnt = #card_name_info[card]
        if cnt == pattern.card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
            local card_pattern = {cards=card_name_info[card]
                , type = obj_type
                , repeat_cnt=1
                , card_cnt = pattern.card_cnt
                , value = CardCommon.Name2Value(card,0) }
            table.insert(hintList, CardPattern.Encap(card_pattern))
        end
    end
    
    if #hintList == 0 and magic_cnt and  magic_cnt > 0 then
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            if (cnt == pattern.card_cnt - 1)   and CardCommon.Name2Value(card,0) > pattern.value  then
                local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],CardCommon.MagicCard}
                    , type = obj_type
                    , repeat_cnt=1
                    , card_cnt = pattern.card_cnt
                    , value = CardCommon.Name2Value(card,0) }
                table.insert(hintList, CardPattern.Encap(card_pattern))
            end
        end
        if magic_cnt > 1 then
            for _,card in ipairs(CardCommon.SortedCardName) do
                cnt = #card_name_info[card]
                if (cnt == pattern.card_cnt - 2)   
                    and CardCommon.Name2Value(card,0) > pattern.value  
                    and CardCommon.IsNormalCard(card, CardCommon.card_unknown)
                then
                    local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],CardCommon.MagicCard,CardCommon.MagicCard}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end
            end
        end
    end
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_five](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    return hintList;
end
CardSet.enum[CardCommon.type_five] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    local obj_type = CardCommon.type_five
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 5, repeat_cnt=1, value = 0}
    end
    
    for _,card in ipairs(CardCommon.SortedCardName) do
        cnt = #card_name_info[card]
        if cnt == pattern.card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
            local card_pattern = {cards=card_name_info[card]
                , type = obj_type
                , repeat_cnt=1
                , card_cnt = pattern.card_cnt
                , value = CardCommon.Name2Value(card,0) }
            table.insert(hintList, CardPattern.Encap(card_pattern))
        end
    end
    
    if #hintList == 0 and  magic_cnt and  magic_cnt > 0 then
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            if (cnt == pattern.card_cnt - 1)  and CardCommon.Name2Value(card,0) > pattern.value then
                local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],CardCommon.MagicCard}
                    , type = obj_type
                    , repeat_cnt=1
                    , card_cnt = pattern.card_cnt
                    , value = CardCommon.Name2Value(card,0) }
                table.insert(hintList, CardPattern.Encap(card_pattern))
            end
        end
        if magic_cnt > 1 then
            for _,card in ipairs(CardCommon.SortedCardName) do
                cnt = #card_name_info[card]
                if (cnt == pattern.card_cnt - 2)  and CardCommon.Name2Value(card,0) > pattern.value then
                    local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],CardCommon.MagicCard,CardCommon.MagicCard}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end
            end
        end
        
    end
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_five_same_color](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    return hintList;
end
CardSet.enum[CardCommon.type_five_same_color] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    --local __,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_single],card_name_stat)
    local hintList = {}
    if not pattern then 
        pattern = {type = CardCommon.type_five_same_color, repeat_cnt=1, value = 0}
    end
    local doGetPatternFromRepeatInfo = function (card_name_info,magic_cnt,pattern)
        local pattern_list = {}
        local loop_cnt = 1
        local color_cnt={0,0,0,0};
        if not magic_cnt  then
            magic_cnt = 0;
        end
        local list = {}
        local ca_mask = {0,0,0,0};
        for _,ca in ipairs(card_name_info[CardCommon.card_A]) do 
            local cardinfo = CardCommon.ResolveCardIdx(ca);
            ca_mask[cardinfo.color] = 1;
        end
        for color=1,4 do 
            local color_magic_pos=0;
            local begin_name = 0;
            while begin_name < CardCommon.max_normal_card_name  do 
                begin_name = begin_name + 1
                if begin_name > color_magic_pos then 
                    color_magic_pos = 0;
                    local color_magic_cnt=magic_cnt;

                    local same_color_info_list_tmp = {cards={},color=color,repeat_cnt=0,start_ix=0,end_ix=0,color_magic_cnt=0}
                    --get one info per whole loop
                    for ix=begin_name,CardCommon.max_normal_card_name do 
                        local last_card = CardCommon.card_unknown;
                        local quit_loop = false;
                        for _,card in ipairs(card_name_info[ix]) do
                            local cardinfo = CardCommon.ResolveCardIdx(card);
                            if (card ~= last_card) and cardinfo.color == color then 
                                if same_color_info_list_tmp.start_ix == 0 then
                                    same_color_info_list_tmp.start_ix = ix;
                                end
                                same_color_info_list_tmp.repeat_cnt = same_color_info_list_tmp.repeat_cnt+1
                                same_color_info_list_tmp.end_ix = ix;
                                last_card = card;
                                table.insert(same_color_info_list_tmp.cards,ix);
                            end
                        end
                        
                        if same_color_info_list_tmp.end_ix ~= ix  then
                            if color_magic_cnt <= 0 then 
                                if same_color_info_list_tmp.repeat_cnt >= 5 then
                                    table.insert(list,same_color_info_list_tmp);  
                                end
                                if magic_cnt == 0 then
                                    color_magic_pos = ix;
                                end
                                quit_loop =true;
                            else
                                if same_color_info_list_tmp.start_ix == 0 then
                                    same_color_info_list_tmp.start_ix = ix
                                    same_color_info_list_tmp.repeat_cnt = 0;
                                end
                                same_color_info_list_tmp.repeat_cnt = same_color_info_list_tmp.repeat_cnt+1
                               
                                same_color_info_list_tmp.end_ix = ix;
                            
                                table.insert(same_color_info_list_tmp.cards,CardCommon.magic_card);
                                if (color_magic_pos == 0) then
                                    color_magic_pos = ix;
                                end
                                color_magic_cnt = color_magic_cnt - 1;
                                same_color_info_list_tmp.color_magic_cnt = same_color_info_list_tmp.color_magic_cnt + 1
                            end

                        end
                        if same_color_info_list_tmp.end_ix == CardCommon.max_normal_card_name then
                            quit_loop =true;
                            if (ca_mask[same_color_info_list_tmp.color] == 1 or same_color_info_list_tmp.color_magic_cnt < magic_cnt) then 
                                same_color_info_list_tmp.end_ix = CardCommon.card_A;
                                if ca_mask[same_color_info_list_tmp.color] == 1 then 
                                    table.insert(same_color_info_list_tmp.cards,CardCommon.card_A); 
                                else
                                    table.insert(same_color_info_list_tmp.cards,CardCommon.magic_card); 
                                    if (color_magic_pos == 0) then
                                        color_magic_pos = ix;
                                    end
                                    color_magic_cnt = color_magic_cnt - 1;
                                    same_color_info_list_tmp.color_magic_cnt = same_color_info_list_tmp.color_magic_cnt + 1
                                end
                                same_color_info_list_tmp.repeat_cnt = same_color_info_list_tmp.repeat_cnt + 1;
                            end
                            
                            if same_color_info_list_tmp.repeat_cnt >= 5 then
                                table.insert(list,same_color_info_list_tmp);  
                            end
                        end
                        
                        if quit_loop then
                            break;
                        end
                    end
                end 
            
            end
        end    
        for _,info in ipairs(list) do
            
            --print(info.color, info.start_ix, info.end_ix, info.repeat_cnt, info.color_magic_cnt);
            local loop_cnt = 1;
            for index=5,info.repeat_cnt do
                local card_pattern = doGetCardsSameColor(info.cards, loop_cnt, card_name_info, info.color)
                if card_pattern then 
                    for _,pt in ipairs(card_pattern) do
                        if (pt.value > pattern.value) then
                            table.insert(pattern_list, pt)
                        end
                    end
                end 
                loop_cnt = loop_cnt + 1
            end
        end
        
        table.sort(pattern_list, function(a,b) 
            return a.value < b.value;
        end);
        return pattern_list;
    end

    CardPattern.UniqueCombine(hintList, doGetPatternFromRepeatInfo(card_name_info,0,pattern));
    if magic_cnt and  magic_cnt > 0 then
            --local magic_info = CardCommon.MagicRepeatInfo(repeat_info, 1, i, card_name_stat, magic_cnt)
        CardPattern.UniqueCombine(hintList, doGetPatternFromRepeatInfo(card_name_info,magic_cnt,pattern));
    end
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_six](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    --����ը��
    return hintList;
end
CardSet.enum[CardCommon.type_six] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    local obj_type = CardCommon.type_six
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 6, repeat_cnt=1, value = 0}
    end
    
    for _,card in ipairs(CardCommon.SortedCardName) do
        cnt = #card_name_info[card]
        if cnt == pattern.card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
            local card_pattern = {cards=card_name_info[card]
                , type = obj_type
                , repeat_cnt=1
                , card_cnt = pattern.card_cnt
                , value = CardCommon.Name2Value(card,0) }
            table.insert(hintList, CardPattern.Encap(card_pattern))
        end
    end
    if #hintList ==0 and magic_cnt and  magic_cnt > 0 then
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            if (cnt == pattern.card_cnt - 1) and CardCommon.Name2Value(card,0) > pattern.value then
                local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],card_name_info[card][5],CardCommon.MagicCard}
                    , type = obj_type
                    , repeat_cnt=1
                    , card_cnt = pattern.card_cnt
                    , value = CardCommon.Name2Value(card,0) }
                table.insert(hintList, CardPattern.Encap(card_pattern))
            end
        end
        if magic_cnt > 1 then
            for _,card in ipairs(CardCommon.SortedCardName) do
                cnt = #card_name_info[card]
                if (cnt == pattern.card_cnt - 2)  and CardCommon.Name2Value(card,0) > pattern.value then
                    local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],CardCommon.MagicCard,CardCommon.MagicCard}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end
            end
        end
        
    end
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_seven](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    return hintList;
end
CardSet.enum[CardCommon.type_seven] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    local obj_type = CardCommon.type_seven
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 7, repeat_cnt=1, value = 0}
    end
    for _,card in ipairs(CardCommon.SortedCardName) do
        cnt = #card_name_info[card]
        if cnt == pattern.card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
            local card_pattern = {cards=card_name_info[card]
                , type = obj_type
                , repeat_cnt=1
                , card_cnt = pattern.card_cnt
                , value = CardCommon.Name2Value(card,0) }
            table.insert(hintList, CardPattern.Encap(card_pattern))
        end
    end
    if #hintList ==0 and  magic_cnt and  magic_cnt > 0 then
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            if (cnt == pattern.card_cnt - 1)  and CardCommon.Name2Value(card,0) > pattern.value then
                local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],card_name_info[card][5],card_name_info[card][6],CardCommon.MagicCard}
                    , type = obj_type
                    , repeat_cnt=1
                    , card_cnt = pattern.card_cnt
                    , value = CardCommon.Name2Value(card,0) }
                table.insert(hintList, CardPattern.Encap(card_pattern))
            end
        end
        if magic_cnt > 1 then
            for _,card in ipairs(CardCommon.SortedCardName) do
                cnt = #card_name_info[card]
                if (cnt == pattern.card_cnt - 2)  and CardCommon.Name2Value(card,0) > pattern.value then
                    local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],card_name_info[card][5],CardCommon.MagicCard,CardCommon.MagicCard}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end
            end
        end
    end
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_eight](nil, card_type_stat,card_name_info, card_name_stat, magic_cnt))
    return hintList;
end
CardSet.enum[CardCommon.type_eight] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    local obj_type = CardCommon.type_eight
    if not pattern then 
        pattern = {type = obj_type, card_cnt = 8, repeat_cnt=1, value = 0}
    end
    
    for _,card in ipairs(CardCommon.SortedCardName) do
        cnt = #card_name_info[card]
        if cnt == pattern.card_cnt and CardCommon.Name2Value(card,0) > pattern.value then
            local card_pattern = {cards=card_name_info[card]
                , type = obj_type
                , repeat_cnt=1
                , card_cnt = pattern.card_cnt
                , value = CardCommon.Name2Value(card,0) }
            table.insert(hintList, CardPattern.Encap(card_pattern))
        end
    end
    if #hintList == 0 and magic_cnt and magic_cnt > 0 then
        for _,card in ipairs(CardCommon.SortedCardName) do
            cnt = #card_name_info[card]
            if (cnt == pattern.card_cnt - 1)  and CardCommon.Name2Value(card,0) > pattern.value then
                local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],card_name_info[card][5],card_name_info[card][6],card_name_info[card][7],CardCommon.MagicCard}
                    , type = obj_type
                    , repeat_cnt=1
                    , card_cnt = pattern.card_cnt
                    , value = CardCommon.Name2Value(card,0) }
                table.insert(hintList, CardPattern.Encap(card_pattern))
            end
        end
        if magic_cnt > 1 then
            for _,card in ipairs(CardCommon.SortedCardName) do
                cnt = #card_name_info[card]
                if (cnt == pattern.card_cnt - 2)  and CardCommon.Name2Value(card,0) > pattern.value then
                    local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2],card_name_info[card][3],card_name_info[card][4],card_name_info[card][5],card_name_info[card][6],CardCommon.MagicCard,CardCommon.MagicCard}
                        , type = obj_type
                        , repeat_cnt=1
                        , card_cnt = pattern.card_cnt
                        , value = CardCommon.Name2Value(card,0) }
                    table.insert(hintList, CardPattern.Encap(card_pattern))
                end
            end
        end
    end
    CardPattern.UniqueCombine(hintList, CardSet.enum[CardCommon.type_four_king](nil, card_type_stat,card_name_info, card_name_stat))
    return hintList;
end
CardSet.enum[CardCommon.type_four_king] = function(pattern, card_type_stat,card_name_info, card_name_stat, magic_cnt)
    local hintList = {}
    if card_name_stat[CardCommon.card_small_king] == 2 and card_name_stat[CardCommon.card_big_king] == 2 then
        local card_pattern = {cards={card_name_info[CardCommon.card_big_king][1]
                                    ,card_name_info[CardCommon.card_big_king][2] 
                                    ,card_name_info[CardCommon.card_small_king][1]
                                    ,card_name_info[CardCommon.card_small_king][2]}
            , type = CardCommon.type_four_king
            , repeat_cnt=1
            , card_cnt = 4
            , value = CardCommon.Name2Value(CardCommon.card_big_king,0) }
        table.insert(hintList, CardPattern.Encap(card_pattern))
    end
    return hintList;
end

-- ������ʾ ��ȡ������ʾ�����ͼ��ϵ����� essential_card = ����һ���׷�����ָ��Ϊ����3������ʱ����ΪNIL
function CardSet:hintIterator(pattern,type)

	local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,true,CardCommon.type_five_same_color)
    local cnt = {};
    local pos = {};
    local used_magic_cnt = {};
    for i=1,CardCommon.type_max do
        table.insert(cnt, 0);
    end
    local pattern_set = {};
    if pattern == nil then 
        pattern_set_full = CardSet.enum_full(pattern, card_type_stat,card_name_info, card_name_stat, card_name_stat[CardCommon.magic_card]);
        for _,pt in ipairs(pattern_set_full) do
            cnt[pt.type] = cnt[pt.type] + 1;
            if type then
                if pt.type == type then 
                    table.insert(pattern_set, pt);
                end
            else
                local logic_cnt = 0;
                if pt.logic_cards then
                    for _,card in ipairs(pt.logic_cards) do
                        if card ~= 0 then
                            logic_cnt = logic_cnt + 1
                        end
                    end
                end
                if (cnt[pt.type] == 1) then 
                    table.insert(pattern_set, pt);
                    pos[pt.type] = #pattern_set;
                    used_magic_cnt[pt.type] = logic_cnt
                else
                    if logic_cnt < used_magic_cnt[pt.type] then
                        pattern_set[pos[pt.type]] = pt;
                        used_magic_cnt[pt.type] = logic_cnt
                    end
                end 
            end
        end
    else
        if pattern.type > CardCommon.type_max then
            return nil;
        end
        pattern_set = CardSet.enum[pattern.type](pattern, card_type_stat,card_name_info, card_name_stat, card_name_stat[CardCommon.magic_card],true);
    end
	local index = 0
    if not pattern_set or #pattern_set == 0 then
        return nil;
    end
    if not type then 
        local sort_type = {
            CardCommon.type_single,
            CardCommon.type_double,
            CardCommon.type_three,
            CardCommon.type_three_p2,
            CardCommon.type_triple2,
            CardCommon.type_double3,
            CardCommon.type_single_5,
            CardCommon.type_four,
            CardCommon.type_five,
            CardCommon.type_five_same_color,
            CardCommon.type_six,
            CardCommon.type_seven,
            CardCommon.type_eight,
            CardCommon.type_four_king}

        local new_pattern_set = {};
        for ix, selected_type in ipairs(sort_type) do
            for ix,pt in ipairs(pattern_set) do
                if pt.type == selected_type then
                    table.insert(new_pattern_set, pt);
                end
            end
        end
        pattern_set = new_pattern_set;    
    end
	return function ()
		index = index  % (#pattern_set) + 1
		return pattern_set[index]
	end, (#pattern_set)
end

local doAddOneCard=function(result, name, color, cards_removed)
	local card_idx = 0
	local remove_flag = false;
	card_idx = CardCommon.FormatCardIndex(name, color)
	for _,c in ipairs(cards_removed) do
		if (c == card_idx) then
			remove_flag = true
			break
		end
	end
	if not remove_flag then
		table.insert(result, card_idx)
	end
end
--ϴ�ƺ���
function CardSet.shuffle(cards_removed,randomseed)
	math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local max_card_name = CardCommon.card_big_king;
	local card_names=CardCommon.GenerateRandomSequence(max_card_name);
	local colors={CardCommon.color_black_heart,CardCommon.color_red_heart,CardCommon.color_plum,CardCommon.color_square};
	local cards={}
	
	for idx=1,max_card_name do
        local max_color = 4;
        if (card_names[idx] > CardCommon.max_normal_card_name) then
            max_color = 1;
        end
		local color_idx = CardCommon.GenerateRandomSequence(max_color)
		for i=1,max_color do
			doAddOneCard(cards, card_names[idx], colors[color_idx[i]], cards_removed)
		end
	end
    card_names=CardCommon.GenerateRandomSequence(max_card_name)
	for idx=1,max_card_name do
        local max_color = 4;
        if (card_names[idx] > CardCommon.max_normal_card_name) then
            max_color = 1;
        end
		local color_idx = CardCommon.GenerateRandomSequence(max_color)
		for i=1,max_color do
			doAddOneCard(cards, card_names[idx], colors[color_idx[i]], cards_removed)
		end
	end
	--doAddOneCard(cards, CardName.card_small_king, CardColor.color_black_heart, cards_removed)
	--doAddOneCard(cards, CardName.card_big_king, CardColor.color_black_heart, cards_removed)
	local cards_return_idx = CardCommon.GenerateRandomSequence(#cards);
	local cards_return={}
	for _,v in ipairs(cards_return_idx) do
		table.insert(cards_return, cards[v])
	end
	return cards_return
end
--����
function CardSet:count(card)
    local cnt = 0;
    for _,c in ipairs(self.cards) do
	    if (c == card) then
		    cnt = cnt + 1
	    end
    end
    return cnt;
end

function CardSet.deal(cards)
	assert(cards)
	local max_cnt = #cards
	local offset = 1
	assert(max_cnt % 4 == 0)
	local player_cards={{},{},{}, {}}
	while (offset < max_cnt) do
		table.insert(player_cards[1], cards[offset+0])
		table.insert(player_cards[2], cards[offset+1])
		table.insert(player_cards[3], cards[offset+2])
		table.insert(player_cards[4], cards[offset+3])
		offset= offset + 4
	end
--    table.insert(player_cards[1], CardCommon.FormatCardIndex(CardCommon.card_small_king, 1))
--	table.insert(player_cards[1], CardCommon.FormatCardIndex(CardCommon.card_big_king, 1))
--	table.insert(player_cards[1], CardCommon.FormatCardIndex(CardCommon.card_K, 2))
--	table.insert(player_cards[2], CardCommon.FormatCardIndex(CardCommon.card_small_king, 1))
--	table.insert(player_cards[2], CardCommon.FormatCardIndex(CardCommon.card_big_king, 1))
--	table.insert(player_cards[2], CardCommon.FormatCardIndex(CardCommon.card_K, 2))
--	table.insert(player_cards[3], CardCommon.FormatCardIndex(CardCommon.card_K, 1))
--	table.insert(player_cards[3], CardCommon.FormatCardIndex(CardCommon.card_K, 1))
--	table.insert(player_cards[3], CardCommon.FormatCardIndex(CardCommon.card_K, 4))
--	table.insert(player_cards[4], CardCommon.FormatCardIndex(CardCommon.card_K, 3))
--	table.insert(player_cards[4], CardCommon.FormatCardIndex(CardCommon.card_K, 3))
--	table.insert(player_cards[4], CardCommon.FormatCardIndex(CardCommon.card_K, 4))
	return {CardSet.new(player_cards[1])
		  ,CardSet.new(player_cards[2])
		  ,CardSet.new(player_cards[3])
		  ,CardSet.new(player_cards[4])}
end

-- ����
function CardSet:discard(card_pattern_object)
    local cards = {};
    cards = CardCommon.Combine(cards, self.cards);
	local cnt = #(cards)
	for _,c in pairs(card_pattern_object.cards) do
		for idx,card in ipairs(cards) do
			if (c == card) then
				table.remove(cards,idx)
				break
			end
		end
	end
	local new_cnt = #cards;
    if new_cnt == cnt - card_pattern_object.card_cnt then
        self.card_cnt = new_cnt;
        self.cards = cards;
        return new_cnt, true;
    else
        return cnt, false;
    end;
end			
	
function CardSet:remove(cards) 

	for _,c in ipairs(cards) do
		for idx,card in ipairs(self.cards) do
			if (c == card) then
				table.remove(self.cards,idx)
				break
			end
		end
	end
    self.card_cnt = #(self.cards)
    
end

function CardSet:add(cards)
    for _,c in ipairs(cards) do
		table.insert(self.cards, c);
	end
    self.card_cnt = #(self.cards)
end

function CardSet:max_val_card()
    local max = 0;
    for _,c in ipairs(self.cards) do
        if (max == 0 or CardCommon.NameIdx2Value(c,0) > CardCommon.NameIdx2Value(max,0)) and (not CardCommon.IsMagic(c)) then
            max = c
        end
    end
    return max;
end
return CardSet						
						
						