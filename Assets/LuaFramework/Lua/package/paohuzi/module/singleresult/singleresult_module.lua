---
--- Created by ju.
--- DateTime: 2017/10/23 14:45
--- 小结算
---@class SingleResultModule
---@field view SingleResultView
local ModuleBase = require("core.mvvm.module_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")
local SoundManager = require("package.paohuzi.module.table.sound_manager")
local ModuleCache = ModuleCache

local SingleResultModule = Class("SingleResult", ModuleBase)
local coroutine = require("coroutine")
local curTableData


function SingleResultModule:initialize(...)
    curTableData = TableManager.phzTableData
    ModuleBase.initialize(self, "singleresult_view", nil, ...)
end

--- 设置标题
--- @param value number 1-自己赢，2-下家赢，3-上家赢
function SingleResultModule:set_title(value)
    self.view.titleImg.sprite = self.view.titleSpriteHolder:FindSpriteByName(tostring(value))
    self.view.titleImg:SetNativeSize()
end

--- 设置底牌
function SingleResultModule:set_dipai(data, mapai)
    mapai = mapai or {}
    TableUtilPaoHuZi.print("剩余牌数", #data)
    Manager.DestroyChildren(self.view.dipaiParent, self.view.dipaiSample)
    local ma_pai = mapai
    for i = 1, #ma_pai do
        local obj = Manager.CopyObject(self.view.dipaiSample)
        local text = Manager.GetText(obj, "Score")
        text.text = ma_pai[i].count
        TableUtilPaoHuZi.set_card(obj, ma_pai[i].pai, Color.New(0 / 255, 253 / 255, 23 / 255, 1), 'ZiPai_PlayCards')
        Manager.SetActive(obj, true)
    end
    
    
    for i = 1, #data do
        TableUtilPaoHuZi.print("-----", data[i])
        local obj = Manager.CopyObject(self.view.dipaiSample)
        local text = Manager.GetText(obj, "Score")
        text.text = ""
        TableUtilPaoHuZi.set_card(obj, data[i], nil, 'ZiPai_PlayCards')
        Manager.SetActive(obj, true)
    end
end




--- 设置胡牌下张
--- @param data
--- @param pai number 胡的牌
function SingleResultModule:set_xiazhang(data, pai)
    Manager.DestroyChildren(self.view.xiazhangParent, self.view.xiazhangSample)
    for i = 1, #data do
        local obj = Manager.CopyObject(self.view.xiazhangSample)
        local name = Manager.GetText(obj, "Name")
        local huxi = Manager.GetText(obj, "Huxi")
        name.text = data[i].des
        huxi.text = tostring(data[i].hu_xi)

        if AppData.Game_Name == "GLZP" then
            name.gameObject:SetActive(false)
        end

        local findTag = false
        for j = 1, 4 do
            local cardObj = Manager.FindObject(obj, "Cards/" .. tostring(j))
            if data[i].pai[j] then
                local value = data[i].pai[j]
                local status = data[i].status[j]
                if status == 0 or AppData.Game_Name ~= "GLZP" then
                    TableUtilPaoHuZi.set_card(cardObj, value, nil, 'ZiPai_PlayCards')
                else
                    TableUtilPaoHuZi.set_card(cardObj, value, Color.New(0 / 255, 253 / 255, 23 / 255, 1), 'ZiPai_PlayCards')
                end
                Manager.SetActive(cardObj, true)
                local tag = Manager.FindObject(cardObj, "Image/Hu")
                --- 约定胡的牌始终在最后一列
                if i == #data and not findTag and data[i].pai[j] == pai then
                    findTag = true
                    Manager.SetActive(tag, true)
                end
            else
                Manager.SetActive(cardObj, false)
            end
        end
        Manager.SetActive(obj, true)
    end
end

--- 设置放炮位置
--- @param value number 1-自己放炮，2-下家放炮，3-上家放炮，4-自摸
function SingleResultModule:set_pao(value)
    self.view.paoImg.sprite = self.view.paoSpriteHolder:FindSpriteByName(tostring(value))
    self.view.paoImg:SetNativeSize()
end

--- 设置胡法
function SingleResultModule:set_hufa(data, huxi)
    local str = ""
    Manager.DestroyChildren(self.view.suanfenParent, self.view.suanfenSample)
    Manager.DestroyChildren(self.view.suanfenParent1, self.view.suanfenSample1)
    

    for i = #data, 1,-1 do

        if data[i].display_position == 1 then
            str = str .. data[i].name .. "  "
        end

        if data[i].display_position == 2 then
            local obj = Manager.CopyObject(self.view.suanfenSample)
            local name = Manager.GetText(obj, "Name")
            local score = Manager.GetComponentWithPath(obj, "Score", "TextWrap")
            name.text = data[i].name
            score.text = tostring(data[i].fen)
            if not data[i].is_addition then
                score.text = "*" .. tostring(data[i].fen)
            end
            Manager.SetActive(obj, true)

            print(tostring(data[i].fen),score.text)
        end

        

        if data[i].display_position == 3 then
            local obj = Manager.CopyObject(self.view.suanfenSample1)
            local name = Manager.GetText(obj, "Name")
            local score = Manager.GetComponentWithPath(obj, "Score", "TextWrap")
            name.text = data[i].name
            score.text = tostring(data[i].fen)
            if not data[i].is_addition then
                score.text = "*" .. tostring(data[i].fen)
            end
            Manager.SetActive(obj, true)
            
        end

    end

 

    self.view.hufa.text = str
    TableUtilPaoHuZi.print("胡法", str)
end

--- 设置输赢
--- @param score number 输赢多少分
function SingleResultModule:set_win(score)
    if score == nil then
        self.view.winImg.gameObject:SetActive(false)
        return
    else
        self.view.winImg.gameObject:SetActive(true)
    end

    local str = tostring(score)
    if score > 0 then
        str = "+" .. score
    end
    self.view.winScoreRed.text = str
    self.view.winScoreGreen.text = str
    Manager.SetActive(self.view.winScoreRed.gameObject, score > 0)
    Manager.SetActive(self.view.winScoreGreen.gameObject, score <= 0)
    self.view.winImg.sprite = self.view.winSpriteHolder:FindSpriteByName(tostring(score > 0 and 1 or 2))
--self.view.winScore.text = tostring(score)
end

--- 设置将牌
--- @param value number
function SingleResultModule:set_jiang(value)
    TableUtilPaoHuZi.set_card(self.view.jiang, value, nil, 'ZiPai_PlayCards')

    if AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP' then
        self.view.jiang.gameObject:SetActive(false)
    end
end

function SingleResultModule:on_show(intentData)
    
    self:start_lua_coroutine(function()
        --self.view.root.gameObject:SetActive(true)
        self:show_fanxing()
        DataPaoHuZi.PlayerView_WaitTime = DataPaoHuZi.PlayerView_WaitTime or 0
        coroutine.wait(1)
        coroutine.wait(DataPaoHuZi.PlayerView_WaitTime)
        if #intentData.ma_pai > 0 then
            -- 如果是 有翻醒 的情况  则先翻开醒牌  之后在  打开界面
           
            for i = 1, #intentData.player do
                local localSeatID = TableUtilPaoHuZi.get_local_seat(i - 1, curTableData.SeatID, 3)
                if intentData.player[i].hu_pai > 0 then
                    TableUtilPaoHuZi.print("赢家", localSeatID)
                    
                    self.view.fanxing.transform.position = self.view.fanxingjPos[localSeatID]
                end
            end

            self.view.FanXingDongHua.gameObject:SetActive(false)
            self.view.FanXingDongHua.gameObject:SetActive(true)
            self.view.FanXingZhi.gameObject:SetActive(false)
            coroutine.wait(1.5)
            self.view.FanXingDongHua.gameObject:SetActive(false)
            local count = 0
            for i = 1, #intentData.ma_pai do
                local xingpai = intentData.ma_pai[i].pai
                count = count + intentData.ma_pai[i].count
                self:XingPaiDongHua(xingpai,count)
                if #intentData.ma_pai > 1 and i == 1 then
                    self.view.FanXingDongCHua.gameObject:SetActive(false)
                    self.view.FanXingDongCHua.gameObject:SetActive(true)
                    coroutine.wait(1.5)
                    self.view.FanXingDongCHua.gameObject:SetActive(false)
                    coroutine.wait(0.5)
                end
            end
            coroutine.wait(1)
        end
        self:show_fanxingend()
        self.view.WanFaShow.text = self:getstrByWanFa()
        self:InitPersonInfos(intentData)

        Manager.SetActive(self.view.btnNext.gameObject, not curTableData.isPlayBack and DataPaoHuZi.Msg_Table_GameStateNTFNew.result == 1)
        if self.view.btnExit then
            Manager.SetActive(self.view.btnExit.gameObject, not curTableData.isPlayBack and DataPaoHuZi.Msg_Table_GameStateNTFNew.result == 2)
        end
        Manager.SetActive(self.view.btnTotal.gameObject, not curTableData.isPlayBack and DataPaoHuZi.Msg_Table_GameStateNTFNew.result == 2)
        Manager.SetActive(self.view.btnBack.gameObject, curTableData.isPlayBack)
        local winSeat = 0
        local paoSeat = 1
        local localSeatID_i = 0
        for i = 1, #intentData.player do
            local localSeatID = TableUtilPaoHuZi.get_local_seat(i - 1, curTableData.SeatID, 3)
            if localSeatID == 1 then
                localSeatID_i = i
            end
            if intentData.player[i].hu_pai > 0 then
                TableUtilPaoHuZi.print("赢家", localSeatID)
                winSeat = localSeatID
                self:set_xiazhang(intentData.player[i].xia_zhang, intentData.player[i].hu_pai)
                self:set_hufa(intentData.player[i].HuFa, intentData.player[i].round_hu_xi)
                self.view.ZongScore.text = intentData.player[i].round_hu_xi
                self.view.ZongScoreT.text = intentData.player[i].round_hu_xi
            end
            if i - 1 == intentData.loser then
                paoSeat = localSeatID
            end
            if localSeatID == 1 then
                self:set_win(intentData.player[i].round_score)
            end
        end
        self:set_title(winSeat)
        if winSeat == 0 then
            self:show_huangzhuang()
            if AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP' then
                self:set_hufa(intentData.player[localSeatID_i].HuFa, 0)
                self:set_jiang(intentData.jiang_pai)
                self:set_xiazhang(intentData.player[localSeatID_i].xia_zhang, intentData.player[localSeatID_i].hu_pai)
                self:set_win()
            end
        else
            --- 自摸特殊处理
            if intentData.loser == 4294967295 then
                paoSeat = 4
            end
            TableUtilPaoHuZi.print("放炮Index", paoSeat, intentData.loser)
            self:set_pao(paoSeat)
            self:set_dipai(intentData.dun, intentData.ma_pai)
            self:set_jiang(intentData.jiang_pai)
        end

        local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)
        if ruleInfo.baseScore then
            
        else
            if DataPaoHuZi.Msg_Table_GameStateNTF.CurRound % curTableData.RoundCount == 0 then
                return
            end
        end
        if curTableData.isPlayBack then
            return
        end
        self:DaoJiShiAnNiu()

        self:DaoJiShi()


    end)
