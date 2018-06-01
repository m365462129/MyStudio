local cp = require('package.wushik.module.table.gamelogic_pattern')
local cc = require('package.wushik.module.table.gamelogic_common')
local csort = require('package.wushik.module.table.gamelogic_sort')
--local cp = require "gamelogic_pattern"
--local cc = require "gamelogic_common"
--local csort = require "gamelogic_sort"
--local cjson = {encode = function() return "" end}
local cjson = require "cjson"

-- 牌集类
local CardSet={}
CardSet.card_cnt = 0
CardSet.cards={}

local function toString(cs)
    return "cardset("..cs.card_cnt..")["..table.concat(cs.cards,",").."]"
end

-- 返回新的牌集对象 return instance of CardSet
function CardSet.new(cards, card_cnt)
	local o = {}
	setmetatable(o, {__index=CardSet, __tostring = toString});
	if (cards ~= nil)then
		o.cards = {}
		for i,c in ipairs(cards) do
			table.insert(o.cards,c)
        end
        csort.sortBySpec(o.cards)
	end
	if (card_cnt == nil) then
		card_cnt = #(o.cards)
	end
	o.card_cnt = card_cnt
	return o
end

local function newPattern(cards, handCardCnt)
    if type(cards) ~= "table" then
        cards = {cards}
    end
    local pts = cp.new(cards, nil, handCardCnt)
    if not pts then
        return nil
    end
    return pts[1], #pts, pts
end

---所有牌型提示处理函数列表
local patternHints = {}

local function doHint(targetPattern, card_type_stat, card_name_info, card_name_stat, cardCnt)
    local hintSeqs = assert(cp.patternCompaleMap[targetPattern.type], "非法的targetPattern.type值:"..targetPattern.type)
    local hintList = {}
    for _, p in ipairs(hintSeqs) do
        local array = patternHints[p](targetPattern, card_type_stat, card_name_info, card_name_stat, cardCnt)
        cp.UniqueCombine(hintList, array)
    end
    return hintList
end

local function doHintAll(card_type_stat, card_name_info, card_name_stat, cardCnt)
    local patterns = {}
    if cardCnt == 1 then
        table.insert(patterns, {type = cc.PT_SINGLE, card_cnt = 0, repeat_cnt=1, value = 0})
    elseif cardCnt == 2 then
        table.insert(patterns, {type = cc.PT_SINGLE, card_cnt = 0, repeat_cnt=1, value = 0})
        table.insert(patterns, {type = cc.PT_PAIR, card_cnt = 0, repeat_cnt=1, value = 0})
    else
        table.insert(patterns, {type = cc.PT_SINGLE, card_cnt = 0, repeat_cnt=1, value = 0})
        table.insert(patterns, {type = cc.PT_PAIR, card_cnt = 0, repeat_cnt=1, value = 0})
        table.insert(patterns, {type = cc.PT_STRAIGHT, card_cnt = 0, repeat_cnt=3, value = 0})
        table.insert(patterns, {type = cc.PT_CPAIR, card_cnt = 0, repeat_cnt=3, value = 0})
    end
    local hintList = {}
    for _, p in ipairs(patterns) do
        cp.UniqueCombine(hintList, doHint(p, card_type_stat, card_name_info, card_name_stat, cardCnt))
    end
    return hintList
end

patternHints[cc.PT_SINGLE] = function(pattern, card_type_stat, card_name_info, card_name_stat, cardCnt)
    local hintList = {}
    local card_cnt = 1;
    while #hintList == 0 and card_cnt < 4 do 
        for _,cardName in ipairs(cc.SortedCardName) do
            local cards = card_name_info[cardName] 
            local cnt = #cards
            if cardName == cc.card_C and cnt == 0 then
                cards = card_name_info[cc.card_magic] 
                cnt = #cards
            end
            if cnt == card_cnt and cp.calcValue2(cc.PT_SINGLE, cardName) > pattern.value then
                local pt = newPattern(cards[1], cardCnt)
                table.insert(hintList, pt)
            end
        end
        card_cnt = card_cnt + 1
        if (pattern.value == 0) then
            break;
        end
    end
    
    return hintList;
end

patternHints[cc.PT_STRAIGHT] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    local _, repeat_info = cc.StatRepeatInfo(card_name_info, 1, 3);
    return cp.NewPatternList(repeat_info, pattern)
end

