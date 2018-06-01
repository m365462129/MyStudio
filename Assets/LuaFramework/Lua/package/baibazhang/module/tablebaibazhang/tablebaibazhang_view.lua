local class = require("lib.middleclass");
local View = require('core.mvvm.view_base');
local ModuleCache = ModuleCache
local ComponentTypeName = ComponentTypeName
---@class TableBaiBaZhangView
local TableBaiBaZhangView = class('tableBaiBaZhangView', View);
local TableBaiBaZhangHelper = require("package/baibazhang/module/tablebaibazhang/tablebaibazhang_helper")
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath;
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;
local Instantiate = ModuleCache.ComponentUtil.InstantiateLocal;
local GameSDKInterface = ModuleCache.GameSDKInterface
local clockCountStopFlag = false;
local table = table


function TableBaiBaZhangView:initialize(...)
    self.packageName = 'baibazhang'
    self.moduleName = 'tablebaibazhang'
    View.initialize(self, "baibazhang/module/tablebaibazhang/baibazhang_table.prefab", "BaiBaZhang_Table", 0, true);
    self.spritesNameInhand = {};
    self.animList = {};
    self.widthText = GetComponentWithPath(self.root, "WidthText", ComponentTypeName.Text)

    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image)
    self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)
    -- body
    self.fastMatching = GetComponentWithPath(self.root,"DealWin/Matching/FastMatching",ComponentTypeName.Transform).gameObject;
    self.tenthPoker = GetComponentWithPath(self.root,"DealWin/Matching/10thPoker",ComponentTypeName.Transform).gameObject;
    self.tenthPokerImage = GetComponentWithPath(self.root,"DealWin/Matching/10thPoker/pokersOnMatch/10",ComponentTypeName.Image)
    self.imgBiji = GetComponentWithPath(self.root,"Background/ImageBiJi",ComponentTypeName.Image).gameObject;
    self.imgShucheng = GetComponentWithPath(self.root,"Background/ImageShucheng",ComponentTypeName.Image).gameObject;
    self.buttonRule = GetComponentWithPath(self.root,"Top/TopInfo/RoomInfo/ButtonRule",ComponentTypeName.Button);
    self.ruleHint = GetComponentWithPath(self.root,"Top/TopInfo/RoomID/RuleHint",ComponentTypeName.Button);
    self.buttonSetting = GetComponentWithPath(self.root, "Top/BatteryTime/ButtonSettings", ComponentTypeName.Button)
    self.buttonLocation = GetComponentWithPath(self.root, "Top/BatteryTime/ButtonLocation", ComponentTypeName.Button)

    self.buttonActivity = GetComponentWithPath(self.root, "PublicButtons/ButtonActivity", ComponentTypeName.Button)
    self.spriteActivityRedPoint = GetComponentWithPath(self.root, "PublicButtons/ButtonActivity/RedPoint", ComponentTypeName.Image)

    self:showActivityBtn(false)

    self.buttonExit = GetComponentWithPath(self.root, "Ready/Panel/exit", ComponentTypeName.Button)
    self.buttonExit2 = GetComponentWithPath(self.root, "Ready/Panel/exit2", ComponentTypeName.Button)
    self:bindButtons();
    self.seatPrefab = GetComponentWithPath(self.root, "Holder/Seat", ComponentTypeName.Transform).gameObject;
    self.panelErrHint = GetComponentWithPath(self.root,"DealWin/MatchingErrHint",ComponentTypeName.Transform).gameObject;
    self.panelExchangeHint = GetComponentWithPath(self.root,"DealWin/MatchingExchangeHint",ComponentTypeName.Transform).gameObject;
    self.goPanelAnimMatching = GetComponentWithPath(self.root, "DealWin/Matching/Panel", ComponentTypeName.Transform).gameObject
    self.buttonChat = GetComponentWithPath(self.root, "Bottom/Action/ButtonChat", ComponentTypeName.Button)
    self.buttonMic = GetComponentWithPath(self.root, "Bottom/Action/ButtonMic", ComponentTypeName.Button)    
    self.goSpeaking = GetComponentWithPath(self.root, "Speaking", ComponentTypeName.Transform).gameObject
    self.goCancelSpeaking = GetComponentWithPath(self.root, "CancelRecord", ComponentTypeName.Transform).gameObject
    self.goClock = GetComponentWithPath(self.root, "DealWin/Clock", ComponentTypeName.Transform).gameObject
    --房間信息組件
    self.textClock = GetComponentWithPath(self.root,"DealWin/Clock/Text","TextWrap")
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomID/Text", ComponentTypeName.Text);
    self.textRoomRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/PanelDetail/Text", ComponentTypeName.Text);
    self.textRoundNum = GetComponentWithPath(self.root, "Center/RoundNum/Text", ComponentTypeName.Text);
    self.textXiPai = GetComponentWithPath(self.root, "DealWin/HintXipai/XiPai",ComponentTypeName.Text);
    self.textXiPaiTitle = GetComponentWithPath(self.root, "DealWin/HintXipai/Title",ComponentTypeName.Text);
    self.textNotReady = GetComponentWithPath(self.root, "Ready/NotReady/Text",ComponentTypeName.Text);
    self.textCenterTips = GetComponentWithPath(self.root, "Center/Tips/Text", ComponentTypeName.Text);
    --图集
    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.BiJiAssetHolder = GetComponentWithPath(self.root, "Holder/BiJiAssetHolder", "SpriteHolder")
    
    self.SpecialTypeAssetHolder = GetComponentWithPath(self.root, "Holder/SpecailTypeAssetHolder", "SpriteHolder")
    self.uiStateSwitcherSeatPrefab = GetComponentWithPath(self.root, "Holder/Seat", "UIStateSwitcher")
    --self.cardAssetHolder =  GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.niuPointAssetHolder = GetComponentWithPath(self.root, "Holder/NiuNumAssetHolder", "SpriteHolder")  
    self.resetAll = GetComponentWithPath(self.root,"DealWin/Submit/ResetAll",ComponentTypeName.Transform).gameObject;
    self.orderSequence = GetComponentWithPath(self.root,"DealWin/Submit/OrderBySequence",ComponentTypeName.Transform).gameObject;
    self.orderColor = GetComponentWithPath(self.root,"DealWin/Submit/OrderByColor",ComponentTypeName.Transform).gameObject;
    
    self.WinDeal = GetComponentWithPath(self.root, "DealWin", ComponentTypeName.Transform).gameObject;
    self.pokers = GetComponentWithPath(self.root,"DealWin/pockers",ComponentTypeName.Transform).gameObject;
    self.TransMatching = GetComponentWithPath(self.root, "DealWin/Matching", ComponentTypeName.Transform);
    --结果
    self.panelNotReadyConfirm = GetComponentWithPath(self.root,"Ready/NotReady",ComponentTypeName.Transform); 
    self.Result = GetComponentWithPath(self.root, "TableResult", ComponentTypeName.Transform);
    self.SelfResult = GetComponentWithPath(self.root, "TableResult/SelfTable", ComponentTypeName.Transform).gameObject;
    self.MinusOneResult = GetComponentWithPath(self.root, "TableResult/MinusOneTable", ComponentTypeName.Transform);
    self.MinusTwoResult = GetComponentWithPath(self.root, "TableResult/MinusTwoTable", ComponentTypeName.Transform);
    self.PlusOneResult = GetComponentWithPath(self.root, "TableResult/PlusOneTable", ComponentTypeName.Transform);
    self.MinusZeroResult  = GetComponentWithPath(self.root, "TableResult/MinusZeroTable", ComponentTypeName.Transform);
    self.PlusTwoResult = GetComponentWithPath(self.root, "TableResult/PlusTwoTable", ComponentTypeName.Transform);
    self.goStartCompreLogo = GetComponentWithPath(self.root, "ImageCompareLogo", ComponentTypeName.Transform).gameObject
    self.goGState2G = GetComponentWithPath(self.root, "Top/BatteryTime/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "Top/BatteryTime/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "Top/BatteryTime/GState/4g", ComponentTypeName.Transform).gameObject
    self.sliderBattery = GetComponentWithPath(self.root, "Top/BatteryTime/Battery", ComponentTypeName.Slider)
    self.textTime = GetComponentWithPath(self.root, "Top/BatteryTime/Time/Text", ComponentTypeName.Text)
    self.textPingValue = GetComponentWithPath(self.root, "Top/BatteryTime/PingVal", ComponentTypeName.Text)
    self.readyCountDown = GetComponentWithPath(self.root,"Ready/ready2/TextCountDown",ComponentTypeName.Text)
    self.readyPanel = GetComponentWithPath(self.root,"Ready",ComponentTypeName.Transform).gameObject
    self.goDealWinPokers = GetComponentWithPath(self.root,"DealWin/pockers",ComponentTypeName.Transform).gameObject
    self.winSpecialType = GetComponentWithPath(self.root,"DealWin/SpecialTypeNotice",ComponentTypeName.Transform).gameObject;
    self.textSpecialType = GetComponentWithPath(self.root,"DealWin/SpecialTypeNotice/Center/TextTipInfo",ComponentTypeName.Text)
    self.centerRule = GetComponentWithPath(self.root,"Center/RoomRule/Text",ComponentTypeName.Text);
    self.goWifiStateArray = {}    
    for i=1,5 do
        local goState = GetComponentWithPath(self.root, "Top/BatteryTime/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end
    self.isWaitForShowResult = false;
    local matchingcount = self.TransMatching.childCount;
    self.WinMatchings = {};

    self.winMatchingPokers = {}
    
    for i = 1, matchingcount-4 do
        --print(i);
        --print(self.TransMatching:GetChild(i-1).name);
        --self.WinMatchings[i]=self.TransMatching:GetChild(i-1);
        self.WinMatchings[i] = {};
        self.WinMatchings[i]["pokersWin"] = self.TransMatching:GetChild(i+1):Find("pokersOnMatch");
        if(self.WinMatchings[i]["pokersWin"] ~= nil) then
            local pokercount = self.WinMatchings[i]["pokersWin"].childCount;
        
            for j = 1, pokercount do
                self.WinMatchings[i][j] = self.WinMatchings[i]["pokersWin"]:GetChild(j - 1).gameObject;
            --self.WinMatchings[i]["poker"]=ModuleCache.ComponentUtil.GetComponentInChildren(self.WinMatchings[i][j],"Image");
                local image = self.WinMatchings[i][j]:GetComponent("Image");
                self.WinMatchings[i]["poker" .. j] = image
                local winMatchingPokerData = {}
                winMatchingPokerData.image = image
                winMatchingPokerData.parentGameObject = image.transform.parent.gameObject
                winMatchingPokerData.parentGameObject:SetActive(false)
                table.insert(self.winMatchingPokers, winMatchingPokerData)
            end
        end
    end

    self.TransPokers = GetComponentWithPath(self.root, "DealWin/pockers", ComponentTypeName.Transform);
    local pokerscount = self.TransPokers.childCount;
    self.inHandPokers = {};
    
    for i = 1, pokerscount do
        self.inHandPokers[i] = {};
        self.inHandPokers[i]["gameobject"] = self.TransPokers:GetChild(i - 1).gameObject;
        self.inHandPokers[i]["image"] = ModuleCache.ComponentUtil.GetComponentInChildren(self.inHandPokers[i]["gameobject"], ComponentTypeName.Image);
    end
    self.srcSeatHolderArray = {}
    local localSeatIndex = 1
    for i=1,6 do        
        local seatHolder = {}
        local seatPosTran = GetComponentWithPath(self.root, "Center/Seats/" .. i, ComponentTypeName.Transform)

        local goSeat = ModuleCache.ComponentUtil.InstantiateLocal(self.uiStateSwitcherSeatPrefab.gameObject, seatPosTran.gameObject)     
        seatHolder.pokerAssetHolder = self.cardAssetHolder
        seatHolder.niuPointAssetHolder = self.niuPointAssetHolder
        
        if(i == 1)then
            TableBaiBaZhangHelper:initSeatHolder(seatHolder, i, goSeat, nil)  
            --seatHolder.goNiuPoint = self.goNiuPoint
            --seatHolder.imageNiuPoint = self.imageNiuPoint  
            --seatHolder.imageComputeDone = self.imageComputeDone
            --seatHolder.transDonePokersPos = self.transDonePokersPos
            --seatHolder.goNiuNiuEffect = self.goNiuNiuEffect
        else
            TableBaiBaZhangHelper:initSeatHolder(seatHolder, i, goSeat, nil)        
        end
        
        TableBaiBaZhangHelper:refreshSeatInfo(seatHolder, {})      --初始化
        
        seatHolder.goTmpBankerPos = self.goTmpBankerPos
        seatHolder.goTmpPokerHeapPos = self.goTmpPokerHeapPos   --牌堆位置

        seatHolder.clockHolder.goClock = goClock
        seatHolder.clockHolder.textClock = textClock

        self.srcSeatHolderArray[i] = seatHolder
        ModuleCache.ComponentManager.SafeSetActive(seatHolder.seatRoot, false)
    end    

    self:refresh_table_bg()
    self:SetBtnInviteActive(false)
--set(self);
--self:SetRoomInfo();
end

function TableBaiBaZhangView:showActivityBtn(show)
    show = show or false
    if(self.buttonActivity)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonActivity.gameObject, show)
    end
