local AppData = AppData
local BranchPackageName = AppData.BranchZhaJinHuaName
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance

local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
---@class tableView
local TableView_ZhaJinHua = class('tableView', View)
---@type TableHelper TableHelper
local TableHelper = require(string.format("package/%s/module/table_zhajinhua/table_zhajinhua_helper", BranchPackageName))
local Sequence = DG.Tweening.DOTween.Sequence
local GameSDKInterface = ModuleCache.GameSDKInterface
local ZjhLogic = require(string.format("package.%s.module.table_zhajinhua.zjh_logic", BranchPackageName))
local CardCommon = require "package/zhajinhua/module/table_zhajinhua/gamelogic_common"

function TableView_ZhaJinHua:initialize(...)

    View.initialize(self, string.format("%s/module/table/zhajinhua_table.prefab", BranchPackageName), "ZhaJinHua_Table", 0)
    -- View.set_1080p(self)
    self.TestBtnReconnection = GetComponentWithPath(self.root, "TopLeft/TestBtnReconnection", ComponentTypeName.Button)
    if (not ModuleCache.GameManager.developmentMode) then
        ModuleCache.ComponentUtil.SafeSetActive(self.TestBtnReconnection.gameObject, false)
    end

    self.ComparePokerSelectRoot = GetComponentWithPath(self.root,"Center/ComparePokerSelectRoot", ComponentTypeName.Transform).gameObject
    self:SetState_ComparePokerSelectRoot(false)
    self.ComparePokerSelectTime = GetComponentWithPath(self.root,"Center/ComparePokerSelectRoot/Time", ComponentTypeName.Text)
    self.MyWinEffectRoot = GetComponentWithPath(self.root,"Bottom/HandPokers/MyWinEffectRoot", ComponentTypeName.Transform).gameObject
    self:SetState_MyWinEffectRoot(false)
    self.EffectRanShaoRoot = GetComponentWithPath(self.root, "EffectRanShaoRoot", ComponentTypeName.Transform).gameObject
    self:SetState_EffectRanShaoRoot(false)
    self.BtnLeftOpen = GetComponentWithPath(self.root,"TopLeft/NewUI/BtnLeftOpen", ComponentTypeName.Button)
    self.BtnLeftClose = GetComponentWithPath(self.root,"TopLeft/NewUI/LeftRoot/BtnLeftClose", ComponentTypeName.Button)
    self.LeftRoot = GetComponentWithPath(self.root, "TopLeft/NewUI/LeftRoot", ComponentTypeName.Transform).gameObject
    self:SetState_LeftRoot(false)
    self.BtnShopRoot = GetComponentWithPath(self.root,"TopLeft/NewUI/TopLeftBtns/BtnShopRoot", ComponentTypeName.Transform).gameObject
    self.ButtonShop = GetComponentWithPath(self.root,"TopLeft/NewUI/TopLeftBtns/BtnShopRoot/ButtonShop", ComponentTypeName.Button)
    self.BtnActivityRoot = GetComponentWithPath(self.root,"TopLeft/NewUI/TopLeftBtns/BtnActivityRoot", ComponentTypeName.Transform).gameObject
    self.BtnActivity = GetComponentWithPath(self.root,"TopLeft/NewUI/TopLeftBtns/BtnActivityRoot/BtnActivity", ComponentTypeName.Button)
    self.ActivityRedPoint = GetComponentWithPath(self.root,"TopLeft/NewUI/TopLeftBtns/BtnActivityRoot/BtnActivity/ActivityRedPoint", ComponentTypeName.Transform).gameObject
    self:SetState_BtnActivityRoot(false)
    self.WaitOthersReadyRoot = GetComponentWithPath(self.root, "Center/WaitOthersReadyRoot", ComponentTypeName.Transform).gameObject
    self:SetState_WaitOthersReadyRoot(false)
    self.ButtonReplaceTableText = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonReplaceTableGray/Text", ComponentTypeName.Text)
    self.TipsServiceFeeRoot = GetComponentWithPath(self.root, "Center/TipsServiceFee", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.TipsServiceFeeRoot.gameObject, false)
    self.TipsServiceFeeText = GetComponentWithPath(self.root, "Center/TipsServiceFee/Text", ComponentTypeName.Text)
    self.CoinMatchCountdownRoot = GetComponentWithPath(self.root, "Center/CoinMatchCountdown", ComponentTypeName.Transform).gameObject
    self.CoinMatchCountdownText = GetComponentWithPath(self.root, "Center/CoinMatchCountdown/Image/Text", "TextWrap")
    self:SetCoinCountdownState(false)
    self.JinBiChangMatchRoot = GetComponentWithPath(self.root, "TopLeft/NewUI/LeftRoot/Bg/JinBiChangMatch", ComponentTypeName.Transform).gameObject
    self.ButtonJinBiChangExit = GetComponentWithPath(self.root,"TopLeft/NewUI/LeftRoot/Bg/JinBiChangMatch/ButtonJinBiChangExit", ComponentTypeName.Button)
    self.ButtonRuleExplain = GetComponentWithPath(self.root,"TopLeft/NewUI/LeftRoot/Bg/JinBiChangMatch/ButtonRuleExplain", ComponentTypeName.Button)
    self.buttonSetting = GetComponentWithPath(self.root,"TopLeft/NewUI/LeftRoot/Bg/JinBiChangMatch/ButtonSettings", ComponentTypeName.Button)
    self.ButtonRule = GetComponentWithPath(self.root,"TopRight/TopRoot/ButtonRule", ComponentTypeName.Button)
    self.ButtonReplaceTable = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonReplaceTable", ComponentTypeName.Button)
    self.ButtonReady = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonReady", ComponentTypeName.Button)
    self.ButtonReadyTime = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonReady/Time", ComponentTypeName.Text)

    --TODO XLQ:亲友圈快速组局没有自动准备 需要手动点击准备
    self.buttonReady_museum =  GetComponentWithPath(self.root, "Bottom/Action/ButtonReady", ComponentTypeName.Button)

    self.tableBackgroundSprite = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image).sprite
    self:bindButtons()
    self.buttonLocation = GetComponentWithPath(self.root,"TopRight/TopRoot/ButtonLocation", ComponentTypeName.Button)
    self.buttonMic = GetComponentWithPath(self.root, "Bottom/Action/ButtonMic", ComponentTypeName.Button)
    self.goSpeaking = GetComponentWithPath(self.root, "Speaking", ComponentTypeName.Transform).gameObject
    self.goCancelSpeaking = GetComponentWithPath(self.root, "CancelRecord", ComponentTypeName.Transform).gameObject

    self.buttonChat = GetComponentWithPath(self.root, "Bottom/Action/ButtonChat", ComponentTypeName.Button)
    self.sliderBattery = GetComponentWithPath(self.root, "TopRight/TopRoot/Battery", ComponentTypeName.Slider)
    self.imageBatteryCharging = GetComponentWithPath(self.sliderBattery.gameObject, "ImageCharging", ComponentTypeName.Image)
    self.textPingValue = GetComponentWithPath(self.root, "TopRight/TopRoot/PingVal", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "TopRight/TopRoot/Time/Text", ComponentTypeName.Text)
    self.goWifiStateArray = {}
    for i = 1, 5 do
        local goState = GetComponentWithPath(self.root,"TopRight/TopRoot/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end

    self.goGState2G = GetComponentWithPath(self.root, "TopRight/TopRoot/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "TopRight/TopRoot/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "TopRight/TopRoot/GState/4g", ComponentTypeName.Transform).gameObject

    self.RoomIDRoot = GetComponentWithPath(self.root,"TopRight/TopRoot/RoomID", ComponentTypeName.Transform).gameObject
    self.textRoomNum = GetComponentWithPath(self.RoomIDRoot, "Text", ComponentTypeName.Text)
    self.RoomInfoRoot = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo", ComponentTypeName.Transform).gameObject
    self.textRoomRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Text", ComponentTypeName.Text)

    self.textCenterTips = GetComponentWithPath(self.root, "Center/Tips/Text", ComponentTypeName.Text)

    self.goNiuPoint = GetComponentWithPath(self.root, "Bottom/HandPokers/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.goNiuPoint.gameObject, false)
    self.imageNiuPoint = GetComponentWithPath(self.goNiuPoint, "num", ComponentTypeName.Image)
    self.JinHuaTypeName = GetComponentWithPath(self.goNiuPoint, "TypeName", ComponentTypeName.Text)

    self.uiStateSwitcherSeatPrefab = GetComponentWithPath(self.root, "Holder/Seat", "UIStateSwitcher")
    ModuleCache.ComponentUtil.SafeSetActive(self.uiStateSwitcherSeatPrefab.gameObject, false)

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.zhajinhuaAssetHolder = GetComponentWithPath(self.root, "Holder/ZhaJinHuaAssetHolder", "SpriteHolder")
    self.goTmpBankerPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpBankerPos", ComponentTypeName.Transform).gameObject
    self.goTmpPokerHeapPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpPokerHeapPos", ComponentTypeName.Transform).gameObject

    self.textRoundNum = GetComponentWithPath(self.root, "Center/RoundNum/Text", ComponentTypeName.Text)
    self.goCurRoundBetScore = GetComponentWithPath(self.root, "Center/RoundBetScore", ComponentTypeName.Transform).gameObject
    self.textCurRoundBetScore = GetComponentWithPath(self.goCurRoundBetScore, "Text", ComponentTypeName.Text)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCurRoundBetScore, false)



    --牌堆范围
    self.goldHeapRect = {}
    self.goldHeapRect.tranLeftTop = GetComponentWithPath(self.root, "Center/BetGoldAreaLeftTopPos", ComponentTypeName.Transform)
    self.goldHeapRect.tranLeftBottom = GetComponentWithPath(self.root, "Center/BetGoldAreaLeftBottomPos", ComponentTypeName.Transform)
    self.goldHeapRect.tranRightTop = GetComponentWithPath(self.root, "Center/BetGoldAreaRightTopPos", ComponentTypeName.Transform)
    self.goldHeapRect.tranRightBottom = GetComponentWithPath(self.root, "Center/BetGoldAreaRightBottomPos", ComponentTypeName.Transform)

    self.holderGolds = {}
    self.holderGolds.root = GetComponentWithPath(self.root, "Center/golds", ComponentTypeName.Transform).gameObject


    --比牌特效
    self.PokerPKRoot = GetComponentWithPath(self.root,"PokerPKRoot", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.PokerPKRoot.gameObject, false)
    self.PKAnimRoot = GetComponentWithPath(self.root,"PokerPKRoot/PokerContrast/PKAnimRoot", ComponentTypeName.Transform).gameObject
    self.PK_Left_Win_Go = GetComponentWithPath(self.root,"PokerPKRoot/PokerContrast/PKAnimRoot/PK_Left_Win", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.PK_Left_Win_Go.gameObject, false)
    self.PK_Left_Win_Animator = GetComponentWithPath(self.root,"PokerPKRoot/PokerContrast/PKAnimRoot/PK_Left_Win", "UnityEngine.Animator")
    self.PK_Right_Win_Go = GetComponentWithPath(self.root,"PokerPKRoot/PokerContrast/PKAnimRoot/PK_Right_Win", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.PK_Right_Win_Go.gameObject, false)
    self.PK_Right_Win_Animator = GetComponentWithPath(self.root,"PokerPKRoot/PokerContrast/PKAnimRoot/PK_Right_Win", "UnityEngine.Animator")


    self.goMask = GetComponentWithPath(self.root, "mask", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect = {}
    self.holderConstrastEffect.goRoot = GetComponentWithPath(self.root, "PokerContrast", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.goAnimator = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/Animator", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.goLeftBoom = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/leftBoom", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.goRightBoom = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/rightBoom", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.animatorZhaDan = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/Zhadan", "UnityEngine.Animator")
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, false)
    self.PokerContrastRoot = GetComponentWithPath(self.root, "PokerContrastRoot", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.leftCardsRoot = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/HeadRoot/HeadL", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.leftLostEffect = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/HeadRoot/HeadL/Head/LostEffect", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.leftCardsRootPos = self.holderConstrastEffect.leftCardsRoot.transform.position
    self.holderConstrastEffect.rightCardsRoot = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/HeadRoot/HeadR", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect.rightCardsRootPos = self.holderConstrastEffect.rightCardsRoot.transform.position
    self.holderConstrastEffect.rightLostEffect = GetComponentWithPath(self.root, "PokerContrast/PokerContrast/HeadRoot/HeadR/Head/LostEffect", ComponentTypeName.Transform).gameObject

    local selfHandPokerRoot = GetComponentWithPath(self.root, "Bottom/HandPokers", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(selfHandPokerRoot.gameObject, false)
    self.srcSeatHolderArray = {}
    local localSeatIndex = 1
    for i = 1, 6 do
        local seatHolder = {}
        seatHolder.seatHolderIndex = i
        local seatPosTran = GetComponentWithPath(self.root, "Center/Seats/" .. i, ComponentTypeName.Transform)
        local goSeat = ModuleCache.ComponentUtil.InstantiateLocal(self.uiStateSwitcherSeatPrefab.gameObject, seatPosTran.gameObject)
        seatHolder.pokerAssetHolder = self.cardAssetHolder
        seatHolder.zhajinhuaAssetHolder = self.zhajinhuaAssetHolder

        if (i == 1) then
            TableHelper:initSeatHolder(seatHolder, i, goSeat, selfHandPokerRoot)
            seatHolder.goNiuPoint = self.goNiuPoint
            seatHolder.imageNiuPoint = self.imageNiuPoint
            seatHolder.JinHuaTypeName = self.JinHuaTypeName
            seatHolder.StateHasCheck = GetComponentWithPath(self.root, "Bottom/HandPokers/StateRoot/StateHasCheck", ComponentTypeName.Transform).gameObject
            seatHolder.StateDrop = GetComponentWithPath(self.root, "Bottom/HandPokers/StateRoot/StateDrop", ComponentTypeName.Transform).gameObject
            seatHolder.StateCompareFail = GetComponentWithPath(self.root, "Bottom/HandPokers/StateRoot/StateCompareFail", ComponentTypeName.Transform).gameObject
            seatHolder.goCostScore = GetComponentWithPath(self.root, "Bottom/Action/CostScore", ComponentTypeName.Transform).gameObject
            seatHolder.textCostScore = GetComponentWithPath(seatHolder.goCostScore, "cost/CostText", ComponentTypeName.Text)
        else
            TableHelper:initSeatHolder(seatHolder, i, goSeat, nil)
        end
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goNiuPoint.gameObject, false)
        TableHelper:refreshSeatInfo(seatHolder, {})      --初始化
        seatHolder.goTmpBankerPos = self.goTmpBankerPos
        seatHolder.goTmpPokerHeapPos = self.goTmpPokerHeapPos   --牌堆位置
        self.srcSeatHolderArray[i] = seatHolder
    end

    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        ModuleCache.ComponentManager.Find(self.root, "Bottom/Action/StateSwitcher/ButtonInviteFriend"):SetActive(false)
    end
end

function TableView_ZhaJinHua:bindButtons()
    self.buttonInvite = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonInviteFriend", ComponentTypeName.Button)
    self.buttonContinue = GetComponentWithPath(self.root, "Bottom/Action/ButtonContinue", ComponentTypeName.Button)
    self.textContinueLimitTime = GetComponentWithPath(self.buttonContinue.gameObject, "Text", ComponentTypeName.Text)
    self.buttonStart = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonStart", ComponentTypeName.Button)
    self.buttonExit = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonExit", ComponentTypeName.Button)

    self.goZhaJinNiuBtnsRoot = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.goZhaJinNiuBtnsRoot.gameObject, false)
    self.BtnXuePin = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BtnXuePin", ComponentTypeName.Button)
    self.BtnXuePinPos = self.BtnXuePin.transform.position
    self.BtnXuePinText = GetComponentWithPath(self.BtnXuePin.gameObject, "Text", ComponentTypeName.Text)
    self.BtnXuePinFollow = GetComponentWithPath(self.root,"Bottom/Action/ZhaJinNiu/BetBtns/BtnXuePinFollow", ComponentTypeName.Button)
    self.BtnXuePinFollowText = GetComponentWithPath(self.BtnXuePinFollow.gameObject, "Text", ComponentTypeName.Text)
    self.BtnDropPokerUIStateSwitcher = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonDrop", "UIStateSwitcher")
    self.buttonDropPoker = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonDrop", ComponentTypeName.Button)
    self.BtnDropPos = self.buttonDropPoker.transform.position
    self.BtnCompareUIStateSwitcher = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonCompare", "UIStateSwitcher")
    self.buttonComparePoker = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonCompare", ComponentTypeName.Button)
    self.BtnComparePokerPos = self.buttonComparePoker.transform.position
    self.ButtonCompareText = GetComponentWithPath(self.buttonComparePoker.gameObject, "Text", ComponentTypeName.Text)
    self.BtnCompareText2 = GetComponentWithPath(self.buttonComparePoker.gameObject, "Text2", ComponentTypeName.Text)
    self.ButtonCheck = GetComponentWithPath(self.root, "Bottom/HandPokers/ButtonCheck", ComponentTypeName.Button)
    self.ActionCenterPos = self.ButtonCheck.gameObject.transform.position
    self.toggleFollowAlways = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/ToggleFollowAlways", ComponentTypeName.Toggle)
    self.FollowAlwaysPos = self.toggleFollowAlways.transform.position
    self.toggleFollowAlwaysValue = GetComponentWithPath(self.toggleFollowAlways.gameObject, "Text", ComponentTypeName.Text)
    self.toggleFollowAlwaysInstructionsLable = GetComponentWithPath(self.toggleFollowAlways.gameObject, "Instructions/Lable", ComponentTypeName.Text)
    self.buttonFollow = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/ButtonFollow", ComponentTypeName.Button)
    self.BtnFollowPos = self.buttonFollow.transform.position
    self.textFollowValue = GetComponentWithPath(self.buttonFollow.gameObject, "Text", ComponentTypeName.Text)

    self.AddBetRoot = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/AddBetRoot", ComponentTypeName.Transform).gameObject
    self:SetState_AddBetRoot(false)
    self.AddBetRootBtnClose = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/AddBetRoot/AddBetRootBtnClose", ComponentTypeName.Button)
    self.AddBetBtnList = {}
    for i = 1, 10 do
        local AddBetBtn = GetComponentWithPath(self.AddBetRoot, "More/"..i, ComponentTypeName.Button)
        table.insert(self.AddBetBtnList, AddBetBtn)
    end

    self.goldPrefabList = {}
    for i = 1, 4 do
        local locGoldPrefab = GetComponentWithPath(self.root, "Center/goldPrefab"..i, ComponentTypeName.Transform).gameObject
        table.insert(self.goldPrefabList,locGoldPrefab)
    end
    self.GoldBullionPrefab = GetComponentWithPath(self.root, "Center/GoldBullionPrefab", ComponentTypeName.Transform).gameObject

    self.BtnAddUIStateSwitcher = GetComponentWithPath(self.root,"Bottom/Action/ZhaJinNiu/BetBtns/BtnAdd", "UIStateSwitcher")
    self.BtnAdd = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/BtnAdd", ComponentTypeName.Button)
    self.BtnAddPos = self.BtnAdd.transform.position
    self.Viewport = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/ScrollRect/Viewport", ComponentTypeName.Transform).gameObject
    self.goMoreBtns = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/ScrollRect/Viewport/More", ComponentTypeName.Transform).gameObject

    self.switcher = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher", "UIStateSwitcher");
    self.JinBiChangStateSwitcher = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher", "UIStateSwitcher")
    self:SetJinBiChangStateSwitcher(false)
end


function TableView_ZhaJinHua:setRoomInfo(roomInfo)
    local TopCerterShowStr =  ""
    if (self:isJinBiChang()) then
        TopCerterShowStr = "底注:" .. self:GetCurBaseCoinScore()
        local minJoinCoin = self:Get_minJoinCoin()
        if(minJoinCoin) then
            TopCerterShowStr = TopCerterShowStr .. " 入场:" .. minJoinCoin
        end
        local minForceExitCoin = self:Get_minForceExitCoin()
        if(minForceExitCoin and minForceExitCoin > 0) then
            TopCerterShowStr = TopCerterShowStr .. " 离场:" .. minForceExitCoin
        end
        TopCerterShowStr = TopCerterShowStr .. "  第" .. roomInfo.cur_circle .. "/" .. roomInfo.max_circle .. "轮"
    else
        TopCerterShowStr = self:getRoomInfoDesc(roomInfo)
        self.textRoundNum.text = "(第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局)"
    end

    if self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0 then
        self.textRoomNum.text = AppData.MuseumName .."房号:" .. roomInfo.roomNum
    else
        self.textRoomNum.text = "房号:" .. roomInfo.roomNum
    end

    self.textRoomRule.text = TopCerterShowStr
    self.textRoundNum.gameObject:SetActive(true)
end

function TableView_ZhaJinHua:getRoomInfoDesc(roomInfo)
    local ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local desc = "第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局 "
    if (ruleTable.menNum) then
        if (ruleTable.menNum == 0) then
            desc = desc .. "可不闷 "
        else
            desc = desc .. "闷" .. ruleTable.menNum .. "圈 "
        end
    end

    local minJoinCoin = self:Get_minJoinCoin()
    if(minJoinCoin) then
        desc = desc .. "入场:" .. minJoinCoin .. " "
    end

    --if (ruleTable.special == 0) then
    --    desc = desc .. "235大于豹子 "
    --elseif (ruleTable.special == 1) then
    --    desc = desc .. "235大于AAA "
    --end

    desc = desc .. "第" .. roomInfo.cur_circle .. "/" .. roomInfo.max_circle .. "轮"
    return desc
end

function TableView_ZhaJinHua:refreshBatteryAndTimeInfo()
    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue / 100
    self.sliderBattery.value = batteryValue
    ModuleCache.ComponentUtil.SafeSetActive(self.imageBatteryCharging.gameObject, GameSDKInterface:GetCurChargeState())
    self.textTime.text = os.date("%H:%M", os.time())

    local signalType = GameSDKInterface:GetCurSignalType()

    if (signalType == "none") then
        self:showWifiState(true, 0)
        self:show4GState(false)
    elseif (signalType == "wifi") then
        local wifiLevel = GameSDKInterface:GetCurSignalStrenth()
        self:showWifiState(true, math.ceil(wifiLevel))
        self:show4GState(false)
    else
        self:showWifiState(false)
        self:show4GState(true, signalType)
    end
end

function TableView_ZhaJinHua:showWifiState(show, wifiLevel)
    for i = 1, #self.goWifiStateArray do
        ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)
    end
