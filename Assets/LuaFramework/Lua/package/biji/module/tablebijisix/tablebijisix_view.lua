---
--- Created by tanqiang.
--- DateTime: 2018/5/8 15:24
---
local ModuleCache = ModuleCache
local UnityEngine = UnityEngine
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameSDKInterface = ModuleCache.GameSDKInterface
local Manager = require("manager.function_manager")
local class = require("lib.middleclass")
local View = require("package.public.module.table_poker.base_table_view")
local TableBiJiSixView = class("TableBiJiSixView", View)
local Util = Util

function TableBiJiSixView:initialize()
    View.initialize(self, "biji/module/tablebiji/biji_sixtable.prefab", "BiJi_SixTable", 0)

    self.buttonRule     = self.GetComponentWithPath(self.root, "Top/TopInfo/RoomID/ButtonRule", self.ComponentTypeName.Button)
    self.buttonResult   = self.GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/PanelDetail/ButtonResult", self.ComponentTypeName.Button)

    self.winDeal        = self.GetComponentWithPath(self.root, "DealWin", self.ComponentTypeName.Transform).gameObject;
    self.winDealPanelBtn= self.GetComponentWithPath(self.root, "DealWin/Panel", self.ComponentTypeName.Transform).gameObject;
    self.matchTimeText  = self.GetComponentWithPath(self.root,"Center/Clock/Text", "TextWrap")
    self.matchTimeObj   = self.GetComponentWithPath(self.root,"Center/Clock", "UIStateSwitcher")
    self.pokers         = self.GetComponentWithPath(self.root,"DealWin/pockers",self.ComponentTypeName.Transform).gameObject;
    self.transMatching      = self.GetComponentWithPath(self.root, "DealWin/Matching", self.ComponentTypeName.Transform);
    self.goStartCompreLogo  = self.GetComponentWithPath(self.root, "ImageCompareLogo", self.ComponentTypeName.Transform).gameObject
    self.cardAssetHolder    = self.GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.biJiAssetHolder    = self.GetComponentWithPath(self.root, "Holder/BiJiAssetHolder", "SpriteHolder")
    self.textCenterTips     = self.GetComponentWithPath(self.root, "Center/Tips/Text", self.ComponentTypeName.Text)
    self.Result             = self.GetComponentWithPath(self.root, "TableResult", self.ComponentTypeName.Transform);
    self.readyCountDown     = self.GetComponentWithPath(self.root,"Bottom/Action/ButtonReady/TextCountDown", self.ComponentTypeName.Text)
    self.tableBackgroundImage = self.GetComponentWithPath(self.root, "Background/ImageBackground", self.ComponentTypeName.Image)
    self.sliderBattery      = self.GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/Battery/ImageBackground/ImageLevel", self.ComponentTypeName.Image)
    self.btnCtrState        = self.GetComponentWithPath(self.root, "Bottom/BtnCtr", "UIStateSwitcher")
    self.animList = {}

    --手牌排序类型
    self.SORT_POKER_TYPE = {
        NONE = 0,
        SIZE = 1,
        COLOR = 2,
    }

    self:initMatchPokersPanel()
    self:initHandPokerItems()
    self:initPanelMatching()
    self:initLeftInfo()
    self:initOtherHandPokers()
end

function TableBiJiSixView:getTotalSeatCount()
    return 6
end

function TableBiJiSixView:refreshBatteryAndTimeInfo()
    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue / 100
    self.sliderBattery.fillAmount = batteryValue
    ModuleCache.ComponentUtil.SafeSetActive(self.imageBatteryCharging.gameObject, GameSDKInterface:GetCurChargeState())
    self.textTime.text = os.date("%H:%M", os.time())

    local signalType = GameSDKInterface:GetCurSignalType()

    if(signalType == "none")then
        self:showWifiState(true, 0)
        self:show4GState(false)
    elseif(signalType == "wifi")then
        local wifiLevel = GameSDKInterface:GetCurSignalStrenth()
        self:showWifiState(true, math.ceil(wifiLevel))
        self:show4GState(false)
    else
        self:showWifiState(false)
        self:show4GState(true, signalType)
    end
end

--初始化左边的信息
function TableBiJiSixView:initLeftInfo()
    self.btnLeftOpen = self.GetComponentWithPath(self.root,"PublicButtons/BtnLeftOpen",self.ComponentTypeName.Button)
    self.leftRoot   = self.GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot",self.ComponentTypeName.Transform).gameObject
    self.btnLeftClose = self.GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/BtnLeftClose",self.ComponentTypeName.Button)
    self.btnGameSetting = self.GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/Bg/BtnGrid/BtnSetting",self.ComponentTypeName.Button)
    self.btnGameRule = self.GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/Bg/BtnGrid/ButtonRuleExplain",self.ComponentTypeName.Button)
    self.btnGameExit = self.GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/Bg/BtnGrid/BtnGameExit",self.ComponentTypeName.Button)

    self.btnLeftOpen.onClick:AddListener( function() self.leftRoot.gameObject:SetActive(true) end )
    self.btnLeftClose.onClick:AddListener( function() self.leftRoot.gameObject:SetActive(false) end)
