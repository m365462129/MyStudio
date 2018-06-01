-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableMatchView = Class('tableMatchView', View)

local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local GameSDKInterface = ModuleCache.GameSDKInterface
local Vector3 = Vector3
function TableMatchView:initialize(...)
    -- 初始View
    View.initialize(self, "public/module/tablematch/public_windowtablematch.prefab", "Public_WindowTableMatch", 1)

    --View.set_1080p(self)
    self.players = {}
    self.pos = {}
    self.tablepos = {}
    self.getbg = false
    self.initBaseSeat = false
    self.holder = GetComponentWithPath(self.root, "Holder/SeatMajong", ComponentTypeName.Transform).gameObject
    self.leftPannel = GetComponentWithPath(self.root, "TopRight/TopRoot/RightMenu", ComponentTypeName.Transform).gameObject
    self.matchinfo = GetComponentWithPath(self.root, "Info/MatchInfo", ComponentTypeName.Transform).gameObject
    self.uiState = GetComponentWithPath(self.root, "Info", "UIStateSwitcher")
    self.uiState3d = GetComponentWithPath(self.root, "Info/GoldInfo", "UIStateSwitcher")
    ComponentUtil.SafeSetActive(self.holder, false)
    ComponentUtil.SafeSetActive(self.leftPannel, false)
    self:refreshBatteryAndTimeInfo()
    self:initLocalView()
end

function TableMatchView:show_view(matchtype)
    self.uiState:SwitchState(matchtype)
end


--matchcurdata 比赛场信息
--    {
--    MatchID 比赛场id
--    StageID
--    CurLoopCnt 当前轮
--    UserCnt 剩余比赛玩家数
--    SignupUserCnt 总报名人数
--    RoomCnt 剩余房间数
--    QuitScore 淘汰分
--    Rank 当前名次
--    }
function TableMatchView:initTable(matchtype, goldinfo, matchinfo, roleData, matchcurdata)

    local playernum
    local goldname
    local golddifen
    local param1 = ""
    local param2 = ""
    if goldinfo then
        local rule = ModuleCache.Json.decode(goldinfo.playRule)
        param1 = rule.QiHuBeiShu
        param2 = rule.FengDingType
        if tonumber(param2) == 1 then
            param2 = 50
        elseif tonumber(param2) == 2 then
            param2 = 100
        elseif tonumber(param2) == 3 then
            param2 = 80
        elseif tonumber(param2) == 4 then
            param2 = 200
        end
        playernum = rule.playerCount or rule.PlayerNum
        goldname = goldinfo.goldName
        golddifen = goldinfo.baseScore
    else
        --appname = matchinfo.gameId
        playernum = matchinfo.playerCount
    end
    self.playerCount = playernum
    --local str = string.split(appname, "_")

    self.uiState:SwitchState(matchtype)
    if matchtype == 1 then
        local infoText = GetComponentWithPath(self.root, "Info/GoldInfo/Info", ComponentTypeName.Text)
        infoText.text = goldname .. " 底分:" .. golddifen .. "\n起胡倍数：" .. param1 .. " 封顶倍数：" .. param2
    elseif matchtype == 2 then
        self:matchinfo_view(matchcurdata, matchinfo.matchName)
    end
    self.mypinfo = { playerid = roleData.userID, localpos = 1 }
    local score
    if matchtype == 2 then
        score = 0
        if matchcurdata.Score then
            score = matchcurdata.Score
        end
        self:set_posinfo(1, roleData, score)
    else
        self:set_posinfo(1, roleData)
        self:get_userinfo(roleData.userID, function(_, data)
            if self.seats[1] and data then
                local textGold = GetComponentWithPath(self.seats[1], "Info/HeadBg/SomeInfoRoot/CurrencyRoot/Gold/Count", ComponentTypeName.Text)
                textGold.text = Util.filterPlayerGoldNum(data.gold)
            end
        end)
    end

    self.tableinit = true



end


