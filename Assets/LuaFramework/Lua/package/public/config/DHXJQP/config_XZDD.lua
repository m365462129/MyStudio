local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --血战到底
        {--不同分类 局数 人数..
            tag = {togglesTile = "局数:",rowNum = 3},--toggle标题信息
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
            tag = {togglesTile = "人数:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"PlayerNum\":4",toggleType = 1,toggleTitle = "4人玩法",toggleIsOn = true},
                }
            }
        },
        --{
        --    tag = {togglesTile = "自摸:",rowNum = 3},--toggle标题信息
        --    list =
        --    {
        --        {
        --            {disable = false,json = "\"ZiMoJiaDi\":true",toggleType = 1,toggleTitle = "自摸加底",toggleIsOn = true,clickTip = "自摸胡牌时加1倍底分"},
        --            {disable = false,json = "\"ZiMoJiaDi\":false",toggleType = 1,toggleTitle = "自摸加番",toggleIsOn = false,clickTip = "自摸胡牌时加1番"},
        --        }
        --    }
        --},
        {
            tag = {togglesTile = "点杠:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"DianGangHua\":true",toggleType = 1,toggleTitle = "算点炮",toggleIsOn = true,clickTip = "点杠杠上花胡牌只有点杠玩家出分"},
                    {disable = false,json = "\"DianGangHua\":false",toggleType = 1,toggleTitle = "算自摸",toggleIsOn = false,clickTip = "点杠杠上花胡牌算自摸三家都要出分"},
                }
            }
        },
        {
            tag = {togglesTile = "玩法:",rowNum = 4},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"HuanSanZhang\":true",toggleType = 2,toggleTitle = "换三张",toggleIsOn = true,clickTip = "勾选后有换三张流程"},
                    {disable = false,json = "\"MenQingZhongZhang\":true",toggleType = 2,toggleTitle = "门清中张",toggleIsOn = false,clickTip = "勾选后有门清中张算分"},
                    {disable = false,json = "\"TianDiHu\":true",toggleType = 2,toggleTitle = "天地胡",toggleIsOn = false,clickTip = "勾选后有天胡地胡算分"},
                    {disable = false,json = "\"DaiYaoJiuJiang\":true",toggleType = 2,toggleTitle = "带幺九将对",toggleIsOn = false,clickTip = "勾选后有幺九和将对算分"},
                    {disable = false,json = "\"Piao\":true",toggleType = 2,toggleTitle = "带抛",toggleIsOn = true,clickTip = "勾选后第一局可以选择抛分"},
                    {disable = false,json = "\"Pao\":true",toggleType = 2,toggleTitle = "带攮",toggleIsOn = true,clickTip = "勾选后第一局可以选择攮分"},
                    {disable = false,json = "\"GuaFengXiaYu\":true",toggleType = 2,toggleTitle = "带刮风下雨",toggleIsOn = false, clickSmallShow = "4_7"},
                },
                {
                    {disable = false,json = "\"HuJiaoZhuanYi\":0",toggleType = 1,toggleTitle = "不呼叫",toggleIsOn = true, smallShow = "4_7", smallShowType = 1},
                    {disable = false,json = "\"HuJiaoZhuanYi\":1",toggleType = 1,toggleTitle = "呼叫转移",toggleIsOn = false,clickTip = "开杠后点炮转移杠分", smallShow = "4_7", smallShowType = 1},
                    {disable = false,json = "\"HuJiaoZhuanYi\":2",toggleType = 1,toggleTitle = "呼叫转移转根",toggleIsOn = false,clickTip = "开杠后点炮转移杠分和根分", smallShow = "4_7", smallShowType = 1},
                }
            }
        },
        {
            tag = {togglesTile = "封顶:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"FengDing\":2",toggleType = 1,toggleTitle = "2番封顶",toggleIsOn = false},
                    {disable = false,json = "\"FengDing\":3",toggleType = 1,toggleTitle = "3番封顶",toggleIsOn = true},
                    {disable = false,json = "\"FengDing\":4",toggleType = 1,toggleTitle = "4番封顶",toggleIsOn = false},
                }
            }
        },
        {
            tag = { togglesTile = "定位:", rowNum = 3 }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"NeedOpenGPS\":true", toggleType = 2, toggleTitle = "GPS检测", toggleIsOn = false },
                    { disable = false, json = "\"CheckIPAddress\":true", toggleType = 2, toggleTitle = "相同IP检测", toggleIsOn = false },
                }
            }
        },
        {
            tag = {togglesTile = "支付:",rowNum = 3, isPay = true},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"PayType\":1",toggleType = 1,toggleTitle = "AA支付",toggleIsOn = true},
                    {disable = false,json = "\"PayType\":0",toggleType = 1,toggleTitle = "房主支付",toggleIsOn = false},
                },
            }
        },
        caculPrice = function (roundCount, playerCount, payType, bankerType)
            return Config.caculate_price2(roundCount, playerCount, payType, bankerType)
        end,
        isXueLiuCH = true,
        isDingQue = true,
        pnShowResult = true,
        wanfaCustomShow = true,
        isXueZhanDD = true,
        isTablePop = true,
        isShowPiao = true,
        isMidTing = true,
        tingLocalJson = "Pao",
        PaoTitles = "不抛|抛1|抛2",
        headTag = {
            serverJson = "PiaoNum",
            localJson =  "Piao",
            zeroJson = "不抛",
            preJson = "抛",
        },
        view = "tablexuezhandaodi_view",
        controller = "tablexuezhandaodi_controller"
    },
}