end

--初始化手牌Item
function TableBiJiSixView:initHandPokerItems()
    self.TransPokers = self.GetComponentWithPath(self.root, "DealWin/pockers", self.ComponentTypeName.Transform);
    local pokerscount = self.TransPokers.childCount;
    self.inHandPokers = {};
    for i = 1, pokerscount do
        self.inHandPokers[i] = {};
        self.inHandPokers[i]["gameobject"] = self.TransPokers:GetChild(i - 1).gameObject;
        self.inHandPokers[i]["image"] = ModuleCache.ComponentUtil.GetComponentInChildren(self.inHandPokers[i]["gameobject"], self.ComponentTypeName.Image);
    end
end

--初始化其他玩家的手牌
function TableBiJiSixView:initOtherHandPokers()
    self.otherPlayerHandPokers = {}
    for playerIndex = 2, self:getTotalSeatCount() do
        self.otherPlayerHandPokers[playerIndex] = {}
        for pokerIndex = 1, 9 do
            local otherPoker = self.GetComponentWithPath(self.root,"PanelHandPokers/player"..playerIndex.."/"..pokerIndex, self.ComponentTypeName.Transform).gameObject
            self.otherPlayerHandPokers[playerIndex][pokerIndex] = otherPoker
        end
    end
end


function TableBiJiSixView:initPanelMatching()
    self.pressLookTips = self.GetComponentWithPath(self.root,"TableResult/Result_1/PressLookTips", self.ComponentTypeName.Transform).gameObject
    self.panelMatchTable = {}
    self.resultObjs = {} --配牌结果展示一起在这里初始化好了
    for seatIndex = 1, self:getTotalSeatCount() do
        local obj = self.GetComponentWithPath(self.root,"PanelMatching/ImageMatching" .. seatIndex, self.ComponentTypeName.Transform)
        if obj ~= nil then
            self.panelMatchTable[seatIndex] = obj.gameObject
        end

        obj = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex, self.ComponentTypeName.Transform)
        if obj ~= nil then
            self.resultObjs[seatIndex] = {}
            self.resultObjs[seatIndex].obj = obj.gameObject
            self.resultObjs[seatIndex].textSurrender = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/TextSurrender", self.ComponentTypeName.Transform).gameObject
            self.resultObjs[seatIndex].imageObj = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/Image", self.ComponentTypeName.Transform).gameObject
            self.resultObjs[seatIndex].imageObjText = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/Image/Text", "TextWrap")
            self.resultObjs[seatIndex].textAddScore = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/AddScore", self.ComponentTypeName.Text)
            self.resultObjs[seatIndex].textTotalScore = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/TotalScore", self.ComponentTypeName.Text)
            self.resultObjs[seatIndex].imgBackground = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/TotalScore/ImgBackground", self.ComponentTypeName.Image)
            self.resultObjs[seatIndex].imgVictory = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/TotalScore/ImgVictory", self.ComponentTypeName.Image)
            self.resultObjs[seatIndex].panelPlus = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/TotalScore/PanelPlus", "TextWrap")
            self.resultObjs[seatIndex].panelMinus = self.GetComponentWithPath(self.root,"TableResult/Result_" .. seatIndex.."/TotalScore/PanelMinus", "TextWrap")
            for tableIndex = 1, 3 do
                if self.resultObjs[seatIndex][tableIndex] == nil then self.resultObjs[seatIndex][tableIndex] = {} end
                local tempPath = "TableResult/Result_".. seatIndex.. "/Table_" .. tableIndex
                self.resultObjs[seatIndex][tableIndex].obj = self.GetComponentWithPath(self.root, tempPath, self.ComponentTypeName.Transform).gameObject
                self.resultObjs[seatIndex][tableIndex].textPlus  = self.GetComponentWithPath(self.root, tempPath.."/TextPlus", "TextWrap")
                self.resultObjs[seatIndex][tableIndex].textMinus = self.GetComponentWithPath(self.root,tempPath .. "/TextMinus", "TextWrap")
                self.resultObjs[seatIndex][tableIndex].paiXing   = self.GetComponentWithPath(self.root, tempPath.."/PaiXing", self.ComponentTypeName.Image)
                for pokerIndex = 1, 3 do
                    obj = self.GetComponentWithPath(self.root,tempPath .. "/Panel/" .. pokerIndex, self.ComponentTypeName.Image)
                    if obj ~= nil then
                        obj.sprite = self.cardAssetHolder:FindSpriteByName("paidi")
                        self.resultObjs[seatIndex][tableIndex][pokerIndex] = obj
                    end
                end
            end
        end
    end
