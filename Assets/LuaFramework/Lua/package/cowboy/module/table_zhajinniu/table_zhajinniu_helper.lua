local ModuleCache = ModuleCache

---@class TableHelper_ZhaJinNiu
local TableHelper = {}
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local Sequence = DG.Tweening.DOTween.Sequence

local normalColor = UnityEngine.Color.white
local maskColor = UnityEngine.Color(0.3,0.3,0.3,1)
local maskColor1 = UnityEngine.Color(0.6,0.6,0.6,1)

function TableHelper:setSeatPlayerInfo(seatHolder, playerInfo)

end

function TableHelper:initSeatHolder(seatHolder, seatIndex, goSeat, handPokerRoot)
    local root = goSeat
    local pokerAssetHolder = seatHolder.pokerAssetHolder

    local buttonNotSeatDown = GetComponentWithPath(root, "NotSeatDown", ComponentTypeName.Button)        
    local goSeatInfo = GetComponentWithPath(root, "Info", ComponentTypeName.Transform).gameObject                   
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
       uiStateSwitcher:SwitchState("Left")
    elseif seatIndex == 2 or seatIndex == 3 then        
       uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
    end

    local imagePlayerHead = GetComponentWithPath(root, "Info/Avatar/Mask/Image", ComponentTypeName.Image) 
    local textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)
    local textScore =  GetComponentWithPath(root, "Info/Point/Text", ComponentTypeName.Text)
    local imageDisconnect =  GetComponentWithPath(root, "Info/ImageStateDisconnect", ComponentTypeName.Image)
    local imageTemporaryLeave = GetComponentWithPath(root, "Info/ImageStateTemporaryLeave", ComponentTypeName.Image)    --暂时离开
    local goReadyBubble = GetComponentWithPath(root, "State/Group/ReadyBubble", ComponentTypeName.RectTransform).gameObject

    local imageBanker = GetComponentWithPath(root, "Info/ImageBanker", ComponentTypeName.Image)
    local animBanker = GetComponentWithPath(root, "Info/EffectBanker", "UIImageAnimation")
        
    local imageCreator = GetComponentWithPath(root, "Info/ImageCreator", ComponentTypeName.Image)    

    --倒计时框
    local imageTimeLimit = GetComponentWithPath(root, "Info/ImageBackground/Frame", ComponentTypeName.Image)
    local imageTimeLimit_Frame = GetComponentWithPath(root, "Info/ImageBackground/Frame/Frame", ComponentTypeName.Image)

    local goRoundScore = GetComponentWithPath(root, "State/Group/RoundScoreAnim/bg", ComponentTypeName.Transform).gameObject
    local textRoundWinScore = GetComponentWithPath(goRoundScore, "win/score", ComponentTypeName.Text)
    local textRoundLoseScore = GetComponentWithPath(goRoundScore, "lose/score", ComponentTypeName.Text)

    local goSpeakIcon =  GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Image)

    local emojiGoArray = {}
    for i=1,20 do
        emojiGoArray[i] = GetComponentWithPath(root, "State/Group/ChatFace/" .. (i - 1), ComponentTypeName.Transform).gameObject
    end

    --比牌选择框
    local goSelectCompare = GetComponentWithPath(root, "State/Group/SelectCompare", ComponentTypeName.Transform).gameObject

    local goCostScore = GetComponentWithPath(root, "State/Group/CostScore", ComponentTypeName.Transform).gameObject
    local imageCostGold = GetComponentWithPath(goCostScore, "cost/gold", ComponentTypeName.Image)
    local textCostScore = GetComponentWithPath(goCostScore, "cost/Text", ComponentTypeName.Text)



    local goWinScore = GetComponentWithPath(root, "State/Group/WinScore", ComponentTypeName.Transform).gameObject
    local textWinScore = GetComponentWithPath(goWinScore, "bg/win/score", "TextWrap")
    local textLoseScore = GetComponentWithPath(goWinScore, "bg/lose/score", "TextWrap")

    local goNiuPoint
    local niuResultUiSwitcher
    if(seatIndex == 2 or seatIndex == 3)then
        goNiuPoint = GetComponentWithPath(root, "State/RightHandPokers/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
        niuResultUiSwitcher = GetComponentWithPath(root, "State/RightHandPokers/NiuResult", "UIStateSwitcher")
    else
        goNiuPoint = GetComponentWithPath(root, "State/LeftHandPokers/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
        niuResultUiSwitcher = GetComponentWithPath(root, "State/LeftHandPokers/NiuResult", "UIStateSwitcher")
    end

    local imageNiuPoint = GetComponentWithPath(goNiuPoint, "num", ComponentTypeName.Image)

    local handPokerCardsUiSwitcher = ((seatIndex == 2 or seatIndex == 3) and GetComponentWithPath(root, "State/RightHandPokers", "UIStateSwitcher")) or GetComponentWithPath(root, "State/LeftHandPokers", "UIStateSwitcher")
    local handPokerCardsRoot = handPokerRoot or (handPokerCardsUiSwitcher.gameObject)

    --弃牌贴图
    local goDropBubble = GetComponentWithPath(root, "State/Group/DropBubble", ComponentTypeName.RectTransform).gameObject
    local imageHasCheck = GetComponentWithPath(root, "State/Group/ImageHasCheck", ComponentTypeName.Image)
    local goFailBubble = GetComponentWithPath(root, "State/Group/FailBubble", ComponentTypeName.Transform).gameObject
    
    seatHolder.handPokerCardsRoot = handPokerCardsRoot
    seatHolder.inHandCardsOriginalPos = handPokerCardsRoot.transform.position

    seatHolder.goMask = GetComponentWithPath(root, "Info/mask", ComponentTypeName.Transform).gameObject

    seatHolder.goWinAnim = GetComponentWithPath(root, "Info/Anim_Win", ComponentTypeName.Transform).gameObject

    local inhandCardsArray = {}
    for i=1,5 do
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

    
    seatHolder.goWinScore = goWinScore
    seatHolder.textWinScore = textWinScore
    seatHolder.textLoseScore = textLoseScore

    seatHolder.goRoundScore = goRoundScore
    seatHolder.textRoundWinScore = textRoundWinScore
    seatHolder.textRoundLoseScore = textRoundLoseScore

    seatHolder.imageHasCheck = imageHasCheck
    seatHolder.goDropBubble = goDropBubble
    seatHolder.goFailBubble = goFailBubble
    seatHolder.goCostScore = goCostScore
    seatHolder.imageCostGold = imageCostGold
    seatHolder.textCostScore = textCostScore
    seatHolder.goSelectCompare = goSelectCompare
    seatHolder.goSpeakIcon = goSpeakIcon
    seatHolder.goSeatInfo = goSeatInfo
    seatHolder.buttonNotSeatDown = buttonNotSeatDown
    seatHolder.seatPosTran = seatPosTran 
    seatHolder.seatRoot = goSeat

    seatHolder.imagePlayerHead = imagePlayerHead
    seatHolder.textPlayerName = textPlayerName
    seatHolder.textScore = textScore
    seatHolder.imageDisconnect = imageDisconnect
    seatHolder.imageTemporaryLeave = imageTemporaryLeave

    seatHolder.imageBanker = imageBanker
    seatHolder.animBanker = animBanker

    seatHolder.imageCreator = imageCreator
    seatHolder.imageTimeLimit = imageTimeLimit
    seatHolder.imageTimeLimit_Frame = imageTimeLimit_Frame


    seatHolder.goReadyBubble = goReadyBubble

    seatHolder.emojiGoArray = emojiGoArray

    --牛的点数
    seatHolder.goNiuPoint = goNiuPoint
    seatHolder.imageNiuPoint = imageNiuPoint
    seatHolder.goNiuNiuEffect = goNiuNiuEffect

    seatHolder.handPokerCardsRoot = handPokerCardsRoot
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
    for i=1,5 do
       local cardHolder = seatHolder.inhandCardsArray[i]   
       self:setPokerMaskColor(cardHolder, mask)
    end
end

function TableHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim)
    local cardCount = #inHandPokerList
    if(seatHolder.handPokerCardsUiSwitcher)then
        seatHolder.handPokerCardsUiSwitcher:SwitchState("Normal")
    end

    if(showFace)then
        if(seatHolder.handPokerCardsUiSwitcher)then
            local result = {}
            local hasNiu = self:checkHasNiuFormPokerArray(inHandPokerList, result)
            if(hasNiu)then
                table.sort(inHandPokerList, function(a,b) 
                    if(self:containsPoker(result.pokers, a) and (not self:containsPoker(result.pokers, b)))then
                        return true
                    elseif(self:containsPoker(result.pokers, b) and (not self:containsPoker(result.pokers, a)))then
                        return false
                    else
                        local _, aNumber = self:getNumberFormPoker(a)
                        local _, bNumber = self:getNumberFormPoker(b)
                        if(aNumber == bNumber)then
                            return self:getColorNumbrFromPoker(a) > self:getColorNumbrFromPoker(b)
                        else
                            return aNumber > bNumber
                        end
                    end
                end)
            seatHolder.handPokerCardsUiSwitcher:SwitchState("Show_HasNiu")
            end
        end
    end

    for i=1,5 do        
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
function TableHelper:showNiuName(seatHolder, show, niuName, mask)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuPoint.transform.parent.gameObject, show)     
    if(not show) then
        return
    end
    local hasNiu = self:checkHasNiuFromNiuName(niuName)
    seatHolder.switchNiuResult(hasNiu)
    local  sprite = seatHolder.niuPointAssetHolder:FindSpriteByName(self:getImageNameFromNiuName(niuName))    
    seatHolder.imageNiuPoint.sprite = sprite
    seatHolder.imageNiuPoint:SetNativeSize()

    if(mask)then
        seatHolder.imageNiuPoint.color = maskColor1
    else
        seatHolder.imageNiuPoint.color = normalColor
    end

    local sequence = self.module:create_sequence();

    sequence:Append(seatHolder.goNiuPoint.transform:DOScaleX(1, 0.0))
    sequence:Join(seatHolder.goNiuPoint.transform:DOScaleY(1, 0.0))
    sequence:Append(seatHolder.goNiuPoint.transform:DOScaleX(1.5, 0.3))
    sequence:Join(seatHolder.goNiuPoint.transform:DOScaleY(1.5, 0.3))
    sequence:Append(seatHolder.goNiuPoint.transform:DOScaleX(1, 0.3))
    sequence:Join(seatHolder.goNiuPoint.transform:DOScaleY(1, 0.3))
    sequence:OnComplete(function()
        
    end)
