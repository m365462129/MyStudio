--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameObject = UnityEngine.GameObject
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')

local OneGameResultView = class('oneGameResultView', View)
local ComponentUtil = ModuleCache.ComponentUtil

local Color = UnityEngine.Color
local poorObjs = {}
local gameState = nil
local xOffset = 80
local xAddOffset = 10
local xlastOffset = 20
local totalSeat = 4
local colorMj = nil
local gridScale = 0.56

function OneGameResultView:initialize(assetBundleName, mainAssetName, sortingLayer)
    View.initialize(self, assetBundleName, mainAssetName, sortingLayer)

    self.textRoomInfo = GetComponentWithPath(self.root, "Title/TextRoomInfo", ComponentTypeName.Text)
    self.textStartTime = GetComponentWithPath(self.root, "Title/TextTime", ComponentTypeName.Text)
    self.textEndTime = GetComponentWithPath(self.root, "Title/TextEndTime", ComponentTypeName.Text)

    self.playerHolders = {}
    local playerPrefabRoot = GetComponentWithPath(self.root, "Center/Players/Player1", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(playerPrefabRoot, false)
    for i=1,3 do
        local holder = {}
        local root
        root = ModuleCache.ComponentUtil.InstantiateLocal(playerPrefabRoot, playerPrefabRoot.transform.parent.gameObject)
        ModuleCache.ComponentUtil.SafeSetActive(root, true)
        self.playerHolders[i] = self:initPlayerHolder(root, i)
    end

end

function OneGameResultView:initPlayerHolder(root, index)
    local holder = {}
    holder.imageBg = GetComponentWithPath(root, "bg/MyselfBg", ComponentTypeName.Image)
    holder.textName = GetComponentWithPath(root, "Role/Name/TextName", ComponentTypeName.Text)
    holder.imageCreator = GetComponentWithPath(root, "Role/ImageRoomCreator", ComponentTypeName.Image)
    holder.textBomb = GetComponentWithPath(root, "textBomb", ComponentTypeName.Text)
    holder.textScoreRed = GetComponentWithPath(root, "TotalScore/redScore", "TextWrap")
    holder.textScoreGreen = GetComponentWithPath(root, "TotalScore/greenScore", "TextWrap")
    holder.imageHead = GetComponentWithPath(root, "Role/Avatar/Avatar/Image", ComponentTypeName.Image)
    return holder
end

function OneGameResultView:refresh_view(data)
    local roomInfo = data.roomInfo
    self.textRoomInfo.text = string.format('房号:%d %s 第%d/%d局', roomInfo.roomNum, data.roomDesc or '', roomInfo.curRoundNum, roomInfo.totalRoundCount)
    self.textStartTime.text = os.date("开始 %Y-%m-%d %H:%M:%S", data.startTime)
    self.textEndTime.text = os.date("结束 %Y-%m-%d %H:%M:%S", data.endTime)
    local players = data.players
    for i=1,#self.playerHolders do
        local holder = self.playerHolders[i]
        if(i <= #players)then
            local player = players[i]
            player.is_gold_settle = data.is_gold_settle
            self:refreshPlayer(holder, player, player.playerId == data.myPlayerId)
        else
            holder.textName.text = ''

            ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.gameObject, false)
            ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreGreen.gameObject, false)
            self:showHandPokers(holder.handPokers, {})
        end
    end
end

function OneGameResultView:refreshPlayer(holder, player, isSelf)
    if(player.playerInfo)then
        self:setPlayerInfo(holder, player.playerInfo, isSelf)
    else
        self:get_userinfo(player.playerId, function(err, data)
            if(err)then
                self:refreshPlayer(holder, player, isSelf)
                return
            end
            local playerInfo = {}
            playerInfo.playerId = player.playerId
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
            playerInfo.ip = data.ip
            player.playerInfo = playerInfo
            self:setPlayerInfo(holder, playerInfo, isSelf)
        end)
    end
    if(holder.textPlayerID)then
        holder.textPlayerID.text = 'ID:' .. player.playerId
    end
    holder.textBomb.text = player.bombCount
    if(player.score > 0)then
        holder.textScoreRed.text = '+' .. player.score
    elseif(player.score == 0)then
        holder.textScoreRed.text = player.score
    else
        holder.textScoreGreen.text = player.score
    end
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageBg.gameObject, isSelf or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.gameObject, player.score >= 0)
    ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreGreen.gameObject, player.score < 0)
end


function OneGameResultView:setPlayerInfo(holder, playerInfo, isSelf)
    if(playerInfo.playerId ~= 0)then
        local playerName = Util.filterPlayerName(playerInfo.playerName)
        holder.textName.text = playerName
        if(playerInfo.spriteHeadImage)then
            holder.imageHead.sprite = playerInfo.spriteHeadImage
            return
        end
        self:startDownLoadHeadIcon(holder.imageHead, playerInfo.headUrl, function (sprite )
            playerInfo.spriteHeadImage = sprite
        end)
    else
        holder.textPlayerName.text = Util.filterPlayerName("正在获取..")
        return
    end
end


return  OneGameResultView