end

function TableView_ZhaJinHua:show4GState(show, signalType)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")
end

function TableView_ZhaJinHua:showCenterTips(show, content)
    ModuleCache.ComponentUtil.SafeSetActive(self.textCenterTips.transform.parent.gameObject, show)
    if (show) then
        self.textCenterTips.text = content
    end
end


-- 刷新准备状态,房主显示离开房间,邀请好友,开始游戏.  非房主显示离开房间和邀请好友
function TableView_ZhaJinHua:refreshReadyState(isCreator)
    if (self:isJinBiChang()) then
        self:SetJinBiChangStateSwitcher("Center")
        self:hideAllReadyButton()
        return
    end

    if isCreator then
        self.switcher:SwitchState("Three");
    else
        self.switcher:SwitchState("Two");
    end

    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        ModuleCache.ComponentManager.Find(self.root, "Bottom/Action/StateSwitcher/ButtonInviteFriend"):SetActive(false)
    end
end

--TODO XLQ:亲友圈快速组局 需要手动准备
function TableView_ZhaJinHua:MuseumReadyState(isShow)
    if self.modelData.roleData.RoomType == 2  then
        print("------------------mySeatInfo.cur_game_loop_cnt=",self.modelData.curTableData.roomInfo.mySeatInfo.cur_game_loop_cnt)
        self.buttonReady_museum.gameObject:SetActive(isShow and
        ( not self.modelData.curTableData.roomInfo.mySeatInfo.cur_game_loop_cnt
        or self.modelData.curTableData.roomInfo.mySeatInfo.cur_game_loop_cnt == 0)
        )
    end
