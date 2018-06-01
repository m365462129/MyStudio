local BranchPackageName = AppData.BranchRunfastName
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameSDKInterface = ModuleCache.GameSDKInterface
local Sequence = DG.Tweening.DOTween.Sequence
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
local TableRunfastHelper = require(string.format("package/%s/module/tablerunfast/tablerunfast_helper",BranchPackageName))
---@class TableRunfastView
local TableRunfastView = class('TableRunfastView', View)
local PlayerPrefs = UnityEngine.PlayerPrefs

------初始化
function TableRunfastView:initialize( ... )
    self.curTableData_PB = TableManager.curTableData_PB
    View.initialize(self, BranchPackageName.."/module/tablerunfast/runfast_table.prefab", "Runfast_Table", 0)  
    self.TestButton1 = GetComponentWithPath(self.root, "Top/TopInfo/TestButton1", ComponentTypeName.Button)
    if(not ModuleCache.GameManager.developmentMode) then
        ModuleCache.ComponentUtil.SafeSetActive(self.TestButton1.gameObject, false)  
    end

    self.goActivity = ModuleCache.ComponentManager.Find(self.root,"Bottom/Action/BtnActivity")
    self.goSpriteRedPoint = ModuleCache.ComponentManager.Find(self.goActivity,"RedPoint")
    self:SetState_BtnActivity(false)
    self.TopRootUIStateSwitcher = GetComponentWithPath(self.root,"TopRight/TopRoot", "UIStateSwitcher")
    self.AnticheatMatchingRoot = GetComponentWithPath(self.root,"Center/AnticheatMatchingRoot", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.AnticheatMatchingRoot.gameObject,false)

    self.JinBiChangStateSwitcher = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher", "UIStateSwitcher")
    self.ButtonReplaceTable = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonReplaceTable", ComponentTypeName.Button)
    self.ButtonReplaceTableText = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonReplaceTableGray/Text", ComponentTypeName.Text)
    self.ButtonJinBiChangReady = GetComponentWithPath(self.root, "Bottom/Action/JinBiChangStateSwitcher/ButtonJinBiChangReady", ComponentTypeName.Button)


    self.CancelIntrustRoot = GetComponentWithPath(self.root, "Bottom/CancelIntrustRoot", ComponentTypeName.Transform).gameObject
    self.BtnCancelIntrust = GetComponentWithPath(self.root, "Bottom/CancelIntrustRoot/BtnCancelIntrust", ComponentTypeName.Button)
    self:SetCancelIntrustState(false)
    self.TipsServiceFeeRoot = GetComponentWithPath(self.root,"Center/TipsServiceFee",ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.TipsServiceFeeRoot.gameObject, false)
    self.TipsServiceFeeText = GetComponentWithPath(self.root, "Center/TipsServiceFee/Text", ComponentTypeName.Text)
    self.ButtonShop = GetComponentWithPath(self.root,"TopLeft/Root/ButtonShop", ComponentTypeName.Button)
    self.ButtonJinBiChangExit = GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/Bg/JinBiChangMatch/ButtonJinBiChangExit", ComponentTypeName.Button)
    self.ButtonRuleExplain = GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/Bg/JinBiChangMatch/ButtonRuleExplain", ComponentTypeName.Button)
    self.BtnLeftOpen = GetComponentWithPath(self.root,"TopLeft/Root/BtnLeftOpen", ComponentTypeName.Button)
    self.BtnLeftClose = GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/BtnLeftClose", ComponentTypeName.Button)
    self.LeftRoot = GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot", ComponentTypeName.Transform).gameObject
    self:SetState_LeftRoot(false)
    self.RecordPokerRoot = GetComponentWithPath(self.root,"Top/TopInfo/RecordPokerRoot",ComponentTypeName.Transform).gameObject
    self.BtnRecordPoker = GetComponentWithPath(self.root, "Top/TopInfo/RecordPokerRoot/BtnRecordPoker", ComponentTypeName.Button)
    self.RecordPokerShowRoot = GetComponentWithPath(self.root,"Top/TopInfo/RecordPokerRoot/RecordPokerShowRoot",ComponentTypeName.Transform).gameObject
    self:SetState_RecordPokerShowRoot(false)
    self.RecordPokerCountSlotArray = {}
    for i=1,13 do
        local RecordPokerCountPath = "Top/TopInfo/RecordPokerRoot/RecordPokerShowRoot/PokerCount/Text" .. i
        local RecordPokerCountText = GetComponentWithPath(self.root, RecordPokerCountPath, ComponentTypeName.Text)
        table.insert(self.RecordPokerCountSlotArray,RecordPokerCountText)
    end
    self.RecordPokerTimeRoot = GetComponentWithPath(self.root,"Top/TopInfo/RecordPokerRoot/RecordPokerTimeRoot",ComponentTypeName.Transform).gameObject
    self:SetState_RecordPokerTimeRoot(false)
    self.RecordPokerTimeText = GetComponentWithPath(self.root, "Top/TopInfo/RecordPokerRoot/RecordPokerTimeRoot/TextBg/Time", ComponentTypeName.Text)


    self.EffectXuanZhuanHeiTao3Root = GetComponentWithPath(self.root,"Center/EffectXuanZhuanHeiTao3Root",ComponentTypeName.Transform).gameObject
    self:SetEffectXuanZhuanHeiTao3RootState(false)
    self.EffectXuanZhuan_PaiMian = GetComponentWithPath(self.root,"Center/EffectXuanZhuanHeiTao3Root/Anim_DGT_RunfastXuanZhuan/Animator/HeXinZu/PuKe1/PaiMian",ComponentTypeName.Transform).gameObject
    
    self.CenterRule = GetComponentWithPath(self.root, "Background/CenterRule", ComponentTypeName.Text)
    self.tableBackgroundSprite = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image).sprite
    self.NotAllowActionMask = GetComponentWithPath(self.root, "NotAllowActionMask", ComponentTypeName.Transform).gameObject
    self:SetNotAllowActionMaskState(false)
    self.NotAllowActionMaskLastPokerAuto = GetComponentWithPath(self.root, "NotAllowActionMaskLastPokerAuto", ComponentTypeName.Transform).gameObject
    self:SetNotAllowActionMaskLastPokerAutoState(false)

    self.PokerPrefabParent = GetComponentWithPath(self.root, "Bottom/HandPokers", ComponentTypeName.Transform).gameObject
    self.PokerPrefab = GetComponentWithPath(self.root, "Bottom/HandPokers/PokerPrefab", ComponentTypeName.Transform).gameObject
    self.HandPokersLayout = GetComponentWithPath(self.root, "Bottom/HandPokers/PokerPrefab", "HorizontalLayoutGroup")
    self:InstantiatePokerSlot()

    --第一人称打出去的牌的槽的数组
    self.FirstThrowPokerGridLayoutGroupRoot = GetComponentWithPath(self.root, "Bottom/ThrowPokerRoot/GridLayoutGroup", ComponentTypeName.Transform).gameObject
    self.FirstThrowPokerSlotArray = {}
    for i=1,TableRunfastHelper.pokerSlotMaxCount do
        local locFirstPath = "Bottom/ThrowPokerRoot/GridLayoutGroup/PokerPrefab"..i
        local SlotData = {}
        SlotData.PrefabGo = GetComponentWithPath(self.root, locFirstPath,ComponentTypeName.Transform).gameObject
        ModuleCache.ComponentUtil.SafeSetActive(SlotData.PrefabGo,false)
        SlotData.FaceImage = GetComponentWithPath(self.root, locFirstPath.."/face",ComponentTypeName.Image)
        table.insert(self.FirstThrowPokerSlotArray,SlotData)
    end

    self.NotAffordWarningRoot = GetComponentWithPath(self.root, "Bottom/MySeNotAffordWarningRoot", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.NotAffordWarningRoot, false)  
    self.goTmpBankerPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpBankerPos", ComponentTypeName.Transform).gameObject
    self.goTmpPokerHeapPos = GetComponentWithPath(self.root, "Center/PosHolder/TmpPokerHeapPos", ComponentTypeName.Transform).gameObject
    self.buttonInvite = GetComponentWithPath(self.root, "Bottom/Action/ButtonInviteFriend", ComponentTypeName.Button)

    self.buttonReady_quickStart = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady_quickStart", ComponentTypeName.Button)
    self.buttonReady_quickStart_TextWrap = GetComponentWithPath(self.buttonReady_quickStart.gameObject, "NumberImage", "TextWrap")

    self.ButtonInviteFriendDray = GetComponentWithPath(self.root, "Bottom/Action/ButtonInviteFriendDray", ComponentTypeName.Button)
    self.buttonReady = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady", ComponentTypeName.Button) 
    self.ButtonLeave = GetComponentWithPath(self.root, "Bottom/Action/ButtonLeave", ComponentTypeName.Button) 
    self.ButtonLeaveText = GetComponentWithPath(self.root, "Bottom/Action/ButtonLeave/Text", ComponentTypeName.Text) 
    self.ButtonLeave_LeaveRoom = GetComponentWithPath(self.root, "Bottom/Action/ButtonLeave/LeaveRoom", ComponentTypeName.Transform).gameObject
    self.ButtonLeave_DissolveRoom = GetComponentWithPath(self.root, "Bottom/Action/ButtonLeave/DissolveRoom", ComponentTypeName.Transform).gameObject
    self.buttonCancelReady = GetComponentWithPath(self.root, "Bottom/Action/ButtonCancelReady", ComponentTypeName.Button)
    self.buttonStart = GetComponentWithPath(self.root, "Bottom/Action/ButtonStart", ComponentTypeName.Button)

    self.DoingRoot = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot", ComponentTypeName.Transform).gameObject
    self.BtnHint = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot/BtnHint", ComponentTypeName.Button)--提示按钮
    self.BtnThrowCard = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot/BtnThrowCard", ComponentTypeName.Button)--出牌按钮
    self.BtnThrowCardDray = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot/BtnThrowCardDray", ComponentTypeName.Button)--出牌按钮
    self.BtnNotAffordRoot = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot/BtnNotAffordRoot", ComponentTypeName.Transform).gameObject
    self.BtnNotAfford = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot/BtnNotAffordRoot/BtnNotAfford", ComponentTypeName.Button)--要不起按钮
    self.BtnNotAffordDray = GetComponentWithPath(self.root, "Bottom/Action/DoingRoot/BtnNotAffordRoot/BtnNotAffordDray", ComponentTypeName.Button)--要不起按钮
    self.BtnUnSelectedAllPoker = GetComponentWithPath(self.root, "Background/BtnUnSelectedAllPoker", ComponentTypeName.Button)--要不起按钮

    self.ZhaDanScoreRoot = GetComponentWithPath(self.root, "ZhaDanScoreRoot", ComponentTypeName.Transform).gameObject
    self.ZhaDanScorePrefab = GetComponentWithPath(self.root, "ZhaDanScoreRoot/ZhaDanScorePrefab", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.ZhaDanScorePrefab,false)

    self.TopInfo = GetComponentWithPath(self.root, "Top/TopInfo", ComponentTypeName.Transform).gameObject
    self.BtnSetting = GetComponentWithPath(self.root,"TopLeft/Root/LeftRoot/Bg/JinBiChangMatch/BtnSetting", ComponentTypeName.Button)
    self.BtnLocation = GetComponentWithPath(self.root, "TopRight/TopRoot/BtnLocation", ComponentTypeName.Button)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnLocation.gameObject, false)

    self.ButtonRoomRule = GetComponentWithPath(self.root,"TopRight/TopRoot/ButtonRule", ComponentTypeName.Button)
    --房间id
    self.textRoomNum = GetComponentWithPath(self.root,"TopRight/TopRoot/RoomID/Text", ComponentTypeName.Text)
    --顶部右的节点
    self.TopRight = GetComponentWithPath(self.root,"TopRight", ComponentTypeName.Transform).gameObject
    --电池,电池充电
    self.BatteryImage = GetComponentWithPath(self.root,"TopRight/TopRoot/Battery/ImageBackground/ImageLevel", ComponentTypeName.Image)
    self.BatteryChargingRoot = GetComponentWithPath(self.root,"TopRight/TopRoot/Battery/ImageCharging", ComponentTypeName.Transform).gameObject
    --当前的时间
    self.textTime = GetComponentWithPath(self.root,"TopRight/TopRoot/Time/Text", ComponentTypeName.Text)
    --当前的网络信号信息
    self.goGState2G = GetComponentWithPath(self.root,"TopRight/TopRoot/NetState/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root,"TopRight/TopRoot/NetState/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root,"TopRight/TopRoot/NetState/GState/4g", ComponentTypeName.Transform).gameObject
    self.textPingValue = GetComponentWithPath(self.root,"TopRight/TopRoot/PingVal", ComponentTypeName.Text)
    self.goWifiStateArray = {}    
    for i=1,5 do
        local goState = GetComponentWithPath(self.root,"TopRight/TopRoot/NetState/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end
    --对话,语音
    self.buttonChat = GetComponentWithPath(self.root, "Bottom/Action/ButtonChat", ComponentTypeName.Button)
    self.buttonMic = GetComponentWithPath(self.root, "Bottom/Action/ButtonMic", ComponentTypeName.Button)
    self.goSpeaking = GetComponentWithPath(self.root, "Speaking", ComponentTypeName.Transform).gameObject
    self.goCancelSpeaking = GetComponentWithPath(self.root, "CancelRecord", ComponentTypeName.Transform).gameObject

    --selfHandPokerRoot自己手上的牌的节点
    local selfHandPokerRoot = GetComponentWithPath(self.root, "Bottom/HandPokers", ComponentTypeName.Transform).gameObject
    self.uiStateSwitcherSeatPrefab = GetComponentWithPath(self.root, "Holder/Seat", "UIStateSwitcher")
    ModuleCache.ComponentUtil.SafeSetActive(self.uiStateSwitcherSeatPrefab.gameObject, false)

    self.CardAssetHolder1 = GetComponentWithPath(self.root, "Holder/CardAssetHolder1", "SpriteHolder")
    self.CardAssetHolder2 = GetComponentWithPath(self.root, "Holder/CardAssetHolder2", "SpriteHolder")
    self:CheckStyleType()

    --print("=============牌面样式=",PlayerPrefs.GetInt(PokerStyleTypeKey))
    self.srcSeatHolderArray = {}
    local seatMaxCount = TableRunfastHelper.seatMaxCount --最多几人玩

    for i=1,seatMaxCount do
        local seatPosTran = GetComponentWithPath(self.root, "Center/Seats/" .. i, ComponentTypeName.Transform)
        local goSeat = ModuleCache.ComponentUtil.InstantiateLocal(self.uiStateSwitcherSeatPrefab.gameObject, seatPosTran.gameObject)
        local seatHolder = {}

        if(i == 1) then
             TableRunfastHelper:initSeatHolder(seatHolder, i, goSeat, selfHandPokerRoot)
             seatHolder.NotAffordEffectRoot = GetComponentWithPath(self.root, "Bottom/NotAfford/NotAffordImage", ComponentTypeName.Transform).gameObject
             ModuleCache.ComponentUtil.SafeSetActive(seatHolder.NotAffordEffectRoot,false)
             seatHolder.EffectType = {}
             local effectPath = "Bottom/Effect/"
             seatHolder.EffectType.Effect_Feiji = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Feiji"), ComponentTypeName.Transform).gameObject
             seatHolder.EffectType.Effect_Liandui = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Liandui"), ComponentTypeName.Transform).gameObject
             seatHolder.EffectType.Effect_Quanguan = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Quanguan"), ComponentTypeName.Transform).gameObject
             seatHolder.EffectType.Effect_Sandaier = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Sandaier"), ComponentTypeName.Transform).gameObject
             seatHolder.EffectType.Effect_Sandaiyi = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Sandaiyi"), ComponentTypeName.Transform).gameObject
             seatHolder.EffectType.Effect_Shunzi = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Shunzi"), ComponentTypeName.Transform).gameObject
             seatHolder.EffectType.Effect_Zhadan = GetComponentWithPath(self.root, (effectPath.."Ainm_Paixing_Zhadan"), ComponentTypeName.Transform).gameObject
        else 
             TableRunfastHelper:initSeatHolder(seatHolder, i, goSeat, nil)
        end

        TableRunfastHelper:refreshSeatInfo(seatHolder, {})
        seatHolder.seatPosTran = seatPosTran
        seatHolder.goTmpBankerPos = self.goTmpBankerPos
        seatHolder.goTmpPokerHeapPos = self.goTmpPokerHeapPos   --牌堆位置
        self.srcSeatHolderArray[i] = seatHolder
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.seatRoot, false) 
    end

    if ModuleCache.GameManager.iosAppStoreIsCheck then
        self.buttonMic.gameObject:SetActive(false)
        self.goActivity:SetActive(false)
    end


    self:InitiPB()
