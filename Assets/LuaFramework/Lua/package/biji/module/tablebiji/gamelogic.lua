local table = table
local math = math
local pairs = pairs
local Cal = {}

function Cal.deepcopy(obj)
    --local InTable = {};
    local function Func(obj)
        if type(obj) ~= "table" then
            --判断表中是否有表
            return obj;
        end
        local NewTable = {};  --定义一个新表
        --InTable[obj] = NewTable;  --若表中有表，则先把表给InTable，再用NewTable去接收内嵌的表
        for k, v in pairs(obj) do
            --把旧表的key和Value赋给新表
            NewTable[Func(k)] = Func(v);
        end
        return setmetatable(NewTable, getmetatable(obj))--赋值元表
    end
    return Func(obj) --若表中有表，则把内嵌的表也复制了
end

function Cal.Compare(a, b)
    return (a.Number * 4 + a.Color) < (b.Number * 4 + b.Color)
end

function Cal.IsSanTiao(poker)
    return poker[1].Number == poker[2].Number and poker[1].Number == poker[3].Number
end

function Cal.IsTongHua(poker)
    return poker[1].Color == poker[2].Color and poker[1].Color == poker[3].Color
end

function Cal.IsShunZi(poker)
    return (poker[1].Number + 1 == poker[2].Number and poker[1].Number + 2 == poker[3].Number) or
    (poker[1].Number == 2 and poker[2].Number == 3 and poker[3].Number == 14)
end

function Cal.IsDuiZi(poker)
    return poker[1].Number == poker[2].Number or poker[1].Number == poker[3].Number or poker[2].Number == poker[3].Number
end

function Cal.DuiZi(poker)
    if poker[1].Number == poker[2].Number then
        return 1, 3
    elseif poker[1].Number == poker[3].Number then
        return 1, 2
    else
        return 2, 1
    end
end

function Cal.PokerToMask(Poker)
    local mask = {}
    for i = 1, #Poker do
        mask[Poker[i].Number * 4 + Poker[i].Color] = true
    end
    return mask
end

function Cal.ComputePaixing(poker, mask)
    --6,����;5,ͬ��˳;4,ͬ��;3,˳��;2,����;1,����
    table.sort(poker, function (a, b)
        return a.Number < b.Number
    end)
    if poker[3].Number == 15 then
        local maxpn
        local maxvalue
        local maxpp
        local cw = poker[2].Number == 15 and 2 or 1
        local function LaiZiPai(poker, mask, ns)
            local flag = true
            for i = 1, 3 do
                if poker[i].Number == 15 and flag then
                    poker[i].king = true
                    ns = ns or 2
                    flag = false
                    for n = ns, 14 do
                        for c = 1, 4 do
                            if not mask[n * 4 + c] then
                                if cw == 1 or (cw == 2 and (n == poker[1].Number or c == poker[1].Color)) then
                                    mask[n * 4 + c] = true
                                    poker[i].Number = n
                                    poker[i].Color = c
                                    LaiZiPai(Cal.deepcopy(poker), mask, n)
                                    mask[n * 4 + c] = nil
                                end
                            end
                        end
                    end
                end
            end
            if flag then
                table.sort(poker, Cal.Compare)
                local pn, value = Cal.ComputePaixing(poker)
                if not maxpn or (maxpn and (pn > maxpn or (pn == maxpn and value > maxvalue))) then
                    maxpn, maxvalue, maxpp = pn, value, poker
                end
            end
        end
        LaiZiPai(Cal.deepcopy(poker), Cal.deepcopy(mask))
        return maxpn, maxvalue, maxpp
    else
        if Cal.IsSanTiao(poker) then
            return 6, Cal.PaiXingValue(6, poker)
        elseif Cal.IsTongHua(poker) then
            local px = Cal.IsShunZi(poker) and 5 or 4
            return px, Cal.PaiXingValue(px, poker)
        elseif Cal.IsShunZi(poker) then
            return 3, Cal.PaiXingValue(3, poker)
        elseif Cal.IsDuiZi(poker) then
            return 2, Cal.PaiXingValue(2, poker)
        else
            return 1, Cal.PaiXingValue(1, poker)
        end
    end