end

--隐藏所有选择按钮
function TableView_ZhaJinHua:hideAllReadyButton()
    self.switcher:SwitchState("Disable");
end

function TableView_ZhaJinHua:showContinueBtn(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonContinue.gameObject, show)
end

--显示牛名
function TableView_ZhaJinHua:showNiuName(seatData, show, niuName)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    if (show) then
        TableHelper:showNiuName(seatHolder, true, niuName)
    else
        TableHelper:showNiuName(seatHolder, false, nil)
    end
end


function TableView_ZhaJinHua:SetPokerType(seatInfo, show, cards)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    if (not show) then
        TableHelper:showZhaJinHuaName(seatHolder, show)
        return
    end

    if (cards == nil or #cards ~= 3) then
        return
    end
    local cardType = ZjhLogic.cards_type(cards)
    seatInfo.TypeNameShowStr = ""
    if (show and cardType ~= nil) then
        if (cardType == 0) then
            --print("==CardCommon.unknown")
            seatInfo.TypeName = "unknown"
            seatInfo.hasZhaJinHua = false
        elseif (cardType == 1) then
            --print("==CardCommon.danzhang")
            seatInfo.TypeName = "danzhang"
            seatInfo.TypeNameShowStr = "高牌"
            seatInfo.hasZhaJinHua = true
        elseif (cardType == 2) then
            --print("==CardCommon.duizi")
            seatInfo.TypeName = "duizi"
            seatInfo.TypeNameShowStr = "对子"
            seatInfo.hasZhaJinHua = true
        elseif (cardType == 3) then
            --print("==CardCommon.shunzi")
            seatInfo.TypeName = "shunzi"
            seatInfo.TypeNameShowStr = "顺子"
            seatInfo.hasZhaJinHua = true
        elseif (cardType == 4) then
            --print("==CardCommon.jinhua")
            seatInfo.TypeName = "jinhua"
            seatInfo.TypeNameShowStr = "金花"
            seatInfo.hasZhaJinHua = true
        elseif (cardType == 5) then
            --print("==CardCommon.shunjin")
            seatInfo.TypeName = "shunjin"
            seatInfo.TypeNameShowStr = "顺金"
            seatInfo.hasZhaJinHua = true
        elseif (cardType == 6) then
            --print("==CardCommon.baozi")
            seatInfo.TypeName = "baozi"
            seatInfo.TypeNameShowStr = "豹子"
            seatInfo.hasZhaJinHua = true
        elseif (cardType == 7) then
            --print("==CardCommon.special")
            seatInfo.TypeName = "special"
            seatInfo.hasZhaJinHua = false
        end
        TableHelper:showZhaJinHuaName(seatHolder, show, seatInfo.TypeName, seatInfo.hasZhaJinHua,seatInfo.TypeNameShowStr)
    end
end



function TableView_ZhaJinHua:showNiuNiuEffect(seatData, show, duration, stayTime, delayTime, onComplete)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showNiuNiuEffect(seatHolder, show, duration, stayTime, delayTime, onComplete)
end


function TableView_ZhaJinHua:hideAllNiuNiuEffect()
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        TableHelper:showNiuNiuEffect(seatHolder, false)
    end
end

function TableView_ZhaJinHua:resetSelectedPokers()
    local cardsArray = self.seatHolderArray[1].inhandCardsArray
    for i = 1, #cardsArray do
        self:refreshCardSelect(cardsArray[i], true)
    end
end

function TableView_ZhaJinHua:refreshSeat(seatInfo)
    self:refreshSeatInfo(seatInfo)--刷新座位基本信息:头像,id,昵称等信息
    self:refreshSeatState(seatInfo)--刷新座位状态:准备状态
    self:SwitchState_NewStateRoot(seatInfo)--刷新玩家看牌、弃牌状态、比牌失败
    self:setInHandCardsMaskColor(seatInfo, seatInfo.zhaJinNiu_state == 3 or seatInfo.zhaJinNiu_state == 4)--设置手牌顶点颜色
end

--刷新座位玩家状态
function TableView_ZhaJinHua:refreshSeatState(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local locIsShow = false
    if(seatInfo.playerId and (seatInfo.playerId ~= 0 and seatInfo.playerId ~= "0")) then         
        locIsShow =  seatInfo.isReady and (not seatInfo.curRound) 
    end
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.ReadyRoot.gameObject, locIsShow)
    if(seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo) then
        self:SetState_WaitOthersReadyRoot(locIsShow)
    end
end

function TableView_ZhaJinHua:setInHandCardsMaskColor(seatData, mask)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:setInHandCardsMaskColor(seatHolder, mask)
end


--刷新座位看牌、弃牌状态、比牌失败状态
function TableView_ZhaJinHua:SwitchState_NewStateRoot(seatInfo,clean)
    local tSeatIndex = seatInfo.localSeatIndex
    --if(tSeatIndex== 1) then
    --    return
    --end
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    if(seatHolder) then
        if(clean) then
            seatHolder.NewStateRoot:SwitchState("No")
        else
            local str = nil
            if(seatInfo.zhaJinNiu_state == 3) then
                str = "StateDrop"
            elseif seatInfo.zhaJinNiu_state == 4 then
                str = "StateCompareFail"
            elseif seatInfo.zhaJinNiu_state == 2 then
                str = "StateHasCheck"
            end
            if(str == nil) then
                seatHolder.NewStateRoot:SwitchState("No")
                --print("====str == nil")
                return
            end
            if(tSeatIndex == 4 or tSeatIndex == 5 or tSeatIndex == 6 ) then
                str = str .. "L"
            elseif(tSeatIndex == 2 or tSeatIndex == 3) then
                str = str .. "R"
            elseif(tSeatIndex == 1) then
                str = str .. "B"
            end
            --print("====tSeatIndex="..tSeatIndex.."  str="..str)
            seatHolder.NewStateRoot:SwitchState(str)
        end
    end
end

function TableView_ZhaJinHua:ClearAllNewStateRoot()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        self:SwitchState_NewStateRoot(seatInfo,true)
    end
end

function TableView_ZhaJinHua:SetSeatInfoState_imageHasCheck(seatInfo, show)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.StateHasCheck.gameObject, show)
end

