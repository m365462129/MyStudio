local BranchPackageName = AppData.BranchRunfastName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local Sequence = DG.Tweening.DOTween.Sequence
local CardCommon = require(string.format("package/%s/module/tablerunfast/gamelogic_common",BranchPackageName))
---@class TableRunfastHelper
local TableRunfastHelper = {}
local ModuleCache = ModuleCache
TableRunfastHelper.pokerSlotMaxCount = 16 --跑得快最多16张牌
TableRunfastHelper.seatMaxCount = 4 --最多几个人玩
TableRunfastHelper.PokerStyleTypeKey = "RunfastPokerStyleType"

------初始化座位持有者:seatHolder座位持有者,seatIndex座位下标,goSeat座位对象,handPokerRoot扑克节点
function TableRunfastHelper:initSeatHolder(seatHolder, seatIndex, goSeat, handPokerRoot)
    local root = goSeat
    seatHolder.seatRoot = goSeat
    seatHolder.NotSeatRoot = GetComponentWithPath(root, "NotSeatRoot", ComponentTypeName.Transform).gameObject--没有人座位下的状态
    seatHolder.NotSeatRootUIStateSwitcher = GetComponentWithPath(root,"NotSeatRoot", "UIStateSwitcher")
    seatHolder.goSeatInfo = GetComponentWithPath(root, "Info", ComponentTypeName.Transform).gameObject--座位上玩家的信息
    seatHolder.HeadSelected =  GetComponentWithPath(root, "Info/HeadBg/HeadSelected", ComponentTypeName.Transform).gameObject--座位上玩家的信息
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.HeadSelected,false)
    seatHolder.AvatarUIStateSwitcher = GetComponentWithPath(root,"Info/HeadBg/Avatar", "UIStateSwitcher")
    
    --ui状态切换
    local uiStateSwitcher = ModuleCache.ComponentManager.GetComponent(root,"UIStateSwitcher")
    ModuleCache.TransformUtil.SetX(uiStateSwitcher.transform, 0, true)
    ModuleCache.TransformUtil.SetY(uiStateSwitcher.transform, 0, true)
    if(seatIndex == 1) then
        uiStateSwitcher:SwitchState("Bottom")
    elseif(seatIndex == 2) then
        uiStateSwitcher:SwitchState("Right")
    elseif(seatIndex == 3) then
        uiStateSwitcher:SwitchState("Left")
        seatHolder.isInRight = true
    end

    seatHolder.CurrencyUIStateSwitcher = GetComponentWithPath(root, "Info/CurrencyRoot", "UIStateSwitcher")
    seatHolder.Warning = GetComponentWithPath(root, "State/Group/Warning", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.Warning,false)
    seatHolder.RemainPokerRoot = GetComponentWithPath(root, "State/Group/RemainPokerRoot", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerRoot,false)
    seatHolder.RemainPokerInHand = GetComponentWithPath(root, "State/Group/RemainPokerRoot/RemainPokerInHand", ComponentTypeName.Text)--手上剩余的牌的数量
    seatHolder.NotAffordEffectRootOld = GetComponentWithPath(root, "State/Group/NotAffordEffect", ComponentTypeName.Transform).gameObject--要不起的效果
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotAffordEffectRootOld,false)
    seatHolder.NotAffordEffectRoot = GetComponentWithPath(root, "State/Group/NotAfford/NotAffordImage", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotAffordEffectRoot,false)
    seatHolder.KickBtn = GetComponentWithPath(root, "State/Group/KickBtn", ComponentTypeName.Button)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject,false)

    seatHolder.ZhaDanEffectRoot = GetComponentWithPath(root, "Info/HeadBg/ZhaDanEffectRoot", ComponentTypeName.Transform).gameObject
    seatHolder.ZhaDanEffectPread = GetComponentWithPath(seatHolder.ZhaDanEffectRoot.gameObject, "ZhaDanEffectPread", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.ZhaDanEffectPread,false)
    seatHolder.ZhaDanEffectMoveRoot = GetComponentWithPath(seatHolder.ZhaDanEffectRoot.gameObject, "ZhaDanEffectScore/MoveRoot", ComponentTypeName.Transform).gameObject

    seatHolder.ThirdSeatShow = GetComponentWithPath(root, "ThirdSeatShow", ComponentTypeName.Transform).gameObject
    seatHolder.ThirdSeatShowText = GetComponentWithPath(root, "ThirdSeatShow/Text", ComponentTypeName.Text)
    seatHolder.imagePlayerHead = GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/Image", ComponentTypeName.Image)--玩家头像
    seatHolder.textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)--玩家名字
    seatHolder.textPlayerId = GetComponentWithPath(root, "Info/PlayerId", ComponentTypeName.Text)
    seatHolder.textScore =  GetComponentWithPath(root, "Info/CurrencyRoot/Point/Text", ComponentTypeName.Text)--货币数量
    seatHolder.GoldCount = GetComponentWithPath(root, "Info/CurrencyRoot/Gold/Count", ComponentTypeName.Text)--货币数量
    seatHolder.imageDisconnect =  GetComponentWithPath(root, "Info/HeadBg/Avatar/Mask/ImageStateDisconnect", ComponentTypeName.Image)--断线
    seatHolder.imageReady = GetComponentWithPath(root, "State/Group/ImageReady", ComponentTypeName.Image)--已经准备
    seatHolder.imageBanker = GetComponentWithPath(root, "Info/ImageBanker", ComponentTypeName.Image)--庄家
    seatHolder.imageCreator = GetComponentWithPath(root, "Info/ImageCreator", ComponentTypeName.Image)--房主
    seatHolder.imageScoreRate1 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple1", ComponentTypeName.Image)
    seatHolder.imageScoreRate2 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple2", ComponentTypeName.Image)
    seatHolder.imageScoreRate3 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple3", ComponentTypeName.Image)
    seatHolder.imageScoreRate4 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple4", ComponentTypeName.Image)
    seatHolder.imageScoreRate5 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple5", ComponentTypeName.Image)
    seatHolder.imageScoreRate10 = GetComponentWithPath(root, "State/Group/ScoreRate/ImageScoreMultiple10", ComponentTypeName.Image) 
    seatHolder.goWinScore = GetComponentWithPath(root, "State/Group/WinScore", ComponentTypeName.Transform).gameObject
    seatHolder.textWinScore = GetComponentWithPath(seatHolder.goWinScore, "bg/win/score", "TextWrap")
    seatHolder.textLoseScore = GetComponentWithPath(seatHolder.goWinScore, "bg/lose/score", "TextWrap")
    seatHolder.goRoundScore = GetComponentWithPath(root, "State/Group/RoundScoreAnim/bg", ComponentTypeName.Transform).gameObject
    seatHolder.textRoundWinScore = GetComponentWithPath(seatHolder.goRoundScore, "win/score", "TextWrap")
    seatHolder.textRoundLoseScore = GetComponentWithPath(seatHolder.goRoundScore, "lose/score", "TextWrap")
    seatHolder.RechargeGoldRoot = GetComponentWithPath(root,"Info/HeadBg/RechargeGoldRoot",ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RechargeGoldRoot.gameObject,false)
    --说话
    seatHolder.goSpeakIcon =  GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Image)
    local locGoClock = GetComponentWithPath(root, "State/Group/Clock", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(locGoClock,false)
    seatHolder.clockHolder = 
    {
        goClock = locGoClock,
        textClock = GetComponentWithPath(locGoClock, "Text", "TextWrap")
    }

    --表情
    seatHolder.emojiGoArray = {}
    for i=0,19 do
        seatHolder.emojiGoArray[i] = GetComponentWithPath(root, "State/Group/ChatFace/" .. i, ComponentTypeName.Transform).gameObject
    end

    --牌
    seatHolder.handPokerCardsRoot = handPokerRoot --or (((seatIndex == 5 or seatIndex == 6) and GetComponentWithPath(root, "State/RightHandPokers", ComponentTypeName.Transform).gameObject) or GetComponentWithPath(root, "State/LeftHandPokers", ComponentTypeName.Transform).gameObject)
    if(seatHolder.handPokerCardsRoot == nil) then
        local locPath
        if(seatIndex == 2) then
            locPath = "State/RightHandPokers"
        elseif(seatIndex == 3) then
            locPath = "State/LeftHandPokers"
        elseif(seatIndex == 4) then
            locPath = "State/TopHandPokers"
        end
        seatHolder.handPokerCardsRoot = GetComponentWithPath(root, locPath, ComponentTypeName.Transform).gameObject

        seatHolder.handPokerRoot = GetComponentWithPath(seatHolder.handPokerCardsRoot, "PokerRoot/GridLayoutGroup", ComponentTypeName.Transform).gameObject
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerRoot, false)
        seatHolder.handPokerPrefab = GetComponentWithPath(seatHolder.handPokerCardsRoot, "PokerRoot/GridLayoutGroup/PokerPrefab", ComponentTypeName.Transform).gameObject
        seatHolder.handPokerSlotTable = {}
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerPrefab, false)
        for i=1,self.pokerSlotMaxCount do
            local tPoker = ModuleCache.ComponentUtil.InstantiateLocal(seatHolder.handPokerPrefab, seatHolder.handPokerRoot)
            tPoker.name = "Poker"..tostring(i)
            ModuleCache.ComponentUtil.SafeSetActive(tPoker, true)
            table.insert(seatHolder.handPokerSlotTable,tPoker)
        end

        seatHolder.ThrowPokerGridLayoutGroup = GetComponentWithPath(seatHolder.handPokerCardsRoot, "ThrowPokerRoot/GridLayoutGroup", ComponentTypeName.Transform).gameObject
        seatHolder.otherThrowPokerPrefab = GetComponentWithPath(seatHolder.handPokerCardsRoot, "ThrowPokerRoot/GridLayoutGroup/ThrowPokerPrefab", ComponentTypeName.Transform).gameObject
        seatHolder.otherThrowPokerSlotTable = {}
        self:InstantiateOtherThrowPokerSlot(seatHolder.otherThrowPokerPrefab,seatHolder.ThrowPokerGridLayoutGroup,seatHolder.otherThrowPokerSlotTable)
    end

    seatHolder.inHandCardsOriginalPos = seatHolder.handPokerCardsRoot.transform.position
    seatHolder.inhandCardsArray = {}
    local pokerSlotMaxCount = self.pokerSlotMaxCount
    for i=1,pokerSlotMaxCount do
        local pokerCard     
        if(seatIndex == 1) then
            pokerCard = GetComponentWithPath(seatHolder.handPokerCardsRoot, "Poker" .. i .. "/Poker", ComponentTypeName.Transform).gameObject 
        else
            pokerCard = GetComponentWithPath(seatHolder.handPokerCardsRoot, "PokerRoot/GridLayoutGroup/Poker" .. i, ComponentTypeName.Transform).gameObject 
        end

        local cardHolder = {}
        cardHolder.cardRoot = pokerCard      
        cardHolder.cardPosition = pokerCard.transform.position  
        cardHolder.cardLocalPosition = pokerCard.transform.localPosition
        cardHolder.cardLocalScale = pokerCard.transform.localScale        
        self:initCardHolder(cardHolder)
        seatHolder.inhandCardsArray[i] = cardHolder
    end

    local effectPath = "Effect/"
    seatHolder.EffectType = {}
    seatHolder.EffectType.Effect_Feiji = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Feiji"), ComponentTypeName.Transform).gameObject
    seatHolder.EffectType.Effect_Liandui = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Liandui"), ComponentTypeName.Transform).gameObject
    seatHolder.EffectType.Effect_Quanguan = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Quanguan"), ComponentTypeName.Transform).gameObject
    seatHolder.EffectType.Effect_Sandaier = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Sandaier"), ComponentTypeName.Transform).gameObject
    seatHolder.EffectType.Effect_Sandaiyi = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Sandaiyi"), ComponentTypeName.Transform).gameObject
    seatHolder.EffectType.Effect_Shunzi = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Shunzi"), ComponentTypeName.Transform).gameObject
    seatHolder.EffectType.Effect_Zhadan = GetComponentWithPath(root, (effectPath.."Ainm_Paixing_Zhadan"), ComponentTypeName.Transform).gameObject
