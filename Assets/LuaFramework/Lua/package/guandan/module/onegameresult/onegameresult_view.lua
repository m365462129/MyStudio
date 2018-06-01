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

function OneGameResultView:initialize(...)
    View.initialize(self, "guandan/module/onegameresult/guandan_onegameresult.prefab", "GuanDan_OneGameResult", 1)
    self.imageWin = GetComponentWithPath(self.root, "BaseBackground/win", ComponentTypeName.Image)
    self.imageLose = GetComponentWithPath(self.root, "BaseBackground/lose", ComponentTypeName.Image)

    self.textRoomInfo = GetComponentWithPath(self.root, "Top/TextRoomInfo", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Top/TextTime", ComponentTypeName.Text)

    self.buttonShare = GetComponentWithPath(self.root, "Bottom/BtnShare", ComponentTypeName.Button)
    self.buttonRestart = GetComponentWithPath(self.root, "Bottom/BtnRestart", ComponentTypeName.Button)

    self.playerHolders = {}
    for i=1,4 do
        local holder = {}
        local root = GetComponentWithPath(self.root, "Center/Players/player"..i, ComponentTypeName.Transform).gameObject
        holder.imageBg = GetComponentWithPath(root, "bg", ComponentTypeName.Image)
        holder.textName = GetComponentWithPath(root, "TextName", ComponentTypeName.Text)
        holder.imageCreator = GetComponentWithPath(root, "ImageRoomCreator", ComponentTypeName.Image)
        holder.textUplevel = GetComponentWithPath(root, "TextUplevel", ComponentTypeName.Text)
        holder.imageUpLevel = GetComponentWithPath(root, "ImageUpLevel", ComponentTypeName.Image)
        holder.textMultiple = GetComponentWithPath(root, "TextMultiple", ComponentTypeName.Text)
        holder.textScoreRed = GetComponentWithPath(root, "TextScoreRed", "TextWrap")
        holder.textScoreGreen = GetComponentWithPath(root, "TextScoreGreen", "TextWrap")
        holder.imageHead = GetComponentWithPath(root, "Avatar/Mask/Image", ComponentTypeName.Image)
        holder.goRanks = {}
        for j=1,4 do
            holder.goRanks[j] = GetComponentWithPath(root, "rank/"..j, ComponentTypeName.Transform).gameObject
        end
        self.playerHolders[i] = holder
    end

end

function OneGameResultView:refresh_view(data)
    local roomInfo = data.roomInfo
    self.textRoomInfo.text = string.format('房号:%d %s 第%d/%d局', roomInfo.roomNum, data.roomDesc or '', roomInfo.curRoundNum, roomInfo.totalRoundCount)
    self.textTime.text = os.date("%Y-%m-%d %H:%M:%S", data.time)

    local players = data.players
    for i=1,#self.playerHolders do
        local holder = self.playerHolders[i]
        if(i <= #players)then
            local player = players[i]
            self:refreshPlayer(holder, player, player.playerId == data.myPlayerId)
            if(player.playerId == data.myPlayerId)then
                local win = player.score > 0
                ModuleCache.ComponentUtil.SafeSetActive(self.imageWin.gameObject, win)
                ModuleCache.ComponentUtil.SafeSetActive(self.imageLose.gameObject, not win)
            end
        else
            holder.textName.text = ''
            holder.textUplevel.text = ''
            holder.textMultiple.text = ''
            ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.gameObject, false)
            ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreGreen.gameObject, false)
            self:showRank(holder.goRanks, -1)
        end
    end

    if(data.hide_shareBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonShare.gameObject, false)
    end
    if(data.hide_restartBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonRestart.gameObject, false)
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
    holder.textUplevel.text = player.uplevel
    holder.textMultiple.text = player.multiple
    if(player.score > 0)then
        holder.textScoreRed.text = '+' .. player.score
        holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
        holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
    elseif(player.score == 0)then
        holder.textScoreRed.text = player.score
    else
        holder.textScoreGreen.text = player.score
    end
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageBg.gameObject, isSelf or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageCreator.gameObject, player.isRoomCreator or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageUpLevel.gameObject, player.uplevel > 0)
    ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.gameObject, player.score >= 0)
    ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreGreen.gameObject, player.score < 0)
    self:showRank(holder.goRanks, player.rank)
end

function OneGameResultView:showRank(goRanks, rank)
    for i=1,#goRanks do
        if(i == rank)then
            ModuleCache.ComponentUtil.SafeSetActive(goRanks[i], true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(goRanks[i], false)
        end
    end
end


function OneGameResultView:setPlayerInfo(holder, playerInfo, isSelf)
    if(playerInfo.playerId ~= 0)then
        local playerName = Util.filterPlayerName(playerInfo.playerName)
        if(isSelf)then
            holder.textName.text = '<color=#F9EE60FF>'..playerName..'</color>'
        else
            holder.textName.text = playerName
        end
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