end

function Cal.PaiXingValue(px, poker)
    if px == 2 then
        --¶Ô×Ó£¬ÏÈ±È¶Ô×Ó´óÐ¡£¬¶Ô×ÓÏàÍ¬£¬±Èµ¥ÅÆ´óÐ¡£¬µ¥ÅÆÒ²ÏàÍ¬£¬ÔÙ±È»¨É«
        local duizi, danpai = Cal.DuiZi(poker)
        return (poker[duizi].Number * 14 + poker[danpai].Number) * 4 * 4 * 4 + poker[3].Color * 4 * 4 + poker[2].Color * 4 + poker[1].Color
    elseif px == 3 then
        local k = (poker[3].king or poker[2].king or poker[1].king) and 0 or 1
        if poker[3].Number == 14 and poker[1].Number == 2 then
            return (3 * 14 * 14 + 2 * 14 + 1) * 4 * 4 * 4 * 4 + k * 4 * 4 * 4 + (poker[3].king and 0 or poker[3].Color) * 4 * 4 + (poker[2].king and 0 or poker[2].Color) * 4 + (poker[1].king and 0 or poker[1].Color)
        else
            return (poker[3].Number * 14 * 14 + poker[2].Number * 14 + poker[1].Number) * 4 * 4 * 4 * 4 + k * 4 * 4 * 4 + (poker[3].king and 0 or poker[3].Color) * 4 * 4 + (poker[2].king and 0 or poker[2].Color) * 4 + (poker[1].king and 0 or poker[1].Color)
        end
    elseif px == 5 then
        if poker[3].Number == 14 and poker[1].Number == 2 then
            return (3 * 14 * 14 + 2 * 14 + 1) * 4 * 4 * 4 + poker[3].Color * 4 * 4 + poker[2].Color * 4 + poker[1].Color
        else
            return (poker[3].Number * 14 * 14 + poker[2].Number * 14 + poker[1].Number) * 4 * 4 * 4 + poker[3].Color * 4 * 4 + poker[2].Color * 4 + poker[1].Color
        end
    elseif px == 6 then
        local k = (poker[3].king or poker[2].king or poker[1].king) and 0 or 1
        return (poker[3].Number * 14 * 14 + poker[2].Number * 14 + poker[1].Number) * 4 * 4 * 4 * 4 + k * 4 * 4 * 4 + (poker[3].king and 0 or poker[3].Color) * 4 * 4 + (poker[2].king and 0 or poker[2].Color) * 4 + (poker[1].king and 0 or poker[1].Color)
    else --²»ÊÇ¶Ô×Ó£¬ÅÆÐÍÏàÍ¬µÄÇé¿öÏÂ£¬ÏÈ±ÈÅÆÊý´óÐ¡£¬ÅÆÊýÏàÍ¬£¬ÔÙ±È×î´óÅÆµÄ»¨É«
        return (poker[3].Number * 14 * 14 + poker[2].Number * 14 + poker[1].Number) * 4 * 4 * 4 + poker[3].Color * 4 * 4 + poker[2].Color * 4 + poker[1].Color
    end
end

function Cal.ComparePoker(poker1, poker2)
    if poker1.px > poker2.px then
        return true
    elseif poker1.px < poker2.px then
        return false
    elseif poker1.px == poker2.px then
        return poker1.value > poker2.value
    end
end


