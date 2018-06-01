---
--- Created by ju.
--- DateTime: 2017/10/23 14:45
--- 大结算

local ModuleBase = require("core.mvvm.module_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")

local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

local ModuleCache = ModuleCache

---@class TotalResultModule : Module
local TotalResultModule = Class("TotalResultModule", ModuleBase)


local curTableData

function TotalResultModule:initialize(...)
    curTableData = TableManager.phzTableData
    ModuleBase.initialize(self, "totalresult_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function TotalResultModule:on_module_inited()

end

-- 绑定module层的交互事件
function TotalResultModule:on_module_event_bind()
end

-- 绑定loginModel层事件，模块内交互
function TotalResultModule:on_model_event_bind()
end

function TotalResultModule:on_show(intentData)
    intentData = intentData or DataHuaPai.Msg_Table_GameStateNTF
    --- 加载时隐藏，手动调用显示函数
    Manager.SetActive(self.view.root, false)
    self:set_room_info(intentData.CurRound, intentData.starttime, intentData.endtime)
    if AppData.Game_Name == "DYZP" then
        self:set_players(intentData)

    else
        self:set_players(intentData)
    end
   
    self:setJieSanInfo()

   
end

--- 显示大结算页面
function TotalResultModule:show_result()

    Manager.SetActive(self.view.root, true)


    if DataHuaPai.Msg_Table_UserStateNTF_Self and DataHuaPai.Msg_Table_UserStateNTF_Self.Ready == true and DataHuaPai.Msg_RoomDismissedNTF ~= nil then
        Manager.SetActive(self.view.root, false)
    end

    self:start_lua_coroutine(function ()
        if ModuleCache.ShareManager().share_room_result_text then
            ModuleCache.ShareManager().share_room_result_text(self:get_result_share_data())
        end
    end)


end

--- 设置房间信息
function TotalResultModule:set_room_info(round, startTime, endTime)
    local ruleInfo1,
        ruleInfo2,
        ruleInfo3,
        ruleInfo4 = TableUtilPaoHuZi.get_rule_name(curTableData.Rule, curTableData.HallID == 0)
    self.view.roomID.text = "房号:" .. curTableData.RoomID
    self.view.wanfa.text = ruleInfo4
    
    self.view.round.text = string.format("第%d/%d局", round, curTableData.RoundCount)

    if AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP' then
        self.view.round.text = string.format("第%d局", DataHuaPai.Msg_Table_GameStateNTFNew.RealyRound)
    end

    if AppData.Game_Name == 'XXZP' then
        self.view.wanfa.text = "湘乡告胡子"
    end

    if AppData.Game_Name == 'LDZP' then
        self.view.wanfa.text = "娄底放炮罚"
    end
    
    if AppData.Game_Name == "GLZP" then
        self.view.wanfa.text = "桂林字牌"

        if round < curTableData.RoundCount then
            self.view.ButtonNext.gameObject:SetActive(false)
        end
    end

    if os.date("%Y/%m/%d %H:%M", startTime - 2208988800 - 3600 * 8) ~= nil then
        print("时间哦               ", startTime, endTime)
        self.view.startTime.text = "开始时间：" .. os.date("%Y/%m/%d %H:%M", startTime - 2208988800 - 3600 * 8)
    end

    if endTime then
        self.view.endTime.text = "结束时间：" .. os.date("%Y/%m/%d %H:%M", endTime - 2208988800 - 3600 * 8)
        
    end
end







--- 设置玩家信息
function TotalResultModule:set_players1(data)
    Manager.DestroyChildren(self.view.playersHolder)

    local maxScore = 0
    local scoreList = {}
    for i = 1, #data.player do
        scoreList[i] = data.player[i].total_score
        if maxScore < data.player[i].total_score then
            maxScore = data.player[i].total_score
        end
    end

    for i = 1, #data.player do
        --local seatID = TableUtilPaoHuZi.get_local_seat(i - 1, curTableData.SeatID, 3)
        local obj = Manager.CopyObject(self.view.item, self.view.playersHolder)
        local myBg = Manager.FindObject(obj, "bg/MyselfBg")
        Manager.SetActive(myBg, curTableData.SeatID == i - 1)

        local head = Manager.GetImage(obj, "Role/Avatar/Avatar/Image")
        local name = Manager.GetText(obj, "Role/Name/TextName")
        local id = Manager.GetText(obj, "Role/ID/TextID")
        local fangzhu = Manager.FindObject(obj, "Role/ImageRoomCreator")

      
        local dayingjia = Manager.FindObject(obj, "Role/ImageWinner")
        local win = Manager.GetText(obj, "WinTimes/value")
        local lose = Manager.GetText(obj, "LoseTimes/value")
        local ping = Manager.GetText(obj, "PingTimes/value")
        local greenScore = Manager.GetComponentWithPath(obj, "TotalScore/greenScore", "TextWrap")
        local redScore = Manager.GetComponentWithPath(obj, "TotalScore/redScore", "TextWrap")
        id.text = tostring(curTableData.seatUserIdInfo[tostring(i - 1)])
        Manager.SetActive(dayingjia, scoreList[i] ~= 0 and scoreList[i] == maxScore)
        Manager.SetActive(fangzhu, curTableData.FangZhu == i - 1)
        TableUtilPaoHuZi.download_seat_detail_info(
            curTableData.seatUserIdInfo[tostring(i - 1)],
            function(playerInfo)
                head.sprite = playerInfo.headImage
            end,
            function(playerInfo)
                name.text = Util.filterPlayerName(playerInfo.playerName, 10)
            end
        )

        --- 遍历小局记录，计算出胜利，失败和平局次数
        local winCount, loseCount, pingCount = 0, 0, 0
        for j = 1, #data.history do
            for k = 1, #data.history[j].score do
                if k == i then
                    local score = data.history[j].score[k]
                    if score > 0 then
                        winCount = winCount + 1
                    elseif score < 0 then
                        loseCount = loseCount + 1
                    else
                        pingCount = pingCount + 1
                    end
                end
            end
        end
        win.text = tostring(winCount)
        lose.text = tostring(loseCount)
        ping.text = tostring(pingCount)
        if scoreList[i] > 0 then
            Manager.SetActive(greenScore.gameObject, false)
            Manager.SetActive(redScore.gameObject, true)
            redScore.text = "+" .. scoreList[i]
        else
            Manager.SetActive(greenScore.gameObject, true)
            Manager.SetActive(redScore.gameObject, false)
            greenScore.text = tostring(scoreList[i])
        end
        Manager.SetActive(obj, true)
    end
end

--- 设置玩家信息
function TotalResultModule:set_players(data)
    --Manager.DestroyChildren(self.view.playersHolder)

    self.view.item.gameObject:SetActive(false)
    local maxScore = 0
    local scoreList = {}
    for i = 1, #data.player do
        scoreList[i] = data.player[i].total_score
        if maxScore < data.player[i].total_score then
            maxScore = data.player[i].total_score
        end
    end

    local retData = DataHuaPai.Msg_Table_UserStateNTF or {}

    local boolIsFangZhu = false
    for i = 1, #data.player do
        --local seatID = TableUtilPaoHuZi.get_local_seat(i - 1, curTableData.SeatID, 3)
        local obj = Manager.CopyObject(self.view.item, self.view.playersHolder)

        print(obj, self.view.items[i], i)

        local isDuo = false
        if data.player[i].total_piao == 1 then
            isDuo = true
        end

        local myBg = Manager.FindObject(obj, "bg/MyselfBg")
        --Manager.SetActive(myBg, curTableData.SeatID == i - 1)
        local head = Manager.GetImage(obj, "Role/Avatar/Avatar/Image")
        local name = Manager.GetText(obj, "Role/Name/TextName")
        local id = Manager.GetText(obj, "Role/ID/TextID")
        local fangzhu = Manager.FindObject(obj, "Role/ImageRoomCreator")
        local dayingjia = Manager.FindObject(obj, "Role/ImageWinner")

        local TextMingV = Manager.GetText(obj, "TextMingV")
        local TextMing = Manager.GetText(obj, "TextMing")

        local ImageRoomDuo = Manager.FindObject(obj, "Role/ImageRoomDuo")
        local ImageRoomJie = Manager.FindObject(obj, "Role/ImageRoomJie")
        local str = TextMing.text
        if AppData.Game_Name == 'GLZP' then
            if data.player[i].Is_RoomOwner == 1 and curTableData.SeatID == i - 1 then
                boolIsFangZhu = true
            end


            local str = TextMing.text
            str = string.gsub(str, "平胡", tostring(data.player[i].total_ping_hu))
            str = string.gsub(str, "自摸", tostring(data.player[i].total_zi_mo))
            str = string.gsub(str, "点炮", tostring(data.player[i].total_dian_pao))
            str = string.gsub(str, "地胡", tostring(data.player[i].total_di_hu))
            str = string.gsub(str, "总翻醒", tostring(data.player[i].total_fan_xing))
            str = string.gsub(str, "三笼五坎", tostring(data.player[i].total_san_long))
            str = string.gsub(str, "天胡", tostring(data.player[i].total_tian_hu))
            TextMingV.text = str
        end


        --optional int32 total_zi_mo			= 12;//自摸次数
        --optional int32 total_tian_hu		= 13;//天胡次数
        --optional int32 total_di_hu			= 14;//地胡次数
        --optional int32 total_san_long		= 15;//三笼五坎次数
        --optional int32 total_ping_hu		= 16;//平胡次数
        --optional int32 total_dian_pao		= 17;//点炮次数
        --optional int32 total_fan_xing		= 18;//总翻醒
        


        if AppData.Game_Name ~= 'GLZP' then
            local datas = data.player[i].balance_count
            local str1 = "<color=#7a3913>总胡息</color>  " .. '\n'
            str1 = str1 .. "<color=#7a3913>原始胡息</color>  " .. '\n'
            


            if not (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
                str1 = ""
            end
            for i=1,#datas do
                str1 = str1 .. datas[i].name .. '\n'
            end
            TextMing.text = str1




            local str1 = "<color=#7a3913>" .. data.player[i].total_score .. '</color>\n'
            str1 = str1 ..  "<color=#7a3913>" .. data.player[i].total_score .. '</color>\n'

            if not (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
                str1 ="<color=#7a3913>" .. data.player[i].total_score .. '</color>\n'
                str1 = ""
            end
            for i=1,#datas do
                str1 = str1 .. datas[i].count .. '\n'
            end
            TextMingV.text = str1

        end

        local greenScore = Manager.GetComponentWithPath(obj, "TotalScore/greenScore", "TextWrap")
        local redScore = Manager.GetComponentWithPath(obj, "TotalScore/redScore", "TextWrap")
        id.text = tostring(curTableData.seatUserIdInfo[tostring(i - 1)])
        Manager.SetActive(dayingjia, scoreList[i] ~= 0 and scoreList[i] == maxScore)
        Manager.SetActive(fangzhu, curTableData.FangZhu == i - 1)
        Manager.SetActive(fangzhu, data.player[i].Is_RoomOwner == 1)

        if ImageRoomDuo then
            Manager.SetActive(ImageRoomDuo, isDuo)
        end

        if ImageRoomJie then
            Manager.SetActive(ImageRoomJie, data.player[i].dis_user == 1)
        end
        TableUtilPaoHuZi.download_seat_detail_info(
            curTableData.seatUserIdInfo[tostring(i - 1)],
            function(playerInfo)
                head.sprite = playerInfo.headImage
            end,
            function(playerInfo)
                if name ~= nil and self.view then
                    name.text = Util.filterPlayerName(playerInfo.playerName, 10)
                    
                end
            end
        )
        local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)

        if scoreList[i] > 0 then
            Manager.SetActive(greenScore.gameObject, false)
            Manager.SetActive(redScore.gameObject, true)
            redScore.text = "+" .. scoreList[i]


            --if ruleInfo.DiFen then
            --    redScore.text = "+" .. scoreList[i]/1000
            --end

            if AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP' then
                redScore.text = "+" .. scoreList[i]/1000
            end
        else
            Manager.SetActive(greenScore.gameObject, true)
            Manager.SetActive(redScore.gameObject, false)
            greenScore.text = tostring(scoreList[i])
            --if ruleInfo.DiFen then
            --    greenScore.text = tostring(scoreList[i]/1000)
            --end
            if AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP' then
                greenScore.text = tostring(scoreList[i]/1000)
            end
        end
        Manager.SetActive(obj, true)

        obj.transform.position = self.view.items[i].transform.position
    end

    if self.view.ButtonNextText then 
        if boolIsFangZhu and (not curTableData.HallID or curTableData.HallID and curTableData.HallID == 0 or curTableData.HallID =="0") then
            self.view.ButtonNextText.text = '再玩一局'
        else
            self.view.ButtonNextText.text = '继续游戏'
        end
    end
end

function TotalResultModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.btnShare.gameObject then
        ModuleCache.ShareManager().shareImage(false)
    elseif obj == self.view.ButtonNext.gameObject then
       
        self:start_lua_coroutine(function ()

          
            self:dispatch_module_event("tablestrategy", "Event_Show_TableStrategy")
            DataHuaPai.NoJieXiGameState = true
            local selfGS = DataHuaPai.Msg_Table_UserStateNTF_Self
            DataHuaPai.Msg_Table_UserStateNTF_Self = nil
            for i=1,10 do
                coroutine.wait(0.01)
                if DataHuaPai.Msg_Table_UserStateNTF_Self then
                    break
                end
                if not self.view then
                    DataHuaPai.NoJieXiGameState = nil
                    return
                end
            end

            if DataHuaPai.Msg_Table_UserStateNTF_Self == nil then
                DataHuaPai.Msg_Table_UserStateNTF_Self = selfGS
            end

            if DataHuaPai.Msg_Table_UserStateNTF_Self == nil then
                DataHuaPai.NoJieXiGameState = nil
                return
            end
            
            DataHuaPai.NoJieXiGameState = nil
            if DataHuaPai.Msg_Table_UserStateNTF_Self.ErrCode == -11 or DataHuaPai.Msg_Table_UserStateNTF_Self.ErrCode == -23 then
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的钻石和体力都不足，是否充值？\n（体力和钻石必须有一种数量足够） ", function()
                    ModuleCache.ModuleManager.show_module("henanmj", "shop")
                end, nil, true, "确 认", "取 消")
            elseif DataHuaPai.Msg_Table_UserStateNTF_Self.ErrCode == 0 then
                ModuleCache.ModuleManager.destroy_module("huapai", "totalresult")
                if DataHuaPai.Msg_Table_UserStateNTF_Self.Ready then
                    TableManager:heartbeat_timeout_reconnect_game_server()
                end
            end
        end)

    elseif obj == self.view.btnBack.gameObject then
        self:dispatch_module_event("totalresult", "Event_RoomSetting_ExitRoom")
    end
end

function TotalResultModule:setJieSanInfo()
    if AppData.Game_Name ~= "GLZP" then
        return
    end


    self.view.textJieSan.text = ""
    if DataHuaPai.Msg_DismissNTF == nil then
        return 
    end
    local freeRoomData = DataHuaPai.Msg_DismissNTF
    for i=1,#freeRoomData.Action do
		local action = freeRoomData.Action[i]
		local playerId = curTableData.seatUserIdInfo[(i - 1) .. ""]
		TableUtilPaoHuZi.download_seat_detail_info(playerId,nil,function(playerInfo)
            if(action == 1) then
                local playerName = Util.filterPlayerName(playerInfo.playerName, 10)
                self.view.textJieSan.text = "<color=#b13a1f><color=#84590f>【" .. playerName .. "】</color>" .. "发起的解散房间   </color>"
			end
		end)
	end
end

function TotalResultModule:get_result_share_data()
    local resultData = {
        roomID = curTableData.RoomID,
        hallID = self.modelData.roleData.HallID,
    }

    if(DataHuaPai.Msg_Table_GameStateNTF.endTime)then
        resultData.endTime = os.date("%Y/%m/%d %H:%M:%S", DataHuaPai.Msg_Table_GameStateNTF.endTime)
    end

    local playerDatas = {}
    local data = DataHuaPai.Msg_Table_GameStateNTF
    for i = 1, #data.player do
        local id = tostring(curTableData.seatUserIdInfo[tostring(i - 1)])
        

        local boolFlag = false
        local name = ""
        local score = data.player[i].total_score
        TableUtilPaoHuZi.download_seat_detail_info(
            id,
            function(playerInfo)
                
            end,
            function(playerInfo)
                name = playerInfo.playerName
                boolFlag = true
            end
        )
        for i=1,300 do
            coroutine.wait(0)
            if boolFlag then
                break
            end
        end

        local tmp = {
            name,
            score,
        }

        --local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)

        if AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP' then
            tmp[2] = score / 1000
        end
        --if ruleInfo.DiFen  then
        --    tmp = {
        --        name,
        --        score/1000,
        --    }
        --end

        if(data.player[i].dis_user == 1)then
            resultData.dissRoomPlayName = name
        end

        table.insert(playerDatas,tmp)
    end
    resultData.playerDatas = playerDatas
    return resultData
end

function TotalResultModule:on_destroy()
end

return TotalResultModule
