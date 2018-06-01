--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;
local Instantiate = ModuleCache.ComponentUtil.InstantiateLocal;
local class = require("lib.middleclass")
local View = require('package.public.module.table_poker.base_table_view')
local baseView = require('core.mvvm.view_base')
local LaoYanCaiTableView = class('LaoYanCaiTableView', View)

local cardCommon = require('package.laoyancai.module.table_laoyancai.gamelogic_common')

--local tableSound = require('package.LaoYanCai.module.LaoYanCai_table.table_sound')

local GameSDKInterface = ModuleCache.GameSDKInterface

local offsetY = 50

function LaoYanCaiTableView:initialize(...)
    baseView.initialize(self, "laoyancai/module/table/table_laoyancai.prefab", "Table_LaoYanCai", 0)
--由于更改了预制体，所以直接将基类种的initialize放入
    self.GetComponentWithPath = GetComponentWithPath
    self.ComponentTypeName = ComponentTypeName
    self.CSmartTimer = CSmartTimer
    
    self.buttonStart = GetComponentWithPath(self.root, "Bottom/Action/ButtonStart", ComponentTypeName.Button) 
    self.buttonReady = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady", ComponentTypeName.Button) 
    self.buttonInvite = GetComponentWithPath(self.root, "Bottom/Action/ButtonInviteFriend", ComponentTypeName.Button) 
    self.buttonLeave = GetComponentWithPath(self.root, "Bottom/Action/ButtonLeave", ComponentTypeName.Button) 
    self.buttonSetting = GetComponentWithPath(self.root, "PublicButtons/ButtonSettings", ComponentTypeName.Button)
    self.buttonMic = GetComponentWithPath(self.root, "PublicButtons/ButtonMic", ComponentTypeName.Button)    
    self.buttonChat = GetComponentWithPath(self.root, "PublicButtons/ButtonChat", ComponentTypeName.Button)
    self.buttonActivity = GetComponentWithPath(self.root, "PublicButtons/ButtonActivity", ComponentTypeName.Button)
    self.spriteActivityRedPoint = GetComponentWithPath(self.root, "PublicButtons/ButtonActivity/RedPoint", ComponentTypeName.Image)

    self:showActivityBtn(false)
    self.buttonLocation = GetComponentWithPath(self.root, "PublicButtons/ButtonLocation", ComponentTypeName.Button)
    self.goSpeaking = GetComponentWithPath(self.root, "Speaking", ComponentTypeName.Transform).gameObject
    self.goCancelSpeaking = GetComponentWithPath(self.root, "CancelRecord", ComponentTypeName.Transform).gameObject
    

    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomID/Text", ComponentTypeName.Text)
    print(self.textRoomNum)
    self.textRoundNum = GetComponentWithPath(self.root, "Top/TopInfo/RoundNum/Text", ComponentTypeName.Text)
    self.textRoomRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Text", ComponentTypeName.Text)
    self:initAllSeatHolders()



    self.buttonGetMorePoker = GetComponentWithPath(self.root,"Buttons/ButtonGet",ComponentTypeName.Button);
    self.buttonNotGetPoker = GetComponentWithPath(self.root,"Buttons/ButtonNotGet",ComponentTypeName.Button);
    self.buttonExplode = GetComponentWithPath(self.root,"Buttons/ButtonExplode",ComponentTypeName.Button);
    self.buttonGetMorePokerGray = GetComponentWithPath(self.root,"Buttons/ButtonGetGray",ComponentTypeName.Transform);
    self.buttonNotGetPokerGray = GetComponentWithPath(self.root,"Buttons/ButtonNotGetGray",ComponentTypeName.Transform);
    self.buttonExplodeGray = GetComponentWithPath(self.root,"Buttons/ButtonExplodeGray",ComponentTypeName.Transform);
    self.buttonJoinBankerQueue = GetComponentWithPath(self.root,"Buttons/ButtonKnockBanker",ComponentTypeName.Button).gameObject;
    self.buttonExitBankerQueue = GetComponentWithPath(self.root,"Buttons/ButtonCancelBanker",ComponentTypeName.Button).gameObject;
    self.explodeAnim = GetComponentWithPath(self.root,"Anims/Anim_LYC_ZhaKai",ComponentTypeName.Transform).gameObject;
    self.pokerSpriteHolder = GetComponentWithPath(self.root,"Holder/CardAssetHolder","SpriteHolder");
    self.tipText = GetComponentWithPath(self.root,"Center/Tips/Text",ComponentTypeName.Text);
    self.tip = GetComponentWithPath(self.root,"Center/Tips",ComponentTypeName.Transform).gameObject;
    self.tipText2 = GetComponentWithPath(self.root,"Center/Tips2/Text",ComponentTypeName.Text);
    self.tip2 = GetComponentWithPath(self.root,"Center/Tips2",ComponentTypeName.Transform).gameObject;
    self.tipText3 = GetComponentWithPath(self.root,"Center/Tips3/Text",ComponentTypeName.Text);
    self.tip3 = GetComponentWithPath(self.root,"Center/Tips3",ComponentTypeName.Transform).gameObject;
    self.tipText4 = GetComponentWithPath(self.root,"Center/Tips4/Text",ComponentTypeName.Text);
    self.tip4 = GetComponentWithPath(self.root,"Center/Tips4",ComponentTypeName.Transform).gameObject;
    self.textRoomNum = GetComponentWithPath(self.root,"Top/TopInfo/RoomInfo/RoomID/Text",ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root,"Top/TopInfo/RoomInfo/RoundNum/Text",ComponentTypeName.Text)
    self.actionStateSwitcher = GetComponentWithPath(self.root,"Bottom/Action","UIStateSwitcher")
    self.buttonRob = GetComponentWithPath(self.root,"Buttons/ButtonRob",ComponentTypeName.Button)
    self.buttonNotRob = GetComponentWithPath(self.root,"Buttons/ButtonNotRob",ComponentTypeName.Button)
    self.buttonBet1 = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBet1",ComponentTypeName.Button);
    self.buttonBet2 = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBet2",ComponentTypeName.Button);
    self.buttonBet3 = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBet3",ComponentTypeName.Button);
    self.buttonBet4 = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBet4",ComponentTypeName.Button);
    self.buttonBetMaBao = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBetMaBao",ComponentTypeName.Button);
    self.betPanel = GetComponentWithPath(self.root,"Buttons/Bet",ComponentTypeName.Transform).gameObject;
    self.restPokerNum = GetComponentWithPath(self.root,"Center/RestPokerNum",ComponentTypeName.Transform).gameObject;
    self.textRestPokerNum = GetComponentWithPath(self.root,"Center/RestPokerNum/Image/Text",ComponentTypeName.Text);
    self.bankerQueue = GetComponentWithPath(self.root,"Center/BankerQueue",ComponentTypeName.Transform).gameObject;
    self.pokerHeap = GetComponentWithPath(self.root,"PokerHeap",ComponentTypeName.Transform);
    self.buttonRule = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/ButtonRule", ComponentTypeName.Button)
    self.ruleHint = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/ruleBtn", ComponentTypeName.Button)
    self.tableBackgroundImage = GetComponentWithPath(self.root, "Background/ImageBackground1", ComponentTypeName.Image)
    self.tableBackgroundImage2 = GetComponentWithPath(self.root, "Background/ImageBackground2", ComponentTypeName.Image)
    self.getThirdPokerAnim = GetComponentWithPath(self.root,"Seats/1/Panel/Panel/3/Anim_LYC_LaoPai",ComponentTypeName.Transform).gameObject;
    self.gameStartAnim = GetComponentWithPath(self.root,"Anims/Anim_Pbulic_GameStart",ComponentTypeName.Transform).gameObject;
    self.coins = {}
    for i = 1,7 do
        local coin = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/coin/Image",ComponentTypeName.Transform).gameObject;
        table.insert(self.coins, coin)
    end
    self.sliderBattery = GetComponentWithPath(self.root, "Top/BatteryTime/Battery", ComponentTypeName.Slider)
    self.imageBatteryCharging = GetComponentWithPath(self.root, "Top/BatteryTime/Battery/ImageCharging", ComponentTypeName.Image)
    self.textTime = GetComponentWithPath(self.root, "Top/BatteryTime/Time/Text", ComponentTypeName.Text)
    self.goWifiStateArray = {}    
    for i=1,5 do
        local goState = GetComponentWithPath(self.root, "Top/BatteryTime/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end
    
    self.goGState2G = GetComponentWithPath(self.root, "Top/BatteryTime/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "Top/BatteryTime/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "Top/BatteryTime/GState/4g", ComponentTypeName.Transform).gameObject
    
    self.textPingValue = GetComponentWithPath(self.root, "Top/BatteryTime/PingVal", ComponentTypeName.Text)
end

function LaoYanCaiTableView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    local imageTimeLimit = GetComponentWithPath(seatRoot, "Info/ImageBackground/Frame", ComponentTypeName.Image)    
    local buttonKick = GetComponentWithPath(seatRoot, "Info/ButtonKick", ComponentTypeName.Button)  
    seatHolder.imageTimeLimit = imageTimeLimit;
    seatHolder.buttonKick = buttonKick;
    if index == 1 then
       seatHolder.uiStateSwitcher:SwitchState("Bottom")
        local animSelectBankerHorizontal = GetComponentWithPath(seatRoot, "Info/EffectHorizontal", ComponentTypeName.Image)           
        seatHolder.animSelectBanker = animSelectBankerHorizontal
    elseif index == 2 or index == 3 then
       seatHolder.uiStateSwitcher:SwitchState("Left")
    elseif index == 5 or index == 6 then
       seatHolder.uiStateSwitcher:SwitchState("Left")
    elseif index == 4 or index == 7 then        
       seatHolder.uiStateSwitcher:SwitchState("Right")
       seatHolder.isInRight = true
    end
end

function LaoYanCaiTableView:SetKickButtonActive(index,isActive)
    local seatHolder = self.srcSeatHolderArray[index]
    seatHolder.buttonKick.gameObject:SetActive(isActive);
end

function LaoYanCaiTableView:initAllSeatHolders()
    View.initAllSeatHolders(self)
    for localSeatIndex = 1,#self.srcSeatHolderArray do
        local cardHolderList = {}
        local seatHolder = self.srcSeatHolderArray[localSeatIndex]
        for i = 1,2 do
            local poker = GetComponentWithPath(self.root,"Seats/"..localSeatIndex.."/Panel/Panel/"..i,ComponentTypeName.Transform).gameObject;
            local cardHolder = {};
            cardHolder.cardRoot = poker;
            cardHolder.cardLocalPosition = poker.transform.localPosition;
            cardHolder.cardLocalScale = poker.transform.localScale;
            --print('---------', poker.transform.position.x, poker.transform.position.y, poker.transform.position.z)
            cardHolder.cardPosition = poker.transform.position
            table.insert( cardHolderList,cardHolder)
            --cardHolder.cardHolderList = cardHolderList;
        end
        seatHolder.cardHolderList = cardHolderList
    end
end

function LaoYanCaiTableView:showActivityBtn(show)
    show = show or false
    if(self.buttonActivity)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonActivity.gameObject, show)
    end
