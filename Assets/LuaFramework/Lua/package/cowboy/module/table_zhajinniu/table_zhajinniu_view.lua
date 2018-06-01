--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance

local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
---@class TableView_ZhaJinNiu:View
local TableView_ZhaJinNiu = class('tableView', View)

local TableHelper = require("package/cowboy/module/table_zhajinniu/table_zhajinniu_helper")
local Sequence = DG.Tweening.DOTween.Sequence
local GameSDKInterface = ModuleCache.GameSDKInterface

function TableView_ZhaJinNiu:initialize(...)
    self.packageName = 'cowboy'
    self.moduleName = 'table_zhajinniu'
    View.initialize(self, "cowboy/module/table/cowboy_table_zhajinniu.prefab", "CowBoy_Table_ZhaJinNiu", 0, true)

    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material

    self.tableBackgroundSprite = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image).sprite
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
    self.goWifiStateArray = {}    
    for i=1,5 do
        local goState = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end
    
    self.goGState2G = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "Top/TopInfo/BatteryTime/GState/4g", ComponentTypeName.Transform).gameObject
    

    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomID/Text", ComponentTypeName.Text)

    self.textCenterTips = GetComponentWithPath(self.root, "Center/Tips/Text", ComponentTypeName.Text)

    self.goNiuPoint = GetComponentWithPath(self.root, "Bottom/HandPokers/NiuResult/Niu_Point", ComponentTypeName.Transform).gameObject
    self.imageNiuPoint = GetComponentWithPath(self.goNiuPoint, "num", ComponentTypeName.Image)
    

    self.uiStateSwitcherSeatPrefab = GetComponentWithPath(self.root, "Holder/Seat", "UIStateSwitcher")
    self.cardAssetHolder =  GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.niuPointAssetHolder = GetComponentWithPath(self.root, "Holder/NiuNumAssetHolder", "SpriteHolder")        
    self.goTmpBankerPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpBankerPos", ComponentTypeName.Transform).gameObject
    self.goTmpPokerHeapPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpPokerHeapPos", ComponentTypeName.Transform).gameObject

    self.textRoundNum = GetComponentWithPath(self.root, "Center/RoundNum/Text", ComponentTypeName.Text)
    self.goCurRoundBetScore = GetComponentWithPath(self.root, "Center/RoundBetScore", ComponentTypeName.Transform).gameObject
    self.textCurRoundBetScore = GetComponentWithPath(self.goCurRoundBetScore, "Text", ComponentTypeName.Text)

    self.prefabGold1 = GetComponentWithPath(self.root, "Center/goldPrefab1", ComponentTypeName.Transform).gameObject
    self.textGold1 = GetComponentWithPath(self.prefabGold1, "Text", ComponentTypeName.Text)
    self.prefabGold2 = GetComponentWithPath(self.root, "Center/goldPrefab2", ComponentTypeName.Transform).gameObject
    self.textGold2 = GetComponentWithPath(self.prefabGold2, "Text", ComponentTypeName.Text)
    self.prefabGold3 = GetComponentWithPath(self.root, "Center/goldPrefab3", ComponentTypeName.Transform).gameObject
    self.textGold3 = GetComponentWithPath(self.prefabGold3, "Text", ComponentTypeName.Text)
    self.prefabGold4 = GetComponentWithPath(self.root, "Center/goldPrefab4", ComponentTypeName.Transform).gameObject
    self.textGold4 = GetComponentWithPath(self.prefabGold4, "Text", ComponentTypeName.Text)

    --牌堆范围
    self.goldHeapRect = {}
    self.goldHeapRect.tranLeftTop = GetComponentWithPath(self.root, "Center/BetGoldAreaLeftTopPos", ComponentTypeName.Transform)
    self.goldHeapRect.tranLeftBottom = GetComponentWithPath(self.root, "Center/BetGoldAreaLeftBottomPos", ComponentTypeName.Transform)
    self.goldHeapRect.tranRightTop = GetComponentWithPath(self.root, "Center/BetGoldAreaRightTopPos", ComponentTypeName.Transform)
    self.goldHeapRect.tranRightBottom = GetComponentWithPath(self.root, "Center/BetGoldAreaRightBottomPos", ComponentTypeName.Transform)

    self.holderGolds = {}
    self.holderGolds.root = GetComponentWithPath(self.root, "Center/golds", ComponentTypeName.Transform).gameObject

    local goCostScore = GetComponentWithPath(self.root, "Bottom/CostScore", ComponentTypeName.Transform).gameObject
    local imageCostGold = GetComponentWithPath(goCostScore, "cost/gold", ComponentTypeName.Image)
    local textCostScore = GetComponentWithPath(goCostScore, "cost/Text", ComponentTypeName.Text)

    local imageCompareFail = GetComponentWithPath(self.root, "Bottom/ImageCompareFail", ComponentTypeName.Image)

    --比牌特效
    self.goMask = GetComponentWithPath(self.root, "mask", ComponentTypeName.Transform).gameObject

    --新的比牌特效
    self.holderConstrastEffect_New = {}
    self.holderConstrastEffect_New.goRoot = GetComponentWithPath(self.root, "PokerContrast", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect_New.left = {}
    self.holderConstrastEffect_New.left.goAnimator = GetComponentWithPath(self.root, "PokerContrast/PK_Left_Win", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect_New.left.imageHead1 = GetComponentWithPath(self.holderConstrastEffect_New.left.goAnimator, "ZuoBian/Avatar/Mask/Image", ComponentTypeName.Image)
    self.holderConstrastEffect_New.left.imageHead2 = GetComponentWithPath(self.holderConstrastEffect_New.left.goAnimator, "YouBian /Avatar/Mask/Image", ComponentTypeName.Image)
    self.holderConstrastEffect_New.left.textName1 = GetComponentWithPath(self.holderConstrastEffect_New.left.goAnimator, "ZuoBian/TextName", ComponentTypeName.Text)
    self.holderConstrastEffect_New.left.textName2 = GetComponentWithPath(self.holderConstrastEffect_New.left.goAnimator, "YouBian /TextName", ComponentTypeName.Text)
    self.holderConstrastEffect_New.right = {}
    self.holderConstrastEffect_New.right.goAnimator = GetComponentWithPath(self.root, "PokerContrast/PK_Right_Win", ComponentTypeName.Transform).gameObject
    self.holderConstrastEffect_New.right.imageHead1 = GetComponentWithPath(self.holderConstrastEffect_New.right.goAnimator, "ZuoBian/Avatar/Mask/Image", ComponentTypeName.Image)
    self.holderConstrastEffect_New.right.imageHead2 = GetComponentWithPath(self.holderConstrastEffect_New.right.goAnimator, "YouBian /Avatar/Mask/Image", ComponentTypeName.Image)
    self.holderConstrastEffect_New.right.textName1 = GetComponentWithPath(self.holderConstrastEffect_New.right.goAnimator, "ZuoBian/TextName", ComponentTypeName.Text)
    self.holderConstrastEffect_New.right.textName2 = GetComponentWithPath(self.holderConstrastEffect_New.right.goAnimator, "YouBian /TextName", ComponentTypeName.Text)


    local selfHandPokerRoot = GetComponentWithPath(self.root, "Bottom/HandPokers", ComponentTypeName.Transform).gameObject
    self.srcSeatHolderArray = {}
    local localSeatIndex = 1
    for i=1,6 do        
        local seatHolder = {}
        seatHolder.seatHolderIndex = i
        local seatPosTran = GetComponentWithPath(self.root, "Center/Seats/" .. i, ComponentTypeName.Transform)

        local goSeat = ModuleCache.ComponentUtil.InstantiateLocal(self.uiStateSwitcherSeatPrefab.gameObject, seatPosTran.gameObject)     
        seatHolder.pokerAssetHolder = self.cardAssetHolder
        seatHolder.niuPointAssetHolder = self.niuPointAssetHolder
        
        if(i == 1)then
            TableHelper:initSeatHolder(seatHolder, i, goSeat, selfHandPokerRoot)  
            seatHolder.goNiuPoint = self.goNiuPoint
            seatHolder.imageNiuPoint = self.imageNiuPoint
            seatHolder.imageCompareFail = imageCompareFail
            seatHolder.goCostScore = goCostScore
            seatHolder.imageCostGold = imageCostGold
            seatHolder.textCostScore = textCostScore
            seatHolder.goWinAnim = GetComponentWithPath(self.root, "WinEffect/Anim_Table_LP_MyWin", ComponentTypeName.Transform).gameObject
        else
            TableHelper:initSeatHolder(seatHolder, i, goSeat, nil)        
        end
        
        TableHelper:refreshSeatInfo(seatHolder, {})      --初始化
        
        seatHolder.goTmpBankerPos = self.goTmpBankerPos
        seatHolder.goTmpPokerHeapPos = self.goTmpPokerHeapPos   --牌堆位置


        self.srcSeatHolderArray[i] = seatHolder
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, false)   
    end    
end

function TableView_ZhaJinNiu:bindButtons()
    self.buttonInvite = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonInviteFriend", ComponentTypeName.Button) 
    self.buttonReady = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady", ComponentTypeName.Button)
    self.buttonReady_fastStart = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady_fastStatr", ComponentTypeName.Button)

    self.buttonContinue = GetComponentWithPath(self.root, "Bottom/Action/ButtonContinue", ComponentTypeName.Button)
    self.textContinueLimitTime = GetComponentWithPath(self.buttonContinue.gameObject, "Text", ComponentTypeName.Text) 
    self.buttonStart = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonStart", ComponentTypeName.Button) 
    self.buttonExit = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher/ButtonExit", ComponentTypeName.Button)

    self.goZhaJinNiuBtnsRoot = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu", ComponentTypeName.Transform).gameObject 
    self.buttonDropPoker = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonDrop", ComponentTypeName.Button) 
    self.buttonComparePoker = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonCompare", ComponentTypeName.Button)
    self.textComparePokerValue = GetComponentWithPath(self.buttonComparePoker.gameObject, "Text", ComponentTypeName.Text)

    self.buttonCheckPoker = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonCheck", ComponentTypeName.Button) 

    self.toggleFollowAlways = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ToggleFollowAlways", ComponentTypeName.Toggle)
    self.textFollowAlwaysValue = GetComponentWithPath(self.toggleFollowAlways.gameObject, "Text", ComponentTypeName.Text)

    self.buttonFollow = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonFollow", ComponentTypeName.Button)
    self.textFollowValue = GetComponentWithPath(self.buttonFollow.gameObject, "Text", ComponentTypeName.Text)

    --加注按钮
    self.buttonRaise = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/BetBtns/ButtonRasise", ComponentTypeName.Button) 
    self.textRiseValue = GetComponentWithPath(self.buttonRaise.gameObject, "Text", "TextWrap") 

    self.buttonMore = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/ButtonMore", ComponentTypeName.Button)
    self.buttonHideMore = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/AddBetRoot/AddBetRootBtnClose", ComponentTypeName.Button)

    self.goMoreBtns = GetComponentWithPath(self.root, "Bottom/Action/ZhaJinNiu/AddBetRoot/More", ComponentTypeName.Transform).gameObject

    self.betBtnHolderArray = {}
    local list = {1,2,3,4,5,6,8,10}
    for i = 1, #list do
        local holder = {}
        holder.button = GetComponentWithPath(self.goMoreBtns, "AddBetBtn"..list[i], ComponentTypeName.Button)
        holder.text = GetComponentWithPath(self.goMoreBtns, "AddBetBtn"..list[i].."/Value", ComponentTypeName.Text)
        self.betBtnHolderArray[list[i]] = holder
    end

    self.switcher = GetComponentWithPath(self.root, "Bottom/Action/StateSwitcher", "UIStateSwitcher");
end


function TableView_ZhaJinNiu:setRoomInfo(roomInfo)
    if self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0 then
        self.textRoomNum.text = AppData.MuseumName .."房号:" .. roomInfo.roomNum
    else
        self.textRoomNum.text = "房号:" .. roomInfo.roomNum
    end

    self.textRoundNum.text = self:getRoomInfoDesc(roomInfo)
    self.textRoundNum.transform.parent.gameObject:SetActive(true)
end

function TableView_ZhaJinNiu:getRoomInfoDesc(roomInfo)
    local ruleTable = ModuleCache.Json.decode(roomInfo.rule)
    local desc = "第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局"
    if(ruleTable.maxBetScore)then
        desc = desc .. " 上限:" .. ruleTable.maxBetScore * 2
    end
    if(ruleTable.payType == 0)then
        desc = desc .. " AA支付"
    elseif(ruleTable.payType == 1)then
        desc = desc .. " 房主支付"
    end
    desc = desc .. " 底注:1"
    desc = desc .. " 第" .. roomInfo.curBetRoundNum .. "/" .. roomInfo.totalBetRoundCount .. "轮"
    return desc
end

function TableView_ZhaJinNiu:refreshBatteryAndTimeInfo()
    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue / 100
    self.sliderBattery.value = batteryValue
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

function TableView_ZhaJinNiu:showWifiState(show, wifiLevel)    
    for i=1,#self.goWifiStateArray do        
        ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)   
    end
