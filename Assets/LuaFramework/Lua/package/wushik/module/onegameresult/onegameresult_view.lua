--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local GetComponent = ModuleCache.ComponentManager.GetComponent
local class = require("lib.middleclass")
local View = require('package.wushik.module.onegameresult.base_result_view')
---@type WuShiK_CardCommon
local CardCommon = require('package.wushik.module.table.gamelogic_common')
local OneGameResultView = class('oneGameResultView', View)

function OneGameResultView:initialize(...)
    View.initialize(self, "wushik/module/onegameresult/wushik_onegameresult.prefab", "WuShiK_OneGameResult", 1)
    self.textScoreInfo = GetComponentWithPath(self.goRoot, "Title/TextScoreInfo", ComponentTypeName.Text)
    self.goBottom = GetComponentWithPath(self.root, "Bottom", ComponentTypeName.Transform).gameObject
    self.buttonShare = GetComponentWithPath(self.goBottom, "BtnShare", ComponentTypeName.Button)
    self.buttonRestart = GetComponentWithPath(self.goBottom, "BtnRestart", ComponentTypeName.Button)

    self.smallCardAssetHolder = GetComponentWithPath(self.goRoot, "CardAssetHolder", "SpriteHolder")
    self.ganTongAssetHolder = GetComponentWithPath(self.goRoot, "GanTongAssetHolder", "SpriteHolder")
end

function OneGameResultView:initPlayerHolder(root, index)
    local holder = View.initPlayerHolder(self, root, index)
    holder.imageBg_Win = GetComponentWithPath(root, "bg_win", ComponentTypeName.Image)
    holder.imageBg_Lose = GetComponentWithPath(root, "bg_lose", ComponentTypeName.Image)
    holder.imageBanker = GetComponentWithPath(root, "Role/ImageBanker", ComponentTypeName.Image)
    holder.textJianFen = GetComponentWithPath(root, "TextJianFen", ComponentTypeName.Text)
    holder.textTeamJianFen = GetComponentWithPath(root, "TextTeamJianFen", ComponentTypeName.Text)
    holder.imageRanks = {}
    for i = 1, 3 do
        holder.imageRanks[i] = GetComponentWithPath(root, "Tags/Rank/image"..i, ComponentTypeName.Image)
    end
    holder.goGanTong = GetComponentWithPath(root, "Tags/GanTong", ComponentTypeName.Transform).gameObject
    holder.goDuPai = GetComponentWithPath(root, "Tags/DuPai", ComponentTypeName.Transform).gameObject
    holder.imageGanTong = GetComponentWithPath(holder.goGanTong, "image", ComponentTypeName.Image)

    holder.image_played_cards_group_line_prefab = GetComponentWithPath(root, "RelationLine/Line", ComponentTypeName.Image)
    holder.image_played_cards_group_point_prefab = GetComponentWithPath(root, "RelationLine/Point", ComponentTypeName.Image)

    local pokerPrefabImage = GetComponentWithPath(root, "Pokers/PokersPlayLayout/SpritePlayPoker", ComponentTypeName.Image)
    holder.dispatchedPokers = self:initPlayerPokers(root, pokerPrefabImage)
    holder.dispatchedPokers_root = pokerPrefabImage.transform.parent.gameObject
    pokerPrefabImage = GetComponentWithPath(root, "Pokers/PokersNotPlayLayout/SpriteNotPlayPoker", ComponentTypeName.Image)
    holder.handPokers = self:initPlayerPokers(root, pokerPrefabImage)
    holder.handPokers_root = pokerPrefabImage.transform.parent.gameObject

    return holder
end