--显示座位本局下注的总分数
function TableView_ZhaJinHua:showSeatCostGold(seatInfo, show,IsOnlyRefreshText)
    if(seatInfo == nil) then
        return
    end
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goCostScore, show)
    if (not show and not IsOnlyRefreshText) then
        return
    end
    local showStr = ""
    if (self:isGoldSettle()) then
        showStr = Util.filterPlayerGoldNum(seatInfo.in_gold)
    else
        showStr = seatInfo.in_score .. ""
    end
    seatHolder.textCostScore.text = showStr
end

--显示本局注池的分数
function TableView_ZhaJinHua:showCurRoundBetScore(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCurRoundBetScore, show)
    if (show) then
        local showStr = ""
        if (self:isGoldSettle()) then
            showStr = Util.filterPlayerGoldNum(self.modelData.curTableData.roomInfo.pool_gold)
        else
            showStr = tostring(self.modelData.curTableData.roomInfo.pool_score)
        end
        self.textCurRoundBetScore.text = showStr
    end
end

--刷新在线状态
function TableView_ZhaJinHua:refreshSeatOfflineState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:refreshSeatOfflineState(seatHolder, seatData)
end

function TableView_ZhaJinHua:refreshSeatInfo(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    TableHelper:refreshSeatInfo(seatHolder, seatInfo)
end

function TableView_ZhaJinHua:showInHandCards(seatInfo, show)

    if (seatInfo.isWatchState) then
        show = false
    end
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    if(show and seatHolder.handPokerCardsUiSwitcher)then
        seatHolder.handPokerCardsUiSwitcher:SwitchState("Normal")
    end
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerCardsRoot, show)

    if(not show) then
        self:SetPokerType(seatInfo, show)
    end
end


function TableView_ZhaJinHua:refreshInHandCards(seatInfo, showFace, useAnim, IsShowPokerType)
    --如果没有显示牌的正面,那么就不能显示牌型
    if (not showFace) then
        self:SetPokerType(seatInfo, false)
    end

    if (showFace and (not seatInfo.inHandPokerListIsRealData)) then
        print("error====不是真实数据,不能显示")
        return
    end
    local localSeatIndex = seatInfo.localSeatIndex
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    local inHandPokerList = seatInfo.inHandPokerList
    TableHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim)

    --如果显示牌的类型那么就不能显示看牌、弃牌状态、比牌失败的状态
    if (IsShowPokerType) then
        self:SwitchState_NewStateRoot(seatInfo, true and localSeatIndex ~= 1)
    end

    --如果显示牌正面并且显示牌的类型,那么必须显示牌型,不显示状态
    if (showFace and IsShowPokerType) then
        local pokerNumList = {}
        if (seatInfo ~= nil and seatInfo.inHandPokerListIsRealData) then
            local inHandPokerList = seatInfo.inHandPokerList
            for i = 1, #inHandPokerList do
                local poker = inHandPokerList[i]
                table.insert(pokerNumList, poker.PokerNum)
            end
        end

        if (#pokerNumList > 0) then
            self:SetPokerType(seatInfo, true, pokerNumList)
            self:SwitchState_NewStateRoot(seatInfo, true and localSeatIndex ~= 1)
        end
    end

    if(seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo and showFace) then
        self:showCheckPokersButton(not showFace)
    end
end

--显示比牌选择框
function TableView_ZhaJinHua:showSelectCompare(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSelectCompare, show)
end


--显示聊天气泡
function TableView_ZhaJinHua:show_chat_bubble(localSeatIndex, content)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local chatBubble = GetComponentWithPath(seatRoot, "State/Group/ChatBubble", ComponentTypeName.RectTransform).gameObject
    local chatText = GetComponentWithPath(chatBubble, "TextBg/Text", ComponentTypeName.Text)
    chatText.text = content
    chatBubble:SetActive(true)
    if seatInfo.timeChatEvent_id then
        CSmartTimer:Kill(seatInfo.timeChatEvent_id)
        seatInfo.timeChatEvent_id = nil
    end
    seatInfo.timeChatEvent_id = nil
    local timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete(function(t)
        chatBubble:SetActive(false)
    end)
    seatInfo.timeChatEvent_id = timeEvent.id
end

--显示表情
function TableView_ZhaJinHua:show_chat_emoji(localSeatIndex, emojiId)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local curEmoji
    for i = 1, #seatHolder.emojiGoArray do
        local goEmoji = seatHolder.emojiGoArray[i]
        if (i == emojiId) then
            curEmoji = goEmoji
            ModuleCache.ComponentUtil.SafeSetActive(goEmoji, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(goEmoji, false)
        end
    end
    if seatHolder.timeChatEmojiEvent_id then
        CSmartTimer:Kill(seatHolder.timeChatEmojiEvent_id)
        seatHolder.timeChatEmojiEvent_id = nil
    end

    seatHolder.timeChatEmojiEvent_id = nil
    local timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete(function(t)
        if (curEmoji) then
            ModuleCache.ComponentUtil.SafeSetActive(curEmoji, false)
        end
    end)
    seatHolder.timeChatEmojiEvent_id = timeEvent.id
end



function TableView_ZhaJinHua:show_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(true)
end

function TableView_ZhaJinHua:hide_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(false)
end

function TableView_ZhaJinHua:show_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goSpeaking, show)
end

function TableView_ZhaJinHua:show_cancel_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCancelSpeaking, show)
end

