--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local class = require("lib.middleclass")
local View = require('package.daigoutui.module.table.base_table_view')
local DaiGouTuiTableView = class('DaiGouTuiTableView', View)

function DaiGouTuiTableView:initialize(...)
    View.initialize(self, "daigoutui/module/table/daigoutui_table.prefab", "DaiGouTui_Table", 0)
    self.fengDingText = GetComponentWithPath(self.root, "Center/Text", ComponentTypeName.Text)
    self.goCallServantBtns = GetComponentWithPath(self.root, "Buttons/CallGouTuiBtns", ComponentTypeName.Transform).gameObject
    self.uiStateSwitcher_callServent = GetComponentWithPath(self.root, "Buttons/CallGouTuiBtns", 'UIStateSwitcher')
    self.uiStateSwitcher_leave_ready_invite = GetComponentWithPath(self.root, "Bottom/Action", 'UIStateSwitcher')
    self.buttonMingPai_1vs4 = GetComponentWithPath(self.goCallServantBtns, "ButtonMing_1vs4", ComponentTypeName.Button)
    self.buttonAnPai_1vs4 = GetComponentWithPath(self.goCallServantBtns, "ButtonAn_1vs4", ComponentTypeName.Button)
    self.buttonCallServant = GetComponentWithPath(self.goCallServantBtns, "ButtonCallGouTui", ComponentTypeName.Button)
    self.buttonRestart = GetComponentWithPath(self.goCallServantBtns, "ButtonRestart", ComponentTypeName.Button)

    self.buttonShowCard = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonShowCard", ComponentTypeName.Button)
    self.buttonNotShowCard = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonNotShowCard", ComponentTypeName.Button)
    self.buttonBuChu = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonBuChu", ComponentTypeName.Button)
    self.buttonChuPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonChuPai", ComponentTypeName.Button)
    self.buttonTiShi = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonTiShi", ComponentTypeName.Button)
    self.buttonYaoBuQi = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonYaoBuQi", ComponentTypeName.Button)

    self.textNoBig = GetComponentWithPath(self.root, "Bottom/NoBigText", ComponentTypeName.Text)

    self.buttonLiPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonLiPai", ComponentTypeName.Button)

    self.textTips = GetComponentWithPath(self.root, "Center/Tips/Text", ComponentTypeName.Text)

    self.goSelectServantCardEffect = GetComponentWithPath(self.root, "SelectServantCardAnim", ComponentTypeName.Transform).gameObject
    self.imageSelectServantCardEffect = GetComponentWithPath(self.goSelectServantCardEffect, "Animator/HeXinZu/PuKe1/PaiMian", ComponentTypeName.Image)
    self.pos_goSelectServantCardEffect = self.goSelectServantCardEffect.transform.localPosition
end

function DaiGouTuiTableView:setRoomInfo(roomNum, curRoundNum, totalRoundCount, wanfaName)
    self.textRoomNum.text = "房号:" .. roomNum
    self.textRoundNum.text = "(第" .. curRoundNum .. "/" .. totalRoundCount .. "局)"
    self.textWanFa.text = wanfaName
    self.textRoundNum.gameObject:SetActive(true)
end

function DaiGouTuiTableView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    local root = seatRoot
    seatHolder.buttonKick =  GetComponentWithPath(root, "Info/KickBtn", ComponentTypeName.Button)
    seatHolder.goMingPaiTag =  GetComponentWithPath(root, "Info/ImageMingPai", ComponentTypeName.Transform).gameObject
    seatHolder.goXiPaiMultiple = GetComponentWithPath(root, "Info/ImageXiPai", ComponentTypeName.Transform).gameObject
    seatHolder.imageXiPaiTag = GetComponentWithPath(seatHolder.goXiPaiMultiple, "image", ComponentTypeName.Image)
    seatHolder.textXiPaiMultiple = GetComponentWithPath(seatHolder.goXiPaiMultiple, "text", ComponentTypeName.Text)
end

