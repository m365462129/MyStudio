local BranchPackageName = 'doudizhu'
local CardPattern = require(string.format("package/%s/module/%s_table/gamelogic_pattern",BranchPackageName, BranchPackageName))--require "gamelogic_pattern"
local CardCommon = require(string.format("package/%s/module/%s_table/gamelogic_common",BranchPackageName, BranchPackageName))
local CardTool = require(string.format("package/%s/module/%s_table/card_tool",BranchPackageName, BranchPackageName))
local DdzLogic = require(string.format("package/%s/module/%s_table/ddz_logic",BranchPackageName, BranchPackageName))

-- ---@type CardPattern CardPattern
-- local CardPattern = require "gamelogic_pattern"

-- ---@type CardCommon CardCommon
-- local CardCommon = require "gamelogic_common"

-- ---@type CardTool CardTool
-- local CardTool = require "card_tool"

-- ---@type DdzLogic DdzLogic
-- local DdzLogic = require "ddz_logic"

---@class CardSet
local CardSet = {}

--  return instance of CardSet
function CardSet.new(cards, card_cnt)
    local o = {}
    setmetatable(o, { __index = CardSet });
    if (cards ~= nil) then
        o.cards = {}
        for i, c in ipairs(cards)
        do
            table.insert(o.cards, c)
        end
    end
    if (card_cnt == nil) then
        card_cnt = #(o.cards)
    end
    o.card_cnt = card_cnt
    return o
end


---@return 出牌提示
function CardSet:hintIterator(pattern)
    local firstout = true  --是否先手
    local outcard = {}
    local handcard = self.cards
    if pattern ~= nil then
        firstout = false
        outcard = pattern.cards
    end
    local tishi, discard_now = DdzLogic.hintIterator(handcard, outcard, firstout)
    local pattern_set = {}
    for i, j in ipairs(tishi) do
        local pattern_tmp = CardPattern.new(j)
        table.insert(pattern_set, pattern_tmp);
    end
    local index = 0
    if #pattern_set == 0 then
        return nil, discard_now
    else
        return function()
            index = index % (#pattern_set) + 1
            return pattern_set[index]
        end, (#pattern_set), discard_now
    end
end

---@return 选牌提示
---@param cards table 选中的牌
function CardSet:choose_hintIterator(cards)
    local tishi = DdzLogic.hintIterator(cards, {}, true)
    local max_cnt = 0
    local pattern_set = {}
    for i, j in ipairs(tishi) do
        if #j > max_cnt then
            max_cnt = #j
        end
    end
    for i, j in ipairs(tishi) do
        local tem_pattern_set = CardPattern.new(j)
        if tem_pattern_set.card_cnt == max_cnt then
            table.insert(pattern_set, tem_pattern_set)
        end
    end
    local num = 0
    local shunxu = 0
    for i, p in ipairs(pattern_set) do
        local tishiidx = CardCommon.tishi[p.type]
        if tishiidx > shunxu then
            shunxu = tishiidx
            num = i
        end
    end
    return pattern_set[num]
end


--添加一张牌到牌列表
local doAddOneCard = function(result, name, color, cards_removed)
    local card_idx = 0
    local remove_flag = false;
    card_idx = CardCommon.FormatCardIndex(name, color)
    for _, c in ipairs(cards_removed) do
        if (c == card_idx) then
            remove_flag = true
            break
        end
    end
    if not remove_flag then
        table.insert(result, card_idx)
    end
end
--洗牌
function CardSet.shuffle(cards_removed, randomseed)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local card_names = CardCommon.GenerateRandomSequence(CardCommon.max_normal_card_name);
    local colors = { CardCommon.color_black_heart, CardCommon.color_red_heart, CardCommon.color_plum, CardCommon.color_square };
    local cards = {}

    for idx = 1, CardCommon.max_normal_card_name do
        local color_idx = CardCommon.GenerateRandomSequence(4)
        for i = 1, 4 do
            doAddOneCard(cards, card_names[idx], colors[color_idx[i]], cards_removed)
        end
    end
    doAddOneCard(cards, CardCommon.card_small_king, CardCommon.color_black_heart, cards_removed)
    doAddOneCard(cards, CardCommon.card_big_king, CardCommon.color_black_heart, cards_removed)
    local cards_return_idx = CardCommon.GenerateRandomSequence(#cards);
    local cards_return = {}
    for _, v in ipairs(cards_return_idx) do
        table.insert(cards_return, cards[v])
    end
    return cards_return
end




--发牌
function CardSet.deal(cards, player_cnt)
    assert(cards)
    local max_cnt = #cards
    local offset = 1
    assert(max_cnt % player_cnt == 0)
    local player_cards = { {}, {}, {} }

    while (offset < max_cnt - 3 ) do
        for i = 1, player_cnt do
            table.insert(player_cards[i], cards[offset + i - 1])
        end
        offset = offset + player_cnt
    end
    local use_card = CardTool.TableAdd(player_cards, 3)
    local sur_card = CardTool.TableSubtract(cards, use_card)
    local cardset = {};
    for i = 1, player_cnt do
        table.insert(cardset, CardSet.new(player_cards[i]))
    end
    return cardset, sur_card;
end
function CardSet:find(card)
    for _, c in ipairs(self.cards) do
        if c == card then
            return true;
        end
    end
    return false;
end

--出牌过牌
function CardSet:discard(card_pattern_object)
    local cnt = #(self.cards)
    local cards = {};
    cards = CardCommon.Combine(cards, self.cards);
    cnt = #(cards)
    for _, c in pairs(card_pattern_object.cards) do
        for idx, card in ipairs(cards) do
            if (c == card) then
                table.remove(cards, idx)
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

---@function 添加底牌到手牌中
---@param cards table
function CardSet:add_dicard(cards)
    local new_cards = CardTool.two_table_add(cards, self.cards)
    self.cards = new_cards
    self.card_cnt = #new_cards
end

function CardSet:count(card)
    local cnt = 0;
    for _, c in ipairs(self.cards) do
        if (c == card) then
            cnt = cnt + 1;
        end
    end
    return cnt;
end

return CardSet						
						
						