end


function TableHelper:setInHandPokersOriginalPos(seatHolder)
    seatHolder.handPokerCardsRoot.transform.position = seatHolder.inHandCardsOriginalPos
end


--播放设置庄家动画
function TableHelper:playSetTargetSeatAsBanker(seatHolder, onFinish)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animBanker.gameObject, true) 
    seatHolder.animBanker:Play(0)
    seatHolder.animBanker:RegistMovieEvent(12, function (frame)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animBanker.gameObject, false) 
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, true) 
        if(onFinish)then
            onFinish()
        end
    end, true)

end

--刷新座位相关信息
function TableHelper:refreshSeatInfo(seatHolder, seatData)    
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)    
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, seatData.isBanker)
        --第一局开始前显示房主标记
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, tonumber(seatData.playerId) == tonumber(self.modelData.curTableData.roomInfo.roomHostID) and (self.modelData.curTableData.roomInfo.curRoundNum == 0))
        -- --print("seatData", seatData.playerId, seatData.isOffline)
        self:refreshSeatOfflineState(seatHolder, seatData)

        --print(seatData.playerId,"-----refreshSeatInfo---------------",self.modelData.curTableData.roomInfo.curRoundNum, self.modelData.curTableData.roomInfo.roomHostID,self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
        --TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
        if self.modelData.roleData.RoomType == 2 then
            if  seatData.isOffline == false then
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,
                tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0
                and tonumber(self.modelData.curTableData.roomInfo.roomHostID) == tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
                and tonumber(seatData.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
                )
            else
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0)
            end

        end

        seatHolder.textScore.text = seatData.score
        if (seatData.playerInfo and seatData.playerInfo.userId and seatData.playerInfo.userId..'' == seatData.playerId..'') then
            self:setPlayerInfo(seatHolder, seatData.playerInfo)        
        else
            seatData.playerInfo = nil
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
                playerInfo.ip = data.ip
                seatData.playerInfo = playerInfo
                self:setPlayerInfo(seatHolder, seatData.playerInfo)
            end);
        end
        
    else        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, false)
        if(seatData.roomInfo and seatData.roomInfo.curRoundNum ~= 0)then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, true)
        end

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
    if self.modelData.roleData.RoomType == 2 and tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0 then

        if tonumber(self.modelData.curTableData.roomInfo.roomHostID) == tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
        and tonumber(seatData.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, seatData.isOffline)
        end

    end
