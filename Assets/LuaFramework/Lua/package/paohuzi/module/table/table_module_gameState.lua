

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





--- 实时刷新游戏状态
function TableModule:refresh_game_state(data)

    DataPaoHuZi.Msg_Table_GameStateNTFNew = data
    if not self.lastGameState then
        self.firstGameState = true
    else
        self.firstGameState = false
    end
    self.roundStart = true
    self.gameStateTable = self.gameStateTable or {}
    table.insert(self.gameStateTable, data)
    self.lastGameState = data



end

function TableModule:InitGameStateCon()
    curTableData = TableManager.phzTableData
    if curTableData.isPlayBack then
        return
    end

    self:start_lua_coroutine(
        function()
            while true do
                self.gameStateTable = self.gameStateTable or {}
                if #self.gameStateTable > 0 then
                    local boolIsFlag = false
                    self:start_lua_coroutine(function()
                        self:play_game_state()
                        boolIsFlag = true
                    end)
                    for i=1,150 do
                        if boolIsFlag then
                            break
                        end
                        coroutine.wait(0.05)
                    end
                    if not boolIsFlag then
                        ModuleCache.GameManager.logout()
                        ModuleCache.Log.report_exception("paohuzi大问题", "play_game_state没有执行完整")
                    end
                    table.remove(self.gameStateTable, 1)
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


    TableUtilPaoHuZi.print("<color=red>播放游戏状            态</color>")
    self.playingGameState = true
    local data = self.gameStateTable[1]

    DataPaoHuZi.Msg_Table_GameStateNTFLast = DataPaoHuZi.Msg_Table_GameStateNTF
    
    DataPaoHuZi.Msg_Table_GameStateNTF = data

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
                if AppData.Game_Name == "LDZP" or AppData.Game_Name == "XXZP" then
                    self.playersView[localSeatID].seat.score.text = tostring(data.player[i].total_hu_xi)
                else
                    self.playersView[localSeatID].seat.score.text = tostring(data.player[i].total_score)
                end
            end
            
            return
        end

        self:show_game_result(data)
    else
        --self.showSingleResult = false
      
        self.oneRoundStart = true
    end


    self.IndexOfshowJinPlayerErr = self.IndexOfshowJinPlayerErr or 1
    self.IndexOfshowJinPlayerErr = self.IndexOfshowJinPlayerErr + 1
    if self.IndexOfshowJinPlayerErr % 20 == 0 then
        --self:showJinPlayerErr()
    end

    -- 自己的 下张  弃张 为0

    local num = 0
    for i = 1, #data.player do
        local localSeatID = self:get_local_seat(i - 1)
        if localSeatID == 1 then
            num = num + #data.player[i].xia_zhang
            num = num + #data.player[i].qi_zhang
        end
    end



    if self:has_actionWhat(17)  then
        HandCardView.isFirstLoad = true
        self:start_lua_coroutine(function ()
            Manager.SetActive(self.view.remainderCardObj, false)
            coroutine.wait(1.4)
            if self.view then
                Manager.SetActive(self.view.remainderCardObj, true)
            end
        end)
    end

    self:play(data)
end


--- 是否在准备状态
function TableModule:isInZhunBeiIng()
    if not DataPaoHuZi.Msg_Table_UserStateNTF then
        return false
    end

    local num = 0
    for key, v in pairs(DataPaoHuZi.Msg_Table_UserStateNTF.State) do
        if v.UserID ~= "0" and v.UserID ~= nil and v.Ready then
            num = num + 1
        end
    end

    

    return  num ~= 3 and DataPaoHuZi.Msg_Table_UserStateNTF_Self.Ready
end


--- 判断是否有动作ID
function TableModule:has_actionWhat(id)
    local data = DataPaoHuZi.Msg_Table_GameStateNTF

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

    if data.FeeNum ~= nil and data.FeeNum ~= 0 and self.fuwufeiFalg == nil then
        self.fuwufeiFalg = {}
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("本局服务费" ..data.FeeNum .. ' 金币')
        coroutine.wait(2)
    end
    if self:has_action(data) and self:has_actionWhat(9) then
        self:show_leave_btn(false)
        self:show_invite_btn(false)
        --self:refresh_paiju(data)
        self:play_jiangpai(data.jiang_pai)
        coroutine.wait(0.3)
    end

    self:set_jiang(data.jiang_pai)


    self:refresh_paiju(data)



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
        if playerData[i].player.hu_fa_action[1] == 7 then
            playerData[i].PaiXuNum = -10
        end

        local localSeatID = self:get_local_seat(i - 1)
        if data.action then
            for j = 1, #data.action do
                if data.action[j].seat_id == i - 1 and data.action[j].action == 7 then
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
        TableUtilPaoHuZi.print("动作ID吧   ", actionID, "动作位置", localSeatID)
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

   
    -- 挡抵后的第一次  出张    需要收回
    if AppData.Game_Name ~= 'GLZP' and self:has_actionWhat(16)  then
        coroutine.wait(1)
        for j = 1, 3 do
            self.playersView[j]:hide_chuzhang()
        end
    end

    HandCardView:set_out_card_enable(data.ke_chu ~= 0)

    HandCardView:set_drag_enable(true)
    coroutine.wait(0)
  
end



--- 播放将牌动画
function TableModule:play_jiangpai(jiang, fangshi)
    fangshi = fangshi or 9
    TableUtilPaoHuZi.print("播放将牌动画")
    self.playJiangpai = true
    local obj = TableUtilPaoHuZi.clone(self.view.QiZhangObj, self.view.root, Vector3.New(0, 0, 0))
    obj.transform.position = self.view.jiangpaiObj.transform.position
    local jiangTx = TableUtilPaoHuZi.clone(self.view.chuTX, self.view.root, Vector3.New(0, 0, 0))
    jiangTx.transform.position = self.view.jiangpaiObj.transform.position
    local img1 = Manager.GetImage(jiangTx, "Animator/WenBen")
    local img2 = Manager.GetImage(jiangTx, "Animator/GaoLiang")
    local spriteHolder = Manager.GetComponent(jiangTx, "SpriteHolder")
    local sprite = spriteHolder:FindSpriteByName(fangshi)
    img1.sprite = sprite
    img2.sprite = sprite
    img1:SetNativeSize()
    img2:SetNativeSize()
    Manager.SetActive(obj, true)
    Manager.SetActive(jiangTx, true)

    if AppData.Game_Name == "DYZP" then
        TableUtilPaoHuZi.set_card(obj, jiang, nil, "ZiPai_PlayCards")
        self.view.jiangpaiImg.sprite = TableUtilPaoHuZi.getcardSprite(jiang, "ZiPai_PlayCards")
    else
        TableUtilPaoHuZi.set_card(obj, jiang, nil, "ZiPai_PlayCards")
        self.view.jiangpaiImg.sprite = TableUtilPaoHuZi.getcardSprite(jiang, "ZiPai_PlayCards")
    end

    Manager.SetActive(self.view.jiangpaiObj, true)
    Manager.SetActive(self.view.jiangpaiImg.gameObject, false)
    local seq = self.view:create_sequence()
    seq:AppendInterval(1)

    local tw1
    if AppData.Game_Name == "DYZP" then
        tw1 = Manager.DoScale(obj, 1.3, 0.3)
    else
        tw1 = Manager.Move(obj, self.view.jiangpaiImg.transform.position, 0.3)
    end

    local tw2 = Manager.Move(obj, self.view.jiangpaiImg.transform.position, 0.3)
    seq:Append(tw1)
    seq:Join(tw2)
    seq:SetAutoKill(true)
    seq:Play()
    TableUtilPaoHuZi.add_sequence(seq)
    local isEnd = true
    seq:OnComplete(
        function()
            isEnd = false
        end
    )
    while isEnd do
        coroutine.wait(0)
    end

    Manager.DestroyObject(obj)
    Manager.DestroyObject(jiangTx)
    Manager.SetActive(self.view.jiangpaiImg.gameObject, true)

    if fangshi == 13 then
        coroutine.wait(1)
        Manager.SetActive(self.view.jiangpaiImg.gameObject, false)
    end
end
--- 显示结算
function TableModule:show_game_result(data)
    --- 大结算
    if data.result == 2 then
        ModuleManager.destroy_module("paohuzi", "dissolveroom")
        ModuleManager.show_module("paohuzi", "totalresult", data)

       
        --- 没有显示  小结算或者显示了小结算但不是最后一局则表示是解散房间
        if not self.showSingleResult or (self.showSingleResult and DataPaoHuZi.Msg_DismissNTF and #DataPaoHuZi.Msg_DismissNTF.Action ~= 0) then
            ModuleManager.destroy_module("paohuzi", "singleresult")
            ModuleManager.get_module("paohuzi", "totalresult"):show_result()
        end
        return
    elseif data.result == 1 then
        self.showSingleResult = true

        self:InitActivity_module()
    end
    ModuleManager.destroy_module("paohuzi", "singleresult")
    ModuleManager.show_module("paohuzi", "singleresult", data)
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
            for j = 1, #data.player[i].fixed_pai do
                table.insert(cardData, data.player[i].fixed_pai[j])
                count = count + 1
            end
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
        if AppData.Game_Name == "LDZP" or AppData.Game_Name == "XXZP" then
            self.playersView[localSeatID]:update_score(data.player[i].total_hu_xi)
        else
            self.playersView[localSeatID]:update_score(data.player[i].total_score)
        end
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