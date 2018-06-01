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
---@class DaiGouTuiTableBaseView:Poker_Table_Base_View
local BaseTableView = class('BaseTableView', View)

local cardCommon = require('package.daigoutui.module.table.gamelogic_common')

local tableSound = require('package.daigoutui.module.table.table_sound')

local GameSDKInterface = ModuleCache.GameSDKInterface

local offsetY = 50

function BaseTableView:initialize(assetBundleName, mainAssetName, sortingLayer)
    View.initialize(self, assetBundleName, mainAssetName, sortingLayer)

    self.imageMask = GetComponentWithPath(self.root, "Background/mask", ComponentTypeName.Image)
    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground1", ComponentTypeName.Image)
    self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoundNum/Text", ComponentTypeName.Text)
    self.textWanFa = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoundNum/TextWanFa", ComponentTypeName.Text)
    self.buttonRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/ButtonRule", ComponentTypeName.Button)

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.smallCardAssetHolder = GetComponentWithPath(self.root, "Holder/SmallCardAssetHolder", "SpriteHolder")
    self.myCardAssetHolder = self.cardAssetHolder
    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material
    self.prefabPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker", ComponentTypeName.Transform).gameObject

    local goTuiCardHolder = {}
    goTuiCardHolder.root = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/GouTui", ComponentTypeName.Transform).gameObject
    local pokerHolder = {}
    pokerHolder.root = GetComponentWithPath(goTuiCardHolder.root, "Poker", ComponentTypeName.Transform).gameObject
    pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
    pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);  
    pokerHolder.goGouTuiTag = GetComponentWithPath(pokerHolder.root, "gouTuiTag", ComponentTypeName.Image).gameObject
    goTuiCardHolder.pokerHolder = pokerHolder
    self.goTuiCardHolder = goTuiCardHolder

end

function BaseTableView:getTotalSeatCount()
    return 5
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
            pokerHolder.goGouTuiTag = GetComponentWithPath(pokerHolder.root, "Poker/gouTuiTag", ComponentTypeName.Image).gameObject
            pokerHolder.imageServantCardTag = GetComponentWithPath(pokerHolder.root, "Poker/servantTag", ComponentTypeName.Image) 
            
            dispatchCardHolder.pokerHolderList[j] = pokerHolder
        end
        self.dispatchCardHolderList[i] = dispatchCardHolder

        local dispatchCardEffectHolder = {}
        dispatchCardEffectHolder.root = GetComponentWithPath(self.root, "DispatchCardsEffect/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.center_root = GetComponentWithPath(self.root, "DispatchCardsEffect/Center/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_sanshun = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DGT_SanShun", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_hudie = GetComponentWithPath(dispatchCardEffectHolder.center_root, "Anim_DGT_HuDie", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_liandui = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DGT_LianDui", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_zhadan = GetComponentWithPath(dispatchCardEffectHolder.center_root, "Anim_DGT_ZhaDan", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_sandaier = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DGT_SanDaiEr", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_shunzi = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DGT_ShunZi", ComponentTypeName.Transform).gameObject
        if(i == 1)then
            dispatchCardEffectHolder.goEffect_mingpai = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DGT_MingPai", ComponentTypeName.Transform).gameObject
        else
            dispatchCardEffectHolder.goEffect_mingpai = GetComponentWithPath(dispatchCardEffectHolder.root, "Anim_DGT_MingPaiTaRen", ComponentTypeName.Transform).gameObject
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
    elseif index == 2 or index == 3 then
       seatHolder.uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
    elseif index == 4 or index == 5 then        
       seatHolder.uiStateSwitcher:SwitchState("Left")
    end
    
    seatHolder.imagePass = GetComponentWithPath(self.root, "Center/PassIcon/"..index.."/PassIcon/image", ComponentTypeName.Image)
    seatHolder.imageWarning = GetComponentWithPath(root, "State/Group/ImageWarning", ComponentTypeName.Transform)
    seatHolder.goEffect_Warning = GetComponentWithPath(root, "State/Group/ImageWarning/Ainm_Baojing", ComponentTypeName.Transform).gameObject
    seatHolder.imageLeftCard = GetComponentWithPath(root, "State/Group/LeftCard", ComponentTypeName.Image)
    seatHolder.textLeftCard = GetComponentWithPath(seatHolder.imageLeftCard.gameObject, "Text", ComponentTypeName.Text)

    seatHolder.imageLandLord = GetComponentWithPath(root, "Info/ImageLandLord/Image", ComponentTypeName.Image)
    seatHolder.imageGouTui = GetComponentWithPath(root, "Info/ImageGouTui/Image", ComponentTypeName.Image)

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
    seatHolder.handPokerHolder.root = GetComponentWithPath(self.root, "HandCards/"..index, ComponentTypeName.Transform).gameObject
    seatHolder.handPokerHolder.goChouTi = GetComponentWithPath(seatHolder.handPokerHolder.root, "ChouTi", ComponentTypeName.Transform).gameObject
    seatHolder.handPokerHolder.tran_chouti_close_pos = GetComponentWithPath(seatHolder.handPokerHolder.root, "close_pos", ComponentTypeName.Transform)
    seatHolder.handPokerHolder.tran_chouti_open_pos = GetComponentWithPath(seatHolder.handPokerHolder.root, "open_pos", ComponentTypeName.Transform)
    seatHolder.handPokerHolder.buttonTag = GetComponentWithPath(seatHolder.handPokerHolder.goChouTi, "Button", ComponentTypeName.Button)
    local prefabPoker = GetComponentWithPath(seatHolder.handPokerHolder.goChouTi, "Pokers/Pokers/Poker", ComponentTypeName.Transform).gameObject
    for i=1,38 do
        local pokerHolder = {}
        if(i == 1)then
            pokerHolder.root = prefabPoker
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
        end
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);    
        pokerHolder.goGouTuiTag = GetComponentWithPath(pokerHolder.root, "Poker/gouTuiTag", ComponentTypeName.Image).gameObject  
        pokerHolder.imageServantCardTag = GetComponentWithPath(pokerHolder.root, "Poker/servantTag", ComponentTypeName.Image)
        seatHolder.handPokerHolder[i] = pokerHolder  
    end

    seatHolder.left_handPokerHolder = {}
    seatHolder.left_handPokerHolder.root = GetComponentWithPath(self.root, "LeftHandCards/"..index, ComponentTypeName.Transform).gameObject
    local prefabPoker = GetComponentWithPath(seatHolder.left_handPokerHolder.root, "Pokers/Pokers/Poker", ComponentTypeName.Transform).gameObject
    for i=1,38 do
        local pokerHolder = {}
        if(i == 1)then
            pokerHolder.root = prefabPoker
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
        end
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);    
        pokerHolder.goGouTuiTag = GetComponentWithPath(pokerHolder.root, "Poker/gouTuiTag", ComponentTypeName.Image).gameObject  
        seatHolder.left_handPokerHolder[i] = pokerHolder  
    end

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