end

function TableBaiBaZhangView:SetSpecialTypeText(text)
    self.textSpecialType.text = "<size=32>获得特殊牌型<color=#b13a1f>("..text..")</color>是否选择不参与三道牌的比牌？</size>\n\n\n<size=25><color=#b13a1f>(确定将不参与普通牌的比较，直接得分)</color></size>";
end

function TableBaiBaZhangView:CheckSpriteInHand()
    local pokersCount = self.TransPokers.childCount;
    local inHandPokers = self.inHandPokers
    for i = 1, pokersCount do
        if(not inHandPokers[i]["gameobject"].activeSelf) then
            return false;
        end

        local curSprite = inHandPokers[i]["image"].sprite;
        for j = i + 1,pokersCount do
            if (inHandPokers[j]["gameobject"].activeSelf) then
                if(curSprite == inHandPokers[j]["image"].sprite) then
                    print_debug("发现重复牌！！！")
                    if ModuleCache.GameManager.isEditor then
                        self.subscibe_time_event(0.01, false, 0):OnComplete(function(t)
                            ModuleCache.GameSDKInterface:PauseEditorApplication(true)
                        end)
                    else
                        ModuleCache.GameManager.logout()
                    end
                    -- 故意设置错误代码好上报Bugly
                    if self.oringinalServerPokers then
                        log_table(self.oringinalServerPokers)
                    end
                    local test =  kjkd > 0
                    return true;
                end
            end
        end
    end
    return false;
end

function TableBaiBaZhangView:set_oringinalServerPokers(pokers)
    self.oringinalServerPokers ={}
    for i = 1, #pokers do
        self.oringinalServerPokers[i] = {}
        self.oringinalServerPokers[i].Color = pokers[i].Color
        self.oringinalServerPokers[i].Number = pokers[i].Number
    end
end

function TableBaiBaZhangView:CheckSpriteInMatch()
    for i = 1, #self.winMatchingPokers do
        if(self.winMatchingPokers[i].parentGameObject.activeSelf) then
            local curSprite = self.winMatchingPokers[i].image.sprite;
            for j = i + 1, #self.winMatchingPokers do
                if (self.winMatchingPokers[j].parentGameObject.activeSelf) then
                    if(curSprite == self.winMatchingPokers[j].image.sprite) then
                        if ModuleCache.GameManager.isEditor then
                            ModuleCache.GameSDKInterface:PauseEditorApplication(true)
                        else
                            --ModuleCache.GameSDKInterface:PauseEditorApplication(true)
                            ModuleCache.GameManager.logout()
                        end
                        -- 故意设置错误代码好上报Bugly
                        if self.oringinalServerPokers then
                            log_table(self.oringinalServerPokers)
                        end
                        local test =  kjkd > 0
                        return true
                    end
                end
            end
        end
    end
    return false;
end


function TableBaiBaZhangView:Set10thPokersActive(isActive)
    self.tenthPoker:SetActive(isActive);
    self.fastMatching:SetActive(not isActive);
end

function TableBaiBaZhangView:refresh_table_bg()
    local tableBg = UnityEngine.PlayerPrefs.GetInt("RoomSetting_TableBackground_Name_" .. "BIJI", 1)
    ModuleCache.ComponentManager.SafeSetActive(self.tableBackgroundImage.gameObject, tableBg == 1)
    ModuleCache.ComponentManager.SafeSetActive(self.tableBackgroundImage2.gameObject, tableBg == 2)
end

function TableBaiBaZhangView:StartClockCountdown(countdownSeconds)
    --self.goClock:SetActive(true);
    local stopFlag = false;
    for i = 1,countdownSeconds + 1 do
        self:subscibe_time_event(i -1, false, 0):OnComplete(function(t)
            if(clockCountStopFlag) then
                stopFlag = true;
            end
            if(stopFlag) then
                return;
            end
            self.textClock.text = countdownSeconds - (i - 1);
        end)
    end
end

function TableBaiBaZhangView:SetExchangeHintActive(isActive)
    self.panelExchangeHint:SetActive(isActive);
end

function TableBaiBaZhangView:SetGameLogoActive(type,isActive)
    if(not isActive) then
        self.imgBiji:SetActive(false);
        self.imgShucheng:SetActive(false);
        return;
    end
    if(type == 0) then
        self.imgBiji:SetActive(isActive);
        self.imgShucheng:SetActive(not isActive);
    elseif(type == 1) then
        self.imgBiji:SetActive(not isActive);
        self.imgShucheng:SetActive(isActive);
    end
end

function TableBaiBaZhangView:SetRuleBtnActive(isActive)
    self.buttonRule.gameObject:SetActive(isActive);
    self.ruleHint.gameObject:SetActive(not isActive);
    if isActive then
        self.textRoomNum.transform.localPosition = Vector3.New(-12, self.textRoomNum.transform.localPosition.y, self.textRoomNum.transform.localPosition.z)
    else
        self.textRoomNum.transform.localPosition = Vector3.New(12, self.textRoomNum.transform.localPosition.y, self.textRoomNum.transform.localPosition.z)
    end
   
end

function TableBaiBaZhangView:SetClockActive(isActive)
    self.goClock:SetActive(isActive);
    if(isActive == false) then
        clockCountStopFlag = true;
    else
        clockCountStopFlag = false;
    end
end

function TableBaiBaZhangView:resetSelectedPokers()
	local cardsArray = self.seatHolderArray[1].inhandCardsArray
	for i=1,#cardsArray do		
		self:refreshCardSelect(cardsArray[i], true)		
	end	
end

function TableBaiBaZhangView:SetHandPokersActive(isActive)
    self.pokers:SetActive(isActive);
end

function TableBaiBaZhangView:GetSeatPosition(localSeatIndex)
    local seat = GetComponentWithPath(self.root,"Center/Seats/"..localSeatIndex,ComponentTypeName.Transform);
    print(seat.position.x .. ";"..seat.position.y..";"..seat.position.z)
    return seat.position;
end

function TableBaiBaZhangView:refreshSeat(seatData)
    --local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    local defaultImage = GetComponentWithPath(self.root,"Center/Seats/"..seatData.localSeatIndex.."/NotSitDown",ComponentTypeName.Transform).gameObject;
    if(seatData.playerId == 0) then
        
        defaultImage:SetActive(true);
    else
        defaultImage:SetActive(false);
    end
    
    --刷新座位基本信息
    self:refreshSeatInfo(seatData)
    --刷新座位状态
    self:refreshSeatState(seatData)
    --TableBaiBaZhangHelper:refreshInHandCards(seatHolder, seatData.inHandPokerList, showCardFace, showCardWithAnim)    
    --TableBaiBaZhangHelper:showInHandCards(seatHolder, #seatData.inHandPokerList ~= 0)
    --if(seatData.isDoneComputeNiu)then
        
        --TableBaiBaZhangHelper:setInHandPokersDonePos(seatHolder)
    --else
        --TableBaiBaZhangHelper:setInHandPokersOriginalPos(seatHolder)
    --end
end

--刷新座位玩家状态
function TableBaiBaZhangView:refreshSeatState(seatData)
    if(seatData.localSeatIndex == nil) then
        return;
    end
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableBaiBaZhangHelper:refreshSeatState(seatHolder, seatData)
end

--刷新在线状态
function TableBaiBaZhangView:refreshSeatOfflineState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableBaiBaZhangHelper:refreshSeatOfflineState(seatHolder, seatData)
end

function TableBaiBaZhangView:refreshSeatInfo(seatData)
    if(seatData.localSeatIndex == nil) then
        return;
    end
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableBaiBaZhangHelper:refreshSeatInfo(seatHolder, seatData)
end
--設置房間信息
function TableBaiBaZhangView:SetRoomInfo(roomInfo)
    print_table(roomInfo)
    print(self.modelData.roleData.HallID);
    if(self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0) then
        self.textRoomNum.text = AppData.MuseumName .."房号:" ..  roomInfo.roomNum
    else
         self.textRoomNum.text = "房号:" .. roomInfo.roomNum
    end
    
    self.textRoomRule.text = "摆八张 ";

    --self.textRoomRule.text = 
    self.textRoomRule.text = self.textRoomRule.text.."第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局"
    --self.textRoundNum.text = "(第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局)"
    --self.textRoundNum.gameObject:SetActive(true)
end

function TableBaiBaZhangView:showWifiState(show, wifiLevel)    
    for i=1,#self.goWifiStateArray do        
        ModuleCache.ComponentManager.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)
    end
end


function TableBaiBaZhangView:show4GState(show, signalType)
    ModuleCache.ComponentManager.SafeSetActive(self.goGState2G, show and signalType == "2g")
    ModuleCache.ComponentManager.SafeSetActive(self.goGState3G, show and signalType == "3g")
    ModuleCache.ComponentManager.SafeSetActive(self.goGState4G, show and signalType == "4g")
end

function TableBaiBaZhangView:refreshBatteryAndTimeInfo()
    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue / 100
    self.sliderBattery.value = batteryValue
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

function TableBaiBaZhangView:ShowSelfResultBackTable()
    self.Result.gameObject:SetActive(true);
    self.SelfResult:SetActive(true);
    local path = "TableResult/SelfTable";
    local paiBeiSprite = self.cardAssetHolder:FindSpriteByName("paidi")
    for j = 1,3 do
        if(j == 1) then
            pathMatch = path.."/FirstTable";
        elseif( j == 2) then
            pathMatch = path.."/SecondTable";
        elseif(j == 3) then
            pathMatch = path.."/ThirdTable";
        end
        for i = 1,3 do
            local image = GetComponentWithPath(self.root,pathMatch.."/Panel/"..i,ComponentTypeName.Image);
            image.sprite = paiBeiSprite;
        end
    end

end


function TableBaiBaZhangView:ShowSelfSurrender()
    self.Result.gameObject:SetActive(true);
    self.SelfResult:SetActive(true);
    local firstTable = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable",ComponentTypeName.Transform).gameObject;
    local secondTable = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable",ComponentTypeName.Transform).gameObject;
    local thirdTable = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable",ComponentTypeName.Transform).gameObject;
    firstTable:SetActive(false);
    secondTable:SetActive(false);
    thirdTable:SetActive(false);
    local surrenderText = GetComponentWithPath(self.root,"TableResult/SelfTable/TextSurrender",ComponentTypeName.Transform).gameObject;
    surrenderText:SetActive(true);
end

function TableBaiBaZhangView:ShowResultTable()
    self.Result.gameObject:SetActive(true);
    self.WinDeal:SetActive(false);
    self.buttonChat.gameObject:SetActive(true)
end