function TableMatchView:initLocalView()
    local gamename = AppData.Game_Name

    if gamename == "HSHH" then
        gamename = "HENANMJ"
    end
    print("加载金币场背景：", gamename)
    local bgp = GetComponentWithPath(self.root, "GameName/" .. gamename, ComponentTypeName.Transform).gameObject
    local bg = self:getBg(gamename)
    if bg and bgp then
        local background = GetComponentWithPath(bgp, "Background", ComponentTypeName.Transform)
        bg.transform:SetParent(background)
    end

    self.seats = {}
    if not self.initBaseSeat and bgp then
        for i = 1, 6 do
            local s = GetComponentWithPath(bgp, "Center/Seats/" .. i, ComponentTypeName.Transform).gameObject
            local target = ComponentUtil.InstantiateLocal(self.holder, Vector3.zero)
            local obj = GetComponentWithPath(target, "Info/HeadBg", ComponentTypeName.Transform).gameObject
            local matching = GetComponentWithPath(target, "Info/Matching", ComponentTypeName.Transform).gameObject
            target.transform:SetParent(s.transform)
            target.transform.localScale = Vector3.one
            target.transform.localPosition = Vector3.zero
            target.name = "Seat"
            --local uiStated = GetComponentWithPath(target, "", "UIStateSwitcher")
            --if i == 2 then
            --    uiStated:SwitchState("Right")
            --else
            --    uiStated:SwitchState("Left")
            --end
            ComponentUtil.SafeSetActive(target, true)
            ComponentUtil.SafeSetActive(matching, true)
            ComponentUtil.SafeSetActive(obj, false)
            table.insert(self.seats, target)
        end
        self.initBaseSeat = true
    end
    self:show();
end

function TableMatchView:matchinfo_view(matchInfo, matchName)
    if matchName then
        local nameText = GetComponentWithPath(self.root, "Info/MatchInfo/Type/Type1Root/UpText", ComponentTypeName.Text)
        nameText.text = matchName
    end
    if matchInfo then
        self.matchinfoText = GetComponentWithPath(self.root, "Info/MatchInfo/DownText", ComponentTypeName.Text)
        self.matchnumText = GetComponentWithPath(self.root, "Info/MatchInfo/JinJi/Num", ComponentTypeName.Text)

        self.quitScore = matchInfo.QuitScore
        self.matchinfoText.text = "淘汰分:" .. matchInfo.QuitScore .. " 名次:" .. matchInfo.Rank .. " 轮数:" ..
                matchInfo.CurLoopCnt .. " 人数:" .. matchInfo.UserCnt
        self.matchnumText.text = matchInfo.RoomCnt
    end
end

function TableMatchView:hide_matchinfo()
    ComponentUtil.SafeSetActive(self.matchinfo, false)
end

function TableMatchView:update_matchinfo(matchinfo)
    print_table(matchinfo, "更新比赛信息")
    print("牌桌初始化：", self.tableinit)
    if not matchinfo or not self.tableinit then
        return
    end
    self.noneNatchInfo = nil
    self:matchinfo_view(matchinfo)
    if self.seats[1] then
        local textScore = GetComponentWithPath(self.seats[1], "Info/HeadBg/SomeInfoRoot/CurrencyRoot/Point/Text", ComponentTypeName.Text)
        local goldSwitch = GetComponentWithPath(self.seats[1], "Info/HeadBg/SomeInfoRoot/CurrencyRoot", "UIStateSwitcher")
        textScore.text = matchinfo.score
        goldSwitch:SwitchState("Point")
    end
end

function TableMatchView:pannelExpand(b)
    ComponentUtil.SafeSetActive(self.leftPannel, b)
end

function TableMatchView:update_player(players)
    print_table(players, "更新玩家")
    if not self.tableinit then
        return
    end
    for i = 1, #players do
        local id = tonumber(players[i].UserID)
        if id == tonumber(self.mypinfo.playerid) then
            self.mypinfo.serverpos = players[i].SeatID
            self.pos[1] = id
            self.players[id] = {}
            self.players[id].userID = id
            self.players[id].pos = 1
            self.players[id].serverpos = players[i].SeatID
            self:refreshSeatPlayerInfo(self.players[id])
        end
    end
    for i = 1, #players do
        local id = players[i].UserID
        if tonumber(id) ~= self.mypinfo.playerid and self.mypinfo.serverpos then
            if self.players[id] and self.players[id].playerInfo then
                self:refreshSeatPlayerInfo(self.players[id])
            else
                local pos = self:serverSeatIdToLocal(players[i].SeatID, self.mypinfo.serverpos, self.playerCount)
                self.players[id] = {} -- pos
                self.players[id].userID = id
                self.players[id].pos = pos
                self.players[id].serverpos = players[i].SeatID
                self:refreshSeatPlayerInfo(self.players[id])
            end
            self.pos[self.players[id].pos] = id
        end
        print("玩家位置", id, self.players[id].pos)
    end
    local le = {}
    for pos, id in pairs(self.pos) do
        local e = false
        for i = 1, #players do
            if tonumber(id) == tonumber(players[i].UserID) then
                e = true
            end
        end
        if not e then
            self.pos[pos] = nil
            table.insert(le, pos)
        end
    end
    if #le > 0 then
        for i = 1, #le do
            self:playerleave(le[i])
            self.tablepos[le[i]] = nil
        end
    end
