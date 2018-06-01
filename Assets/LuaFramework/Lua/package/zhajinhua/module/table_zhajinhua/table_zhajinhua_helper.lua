local ModuleCache = ModuleCache

---@class TableHelper
local TableHelper = {}
TableHelper.PlayerMaxCount = 6 --玩家最多数
TableHelper.PokerCount = 3 --炸金花是几张牌玩
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local Sequence = DG.Tweening.DOTween.Sequence
local CardCommon = require "package/zhajinhua/module/table_zhajinhua/gamelogic_common"

local normalColor = UnityEngine.Color.white
local maskColor = UnityEngine.Color(0.3,0.3,0.3,1)

function TableHelper:setSeatPlayerInfo(seatHolder, playerInfo)

end

function TableHelper:initSeatHolder(seatHolder, seatIndex, goSeat, handPokerRoot)
    local root = goSeat
    seatHolder.seatRoot = goSeat
    local pokerAssetHolder = seatHolder.pokerAssetHolder

    seatHolder.buttonNotSeatDown = GetComponentWithPath(root, "NotSeatDown", ComponentTypeName.Button)        
    seatHolder.goSeatInfo = GetComponentWithPath(root, "Info", ComponentTypeName.Transform).gameObject                   
    local uiStateSwitcher = ModuleCache.ComponentManager.GetComponent(root,"UIStateSwitcher")
    ModuleCache.TransformUtil.SetX(uiStateSwitcher.transform, 0, true)
    ModuleCache.TransformUtil.SetY(uiStateSwitcher.transform, 0, true)    

    local animSelectBankerVertical = GetComponentWithPath(root, "Info/EffectVertical", "UIImageAnimation")
    seatHolder.animSelectBanker = animSelectBankerVertical
    if seatIndex == 1 then
       uiStateSwitcher:SwitchState("Bottom")
        local animSelectBankerHorizontal = GetComponentWithPath(root, "Info/EffectHorizontal", "UIImageAnimation")           
        seatHolder.animSelectBanker = animSelectBankerHorizontal
    elseif seatIndex == 5 or seatIndex == 6 then
        uiStateSwitcher:SwitchState("Left")
    elseif seatIndex == 4 then
        --uiStateSwitcher:SwitchState("Left")
        uiStateSwitcher:SwitchState("Top")
    elseif seatIndex == 2 or seatIndex == 3 then        
       uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
    end

    seatHolder.WinnerEffectRoot = GetComponentWithPath(root, "State/Group/WinnerEffectRoot", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.WinnerEffectRoot.gameObject, false)
    seatHolder.HeadGray = GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/HeadGray", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.HeadGray.gameObject, false)
    seatHolder.imagePlayerHead = GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/Image", ComponentTypeName.Image)
    seatHolder.textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)
    seatHolder.textScore =  GetComponentWithPath(root, "Info/Point/Text", ComponentTypeName.Text)
    seatHolder.GoldCount = GetComponentWithPath(root, "Info/Currency/GoldRoot/GoldCount", ComponentTypeName.Text)
    seatHolder.CurrencyUIStateSwitcher = GetComponentWithPath(root, "Info/Currency", "UIStateSwitcher")
    seatHolder.imageDisconnect =  GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/StateDisconnect", ComponentTypeName.Image)
    seatHolder.imageTemporaryLeave = GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/StateTemporaryLeave", ComponentTypeName.Image)
    seatHolder.ReadyRoot = GetComponentWithPath(root, "State/ReadyRoot", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.ReadyRoot.gameObject, false)
    seatHolder.imageBanker = GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/Banker", ComponentTypeName.Image)
    seatHolder.imageCreator = GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/Creator", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, false)
    --倒计时框
    seatHolder.imageTimeLimit = GetComponentWithPath(root, "Info/HeadBg/BgFilled/Frame", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTimeLimit.gameObject, false)
    seatHolder.TimeChangeShow = GetComponentWithPath(seatHolder.imageTimeLimit.gameObject, "TimeChangeShow", ComponentTypeName.Image)
    seatHolder.goRoundScore = GetComponentWithPath(root, "State/Group/RoundScoreAnim/bg", ComponentTypeName.Transform).gameObject
    seatHolder.textRoundWinScore = GetComponentWithPath(seatHolder.goRoundScore, "win/score", ComponentTypeName.Text)
    seatHolder.textRoundLoseScore = GetComponentWithPath(seatHolder.goRoundScore, "lose/score", ComponentTypeName.Text)
    seatHolder.goSpeakIcon =  GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Image)
    seatHolder.NewStateRoot = GetComponentWithPath(root, "State/Group/NewStateRoot", "UIStateSwitcher")
    seatHolder.NewStateRoot:SwitchState("No")
    --补充金币状态
    seatHolder.rechargeState =  GetComponentWithPath(root, "Info/HeadBg/RechargeGold", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.rechargeState.gameObject, false)

    seatHolder.emojiGoArray = {}
    for i=1,20 do
        seatHolder.emojiGoArray[i] = GetComponentWithPath(root, "State/Group/ChatFace/" .. (i - 1), ComponentTypeName.Transform).gameObject
    end

    --比牌选择框
    seatHolder.goSelectCompare = GetComponentWithPath(root, "State/Group/SelectCompare", ComponentTypeName.Transform).gameObject
    seatHolder.goCostScore = GetComponentWithPath(root, "State/Group/CostScore", ComponentTypeName.Transform).gameObject
    seatHolder.textCostScore = GetComponentWithPath(seatHolder.goCostScore, "cost/CostText", ComponentTypeName.Text)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goCostScore.gameObject, false)

    seatHolder.goWinScore = GetComponentWithPath(root, "State/Group/WinScore", ComponentTypeName.Transform).gameObject
    seatHolder.textWinScore = GetComponentWithPath(seatHolder.goWinScore, "bg/win/score", "TextWrap")
    seatHolder.textLoseScore = GetComponentWithPath(seatHolder.goWinScore, "bg/lose/score", "TextWrap")

    seatHolder.goNiuPoint = GetComponentWithPath(root, "State/Group/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
    local niuResultUiSwitcher = GetComponentWithPath(root, "State/Group/NiuResult", "UIStateSwitcher")
    seatHolder.imageNiuPoint = GetComponentWithPath(seatHolder.goNiuPoint, "num", ComponentTypeName.Image)
    seatHolder.JinHuaTypeName = GetComponentWithPath(seatHolder.goNiuPoint, "TypeName", ComponentTypeName.Text)

    local handPokerCardsUiSwitcher = ((seatIndex == 2 or seatIndex == 3) and GetComponentWithPath(root, "State/RightHandPokers", "UIStateSwitcher")) or GetComponentWithPath(root, "State/LeftHandPokers", "UIStateSwitcher")
    local handPokerCardsRoot = handPokerRoot or (handPokerCardsUiSwitcher.gameObject)

    --弃牌贴图
    seatHolder.StateDrop = GetComponentWithPath(handPokerCardsRoot, "StateRoot/StateDrop", ComponentTypeName.Transform).gameObject
    seatHolder.StateHasCheck = GetComponentWithPath(handPokerCardsRoot, "StateRoot/StateHasCheck", ComponentTypeName.Transform).gameObject
    seatHolder.StateCompareFail = GetComponentWithPath(handPokerCardsRoot, "StateRoot/StateCompareFail", ComponentTypeName.Transform).gameObject
    
    seatHolder.handPokerCardsRoot = handPokerCardsRoot
    seatHolder.inHandCardsOriginalPos = handPokerCardsRoot.transform.position
    
    local inhandCardsArray = {}
    for i=1,self.PokerCount do
        local pokerCard = GetComponentWithPath(handPokerCardsRoot, "Poker" .. i .. "/Poker", ComponentTypeName.Transform).gameObject 
        local imageLightFrame = GetComponentWithPath(pokerCard, "LightFrame", ComponentTypeName.Image) 
        local cardHolder = {}
        cardHolder.cardRoot = pokerCard   
        cardHolder.imageLightFrame = imageLightFrame   
        cardHolder.cardPosition = pokerCard.transform.position  
        cardHolder.cardLocalPosition = pokerCard.transform.localPosition
        cardHolder.cardLocalScale = pokerCard.transform.localScale        
        self:initCardHolder(cardHolder, pokerAssetHolder)
        inhandCardsArray[i] = cardHolder
    end
    seatHolder.handPokerCardsRoot = handPokerCardsRoot


    seatHolder.seatPosTran = seatPosTran 
    seatHolder.goNiuNiuEffect = goNiuNiuEffect

    if(handPokerRoot)then
        seatHolder.handPokerCardsUiSwitcher = nil
    else
        seatHolder.handPokerCardsUiSwitcher = handPokerCardsUiSwitcher
    end

    if(seatIndex == 4 or seatIndex == 5 or seatIndex == 6)then
        seatHolder.switchNiuResult = function(hasNiu)
            if(hasNiu)then
                niuResultUiSwitcher:SwitchState("Left_Has_Niu")
            else
                niuResultUiSwitcher:SwitchState("Normal")
            end
        end
    elseif(seatIndex == 2 or seatIndex == 3)then
        seatHolder.switchNiuResult = function(hasNiu)
            if(hasNiu)then
                niuResultUiSwitcher:SwitchState("Right_Has_Niu")
            else
                niuResultUiSwitcher:SwitchState("Normal")
            end
        end
    else
        seatHolder.switchNiuResult = function(hasNiu)
        end
    end
    seatHolder.inhandCardsArray = inhandCardsArray

    --TODO XLQ:亲友圈快速组局踢人
    seatHolder.KickBtn = GetComponentWithPath(root, "State/Group/KickBtn", ComponentTypeName.Button)
end

function TableHelper:initCardHolder(cardHolder, pokerAssetHolder)
    local root = cardHolder.cardRoot
    local face =  GetComponentWithPath(root, "face", ComponentTypeName.Image)
    local back =  GetComponentWithPath(root, "back", ComponentTypeName.Image)
    cardHolder.face = face
    cardHolder.back = back
    cardHolder.pokerAssetHolder = pokerAssetHolder
end

--设置手牌顶点颜色
function TableHelper:setInHandCardsMaskColor(seatHolder, mask)
    for i=1,self.PokerCount do
       local cardHolder = seatHolder.inhandCardsArray[i]   
       self:setPokerMaskColor(cardHolder, mask)
    end
end

function TableHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim)
    local cardCount = #inHandPokerList
    if(seatHolder.handPokerCardsUiSwitcher)then
        seatHolder.handPokerCardsUiSwitcher:SwitchState("Normal")
    end

    for i=1,self.PokerCount do        
        local cardHolder = seatHolder.inhandCardsArray[i]        
        if(i <= cardCount) then 
            self:setCardInfo(cardHolder, inHandPokerList[i])
            if(useAnim)then
                self:playCardTurnAnim(cardHolder, showFace, 0.1, (i - 1) * 0.1, function()
                        
                end)
            else
                if(showFace)then
                    self:showCardFace(cardHolder)          
                else
                    self:showCardBack(cardHolder)        
                end
            end
            
            self:showCard(cardHolder, true)
        else
            self:showCard(cardHolder, false)
        end
        
    end