function Cal.SortHBTPai(Pai, mask)
    for i = 1, 3 do
        Pai[i].px, Pai[i].value, Pai[i].pp = Cal.ComputePaixing(Pai[i], mask)
    end
    Cal.SortPai(Pai, false)
    local count = 0
    local pos = {}
    for i = 1, 3 do
        if Pai[i][3].Number == 15 then
            count = count + 1
            pos[count] = i
        end
    end
    if count == 2 then
        --如果存在两个癞子并分散在两道牌中
        local m = Cal.deepcopy(mask)
        for i = 1, 3 do
            --其中一个癞子变的牌，另一个癞子不能再变，优先牌型更大的癞子组合
            m[Pai[pos[2]].pp[i].Number * 4 + Pai[pos[2]].pp[i].Color] = true
        end
        Pai[pos[1]].px, Pai[pos[1]].value = Cal.ComputePaixing(Pai[pos[1]], m)
        Cal.SortPai(Pai, false)
    end
end

function Cal.SortPai(Pai, flag, s, e)
    s = s or 1
    e = e or #Pai
    if s >= e then
        return
    end
    local key = Pai[s]
    local i, j = s, e
    while i < j do
        while i < j and ((flag and not Cal.ComparePoker(Pai[j], key)) or (not flag and Cal.ComparePoker(Pai[j], key))) do
            j = j - 1
        end
        Pai[i] = Pai[j]
        while i < j and ((flag and Cal.ComparePoker(Pai[i], key)) or (not flag and not Cal.ComparePoker(Pai[i], key))) do
            i = i + 1
        end
        Pai[j] = Pai[i]
    end
    Pai[i] = key
    Cal.SortPai(Pai, flag, s, i - 1)
    Cal.SortPai(Pai, flag, i + 1, e)
end

function Cal.pow(x, n)
    return math.exp(n * math.log(x))
end

--����������Ƶ��������
function Cal.CombinePoker(poker, combinations, gpos, n, k, index, i)
    k = k or 0
    n = n or 3
    if k == n then
        local temp = #combinations + 1
        combinations[temp] = {}
        local key = 0
        for h = 1, n do
            combinations[temp][h] = poker[index[h]]
            key = key + Cal.pow(2, index[h])
        end
        gpos[temp] = key
        return
    end
    index = index or {}
    i = i or 1
    for j = i, #poker - n + k + 1 do
        index[k + 1] = j
        Cal.CombinePoker(poker, combinations, gpos, n, k + 1, index, j + 1)
    end
end

function Cal.ComputePoker(Players)
    for _, p in pairs(Players) do
        local combinations = {}
        Cal.CombinePoker(p.Poker, combinations)
        local mask = Cal.PokerToMask(p.Poker)
        for i = 1, #combinations do
            local res = Cal.ComputePaixing(combinations[i], mask)
            if res ~= 1 then
                local temp
                if res == 5 then
                    --ͬ��˳Ҳ����ͬ����˳��
                    for j = 1, 3 do
                        temp = #p.PaiXing[res - j] + 1
                        p.PaiXing[res - j][temp] = Cal.deepcopy(combinations[i])
                    end
                else
                    temp = #p.PaiXing[res - 1] + 1
                    p.PaiXing[res - 1][temp] = Cal.deepcopy(combinations[i])
                end
            end
        end
    end
end

function Cal.IsSanQing(Pai)
    for i = 1, 3 do
        if Pai[i].px ~= 5 and Pai[i].px ~= 4 then
            return false
        end
    end
    return true
end

function Cal.IsQuanHong(Poker)
    for i = 1, 9 do
        if Poker[i].Color ~= 1 and Poker[i].Color ~= 3 then
            return false
        end
    end
    return true
end

function Cal.IsQuanHei(Poker)
    for i = 1, 9 do
        if Poker[i].Color ~= 2 and Poker[i].Color ~= 4 then
            return false
        end
    end
    return true
end
function Cal.IsShuangOrSanShunQing(Pai)
    local cnt = 0
    for i = 1, 3 do
        if Pai[i].px == 5 then
            cnt = cnt + 1
        end
    end
    return cnt > 1 and cnt or 0
end

function Cal.IsShuangOrQuanSanTiao(Pai)
    if Pai[2].px == 6 and Pai[3].px == 6 then
        return Pai[1].px == 6 and 3 or 2
    end
    return 0
