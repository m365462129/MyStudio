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
local View = require('package.doudizhu.module.onegameresult.base_result_view')
local cardCommon = require('package.doudizhu.module.doudizhu_table.gamelogic_common')
local OneGameResultView = class('oneGameResultView', View)

function OneGameResultView:initialize(...)
    View.initialize(self, "doudizhu/module/onegameresult/doudizhu_onegameresult.prefab", "DouDiZhu_OneGameResult", 1)
    self.buttonShare = GetComponentWithPath(self.root, "Bottom/BtnShare", ComponentTypeName.Button)
    self.buttonRestart = GetComponentWithPath(self.root, "Bottom/BtnRestart", ComponentTypeName.Button)
    self.goWin = GetComponentWithPath(self.root, "Center/Frame/Win", ComponentTypeName.Transform).gameObject
    self.goLose = GetComponentWithPath(self.root, "Center/Frame/Lose", ComponentTypeName.Transform).gameObject
    self.smallCardAssetHolder = GetComponentWithPath(self.root, "SmallCardAssetHolder", "SpriteHolder")
    self.buttonBack = GetComponentWithPath(self.root, "Bottom/GoldMatch/ButtonBack", ComponentTypeName.Button)
    self.buttonReady = GetComponentWithPath(self.root, "Bottom/GoldMatch/ButtonReady", ComponentTypeName.Button)
    self.text_leftSecs = GetComponentWithPath(self.buttonReady.gameObject, "TimeDown", ComponentTypeName.Text)
end

function OneGameResultView:initPlayerHolder(root, index)
    local holder = View.initPlayerHolder(self, root, index)
    holder.tranTagChunTian = GetComponentWithPath(root, "Tags/ChunTian", ComponentTypeName.Transform)
    holder.tranTagMingPai = GetComponentWithPath(root, "Tags/MingPai", ComponentTypeName.Transform)
    holder.imageLord = GetComponentWithPath(root, "Role/ImageLandLord", ComponentTypeName.Image)
    holder.textPlayerID = GetComponentWithPath(root, "Role/TextPlayerID", ComponentTypeName.Text)
    holder.image_played_cards_group_line_prefab = GetComponentWithPath(root, "RelationLine/Line", ComponentTypeName.Image)
    holder.image_played_cards_group_point_prefab = GetComponentWithPath(root, "RelationLine/Point", ComponentTypeName.Image)
    holder.textMultiple = GetComponentWithPath(root, "LabelMultiple", ComponentTypeName.Text)
    holder.textCoin = GetComponentWithPath(root, "GoldScore/GoldCount", ComponentTypeName.Text)

    local pokerPrefabImage = GetComponentWithPath(root, "Pokers/PokersPlayLayout/SpritePlayPoker", ComponentTypeName.Image)
    holder.dispatchedPokers = {}
    holder.dispatchedPokers_root = pokerPrefabImage.transform.parent.gameObject
    for j=1,20 do
        local pokerHolder = {}
        if(j == 1)then
            pokerHolder.root = pokerPrefabImage.gameObject
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(pokerPrefabImage.gameObject, pokerPrefabImage.transform.parent.gameObject)
        end
        pokerHolder.root.name = j
        pokerHolder.face = GetComponent(pokerHolder.root, ComponentTypeName.Image);
        holder.dispatchedPokers[j] = pokerHolder
    end

    pokerPrefabImage = GetComponentWithPath(root, "Pokers/PokersNotPlayLayout/SpriteNotPlayPoker", ComponentTypeName.Image)
    holder.handPokers = {}
    holder.handPokers_root = pokerPrefabImage.transform.parent.gameObject
    for j=1,20 do
        local pokerHolder = {}
        if(j == 1)then
            pokerHolder.root = pokerPrefabImage.gameObject
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(pokerPrefabImage.gameObject, pokerPrefabImage.transform.parent.gameObject)
        end
        pokerHolder.root.name = j
        pokerHolder.face = GetComponent(pokerHolder.root, ComponentTypeName.Image);
        holder.handPokers[j] = pokerHolder
    end
    return holder
end

function OneGameResultView:refresh_view(data)
    View.refresh_view(self, data)
    local roomInfo = data.roomInfo
    local ruleTable = roomInfo.ruleTable

    if(data.is_gold_table_settle)then
        if(ruleTable.maxbeishu == 4)then
            self.textRoomInfo.text = '4倍封顶'
        elseif(ruleTable.maxbeishu == 8)then
            self.textRoomInfo.text = '8倍封顶'
        elseif(ruleTable.maxbeishu == 0)then
            self.textRoomInfo.text = '不封顶'
        end
    else
        self.textRoomInfo.text = string.format('房号:%d 第%d/%d局', roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount)
    end

    if(data.is_gold_table_settle)then
        data.hide_restartBtn = true
        data.hide_shareBtn = true
    end
    if(data.hide_shareBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonShare.gameObject, false)
    end
    if(data.hide_restartBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonRestart.gameObject, false)
    end
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonBack.transform.parent.gameObject, data.is_gold_table_settle or false)
    if(data.is_gold_table_settle)then
        self:showReadyLeftSecs(data.auto_ready_timestamp - os.time())
    end
end

