local table=table
local math=math
local pairs = pairs
local Cal={}

Cal.specialPaiType=1
Cal.specialPaiFen={3,3,3,13}
function Cal.setStraightRule(straightRule)
   Cal.straightRule=straightRule or 2
end

function Cal.setFlushRule(flushRule)
   Cal.flushRule=flushRule or 2
end

-- 三花茶 1 三顺子 2 六对半 3 十三张 4 半大 5 半小 6 全大 7 全小 8 五对三条 9
-- 全黑 10 全红 11 全黑一点红 12 全红一点黑 13 四套三条 14 清一色龙 15
function Cal.setSpecialPaiType(specialPaiType)
	Cal.specialPaiType=specialPaiType
	if Cal.specialPaiType==1 then
		Cal.specialPaiFen={3,3,3,13}
	elseif Cal.specialPaiType==2 then
		Cal.specialPaiFen={3,3,6,13,3,3,6,6,9,20,20,10,10,6,52}
	end
end

function Cal.DeepCopy(obj)	
	local InTable = {};
	local function Func(obj)
		if type(obj) ~= "table" then   --??????????????  
			return obj;
		end
		local NewTable = {};  --???????????  
		InTable[obj] = NewTable;  --?????????????????InTable??????NewTable???????????  
		for k, v in pairs(obj) do  --?????key??Value????????  
			NewTable[Func(k)] = Func(v);
		end
		return setmetatable(NewTable, getmetatable(obj))--??????  
	end
	return Func(obj) --??????????????????????????  
end

function Cal.Length(t)
	local cnt=0
	for _,_ in pairs(t) do
		cnt=cnt+1
	end
	return cnt
end

function Cal.Compare(a,b)
	return (a.Number*4+a.Color)<(b.Number*4+b.Color)
end

function Cal.SortPoker(pokers)
    for i=1,#pokers-1 do
        local minp=i
        for j=i+1,#pokers do
	        if pokers[j].Number*4+pokers[j].Color<pokers[minp].Number*4+pokers[minp].Color then
		        minp=j
		    end
	    end
	    local temp=pokers[i]
	    pokers[i]=pokers[minp]
	    pokers[minp]=temp
    end
end

function Cal.IsTongHua(poker)
	for i=1,#poker-1 do
		if poker[i].Color~=poker[i+1].Color then
			return false
		end
	end
	return true
end

function Cal.IsShunZi(poker)
	local size=#poker
	for i=1,size-2 do
		if poker[i].Number+1~=poker[i+1].Number then
			return false
		end
	end
	if poker[size-1].Number+1==poker[size].Number then
		return true
	else
	    if poker[size].Number==14 and poker[1].Number==2 then
			return true
		end
		return false
	end
end

function Cal.PokerToMask(Poker)
    local mask={}
	for i=1,#Poker do
	    mask[Poker[i].Number*4+Poker[i].Color]=true
	end
	return mask
end

-- 散牌 1 对子 2 两对 3 三条 4 顺子 5 同花 6 葫芦 7 四条 8 同花顺 9	
function Cal.ComputePaixing(poker)
	local bucket={}
	for i=1,#poker do
		bucket[poker[i].Number]=bucket[poker[i].Number] and bucket[poker[i].Number]+1 or 1
	end
	local cnt={0,0,0,0}
	local index={0,0,0,0}
	for num,n in pairs(bucket) do
		cnt[n]=cnt[n]+1
		index[n]=num
	end
    if poker[5] then
		local tonghua=Cal.IsTongHua(poker)
		local shunzi=Cal.IsShunZi(poker)
        if tonghua and shunzi then
			return 9,Cal.PaiXingValue(9,poker)
		elseif cnt[4]==1 then
			return 8,Cal.PaiXingValue(8,poker,index[4])
		elseif cnt[3]==1 and cnt[2]==1 then
			return 7,Cal.PaiXingValue(7,poker,index[3])
		elseif tonghua then
			return 6,Cal.PaiXingValue(6,poker)
		elseif shunzi then
			return 5,Cal.PaiXingValue(5,poker)
		elseif cnt[3]==1 then
			return 4,Cal.PaiXingValue(4,poker,index[3])
		elseif cnt[2]==2 then
			return 3,Cal.PaiXingValue(3,poker,index[1])
		elseif cnt[2]==1 then
			return 2,Cal.PaiXingValue(2,poker,index[2])
		else
			return 1,Cal.PaiXingValue(1,poker)
		end
	else
		if cnt[3]==1 then
			return 4,Cal.PaiXingValue(4,poker)
		elseif cnt[2]==1 then
			return 2,Cal.PaiXingValue(2,poker)
		else
			return 1,Cal.PaiXingValue(1,poker)
		end
	end
