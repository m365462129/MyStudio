---
--- Created by chenz.
--- DateTime: 2017/9/28 15:59
---

local BranchPackageName = 'doudizhu'
---@type CardTool CardTool
local CardTool = require(string.format("package/%s/module/%s_table/card_tool",BranchPackageName, BranchPackageName))
---@type CardCommon CardCommon
local CardCommon = require(string.format("package/%s/module/%s_table/gamelogic_common",BranchPackageName, BranchPackageName))

-- ---@type CardTool CardTool
-- local CardTool = require "card_tool"
-- ---@type CardCommon CardCommon
-- local CardCommon = require "gamelogic_common"


---@class DdzLogic
local DdzLogic = {}

---@return 牌列表转换为牌值
---@param cards table,cards
function DdzLogic.idx2value(cards)
    if not CardTool.table_nil_or_null(cards) then
        return cards
    else
        local newcards = {}
        for i, j in ipairs(cards) do
            table.insert(newcards, CardCommon.NameIdx2Value(j))
        end
        return newcards
    end
end



---@return 是否是单牌
---@param cards,table,cards
function DdzLogic.danpai(cards)
    if #cards == 1 then
        local newcards = DdzLogic.idx2value(cards)
        return newcards[1]
    else
        return false
    end

end

---@return 是否是对子
---@param cards table,cards
function DdzLogic.duizi(cards)
    if #cards == 2 then
        local newcards = DdzLogic.idx2value(cards)
        if CardTool.table_same_value(newcards) then
            return newcards[1]
        else
            return false
        end
    else
        return false
    end
end


