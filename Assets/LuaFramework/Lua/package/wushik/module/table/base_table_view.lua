--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;

local class = require("lib.middleclass")
local View = require('package.public.module.table_poker.base_table_view')
---@class WuShiKTableBaseView:Poker_Table_Base_View
local BaseTableView = class('BaseTableView', View)
---@type WuShiK_CardCommon
local CardCommon = require('package.wushik.module.table.gamelogic_common')

local tableSound = require('package.wushik.module.table.table_sound')

local GameSDKInterface = ModuleCache.GameSDKInterface

local offsetY = 50

function BaseTableView:initialize(assetBundleName, mainAssetName, sortingLayer)
    View.initialize(self, assetBundleName, mainAssetName, sortingLayer)

    self.imageMask = GetComponentWithPath(self.root, "Background/mask", ComponentTypeName.Image)
    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground1", ComponentTypeName.Image)
    self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root, "Center/Text", ComponentTypeName.Text)
    self.buttonRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/ButtonRule", ComponentTypeName.Button)

    self.cardAssetHolder1 = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.cardAssetHolder2 = GetComponentWithPath(self.root, "Holder/CardAssetHolder1", "SpriteHolder")
    self.cardAssetHolder3 = GetComponentWithPath(self.root, "Holder/CardAssetHolder2", "SpriteHolder")
    local pokerFaceStyle = UnityEngine.PlayerPrefs.GetInt('last_wushik_card_face_style', 2)
    self.cardAssetHolder = self['cardAssetHolder' .. pokerFaceStyle]
    if(not self.cardAssetHolder)then
        self.cardAssetHolder = self.cardAssetHolder1
    end

    self.myCardAssetHolder = self.cardAssetHolder

    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material
    self.prefabPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker", ComponentTypeName.Transform).gameObject

    self.textZhuoMianFen = GetComponentWithPath(self.root, "Center/ZhuoMianFen/text", ComponentTypeName.Text)
    local pokerHolder = {}
    pokerHolder.root = GetComponentWithPath(self.root, "Center/JiaoPaiShow/Poker", ComponentTypeName.Transform).gameObject
    pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image)
    pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image)
    self.jiaoPaiPokerHolder = pokerHolder

end

function BaseTableView:getTotalSeatCount()
    return 4
end

