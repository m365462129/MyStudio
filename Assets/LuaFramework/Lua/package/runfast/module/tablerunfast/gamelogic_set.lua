local BranchPackageName = AppData.BranchRunfastName
local CardPattern = require(string.format("package/%s/module/tablerunfast/gamelogic_pattern",BranchPackageName))--require "gamelogic_pattern"
local CardCommon = require(string.format("package/%s/module/tablerunfast/gamelogic_common",BranchPackageName))
-- �Ƽ���
local CardSet={}

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
local doGetCards4=function(cards)
	return CardPattern.new(cards);
end

local doGetCardsNormal=function (cards,start_idx, end_idx, pattern, card_name_info)
	local obj_card={}
	for idx=start_idx,end_idx do
		local name= cards[idx]
		local cnt = #(card_name_info[name])
		if (pattern) then
			cnt = pattern.type
		end
		for i=1,cnt do
			table.insert(obj_card,card_name_info[name][i])
		end
	end
	
	return CardPattern.new(obj_card);
end

local doGetCards=function (cards,start_idx, end_idx, pattern, card_name_info,card_name_stat)
	if pattern.type == CardCommon.type_four then
		return doGetCards4( card_name_info[cards[start_idx]])
	elseif pattern.type ~= CardCommon.type_three then
		return doGetCardsNormal(cards, start_idx, end_idx, pattern, card_name_info)
	else
		return doGetCardsNormal(cards, start_idx, end_idx, pattern, card_name_info)
	end
end

local doGetHintList=function (pattern, repeat_info, max_repeat_info,card_name_info, card_name_stat,pattern_four_repeat_info)
	local hintList = {}
	
    local strong_triple = CardCommon.strong_triple
    local strong_double = CardCommon.strong_double;
    if repeat_info 
		and max_repeat_info 
		and max_repeat_info.repeat_cnt >= pattern.repeat_cnt 
		and max_repeat_info.total_cards_cnt >= pattern.card_cnt
	then
		if pattern.repeat_cnt == 1 and (pattern.type == CardCommon.type_double or pattern.type == CardCommon.type_single) then
			local begin_type = pattern.type
			while begin_type < CardCommon.type_four do
				for _,name in ipairs(CardCommon.SortedCardName) do
					if card_name_stat[name] == begin_type and CardCommon.Name2Value(name) > pattern.value then
						local card_pattern = doGetCards({name}, 1, 1, pattern, card_name_info,  card_name_stat)
						table.insert(hintList, card_pattern)
					end
				end
				begin_type = begin_type + 1
			end
		else
            local check_strong_triple = function(card_start, card_end,  repeat_cnt, card_cnt)
                if pattern.type ~= CardCommon.type_three or (not strong_triple) then
                    return true;
                end 
                if (repeat_cnt*3 == card_cnt) then
                    return true;
                end

                --local double_cards = {};
                local cnt = 0;
                for _,c in ipairs(CardCommon.SortedCardName) do
                    if card_name_stat[c] >= 2 
                        and (CardCommon.Name2Value(c) < CardCommon.Name2Value(card_start) 
                            or CardCommon.Name2Value(c) > CardCommon.Name2Value(card_end))
                    then
                        --table.insert(double_cards, c);
                        cnt = cnt + 1;
                        if repeat_cnt == cnt then 
                            return true;
                        end
                    end
                end
                return false;
               
            end
			for _,info in ipairs(repeat_info) do
				if (info.repeat_cnt >= pattern.repeat_cnt) then
					local loop_cnt = 1
					for index=pattern.repeat_cnt,info.repeat_cnt
					do
						if CardCommon.Name2Value(info.cards[index]) > pattern.value 
                            and check_strong_triple(info.cards[loop_cnt], info.cards[index], pattern.repeat_cnt, pattern.card_cnt)
                        then
							local card_pattern = doGetCards(info.cards, loop_cnt, index, pattern, card_name_info,  card_name_stat)
							table.insert(hintList, card_pattern)
						end
						loop_cnt = loop_cnt + 1
					end
				end
			end
		end
	end
	
	if (pattern_four_repeat_info) then
		for _,info in ipairs(pattern_four_repeat_info) do
			for _,card in ipairs(info.cards) do
				local card_pattern = doGetCards4(card_name_info[card])
				table.insert(hintList, card_pattern)
			end
		end
	end
       
	return hintList