end


------初始化扑克牌:cardHolder扑克牌的信息
function TableRunfastHelper:initCardHolder(cardHolder)
    local root = cardHolder.cardRoot
    cardHolder.face = GetComponentWithPath(root, "face", ComponentTypeName.Image)
    cardHolder.back = GetComponentWithPath(root, "back", ComponentTypeName.Image)
    cardHolder.GradientColor = GetComponentWithPath(root, "face", "UiEffect.GradientColor")
end

function TableRunfastHelper:initCardHolder2(PokerSlot,sprite)
     local  locImage = GetComponentWithPath(PokerSlot.gameObject, "face", ComponentTypeName.Image)
     locImage.sprite = sprite
end

------刷新手中的牌:
function TableRunfastHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim)
    local cardCount = #inHandPokerList--手中牌的数量
    local pokerSlotCount = #seatHolder.inhandCardsArray--牌槽的数量
    for i=1,pokerSlotCount do
        local cardHolder = seatHolder.inhandCardsArray[i]--牌槽
        if(i <= cardCount) then
            self:setCardInfo(cardHolder, inHandPokerList[i])--将数据放到牌槽中
            --判断是否有发牌动画
            local isHaveFaPaiAnim = false
            if(self.modelData.curTableData.roomInfo.isNewRound) then
                if(self.modelData.curTableData.roomInfo.isNewRoundAlreadyFaPai == nil 
                or self.modelData.curTableData.roomInfo.isNewRoundAlreadyFaPai == false)then
                    isHaveFaPaiAnim = true
                end
            end
            --if(self.modelData.curTableData.roomInfo.is_deal)
            if(not self.modelData.curTableData.roomInfo.is_deal) then--发牌动画
                self.module:subscibe_time_event(i*0.05, false, 0):OnComplete(function(t)
                    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot.transform.parent.transform.gameObject,true)
                    ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/table/dealpoker.bytes", "dealpoker")
                end)
            else
                ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot.transform.parent.transform.gameObject,true)
            end
            --self:showCard(cardHolder, true)
            if(useAnim)then
               self:playCardTurnAnim(cardHolder, showFace, 0.1, (i - 1) * 0.1, function() end)
            else
                if(showFace)then
                    self:showCardFace(cardHolder)          
                else
                    self:showCardBack(cardHolder)        
                end
            end
        else
            --self:showCard(cardHolder, false)
            ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot.transform.parent.transform.gameObject,false)
            cardHolder.isThrowed = true
            cardHolder.isHide = true
        end
    end

    if(self.modelData.curTableData.roomInfo.isNewRound) then
        self.module:subscibe_time_event(2, false, 0):OnComplete(function(t)
            self.modelData.curTableData.roomInfo.isNewRound = false
            self.modelData.curTableData.roomInfo.isNewRoundAlreadyFaPai = true
        end)
    end
