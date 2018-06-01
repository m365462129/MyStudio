--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local class = require("lib.middleclass")
local View = require('package.doudizhu.module.onegameresult.base_result_view')
local TableResultView = class('oneGameResultView', View)

function TableResultView:initialize(...)
    View.initialize(self, "doudizhu/module/tableresult/doudizhu_tableresult.prefab", "DouDiZhu_TableResult", 1)
    self.buttonShare = GetComponentWithPath(self.root, "Bottom/ButtonShare", ComponentTypeName.Button)
    self.buttonBack = GetComponentWithPath(self.root, "Bottom/ButtonBack", ComponentTypeName.Button)
end

function TableResultView:initPlayerHolder(root, index)
    local holder = View.initPlayerHolder(self, root, index)
    holder.textChunTian = GetComponentWithPath(root, "textChunTian", ComponentTypeName.Text)
    holder.textMingPai = GetComponentWithPath(root, "textMingPai", ComponentTypeName.Text)
    holder.textWinTimes = GetComponentWithPath(root, "textWinTimes", ComponentTypeName.Text)
    holder.imageLord = GetComponentWithPath(root, "Role/ImageLandLord", ComponentTypeName.Image)
    holder.imageDissolver = GetComponentWithPath(root, "Role/dissolver", ComponentTypeName.Image)
    holder.goWinner = GetComponentWithPath(root, "winner", ComponentTypeName.Transform).gameObject
    holder.textId = GetComponentWithPath(root, "Role/ID/TextID", ComponentTypeName.Text)
    holder.uiStateSwitcher_goldSettle = GetComponentWithPath(root, "GoldSettle", 'UIStateSwitcher')
    holder.textGreenGoldScore = GetComponentWithPath(holder.uiStateSwitcher_goldSettle.gameObject, "GoldCoin/greenText", ComponentTypeName.Text)
    holder.textRedGoldScore = GetComponentWithPath(holder.uiStateSwitcher_goldSettle.gameObject, "GoldCoin/redText", ComponentTypeName.Text)
    holder.textRedRedPackageScore = GetComponentWithPath(holder.uiStateSwitcher_goldSettle.gameObject, "RedPackage/redText", ComponentTypeName.Text)
    holder.textGreenRedPackageScore = GetComponentWithPath(holder.uiStateSwitcher_goldSettle.gameObject, "RedPackage/greenText", ComponentTypeName.Text)
    return holder
end

function TableResultView:refresh_view(data)
    local players = data.players
    self.data = data
    local maxScore = 0
    for i = 1, #players do
        local player = players[i]
        if(player.playerId == data.free_sponsor)then
            player.isDissolver = true
        end
        if(player.totalScore > maxScore)then
            maxScore = player.totalScore
        end
    end

    if(maxScore > 0)then
        for i = 1, #players do
            local player = players[i]
            if(player.totalScore == maxScore)then
                player.isBigWinner = true
            end
        end
    end

    View.refresh_view(self, data)
end

function TableResultView:refreshPlayer(holder, player, isSelf)
    player.spring = player.spring_times
    player.show_cards = player.show_cards_times
    player.score = player.totalScore
    player.bombCount = player.bomb_cnt
    View.refreshPlayer(self, holder, player, isSelf)
    holder.textChunTian.text = player.spring or 0
    holder.textMingPai.text = player.show_cards or 0
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageLord.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageDissolver.gameObject, player.isDissolver or false)
    holder.textWinTimes.text = player.win_cnt
    holder.textId.text = 'ID:'..player.playerId
    ModuleCache.ComponentUtil.SafeSetActive(holder.goWinner, player.isBigWinner or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageCreator.gameObject, player.isRoomCreator or false)
    if(player.is_gold_settle)then
        ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.transform.parent.gameObject, false)
        ModuleCache.ComponentUtil.SafeSetActive(holder.uiStateSwitcher_goldSettle.gameObject, true)
        if(player.coin >= 0)then
            holder.textRedGoldScore.text = '+' .. player.coin
            holder.textGreenGoldScore.text = ''
        else
            holder.textGreenGoldScore.text = player.coin
            holder.textRedGoldScore.text = ''
        end
        if(player.restRedPackage == 0)then
            holder.uiStateSwitcher_goldSettle:SwitchState("Gold_Only")
        else
            holder.uiStateSwitcher_goldSettle:SwitchState("Gold_RedPackage")
            if(player.restRedPackage >= 0)then
                holder.textRedRedPackageScore.text = string.format('+%0.1f', player.restRedPackage)
                holder.textGreenRedPackageScore.text = ''
            else
                holder.textGreenRedPackageScore.text = string.format('%0.1f', player.restRedPackage)
                holder.textRedRedPackageScore.text = ''
            end
        end
    end
end

function TableResultView:setPlayerInfo(holder, playerInfo, isSelf)
    View.setPlayerInfo(self, holder, playerInfo, isSelf)
    if(playerInfo and playerInfo.playerName)then
        local data = self:get_result_share_data(self.data.players)
        if(data)then
            ModuleCache.ShareManager().share_room_result_text(data)
        end
    end
end

function TableResultView:get_result_share_data(list)
    local resultData = {
        roomID = self.data.roomInfo.roomNum,
        hallID = self.modelData.roleData.HallID,
    }

    if(self.data.startTime)then
       resultData.startTime = os.date("%Y/%m/%d %H:%M:%S", self.data.startTime)
    end
    if(self.data.endTime)then
        resultData.endTime = os.date("%Y/%m/%d %H:%M:%S", self.data.endTime)
    end

    local playerDatas = {}
    local count = #list
    for i=1,count do
        local playerResult = list[i]
        local tmp = {
            playerResult.playerId,
            playerResult.totalScore,
        }
        if(not playerResult.playerInfo)then
            return nil
        end
        tmp[1] = playerResult.playerInfo.playerName
        table.insert(playerDatas,tmp)
        if(playerResult.isDissolver)then
            resultData.dissRoomPlayName = playerResult.playerInfo.playerName
        end
    end
    resultData.playerDatas = playerDatas
    return resultData
end

return  TableResultView