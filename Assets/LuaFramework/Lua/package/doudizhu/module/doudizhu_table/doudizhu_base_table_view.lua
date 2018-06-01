--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;

local class = require("lib.middleclass")
local View = require('package.public.module.table_poker.base_table_view')
local BaseTableView = class('BaseTableView', View)

local cardCommon = require('package.doudizhu.module.doudizhu_table.gamelogic_common')

local tableSound = require('package.doudizhu.module.doudizhu_table.table_sound')

local GameSDKInterface = ModuleCache.GameSDKInterface

local offsetY = 50

function BaseTableView:initialize(assetBundleName, mainAssetName, sortingLayer)
    View.initialize(self, assetBundleName, mainAssetName, sortingLayer)

    self.imageMask = GetComponentWithPath(self.root, "Background/mask", ComponentTypeName.Image)
    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground1", ComponentTypeName.Image)
    self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoundNum/Text", ComponentTypeName.Text)
    self.buttonRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/ButtonRule", ComponentTypeName.Button)

    self.textBeiShu = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Multiple/Text", ComponentTypeName.Text)

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.smallCardAssetHolder = GetComponentWithPath(self.root, "Holder/SmallCardAssetHolder", "SpriteHolder")
    self.myCardAssetHolder = self.cardAssetHolder
    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material
    self.prefabPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker", ComponentTypeName.Transform).gameObject

    self.buttonBuChu = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonBuChu", ComponentTypeName.Button)
    self.buttonChuPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonChuPai", ComponentTypeName.Button)
    self.buttonTiShi = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonTiShi", ComponentTypeName.Button)
    self.buttonYaoBuQi = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonYaoBuQi", ComponentTypeName.Button)

    self.goGrabLordBtns = GetComponentWithPath(self.root, "Buttons/GrabLordBtns", ComponentTypeName.Transform).gameObject
    self.buttonGrabLordBtns = {}
    for i=1,4 do
        self.buttonGrabLordBtns[i] = GetComponentWithPath(self.goGrabLordBtns, "ButtonGrabLord_" .. (i - 1), ComponentTypeName.Button)
    end

    self.buttonShowCard = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonShowCard", ComponentTypeName.Button)
    self.buttonShowCard_uiStateSwitcher = ModuleCache.ComponentManager.GetComponent(self.buttonShowCard.gameObject,"UIStateSwitcher")

    local goDeskLeftCardRoot = GetComponentWithPath(self.root, "Top/DeskLeftCards", ComponentTypeName.Transform).gameObject
    local deskLeftCardsPokerHolderArray = {}
    for i=1,3 do
        local pokerHolder = {}
        pokerHolder.root = GetComponentWithPath(goDeskLeftCardRoot, "Poker"..i, ComponentTypeName.Transform).gameObject
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);   
        deskLeftCardsPokerHolderArray[i] = pokerHolder 
    end
    self.goDeskLeftCardRoot = goDeskLeftCardRoot
    self.deskLeftCardsPokerHolderArray = deskLeftCardsPokerHolderArray

end

function BaseTableView:getTotalSeatCount()
    return 3
end

