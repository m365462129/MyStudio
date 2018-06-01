-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local BiSaiListModule = class("Public.BiSaiListModule", ModuleBase)
local GameSDKInterface = ModuleCache.GameSDKInterface
local TableManager = TableManager
-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local CSmartTimer = ModuleCache.SmartTimer.instance
local MatchingManager = require("package.public.matching_manager")
function BiSaiListModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "bisailist_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function BiSaiListModule:on_module_inited()

end

-- 绑定module层的交互事件
function BiSaiListModule:on_module_event_bind()
    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.view:refreshPlayerInfo(self.modelData.roleData)
    end)
    self:subscibe_package_event("Event_Package_Refresh_MatchList", function(eventHead, eventData)
        self:get_bisai_list(self.id)
    end)
    self:subscibe_package_event("match_entry_info_change", function(eventHead, eventData)
        print("收到比赛场人数改变推送", eventData, type(eventData), eventData.matchId, eventData.stageNum, eventData.preEntryNum, eventData.currentEntryNum)
        local id, matchdata = self:matchid2Clickid(eventData.matchId, eventData.stageNum)
        print("匹配obj id", id)
        if id > 0 then
            self.view:match_info_change(id, eventData, matchdata)
        end
    end)


    --报名成功
    self:subscibe_package_event("Event_Matching_SignUp", function(eventHead, eventData)
        print("报名成功")
        self.havebaoming = true
        if self.view then
            self:subscibe_time_event(1.2, false, 0):OnComplete(function( t )
                self:get_bisai_list( self.id, function(data)
                    for i = 1, #data do
                        if data[i].matchId == self.clickdata.matchId then
                            self.view:refreshSignupNum(data[i].currentEntryNum )
                        end
                    end
                end)
            end)
            self.view:baoming_success()
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("报名成功")
        end
        self:dispatch_package_event("Event_Package_RefreshUserInfo")
    end)
    --刷新界面
    self:subscibe_package_event("Event_Refresh_Matching", function(eventHead, eventData)
        if self.view then
            print("刷新比赛列表", eventData)
            if eventData then
                self:subscibe_time_event(1.2, false, 0):OnComplete(function( t )
                    self:get_bisai_list(self.id)
                end)
            else
                if not self.havebaoming then
                    self.view:signUpView(false)
                end
            end

        end
    end)
    --Event_Refresh_Matching
    --退赛成功
    self:subscibe_package_event("Event_Matching_Withdraw", function(eventHead, eventData)

        if eventData.error == 0 then
            self:tuisai_deal()
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("退赛成功")
        else
            self:getmatchbyid(eventData.MatchID, eventData.StageID, function(info)
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.ErrorInfo)
                self:reconnet_match()
            end )
        end

    end)

    --事件
    self:subscibe_package_event("Event_Matching_Notify_MatchDynamic", function(eventHead, eventData)
        --eventData.EventArgs
        --print("收到事件消息", eventData.EventArgs, eventData.CurLoopNo)
        local ev = ModuleCache.Json.decode(eventData.EventArgs)

        if ev.MatchState == -1 then
            --比赛取消
            if (TableManager.loginClientConnected) then
                TableManager:disconnect_login_server()
            end
            self.havebaoming = false
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(
                    "您报名的比赛因人数不足，已取消比赛",
                    function()
                        if self.view then
                            self.view:signUpView(false)
                        end

                    end)
        elseif ev.Type == "match_info" and ev.MatchState == 0 then
            --刷新界面显示人数
            if self.view then
                self.view:refreshSignupNum(ev.SignupUserCnt)
            end
        elseif ev.Type == "loop_start" and ev.MatchState == 1 and eventData.CurLoopNo then
            --比赛开始事件
            local lunkong = false
            for i = 1, #ev.PromotionUsers do
                if tostring(ev.PromotionUsers[i]) == tostring(self.modelData.roleData.userID) then
                    lunkong = true
                end
            end
            if lunkong then
                if self.haveEnter then
                    return
                end
                print("玩家轮空进入匹配界面")
                self.haveEnter = true
                local matchInfo = {
                    MatchID = eventData.MatchID,
                    StageID = eventData.StageID,
                    CurLoopCnt = eventData.CurLoopNo,
                    UserCnt = #eventData.Users,
                    SignupUserCnt = #eventData.Users,
                    RoomCnt = ev.TotalRoomCnt,
                    QuitScore = ev.CurQuitScore,
                    Rank = 0,
                    Score = 0,
                }
                for i = 1, #eventData.Users do
                    if tonumber(eventData.Users[i].UserID) == tonumber(self.modelData.roleData.userID) then
                        matchInfo.Score = eventData.Users[i].Score
                        matchInfo.Rank = eventData.Users[i].Rank
                    end
                end
                ModuleCache.ModuleManager.show_module("public", "tablematch", { matchtype = 2, matchid = eventData.MatchID, matchinfo = matchInfo })
                ModuleCache.ModuleManager.destroy_package("public", "tablematch")
            else
                print("玩家没有轮空等等进入比赛界面")
            end
        end
    end)
    ----匹配动态信息
    self:subscibe_package_event("Event_Matching_Notify_RoomInfo", function(eventHead, eventData)
        if self.haveEnter then
            return
        end
        print("比赛进入牌局", eventData.RoomID)
        if (eventData.RoomID == 0) then
            --刷新匹配信息
        else
            if (TableManager.loginClientConnected) then
                TableManager:disconnect_login_server()
            end
            self.haveEnter = true
            TableManager:proce_enterMatchingRoom(eventData.Host, eventData.Port, eventData.RoomID, eventData.UserID, eventData.Password, eventData.PlayRule, 2)
            self:subscibe_time_event(5, false, 1):OnComplete(function()
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("网络连接失败")
                ModuleCache.GameManager.logout()
            end)
            --ModuleCache.ModuleManager.destroy_package("public");
        end
    end)