end

function LaoYanCaiTableView:ShowPlayerPokers(index,pokerIndex,poker,text)
    self:playCardTurnAnim(index,pokerIndex,poker,1,0);
end

function LaoYanCaiTableView:setRoomInfo(roomInfo)
    print_table(roomInfo)
    self.textRoomNum.text = "房号:" .. roomInfo.roomNum
    self.textRoomRule.text = roomInfo.ruleDesc
    if(roomInfo.ruleTable.playType == 0) then
        self.textRoundNum.text = "经典玩法 "
    elseif(roomInfo.ruleTable.playType == 1) then
        self.textRoundNum.text = "码宝连庄 "
    end
    self.textRoundNum.text = self.textRoundNum.text.."第" .. roomInfo.curRoundNum .. "/" .. roomInfo.totalRoundCount .. "局"
    self.textRoundNum.gameObject:SetActive(true)
end

function LaoYanCaiTableView:playCardTurnAnim(index,pokerIndex,poker, duration, delayTime)
    local imagePanel = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Panel",ComponentTypeName.Transform).gameObject
    imagePanel.gameObject:SetActive(true)
    local pokerImage = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Panel/"..pokerIndex,ComponentTypeName.Image)
    pokerImage.gameObject:SetActive(true);
    local imageName = self:getImageNameFromCode(poker)
    local sprite = self.pokerSpriteHolder:FindSpriteByName(imageName);
    local sequence = self:create_sequence()
    local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
    local paiBeiSprite = self.pokerSpriteHolder:FindSpriteByName("paibei")
    pokerImage.sprite = paiBeiSprite
    local sequence = self:create_sequence();
    sequence:Append(pokerImage.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime + duration * 0.2):OnComplete(function()
        pokerImage.sprite = sprite
    end))
    sequence:Append(pokerImage.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):OnComplete(function()
    end))