--显示出牌相关按钮
function DaiGouTuiTableView:showChuPaiButtons(show, isFirst, yaoBuQi)
    --yaoBuQi = false
    ModuleCache.ComponentManager.SafeSetActive(self.buttonChuPai.gameObject, show and (not yaoBuQi) or false)
    self:setGray(self.buttonChuPai.gameObject, yaoBuQi or false)
    self.buttonChuPai.enabled = not (yaoBuQi or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonBuChu.gameObject, show and (not yaoBuQi) or false)
    self:setGray(self.buttonBuChu.gameObject, isFirst or false)
    self.buttonBuChu.enabled = not (isFirst or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonTiShi.gameObject, show and (not yaoBuQi) or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonYaoBuQi.gameObject, show and (not isFirst) and yaoBuQi or false)
    self:showNoBigText(show and (not isFirst) and yaoBuQi)
end

function DaiGouTuiTableView:showNoBigText(show)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.textNoBig.gameObject, show)
end

--设置出牌按钮置灰
function DaiGouTuiTableView:setChuPaiBtnGrayAndEnable(gray, enable)
    self:setGray(self.buttonChuPai.gameObject, gray or false)
    self.buttonChuPai.enabled = enable or false
end

--显示明牌按钮
function DaiGouTuiTableView:showMingPaiBtn(show)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonShowCard.gameObject, show or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonNotShowCard.gameObject, show or false)
end

--显示踢人按钮
function DaiGouTuiTableView:showKickBtns(show, ignoreLocalSeatIndex)
    for i,v in ipairs(self.seatHolderArray) do
        if(i == ignoreLocalSeatIndex)then
            ModuleCache.ComponentManager.SafeSetActive(v.buttonKick.gameObject, false)
        else
            ModuleCache.ComponentManager.SafeSetActive(v.buttonKick.gameObject, show or false)
        end
    end
end

--显示叫狗腿按钮
function DaiGouTuiTableView:showCallServantBtns(show, canCallServant, onlyShowRestart)
    ModuleCache.ComponentManager.SafeSetActive(self.goCallServantBtns, show or false)
    if(show)then
        if(onlyShowRestart)then
            self.uiStateSwitcher_callServent:SwitchState("Restart")
        else
            if(canCallServant)then
                self.uiStateSwitcher_callServent:SwitchState("Show_CallServant")
            else
                self.uiStateSwitcher_callServent:SwitchState("Show_Restart")
            end
        end
    end
end

function DaiGouTuiTableView:showFengDingText(show, text)
    ModuleCache.ComponentManager.SafeSetActive(self.fengDingText.gameObject, show or false)
    if(show)then
        self.fengDingText.text = text
    end
end

--显示明牌标签
function DaiGouTuiTableView:showMingPaiTag(localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.goMingPaiTag, show or false)
end

--显示座位手牌
function DaiGouTuiTableView:showSeatHandPokers(localSeatIndex, show)
    View.showSeatHandPokers(self, localSeatIndex, show)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local handPokerHolder = seatHolder.handPokerHolder
    if(not show)then
        seatHolder.isChouTiOpen = false
        self:showChouTi(localSeatIndex, false, true)
    end
end

