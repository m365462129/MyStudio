local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --红中
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
                    {disable = false,json = "\"PlayerNum\":3",toggleType = 1,toggleTitle = "3人玩法",toggleIsOn = false},
                }
            }
        },
        { 
            tag = {togglesTile = "玩法:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"BuKeJiePao\":false",toggleType = 2,toggleTitle = "可接炮",toggleIsOn = false,clickTip = "勾选后可以接炮胡"},
                    {disable = false,json = "\"YouLaiZi\":true",toggleType = 2,toggleTitle = "红中",toggleIsOn = true,clickTip = "勾选时带红中"},
                    {disable = false,json = "\"QiangGangQuanBao\":true",toggleType = 2,toggleTitle = "抢杠全包",toggleIsOn = true,clickTip = "勾选后被抢杠胡玩家包三家分"},
                    {disable = false,json = "\"HuangZhuangHuangGang\":true",toggleType = 2,toggleTitle = "黄庄黄杠",toggleIsOn = true,clickTip = "勾选后黄庄的情况下不计算杠分"},
                    {disable = false,json = "\"QiXiaoDui\":true",toggleType = 2,toggleTitle = "可胡七对",toggleIsOn = true,clickTip = "勾选后允许七对子胡牌"},
                    {disable = false,json = "\"BuKeChi\":true",toggleType = 2,toggleTitle = "不可吃牌",toggleIsOn = true,clickTip = "勾选后不允许吃牌"},
                    {disable = false,json = "\"SiHongZhong\":true",toggleType = 2,toggleTitle = "4红中胡牌",toggleIsOn = true,clickTip = "勾选后有4个红中可以直接胡牌"},
                    {disable = false,json = "\"QiangGangWuHongZhong\":true",toggleType = 2,toggleTitle = "抢杠胡无红中",toggleIsOn = false,clickTip = "勾选后没有红中不可以抢杠胡"},
                    {disable = false,json = "\"ZhiNengPengYiDui\":true",toggleType = 2,toggleTitle = "只能对一对",toggleIsOn = false,clickTip = "勾选后只能碰一次"},
                    {disable = false,json = "\"QingYiSe\":true",toggleType = 2,toggleTitle = "清一色加分",toggleIsOn = false,clickTip = "勾选后胡清一色有加分"},
                    {disable = false,json = "\"MenQing\":true",toggleType = 2,toggleTitle = "门清加分",toggleIsOn = false,clickTip = "勾选后胡门清有加分"},
                    {disable = false,json = "\"GangBaoQuanBao\":true",toggleType = 2,toggleTitle = "杠爆全包",toggleIsOn = false,clickTip = "勾选后杠上开花的放杠玩家包三家分"},
                }
            }
        },
        { 
            tag = {togglesTile = "扎码:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"ZhaMa\":0",toggleType = 1,toggleTitle = "不扎码",toggleIsOn = false,clickSmallShow = "4_1",clickTip = "勾选后没有扎码"},
                    {disable = false, json = "ZhaMa", toggleType = 1, toggleTitle = "扎", toggleIsOn = true, dropDown = "2,4,6", dropDefault = 0, dropAddStr = "码",clickTip = "勾选后有扎码" },
                    {disable = false,json = "\"ZhaMa\":1",toggleType = 1,toggleTitle = "一码全中",toggleIsOn = false,clickSmallShow = "4_1",clickTip = "勾选后只扎一个马，点数多少额外加多少分"},
                },
                {
                    {disable = false,json = "\"HongZhongSuanMa\":true",toggleType = 2,toggleTitle = "红中算码",toggleIsOn = true,smallShow = "4_1",smallShowType = 2,clickTip = "勾选后翻开红中算中码"},
                    {disable = false,json = "\"GangKaiJiaMa\":true",toggleType = 2,toggleTitle = "杠开加码",toggleIsOn = false,smallShow = "4_1",smallShowType = 2,clickTip = "勾选后杠上开花扎码数量翻倍"},
                },
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
            return Config.caculate_price2_3(roundCount, playerCount, payType, bankerType)
        end,
    },
}