function BaseTableView:initAllSeatHolders()
    self.dispatchCardHolderList = {}
    self.dispatchCardEffectHolderList = {}
    for i=1,self:getTotalSeatCount() do
        local dispatchCardHolder = {}
        dispatchCardHolder.root = GetComponentWithPath(self.root, "Center/DispatchCards/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardHolder.pokerHolderList = {}
        local prefabPoker = GetComponentWithPath(dispatchCardHolder.root, "Pokers/Poker", ComponentTypeName.Transform).gameObject
        for j=1,38 do
            local pokerHolder = {}
            if(j == 1)then
                pokerHolder.root = prefabPoker
            else
                pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
            end
            pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
            pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);
            pokerHolder.laiZiTag = GetComponentWithPath(pokerHolder.root, "Poker/tag", ComponentTypeName.Image);
            pokerHolder.daHuTag = GetComponentWithPath(pokerHolder.root, "Poker/dahuTag", ComponentTypeName.Image);
            dispatchCardHolder.pokerHolderList[j] = pokerHolder
        end
        self.dispatchCardHolderList[i] = dispatchCardHolder
        local dispatchCardEffectHolder = {}
        dispatchCardEffectHolder.root = GetComponentWithPath(self.root, "DispatchCardsEffect/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.center_root = GetComponentWithPath(self.root, "DispatchCardsEffect/Center/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_liandui = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DDZ_LianDui", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_zhadan = GetComponentWithPath(dispatchCardEffectHolder.root, "zhadang", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_wushik = GetComponentWithPath(dispatchCardEffectHolder.root, "wushik", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_wangzha = GetComponentWithPath(dispatchCardEffectHolder.center_root, "wangzha", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_shunzi = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DDZ_ShunZi", ComponentTypeName.Transform).gameObject
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
    elseif index == 3 then
        seatHolder.uiStateSwitcher:SwitchState("Top")
    elseif index == 4 then
       seatHolder.uiStateSwitcher:SwitchState("Left")
    end
    seatHolder.imagePass = GetComponentWithPath(self.root, "Center/PassIcon/"..index.."/PassIcon/image", ComponentTypeName.Image)
    seatHolder.imageWarning = GetComponentWithPath(root, "State/Group/ImageWarning", ComponentTypeName.Transform)
    seatHolder.goEffect_Warning = GetComponentWithPath(root, "State/Group/ImageWarning/Ainm_Baojing", ComponentTypeName.Transform).gameObject
    seatHolder.imageLeftCard = GetComponentWithPath(root, "State/Group/LeftCard", ComponentTypeName.Image)
    seatHolder.textLeftCard = GetComponentWithPath(seatHolder.imageLeftCard.gameObject, "Text", ComponentTypeName.Text)
    seatHolder.goLordTag = GetComponentWithPath(root, "State/Group/Lord", ComponentTypeName.Transform).gameObject
    seatHolder.goFriendTag = GetComponentWithPath(root, "State/Group/Friend", ComponentTypeName.Transform).gameObject
    seatHolder.imageFriend = GetComponentWithPath(seatHolder.goFriendTag, "you", ComponentTypeName.Image)
    seatHolder.imageJi = GetComponentWithPath(seatHolder.goFriendTag, "ji", ComponentTypeName.Image)

    seatHolder.imageRankArray = {}
    for i = 1, 3 do
        seatHolder.imageRankArray[i] = GetComponentWithPath(root, "State/Group/Rank/"..i, ComponentTypeName.Image)
    end

    if(index == 1)then
        seatHolder.imageClock = GetComponentWithPath(self.root, "Bottom/Clock", ComponentTypeName.Image)
    else
        seatHolder.imageClock = GetComponentWithPath(self.root, "Center/PassIcon/"..index.."/Clock", ComponentTypeName.Image)
    end

    seatHolder.textClock = GetComponentWithPath(seatHolder.imageClock.gameObject, "Text", "TextWrap")

    seatHolder.imageHeadSelected = GetComponentWithPath(root, "Info/HeadSelected", ComponentTypeName.Image)
    seatHolder.textJianFen = GetComponentWithPath(root, "Info/JianFen/text", ComponentTypeName.Text)

    seatHolder.dispatchCardHolder = self.dispatchCardHolderList[index]
    seatHolder.dispatchCardEffectHolder = self.dispatchCardEffectHolderList[index]

    seatHolder.handPokerHolder = {}
    seatHolder.handPokerHolder.root = GetComponentWithPath(self.root, "HandCards/"..index, ComponentTypeName.Transform).gameObject
    local prefabPoker = GetComponentWithPath(seatHolder.handPokerHolder.root, "Pokers/Poker", ComponentTypeName.Transform).gameObject
    for i=1,27 do
        local pokerHolder = {}
        if(i == 1)then
            pokerHolder.root = prefabPoker
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
        end
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);
        pokerHolder.laiZiTag = GetComponentWithPath(pokerHolder.root, "Poker/tag", ComponentTypeName.Image);
        pokerHolder.daHuTag = GetComponentWithPath(pokerHolder.root, "Poker/dahuTag", ComponentTypeName.Image);
        seatHolder.handPokerHolder[i] = pokerHolder
    end

end

function BaseTableView:SetRuleBtnActive(isActive)
    self.buttonRule.gameObject:SetActive(isActive)
end

function BaseTableView:getImageNameFromCode(code)
    local card = CardCommon.solveCard(code)
    card.code = code
    return self:getImageNameFromCard(card)
end