end

--刷新座位的状态
function TableHelper:refreshSeatState(seatHolder, seatData)
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goReadyBubble, seatData.isReady and (not seatData.curRound))
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goReadyBubble, false)
    end
end

--刷新座位看牌、弃牌状态、比牌失败
function TableHelper:refreshSeatPlayState(seatHolder, seatData, clean)
    local roomInfo = seatData.roomInfo
    local mySeatInfo = roomInfo.mySeatInfo
    local isWatchState = (not mySeatInfo.isReady) and(mySeatInfo.betScore == 0) and(roomInfo.state ~= 0)
    if(clean)then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goDropBubble, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageHasCheck.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goFailBubble, false)
        self:showSeatMask(seatHolder, false or isWatchState)
        return
    end
    self:showSeatMask(seatHolder, seatData.zhaJinNiu_state == 3 or seatData.zhaJinNiu_state == 4 or isWatchState)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goDropBubble, seatData.zhaJinNiu_state == 3)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageHasCheck.gameObject, seatData.zhaJinNiu_state == 2)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goFailBubble, seatData.zhaJinNiu_state == 4)
end

function TableHelper:showSeatMask(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goMask, show or false)
end

--显示座位本局下注的总分数
function TableHelper:showSeatCostGold(seatHolder, show, score)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goCostScore, show)
    if(not show)then
        return
    end
    seatHolder.textCostScore.text = score .. ""
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
function TableHelper:setPlayerInfo(seatHolder, playerData)
    if(playerData.playerId ~= 0)then
        if(playerData.hasDownHead)then
            return
        end
        playerData.textPlayerName = seatHolder.textPlayerName
        playerData.imagePlayerHead = seatHolder.imagePlayerHead
        seatHolder.textPlayerName.text = Util.filterPlayerName(playerData.playerName)
        self:startDownLoadHeadIcon(seatHolder.imagePlayerHead, playerData.headUrl)
    else
        seatHolder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
    
