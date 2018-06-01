--- 三公 table view
--- Created by 袁海洲
--- DateTime: 2017/11/17 11:32
-- -
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;

local class = require("lib.middleclass")
local View = require('package.public.module.table_poker.base_table_view')
local cardCommon = require('package.sangong.module.table.sangong_cardCommon')

--- @class TableSanGongView
local TableSanGongView = class('tableSanGongView', View);

local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath;
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;
local Instantiate = ModuleCache.ComponentUtil.InstantiateLocal;
local GameSDKInterface = ModuleCache.GameSDKInterface
local GameObject = UnityEngine.GameObject
local DOTween = DG.Tweening.DOTween

local table = table

function TableSanGongView:initialize(...)
    View.initialize(self, "sangong/module/table/sangong_table.prefab", "SanGong_Table", 0)

    self.packageName = 'sangong'
    self.moduleName = 'table'

    --- 背景
    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground1", ComponentTypeName.Image)
    -- self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)

    --- 开牌相关
    self.buttoKaiPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtoKaiPai", ComponentTypeName.Button)
    self.buttoCuoPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtoCuoPai", ComponentTypeName.Button)
    self.buttonLiangPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonLiangPai", ComponentTypeName.Button)

    --- 押注相关UI控件
    self.stake = GetComponentWithPath(self.root, "Stake", ComponentTypeName.Transform)
    self.stakeExOpr = GetComponentWithPath(self.root, "Stake/ExOpr", ComponentTypeName.Transform)
    self.exStakeSlider = GetComponentWithPath(self.root, "Stake/ExOpr/ExStakeSlider", ComponentTypeName.Slider)
    self.exStakeText = GetComponentWithPath(self.root, "Stake/ExOpr/ExStakeSlider/HandleSlideArea/Handle/Image/ExStakeText", ComponentTypeName.Text)
    self.exStakeUpBtn = GetComponentWithPath(self.root, "Stake/ExOpr/UpBtn", ComponentTypeName.Button)
    self.exStakeDownBtn = GetComponentWithPath(self.root, "Stake/ExOpr/DownBtn", ComponentTypeName.Button)

    self.exStakeSlider.onValueChanged:AddListener( function()
        self.exStakeText.text = tostring(self.exStakeSlider.value)
    end )

    self.okExStakeBtn = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/OkExStake", ComponentTypeName.Button)
    self.stakeBtn1 = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/1", ComponentTypeName.Button)
    self.stakeBtn1Text = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/1/Text", ComponentTypeName.Text)
    self.stakeBtn2 = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/2", ComponentTypeName.Button)
    self.stakeBtn2Text = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/2/Text", ComponentTypeName.Text)
    self.stakeBtn3 = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/3", ComponentTypeName.Button)
    self.stakeBtn3Text = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/3/Text", ComponentTypeName.Text)
    self.stakeBtn4 = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/4", ComponentTypeName.Button)
    self.stakeBtn4Text = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/4/Text", ComponentTypeName.Text)
    self.stakeBtn5 = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/5", ComponentTypeName.Button)
    self.stakeBtn5Text = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/5/Text", ComponentTypeName.Text)

    self.openExStakeBtn = GetComponentWithPath(self.root, "Stake/NoOpr/Btns/OpenExStake", ComponentTypeName.Button)

    --- 抢庄相关UI控件
    self.getBanker = GetComponentWithPath(self.root, "GetBanker", ComponentTypeName.Transform)
    self.noGetBankerBtn = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/No", ComponentTypeName.Button)
    self.getBankerBtn1 = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/1", ComponentTypeName.Button)
    self.getBankerBtn1Text = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/1/Text", ComponentTypeName.Text)
    self.getBankerBtn2 = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/2", ComponentTypeName.Button)
    self.getBankerBtn2Text = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/2/Text", ComponentTypeName.Text)
    self.getBankerBtn3 = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/3", ComponentTypeName.Button)
    self.getBankerBtn3Text = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/3/Text", ComponentTypeName.Text)
    self.getBankerBtn4 = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/4", ComponentTypeName.Button)
    self.getBankerBtn4Text = GetComponentWithPath(self.root, "GetBanker/OprBtns/Grid/4/Text", ComponentTypeName.Text)

    --- 搓牌相关
    self.dragCard = GetComponentWithPath(self.root, "DragCard", ComponentTypeName.Transform).gameObject
    self.dragPokerBack = GetComponentWithPath(self.root, "DragCard/back", ComponentTypeName.Transform).gameObject
    self.dragPokerImage = GetComponentWithPath(self.root, "DragCard/face", ComponentTypeName.Image)

    --- 卡牌图集
    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.smallCardAssetHolder = GetComponentWithPath(self.root, "Holder/SmallCardAssetHolder", "SpriteHolder")

    --- 自己手牌
    self.myHandPokersRoot = GetComponentWithPath(self.root, "Bottom/HandPokers", ComponentTypeName.Transform).gameObject
    self.myHandPokers = { }
    for i = 1, 3 do
        local poker = { }
        poker.root = GetComponentWithPath(self.root, "Bottom/HandPokers/" .. i, ComponentTypeName.Transform)
        poker.face = GetComponentWithPath(self.root, "Bottom/HandPokers/" .. i .. "/face", ComponentTypeName.Image)
        -- poker.back =  GetComponentWithPath(self.root,"Bottom/HandPokers/"..i.."/back", ComponentTypeName.Image)
        table.insert(self.myHandPokers, poker)
    end

    self.myCardTypeDis = { }
    self.myCardTypeDis.cardTypeObj = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeRoot = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeTextWrap = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/Text", "TextWrap")
    self.myCardTypeDis.cardTypeHei = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/Hei", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeLan = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/Lan", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeJin = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/Jin", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeHSG = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/HSG", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeXSG = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/XSG", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeDSG = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/DSG", ComponentTypeName.Transform).gameObject
    self.myCardTypeDis.cardTypeSZS = GetComponentWithPath(self.root, "Bottom/HandPokers/CardType/Root/SZS", ComponentTypeName.Transform).gameObject

    self.myGetBankerRateObj = GetComponentWithPath(self.root, "Bottom/GetBankerRateText", ComponentTypeName.Transform).gameObject
    self.myGetBankerRateRoot = GetComponentWithPath(self.root, "Bottom/GetBankerRateText/Root", ComponentTypeName.Transform).gameObject
    self.myGetBankerRateText = GetComponentWithPath(self.root, "Bottom/GetBankerRateText/Root/Text", "TextWrap")
    self.myGetBankerRateTag = GetComponentWithPath(self.root, "Bottom/GetBankerRateText/Root/Tag", ComponentTypeName.Transform).gameObject
    self.myGetBankerRateNoTag = GetComponentWithPath(self.root, "Bottom/GetBankerRateText/Root/NoTag", ComponentTypeName.Transform).gameObject

    self.buttonContinue = GetComponentWithPath(self.root, "Bottom/Action/ButtonContinue", ComponentTypeName.Button)
    self.buttonRule = GetComponentWithPath(self.root, "Top/TopInfo/ButtonRule", ComponentTypeName.Button)

    --- 总下注相关控件
    self.totalStakeObj = GetComponentWithPath(self.root, "TotalStake", ComponentTypeName.Transform).gameObject
    self.totalStakeText = GetComponentWithPath(self.root, "TotalStake/BG/TotalStakeText", ComponentTypeName.Text)

    --- 牌桌中间倒计时相关控件
    self.countDownObj = GetComponentWithPath(self.root, "CountDown", ComponentTypeName.Transform).gameObject
    self.countDownText = GetComponentWithPath(self.root, "CountDown/BG/CountDownText", ComponentTypeName.Text)

    --- 筹码动效果相关
    self.activeChip = { }
    self.chipRoot = GetComponentWithPath(self.root, "ChipRoot", ComponentTypeName.Transform).gameObject

    self.chip10 = GetComponentWithPath(self.root, "Holder/Chip_10", ComponentTypeName.Transform).gameObject
    self.chip5 = GetComponentWithPath(self.root, "Holder/Chip_5", ComponentTypeName.Transform).gameObject
    self.chip2 = GetComponentWithPath(self.root, "Holder/Chip_2", ComponentTypeName.Transform).gameObject
    self.chip1 = GetComponentWithPath(self.root, "Holder/Chip_1", ComponentTypeName.Transform).gameObject

    --- 拖动相关
    local gameRoot = GameObject.Find("GameRoot")
    self.uicamera = GetComponentWithPath(gameRoot, "Game/UIRoot/UICamera", "UnityEngine.Camera")

    --- 房间信息相关 Multiple
    self.roomInfoObj = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo", ComponentTypeName.Transform).gameObject
    self.multipleObj = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Multiple", ComponentTypeName.Transform).gameObject
    self.multipleText = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Multiple/Text", ComponentTypeName.Text)
    self.buttonHistory = GetComponentWithPath(self.root, "Top/TopInfo/ButtonHistory", ComponentTypeName.Button)

    --- 发牌相关控件
    self.dealPokers = { }
    self.dealRoot = GetComponentWithPath(self.root, "DealRoot", ComponentTypeName.Transform).gameObject
    self.dealPoker = GetComponentWithPath(self.root, "Holder/DealPoker", ComponentTypeName.Transform).gameObject

    -- 设置根节点
    self.settingRoot = GetComponentWithPath(self.root, "SettingRoot", ComponentTypeName.Transform).gameObject;
    self.settingRoot:SetActive(false);
    -- 设置遮罩
    self.spriteSettingMask = GetComponentWithPath(self.root, "SettingRoot/SpriteSettingMask", ComponentTypeName.Image);
    -- 离开房间按钮
    self.buttonLeaveRoom = GetComponentWithPath(self.root, "SettingRoot/Grid/ButtonLeaveRoom", ComponentTypeName.Button);
    -- 设置按钮
    self.buttonOtherSetting = GetComponentWithPath(self.root, "SettingRoot/Grid/ButtonOtherSetting", ComponentTypeName.Button);
    -- 玩法按钮
    self.buttonPlay = GetComponentWithPath(self.root, "SettingRoot/Grid/ButtonPlay", ComponentTypeName.Button);
    -- 设置返回按钮
    self.buttonSettingBack = GetComponentWithPath(self.root, "SettingRoot/ButtonSettingBack", ComponentTypeName.Button);
