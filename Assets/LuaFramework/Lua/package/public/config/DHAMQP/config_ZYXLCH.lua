local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --血流成河
        {--不同分类 局数 人数..
            tag = {togglesTile = "局数:",rowNum = 3, bigShow = "customEnterSet"},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"roundCount\":4",toggleType = 1,toggleTitle = "4局",toggleIsOn = false},
                    {disable = false,json = "\"roundCount\":8",toggleType = 1,toggleTitle = "8局",toggleIsOn = true},
                    {disable = false,json = "\"roundCount\":16",toggleType = 1,toggleTitle = "16局",toggleIsOn = false},
                },
            }
        },
        {
            tag = {togglesTile = "设置:",rowNum = 3, bigShow = "goldEnterSet"},--toggle标题信息
            list =
            {

            }
        },
        --{
        --    tag = { togglesTile = "结算:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
        --    list = {
        --        {
        --            { disable = false, json = "\"settleType\":0", toggleType = 1, toggleTitle = "积分结算", toggleIsOn = true, refreshUI = true},
        --            { disable = false, json = "\"settleType\":1", toggleType = 1, toggleTitle = "金币辅助结算", toggleIsOn = false, goldSet = true, refreshUI = true, goldSetVal1 = 50, goldSetVal2 = 1500 },
        --        }
        --    }
        --},
        {
            tag = {togglesTile = "人数:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"PlayerNum\":4",toggleType = 1,toggleTitle = "4人玩法",toggleIsOn = true},
                }
            }
        },
        {
            tag = {togglesTile = "漂分:",rowNum = 4},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"Piao\":1",toggleType = 1,toggleTitle = "漂1",toggleIsOn = true},
                    {disable = false,json = "\"Piao\":2",toggleType = 1,toggleTitle = "漂2",toggleIsOn = false},
                    {disable = false,json = "\"Piao\":3",toggleType = 1,toggleTitle = "漂3",toggleIsOn = false},
                    {disable = false,json = "\"Piao\":5",toggleType = 1,toggleTitle = "漂5",toggleIsOn = false},
                }
            }
        },
        {
            tag = {togglesTile = "玩法:",rowNum = 4},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"HuanSanZhang\":true",toggleType = 2,toggleTitle = "换三张",toggleIsOn = true,clickTip = "勾选后有换三张流程"},
                }
            }
        },
        {
            tag = { togglesTile = "定位:", rowNum = 3 , bigShow = "customEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"NeedOpenGPS\":true", toggleType = 2, toggleTitle = "GPS检测", toggleIsOn = true },
                    { disable = false, json = "\"CheckIPAddress\":true", toggleType = 2, toggleTitle = "相同IP检测", toggleIsOn = true },
                }
            }
        },
        {
            tag = { togglesTile = "定位:", rowNum = 3 , bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = true, json = "\"NeedOpenGPS\":true", toggleType = 2, toggleTitle = "GPS检测", toggleIsOn = true },
                    { disable = true, json = "\"CheckIPAddress\":true", toggleType = 2, toggleTitle = "相同IP检测", toggleIsOn = true },
                }
            }
        },
        {
            tag = { togglesTile = "", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"isPrivateRoom\":true", toggleType = 2, toggleTitle = "私人房", toggleIsOn = true },
                },
            }
        },

        {
            tag = {togglesTile = "支付:",rowNum = 4, isPay = true, goldSet = true},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"IsGoldFieldRoom\":true",toggleType = 1,toggleTitle = "金币场",toggleIsOn = true,
                        goldEnterSet = true,clickBigShow = "goldEnterSet", minGoldEnterVal = 50, maxGoldEnterVal = 1000, enterMulti = 20, addJson = "\"roundCount\":0,\"PayType\":-1"},
                    { disable = false, json = "PayType", toggleType = 1, toggleTitle = "好友场", toggleIsOn = false,
                        dropDown = "0,1", dropDefault = 1, dropDownTitles = "房主,AA",clickBigShow = "customEnterSet",dropDownWidth = 140 },
                },
            }
        },
        {
            tag = {togglesTile = "支付:",rowNum = 3, isPay = true, goldSet = false},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"PayType\":1",toggleType = 1,toggleTitle = "AA支付",toggleIsOn = true,clickBigShow = "customEnterSet"},
                    {disable = false,json = "\"PayType\":0",toggleType = 1,toggleTitle = "房主支付",toggleIsOn = false,clickBigShow = "customEnterSet"},
                },
            }
        },
        caculPrice = function (roundCount, playerCount, payType, bankerType)
            return Config.caculate_price2(roundCount, playerCount, payType, bankerType)
        end,
        isXueLiuCH = true,
        pnShowResult = true,
        wanfaCustomShow = true,
    },
}


