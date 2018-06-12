local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --长沙麻将
        {--不同分类 局数 人数..
            tag = {togglesTile = "局数:",rowNum = 3},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "",toggleType = 1,toggleTitle = "4局",toggleIsOn = false},
                    {disable = false,json = "",toggleType = 1,toggleTitle = "8局",toggleIsOn = true},
                    {disable = false,json = "",toggleType = 1,toggleTitle = "16局",toggleIsOn = false},
                },
            }
        },
        { 
            tag = {togglesTile = "人数:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"PlayerNum\":4",toggleType = 1,toggleTitle = "4人玩法",toggleIsOn = true},
                    {disable = false,json = "\"PlayerNum\":3",toggleType = 1,toggleTitle = "3人玩法",toggleIsOn = false},
                }
            }
        },
        {
            tag = { togglesTile = "可选:", rowNum = 3}, --toggle标题信息
            list =
            {
                {
                    { disable = false, json = "\"XianZhuang\":true", toggleType = 2, toggleTitle = "庄闲（算分）", toggleIsOn = true,clickTip = "勾选后所有与庄家相关的大胡小胡输赢都多1分"},
                    { disable = false, json = "\"Piao\":true", toggleType = 2, toggleTitle = "飘分", toggleIsOn = false,clickTip = "勾选后在每局开始之前可以选择飘分。每局胡牌结算时，输赢双方将额外计算飘分总和"},
                }
            }
        },
        {
            tag = { togglesTile = "玩法:", rowNum = 4}, --toggle标题信息
            list =
            {
                {
                    { disable = false, json = "\"LiuLiuShun\":true", toggleType = 2, toggleTitle = "六六顺", toggleIsOn = true,clickTip = "勾选后起手胡可以胡六六顺"},
                    { disable = false, json = "\"QueYiSe\":true", toggleType = 2, toggleTitle = "缺一色", toggleIsOn = true,clickTip = "勾选后起手胡可以胡缺一色"},
                    { disable = false, json = "\"BanBan\":true", toggleType = 2, toggleTitle = "板板胡", toggleIsOn = true,clickTip = "勾选后起手胡可以胡板板胡"},
                    { disable = false, json = "\"SiXi\":true", toggleType = 2, toggleTitle = "大四喜", toggleIsOn = true,clickTip = "勾选后起手胡可以胡大四喜"},
                    { disable = false, json = "\"JieJieGao\":true", toggleType = 2, toggleTitle = "节节高", toggleIsOn = false,clickTip = "勾选后起手胡可以胡节节高"},
                    { disable = false, json = "\"SanTong\":true", toggleType = 2, toggleTitle = "三同", toggleIsOn = false,clickTip = "勾选后起手胡可以胡三同"},
                    { disable = false, json = "\"YiZhiHua\":true", toggleType = 2, toggleTitle = "一枝花", toggleIsOn = false,clickTip = "勾选后起手胡可以胡一枝花"},
                    { disable = false, json = "\"ZhongTuSiXi\":true", toggleType = 2, toggleTitle = "中途四喜", toggleIsOn = false,clickTip = "勾选后可以胡中途四喜"},
                    { disable = false, json = "\"ZhongTuLiuLiuShun\":true", toggleType = 2, toggleTitle = "中途六六顺", toggleIsOn = false,clickTip = "勾选后可以胡中途六六顺"},
                }
            }
        },
        {
            tag = { togglesTile = "扎鸟:", rowNum = 3}, --toggle标题信息
            list =
            {
                {
                    { disable = false, json = "\"ZhaNiaoType\":0", toggleType = 1, toggleTitle = "不扎鸟", toggleIsOn = true,clickTip = "选中后本局游戏胡牌后不扎鸟"},
                    { disable = false, json = "\"ZhaNiaoType\":1", toggleType = 1, toggleTitle = "中鸟加分", toggleIsOn = false,clickSmallShow="5_2",clickTip = "选中后本局游戏胡牌时进行扎鸟，每扎中1鸟输赢多一分"},
                    { disable = false, json = "\"ZhaNiaoType\":2", toggleType = 1, toggleTitle = "中鸟翻倍", toggleIsOn = false,clickSmallShow="5_3",clickTip = "选中后本局游戏胡牌时进行扎鸟，扎中1鸟胡牌分x2，中2鸟胡牌分x3"},
                },
                {
                    { disable = false, json = "\"ZhaNiao\":2", toggleType = 1, toggleTitle = "扎2鸟", toggleIsOn = true,smallShow="5_2",smallShowType = 1},
                    { disable = false, json = "\"ZhaNiao\":4", toggleType = 1, toggleTitle = "扎4鸟", toggleIsOn = false,smallShow="5_2",smallShowType = 1},
                    { disable = false, json = "\"ZhaNiao\":6", toggleType = 1, toggleTitle = "扎6鸟", toggleIsOn = false,smallShow="5_2",smallShowType = 1},
                },
                {
                    { disable = false, json = "\"ZhaNiao\":1", toggleType = 1, toggleTitle = "扎1鸟（x2）", toggleIsOn = true,smallShow="5_3",smallShowType = 1},
                    { disable = false, json = "\"ZhaNiao\":2", toggleType = 1, toggleTitle = "扎2鸟（x3）", toggleIsOn = false,smallShow="5_3",smallShowType = 1},
                },
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
            return Config.caculate_price3(roundCount, playerCount, payType, bankerType)
        end,
        isChangSha = true,
        isTablePop = true,
        headTag = {
            serverJson = "PiaoNum",
            localJson =  "Piao",
            zeroJson = "不飘",
            addJson = "分",
        },
        isShowPiao = true,
        PaoTitles = "不飘|1分|2分|3分",
        view = "tablechangsha_view",
        controller = "tablechangsha_controller"
    },
}

