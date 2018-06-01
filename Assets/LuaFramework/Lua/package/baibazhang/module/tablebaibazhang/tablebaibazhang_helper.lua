
local TableBaiBaZhangHelper = {}
local ModuleCache = ModuleCache
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local Sequence = DG.Tweening.DOTween.Sequence

function TableBaiBaZhangHelper:setSeatPlayerInfo(seatHolder, playerInfo)

end

function TableBaiBaZhangHelper:initDealTable(root)
    self.inhandPokers = {}
    self.matching = {};
    self.animMatching = {};
    TableBaiBaZhangHelper:initInHandPokers(root);
    for i = 1, 3 do
        TableBaiBaZhangHelper:initMatching(root,i);
    end
    TableBaiBaZhangHelper:initAnimMatching(root);
end

function TableBaiBaZhangHelper:initInHandPokers(root)
    for i = 1,9 do
        local pokerCard = GetComponentWithPath(root, "DealWin/pockers/" .. i-1 .. "/poker", ComponentTypeName.Transform).gameObject   
        local cardHolder = {}
        cardHolder.cardRoot = pokerCard      
        cardHolder.cardPosition = pokerCard.transform.position  
        cardHolder.cardLocalPosition = pokerCard.transform.localPosition
        cardHolder.cardLocalScale = pokerCard.transform.localScale        
        --self:initCardHolder(cardHolder, pokerAssetHolder)
        self.inhandPokers[i] = cardHolder
    end
end

function TableBaiBaZhangHelper:initMatching(root,index)
    self.matching[index] = {};
    local path;
    if(index == 1) then
        path = "DealWin/Matching/first/pokersOnMatch/";
    elseif(index == 2) then
        path = "DealWin/Matching/second/pokersOnMatch/";
    elseif(index == 3) then
        path = "DealWin/Matching/third/pokersOnMatch/";
    end
    local maxIndex = 3;
    if(index == 1) then
        maxIndex = 2;
    end
    for i = 1,maxIndex do
        local pokerCard = GetComponentWithPath(root, path..i-1, ComponentTypeName.Transform).gameObject   
        local cardHolder = {}
        cardHolder.cardRoot = pokerCard      
        cardHolder.cardPosition = pokerCard.transform.position  
        cardHolder.cardLocalPosition = pokerCard.transform.localPosition
        cardHolder.cardLocalScale = pokerCard.transform.localScale
        self.matching[index][i] = cardHolder;
    end
end

function TableBaiBaZhangHelper:initAnimMatching(root)
    for i = 1,3 do
        local path = "DealWin/Matching/Panel/pokers"..i;
        local pokerCard = GetComponentWithPath(root, path, ComponentTypeName.Transform).gameObject   
        local cardHolder = {}
        cardHolder.cardRoot = pokerCard      
        cardHolder.cardPosition = pokerCard.transform.position  
        cardHolder.cardLocalPosition = pokerCard.transform.localPosition
        cardHolder.cardLocalScale = pokerCard.transform.localScale
        self.animMatching[i] = cardHolder;
    end    
end

