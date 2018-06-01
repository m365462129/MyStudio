--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local GetComponent = ModuleCache.ComponentManager.GetComponent
local CSmartTimer = ModuleCache.SmartTimer.instance

local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
--- @class CowBoy_TableView
local TableView = class('tableView', View)
local TableHelper = require("package/cowboy/module/table/table_helper")
local Sequence = DG.Tweening.DOTween.Sequence
local GameSDKInterface = ModuleCache.GameSDKInterface

function TableView:initialize(...)
    self.packageName = 'cowboy'
    self.moduleName = 'table'
    View.initialize(self, "cowboy/module/table/cowboy_table.prefab", "CowBoy_Table", 0, true)
    self.tableHelper = TableHelper:new()
    self.tableBackgroundSprite = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image).sprite
    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material
    self.goGold = GetComponentWithPath(self.root, "Holder/Gold", ComponentTypeName.Image).gameObject
    self.tranGoldHolder = GetComponentWithPath(self.root, "goldHolder", ComponentTypeName.Transform)
    self.buttonTestReconnect = GetComponentWithPath(self.root, "Top/TopInfo/ButtonTestReconnect", ComponentTypeName.Button)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonTestReconnect.gameObject, ModuleCache.GameManager.developmentMode or false)
    self:bindButtons()
    self.buttonSetting = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/ButtonSettings", ComponentTypeName.Button)
    self.buttonLocation = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/ButtonLocation", ComponentTypeName.Button)
    self.buttonMic = GetComponentWithPath(self.root, "Bottom/Action/ButtonMic", ComponentTypeName.Button)
    self.goSpeaking = GetComponentWithPath(self.root, "Speaking", ComponentTypeName.Transform).gameObject
    self.goCancelSpeaking = GetComponentWithPath(self.root, "CancelRecord", ComponentTypeName.Transform).gameObject

    self.buttonChat = GetComponentWithPath(self.root, "Bottom/Action/ButtonChat", ComponentTypeName.Button)
    self.sliderBattery = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/Battery", ComponentTypeName.Slider)
    self.imageBatteryCharging = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/Battery/ImageCharging", ComponentTypeName.Image)
    self.textPingValue = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/PingVal", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/Time/Text", ComponentTypeName.Text)
    self.goWifiStateArray = { }
    for i = 1, 5 do
        local goState = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/WifiState/state" ..(i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end

    self.goGState2G = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/GState/4g", ComponentTypeName.Transform).gameObject


    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoomRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Text", ComponentTypeName.Text)
    self.buttonRoomRule = GetComponentWithPath(self.root, "Top/TopInfo/ButtonRule", ComponentTypeName.Button)

    self.goSelectNiuNumberPanel = GetComponentWithPath(self.root, "Bottom/Info", ComponentTypeName.Transform).gameObject
    self.textSelectedNiuNumbersArray = { }
    for i = 1, 10 do
        self.textSelectedNiuNumbersArray[i] = GetComponentWithPath(self.root, "Bottom/Info/Count/TextPoker" .. i, ComponentTypeName.Text)
    end
    self.textSelectedNiuValue = GetComponentWithPath(self.root, "Bottom/Info/Count/TextValue", ComponentTypeName.Text)

    self.goNiuPoint = GetComponentWithPath(self.root, "Bottom/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
    self.imageNiuPoint = GetComponentWithPath(self.goNiuPoint, "num", ComponentTypeName.Image)
    self.imageComputeDone = GetComponentWithPath(self.root, "Bottom/ImageDone", ComponentTypeName.Image)
    self.transDonePokersPos = GetComponentWithPath(self.root, "Bottom/DonePokersPos", ComponentTypeName.Transform)

    self.uiStateSwitcherSeatPrefab = GetComponentWithPath(self.root, "Holder/Seat", "UIStateSwitcher")
    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.niuPointAssetHolder = GetComponentWithPath(self.root, "Holder/NiuNumAssetHolder", "SpriteHolder")
    self.goTmpBankerPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpBankerPos", ComponentTypeName.Transform).gameObject
    self.goTmpPokerHeapPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpPokerHeapPos", ComponentTypeName.Transform).gameObject

    self.goNiuNiuEffect = GetComponentWithPath(self.root, "NiuNiuEffect", ComponentTypeName.Transform).gameObject

    self.buttonMaskPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker5/Poker/MaskPoker", ComponentTypeName.Button)
    self.goFingerRoot = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker5/Finger", ComponentTypeName.Transform).gameObject
    self.goFinger = GetComponentWithPath(self.goFingerRoot, "finger", ComponentTypeName.Transform).gameObject
    self.imageYellowPoint = GetComponentWithPath(self.goFingerRoot, "back", ComponentTypeName.Image)

    self.goWinScore = GetComponentWithPath(self.root, "Bottom/WinScore", ComponentTypeName.Transform).gameObject
    self.textWinScore = GetComponentWithPath(self.goWinScore, "bg/win/score", "TextWrap")
    self.textLoseScore = GetComponentWithPath(self.goWinScore, "bg/lose/score", "TextWrap")

    local goClock = GetComponentWithPath(self.root, "Center/Clock", ComponentTypeName.Transform).gameObject
    local textClock = GetComponentWithPath(goClock, "Text", ComponentTypeName.Text)

    self.textRoundNum = GetComponentWithPath(self.root, "Center/RoundNum/Text", ComponentTypeName.Text)

    local selfHandPokerRoot = GetComponentWithPath(self.root, "Bottom/HandPokers", ComponentTypeName.Transform).gameObject
    self.srcSeatHolderArray = { }
    local localSeatIndex = 1
    for i = 1, 6 do
        local seatHolder = { }
        local seatPosTran = GetComponentWithPath(self.root, "Center/Seats/" .. i, ComponentTypeName.Transform)

        local goSeat = ModuleCache.ComponentUtil.InstantiateLocal(self.uiStateSwitcherSeatPrefab.gameObject, seatPosTran.gameObject)
        seatHolder.pokerAssetHolder = self.cardAssetHolder
        seatHolder.niuPointAssetHolder = self.niuPointAssetHolder

        seatHolder.goGoldCoinRoundScore = GetComponentWithPath(self.root, "Center/RoundScoreAnimHolder/" .. i .. "/RoundScoreAnim/bg", ComponentTypeName.Transform).gameObject
        seatHolder.textGoldCoinRoundWinScore = GetComponentWithPath(seatHolder.goGoldCoinRoundScore, "TextPlus/TextPlus", "TextWrap")
        seatHolder.textGoldCoinRoundLoseScore = GetComponentWithPath(seatHolder.goGoldCoinRoundScore, "TextMinus/TextMinus", "TextWrap")

        if (i == 1) then
            self.tableHelper:initSeatHolder(seatHolder, i, goSeat, selfHandPokerRoot)
            seatHolder.handPokerCardsUiSwitcher = ModuleCache.ComponentManager.GetComponent(selfHandPokerRoot,'UIStateSwitcher')
            seatHolder.goNiuPoint = self.goNiuPoint
            seatHolder.imageNiuPoint = self.imageNiuPoint
            seatHolder.imageComputeDone = self.imageComputeDone
            seatHolder.transDonePokersPos = self.transDonePokersPos
            seatHolder.goNiuNiuEffect = self.goNiuNiuEffect
            seatHolder.goWinScore = self.goWinScore
            seatHolder.textWinScore = self.textWinScore
            seatHolder.textLoseScore = self.textLoseScore
        else
            self.tableHelper:initSeatHolder(seatHolder, i, goSeat, nil)
        end

        self.tableHelper:refreshSeatInfo(seatHolder, { })
        -- 初始化

        seatHolder.goTmpBankerPos = self.goTmpBankerPos
        seatHolder.goTmpPokerHeapPos = self.goTmpPokerHeapPos
        -- 牌堆位置

        seatHolder.clockHolder.goClock = goClock
        seatHolder.clockHolder.textClock = textClock

        self.srcSeatHolderArray[i] = seatHolder
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, false)
    end


    self.text_goldCoinWaitReadyTip = GetComponentWithPath(self.root, "Center/GoldCoin_WaitReady_Tip/Text", ComponentTypeName.Text)
    self.button_goldCoin_exit = GetComponentWithPath(self.root, "Top/TopInfo/ButtonExit", ComponentTypeName.Button)
    self.button_wanfashuoming = GetComponentWithPath(self.root, "Top/TopInfo/Button_wanfashuoming", ComponentTypeName.Button)
    self.button_tableshop = GetComponentWithPath(self.root, "Top/TopInfo/ButtonShop", ComponentTypeName.Button)
    self.text_goldCoin_dizhu = GetComponentWithPath(self.root, "Center/GoldCoin_dizhu/Text", ComponentTypeName.Text)
    self.text_goldCoin_tip = GetComponentWithPath(self.root, "Center/GoldCoin_tip/Text", ComponentTypeName.Text)
