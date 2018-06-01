--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local class = require("lib.middleclass")
local View = require('package.wushik.module.table.base_table_view')
---@class WuShiKTableView:WuShiKTableBaseView
local WuShiKTableView = class('WuShiKTableView', View)

function WuShiKTableView:initialize(...)
    View.initialize(self, "wushik/module/table/wushik_table.prefab", "WuShiK_Table", 0)

    self.uiStateSwitcher_leave_ready_invite = GetComponentWithPath(self.root, "Bottom/Action", 'UIStateSwitcher')

    self.buttonDuPai = GetComponentWithPath(self.root, "Buttons/JiaoPai/ButtonDuPai", ComponentTypeName.Button)
    self.buttonBuDu = GetComponentWithPath(self.root, "Buttons/JiaoPai/ButtonBuDu", ComponentTypeName.Button)

    self.buttonBuChu = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonBuChu", ComponentTypeName.Button)
    self.buttonChuPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonChuPai", ComponentTypeName.Button)
    self.buttonTiShi = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonTiShi", ComponentTypeName.Button)
    self.buttonYaoBuQi = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonYaoBuQi", ComponentTypeName.Button)


    self.button50K = GetComponentWithPath(self.root, "Buttons/Buttons/Button50K", ComponentTypeName.Button)
    self.buttonLiPai = GetComponentWithPath(self.root, "Buttons/Buttons/ButtonPaiXu", ComponentTypeName.Button)

    self.textTips = GetComponentWithPath(self.root, "Center/Tips/Text", ComponentTypeName.Text)

    self.askWindowHolder = {}
    self.askWindowHolder.root = GetComponentWithPath(self.root, "AskWindow", ComponentTypeName.Transform).gameObject
    self.askWindowHolder.text = GetComponentWithPath(self.askWindowHolder.root, "Text", ComponentTypeName.Text)
    self.askWindowHolder.buttonConfirm = GetComponentWithPath(self.askWindowHolder.root, "ButtonConfirm", ComponentTypeName.Button)
    self.askWindowHolder.buttonCancel = GetComponentWithPath(self.askWindowHolder.root, "ButtonCancel", ComponentTypeName.Button)

    self.effectJiaoJiHolder = {}
    self.effectJiaoJiHolder.root = GetComponentWithPath(self.root, "JiaoJiAnim", ComponentTypeName.Transform).gameObject
    self.effectJiaoJiHolder.anim = GetComponentWithPath(self.effectJiaoJiHolder.root, "jiaoji", ComponentTypeName.Transform).gameObject
    self.effectJiaoJiHolder.image = GetComponentWithPath(self.effectJiaoJiHolder.root, "image", ComponentTypeName.Image)

    self.effectDuPaiHolder = {}
    self.effectDuPaiHolder.root = GetComponentWithPath(self.root, "DuPaiAnim", ComponentTypeName.Transform).gameObject
    self.effectDuPaiHolder.anim = GetComponentWithPath(self.effectDuPaiHolder.root, "dupai", ComponentTypeName.Transform).gameObject
    self.effectDuPaiHolder.image = GetComponentWithPath(self.effectDuPaiHolder.root, "image", ComponentTypeName.Image)

    self.goJiaoPaiEffect = GetComponentWithPath(self.root, "JiaoPaiAnim", ComponentTypeName.Transform).gameObject
    self.imageJiaoPaiEffect = GetComponentWithPath(self.goJiaoPaiEffect, "Animator/HeXinZu/PuKe1/PaiMian", ComponentTypeName.Image)
    self.pos_goJiaoPaiEffect = self.goJiaoPaiEffect.transform.localPosition

    self.buttonTestReconnect = GetComponentWithPath(self.root, "Top/TestBtnReconnection", ComponentTypeName.Button)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonTestReconnect.gameObject, ModuleCache.GameManager.developmentMode or false)

    self.image_ownTeamCardTips = GetComponentWithPath(self.root, "Center/JiPaiRemind/Image", ComponentTypeName.Image)
    self.tran_ownTeamCardStartPos = GetComponentWithPath(self.root, "Center/JiPaiRemind/startPos", ComponentTypeName.Transform)
    self.tran_ownTeamCardEndPos = GetComponentWithPath(self.root, "Center/JiPaiRemind/endPos", ComponentTypeName.Transform)

    --屏蔽Top使用PokerTableFrame
    if(true)then
        local goTop = GetComponentWithPath(self.root, "Top", ComponentTypeName.Transform).gameObject
        ModuleCache.ComponentManager.SafeSetActive(goTop, false)

    end