end

function TableSanGongView:get_world_pos(screenPos, z)
    return self.uicamera:ScreenToWorldPoint(Vector3.New(screenPos.x, screenPos.y, z))
end

function TableSanGongView:getTotalSeatCount()
    return 6
end

--- 控制下注界面
function TableSanGongView:ControlStakeObj(state, gameType)
    ModuleCache.ComponentUtil.SafeSetActive(self.stake.gameObject, state)
    self:ControlExStakeObj(false)
    if 1 == gameType then
        ModuleCache.ComponentUtil.SafeSetActive(self.openExStakeBtn.gameObject, false)
    else
        local baseScore = self.modelData.curTableData.roomInfo.ruleData.baseScore
        if 1 == baseScore then
            self.exStakeSlider.minValue = 1
            self.exStakeSlider.maxValue = 10
            self.exStakeSlider.value = 5
            ModuleCache.ComponentUtil.SafeSetActive(self.openExStakeBtn.gameObject, true)
        elseif 2 == baseScore then
            self.exStakeSlider.minValue = 2
            self.exStakeSlider.maxValue = 20
            self.exStakeSlider.value = 10
            ModuleCache.ComponentUtil.SafeSetActive(self.openExStakeBtn.gameObject, false)
        elseif 4 == baseScore then
            self.exStakeSlider.minValue = 4
            self.exStakeSlider.maxValue = 40
            self.exStakeSlider.value = 20
            ModuleCache.ComponentUtil.SafeSetActive(self.openExStakeBtn.gameObject, false)
        end
    end