function TableBaiBaZhangHelper:initSeatHolder(seatHolder, seatIndex, goSeat, handPokerRoot)
    local root = goSeat
    local pokerAssetHolder = seatHolder.pokerAssetHolder

    local buttonNotSeatDown = GetComponentWithPath(root, "NotSeatDown", ComponentTypeName.Button)        
    local goSeatInfo = GetComponentWithPath(root, "Info", ComponentTypeName.Transform).gameObject  
    local goIsReady = GetComponentWithPath(root, "State/Group/ImageReady", ComponentTypeName.Transform).gameObject                   
    local uiStateSwitcher = ModuleCache.ComponentManager.GetComponent(root,"UIStateSwitcher")
    ModuleCache.TransformUtil.SetX(uiStateSwitcher.transform, 0, true)
    ModuleCache.TransformUtil.SetY(uiStateSwitcher.transform, 0, true)    

    local animSelectBankerVertical = GetComponentWithPath(root, "Info/EffectVertical", "UIImageAnimation")
    seatHolder.animSelectBanker = animSelectBankerVertical
    if seatIndex == 1 then
       uiStateSwitcher:SwitchState("Bottom")
        local animSelectBankerHorizontal = GetComponentWithPath(root, "Info/EffectHorizontal", "UIImageAnimation")           
        seatHolder.animSelectBanker = animSelectBankerHorizontal
    elseif seatIndex == 2 then
       uiStateSwitcher:SwitchState("MiddleRight")
    elseif seatIndex == 3 then
        uiStateSwitcher:SwitchState("Right")
    elseif seatIndex == 4 then
       uiStateSwitcher:SwitchState("Left")
    elseif seatIndex == 5 then
       uiStateSwitcher:SwitchState("MiddleLeft")
    elseif seatIndex == 6 then        
       uiStateSwitcher:SwitchState("Left")
       seatHolder.isInRight = true
    end

    local imagePlayerHead = GetComponentWithPath(root, "Info/Avatar/Mask/Image", ComponentTypeName.Image) 
    local textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)
    local textScore =  GetComponentWithPath(root, "Info/Point/Text", ComponentTypeName.Text)
    local imageDisconnect =  GetComponentWithPath(root, "Info/ImageStateDisconnect", ComponentTypeName.Image)
    local imageReady = GetComponentWithPath(root, "State/Group/ImageReady", ComponentTypeName.Image)
    local imageBetting = GetComponentWithPath(root, "State/Group/ImageText", ComponentTypeName.Image)       --下注中
    local imageComputeDone = GetComponentWithPath(root, "State/Group/ImageDone", ComponentTypeName.Image) 
    
    local imageBanker = GetComponentWithPath(root, "Info/ImageBanker", ComponentTypeName.Image)
    local animBanker = GetComponentWithPath(root, "Info/EffectBanker", "UIImageAnimation")
        
    local imageCreator = GetComponentWithPath(root, "Info/ImageCreator", ComponentTypeName.Image)    
    local imageTemporaryLeave = GetComponentWithPath(root,"Info/ImageExit",ComponentTypeName.Image);
    local buttonKick = GetComponentWithPath(root,"Info/ButtonKick",ComponentTypeName.Button);

    local imageScoreRate1 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple1", ComponentTypeName.Image)
    local imageScoreRate2 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple2", ComponentTypeName.Image)
    local imageScoreRate3 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple3", ComponentTypeName.Image)
    local imageScoreRate4 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple4", ComponentTypeName.Image)
    local imageScoreRate5 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple5", ComponentTypeName.Image)
    local imageScoreRate10 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple10", ComponentTypeName.Image)

    local goWinScore = GetComponentWithPath(root, "State/Group/WinScore", ComponentTypeName.Transform).gameObject
    local textWinScore = GetComponentWithPath(goWinScore, "bg/win/score", "TextWrap")
    local textLoseScore = GetComponentWithPath(goWinScore, "bg/lose/score", "TextWrap")

    local goRoundScore = GetComponentWithPath(root, "State/Group/RoundScoreAnim/bg", ComponentTypeName.Transform).gameObject
    local textRoundWinScore = GetComponentWithPath(goRoundScore, "win/score", "TextWrap")
    local textRoundLoseScore = GetComponentWithPath(goRoundScore, "lose/score", "TextWrap")

    local goSpeakIcon =  GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Image)
    local goClock = GetComponentWithPath(root, "State/Group/Clock", ComponentTypeName.Transform).gameObject
    local textClock = GetComponentWithPath(goClock, "Text", "TextWrap")
    local clockHolder = {
        goClock = goClock,
        textClock = textClock
    }

    local emojiGoArray = {}
    for i=1,4 do
        emojiGoArray[i] = GetComponentWithPath(root, "State/Group/ChatFace/" .. i, ComponentTypeName.Transform).gameObject
    end


    local goNiuPoint = GetComponentWithPath(root, "State/Group/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
    local imageNiuPoint = GetComponentWithPath(goNiuPoint, "num", ComponentTypeName.Image)
    local goNiuNiuEffect = GetComponentWithPath(root, "State/Group/NiuNiuEffectHolder/NiuNiuEffect", ComponentTypeName.Transform).gameObject

    local handPokerCardsRoot = handPokerRoot or (((seatIndex == 5 or seatIndex == 6) and GetComponentWithPath(root, "State/RightHandPokers", ComponentTypeName.Transform).gameObject) or GetComponentWithPath(root, "State/LeftHandPokers", ComponentTypeName.Transform).gameObject)

    seatHolder.inHandCardsOriginalPos = handPokerCardsRoot.transform.position
    
    local inhandCardsArray = {}
    for i=1,5 do
        local pokerCard = GetComponentWithPath(handPokerCardsRoot, "Poker" .. i .. "/Poker", ComponentTypeName.Transform).gameObject        
        local cardHolder = {}
        cardHolder.cardRoot = pokerCard      
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

    seatHolder.goSpeakIcon = goSpeakIcon
    seatHolder.goIsReady = goIsReady
    seatHolder.goSeatInfo = goSeatInfo
    seatHolder.buttonNotSeatDown = buttonNotSeatDown
    seatHolder.seatPosTran = seatPosTran 
    seatHolder.seatRoot = goSeat

    seatHolder.imagePlayerHead = imagePlayerHead
    seatHolder.textPlayerName = textPlayerName
    seatHolder.textScore = textScore
    seatHolder.imageDisconnect = imageDisconnect

    seatHolder.imageBanker = imageBanker
    seatHolder.animBanker = animBanker
    seatHolder.buttonKick = buttonKick
    seatHolder.imageCreator = imageCreator
    seatHolder.imageTemporaryLeave = imageTemporaryLeave
    seatHolder.imageReady = imageReady
    seatHolder.imageBetting = imageBetting
    seatHolder.imageComputeDone = imageComputeDone
    seatHolder.clockHolder = clockHolder

    seatHolder.emojiGoArray = emojiGoArray

    --已选择的倍数
    seatHolder.imageScoreRate1 = imageScoreRate1
    seatHolder.imageScoreRate2 = imageScoreRate2
    seatHolder.imageScoreRate3 = imageScoreRate3
    seatHolder.imageScoreRate4 = imageScoreRate4
    seatHolder.imageScoreRate5 = imageScoreRate5
    seatHolder.imageScoreRate10 = imageScoreRate10

    --牛的点数
    seatHolder.goNiuPoint = goNiuPoint
    seatHolder.imageNiuPoint = imageNiuPoint
    seatHolder.goNiuNiuEffect = goNiuNiuEffect

    seatHolder.handPokerCardsRoot = handPokerCardsRoot
    seatHolder.inhandCardsArray = inhandCardsArray
end

function TableBaiBaZhangHelper:initCardHolder(cardHolder, pokerAssetHolder)
    local root = cardHolder.cardRoot
    local face =  GetComponentWithPath(root, "face", ComponentTypeName.Image)
    local back =  GetComponentWithPath(root, "back", ComponentTypeName.Image)
    cardHolder.face = face
    cardHolder.back = back
    cardHolder.pokerAssetHolder = pokerAssetHolder
end

function TableBaiBaZhangHelper:PlayAnimHandToMatch(handIndex,matchIndex,detailIndex,onFinishInvoke)
    local cardHolder = self.inhandPokers[handIndex];
    cardHolder.cardRoot.transform.localPosition = UnityEngine.Vector3.zero;
    cardHolder.cardRoot.transform.parent.gameObject:SetActive(false);
    cardHolder.cardRoot.transform.localScale = UnityEngine.Vector3.one;
    if(onFinishInvoke) then
        onFinishInvoke();
    end
    --暂时不要播放动画
    --self:playCardFlyToPosAnim(cardHolder, match[detailIndex].cardPosition, duration, 0, nil)
    --self:playCardScaleAnim(cardHolder, targetScale, duration, 0, onFinish)
end

function TableBaiBaZhangHelper:PlayAnimMatchToMatch(srcIndex,desIndex,onFinish)
    local duration = 0.5;
    local cardHolder = self.animMatching[srcIndex];
        local position = cardHolder.cardRoot.transform.localPosition;
        local onFinishInvoke = function ()
            cardHolder.cardRoot.transform.localPosition = position;
            if(onFinish) then
                onFinish();
            end
        end       
        self:playCardFlyToPosAnim(cardHolder, self.animMatching[desIndex].cardPosition, duration, 0, onFinishInvoke)
end


function TableBaiBaZhangHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim)
    local cardCount = #inHandPokerList
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