end

function TableView_ZhaJinNiu:show4GState(show, signalType)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")       
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")       
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")       
end

function TableView_ZhaJinNiu:showCenterTips(show, content)
    
    ModuleCache.ComponentUtil.SafeSetActive(self.textCenterTips.transform.parent.gameObject, show)
    if(show)then
        self.textCenterTips.text = content
    end   
end

--function TableView_ZhaJinNiu:showReadyBtn(show)    
--    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, show)   
--    ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, show and (not ModuleCache.GameManager.iosAppStoreIsCheck))   
--end

--function TableView_ZhaJinNiu:showStartBtn(show)
--    ModuleCache.ComponentUtil.SafeSetActive(self.buttonStart.gameObject, show)    
--end

-- 刷新准备状态,房主显示离开房间,邀请好友,开始游戏.  非房主显示离开房间和邀请好友
function TableView_ZhaJinNiu:refreshReadyState(isCreator)

    if isCreator then
        self.switcher:SwitchState("Three");
    else
        self.switcher:SwitchState("Two");
    end
end

--隐藏所有选择按钮
function TableView_ZhaJinNiu:hideAllReadyButton()

 self.switcher:SwitchState("Disable");
end

function TableView_ZhaJinNiu:showContinueBtn(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonContinue.gameObject, show)
end

