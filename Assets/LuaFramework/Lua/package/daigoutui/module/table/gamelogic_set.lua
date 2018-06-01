local BranchPackageName = 'daigoutui'
local CardPattern = require(string.format("package/%s/module/table/gamelogic_pattern",BranchPackageName))
local CardCommon = require(string.format("package/%s/module/table/gamelogic_common",BranchPackageName))

--local CardPattern = require "gamelogic_pattern"
--local CardCommon = require "gamelogic_common"
--local Utils = require "utils"
-- 牌集类
local CardSet={}
CardSet.card_cnt = 0
CardSet.cards={}

-- 返回新的牌集对象 return instance of CardSet
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
    CardCommon.SortAsc(o.cards)
	return o
end
function CardSet:hintNormal(pattern, servant_card, is_lord_player)
    local pattern_list = {};
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,false, servant_card, is_lord_player)
    if pattern.type >= 4 then 
        return nil;
    end
    local is_not_pure = false;
    if #card_type_stat[pattern.type] == 0  then 
        if pattern.value == 0 then
            return nil;
        end
        is_not_pure = true
        card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,true, servant_card, is_lord_player)
    elseif pattern.value ~= 0 then 
        local find = false;
        for j=1,#card_type_stat[pattern.type] do
            if CardCommon.Name2Value(card_type_stat[pattern.type][j]) > pattern.value then
                find = true;
                break;
            end
        end
        if not find then
            card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,true, servant_card, is_lord_player)
            is_not_pure = true;
        end 
    end
    for j=1,#card_type_stat[pattern.type] do
        local pt = CardPattern.NewPattern(CardCommon.Combine({}, card_name_info[card_type_stat[pattern.type][j]], pattern.type));
        if (pt and pt.type ~= CardCommon.type_bomb and pt.value > pattern.value) then 
            if is_not_pure then
                pt.is_not_pure = true
            end
            table.insert(pattern_list, pt);
        end;
        if pattern.value == 0 and #pattern_list ~= 0 then
            break
        end
    end
    return pattern_list;
end
function CardSet:GetSequencePattern(info, begin_ix, end_ix, multiplicity, card_name_info, addition_cards)
    local cards = {}
    for i=begin_ix,end_ix do
        CardCommon.Combine(cards, card_name_info[info.cards[i]], multiplicity);
    end
    if addition_cards then
        CardCommon.Combine(cards, addition_cards);
    end
    return CardPattern.NewPattern(cards);
end
function CardSet:GetSequenceCards(info, begin_ix, end_ix, multiplicity, card_name_info)
    local cards = {}
    for i=begin_ix,end_ix do
        CardCommon.Combine(cards, card_name_info[info.cards[i]], multiplicity);
    end
    return cards;
end
function CardSet:GetRepeatPattern(pattern, repeat_list, multiplicity, card_name_info, addition_cards) 
    local pattern_list = {};
    for _,info in ipairs(repeat_list) do
        if info.repeat_cnt >= pattern.repeat_cnt and info.value > pattern.value then
            local begin_ix = 1
            for end_ix=pattern.repeat_cnt,info.repeat_cnt do 
                local end_card_value = CardCommon.Name2Value(info.cards[end_ix]);
                if end_card_value > pattern.value then 
                    local pt = self:GetSequencePattern(info, begin_ix, end_ix, multiplicity, card_name_info, addition_cards)
                    if pt then 
                        table.insert(pattern_list, pt);
                    end
                end
                begin_ix = begin_ix + 1
            end
        end
    end
    return pattern_list;
end

function CardSet:hintSequenceSingle(pattern, servant_card, is_lord_player)
    --TODO 单连顺牌型提示
    local pattern_list = {};
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards, false, servant_card, is_lord_player)
    local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_single],card_name_stat)
    if max_repeat.repeat_cnt >= pattern.repeat_cnt then
        CardCommon.Combine(pattern_list, self:GetRepeatPattern(pattern, repeat_list, 1, card_name_info));
    end 
    if #pattern_list == 0  and pattern.value ~= 0 then
        card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,true, servant_card, is_lord_player)
        max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_single],card_name_stat)
        if max_repeat.repeat_cnt < pattern.repeat_cnt then
            return nil;
        end
        local pattern_list_temp = self:GetRepeatPattern(pattern, repeat_list, 1, card_name_info);
        CardCommon.Combine(pattern_list, pattern_list_temp);
        for _,pt in ipairs(pattern_list_temp) do
            pt.is_not_pure = true;
        end
    end
    return pattern_list