end

function TableHelper:containsPoker(list, t)
    for i=1,#list do
        if(list[i] == t)then
            return true
        end
    end
    return false
end

function TableHelper:playCardTurnAnim(cardHolder, toFace, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
    if(toFace)then
        self:showCardBack(cardHolder)
    else
        self:showCardFace(cardHolder)
    end
    
    sequence:Append(cardHolder.cardRoot.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime):OnComplete(function()
        if(toFace)then
            self:showCardFace(cardHolder)
        else
            self:showCardBack(cardHolder)
        end 
    end))
    sequence:Append(cardHolder.cardRoot.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end

function TableHelper:playCardFlyToPosAnim(cardHolder, targetPos, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOMove(targetPos, duration, false):SetDelay(delayTime))    
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end

function TableHelper:playCardScaleAnim(cardHolder, targetScale, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOScaleX(targetScale, duration):SetDelay(delayTime))    
    sequence:Join(cardHolder.cardRoot.transform:DOScaleY(targetScale, duration))    
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end


--显示牛几
function TableHelper:showNiuName(seatHolder, show, niuName)    
    -- ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuPoint.transform.parent.gameObject, show)     
    -- if(not show) then
    --     return
    -- end
    -- local hasNiu = self:checkHasNiuFromNiuName(niuName)
    -- seatHolder.switchNiuResult(hasNiu)
    -- local  sprite = seatHolder.niuPointAssetHolder:FindSpriteByName(self:getImageNameFromNiuName(niuName))    
    -- seatHolder.imageNiuPoint.sprite = sprite
    -- seatHolder.imageNiuPoint:SetNativeSize()

    -- local sequence = self.module:create_sequence();

    -- sequence:Append(seatHolder.goNiuPoint.transform:DOScaleX(1, 0.0))
    -- sequence:Join(seatHolder.goNiuPoint.transform:DOScaleY(1, 0.0))
    -- sequence:Append(seatHolder.goNiuPoint.transform:DOScaleX(1.5, 0.3))
    -- sequence:Join(seatHolder.goNiuPoint.transform:DOScaleY(1.5, 0.3))
    -- sequence:Append(seatHolder.goNiuPoint.transform:DOScaleX(1, 0.3))
    -- sequence:Join(seatHolder.goNiuPoint.transform:DOScaleY(1, 0.3))
    -- sequence:OnComplete(function()
        
    -- end)
