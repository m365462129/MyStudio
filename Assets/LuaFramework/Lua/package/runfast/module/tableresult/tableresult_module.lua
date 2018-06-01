-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
local BranchPackageName = AppData.BranchRunfastName
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("TableResultModule", ModuleBase)
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

function TableResultModule:initialize(...)
    ModuleBase.initialize(self, "tableResult_view", "tableResult_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function TableResultModule:on_module_inited()
end

-- 绑定module层的交互事件
function TableResultModule:on_module_event_bind()
end

-- 绑定loginModel层事件，模块内交互
function TableResultModule:on_model_event_bind()
end

function TableResultModule:on_show(data)
    ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom")
    TableManagerPoker:disconnect_game_server()
    self.tableResultView:refreshRoomInfo(self.modelData);
    local playerlist = data.curAccountData.players
    local resultList = {}
    for i = 1, #playerlist do
        local result = {}
        local locData = playerlist[i]
        result.player_id = locData.player_id
        result.bomb_cnt = locData.bomb_cnt
        result.score = locData.score
        result.win_cnt = locData.win_cnt
        result.lost_cnt = locData.lost_cnt
        result.coin = locData.coin
        result.restCoin = locData.restCoin
        result.coinBalance = locData.coinBalance
        table.insert(resultList, result)
    end
    local count = #resultList
    if (count ~= 0) then
        ModuleCache.ModuleManager.show_public_module("netprompt")
    end

    local finishCount = 0
    local maxScore = 0
    for i = 1, count do
        if (maxScore < resultList[i].score) then
            maxScore = resultList[i].score
        end

        self:getPlayerInfo(resultList[i], function(err)
            finishCount = finishCount + 1
            if (finishCount == count) then
                ModuleCache.ModuleManager.hide_public_module("netprompt")
                self.tableResultView:init_view(resultList, maxScore,self.modelData)
            end
        end )
    end

    
end

function TableResultModule:getPlayerInfo(data, callback)
    print("data.player_id=" .. tostring(data.player_id))
    self.tableResultModel:get_userinfo(data.player_id, function(err, playerData)
        print("finish get userInfo")
        if (err) then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(err)
            ModuleCache.ModuleManager.hide_public_module("netprompt")
            return
        end
        local player = { }
        player.uid = playerData.userId
        player.nickname = playerData.nickname
        player.headImg = playerData.headImg

        -- 根据玩家id获取座位信息
        local seatInfo = self:getSeatInfo(data.player_id);
        player.seatInfo = seatInfo;
        data.player = player
        callback(err)
    end )
end

-- 根据玩家id获取座位信息
function TableResultModule:getSeatInfo(playerID)

    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList;
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if (tostring(playerID) == tostring(seatInfo.playerId)) then
            return seatInfo;
        end
    end
end



function TableResultModule:on_click(obj, arg)
    print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.tableResultView.buttonBack.gameObject then
        self.modelData.curTableData.roomInfo = nil
        ModuleCache.ModuleManager.destroy_package(BranchPackageName)
        ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
        return
    elseif obj == self.tableResultView.buttonShare.gameObject then
        ModuleCache.ShareManager().shareImage(false)
        return
    end
end

return TableResultModule