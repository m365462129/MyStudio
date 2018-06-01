local NetClientManager = ModuleCache.net.NetClientManager
local NetMsgHandler = ModuleCache.net.NetMsgHandler

local class = require("lib.middleclass")
local Model = require('core.mvvm.model_base')
local TableManager = class('TableManager', Model)
local CSmartTimer = ModuleCache.SmartTimer.instance
local ModuleCache = ModuleCache
local Net_Hall_Login = "Msg_Hall_Login"
local Application = UnityEngine.Application
local max_reconnect_game_server_times = 7
local Buffer = ModuleCache.net.Buffer
local PlayerPrefs = UnityEngine.PlayerPrefs

function TableManager:henanmj_request_login_game_server(loginInfo)
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local msgId, request = self.netMsgApi:create_request_data("Msg_Login_Server")
    request.Password = loginInfo.Password
    request.RoomID = loginInfo.RoomID
    request.SeatID = loginInfo.SeatID
    request.AppendData = loginInfo.AppendData or ""
    request.ProtoVersion = loginInfo.ProtoVersion
    request.ClientVersion = loginInfo.ClientVersion
    Model.send_msg(self, msgId, request, "gameServer")
end

function TableManager:henanmj_request_create_room(createInfo)
    self.Rule = createInfo.Rule
    self.RoundCount = createInfo.RoundCount
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local msgId, request = self.netMsgApi:create_request_data("Msg_CreateRoom")
    request.GameName = createInfo.GameName
    request.RoundCount = createInfo.RoundCount
    request.Rule = createInfo.Rule
    request.HallID = createInfo.HallID
    Model.send_msg(self, msgId, request, "login")
end


function TableManager:connect_login_server(onConnectedCallback, onLoginAccCallback, onCreateRoomCallback, onEnterRoomCallback, onErrorCallback)
	ModuleCache.ModuleManager.show_public_module("netprompt")
	self.onConnectLoginServerCallback = onConnectedCallback
	self.onLoginAccCallback = onLoginAccCallback
	self.onCreateRoomFromLoginServerCallback = onCreateRoomCallback
	self.onEnterRoomFromLoginServerCallback = onEnterRoomCallback
	self.onConnectLoginServerErrorCallback = onErrorCallback
	print("connect_login_server...", self.onConnectLoginServerErrorCallback)
	local loginClient = NetClientManager.init_client("login", 1)
	self.modelData.loginClient = loginClient
    -- loginClient:connect("172.16.30.192:4004")
	loginClient:connect(ModuleCache.GameManager.netAdress.curServerHostIp .. "login")
	loginClient:subscibe_connect_event(function(state)
		if "Closed" == state then				
            if self.checkLoginTimeId then 
                CSmartTimer:Kill(self.checkLoginTimeId)
                self.checkLoginTimeId = nil
            end
		elseif "Connected" == state then	
			self.reconnectLoginServerTimes = 0
			if(self.onConnectLoginServerCallback) then
				self:onConnectLoginServerCallback()
			end	
            self.checkLoginTimeId = CSmartTimer:Subscribe(8, false, 0):OnComplete(function(t)
                --self:disconnect_login_server()
                self.modelData.loginClient:close()
                self:showNetErrDialog(function()
                    if(self.reconnectLoginServerTimes >= 3) then
                        ModuleCache.GameManager.logout();
                        return
                    end
                    self:reconnect_login_server()
                end)
            end).id
		else
            ModuleCache.GameManager.get_and_set_net_adress()
            if(self.reconnectLoginServerTimes >= 3) then
                self.reconnectLoginServerTimes = 0
                ModuleCache.ModuleManager.hide_public_module("netprompt")
                if(self.onConnectLoginServerErrorCallback) then
                    self:onConnectLoginServerErrorCallback()
                end
            else                
                self:reconnect_login_server()
            end
		end			
	end)
end

function TableManager:reconnect_login_server()
	self.reconnectLoginServerTimes = self.reconnectLoginServerTimes + 1
	local accountID = self.modelData.roleData.userID
    if not accountID then
		accountID = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
	end
	if accountID then
		-- local password = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_PASSWORD, "0")
		local password = self.modelData.roleData.password
		self:connect_login_server(function()
			self:request_login_login_server(accountID, password, nil)
		end,
		function(data)
			if data.UserID ~= "0" then
				if(data.RoomID and data.RoomID ~= 0) then
					self:request_join_room_login_server(data.RoomID)
				elseif(ModuleCache.ModuleManager.module_is_active("majiang", "table")) then
					self:exit_room()
				else
					self:disconnect_login_server()
				end
			else
				-- ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("登录失败，请重试")	
				self:disconnect_login_server()
			end
		end, nil, nil, self.onConnectLoginServerErrorCallback)
	end