ConfigChild.GoldRule = {
    {disable = false,json = "ZiMoJiaDi:true",toggleType = 1,toggleTitle = "自摸加底",toggleIsOn = true,clickTip = "自摸胡牌时加1倍底分"},
    {disable = false,json = "ZiMoJiaDi:false",toggleType = 1,toggleTitle = "自摸加番",toggleIsOn = false,clickTip = "自摸胡牌时加1番"},
    {disable = false,json = "DianGangHua:true",toggleType = 1,toggleTitle = "算点炮",toggleIsOn = true,clickTip = "点杠杠上花胡牌只有点杠玩家出分"},
    {disable = false,json = "DianGangHua:false",toggleType = 1,toggleTitle = "算自摸",toggleIsOn = false,clickTip = "点杠杠上花胡牌算自摸三家都要出分"},
    {disable = false,json = "HuanSanZhang:true",toggleType = 2,toggleTitle = "换三张",toggleIsOn = true,clickTip = "勾选后有换三张流程"},
    {disable = false,json = "MenQingZhongZhang:true",toggleType = 2,toggleTitle = "门清中张",toggleIsOn = false,clickTip = "勾选后有门清中张算分"},
    {disable = false,json = "TianDiHu:true",toggleType = 2,toggleTitle = "天地胡",toggleIsOn = false,clickTip = "勾选后有天胡地胡算分"},
    {disable = false,json = "DaiYaoJiuJiang:true",toggleType = 2,toggleTitle = "带幺九将对",toggleIsOn = false,clickTip = "勾选后有幺九和将对算分"},
    {disable = false,json = "FengDing:2",toggleType = 1,toggleTitle = "2番封顶",toggleIsOn = false},
    {disable = false,json = "FengDing:3",toggleType = 1,toggleTitle = "3番封顶",toggleIsOn = true},
    {disable = false,json = "FengDing:4",toggleType = 1,toggleTitle = "4番封顶",toggleIsOn = false},


}

function ConfigChild:PlayRule(playRule)
    if playRule and type(playRule) == "table" then
        local desc = ""
        for i, j in pairs(playRule) do
            --hasKing false
            local v = tostring(j)
            local json = i .. ":" .. v
            local tem = ""
            for n = 1, #ConfigChild.GoldRule do
                if json == ConfigChild.GoldRule[n].json then
                    tem = ConfigChild.GoldRule[n].toggleTitle
                end
            end
            if tem ~= "" then
                desc = desc .. "，" .. tem
            end
        end
        if desc ~= "" then
            desc =string.sub(desc,4)
        end
        return desc
    else
        return ""
    end
end

ConfigChild.PlayRuleText = {
    [[血流换三张,4番封顶]]
}