end

function LaoYanCaiTableView:HideChips()
    self.betPanel:SetActive(false)
end

function LaoYanCaiTableView:ShowBetScore(index,score)
    local scorePanel = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/coin",ComponentTypeName.Transform)
    local scoreText = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/coin/Text",ComponentTypeName.Text)
    scorePanel.gameObject:SetActive(true);
    scoreText.text = score;
end

function LaoYanCaiTableView:SetBankerQueueButtonActive(isActive)
    self.buttonJoinBankerQueue:SetActive(isActive);
    self.buttonExitBankerQueue:SetActive(not isActive);
end

function LaoYanCaiTableView:ShowOperationButton(state,time)
    if(state == 0) then
        local text = "等待庄家操作 "
        self:ShowOperationTip(text,time)
        self:SetOperationButtonActive(1,false)
        self:SetOperationButtonActive(2,false)
        self:SetOperationButtonActive(3,false)
    elseif(state == 1) then
        local text = "等待闲家操作 "
        self:ShowOperationTip(text,time)
        self:SetOperationButtonActive(1,false)
        self:SetOperationButtonActive(2,false)
        self:SetOperationButtonActive(3,false)
    elseif(state == 2) then
        self:HideTip()
        self:SetOperationButtonActive(1,true)
        self:SetOperationButtonActive(2,false)
        self:SetOperationButtonActive(3,false)
    elseif(state == 3) then
        self:HideTip()
        self:SetOperationButtonActive(1,false)
        self:SetOperationButtonActive(2,true)
        self:SetOperationButtonActive(3,true)
    end
end

function LaoYanCaiTableView:ShowWaitOthersTip()
    local text = "等待其他闲家操作 "
    local time = 10;
    self:ShowOperationTip(text,time)
end

function LaoYanCaiTableView:ShowOperationTip(text,time)
    self:HideTip();
    self.tip3:SetActive(true)
    if(self.tip3TimeEvent) then
        CSmartTimer:Kill(self.tip3TimeEvent)
        self.tip3TimeEvent = nil
    end
    self:HideTip();
    local timeEvent = self:subscibe_time_event(time,false,0):OnComplete(function()
        self.tip3TimeEvent = nil
    end):SetIntervalTime(1, function(t)
        time = time - 1;
        self.tipText3.text = text..time.."s";
        self.tip3:SetActive(true)
    end)
    self.tip3TimeEvent = timeEvent.id;