end

-- 绑定loginModel层事件，模块内交互
function BiSaiListModule:on_model_event_bind()


end

function BiSaiListModule:tuisai_deal()
    print("退赛成功")
    self.havebaoming = false
    if (TableManager.loginClientConnected) then
        TableManager:disconnect_login_server()
    end
    if self.view then
        self:subscibe_time_event(1.2, false, 0):OnComplete(function( t )
            self:get_bisai_list(self.id)
        end)
        if self.exitClick == "Close" then
            self.view:signUpView(false)
        else
            self.view:tuisai_success()
        end

    end
    self:dispatch_package_event("Event_Package_RefreshUserInfo")
end

function BiSaiListModule:on_update()
    if (self.havebaoming) then
        if ((not self.lastPingTime) or (self.lastPingTime + 3 < Time.realtimeSinceStartup)) then
            self.lastPingTime = Time.realtimeSinceStartup
            if (TableManager.loginClientConnected) then
                TableManager:request_ping()
            end
            --if self.id and self.view then
            --    self:get_bisai_list(self.id)
            --end

        end

        if TableManager.loginClientConnected and self.modelData.loginClient and self.modelData.loginClient.clientConnected and (self.modelData.loginClient.lastReceivePackTime + 15 < Time.realtimeSinceStartup) then
            TableManager:heartbeat_timeout_reconnect_login_server()
        end
    end
    if (self.id and self.view and ((self.lastUpdateTime and self.lastUpdateTime + 30 < Time.realtimeSinceStartup) or not self.lastUpdateTime) ) then
        print("更新比赛列表")
        self.lastUpdateTime = Time.realtimeSinceStartup

        if self.id and self.view then
            self:get_bisai_list(self.id)
        end

    end
end