function TableBaiBaZhangHelper:playCardTurnAnim(cardHolder, toFace, duration, delayTime, onFinish)
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

function TableBaiBaZhangHelper:playCardFlyToPosAnim(cardHolder, targetPos, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOMove(targetPos, duration, false):SetDelay(delayTime))    
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end

function TableBaiBaZhangHelper:playCardScaleAnim(cardHolder, targetScale, duration, delayTime, onFinish)
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
function TableBaiBaZhangHelper:showNiuName(seatHolder, show, niuName)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuPoint.transform.parent.gameObject, show)     
    if(not show) then
        return
    end
    local  sprite = seatHolder.niuPointAssetHolder:FindSpriteByName(self:getImageNameFromNiuName(niuName))    
    seatHolder.imageNiuPoint.sprite = sprite
    seatHolder.imageNiuPoint:SetNativeSize()

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



function TableBaiBaZhangHelper:setInHandPokersDonePos(seatHolder)
    if(seatHolder.transDonePokersPos)then
        seatHolder.handPokerCardsRoot.transform.position = seatHolder.transDonePokersPos.position
    end    
end

function TableBaiBaZhangHelper:setInHandPokersOriginalPos(seatHolder)
    seatHolder.handPokerCardsRoot.transform.position = seatHolder.inHandCardsOriginalPos