ConfigChild.GoldRule = {
    {disable = false,json = "PlayerNum:4",toggleType = 1,toggleTitle = "4人",toggleIsOn = true},
    {disable = false,json = "PlayerNum:3",toggleType = 1,toggleTitle = "3人",toggleIsOn = false},

    {disable = false,json = "BuKeJiePao:false",toggleType = 2,toggleTitle = "可接炮",toggleIsOn = false,clickTip = "勾选后可以接炮胡"},
    --{disable = false,json = "YouLaiZi:true",toggleType = 2,toggleTitle = "带红中",toggleIsOn = true,clickTip = "勾选时带红中"},
	{disable = false,json = "YouLaiZi:false",toggleType = 2,toggleTitle = "无红中",toggleIsOn = true,clickTip = "勾选时带红中"},
    {disable = false,json = "QiangGangQuanBao:true",toggleType = 2,toggleTitle = "抢杠全包",toggleIsOn = true,clickTip = "勾选后被抢杠胡玩家包三家分"},
    {disable = false,json = "HuangZhuangHuangGang:true",toggleType = 2,toggleTitle = "黄庄黄杠",toggleIsOn = true,clickTip = "勾选后黄庄的情况下不计算杠分"},
    {disable = false,json = "QiXiaoDui:true",toggleType = 2,toggleTitle = "带七对",toggleIsOn = true,clickTip = "勾选后允许七对子胡牌"},
    --{disable = false,json = "BuKeChi:true",toggleType = 2,toggleTitle = "不可吃牌",toggleIsOn = true,clickTip = "勾选后不允许吃牌"},
    {disable = false,json = "BuKeChi:false",toggleType = 2,toggleTitle = "可吃牌",toggleIsOn = true,clickTip = "勾选后不允许吃牌"},
    {disable = false,json = "SiHongZhong:true",toggleType = 2,toggleTitle = "4红中胡牌",toggleIsOn = true,clickTip = "勾选后有4个红中可以直接胡牌"},
    {disable = false,json = "QiangGangWuHongZhong:true",toggleType = 2,toggleTitle = "抢杠胡无红中",toggleIsOn = false,clickTip = "勾选后没有红中不可以抢杠胡"},
    {disable = false,json = "ZhiNengPengYiDui:true",toggleType = 2,toggleTitle = "只能对一对",toggleIsOn = false,clickTip = "勾选后只能碰一次"},
    {disable = false,json = "QingYiSe:true",toggleType = 2,toggleTitle = "带清一色",toggleIsOn = false,clickTip = "勾选后胡清一色有加分"},
    {disable = false,json = "MenQing:true",toggleType = 2,toggleTitle = "带门清",toggleIsOn = false,clickTip = "勾选后胡门清有加分"},
    {disable = false,json = "GangBaoQuanBao:true",toggleType = 2,toggleTitle = "杠爆全包",toggleIsOn = false,clickTip = "勾选后杠上开花的放杠玩家包三家分"},
    {disable = false,json = "ZhaMa:0",toggleType = 1,toggleTitle = "不扎码",toggleIsOn = false,clickSmallShow = "4_1",clickTip = "勾选后没有扎码"},
    {disable = false, json = "ZhaMa", toggleType = 1, toggleTitle = "扎", toggleIsOn = true, dropDown = "2,4,6", dropDefault = 0, dropAddStr = "码",clickTip = "勾选后有扎码" },
    {disable = false,json = "ZhaMa:1",toggleType = 1,toggleTitle = "一码全中",toggleIsOn = false,clickSmallShow = "4_1",clickTip = "勾选后只扎一个马，点数多少额外加多少分"},
    {disable = false,json = "HongZhongSuanMa:true",toggleType = 2,toggleTitle = "红中算码",toggleIsOn = true,smallShow = "4_1",smallShowType = 2,clickTip = "勾选后翻开红中算中码"},
    {disable = false,json = "GangKaiJiaMa:true",toggleType = 2,toggleTitle = "杠开加码",toggleIsOn = false,smallShow = "4_1",smallShowType = 2,clickTip = "勾选后杠上开花扎码数量翻倍"},

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
    [[红中麻将]]
}

