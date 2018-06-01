local CardCommon={}
local cc = CardCommon
--local cjson = {encode = function() return "" end}
local cjson = require "cjson"

---牌型
cc.PT_UNKNOWN=0
cc.PT_SINGLE = 1  --单牌
cc.PT_PAIR = 2  --对子
cc.PT_CPAIR = 3  --连对
cc.PT_STRAIGHT = 4  --顺子
cc.PT_BOMB3 = 5  --三炸
cc.PT_BOMB4 = 6  --四炸
cc.PT_BOMB5 = 7  --五炸
cc.PT_BOMB6 = 8  --六炸
cc.PT_BOMB7 = 9  --七炸
cc.PT_BOMB8 = 10  --八炸
cc.PT_N510K = 11  --副510K
cc.PT_P510K = 12  --正510K
cc.PT_BOMB_KING2 = 13  --对王炸
cc.PT_BOMB_KING3 = 14  --三王炸
cc.PT_BOMB_KING4 = 15  --四王炸
cc.PATTERNS = {cc.PT_SINGLE,cc.PT_PAIR,cc.PT_CPAIR,cc.PT_STRAIGHT,cc.PT_BOMB3,cc.PT_BOMB4,cc.PT_BOMB5,cc.PT_BOMB6,cc.PT_BOMB7,cc.PT_BOMB8,cc.PT_N510K,cc.PT_P510K,cc.PT_BOMB_KING2,cc.PT_BOMB_KING3,cc.PT_BOMB_KING4}
cc.MAX_PATTERN = cc.PT_BOMB_KING4

-- 牌名说明 取值范围1~14  11代表J, 12代表Q, 13代表K, 1代表A, 2~10代表2~10 14代表王牌，小王与大王使用黑红区分
CardCommon.card_unknown = -1
CardCommon.card_magic=0
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
CardCommon.card_C=14  --Clown,小丑牌，即王牌

-- 花色说明 取值范围1~4   1代表黑桃 2代表红桃 3代表梅花 4代表方块
CardCommon.color_unkown=0
CardCommon.color_black_heart=1
CardCommon.color_red_heart=2
CardCommon.color_plum=3
CardCommon.color_square=4

-- 牌值定义，下标对应到牌名，牌名对应的值被编码为相差4的连序整数，eg: A的值为47,3的值为3
CardCommon.CardValue = {47,52,3,7,11,15,19,23,27,31,35,39,43,56}

CardCommon.DEFAULT_MAGIC_CARDS = {53, 54, 53, 54}  --小王、大王为癞子牌，两副牌即4张癞子牌
CardCommon.magicCardEnabled = false
CardCommon.magicCards = cc.DEFAULT_MAGIC_CARDS

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
	CardCommon.card_C
}

CardCommon.ONE_DECK_CARDS_CNT = 13*4+2
CardCommon.DECKS_OF_CARDS = 2
CardCommon.max_card_cnt = cc.DECKS_OF_CARDS * cc.ONE_DECK_CARDS_CNT
CardCommon.max_card_name=CardCommon.card_C  --最大的牌（牌面最大，非值最大）
CardCommon.max_normal_card_name=CardCommon.card_K  --最大的普通牌（牌面最大，非值最大）从1到13表示的牌，除了14的王牌

CardCommon.SEQS_510k = {cc.card_5, cc.card_10, cc.card_K}

---启用或禁用癞子牌功能
--@param enabled 启用或禁用
--@param aMagicCards 癞子牌列表，enabled为false不传，为true时不传表示使用默认设置
function CardCommon.enableMagicCards(enabled, aMagicCards)
	if enabled then
		cc.magicCardEnabled = true
		if aMagicCards then
			cc.magicCards = cc.arrayClone(aMagicCards)
		else
			cc.magicCards = cc.DEFAULT_MAGIC_CARDS
		end
	else
		cc.magicCardEnabled = false
		cc.magicCards = cc.DEFAULT_MAGIC_CARDS
	end
end

function CardCommon.isMagicCardEnabled()
	return cc.magicCardEnabled
end

function CardCommon.getMagicCards()
	return cc.magicCards
end

