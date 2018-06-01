local class = require("lib.middleclass")
--- @class CowBoy_TableHelper
local TableHelper = class('tableModule')
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local Sequence = DG.Tweening.DOTween.Sequence
local ModuleCache = ModuleCache
local UnityEngine = UnityEngine

function TableHelper:initialize(...)

end

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

    local text_goldCoin_betScore_right = GetComponentWithPath(root, "State/Group/GoldCoin_XiaZhu/RightText", ComponentTypeName.Text)
    local text_goldCoin_betScore_left = GetComponentWithPath(root, "State/Group/GoldCoin_XiaZhu/LeftText", ComponentTypeName.Text)

    local animSelectBankerVertical = GetComponentWithPath(root, "Info/EffectVertical", ComponentTypeName.Image)
    seatHolder.animSelectBanker = animSelectBankerVertical
    if seatIndex == 1 then
       uiStateSwitcher:SwitchState("Bottom")
        local animSelectBankerHorizontal = GetComponentWithPath(root, "Info/EffectHorizontal", ComponentTypeName.Image)           
        seatHolder.animSelectBanker = animSelectBankerHorizontal
        seatHolder.text_goldCoin_betScore = text_goldCoin_betScore_right
    elseif seatIndex == 2 or seatIndex == 3 then
       uiStateSwitcher:SwitchState("Left")
        seatHolder.text_goldCoin_betScore = text_goldCoin_betScore_left
    elseif seatIndex == 4 then
       uiStateSwitcher:SwitchState("Left")
        seatHolder.text_goldCoin_betScore = text_goldCoin_betScore_left
    elseif seatIndex == 5 or seatIndex == 6 then        
       uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
        seatHolder.text_goldCoin_betScore = text_goldCoin_betScore_right
    end

    local imagePlayerHead = GetComponentWithPath(root, "Info/Avatar/Mask/Image", ComponentTypeName.Image) 
    local textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)
    local textScore =  GetComponentWithPath(root, "Info/Point/Text", ComponentTypeName.Text)
    local textGoldCoin =  GetComponentWithPath(root, "Info/GoldCoin/Text", ComponentTypeName.Text)
    local imageDisconnect =  GetComponentWithPath(root, "Info/ImageStateDisconnect", ComponentTypeName.Image)
    local imageTemporaryLeave = GetComponentWithPath(root, "Info/ImageStateTemporaryLeave", ComponentTypeName.Image)    --暂时离开
    local imageReady = GetComponentWithPath(root, "State/Group0/ImageReady", ComponentTypeName.Image)
    local imageBetting = GetComponentWithPath(root, "State/Group/ImageText", ComponentTypeName.Image)       --下注中
    local imageComputeDone = GetComponentWithPath(root, "State/Group/ImageDone", ComponentTypeName.Image) 

    local imageBanker = GetComponentWithPath(root, "Info/ImageBanker", ComponentTypeName.Image)
    local animBanker = GetComponentWithPath(root, "Info/EffectBanker", "UIImageAnimation")
        
    local imageCreator = GetComponentWithPath(root, "Info/ImageCreator", ComponentTypeName.Image)    

    for i = 1, 10 do
        seatHolder['imageQiangZhuangBeiShu'..i] = GetComponentWithPath(root, "State/Group/QiangZhuangBeiShu/BeiShu"..i, ComponentTypeName.Image)
    end


    local goSpeakIcon =  GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Image)
    local clockHolder = {

    }

    local emojiGoArray = {}
    for i=1,20 do
        emojiGoArray[i] = GetComponentWithPath(root, "State/Group/ChatFace/" .. (i - 1), ComponentTypeName.Transform).gameObject
    end


    local goNiuPoint = GetComponentWithPath(root, "State/Group/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
    local niuResultUiSwitcher = GetComponentWithPath(root, "State/Group/NiuResult", "UIStateSwitcher")

    local imageNiuPoint = GetComponentWithPath(goNiuPoint, "num", ComponentTypeName.Image)
    local goNiuNiuEffect = GetComponentWithPath(root, "State/Group/NiuNiuEffectHolder/NiuNiuEffect", ComponentTypeName.Transform).gameObject

    local goQiangZhuangBeiShu = GetComponentWithPath(root, "State/Group/TableBubble", ComponentTypeName.Transform).gameObject
    local textQiangZhuangBeiShu = GetComponentWithPath(goQiangZhuangBeiShu, "TextBg/Text", ComponentTypeName.Text)

    local handPokerCardsUiSwitcher = ((seatIndex == 5 or seatIndex == 6) and GetComponentWithPath(root, "State/RightHandPokers", "UIStateSwitcher")) or GetComponentWithPath(root, "State/LeftHandPokers", "UIStateSwitcher")
    local handPokerCardsRoot = handPokerRoot or (handPokerCardsUiSwitcher.gameObject)

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

    seatHolder.goQiangZhuangBeiShu = goQiangZhuangBeiShu
    seatHolder.textQiangZhuangBeiShu = textQiangZhuangBeiShu


    seatHolder.goSpeakIcon = goSpeakIcon
    seatHolder.goSeatInfo = goSeatInfo
    seatHolder.buttonNotSeatDown = buttonNotSeatDown
    seatHolder.seatPosTran = seatPosTran 
    seatHolder.seatRoot = goSeat

    seatHolder.imagePlayerHead = imagePlayerHead
    seatHolder.textPlayerName = textPlayerName
    seatHolder.textScore = textScore
    seatHolder.textGoldCoin = textGoldCoin
    seatHolder.imageDisconnect = imageDisconnect
    seatHolder.imageTemporaryLeave = imageTemporaryLeave

    seatHolder.imageBanker = imageBanker
    seatHolder.animBanker = animBanker

    seatHolder.imageCreator = imageCreator

    seatHolder.imageReady = imageReady
    seatHolder.imageBetting = imageBetting
    seatHolder.imageComputeDone = imageComputeDone
    seatHolder.clockHolder = clockHolder

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

    if(seatIndex == 2 or seatIndex == 3 or seatIndex == 4)then
        seatHolder.switchNiuResult = function(hasNiu)
            if(hasNiu)then
                niuResultUiSwitcher:SwitchState("Left_Has_Niu")
            else
                niuResultUiSwitcher:SwitchState("Normal")
            end
        end
    elseif(seatIndex == 5 or seatIndex == 6)then
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



function TableHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim, isLiangPai)
    local cardCount = #inHandPokerList
    if(seatHolder.handPokerCardsUiSwitcher)then
        seatHolder.handPokerCardsUiSwitcher:SwitchState("Normal")
    end

    if(showFace)then
        if(isLiangPai and seatHolder.handPokerCardsUiSwitcher)then
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

    local startIndex = 1
    local endIndex = 5
    local step = 1
    if(seatHolder.isInRight)then
        startIndex = 5
        endIndex = 1
        step = -1
    end

    local count = 0
    for i=startIndex,endIndex,step do
        count = count + 1
        local cardHolder = seatHolder.inhandCardsArray[i]
        if(count <= cardCount) then
            if(showFace)then
                self:setCardInfo(cardHolder, inHandPokerList[i])
            else
                self:setCardInfo(cardHolder, inHandPokerList[count])
            end

            if(useAnim)then
                self:setTargetFrame(true)
                self:playCardTurnAnim(cardHolder, showFace, 0.1, (count - 1) * 0.1, function()
                    if(count == cardCount)then
                        self:setTargetFrame(false)
                    end
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
    self:setTargetFrame(true)
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end

function TableHelper:playCardFlyToPosAnim(cardHolder, targetPos, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOMove(targetPos, duration, false):SetDelay(delayTime):SetEase(DG.Tweening.Ease.OutQuad))
    self:setTargetFrame(true)  
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end

function TableHelper:playCardScaleAnim(cardHolder, targetScale, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOScaleX(targetScale, duration):SetDelay(delayTime))    
    sequence:Join(cardHolder.cardRoot.transform:DOScaleY(targetScale, duration))   
    self:setTargetFrame(true) 
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end


--显示牛几
function TableHelper:showNiuName(seatHolder, show, niuName)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuPoint.transform.parent.gameObject, show)     
    if(not show) then
        return
    end
    local hasNiu = self:checkHasNiuFromNiuName(niuName)
    seatHolder.switchNiuResult(hasNiu)
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
    self:setTargetFrame(true)
    sequence:OnComplete(function()
        self:setTargetFrame(false)
    end)