end


------设置房间信息
function TableRunfastView:setRoomInfo(roomInfo)
    if self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0 then
        self.textRoomNum.text = AppData.MuseumName .."房号:" .. roomInfo.roomNum
    else
        self.textRoomNum.text = "房号:" .. roomInfo.roomNum
    end

    local locResult = ""
    local ruleTable = roomInfo.createRoomRule
    if(ruleTable) then
        if(self:isJinBiChang()) then
            if(roomInfo.maxPlayerCount >= 3) then
                locResult = locResult .. " ".. "黑桃3先出"
            end
        else
            if(ruleTable.game_type == nil) then
            else
                locResult = locResult .. " ".. TableManager:GetCurTip(ruleTable.game_type)
            end
        end
        locResult = locResult .. " ".. ruleTable.init_card_cnt .. "张牌"
        locResult = locResult .. (ruleTable.pay_all and " 放走包赔" or "")
        locResult = locResult .. " "..(ruleTable.allow_pass and "可过牌" or "有牌必压")
        locResult = locResult .. (ruleTable.have2mustpressA and " 有2必打A" or "")
        locResult = locResult .. (ruleTable.isPrivateRoom and " 私人房" or "")
        if(self:isGoldSettle()) then
            locResult = locResult .. " ".. "底分:".. self:GetCurBaseCoinScore()
        end
        if(not self:isJinBiChang()) then
            locResult = locResult .. " ".. "第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局"
        end
    end
    self.CenterRule.text = locResult