--显示牛名
function TableView_ZhaJinNiu:showNiuName(seatData, show, niuName, mask)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]    
    if(show)then
        TableHelper:showNiuName(seatHolder, true, niuName, mask)
    else
        TableHelper:showNiuName(seatHolder, false, nil)
    end
    
end

function TableView_ZhaJinNiu:showNiuNiuEffect(seatData, show, duration, stayTime, delayTime, onComplete)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showNiuNiuEffect(seatHolder, show, duration, stayTime, delayTime, onComplete)
end


function TableView_ZhaJinNiu:hideAllNiuNiuEffect()
	for i=1,#self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]        
        TableHelper:showNiuNiuEffect(seatHolder, false)
    end
end

function TableView_ZhaJinNiu:resetSelectedPokers()
	local cardsArray = self.seatHolderArray[1].inhandCardsArray
	for i=1,#cardsArray do		
		self:refreshCardSelect(cardsArray[i], true)		
	end	
end

function TableView_ZhaJinNiu:refreshSeat(seatData)    
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    --刷新座位基本信息
    self:refreshSeatInfo(seatData)
    --刷新座位状态
    self:refreshSeatState(seatData)
    --刷新玩家看牌、弃牌状态
    self:refreshSeatPlayState(seatData)
    --给手牌设置蒙板
    self:setInHandCardsMaskColor(seatData, seatData.zhaJinNiu_state == 3 or seatData.zhaJinNiu_state == 4)