end

function Cal.DuiZi(poker)
	if poker[5] then
		for i=1,4 do
			if poker[i].Number==poker[i+1].Number then
				return i
			end
		end
	else 
		if poker[1].Number==poker[2].Number then
			return 1,3
		else
			return 2,1
		end
	end
end

function Cal.DuiZi2(poker)
	local duizi={}
	local danzhang
	for i=1,4 do
		if poker[i].Number==poker[i+1].Number then
			table.insert(duizi,i)
		end
	end
	for i=1,5 do
		if i~=duizi[1] and i~=duizi[1]+1 and i~=duizi[2] and i~=duizi[2]+1 then
			danzhang=i
		end
	end
	return duizi,danzhang
end

function Cal.PaiXingValue(px,poker,num)
    if poker[5] then
		if px==9 then 
			if poker[5].Number==14 and poker[1].Number==2 then
				if Cal.straightRule==1 then
					if Cal.flushRule==1 then
						return poker[5].Color*537824+576011
					else
						return 2304044+poker[5].Color
					end
				else
					if Cal.flushRule==1 then
						return poker[5].Color*537824+203673
					else
						return 814692+poker[5].Color
					end
				end
			else
				if Cal.flushRule==1 then
					return poker[5].Color*38416*14+poker[5].Number*38416+poker[4].Number*2744+poker[3].Number*196+poker[2].Number*14+poker[1].Number
				else
					return (poker[5].Number*38416+poker[4].Number*2744+poker[3].Number*196+poker[2].Number*14+poker[1].Number)*4+poker[5].Color
				end
			end
		elseif px==5 then
			if poker[5].Number==14 and poker[1].Number==2 then
				if Cal.straightRule==1 then
					return 589835264+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
				else
					return 208561152+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
				end
			else
				return (poker[5].Number*38416+poker[4].Number*2744+poker[3].Number*196+poker[2].Number*14+poker[1].Number)*1024+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
			end
		elseif px==7 then 
			local duizi 
			for i=1,5 do
				if poker[i].Number~=num then
				duizi=poker[i].Number
				break
				end
			end
			return (num*14+duizi)*1024+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
		elseif px==4 or px==2 or px==8 then
			local index
			local danzhang={}
			for i=1,5 do
				if poker[i].Number==num then
				index=i
				else
				table.insert(danzhang,i)
				end
			end
			if px==4 then
				local value5=(num*196+poker[danzhang[2]].Number*14+poker[danzhang[1]].Number)*1024+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
				local value3=num
				return value5,value3
			elseif px==2 then
				local value5=(num*2744+poker[danzhang[3]].Number*196+poker[danzhang[2]].Number*14+poker[danzhang[1]].Number)*1024+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
				local value3=(num*14+poker[danzhang[3]].Number)*4+(index>danzhang[3] and poker[index].Color or poker[danzhang[3]].Color)
				return value5,value3
			else
				return (num*14+poker[danzhang[1]].Number)*4+poker[danzhang[1]].Color
			end
		elseif px==6 then
			if Cal.flushRule==1 then
				return poker[5].Color*38416*14+poker[5].Number*38416+poker[4].Number*2744+poker[3].Number*196+poker[2].Number*14+poker[1].Number
			else
				return (poker[5].Number*38416+poker[4].Number*2744+poker[3].Number*196+poker[2].Number*14+poker[1].Number)*4+poker[5].Color
			end
		elseif px==1 then
			local value5=(poker[5].Number*38416+poker[4].Number*2744+poker[3].Number*196+poker[2].Number*14+poker[1].Number)*1024+poker[5].Color*256+poker[4].Color*64+poker[3].Color*16+poker[2].Color*4+poker[1].Color
			local value3=(poker[5].Number*196+poker[4].Number*14+poker[3].Number)*4+poker[5].Color
			return value5,value3
		elseif px==3 then
			local duizi,danzhang=Cal.DuiZi2(poker)
			return (poker[duizi[2]].Number*196+poker[duizi[1]].Number*14+num)*1024+poker[duizi[2]+1].Color*256+poker[duizi[2]].Color*64+poker[duizi[1]+1].Color*16+poker[duizi[1]].Color*4+poker[danzhang].Color
		end
  	else
		if px==4 then
			return poker[3].Number
		elseif px==2 then
			local duizi,danzhang=Cal.DuiZi(poker)
			return (poker[duizi].Number*14+poker[danzhang].Number)*4+poker[3].Color
		elseif px==1 then
			return (poker[3].Number*196+poker[2].Number*14+poker[1].Number)*4+poker[3].Color
		end
  	end