end


--初始化配牌界面
function TableBiJiSixView:initMatchPokersPanel()
    self.WinMatchings = {};
    self.winMatchingPokers = {}
    for i = 1, 3 do
        local obj = self.transMatching:Find("match_" .. i);
        if (obj ~= nil) then
            self.WinMatchings[i] = {};

            local pokersobj = obj:Find("pokersOnMatch");
            self.WinMatchings[i].pokersObj = pokersobj
            self.WinMatchings[i].closeMatchBtn = obj:Find("CloseMatchBtn")
            for j = 1, 3 do
                self.WinMatchings[i][j] = pokersobj:Find(j-1 .. "").gameObject;
                local image = self.WinMatchings[i][j]:GetComponent("Image");
                self.WinMatchings[i]["poker" .. j] = image
                local winMatchingPokerData = {}
                winMatchingPokerData.image = image
                winMatchingPokerData.parentGameObject = pokersobj.gameObject
                pokersobj.gameObject:SetActive(false)
                table.insert(self.winMatchingPokers, winMatchingPokerData)
            end
        end
    end

    self.panelErrHint           = self.GetComponentWithPath(self.root,"DealWin/MatchingErrHint", self.ComponentTypeName.Transform).gameObject
    self.panelExchangeHint      = self.GetComponentWithPath(self.root,"DealWin/MatchingExchangeHint", self.ComponentTypeName.Transform).gameObject
    self.goPanelAnimMatching    = self.GetComponentWithPath(self.root, "DealWin/Matching/Panel", self.ComponentTypeName.Transform).gameObject
    self.buttonSurrender        = self.GetComponentWithPath(self.root,"DealWin/Submit/Surrender",self.ComponentTypeName.Button)
    self.buttonSubmit           = self.GetComponentWithPath(self.root,"DealWin/Submit/Submit",self.ComponentTypeName.Button)
    self.buttonResetAll         = self.GetComponentWithPath(self.root,"DealWin/Submit/ResetAll",self.ComponentTypeName.Button)
    self.btnOrderBySize         = self.GetComponentWithPath(self.root,"DealWin/Submit/OrderBySize",self.ComponentTypeName.Button)
    self.btnOrderByColor        = self.GetComponentWithPath(self.root,"DealWin/Submit/OrderByColor",self.ComponentTypeName.Button)
    --牌类型
    self.PAIXING_TYPE = {
        DUIZI = 1,
        SHUNZI = 2,
        TONGHUA = 3,
        TONGHUASHUN = 4,
        SANTIAO = 5,
    }
    self.buttonPair     = self.GetComponentWithPath(self.root,"DealWin/button/pair",self.ComponentTypeName.Button).gameObject;
    self.buttonStraight = self.GetComponentWithPath(self.root,"DealWin/button/straight",self.ComponentTypeName.Button).gameObject;
    self.buttonFlush    = self.GetComponentWithPath(self.root,"DealWin/button/flush",self.ComponentTypeName.Button).gameObject;
    self.buttonStraightFlush    = self.GetComponentWithPath(self.root,"DealWin/button/straightflush",self.ComponentTypeName.Button).gameObject;
    self.buttonThreeOfAKind     = self.GetComponentWithPath(self.root,"DealWin/button/threeofakind", self.ComponentTypeName.Button).gameObject;
    self.buttons_by_type = {
        [self.PAIXING_TYPE.DUIZI]   = self.buttonPair,
        [self.PAIXING_TYPE.SHUNZI]  = self.buttonStraight,
        [self.PAIXING_TYPE.TONGHUA] = self.buttonFlush,
        [self.PAIXING_TYPE.TONGHUASHUN] = self.buttonStraightFlush,
        [self.PAIXING_TYPE.SANTIAO] = self.buttonThreeOfAKind,
    }
end

function TableBiJiSixView:initSeatHolder(seatHolder, seatRoot, index)

    View.initSeatHolder(self, seatHolder, seatRoot, index)
    if index == 1 or  index == 6  then
        seatHolder.uiStateSwitcher:SwitchState("Left")
    elseif  index == 2 or  index == 3  then
        seatHolder.uiStateSwitcher:SwitchState("Right")
        seatHolder.isInRight = true
    elseif index == 4 then
        seatHolder.uiStateSwitcher:SwitchState("TopRight")
    elseif index == 5 then
        seatHolder.uiStateSwitcher:SwitchState("TopLeft")
    end
    --self.kickBtns[index] = self.GetComponentWithPath(seatRoot, "Info/TextName", self.ComponentTypeName.Button).gameObject
    seatHolder.buttonKick = self.GetComponentWithPath(seatRoot, "Info/ButtonKick", self.ComponentTypeName.Button).gameObject
    if self.kickBtns == nil then self.kickBtns = {} end
    self.kickBtns[seatHolder.buttonKick] = index
