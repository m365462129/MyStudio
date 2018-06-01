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
local GuanDanTableView = class('GuanDanTableView', View)

local cardCommon = require('package.guandan.module.guandan_table.gamelogic_common')

local tableSound = require('package.guandan.module.guandan_table.table_sound')

local GameSDKInterface = ModuleCache.GameSDKInterface

local offsetY = 50

function GuanDanTableView:initialize(...)
    View.initialize(self, "guandan/module/table/guandan_table.prefab", "GuanDan_Table", 0)

    self.imageMask = GetComponentWithPath(self.root, "Background/mask", ComponentTypeName.Image)
    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground1", ComponentTypeName.Image)
    self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoundNum/Text", ComponentTypeName.Text)
    self.ruleHint = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/ruleBtn", ComponentTypeName.Button)

    self.goRoundInfo = GetComponentWithPath(self.root, "Top/TopInfo/RoundInfo", ComponentTypeName.Transform).gameObject
    self.textOurMainCard = GetComponentWithPath(self.goRoundInfo, "MainCard/TextOurCard", ComponentTypeName.Text)
    self.textOppoMainCard = GetComponentWithPath(self.goRoundInfo, "MainCard/TextOppoCard", ComponentTypeName.Text)
    self.textCurMainCard = GetComponentWithPath(self.goRoundInfo, "Rate/TextCurMainCard", ComponentTypeName.Text)
    self.textRate = GetComponentWithPath(self.goRoundInfo, "Rate/TextRate", ComponentTypeName.Text)

    self.buttonReset = GetComponentWithPath(self.root, "Buttons/ButtonReset", ComponentTypeName.Button)
    self.buttonOneCol = GetComponentWithPath(self.root, "Buttons/ButtonOneCol", ComponentTypeName.Button)
    self.buttonShowDesktop = GetComponentWithPath(self.root, "Buttons/ButtonShowDesktop", ComponentTypeName.Button)
    self.buttonSequence = GetComponentWithPath(self.root, "Buttons/ButtonSequence", ComponentTypeName.Button)
    self.buttonChuPai = GetComponentWithPath(self.root, "Buttons/ButtonChuPai", ComponentTypeName.Button)
    self.buttonTiShi = GetComponentWithPath(self.root, "Buttons/ButtonTiShi", ComponentTypeName.Button)
    self.buttonBuChu = GetComponentWithPath(self.root, "Buttons/ButtonBuChu", ComponentTypeName.Button)
    
    self.buttonShangGong = GetComponentWithPath(self.root, "Buttons/ButtonShangGong", ComponentTypeName.Button)
    self.buttonKangGong = GetComponentWithPath(self.root, "Buttons/ButtonKangGong", ComponentTypeName.Button)
    self.buttonHuanGong = GetComponentWithPath(self.root, "Buttons/ButtonHuanGong", ComponentTypeName.Button)

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.myCardAssetHolder = GetComponentWithPath(self.root, "Holder/MyCardAssetHolder", "SpriteHolder")
    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material
    self.prefabPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker", ComponentTypeName.Transform).gameObject
    
    self.goCenterMingPai = GetComponentWithPath(self.root, "Center/MingPai", ComponentTypeName.Transform).gameObject
    self.imageCenterMingPaiFace = GetComponentWithPath(self.goCenterMingPai, "Poker/face", ComponentTypeName.Image);
    
    self.goChangeSeatInfo = GetComponentWithPath(self.root, "ChangeSeatInfo", ComponentTypeName.Transform).gameObject
    self.goNoSeatChangePanel = GetComponentWithPath(self.root, "NoSeatChangePanel", ComponentTypeName.Transform).gameObject

    self.changeSeatHolderList = {}
    for i=1,2 do
        local seatHolder = {}
        seatHolder.imagePlayerHead = GetComponentWithPath(self.goChangeSeatInfo, "Player"..i.."/Avatar/Mask/Image", ComponentTypeName.Image) 
        seatHolder.textPlayerName = GetComponentWithPath(self.goChangeSeatInfo, "Player"..i.."/TextName", ComponentTypeName.Text)
        self.changeSeatHolderList[i] = seatHolder
    end

    local selectCardsPanelHolder = {}
    selectCardsPanelHolder.root = GetComponentWithPath(self.root, "SelectCardsPanel", ComponentTypeName.Transform).gameObject
    selectCardsPanelHolder.imageSelect = GetComponentWithPath(selectCardsPanelHolder.root, "SelectImage", ComponentTypeName.Image)
    selectCardsPanelHolder.goPokersRoot1 = GetComponentWithPath(selectCardsPanelHolder.root, "WaitSelectCards/Pokers1", ComponentTypeName.Transform).gameObject
    selectCardsPanelHolder.goPokersRoot2 = GetComponentWithPath(selectCardsPanelHolder.root, "WaitSelectCards/Pokers2", ComponentTypeName.Transform).gameObject
    local pokerHolderList1 = {}
    local pokerHolderList2 = {}
    for i=1,2 do
        local list = (i == 1 and pokerHolderList1) or pokerHolderList2
        local tmpRoot = (i == 1 and selectCardsPanelHolder.goPokersRoot1) or selectCardsPanelHolder.goPokersRoot2
        for j=1,8 do
            local pokerHolder = {}
            pokerHolder.root = GetComponentWithPath(tmpRoot, "Poker"..j, ComponentTypeName.Transform).gameObject
            pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
            pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);    
            pokerHolder.star = GetComponentWithPath(pokerHolder.root, "Poker/star", ComponentTypeName.Image);  
            list[j] = pokerHolder
        end
    end
    selectCardsPanelHolder.pokerHolderList1 = pokerHolderList1
    selectCardsPanelHolder.pokerHolderList2 = pokerHolderList2
    self.selectCardsPanelHolder = selectCardsPanelHolder

    self.buttonTextReconnect = GetComponentWithPath(self.root, "Top/TopInfo/TestBtnReconnection", ComponentTypeName.Button)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonTextReconnect.gameObject, ModuleCache.GameManager.developmentMode or false)

    self.readyBtn_countDown_obj = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady/Count down", ComponentTypeName.Transform).gameObject
    self.readyBtn_countDown_tex = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady/Count down/Text", ComponentTypeName.Text)