function BaseTableView:initAllSeatHolders()
    self.dispatchCardHolderList = {}
    self.dispatchCardEffectHolderList = {}
    local goEffect_chutian = GetComponentWithPath(self.root, "DispatchCardsEffect/Anim_DDZ_ChunTian", ComponentTypeName.Transform).gameObject
    self.goEffect_dizhu = GetComponentWithPath(self.root, "Center/PosHolder/LordEffectPos/Anim_DDZ_DiZhuBoFang", ComponentTypeName.Transform).gameObject
    self.pos_goEffect_dizhu = self.goEffect_dizhu.transform.parent.position
    for i=1,3 do
        local dispatchCardHolder = {}
        dispatchCardHolder.root = GetComponentWithPath(self.root, "Center/DispatchCards/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardHolder.pokerHolderList = {}
        local prefabPoker = GetComponentWithPath(dispatchCardHolder.root, "Pokers/Poker", ComponentTypeName.Transform).gameObject
        for j=1,20 do
            local pokerHolder = {}
            if(j == 1)then
                pokerHolder.root = prefabPoker
            else
                pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
            end
            pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
            pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);    
            pokerHolder.goLordTag = GetComponentWithPath(pokerHolder.root, "Poker/tagLord", ComponentTypeName.Image).gameObject 
            dispatchCardHolder.pokerHolderList[j] = pokerHolder
        end
        self.dispatchCardHolderList[i] = dispatchCardHolder

        local dispatchCardEffectHolder = {}
        dispatchCardEffectHolder.root = GetComponentWithPath(self.root, "DispatchCardsEffect/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.center_root = GetComponentWithPath(self.root, "DispatchCardsEffect/Center/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_shunzi = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DDZ_ShunZi", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_feiji = GetComponentWithPath(dispatchCardEffectHolder.center_root, "Anim_DDZ_FeiJi", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_liandui = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DDZ_LianDui", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_zhadan = GetComponentWithPath(dispatchCardEffectHolder.center_root, "Anim_DDZ_ZhaDan", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_wangzha = GetComponentWithPath(dispatchCardEffectHolder.center_root, "Anim_DDZ_WangZha", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_chutian = goEffect_chutian
        if(i == 1)then
            dispatchCardEffectHolder.goEffect_mingpai = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DDZ_MingPai", ComponentTypeName.Transform).gameObject
        else
            dispatchCardEffectHolder.goEffect_mingpai = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DDZ_MingPaiTaRen", ComponentTypeName.Transform).gameObject
        end
        self.dispatchCardEffectHolderList[i] = dispatchCardEffectHolder

    end
    View.initAllSeatHolders(self)
end

function BaseTableView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    local root = seatRoot
    if index == 1 then
       seatHolder.uiStateSwitcher:SwitchState("Bottom")
        local animSelectBankerHorizontal = GetComponentWithPath(root, "Info/EffectHorizontal", ComponentTypeName.Image)           
        seatHolder.animSelectBanker = animSelectBankerHorizontal
    elseif index == 2 then
       seatHolder.uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
    elseif index == 3 then        
       seatHolder.uiStateSwitcher:SwitchState("Left")
    end
    
    seatHolder.imagePass = GetComponentWithPath(self.root, "Center/PassIcon/"..index.."/PassIcon/image", ComponentTypeName.Image)
    seatHolder.imageWarning = GetComponentWithPath(root, "State/Group/ImageWarning", ComponentTypeName.Transform)
    seatHolder.goEffect_Warning = GetComponentWithPath(root, "State/Group/ImageWarning/Ainm_Baojing", ComponentTypeName.Transform).gameObject
    seatHolder.goEffect_dizhu = GetComponentWithPath(root, "Info/ImageLandLord/Anim_DDZ_DiZhuXuanZhong", ComponentTypeName.Transform).gameObject
    seatHolder.imageLeftCard = GetComponentWithPath(root, "State/Group/LeftCard", ComponentTypeName.Image)
    seatHolder.textLeftCard = GetComponentWithPath(seatHolder.imageLeftCard.gameObject, "Text", ComponentTypeName.Text)

    seatHolder.imageLandLord = GetComponentWithPath(root, "Info/ImageLandLord/Image", ComponentTypeName.Image)

    if(index == 1)then
        seatHolder.imageClock = GetComponentWithPath(self.root, "Bottom/Clock", ComponentTypeName.Image)
        seatHolder.textClock = GetComponentWithPath(seatHolder.imageClock.gameObject, "Text", "TextWrap")
    else
        seatHolder.imageClock = GetComponentWithPath(root, "State/Group/Clock", ComponentTypeName.Image)
        seatHolder.textClock = GetComponentWithPath(seatHolder.imageClock.gameObject, "Text", "TextWrap")
    end
    seatHolder.imageHeadSelected = GetComponentWithPath(root, "Info/HeadSelected", ComponentTypeName.Image)


    seatHolder.dispatchCardHolder = self.dispatchCardHolderList[index]
    seatHolder.dispatchCardEffectHolder = self.dispatchCardEffectHolderList[index]

    seatHolder.handPokerHolder = {}
    seatHolder.handPokerHolder.root = GetComponentWithPath(self.root, "Center/HandCards/"..index, ComponentTypeName.Transform).gameObject
    local prefabPoker = GetComponentWithPath(seatHolder.handPokerHolder.root, "Pokers/Poker", ComponentTypeName.Transform).gameObject
    for i=1,20 do
        local pokerHolder = {}
        if(i == 1)then
            pokerHolder.root = prefabPoker
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
        end
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);      
        pokerHolder.imageLordTag = GetComponentWithPath(pokerHolder.root, "Poker/face/tagLord", ComponentTypeName.Image)
        pokerHolder.imageMingPaiTag = GetComponentWithPath(pokerHolder.root, "Poker/face/tagMingPai", ComponentTypeName.Image)
        seatHolder.handPokerHolder[i] = pokerHolder  
    end

    seatHolder.textCoin =  GetComponentWithPath(root, "Info/GoldCoin/GoldCoin/Text", ComponentTypeName.Text)
    seatHolder.textName_gold =  GetComponentWithPath(root, "Info/GoldCoin/TextName", ComponentTypeName.Text)
    seatHolder.imageSeatBg = GetComponentWithPath(seatRoot, "Info/ImageBackground", ComponentTypeName.Image)
end

--显示座位上的金币数
function BaseTableView:showSeatGoldCoin(localSeatIndex, showCoin)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    showCoin = showCoin or false
    if(showCoin)then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textPlayerName.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageSeatBg.gameObject, false)
        seatHolder.textPlayerName = seatHolder.textName_gold
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textName_gold.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textName_gold.transform.parent.gameObject, true)
    end
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textScore.transform.parent.gameObject, not showCoin)
end