end


--播放随机选庄动画
function TableBaiBaZhangHelper:playRandomBankerAnim(seatHolderList, targetSeat, onFinish)
    math.randomseed(os.time())
    local minTimes = math.random(2, 5)
    local sequence = self.module:create_sequence();

end

--播放设置庄家动画
function TableBaiBaZhangHelper:playSetTargetSeatAsBanker(seatHolder, onFinish)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animBanker.gameObject, true) 
    seatHolder.animBanker:Play(0)
    seatHolder.animBanker:RegistMovieEvent(12, function (frame)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animBanker.gameObject, false) 
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, true) 
    end, true)

    --[[
    local sequence = self.module:create_sequence();
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, true) 
    local oldParent = seatHolder.imageBanker.transform.parent
    local oldPos = seatHolder.imageBanker.transform.position
    ModuleCache.ComponentUtil.SetParent(seatHolder.imageBanker.gameObject, seatHolder.goTmpBankerPos)
    ModuleCache.TransformUtil.SetX(seatHolder.imageBanker.transform, 0, true)
    ModuleCache.TransformUtil.SetY(seatHolder.imageBanker.transform, 0, true)  
    sequence:Append(seatHolder.imageBanker.transform:DOMove(oldPos, 0.8, false))
    sequence:OnComplete(function()
        ModuleCache.ComponentUtil.SetParent(seatHolder.imageBanker.gameObject, oldParent.gameObject)
        ModuleCache.TransformUtil.SetX(seatHolder.imageBanker.transform, oldPos.x, false)
        ModuleCache.TransformUtil.SetY(seatHolder.imageBanker.transform, oldPos.y, false) 
        if(onFinish)then
            onFinish()
        end 
    end)
    --]]
end