end

function TableMatchView:serverSeatIdToLocal(targetSeatId, mySeatId, seatCount)
    local localIndex = targetSeatId + (1 - mySeatId) + seatCount
    if (localIndex > seatCount) then
        return localIndex - seatCount
    else
        return localIndex;
    end
end

--刷新座位玩家信息
function TableMatchView:refreshSeatPlayerInfo(seatInfo)
    if (seatInfo.playerInfo) then
        --print("======TableMatchView:refreshSeatPlayerInfo1111======")
        self:setPlayerInfo(seatInfo.pos, seatInfo.playerInfo)
    else
        --print("======TableMatchView:refreshSeatPlayerInfo2222======",self.tablepos[seatInfo.pos],seatInfo.userID)
        if not (self.tablepos[seatInfo.pos] and tonumber(self.tablepos[seatInfo.pos]) == tonumber(seatInfo.userID)) then
            seatInfo.playerInfo = nil
            self:get_userinfo(seatInfo.userID, function(err, data)
                if (err) then
                    self:refreshSeatPlayerInfo(seatInfo)
                    return
                end
                local playerInfo = {}
                playerInfo.userID = data.userId
                playerInfo.nickname = data.nickname
                playerInfo.headImg = data.headImg
                playerInfo.gold = data.gold
                seatInfo.playerInfo = playerInfo
                self:setPlayerInfo(seatInfo.pos, seatInfo.playerInfo, seatInfo.score)
            end)
        end
    end
end

function TableMatchView:get_userinfo(playerId, callback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = playerId,
        },
        cacheDataKey = "user/info?uid=" .. playerId
    }

    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end, function(error)
        print(error.error)
        callback(error.error, nil)
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then
            --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end)

end

function TableMatchView:setPlayerInfo(pos, playerInfo, score)
    --print("====TableMatchView:setPlayerInfo====",self.tablepos[pos],playerInfo.userId,self.seats[pos])
    if not (self.tablepos[pos] and tonumber(self.tablepos[pos]) == tonumber(playerInfo.userId)) and self.seats[pos] then
        --print("玩家进入", pos, playerInfo.userId)
        self:set_posinfo(pos, playerInfo, score)
    end
end

function TableMatchView:set_posinfo(pos, roleData, score)
    --print_table(roleData, "set_posinfo")
    --print("set_posinfo", pos, score, tostring(self.seats[pos]))
    local obj = self.seats[pos]
    if not obj then
        return
    end
    obj.name = roleData.userID
    self.tablepos[1] = roleData.userID
    local textPlayerName = GetComponentWithPath(obj, "Info/HeadBg/SomeInfoRoot/TextName", ComponentTypeName.Text)
    local imagePlayerHead = GetComponentWithPath(obj, "Info/HeadBg/Avatar/Mask/Image", ComponentTypeName.Image)
    local head = GetComponentWithPath(obj, "Info/HeadBg", ComponentTypeName.Transform).gameObject
    local matching = GetComponentWithPath(obj, "Info/Matching", ComponentTypeName.Transform).gameObject
    local textScore = GetComponentWithPath(obj, "Info/HeadBg/SomeInfoRoot/CurrencyRoot/Point/Text", ComponentTypeName.Text)
    local textGold = GetComponentWithPath(obj, "Info/HeadBg/SomeInfoRoot/CurrencyRoot/Gold/Count", ComponentTypeName.Text)
    local goldSwitch = GetComponentWithPath(obj, "Info/HeadBg/SomeInfoRoot/CurrencyRoot", "UIStateSwitcher")
    ComponentUtil.SafeSetActive(matching, false)
    if type(score) == "number" then
        textScore.text = Util.filterPlayerGoldNum(score)
        goldSwitch:SwitchState("Point")
    else
        textGold.text = Util.filterPlayerGoldNum(roleData.gold)
        goldSwitch:SwitchState("Gold")
    end
    if roleData.nickname then
        textPlayerName.text = Util.filterPlayerName(roleData.nickname)

        self:startDownLoadHeadIcon(imagePlayerHead, roleData.headImg)
        ComponentUtil.SafeSetActive(head, true)
    else
        self:get_userinfo(roleData.userID, function(error, data)
            textGold.text = Util.filterPlayerGoldNum(data.gold)
            textPlayerName.text = Util.filterPlayerName(data.nickname)
            self:startDownLoadHeadIcon(imagePlayerHead, data.headImg)
            ComponentUtil.SafeSetActive(head, true)
        end)
    end

