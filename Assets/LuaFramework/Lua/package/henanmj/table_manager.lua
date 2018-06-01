local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local AppData = AppData
local class = require("lib.middleclass")
local Model = require('core.mvvm.model_base')
local ModuleEventBase = require('core.mvvm.module_event_base')
---@class TableManager
local TableManager = class('TableManager', Model)
local CSmartTimer = ModuleCache.SmartTimer.instance
local Net_Hall_Login = "Msg_Hall_Login"
local max_reconnect_game_server_times = 7
local Buffer = ModuleCache.net.Buffer
local Application = UnityEngine.Application

function TableManager:henanmj_request_login_game_server(loginInfo, hideCircle)
    ModuleCache.GameSDKCallback.instance.mwEnterRoomID = "0"
    ModuleCache.FunctionManager.ClearClipBoard()
    if not hideCircle then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    local msgId, request = self.netMsgApi:create_request_data("Msg_Login_Server")
    request.Password = loginInfo.Password
    request.RoomID = loginInfo.RoomID
    request.SeatID = loginInfo.SeatID or 0
    request.AppendData = loginInfo.AppendData or ""
    request.ProtoVersion = loginInfo.ProtoVersion or 1
    request.ClientVersion = loginInfo.ClientVersion
    Model.send_msg(self, msgId, request, "gameServer")
    --ModuleCache.PreLoadManager.registerFinishPreLoadCallback(function()
    --    ModuleCache.UnityEngine.Application.backgroundLoadingPriority = UnityEngine.ThreadPriority.High
    --end)
end

function TableManager:henanmj_request_create_room(createInfo)
    print_debug("henanmj_request_create_room")
    local ruleTable = ModuleCache.Json.decode(createInfo.Rule)
    self.Rule = createInfo.Rule
    self.RoundCount = createInfo.RoundCount
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local msgId, request = self.netMsgApi:create_request_data("Msg_CreateRoom")
    request.GameName = createInfo.GameName
    request.RoundCount = createInfo.RoundCount
    request.Rule = createInfo.Rule
    request.HallID = createInfo.HallID
    request.IsGoldFieldRoom = ruleTable.IsGoldFieldRoom or false
    self.creatRoomRule = createInfo.Rule
    if ruleTable.NeedOpenGPS or ruleTable.CheckIPAddress then
        local playRule = {
            NeedOpenGPS = ruleTable.NeedOpenGPS,
            CheckIPAddress = ruleTable.CheckIPAddress,
            simulateGPS = true
        }
        self:get_client_ip_and_gps(playRule, nil, function(exJsonStr)
            request.ExJsonStr = exJsonStr
            Model.send_msg(self, msgId, request, "login")
        end, true)
    else
        Model.send_msg(self, msgId, request, "login")
    end
end


--
function TableManager:get_client_ip_and_gps(playeRule, exJsonTable, callback)
    local processData = function(data)
        local exJsonTable = exJsonTable or {}
        if data then
            exJsonTable.gps_opened = not (data.latitude == 0 and data.longitude == 0)
            exJsonTable.latitude = tonumber(data.latitude)
            exJsonTable.longitude = tonumber(data.longitude)
        end
        exJsonTable.ip = tostring(self.modelData.roleData.ip)

        if (ModuleCache.GameManager.isEditor or "WindowsPlayer" == tostring(ModuleCache.UnityEngine.Application.platform)) then
            exJsonTable.gps_opened = true
            exJsonTable.ip = "183.1" .. os.date("%S") .. ".197.1" .. tostring(os.date("%S"))
            exJsonTable.latitude = tonumber("1" .. tostring(os.date("%S")))
            exJsonTable.longitude = tonumber("2" .. tostring(os.date("%S")))
        end

        return ModuleCache.Json.encode(exJsonTable)
    end

    if playeRule.CheckIPAddress and callback then
        if not playeRule.NeedOpenGPS and self.modelData.roleData.ip ~= "" then
            callback(processData(nil))
            return
        end

        local requestData = {
            baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "api/getIp?",
            params = {
                uid = self.modelData.roleData.userID,
            },
        }
        ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
            local retData = ModuleCache.Json.decode(wwwOperation.www.text)
            if retData.ret and retData.ret == 0 then
                self.modelData.roleData.ip = retData.data
                if not playeRule.NeedOpenGPS then
                    callback(processData(nil))
                end
            end
        end, function(error)
            print(error.error)
        end)

        if not playeRule.NeedOpenGPS then
            return
        end
    end

    if playeRule.NeedOpenGPS and ModuleCache.GameManager.runtimePlatform == "Android" then
        if not ModuleCache.GameSDKInterface:IsGpsOpen(false) then
            self:disconnect_login_server()
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            ModuleCache.ModuleManager.show_public_module_alertdialog():show_confirm_cancel("此玩法需要检测您的地理位置,而您设备GPS处于关闭状态\n是否前往打开？", function()
                ModuleCache.GameSDKInterface:StartActivity("android.settings.LOCATION_SOURCE_SETTINGS")
            end)
            return
        end
    end

    local cacheData = ModuleCache.GPSManager._get_cache_data(true)
    if cacheData then
        if callback then
            callback(processData(cacheData))
            if os.time() - ModuleCache.PlayerPrefsManager.GetInt("UpdateGPSINFOTime", 0) < 60 then
                return
            end
        end
    end

    ModuleCache.GPSManager.begin_location(function(data)
        if callback then
            callback(processData(data))
        end
    end, true)

end

function TableManager:connect_login_server(onConnectedCallback, onLoginAccCallback, onCreateRoomCallback, onEnterRoomCallback, onErrorCallback, hideCircle)
    if not hideCircle then
        ModuleCache.ModuleManager.show_public_module("netprompt", true)
    end
    self.connecting = true
    self.onConnectLoginServerCallback = onConnectedCallback
    self.onLoginAccCallback = onLoginAccCallback
    self.onCreateRoomFromLoginServerCallback = onCreateRoomCallback
    self.onEnterRoomFromLoginServerCallback = onEnterRoomCallback
    self.onConnectLoginServerErrorCallback = onErrorCallback
    print("connect_login_server...", self.onConnectLoginServerErrorCallback)
    local loginClient = NetClientManager.init_client("login", 1)
    self.modelData.loginClient = loginClient
    local accountID = ModuleCache.PlayerPrefsManager.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
    local password = ModuleCache.PlayerPrefsManager.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_PASSWORD, "0")
    if accountID ~= "0" and password ~= "0" and password ~= "" then
        loginClient:connect(ModuleCache.GameManager.netAdress.curServerHostIp .. "login?type=token")
    else
        loginClient:connect(ModuleCache.GameManager.netAdress.curServerHostIp .. "login")
    end
    loginClient:subscibe_connect_event(function(state)
        self.connecting = false
        if "Closed" == state then
            self.loginClientConnected = false
            if self.checkLoginTimeId then
                CSmartTimer:Kill(self.checkLoginTimeId)
                self.checkLoginTimeId = nil
            end
        elseif "Connected" == state then
            self.loginClientConnected = true
            self.reconnectLoginServerTimes = 0
            if (self.onConnectLoginServerCallback) then
                self:onConnectLoginServerCallback()
            end
            self.checkLoginTimeId = CSmartTimer:Subscribe(9, false, 0):OnComplete(function(t)
                --self:disconnect_login_server()
                print("diconnect login server")
                ModuleCache.ModuleManager.hide_public_module("netprompt")
                self.modelData.loginClient:close()
            end)                               .id
        else
            self.loginClientConnected = false
            ModuleCache.GameManager.get_and_set_net_adress()
            ModuleCache.ModuleManager.hide_public_module("netprompt")
        end
    end)
end

