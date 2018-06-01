local ConfigChild = {}

ConfigChild.createRoomTable = 
{
    {

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
            tag = { togglesTile = "设置:", rowNum = 3, bigShow = "goldEnterSet", hideTableRule = true }, --toggle标题信息
            list = {

            }
        },
        {
            tag = { togglesTile = "结算:", rowNum = 3, bigShow = "customEnterSet" }, --toggle标题信息
            list = {
                {
                    { disable = false, json = "\"settleType\":0", toggleType = 1, toggleTitle = "积分结算", toggleIsOn = true, refreshUI = true },
                    { disable = false, json = "\"settleType\":1", toggleType = 1, toggleTitle = "金币辅助结算", toggleIsOn = false, goldSet = true, refreshUI = true, goldSetVal1 = 50, goldSetVal2 = 1500 },
                }
            }
        },
        { 
            tag = {togglesTile = "闷牌:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"menNum\":0",toggleType = 1,toggleTitle = "可不闷",toggleIsOn = true},
                    {disable = false,json = "\"menNum\":1",toggleType = 1,toggleTitle = "必闷1圈",toggleIsOn = false},
                    {disable = false,json = "\"menNum\":3",toggleType = 1,toggleTitle = "必闷3圈",toggleIsOn = false},
                },
            }
        },

        { 
            tag = {togglesTile = "封顶:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"maxScore\":6",toggleType = 1,toggleTitle = "6倍底分封顶",toggleIsOn = true},
                    {disable = false,json = "\"maxScore\":10",toggleType = 1,toggleTitle = "10倍底分封顶",toggleIsOn = false},
                    -- {disable = false,json = "\"maxScore\":20",toggleType = 1,toggleTitle = "最多压20分",toggleIsOn = false},
                },
            }
        },

        { 
            tag = {togglesTile = "特殊:",rowNum = 3},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"special\":0",toggleType = 1,toggleTitle = "235大于豹子",toggleIsOn = true},
                    {disable = false,json = "\"special\":1",toggleType = 1,toggleTitle = "235仅大于AAA",toggleIsOn = false},
                },
                {
                    {disable = false,json = "\"shunziRule\":2",toggleType = 1,toggleTitle = "顺子123最小",toggleIsOn = true, clickTip = "QKA>JQK>...>123"},
                    {disable = false,json = "\"shunziRule\":1",toggleType = 1,toggleTitle = "123仅小于QKA",toggleIsOn = false, clickTip = "QKA>123>JQK>...>234"},
                    {disable = false,json = "\"shunziRule\":0",toggleType = 1,toggleTitle = "顺子123最大",toggleIsOn = false, clickTip = "123>QKA>...>234"},
                },
            }
        },

        { 
            tag = {togglesTile = "喜牌:",rowNum = 3, bigShow = "customEnterSet" },--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"leopardAddScore\":true",toggleType = 2,toggleTitle = "豹子X10",toggleIsOn = false, clickTip = "积分结算底分X10,金币辅助结算底分X10"},
                    {disable = false,json = "\"shunKingAddScore\":true",toggleType = 2,toggleTitle = "顺金X5",toggleIsOn = false, clickTip = "积分计算底分X5,金币辅助结算底分X5"},
                },
            }
        },

        {
            tag = {togglesTile = "时间:",rowNum = 4},--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"GiveupTime\":0",toggleType = 1,toggleTitle = "无",toggleIsOn = true},
                    {disable = false,json = "\"GiveupTime\":15",toggleType = 1,toggleTitle = "15秒",toggleIsOn = false,clickTip = "15秒内无有效操作自动弃牌"},
                    {disable = false,json = "\"GiveupTime\":30",toggleType = 1,toggleTitle = "30秒",toggleIsOn = false,clickTip = "30秒内无有效操作自动弃牌"},
                    {disable = false,json = "\"GiveupTime\":60",toggleType = 1,toggleTitle = "1分钟",toggleIsOn = false,clickTip = "1分钟内无有效操作自动弃牌"},
                },
            }
        },

        { 
            tag = {togglesTile = "设置:",rowNum = 3, bigShow = "customEnterSet" },--toggle标题信息
            list =
            {
                {
                    {disable = false,json = "\"allowEnter\":true",toggleType = 2,toggleTitle = "游戏开始后允许其他玩家加入",toggleIsOn = true},
                },
                {
                    {disable = true,json = "\"sameCardThanColor\":true",toggleType = 2,toggleTitle = "达到最大轮数时相同的牌比花色（黑红梅方）",toggleIsOn = true},
                },
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
                        goldEnterSet = true, clickBigShow = "goldEnterSet", minGoldEnterVal = 50, maxGoldEnterVal = 1000, enterMulti = 20,
                        addJson = "\"roundCount\":0,\"payType\":-1,\"sameCardThanColor\":true,\"allowEnter\":true" },
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



        caculPrice = function (roundCount, playerCount, payType, bankerType)
            return Config.caculate_price_zhajinhua(roundCount, playerCount, payType, bankerType)
        end,
        configJson = "{\"game_type\":0,\"playerCount\":6,\"HallID\":0,"
    },
}