--刷新座位玩家状态
function BaseTableView:refreshSeatState(seatInfo, localSeatIndex)
    View.refreshSeatState(self, seatInfo, localSeatIndex)
    localSeatIndex = localSeatIndex or seatInfo.localSeatIndex
    local seatHolder = self.seatHolderArray[localSeatIndex]
    seatHolder.textCoin.text = Util.filterPlayerGoldNum(seatInfo.coinBalance)
end

function BaseTableView:SetRuleBtnActive(isActive)
    self.buttonRule.gameObject:SetActive(isActive)
end

function BaseTableView:getImageNameFromCode(code, majorCardLevel)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function BaseTableView:getImageNameFromCard(card, majorCardLevel)
    local color = card.color
    local number = card.name
    if(number == cardCommon.card_small_king)then
        return 'little_boss'
    elseif(number == cardCommon.card_big_king)then
        return 'big_boss'
    end
    

    if(color == cardCommon.color_black_heart)then
        return 'heitao_' .. number
    elseif(color == cardCommon.color_red_heart)then
        if(majorCardLevel)then
           return 'xing_' .. number     
        end
        return 'hongtao_' .. number
    elseif(color == cardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == cardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end

--显示倍数
function BaseTableView:showMultiple(show, multiple)
    ModuleCache.ComponentUtil.SafeSetActive(self.textBeiShu.gameObject, show or false)
    if(show)then
        self.textBeiShu.text = multiple .. '倍'
    end
end

--显示出牌相关按钮
function BaseTableView:showChuPaiButtons(show, isFirst, yaoBuQi)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChuPai.gameObject, show and (not yaoBuQi) or false)
    self:setGray(self.buttonChuPai.gameObject, yaoBuQi or false)
    self.buttonChuPai.enabled = not (yaoBuQi or false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonBuChu.gameObject, show and (not yaoBuQi) or false)
    self:setGray(self.buttonBuChu.gameObject, isFirst or false)
    self.buttonBuChu.enabled = not (isFirst or false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonTiShi.gameObject, show and (not yaoBuQi) or false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonYaoBuQi.gameObject, show and (not isFirst) and yaoBuQi or false)
end

--显示报警图标
function BaseTableView:showSeatWarningIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.goEffect_Warning
    ModuleCache.ComponentUtil.SafeSetActive(go, show or false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageWarning.gameObject, show or false)
end

--显示地主标签
function BaseTableView:showSeatLandLordIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.imageLandLord.gameObject
    ModuleCache.ComponentUtil.SafeSetActive(go, show or false)
end

--刷新手牌数
function BaseTableView:showLeftHandCardCountBg(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageLeftCard.gameObject, show or false)
end

--刷新手牌数
function BaseTableView:refreshLeftHandCardCount(localSeatIndex, show, leftCount)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textLeftCard.gameObject, show or false)
    if(show)then
        seatHolder.textLeftCard.text = leftCount
    end