end

--刷新别人手上的牌
function TableRunfastHelper:refreshInHandCardsForOthers(seatInfo)
    local localSeatIndex = seatInfo.localSeatIndex
    local seatHolder = self.TableRunfastView.seatHolderArray[localSeatIndex]
    local pokerSlotCount = #seatHolder.inhandCardsArray
    for i=1,pokerSlotCount do   
        local cardHolder = seatHolder.inhandCardsArray[i]
        if(i <= #seatInfo.inHandPokerList) then
            local locPoker = seatInfo.inHandPokerList[i]
            if(locPoker ~= nil and cardHolder~=nil) then
                cardHolder.poker = cardHolder  
                cardHolder.face.sprite = self:GetPokerSprite(locPoker.PokerNum)
            end
            ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot.transform.gameObject,true) 
        else
            ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot.transform.gameObject,false)   
        end
    end
end

function TableRunfastHelper:playCardTurnAnim(cardHolder, toFace, duration, delayTime, onFinish)
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

------播放纸牌转的动画
function TableRunfastHelper:playCardTurnAnim(cardHolder, toFace, duration, delayTime, onFinish)
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

------播放纸牌飞的动画:cardHolder纸牌,targetPos目标位置,duration飞的时间,delayTime延迟时间,onFinish结束后的回调
function TableRunfastHelper:playCardFlyToPosAnim(cardHolder, targetPos, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOMove(targetPos, duration, false):SetDelay(delayTime))    
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end