end

function TableView:bindButtons()
    self.buttonInvite = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonInviteFriend", ComponentTypeName.Button)
    self.buttonReady = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady", ComponentTypeName.Button)
    self.buttonChangeRoom = GetComponentWithPath(self.root, "Bottom/Action/GoldCoinButtonchangeRoom", ComponentTypeName.Button)
    self.textChangeRoomLeftSecs = GetComponentWithPath(self.buttonChangeRoom.gameObject, "TextLeftSecs", ComponentTypeName.Text)
    self.button_goldcoin_ready = GetComponentWithPath(self.root, "Bottom/Action/GoldCoinButtonReady", ComponentTypeName.Button)
    self.text_goldcoin_ready = GetComponentWithPath(self.root, "Bottom/Action/GoldCoinButtonReady/Text", ComponentTypeName.Text)
    self.uistatewitcher_goldcoin_ready = GetComponent(self.button_goldcoin_ready.gameObject,"UIStateSwitcher")
    self.buttonContinue = GetComponentWithPath(self.root, "Bottom/Action/ButtonContinue", ComponentTypeName.Button)
    self.textContinueLimitTime = GetComponentWithPath(self.buttonContinue.gameObject, "Text", ComponentTypeName.Text)
    self.buttonStart = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonStart", ComponentTypeName.Button)
    self.buttonExit = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonExit", ComponentTypeName.Button)
    self.buttonNoNiu = GetComponentWithPath(self.root, "Bottom/Action/ButtonShowNone", ComponentTypeName.Button)
    self.buttonHasNiu = GetComponentWithPath(self.root, "Bottom/Action/ButtonShowHave", ComponentTypeName.Button)
    self.buttonLiangPai = GetComponentWithPath(self.root, "Bottom/Action/ButtonLiangPai", ComponentTypeName.Button)

    self.toggleAutoSelectNiu = GetComponentWithPath(self.root, "Bottom/Action/ToggleAutoSelectNiu", ComponentTypeName.Toggle) 

    self.buttonQiangZhuang = GetComponentWithPath(self.root, "Bottom/Action/ButtonQiangZhuang", ComponentTypeName.Button)
    self.buttonNotQiangZhuang = GetComponentWithPath(self.root, "Bottom/Action/ButtonBuQiang", ComponentTypeName.Button)

    self.goBetBtnRoot = GetComponentWithPath(self.root, "Bottom/Action/SelectMultiple", ComponentTypeName.Transform).gameObject
    self.buttonBetNone = GetComponentWithPath(self.goBetBtnRoot, "ButtonCancel", ComponentTypeName.Button)
    self.buttonBet1 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple1", ComponentTypeName.Button)
    self.buttonBet2 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple2", ComponentTypeName.Button)
    self.buttonBet3 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple3", ComponentTypeName.Button)
    self.buttonBet4 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple4", ComponentTypeName.Button)
    self.buttonBet5 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple5", ComponentTypeName.Button)
    self.buttonBet6 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple6", ComponentTypeName.Button)
    self.buttonBet7 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple7", ComponentTypeName.Button)
    self.buttonBet8 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple8", ComponentTypeName.Button)
    self.buttonBet9 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple9", ComponentTypeName.Button)
    self.buttonBet10 = GetComponentWithPath(self.goBetBtnRoot, "ButtonMultiple10", ComponentTypeName.Button)

    self.goQiangZhuangBtnsRoot = GetComponentWithPath(self.root, "Bottom/Action/QiangZhuangBtns", ComponentTypeName.Transform).gameObject
    for i=0,10 do
        self['buttonQiangZhuang_'..i] = GetComponentWithPath(self.goQiangZhuangBtnsRoot, "ButtonMultiple"..i, ComponentTypeName.Button)
        self['textGrayQiangZhuang_'..i] = GetComponentWithPath(self.goQiangZhuangBtnsRoot, "ButtonMultiple"..i.."/GrayText", ComponentTypeName.Text)
        self['textQiangZhuang_'..i] = GetComponentWithPath(self.goQiangZhuangBtnsRoot, "ButtonMultiple"..i.."/Text", ComponentTypeName.Text)
    end
    self.buttonQiangZhuang_Qiang = GetComponentWithPath(self.goQiangZhuangBtnsRoot, "ButtonQiang", ComponentTypeName.Button)
    self.buttonQiangZhuang_BuQiang = GetComponentWithPath(self.goQiangZhuangBtnsRoot, "ButtonBuQiang", ComponentTypeName.Button)

    self.goGoldCoinBetBtnsRoot = GetComponentWithPath(self.root, "Bottom/Action/GoldCoinBetBtns", ComponentTypeName.Transform).gameObject
    self.goldCoinBetArray = {}
    for i=1,5 do
        self.goldCoinBetArray[i] = {}
        self.goldCoinBetArray[i].button = GetComponentWithPath(self.goGoldCoinBetBtnsRoot, "ButtonMultiple"..i, ComponentTypeName.Button)
        self.goldCoinBetArray[i].text = GetComponentWithPath(self.goGoldCoinBetBtnsRoot, "ButtonMultiple"..i .. '/Text', ComponentTypeName.Text)
        self.goldCoinBetArray[i].text_gray = GetComponentWithPath(self.goGoldCoinBetBtnsRoot, "ButtonMultiple"..i .. '/GrayText', ComponentTypeName.Text)
    end

    self.switcher = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher", "UIStateSwitcher");

    --self.buttonReady_fastStart = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady_fastStatr", ComponentTypeName.Button)
    --self.textFastStartLimitTime = GetComponentWithPath(self.buttonReady_fastStart.gameObject, "Text", ComponentTypeName.Text)