function TableManager:connect_game_server(host, port, onConnectCallback, hideCircle)
    if not hideCircle then
        ModuleCache.ModuleManager.show_public_module("netprompt", true)
    end
    self.connectCallback = onConnectCallback
    self.lastLoginToken = nil
    local client = NetClientManager.init_client("gameServer", 2)
    self.modelData.gameClient = client
    local accountID = self.modelData.roleData.userID
    if not accountID then
        accountID = ModuleCache.PlayerPrefsManager.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
    end
    if self.curTableData.WebSocketSport and self.curTableData.WebSocketSport ~= 0 then
        --用于连测试服
        client:connect(self.curTableData.ServerHost .. ":" .. self.curTableData.WebSocketSport)
    else
        client:connect(ModuleCache.GameManager.netAdress.curServerHostIp .. "game?token=" .. accountID)
    end

    client:subscibe_connect_event(function(state)
        if "Closed" == state then
            --主动关闭，不会触发断线重连

        elseif "Connected" == state then
            self.netErrNum = 0
            self.reconnectGameServerTimes = 0
            self.clientConnected = true
            if self.connectCallback then
                self.connectCallback()
            end
        elseif "Disconnected" == state then
            self:on_game_server_connect_error()
        elseif "ConnectTimeOut" == state then
            self:on_game_server_connect_error()
        else
            self:on_game_server_connect_error()
        end
    end);
end

function TableManager:on_game_server_connect_error()
    -- 同一个账号是否在多地登录
    ModuleCache.GameManager.get_and_set_net_adress()
    if (self.reconnectGameServerTimes >= max_reconnect_game_server_times) then
        ModuleCache.GameManager.logout();
    else
        self:reconnect_game_server()
    end
end

function TableManager:heartbeat_timeout_reconnect_game_server()
    -- 主动断线会触发Error
    self.modelData.gameClient:disconnect()
end

function TableManager:heartbeat_timeout_reconnect_login_server()
    -- 主动断线会触发Error
    self.modelData.loginClient:disconnect()
end

-- 离开房间
function TableManager:exit_room(tip)
    self:disconnect_login_server()
    self:disconnect_game_server()
    ModuleCache.net.NetClientManager.disconnect_all_client()
    ModuleCache.ModuleManager.hide_public_module("netprompt")
    for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
        ModuleCache.ModuleManager.destroy_package(v.package_name)
    end
    ModuleCache.ModuleManager.destroy_public_package()
    --ModuleCache.ModuleManager.destroy_module("majiang", "table")
    ModuleCache.ModuleManager.show_module("henanmj", "hall")
    if (tip) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(tip)
    end
end

-- 如果出了总结算界面那么就不返回桌面
function TableManager:disconnect_all_client_no_exit_room()
    self:disconnect_login_server()
    self:disconnect_game_server(true)
    ModuleCache.net.NetClientManager.disconnect_all_client()
    ModuleCache.ModuleManager.hide_public_module("netprompt")
end


-- 牌局中重连 要重新走登录流程
function TableManager:reconnect_game_server()
    print("reconnect_game_server ------------------------ ")
    self.reconnectGameServerTimes = self.reconnectGameServerTimes + 1
    self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort, function()
        self:henanmj_request_login_game_server(self.curTableData)
    end)
end

function TableManager:showNetErrDialog(callback)
    if (callback) then
        if (not self.netErrNum) then
            self.netErrNum = 1
        end
        self.netErrNum = self.netErrNum + 1
        if (self.netErrNum >= 4) then
            self.netErrNum = 0
            self.onConnectLoginServerErrorCallback = nil
            ModuleCache.GameManager.logout();
        else
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("当前网络环境异常，请检查网络后重试", callback)
        end
    else
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("当前网络环境异常，请检查网络后重试", nil)
    end
end

function TableManager:request_login_login_server(userId, password, weiXinCode, hideCircle)
    if not hideCircle then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    local msgId, request = self.netMsgApi:create_request_data(Net_Hall_Login)
    request.UserID = userId or 0
    request.Password = password or ""
    if weiXinCode and weiXinCode ~= "youke" then
        request.WeiXinCode = weiXinCode .. "__" .. ModuleCache.AppData.Const_App_Bundle_ID
    else
        request.WeiXinCode = weiXinCode or ""
    end
    request.Platform = ModuleCache.GameManager.customPlatformName
    request.ProtoVersion = 1
    request.ClientVersion = ModuleCache.GameManager.appVersion
    request.AppName = ModuleCache.AppData.get_app_name()
    request.EnterGraySrv = ModuleCache.GameManager.openGameServerGradationTest
    Model.send_msg(self, msgId, request, "login") --消息名在 net.net_msg_api.lua 中
end


-- playRule为玩法规则
function TableManager:request_join_room_login_server(roomId, wanfaName, matchId, goldId, playRule, hideCircle)
    local msgId, request = self.netMsgApi:create_request_data("Msg_EnterRoom")
    if not hideCircle then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end
    if roomId then
        request.RoomID = roomId
        -- 防止服务器返回0的情况  客户端缓村该变量
        self._roomID = roomId
    else
        self._roomID = nil
    end

    if (wanfaName) then
        request.GameName = wanfaName
        ModuleCache.PlayerPrefsManager.SetString("LastJoinWanfaName", wanfaName)
    else
        ModuleCache.PlayerPrefsManager.SetString("LastJoinWanfaName", "")
    end

    if (matchId) then
        -- 比赛场id
        request.MatchID = matchId
    end
    if goldId then
        --金币场id
        request.GoldFieldID = goldId
    end

    if playRule and playRule.callFromErrorCode then
        self.callFromErrorCode = true
    else
        self.callFromErrorCode = false
    end

    local exJsonTable
    if (ModuleCache.PlayerPrefsManager.GetInt("ChangeTable", 0) == 2) then
        exJsonTable = {
            isAutoReady = true,
        }
    end
    if (exJsonTable) then
        request.ExJsonStr = ModuleCache.Json.encode(exJsonTable)
    end

    ModuleCache.PlayerPrefsManager.SetInt("ChangeTable", -1)
    if playRule and (playRule.NeedOpenGPS or playRule.CheckIPAddress) then
        self:get_client_ip_and_gps(playRule, exJsonTable, function(exJsonStr)
            request.ExJsonStr = exJsonStr
            Model.send_msg(self, msgId, request, "login")
        end)
    else
        Model.send_msg(self, msgId, request, "login")
    end
end