--显示报警图标
function BaseTableView:showSeatWarningIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.goEffect_Warning
    ModuleCache.ComponentManager.SafeSetActive(go, show or false)
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageWarning.gameObject, show or false)
end

--显示地主标签
function BaseTableView:showSeatLandLordIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.imageLandLord.gameObject
    ModuleCache.ComponentManager.SafeSetActive(go, show or false)
end

--显示狗腿标签
function BaseTableView:showSeatServantIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.imageGouTui.gameObject
    ModuleCache.ComponentManager.SafeSetActive(go, show or false)
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
function BaseTableView:showLeftHandCards(localSeatIndex, show, cards, servantCard)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local handPokerHolder = seatHolder.left_handPokerHolder
    ModuleCache.ComponentManager.SafeSetActive(handPokerHolder.root, show or false)
    if(show)then
        for i=1,#handPokerHolder do
            local pokerHolder = handPokerHolder[i]
            ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root, false)
        end
        local codeList = cards
        local len = #codeList
        for i=1,len do
            local code = codeList[i]
            local spriteName = self:getImageNameFromCode(code)
            local pokerHolder = handPokerHolder[i]
            ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root, true)
            local cardAssetHolder = self.smallCardAssetHolder
            pokerHolder.face.sprite = cardAssetHolder:FindSpriteByName(spriteName);
            ModuleCache.ComponentManager.SafeSetActive(pokerHolder.goGouTuiTag, code == servantCard)
        end
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


--播放出牌动画
function BaseTableView:playDispatchPokers(localSeatIndex, show,  codeList, servantCard, withoutAnim, onFinish)
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
            local spriteName = self:getImageNameFromCode(code)
            pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
            ModuleCache.ComponentManager.SafeSetActive(pokerHolder.goGouTuiTag, code == servantCard)
            ModuleCache.ComponentManager.SafeSetActive(pokerHolder.imageServantCardTag.gameObject, servantCard == code or false)
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


local singleRowColCount = 8
function BaseTableView:calcDispatchPokerPos(localSeatIndex, len)
    local list = {}
    local dir = 0
    local offsetX = 38.8
    local offsetY = -48
    if(localSeatIndex == 2 or localSeatIndex == 3)then
        dir = -1
    elseif(localSeatIndex == 4 or localSeatIndex == 5)then
        dir = 1
    end
    for i=1,len do
        local col = i
        local row = 1
        local totalCol = len
        if(i <= singleRowColCount)then
            if(len > singleRowColCount)then
                totalCol = singleRowColCount
            else
                totalCol = len
            end
            if(dir == -1)then
                if(len <= 8)then
                    col = (singleRowColCount - len) + i
                end
            end
        else
            row = 2
            totalCol = len - singleRowColCount
            if(dir == -1)then
                col = (singleRowColCount - len) + i
            else
                col = i - singleRowColCount
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
    local rightCol = 8
    local pos = {}
    local index = row * 8 + col
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
function BaseTableView:refreshSeatHandPokers(localSeatIndex, codeList, servantCard)
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
        local cardAssetHolder = self.smallCardAssetHolder
        pokerHolder.face.sprite = cardAssetHolder:FindSpriteByName(spriteName);
        ModuleCache.ComponentManager.SafeSetActive(pokerHolder.goGouTuiTag, code == servantCard)
    end
end

--显示狗腿牌
function BaseTableView:showServantCards(show, servantCard)
    ModuleCache.ComponentManager.SafeSetActive(self.goTuiCardHolder.pokerHolder.root, show or false)
    if(show)then
        local code = servantCard
        local spriteName = self:getImageNameFromCode(code)
        self.goTuiCardHolder.pokerHolder.face.sprite = self.smallCardAssetHolder:FindSpriteByName(spriteName)
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

--播放蝴蝶特效
function BaseTableView:playHuDieEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_hudie
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
function BaseTableView:playShunZiEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
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

--播放三代二特效
function BaseTableView:playSanDaiErEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_sandaier
    local duration = 1.67
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放三顺特效
function BaseTableView:playSanShunEffect(seatInfo, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_sanshun
    local duration = 1.67
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
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



return  BaseTableView