end

function Cal.ComparePoker(poker1,poker2)
	if poker1.px>poker2.px then 
		return true
	elseif poker1.px<poker2.px then
		return false
	elseif poker1.px==poker2.px then
		if poker1[5] and not poker2[5] then
			return poker1.value3>poker2.value5 
		elseif not poker1[5] and poker2[5] then
			return poker1.value5>poker2.value3 
		else
			return poker1.value5>poker2.value5 
		end
	end
end

function Cal.SortHBTPai(Pai)
    for i=1,3 do
	    Pai[i].px,Pai[i].value5,Pai[i].value3=Cal.ComputePaixing(Pai[i])
    end
	for i=1,#Pai-1 do
		if Cal.ComparePoker(Pai[i], Pai[i+1]) then
			return i
		end
	end
	return 0
end

function Cal.SortPai(Pai,flag,s,e)
    s=s or 1
    e=e or #Pai
    if s>=e then
        return
    end
    local key=Pai[s]
    local i,j=s,e
    while i<j do
        while i<j and ((flag and not Cal.ComparePoker(Pai[j],key)) or (not flag and Cal.ComparePoker(Pai[j],key)))do
	        j=j-1
	    end
	    Pai[i]=Pai[j]
	    while i<j and ((flag and Cal.ComparePoker(Pai[i],key)) or (not flag and not Cal.ComparePoker(Pai[i],key)))do
	        i=i+1
	    end
	    Pai[j]=Pai[i]
    end
    Pai[i]=key
    Cal.SortPai(Pai,flag,s,i-1)
    Cal.SortPai(Pai,flag,i+1,e)
end

function Cal.IsShiSanZhang(poker)
	for i=1,13 do
		if poker[i].Number~=i+1 then
			return false
		end
	end
	return true
end

function Cal.IsSanHuaCha(Pai)
	for i=2,3 do
		if Pai[i].px~=6 and Pai[i].px~=9 then
			return false
		end
	end
	return Cal.IsTongHua(Pai[1])
end

function Cal.IsSanShunZi(Pai)
	for i=2,3 do
		if Pai[i].px~=5 and Pai[i].px~=9 then
			return false
		end
	end
	return Cal.IsShunZi(Pai[1])
end

function Cal.IsLiuDuiBan(poker)
	local bucket={}
	for i=1,13 do
		bucket[poker[i].Number]=bucket[poker[i].Number] and bucket[poker[i].Number]+1 or 1
	end
	local cnt=0
	for _,n in pairs(bucket) do
		if n==4 then
			cnt=cnt+2
		elseif n>=2 then
			cnt=cnt+1
		end
	end
	return cnt==6
end

