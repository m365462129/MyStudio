local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --开口番
        {--不同分类 局数 人数..
            tag = {togglesTile = "局数:",rowNum = 3, bigShow = "customEnterSet"},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"roundCount\":8",toggleType = 1,toggleTitle = "8局",toggleIsOn = true},
                    {disable = false,json = "\"roundCount\":16",toggleType = 1,toggleTitle = "16局",toggleIsOn = false},
                },
            }
        },
        {
            tag = { togglesTile = "设置:", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {

            }
        },
        --{
        --    tag = { togglesTile = "结算:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
        --    list = {
        --        {
        --            { disable = false, json = "\"settleType\":0", toggleType = 1, toggleTitle = "积分结算", toggleIsOn = true, refreshUI = true },
        --            { disable = false, json = "\"settleType\":1", toggleType = 1, toggleTitle = "金币辅助结算", toggleIsOn = false, goldSet = true, refreshUI = true, goldSetVal1 = 50, goldSetVal2 = 1500 },
        --        }
        --    }
        --},
        {
            tag = {togglesTile = "人数:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"PlayerNum\":4",toggleType = 1,toggleTitle = "4人",toggleIsOn = true},
                }
            }
        },
        {
            tag = {togglesTile = "玩法:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"ZhuangJiaFan\":true",toggleType = 2,toggleTitle = "庄家加番",toggleIsOn = true,clickTip="庄家输赢额外多算1番，大胡不算"},
                    {disable = false,json = "\"FengPai\":true",toggleType = 2,toggleTitle = "带风牌",toggleIsOn = false,clickTip="牌局带东南西北"},
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
            tag = { togglesTile = "支付:", rowNum = 4, isPay = true, goldSet = true }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"IsGoldFieldRoom\":true", toggleType = 1, toggleTitle = "金币场", toggleIsOn = false,
                        goldEnterSet = true, clickBigShow = "goldEnterSet", minGoldEnterVal = 10, maxGoldEnterVal = 500, enterMulti = 100, addJson = "\"roundCount\":0,\"PayType\":-1,\"halfEnter\":true" },
                    { disable = false, json = "PayType", toggleType = 1, toggleTitle = "好友场", toggleIsOn = true,
                        dropDown = "0,1,2", dropDefault = 0, dropDownTitles = "房主,AA,大赢家", clickBigShow = "customEnterSet", dropDownWidth = 140 },
                },
            }
        },
        {
            tag = { togglesTile = "支付:", rowNum = 3, isPay = true, goldSet = false }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"PayType\":1", toggleType = 1, toggleTitle = "AA支付", toggleIsOn = true, clickBigShow = "customEnterSet" },
                    { disable = false, json = "\"PayType\":0", toggleType = 1, toggleTitle = "房主支付", toggleIsOn = false, clickBigShow = "customEnterSet" },
                    { disable = false, json = "\"PayType\":2", toggleType = 1, toggleTitle = "大赢家支付", toggleIsOn = false, clickBigShow = "customEnterSet" },
                },
            }
        },
        caculPrice = function (roundCount, PlayerNum, PayType, bankerType)
            return Config.caculate_price_hshh(roundCount, PlayerNum, PayType, bankerType)
        end,
        isHuangShiHH = true,
        laiziTagTitle = "赖子",
        laiziTag = "3",
        pnShowResult = true,
        wanfaCustomShow = true,
        isDaYeKKF = true,
        soundPath = "hshh",
        chatShotTextList = {
            "想什么呢,快点出牌呀",
            "不好意思,刚接了个电话,耽搁一下",
            "上手能不能不捉果紧,放个档子啦",
            "几张牌活活被恩碰死",
            "能不能来果,真正一七心",
            "真正一有味,带果个牌也能胡",
            "果个牌冒杠开,痞手的哭",
            "打渔看倒浪啦,莫糊涂打",
            "打牌不冲锋,不如回家做负工",
            "恩能不能有点最求啦,果噶屁胡机子",
        },
        laiziNoYellow = true,
    },
}



