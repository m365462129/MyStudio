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
local View = require('core.mvvm.view_base')
local GuanDanTableVideoView = class('guanDanTableVideoView', View)

local cardCommon = require('package.guandan.module.guandan_table.gamelogic_common')

local tableSound = require('package.guandan.module.guandan_table.table_sound')

function GuanDanTableVideoView:initialize(...)
    View.initialize(self, "guandan/module/table/guandan_table_video.prefab", "GuanDan_Table_Video", 1)
    self.GetComponentWithPath = GetComponentWithPath
    self.imageBg = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image)
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoundNum/Text", ComponentTypeName.Text)

    self.textOurMainCard = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/MainCard/TextOurCard", ComponentTypeName.Text)
    self.textOppoMainCard = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/MainCard/TextOppoCard", ComponentTypeName.Text)
    self.textCurMainCard = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Rate/TextCurMainCard", ComponentTypeName.Text)
    self.textRate = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Rate/TextRate", ComponentTypeName.Text)

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

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.myCardAssetHolder = GetComponentWithPath(self.root, "Holder/MyCardAssetHolder", "SpriteHolder")
    self.prefabPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker", ComponentTypeName.Transform).gameObject
    self:initAllSeatHolders()
end

function GuanDanTableVideoView:initAllSeatHolders()
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
        tributeCardHolder.goKangGong = GetComponentWithPath(tributeCardHolder.root, "Image", ComponentTypeName.Image)
        local pokerHolder = {}
        pokerHolder.root = GetComponentWithPath(tributeCardHolder.root, "Poker", ComponentTypeName.Transform).gameObject
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image)
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image)
        tributeCardHolder.pokerHolder = pokerHolder
        self.tributeCardHolderList[i] = tributeCardHolder
    end

    self.goMingPai = GetComponentWithPath(self.root, "Bottom/MingPai", ComponentTypeName.Transform).gameObject

    self.uiStateSwitcherSeatPrefab = self.GetComponentWithPath(self.root, "Holder/Seat", ComponentTypeName.Transform)
    self.srcSeatHolderArray = {}
    for i=1,4 do
        local seatHolder = {}
        local seatPosTran = self.GetComponentWithPath(self.root, "Seats/" .. i, ComponentTypeName.Transform)
        local goSeat = ModuleCache.ComponentUtil.InstantiateLocal(self.uiStateSwitcherSeatPrefab.gameObject, seatPosTran.gameObject)   
        self:initSeatHolder(seatHolder, goSeat, i)
        self.srcSeatHolderArray[i] = seatHolder
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, false)   
    end
end

function GuanDanTableVideoView:resetSeatHolderArray(seatCount)
	local newSeatHolderArray = {}
	local seatHolderArray = self.srcSeatHolderArray
    newSeatHolderArray = seatHolderArray

	for i,v in ipairs(seatHolderArray) do
		ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, false)   
	end
	for i,v in ipairs(newSeatHolderArray) do
		ModuleCache.ComponentUtil.SafeSetActive(v.seatRoot, true)   
	end
	self.seatHolderArray = newSeatHolderArray
end

