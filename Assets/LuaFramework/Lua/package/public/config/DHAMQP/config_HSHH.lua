local ConfigChild = {}

ConfigChild.createRoomTable =
{
    { --发财晃晃麻将
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
            tag = {togglesTile = "设置:",rowNum = 3, bigShow = "goldEnterSet"},--toggle标题信息
            list =
            {

            }
        },
        --{
        --    tag = { togglesTile = "结算:", rowNum = 3, bigShow = "customEnterSet"  }, --toggle标题信息
        --    list = {
        --        {
        --            { disable = false, json = "\"settleType\":0", toggleType = 1, toggleTitle = "积分结算", toggleIsOn = true, refreshUI = true, clickBigShow = "4_1"},
        --            { disable = false, json = "\"settleType\":1", toggleType = 1, toggleTitle = "金币辅助结算", toggleIsOn = false, goldSet = true, refreshUI = true, goldSetVal1 = 50, goldSetVal2 = 1500, addJson = "\"DiFen\":1" },
        --        }
        --    }
        --},
        {
            tag = {togglesTile = "人数:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"PlayerNum\":4",toggleType = 1,toggleTitle = "4人",toggleIsOn = true},
                    {disable = false,json = "\"PlayerNum\":3",toggleType = 1,toggleTitle = "3人(无万字牌)",toggleIsOn = false},
                }
            }
        },
        {
            tag = {togglesTile = "底分:",rowNum = 4, bigShow = "customEnterSet"},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"DiFen\":2",toggleType = 1,toggleTitle = "0.2",toggleIsOn = false, ruleTitle = "底分0.2"},
                    {disable = false,json = "\"DiFen\":3",toggleType = 1,toggleTitle = "0.3",toggleIsOn = false, ruleTitle = "底分0.3"},
                    {disable = false,json = "\"DiFen\":5",toggleType = 1,toggleTitle = "0.5",toggleIsOn = false, ruleTitle = "底分0.5"},
                    {disable = false,json = "\"DiFen\":10",toggleType = 1,toggleTitle = "1",toggleIsOn = true, ruleTitle = "底分1"},
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
                    {disable = false,json = "\"isPrivateRoom\":true",toggleType = 2,toggleTitle = "私人房",toggleIsOn = true},
                },
            }
        },
        {
            tag = {togglesTile = "支付:",rowNum = 4, isPay = true, goldSet = true},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"IsGoldFieldRoom\":true",toggleType = 1,toggleTitle = "金币场",toggleIsOn = true,
                        goldEnterSet = true,clickBigShow = "goldEnterSet", minGoldEnterVal = 10, maxGoldEnterVal = 500,
                        enterMulti = 100, addJson = "\"roundCount\":0,\"PayType\":-1,\"DiFen\":1"},
                    { disable = false, json = "PayType", toggleType = 1, toggleTitle = "好友场", toggleIsOn = false,
                        dropDown = "0,1,2", dropDefault = 1, dropDownTitles = "房主,AA,大赢家",clickBigShow = "customEnterSet",dropDownWidth = 140 },
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
                    {disable = false,json = "\"PayType\":2",toggleType = 1,toggleTitle = "大赢家支付",toggleIsOn = false,clickBigShow = "customEnterSet"},
                },
            }
        },
        configJson = "{\"WanFa\":1,\"GameType\":\"hubei_fchh\",",
        caculPrice = function (roundCount, PlayerNum, PayType, bankerType)
            return Config.caculate_price_hshh(roundCount, PlayerNum, PayType, bankerType)
        end,
        isHuangShiHH = true,
        laiziTagTitle = "赖子",
        laiziTag = "3",
        headTag = {
            serverJson = "Pao",
            zeroJson = "0番",
            addJson = "番",
        },
        pnShowResult = true,
        wanfaCustomShow = true,
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
    { --红中晃晃麻将
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
            tag = {togglesTile = "设置:",rowNum = 3, bigShow = "goldEnterSet"},--toggle标题信息
            list =
            {

            }
        },
        --{
        --    tag = { togglesTile = "结算:", rowNum = 3, bigShow = "customEnterSet"  }, --toggle标题信息
        --    list = {
        --        {
        --            { disable = false, json = "\"settleType\":0", toggleType = 1, toggleTitle = "积分结算", toggleIsOn = true, refreshUI = true, clickBigShow = "4_1"},
        --            { disable = false, json = "\"settleType\":1", toggleType = 1, toggleTitle = "金币辅助结算", toggleIsOn = false, goldSet = true, refreshUI = true, goldSetVal1 = 50, goldSetVal2 = 1500, addJson = "\"DiFen\":1" },
        --        }
        --    }
        --},
        {
            tag = {togglesTile = "人数:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"PlayerNum\":4",toggleType = 1,toggleTitle = "4人",toggleIsOn = true},
                    {disable = false,json = "\"PlayerNum\":3",toggleType = 1,toggleTitle = "3人(无万字牌)",toggleIsOn = false},
                }
            }
        },
        {
            tag = {togglesTile = "底分:",rowNum = 4, bigShow = "customEnterSet"},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"DiFen\":2",toggleType = 1,toggleTitle = "0.2",toggleIsOn = false, ruleTitle = "底分0.2"},
                    {disable = false,json = "\"DiFen\":3",toggleType = 1,toggleTitle = "0.3",toggleIsOn = false, ruleTitle = "底分0.3"},
                    {disable = false,json = "\"DiFen\":5",toggleType = 1,toggleTitle = "0.5",toggleIsOn = false, ruleTitle = "底分0.5"},
                    {disable = false,json = "\"DiFen\":10",toggleType = 1,toggleTitle = "1",toggleIsOn = true, ruleTitle = "底分1"},
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
                    {disable = false,json = "\"isPrivateRoom\":true",toggleType = 2,toggleTitle = "私人房",toggleIsOn = true},
                },
            }
        },
        {
            tag = {togglesTile = "支付:",rowNum = 4, isPay = true, goldSet = true},--toggle标题信息
            list =--不同group
            {
                {--不同toggle组
                    {disable = false,json = "\"IsGoldFieldRoom\":true",toggleType = 1,toggleTitle = "金币场",toggleIsOn = true,
                        goldEnterSet = true,clickBigShow = "goldEnterSet", minGoldEnterVal = 10, maxGoldEnterVal = 500, enterMulti = 50,
                        addJson = "\"roundCount\":0,\"PayType\":-1,\"DiFen\":1"},
                    { disable = false, json = "PayType", toggleType = 1, toggleTitle = "好友场", toggleIsOn = false,
                        dropDown = "0,1,2", dropDefault = 1, dropDownTitles = "房主,AA,大赢家",clickBigShow = "customEnterSet",dropDownWidth = 140 },
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
                    {disable = false,json = "\"PayType\":2",toggleType = 1,toggleTitle = "大赢家支付",toggleIsOn = false,clickBigShow = "customEnterSet"},
                },
            }
        },
        configJson = "{\"WanFa\":0,\"GameType\":\"hubei_hzhh\",",
        caculPrice = function (roundCount, PlayerNum, PayType, bankerType)
            return Config.caculate_price_hshh(roundCount, PlayerNum, PayType, bankerType)
        end,
        isHuangShiHH = true,
        laiziTagTitle = "赖子",
        laiziTag = "3",
        headTag = {
            serverJson = "Pao",
            zeroJson = "0番",
            addJson = "番",
        },
        pnShowResult = true,
        wanfaCustomShow = true,
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
    {disable = false,json = "WanFa:1",toggleType = 1,toggleTitle = "发财晃晃",toggleIsOn = true,clickTip="勾选后红中发财和赖子可杠，16分起胡。"},
    {disable = false,json = "WanFa:0",toggleType = 1,toggleTitle = "红中晃晃",toggleIsOn = false,clickTip="勾选后红中和赖子可杠，10起胡。"},
	{disable = false,json = "PlayerNum:4",toggleType = 1,toggleTitle = "4人",toggleIsOn = true},
    {disable = false,json = "PlayerNum:3",toggleType = 1,toggleTitle = "3人(无万字牌)",toggleIsOn = false},
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
    [[红中晃晃]],[[发财晃晃]]
}

