local require = require
local ModuleCache = ModuleCache
local ModelData = require("package.henanmj.model.model_data")
local TableUtil = require("package.changpai.module.table.table_util")
local Manager = require("manager.function_manager")
local TableManager = require("package.henanmj.table_manager")
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
local OneGameResultView = class('oneGameResultView', View)
local xOffset = 80
local xAddOffset = 10
local xlastOffset = 20
local totalSeat = 3
local gridXoffset = 70


function OneGameResultView:initialize(...)
    View.initialize(self, "changpai/module/onegameresult/changpai_onegameresult.prefab", "ChangPai_OneGameResult", 0)
    self.imageResult = Manager.GetImage(self.root, "Top/Child/ImageTitle")
    self.imageResultSH = Manager.GetComponent(self.root, "SpriteHolder", "Top/Child/ImageTitle")
    self.cloneParent = Manager.FindObject(self.root, "Center/Clone")
    self.btnRestart = Manager.FindObject(self.root, "Bottom/Child/BtnRestart")
    self.btnShare = Manager.FindObject(self.root, "Bottom/Child/BtnShare")
    self.btnContinue = Manager.FindObject(self.root, "Bottom/Child/BtnContinue")
    self.btnLookTotal = Manager.FindObject(self.root, "Bottom/Child/BtnLookTotal")
    self.textRoomID = Manager.GetText(self.root, "TopLeft/Child/RoomID")
    self.textJuShu = Manager.GetText(self.root, "TopLeft/Child/JuShu")
    self.textWanfa = Manager.GetText(self.root, "TopLeft/Child/WanFa")

    self.textQuanHao = Manager.GetText(self.root, "TopRight/Child/QuanHao")
    self.textBeginTime = Manager.GetText(self.root, "TopRight/Child/BeginTime")
    self.textEndTime = Manager.GetText(self.root, "TopRight/Child/EndTime")

    self.MaiMaPanel = Manager.FindObject(self.root, "Bottom/Child/MaiMa")
    self.MaiMaCopyParent = Manager.FindObject(self.root, "Bottom/Child/MaiMa/vector")
    self.MaiMaCopyItem = Manager.FindObject(self.root, "Bottom/Child/MaiMa/vector/MaiMaPai")
    
    self.button_countDownTex = Manager.GetText(self.btnRestart, "Count down/Text")
    Manager.FindObject(self.btnRestart, "Image"):SetActive(TableManager.curTableData.RoomType ~= 3)
    Manager.FindObject(self.btnRestart, "Count down"):SetActive(TableManager.curTableData.RoomType == 3)
   
    self.redAtlas = Manager.GetComponent(self.root, "SpriteAtlas", "RedNumbersHolder")
    self.greenAtlas = Manager.GetComponent(self.root, "SpriteAtlas", "GreenNumbersHolder")

    self.jiangpai = {}
    self.jiangpai[1] = Manager.FindObject(self.root, "JiangPai/Layout/1")
    self.jiangpai[2] = Manager.FindObject(self.root, "JiangPai/Layout/2")

    self:initLayout()
end

function OneGameResultView:initLayout()
    local def = TableUtil.get_int_def_prefs()
    local isNew = Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT",def) == 0 -- 0:新界面 1:老界面
    if(isNew) then
        gridXoffset = 60
    else
        gridXoffset = 70
    end
end

