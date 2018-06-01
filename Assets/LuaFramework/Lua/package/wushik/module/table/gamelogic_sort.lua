local cc = require('package.wushik.module.table.gamelogic_common')
local cp = require('package.wushik.module.table.gamelogic_pattern')
--local cc = require "gamelogic_common"
--local cp = require "gamelogic_pattern"
--local cjson = {encode = function() return "" end}
local cjson = require "cjson"

local CardSort = {}

---按大王、小王顺序排列
local function bigLittleKingOrder(a, b)
	return a > b
end

---组合出正510k的牌型升序在前和其他按牌值升序的序列
--@return 不改变入参内部顺序，以返回值输出
local function composePure510kPatternsOrderArray(cards510k)
    local originalLen = #cards510k
    local pts = cp.enumerate510kPatterns(cards510k)
    --按黑红梅方排序
    table.sort(pts, function(a, b)
        return a.color < b.color
    end)
	local pureCards = {}
    for _, pt in ipairs(pts) do
		if pt.sameColor then
            --按K,10,5顺序追加
            for j = #pt.cards, 1, -1 do
                table.insert(pureCards, pt.cards[j])
            end
		end
    end
    local others = cards510k
    if #pureCards > 0 then
        others = cc.arraySubtract(cards510k, pureCards)
    end
	cc.sortByValue(others, false)
    cc.arrayAppend(pureCards, others)
    assert(originalLen == #pureCards, "510K组合程序错误，原输入长："..originalLen..", 组合后："..#pureCards)
	return pureCards
end

---按指定序列排序：{正510k}>K>10>5>大王>小王>2>A>Q>J>9>8>7>6>4>3
--@param cards 待排序牌列表
function CardSort.sortBySpec(cards)
    local l1 = #cards
	local cards510k = {}
	local kingCards = {}
	local i = 1
	while i <= #cards do
		local c = cards[i]
		local cn = cc.getCardName(c)
		if cn == cc.card_5 or cn == cc.card_10 or cn == cc.card_K then
			table.insert(cards510k, c)
			table.remove(cards, i)
		elseif cn == cc.card_C then
			table.insert(kingCards, c)
			table.remove(cards, i)
		else
			i = i + 1
		end
	end

	cards510k = composePure510kPatternsOrderArray(cards510k)
	table.sort(kingCards, bigLittleKingOrder)
	cc.sortByValue(cards, false)
	for i, c in ipairs(kingCards) do
		table.insert(cards, i, c)
	end
	for i, c in ipairs(cards510k) do
		table.insert(cards, i, c)
    end
    local l2 = #cards
    assert(l1 == l2, "排序处理后的长度与排序前不一致，原来："..l1..",排序后："..l2..","..cjson.encode(cards))
	return cards
end

---按指定序列排序：从左至右为，炸弹>对子>单牌，每个牌型分别按当前规则下的大小从左至右排列（【王】摆放在4条炸和3条炸之间，按4条炸>大王>小王>3条炸的顺序）
function CardSort.sortBySpec1(cards)
	local originalLen = #cards
	local _, cardsByName, _ = cc.InitParse(cards)
	local cardInfos = {}
	for cardName, cards in pairs(cardsByName) do
		if cardName ~= cc.card_C and cardName ~= 0 then
			table.insert(cardInfos, {name=cardName, cards=cards, count=#cards})
		end
	end
	table.sort(cardInfos, function(a, b)
		if a.count == b.count then
			return cc.CardValue[a.name] > cc.CardValue[b.name]
		else
			return a.count > b.count
		end
	end)

	--由于InitParse()方法与是否启用癞子牌有关系，所以王牌(癞子牌)需要单独处理
	local kingCards = {}
	for _, c in ipairs(cards) do
		if cc.isKingCard(c) then
			table.insert(kingCards, c)
		end
	end
	--按大王、小王顺序排列
	table.sort(kingCards, bigLittleKingOrder)
	
	local specCards = {}
	local kingsAppend = false
	for _, cardInfo in ipairs(cardInfos) do
		if cardInfo.count < 4 and not kingsAppend and #kingCards > 0 then
			cc.arrayAppend(specCards, kingCards)
			kingsAppend = true
		end
		cc.arrayAppend(specCards, cardInfo.cards)
	end
	cc.arrayClear(cards)
	cc.arrayAppend(cards, specCards)
	if not kingsAppend and #kingCards > 0 then
		cc.arrayAppend(cards, kingCards)
	end
	assert(originalLen == #cards, "程序错误：排序后的数组长度与原数组长度不相等，原长:"..originalLen.." 现长:"..#cards)
	return cards
end

---按指定序列排序：大王>小王>2>A>K>Q>J>10>9>8>7>6>5>4>3
function CardSort.sortBySpec2(cards)
	local kingCards = {}
	local i = 1
	while i <= #cards do
		local c = cards[i]
		local cn = cc.getCardName(c)
		if cn == cc.card_C then
			table.insert(kingCards, c)
			table.remove(cards, i)
		else
			i = i + 1
		end
	end
	table.sort(kingCards, bigLittleKingOrder)
	cc.sortByValue(cards, false)
	for i, c in ipairs(kingCards) do
		table.insert(cards, i, c)
	end
	return cards
end

return CardSort
