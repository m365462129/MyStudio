--
-- Created by IntelliJ IDEA.
-- User: 朱腾芳
-- Date: 2016/12/7
-- Time: 18:17
-- To change this template use File | Settings | File Templates.
--
local TableModule = PaoHuZi_TableModule

local ModuleCache = ModuleCache
local ModuleManager = ModuleCache.ModuleManager

local PlayerView = require("package.paohuzi.module.table.player_view")
local CardCtrlView = require("package.paohuzi.module.table.cardctrl_view")
local HandCardView = require("package.paohuzi.module.table.handcard_view")
local SoundManager = require("package.paohuzi.module.table.sound_manager")

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")

local ComponentUtil = ModuleCache.ComponentUtil
local DoTween = DG.Tweening.DOTween

local UnityEngine = UnityEngine
local Input = UnityEngine.Input

local curTableData  -- 牌桌数据
 
local TOTAL_SEAT = 3 --               座位数


function TableModule:init_userState()
    curTableData = TableManager.phzTableData
end

--- 房间内用户上线
function TableModule:refresh_user_online(data)
    TableUtilPaoHuZi.print("房间内用户上线")
    local localSeatID = self:get_local_seat(data.SeatID)
    self.playersView[localSeatID]:show_offline(false)
end

--- 房间内用户离线
function TableModule:refresh_user_offline(data)
    TableUtilPaoHuZi.print("房间内用户离线")
    local localSeatID = self:get_local_seat(data.SeatID)
    self.playersView[localSeatID]:show_offline(true)
    self:show_start_btn()
end

function TableModule:is_all_ready()
    if not DataPaoHuZi.Msg_Table_UserStateNTF then
        return false
    end
    local num = 0
    for key, v in pairs(DataPaoHuZi.Msg_Table_UserStateNTF.State) do
        if v.UserID ~= "0" and v.UserID ~= nil and v.Ready then
            num = num + 1
        end
    end

    return num == 3
end

--- 玩家即时反馈的状态
function TableModule:refresh_report_state(data)
    if not DataPaoHuZi.Msg_Table_UserStateNTF then
        return
    end

    TableUtilPaoHuZi.print("玩家即时反馈的状态")
    local localSeatID = self:get_local_seat(data.SeatID)
    self.playersView[localSeatID]:show_leave(data.State and data.State == 1)
    self.playersView[localSeatID]:show_offline(data.State and data.State == 2)

    --print("----------------- curTableData.CurRound:", curTableData.CurRound)
    --TODO XLQ:亲友圈 允许在线玩家踢出离线玩家     data.State 用户状态信息：0、在线；1、离开（休息）；2、离线
    if DataPaoHuZi.Msg_Table_GameStateNTF == nil and curTableData.RoomType == 2 and tonumber(data.State) == 2 and (not curTableData.CurRound or (curTableData.CurRound and curTableData.CurRound ==0))  then

        self.playersView[localSeatID]:show_kick(not (self:is_all_ready() and not DataPaoHuZi.Msg_Table_GameStateNTF ))
        Manager.AddButtonListener(
        self.playersView[localSeatID].seat.kick,
        function()
            self.model:request_kick_player(curTableData.seatUserIdInfo[data.SeatID..""])
        end
        )
    end
end