end



function TableHelper:setInHandPokersDonePos(seatHolder)
    if(seatHolder.transDonePokersPos)then
        seatHolder.handPokerCardsRoot.transform.position = seatHolder.transDonePokersPos.position
    end    
end

function TableHelper:setInHandPokersOriginalPos(seatHolder)
    seatHolder.handPokerCardsRoot.transform.position = seatHolder.inHandCardsOriginalPos
end


--播放随机选庄动画
function TableHelper:playRandomBankerAnim(seatHolderList, targetSeat, onFinish)
    math.randomseed(os.time())
    local minTimes = math.random(2, 5)
    local sequence = self.module:create_sequence();

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
function TableHelper:refreshSeatInfo(seatHolder, seatData)    
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)    
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, seatData.isBanker)   
        self:showRandomBankerEffect(seatHolder, seatData.isBanker)
        if self.modelData.roleData.RoomType == 2 then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, tonumber(seatData.playerId) == tonumber(self.modelData.curTableData.roomInfo.roomHostID) and (self.modelData.curTableData.roomInfo.curRoundNum == 0))
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, false and seatData.isCreator)
        end

        -- print("seatData", seatData.playerId, seatData.isOffline)
        self:refreshSeatOfflineState(seatHolder, seatData)

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

        seatHolder.textScore.text = seatData.score or ''
        seatHolder.textGoldCoin.text = Util.filterPlayerGoldNum(seatData.gold)
        if (seatData.playerInfo and seatData.playerInfo.userId and seatData.playerInfo.userId..'' == seatData.playerId..'') then
            self:setPlayerInfo(seatHolder, seatData.playerInfo)        
        else
            seatData.playerInfo = nil
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
                playerInfo.ip = data.ip
                playerInfo.lostCount = data.lostCount
                playerInfo.winCount = data.winCount
                playerInfo.tieCount = data.tieCount
                playerInfo.breakRate = data.breakRate
                playerInfo.gold = data.gold
                seatData.playerInfo = playerInfo
                if(seatData.on_get_userinfo_callback_queue)then
                    local cb = seatData.on_get_userinfo_callback_queue:shift()
                    while cb do
                        cb(seatData)
                        cb = seatData.on_get_userinfo_callback_queue:shift()
                    end
                end
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

    -- self.modelData.roleData.RoomType == 0 --0     Cocos Creator 1.8     非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间
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
        self:showReadTag(seatHolder, seatData.isReady and (not seatData.curRound))
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBetting.gameObject, seatData.isReady and seatData.isBetting)
        -- print("seat betting", seatData.playerId, seatData.isBetting)
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageComputeDone.gameObject, seatData.isDoneComputeNiu and (not seatData.isCalculatedResult))
        self:setBetScore(seatHolder, seatData, true)
    else
        self:showReadTag(seatHolder, false)
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBetting.gameObject, false)
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageComputeDone.gameObject, false)
        self:setBetScore(seatHolder, seatData, false)
    end