function TableManager:initialize(...)
    Model.initialize(self, ...)
    self:refresh_voice_shake()
    self.chatMsgs = {}
    self.reconnectGameServerTimes = 0
    self.reconnectLoginServerTimes = 0
    self.sendMsgNetClientName = "gameServer"
    self.modelData = require("package.henanmj.model.model_data")
    self.heartbeatRequestName = "5"
    self.heartbeatResponseName = "Msg_Ping"

    Model.subscibe_msg_event(self, {    --登录回调
        msgName = Net_Hall_Login,
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            if (retData.ErrorCode and retData.ErrorCode ~= 0) or retData.ErrorInfo == "密码检验失败" or retData.ErrorInfo == "密码校验失败" then
                if (retData.ErrorCode == -8) then
                    print("登录错误提示：", retData.ErrorCode, retData.ErrorInfo)
                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(retData.ErrorInfo)
                else
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                end
                if (not retData.ErrorCode or (retData.ErrorCode and retData.ErrorCode >= -4)) then
                    ModuleCache.GameManager.logout(true)
                    self:disconnect_login_server()
                end
            else
                self.loginGameName = retData.Game_Name
                if (self.onLoginAccCallback) then
                    self.onLoginAccCallback(retData)
                end
            end
        end
    }, "login")

    Model.subscibe_msg_event(self, {
        msgName = "Msg_CreateRoom",
        callback = function(msgName, msgBuffer)
            -- ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            print_pbc_table(retData, "~~~~~~~~~~~~~~~~~~~Msg_CreateRoom~~~~~~~~~~~")
            self.curTableData = {}
            if retData.ErrorCode ~= 0 then
                ModuleCache.ModuleManager.hide_public_module("netprompt")

                if retData.ErrorCode == -34 then
                    -- 已在游戏中
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                    if string.find(retData.ErrorInfo, "已在") then
                        --需要重新登录
                        ModuleCache.GameManager.logout()
                    end
                elseif retData.ErrorCode == -23 then
                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("体力不足，是否充值？"), function()
                        ModuleCache.ModuleManager.show_module("henanmj", "shop", 2)
                    end, nil)
                elseif retData.ErrorCode == -11 then
                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您的钻石和体力都不足，是否充值？\n（体力和钻石必须有一种数量足够）"), function()
                        ModuleCache.ModuleManager.show_module("henanmj", "shop")
                    end, nil)
                elseif (retData.ErrorCode == -41) then
                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
                        ModuleCache.ModuleManager.show_module("public", "goldadd")
                    end, nil, true, "确 认", "取 消")
                elseif (retData.ErrorCode == -48) or (retData.ErrorCode == -49) then
                    print("ip或gps相同", self.modelData.tableCommonData.isCheatRoom, retData.GoldFieldID)
                    if self.modelData.tableCommonData.isCheatRoom and retData.GoldFieldID > 0 and retData.GoldFieldID < 1000000 then
                        print("防作弊房间继续进入")
                        TableManager:join_room(nil, ModuleCache.PlayerPrefsManager.GetString("LastJoinWanfaName", ""), nil, retData.GoldFieldID)
                    end
                else
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                end
            else
                ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)
                self.curTableData = {
                    Password = retData.Password,
                    RoomID = retData.RoomID,
                    SeatID = retData.SeatID,
                    AppendData = ModuleCache.GPSManager.gps_info,
                    ProtoVersion = 1,
                    ClientVersion = ModuleCache.UnityEngine.Application.version,
                    ServerHost = retData.ServerHost,
                    ServerPort = retData.ServerPort,
                    WebSocketSport = retData.wsport,
                    modelData = self.modelData,
                    Rule = self.Rule,
                    RoundCount = self.RoundCount,
                    HallID = retData.HallID,
                    RoomType = retData.RoomType
                }
                self.modelData.tableCommonData.tableType = 0
                local ruleTable = ModuleCache.Json.decode(self.Rule)
                print_table(ruleTable, "创建房间rule")

                if self.onCreateRoomFromLoginServerCallback then
                    if (retData.RoomID ~= 0) then
                        local roleData = self.modelData.roleData
                        local myRoomSeatInfo = { }
                        myRoomSeatInfo.RoomID = retData.RoomID
                        myRoomSeatInfo.WebSocketSport = retData.wsport
                        myRoomSeatInfo.ServerHost = retData.ServerHost
                        myRoomSeatInfo.ServerPort = retData.ServerPort
                        myRoomSeatInfo.SeatID = retData.SeatID
                        myRoomSeatInfo.Password = retData.Password
                        myRoomSeatInfo.Rule = self.Rule
                        myRoomSeatInfo.RuleTable = ruleTable
                        local GameID = myRoomSeatInfo.RuleTable.GameID

                        roleData.myRoomSeatInfo = myRoomSeatInfo
                        roleData.RoomType = retData.RoomType
                        roleData.HallID = retData.HallID
                    end
                    self.onCreateRoomFromLoginServerCallback(retData)
                    self:disconnect_login_server()
                    return
                end

                self:disconnect_login_server()
                -- 金币场合并Develop
                --    ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)
                local Is3D = Config.get_mj3dSetting(ruleTable.GameID).Is3D
                local def3dOr2d = Config.get_mj3dSetting(ruleTable.GameID).def3dOr2d
                local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",ruleTable.GameType)
                local curSetIs3D = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
                local package = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).package
                if Is3D and Is3D == 1 and curSetIs3D == 1 then
                    ModuleCache.ModuleManager.hide_public_module("netprompt")
                    local packageName = 'majiang3d'
                    if(string.find(package, "majiangshanxi") ~= nil)then
                        packageName = 'majiangshanxi3d'
                    end
                    ModuleCache.PackageManager.update_package_version(packageName, function()
                        ModuleCache.ModuleManager.show_public_module("netprompt")
                        self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort, function()
                            self:henanmj_request_login_game_server(self.curTableData)
                        end)
                    end)
                else
                    self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort, function()
                        self:henanmj_request_login_game_server(self.curTableData)
                    end)
                end

            end
        end
    }, "login")

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Login_Server",
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            ModuleCache.ModuleManager.hide_public_module("redpacket")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            if retData.Error == 0 then
                ModuleCache.SoundManager.stop_music()
                for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
                    ModuleCache.ModuleManager.destroy_package(v.package_name)
                end
                ModuleCache.ModuleManager.destroy_public_package()
                if ModuleCache.AppData.Game_Name == "NTCP" or ModuleCache.AppData.Game_Name == "HMCP" or "RDCP" == ModuleCache.AppData.Game_Name then
                    ModuleCache.ModuleManager.show_module_only("changpai", "table")
                else
                    --- 大冶字牌
                    if self.curTableData and self.curTableData.Rule and string.sub(self.curTableData.Rule, 1, 1) == "{" then
                        self.phzTableData = {}
                        for k, v in pairs(self.curTableData) do
                            self.phzTableData[k .. ""] = v
                        end
                        local package = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).package
                        if package == "paohuzi" or package == 'huapai' then
                            ModuleCache.ModuleManager.destroy_package(package)
                            ModuleCache.ModuleManager.show_module_only(package, "table")

                        else
                            self:show_majiang_table(self.curTableData.Rule)
                        end
                    else
                        self:show_majiang_table(self.curTableData.Rule)
                    end
                end
                ModuleCache.GPSManager.begin_location(function(data)
                    if data and type(data) == "table" then
                        data.chatType = 4
                        self:request_chat(data)
                    end
                end)
            else
                --穆大神：连接服务器失败不提示
                --ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("连接游戏服错误：" .. (retData.ErrInfo or ""))
                ModuleCache.GameManager.logout()
            end
        end
    }, "gameServer")

    Model.subscibe_msg_event(self, {
        msgName = "Msg_EnterRoom",
        callback = function(msgName, msgBuffer)
            self:proce_msg_enterRoom(msgName, msgBuffer, self.modelData.hallData.hideCircle)
        end
    }, "login")

    --进入回调
    self:subscibe_msg_event({
        msgName = 'Msg_Matching_Enter',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            if (retData.ErrorCode == 0) then
                if self.checkLoginTimeId then
                    CSmartTimer:Kill(self.checkLoginTimeId)
                    self.checkLoginTimeId = nil
                end
                if retData.GameName then
                    ModuleCache.GameManager.change_game_by_gameName(retData.GameName)
                end
                if (retData.IsStart or retData.CurLoopCnt > 0) then
                    local matchInfo = {
                        MatchID = retData.MatchID,
                        StageID = retData.StageID,
                        CurLoopCnt = retData.CurLoopCnt,
                        UserCnt = retData.UserCnt,
                        SignupUserCnt = retData.SignupUserCnt,
                        RoomCnt = retData.RoomCnt,
                        QuitScore = retData.QuitScore,
                        Rank = retData.Rank,
                        Score = retData.Score,
                    }
                    ModuleCache.ModuleManager.show_module("public", "tablematch", { matchtype = 2, matchid = retData.MatchID, matchinfo = matchInfo })
                else
                    ModuleCache.ModuleManager.show_module("henanmj", "hall")
                    ModuleCache.ModuleManager.show_module("public", "bisailist",
                            { id = retData.MatchID, stageId = retData.StageID, isSigned = true })
                end
            else
                self:disconnect_login_server()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                for k, v in pairs(AppData.allPackageConfig) do
                    ModuleCache.ModuleManager.destroy_package(v.package_name)
                end
                ModuleCache.ModuleManager.destroy_package("public")
                ModuleCache.ModuleManager.show_module("henanmj", "hall")
            end
        end
    }, "login")
    --报名回调
    self:subscibe_msg_event({
        msgName = 'Msg_Matching_SignUp',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            if (retData.ErrorCode == 0) then
                ModuleEventBase.dispatch_package_event(self, 'Event_Matching_SignUp', { MatchID = retData.MatchID, StageID = retData.StageID })
                if self.checkLoginTimeId then
                    CSmartTimer:Kill(self.checkLoginTimeId)
                    self.checkLoginTimeId = nil
                end
            else
                self:disconnect_login_server()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
            end
        end
    }, "login")
    --退赛回调
    self:subscibe_msg_event({
        msgName = 'Msg_Matching_Withdraw',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            ModuleEventBase.dispatch_package_event(self, 'Event_Matching_Withdraw',
                    { MatchID = retData.MatchID, StageID = retData.StageID, error = retData.ErrorCode, ErrorInfo = retData.ErrorInfo })

            --if (retData.ErrorCode == 0) then
            --    ModuleEventBase.dispatch_package_event(self, 'Event_Matching_Withdraw', { MatchID = retData.MatchID, StageID = retData.StageID })
            --else
            --    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
            --end
        end
    }, "login")
    --赛况
    self:subscibe_msg_event({
        msgName = 'Msg_Matching_Notify_MatchDynamic',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            ModuleEventBase.dispatch_package_event(self, 'Event_Matching_Notify_MatchDynamic', retData)
        end
    }, "login")
    --匹配成功
    self:subscibe_msg_event({
        msgName = 'Msg_Matching_Notify_RoomInfo',
        callback = function(msgName, msgBuffer)
            print("比赛场进入房间")
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            ModuleEventBase.dispatch_package_event(self, 'Event_Matching_Notify_RoomInfo', retData)

        end
    }, "login")
    --账号被挤
    self:subscibe_msg_event({
        msgName = 'Msg_Extrusion',
        callback = function(msgName, msgBuffer)

            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            print("账号被挤", retData.UserID)
            if retData.UserID == self.modelData.roleData.userID then
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您的账号已在其他地方登录")
                ModuleCache.GameManager.logout()
            end
        end
    }, "login")
    --心跳回包
    self:subscibe_msg_event({
        msgName = 'Msg_Ping',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            print("login ping")
            if (self.lastPingReqeustTime) then
                self.pingDelayTime = UnityEngine.Time.realtimeSinceStartup - self.lastPingReqeustTime
                self.lastPingReqeustTime = nil
                if (self.pingDelayTime == 0) then
                    self.pingDelayTime = 0.06
                end
            end
        end
    }, "login")
    --进入金币场
    self:subscibe_msg_event({
        msgName = 'Msg_GoldMatching_Enter',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            if (retData.ErrorCode == 0) then
                if self.checkLoginTimeId then
                    CSmartTimer:Kill(self.checkLoginTimeId)
                    self.checkLoginTimeId = nil
                end
                if retData.GameName then
                    ModuleCache.GameManager.change_game_by_gameName(retData.GameName)
                end
                self.modelData.tableCommonData.tableType = 1
                ModuleCache.ModuleManager.show_module("public", "tablematch", { matchtype = 1, goldid = retData.GoldID })
            else
                self:disconnect_login_server()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                for k, v in pairs(AppData.allPackageConfig) do
                    ModuleCache.ModuleManager.destroy_package(v.package_name)
                end
                ModuleCache.ModuleManager.destroy_package("public")
                ModuleCache.ModuleManager.show_module("henanmj", "hall")
            end
        end
    }, "login")
    --退出金币场
    self:subscibe_msg_event({
        msgName = 'Msg_GoldMatching_Quit',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            print("退出金币场成功，", retData.ErrorCode)
            if (retData.ErrorCode == 0) then
                print("发退出金币场消息")
                ModuleEventBase.dispatch_package_event(self, 'Event_GoldMatching_Quit', retData.GoldID)
            else
                --ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
            end

        end
    }, "login")
    --金币场匹配成功
    self:subscibe_msg_event({
        msgName = 'Msg_GoldMatching_Notify_RoomInfo',
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            ModuleEventBase.dispatch_package_event(self, 'Event_GoldMatching_Notify_RoomInfo', retData)
        end
    }, "login")