function OneGameResultView:refresh_view(newGameState)
    self.gameState = newGameState
    self.clones = TableUtil.get_all_child(self.cloneParent)
    self.playerTrans = {}
    self.colorMj = {}
    for i = 1, 4 do
        local playerTranData = {}
        local playerTran = Manager.FindObject(self.root, "Top/Child/Player" .. i)
        if i <= TableManager.curTableData.totalSeat then
            playerTranData.xiaGrid = Manager.FindObject(playerTran, "Grid1")
            playerTranData.paiGrid = Manager.FindObject(playerTran, "Grid2")
            playerTranData.huaGrid = Manager.FindObject(playerTran, "Grid3")
            playerTranData.paiBeginPos = playerTranData.paiGrid.transform.localPosition
            playerTranData.textName = Manager.GetText(playerTran, "PlayerInfo/Text")
            playerTranData.imageHead = Manager.GetImage(playerTran, "PlayerInfo/Avatar/Mask/Image")
            playerTranData.textScore = Manager.GetComponent(playerTran, "TextWrap", "TextScore")
            playerTranData.textHuFa = Manager.GetText(playerTran, "TextFB")
            playerTranData.objeBanker = Manager.FindObject(playerTran, "ImageBanker")
            playerTranData.objPao = Manager.FindObject(playerTran, "ImagePao")
            playerTranData.objHu = Manager.FindObject(playerTran, "ImageHu")
            playerTranData.objDi = Manager.FindObject(playerTran, "ImageDi")
            playerTranData.objTuo = Manager.FindObject(playerTran, "ImageTuo")
            self.playerTrans[i] = playerTranData
            self:set_result(i)
        else
            Manager.SetActive(playerTran, false)
        end
    end

    if(self.gameState.Result == 3) then
        self.imageResult.sprite = self.imageResultSH:FindSpriteByName("1")
        Manager.SetActive(self.btnContinue, true)
        Manager.SetActive(self.btnRestart, false)
        Manager.SetActive(self.btnLookTotal, false)
        Manager.SetActive(self.btnShare, false)
    else
        local showLookTotal = self.gameState.CurRound == TableManager.curTableData.RoundCount or TableManager.curTableData.dismiss or (TableManager.curTableData.RoomType == 3 and newGameState.RestTime == 1000)
        Manager.SetActive(self.btnRestart, not showLookTotal)
        Manager.SetActive(self.btnLookTotal, showLookTotal)
        Manager.SetActive(self.btnShare, true)
        Manager.SetActive(self.btnContinue, false)

        if self.timeEventID then
            Manager.KillSmartTimer(self.timeEventID)
            self.timeEventID = nil
        end

        -- 策划需求，不直接展示总结算
        --if showLookTotal then
        --    self.timeEventID =  self:subscibe_time_event(3, false, 0):OnComplete(function(t)
        --        self.timeEventID  = nil
        --        self:show_totalgameresult_module()
        --    end).id
        --end
    end
    if(TableManager.curTableData.isPlayBack) then
        Manager.SetActive(self.btnContinue, false)
        Manager.SetActive(self.btnRestart, false)
        Manager.SetActive(self.btnLookTotal, false)
        Manager.SetActive(self.btnShare, false)
        self.textJuShu.text = ""
        self.textQuanHao.text = ""
        self.textRoomID.text = ""
        if(self.gameState.starttime and tonumber(self.gameState.starttime) > 0) then
            self.textBeginTime.text = "开始:" .. os.date("%Y/%m/%d %H:%M:%S", tonumber(self.gameState.starttime) - 2208988800 - 3600 * 8)
        else
            self.textBeginTime.text = ""
        end
        if(self.gameState.endtime and tonumber(self.gameState.endtime) > 0) then
           self.textEndTime.text = "结束:" .. os.date("%Y/%m/%d %H:%M:%S", tonumber(self.gameState.endtime) - 2208988800 - 3600 * 8)
        else
            self.textEndTime.text = ""
        end
        self.textWanfa.text =  TableUtil.get_rule_name(TableManager.curTableData.videoData.gamerule)
        if(TableManager.curTableData.videoData.roundcount) then
             if(TableManager.curTableData.RoomType == 3) then
                self.textJuShu.text = "第" .. self.gameState.CurRound .. "局"
            else
                self.textJuShu.text = "第" .. self.gameState.CurRound .. "/" .. TableManager.curTableData.videoData.roundcount .. "局"
            end
        end
        if TableManager.curTableData.videoData.roomid or TableManager.curTableData.videoData.hallnum then
            self.textRoomID.text = "房号:" ..  TableManager.curTableData.videoData.roomid
            if(TableManager.curTableData.videoData.hallnum and TableManager.curTableData.videoData.hallnum > 0) then
                self.textQuanHao.text = "圈号:"..TableManager.curTableData.videoData.hallnum
            end
        end
    else
        self:refreshRoomInfo()
    end

    if(TableManager.curTableData.RoomType == 3 and self.gameState.Result == 1) then
        if self.kickedTimeId then
            Manager.KillSmartTimer(self.kickedTimeId)
        end

        self.kickedTimeId = self:subscibe_time_event(self.gameState.RestTime, false, 1):OnUpdate(function(t)
            t = t.surplusTimeRound
            self.button_countDownTex.text = "("..t.."s)"
        end):OnComplete(function(t)
            Manager.DestroyModule("majiang", "onegameresult")
            Manager.HideModule("henanmj", "matchdialog")
        end).id
    end
    
    if TableManager.curTableData.RoomType == 3 and  self.gameState.RestTime ~= 1000 then
        Manager.ShowModule("henanmj", "matchdialog",
        {
            btnType = 1,
            infoStr = "存在同分的情况，未能决出冠亚军，需要继续进行比赛。",
        })
    end

    TableUtil.new_set_changpai(self.gameState.JiangPai[1], self.jiangpai[1], false)
    if self.gameState.JiangPai[2] and 0 ~= self.gameState.JiangPai[2] then
        TableUtil.new_set_changpai(self.gameState.JiangPai[2], self.jiangpai[2], false)
        Manager.SetActive(self.jiangpai[2], true)
    else
        Manager.SetActive(self.jiangpai[2], false)
    end
