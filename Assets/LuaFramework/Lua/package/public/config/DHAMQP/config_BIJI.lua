local ConfigChild = {}

ConfigChild.createRoomTable = {
    { --极速
        {--不同分类 局数 人数..
            tag = { togglesTile = "局数:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"roundCount\":8", toggleType = 1, toggleTitle = "8局", toggleIsOn = true },
                    { disable = false, json = "\"roundCount\":16", toggleType = 1, toggleTitle = "16局", toggleIsOn = false },
                    { disable = false, json = "\"roundCount\":24", toggleType = 1, toggleTitle = "24局", toggleIsOn = false },
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
            tag = { togglesTile = "倍数:", rowNum = 3 }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"scoreType\":0", toggleType = 1, toggleTitle = "1 2 3 4", toggleIsOn = false, ruleTitle = "(1 2 3 4)倍", clickTipType = "喜牌_1" },
                    { disable = false, json = "\"scoreType\":1", toggleType = 1, toggleTitle = "2 4 6 8", toggleIsOn = true, ruleTitle = "(2 4 6 8)倍", clickTipType = "喜牌_2" },
                }
            }
        },
        {
            tag = { togglesTile = "喜牌:", rowNum = 3 }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"extraScoreTypes\":16", toggleType = 1, toggleTitle = "经典玩法", toggleIsOn = true, clickTip = "喜牌（总人数-1）*1\n三顺清与全三条喜牌分数加倍|喜牌（总人数-1）*2\n三顺清与全三条喜牌分数加倍", clickTipType = "喜牌" },
                    { disable = false, json = "\"extraScoreTypes\":15", toggleType = 1, toggleTitle = "固定倍数", toggleIsOn = false, clickTip = "清连顺/连顺/三顺清/全三条/四个头/三清*6\n双顺清/双三条/三顺子*3，全黑/全红*3|清连顺/连顺/三顺清/全三条/四个头/三清*12\n双顺清/双三条/三顺子*6，全黑/全红*3", clickTipType = "喜牌" },
                }
            }
        },
        {
            tag = { togglesTile = "配牌:", rowNum = 3 }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"pokersNum\":9", toggleType = 1, toggleTitle = "9张配", toggleIsOn = true, clickTip = "发9张牌组三道牌", isNew = true },
                    { disable = false, json = "\"pokersNum\":10", toggleType = 1, toggleTitle = "10张配", toggleIsOn = false, clickTip = "特色玩法：发10张牌选择9张组三道牌", isNew = true },
                }
            }
        },
        {
            tag = { togglesTile = "玩法:", rowNum = 3 }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"hasKing\":false", toggleType = 1, toggleTitle = "不带王", toggleIsOn = true },
                    { disable = false, json = "\"hasKing\":true", toggleType = 1, toggleTitle = "带双王", toggleIsOn = false, clickTip = "王牌不可以与自己手牌中的牌大小花色都相同，可以与其它玩家手牌中的牌大小花色一样" },
                }
            }
        },
        {
            tag = { togglesTile = "设置:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"allowHalfEnter\":false", toggleType = 2, toggleTitle = "游戏开始后不允许加入", toggleIsOn = true },
                }
            }
        },
        {
            tag = { togglesTile = "", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    {disable = false,json = "\"isPrivateRoom\":true",toggleType = 2,toggleTitle = "私人房",toggleIsOn = false},
                },
            }
        },
        {
            tag = { togglesTile = "支付:", rowNum = 4, isPay = true, goldSet = true }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"IsGoldFieldRoom\":true", toggleType = 1, toggleTitle = "金币场", toggleIsOn = true,
                        goldEnterSet = true, clickBigShow = "goldEnterSet", minGoldEnterVal = 50, maxGoldEnterVal = 1000, enterMulti = 30,
                        addJson = "\"roundCount\":0,\"payType\":-1,\"allowHalfEnter\":true" }, --allowHalfEnter
                    { disable = false, json = "payType", toggleType = 1, toggleTitle = "好友场", toggleIsOn = false,
                        dropDown = "0,1,2", dropDefault = 0, dropDownTitles = "AA,房主,大赢家", clickBigShow = "customEnterSet", dropDownWidth = 140 },
                },
            }
        },
        {
            tag = { togglesTile = "支付:", rowNum = 3, isPay = true, goldSet = false }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"payType\":0", toggleType = 1, toggleTitle = "AA支付", toggleIsOn = true, clickBigShow = "customEnterSet" },
                    { disable = false, json = "\"payType\":1", toggleType = 1, toggleTitle = "房主支付", toggleIsOn = false, clickBigShow = "customEnterSet" },
                    { disable = false, json = "\"payType\":2", toggleType = 1, toggleTitle = "大赢家支付", toggleIsOn = false, clickBigShow = "customEnterSet" },
                },
            }
        },


        caculPrice = function(roundCount, playerCount, payType, bankerType)
            return Config.caculate_price4(roundCount, playerCount, payType, bankerType)
        end,
        configJson = "{\"gameType\":0,\"playerCount\":5,\"HallID\":0,\"GameType\":0,"
    },
}

