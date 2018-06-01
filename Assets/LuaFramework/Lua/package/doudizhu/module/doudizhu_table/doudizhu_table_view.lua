--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local class = require("lib.middleclass")
local View = require('package.doudizhu.module.doudizhu_table.doudizhu_base_table_view')
local DouDiZhuTableView = class('DouDiZhuTableView', View)

function DouDiZhuTableView:initialize(...)
    View.initialize(self, "doudizhu/module/table/doudizhu_table.prefab", "DouDiZhu_Table", 0)
    self.fengDingText = GetComponentWithPath(self.root, "Center/FengDingText", ComponentTypeName.Text)

    local goDeskLeftCardRoot = GetComponentWithPath(self.root, "Top/TopInfo/GoldCoin/DeskLeftCards", ComponentTypeName.Transform).gameObject
    local deskLeftCardsPokerHolderArray = {}
    for i=1,3 do
        local pokerHolder = {}
        pokerHolder.root = GetComponentWithPath(goDeskLeftCardRoot, "Poker"..i, ComponentTypeName.Transform).gameObject
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);
        deskLeftCardsPokerHolderArray[i] = pokerHolder
    end
    self.goDeskLeftCardRoot_gold = goDeskLeftCardRoot
    self.deskLeftCardsPokerHolderArray_gold = deskLeftCardsPokerHolderArray

    self.text_gold_BeiShu = GetComponentWithPath(self.root, "Top/TopInfo/GoldCoin/Multiple/Text", ComponentTypeName.Text)
    self.button_gold_ready = GetComponentWithPath(self.root, "Bottom/Action/ButtonGoldReady", ComponentTypeName.Button)
    self.button_goldCoin_exit = GetComponentWithPath(self.root, "Top/TopInfo/GoldCoin/ButtonExit", ComponentTypeName.Button)
    self.button_wanfashuoming = GetComponentWithPath(self.root, "Top/TopInfo/GoldCoin/Button_wanfashuoming", ComponentTypeName.Button)
    self.button_tableshop = GetComponentWithPath(self.root, "Top/TopInfo/GoldCoin/ButtonShop", ComponentTypeName.Button)

    self.text_goldCoin_tip = GetComponentWithPath(self.root, "Center/GoldCoin_tip/Text", ComponentTypeName.Text)
    self.goGold = GetComponentWithPath(self.root, "Holder/Gold", ComponentTypeName.Image).gameObject
    self.buttonCancelInstrust = GetComponentWithPath(self.root, "Intrusting/BtnCancelIntrust", ComponentTypeName.Button)

    self.ready_count_down_obj = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady/Count down", ComponentTypeName.Transform).gameObject
    self.ready_count_down_tex = GetComponentWithPath(self.root, "Bottom/Action/ButtonReady/Count down/Text", ComponentTypeName.Text)
end

function DouDiZhuTableView:setRoomInfo(roomNum, curRoundNum, totalRoundCount, wanfaName)
    self.textRoomNum.text = "房号:" .. roomNum
    self.textRoundNum.text = wanfaName .. " (第" .. curRoundNum .. "/" .. totalRoundCount .. "局)"
    self.textRoundNum.gameObject:SetActive(true)
end

function DouDiZhuTableView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    local root = seatRoot
    seatHolder.kickBtn =  GetComponentWithPath(root, "Info/KickBtn", ComponentTypeName.Button)
    local callLoardScoreHolder = {}
    callLoardScoreHolder.lordScoreRoot = GetComponentWithPath(self.root, "Center/LordScore/" .. index .. '/icon', ComponentTypeName.Transform).gameObject
    callLoardScoreHolder.lordScoreArray = {}
    for i=0,3 do
        callLoardScoreHolder.lordScoreArray[i] =  GetComponentWithPath(callLoardScoreHolder.lordScoreRoot, ''..i, ComponentTypeName.Transform).gameObject    
    end
    seatHolder.callLoardScoreHolder = callLoardScoreHolder
    seatHolder.goRechargingState = GetComponentWithPath(seatRoot, "Info/RechargeGoldRoot", ComponentTypeName.Image).gameObject

    seatHolder.imageClock_gold = GetComponentWithPath(seatRoot, "State/Group/GoldCoinClock", ComponentTypeName.Image)
    seatHolder.textClock_gold = GetComponentWithPath(seatHolder.imageClock_gold.gameObject, "Text", "TextWrap")