end


function TableView:setRoomInfo(roomInfo)
    if self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0 then
        self.textRoomNum.text = AppData.MuseumName .."房号:" .. roomInfo.roomNum
    else
        self.textRoomNum.text = "房号:" .. roomInfo.roomNum
    end

    self.textRoomRule.text = roomInfo.ruleDesc
    self.textRoundNum.text = "(第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局)"
    self.textRoundNum.gameObject:SetActive(false)
end

function TableView:refreshBatteryAndTimeInfo()
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

function TableView:showWifiState(show, wifiLevel)
    for i = 1, #self.goWifiStateArray do
        ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)
    end
end

function TableView:show4GState(show, signalType)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")
end

-- function TableView:showReadyBtn(show)
--    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, show)
--    ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, show and(not ModuleCache.GameManager.iosAppStoreIsCheck))
-- end

-- function TableView:showStartBtn(show)
--    ModuleCache.ComponentUtil.SafeSetActive(self.buttonStart.gameObject, show)
-- end

-- 刷新准备状态,房主显示离开房间,邀请好友,开始游戏.  非房主显示离开房间和邀请好友
function TableView:refreshReadyState(isCreator)

    if isCreator then
        self.switcher:SwitchState("Three");
    else
        self.switcher:SwitchState("Two");
    end