end

function TableBiJiSixView:refreshSeat(seatData)
    if seatData == nil or seatData.localSeatIndex == nil then return end
    self:refreshSeatState(seatData)
    self:refreshSeatPlayerInfo(seatData)
end

--刷新座位状态
function TableBiJiSixView:refreshSeatState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
   -- View.refreshSeatState(self, seatData)
    self:showBtnSatus(seatData)

    seatHolder.textScore.text = seatData.curScore
    if(seatData.playerId and (seatData.playerId ~= 0 and seatData.playerId ~= "0")) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, seatData.isReady and (not seatData.curRound))

        local isShow = false
        local mySelfInfo = self.modelData.curTableData.roomInfo.mySeatInfo
        if seatData ~= mySelfInfo and mySelfInfo.isCreator and tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0 then
            isShow = true
        end
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonKick, isShow)
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject, false)
    end
end

function TableBiJiSixView:setRoomInfo(roomNum, curRoundNum, totalRoundCount, wanfaName)
    self.textRoomNum.text = "房号:" .. roomNum
    self.textRoomRule.text = wanfaName.." 第" .. curRoundNum .. "/" .. totalRoundCount .. "局"
end

--显示投降按钮状态
function TableBiJiSixView:showSurrenderBtn(isshowSurrender)
    Manager.SetButtonEnable(self.buttonSurrender,isshowSurrender,not isshowSurrender,true)
    if not isshowSurrender then
        local btnImage = ModuleCache.ComponentManager.GetComponent(self.buttonSurrender.gameObject, self.ComponentTypeName.Image)
        btnImage.color = Color.New(124 / 255, 124 / 255, 124 / 255, 1)
    end
end

--显示隐藏配牌提示按钮
function TableBiJiSixView:showMatchPokerTimeObj(isShow)
    self.matchTimeObj.gameObject:SetActive(isShow)
end

--显示手牌排序按钮
function TableBiJiSixView:showSortBtn(sortType)
    self.btnOrderBySize.gameObject:SetActive(not (sortType == self.SORT_POKER_TYPE.SIZE))
    self.btnOrderByColor.gameObject:SetActive(not (sortType == self.SORT_POKER_TYPE.COLOR))
    self.currentSortType = sortType
end

--配牌完成 需要显示重置个确定按钮
function TableBiJiSixView:showEnterMatchBtn(matchOver)
    self.buttonSubmit.gameObject:SetActive(matchOver)
    self.buttonResetAll.gameObject:SetActive(matchOver)
end

function TableBiJiSixView:showBtnSatus(seatData)
    if seatData == nil or seatData.playerId ~= self.modelData.curTableData.roomInfo.mySeatInfo.playerId then return end
    local roomInfo =  self.modelData.curTableData.roomInfo
    local isFirstCount = tonumber(roomInfo.curRoundNum) == 0
    if isFirstCount  then
        local stateName = seatData.isCreator and "Three" or "Two"
        self.btnCtrState:SwitchState(stateName)
    else
        self.btnCtrState:SwitchState("Zero")
    end
    self:showReadyBtn(not isFirstCount and not seatData.isReady)
    self.buttonReady.transform.localPosition =  Vector3.zero
end

--显示组牌界面
function TableBiJiSixView:showDealTable(ishow)
    ModuleCache.ComponentUtil.SafeSetActive(self.winDeal, ishow)
    if ishow then
        self:showReadyBtn(false)
    else
        for i = 1, #self.WinMatchings do
            self:showCloseMatchBtn(i, false)
        end
        self:showMatchPokerTimeObj(false)
    end
    self.matchTimeObj:SwitchState(ishow and "Matching" or "Matchend")
end

--开始游戏 关闭其他没人位置
function TableBiJiSixView:showStartSeat(seatDatas)
    for localIndex, v in pairs(self.seatHolderArray) do
        for _, v in pairs(seatDatas) do
            if v.localSeatIndex ~= nil and v.localSeatIndex == localIndex  then
                break
            end
        end
        ModuleCache.ComponentUtil.SafeSetActive(v.buttonNotSeatDown.gameObject, false)
    end
end