end

function CardSet:hintSequenceDouble(pattern, servant_card, is_lord_player)
    local pattern_list = {};
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,false, servant_card, is_lord_player)
    local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_double],card_name_stat)
    if max_repeat.repeat_cnt >= pattern.repeat_cnt  then
        CardCommon.Combine(pattern_list, self:GetRepeatPattern(pattern, repeat_list, 2, card_name_info));
    end 
    if #pattern_list == 0 and pattern.value ~= 0 then
        card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,true, servant_card, is_lord_player)
        max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_double],card_name_stat)
        if max_repeat.repeat_cnt < pattern.repeat_cnt  then
            return nil;
        end
        local pattern_list_temp = self:GetRepeatPattern(pattern, repeat_list, 2, card_name_info);
        CardCommon.Combine(pattern_list, pattern_list_temp);
        for _,pt in ipairs(pattern_list_temp) do
            pt.is_not_pure = true;
        end
    end
    return pattern_list
end

function CardSet:hintSequenceTriple(pattern, servant_card, is_lord_player)
    local pattern_list = {};
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,false, servant_card, is_lord_player)
    local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_triple],card_name_stat)
    if max_repeat.repeat_cnt >= pattern.repeat_cnt then
        CardCommon.Combine(pattern_list, self:GetRepeatPattern(pattern, repeat_list, 3, card_name_info));
    end
    return pattern_list
end


function CardSet:getDoubleCards(type2_stat, card_name_stat, card_name_info, repeat_cnt, filter)
	local card_type_stat = CardCommon.Combine({}, type2_stat)
	local cards2
	if filter and #filter > 0 then 
		for _, card in ipairs(filter) do
			local card_name = CardCommon.ResolveCardIdx(card).name
			for i=1,#card_type_stat do
				if card_type_stat[i] == card_name then
					table.remove(card_type_stat, i)
				end 
			end 
		end
	end 
	if #card_type_stat < repeat_cnt then
		return nil;
	end 
	if repeat_cnt == 2 then
		local max_repeat2, repeat_list2 = CardCommon.StatRepeatCnt (card_type_stat,card_name_stat)
		if max_repeat2.repeat_cnt < repeat_cnt then  
			return nil;
		end 
		local try_repeat_cnt = 2
        while try_repeat_cnt < 15 and (not cards2) do 
            for i=1,#repeat_list2 do 
                if repeat_list2[i].repeat_cnt == try_repeat_cnt then 
                    cards2 = self:GetSequenceCards(repeat_list2[i], 1, 2, 2, card_name_info)
                    break;
                end
            end
            try_repeat_cnt = try_repeat_cnt+ 1
        end 
	else
		cards2 = self:GetSequenceCards({cards=card_type_stat}, 1, repeat_cnt, 2, card_name_info)
	end 
	return cards2
end

function CardSet:hintSequenceTripleP2(pattern, servant_card, is_lord_player)
	local pattern_list = {};
	local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards, true, servant_card, is_lord_player)
	local max_repeat, repeat_list = CardCommon.StatRepeatCnt (card_type_stat[CardCommon.type_triple],card_name_stat)
    
	if max_repeat.repeat_cnt < pattern.repeat_cnt then 
        return nil;
    end
	
	local pattern_list_temp = self:GetRepeatPattern(pattern, repeat_list, multiplicity, card_name_info, cards2) 
    for _,pt in ipairs(pattern_list_temp) do
        pt.is_not_pure = true;
		local cards2 = self:getDoubleCards(card_type_stat[CardCommon.type_double]
			, card_name_stat
			, card_name_info
			, pattern.repeat_cnt
			, pt.cards);
		if cards2 then
			CardCommon.Combine(pt.cards, cards2)
			pt.type = CardCommon.type_sequence_triple_p2
			pt.card_cnt = pt.card_cnt + #cards2
			table.insert(pattern_list, pt);
		end 
    end
    return #pattern_list > 0 and pattern_list or nil;
end