function BaseTableView:setMagicCards(useMagicCards, magicCards)
    self._useMagicCards = useMagicCards
    self._magicCards = {}
    for i = 1, #magicCards do
        self._magicCards[i] = magicCards[i]
    end
end

function BaseTableView:isMagicCard(code)
    if(not self._useMagicCards)then
        return false
    end
    for i, v in pairs(self._magicCards) do
        if(code == v)then
            return true
        end
    end
    return false
end

function BaseTableView:getImageNameFromCard(card)
    local color = card.color
    local number = card.name
    local code = card.code
    if(CardCommon.isLittleKingCard(code))then
        return 'little_boss'
    elseif(CardCommon.isBigKingCard(code))then
        return 'big_boss'
    end
    

    if(color == CardCommon.color_black_heart)then
        return 'heitao_' .. number
    elseif(color == CardCommon.color_red_heart)then
        return 'hongtao_' .. number
    elseif(color == CardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == CardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end

--显示座位排名
function BaseTableView:showSeatRankTag(localSeatIndex, show, rank)
    show = show or false
    local seatHolder = self.seatHolderArray[localSeatIndex]
    for i = 1, #seatHolder.imageRankArray do
        local iamgeRank = seatHolder.imageRankArray[i]
        ModuleCache.ComponentManager.SafeSetActive(iamgeRank.gameObject, false)
    end
    if(show)then
        local imageRank = seatHolder.imageRankArray[rank]
        if(imageRank)then
            ModuleCache.ComponentManager.SafeSetActive(imageRank.gameObject, true)
        end
    end
end

--显示座位独牌标签
function BaseTableView:showSeatLordTag(localSeatIndex, show)
    show = show or false
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.goLordTag.gameObject, show)
end

--显示庄家的朋友标签
function BaseTableView:showSeatFriendTag(localSeatIndex, show, isFriend)
    show = show or false
    isFriend = isFriend or false
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.goFriendTag.gameObject, show)
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageFriend.gameObject, isFriend)
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageJi.gameObject, not isFriend)
end

--显示报警图标
function BaseTableView:showSeatWarningIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.goEffect_Warning
    ModuleCache.ComponentManager.SafeSetActive(go, show or false)
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageWarning.gameObject, show or false)
end

--刷新手牌数
function BaseTableView:showLeftHandCardCountBg(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageLeftCard.gameObject, show or false)
end

--刷新手牌数
function BaseTableView:refreshLeftHandCardCount(localSeatIndex, show, leftCount)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.textLeftCard.gameObject, show or false)
    if(show)then
        seatHolder.textLeftCard.text = leftCount
    end
end

--刷新剩余手牌
function BaseTableView:showLeftHandCards(localSeatIndex, show, cards)

end

--显示座位捡分
function BaseTableView:showSeatJianFen(localSeatIndex, show, score, withoutAnim)
    show = show or false
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.textJianFen.transform.parent.gameObject, show)
    if(show)then
        seatHolder.textJianFen.text = score
        if(not withoutAnim)then
            self:doScaleAnim(seatHolder.textJianFen.gameObject, 1.5)
        end
    end
end

--显示叫牌框
function BaseTableView:showJiaoPaiFrame(show)
    show = show or false
    local pokerHolder = self.jiaoPaiPokerHolder
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root.transform.parent.gameObject, show)
end

--显示叫牌
function BaseTableView:refreshJiaoPai(show, code)
    show = show or false
    local pokerHolder = self.jiaoPaiPokerHolder
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root, show)
    if(show)then
        pokerHolder.show_code = code
        local spriteName = self:getImageNameFromCode(code)
        local cardAssetHolder = self.cardAssetHolder
        pokerHolder.face.sprite = cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--显示座位闹钟