-- 设置颜色
function TableBiJiSixView:setExchangePokerColor(indexMatch,index,isSelected)
    if(indexMatch == 4) then
        if(isSelected) then
            self.tenthPokerImage.color = UnityEngine.Color(0.51,0.51,0.51,1);
        else
            self.tenthPokerImage.color = UnityEngine.Color(1,1,1,1);
        end
        return;
    end
    if(indexMatch == 5) then
        return;
    end
    if(isSelected) then
        self.WinMatchings[indexMatch]["poker" .. index].color = UnityEngine.Color(0.51,0.51,0.51,1);
    else
        self.WinMatchings[indexMatch]["poker" .. index].color = UnityEngine.Color(1,1,1,1);
    end
end

function TableBiJiSixView:setErrHintActive(isActive)
    self.panelErrHint:SetActive(isActive);
    if(isActive) then
        self:subscibe_time_event(2, false, 0):OnComplete(function(t)
            self.panelErrHint:SetActive(false);
        end)
    end
end

function TableBiJiSixView:setExchangeHintActive(isActive)
    self.panelExchangeHint:SetActive(isActive);
end

--其他玩家手牌的显示
function TableBiJiSixView:showOtherPlayersPokers(index, pokersNum)
    if self.otherPlayerHandPokers[index] == nil then return end
    for i = 1, pokersNum do
        local pokerObj = self.otherPlayerHandPokers[index][i]
        if pokerObj ~= nil then
            pokerObj:SetActive(true)
        end
    end
end

-- 刷新手中的牌
function TableBiJiSixView:refreshPokersInHand(pokers, isFirst, onFinish)
    if(isFirst) then
        local duration = 0.06;
        for i = 1, #pokers do
            self.inHandPokers[i]["image"].sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(pokers[i]))
            self:subscibe_time_event(duration * i, false, 0):OnComplete(function(t)
                self.inHandPokers[i]["gameobject"]:SetActive(true)
                if(i == #pokers) and onFinish then
                     onFinish()
                end
            end)
        end
    else
        for i = 1, 10 do
            if i > #pokers then
                self.inHandPokers[i]["gameobject"]:SetActive(false)
            else
                local sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(pokers[i]))
                self.inHandPokers[i]["image"].sprite = sprite
                self.inHandPokers[i]["gameobject"]:SetActive(true)
            end
        end
    end
end

function TableBiJiSixView:setSelfImageActive(isActive)
    local selfImage = self.GetComponentWithPath(self.root,"Seats/1/Seat(Clone)", self.ComponentTypeName.Transform).gameObject;
    selfImage:SetActive(isActive);
end

function TableBiJiSixView:playAnimHandToMatch(handIndex, matchIndex, detailIndex,onFinishInvoke)
    local cardHolder = self.inhandPokers[handIndex];
    cardHolder.cardRoot.transform.localPosition = UnityEngine.Vector3.zero;
    cardHolder.cardRoot.transform.parent.gameObject:SetActive(false);
    cardHolder.cardRoot.transform.localScale = UnityEngine.Vector3.one;
    if(onFinishInvoke) then
        onFinishInvoke();
    end
end

--刷新选中的牌
function TableBiJiSixView:refreshCardSelect(inHandPoker, withoutAnim)
    local targetPosY = inHandPoker.selected and 30 or 0
    if(not withoutAnim) then
        ModuleCache.TransformUtil.SetY(inHandPoker.image.transform, targetPosY, true)
    else
        local sequence = self:create_sequence();
        sequence:Append(inHandPoker.image.transform:DOLocalMoveY(targetPosY, 0.1, true))
    end
end

--显示或者隐藏掉组牌
function TableBiJiSixView:showMatchingPokers(index, isShow)
    if(self.WinMatchings[index].pokersObj ~= nil) then
        self.WinMatchings[index].pokersObj.gameObject:SetActive(isShow);
    end
end

--是否显示道上的重置按钮
function TableBiJiSixView:showCloseMatchBtn(index, isShow)
    if(self.WinMatchings[index].closeMatchBtn ~= nil) then
        self.WinMatchings[index].closeMatchBtn.gameObject:SetActive(isShow);
    end
end

-- 设置道上的牌
function TableBiJiSixView:setMatchingShow(index, pokerList, isForceActive)
    if(index > 3) then
        return;
    end
    if(isForceActive) then
        self:showMatchingPokers(index, true)
    end
    local _index=1;
    for _,v in ipairs(pokerList) do
        local sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(v));
        self.WinMatchings[index]["poker" .. _index].sprite= sprite;
        _index = _index+1;
    end
    self:showCloseMatchBtn(index, true)
end

function TableBiJiSixView:setMatchingActive(index, isActive)
    if self.panelMatchTable[index] == nil then return end
    self.panelMatchTable[index]:SetActive(isActive)
end


