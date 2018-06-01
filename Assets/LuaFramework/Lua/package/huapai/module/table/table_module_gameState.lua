

local TableModule = PaoHuZi_TableModule

local ModuleCache = ModuleCache
local ModuleManager = ModuleCache.ModuleManager

local PlayerView = require("package.huapai.module.table.player_view")
local CardCtrlView = require("package.huapai.module.table.cardctrl_view")
local HandCardView = require("package.huapai.module.table.handcard_view")
local SoundManager = require("package.huapai.module.table.sound_manager")

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

local ComponentUtil = ModuleCache.ComponentUtil
local DoTween = DG.Tweening.DOTween

local UnityEngine = UnityEngine
local Input = UnityEngine.Input

local curTableData  -- 牌桌数据





--- 实时刷新游戏状态
function TableModule:refresh_game_state(data)

    DataHuaPai.Msg_Table_GameStateNTFNew = data
    if not self.lastGameState then
        self.firstGameState = true
    else
        self.firstGameState = false
    end
    self.roundStart = true

    table.insert(DataHuaPai.gameStateTable, data)
    self.lastGameState = data



end

function TableModule:InitGameStateCon()
    curTableData = TableManager.phzTableData
    if curTableData.isPlayBack then
        return
    end

    DataHuaPai.gameStateTable = {}


    self:start_lua_coroutine(
        function()
            while true do
                if #DataHuaPai.gameStateTable > 0 then
                    self:play_game_state()
                    coroutine.wait(0.05)
                    table.remove(DataHuaPai.gameStateTable, 1)
                    coroutine.wait(0.05)
                else
                    coroutine.wait(0)
                end
            end
        end
    )
end