function CardSet:hintTripleP2(pattern, servant_card, is_lord_player)
    local pattern_list = {};
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,false, servant_card, is_lord_player)
    if #card_type_stat[3] == 0 then 
        return nil;
    end
    if (#card_type_stat[3] == 1 or pattern.value == 0) and #card_type_stat[2] == 0 then 
        return nil;
    end 
    local begin3 = 1;
    if #card_type_stat[2] == 0 then 
        begin3 = 2;
    end
    for j=begin3,#card_type_stat[3] do
        local cards = CardCommon.Combine({}, card_name_info[card_type_stat[3][j]]);
        if (begin3 == 1) then 
            CardCommon.Combine(cards, card_name_info[card_type_stat[2][1]]);
        else
            CardCommon.Combine(cards, card_name_info[card_type_stat[3][1]], 2);
        end
        local pt = CardPattern.NewPattern(cards);
        if (pt and pt.type ~= CardCommon.type_bomb and pt.value > pattern.value) then 
            if (begin3 ~= 1) then
                pt.is_not_pure = true;
            end 
            table.insert(pattern_list, pt);
        end;
    end
    return pattern_list;
end

function CardSet:hintAllBomb(pattern, servant_card, is_lord_player) 
    if not pattern then 
        pattern = {value=0}
    end
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards, false, servant_card, is_lord_player)
    local pattern_list = {};
    local small_king_cnt =  card_name_stat[CardCommon.card_small_king];
    local big_king_cnt = card_name_stat[CardCommon.card_big_king];
    local king_cnt = big_king_cnt+small_king_cnt;


    if (king_cnt >= 4 ) then
        local pt = CardPattern.NewPattern(CardCommon.Combine(CardCommon.Combine({}, card_name_info[CardCommon.card_small_king]), card_name_info[CardCommon.card_big_king]));
        if (pt and pt.value > pattern.value) then
            table.insert(pattern_list, pt);
        end;
    elseif (small_king_cnt == 3) then
        local pt = CardPattern.NewPattern(card_name_info[CardCommon.card_small_king]);
        if (pt and pt.value > pattern.value) then
            table.insert(pattern_list, pt);
        end;
    elseif (big_king_cnt ==3) then
        local pt = CardPattern.NewPattern(card_name_info[CardCommon.card_big_king]);
        if (pt and pt.value > pattern.value) then
            table.insert(pattern_list, pt);
        end;
    end
    for i=4,#card_type_stat do
        if #card_type_stat[i] > 0 then
            for j=1,#card_type_stat[i] do
                local pt = CardPattern.NewPattern(card_name_info[card_type_stat[i][j]]);
                if (pt and pt.value > pattern.value) then
                    table.insert(pattern_list, pt);
                end;
            end
        end
    end
    local cardinfo = CardCommon.ResolveCardIdx(servant_card);
    if (servant_card and self:count(servant_card) == 1) and is_lord_player then
        local pt = CardPattern.NewPattern({servant_card}, servant_card, is_lord_player);
        if (pt) then
            table.insert(pattern_list, pt);
        end;
    end
    return pattern_list;
end
-- 出牌提示 获取出牌提示的牌型集合迭代器 
function CardSet:ResolveBond()
    local bond_list = {}
    local pattern_list = self:hintAllBomb(nil, 0, false)
    if not pattern_list or #pattern_list == 0 then 
        return bond_list;
    end
    for _,pattern in ipairs(pattern_list) do
        local pattern_bond = pattern.bond_list
        if pattern_bond and #pattern_bond ~= 0 then 
            CardCommon.Combine(bond_list, pattern_bond);
            if not self.bond_cnt then
                self.bond_cnt = 0
            end 
            self.bond_cnt = self.bond_cnt + 1
        end
    end
    return bond_list;
end

