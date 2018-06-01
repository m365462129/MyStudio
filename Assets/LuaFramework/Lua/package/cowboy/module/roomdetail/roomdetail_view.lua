-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local RoomDetailView = Class('roomDetailView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local ComponentUtil = ModuleCache.ComponentUtil
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function RoomDetailView:initialize(...)
    -- 初始View
    View.initialize(self, "cowboy/module/roomdetail/cowboy_windowroomdetail.prefab", "CowBoy_WindowRoomDetail", 1)


    self.buttonClose       = GetComponentWithPath(self.root, "TopLeft/Child/ImageBack", ComponentTypeName.Button)
    self.cloneObj          = GetComponentWithPath(self.root,"Top/Panels/ItemHolder/item0",ComponentTypeName.Transform).gameObject
    self.content           = GetComponentWithPath(self.root,"Top/Panels/Scroll View/Viewport/Content",ComponentTypeName.Transform)
    self.textRule          = GetComponentWithPath(self.root,"Top/Child/Image/lbRule",ComponentTypeName.Text)

    -- 扑克图集
    self.spriteAsset = GetComponentWithPath(self.root,"Top/PokerAssetHolder","SpriteHolder")
    -- 红色图集
    self.redAtlas    = GetComponentWithPath(self.root, "Top/RedNumbersHolder", "SpriteAtlas")
    -- 绿色图集
    self.greenAtlas  = GetComponentWithPath(self.root, "Top/GreenNumbersHolder", "SpriteAtlas")

end


function RoomDetailView:initRoomInfo(roomInfo)
    -- print_table(roomInfo)
    self.creatorId = roomInfo.creatorId
    if(self:isGuangDong())then
        self.textRule.text = self:getPlayRuleString_GuangDong(roomInfo.playRule)
    else
        self.textRule.text = self:getPlayRuleString(roomInfo.playRule)
    end
    
end

function RoomDetailView:getPlayRuleString(playRuleString)
    local playRule = ModuleCache.Json.decode(playRuleString)
    local ruleStr = "炸金牛 "
    if playRule.bankerType == 0 then
        ruleStr = "轮流坐庄 "
    elseif playRule.bankerType == 1 then
        ruleStr = "随机坐庄 "
    elseif playRule.bankerType == 2 then
        ruleStr = "看牌抢庄 "
    end

    ruleStr = ruleStr..playRule.roundCount.."局 "..playRule.playerCount.."人 "

    if playRule.isBigBet then
        if playRule.isBigBet == 0 then ruleStr = ruleStr.."小倍场 " end
        if playRule.isBigBet == 1 then ruleStr = ruleStr.."大倍场 " end
    end

    if playRule.haveJQK == 1 then
        ruleStr = ruleStr.."带花牌 "
    end

    if playRule.payType == 0 then
        ruleStr = ruleStr.."AA支付"
    elseif playRule.payType == 1 then
        ruleStr = ruleStr.."房主支付"
    elseif playRule.payType == 2 then
        ruleStr = ruleStr.."大赢家支付"
    end

    if playRule.maxBetScore then
        ruleStr = ruleStr.." 加注上限:"..playRule.maxBetScore 
    end
    return ruleStr
end

function RoomDetailView:getPlayRuleString_GuangDong(playRuleString)
    local playRule = ModuleCache.Json.decode(playRuleString)
    local ruleStr = "经典拼十 "
    if playRule.bankerType == 0 then
        ruleStr = ruleStr .. "轮流坐庄 "
    elseif playRule.bankerType == 1 then
        ruleStr = ruleStr .. "随机坐庄 "
    elseif playRule.bankerType == 3 then
        ruleStr = ruleStr .. "牛九上庄 "
    elseif playRule.bankerType == 4 then
        ruleStr = ruleStr .. "牛牛上庄 "
    elseif playRule.bankerType == 5 then
        ruleStr = ruleStr .. "房主当庄 "
    elseif playRule.bankerType == 2 then
        ruleStr = ""
    elseif not playRule.bankerType then
        ruleStr = "通比拼十 "
    end

    if(playRule.kanPaiCount == 3)then
        ruleStr = '看三张抢庄 '
    elseif(playRule.kanPaiCount == 4)then
        ruleStr = '看四张抢庄 '
    elseif(playRule.kanPaiCount == 0)then
        ruleStr = '不看牌抢庄 '
    end

    ruleStr = ruleStr..playRule.roundCount.."局 "..playRule.playerCount.."人 "
    if(playRule.bankerType == 2)then
        local qiangZhuangStr = '抢庄 ( '
        for i=1,10 do
            local qiangZhuang = playRule['qiangZhuangScore_'..i]
            if(qiangZhuang)then
                qiangZhuangStr = qiangZhuangStr .. i .. ' '
            end
        end
        qiangZhuangStr = qiangZhuangStr .. ')'
    end

    if(not playRule.bankerType)then
        local diZhuStr = '底注' .. playRule.diZhuScore .. '分 '
        ruleStr = ruleStr .. diZhuStr
    else
        local xiaZhuStr = '下注 ( '
        for i=1,10 do
            local xiaZhu = playRule['xiaZhuScore_'..i]
            if(xiaZhu)then
                xiaZhuStr = xiaZhuStr .. i .. ' '
            end
        end
        xiaZhuStr = xiaZhuStr .. ') '
        ruleStr = ruleStr .. xiaZhuStr
    end

    if playRule.haveJQK == 1 then
        ruleStr = ruleStr.."有花牌 "
    elseif playRule.haveJQK == 0 then
        ruleStr = ruleStr.."无花牌 "
    end

    if playRule.payType == 0 then
        ruleStr = ruleStr.."AA支付"
    elseif playRule.payType == 1 then
        ruleStr = ruleStr.."房主支付"
    elseif playRule.payType == 2 then
        ruleStr = ruleStr.."大赢家支付"
    end

    if playRule.maxBetScore then
        ruleStr = ruleStr.." 加注上限:"..playRule.maxBetScore 
    end
    return ruleStr
end

function RoomDetailView:initLoopScrollViewList(roomData)       
    local roundList = roomData
    local contents = TableUtil.get_all_child(self.content)
    ComponentUtil.SafeSetActive(self.content.gameObject, false)
    for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end
    if(roomData == nil) then return end
    for i=1,#roundList do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(self.cloneObj,self.content.gameObject,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)  
        item.gameObject = obj
        item.data = roundList[i]
        local disUserId = nil
        if(i == 1)then
            disUserId = item.data.disUserId
        end
        self:fillItem(item, disUserId)
    end
    self.content.transform.localPosition = Vector3.New(self.content.transform.localPosition.x, 0, self.content.transform.localPosition.z)
    ComponentUtil.SafeSetActive(self.content.gameObject, true)
end

function RoomDetailView:fillItem(item, disUserId)

    local data = item.data
    -- print_table(data)

    local curRound = GetComponentWithPath(item.gameObject, "Title/RoundNumLbl", ComponentTypeName.Text);
    curRound.text = data.roundNumber

    for i = 1, 6 do
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject;
        ComponentUtil.SafeSetActive(playerGo, false)
    end

    for k,v in ipairs(data.player) do
        local showIndex = v.showIndex
        local recordData = data.result[tostring(v.userId)]
        if(v.userId == disUserId)then
            recordData.isDissolver = true
        end
        if(recordData)then
            local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. showIndex, ComponentTypeName.Transform).gameObject;
            self:showPlayerInfo(playerGo,recordData,v)
            ComponentUtil.SafeSetActive(playerGo, true)
        end
    end
