

local cc = require "package.wushik.module.table.gamelogic_common"
local cp = require "package.wushik.module.table.gamelogic_pattern"
local ch = require "package.wushik.module.table.cardhelp"
local cjson = require "cjson"

local toIndex = ch.toIndex
local toText = ch.toText
local patternText = ch.patternText
local showPattern = ch.showPattern
local showHints = ch.showHints
local cardOf = cc.makeCard

local function newPattern(cards)
    if type(cards) ~= "table" then
        cards = {cards}
    end
    local pts = nil
    if type(cards[1]) == "string" then
        pts = cp.new(toIndex(cards))
    elseif type(cards[1]) == "number" then
        pts = cp.new(cards)
    end
    if not pts then
        return nil
    end
    return pts[1], #pts, pts
end

---cards2牌型能兼容cards1牌型吗？
local function comp(cards1, cards2)
    assert(cards1, "cards1参数不能为nil")
    assert(cards2, "cards2参数不能为nil")
    local p1=newPattern(cards1)
    local p2=newPattern(cards2)
    assert(p1, "cards1不支持的牌型")
    assert(p2, "cards2不支持的牌型")
    print(patternText(p2), "兼容", patternText(p1))
    return p2:compable(p1)
end

---cards1牌是否小于等于cards2牌，前提条件是cards2牌型能兼容card1牌型
local function le(cards1, cards2)
    assert(cards1, "cards1参数不能为nil")
    assert(cards2, "cards2参数不能为nil")
    local p1=newPattern(cards1)
    local p2=newPattern(cards2)
    assert(p1, "cards1不支持的牌型")
    assert(p2, "cards2不支持的牌型")
    print(patternText(p1), "<=", patternText(p2))
    if p2:compable(p1) then
        local isLe, isEq = p2:le(p1)
        return isEq and true or not isLe
    end
    print("牌型'"..patternText(p1).."'不支持匹配牌型'"..patternText(p2).."'")
    return false
end

---cards1牌是否大于cards2牌，前提条件是cards1牌型能兼容card2牌型
local function g(cards1, cards2)
    assert(cards1, "cards1参数不能为nil")
    assert(cards2, "cards2参数不能为nil")
    local p1=newPattern(cards1)
    local p2=newPattern(cards2)
    assert(p1, "cards1不支持的牌型")
    assert(p2, "cards2不支持的牌型")
    print(patternText(p1), ">", patternText(p2))
    if p1:compable(p2) then
        return not p1:le(p2)
    end
    print("牌型'"..patternText(p1).."'不支持匹配牌型'"..patternText(p2).."'")
    return false
end

local function assertPattern(cards, expectedText)
    expectedText = expectedText or "不支持的牌型"
    local ptTxts = {}
    local _, _, pts = newPattern(cards)
    if pts then
        print(cjson.encode(pts))
        for _, pt in pairs(pts) do
            table.insert(ptTxts, patternText(pt))
        end
    else
        table.insert(ptTxts, expectedText)
    end
    local s = table.concat(ptTxts, ";")
    if #ptTxts > 1 then
        print("**多组合牌型: "..s)
    end
    local i = s:find(expectedText)
    assert(i ~= nil, "牌型断言错误，期望:"..expectedText.."，实际:"..s)
end

local function printRepeatInfo(max_repeat_info, repeat_infos)
    print("max repeat: "..cjson.encode(max_repeat_info))
    for i, repeatInfo in ipairs(repeat_infos) do
        print(i..": "..cjson.encode(repeatInfo))
        print("  "..toText(repeatInfo.cards, true))
    end
end