---给定的牌是否为癞子牌，大小王均为癞子牌，只有开启时才有效
function CardCommon.isMagicCard(card)
	if not CardCommon.magicCardEnabled then
		return false
	end
	for _, c in ipairs(CardCommon.magicCards) do
		if card == c then
			return true
		end
	end
	return false
end

function CardCommon.findMagicCards(cards)
	local mcs = {}
	if not CardCommon.magicCardEnabled then
		return mcs
	end
    for _, c in ipairs(cards) do
        if c == 53 or c == 54 then
            table.insert(mcs, c)
        end
    end
    return mcs
end

function CardCommon.appendMagicCard(array, magicCards, needMagicCardCnt, doRemove)
	assert(array, "array参数不能为nil")
	assert(magicCards, "magicCards参数不能为nil")
	if #magicCards == 0 then
		return array, #magicCards
	end
	local actureAppendCnt = 0
	if doRemove then
		local i = 0
		while #magicCards > 0 do
			table.insert(array, table.remove(magicCards))
			i = i + 1
			if i >= needMagicCardCnt then
				break
			end
		end
		actureAppendCnt = i
	else
		local to = needMagicCardCnt > #magicCards and #magicCards or needMagicCardCnt
		for i=1, to do
			table.insert(array, magicCards[i])
		end
		actureAppendCnt = to
	end
    return actureAppendCnt, #magicCards
end


function CardCommon.isKingCard(cardIdx)
	return cc.getCardName(cardIdx) == CardCommon.card_C
end

function CardCommon.isBigKingCard(cardIdx)
	return cardIdx == 54
end

function CardCommon.isLittleKingCard(cardIdx)
	return cardIdx == 53
end

---获取指定牌索引对应的牌名
--@param cardIdx 牌索引
--@return 牌名，整数
function CardCommon.getCardName(cardIdx)
	return CardCommon.solveCard(cardIdx).name
end

---获取指定牌索引对应的花色
--@param cardIdx 牌索引
--@return 花色，整数，1-4
function CardCommon.getCardColor(cardIdx)
	return CardCommon.solveCard(cardIdx).color
end

---获取指定牌索引对应定义的值
--@param card 牌索引
--@param considerColorValue 是否考虑加上牌颜色值
function CardCommon.getCardValue(card, considerColorValue)
	assert(card, "card不能为nil")
	assert(card>=1 and card<=54, "card参数超出范围，应在[1,54],实际传入:"..card)
	local p = cc.solveCard(card)
	local value = cc.CardValue[p.name]
	if considerColorValue then
		value = value + p.color - 1
	end
	return value
end

function CardCommon.getCardValueByName(cardName)
	return cc.CardValue[cardName]
end

---通过牌的牌面和花色组合一个使用数值表示的具体牌，cardName为行，color为列的二维数组
function CardCommon.makeCard(cardName, color)
	assert(cardName>0 and cardName<=cc.max_card_name, "cardName参数超出范围，应在[1,"..cc.max_card_name.."],实际传入:"..cardName)
	assert(color>0 and color<=4, "color参数超出范围，应该在[1,4]，实际传入:"..color)
	if cardName == cc.card_C and color > 2 then
		--修正大小王的花色，黑或红
		color = color - 1
	end
	return (cardName-1) * 4 + color
end

---拆解牌索引值为牌名和花色
function CardCommon.solveCard(card)
	assert(card, "card参数不能nil")
	--assert(card>0 and card<54, "card参数超出范围，应在[1,54],实际传入:"..card)
	if card <=0 or card > 54 then
		return {name = 0, color = 0}
	end
	local name = math.modf((card-1)/4 + 1)
	local color = card - (name-1) * 4
	return {name=name, color=color}
end

---按牌值排序牌列表,排序影响入参cards数组
--@param cards 待排序牌列表
--@param ascOrder 是否升序，默认为true
--@return cards
function CardCommon.sortByValue(cards, ascOrder)
	local ascOrder = ascOrder == nil and true or ascOrder
	table.sort(cards, function (a,b)
		local ctA, ctB = cc.solveCard(a), cc.solveCard(b)
		local valueA = assert(cc.CardValue[ctA.name], "牌:"..a.."(name:"..ctA.name..")对应的值定义为nil,检查牌值是否合法")
		local valueB = assert(cc.CardValue[ctB.name], "牌:"..b.."(name:"..ctB.name..")对应的值定义为nil,检查牌值是否合法")
		if (valueA == valueB) then
			if ascOrder then
				return a < b
			else
				--按牌值降序时依然按花色升序
				return ctA.color < ctB.color
			end
		else
			if ascOrder then
				return valueA < valueB
			else
				return valueA > valueB
			end
		end
	end)
	return cards