end

function LaoYanCaiTableView:SetOperationButtonActive(index,isActive)
    if(index == 1) then
        self.buttonExplode.gameObject:SetActive(isActive)
        self.buttonExplodeGray.gameObject:SetActive(not isActive)
    elseif(index == 2) then
        self.buttonGetMorePoker.gameObject:SetActive(isActive)
        self.buttonGetMorePokerGray.gameObject:SetActive(not isActive)
    elseif(index == 3) then
        self.buttonNotGetPoker.gameObject:SetActive(isActive)
        self.buttonNotGetPokerGray.gameObject:SetActive(not isActive)
    end
end

function LaoYanCaiTableView:PlayCompareSound(point,pokerType,seatInfo)
    local voice1Name = ""
    local delay = 0;
    if(pokerType == 1) then
        voice1Name = "shuangyan";
        delay = 1;
    elseif(pokerType == 2) then
        voice1Name = "sanyan";
        delay = 1;
    end
    if(seatInfo.playerInfo and seatInfo.playerInfo.gender == 2) then
		path = "pt_man/" 
	else
		path = "pt_woman/"
	end
    if(voice1Name ~= "") then
        ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/" .. path .. voice1Name..".bytes", voice1Name)
    end
    local voice2Name = point.."dian";
    self:subscibe_time_event(delay, false, 0):OnComplete(function(t)
        ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/" .. path .. voice2Name..".bytes", voice2Name)
    end)
end

function LaoYanCaiTableView:PlayKnockBankerSound(isKnock,seatInfo)
    local voiceName = ""
    if(isKnock) then
        voiceName = "qiang"
    else
        voiceName = "buqiang"
    end
    if(seatInfo.playerInfo and seatInfo.playerInfo.gender == 2) then
		path = "pt_man/" 
	else
		path = "pt_woman/"
	end
    ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/" .. path .. voiceName..".bytes", voiceName)
end

function LaoYanCaiTableView:PlayStartSound()
    ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/audiostartgame.bytes", "audiostartgame")
end

function LaoYanCaiTableView:PlayOperationSound(index,seatInfo)
    local voiceName = ""
    if(index == 2) then
        voiceName = "zhakai"
    elseif(index == 3) then
        voiceName = "laopai"
    elseif(index == 4) then
        voiceName = "bulao"
    end
    if(seatInfo.playerInfo and seatInfo.playerInfo.gender == 2) then
		path = "pt_man/" 
	else
		path = "pt_woman/"
	end
    ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/" .. path .. voiceName..".bytes", voiceName)
end

function LaoYanCaiTableView:PlayGetPokerSound()
    self:subscibe_time_event(0, false, 0):OnComplete(function(t)
        ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/audiocheckcard.bytes", "audiocheckcard")
    end)
    self:subscibe_time_event(0.2, false, 0):OnComplete(function(t)
        ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/audiocheckcard.bytes", "audiocheckcard")
    end)
    --ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/AudioCheckCard.bytes", "AudioCheckCard")
end

function LaoYanCaiTableView:PlayCoinsFlySound()
    ModuleCache.SoundManager.play_sound("laoyancai", "laoyancai/sound/audiocoinsfly.bytes", "audiocoinsfly")
end

function LaoYanCaiTableView:PlayExplodeAnim()
    self.explodeAnim:SetActive(true);
end

function LaoYanCaiTableView:ShowPokersBack(index)
    local imageName = "paibei";
    local image1 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Panel/1",ComponentTypeName.Image)
    local image2 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Panel/2",ComponentTypeName.Image)
    image1.sprite = self.pokerSpriteHolder:FindSpriteByName(imageName);
    image2.sprite = self.pokerSpriteHolder:FindSpriteByName(imageName);
    local imagePanel = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Panel",ComponentTypeName.Transform).gameObject
    imagePanel.gameObject:SetActive(true)
end

function LaoYanCaiTableView:HideReadyWindow()
    self.actionStateSwitcher:SwitchState("None")
end

function LaoYanCaiTableView:ShowKnockBankerIcon(index)
    local knockIcon = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Banker",ComponentTypeName.Transform).gameObject;
    knockIcon:SetActive(true);
end

function LaoYanCaiTableView:HideAllKonckBankerIcons()
    for i = 1,7 do
        local knockIcon = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/Banker",ComponentTypeName.Transform).gameObject;
        knockIcon:SetActive(false);
    end
end

function LaoYanCaiTableView:ShowReadyButton(dalay)
    self:subscibe_time_event(dalay, false, 0):OnComplete(function(t)
        self.actionStateSwitcher:SwitchState("Ready")
    end)
end