--{id=比赛场id,isSigned=是否已报名}
function BiSaiListModule:on_show(data)
    if data.isSigned then
        self:getmatchbyid(data.id, data.stageId, function(info)
            self.id = info.matchType
            self.havebaoming = true
            self.view:refreshPlayerInfo(self.modelData.roleData)
            self.view:set_name(self:get_name(self.id))
            self:get_bisai_list(self.id)
            self.clickdata = info
            self:baoming(info)

        end)
    else
        self.id = data.id
        self.view:refreshPlayerInfo(self.modelData.roleData)
        self.view:set_name(self:get_name(self.id))
        self:get_bisai_list(self.id)
        self.view:signUpView(false)
        self.havebaoming = false

    end
end

function BiSaiListModule:get_name(id)
    if id == 1 then
        return "金币赛"
    elseif id == 2 then
        return "钻石赛"
    elseif id == 3 then
        return "话费赛"
    elseif id == 4 then
        return "实物赛"
    end
end

function BiSaiListModule:on_click(obj, arg)
    print("点击", obj.name, obj.transform.parent.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj.name == "ImageBack" then
        ModuleCache.ModuleManager.destroy_module("public", "bisailist")
        return
    elseif obj.name == "Gold" then
        ModuleCache.ModuleManager.show_module("public", "shopbase")
    elseif obj.name == "Gem" then
        ModuleCache.ModuleManager.show_module("public", "shopbase", 1)
    elseif obj.name == "BtnRecord" then
        ModuleCache.ModuleManager.show_module("public", "matchrecord")
    elseif obj.name == "BaoMing1" or obj.name == "BaoMingFee" then
        self.clickid = tonumber(obj.transform.parent.parent.name)
        self.clickdata = self.matchData[self.clickid]
        self:request_baoming_data(self.clickdata)
    elseif obj.name == "BaoMing2" then
        self.clickid = tonumber(obj.transform.parent.parent.name)
        self.clickdata = self.matchData[self.clickid]
        self:yuyue(self.clickdata)
    elseif obj.name == "BtnExit" then
        self.exitClick = "Exit"
        self:sureExit()
    elseif obj.name == "BtnClose" then
        self.exitClick = "Close"
        if not self.havebaoming then
            self.view:signUpView(false)
        else
            self:sureExit()
        end
    elseif obj.name == "BtnWant" then

        self:request_baoming(self.clickdata)


    elseif obj.name == "AlarmTest" then
        --print("设置闹钟0")
        --local t = os.time()
        --ModuleCache.ModuleManager.show_module("public", "matchrank", self.matchData[tonumber(self.clickid)].matchId)
        --GameSDKInterface:SetAlarm((t + 10) * 1000, "您预约的" .. "比赛" .. "开始报名了")
        if (TableManager.loginClientConnected) then
            TableManager:disconnect_login_server()
        end
        TableManager:start_enter_gold_matching(self.modelData.roleData.userID,
                self.modelData.roleData.password, nil, nil, nil, self.id)
    end
end

function BiSaiListModule:matchid2Clickid(matchid, stageNum)
    local index = 0
    if not self.matchData then
        return 0
    end
    for i = 1, #self.matchData do
        if self.matchData[i].matchId == matchid and self.matchData[i].stageNum == stageNum then
            index = i
        end
    end
    return index, self.matchData[index]
end

function BiSaiListModule:reconnet_match()
    if (TableManager.loginClientConnected) then
        TableManager:disconnect_login_server()
    end
    TableManager:start_enter_gold_matching(self.modelData.roleData.userID,
            self.modelData.roleData.password, nil, nil, nil, self.id)
end

function BiSaiListModule:sureExit()
    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
            "您报名的比赛即将开始，真的要狠心离开吗？",
            function()
                --退赛
                if (TableManager.loginClientConnected) then
                    TableManager:request_matching_withdraw(self.clickdata.matchId, self.clickdata.stageNum, self.modelData.roleData.userID)
                else
                    self:reconnet_match()
                end

            end, nil, true, "退赛", "取消")
end