end

function WuShiKTableView:setRoomInfo(roomNum, curRoundNum, totalRoundCount, wanfaName)
    self.textRoomNum.text = "房号:" .. roomNum
    self.textRoundNum.text = string.format('%s 第%d/%d局', wanfaName, curRoundNum, totalRoundCount)
    self.textRoundNum.gameObject:SetActive(true)
end

function WuShiKTableView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    local root = seatRoot
    seatHolder.buttonKick =  GetComponentWithPath(root, "Info/KickBtn", ComponentTypeName.Button)
end

--显示出牌相关按钮
function WuShiKTableView:showChuPaiButtons(show, isFirst, yaoBuQi)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonChuPai.gameObject, show and (not yaoBuQi) or false)
    self:setGray(self.buttonChuPai.gameObject, yaoBuQi or false)
    self.buttonChuPai.enabled = not (yaoBuQi or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonBuChu.gameObject, show and (not yaoBuQi) or false)
    self:setGray(self.buttonBuChu.gameObject, isFirst or false)
    self.buttonBuChu.enabled = not (isFirst or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonTiShi.gameObject, show and (not yaoBuQi) or false)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonYaoBuQi.gameObject, show and (not isFirst) and yaoBuQi or false)
end

--设置出牌按钮置灰
function WuShiKTableView:setChuPaiBtnGrayAndEnable(gray, enable)
    self:setGray(self.buttonChuPai.gameObject, gray or false)
    self.buttonChuPai.enabled = enable or false
end

--显示踢人按钮
function WuShiKTableView:showKickBtns(show, ignoreLocalSeatIndex)
    for i,v in ipairs(self.seatHolderArray) do
        if(i == ignoreLocalSeatIndex)then
            ModuleCache.ComponentManager.SafeSetActive(v.buttonKick.gameObject, false)
        else
            ModuleCache.ComponentManager.SafeSetActive(v.buttonKick.gameObject, show or false)
        end
    end
end


function WuShiKTableView:playLocalMoveAnim(go, startPos, endPos, duration, onFinish)
    local sequence = self:create_sequence()
    go.transform.localPosition = startPos
    sequence:Append(go.transform:DOLocalMove(endPos, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

function WuShiKTableView:playLocalScaleAnim(go, startScale, endScale, duration, onFinish)
    local sequence = self:create_sequence()
    go.transform.localScale = ModuleCache.CustomerUtil.ConvertVector3(startScale,startScale,1)
    sequence:Append(go.transform:DOScale(endScale, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

--显示或隐藏理牌按钮
function WuShiKTableView:showLiPaiBtn(show)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.buttonLiPai.gameObject, show)
end

function WuShiKTableView:show50KBtn(show)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.button50K.gameObject, show)
end

function WuShiKTableView:showTips(show, content)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.textTips.transform.parent.gameObject, show)
    if(show)then
        self.textTips.text = content
    end
end

function WuShiKTableView:showDuPaiBtn(show)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.buttonDuPai.gameObject, show)
    ModuleCache.ComponentManager.SafeSetActive(self.buttonBuDu.gameObject, show)
end

function WuShiKTableView:showSeatDuPaiAnim(localSeatIndex, show, duPai)

end

--播放独牌动画
function WuShiKTableView:playDuPaiAnim(localSeatIndex, onFinish)
    local holder = self.effectDuPaiHolder
    ModuleCache.ComponentManager.SafeSetActive(holder.root, true)

    local seatHolder = self.seatHolderArray[localSeatIndex]

    local go = holder.anim
    local duration = 1.5 * 0.75
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    ModuleCache.ComponentManager.SafeSetActive(holder.image.gameObject, false)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        ModuleCache.ComponentManager.SafeSetActive(holder.image.gameObject, true)
        holder.image.transform.localPosition = UnityEngine.Vector3.zero
        holder.image.transform.localScale = UnityEngine.Vector3.one
        local sequence = self:create_sequence()
        local move_duration = 0.4
        sequence:Join(holder.image.transform:DOMove(seatHolder.goLordTag.transform.position, move_duration))
        sequence:Join(holder.image.transform:DOScale(0.1736, move_duration))
        sequence:OnComplete(function ()
            ModuleCache.ComponentManager.SafeSetActive(holder.image.gameObject, false)
            ModuleCache.ComponentManager.SafeSetActive(holder.root, false)
            if(onFinish)then
                onFinish()
            end
        end)
    end)