end

function TableSanGongView:ControlExStakeObj(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.stakeExOpr.gameObject, state)
    ModuleCache.ComponentUtil.SafeSetActive(self.okExStakeBtn.gameObject, state)
end
--- 控制抢庄界面
function TableSanGongView:ControlGetBankerObj(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.getBanker.gameObject, state)
end
--- 控制搓牌界面
function TableSanGongView:ControlDragCardObj(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.dragCard.gameObject, state)
end
--- 控制开牌按钮
function TableSanGongView:ContorlShowCardBtn(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttoKaiPai.gameObject, state)
end
--- 控制搓牌按钮
function TableSanGongView:ContorlDragCardBtns(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttoCuoPai.gameObject, state)
end
--- 控制亮牌按钮
function TableSanGongView:ControlLiangPaiBtn(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonLiangPai.gameObject, state)
end

--- 控制总下注池界面
function TableSanGongView:ControlTotalStakeObj(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.totalStakeObj.gameObject, state)
end

--- 初始化玩家座位信息控件
function TableSanGongView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    seatHolder.inHandPokerRoot = GetComponentWithPath(seatRoot, "State/InHandPokers/", ComponentTypeName.Transform)
    seatHolder.inHandPokers = { }
    for i = 1, 3 do
        local poker = { }
        poker.root = GetComponentWithPath(seatRoot, "State/InHandPokers/" .. i, ComponentTypeName.Transform)
        poker.face = GetComponentWithPath(seatRoot, "State/InHandPokers/" .. i .. "/face", ComponentTypeName.Image)
        table.insert(seatHolder.inHandPokers, poker)
    end

    seatHolder.stakeInfoRoot = GetComponentWithPath(seatRoot, "State/Group/StakeInfo", ComponentTypeName.Transform)
    seatHolder.stakeBGImage = GetComponentWithPath(seatRoot, "State/Group/StakeInfo", ComponentTypeName.Image)
    seatHolder.stakeText = GetComponentWithPath(seatRoot, "State/Group/StakeInfo/Text", ComponentTypeName.Text)
    seatHolder.stakeCoinImage = GetComponentWithPath(seatRoot, "State/Group/StakeInfo/Image", ComponentTypeName.Image)
    seatHolder.stakeCoinImageOriginPos = seatHolder.stakeCoinImage.transform.position

    seatHolder.scoreChangeObj = GetComponentWithPath(seatRoot, "Info/ScoreChangeText", ComponentTypeName.Transform).gameObject
    seatHolder.scoreAddChangeText = GetComponentWithPath(seatRoot, "Info/ScoreChangeText/AddText", "TextWrap")
    seatHolder.scoreSubChangeText = GetComponentWithPath(seatRoot, "Info/ScoreChangeText/SubText", "TextWrap")
    seatHolder.scoreChangeObjOriginPos = seatHolder.scoreChangeObj.transform.position

    seatHolder.cardTypeObj = GetComponentWithPath(seatRoot, "State/CardType", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeRoot = GetComponentWithPath(seatRoot, "State/CardType/Root", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeTextWrap = GetComponentWithPath(seatRoot, "State/CardType/Root/Text", "TextWrap")
    seatHolder.cardTypeHei = GetComponentWithPath(seatRoot, "State/CardType/Root/Hei", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeLan = GetComponentWithPath(seatRoot, "State/CardType/Root/Lan", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeJin = GetComponentWithPath(seatRoot, "State/CardType/Root/Jin", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeHSG = GetComponentWithPath(seatRoot, "State/CardType/Root/HSG", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeXSG = GetComponentWithPath(seatRoot, "State/CardType/Root/XSG", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeDSG = GetComponentWithPath(seatRoot, "State/CardType/Root/DSG", ComponentTypeName.Transform).gameObject
    seatHolder.cardTypeSZS = GetComponentWithPath(seatRoot, "State/CardType/Root/SZS", ComponentTypeName.Transform).gameObject

    seatHolder.kickBtn = GetComponentWithPath(seatRoot, "Info/KickBtn", ComponentTypeName.Transform).gameObject

    seatHolder.state1Tag = GetComponentWithPath(seatRoot, "Info/State1Tag", ComponentTypeName.Transform).gameObject
    seatHolder.state2Tag = GetComponentWithPath(seatRoot, "Info/State2Tag", ComponentTypeName.Transform).gameObject
    seatHolder.state3Tag = GetComponentWithPath(seatRoot, "Info/State3Tag", ComponentTypeName.Transform).gameObject


    seatHolder.getBankerRateObj = GetComponentWithPath(seatRoot, "State/GetBankerRateText", ComponentTypeName.Transform).gameObject
    seatHolder.getBankerRateRoot = GetComponentWithPath(seatRoot, "State/GetBankerRateText/Root", ComponentTypeName.Transform).gameObject
    seatHolder.getBankerRateText = GetComponentWithPath(seatRoot, "State/GetBankerRateText/Root/Text", "TextWrap")
    seatHolder.getBankerRateTag = GetComponentWithPath(seatRoot, "State/GetBankerRateText/Root/Tag", ComponentTypeName.Transform).gameObject
    seatHolder.getBankerRateNoTag = GetComponentWithPath(seatRoot, "State/GetBankerRateText/Root/NoTag", ComponentTypeName.Transform).gameObject

    seatHolder.bankerRandomTag = GetComponentWithPath(seatRoot, "Info/BankerRandomTag", ComponentTypeName.Transform).gameObject
    seatHolder.bankerRandomImage1 = GetComponentWithPath(seatRoot, "Info/BankerRandomTag/Image1", ComponentTypeName.Image)
    seatHolder.bankerRandomImage2 = GetComponentWithPath(seatRoot, "Info/BankerRandomTag/Image2", ComponentTypeName.Image)
    seatHolder.bankerAni = GetComponentWithPath(seatRoot, "Info/EffectBanker", "UIImageAnimation")

    if 1 == index then
        -- 自己的座位
        -- 关闭自己头像旁边的牌显示
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.inHandPokerRoot.gameObject, false)
        seatHolder.textPlayerName.fontSize = 25
    end
end
--- 刷新玩家座位信息
function TableSanGongView:refreshSeatPlayerInfo(seatInfo, localSeatIndex)
    View.refreshSeatPlayerInfo(self, seatInfo, localSeatIndex)
    -- 调用基类
    localSeatIndex = localSeatIndex or seatInfo.localSeatIndex
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local realCardCount = self:fillHandCards(seatInfo.cards, seatHolder.inHandPokers)
    seatHolder.stakeText.text = tostring(seatInfo.stake)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.stakeInfoRoot.gameObject, seatInfo.stake > 0)
    seatHolder.textScore.text = tostring(seatInfo.score)
    -- 积分

    if 1 == localSeatIndex--- 剔除自己
        or realCardCount < 3 then
        --- 剔除没有牌型的
        self:proceeCardTypeDis(seatHolder, nil)
        --- 处理牌型标记显示
    else
        self:proceeCardTypeDis(seatHolder, seatInfo.cardType)
        --- 处理牌型标记显示
    end

    --- 刷新踢人按钮状态
    local roomInfo = self.modelData.curTableData.roomInfo
    ----TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
    if self.modelData.roleData.RoomType == 2 then
        if not seatInfo.isOffline then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.kickBtn,
            tonumber(roomInfo.curRoundNum) == 0 and not seatInfo.isCreator and roomInfo.mySeatInfo.isCreator
            )
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.kickBtn, tonumber(roomInfo.curRoundNum) == 0)
        end
    else
        if not roomInfo.isRoomStarted
            and not seatInfo.isCreator
            and roomInfo.mySeatInfo.isCreator then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.kickBtn, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.kickBtn, false)
        end
    end

    --- 开局后不显示空位的问号图标
    if roomInfo.isRoomStarted then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)
    end
    --- 处理准备标志状态
    if 1 ~= localSeatIndex then
        local xOffset = seatHolder.imageReady.transform.anchoredPosition.x
        local yOffset = seatHolder.imageReady.transform.anchoredPosition.y
        xOffset = seatHolder.stakeInfoRoot.gameObject.activeSelf and 225 or 80
        yOffset = seatHolder.kickBtn.gameObject.activeSelf and 0 or 45
        seatHolder.imageReady.transform.anchoredPosition = Vector3.New(xOffset, yOffset, 0)
    end
    --- 自由抢庄玩法不显示房主图标
    local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
    if 2 == gameType and self.modelData.roleData.RoomType ~= 2 then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, false)
    end

    if not seatInfo.isBanker then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.bankerRandomTag.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.bankerAni.gameObject, false)
    end

    --- 刷新玩家状态标志
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state1Tag, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state2Tag, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state3Tag, false)
    local roomState = self.modelData.curTableData.roomInfo.state
    if 0 == seatInfo.state then
    elseif 2 == seatInfo.state and 2 == roomState then
        -- todo:显示下注标记
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state1Tag, true)
        if 2 == gameType and seatInfo.isBanker then
            --- 自由抢庄模式下，庄家不能下注
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state1Tag, false)
        end
    elseif 1 == seatInfo.state and 1 == roomState then
        -- todo:显示抢庄标记
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state2Tag, true)
    elseif 3 == seatInfo.state and 3 == roomState then
        -- todo:显示开牌标记
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.state3Tag, true)
    elseif 4 == seatInfo.state then

    end