end

------刷新电池,时间,网络信号信息
function TableRunfastView:refreshBatteryAndTimeInfo()
    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue * 0.01
    self.BatteryImage.fillAmount = batteryValue
    self.textTime.text = os.date("%H:%M", os.time())
    ModuleCache.ComponentUtil.SafeSetActive(self.BatteryChargingRoot, GameSDKInterface:GetCurChargeState())
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


------wifi信号的强度:show 是否显示,wifiLevel wifi强度
function TableRunfastView:showWifiState(show, wifiLevel)    
    for i=1,#self.goWifiStateArray do        
        ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)   
    end
end


------移动信号:show 是否显示,signalType 移动网络信号类型
function TableRunfastView:show4GState(show, signalType)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")       
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")       
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")       
end

------进入牌桌已经开始游戏清理按钮
function TableRunfastView:EnterTableAlreadyStartGameClearBtn()
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, false) 
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.ButtonInviteFriendDray.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave.gameObject, false)

    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady_quickStart.gameObject, false)
end

------显示准备按钮
function TableRunfastView:showReadyBtn(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, show)   
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, show and (not ModuleCache.GameManager.iosAppStoreIsCheck))  
end

------
function TableRunfastView:EnterTableShowBtn(show,_isCreate)
    --RoomType == 2 快速组局
    if self.modelData.roleData.RoomType ~= 2 then
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave.gameObject, show)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, show and (not ModuleCache.GameManager.iosAppStoreIsCheck))
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave_LeaveRoom, not _isCreate)
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave_DissolveRoom, _isCreate)
    --else
    --    ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave.gameObject, show)
    --    ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, false)
    --    ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady_quickStart.gameObject, show)
    --    ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave_LeaveRoom, show)
    end
