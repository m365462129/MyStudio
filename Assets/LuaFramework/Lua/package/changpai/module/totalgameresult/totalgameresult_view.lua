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
local TotalGameResultView = class('totalGameResultView', View)
local ComponentUtil = ModuleCache.ComponentUtil
local curTableData = nil
local gameState = nil
local paoShouNum = 0
local totalScore = 0

function TotalGameResultView:initialize(...)
    curTableData = TableManager.curTableData
    View.initialize(self, "changpai/module/totalgameresult/changpai_totalgameresult.prefab", "ChangPai_TotalGameResult", 0)
    self.textRoomID = GetComponentWithPath(self.root, "TopLeft/Child/RoomID", ComponentTypeName.Text)
    self.textJuShu = GetComponentWithPath(self.root, "TopLeft/Child/JuShu", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "TopRight/Child/Time", ComponentTypeName.Text)
    self.textWanfa = GetComponentWithPath(self.root, "TopLeft/Child/WanFa", ComponentTypeName.Text)
    self.textQuanHao = GetComponentWithPath(self.root, "TopRight/Child/QuanHao", ComponentTypeName.Text)
    gameState = curTableData.gameState
    paoShouNum = 0
    totalScore = 0
    self.playerTrans = {}
    for i=1,4 do
        local playerTranData = {}
        local playerTran = GetComponentWithPath(self.root, "Top/Grid/Player" .. i, ComponentTypeName.Transform).gameObject
        if(i<=curTableData.totalSeat) then
            playerTranData.textName = GetComponentWithPath(playerTran, "TextName", ComponentTypeName.Text)
            playerTranData.textZiMo = GetComponentWithPath(playerTran, "ImageBg/TextZiMoTitle/Text", ComponentTypeName.Text)
            playerTranData.textJiePao = GetComponentWithPath(playerTran, "ImageBg/TextJiePaoTitle/Text", ComponentTypeName.Text)
            playerTranData.textDianPao = GetComponentWithPath(playerTran, "ImageBg/TextDianPaoTitle/Text", ComponentTypeName.Text)
            playerTranData.textAnGang = GetComponentWithPath(playerTran, "ImageBg/TextAnGangTitle/Text", ComponentTypeName.Text)
            playerTranData.textMingGang = GetComponentWithPath(playerTran, "ImageBg/TextMingGangTitle/Text", ComponentTypeName.Text)
            playerTranData.textScore = GetComponentWithPath(playerTran, "ImageTotalScore/Text", "TextWrap")
            playerTranData.textScore1 = GetComponentWithPath(playerTran, "ImageTotalScore/Text (1)", "TextWrap")
            playerTranData.objeBanker = GetComponentWithPath(playerTran, "ImageBanker", ComponentTypeName.Image).gameObject
            playerTranData.objeDisbander = GetComponentWithPath(playerTran, "ImageDisbander", ComponentTypeName.Image).gameObject
            playerTranData.imageHead = GetComponentWithPath(playerTran, "ImageHeadBg/ImageMask/ImageHead", ComponentTypeName.Image)
            playerTranData.textID =  GetComponentWithPath(playerTran, "TextID", ComponentTypeName.Text)
            playerTranData.objPaoShou = GetComponentWithPath(playerTran, "ImagePaoShou", ComponentTypeName.Image).gameObject
            playerTranData.objWin = GetComponentWithPath(playerTran, "ImageWin", ComponentTypeName.Image).gameObject
            self.playerTrans[i] = playerTranData
            self:set_result(i)
        else
            ComponentUtil.SafeSetActive(playerTran, false)
        end
    end
    for i=1,#gameState.Player do
        ComponentUtil.SafeSetActive(self.playerTrans[i].objWin, totalScore ~= 0 and gameState.Player[i].ZongBeiShu == totalScore)
        ComponentUtil.SafeSetActive(self.playerTrans[i].objeDisbander, 1 == gameState.Player[i].dis_user)
    end
    if(paoShouNum > math.ceil(gameState.CurRound * 0.5)) then
        local dianPaoPlayers = {}
        for i=1,#gameState.Player do
            if(gameState.Player[i].DiaoPaoCiShu == paoShouNum) then
                table.insert(dianPaoPlayers, i)
            end
        end
        if(#dianPaoPlayers == 1) then
            self:set_paoshou(dianPaoPlayers[1])
        else
            local minScore = 0
            for i=1,#dianPaoPlayers do
                local p = gameState.Player[dianPaoPlayers[i]]
                if(p.ZongBeiShu < minScore) then
                    minScore = p.ZongBeiShu
                end
            end
            local minScorePlayers = {}
            for i=1,#dianPaoPlayers do
                local p = gameState.Player[dianPaoPlayers[i]]
                if(p.ZongBeiShu == minScore) then
                    table.insert(minScorePlayers, dianPaoPlayers[i])
                end
            end
            local rValue = math.random(#minScorePlayers)
            self:set_paoshou(rValue)
        end
    end
    self:refreshRoomInfo()
end

function TotalGameResultView:refreshRoomInfo()
    self.textRoomID.text = string.format( "房号：%d", curTableData.RoomID)
    self.textTime.text = os.date("%Y-%m-%d %H:%M", os.time())

    if(curTableData.RoomType == 3) then
        self.textJuShu.text = "第" .. gameState.CurRound .. "局"
    else
        self.textJuShu.text = "第" .. gameState.CurRound .. "/" .. curTableData.RoundCount .. "局"
    end

    self.textRoomID.text = string.format( "房号:%d", curTableData.RoomID)
    self.textTime.text = os.date("%Y/%m/%d %H:%M", os.time())

    self.textWanfa.text=  TableUtil.get_rule_name(curTableData.Rule)
    if curTableData.HallID and curTableData.HallID ~=0 then
        self.textQuanHao.text = "圈号:"..curTableData.HallID
    else
         self.textQuanHao.text =""
    end
end

-- 设置最佳炮手
function TotalGameResultView:set_paoshou(index)
    for i=1,#gameState.Player do
        ComponentUtil.SafeSetActive(self.playerTrans[i].objPaoShou, i == index)
    end
end

function TotalGameResultView:set_result(index)
    local playerState = gameState.Player[index]
    local playerTranData = self.playerTrans[index]
    local playerId = curTableData.seatUserIdInfo[(index - 1) .. ""]
    playerTranData.textZiMo.text = playerState.ZiMoCiShu .. ""
    playerTranData.textJiePao.text = (playerState.HuPaiCiShu - playerState.ZiMoCiShu) .. ""
    playerTranData.textDianPao.text = playerState.DiaoPaoCiShu .. ""
    playerTranData.textAnGang.text = playerState.AnGangCiShu .. ""
    playerTranData.textMingGang.text = (playerState.GangPaiCiShu - playerState.AnGangCiShu) .. ""
    if(playerState.DiaoPaoCiShu > paoShouNum) then
        paoShouNum = playerState.DiaoPaoCiShu
    end

    ComponentUtil.SafeSetActive(playerTranData.textScore.gameObject, playerState.ZongBeiShu >= 0)
    ComponentUtil.SafeSetActive(playerTranData.textScore1.gameObject, playerState.ZongBeiShu < 0)
    if(playerState.ZongBeiShu >= 0) then
        playerTranData.textScore.text = "+" .. playerState.ZongBeiShu
        if(playerState.ZongBeiShu == 0) then
            playerTranData.textScore.text = playerState.ZongBeiShu
        end
    else
        playerTranData.textScore1.text = playerState.ZongBeiShu
    end
    if(playerState.ZongBeiShu > totalScore) then
        totalScore = playerState.ZongBeiShu
    end
    TableUtil.download_seat_detail_info(playerId,function(playerInfo)
        playerTranData.imageHead.sprite = playerInfo.headImage
    end,function(playerInfo)
        playerTranData.textName.text = Util.filterPlayerName(playerInfo.playerName, 10)
        playerTranData.textID.text = "ID:" .. playerId
    end)
end

return  TotalGameResultView