end

function TableManager:proce_msg_enterRoom(msgName, msgBuffer, hideCircle)
    ModuleCache.ModuleManager.hide_public_module("netprompt")
    local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
    self.curTableData = {}
    if retData.ErrorCode == 0 then
        self:disconnect_login_server()

        if string.sub(retData.Rule, 1, 1) == "{" then
            local roomRule = ModuleCache.Json.decode(retData.Rule)

            local isPokerRule, packageConfig = ModuleCache.AppData.isPokerRule(roomRule.gameName)
            if (isPokerRule) then
                local roleData = self.modelData.roleData
                local myRoomSeatInfo = {}
                myRoomSeatInfo.RoomID = retData.RoomID
                myRoomSeatInfo.HallID = retData.HallID
                myRoomSeatInfo.ServerHost = retData.ServerHost
                myRoomSeatInfo.ServerPort = retData.ServerPort
                myRoomSeatInfo.WebSocketSport = retData.wsport
                myRoomSeatInfo.SeatID = retData.SeatID
                myRoomSeatInfo.Password = retData.Password
                myRoomSeatInfo.Rule = retData.Rule
                myRoomSeatInfo.RuleTable = ModuleCache.Json.decode(retData.Rule)

                roleData.modelData = self.modelData
                roleData.RoomID = retData.RoomID
                roleData.HallID = retData.HallID
                roleData.RoomType = retData.RoomType
                roleData.MatchID = retData.MatchID

                roleData.myRoomSeatInfo = myRoomSeatInfo
                ModuleCache.GameManager.change_game_by_gameName(myRoomSeatInfo.RuleTable.gameName)

                ModuleCache.PackageManager.update_package_version(packageConfig.package_name, function()
                    TableManagerPoker.reconnectGameServerTimes = 0
                    TableManagerPoker:connect_game_server(function()
                        TableManagerPoker:request_login_game_server(self.modelData.roleData.userID, self.modelData.roleData.myRoomSeatInfo.Password, hideCircle)
                    end,
                    --登录回调
                            function(data)
                                if (data.ErrorCode == -8) then
                                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您尚未加入此亲友圈，是否申请加入？"), function()
                                        ModuleCache.ModuleManager.show_module("henanmj", "museumjoin", data.HallID)
                                    end, nil)
                                elseif data.ErrorCode == -23 then
                                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("体力不足，是否充值？"), function()
                                        ModuleCache.ModuleManager.show_module("henanmj", "shop", 2)
                                    end, nil)
                                elseif data.ErrorCode == -11 then
                                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您的钻石和体力都不足，是否充值？\n（体力和钻石必须有一种数量足够）"), function()
                                        ModuleCache.ModuleManager.show_module("henanmj", "shop")
                                    end, nil)
                                elseif (not data.err_no or data.err_no == "0") then
                                    for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
                                        ModuleCache.ModuleManager.destroy_package(v.package_name)
                                    end
                                    ModuleCache.ModuleManager.destroy_package("public")
                                    ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)
                                    if (packageConfig.package_name == 'runfast') then
                                        self.RunfastRuleJsonString = myRoomSeatInfo.Rule
                                    end

                                    ModuleCache.SoundManager.stop_music()
                                    if (self.modelData.roleData.myRoomSeatInfo.RuleTable.name and self.modelData.roleData.myRoomSeatInfo.RuleTable.name == "ZhaJinNiu") then
                                        ModuleCache.ModuleManager.show_module("cowboy", "table_zhajinniu")
                                    else
                                        if packageConfig.package_name == "biji" and self.modelData.roleData.myRoomSeatInfo.RuleTable.gameType == 2 then
                                            ModuleCache.ModuleManager.show_module(packageConfig.package_name, "tablebijisix")
                                        else
                                            ModuleCache.ModuleManager.show_module(packageConfig.package_name, packageConfig.table_module_name)
                                        end
                                    end
                                else
                                    TableManagerPoker:disconnect_game_server()
                                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
                                    self:removeLastNum()
                                    self.joinRoomView:refreshRoomNumText(self.strRoomNum)
                                end
                            end, hideCircle)
                end)
                return
            end

        end

        ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")
        self.curTableData = {
            Password = retData.Password,
            RoundCount = retData.RoundCount,
            SeatID = retData.SeatID,
            Rule = retData.Rule,
            ServerHost = retData.ServerHost,
            ServerPort = retData.ServerPort,
            WebSocketSport = retData.wsport,
            RoomID = retData.RoomID,
            AppendData = ModuleCache.GPSManager.gps_info,
            ProtoVersion = 1,
            ClientVersion = ModuleCache.UnityEngine.Application.version,
            modelData = self.modelData,
            HallID = retData.HallID,
            RoomType = retData.RoomType,
            MatchID = retData.MatchID,
            GoldFieldID = retData.GoldFieldID,
        }

        local ruleTable = ModuleCache.Json.decode(retData.Rule)

        ModuleCache.GameManager.change_game_by_gameName(ruleTable.gameName or (self.loginGameName or ModuleCache.AppData.Game_Name))
        ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)

        local package = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).package
        local Is3D = Config.get_mj3dSetting(ruleTable.GameID).Is3D
        local def3dOr2d = Config.get_mj3dSetting(ruleTable.GameID).def3dOr2d
        local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",ruleTable.GameType)
        local curSetIs3D = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
        if package == "majiang" and Is3D and Is3D == 1 and curSetIs3D == 1 then
            package = "majiang3d"
        elseif package == "majiangshanxi" and Is3D and Is3D == 1 and curSetIs3D == 1 then
            package = "majiangshanxi3d"
        end
        ModuleCache.PackageManager.update_package_version(package, function()
            self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort,
                    function()
                        self:henanmj_request_login_game_server(self.curTableData)
                    end)
        end)
    else
        -- 如果换桌失败，需要退出重连
        for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
            if (ModuleCache.ModuleManager.module_is_active(v.package_name, v.table_module_name)) then
                ModuleCache.ModuleManager.destroy_package(v.package_name)
                self:exit_room()
                return
            end
        end

        if (ModuleCache.ModuleManager.module_is_active("majiang", "table")
                or ModuleCache.ModuleManager.module_is_active("majiang", "tablenew")
                or ModuleCache.ModuleManager.module_is_active("majiang3d", "table3d")) then
            self:exit_room()
        elseif (ModuleCache.ModuleManager.module_is_active("majiangshanxi", "table")
        or ModuleCache.ModuleManager.module_is_active("majiangshanxi", "tablenew")
        or ModuleCache.ModuleManager.module_is_active("majiangshanxi3d", "table3d")) then
            self:exit_room()
        else
            local PackageModuleEvent = require("core.package_module_event")
            PackageModuleEvent:dispatch_module_event(nil, nil, "Event_Package_EnterRoomFail", retData.ErrorCode)
            --self:dispatch_package_event("Event_Package_EnterRoomFail",retData.ErrorCode)  --跑抛出消息进入房间失败
            if (retData.ErrorCode == -8) then
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您尚未加入此亲友圈，是否申请加入？"), function()
                    ModuleCache.ModuleManager.show_module("henanmj", "museumjoin", retData.HallID)
                end, nil)
            elseif retData.ErrorCode == -23 then
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("体力不足，是否充值？"), function()
                    ModuleCache.ModuleManager.show_module("henanmj", "shop", 2)
                end, nil)
            elseif retData.ErrorCode == -11 then
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您的钻石和体力都不足，是否充值？\n（体力和钻石必须有一种数量足够）"), function()
                    ModuleCache.ModuleManager.show_module("henanmj", "shop", 1)
                end, nil)
            elseif (retData.ErrorCode == -41) then
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
                    ModuleCache.ModuleManager.show_module("public", "goldadd")
                end, nil, true, "确 认", "取 消")
            elseif (retData.ErrorCode == -48) or (retData.ErrorCode == -49) then
                -- -48提示您与其他玩家距离国际
                local gameName = ModuleCache.PlayerPrefsManager.GetString("GoldEntranceClickGame", "")
                print("进入其他房间", self.modelData.tableCommonData.isCheatRoom, gameName, retData.GoldFieldID)
                if self.modelData.tableCommonData.isCheatRoom and retData.GoldFieldID > 0 and retData.GoldFieldID < 1000000 and gameName ~= "" then
                    self:disconnect_login_server()
                    TableManager:join_room(nil, gameName, nil, retData.GoldFieldID)
                else
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                end
                self.modelData.tableCommonData.isCheatRoom = false
            elseif retData.ErrorCode == -46 and not self.callFromErrorCode then
                --服务器返回GPS没有打开,需要避免死循环
                local roomId = self._roomID
                if not roomId and retData.RoomID and retData.RoomID ~= 0 then
                    roomId = retData.RoomID
                end

                TableManager:request_join_room_login_server(roomId, ModuleCache.PlayerPrefsManager.GetString("LastJoinWanfaName", ""), nil, nil, { NeedOpenGPS = true, simulateGPS = true, callFromErrorCode = true })
                return
            elseif retData.ErrorCode == -47 and not self.callFromErrorCode then
                --服务器返回ip没有获取成功,需要避免死循环
                local roomId = self._roomID
                if not roomId and retData.RoomID and retData.RoomID ~= 0 then
                    roomId = retData.RoomID
                end
                TableManager:request_join_room_login_server(roomId, ModuleCache.PlayerPrefsManager.GetString("LastJoinWanfaName", ""), nil, nil, { CheckIPAddress = true, simulateGPS = true, callFromErrorCode = true })
                return
            else
                -- 进入麻将馆时可能会提示用“您已在房间中，请重试”
                self.callFromErrorCode = false
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                if string.find(retData.ErrorInfo, "已在") then
                    ModuleCache.GameManager.logout()
                end

                if retData.ErrorCode == -2 then
                    if (self.openShake) then
                        ModuleCache.GameSDKInterface:ShakePhone(250)
                    end
                end
            end
            self:disconnect_login_server()
        end
    end

