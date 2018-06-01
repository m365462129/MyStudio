local cc = require('package.wushik.module.table.gamelogic_common')
--local cc = require "gamelogic_common"
--local cjson = {encode = function() return "" end}
local cjson = require "cjson"

-- 牌名索引 （牌名-1）* 4 + 花色, 前端收到的永远只是牌名索引，但可通过牌名索引计算出牌名与花色
-- 前后端及传输协议中保存的都是牌名索引
-- 牌型类
local CardPattern={}
local cp = CardPattern

CardPattern.card_cnt = 0

--------------------------
local CARD_PATTERN_TEXTS = {"单牌","对子","连对","顺子","三炸","四炸","五炸","六炸","七炸","八炸","副五十K","正五十K","对王炸","三王炸","四王炸"}
local NORMAL_PATTERNS = {cc.PT_SINGLE,cc.PT_PAIR,cc.PT_CPAIR,cc.PT_STRAIGHT}
local BOMB_PATTERNS = {cc.PT_BOMB3,cc.PT_BOMB4,cc.PT_BOMB5,cc.PT_BOMB6,cc.PT_BOMB7,cc.PT_BOMB8,cc.PT_N510K,cc.PT_P510K,cc.PT_BOMB_KING2,cc.PT_BOMB_KING3,cc.PT_BOMB_KING4}

CardPattern.CARD_PATTERN_TEXTS = CARD_PATTERN_TEXTS

local function toString(p)
    assert(p)
    return CARD_PATTERN_TEXTS[p.type]..'('..p.type..','..#p.cards..','..p.value..','..p.repeat_cnt..')'
end

local function isNormalPattern(ptValue)
    return cc.arrayIndexOf(NORMAL_PATTERNS, ptValue) ~= nil
end

--黄石玩法：3条<4条<5条<杂五十K<正五十K<6条<对王（杂王）<7条<3王<8条<4王
local bombPatternCompSeqs1 = {cc.PT_BOMB3,cc.PT_BOMB4,cc.PT_BOMB5,cc.PT_N510K,cc.PT_P510K,cc.PT_BOMB6,cc.PT_BOMB_KING2,cc.PT_BOMB7,cc.PT_BOMB_KING3,cc.PT_BOMB8,cc.PT_BOMB_KING4}
--大冶玩法：3条<4条<5条<6条<7条<杂五十K<正五十K<对王（杂王）<3王<8条<4王
local bombPatternCompSeqs2 = {cc.PT_BOMB3,cc.PT_BOMB4,cc.PT_BOMB5,cc.PT_BOMB6,cc.PT_BOMB7,cc.PT_N510K,cc.PT_P510K,cc.PT_BOMB_KING2,cc.PT_BOMB_KING3,cc.PT_BOMB8,cc.PT_BOMB_KING4}

local dontBeatSelfPatterns = {cc.PT_N510K,cc.PT_BOMB_KING3,cc.PT_BOMB_KING4}
local function cantBeatSelf(pt)
    for _,v in ipairs(dontBeatSelfPatterns) do
        if pt == v then
            return true
        end
    end
    return false
end

---确定牌型大小的比较序列
--@param useComp1 是否使用第1种（黄石玩法）牌型大小比较序列
--@return patternCompMap, patternSeqText
function CardPattern.confirmPatternCompareSeqs(useComp1)
    local patternCompMap = {}
    for _,pt in ipairs(cc.PATTERNS) do
        if cantBeatSelf(pt) then
            patternCompMap[pt] = {}
        else
            patternCompMap[pt] = {pt}
        end
    end

    local bombPatternCompSeqs = useComp1 and bombPatternCompSeqs1 or bombPatternCompSeqs2
    local seqsLen = #bombPatternCompSeqs
    for aPt, bPts in pairs(patternCompMap) do
        if isNormalPattern(aPt) then
            cc.arrayAppend(bPts, bombPatternCompSeqs)
        else
            local index = cc.arrayIndexOf(bombPatternCompSeqs, aPt)
            if index < seqsLen then
                index = index + 1
                cc.arrayAppend(bPts, bombPatternCompSeqs, index)
            end 
        end
    end
    CardPattern.patternCompaleMap = patternCompMap
    CardPattern.sortedPatternSeqs = cc.arrayAppend({cc.PT_SINGLE,cc.PT_PAIR,cc.PT_CPAIR,cc.PT_STRAIGHT}, bombPatternCompSeqs)
    local ptTexts = {}
    for _, pt in ipairs(CardPattern.sortedPatternSeqs) do
        table.insert(ptTexts, CARD_PATTERN_TEXTS[pt]..'('..pt..')')
    end
    return patternCompMap, table.concat(ptTexts, '<')