end

function OneGameResultView:refreshRoomInfo()
    self.textRoomID.text = string.format( "房号:%d", TableManager.curTableData.RoomID)
    if(self.gameState.starttime and tonumber(self.gameState.starttime) > 0) then
        self.textBeginTime.text = "开始:" .. os.date("%Y/%m/%d %H:%M:%S", tonumber(self.gameState.starttime) - 2208988800 - 3600 * 8)
    else
        self.textBeginTime.text = ""
    end
    if(self.gameState.endtime and tonumber(self.gameState.endtime) > 0) then
        self.textEndTime.text = "结束:" .. os.date("%Y/%m/%d %H:%M:%S", tonumber(self.gameState.endtime) - 2208988800 - 3600 * 8)
    else
        self.textEndTime.text = "结束:" .. os.date("%Y/%m/%d %H:%M:%S", os.time())
    end
    if(TableManager.curTableData.RoomType == 3) then
        self.textJuShu.text = "第" .. self.gameState.CurRound .. "局"
    else
        self.textJuShu.text = "第" .. self.gameState.CurRound .. "/" .. TableManager.curTableData.RoundCount .. "局"
    end

    self.textWanfa.text=  TableUtil.get_rule_name(TableManager.curTableData.Rule)
    if TableManager.curTableData.HallID and TableManager.curTableData.HallID ~=0 then
        self.textQuanHao.text = "圈号:"..TableManager.curTableData.HallID
    else
         self.textQuanHao.text =""
    end
end