end

function Cal.IsSiGeTou(Pai)
    local santiao = {}
    for i = 1, 3 do
        if Pai[i].px == 6 then
            table.insert(santiao, Pai[i][3].Number ~= 15 and Pai[i][3].Number or 0)
        end
    end
    local sigetounum = 0
    for i = 1, #santiao do
        for j = 1, 3 - #santiao do
            for k = 1, 3 do
                if Pai[j][k].Number == santiao[i] then
                    sigetounum = sigetounum + 1
                end
            end
        end
    end
    return sigetounum
end

function Cal.IsLianShun(Pai, Poker)
    for i = 1, 3 do
        if Pai[i].px ~= 5 and Pai[i].px ~= 3 then
            return false
        end
    end
    local j = 0
    for i = 1, 8 do
        if Poker[i].Number + 1 ~= Poker[i + 1].Number then
            j = i
            break
        end
    end
    if j == 0 then
        return true
    elseif j == 8 then
        if Poker[9].Number == 14 and Poker[1].Number == 2 then
            return true
        end
    end
    return false
end

function Cal.IsSanShunZi(Pai)
    for i = 1, 3 do
        if Pai[i].px ~= 5 and Pai[i].px ~= 3 then
            return false
        end
    end
    return true
end


function Cal.ComputeXiPai(Pai, Poker, XiPai)
    local temp
    temp = Cal.IsShuangOrSanShunQing(Pai)
    if temp == 3 then
        XiPai[5] = true
    elseif temp == 2 then
        XiPai[4] = true
    end
    local isSanQing = Cal.IsSanQing(Pai)
    if temp ~= 3 and isSanQing then
        --如果三顺清，则不再计算三清
        XiPai[1] = true
    end
    if Cal.IsQuanHei(Poker) then
        XiPai[2] = true
    elseif Cal.IsQuanHong(Poker) then
        XiPai[3] = true
    end
    if Cal.IsSanShunZi(Pai) then
        XiPai[12] = true
    end
    local isLianShun = XiPai[12] and Cal.IsLianShun(Pai, Poker)
    if (Pai[1][1].Color == Pai[2][1].Color and Pai[1][1].Color == Pai[3][1].Color) and XiPai[5] and isLianShun then
        --三顺清并且三道牌花色相同，再计算清连顺
        XiPai[11] = true
    elseif isLianShun then
        XiPai[10] = true
    end
    if not XiPai[2] and not XiPai[3] then
        temp = Cal.IsShuangOrQuanSanTiao(Pai)
        if temp == 3 then
            XiPai[7] = true
        elseif temp == 2 then
            XiPai[6] = true
        end
        if temp ~= 3 then
            temp = Cal.IsSiGeTou(Pai)
            if temp == 1 then
                XiPai[8] = true
            elseif temp == 2 then
                XiPai[9] = true
            end
        end
    end

    if Poker[9].Number == 15 then
        for i = 1, 12 do
            if i == 8 or i == 9 then
            elseif i == 4 or i == 6 then
                if Pai[2][3].Number == 15 or Pai[3][3].Number == 15 then
                    XiPai[i] = false
                end
            else
                XiPai[i] = false
            end
        end
    end
end

function Cal.PXValue(px, poker)
    if px == 2 then
        local duizi, danpai = Cal.DuiZi(poker)
        return poker[duizi].Number * 14 + poker[danpai].Number
    elseif px == 3 or px == 5 then
        if poker[3].Number == 14 and poker[1].Number == 2 then
            return 3 * 14 * 14 + 2 * 14 + 1
        else
            return poker[3].Number * 14 * 14 + poker[2].Number * 14 + poker[1].Number
        end
    else
        return poker[3].Number * 14 * 14 + poker[2].Number * 14 + poker[1].Number
    end
end

function Cal.ComparePai(p1, p2)
    if p1.px > p2.px then
        return true
    elseif p1.px < p2.px then
        return false
    elseif p1.px == p2.px then
        local v1 = Cal.PXValue(p1.px, p1)
        local v2 = Cal.PXValue(p2.px, p2)
        return v1 > v2
    end
