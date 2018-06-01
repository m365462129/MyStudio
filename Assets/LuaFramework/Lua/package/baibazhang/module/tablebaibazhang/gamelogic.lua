local table = table
local math = math
local pairs = pairs
local Cal = {}

function Cal.SetValueType(valuetype)
   Cal.valuetype=valuetype or 0
end

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
   if poker[3] then
		return poker[1].Color==poker[2].Color and poker[1].Color==poker[3].Color 
	else
		return poker[1].Color==poker[2].Color
	end
end

function Cal.IsShunZi(poker)
    return (poker[1].Number + 1 == poker[2].Number and poker[1].Number + 2 == poker[3].Number) or
    (poker[1].Number == 2 and poker[2].Number == 3 and poker[3].Number == 14)
end

function Cal.IsDuiZi(poker)
     if poker[3] then
		return poker[1].Number==poker[2].Number or poker[1].Number==poker[3].Number or poker[2].Number==poker[3].Number
	else
		return poker[1].Number==poker[2].Number
	end
end

function Cal.DuiZi(poker)
    if poker[1].Number == poker[2].Number then
        return 1, 3
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

function Cal.ComputePaixing(poker)
    if poker[3] then
		if Cal.IsSanTiao(poker) then
			return 4,Cal.PaiXingValue(4,poker)
		elseif Cal.IsShunZi(poker) then
			local px=Cal.IsTongHua(poker) and 5 or 3
			return px,Cal.PaiXingValue(px,poker)
		end
	end
	if Cal.IsDuiZi(poker) then
		return 2,Cal.PaiXingValue(2,poker)
	else
		return 1,Cal.PaiXingValue(1,poker)
	end 
end

function Cal.PaiXingValue(px, poker)
    if poker[3] then
		if px==2 then 
			local duizi,danpai=Cal.DuiZi(poker)
			local value3=(poker[duizi].Number*14+poker[danpai].Number)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
			local value2=poker[duizi+1].Number*4*4+poker[duizi+1].Color*4+poker[duizi].Color
			return value3,value2
		elseif px==3 or px==5 then 
			if poker[3].Number==14 and poker[1].Number==2 then
				if Cal.valuetype==0 then
					return (3*14*14+2*14+1)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
				elseif Cal.valuetype==1 then
					return (14*14*14+13*14+11)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
				elseif Cal.valuetype==2 then
					return (15*14*14+14*14+13)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
				end
			else
				return (poker[3].Number*14*14+poker[2].Number*14+poker[1].Number)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
			end
		elseif px==1 then
			local value3=(poker[3].Number*14*14+poker[2].Number*14+poker[1].Number)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
			local value2=(poker[3].Number*14+poker[2].Number)*4*4+poker[3].Color*4+poker[2].Color
			return value3,value2
		else
			return (poker[3].Number*14*14+poker[2].Number*14+poker[1].Number)*4*4*4+poker[3].Color*4*4+poker[2].Color*4+poker[1].Color
		end
	else
		if px==2 then
			return poker[2].Number*4*4+poker[2].Color*4+poker[1].Color
		elseif px==1 then
			return (poker[2].Number*14+poker[1].Number)*4*4+poker[2].Color*4+poker[1].Color
		end
    end
end

function Cal.ComparePoker(poker1, poker2)
    if poker1.px>poker2.px then 
		return 1
	elseif poker1.px<poker2.px then
		return -1
	elseif poker1.px==poker2.px then
		if poker1[3] and not poker2[3] then
			return poker1.value2>poker2.value3 and 1 or -1
		elseif not poker1[3] and poker2[3] then
			return poker1.value3>poker2.value2 and 1 or -1
		else
			if poker1.value3>poker2.value3 then
				return 1
			elseif poker1.value3<poker2.value3 then
				return -1
			else
				return 0
			end
		end
	end
end