end

function TableHelper:showZhaJinHuaName(seatHolder, show, ZhajinHuaName,hasZhaJinHua,TypeNameShowStr)
    --print("====showZhaJinHuaName=",ZhajinHuaName,hasZhaJinHua)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuPoint.transform.gameObject, show)     
    if(not show) then
        return
    end
    --local  sprite = seatHolder.zhajinhuaAssetHolder:FindSpriteByName(ZhajinHuaName)
    --seatHolder.imageNiuPoint.sprite = sprite
    --seatHolder.imageNiuPoint:SetNativeSize()
    seatHolder.JinHuaTypeName.text = TypeNameShowStr
end


function TableHelper:setInHandPokersOriginalPos(seatHolder)
    seatHolder.handPokerCardsRoot.transform.position = seatHolder.inHandCardsOriginalPos
end


--刷新座位相关信息
function TableHelper:refreshSeatInfo(seatHolder, seatData)    
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)    
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, seatData.isBanker)
        local isShow_imageCreator = tonumber(seatData.playerId) == tonumber(self.modelData.curTableData.roomInfo.owner) and not self.modelData.curTableData.roomInfo.IsHideCreatorIcon
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject,isShow_imageCreator)

        -- --print("seatData", seatData.playerId, seatData.isOffline)
        self:refreshSeatOfflineState(seatHolder, seatData)

        --print(self.modelData.roleData.RoomType,"---------refreshSeatInfo---------------seatData.playerId:",seatData. cur_game_loop_cnt,
        --self.modelData.curTableData.roomInfo.owner,self.modelData.curTableData.roomInfo.mySeatInfo.playerId,seatData.playerId)
        --TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
        if self.modelData.roleData.RoomType == 2 then
            if  seatData.isOffline == false then
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,
                tonumber(seatData. cur_game_loop_cnt) == 0
                and tonumber(self.modelData.curTableData.roomInfo.owner) == tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
                and tonumber(seatData.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
                )
            else
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,tonumber(seatData. cur_game_loop_cnt) == 0)
            end

        end

        seatHolder.textScore.text = seatData.score
        seatHolder.GoldCount.text = Util.filterPlayerGoldNum(seatData.coinBalance)
        if (seatData.playerInfo and seatData.playerInfo.userId) then
            self:setPlayerInfo(seatHolder, seatData.playerInfo)        
        else
            self:get_userinfo(seatData.playerId, function(err, data)
                --{"data":{"breakRate":"0%","cards":99999979,"coins":50,"gender":1,"hasBind":false,
                --"headImg":"http://www.th7.cn/d/file/p/2016/09/12/f7ef1bbfe2db9d1913e8e8c22ffc7619.jpg",
                --"lostCount":0,"nickname":"TestUser111","score":0,"tieCount":0,"winCount":0},"ret":0}

                if(err)then
                    --self:refreshSeatInfo(seatHolder, seatData)
                    return
                end

                local playerInfo = seatData.playerInfo or {}
                playerInfo.playerId = seatData.playerId
                playerInfo.userId = data.userId
		        playerInfo.playerName = data.nickname
                playerInfo.nickname = data.nickname
		        playerInfo.headUrl = data.headImg
                playerInfo.headImg = data.headImg
                playerInfo.gender = data.gender
                playerInfo.score = data.score
                playerInfo.lostCount = data.lostCount
                playerInfo.winCount = data.winCount
                playerInfo.tieCount = data.tieCount
                playerInfo.breakRate = data.breakRate
                playerInfo.gold = data.gold
                playerInfo.ip = data.ip
                seatData.playerInfo = playerInfo
                self:setPlayerInfo(seatHolder, seatData.playerInfo)
            end);
        end
        
    else        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, false)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, true)

        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, false)
    end