function LaoYanCaiTableView:ShowThirdPoker(index,poker,text,isDelay)
    local thirdPoker = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Panel/3",ComponentTypeName.Image);
    local pokerName = self:getImageNameFromCode(poker)
    thirdPoker.sprite = self.pokerSpriteHolder:FindSpriteByName(pokerName);
    thirdPoker.gameObject:SetActive(true);
    local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    local eulerAngles = thirdPoker.transform.localEulerAngles;
    eulerAngles.y = 90;
    thirdPoker.transform.localEulerAngles = eulerAngles;
    local delay = 0;
    if(isDelay) then
        delay = 1;
    end
    self.getThirdPokerAnim:SetActive(true);
    self:subscibe_time_event(delay, false, 0):OnComplete(function(t)
        local sequence = self:create_sequence();
        sequence:Append(thirdPoker.transform:DOLocalRotate(originalRotate, 1 * 0.5, DG.Tweening.RotateMode.Fast):OnComplete(function()  
            self:SetPokerTypeText(index,text,3)
        end))
    end)  
end

function LaoYanCaiTableView:SetPokerTypeText(index,text,textIndex) --textIndex 显示2张牌的文字还是3张牌的文字，为0时隐藏
    if(text == "") then
        return;
    end
    local maskImage3 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Point/ImageFor3",ComponentTypeName.Transform).gameObject;
    local maskImage2 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Point/ImageFor2",ComponentTypeName.Transform).gameObject;

    local text3 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Point/TextFor3","TextWrap");
    local text2 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Point/TextFor2","TextWrap");
    if(textIndex == 3) then
        maskImage2:SetActive(false)
        maskImage3:SetActive(true);
        text2.gameObject:SetActive(false)
        text3.gameObject:SetActive(true);
        text3.text = text;
    elseif(textIndex == 2) then
        maskImage2:SetActive(true)
        maskImage3:SetActive(false);
        text2.gameObject:SetActive(true)
        text3.gameObject:SetActive(false);
        text2.text = text;
    elseif(textIndex == 0) then
        maskImage2:SetActive(false)
        maskImage3:SetActive(false);
        text2.gameObject:SetActive(false)
        text3.gameObject:SetActive(false);
        text2.text = text;
        text3.text = text;
    end
end

function LaoYanCaiTableView:SetMaBaoPlayTypeUI()
    self.buttonJoinBankerQueue:SetActive(true);
end

function LaoYanCaiTableView:SetSeatActive(index,isActive)
    local seatHolder = self.seatHolderArray[index]
    seatHolder.buttonNotSeatDown.gameObject:SetActive(isActive)
end

function LaoYanCaiTableView:ShowStartBankerStatus(state,time)
    self:subscibe_time_event(1,false,0):OnComplete(function (t)
        if(state == 0) then
            self:SetRobButtonsActive(true)
            self:HideTip();
            self.tip:SetActive(true)
            for i = 0,time - 2 do
                self:subscibe_time_event(i, false, 0):OnComplete(function(t)
                    local text ="请选择是否抢庄？".. time - 2 - i.."s";    
                    self:SetTipsText(text);
                    if(time - 2 - i == 0) then
                    end    
                end)       
            end
        elseif(state == 1) then

        elseif(state == 2) then

        end
    end)
    
end

function LaoYanCaiTableView:ShowScore(index,score)
    
end

function LaoYanCaiTableView:ShowResult(index,score,pokerNum)
    if(score == 0) then
        self:HideResultIcon(index)
        return;
    end
    local image = nil;
    if(pokerNum == 2) then
        if(score > 0) then
            image = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageWin2",ComponentTypeName.Image).gameObject;
        elseif(score < 0) then
            image = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageLose2",ComponentTypeName.Image).gameObject;
        end
    elseif(pokerNum == 3) then
        if(score > 0) then
            image = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageWin3",ComponentTypeName.Image).gameObject;
        elseif(score < 0) then
            image = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageLose3",ComponentTypeName.Image).gameObject;
        end
    end
    image:SetActive(true);
end

function LaoYanCaiTableView:HideResultIcon(index)
    local imageWin2 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageWin2",ComponentTypeName.Image).gameObject;
    local imageLose2 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageLose2",ComponentTypeName.Image).gameObject;
    local imageWin3 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageWin3",ComponentTypeName.Image).gameObject;
    local imageLose3 = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Result/ImageLose3",ComponentTypeName.Image).gameObject;
    imageWin2:SetActive(false);
    imageLose2:SetActive(false);
    imageWin3:SetActive(false);
    imageLose3:SetActive(false);
end

function LaoYanCaiTableView:SetRestPokerNum(num)
    self.textRestPokerNum.text = num;
end

function LaoYanCaiTableView:SetRobButtonsActive(isActive)
    self.buttonRob.gameObject:SetActive(isActive)
    self.buttonNotRob.gameObject:SetActive(isActive)
end

function LaoYanCaiTableView:SetTipsText(text)
    self.tipText.text = text;
end

function LaoYanCaiTableView:SetTips2Text(text)
    self.tipText2.text = text;
end

function LaoYanCaiTableView:showStartStatus(isCreator)
    if(isCreator) then
        self.actionStateSwitcher:SwitchState("Creator")
    else
        self.actionStateSwitcher:SwitchState("Normal")
    end
end

function LaoYanCaiTableView:ShowRestPokerNum()
    self.restPokerNum:SetActive(true);
end