end
--- 刷新我的手牌
function TableSanGongView:refreshMyHandCard(cards, cardType)
    if not cards then
        cards = { }
    end
    local realCardCount = self:fillHandCards(cards, self.myHandPokers)
    if realCardCount >= 3 then
        self:proceeCardTypeDis(self.myCardTypeDis, cardType)
    else
        self:proceeCardTypeDis(self.myCardTypeDis, nil)
    end
end
--- 显示我的手牌控件
function TableSanGongView:ControlMyHandCard(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.myHandPokersRoot, state)
end

--- 填充手牌信息
--- 返回实际拥有的有效手牌数
function TableSanGongView:fillHandCards(cards, inHandPokers)
    local cardNum = #cards
    local realCardCount = 0
    for i = 1, 3 do
        if i > cardNum then
            ModuleCache.ComponentUtil.SafeSetActive(inHandPokers[i].root.gameObject, false)
        else
            ModuleCache.ComponentUtil.SafeSetActive(inHandPokers[i].root.gameObject, true)
            -- ModuleCache.ComponentUtil.SafeSetActive(inHandPokers[i].face.gameObject,true)
            if 0 ~= cards[i] then
                realCardCount = realCardCount + 1
            end
            local spriteName = cardCommon:getImageNameFromCode(cards[i])
            inHandPokers[i].face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName)
        end
    end
    return realCardCount