end

--显示座位闹钟
function BaseTableView:showSeatClock(localSeatIndex, show, needShake, secs)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    if(seatHolder.clockTimeEventId)then
        CSmartTimer:Kill(seatHolder.clockTimeEventId)
        seatHolder.clockTimeEventId = nil
    end
    self:showSeatSelected(localSeatIndex, show)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageClock.gameObject, show or false)
    if(not show)then
        return
    end
    secs = secs or 16
    seatHolder.clockLeftSecs = secs
    seatHolder.textClock.text = seatHolder.clockLeftSecs - 1
    local timeEvent = self:subscibe_time_event(seatHolder.clockLeftSecs, false, 0):SetIntervalTime(1, function(t)
        if(seatHolder.clockLeftSecs > 0)then
            if(seatHolder.clockLeftSecs == 5)then
                tableSound:playRemind()
            end
            seatHolder.clockLeftSecs = seatHolder.clockLeftSecs - 1
            if(seatHolder.clockLeftSecs == 0 and needShake)then
                self:shakePhone(1000)
            end
        end
        seatHolder.textClock.text = seatHolder.clockLeftSecs
    end):OnComplete(function(t)			
        seatHolder.clockTimeEventId = nil
	end)
    seatHolder.clockTimeEventId = timeEvent.id
end

--显示座位的亮框
function BaseTableView:showSeatSelected(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageHeadSelected.gameObject, show or false)
end


--播放出牌动画
function BaseTableView:playDispatchPokers(localSeatIndex, show,  codeList, showLordTag, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    seatHolder.dispatchCardHolder.root:SetActive(false)
    if(not show)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    --print(localSeatIndex, show, codeList[1], withoutAnim)
    local len = #codeList

    for i=1,#seatHolder.dispatchCardHolder.pokerHolderList do
        local pokerHolder = seatHolder.dispatchCardHolder.pokerHolderList[i]
        if(i > len)then
            pokerHolder.root:SetActive(false)
        else
            pokerHolder.root:SetActive(true)
            local spriteName = self:getImageNameFromCode(codeList[i])
            pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
            if(showLordTag and i == len)then
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.goLordTag, true)
            else
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.goLordTag, false)
            end
        end
    end
    seatHolder.dispatchCardHolder.root:SetActive(true)
    if(withoutAnim)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    
    local sequence = self:create_sequence()
    local duration = 0.175
    local srcScale = 0.8
    seatHolder.dispatchCardHolder.root.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(srcScale,srcScale,1)
    sequence:Append(seatHolder.dispatchCardHolder.root.transform:DOScale(1, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)

end

--播放过牌动画
function BaseTableView:playSeatPassAnim(localSeatIndex, show, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imagePass.transform.parent.gameObject, show or false)
    if(withoutAnim)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    
    local sequence = self:create_sequence()
    local duration = 0.2
    local srcScale = 0.5

    seatHolder.imagePass.transform.localScale = UnityEngine.Vector3.one * srcScale
    sequence:Append(seatHolder.imagePass.transform:DOScale(1, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

--显示座位手牌
function BaseTableView:showSeatHandPokers(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    ModuleCache.ComponentUtil.SafeSetActive(handPokerHolder.root, show or false)
end

--刷新座位手牌
function BaseTableView:refreshSeatHandPokers(localSeatIndex, codeList, showLordTag, showMingPaiTag, customCardAssetHolder)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    for i=1,#handPokerHolder do
        local pokerHolder = handPokerHolder[i]
        ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
    end
    
    local len = #codeList
    for i=1,len do
        local code = codeList[i]
        local spriteName = self:getImageNameFromCode(code)
        local pokerHolder = handPokerHolder[i]
        ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, true)
        local cardAssetHolder = customCardAssetHolder or self.smallCardAssetHolder
        pokerHolder.face.sprite = cardAssetHolder:FindSpriteByName(spriteName);
        if(pokerHolder.imageLordTag)then
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.imageLordTag.gameObject, (showLordTag and i == len))
        end
        if(pokerHolder.imageMingPaiTag)then
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.imageMingPaiTag.gameObject, (showMingPaiTag and i == len))
        end
    end
end

--显示抢地主按钮组
function BaseTableView:showGrabLordBtns(show, scoreList)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGrabLordBtns, show or false)
    for k,v in pairs(self.buttonGrabLordBtns) do
        ModuleCache.ComponentUtil.SafeSetActive(v.gameObject, true)
        self:setGray(v.gameObject, true)
        v.enabled = false
    end
    if(not show or (not scoreList))then
        return
    end
    for i,v in ipairs(scoreList) do
        local btn = self.buttonGrabLordBtns[v + 1]
        if(btn)then
            self:setGray(btn.gameObject, false)
            btn.enabled = true
        end
    end