end

function TableHelper:refreshSeatOfflineState(seatHolder, seatData)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageDisconnect.gameObject, seatData.isOffline)   
    if(seatData.isOffline)then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTemporaryLeave.gameObject, false) 
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTemporaryLeave.gameObject, seatData.isTempLeave or false) 
    end

    -- self.modelData.roleData.RoomType == 0 --0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
    --TODO XLQ 快速组局 离线玩家显示踢人按钮---
    if self.modelData.roleData.RoomType == 2 and tonumber(seatData. cur_game_loop_cnt) == 0 then
        if tonumber(self.modelData.curTableData.roomInfo.owner) == tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
        and tonumber(seatData.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, seatData.isOffline)
        end


    end
end


function TableHelper:showSeatWinScoreCurRound(seatHolder, show, score)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goWinScore, show)
    if(not show)then
        return
    end
    if (score >= 0)then
        seatHolder.textWinScore.text = "+" .. score
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textWinScore.transform.parent.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textLoseScore.transform.parent.gameObject, false)
    else
        seatHolder.textLoseScore.text = score .. ""
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textWinScore.transform.parent.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textLoseScore.transform.parent.gameObject, true)
    end
end


--显示或隐藏说话icon
function TableHelper:showSpeakIcon(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSpeakIcon, show) 
end