---@return 是否是三张，三带一和三带二
---@param cards table,cards
function DdzLogic.sandaiyi(cards)
    if (#cards == 3) or (#cards == 4 ) or (#cards == 5) then
        local newcards = DdzLogic.idx2value(cards)
        local fourl = CardTool.remove_four_same(newcards)
        local threel, surl = CardTool.remove_three_same(newcards)
        if #cards == 4 and #fourl == 1 then
            return false
        end
        if (#threel == 1 ) and CardTool.table_same_value(surl) then
            return threel[1]
        else
            return false
        end
    else
        return false
    end
end

---@return 是否是连对（对子数大于或等于3个对子才是合法的）
---@param cards table,cards
function DdzLogic.liandui(cards)
    local newcards = DdzLogic.idx2value(cards)
    local twol, surl = CardTool.remove_two_same(newcards)
    if CardTool.table_value_shunzi(twol) and (#twol >= 3 ) and (#surl == 0) then
        twol = CardTool.sort_descend(twol)
        return twol[1]
    else
        return false
    end
end

---@return 是否是的顺子 必须大于或等于5个元素
---@param cards table,cards
function DdzLogic.shunzi(cards)
    local newcards = DdzLogic.idx2value(cards)
    if CardTool.table_value_shunzi(newcards) and #cards >= 5 then
        newcards = CardTool.sort_descend(newcards)
        return newcards[1]
    else
        return false
    end
end


---@return 是否是飞机
---@param cards table,cards
function DdzLogic.feiji(cards)
    local newcards = DdzLogic.idx2value(cards)
    local threel, surl = CardTool.remove_three_same(newcards)
    local air = false
    local feijinum = 0
    if #threel > 1 then
        local i = #threel
        while (i > 1) and (not air) do
            local lianshunl = CardTool.find_point_shunzi(threel, i)

            if #lianshunl > 0 then
                for j, l in ipairs(lianshunl) do
                    local sur_three = CardTool.TableSubtract(threel, l)
                    local surl1 = CardTool.copy_table_value(sur_three, 3)
                    local surl2 = CardTool.two_table_add(surl1, surl)
                    local twol = CardTool.remove_two_same(surl2)
                    if (#surl2 == #l) or ((2 * #l == #surl2) and (#twol == #l)) or (#surl == 0) then
                        l = CardTool.sort_descend(l)
                        air = l[1]
                        feijinum = i
                    end
                end
            end
            i = i - 1
        end
    end
    return air, feijinum
end


---@return 是否是炸弹
---@param cards table,cards
function DdzLogic.zhadan(cards)
    if #cards == 4 then
        local newcards = DdzLogic.idx2value(cards)
        if CardTool.table_same_value(newcards) then
            return newcards[1]
        else
            return false
        end
    else
        return false
    end
end


---@return 是否是火箭
---@param cards table,cards
function DdzLogic.huojian(cards)
    if #cards == 2 then
        if (cards[1] > 52 ) and (cards[2] > 52) then
            return true
        else
            return false
        end
    else
        return false
    end
end

---@return 是否是四带二,四带四
---@param cards table,cards
function DdzLogic.sidaier(cards)
    if #cards == 6 then
        local newcards = DdzLogic.idx2value(cards)
        local fourl, surl = CardTool.remove_four_same(newcards)
        if #fourl == 1 then
            return fourl[1]
        else
            return false
        end
    elseif #cards == 8 then
        local newcards = DdzLogic.idx2value(cards)
        local fourl, surl = CardTool.remove_four_same(newcards)
        if #fourl == 1 then
            local twol = CardTool.remove_two_same(surl)
            if #twol == 2 then
                return fourl[1]
            else
                return false
            end
        elseif #fourl == 2 then
            fourl = CardTool.sort_descend(fourl)
            return fourl[1]
        else
            return false
        end
    else
        return false
    end
end

---@return 获取牌的牌型
---@param table
function DdzLogic.get_cards_type(cards)
    if CardTool.table_nil_or_null(cards) then
        local danpai = DdzLogic.danpai(cards)
        if danpai then
            return CardCommon.danpai, danpai
        else
            local duizi = DdzLogic.duizi(cards)
            if duizi then
                return CardCommon.duizi, duizi
            else
                local sandaiyi = DdzLogic.sandaiyi(cards)
                if sandaiyi then
                    return CardCommon.sandaiyi, sandaiyi

                else
                    local shunzi = DdzLogic.shunzi(cards)
                    if shunzi then
                        return CardCommon.shunzi, shunzi
                    else
                        local liandui = DdzLogic.liandui(cards)
                        if liandui then
                            return CardCommon.liandui, liandui
                        else
                            local feiji = DdzLogic.feiji(cards)
                            if feiji then
                                return CardCommon.feiji, feiji
                            else
                                local zhadan = DdzLogic.zhadan(cards)
                                if zhadan then
                                    return CardCommon.zhadan, zhadan
                                else
                                    local huojian = DdzLogic.huojian(cards)
                                    if huojian then
                                        return CardCommon.huojian, CardCommon.max_card_value
                                    else
                                        local sidaier = DdzLogic.sidaier(cards)
                                        if sidaier then
                                            return CardCommon.sidaier, sidaier
                                        else
                                            return CardCommon.unknown
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        return CardCommon.unknown
    end
end

---@return 找出所有的四张
---@param handcards table
function DdzLogic.find_all_sizhang(handcards)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local fourl = CardTool.remove_four_same(newcardvalue)
    table.sort(fourl)
    local zhadanl = {}
    for i, j in ipairs(fourl) do
        local t = DdzLogic.value2idx(j)
        table.insert(zhadanl, t)
    end
    return zhadanl
end

---@return 找出所有的炸弹
---@param handcards table
function DdzLogic.find_all_boom(handcards)
    return CardTool.two_table_add(DdzLogic.find_all_sizhang(handcards), DdzLogic.find_huojian(handcards))
end

---@return 找出所有的三张
---@param handcards table
function DdzLogic.find_all_sanzhang(handcards)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local fourl, surl = CardTool.remove_four_same(newcardvalue)
    local threel = CardTool.remove_three_same(surl)
    local sanzhangl = {}
    table.sort(threel)
    for i, j in ipairs(threel) do
        local t = DdzLogic.value2have_idx(j, handcards)
        table.insert(sanzhangl, t)
    end
    return sanzhangl
end

---@return 找出所有的对子（包括三张）
---@param handcards table
function DdzLogic.find_all_duizi(handcards)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local fourl, surl = CardTool.remove_four_same(newcardvalue)
    local threel, surl2 = CardTool.remove_three_same(surl)
    local twol = CardTool.remove_two_same(surl2)
    table.sort(threel)
    table.sort(twol)
    local duizil = {}
    local sanzhangl = {}
    for i, j in ipairs(twol) do
        local t = DdzLogic.value2have_idx(j, handcards)
        table.insert(duizil, t)
    end
    for i, j in ipairs(threel) do
        local t = DdzLogic.value2have_point_idx({ j, j }, handcards)
        table.insert(sanzhangl, t)
    end
    return CardTool.two_table_add(duizil, sanzhangl), duizil
end

---@return 找出所有的单张(包括对子，三张中的一张)
---@param handcards table
function DdzLogic.find_all_danzhang(handcards)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local fourl, surl = CardTool.remove_four_same(newcardvalue)
    local threel, surl2 = CardTool.remove_three_same(surl)
    local twol, surl3 = CardTool.remove_two_same(surl2)
    table.sort(surl3)
    table.sort(threel)
    table.sort(twol)
    local danzhangidx = {}
    local twoidx = {}
    local threeidx = {}
    for i, j in ipairs(surl3) do
        local t = DdzLogic.value2have_idx(j, handcards)
        table.insert(danzhangidx, t)
    end
    for i, j in ipairs(twol) do
        local t = DdzLogic.value2have_point_idx({ j }, handcards)
        table.insert(twoidx, t)
    end
    for i, j in ipairs(threel) do
        local t = DdzLogic.value2have_point_idx({ j }, handcards)
        table.insert(threeidx, t)
    end
    return CardTool.TableAdd({ danzhangidx, twoidx, threeidx }), danzhangidx
end

---@return 找出所有的顺子
---@param handcards table
---@param num int
function DdzLogic.find_all_shunzi(handcards, num)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local value_shunzi = CardTool.find_point_shunzi(newcardvalue, num)
    local idx_shunzi = {}
    for i, j in ipairs(value_shunzi) do
        table.insert(idx_shunzi, DdzLogic.value2have_point_idx(j, handcards))
    end
    return idx_shunzi
end

---@return 找出所有的飞机
---@param handcards table
---@param num int
function DdzLogic.find_all_feiji(handcards, num)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local fourl, surl = CardTool.remove_four_same(newcardvalue)
    local threel = CardTool.remove_three_same(surl)
    local allthree = CardTool.two_table_add(fourl, threel)
    local value_shunzi = CardTool.find_point_shunzi(allthree, num)
    local idx_shunzi = {}
    for i, j in ipairs(value_shunzi) do
        table.insert(idx_shunzi, DdzLogic.value2have_point_idx(CardTool.copy_table_value(j, 3), handcards))
    end
    return idx_shunzi
end


---@return 找出所有的连对
---@param handcards table
---@param num int
function DdzLogic.find_all_liandui(handcards, num)
    local newcardvalue = DdzLogic.idx2value(handcards)
    local fourl, surl = CardTool.remove_four_same(newcardvalue)
    local threel, surl2 = CardTool.remove_three_same(surl)
    local twol, surl3 = CardTool.remove_two_same(surl2)
    local alltwo = CardTool.two_table_add(threel, twol)
    local value_shunzi = CardTool.find_point_shunzi(alltwo, num)
    local idx_shunzi = {}
    for i, j in ipairs(value_shunzi) do
        table.insert(idx_shunzi, DdzLogic.value2have_point_idx(CardTool.copy_table_value(j, 2), handcards))
    end
    return idx_shunzi
end

---@return 找到火箭
---@param handcards 手牌
function DdzLogic.find_huojian(handcards)
    local huojian = {}
    for i, j in ipairs(handcards) do
        local cardvalue = CardCommon.NameIdx2Value(j)
        local cardname = DdzLogic.card2name(cardvalue)
        if cardname == CardCommon.card_small_king or cardname == CardCommon.card_big_king then
            table.insert(huojian, j)
        end
    end
    if #huojian == 2 then
        return { huojian }
    else
        return {}
    end
end

---@return 牌值转换为手牌中的索引(指定数量的牌)
---@param cardvaluel table
---@param handcard table
function DdzLogic.value2have_point_idx(cardvaluel, handcard)
    local pointl = {}
    local newhandcard = CardTool.copy_table(handcard)
    for i, j in ipairs(cardvaluel) do
        local havel = DdzLogic.value2have_idx(j, newhandcard)
        if #havel > 0 then
            for t, k in ipairs(newhandcard) do
                if k == havel[1] then
                    table.insert(pointl, k)
                    table.remove(newhandcard, t)
                end
            end
        end
    end
    pointl = CardTool.sort_ascend(pointl)
    return pointl
end


---@return 牌值转换为手牌中的索引（全部拥有的牌）
---@param cardvalue int
---@param handcard table
function DdzLogic.value2have_idx(cardvalue, handcard)
    local cardl = DdzLogic.value2idx(cardvalue)
    local havecardl = {}
    for i, j in ipairs(cardl) do
        if CardTool.TableMember(handcard, j) then
            table.insert(havecardl, j)
        end
    end
    havecardl = CardTool.sort_ascend(havecardl)
    return havecardl
end

---@return 牌值转换为牌中的索引
---@param cardvalue int
function DdzLogic.value2idx(cardvalue)
    local cardname = CardCommon.card_unknown
    for i, j in ipairs(CardCommon.CardValue) do
        if cardvalue == j then
            cardname = i
        end
    end
    return {
        CardCommon.FormatCardIndex(cardname, CardCommon.color_black_heart),
        CardCommon.FormatCardIndex(cardname, CardCommon.color_red_heart),
        CardCommon.FormatCardIndex(cardname, CardCommon.color_plum),
        CardCommon.FormatCardIndex(cardname, CardCommon.color_square)
    }
end

---@return 牌值转换为CardValue
---@param cardvalue int
function DdzLogic.value2cardvalue(cardvalue)
    local cardname = 0
    for i, j in ipairs(CardCommon.CardValue) do
        if cardvalue == j then
            cardname = i
        end
    end
    return cardname
end

---@return 牌转换为name
---@param card int
function DdzLogic.card2name(card)
    local cardname = CardCommon.card_unknown
    for i, j in ipairs(CardCommon.CardValue) do
        if card == j then
            cardname = i
        end
    end
    return cardname
end

---@return 找出所有大于上家出的牌的牌型
---@param handcard table
---@param outcard table
function DdzLogic.find_all_biger_type(handcard, outcard)
    local allboom = DdzLogic.find_all_boom(handcard)
    local huojian = DdzLogic.find_huojian(handcard)
    local outtype, outvalue = DdzLogic.get_cards_type(outcard)
    if outtype == CardCommon.danpai then
        return CardTool.two_table_add(DdzLogic.find_all_biger_danpai(handcard, outvalue), allboom)
    elseif outtype == CardCommon.duizi then
        return CardTool.two_table_add(DdzLogic.find_all_biger_duizi(handcard, outvalue), allboom)
    elseif outtype == CardCommon.sandaiyi then
        return CardTool.two_table_add(DdzLogic.find_all_biger_sanzhang(handcard, outvalue, #outcard), allboom)
    elseif outtype == CardCommon.zhadan then
        return CardTool.two_table_add(DdzLogic.find_all_biger_sizhang(handcard, outvalue), huojian)
    elseif outtype == CardCommon.shunzi then
        return CardTool.two_table_add(DdzLogic.find_all_biger_shunzi(handcard, outvalue, #outcard), allboom)
    elseif outtype == CardCommon.liandui then
        return CardTool.two_table_add(DdzLogic.find_all_biger_liandui(handcard, outvalue, #outcard / 2), allboom)
    elseif outtype == CardCommon.feiji then
        return CardTool.two_table_add(DdzLogic.find_all_biger_feiji(handcard, outcard), allboom)
    elseif outtype == CardCommon.sidaier then
        return allboom
    elseif outtype == CardCommon.huojian then
        return {}
    else
        return {}
    end
end

---@return 先手提示 飞机》顺子》连对》三张》对子》单张》炸弹》火箭
---@param handcard table
function DdzLogic.first_tishi_card(handcard)
    local t, danpai = DdzLogic.find_all_danzhang(handcard)
    local tishi, auto = {}, false
    if #handcard == 1 then
        tishi = { handcard }
        auto = true
    elseif #handcard == 2 then
        if DdzLogic.duizi(handcard) or DdzLogic.huojian(handcard) then
            tishi = { handcard }
            auto = true
        else
            tishi = DdzLogic.find_tishi_type(handcard)
        end
    elseif #handcard == 3 then
        if DdzLogic.sandaiyi(handcard) then
            tishi = { handcard }
            auto = true
        else
            tishi = DdzLogic.find_tishi_type(handcard)
        end
    elseif #handcard == 4 then
        if DdzLogic.zhadan(handcard) or DdzLogic.sandaiyi(handcard) then
            tishi = { handcard }
            auto = true
        else
            tishi = DdzLogic.find_tishi_type(handcard)
        end
    elseif #handcard == 5 then
        local wangzha = DdzLogic.find_huojian(handcard)
        if (#wangzha == 0 and DdzLogic.sandaiyi(handcard)) or DdzLogic.shunzi(handcard) then
            tishi = { handcard }
            auto = true
        else
            tishi = DdzLogic.find_tishi_type(handcard)
        end
    else
        local sizhang = DdzLogic.find_all_sizhang(handcard)
        local wangzha = DdzLogic.find_huojian(handcard)
        if (#sizhang == 0 and #wangzha == 0) then
            if DdzLogic.shunzi(handcard)  or DdzLogic.liandui(handcard) or DdzLogic.feiji(handcard) then
                tishi = { handcard }
                auto = true
            else
                tishi = DdzLogic.find_tishi_type(handcard)
            end
        else
            tishi = DdzLogic.find_tishi_type(handcard)
        end
    end
    return tishi, auto
end

---@return 返回收发提示牌型 飞机》顺子》连对》三张》对子》单张》炸弹》火箭
---@param handcard table
function DdzLogic.find_tishi_type(handcard)
    local threel = DdzLogic.find_all_sanzhang(handcard)
    local allduizi, duizi = DdzLogic.find_all_duizi(handcard)
    local alldanpai, danpai = DdzLogic.find_all_danzhang(handcard)
    local zhadan = DdzLogic.find_all_sizhang(handcard)
    local huojian = DdzLogic.find_huojian(handcard)
    local feiji = {}
    local shunzi = {}
    local liandui = {}
    local threenum = #threel
    local shunzinum = 12
    if (#handcard < 12 ) and (#handcard > 4) then
        shunzinum = #handcard
    elseif #handcard < 5 then
        shunzinum = 0
    end
    local duizinum = #allduizi
    while (threenum > 1 and #feiji == 0) do
        feiji = DdzLogic.find_all_feiji(handcard, threenum)
        threenum = threenum - 1
    end
    while (shunzinum > 4 and #shunzi == 0) do
        shunzi = DdzLogic.find_all_shunzi(handcard, shunzinum)
        shunzinum = shunzinum - 1
    end
    while (duizinum > 2 and #liandui == 0) do
        liandui = DdzLogic.find_all_liandui(handcard, duizinum)
        duizinum = duizinum - 1
    end
    return CardTool.TableAdd({ feiji, liandui, shunzi, threel, duizi, danpai, zhadan, huojian })
end

---@return 找出所有大于单张的牌型
---@param handcard table
---@param outvalue int
function DdzLogic.find_all_biger_danpai(handcard, outvalue)
    local alltype = DdzLogic.find_all_danzhang(handcard)
    local biger = {}
    for i, j in ipairs(alltype) do
        local v = DdzLogic.danpai(j)
        if v then
            if v > outvalue then
                table.insert(biger, j)
            end
        end
    end
    return biger
end
---@return 找出所有大于对子的牌型
---@param handcard table
---@param outvalue int
function DdzLogic.find_all_biger_duizi(handcard, outvalue)
    local alltype = DdzLogic.find_all_duizi(handcard)
    local biger = {}
    for i, j in ipairs(alltype) do
        local v = DdzLogic.duizi(j)
        if v then
            if v > outvalue then
                table.insert(biger, j)
            end
        end
    end
    return biger
end

---@return 找出所有大于炸弹的牌型
---@param handcard table
---@param outvalue int
function DdzLogic.find_all_biger_sizhang(handcard, outvalue)
    local alltype = DdzLogic.find_all_sizhang(handcard)
    local biger = {}
    for i, j in ipairs(alltype) do
        local v = DdzLogic.zhadan(j)
        if v then
            if v > outvalue then
                table.insert(biger, j)
            end
        end
    end
    return biger
end
---@return 找出所有大于顺子的牌型
---@param handcard table
---@param outvalue int
---@param num int
function DdzLogic.find_all_biger_shunzi(handcard, outvalue, num)
    local alltype = DdzLogic.find_all_shunzi(handcard, num)
    local biger = {}
    if #handcard >= num then
        for i, j in ipairs(alltype) do
            local v = DdzLogic.shunzi(j)
            if v then
                if v > outvalue then
                    table.insert(biger, j)
                end
            end
        end
    end
    return biger
end
---@return 找出所有大于连对的牌型
---@param handcard table
---@param outvalue int
---@param num int
function DdzLogic.find_all_biger_liandui(handcard, outvalue, num)
    local alltype = DdzLogic.find_all_liandui(handcard, num)
    local biger = {}
    if #handcard >= num * 2 then
        for i, j in ipairs(alltype) do
            local v = DdzLogic.liandui(j)
            if v then
                if v > outvalue then
                    table.insert(biger, j)
                end
            end
        end
    end
    return biger
end

---@return 找出所有大于三张的牌型
---@param handcard table
---@param outvalue int
function DdzLogic.find_all_biger_sanzhang(handcard, outvalue, num)
    local alltype = DdzLogic.find_all_sanzhang(handcard)
    local biger = {}
    if #handcard >= num then
        for i, j in ipairs(alltype) do
            local v = DdzLogic.sandaiyi(j)
            if v then
                if v > outvalue then
                    table.insert(biger, j)
                end
            end
        end
    end
    return biger
end

---@return 找出所有大于飞机的牌型
---@param handcard table
---@param outvalue int
---@param num int
function DdzLogic.find_all_biger_feiji(handcard, outcard)
    local outvalue, num = DdzLogic.feiji(outcard)
    local alltype = DdzLogic.find_all_feiji(handcard, num)
    local biger = {}
    if #handcard >= #outcard then
        for i, j in ipairs(alltype) do
            local v = DdzLogic.feiji(j)
            if v then
                if v > outvalue then
                    surl = CardTool.TableSubtract(handcard, j)
                    table.insert(biger, j)
                end
            end
        end
    end
    return biger
end

---@return 出牌提示
---@param handcard table 手牌
---@param outcard table 上家出的牌
---@param firstout boolean 是否先手出牌
function DdzLogic.hintIterator(handcard, outcard, firstout)
    local tishi, auto = {}, false
    if (firstout ) then
        tishi, auto = DdzLogic.first_tishi_card(handcard)
    else
        tishi = DdzLogic.find_all_biger_type(handcard, outcard)
        if #tishi == 1 then
            if #(tishi[1]) == #handcard then
                auto = true
            end
        end
    end
    return tishi, auto
end


return DdzLogic