local function testPatternParse()
    --癞子模式下
    cc.enableMagicCards(true)
    assertPattern({"K-s","c-s","c-h"},"正五十K")
    assertPattern("2-H","单牌")
    assertPattern({"2-H","3-H","4-s"})
    assertPattern({"2-H"},"单牌")
    assertPattern({"A-H"},"单牌")
    assertPattern({"2-H","2-S"},"对子")
    assertPattern({"3-H","4-s","5-H"},"顺子")
    assertPattern({"4-H","4-H","4-s"},"三炸")
    assertPattern({"C-H"})  --TODO: 癞子玩法要考虑最后一张牌是王牌也能打出
    assertPattern({"C-H","C-H"},"对王炸")
    assertPattern({"3-S","3-H","3-C"},"三炸")
    assertPattern({"t-s","t-c","t-d"},"三炸")
    assertPattern({"5-s","5-h","c-h"},"三炸")
    assertPattern({"5-H","T-C","K-D"},"五十K")
    assertPattern({"5-H","6-C","7-D"},"顺子")
    assertPattern({"5-H","6-C","C-S"},"顺子")
    assertPattern({"5-H","C-H","C-S"},"正五十K")

    assertPattern({"3-S","3-H","4-s","4-h","5-S","5-h"}, "连对")
    assertPattern({"9-S","9-S","T-h","T-s","J-s","J-C","Q-s","Q-h"}, "连对")
    assertPattern({"9-S","9-S","T-h","T-s","C-s","J-C","Q-s","Q-h"}, "连对")

    assertPattern({"5-H","C-H","C-S","5-S"},"四炸")
    assertPattern({"6-H","6-H","6-S","6-S"},"四炸")
    assertPattern({"C-H","C-H","C-S","C-S"},"四王炸")
    assertPattern({"5-H","6-H","7-S","8-S","9-H"},"顺子")
    assertPattern({"5-H","C-H","7-S","8-S","C-S"},"顺子")
    assertPattern({"5-H","5-H","5-S","5-S","5-C"},"五炸")
    assertPattern({"5-H","5-H","C-S","C-S","5-C"},"五炸")

    assertPattern({"5-H","5-H","6-S","6-S","7-C","7-S"},"连对")
    assertPattern({"5-H","6-S","7-C","8-S","9-H","C-H"},"顺子")
    assertPattern({"6-H","6-S","6-C","6-S","6-H","C-H"},"六炸")

    assertPattern({"6-H","6-S","6-C","6-S","6-H","6-D","6-D"},"七炸")
    assertPattern({"C-H","C-S","C-S","C-H","6-D","6-D","6-C"},"七炸")
    assertPattern({"3-H","4-S","5-S","6-H","7-D","8-D","9-C"},"顺子")
    assertPattern({"3-H","4-S","5-S","C-H","7-D","8-D","9-C"},"顺子")

    assertPattern({"6-H","6-S","6-C","6-C","6-S","6-H","6-D","6-D"},"八炸")

    assertPattern({"5-H","t-S","c-s"},"副五十K")
    assertPattern({"5-H","t-h","k-h"},"正五十K")
    assertPattern({"5-H","t-h","c-h"},"正五十K")
    assertPattern({"5-H","c-h","c-h"},"正五十K")
    assertPattern({"5-c","c-h","k-c"},"正五十K")
    assertPattern({"5-h","t-h","c-s"},"正五十K")
    assertPattern({"k-c","c-h","c-h"},"正五十K")
end

local function testPatternParse1()
    cc.enableMagicCards(false)
    assertPattern("2-H","单牌")
    assertPattern({"2-H","3-H","4-s"})
    assertPattern({"2-H"},"单牌")
    assertPattern({"A-H"},"单牌")
    assertPattern({"2-H","2-S"},"对子")
    assertPattern({"3-H","4-s","5-H"},"顺子")
    assertPattern({"4-H","4-H","4-s"},"三炸")
    assertPattern({"C-H"},"单牌")
    assertPattern({"C-H","C-H"},"对王炸")
    assertPattern({"3-S","3-H","3-C"},"三炸")
    assertPattern({"5-H","T-C","K-D"},"副五十K")
    assertPattern({"5-H","6-C","7-D"},"顺子")
    assertPattern({"5-H","6-C","C-S"})
    assertPattern({"5-H","C-H","C-S"},"正五十K")

    assertPattern({"2-h","q-s","k-s"})
    assertPattern({"2-h","a-s","k-s"})
    assertPattern({"q-h","k-s","a-s"}, "顺子")

    assertPattern({"3-S","3-H","4-s","4-h","5-S","5-h"}, "连对")
    assertPattern({"9-S","9-S","T-h","T-s","J-s","J-C","Q-s","Q-h"}, "连对")
    assertPattern({"9-S","9-S","T-h","T-s","C-s","J-C","Q-s","Q-h"})

    assertPattern({"5-H","C-H","C-S","5-S"})
    assertPattern({"6-H","6-H","6-S","6-S"},"四炸")
    assertPattern({"C-H","C-H","C-S","C-S"},"四王炸")
    assertPattern({"5-H","6-H","7-S","8-S","9-H"},"顺子")
    assertPattern({"5-H","C-H","7-S","8-S","C-S"})
    assertPattern({"5-H","5-H","5-S","5-S","5-C"},"五炸")
    assertPattern({"5-H","5-H","C-S","C-S","5-C"})

    assertPattern({"5-H","5-H","6-S","6-S","7-C","7-S"},"连对")
    assertPattern({"5-H","6-S","7-C","8-S","9-H","t-H"},"顺子")
    assertPattern({"6-H","6-S","6-C","6-S","6-H","C-H"})

    assertPattern({"6-H","6-S","6-C","6-S","6-H","6-D","6-D"},"七炸")
    assertPattern({"C-H","C-S","C-S","C-H","6-D","6-D","6-C"})
    assertPattern({"3-H","4-S","5-S","6-H","7-D","8-D","9-C"},"顺子")
    assertPattern({"3-H","4-S","5-S","C-H","7-D","8-D","9-C"})

    assertPattern({"6-H","6-S","6-C","6-C","6-S","6-H","6-D","6-D"},"八炸")
    assertPattern({"5-H","t-S","k-C"},"副五十K")
    assertPattern({"5-H","t-h","k-h"},"正五十K")