function GuanDanTableVideoView:initSeatHolder(seatHolder, seatRoot, index)
    local root = seatRoot
    seatHolder.seatRoot = seatRoot
    seatHolder.buttonNotSeatDown = GetComponentWithPath(root, "NotSeatDown", ComponentTypeName.Button)  
    seatHolder.goSeatInfo = GetComponentWithPath(root, "Info", ComponentTypeName.Transform).gameObject     
    seatHolder.uiStateSwitcher = ModuleCache.ComponentManager.GetComponent(root,"UIStateSwitcher")
    ModuleCache.TransformUtil.SetX(seatHolder.uiStateSwitcher.transform, 0, true)
    ModuleCache.TransformUtil.SetY(seatHolder.uiStateSwitcher.transform, 0, true)  

    seatHolder.imagePlayerHead = GetComponentWithPath(root, "Info/Avatar/Mask/Image", ComponentTypeName.Image) 
    seatHolder.textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)
    seatHolder.textScore =  GetComponentWithPath(root, "Info/Point/Text", ComponentTypeName.Text)
    seatHolder.imageDisconnect =  GetComponentWithPath(root, "Info/ImageStateDisconnect", ComponentTypeName.Image)
    seatHolder.imageTemporaryLeave = GetComponentWithPath(root, "Info/ImageStateTemporaryLeave", ComponentTypeName.Image)    --暂时离开
    seatHolder.imageReady = GetComponentWithPath(root, "State/Group/ImageReady", ComponentTypeName.Image)
    seatHolder.imageBanker = GetComponentWithPath(root, "Info/ImageBanker", ComponentTypeName.Image)
    seatHolder.imageCreator = GetComponentWithPath(root, "Info/ImageCreator", ComponentTypeName.Image)   
    seatHolder.goSpeakIcon =  GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Transform).gameObject
    self.defaultHeadSprite = seatHolder.imagePlayerHead.sprite
    seatHolder.emojiGoArray = {}
    for i=1,20 do
        seatHolder.emojiGoArray[i] = GetComponentWithPath(root, "State/Group/ChatFace/" .. (i - 1), ComponentTypeName.Transform).gameObject
    end

    seatHolder.handPokerHolder = {}
    if index == 1 then
       seatHolder.uiStateSwitcher:SwitchState("Bottom")
        local animSelectBankerHorizontal = GetComponentWithPath(root, "Info/EffectHorizontal", ComponentTypeName.Image)           
        seatHolder.animSelectBanker = animSelectBankerHorizontal
        seatHolder.handPokerHolder.root = GetComponentWithPath(root, "State/Bottom_InHandPokers", ComponentTypeName.Transform).gameObject
        seatHolder.cardAssetHolder = self.cardAssetHolder
    elseif index == 2 then
       seatHolder.uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
       seatHolder.handPokerHolder.root = GetComponentWithPath(root, "State/Right_InHandPokers", ComponentTypeName.Transform).gameObject
       seatHolder.cardAssetHolder = self.myCardAssetHolder
    elseif index == 3 then
       seatHolder.uiStateSwitcher:SwitchState("Top")
       seatHolder.handPokerHolder.root = GetComponentWithPath(root, "State/Top_InHandPokers", ComponentTypeName.Transform).gameObject
       seatHolder.cardAssetHolder = self.cardAssetHolder
    elseif index == 4 then        
       seatHolder.uiStateSwitcher:SwitchState("Left")
       seatHolder.handPokerHolder.root = GetComponentWithPath(root, "State/Left_InHandPokers", ComponentTypeName.Transform).gameObject
       seatHolder.cardAssetHolder = self.myCardAssetHolder
    end
    
    seatHolder.imagePass = GetComponentWithPath(root, "State/Group/PassIcon/image", ComponentTypeName.Image)
    seatHolder.imageWarning = GetComponentWithPath(root, "State/Group/ImageWarning", ComponentTypeName.Image)
    seatHolder.goEffect_Warning = GetComponentWithPath(root, "State/Group/ImageWarning/Ainm_Baojing", ComponentTypeName.Transform).gameObject
    seatHolder.imageLeftCard = GetComponentWithPath(root, "State/Group/LeftCard", ComponentTypeName.Image)
    seatHolder.textLeftCard = GetComponentWithPath(seatHolder.imageLeftCard.gameObject, "Text", ComponentTypeName.Text)

    seatHolder.imageClock = GetComponentWithPath(root, "State/Group/Clock", ComponentTypeName.Image)
    seatHolder.textClock = GetComponentWithPath(root, "State/Group/Clock/Text", "TextWrap")

    seatHolder.goRankList = {}
    for i=1,4 do
        seatHolder.goRankList[i] = GetComponentWithPath(root, "State/Group/Rank/" .. i, ComponentTypeName.Transform).gameObject
    end

    seatHolder.dispatchCardHolder = self.dispatchCardHolderList[index]
    seatHolder.dispatchCardEffectHolder = self.dispatchCardEffectHolderList[index]
    seatHolder.tributeCardHolder = self.tributeCardHolderList[index]

    local prefabPoker = GetComponentWithPath(seatHolder.handPokerHolder.root, "Poker", ComponentTypeName.Transform).gameObject
    for i=1,28 do
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

end

function GuanDanTableVideoView:getImageNameFromCode(code, majorCardLevel)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function GuanDanTableVideoView:getImageNameFromCard(card, majorCardLevel)
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