function TableBaiBaZhangView:CloseResultTable()
    self.Result.gameObject:SetActive(false);
    local path;
    for i = 1,6 do
        if(i == 1) then
            path = "TableResult/SelfTable"
        elseif(i == 2) then
            path = "TableResult/PlusOneTable";
        elseif(i == 3) then
            path = "TableResult/PlusTwoTable";
        elseif(i == 4) then
            path = "TableResult/MinusTwoTable";
        elseif(i == 5) then
            path = "TableResult/MinusOneTable";
        elseif(i == 6) then
            path = "TableResult/MinusZeroTable";
        end
        local currentTable = GetComponentWithPath(self.root,path,ComponentTypeName.Transform).gameObject;
        currentTable:SetActive(false);
        local addText = GetComponentWithPath(self.root,path.."/AddScore",ComponentTypeName.Text);
        local totalText = GetComponentWithPath(self.root,path.."/TotalScore",ComponentTypeName.Text);
        local imgVictory = GetComponentWithPath(self.root,path.."/TotalScore/ImgVictory",ComponentTypeName.Image);
        local imgBackground = GetComponentWithPath(self.root,path.."/TotalScore/ImgBackground",ComponentTypeName.Image);
        local panelPlus = GetComponentWithPath(self.root,path.."/TotalScore/PanelPlus","TextWrap");
        local panelMinus = GetComponentWithPath(self.root,path.."/TotalScore/PanelMinus","TextWrap");
        local goPass =  GetComponentWithPath(self.root,path.."/Image",ComponentTypeName.Transform).gameObject; 
        imgBackground.gameObject:SetActive(false);
        imgVictory.gameObject:SetActive(false);
        panelPlus.gameObject:SetActive(false);
        panelMinus.gameObject:SetActive(false);
        goPass:SetActive(false);
        addText.text = "";
        totalText.text = "";
        local pathMatch;
        for j = 1,3 do
            if(j == 1) then
                pathMatch = path.."/FirstTable";
            elseif( j == 2) then
                pathMatch = path.."/SecondTable";
            elseif(j == 3) then
                pathMatch = path.."/ThirdTable";
            end
            
            local currentMatchTextPlus = GetComponentWithPath(self.root,pathMatch.."/TextPlus",ComponentTypeName.Text);
            local currentMatchTextMinus = GetComponentWithPath(self.root,pathMatch.."/TextMinus",ComponentTypeName.Text);
            currentMatchTextPlus.text = "";
            currentMatchTextPlus.gameObject:SetActive(false);
            currentMatchTextMinus.text = "";
            currentMatchTextMinus.gameObject:SetActive(false);
            local currentTable = GetComponentWithPath(self.root,pathMatch,ComponentTypeName.Transform).gameObject;
            currentTable:SetActive(true);
        end
        -- 喜牌的动画会稍微晚点，所以
        for k = 1,4 do
            local curXipaiImage = GetComponentWithPath(self.root,path.."/XipaiScore/ImgXipai"..k,ComponentTypeName.Image);
            curXipaiImage.gameObject:SetActive(false);
            local curXipaiText = GetComponentWithPath(self.root,path.."/XipaiScore/ImgXipai"..k.."/Text","TextWrap");
            curXipaiText.gameObject:SetActive(false);
        end
        local currentSurrender = GetComponentWithPath(self.root,path.."/TextSurrender",ComponentTypeName.Transform).gameObject;
        currentSurrender:SetActive(false);
        local specialTypePanel = GetComponentWithPath(self.root,path.."/Special",ComponentTypeName.Transform).gameObject;
        specialTypePanel:SetActive(false);
        local scoreText = GetComponentWithPath(self.root,path.."/Special/Score",ComponentTypeName.Text);
        local scoreTextMinus = GetComponentWithPath(self.root,path.."/Special/ScoreMinus",ComponentTypeName.Text);
        local scoreTitle = GetComponentWithPath(self.root,path.."/Special/Text",ComponentTypeName.Text);
        local image = GetComponentWithPath(self.root,path.."/Special/Image",ComponentTypeName.Image);
        scoreText.gameObject:SetActive(false);
        scoreTextMinus.gameObject:SetActive(false);
        scoreTitle.gameObject:SetActive(false);
        image.gameObject:SetActive(false);
    end
    for i = 1,#self.animList do
        UnityEngine.Object.Destroy(self.animList[i].gameObject)
        --self.animList[i].gameObject:SetActive(false);
    end
    self.animList = {};
end

function TableBaiBaZhangView:PlayCompareVocie(key, seatInfo)	
    if(not key) then
        return;
    end
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
        voiceName = "santiao"

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
	ModuleCache.SoundManager.play_sound("baibazhang", "baibazhang/sound/bijisound/" .. path .. ".bytes", voiceName)
end

function TableBaiBaZhangView:PlayResultVoice(isVictory)	
    if(isVictory) then
        ModuleCache.SoundManager.play_sound("baibazhang", "baibazhang/sound/bijisound/win_1.bytes" ,"win_1")
    else
        ModuleCache.SoundManager.play_sound("baibazhang", "baibazhang/sound/bijisound/lose.bytes" , "lose")
    end
end

function TableBaiBaZhangView:ShowReadyBtn()
    self.readyPanel:SetActive(true);
end

function TableBaiBaZhangView:HideReadyBtn()
    self.readyPanel:SetActive(false);
end

function TableBaiBaZhangView:SetAllDefaultImageActive(isActive)
    for i = 1,6 do
        local curImage = GetComponentWithPath(self.root,"Center/Seats/"..i.."/NotSitDown",ComponentTypeName.Transform).gameObject;
        curImage:SetActive(isActive);
    end
end

function TableBaiBaZhangView:SetDefaultImageActive(index,isActive)
    local curImage = GetComponentWithPath(self.root,"Center/Seats/"..index.."/NotSitDown",ComponentTypeName.Transform).gameObject;
    curImage:SetActive(isActive);
end

function TableBaiBaZhangView:ConvertNumIntoImageInTotal(index,score)
    local path;
    if(index == 1) then
        path = "TableResult/SelfTable/TotalScore";
    elseif(index == 2) then
        path = "TableResult/PlusOneTable/TotalScore";
    elseif(index == 3) then
        path = "TableResult/PlusTwoTable/TotalScore";
    elseif(index == 4) then
        path = "TableResult/MinusTwoTable/TotalScore";
    elseif(index == 5) then
        path = "TableResult/MinusOneTable/TotalScore";
    elseif(index == 6) then
        path = "TableResult/MinusZeroTable/TotalScore";
    end

    local imgVictory = GetComponentWithPath(self.root,path.."/ImgVictory",ComponentTypeName.Image);
    local imgBackground = GetComponentWithPath(self.root,path.."/ImgBackground",ComponentTypeName.Image);
    local panelPlus = GetComponentWithPath(self.root,path.."/PanelPlus","TextWrap");
    local panelMinus = GetComponentWithPath(self.root,path.."/PanelMinus","TextWrap");
    local winSprite;
    imgBackground.gameObject:SetActive(true);
    if(false) then  --暂时不要胜败
        imgVictory.gameObject:SetActive(true);
    end
    if(score >= 0) then
        winSprite = self.BiJiAssetHolder:FindSpriteByName("win");
        --plusSprite = self.BiJiAssetHolder:FindSpriteByName("plus");
        panelPlus.gameObject:SetActive(true);
        panelMinus.gameObject:SetActive(false);
        panelPlus.text = "+" .. score;
    else
        winSprite = self.BiJiAssetHolder:FindSpriteByName("lose")
        panelPlus.gameObject:SetActive(false);
        panelMinus.gameObject:SetActive(true);
        panelMinus.text = "-"..math.abs(score);
        --plusSprite = self.BiJiAssetHolder:FindSpriteByName("minus")
    end
    imgVictory.sprite = winSprite;
end

function TableBaiBaZhangView:Show10thPokerImage(poker)
    local sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(poker));
    self.tenthPokerImage.sprite = sprite;
end