end

--亲友圈快速组局 点击准备
function TableRunfastView:readyDoneShow()
    --ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady_quickStart.gameObject, false)
    --self.ButtonLeave.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,-100,0)

end

--亲友圈快速组局刷新所以按钮状态
function TableRunfastView:refreshAllBtnState()
    if(self.modelData.curTableData.roomInfo.curRoundNum <= 0 and self.modelData.roleData.RoomType == 2) then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        --人满了
        local isMaxPlayer = #seatInfoList == self.modelData.curTableData.roomInfo.maxPlayerCount

        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave.gameObject, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave_LeaveRoom, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonLeave_DissolveRoom, false)

        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonInviteFriendDray.gameObject, isMaxPlayer)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, not isMaxPlayer)

        if(self.modelData.curTableData.roomInfo.mySeatInfo.isReady) then
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, false)
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady_quickStart.gameObject, false)

            if isMaxPlayer then
                self.ButtonLeave.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(-150,-100,0)
                self.ButtonInviteFriendDray.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(150,-100,0)
            else
                self.ButtonLeave.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(-150,-100,0)
                self.buttonInvite.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(150,-100,0)
            end
        else
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, not isMaxPlayer)
            ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady_quickStart.gameObject, isMaxPlayer)

            if isMaxPlayer then
                self.ButtonLeave.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(-300,-100,0)
                self.ButtonInviteFriendDray.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,-100,0)
                self.buttonReady_quickStart.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(300,-100,0)
            else
                self.ButtonLeave.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(-300,-100,0)
                self.buttonInvite.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,-100,0)
                self.buttonReady.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(300,-100,0)
            end
        end
    end
end

------显示继续按钮
function TableRunfastView:showContinueBtn(show)
    if(show)then
        --ModuleCache.ComponentUtil.SafeSetActive(self.buttonCancelReady.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonReady.gameObject, false)    
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonInvite.gameObject, false)   
    end
end

------显示开始按钮
function TableRunfastView:showStartBtn(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonStart.gameObject, false)    
end

function TableRunfastView:showBetBtns(show)
end


------刷新座位
function TableRunfastView:refreshSeat(seatData, showCardFace, showCardWithAnim)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    self:refreshSeatInfo(seatData)--刷新座位基本信息
    self:refreshSeatState(seatData)--刷新座位状态
    --刷新手中的牌
    if(seatData.localSeatIndex == 1) then
        TableRunfastHelper:refreshInHandCards(seatHolder, seatData.inHandPokerList, showCardFace, showCardWithAnim)
    else
        if(self.isPlayBacking) then
            TableRunfastHelper:refreshInHandCardsForOthers(seatData)
        end
    end
    TableRunfastHelper:showInHandCards(seatHolder, #seatData.inHandPokerList ~= 0)

end

------显示座位当前局数赢的的分数
function TableRunfastView:showSeatWinScoreCurRound(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]    
    TableRunfastHelper:showSeatWinScoreCurRound(seatHolder, show, score)    
end

------牌的选择
function TableRunfastView:refreshSeatCardsSelect(seatData, withoutAnim)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]  
    local inHandCards = seatHolder.inhandCardsArray
    for i=1,#inHandCards do
        self:refreshCardSelect(inHandCards[i], withoutAnim)    
    end    
end

------
function TableRunfastView:refreshCardSelect(cardHolder, withoutAnim)
    local targetPosY    
    if(cardHolder.selected) then 
        targetPosY = 25
    else
        targetPosY = 0
    end
    
    if(withoutAnim) then        
        ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, targetPosY, true)
    else        
        --local sequence = self:create_sequence();
        --sequence:Append(cardHolder.cardRoot.transform:DOLocalMoveY(targetPosY, 0.1, true))
        cardHolder.cardRoot.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0,targetPosY,0)
    end
end

function TableRunfastView:resetSelectedPokers()
	local cardsArray = self.seatHolderArray[1].inhandCardsArray
	for i=1,#cardsArray do		
		self:refreshCardSelect(cardsArray[i], true)		
	end	
end

function TableRunfastView:SetBtnThrowCardState(_canClick)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnThrowCard.gameObject, _canClick) 
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnThrowCardDray.gameObject,not _canClick) 
end

function TableRunfastView:SetBtnNotAffordState(_canClick)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnNotAfford.gameObject, _canClick) 
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnNotAffordDray.gameObject,not _canClick) 
end

------显示语音:localSeatIndex 座位号
function TableRunfastView:show_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    if(seatRoot ~= nil) then
        local voice = GetComponentWithPath(seatRoot.gameObject, "State/Group/Speak", ComponentTypeName.Transform).gameObject
        voice:SetActive(true)
    end
end

function TableRunfastView:refresh_voice_shake()
    self.openVoice = (PlayerPrefs.GetInt("openVoice", 1) == 1)
end

------隐藏语音
function TableRunfastView:hide_voice(localSeatIndex)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    if(seatRoot~=nil) then
        local voice = GetComponentWithPath(seatRoot.gameObject, "State/Group/Speak", ComponentTypeName.Transform).gameObject
        if(voice ~= nil) then
            voice:SetActive(false)
        end
    end
end


------自己正在语音
function TableRunfastView:show_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goSpeaking, show) 
end


------自己取消语音
function TableRunfastView:show_cancel_speaking_amin(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goCancelSpeaking, show) 
end