------播放纸牌缩放的动画
function TableRunfastHelper:playCardScaleAnim(cardHolder, targetScale, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOScaleX(targetScale, duration):SetDelay(delayTime))    
    sequence:Join(cardHolder.cardRoot.transform:DOScaleY(targetScale, duration))    
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end


function TableRunfastHelper:playCardScaleAnim(cardHolder, targetScale, duration, delayTime, onFinish)
    local sequence = self.module:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOScaleX(targetScale, duration):SetDelay(delayTime))    
    sequence:Join(cardHolder.cardRoot.transform:DOScaleY(targetScale, duration))    
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end


function TableRunfastHelper:setInHandPokersDonePos(seatHolder)
    if(seatHolder.transDonePokersPos)then
        seatHolder.handPokerCardsRoot.transform.position = seatHolder.transDonePokersPos.position
    end    
end

function TableRunfastHelper:setInHandPokersOriginalPos(seatHolder)
    seatHolder.handPokerCardsRoot.transform.position = seatHolder.inHandCardsOriginalPos
end


--播放随机选庄动画
function TableRunfastHelper:playRandomBankerAnim(seatHolderList, targetSeat, onFinish)
    math.randomseed(os.time())
    local minTimes = math.random(2, 5)
    local sequence = self.module:create_sequence();

end


--刷新座位相关信息
function TableRunfastHelper:refreshSeatInfo(seatHolder, seatData)    
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)     
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, true)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotSeatRoot.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, seatData.isBanker)    
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, seatData.isCreator)    
        -- print("seatData", seatData.playerId, seatData.isOffline)
        self:refreshSeatOfflineState(seatHolder, seatData)
        seatHolder.textScore.text = seatData.score
        seatHolder.GoldCount.text = Util.filterPlayerGoldNum(seatData.coinBalance)
        if (seatData.playerInfo and seatData.playerInfo.userId) then
            self:setPlayerInfo(seatHolder, seatData.playerInfo)        
        else
            seatData.playerInfo = {}
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
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, false)        
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotSeatRoot.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, false)                     
    end