end

--显示踢人按钮
function DouDiZhuTableView:showKickBtns(show, ignoreLocalSeatIndex)
    if self.modelData.roleData.RoomType ~= 2 then--亲友圈快速组局
        for i,v in ipairs(self.seatHolderArray) do
            if(i == ignoreLocalSeatIndex)then
                ModuleCache.ComponentUtil.SafeSetActive(v.kickBtn.gameObject, false)
            else
                ModuleCache.ComponentUtil.SafeSetActive(v.kickBtn.gameObject, show or false)
            end
        end
    end
end

--显示叫分
function DouDiZhuTableView:playCallLordScore(localSeatIndex, show, score, withoutAnim, onFinish)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    local callLoardScoreHolder = seatHolder.callLoardScoreHolder
    ModuleCache.ComponentUtil.SafeSetActive(callLoardScoreHolder.lordScoreRoot, show or false)
    if(not show)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    for k,v in pairs(seatHolder.callLoardScoreHolder.lordScoreArray) do
        ModuleCache.ComponentUtil.SafeSetActive(v, k == score)
    end
    if(withoutAnim)then
        if(onFinish)then
            onFinish()
        end
        return
    end
    
    local sequence = self:create_sequence()
    local duration = 0.2
    local srcScale = 0.5

    callLoardScoreHolder.lordScoreRoot.transform.localScale = UnityEngine.Vector3.one * srcScale
    sequence:Append(callLoardScoreHolder.lordScoreRoot.transform:DOScale(1, duration))
    sequence:OnComplete(function ()
        if(onFinish)then
            onFinish()
        end
    end)
end

function DouDiZhuTableView:showFengDingText(show, text)
    ModuleCache.ComponentUtil.SafeSetActive(self.fengDingText.gameObject, show or false)
    if(show)then
        self.fengDingText.text = text
    end
end

--刷新座位玩家状态
function DouDiZhuTableView:refreshSeatState(seatInfo, localSeatIndex)
    View.refreshSeatState(self, seatInfo, localSeatIndex)
    localSeatIndex = localSeatIndex or seatInfo.localSeatIndex
    local seatHolder = self.seatHolderArray[localSeatIndex]
    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.goRechargingState, seatInfo.isRecharging or false)
end


function DouDiZhuTableView:flyGoldToSeat(fromLocalSeatIndex, toLocalSeatIndex, onFinish)
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
        local gold = self:genGold(originalGo, parentGo, Vector3.zero, true, true, false)
        gold.transform.parent = self.tranGoldHolder
        table.insert(goldList, gold)
    end
    self:goldFlyToSeat(goldList, targetPos, duration, 0, delayTime, true, onFinish)
end

function DouDiZhuTableView:showGoldCoinTable(showGoldCoin)
    showGoldCoin = showGoldCoin or false
    ModuleCache.ComponentUtil.SafeSetActive(self.button_goldCoin_exit.transform.parent.gameObject, showGoldCoin)
    ModuleCache.ComponentUtil.SafeSetActive(self.textRoomNum.transform.parent.parent.gameObject, not showGoldCoin)
    if(showGoldCoin)then
        self.isGoldTable = true
        self:showDeskLeftCards(false)
        self:showReadyBtn(false)
        self.showReadyBtn = self.showGoldCoinReadyBtn
        self.textBeiShu = self.text_gold_BeiShu
        self.deskLeftCardsPokerHolderArray = self.deskLeftCardsPokerHolderArray_gold
        self.goDeskLeftCardRoot = self.goDeskLeftCardRoot_gold
    end