ConfigChild.GoldRule = {
    --{json = "menNum:0",toggleTitle = "可不闷"},
    {json = "menNum:1",toggleTitle = "必闷1圈"},
    {json = "menNum:3",toggleTitle = "必闷3圈"},
    {disable = false,json = "maxScore:6",toggleType = 1,toggleTitle = "6倍底分封顶",toggleIsOn = true},
    {disable = false,json = "maxScore:10",toggleType = 1,toggleTitle = "10倍底分封顶",toggleIsOn = false},
    {disable = false,json = "maxScore:20",toggleType = 1,toggleTitle = "20倍底分封顶",toggleIsOn = false},
    {disable = false,json = "special:0",toggleType = 1,toggleTitle = "235大于豹子",toggleIsOn = true},
    {disable = false,json = "special:1",toggleType = 1,toggleTitle = "235仅大于AAA",toggleIsOn = false},
    {disable = false,json = "leopardAddScore:true",toggleType = 2,toggleTitle = "豹子10倍",toggleIsOn = false},
    {disable = false,json = "shunKingAddScore:true",toggleType = 2,toggleTitle = "顺金5倍",toggleIsOn = false},
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
    [[可不闷,顺子123最小,235仅大于AAA]]
}


ConfigChild.HowToPlayGoldTexts =
{
--     [[【牌型大小】

-- 豹子>顺金>金花>顺子>对子>单张


-- 【房间规则】

-- 特殊：523仅大于AAA，顺子123最小
-- 打和：相同牌按最大牌黑红梅方比大小
--     ]],

    [[

<size=32><color=#004f3c>【牌型大小】</color></size>
    
豹子>顺金>金花>顺子>对子>单张

<size=32><color=#004f3c>【房间规则】</color></size>
            
特殊：523仅大于AAA，顺子123最小		
打和：相同牌按最大牌黑红梅方比大小
]],
}

ConfigChild.HowToPlayTexts = 
{
[[<size=32><color=#004f3c>一、简介</color></size>
<size=28><color=#7c5608>
"飘三叶"又叫炸金花等,是在全国广泛流传尤其在澳门的一种民间多人纸牌游戏,玩家以手中的三张牌比输赢,游戏过程中需要考验玩家的胆略和智慧,飘三叶是被公认的最受欢迎的纸牌游戏之一.
</color></size>
<size=32><color=#004f3c>二、基本玩法</color></size>
<size=28><color=#7c5608>
游戏参与人数 2- 6 人，使用一副去掉到大小王的扑克牌，共 52 张牌
1）坐庄：首局房主当庄，以后谁赢谁坐庄；
2）锅底：在发牌前每个玩家投一定的底注，上限6分和10分,1分的底；
3）发牌：从庄家开始逆时针发牌，每人发3张牌，牌面向下；
4）操作：从庄家的下家开始操作，可进行的选择为弃牌、看牌、比牌、跟注、加注；
5）结算：弃牌或比牌决出最后一个玩家后游戏结束，所有筹码全部归最终赢家.
</color></size>
<size=32><color=#004f3c>三、牌型及大小</color></size>
<size=28><color=#7c5608>
牌型：豹子、顺金、金花、顺子、对子、单张
1）豹子>顺金>金花>顺子>对子>单张；
2）特殊523>豹子（通过玩法选择控制）；
3）同为顺子时大小为AKQ >KQJ>...234>A23；
4）同为对子时先比较对，再比较单牌；
5）单张A最大，2最小，全部是单张时，由最大的单张开始依次比较；
6）相同的牌，谁发起比牌算谁输；若达到最大轮数时，相同的牌比最大那张牌的花色：黑桃>红桃>梅花>方片.
</color></size>
]],
}

return ConfigChild