function Cal.SortHBTPai(Pai)
    for i=1,3 do
	    Pai[i].px,Pai[i].value3,Pai[i].value2=Cal.ComputePaixing(Pai[i])
    end
	for i=1,#Pai-1 do
		if Cal.ComparePoker(Pai[i], Pai[i+1])==1 then
			return i
		end
	end
	return 0
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
        while i < j and ((flag and Cal.ComparePoker(Pai[j], key)<=0) or (not flag and Cal.ComparePoker(Pai[j], key)==1)) do
            j = j - 1
        end
        Pai[i] = Pai[j]
        while i < j and ((flag and Cal.ComparePoker(Pai[i], key)==1) or (not flag and Cal.ComparePoker(Pai[i], key)<=0)) do
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
                if res == 5 then
					table.insert(p.PaiXing[4],Cal.deepcopy(combinations[i]))
					table.insert(p.PaiXing[2],Cal.deepcopy(combinations[i]))
                else
					table.insert(p.PaiXing[res - 1],Cal.deepcopy(combinations[i]))
                end
            end
        end
    end
end

function Cal.IsSanShun(Pai)
    for i=2,3 do
		if Pai[i].px~=3 and Pai[i].px~=5 then
			return false
		end
	end
	if Pai[1][1].Number+1==Pai[1][2].Number then
		return true
	elseif Pai[1][2].Number==14 and Pai[1][1].Number==2 then
		return true
	end
end

function Cal.IsSiDui(Poker)
	local cnt=0
	for i=1,7,2 do
	    if Poker[i].Number==Poker[i+1].Number then
			cnt=cnt+1
		end
	end
	return cnt==4
end

function Cal.IsSiTiao(Poker)
	local cnt=0
	for i=1,5 do
	    if Poker[i].Number==Poker[i+3].Number then
			return true
		end
	end
	return false
end

function Cal.IsShuangSiTiao(Poker)
     return Poker[1].Number==Poker[4].Number and Poker[5].Number==Poker[8].Number
end

function Cal.IsBaGuai(Poker)
    for i=1,7 do
		if Poker[i].Number==Poker[i+1].Number then
		return false
		end
	end
	for i=1,6 do
		if Poker[i].Number+1==Poker[i+1].Number and Poker[i+1].Number+1==Poker[i+2].Number then
		return false
		end
	end
	if Poker[8].Number==14 and Poker[1].Number==2 and Poker[2].Number==3 then
		return false
	end
    local index=0
	for i=1,7,2 do
		if Poker[i].Number+1~=Poker[i+1].Number then
			index=i
			break
		end
	end
	if index==0 then
		return true
	elseif Poker[8].Number==14 then
		index=0
		for i=2,6,2 do
			if Poker[i].Number+1~=Poker[i+1].Number then
				index=i
				break
			end
		end
		if index==0 then
			if Poker[1].Number==2 then
				return true
			end
		end
	end
	return false
end

function Cal.IsZaLong(Poker)
    local j=0
	for i=1,7 do
	    if Poker[i].Number+1~=Poker[i+1].Number then
	        j=i
		    break
	    end
	end
	if j==0 then
	    return true
    elseif j==7 then
	    if Poker[8].Number==14 and Poker[1].Number==2 then
	        return true
	    end
	end
	return false
end

function Cal.IsSameColor(Poker)
    local index=0
	for i=1,7 do
		if Poker[i].Color~=Poker[i+1].Color then
			index=i
			break
		end
	end
	if index==0 then
		return true
	end
	return false
end

function Cal.ComputeXiPai(Pai, Poker)
    if Cal.IsSanShun(Pai) then
		local temp=0
		if Cal.IsZaLong(Poker) then
			if Cal.IsSameColor(Poker) then
				return 10,108
			else
				temp=9
			end
		end
		if Cal.IsTongHua(Pai[3]) then
			local tonghua={}
			if Cal.IsTongHua(Pai[1]) then
				tonghua[1]=true
			end
			if Cal.IsTongHua(Pai[2]) then
				tonghua[2]=true
			end
			if tonghua[1] and tonghua[2] then
				return 4 ,38
			elseif tonghua[2] then
				return 3,18
			end
			if temp==9 then
				return 9,16
			end
			return 2,8
		end
		if temp==9 then
			return 9,16
		end
		return 1,3
	end
	
	if Cal.IsShuangSiTiao(Poker) then
		return 8,16
	end
	
	if Cal.IsSiTiao(Poker) then
		return 7,8
	end
	
	if Cal.IsSiDui(Poker) then
		return 6,8
	end
	
	if Cal.IsBaGuai(Poker) then
		return 5,8
	end
	
	return 0,0
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

