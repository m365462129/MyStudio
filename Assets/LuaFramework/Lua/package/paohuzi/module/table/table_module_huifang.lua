

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



function TableModule:innitHuiFang()


end


--- 初始化回放数据
function TableModule:init_playback_data()
    curTableData = TableManager.phzTableData

    if curTableData.isPlayBack then
        self.playbackModule = ModuleManager.show_module("paohuzi", "playback")

        self:show_invite_btn(false)
        self:show_leave_btn(false)
        Manager.SetActive(self.view.btnRule.gameObject, false)
        Manager.SetActive(self.view.btnVoice.gameObject, false)
        Manager.SetActive(self.view.btnChat.gameObject, false)
        Manager.SetActive(self.view.buttonWarning.gameObject, false)
        --Manager.SetActive(self.view.objRightTop, false)

        HandCardView:set_drag_enable(false)
        HandCardView:set_out_card_enable(false)

        for i = 1, #curTableData.players do
            print_table(curTableData.players[i], "players")
            local localSeatID = self:get_local_seat(curTableData.players[i].seatId)
            self.playersView[localSeatID]:refresh_player_info(curTableData.players[i])
        end

        self.gameStateTable = {}

        self:start_lua_coroutine(
            function()
                while true do
                    coroutine.wait(0.1)
                    if not self.view then
                        break
                    end

                    if #self.gameStateTable >= self.playbackIndex and self.playingPlayback and self.view then
                        self:playback()
                    else
                        if self.view then
                            self.playbackModule:show_btn_play(true)
                        end
                    end
                end
            end
        )

        self.playbackIndex = 1
        for i = 1, #curTableData.gamestates do
            table.insert(self.gameStateTable, curTableData.gamestates[i])
        end

        self:playback_reset()
        self.playingPlayback = true
    end
end

--- 回放
function TableModule:playback()
    local data = self.gameStateTable[self.playbackIndex]

    DataPaoHuZi.Msg_Table_GameStateNTFLast = DataPaoHuZi.Msg_Table_GameStateNTF
    DataPaoHuZi.Msg_Table_GameStateNTF = data

    self.playbackModule:show_btn_play(not self.playingPlayback)

    
    self:set_jiang(data.jiang_pai)

    self:refresh_remainder_cards(#data.dun)
    self:refresh_round(data.CurRound)

    if data.result == 2 then
        DataPaoHuZi.Msg_Table_GameStateNTF2 = data
    elseif data.result == 1 then
        DataPaoHuZi.Msg_Table_GameStateNTF1 = data
    end

    if data.result ~= 0 then
        self:show_game_result(data)
    else
        ModuleManager.hide_module("paohuzi", "singleresult")
    end

    if self:has_action(data) and self:has_actionWhat(9) then
        self:play_jiangpai(data.jiang_pai)
        if self.view then
            self:set_jiang(data.jiang_pai)
        end
    end

    local playerData = {}
    for i = 1, #data.player do
        playerData[i] = {}
        playerData[i].player = data.player[i]
        playerData[i].i = i
        playerData[i].hufaActionNum = i
        if playerData[i].player.hu_fa_action[1] == 7 then
            playerData[i].hufaActionNum = -10
        end

        if data.action then
            for j = 1, #data.action do
                if data.action[j].seat_id == i - 1 and data.action[j].action == 7 then
                   playerData[i].hufaActionNum = -9
                end
            end
        end
    end

    table.sort(
        playerData,
        function(a, b)
            return a.hufaActionNum < b.hufaActionNum
        end
    )

    for k = 1, #playerData do
        local i = playerData[k].i
        local localSeatID = self:get_local_seat(i - 1)
        if localSeatID == 1 then
            local cardData = {}
            local count = 0
            for j = 1, #data.player[i].fixed_pai do
                table.insert(cardData, data.player[i].fixed_pai[j])
                count = count + 1
            end
            for j = 1, #data.player[i].shou_zhang do
                table.insert(cardData, data.player[i].shou_zhang[j])
            end

            HandCardView:init_data({cards = cardData, count = count})
        end

        self.playersView[localSeatID]:show_banker(data.zhuang == i - 1)
        self.playersView[localSeatID]:show_light(data.cur_player == i - 1)
        self.playersView[localSeatID]:update_score(data.player[i].total_score)
        local actionID = 0
        local findActionIndex = 0

        if data.action then
            for j = 1, #data.action do
                if data.action[j].seat_id == i - 1 then
                    actionID = data.action[j].action
                    if actionID == 7 or actionID == 8 then
                        findActionIndex = findActionIndex + 1
                    end
                end
            end
        end
        TableUtilPaoHuZi.print("动作ID", actionID, "动作位置", localSeatID)

        
        self.playersView[localSeatID].localSeatID = localSeatID
        self.playersView[localSeatID].seatID = i - 1
        self.playersView[localSeatID].zhuang = data.zhuang == i - 1
        self.playersView[localSeatID].dataStateoyl = data.player[i]
        self.playersView[localSeatID].playersViewAll = self.playersView

        self.playersView[localSeatID]:refresh_game_state(data.player[i], actionID, findActionIndex == 2)

    
    
        --print(self.playersView[localSeatID]:getIsHaveChuZhang(),data.ke_chu,i)
        
    end
    coroutine.wait(0.3)

    
    if self.view then
        self.playbackIndex = self.playbackIndex + 1
    end
end

--- 播放按钮播放
function TableModule:playback_play()
    self.playingPlayback = true
end

--- 暂停
function TableModule:playback_pause()
    self.playingPlayback = false
end

--- 后退一步
function TableModule:playback_back()
    if self.isCaoZuoNow then
        return
    end
    self:hide_players_chuzhang()
    self.playbackIndex = self.playbackIndex - 2
    if self.playbackIndex < 1 then
        self.playbackIndex = 1
    end
    self.playingPlayback = false
    self:start_lua_coroutine(
        function()
            self:playback()
        end
    )
end

--- 前进一步
function TableModule:playback_front()
    if self.isCaoZuoNow then
        return
    end
    self:hide_players_chuzhang()
    self.playbackIndex = self.playbackIndex + 1
    if self.playbackIndex > #self.gameStateTable then
        self.playbackIndex = #self.gameStateTable
    end
    self.playingPlayback = false
    self:start_lua_coroutine(
        function()
            self:playback()
        end
    )

    self:start_lua_coroutine(
        function()
            self.isCaoZuoNow = true
            coroutine.wait(1)
            self.isCaoZuoNow = false
        end
    )
end

--- 重置
function TableModule:playback_reset()
    self:hide_players_chuzhang()
    self.playbackIndex = 1
    self.playingPlayback = false
    self:hide_players_chuzhang()
    self:set_jiang()
    self.playbackModule:show_btn_play(true)
    self:show_start_btn()
end