end

function TableManager:proce_enterMatchingRoom(serverHost, serverPort, roomId, goldid, password, rule, matchtype,seatId)
    if string.sub(rule, 1, 1) == "{" then
        local roomRule = ModuleCache.Json.decode(rule)
        if matchtype == 1 then
            self.modelData.tableCommonData.tableType = 1
            self.modelData.tableCommonData.goldFildId = goldid
        else
            self.modelData.tableCommonData.tableType = 2
        end
        print(matchtype, "牌桌类型：", self.modelData.tableCommonData.tableType)
        local isPokerRule, packageConfig = AppData.isPokerRule(roomRule.gameName)
        print('------------------------', isPokerRule)
        if (isPokerRule) then
            print("AppData.isPokerRule：" .. roomRule.gameName)
            local roleData = self.modelData.roleData
            local myRoomSeatInfo = {}
            myRoomSeatInfo.RoomID = roomId
            myRoomSeatInfo.ServerHost = serverHost
            myRoomSeatInfo.ServerPort = serverPort
            myRoomSeatInfo.WebSocketSport = serverPort
            myRoomSeatInfo.Password = password
            myRoomSeatInfo.Rule = rule
            myRoomSeatInfo.RuleTable = ModuleCache.Json.decode(rule)

            roleData.modelData = self.modelData
            roleData.RoomID = roomId

            roleData.myRoomSeatInfo = myRoomSeatInfo
            ModuleCache.GameManager.change_game_by_gameName(myRoomSeatInfo.RuleTable.gameName)

            ModuleCache.PackageManager.update_package_version(packageConfig.package_name, function()
                TableManagerPoker.reconnectGameServerTimes = 0
                TableManagerPoker:connect_game_server(function()
                    TableManagerPoker:request_login_game_server(self.modelData.roleData.userID, self.modelData.roleData.myRoomSeatInfo.Password, true)
                end,
                --登录回调
                        function(data)
                            if (data.ErrorCode == -8) then
                                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您尚未加入此亲友圈，是否申请加入？"), function()
                                    ModuleCache.ModuleManager.show_module("henanmj", "museumjoin", data.HallID)
                                end, nil)
                            elseif data.ErrorCode == -23 then
                                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("钻石不足，是否充值？"), function()
                                    ModuleCache.ModuleManager.show_module("public", "shopbase", 1)
                                end, nil)
                            elseif data.ErrorCode == -11 then
                                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您的钻石不足，是否充值？"), function()
                                    ModuleCache.ModuleManager.show_module("public", "shopbase", 1)
                                end, nil)
                            elseif (not data.err_no or data.err_no == "0") then
                                for k, v in pairs(AppData.allPackageConfig) do
                                    ModuleCache.ModuleManager.destroy_package(v.package_name)
                                end
                                ModuleCache.ModuleManager.destroy_package("public", "tablematch")
                                --ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)
                                if (packageConfig.package_name == 'runfast') then
                                    print("==跑得快加入房间的规则=" .. tostring(self.RunfastRuleJsonString))
                                    self.RunfastRuleJsonString = myRoomSeatInfo.Rule
                                end

                                ModuleCache.SoundManager.stop_music()
                                if (myRoomSeatInfo.RuleTable.name and myRoomSeatInfo.RuleTable.name == "ZhaJinNiu") then
                                    ModuleCache.ModuleManager.show_module("cowboy", "table_zhajinniu")
                                else
                                    ModuleCache.ModuleManager.show_module(packageConfig.package_name, packageConfig.table_module_name)
                                end
                            else
                                TableManagerPoker:disconnect_game_server()
                                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
                            end
                        end, true)
            end)
            return
        end

    end

    self.curTableData = {
        Password = password,
        Rule = rule,
        ServerHost = serverHost,
        ServerPort = serverPort,
        WebSocketSport = serverPort,
        RoomID = roomId,
        SeatID = seatId,
        AppendData = ModuleCache.GPSManager.gps_info,
        ProtoVersion = 1,
        ClientVersion = Application.version,
        modelData = self.modelData,
    }

    local ruleTable = ModuleCache.Json.decode(rule)

    ModuleCache.GameManager.change_game_by_gameName(ruleTable.gameName or (self.loginGameName or AppData.Game_Name))
    ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)

    local playMode = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
    ModuleCache.PackageManager.update_package_version(playMode.package, function()
        self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort,
                function()
                    self:henanmj_request_login_game_server(self.curTableData, true)
                end, true)
    end)