--刷新座位相关信息
function TableBaiBaZhangHelper:refreshSeatInfo(seatHolder, seatData)    
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)    
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, seatData.isBanker)    
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, seatData.isCreator)
        if(not seatData.isOffline) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTemporaryLeave.gameObject, seatData.isTemporaryLeave)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTemporaryLeave.gameObject, false)
        end
        --快速组局不显示踢人
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonKick.gameObject, seatData.canBeKicked and self.modelData.roleData.RoomType ~= 2 )
        -- print("seatData", seatData.playerId, seatData.isOffline)
        self:refreshSeatOfflineState(seatHolder, seatData)
        seatHolder.textScore.text = seatData.curScore
        if (seatData.playerInfo and seatData.playerInfo.userId) then
            self:setPlayerInfo(seatHolder, seatData.playerInfo)        
        else
            self:get_userinfo(seatData.playerId, function(err, data)
                --{"data":{"breakRate":"0%","cards":99999979,"coins":50,"gender":1,"hasBind":false,
                --"headImg":"http://www.th7.cn/d/file/p/2016/09/12/f7ef1bbfe2db9d1913e8e8c22ffc7619.jpg",
                --"lostCount":0,"nickname":"TestUser111","score":0,"tieCount":0,"winCount":0},"ret":0}

                if(err)then
                    self:refreshSeatInfo(seatHolder, seatData)
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

                if(seatData.chatDataSeatHolder)then
                    seatData.chatDataSeatHolder.playerInfo = playerInfo
                end
                self:setPlayerInfo(seatHolder, seatData.playerInfo)
            end);
        end
        
    else        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, false)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)                
                
    end
end

function TableBaiBaZhangHelper:refreshSeatOfflineState(seatHolder, seatData)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageDisconnect.gameObject, seatData.isOffline)
    if(seatData.isOffline) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTemporaryLeave.gameObject, false);
    end
end

--刷新座位的状态
function TableBaiBaZhangHelper:refreshSeatState(seatHolder, seatData)
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, seatData.isReady and (not seatData.curRound))    
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBetting.gameObject, seatData.isBetting)
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageComputeDone.gameObject, seatData.isDoneComputeNiu and (not seatData.isCalculatedResult))
        --self:setBetScore(seatHolder, seatData, true)
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, false)    
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBetting.gameObject, false)
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageComputeDone.gameObject, false)
        --self:setBetScore(seatHolder, seatData, false)
    end
end

function TableBaiBaZhangHelper:showSeatWinScoreCurRound(seatHolder, show, score)
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

function TableBaiBaZhangHelper:refreshClock(seatHolder, show, targetTime, curTime)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.clockHolder.goClock, show)
    if(not show)then
        return
    end
    local leftSecs = targetTime - curTime
    if(leftSecs < 0) then  leftSecs = 0 end
    seatHolder.clockHolder.textClock.text = leftSecs .. ""
end

--显示或隐藏说话icon
function TableBaiBaZhangHelper:showSpeakIcon(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSpeakIcon, show) 
end

--显示下注按钮
function TableBaiBaZhangHelper:setBetScore(seatHolder, seatData, show)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate1.gameObject, show and (not seatData.isBanker) and seatData.betScore == 1)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate2.gameObject, show and (not seatData.isBanker) and seatData.betScore == 2)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate3.gameObject, show and (not seatData.isBanker) and seatData.betScore == 3)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate4.gameObject, show and (not seatData.isBanker) and seatData.betScore == 4)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate5.gameObject, show and (not seatData.isBanker) and seatData.betScore == 5)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate10.gameObject, show and (not seatData.isBanker) and seatData.betScore == 10)
end

--填写玩家信息
function TableBaiBaZhangHelper:setPlayerInfo(seatHolder, playerData)
    if(playerData.playerId ~= 0)then
        if(playerData.hasDownHead)then
            return
        end
        seatHolder.textPlayerName.text = Util.filterPlayerName(playerData.playerName)
        self:startDownLoadHeadIcon(seatHolder.imagePlayerHead, playerData.headUrl, function (sprite )
            playerData.spriteHeadImage = sprite
        end)
    else
        seatHolder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
    
end



--下载头像
function TableBaiBaZhangHelper:startDownLoadHeadIcon(targetImage, url, callback)    
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            print('error down load '.. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if(self)then
                    --self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if(callback)then
                callback(tex)
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end)    
end


--设置牌的数据
function TableBaiBaZhangHelper:setCardInfo(cardHolder, poker)    
    cardHolder.poker = poker
    local  sprite = cardHolder.pokerAssetHolder:FindSpriteByName(self:getImageNameFromPoker(poker))    
    cardHolder.face.sprite = sprite
end

--显示或隐藏牌
function TableBaiBaZhangHelper:showCard(cardHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot, show)
end

--显示牌正面
function TableBaiBaZhangHelper:showCardFace(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, false)
end
--显示牌背面
function TableBaiBaZhangHelper:showCardBack(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, true)
end