end

function GuanDanTableView:initAllSeatHolders()
    self.dispatchCardHolderList = {}
    self.dispatchCardEffectHolderList = {}
    self.tributeCardHolderList = {}
    for i=1,4 do
        local dispatchCardHolder = {}
        dispatchCardHolder.root = GetComponentWithPath(self.root, "Center/DispatchCards/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardHolder.pokerHolderList = {}
        for j=1,8 do
            local pokerHolder = {}
            pokerHolder.root = GetComponentWithPath(dispatchCardHolder.root, "Pokers/Poker"..j, ComponentTypeName.Transform).gameObject
            pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
            pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);    
            pokerHolder.star = GetComponentWithPath(pokerHolder.root, "Poker/star", ComponentTypeName.Image);    
            dispatchCardHolder.pokerHolderList[j] = pokerHolder
        end
        self.dispatchCardHolderList[i] = dispatchCardHolder

        local dispatchCardEffectHolder = {}
        dispatchCardEffectHolder.root = GetComponentWithPath(self.root, "Center/DispatchCardsEffect/"..i, ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_shunzi = GetComponentWithPath(dispatchCardEffectHolder.root, "Ainm_Paixing_Shunzi", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_feiji = GetComponentWithPath(dispatchCardEffectHolder.root, "Ainm_Paixing_Feiji", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_liandui = GetComponentWithPath(dispatchCardEffectHolder.root, "Ainm_Paixing_Liandui", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_zhadan = GetComponentWithPath(dispatchCardEffectHolder.root, "Ainm_Paixing_Zhadan", ComponentTypeName.Transform).gameObject
        dispatchCardEffectHolder.goEffect_tonghuashun = GetComponentWithPath(dispatchCardEffectHolder.root, "Ainm_Paixing_TongHuaShun", ComponentTypeName.Transform).gameObject
        self.dispatchCardEffectHolderList[i] = dispatchCardEffectHolder

        local tributeCardHolder = {}
        tributeCardHolder.root = GetComponentWithPath(self.root, "Center/TributeCards/"..i, ComponentTypeName.Transform).gameObject
        tributeCardHolder.goKangGong = GetComponentWithPath(tributeCardHolder.root, "Image", ComponentTypeName.Image).gameObject
        local pokerHolder = {}
        pokerHolder.root = GetComponentWithPath(tributeCardHolder.root, "Poker", ComponentTypeName.Transform).gameObject
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image)
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image)
        tributeCardHolder.pokerHolder = pokerHolder
        self.tributeCardHolderList[i] = tributeCardHolder
    end
    self.goMingPai = GetComponentWithPath(self.root, "Bottom/MingPai", ComponentTypeName.Transform).gameObject
    View.initAllSeatHolders(self)
end

function GuanDanTableView:initSeatHolder(seatHolder, seatRoot, index)
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
       seatHolder.uiStateSwitcher:SwitchState("Top")
    elseif index == 4 then        
       seatHolder.uiStateSwitcher:SwitchState("Left")
    end
    
    seatHolder.imagePass = GetComponentWithPath(root, "State/Group/PassIcon/image", ComponentTypeName.Image)
    seatHolder.imageWarning = GetComponentWithPath(root, "State/Group/ImageWarning", ComponentTypeName.Image)
    seatHolder.goEffect_Warning = GetComponentWithPath(root, "State/Group/ImageWarning/Ainm_Baojing", ComponentTypeName.Transform).gameObject
    seatHolder.imageLeftCard = GetComponentWithPath(root, "State/Group/LeftCard", ComponentTypeName.Image)
    seatHolder.textLeftCard = GetComponentWithPath(seatHolder.imageLeftCard.gameObject, "Text", ComponentTypeName.Text)

    seatHolder.imageClock = GetComponentWithPath(root, "State/Group/Clock", ComponentTypeName.Image)
    seatHolder.textClock = GetComponentWithPath(root, "State/Group/Clock/Text", "TextWrap")

    seatHolder.imageHeadSelected = GetComponentWithPath(root, "Info/HeadSelected", ComponentTypeName.Image)

    seatHolder.goRankList = {}
    for i=1,4 do
        seatHolder.goRankList[i] = GetComponentWithPath(self.root, "Center/RankPos/"..index.."/Rank/" .. i, ComponentTypeName.Transform).gameObject
    end

    seatHolder.dispatchCardHolder = self.dispatchCardHolderList[index]
    seatHolder.dispatchCardEffectHolder = self.dispatchCardEffectHolderList[index]
    seatHolder.tributeCardHolder = self.tributeCardHolderList[index]

    seatHolder.handPokerHolder = {}
    seatHolder.handPokerHolder.root = GetComponentWithPath(root, "State/InHandPokers", ComponentTypeName.Transform).gameObject
    local prefabPoker = GetComponentWithPath(seatHolder.handPokerHolder.root, "Poker", ComponentTypeName.Transform).gameObject
    for i=1,27 do
        local pokerHolder = {}
        if(i == 1)then
            pokerHolder.root = prefabPoker
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
        end
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);      
        seatHolder.handPokerHolder[i] = pokerHolder  
    end

    seatHolder.mingPaiPokerHolerList = {}
    local goMingPai
    if(index == 1)then
        goMingPai = self.goMingPai
    else
        goMingPai = GetComponentWithPath(root, "State/Group/MingPai", ComponentTypeName.Transform).gameObject
    end
    local goTagMingPai = GetComponentWithPath(goMingPai, "Text", ComponentTypeName.Transform).gameObject
    for i=1,2 do
        local pokerHolder = {}
        pokerHolder.root = GetComponentWithPath(goMingPai, "Poker"..i, ComponentTypeName.Transform).gameObject
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);      
        seatHolder.mingPaiPokerHolerList[i] = pokerHolder  
    end
    seatHolder.goMingPai = goMingPai
    seatHolder.goTagMingPai = goTagMingPai

    seatHolder.kickBtn = GetComponentWithPath(root,"Info/ButtonKick",ComponentTypeName.Button);