--- 播放游戏状态
function TableModule:play_game_state()
    print("播放游戏状" .. #DataHuaPai.gameStateTable)

    self.playingGameState = true
    local data = DataHuaPai.gameStateTable[1]

    DataHuaPai.Msg_Table_GameStateNTFLast = DataHuaPai.Msg_Table_GameStateNTF
    
    DataHuaPai.Msg_Table_GameStateNTF = data

    if self.Msg_Table_GameStateNTFFunc then
        self.Msg_Table_GameStateNTFFunc()
    end

   

    if data.result ~= 0 then
        for j = 1, 3 do
            self.playersView[j]:hide_chuzhang()
        end

        -- 假如有一个人未曾准备好 则说明处于 小结算后的待准备状态
        if self:isInZhunBeiIng() and data.result == 1 then
            --隐藏邀请和 退出按钮
            Manager.SetActive(self.view.btnInvite.gameObject, false)
            Manager.SetActive(self.view.btnLeave.gameObject, false)

            for i = 1, #data.player do
                local localSeatID = self:get_local_seat(i - 1)
                self.playersView[localSeatID].dataStateoyl = data.player[i]
                self.playersView[localSeatID].seat.score.text = tostring(data.player[i].total_score)
            end
            
            return
        end

        self:show_game_result(data)
    else
        self.oneRoundStart = true
    end



    self:play(data)

end


--- 是否在准备状态
function TableModule:isInZhunBeiIng()
    if not DataHuaPai.Msg_Table_UserStateNTF then
        return false
    end

    local num = 0
    for key, v in pairs(DataHuaPai.Msg_Table_UserStateNTF.State) do
        if v.UserID ~= "0" and v.UserID ~= nil and v.Ready then
            num = num + 1
        end
    end

    

    return  num ~= 3 and DataHuaPai.Msg_Table_UserStateNTF_Self.Ready
end


--- 判断是否有动作ID
function TableModule:has_actionWhat(id)
    local data = DataHuaPai.Msg_Table_GameStateNTF

    if not data then
        return false
    end
    for i = 1, #data.player do

        if data.action then
            for j = 1, #data.action do
                if data.action[j].action == id then
                    return true
                end
            end
        end
    end

    return false
end



--- 播放游戏状态
function TableModule:play(data)
    if not self:has_actionWhat(13) then
        self:refresh_paiju(data)
    end

    if data.ke_chu == 0 then
        HandCardView:set_out_card_enable(data.ke_chu ~= 0)
    end

    HandCardView:set_drag_enable(true)
    CardCtrlView:show_btns(data)

    
    local playerData = {}
    for i = 1, #data.player do
        playerData[i] = {}
        playerData[i].player = data.player[i]
        playerData[i].i = i
        playerData[i].PaiXuNum = i
      

        local localSeatID = self:get_local_seat(i - 1)
        if data.action then
            for j = 1, #data.action do
                if data.action[j].seat_id == i - 1 and (data.action[j].action == 9 or data.action[j].action == 10) then
                    playerData[i].PaiXuNum = -9
                end
            end
        end
    end

    table.sort(
        playerData,
        function(a, b)
            return a.PaiXuNum < b.PaiXuNum
        end
    )

    if DataHuaPai.IsPingBiAction and self:has_actionWhat(8) then
        playerData = {}
    end
    DataHuaPai.IsPingBiAction = false

    for k = 1, #playerData do
        local i = playerData[k].i
        local localSeatID = self:get_local_seat(i - 1)
        local actionID = 0

        --- 找出玩家的动作ID
        if data.action then
            for j = 1, #data.action do
                if data.action[j].seat_id == i - 1 then
                    actionID = data.action[j].action
                end
            end
        end
        print("动作ID吧   ", actionID, "动作位置", localSeatID)
        self.playersView[localSeatID].localSeatID = localSeatID
        self.playersView[localSeatID].seatID = i - 1
        self.playersView[localSeatID].zhuang = data.zhuang == i - 1
        self.playersView[localSeatID].dataStateoyl = data.player[i]
        self.playersView[localSeatID].playersViewAll = self.playersView
        self.playersView[localSeatID]:refresh_game_state(data.player[i], actionID)

        if localSeatID == 1 then
            -- 决定是否显示 托管按钮
            self:quxiaoTuoGuan(data.player[i])
        end

  
    end

   


    if self:has_actionWhat(13) then
        self:refresh_paiju(data)
    end

    HandCardView:set_out_card_enable(data.ke_chu ~= 0)

    HandCardView:set_drag_enable(true)


    local cardData = {}
    local count = 0
    for i = 1, #data.player do
        local localSeatID = self:get_local_seat(i - 1)
        if localSeatID == 1 then
            for j = 1, #data.player[i].shou_zhang do
                if valueNotIn ~= data.player[i].shou_zhang[j] then
                    table.insert(cardData, data.player[i].shou_zhang[j])
                end
            end
        end
    end
    --HandCardView:init_data1({cards = cardData})

    coroutine.wait(0)
    
    print('一个 GameState执行完毕' .. #data.action)
end



--- 播放将牌动画
function TableModule:play_jiangpai(jiang, fangshi)
  
end
--- 显示结算
function TableModule:show_game_result(data)
    --- 大结算
    if data.result == 2 then
        ModuleManager.destroy_module("huapai", "dissolveroom")
        ModuleManager.show_module("huapai", "totalresult", data)

       
        --- 没有显示  小结算或者显示了小结算但不是最后一局则表示是解散房间
        if not self.showSingleResult or (self.showSingleResult and DataHuaPai.Msg_DismissNTF and #DataHuaPai.Msg_DismissNTF.Action ~= 0) then
            ModuleManager.destroy_module("huapai", "singleresult")
            ModuleManager.get_module("huapai", "totalresult"):show_result()
        end
        return
    elseif data.result == 1 then
        self.showSingleResult = true

        self:InitActivity_module()
    end
    ModuleManager.destroy_module("huapai", "singleresult")
    ModuleManager.show_module("huapai", "singleresult", data)
end




--- 刷新牌局信息
function TableModule:refresh_paiju(data,valueNotIn)
    curTableData.CurRound = data.CurRound

    TableUtilPaoHuZi.print("刷新手牌及状态")
    self:show_leave_btn(false)
    self:show_invite_btn(false)
    self:show_start_btn()
    self:refresh_round(data.CurRound)
    self:refresh_remainder_cards(#data.dun)
    --　  #b13a1f
    --    #84590f
    local cardData = {}
    local count = 0
    for i = 1, #data.player do
        local localSeatID = self:get_local_seat(i - 1)
        if localSeatID == 1 then
           
            for j = 1, #data.player[i].shou_zhang do
                if valueNotIn ~= data.player[i].shou_zhang[j] then
                    table.insert(cardData, data.player[i].shou_zhang[j])
                end
            end
        end
        self.playersView[localSeatID]:show_ready(false)
        self.playersView[localSeatID]:show_kick(false)
        self.playersView[localSeatID]:show_banker(data.zhuang == i - 1)
        self.playersView[localSeatID]:show_light(data.cur_player == i - 1)
        self.playersView[localSeatID]:update_score(data.player[i].total_score)
        if data.player[i].Balance and data.player[i].Balance > 0 then
            self.playersView[localSeatID]:update_score(data.player[i].Balance)
        end
    end

    HandCardView:init_data({cards = cardData, count = count})


    if not self.view then
        return
    end

    if data.result ~= 0 then
        --干掉      手牌
        HandCardView:clear()
    end
end