function Cal.pow(x,n)
	return math.exp(n*math.log(x))
end

Cal.pow2={2,4,8,16,32,64,128,256,512,1024,2048,4096,8192}

function Cal.CombinePoker(poker,combinations,gpai,n,k,index,i)
	k=k or 0
	n=n or 5
	if k==n then
        local temp={}
		local key=0
		for h=1,n do
			temp[h]=poker[index[h]]
			key=key+Cal.pow2[index[h] ]
		end
		temp.px,temp.value5,temp.value3=Cal.ComputePaixing(temp)
		table.insert(combinations,temp)
		gpai[key]=temp
		return
	end
	index=index or {}
	i=i or 1
	for j=i,#poker-n+k+1 do
	   index[k+1]=j
	   Cal.CombinePoker(poker,combinations,gpai,n,k+1,index,j+1)
	end	
end

function Cal.Classification(combinations,paixing,n)
	n=n or 8
	for i=1,n do
		paixing[i]={}
	end
	for i=1,#combinations do
		local px=combinations[i].px
		if px>1 then
			if px==9 then
				table.insert(paixing[4],combinations[i])
				table.insert(paixing[5],combinations[i])
			end
			table.insert(paixing[px-1],combinations[i])
		end
	end
	for i=1,n do
		Cal.SortPai(paixing[i],true)
	end
end

function Cal.GenerateHBTv(poker, hbts, pos, mask, s, c,gpai,gpai3,index)
    s = s or 1
    c = c or 0
    mask = mask or {}
	if c==0 then
		s=1
	elseif c==5 then
		s=1
	end
	if c==5 then
		index=0
		for i=1,5 do	
			index=index+Cal.pow2[pos[i] ]
		end
		--尾道为散牌则返回
		index=gpai[index]
		if index.px==1 then
			return
		end
    elseif c == 10 then
        local temp = {}
		temp[3]=index
		local key=0
		for i=6,10 do	
			key=key+Cal.pow2[pos[i] ]
		end
		temp[2]=gpai[key]
		--中道比尾道大则返回
		if Cal.ComparePoker(temp[2],temp[3]) then
			return
		end
		key=0
		for i=1,13 do
			if not mask[i] then
				key=key+Cal.pow2[i]
			end
		end
		temp[1]=gpai3[key]
		--头道比中道大则返回
		if Cal.ComparePoker(temp[1],temp[2]) then
			return
		end
		
		temp.XiPaiType=0
		temp.XiPaiFen=0
		if Cal.IsSanShunZi(temp) then
			local flag=true
			for i=1,#hbts do
				if hbts[i].XiPaiType==2 or hbts[i].XiPaiType==1 then
					flag=false
					break
                end
			end
			if flag then
				local pai=Cal.DeepCopy(temp)
				pai.XiPaiType=2
				pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
				table.insert(hbts,pai)
			end
		elseif Cal.IsSanHuaCha(temp) then
			local flag=true
			for i=1,#hbts do
				if hbts[i].XiPaiType==1 or hbts[i].XiPaiType==2 then
					flag=false
					break
                end
			end
			if flag then
				local pai=Cal.DeepCopy(temp)
				pai.XiPaiType=1
				pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
				table.insert(hbts,pai)
			end
		end
        local flag = true
        for i = #hbts, 1, -1 do
			if hbts[i].XiPaiType==0 then
				if not Cal.ComparePoker(hbts[i][1], temp[1]) and not Cal.ComparePoker(hbts[i][2], temp[2]) and not Cal.ComparePoker(hbts[i][3], temp[3]) then
					table.remove(hbts, i)
				elseif not Cal.ComparePoker(temp[1], hbts[i][1]) and not Cal.ComparePoker(temp[2], hbts[i][2]) and not Cal.ComparePoker(temp[3], hbts[i][3]) then
					flag = false
				end
			end
        end
        if flag then
            for i = 1, #hbts do
				if hbts[i].XiPaiType==0 then
					if temp[1].px == hbts[i][1].px and temp[2].px == hbts[i][2].px and temp[3].px == hbts[i][3].px then
						flag = false
						if (temp[3].value5 > hbts[i][3].value5) or (temp[3].value5 == hbts[i][3].value5 and temp[2].value5 > hbts[i][2].value5) then
							hbts[i] = temp
							break
						end
					end
				end
            end
            if flag then
                table.insert(hbts, temp)
            end
        end
        return
    end
	local limit=0
	if c<5 then
		limit=5-c
	else
		limit=10-c
	end
    for i = s, #poker-limit+1 do
        if not mask[i] then
            mask[i] = true
            pos[c + 1] = i
            Cal.GenerateHBTv(poker, hbts, pos, mask, i + 1, c + 1, gpai,gpai3,index)
            mask[i] = nil
        end
    end