function Cal.GenerateHBTv(poker, hbts, pos, mask, s, c,xipai)
    s = s or 1
    c = c or 0
    mask = mask or {}
	if c==0 then
		s=1
	elseif c==2 then
		s=1
	elseif c==5 then
		s=1
	end
    if c == 8 then
        local temp = {}
		table.insert(temp,{poker[pos[1]],poker[pos[2]]})
		table.insert(temp,{poker[pos[3]],poker[pos[4]],poker[pos[5]]})
		table.insert(temp,{poker[pos[6]],poker[pos[7]],poker[pos[8]]})
        if Cal.SortHBTPai(temp)>0 then
			return
		end
		for i=1,3 do
			temp[i].px,temp[i].value3,temp[i].value2=Cal.ComputePaixing(temp[i])
		end
        temp.XiPaiType,temp.XiPaiScore=Cal.ComputeXiPai(temp, poker)
		if temp.XiPaiType>0 then
			if #xipai==0 or temp.XiPaiScore>xipai[1].XiPaiScore then
                xipai[1]=temp
			end
		end
        local flag = true
        for i = #hbts, 1, -1 do
            if Cal.ComparePoker(hbts[i][1], temp[1])<=0 and Cal.ComparePoker(hbts[i][2], temp[2])<=0 and Cal.ComparePoker(hbts[i][3], temp[3])<=0 then
                table.remove(hbts, i)
            elseif Cal.ComparePoker(temp[1], hbts[i][1])<=0 and Cal.ComparePoker(temp[2], hbts[i][2])<=0 and Cal.ComparePoker(temp[3], hbts[i][3])<=0 then
                flag = false
            end
        end
        if flag then
            for i = 1, #hbts do
                if temp[1].px == hbts[i][1].px and temp[2].px == hbts[i][2].px and temp[3].px == hbts[i][3].px then
                    flag = false
                    if  (temp[1].px==2 and temp[1][1].Number>hbts[i][1][1].Number) or (temp[3].value3 > hbts[i][3].value3) or (temp[3].value3 == hbts[i][3].value3 and temp[2].value3 > hbts[i][2].value3) then
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
            Cal.GenerateHBTv(poker, hbts, pos, mask, i + 1, c + 1,xipai)
            mask[i] = nil
        end
    end
end

function Cal.GenerateHBT(poker,xipai)
    local HBTs = {}
    local hbts = {}
    local pos = {}
    local mask
    local s
    local c
    for i = 1, 8 do
        pos[i] = 0
    end
    Cal.GenerateHBTv(poker, hbts, pos, mask, s, c, xipai)
    HBTs = Cal.deepcopy(hbts)
    for i = 1, #HBTs - 1 do
        local maxpos = i
        for j = i + 1, #HBTs do
            local numj = HBTs[j][3].px * 6 * 6 + HBTs[j][2].px * 6 + HBTs[j][1].px
            local numm = HBTs[maxpos][3].px * 6 * 6 + HBTs[maxpos][2].px * 6 + HBTs[maxpos][1].px
			local flag=numj>numm
			if HBTs[j][1].px==2 and HBTs[maxpos][1].px~=2 then
				flag=true
			elseif HBTs[j][1].px~=2 and HBTs[maxpos][1].px==2 then
				flag=false
			elseif HBTs[j][1].px==2 and HBTs[maxpos][1].px==2 then
				if HBTs[j][1][1].Number>HBTs[maxpos][1][1].Number then
					flag=true
				elseif HBTs[j][1][1].Number<HBTs[maxpos][1][1].Number then
					flag=false
				end
			end

            if flag then
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
