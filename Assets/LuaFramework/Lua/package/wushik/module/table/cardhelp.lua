local cc = require "package.wushik.module.table.gamelogic_common"
local cjson = require "cjson"

---字符串分割函数
--@param str 传入的字符串
--@param delimiter 分隔符
--@return 分割后的数组(table)
local function split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

---查找数组元素的位置
--@param array 数组
--@param element 待查找的元素
--@return 返回所在位置，没找到返回nil
local function arrayIndexOf(array, element)
    for i,v in ipairs(array) do
        if v == element then
            return i
        end
    end
end

local function join(array)
    return table.concat(array, ',')
end

local CARD_COLORS = {"S", "H", "C", "D"}
local CARD_NAMES = {"A","2","3","4","5","6","7","8","9","T","J","Q","K","C"}

---牌索引值对应的表示字符，如:'2-H'表示红桃2,对应的索值为6, 那传入6返回'2-H'
--@param cardIdx 牌索引或数组
--@param returnStrInsteadArray 如果cardIdx是数组，那么返回值是否返回字符串而不是数组
--@return 牌表示字符或对应数组
local function toText(cardIdx, returnStrInsteadArray)
    local func = function(cardIdx)
        assert(cardIdx, "cardIdx参数不能为nil")
        if type(cardIdx) ~= "number" then
            error("牌索值必须是数字")
        end
        local p,cardSeq = cc.solveCard(cardIdx);
        local a = {CARD_NAMES[p.name] or p.name, CARD_COLORS[p.color] or p.color}
        if cardSeq then
            table.insert(a, cardSeq)
        end
        return table.concat(a, '-')
    end

    if type(cardIdx) == "table" then
        local t = {}
        for _,v in ipairs(cardIdx) do
            t[#t+1] = func(v)
        end
        return returnStrInsteadArray and table.concat(t, ',') or t
    else
        return func(cardIdx)
    end
end

local function showText(cardIdx)
    print(join(toText(cardIdx)))
end

---牌表示字符对应的牌索引值，如：传入‘2-H’,返回6
--@param cardText 牌表示字符或数组
--@return 牌索引值或对应数组
local function toIndex(cardText)
    local func = function(cardText)
        assert(cardText, "cardText参数不能为nil")
        local array = split(string.upper(cardText), '-')
        if #array<2 then
            error("非法的牌字面表达式："..cardText)
        end
        local name, color, cardSeq = array[1], array[2], array[3] or 0
        local nameIdx, colorIdx = arrayIndexOf(CARD_NAMES, name), arrayIndexOf(CARD_COLORS, color)
        if not nameIdx then
            error("非法的牌名字符："..name)
        end
        if not colorIdx then
            error("非法的牌花色字符："..color)
        end
        return cc.makeCard(nameIdx, colorIdx, cardSeq)
    end

    if type(cardText) == "table" then
        local t = {}
        for _,v in ipairs(cardText) do
            t[#t+1] = func(v)
        end
        return t
    else
        return func(cardText)
    end
end

local function showIndex(cardText)
    print(join(toIndex(cardText)))
end

local CARD_PATTERN_TEXTS = {"单牌","对子","连对","顺子","三炸","四炸","五炸","六炸","七炸","八炸","副五十K","正五十K","对王炸","三王炸","四王炸"}

--牌型文本表示
--@param cardPattern 牌型对象或牌型对象数组
--@param showCardIdxs
--@return 表示文本
local function patternText(cardPattern, showCardIdxs)
    if not cardPattern then
        return '不支持的牌型'
    end

    local func = function(p, showCardIdxs)
        if not p then
            return '不支持的牌型'
        end
        local s = CARD_PATTERN_TEXTS[p.type]..'('..p.value..','..p.repeat_cnt..'):'..'['..toText(p.cards, true)..']';
        if p.logic_cards then
            s = s ..'('..join(toText(p.logic_cards))..')'
        end
        if showCardIdxs then
            s = s .. ';[' .. join(p.cards) .. ']'
            if p.logic_cards then
                s = s..'('..join(p.logic_cards)..')'
            end
        end
        return s
    end
    
    if type(cardPattern) == "table" and #cardPattern > 0 then
        local t = {}
        for _, p in ipairs(cardPattern) do
            t[#t+1] = func(p, showCardIdxs)
        end
        return table.concat(t, ' ')
    else
        return func(cardPattern, showCardIdxs)
    end
end

local function showPattern(cardPattern, showCardIdxs)
    print(patternText(cardPattern, showCardIdxs))
end

local function showHints(iterator, cnt)
    print((cnt or 0).." hints:")
    if not (iterator and cnt) then 
       return 
    end
    for i=1, cnt do
        print("  "..i..": "..patternText(iterator()))
    end
end

return {
    toText = toText,
    toIndex = toIndex,
    join = join,
    patternText = patternText,
    showText = showText,
    showIndex = showIndex,
    showPattern = showPattern,
    showHints = showHints
}