end

function TableManager:clear_strategy_vals()

end

function TableManager:refresh_voice_shake()
    self.openVoice = (ModuleCache.PlayerPrefsManager.GetInt("openVoice", 1) == 1)
    self.openShake = (ModuleCache.PlayerPrefsManager.GetInt("openShake", 1) == 1)
end

function TableManager:disconnect_game_server(notClearData)
    self:clear_strategy_vals()
    if self.modelData.gameClient then
        self.modelData.gameClient:clear_subscibe_connect_event()
        self.modelData.gameClient:close()
    end
    self.connectCallback = nil
    self.lastLoginToken = nil
    --if (not notClearData) then
    --    self.curTableData = {}
    --end
end

function TableManager:disconnect_login_server()
    -- self.modelData.loginClient:clear_subscibe_connect_event()
    self.modelData.loginClient:close()
    self.onCreateRoomFromLoginServerCallback = nil
    self.onEnterRoomFromLoginServerCallback = nil
    self.lastPingReqeustTime = nil
end

function TableManager:play_back_on_id(playBackId, callback)
    local requestData = {
        params = {
            uid = self.modelData.roleData.userID,
            shortRecordId = playBackId
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/getRecordId?",
    }

    ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if (callback) then
            callback(retData)
        else
            if retData.ret and retData.ret == 0 then
                --OK
                local playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
                if (playMode.package == "runfast") then
                    self:play_back_runfast(retData.data, retData.data.players)
                else
                    self:play_back(retData.data, retData.data.players)
                end
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
            end
        end

    end, function(error)
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
    end)
end

function TableManager:share_play_back_id(playBackId, roomId)
    local requestData = {
        params = {
            uid = self.modelData.roleData.userID,
            recordId = playBackId,
            roomId = roomId,
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/getShortRecordId?",
    }
    ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            --OK
            ModuleCache.ShareManager().share_play_back(self.modelData.roleData.userID, retData.data.shortRecordId)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("分享回放码错误")
        end
    end, function(error)
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("分享回放码错误")
    end)
end

function TableManager:play_back(data, players)
    self:get_play_back_info(data.recordId, function(gamestates, data)
        local index = 1
        for i = 1, #players do
            local userId = players[i].userId
            if (userId .. "" == self.modelData.roleData.userID) then
                index = i
            end
        end
        self.curTableData = {
            isPlayBack = true,
            SeatID = index - 1,
            videoData = data,
            modelData = self.modelData,
            gamestates = gamestates,
            players = players
        }
        local strurl = ModuleCache.AppData.Game_Name
        local len = string.len(strurl)
        if string.sub(strurl, len - 1, len) == 'ZP' then
            TableManager.phzTableData = {
                isPlayBack = true,
                SeatID = index - 1,
                RoomID = data.roomid,
                RoundCount = data.roundcount,
                videoData = data,
                modelData = self.modelData,
                gamestates = gamestates,
                players = players,
                Rule = data.gamerule,
            }

            for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
                ModuleCache.ModuleManager.destroy_package(v.package_name)
            end
            ModuleCache.ModuleManager.destroy_package("public")
            ModuleCache.ModuleManager.show_module_only("paohuzi", "table")
            ModuleCache.ModuleManager.show_module("paohuzi", "playback")
        else
            local excute = function()
                for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
                    ModuleCache.ModuleManager.destroy_package(v.package_name)
                end
                ModuleCache.ModuleManager.destroy_package("public")
                self:show_majiang_table(data.gamerule)

                local package = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).package
                if(string.find(package, "majiangshanxi") ~= nil)then
                    ModuleCache.ModuleManager.show_module("majiangshanxi", "playback")
                else
                    ModuleCache.ModuleManager.show_module("majiang", "playback")
                end
            end
            local ruleTable = ModuleCache.Json.decode(data.gamerule)
            local playMode = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
            local Is3D = Config.get_mj3dSetting(ruleTable.GameID).Is3D
            local def3dOr2d = Config.get_mj3dSetting(ruleTable.GameID).def3dOr2d
            local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",ruleTable.GameType)
            local curSetIs3D = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
            if playMode.package == "majiang" and Is3D and Is3D == 1 and curSetIs3D == 1 then
                playMode.package = "majiang3d"
            elseif playMode.package == "majiangshanxi" and Is3D and Is3D == 1 and curSetIs3D == 1 then
                playMode.package = "majiangshanxi3d"
            end
            if "majiang3d" == playMode.package or "majiangshanxi3d" == playMode.package then
                ModuleCache.PackageManager.update_package_version(playMode.package, function()
                    excute()
                end)
            else
                excute()
            end
        end
    end)
end

function TableManager:show_majiang_table(rule)
    local ruleTable = ModuleCache.Json.decode(rule)
    local Is3D = Config.get_mj3dSetting(ruleTable.GameID).Is3D
    local def3dOr2d = Config.get_mj3dSetting(ruleTable.GameID).def3dOr2d
    local package = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).package
    if (Is3D) then
        local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",ruleTable.GameType)
        local curSetIs3D = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
        if(string.find(package, "majiangshanxi") ~= nil)then
            if (Is3D == 1 and curSetIs3D == 1) then
                ModuleCache.ModuleManager.show_module_only("majiangshanxi3d", "table3d")
            else
                ModuleCache.ModuleManager.show_module_only("majiangshanxi", "tablenew")
            end
        else
            if (Is3D == 1 and curSetIs3D == 1) then
                ModuleCache.ModuleManager.show_module_only("majiang3d", "table3d")
            else
                ModuleCache.ModuleManager.show_module_only("majiang", "tablenew")
            end
        end
    else
        if(string.find(package, "majiangshanxi") ~= nil)then
            ModuleCache.ModuleManager.show_module_only("majiangshanxi", "table")
        else
            ModuleCache.ModuleManager.show_module_only("majiang", "table")
        end
    end