end

function SingleResultModule:DaoJiShiAnNiu()
    if not self.view.btnNextText then
        return
    end
    self.view.btnNextText.text = ""

    for i=1,20 do
        coroutine.wait(0.1)
        if not self.view then
            return
        end
         
        local num = 0

        if DataPaoHuZi.Msg_Table_UserStateNTF_Self then
            num = DataPaoHuZi.Msg_Table_UserStateNTF_Self.RestTime
        end

        print(num)
        if num > 1 then
            break
        end
        if i == 20 then
            return
        end
    end

    
    for i=DataPaoHuZi.Msg_Table_UserStateNTF_Self.RestTime,1,-1 do
        
        self.view.btnNextText.text = tostring(i)
        coroutine.wait(1)
        if not self.view then
            return
        end
    end
    self.view.btnNextText.text = ""
    if self.view then
        --self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
    end

end

function SingleResultModule:DaoJiShi()
    if AppData.Game_Name == "GLZP" then
        for i=5,1,-1 do
            self.view.TextDaoJiShi.text = '倒计时' .. i .. '秒'
            coroutine.wait(1)
            if not self.view then
                return
            end
        end
        self.view.TextDaoJiShi.text = ''
        self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
        ModuleCache.ModuleManager.destroy_module("paohuzi", "singleresult")
    end