end

local doGetFirstHintList=function (card_type_stat,card_name_info,card_name_stat, single_repeat_info)
	local hintList = {}
    local strong_triple = CardCommon.strong_triple
    local strong_double = CardCommon.strong_double;
	local try_cnt = 13
	if (single_repeat_info) then
		while (#hintList==0 and try_cnt > 4) do
			for _,info in ipairs(single_repeat_info) do
				if (info.repeat_cnt >= try_cnt) then
					local card_pattern = doGetCards(info.cards, 1, info.repeat_cnt, {type=CardCommon.type_single}, card_name_info,  card_name_stat)
					table.insert(hintList, card_pattern)
					break
				end
			end
			try_cnt = try_cnt -1
		end
	end 
	try_cnt = 5
	local list = {}
	local max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_three],card_name_stat)
	while ((#list == 0)  and try_cnt > 0) do
		list = doGetHintList({type=CardCommon.type_three,repeat_cnt=try_cnt, value=0,card_cnt=try_cnt*3},repeat_info,max_repeat_info,card_name_info,card_name_stat)
		hintList = CardCommon.Combine(hintList,list)
		try_cnt = try_cnt -1
	end
	try_cnt = 8
	list = {}
	max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_double],card_name_stat)
	while ((#list == 0)  and try_cnt > 0) do
        if not strong_double or  (try_cnt ~= 2)  then 
            list = doGetHintList({type=CardCommon.type_double,repeat_cnt=try_cnt, value=0,card_cnt=try_cnt*2},repeat_info,max_repeat_info,card_name_info,card_name_stat)
		    hintList = CardCommon.Combine(hintList,list)
        end 
		try_cnt = try_cnt -1
	end
	for _,name in ipairs(CardCommon.SortedCardName) do
		if (card_name_stat[name] == 1)then
			local card_pattern = CardPattern.new({card_name_info[name][1]})
			table.insert(hintList, card_pattern)
			break
		end
	end
	try_cnt = 1
	list = {}
	max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_four],card_name_stat)
	while ((#list == 0)  and try_cnt > 0) do
		list = doGetHintList({type=CardCommon.type_four,repeat_cnt=try_cnt, value=0,card_cnt=4},repeat_info,max_repeat_info,card_name_info,card_name_stat)
		hintList = CardCommon.Combine(hintList,list)
		try_cnt = try_cnt -1
	end
	
	return hintList
end
--存在漏洞，只能必选黑桃，其他花色不行（目前只有黑桃3，所以无碍）。
local doGetHintWithCard=function (card_type_stat,card_name_info,card_name_stat, single_repeat_info, essential_card)
	local hintList = {}
    local name = CardCommon.ResolveCardIdx(essential_card).name
    local strong_triple = CardCommon.strong_triple
    local strong_double = CardCommon.strong_double;
	local try_cnt = 13
    if card_name_stat[name] == 0 then
        return hintList;
    end
    local find_card = false;
    for _,c in ipairs(card_name_info[name]) do
        if c == essential_card then
            find_card = true;
            break;
        end
    end
    if not find_card then
        return hintList;
    end
	if (single_repeat_info) then
		for _,info in ipairs(single_repeat_info) do
			if (info.repeat_cnt >= 5) 
                and (CardCommon.Name2Value(name) >= CardCommon.Name2Value(info.card_start))
                and (CardCommon.Name2Value(name) <= CardCommon.Name2Value(info.card_end)) 
            then
				local card_pattern = doGetCards(info.cards, 1, info.repeat_cnt, {type=CardCommon.type_single}, card_name_info,  card_name_stat)
				table.insert(hintList, card_pattern)
				break
			end
		end
	end 

    try_cnt = 5
	list = {}
	max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_three],card_name_stat)
	local find = false;
    while (try_cnt > 1 and (not find)) do
		list = doGetHintList({type=CardCommon.type_three,repeat_cnt=try_cnt, value=0,card_cnt=try_cnt*3},repeat_info,max_repeat_info,card_name_info,card_name_stat)
        for i=1,#list do 
            if list[i]:count(essential_card) > 0 then
                table.insert(hintList, list[i]);
                find = true;
                break;
            end
        end
		try_cnt = try_cnt -1
	end

	try_cnt = 8
    local min_try_cnt = 1;
    if strong_double then 
        min_try_cnt = 2;
    end
	list = {}
	max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_double],card_name_stat)
	local find = false;
    while (try_cnt > min_try_cnt and (not find)) do
		list = doGetHintList({type=CardCommon.type_double,repeat_cnt=try_cnt, value=0,card_cnt=try_cnt*2},repeat_info,max_repeat_info,card_name_info,card_name_stat)
        
        for i=1,#list do 
            if list[i]:count(essential_card) > 0 then
                table.insert(hintList, list[i]);
                find = true;
                break;
            end
        end
		try_cnt = try_cnt -1
	end
    for i=1,card_name_stat[name] do
        if card_name_info[name][i] == essential_card then
            local card_pattern = CardPattern.new(card_name_info[name])
			table.insert(hintList, card_pattern)
			break
        end
    end

    for _,pt in ipairs(hintList) do 
        if pt:count(essential_card) == 0 then
            for i,c in ipairs(pt.cards) do
                local local_name = CardCommon.ResolveCardIdx(c).name;
                if local_name == name then
                    pt.cards[i] = essential_card;
                end
            end
        end
    end
	return hintList