end


function GuanDanTableView:getImageNameFromCode(code, majorCardLevel)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function GuanDanTableView:getImageNameFromCard(card, majorCardLevel)
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

--显示出牌相关按钮
function GuanDanTableView:showChuPaiButtons(show, isFirst, yaoBuQi)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChuPai.gameObject, show or false)
    self:setGray(self.buttonChuPai.gameObject, yaoBuQi or false)
    self.buttonChuPai.enabled = not (yaoBuQi or false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonBuChu.gameObject, show or false)
    self:setGray(self.buttonBuChu.gameObject, isFirst or false)
    self.buttonBuChu.enabled = not (isFirst or false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonTiShi.gameObject, show or false)
end

--显示上贡按钮
function GuanDanTableView:showShangGongButton(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonShangGong.gameObject, show or false)
end

--显示抗贡按钮
function GuanDanTableView:showKangGongButton(show, gray)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonKangGong.gameObject, show or false)
end

--显示还贡按钮
function GuanDanTableView:showHuanGongButton(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonHuanGong.gameObject, show or false)
end

--显示上贡的牌
function GuanDanTableView:showTributeCard(localSeatIndex, show, code)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.tributeCardHolder.pokerHolder.root, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(code)
        seatHolder.tributeCardHolder.pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--播放交换座位动画
