local CardCommon={}

-- 牌型说明 取值范围 1~4 1代表单牌 2代表对子 3代表三张相同 4代表炸弹
CardCommon.type_unknown=0
--单张
CardCommon.type_single=1
--对子
CardCommon.type_double=2
--连对
CardCommon.type_sequence_double=10
--三张
CardCommon.type_triple=3
--三带二
CardCommon.type_triple_p2 = 12
--三顺
CardCommon.type_sequence_triple=11
--蝴蝶
CardCommon.type_sequence_triple_p2 = 13
--单张顺子
CardCommon.type_sequence_single = 14
CardCommon.type_bomb=4

-- 牌名说明 取值范围1~15  11代表J, 12代表Q, 13代表K, 1代表A, 2~10代表2~10 14代表小王 15代表大王
CardCommon.card_unknown = -1
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
-- 花色说明 取值范围1~4   1代表黑桃 2代表红桃 3代表梅花 4代表方块
CardCommon.color_unkown=0
CardCommon.color_black_heart=1
CardCommon.color_red_heart=2
CardCommon.color_plum=3
CardCommon.color_square=4

CardCommon.bt_bomb_color_5 = 1
CardCommon.bt_bomb_color_6 = 2
CardCommon.bt_bomb_7 = 3
CardCommon.bt_bomb_small_king=4
CardCommon.bt_bomb_big_king=5
CardCommon.bt_bomb_8=6
CardCommon.bt_bomb_king_4=7
CardCommon.bt_bomb_9=8
CardCommon.bt_bomb_10=9
CardCommon.bt_bomb_king_5=10
CardCommon.bt_bomb_11=11
CardCommon.bt_bomb_12 =12
CardCommon.bt_bomb_king_6=13
CardCommon.bt_bomb_king_3p1 = 14