end

function TableManager:connect_game_server(host, port, onConnectCallback)
	ModuleCache.ModuleManager.show_public_module("netprompt")
	self.connectCallback = onConnectCallback
	self.lastLoginToken = nil
	local client = NetClientManager.init_client("gameServer", 2)
	self.modelData.gameClient = client
	local accountID = self.modelData.roleData.userID
	if not accountID then
		accountID = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "0")
	end
	if self.curTableData.WebSocketSport and self.curTableData.WebSocketSport ~= 0 then  --用于连测试服
		client:connect(self.curTableData.ServerHost .. ":" .. self.curTableData.WebSocketSport)
	else
		client:connect(ModuleCache.GameManager.netAdress.curServerHostIp .. "game?token=" .. accountID)
	end
	
	client:subscibe_connect_event(function(state)
		if "Closed" == state then				--主动关闭，不会触发断线重连		
		
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
    if(self.reconnectGameServerTimes >= max_reconnect_game_server_times) then			
        ModuleCache.GameManager.logout();
        -- self:showNetErrDialog(function()
        --     -- if(self.reconnectGameServerTimes >= max_reconnect_game_server_times) then
        --     --     self.clientConnected = false
        --     --     ModuleCache.GameManager.logout();	
        --     --     return
        --     -- end							
        --     self:reconnect_game_server()	
        -- end)
    else
        self:reconnect_game_server()
    end
end



function TableManager:heartbeat_timeout_reconnect_game_server()
	-- 主动断线会触发Error
	self.modelData.gameClient:disconnect()
end

-- 离开房间
function TableManager:exit_room(tip)
	self:disconnect_login_server()
    self:disconnect_game_server()
	ModuleCache.net.NetClientManager.disconnect_all_client()
    ModuleCache.ModuleManager.hide_public_module("netprompt")
    ModuleCache.ModuleManager.destroy_package("henanmj")
    ModuleCache.ModuleManager.destroy_package("majiang")
    ModuleCache.ModuleManager.destroy_package("majiang3d")
	--ModuleCache.ModuleManager.destroy_module("majiang", "table")
    ModuleCache.ModuleManager.show_module("henanmj", "hall")
    if(tip) then
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
    if(callback) then
        if(not self.netErrNum) then
            self.netErrNum = 1
        end
        self.netErrNum = self.netErrNum + 1
        if(self.netErrNum >= 4) then    
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

function TableManager:request_login_login_server(userId, password, weiXinCode)  
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local msgId, request = self.netMsgApi:create_request_data(Net_Hall_Login)        
    request.UserID = userId or 0
    request.Password = password or ""
    request.WeiXinCode = weiXinCode or ""   
    request.Platform = ModuleCache.GameManager.customPlatformName
    request.ProtoVersion = 1
    request.ClientVersion = ModuleCache.GameManager.appVersion
    request.AppName = AppData.App_Name
    Model.send_msg(self, msgId, request, "login") --消息名在 net.net_msg_api.lua 中
end



function TableManager:request_join_room_login_server(roomId, wanfaName)
    ModuleCache.ModuleManager.show_public_module("netprompt")
    local msgId, request = self.netMsgApi:create_request_data("Msg_EnterRoom")
    request.RoomID = roomId
    if(wanfaName) then
        request.GameName = wanfaName
    end
    Model.send_msg(self, msgId, request, "login") 
end

function TableManager:initialize(...)
    Model.initialize(self, ...)
    self:refresh_voice_shake()
    self.chatMsgs = {}
    self.reconnectGameServerTimes = 0
    self.reconnectLoginServerTimes = 0
    self.sendMsgNetClientName = "gameServer"
    self.modelData = require("package.henanmj.model.model_data")

    Model.subscibe_msg_event(self, {    --登录回调
        msgName = Net_Hall_Login,
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)    
                        
            if(self.onLoginAccCallback)then
                self.onLoginAccCallback(retData)
            end
        end
    }, "login")

    Model.subscibe_msg_event(self, {
        msgName = "Msg_CreateRoom",
        callback = function(msgName, msgBuffer)
            -- ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer) 
            self:disconnect_login_server()  
            self.curTableData = {}
            if retData.RoomID == 0 then
                -- 有可能已在游戏中
                ModuleCache.ModuleManager.hide_public_module("netprompt")
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                if string.find(retData.ErrorInfo, "已在") then --需要重新登录
                    ModuleCache.GameManager.logout()
                end
            else
                self.curTableData = {
                    Password = retData.Password,
                    RoomID = retData.RoomID,
                    SeatID = retData.SeatID,
                    AppendData = ModuleCache.GPSManager.gps_info,
                    ProtoVersion = 1,
                    ClientVersion = Application.version,
                    ServerHost = retData.ServerHost,
                    ServerPort = retData.ServerPort,
                    WebSocketSport = retData.wsport,
                    modelData = self.modelData,
                    Rule = self.Rule,
                    RoundCount = self.RoundCount,
                    HallID = retData.HallID,
                    RoomType = retData.RoomType
                }
                self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort, function()
                    self:henanmj_request_login_game_server(self.curTableData)
                end)
            end
        end
    }, "login")

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Login_Server",
        callback = function(msgName, msgBuffer)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)    
            if retData.Error == 0 then
                ModuleCache.SoundManager.stop_music("henanmj")
                ModuleCache.ModuleManager.destroy_package("henanmj")
                ModuleCache.ModuleManager.show_module_only("majiang", "table")
                self:begin_location(true, true)
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
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)  
            self:disconnect_login_server()
            self.curTableData = {}
            if retData.Error == 0 then
                if string.sub(retData.Rule,1,1) == "{" then
		            local roomRule = ModuleCache.Json.decode(retData.Rule)
                        if (AppData.isPokerBijiRule(roomRule.gameName)) then
                        local roleData = self.modelData.roleData
                        local myRoomSeatInfo = {}
                        myRoomSeatInfo.RoomID = retData.RoomID
                        myRoomSeatInfo.ServerHost = retData.ServerHost
                        myRoomSeatInfo.ServerPort = retData.ServerPort
                        myRoomSeatInfo.SeatID	= retData.SeatID
                        myRoomSeatInfo.Password = retData.Password
                        myRoomSeatInfo.Rule = retData.Rule
                        roleData.myRoomSeatInfo = myRoomSeatInfo	
                        TableManagerPoker.reconnectGameServerTimes = 0
                        TableManagerPoker:connect_game_server(function()
                            TableManagerPoker:request_login_game_server(self.modelData.roleData.userID, self.modelData.roleData.myRoomSeatInfo.Password)
                        end,
                        --登录回调
                        function(data)
                            if(not data.err_no  or data.err_no == "0") then   			
                                ModuleCache.ModuleManager.destroy_module("biji", "joinroom")
                                ModuleCache.ModuleManager.destroy_module("henanmj", "joinroom")
                                ModuleCache.ModuleManager.destroy_module("henanmj", "hall")
                                ModuleCache.SoundManager.stop_music("biji")
                                ModuleCache.ModuleManager.show_module("biji", "tablebiji")
                            else
                                TableManagerPoker:disconnect_game_server()
                                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)	
                                self:removeLastNum()
                                self.joinRoomView:refreshRoomNumText(self.strRoomNum)
                            end
                        end)
                        return 
                    end
		        end


                ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")
                self.curTableData = 
                {
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
                    ClientVersion = Application.version,
                    modelData = self.modelData,
                    HallID = retData.HallID,
                    RoomType = retData.RoomType
                }
                self:connect_game_server(self.curTableData.ServerHost, self.curTableData.ServerPort, 
                function()
                    self:henanmj_request_login_game_server(self.curTableData)
                end)
            else 
                if(ModuleCache.ModuleManager.module_is_active("majiang", "table")) then
                    self:exit_room()
                else
                    if(retData.Error == -8) then
                        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您尚未加入此亲友圈，是否申请加入？"), function()
                            ModuleCache.ModuleManager.show_module("henanmj", "museumjoin", retData.HallID)
                        end, nil)
                    else
                        -- 进入麻将馆时可能会提示用“您已在房间中，请重试”
                        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.ErrorInfo)
                        if string.find(retData.ErrorInfo, "已在") then
                            ModuleCache.GameManager.logout()
                        end
                        if retData.Error == -2 then
                            if(self.openShake) then
                                ModuleCache.GameSDKInterface:ShakePhone(250)
                            end
                        end
                    end
                end
            end        
        end
    }, "login")
