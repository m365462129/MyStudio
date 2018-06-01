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
    View.initialize(self, "majiangshanxi/module/totalgameresult/henanmj_totalgameresult.prefab", "HeNanMJ_TotalGameResult", 1)
    self.textRoomID = GetComponentWithPath(self.root, "TopLeft/Child/RoomID", ComponentTypeName.Text)
    self.textJuShu = GetComponentWithPath(self.root, "TopLeft/Child/JuShu", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "TopRight/Child/Time", ComponentTypeName.Text)
    self.textWanfa = GetComponentWithPath(self.root, "TopLeft/Child/WanFa", ComponentTypeName.Text)
    self.textQuanHao = GetComponentWithPath(self.root, "TopRight/Child/QuanHao", ComponentTypeName.Text)
    gameState = curTableData.gameState
    paoShouNum = 0
    totalScore = 0

    local config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))
    local wanfaType = Config.GetWanfaIdx(curTableData.ruleJsonInfo.GameType)
    self.ConfigData = config.createRoomTable[wanfaType]

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
            playerTranData.objBanker = GetComponentWithPath(playerTran, "ImageBanker", ComponentTypeName.Image).gameObject
            playerTranData.objDiss = GetComponentWithPath(playerTran, "ImageDiss", ComponentTypeName.Image).gameObject
            playerTranData.imageHead = GetComponentWithPath(playerTran, "ImageHeadBg/ImageMask/ImageHead", ComponentTypeName.Image)
            playerTranData.textID =  GetComponentWithPath(playerTran, "TextID", ComponentTypeName.Text)
            playerTranData.objPaoShou = GetComponentWithPath(playerTran, "ImagePaoShou", ComponentTypeName.Image).gameObject
            playerTranData.objWin = GetComponentWithPath(playerTran, "ImageWin", ComponentTypeName.Image).gameObject
            playerTranData.objGoldMode = GetComponentWithPath(playerTran, "GoldMode", ComponentTypeName.Transform).gameObject
            playerTranData.objGoldSoreText1 = GetComponentWithPath(playerTran, "GoldMode/1/Text", ComponentTypeName.Text)
            playerTranData.objGoldSoreText2 = GetComponentWithPath(playerTran, "GoldMode/2/Text", ComponentTypeName.Text)
            self.playerTrans[i] = playerTranData
            self:set_result(i)
        else
            ComponentUtil.SafeSetActive(playerTran, false)
        end
    end
    for i=1,#gameState.Player do
        ComponentUtil.SafeSetActive(self.playerTrans[i].objWin, totalScore ~= 0 and gameState.Player[i].ZongBeiShu == totalScore)
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
    self:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
        ModuleCache.ShareManager().share_room_result_text(self:get_clip_board_text())
    end)
end