CardCommon.BondType = {
    CardCommon.bt_bomb_color_5, 
    CardCommon.bt_bomb_color_6, 

    CardCommon.bt_bomb_7,
    CardCommon.bt_bomb_small_king,
    CardCommon.bt_bomb_big_king,
    
    CardCommon.bt_bomb_8,
    CardCommon.bt_bomb_king_4,
    
    CardCommon.bt_bomb_9,

    CardCommon.bt_bomb_10,
    CardCommon.bt_bomb_king_5,

    
    CardCommon.bt_bomb_11,

    
    CardCommon.bt_bomb_12 ,
    CardCommon.bt_bomb_king_6,
    CardCommon.bt_bomb_king_3p1
}
CardCommon.BondScore = {
    1, 
    2, 
    1,
    1,
    1,
    2,
    1,
    3,
    4,
    4,
    5,
    6,
    6,
    2
}
-- 牌值定义，下标对应到牌名
CardCommon.CardValue=   {14,16,3,4,5,6,7,8,9,10,11,12,13, 18,19}
CardCommon.SortedCardName={
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
CardCommon.max_card_value=CardCommon.CardValue[CardCommon.card_big_king]
CardCommon.max_normal_card_value=CardCommon.CardValue[CardCommon.card_A]
CardCommon.max_card_name=CardCommon.card_big_king
CardCommon.max_normal_card_name=CardCommon.card_K
CardCommon.max_card_cnt = (13*4+2)*3
CardCommon.proto_name_map = {msg_map={},msg_name_map={}, msg_id_map={}, id_seed=1}
--是否连续单张（5张及以上）可以出顺子
CardCommon.enableSequentialSingle = false
--是否启用喜牌分
CardCommon.enableBondCardScore = true

function CardCommon.IsArray(obj)
    if type(obj) ~= "table" then
        return false;
    end 
    local length = 0;
    for _,v in pairs(obj) do
        length = length + 1;
    end 
    for key,value in pairs(obj) do
        if type(key) ~= "number" then 
            return false;
        end 
        if key <= 0 or  key > length or math.floor(key) < key then
            return false;
        end 
    end 
    return true;
end 
function CardCommon.ProtoDecode(response)
    if not response  or not response.name then
        return nil;
    end 
    local new_obj = {};
    local msg_name = CardCommon.proto_name_map.msg_id_map[response.name]
    if msg_name then 
        new_obj.name = msg_name;
    else
        new_obj.name = response.name;
    end 
    local msg_map = CardCommon.proto_name_map.msg_map[new_obj.name]
    if not msg_map then 
        new_obj.msg = response.msg;
        return new_obj;
    end 
    new_obj.msg = {};
    local curr_obj = new_obj.msg
    for key,value in pairs(response.msg) do 
        local key_name = msg_map.id_map[key]
        if not key_name then 
            key_name = key;
        end
        if type(value) == "table"  
            and CardCommon.IsArray(value) 
            and #value > 0 
            and type(value[1]) == "table" 
        then
            curr_obj[key_name] = {}
            for i,v in ipairs(value) do 
                local curr_new_obj = {}
                table.insert(curr_obj[key_name], curr_new_obj);
                for k,v in pairs(value[i]) do
                    local k_name = msg_map.id_map[k]
                    if not k_name then 
                        k_name = k
                    end 
                    curr_new_obj[k_name] = v;
                end 
            end 
        elseif type(value) == "table"  and (not CardCommon.IsArray(value)) then 
            curr_obj[key_name] = {}
            local obj_v = curr_obj[key_name]
            for k,v in pairs(value) do
                local k_name = msg_map.id_map[k]
                if not k_name then 
                    k_name = k
                end 
                obj_v[k_name] = v;
            end 
        else
            curr_obj[key_name] = value;
        end 
    end 
    return new_obj;
end 

function CardCommon.ProtoEncode(response) 
    if not response  or not response.name then
        return nil;
    end 
    local new_obj = {};
    local msg_id = CardCommon.proto_name_map.msg_name_map[response.name]
    local msg_map = CardCommon.proto_name_map.msg_map[response.name]
    if msg_id then 
        new_obj.name = msg_id;
    else
        new_obj.name = response.name;
    end 
    if not msg_map then 
        new_obj.msg = response.msg;
        return new_obj;
    end 
    
    new_obj.msg = {};
    local curr_obj = new_obj.msg
    for key,value in pairs(response.msg) do 
        local key_id = msg_map.name_map[key]
        if not key_id then 
            key_id = key;
        end
        if type(value) == "table"  
            and CardCommon.IsArray(value) 
            and #value > 0 
            and type(value[1]) == "table" 
        then
            curr_obj[key_id] = {}
            for i,v in ipairs(value) do 
                local curr_new_obj = {}
                table.insert(curr_obj[key_id], curr_new_obj);
                for k,v in pairs(value[i]) do
                    local k_id = msg_map.name_map[k]
                    if not k_id then 
                        k_id = k
                    end 
                    curr_new_obj[k_id] = v;
                end 
            end 
        elseif type(value) == "table"  and (not CardCommon.IsArray(value)) then 
            curr_obj[key_id] = {}
            local obj_v = curr_obj[key_id]
            for k,v in pairs(value) do
                local k_id = msg_map.name_map[k]
                if not k_id then 
                    k_id = k
                end 
                obj_v[k_id] = v;
            end 
        else
            curr_obj[key_id] = value;
        end 
    end 
    return new_obj;
end 
function CardCommon.ProtoAddNameMap(msg,name)
    if not name then
        return;
    end
    local map = CardCommon.proto_name_map.msg_map[msg]
    if not map then 
       local msg_name_map = CardCommon.proto_name_map.msg_name_map
       local msg_id_map = CardCommon.proto_name_map.msg_id_map
       local id = tostring(CardCommon.proto_name_map.id_seed)
       msg_name_map[msg] = id
       msg_id_map[id] = msg;
       CardCommon.proto_name_map.id_seed = tonumber(id) + 1;
       CardCommon.proto_name_map.msg_map[msg] = {id_seed=1,id_map={},name_map={}}

       map = CardCommon.proto_name_map.msg_map[msg]
    end
    if map[name] then
        return;
    end 
    local id = tostring(map.id_seed);
    map.name_map[name] = id;
    map.id_map[id] = name;
    map.id_seed = tonumber(id) + 1;
end 
function CardCommon.InitProtoNameMap()
    
    CardCommon.ProtoAddNameMap("Game.GameInfo", "room_id");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "players");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "game_loop_cnt");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "game_total_cnt");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "desk_player_id");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "desk_cards");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "next_player_id");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "can_apply_showcard");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "time");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "cards");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "state");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "servant_card");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "servant_player_id");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "lord_player_id");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "can_call_servant");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "is_1v4");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "block_operation");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "discard_serno");

    CardCommon.ProtoAddNameMap("Game.GameInfo", "player_id");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "player_pos");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "warning_flag");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "is_offline");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "is_owner");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "is_ready");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "score");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "win_cnt");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "lost_cnt");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "rest_card_cnt");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "round_discard_cnt");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "round_discard_info");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "round_discard_type");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "round_discard_value");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "multiple");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "cards");
    CardCommon.ProtoAddNameMap("Game.GameInfo", "show_card");

    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "player_id");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "is_passed");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "cards");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "warning_flag");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "next_player_id");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "rest_card_cnt");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "is_first_pattern");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "hand_cards");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "multiple");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "can_apply_showcard");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "servant_player_id");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "type");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "is_1v4");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "value");
    CardCommon.ProtoAddNameMap("Game.DiscardNotify", "discard_serno");

    CardCommon.ProtoAddNameMap("Game.DiscardReply", "is_ok");
    CardCommon.ProtoAddNameMap("Game.DiscardReply", "desc");
    CardCommon.ProtoAddNameMap("Game.DiscardReply", "cards");
    CardCommon.ProtoAddNameMap("Game.DiscardReply", "discard_serno");
    
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "players");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "game_count");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "is_summary_account");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "startTime");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "endTime");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "first_player_id");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "show_card_multiple");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "need_show_round_settle");
    
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "player_id");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "remain_card_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "score");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "win_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "lost_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "current_score");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "multiple");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "bond_score");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "played_cards");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "cards");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "bond_pattern_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "lord_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "servant_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "farmer_cnt");
    CardCommon.ProtoAddNameMap("Game.CurrentGameAccount", "identity");