function BaseTableView:showSeatClock(localSeatIndex, show, needShake)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    if(seatHolder.clockTimeEventId)then
        CSmartTimer:Kill(seatHolder.clockTimeEventId)
        seatHolder.clockTimeEventId = nil
    end
    self:showSeatSelected(localSeatIndex, show)
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageClock.gameObject, show or false)
    if(not show)then
        return
    end
    seatHolder.clockLeftSecs = 16
    seatHolder.textClock.text = seatHolder.clockLeftSecs - 1
    local timeEvent = self:subscibe_time_event(seatHolder.clockLeftSecs, false, 0):SetIntervalTime(1, function(t)
        if(seatHolder.clockLeftSecs > 0)then
            if(seatHolder.clockLeftSecs <= 3)then
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
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageHeadSelected.gameObject, show or false)
end

--显示桌面分
function BaseTableView:showZhuoMianFen(show, score, withoutAnim, onFinish)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.textZhuoMianFen.transform.parent.gameObject, show)
    if(show)then
        self.textZhuoMianFen.text = score
        if(not withoutAnim)then
            self:doScaleAnim(self.textZhuoMianFen.gameObject, 1.5)
        end
    end
end

--播放出牌动画
function BaseTableView:playDispatchPokers(localSeatIndex, show,  codeList, logicCodeList, withoutAnim, onFinish)
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
        pokerHolder.root.name = i
        if(i > len)then
            pokerHolder.root:SetActive(false)
        else
            pokerHolder.root:SetActive(true)
            local code = codeList[i]
            ModuleCache.ComponentManager.SafeSetActive(pokerHolder.laiZiTag.gameObject, self:isMagicCard(code))
            if(logicCodeList[i] and logicCodeList[i] ~= 0)then
                code = logicCodeList[i]
            end
            pokerHolder.show_code = code
            local spriteName = self:getImageNameFromCode(code)
            pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
        end
    end
    self:formatDispatchPokerLayout(localSeatIndex, codeList)
    seatHolder.dispatchCardHolder.root.transform:SetAsLastSibling()
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

function BaseTableView:formatDispatchPokerLayout(localSeatIndex, codeList)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local len = #codeList
    local pos_index_List = self:calcDispatchPokerPos(localSeatIndex, len)
    for i=1,len do
        local pokerHolder = seatHolder.dispatchCardHolder.pokerHolderList[i]
        local pos = pos_index_List[i].pos
        local index = pos_index_List[i].index
        pokerHolder.root.transform:SetSiblingIndex(i)
        pokerHolder.root.transform.localPosition = pos
    end
end


local singleRowColCount = 9
function BaseTableView:calcDispatchPokerPos(localSeatIndex, len)
    local list = {}
    local dir = 0
    local offsetX = 27
    local offsetY = -49
    if(localSeatIndex == 2)then
        dir = -1
    elseif(localSeatIndex == 4)then
        dir = 1
    elseif(localSeatIndex == 1)then
        offsetX = 28
    end
    for i=1,len do
        local col = i
        local row = 1
        local totalCol = len
        if(localSeatIndex == 1)then
            totalCol = len
            row = 1
            col = i
        else
            if(i <= singleRowColCount)then
                totalCol = math.min(len, singleRowColCount)
                col = i - singleRowColCount *(1-1)
                if(dir == -1 and len < singleRowColCount)then
                    col = i + (singleRowColCount - len)
                end
            elseif(i <= singleRowColCount * 2)then
                row = 2
                totalCol = math.min(len - singleRowColCount * 1, singleRowColCount)
                col = i - singleRowColCount *(2-1)
            elseif(i <= singleRowColCount * 3)then
                row = 3
                totalCol = math.min(len - singleRowColCount * 2, singleRowColCount)
                col = i - singleRowColCount *(3-1)
            end
        end


        local pos_index = self:calcPosAndIndex(offsetX, offsetY, col, row, totalCol, dir)
        -- print(offsetX, offsetY, col, row, totalCol, dir)
        table.insert(list, pos_index)
    end
    return list
end