end

--隐藏所有选择按钮
function TableView:hideAllReadyButton()

 self.switcher:SwitchState("Disable");
end


function TableView:showBetBtns_Custom(show, array)
    if (show) then
        for i=1,10 do
            ModuleCache.ComponentUtil.SafeSetActive(self['buttonBet'..i].gameObject, false)
        end
        for i,v in ipairs(array) do
            local key = 'buttonBet'..v
            if(self[key])then
                ModuleCache.ComponentUtil.SafeSetActive(self[key].gameObject, true)
            end
        end
        ModuleCache.ComponentUtil.SafeSetActive(self.goBetBtnRoot, true)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.goBetBtnRoot, false)
    end
end

function TableView:showQiangZhuangBeiShuBtns_Custom(show, array)
    if (show) then
        for i=1,10 do
            ModuleCache.ComponentUtil.SafeSetActive(self['buttonQiangZhuang_'..i].gameObject, false)
        end
        local len = #array
        if(len == 2 and array[1] == 0 and array[2] == 1)then
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonQiangZhuang_Qiang.gameObject, true)
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonQiangZhuang_BuQiang.gameObject, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonQiangZhuang_Qiang.gameObject, false)
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonQiangZhuang_BuQiang.gameObject, false)
            for i,v in ipairs(array) do
                local key = 'buttonQiangZhuang_'..v
                if(self[key])then
                    ModuleCache.ComponentUtil.SafeSetActive(self[key].gameObject, true)
                end
            end
        end

        ModuleCache.ComponentUtil.SafeSetActive(self.goQiangZhuangBtnsRoot, true)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.goQiangZhuangBtnsRoot, false)
    end
end

