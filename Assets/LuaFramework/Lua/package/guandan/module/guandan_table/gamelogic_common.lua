local CardCommon={}

-- ����˵�� ȡֵ��Χ 1~4 1������ 2������� 3����������ͬ 4����ը��
CardCommon.type_unknown=0
CardCommon.type_single=1
CardCommon.type_single_5=13
CardCommon.type_double=2
CardCommon.type_triple2=10
CardCommon.type_three=3
CardCommon.type_three_p2 = 12
CardCommon.type_double3=11
CardCommon.type_four=4
CardCommon.type_five=5
CardCommon.type_five_same_color=9
CardCommon.type_six=6
CardCommon.type_seven=7
CardCommon.type_eight=8
CardCommon.type_four_king = 14

CardCommon.type_max = CardCommon.type_four_king
-- ����˵�� ȡֵ��Χ1~15  11����J, 12����Q, 13����K, 1����A, 2~10����2~10 14����С�� 15�������
CardCommon.card_unknown = -1
CardCommon.magic_card=0
CardCommon.card_A=1
CardCommon.card_2=2
CardCommon.card_3=3
CardCommon.card_4=4
CardCommon.card_5=5
CardCommon.card_6=6
CardCommon.card_7=7
CardCommon.card_8=8
CardCommon.card_9=9
CardCommon.card_10=10
CardCommon.card_J=11
CardCommon.card_Q=12
CardCommon.card_K=13
CardCommon.card_small_king=14
CardCommon.card_big_king=15
-- ��ɫ˵�� ȡֵ��Χ1~4   1������� 2������� 3����÷�� 4������
CardCommon.color_unkown=0
CardCommon.color_black_heart=1
CardCommon.color_red_heart=2
CardCommon.color_plum=3
CardCommon.color_square=4
CardCommon.BondType = {CardCommon.type_five_same_color, CardCommon.type_six, CardCommon.type_seven, CardCommon.type_eight, CardCommon.type_four_king}
-- ��ֵ���壬�±��Ӧ������
CardCommon.DefCardValue={{14,1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{18},{19}}
CardCommon.CardValue=   {{14,1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{18},{19}}
CardCommon.MagicValue = 16
CardCommon.MagicCard = CardCommon.card_unknown
CardCommon.SortedCardName={
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
	CardCommon.card_A,
	CardCommon.card_small_king,
	CardCommon.card_big_king
}
CardCommon.max_card_value=19
CardCommon.max_type=14
CardCommon.max_normal_card_value=14
CardCommon.max_card_name=CardCommon.card_big_king
CardCommon.max_normal_card_name=13
CardCommon.max_card_cnt = (13*4+2)*2
function CardCommon.GetNextCard(card_name,uplevel)
    if ((card_name+uplevel) == CardCommon.card_K + 1) then
        return CardCommon.card_A;
    elseif ((card_name+uplevel) > CardCommon.card_K + 1) then
        return CardCommon.card_2;
    end
    return card_name+uplevel;
end

function CardCommon.IsMagic(card)
    return card == CardCommon.MagicCard
end

function CardCommon.IsNormalCard(card,major_card)
    local name=card;
    if (name == CardCommon.card_small_king 
        or name == CardCommon.card_big_king 
        or name == major_card) 
    then
        return false;
    else
        return true;
    end
end


function CardCommon.SetBondType(calc_five_same_color,calc_six,calc_four_king)
    CardCommon.BondType = {};

    if (calc_five_same_color) then 
        table.insert(CardCommon.BondType, CardCommon.type_five_same_color);
    end

    if (calc_six) then
        table.insert(CardCommon.BondType, CardCommon.type_six)
        table.insert(CardCommon.BondType, CardCommon.type_seven)
        table.insert(CardCommon.BondType, CardCommon.type_eight)
    end
    if (calc_four_king) then
        table.insert(CardCommon.BondType, CardCommon.type_four_king);

    end
end

function CardCommon.GenerateCardInfo(major_card)
    --CardValue
    CardCommon.MagicCard = CardCommon.FormatCardIndex(major_card, CardCommon.color_red_heart)
    CardCommon.CardValue[CardCommon.magic_card] = {CardCommon.MagicValue}
    for ic,cv in  ipairs(CardCommon.CardValue) do
        CardCommon.CardValue[ic] = {} 
        for iv,v in ipairs(CardCommon.DefCardValue[ic]) do
            table.insert(CardCommon.CardValue[ic],v)
        end
    end
    table.insert(CardCommon.CardValue[major_card],CardCommon.MagicValue)
--    for i = 1,CardCommon.max_normal_card_name do
--        table.insert(CardCommon.CardValue[magic_card], CardCommon.CardValue[i])
--    end
    --SortedCardName
    table.sort(CardCommon.SortedCardName,function(a,b) 
        return CardCommon.Name2Value(a,0) < CardCommon.Name2Value(b,0)
    end)
end

function CardCommon.NameIdx2Value(name_idx,value_idx)
    local name = math.modf((name_idx-1)/4+1);
    return CardCommon.Name2Value(name,value_idx);
end

function CardCommon.Name2Value(name,value_idx)
    if value_idx == 0 then 
        local mv = 0;
        for _,val in ipairs(CardCommon.CardValue[name]) do
            if val > mv then 
                mv = val;
            end
        end
        return mv;
    elseif (value_idx and value_idx < #CardCommon.CardValue[name]) then 
	    return CardCommon.CardValue[name][value_idx]
    else
        return CardCommon.CardValue[name][1]
    end
end

function CardCommon.Value2Name(value)
    for name,values in ipairs(CardCommon.CardValue) do
        for _,val in ipairs(values) do
            if val == value then
                return name;
            end
        end
    end
    return CardCommon.card_unknown;
end
function CardCommon.ResolveCardIdx(name_idx)
	local name = math.modf((name_idx-1)/4+1)
	local color = name_idx - (name-1) * 4
	return {name=name,color=color}
end

function CardCommon.FormatCardIndex(name,color) 
    if (color) then 
	    return (name-1)*4+color
    else 
        return (name-1)*4
    end
end
function CardCommon.Sort(cards)
	table.sort(cards, function (a,b)
		local index_a = math.modf((a-1)/8+1)
		local index_b = math.modf((b-1)/8+1)
		if (CardCommon.Name2Value(index_a) == CardCommon.Name2Value(index_b)) then
			return a < b
		else
			return CardCommon.Name2Value(index_a) > CardCommon.Name2Value(index_b)
		end
		
	end)
end
function CardCommon.SortAsc(cards)
	table.sort(cards, function (a,b)
		local index_a = math.modf((a-1)/4+1)
		local index_b = math.modf((b-1)/4+1)
		if (CardCommon.Name2Value(index_a) == CardCommon.Name2Value(index_b)) then
			return a < b
		else
			return CardCommon.Name2Value(index_a) < CardCommon.Name2Value(index_b)
		end
		
	end)
end
-- ��ʼ���ͷ�������ͳ�Ƶ��ơ����ơ����ż���ը�ĸ���
function CardCommon.InitParse(cards,use_magic,type)
    if (type == nil ) then
        type = CardCommon.type_unknown;
    end

    local magic_card = CardCommon.card_unknown;
    if (use_magic) then 
        magic_card = CardCommon.MagicCard;
    end
	CardCommon.SortAsc(cards)
	-- ��������ͳ��
	local card_type_stat={{},{},{},{},{},{},{},{}}
	local card_name_info={}
	-- ��Ը�������������ͳ��
	local card_name_stat={}
	for idx=0,CardCommon.max_card_name
	do
		card_name_stat[idx] = 0
		card_name_info[idx] = {}
	end
	local last_card = CardCommon.card_unknown
	local card_repeat_cnt = 0
	for i,c in ipairs(cards)
	do
		assert(c > 0)
        local name = CardCommon.magic_card
        if (c ~= magic_card ) then 
            name = math.modf((c-1)/4+1)
        end		
        --��������ֻ��name_stat�У������ط������漰��
		card_name_stat[name] = card_name_stat[name]+1
		

        if (c ~= magic_card) then 
            table.insert(card_name_info[name],c)
		    -- ��ʱ֧��һ����
		    -- assert(card_name_stat[name] <= 4)
		    -- table.insert(card_type_stat[card_name_stat[name]],name)
		    if last_card == CardCommon.card_unknown then
			    last_card = name
			    card_repeat_cnt = 1
		    elseif name ~= last_card  then
			    if (card_repeat_cnt > 3)  and type ~= CardCommon.type_five_same_color  then
				    table.insert(card_type_stat[card_repeat_cnt],last_card)
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
--        else 
--            if magic_card ~= last_card  then
--			    if (card_repeat_cnt > 3) then
--				    table.insert(card_type_stat[card_repeat_cnt],last_card)
--			    else
--				    for i=1,card_repeat_cnt do
--					    table.insert(card_type_stat[i],last_card)
--				    end
--			    end
--            end
--			last_card = CardCommon.card_unknown
--			card_repeat_cnt = 0
        end
	end
	if (card_repeat_cnt > 3) and type ~= CardCommon.type_five_same_color then
		table.insert(card_type_stat[card_repeat_cnt],last_card) 
	else
		for i=1,card_repeat_cnt do
			table.insert(card_type_stat[i],last_card)
		end
	end
	return card_type_stat,card_name_info,card_name_stat
end

CardCommon.CloneNameInfo=function(card_name_info)
    local name_info = {};
    for card_name,info in pairs(card_name_info) do
        name_info[card_name] = {};
        for ix,card in ipairs(info) do
            table.insert(name_info[card_name], card)
        end
    end
    return name_info;
end
CardCommon.UpdateNameInfo=function(card_name_info, logic_cards, fixd_cnt)
    for _,card in ipairs(logic_cards) do
        for i=#card_name_info[card],fixd_cnt do
            table.insert(card_name_info[card],CardCommon.MagicCard);
        end
    end
end
CardCommon.CloneRepeatInfo=function(src)
    if (src == nil) then
        return nil;
    end
    local repeat_info = {   
        repeat_cnt = src.repeat_cnt, 
        value = src.value,
        card_start = src.card_start,
        card_end = src.card_end,
        cards = {}
    };
    for _,c in ipairs(src.cards) do
        table.insert(repeat_info.cards, c);
    end
    return repeat_info;
end



CardCommon.MagicRepeatInfo = function (repeat_info, multiplicity, idx, card_name_stat, magic_cnt)
    if (not repeat_info) or (not repeat_info[idx]) then
        return nil;
    end 
    local logic_cards = {};
    local info_cnt = #repeat_info;
    local info = CardCommon.CloneRepeatInfo(repeat_info[idx]);
    while magic_cnt > 0 and info.value < CardCommon.Name2Value(CardCommon.card_A)  do 
        local miss_cnt = multiplicity - card_name_stat[CardCommon.Value2Name(info.value+1)]
        if miss_cnt > 0 and miss_cnt <= magic_cnt then
            info.value = info.value+1
            table.insert(logic_cards, CardCommon.Value2Name(info.value));
            table.insert(info.cards,CardCommon.magic_card);
            info.repeat_cnt = info.repeat_cnt + 1
            magic_cnt = magic_cnt - miss_cnt
        else
            break;
        end
        if (idx < info_cnt and info.value+repeat_info[idx+1].repeat_cnt  == repeat_info[idx+1].value) then
            info.cards = CardCommon.Combine(info.cards,  repeat_info[idx+1].cards);
            info.value = repeat_info[idx+1].value;
            info.repeat_cnt = info.repeat_cnt + repeat_info[idx+1].repeat_cnt;
            idx = idx + 1
        end
    end 
    if info.value <= CardCommon.max_normal_card_value then 
        while (1 < (info.value + 1 - info.repeat_cnt) and magic_cnt > 0) do
            local miss_cnt = multiplicity - card_name_stat[CardCommon.Value2Name(info.value + 1 - info.repeat_cnt)]
            if miss_cnt <= 0 or  miss_cnt > magic_cnt then
                break;
            end
            table.insert(logic_cards, card_name_stat[info.value + 1 - info.repeat_cnt]);
            table.insert(info.cards,CardCommon.magic_card);
            info.repeat_cnt = info.repeat_cnt + 1
            magic_cnt = magic_cnt - miss_cnt;
            --ins
        end
    end
    return info,logic_cards;
end

function CardCommon.StatRepeatInfo (card_name_info,multiplicity, repeat_cnt,magic_cnt)
	local pattern_info_list = {}
	local loop_cnt = 1
	local color_cnt={0,0,0,0};
	if not magic_cnt  then
		magic_cnt = 0;
	end
	local info_list = {}
	local begin_name = 0;
    local magic_pos = 0;
	while begin_name < CardCommon.max_normal_card_name  do 
		begin_name = begin_name + 1
		if begin_name > magic_pos then 
			magic_pos = 0;
			local curr_magic_cnt=magic_cnt;

			local info = {cards={},logic_cards={},logic_pos={}, value=0,repeat_cnt=0,card_start=0,card_end=0,curr_magic_cnt=0}
			for ix=begin_name,CardCommon.max_normal_card_name do 
                local mask = #card_name_info[ix]
                local quit_loop = false;
				if mask >= multiplicity then
					if info.card_start == 0 then
						info.card_start = ix;
					end
					info.repeat_cnt = info.repeat_cnt+1
					info.card_end = ix;
                    for i=1,multiplicity do 
					    table.insert(info.cards,card_name_info[info.card_end][i]);
					    --table.insert(info.logic_cards,0);
                    end
                    info.value = CardCommon.Name2Value(info.card_end, 1);
				end
                
				if info.card_end ~= ix  then
					if (curr_magic_cnt + mask) < multiplicity then 
						if info.repeat_cnt >= repeat_cnt then
                            info.multiplicity = multiplicity
							table.insert(info_list,info);  
						end
						if magic_cnt == 0 then
							magic_pos = ix;
						end
                        quit_loop = true;
					else
						if info.card_start == 0 then
							info.card_start = ix
							info.repeat_cnt = 0;
						end
						info.repeat_cnt = info.repeat_cnt+1
						info.card_end = ix;
						info.value = CardCommon.Name2Value(info.card_end, 1);
                        for i=1,mask do 
					        table.insert(info.cards,card_name_info[info.card_end][i]);
					        --table.insert(info.logic_cards,0);
                        end
                        local need_magic_cnt = multiplicity - mask
                        
                        for i=1,need_magic_cnt do 
					        table.insert(info.cards,CardCommon.MagicCard);
					        table.insert(info.logic_cards,ix);
                            table.insert(info.logic_pos, info.repeat_cnt);
                        end
						if (magic_pos == 0) then
							magic_pos = ix;
						end
						curr_magic_cnt = curr_magic_cnt - need_magic_cnt;
						info.curr_magic_cnt = info.curr_magic_cnt + need_magic_cnt
					end
				end
                if info.card_end == CardCommon.max_normal_card_name then
                    local ca_mask = #card_name_info[CardCommon.card_A]
                    quit_loop = true;
		            if  (ca_mask >=multiplicity  or (magic_cnt - info.curr_magic_cnt + ca_mask) >= multiplicity ) then 
			            info.card_end = CardCommon.card_A;
			            info.value = CardCommon.Name2Value(info.card_end, 1);
			            info.repeat_cnt = info.repeat_cnt + 1;
                        for i=1,ca_mask do 
				            table.insert(info.cards,card_name_info[info.card_end][i]);
				            --table.insert(info.logic_cards,0);
                        end
            
			            if ca_mask < multiplicity then 
                            local need_magic_cnt = multiplicity - ca_mask
                            for i=1,need_magic_cnt do 
				                table.insert(info.cards,CardCommon.MagicCard);
				                table.insert(info.logic_cards,info.card_end);
                                table.insert(info.logic_pos, info.repeat_cnt);
                            end
                            if (magic_pos == 0) then
                                magic_pos = ix;
                            end
                            curr_magic_cnt = curr_magic_cnt - need_magic_cnt;
                            info.curr_magic_cnt = info.curr_magic_cnt + need_magic_cnt
                            
			            end
		            end
                    if info.repeat_cnt >= repeat_cnt then
                        info.multiplicity = multiplicity
						table.insert(info_list,info);  
					end
                end
                if quit_loop then
                    break;
                end
			end
		end 
	
	end
	
	local max_value_info = nil;
	for _,info in ipairs(info_list) do
		if not max_value_info or (info.value > max_value_info.value) then
			max_value_info = info;
		end
		--print("card_start", info.card_start, "card_end", info.card_end, "repeat_cnt", info.repeat_cnt, "curr_magic_cnt", info.curr_magic_cnt);
	end
	return max_value_info,info_list;
end

function CardCommon.StatRepeatCnt (card_type_stat,card_name_stat)
	local max_repeat_info = nil
	local info=nil
	local repeat_info={}
	if ((card_type_stat == nil) or (#card_type_stat == 0)) then
	    return {},{}
	end
	local card_cnt = #card_type_stat
	local last_value = 0
	local total_cards_cnt = 0
	for _,cnt in ipairs(card_name_stat) do
		total_cards_cnt = total_cards_cnt + cnt;
	end
	local ca_mask = 0;

	for name_idx=1,card_cnt
	do
		--print("index=",name_idx, " value=",CardCommon.Name2Value(card_type_stat[name_idx]))
        if card_type_stat[name_idx] == CardCommon.card_A then
            ca_mask = 1;
        end
		local value = CardCommon.Name2Value(card_type_stat[name_idx])
        if (value ~= CardCommon.MagicValue) then
		    if name_idx == 1  then
			    info = {value=value,repeat_cnt=1,card_start=card_type_stat[name_idx],card_end=card_type_stat[name_idx],cards={card_type_stat[name_idx]}}
			    table.insert(repeat_info,info)
			    max_repeat_info = info
		    elseif value == last_value + 1  then
			    info.card_end = card_type_stat[name_idx]
			    info.repeat_cnt = info.repeat_cnt+1
                info.value=value
			    table.insert(info.cards, card_type_stat[name_idx])
		    else
			    if (info.repeat_cnt > max_repeat_info.repeat_cnt) then
				    max_repeat_info = info
			    end
			    info = {value=value,repeat_cnt=1,card_start=card_type_stat[name_idx],card_end=card_type_stat[name_idx],cards={card_type_stat[name_idx]}}
			    table.insert(repeat_info,info)
                
		    end
		    last_value = value
        end
	end
	if ((not max_repeat_info) or (info.repeat_cnt > max_repeat_info.repeat_cnt)) then
		max_repeat_info = info
	end
    for _,info in ipairs(repeat_info) do
        if (info.card_start == CardCommon.card_2 ) and ca_mask == 1 then
            info.repeat_cnt = info.repeat_cnt + 1;
            info.card_start = CardCommon.card_A;
            table.insert(info.cards, 1, CardCommon.card_A);
        end
    end
	max_repeat_info.total_cards_cnt = total_cards_cnt;
	return max_repeat_info,repeat_info
end

function CardCommon.Combine(a,b)
	if a == nil then
		return b
	end
	if b then 
		for i,v in ipairs(b) do
			table.insert(a, v)
		end
	end
	return a
end
function CardCommon.GenerateRandomSequence(cnt)
	local orignal={}
	local rand_sequence={}
	for idx=1,cnt do
		table.insert(orignal,idx)
	end
	local rand_cnt = 0
	while (rand_cnt < cnt) do
		local x = math.random(1,cnt-rand_cnt);
		table.insert(rand_sequence, orignal[x])
		table.remove(orignal, x)
		rand_cnt = rand_cnt + 1
	end
	return rand_sequence

end

return CardCommon
			
						
						
						