--显示下注按钮
function TableHelper:setBetScore(seatHolder, seatData, show)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate1.gameObject, show and (not seatData.isBanker) and seatData.betScore == 1)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate2.gameObject, show and (not seatData.isBanker) and seatData.betScore == 2)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate3.gameObject, show and (not seatData.isBanker) and seatData.betScore == 3)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate4.gameObject, show and (not seatData.isBanker) and seatData.betScore == 4)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate5.gameObject, show and (not seatData.isBanker) and seatData.betScore == 5)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate10.gameObject, show and (not seatData.isBanker) and seatData.betScore == 10)
end

--填写玩家信息
function TableHelper:setPlayerInfo(seatHolder, playerInfo)
    if(playerInfo.playerId ~= 0)then
        if(playerInfo.hasDownHead)then
            return
        end
        playerInfo.textPlayerName = seatHolder.textPlayerName
        playerInfo.imagePlayerHead = seatHolder.imagePlayerHead
        seatHolder.textPlayerName.text = Util.filterPlayerName(playerInfo.playerName)
        ModuleCache.TextureCacheManager:startDownLoadHeadIcon(playerInfo.headUrl,function (HeadIcon)
            playerInfo.spriteHeadImage = HeadIcon
            seatHolder.imagePlayerHead.sprite = playerInfo.spriteHeadImage
        end)
    else
        seatHolder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
    
end

--设置牌的顶点颜色
function TableHelper:setPokerMaskColor(cardHolder, mask)
    if(not mask)then
        cardHolder.face.color = normalColor
        cardHolder.back.color = normalColor
    else
        cardHolder.face.color = maskColor
        cardHolder.back.color = maskColor
    end
end

--设置牌的数据
function TableHelper:setCardInfo(cardHolder, poker)
    cardHolder.poker = poker
    local  sprite = cardHolder.pokerAssetHolder:FindSpriteByName(poker.PokerSpriteName)    
    cardHolder.face.sprite = sprite
end

--显示或隐藏牌
function TableHelper:showCard(cardHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot, show)
end

--显示牌正面
function TableHelper:showCardFace(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, false)
end
--显示牌背面
function TableHelper:showCardBack(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, true)
end

function TableHelper:NumberToPokerTable(pokerNum,isRealData)
    local poker = {}
    poker.isRealData = isRealData
    poker.PokerNum = pokerNum

    local colorStr
    local temp = CardCommon.ResolveCardIdx(pokerNum)
    if(temp.color == 1) then 
        colorStr = "fangkuai"
    elseif (temp.color == 2) then
        colorStr = "meihua"
    elseif (temp.color == 3) then
        colorStr = "hongtao"
    elseif (temp.color == 4) then
        colorStr = "heitao"
    end
    poker.name = temp.name
    poker.color = colorStr
    poker.PokerSpriteName = colorStr .. "_" .. temp.name
    poker.colorInt = temp.color
    return poker
end