end

function TableHelper:showSeatWinScoreCurRound(seatHolder, show, score)

end

function TableHelper:refreshClock(seatHolder, show, targetTime, curTime, isDigitalClock)
    local goClock
    local textClock
    goClock = seatHolder.clockHolder.goClock
    textClock = seatHolder.clockHolder.textClock

    ModuleCache.ComponentUtil.SafeSetActive(goClock, show)
    if(not show)then
        return
    end
    local leftSecs = targetTime - curTime
    if(leftSecs < 0) then  leftSecs = 0 end
    textClock.text = leftSecs .. ""

    if(seatHolder.last_left_secs ~= leftSecs and leftSecs == 3)then
        self:playDaoJiShiWarningSound()
    end
    seatHolder.last_left_secs = leftSecs
end

--显示或隐藏说话icon
function TableHelper:showSpeakIcon(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSpeakIcon, show) 
end

--显示下注按钮
function TableHelper:setBetScore(seatHolder, seatData, show)
    show = show or false
    show = show and seatData.betScore ~= 0
    seatHolder.text_goldCoin_betScore.text = 'x' .. (seatData.betScore or 0)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.text_goldCoin_betScore.transform.parent.gameObject, show and (not seatData.isBanker))
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.text_goldCoin_betScore.gameObject, show and (not seatData.isBanker))
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
    if(self:isGuangDong() or self:isGoldCoinRoom())then    --广东棋牌
        if(niuName == 'goldcow')then
            if(self:isGuangDongProvince())then
                return 'wuhuaniu'
            end
        elseif(niuName == 'silvercow')then
            if(self:isGuangDongProvince())then
                return 'cow10'
            end
        end
    end
    return niuName
