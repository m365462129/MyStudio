---
--- Created by chenz.
--- DateTime: 2017/9/30 13:02
---

-- ---@type CardCommon CardCommon
-- local CardCommon = require "gamelogic_common"

-- ---@type DdzLogic DdzLogic
-- local DdzLogic = require "ddz_logic"
-- ---@type CardTool CardTool
-- local CardTool = require "card_tool"

local BranchPackageName = 'doudizhu'
local CardCommon = require(string.format("package/%s/module/%s_table/gamelogic_common",BranchPackageName, BranchPackageName))--require "gamelogic_common"
--
--
---@type DdzLogic DdzLogic
local DdzLogic = require(string.format("package/%s/module/%s_table/ddz_logic",BranchPackageName, BranchPackageName))
local CardTool = require(string.format("package/%s/module/%s_table/card_tool",BranchPackageName, BranchPackageName))

-- 牌型类
---@class CardPattern
local CardPattern = {}


CardPattern.card_cnt = 0

-- 牌名索引 （牌名-1）* 4 + 花色, 前端收到的永远只是牌名索引，但可通过牌名索引计算出牌名与花色
-- 前后端及传输协议中保存的都是牌名索引
CardPattern.cards = {}
CardPattern.value = 0
CardPattern.type = CardCommon.unknown
CardPattern.repeat_cnt = 1
CardPattern.disp_type = CardCommon.unknown
-- 新建并初始化一个牌型实例 return instance of CardPattern
---new
---@param cards table
function CardPattern. new(cards)
    local o = {}
    setmetatable(o, { __index = CardPattern })
    if not o:parse(cards) then
        return nil
    end
    return o
end

-- 判断两次出牌的牌型是否匹配
function CardPattern:compable(card_obj)
    assert((self.type > CardCommon.unknown) )
    assert((card_obj.type > CardCommon.unknown))
    if self.type == CardCommon.zhadan or self.type == CardCommon.huojian then
        return true
    else
        return self.card_cnt == card_obj.card_cnt
    end
end

-- 判断两次出牌的大小 小于等于返回真，否则返回假
function CardPattern:le(card_obj)
    -- 牌型系数说明,影响牌值比较
    local CardTypeFactor = { 0, 0, 0, 0, 0, 0, 100, 200, 0 }
    -- 要求调用此函数之前必须先调用compable
    assert(card_obj ~= nil)
    assert(self:compable(card_obj))
    -- 牌值合法性检查
    local maxvalue = CardTool.Max(CardCommon.CardValue)
    assert(self.value <= maxvalue and self.value > 0)
    assert(card_obj.value <= maxvalue and card_obj.value > 0)
    if (self.value + CardTypeFactor[self.type] ) <= ( card_obj.value + CardTypeFactor[card_obj.type])
    then
        return true
    else
        return false
    end
end



---转换类型
function CardPattern:parseDispType()
    local dispTypeOfSingle = { "one1", "one2", "one3", "one4", "one5", "one6", "one7", "one8", "one9", "one10", "one11", "one12", "one13", "one14", "one15" };
    local dispTypeOfDouble = { "dui1", "dui2", "dui3", "dui4", "dui5", "dui6", "dui7", "dui8", "dui9", "dui10", "dui11", "dui12", "dui13" };
    --local dispTypeOfThree = { "san1", "san2", "san3", "san4", "san5", "san6", "san7", "san8", "san9", "san10", "san11", "san12", "san13" };
    if self.type == CardCommon.danpai then
        self.disp_type = dispTypeOfSingle[DdzLogic.value2cardvalue(self.value) ];
    elseif self.type == CardCommon.duizi then
        self.disp_type = dispTypeOfDouble[DdzLogic.value2cardvalue(self.value)];
    elseif self.type == CardCommon.sandaiyi then
        if self.card_cnt == 3 then
            self.disp_type = "sanzhang";
        elseif self.card_cnt == 4 then
            self.disp_type = "sandaiyi"
        else
            self.disp_type = "sandaier"
        end
    elseif self.type == CardCommon.shunzi then
        self.disp_type = "shunzi"
    elseif self.type == CardCommon.liandui then
        self.disp_type = "liandui"
    elseif self.type == CardCommon.zhadan then
        self.disp_type = "zhadan"
    elseif self.type == CardCommon.feiji then
        self.disp_type = "feiji"
    elseif self.type == CardCommon.huojian then
        self.disp_type = "huojian"
    elseif self.type == CardCommon.sidaier then
        if self.card_cnt == 6 then
            self.disp_type = "sidaier";
        else
            self.disp_type = "sidaisi"
        end
    end
end
-- 判断是否为合法牌型，合法返回true,否则返回假
function CardPattern:parse(cards)
    if (cards ~= nil) then
        self.cards = {}
        for i, c in ipairs(cards)
        do
            table.insert(self.cards, c)
        end
    end
    self.card_cnt = #self.cards
    local card_type, card_value = DdzLogic.get_cards_type(cards)
    if card_type == CardCommon.unknown then
        return false
    else
        self.type = card_type
        self.value = card_value
        self:parseDispType()
        return true
    end
end




return CardPattern