end

--刷新座位玩家状态
function TableView_ZhaJinNiu:refreshSeatState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]

    ----TODO XLQ 快速组局 服务器3分钟倒计时结束后取消准备通知
    --if self.modelData.roleData.RoomType ==2 and not seatData.isReady and (not seatData.curRound) and tonumber(seatData.playerId) == tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId) then
    --    self.buttonReady_fastStart.gameObject:SetActive(self.modelData.curTableData.roomInfo.curRoundNum == 0)
    --end

    TableHelper:refreshSeatState(seatHolder, seatData)
end

function TableView_ZhaJinNiu:setInHandCardsMaskColor(seatData, mask)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:setInHandCardsMaskColor(seatHolder, mask)
end

--刷新玩家看牌、弃牌的状态
function TableView_ZhaJinNiu:refreshSeatPlayState(seatData, clean)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:refreshSeatPlayState(seatHolder, seatData, clean)
end

--显示座位本局下注的总分数
function TableView_ZhaJinNiu:showSeatCostGold(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showSeatCostGold(seatHolder, show, seatData.zhaJinNiu_betScore)
end

--显示本局注池的分数
function TableView_ZhaJinNiu:showCurRoundBetScore(show, score)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCurRoundBetScore, show) 
    self.textCurRoundBetScore.text = score
end