end

function Cal.CalSpecialPai(poker)
	local yitiaolong=Cal.IsShiSanZhang(poker)
	local tonghua=Cal.IsTongHua(poker)
	local hong,hei=0,0
	local bucket={}
	local heiindex,hongindex
	local quanda,quanxiao,banda,banxiao=true,true,true,true
	for i=1,#poker do
		if poker[i].Number>10 then
			quanxiao=false
			if poker[i].Number~=14 then
				banxiao=false
			end
		end
		if poker[i].Number<6 or poker[i].Number==14 then
			quanda=false
			if poker[i].Number~=14 then
				banda=false
			end
		end
		if poker[i].Color==2 or poker[i].Color==4 then
			hei=hei+1
			heiindex=i
		else
			hong=hong+1
			hongindex=i
		end
		bucket[poker[i].Number]=bucket[poker[i].Number] and bucket[poker[i].Number]+1 or 1
	end
	
	if quanxiao then
		banxiao=false
	end
	if quanda then
		banda=false
	end
	
	if yitiaolong and tonghua then
		local poker=Cal.DeepCopy(poker)
		local pai={{},{},{}}
		pai[1]={poker[1],poker[2],poker[3]}
		pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
		pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
		pai.XiPaiType=15
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		return pai
	end
	
	if hong==13 or hei==13 then
		local poker=Cal.DeepCopy(poker)
		local pai={{},{},{}}
		pai[1]={poker[1],poker[2],poker[3]}
		pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
		pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
		pai.XiPaiType=hong==13 and 11 or 10
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		return pai
	end
	
	if hong==12 or hei==12 then
		local index=heiindex or hongindex
		local poker=Cal.DeepCopy(poker)
		local p=poker[index]
		table.remove(poker,index)
		local pai={{},{},{}}
		pai[1]={poker[1],poker[2],poker[3]}
		pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
		pai[3]={poker[9],poker[10],poker[11],poker[12],p}
		pai.XiPaiType=hong==12 and 13 or 12
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		return pai
	end
	
	local cnt={0,0,0,0}
	local index={0,0,0,0}
	for num,n in pairs(bucket) do	
		cnt[n]=cnt[n]+1	
		index[n]=num
	end
	
	if cnt[3]==1 then
		local count=cnt[2]*2+cnt[4]*4
		if count==10 then
			local poker=Cal.DeepCopy(poker)
			for i=1,13 do
				if poker[i].Number==index[3] then
					local santiao={}
					santiao[1]=poker[i]
					santiao[2]=poker[i+1]
					santiao[3]=poker[i+2]
					table.remove(poker,i)
					table.remove(poker,i)
					table.remove(poker,i)
					poker[11]=santiao[1]
					poker[12]=santiao[2]
					poker[13]=santiao[3]
					local pai={{},{},{}}
					pai[1]={poker[1],poker[2],poker[3]}
					pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
					pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
					pai.XiPaiType=9
					pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
					return pai
				end
			end
		end
	end
	
	if cnt[3]>=3 then
		if cnt[3]==4 then
			for i=1,13 do
				if poker[i].Number==index[1] then
					local danzhang=poker[i]
					table.remove(poker,i)
					local pai={{},{},{}}
					pai[1]={poker[1],poker[2],poker[3]}
					pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
					pai[3]={poker[9],poker[10],poker[11],poker[12],danzhang}
					pai.XiPaiType=14
					pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
					return pai
				end
			end
			return
		elseif cnt[4]==1 then
			local pai={{},{},{}}
			pai[1]={poker[1],poker[2],poker[3]}
			pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
			pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
			pai.XiPaiType=14
			pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
			return pai
		end
	end
	
	if quanda or quanxiao then
		local poker=Cal.DeepCopy(poker)
		local pai={{},{},{}}
		pai[1]={poker[1],poker[2],poker[3]}
		pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
		pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
		pai.XiPaiType=quanda and 7 or 8
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		return pai
	end
	
	if banda or banxiao then
		local poker=Cal.DeepCopy(poker)
		local pai={{},{},{}}
		pai[1]={poker[1],poker[2],poker[3]}
		pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
		pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
		pai.XiPaiType=banda and 5 or 6
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		return pai
	end