end

function TableRunfastHelper:refreshSeatOfflineState(seatHolder, seatData)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageDisconnect.gameObject, seatData.isOffline) 
   -- self.modelData.roleData.RoomType == 0 --0 非麻将馆房间 1 麻将馆普通开房 2 麻将馆随机组局 3 比赛场房间  
    if self.modelData.roleData.RoomType == 2 and self.modelData.curTableData.roomInfo.curRoundNum == 0 then--TODO XLQ 快速组局 离线玩家显示踢人按钮---
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.KickBtn.gameObject, seatData.isOffline)  
    end
end

--刷新座位的状态
function TableRunfastHelper:refreshSeatState(seatHolder, seatData)
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then        
        if(self.modelData.curTableData.roomInfo.roundStarted) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, false)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, seatData.isReady and (not seatData.curRound))
        end
        self:setBetScore(seatHolder, seatData, true)
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, false)    
        self:setBetScore(seatHolder, seatData, false)
    end
end

function TableRunfastHelper:showSeatWinScoreCurRound(seatHolder, show, score)
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
function TableRunfastHelper:showSpeakIcon(seatHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSpeakIcon, show) 
end

--显示下注按钮
function TableRunfastHelper:setBetScore(seatHolder, seatData, show)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate1.gameObject, show and (not seatData.isBanker) and seatData.betScore == 1)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate2.gameObject, show and (not seatData.isBanker) and seatData.betScore == 2)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate3.gameObject, show and (not seatData.isBanker) and seatData.betScore == 3)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate4.gameObject, show and (not seatData.isBanker) and seatData.betScore == 4)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate5.gameObject, show and (not seatData.isBanker) and seatData.betScore == 5)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageScoreRate10.gameObject, show and (not seatData.isBanker) and seatData.betScore == 10)
end

------填写玩家信息
function TableRunfastHelper:setPlayerInfo(seatHolder, playerData)
    if(playerData.playerId ~= 0)then
        if(playerData.hasDownHead)then
           return
        end
        --seatHolder.textPlayerId.text = ""--"ID:"..tostring(playerData.playerId)
        seatHolder.textPlayerName.text = Util.filterPlayerName(playerData.playerName,8)
        self:startDownLoadHeadIcon(seatHolder.imagePlayerHead, playerData.headUrl,function(headsprite)
            playerData.spriteHeadImage = headsprite
        end)
    else
        seatHolder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
end

------下载头像
function TableRunfastHelper:startDownLoadHeadIcon(targetImage, url,callback)    
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            --print('error down load '.. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(err.error, 'http') == 1 then 
                if(self)then
                    --self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if(callback) then
                callback(tex)
            end
        end
    end)    
end

------设置第一人称的扑克信息
function TableRunfastHelper:SetFirstPokerInfo(_cardHolder,_PokerNum)
    _cardHolder.PokerNum = _PokerNum
    _cardHolder.face.sprite = self:GetPokerSprite(_PokerNum)
end

-------获取扑克图,两个参数输入一个即可,另外一个参数为nil
function TableRunfastHelper:GetPokerSprite(_PokerNum,_Poker)
    if(_PokerNum ~= nil) then
        local poker = self:NumberToPokerTable(_PokerNum)
        local spriteName = poker.SpriteName
        return self.TableRunfastView.cardAssetHolder:FindSpriteByName(spriteName)
    end

    if(_Poker ~= nil) then
        return self.TableRunfastView.cardAssetHolder:FindSpriteByName(_Poker.SpriteName)
    end
end

--设置牌的数据
function TableRunfastHelper:setCardInfo(cardHolder, poker)    
    cardHolder.poker = poker    
    cardHolder.face.sprite = self:GetPokerSprite(nil,poker)
end

--显示或隐藏牌
function TableRunfastHelper:showCard(cardHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.cardRoot, show)
end

--显示牌正面
function TableRunfastHelper:showCardFace(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, false)
end

--显示牌背面
function TableRunfastHelper:showCardBack(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, true)
end

function TableRunfastHelper:enableGradientColor(cardHolder,show)
    if(cardHolder) then
        cardHolder.GradientColor.enabled = show
    end
end

function TableRunfastHelper:SetPokerDragEffect(pokerName,enabled)
    local cardHolder = self.TableRunfastLogic:FindPokerByName(pokerName)
    if(cardHolder) then
	    self.TableRunfastHelper:enableGradientColor(cardHolder,enabled)
	end