end

function TableManager:get_play_back_info(playbackId, callback)
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local requestData = {
        params = {
            uid = self.modelData.roleData.userID,
            recordId = playbackId
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/playback?",
    }

    ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        if (string.find(www.text, "ret") ~= nil and string.find(www.text, "{") ~= nil) then
            local retData = ModuleCache.Json.decode(www.text)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            return
        end
        local buffer = Buffer.Create(0)  --会在C#层自动回收
        local videoData = buffer:GetPlayBackInfo(www.bytes)
        if not videoData then
            print("回放数据非法")
            return
        end
        local videoTable = nil
        if videoData.rule then
            videoTable = {}
            videoTable.gamerule = videoData.rule
        else
            videoTable = self:unpack_msg_new("Msg_VideoCode", videoData.headData)
        end
        local gamestates = {}
        for i = 1, videoData.frames.Count do
            local retData, error = self:unpack_msg_new("Msg_Table_GameStateNTF", videoData.frames[i - 1].buffer)
            table.insert(gamestates, retData)
        end

        callback(gamestates, videoTable)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
    end, function(error)
        ModuleCache.ModuleManager.hide_public_module("netprompt")
    end)
end

function TableManager:play_back_runfast(data, players, _roomInfo)
    self:get_play_back_info_runfast(data.recordId, function(gamestates, videoTable)
        local index = 1
        for i = 1, #players do
            local userId = players[i].userId
            if (tostring(userId) == self.modelData.roleData.userID) then
                index = i
            end
        end

        for k, v in pairs(videoTable) do
            if string.find(k .. "", "_RUNFAST_RUNFAST") ~= nil then
                videoTable.RUNFAST = v
                break
            end
        end

        if (_roomInfo == nil) then
            local locDataTable = videoTable.RUNFAST
            _roomInfo = {
                roomNum = locDataTable.room_id,
                curRoundNum = locDataTable.round_count,
                totalRoundCount = locDataTable.room_conf.roundCount,
                creatorId = locDataTable.owner_id,
                playRule = ModuleCache.Json.encode(locDataTable.room_conf)
            }
        end

        self.curTableData_PB = {
            isPlayBack = true,
            roomInfo = _roomInfo,
            SeatID = index - 1,
            videoData = videoTable,
            modelData = self.modelData,
            gamestates = gamestates,
            players = players
        }

        self.modelData.curTablePlayerId = players[1].userId
        self.RunfastRuleJsonString = _roomInfo.playRule
        if (videoTable.success == false) then
            print("=====服务器说:" .. videoTable.errMsg)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(videoTable.errMsg)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            self.curTableData_PB = nil
            return
        end

        for k, v in pairs(ModuleCache.AppData.allPackageConfig) do
            ModuleCache.ModuleManager.destroy_package(v.package_name)
        end
        ModuleCache.ModuleManager.destroy_package("public")
        --ModuleCache.ModuleManager.show_module(ModuleCache.AppData.BranchRunfastName, "tablerunfast")
        ModuleCache.ModuleManager.destroy_package(ModuleCache.AppData.BranchRunfastName)
        ModuleCache.ModuleManager.show_module_only(ModuleCache.AppData.BranchRunfastName, "tablerunfast")
    end)
end

function TableManager:get_play_back_info_runfast(playbackId, callback)
    local requestData = {
        params = {
            uid = self.modelData.roleData.userID,
            recordId = playbackId
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/playback?",
    }

    ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        --  {"errMsg":"未知的回放记录","ret":-1,"success":false}
        if www.bytes and www.bytes.Length > 0 and www.bytes[0] == 123 then
            local retDataTable = ModuleCache.Json.decode(www.text)
            if (www.text ~= nil and www.text ~= nil and retDataTable ~= nil) then
                callback(nil, retDataTable)
            end
        end
    end, function(error)
        print("==error.error=" .. error.error)
    end)
end

function TableManager:unpack_msg_new(msgName, dataBuffer)
    local strurl = ModuleCache.AppData.Game_Name
    local len = string.len(strurl)
    if string.sub(strurl, len - 1, len) == 'ZP' then
        local api = require("package.paohuzi.model.net.net_msg_data_map")
        local ret = api:create_ret_data(msgName)
        ret:ParseFromString(dataBuffer)
        return ret
    end

    -- 南通长牌
    if string.sub(strurl, len - 1, len) == 'CP' then
        local api = require("package.changpai.model.net.net_msg_data_map")
        local ret = api:create_ret_data(msgName)
        ret:ParseFromString(dataBuffer)
        return ret
    end

    -- 麻将的
    local api = require("package.majiang.model.net.net_msg_data_map")
    local ret = api:create_ret_data(msgName)
    ret:ParseFromString(dataBuffer)
    return ret
end

-- 请求加入房间，gameName很有用处，用来进入牌友的
function TableManager:join_room(roomId, gameName, matchId, goldId, playRule)
    if (goldId) then
        ModuleCache.PlayerPrefsManager.SetInt("LastGoldFieldID", goldId)
    end

    self:connect_login_server(function()
        self:request_login_login_server(self.modelData.roleData.userID, self.modelData.roleData.password)
    end,
    --登录回调
            function(data)
                if (not data.ErrorCode or data.ErrorCode == 0) then
                    if data.RoomID ~= 0 then
                        self:request_join_room_login_server(data.RoomID, nil, nil, nil, playRule)
                    else
                        self:request_join_room_login_server(roomId, gameName, matchId, goldId, playRule)
                    end
                else
                    self:disconnect_login_server()
                    if data.ErrorInfo == "密码检验失败" or data.ErrorInfo == "密码校验失败" then
                        ModuleCache.GameManager.logout()
                    end
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
                end
            end,
            nil, nil, function()
                self:showNetErrDialog(nil)
            end)
end

function TableManager:request_chat(msg)
    local api = require("package.public.model.net.net_msg_data_map_2")
    local msgId, request = api:create_request_data("Msg_Message")
    request.Message = ModuleCache.Json.encode(msg)
    request.AppendData = ModuleCache.GPSManager.gps_info
    Model.send_msg(self, msgId, request, "gameServer", 1)
end



function TableManager:GetRunfastRuleText(RuleJsonString)
    local locResult = ""
    local locJsonString = ""

    if (RuleJsonString ~= nil and RuleJsonString ~= "") then
        locJsonString = RuleJsonString
    elseif (self.RunfastRuleJsonString ~= nil and self.RunfastRuleJsonString ~= "") then
        locJsonString = self.RunfastRuleJsonString
    end

    if (locJsonString ~= nil and locJsonString ~= "") then
        local ruleTable = ModuleCache.Json.decode(locJsonString)
        -- if(ruleTable.game_type == 1) then
        --     locResult = locResult .. "安徽关牌 "
        -- elseif(ruleTable.game_type == 2) then
        --     if(ruleTable.gameName == "DHJSQP_RUNFAST_RUNFAST") then
        --         locResult = locResult .. "江苏关牌 "
        --     else
        --         locResult = locResult .. "经典玩法 "
        --     end
        -- end
        local wanfaName = self:GetCurTip(ruleTable.game_type)
        locResult = locResult .. wanfaName .. " "
        locResult = locResult .. ruleTable.roundCount .. "局 "
        locResult = locResult .. ruleTable.playerCount .. "人 "
        locResult = locResult .. (ruleTable.notify_card_cnt and "显示牌数 " or "不显示牌数 ")
        locResult = locResult .. (ruleTable.allow_pass and "可过牌 " or "有牌必压 ")
        -- if(ruleTable.notify_card_cnt) then
        --     locResult = locResult .. "显示牌数 "
        -- else
        --     locResult = locResult .. "不显示牌数 "
        -- end

        -- if(ruleTable.allow_pass) then
        --     locResult = locResult .. "可过牌 "
        -- else
        --     locResult = locResult .. "有牌必压 "
        -- end

        locResult = locResult .. ruleTable.init_card_cnt .. "张牌玩法 "
        --if (ruleTable.game_type == 2) then
        --    locResult = locResult .. ruleTable.rate .. "倍积分 "
        --end

        if (ruleTable.payType == 0) then
            locResult = locResult .. "AA支付"
        elseif (ruleTable.payType == 1) then
            locResult = locResult .. "房主支付"
        elseif (ruleTable.payType == 2) then
            locResult = locResult .. "大赢家支付"
        end
    end

    print("===locResult", locResult)

    return locResult