function TableView_ZhaJinHua:showSeatRoundScoreAnim(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showRoundScoreEffect(seatHolder, seatData.localSeatIndex, show, score, 0.6)
end

function TableView_ZhaJinHua:showRandomBankerEffect(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showRandomBankerEffect(seatHolder, show)
end

function TableView_ZhaJinHua:showSeatWinScoreCurRound(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showSeatWinScoreCurRound(seatHolder, show, score)
end

--------------------------------------------------------------------------------
--按钮置灰
function TableView_ZhaJinHua:maskGrayButton(obj, gray)
    local children = ModuleCache.ComponentUtil.GetComponentsInChildren(obj.gameObject, ComponentTypeName.Image)
    local grayColor = UnityEngine.Color(0.65, 0.65, 0.65, 1)
    local normalColor = UnityEngine.Color(1, 1, 1, 1)
    for i = 0, children.Length - 1 do
        local img = children[i]
        if (gray) then
            img.color = grayColor
            --ModuleCache.CustomerUtil.SetAlpha(img, 0.5)
        else
            img.color = normalColor
            --ModuleCache.CustomerUtil.SetAlpha(img, 1)
        end
    end
end

--按钮使能
function TableView_ZhaJinHua:enableButton(obj, enable)
    local children = ModuleCache.ComponentUtil.GetComponentsInChildren(obj, "UnityEngine.UI.Graphic")
    for i = 0, children.Length - 1 do
        local img = children[i]
        if (enable) then
            img.raycastTarget = true
        else
            img.raycastTarget = false
        end
    end
end

function TableView_ZhaJinHua:EnableButton2(ButtonComponent,IsEnable)
    if(ButtonComponent) then
        ButtonComponent.interactable = IsEnable
    end
end

function TableView_ZhaJinHua:EnableAddBetBtn(ButtonComponent, enable)

end

function TableView_ZhaJinHua:GetCurBaseCoinScore()
    return self.modelData.curTableData.roomInfo.baseCoinScore
end

function TableView_ZhaJinHua:GetBetScore(BetScore)
    if (self:isGoldSettle()) then
        return BetScore * self:GetCurBaseCoinScore()
    else
        return BetScore
    end
end

--刷新下注按钮
function TableView_ZhaJinHua:refreshBetBtns(canBetScoreList)
    local followScore = self:GetBetScore(canBetScoreList[1])
    print("=====followScore=",followScore)
    self.textFollowValue.text = followScore
    self.toggleFollowAlwaysValue.text = followScore
    self.ButtonCompareText.text = followScore
    self.BtnCompareText2.text = followScore
end

function TableView_ZhaJinHua:refreshBetBtnTextCount(cur_follow_score)
    local followScore = self:GetBetScore(cur_follow_score)
    --print("=====followScore=",followScore)
    self.textFollowValue.text = followScore
    self.toggleFollowAlwaysValue.text = followScore
    self.ButtonCompareText.text = followScore
    self.BtnCompareText2.text = followScore
end

--显示更多
function TableView_ZhaJinHua:showBetBtns(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goMoreBtns, show)
    ModuleCache.ComponentUtil.SafeSetActive(self.Viewport, show)
end

--显示比牌特效
function TableView_ZhaJinHua:showConstrastEffect(show, leftWin, onFinish)
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, true)
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goAnimator, show)
    if (not show) then
        return
    end

    View.subscibe_time_event(self, 0.75, false, 0):OnComplete(function(t)
        ModuleCache.SoundManager.play_sound("zhajinhua", "zhajinhua/sound/zhajinniu/compare_poker_flash.bytes", "compare_poker_flash")
        ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.leftLostEffect,not leftWin)
        ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.rightLostEffect, leftWin)
        View.subscibe_time_event(self, 1.7, false, 0):OnComplete(function(t)
            ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.leftLostEffect,false)
            ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.rightLostEffect, false)
            ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, false)
            if (onFinish) then
                onFinish()
            end
        end)
    end)
end

--显示比牌前的扑克飞跃动画
function TableView_ZhaJinHua:showSeatPokerFly2ComparePosEffect(seatInfo, show, isLeft, onFinish)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    if (not show) then
        ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, false)
    else
        local MoveRoot
        local MoveRootPos
        if (isLeft) then
            MoveRoot = self.holderConstrastEffect.leftCardsRoot
            MoveRootPos = self.holderConstrastEffect.leftCardsRootPos
        else
            MoveRoot = self.holderConstrastEffect.rightCardsRoot
            MoveRootPos = self.holderConstrastEffect.rightCardsRootPos
        end
        local MoveRootHeadImage = GetComponentWithPath(MoveRoot.gameObject,"Head/Avatar/Mask/Image", ComponentTypeName.Image)
        MoveRootHeadImage.sprite = seatHolder.imagePlayerHead.sprite
        local MoveRootTextName = GetComponentWithPath(MoveRoot.gameObject,"Head/TextName", ComponentTypeName.Text)
        MoveRootTextName.text = seatHolder.textPlayerName.text
        ModuleCache.ComponentUtil.SafeSetActive(MoveRoot, false)
        ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, true)
        ModuleCache.ComponentUtil.SafeSetActive(MoveRoot, true)
        MoveRoot.transform.localScale  = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
        MoveRoot.transform.position = seatHolder.imagePlayerHead.transform.position
        local sequence = self:create_sequence()
        local duration = 0.75
        sequence:Join(MoveRoot.transform:DOMove(MoveRootPos, duration, false):SetEase(DG.Tweening.Ease.OutQuint))
        sequence:OnComplete(function()
            if (onFinish) then
                onFinish()
            end
        end)
    end
end

--显示比牌后的扑克飞跃动画
function TableView_ZhaJinHua:showComparePokerFly2SeatPosEffect(seatData, show, isLeft, onFinish)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, show)
    if (show) then
        local MoveRoot
        local MoveRootPos
        if (isLeft) then
            MoveRoot = self.holderConstrastEffect.leftCardsRoot
            MoveRootPos = self.holderConstrastEffect.leftCardsRootPos
        else
            MoveRoot = self.holderConstrastEffect.rightCardsRoot
            MoveRootPos = self.holderConstrastEffect.rightCardsRootPos
        end
        ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect.goRoot, true)
        ModuleCache.ComponentUtil.SafeSetActive(MoveRoot, true)
        MoveRoot.transform.position = MoveRootPos
        local sequence = self:create_sequence()
        local duration = 0.75
        local toPos = seatHolder.imagePlayerHead.transform.position
        --View.subscibe_time_event(self, duration - 0.4, false, 0):OnComplete(function (t)
        --    ModuleCache.ComponentUtil.SafeSetActive(MoveRoot, false)
        --end)
        --sequence:Append(MoveRoot.transform:DOMove(toPos, duration, false):SetEase(DG.Tweening.Ease.OutQuint))
        sequence:Append(MoveRoot.transform:DOMove(toPos, duration, false))
        sequence:Join(MoveRoot.transform:DOScale(0, duration-0.1))
        sequence:OnComplete(function()
            ModuleCache.ComponentUtil.SafeSetActive(MoveRoot, false)
            MoveRoot.transform.localScale  = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
            if (onFinish) then
                onFinish()
            end
        end)
    end
end

--显示手牌膨胀特效
function TableView_ZhaJinHua:showInHandCardsExpandEffect(seatData, show, onFinish)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    local handPokerCardsRoot = seatHolder.handPokerCardsRoot


    local originalScale = handPokerCardsRoot.transform.localScale
    local sequence = self:create_sequence();
    local duration = 1
    for i = 1, TableHelper.PokerCount do
        local cardHolder = seatHolder.inhandCardsArray[i]
        local imageLightFrame = cardHolder.imageLightFrame
        ModuleCache.ComponentUtil.SafeSetActive(imageLightFrame.gameObject, true)
    end
    local loopTime = 1
    for i = 1, loopTime do
        sequence:Append(handPokerCardsRoot.transform:DOScaleX(originalScale.x * 1.1, duration / loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
        sequence:Join(handPokerCardsRoot.transform:DOScaleY(originalScale.y * 1.1, duration / loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
        sequence:Append(handPokerCardsRoot.transform:DOScaleX(originalScale.x, duration / loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
        sequence:Join(handPokerCardsRoot.transform:DOScaleY(originalScale.y, duration / loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
    end

    sequence:OnComplete(function()
        for i = 1, TableHelper.PokerCount do
            local cardHolder = seatHolder.inhandCardsArray[i]
            local imageLightFrame = cardHolder.imageLightFrame
            ModuleCache.ComponentUtil.SafeSetActive(imageLightFrame.gameObject, false)
        end

        if (onFinish) then
            onFinish()
        end
    end)
end

--屏蔽点击
function TableView_ZhaJinHua:showMask(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goMask.gameObject, show)
end

--显示座位的倒计时效果  loopTimes > 0时多少圈就停止,loopTimes < 0是永远转圈
function TableView_ZhaJinHua:showSeatTimeLimitEffect(seatInfo, show, duration, onFinish, loopTimes)
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    seatHolder.imageTimeLimit.fillAmount = 0
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTimeLimit.gameObject, show)
    if (seatHolder.timeLimit) then
        CSmartTimer:Kill(seatHolder.timeLimit.timeEvent_id)
        seatHolder.timeLimit = nil
    end
    if (not show) then
        return
    end

    seatHolder.timeLimit = {}
    seatHolder.timeLimit.startTime = Time.realtimeSinceStartup
    seatHolder.timeLimit.endTime = Time.realtimeSinceStartup + duration
    seatHolder.timeLimit.curTime = Time.realtimeSinceStartup
    local timeEvent = View.subscibe_time_event(self, duration, false, 0):OnComplete(function(t)
        seatHolder.timeLimit = nil
        if (onFinish) then
            onFinish()
        end
        if (loopTimes) then
            loopTimes = loopTimes - 1
            if (loopTimes == 0) then
                if (seatHolder.timeLimit) then
                    CSmartTimer:Kill(seatHolder.timeLimit.timeEvent_id)
                    seatHolder.timeLimit = nil
                    return
                end
            elseif (loopTimes < 0) then
                self:showSeatTimeLimitEffect(seatInfo, show, duration, onFinish, loopTimes)
            elseif (loopTimes > 0) then
                self:showSeatTimeLimitEffect(seatInfo, show, duration, onFinish, loopTimes)
            end
        end
    end):SetIntervalTime(0.05, function(t)
        if(self:isJinBiChang() and t.surplusTimeRound == 5 and seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo) then
            local soundName = "b_daojishi"
            ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/zhajinniu/" .. soundName .. ".bytes", soundName)
        end
        seatHolder.timeLimit.curTime = Time.realtimeSinceStartup
        local rate = (seatHolder.timeLimit.curTime - seatHolder.timeLimit.startTime) / duration
        --local fillAmount = 1 - rate
        local fillAmount =  rate
        seatHolder.imageTimeLimit.fillAmount = fillAmount
        --if(fillAmount > 0.9) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.5, 0.8, 0, 1)
        --elseif(fillAmount > 0.85) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.55, 0.75, 0.003, 1)
        --elseif(fillAmount > 0.8) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.6, 0.7, 0.003, 1)
        --elseif(fillAmount > 0.75) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.65, 0.65, 0.002, 1)
        --elseif(fillAmount > 0.7) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.7, 0.62, 0.002, 1)
        --elseif(fillAmount > 0.65) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.75, 0.6, 0.002, 1)
        --elseif(fillAmount > 0.6) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.8, 0.55, 0.002, 1)
        --elseif(fillAmount > 0.55) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.85, 0.5, 0.001, 1)
        --elseif(fillAmount > 0.5) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(0.9, 0.45, 0.001, 1)
        --elseif(fillAmount > 0.4) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.4, 0.001, 1)
        --elseif(fillAmount > 0.35) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.35, 0, 1)
        --elseif(fillAmount > 0.3) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.3, 0, 1)
        --elseif(fillAmount > 0.25) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.25, 0, 1)
        --elseif(fillAmount > 0.2) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.2, 0, 1)
        --elseif(fillAmount > 0.15) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.15, 0, 1)
        --elseif(fillAmount > 0.1) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.1, 0, 1)
        --elseif(fillAmount > 0.05) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.05, 0, 1)
        --elseif(fillAmount > 0) then
        --    seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0, 0, 1)
        --end

        if(fillAmount > 0.9) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0, 0, 1)
        elseif(fillAmount > 0.85) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.05, 0, 1)
        elseif(fillAmount > 0.8) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.1, 0, 1)
        elseif(fillAmount > 0.75) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.15, 0, 1)
        elseif(fillAmount > 0.7) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.2, 0, 1)
        elseif(fillAmount > 0.65) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.25, 0, 1)
        elseif(fillAmount > 0.6) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.3, 0, 1)
        elseif(fillAmount > 0.55) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.35, 0, 1)
        elseif(fillAmount > 0.5) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(1, 0.4, 0.001, 1)
        elseif(fillAmount > 0.4) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.9, 0.45, 0.001, 1)
        elseif(fillAmount > 0.35) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.85, 0.5, 0.001, 1)
        elseif(fillAmount > 0.3) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.8, 0.55, 0.002, 1)
        elseif(fillAmount > 0.25) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.75, 0.6, 0.002, 1)
        elseif(fillAmount > 0.2) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.7, 0.62, 0.002, 1)
        elseif(fillAmount > 0.15) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.65, 0.65, 0.002, 1)
        elseif(fillAmount > 0.1) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.6, 0.7, 0.003, 1)
        elseif(fillAmount > 0.05) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.55, 0.75, 0.003, 1)
        elseif(fillAmount > 0) then
            seatHolder.TimeChangeShow.color = UnityEngine.Color(0.5, 0.8, 0, 1)
        end
    end)
    seatHolder.timeLimit.timeEvent_id = timeEvent.id