end



--下载头像
function TableHelper:startDownLoadHeadIcon(targetImage, url)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            print('error down load '.. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if(self)then
                    --self:startDownLoadHeadIcon(targetImage, url)
                end
            end
        else
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
            if targetImage then
                targetImage.sprite = tex
            end
        end
    end)    
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
    local  sprite = cardHolder.pokerAssetHolder:FindSpriteByName(self:getImageNameFromPoker(poker))    
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

--显示或隐藏手牌
function TableHelper:showInHandCards(seatHolder, show)    
    if(show and seatHolder.handPokerCardsUiSwitcher)then
        seatHolder.handPokerCardsUiSwitcher:SwitchState("Normal")
    end
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerCardsRoot, show)
end




function TableHelper:getImageNameFromPoker(poker)
    --S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
    local colorStr
    if(poker.colour == "S") then
        colorStr = "heitao"
    elseif (poker.colour == "H") then 
        colorStr = "hongtao"
    elseif (poker.colour == "C") then 
        colorStr = "meihua"
    elseif (poker.colour == "D") then 
        colorStr = "fangkuai"
    end

    local numberStr
    if(poker.number == "A") then
        numberStr = "1"
    elseif (poker.number == "J") then 
        numberStr = "11"
    elseif (poker.number == "Q") then 
        numberStr = "12"
    elseif (poker.number == "K") then 
        numberStr = "13"
    else
        numberStr = poker.number
    end
    local spriteName = colorStr .. "_" .. numberStr
    return spriteName
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
    --S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
    if(poker.colour == "S") then
        return 4
    elseif (poker.colour == "H") then 
        return 3
    elseif (poker.colour == "C") then 
        return 2
    elseif (poker.colour == "D") then 
        return 1
    end
    return 0
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
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/table/" .. soundName .. ".bytes", soundName)
end

function TableHelper:playScrmbleBankerSound(scramble, isFemale)
    local soundName = (scramble and "bank1") or "bank0"
    if(isFemale)then
        soundName = "female_" .. soundName
    else
        soundName = "male_" .. soundName
    end
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/table/" .. soundName .. ".bytes", soundName)
end

function TableHelper:playResultSound(play, win)    
    local soundName = (win and "gamewin") or "gamelost"
    if(play)then
        ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/table/" .. soundName .. ".bytes", soundName)
    else
        ModuleCache.SoundManager.stop_sound("cowboy", "cowboy/sound/table/" .. soundName .. ".bytes", soundName)
    end
    
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
        stayTime = stayTime or 2
        delayTime = delayTime or 0
        local sequence = self.module:create_sequence();
        local target = seatHolder.goRoundScore
        target.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,-18,0)      
        local targetY = (localSeatIndex == 1 and 50.8) or 78.29
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
    local random = math.random(-45, 45)
    local localEulerAngles = tran.localEulerAngles
    localEulerAngles.z = random
    tran.localEulerAngles = localEulerAngles
end

--飞到制定位置
function TableHelper:flyToPos(trans, targetPos, duration, delayTime, onFinish)
    duration = duration or 0.5
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



return TableHelper