------显示聊天气泡
function TableRunfastView:show_chat_bubble(localSeatIndex, content)
    local seatInfo = self.seatHolderArray[localSeatIndex]
    local seatRoot = seatInfo.seatRoot
    local chatBubble = GetComponentWithPath(seatRoot, "State/Group/ChatBubble", ComponentTypeName.RectTransform).gameObject
    local chatText = GetComponentWithPath(chatBubble, "TextBg/Text", ComponentTypeName.Text)
    chatText.text = content
    chatBubble:SetActive(true)

    if seatInfo.timeChatEventId then 
        CSmartTimer:Kill(seatInfo.timeChatEventId)
        seatInfo.timeChatEventId = nil
    end

    local timeChatEvent = self:subscibe_time_event(3, false, 0):OnComplete(function(t)
        if(chatBubble ~=nil) then
            ModuleCache.ComponentUtil.SafeSetActive(chatBubble, false) 
        end
    end)
    seatInfo.timeChatEventId = timeChatEvent.id

end

------显示表情:座位,表情id
function TableRunfastView:show_chat_emoji(localSeatIndex, emojiId)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local curEmoji
    for i=1,20 do
        local goEmoji = GetComponentWithPath(seatHolder.seatRoot, "State/Group/ChatFace/" .. (i-1), ComponentTypeName.Transform).gameObject
        if(goEmoji) then
            if(i == emojiId) then 
                curEmoji = goEmoji
                ModuleCache.ComponentUtil.SafeSetActive(goEmoji, true) 
            else
                ModuleCache.ComponentUtil.SafeSetActive(goEmoji, false) 
            end
        end
    end

    if(seatHolder.timeChatEmojiEventId) then
        CSmartTimer:Kill(seatHolder.timeChatEmojiEventId)
        seatHolder.timeChatEmojiEventId = nil
    end
    local timeChatEmojiEvent = self:subscibe_time_event(3, false, 0):OnComplete(function(t)
        if(curEmoji ~= nil)then
            ModuleCache.ComponentUtil.SafeSetActive(curEmoji, false)
        end        
    end)
end

------刷新座位信息
function TableRunfastView:refreshSeatInfo(seatData)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableRunfastHelper:refreshSeatInfo(seatHolder, seatData)
end

------刷新座位玩家状态
function TableRunfastView:refreshSeatState(seatData)
    TableRunfastHelper:refreshSeatState(self.seatHolderArray[seatData.localSeatIndex], seatData)
end

------刷新在线状态
function TableRunfastView:refreshSeatOfflineState(seatInfo)
    if(self:IsAnticheatWaitReady() and self.modelData.curTableData.roomInfo.maxPlayerCount <= 3) then
        return
    end
    TableRunfastHelper:refreshSeatOfflineState(self.seatHolderArray[seatInfo.localSeatIndex], seatInfo)
end

function TableRunfastView:showSeatRoundScoreAnim(seatData, show, score)
    local seatHolder = self.seatHolderArray[seatData.localSeatIndex]
    TableRunfastHelper:showRoundScoreEffect(seatHolder, seatData.localSeatIndex , show, score)
end


function TableRunfastView:SetDoingState(show,delayTime)
    if(delayTime ~= nil and delayTime > 0) then
        self:subscibe_time_event(delayTime, false, 0):OnComplete(function(t)
             ModuleCache.ComponentUtil.SafeSetActive(self.DoingRoot, show)
        end)
    else
         ModuleCache.ComponentUtil.SafeSetActive(self.DoingRoot, show)
    end
end

------实例化扑克牌的槽
function TableRunfastView:InstantiatePokerSlot()
    ModuleCache.ComponentUtil.SafeSetActive(self.PokerPrefab, false)
    local pokerSlotMaxCount = TableRunfastHelper.pokerSlotMaxCount
    for i=1,pokerSlotMaxCount do
        local tPoker =ModuleCache.ComponentUtil.InstantiateLocal(self.PokerPrefab, self.PokerPrefabParent)
        tPoker.name = "Poker"..tostring(i)
        ModuleCache.ComponentUtil.SafeSetActive(tPoker, false)
    end
end

------刷新手中剩余的牌数
function TableRunfastView:RefreshRemainPokerInHand()
    local myseatHolder = self.seatHolderArray[1]
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
        if(myseatHolder == seatHolder) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerRoot, false)
            self:WarningSingle(seatInfo)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerRoot, true)
	        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerInHand.gameObject, true and seatInfo.rest_card_cnt > 0)
            seatHolder.RemainPokerInHand.text = tostring(seatInfo.rest_card_cnt)
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.Warning.gameObject, seatInfo.is_single)
            self:WarningSingle(seatInfo)
            if(seatInfo.is_single) then
                ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerInHand.gameObject, true)
                seatHolder.RemainPokerInHand.text = tostring(1)
            end
        end
    end
end

function TableRunfastView:WarningSingle(seatInfo)
    if(seatInfo.is_single) then
        --print("==seatInfo.is_single="..tostring(seatInfo.is_single))
        if(seatInfo.is_single_soundplayed == false) then
            --print("==报单id="..tostring(seatInfo.playerId))
            self:SoundOnlyOne(seatInfo.playerInfo ~= nil and seatInfo.playerInfo.gender == 1)
            seatInfo.is_single_soundplayed = true
        end
    end
end

------设置手中剩余的牌数
function TableRunfastView:SetRemainPokerInHand(seatInfo)
    local myseatHolder = self.seatHolderArray[1]
	local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
    if(myseatHolder == seatHolder) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerRoot, false)
        self:WarningSingle(seatInfo)
    else
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerRoot, true)
	    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.RemainPokerInHand.gameObject, false)
        local intCount = tonumber(seatInfo.rest_card_cnt)
	    seatHolder.RemainPokerInHand.text = tostring(intCount)
        --print("====intCount="..tostring(intCount))
        local boolShowWarning = seatInfo.is_single
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.Warning.gameObject, boolShowWarning)
        self:WarningSingle(seatInfo)
    end
end


function TableRunfastView:SoundOnlyOne(boolMale)
	local resultvoiceName = ""
	local genderName = "male_"
	if(not boolMale) then
		genderName = "female_"
	end
	resultvoiceName = genderName.."shengyu1"
    self:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
        ModuleCache.SoundManager.play_sound(BranchPackageName, BranchPackageName.."/sound/table/" .. resultvoiceName .. ".bytes", resultvoiceName)
    end)