function TableView:showBetBtns(show, bigBet, isScramble)
    --print_table({}, 'showBetBtns'..(show and 'true' or 'false'))
    if (show) then
        ModuleCache.ComponentUtil.SafeSetActive(self.goBetBtnRoot, true)
        -- ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet1.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet2.gameObject, bigBet ~= 1)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet3.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet4.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet5.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet8.gameObject, (bigBet == 1 and (not isScramble)) or false)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonBet10.gameObject, (bigBet == 1 and isScramble) or false)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.goBetBtnRoot, false)
    end
end

--显示自动选牛选项
function TableView:showAutoSelectToggleBtn(show)
    --ModuleCache.ComponentUtil.SafeSetActive(self.toggleAutoSelectNiu.gameObject, show or false)
end

function TableView:showNiuName(seatData, show, niuName)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    if (show) then
        self.tableHelper:showNiuName(seatHolder, true, niuName)
    else
        self.tableHelper:showNiuName(seatHolder, false, nil)
    end

end

function TableView:showSeatWinScoreCurRound(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showSeatWinScoreCurRound(seatHolder, show, score)
end

function TableView:refreshSeatCardsSelect(seatData, withoutAnim)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    local inHandCards = seatHolder.inhandCardsArray
    for i = 1, #inHandCards do
        self:refreshCardSelect(inHandCards[i], withoutAnim)
    end
end

function TableView:refreshCardSelect(cardHolder, withoutAnim)
    local targetPosY
    if (cardHolder.selected) then
        targetPosY = 30
    else
        targetPosY = 0
    end

    if (withoutAnim) then
        ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, targetPosY, true)
    else
        local sequence = self:create_sequence();
        sequence:Append(cardHolder.cardRoot.transform:DOLocalMoveY(targetPosY, 0.1, true))
    end

end

function TableView:resetSelectedPokers()
    local cardsArray = self.seatHolderArray[1].inhandCardsArray
    for i = 1, #cardsArray do
        self:refreshCardSelect(cardsArray[i], true)
    end
end