function TableModule:show_start_btn()

  
    Manager.SetActive(self.view.btnStart.gameObject, false)
    Manager.SetActive(self.view.btnStartHui.gameObject, false)
    Manager.SetActive(self.view.btnStartZhunBei.gameObject, false)
    Manager.SetActive(self.view.btnStartZhunBei_museum.gameObject, false)

    if curTableData.isPlayBack then
        return
    end

    --TODO XLQ:亲友圈快速组局
    if curTableData.RoomType == 2 then
        if DataPaoHuZi.Msg_Table_UserStateNTF_Self and not DataPaoHuZi.Msg_Table_UserStateNTF_Self.Ready then
            Manager.SetActive(self.view.btnStartZhunBei_museum.gameObject,(not DataPaoHuZi.Msg_Table_GameStateNTF or DataPaoHuZi.Msg_Table_GameStateNTF.RealyRound == 0) )
        end
    end

    if self.roundStart then
        return
    end



    if not DataPaoHuZi.Msg_Table_UserStateNTF_Self then
        return
    end

    if self.view.btnStartZhunBeiText then

        -- 七星棋牌
        Manager.SetActive(self.view.btnStartZhunBei.gameObject, true)
        if DataPaoHuZi.Msg_Table_UserStateNTF_Self and DataPaoHuZi.Msg_Table_UserStateNTF_Self.Ready then
            Manager.SetActive(self.view.btnStartZhunBei.gameObject, false)
        else
            self:Init10DaoJsButton()
        end
    else

        -- 大胡棋牌游戏在任何情况下  只要自己准备了 则不显示任何与准备相关的按钮 
     

        if (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
            local num = 0
            for key, v in pairs(DataPaoHuZi.Msg_Table_UserStateNTF.State) do
                if v.UserID ~= "0" and v.UserID ~= nil and v.Ready then
                    num = num + 1
                end
            end
            local ruleInfo = TableUtilPaoHuZi.convert_rule(curTableData.Rule)

            if DataPaoHuZi.Msg_Table_UserStateNTF_Self.PiaoNum == -1 and num == 3 and ruleInfo.DaTuo == 1 then
                self.view.ShiFouDaTuo.gameObject:SetActive(true)
            end

            if num == 3 then
                self.view.btnInvite.gameObject:SetActive(false)
                self.view.btnLeave.gameObject:SetActive(false)
                return
            end
        end

      
       
        

        if AppData.Game_Name == 'DYZP' then
            Manager.SetActive(self.view.btnStart.gameObject, false)
        else
            if DataPaoHuZi.Msg_Table_UserStateNTF_Self.Ready then
                return
            end
            local data = DataPaoHuZi.Msg_Table_UserStateNTF
            local isFangZhu = data.ZhuangJia == curTableData.SeatID
            local num = DataPaoHuZi.Msg_Table_UserStateNTFNumPrep or 0
            if isFangZhu then
                if num == 2 then
                    Manager.SetActive(self.view.btnStart.gameObject, true)
                else
                    Manager.SetActive(self.view.btnStartHui.gameObject, true)
                end
            else
                if DataPaoHuZi.Msg_Table_UserStateNTF_Self and not DataPaoHuZi.Msg_Table_UserStateNTF_Self.Ready then
                    Manager.SetActive(self.view.btnStartZhunBei.gameObject, true)
                end
            end
        end
      
    end

    --TODO XLQ:亲友圈快速组局
    if curTableData.RoomType == 2 then
        Manager.SetActive(self.view.btnStart.gameObject, false)
        Manager.SetActive(self.view.btnStartHui.gameObject, false)
        Manager.SetActive(self.view.btnStartZhunBei.gameObject, false)
    end

    self:invite_friend(true)
end


--- 刷新座位信息
function TableModule:refresh_seat_info(data)
    TableUtilPaoHuZi.print("刷新座位信息")
    local localSeatID = self:get_local_seat(data.SeatID)
    self.playersView[localSeatID]:refresh_player_info(data)

    if curTableData.RoomType == 2 and data  then
        if not curTableData.isPlayBack then
            if not data.UserID or data.UserID == "0" then
                if self.view then
                    self.view.btnStartZhunBei_museum_cd_obj:SetActive(false)
                end
            end

        end
    end
    self:invite_friend(true)
end



--- 刷新用户状态
function TableModule:refresh_user_state(data)
    TableUtilPaoHuZi.print("刷新用户状态")
    for i = 1, #data.State do
        if not curTableData.isPlayBack then
            local localSeatID = self:get_local_seat(data.State[i].SeatID)
            self.playersView[localSeatID]:refresh_player_info(data.State[i])
            self.playersView[localSeatID]:show_banker(data.State[i].SeatID == data.ZhuangJia)
            self.playersView[localSeatID]:show_ready(data.State[i].Ready)
            self.playersView[localSeatID]:show_ImageDuo(data.State[i].PiaoNum == 1)

            if DataPaoHuZi.Msg_ReportStateNTF_Table and DataPaoHuZi.Msg_ReportStateNTF_Table[data.State[i].SeatID] then
                self.playersView[localSeatID]:show_leave(DataPaoHuZi.Msg_ReportStateNTF_Table[data.State[i].SeatID].State == 1)
                self.playersView[localSeatID]:show_offline(DataPaoHuZi.Msg_ReportStateNTF_Table[data.State[i].SeatID].State == 2)

            end
        end
    end
    curTableData.FangZhu = data.ZhuangJia

    local seatHolderArray = {}
    for i, v in ipairs(self.playersView) do
        seatHolderArray[i] = v.playerInfo
    end

    if self:getDangQianRenShu() < 3 then
        self.view.buttonWarning.gameObject:SetActive(false)
    else
        self.view.buttonWarning.gameObject:SetActive(true)
        self:ShowGpsInfo(true)
    end
    self:show_start_btn()


    self:begin_location(function(data)
        boolFlag = true
        data.chatType = 4
        data.address = ModuleCache.GPSManager.gpsAddress .. '.'
        if ModuleCache.GameManager.isEditor or "WindowsPlayer" == tostring(UnityEngine.Application.platform) then
            data.gps_opened = true
            data.ip = "183.1" .. os.date("%S") .. ".197.1" .. tostring(os.date("%S"))
            data.latitude = tonumber("1" ) 
            data.longitude = tonumber("2" )
            data.address = "电脑你还想看到位置吗搞笑"
        end
        self.model:request_chat(data)
    end)

    

    if not self.IsLoad_activityOrady then

        self.IsLoad_activityOrady = true
        local object = 
        {
        buttonActivity=self.view.ButtonActivity,
        spriteRedPoint = self.view.spriteRedPoint
        }
        ModuleCache.ModuleManager.show_public_module("activity", object);
    end
end


function TableModule:ShowGpsInfo(hide)
    

    local datas = {}
    datas.gameType = "paohuzi"

    local seatHolderArray = {}
    for i, v in ipairs(self.playersView) do
        seatHolderArray[i] = v.playerInfo
    end

  
    if #seatHolderArray < 3 then
        return
    end


    self.view.buttonWarning.gameObject:SetActive(true)
    datas.seatHolderArray = seatHolderArray
    ---金币场相关设置
    datas.buttonLocation = self.view.buttonWarning
    datas.isShowLocation = true


    self:start_lua_coroutine(function ()
        if hide then
            coroutine.wait(3)
        end

        local isShowPlayerInfo = ModuleCache.ModuleManager.module_is_active("henanmj", "tablelocation")
        -- 如果已经有 弹出的窗体在显示  则 不执行以下代码
        if isShowPlayerInfo then
            return
        end

        local tablelocation = ModuleCache.ModuleManager.show_module("henanmj", "tablelocation", datas)
        if hide then
            -- 是否 有作弊玩家
            local str = "打开房间了" .. curTableData.RoomID

            print(tablelocation.isHavaZuoBiPlayer)
            if tablelocation 
             and tablelocation.isHavaZuoBiPlayer 
             and tablelocation:isHavaZuoBiPlayer(seatHolderArray)
             and UnityEngine.PlayerPrefs.GetString(str) == "" then
                UnityEngine.PlayerPrefs.SetString(str, "对")
            else
                ModuleCache.ModuleManager.hide_module("henanmj", "tablelocation")
            end
        end
    end)


end

return TableModule