end


function TableHelper:getSoundNameFromNiuName(niuName)
    local headStr = "cow_"
    if(niuName == "boom")then
        return headStr .. "11"
    elseif(niuName == "goldcow")then
        if(self:isGuangDong() or self:isGoldCoinRoom())then    --广东棋牌
            return headStr .. '12'      --五花牛
        end
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
    print(niuName, soundName)
    if(isFemale)then
        soundName = "female_" .. soundName
    else
        soundName = "male_" .. soundName
    end
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/table/" .. soundName .. ".bytes", soundName)
end

function TableHelper:playFaPaiSound()
    local soundName = 'fapai'
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/table/" .. soundName .. ".bytes", soundName)
end

function TableHelper:playDaoJiShiWarningSound()
    local soundName = 'b_daojishi'
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
        self:setTargetFrame(true)
        sequence:OnComplete(function()
            self:setTargetFrame(false)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuNiuEffect, false)    
            if(onComplete)then                
                onComplete()
            end
        end)        
    end
end


function TableHelper:showRoundScoreEffect(seatHolder, localSeatIndex, show, score, duration, delayTime, stayTime, onComplete, stillShow)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goGoldCoinRoundScore, show)
    if(show)then
        if (score >= 0)then
            seatHolder.textGoldCoinRoundWinScore.text = "+" .. score
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textGoldCoinRoundWinScore.transform.parent.gameObject, true)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textGoldCoinRoundLoseScore.transform.parent.gameObject, false)
        else
            seatHolder.textGoldCoinRoundLoseScore.text = score .. ""
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textGoldCoinRoundWinScore.transform.parent.gameObject, false)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textGoldCoinRoundLoseScore.transform.parent.gameObject, true)
        end
        duration = duration or 0.5
        stayTime = stayTime or 2
        delayTime = delayTime or 0

        local sequence = self.module:create_sequence();
        local target = seatHolder.goGoldCoinRoundScore
        target.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,-18,0)
        local targetY = (localSeatIndex == 1 and 99) or 63
        sequence:Append(target.transform:DOLocalMoveY(targetY, duration, false):SetDelay(delayTime))
        sequence:Append(target.transform:DOScale(1, 0):SetDelay(stayTime))
        self:setTargetFrame(true)
        sequence:OnComplete(function()
            self:setTargetFrame(false)
            if(not stillShow)then
                ModuleCache.ComponentUtil.SafeSetActive(target, false)
            end
            if(onComplete)then
                onComplete()
            end
        end)
    end
end


function TableHelper:showRandomBankerEffect(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.animSelectBanker.gameObject, show)    
end

--显示抢庄标签
function TableHelper:showQiangZhuangTag(seatHolder, show, scramble)

end

--显示抢庄倍数标签
function TableHelper:showQiangZhuangBeiShuBubble(seatHolder, show, beiShu)
     ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goQiangZhuangBeiShu, show or false)  
     if(show)then
         if(not beiShu or beiShu < 1)then
             seatHolder.textQiangZhuangBeiShu.text = '不抢'
         else
             seatHolder.textQiangZhuangBeiShu.text = beiShu .. '倍'
         end
     end
end

function TableHelper:showQiangZhuangBeiShuTag(seatHolder, show, beiShu)
    for i = 1, 10 do
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder['imageQiangZhuangBeiShu'..i].gameObject, show and beiShu == i)
    end
end

function TableHelper:showReadTag(seatHolder, show)
    if(not seatHolder.goReadyTag)then
        seatHolder.goReadyTag = ModuleCache.ComponentUtil.InstantiateLocal(seatHolder.goQiangZhuangBeiShu, seatHolder.goQiangZhuangBeiShu.transform.parent.gameObject)
        seatHolder.textReadyTag = GetComponentWithPath(seatHolder.goReadyTag, "TextBg/Text", ComponentTypeName.Text)
        seatHolder.textReadyTag.text = '准备'
    end
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goReadyTag, show or false)
end