end

function Cal.GenerateHBTv(gpai, combinations, poker, hbts, pos, mask, s, c, xipaiscore)
    s = s or 1
    c = c or 0
    mask = mask or {}
    if c % 3 == 0 then
        s = pos[c - 2] or 1
    end
    if c == 9 then
        local temp = {}
        for i = 1, 7, 3 do
            local p = 0
            for j = i, i + 2 do
                p = p + Cal.pow(2, pos[j])
            end
            temp[(i - 1) / 3 + 1] = combinations[gpai[p]]
        end
        Cal.SortPai(temp)
        local xipai = {}
        local xppoker = {}
        for i = 1, #poker do
            if mask[i] then
                table.insert(xppoker, poker[i])
            end
        end
        Cal.ComputeXiPai(temp, xppoker, xipai)
        temp.XiPaiScore = 0
        for i = 1, 12 do
            if xipai[i] then
                temp.XiPaiScore = temp.XiPaiScore + xipaiscore[i]
            end
        end
        local flag = true
        for i = #hbts, 1, -1 do
            if not Cal.ComparePai(hbts[i][1], temp[1]) and not Cal.ComparePai(hbts[i][2], temp[2]) and not Cal.ComparePai(hbts[i][3], temp[3]) and temp.XiPaiScore >= hbts[i].XiPaiScore then
                table.remove(hbts, i)
            elseif not Cal.ComparePai(temp[1], hbts[i][1]) and not Cal.ComparePai(temp[2], hbts[i][2]) and not Cal.ComparePai(temp[3], hbts[i][3]) and hbts[i].XiPaiScore >= temp.XiPaiScore then
                flag = false
            end
        end
        if flag then
            for i = 1, #hbts do
                if temp[1].px == hbts[i][1].px and temp[2].px == hbts[i][2].px and temp[3].px == hbts[i][3].px then
                    flag = false
                    if temp.XiPaiScore > hbts[i].XiPaiScore or temp[3].value > hbts[i][3].value or (temp[3].value == hbts[i][3].value and temp[2].value > hbts[i][2].value) then
                        hbts[i] = temp
                        break
                    end
                end
            end
            if flag then
                table.insert(hbts, temp)
            end
        end
        return
    end
    for i = s, #poker do
        if not mask[i] then
            mask[i] = true
            pos[c + 1] = i
            Cal.GenerateHBTv(gpai, combinations, poker, hbts, pos, mask, i + 1, c + 1, xipaiscore)
            mask[i] = nil
        end
    end
end

function Cal.GenerateHBT(gpai, combinations, poker, pokermask, xipaiscore)
    local HBTs = {}
    local hbts = {}
    local pos = {}
    local mask
    local s
    local c
    for i = 1, 9 do
        pos[i] = 0
    end
    Cal.GenerateHBTv(gpai, combinations, poker, hbts, pos, mask, s, c, xipaiscore)
    HBTs = Cal.deepcopy(hbts)
    for i = 1, #HBTs do
        Cal.SortHBTPai(HBTs[i], pokermask)
    end
    for i = 1, #HBTs - 1 do
        local maxpos = i
        for j = i + 1, #HBTs do
            local numj = HBTs[j][3].px * 6 * 6 + HBTs[j][2].px * 6 + HBTs[j][1].px
            local numm = HBTs[maxpos][3].px * 6 * 6 + HBTs[maxpos][2].px * 6 + HBTs[maxpos][1].px
            if HBTs[j].XiPaiScore > HBTs[maxpos].XiPaiScore or (HBTs[j].XiPaiScore == HBTs[maxpos].XiPaiScore and numj > numm) then
                maxpos = j
            end
        end
        local temp = HBTs[i]
        HBTs[i] = HBTs[maxpos]
        HBTs[maxpos] = temp
    end
    return HBTs;
end

return Cal