--刷新座位玩家信息
function GuanDanTableVideoView:refreshSeatPlayerInfo(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    seatHolder.textScore.text = seatInfo.score
    if(seatInfo.playerId and (seatInfo.playerId ~= 0 and seatInfo.playerId ~= "0")) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, seatInfo.isCreator or false)
        if(seatInfo.playerInfo)then
            self:setPlayerInfo(seatHolder, seatInfo.playerInfo)
        else
            self:get_userinfo(seatInfo.playerId, function(err, data)
                if(err)then
                    self:refreshSeatPlayerInfo(seatInfo)
                    return
                end
                local playerInfo = seatInfo.playerInfo or {}
                playerInfo.playerId = seatInfo.playerId
                playerInfo.userId = data.userId
		        playerInfo.playerName = data.nickname
                playerInfo.nickname = data.nickname
		        playerInfo.headUrl = data.headImg
                playerInfo.headImg = data.headImg
                playerInfo.gender = data.gender
                playerInfo.score = data.score
                playerInfo.ip = data.ip
                seatInfo.playerInfo = playerInfo
                seatInfo.gender = data.gender
                if(seatInfo.on_get_userinfo_callback_queue)then
                    local cb = seatInfo.on_get_userinfo_callback_queue:shift()
                    while cb do
                        cb(seatInfo)
                        cb = seatInfo.on_get_userinfo_callback_queue:shift()
                    end
                end
                if(seatInfo.chatDataSeatHolder)then
                    seatInfo.chatDataSeatHolder.playerInfo = playerInfo
                end
                self:setPlayerInfo(seatHolder, seatInfo.playerInfo)
            end)
        end
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, true)
    end
end

function GuanDanTableVideoView:setPlayerInfo(seatHolder, playerInfo)
    if(playerInfo.playerId ~= 0)then
        seatHolder.textPlayerName.text = Util.filterPlayerName(playerInfo.playerName)
        if(playerInfo.hasDownHead)then
            if(playerInfo.spriteHeadImage)then
                seatHolder.imagePlayerHead.sprite = playerInfo.spriteHeadImage
            end
            return
        end
        seatHolder.imagePlayerHead.sprite = self.defaultHeadSprite
        self:startDownLoadHeadIcon(seatHolder.imagePlayerHead, playerInfo.headUrl, function (sprite )
            playerInfo.hasDownHead = true
            playerInfo.spriteHeadImage = sprite
        end)
        
    else
        seatHolder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
end

--下载头像
function GuanDanTableVideoView:startDownLoadHeadIcon(targetImage, url, callback)    
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            print('error down load '.. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(err.error, 'http') == 1 then 
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

function GuanDanTableVideoView:get_userinfo(playerId, callback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = playerId,
        },
        cacheDataKey = "user/info?uid=" .. playerId
    }

    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end, function(error)
        print(error.error)
        callback(error.error, nil)
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then    --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end)

end


--播放交换座位动画
function GuanDanTableVideoView:playChangeSeatPosAnim(localSeatIndex1, localSeatIndex2, onFinish)
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

--显示上贡的牌
function GuanDanTableVideoView:showTributeCard(localSeatIndex, show, code)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.tributeCardHolder.pokerHolder.root, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(code)
        seatHolder.tributeCardHolder.pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--播放交换贡牌动画
function GuanDanTableVideoView:playChangeTributeCardAnim(localSeatIndex1, localSeatIndex2, onFinish)
    local seatHolder1 = self.seatHolderArray[localSeatIndex1]
    local seatHolder2 = self.seatHolderArray[localSeatIndex2]
    local srcPos1 = seatHolder1.tributeCardHolder.pokerHolder.root.transform.position
    local srcPos2 = seatHolder2.tributeCardHolder.pokerHolder.root.transform.position
    local sequence = self:create_sequence()
    local duration = 0.5 * 1
    
    sequence:Append(seatHolder1.tributeCardHolder.pokerHolder.root.transform:DOMove(srcPos2, duration, false))
    sequence:OnComplete(function ()
        seatHolder1.tributeCardHolder.pokerHolder.root.transform.localPosition = UnityEngine.Vector3.zero
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放贡牌飞到玩家头像上的动画
function GuanDanTableVideoView:playTributeCardFly2Head(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local srcPos = seatHolder.tributeCardHolder.pokerHolder.root.transform.position
    local dstPos = seatHolder.imagePlayerHead.transform.position
    local srcScale = seatHolder.tributeCardHolder.pokerHolder.root.transform.localScale
    local dstScale = 0.3
    local sequence = self:create_sequence()
    local duration = 0.3 * 1
    
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
function GuanDanTableVideoView:showKangGongAnim(localSeatIndex, show, withAnim)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.tributeCardHolder.goKangGong.gameObject, show or false)
end

--显示主牌
function GuanDanTableVideoView:showMajorCard(show, major_card_name)
    ModuleCache.ComponentUtil.SafeSetActive(self.textCurMainCard.gameObject, show or false)
    self.textCurMainCard.text = major_card_name
end

--显示敌友双反主牌
function GuanDanTableVideoView:refreshTeamMajorCard(our_major_card_name, oppo_major_card_name)
    self.textOurMainCard.text = our_major_card_name
    self.textOppoMainCard.text = oppo_major_card_name
end

--刷新倍数
function GuanDanTableVideoView:refreshMultiple(multiple)
    self.textRate.text = multiple
end

--显示牌桌中央的明牌
function GuanDanTableVideoView:showCenterMingPai(show, card)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCenterMingPai, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(card)
        self.imageCenterMingPaiFace.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--显示明牌背景
function GuanDanTableVideoView:showSeatMingPaiBg(show, localSeatIndex)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goMingPai, show or false)
end