end

function TableMatchView:playerleave(pos)
    if not self.seats[pos] then
        return
    end
    print("玩家离开,", pos)
    local head = GetComponentWithPath(self.seats[pos], "Info/HeadBg", ComponentTypeName.Transform).gameObject
    local matching = GetComponentWithPath(self.seats[pos], "Info/Matching", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(head, false)
    ComponentUtil.SafeSetActive(matching, true)
end


--下载头像
function TableMatchView:startDownLoadHeadIcon(targetImage, url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(err.error, 'http') == 1 then
                if (self) then
                    --self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if (callback) then
                callback(tex)
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end)
end

------刷新电池,时间,网络信号信息
function TableMatchView:refreshBatteryAndTimeInfo()
    --电池,电池充电
    self.BatteryImage = GetComponentWithPath(self.root, "TopRight/TopRoot/Battery/ImageBackground/ImageLevel", ComponentTypeName.Image)
    self.BatteryChargingRoot = GetComponentWithPath(self.root, "TopRight/TopRoot/Battery/ImageCharging", ComponentTypeName.Transform).gameObject
    --当前的时间
    self.textTime = GetComponentWithPath(self.root, "TopRight/TopRoot/Time/Text", ComponentTypeName.Text)
    --当前的网络信号信息
    self.goGState2G = GetComponentWithPath(self.root, "TopRight/TopRoot/NetState/GState/2g", ComponentTypeName.Transform).gameObject
    self.goGState3G = GetComponentWithPath(self.root, "TopRight/TopRoot/NetState/GState/3g", ComponentTypeName.Transform).gameObject
    self.goGState4G = GetComponentWithPath(self.root, "TopRight/TopRoot/NetState/GState/4g", ComponentTypeName.Transform).gameObject
    self.textPingValue = GetComponentWithPath(self.root, "TopRight/TopRoot/PingVal", ComponentTypeName.Text)
    self.goWifiStateArray = {}
    for i = 1, 5 do
        local goState = GetComponentWithPath(self.root, "TopRight/TopRoot/NetState/WifiState/state" .. (i - 1), ComponentTypeName.Transform).gameObject
        table.insert(self.goWifiStateArray, goState)
    end
    local batteryValue = GameSDKInterface:GetCurBatteryLevel()
    batteryValue = batteryValue * 0.01
    self.BatteryImage.fillAmount = batteryValue
    self.textTime.text = os.date("%H:%M", os.time())
    ModuleCache.ComponentUtil.SafeSetActive(self.BatteryChargingRoot, GameSDKInterface:GetCurChargeState())
    local signalType = GameSDKInterface:GetCurSignalType()
    if (signalType == "none") then
        self:showWifiState(true, 0)
        self:show4GState(false)
    elseif (signalType == "wifi") then
        local wifiLevel = GameSDKInterface:GetCurSignalStrenth()
        self:showWifiState(true, math.ceil(wifiLevel))
        self:show4GState(false)
    else
        self:showWifiState(false)
        self:show4GState(true, signalType)
    end
end

------wifi信号的强度:show 是否显示,wifiLevel wifi强度
function TableMatchView:showWifiState(show, wifiLevel)
    for i = 1, #self.goWifiStateArray do
        ModuleCache.ComponentUtil.SafeSetActive(self.goWifiStateArray[i], show and wifiLevel + 1 == i)
    end
end

------移动信号:show 是否显示,signalType 移动网络信号类型
function TableMatchView:show4GState(show, signalType)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState2G, show and signalType == "2g")
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState3G, show and signalType == "3g")
    ModuleCache.ComponentUtil.SafeSetActive(self.goGState4G, show and signalType == "4g")
end