ConfigChild.HowToPlayGoldTexts =
{
    [[

<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1）  麻将共120张牌，包括:万、条、筒、中、发、白;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1）  可碰牌，可开杠，可吃牌;
2）  可自摸，可接炮，不可以一炮多响;
3）  留牌:每局留最后10张牌，即打到剩余10张牌就流局;
4）  三人玩法:去掉万字牌;
5）  两个赖子或以上不可以平胡接炮胡;
6）  见字胡不可以接炮胡;
7）  赖子:发牌后随机翻一张牌。这张牌的上一个数，就是赖子，赖子可
        以当任意牌使用，但不可充当某张牌去吃碰杠;
</size>
<size=32><color=#004f3c>三.红中晃晃</color></size>
<size=28>
1）  10倍底分起胡;
2）  翻中发白赖子:翻红中则发财赖子，翻发财则白板赖子，翻白板则发
        财为赖子;
3）  可杠牌:红中和赖子可杠;
4）  封顶:40银顶/50金顶;
</size>
<size=32><color=#004f3c>四.特殊玩法</color></size>
<size=28>
1）  亮中发白:在开局阶段，每位玩家未摸牌前，可将中发白亮出，输赢
        均翻倍;
2）  红中晃晃:亮中发白2番，若发财或白板为赖子则4番;
</size>
<size=32><color=#004f3c>六.计分规则</color></size>
<size=28>
1）  牌型分:
        ◆  屁胡:1分;平胡接炮
        ◆  手提:3分;平胡自摸，有吃碰杠行为;
        ◆  大刀:5分;平胡自摸，无吃碰杠行为;
        ◆  大胡:5分;清一色、碰碰胡、七对、将一色;大胡可叠加，例清一
              色碰碰胡加10分;
2）  胡牌番数:
        ◆  点炮:1番;
        ◆  自摸:1番;
        ◆  吃赖子:2番;
        ◆  赖子杠:2番;
        ◆  红中杠:1番;
        ◆  发财杠:1番;
        ◆  明杠:1番;
        ◆  暗杠:2番;
        ◆  硬胡:1番;
        ◆  吃碰杠3句:1番;
        ◆  吃碰杠4句:2番;
</size>
    ]],
    [[

﻿<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1）  麻将共120张牌，包括:万、条、筒、中、发、白;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1）  可碰牌，可开杠，可吃牌;
2）  可自摸，可接炮，不可以一炮多响;
3）  留牌:每局留最后10张牌，即打到剩余10张牌就流局;
4）  三人玩法:去掉万字牌;
5）  两个赖子或以上不可以平胡接炮胡;
6）  见字胡不可以接炮胡;
7）  赖子:发牌后随机翻一张牌。这张牌的上一个数，就是赖子，赖子可
        以当任意牌使用，但不可充当某张牌去吃碰杠;
</size>
<size=32><color=#004f3c>三.发财晃晃</color></size>
<size=28>
1）  16倍底分起胡;
2）  翻中发白赖子:无论翻中发白那个，都是白板做赖子;
3）  可杠牌:红中发财和赖子可杠;
4）  封顶:80银顶/100金顶;
</size>
<size=32><color=#004f3c>四.特殊玩法</color></size>
<size=28>
1）  亮中发白:在开局阶段，每位玩家未摸牌前，可将中发白亮出，输
        赢均翻倍;
2）  发财晃晃:亮中发白3番，若白板为赖子则5番;
</size>
<size=32><color=#004f3c>六.计分规则</color></size>
<size=28>
1）  牌型分:
        ◆  屁胡:1分;平胡接炮
        ◆  手提:3分;平胡自摸，有吃碰杠行为;
        ◆  大刀:5分;平胡自摸，无吃碰杠行为;
        ◆  大胡:5分;清一色、碰碰胡、七对、将一色;大胡可叠加，例清
              一色碰碰胡加10分;
2）  胡牌番数:
        ◆  点炮:1番;
        ◆  自摸:1番;
        ◆  吃赖子:2番;
        ◆  赖子杠:2番;
        ◆  红中杠:1番;
        ◆  发财杠:1番;
        ◆  明杠:1番;
        ◆  暗杠:2番;
        ◆  硬胡:1番;
        ◆  吃碰杠3句:1番;
        ◆  吃碰杠4句:2番;
</size>
]],
}