end

function CardSet:multiselect(pattern, selected_cards, is_single, is_black3_player)
    local set = CardSet.new(selected_cards);
    local fn,cnt = set:hintIterator(pattern, nil, is_single, is_black3_player);
    if cnt and cnt >  0 then 
        return fn();
    end
    return nil;
end

function CardSet:hintIterator(pattern,essential_card, is_single, is_black3_player)
	local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(self.cards)
	local max_repeat_info = nil
	local repeat_info = nil
	local pattern_four_repeat_info = nil
	local max_pattern_four_repeat_info = nil
	local tripleA_is_bomb = CardCommon.tripleA_is_bomb;
    local no_triple_p1 = CardCommon.no_triple_p1;
    local allow_unruled_multitriple = CardCommon.allow_unruled_multitriple
    local strong_double = CardCommon.strong_double
	local discard_now = false;
	local pattern_set = nil
    if (CardCommon.pay_all) then 
        --is_single = false;
    end
    if not pattern then
		local min_card = self.cards[1]
        local max_card = self.cards[1]
        for _, c in ipairs(self.cards) do
            if CardCommon.NameIdx2Value(c) > CardCommon.NameIdx2Value(max_card) then
                max_card = c;
            end  
            if CardCommon.NameIdx2Value(c) < CardCommon.NameIdx2Value(min_card) then
                min_card = c;
            end
        end
        max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_single],card_name_stat)
        if essential_card then 
            pattern_set = doGetHintWithCard(card_type_stat,card_name_info,card_name_stat, repeat_info, essential_card)
        else
            pattern_set = doGetFirstHintList(card_type_stat,card_name_info,card_name_stat, repeat_info)
        end
		if (is_single ) then 
            if not pattern_set then
                pattern_set = {};
            end
			for idx,pt in ipairs(pattern_set) do
				if (pt.type == CardCommon.type_single and pt.repeat_cnt == 1) then
                    pt.cards[1] = max_card;
                    pt.value = CardCommon.NameIdx2Value(max_card);
					break
				end
			end
                
		end
        
    else
        if (self.card_cnt < pattern.card_cnt) then
            --return nil
        end
        max_pattern_four_repeat_info,pattern_four_repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_four],card_name_stat)
        
        if pattern.type == CardCommon.type_four then
            max_repeat_info,repeat_info = max_pattern_four_repeat_info,pattern_four_repeat_info
            pattern_set = doGetHintList(pattern,repeat_info,max_repeat_info,card_name_info,card_name_stat)
        end
        if pattern.type == CardCommon.type_three then
            max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_three],card_name_stat)
            pattern_set = doGetHintList(pattern,repeat_info,max_repeat_info,card_name_info,card_name_stat,pattern_four_repeat_info)
        end
        if pattern.type == CardCommon.type_double then
            max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_double],card_name_stat)
            pattern_set = doGetHintList(pattern,repeat_info,max_repeat_info,card_name_info,card_name_stat,pattern_four_repeat_info)
        end
        
        if pattern.type == CardCommon.type_single then
            max_repeat_info,repeat_info = CardCommon.StatRepeatCnt(card_type_stat[CardCommon.type_single],card_name_stat)
            pattern_set = doGetHintList(pattern,repeat_info,max_repeat_info,card_name_info,card_name_stat,pattern_four_repeat_info)
        end
		if pattern.type == CardCommon.type_single and pattern.repeat_cnt == 1 and is_single and pattern_set  and #pattern_set > 0 then
			local last_pt = nil;
            while  true do 
                local find = false
                for i=1,#pattern_set do 
                    if (pattern_set[i].type == CardCommon.type_single) then
                        if (last_pt == nil or pattern_set[i].value > last_pt.value) then
                            last_pt = pattern_set[i];
                        end
                        table.remove(pattern_set, i);
                        find = true;
                        break;
                    end
                end
                if not find then
                    break;
                end
            end
            local raw_single = true;
			if (last_pt and (#pattern_set) >= 1) then 
				for i=1,#pattern_set do
					if (pattern_set[i].value > last_pt.value) then 
						 last_pt.value = pattern_set[i].value;
						 last_pt.cards[1] = pattern_set[i].cards[1];
                         raw_single = false;
					end 
				end
			end
            if (last_pt) then
                if raw_single then 
                    table.insert(pattern_set, 1, last_pt);
                else
                    table.insert(pattern_set, last_pt);
                end
            end
		end
        
    end 
    
    if is_black3_player and (not essential_card) then
        if (card_name_stat[CardCommon.card_3] == 3) then
            for ix,pt in ipairs(pattern_set) do
                if pt.type == CardCommon.type_three and pt.value == CardCommon.Name2Value(CardCommon.card_3)  then
                    table.remove(pattern_set, ix);
                    break; 
                end
            end
            local pt_bomb3 = CardPattern.new(card_name_info[CardCommon.card_3], 3, true);
            if  (not pattern) or ( pt_bomb3:compable(pattern) and (not pt_bomb3:le(pattern))) then
                table.insert(pattern_set, pt_bomb3);
            end
        end
    end
    
    if tripleA_is_bomb and self.card_cnt >= 4 and (not essential_card) then 
        local find=false;
        if (card_name_stat[CardCommon.card_A] == 3)  then 
            local cnt = 1;
            local cards = {}
            CardCommon.Combine(cards, card_name_info[CardCommon.card_A]);
            while cnt <= 4 and (not find) do
                for _,card in ipairs(CardCommon.SortedCardName) do
                    local info_cnt = card_name_stat[card];
                    if card ~= CardCommon.card_A and info_cnt == cnt then 
                        table.insert(cards, card_name_info[card][1]);
                        find = true;
                        break;
                    end
                end
                cnt = cnt + 1
            end
            if (find) then 
                for ix,pt in ipairs(pattern_set) do
                    if pt.type == CardCommon.type_three 
                        and pt.value == CardCommon.Name2Value(CardCommon.card_A)
                    then
                        table.remove(pattern_set, ix);
                    end
                end
                table.insert(pattern_set, CardPattern.new(cards));
            end
        end
    end
    
	if (pattern_set == nil) then
		return nil
	end
	if (#pattern_set) == 0 then
		return nil
	end
    local find_bomb = false;
    for _,pt in ipairs(pattern_set) do 
        if pt.type == CardCommon.type_four then 
            find_bomb = true;
            break;
        end
    end
	if (pattern) then 
		if #pattern_set == 1 
            and pattern_set[1].type ~= CardCommon.type_three
            and pattern_set[1].card_cnt == self.card_cnt
        then
		    discard_now = true;
		elseif pattern.type == CardCommon.type_three and  pattern.card_cnt == self.card_cnt and (not find_bomb) then 
            local pattern_tmp = CardPattern.new(self.cards,self.card_cnt)
            if pattern_tmp then
                pattern_set = {}
				table.insert(pattern_set, pattern_tmp);
				discard_now = true;
            end
		end
	else 
		for _,pattern_obj in ipairs(pattern_set) do 
			if pattern_obj.card_cnt == self.card_cnt then
				pattern_set = {}
				table.insert(pattern_set, pattern_obj)
				discard_now = true
				break
			elseif pattern_obj.type == CardCommon.type_three   and (not find_bomb)  then
                local pattern_tmp = CardPattern.new(self.cards,self.card_cnt)
                if pattern_tmp then
                    pattern_set = {}
				    table.insert(pattern_set, pattern_tmp);
				    discard_now = true;
                    break;
                end
               
			end
		end
	end
    if (pattern and essential_card) then 
        local tmp_set = {};
        for _,pattern_obj in ipairs(pattern_set) do 
            if pattern_obj:count(essential_card) > 0 then
                table.insert(tmp_set, pattern_obj);
            end
        end
        pattern_set = {};
        pattern_set = tmp_set;
    end
	local index = 0
	return function ()
		index = index  % (#pattern_set) + 1
		return pattern_set[index]
	end, (#pattern_set),discard_now
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
function CardSet.shuffle(cards_removed,randomseed)
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6))+tonumber(randomseed)*10)
	local card_names=CardCommon.SortedCardName
	local colors={CardCommon.color_black_heart,CardCommon.color_red_heart,CardCommon.color_plum,CardCommon.color_square};
	local cards={}
	
	for idx=1,CardCommon.max_normal_card_name do
		--local color_idx = CardCommon.GenerateRandomSequence(4)
		for i=1,4 do
			doAddOneCard(cards, card_names[idx], i, cards_removed)
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
function CardSet.deal(cards, player_cnt)
	assert(cards)
	local max_cnt = #cards
	local offset = 1
	assert(max_cnt % player_cnt == 0)
	local player_cards={{},{},{},{}}
    local card_cnt_per_player = max_cnt / player_cnt
	for pix =1,player_cnt do
        for i=1, card_cnt_per_player do 
            table.insert(player_cards[pix], cards[(pix-1)*card_cnt_per_player+i])
        end 
	end
	local cardset = {};
	for i=1,player_cnt do 
		table.insert(cardset, CardSet.new(player_cards[i]))
	end 
	return cardset;
end
function CardSet:find(card)
    for _,c in ipairs(self.cards) do
        if c == card then
            return true;
        end
    end
    return false;
end
function CardSet:discard(card_pattern_object)
local cnt = #(self.cards)
	-- for _,c in ipairs(card_pattern_object.cards) do
	-- 	for idx,card in ipairs(self.cards) do
	-- 		if (c == card) then
	-- 			table.remove(self.cards,idx)
	-- 			break
	-- 		end
	-- 	end
	-- end
	
	-- self.card_cnt = #(self.cards)
	-- --print("self.card_cnt="..self.card_cnt.." old_cnt="..cnt.." pt.ctn="..card_pattern_object.card_cnt);
	-- return self.card_cnt,self.card_cnt ==(cnt-card_pattern_object.card_cnt)
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
function CardSet:count(card)
    local cnt = 0;
    for _,c in ipairs(self.cards) do
        if (c == card) then
            cnt = cnt + 1;
        end
    end 
    return cnt;
end		

return CardSet						
						
						