end

--- 初始牌型分析，仅统计单牌、对牌、三张及王炸的个数
--@param cards
function CardCommon.InitParse(cards)
    CardCommon.sortByValue(cards)

	local card_type_stat={{},{},{},{},{},{},{},{}}  --索引代表牌张数，值为该张数可能打出的牌,eg:索引2有{6,7},则可打出6677
	local card_name_info={}
	-- 针对各张牌名的数量统计
	local card_name_stat={}
	for idx=0, CardCommon.max_card_name do
		card_name_stat[idx] = 0
		card_name_info[idx] = {}
	end
	local last_card = CardCommon.card_unknown
	local card_repeat_cnt = 0
	for i,c in ipairs(cards) do
		assert(c > 0)
		local isNotMagicCard = not CardCommon.isMagicCard(c)
		local name = CardCommon.card_magic
        if isNotMagicCard then 
            name = math.modf((c-1)/4+1)
		end
		card_name_stat[name] = card_name_stat[name] + 1
		table.insert(card_name_info[name], c)
        if isNotMagicCard then 
		    if last_card == CardCommon.card_unknown then
			    last_card = name
			    card_repeat_cnt = 1
		    elseif name ~= last_card  then
				if card_repeat_cnt > 2 then  --超过2张即拆牌，3张重复的牌为炸弹，不拆牌
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
	if card_repeat_cnt > 2 then
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
            table.insert(card_name_info[card],CardCommon.magicCards[1]);
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

local cardNameSeqForRepeatStat = {
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
}

function CardCommon.StatRepeatInfo(card_name_info, multiplicity, repeat_cnt)
	--print("repeat_cnt: "..tostring(repeat_cnt)..", multiplicity: "..multiplicity..", magic_cnt:"..tostring(magic_cnt))
	local loop_cnt = 1
	local magicCards = card_name_info[cc.card_magic]
	local magic_cnt = #magicCards
	local info_list = {}
	local begin_name = 0;
	local magic_pos = 0;

	for i, begin_name in ipairs(cardNameSeqForRepeatStat) do
		if begin_name > magic_pos then
			--print("card name:"..begin_name..", magic_pos:"..magic_pos)
			magic_pos = 0;
			local curr_magic_cnt=magic_cnt;
			local info = {cards={},logic_cards={},logic_pos={}, value=0,repeat_cnt=0,card_start=0,card_end=0,curr_magic_cnt=0}
			for j = i, #cardNameSeqForRepeatStat do
				local ix = cardNameSeqForRepeatStat[j]
				local mask = #card_name_info[ix]  --mask为ix牌名对应的牌张数
				local quit_loop = false;
				--print("  "..ix.." card size:"..mask)
				if mask >= multiplicity then
					if info.card_start == 0 then
						info.card_start = ix;
					end
					info.repeat_cnt = info.repeat_cnt + 1
					info.card_end = ix;
					for i=1, multiplicity do 
						table.insert(info.cards, card_name_info[info.card_end][i]);
					end
					info.value = cc.getCardValueByName(info.card_end);
					--print("  1.",ix, cjson.encode(info))
				end

				if info.card_end ~= ix then  --上个if没处理已不连续
					--print("  curr_magic_cnt + mask = "..(curr_magic_cnt + mask))
					if (curr_magic_cnt + mask) < multiplicity then
						if info.repeat_cnt >= repeat_cnt then
							--满足要求的连续个数
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
						info.value = cc.getCardValueByName(info.card_end);
						for i=1, mask do 
							table.insert(info.cards, card_name_info[info.card_end][i]);
						end
						local need_magic_cnt = multiplicity - mask

						for i=1,need_magic_cnt do 
							table.insert(info.cards, magicCards[i]);
							table.insert(info.logic_cards,ix);
							table.insert(info.logic_pos, info.repeat_cnt);
						end
						if (magic_pos == 0) then
							magic_pos = ix;
						end
						curr_magic_cnt = curr_magic_cnt - need_magic_cnt;
						info.curr_magic_cnt = info.curr_magic_cnt + need_magic_cnt
						--print("2.",ix, cjson.encode(info))
					end
				end
				if info.card_end == CardCommon.max_normal_card_name then  --max_normal_card_name:K 最大的普通牌（牌面最大，非值最大）
					quit_loop = true;
					local ca_mask = #card_name_info[CardCommon.card_A]
					if (ca_mask >=multiplicity or (magic_cnt - info.curr_magic_cnt + ca_mask) >= multiplicity ) then 
						info.card_end = CardCommon.card_A;
						info.value = cc.getCardValueByName(info.card_end);
						info.repeat_cnt = info.repeat_cnt + 1;
						for i=1, ca_mask do 
							table.insert(info.cards, card_name_info[info.card_end][i]);
						end
						--print("3.",ix, cjson.encode(info))
			
						if ca_mask < multiplicity then 
							local need_magic_cnt = multiplicity - ca_mask
							for i=1,need_magic_cnt do 
								table.insert(info.cards, cc.magicCards[i]);
								table.insert(info.logic_cards, info.card_end);
								table.insert(info.logic_pos, info.repeat_cnt);
							end
							if (magic_pos == 0) then
								magic_pos = ix;
							end
							curr_magic_cnt = curr_magic_cnt - need_magic_cnt;
							info.curr_magic_cnt = info.curr_magic_cnt + need_magic_cnt
							--print("4.",ix, cjson.encode(info))
						end
					end
					if info.repeat_cnt >= repeat_cnt then
						info.multiplicity = multiplicity
						table.insert(info_list,info);
						--print("2. getting!")
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
	return max_value_info, info_list;