function TableBaiBaZhangView:ShowSelfResult(selfPlayer, onFinish,isAllSurrender)
    self.SelfResult:SetActive(true);
    local surrenderHint = GetComponentWithPath(self.root,"TableResult/SelfTable/TextSurrender",ComponentTypeName.Transform).gameObject;
    local firstTable = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable",ComponentTypeName.Transform).gameObject;
    local secondTable = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable",ComponentTypeName.Transform).gameObject;
    local thirdTable = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable",ComponentTypeName.Transform).gameObject;
    local imagePass = GetComponentWithPath(self.root,"TableResult/SelfTable/Image",ComponentTypeName.Image).gameObject;
    local textPass = GetComponentWithPath(self.root,"TableResult/SelfTable/Image/Text","TextWrap");
    local textAddScore = GetComponentWithPath(self.root,"TableResult/SelfTable/AddScore",ComponentTypeName.Text);
    textAddScore.gameObject:SetActive(false)
    imagePass:SetActive(false);
    local totalScoreText = GetComponentWithPath(self.root, "TableResult/SelfTable/TotalScore", ComponentTypeName.Text);
    local totalScore = 0
    totalScoreText.text = '';

    local interval = 0.5
    local duration = 0.4
    local seatInfo = TableBaiBaZhangHelper:getSeatInfoByPlayerId(selfPlayer.userID, self.modelData.curTableData.roomInfo.seatInfoList);
    local isSpecial = false;
    if(selfPlayer.typeOfXipai[1] ~= 0) then
        local specialPanel = GetComponentWithPath(self.root,"TableResult/SelfTable/Special",ComponentTypeName.Transform).gameObject;
        specialPanel:SetActive(true);

        if(selfPlayer.typeOfXipai[1] ~= 0) then
            local name = selfPlayer.typeOfXipai[1];
            local sprite = self.SpecialTypeAssetHolder:FindSpriteByName(name);
            local image = GetComponentWithPath(self.root,"TableResult/SelfTable/Special/Image/Image",ComponentTypeName.Image);
            image.sprite = sprite;
            local imageParent = GetComponentWithPath(self.root,"TableResult/SelfTable/Special/Image",ComponentTypeName.Image);
            imageParent.gameObject:SetActive(true);
            isSpecial = true;
        end

        local scoreText = GetComponentWithPath(self.root,"TableResult/SelfTable/Special/Score",ComponentTypeName.Text);
        local scoreTitle = GetComponentWithPath(self.root,"TableResult/SelfTable/Special/Text",ComponentTypeName.Text);
        if(selfPlayer.XipaiScores[1] >= 0) then
            scoreText.text = "+" .. selfPlayer.XipaiScores[1]
        else
            scoreText = GetComponentWithPath(self.root,"TableResult/SelfTable/Special/ScoreMinus",ComponentTypeName.Text);
            scoreText.text = selfPlayer.XipaiScores[1]
        end
        self:subscibe_time_event(4 * (duration + interval), false, 0):OnComplete(function(t)
            scoreText.gameObject:SetActive(true);
            scoreTitle.gameObject:SetActive(true);
            self:subscibe_time_event(0.5 * (duration + interval), false, 0):OnComplete(function(t)
                totalScore = selfPlayer.totalScore;
                self:ConvertNumIntoImageInTotal(1,totalScore)
                
                if(onFinish)then
                    onFinish()
                end
            end)
            self:subscibe_time_event(1,false,0):OnComplete(function(t)
                if(not isSpecial) then
                    local preTextType = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
            end)
        end)
    else
        self:subscibe_time_event(3 * (duration + interval), false, 0):OnComplete(function(t)
            totalScore = selfPlayer.totalScore;
            self:ConvertNumIntoImageInTotal(1,totalScore)
            self:subscibe_time_event(1,false,0):OnComplete(function(t)
                if(not isSpecial) then
                    local preTextType = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
            end)
            if(onFinish)then
                onFinish()
            end
        end)
    end
    if(selfPlayer.isSurrender) then
        local totalScoreText = GetComponentWithPath(self.root, "TableResult/SelfTable/TotalScore", ComponentTypeName.Text);      
        totalScoreText.text = selfPlayer.totalScore;
        surrenderHint:SetActive(true);
        firstTable:SetActive(false);
        secondTable:SetActive(false);
        thirdTable:SetActive(false);
        for i = 1,10 do
            local curPoker = GetComponentWithPath(self.root, "DealWin/pockers/"..i-1, ComponentTypeName.Transform).gameObject;
            curPoker:SetActive(false);
        end
        local num;
        if(tonumber(#selfPlayer.typeOfXipai) ~= 0 and selfPlayer.scoreOfXipai ~= 0) then
            num = 4;
        else
            if(isAllSurrender) then
                num = 0.5;
            else
                 num = 3;
            end
        end
        self:subscibe_time_event(num * (duration + interval), false, 0):OnComplete(function(t)
            totalScoreText.gameObject:SetActive(true);
                    
            totalScore = selfPlayer.totalScore;
            self:ConvertNumIntoImageInTotal(1,totalScore)
        end)
        
        if(onFinish)then
            onFinish()
        end
        return;
    else
        surrenderHint:SetActive(false);
        firstTable:SetActive(true);
        secondTable:SetActive(true);
        thirdTable:SetActive(true);        

        self:subscibe_time_event(0 * (duration + interval), false, 0):OnComplete(function(t)			
            firstTable:SetActive(true);
            --ModuleCache.SoundManager.play_sound("biji", "biji/sound/bijisound/showcard.bytes", "showcard")
            --textAddScore.gameObject:SetActive(true)
            local score = selfPlayer.scoreOfPokers[1]
            textAddScore.text = (score < 0 and score) or '+'..score
            --totalScore = totalScore + score
            --totalScoreText.text = totalScore;
            self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                local curText;
                local curTextPlus = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable/TextPlus",ComponentTypeName.Transform).gameObject;
                local curTextMinus = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable/TextPlus",ComponentTypeName.Transform).gameObject;
                curTextPlus:SetActive(false);
                curTextMinus:SetActive(false);
                if(selfPlayer.scoreOfPokers[1] >= 0) then
                    curText = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable/TextPlus",ComponentTypeName.Transform).gameObject;
                else
                    curText = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable/TextMinus",ComponentTypeName.Transform).gameObject;
                end
                local soundIndex = selfPlayer.typeOfPokers[1];
                if(not isSpecial) then
                    local strType = self:GetStrPokerType(soundIndex);
                    local textType = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable/TextPokerType",ComponentTypeName.Text);
                    textType.gameObject:SetActive(true);
                    textType.text = strType;
                end
                self:PlayCompareVocie(soundIndex,seatInfo)
                curText:SetActive(true);
                textAddScore.gameObject:SetActive(false)
            end)
        end)
        self:subscibe_time_event(1 * (duration + interval), false, 0):OnComplete(function(t)			
            secondTable:SetActive(true);
            --ModuleCache.SoundManager.play_sound("biji", "biji/sound/bijisound/showcard.bytes", "showcard")
            --textAddScore.gameObject:SetActive(true)
            local score = selfPlayer.scoreOfPokers[2]
            textAddScore.text = (score < 0 and score) or '+'..score
            --totalScore = totalScore + score
            --totalScoreText.text = totalScore;
            self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                local curText;
                local curTextPlus = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable/TextPlus",ComponentTypeName.Transform).gameObject;
                local curTextMinus = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable/TextPlus",ComponentTypeName.Transform).gameObject;
                curTextPlus:SetActive(false);
                curTextMinus:SetActive(false);
                if(selfPlayer.scoreOfPokers[2] >= 0) then
                    curText = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable/TextPlus",ComponentTypeName.Transform).gameObject;
                else
                    curText = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable/TextMinus",ComponentTypeName.Transform).gameObject;
                end
                local soundIndex = selfPlayer.typeOfPokers[2];
                if(not isSpecial) then
                    local strType = self:GetStrPokerType(soundIndex);
                    local textType = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable/TextPokerType",ComponentTypeName.Text);
                    textType.gameObject:SetActive(true);
                    textType.text = strType;
                    local preTextType = GetComponentWithPath(self.root,"TableResult/SelfTable/FirstTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
                self:PlayCompareVocie(soundIndex,seatInfo)
                curText:SetActive(true);
                textAddScore.gameObject:SetActive(false)
            end)
        end)
        self:subscibe_time_event(2 * (duration + interval), false, 0):OnComplete(function(t)			
            thirdTable:SetActive(true);
            --ModuleCache.SoundManager.play_sound("biji", "biji/sound/bijisound/showcard.bytes", "showcard")
            --textAddScore.gameObject:SetActive(true)
            local score = selfPlayer.scoreOfPokers[3]
            textAddScore.text = (score < 0 and score) or '+'..score
            --totalScore = totalScore + score
            --totalScoreText.text = totalScore;
            self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                local curText;
                local curTextPlus = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextPlus",ComponentTypeName.Transform).gameObject;
                local curTextMinus = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextPlus",ComponentTypeName.Transform).gameObject;
                curTextPlus:SetActive(false);
                curTextMinus:SetActive(false);
                if(selfPlayer.scoreOfPokers[3] >= 0) then
                    curText = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextPlus",ComponentTypeName.Transform).gameObject;
                else
                    curText = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextMinus",ComponentTypeName.Transform).gameObject;
                end
                local soundIndex = selfPlayer.typeOfPokers[3];
                if(not isSpecial) then
                    local strType = self:GetStrPokerType(soundIndex);
                    local textType = GetComponentWithPath(self.root,"TableResult/SelfTable/ThirdTable/TextPokerType",ComponentTypeName.Text);
                    textType.gameObject:SetActive(true);
                    textType.text = strType;
                    local preTextType = GetComponentWithPath(self.root,"TableResult/SelfTable/SecondTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
                self:PlayCompareVocie(soundIndex,seatInfo)
                curText:SetActive(true);
                textAddScore.gameObject:SetActive(false)
            end)
        end)
        if(tonumber(selfPlayer.scoreOfRound) ~= 0) then
            imagePass:SetActive(false);
            self:subscibe_time_event(3 * (duration + interval), false, 0):OnComplete(function(t)
                if(tonumber(selfPlayer.scoreOfRound) > 0) then
                    imagePass:SetActive(true);
                end
                --textAddScore.gameObject:SetActive(true)
                local score = selfPlayer.scoreOfRound
                textAddScore.text = (score < 0 and score) or '+'..score
                if(score > 0) then
                    textPass.text = score;
                end
                --totalScore = totalScore + score
                --totalScoreText.text = totalScore;
                self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                    textAddScore.gameObject:SetActive(false)
                end)
            end)
        else
            imagePass:SetActive(false);
        end
        
    end

    
    --local pokerBackSprite = ;
    for i = 1,3 do
        local currentScorePlusText;
        local currentScoreMinusText;
        local currentFirstPoker;
        local currentSecondPoker;
        local currentThirdPoker;

        local firstSprite;
        local secondSprite;
        local thirdSprite;
        if(i == 1) then
            currentScorePlusText = GetComponentWithPath(self.root, "TableResult/SelfTable/FirstTable/TextPlus", ComponentTypeName.Text);
            currentScoreMinusText = GetComponentWithPath(self.root, "TableResult/SelfTable/FirstTable/TextMinus", ComponentTypeName.Text);
            currentFirstPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/FirstTable/Panel/1", ComponentTypeName.Image);
            currentSecondPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/FirstTable/Panel/2", ComponentTypeName.Image);
            currentThirdPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/FirstTable/Panel/3", ComponentTypeName.Image);
            local firstPoker = {};
            firstPoker.colour = selfPlayer.pokers[1].Color;
            firstPoker.number = selfPlayer.pokers[1].Number;
            firstSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(firstPoker));
            --currentFirstPoker.sprite = firstSprite;
            local secondPoker = {};
            secondPoker.colour = selfPlayer.pokers[2].Color;
            secondPoker.number = selfPlayer.pokers[2].Number;
            secondSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(secondPoker));
            --currentSecondPoker.sprite = secondSprite;
            --currentThirdPoker.sprite = thirdSprite;
            if(tonumber(selfPlayer.scoreOfPokers[i]) >= 0) then
                currentScorePlusText.text ="头道<size=32>+" .. selfPlayer.scoreOfPokers[i].."</size>";
            else
                currentScoreMinusText.text ="头道<size=32>" .. selfPlayer.scoreOfPokers[i].."</size>";
            end
            
        end
        if(i == 2) then
            currentScorePlusText = GetComponentWithPath(self.root, "TableResult/SelfTable/SecondTable/TextPlus", ComponentTypeName.Text);
            currentScoreMinusText = GetComponentWithPath(self.root, "TableResult/SelfTable/SecondTable/TextMinus", ComponentTypeName.Text);
            currentFirstPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/SecondTable/Panel/1", ComponentTypeName.Image);
            currentSecondPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/SecondTable/Panel/2", ComponentTypeName.Image);
            currentThirdPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/SecondTable/Panel/3", ComponentTypeName.Image);
            local firstPoker = {};
            firstPoker.colour = selfPlayer.pokers[3].Color;
            firstPoker.number = selfPlayer.pokers[3].Number;
            firstSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(firstPoker));
            --currentFirstPoker.sprite = firstSprite;
            local secondPoker = {};
            secondPoker.colour = selfPlayer.pokers[4].Color;
            secondPoker.number = selfPlayer.pokers[4].Number;
            secondSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(secondPoker));
            --currentSecondPoker.sprite = secondSprite;
            local thirdPoker = {};
            thirdPoker.colour = selfPlayer.pokers[5].Color;
            thirdPoker.number = selfPlayer.pokers[5].Number;
            thirdSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(thirdPoker));
            --currentThirdPoker.sprite = thirdSprite;
            if(tonumber(selfPlayer.scoreOfPokers[i]) >= 0) then
                currentScorePlusText.text ="中道<size=32>+" .. selfPlayer.scoreOfPokers[i].."</size>";
            else
                currentScoreMinusText.text ="中道<size=32>" .. selfPlayer.scoreOfPokers[i].."</size>";
            end
        end
        if(i == 3) then
            currentScorePlusText = GetComponentWithPath(self.root, "TableResult/SelfTable/ThirdTable/TextPlus", ComponentTypeName.Text);
            currentScoreMinusText = GetComponentWithPath(self.root, "TableResult/SelfTable/ThirdTable/TextMinus", ComponentTypeName.Text);
            currentFirstPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/ThirdTable/Panel/1", ComponentTypeName.Image);
            currentSecondPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/ThirdTable/Panel/2", ComponentTypeName.Image);
            currentThirdPoker = GetComponentWithPath(self.root, "TableResult/SelfTable/ThirdTable/Panel/3", ComponentTypeName.Image);
            local firstPoker = {};
            firstPoker.colour = selfPlayer.pokers[6].Color;
            firstPoker.number = selfPlayer.pokers[6].Number;
            firstSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(firstPoker));
            --currentFirstPoker.sprite = firstSprite;
            local secondPoker = {};
            secondPoker.colour = selfPlayer.pokers[7].Color;
            secondPoker.number = selfPlayer.pokers[7].Number;
            secondSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(secondPoker));
            --currentSecondPoker.sprite = secondSprite;
            local thirdPoker = {};
            thirdPoker.colour = selfPlayer.pokers[8].Color;
            thirdPoker.number = selfPlayer.pokers[8].Number;
            thirdSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(thirdPoker));
            --currentThirdPoker.sprite = thirdSprite;
            if(tonumber(selfPlayer.scoreOfPokers[i]) >= 0) then
                currentScorePlusText.text ="尾道<size=32>+" .. selfPlayer.scoreOfPokers[i].."</size>";
            else
                currentScoreMinusText.text ="尾道<size=32>" .. selfPlayer.scoreOfPokers[i].."</size>";
            end
        end

        local delayTime = (duration + interval) * (i - 1)
        if(isSpecial) then
            delayTime = 0;
        end
        local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
        local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
        local paiBeiSprite = self.cardAssetHolder:FindSpriteByName("paidi")
        currentFirstPoker.sprite = paiBeiSprite
        local sequence = self:create_sequence();
        sequence:Append(currentFirstPoker.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
            currentFirstPoker.sprite = firstSprite
        end))
        sequence:Append(currentFirstPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))

        currentSecondPoker.sprite = paiBeiSprite
        sequence = self:create_sequence();
        sequence:Append(currentSecondPoker.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
            currentSecondPoker.sprite = secondSprite
        end))
        sequence:Append(currentSecondPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))

        currentThirdPoker.sprite = paiBeiSprite
        sequence = self:create_sequence();
        sequence:Append(currentThirdPoker.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
            currentThirdPoker.sprite = thirdSprite
        end))
        sequence:Append(currentThirdPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))
    end

end

function TableBaiBaZhangView:SetErrHintActive(isActive)
    self.panelErrHint:SetActive(isActive);
    if(isActive) then
        self:subscibe_time_event(2, false, 0):OnComplete(function(t)
            self.panelErrHint:SetActive(false);
        end)
    end
end