function BaseTableView:calcPosAndIndex(offsetX, offsetY, col, row, totalCol, dir)
    local centerCol = ( (totalCol + 1) * 0.5)
    local leftCol = 1
    local rightCol = 9
    local pos = {}
    local index = row * (rightCol - leftCol + 1) + col
    if(dir == 0)then
        pos.x = offsetX * (col - centerCol)
        pos.y = offsetY * (row - 1)
    elseif(dir == 1)then
        pos.x = offsetX * (col - leftCol)
        pos.y = offsetY * (row - 1)
    elseif(dir == -1)then
        pos.x = offsetX * (col - rightCol)
        pos.y = offsetY * (row - 1)
    end
    pos.z = 0
    return {pos=pos,index=index}
end

--播放过牌动画
function BaseTableView:playSeatPassAnim(localSeatIndex, show, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imagePass.transform.parent.gameObject, show or false)
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
    ModuleCache.ComponentManager.SafeSetActive(handPokerHolder.root, show or false)
end

--刷新座位手牌
function BaseTableView:refreshSeatHandPokers(localSeatIndex, codeList)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    for i=1,#handPokerHolder do
        local pokerHolder = handPokerHolder[i]
        ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root, false)
    end
    
    local len = #codeList
    for i=1,len do
        local code = codeList[i]
        local spriteName = self:getImageNameFromCode(code)
        local pokerHolder = handPokerHolder[i]
        ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root, true)
        local cardAssetHolder = self.cardAssetHolder
        pokerHolder.face.sprite = cardAssetHolder:FindSpriteByName(spriteName);
        ModuleCache.ComponentManager.SafeSetActive(pokerHolder.laiZiTag.gameObject, self:isMagicCard(code))
    end
end

--刷新座位玩家信息
function BaseTableView:refreshSeatPlayerInfo(seatInfo, localSeatIndex)
    View.refreshSeatPlayerInfo(self, seatInfo, localSeatIndex)
    localSeatIndex = localSeatIndex or seatInfo.localSeatIndex
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, false)
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
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.face.gameObject, false)
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.back.gameObject, true)
end

function BaseTableView:showCardFace(pokerHolder)
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.face.gameObject, true)
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.back.gameObject, false)
end

--播放报警特效
function BaseTableView:playWarningEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local go = seatHolder.goEffect_Warning
    local duration = 2
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
    end)
end

--播放炸弹特效
function BaseTableView:playZhaDanEffect(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_zhadan
    local duration = 1.5
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放连对特效
function BaseTableView:playLianDuiEffect(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_liandui
    local duration = 1.5
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放王炸特效
function BaseTableView:playWangZhaEffect(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_wangzha
    local duration = 1.5
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放顺子特效
function BaseTableView:playShunZiEffect(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_shunzi
    local duration = 1.5
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放50k特效
function BaseTableView:play50KEffect(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_wushik
    local duration = 1.5
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end


function BaseTableView:refresh_all_dispatched_poker_face()
    for i, v in pairs(self.seatHolderArray) do
        local seatHolder = v
        for i=1,#seatHolder.dispatchCardHolder.pokerHolderList do
            local pokerHolder = seatHolder.dispatchCardHolder.pokerHolderList[i]
            if(pokerHolder.show_code)then
                local spriteName = self:getImageNameFromCode(pokerHolder.show_code)
                pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
                pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
            end
        end
    end
end

function BaseTableView:refresh_jiaopai_poker_face()
    local pokerHolder = self.jiaoPaiPokerHolder
    if(pokerHolder.show_code)then
        local spriteName = self:getImageNameFromCode(pokerHolder.show_code)
        pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName)
    end
end

function BaseTableView:doScaleAnim(go, fromScale, toScale, duration, onFinish)
    assert(go, 'doScale target gameObject is nil, please set value')
    assert(fromScale, 'fromScale is nil, please set value')
    local sequence = self:create_sequence()
    local duration = duration or 0.3
    toScale = toScale or 1
    go.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(fromScale,fromScale,1)
    sequence:Append(go.transform:DOScale(toScale, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

return  BaseTableView