end

---牌型匹配列表，每个索引对应的元素是索引代表的牌型可匹配(被吃起)的列表
CardPattern.patternCompaleMap= {}

--默认使用黄石玩法的牌型比较
CardPattern.confirmPatternCompareSeqs(true)

---牌型对象工厂方法
--@param cards 组成牌型的牌列表
--@param logic_cards 确定的使用癞子充当的牌
--@param handCardCnt 构造牌型对象时手牌的张数
function CardPattern.new(cards, logic_cards, handCardCnt)
    if (cards == nil) then
        return nil;
    end;
    --TODO: 校验cards值的正确性：在牌索引的范围内
    if type(cards) ~= "table" then
        cards = {cards}
    end

    if (#cards < 1) then
        return nil;
    end
        
    local pt = {};
    setmetatable(pt, {__index = CardPattern, __tostring = toString})
    pt.cards = {}
    pt.logic_cards = {}
    pt.color = cc.color_unkown
    for i,c in ipairs(cards) do
		table.insert(pt.cards, c)
        table.insert(pt.logic_cards, 0);
    end
    pt.card_cnt = #pt.cards
    pt.handCardCnt = handCardCnt
    
    local card_type_stat,card_name_info,card_name_stat=cc.InitParse(pt.cards)
    --print("card_type_stat:"..cjson.encode(card_type_stat).."\ncard_name_info:"..cjson.encode(card_name_info).."\ncard_name_stat:"..cjson.encode(card_name_stat))
    local patterns = nil
    if pt.card_cnt <= #CardPattern.parsers then
        patterns =  CardPattern.parsers[pt.card_cnt](pt, card_name_stat, card_name_info, card_type_stat)
    else
        if not patterns then
            --8炸
            patterns = CardPattern.parsers[8](pt, card_name_stat, card_name_info, card_type_stat)
        end
        if not patterns and pt.card_cnt % 2 == 0 then            
            --连对
            patterns = CardPattern.parsers[6](pt, card_name_stat, card_name_info, card_type_stat)
        end
        if not patterns then
            --顺子
            patterns = CardPattern.parsers[3](pt, card_name_stat, card_name_info, card_type_stat)
        end
        if not patterns then
            return nil
        end
    end

    return patterns;
end

function CardPattern.NewPatternList(info_list, pattern)
    local pattern_list = {}
    if not info_list then
        return nil;
    end
    for _,info in ipairs(info_list) do
        if info.repeat_cnt >= pattern.repeat_cnt and cp.calcValue1(pattern.type, info.value) > pattern.value then
            local begin_ix = 1;
            for end_ix = pattern.repeat_cnt, info.repeat_cnt do
                local real_card = (info.card_start + end_ix - 1 - 1 ) % cc.max_normal_card_name + 1
                local pattern_value = cp.calcValue2(pattern.type, real_card)
                if pattern_value > pattern.value then
                    local new_pattern = {cards={},logic_cards={},type=pattern.type,repeat_cnt=pattern.repeat_cnt,value=pattern_value}
                    for ix=begin_ix, end_ix do
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
                end
                begin_ix = begin_ix + 1;
            end
        end
    end
    return pattern_list
end

function CardPattern.Encap(obj)
    setmetatable(obj, {__index=CardPattern, __tostring = toString})
    if not obj.logic_cards then
        obj.logic_cards = {}
        for _, c in pairs(obj.cards) do
            table.insert(obj.logic_cards, 0)
        end
    end
    return obj;
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
function CardPattern:compable(ptObj)
	assert((self.type > cc.PT_UNKNOWN and self.type <= cc.MAX_PATTERN) )
    if (ptObj == nil) then
        return false;
    end
    
    local compReqs = CardPattern.patternCompaleMap[ptObj.type]
    for _, type in pairs(compReqs) do
        --我(self)在你(ptObj)的牌型匹配列表里面吗？
        if (type == self.type) then
            if (type == cc.PT_STRAIGHT or type == cc.PT_CPAIR) and self.card_cnt ~= ptObj.card_cnt then
                return false
            end
            return true;
        end
    end
    return false;
end

-- 判断两次出牌的大小 小于等于返回真，否则返回假
function CardPattern:le(ptObj)
	assert(ptObj ~= nil, "被比较的ptObj为nil")
	-- 调用此函数之前必须先调用compable
    assert(self:compable(ptObj), "牌型'"..tostring(self).."'<"..self.card_cnt..">不能与牌型'"..tostring(ptObj).."'<"..ptObj.card_cnt..">比较")
    if (self.type == ptObj.type) then
        local d = self.value - ptObj.value
        return d <= 0, d == 0;
    else
        return false;
    end
end

function CardPattern:clone()
    local o = {};
    setmetatable(o, {__index=CardPattern})
    o.card_cnt = self.card_cnt;
    o.cards = {};
    cc.Combine(o.cards, self.cards);
    o.logic_cards = {};
    cc.Combine(o.logic_cards, self.logic_cards);
    o.type = self.type;
    o.value = self.value;
    o.repeat_cnt = self.repeat_cnt;
    return o;
end

function CardPattern:update_logic_cards(logic_card_name, color)
    local loop = 1;
    for ix,c in ipairs(self.cards) do
        if loop > #logic_card_name then
            return;
        end
        self.logic_cards[ix] = 0;
        if cc.isMagicCard(c) then 
            if color and color > 0 then 
                self.logic_cards[ix] = cc.makeCard(logic_card_name[loop],color);
            else
                self.logic_cards[ix] = cc.makeCard(logic_card_name[loop],cc.color_red_heart);
            end
            loop = loop + 1
        end
    end
end

---返回牌型中5、10、k的张数
--@return {
--  "5" = cnt,
--  "10" = cnt,
--  "k" = cnt
--}
function CardPattern:count510kCards()
    assert(self.cards)
    local _,card_name_info,card_name_stat=cc.InitParse(self.cards)
    return {
        ["5"] = card_name_stat[cc.card_5],
        ["10"] = card_name_stat[cc.card_10],
        ["k"] = card_name_stat[cc.card_K],
    }
end

---计算牌型的值
local function patternValueFormula(ptWeight, cardValue)
    assert(ptWeight, "ptWeight参数不能为nil")
    assert(cardValue, "cardValue参数不能为nil")
    return 100 * ptWeight + cardValue
end

---计算指定牌型类型和牌索引值的牌型值
local function calcValue(ptType, cardIdx, plusColorValue)
    local idx = cc.arrayIndexOf(cp.sortedPatternSeqs, ptType)
    if not idx then
        return 0
    end
    local v = cc.getCardValue(cardIdx, plusColorValue)
    return patternValueFormula(idx, cc.getCardValue(cardIdx, plusColorValue))
end

---计算指定牌型类型和牌值相加的牌型值
local function calcValue1(ptType, cardValue)
    local idx = cc.arrayIndexOf(cp.sortedPatternSeqs, ptType)
    if not idx then
        return 0
    end
    return patternValueFormula(idx, cardValue)
end

---计算指定牌型类型和牌名组合的牌型值
local function calcValue2(ptType, cardName)
    local idx = cc.arrayIndexOf(cp.sortedPatternSeqs, ptType)
    if not idx then
        return 0
    end
    return patternValueFormula(idx, cc.getCardValueByName(cardName))
end

CardPattern.calcValue = calcValue
CardPattern.calcValue1 = calcValue1
CardPattern.calcValue2 = calcValue2

CardPattern.parsers={}

function CardPattern.parse1Cards(o, card_name_stat, card_name_info, card_type_stat)
    if cc.isMagicCard(o.cards[1]) and o.handCardCnt ~= 1 then
        --癞子牌，即王牌不能单独打出，除非是手牌的最后一张牌
        return nil
    end
    o.type = cc.PT_SINGLE
    o.value = calcValue(o.type, o.cards[1])
    local nc = cc.solveCard(o.cards[1])
    if nc.name == cc.card_C and nc.color == 2 then
        o.value = o.value + 1
    end
	o.repeat_cnt = 1
	return {o}
end
CardPattern.parsers[1] = CardPattern.parse1Cards;

local function tryDealKingBombPattern(bombSize, ptObj)
    assert(bombSize>=2 and bombSize<=4, "王炸的牌张数必须在[2,4]")
    if bombSize ~= #ptObj.cards then
        return false
    end
    local colorValue = 0
    for _,c in ipairs(ptObj.cards) do
        local nc = cc.solveCard(c)
        if nc.name ~= cc.card_C then
            return false
        end
        if nc.color == cc.color_red_heart then
            colorValue = colorValue + 1
        end
    end

    ptObj.type = cc["PT_BOMB_KING"..bombSize]
    ptObj.value = calcValue2(ptObj.type, cc.card_C) + colorValue
    ptObj.repeat_cnt = bombSize
    ptObj.isBomb = true
    return true
end

function CardPattern.parse2Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDealKingBombPattern(2, o) then
        return {o}
    end

    o.type = cc.PT_PAIR
    o.repeat_cnt = 1
    local magic_cnt = card_name_stat[cc.card_magic];
    if (#card_type_stat[2]) > 0 then
        o.value = calcValue(o.type, o.cards[1]);
    elseif (#card_type_stat[1]) > 0 and magic_cnt == 1 then
        o.value = calcValue(o.type, o.cards[1]);
        o:update_logic_cards({card_type_stat[1][1]});
    else
        return nil;
    end
	return {o}
end
CardPattern.parsers[2] = CardPattern.parse2Cards;

local MAX_BOMB_SIZE = 8

local function tryDealBombPattern(bombSize, ptObj, card_name_stat, card_name_info, card_type_stat)
    local cardCnt = #ptObj.cards
    if cardCnt <= MAX_BOMB_SIZE and cardCnt ~= bombSize then
        return false
    end
    
    local magic_cnt = card_name_stat[cc.card_magic]
    --print(bombSize, "magic_cnt: "..magic_cnt, "cards size:"..cardCnt)
    ptObj.type = cc["PT_BOMB"..bombSize]
    ptObj.repeat_cnt = 1;
    ptObj.card_cnt = cardCnt
    ptObj.value = calcValue(ptObj.type, ptObj.cards[1])
    if magic_cnt == 0 then
        if cardCnt > MAX_BOMB_SIZE then
            return false
        end
        if #card_type_stat[bombSize] == 0 then
            return false
        end
    else
        local i = (cardCnt > MAX_BOMB_SIZE and cardCnt or bombSize) - magic_cnt
        assert(i > 0)
        --print(i, cjson.encode(card_type_stat))
        if i > #card_type_stat or #card_type_stat[i] == 0 then
            return false
        end
        local cardName = card_type_stat[i][1]
        local logicCards = {}
        for k = 1, magic_cnt do
            logicCards[#logicCards+1] = cardName
        end
        --TODO: 被代替的逻辑牌需要考虑花色的正确性
        ptObj:update_logic_cards(logicCards);
    end
    ptObj.isBomb = true
    return true
end

local function pickCard(cards, toPickCardName, toPickCardColor)
    assert(cards)
    assert(toPickCardName)
    local i = 1
    while i <= #cards do
        local card = cards[i]
        local nc = cc.solveCard(card)
        local eq = false
        if toPickCardColor and toPickCardColor > 0 then
            eq = nc.name == toPickCardName and nc.color == toPickCardColor
        else
            eq = nc.name == toPickCardName
        end
        if eq then
            card = table.remove(cards, i)
            --print("** pick card: "..card..", nc: "..cjson.encode(nc))
            return nc, i, card
        end
        i = i + 1
    end
    return nil
end

---按5、10、K分组牌
--@param cards 必须只包含5、10、K的牌
--@param colorFirst 是否按颜色优先分组
local function group510k(cards, colorFirst)
    --按花色优先分拣5、10、K
    local pt510ks = {}
    local colorBegin, colorEnd = 1, 4
    if not colorFirst then
        colorBegin, colorEnd = 0, 0
    end
    while #cards > 0 do
        for c=colorBegin, colorEnd do
            local pt510k = {cards={}, color=c, missCardNames={}, logicCardNames={}}
            for _, n in ipairs(cc.SEQS_510k) do
                local nc, j, card = pickCard(cards, n, c)
                if nc then
                    table.insert(pt510k.cards, card)
                else
                    table.insert(pt510k.missCardNames, n)
                end
            end
            table.insert(pt510ks, pt510k)
        end
    end
    return pt510ks
end

local function fillMissCardNameUseMagicCard(pt, magicCards)
    local fillCnt = 0
    while #pt.missCardNames > 0 do
        local n = pt.missCardNames[#pt.missCardNames]
        if #magicCards > 0 then
            table.insert(pt.logicCardNames, n)
            table.insert(pt.cards, table.remove(magicCards))
            table.remove(pt.missCardNames)
            fillCnt = fillCnt + 1
        else
            break
        end
    end
    return fillCnt
end

local function filter510kCards(cards)
    local cards510k = {}
    for _, c in ipairs(cards) do
        local n = cc.getCardName(c)
        if n == cc.card_5 or n == cc.card_10 or n == cc.card_K then
            table.insert(cards510k, c)
        end
    end
    return cards510k
end

local function wrapTo510kPatternObjs(ptScales)
    --构造成CardPattern对象
    local ptObjs = {}
    for _, pt in ipairs(ptScales) do
        pt.type = pt.sameColor and cc.PT_P510K or cc.PT_N510K
        pt.card_cnt = #pt.cards
        pt.repeat_cnt = 3
        --正五十K大小顺序：
        --1）相同花色下，正五十K（不带癞子）>正五十K（带癞子）
        --2）花色不同，大小顺序为：黑桃正五十K（不带癞子）>黑桃正五十K（带癞子）>红桃正五十K（不带癞子）……>方块正五十K（带癞子）
        local value = calcValue2(pt.type, cc.card_K)
        if pt.sameColor then
            --正五十K
            value = value + (4 - pt.color + 1)
            if #pt.logicCardNames > 0 then
                value = value - 1
            end
            --else 副五十K无论是否带癞子，大小相同
        end
        pt.value = value
        local ptObj = cp.Encap(pt)
        ptObj:update_logic_cards(pt.logicCardNames, pt.color);
        table.insert(ptObjs, ptObj)
    end
    return ptObjs
end

---枚举给定的牌的510k牌型组合，包括癞子牌情况的510K， 5Tx,5xK,xTK(按花色分正负) 杂的 5xx,xxK,xTx
--@param cards 牌索引列表
--@param returnActurePatternObj
--@return 510k牌型组合列表
local function enumerate510kPatterns(aCards, returnActurePatternObj)
    local magicCards = cc.findMagicCards(aCards)
    local cards = filter510kCards(aCards)
    if #cards + #magicCards < 3 then
        return {}
    end

    --按花色优先分组5、10、K
    local pt510ks = group510k(cards, true)
    --按缺失牌的个数倒序
    table.sort(pt510ks, function(a, b)
        return #a.missCardNames > #b.missCardNames
    end)
    --print("pt510ks: "..#pt510ks..","..cjson.encode(pt510ks))
    --挑出正510K
    local pure510ks = {}
    for i = #pt510ks, 1, -1 do
        local pt = pt510ks[i]
        if #pt.missCardNames == 0 then
            pt.sameColor = true
            table.insert(pure510ks, table.remove(pt510ks, i))
        elseif #pt.missCardNames == 1 and #magicCards > 0 then
            fillMissCardNameUseMagicCard(pt, magicCards)
            pt.sameColor = true
            table.insert(pure510ks, table.remove(pt510ks, i))
        else
            break
        end
    end
    --print("pure510ks:"..#pure510ks..","..cjson.encode(pure510ks))
    --处理副510K
    cards = {}
    for i, pt in pairs(pt510ks) do
        cc.arrayAppend(cards, pt.cards)
    end
    
    local neg510ks = group510k(cards, false)
    --print("neg510ks:"..#neg510ks..","..cjson.encode(neg510ks))
    for _, pt in pairs(neg510ks) do
        if #pt.missCardNames == 0 then
            table.insert(pure510ks, pt)
        else
            if #magicCards == 0 then
                break
            end
            local mayPure = false
            if #pt.missCardNames == 2 then
                mayPure = true
            end
            --缺失的，使用癞子填充
            fillMissCardNameUseMagicCard(pt, magicCards)
            if #pt.missCardNames == 0 then
                if mayPure then
                    pt.sameColor = true
                    pt.color = cc.getCardColor(pt.cards[1])
                end
                table.insert(pure510ks, pt)
            end
        end
    end
    --print("510ks:"..#pure510ks..","..cjson.encode(pure510ks))

    if not returnActurePatternObj then
        return pure510ks
    end

    return wrapTo510kPatternObjs(pure510ks)
end

CardPattern.enumerate510kPatterns = enumerate510kPatterns

local function tryDeal510kPattern(ptObj, cardsByName)
    local cards = ptObj.cards
    if #cards ~= 3 then
        return false
    end
    if #cardsByName[cc.card_magic] > 2 then
        return false
    end

    local array = enumerate510kPatterns(ptObj.cards, true)
    if #array == 0 then
        return false
    end
    local t = array[1]
    ptObj.type = t.type
    ptObj.repeat_cnt = t.repeat_cnt
    ptObj.color = t.color
    ptObj.logic_cards = t.logic_cards
    ptObj.value = t.value
    return true
end

local function tryDealStraightPattern(ptObj, card_name_stat, card_name_info)
    if #card_name_info[2] > 0 then
        --2不能包含在顺子内
        return false
    end
    if ptObj.card_cnt < 3 then
        return false
    end

    local max_repeat_info = cc.StatRepeatInfo(card_name_info, 1, ptObj.card_cnt)
    --print("max_repeat_info: "..cjson.encode(max_repeat_info))
    if not max_repeat_info then
        return false
    end
    ptObj.type = cc.PT_STRAIGHT
    ptObj.value = calcValue1(ptObj.type, max_repeat_info.value)
    ptObj.repeat_cnt = max_repeat_info.repeat_cnt;
    ptObj:update_logic_cards(max_repeat_info.logic_cards);
    return true
end

local function tryDealCpairPattern(ptObj, card_name_stat, card_name_info)
    if #card_name_info[2] > 0 then
        --2不能包含在三连对内
        return false
    end
    if ptObj.card_cnt % 2 ~= 0 then
        return false
    end

    local pairCnt = ptObj.card_cnt / 2
    local max_repeat_info = cc.StatRepeatInfo(card_name_info, 2, pairCnt);
    if not max_repeat_info then 
        return false
    end
    ptObj.type = cc.PT_CPAIR;
    ptObj.value = calcValue1(ptObj.type, max_repeat_info.value)
    ptObj.repeat_cnt = max_repeat_info.repeat_cnt;
    ptObj:update_logic_cards(max_repeat_info.logic_cards);
    return true
end

function  CardPattern.parse3Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDeal510kPattern(o, card_name_info) then
        return {o}
    end

    if tryDealKingBombPattern(3, o) then
        return {o}
    end

    if tryDealBombPattern(3, o, card_name_stat, card_name_info, card_type_stat) then
        return {o}
    end

    if tryDealStraightPattern(o, card_name_stat, card_name_info) then
        return {o}
    end
    return nil;
end
CardPattern.parsers[3] = CardPattern.parse3Cards

function CardPattern.parse4Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDealKingBombPattern(4, o) then
        return {o}
    end
    
    if tryDealBombPattern(4, o, card_name_stat, card_name_info, card_type_stat) then
        return {o}
    end

    if tryDealStraightPattern(o, card_name_stat, card_name_info) then
        return {o}
    end

	return nil
end
CardPattern.parsers[4] = CardPattern.parse4Cards

function CardPattern.parse5Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDealBombPattern(5, o, card_name_stat, card_name_info, card_type_stat) then
        return {o}
    end

    if tryDealStraightPattern(o, card_name_stat, card_name_info) then
        return {o}
    end

	return nil
end
CardPattern.parsers[5] = CardPattern.parse5Cards

function CardPattern.parse6Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDealBombPattern(6, o, card_name_stat, card_name_info, card_type_stat) then
        return {o}
    end

    if tryDealCpairPattern(o, card_name_stat, card_name_info) then
        return {o}
    end
    
    if tryDealStraightPattern(o, card_name_stat, card_name_info) then
        return {o}
    end

    return nil;
end 
CardPattern.parsers[6] = CardPattern.parse6Cards

function CardPattern.parse7Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDealBombPattern(7, o, card_name_stat, card_name_info, card_type_stat) then
        return {o}
    end
    if tryDealStraightPattern(o, card_name_stat, card_name_info) then
        return {o}
    end
    return nil
end 
CardPattern.parsers[7] = CardPattern.parse7Cards

function CardPattern.parse8Cards(o, card_name_stat, card_name_info, card_type_stat)
    if tryDealBombPattern(8, o, card_name_stat, card_name_info, card_type_stat) then
        return {o}
    end
    
    if tryDealCpairPattern(o, card_name_stat, card_name_info) then
        return {o}
    end

    if tryDealStraightPattern(o, card_name_stat, card_name_info) then
        return {o}
    end
    return nil;
end 
CardPattern.parsers[8] = CardPattern.parse8Cards

return CardPattern