------扑克图片名到数字:例如输入meihua_11返回43
function TableHelper:PokerSpriteNameToNumber(spriteName)
    local res = -1
    local temp = string.split(spriteName,"_")
    if(temp == nil or #temp ~= 2 ) then
        return res
    end

    local colorStr = temp[1]
    local nameStr = temp[2]

    local colorInt
    local nameInt = tonumber(nameStr)
    if(colorStr == "heitao") then
        colorInt = 4
    elseif(colorStr == "hongtao") then
        colorInt = 3
    elseif(colorStr == "meihua") then
        colorInt = 2
    elseif(colorStr == "fangkuai") then
        colorInt = 1
    end

    res = CardCommon.FormatCardIndex(nameInt,colorInt)
    return res
end

function TableHelper:getImageNameFromNiuName(niuName)
    ----print(niuName)
    return niuName
end


function TableHelper:getSoundNameFromNiuName(niuName)
    local headStr = "cow_"
    if(niuName == "boom")then
        return headStr .. "11"
    elseif(niuName == "goldcow")then
        return headStr .. "10"
    elseif(niuName == "samll")then
        return headStr .. "13"
    elseif(niuName == "straight")then
        return headStr .. "14"
    elseif(niuName == "silvercow")then
        return headStr .. "10"
    else
        local cow = "cow"
        local startIndex, endIndex= string.find(niuName, cow)	
	    if (startIndex == 1) then
            return string.gsub(niuName, cow, headStr)            
        end
    end
    return ""
end

function TableHelper:checkHasNiuFromNiuName(niuName)
    if(niuName == "boom")then
        return false
    elseif(niuName == "goldcow")then
        return true
    elseif(niuName == "samll")then
        return true
    elseif(niuName == "straight")then
        return false
    elseif(niuName == "silvercow")then
        return true
    else
        local cow = "cow"
        local startIndex, endIndex= string.find(niuName, cow)	
	    if (startIndex == 1) then
            return niuName ~= "cow0"        
        end
    end
    return false
end

function TableHelper:getNumberFormPoker(poker)
    if(poker.number == "A") then
        return 1, 1
    elseif (poker.number == "J") then 
        return 10, 11
    elseif (poker.number == "Q") then 
        return 10, 12
    elseif (poker.number == "K") then 
        return 10, 13
    else
        return tonumber(poker.number), tonumber(poker.number)
    end
end

function TableHelper:getColorNumbrFromPoker(poker)
    return poker.colorInt
end

function TableHelper:checkHasNiuFormPokerArray(pokerArray, result)
    result = result or {}
    local len = #pokerArray
    local totalValue = 0
    if(len < 3) then
        result.pokers = {}
        return false
    elseif (len == 3) then        
        for i=1,3 do
            totalValue = totalValue + self:getNumberFormPoker(pokerArray[i])
        end
        local hasNiu = totalValue == 10 or totalValue == 20 or totalValue == 30
        if(hasNiu) then
            result.pokers = pokerArray
            return true
        else
            return false
        end
    end

    for i=1,len - 2 do        
        for j=i+1,len - 1 do
            for k=j+1,len do
                local array = {pokerArray[i], pokerArray[j], pokerArray[k]}
                local tmpResult = {}
                local hasNiu = self:checkHasNiuFormPokerArray(array, tmpResult)                                
                if(hasNiu) then
                    result.pokers = tmpResult.pokers
                    return true
                end
            end
        end
    end
    return false
end

--通过服务器的位置索引获得客户端显示的座位
function TableHelper:getSeatInfoByRemoteSeatIndex(remoteSeatIndex, seatInfoList)	
	for i=1,#seatInfoList do
		if(seatInfoList[i].seatIndex == remoteSeatIndex) then
			return seatInfoList[i]
		end
	end
	return nil
end

--将服务器的做座位索引转换为本地位置索引
function TableHelper:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		return localIndex - seatCount
	else
		return localIndex
	end
end

--判断是否所有入座的玩家都已准备
function TableHelper:checkIsAllReady(seatInfoList)
	local seatedCount = 0       --入座数
    local isAllReady = true
	for i=1,#seatInfoList do        
		if(seatInfoList[i].isSeated) then            
            isAllReady = isAllReady and seatInfoList[i].isReady
			seatedCount = seatedCount + 1
		end
	end	    
	return isAllReady, seatedCount
end

--通过玩家id获取座位信息
function TableHelper:getSeatInfoByPlayerId(playerId, seatInfoList)	
    local tmpPlyaerId = playerId
    if(type(playerId) == 'number')then
        tmpPlyaerId = tostring(playerId)
    end
	for i=1,#seatInfoList do
		if(seatInfoList[i].playerId == tmpPlyaerId) then
			return seatInfoList[i]
		end
	end
	return nil
end

function TableHelper:getSeatedSeatCount(seatInfoList)
	local count = 0    
	for i=1,#seatInfoList do
		if(seatInfoList[i].playerId ~= "0")then
			count = count + 1
		end
	end
	return count
end

function TableHelper:get_userinfo(playerId, callback)             
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = playerId,
        },
        cacheDataKey = "user/info?uid=" .. playerId
    }

    self.module:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end, function(error)
        print(error.error)
        callback(error.error, nil);
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then    --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end)
end

