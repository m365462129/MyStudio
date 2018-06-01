Config = {}

local ModuleCache = ModuleCache
local Config = Config
Config.chatShotTextList = {
        "你太牛啦！！！",
        "O(∩_∩)O哈哈哈~，手气真是好！",
        "快点出牌咯~！~",
        "今天真高兴~",
        "这口吃的好。",
        "你放炮，我不胡。",
        "你家里是开银行的吧！",
        "不好意思我有事，要先离开一会。",
        "你的牌打得太好啦！",
        "大家好！很高兴见到各位。",
        "怎么又断线了，网络怎么这么差啊",
}

---配置麻将是否开放3D模式
--- Is3D ：1 开启3D和2D切换， 2 使用新框架不开启3D
--- def3dOr2d ：1 游戏默认设置为3D模式，2游戏默认设置为2D模式
Config.mj3dSetting =
{
    ["DHHUBEIQP_HSHH"] = {Is3D = 1,def3dOr2d = 1},---湖北黄石晃晃
    ["DHHUBEIQP_DYKKF"] = {Is3D = 1,def3dOr2d = 1},---湖北大冶开口番
    ["DHHUBEIQP_HGXS"] = {Is3D = 1,def3dOr2d = 1},---湖北浠水麻将

    ["DHAHQP_CZDZ"] = {Is3D = 2,def3dOr2d = 2},---安徽东至麻将
    ["DHAHQP_HNAF"] = {Is3D = 2,def3dOr2d = 2},---安徽淮南安丰麻将
    ["DHAHQP_BBBB"] = {Is3D = 2,def3dOr2d = 2},---安徽蚌埠麻将

    ["DHHNQP_HZMJ"] = {Is3D = 1,def3dOr2d = 1},---湖南红中麻将
    ["DHHNQP_CSMJZZ"] = {Is3D = 1,def3dOr2d = 1},---湖南转转麻将

    ------------shanxi_package------------------------------------
    ["DHHUBEIQP_ESMJ"] = {Is3D = 1,def3dOr2d = 1},
    ----------------end-------------------------------------------
}

function Config.get_mj3dSetting(GameID)
    local setting = Config.mj3dSetting[GameID]
    if setting then
        return setting
    end
    return { def3dOr2d = 2 }
end


function Config.GetWanfaIdx(wanfa)
    wanfa = wanfa .. ''
    local list = Config.get_list()
    for i = 1, #list do
        if (wanfa == list[i].wanfaType) then
            return i, list[i].name or "", list[i].playModName or ''
        end
    end
    local goldlist = Config.get_gold_list()
    for i = 1, #goldlist do
        if (wanfa == goldlist[i].wanfaType) then
            return i, goldlist[i].name or "", goldlist[i].playModName or ''
        end
    end
    return 1
end

function Config.get_create_name_by_wanfatype(wanfaType)
    local list = Config.get_list()
    for i=1,#list do
       if(wanfaType == list[i].wanfaType) then
            return list[i].createName or ""
       end
    end
end

function Config.get_create_name(index)
   local list = Config.get_list()
   for i=1,#list do
       if(i == index) then
            return list[i].createName or ""
       end
   end
end

function Config.get_wanfaType_name(index)
    local list = Config.get_list()
    for i=1,#list do
        if(i == index) then
            return list[i].wanfaType or ""
        end
    end
end
--获取金币场数据
function Config.get_gold_list()
    return ModuleCache.PlayModeUtil.get_gold_playmodel_data(ModuleCache.AppData.Game_Name)
end
--获取金币场wanfaname
function Config.get_gold_wanfaType_name(index)
    local list = Config.get_gold_list()
    for i = 1, #list do
        if (i == index) then
            return list[i].wanfaType or ""
        end
    end
end
function Config.get_list()
    return ModuleCache.PlayModeUtil.get_playmodel_data(nil, ModuleCache.AppData.Game_Name)
end

function Config.caculate_price(roundCount, playerNum, payType)
    -- 基础价格 7 12 20
    local basePrice = 0;
    if (roundCount == 4) then
        basePrice = 7
    elseif (roundCount == 8) then
        basePrice = 12
    elseif (roundCount == 16) then
        basePrice = 20
    end
    local totalCost = 0
    if(payType == 0) then
        totalCost = basePrice * playerNum
    elseif(payType == 1) then
        totalCost = basePrice
    elseif(payType == 2) then
        totalCost = basePrice * playerNum
    end
    return totalCost
end