end 
CardCommon.InitProtoNameMap();
function CardCommon.NameIdx2Value(name_idx,value_idx)
    local name = CardCommon.ResolveCardIdx(name_idx).name;
    return CardCommon.Name2Value(name,value_idx);
end

function CardCommon.Name2Value(name)
    return CardCommon.CardValue[name]
end

function CardCommon.Value2Name(val)
    for name,value in ipairs(CardCommon.CardValue) do
        
        if val == value then
            return name;
        end
    end
    return CardCommon.card_unknown;
end
function CardCommon.ResolveCardIdx(name_idx)
    --local name_idx_inter = name_idx % 256
    local cardSeq, name_idx_inter = math.modf(name_idx / 256), name_idx % 256
	local name = math.modf((name_idx_inter-1)/4+1)
	local color = name_idx_inter - (name-1) * 4
	return {name=name,color=color}, cardSeq
end

function CardCommon.FormatCardIndex(name,color,id) 
    if not id then
        id = 0
    end
    return id*256 + (name-1)*4 + color;
end

function CardCommon.SortAsc(cards)
	table.sort(cards, function (a,b)
		local index_a = CardCommon.ResolveCardIdx(a).name
		local index_b = CardCommon.ResolveCardIdx(b).name
		if index_a == index_b then
            local color_value = {1,3,2,4}
            local color_a = CardCommon.ResolveCardIdx(a).color
            local color_b = CardCommon.ResolveCardIdx(b).color
            return color_value[color_a] < color_value[color_b]
		else
			return CardCommon.Name2Value(index_a) < CardCommon.Name2Value(index_b)
		end
		
	end)