function LaoYanCaiTableView:ShowBaoChips(chipValue)
    local textBet = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBetMaBao/Text",ComponentTypeName.Text)
    textBet.text = chipValue
    self.buttonBetMaBao.gameObject:SetActive(true);
end

function LaoYanCaiTableView:ShowChips(chipValues)
    self.betPanel:SetActive(true);
    if(#chipValues < 4) then
        return;
    end
    for i = 1,4 do
        local textBet = GetComponentWithPath(self.root,"Buttons/Bet/ButtonBet"..i.."/Text",ComponentTypeName.Text)
        textBet.text = chipValues[i]
    end
end

function LaoYanCaiTableView:ClearTable()
    self:HideTip();
    self:SetOperationButtonActive(1,false);
    self:SetOperationButtonActive(2,false);
    self:SetOperationButtonActive(3,false);
    self.explodeAnim:SetActive(false);
    for i = 1,7 do
        local panel = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/Panel",ComponentTypeName.Transform).gameObject;
        local coins = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/coin",ComponentTypeName.Transform).gameObject;
        local thirdPoker = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/Panel/3",ComponentTypeName.Transform).gameObject;
        local textScorePlus = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/Score/TextPlus",ComponentTypeName.Transform).gameObject;
        local textScoreMinus = GetComponentWithPath(self.root,"Seats/"..i.."/Panel/Score/TextMinus",ComponentTypeName.Transform).gameObject;
        thirdPoker:SetActive(false);
        panel:SetActive(false);
        coins:SetActive(false);
        self:SetPokerTypeText(i,"1",0);
        self:HideResultIcon(i);
        textScorePlus:SetActive(false);
        textScoreMinus:SetActive(false);
    end
end

function LaoYanCaiTableView:getTotalSeatCount()
    return 7;
end

function LaoYanCaiTableView:ShowCountDownText(text,time)
    self:HideTip();
    self.tip2:SetActive(true)
    for i = 0,time do
        self:subscibe_time_event(i, false, 0):OnComplete(function(t)
            self:SetTips2Text(text..time - i.."s");
        end)       
    end
end

function LaoYanCaiTableView:HideTip()
    self.tip:SetActive(false);
    self.tip2:SetActive(false);
    self.tip3:SetActive(false);
    if(self.tip3TimeEvent) then
        CSmartTimer:Kill(self.tip3TimeEvent)
        self.tip3TimeEvent = nil
    end
end

function LaoYanCaiTableView:SetTip4Active(isActive)
    self.tip4:SetActive(isActive);
end

function LaoYanCaiTableView:getImageNameFromCode(code)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function LaoYanCaiTableView:getImageNameFromCard(card)
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
        return 'hongtao_' .. number
    elseif(color == cardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == cardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end





function LaoYanCaiTableView:goldFlyToSeat(goldList, seatPos, duration, delayTime, autoDestory, onFinish)
    duration = duration or 0.5
    delayTime = delayTime or 0
    table.sort( goldList, function(a,b) 
        local disA = UnityEngine.Vector3.Distance(a.transform.position, seatPos)
        local disB = UnityEngine.Vector3.Distance(b.transform.position, seatPos)
        if(disA < disB)then
            return true
        end
        return false
    end)

    local len = #goldList
    local tmpDelayTime = math.min(0.1, 1 / len)
    for i=1,len do
        local tmpOnFinish = nil
        if(i == len)then
            tmpOnFinish = onFinish
        end
        local gold = goldList[i]
        self:flyToPos(gold.transform, seatPos, duration, delayTime + (i - 1) * tmpDelayTime, function ()
            if(autoDestory)then
                UnityEngine.GameObject.Destroy(gold)
            end
            if(tmpOnFinish)then
                tmpOnFinish()
            end
        end)   
    end

end

--显示座位的倒计时效果
function LaoYanCaiTableView:showSeatTimeLimitEffect(seatData, show, duration, onFinish, loopTimes)
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
                self:showSeatTimeLimitEffect(seatData, show, duration, onFinish, loopTimes)
            elseif(loopTimes > 0)then
                self:showSeatTimeLimitEffect(seatData, show, duration, onFinish, loopTimes - 1)
            end
        end
    end):SetIntervalTime(0.05, function(t)
        seatHolder.timeLimit.curTime = Time.realtimeSinceStartup
        local rate = (seatHolder.timeLimit.curTime - seatHolder.timeLimit.startTime) / duration
        seatHolder.imageTimeLimit.fillAmount = 1 - rate
    end)
    seatHolder.timeLimit.timeEvent_id = timeEvent.id
end

function LaoYanCaiTableView:SetBankerQueue(index,playerInfo)
    if(index > 3) then
        --more:SetActive(true);
        return;
    end
    local seatHolder = {};
    seatHolder.imagePlayerHead = GetComponentWithPath(self.root,"Center/BankerQueue/"..index.."/Avatar/Mask/Image",ComponentTypeName.Image);
    self:SetBankerQueueHeadIcon(seatHolder, playerInfo)
end

function LaoYanCaiTableView:SetBankerQueueActive(queueNum)
    local more = GetComponentWithPath(self.root,"Center/BankerQueue/Text",ComponentTypeName.Text).gameObject;
    more:SetActive(false);
    if(queueNum > 2) then
        more:SetActive(true);
        queueNum = 2;
    end
    for i = 1,2 do
        local seat = GetComponentWithPath(self.root,"Center/BankerQueue/"..i + 1,ComponentTypeName.Transform).gameObject;
        seat:SetActive(false);
    end
    for i = 1,queueNum do
        local seat = GetComponentWithPath(self.root,"Center/BankerQueue/"..i + 1,ComponentTypeName.Transform).gameObject;
        seat:SetActive(true);
    end
end

function LaoYanCaiTableView:SetBankerQueueHeadIcon(seatHolder, playerInfo)
    if(not playerInfo) then
        return;
    end
    if(playerInfo.playerId ~= 0)then
        --seatHolder.textPlayerName.text = Util.filterPlayerName(playerInfo.playerName)
        --playerInfo.playerShowName = seatHolder.textPlayerName.text
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
        --seatHolder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
end

function LaoYanCaiTableView:playFaPaiAnim(localSeatIndex, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local delay = 0.2
    local duration = 0.5
    local finishCount = 0
    --local localSeatIndex = seatInfo.localSeatIndex;
	local heap = self.pokerHeap;
    for i = 1, 2 do
        local cardHolder = seatHolder.cardHolderList[i];
        ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, heap.position.x, false)
        ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, heap.position.y, false)
        local pokerHeapCardScale = ModuleCache.CustomerUtil.ConvertVector3(0.58, 0.58, 0.58)
        cardHolder.cardRoot.transform.localScale = pokerHeapCardScale

        ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, heap.position.x, false)
        ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, heap.position.y, false)
        self:playCardFlyToPosAnim(cardHolder, cardHolder.cardPosition, duration,(i - 1) * delay, function()            
            ModuleCache.TransformUtil.SetX(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.x, true)
            ModuleCache.TransformUtil.SetY(cardHolder.cardRoot.transform, cardHolder.cardLocalPosition.y, true)
        end )
        self:playCardScaleAnim(cardHolder, cardHolder.cardLocalScale.x, duration,(i - 1) * delay, nil)

        
        --self:playCardRotateAnim(cardHolder, true, duration,(i - 1) * delay, function()
            --finishCount = finishCount + 1
            --if (finishCount == count) then
                --if (onFinish) then
                    --onFinish()
                --end
            --end
        --end)
    end