ConfigChild.GoldRule = 
{
    {disable = false,json = "HuanSanZhang:true",toggleType = 2,toggleTitle = "换三张",toggleIsOn = true,clickTip = "勾选后有换三张流程"},
    {disable = false,json = "ZiMoJiaDi:true",toggleType = 1,toggleTitle = "自摸加1底",toggleIsOn = true,clickTip = "自摸胡牌时加1倍底分"},
    {disable = false,json = "ZiMoJiaDi:false",toggleType = 1,toggleTitle = "自摸加1番",toggleIsOn = false,clickTip = "自摸胡牌时加1番"},
	{disable = false,json = "FengDing:2",toggleType = 1,toggleTitle = "2番封顶",toggleIsOn = false},
    {disable = false,json = "FengDing:3",toggleType = 1,toggleTitle = "3番封顶",toggleIsOn = true},
    {disable = false,json = "FengDing:4",toggleType = 1,toggleTitle = "4番封顶",toggleIsOn = false},
	{disable = false,json = "Piao:1",toggleType = 1,toggleTitle = "漂1",toggleIsOn = true},
    {disable = false,json = "Piao:2",toggleType = 1,toggleTitle = "漂2",toggleIsOn = false},
    {disable = false,json = "Piao:3",toggleType = 1,toggleTitle = "漂3",toggleIsOn = false},
    {disable = false,json = "Piao:5",toggleType = 1,toggleTitle = "漂5",toggleIsOn = false},
    {disable = false,json = "DianGangHua:true",toggleType = 1,toggleTitle = "点杠花算点炮",toggleIsOn = true,clickTip = "点杠杠上花胡牌只有点杠玩家出分"},
    {disable = false,json = "DianGangHua:false",toggleType = 1,toggleTitle = "点杠花算自摸",toggleIsOn = false,clickTip = "点杠杠上花胡牌算自摸三家都要出分"},
    {disable = false,json = "MenQingZhongZhang:true",toggleType = 2,toggleTitle = "门清中张",toggleIsOn = false,clickTip = "勾选后有门清中张算分"},
    {disable = false,json = "TianDiHu:true",toggleType = 2,toggleTitle = "带天地胡",toggleIsOn = false,clickTip = "勾选后有天胡地胡算分"},
    {disable = false,json = "DaiYaoJiuJiang:true",toggleType = 2,toggleTitle = "带幺九将对",toggleIsOn = false,clickTip = "勾选后有幺九和将对算分"},

}

function ConfigChild:PlayRule(playRule)
    if playRule and type(playRule) == "table" then
        local desc1 = ""
        local descList = {}
        for i, j in pairs(playRule) do
            --hasKing false
            local v = tostring(j)
            local json = i .. ":" .. v
            local tem = ""
            for n = 1, #ConfigChild.GoldRule do
                if json == ConfigChild.GoldRule[n].json then
                    tem = ConfigChild.GoldRule[n].toggleTitle
                    table.insert(descList, { desc = tem, id = n })
                end
            end
        end
        table.sort(descList, function(a, b)
            return a.id < b.id
        end )
        for i in pairs(descList) do
            if desc1 == "" then
                desc1 = descList[i].desc
            else
                desc1 = desc1 .. " " .. descList[i].desc
            end
        end
        return desc1
    else
        return ""
    end
end

ConfigChild.PlayRuleText = {
    [[血流换三张,漂1]]
}


ConfigChild.HowToPlayGoldTexts =
{
    [[

﻿<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1）  麻将共108张牌，包括:万、条、筒;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1）  可碰牌，可开杠，不可吃牌;
2）  可自摸，可接炮，可以一炮多响;
3）  必须缺门才能胡牌，开局无定缺;
4）  当有玩家胡牌后，不结束游戏，该玩家的牌变为听牌状态，不可
        改章只能摸牌打牌，有胡时自动胡；可暗杠，已碰的牌可以补杠;
5）  最后四张牌，有胡必须胡，不能过;
6）  吃包子:流局时没叫的玩家赔给有叫的玩家和已胡牌的玩家最大可
        能番数;
7）  捉花猪:游戏结算时，未胡牌玩家手中有筒、万、条三种花色的牌
        就算捉花猪，要赔给已听牌和已胡牌玩家3倍最大胡牌分数;
8）  门清:玩家胡牌时，没有碰杠，没有明杠，胡牌牌型上加1番;
9）天胡:不允许天胡;
</size>
<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1）  自摸:满足胡牌限制即可;
2）  接炮:满足胡牌限制即可;
</size>
<size=32><color=#004f3c>四.胡牌类型</color></size>
<size=28>
1）  基础胡:3番;
2）  对对胡:5番;四副刻子加一对将;
3）  清一色:8番;胡牌时，都是同一种花色;
4）  清一色对对胡:12番;
5）  明杠:1番;
6）  接杠:1番;
7）  暗杠:2番;
</size>]]
}




ConfigChild.HowToPlayTexts =
{
[[<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1） 麻将共108张牌，包括:万、条、筒;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1） 可碰牌，可开杠，不可吃牌;
2） 可自摸，可接炮，可以一炮多响;
3） 必须缺门才能胡牌，开局无定缺;
4） 坐庄:第一局房主坐庄；上一局最先胡牌的人为庄家，若此时是一
    炮多响则点炮玩家为庄家；若无任何人胡牌则逆时针轮庄;
5） 当有玩家胡牌后，不结束游戏，该玩家的牌变为听牌状态，不可
    改章只能摸牌打牌，有胡时自动胡；可暗杠，已碰的牌可以补杠;
6） 最后四张牌，有胡必须胡，不能过;
7） 吃包子:流局时没叫的玩家赔给有叫的玩家和已胡牌的玩家最大可
    能番数;
8） 捉花猪:游戏结算时，未胡牌玩家手中有筒、万、条三种花色的牌
    就算捉花猪，要赔给已听牌和已胡牌玩家3倍最大胡牌分数;
9） 门清:玩家胡牌时，没有碰杠，没有明杠，胡牌牌型上加1番;
10）天胡:不允许天胡;
</size>
<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1） 自摸:满足胡牌限制即可;
2） 接炮:满足胡牌限制即可;
</size>
<size=32><color=#004f3c>四.胡牌类型</color></size>
<size=28>
1） 基础胡:3番;
2） 对对胡:5番;四副刻子加一对将;
3） 清一色:8番;胡牌时，都是同一种花色;
4） 清一色对对胡:12番;
5） 明杠:1番;
6） 接杠:1番;
7） 暗杠:2番;
</size>]]
}

return ConfigChild