--刷新在线状态
function TableView_ZhaJinNiu:refreshSeatOfflineState(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:refreshSeatOfflineState(seatHolder, seatData)
end

function TableView_ZhaJinNiu:refreshSeatInfo(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:refreshSeatInfo(seatHolder, seatData)
end

function TableView_ZhaJinNiu:showInHandCards(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showInHandCards(seatHolder, show)
end

function TableView_ZhaJinNiu:refreshInHandCards(seatData, showFace, useAnim)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    local inHandPokerList = seatData.inHandPokerList
    TableHelper:refreshInHandCards(seatHolder, inHandPokerList, showFace, useAnim)
end

--显示比牌选择框
function TableView_ZhaJinNiu:showSelectCompare(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSelectCompare, show)
end


--显示聊天气泡
function TableView_ZhaJinNiu:show_chat_bubble(localSeatIndex, content)
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
    local timeEvent = nil
    timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete(function(t)
        chatBubble:SetActive(false)
    end)
    seatInfo.timeChatEvent_id = timeEvent.id
end

--显示表情
function TableView_ZhaJinNiu:show_chat_emoji(localSeatIndex, emojiId)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local curEmoji
    for i=1,#seatHolder.emojiGoArray do
        local goEmoji = seatHolder.emojiGoArray[i]
        if(i == emojiId)then
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
    timeEvent = View.subscibe_time_event(self, 3, false, 0):OnComplete(function(t)
        if(curEmoji)then
            ModuleCache.ComponentUtil.SafeSetActive(curEmoji, false)
        end        
    end)
    seatHolder.timeChatEmojiEvent_id = timeEvent.id
end



function TableView_ZhaJinNiu:show_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(true)
end

function TableView_ZhaJinNiu:hide_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(false)
end

function TableView_ZhaJinNiu:show_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goSpeaking, show) 
end

function TableView_ZhaJinNiu:show_cancel_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCancelSpeaking, show) 
end

function TableView_ZhaJinNiu:showSeatRoundScoreAnim(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showRoundScoreEffect(seatHolder, seatData.localSeatIndex , show, score)
end

function TableView_ZhaJinNiu:showRandomBankerEffect(seatData, show)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableHelper:showRandomBankerEffect(seatHolder, show)
end

function TableView_ZhaJinNiu:showSeatWinScoreCurRound(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]    
    TableHelper:showSeatWinScoreCurRound(seatHolder, show, score)    
end

--------------------------------------------------------------------------------
--按钮置灰
function TableView_ZhaJinNiu:maskGrayButton(obj, gray)
    self:setGray(obj, gray)
    --local children = ModuleCache.ComponentUtil.GetComponentsInChildren(obj.gameObject, ComponentTypeName.Image)
    --local grayColor = UnityEngine.Color(0.65, 0.65, 0.65, 1)
    --local normalColor = UnityEngine.Color(1,1,1,1)
    --for i=0,children.Length - 1 do
    --    local img = children[i]
    --    if(gray)then
    --        img.color = grayColor
    --        --ModuleCache.CustomerUtil.SetAlpha(img, 0.5)
    --    else
    --        img.color = normalColor
    --        --ModuleCache.CustomerUtil.SetAlpha(img, 1)
    --    end
    --end
end

--置灰
function TableView_ZhaJinNiu:setGray(go, isGray)
    if(not self._grayMat)then
        return
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
end

--按钮使能
function TableView_ZhaJinNiu:enableButton(obj, enable)
    local children = ModuleCache.ComponentUtil.GetComponentsInChildren(obj, "UnityEngine.UI.Graphic")
    for i=0,children.Length - 1 do
        local img = children[i]
        if(enable)then
            img.raycastTarget = true
        else
            img.raycastTarget = false
        end
    end
end

--刷新下注按钮
function TableView_ZhaJinNiu:refreshBetBtns(canBetScoreList, baseScore, originalBetScoreList)
    baseScore = baseScore or 1
    for i, v in pairs(self.betBtnHolderArray) do
        ModuleCache.ComponentUtil.SafeSetActive(v.button.gameObject, false)
    end

    for i, v in pairs(originalBetScoreList) do
        local holder = self.betBtnHolderArray[v]
        if(holder)then
            holder.value = baseScore * v
            holder.text.text = holder.value
            ModuleCache.ComponentUtil.SafeSetActive(holder.button.gameObject, true)
            self:setGray(holder.button.gameObject, true)
            self:enableButton(holder.button.gameObject, false)
        end
    end

    local min

    for i, v in pairs(canBetScoreList) do
        if(not min)then
            min = v
        else
            if(min > v)then
                min = v
            end
        end
    end
    self.textFollowValue.text = self:format_score(min * baseScore)
    self.textComparePokerValue.text = self:format_score(min * baseScore)
    self.textFollowAlwaysValue.text = self:format_score(min * baseScore)

    for i, v in pairs(canBetScoreList) do
        if(min ~= v)then
            local holder = self.betBtnHolderArray[v]
            if(holder)then
                holder.value = baseScore * v
                holder.text.text = holder.value
                ModuleCache.ComponentUtil.SafeSetActive(holder.button.gameObject, true)
                self:setGray(holder.button.gameObject, false)
                self:enableButton(holder.button.gameObject, true)
            end
        end
    end
end

function TableView_ZhaJinNiu:format_score(val)
    val = val or 0
    local unit = 10000
    if(val >= unit)then
        return string.format('%d万', math.ceil (val / unit))
    else
        return val .. ''
    end
end

--显示更多
function TableView_ZhaJinNiu:showBetBtns(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goMoreBtns.transform.parent.gameObject, show or false)
end

--显示比牌特效
function TableView_ZhaJinNiu:showConstrastEffect_New(show, seatInfo1, seatInfo2, leftWin, onFinish)
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect_New.goRoot, true)
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect_New.left.goAnimator, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.holderConstrastEffect_New.right.goAnimator, false)
    if(not show)then
        return
    end
    ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/compare_poker.bytes", "compare_poker")
    self:subscibe_time_event(0.3, false, 0):OnComplete(function()
        ModuleCache.SoundManager.play_sound("cowboy", "cowboy/sound/zhajinniu/compare_poker_boom.bytes", "compare_poker_boom")
    end)
    local holder = self.holderConstrastEffect_New.right
    if(leftWin)then
        holder = self.holderConstrastEffect_New.left
    end
    ModuleCache.ComponentUtil.SafeSetActive(holder.goAnimator, true)
    self:setConstrastPlayerInfo(seatInfo1, holder.textName1, holder.imageHead1)
    self:setConstrastPlayerInfo(seatInfo2, holder.textName2, holder.imageHead2)
    self:subscibe_time_event(1.7, false, 0):OnComplete(function(t)
        if(onFinish)then
            onFinish()
        end
    end)