end

function WuShiKTableView:playOwnTeamCardTipAnim(onFinish)
    ModuleCache.ComponentManager.SafeSetActive(self.image_ownTeamCardTips.gameObject, true)
    local startPos = UnityEngine.Vector3.New(self.tran_ownTeamCardStartPos.position.x, self.image_ownTeamCardTips.transform.position.y, self.image_ownTeamCardTips.transform.position.z)
    self.image_ownTeamCardTips.transform.position = startPos
    local sequence = self:create_sequence()
    local move_duration = 0.2
    local interval = 2.5
    sequence:Append(self.image_ownTeamCardTips.transform:DOLocalMoveX(0, move_duration))
    sequence:AppendInterval(interval)
    sequence:Append(self.image_ownTeamCardTips.transform:DOLocalMoveX(self.tran_ownTeamCardEndPos.localPosition.x, move_duration))
    sequence:OnComplete(function ()
        ModuleCache.ComponentManager.SafeSetActive(self.image_ownTeamCardTips.gameObject, false)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放确定鸡牌动画
function WuShiKTableView:playConfirmTeamCardAnim(teamCard, onFinish)
    self:showJiaoPaiFrame(true)
    self:refreshJiaoPai(false)
    self:playJiaoPaiAnim(teamCard, function()
        self:refreshJiaoPai(true, teamCard)
        if(onFinish)then
            onFinish()
        end
    end)
end

--播放出现队友动画
function WuShiKTableView:playAppearTeamMateAnim(localSeatIndex, onFinish)
    local holder = self.effectJiaoJiHolder
    ModuleCache.ComponentManager.SafeSetActive(holder.root, true)
    local seatHolder = self.seatHolderArray[localSeatIndex]

    local go = holder.anim
    local duration = 1.5 * 0.75
    ModuleCache.ComponentManager.SafeSetActive(go, true)
    ModuleCache.ComponentManager.SafeSetActive(holder.image.gameObject, false)
    self:subscibe_time_event(duration, false, 0):OnComplete(function(t)
        ModuleCache.ComponentManager.SafeSetActive(go, false)
        ModuleCache.ComponentManager.SafeSetActive(holder.image.gameObject, true)
        holder.image.transform.localPosition = UnityEngine.Vector3.zero
        holder.image.transform.localScale = UnityEngine.Vector3.one
        local sequence = self:create_sequence()
        local move_duration = 0.4
        sequence:Join(holder.image.transform:DOMove(seatHolder.goFriendTag.transform.position, move_duration))
        sequence:Join(holder.image.transform:DOScale(0.1, move_duration))
        sequence:OnComplete(function ()
            ModuleCache.ComponentManager.SafeSetActive(holder.image.gameObject, false)
            ModuleCache.ComponentManager.SafeSetActive(holder.root, false)
            if(onFinish)then
                onFinish()
            end
        end)
    end)
end

function WuShiKTableView:show_leave_ready_invite_btn(leave_invite, ready)
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

function WuShiKTableView:showAskWindow(show, content, callback)
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(self.askWindowHolder.root, show)
    if(show)then
        self.askWindowHolder.text.text = content
        self.askWindowHolder.callback = callback
    end
end

--播放叫牌动画
function WuShiKTableView:playJiaoPaiAnim(card, onFinish)
    local spriteName = self:getImageNameFromCode(card)
    self.imageJiaoPaiEffect.sprite = self.cardAssetHolder:FindSpriteByName(spriteName)
    ModuleCache.ComponentManager.SafeSetActive(self.goJiaoPaiEffect, true)
    self:subscibe_time_event(1.5 * 0.75, false, 0):OnComplete(function(t)
        local dstPos = self.jiaoPaiPokerHolder.root.transform.position
        local dstScale = Vector3.New(0.388, 0.388, 1)
        local duration = 0.5
        local sequence = self:create_sequence()
        sequence:Join(self.imageJiaoPaiEffect.transform:DOMove(dstPos, duration, false))
        sequence:Join(self.imageJiaoPaiEffect.transform:DOScale(dstScale, duration))
        sequence:OnComplete(function ()
            self.imageJiaoPaiEffect.transform.localPosition = Vector3.zero
            self.imageJiaoPaiEffect.transform.localScale = Vector3.one
            ModuleCache.ComponentManager.SafeSetActive(self.goJiaoPaiEffect, false)
            if(onFinish)then
                onFinish()
            end
        end)
    end)
end

return  WuShiKTableView