function TableBaiBaZhangView:ShowReadyStatus(localSeatIndex,isConfirmed,pokersNum)
    if(isConfirmed) then
        local paiBeiSprite = self.cardAssetHolder:FindSpriteByName("paidi")
        local path;
        self.Result.gameObject:SetActive(true);
        --currentFirstPoker.sprite = paiBeiSprite
        if(tonumber(localSeatIndex) == 2) then
            self.PlusOneResult.gameObject:SetActive(true);
            path = "TableResult/PlusOneTable";
        end
        if(tonumber(localSeatIndex) == 3) then
            self.PlusTwoResult.gameObject:SetActive(true);
            path = "TableResult/PlusTwoTable";
        end
        if(tonumber(localSeatIndex) == 4) then
            self.MinusTwoResult.gameObject:SetActive(true);
            path = "TableResult/MinusTwoTable";
        end
        if(tonumber(localSeatIndex) == 5) then
            self.MinusOneResult.gameObject:SetActive(true);
            path = "TableResult/MinusOneTable";
        end
        if(tonumber(localSeatIndex) == 6) then
            self.MinusZeroResult.gameObject:SetActive(true);
            path = "TableResult/MinusZeroTable";
        end
        for i = 1,3 do
            local pathDetail
            if(i == 1) then
                pathDetail = path.."/FirstTable/Panel/";
            elseif(i == 2) then
                pathDetail = path.."/SecondTable/Panel/";
            elseif(i == 3) then
                pathDetail = path.."/ThirdTable/Panel/";
            end
            for j = 1,3 do 
                local currentPoker = GetComponentWithPath(self.root, pathDetail..j, ComponentTypeName.Image);
                currentPoker.sprite = paiBeiSprite;
            end
        end
    else
        local playerPanel = GetComponentWithPath(self.root,"PanelHandPokers/player"..localSeatIndex,ComponentTypeName.Transform).gameObject;
        playerPanel:SetActive(true);
        for i = 1,pokersNum do
            local otherPoker = GetComponentWithPath(self.root,"PanelHandPokers/player"..localSeatIndex.."/"..i,ComponentTypeName.Transform).gameObject;
            otherPoker:SetActive(true); 
        end
    end
end

function TableBaiBaZhangView:SetReadyBtn(startType)
    if startType ~= 3 and startType ~= 4 and startType ~= 1 then
        self.textCenterTips.transform.parent.gameObject:SetActive(false);
    end
    
    local switcher = GetComponentWithPath(self.root,"Ready","UIStateSwitcher")
    if(startType == 0) then
        --self.buttonStart.gameObject:SetActive(true);
        --self.buttonReady.gameObject:SetActive(false);        
        self.buttonReady2.gameObject:SetActive(false);
        --self.buttonExit.gameObject:SetActive(true);
        switcher:SwitchState("Three")
    elseif(startType == 1) then
        --self.buttonStart.gameObject:SetActive(false);
        --self.buttonReady.gameObject:SetActive(false);
        --self.buttonReady.gameObject:SetActive(true);
        --self.buttonExit.gameObject:SetActive(true);
        self.buttonReady2.gameObject:SetActive(false);
        switcher:SwitchState("Two")
    elseif(startType == 2) then
        self.buttonStart.gameObject:SetActive(false);
        self.buttonReady.gameObject:SetActive(false);
        --self.buttonReady.gameObject:SetActive(false);
        self.buttonReady2.gameObject:SetActive(true);
        self.buttonExit.gameObject:SetActive(false);
        self.buttonExit2.gameObject:SetActive(false);
    elseif(startType == 3) then--棋牌馆 快速组局 非第一个进入的 倒计时   
        self.buttonReady2.gameObject:SetActive(true);
        switcher:SwitchState("Two")
    elseif(startType == 4) then--棋牌馆 快速组局 第一个进入的 倒计时   
        self.buttonReady2.gameObject:SetActive(true);
        switcher:SwitchState("Three")

    elseif(startType == 5) then
        self.buttonStart.gameObject:SetActive(false);
        self.buttonReady.gameObject:SetActive(false);
        --self.buttonReady.gameObject:SetActive(false);
        self.buttonReady2.gameObject:SetActive(false);
        self.buttonExit.gameObject:SetActive(false);
        self.buttonExit2.gameObject:SetActive(false);
        self:SetBtnInviteActive(false);
    end

    if ModuleCache.GameManager.iosAppStoreIsCheck then
        self:SetBtnInviteActive(false)
    end
end

function TableBaiBaZhangView:SetSelfImageActive(isActive)
    local selfImage = GetComponentWithPath(self.root,"Center/Seats/1/Seat(Clone)",ComponentTypeName.Transform).gameObject;
    selfImage:SetActive(isActive);
end

function TableBaiBaZhangView:SetDealWindowActive(isActive)
    self.WinDeal:SetActive(isActive);
    self.buttonChat.gameObject:SetActive(not isActive)
    if(isActive)then
        ModuleCache.ModuleManager.hide_module("henanmj", "tablechat")
    end
end

function TableBaiBaZhangView:SetSurrenderConfirmWindow(isActive)
    self.SurrenderConfirm:SetActive(isActive);
end

function TableBaiBaZhangView:ShowNotReadyNotice(errInfo)
    --self.textNotReady.transform.parent.gameObject:SetActive(true);
    --self.textNotReady.text = errInfo;
    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(errInfo)	

end

function TableBaiBaZhangView:DelayToGetReady(onFinish)
    for i = 1,6 do
        self:subscibe_time_event(i -1, false, 0):OnComplete(function(t)
            self.readyCountDown.text ="(".. 5 - (i - 1)..")";
        end)
    end
    self:subscibe_time_event(5, false, 0):OnComplete(function(t)
        if(onFinish) then
            onFinish()
        end
    end)
end

function TableBaiBaZhangView:SetReadyCancel(isReady)
    if(isReady) then
 --       self.buttonCancel.gameObject:SetActive(true);
        self.buttonReady.gameObject:SetActive(false);
        self.buttonReady2.gameObject:SetActive(false);
    else
  --      self.buttonCancel.gameObject:SetActive(false);
        self.buttonReady.gameObject:SetActive(true);
    end
end

function TableBaiBaZhangView:SetMatchingActive(index,isActive)
    local path;
    if(index == 2 ) then
        path = "PanelMatching/ImageMatching2";
    elseif(index == 3) then
        path = "PanelMatching/ImageMatching3";
    elseif(index == 4) then
        path = "PanelMatching/ImageMatching4";
    elseif(index == 5) then
        path = "PanelMatching/ImageMatching5";
    end
    local matchingImage = GetComponentWithPath(self.root,path,ComponentTypeName.Transform).gameObject;
    matchingImage:SetActive(isActive);
end

function TableBaiBaZhangView:SetDealBtnActive( index, isActive )
    if(index == 1) then
        self.buttonPair.gameObject:SetActive(isActive);
        self.buttonPairGray.gameObject:SetActive(not isActive);
    elseif(index == 2) then
        --self.buttonStraight.interactable = isActive;
        self.buttonStraight.gameObject:SetActive(isActive);
        self.buttonStraightGray.gameObject:SetActive(not isActive);
    elseif(index == 3) then
        
    elseif(index == 4) then
        --self.buttonStraightFlush.interactable = isActive;
        self.buttonStraightFlush.gameObject:SetActive(isActive);
        self.buttonStraightFlushGray.gameObject:SetActive(not isActive);
    elseif(index == 5) then
        --self.buttonThreeOfAKind.interactable = isActive;
        self.buttonThreeOfAKind.gameObject:SetActive(isActive);
        self.buttonThreeOfAKindGray.gameObject:SetActive(not isActive);
    end
    -- body
end

function TableBaiBaZhangView:ShowPlayingNotify()
    self.textCenterTips.text = "等待下一局...";
    self.textCenterTips.transform.parent.gameObject:SetActive(true);
    self.buttonStart.gameObject:SetActive(false);
    self.buttonReady.gameObject:SetActive(false);
end

function TableBaiBaZhangView:ClosePlayingNotify()
    self.textCenterTips.text = "等待下一局...";
    self.textCenterTips.transform.parent.gameObject:SetActive(false);
    --self.buttonStart.gameObject:SetActive(false);
    --self.buttonReady.gameObject:SetActive(false);
end

function TableBaiBaZhangView:SetResetBtnActive(index,isActive)
    local path = ""
    if(index == 1) then
        path = "DealWin/Matching/first/reset";
        --self.buttonResetFirst.gameObject:SetActive(isActive);
    end
    if(index == 2) then
        path = "DealWin/Matching/second/reset";
        --self.buttonResetSecond.gameObject:SetActive(isActive);
    end
    if(index == 3) then
        path = "DealWin/Matching/third/reset";
        --self.buttonResetThird.gameObject:SetActive(isActive);
    end
    local btnReset = GetComponentWithPath(self.root,path.."/reset",ComponentTypeName.Transform).gameObject;
    local btnResetDisable = GetComponentWithPath(self.root,path.."/resetDisable",ComponentTypeName.Transform).gameObject;
    btnReset:SetActive(isActive);
    btnResetDisable:SetActive(not isActive);
end

function TableBaiBaZhangView:SetPokerTypeHint(index,type)
    local path;
    if(index == 1) then
        path = "DealWin/Matching/first/Panel/Text";
    elseif(index == 2) then
        path = "DealWin/Matching/second/Panel/Text";
    elseif(index == 3) then
        path = "DealWin/Matching/third/Panel/Text";
    end
    local text = GetComponentWithPath(self.root,path,ComponentTypeName.Text);
    if(type == 1) then
        text.text = "散牌";
    elseif(type == 2) then
        text.text = "对子";
    elseif(type == 3) then
        text.text = "顺子";
    elseif(type == 4) then
        text.text = "三条";
    elseif(type == 5) then
        text.text = "同花顺";
    elseif(type == 6) then
        text.text = "三条";
    end
end

function TableBaiBaZhangView:ClearPaiXingHint(index)
    local path;
    if(index == 1) then
        path = "DealWin/Matching/first/Panel/Text";
    elseif(index == 2) then
        path = "DealWin/Matching/second/Panel/Text";
    elseif(index ==3) then
        path = "DealWin/Matching/third/Panel/Text";
    end
    local textHint = GetComponentWithPath(self.root,path,ComponentTypeName.Text);
    textHint.text = "";
end

function TableBaiBaZhangView:ClearFastMatchingHint()
    for i = 1,3 do
        local path = "DealWin/Matching/FastMatching/Suggestion"..i;
        local textHint = GetComponentWithPath(self.root,path.."/Text",ComponentTypeName.Text);
        textHint.transform.parent.gameObject:SetActive(false);
        textHint.text = ""
    end
end

function TableBaiBaZhangView:SetFastMatchingHint(index,matches)
    local path = "DealWin/Matching/FastMatching/Suggestion"..index;
    local textHint = GetComponentWithPath(self.root,path.."/Text",ComponentTypeName.Text);
    textHint.transform.parent.gameObject:SetActive(true);
    local text = ""
    for i = 1,3 do
        local textType;
        if(matches[i] == 1) then
            textType = "散牌";
        elseif(matches[i] == 2) then
            textType = "对子";
        elseif(matches[i] == 3) then
            textType = "顺子";
        elseif(matches[i] == 4) then
            textType = "三条";
        elseif(matches[i] == 5) then
            textType = "同花顺";
        end
        text = text .. textType .. "+";
    end
    textHint.text = string.sub(text, 1, -2 );
end

function TableBaiBaZhangView:GetStrPokerType(index)
    local textType = "";
    if(index == 1) then
        textType = "散牌";
    elseif(index == 2) then
        textType = "对子";
    elseif(index == 3) then
        textType = "顺子";
    elseif(index == 4) then
        textType = "三条";
    elseif(index == 5) then
        textType = "同花顺";
    end
    return textType
end