function TableHelper:formatRuleDesc(rule)
    local desc = ""
    local ruleTable = ModuleCache.Json.decode(rule)    
    desc = string.format( "%d局,%d人",ruleTable.roundCount, ruleTable.playerCount)
    if(ruleTable.isBigBet == 1)then
        desc = desc .. ",大倍场"
    elseif(ruleTable.isBigBet == 0)then
        desc = desc .. ",小倍场"
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

function TableHelper:setTargetFrame(anim)
    -- local targetFrameRate = (anim and 60) or 30
    UnityEngine.Application.targetFrameRate = (anim and 60) or ModuleCache.AppData.tableTargetFrameRate
end

function TableHelper:isGuangDong(ruleTable)
    ruleTable = ruleTable or self.ruleTable
    if(ruleTable and ruleTable.isGuangDongMode)then
        return true
    end
    return AppData.App_Name == 'DHGDQP'
end

function TableHelper:isGuangDongProvince()
    return AppData.App_Name == 'DHGDQP'
end

function TableHelper:isGoldCoinRoom()
    if(self.modelData.tableCommonData.isGoldTable)then
        return true
    end
    return false
end

--显示座位上的金币数
function TableHelper:showSeatGoldCoin(seatHolder, show)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textGoldCoin.transform.parent.gameObject, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textScore.transform.parent.gameObject, not show)
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

function TableHelper:randomPosByOffset(center, offset)
    local pos = center
    local xFactor = math.random()
    pos.x = pos.x + offset * (1 - xFactor * 2)
    local yFactor = math.random()
    pos.y = pos.y + offset * (1 - yFactor * 2)
    return pos
end

--随机设置物体的旋转角度
function TableHelper:setRandomRotation(tran)
    --math.randomseed(os.time())
    local random = math.random()
    local localEulerAngles = tran.localEulerAngles
    localEulerAngles.z = random * 360
    tran.localEulerAngles = localEulerAngles
end

--飞到制定位置
function TableHelper:flyToPos(trans, targetPos, duration, delayTime, onFinish)
    duration = duration or 0.5
    delayTime = delayTime or 0

    local target = trans
    ModuleCache.ComponentUtil.SafeSetActive(trans.gameObject, false)
    self.module:subscibe_time_event(delayTime, false, 0):OnComplete( function(t)
        ModuleCache.ComponentUtil.SafeSetActive(trans.gameObject, true)
        local sequence = self.module:create_sequence();
        sequence:Append(target:DOMove(targetPos, duration, false):SetEase(DG.Tweening.Ease.OutQuint))
        sequence:OnComplete(function()
            if(onFinish)then
                onFinish()
            end
        end)
    end)

    --sequence:Append(target:DOMove(targetPos, duration, false):SetDelay(delayTime):SetEase(DG.Tweening.Ease.OutQuint))
    --sequence:OnStart(function()
    --    ModuleCache.ComponentUtil.SafeSetActive(trans.gameObject, true)
    --end)
    --sequence:OnComplete(function()
    --    if(onFinish)then
    --        onFinish()
    --    end
    --end)
end

function TableHelper:genGold(originalGo, parentGo, localPos, needRandomRotation, randomOffset, active)
    local gold = ModuleCache.ComponentUtil.InstantiateLocal(originalGo, parentGo)
    local pos = localPos
    if(randomOffset)then
        gold.transform.localPosition = self:randomPosByOffset(localPos, 10)
    end
    if(needRandomRotation)then
        self:setRandomRotation(gold.transform)
    end
    ModuleCache.ComponentUtil.SafeSetActive(gold, active or false)
    return gold
end

function TableHelper:goldFlyToSeat(goldList, seatPos, duration, delayTime, delayTime2, autoDestory, onFinish)
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
    local tmpDelayTime = delayTime2
    for i=1,len do
        local tmpOnFinish = nil
        if(i == len)then
            tmpOnFinish = onFinish
        end
        local gold = goldList[i]
        self:flyToPos(gold.transform, seatPos, duration, delayTime + (i - 1) * tmpDelayTime, function ()
            if(autoDestory)then
                if(gold)then
                    UnityEngine.GameObject.Destroy(gold)
                end
            end
            if(tmpOnFinish)then
                tmpOnFinish()
            end
        end)
    end

end

return TableHelper