end

function TableView_ZhaJinNiu:setConstrastPlayerInfo(seatInfo, text, image)
    text.text = ''
    image.sprite = nil
    if (seatInfo.playerInfo and seatInfo.playerInfo.userId and seatInfo.playerInfo.userId..'' == seatInfo.playerId..'') then
        text.text = Util.filterPlayerName(seatInfo.playerInfo.playerName)
        local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
        if(seatHolder.imagePlayerHead.sprite)then
            image.sprite = seatHolder.imagePlayerHead.sprite
        else
            TableHelper:startDownLoadHeadIcon(image, seatInfo.playerInfo.headUrl)
        end
    else
        TableHelper:get_userinfo(seatInfo.playerId, function(err, data)
            if(err)then
                return
            end
            text.text = Util.filterPlayerName(data.nickname)
            TableHelper:startDownLoadHeadIcon(image, data.headImg)
        end);
    end
end


--显示比牌特效
function TableView_ZhaJinNiu:showConstrastEffect(show, leftWin, onFinish)


end

--显示比牌前的扑克飞跃动画
function TableView_ZhaJinNiu:showSeatPokerFly2ComparePosEffect(seatData, show, isLeft, onFinish)

end

--显示比牌后的扑克飞跃动画
function TableView_ZhaJinNiu:showComparePokerFly2SeatPosEffect(seatData, show, isLeft, onFinish)

end