--播放牛名
function TableHelper:playNiuNameSound(niuName, isFemale)
    local soundName = self:getSoundNameFromNiuName(niuName)
    --print(niuName, soundName)
    if(isFemale)then
        soundName = "female_" .. soundName
    else
        soundName = "male_" .. soundName
    end
    ModuleCache.SoundManager.play_sound("zhajinhua", "zhajinhua/sound/table/" .. soundName .. ".bytes", soundName)
end

function TableHelper:playScrmbleBankerSound(scramble, isFemale)
    local soundName = (scramble and "bank1") or "bank0"
    if(isFemale)then
        soundName = "female_" .. soundName
    else
        soundName = "male_" .. soundName
    end
    ModuleCache.SoundManager.play_sound("zhajinhua", "zhajinhua/sound/table/" .. soundName .. ".bytes", soundName)
end




function TableHelper:showNiuNiuEffect(seatHolder, show, duration, stayTime, delayTime, onComplete)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuNiuEffect, show)    
    if(show)then
        duration = duration or 1
        stayTime = stayTime or 3
        delayTime = delayTime or 0
        local sequence = self.module:create_sequence();
        local target = seatHolder.goNiuNiuEffect
        target.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(0,0,0)
        sequence:Append(target.transform:DOScale(1, duration):SetDelay(delayTime))
        sequence:Append(target.transform:DOScale(1, 0):SetDelay(stayTime))
        sequence:Append(target.transform:DOShakePosition(duration, 5, 100, 180, true, false))  --持续时间、振幅、频率、随机性
        sequence:OnComplete(function()
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuNiuEffect, false)    
            if(onComplete)then                
                onComplete()
            end
        end)        
    end
end

function TableHelper:showRoundScoreEffect(seatHolder, localSeatIndex, show, score, duration, delayTime, stayTime, onComplete)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goRoundScore, show)    
    if(show)then
        if (score >= 0)then
            seatHolder.textRoundWinScore.text = "+" .. score
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textRoundWinScore.transform.parent.gameObject, true)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textRoundLoseScore.transform.parent.gameObject, false)
        else
            seatHolder.textRoundLoseScore.text = score .. ""
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textRoundWinScore.transform.parent.gameObject, false)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textRoundLoseScore.transform.parent.gameObject, true)
        end
        duration = duration or 0.5
        stayTime = stayTime or 1
        delayTime = delayTime or 0
        local sequence = self.module:create_sequence();
        local target = seatHolder.goRoundScore
        target.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,-18,0)      
        local targetY = (localSeatIndex == 1 and 99) or 54
        sequence:Append(target.transform:DOLocalMoveY(targetY, duration, false):SetDelay(delayTime))
        sequence:Append(target.transform:DOScale(1, 0):SetDelay(stayTime))        
        sequence:OnComplete(function()
            ModuleCache.ComponentUtil.SafeSetActive(target, false)    
            if(onComplete)then                
                onComplete()
            end
        end)        
    end
end


function TableHelper:showRandomBankerEffect(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animSelectBanker.gameObject, show)    
end


function TableHelper:randomRange(min, max)
    local factor = math.random()
    local offset = max - min
    return min + offset * factor
end

--在指定范围内随机出一个点
function TableHelper:randomPosInRect(rect)
    local leftBottom = rect.leftBottom
    local rightTop = rect.rightTop
    --math.randomseed(os.time())
    local xFactor = math.random()
    local x = leftBottom.x + (rightTop.x - leftBottom.x) * xFactor
    local yFactor = math.random()
    local y = leftBottom.y + (rightTop.y - leftBottom.y) * yFactor
    return x, y
end

--随机设置物体的旋转角度
function TableHelper:setRandomRotation(tran)
    --math.randomseed(os.time())
    local random = math.random(-45,45)
    local localEulerAngles = tran.localEulerAngles
    localEulerAngles.z = random
    tran.localEulerAngles = localEulerAngles
end