end

--显示明牌按钮
function BaseTableView:showMingPaiBtn(show, left)
    if(left)then
        self.buttonShowCard_uiStateSwitcher:SwitchState('Left')
    else
        self.buttonShowCard_uiStateSwitcher:SwitchState('Center')
    end
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonShowCard.gameObject, show or false)
end

--显示底牌
function BaseTableView:showDeskLeftCards(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goDeskLeftCardRoot, show or false)
end

--刷新底牌
function BaseTableView:refreshDeskLeftCards(cards, withoutAnim, onFinish)
    cards = cards or {}
    local deskLeftCardsPokerHolderArray = self.deskLeftCardsPokerHolderArray
    local totalCount = #deskLeftCardsPokerHolderArray
    local finishCount = 0
    for i=1, totalCount do
        local pokerHolder = deskLeftCardsPokerHolderArray[i]
        local code = cards[i]
        if(code)then
            local spriteName = self:getImageNameFromCode(code)
            pokerHolder.face.sprite = self.smallCardAssetHolder:FindSpriteByName(spriteName);
            if(withoutAnim)then
                self:showCardFace(pokerHolder)
                if(onFinish)then
                    onFinish()
                end
            else
                self:playCardTurnAnim(pokerHolder, true, 0.5, 0, function()
                    finishCount = finishCount + 1
                    if(finishCount == totalCount)then
                        if(onFinish)then
                            onFinish()
                        end
                    end
                end)
            end
        else
            self:showCardBack(pokerHolder)
        end
    end
end

function BaseTableView:playCardTurnAnim(pokerHolder, toFace, duration, delayTime, onFinish)
    local sequence = self:create_sequence()
    local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
    if(toFace)then
        self:showCardBack(pokerHolder)
    else
        self:showCardFace(pokerHolder)
    end
    
    sequence:Append(pokerHolder.root.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime):OnComplete(function()
        if(toFace)then
            self:showCardFace(pokerHolder)
        else
            self:showCardBack(pokerHolder)
        end 
    end))
    sequence:Append(pokerHolder.root.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end

function BaseTableView:showCardBack(pokerHolder)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.back.gameObject, true)
end

function BaseTableView:showCardFace(pokerHolder)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.back.gameObject, false)
end

--播放报警特效
function BaseTableView:playWarningEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local go = seatHolder.goEffect_Warning
    local duration = 2
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

--播放飞机特效
function BaseTableView:playFeiJiEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_feiji
    local duration = 1.5
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放顺子特效
function BaseTableView:playShunZiEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_shunzi
    local duration = 1.67
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放连对特效
function BaseTableView:playLianDuiEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_liandui
    local duration = 1.67
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放炸弹特效
function BaseTableView:playZhaDanEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_zhadan
    local duration = 1.83
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放王炸特效
function BaseTableView:playWangZhaEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_wangzha
    local duration = 1.83
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end


--播放春天特效
function BaseTableView:playChunTianEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_chutian
    local duration = 2
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放明牌特效
function BaseTableView:playMingPaiEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_mingpai
    local duration = 1.67
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放地主特效
function BaseTableView:playLordEffect(onFinish)
    local go = self.goEffect_dizhu
    local originalPos = self.pos_goEffect_dizhu
    go.transform.position = originalPos
    local duration = 1.3
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        if(onFinish)then
            onFinish()
        else
            ModuleCache.ComponentUtil.SafeSetActive(go, false)
        end
    end)
    return go
end

--播放定地主特效
function BaseTableView:playSetLordEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local go = seatHolder.goEffect_dizhu
    local duration = 2.83
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

return  BaseTableView