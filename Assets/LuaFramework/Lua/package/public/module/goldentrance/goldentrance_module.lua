-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local GoldEntranceModule = class("Public.GoldEntranceModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local GameManager = ModuleCache.GameManager
local PlayModeUtil = ModuleCache.PlayModeUtil
local PlayerPrefs = UnityEngine.PlayerPrefs
local times = 0
local TableManager = TableManager
local MatchingManager = require("package.public.matching_manager")
---@type Config Config
local Config = require("package.public.config.config")
function GoldEntranceModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据

    ModuleBase.initialize(self, "goldentrance_view", "goldentrance_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function GoldEntranceModule:on_module_inited()

end

-- 绑定module层的交互事件
function GoldEntranceModule:on_module_event_bind()
    self:subscibe_package_event("Event_Set_Play_Mode", function(eventHead, eventData)
        if eventData then
            self.playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
            self:on_show()
        end
    end)
    --self:subscibe_package_event("Event_Package_GetUserInfo", function(eventHead, eventData)
    --    print_table(eventData, "玩家数据")
    --    self.view:refresh_gold(eventData)
    --end )
    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.view:refresh_gold(self.modelData.roleData)
        self:get_quickJoin_data(true)
    end )
    self:subscibe_package_event("Event_Package_EnterRoomFail", function(eventHead, eventData)
        --self:get_table_list()
    end )

end

-- 绑定Model层事件，模块内交互
function GoldEntranceModule:on_model_event_bind()


end

function GoldEntranceModule:on_show(data)
    self:get_tag_list()
    self.roomData = {}
    self.tableData = {}
    self.playRule = {}
    self:getUserNewMessage()
    self.view:refresh_gold(self.modelData.roleData)

    --self.view:refreshPlayMode()
    if data and type(data) == "table" then

        if data.tag then
            self.tag = data.tag
        end
        if self.tag > #self.wanfaType then
            self.tag = 1
        end
        print("开启标签，，，，，", self.tag)
        self.roomData[self.tag] = data.data
        self.playRule[self.tag] = data.rule
        self:getUserNewMessage()
        self.num = data.data[1].id
        self.view:initRoomViewList(data.data)
    else
        if data then
            self.tag = tonumber(data)
        end
        if self.tag > #self.wanfaType then
            self.tag = 1
        end
        self:get_data_list()
    end
    self:get_quickJoin_data(true)
    --print("初始化标签", self.tag)
    --self.view:initTag(self.wanfaType, self.tag)

    --self:get_table_list()
    self.modelData.tableCommonData.isGoldTable = false
    --self:connect_login_server()  --断线重连检测
end





function GoldEntranceModule:get_tag_list()
    self.wanfaType = ModuleCache.PlayModeUtil.get_gold_playmodel_data(AppData.Game_Name)
    self.tag = 1
    self.gamename = ModuleCache.AppData.get_app_and_game_name()
    if self.modelData.hallData.goldClickRecord[self.gamename] then
        self.tag = self.modelData.hallData.goldClickRecord[self.gamename]
    end
end


function GoldEntranceModule:on_click(obj, arg)

    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    local objName = obj.name
    print("点击按钮", objName, obj.transform.parent.name)
    if objName == "BackBtn" then
        --ModuleCache.GameManager.select_province_id( self.modelData.hallData.normalProvinceId)
        --ModuleCache.GameManager.select_game_id(  self.modelData.hallData.normalGameId)
        ModuleCache.ModuleManager.hide_module("public", "goldentrance")
        ModuleCache.UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_LAST_HALL_OPEN_MODULE, "");
    elseif objName == "StartBtn" then
        print("快速开始")
        self:get_quickJoin_data()
    elseif objName == "PlayBtn" then
        print("玩法说明", self.tag)
        ModuleCache.ModuleManager.show_module("public", "goldhowtoplay", self.tag)
    elseif (objName == "BtnplayMode") then
        print("选择省份")
        ModuleCache.ModuleManager.show_module('henanmj', "setplaymode", ModuleCache.GameManager.curProvince)
    elseif obj.transform.parent.name == "RoomList" then
        local num = tonumber(objName)
        local pd = self:get_point_data(num)
        if pd then
            if self.modelData.roleData.gold >= pd.minJoinCoin and self.modelData.roleData.gold <= pd.maxJoinCoin then
                --ModuleCache.ModuleManager.show_module("public", "tablematch")
                TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,
                        pd.id, nil, nil,nil)
            else
                MatchingManager:gold_jump(pd.id)
            end
        end
        --战绩
    elseif objName == "RecordBtn" then
        --self:getHistoryList()
        ModuleCache.ModuleManager.show_module( "public", "goldhistory")
    elseif objName == "RefreshBtn" then
        self.view:refreshBtnSate()
        self:get_data_list()
        self:get_table_list()
        --排行榜
    elseif objName == "RankBtn" then
        ModuleCache.ModuleManager.show_module("henanmj", "rank");
        --创建房间
    elseif objName == "CreateBtn" then
        local sendData = {
            showType = 1,
            clickType = 1,
            data = nil
        }
        ModuleCache.ModuleManager.show_module("henanmj", "createroom", sendData)
        ModuleCache.GameManager.set_used_playMode()
        --加入房间
    elseif objName == "JoinBtn" then
        ModuleCache.ModuleManager.show_module("henanmj", "joinroom")
        ModuleCache.GameManager.set_used_playMode()
    elseif obj.name == "Gold" then
        ModuleCache.ModuleManager.show_module("henanmj", "shop",5)
    elseif obj.name == "Tili" then
        ModuleCache.ModuleManager.show_module("henanmj", "shop",2)
    elseif (obj.name == "Enter") then
        print("点击进入房间")
    elseif (obj.transform.parent.name == "TagGroup") then
        local index = tonumber(obj.name)
        self.tag = index
        self.view:tagClickDeal(self.tag)
        if self.roomData[index] then
            self.num = self.roomData[index][1].id
            self.view:initRoomViewList(self.roomData[index])
        else
            self:get_data_list()
        end
        --if self.tableData[index] then
        --    self.num = self.tableData[index][1].id
        --    self.view:initTableData(self.tableData[index])
        --else
        --    self:get_table_list()
        --end
        self.modelData.hallData.goldClickRecord[self.gamename] = self.tag
        ModuleCache.UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_LAST_HALL_OPEN_MODULE, "public_goldentrance_" .. self.tag)
    elseif (obj.name == "TestBtn") then
        local gameid = AppData.App_Name .. "_" .. AppData.Game_Name .. "_" .. AppData.Game_Name
        print("测试进入游戏", self.num, gameid)
        self:join_room(self.num, gameid) --加入房间
    elseif (obj.transform.parent.name == "Content") then
        print("进入牌桌：", obj.name)
        TableManager:join_room(tonumber(obj.name))
    elseif (obj.name == "ClubBtn") then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待")
    elseif (obj.name == "DescBtn") then
        --ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待")
        print("牌桌：", obj.transform.parent.name, "描述")
        self.view:click_desc_view("open", obj)
    elseif (obj.name == "DescMask") then
        self.view:click_desc_view("close")
    end