--显示手牌膨胀特效
function TableView_ZhaJinNiu:showInHandCardsExpandEffect(seatData, show, onFinish)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    local handPokerCardsRoot = seatHolder.handPokerCardsRoot
    
    local originalScale = handPokerCardsRoot.transform.localScale
    local sequence = self:create_sequence();
    local duration = 1
    for i=1,5 do
        local cardHolder = seatHolder.inhandCardsArray[i]
        local imageLightFrame = cardHolder.imageLightFrame
        ModuleCache.ComponentUtil.SafeSetActive(imageLightFrame.gameObject, true)
    end
    local loopTime = 1
    for i=1,loopTime do
        sequence:Append(handPokerCardsRoot.transform:DOScaleX(originalScale.x * 1.1, duration/loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
        sequence:Join(handPokerCardsRoot.transform:DOScaleY(originalScale.y * 1.1, duration/loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
        sequence:Append(handPokerCardsRoot.transform:DOScaleX(originalScale.x, duration/loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))
        sequence:Join(handPokerCardsRoot.transform:DOScaleY(originalScale.y, duration/loopTime * 0.5):SetEase(DG.Tweening.Ease.InOutQuint))  
    end

    sequence:OnComplete(function() 
        for i=1,5 do
            local cardHolder = seatHolder.inhandCardsArray[i]
            local imageLightFrame = cardHolder.imageLightFrame
            ModuleCache.ComponentUtil.SafeSetActive(imageLightFrame.gameObject, false)
        end
        
        if(onFinish)then                
            onFinish()
        end
    end) 
end

--屏蔽点击
function TableView_ZhaJinNiu:showMask(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goMask.gameObject, show)
end

--显示座位的倒计时效果
function TableView_ZhaJinNiu:showSeatTimeLimitEffect(seatData, show, duration, onFinish, loopTimes, on_update_fun)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageTimeLimit.gameObject, show)
    if(seatHolder.timeLimit)then
        CSmartTimer:Kill(seatHolder.timeLimit.timeEvent_id)
        seatHolder.timeLimit = nil
    end
    if(not show)then
        return
    end
    
    seatHolder.timeLimit = {}
    seatHolder.timeLimit.startTime = Time.realtimeSinceStartup
    seatHolder.timeLimit.endTime = Time.realtimeSinceStartup + duration
    seatHolder.timeLimit.curTime = Time.realtimeSinceStartup
    local timeEvent = View.subscibe_time_event(self, duration, false, 0):OnComplete(function(t)
        seatHolder.timeLimit = nil
        if(onFinish)then
            onFinish()
        end
        if(loopTimes)then
            if(loopTimes < 0)then
                self:showSeatTimeLimitEffect(seatData, show, duration, onFinish, loopTimes, on_update_fun)
            elseif(loopTimes > 0)then
                self:showSeatTimeLimitEffect(seatData, show, duration, onFinish, loopTimes - 1, on_update_fun)
            end
        end
    end):SetIntervalTime(0.05, function(t)
        seatHolder.timeLimit.curTime = Time.realtimeSinceStartup
        local costTime = (seatHolder.timeLimit.curTime - seatHolder.timeLimit.startTime)
        local leftTime = duration - costTime
        local rate =  costTime/ duration
        seatHolder.imageTimeLimit.fillAmount = rate
        seatHolder.imageTimeLimit_Frame.color = self:get_time_color(rate)
        if(on_update_fun)then
            on_update_fun(costTime, leftTime)
        end
    end)
    seatHolder.timeLimit.timeEvent_id = timeEvent.id
end

function TableView_ZhaJinNiu:get_time_color(fillAmount)
    if(fillAmount > 0.9) then
        return UnityEngine.Color(1, 0, 0, 1)
    elseif(fillAmount > 0.85) then
        return UnityEngine.Color(1, 0.05, 0, 1)
    elseif(fillAmount > 0.8) then
        return UnityEngine.Color(1, 0.1, 0, 1)
    elseif(fillAmount > 0.75) then
        return UnityEngine.Color(1, 0.15, 0, 1)
    elseif(fillAmount > 0.7) then
        return UnityEngine.Color(1, 0.2, 0, 1)
    elseif(fillAmount > 0.65) then
        return UnityEngine.Color(1, 0.25, 0, 1)
    elseif(fillAmount > 0.6) then
        return UnityEngine.Color(1, 0.3, 0, 1)
    elseif(fillAmount > 0.55) then
        return UnityEngine.Color(1, 0.35, 0, 1)
    elseif(fillAmount > 0.5) then
        return UnityEngine.Color(1, 0.4, 0.001, 1)
    elseif(fillAmount > 0.4) then
        return UnityEngine.Color(0.9, 0.45, 0.001, 1)
    elseif(fillAmount > 0.35) then
        return UnityEngine.Color(0.85, 0.5, 0.001, 1)
    elseif(fillAmount > 0.3) then
        return UnityEngine.Color(0.8, 0.55, 0.002, 1)
    elseif(fillAmount > 0.25) then
        return UnityEngine.Color(0.75, 0.6, 0.002, 1)
    elseif(fillAmount > 0.2) then
        return UnityEngine.Color(0.7, 0.62, 0.002, 1)
    elseif(fillAmount > 0.15) then
        return UnityEngine.Color(0.65, 0.65, 0.002, 1)
    elseif(fillAmount > 0.1) then
        return UnityEngine.Color(0.6, 0.7, 0.003, 1)
    elseif(fillAmount > 0.05) then
        return UnityEngine.Color(0.55, 0.75, 0.003, 1)
    elseif(fillAmount > 0) then
        return UnityEngine.Color(0.5, 0.8, 0, 1)
    else
        return UnityEngine.Color(1, 1, 1, 1)
    end
end

--显示弃牌牌按钮
function TableView_ZhaJinNiu:showDropPokersButton(show, enable)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonDropPoker.gameObject, show)
    if(not show)then
        return
    end
    self:maskGrayButton(self.buttonDropPoker.gameObject, not enable)
    self:enableButton(self.buttonDropPoker.gameObject, enable)
end

--显示比牌按钮
function TableView_ZhaJinNiu:showComparePokersButton(show, enable)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonComparePoker.gameObject, show)
    if(not show)then
        return
    end
    self:maskGrayButton(self.buttonComparePoker.gameObject, not enable)
    self:enableButton(self.buttonComparePoker.gameObject, enable)
end

--显示看牌按钮
function TableView_ZhaJinNiu:showCheckPokersButton(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonCheckPoker.gameObject, show)
end

--显示跟到底按钮
function TableView_ZhaJinNiu:showFollowAlwaysButton(show)
    local obj = self.toggleFollowAlways.gameObject
    ModuleCache.ComponentUtil.SafeSetActive(obj, show)
end

--显示跟注按钮
function TableView_ZhaJinNiu:showFollowButton(show, enable)
    local obj = self.buttonFollow.gameObject
    ModuleCache.ComponentUtil.SafeSetActive(obj, show)
    self:maskGrayButton(obj, not enable)
    self:enableButton(obj, enable)
end

--显示加注按钮
function TableView_ZhaJinNiu:showRaiseButton(show, enable)
    local obj = self.buttonRaise.gameObject
    ModuleCache.ComponentUtil.SafeSetActive(obj, show)
    self:maskGrayButton(obj, not enable)
    self:enableButton(obj, enable)
end

--显示更多按钮
function TableView_ZhaJinNiu:showMoreBtns(show, enable)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonMore.gameObject, show)
    self:maskGrayButton(self.buttonMore.gameObject, not enable)
    self:enableButton(self.buttonMore.gameObject, enable)