patternHints[cc.PT_PAIR] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    local hintList = {}
    local obj_type = cc.PT_PAIR
    local card_cnt = 2;
    while #hintList == 0 and card_cnt < 4 do 
        for _,card in ipairs(cc.SortedCardName) do
            cnt = #card_name_info[card]
            if cnt == card_cnt and cp.calcValue2(cc.PT_PAIR, card) > pattern.value then
                local card_pattern = {cards={card_name_info[card][1],card_name_info[card][2]}
                    , type = obj_type
                    , repeat_cnt= 1
                    , card_cnt = 2
                    , value = cp.calcValue2(cc.PT_PAIR, card) }
                table.insert(hintList, cp.Encap(card_pattern))
            end
        end
        card_cnt = card_cnt + 1;
        if (pattern.value == 0) then
            break;
        end
    end

    local magicCards = card_name_info[cc.card_magic]
    local magic_cnt = #magicCards
    if magic_cnt > 0 and #hintList == 0 then 
        if magic_cnt == 1 and #hintList == 0 and pattern.value ~= 0 then 
            for _,card in ipairs(cc.SortedCardName) do
                local cnt = #card_name_info[card]
                if cnt == 1 and cp.calcValue2(cc.PT_PAIR, card) > pattern.value then
                    local card_pattern = {cards={card_name_info[card][1], magicCards[1]}
                        , type = obj_type
                        , repeat_cnt= 1
                        , card_cnt = 2
                        , value = cp.calcValue2(cc.PT_PAIR,card) }
                    table.insert(hintList, cp.Encap(card_pattern))
                end
            end
        end
    end

    return hintList
end

patternHints[cc.PT_CPAIR] = function(pattern, card_type_stat, card_name_info, card_name_stat, calc_bomb_pattern)
    local _,repeat_info = cc.StatRepeatInfo(card_name_info, 2, 3);
    return cp.NewPatternList(repeat_info, pattern)
end