function CardSet:hintIterator(pattern, servant_card, is_lord_player, most_great_servant_card_1v4)
    self.servant_card = servant_card
    if (not most_great_servant_card_1v4) or (not is_lord_player) then 
        servant_card = 0;
    end 
    local pattern_set = {};
    local is_first_hand = not pattern
	if (not pattern) or pattern.type <= 3 then 
        if not pattern then
            pattern_set = CardCommon.Combine(pattern_set, self:hintNormal({type=1, value=0, repeat_cnt=1}, servant_card, is_lord_player))
            pattern_set = CardCommon.Combine(pattern_set, self:hintNormal({type=2, value=0, repeat_cnt=1}, servant_card, is_lord_player))
            pattern_set = CardCommon.Combine(pattern_set, self:hintNormal({type=3, value=0, repeat_cnt=1}, servant_card, is_lord_player))
        else
            pattern_set = self:hintNormal(pattern, servant_card, is_lord_player)
        end        
    end

    if CardCommon.enableSequentialSingle and (not pattern or pattern.type == CardCommon.type_sequence_single) then
        --单张顺子
        if not pattern then
            local try_repeat_cnt = 13;
            local temp_pattern_set = {}
            while try_repeat_cnt > 2 and #temp_pattern_set == 0 do
                CardCommon.Combine(temp_pattern_set, self:hintSequenceSingle({type = CardCommon.type_sequence_single, value = 0, repeat_cnt = try_repeat_cnt}, servant_card, is_lord_player))
                try_repeat_cnt = try_repeat_cnt - 1
            end
            pattern_set = CardCommon.Combine(pattern_set, temp_pattern_set);
        else
            pattern_set = self:hintSequenceSingle(pattern, servant_card, is_lord_player)
        end    
    end

    if (not pattern) or pattern.type == CardCommon.type_sequence_double  then
        if not pattern then
            local try_repeat_cnt = 13;
            local temp_pattern_set = {}
            while try_repeat_cnt > 2 and #temp_pattern_set == 0 do
                CardCommon.Combine(temp_pattern_set, self:hintSequenceDouble({type = CardCommon.type_sequence_double, value = 0, repeat_cnt = try_repeat_cnt}, servant_card, is_lord_player))
                try_repeat_cnt = try_repeat_cnt - 1
            end
            pattern_set = CardCommon.Combine(pattern_set, temp_pattern_set);
        else
            pattern_set = self:hintSequenceDouble(pattern, servant_card, is_lord_player)
        end
        
    end
    if (not pattern) or pattern.type == CardCommon.type_sequence_triple then
        if not pattern then
            local try_repeat_cnt = 12;
            local temp_pattern_set = {}
            while try_repeat_cnt > 1 and #temp_pattern_set == 0 do
                CardCommon.Combine(temp_pattern_set, self:hintSequenceTriple({type = CardCommon.type_sequence_triple, value = 0, repeat_cnt = try_repeat_cnt}, servant_card, is_lord_player))
                try_repeat_cnt = try_repeat_cnt - 1
            end
            pattern_set = CardCommon.Combine(pattern_set, temp_pattern_set);
        else
            pattern_set = self:hintSequenceTriple(pattern, servant_card, is_lord_player)
        end
    end
    if (not pattern) or pattern.type == CardCommon.type_triple_p2 then
        if not pattern then
            pattern_set = CardCommon.Combine(pattern_set,self:hintTripleP2({type = CardCommon.type_triple_p2, value = 0, repeat_cnt = try_repeat_cnt}, servant_card, is_lord_player))
        else
            pattern_set = self:hintTripleP2(pattern, servant_card, is_lord_player)
        end
    end
    if (not pattern) or pattern.type == CardCommon.type_sequence_triple_p2  then
        if not pattern then
            local try_repeat_cnt = 7;
            local temp_pattern_set = {}
            while try_repeat_cnt > 1 and #temp_pattern_set == 0 do
                CardCommon.Combine(temp_pattern_set, self:hintSequenceTripleP2({type = CardCommon.type_sequence_triple_p2, value = 0, repeat_cnt = try_repeat_cnt}, servant_card, is_lord_player))
                try_repeat_cnt = try_repeat_cnt - 1
            end
            pattern_set = CardCommon.Combine(pattern_set, temp_pattern_set);
        else
            pattern_set = self:hintSequenceTripleP2(pattern, servant_card, is_lord_player)
        end
    end 
    pattern_set = CardCommon.Combine(pattern_set, self:hintAllBomb(pattern, servant_card, is_lord_player));
    if not pattern_set or #pattern_set == 0 then 
        return nil, 0
    end 
    if is_first_hand then
        local temp_pattern_set = {}
        local last_pattern_type = 0
        for _,pattern in ipairs(pattern_set) do
            if pattern.type ~= last_pattern_type then
                table.insert(temp_pattern_set, pattern);
                last_pattern_type = pattern.type;
            end
        end
        pattern_set = temp_pattern_set
    else
        local temp_pattern_set = {}
        local last_pattern_type = 0
        table.sort(pattern_set, function(a,b) 
            return a.value < b.value;
        end );
        for _,pattern in ipairs(pattern_set) do
            if not pattern.is_not_pure then
                table.insert(temp_pattern_set, pattern);
                last_pattern_type = pattern.type;
            end
        end
        for _,pattern in ipairs(pattern_set) do
            if pattern.is_not_pure then
                table.insert(temp_pattern_set, pattern);
                last_pattern_type = pattern.type;
            end
        end
        pattern_set = temp_pattern_set
    end
    local index = 0
	return function ()
		index = index  % (#pattern_set) + 1
		return pattern_set[index]
	end, (#pattern_set)
end

local doAddOneCard=function(result, name, color, id, cards_removed)
	local card_idx = 0
	local remove_flag = false;
	card_idx = CardCommon.FormatCardIndex(name, color, id)
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
--洗牌函数
function CardSet.shuffle(cards_removed,randomseed)
    randomseed = tonumber(randomseed or 0)
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6))+randomseed*10)
    local max_card_name = CardCommon.card_big_king;
    local cards={}
    for id=1,3 do
        for name=1,max_card_name do
            local max_color = 4;
            if (name > CardCommon.max_normal_card_name) then
                max_color = 1;
            end
            for color=1,max_color do
                doAddOneCard(cards, name, color, id, cards_removed)
            end
        end
    end
    local cards_return_idx = CardCommon.GenerateRandomSequence(#cards);
    local cards_return={}
    for _,v in ipairs(cards_return_idx) do
        table.insert(cards_return, cards[v])
    end
    return cards_return
end
--发牌
function CardSet:count(card,ignore_id)
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
function CardSet:max_samecolor_doube()
    local card = 0;
    local SortedCardName ={
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

    for i=#SortedCardName, 1, -1 do
        for color=CardCommon.color_black_heart,CardCommon.color_square do
            local temp_card = CardCommon.FormatCardIndex(SortedCardName[i], color)
            if self:count(temp_card,true) == 2 then
                card = temp_card;
                break;
            end 
        end
        if card ~= 0 then
            break;
        end 
    end
    if card == 0 then 
        return nil
    end 
    local cardinfo = CardCommon.ResolveCardIdx(card)
    local servant_card = 0;
    for i=1,3 do 
        servant_card = CardCommon.FormatCardIndex(cardinfo.name, cardinfo.color, i);
        if self:count(servant_card) == 0 then 
            return servant_card
        end 
    end
end
function CardSet.deal(cards)
	assert(cards)
	local max_cnt = #cards
	local offset = 1
    assert(#cards == 162, "fatal error, no enough cards")
	local player_cards={{},{},{}, {}, {}, {}}
    for i=1,5 do
        for j=1,31 do
            table.insert(player_cards[i], cards[(i-1)*31+j])
        end
    end
    for j=1,7 do
        table.insert(player_cards[6], cards[5*31+j])
    end
	return {CardSet.new(player_cards[1])
		  ,CardSet.new(player_cards[2])
		  ,CardSet.new(player_cards[3])
		  ,CardSet.new(player_cards[4])
		  ,CardSet.new(player_cards[5])
          },player_cards[6]
end

-- 出牌
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
--1 表示 按牌值大小排序 2表示按牌型大小 
function CardSet:SortByPattern(sort_type, servant_card, is_lord_player, most_great_servant_card_1v4)
    if (not most_great_servant_card_1v4) or (not is_lord_player) then 
        servant_card = 0;
    end 
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards,false, servant_card, is_lord_player)
    local new_cards = {};
    if sort_type == 2 then
        local pattern_list = self:hintAllBomb(nil, servant_card, is_lord_player)
        table.sort(pattern_list, function (p1,p2) 
            return p1.value < p2.value;
        end)
        local has_king_bomb = false;
        for i=#pattern_list,1,-1 do
            if (not has_king_bomb) or (pattern_list[i].value % 100 ~= 50) then 
                CardCommon.Combine(new_cards, pattern_list[i].cards);
            end 
            if pattern_list[i].value % 100 == 50 then 
                has_king_bomb = true;
            end  
        end 
        for i=3,1,-1 do 
            for j=#card_type_stat[i],1,-1 do
                local card_name = card_type_stat[i][j]
                if not (card_name >= CardCommon.card_small_king and has_king_bomb) then 
                    CardCommon.Combine(new_cards, card_name_info[card_name]);
                end 
            end 
        end 
        local has_error = false;
        for _,card in ipairs(new_cards) do 
            if self:count(card) ~= 1 then 
                has_error = true;
                break;
            end 
        end 
        if (has_error) or (#new_cards ~= #self.cards) then
            new_cards = self.cards
        end 
    elseif sort_type == 1 then 
        
        if servant_card ~= 0 and self:count(servant_card) == 1 then 
            table.insert(new_cards, servant_card);
        end 
        for i=#CardCommon.SortedCardName,1,-1 do
            CardCommon.Combine(new_cards, card_name_info[CardCommon.SortedCardName[i]]);
        end    
    else 
        new_cards = self.cards
        
    end 
    
    self.cards = new_cards;
end 
return CardSet						
						
						