end

function Cal.GenerateHBT(poker,gpai)
    local HBTs = {}
    local hbts = {}
    local pos = {}
    local mask
    local s
    local c
    for i = 1, 10 do
        pos[i] = 0
    end
	local index
	local gpai3={}
	local combinations3={}
	Cal.CombinePoker(poker,combinations3,gpai3,3)
    Cal.GenerateHBTv(poker, hbts, pos, mask, s, c,gpai,gpai3,index)
	local pai={{},{},{}}
	if Cal.IsShiSanZhang(poker) then
		pai[1]={poker[1],poker[2],poker[3]}
		pai[2]={poker[4],poker[5],poker[6],poker[7],poker[8]}
		pai[3]={poker[9],poker[10],poker[11],poker[12],poker[13]}
		pai.XiPaiType=4
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		table.insert(hbts,pai)
	elseif Cal.IsLiuDuiBan(poker) then
		local poker=Cal.DeepCopy(poker)
		local danzhang
		local bucket={}
		for i=1,13 do
			bucket[poker[i].Number]=bucket[poker[i].Number] and bucket[poker[i].Number]+1 or 1
		end
		for i=1,13 do
			if bucket[poker[i].Number]%2==1 then
				danzhang=i
				break
			end
		end
		table.insert(pai[1],poker[danzhang])
		table.remove(poker,danzhang)
		local cnt=1
		for i=1,12 do
			if cnt<=2 then
				table.insert(pai[1],poker[i])
			elseif cnt<=7 then
				table.insert(pai[2],poker[i])
			else
				table.insert(pai[3],poker[i])
			end
			cnt=cnt+1
		end
		pai.XiPaiType=3
		pai.XiPaiFen=Cal.specialPaiFen[pai.XiPaiType]
		table.insert(hbts,pai)

	end
	if Cal.specialPaiType==2 then
		local pai=Cal.CalSpecialPai(poker)
		if pai then
			table.insert(hbts,pai)
		end
	end
    HBTs = Cal.DeepCopy(hbts)
    for i = 1, #HBTs - 1 do
        local maxpos = i
        for j = i + 1, #HBTs do
			local flag=true
			if HBTs[j].XiPaiType>0 or HBTs[maxpos].XiPaiType>0 then
				flag=HBTs[j].XiPaiFen>HBTs[maxpos].XiPaiFen
			else 
				local numj = HBTs[j][3].px * 9 * 9 + HBTs[j][2].px * 9 + HBTs[j][1].px
				local numm = HBTs[maxpos][3].px * 9 * 9 + HBTs[maxpos][2].px * 9 + HBTs[maxpos][1].px
				flag=numj>numm
				if HBTs[maxpos][3].px<8 and HBTs[maxpos][1].px~=4 and HBTs[j][1].px==4 then
					flag=true
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
	
	for i=#HBTs,1,-1 do
		if HBTs[i].XiPaiType>0 and i~=1 then
			table.remove(HBTs,i)
		end
	end
		
    return HBTs;
end

return Cal