end

function CardCommon.GenerateRandomSequence(cnt)
	local orignal={}
	for idx=1, cnt do
		table.insert(orignal, idx)
	end
	local rand_sequence={}
	local rand_cnt = 0
	while (rand_cnt < cnt) do
		local x = math.random(1, cnt-rand_cnt);
		table.insert(rand_sequence, orignal[x])
		table.remove(orignal, x)
		rand_cnt = rand_cnt + 1
	end
	return rand_sequence
end

function CardCommon.generateOneDeckCards(excludeCards)
    local cards = cc.GenerateRandomSequence(cc.ONE_DECK_CARDS_CNT)
    if excludeCards and #excludeCards > 0 then
        for _, ex in ipairs(excludeCards) do
            local i = nil
            for j, c in ipairs(cards) do
                if ex == c then
                    i = j
                    break
                end
            end
            if i then
                table.remove(cards, i)
            end
        end
    end
    return cards
end

-----------------
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

---找出指定值在数组中的索引位置
function CardCommon.arrayIndexOf(array, value)
	if array == nil or value == nil then
		return nil
	end

    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

---将array2数组中的元素追加到array1数组后面
function CardCommon.arrayAppend(array1, array2, startOf)
	if array1 == nil or array2 == nil then
		return array1
	end

	local i = 1
	local len2 = #array2
    if startOf and type(startOf) == "number" and startOf > 0 then
		i = startOf
		if i > len2 then
			return array1
		end
    end
    while i <= len2 do
        table.insert(array1, array2[i])
        i = i + 1
    end
    return array1
end

---浅复制数组
function CardCommon.arrayClone(array)
	assert(array)
	local copy = {}
	cc.arrayAppend(copy, array)
	return copy
end

---清除数组
function CardCommon.arrayClear(array)
	assert(array)
	repeat
		table.remove(array)
	until #array == 0
end

---差集,重复元素只减一次
function CardCommon.arraySubtract(array1, array2)
	local a = cc.arrayClone(array1)
	local b = cc.arrayClone(array2)
	local i = #a
	while i > 0 do
		local e1 = a[i]
		local found = false
		local j = #b
		while j > 0 do
			local e2 = b[j]
			if e1 == e2 then
				table.remove(b, j)
				found = true
				break
			else
				j = j - 1
			end
		end
		if found then
			table.remove(a, i)
		else
			i = i - 1
		end
	end
	return a
end

return CardCommon