end
-- 初始牌型分析，仅统计单牌、对牌、三张及王炸的个数
function CardCommon.InitParse(cards, flag, servant_card, is_lord_player)
    if (type == nil ) then
        type = CardCommon.type_unknown;
    end

	CardCommon.SortAsc(cards)
	-- 牌型数量统计
	local card_type_stat={{},{},{},{},{},{},{},{},{},{},{},{}}
	local card_name_info={}
	-- 针对各张牌名的数量统计
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
        local name = CardCommon.ResolveCardIdx(c).name
        if (c ~= servant_card or (not is_lord_player)) then 
		    card_name_stat[name] = card_name_stat[name]+1
            table.insert(card_name_info[name],c)
		    if last_card == CardCommon.card_unknown then
			    last_card = name
			    card_repeat_cnt = 1
		    elseif name ~= last_card  then
			    if (card_repeat_cnt > 3 or (not flag))  then
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
        end
    end
    if card_repeat_cnt and card_repeat_cnt > 0 then 
	    if (card_repeat_cnt > 3 or (not flag))  then
		    table.insert(card_type_stat[card_repeat_cnt],last_card) 
	    else
		    for i=1,card_repeat_cnt do
			    table.insert(card_type_stat[i],last_card)
		    end
	    end
    end 
    local small_cnt = card_name_stat[CardCommon.card_small_king]
    local big_cnt = card_name_stat[CardCommon.card_big_king]
    if small_cnt == 3 or big_cnt == 3 or  (small_cnt + big_cnt) > 3 then
        if small_cnt > 0 then
            for try_type=1,small_cnt do
                for pos, c in ipairs(card_type_stat[try_type]) do
                    if c == CardCommon.card_small_king then
                        table.remove(card_type_stat[try_type], pos);
                        break;
                    end
                end
            end
        end 
        if big_cnt > 0 then
            for try_type=1,big_cnt do
                for pos, c in ipairs(card_type_stat[try_type]) do
                    if c == CardCommon.card_big_king then
                        table.remove(card_type_stat[try_type], pos);
                        break;
                    end
                end
            end
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


function CardCommon.StatRepeatCnt (card_type_stat,card_name_stat)
	local max_repeat_info = {repeat_cnt=0, value=0}
	local info=nil
	local repeat_info={}
	if ((card_type_stat == nil) or (#card_type_stat == 0)) then
	    return {repeat_cnt=0, value=0},{}
	end
	local card_cnt = #card_type_stat
	local last_value = 0
	local total_cards_cnt = 0
	for _,cnt in ipairs(card_name_stat) do
		total_cards_cnt = total_cards_cnt + cnt;
	end

	for name_idx=1,card_cnt
	do
		local value = CardCommon.Name2Value(card_type_stat[name_idx])
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
	if ((not max_repeat_info) or (info.repeat_cnt > max_repeat_info.repeat_cnt)) then
		max_repeat_info = info
	end
	max_repeat_info.total_cards_cnt = total_cards_cnt;
	return max_repeat_info,repeat_info
end

function CardCommon.Combine(a,b,len)
	if a == nil then
		return b
	end
	if b then 
        if not len then 
            len = #b;
        end
		for i=1,len do
			table.insert(a, b[i])
		end
	end
	return a
end

function CardCommon.GenerateRandomSequence(cnt)
	local orignal={}
	for idx=1,cnt do
		table.insert(orignal,idx)
	end
    for i=1,cnt do
        local j = math.random(i, cnt)
        orignal[i],orignal[j] = orignal[j], orignal[i]
    end
	return orignal
end

return CardCommon