function BiSaiListModule:request_baoming(data)
    local type = data.entryConditions[1].compareType
    local can = true
    if type == 2 then
        can = false
    end
    for i = 1, #data.entryConditions do
        local num = 0
        if data.entryConditions[i].entryFeeType == 1 then
            num = self.modelData.roleData.cards
        elseif data.entryConditions[i].entryFeeType == 5 then
            num = self.modelData.roleData.gold
        end
        if type == 1 then
            if num < data.entryConditions[i].entryFeeNum then
                can = false
            end
        else
            if num >= data.entryConditions[i].entryFeeNum then
                can = true
            end
        end
    end
    if can then
        self:getmatchbyid(data.matchId, data.stageNum, function(info)
            TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,
                    nil, info.matchId, info.stageNum)
        end)
    else
        if data.entryConditions[1].entryFeeType == 1 then
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
                    "报名费不足，是否去充值？",
                    function()
                        ModuleCache.ModuleManager.show_module("public", "shopbase", 1)

                    end, nil, true, "充值", "取消", "钻石不足")
        else
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
                    "报名费不足，是否去充值？",
                    function()
                        ModuleCache.ModuleManager.show_module("public", "shopbase")

                    end, nil, true, "充值", "取消", "金币不足")
        end

    end


end

function BiSaiListModule:request_baoming_data(data)
    self.view:baoming(data, 2)
    self:getmatchbyid(data.matchId, data.stageNum, function(info)
        --获取服务器真实时间
        self.view:baoming(info, 2)
    end)

    self:get_maxrank(data.matchId)
    self.view:signUpView(true)
end

function BiSaiListModule:baoming(info)
    --判断报名条件
    --可以报名
    self.view:baoming(info, 1)
    self:get_maxrank(info.matchId)
    self.view:signUpView(true)

end

function BiSaiListModule:yuyue(info)
    --可以预约
    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
            "<color=red>" .. info.matchName .. "</color>比赛将于\n" .. info.entryStartTime .. "\n开启报名，是否预约？",
            function()
                self:reservation(info.matchId, info.stageNum, info.entryStartTimeSecond, info.matchName, info.serviceTimeSecond)

            end, nil, true, "确定", "取消")
end


--获取比赛列表
function BiSaiListModule:get_bisai_list(id, fun)
    local addStr = "match/getMatchs?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            uid = self.modelData.roleData.userID,
            matchType = id,
            gameId = AppData.get_app_and_game_name()
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            self.matchData = retData.data
            self.view:viewList(retData.data)
            if fun then
                fun(retData.data)
            end
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end


--获取最高排名 GET /match/getUserMatchMaxRank  int
function BiSaiListModule:get_maxrank(id)
    local addStr = "match/getUserMatchMaxRank?"
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
            self.view:maxRank(retData.data)
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

--预约 GET /match/preEntry  bool
function BiSaiListModule:reservation(id, stage, time, name, servertime)
    local addStr = "match/preEntry?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
            matchId = id,
            stageNum = stage
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("预约成功！")
            self:get_bisai_list(self.id)
            local t = time - servertime
            --设置闹钟
            GameSDKInterface:SetAlarm(time * 1000, "您预约的" .. name .. "开始报名了")
            CSmartTimer:Subscribe(t, false, 1):OnComplete(function( t )
                ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(
                        "您预约的<color=red>" .. name .. "</color>比赛已经开始报名啦！名额有限，快去报名吧！")
                --震动
                ModuleCache.GameSDKInterface:ShakePhone(500)
            end)
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end
--领奖 GET /match/receivesAward  bool
function BiSaiListModule:receive_award(id)
    local addStr = "match/receivesAward?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            uid = self.modelData.roleData.userID,
            resultId = id
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then

        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

function BiSaiListModule:getmatchbyid(id, stagenum, fun)
    local addStr = "match/getById?"
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = false,
        params = {
            uid = self.modelData.roleData.userID,
            matchId = id
        }

    }
    if stagenum then
        requestData.params.stageNum = stagenum
    end
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            fun(retData.data)
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

return BiSaiListModule