end

function TableManager:GetRunfastRuleJsonString()
    local locJsonString = ""
    if (self.RunfastRuleJsonString ~= nil and self.RunfastRuleJsonString ~= "") then
        locJsonString = self.RunfastRuleJsonString
    end
    return locJsonString
end

function TableManager:GetRunfastRuleTable()
    local locJsonString = self:GetRunfastRuleJsonString()
    if (locJsonString ~= "") then
        return ModuleCache.Json.decode(locJsonString)
    end
    return nil
end

function TableManager:GetCurTip(curwanfaType)
    local result = ""

    --检查curwanfaType
    if (curwanfaType == nil) then
        if (self.modelData.roleData.myRoomSeatInfo.Rule) then
            local RuleTable = ModuleCache.Json.decode(self.modelData.roleData.myRoomSeatInfo.Rule)
            curwanfaType = RuleTable.game_type
        else
            print("==self.modelData.roleData.myRoomSeatInfo.Rule == nil")
        end
    end

    --查找数据
    local playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
    local tipArr = string.split(playMode.tips, "|")
    local wanfaTypeArr = string.split(playMode.wanfaType, "|")
    if (#wanfaTypeArr <= 0) then
        print("=====#wanfaTypeArr <= 0")
    else
        for i = 1, #wanfaTypeArr do
            local tempwanfaType = wanfaTypeArr[i]
            if (tempwanfaType == tostring(curwanfaType)) then
                result = tipArr[i]
            end
        end
    end
    return result
end


--心跳包
function TableManager:request_ping()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Ping")
    request.TimeStamp = os.time()
    if (not self.lastPingReqeustTime) then
        self.lastPingReqeustTime = Time.realtimeSinceStartup
    end
    Model.send_msg(self, msgId, request, "login")
end

--进入金币场
function TableManager:request_goldmatching_enter(goldId, userId)
    userId = userId or tonumber(self.modelData.roleData.userID .. '')
    local msgId, request = self.netMsgApi:create_request_data("Msg_GoldMatching_Enter")
    request.GoldID = goldId
    request.UserID = userId
    Model.send_msg(self, msgId, request, "login")
    ModuleCache.ModuleManager.show_public_module("netprompt")
end

--退出金币场
function TableManager:request_goldmathing_quit(goldId, userId)
    userId = userId or tonumber(self.modelData.roleData.userID .. '')
    local msgId, request = self.netMsgApi:create_request_data("Msg_GoldMatching_Quit")
    request.GoldID = goldId
    request.UserID = userId
    Model.send_msg(self, msgId, request, "login")
end

--判断当前游戏房间是否时金币场
function TableManager:cur_game_is_gold_room_type()
    return (1 == self.modelData.tableCommonData.tableType)
end

--进入比赛场
function TableManager:request_matching_enter(matchId, stageId, userId)
    userId = userId or tonumber(self.modelData.roleData.userID .. '')
    local msgId, request = self.netMsgApi:create_request_data("Msg_Matching_Enter")
    request.MatchID = matchId
    request.StageID = stageId
    request.UserID = userId
    Model.send_msg(self, msgId, request, "login")
    --ModuleCache.ModuleManager.hide_public_module("netprompt")
end

--报名比赛场
function TableManager:request_matching_signup(matchId, stageId, userId)
    userId = userId or tonumber(self.modelData.roleData.userID .. '')
    local msgId, request = self.netMsgApi:create_request_data("Msg_Matching_SignUp")
    request.MatchID = matchId
    request.StageID = stageId
    request.UserID = userId
    ModuleCache.ModuleManager.show_public_module("netprompt")
    Model.send_msg(self, msgId, request, "login")
end

--退赛
function TableManager:request_matching_withdraw(matchId, stageId, userId)
    userId = userId or tonumber(self.modelData.roleData.userID .. '')
    local msgId, request = self.netMsgApi:create_request_data("Msg_Matching_Withdraw")
    request.MatchID = matchId
    request.StageID = stageId
    request.UserID = userId
    ModuleCache.ModuleManager.show_public_module("netprompt")
    Model.send_msg(self, msgId, request, "login")
end

function TableManager:start_enter_gold_matching(userId, password, goldId, matchId, stageId, reconm)

    userId = userId or tonumber(self.modelData.roleData.userID .. '')
    userId = tonumber(userId .. '')
    TableManager:connect_login_server(function()
        TableManager:request_login_login_server(userId, password, nil, true)
    end,
    --登录成功回调
            function(data)

                if (not data.ErrorCode or data.ErrorCode == 0) then
                    if (data.RoomID ~= 0) then
                        if data.LoginEnv == "match" then
                            self.modelData.tableCommonData.tableType = 2
                        elseif data.LoginEnv == "new_gold" then
                            self.modelData.tableCommonData.tableType = 1
                            self.modelData.tableCommonData.goldFildId = goldId
                        else
                            self.modelData.tableCommonData.tableType = 0
                        end
                        self.modelData.hallData.hideCircle = true
                        TableManager:request_join_room_login_server(data.RoomID, nil, nil, nil)
                        return
                    end
                    if (data.LoginEnv == 'match') then
                        local jsonTable = ModuleCache.Json.decode(data.LoginArgs)
                        if self.checkLoginTimeId then
                            ModuleCache.SmartTimer.instance:Kill(self.checkLoginTimeId)
                            self.checkLoginTimeId = nil
                        end
                        TableManager:request_matching_enter(jsonTable.MatchID, jsonTable.StageID)
                        return
                    elseif (data.LoginEnv == 'new_gold') then
                        local jsonTable = ModuleCache.Json.decode(data.LoginArgs)
                        if self.checkLoginTimeId then
                            CSmartTimer:Kill(self.checkLoginTimeId)
                            self.checkLoginTimeId = nil
                        end
                        TableManager:request_goldmatching_enter(jsonTable.GoldID, userId)
                        return
                    else
                        if (goldId) then
                            TableManager:request_goldmatching_enter(goldId, userId)
                            return
                        elseif (matchId and stageId) then
                            TableManager:request_matching_signup(matchId, stageId, userId)
                            return
                        elseif reconm then
                            ModuleCache.ModuleManager.show_module("public", "bisailist",
                                    { id = reconm })
                        end
                        print('goldId, matchId, stageId 全为空？？？？？？？？？？？？')
                    end
                else
                    TableManager:disconnect_login_server()

                    if data.ErrorInfo == "密码检验失败" or data.ErrorInfo == "密码校验失败" then
                        ModuleCache.GameManager.logout()
                    end
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
                end
            end,
    --创建成功回调
            nil,
    --加入房间回调
            function(data)
                if data.ErrorCode == 0 then
                    TableManager:disconnect_login_server()
                    self:connect_game_server(nil, nil, true)
                else
                    TableManager:disconnect_login_server()
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
                end
            end, nil, true)
end

TableManager:initialize("henanmj")

return TableManager