end


--显示弃牌牌按钮
function TableView_ZhaJinHua:showDropPokersButton(show, enable,isNeedAnim)
    local obj = self.buttonDropPoker.gameObject
    isNeedAnim = false--self:CheckIsNeedAnim(isNeedAnim,show,obj.activeInHierarchy)
    if(not isNeedAnim) then
        ModuleCache.ComponentUtil.SafeSetActive(obj, show)
        if(show and enable ~= nil) then
            self:EnableButton2(self.buttonDropPoker,enable)
            self.BtnDropPokerUIStateSwitcher:SwitchState(enable and "OnEnable" or "DisEnable")
            obj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
        end
    else
        if(show) then
            self:BtnAnim_FromNotShowToShow(obj,self.BtnDropPos)
        else
            self:BtnAnim_FromShowToNotShow(obj)
        end
    end
end

--显示比牌按钮
function TableView_ZhaJinHua:showComparePokersButton(show,enable,isNeedAnim)
    local obj = self.buttonComparePoker.gameObject
    isNeedAnim = self:CheckIsNeedAnim(isNeedAnim,show,obj.activeInHierarchy)
    if(not isNeedAnim) then
        ModuleCache.ComponentUtil.SafeSetActive(obj, show)
        if(show and enable ~= nil) then
            self:EnableButton2(self.buttonComparePoker,enable)
            self.BtnCompareUIStateSwitcher:SwitchState(enable and "OnEnable" or "DisEnable")
            obj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
        end
    else
        if(show) then
            self:BtnAnim_FromNotShowToShow(obj,self.BtnComparePokerPos)
        else
            self:BtnAnim_FromShowToNotShow(obj)
        end
    end
end

--显示看牌按钮
function TableView_ZhaJinHua:showCheckPokersButton(show, enable)
    local obj = self.ButtonCheck.gameObject
    ModuleCache.ComponentUtil.SafeSetActive(obj, show)
end

--显示跟到底按钮
function TableView_ZhaJinHua:showFollowAlwaysButton(show, enable ,isNeedAnim)
    local obj = self.toggleFollowAlways.gameObject
    isNeedAnim = false--self:CheckIsNeedAnim(isNeedAnim,show,obj.activeInHierarchy)
    if(not isNeedAnim) then
        ModuleCache.ComponentUtil.SafeSetActive(obj, show)
        if(show and enable ~= nil) then
            self:maskGrayButton(obj, not enable)
            self:enableButton(obj, enable)
            obj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
        end
    else
        if(show) then
            self:BtnAnim_FromNotShowToShow(obj,self.FollowAlwaysPos)
        else
            self:BtnAnim_FromShowToNotShow(obj)
        end
    end
end

--显示跟注按钮
function TableView_ZhaJinHua:showFollowButton(show, enable,isNeedAnim)
    local obj = self.buttonFollow.gameObject
    isNeedAnim = false--self:CheckIsNeedAnim(isNeedAnim,show,obj.activeInHierarchy)
    if(not isNeedAnim) then
        ModuleCache.ComponentUtil.SafeSetActive(obj, show)
        if(show and enable ~= nil) then
            self:maskGrayButton(obj, not enable)
            self:enableButton(obj, enable)
            obj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
        end
    else
        if(show) then
            self:BtnAnim_FromNotShowToShow(obj,self.BtnFollowPos)
        else
            self:BtnAnim_FromShowToNotShow(obj)
        end
    end
end

function TableView_ZhaJinHua:showBtnXuePin(show, enable,isNeedAnim)
    local obj = self.BtnXuePin.gameObject
    isNeedAnim = self:CheckIsNeedAnim(isNeedAnim,show,obj.activeInHierarchy)
    if(not isNeedAnim) then
        ModuleCache.ComponentUtil.SafeSetActive(obj, show)
        self:maskGrayButton(obj, not enable)
        self:enableButton(obj, enable)
        obj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
    else
        if(show) then
            self:BtnAnim_FromNotShowToShow(obj,self.BtnXuePinPos)
        else
            self:BtnAnim_FromShowToNotShow(obj)
        end
    end
end

function TableView_ZhaJinHua:showBtnXuePinFollow(show, enable)
    local obj = self.BtnXuePinFollow.gameObject
    ModuleCache.ComponentUtil.SafeSetActive(obj, show)
end


--显示加注按钮
function TableView_ZhaJinHua:showBtnAdd(show, enable,isNeedAnim)
    local obj = self.BtnAdd.gameObject
    isNeedAnim = self:CheckIsNeedAnim(isNeedAnim,show,obj.activeInHierarchy)
    if(not isNeedAnim) then
        ModuleCache.ComponentUtil.SafeSetActive(obj, show)
        if(show and enable ~= nil) then
            self:EnableButton2(self.BtnAdd,enable)
            self.BtnAddUIStateSwitcher:SwitchState(enable and "OnEnable" or "DisEnable")
            obj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(1, 1, 1)
        end
    else
        if(show) then
            self:BtnAnim_FromNotShowToShow(obj,self.BtnAddPos)
        else
            self:BtnAnim_FromShowToNotShow(obj)
        end
    end
end

function TableView_ZhaJinHua:CheckIsNeedAnim(isNeedAnim,isShow,isActiveInHierarchy)
    if(true) then
        return false
    end
    if(isNeedAnim) then
        if((isShow and isActiveInHierarchy)
        or (not isShow and not isActiveInHierarchy)) then
            isNeedAnim = false
        end
    end
    return isNeedAnim
end


function TableView_ZhaJinHua:BtnAnim_FromShowToNotShow(BtnObj)
    local sequence = self:create_sequence()
    local duration = 0.3
    local toPos = self.ActionCenterPos
    sequence:Append(BtnObj.transform:DOMove(toPos, duration, false))
    sequence:Join(BtnObj.transform:DOScale(0, duration))
    sequence:OnComplete(function()
        ModuleCache.ComponentUtil.SafeSetActive(BtnObj, false)
    end)
end

function TableView_ZhaJinHua:BtnAnim_FromNotShowToShow(BtnObj,toPos)
    local sequence = self:create_sequence()
    local duration = 0.3
    BtnObj.transform.position = self.ActionCenterPos
    BtnObj.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    ModuleCache.ComponentUtil.SafeSetActive(BtnObj, true)
    sequence:Append(BtnObj.transform:DOMove(toPos, duration, false))
    sequence:Join(BtnObj.transform:DOScale(1, duration))
end

function TableView_ZhaJinHua:GoldFlyToPoolFromSeat(seatInfo, count)
    self:goldFlyToGoldHeapFromSeat(seatInfo, count)
end