function TableBaiBaZhangView:ShowOthersResult(other,othersSeat, onFinish,isAllSurrender,isJoinAfterStart)
    if(isJoinAfterStart) then
        if(onFinish) then
            onFinish()
        end
        return;
    end    
    local path;
    if(othersSeat == 2) then
        self.PlusOneResult.gameObject:SetActive(true);
        path = "TableResult/PlusOneTable";
    end
    if(othersSeat == 3) then
        self.PlusTwoResult.gameObject:SetActive(true);
        path = "TableResult/PlusTwoTable";
    end
    if(othersSeat == 4) then
        self.MinusTwoResult.gameObject:SetActive(true);
        path = "TableResult/MinusTwoTable";
    end
    if(othersSeat == 5) then
        self.MinusOneResult.gameObject:SetActive(true);
        path = "TableResult/MinusOneTable";
    end
    if(othersSeat == 6) then
        self.MinusZeroResult.gameObject:SetActive(true);
        path = "TableResult/MinusZeroTable";
    end
    local surrenderHint = GetComponentWithPath(self.root,path.."/TextSurrender",ComponentTypeName.Transform).gameObject;
    local firstTable = GetComponentWithPath(self.root,path.."/FirstTable",ComponentTypeName.Transform).gameObject;
    local secondTable = GetComponentWithPath(self.root,path.."/SecondTable",ComponentTypeName.Transform).gameObject;
    local thirdTable = GetComponentWithPath(self.root,path.."/ThirdTable",ComponentTypeName.Transform).gameObject;
    local imagePass = GetComponentWithPath(self.root,path.."/Image",ComponentTypeName.Transform).gameObject;
    local totalScoreText = GetComponentWithPath(self.root, path.."/TotalScore", ComponentTypeName.Text);
    local textPass = GetComponentWithPath(self.root,path.."/Image/Text","TextWrap");
    local totalScore = 0;
    totalScoreText.text = '';
    imagePass:SetActive(false);
    local textAddScore = GetComponentWithPath(self.root,path.."/AddScore",ComponentTypeName.Text);

    local interval = 0.5
    local duration = 0.4
    local isSpecial = false;
    if(other.typeOfXipai[1] ~= 0 or other.scoreOfXipai ~= 0)then
        local specialPanel = GetComponentWithPath(self.root,path.."/Special",ComponentTypeName.Transform).gameObject;
        specialPanel:SetActive(true);
        
        if(other.typeOfXipai[1] ~= 0) then
            local name = other.typeOfXipai[1];
            local sprite = self.SpecialTypeAssetHolder:FindSpriteByName(name);
            local image = GetComponentWithPath(self.root,path.."/Special/Image/Image",ComponentTypeName.Image);
            image.sprite = sprite;
            local imageParent = GetComponentWithPath(self.root,path.."/Special/Image",ComponentTypeName.Image);
            imageParent.gameObject:SetActive(true);
            isSpecial = true;
        end
        
        local scoreText = GetComponentWithPath(self.root,path.."/Special/Score",ComponentTypeName.Text);
        local scoreTitle = GetComponentWithPath(self.root,path.."/Special/Text",ComponentTypeName.Text);
        if(other.XipaiScores[1] >= 0) then
            scoreText.text = "+" .. other.XipaiScores[1]
        else
            scoreText = GetComponentWithPath(self.root,path.."/Special/ScoreMinus",ComponentTypeName.Text);
            scoreText.text = other.XipaiScores[1]
        end
        self:subscibe_time_event(4 * (duration + interval), false, 0):OnComplete(function(t)
            scoreText.gameObject:SetActive(true);
            scoreTitle.gameObject:SetActive(true);
            self:subscibe_time_event(0.5 * (duration + interval), false, 0):OnComplete(function(t)
                totalScore = other.totalScore;
                self:ConvertNumIntoImageInTotal(othersSeat,totalScore)
                if(onFinish)then
                    onFinish()
                end
            end)
            self:subscibe_time_event(1,false,0):OnComplete(function(t)
                if(not isSpecial) then
                    local preTextType = GetComponentWithPath(self.root,path.."/ThirdTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
            end)
            
        end)
    else
        self:subscibe_time_event(3 * (duration + interval), false, 0):OnComplete(function(t)
            totalScore = other.totalScore;
            self:ConvertNumIntoImageInTotal(othersSeat,totalScore)
            if(onFinish)then
                onFinish()
            end
            self:subscibe_time_event(1,false,0):OnComplete(function(t)
                if(not isSpecial) then
                    local preTextType = GetComponentWithPath(self.root,path.."/ThirdTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
            end)
        end)
        
    end
    if(other.isSurrender) then
        local totalScoreText = GetComponentWithPath(self.root, path.."/TotalScore", ComponentTypeName.Text);      
        totalScoreText.text = other.totalScore;
        surrenderHint:SetActive(true);
        firstTable:SetActive(false);
        secondTable:SetActive(false);
        thirdTable:SetActive(false);
        local num;
        if(tonumber(#other.typeOfXipai) ~= 0 and other.scoreOfXipai ~= 0) then
            num = 4;
        else
            if(isAllSurrender) then
                num = 0.5;
            else
                 num = 3;
            end
        end
        self:subscibe_time_event(num * (duration + interval), false, 0):OnComplete(function(t)
            totalScoreText.gameObject:SetActive(true);
                    
            totalScore = other.totalScore;
            self:ConvertNumIntoImageInTotal(othersSeat,totalScore)
        end)
        if(onFinish)then
            onFinish()
        end
        return;
    else
        surrenderHint:SetActive(false);
        -- firstTable:SetActive(false);
        -- secondTable:SetActive(false);
        -- thirdTable:SetActive(false);

        textAddScore.gameObject:SetActive(false)
        self:subscibe_time_event(0 * (interval + duration), false, 0):OnComplete(function(t)			
		    firstTable:SetActive(true);
            
            --textAddScore.gameObject:SetActive(true)
            local score = other.scoreOfPokers[1]
            textAddScore.text = (score < 0 and score) or '+'..score
            totalScore = totalScore + score
            totalScoreText.text = totalScore;
            self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                local curText;
                local curTextPlus = GetComponentWithPath(self.root,path.."/FirstTable/TextPlus",ComponentTypeName.Transform).gameObject;
                local curTextMinus = GetComponentWithPath(self.root,path.."/FirstTable/TextMinus",ComponentTypeName.Transform).gameObject;
                curTextPlus:SetActive(false);
                curTextMinus:SetActive(false);
                if(other.scoreOfPokers[1] >= 0) then
                    curText = GetComponentWithPath(self.root,path.."/FirstTable/TextPlus",ComponentTypeName.Transform).gameObject;
                else
                    curText = GetComponentWithPath(self.root,path.."/FirstTable/TextMinus",ComponentTypeName.Transform).gameObject;
                end
                local soundIndex = other.typeOfPokers[1];
                if(not isSpecial) then
                    local strType = self:GetStrPokerType(soundIndex);
                    local textType = GetComponentWithPath(self.root,path.."/FirstTable/TextPokerType",ComponentTypeName.Text);
                    textType.gameObject:SetActive(true);
                    textType.text = strType;
                end
                curText:SetActive(true);
                textAddScore.gameObject:SetActive(false)
            end)
	    end)
        self:subscibe_time_event(1 * (interval + duration), false, 0):OnComplete(function(t)			
		    secondTable:SetActive(true);
            
            --textAddScore.gameObject:SetActive(true)
            local score = other.scoreOfPokers[2]
            textAddScore.text = (score < 0 and score) or '+'..score
            totalScore = totalScore + score
            totalScoreText.text = totalScore;
            self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                local curText;
                local curTextPlus = GetComponentWithPath(self.root,path.."/SecondTable/TextPlus",ComponentTypeName.Transform).gameObject;
                local curTextMinus = GetComponentWithPath(self.root,path.."/SecondTable/TextMinus",ComponentTypeName.Transform).gameObject;
                curTextPlus:SetActive(false);
                curTextMinus:SetActive(false);
                if(other.scoreOfPokers[2] >= 0) then
                    curText = GetComponentWithPath(self.root,path.."/SecondTable/TextPlus",ComponentTypeName.Transform).gameObject;
                else
                    curText = GetComponentWithPath(self.root,path.."/SecondTable/TextMinus",ComponentTypeName.Transform).gameObject;
                end
                local soundIndex = other.typeOfPokers[2];
                if(not isSpecial) then
                    local strType = self:GetStrPokerType(soundIndex);
                    local textType = GetComponentWithPath(self.root,path.."/SecondTable/TextPokerType",ComponentTypeName.Text);
                    textType.gameObject:SetActive(true);
                    textType.text = strType;
                    local preTextType = GetComponentWithPath(self.root,path.."/FirstTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
                curText:SetActive(true);
                textAddScore.gameObject:SetActive(false)
            end)
	    end)
        self:subscibe_time_event(2 * (interval + duration), false, 0):OnComplete(function(t)			
		    thirdTable:SetActive(true);
            --textAddScore.gameObject:SetActive(true)
            local score = other.scoreOfPokers[3]
            textAddScore.text = (score < 0 and score) or '+'..score
            totalScore = totalScore + score
            totalScoreText.text = totalScore;
            self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                local curText;
                local curTextPlus = GetComponentWithPath(self.root,path.."/ThirdTable/TextPlus",ComponentTypeName.Transform).gameObject;
                local curTextMinus = GetComponentWithPath(self.root,path.."/ThirdTable/TextMinus",ComponentTypeName.Transform).gameObject;
                curTextPlus:SetActive(false);
                curTextMinus:SetActive(false);
                if(other.scoreOfPokers[3] >= 0) then
                    curText = GetComponentWithPath(self.root,path.."/ThirdTable/TextPlus",ComponentTypeName.Transform).gameObject;
                else
                    curText = GetComponentWithPath(self.root,path.."/ThirdTable/TextMinus",ComponentTypeName.Transform).gameObject;
                end
                local soundIndex = other.typeOfPokers[3];
                if(not isSpecial) then
                    local strType = self:GetStrPokerType(soundIndex);
                    local textType = GetComponentWithPath(self.root,path.."/ThirdTable/TextPokerType",ComponentTypeName.Text);
                    textType.gameObject:SetActive(true);
                    textType.text = strType;
                    local preTextType = GetComponentWithPath(self.root,path.."/SecondTable/TextPokerType",ComponentTypeName.Text);
                    preTextType.gameObject:SetActive(false)
                end
                curText:SetActive(true);
                textAddScore.gameObject:SetActive(false)
            end)
	    end)
        if(tonumber(other.scoreOfRound) ~= 0) then
            imagePass:SetActive(false);
            self:subscibe_time_event(3 * (interval + duration), false, 0):OnComplete(function(t)
                if(tonumber(other.scoreOfRound) > 0) then
                    imagePass:SetActive(true);
                end
                
                --textAddScore.gameObject:SetActive(true)
                local score = other.scoreOfRound
                textAddScore.text = (score < 0 and score) or '+'..score
                totalScore = totalScore + score
                totalScoreText.text = totalScore;
                if(score > 0) then
                    textPass.text = score;
                end
                
                self:subscibe_time_event(interval + duration * 0.5, false, 0):OnComplete(function(t)
                    textAddScore.gameObject:SetActive(false)
                end)
            end)
        else
            imagePass:SetActive(false);
        end
        

    end
    
    
    for i = 1,3 do
        local firstSprite
        local secondSprite
        local thirdSprite
        local currentScorePlusText;
        local currentScoreMinusText;
        local currentFirstPoker;
        local currentSecondPoker;
        local currentThirdPoker;--[[]]
        if(i == 1) then
            currentScorePlusText = GetComponentWithPath(self.root, path.."/FirstTable/TextPlus", ComponentTypeName.Text);
            currentScoreMinusText = GetComponentWithPath(self.root, path.."/FirstTable/TextMinus", ComponentTypeName.Text);
            currentFirstPoker = GetComponentWithPath(self.root, path.."/FirstTable/Panel/1", ComponentTypeName.Image);
            currentSecondPoker = GetComponentWithPath(self.root, path.."/FirstTable/Panel/2", ComponentTypeName.Image);
            currentThirdPoker = GetComponentWithPath(self.root, path.."/FirstTable/Panel/3", ComponentTypeName.Image);
            local firstPoker = {};
            firstPoker.colour = other.pokers[1].Color;
            firstPoker.number = other.pokers[1].Number;
            firstSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(firstPoker));
            --currentFirstPoker.sprite = firstSprite;
            local secondPoker = {};
            secondPoker.colour = other.pokers[2].Color;
            secondPoker.number = other.pokers[2].Number;
            secondSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(secondPoker));
            --currentThirdPoker.sprite = thirdSprite;
            if(tonumber(other.scoreOfPokers[i]) >= 0) then
                currentScorePlusText.text ="赢<size=32>+" .. other.scoreOfPokers[i].."</size>";
            else
                currentScoreMinusText.text ="输<size=32>" .. other.scoreOfPokers[i].."</size>";
            end
        end
        if(i == 2) then
            currentScorePlusText = GetComponentWithPath(self.root, path.."/SecondTable/TextPlus", ComponentTypeName.Text);
            currentScoreMinusText = GetComponentWithPath(self.root, path.."/SecondTable/TextMinus", ComponentTypeName.Text);
            currentFirstPoker = GetComponentWithPath(self.root, path.."/SecondTable/Panel/1", ComponentTypeName.Image);
            currentSecondPoker = GetComponentWithPath(self.root, path.."/SecondTable/Panel/2", ComponentTypeName.Image);
            currentThirdPoker = GetComponentWithPath(self.root, path.."/SecondTable/Panel/3", ComponentTypeName.Image);
            local firstPoker = {};
            firstPoker.colour = other.pokers[3].Color;
            firstPoker.number = other.pokers[3].Number;
            firstSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(firstPoker));
            --currentFirstPoker.sprite = firstSprite;
            local secondPoker = {};
            secondPoker.colour = other.pokers[4].Color;
            secondPoker.number = other.pokers[4].Number;
            secondSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(secondPoker));
            --currentSecondPoker.sprite = secondSprite;
            local thirdPoker = {};
            thirdPoker.colour = other.pokers[5].Color;
            thirdPoker.number = other.pokers[5].Number;
            thirdSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(thirdPoker));
            --currentThirdPoker.sprite = thirdSprite;
            if(tonumber(other.scoreOfPokers[i]) >= 0) then
                currentScorePlusText.text ="赢<size=32>+" .. other.scoreOfPokers[i].."</size>";
            else
                currentScoreMinusText.text ="输<size=32>" .. other.scoreOfPokers[i].."</size>";
            end
        end
        if(i == 3) then
            currentScorePlusText = GetComponentWithPath(self.root, path.."/ThirdTable/TextPlus", ComponentTypeName.Text);
            currentScoreMinusText = GetComponentWithPath(self.root, path.."/ThirdTable/TextMinus", ComponentTypeName.Text);
            currentFirstPoker = GetComponentWithPath(self.root, path.."/ThirdTable/Panel/1", ComponentTypeName.Image);
            currentSecondPoker = GetComponentWithPath(self.root, path.."/ThirdTable/Panel/2", ComponentTypeName.Image);
            currentThirdPoker = GetComponentWithPath(self.root, path.."/ThirdTable/Panel/3", ComponentTypeName.Image);
            local firstPoker = {};
            firstPoker.colour = other.pokers[6].Color;
            firstPoker.number = other.pokers[6].Number;
            firstSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(firstPoker));
            --currentFirstPoker.sprite = firstSprite;
            local secondPoker = {};
            secondPoker.colour = other.pokers[7].Color;
            secondPoker.number = other.pokers[7].Number;
            secondSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(secondPoker));
            --currentSecondPoker.sprite = secondSprite;
            local thirdPoker = {};
            thirdPoker.colour = other.pokers[8].Color;
            thirdPoker.number = other.pokers[8].Number;
            thirdSprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(thirdPoker));
            --currentThirdPoker.sprite = thirdSprite;
            if(tonumber(other.scoreOfPokers[i]) >= 0) then
                currentScorePlusText.text ="赢<size=32>+" .. other.scoreOfPokers[i].."</size>";
            else
                currentScoreMinusText.text ="输<size=32>" .. other.scoreOfPokers[i].."</size>";
            end
        end
        
        local delayTime = (duration + interval) * (i - 1)
        if(isSpecial) then
            delayTime = 0;
        end
        local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
        local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
        local paiBeiSprite = self.cardAssetHolder:FindSpriteByName("paidi")
        currentFirstPoker.sprite = paiBeiSprite
        local sequence = self:create_sequence();
        sequence:Append(currentFirstPoker.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
            currentFirstPoker.sprite = firstSprite
        end))
        sequence:Append(currentFirstPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))

        currentSecondPoker.sprite = paiBeiSprite
        sequence = self:create_sequence();
        sequence:Append(currentSecondPoker.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
            currentSecondPoker.sprite = secondSprite
        end))
        sequence:Append(currentSecondPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))

        currentThirdPoker.sprite = paiBeiSprite
        sequence = self:create_sequence();
        sequence:Append(currentThirdPoker.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
            currentThirdPoker.sprite = thirdSprite
        end))
        sequence:Append(currentThirdPoker.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))

    end
    