--显示座位闹钟
function OneGameResultView:showReadyLeftSecs(secs)
    if(self.clockTimeEventId)then
        CSmartTimer:Kill(self.clockTimeEventId)
        self.clockTimeEventId = nil
    end
    secs = secs or 16
    self.clockLeftSecs = secs
    self.text_leftSecs.text = self.clockLeftSecs - 1
    local timeEvent = self:subscibe_time_event(self.clockLeftSecs, false, 0):SetIntervalTime(1, function(t)
        if(self.clockLeftSecs > 0)then
            self.clockLeftSecs = self.clockLeftSecs - 1
        end
        self.text_leftSecs.text = self.clockLeftSecs
    end):OnComplete(function(t)
        self.clockTimeEventId = nil
    end)
    self.clockTimeEventId = timeEvent.id
end

function OneGameResultView:refreshPlayer(holder, player, isSelf)
    View.refreshPlayer(self, holder, player, isSelf)
    if(player.is_gold_settle)then
        ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreGreen.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(holder.textCoin.transform.parent.gameObject, true)
        local text = Util.filterPlayerGoldNum(player.coin) .. ''
        if(player.coin >= 0)then
            holder.textCoin.text = string.format('<color=#ff0000>+%s</color>', text)
        else
            holder.textCoin.text = string.format('<color=#02c714>%s</color>', text)
        end
    end
    ModuleCache.ComponentUtil.SafeSetActive(holder.tranTagChunTian.gameObject, player.spring ~= 0)
    ModuleCache.ComponentUtil.SafeSetActive(holder.tranTagMingPai.gameObject, player.show_cards ~= 0)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageLord.gameObject, player.isLord or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.handPokers_root, #player.cards > 0)
    ModuleCache.ComponentUtil.SafeSetActive(holder.dispatchedPokers_root, (player.played_cards or false) and #player.played_cards > 0)

    local multipleStr = player.multiple
    if(isSelf)then
        local score = player.score
        if(player.is_gold_settle)then
            score = player.coin
        end
        ModuleCache.ComponentUtil.SafeSetActive(self.goWin, score > 0)
        ModuleCache.ComponentUtil.SafeSetActive(self.goLose, score <= 0)
        ModuleCache.ComponentUtil.SafeSetActive(holder.imageBg.gameObject, true)
        multipleStr = string.format('<color=#fff047>%d</color>', player.multiple)
    end
    holder.textMultiple.text = multipleStr
    self:showHandPokers(holder, player.cards)
    self:showDispatchedPokers(holder, player.played_cards)
    self:subscibe_time_event(0.01, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(holder.dispatchedPokers_root.transform.parent.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(holder.dispatchedPokers_root.transform.parent.gameObject, true)
    end)
end

function OneGameResultView:showHandPokers(holder, codes)
    local handPokers = holder.handPokers
    for i=1,#handPokers do
        local pokerHolder = handPokers[i]
        if(i <= #codes)then
            local code = codes[i]
            local spriteName = self:getImageNameFromCode(code)
            pokerHolder.face.sprite = self.smallCardAssetHolder:FindSpriteByName(spriteName);
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
        end
    end
end

function OneGameResultView:showDispatchedPokers(holder, codesList)
    local dispatchedPokers = holder.dispatchedPokers
    if(not codesList)then
        return
    end
    local index = 0
    for i = 1, #codesList do
        local codes = codesList[i]
        local firstIndex
        local lastIndex
        for j = 1, #codes do
            index = index + 1
            local pokerHolder = dispatchedPokers[index]
            local code = codes[j]
            local spriteName = self:getImageNameFromCode(code)
            pokerHolder.face.sprite = self.smallCardAssetHolder:FindSpriteByName(spriteName);
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, true)
            if(j == 1)then
                firstIndex = index
            end
            if(j == #codes)then
                lastIndex = index
            end
        end
        if(lastIndex and firstIndex)then
            self:showDispatchedPokersGroup(holder, firstIndex, lastIndex)
        end
    end
end

function OneGameResultView:showDispatchedPokersGroup(holder, firstIndex, lastIndex)
    local startOffsetX = 19
    local offsetX = 30
    local startPosX = (firstIndex - 1) * offsetX + startOffsetX
    local endPosX = (lastIndex - 1) * offsetX + startOffsetX
    --print(startPosX, endPosX)
    if(firstIndex == lastIndex)then
        local point = ModuleCache.ComponentUtil.InstantiateLocal(holder.image_played_cards_group_point_prefab.gameObject, holder.image_played_cards_group_point_prefab.transform.parent.gameObject)
        ModuleCache.TransformUtil.SetX(point.transform, startPosX - 10, true)
        ModuleCache.ComponentUtil.SafeSetActive(point, true)
        return
    end
    local line = ModuleCache.ComponentUtil.InstantiateLocal(holder.image_played_cards_group_line_prefab.gameObject, holder.image_played_cards_group_line_prefab.transform.parent.gameObject)
    ModuleCache.TransformUtil.SetX(line.transform, startPosX, true)
    local lineRectTransform = GetComponent(line, ComponentTypeName.RectTransform)
    lineRectTransform.sizeDelta  = Vector2.New(endPosX - startPosX, 17)
    ModuleCache.ComponentUtil.SafeSetActive(line, true)
end

function OneGameResultView:getImageNameFromCode(code, majorCardLevel)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function OneGameResultView:getImageNameFromCard(card, majorCardLevel)
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
        if(majorCardLevel)then
           return 'xing_' .. number     
        end
        return 'hongtao_' .. number
    elseif(color == cardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == cardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end


return  OneGameResultView