end

function RoomDetailView:showPlayerInfo(playerGo, recordData, playerInfo)
    local name         = GetComponentWithPath(playerGo, "lbName", ComponentTypeName.Text)
    local bankerIcon   = GetComponentWithPath(playerGo, "banker", ComponentTypeName.Transform).gameObject
    local cardTypeName = GetComponentWithPath(playerGo, "lbCow", ComponentTypeName.Text)
    local wrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")
    local uiState      = GetComponentWithPath(playerGo, "Pokers", "UIStateSwitcher")
    local dissolverIcon   = GetComponentWithPath(playerGo, "dissolver", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(dissolverIcon, recordData.isDissolver or false)

    name.text = Util.filterPlayerName(playerInfo.playerName,8)
    local scoreText = tostring(playerInfo.score)
    if playerInfo.score >= 0 then
        wrapRedScore.atlas = self.redAtlas
        scoreText = "+"..scoreText
    else
        wrapRedScore.atlas = self.greenAtlas
    end

    wrapRedScore.text = scoreText
    ComponentUtil.SafeSetActive(bankerIcon, recordData.banker == "1")

    cardTypeName.text = self:getCardTypeName(recordData.cow)

    local showCards = self:translateCow(recordData.cards,recordData.cow)
    if(showCards == nil) then showCards = recordData.cards end

    uiState:SwitchState("None")
    if(self:isHaveNiuFromCardType(recordData.cow)) then uiState:SwitchState("Niu") end

    for i=1,5 do
        local card = GetComponentWithPath(playerGo, "Pokers/"..i, ComponentTypeName.Image)
        local cardSp = self.spriteAsset:FindSpriteByName(self:GetSpriteFromPoker(showCards[i]))
        card.sprite = cardSp
        if(recordData.cow == "cow0")then
            card.color = Color.New(0.7,0.7,0.7,1) 
        else
            card.color = Color.New(1,1,1,1) 
        end
    end

end

function RoomDetailView:getCardTypeName( cardType )
    if cardType == "cow1" then
        return "牛一"
    elseif cardType == "cow2" then
        return "牛二"
    elseif cardType == "cow3" then
        return "牛三"
    elseif cardType == "cow4" then
        return "牛四"
    elseif cardType == "cow5" then
        return "牛五"
    elseif cardType == "cow6" then
        return "牛六"
    elseif cardType == "cow7" then
        return "牛七"
    elseif cardType == "cow8" then
        return "牛八"
    elseif cardType == "cow9" then
        return "牛九"
    elseif cardType == "cow10" then
        return "牛牛"
    elseif cardType == "boom" then
        return "炸弹"
    elseif cardType == "goldcow" then
        if(self:isGuangDong())then
            return '五花牛'
        end
        return "金牛"
    elseif cardType == "samll" then
        return "五小牛"
    elseif cardType == "straight" then
        return "一条龙"
    elseif cardType == "silvercow" then
        if(self:isGuangDong())then
            return '牛牛'
        end
        return "银牛"
    else
        return "没牛"
    end
end

-- 转换有牛牌型
function RoomDetailView:translateCow(cards, cardType)
    if(not self:isHaveNiuFromCardType(cardType)) then return nil end -- 没牛就不用浪费时间了
    local cowNum = 1
    if(cardType == "silvercow" or cardType == "goldcow" or cardType == "cow10") then
        cowNum = 10
    else
        -- print("cardType = "..cardType)
        -- print("sub = "..string.sub(cardType,4,#cardType))
        cowNum = tonumber(string.sub(cardType,4,#cardType))
    end
    -- print("caowNum = "..cowNum)

    local newCards = {}
    local pokers = self:getCardsWithoutColor(cards)

    for i=1,3 do
        if(#newCards > 1) then break end
        for j=i+1,4 do
            if(#newCards > 1) then break end
            for k=j+1,5 do
                -- print("/*++++++++++++++++++++++++++++")
                -- print("i = "..i)
                -- print("j = "..j)
                -- print("k = "..k)
                -- print("pokers[i] = "..pokers[i])
                -- print("pokers[j] = "..pokers[j])
                -- print("pokers[k] = "..pokers[k])
                -- print("self:getNumberFormPoker(pokers[i]) = "..self:getNumberFormPoker(pokers[i]))
                -- print("self:getNumberFormPoker(pokers[j]) = "..self:getNumberFormPoker(pokers[j]))
                -- print("self:getNumberFormPoker(pokers[k]) = "..self:getNumberFormPoker(pokers[k]))
                -- print("i = "..i)
                -- print("++++++++++++++++++++++++++++*/")
                local totalValue = self:getNumberFormPoker(pokers[i]) + self:getNumberFormPoker(pokers[j]) + self:getNumberFormPoker(pokers[k])
                if(totalValue == 10 or totalValue == 20 or totalValue == 30)then

                   -- print("/*-------------------------------")

                    
                    local key1 = 0
                    local key2 = 0


                    for index=1,5 do
                        if(index ~= i and index ~= k and index ~= j) then
                            if(key1 ==0) then
                                key1 = index
                            else
                                key2 = index
                            end
                        end
                    end

                    local num11,num12 = self:getNumberFormPoker(pokers[key1])
                    local num21,num22 = self:getNumberFormPoker(pokers[key2])
                    
                    local getNiuNum = ( num11 + num21 ) % 10
                    if(getNiuNum == 0 ) then getNiuNum = 10 end

                    if num12 < num21 then
                        local temp = key1
                        key1 = key2
                        key2 = temp
                    end

                    -- print("i = "..i)
                    -- print("j = "..j)
                    -- print("k = "..k)
                    -- print("key1 = "..key1)
                    -- print("key2 = "..key2)
                    -- print("self:getNumberFormPoker(pokers[key1]) = "..self:getNumberFormPoker(pokers[key1]))
                    -- print("self:getNumberFormPoker(pokers[key2]) = "..self:getNumberFormPoker(pokers[key2]))
                    -- print("cowNum = "..cowNum)
                    -- print("getNiuNum = "..getNiuNum)

                    if(getNiuNum == cowNum) then
                        newCards[1] = cards[i]
                        newCards[2] = cards[j]
                        newCards[3] = cards[k]
                        newCards[4] = cards[key1]
                        newCards[5] = cards[key2]
                        break
                    end

                    -- print("-------------------------------*/")
                end
            end
        end
    end

    if(#newCards > 1) then
        --print("转换牌型成功")
        --print_table(newCards)
    else
        --print("转换失败")
        newCards = nil
    end

    return newCards
end

function RoomDetailView:isHaveNiuFromCardType(cardType)
    if(cardType == "cow0" or cardType == "samll" or cardType == "straight" or cardType == "boom") then return false end
    return true 
end

function RoomDetailView:getCardsWithoutColor(cards)
    local pokers = {}
    for i=1,5 do
        local card = cards[i]
        local poker = string.split(card,"_")

        if(#poker < 2) then
            poker = string.split(card,"-")
        end

        pokers[i] = poker[2]
    end
    -- print("----------------------------")
    -- print_table(pokers)
    return pokers
end

function RoomDetailView:getNumberFormPoker(poker)
    if(poker == "A") then
        return 1,1
    elseif (poker == "J") then 
        return 10,11
    elseif (poker == "Q") then 
        return 10,12
    elseif (poker == "K") then 
        return 10,13
    else
        return tonumber(poker),tonumber(poker)
    end
end

function RoomDetailView:GetSpriteFromPoker(card)
    --S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
    -- print("card = "..card)
    local poker = string.split(card,"_")

    if(#poker < 2) then
        poker = string.split(card,"-") -- 不知道为什么，服务端发来的分割方式居然有两种模式，我看你这是在刁难我胖虎 #23
    end

    local colorStr = ""
    if (poker[1] == "S") then
        colorStr = "heitao";
    elseif (poker[1] == "H") then
        colorStr = "hongtao";
    elseif (poker[1] == "C") then
        colorStr = "meihua";
    elseif (poker[1] == "D") then
        colorStr = "fangkuai";
    end
    local numberStr = ""
    if (poker[2] == "A") then
        numberStr = "1";
    elseif (poker[2] == "J") then
        numberStr = "11";
    elseif (poker[2] == "Q") then
        numberStr = "12";
    elseif (poker[2] == "K") then
        numberStr = "13";
    else
        numberStr = ""..poker[2];
    end
    local spriteName = colorStr .. "_" .. numberStr;

    return spriteName;
end

function RoomDetailView:isGuangDong()
    return AppData.App_Name == 'DHGDQP'
end


return RoomDetailView