end


function GoldEntranceModule:connect_login_server()
    TableManager:connect_login_server(function()
        TableManager:request_login_login_server(self.modelData.roleData.userID, self.modelData.roleData.password)
    end,
    --登录成功回调
    function(data)
        if data.UserID ~= "0" and data.RoomID and data.RoomID ~= 0 then
            TableManager:request_join_room_login_server(data.RoomID)
        end
    end,
    nil, nil, nil)
end



function GoldEntranceModule:get_point_data(id)
    local data
    if self.roomData[self.tag] then
        for _, i in ipairs(self.roomData[self.tag]) do
            if id == i.id then
                data = i
            end
        end
    end

    return data
end


function GoldEntranceModule:join_room(id, gameName)
    TableManager:join_room(nil, gameName, nil, id)
    ModuleCache.GameManager.set_used_playMode()
end

--获取金币场数据
function GoldEntranceModule:get_data_list()
    local gamename = ModuleCache.AppData.get_app_and_game_name()
    print("========", self.tag)
    self.gameType = Config.get_gold_wanfaType_name(self.tag)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/getGolds?",
        params = {
            uid = self.modelData.roleData.userID,
            tagCode = self.gameType
        },
        cacheDataKey = "gold/getGolds?uid=" .. self.modelData.roleData.userID .. "&gameName=" .. self.gameType .. "tag=" .. self.tag
    }
    local sucDeal = function(retData)
        if (retData.success) and type(retData.data) == "table" and #retData.data > 0 then
            self.roomData[self.tag] = {}
            self.playRule[self.tag] = ""
            for i = 1, #retData.data do
                --coinType  台费类型 1-钻石 2-体力 3-元宝 4-铜钱 5-金币
                if self.playRule[self.tag] == "" then
                    self.playRule[self.tag] = retData.data[i].playRule
                end
                local temp = {
                    index = i,
                    id = retData.data[i].goldId,
                    name = retData.data[i].goldName,
                    difen = retData.data[i].baseScore,
                    minJoinCoin = retData.data[i].minJoinCoin,
                    maxJoinCoin = retData.data[i].maxJoinCoin,
                    onlinenum = retData.data[i].onLine,
                    playRule = retData.data[i].playRule,
                    feeNum = retData.data[i].feeNum,
                    desc = ""   --retData.data[i].goldTagDesc
                }
                print("角标文字：",type(retData.data[i].goldTagDesc),retData.data[i].goldTagDesc)
                if retData.data[i].goldTagDesc and type(retData.data[i].goldTagDesc) == "string"  then
                    temp.desc = retData.data[i].goldTagDesc
                end
                temp.open = i < 5
                table.insert(self.roomData[self.tag], temp)
                --self.roomData[ retData.data[i].goldId] = temp
            end
            print("金币场数据获取成功")
            print_table(self.roomData)
            self.modelData.hallData.goldData[gamename] = retData.data
            ModuleCache.UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_LAST_HALL_OPEN_MODULE, "public_goldentrance_" .. self.tag)
            self.num = self.roomData[self.tag][1].id
            self.view:initRoomViewList(self.roomData[self.tag])
        end
    end
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        sucDeal(retData)
    end, function(wwwErrorData)
        print(wwwErrorData.error)
        print("第" .. times .. "获取金币场数据失败，继续获取")
        if times < 3 then
            times = times + 1
            self:get_data_list()
        end
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        sucDeal(retData)
    end)