ConfigChild.HowToPlayGoldTexts =
{
    [[

<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1）麻将共108张牌，包括:万、条、筒;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1）可碰牌，可开杠，不可吃牌;
2）可自摸，可接炮，可以一炮多响;
3）必须缺门才能胡牌，开局定缺;
4）当有玩家胡牌后，不结束游戏，该玩家的牌变为听牌状态，不可改章
只能摸牌打牌，有胡时自动胡；可暗杠，已碰的牌可以补杠;
5）最后四张牌，有胡必须胡，不能过;
6）刮风:
◆直杠:手中有暗刻，其他玩家打出相同牌，暗刻玩家接杠;直杠收取
放杠玩家2倍底分;
◆弯杠:手中有明刻，即碰的三张，自己摸到第四张补杠;弯杠收取其
余三家各1倍底分;
7）下雨:手中有四张没有碰，玩家选择杠牌；暗杠收取三家各2倍底分;
8）查大叫:流局时没叫的玩家赔给有叫的玩家和已胡牌的玩家最大可能
番数（大叫），并退回所有刮风下雨所得;
9）自摸加底:玩家自摸胡牌时，除获得相应牌型计分外，还要收取未胡
牌玩家1倍底分;
10）自摸加番:玩家自摸胡牌时，胡牌牌型上额外加1番;
11）门清:玩家胡牌时，没有碰杠，没有明杠，胡牌牌型上加1番;
12）中张:玩家胡牌时，所有牌没有一和九，胡牌牌型上加1番;
13）点杠花“自摸”:玩家点杠后杠上花胡牌时，按自摸算并收三家分数;
</size>
<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1）自摸:满足胡牌限制即可;
2）接炮:满足胡牌限制即可;
</size>
<size=32><color=#004f3c>四.胡牌类型</color></size>
<size=28>
1）平胡:0番;
2）对对胡:1番;四副刻子加一对将;
3）将对:1番;由2、5、8组成的对对胡;
4）清一色:2番;胡牌时，都是同一种花色;
5）带幺九:2番;每个刻子、顺子、将牌都必须包含1或9;
6）七对:2番;胡牌时结算，都是对子，没有碰杠;
7）龙七对:3番;胡牌时结算，都是对子，手上有四张相同的牌（没有杠
出）;
8）天胡:5番;庄家起手摸第一张胡牌;
9）地胡:5番;闲家摸第一张胡牌;
</size>
<size=32><color=#004f3c>五.额外算番</color></size>
<size=28>
1）杠上花:1番;杠牌后补牌并胡牌;
2）杠上炮:1番;玩家杠牌补牌后打出一张牌，被其他玩家胡牌;
3）抢杠胡:1番;玩家补杠时，其他玩家可以抢杠胡;
4）扫底胡:1番;最后一张牌自摸胡牌;
5）海底胡:1番;最后一张牌点炮胡牌;
6）金沟胡:1番;对对胡单吊将牌，并且其它牌都碰、杠出;
7）门清:1番;胡牌时，没有碰，没有明杠;
8）中张:1番;胡牌时，所有牌都没有1和9;
9）根:1番;有四张相同的牌，不论碰杠都算，可叠加;
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
3） 必须缺门才能胡牌，开局定缺;
4） 坐庄规则:第一局房主坐庄，若流局则庄家的下家坐庄;有人胡牌
    则最先胡牌的坐庄;若一炮多响则点炮玩家坐庄;
5） 当有玩家胡牌后，其余未胡牌玩家继续游戏，直到流局或只有一
    位未胡牌玩家为止;
6） 最后四张牌，有胡必须胡，不能过;
7） 刮风:
   ◆ 直杠:手中有暗刻，其他玩家打出相同牌，暗刻玩家接杠;直杠
      收取放杠玩家2倍底分;
   ◆ 弯杠:手中有明刻，即碰的三张，自己摸到第四张补杠;弯杠收
      取其余三家各1倍底分;
8） 下雨:手中有四张没有碰，玩家选择杠牌；暗杠收取三家各2倍底
    分;
9） 查大叫:流局时没叫的玩家赔给有叫的玩家和已胡牌的玩家最大可
    能番数（大叫），并退回所有刮风下雨所得;
10）自摸加底:玩家自摸胡牌时，除获得相应牌型计分外，还要收取未
    胡牌玩家1倍底分;
11）自摸加番:玩家自摸胡牌时，胡牌牌型上额外加1番;
12）门清:玩家胡牌时，没有碰杠，没有明杠，胡牌牌型上加1番;
13）中张:玩家胡牌时，所有牌没有一和九，胡牌牌型上加1番;
14）点杠“算点炮”:玩家点杠后杠上花胡牌时，按自摸算但只收点杠
    者一家分数;
15）点杠“算自摸”:玩家点杠后杠上花胡牌时，按自摸算并收三家分
    数;
16) 呼叫转移:开杠玩家在开杠后点炮，当前的杠的杠分转移给接炮胡
    的玩家，但不转根分;
17）呼叫转移转根:开杠玩家在开杠后点炮，当前杠的杠分转移给接炮
    胡的玩家，根分也转移;
</size>
<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1） 自摸:满足胡牌限制即可;
2） 接炮:满足胡牌限制即可;
</size>
<size=32><color=#004f3c>四.胡牌类型</color></size>
<size=28>
1） 平胡:0番;
2） 对对胡:1番;四副刻子加一对将;
3） 将对:1番;由2、5、8组成的对对胡;
4） 清一色:2番;胡牌时，都是同一种花色;
5） 带幺九:2番;每个刻子、顺子、将牌都必须包含1或9;
6） 七对:2番;胡牌时结算，都是对子，没有碰杠;
7） 龙七对:3番;胡牌时结算，都是对子，手上有四张相同的牌（没有
    杠出）;
8） 天胡:5番;庄家起手摸第一张胡牌;
9） 地胡:5番;闲家摸第一张胡牌;
</size>
<size=32><color=#004f3c>五.额外算番</color></size>
<size=28>
1） 杠上花:1番;杠牌后补牌并胡牌;
2） 杠上炮:1番;玩家杠牌补牌后打出一张牌，被其他玩家胡牌;
3） 抢杠胡:1番;玩家补杠时，其他玩家可以抢杠胡;
4） 扫底胡:1番;最后一张牌自摸胡牌;
5） 海底胡:1番;最后一张牌点炮胡牌;
6） 金沟胡:1番;对对胡单吊将牌，并且其它牌都碰、杠出;
7） 门清:1番;胡牌时，没有碰，没有明杠;
8） 中张:1番;胡牌时，所有牌都没有1和9;
9） 根:1番;有四张相同的牌，不论碰杠都算，可叠加;
</size>]]
}

return ConfigChild