end
--- 播放玩家座位下注动效`
function TableSanGongView:playSeatStakeAni(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    if seatHolder.isPlayStakeAni then
        return
        --- 正在播放
    end
    seatHolder.isPlayStakeAni = true
    seatHolder.stakeText.color = Color.New(seatHolder.stakeText.color.r, seatHolder.stakeText.color.g, seatHolder.stakeText.color.b, 0)
    seatHolder.stakeCoinImage.transform.position = seatHolder.seatRoot.transform.position
    seatHolder.stakeBGImage.color = Color.New(seatHolder.stakeBGImage.color.r, seatHolder.stakeBGImage.color.g, seatHolder.stakeBGImage.color.b, 0)
    seatHolder.stakeCoinImage.transform:DOMove(seatHolder.stakeCoinImageOriginPos, 0.5):SetEase(DG.Tweening.Ease.OutSine):OnComplete( function()
        seatHolder.stakeBGImage.color = Color.New(seatHolder.stakeBGImage.color.r, seatHolder.stakeBGImage.color.g, seatHolder.stakeBGImage.color.b, 1)
        seatHolder.stakeText.color = Color.New(seatHolder.stakeText.color.r, seatHolder.stakeText.color.g, seatHolder.stakeText.color.b, 1)
        seatHolder.isPlayStakeAni = false
    end )
end
--- 播放玩家分数变动动效，并展示
function TableSanGongView:playScoreChangeAni(seatInfo, changeValue)
    changeValue = changeValue or 0
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local rootT = seatHolder.scoreChangeObj.transform
    seatHolder.scoreAddChangeText.text = ""
    seatHolder.scoreSubChangeText.text = ""
    if changeValue >= 0 then
        seatHolder.scoreAddChangeText.text = "+" .. changeValue
    elseif changeValue < 0 then
        seatHolder.scoreSubChangeText.text = "" .. changeValue
    end
    rootT.transform.position = seatHolder.scoreChangeObjOriginPos
    rootT:DOLocalMoveY(84, 0.5):SetEase(DG.Tweening.Ease.OutBounce):OnComplete( function()
        self:subscibe_time_event(4, false, 1):OnComplete( function()
            self:hideyScoreChangeDis(seatInfo)
        end )
    end )
end
--- 隐藏分数变动展示
function TableSanGongView:hideyScoreChangeDis(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    seatHolder.scoreAddChangeText.text = ""
    seatHolder.scoreSubChangeText.text = ""
end
--- 播放翻牌
--- formCode 反转前的牌面
--- toCode 反转后的牌面
--- callback 播放完毕后的回调
function TableSanGongView:playRotateCard(poker, formCode, toCode, callback)
    local formSpriteName = cardCommon:getImageNameFromCode(formCode)
    local toSpriteName = cardCommon:getImageNameFromCode(toCode)
    poker.face.sprite = self.cardAssetHolder:FindSpriteByName(formSpriteName)
    poker.face.transform:DORotate(Vector3.New(0, 90, 0), 0.15):OnComplete( function()
        poker.face.sprite = self.cardAssetHolder:FindSpriteByName(toSpriteName)
        poker.face.transform.localEulerAngles = Vector3.New(0, 270, 0)
        poker.face.transform:DORotate(Vector3.New(0, 360, 0), 0.15):OnComplete( function()
            poker.face.transform.localEulerAngles = Vector3.New(0, 0, 0)
            if callback then
                callback()
            end
        end )
    end )
end

--- 发牌到玩家
--- cardIndex 发到第几张牌
--- 返回发的牌的GameObject
function TableSanGongView:playDealCardToPlayerAni(inHandPokers, cardIndex, time, callback)
    local poker = inHandPokers[cardIndex]
    if poker then
        local dealPoker = self:poorDeactiveDealPoker()
        dealPoker.transform.position = self.dealRoot.transform.position
        dealPoker.transform:DOMove(poker.root.transform.position, time):SetEase(DG.Tweening.Ease.OutSine):OnComplete( function()
            ModuleCache.ComponentUtil.SafeSetActive(dealPoker, false)
            if callback and "function" == type(callback) then
                callback()
            end
        end )
        return dealPoker
    end
end
--- 获得可用的发牌用poker
function TableSanGongView:poorDeactiveDealPoker()
    local dealPoker = nil
    for i = 1, self.dealRoot.transform.childCount do
        local child = self.dealRoot.transform:GetChild(i - 1)
        if child
            and(not child.gameObject.activeSelf) then
            dealPoker = child.gameObject
            break
        end
    end
    if not dealPoker then
        dealPoker = ModuleCache.ComponentUtil.InstantiateLocal(self.dealPoker, self.dealRoot)
    end
    dealPoker.transform.localScale = self.dealPoker.transform.localScale
    ModuleCache.ComponentUtil.SafeSetActive(dealPoker, true)
    return dealPoker
end
--- 展示抢庄倍数
function TableSanGongView:playGetBankerRateAni(seatInfo, rate)
    rate = rate or 0
    if seatInfo.playerId == self.modelData.curTableData.roomInfo.mySeatInfo.playerId then
        if rate > 0 then
            ModuleCache.ComponentUtil.SafeSetActive(self.myGetBankerRateTag, true)
            ModuleCache.ComponentUtil.SafeSetActive(self.myGetBankerRateNoTag, false)
            self.myGetBankerRateText.text = "x" .. rate
        else
            self.myGetBankerRateText.text = ""
            ModuleCache.ComponentUtil.SafeSetActive(self.myGetBankerRateTag, false)
            ModuleCache.ComponentUtil.SafeSetActive(self.myGetBankerRateNoTag, true)
        end
        ModuleCache.ComponentUtil.SafeSetActive(self.myGetBankerRateObj, true)
        self.myGetBankerRateRoot.transform.localScale = Vector3.New(0.5, 0.5, 0.5)
        self.myGetBankerRateRoot.transform:DOScale(Vector3.New(0.82, 0.82, 0.82), 0.15):SetEase(DG.Tweening.Ease.OutBounce):OnComplete( function()

        end )
    else
        local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
        if rate > 0 then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.getBankerRateTag, true)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.getBankerRateNoTag, false)
            seatHolder.getBankerRateText.text = "x" .. rate

        else
            seatHolder.getBankerRateText.text = ""
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.getBankerRateTag, false)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.getBankerRateNoTag, true)
        end
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.getBankerRateObj, true)
        seatHolder.getBankerRateRoot.transform.localScale = Vector3.New(0.5, 0.5, 0.5)
        seatHolder.getBankerRateRoot.transform:DOScale(Vector3.New(0.82, 0.82, 0.82), 0.15):SetEase(DG.Tweening.Ease.OutBounce):OnComplete( function()

        end )
    end
end
--- 隐藏抢庄倍数展示
function TableSanGongView:HideGetBankerRateDis(seatInfo)
    if seatInfo.playerId == self.modelData.curTableData.roomInfo.mySeatInfo.playerId then
        ModuleCache.ComponentUtil.SafeSetActive(self.myGetBankerRateObj, false)
    else
        local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.getBankerRateObj, false)
    end
end

--- 播放抢庄随机庄家动画
--- seatInfoList 需要进行随庄动效的玩家seatinfo
function TableSanGongView:playRandomBankerAni(seatInfoList, bankerid, callback)
    local totalDuration = 2
    local count = #seatInfoList
    local totalCount = 0
    local bankerSeatInfo = nil
    for i = 1, #seatInfoList do
        if (seatInfoList[i].playerId == bankerid) then
            totalCount = i + count * 2
            bankerSeatInfo = seatInfoList[i]
        end
    end
    while (totalCount < 6 * 2) do
        totalCount = totalCount + count
    end
    local duration2 = totalDuration /(6 + totalCount)
    local duration1 = 2 * duration2
    local index = 1
    local showEffect
    showEffect = function(i, isFirstRound)
        local curSeatInfo = seatInfoList[i]
        local seatHolder = self.seatHolderArray[curSeatInfo.localSeatIndex]
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.bankerRandomTag.gameObject, true)
        local assetName = "sangong/sound/random_banker_sound.bytes"
        ModuleCache.SoundManager.play_sound("sangong", assetName, "random_banker_sound")
        self:subscibe_time_event((isFirstRound and duration1) or duration2, false, 0):OnComplete( function(t)
            ModuleCache.SoundManager.stop_sound("sangong", assetName, "random_banker_sound")
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.bankerRandomTag.gameObject, false)
            if (index == totalCount) then
                if (callback) then
                    callback(bankerSeatInfo)
                end
            else
                if (i == count) then
                    i = 1
                else
                    i = i + 1
                end
                index = index + 1
                showEffect(i, index < 6)
            end
        end )
    end
    showEffect(1, true)
end

--- 播放庄家特效
function TableSanGongView:playBankerEffect(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.bankerAni.gameObject, true)
    seatHolder.bankerAni:Play(0)
    self:subscibe_time_event(0.7, false, 1):OnComplete( function()
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.bankerAni.gameObject, false)
    end )
end

--- 重置玩家座位信息控件
function TableSanGongView:resetSeatHolderArray(seatCount)
    View.resetSeatHolderArray(self, seatCount)
    -- 调用基类
end
--- 初始化各种操作按钮
function TableSanGongView:initStakeOprBtns(gameType)
    -- 初始化押注按钮
    if gameType == 1 then
        self.stakeBtn1.name = "20"
        self.stakeBtn1Text.text = "20分"
        self.stakeBtn2.name = "40"
        self.stakeBtn2Text.text = "40分"
        self.stakeBtn3.name = "60"
        self.stakeBtn3Text.text = "60分"
        self.stakeBtn4.name = "80"
        self.stakeBtn4Text.text = "80分"
        self.stakeBtn5.name = "100"
        self.stakeBtn5Text.text = "100分"
    elseif gameType == 2 then
        local baseScore = self.modelData.curTableData.roomInfo.ruleData.baseScore
        if 1 == baseScore then
            self.stakeBtn1.name = "1"
            self.stakeBtn1Text.text = "1分"
            self.stakeBtn2.name = "2"
            self.stakeBtn2Text.text = "2分"
            self.stakeBtn3.name = "3"
            self.stakeBtn3Text.text = "3分"
            self.stakeBtn4.name = "4"
            self.stakeBtn4Text.text = "4分"
            self.stakeBtn5.name = "5"
            self.stakeBtn5Text.text = "5分"
        elseif 2 == baseScore then
            self.stakeBtn1.name = "2"
            self.stakeBtn1Text.text = "2分"
            self.stakeBtn2.name = "4"
            self.stakeBtn2Text.text = "4分"
            self.stakeBtn3.name = "6"
            self.stakeBtn3Text.text = "6分"
            self.stakeBtn4.name = "8"
            self.stakeBtn4Text.text = "8分"
            self.stakeBtn5.name = "10"
            self.stakeBtn5Text.text = "10分"
        elseif 4 == baseScore then
            self.stakeBtn1.name = "4"
            self.stakeBtn1Text.text = "4分"
            self.stakeBtn2.name = "8"
            self.stakeBtn2Text.text = "8分"
            self.stakeBtn3.name = "12"
            self.stakeBtn3Text.text = "12分"
            self.stakeBtn4.name = "16"
            self.stakeBtn4Text.text = "16分"
            self.stakeBtn5.name = "20"
            self.stakeBtn5Text.text = "20分"
        end
    end
end
--- 设置房间信息
function TableSanGongView:setRoomInfo(roomInfo)
    local ruledesc = roomInfo.ruleDesc
    local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
    if 1 == gameType then
        -- multipleObj
        -- self.roomInfoObj.transform.anchoredPosition = Vector3.New(0,self.roomInfoObj.transform.anchoredPosition.y,0)
        -- self.textRoundNum.transform.anchoredPosition = Vector3.New(82,self.textRoundNum.transform.anchoredPosition.y,0)
        ModuleCache.ComponentUtil.SafeSetActive(self.multipleObj, false)
        roomInfo.ruleDesc = "自由下注 "
    elseif 2 == gameType then
        -- self.roomInfoObj.transform.anchoredPosition = Vector3.New(-60,self.roomInfoObj.transform.anchoredPosition.y,0)
        -- self.textRoundNum.transform.anchoredPosition = Vector3.New(0,self.textRoundNum.transform.anchoredPosition.y,0)
        ModuleCache.ComponentUtil.SafeSetActive(self.multipleObj, true)
        self.multipleText.text = "无庄"
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            if seatInfo.isBanker then
                self.multipleText.text = tostring(seatInfo.bankerRate) .. "倍"
                break
            end
        end
        roomInfo.ruleDesc = "自由抢庄 "
    end
    View.setRoomInfo(self, roomInfo)
    roomInfo.ruleDesc = ruledesc
end
--- 控制继续按钮
function TableSanGongView:ContorlContinueBtn(state)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonContinue.gameObject, state)
end

--- 显示倒计时
function TableSanGongView:ShowTiming(time, text, oncomplate)
    if not time or 0 > time then
        return
    end
    text = text or ""
    self:HideTiming()
    local timingInfo = { }
    timingInfo.leftTime = time
    timingInfo.text = text
    self.centerTimingId = self:subscibe_time_event(time, false, 1):OnUpdate( function(t)
        t = t.surplusTimeRound
        timingInfo.leftTime = t
        self.countDownText.text = timingInfo.text .. " " .. t .. "s"
        if t <= 5 then
            --- 最后五秒倒计时播放声音
            ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/daojishi.bytes", "daojishi")
        end
    end ):OnComplete( function(t)
        self:HideTiming()
        if oncomplate then
            oncomplate()
        end
    end ).id
    ModuleCache.ComponentUtil.SafeSetActive(self.countDownObj, true)
    self.curTimingInfo = timingInfo
end
--- 隐藏倒计时
function TableSanGongView:HideTiming()
    if self.centerTimingId then
        CSmartTimer:Kill(self.centerTimingId)
        self.centerTimingId = nil
    end
    self.curTimingInfo = nil
    ModuleCache.ComponentUtil.SafeSetActive(self.countDownObj, false)
end

--- 丢筹码到桌子中间
function TableSanGongView:ThorwChip(seatInfo, num)

    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]

    local info = self:processChipType(num)

    local _10Count = info._10Count
    local _5Count = info._5Count
    local _2Count = info._2Count
    local _1Count = info._1Count

    local chips = { }
    --- 创建10的筹码
    for i = 1, _10Count do
        local _10chip = self:poorDeactiveChip(10)
        table.insert(chips, _10chip)
    end
    --- 创建5的筹码
    for i = 1, _5Count do
        local _5chip = self:poorDeactiveChip(5)
        table.insert(chips, _5chip)
    end
    --- 创建2的筹码
    for i = 1, _2Count do
        local _2chip = self:poorDeactiveChip(2)
        table.insert(chips, _2chip)
    end
    --- 创建1的筹码
    for i = 1, _1Count do
        local _1chip = self:poorDeactiveChip(1)
        table.insert(chips, _1chip)
    end

    math.randomseed(os.time())
    for i = 1, #chips do
        local chip = chips[i]
        local pos = self.chipRoot.transform.position + Vector3.New(math.random(-1, 1) * math.random() * 0.3, math.random(-1, 1) * math.random() * 0.3, 0)
        chip.transform.position = seatHolder.seatRoot.transform.position
        ModuleCache.ComponentUtil.SafeSetActive(chip, true)
        chip.transform:DOMove(pos, 0.7):SetEase(DG.Tweening.Ease.OutSine):OnComplete( function()

        end )
        table.insert(self.activeChip, chip)
    end
    ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/coin_change.bytes", "coin_change")
end
--- 收筹码从桌子中间到玩家
function TableSanGongView:GetChip(seatInfo, num)

    local left = num % 10
    local _10Count =(num - left) / 10
    num = left
    left = num % 5
    local _5Count =(num - left) / 5

    num = left
    left = num % 2
    local _2Count =(num - left) / 2
    local _1Count = left

    local chips = { }

    local name = "Chip_10"
    for j = 1, _10Count do
        for i = 1, #self.activeChip do
            local chip = self.activeChip[i]
            if name == chip.name then
                table.insert(chips, chip)
                table.remove(self.activeChip, i)
                break
            end
        end
    end
    name = "Chip_5"
    for j = 1, _5Count do
        for i = 1, #self.activeChip do
            local chip = self.activeChip[i]
            if name == chip.name then
                table.insert(chips, chip)
                table.remove(self.activeChip, i)
                break
            end
        end
    end
    name = "Chip_2"
    for j = 1, _2Count do
        for i = 1, #self.activeChip do
            local chip = self.activeChip[i]
            if name == chip.name then
                table.insert(chips, chip)
                table.remove(self.activeChip, i)
                break
            end
        end
    end
    name = "Chip_1"
    for j = 1, _1Count do
        for i = 1, #self.activeChip do
            local chip = self.activeChip[i]
            if name == chip.name then
                table.insert(chips, chip)
                table.remove(self.activeChip, i)
                break
            end
        end
    end

    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    for i = 1, #chips do
        local chip = chips[i]
        local pos = seatHolder.seatRoot.transform.position
        chip.transform:DOMove(pos, 0.7):SetEase(DG.Tweening.Ease.OutSine):OnComplete( function()
            ModuleCache.ComponentUtil.SafeSetActive(chip, false)
        end )
    end
    ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/coin_change.bytes", "coin_change")
end
--- 筹码从一个玩家飞向另外一个玩家
function TableSanGongView:ThorwChipToPlayer(seatInfo1, seatInfo2, num)

    local info = self:processChipType(num)

    local _10Count = info._10Count
    local _5Count = info._5Count
    local _2Count = info._2Count
    local _1Count = info._1Count

    local chips = { }
    --- 创建10的筹码
    for i = 1, _10Count do
        local _10chip = self:poorDeactiveChip(10)
        table.insert(chips, _10chip)
    end
    --- 创建5的筹码
    for i = 1, _5Count do
        local _5chip = self:poorDeactiveChip(5)
        table.insert(chips, _5chip)
    end
    --- 创建2的筹码
    for i = 1, _2Count do
        local _2chip = self:poorDeactiveChip(2)
        table.insert(chips, _2chip)
    end
    --- 创建1的筹码
    for i = 1, _1Count do
        local _1chip = self:poorDeactiveChip(1)
        table.insert(chips, _1chip)
    end

    local seatHolder1 = self.seatHolderArray[seatInfo1.localSeatIndex]
    local seatHolder2 = self.seatHolderArray[seatInfo2.localSeatIndex]

    math.randomseed(os.time())
    for i = 1, #chips do
        local chip = chips[i]
        local pos = seatHolder2.seatRoot.transform.position + Vector3.New(math.random(-1, 1) * math.random() * 0.05, math.random(-1, 1) * math.random() * 0.05, 0)
        chip.transform.position = seatHolder1.seatRoot.transform.position
        ModuleCache.ComponentUtil.SafeSetActive(chip, true)
        chip.transform:DOMove(pos, 0.7):SetEase(DG.Tweening.Ease.OutSine):OnComplete( function()
            ModuleCache.ComponentUtil.SafeSetActive(chip, false)
        end )
        table.insert(self.activeChip, chip)
    end
    ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/coin_change.bytes", "coin_change")
end
--- 获得可用的筹码
function TableSanGongView:poorDeactiveChip(type)
    local name = "Chip_" .. type
    local chip = nil
    for i = 1, self.chipRoot.transform.childCount do
        local child = self.chipRoot.transform:GetChild(i - 1)
        if child
            and(not child.gameObject.activeSelf)
            and name == child.name then
            chip = child.gameObject
            break
        end
    end
    if not chip then
        if 1 == type then
            chip = ModuleCache.ComponentUtil.InstantiateLocal(self.chip1, self.chipRoot)
        elseif 2 == type then
            chip = ModuleCache.ComponentUtil.InstantiateLocal(self.chip2, self.chipRoot)
        elseif 5 == type then
            chip = ModuleCache.ComponentUtil.InstantiateLocal(self.chip5, self.chipRoot)
        elseif 10 == type then
            chip = ModuleCache.ComponentUtil.InstantiateLocal(self.chip10, self.chipRoot)
        end
        chip.transform.localScale = Vector3.New(0.7, 0.7, 0.7)
        chip.name = name
    end
    ModuleCache.ComponentUtil.SafeSetActive(chip, true)
    return chip
end
--- 将一个数随机处理成某种筹码的组合类型
function TableSanGongView:processChipType(num)
    local info = { }
    info._10Count = 0
    info._5Count = 0
    info._2Count = 0
    info._1Count = 0

    local randomCount = 1
    if num > 10 then
        randomCount =(num -(num % 10)) / 10 + 1
    end

    local left = num
    for i = 1, randomCount do
        if left >= 10 then
            local randomNum = math.random(1, 100)
            if randomNum > 90 then
                info._1Count = info._1Count + 10
            elseif randomNum > 80 then
                info._2Count = info._2Count + 5
            elseif randomNum > 60 then
                info._5Count = info._5Count + 1
                info._2Count = info._2Count + 1
                info._1Count = info._1Count + 1
            elseif randomNum > 30 then
                info._5Count = info._5Count + 2
            elseif randomNum > 0 then
                info._10Count = info._10Count + 1
            end
            left = left - 10
        else
            local temp = left
            left = temp % 5
            info._5Count = info._5Count +(temp - left) / 5

            temp = left
            left = temp % 2
            info._2Count = info._2Count +(temp - left) / 2

            info._1Count = info._1Count + left
        end
    end
    return info
end

--- 处理牌型显示
function TableSanGongView:proceeCardTypeDis(seatHolder, cardType)
    cardType = cardType or -1

    seatHolder.cardTypeTextWrap.text = ""
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeHei, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeLan, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeJin, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeHSG, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeXSG, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeDSG, false)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeSZS, false)

    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeObj, -1 ~= cardType)
    if - 1 == cardType then
        return
    end

    if cardType < 10 then
        seatHolder.cardTypeTextWrap.text = tostring(cardType)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeHei, 0 == cardType)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeLan, 0 < cardType and cardType < 8)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeJin, 7 < cardType and cardType < 10)
    elseif 10 == cardType then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeHSG, true)
    elseif 11 == cardType then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeXSG, true)
    elseif 12 == cardType then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeDSG, true)
    elseif 13 == cardType then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.cardTypeSZS, true)
    end
end

--- 播放牌型音效
function TableSanGongView:PlayCardTypeSound(CardType, seatInfo)
    if CardType > 9 then
        CardType = "sangong"
    end
    local sex = 1
    if seatInfo and seatInfo.playerInfo and seatInfo.playerInfo.gender then
        sex = seatInfo.playerInfo.gender
    end
    local path = "sangong/sound/man/"
    local tyepName = "man_" .. CardType
    if 1 ~= sex then
        path = "sangong/sound/woman/"
        tyepName = "woman_" .. CardType
    end
    local assetName = path .. tyepName .. ".bytes"
    ModuleCache.SoundManager.play_sound("sangong", assetName, tyepName)
end

--- 播放抢庄声音
function TableSanGongView:playGetBankerSound(seatInfo, rate)
    local soundName = "bank0"
    if rate > 0 then
        soundName = "bank1"
    end
    local sex = 1
    if seatInfo and seatInfo.playerInfo and seatInfo.playerInfo.gender then
        sex = seatInfo.playerInfo.gender
    end
    local tyepName = "male_" .. soundName
    if 1 ~= sex then
        tyepName = "female_" .. soundName
    end
    local assetName = "sangong/sound/" .. tyepName .. ".bytes"
    ModuleCache.SoundManager.play_sound("sangong", assetName, tyepName)
end

--- 重置搓牌底牌
function TableSanGongView:ResetDragPoker(card)
    local spriteName = cardCommon:getImageNameFromCode(card)
    self.dragPokerImage.sprite = self.cardAssetHolder:FindSpriteByName(spriteName)
    self.dragPokerBack.transform.anchoredPosition = Vector3.New(21, 8, 0)
end

return TableSanGongView