-- 通用算法
function Config.caculate_price1(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = {["12"] = 10,["13"] = 7,["14"] = 5,["02"] = 20,["03"] = 20,["04"] = 20},
        ["8"] = {["12"] = 20,["13"] = 14,["14"] = 10,["02"] = 40,["03"] = 40,["04"] = 40},
        ["16"] = {["12"] = 40,["13"] = 27,["14"] = 20,["02"] = 80,["03"] = 80,["04"] = 80},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end

-- 普宁逼胡、客家麻将
function Config.caculate_price1_1(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = {["13"] = 4,["14"] = 3,["03"] = 12,["04"] = 12},
        ["8"] = {["13"] = 8,["14"] = 6,["03"] = 24,["04"] = 24},
        ["16"] = {["13"] = 16,["14"] = 12,["03"] = 48,["04"] = 48},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end

function Config.caculate_price2(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = {["12"] = 8,["13"] = 5,["14"] = 4,["02"] = 15,["03"] = 15,["04"] = 15},
        ["8"] = {["12"] = 15,["13"] = 10,["14"] = 8,["02"] = 30,["03"] = 30,["04"] = 30},
        ["16"] = {["12"] = 30,["13"] = 20,["14"] = 15,["02"] = 60,["03"] = 60,["04"] = 60},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end

-- 曲靖飞小鸡
function Config.caculate_price2_1(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = {["13"] = 5,["14"] = 5,["03"] = 15,["04"] = 20},
        ["8"] = {["13"] = 9,["14"] = 9,["03"] = 27,["04"] = 36},
        ["12"] = {["13"] = 14,["14"] = 14,["03"] = 42,["04"] = 56},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end

-- 扬州麻将
function Config.caculate_price2_2(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = 7,
        ["8"] = 12,
        ["16"] = 20,
    }
    local totalCost = prices[roundCount .. ""]
    if(payType == 1)then  --AA
        totalCost = totalCost
    elseif(payType == 0)then
        totalCost = totalCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = totalCost * playerNum
    end
    return totalCost
end

-- 连云港新浦麻将
function Config.caculate_price_lygxp(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = 4,
        ["8"] = 7,
        ["16"] = 14,
    }
    local totalCost = prices[roundCount .. ""]
    if(payType == 1)then  --AA
        totalCost = totalCost
    elseif(payType == 0)then
        totalCost = totalCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = totalCost * playerNum
    end
    return totalCost
end

-- 广西红中
function Config.caculate_price2_3(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = 5,
        ["8"] = 9,
        ["16"] = 18,
    }
    local totalCost = prices[roundCount .. ""]
    if(payType == 1)then  --AA
        totalCost = totalCost
    elseif(payType == 0)then
        totalCost = totalCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = totalCost * playerNum
    end
    return totalCost
end

-- 卡五星
function Config.caculate_price2_4(roundCount, playerNum, payType)
    local prices =
    {
        ["8"] = {["13"] = 10,["12"] = 15,["03"] = 30,["02"] = 30},
        ["16"] = {["13"] = 20,["12"] = 30,["03"] = 60,["02"] = 60},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end

function Config.caculate_price2_5(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = {["13"] = 5,["14"] = 5,["03"] = 15,["04"] = 20,["23"] = 15,["24"] = 20},
        ["8"] = {["13"] = 7,["14"] = 7,["03"] = 21,["04"] = 30,["23"] = 21,["24"] = 30},
        ["16"] = {["13"] = 15,["14"] = 15,["03"] = 45,["04"] = 60,["23"] = 45,["24"] = 60},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end

function Config.caculate_price3(roundCount, playerNum, payType)
    local totalCost = roundCount
    if(payType == 1)then  --AA
        totalCost = roundCount
    elseif(payType == 0)then
        totalCost = roundCount * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = roundCount * playerNum
    end
    return totalCost
end

-- 比鸡
function Config.caculate_price4(roundCount, playerNum, payType)
    local perPlayerCost = 10
    if(roundCount == 8)then
        perPlayerCost = 8
    elseif(roundCount == 16)then
        perPlayerCost = 16
    elseif(roundCount == 24)then
        perPlayerCost = 24
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

-- 十三张
function Config.caculate_price_shi_san_zhang(roundCount, playerNum, payType)
    local perPlayerCost = 10
    if(roundCount == 8)then
        perPlayerCost = 8
    elseif(roundCount == 16)then
        perPlayerCost = 16
    elseif(roundCount == 24)then
        perPlayerCost = 24
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0 or payType == 2)then
        if(roundCount == 8)then
            totalCost = 30
        elseif(roundCount == 16)then
            totalCost = 50
        elseif(roundCount == 24)then
            totalCost = 70
        end
    end
    return totalCost
end

-- 掼蛋
function Config.caculate_price5(roundCount, playerNum, payType)
    local perPlayerCost = 10
    if(roundCount == 4)then
        perPlayerCost = 10
    elseif(roundCount == 6)then
        perPlayerCost = 15
    elseif(roundCount == 12)then
        perPlayerCost = 30
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

-- 跑得快
function Config.caculate_price6(roundCount, playerNum, payType)
    local perPlayerCost = 10
    if(roundCount == 6 or roundCount == 8)then
        perPlayerCost = 10
    elseif(roundCount == 12)then
        perPlayerCost = 20
    elseif(roundCount == 18)then
        perPlayerCost = 30
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

-- 斗牛
function Config.caculate_price7(roundCount, playerNum, payType, bankerType)
    local perPlayerCost = 10
    if(bankerType) then
        if(roundCount == 10)then
            perPlayerCost = 10
        elseif(roundCount == 20)then
            perPlayerCost = 20
        elseif(roundCount == 30)then
            perPlayerCost = 30
        end
    else
        if(roundCount == 8)then
            perPlayerCost = 12
        elseif(roundCount == 16)then
            perPlayerCost = 24
        elseif(roundCount == 10)then
            perPlayerCost = 10
        elseif(roundCount == 20)then
            perPlayerCost = 20
        elseif(roundCount == 30)then
            perPlayerCost = 30
        end
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

-- 长牌
function Config.caculate_price8(roundCount, playerNum, payType, bankerType)
    local perPlayerCost = 10
    if(roundCount == 6)then
        perPlayerCost = 10
    elseif(roundCount == 9)then
        perPlayerCost = 15
    elseif(roundCount == 12)then
        perPlayerCost = 20
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

--- 大冶字牌
function Config.caculate_price9(roundCount, playerNum, payType, bankerType)

    roundCount = roundCount or 8

    local perPlayerCost = 5

    if (roundCount == 8) then
        perPlayerCost = 5
    elseif (roundCount == 12) then
        perPlayerCost = 8
    elseif (roundCount == 18) then
        perPlayerCost = 12
    end

    local totalCost = perPlayerCost
    if (payType == 1) then
        --AA
        totalCost = perPlayerCost
    elseif (payType == 0) then
        totalCost = perPlayerCost * playerNum
    elseif (payType == 2) then
        --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end


--- 大冶字牌
function Config.caculate_priceXX(roundCount, playerNum, payType, bankerType)

    roundCount = roundCount or 8

    local perPlayerCost = 5

    if (roundCount == 8) then
        perPlayerCost = 5
    elseif (roundCount == 12) then
        perPlayerCost = 8
    elseif (roundCount == 18) then
        perPlayerCost = 12
    end

    local totalCost = perPlayerCost
    if (payType == 1) then
        --AA
        totalCost = perPlayerCost
    elseif (payType == 0) then
        totalCost = perPlayerCost * playerNum
    elseif (payType == 2) then
        --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

--斗地主
function Config.caculate_price10(roundCount, playerNum, payType, bankerType)
    local perPlayerCost = 10
    
    if(roundCount == 8)then
        perPlayerCost = 10
    elseif(roundCount == 12)then
        perPlayerCost = 16
    elseif(roundCount == 18)then
        perPlayerCost = 24
    end

    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

-- 炸金花
function Config.caculate_price_zhajinhua(roundCount, playerNum, payType ,bankerType)
    local perPlayerCost = 10
    if(roundCount == 6 or roundCount == 8)then
        perPlayerCost = 10
    elseif(roundCount == 12)then
        perPlayerCost = 20
    elseif(roundCount == 18)then
        perPlayerCost = 30
    end
    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

function Config.caculate_price_guilin(roundCount, playerNum, payType ,bankerType)
    if payType == 1 then
        return roundCount/10*9 

    elseif payType == 0 then
        return roundCount/10*27
    end
    return 20
end


function Config.caculate_price_sangong(roundCount, playerNum, payType, bankerType)
    local totalCost = 0
    if(payType == 1)then  --AA
        if 10 == roundCount then
            totalCost = 10
        end
        if 20 == roundCount then
            totalCost = 20
        end
    else  ---房主和大赢家
        if 10 == roundCount then
            totalCost = 50
        end
        if 20 == roundCount then
            totalCost = 100
        end
    end
    return totalCost
end


--黄石晃晃
function Config.caculate_price_hshh(roundCount, playerNum, payType, bankerType)
    if 8 == roundCount then
        if 1 == payType then --AA制
            return 8
        else
            return 8 * playerNum
        end
    elseif 16 == roundCount then
        if 1 == payType then --AA制
            return 16
        else
            return 16 * playerNum
        end
    end
    return 0
end


--逮狗腿
function Config.caculate_price_daigoutui(roundCount, playerNum, payType, bankerType)
    local perPlayerCost = 10

    if(roundCount == 5)then
        perPlayerCost = 12
    elseif(roundCount == 8)then
        perPlayerCost = 20
    elseif(roundCount == 12)then
        perPlayerCost = 30
    end

    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

--50k
function Config.caculate_price_50k(roundCount, playerNum, payType, bankerType)
    local perPlayerCost = 8

    if(roundCount == 4)then
        perPlayerCost = 8
    elseif(roundCount == 8)then
        perPlayerCost = 16
    elseif(roundCount == 12)then
        perPlayerCost = 24
    end

    local totalCost = perPlayerCost
    if(payType == 1)then  --AA
        totalCost = perPlayerCost
    elseif(payType == 0)then
        totalCost = perPlayerCost * playerNum
    elseif(payType == 2)then  --大赢家
        totalCost = perPlayerCost * playerNum
    end
    return totalCost
end

--九江湖口麻将
function Config.caculate_price_jjhk(roundCount, playerNum, payType, bankerType)
    if 1 == payType then  ---AA制
        if 4 == roundCount then
            return 5
        elseif 8 == roundCount then
            return 9
        elseif 16 == roundCount then
            return 18
        end
    elseif 0 == payType then ---房主支付
        if 4 == roundCount then
            return 5 * playerNum
        elseif 8 == roundCount then
            return 9 * playerNum
        elseif 16 == roundCount then
            return 18 * playerNum
        end
    elseif 2 == payType then ---大赢家支付
        if 4 == roundCount then
            return 5 * playerNum
        elseif 8 == roundCount then
            return 9 * playerNum
        elseif 16 == roundCount then
            return 18 * playerNum
        end
    end
end

--北海推倒胡消耗
function Config.caculate_price_bhtdh(roundCount, playerNum, payType, bankerType)
    if 1 == payType then  ---AA制
        if 4 == roundCount then
            return 4
        elseif 8 == roundCount then
            return 6
        elseif 16 == roundCount then
            return 12
        end
    elseif 0 == payType or 2 == payType then ---房主支付,大贏家支付
        if 4 == roundCount then
            return 4 * playerNum
        elseif 8 == roundCount then
            return 6 * playerNum
        elseif 16 == roundCount then
            return 12 * playerNum
        end
    end
end

--湖北浠水麻将
function Config.caculate_price_xsmj(roundCount, playerNum, payType, bankerType)
    if 1 == payType then  ---AA制
        if 8 == roundCount then
            return 10
        elseif 16 == roundCount then
            return 20
        end
    elseif 0 == payType or 2 == payType then ---房主支付,大贏家支付
        if 8 == roundCount then
            return 10 * playerNum
        elseif 16 == roundCount then
            return 20 * playerNum
        end
    end
end

--湖南转转麻将
function Config.caculate_price_HNQP_CSMJZZ(roundCount, playerNum, payType, bankerType)
    if 1 == payType then  ---AA制
        if 4 == roundCount then
            if 3 == playerNum then
                return 5
            elseif 4 == playerNum then
                return 4
            end
        elseif 8 == roundCount then
            if 3 == playerNum then
                return 10
            elseif 4 == playerNum then
                return 8
            end
        elseif 16 == roundCount then
            if 3 == playerNum then
                return 20
            elseif 4 == playerNum then
                return 15
            end
        end
    elseif 0 == payType or 2 == payType then ---房主支付,大贏家支付
        if 4 == roundCount then
            return 15
        elseif 8 == roundCount then
            return 30
        elseif 16 == roundCount then
            return 60
        end
    end
end
--湖南红中麻将
function Config.caculate_price_HNQP_HZMJ(roundCount, playerNum, payType, bankerType)
    if 1 == payType then  ---AA制
    if 4 == roundCount then
        if 3 == playerNum then
            return 5
        elseif 4 == playerNum then
            return 4
        end
    elseif 8 == roundCount then
        if 3 == playerNum then
            return 10
        elseif 4 == playerNum then
            return 8
        end
    elseif 16 == roundCount then
        if 3 == playerNum then
            return 20
        elseif 4 == playerNum then
            return 15
        end
    end
    elseif 0 == payType or 2 == payType then ---房主支付,大贏家支付
    if 4 == roundCount then
        return 15
    elseif 8 == roundCount then
        return 30
    elseif 16 == roundCount then
        return 60
    end
    end
end

--淮南安丰消耗计算
function Config.caculate_price_HNAF(roundCount, playerNum, payType)
    local prices =
    {
        ["4"] = {["12"] = 8,["13"] = 5,["14"] = 4,["02"] = 15,["03"] = 15,["04"] = 15},
        ["8"] = {["12"] = 15,["13"] = 10,["14"] = 8,["02"] = 30,["03"] = 30,["04"] = 30},
        ["16"] = {["12"] = 30,["13"] = 20,["14"] = 16,["02"] = 60,["03"] = 60,["04"] = 60},
    }
    return prices[roundCount .. ""][payType .. "" .. playerNum]
end
--甘肃平凉麻将消耗计算
function Config.caculate_price_GSQP_PLMJ(roundCount, playerNum, payType)
    if 1 == payType then  ---AA制
    if 4 == roundCount then
        return 5
    elseif 8 == roundCount then
        return 9
    elseif 16 == roundCount then
        return 18
    end
    elseif 0 == payType then  ---房主支付
    if 4 == playerNum then
        if 4 == roundCount then
            return 20
        elseif 8 == roundCount then
            return 36
        elseif 16 == roundCount then
            return 72
        end
    elseif 3 == playerNum then
        if 4 == roundCount then
            return 15
        elseif 8 == roundCount then
            return 27
        elseif 16 == roundCount then
            return 54
        end
    end
    end
end

function Config.caculate_price_AHQP_BBBB(roundCount, playerNum, payType)
    if 1 == payType then  ---AA制
    if 4 == roundCount then
        if 3 == playerNum then
            return 5
        elseif 4 == playerNum then
            return 4
        elseif 2 == playerNum then
            return 8
        end
    elseif 8 == roundCount then
        if 3 == playerNum then
            return 10
        elseif 4 == playerNum then
            return 8
        elseif 2 == playerNum then
            return 15
        end
    elseif 16 == roundCount then
        if 3 == playerNum then
            return 20
        elseif 4 == playerNum then
            return 15
        elseif 2 == playerNum then
            return 30
        end
    end
    elseif 0 == payType then ---房主支付,大贏家支付
    if 4 == roundCount then
        return 15
    elseif 8 == roundCount then
        return 30
    elseif 16 == roundCount then
        return 60
    end
    end
end
--[[ 配置说明
    clickBigShow = "xx" 此选项影响整个组的按钮显示与隐藏
    bigShow = "xx" 与clickBigShow一一对应 被受影响
    bigShowType = 1 上面的按钮显示 它就显示 反之就隐藏
    bigShowType = 2 上面的按钮显示 它就隐藏 反之就显示
    clickSmallShow = "xx" 此选项影响单个按钮显示与隐藏
    smallShow = "xx" 与clickSmallShow一一对应 被受影响
    smallShowType = 1 上面的按钮显示 它就显示 反之就隐藏
    smallShowType = 2 上面的按钮显示 它就隐藏 反之就显示
    addJson = "xxx" 选项额外需要匹配的json字段
    inverseJson = "xxx" 选项不勾选对应的json字段
    --------上述是选项内的
    isMidTing 是否牌局中报听
    isTablePop 是否弹出选飘选跑界面
    isShowPao 是否选跑
    isShowPiao 是否选飘
    PaoTitles 跑飘对应的按钮文字显示
    laiziTagTitle 癞子对应的特殊名称
    laiziTag 癞子对应不同角标图片
    headTag = {
            serverJson = "PiaoNum", 对应的服务器使用飘跑字段
            localJson =  "Piao", 规则控制是否开启的飘跑字段
            zeroJson = "不飘", 为0时的标题
            addJson = "分", 不为0时的后补充文本
            notZeroJson = "飘分" 不为0时的标题
            preJson = "分" 不为0时的前补充文本
            secondShow = true 是否显示在第二列
        },
    isDingQue 是否需要定缺
    dingQueLocalJson 定缺开启的规则选项
    tingLocalJson 牌局中听牌的规则选项
    pnShowResult 使用普宁结算方式显示
    caculPrice 计算价格方式
    configJson 创建房间规则json头替换
    wanfaCustomShow 普通显示结算算分文本
    showMulOne 结算显示x1
    showAddOne 结算显示+0
    configJson 规则json头 如果没有 用默认的
    addJson 规则json额外要添加的字段
    caculPrice 计算价格的公式 没有就用默认
    callback 根据返回的规则table额外添加条件构建一个新的规则table
    isOpenLocationSetting 是否开启方言设置
    defLocationSetting 方言配置默认值，如果不配置，则默认普通话
    soundPath 方言配置语音文件的路径
    chatShotTextList 方言配置的文本设置
    --------上述是整个配置文件的
]]

return Config
