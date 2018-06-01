--- 三公玩法 table module
--- Created by 袁海洲
--- DateTime: 2017/11/17 11:28
-- -
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('package.public.module.table_poker.base_table_module')

local TableSanGongModule = class('tableSanGongModule', ModuleBase);

local SoundManager = ModuleCache.SoundManager
local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application
local CSmartTimer = ModuleCache.SmartTimer.instance
local System = UnityEngine.System
local isPress = false
local isUpload = false
local isRecording = false
local timeEvent = nil
local recordPath = ""
local downloadPath = ""
local GameSDKInterface = ModuleCache.GameSDKInterface
local WechatManager = ModuleCache.WechatManager

local Input = UnityEngine.Input

local GameLogic = require('package.sangong.module.table.sangong_game_logic')
local View = require('package.public.module.table_poker.base_table_view')


function TableSanGongModule:initialize(...)
    ModuleBase.initialize(self, "table_view", "table_model", ...);
    self:set_gameinfo_coming_time(nil)
    self.config = require('package.sangong.config')

    self.packageName = "sangong"
    self.moduleName = "table"

    self:subscibe_model_event("Event_Table_Stake", function(eventHead, eventData)
        self:on_Table_Stake(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_Stake_Notify", function(eventHead, eventData)
        self:on_Table_Stake_Notify(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_Banker", function(eventHead, eventData)
        self:on_Table_Banker(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_Banker_Notify", function(eventHead, eventData)
        self:on_Table_Banker_Notify(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_BankerResult_Notify", function(eventHead, eventData)
        self:on_Table_BankerResult_Notify(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_Show_Card", function(eventHead, eventData)
        self:on_Table_Show_Card(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_Handcard_Notify", function(eventHead, eventData)
        self:on_Table_Handcard_Notify(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_GameInfo", function(eventHead, eventData)
        self:on_Table_GameInfo(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_CurrentGameAccount", function(eventHead, eventData)
        self:on_Table_CurrentGameAccount(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_TimeoutNotify", function(eventHead, eventData)
        self:on_Table_TimeoutNotify(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_GetCard", function(eventHead, eventData)
        self:on_Table_GetCard(eventHead, eventData)
    end )
    self:subscibe_model_event("Event_Table_ShowCardNotify", function(eventHead, eventData)
        self:on_Table_ShowCardNotify(eventHead, eventData)
    end )

    -- 房主变更广播消息
    self:subscibe_model_event("Event_Table_RoomOwnerChangeMsg", function(eventHead, eventData)
        -- print("------------------Event_Table_RoomOwnerChangeMsg-------------------",self.modelData.roleData.RoomType)
        if self.modelData.roleData.RoomType == 2 and self.modelData.curTableData then
            -- 亲友圈快速组局

            self.modelData.curTableData.roomInfo.CreatorId = eventData.newOwnerId

            local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
            for key, v in ipairs(seatInfoList) do
                v.isCreator =(v.playerId == eventData.newOwnerId)

                if (self.modelData.curTableData.roomInfo.mySeatInfo.isCreator and not v.isCreator and tonumber(v.playerId) ~= tonumber(self.modelData.curTableData.roomInfo.mySeatInfo.playerId) and tonumber(self.modelData.curTableData.roomInfo.curRoundNum) == 0) then
                    -- TODO XLQ 快速组局 第一个进入的玩家显示踢人按钮
                    local seatHolder = self.view.seatHolderArray[v.localSeatIndex]
                    ModuleCache.ComponentUtil.SafeSetActive(seatHolder.kickBtn.gameObject, true)
                end
            end

            local seatInfo = self:getSeatInfoByPlayerId(eventData.newOwnerId, seatInfoList, eventData.newOwnerId)
            self.view:refreshSeatPlayerInfo(seatInfo)
            self.view:refreshSeatState(seatInfo)

            self:updateActionBtnStatus()
        end

    end )


end

function TableSanGongModule:on_model_event_bind()
    ModuleBase.on_model_event_bind(self)
end

--- 房间消息处理

function TableSanGongModule:on_ready_rsp(eventData)
    ModuleBase.on_ready_rsp(self, eventData)
    self:updateActionBtnStatus()
    self.view:ControlLiangPaiBtn(false)
end

function TableSanGongModule:on_ready_notify(eventData)
    ModuleBase.on_ready_notify(self, eventData)
    self:updateActionBtnStatus()
end

function TableSanGongModule:on_enter_notify(eventData)
    ModuleBase.on_enter_notify(self, eventData)
    self:updateActionBtnStatus()
    self:updateShareData()
    self:refresh_share_clip_board()
end

function TableSanGongModule:on_leave_room_notify(eventData)
    ModuleBase.on_leave_room_notify(self, eventData)
    self:updateActionBtnStatus()
    self:updateShareData()
    self:refresh_share_clip_board()
end

-- 点击设置按钮
function TableSanGongModule:on_click_setting_btn(obj, arg)

    self.view.settingRoot:SetActive(true);
end

--- 游戏消息处理
--- 当押注回复
function TableSanGongModule:on_Table_Stake(eventHead, eventData)
    local data = eventData
    if not data.is_ok then
        print(data.desc)
        return
    end
    -- 关闭下注界面
    self.view:ControlStakeObj(false)
    self:updateTotalStakeInfo()
    self.view:HideTiming()
end
--- 当下注通知
function TableSanGongModule:on_Table_Stake_Notify(eventHead, eventData)
    local data = eventData
    local seatInfo = self:getSeatInfoByID(data.player_id)
    seatInfo.stake = data.stake

    local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
    if 1 == gameType then
        self.view:ThorwChip(seatInfo, seatInfo.stake)
        seatInfo.state = 3
        --- 修改玩家状态到开牌
    elseif 2 == gameType then
        -- 抢庄模式不丢筹码
        seatInfo.state = 3
        --- 修改玩家状态到开牌
    end

    self.view:refreshSeatPlayerInfo(seatInfo)
    self.view:playSeatStakeAni(seatInfo)
    --- 播放玩家押注座位动效
    self:updateTotalStakeInfo()

    if data.all_staked then
        local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
        self:setRoomState(3)
        --- 切换房间到开牌状态
        if 0 ~= mySeatInfo.state then
            self:updateShowCardBtnStatus(true)
            --- 打开开牌按钮
        end
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            if seatInfo.isSeated and 0 ~= seatInfo.state then
                seatInfo.state = 3
                --- 设置玩家到开牌阶段
            end
            self.view:refreshSeatPlayerInfo(seatInfo)
        end
    end
end
--- 抢庄回复操作
function TableSanGongModule:on_Table_Banker(eventHead, eventData)
    local data = eventData
    if not data.is_ok then
        print(data.desc)
        return
    end
    -- 关闭抢庄界面
    self.view:ControlGetBankerObj(false)
    self.view:HideTiming()
end
--- 抢庄通知操作
function TableSanGongModule:on_Table_Banker_Notify(eventHead, eventData)
    local data = eventData
    local seatInfo = self:getSeatInfoByID(data.player_id)
    seatInfo.bankerRate = data.banker_rate
    seatInfo.state = 2
    --- 修改玩家状态到下注
    self.view:refreshSeatPlayerInfo(seatInfo)
    self.view:playGetBankerRateAni(seatInfo, seatInfo.bankerRate)

    self.getBankerInfo = self.getBankerInfo or { }
    local info = { }
    info.playerId = data.player_id
    info.bankerRate = data.banker_rate
    table.insert(self.getBankerInfo, info)

    self.view:playGetBankerSound(seatInfo, seatInfo.bankerRate)
end
--- 抢庄结果通知操作
function TableSanGongModule:on_Table_BankerResult_Notify(eventHead, eventData)
    local data = eventData
    local bankerId = data.player_id
    local bankerRate = data.banker_rate
    local randomBankerList = { }
    local allZero = true
    for i = 1, #self.getBankerInfo do
        if self.getBankerInfo[i].bankerRate > 0 then
            allZero = false
            break
        end
    end
    for i = 1, #self.getBankerInfo do
        local info = self.getBankerInfo[i]
        local needPlay = false
        if info.playerId == bankerId and 0 == info.bankerRate then
            needPlay = true
        end
        if info.bankerRate == bankerRate or needPlay or allZero then
            table.insert(randomBankerList, info)
        end
    end
    print_table(randomBankerList)
    local Process = function()
        local seatInfo = self:getSeatInfoByID(data.player_id)
        seatInfo.isBanker = true
        seatInfo.bankerRate = data.banker_rate
        self.view:refreshSeatPlayerInfo(seatInfo)
        self.view:playBankerEffect(seatInfo)

        self:setRoomState(2)
        -- 抢庄完毕切换到下注

        local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
        if 0 ~= mySeatInfo.state
            and not mySeatInfo.isBanker then
            --- 庄家不能下注
            --- 抢庄之后进入下注阶段
            self.view:ControlStakeObj(true, self.modelData.curTableData.roomInfo.ruleData.game_type)
        end

        local roomInfo = self.modelData.curTableData.roomInfo
        self.view:setRoomInfo(roomInfo)
        -- 抢庄后刷新顶部房间信息，自由抢庄需要显示庄家倍数

        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            if seatInfo.isSeated and 0 ~= seatInfo.state then
                seatInfo.state = 2
                --- 设置玩家到下注阶段
            end
            self.view:refreshSeatPlayerInfo(seatInfo)
            self:subscibe_time_event(1, false, 1):OnComplete( function()
                self.view:HideGetBankerRateDis(seatInfo)
            end )
        end
    end

    if #randomBankerList > 1 then
        --- 需要播放随庄动画
        local tempList = { }
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            for j = 1, #randomBankerList do
                local info = randomBankerList[j]
                if seatInfo.playerId == info.playerId then
                    table.insert(tempList, seatInfo)
                end
            end
        end
        ModuleCache.ComponentUtil.SafeSetActive(self.view.countDownObj, false)
        self.playRandomAniing = true;
        --- 是否正在播放随庄动画
        self.view:playRandomBankerAni(tempList, bankerId, function(bankerSeatInfo)
            self.playRandomAniing = false;
            self.view:playBankerEffect(bankerSeatInfo)
            Process()
            --- 特殊处理倒计时文本
            local roomInfo = self.modelData.curTableData.roomInfo
            if roomInfo.mySeatInfo.isBanker then
                --- 自由抢庄，庄家不押注
                self.view.curTimingInfo.text = "请等待其他玩家押注"
                self.view.countDownText.text = self.view.curTimingInfo.text .. " " .. self.view.curTimingInfo.leftTime .. "s"
            end
            ModuleCache.ComponentUtil.SafeSetActive(self.view.countDownObj, true)

        end )
    else
        Process()
    end

    self.getBankerInfo = nil
end
--- 亮回复操作
function TableSanGongModule:on_Table_Show_Card(eventHead, eventData)
    local data = eventData
    if not data.is_ok then
        print(data.desc)
        return
    end
    self:updateShowCardBtnStatus(false)
    self.view:ControlLiangPaiBtn(false)

    local seatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    table.clear(seatInfo.cards)
    for i = 1, #data.cards do
        table.insert(seatInfo.cards, data.cards[i])
    end
    seatInfo.cardType = data.card_type
    seatInfo.state = 4
    --- 修改自己状态
    self.view:refreshSeatPlayerInfo(seatInfo)
    self.view:refreshMyHandCard(seatInfo.cards, seatInfo.cardType)
    self.view:HideTiming()

    if not self.isShowCardComplate and not self.isShowCarding then
        if 1 == self.modelData.curTableData.roomInfo.ruleData.manualShow then
            if not self.DragCarding then
                --- 如果不是在搓牌中则直接播放开牌动画
                self:playMyselfShowCardAni()
                --- 播放自己开牌
            else
                self:subscibe_time_event(0.5, false, 1):OnComplete( function(t)
                    --- 延迟播放自己开牌
                    ModuleCache.ModuleManager.destroy_module("sangong", "showcard")
                    self.view:ControlMyHandCard(true)
                    self:playMyselfShowCardAni( function()
                        self.isShowCarding = false
                        self.isShowCardComplate = true
                    end )
                end )
            end
        else
            self:playMyselfShowCardAni( function()
                self.isShowCarding = false
                self.isShowCardComplate = true
            end )
            --- 播放自己开牌
        end
        self.DragCarding = false
    end
end
--- 手牌通知 所有人亮牌后、下注后都会广播操纵
function TableSanGongModule:on_Table_Handcard_Notify(eventHead, eventData)
    local data = eventData

    -- 如果当前房间处于 1抢庄阶段 则切换到下注或者开牌阶段
    -- 如果当前房间处于 3等待开牌阶段则 则切换到 4等待结算
    local isDeal = false
    --- 是否这次手牌推送是发牌
    local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
    if 1 == self:getRoomState() then
        --- 房间处于抢庄阶段，只有自由抢庄玩法有抢庄
        -- self:setRoomState(2)---切换到下注
        isDeal = true
        --- 自由抢庄玩法下，抢庄阶段的手牌推送代表这次是发牌
    elseif 2 == self:getRoomState() then
        --- 房间处于下注阶段
        if 1 == gameType then
            --- 自由下注模式下，下注阶段的手牌推送代表这次是发牌
            isDeal = true
        end
    elseif 3 == self:getRoomState() then
        self:setRoomState(4)
        --- 切换到结算状态
        self.view:HideTiming()
    end

    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    for i = 1, #data.players do
        local player = data.players[i]
        local seatInfo = self:getSeatInfoByID(player.player_id)

        local newCards = { }
        for j = 1, #player.cards do
            table.insert(newCards, player.cards[j])
        end
        local limitNum = 3
        local Dvalue = limitNum - #player.cards
        for i = 1, Dvalue do
            table.insert(newCards, 0)
        end
        table.clear(seatInfo.cards)
        for j = 1, #newCards do
            if j <= limitNum then
                table.insert(seatInfo.cards, newCards[j])
            end
        end
        seatInfo.cardType = player.card_type
        if 2 == self:getRoomState() then
            seatInfo.state = 2
            --- 设置玩家到下注中
        end
        if not isDeal then
            seatInfo.state = 4
            --- 设置玩家到等待结算中
        end
        -- self.view:refreshSeatPlayerInfo(seatInfo)
        -- if seatInfo.playerId == mySeatInfo.playerId then ---如果是自己则刷新自己的手牌
        -- self.view:refreshMyHandCard(seatInfo.cards,seatInfo.cardType)
        -- end
    end
    -- todo:data.cnt ??? 这个字段干嘛的？
    -- self.view:ControlGetBankerObj(data.need_banker)
    if 0 ~= mySeatInfo.state then
        if isDeal then
            --- 是否是发牌
            self.view:ControlStakeObj(false)
            self.view:ControlGetBankerObj(false)
            self:playOtherDealCardAniOnDealState()
            --- 播放发牌给别人的动画
            self:playMyselfDealCardAniOnDealState( function()
                --- 播放发牌给自己的动画
                if 1 == self.modelData.curTableData.roomInfo.ruleData.game_type then
                    -- 自由下注
                    self.view:ControlStakeObj(true, gameType)
                elseif 2 == self.modelData.curTableData.roomInfo.ruleData.game_type then
                    -- 自由抢庄
                    self.view:ControlGetBankerObj(true)
                end
            end )
        else
            self.isDelayGameAccount = true
            --- 是否之后的小结算延迟处理，用来区别断线重连的小结算推送
            self.view:ControlLiangPaiBtn(false)
            local Process = function()
                -- self:playShowCardAni(math.random(1,6))  ---从随机位置播放所有玩家开牌翻牌
            end
            --- 如果开启了搓牌，则自动完成搓牌
            if 1 == self.modelData.curTableData.roomInfo.ruleData.manualShow then
                local showcarodmodule = ModuleCache.ModuleManager.get_module("sangong", "showcard")
                if showcarodmodule then
                    showcarodmodule:immediateShowCard()
                    showcarodmodule.onComplate = function()
                        self:subscibe_time_event(0.5, false, 1):OnComplete( function(t)
                            self.view:ControlMyHandCard(true)
                            ModuleCache.ModuleManager.destroy_module("sangong", "showcard")
                            self:playMyselfShowCardAni( function()
                                Process()
                            end )
                        end )
                    end
                else
                    Process()
                end
            else
                Process()
            end
            -- 重置玩家准备状态
            local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
            for i = 1, #seatInfoList do
                local seatInfo = seatInfoList[i]
                if seatInfo.isSeated then
                    seatInfo.isReady = false
                end
            end
        end
    end
end
--- 单播 游戏信息 登录或者断线重连时发送 操作
function TableSanGongModule:on_Table_GameInfo(eventHead, eventData)
    self:check_activity_is_open()
    self:set_gameinfo_coming_time(Time.realtimeSinceStartup)

    GameLogic:initTableData(eventData, self)

    if self.modelData.curTableData.roomInfo.isRoomStarted then
        self:clean_share_clip_board()
        --- 如果房间游戏开始了，清理房间信息分享剪贴板数据
    else
        self:refresh_share_clip_board()
        --- 如果房间游戏未开始，则刷新房间信息分享剪贴板信息
    end

    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type

    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]

        --- 处理抢庄，下注，开牌状态牌面的显示，服务器未必发下适合的数据
        local needFill = false
        --- 是否进行本地的牌数据填充
        if seatInfo.isSeated and 0 ~= seatInfo.state then
            if 1 == gameType then
                if (2 == self:getRoomState() or 3 == self:getRoomState()) then
                    needFill = true
                end
            elseif 2 == gameType then
                if (1 == self:getRoomState() or 2 == self:getRoomState() or 3 == self:getRoomState()) then
                    needFill = true
                end
            end
        end
        if needFill then
            local newCards = { }
            for i = 1, #seatInfo.cards do
                table.insert(newCards, seatInfo.cards[i])
            end
            local limitNum = 3
            local Dvalue = limitNum - #newCards
            for i = 1, Dvalue do
                table.insert(newCards, 0)
            end
            table.clear(seatInfo.cards)
            for j = 1, #newCards do
                if j <= limitNum then
                    --- 超出的牌截断不显示
                    table.insert(seatInfo.cards, newCards[j])
                end
            end
        end

        self.view:refreshSeatPlayerInfo(seatInfo)

        self.view:refreshSeatOfflineState(seatInfo)

        self.view:refreshSeatState(seatInfo)
        --- 处理自己座位信息相关的操作
        if seatInfo.playerId == mySeatInfo.playerId then
            -- 刷新自己手牌
            self.view:refreshMyHandCard(seatInfo.cards, seatInfo.cardType)
        end
    end

    -- 初始化投注按钮状态
    self.view:initStakeOprBtns(self.modelData.curTableData.roomInfo.ruleData.game_type)
    -- 更新Action相关按钮状态
    self:updateActionBtnStatus()
    -- 更新总押注信息
    self:updateTotalStakeInfo()

    local roomState = self:getRoomState()

    if 0 == roomState then
        if self.modelData.curTableData.roomInfo.isRoomStarted then
            -- 已经开局，正出于结算状态
        else
            -- 未开局，房间处于未开始状态
        end
    elseif 2 == roomState then
        if mySeatInfo.state == 2 then
            -- 玩家处于下注阶段
            if 1 == gameType then
                self.view:ControlStakeObj(true, self.modelData.curTableData.roomInfo.ruleData.game_type)
                -- 显示押注界面
            elseif 2 == gameType then
                self.view:ControlStakeObj(not mySeatInfo.isBanker, self.modelData.curTableData.roomInfo.ruleData.game_type)
                -- 显示押注界面
            end
        end
        --- 隐藏分数变动展示
        for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
            local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
            self.view:hideyScoreChangeDis(seatInfo)
        end
    elseif 1 == roomState then
        if mySeatInfo.state == 1 then
            -- 玩家处于等待抢庄状态
            self.view:ControlGetBankerObj(true)
            -- 显示抢庄界面
        end
    elseif 3 == roomState then
        if mySeatInfo.state == 3 then
            -- 玩家处于等待开牌状态
            self:updateShowCardBtnStatus(true)
            -- 显示开牌按钮
        end
    end

    --- 设置房间信息
    self.view:setRoomInfo(self.modelData.curTableData.roomInfo)

end
--- 结算操作
function TableSanGongModule:on_Table_CurrentGameAccount(eventHead, eventData)
    local data = eventData
    local roomInfo = self.modelData.curTableData.roomInfo
    self:setRoomState(0)
    --- 房间状态切换到等待状态
    if data.is_summary_account then
        -- 大结算
        local function Porcess()
            TableManagerPoker:disconnect_game_server()
            --- 断开游戏服务器链接
            ModuleCache.ModuleManager.show_module("sangong", "tableresult", data)
            ModuleCache.ModuleManager.destroy_module("henanmj", "dissolveroom", data)
            self:updateActionBtnStatus()
            -- 刷新Action按钮
        end
        if roomInfo.curRoundNum == roomInfo.totalRoundCount then
            --- 大结算延迟处理

            self:subscibe_time_event(5, false, 1):OnComplete( function()
                Porcess()
            end )
        else
            --- 牌局未结束接到大结算，比如游戏中解散房间的时候
            Porcess()
        end
    else
        -- 小结算
        local function Process()

            self.view:ControlLiangPaiBtn(false)

            for i = 1, #data.players do
                local player = data.players[i]
                local seatInfo = self:getSeatInfoByID(player.player_id)
                seatInfo.score = player.score
                table.clear(seatInfo.cards)
                for j = 1, #player.cards do
                    table.insert(seatInfo.cards, player.cards[j])
                end
                seatInfo.cardType = player.card_type
                self.view:refreshSeatPlayerInfo(seatInfo)
                --- 刷新界面
                self.view:playScoreChangeAni(seatInfo, player.current_score)
                --- 播放分数变动效果
                if seatInfo.playerId == roomInfo.mySeatInfo.playerId then
                    -- 刷新自己手牌
                    self.view:refreshMyHandCard(seatInfo.cards, seatInfo.cardType)
                end
            end

            local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
            if 1 == gameType then
                for i = 1, #data.players do
                    local player = data.players[i]
                    local seatInfo = self:getSeatInfoByID(player.player_id)
                    self.view:GetChip(seatInfo, player.current_score)
                end
                if #self.view.activeChip > 0 then
                    for i = 1, #self.view.activeChip do
                        ModuleCache.ComponentUtil.SafeSetActive(self.view.activeChip[i], false)
                    end
                    self.view.activeChip = { }
                end
            elseif 2 == gameType then
                -- 根据输赢,庄家和闲家相互丢筹码
                local bankerSeatInfo = self:getBankerSeatInfo()
                if not bankerSeatInfo then
                    return
                    -- todo:断线重连结算信息需要发送庄家是谁
                end
                local bankerPlayer = nil
                for i = 1, #data.players do
                    local player = data.players[i]
                    if player.player_id == bankerSeatInfo.playerId then
                        bankerPlayer = player
                        break
                    end
                end
                local getGroup = { }
                local thorwGroup = { }
                for i = 1, #data.players do
                    local player = data.players[i]
                    if player.player_id ~= bankerSeatInfo.playerId then
                        local num = math.abs(player.current_score)
                        local seatInfo = self:getSeatInfoByID(player.player_id)
                        if player.current_score > 0 then
                            local info = { }
                            info.form = bankerSeatInfo
                            info.to = seatInfo
                            info.num = num
                            table.insert(thorwGroup, info)
                        else
                            local info = { }
                            info.form = seatInfo
                            info.to = bankerSeatInfo
                            info.num = num
                            table.insert(getGroup, info)
                        end
                    end
                end
                local delayTime = 0
                if #getGroup > 0 then
                    delayTime = delayTime + 0.5
                end
                self:subscibe_time_event(delayTime, false, 1):OnComplete( function()
                    for i = 1, #getGroup do
                        local info = getGroup[i]
                        self.view:ThorwChipToPlayer(info.form, info.to, info.num)
                    end
                end )
                if #thorwGroup > 0 then
                    delayTime = delayTime + 0.5
                end
                self:subscibe_time_event(delayTime, false, 1):OnComplete( function()
                    for i = 1, #thorwGroup do
                        local info = thorwGroup[i]
                        self.view:ThorwChipToPlayer(info.form, info.to, info.num)
                    end
                end )
            end
            self:updateActionBtnStatus()
            -- 刷新Action按钮
        end
        if self.isDelayGameAccount then
            --- 小结算延迟处理
            self.playGameAccount = true
            self:subscibe_time_event(0.5 * self:getPlayerCount(), false, 1):OnComplete( function()
                Process()
                self.playGameAccount = false
                self:updateActionBtnStatus()
            end )
        else
            Process()
            --- 断线重连上来的，直接处理
        end
        self.isDelayGameAccount = false
    end
end
--- 超时通知
function TableSanGongModule:on_Table_TimeoutNotify(eventHead, eventData)
    local data = eventData

    local text = ""
    if 2 == data.event then
        --- 下注超时
        text = "请选择押注"
        local roomInfo = self.modelData.curTableData.roomInfo
        if 2 == roomInfo.ruleData.game_type and roomInfo.mySeatInfo.isBanker then
            --- 自由抢庄，庄家不押注
            text = "请等待其他玩家押注"
        end
        if self.playRandomAniing then
            ModuleCache.ComponentUtil.SafeSetActive(self.view.countDownObj, true)
        end
    elseif 1 == data.event then
        --- 抢庄超时
        text = "请选择是否抢庄"
    elseif 3 == data.event then
        --- 翻牌超时
        text = "请开牌"
    elseif 0 == data.event then
        --- 准备超时
        text = "等待其他玩家继续游戏"
    end
    self.view:ShowTiming(data.timeout, text)
end
--- 获取自己自己手牌返回
function TableSanGongModule:on_Table_GetCard(eventHead, eventData)
    local data = eventData
    if not data.is_ok then
        print(data.desc)
        return
    end

    self:updateShowCardBtnStatus(false)

    local seatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    table.clear(seatInfo.cards)
    for i = 1, #data.cards do
        table.insert(seatInfo.cards, data.cards[i])
    end
    seatInfo.cardType = data.card_type

    --- 开启搓牌
    if self.isDragCard then
        --- 如果是点击搓牌按钮获取的手牌信息
        local initData = { }
        initData.card = data.cards[3]
        initData.topCards = { data.cards[1], data.cards[2] }
        initData.onComplate = function()
            self:subscibe_time_event(0.5, false, 1):OnComplete( function(t)
                self.view:ControlMyHandCard(true)
                ModuleCache.ModuleManager.destroy_module("sangong", "showcard")
                self:playMyselfShowCardAni( function()
                    self.isShowCarding = false
                    self.isShowCardComplate = true
                    self.view:ControlLiangPaiBtn(true)
                end , false)
                --- 播放自己开牌
            end )
        end
        ModuleCache.ModuleManager.show_module("sangong", "showcard", initData)
        self.view:ControlMyHandCard(false)
        self.DragCarding = true
        --- 设置正在搓牌标志
    else
        --- 点击的开牌按钮获取的手牌信息
        self:playMyselfShowCardAni( function()
            self.isShowCarding = false
            self.isShowCardComplate = true
            -- self.view:ControlLiangPaiBtn(true)
            --- 不是搓牌，点击开牌后直接亮牌
            self.model:request_showcard()
        end , false)
        --- 播放自己开牌
    end
    self.isShowCarding = true
    --- 设置正在开牌中标志
end
--- 亮牌广播
function TableSanGongModule:on_Table_ShowCardNotify(eventHead, eventData)
    local data = eventData

    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    if data.player_id == mySeatInfo.playerId then
        self.view:PlayCardTypeSound(mySeatInfo.cardType, mySeatInfo)
        return
        --- 自己不处理
    end

    local info = { }
    info.playerid = data.player_id
    info.cards = data.cards
    info.card_type = data.card_type

    if not self.ShowCardQue then
        self.ShowCardQue = { }
    end
    table.insert(self.ShowCardQue, info)


    local seatInfo = self:getSeatInfoByID(info.playerid)
    local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
    local handPokers = seatHolder.inHandPokers
    self.view:fillHandCards( { 0, 0, 0 }, handPokers)
    --- 先将牌面置为背面
    self.view:proceeCardTypeDis(seatHolder, nil)
    --- 先将牌型展示隐藏

    if not self.isRunShowCardNotify then
        self:processShowCardNotify()
    end
end
--- 处理亮牌展示
function TableSanGongModule:processShowCardNotify()
    local info = self.ShowCardQue[1]
    if not info then
        self.isRunShowCardNotify = false
        return
    end
    self.isRunShowCardNotify = true
    table.remove(self.ShowCardQue, 1)

    local seatInfo = self:getSeatInfoByID(info.playerid)
    table.clear(seatInfo.cards)
    for i = 1, #info.cards do
        table.insert(seatInfo.cards, info.cards[i])
    end
    seatInfo.cardType = info.card_type
    local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
    local handPokers = seatHolder.inHandPokers
    seatInfo.state = 4
    --- 设置玩家到等待结算状态
    self.view:refreshSeatPlayerInfo(seatInfo)
    for j = 1, #handPokers do
        local targetCode = info.cards[j]
        if j == #handPokers then
            self.view:playRotateCard(handPokers[j], 0, targetCode, function()
                self:processShowCardNotify()
                --- 处理下一个
            end )
        else
            self.view:playRotateCard(handPokers[j], 0, targetCode)
        end
    end
    self.view:proceeCardTypeDis(seatHolder, info.card_type)
    self.view:PlayCardTypeSound(info.card_type, seatInfo)
end

--- 点击事件
function TableSanGongModule:on_click(obj, arg)
    if obj == self.view.buttonLeave.gameObject
        and self.modelData.curTableData.roomInfo.mySeatInfo.isCreator then
        if self.modelData.roleData.RoomType ~= 2 then
            -- 重载离开按钮响应事件           海洲 这里直接发解散命令不就可以了么？
            self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)

        else
            self.model:request_exit_room()
        end

    elseif obj == self.view.buttonLiangPai.gameObject then
        --- 亮牌
        self.model:request_showcard()
    elseif obj == self.view.buttoKaiPai.gameObject then
        self.model:request_getcard()
        self.isDragCard = false
        --- 是否是搓牌
    elseif obj == self.view.buttoCuoPai.gameObject then
        self.model:request_getcard()
        self.isDragCard = true
        --- 是否是搓牌
    elseif obj == self.view.okExStakeBtn.gameObject then
        local stakeNum = self.view.exStakeSlider.value
        -- 确定押注，直接设置的slider的MaxValue，MinValue和WholeNumbers状态，输出值直接用做押注数
        self.model:request_stake(stakeNum)
        local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
        if 2 == gameType then
            --- 自由抢庄没有丢筹码，所以在按钮上播放下注音效
            ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/coin_change.bytes", "coin_change")
        end
    elseif (obj == self.view.stakeBtn1.gameObject
        or obj == self.view.stakeBtn2.gameObject
        or obj == self.view.stakeBtn3.gameObject
        or obj == self.view.stakeBtn4.gameObject
        or obj == self.view.stakeBtn5.gameObject) then
        -- 直接用按钮对象的名字来标记押注数，在self.view.InitOprBtns()中初始化按钮状态
        local stakeNum = tonumber(obj.name);
        self.model:request_stake(stakeNum)
        local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
        if 2 == gameType then
            --- 自由抢庄没有丢筹码，所以在按钮上播放下注音效
            ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/coin_change.bytes", "coin_change")
        end
    elseif obj == self.view.noGetBankerBtn.gameObject then
        -- 放弃抢庄
        self.model:request_getbanker(0)
    elseif (obj == self.view.getBankerBtn1.gameObject
        or obj == self.view.getBankerBtn2.gameObject
        or obj == self.view.getBankerBtn3.gameObject
        or obj == self.view.getBankerBtn4.gameObject) then
        local getBankerRate = tonumber(obj.name)
        -- 确定抢庄
        self.model:request_getbanker(getBankerRate)
    elseif obj == self.view.openExStakeBtn.gameObject then
        -- 打开下注拓展操作界面
        self.view:ControlExStakeObj(true)
    elseif obj == self.view.buttonContinue.gameObject then
        -- 点击继续按钮发送准备消息
        self.model:request_ready()
    elseif obj == self.view.buttonRule.gameObject then
        -- 点击规则按钮
        ModuleCache.ModuleManager.show_module("henanmj", "tablerule", self.modelData.curTableData.roomInfo.rule)
    elseif obj.name == "KickBtn" then
        local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
        for i, v in ipairs(seatInfoList) do
            local seatHolder = self.view.seatHolderArray[v.localSeatIndex]
            if (seatHolder) then
                if (seatHolder.kickBtn == obj and v.playerId and v.playerId ~= 0) then
                    self.model:request_kick_player(v.playerId)
                    break
                end
            end
        end
    elseif obj == self.view.exStakeUpBtn.gameObject then
        self.view.exStakeSlider.value = self.view.exStakeSlider.value + 1
    elseif obj == self.view.exStakeDownBtn.gameObject then
        self.view.exStakeSlider.value = self.view.exStakeSlider.value - 1
    elseif obj == self.view.buttonHistory.gameObject then
        self:showCurRoomHistory()
        -- 设置遮罩
    elseif obj == self.view.spriteSettingMask.gameObject or obj == self.view.buttonSettingBack.gameObject then
        self.view.settingRoot:SetActive(false);
        -- 离开按钮
    elseif obj == self.view.buttonLeaveRoom.gameObject then
        if self.modelData.curTableData.roomInfo.mySeatInfo.isCreator then
            if self.modelData.roleData.RoomType ~= 2 then
                -- 重载离开按钮响应事件           海洲 这里直接发解散命令不就可以了么？
                self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1)

            else
                self.model:request_exit_room()
            end
        else
            print("第几局:", self.modelData.curTableData.roomInfo.curRoundNum);
            local canLeaveRoom =(self.modelData.curTableData.roomInfo.curRoundNum ~= 0);
            -- 已经开始打牌
            if canLeaveRoom then
                self:dispatch_package_event("Event_RoomSetting_DissolvedRoom", 1);
            else
                self.model:request_exit_room()
            end
        end
        -- 设置按钮
    elseif obj == self.view.buttonOtherSetting.gameObject then
        local data = self:getRoomSettingData()
        if (not data) then
            return
        end
        ModuleCache.ModuleManager.show_module("henanmj", "roomsetting", data)
        -- 玩法按钮
    elseif obj == self.view.buttonPlay.gameObject then
        ModuleCache.ModuleManager.show_module("public", "goldhowtoplay")
    else
        ModuleBase.on_click(self, obj, arg)
    end
end
--- 设置房间状态
function TableSanGongModule:setRoomState(state)
    self.modelData.curTableData.roomInfo.state = state
    if 0 == self.modelData.curTableData.roomInfo.state then
        self.modelData.curTableData.roomInfo.isRoundStarted = false
    end
    print("游戏进入状态 " .. self.modelData.curTableData.roomInfo.state)
end
--- 获取房间状态
function TableSanGongModule:getRoomState()
    return self.modelData.curTableData.roomInfo.state
end
--- 获取庄家的SeatInfo
function TableSanGongModule:getBankerSeatInfo()
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if seatInfo.isSeated then
            if seatInfo.isBanker then
                return seatInfo
            end
        end
    end
end
--- 用player获取玩家信息
function TableSanGongModule:getSeatInfoByID(playerId)
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if seatInfo.isSeated then
            if seatInfo.playerId == playerId then
                return seatInfo
            end
        end
    end
end
--- 获取当前玩家数量
function TableSanGongModule:getPlayerCount()
    local count = 0
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
        if seatInfo.isSeated then
            count = count + 1
        end
    end
    return count
end
--- 所有玩家是否准备完毕
function TableSanGongModule:allPlayerReady()
    local allReady = true
    for i = 1, #self.modelData.curTableData.roomInfo.seatInfoList do
        local seatInfo = self.modelData.curTableData.roomInfo.seatInfoList[i]
        if seatInfo.isSeated and not seatInfo.isReady then
            allReady = false
        end
    end
    return allReady
end


--- 更新ActionBtn相关状态
function TableSanGongModule:updateActionBtnStatus()

    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local isRoundStart = self.modelData.curTableData.roomInfo.isRoomStarted;
    -- 是否开局

    if not mySeatInfo.isReady then
        -- 自己未准备
        if not isRoundStart then
            self.view:showReadyBtn(true)
        elseif not self.playGameAccount then
            self.view:ContorlContinueBtn(true)
            -- 牌局已经开始，显示继续按钮
        end
    else
        self.view:ContorlContinueBtn(false)
        self.view:showReadyBtn(false)
    end

    if (not isRoundStart)-- 没有开局
        and self:getPlayerCount() < self.view:getTotalSeatCount() then
        -- 人数未满
        self.view:showInviteBtn(true)
        -- 显示邀请按钮
    else
        self.view:showInviteBtn(false)
        -- 隐藏邀请按钮
    end
    self.view:showLeaveBtn(not isRoundStart)
    -- 牌局未开始显示

    if (not isRoundStart)-- 没有开局
        and(self:getPlayerCount() > 1)-- 人数大于一
        and self:allPlayerReady()-- 所有玩家都准备
        and mySeatInfo.isCreator then
        -- 自己是房主
        self.view:showStartBtn(true)
        -- 显示开始按钮
        self.view.buttonInvite.transform.anchoredPosition = Vector3.New(0, self.view.buttonInvite.transform.anchoredPosition.y)
        self.view.buttonLeave.transform.anchoredPosition = Vector3.New(-310, self.view.buttonInvite.transform.anchoredPosition.y)
    else
        self.view:showStartBtn(false)
        -- 隐藏开始按钮
        self.view.buttonInvite.transform.anchoredPosition = Vector3.New(170, self.view.buttonInvite.transform.anchoredPosition.y)
        self.view.buttonLeave.transform.anchoredPosition = Vector3.New(-170, self.view.buttonInvite.transform.anchoredPosition.y)
    end

end
--- 更新开牌相关按钮状态
function TableSanGongModule:updateShowCardBtnStatus(state)
    self.view:ContorlShowCardBtn(state)
    self.view:ContorlDragCardBtns(state)
    if 1 ~= self.modelData.curTableData.roomInfo.ruleData.manualShow then
        -- 是否开启搓牌
        self.view:ContorlDragCardBtns(false)
    end
    if state then
        self.isShowCarding = false
        --- 重置是否正在开牌中
        self.isShowCardComplate = false
        --- 重置是否开牌完毕
    end
end
--- 更新总押注信息
function TableSanGongModule:updateTotalStakeInfo()
    local totalStake = 0
    local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if seatInfo.stake and seatInfo.stake > 0 then
            totalStake = totalStake + seatInfo.stake
        end
    end

    if 2 == self.modelData.curTableData.roomInfo.ruleData.game_type then
        totalStake = 0
        -- 自由抢庄不显示总下注数
    end
    self.view:ControlTotalStakeObj(totalStake > 0)
    self.view.totalStakeText.text = tostring(totalStake)

    --- 处理断线重连后重置押注时桌子筹码
    local gameType = self.modelData.curTableData.roomInfo.ruleData.game_type
    if 1 == gameType and totalStake > 0 and #self.view.activeChip < 1 then
        for i = 1, #seatInfoList do
            local seatInfo = seatInfoList[i]
            if seatInfo.stake and seatInfo.stake > 0 then
                self.view:ThorwChip(seatInfo, seatInfo.stake)
            end
        end
    end
end

--- 播放我的开牌动效
--- callback 播放完毕后的回调
function TableSanGongModule:playMyselfShowCardAni(callback, isPlaySound)
    if nil == isPlaySound then
        isPlaySound = true
    end
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local handPokers = self.view.myHandPokers
    for j = 1, #handPokers do
        local targetCode = mySeatInfo.cards[j]
        if j >= 3 then
            self.view:playRotateCard(handPokers[j], 0, targetCode, callback)
        end
    end
    self.view:proceeCardTypeDis(self.view.myCardTypeDis, mySeatInfo.cardType)
    if isPlaySound then
        self.view:PlayCardTypeSound(mySeatInfo.cardType, mySeatInfo)
    end
end
--- 播放开牌动画
--- startIndex 从几号位置开始开牌
function TableSanGongModule:playShowCardAni(startlocalIndex)
    startlocalIndex = startlocalIndex or 1
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local seatInfoOriginList = self.modelData.curTableData.roomInfo.seatInfoList
    local seatInfoList = { }

    for i = 1, #self.view.seatHolderArray do
        local realIndex = i +(startlocalIndex - 1)
        if realIndex > #self.view.seatHolderArray then
            realIndex = realIndex - #self.view.seatHolderArray
        end
        for j = 1, #seatInfoOriginList do
            local seatInfo = seatInfoOriginList[j]
            local alreadyShowCard = true
            --- 是否已经开过牌
            alreadyShowCard = 3 <= #seatInfo.cards
            for k = 1, #seatInfo.cards do
                if seatInfo.cards[k] == 0 then
                    alreadyShowCard = false
                end
            end
            if seatInfo.isSeated
                and 0 ~= seatInfo.state
                and seatInfo.seatIndex == realIndex
                and not alreadyShowCard then
                table.insert(seatInfoList, seatInfo)
                break
            end
        end
    end

    local realCount = 1
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        local isMyself = seatInfo.playerId == mySeatInfo.playerId
        if not isMyself then
            local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
            local handPokers = seatHolder.inHandPokers
            local cards = { }
            --- 缓存一下，防止数据在动画播放过程中被修改导致错误
            for j = 1, #seatInfo.cards do
                table.insert(cards, seatInfo.cards[j])
            end
            local cardType = seatInfo.cardType
            --- 缓存一下，防止数据在动画播放过程中被修改导致错误
            self.view:fillHandCards( { 0, 0, 0 }, handPokers)
            --- 先将牌面置为背面
            self.view:proceeCardTypeDis(seatHolder, nil)
            --- 先将牌型展示隐藏
            self:subscibe_time_event(1 * realCount, false, 1):OnComplete( function(t)
                for j = 1, #handPokers do
                    local targetCode = cards[j]
                    self.view:playRotateCard(handPokers[j], 0, targetCode)
                end
                self.view:proceeCardTypeDis(seatHolder, cardType)
                self.view:PlayCardTypeSound(cardType, seatInfo)
            end )
            realCount = realCount + 1
        end
    end
end

--- 播放其他玩家发牌阶段发牌动效果
function TableSanGongModule:playOtherDealCardAniOnDealState()
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local seatInfoOriginList = self.modelData.curTableData.roomInfo.seatInfoList
    local seatInfoList = { }
    local playTime = 0.5

    for i = 1, #self.view.seatHolderArray do
        for j = 1, #seatInfoOriginList do
            local seatInfo = seatInfoOriginList[j]
            if seatInfo.isSeated and 0 ~= seatInfo.state and seatInfo.seatIndex == i then
                table.insert(seatInfoList, seatInfo)
                break
            end
        end
    end

    local realIndex = 1
    for i = 1, #seatInfoList do
        local seatInfo = seatInfoList[i]
        if seatInfo.isSeated then
            local isMyself = seatInfo.playerId == mySeatInfo.playerId
            if not isMyself then
                local seatHolder = self.view.seatHolderArray[seatInfo.localSeatIndex]
                local handPokers = seatHolder.inHandPokers
                for j = 1, #handPokers do
                    local poker = handPokers[j]
                    ModuleCache.ComponentUtil.SafeSetActive(poker.face.gameObject, false)
                end
                self:subscibe_time_event(0.1 * realIndex, false, 1):OnComplete( function(t)
                    for j = 1, #handPokers do
                        local index = j
                        local poker = handPokers[j]
                        ModuleCache.ComponentUtil.SafeSetActive(poker.face.gameObject, false)
                        local delay = 3 == j and 0.2 * j + 1 or 0.2 * j
                        self:subscibe_time_event(delay, false, 1):OnComplete( function(t)
                            self.view:playDealCardToPlayerAni(handPokers, index, playTime, function()
                                ModuleCache.ComponentUtil.SafeSetActive(poker.face.gameObject, true)
                            end )
                            ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/fapai.bytes", "fapai")
                        end )
                    end
                end )
                realIndex = realIndex + 1
            end
        end
    end
end
--- 播放自己发牌阶段发牌动效果
function TableSanGongModule:playMyselfDealCardAniOnDealState(callback)
    local mySeatInfo = self.modelData.curTableData.roomInfo.mySeatInfo
    local handPokers = self.view.myHandPokers
    local playTime = 0.5
    for j = 1, #handPokers do
        local index = j
        local poker = handPokers[j]
        ModuleCache.ComponentUtil.SafeSetActive(poker.face.gameObject, false)
        local delay = 3 == j and 0.2 * j + 1 or 0.2 * j
        self:subscibe_time_event(delay, false, 1):OnComplete( function(t)
            local dealPoker = self.view:playDealCardToPlayerAni(handPokers, index, playTime, function()
                ModuleCache.ComponentUtil.SafeSetActive(poker.face.gameObject, true)
                if 3 ~= index then
                    self.view:playRotateCard(poker, 0, mySeatInfo.cards[index])
                end
                if 3 == index and callback and "function" == type(callback) then
                    callback()
                end
            end )
            ModuleCache.SoundManager.play_sound("sangong", "sangong/sound/fapai.bytes", "fapai")
            dealPoker.transform:DOScale(poker.root.transform.localScale, playTime)
        end )
    end
end

--- 显示当前房间历史战绩详情
function TableSanGongModule:showCurRoomHistory()
    local roomInfo = { }
    roomInfo.creatorId = self.modelData.curTableData.roomInfo.CreatorId
    roomInfo.playRule = self.modelData.curTableData.roomInfo.rule
    roomInfo.id = self.modelData.curTableData.roomInfo.roomHistoryId
    roomInfo.isReverseOrder = true
    roomInfo.isUseCache = true
    ModuleCache.ModuleManager.show_module("sangong", "roomdetail", roomInfo)
end

--- 更新分享信息
function TableSanGongModule:updateShareData()
    local seatCount = self.view:getTotalSeatCount()
    local roomInfo = self.modelData.curTableData.roomInfo
    local curPlayer = 0
    for i = 1, #roomInfo.seatInfoList do
        local seatInfo = roomInfo.seatInfoList[i]
        if seatInfo.isSeated then
            curPlayer = curPlayer + 1
        end
    end
    self:setShareData(seatCount, roomInfo.totalRoundCount, roomInfo.ruleData.allowHalfEnter, curPlayer)
end

return TableSanGongModule