end


--- 显示桌面/返回结算
function SingleResultModule:show_table(show)
    Manager.SetActive(self.view.bg, not show)
    Manager.SetActive(self.view.titleImg.gameObject, not show)
    Manager.SetActive(self.view.leftObj, not show)
    Manager.SetActive(self.view.rightObj, not show)
    Manager.SetActive(self.view.btnShow.gameObject, not show)
    Manager.SetActive(self.view.btnHide.gameObject, show)
    Manager.SetActive(self.view.FanXingDongHuaR.gameObject, show)

    if AppData.Game_Name == "GLZP" then
        Manager.SetActive(self.view.FanXingZhi.gameObject, show)
    end
end

--- 显示黄庄
function SingleResultModule:show_huangzhuang()
    Manager.SetActive(self.view.bg, false)
    Manager.SetActive(self.view.titleImg.gameObject, false)
    Manager.SetActive(self.view.leftObj, false)
    Manager.SetActive(self.view.rightObj, false)
    Manager.SetActive(self.view.btnShow.gameObject, false)
    Manager.SetActive(self.view.btnHide.gameObject, false)
    Manager.SetActive(self.view.huangzhuang, true)
    if AppData.Game_Name == "GLZP" then
        Manager.SetActive(self.view.FanXingZhi.gameObject, false)
    end

    if AppData.Game_Name == "XXZP" or AppData.Game_Name == "LDZP" then
        Manager.SetActive(self.view.bg, true)
        Manager.SetActive(self.view.titleImg.gameObject, true)
        Manager.SetActive(self.view.leftObj, true)
        Manager.SetActive(self.view.rightObj, true)
        Manager.SetActive(self.view.btnShow.gameObject, true)
        Manager.SetActive(self.view.btnHide.gameObject, false)
       
        
    end