end

--显示座位闹钟
function DouDiZhuTableView:showSeatClock(localSeatIndex, show, needShake, secs)
    local seatHolder = self.seatHolderArray[localSeatIndex]
    if(self.isGoldTable)then
        if(localSeatIndex == 1)then
            seatHolder.imageClock = seatHolder.imageClock_gold
            seatHolder.textClock = seatHolder.textClock_gold
        end
    end
    View.showSeatClock(self, localSeatIndex, show, needShake, secs)
end

--金币场提示
function DouDiZhuTableView:showGoldCoinTips(show, content)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.text_goldCoin_tip.transform.parent.gameObject, show)
    if(show)then
        self.text_goldCoin_tip.text = content
    end
end

--显示托管
function DouDiZhuTableView:showInstrustingMask(show)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonCancelInstrust.transform.parent.gameObject, show)
end

function DouDiZhuTableView:showGoldCoinReadyBtn(show)
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(self.button_gold_ready.gameObject, show)
end

--在指定范围内随机出一个点
function DouDiZhuTableView:randomPosInRect(rect)
    local leftBottom = rect.leftBottom
    local rightTop = rect.rightTop
    --math.randomseed(os.time())
    local xFactor = math.random()
    local x = leftBottom.x + (rightTop.x - leftBottom.x) * xFactor
    local yFactor = math.random()
    local y = leftBottom.y + (rightTop.y - leftBottom.y) * yFactor
    return x, y
end

function DouDiZhuTableView:randomPosByOffset(center, offset)
    local pos = center
    local xFactor = math.random()
    pos.x = pos.x + offset * (1 - xFactor * 2)
    local yFactor = math.random()
    pos.y = pos.y + offset * (1 - yFactor * 2)
    return pos
end

--随机设置物体的旋转角度
function DouDiZhuTableView:setRandomRotation(tran)
    --math.randomseed(os.time())
    local random = math.random()
    local localEulerAngles = tran.localEulerAngles
    localEulerAngles.z = random * 360
    tran.localEulerAngles = localEulerAngles
end

--飞到制定位置
function DouDiZhuTableView:flyToPos(trans, targetPos, duration, delayTime, onFinish)
    duration = duration or 0.5
    delayTime = delayTime or 0
    local sequence = self.module:create_sequence();
    local target = trans

    sequence:Append(target:DOMove(targetPos, duration, false):SetDelay(delayTime):SetEase(DG.Tweening.Ease.OutQuint))
    sequence:OnStart(function()
        ModuleCache.ComponentUtil.SafeSetActive(trans.gameObject, true)
    end)
    sequence:OnComplete(function()
        if(onFinish)then
            onFinish()
        end
    end)
end

function DouDiZhuTableView:genGold(originalGo, parentGo, localPos, needRandomRotation, randomOffset, active)
    local gold = ModuleCache.ComponentUtil.InstantiateLocal(originalGo, parentGo)
    local pos = localPos
    if(randomOffset)then
        gold.transform.localPosition = self:randomPosByOffset(localPos, 10)
    end
    if(needRandomRotation)then
        self:setRandomRotation(gold.transform)
    end
    ModuleCache.ComponentUtil.SafeSetActive(gold, active or false)
    return gold
end

function DouDiZhuTableView:goldFlyToSeat(goldList, seatPos, duration, delayTime, delayTime2, autoDestory, onFinish)
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
    local tmpDelayTime = delayTime2
    for i=1,len do
        local tmpOnFinish = nil
        if(i == len)then
            tmpOnFinish = onFinish
        end
        local gold = goldList[i]
        self:flyToPos(gold.transform, seatPos, duration, delayTime + (i - 1) * tmpDelayTime, function ()
            if(autoDestory)then
                if(gold)then
                    UnityEngine.GameObject.Destroy(gold)
                end
            end
            if(tmpOnFinish)then
                tmpOnFinish()
            end
        end)
    end

end

return  DouDiZhuTableView