function TableMatchView:show_ping_delay(show, delaytime)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingValue.gameObject, show)
    if (not show) then
        return
    end
    delaytime = math.floor(delaytime * 1000)
    local content = ''
    if (delaytime >= 1000) then
        delaytime = delaytime / 1000
        delaytime = Util.getPreciseDecimal(delaytime, 2)
        content = '<color=#a31e2a>' .. delaytime .. 's</color>'
    elseif (delaytime >= 200) then
        content = '<color=#a31e2a>' .. delaytime .. 'ms</color>'
    elseif (delaytime >= 100) then
        content = '<color=#b5a324>' .. delaytime .. 'ms</color>'
    else
        content = '<color=#44b916>' .. delaytime .. 'ms</color>'
    end
    self.textPingValue.text = content
end

function TableMatchView:getBg(gamename)
    if self.getbg then
        return nil
    end
    self.getbg = true
    local bg = nil
    local s1 = "public/module/tablematch/table_publicbg.prefab"
    local s2 = "Table_PublicBg"
    if gamename == "RUNFAST" then
        s1 = "runfast/module/tablerunfast/runfast_tablebg.prefab"
        s2 = "Runfast_TableBg"
        bg = ModuleCache.ViewUtil.InitViewGameObject(s1, s2, 1);
    elseif gamename == "HENANMJ" then
        s1 = "majiang/module/table/henanmj_tablebg.prefab"
        s2 = "HeNanMJ_TableBg"
        self.maJiangBg = nil
        bg = ModuleCache.ViewUtil.InitViewGameObject(s1, s2, 1);
        self.maJiangBg = bg
        self:refresh_majiang_2d_Bg()
    end
    return bg
end

---刷新背景
function TableMatchView:refresh_majiang_2d_Bg(bgSet)
    if not self.maJiangBg then
        return
    end
    local GameID = AppData.get_app_and_game_name()
    local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
    local Is3D = Config.get_mj3dSetting(GameID).Is3D
    local def3dOr2d = Config.get_mj3dSetting(GameID).def3dOr2d
    local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d", gameType)
    local curSetting = UnityEngine.PlayerPrefs.GetInt(mj2dOr3dSetKey,def3dOr2d)
    local mjBgSet = bgSet
    if  1 == Is3D then
        if not self.mjiang3dBg then
            local s1 = "majiang3d/module/table3d/mj_table3d_bg.prefab"
            local s2 = "MJ_Table3D_BG"
            self.mjiang3dBg = ModuleCache.ViewUtil.InitViewGameObject(s1, s2, 1)
            self.mjiang3dBg.transform:SetParent(self.maJiangBg.transform)
            ModuleCache.ComponentUtil.SafeSetActive(self.mjiang3dBg, -10086 == mjBgSet)
            self.majiang3dBgSprite = {}
            local sprite2d = GetComponentWithPath(self.mjiang3dBg, "2dOr3dSelectPic/2d", ComponentTypeName.Image).sprite
            local sprite3d = GetComponentWithPath(self.mjiang3dBg, "2dOr3dSelectPic/2d", ComponentTypeName.Image).sprite
            table.insert(self.majiang3dBgSprite,sprite2d)
            table.insert(self.majiang3dBgSprite,sprite3d)
        end
    end
    if 1 == Is3D and 1 == curSetting then
        mjBgSet = -10086
    else
        if not mjBgSet then
            local config = ModuleCache.PlayModeUtil.get_playmodel_data(gameType)
            local defaultBg = 1
            if (config.cardTheame) then
                local strs = string.split(config.cardTheame, "|")
                if (strs[3]) then
                    defaultBg = tonumber(strs[3])
                end
            end
            local bgSetKey = string.format("%s_MJBackground", gameType)
            mjBgSet = UnityEngine.PlayerPrefs.GetInt(bgSetKey, defaultBg)
        end
    end
    local bgs = TableUtil.get_all_child(self.maJiangBg)
    self.majiang2dBgSprite = {}
    for i = 1, #bgs do
        local bg = bgs[i]
        ModuleCache.ComponentUtil.SafeSetActive(bg, i == mjBgSet)
        local Image = GetComponentWithPath(bg, "", ComponentTypeName.Image)
        if Image then
            local bgSprite = GetComponentWithPath(bg, "", ComponentTypeName.Image).sprite
            table.insert(self.majiang2dBgSprite, bgSprite)
        end
    end
    if -10086 == mjBgSet then
        if self.mjiang3dBg then   ModuleCache.ComponentUtil.SafeSetActive(self.mjiang3dBg,true) end
        self.uiState3d:SwitchState("3d")
    else
        if self.mjiang3dBg then   ModuleCache.ComponentUtil.SafeSetActive(self.mjiang3dBg,false) end
        self.uiState3d:SwitchState("2d")
    end
end

return TableMatchView