end


------隐藏OK图标
function TableRunfastView:HideOkIcon()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        local seatHolder= self.seatHolderArray[seatInfo.localSeatIndex]
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageReady.gameObject,false)
    end    
end

------隐藏别人收上的背景牌
function TableRunfastView:HideOthersBackPoker()
	local localMyId = tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList  do
		local seatInfo = seatInfoList[i]
		local seatInfoPlayerId = tonumber(seatInfo.playerId)
		if(seatInfoPlayerId == localMyId) then
		else
			local seatHolder = self.seatHolderArray[seatInfo.localSeatIndex]
			ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerRoot,false)
		end
	end
end

function TableRunfastView:SetNotAllowActionMaskState(boolActive,delayTime)
    if(delayTime ~= nil and delayTime > 0) then
        self:subscibe_time_event(delayTime, false, 0):OnComplete(function(t)
            ModuleCache.ComponentUtil.SafeSetActive(self.NotAllowActionMask, boolActive)
        end)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.NotAllowActionMask, boolActive)
    end
end

function TableRunfastView:SetNotAllowActionMaskLastPokerAutoState(boolActive,delayTime)
    if(delayTime ~= nil and delayTime > 0) then
        self:subscibe_time_event(delayTime, false, 0):OnComplete(function(t)
            ModuleCache.ComponentUtil.SafeSetActive(self.NotAllowActionMaskLastPokerAuto, boolActive)
        end)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.NotAllowActionMaskLastPokerAuto, boolActive)
    end
end

--根据规则布局UI
function TableRunfastView:CheckLayoutUI(ruleTable)    
    if(self.isPlayBacking) then --回放的位置调整
        if(ruleTable.playerCount == 4) then--四人玩法位置调整
            for i=1,#self.seatHolderArray do
                local seatHolder = self.seatHolderArray[i]
                if(seatHolder ~= nil) then
                    local locV3 = seatHolder.seatPosTran.localPosition
                    if(i == 2 or i == 4) then --四人玩法代码里面有调整顺序,所以是2和4,不是2和3.在UI中实际改的值是2,3的位置
                        locV3.y = 90
                        seatHolder.seatPosTran.localPosition = locV3
                    elseif(i == 3) then ----四人玩法代码里面有调整顺序,所以在UI中实际改的值是4的位置
                        locV3.x = -280
                        seatHolder.seatPosTran.localPosition = locV3
                        local v3_ThrowPoker = seatHolder.ThrowPokerGridLayoutGroup.transform.localPosition
                        v3_ThrowPoker.x = 280
                        seatHolder.ThrowPokerGridLayoutGroup.transform.localPosition = v3_ThrowPoker
                    -- elseif(i == 1) then
                    --     locV3.x = -440
                    --     locV3.y = -282
                    --     seatHolder.seatPosTran.localPosition = locV3
                    end
                end
            end
        end
        return
    end
    
    --允许过牌的UI:可过牌有不要按钮,必压没有不要的按钮
    if(ruleTable.allow_pass) then
        ModuleCache.ComponentUtil.SafeSetActive(self.BtnNotAffordRoot.gameObject,true)
        self.BtnHint.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
        self.BtnThrowCard.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(285, 0, 0)
        self.BtnThrowCardDray.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(285, 0, 0)
    else
        ModuleCache.ComponentUtil.SafeSetActive(self.BtnNotAffordRoot.gameObject,false)
        self.BtnHint.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(-160, 0, 0)
        self.BtnThrowCard.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(160, 0, 0)
        self.BtnThrowCardDray.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(160, 0, 0)
    end

    --四人玩法位置调整
    if(ruleTable.playerCount == 4) then
        for i=1,#self.seatHolderArray do
            local seatHolder = self.seatHolderArray[i]
            if(seatHolder ~= nil) then
                if(i == 2 or i == 4) then --四人玩法代码里面有调整顺序,所以是2和4,不是2和3
                    local locV3 = seatHolder.seatPosTran.localPosition
                    locV3.y = 40
                    seatHolder.seatPosTran.localPosition = locV3
                end
            end
        end
    end
    self:CheckJinBiChangUI()
    self:CheckAnticheatUI()
end

------初始化回放
function TableRunfastView:InitiPB()
    self.isPlayBacking = false
    self.PB_UIRoot =  GetComponentWithPath(self.root, "PlayBackUIRoot", ComponentTypeName.Transform).gameObject
    self.PB_ReplayBtn = GetComponentWithPath(self.root, "PlayBackUIRoot/Action/Top/PB_ReplayBtn", ComponentTypeName.Button)
    self.PB_StopBtn = GetComponentWithPath(self.root, "PlayBackUIRoot/Action/Top/PB_StopBtn", ComponentTypeName.Button)
    self.PB_BackBtn = GetComponentWithPath(self.root, "PlayBackUIRoot/Action/Bottom/PB_BackBtn", ComponentTypeName.Button)
    self.PB_PauseBtn = GetComponentWithPath(self.root, "PlayBackUIRoot/Action/Bottom/PB_PauseBtn", ComponentTypeName.Button)
    self.PB_PlayBtn = GetComponentWithPath(self.root, "PlayBackUIRoot/Action/Bottom/PB_PlayBtn", ComponentTypeName.Button)
    ModuleCache.ComponentUtil.SafeSetActive(self.PB_PlayBtn.gameObject,false)
    self.PB_ForwardBtn = GetComponentWithPath(self.root, "PlayBackUIRoot/Action/Bottom/PB_ForwardBtn", ComponentTypeName.Button)
    
    if(self.curTableData_PB ~= nil and self.curTableData_PB.isPlayBack) then
        self:PBUI()
    end
end

------回放隐藏的UI
function TableRunfastView:PBUI()
    --状态标识
    self.isPlayBacking = true
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonMic.gameObject,not self.isPlayBacking)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChat.gameObject,not self.isPlayBacking)
    ModuleCache.ComponentUtil.SafeSetActive(self.ButtonRoomRule.gameObject,not self.isPlayBacking)
    ModuleCache.ComponentUtil.SafeSetActive(self.TopRight,not self.isPlayBacking)
    ModuleCache.ComponentUtil.SafeSetActive(self.PB_UIRoot,self.isPlayBacking)
    if ModuleCache.GameManager.iosAppStoreIsCheck then
        self.buttonMic.gameObject:SetActive(false)
    end
end