function GuanDanTableView:playChangeSeatPosAnim(localSeatIndex1, localSeatIndex2, onFinish)
    local seatHolder1 = self.seatHolderArray[localSeatIndex1]
    local seatHolder2 = self.seatHolderArray[localSeatIndex2]
    local srcPos1 = seatHolder1.seatRoot.transform.position
    local srcPos2 = seatHolder2.seatRoot.transform.position
    local sequence = self:create_sequence()
    local duration = 0.5
    
    sequence:Append(seatHolder1.seatRoot.transform:DOMove(srcPos2, duration, false))
    sequence:OnComplete(function ()
        seatHolder1.seatRoot.transform.localPosition = UnityEngine.Vector3.zero
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放交换贡牌动画
function GuanDanTableView:playChangeTributeCardAnim(localSeatIndex1, localSeatIndex2, onFinish)
    local seatHolder1 = self.seatHolderArray[localSeatIndex1]
    local seatHolder2 = self.seatHolderArray[localSeatIndex2]
    local srcPos1 = seatHolder1.tributeCardHolder.pokerHolder.root.transform.position
    local srcPos2 = seatHolder2.tributeCardHolder.pokerHolder.root.transform.position
    local sequence = self:create_sequence()
    local duration = 0.5
    
    sequence:Append(seatHolder1.tributeCardHolder.pokerHolder.root.transform:DOMove(srcPos2, duration, false))
    sequence:OnComplete(function ()
        seatHolder1.tributeCardHolder.pokerHolder.root.transform.localPosition = UnityEngine.Vector3.zero
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放贡牌飞到玩家头像上的动画
function GuanDanTableView:playTributeCardFly2Head(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local srcPos = seatHolder.tributeCardHolder.pokerHolder.root.transform.position
    local dstPos = seatHolder.imagePlayerHead.transform.position
    local srcScale = seatHolder.tributeCardHolder.pokerHolder.root.transform.localScale
    local dstScale = 0.3
    local sequence = self:create_sequence()
    local duration = 0.3
    
    sequence:Append(seatHolder.tributeCardHolder.pokerHolder.root.transform:DOMove(dstPos, duration, false))
    sequence:Join(seatHolder.tributeCardHolder.pokerHolder.root.transform:DOScale(dstScale, duration))
    sequence:OnComplete(function ()
        seatHolder.tributeCardHolder.pokerHolder.root.transform.position = srcPos
        seatHolder.tributeCardHolder.pokerHolder.root.transform.localScale = srcScale
        if(onFinish)then
            onFinish()
        end
    end)
end

--显示抗贡
function GuanDanTableView:showKangGongAnim(localSeatIndex, show, withAnim)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.tributeCardHolder.goKangGong, show or false)
end

--显示牌局信息
function GuanDanTableView:showRoundInfo(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goRoundInfo, show or false)
end

--显示主牌
function GuanDanTableView:showMajorCard(show, major_card_name)
    ModuleCache.ComponentUtil.SafeSetActive(self.textCurMainCard.gameObject, show or false)
    self.textCurMainCard.text = major_card_name
end

--显示敌友双反主牌
function GuanDanTableView:refreshTeamMajorCard(our_major_card_name, oppo_major_card_name)
    self.textOurMainCard.text = our_major_card_name
    self.textOppoMainCard.text = oppo_major_card_name
end

--刷新倍数
function GuanDanTableView:refreshMultiple(multiple)
    self.textRate.text = multiple
end

--显示同花顺按钮
function GuanDanTableView:showFlushStraightBtn(show, enable, gray)
    self:setGray(self.buttonSequence.gameObject, gray)
    self.buttonSequence.enabled = enable
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonSequence.gameObject, show or false)
end

--显示报警图标
function GuanDanTableView:showSeatWarningIcon(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.goEffect_Warning
    ModuleCache.ComponentUtil.SafeSetActive(go, show or false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageWarning.gameObject, show or false)
end

--刷新手牌数
function GuanDanTableView:refreshLeftHandCardCount(localSeatIndex, show, leftCount)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageLeftCard.gameObject, show or false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.textLeftCard.gameObject, show or false)
    if(show)then
        seatHolder.textLeftCard.text = leftCount
    end
end

--显示座位闹钟
function GuanDanTableView:showSeatClock(localSeatIndex, show, needShake)
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
    seatHolder.clockLeftSecs = 16
    seatHolder.textClock.text = seatHolder.clockLeftSecs - 1
    local timeEvent = self:subscibe_time_event(seatHolder.clockLeftSecs, false, 0):SetIntervalTime(1, function(t)
        if(seatHolder.clockLeftSecs > 0)then
            if(seatHolder.clockLeftSecs > 1 and seatHolder.clockLeftSecs <= 4)then
                tableSound:playTickSound()
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
function GuanDanTableView:showSeatSelected(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageHeadSelected.gameObject, show or false)
end

--显示排名标签
function GuanDanTableView:showRankTag(localSeatIndex, rank)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    for i=1,#seatHolder.goRankList do
        local goRank = seatHolder.goRankList[i]
        ModuleCache.ComponentUtil.SafeSetActive(goRank, rank == i)
    end
end

--播放出牌动画
function GuanDanTableView:playDispatchPokers(localSeatIndex, show,  codeList, logicCodeList, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    seatHolder.dispatchCardHolder.root:SetActive(show or false)
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
            local spriteName
            if(logicCodeList[i] and logicCodeList[i] ~= 0)then
                spriteName = self:getImageNameFromCode(logicCodeList[i])
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.star.gameObject, true)
            else
                spriteName = self:getImageNameFromCode(codeList[i])
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.star.gameObject, false)
            end
            
            pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
        end
    end

    if(withoutAnim)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    
    local sequence = self:create_sequence()
    local duration = 0.2
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
function GuanDanTableView:playSeatPassAnim(localSeatIndex, show, withoutAnim, onFinish)
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
function GuanDanTableView:showSeatHandPokers(seatInfo, show)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    ModuleCache.ComponentUtil.SafeSetActive(handPokerHolder.root, show or false)
end

--刷新座位手牌
function GuanDanTableView:refreshSeatHandPokers(seatInfo, codeList)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    for i=1,#handPokerHolder do
        local pokerHolder = handPokerHolder[i]
        ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
    end
    
    for i=1,#codeList do
        local code = codeList[i]
        local spriteName = self:getImageNameFromCode(code)
        local pokerHolder = handPokerHolder[i]
        ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, true)
        pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--显示选牌型界面