end

function TableManager:clear_strategy_vals()
    self.strategeVals = { {1},{1},{1,2},{1,2} }
    for i=1,#self.strategeVals do
		for j=1,#self.strategeVals[i] do
            PlayerPrefs.SetInt("tableStrategy_value_" .. i .. "_" .. j, 0)
		end 
	end
end

function TableManager:refresh_voice_shake()
    self.openVoice = (PlayerPrefs.GetInt("openVoice", 1) == 1)
    self.openShake = (PlayerPrefs.GetInt("openShake", 1) == 1)
end

function TableManager:disconnect_game_server(notClearData)
    self:clear_strategy_vals()
    self.modelData.gameClient:clear_subscibe_connect_event()
    self.modelData.gameClient:close()
    self.connectCallback = nil
    self.lastLoginToken = nil
    if(not notClearData) then
        self.curTableData = {}
    end
end

function TableManager:disconnect_login_server()
    -- self.modelData.loginClient:clear_subscibe_connect_event()
    self.modelData.loginClient:close()
    self.onCreateRoomFromLoginServerCallback = nil
    self.onEnterRoomFromLoginServerCallback = nil
end

function TableManager:play_back_on_id(playBackId)
    local requestData = {
		params = {
			uid = self.modelData.roleData.userID,
            shortRecordId = playBackId
		},
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/getRecordId?",
	}

    Util.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
			self:play_back(retData.data, retData.data.players)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
        end
    end, function(error)
        print(error.error)
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
    end)