--播放座位喜牌
function DaiGouTuiTableView:playXiPaiMultipleTag(localSeatIndex, show, last_multiple, multiple, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentManager.SafeSetActive(seatHolder.goXiPaiMultiple, show or false)
    if(show)then
        seatHolder.textXiPaiMultiple.text = 'x' .. multiple
        ModuleCache.ComponentManager.SafeSetActive(seatHolder.imageXiPaiTag.gameObject, true)
        local startPos = ModuleCache.CustomerUtil.ConvertVector3(-80,0,0)
        local endPos = ModuleCache.CustomerUtil.ConvertVector3(0,0,0)
        local startScale = 2
        local endScale = 1
        if(withoutAnim)then
            seatHolder.imageXiPaiTag.transform.localPosition = endPos
            seatHolder.textXiPaiMultiple.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(endScale,endScale,1)
            ModuleCache.ComponentManager.SafeSetActive(seatHolder.textXiPaiMultiple.gameObject, true)
        else
            if(last_multiple and last_multiple > 0)then
                ModuleCache.ComponentManager.SafeSetActive(seatHolder.textXiPaiMultiple.gameObject, true)
                self:playLocalScaleAnim(seatHolder.textXiPaiMultiple.gameObject, startScale, endScale, 0.1, onFinish)
                return
            end
            if(localSeatIndex == 2 or localSeatIndex == 3)then
                startPos = ModuleCache.CustomerUtil.ConvertVector3(100,0,0)
            end
            ModuleCache.ComponentManager.SafeSetActive(seatHolder.textXiPaiMultiple.gameObject, false)
            self:playLocalMoveAnim(seatHolder.imageXiPaiTag.gameObject, startPos, endPos, 0.2, function ()
                ModuleCache.ComponentManager.SafeSetActive(seatHolder.textXiPaiMultiple.gameObject, true)
                self:playLocalScaleAnim(seatHolder.textXiPaiMultiple.gameObject, startScale, endScale, 0.1, onFinish)
            end)
        end
    end
end

function DaiGouTuiTableView:playLocalMoveAnim(go, startPos, endPos, duration, onFinish)
    local sequence = self:create_sequence()
    go.transform.localPosition = startPos
    sequence:Append(go.transform:DOLocalMove(endPos, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

function DaiGouTuiTableView:playLocalScaleAnim(go, startScale, endScale, duration, onFinish)
    local sequence = self:create_sequence()
    go.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(startScale,startScale,1)
    sequence:Append(go.transform:DOScale(endScale, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

--打开抽屉
function DaiGouTuiTableView:showChouTi(localSeatIndex, show, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    if(not seatHolder.handPokerHolder.tran_chouti_close_pos)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    local duration = 0.2
    local targetPosX = seatHolder.handPokerHolder.tran_chouti_close_pos.localPosition.x
    if(show)then
        targetPosX = seatHolder.handPokerHolder.tran_chouti_open_pos.localPosition.x
    end
    local sequence = self:create_sequence()
    sequence:Append(seatHolder.handPokerHolder.goChouTi.transform:DOLocalMoveX(targetPosX, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end


--显示或隐藏理牌按钮
function DaiGouTuiTableView:showLiPaiBtn(show)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.buttonLiPai.gameObject, show)
end

function DaiGouTuiTableView:showTips(show, content)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.textTips.transform.parent.gameObject, show)
    if(show)then
        self.textTips.text = content
    end
end


function DaiGouTuiTableView:show_leave_ready_invite_btn(leave_invite, ready)
    if(not leave_invite)then
        self.uiStateSwitcher_leave_ready_invite:SwitchState('None')
        return
    end
    if(ready)then
        self.uiStateSwitcher_leave_ready_invite:SwitchState('Leave_Ready_Invite')
    else
        self.uiStateSwitcher_leave_ready_invite:SwitchState('Leave_Invite')
    end
end

function DaiGouTuiTableView:playSelectServantCardAnim(servantCard, onFinish)
    local spriteName = self:getImageNameFromCode(servantCard)
    self.imageSelectServantCardEffect.sprite = self.cardAssetHolder:FindSpriteByName(spriteName)
    ModuleCache.ComponentManager.SafeSetActive(self.goSelectServantCardEffect, true)
    self:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
        local dstPos = self.goTuiCardHolder.pokerHolder.root.transform.position
        local dstScale = Vector3.New(0.22, 0.27, 1)
        local duration = 0.5
        local sequence = self:create_sequence()
        sequence:Join(self.imageSelectServantCardEffect.transform:DOMove(dstPos, duration, false))
        sequence:Join(self.imageSelectServantCardEffect.transform:DOScale(dstScale, duration))
        sequence:OnComplete(function ()
            self.imageSelectServantCardEffect.transform.localPosition = Vector3.zero
            self.imageSelectServantCardEffect.transform.localScale = Vector3.one
            ModuleCache.ComponentManager.SafeSetActive(self.goSelectServantCardEffect, false)
            self:showServantCards(true, servantCard)
            if(onFinish)then
                onFinish()
            end
        end)
    end)
end

return  DaiGouTuiTableView