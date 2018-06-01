local CardCommon = require "package.guandan.module.guandan_table.gamelogic_common"
-- ������
local CardPattern={}


CardPattern.card_cnt = 0

-- �������� ������-1��* 4 + ��ɫ, ǰ���յ�����Զֻ����������������ͨ���������������������뻨ɫ
-- ǰ���˼�����Э���б����Ķ�����������

-- �½�����ʼ��һ������ʵ�� return instance of CardPattern
function CardPattern.new(cards, logic_cards)
	return CardPattern.NewPattern(cards, logic_cards);
end
CardPattern.CompReq= {{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
CardPattern.CompReq[CardCommon.type_single] = {
    CardCommon.type_single,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_single_5] = {
    CardCommon.type_single_5,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_double] = {
    CardCommon.type_double,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_triple2] = {
    CardCommon.type_triple2,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_three] = {
    CardCommon.type_three,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_double3] = {
    CardCommon.type_double3,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_three_p2] = {
    CardCommon.type_three_p2,
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_four] = {
    CardCommon.type_four,
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_five] = {
    CardCommon.type_five,
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_five_same_color] = {
    CardCommon.type_five_same_color,
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_six] = {
    CardCommon.type_six,
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_seven] = {
    CardCommon.type_seven,
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_eight] = {
    CardCommon.type_eight,
    CardCommon.type_four_king}
CardPattern.CompReq[CardCommon.type_four_king] = {}

function CardPattern.NewPatternList(info_list, pattern)
    local pattern_list = {}
    if not info_list then
        return nil;
    end
    for _,info in ipairs(info_list) do
        if info.repeat_cnt >= pattern.repeat_cnt and info.value > pattern.value then
            local begin_ix = 1;
            for end_ix = pattern.repeat_cnt,info.repeat_cnt do
                local real_card = (info.card_start + end_ix - 1 - 1 ) % CardCommon.max_normal_card_name + 1
                
                local pattern_value = CardCommon.Name2Value(real_card, 1)
                if pattern_value > pattern.value then
                    local new_pattern = {cards={},logic_cards={},type=pattern.type,repeat_cnt=pattern.repeat_cnt,value=pattern_value}
                    for ix=begin_ix,end_ix do
                        for card_ix = (ix-1)*info.multiplicity+1,ix*info.multiplicity do
                            table.insert(new_pattern.cards, info.cards[card_ix]);
                            table.insert(new_pattern.logic_cards, 0);
                        end
                        
                    end
                    local logic_cards = {}
                    for ix,pos in ipairs(info.logic_pos) do
                        if pos >= begin_ix and pos <= end_ix then
                            table.insert(logic_cards, info.logic_cards[ix]);
                        end
                    end 
                    table.insert(pattern_list, CardPattern.Encap(new_pattern));
                    new_pattern:update_logic_cards(logic_cards);
                    --bug 
                end
                begin_ix = begin_ix + 1;
            end
        end
    end
    return pattern_list
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

-- �ж����γ��Ƶ������Ƿ�ƥ��
function CardPattern:compable(card_obj)
	assert((self.type > CardCommon.type_unknown and self.type <= CardCommon.max_type) )
    if (card_obj == nil) then
        return false;
    end;

    for _,type in pairs(CardPattern.CompReq[card_obj.type]) do 
        if (type == self.type) then
            return true;
        end

    end
	
    return false;
end
function CardPattern:GetBondType()
    for _,type in ipairs(CardCommon.BondType) do
        if (type == self.type) then
            local o = {type = self.type, cards={}};        
            for _,card in ipairs(self.cards) do
                table.insert(o.cards, card);
            end
            return o;
        end
    end
    return nil;
end
-- �ж����γ��ƵĴ�С С�ڵ��ڷ����棬���򷵻ؼ�
function CardPattern:le(card_obj)
	-- ����ϵ��˵��,Ӱ����ֵ�Ƚ�
	local CardTypeFactor={0,0,0,(CardCommon.max_card_value)*1,0,0}
	-- Ҫ�����ô˺���֮ǰ�����ȵ���compable
	assert(card_obj ~= nil)
	assert(self:compable(card_obj))
	-- ��ֵ�Ϸ��Լ���
	assert(self.value <=  CardCommon.max_card_value and  self.value >  0)
	assert(card_obj.value <=  CardCommon.max_card_value and card_obj.value > 0)
	if (self.type == card_obj.type) then
        return self.value <= card_obj.value;
    else
        return false;
    end

end
function CardPattern.Encap(obj)
    
    setmetatable(obj, {__index=CardPattern})
    return obj;
end
function CardPattern.NewPattern(cards,logic_cards)
    if (cards == nil) then
        return nil;
    end;

    if (#cards > #CardPattern.Parser or #cards < 1) then
        return nil;
    end
        
    local pt = {};
    setmetatable(pt, {__index=CardPattern})
    pt.cards = {}
    pt.logic_cards = {}
    pt.color = CardCommon.color_unkown
    for i,c in ipairs(cards)
	do
		table.insert(pt.cards, c)
        table.insert(pt.logic_cards, 0);
	end
    local use_magic = true;
    if logic_cards and #logic_cards == #cards then 
        for i,c in ipairs(logic_cards)
	    do
            if c ~= 0 and CardCommon.IsMagic(pt.cards[i]) then 
                --�˴�����ԭ��
                pt.logic_cards[i] = pt.cards[i];
                pt.cards[i] = logic_cards[i];
            end
	    end
        use_magic = false;
    end
	
      
    pt.card_cnt = #pt.cards
    local card_type_stat,card_name_info,card_name_stat=CardCommon.InitParse(pt.cards,use_magic)

	local patterns =  CardPattern.Parser[#pt.cards](pt, card_name_stat, card_name_info, card_type_stat)
    if (not use_magic) and patterns then
        for _,pattern in ipairs(patterns) do
            pattern.cards = cards;
            pattern.logic_cards = logic_cards;
        end
    end
    return patterns;
end
function CardPattern:clone()
    local o = {};
    setmetatable(o, {__index=CardPattern})
    o.card_cnt = self.card_cnt;
    o.cards = {};
    CardCommon.Combine(o.cards, self.cards);
    o.logic_cards = {};
    CardCommon.Combine(o.logic_cards, self.logic_cards);
    o.type = self.type;
    o.value = self.value;
    o.repeat_cnt = self.repeat_cnt;
    return o;
end

function CardPattern:update_logic_cards(logic_card_name,color)
    local loop = 1;
    for ix,c in ipairs(self.cards) do
        if loop > #logic_card_name then
            return;
        end
        self.logic_cards[ix] = 0;
        if c == CardCommon.MagicCard then 
            if (color) then 
                self.logic_cards[ix] = CardCommon.FormatCardIndex(logic_card_name[loop],color);
            else
                self.logic_cards[ix] = CardCommon.FormatCardIndex(logic_card_name[loop],CardCommon.color_red_heart);
            end
            loop = loop + 1

        end
    end
end
function CardPattern:update_logic_color(color)
    local loop = 1;
    for ix,c in ipairs(self.logic_cards) do
        if c ~= 0 then 
            local card_info = CardCommon.ResolveCardIdx(c);
            self.logic_cards[ix]= CardCommon.FormatCardIndex(card_info.name,color);
        end
    end
end
CardPattern.Parser={{},{},{},{},{},{},{},{}}

function CardPattern.Parse1Cards(o, card_name_stat, card_name_info, card_type_stat)
    o.type = CardCommon.type_single
	o.value = CardCommon.NameIdx2Value(o.cards[1],0)
	o.repeat_cnt = 1
    --o.disp_type = 1 
	return {o}
end
CardPattern.Parser[1] = CardPattern.Parse1Cards;

function CardPattern.Parser2Cards(o, card_name_stat, card_name_info, card_type_stat)
    o.type = CardCommon.type_double
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    if (#card_type_stat[2]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[2][1],0);
    elseif (#card_type_stat[1]) > 0 
        and magic_cnt == 1 
        and CardCommon.IsNormalCard(card_type_stat[1][1],CardCommon.card_unknown) 
    then
        o.value = CardCommon.Name2Value(card_type_stat[1][1],0);
        o:update_logic_cards({card_type_stat[1][1]});
    elseif magic_cnt == 2  then
        o.value = CardCommon.NameIdx2Value(o.cards[1],0);
    else
        return nil;
    end
	o.repeat_cnt = 1
	return {o}

end
CardPattern.Parser[2] = CardPattern.Parser2Cards;
function  CardPattern.Parser3Cards(o, card_name_stat, card_name_info, card_type_stat)
    o.type = CardCommon.type_three
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    if (#card_type_stat[3]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[3][1],0);
    elseif (#card_type_stat[2]) > 0 
        and magic_cnt == 1  
        and CardCommon.IsNormalCard(card_type_stat[2][1],CardCommon.card_unknown) 
    then
        o.value = CardCommon.Name2Value(card_type_stat[2][1],0);
        o:update_logic_cards({card_type_stat[2][1]});
    elseif magic_cnt == 2   
        and CardCommon.IsNormalCard(card_type_stat[1][1],CardCommon.card_unknown) 
    then
        o.value = CardCommon.Name2Value(card_type_stat[1][1],0);
        o:update_logic_cards({card_type_stat[1][1],card_type_stat[1][1]});
    else
        return nil;
    end
	o.repeat_cnt = 1
	return {o}
end
CardPattern.Parser[3] = CardPattern.Parser3Cards

function CardPattern.Parser4Cards(o, card_name_stat, card_name_info, card_type_stat)
    o.type = CardCommon.type_four
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    if (#card_type_stat[4]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[4][1],0);
    elseif (#card_type_stat[3]) > 0 and magic_cnt == 1 then
        o.value = CardCommon.Name2Value(card_type_stat[3][1],0);
        o:update_logic_cards({card_type_stat[3][1]});
    elseif (#card_type_stat[2]) > 0 
        and magic_cnt == 2 
        and CardCommon.IsNormalCard(card_type_stat[2][1],CardCommon.card_unknown) 
    then
        o.value = CardCommon.Name2Value(card_type_stat[2][1],0);
        o:update_logic_cards({card_type_stat[2][1],card_type_stat[2][1]});
    elseif  (#card_type_stat[2]) == 2 and CardCommon.Name2Value(card_type_stat[2][1]) == CardCommon.Name2Value(CardCommon.card_small_king) then 
        o.type = CardCommon.type_four_king
        o.value = CardCommon.Name2Value(card_type_stat[2][1])
    else
        return nil;
    end
	o.repeat_cnt = 1
    --o.disp_type = 3 
    --����
	return {o}
end

CardPattern.Parser[4] = CardPattern.Parser4Cards
function CardPattern.Parser5Cards(o, card_name_stat, card_name_info, card_type_stat)
 
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    o.type = CardCommon.type_five;
    o.repeat_cnt = 1
    if (#card_type_stat[5]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[5][1],0);
    elseif (#card_type_stat[4]) > 0 and magic_cnt == 1 then
        o.value = CardCommon.Name2Value(card_type_stat[4][1],0);
        o:update_logic_cards({card_type_stat[4][1]});
    elseif (#card_type_stat[3]) > 0  then
        o.value = CardCommon.Name2Value(card_type_stat[3][1],0);

        if magic_cnt == 2   then 
            -- type_five
            o.type = CardCommon.type_five;
            local major_card = CardCommon.ResolveCardIdx(CardCommon.MagicCard).name;
            if major_card ~= card_type_stat[3][1] then
                o:update_logic_cards({card_type_stat[3][1],card_type_stat[3][1]});
            end;
            
            return {o};
        elseif (#card_type_stat[2]) > 1 then
            o.type = CardCommon.type_three_p2;
        elseif (#card_type_stat[1]) == 2 and magic_cnt == 1 then
            o.type = CardCommon.type_three_p2;
            if  card_type_stat[1][1] == card_type_stat[3][1] then
                if not CardCommon.IsNormalCard(card_type_stat[1][2],CardCommon.card_unknown) then
                    return nil;
                else
                    o:update_logic_cards({card_type_stat[1][2]});
                end
            else
                if not CardCommon.IsNormalCard(card_type_stat[1][1],CardCommon.card_unknown) then 
                    return nil;
                else
                    o:update_logic_cards({card_type_stat[1][1]});
                end
            end
        else
            return nil;
        end
    elseif (#card_type_stat[2]) == 2 and  magic_cnt == 1 then
         o.type = CardCommon.type_three_p2;       
         o.value = CardCommon.Name2Value(card_type_stat[2][2],0);
         o:update_logic_cards({card_type_stat[2][2]});

         local o1 = o:clone();
         
         o1.value = CardCommon.Name2Value(card_type_stat[2][1],0);
         o1:update_logic_cards({card_type_stat[2][1]});
         if not CardCommon.IsNormalCard(card_type_stat[2][1],CardCommon.card_unknown) then
            if not CardCommon.IsNormalCard(card_type_stat[2][2],CardCommon.card_unknown) then
                return nil;
            else

                return {o}
            end

         else
            if not CardCommon.IsNormalCard(card_type_stat[2][2],CardCommon.card_unknown) then
                return {o1}
            else
                if (o.value > o1.value) then 
                    return {o,o1}
                else
                    return {o1,o}
                end
            end
         end
    elseif (#card_type_stat[2]) == 1 and  magic_cnt == 2 then
         local card1 = CardCommon.card_unknown;
         local card2 = CardCommon.card_unknown;
         for card,cnt in ipairs(card_name_stat) do 
            if cnt == 1 then
                card1 = card;
            end
            if cnt == 2 then 
                card2 = card;
            end
         end
         
         if (not CardCommon.IsNormalCard(card1,CardCommon.card_unknown)) then
            return nil;
         end
         local o1 = o:clone();
         o1.type = CardCommon.type_three_p2;  
         o1.value = CardCommon.Name2Value(card_type_stat[1][1],0);
         o1:update_logic_cards({card1,card1});

         if (not CardCommon.IsNormalCard(card2,CardCommon.card_unknown)) then
            return {o1};
         end
         o.type = CardCommon.type_three_p2;       
         o.value = CardCommon.Name2Value(card_type_stat[2][1],0);
         o:update_logic_cards({card2,card1});
         
         if (o.value > o1.value) then 
            return {o,o1}
         else
            return {o1,o}
         end

    else
        local color_cnt={0,0,0,0};
        --local obj_pattern = {type=CardCommon.type_single_5,value=0,repeat_cnt=5}
        local max_repeat_info,repeat_info = CardCommon.StatRepeatInfo(card_name_info,1,5,magic_cnt);
        if not max_repeat_info then
            return nil;
        end
        local last_card = CardCommon.card_unknown;
        for _i,card in ipairs(o.cards) do
            local cardinfo = CardCommon.ResolveCardIdx(card);
            if (not CardCommon.IsMagic(card)) or (magic_cnt == 0) then
                if cardinfo.color > 0 and (card ~= last_card) then 
                    color_cnt[cardinfo.color] = color_cnt[cardinfo.color] + 1 
                    last_card = card;
                end
            end 
        end
        local max_val_info = max_repeat_info
--        for _,info in ipairs(repeat_info) do 
--            if info.value > max_val_info.value then
--                max_val_info = info;
--            end
--        end 
        o.value = max_val_info.value;
        o:update_logic_cards(max_val_info.logic_cards);
        --o.logic_cards = max_repeat_info.logic_cards;
        o.type = CardCommon.type_single_5
        --local pattern_list = CardPattern.NewPatternList(max_repeat_info, 1, obj_pattern);
        for color,cnt in ipairs(color_cnt) do
            if (cnt + magic_cnt) == 5 then
                --ths
                o.type = CardCommon.type_five_same_color;
                o.color = color;
                o:update_logic_color(color);
                break
            end 
        end
        o.repeat_cnt = 5
    end
	
    --o.disp_type = 3 
	return {o}
end
CardPattern.Parser[5] = CardPattern.Parser5Cards
function CardPattern.Parser6Cards(o, card_name_stat, card_name_info, card_type_stat)
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    o.type = CardCommon.type_six;
    o.repeat_cnt = 1;
    if (#card_type_stat[6]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[6][1],0);
    elseif (#card_type_stat[5]) > 0 and magic_cnt == 1 then
        o.value = CardCommon.Name2Value(card_type_stat[5][1],0);
        o:update_logic_cards({card_type_stat[5][1]});
    elseif (#card_type_stat[4]) > 0 and magic_cnt == 2 then
        o.value = CardCommon.Name2Value(card_type_stat[4][1],0);
        o:update_logic_cards({card_type_stat[4][1],card_type_stat[4][1]});
    else
        --local obj_pattern = {type=CardCommon.type_single_5,value=0,repeat_cnt=5}
        local max_repeat_info3 = CardCommon.StatRepeatInfo(card_name_info,3,2,magic_cnt);
        
        local max_repeat_info2 = CardCommon.StatRepeatInfo(card_name_info,2,3,magic_cnt);
        local pattern_list = {}
        if max_repeat_info3 then 
            o.type = CardCommon.type_double3;
            o.value = max_repeat_info3.value
            --o.logic_cards = max_repeat_info3.logic_cards;
            o:update_logic_cards(max_repeat_info3.logic_cards);
            o.repeat_cnt = max_repeat_info3.repeat_cnt;
            table.insert(pattern_list, o);
        end
        
        if max_repeat_info2 then
            local o2 = o:clone();
            o2.type = CardCommon.type_triple2;
            o2.value = max_repeat_info2.value
            --o2.logic_cards = max_repeat_info2.logic_cards;
            o2:update_logic_cards(max_repeat_info2.logic_cards);
            o2.repeat_cnt = max_repeat_info2.repeat_cnt;
            table.insert(pattern_list, o2);
        end

        if #pattern_list == 0 then
            return nil;
        end
        return pattern_list;
    end 
    return {o};
end 
CardPattern.Parser[6] = CardPattern.Parser6Cards
function CardPattern.Parser7Cards(o, card_name_stat, card_name_info, card_type_stat)
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    o.type = CardCommon.type_seven;
    o.repeat_cnt = 1;
    if (#card_type_stat[7]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[7][1],0);
    elseif (#card_type_stat[6]) > 0 and magic_cnt == 1 then
        o.value = CardCommon.Name2Value(card_type_stat[6][1],0);
        o:update_logic_cards({card_type_stat[6][1]});
    elseif (#card_type_stat[5]) > 0 and magic_cnt == 2 then
        o.value = CardCommon.Name2Value(card_type_stat[5][1],0);
        o:update_logic_cards({card_type_stat[5][1],card_type_stat[5][1]});
    else
        return nil;
    end 
    return {o};
end 
CardPattern.Parser[7] = CardPattern.Parser7Cards
function CardPattern.Parser8Cards(o, card_name_stat, card_name_info, card_type_stat)
    local magic_cnt = card_name_stat[CardCommon.magic_card];
    o.type = CardCommon.type_eight;
    o.repeat_cnt = 1;
    if (#card_type_stat[8]) > 0 then
        o.value = CardCommon.Name2Value(card_type_stat[8][1],0);
    elseif (#card_type_stat[7]) > 0 and magic_cnt == 1 then
        o.value = CardCommon.Name2Value(card_type_stat[7][1],0);
        o:update_logic_cards({card_type_stat[7][1]});
    elseif (#card_type_stat[6]) > 0 and magic_cnt == 2 then
        o.value = CardCommon.Name2Value(card_type_stat[6][1],0);
        o:update_logic_cards({card_type_stat[6][1],card_type_stat[6][1]});
    else
        return nil;
    end 
    return {o};
end 
CardPattern.Parser[8] = CardPattern.Parser8Cards
-- �ж��Ƿ�Ϊ�Ϸ����ͣ��Ϸ�����true,���򷵻ؼ� 
function CardPattern:parse(cards, owner_set_cnt)
	if CardPattern.new(cards) then 
        return true;
    end 
    return false;
end

return CardPattern