local function doHintForBombs(bombSize, maxMagicCardFillCnt, pattern, card_name_info)
    local thePatternType = assert(cc["PT_BOMB"..bombSize], "不支持的炸弹长度:"..bombSize)
    local hintList = {}
    for _,cname in ipairs(cc.SortedCardName) do
        local cnt = #card_name_info[cname]
        local ptValue = cp.calcValue2(thePatternType, cname)
        if cnt == bombSize and ptValue > pattern.value then
            local cards = card_name_info[cname]
            local ptVector = {cards=cards, type=thePatternType, repeat_cnt=1, card_cnt=#cards, value=ptValue }
            table.insert(hintList, cp.Encap(ptVector))
        end
    end
    
    local magic_cnt = #card_name_info[cc.card_magic]
    if magic_cnt > 0 and #hintList == 0 then
        for i = 1, maxMagicCardFillCnt do
            if magic_cnt >= i then
                for _,cname in ipairs(cc.SortedCardName) do
                    local cnt = #card_name_info[cname]
                    local ptValue = cp.calcValue2(thePatternType, cname)
                    if (cnt == bombSize - i) and ptValue > pattern.value then
                        local cards = cc.arrayClone(card_name_info[cname])
                        cc.appendMagicCard(cards, card_name_info[cc.card_magic], i)
                        local ptVector = { cards=cards, type=thePatternType, repeat_cnt=1, card_cnt=#cards, value=ptValue }
                        table.insert(hintList, cp.Encap(ptVector))
                    end
                end
            end
        end
    end
    return hintList
end

patternHints[cc.PT_BOMB3] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForBombs(3, 2, pattern, card_name_info)    
end

patternHints[cc.PT_BOMB4] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForBombs(4, 3, pattern, card_name_info)    
end

patternHints[cc.PT_BOMB5] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForBombs(5, 4, pattern, card_name_info)
end

patternHints[cc.PT_BOMB6] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForBombs(6, 4, pattern, card_name_info)
end

patternHints[cc.PT_BOMB7] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForBombs(7, 4, pattern, card_name_info)
end

patternHints[cc.PT_BOMB8] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForBombs(8, 4, pattern, card_name_info)
end

local function doHintFor510k(pattern, card_name_info, card_name_stat)
    if not pattern then 
        pattern = {type = cc.PT_N510K, card_cnt = 3, repeat_cnt=1, value = 0}
    end
    
    local hintList = {}
    local cards = {}
    cc.arrayAppend(cards, card_name_info[cc.card_5])
    cc.arrayAppend(cards, card_name_info[cc.card_10])
    cc.arrayAppend(cards, card_name_info[cc.card_K])
    cc.arrayAppend(cards, card_name_info[cc.card_magic])
    local patterns = cp.enumerate510kPatterns(cards, true)
    for _, pt in ipairs(patterns) do
        if pt.value > pattern.value then
            table.insert(hintList, pt)
        end
    end
    table.sort(hintList, function(a, b)
        return a.value < b.value
    end)

    return hintList
end

patternHints[cc.PT_N510K] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintFor510k(pattern, card_name_info, card_name_stat)
end

patternHints[cc.PT_P510K] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintFor510k(pattern, card_name_info, card_name_stat)
end

local function doHintForKingBomb(bombSize, pattern, card_name_stat, card_name_info)
    assert(bombSize>1 and bombSize<=4)
    local kingCards = card_name_info[cc.card_C]
    if #kingCards == 0 then
        kingCards = card_name_info[cc.card_magic]
    end
    if #kingCards ~= bombSize then
        return {}
    end

    local hintList = {}
    local thePatternType = cc["PT_BOMB_KING"..bombSize]
    local cards,logicCards = {}, {}
    local colorValue = 0
    for _, card in ipairs(kingCards) do
        local nc = cc.solveCard(card)
        if nc.color == cc.color_red_heart then
            colorValue = colorValue + 1
        end
        table.insert(cards, card)
        table.insert(logicCards, 0);
    end
    local ptVector = {
        cards = cards,
        logic_cards = logicCards,
        type = thePatternType,
        repeat_cnt=1,
        card_cnt=bombSize,
        value = cp.calcValue2(thePatternType, cc.card_C) + colorValue
    }

    if ptVector.value > pattern.value then        
        table.insert(hintList, cp.Encap(ptVector))
    end
    return hintList
end

patternHints[cc.PT_BOMB_KING2] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForKingBomb(2, pattern, card_name_stat, card_name_info)
end

patternHints[cc.PT_BOMB_KING3] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForKingBomb(3, pattern, card_name_stat, card_name_info)
end

patternHints[cc.PT_BOMB_KING4] = function(pattern, card_type_stat, card_name_info, card_name_stat)
    return doHintForKingBomb(4, pattern, card_name_stat, card_name_info)
end

--- 出牌提示 获取出牌提示的牌型集合迭代器
--@param pattern 被提示的牌型对象
--@param specPtTypes 指定待提示牌型类型列表
--@return 本cardSet对象能匹配上的版型迭代器,能匹配牌型个数
function CardSet:hintIterator(pattern, specPtTypes)
    local card_type_stat,card_name_info,card_name_stat=cc.InitParse(self.cards)
    --print("***\ncard_type_stat:"..cjson.encode(card_type_stat).."\ncard_name_info:"..cjson.encode(card_name_info).."\ncard_name_stat:"..cjson.encode(card_name_stat).."\n***")
    local cnt = {};
    local pos = {};
    local used_magic_cnt = {};
    for i=1, cc.MAX_PATTERN do
        table.insert(cnt, 0);
    end
    local pattern_set = {};
    if pattern == nil then 
        local pattern_set_full = doHintAll(card_type_stat, card_name_info, card_name_stat, self.card_cnt);
        for _,pt in ipairs(pattern_set_full) do
            cnt[pt.type] = cnt[pt.type] + 1;
            if specPtTypes then
                for _,st in ipairs(specPtTypes) do
                    if pt.type == st then 
                        table.insert(pattern_set, pt);
                    end
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
        if pattern.type > cc.MAX_PATTERN then
            return nil;
        end
        pattern_set = doHint(pattern, card_type_stat, card_name_info, card_name_stat, self.card_cnt)
    end
	local index = 0
    if not pattern_set or #pattern_set == 0 then
        return nil;
    end
    if not specPtTypes then 
        local new_pattern_set = {};
        for ix, selected_type in ipairs(cp.sortedPatternSeqs) do
            for ix,pt in ipairs(pattern_set) do
                if pt.type == selected_type then
                    table.insert(new_pattern_set, pt);
                end
            end
        end
        pattern_set = new_pattern_set;    
    end
	return function ()
		index = index % (#pattern_set) + 1
		return pattern_set[index]
	end, (#pattern_set)
end

--洗牌函数
function CardSet.shuffle(excludeCards, randomseed)
    local randomseed = randomseed or 11
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6))+tonumber(randomseed)*10)
    
    local cards = {}
    for i=1, cc.DECKS_OF_CARDS do
        cc.arrayAppend(cards, cc.generateOneDeckCards(excludeCards))
    end
	
	local randomIdxs = cc.GenerateRandomSequence(#cards);
	local randomCards={}
	for _,i in ipairs(randomIdxs) do
		table.insert(randomCards, cards[i])
	end
	return randomCards
end

--发牌
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
	return {CardSet.new(player_cards[1])
		  ,CardSet.new(player_cards[2])
		  ,CardSet.new(player_cards[3])
		  ,CardSet.new(player_cards[4])}
end

-- 出牌
function CardSet:discard(card_pattern_object)
    local cards = {};
    cards = cc.Combine(cards, self.cards);
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

---在牌集合中的不成对(不同点数或不同花色)的单牌中随机选择一张牌(除了王牌)
function CardSet:selectSingleCard()
    local cards = self.cards
    local cardCntMap = {}
    for _, c in ipairs(cards) do
        local n = cardCntMap[c] or 0
        cardCntMap[c] = n + 1
    end
    local singleCards = {}
    for c, n in pairs(cardCntMap) do
        if n == 1 and c ~= 53 and c ~= 54 then
            table.insert(singleCards, c)
        end
    end
    if #singleCards > 0 then
        local i = math.random(1, #singleCards)
        return singleCards[i]
    end
    return nil
end

function CardSet:max_val_card()
    local max = 0;
    for _,c in ipairs(self.cards) do
        if (max == 0 or cc.getCardValue(c,0) > cc.getCardValue(max,0)) and (not cc.IsMagic(c)) then
            max = c
        end
    end
    return max;
end

return CardSet