function TableView_ZhaJinHua:GoldBullionFlyToPoolFromSeat(seatInfo, count,duration)
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    local fromPos = seatHolder.buttonNotSeatDown.transform.position
    duration = duration or 0.7
    if (not self.goldList) then
        self.goldList = {}
    end
    local goldList = {}
    local goldPrefab = self.GoldBullionPrefab
    local goGold = ModuleCache.ComponentUtil.InstantiateLocal(goldPrefab, self.holderGolds.root)
    GetComponentWithPath(goGold.gameObject, "chip/Value", ComponentTypeName.Text).text = count
    ModuleCache.ComponentUtil.SafeSetActive(goGold, true)
    table.insert(self.goldList, goGold)
    table.insert(goldList, goGold)
    TableHelper:goldFlyToGoldHeap(goldList, fromPos, self.goldHeapRect, duration)
end

function TableView_ZhaJinHua:PoolScoreShowGold(poolScore)
    for i = 1, poolScore do
        self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 1, 0)
    end
    --if (self:isGoldSettle()) then
    --    for i = 1, poolScore do
    --        self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 1, 0)
    --    end
    --    return
    --end
    --if (poolScore > 10) then
    --    local count_1 = 0
    --    local count_10 = math.floor( poolScore / 10 )
    --    local yushu_10 = poolScore % 10
    --    for i = 1, count_10 do
    --        self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 10, 0)
    --    end
    --
    --    if (yushu_10 > 0) then
    --        for i = 1, yushu_10 do
    --            self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 1, 0)
    --        end
    --    end
    --
    --    -- if(yushu_10 >= 5) then
    --    --     self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 5, 0)
    --    --     count_1 = yushu_10 - 5
    --    -- else
    --    --     count_1 = yushu_10
    --    -- end
    --
    --    -- if(count_1 > 0) then
    --    --     for i=1,count_1 do
    --    --         self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 1, 0)
    --    --     end
    --    -- end
    --
    --    -- print("========count_10",count_10)
    --    return
    --end

    --for i = 1, poolScore do
    --    self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, 1, 0)
    --end
end

--静态生成金币堆
function TableView_ZhaJinHua:genGoldHeap(curRoundBetScoreList)
    for i = 1, #curRoundBetScoreList do
        self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, curRoundBetScoreList[i], 0)
    end
end

--金币飞到注池
function TableView_ZhaJinHua:goldFlyToGoldHeapFromSeat(seatInfo, betScore)
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    self:goldFlyToGoldHeap(seatHolder.buttonNotSeatDown.transform.position, betScore, 0.7)
end

function TableView_ZhaJinHua:goldFlyToGoldHeap(fromPos, betScore, duration)
    if (true) then
    --if (self:isGoldSettle()) then
        --print("====金币飞筹码")
        if (not self.goldList) then
            self.goldList = {}
        end
        local goldList = {}
        local goldPrefab = self.goldPrefabList[1]
        local locBetScore = betScore
        if(locBetScore <= 2) then
            goldPrefab = self.goldPrefabList[1]
        elseif(locBetScore <= 4) then
            goldPrefab = self.goldPrefabList[2]
        elseif(locBetScore <= 6) then
            goldPrefab = self.goldPrefabList[3]
        else
            goldPrefab = self.goldPrefabList[4]
        end

        local goGold = ModuleCache.ComponentUtil.InstantiateLocal(goldPrefab, self.holderGolds.root)
        GetComponentWithPath(goGold.gameObject, "chip/Value", ComponentTypeName.Text).text = self:GetBetScore(betScore)
        ModuleCache.ComponentUtil.SafeSetActive(goGold, true)
        table.insert(self.goldList, goGold)
        table.insert(goldList, goGold)
        TableHelper:goldFlyToGoldHeap(goldList, fromPos, self.goldHeapRect, duration)
    else
        --print("====积分模式飞筹码")
        if (not self.goldList) then
            self.goldList = {}
        end
        local goldList = {}
        local goldPrefab = self.goldPrefabList[1]
        local locBetScore = self:GetBetScore(betScore)
        if(locBetScore <= 2) then
            goldPrefab = self.goldPrefabList[1]
        elseif(locBetScore <= 4) then
            goldPrefab = self.goldPrefabList[2]
        elseif(locBetScore <= 6) then
            goldPrefab = self.goldPrefabList[3]
        else
            goldPrefab = self.goldPrefabList[4]
        end
        local goGold = ModuleCache.ComponentUtil.InstantiateLocal(goldPrefab, self.holderGolds.root)
        GetComponentWithPath(goGold.gameObject, "chip/Value", ComponentTypeName.Text).text = locBetScore
        ModuleCache.ComponentUtil.SafeSetActive(goGold, true)
        table.insert(self.goldList, goGold)
        table.insert(goldList, goGold)
        TableHelper:goldFlyToGoldHeap(goldList, fromPos, self.goldHeapRect, duration)
    end
end


--金币从注池飞到座位
function TableView_ZhaJinHua:goldFlyToSeat(seatData, onFinish)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    if (self.goldList) then
        TableHelper:goldFlyToSeat(self.goldList, seatHolder.buttonNotSeatDown.transform.position, 0.5, 0, true, function( ... )
            if (onFinish) then
                onFinish()
            end
        end)
        self.goldList = {}
    end
end

function TableView_ZhaJinHua:showZhaJinNiuBtns(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goZhaJinNiuBtnsRoot, show)
end

function TableView_ZhaJinHua:refreshContinueTimeLimitText(secs)
    --self.textContinueLimitTime.text = string.format( "(%d)", secs)
end

function TableView_ZhaJinHua:show_ping_delay(show, delaytime)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingValue.gameObject, show)
    if (not show) then
        return
    end
    delaytime = math.floor(delaytime * 1000)
    local content = ''
    if (delaytime >= 1000) then
        delaytime = delaytime / 1000
        delaytime = Util.getPreciseDecimal(delaytime, 2)
        content = '<color=#a31e2a>' .. delaytime .. 's</color>'
    elseif (delaytime >= 200) then
        content = '<color=#a31e2a>' .. delaytime .. 'ms</color>'
    elseif (delaytime >= 100) then
        content = '<color=#b5a324>' .. delaytime .. 'ms</color>'
    else
        content = '<color=#44b916>' .. delaytime .. 'ms</color>'
    end
    self.textPingValue.text = content
end

--刷新玩家的分数
function TableView_ZhaJinHua:refreshseatInfoScore(seatInfo)
    if (seatInfo == nil) then
        print("====seatInfo == nil or seatInfo.score == nil")
        return
    end
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    if (self:isGoldSettle()) then
        seatHolder.GoldCount.text = Util.filterPlayerGoldNum(seatInfo.coinBalance)
    else
        seatHolder.textScore.text = tostring(seatInfo.score)
    end
end

--刷新玩家的准备状态
function TableView_ZhaJinHua:refreshSeatInfoImageReadyState(seatInfo)
    if (seatInfo == nil) then
        print("====seatInfo == nil")
        return
    end
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    if (seatHolder) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.ReadyRoot.gameObject, seatInfo.isReady)
        if(seatInfo == self.modelData.curTableData.roomInfo.mySeatInfo) then
            self:SetState_WaitOthersReadyRoot(seatInfo.isReady and not seatInfo.isWatchState)
        end
    end
end

--金币场
function TableView_ZhaJinHua:isJinBiChang()
    return self.modelData.tableCommonData.isGoldTable
end

--金币场无限局模式
function TableView_ZhaJinHua:isGoldUnlimited()
    return self.modelData.tableCommonData.isGoldUnlimited
end

--金币结算
function TableView_ZhaJinHua:isGoldSettle()
    return self.modelData.tableCommonData.isGoldSettle
end

function TableView_ZhaJinHua:CheckUI()
    if (self:isJinBiChang()) then
        self:SetState_ButtonShop(true)
    else
        self:SetState_ButtonShop(false)
    end

    if (self:isGoldSettle()) then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
            seatHolder.CurrencyUIStateSwitcher:SwitchState("Gold")
        end
    end
end

function TableView_ZhaJinHua:SetJinBiChangStateSwitcher(show,intTime)
    if (show == false) then
        self:ResetButtonReadyTimeEventId()
        show = "Disable"
    else
        show = "Center"
        if(intTime and intTime > 0) then
            self:ResetButtonReadyTimeEventId()
            self.ButtonReadyTimeEventId = self:subscibe_time_event(intTime, false, 1):OnUpdate(function (t)
                t = t.surplusTimeRound
                self.ButtonReadyTime.text = t
            end):OnComplete(function(t)

            end).id
        end
    end
    self.JinBiChangStateSwitcher:SwitchState(show)
end

function TableView_ZhaJinHua:ResetButtonReadyTimeEventId()
    if self.ButtonReadyTimeEventId then
        CSmartTimer:Kill(self.ButtonReadyTimeEventId)
        self.ButtonReadyTimeEventId = nil
    end
end

function TableView_ZhaJinHua:ReplaceTableNow( ... )
    if self.ReplaceTableNowId then
        CSmartTimer:Kill(self.ReplaceTableNowId)
        self.ReplaceTableNowId = nil
    end
end

function TableView_ZhaJinHua:GetSeatHolderBySeatInfo(seatInfo)
    if (seatInfo == nil) then
        return
    end
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    return seatHolder
end


function TableView_ZhaJinHua:SetCoinCountdown(time)
    self.CoinMatchCountdownText.text = time

end

function TableView_ZhaJinHua:SetCoinCountdownState(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.CoinMatchCountdownRoot.gameObject, show)
end