function TableBiJiSixView:showPlayingNotify(ishow)
    self.textCenterTips.text = "等待下一局...";
    self.textCenterTips.transform.parent.gameObject:SetActive(ishow);
    --self.buttonStart.gameObject:SetActive(false);
    --self.buttonReady.gameObject:SetActive(false);
end

--显示喜牌
function TableBiJiSixView:ShowXiPai(XiPaiText)
    self.textXiPai.text = XiPaiText;
    if(XiPaiText == "") then
        self.textXiPaiTitle.gameObject:SetActive(false);
    else
        self.textXiPaiTitle.gameObject:SetActive(true);
    end
end

--播放配好牌的动画
function TableBiJiSixView:playConfirmPokerAnimStep1(index, pokersNum, onFinish, immediately)
    local resultObj = self.resultObjs[index]
    if resultObj == nil then return end
    if resultObj.obj then
        -- 隐藏喜牌动画
        for k = 1,4 do
            local curXipaiImage = self.GetComponentWithPath(self.root, "TableResult/Result_"..index .."/XipaiScore/ImgXipai"..k, self.ComponentTypeName.Image);
            curXipaiImage.gameObject:SetActive(false);
        end
    end
    if index == 1 then
        if(onFinish)then onFinish() end
        return
    end
    local handPokers = {}
    for i = 1, pokersNum do
        local poker = {}
        --poker.go = self.GetComponentWithPath(self.root,"PanelHandPokers/player"..index.."/"..i, self.ComponentTypeName.Transform).gameObject;
        --poker.go:SetActive(true)
        poker.go = self.otherPlayerHandPokers[index][i]
        poker.originalPos = poker.go.transform.position
        handPokers[i] = poker
    end

    local originalPos = handPokers[5].go.transform.localPosition
    local sequence = self:create_sequence();
    local duration = 0.5 * ((immediately and 0) or 1)
    for i = 1,#handPokers do
        local poker = handPokers[i]
        local targetPos = {}
        targetPos.y = originalPos.y + (5 - i) * 10
        sequence:Join(poker.go.transform:DOLocalMoveY(targetPos.y, duration, true))
    end

    sequence:OnComplete(function()
        for i=1,#handPokers do
            local poker = handPokers[i]
            poker.go.transform.position = poker.originalPos
            poker.go:SetActive(false)
        end
        if(onFinish)then onFinish() end
    end)

end

function TableBiJiSixView:playComfirmPokerAnimStep2(index, onFinish, immediately)
    self:showResultTable(true)
    local resultObjs = self.resultObjs[index]
    if resultObjs == nil then return end
    resultObjs.obj:SetActive(true)
    print("=============特么的 我需要动画啊!=======================")
    local sequence = self:create_sequence();
    local duration = 0.25 * ((immediately and 0) or 1)
    local delayTime = 0.01 * ((immediately and 0) or 1)
    for tableIndex = 1, 3 do
        for pokerIndex = 1, 3 do
            local poker = resultObjs[tableIndex][pokerIndex]
            if poker ~= nil then
                local originalScale = poker.transform.localScale
                poker.transform.localScale = originalScale * 0.5
                sequence:Join(poker.transform:DOScale(originalScale.x, duration):SetDelay(delayTime * pokerIndex))
                ModuleCache.CustomerUtil.SetAlpha(poker,0)
                sequence:Join(ModuleCache.CustomerUtil.FadeAlpha(poker,1,duration):SetDelay(delayTime * pokerIndex))
            end
        end
    end
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end
    end)
end

function TableBiJiSixView:getImageNameFromPoker(poker)
    --S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
    local spriteName
    local numberStr = poker.Number == 14 and 1 or  poker.Number
    if (poker.Color == 4) then
        spriteName = "heitao_" .. numberStr
    elseif (poker.Color == 3) then
        spriteName = "hongtao_" .. numberStr
    elseif (poker.Color == 2) then
        spriteName = "meihua_" .. numberStr
        spriteName = numberStr == 15 and "Joker2" or spriteName
    elseif (poker.Color == 1) then
        spriteName = "fangkuai_" .. numberStr
        spriteName = numberStr == 15 and "Joker1" or spriteName
    end
    return spriteName;
end

function TableBiJiSixView:setDealBtnActive(buttonType, isActive)
    local button = self.buttons_by_type[buttonType]
    if button == nil then return end
    ModuleCache.ComponentManager.GetComponent(button, self.ComponentTypeName.Button).interactable = isActive
    local imageActive = button.transform:GetChild(0).gameObject;
    local imageInactive = button.transform:GetChild(1).gameObject;
    imageActive:SetActive(isActive);
    imageInactive:SetActive(not isActive);
end