ConfigChild.HowToPlayTexts =
{
[[<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1)万条筒1~9各4张,共108张牌;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1)可吃,可碰,可补张,可开杠;
2)可自摸,可接炮,可一炮多响;
3)坐庄:
 ◆ 第一局由房主坐庄,之后谁胡牌谁坐庄;
 ◆ 出现一炮多响的情况,放炮者下局坐庄;
 ◆ 没人胡牌的情况下摸到最后一张牌的人下把坐庄;
</size>
<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1)自摸:满足胡牌牌型即可;
2)接炮:满足胡牌牌型即可;
3)起手胡:起手发牌后满足下列条件,可以直接胡牌;
 ◆ 板板胡,手中没有2,5,8的牌,需要展示所有手牌;
 ◆ 大四喜,手中有四张相同的牌,需要展示此4张牌;
 ◆ 六六顺,手中有两个刻子(刻子:3张相同的牌),需要展示此6张牌;
 ◆ 缺一色,手中没有万条筒中任意一门的牌,需要展示所有手牌;
4)小胡:即普通平胡,平胡胡牌需要258做将;
5)大胡:满足以下条件胡牌时,算作大胡,大胡不需要258做将;
 ◆ 碰碰胡,都是由刻子或碰/杠/补牌组成,剩下两张相同的牌做将胡牌;
 ◆ 将将胡,所有的牌都是258组成;
 ◆ 清一色,满足胡牌牌型并且所有的牌都是同一门花色,可吃碰杠;
 ◆ 海底捞月,要了最后一张牌海底牌胡牌,平胡需要258做将,胡牌后算
 大胡;
 ◆ 海底炮,要了最后一张牌但是被其他玩家胡了这张牌,平胡需要258
 做将,胡牌后算大胡;
 ◆ 七小对,胡牌后手中的牌为七对组成;
 ◆ 双豪华七小对,七对胡牌并且手中有两个4张相同的牌(不能杠),算
 3个大胡的分;
 ◆ 三豪华七小对,七对胡牌并且手中有三个4张相同的牌(不能杠),算
 4个大胡的分;
 ◆ 杠上开花,玩家开杠后翻开两张牌,能胡其中任意一张即算杠上开花;
 ◆ 抢杠胡,玩家明杠时其他玩家可以胡这张牌即算抢杠胡,其他玩家平
 胡抢杠需要258做将;
 ◆ 杠上炮,开杠玩家翻开两张牌后,其他玩家可以胡任意一张即算杠上
 炮。其他玩家平胡需要258做将;
 ◆ 全求人,吃碰杠补后剩下最后一张牌单调,由别人打出或自摸胡牌则
 算全求人。单调牌可以不为258;
 ◆ 天胡,单指庄家,庄家起手摸牌后满足胡牌牌型胡牌,平胡需要258做将;
 ◆ 地胡,单指闲家,庄家打出第一张牌时闲家胡这张牌,平胡需要258做将;
</size>
<size=32><color=#004f3c>四.计分规则</color></size>
<size=28>
1)小胡自摸:胡牌玩家得6分,三家每人出2分;
2)小胡接炮:点炮方出1分,接炮方的1分;
3)大胡自摸:胡牌玩家得18分,三家每人出6分;
4)大胡接炮:点炮方出6分,接炮方的6分;
5)起手胡算小胡自摸,有几个算几次;
6)大胡牌型可叠加计算,比如清一色碰碰胡,算两个大胡;
</size>
]],--长沙麻将
}

return ConfigChild
