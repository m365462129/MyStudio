local ConfigChild = {}

ConfigChild.createRoomTable = {

    { --经典玩法


        {--不同分类 局数 人数..
            tag = { togglesTile = "局数:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"roundCount\":8", toggleType = 1, toggleTitle = "8局", toggleIsOn = true },
                    { disable = false, json = "\"roundCount\":12", toggleType = 1, toggleTitle = "12局", toggleIsOn = false },
                    { disable = false, json = "\"roundCount\":18", toggleType = 1, toggleTitle = "18局", toggleIsOn = false },
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
            tag = { togglesTile = "", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = true, json = "\"secret\":true", toggleType = 2, toggleTitle = "私密房间", toggleIsOn = true, moreBaseScore = 30 },
                },
            }
        },
        {
            tag = { togglesTile = "人数:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"playerCount\":4", toggleType = 1, toggleTitle = "4人", toggleIsOn = false, clickSmallShow = "2_1" },
                    { disable = false, json = "\"playerCount\":3", toggleType = 1, toggleTitle = "3人", toggleIsOn = true },
                    { disable = false, json = "\"playerCount\":2", toggleType = 1, toggleTitle = "2人", toggleIsOn = false, clickSmallShow = "2_3" },
                }
            }
        },
        {
            tag = { togglesTile = "人数:", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"playerCount\":2", toggleType = 1, toggleTitle = "2人", toggleIsOn = true, clickSmallShow = "2_3" },
                    { disable = false, json = "\"playerCount\":3", toggleType = 1, toggleTitle = "3人", toggleIsOn = false, clickSmallShow = "2_2" },
                }
            }
        },
        {
            tag = { togglesTile = "玩法:", rowNum = 3 }, --toggle标题信息
            list = {
                {
                    { disable = true, json = "\"black3_on_firstloop\":true", toggleType = 2, toggleTitle = "首局先出黑桃3", toggleIsOn = true, smallShow = "2_3", smallShowType = 2 },
                    { disable = false, json = "\"pay_all\":true", toggleType = 2, toggleTitle = "放走包赔", toggleIsOn = false, smallShow = "2_3", smallShowType = 2 },
                },
                {
                    { disable = false, json = "\"notify_card_cnt\":false", toggleType = 1, toggleTitle = "不显示牌数", toggleIsOn = true },
                    { disable = false, json = "\"notify_card_cnt\":true", toggleType = 1, toggleTitle = "显示牌数", toggleIsOn = false },
                },
                --{
                --    {disable = false,json = "\"allow_pass\":false",toggleType = 1,toggleTitle = "有牌必压",toggleIsOn = true},
                --    {disable = false,json = "\"allow_pass\":true",toggleType = 1,toggleTitle = "可不要",toggleIsOn = false},
                --},
                {
                    { disable = false, json = "\"init_card_cnt\":16", toggleType = 1, toggleTitle = "16张牌", toggleIsOn = true, smallShow = "2_1", smallShowType = 2 },
                    { disable = false, json = "\"init_card_cnt\":15", toggleType = 1, toggleTitle = "15张牌", toggleIsOn = false, smallShow = "2_1", smallShowType = 2 },
                },
                {
                    { disable = false, json = "\"init_card_cnt\":13", toggleType = 1, toggleTitle = "13张牌", toggleIsOn = true, smallShow = "2_1", smallShowType = 1 },
                },
            }
        },
        {
            tag = { togglesTile = "", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"isPrivateRoom\":true", toggleType = 2, toggleTitle = "私人房", toggleIsOn = true, smallShow = "2_2", smallShowType = 2 },
                },
            }
        },
        {
            tag = { togglesTile = "", rowNum = 3, bigShow = "goldEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = true, json = "\"isPrivateRoom\":true", toggleType = 2, toggleTitle = "私人房", toggleIsOn = true, smallShow = "2_2", smallShowType = 1 },
                },
            }
        },
        {
            tag = { togglesTile = "支付:", rowNum = 4, isPay = true, goldSet = true }, --toggle标题信息
            list = --不同group
            {
                {--不同toggle组
                    { disable = false, json = "\"IsGoldFieldRoom\":true", toggleType = 1, toggleTitle = "金币场", toggleIsOn = true,
                        goldEnterSet = true, clickBigShow = "goldEnterSet", minGoldEnterVal = 20, maxGoldEnterVal = 1000, enterMulti = 50, addJson = "\"roundCount\":0,\"payType\":-1" },
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
            return Config.caculate_price6(roundCount, playerCount, payType, bankerType)
        end,
        configJson = "{\"game_type\":2,\"HallID\":0,\"GameType\":2,\"rate\":1,"
    },
}

ConfigChild.GoldRule = {
    { disable = false, json = "playerCount:4", toggleType = 1, toggleTitle = "4人", toggleIsOn = false, clickSmallShow = "2_1" },
    { disable = false, json = "playerCount:3", toggleType = 1, toggleTitle = "3人", toggleIsOn = true },
    { disable = false, json = "playerCount:2", toggleType = 1, toggleTitle = "2人", toggleIsOn = false, clickSmallShow = "2_3" },
    { disable = false, json = "init_card_cnt:16", toggleType = 1, toggleTitle = "16张牌", toggleIsOn = true, smallShow = "2_1", smallShowType = 2 },
    { disable = false, json = "init_card_cnt:15", toggleType = 1, toggleTitle = "15张牌", toggleIsOn = false, smallShow = "2_1", smallShowType = 2 },
    { disable = false, json = "init_card_cnt:13", toggleType = 1, toggleTitle = "13张牌", toggleIsOn = true, smallShow = "2_1", smallShowType = 1 },
    --{disable = true,json = "black3_on_firstloop:true",toggleType = 2,toggleTitle = "首局先出黑桃3",toggleIsOn = true,smallShow="2_3",smallShowType = 2},
    { disable = false, json = "notify_card_cnt:false", toggleType = 1, toggleTitle = "不显示牌数", toggleIsOn = true },
    { disable = false, json = "notify_card_cnt:true", toggleType = 1, toggleTitle = "显示牌数", toggleIsOn = false },
    { disable = false, json = "allow_pass:false", toggleType = 1, toggleTitle = "有牌必压", toggleIsOn = true },
    { disable = false, json = "allow_pass:true", toggleType = 1, toggleTitle = "可不要", toggleIsOn = false },
    { disable = false, json = "pay_all:true", toggleType = 2, toggleTitle = "放走包赔", toggleIsOn = false, smallShow = "2_3", smallShowType = 2 },
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
    [[跑得快规则]],
    [[跑得快规则]]
}


ConfigChild.HowToPlayGoldTexts = {
    [[
<size=32><color=#004f3c>一、基本规则</color></size>
<size=28><color=#7c5608>
1）首发：每局有黑桃三的玩家首发.
2）输赢条件：第一个出完手中所有牌的玩家本局获胜，每局只有1个赢家.
3）使用牌数：使用48张牌,扣除(两张王牌,3个2,1个A).
5）出牌规则：
        ◆  每局黑桃3先出，且所出的牌中必须包含黑桃3.
        ◆  游戏者逆时针轮流出牌，如果一轮之中其他游戏者都"要不起"，
则最后一次出牌者继续出牌.
        ◆  有牌必出压，如果手牌中有要的起的牌则必须出牌.
        ◆  下家报单时,如果要出单张，那么必须出最大的单张.
</color></size>
<size=32><color=#004f3c>二、牌型介绍</color></size>
<size=28><color=#7c5608>
1）单张:可以是手中的任意一张牌.
2）对子:两张牌点相同的牌,两张牌的花色可以不同.
3）连对:两对或两对以上相连的牌,如:5566.
4）三带二:三张牌点相同的牌,带二张杂牌,如:55566、55567;另外带的杂牌可以是任意牌.
5）飞机带翅膀,两个或两个以上相连的三同张牌,如:5556667788,QQQKKK8899.另外带的杂牌可以是任意牌.
6）顺子,五张或五张以上牌点连续的牌.例如:3456789,10JQKA等.
7）炸弹,四张或四张以上牌点相同的牌,如:6666、8888
</color></size>
<size=32><color=#004f3c>三、牌型规则</color></size>
<size=28><color=#7c5608>
1）点数大小规则:2  >  A  >  K  >  Q  >  J  >  10  >  9  >  8  >  7  >  6  >  5  >  4  >  3
2）顺子从最小从3开始，到A结束，则最小的顺子是34567，最大的顺子是10、J、Q、K、A.
3）单张、对子、三同张、连对、连三同张、顺子等牌型,直接根据牌点确定大小,但要求出牌的数量必须相同;例：上家出5张顺子，那么下家出的顺子也必须是5张并且最大的那张要大于上家最大的那张.
4）炸弹大于以上所有牌型,炸弹之间按点数比大小.
5）除炸弹外其余牌型不能互压,同种牌型比较点数大小,相同牌型出牌数量也必须一致.
</color></size>
<size=32><color=#004f3c>四、分数计算</color></size>
<size=28><color=#7c5608>
1）当玩家胜利时，根据输家手中剩余牌数计分，1张牌1分，剩余1张牌不扣分.
2）如果玩家在该局游戏中一张牌都没有出，则输分翻倍，例：16张，A玩家张牌都没有出，则需要在结算时扣除16*2=分.
3）最终结算金币数量=输赢分数*底分
4）炸弹现结:如果炸弹打出后,其他两家都要不起,则立即每人扣10*底分的金币给出炸弹的玩家.
</color></size>
    ]],


    [[
<size=32><color=#004f3c>一、基本规则</color></size>
<size=28><color=#7c5608>
1）首发：每局有黑桃三的玩家首发，如没有黑桃三则，按照黑红梅方的顺序以此类推.
2）输赢条件：第一个出完手中所有牌的玩家本局获胜，每局只有1个赢家.
3）使用牌数：使用48张牌,扣除(两张王牌,3个2,1个A).
5）出牌规则：
        ◆  游戏者逆时针轮流出牌，如果一轮之中其他游戏者都"要不起"，
则最后一次出牌者继续出牌.
        ◆  有牌必出压，如果手牌中有要的起的牌则必须出牌.
        ◆  下家报单时,如果要出单张，那么必须出最大的单张.
</color></size>
<size=32><color=#004f3c>二、牌型介绍</color></size>
<size=28><color=#7c5608>
1）单张:可以是手中的任意一张牌.
2）对子:两张牌点相同的牌,两张牌的花色可以不同.
3）连对:两对或两对以上相连的牌,如:5566.
4）三带二:三张牌点相同的牌,带二张杂牌,如:55566、55567;另外带的杂牌可以是任意牌.
5）飞机带翅膀,两个或两个以上相连的三同张牌,如:5556667788,QQQKKK8899.另外带的杂牌可以是任意牌.
6）顺子,五张或五张以上牌点连续的牌.例如:3456789,10JQKA等.
7）炸弹,四张或四张以上牌点相同的牌,如:6666、8888
</color></size>
<size=32><color=#004f3c>三、牌型规则</color></size>
<size=28><color=#7c5608>
1）点数大小规则:2  >  A  >  K  >  Q  >  J  >  10  >  9  >  8  >  7  >  6  >  5  >  4  >  3
2）顺子从最小从3开始，到A结束，则最小的顺子是34567，最大的顺子是10、J、Q、K、A.
3）单张、对子、三同张、连对、连三同张、顺子等牌型,直接根据牌点确定大小,但要求出牌的数量必须相同;例：上家出5张顺子，那么下家出的顺子也必须是5张并且最大的那张要大于上家最大的那张.
4）炸弹大于以上所有牌型,炸弹之间按点数比大小.
5）除炸弹外其余牌型不能互压,同种牌型比较点数大小,相同牌型出牌数量也必须一致.
</color></size>
<size=32><color=#004f3c>四、分数计算</color></size>
<size=28><color=#7c5608>
1）当玩家胜利时，根据输家手中剩余牌数计分，1张牌1分，剩余1张牌不扣分.
2）如果玩家在该局游戏中一张牌都没有出，则输分翻倍，例：16张，A玩家张牌都没有出，则需要在结算时扣除16*2=分.
3）最终结算金币数量=输赢分数*底分
4）炸弹现结:如果炸弹打出后,其他两家都要不起,则立即每人扣10*底分的金币给出炸弹的玩家.
</color></size>
   ]]
}



ConfigChild.HowToPlayTexts = {
    [[<size=32><color=#004f3c>一、基本规则</color></size>
  <size=28><color=#7c5608>
  1）参与人数:2人、3人或4人.
  2）首发：第一局有黑桃三的玩家首发，之后谁赢谁首发.
  3）输赢条件：第一个出完手中所有牌的玩家本局获胜，每局只有1个赢家.
  4）使用牌数：
   ◆ 16张玩法：使用48张牌,扣除(两张王牌,3个2,1个A).
   ◆ 15张玩法：使用45张牌,扣除(两张王牌,3个2,3个A,一个K).
   ◆ 13张玩法（四人）：使用52张牌,扣除(两张王牌).
  5）出牌规则：
   ◆ 3人和4人模式下第1局黑桃3先出，且所出的牌中必须包含黑桃3.
   ◆ 2人模式下若没有黑桃3则红桃3先出，没有继续判定直到方块A.
   ◆ 游戏者逆时针轮流出牌，如果一轮之中其他游戏者都"要不起"，
  则最后一次出牌者继续出牌.
   ◆ 有牌必出模式下，如果手牌中有要的起的牌则必须出牌。非此
  模式可以选择不要.
   ◆ 下家报单时,如果要出单张，那么必须出最大的单张，其余的牌
  则不能选中.
  ◆ 放走包赔:下家爆单上家可不出最大牌,如因没出最大牌放走下家,
  则赔所有人.
  </color></size>
  <size=32><color=#004f3c>二、牌型介绍</color></size>
  <size=28><color=#7c5608>
  1）单张:可以是手中的任意一张牌.
  2）对子:两张牌点相同的牌,两张牌的花色可以不同.
  3）连对:两对或两对以上相连的牌,如:5566.
  4）三带二:三张牌点相同的牌,带二张杂牌,如:55566、55567;另外带的杂牌可以是任意牌.
  5）飞机带翅膀,两个或两个以上相连的三同张牌,如:5556667788,QQQKKK8899.另外带的杂牌可以是任意牌.
  6）顺子,五张或五张以上牌点连续的牌.例如:3456789,10JQKA等.
  7）炸弹,四张或四张以上牌点相同的牌,如:6666、8888
  </color></size>
  <size=32><color=#004f3c>三、牌型规则</color></size>
  <size=28><color=#7c5608>
  1）点数大小规则:2 > A > K > Q > J > 10 > 9 > 8 > 7 > 6 > 5 > 4 > 3
  2）顺子从最小从3开始，到A结束，则最小的顺子是34567，最大的顺子是10、J、Q、K、A.
  3）单张、对子、三同张、连对、连三同张、顺子等牌型,直接根据牌点确定大小,但要求出牌的数量必须相同;例：上家出5张顺子，那么下家出的顺子也必须是5张并且最大的那张要大于上家最大的那张.
  4）炸弹大于以上所有牌型,炸弹之间按点数比大小.
  3）除炸弹外其余牌型不能互压,同种牌型比较点数大小,相同牌型出牌数量也必须一致.
  </color></size>
  <size=32><color=#004f3c>四、分数计算</color></size>
  <size=28><color=#7c5608>
  1）当玩家胜利时，根据输家手中剩余牌数计分，1张牌1分，剩余1张牌不计分.
  2）如果玩家在该局游戏中一张牌都没有出，则需要翻倍扣分，例：16张玩法，A玩家张牌都没有出，则需要在结算时扣除16*2=32分.
  3）胜利者赢得所有输家的分数.
  4）炸弹现结:如果炸弹打出后,其他两家都要不起,则立即每人扣10分给出炸弹的玩家.
  5）加倍：创建游戏的时候可以选择牌局加2倍和加3倍.选择了倍数之后则最后结算时乘倍数.例：牌局开始的时候选了3倍，如果其余两家都剩10张牌，那么赢家加分为：（10+10）*3=60分.
  </color></size>
  ]],
}



return ConfigChild
