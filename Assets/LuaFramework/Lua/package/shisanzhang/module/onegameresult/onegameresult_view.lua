--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
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
    View.initialize(self, "shisanzhang/module/onegameresult/shisanzhang_onegameresult.prefab", "ShiSanZhang_OneGameResult", 1)
    self.imageWin = GetComponentWithPath(self.root, "BaseBackground/win", ComponentTypeName.Image)
    self.imageLose = GetComponentWithPath(self.root, "BaseBackground/lose", ComponentTypeName.Image)

    self.textRoomInfo = GetComponentWithPath(self.root, "Top/TextRoomInfo", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Top/TextTime", ComponentTypeName.Text)
    self.titleSoloKill = GetComponentWithPath(self.root,"Center/Title/horLayoutGroup/TextSoloKill",ComponentTypeName.Text)
    self.titleAllKill = GetComponentWithPath(self.root,"Center/Title/horLayoutGroup/TextAllKill",ComponentTypeName.Text)
    self.titleSpadeA = GetComponentWithPath(self.root,"Center/Title/horLayoutGroup/TextSpadeA",ComponentTypeName.Text).gameObject
    self.buttonShare = GetComponentWithPath(self.root, "Bottom/BtnShare", ComponentTypeName.Button)
    self.buttonRestart = GetComponentWithPath(self.root, "Bottom/BtnRestart", ComponentTypeName.Button)
    self.specialTypeHolder = GetComponentWithPath(self.root,"SpecialTypeHolder","SpriteHolder")

    self.playerHolders = {}
    for i=1,4 do
        local holder = {}
        local root = GetComponentWithPath(self.root, "Center/Players/player"..i, ComponentTypeName.Transform).gameObject
        holder.imageBg = GetComponentWithPath(root, "bg", ComponentTypeName.Image)
        --holder.textName = GetComponentWithPath(root, "horLayoutGroup/TextName", ComponentTypeName.Text)
        holder.imageCreator = GetComponentWithPath(root, "ImageRoomCreator", ComponentTypeName.Image)
        holder.imageUpLevel = GetComponentWithPath(root, "ImageUpLevel", ComponentTypeName.Image)
        --holder.textScorePlus = GetComponentWithPath(root, "TextScorePlus", ComponentTypeName.Text)
        --holder.textScoreMinus = GetComponentWithPath(root, "TextScoreMinus", ComponentTypeName.Text)
        --holder.textPokerScoreMinus = GetComponentWithPath(root, "TextPokerMinus", ComponentTypeName.Text)
        --holder.textPokerScorePlus = GetComponentWithPath(root, "TextPokerPlus", ComponentTypeName.Text)
        --holder.textSoloKillScoreMinus = GetComponentWithPath(root, "TextSoloKillMinus", ComponentTypeName.Text)
        --holder.textSoloKillScorePlus = GetComponentWithPath(root, "TextSoloKillPlus", ComponentTypeName.Text)
        --holder.textAllKillScoreMinus = GetComponentWithPath(root, "TextAllKillMinus", ComponentTypeName.Text)
        --holder.textAllKillScorePlus = GetComponentWithPath(root, "TextAllKillPlus", ComponentTypeName.Text)
        --holder.textSpadeAScoreMinus = GetComponentWithPath(root, "TextSpadeAMinus", ComponentTypeName.Text)
        --holder.textSpadeAScorePlus = GetComponentWithPath(root, "TextSpadeAPlus", ComponentTypeName.Text)

        holder.textName = GetComponentWithPath(root, "horLayoutGroup/TextName", ComponentTypeName.Text)
        holder.TextPoker = GetComponentWithPath(root, "horLayoutGroup/TextPoker", ComponentTypeName.Text)
        holder.TextSpadeA = GetComponentWithPath(root, "horLayoutGroup/TextSpadeA", ComponentTypeName.Text)
        holder.TextSoloKill = GetComponentWithPath(root, "horLayoutGroup/TextSoloKill", ComponentTypeName.Text)
        holder.TextAllKill = GetComponentWithPath(root, "horLayoutGroup/TextAllKill", ComponentTypeName.Text)
        holder.TextScore = GetComponentWithPath(root, "horLayoutGroup/TextScore", ComponentTypeName.Text)
        holder.imageHead = GetComponentWithPath(root, "horLayoutGroup/TextName/Avatar/Mask/Image", ComponentTypeName.Image)
        holder.textSpecialType = GetComponentWithPath(root,"horLayoutGroup/TextSpecialType",ComponentTypeName.Text);
        holder.imageSpecialType = GetComponentWithPath(root,"horLayoutGroup/ImageSpecialType",ComponentTypeName.Image);

        holder.textScoreRed = GetComponentWithPath(root, "TextScoreRed", "TextWrap")
        holder.textScoreGreen = GetComponentWithPath(root, "TextScoreGreen", "TextWrap")
        --holder.imageHead = GetComponentWithPath(root, "horLayoutGroup/TextName/Avatar/Mask/Image", ComponentTypeName.Image)
        --holder.imageSpecialType = GetComponentWithPath(root,"ImageSpecialType",ComponentTypeName.Image);
        --holder.textSpecialType = GetComponentWithPath(root,"SpecialText",ComponentTypeName.Text);
        holder.goRanks = {}
        for j=1,4 do
            --holder.goRanks[j] = GetComponentWithPath(root, "rank/"..j, ComponentTypeName.Transform).gameObject
        end
        self.playerHolders[i] = holder
    end

end

function OneGameResultView:refresh_view(data)
    if self.modelData.curTableData.shisanzhang_gametype == 2 then
        self.titleSoloKill.text = "打枪"
        self.titleAllKill.text = "全垒打"
    end

    local roomInfo = data.roomInfo
    --self.textRoomInfo.text = string.format('房号:%d %s 第%d/%d局', roomInfo.roomNum, data.roomDesc or '', roomInfo.curRoundNum, roomInfo.totalRoundCount)
    --self.textTime.text = os.date("%Y-%m-%d %H:%M:%S", data.time)
    local players = data.players
    local index = 1;
    local balance = roomInfo.ruleTable.balance; --TODO 4 ：打枪翻倍   5：黑A翻倍
    if balance == 6 then
        self.titleSoloKill.gameObject:SetActive(true)
        self.titleAllKill.gameObject:SetActive(true)
        self.titleSpadeA:SetActive(true)
    elseif(balance ~= 5 and balance ~= 3) then
        self.titleSoloKill.gameObject:SetActive(true)
        self.titleAllKill.gameObject:SetActive(true)
        self.titleSpadeA:SetActive(false)
    else
        self.titleSpadeA:SetActive(true)

        self.titleSoloKill.gameObject:SetActive(false)
        if self.modelData.curTableData.shisanzhang_gametype == 2 then
            self.titleAllKill.gameObject:SetActive(true)

            --self.titleSpadeA.transform.localPosition =  Vector3.New(-82.4,-11.1,0)
        else
            self.titleAllKill.gameObject:SetActive(false)
        end


    end
    for i=1,#self.playerHolders do
        local holder = self.playerHolders[index]
        if(i <= #players) then
            local seatInfo = self:GetSeatInfoByID(roomInfo.seatInfoList,data.players[i].userID)
            print_table(roomInfo.seatInfoList)
            print_table(data.players[i])
            if(seatInfo.gameCount ~= 0) then
                
                index = index + 1
                local player = players[i]
                local playerInfo = nil;
                for j = 1,#data.roomInfo.seatInfoList do
                    if(player.userID == tonumber(data.roomInfo.seatInfoList[j].playerId)) then
                        playerInfo = data.roomInfo.seatInfoList[j].chatDataSeatHolder.playerInfo;
                    end
                end
                self:refreshPlayer(holder, player, player.userID == data.myPlayerId,playerInfo,roomInfo)
                if(player.userID == data.myPlayerId)then
                    local win = player.resultScore > 0
                    ModuleCache.ComponentUtil.SafeSetActive(self.imageWin.gameObject, win)
                    ModuleCache.ComponentUtil.SafeSetActive(self.imageLose.gameObject, not win)
                end
            end
        else
            holder.textName.text = ''
            --holder.textScorePlus.text = ''
            --holder.textScoreMinus.text = ''
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

function OneGameResultView:refreshPlayer(holder, player, isSelf,playerInfo,roomInfo)
    if self.modelData.curTableData.shisanzhang_gametype == 2 then
        self.specialTypeHolder = GetComponentWithPath(self.root, "SpecialTypeHolder_anhui", "SpriteHolder")
    end

    if(playerInfo)then
        self:setPlayerInfo(holder, playerInfo, isSelf)
    else
        self:get_userinfo(player.userID, function(err, data)
            if(err)then
                self:refreshPlayer(holder, player, isSelf)
                return
            end
            local playerInfo = {}
            playerInfo.playerId = player.userID
            playerInfo.userId = data.userID
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
    local balance = roomInfo.ruleTable.balance;--TODO 4 ：打枪翻倍   5：黑A翻倍
    --holder.textUplevel.text = player.uplevel
    --holder.textMultiple.text = player.multiple
    --player.finalScore = 0; -- 暂时写死，deng
    if(player.resultScore > 0)then
        holder.TextScore.text = '<color=#D60909FF>'..'+' .. player.resultScore..'</color>'
        --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
        --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
    elseif(player.resultScore == 0)then
        holder.TextScore.text =  '<color=#D60909FF>'.. player.resultScore..'</color>'
    else
        holder.TextScore.text = '<color=#00FF00FF>'.. player.resultScore..'</color>'
    end

    if balance == 6 then
        holder.TextSpadeA.gameObject:SetActive(true)
        holder.TextSoloKill.gameObject:SetActive(true)
        holder.TextAllKill.gameObject:SetActive(true)

        if(player.spadeAScore > 0)then
            holder.TextSpadeA.text = '<color=#FFF047FF>'..'+' .. player.spadeAScore..'</color>'
            --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
            --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
        elseif(player.spadeAScore == 0)then
            holder.TextSpadeA.text = '<color=#FFF047FF>'.. player.spadeAScore..'</color>'
        else
            holder.TextSpadeA.text = '<color=#CBDEECFF>'.. player.spadeAScore..'</color>'
        end

        if(player.killScore > 0)then
            holder.TextSoloKill.text ='<color=#FFF047FF>'..'+' .. player.killScore..'</color>'
            --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
            --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
        elseif(player.killScore == 0)then
            holder.TextSoloKill.text = '<color=#FFF047FF>'.. player.killScore..'</color>'
        else
            holder.TextSoloKill.text = '<color=#CBDEECFF>'.. player.killScore..'</color>'
        end
        if(player.allKillScore > 0)then
            holder.TextAllKill.text = '<color=#FFF047FF>'..'+' .. player.allKillScore..'</color>'
            --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
            --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
        elseif(player.allKillScore == 0)then
            holder.TextAllKill.text =  '<color=#FFF047FF>'.. player.allKillScore..'</color>'
        else
            holder.TextAllKill.text = '<color=#CBDEECFF>'.. player.allKillScore..'</color>'
        end


    elseif(balance ~= 5 and balance ~= 3) then
        holder.TextSpadeA.gameObject:SetActive(false)
        holder.TextSoloKill.gameObject:SetActive(true)
        holder.TextAllKill.gameObject:SetActive(true)

        if(player.killScore > 0)then
            holder.TextSoloKill.text ='<color=#FFF047FF>'..'+' .. player.killScore..'</color>'
            --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
            --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
        elseif(player.killScore == 0)then
            holder.TextSoloKill.text = '<color=#FFF047FF>'.. player.killScore..'</color>'
        else
            holder.TextSoloKill.text = '<color=#CBDEECFF>'.. player.killScore..'</color>'
        end
        if(player.allKillScore > 0)then
            holder.TextAllKill.text = '<color=#FFF047FF>'..'+' .. player.allKillScore..'</color>'
            --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
            --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
        elseif(player.allKillScore == 0)then
            holder.TextAllKill.text =  '<color=#FFF047FF>'.. player.allKillScore..'</color>'
        else
            holder.TextAllKill.text = '<color=#CBDEECFF>'.. player.allKillScore..'</color>'
        end
    else
        holder.TextSpadeA.gameObject:SetActive(true)
        holder.TextSoloKill.gameObject:SetActive(false)
        holder.TextAllKill.gameObject:SetActive(true)

        if(player.spadeAScore > 0)then
            holder.TextSpadeA.text = '<color=#FFF047FF>'..'+' .. player.spadeAScore..'</color>'
            --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
            --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
        elseif(player.spadeAScore == 0)then
            holder.TextSpadeA.text = '<color=#FFF047FF>'.. player.spadeAScore..'</color>'
        else
            holder.TextSpadeA.text = '<color=#CBDEECFF>'.. player.spadeAScore..'</color>'
        end
    end

    --local scorePokers = player.scoreOfPokers[1] + player.scoreOfPokers[2] + player.scoreOfPokers[3]
    if(player.finalScoreOfPokers > 0)then
        holder.TextPoker.text = '<color=#FFF047FF>'..'+' .. player.finalScoreOfPokers..'</color>'
        --holder.textUplevel.text = '<color=#F9EE60FF>'..player.uplevel..'</color>'
        --holder.textMultiple.text = '<color=#F9EE60FF>'..player.multiple..'</color>'
    elseif(player.finalScoreOfPokers == 0)then
        holder.TextPoker.text = '<color=#FFF047FF>'..player.finalScoreOfPokers..'</color>'
    else
        holder.TextPoker.text = '<color=#CBDEECFF>'.. player.finalScoreOfPokers..'</color>'
    end
    if(player.typeOfXipai[1] ~= 0) then
        local sprite = self.specialTypeHolder:FindSpriteByName(player.typeOfXipai[1])
        holder.imageSpecialType.sprite = sprite;
        holder.imageSpecialType.gameObject:SetActive(true);
    else
        holder.textSpecialType.gameObject:SetActive(true);
    end
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageBg.gameObject, isSelf or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageCreator.gameObject, player.isRoomCreator or false)
    --ModuleCache.ComponentUtil.SafeSetActive(holder.imageUpLevel.gameObject, player.uplevel > 0)
    --ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreRed.gameObject, player.score >= 0)
    --ModuleCache.ComponentUtil.SafeSetActive(holder.textScoreGreen.gameObject, player.score < 0)
    --self:showRank(holder.goRanks, player.rank)

    if balance  == 5 and self.modelData.curTableData.shisanzhang_gametype == 2 then --TODO balance 4 ：打枪翻倍   5：黑A翻倍
        if not player.allKillScore then
            holder.TextAllKill.text = "0"
        elseif(player.allKillScore > 0)then
            holder.TextAllKill.text = '+' .. player.allKillScore

        elseif(player.allKillScore == 0)then
            holder.TextAllKill.text = player.allKillScore
        else
            holder.TextAllKill.text = player.allKillScore
        end

        if(player.spadeAScore >= 0)then
            holder.TextSpadeA.text = '+' .. player.spadeAScore
        else
            holder.TextSpadeA.text = player.spadeAScore
        end
    end
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
            holder.imageHead.gameObject:SetActive(true);
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

function OneGameResultView:GetSeatInfoByID(seatInfoList,playerID)
    for i = 1,#seatInfoList do
        if(tonumber(seatInfoList[i].playerId) == tonumber(playerID)) then
            return seatInfoList[i];
        end
    end
end

return  OneGameResultView