end

function LaoYanCaiTableView:DisplayScore(index,score)
    local scoreText = nil;
    if(score >= 0) then
        scoreText = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Score/TextPlus/TextPlus","TextWrap");
        scoreText.text ="+".. score;
        scoreText.transform.parent.gameObject:SetActive(true);
    else
        scoreText = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Score/TextMinus/TextMinus","TextWrap");
        scoreText.text = score;
        scoreText.transform.parent.gameObject:SetActive(true);
    end
    local target = GetComponentWithPath(self.root,"Seats/"..index.."/Panel/Score/MoveTarget",ComponentTypeName.Transform).gameObject
    self:PlayScoreAnim(scoreText.transform.parent.gameObject,1.2,target)
end

function LaoYanCaiTableView:PlayCoinFliesToBankerAnim(indexLoser,indexBanker,score)
    local coin = self.coins[indexLoser]
    local targetCoin = self.coins[indexBanker];
    for i = 1,15 do
        self:subscibe_time_event(i * 0.1, false, 0):OnComplete(function(t)
            local coinCopy = Instantiate(coin,coin.transform.parent.gameObject)
            self:flyToPos(coinCopy.transform,targetCoin.transform.position,0.3,0,function()
                UnityEngine.GameObject.Destroy(coinCopy);
                if(i == 15) then
                    self:ShowBetScore(indexBanker, -score)
                end
            end)
            if(i == 1) then
                self:PlayCoinsFlySound();
            end
        end)
    end
    
end

function LaoYanCaiTableView:PlayBankerCoinFliesAnim(indexWinner,indexBanker,score,winnerCount)
    local coin = self.coins[indexBanker]
    local targetCoin = self.coins[indexWinner];
    local delay = 2;
    if(winnerCount == 0) then
        delay = 0;
    end
    for i = 1,15 do
        self:subscibe_time_event(i * 0.1, false, 0):OnComplete(function(t)
            local coinCopy = Instantiate(coin,coin.transform.parent.gameObject)
            self:flyToPos(coinCopy.transform,targetCoin.transform.position,0.3,delay,function()
                UnityEngine.GameObject.Destroy(coinCopy);
                if(i == 15) then
                    self:ShowBetScore(indexBanker, -score)
                end
                if(i == 1) then
                    self:PlayCoinsFlySound();
                end
            end)
        end)
    end
    
end

--飞到制定位置
function LaoYanCaiTableView:flyToPos(trans, targetPos, duration, delayTime, onFinish)
    duration = duration or 0.5
    delayTime = delayTime or 0
    local sequence = self:create_sequence();
    local target = trans
    sequence:Append(target:DOMove(targetPos, duration, false):SetDelay(delayTime):SetEase(DG.Tweening.Ease.OutQuint))
    sequence:OnComplete(function() 
        if(onFinish)then                
            onFinish()
        end
    end)  