function TotalGameResultView:get_clip_board_text()
    if(curTableData.RoomType == 4) then
        return ""
    end

    local resultShareData = {}


    if(self.textQuanHao.text ~= "") then
        resultShareData.hallID = curTableData.HallID
    end
    resultShareData.roomID = curTableData.RoomID

    --local endTime = os.date("%Y/%m/%d %H:%M", os.time())
    --if(gameState.starttime and tonumber(gameState.starttime) > 0) then
    --    startTime = string.format("开始时间：%s\n" .. os.date("%Y/%m/%d %H:%M:%S", tonumber(gameState.starttime - 2208988800 - 3600 * 8)))
    --else
    --    startTime = ""
    --end
    --if(gameState.endtime and tonumber(gameState.endtime) > 0) then
    --    endTime = os.date("%Y/%m/%d %H:%M:%S", tonumber(gameState.endtime - 2208988800 - 3600 * 8))
    --else
    --    endTime = os.date("%Y/%m/%d %H:%M", os.time())
    --end

    local dissIndex = 0
    local dissPlayerName = ""
    for i = 1, #self.playerTrans do
        local playerTranData = self.playerTrans[i]
        if(playerTranData.objDiss.activeSelf) then
            dissIndex = i
            dissPlayerName = playerTranData.playerName
        end
    end
    if(dissIndex ~= 0) then
        resultShareData.dissRoomPlayName = dissPlayerName
    end

    resultShareData.playerDatas = {}

    for i = 1, #self.playerTrans do
        local zongbeishu = gameState.Player[i].ZongBeiShu
        if self.ConfigData.isHuangShiHH and not self.ConfigData.isDaYeKKF  then  ---黄石晃晃分数除以10用来显示小数位
            zongbeishu = zongbeishu / 10
        end
        resultShareData.playerDatas[i] = {self.playerTrans[i].playerName, zongbeishu}
    end
    return resultShareData
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
    playerTranData.playerName = "ID:" .. playerId
    playerTranData.textZiMo.text = playerState.ZiMoCiShu .. ""
    playerTranData.textJiePao.text = (playerState.HuPaiCiShu - playerState.ZiMoCiShu) .. ""
    playerTranData.textDianPao.text = playerState.DiaoPaoCiShu .. ""
    playerTranData.textAnGang.text = playerState.AnGangCiShu .. ""
    playerTranData.textMingGang.text = (playerState.GangPaiCiShu - playerState.AnGangCiShu) .. ""
    if(playerState.DiaoPaoCiShu > paoShouNum) then
        paoShouNum = playerState.DiaoPaoCiShu
    end
    playerTranData.objBanker:SetActive((playerState.Is_RoomOwner == 0 and index == 1) or playerState.Is_RoomOwner == 1)
    playerTranData.objDiss:SetActive(playerState.dis_user == 1)
    ComponentUtil.SafeSetActive(playerTranData.textScore.gameObject, playerState.ZongBeiShu >= 0)
    ComponentUtil.SafeSetActive(playerTranData.textScore1.gameObject, playerState.ZongBeiShu < 0)
    local zongbeishu = playerState.ZongBeiShu
    if self.ConfigData.isHuangShiHH and not self.ConfigData.isDaYeKKF  then  ---黄石晃晃分数除以10用来显示小数位
        zongbeishu = zongbeishu / 10
    end

    if(zongbeishu >= 0) then
        playerTranData.textScore.text = "+" .. zongbeishu
        if(zongbeishu == 0) then
            playerTranData.textScore.text = zongbeishu
        end
    else
        playerTranData.textScore1.text = zongbeishu
    end

    if(playerState.ZongBeiShu > totalScore) then
        totalScore = playerState.ZongBeiShu
    end
    TableUtil.download_seat_detail_info(playerId,function(playerInfo)
        playerTranData.imageHead.sprite = playerInfo.headImage
    end,function(playerInfo)
        playerTranData.playerName = playerInfo.playerName
        playerTranData.textName.text = Util.filterPlayerName(playerInfo.playerName, 10)
        playerTranData.textID.text = "ID:" .. playerId
    end)

    if(curTableData.ruleJsonInfo.settleType == 1) then --金币模式
        local actualGold = gameState.ScoreSettle[index].ActualAmount
        if(actualGold >= 0) then
            playerTranData.objGoldSoreText1.text = string.format("<color=#e20c0c>+%s</color>", Util.filterPlayerGoldNum(actualGold))
            if(actualGold == 0) then
                playerTranData.objGoldSoreText1.text = string.format("<color=#e20c0c>%s</color>", Util.filterPlayerGoldNum(actualGold))
            end
        else
            playerTranData.objGoldSoreText1.text = string.format("<color=#02c714>%s</color>", Util.filterPlayerGoldNum(actualGold))
        end

        local redGold = gameState.ScoreSettle[index].Amount - gameState.ScoreSettle[index].ActualAmount
        playerTranData.textScore.gameObject:SetActive(false)
        playerTranData.textScore1.gameObject:SetActive(false)
        playerTranData.objGoldMode:SetActive(true)
        if(redGold ~= 0) then
            if(redGold >= 0) then
                playerTranData.objGoldSoreText2.text = string.format("<color=#e20c0c>+%s</color>", Util.filterPlayerGoldNum(redGold / 100))
                if(redGold == 0) then
                    playerTranData.objGoldSoreText2.text = string.format("<color=#e20c0c>%s</color>", Util.filterPlayerGoldNum(redGold / 100))
                end
            else
                playerTranData.objGoldSoreText2.text = string.format("<color=#02c714>%s</color>", Util.filterPlayerGoldNum(redGold / 100))
            end
            playerTranData.objGoldSoreText2.transform.parent.gameObject:SetActive(true)
            playerTranData.objGoldSoreText1.transform.parent.localPosition = Vector3.New(playerTranData.objGoldSoreText1.transform.parent.localPosition.x, -140, 0)
        else
            playerTranData.objGoldSoreText2.transform.parent.gameObject:SetActive(false)
            playerTranData.objGoldSoreText1.transform.parent.localPosition = Vector3.New(playerTranData.objGoldSoreText1.transform.parent.localPosition.x, -171, 0)
        end
    else --积分模式
        playerTranData.objGoldMode:SetActive(false)
    end
end

function TotalGameResultView:is_banker(userid)
    return userid == curTableData.bankerUserID
end

return  TotalGameResultView