function TableView_ZhaJinHua:StopCoinCountdown()
    if (self:isJinBiChang()) then
        if self.kickedTimeId then
            CSmartTimer:Kill(self.kickedTimeId)
            self.kickedTimeId = nil
        end
        self:SetCoinCountdownState(false)
    end
end

function TableView_ZhaJinHua:StartCoinCountdown(time, timeOverIsAutoHide)
    if (self:isJinBiChang()) then
        if self.kickedTimeId then
            CSmartTimer:Kill(self.kickedTimeId)
            self.kickedTimeId = nil
        end
        local locTime = time or self.modelData.curTableData.roomInfo.auto_time
        if (locTime and locTime > 0) then
            self:SetCoinCountdownState(true)
            self.kickedTimeId = self:subscibe_time_event(locTime, false, 1):OnUpdate( function(t)
                t = t.surplusTimeRound
                self:SetCoinCountdown(t)
            end):OnComplete( function(t)
                if(timeOverIsAutoHide) then
                    self:SetCoinCountdownState(false)
                end
            end).id
        end
    else
        self:SetCoinCountdownState(false)
    end



end

function TableView_ZhaJinHua:SetTipsServiceFee(FeeNum)
    ModuleCache.ComponentUtil.SafeSetActive(self.TipsServiceFeeRoot.gameObject, true)
    self.TipsServiceFeeText.text = "本局游戏服务费为" .. tostring(self.modelData.curTableData.roomInfo.feeNum)
    self:subscibe_time_event(2, false, 1):OnComplete( function(t)
        ModuleCache.ComponentUtil.SafeSetActive(self.TipsServiceFeeRoot.gameObject, false)
    end)
end

function TableView_ZhaJinHua:ShowGoldNotEnoughUI()
    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
        --self.model:request_UserRechargeReq(true)
        ModuleCache.ModuleManager.show_module("public", "goldadd")
    end, nil, true, "确 认", "取 消")
end


function TableView_ZhaJinHua:RefreshRechargeSatus(seatInfo, mySeatInfo, retData)
    print("玩家在补充金币")
    print_table(retData)
    if seatInfo == mySeatInfo then
        --如果正在操作 则更新倒计时
        print("自己补充金币", retData.time, self.modelData.curTableData.roomInfo.cur_operation_playerid, retData.playerid)
        if retData.time and retData.time ~= 0 and self.modelData.curTableData.roomInfo.cur_operation_playerid == retData.playerid then
            self:StartCoinCountdown(retData.time)
        end
    end
    if self.seatHolderArray[seatInfo.localSeatIndex].rechargeState then
        self:SetState_rechargeState(seatInfo,retData.open)
    end
end

function TableView_ZhaJinHua:ResetAllRechargeSatus()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        self:SetState_rechargeState(seatInfoList[i])
    end
end

function TableView_ZhaJinHua:SetState_rechargeState(seatInfo,show)
    if(seatInfo) then
        local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
        if(seatHolder) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.rechargeState, show)
        end
    end
end


function TableView_ZhaJinHua:SetState_WaitOthersReadyRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.WaitOthersReadyRoot.gameObject, show)
end

function TableView_ZhaJinHua:SetFollowAlwaysInstructionsLable(showLable)
    self.toggleFollowAlwaysInstructionsLable.text = showLable
end

function TableView_ZhaJinHua:SetState_AddBetRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.AddBetRoot.gameObject, show)
end

function TableView_ZhaJinHua:SetAddBetBtnListShow(dataList)
    for i = 1, #self.AddBetBtnList do
        local AddBetBtn = self.AddBetBtnList[i]
        ModuleCache.ComponentUtil.SafeSetActive(AddBetBtn.gameObject, false)
    end

    for i = 1, #dataList do
        local AddBetData = dataList[i]
        if(AddBetData) then
            local AddBetBtn = self.AddBetBtnList[AddBetData.score]
            local AddBetBtnValue = GetComponentWithPath(AddBetBtn.gameObject, "Value", ComponentTypeName.Text)
            AddBetBtnValue.text = self:GetBetScore(AddBetData.score)
            ModuleCache.ComponentUtil.SafeSetActive(AddBetBtn.gameObject, true)
            if(AddBetData.can_add) then
                AddBetBtn.interactable = true
                AddBetBtnValue.color = UnityEngine.Color(1, 1, 1, 1)
            else
                AddBetBtn.interactable = false
                AddBetBtnValue.color = UnityEngine.Color(0.31, 0.31, 0.31, 1)
            end
        end
    end
end

function TableView_ZhaJinHua:SetState_LeftRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.LeftRoot.gameObject, show)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnLeftOpen.gameObject,not show)
end

function TableView_ZhaJinHua:SetState_ButtonShop(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnShopRoot.gameObject, show)
end

function TableView_ZhaJinHua:SetState_BtnActivityRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnActivityRoot.gameObject, show)
end

function TableView_ZhaJinHua:SetState_EffectRanShaoRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.EffectRanShaoRoot.gameObject, show)
end

function TableView_ZhaJinHua:SetState_MyWinEffectRoot(show,IsAutoHide)
    if(not show) then
        ModuleCache.ComponentUtil.SafeSetActive(self.MyWinEffectRoot.gameObject, show)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.MyWinEffectRoot.gameObject, show)
        if(IsAutoHide) then
            self:subscibe_time_event(2.5, false, 1):OnComplete(function(t)
                ModuleCache.ComponentUtil.SafeSetActive(self.MyWinEffectRoot.gameObject, false)
            end)
        end
    end
end

function TableView_ZhaJinHua:SetState_WinnerEffectRoot(seatInfo , show, IsAutoHide)
    if(seatInfo == nil) then
        return
    end
    print("===SetState_WinnerEffectRoot1")
    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
    if(seatHolder == nil) then
        return
    end
    print("===SetState_WinnerEffectRoot2")


    if(not show) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.WinnerEffectRoot.gameObject, show)
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.WinnerEffectRoot.gameObject, show)
        if(IsAutoHide) then
            self:subscibe_time_event(2.5, false, 1):OnComplete(function(t)
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.WinnerEffectRoot.gameObject, false)
            end)
        end
    end
end

function TableView_ZhaJinHua:GetWatchStateShowText()
    return "等待下一局牌局"
end

function TableView_ZhaJinHua:Get_minJoinCoin()
    local roomInfo = self.modelData.curTableData.roomInfo
    local res = roomInfo.minJoinCoin
    if(res and res > 0)  then
        return res
    end

    if(roomInfo.ruleTable) then
        res = roomInfo.ruleTable.minJoinCoin
        if(res and res > 0)  then
            return res
        end
    end
    return nil
end

function TableView_ZhaJinHua:Get_minForceExitCoin()
    local roomInfo = self.modelData.curTableData.roomInfo
    local res = roomInfo.minForceExitCoin
    if(res and res > 0)  then
        return res
    end

    if(roomInfo.ruleTable) then
        res = roomInfo.ruleTable.minForceExitCoin
        if(res and res > 0)  then
            return res
        end
    end
    return nil
end


function TableView_ZhaJinHua:SetState_ComparePokerSelectRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.ComparePokerSelectRoot.gameObject, show)
end

function TableView_ZhaJinHua:SetComparePokerSelectTimeDown(isStart)
    if(self.ComparePokerSelectEventId) then
        CSmartTimer:Kill(self.ComparePokerSelectEventId)
        self.ComparePokerSelectEventId = nil
    end
    if(isStart) then
        self:SetState_ComparePokerSelectRoot(true)
    else
        self:SetState_ComparePokerSelectRoot(false)
        return
    end

    --self.ComparePokerSelectEventId = self:subscibe_time_event(30, false, 1):OnUpdate(function (t)
    --    t = t.surplusTimeRound
    --    self.ComparePokerSelectTime.text = t .. "s"
    --end):OnComplete(function(t)
    --    self:SetComparePokerSelectTimeDown(false)
    --end).id
end


function TableView_ZhaJinHua:SetState_HeadGray(seatInfo , show)
	local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
	if(seatHolder) then
		ModuleCache.ComponentUtil.SafeSetActive(seatHolder.HeadGray.gameObject, show)
	end
end

function TableView_ZhaJinHua:ResetAllPlayerHeadGray()
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i = 1, #seatInfoList do
		local seatInfo = seatInfoList[i]
		if(seatInfo) then
			self:SetState_HeadGray(seatInfo,false)
		end
	end
end

function TableView_ZhaJinHua:CheckLocationUI()
    local playerInfoList = TableManagerPoker:getPlayerInfoList(self.modelData.curTableData.roomInfo.seatInfoList)
    TableManagerPoker:isShowLocation(playerInfoList, self.buttonLocation)
end

function TableView_ZhaJinHua:GetComponentWithPathHelper()

end

function TableView_ZhaJinHua:CheckCreatorIcon()
    local roomInfo = self.modelData.curTableData.roomInfo
    if(self:isJinBiChang()) then
        roomInfo.IsHideCreatorIcon = true
    else
        if(roomInfo.curRoundNum > 0)then
            roomInfo.IsHideCreatorIcon = true
        end
    end
    if(roomInfo.IsHideCreatorIcon) then
        self:HideCreatorIcon()
    end
end

function TableView_ZhaJinHua:HideCreatorIcon()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if(seatInfo) then
            local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
            if(seatHolder) then
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, false)
            end
        end
    end
end





return TableView_ZhaJinHua