ConfigChild.GoldRule = {
    { json = "scoreType:0", toggleTitle = "(1 2 3 4)倍算分" },
    { json = "scoreType:1", toggleTitle = "(2 4 6 8)倍算分" },
    { json = "extraScoreTypes:16", toggleTitle = "经典喜牌算法" },
    { json = "extraScoreTypes:15", toggleTitle = "喜牌固定倍数" },
    { json = "pokersNum:9", toggleTitle = "9张配" },
    { json = "pokersNum:10", toggleTitle = "10张配" },
    { json = "hasKing:false", toggleTitle = "不带王" },
    { json = "hasKing:true", toggleTitle = "带双王" },
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
    [[经典玩法,不带王]]
}

ConfigChild.HowToPlayGoldTexts = {
    [[
<size=32><color=#004f3c>【牌型大小】</color></size>

三张>同花顺>同花>顺子>对子>单张

<size=32><color=#004f3c>【喜牌奖励】</color></size>

四个头  6倍	  三清	  6倍
清连顺  6倍	  双三条  3倍
全三条  6倍	  三顺子  3倍
三顺清	6倍	  全黑	  3倍
连顺	6倍	  全红	  3倍
双顺清	3倍]]
}



ConfigChild.HowToPlayTexts = {
    [[<size=28><color=#004f3c>一.玩法说明</color></size>

   1）一副牌去掉大小王总共52张牌，游戏支持2-5名玩家；
   2）带王玩法：54张牌，支持2-5名玩家；
   3）开局每人发9张牌，玩家需将9张牌配成头道、中道、尾道三副牌，每副三张，三道牌要遵循：头道<中道<尾道；
   4）比牌：所有玩家互相分别对比三道牌，先对比头道，再对比中道，最后对比尾道，判定输赢，结算积分，玩家可选择投降，投降后，只输牌分，不扣其他人的喜牌奖励分和通关分；
   5）比牌规则
   先比较牌型：三条>同花顺>同花>顺子>对子>单张；
   后比较点数：A>K>Q>J>10>9>8>7>6>5>4>3>2；
   最后比较花色：黑桃>红桃>梅花>方片（相同大小的牌对比最大牌的花色）；
   6）通关：玩家三道牌，每一道都比其他玩家大，则为通关。通关则其他玩家需给通关玩家额外奖励分，算分选项1 2 3 4：通关分 =（总人数-1）*1； 算分选项2 4 6 8：通关分=（总人数-1）*2；
   7）喜牌：当配的九张牌达成一定条件，会获得喜牌奖励。其他玩家支付给喜牌玩家一定积分；喜牌不管输赢都有奖励，并且可以叠加；
   8）算分：分别有1 2 3 4和2 4 6 8两种方式；
   1 2 3 4选项喜牌计算：经典玩法喜牌分数 =（总人数-1）*1， 三顺清与全三 条喜牌分数加倍；固定加分清连顺/连顺/三顺清/全三条/四个头/三清固定6分，双顺清/双三条/三顺子固定3分 ，全黑/全红固定3分；
   2 4 6 8选项喜牌计算：经典玩法喜牌分数=（总人数-1）*2， 三顺清与全三 条喜牌分数加倍；固定加分清连顺/连顺/三顺清/全三条/四个头/三清固定12分，双顺清/双三条/三顺子固定6分 ，全黑/全红固定3分。


   <size=28><color=#004f3c>二.积分结算规则</color></size>

   算分选项：1 2 3 4
   1）2人模式，每道牌赢家得1分，输家扣1分；
   2）3人模式，每道牌最大的玩家为赢家，其他为输家。赢家得3分，第二大的扣1分，最小的扣2分；
   3）4人模式，每道牌最大的玩家为赢家，其他为输家。赢家得6分，第二大的扣1分，第三大的扣2分，最小的扣3分；
   4）5人模式，每道牌最大的玩家为赢家，其他为输家。赢家得10分，第二大的扣1分，第三大的扣2分，第四大的扣3分，最小的扣4分
   算分选项：2 4 6 8
   1)2人模式，每道牌赢家得2分，输家扣2分；
   2)3人模式，每道牌最大的玩家为赢家，其他为输家。赢家得6分，第二大的扣2分，最小的扣4分；
   3)4人模式，每道牌最大的玩家为赢家，其他为输家。赢家得12分，第二大的扣2分，第三大的扣4分，最小的扣6分；
   4)5人模式，每道牌最大的玩家为赢家，其他为输家。赢家得20分，第二大的扣2分，第三大的扣4分，第四大的扣6分，最小的扣8分。

   <size=28><color=#004f3c>三.喜牌说明</color></size>

   1）三清：三墩牌都是同花；（与三顺清/清连顺不叠加）
   2）全黑：9张牌全部由黑桃或梅花组成的牌型；
   3）全红：9张牌全部由红桃或方片组成的牌型；
   4）三顺子：三道牌全部都是顺子；
   5）双顺清：头道、中道、尾道中存在两个同花顺；
   6）三顺清：三道牌全部为同花顺；
   7）双三条：头道、中道、尾道中存在两个三条；
   8）全三条：三道牌3副3条；
   9）四个头：手上牌有四张一样的牌；（注：四张必须配出一个三条，才算四个头奖励；若有两个四张，并配出两个三条，则可获得两次四个头奖励）；
   10）连顺：9张牌可组成连贯的顺子，例如A23、456、789；
   11）清连顺：9张牌可组成连贯的顺子，并且9张牌只有一种花色。
   ]],
    [[<size=28><color=#004f3c>一.玩法说明</color></size>

  1）一副牌去掉大小王总共52张牌，游戏支持2-5名玩家；
  2）带王玩法：54张牌，支持2-5名玩家；
  3）开局每人发9张牌，玩家需将9张牌配成头道、中道、尾道三副牌，每副三张，三道牌要遵循：头道<中道<尾道；
  4）比牌：所有玩家互相分别对比三道牌，先对比头道，再对比中道，最后对比尾道，判定输赢，结算积分，玩家可选择投降，投降后，只输牌分，不扣其他人的喜牌奖励分和通关分；
  5）比牌规则
  先比较牌型：三条>同花顺>同花>顺子>对子>单张；
  后比较点数：A>K>Q>J>10>9>8>7>6>5>4>3>2；
  最后比较花色：黑桃>红桃>梅花>方片（相同大小的牌对比最大牌的花色）；
  6）通关：玩家三道牌，每一道都比其他玩家大，则为通关。通关则其他玩家需给通关玩家额外奖励分，算分选项1 2 3 4：通关分=（总人数-1）*1；算分选项2 4 6 8：通关分=（总人数-1）*2；
  7）喜牌：当配的九张牌达成一定条件，会获得喜牌奖励。其他玩家支付给喜牌玩家一定积分；喜牌不管输赢都有奖励，并且可以叠加；
  8）算分：分别有1 2 3 4和2 4 6 8两种方式；1 2 3 4选项喜牌计算：经典 玩法喜牌分数=（总人数-1）*1；固定加分喜牌四个头6分；2 4 6 8选项喜 牌计算：经典玩法喜牌分数=（总人数-1）*2，；固定加分喜牌四个头12分。


  <size=28><color=#004f3c>二.积分结算规则</color></size>

  算分选项：1 2 3 4
  1）2人模式，每道牌赢家得1分，输家扣1分；
  2）3人模式，每道牌最大的玩家为赢家，其他为输家。赢家得3分，第二大的扣1分，最小的扣2分；
  3）4人模式，每道牌最大的玩家为赢家，其他为输家。赢家得6分，第二大的扣1分，第三大的扣2分，最小的扣3分；
  4）5人模式，每道牌最大的玩家为赢家，其他为输家。赢家得10分，第二大的扣1分，第三大的扣2分，第四大的扣3分，最小的扣4分
  算分选项：2 4 6 8
  1）2人模式，每道牌赢家得2分，输家扣2分；
  2）3人模式，每道牌最大的玩家为赢家，其他为输家。赢家得6分，第二大的扣2分，最小的扣4分；
  3）4人模式，每道牌最大的玩家为赢家，其他为输家。赢家得12分，第二大的扣2分，第三大的扣4分，最小的扣6分；
  4）5人模式，每道牌最大的玩家为赢家，其他为输家。赢家得20分，第二大的扣2分，第三大的扣4分，第四大的扣6分，最小的扣8分
  。


  <size=28><color=#004f3c>三.喜牌说明</color></size>

  四个头：手上牌有四张一样的牌；（注：四张必须配出一个三条，才算四个头奖励；若有两个四张，并配出两个三条，则可获得两次四个头奖励）；
  ]],
}

return ConfigChild