--开始比牌
function TableBiJiSixView:playStartCompareAnim(seatInfo, callback)
    if seatInfo == nil then return end
    self.pressLookTips:SetActive(false)
    self:showMatchPokerTimeObj(false)
    self.goStartCompreLogo:SetActive(true)
    self:playCompareVocie(0,seatInfo)
    self.showResultId =  self:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
        self.goStartCompreLogo:SetActive(false)
        if(callback)then callback() end -- --不需要等待1秒再比牌
    end).id
end

function TableBiJiSixView:showResultTable(ishow)
    self.Result.gameObject:SetActive(ishow);
end


--查看我的配置情况
function TableBiJiSixView:lookMyPokersMatch(isShow, seatInfo, matchData)
    if isShow and (matchData == nil or #matchData.pokers == 0) then return end
    local resultObjs = self.resultObjs[seatInfo.localSeatIndex]
    local paiBeiSprite = self.cardAssetHolder:FindSpriteByName("paidi")
    for matchIndex = 1, 3 do
        for pokerIndex = 1, 3 do
            local poker = resultObjs[matchIndex][pokerIndex]
            if isShow then
                local tempIndex = pokerIndex + (matchIndex - 1) * 3
                poker.sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(matchData.pokers[tempIndex]))
            else
                poker.sprite = paiBeiSprite
            end
        end
    end
    self.pressLookTips:SetActive(not isShow)
end


function TableBiJiSixView:showOncePlayersResult(seatInfo, matchIndex, resultData)
    if seatInfo == nil or matchIndex == 0 then return end
    local resultObjs = self.resultObjs[seatInfo.localSeatIndex]
    if resultObjs == nil then return end
    resultObjs.obj:SetActive(true)
    if self:isShowSurrender(resultObjs, resultData) then return end
    local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
    local paiBeiSprite = self.cardAssetHolder:FindSpriteByName("paidi")
    for pokerIndex = 1, 3 do
        local tempIndex = pokerIndex + (matchIndex - 1) * 3
        local poker = resultObjs[matchIndex][pokerIndex]
        poker.sprite = paiBeiSprite
        local sequence = self:create_sequence();
        sequence:Append(poker.transform:DOLocalRotate(targetRotate, 0.2, DG.Tweening.RotateMode.Fast):SetDelay(0.2):OnComplete(function()
            poker.sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(resultData.pokers[tempIndex]));
        end))
        sequence:Append(poker.transform:DOLocalRotate(originalRotate, 0.2, DG.Tweening.RotateMode.Fast))
    end
    coroutine.wait(0.3)
    resultObjs[matchIndex].paiXing.sprite = self.biJiAssetHolder:FindSpriteByName("Table_PaiXing"..resultData.typeOfPokers[matchIndex])
    resultObjs[matchIndex].paiXing:SetNativeSize()
    resultObjs[matchIndex].paiXing.gameObject:SetActive(true)
    if(tonumber(resultData.scoreOfPokers[matchIndex]) > 0) then
        resultObjs[matchIndex].textPlus.text ="+" .. resultData.scoreOfPokers[matchIndex];
    else
        resultObjs[matchIndex].textMinus.text = resultData.scoreOfPokers[matchIndex];
    end
    self:playCompareVocie(resultData.typeOfPokers[matchIndex], seatInfo)
end

--显示本次比牌最终结果
function TableBiJiSixView:showLastResult(seatInfo, resultData)
    if seatInfo == nil then return end
    local resultObjs = self.resultObjs[seatInfo.localSeatIndex]
    if resultObjs == nil then return end
    --通关奖励
    local scoreOfRound = tonumber(resultData.scoreOfRound)
    if scoreOfRound > 0 then
        resultObjs.imageObjText.text = scoreOfRound
        resultObjs.imageObj:SetActive(true)
    end
    --喜牌特效
    self:isShowXiPai(resultData, seatInfo.localSeatIndex, resultObjs)
    --本局最终分数
    self:convertNumIntoImageInTotal(seatInfo.localSeatIndex, resultData.totalScore)
end

--处理投降
function TableBiJiSixView:isShowSurrender(resultObjs, resultData)
    if not resultData.isSurrender then return false end
    resultObjs.textSurrender:SetActive(true)
    for i = 1, 3 do
        if resultObjs[i] ~= nil then
            resultObjs[i].obj:SetActive(false)
        end
    end
    return true
end