function TableView:refreshSeat(seatData, showCardFace, showCardWithAnim, isLiangPai)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    -- 刷新座位基本信息
    self:refreshSeatInfo(seatData)
    -- 刷新座位状态
    self:refreshSeatState(seatData)
    self.tableHelper:showInHandCards(seatHolder, #seatData.inHandPokerList ~= 0)
    self.tableHelper:refreshInHandCards(seatHolder, seatData.inHandPokerList, showCardFace, showCardWithAnim, isLiangPai)
    if (seatData.isDoneComputeNiu) then

        self.tableHelper:setInHandPokersDonePos(seatHolder)
    else
        self.tableHelper:setInHandPokersOriginalPos(seatHolder)
    end
end

-- 刷新座位玩家状态
function TableView:refreshSeatState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:refreshSeatState(seatHolder, seatData)
end

-- 刷新在线状态
function TableView:refreshSeatOfflineState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:refreshSeatOfflineState(seatHolder, seatData)
end

function TableView:refreshSeatInfo(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:refreshSeatInfo(seatHolder, seatData)
end


function TableView:refreshClock(seatData, show, targetTime, curTime)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:refreshClock(seatHolder, show, targetTime, curTime, false)
end

function TableView:refreshDigitalClock(seatData, show, targetTime, curTime)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:refreshClock(seatHolder, show, targetTime, curTime, true)
end

function TableView:showComfirmNiuBtns(show)
    --ModuleCache.ComponentUtil.SafeSetActive(self.buttonHasNiu.gameObject, show)
    --ModuleCache.ComponentUtil.SafeSetActive(self.buttonNoNiu.gameObject, show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonLiangPai.gameObject, show)
end

function TableView:showSelectNiuPanel(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goSelectNiuNumberPanel, show)
    self:refreshSelectedNiuNumbers()
end

function TableView:showContinueBtn(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonContinue.gameObject, show)
end

function TableView:refreshSelectedNiuNumbers()
    local selectedPokersArray = self.seatHolderArray[1].selectedPokersArray or { }
    local totalValue = 0
    for i = 1, 3 do
        if (#selectedPokersArray >= i) then
            local poker = selectedPokersArray[i]
            local number = self.tableHelper:getNumberFormPoker(poker)
            totalValue = totalValue + number
            self.textSelectedNiuNumbersArray[i].text = number .. ""
        else
            self.textSelectedNiuNumbersArray[i].text = ""
        end
    end
    if (#selectedPokersArray ~= 0) then
        self.textSelectedNiuValue.text = totalValue .. ""
    else
        self.textSelectedNiuValue.text = ""
    end
end

function TableView:showNiuNiuEffect(seatData, show, duration, stayTime, delayTime, onComplete)
    if(true)then
        if(onComplete)then
            onComplete()
        end
        return
    end
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showNiuNiuEffect(seatHolder, show, duration, stayTime, delayTime, onComplete)
end


function TableView:hideAllNiuNiuEffect()
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        self.tableHelper:showNiuNiuEffect(seatHolder, false)
    end
end

-- 显示聊天气泡
function TableView:show_chat_bubble(localSeatIndex, content)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local chatBubble = GetComponentWithPath(seatRoot, "State/Group/ChatBubble", ComponentTypeName.RectTransform).gameObject
    local chatText = GetComponentWithPath(chatBubble, "TextBg/Text", ComponentTypeName.Text)
    chatText.text = TableUtil.cut_text(chatText,content .. ' \n',156)
    chatBubble:SetActive(true)
    if seatInfo.timeChatEvent_id then
        CSmartTimer:Kill(seatInfo.timeChatEvent_id)
        seatInfo.timeChatEvent_id = nil
    end
    seatInfo.timeChatEvent_id = nil
    local timeEvent = nil
    timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete( function(t)
        chatBubble:SetActive(false)
    end )
    seatInfo.timeChatEvent_id = timeEvent.id
end

-- 显示表情
function TableView:show_chat_emoji(localSeatIndex, emojiId)
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
    local timeEvent = nil
    timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete( function(t)
        if (curEmoji) then
            ModuleCache.ComponentUtil.SafeSetActive(curEmoji, false)
        end
    end )
    seatHolder.timeChatEmojiEvent_id = timeEvent.id
end



function TableView:show_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(true)
end

function TableView:hide_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(false)
end

function TableView:show_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goSpeaking, show)
end

function TableView:show_cancel_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCancelSpeaking, show)
end

function TableView:showSeatRoundScoreAnim(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showRoundScoreEffect(seatHolder, seatData.localSeatIndex, show, score)
end

function TableView:showRandomBankerEffect(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showRandomBankerEffect(seatHolder, show)
end

function TableView:showQiangZhuangBtns(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonQiangZhuang.gameObject, show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonNotQiangZhuang.gameObject, show)
end

-- 显示或隐藏抢庄标签
function TableView:showQiangZhuangTag(seatData, show, scramble)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showQiangZhuangTag(seatHolder, show, scramble)
end

--显示或隐藏抢庄倍数标签
function TableView:showQiangZhuangBeiShuBubble(seatData, show, beiShu)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showQiangZhuangBeiShuBubble(seatHolder, show, beiShu)
end

function TableView:showQiangZhuangBeiShuTag(seatData, show, beiShu)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self.tableHelper:showQiangZhuangBeiShuTag(seatHolder, show, beiShu)
end

function TableView:refreshContinueTimeLimitText(secs)
    self.textContinueLimitTime.text = string.format("(%d)", secs)
end

function TableView:show_ping_delay(show, delaytime)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingValue.gameObject, show)       
    if(not show)then
        return
    end
    delaytime = math.floor(delaytime * 1000)
    local content = ''
    if(delaytime >= 1000)then
        delaytime = delaytime / 1000
        delaytime = Util.getPreciseDecimal(delaytime, 2)
        content = '<color=#a31e2a>' .. delaytime .. 's</color>'
    elseif(delaytime >= 200)then
        content = '<color=#a31e2a>' .. delaytime .. 'ms</color>'
    elseif(delaytime >= 100)then
        content = '<color=#b5a324>' .. delaytime .. 'ms</color>'
    else
        content = '<color=#44b916>' .. delaytime .. 'ms</color>'
    end
    self.textPingValue.text = content
end

--显示房间信息
function TableView:showRoomInfoAndRuleBtn(show)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.textRoomNum.transform.parent.gameObject, show)    
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonRoomRule.gameObject, show)
end

--显示准备按钮
function TableView:showReadyBtn(show)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, show)
end

--显示金币场准备按钮
function TableView:showReadyBtn(show)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.button_goldcoin_ready.gameObject, show)
end