--显示座位上的明牌
function GuanDanTableVideoView:showSeatMingPaiMain(show, localSeatIndex, card)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local pokerHolder = seatHolder.mingPaiPokerHolerList[2]
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, show or false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goTagMingPai, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(card)
        pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

function GuanDanTableVideoView:playSeatMingPaiSecond(show, localSeatIndex, card, withoutAnim)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local pokerHolder = seatHolder.mingPaiPokerHolerList[1]
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, show or false)
    if(show)then
        local spriteName = self:getImageNameFromCode(card)
        pokerHolder.face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName);
        if(withoutAnim)then
            return
        end
        self:playCardTurnAnim(pokerHolder, true, 0.13, 0.13, function()
        end)
    end
end

--显示交换座位信息
function GuanDanTableVideoView:showChangeSeatInfoPanel(show, localSeatIndex1, localSeatIndex2)
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
function GuanDanTableVideoView:showNoSeatChangePanel(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goNoSeatChangePanel, show or false)
end


function GuanDanTableVideoView:playCardTurnAnim(pokerHolder, toFace, duration, delayTime, onFinish)
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


function GuanDanTableVideoView:showCardBack(pokerHolder)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.back.gameObject, true)
end

function GuanDanTableVideoView:showCardFace(pokerHolder)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.back.gameObject, false)
end

--显示排名标签
function GuanDanTableVideoView:showRankTag(localSeatIndex, rank)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    for i=1,#seatHolder.goRankList do
        local goRank = seatHolder.goRankList[i]
        ModuleCache.ComponentUtil.SafeSetActive(goRank, rank == i)
    end
end

--播放出牌动画
function GuanDanTableVideoView:playDispatchPokers(localSeatIndex, show,  codeList, logicCodeList, withoutAnim, onFinish)
    
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
function GuanDanTableVideoView:playSeatPassAnim(localSeatIndex, show, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imagePass.transform.parent.gameObject, show or false)
    if(not show)then
        return
    end
    if(withoutAnim)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    
    local sequence = self:create_sequence()
    local duration = 0.2
    local srcScale = 0.5
    --print(localSeatIndex, seatHolder.imagePass.transform.parent.parent.parent.parent.parent.name)
    seatHolder.imagePass.transform.localScale = UnityEngine.Vector3.one * srcScale
    sequence:Append(seatHolder.imagePass.transform:DOScale(1, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

--显示座位手牌
function GuanDanTableVideoView:showSeatHandPokers(seatInfo, show)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    ModuleCache.ComponentUtil.SafeSetActive(handPokerHolder.root, show or false)
end

--刷新座位手牌
function GuanDanTableVideoView:refreshSeatHandPokers(seatInfo, codeList)
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
        pokerHolder.face.sprite = seatHolder.cardAssetHolder:FindSpriteByName(spriteName);
    end
end

--播放飞机特效
function GuanDanTableVideoView:playFeiJiEffect(seatInfo)
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
function GuanDanTableVideoView:playShunZiEffect(seatInfo)
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
function GuanDanTableVideoView:playLianDuiEffect(seatInfo)
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
function GuanDanTableVideoView:playZhaDanEffect(seatInfo)
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
function GuanDanTableVideoView:playTongHuaShunEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local dispatchCardEffectHolder = seatHolder.dispatchCardEffectHolder
    local go = dispatchCardEffectHolder.goEffect_tonghuashun
    local duration = 1
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end


function GuanDanTableVideoView:setRoomInfo(roomNum, curRoundNum, totalRoundCount)
    self.textRoomNum.text = "房号:" .. roomNum
    self.textRoundNum.text = "(第" .. curRoundNum .. "/" .. totalRoundCount .. "局)"
    self.textRoundNum.gameObject:SetActive(true)
end
return  GuanDanTableVideoView