function TableRunfastView:PBUI2()
    if(not self.isPlayBacking) then
        return 
    end

    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatInfo = seatInfoList[i]
        print_table(seatInfo)
        local localSeatIndex = seatInfo.localSeatIndex
        local seatHolder= self.seatHolderArray[localSeatIndex]
        if(localSeatIndex == 1) then
            self.PokerPrefabParent.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(0.75, 0.75, 1)
            self.PokerPrefabParent.transform.localPosition = ModuleCache.CustomerUtil.ConvertVector3(0, -290, 0)
            self.FirstThrowPokerGridLayoutGroupRoot.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(0.6, 0.6, 1)
        else
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.handPokerRoot,true)
            seatHolder.ThrowPokerGridLayoutGroup.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(0.6, 0.6, 1)
        end
    end
end


function TableRunfastView:show_ping_delay(show, delaytime)
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

function TableRunfastView:get_room_award_table(roomAward)
    local myID = self.modelData.curTableData.roomInfo.mySeatInfo.playerId;
    local isMyself = false;
    if myID == roomAward.UserID then
        isMyself=true;
    end

    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatInfoList do
        if(seatInfoList[i].playerId == roomAward.UserID) then
            return {
                position =self.seatHolderArray[i].seatPosTran.position,
                awardMsg = roomAward.Message,
                isMe = isMyself,
                canRob=roomAward.canRob,
                sign=roomAward.sign,
            }
        end
    end
    return nil
end


function TableRunfastView:SetEffectXuanZhuanHeiTao3RootState(isShow)
    ModuleCache.ComponentUtil.SafeSetActive(self.EffectXuanZhuanHeiTao3Root.gameObject, isShow)
end

function TableRunfastView:PlayHeiTao3Anim(toPos)
    self:SetEffectXuanZhuanHeiTao3RootState(true)
    self:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
        local dstScale = Vector3.New(0.22, 0.27, 1)
        local duration = 0.5
        local sequence = self:create_sequence()
        sequence:Join(self.EffectXuanZhuan_PaiMian.transform:DOMove(toPos, duration, false))
        sequence:Join(self.EffectXuanZhuan_PaiMian.transform:DOScale(dstScale, duration))
        sequence:OnComplete(function ()
            self.EffectXuanZhuan_PaiMian.transform.localPosition = Vector3.zero
            self.EffectXuanZhuan_PaiMian.transform.localScale = Vector3.one
            self:SetEffectXuanZhuanHeiTao3RootState(false)
            if(onFinish)then
                onFinish()
            end
        end)
    end)
end



function TableRunfastView:GetSeatHolderBySeatInfo(seatInfo)
    --print("--通过seatInfo获取seatHolder")
    if(seatInfo == nil) then
        return nil
    end
    return self.seatHolderArray[seatInfo.localSeatIndex]
end



function TableRunfastView:isJinBiChang()
    --print("--是否是金币场")
    return self.modelData.tableCommonData.isGoldTable
end

function TableRunfastView:isGoldUnlimited()
    --print("--是否是金币场无限局")
    return self.modelData.tableCommonData.isGoldUnlimited
end

function TableRunfastView:isGoldSettle()
    --print("--是否金币结算:包括普通创建房间时用消耗的是金币")
    return self.modelData.tableCommonData.isGoldSettle
end

function TableRunfastView:RefreshAllSeatInfoCurrency()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        self:RefreshSeatInfoCurrency(seatInfoList[i])
    end
end

function TableRunfastView:RefreshSeatInfoCurrency(seatInfo)
    --print("--刷新玩家的货币数量")
    if(seatInfo) then
        local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
        if(seatHolder) then
            if(self:isGoldSettle()) then
                seatHolder.GoldCount.text = Util.filterPlayerGoldNum(seatInfo.coinBalance)
            else
                seatHolder.textScore.text = tostring(seatInfo.score)
            end
        end
    end
end

--获取当前的底注
function TableRunfastView:GetCurBaseCoinScore()
    return self.modelData.curTableData.roomInfo.baseCoinScore
end

function TableRunfastView:CheckJinBiChangUI()
    local roomInfo = self.modelData.curTableData.roomInfo
    local TopRootType = "Normal"
    if(self:isJinBiChang()) then
        self:SetState_RecordPokerRoot(true)
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonShop.gameObject,true)
        if(self:IsAnticheat()) then
            TopRootType = "HideRoomId"
        end
    else
        self:SetState_RecordPokerRoot(false)
        ModuleCache.ComponentUtil.SafeSetActive(self.ButtonShop.gameObject,false)
    end
    self.TopRootUIStateSwitcher:SwitchState(TopRootType)

    local CurrencyUIStateSwitcherType = "Point"
    if(self:isGoldSettle()) then
        CurrencyUIStateSwitcherType = "Gold"
    end
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i=1,#seatInfoList do
        local seatHolder = self:GetSeatHolderBySeatInfo(seatInfoList[i])
        seatHolder.CurrencyUIStateSwitcher:SwitchState(CurrencyUIStateSwitcherType)
    end
end

function TableRunfastView:SetState_LeftRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.LeftRoot.gameObject, show)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnLeftOpen.gameObject,not show)
end


function TableRunfastView:SetState_RecordPokerRoot(isShow)
    ModuleCache.ComponentUtil.SafeSetActive(self.RecordPokerRoot.gameObject, isShow)
end

function TableRunfastView:SetState_RecordPokerShowRoot(isShow)
    ModuleCache.ComponentUtil.SafeSetActive(self.RecordPokerShowRoot.gameObject, isShow)
end

function TableRunfastView:SetState_RecordPokerTimeRoot(isShow)
    ModuleCache.ComponentUtil.SafeSetActive(self.RecordPokerTimeRoot.gameObject, isShow)
end