--显示换桌按钮
function TableView:showChangeRoomBtn(show, gray, leftSecs)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChangeRoom.gameObject, show)
    if(gray)then
        self:setColor(self.buttonChangeRoom.gameObject, Color.New(0.5, 0.5, 0.5, 0.6), true)
    else
        self:setColor(self.buttonChangeRoom.gameObject, nil, true)
    end

    self.buttonChangeRoom.enabled = not gray
    if(leftSecs)then
        self.textChangeRoomLeftSecs.text = string.format('%ds',leftSecs)
        ModuleCache.ComponentUtil.SafeSetActive(self.textChangeRoomLeftSecs.gameObject, true)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.textChangeRoomLeftSecs.gameObject, false)
    end
end

--显示准备提示
function TableView:showWaitReadyTips(show, secs)
    show = show or false
    --ModuleCache.ComponentUtil.SafeSetActive(self.text_goldCoinWaitReadyTip.transform.parent.gameObject, show)
    if(show)then
        --self.text_goldCoinWaitReadyTip.text = string.format('请准备开始:%ds', secs)
        self.text_goldcoin_ready.text = secs or 0
    end
end

--提示
function TableView:showCenterTips(show, content)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.text_goldCoin_tip.transform.parent.gameObject, show)
    if(show)then
        self.text_goldCoin_tip.text = content
    end
end

--显示底注
function TableView:showGoldCoinDiZhu(show, diZhu, curRoundNum, totalRoundCount)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.text_goldCoin_dizhu.transform.parent.gameObject, show)
    if(show)then
        if(curRoundNum and totalRoundCount and diZhu)then
            self.text_goldCoin_dizhu.text = string.format('第%d/%d局 底注:%d', curRoundNum, totalRoundCount, diZhu)
        elseif(diZhu)then
            self.text_goldCoin_dizhu.text = string.format('底注:%d', diZhu)
        elseif(curRoundNum and totalRoundCount)then
            self.text_goldCoin_dizhu.text = string.format('第%d/%d局',curRoundNum, totalRoundCount)
        end
    end
end

--置灰
function TableView:setGray(go, isGray, igoreText)
    if(not self._grayMat)then
        return
    end
    local image = ModuleCache.ComponentManager.GetComponent(go, ComponentTypeName.Image)
    if(image)then
        if(isGray)then
            image.material = self._grayMat
        else
            image.material = nil
        end
    end
    local components = ModuleCache.ComponentUtil.GetComponentsInChildren(go, ComponentTypeName.Image)
    local len = components.Length
    for i=0,len - 1 do
        local image = components[i]
        if(isGray)then
            image.material = self._grayMat
        else
            image.material = nil
        end
    end
    if(not igoreText)then
        local components = ModuleCache.ComponentUtil.GetComponentsInChildren(go, ComponentTypeName.Text)
        local len = components.Length
        for i=0,len - 1 do
            local image = components[i]
            if(isGray)then
                image.material = self._grayMat
            else
                image.material = nil
            end
        end
    end
end


function TableView:setColor(go, color, igoreText)
    color = color or Color.New(1,1,1,1)
    local components = ModuleCache.ComponentUtil.GetComponentsInChildren(go, ComponentTypeName.Image)
    local len = components.Length
    for i=0,len - 1 do
        local image = components[i]
        image.color = color
    end
    if(not igoreText)then
        local components = ModuleCache.ComponentUtil.GetComponentsInChildren(go, ComponentTypeName.Text)
        local len = components.Length
        for i=0,len - 1 do
            local image = components[i]
            image.color = color
        end
    end
end

function TableView:flyGoldToSeat(fromLocalSeatIndex, toLocalSeatIndex, onFinish)
    local fromSeatHolder = self.seatHolderArray[fromLocalSeatIndex]
    local toSeatHolder = self.seatHolderArray[toLocalSeatIndex]
    local parentGo = fromSeatHolder.buttonNotSeatDown.gameObject
    local originalGo = self.goGold
    local targetPos = toSeatHolder.buttonNotSeatDown.transform.position
    local duration = 0.8
    local delayTime = 0.05
    local totalCount = 24
    local goldList = {}
    for i = 1, totalCount do
        local gold = self.tableHelper:genGold(originalGo, parentGo, Vector3.zero, false, true, false)
        gold.transform.parent = self.tranGoldHolder
        table.insert(goldList, gold)
    end
    self.tableHelper:goldFlyToSeat(goldList, targetPos, duration, 0, delayTime, true, onFinish)
end

return TableView