function GuanDanTableView:showSelectCardsPanel(show, codeList1, logicCodeList1, codeList2, logicCodeList2)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.selectCardsPanelHolder.root, show)
    if(not show)then
        ModuleCache.ComponentUtil.SafeSetActive(self.selectCardsPanelHolder.imageSelect.gameObject, show)
        return
    end
    for i=1,2 do
        local pokerHolderList = self.selectCardsPanelHolder.pokerHolderList1
        local codeList = codeList1
        local logicCodeList = logicCodeList1
        if(i ~= 1)then
            pokerHolderList = self.selectCardsPanelHolder.pokerHolderList2
            codeList = codeList2
            logicCodeList = logicCodeList2
        end

        for i=1,#pokerHolderList do
            local code = codeList[i]
            local pokerHolder = pokerHolderList[i]
            if(code)then
                local spriteName
                if(logicCodeList[i] and logicCodeList[i] ~= 0)then
                    spriteName = self:getImageNameFromCode(logicCodeList[i])
                    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.star.gameObject, true)
                else
                    spriteName = self:getImageNameFromCode(code)
                    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.star.gameObject, false)
                end
                
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, true)
                pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);    
            else
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
            end
        end 
    end
    

end

--显示交换座位信息
function GuanDanTableView:showChangeSeatInfoPanel(show, localSeatIndex1, localSeatIndex2)
    ModuleCache.ComponentUtil.SafeSetActive(self.goChangeSeatInfo, show or false)
    if(show)then
        local seatHolder1 = self.seatHolderArray[localSeatIndex1]
        local seatHolder2 = self.seatHolderArray[localSeatIndex2]
        self.changeSeatHolderList[1].imagePlayerHead.sprite = seatHolder1.imagePlayerHead.sprite
        self.changeSeatHolderList[1].textPlayerName.text = seatHolder1.textPlayerName.text
        self.changeSeatHolderList[2].imagePlayerHead.sprite = seatHolder2.imagePlayerHead.sprite
        self.changeSeatHolderList[2].textPlayerName.text = seatHolder2.textPlayerName.text
    end