ConfigChild.HowToPlayGoldTexts =
{
    [[

<size=32><color=#004f3c>一.基础规则</color></size>
<size=28>
1）红中麻将为四人麻将，红中为赖子，可以代替任何牌进行胡牌；
2）红中麻将可以碰杠，不能吃；
3）牌局中杠牌立即结算，与胡不胡牌不相关，可也设置成黄庄时黄杠；
4）万条筒1~9各4张，红中4张，共112张；
</size>
<size=32><color=#004f3c>二.胡牌规则</color></size>
<size=28>
1）胡牌方式有两种，可自摸胡牌，也可以接炮胡；
2）可抢杠胡；
3）过胡惩罚：一圈内对方打出的牌能胡却没有胡，则在未经过自己时再
次出现可接炮胡的牌时也都不可胡牌；
</size>
<size=32><color=#004f3c>三.分数计算</color></size>
<size=28>
1）放杠：3分；
2）明杠：每人1分；
3）暗杠：每人2分；
4）接炮：2分；
5）自摸：2分；
6）抢杠胡：2分；由杠牌玩家出分；
7）门清：1分；
8）无红中：1分；
9）七小对：4分；
10）清一色：5分；
11）清一色七小对：7分；
12）天胡：2分；
13）地胡：1分；
14）臭庄（黄庄）的情况下不会计算杠分；
15）扎2、4、6码：扎中1、5、9、红中算中码，每中1个则额外加1分；
16）最终输赢金币=胡牌分数*底分；
</size>]]
}







ConfigChild.HowToPlayTexts =
{
[[  <size=32><color=#004f3c>一.基础规则</color></size>
  <size=28>
  1）红中麻将为四人麻将，红中为赖子，可以代替任何牌进行胡牌；
  2）红中麻将可以碰杠，不能吃；
  3）牌局中杠牌立即结算，与胡不胡牌不相关，可也设置成黄庄时黄杠；
  4）万条筒1~9各4张，红中4张，共112张；
  5）首局有房主坐庄，之后谁胡谁庄，如果本局臭庄（黄庄），则最后
     摸牌的玩家下局坐庄，一炮多响的情况下由放炮玩家下局坐庄；
  </size>
  <size=32><color=#004f3c>二.胡牌规则</color></size>
  <size=28>
  1）胡牌方式有两种，可自摸胡牌，也可以接炮胡；
  2）可抢杠胡；
  3）过胡惩罚：一圈内对方打出的牌能胡却没有胡，则在未经过自己时再
     次出现可接炮胡的牌时也都不可胡牌；
  </size>
  <size=32><color=#004f3c>三.分数计算</color></size>
  <size=28>
  1）放杠：
     ◆ 四人玩法：3分；
     ◆ 三人玩法：2分；
  2）明杠：
     ◆ 四人玩法：1分；
     ◆ 三人玩法：1分；
  3）暗杠：
     ◆ 四人玩法：2分；
     ◆ 三人玩法：2分；
  4）接炮：2分；
  5）自摸：2分；
  6）抢杠胡：2分；由杠牌玩家出分；
  7）门清：1分；
  8）无红中：1分；
  9）七小对：4分；
  10）清一色：5分；
  11）清一色七小对：7分；
  12）天胡：2分；
  13）地胡：1分；
  14）臭庄（黄庄）的情况下不会计算杠分；
  15）扎2、4、6码：扎中1、5、9、红中算中码，每中1个则额外加1分；
  </size>]]
}

return ConfigChild