end

-- 显示翻醒
function SingleResultModule:show_fanxing()
    Manager.SetActive(self.view.bg, false)
    Manager.SetActive(self.view.titleImg.gameObject, false)
    Manager.SetActive(self.view.leftObj, false)
    Manager.SetActive(self.view.rightObj, false)
    Manager.SetActive(self.view.btnShow.gameObject, false)
    Manager.SetActive(self.view.btnHide.gameObject, false)
    Manager.SetActive(self.view.huangzhuang, false)
    Manager.SetActive(self.view.btnNext.gameObject, false)
    if self.view.btnExit then
        Manager.SetActive(self.view.btnExit.gameObject, false)
    end
end

-- 显示翻醒结束
function SingleResultModule:show_fanxingend()
    Manager.SetActive(self.view.bg, true)
    Manager.SetActive(self.view.titleImg.gameObject, true)
    Manager.SetActive(self.view.leftObj, true)
    Manager.SetActive(self.view.rightObj, true)
    Manager.SetActive(self.view.btnShow.gameObject, true)
    Manager.SetActive(self.view.btnHide.gameObject, false)
    Manager.SetActive(self.view.huangzhuang, false)
    Manager.SetActive(self.view.btnNext.gameObject, true)
    Manager.SetActive(self.view.btnExit.gameObject, true)
end

function SingleResultModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.btnShow.gameObject then
        self:show_table(true)
    elseif obj == self.view.btnHide.gameObject then
        self:show_table(false)
    elseif obj == self.view.btnHide.gameObject then
        self:show_table(false)
    elseif obj == self.view.btnExit.gameObject then
        self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
    elseif obj == self.view.btnNext.gameObject then
        local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)

        if not ruleInfo.baseScore or DataPaoHuZi.Msg_Table_UserStateNTF_Self.Balance > ruleInfo.baseScore * 25 then
            self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
            ModuleCache.ModuleManager.destroy_module("paohuzi", "singleresult")
        else
            self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
            self:start_lua_coroutine(function ()
                DataPaoHuZi.Msg_Table_UserStateNTF_Self = nil
    
                while DataPaoHuZi.Msg_Table_UserStateNTF_Self == nil do  
                    coroutine.wait(0.1)
                    if not self.view then
                        return
                    end
                end
                if tonumber(DataPaoHuZi.Msg_Table_UserStateNTF_Self.ErrCode) == -888 then

                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，  是否立即补充金币继续游戏？ ", function()
                        
                        ModuleCache.ModuleManager.show_module("public", "goldadd")
                    end, nil, true, "确 认", "取 消")  
                else
                    ModuleCache.ModuleManager.destroy_module("paohuzi", "singleresult")
                end
            end)
        end

    elseif obj == self.view.btnTotal.gameObject then
        ModuleCache.ModuleManager.destroy_module("paohuzi", "singleresult")
        ModuleCache.ModuleManager.get_module("paohuzi", "totalresult"):show_result()
    elseif obj == self.view.btnBack.gameObject then
        ModuleCache.ModuleManager.destroy_module("paohuzi", "singleresult")
        ModuleCache.ModuleManager.destroy_module("paohuzi", "table")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
    end
end

function SingleResultModule:XingPaiDongHua(value,zhi)
    self.view.FanXingDongHuaR.gameObject:SetActive(true)
    self.view.FanXingDongHuaRImgGO.gameObject:SetActive(false)
    self.view.FanXingZhi.gameObject:SetActive(false)
    self.view.FanXingDongHuaR.transform.localPosition = UnityEngine.Vector3.New(0, 500, 0)
    for i = 1, 25 do
        coroutine.wait(0)
        if self.view == nil then
            return
        end
        self.view.FanXingDongHuaR.transform.localPosition = UnityEngine.Vector3.New(0, 400 - i * 11, 0)
    end
    self.view.FanXingDongHuaRImgGO.transform.localPosition = UnityEngine.Vector3.New(0, 0, 0)
    self.view.FanXingDongHuaRImgGO.gameObject:SetActive(true)
    TableUtilPaoHuZi.set_card(self.view.FanXingDongHuaR, value, nil, 'ZiPai_CurPutCards')
    coroutine.wait(0.5)
    self.view.FanXingZhi.gameObject:SetActive(true)
    self.view.FanXingZhiText1.text = zhi
    self.view.FanXingZhiText2.text = zhi
    coroutine.wait(1.4)
    self.view.FanXingZhi.gameObject:SetActive(false)
    self.view.FanXingDongHuaR.gameObject:SetActive(false)
end