end


--roomIdText.text = tableData.roomNo
--self.Config = require(string.format("package.public.config.%s.config_%s", AppData.App_Name, AppData.Game_Name))
--ruleText.text = Config:PlayRule(tableData.rule)
--difenText.text = tostring(tableData.difen)
--enterText.text = "入场:" .. Util.filterPlayerGoldNum( tonumber( tableData.enterGoldNum))
--leaveText.text = "离场:" .. Util.filterPlayerGoldNum( tonumber( tableData.leaveGoldNum))
--local player_num = tonumber(tableData.playerNum)



--获取牌桌数据
function GoldEntranceModule:get_table_list()
    self.gameType = Config.get_gold_wanfaType_name(self.tag)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/getGoldRoomList?",
        params = {
            tagCode = self.gameType,
            pageNum = 1,
            pageSize = 50
        },
        --cacheDataKey = "gold/getGoldRoomList?uid=" .. self.modelData.roleData.userID .. "&gameName=" .. self.gameType .. "tag=" .. self.tag
    }
    local sucDeal = function(retData)
        if (retData.success) and type(retData.data) == "table" then
            self.tableData[self.tag] = {}
            for i = 1, #retData.data do
                local temp = {
                    roomNo = retData.data[i].roomNum,
                    rule = retData.data[i].playRule,
                    difen = retData.data[i].baseScore,
                    enterGoldNum = retData.data[i].minJoinCoin,
                    leaveGoldNum = retData.data[i].minForceExitCoin,
                    playerNum = 0, --#retData.data[i].players,
                    maxPlayerNum = retData.data[i].maxPlayerCount,
                    index = i,
                }
                local ps = 0
                if type(retData.data[i].players) == "table" then
                    ps = #retData.data[i].players
                end
                temp.playerNum = ps
                if temp.rule ~= "......" then
                    table.insert(self.tableData[self.tag], temp)
                end

            end
            print("金币场牌桌数据获取成功")
            print_table(self.tableData[self.tag])
            self.view:initTableData(self.tableData[self.tag])
        end
    end
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        sucDeal(retData)
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        sucDeal(retData)
    end)
end

function GoldEntranceModule:get_quickJoin_data(init)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/quickJoin?",
        showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
            tagCode = self.gameType
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            if type(retData.data ) == "table" then
                local data = retData.data
                if init then
                    self.view:setRecommondRoom(data.goldName)
                    return
                end
                TableManager:start_enter_gold_matching(self.modelData.roleData.userID, self.modelData.roleData.password,
                data.goldId, nil, nil)
            else
                if init then
                    self.view:setRecommondRoom("金币不足")
                    return
                end
                MatchingManager:jiujijin(function(times)
                    if times > 0 then
                        ModuleCache.ModuleManager.show_module("public", "relief")
                    else
                        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel(
                                "您的金币不足!是否需要充值?", function()
                                    ModuleCache.ModuleManager.show_module("public", "shopbase")
                                end, nil, true, "确定", "取消")
                    end
                end)
            end
        end
    end, function(wwwErrorData)
        print(wwwErrorData.error)
    end)
end

----获取玩家金币数据
function GoldEntranceModule:getUserNewMessage()
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params =
        {
            uid = self.modelData.roleData.userID,
        },
        cacheDataKey = "user/info?uid=" .. self.modelData.roleData.userID .. "&gameName=" .. (ModuleCache.AppData.get_url_game_name())
    }

    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then
            self.modelData.roleData.cards = retData.data.cards
            self.modelData.roleData.coins = retData.data.coins
            self.modelData.roleData.gold = retData.data.gold
            self.view:refresh_gold(self.modelData.roleData)
        end
    end , function(error)
        self:get_userinfo(true)
        print(error.error)
    end , function(cacheDataText)
        if self.isDestroy then
            return
        end
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then
            self.modelData.roleData.cards = retData.data.cards
            self.modelData.roleData.coins = retData.data.coins
            self.modelData.roleData.gold = retData.data.gold
            self.view:refresh_gold(self.modelData.roleData)
        end

    end )
end


function GoldEntranceModule:get_new_list(list)
    local newList = { }
    local maxNum = 20
    if (#list < maxNum) then
        return list
    else
        for i = 1, maxNum do
            table.insert(newList, list[i])
        end
        print(#newList)
        return newList
    end
end
--- 获取开房历史战绩end

function GoldEntranceModule:on_destroy()
end


return GoldEntranceModule