end

function TableManager:share_play_back_id(playBackId)
    local requestData = {
		params = {
			uid = self.modelData.roleData.userID,
            recordId = playBackId
		},
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/getShortRecordId?",
	}
    
    Util.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
			ModuleCache.ShareManager().share_play_back(self.modelData.roleData.userID, retData.data.shortRecordId)
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("分享回放码错误")
        end
    end, function(error)
        print(error.error)
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("分享回放码错误")
    end)
end

function TableManager:play_back(data, players)
	self:get_play_back_info(data.recordId, function(gamestates, data)
        local index = 1
        for i=1,#players do
		    local userId = players[i].userId
            if(userId .. "" == self.modelData.roleData.userID) then
                 index = i
            end
        end
        self.curTableData = 
        {
            isPlayBack = true,
            SeatID = index - 1,
            videoData = data,
            modelData = self.modelData,
            gamestates = gamestates,
            players = players
        }
		ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.show_module_only("majiang", "table")
		ModuleCache.ModuleManager.show_module("majiang", "playback")
	end)
end

function TableManager:get_play_back_info(playbackId, callback)
    local requestData = {
		params = {
			uid = self.modelData.roleData.userID,
            recordId = playbackId
		},
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/playback?",
	}
    
    Util.http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        --  {"errMsg":"未知的回放记录","ret":-1,"success":false}
        if www.bytes and www.bytes.Length > 0 and www.bytes[0] == 123 then
            local retData = ModuleCache.Json.decode(www.text)
            if retData.data ~= 0 then
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)	
                return 
            end
        end
        local buffer = Buffer.Create(0)  --会在C#层自动回收
		local videoData = buffer:GetPlayBackInfo(www.bytes)
        local videoTable = nil
        if videoData.rule then
            videoTable = {}
            videoTable.gamerule = videoData.rule
        else
            videoTable = self:unpack_msg_new("Msg_VideoCode", videoData.headData) 
        end
		local gamestates = {}
		for i=1,videoData.frames.Count do
			local retData, error = self:unpack_msg_new("Msg_Table_GameStateNTF", videoData.frames[i - 1].buffer) 
			table.insert(gamestates, retData)
		end
		callback(gamestates, videoTable)
    end, function(error)
        print(error.error)
    end)
end

function TableManager:unpack_msg_new(msgName, dataBuffer)
    local ret = self.netMsgApi:create_ret_data(msgName)
    ret:ParseFromString(dataBuffer)
    return ret
end


function TableManager:join_room(roomId, gameName)
	self:connect_login_server(function()
		self:request_login_login_server(self.modelData.roleData.userID, self.modelData.roleData.password)
	end,
	--登录回调
	function(data)
		if(not data.ErrorCode or data.ErrorCode == 0)then
			self:request_join_room_login_server(roomId, gameName)
		else
			self:disconnect_login_server()
			if data.ErrorInfo == "密码检验失败" or data.ErrorInfo == "密码校验失败" then
                ModuleCache.GameManager.logout()
            end
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)	
		end
	end,
	nil,nil,function ()
        self:showNetErrDialog(nil)
    end)
end

function TableManager:request_chat(msg)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Message")
    request.Message = ModuleCache.Json.encode(msg)
    request.AppendData = ModuleCache.GPSManager.gps_info
    Model.send_msg(self, msgId, request, "gameServer", 1)
end

function TableManager:begin_location(isRegeocode, sendToGameServer)
    if(ModuleCache.GameManager.iosAppStoreIsCheck)then
        return
    end
    ModuleCache.WechatManager.onBeginLocation(isRegeocode, function(data)
		print_table(data)
        if(not data) then
            data = {}
        end
        if(not data.address) then
            data.address = "未开启位置获取功能"
            data.latitude = 0
            data.longitude = 0
        end
        ModuleCache.GPSManager.gps_info = data.latitude .. "," .. data.longitude .. "," .. data.address
        ModuleCache.GPSManager.gpsAddress = data.address
        if sendToGameServer then
            data.chatType = 4
            self:request_chat(data)
        end
    end)
end

TableManager:initialize("henanmj")

return TableManager