function TableRunfastView:SetRecordPokerCountSlotArrayData(itemList)
    if(itemList == nil or #itemList ~= 13) then
        print("error===itemList == nil or #itemList ~= 13")
        return
    end

    for i=1,#itemList do
        local locData = itemList[i]
        local locCount = locData.remainCount
        if(locCount == nil or locCount < 0) then
            print("error===数据错误")
        else
            local RecordPokerCountText = self.RecordPokerCountSlotArray[locData.cardName]
            RecordPokerCountText.text = locData.remainCount
        end
    end
    self:SetState_RecordPokerShowRoot(true)
end

function TableRunfastView:SetState_LeftRoot(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.LeftRoot.gameObject, show)
    ModuleCache.ComponentUtil.SafeSetActive(self.BtnLeftOpen.gameObject,not show)
end


function TableRunfastView:SetTipsServiceFee(FeeNum)
    print("====显示服务费")
    ModuleCache.ComponentUtil.SafeSetActive(self.TipsServiceFeeRoot.gameObject, true)
    self.TipsServiceFeeText.text = "本局游戏服务费为:".. tostring((FeeNum or self.modelData.curTableData.roomInfo.feeNum))
    self:subscibe_time_event(2, false, 1):OnComplete( function(t)
        ModuleCache.ComponentUtil.SafeSetActive(self.TipsServiceFeeRoot.gameObject, false)
    end)
end

function TableRunfastView:SetCancelIntrustState(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.CancelIntrustRoot.gameObject, show)
end

function TableRunfastView:ResetReplaceTableWaitId(isHide)
    if self.ReplaceTableWaitId then
        CSmartTimer:Kill(self.ReplaceTableWaitId)
        self.ReplaceTableWaitId = nil
    end

    if(isHide) then
        self.JinBiChangStateSwitcher:SwitchState("Disable")
    end
end

function TableRunfastView:SetJinBiChangStateSwitcher(type)
    if(type == false) then
        type = "Disable"
    else
        if(self:isJinBiChang()) then
            type = "Center"
            if(self:isGoldUnlimited()) then
                type = "CenterOnlyReady"
            end
            if(TableManager.LastChangeTableTime) then
                if(Time.realtimeSinceStartup < TableManager.LastChangeTableTime + 5 ) then
                    type = "ReplaceTableWait"
                    self:ResetReplaceTableWaitId()
                    self.ReplaceTableWaitId = self:subscibe_time_event(5, false, 1):OnUpdate( function(t)
                        t = t.surplusTimeRound
                        self.ButtonReplaceTableText.text = t .. "s"
                    end):OnComplete( function(t)
                        if(self.modelData.curTableData.roomInfo.mySeatInfo.isReady) then
                            self.JinBiChangStateSwitcher:SwitchState("Disable")
                        else
                            self.JinBiChangStateSwitcher:SwitchState("Center")
                        end
                    end).id
                end
            end
        else
            type = "Disable"
        end
    end
    self.JinBiChangStateSwitcher:SwitchState(type)
end

--1:进入房间准备阶段   2:游戏进行阶段   3:游戏结算阶段
function TableRunfastView:IsEnterRoomWaitReady()
    return self.modelData.curTableData.roomInfo.gamePhaseState == 1
end

function TableRunfastView:IsGameDoing()
    return self.modelData.curTableData.roomInfo.gamePhaseState == 2
end

function TableRunfastView:IsAccountWaitReady()
    return self.modelData.curTableData.roomInfo.gamePhaseState == 3
end

--防作弊准备阶段
function TableRunfastView:IsAnticheatWaitReady()
    return self:IsAnticheat() and (self:IsEnterRoomWaitReady() or self:IsAccountWaitReady())
end

--是否防作弊
function TableRunfastView:IsAnticheat()
    if(self:isJinBiChang()) then
        local RuleTable = self.modelData.curTableData.roomInfo.createRoomRule
        if(RuleTable) then
            return RuleTable.anticheat
        end
    end
    return nil
end

function TableRunfastView:CheckAnticheatUI()
    local IsAnticheatWaitReady = self:IsAnticheatWaitReady()
    ModuleCache.ComponentUtil.SafeSetActive(self.AnticheatMatchingRoot.gameObject,IsAnticheatWaitReady)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChat.gameObject,not IsAnticheatWaitReady)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonMic.gameObject,not IsAnticheatWaitReady)
    if ModuleCache.GameManager.iosAppStoreIsCheck then
        self.buttonMic.gameObject:SetActive(false)
    end

    self:CheckAnticheatSwitcherState()
end

function TableRunfastView:CheckAnticheatSwitcherState()
    if ModuleCache.GameManager.iosAppStoreIsCheck then
        return
    end

    if(self:IsAnticheat()) then
        local roomInfo = self.modelData.curTableData.roomInfo
        local count = roomInfo.maxPlayerCount
        local playerCountLimit = 3
        if(count <= playerCountLimit) then
            local seatInfoList = roomInfo.seatInfoList
            local type = "Normal"
            local IsAnticheatWaitReady = self:IsAnticheatWaitReady()
            if(IsAnticheatWaitReady) then
                type = "Anticheat"
                ModuleCache.ComponentUtil.SafeSetActive(self.BtnLocation.gameObject,false)
            else
                if(#seatInfoList >= playerCountLimit) then
                    ModuleCache.ComponentUtil.SafeSetActive(self.BtnLocation.gameObject,true)
                end
            end


            for i = 1, #seatInfoList do
                local seatInfo = seatInfoList[i]
                if(seatInfo and seatInfo~= roomInfo.mySeatInfo) then
                    local seatHolder = self:GetSeatHolderBySeatInfo(seatInfo)
                    if(seatHolder) then
                        seatHolder.AvatarUIStateSwitcher:SwitchState(type)
                    end
                end
            end

            local seatHolderArray = self.seatHolderArray
            for i = 1, #seatHolderArray do
                if(i <= count) then
                    local seatHolder = seatHolderArray[i]
                    if(seatHolder) then
                        seatHolder.NotSeatRootUIStateSwitcher:SwitchState(type)
                    end
                end
            end
            --print("===============roomInfo.gamePhaseState",self.modelData.curTableData.roomInfo.gamePhaseState,type)
        end
    end
end

function TableRunfastView:SetState_BtnActivity(isShow)
    if ModuleCache.GameManager.iosAppStoreIsCheck then
        isShow = false
    end
    ModuleCache.ComponentUtil.SafeSetActive(self.goActivity, isShow)
end

function TableRunfastView:CheckStyleType(StyleType)
    local PokerStyleTypeKey = TableRunfastHelper.PokerStyleTypeKey
    if(not StyleType) then
        StyleType = PlayerPrefs.GetInt(PokerStyleTypeKey)
    end

    if(StyleType == 1) then
        self.cardAssetHolder = self.CardAssetHolder1
    elseif(StyleType == 2) then
        self.cardAssetHolder = self.CardAssetHolder2
    elseif(StyleType == 0) then
        self.cardAssetHolder = self.CardAssetHolder1
        PlayerPrefs.SetInt(PokerStyleTypeKey,1)
    end
end


return  TableRunfastView