ConfigChild.GoldRule = {

    {disable = false,json = "ZhuangJiaFan:true",toggleType = 2,toggleTitle = "庄家加番",toggleIsOn = true,clickTip="庄家输赢额外多算1番，大胡不算"},
    {disable = false,json = "FengPai:true",toggleType = 2,toggleTitle = "带风牌",toggleIsOn = false,clickTip="牌局带东南西北"},

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
    [[]]
}

ConfigChild.HowToPlayTexts =
{
[[<size=32><color=#004f3c>一.麻将数量</color></size><size=28>
1） 麻将共136张牌，包括：万、条、筒、东、南、西、北、中、发、白;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1） 可碰牌，可开杠，可吃牌;
2） 可自摸，可接炮，不可以一炮多响;
3） 坐庄:第一轮房主坐庄，之后谁胡牌谁做庄；黄庄后，庄家下家为庄;
4） 留牌:每局留最后10张牌，即打到剩余10张牌就流局;
5） 开口:吃、碰、明杠算开口，暗杠不算开口;
</size>
<size=32><color=#004f3c>三.胡牌规则</color></size>
<size=28>
1） 5番起胡，6番封顶;
2） 必须开口才能胡，不开口不能胡牌;
3） 屁胡必须2、5、8做将;
4） 屁胡胡牌限制:
    ◆ 赖子数量≤1时可以接炮胡也可以自摸胡;
    ◆ 赖子数量＞1不允许胡牌
    ◆ 屁胡杠上开花，赖子数量＞1时可以胡牌
5） 其它胡牌限制:
    ◆ 大胡无赖子数量限制，多个赖子可以接炮也可以自摸胡
    ◆ 见字胡不可以接炮胡
6)  抢杠胡:
    ◆ 抢杠胡屁胡，仅被抢杠玩家出分
    ◆ 抢杠胡大胡，被抢杠玩家包三家分
7)  天胡、地胡:不可胡
8） 过胡惩罚：一圈内对方打出的牌能胡却没有胡，则在未经过自己时再
    次出现可接炮胡的牌时也都不可以胡牌;
</size>
<size=32><color=#004f3c>四.赖子规则</color></size>
<size=28>
1） 赖子:发牌后随机翻一张牌，这张牌的下一个数，就是赖子;
2） 不带风牌玩法:翻红中、发财、白板都是白板做赖子;
3） 带风牌玩法:翻红中、发财、北都是白板做赖子;翻白板是东做赖子，
    翻东是南做赖子，翻南是西做赖子，翻西是北做赖子;
</size>
<size=32><color=#004f3c>五.包牌规则</color></size>
<size=28>
1） 喂第3口包牌:清一色、将一色给喂第3口，而导致其胡牌的玩家包三家
    分数;
2） 全求人包牌:未开口、已开口未听牌的玩家点炮全求人包三家分数;
3） 抢杠胡包牌:抢杠胡大胡，由被抢杠玩家包三家分;
</size>
<size=32><color=#004f3c>六.计分规则</color></size>
<size=28>
1） 出分规则:
    ◆ 屁胡接炮:谁点炮谁出分;
    ◆ 大胡接炮:三家出分，点炮玩家额外计1番;
    ◆ 自摸:三家出分;
2） 胡牌番数:
    ◆ 屁胡:0番;
    ◆ 点炮:1番;
    ◆ 自摸:1番;
    ◆ 明杠:1番;
    ◆ 暗杠:2番;
    ◆ 赖子杠:2番;
    ◆ 红中杠:1番;
    ◆ 发财杠:1番;
    ◆ 硬胡:1番;
    ◆ 双方开口:1番;
    ◆ 杠上开花:1番;
    ◆ 大胡:2番;
3） 算分:
    ◆ 番数总和≤3番:不出分;
    ◆ 番数总和=4番:10分;
    ◆ 番数总和=5番:20分;
    ◆ 番数总和=6番:40分;
    ◆ 金顶:三位输牌玩家番数都≥6番且都开口时，每家计分多加10分;
    ◆ 阳光顶:三位输牌玩家番数都≥6番，其中1家没有开口，没开口玩
       家多加10分；2家没开口，没开口玩家多加20分;
    ◆ 三阳开泰:三位输牌玩家番数都≥6番，且都未开口，每家计分多加
       30分;</size>]],
}

return ConfigChild