end

function TableBaiBaZhangView:SetBtnInviteActive(isActive)
    print(isActive and (not ModuleCache.GameManager.iosAppStoreIsCheck))
    self.buttonInvite:SetActive(isActive and (not ModuleCache.GameManager.iosAppStoreIsCheck))
    if(not isActive) then
        self.buttonExit.gameObject:SetActive(false);
    end
    -- ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, not ModuleCache.GameManager.iosAppStoreIsCheck)   
end

function TableBaiBaZhangView:SetTempLeaveActive(isActive)

end

function TableBaiBaZhangView:bindButtons()
    self.buttonInvite = GetComponentWithPath(self.root, "Ready/Panel/Invite", ComponentTypeName.Button).gameObject
    --self.buttonReady = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady", ComponentTypeName.Button)
    self.buttonResetFirst = GetComponentWithPath(self.root,"DealWin/Matching/first/reset",ComponentTypeName.Button);
    self.buttonResetSecond = GetComponentWithPath(self.root,"DealWin/Matching/second/reset",ComponentTypeName.Button);
    self.buttonResetThird = GetComponentWithPath(self.root,"DealWin/Matching/third/reset",ComponentTypeName.Button);
    self.buttonSubmit = GetComponentWithPath(self.root,"DealWin/Submit/Submit",ComponentTypeName.Button);
    self.buttonReady = GetComponentWithPath(self.root,"Ready/Panel/ready",ComponentTypeName.Button);
    self.buttonReady2 = GetComponentWithPath(self.root,"Ready/ready2",ComponentTypeName.Button);
    --self.buttonCancel = GetComponentWithPath(self.root,"Ready/cancel",ComponentTypeName.Button);
    self.buttonStart = GetComponentWithPath(self.root,"Ready/Panel/start",ComponentTypeName.Button);
    self.buttonPair = GetComponentWithPath(self.root,"DealWin/button/pair",ComponentTypeName.Button);
    self.buttonPairGray = GetComponentWithPath(self.root,"DealWin/buttonGray/pair",ComponentTypeName.Button);
    self.buttonStraight = GetComponentWithPath(self.root,"DealWin/button/straight",ComponentTypeName.Button);
    self.buttonStraightGray = GetComponentWithPath(self.root,"DealWin/buttonGray/straight",ComponentTypeName.Button);
    --self.buttonFlush = GetComponentWithPath(self.root,"DealWin/button/flush",ComponentTypeName.Button);
    self.buttonStraightFlush = GetComponentWithPath(self.root,"DealWin/button/straightflush",ComponentTypeName.Button);
    self.buttonStraightFlushGray = GetComponentWithPath(self.root,"DealWin/buttonGray/straightflush",ComponentTypeName.Button);
    self.buttonThreeOfAKind = GetComponentWithPath(self.root,"DealWin/button/threeofakind",ComponentTypeName.Button);
    self.buttonThreeOfAKindGray = GetComponentWithPath(self.root,"DealWin/buttonGray/threeofakind",ComponentTypeName.Button);

end


function TableBaiBaZhangView:ShowDealTable()
    self.WinDeal:SetActive(true);
    self.buttonChat.gameObject:SetActive(false)
    ModuleCache.ModuleManager.hide_module("henanmj", "tablechat")
end

function TableBaiBaZhangView:ShowXiPai(XiPaiText)
    self.textXiPai.text = XiPaiText;
    if(XiPaiText == "") then
        self.textXiPaiTitle.gameObject:SetActive(false);
    else
        self.textXiPaiTitle.gameObject:SetActive(true);
    end
end

function TableBaiBaZhangView:CloseNotReadyWindow()
    self.panelNotReadyConfirm.gameObject:SetActive(false);
end

function TableBaiBaZhangView:refreshCardSelect(inHandPoker,withoutAnim)
    local targetPosY
    if (inHandPoker.selected) then
        targetPosY = 30
    else
        targetPosY = 0
    end
    if(not withoutAnim) then        
        ModuleCache.TransformUtil.SetY(inHandPoker.image.transform, targetPosY, true)
    else        
        local sequence = self:create_sequence();
        sequence:Append(inHandPoker.image.transform:DOLocalMoveY(targetPosY, 0.1, true))
    end
end

-- 刷新手中的牌
function TableBaiBaZhangView:refreshPokersInHand(pokers, isFirst,onFinish)
    print("!!!!!!!!!!!!!!!!!!")
    if(isFirst) then
        TableBaiBaZhangHelper:initDealTable(self.root);
        local duration = 0.06;
        -- 你怎么这样写代码
        --local sprites = {};
        --for i = 1,#pokers do
        --    local sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(pokers[i]))
        --    table.insert( sprites,sprite );
        --end
        for i = 1, #pokers do
            self.inHandPokers[i]["image"].sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(pokers[i]))
            self:subscibe_time_event(duration * i, false, 0):OnComplete(function(t)
                self.inHandPokers[i]["gameobject"]:SetActive(true)
                if(i == #pokers) then
                    if(onFinish) then
                        onFinish()
                    end
                end
            end)                 
        end
    else
        for i = 1, 10 do
            self.inHandPokers[i]["gameobject"]:SetActive(false);
        end
        for i = 1, #pokers do
            local sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(pokers[i]))
            self.inHandPokers[i]["image"].sprite = sprite
            self.inHandPokers[i]["gameobject"]:SetActive(true)
        end
    end
    self:CheckSpriteInHand()
    
end


function TableBaiBaZhangView:PlayAnimHandToMatch(handIndex,matchIndex,detailIndex,onFinish)
    TableBaiBaZhangHelper:PlayAnimHandToMatch(handIndex,matchIndex,detailIndex,onFinish);
end

function TableBaiBaZhangView:PlayAnimMatchToMatch(matches,fullIndex)
    local needToChange = false;
    for i = 1,3 do
        local srcIndex = matches[i]["index"];
        local desIndex = i;
        if(srcIndex ~= desIndex) then
            needToChange = true;
        end
    end
    if(not needToChange) then
        self:subscibe_time_event(0.20, false, 0):OnComplete(function(t)
            for i = 1,3 do
                self:ShowMatchingShow(i);
            end
        end)  
        return;
    end
    self:SetErrHintActive(true);
    for i = 1,3 do
        if(i ~= fullIndex) then
            self:ClearMatchingShow(i);
        end
    end
    for i = 1,#matches do
        local srcIndex = matches[i]["index"];
        local desIndex = i;
        local onFinish = function ()
            self.goPanelAnimMatching:SetActive(false);
            self:ShowMatchingShow(desIndex);
        end
        
        self:subscibe_time_event(0.20, false, 0):OnComplete(function(t)
            self.goPanelAnimMatching:SetActive(true);
            self:ClearMatchingShow(fullIndex);
            TableBaiBaZhangHelper:PlayAnimMatchToMatch(srcIndex,desIndex,onFinish);
        end)
        
    end
    
end

function TableBaiBaZhangView:setInHandPokerActive(inHandPoker, active)
     inHandPoker.gameObject:SetActive(active);
end

-- 设置道上的牌
function TableBaiBaZhangView:setMatchingShow(index,pokerList,delay,isForceActive)
    if(index > 3) then
        return;
    end
    if(isForceActive) then
        self.WinMatchings[index]["pokersWin"].gameObject:SetActive(true);
    end
    local _index=1;
    for key,v in ipairs(pokerList) do
        local sprite = self.cardAssetHolder:FindSpriteByName(self:getImageNameFromPoker(v));
        self.WinMatchings[index]["poker" .. _index].sprite= sprite;
        _index=_index+1;
    end
    --self:CheckSpriteInMatch()
end

-- 设置颜色
function TableBaiBaZhangView:SetExchangePokerColor(indexMatch,index,isSelected)
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

function TableBaiBaZhangView:ShowOthersPokerBack(index,isDelay,pokersNum)
    if(isDelay) then
        local duration = 0.1;
        local playerPanel = GetComponentWithPath(self.root,"PanelHandPokers/player"..index,ComponentTypeName.Transform).gameObject;
        playerPanel:SetActive(true);
        for i = 1,pokersNum do
            self:subscibe_time_event(duration * i, false, 0):OnComplete(function(t)
                local otherPoker = GetComponentWithPath(self.root,"PanelHandPokers/player"..index.."/"..i,ComponentTypeName.Transform).gameObject;
                otherPoker:SetActive(true);
            end)       
        end
    else
        local playerPanel = GetComponentWithPath(self.root,"PanelHandPokers/player"..index,ComponentTypeName.Transform).gameObject;
        playerPanel:SetActive(true);
        for i = 1,pokersNum do
            local otherPoker = GetComponentWithPath(self.root,"PanelHandPokers/player"..index.."/"..i,ComponentTypeName.Transform).gameObject;
            otherPoker:SetActive(true);
        end
    end
end

function TableBaiBaZhangView:ShowMatchingShow(index)
    if(self.WinMatchings[index]["pokersWin"] == nil) then
        return;
    end
    self.WinMatchings[index]["pokersWin"].gameObject:SetActive(true);
end

function TableBaiBaZhangView:ClearMatchingShow(index)
    if(self.WinMatchings[index]["pokersWin"] == nil) then
        return;
    end
    self.WinMatchings[index]["pokersWin"].gameObject:SetActive(false);