ConfigChild.HowToPlayTexts =
{
    [[
<size=32><color=#004f3c>一.麻将数量</color></size>
<size=28>
1） 麻将共120张牌，包括:万、条、筒、中、发、白;
</size>
<size=32><color=#004f3c>二.基础规则</color></size>
<size=28>
1） 可碰牌，可开杠，可吃牌;
2） 可自摸，可接炮，不可以一炮多响;
3） 坐庄:第一轮房主坐庄，之后谁胡牌谁做庄；黄庄后，庄家下家为
    庄;
4） 留牌:每局留最后10张牌，即打到剩余10张牌就流局;
5） 三人玩法:去掉万字牌;
6） 两个赖子或以上不可以平胡接炮胡;
7） 见字胡不可以接炮胡;
8） 赖子:发牌后随机翻一张牌。这张牌的上一个数，就是赖子，赖子
    可以当任意牌使用，但不可充当某张牌去吃碰杠;
</size>
<size=32><color=#004f3c>三.红中晃晃</color></size>
<size=28>
1） 10倍底分起胡;
2） 翻中发白赖子:翻红中则发财赖子，翻发财则白板赖子，翻白板则
    发财为赖子;
3） 可杠牌:红中和赖子可杠;
4） 封顶:40银顶/50金顶;
</size>
<size=32><color=#004f3c>四.发财晃晃</color></size>
<size=28>
1） 16倍底分起胡;
2） 翻中发白赖子:无论翻中发白那个，都是白板做赖子;
3） 可杠牌:红中发财和赖子可杠;
4） 封顶:80银顶/100金顶;
</size>
<size=32><color=#004f3c>五.特殊玩法</color></size>
<size=28>
1） 亮中发白:在开局阶段，每位玩家未摸牌前，可将中发白亮出，输
    赢均翻倍;
2） 红中晃晃:亮中发白2番，若发财或白板为赖子则4番;
3） 发财晃晃:亮中发白3番，若白板为赖子则5番;
</size>
<size=32><color=#004f3c>六.计分规则</color></size>
<size=28>
1） 牌型分:
    ◆ 屁胡:1分;平胡接炮
    ◆ 手提:3分;平胡自摸，有吃碰杠行为;
    ◆ 大刀:5分;平胡自摸，无吃碰杠行为;
    ◆ 大胡:5分;清一色、碰碰胡、七对、将一色;大胡可叠加，例清
       一色碰碰胡加10分;
2） 胡牌番数:
    ◆ 点炮:1番;
    ◆ 自摸:1番;
    ◆ 吃赖子:2番;
    ◆ 赖子杠:2番;
    ◆ 红中杠:1番;
    ◆ 发财杠:1番;
    ◆ 明杠:1番;
    ◆ 暗杠:2番;
    ◆ 硬胡:1番;
    ◆ 吃碰杠3句:1番;
    ◆ 吃碰杠4句:2番;
</size>
    ]],
}

return ConfigChild