end

--显示或隐藏手牌
function TableRunfastHelper:showInHandCards(seatHolder, show)    
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerCardsRoot, show)
end

--function TableRunfastHelper:getImageNameFromPoker(poker)
--    --S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
--    local colorStr
--    if(poker.colour == "S") then
--        colorStr = "heitao"
--    elseif (poker.colour == "H") then
--        colorStr = "hongtao"
--    elseif (poker.colour == "C") then
--        colorStr = "meihua"
--    elseif (poker.colour == "D") then
--        colorStr = "fangkuai"
--    end
--
--    local numberStr
--    if(poker.number == "A") then
--        numberStr = "1"
--    elseif (poker.number == "J") then
--        numberStr = "11"
--    elseif (poker.number == "Q") then
--        numberStr = "12"
--    elseif (poker.number == "K") then
--        numberStr = "13"
--    else
--        numberStr = poker.number
--    end
--    local spriteName = colorStr .. "_" .. numberStr
--    return spriteName
--end

------数字转化到扑克图片名:例如输入43返回meihua_11
--function TableRunfastHelper:numberToPokerSpriteName(index)
--     local colorStr
--     local temp = CardCommon.ResolveCardIdx(index)
--     if(temp.color == 1) then
--         colorStr = "heitao"
--     elseif (temp.color == 2) then
--         colorStr = "hongtao"
--     elseif (temp.color == 3) then
--         colorStr = "meihua"
--     elseif (temp.color == 4) then
--         colorStr = "fangkuai"
--     end
--     local spriteName = colorStr .. "_" .. temp.name
--     return spriteName
--end

--function TableRunfastHelper:NumberToPoker(index)
--     local colorStr
--     local numberStr
--     local temp = CardCommon.ResolveCardIdx(index)
--     if(temp.color == 1) then
--         colorStr = "S"
--     elseif (temp.color == 2) then
--         colorStr = "H"
--     elseif (temp.color == 3) then
--         colorStr = "C"
--     elseif (temp.color == 4) then
--         colorStr = "D"
--     end
--
--
--     if(temp.name == 1)then
--         numberStr = "A"
--     elseif(temp.name == 11) then
--         numberStr = "J"
--     elseif(temp.name == 12) then
--         numberStr = "Q"
--     elseif(temp.name == 13) then
--         numberStr = "K"
--     else
--         numberStr = tostring(temp.name)
--     end
--
--     return colorStr,numberStr
--end

function TableRunfastHelper:NumberToPokerTable(num)
    local poker = {}
    poker.PokerNum = num
    local colorStr
    local temp = CardCommon.ResolveCardIdx(num)
    if(temp.color == 1) then
        colorStr = "heitao"
    elseif (temp.color == 2) then
        colorStr = "hongtao"
    elseif (temp.color == 3) then
        colorStr = "meihua"
    elseif (temp.color == 4) then
        colorStr = "fangkuai"
    end
    poker.colorStr = colorStr
    poker.colorNum = temp.color
    poker.nameNum = temp.name
    poker.SpriteName = colorStr .. "_" .. temp.name
    return poker
end


------扑克对象到数字
--function TableRunfastHelper:PokerToNumber(poker)
--    local locSpriteName = self:getImageNameFromPoker(poker)
--    return self:PokerSpriteNameToNumber(locSpriteName)
--end