end

function TableBaiBaZhangView:SetNoPokersImageActive(index,isActive)
    if(true) then
        return;
    end
    if(index == 1) then
        local imageNoPokers = GetComponentWithPath(self.root,"DealWin/Matching/first/ImageNoPokers",ComponentTypeName.Transform).gameObject;
        imageNoPokers:SetActive(isActive);
    elseif(index == 2) then
        local imageNoPokers = GetComponentWithPath(self.root,"DealWin/Matching/second/ImageNoPokers",ComponentTypeName.Transform).gameObject;
        imageNoPokers:SetActive(isActive);
    elseif(index == 3) then
        local imageNoPokers = GetComponentWithPath(self.root,"DealWin/Matching/third/ImageNoPokers",ComponentTypeName.Transform).gameObject;
        imageNoPokers:SetActive(isActive);
    end
end

function TableBaiBaZhangView:init_view(playerResultList)
    local count = #playerResultList    
    for i=1,count do
        local playerResult = playerResultList[i];
        local seatRootPath = "Center/Seats/"..i;
        local goSeatRoot = GetComponentWithPath(self.root,seatRootPath,ComponentTypeName.Transform).gameObject
        local item = ModuleCache.ComponentUtil.InstantiateLocal(self.seatPrefab, goSeatRoot)  
        item.name = "player" .. i         
        item:SetActive(true)
        self:fillItem(item, playerResult)
    end
end

function TableBaiBaZhangView:fillItem(item, playerResult)

end

function TableBaiBaZhangView:getImageNameFromPoker(poker)
    --S:黑桃 H:红桃 C:梅花 D:方片 A 2 3 4 5 6 7 8 9 10 J Q K
    local colorStr
    if (poker.colour == 4) then
        colorStr = "heitao";
    elseif (poker.colour == 3) then
        colorStr = "hongtao";
    elseif (poker.colour == 2) then
        colorStr = "meihua";
    elseif (poker.colour == 1) then
        colorStr = "fangkuai";
    end
    local numberStr
    if (poker.number == 14) then
        numberStr = "1";
    else
        numberStr = ""..poker.number;
    end;
    local spriteName = colorStr .. "_" .. numberStr;
    if(poker.number == 15 and poker.colour == 2) then
        spriteName = "Joker2"
    end
    if(poker.number == 15 and poker.colour == 1) then
        spriteName = "Joker1"
    end
    return spriteName;
end
--[[function TableBaiBaZhangView:refreshCardSelect(cardHolder,withoutAnim)
-- body    local targetPosY
if(cardHolder.selected) then
targetPosY = 30
else
targetPosY = 0
end

if(withoutAnim) then
ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, targetPosY, true)
else
local sequence = self:create_sequence();
sequence:Append(cardHolder.cardRoot.transform:DOLocalMoveY(targetPosY, 0.1, true))
end
end]]

function TableBaiBaZhangView:playStartCompareAnim(onFinish)
    self.goStartCompreLogo:SetActive(true)
    local seatInfo = TableBaiBaZhangHelper:getSeatInfoByPlayerId(self.modelData.roleData.userID, self.modelData.curTableData.roomInfo.seatInfoList);
    self:PlayCompareVocie(0,seatInfo)
    self:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
        self.goStartCompreLogo:SetActive(false)
        if(onFinish)then    --不需要等待1秒再比牌
            onFinish()
        end
        -- self:subscibe_time_event(1,false,0):OnComplete(function(t)
        -- end)
        
    end)
end

function TableBaiBaZhangView:SetSelectedSuggestion(index)
    for i = 1,3 do
        local suggestionSelected = GetComponentWithPath(self.root,"DealWin/Matching/FastMatching/Suggestion"..i.."/Image",ComponentTypeName.Transform).gameObject;
        if(i == index) then
            suggestionSelected:SetActive(true);
        else
            suggestionSelected:SetActive(false);
        end
    end
end

function TableBaiBaZhangView:ClearSelectedSuggestion()
    for i = 1,3 do
        local suggestionSelected = GetComponentWithPath(self.root,"DealWin/Matching/FastMatching/Suggestion"..i.."/Image",ComponentTypeName.Transform).gameObject;
        suggestionSelected:SetActive(false);
    end
end

--播放配好牌的动画
function TableBaiBaZhangView:playConfirmPokerAnimStep1(index,pokersNum, onFinish, immediately)
    local path;
    if(index == 2) then
        path = "TableResult/PlusOneTable";
    end
    if(index == 3) then
        path = "TableResult/PlusTwoTable";
    end
    if(index == 4) then
        path = "TableResult/MinusTwoTable";
    end
    if(index == 5) then
        path = "TableResult/MinusOneTable";
    end
    if(index == 6) then
        path = "TableResult/MinusZeroTable";
    end
    if path then
        -- 隐藏喜牌动画
        for k = 1,4 do
            local curXipaiImage = GetComponentWithPath(self.root, path.."/XipaiScore/ImgXipai"..k,ComponentTypeName.Image);
            curXipaiImage.gameObject:SetActive(false);
        end
    end


    local handPokers = {}
    for i=1,pokersNum do
        local poker = {}    
        poker.go = GetComponentWithPath(self.root,"PanelHandPokers/player"..index.."/"..i,ComponentTypeName.Transform).gameObject;
        poker.go:SetActive(true)
        poker.originalPos = poker.go.transform.position
        handPokers[i] = poker
    end
    
    local originalPos = handPokers[5].go.transform.localPosition
    local sequence = self:create_sequence();
    local duration = 0.5 * ((immediately and 0) or 1)
    for i=1,#handPokers do
        local poker = handPokers[i]
        local targetPos = {}
        if(index == 2)then
            targetPos.y = originalPos.y + (5 - i) * 10
            --print(originalPos.y, targetPos.y, i)
            sequence:Join(poker.go.transform:DOLocalMoveY(targetPos.y, duration, true))
        elseif(index == 3 or index == 4)then
            targetPos.y = originalPos.y + (5 - i) * 10
            sequence:Join(poker.go.transform:DOLocalMoveY(targetPos.y, duration, true))
        elseif(index == 5)then
            targetPos.y = originalPos.y + (5 - i) * 10
            sequence:Join(poker.go.transform:DOLocalMoveY(targetPos.y, duration, true))
        end
        
    end

    sequence:OnComplete(function()
        for i=1,#handPokers do
            local poker = handPokers[i]
            poker.go.transform.position = poker.originalPos
            poker.go:SetActive(false)
        end
        local playerPanel = GetComponentWithPath(self.root,"PanelHandPokers/player"..index,ComponentTypeName.Transform).gameObject;
        playerPanel:SetActive(false);
        if(onFinish)then
            onFinish()
        end        
    end)

end

function TableBaiBaZhangView:SetResetAllActive(isActive)
    self.resetAll:SetActive(isActive);
    self.buttonSubmit.gameObject:SetActive(isActive);
end

function TableBaiBaZhangView:SetOrderSequenceActive(isActive)
    self.orderSequence:SetActive(isActive);
    self.orderColor:SetActive(not isActive);
end

function TableBaiBaZhangView:playComfirmPokerAnimStep2(index, onFinish, immediately)
    self.Result.gameObject:SetActive(true);
    local path;
    if(index == 2) then
        self.PlusOneResult.gameObject:SetActive(true);
        path = "TableResult/PlusOneTable";
    end
    if(index == 3) then
        self.PlusTwoResult.gameObject:SetActive(true);
        path = "TableResult/PlusTwoTable";
    end
    if(index == 4) then
        self.MinusTwoResult.gameObject:SetActive(true);
        path = "TableResult/MinusTwoTable";
    end
    if(index == 5) then
        self.MinusOneResult.gameObject:SetActive(true);
        path = "TableResult/MinusOneTable";
    end
    if(index == 6) then
        self.MinusZeroResult.gameObject:SetActive(true);
        path = "TableResult/MinusZeroTable";
    end
    local pokers = {}
    local fillPaiBei = function(path)
        local currentFirstPoker = GetComponentWithPath(self.root, path.."/Panel/1", ComponentTypeName.Image);
        local currentSecondPoker = GetComponentWithPath(self.root, path.."/Panel/2", ComponentTypeName.Image);
        local currentThirdPoker = GetComponentWithPath(self.root, path.."/Panel/3", ComponentTypeName.Image);
        currentFirstPoker.sprite = self.cardAssetHolder:FindSpriteByName("paidi");  
        currentSecondPoker.sprite = self.cardAssetHolder:FindSpriteByName("paidi");  
        currentThirdPoker.sprite = self.cardAssetHolder:FindSpriteByName("paidi");    
        table.insert( pokers, {image = currentFirstPoker} );
        table.insert( pokers, {image = currentSecondPoker} );
        table.insert( pokers, {image = currentThirdPoker} );
    end
    fillPaiBei(path .. "/FirstTable");
    fillPaiBei(path .. "/SecondTable");
    fillPaiBei(path .. "/ThirdTable");
    
    local sequence = self:create_sequence();
    local duration = 0.25 * ((immediately and 0) or 1)
    local delayTime = 0.01 * ((immediately and 0) or 1)
    for i=1,#pokers do
        local poker = pokers[i]
        poker.originalScale = poker.image.transform.localScale
        poker.color = poker.image.color
        poker.image.transform.localScale = poker.originalScale * 0.5
        sequence:Join(poker.image.transform:DOScale(poker.originalScale.x, duration):SetDelay(delayTime * i))
        ModuleCache.CustomerUtil.SetAlpha(poker.image,0)
        sequence:Join(ModuleCache.CustomerUtil.FadeAlpha(poker.image,1,duration):SetDelay(delayTime * i))
    end
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end        
    end)
end


--显示聊天气泡
function TableBaiBaZhangView:show_chat_bubble(seatInfo, content)
    local localSeatIndex = seatInfo.localSeatIndex
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local chatBubble = GetComponentWithPath(seatRoot, "State/Group/ChatBubble", ComponentTypeName.RectTransform).gameObject
    local chatText = GetComponentWithPath(chatBubble, "TextBg/Text", ComponentTypeName.Text)
    chatText.text =TableUtil.cut_text(self.widthText,content,400);
    chatBubble:SetActive(true)
    if seatInfo.timeChatEvent_id then 
        CSmartTimer:Kill(seatInfo.timeChatEvent_id)
        seatInfo.timeChatEvent_id = nil
    end
    seatInfo.timeChatEvent_id = nil
    local timeEvent = nil
    timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete(function(t)
        chatBubble:SetActive(false)
    end)
    seatInfo.timeChatEvent_id = timeEvent.id
end

--显示表情
function TableBaiBaZhangView:show_chat_emoji(seatInfo, emojiId)
    local localSeatIndex = seatInfo.localSeatIndex
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local showFace = nil
    for i=0,19 do
        local go = GetComponentWithPath(seatHolder.seatRoot, "State/Group/ChatFace/" .. i, ComponentTypeName.Transform)
        if(go)then
            if(i == emojiId - 1)then
                go.gameObject:SetActive(true)
                showFace = go.gameObject
            else
                go.gameObject:SetActive(false)
            end
        end
    end
    
    if seatHolder.timeChatEmojiEvent_id then 
        CSmartTimer:Kill(seatHolder.timeChatEmojiEvent_id)
        seatHolder.timeChatEmojiEvent_id = nil
    end
    if(not showFace)then
        return
    end
    seatHolder.timeChatEmojiEvent_id = nil
    local timeEvent = nil
    timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete(function(t)
        if(showFace)then
            ModuleCache.ComponentManager.SafeSetActive(showFace, false)
        end        
    end)
    seatHolder.timeChatEmojiEvent_id = timeEvent.id
end



function TableBaiBaZhangView:show_voice(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local seatRoot = seatHolder.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(true)
end

function TableBaiBaZhangView:hide_voice(seatInfo)
    local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    local seatRoot = seatHolder.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(false)
end

function TableBaiBaZhangView:show_speaking_amin(show)
    ModuleCache.ComponentManager.SafeSetActive(self.goSpeaking, show)
end

function TableBaiBaZhangView:show_cancel_speaking_amin(show)
    ModuleCache.ComponentManager.SafeSetActive(self.goCancelSpeaking, show)
end


function TableBaiBaZhangView:show_ping_delay(show, delaytime)
    ModuleCache.ComponentManager.SafeSetActive(self.textPingValue.gameObject, show)
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

return TableBaiBaZhangView;
