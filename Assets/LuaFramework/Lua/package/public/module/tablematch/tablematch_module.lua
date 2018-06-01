-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableMatchModule = class("Public.TableMatchModule", ModuleBase)
local TableManager = TableManager
-- 常用模块引用
local ModuleCache = ModuleCache
local MatchingManager = require("package.public.matching_manager")
local CSmartTimer = ModuleCache.SmartTimer.instance
function TableMatchModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "tablematch_view", "tablematch_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function TableMatchModule:on_module_inited()

end

function TableMatchModule:on_update()
    if ((not self.lastPingTime) or (self.lastPingTime + 3 < Time.realtimeSinceStartup)) then
        self.lastPingTime = Time.realtimeSinceStartup
        if (TableManager.loginClientConnected) then
            TableManager:request_ping()
        end
    end
    if TableManager.loginClientConnected and self.modelData.loginClient and self.modelData.loginClient.clientConnected and (self.modelData.loginClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
        TableManager:heartbeat_timeout_reconnect_login_server()
        ModuleCache.GameManager.logout();
    end
end

function TableMatchModule:on_update_per_second()
    if self.view and self.modelData.hallData and not self.haveEnter then
        self.view.textTime.text = os.date("%H:%M", os.time())
        --print("延迟", TableManager.lastPingReqeustTime, TableManager.pingDelayTime  )
        if (TableManager.lastPingReqeustTime) then
            local delaytime = UnityEngine.Time.realtimeSinceStartup - TableManager.lastPingReqeustTime
            self.view:show_ping_delay(true, delaytime)
            if delaytime > 10 then
                self:reconnect_deal()
            else
                self.reconnectTimes = 0
            end
        elseif (TableManager.pingDelayTime) then
            self.view:show_ping_delay(true, TableManager.pingDelayTime)
            if TableManager.pingDelayTime > 10 then
                self:reconnect_deal()
            else
                self.reconnectTimes = 0
            end
        else
            self.reconnectTimes = 0
            self.view:show_ping_delay(true, 0.05)
        end
    end
end

function TableMatchModule:reconnect_deal()
    print("重连", self.reconnectTimes, TableManager.connecting, TableManager.loginClientConnected)

    if not self.reconnectTimes or self.reconnectTimes == 0 then
        --第一次无条件重连
        self:reconnet_match()
        if self.reconnectTimes then
            self.reconnectTimes = self.reconnectTimes + 1
        else
            self.reconnectTimes = 1
        end
    elseif self.reconnectTimes < 7 then
        if not TableManager.connecting and not TableManager.loginClientConnected then
            self:reconnet_match()
            if self.reconnectTimes then
                self.reconnectTimes = self.reconnectTimes + 1
            else
                self.reconnectTimes = 1
            end
        end
    else
        ModuleCache.GameManager.logout();
    end
end

-- 绑定module层的交互事件
function TableMatchModule:on_module_event_bind()
    self:subscibe_package_event("Event_GoldMatching_Quit", function(eventHead, eventData)
        ModuleCache.ModuleManager.destroy_module("public", "tablematch")
        self:dispatch_package_event("Event_GoldJump_error")
        if (TableManager.loginClientConnected) then
            TableManager:disconnect_login_server()
        end
        --local hall = ModuleCache.ModuleManager.get_module("henanmj", "hall")
        --if not hall then
        --    ModuleCache.ModuleManager.show_module("henanmj", "hall")
        --end

        ModuleCache.ModuleManager.show_module("henanmj","hall")
        ModuleCache.ModuleManager.show_module("public","goldentrance")
    end)

    self:subscibe_package_event("Event_Have_Enter_Table", function()
        print("收到下销毁匹配界面通知")
        ModuleCache.ModuleManager.destroy_module("public", "tablematch")
    end)

    self:subscibe_package_event("Event_GoldMatching_Notify_RoomInfo", function(eventHead, eventData)
        print_table(eventData, "Event_GoldMatching_Notify_RoomInfo")
        self.view:update_player(eventData.Players)
        if (eventData.RoomID and eventData.RoomID ~= 0) then
            if (TableManager.loginClientConnected) then
                TableManager:disconnect_login_server()
            end
            self.haveEnter = true
            local seatid = 0
            for i = 1, #eventData.Players do
                if tonumber(eventData.Players[i].UserID) == tonumber(self.modelData.roleData.userID) then
                    seatid = eventData.Players[i].SeatID
                end
            end
            TableManager:proce_enterMatchingRoom(eventData.Host, eventData.Port, eventData.RoomID, self.data.goldid, eventData.Password, eventData.PlayRule, self.data.matchtype, seatid)
            self:subscibe_time_event(10, false, 1):OnComplete(function()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("网络连接失败")
                ModuleCache.GameManager.logout()
            end)
        end
    end)

    self:subscibe_package_event("Event_Matching_Withdraw", function(eventHead, eventData)
        if eventData.error == 0 then
            if (TableManager.loginClientConnected) then
                TableManager:disconnect_login_server()
            end
            ModuleCache.ModuleManager.destroy_module("public", "tablematch")
            local hall = ModuleCache.ModuleManager.get_module("henanmj", "hall")
            if not hall then
                ModuleCache.ModuleManager.show_module("henanmj", "hall")
            end

        end
    end)
    self:subscibe_package_event("Event_Matching_Notify_RoomInfo", function(eventHead, eventData)
        print("比赛进入牌局", eventData.RoomID)
        if (eventData.RoomID ~= 0) then
            if (TableManager.loginClientConnected) then
                TableManager:disconnect_login_server()
            end
            self.haveEnter = true
            local seatid = 0
            for i = 1, #eventData.Players do
                if eventData.Players[i].UserID == self.modelData.roleData.userID then
                    seatid = eventData.Players[i].SeatID
                end
            end
            TableManager:proce_enterMatchingRoom(eventData.Host, eventData.Port, eventData.RoomID, nil, eventData.Password, eventData.PlayRule, self.data.matchtype, seatid)
            self:subscibe_time_event(10, false, 1):OnComplete(function()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("网络连接失败")
                ModuleCache.GameManager.logout()
            end)
        end
    end)

    --事件
    self:subscibe_package_event("Event_Matching_Notify_MatchDynamic", function(eventHead, eventData)
        local ev = ModuleCache.Json.decode(eventData.EventArgs)
        if ev.Type == "loop_end" and ev.MatchState == 2 then
            local rank = 100
            for i = 1, #eventData.Users do
                if tonumber(eventData.Users[i].UserID) == tonumber(self.modelData.roleData.userID) then
                    rank = eventData.Users[i].Rank
                end
            end
            if rank == 100 then
                print("名次获取错误", self.modelData.roleData.userID)
            end
            MatchingManager:matchAwards(eventData.MatchID, eventData.StageID, rank)
            if (TableManager.loginClientConnected) then
                TableManager:disconnect_login_server()
            end
        elseif ev.Type == "loop_start" or ev.Type == "loop_playing" or (ev.Type == "loop_end" and ev.MatchState == 1) then
            local matchinfo = {
                CurLoopCnt = eventData.CurLoopNo,

                RoomCnt = ev.TotalRoomCnt
            }
            matchinfo.UserCnt = #eventData.Users
            matchinfo.Rank = 0
            matchinfo.QuitScore = 0
            if ev.CurQuitScore then
                matchinfo.QuitScore = ev.CurQuitScore
            end
            matchinfo.score = 0
            for i = 1, #eventData.Users do
                if tonumber(eventData.Users[i].UserID) == tonumber(self.modelData.roleData.userID) then
                    matchinfo.score = eventData.Users[i].Score
                    matchinfo.Rank = eventData.Users[i].Rank
                end
            end
            if self.view then
                self.view:update_matchinfo(matchinfo)
            end
        end
    end)

    self:subscibe_package_event("Event_RoomSetting_RefreshBg", function(eventHead, eventData)
        self.view:refresh_majiang_2d_Bg(eventData)
    end)
    self:subscibe_package_event("Event_RoomSetting_Refresh2dOr3d", function(eventHead, eventData)
        if 1 ==  eventData then
            ModuleCache.PackageManager.update_package_version("majiang3d", function()
                self.view:refresh_majiang_2d_Bg(-10086)
            end)
        elseif 2 ==  eventData then
            self.view:refresh_majiang_2d_Bg()
        end
    end)
end

function TableMatchModule:reconnet_match()
    print("匹配界面断线重连")
    if (TableManager.loginClientConnected) then
        TableManager:disconnect_login_server()
    end
    TableManager:start_enter_gold_matching(self.modelData.roleData.userID,
            self.modelData.roleData.password, nil, nil, nil, self.id)
end

-- 绑定loginModel层事件，模块内交互
function TableMatchModule:on_model_event_bind()


end

function TableMatchModule:on_show(data)
    --self.view:hide();
    --self.view:initLocalView()
    if data then
        self.data = data
        self.view:show_view(data.matchtype)
        if data.matchtype == 1 then
            self:getgoldbyid(data.goldid)
        elseif data.matchtype == 2 then
            self:getmatchbyid(data.matchid)
        end

        --ModuleCache.AssetBundleManager:LoadAssetBundleAsync("runfast/module/tabletunfast/runfast_table.prefab", "Runfast_Table", nil)
    end
    ModuleCache.ModuleManager.destroy_package("henanmj")
    ModuleCache.ModuleManager.destroy_module("public","goldentrance")
    --self:dispatch_package_event("Event_GoldJump_error")
end

function TableMatchModule:on_click(obj, arg)
    print("点击", obj.name, obj.transform.parent.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj.name == "ButtonJinBiChangExit" then
        if self.data.matchtype == 1 then
            TableManager:request_goldmathing_quit(self.data.goldid, self.modelData.roleData.userID)
        elseif self.data.matchtype == 2 then
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("比赛场无法退出")
        end
    elseif obj.name == "BtnLeftOpen" then
        self.view:pannelExpand(true)
    elseif obj.name == "BtnLeftClose" then
        self.view:pannelExpand(false)
    elseif obj.name == "BtnMatchRank" then
        ModuleCache.ModuleManager.show_module("public", "matchrank", self.data.matchid)
    elseif obj.name == "Image" then
        local id = tonumber(obj.transform.parent.parent.parent.parent.parent.name)
        print("点击玩家头像", id)
        if id then
            ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", id)
        end
    elseif obj.name == "BtnSetting" then
        local ConfigData = require(string.format("package.public.config.%s.config_%s", AppData.App_Name, AppData.Game_Name))
        local GameID = AppData.get_app_and_game_name()
        local wanfaType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
        local Is3D = Config.get_mj3dSetting(GameID).Is3D
        local def3dOr2d = Config.get_mj3dSetting(GameID).def3dOr2d
        local intentData = { }
        intentData.tableBackgroundSpriteSetName = "RoomSetting_TableBackground_Name_" .. "MJ"
        intentData.canExitRoom = false
        intentData.canDissolveRoom = false
        intentData.is3D = Is3D
        if 1 == Is3D then
            intentData.tableBackground2d = self.view.majiang3dBgSprite[1] ---2D示意桌布
            intentData.tableBackground3d =  self.view.majiang3dBgSprite[2] ---3D示意桌布
            local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d", wanfaType)
            local curSetting = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
            if 2 == curSetting then
                intentData.tableBackgroundSprite = self.view.majiang2dBgSprite[1]  ---2D桌布
                intentData.tableBackgroundSprite2 = self.view.majiang2dBgSprite[2] ---2D桌布
                intentData.tableBackgroundSprite3 = self.view.majiang2dBgSprite[3] ---2D桌布
            end
        else
            intentData.tableBackgroundSprite = self.view.majiang2dBgSprite[1]  ---2D桌布
            intentData.tableBackgroundSprite2 = self.view.majiang2dBgSprite[2] ---2D桌布
            intentData.tableBackgroundSprite3 = self.view.majiang2dBgSprite[3] ---2D桌布
        end
        intentData.isOpenLocationSetting = ConfigData.isOpenLocationSetting
        intentData.defLocationSetting = ConfigData.defLocationSetting
        intentData.defGuoHu = ConfigData.defGuoHu
        ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", intentData)
    elseif obj.name == "ButtonRuleExplain" then
        ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
    end
end

function TableMatchModule:getgoldbyid(id)
    local addStr = "gold/getById?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            goldId = id,
            uid = self.modelData.roleData.userID,
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            self.view:initTable(1, retData.data, nil, self.modelData.roleData)
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end)
end

function TableMatchModule:getmatchbyid(id)
    local addStr = "match/getById?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            uid = self.modelData.roleData.userID,
            matchId = id
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            self.view:initTable(2, nil, retData.data, self.modelData.roleData, self.data.matchinfo)
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end)
end

function TableMatchModule:on_destroy()
end

return TableMatchModule