--显示或隐藏手牌
function TableBaiBaZhangHelper:showInHandCards(seatHolder, show)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerCardsRoot, show)
end

function TableBaiBaZhangHelper:getImageNameFromPoker(poker)
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

function TableBaiBaZhangHelper:getImageNameFromNiuName(niuName)
    print(niuName)
    return niuName
end


function TableBaiBaZhangHelper:getSoundNameFromNiuName(niuName)
    local headStr = "cow_"
    if(niuName == "boom")then
        return headStr .. "11"
    elseif(niuName == "goldcow")then
        return headStr .. "12"
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

function TableBaiBaZhangHelper:getNumberFormPoker(poker)
    if(poker.number == "A") then
        return 1
    elseif (poker.number == "J") then 
        return 10
    elseif (poker.number == "Q") then 
        return 10
    elseif (poker.number == "K") then 
        return 10
    else
        return tonumber(poker.number)
    end
end

function TableBaiBaZhangHelper:checkHasNiuFormPokerArray(pokerArray, result)
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
function TableBaiBaZhangHelper:getSeatInfoByRemoteSeatIndex(remoteSeatIndex, seatInfoList)	
	for i=1,#seatInfoList do
		if(seatInfoList[i].seatIndex == remoteSeatIndex) then
			return seatInfoList[i]
		end
	end
	return nil
end

--将服务器的做座位索引转换为本地位置索引
function TableBaiBaZhangHelper:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		localIndex = localIndex - seatCount
	else
		
	end
    --print('------------------------------------',seatIndex, localIndex, seatCount, mySeatIndex)
    return localIndex
end

--判断是否所有入座的玩家都已准备
function TableBaiBaZhangHelper:checkIsAllReady(seatInfoList)
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
function TableBaiBaZhangHelper:getSeatInfoByPlayerId(playerId, seatInfoList)	
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

function TableBaiBaZhangHelper:getSeatedSeatCount(seatInfoList)
	local count = 0    
	for i=1,#seatInfoList do
		if(seatInfoList[i].playerId ~= "0")then
			count = count + 1
		end
	end
	return count
end

function TableBaiBaZhangHelper:get_userinfo(playerId, callback)             
    local userID = playerId
    local requestData = {
		params = {
			uid = playerId,
		},
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
	}
    if playerId then
        requestData.cacheDataKey = "httpcache:user/info?uid=" .. (playerId or "0")
    end
    
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
function TableBaiBaZhangHelper:playNiuNameSound(niuName, isFemale)
    local soundName = self:getSoundNameFromNiuName(niuName)
    print(niuName, soundName)
    if(isFemale)then
        soundName = "female_" .. soundName
    else
        soundName = "male_" .. soundName
    end
    ModuleCache.SoundManager.play_sound("biji", "biji/sound/table/" .. soundName .. ".bytes", soundName)
end



function TableBaiBaZhangHelper:showNiuNiuEffect(seatHolder, show, duration, stayTime, delayTime, onComplete)
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

function TableBaiBaZhangHelper:showRoundScoreEffect(seatHolder, localSeatIndex, show, score, duration, delayTime, stayTime, onComplete)
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


function TableBaiBaZhangHelper:showRandomBankerEffect(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animSelectBanker.gameObject, show)    
end


function TableBaiBaZhangHelper:formatRuleDesc(rule)
    local desc = ""
    local ruleTable = ModuleCache.Json.decode(rule)    
    desc = string.format( "%d局,%d人",ruleTable.roundCount, ruleTable.playerCount)
    if(ruleTable.haveJQK == 1)then
        desc = desc .. ",有花牌"
    else
        desc = desc .. ",无花牌"
    end

    if(ruleTable.bankerType == 0)then
        desc = desc .. ",轮流坐庄"
    elseif(ruleTable.bankerType == 1)then
        desc = desc .. ",随机坐庄"
    else
        desc = desc .. ",看牌抢庄"
    end

    if(ruleTable.ruleType == 1)then
        desc = desc .. ",花样玩法"
    end
    return desc
end

return TableBaiBaZhangHelper