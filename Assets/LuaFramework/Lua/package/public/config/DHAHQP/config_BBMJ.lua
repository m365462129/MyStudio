local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --固镇
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
            tag = {togglesTile = "玩法:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"GangShangKaiHua\":true",toggleType = 2,toggleTitle = "杠后翻*2",toggleIsOn = false,clickTip="勾选后杠上开花胡牌时分数翻倍，不勾选则不翻倍。"},
                    {disable = false,json = "\"YouFengPai\":false",toggleType = 2,toggleTitle = "不带风",toggleIsOn = false,clickSmallShow = "3_1",clickTip="勾选后牌局内将删除东、南、西、北、中、发、白，不勾选则不删除。"},
                },
                {
                    {disable = false,json = "\"QiXiaoDui\":true",toggleType = 2,toggleTitle = "小七对",toggleIsOn = false,clickTip="勾选后本局可胡七小对且加对应分数，不勾选则不能胡七小对。"},
                    {disable = false,json = "\"ShiSanLan\":true",toggleType = 2,toggleTitle = "十三烂",toggleIsOn = false,smallShow="3_1",smallShowType = 2,clickTip="勾选后本局可胡十三烂且加对应分数，不勾选则不能胡十三烂。"},
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
    },
    { --五河
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
            tag = {togglesTile = "玩法:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"DaiBaoPai\":true",toggleType = 1,toggleTitle = "带宝牌",toggleIsOn = true,clickTip="勾选后将会带宝牌"},
                    {disable = false,json = "\"DaiBaoPai\":false",toggleType = 1,toggleTitle = "不带宝牌",toggleIsOn = false,clickTip="勾选后将不带宝牌"},
                },
                {
                    {disable = false,json = "\"GangShangPaoFanBei\":true",toggleType = 2,toggleTitle = "杠炮翻倍",toggleIsOn = false,clickTip="勾选后杠上炮胡牌将翻倍"},
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
            return Config.caculate_price2(roundCount, playerCount, payType, bankerType)
        end,
    },
}

ConfigChild.HowToPlayTexts =
{
[[<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1）麻将共136张牌，包括：万、条、筒、风（东南西北中发白）;
</size>

<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1）不可吃牌，可碰牌，可开杠;
2）可以一炮多响;
3）坐庄:庄家胡牌、流局时连庄，闲家胡牌逆时针轮庄;
4）出分:一家点炮时，点炮者出分;一家自摸时，剩余三家都要出分;
5）过胡惩罚:能胡而未胡，则只有在自己摸了牌后才能胡，可以自摸胡;
6）过碰惩罚：能碰而未碰，则只有自己摸了牌后再打的该牌才能碰;
7）杠随胡走：只有胡牌才计算杠分（有杠时第一时间可以不杠，随时可以开杠）
</size>

<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1）自摸:满足胡牌牌型即可;
2）接炮:满足胡牌牌型即可;
3）杠上花:满足牌型即可;
4）抢杠胡:满足牌型即可;
</size>
<size=32><color=#004f3c>四.计分规则</color></size>
<size=28>
1）接炮:1分;
2）自摸:2分;
3）明杠:1分;
4）暗杠:2分;
5）抢杠胡:算接炮1分;
6）天胡：胡牌总分*4倍
7）地胡：胡牌总分*2倍
8）小七对：胡牌总分+2分
9）十三烂：胡牌总分+2分
10）无花果：无花果+10分</size>]],--固镇
[[<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1）麻将共136张牌，包括：万、条、筒、风（东南西北中发白）;
2) 每局留12张牌，即倒数第13张牌还没有人胡牌，即黄庄;
</size>

<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1）不可吃牌，可碰牌，可开杠;
2）可自摸，可接炮，不可一炮多响;
3）坐庄:庄家胡牌、流局时连庄，闲家胡牌逆时针轮庄;
4）过胡惩罚:能胡而未胡，则只有在自己摸了牌后才能胡，可以自摸胡;
5）过碰惩罚：能碰而未碰，则只有自己摸了牌后再打的该牌才能碰;
6）杠随胡走：只有胡牌才计算杠分
</size>

<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1）自摸:满足胡牌牌型即可;
2）接炮:满足胡牌牌型即可;
3）杠上花:满足牌型即可;
4）杠后炮:满足牌型即可;
5）抢杠胡:满足牌型即可;

</size>
<size=32><color=#004f3c>四.计分规则</color></size>
<size=28>
1）平胡:1分;
2）自摸:1分;
3）明杠:1分;
4）暗杠:2分;
5）庄：+-1分（输赢1分）;
6）杠上花：胡牌总分*2倍;
7）杠后炮：胡牌总分*2倍.

</size>]],--五河
}

return ConfigChild