end

local function testSinglePatternCompare()
    cc.enableMagicCards(false)
    cp.confirmPatternCompareSeqs(false)
    assert(le("3-H", "4-S"))
    assert(le("4-H", "4-S"))
    assert(g("4-H", "3-S"))
    assert(le("K-S","2-S"))
    assert(le("A-S","2-S"))
    assert(not comp({"3-H","3-S"}, "3-H"))
    assert(not comp("3-H", {"3-H","3-S"}))
    assert(g({"4-S","4-H","4-C"}, "3-D"))
    assert(g({"3-S","3-H","3-C"}, "2-H"))
    assert(not comp("2-H", {"3-S","4-H","5-C"}))
    assert(not comp({"5-S","T-H","K-C"}, "2-H"))
    assert(comp("2-H", {"C-S","C-H"}))
    assert(comp("2-H", {"6-H","6-H","6-S","6-S"}))
end

local function testPairPatternCompare()
    cc.enableMagicCards(false)
    cp.confirmPatternCompareSeqs(false)
    assert(le({"3-S","3-H"},{"5-S","5-S"}))
    assert(le({"K-s","K-h"},{"A-s","A-c"}))
    assert(comp({"2-s","2-h"},{"C-s","C-h"}))
    assert(g({"C-s","C-h"},{"2-s","2-h"}))
    assert(comp({"2-s","2-h"},{"6-H","6-H","6-S","6-S"}))
    assert(g({"6-H","6-H","6-S","6-S"},{"2-s","2-h"}))
    assert(not comp({"2-H","2-C"}, {"3-S","4-H","5-C"}))
end

local function testStraightPatternCompare()
    cc.enableMagicCards(false)
    cp.confirmPatternCompareSeqs(false)
    assert(le({"3-S","4-H","5-S"},{"4-S","5-S","6-h"}))
    assert(not comp({"3-S","4-H","5-S"},{"3-S","4-S","5-S","6-h"}))
    assert(comp({"3-S","4-H","5-S"},{"3-S","3-S","3-h"}))
    assert(g({"3-S","3-S","3-h"},{"3-S","4-H","5-S"}))
end

local function testCpairPatternCompare()
    cc.enableMagicCards(false)
    cp.confirmPatternCompareSeqs(false)
    assert(le({"3-S","3-H","4-s","4-h","5-S","5-h"},{"9-S","9-S","T-h","T-s","J-s","J-C"}))
    assert(not comp({"3-S","3-H","4-s","4-h","5-S","5-h"},{"9-S","9-S","T-h","T-s","J-s","J-C","Q-s","Q-h"}))
end

local function testBombPatternCompare()
    cc.enableMagicCards(false)
    cp.confirmPatternCompareSeqs(false)
    assert(le({"3-h","3-s","3-c"},{"4-s","4-h","4-c"}))
    assert(comp({"3-h","3-s","3-c"},{"3-s","3-h","3-c","3-c"}))
    assert(comp({"2-h","2-h","2-s","2-s","2-d"},{"c-s","c-h","c-h"}))
    assert(g({"c-s","c-h","c-h"}, {"2-h","2-h","2-s","2-s","2-d"}))
    assert(le({"t-s","t-c","t-d"}, {"5-s","t-s","c-s"}))
    assert(g({"5-s","t-s","c-s"}, {"t-s","t-c","t-d"}))
end

local function test510kPatternCompare()
    cc.enableMagicCards(true)
    local _, txt = cp.confirmPatternCompareSeqs(false)
    assert(g({"5-s","t-s","k-s"},{"5-h","t-s","k-c"}))
    assert(g({"5-s","t-s","k-s"},{"5-h","t-h","k-h"}))
    assert(g({"5-h","t-h","k-h"},{"5-c","t-c","k-c"}))
    assert(g({"5-c","t-c","k-c"},{"5-d","t-d","k-d"}))
    assert(g({"5-s","t-s","k-s"},{"5-d","t-d","k-d"}))
    assert(g({"5-s","t-s","k-s"},{"5-s","t-s","c-s"}))
    assert(not comp({"5-s","t-h","k-s"},{"5-s","t-s","k-c"}))
    assert(comp({"5-s","t-h","k-s"},{"c-s","c-s","k-c"}))
    assert(g({"5-s","t-s","k-h"},{"6-s","6-h","6-c","6-d","6-s","6-h"}))
    assert(g({"5-c","c-h","k-c"},{"7-s","7-h","7-c","7-d"}))
    print(txt)
end

--
--testPatternParse()
--testPatternParse1()
--testSinglePatternCompare()
--testPairPatternCompare()
--testStraightPatternCompare()
--testCpairPatternCompare()
--testBombPatternCompare()
--test510kPatternCompare()
--]]