function OneGameResultView:is_one_hu()
    for i=1,#self.gameState.Player do
        local playerState = self.gameState.Player[i]
        if(#playerState.HuPai ~= 0) then
            return true
        end
    end
    return false
end

function OneGameResultView:set_result(index)
    local playerState = self.gameState.Player[index]
    local playerTranData = self.playerTrans[index]
    local playerId = TableManager.curTableData.seatUserIdInfo[(index - 1) .. ""]
    local localSeat = TableUtil.get_local_seat(index - 1, TableManager.curTableData.SeatID, TableManager.curTableData.totalSeat)
    TableUtil.download_seat_detail_info(playerId, nil, function(playerInfo)
        playerTranData.textName.text = Util.filterPlayerName(playerInfo.playerName, 10)
        playerTranData.imageHead.sprite = playerInfo.headImage
    end)
    Manager.SetActive(playerTranData.objeBanker, self.gameState.ZhuangJia == index - 1)
    if playerState.BeiShu >= 0 then
        playerTranData.textScore.atlas = self.redAtlas
    else
        playerTranData.textScore.atlas = self.greenAtlas or self.redAtlas
    end
    if(playerState.BeiShu > 0) then
        playerTranData.textScore.text = "+" .. playerState.BeiShu
    else
        playerTranData.textScore.text = playerState.BeiShu .. ""
    end
    local strHuFa = ""
    for i=1,#playerState.HuFa do
        local hufa = playerState.HuFa[i]
        local addStr = ""
        if(hufa.Jia) then
            if(hufa.Fen > 0) then
                addStr =  addStr .. string.format("<color=#b13a1f>%s</color>", " +" .. hufa.Fen) 
            elseif(hufa.Fen < 0) then
                addStr = addStr .. string.format("<color=#b13a1f>%s</color>", " " .. hufa.Fen) 
            end
        else
            if(hufa.Fen ~= 1) then
                addStr = addStr .. string.format("<color=#b13a1f>%s</color>", " x" .. hufa.Fen) 
            end
        end
        strHuFa = strHuFa .. hufa.Name .. addStr .. " "
    end
    playerTranData.textHuFa.text = strHuFa
    if(localSeat == 1) then
        if(playerState.BeiShu > 0 ) then
            self.imageResult.sprite = self.imageResultSH:FindSpriteByName("2")
        elseif(playerState.BeiShu == 0 ) then
            if(self:is_one_hu()) then
                self.imageResult.sprite = self.imageResultSH:FindSpriteByName("5")
            else
                self.imageResult.sprite = self.imageResultSH:FindSpriteByName("3")
            end
        else
            self.imageResult.sprite = self.imageResultSH:FindSpriteByName("4")
        end
        self.imageResult:SetNativeSize()
    end
    Manager.SetActive(playerTranData.objPao, self.gameState.DianPao == index - 1)
    local noHu = true
    if(#playerState.HuPai ~= 0) then
        noHu = false
        Manager.SetActive(playerTranData.objHu, true)
    else
        Manager.SetActive(playerTranData.objHu, false)
    end

    local leftChildren = TableUtil.get_all_child(playerTranData.xiaGrid)
    local paiGridChildren = TableUtil.get_all_child(playerTranData.paiGrid)
    local huaChildren = TableUtil.get_all_child(playerTranData.huaGrid)

    local XiaZhangTable = {}
    for i, v in ipairs(playerState.LiaoLong) do
        local data = {}
        data.Pai = v.Pai
        data.t = 2

        XiaZhangTable[#XiaZhangTable + 1] = data
    end
    for i, v in ipairs(playerState.JiaoPai) do
        local data = {}
        data.Pai = v.Pai
        data.t = 1

        XiaZhangTable[#XiaZhangTable + 1] = data
    end
    for i, v in ipairs(playerState.XiaZhang) do
        local data = {}
        data.Pai = v.Pai

        XiaZhangTable[#XiaZhangTable + 1] = data
    end

    local leftWidth = 120/0.36 -- 缩放0.36后是120，120是玩家信息宽度
    for i = 1, #XiaZhangTable do --下张摆放位置更新
        local xiaZhangData = XiaZhangTable[i]
        if #xiaZhangData.Pai <= 4 then
            local needGray = false
            local pais = {}
            if i > #leftChildren then
                local mjT = TableUtil.poor("1_4MJ", playerTranData.xiaGrid, Vector3.New(leftWidth, 0 , 0), self.poorObjs, self.clones, Vector3.New(1, 1, 1))
                local mj = Manager.FindObject(mjT, "Pai")

                local image = Manager.GetImage(mjT, "Image")
                if xiaZhangData.t then
                    local s = Manager.GetComponent(mjT,"SpriteHolder", "Image")
                    image.sprite = s:FindSpriteByName("" .. xiaZhangData.t)
                    Manager.SetActive(image.gameObject, true)
                else
                    Manager.SetActive(image.gameObject, false)
                end

                local mjChildren = TableUtil.get_all_child(mj)
                for j = 1, #mjChildren do
                    if j <= #xiaZhangData.Pai then
                        if #xiaZhangData.Pai == 4 then
                            Manager.SetActive(mjChildren[j], true)
                            table.insert(self.colorMj, mjChildren[j])
                            local pai = xiaZhangData.Pai[j]
                            self:insert_mj_by_pai(self.colorMj, pai, mjChildren[j])
                            TableUtil.new_set_changpai(pai, mjChildren[j])
                        else -- 非杠牌，从下往上开始
                            Manager.SetActive(mjChildren[5 - j], true)
                            table.insert(self.colorMj, mjChildren[5 - j])
                            local pai = xiaZhangData.Pai[j]
                            self:insert_mj_by_pai(self.colorMj, pai, mjChildren[5 - j])
                            TableUtil.new_set_changpai(pai, mjChildren[5 - j])
                        end
                        if(j - 1 == xiaZhangData.JinZhang) then
                            if(#xiaZhangData.Pai > 2) then
                                needGray = true
                            end
                        end
                        table.insert(pais, mjChildren[j])
                    else
                        -- 理论上讲，只有else的会执行， #xiaZhangData.Pai == 4 时，所有的牌都会显示的
                        if #xiaZhangData.Pai == 4 then
                            Manager.SetActive(mjChildren[j], false)
                        else
                            Manager.SetActive(mjChildren[5 - j], false)
                        end
                    end
                end
                if(needGray) then
                    local xiaZhangSeat = TableUtil.get_local_seat(xiaZhangData.Seat, index - 1, totalSeat)
                    local mj = nil
                    if(xiaZhangSeat == 2) then
                        if(#xiaZhangData.Pai == 4) then
                            mj = pais[3]
                        else
                            mj = pais[#pais]
                        end
                    elseif(xiaZhangSeat == 3) then
                        if(#xiaZhangData.Pai == 4) then
                            mj = pais[4]
                        else
                            mj = pais[2]
                        end
                    elseif(xiaZhangSeat == 4) then
                        mj = pais[1]
                    else

                    end
                    if(mj) then
                        TableUtil.set_changpai_color(mj, Manager.Color().gray)
                    end
                end
            end
            leftWidth = leftWidth + xOffset + xAddOffset
        else
            for j = 1, #xiaZhangData.Pai do
                local mjT = TableUtil.poor("1_4MJ", playerTranData.xiaGrid, Vector3.New(leftWidth, 0 , 0), self.poorObjs, self.clones, Vector3.New(1, 1, 1))
                local mj = Manager.FindObject(mjT, "Pai")
                local showIndex = 1
                local pai = xiaZhangData.Pai[j]
                local mjChildren = TableUtil.get_all_child(mj)
                for k = 1,#mjChildren do
                    Manager.SetActive(mjChildren[k], k == showIndex)
                    if(k == showIndex) then
                        if(pai == 0) then
                            TableUtil.set_mj_bg(2, mjChildren[showIndex])
                        else
                            TableUtil.set_mj_bg(1, mjChildren[showIndex])
                        end
                        self:insert_mj_by_pai(self.colorMj, pai, mjChildren[showIndex])
                        TableUtil.new_set_changpai(pai, mjChildren[showIndex])
                        TableUtil.set_changpai_color(mjChildren[showIndex], Manager.Color().white)
                    end
                end
                leftWidth = leftWidth + xOffset
            end
            leftWidth = leftWidth + xAddOffset
        end
    end
    -- 30是间隔，0.36是grid1的缩放比例
    playerTranData.paiGrid.transform.localPosition = playerTranData.paiBeginPos + Vector3.New(leftWidth * 0.36 + 30, 0 , 0)

    for i = 1, #playerState.ShouZhang do
        local mj
        local pai = playerState.ShouZhang[i].Pai
        if i <= #paiGridChildren then
            mj = paiGridChildren[i]
            mj.transform.localPosition = Vector3.New(gridXoffset * (i - 1), 0, 0)
        else
            mj = TableUtil.poor("MJ", playerTranData.paiGrid, Vector3.New(gridXoffset * (i - 1), 0, 0), self.poorObjs, self.clones)
        end
        TableUtil.new_set_changpai(pai, mj)
        TableUtil.set_changpai_color(mj, Manager.Color().white)
        Manager.SetActive(mj, true)
        local showHu = #playerState.HuPai ~= 0 and i == #playerState.ShouZhang
        if pai == self.gameState.LaiZi then
            TableUtil.set_changpai_color(mj, Manager.Color().yellow)
        end
        if showHu then
            mj.transform.localPosition = mj.transform.localPosition + Vector3.New(xlastOffset, 0, 0)
        end
    end

    for i=1, #playerState.HuaPai do
        local mj = nil
        local pai = playerState.HuaPai[i]
        if(i <= #huaChildren) then
            mj = huaChildren[i]
        else
            mj = TableUtil.poor("MJ", playerTranData.huaGrid, Vector3.zero, self.poorObjs, self.clones, Vector3.New(1,1,1)) 
        end
        TableUtil.new_set_changpai(pai, mj)
        TableUtil.set_changpai_color(mj, Manager.Color().white)
        Manager.SetActive(mj, true)
    end
end

function OneGameResultView:insert_mj_by_pai(mjTable, pai, mj)
    local paiStr = pai .. ""
    if(not mjTable[paiStr]) then
        mjTable[paiStr] = {}
    end
    table.insert(mjTable[paiStr], mj)
end

function OneGameResultView:Init_MaiMaPanel(data) 
    self.contents = TableUtil.get_all_child(self.MaiMaCopyParent)
    local item = {}
    item[1] = nil
    for i = 2,#self.contents do
        UnityEngine.GameObject.Destroy(self.contents[i])
        item[i] = nil
    end

    self.MaiMaPanel:SetActive(true)
    
    for i = 1, #data.MaiMa do
         item[i] = TableUtil.clone(self.MaiMaCopyItem,self.MaiMaCopyParent,UnityEngine.Vector3.zero)
        TableUtil.new_set_changpai(data.MaiMa[i], item[i])
         item[i]:SetActive(true)
    end

    local idx
    for i=1, #data.ZhongMa do
        idx = data.ZhongMa[i]+1
        Manager.FindObject(item[idx], "HighLight"):SetActive(true)
    end
end

-- 显示总结算界面
function OneGameResultView:show_totalgameresult_module()
    if self.timeEventID then
        Manager.KillSmartTimer(self.timeEventID)
        self.timeEventID = nil
    end
    Manager.ShowModule("changpai", "totalgameresult")
    ModuleCache.ModuleManager.hide_module("henanmj", "dissolveroom")
end

return  OneGameResultView