------扑克图片名到数字:例如输入meihua_11返回43
--function TableRunfastHelper:PokerSpriteNameToNumber(spriteName)
--    local res = -1
--    local temp = string.split(spriteName,"_")
--    if(temp == nil or #temp ~= 2 ) then
--        return res
--    end
--
--    local colorStr = temp[1]
--    local nameStr = temp[2]
--
--    local colorInt
--    local nameInt = tonumber(nameStr)
--    if(colorStr=="heitao") then
--        colorInt = 1
--    elseif(colorStr=="hongtao") then
--        colorInt = 2
--    elseif(colorStr=="meihua") then
--        colorInt = 3
--    elseif(colorStr=="fangkuai") then
--        colorInt = 4
--    end
--
--    res = CardCommon.FormatCardIndex(nameInt,colorInt)
--    return res
--end

--function TableRunfastHelper:getNumberFormPoker(poker)
--    if(poker.number == "A") then
--        return 1
--    elseif (poker.number == "J") then
--        return 10
--    elseif (poker.number == "Q") then
--        return 10
--    elseif (poker.number == "K") then
--        return 10
--    else
--        return tonumber(poker.number)
--    end
--end



------通过服务器的位置索引获得客户端显示的座位
function TableRunfastHelper:getSeatInfoByRemoteSeatIndex(remoteSeatIndex, seatInfoList)	
	for i=1,#seatInfoList do
		if(seatInfoList[i].seatIndex == remoteSeatIndex) then
			return seatInfoList[i]
		end
	end
	return nil
end

------将服务器的做座位索引转换为本地位置索引:seatIndex座位的下标(非本地下标),我的座位下标(非本地下标),seatCount座位的数量
function TableRunfastHelper:getLocalIndexFromRemoteSeatIndex(seatIndex, mySeatIndex, seatCount)
    --print("=====seatIndex="..tostring(seatIndex).."   mySeatIndex="..tostring(mySeatIndex).."   seatCount="..tostring(seatCount))
	local localIndex = seatIndex + (1 - mySeatIndex) + seatCount
	if(localIndex > seatCount) then
		return localIndex - seatCount
	else
		return localIndex
	end
end

------判断是否所有入座的玩家都已准备
function TableRunfastHelper:checkIsAllReady(seatInfoList)
    --人数不足
    local playerCount = self.modelData.curTableData.roomInfo.maxPlayerCount
    if(#seatInfoList ~= playerCount)  then
        -- print("====人数不足 playerCountMax="..playerCount)
        return false
    end

    --人数足,是否都准备了
    for i=1,#seatInfoList do
        if(seatInfoList[i].isReady == false) then
            return false
        end
    end
    return true
    --[[
    local isAllReady = true
	for i=1,#seatInfoList do        
		if(seatInfoList[i].isSeated) then            
            isAllReady = isAllReady and seatInfoList[i].isReady
		end
	end	    
	return isAllReady
    ]]
end




------通过玩家id获取座位信息
function TableRunfastHelper:getSeatInfoByPlayerId(playerId, seatInfoList)	
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

------获取玩家的数量
function TableRunfastHelper:getSeatedSeatCount(seatInfoList)
	local count = 0    
	for i=1,#seatInfoList do
		if(seatInfoList[i].playerId ~= "0")then
			count = count + 1
		end
	end
	return count
end


function TableRunfastHelper:get_userinfo(playerId, callback)
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


function TableRunfastHelper:showRoundScoreEffect(seatHolder, localSeatIndex, show, score, duration, delayTime, stayTime, onComplete)
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


function TableRunfastHelper:InstantiateHandPokerSlot(prefab,parentRoot,SlotTable)
    ModuleCache.ComponentUtil.SafeSetActive(prefab, false)
    for i=1,self.pokerSlotMaxCount do
        local tPoker = ModuleCache.ComponentUtil.InstantiateLocal(prefab, parentRoot)
        tPoker.name = "Poker"..tostring(i)
        ModuleCache.ComponentUtil.SafeSetActive(tPoker, true)
        table.insert(SlotTable,tPoker)
    end
end

function TableRunfastHelper:InstantiateOtherThrowPokerSlot(prefab,parentRoot,SlotTable)
    ModuleCache.ComponentUtil.SafeSetActive(prefab, false)
    for i=1,self.pokerSlotMaxCount do
        local tPoker = ModuleCache.ComponentUtil.InstantiateLocal(prefab, parentRoot)
        tPoker.name = "ThrowPoker"..tostring(i)
        ModuleCache.ComponentUtil.SafeSetActive(tPoker, false)
        table.insert(SlotTable,tPoker)
    end
end

------缩放动画:TargetRoot目标节点,FromScale原始的比例,ToScale目标比例,Duration缩放时间,WaitTimeAutoHide等待多久后自动隐藏
function TableRunfastHelper:PlayScaleAnim(TargetRoot,FromScale,ToScale,Duration,WaitTimeAutoHide)
    --显示目标
    ModuleCache.ComponentUtil.SafeSetActive(TargetRoot.transform.gameObject,true)
    --显示原始比例
    local OldScale = TargetRoot.transform.localScale
    OldScale.x = FromScale
    OldScale.y = FromScale
    TargetRoot.transform.localScale = OldScale
    --显示缩放比例
    local sequence = self.module:create_sequence()
    sequence:Append(TargetRoot.transform:DOScaleX(ToScale, Duration))   
    sequence:Join(TargetRoot.transform:DOScaleY(ToScale, Duration))  

    --之后自动隐藏
    if(WaitTimeAutoHide ~= nil and WaitTimeAutoHide > 0) then
        self.module:subscibe_time_event(WaitTimeAutoHide, false, 0):OnComplete(function(t)
            ModuleCache.ComponentUtil.SafeSetActive(TargetRoot.transform.gameObject,false)
        end)
    end
end

------Y轴移动动画:TargetRoot目标节点,FromY原始的Y,ToY目标Y,Duration缩放时间,WaitTimeAutoHide等待多久后自动隐藏
function TableRunfastHelper:PlayMoveYAnim(TargetRoot,FromY,ToY,Duration,WaitTimeAutoHide)
    if(FromY ~= nil) then
        local OldPos = TargetRoot.transform.localPosition
        OldPos.y = FromY
        TargetRoot.transform.localPosition = OldPos
    end
    
    ModuleCache.ComponentUtil.SafeSetActive(TargetRoot.transform.gameObject,true)
    local sequence = self.module:create_sequence()
    sequence:Append(TargetRoot.transform:DOLocalMoveY(ToY, Duration, true))

    if(WaitTimeAutoHide ~= nil and WaitTimeAutoHide > 0) then
        self.module:subscibe_time_event(WaitTimeAutoHide, false, 0):OnComplete(function(t)
            ModuleCache.ComponentUtil.SafeSetActive(TargetRoot.transform.gameObject,false)
        end)
    end
end


------数组里面是否包含了某个值
function TableRunfastHelper:IsNumTableContains(_NumTable,_Num)
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

------数组里面是否包含了某个值的次数
function TableRunfastHelper:NumTableContainsCount(_NumTable,_Num)
    if(_NumTable == nil or #_NumTable <= 0 or _Num == nil) then
        return 0
    end

    local count = 0
    for i=1,#_NumTable do
        if(_NumTable[i] == _Num) then
            count = count + 1
        end
    end
    return count
end

--飞到目标位置 len 金币数量 cloneObj 克隆物体 parentObj 克隆父物体 fromPos 起始位置 targetPos 结束位置 duration 持续时间 delayTime 延迟时间 autoDestory 自动销毁 onFinish 回调
function TableRunfastHelper:FlyToTarget(len, cloneObj, parentObj, fromPos, targetPos, duration, delayTime, autoDestory, onFinish)
    duration = duration or 0.5
    delayTime = delayTime or 0

    local tmpDelayTime = math.min(0.1, 1 / len)
    self:setTargetFrame(true)
    for i=1,len do
        local tmpOnFinish = nil
        if(i == len)then
            tmpOnFinish = onFinish
        end
        local gold = ModuleCache.ComponentUtil.InstantiateLocal(cloneObj, parentObj)
        gold.transform.position = fromPos
        ModuleCache.ComponentUtil.SafeSetActive(gold, false)
        self:fly_random_path(gold.transform, fromPos, targetPos, duration, delayTime + (i - 1) * tmpDelayTime, function ()
            if(autoDestory)then
                UnityEngine.GameObject.Destroy(gold)
            end
            if(tmpOnFinish)then
                self:setTargetFrame(false)
                tmpOnFinish()
            end
        end)
    end
end

--随机路径飞
function TableRunfastHelper:fly_random_path(trans, fromPos, targetPos, duration, delayTime, onFinish)
    local randomSplitNum = math.random(3) --节点数
    duration = duration / randomSplitNum
    local moveVector = (targetPos - fromPos)/randomSplitNum
    local sequence = self.module:create_sequence()
    local downOrUp = math.random(-1,1)
    for i = 1, randomSplitNum do
        local addRandomVal = math.random()*downOrUp*0.15 --幅度
        if(i==randomSplitNum) then
            addRandomVal = 0
        end
        local targetPos = fromPos + moveVector*i + Vector3.New(addRandomVal, -addRandomVal, 0)
        if(i~=1) then
            delayTime = 0
        end
        ModuleCache.ComponentUtil.SafeSetActive(trans.gameObject, true)
        sequence:Append(trans:DOMove(targetPos, duration, false):SetDelay(delayTime))
    end
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end
    end)
end

function TableRunfastHelper:setTargetFrame(anim)
    UnityEngine.Application.targetFrameRate = (anim and 60) or ModuleCache.AppData.tableTargetFrameRate
end

--IsFiltNilValue是否过nil值
function TableRunfastHelper:NumTableInsertToNewTable(NewTable,NumTable,IsFiltNilValue)
    if(NumTable == nil or #NumTable <=0 ) then
        print("====error NumTable == nil or #NumTable <=0 ")
    end
    for i=1,#NumTable do
		local locNum = NumTable[i]
        table.insert(NewTable,locNum)
        -- if(locNum == nil and IsFiltNilValue) then
        --     --过滤nil值
        -- else
        --     table.insert(NewTable,locNum)
        -- end
	end
end

return TableRunfastHelper