end


function LaoYanCaiTableView:PlayScoreAnim(scoreText,duration,target)
    local posX = scoreText.transform.localPosition.x;
    local posY = scoreText.transform.localPosition.y;
    self:playScoreFlyToPosAnim(scoreText,target.transform.position,duration,0,function()
        ModuleCache.TransformUtil.SetX(scoreText.transform, posX, true)
        ModuleCache.TransformUtil.SetY(scoreText.transform, posY, true)
        scoreText:SetActive(false)
    end)
end

function LaoYanCaiTableView:playScoreFlyToPosAnim(scoreText, targetPos, duration, delayTime, onFinish)
    local sequence = self:create_sequence()
    sequence:Append(scoreText.transform:DOMove(targetPos, duration, false):SetDelay(delayTime))  
    self:setTargetFrame(true)  
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end

function LaoYanCaiTableView:playCardRotateAnim(cardHolder, toFace, duration, delayTime, onFinish)
    local sequence = self:create_sequence()
    local originalRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 0, 0)
    local targetRotate = ModuleCache.CustomerUtil.ConvertVector3(0, 90, 0)
    if(toFace)then
        self:showCardBack(cardHolder)
    else
        self:showCardFace(cardHolder)
    end
    
    sequence:Append(cardHolder.cardRoot.transform:DOLocalRotate(targetRotate, duration * 0.5, DG.Tweening.RotateMode.Fast):SetDelay(delayTime):OnComplete(function()
        if(toFace)then
            self:showCardFace(cardHolder)
        else
            self:showCardBack(cardHolder)
        end 
    end))
    sequence:Append(cardHolder.cardRoot.transform:DOLocalRotate(originalRotate, duration * 0.5, DG.Tweening.RotateMode.Fast))
    self:setTargetFrame(true)
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end

function LaoYanCaiTableView:playCardFlyToPosAnim(cardHolder, targetPos, duration, delayTime, onFinish)
    local sequence = self:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOMove(targetPos, duration, false):SetDelay(delayTime))  
    self:setTargetFrame(true)  
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end

function LaoYanCaiTableView:playCardScaleAnim(cardHolder, targetScale, duration, delayTime, onFinish)
    local sequence = self:create_sequence()
    sequence:Append(cardHolder.cardRoot.transform:DOScaleX(targetScale, duration):SetDelay(delayTime))    
    sequence:Join(cardHolder.cardRoot.transform:DOScaleY(targetScale, duration))   
    self:setTargetFrame(true) 
    sequence:OnComplete(function()
        self:setTargetFrame(false)
        if(onFinish)then
            onFinish()
        end        
    end)
end

--显示牌正面
function LaoYanCaiTableView:showCardFace(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, true)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, false)
end
--显示牌背面
function LaoYanCaiTableView:showCardBack(cardHolder)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.face.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(cardHolder.back.gameObject, true)
end

function LaoYanCaiTableView:setTargetFrame(anim)
    -- local targetFrameRate = (anim and 60) or 30
    UnityEngine.Application.targetFrameRate = (anim and 60) or ModuleCache.AppData.tableTargetFrameRate
end

function LaoYanCaiTableView:refreshSeatPlayerInfo(seatInfo, localSeatIndex)
    --print(#self.seatHolderArray, seatInfo.localSeatIndex)
    localSeatIndex = localSeatIndex or seatInfo.localSeatIndex
    local seatHolder = self.seatHolderArray[localSeatIndex]
    if(seatInfo.playerId and (seatInfo.playerId ~= 0 and seatInfo.playerId ~= "0")) then
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageCreator.gameObject, seatInfo.isCreator or false)
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.imageBanker.gameObject, seatInfo.isBanker or false)
        if(seatInfo.playerInfo and seatInfo.playerInfo.userId and seatInfo.playerInfo.userId..'' == seatInfo.playerId..'')then
            self:setPlayerInfo(seatHolder, seatInfo.playerInfo)
        else
            seatInfo.playerInfo = nil
            self:get_userinfo(seatInfo.playerId, function(err, data)
                if(err)then
                    self:refreshSeatPlayerInfo(seatInfo)
                    return
                end
                local playerInfo = {}
                playerInfo.playerId = seatInfo.playerId
                playerInfo.userId = data.userId
		        playerInfo.playerName = data.nickname
                playerInfo.nickname = data.nickname
		        playerInfo.headUrl = data.headImg
                playerInfo.headImg = data.headImg
                playerInfo.gender = data.gender
                playerInfo.score = data.score
                playerInfo.lostCount = data.lostCount
                playerInfo.winCount = data.winCount
                playerInfo.tieCount = data.tieCount
                playerInfo.breakRate = data.breakRate
                playerInfo.localIp = data.ip
                playerInfo.ip = ''
                seatInfo.playerInfo = playerInfo
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
        --ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, true)
    end
    if(seatInfo.playerId == 0 or seatInfo.playerId == "0" ) then
        if(self.modelData.curTableData.roomInfo.curRoundNum == 0) then
            ModuleCache.ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown.gameObject, true)
        end
    end
end

return LaoYanCaiTableView