function OneGameResultView:initPlayerPokers(root, pokerPrefabImage)
    local pokerHolders = {}
    for j=1,27 do
        local pokerHolder = {}
        if(j == 1)then
            pokerHolder.root = pokerPrefabImage.gameObject
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(pokerPrefabImage.gameObject, pokerPrefabImage.transform.parent.gameObject)
        end
        pokerHolder.root.name = j
        pokerHolder.face = GetComponent(pokerHolder.root, ComponentTypeName.Image);
        pokerHolders[j] = pokerHolder
    end
    return pokerHolders
end

function OneGameResultView:refresh_view(data)
    View.refresh_view(self, data)
    self.textScoreInfo.text = ''
    if(data.hide_shareBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonShare.gameObject, false)
    end
    if(data.hide_restartBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonRestart.gameObject, false)
    end
end

function OneGameResultView:refreshPlayer(holder, player, isSelf)
    View.refreshPlayer(self, holder, player, isSelf)
    self:showRank(holder, player.rank)
    holder.textJianFen.text = player.jianFen
    holder.textTeamJianFen.text = player.teamJianFen
    if(player.multiple == 1 or player.multiple == 2 or player.multiple == 4)then
        ModuleCache.ComponentUtil.SafeSetActive(holder.goGanTong, true)
        local sprite = self.ganTongAssetHolder:FindSpriteByName(player.multiple .. '')
        holder.imageGanTong.sprite = sprite
    end
    ModuleCache.ComponentUtil.SafeSetActive(holder.goDuPai, player.isLord or false)
    local isWin = player.score > 0
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageBg_Win.gameObject, isWin)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageBg_Lose.gameObject, not isWin)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageBanker.gameObject, player.isBanker or false)

    self:showHandPokers(holder, player.cards)
    self:showDispatchedPokers(holder, player.played_cards)
    local isShowHandPoker = #player.cards ~= 0
    local isShowDisCards = #player.played_cards ~= 0
    ModuleCache.ComponentUtil.SafeSetActive(holder.handPokers_root.gameObject, isShowHandPoker)
    ModuleCache.ComponentUtil.SafeSetActive(holder.dispatchedPokers_root.gameObject, isShowDisCards)
    self:subscibe_time_event(0.01, false, 0):OnComplete(function(t)
        ModuleCache.ComponentUtil.SafeSetActive(holder.dispatchedPokers_root.transform.parent.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(holder.dispatchedPokers_root.transform.parent.gameObject, true)
    end)
end

function OneGameResultView:showRank(holder, rank)
    for i = 1, #holder.imageRanks do
        local imageRank = holder.imageRanks[i]
        ModuleCache.ComponentUtil.SafeSetActive(imageRank.gameObject, rank == i)
    end
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
    local startOffsetX = 9
    local offsetX = 21.3
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
    local posY = line.transform.localPosition.y
    local scaleX = line.transform.localScale.x
    local lineRectTransform = GetComponent(line, ComponentTypeName.RectTransform)

    lineRectTransform.sizeDelta  = Vector2.New((endPosX - startPosX) / scaleX, 17)
    ModuleCache.TransformUtil.SetX(line.transform, startPosX, true)
    ModuleCache.TransformUtil.SetY(line.transform, posY, true)
    ModuleCache.ComponentUtil.SafeSetActive(line, true)
end

function OneGameResultView:getImageNameFromCode(code, majorCardLevel)
    local card = CardCommon.solveCard(code)
    card.code = code
    return self:getImageNameFromCard(card, majorCardLevel)
end

function OneGameResultView:getImageNameFromCard(card, majorCardLevel)
    local color = card.color
    local number = card.name
    local code = card.code
    if(CardCommon.isLittleKingCard(code))then
        return 'little_boss'
    elseif(CardCommon.isBigKingCard(code))then
        return 'big_boss'
    end


    if(color == CardCommon.color_black_heart)then
        return 'heitao_' .. number
    elseif(color == CardCommon.color_red_heart)then
        if(majorCardLevel)then
            return 'xing_' .. number
        end
        return 'hongtao_' .. number
    elseif(color == CardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == CardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end

return  OneGameResultView