--飞到制定位置
function TableHelper:flyToPos(trans, targetPos, duration, delayTime, onFinish)
    duration = duration or 0.2
    delayTime = delayTime or 0
    local sequence = self.module:create_sequence();
    local target = trans
    sequence:Append(target:DOMove(targetPos, duration, false):SetDelay(delayTime):SetEase(DG.Tweening.Ease.OutQuint))
    sequence:OnComplete(function() 
        if(onFinish)then                
            onFinish()
        end
    end)  
end

function TableHelper:goldFlyToGoldHeap(goldList, fromPos, goldHeapRect, duration, delayTime)
    duration = duration or 0.5
    delayTime = delayTime or 0
    local rect = {
		leftBottom = goldHeapRect.tranLeftBottom.position,
		rightTop = goldHeapRect.tranRightTop.position,
	}
	local x, y = self:randomPosInRect(rect)
	local targetPos = ModuleCache.CustomerUtil.ConvertVector3(x, y , 0)
    local offset = (rect.rightTop - rect.leftBottom) * 0.5
    offset.x = offset.y

    local tmpRect = {
        leftBottom = targetPos - offset,
        rightTop = targetPos + offset,
    }

    local minX, minY, maxX, maxY
    if(tmpRect.leftBottom.x < rect.leftBottom.x)then
        minX = rect.leftBottom.x
    else
        minX = tmpRect.leftBottom.x
    end

    if(tmpRect.leftBottom.y < rect.leftBottom.y)then
        minY = rect.leftBottom.y
    else
        minY = tmpRect.leftBottom.y
    end

    if(tmpRect.rightTop.x > rect.rightTop.x)then
        maxX = rect.rightTop.x
    else
        maxX = tmpRect.rightTop.x
    end

    if(tmpRect.rightTop.y > rect.rightTop.y)then
        maxY = rect.rightTop.y
    else
        maxY = tmpRect.rightTop.y
    end

    tmpRect.leftBottom = ModuleCache.CustomerUtil.ConvertVector3(minX, minY , 0)
    tmpRect.rightTop = ModuleCache.CustomerUtil.ConvertVector3(maxX, maxY , 0)

    for i=1,#goldList do
        local gold = goldList[i]
        ModuleCache.TransformUtil.SetX(gold.transform, fromPos.x, false)
	    ModuleCache.TransformUtil.SetY(gold.transform, fromPos.y, false)
        self:setRandomRotation(gold.transform)
        x, y = self:randomPosInRect(tmpRect)
	    local tmpTargetPos = ModuleCache.CustomerUtil.ConvertVector3(x, y , 0)
        local tmpDuration = self:randomRange(duration * 0.8, duration * 1.2)
        self:flyToPos(gold.transform, tmpTargetPos, tmpDuration, delayTime, nil)    
    end
	

end


function TableHelper:goldFlyToSeat(goldList, seatPos, duration, delayTime, autoDestory, onFinish)
    duration = duration or 0.5
    delayTime = delayTime or 0
    table.sort( goldList, function(a,b) 
        local disA = UnityEngine.Vector3.Distance(a.transform.position, seatPos)
        local disB = UnityEngine.Vector3.Distance(b.transform.position, seatPos)
        if(disA < disB)then
            return true
        end
        return false
    end)

    local len = #goldList
    local tmpDelayTime = math.min(0.1, 1 / len)
    for i=1,len do
        local tmpOnFinish = nil
        if(i == len)then
            tmpOnFinish = onFinish
        end
        local gold = goldList[i]
        self:flyToPos(gold.transform, seatPos, duration, delayTime + (i - 1) * tmpDelayTime, function ()
            if(autoDestory)then
                UnityEngine.GameObject.Destroy(gold)
            end
            if(tmpOnFinish)then
                tmpOnFinish()
            end
        end)   
    end

end



------数组里面是否包含了某个值
function TableHelper:IsNumTableContains(_NumTable,_Num)
    if(_NumTable == nil or #_NumTable <= 0 or _Num == nil) then
        return false
    end

    for i=1,#_NumTable do
        if(_NumTable[i] == _Num) then
            return true
        end
    end
    return false
end

function TableHelper:GetSwitchStateBySeatIndex(seatIndex)
    if seatIndex == 1 then
        return "Bottom"
    elseif seatIndex == 4 or seatIndex == 5 or seatIndex == 6 then
        return "Left"
    elseif seatIndex == 2 or seatIndex == 3 then
        return "Right"
    end
end



return TableHelper