end

--静态生成金币堆
function TableView_ZhaJinNiu:genGoldHeap(curRoundBetScoreList, baseScore)
    for i=1,#curRoundBetScoreList do
        self:goldFlyToGoldHeap(self.holderGolds.root.transform.position, curRoundBetScoreList[i], 0, baseScore)
    end
end

--金币飞到注池
function TableView_ZhaJinNiu:goldFlyToGoldHeapFromSeat(seatData, betScore, baseScore)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self:goldFlyToGoldHeap(seatHolder.buttonNotSeatDown.transform.position, betScore, 0.7, baseScore)
end

function TableView_ZhaJinNiu:goldFlyToGoldHeap(fromPos, betScore, duration, baseScore)
    if(not self.goldList)then
		self.goldList = {}
	end

	local goldList = {}
    local tmpScore = betScore
    while tmpScore > 0 do
        local goGold
        if(tmpScore > 10 * baseScore)then
            tmpScore = tmpScore - 10 * baseScore
            self.textGold4.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold4, self.holderGolds.root)
        elseif(tmpScore >= 8 * baseScore)then
            self.textGold4.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold4, self.holderGolds.root)
            tmpScore = 0
        elseif(tmpScore > 6 * baseScore)then
            tmpScore = tmpScore - 6 * baseScore
            self.textGold3.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold3, self.holderGolds.root)
        elseif(tmpScore >= 5 * baseScore)then
            self.textGold3.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold3, self.holderGolds.root)
            tmpScore = 0
        elseif(tmpScore > 4 * baseScore)then
            tmpScore = tmpScore - 4 * baseScore
            self.textGold2.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold2, self.holderGolds.root)
        elseif(tmpScore >= 3 * baseScore)then
            self.textGold2.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold2, self.holderGolds.root)
            tmpScore = 0
        else
            self.textGold1.text = tmpScore
            goGold = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabGold1, self.holderGolds.root)
            tmpScore = 0
        end
        ModuleCache.ComponentUtil.SafeSetActive(goGold, true) 
        table.insert(self.goldList, goGold)
        table.insert(goldList, goGold)
    end
    --print(#goldList, betScore)
	TableHelper:goldFlyToGoldHeap(goldList, fromPos, self.goldHeapRect, duration)
end


--金币从注池飞到座位
function TableView_ZhaJinNiu:goldFlyToSeat(seatData, onFinish)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    if(self.goldList)then
		TableHelper:goldFlyToSeat(self.goldList, seatHolder.buttonNotSeatDown.transform.position, 0.5, 0, true, function ( ... )
            if(onFinish)then
                onFinish()
            end
		end)
		self.goldList = {}
	end
end

function TableView_ZhaJinNiu:showZhaJinNiuBtns(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goZhaJinNiuBtnsRoot, show)
end

function TableView_ZhaJinNiu:refreshContinueTimeLimitText(secs)
    self.textContinueLimitTime.text = string.format( "(%d)",secs)
end

function TableView_ZhaJinNiu:show_ping_delay(show, delaytime)
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

function TableView_ZhaJinNiu:playSeatWinAnim(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local go = seatHolder.goWinAnim
    ModuleCache.ComponentUtil.SafeSetActive(go, true)
    self:subscibe_time_event(1.5, false, 0):OnComplete(function()
        ModuleCache.ComponentUtil.SafeSetActive(go, false)
    end)
end

function TableView_ZhaJinNiu:showSeatMask(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    TableHelper:showSeatMask(seatHolder, show)
end

return  TableView_ZhaJinNiu