function TableBiJiSixView:isShowXiPai(resultData, seatIndex, resultObjs)
    if #resultData.typeOfXipai == 0 then return  end
    for k = 1,#resultData.typeOfXipai do
        local tempPath = "TableResult/Result_" .. seatIndex
        local curXipaiImage = self.GetComponentWithPath(self.root,tempPath.. "/XipaiScore/ImgXipai"..k, self.ComponentTypeName.Image);
        local curXipaiText = self.GetComponentWithPath(self.root, tempPath.."/XipaiScore/ImgXipai"..k.."/Text","TextWrap");
        local xiPaiType = resultData.typeOfXipai[k] == 9 and 8 or resultData.typeOfXipai[k]
        if(resultData.XipaiScores[k] ~= 0) then
            local name = "Table_Xipai"..xiPaiType;
            local sprite = self.biJiAssetHolder:FindSpriteByName(name);
            local animPrefab  = self.GetComponentWithPath(self.root,"TableResult/XipaiAnim/Anim_PaiXing_"..xiPaiType, self.ComponentTypeName.Transform).gameObject;
            local anim = ModuleCache.ComponentUtil.InstantiateLocal(animPrefab, curXipaiImage.gameObject)
            table.insert(self.animList,anim);
            curXipaiImage.sprite = sprite;
            curXipaiText.text = resultData.XipaiScores[k];
            curXipaiImage.gameObject:SetActive(true);
            self:subscibe_time_event(0.2, false, 0):OnComplete(function(t)
                curXipaiText.gameObject:SetActive(true);
            end)
        end
    end
end

function TableBiJiSixView:convertNumIntoImageInTotal(index, score)
    local resultObjs = self.resultObjs[index]
    if resultObjs == nil then return end
    local winSprite;
    resultObjs.imgBackground.gameObject:SetActive(true);
    resultObjs.imgVictory.gameObject:SetActive(true);
    if(score >= 0) then
        winSprite = self.biJiAssetHolder:FindSpriteByName("win");
        resultObjs.panelPlus.gameObject:SetActive(true);
        resultObjs.panelMinus.gameObject:SetActive(false);
        resultObjs.panelPlus.text = "+" .. score;
    else
        winSprite = self.biJiAssetHolder:FindSpriteByName("lose")
        resultObjs.panelPlus.gameObject:SetActive(false);
        resultObjs.panelMinus.gameObject:SetActive(true);
        resultObjs.panelMinus.text = "-"..math.abs(score);
    end
    resultObjs.imgVictory.sprite = winSprite;
end


function TableBiJiSixView:playCompareVocie(key, seatInfo)
    if(not key) then return; end
    local voiceName = ""
    local path = "";
    if(key == 0) then
        voiceName = "start_compare";
    elseif(key == 1) then
        voiceName = "wulong"
    elseif(key == 2) then
        voiceName = "duizi"
    elseif(key == 3) then
        voiceName = "shunzi"
    elseif(key == 4) then
        voiceName = "tonghua"
    elseif(key == 5) then
        voiceName = "tonghuashun"
    elseif(key == 6) then
        voiceName = "santiao"
    end
    --男性播放女声
    if(seatInfo.playerInfo and seatInfo.playerInfo.gender == 2) then
        path = "man/" .. voiceName
    else
        path = "woman/" .. voiceName
    end
    ModuleCache.SoundManager.play_sound("biji", "biji/sound/bijisound/" .. path .. ".bytes", voiceName)
end

    --清理小结算界面 重置状态
function TableBiJiSixView:closeResultTable()
    self:showResultTable(false)
    self.goStartCompreLogo:SetActive(false)
    if self.showResultId ~= nil then
        CSmartTimer:Kill(self.showResultId)
        self.showResultId = nil
    end
    for index, result in pairs(self.resultObjs) do
        result.obj:SetActive(false)
        result.imgBackground.gameObject:SetActive(false)
        result.imgVictory.gameObject:SetActive(false)
        result.panelPlus.gameObject:SetActive(false)
        result.panelMinus.gameObject:SetActive(false)
        result.imageObj:SetActive(false)
        result.textAddScore.text = ""
        result.textTotalScore.text = ""
        result.textSurrender:SetActive(false)
        for i = 1, 3 do
            result[i].obj:SetActive(true)
            for j = 1, 3 do
                result[i][j].sprite = self.cardAssetHolder:FindSpriteByName("paidi")
            end
            result[i].paiXing.gameObject:SetActive(false)
            result[i].textPlus.text     = ""
            result[i].textMinus.text    = ""
        end
        -- 喜牌的动画会稍微晚点，所以
        for k = 1,4 do
            local curXipaiImage = self.GetComponentWithPath(self.root,"TableResult/Result_".. index .."/XipaiScore/ImgXipai"..k, self.ComponentTypeName.Image);
            curXipaiImage.gameObject:SetActive(false);
            local curXipaiText = self.GetComponentWithPath(self.root,"TableResult/Result_".. index .."/XipaiScore/ImgXipai"..k.."/Text","TextWrap");
            curXipaiText.gameObject:SetActive(false);
        end
    end

    for i = 1,#self.animList do
        UnityEngine.Object.Destroy(self.animList[i].gameObject)
    end
    self.animList = {};
end

return TableBiJiSixView