end

--显示没有座位需要交换提示
function GuanDanTableView:showNoSeatChangePanel(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goNoSeatChangePanel, show or false)
end

--显示牌桌中央的明牌
function GuanDanTableView:showCenterMingPai(show, card)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCenterMingPai, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(card)
        self.imageCenterMingPaiFace.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--显示座位上的明牌
function GuanDanTableView:showSeatMingPaiMain(show, localSeatIndex, card)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local pokerHolder = seatHolder.mingPaiPokerHolerList[2]
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, show or false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goTagMingPai, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(card)
        pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

function GuanDanTableView:playSeatMingPaiSecond(show, localSeatIndex, card, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local pokerHolder = seatHolder.mingPaiPokerHolerList[1]
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(card)
        pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
        self:playCardTurnAnim(pokerHolder, true, 0.5, 0.5, function()
            self:subscibe_time_event(1, false, 0):OnComplete(function()
                if(onFinish)then
                    onFinish()
                end
            end)
        end)
    else
        if(onFinish)then
            onFinish()
        end
    end
end

function GuanDanTableView:playCardTurnAnim(pokerHolder, toFace, duration, delayTime, onFinish)
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

function GuanDanTableView:showCardBack(pokerHolder)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.back.gameObject, true)
end

function GuanDanTableView:showCardFace(pokerHolder)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.back.gameObject, false)
end

--显示明牌背景
function GuanDanTableView:showSeatMingPaiBg(show, localSeatIndex)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goMingPai, show or false)
end

--播放报警特效
function GuanDanTableView:playWarningEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local go = seatHolder.goEffect_Warning
    local duration = 2
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

--播放飞机特效
function GuanDanTableView:playFeiJiEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_feiji
    local duration = 1.5
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

--播放顺子特效
function GuanDanTableView:playShunZiEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_shunzi
    local duration = 2.2
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

--播放连对特效
function GuanDanTableView:playLianDuiEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_liandui
    local duration = 1.5
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

--播放炸弹特效
function GuanDanTableView:playZhaDanEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_zhadan
    local duration = 1
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

--播放同花顺特效
function GuanDanTableView:playTongHuaShunEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_tonghuashun
    local duration = 1
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

return  GuanDanTableView