function SingleResultModule:InitPersonInfos(data)
    local datam = DataPaoHuZi.Msg_Table_GameStateNTF
    local ScoreSettle = datam.ScoreSettle
    local ScoreSettleta = {}
    for i,v in ipairs(ScoreSettle) do
        ScoreSettleta[v.SeatID] = v.ActualAmount
    end

    for i = 1, 3 do
        self.view.personInfos[i].Go:SetActive(false)
    end
    
    for i = 1, #data.player do
        self.view.personInfos[i].Go:SetActive(true)
        local round_score = tostring(ScoreSettleta[i - 1])


        if tonumber(round_score) == nil then
            round_score = data.player[i].round_score
        end
    
        if tonumber(round_score) == nil then
            round_score = 0
        end

 
        if TableManager.phzTableData.seatUserIdInfo ~= nil then
            TableUtilPaoHuZi.download_seat_detail_info(TableManager.phzTableData.seatUserIdInfo[tostring(i - 1)],
                function(playerInfo)
                    if not self.view then
                        return
                    end
                    self.view.personInfos[i].Image.sprite = playerInfo.headImage
                    self.view.personInfos[i].Name.text =  Util.filterPlayerName(playerInfo.playerName, 10)
                end)
            self.view.personInfos[i].ScoreWin.text = round_score
			self.view.personInfos[i].ScoreLose.text = round_score
			self.view.personInfos[i].ScoreWin.gameObject:SetActive(false)
			self.view.personInfos[i].ScoreLose.gameObject:SetActive(false)
            if tonumber(round_score) > 0 then
				self.view.personInfos[i].Lv.gameObject:SetActive(true)
				self.view.personInfos[i].ScoreWin.gameObject:SetActive(true)
            else
				self.view.personInfos[i].Lv.gameObject:SetActive(false)
				self.view.personInfos[i].ScoreLose.gameObject:SetActive(true)
            end
        else
            TableUtilPaoHuZi.download_seat_detail_info(TableManager.phzTableData.players[i].userId,
                function(playerInfo)
                    self.view.personInfos[i].Image.sprite = playerInfo.headImage
                    self.view.personInfos[i].Name.text = playerInfo.playerName
                end)
            self.view.personInfos[i].ScoreWin.text = round_score
			self.view.personInfos[i].ScoreLose.text = round_score
			self.view.personInfos[i].ScoreWin.gameObject:SetActive(false)
			self.view.personInfos[i].ScoreLose.gameObject:SetActive(false)
            if tonumber(round_score) > 0 then
				self.view.personInfos[i].Lv.gameObject:SetActive(true)
				self.view.personInfos[i].ScoreWin.gameObject:SetActive(true)
            else
				self.view.personInfos[i].Lv.gameObject:SetActive(false)
				self.view.personInfos[i].ScoreLose.gameObject:SetActive(true)
            end
        end
    end
end

function SingleResultModule:getstrByWanFa()
    local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)
    
    if AppData.Game_Name == "LDZP" then
        local str = ""..ruleInfo.roundCount.."胡息结算   "


        if ruleInfo.FengDing then
            str = str .. ' 封顶' .. ruleInfo.FengDing .. '胡息   '
        end

        if ruleInfo.DaTuo == 0 then
            str = str .. '不打坨   '
        elseif ruleInfo.DaTuo == 1 then
            str = str .. '打坨   '
        end

        if ruleInfo.JiePaoFengDing == 0 and AppData.Game_Name == "LDZP" then
            str = str .. '接炮不封顶   '
        elseif ruleInfo.JiePaoFengDing == 100 and AppData.Game_Name == "LDZP" then
            str = str .. '接炮100封顶   '
        end

        if ruleInfo.DiFen then
            str = str .. '底分' .. ruleInfo.DiFen/1000 .. '   '
        end

        if ruleInfo.SeatRule == 1 then
            str = str .. '不换位   '
        elseif ruleInfo.SeatRule == 2 then
            str = str .. '每局换位   '
        end

            
        if ruleInfo.PayType ~= nil then
            if ruleInfo.PayType == 0 then
                str =str ..  '房主支付 '
            end
    
            if ruleInfo.PayType == 1 then
                str =str ..  'AA支付 '
            end
    
            if ruleInfo.PayType == 2 then
                str =str ..  '大赢家支付 '
            end
        end
    
        return str
    end




    if ruleInfo == nil or ruleInfo.HuPaiRule == nil then
        return ""
    end
    local str = ""
    str = str ..ruleInfo.HuPaiRule .. '胡起胡   '
    str = str ..ruleInfo.SettleRule ..  '胡1子   '
  
    if ruleInfo.ZiMoRule == 1 then
        str = str .. '自摸加1   '
    elseif ruleInfo.ZiMoRule == 2 then
        str = str .. '自摸翻倍   '
    end

    if ruleInfo.SeatRule == 1 then
        str = str .. '不换位   '
    elseif ruleInfo.SeatRule == 2 then
        str = str .. '每局换位   '
    end
    
    if ruleInfo.DiaoPaoRule == true then
        str = str .. '可点炮   '
    else
        str = str .. '不可点炮   '
    end
    
    if ruleInfo.ShangXingRule == true then
        str = str .. '上醒   '
    end
    
    if ruleInfo.BenXingRule == true then
        str = str .. '本醒   '
    end
    
    if ruleInfo.XiaXingRule == true then
        str = str .. '下醒   '
    end
    return str
end

function SingleResultModule:on_destroy()

end

return SingleResultModule
