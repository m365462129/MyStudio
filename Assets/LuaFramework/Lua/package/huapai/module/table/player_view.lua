--
-- Created by IntelliJ IDEA.
-- User: Jufeng01
-- Date: 2016/12/7
-- Time: 21:56
-- To change this template use File | Settings | File Templates.
--
local class = require("lib.middleclass")

--- @class PlayerView
--- @field module TableModule
--- @field view UnityEngine.GameObject
--- @field actionID number
--- @field chuzhang UnityEngine.GameObject
--- @field clone table
--- @field chutx UnityEngine.GameObject
--- @field chuzhangLight1 UnityEngine.GameObject
--- @field chuzhangLight2 UnityEngine.GameObject
local PlayerView = class("HuaPai.PlayerView")

local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local SoundManager = require("package.huapai.module.table.sound_manager")
local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

local SmartTime = LuaBridge.SmartTimer.instance

local curTableData

local XIA_ZHANG_OFFSET = {43, -43, 43}
local QI_ZHANG_OFFSET = {{-32, -32}, {-32, 32}, {32, 32}}
local QI_ZHANG_ROW_COUNT = {10, 8, 8}
local SHOU_ZHANG_OFFSET = {0, 43, -43}

local ACTION_NAME = {"吃", "碰", "偎", "跑", "提", "胡", "弃", "出", "将"}

local V3_ZERO = Vector3.New(0, 0, 0)
local V3_ONE = Vector3.New(1, 1, 1)
local coroutine = require("coroutine")

function PlayerView:initialize(view, index, cloneRoot, module)
    curTableData = TableManager.phzTableData
    if not view then
        return
    end

    self.module = module
    self.view = view
    self.seatIndex = index
    self.siblingIndex = self.view.transform:GetSiblingIndex()

    -- 各个父节点
    self.holder = {
        xia_zhang = Manager.FindObject(view, "XiaZhangHolder"),
        qi_zhang = Manager.FindObject(view, "QiZhangHolder"),
        chuzhang = Manager.FindObject(view, "ChuZhangHolder"),
        chuzhang1 = Manager.FindObject(view, "ChuZhangHolder1"),
        pinzhang = Manager.FindObject(view, "PinZhangHolder/Holder"),
        chutx = Manager.FindObject(view, "TeXiaoHolder"),
        seat = Manager.FindObject(view, "SeatHolder"),
        playbackGrid = Manager.FindObject(view, "PlayBackGrid"),
        shou_zhang = Manager.FindObject(view, "ShouZhangHolder"),
        CaoZuoZhe = Manager.FindObject(view, "CaoZuoZhe"),
        clock = Manager.FindObject(view, "ClockHolder")
    }

    self.holder.CaoZuoZhe = Manager.FindObject(self.module.view.root, "Players/CaoZuo/CaoZuoZhe" .. index)

    

    -- 克隆 对象
    self.clone = {
        seat = Manager.FindObject(cloneRoot, "Seat"),
        shou_zhang = Manager.FindObject(cloneRoot, "ShouZhang"),
        qi_zhang = Manager.FindObject(cloneRoot, "QiZhang"),
        chuzhang = Manager.FindObject(cloneRoot, "ChuZhang"),
        xia_zhang = Manager.FindObject(cloneRoot, "XiaZhang"),
        pinzhang = Manager.FindObject(cloneRoot, "PinZhang"),
        chutx = Manager.FindObject(cloneRoot, "ChuTX" .. AppData.Game_Name)
    }

    self:bind_seat()
end

---绑定座位
---@param seatClone UnityEngine.GameObject
---@param seatIndex number
function PlayerView:bind_seat()
    if self.view then
        local root = TableUtilPaoHuZi.clone(self.clone.seat, self.holder.seat, V3_ZERO)
        self.seat = {
            root = root,
            objNone = Manager.FindObject(root, "NotSeatDown"),
            objNoneB = Manager.GetButton(root, "NotSeatDown"),
            FangZuoBi = Manager.GetButton(root, "FangZuoBi"),
            objInfo = Manager.FindObject(root, "Info"),
            objState = Manager.FindObject(root, "State"),
            head = Manager.GetImage(root, "Info/Avatar/Mask/Image"),
            btnHead = Manager.GetButton(root, "Info/Avatar/Image"),
            name = Manager.GetText(root, "Info/TextName"),
            highlight = Manager.FindObject(root, "Info/HighLight"),
            score = Manager.GetText(root, "Info/Point/Text"),
            leave = Manager.FindObject(root, "Info/ImageStateLeave"),
            offline = Manager.FindObject(root, "Info/ImageStateDisconnect"),
            kick = Manager.GetButton(root, "Info/ButtonKick"),
            banker = Manager.FindObject(root, "Info/ImageBanker"),
            ImageDuo = Manager.FindObject(root, "Info/ImageDuo"),
            objHuxi = Manager.FindObject(root, "Info/Huxi"),
            huxi = Manager.GetText(root, "Info/Huxi/Text"),
            objClock = Manager.FindObject(root, "Info/Clock"),
            clockNum = Manager.GetComponentWithPath(root, "Info/Clock/Image/Text", "TextWrap"),
            ready = Manager.FindObject(root, "State/Group/ImageReady"),
            tuoguanz = Manager.FindObject(root, "State/Group/ImageTuoGuanz"),
            tuoguany = Manager.FindObject(root, "State/Group/ImageTuoGuany"),
            speak = Manager.FindObject(root, "State/Group/Speak"),
            objBubble = Manager.FindObject(root, "State/Group/ChatBubble"),
            textLeft = Manager.GetText(root, "State/Group/ChatBubble/TextBgLeft/Text"),
            textRight = Manager.GetText(root, "State/Group/ChatBubble/TextBgRight/Text"),
            objFace = Manager.FindObject(root, "State/Group/ChatFace")
        }

        self.seat.face = TableUtilPaoHuZi.get_all_child(self.seat.objFace)

        local sw = Manager.GetComponent(self.seat.root, "UIStateSwitcher")
        if self.seatIndex == 2 then
            sw:SwitchState("Right")
        else
            sw:SwitchState("Left")
        end

        self.seat.objFace.transform.position = self.seat.head.transform.position
        self.seat.objClock.transform.position = self.holder.clock.transform.position
        self.seat.name.text = ""
        self:show_huxi(false)
        


        self.FanQiZhang = {}
        self.FanQiZhang[3] = {}
        self.FanQiZhang[2] = {}
        self.FanQiZhang[1] = {}

        self.cloneRoot = self.module.view.root

        for i=1,12 do
            self.FanQiZhang[3][i] = Manager.FindObject(self.module.view.root, "Players/QiZhang/Grid3/Pai" .. i)
            self.FanQiZhang[2][i] = Manager.FindObject(self.module.view.root, "Players/QiZhang/Grid2/Pai" .. i)
            self.FanQiZhang[1][i] = Manager.FindObject(self.module.view.root, "Players/QiZhang/Grid1/Pai" .. i)
        end

        self.QiZhangGo = Manager.FindObject(self.module.view.root, "Players/QiZhang")

        Manager.AddButtonListener(
            self.seat.objNoneB,
            function()
                FunctionPaoHuZi.invite_friend()
            end
        )
        Manager.AddButtonListener(
            self.seat.btnHead,
            function()
                if self.playerInfo and not curTableData.isPlayBack then
                    ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", self.playerInfo)
                end
            end
        )

        if self.seat.FangZuoBi then
            Manager.AddButtonListener(
                self.seat.FangZuoBi,
                function()
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("开局后显示玩家信息")
                end
            )
        end
        
    end
end

--- 刷新角色信息
function PlayerView:refresh_player_info(data)
    if data then
        if not curTableData.isPlayBack then
            if not data.UserID or data.UserID == "0" then
                self.playerInfo = nil
                ComponentUtil.SafeSetActive(self.seat.objInfo, false)
                ComponentUtil.SafeSetActive(self.seat.objState, false)
                ComponentUtil.SafeSetActive(self.seat.objNone, true)
            else
                if (not curTableData.seatUserIdInfo) then
                    curTableData.seatUserIdInfo = {}
                end
                if not self.playerInfo then
                    self.playerInfo = {}
                end

                if data.Balance and data.Balance > 0 then
                    self:update_score(data.Balance)
                end

                self.playerInfo.playerId = data.UserID
                curTableData.seatUserIdInfo[data.SeatID .. ""] = data.UserID
                ComponentUtil.SafeSetActive(self.seat.objInfo, true)
                ComponentUtil.SafeSetActive(self.seat.objState, true)
                ComponentUtil.SafeSetActive(self.seat.objNone, false)

                --TODO XLQ:牌友圈快速组局 房主没有踢人功能
                if
                    data.SeatID ~= 0 and curTableData.SeatID == 0 and not self.module.roundStart and
                        curTableData.RoomType ~= 2
                 then
                    self:show_kick(not (self.module:is_all_ready() and not DataHuaPai.Msg_Table_GameStateNTF))
                    Manager.AddButtonListener(
                        self.seat.kick,
                        function()
                            self.module.model:request_kick_player(data.UserID)
                        end
                    )
                else
                    self:show_kick(false)
                end

                --TODO XLQ:牌友圈 允许在线玩家踢出离线玩家     data.State 用户状态信息：0、在线；1、离开（休息）；2、离线
                if
                    curTableData.RoomType == 2 and
                        (not DataHuaPai.Msg_Table_GameStateNTF or DataHuaPai.Msg_Table_GameStateNTF.RealyRound == 0)
                 then
                    if
                        DataHuaPai.Msg_ReportStateNTF_Table and DataHuaPai.Msg_Table_GameStateNTF == nil and
                            DataHuaPai.Msg_ReportStateNTF_Table[data.SeatID] and
                            tonumber(DataHuaPai.Msg_ReportStateNTF_Table[data.SeatID].State) == 2
                     then
                        self:show_kick(not (self.module:is_all_ready() and not DataHuaPai.Msg_Table_GameStateNTF))
                        Manager.AddButtonListener(
                            self.seat.kick,
                            function()
                                self.module.model:request_kick_player(data.UserID)
                            end
                        )
                    end
                end

                self:show_clock(false)

                TableUtilPaoHuZi.download_seat_detail_info(
                    data.UserID,
                    function(playerInfo)
                        if not self.module.view then
                            return
                        end
                        self.seat.head.sprite = playerInfo.headImage
                        self.playerInfo.spriteHeadImage = self.seat.head.sprite
                    end,
                    function(playerInfo)
                        if not self.module.view then
                            return
                        end

                        self.seat.name.text = Util.filterPlayerName(playerInfo.playerName, 10)
                        self.man = playerInfo.gender == 1
                        self.ip = playerInfo.ip
                        if self.playerInfo then
                            self.playerInfo.ip = playerInfo.ip
                            self.playerInfo.playerName = playerInfo.playerName
                            self.playerInfo.gender = playerInfo.gender
                        end
                    end
                )
            end
        else
            ComponentUtil.SafeSetActive(self.seat.objInfo, true)
            ComponentUtil.SafeSetActive(self.seat.objState, false)
            ComponentUtil.SafeSetActive(self.seat.objNone, false)
            self.seat.name.text = Util.filterPlayerName(data.playerName, 10)

            if self.dataStateoyl and self.dataStateoyl.total_hu_xi > 0 then
                self:update_score(self.dataStateoyl.total_hu_xi)
            else
                self:update_score(data.playerScore)
            end

            TableUtilPaoHuZi.only_download_head_icon(self.seat.head, data.headImg)
            self:show_light(false)
            self:show_banker(false)
        end
    else
        ComponentUtil.SafeSetActive(self.seat.objInfo, false)
        ComponentUtil.SafeSetActive(self.seat.objState, false)
        ComponentUtil.SafeSetActive(self.seat.objNone, true)
    end
end

--- 更新位置信 息
function PlayerView:update_location_data(data)
    if not self.playerInfo then
        self.playerInfo = {}
    end
    self.playerInfo.locationData = data
end

local TimeWenziDongHua = 0.8 -- 文字动画
local TimeChuhangYiDong = 0.3
local TimeQiZhangYiDong = 0.25
local TimeShouZhangYidong = 0.1
local TimeXiaZhangYiDong = 0.15
--- 刷新游戏状态
function PlayerView:refresh_game_state(data, actionID, stay)
    print(actionID .. "  OAOA")

    self.actionIDMy = actionID
    --//1:抵 2:吃 3:碰 4:绍 5:下抓 6:半挎  7:满挎 8:出 9：翻弃牌 10：出弃牌 11：胡  12: 开局 13:出张收回
    if data then
        --self:showHuPai()
        local chuqiValue = 0

        if data.chu_pai == 1 then
           chuqiValue = data.fan_zhang[#data.fan_zhang]
        end

        if data.chu_pai == 2 then
            chuqiValue = data.qi_zhang[#data.qi_zhang]
        end



        if actionID == 0 or self.module.firstGameState then
            -- 如果是本人则  且为庄家 0.3秒后将牌隐藏
            self:refresh_xiazhang(data.xia_zhang, false)
            self:refresh_qizhang(data)
            self:refreshQiZHang()

            if actionID == 8 then
                self:show_chuzhang(chuqiValue, true)
                --SoundManager:play_nameroot("fanpai")
            end
        elseif DataHuaPai.Msg_Table_GameStateNTF.result == 1 then
            self:refresh_xiazhang(data.xia_zhang, false)
            self:refresh_qizhang(data)
        elseif
            (actionID >= 1 and actionID <= 7) or actionID == 11
         then
            self:show_chutx(actionID)
            SoundManager:play_action(actionID)
            self:refresh_xiazhang(data.xia_zhang, true, actionID)

            
            for i = 1, 3 do
                if actionID ~= 18 and actionID ~= 19 then
                    self.playersViewAll[i]:hide_chuzhang()
                end
            end

            coroutine.wait(0.1)
        elseif actionID == 9 or actionID == 10 then
            
            self:add_qizhang(chuqiValue, true)
        elseif actionID == 13 then
            coroutine.wait(2)
            self:add_qizhang(chuqiValue, true)
            
        elseif actionID == 8 then
            if chuqiValue ~= 0 then
                self:show_chuzhang(chuqiValue, true)
                --SoundManager:play_nameroot("fanpai")
            end
        end

        self:add_shouzhang(data)
        self:update_huxi()
        self:update_tuoguan()

        if DataHuaPai.Msg_Table_GameStateNTF.result == 0 then
            self:refresh_xiazhangData(data.xia_zhang)
        end

        if DataHuaPai.Msg_Table_GameStateNTF and DataHuaPai.Msg_Table_GameStateNTF.result == 1 then
            self:show_clock(false)
            self.QiZhangGo:SetActive(false)
        end

    end
end

-- 刷新弃张
function PlayerView:refreshQiZHang()
    self.QiZhangGo:SetActive(true)
    for i=1,12 do
        self.FanQiZhang[self.localSeatID][i].gameObject:SetActive(false)
    end

    for i=1,#self.dataStateoyl.qi_zhang do
        local go = self.FanQiZhang[self.localSeatID][i]
        go.gameObject:SetActive(true)
        TableUtilPaoHuZi.set_card(go, self.dataStateoyl.qi_zhang[i], nil, "ZiPai_PlayCards")
    end
end

function PlayerView:showHuPai()
    --repeated int32 hu_fa_action 		= 21;     // 胡法的类型 0、流局 1、平胡 2、自摸 3、天胡  4、地胡  5、三笼五坎 6、接炮 7、点炮
    --optional bool is_dian_pao			 = 22;//是否点炮

    DataHuaPai.PlayerView_WaitTime = 0
    -- 点炮了
    local dataStateoyl = self.dataStateoyl
    if dataStateoyl.hu_fa_action ~= nil and #dataStateoyl.hu_fa_action > 0 then
        local hu_fa_action = dataStateoyl.hu_fa_action[1]

        if hu_fa_action >= 1 then
            --   点炮--->接炮  改为了  点炮--->胡      这个胡还是没音效的
            if hu_fa_action == 6 then
                hu_fa_action = 1
            end

            if hu_fa_action ~= 6 then
                SoundManager:play_name("k" .. hu_fa_action, self.man)
            end
            self:show_chutx(100 + hu_fa_action)
        end
    end
end

function PlayerView:clear_sequence()
    if self.chuzhangSeq then
        self.chuzhangSeq:Kill(false)
        self.chuzhangSeq = nil
    end

    if self.qizhangSeq then
        self.qizhangSeq:Kill(false)
        self.qizhangSeq = nil
    end

    if self.xiazhangSeq then
        self.xiazhangSeq:Kill(false)
        self.xiazhangSeq = nil
    end
end

function PlayerView:clear()
    self:clear_sequence()
    if self.clockEventId then
        SmartTime:Kill(self.clockEventId)
        self.clockEventId = nil
    end
    self.seat.name.text = ""
    self.seat.score.text = ""
    self.seat.objInfo:SetActive(false)
    self.huxi = 0
    self:show_light(false)
    self:show_offline(false)
    self:show_ready(false)
    self:show_banker(false)
    self.QiZhangGo:SetActive(false)
    self:clear_cards()
end

function PlayerView:clear_cards()
    self.huxi = 0
    self:show_huxi(false)
    self:hide_chuzhang()
    self.xiazhangList = nil
    self.qizhangList = nil
    Manager.DestroyChildren(self.holder.xia_zhang)
    Manager.DestroyChildren(self.holder.qi_zhang)
    Manager.DestroyChildren(self.holder.pinzhang)
    Manager.DestroyChildren(self.holder.shou_zhang)
end

---更新胡息数
---@param huxi number
function PlayerView:update_huxi()
  

    self:show_huxi(true)
    if DataHuaPai.Msg_Table_GameStateNTFNew and DataHuaPai.Msg_Table_GameStateNTFNew.result == 2 then
        return
    end

    self.seat.huxi.text = '点数:' .. self.dataStateoyl.cur_hu_shu
end

---更新胡息数
---@param huxi number
function PlayerView:update_tuoguan()
    if not self.seat.tuoguanz then
        return
    end

    self.seat.tuoguanz.gameObject:SetActive(false)
    self.seat.tuoguany.gameObject:SetActive(false)

    local tuoguan = nil
    if self.seatIndex == 2 then
        tuoguan = self.seat.tuoguanz
    end

    if self.seatIndex == 3 then
        tuoguan = self.seat.tuoguany
    end

    if self.seatIndex == 1 then
        return
    end

    if self.dataStateoyl and self.dataStateoyl.IntrustState then
        tuoguan.gameObject:SetActive(self.dataStateoyl.IntrustState ~= 0)
    end
end

--- 显示胡息
function PlayerView:show_huxi(show)
    ComponentUtil.SafeSetActive(self.seat.objHuxi, show)
    ComponentUtil.SafeSetActive(self.seat.huxi.gameObject, show)
end

---更新分数
---@param score number
function PlayerView:update_score(score)
    self.module:start_lua_coroutine(
        function()
            if DataHuaPai.Msg_Table_GameStateNTF and DataHuaPai.Msg_Table_GameStateNTF.result == 1 and self.view then
                coroutine.wait(3)
                if AppData.Game_Name == "GLZP" then
                    coroutine.wait(5)
                end
            end
            local str = tostring(score)
            if score >= 100000000 then
                local yi = tostring(score / 100000000)
                local subIndex = string.find(yi, ".")
                str = string.sub(yi, 1, subIndex + 2) .. "亿"
            elseif score >= 10000 then
                local wan = tostring(score / 10000)
                local subIndex = string.find(wan, ".")
                str = string.sub(wan, 1, subIndex + 2) .. "万"
            end

            self.seat.score.text = '分数:' .. str
        end
    )
end

---显示高亮
---@param b boolean
function PlayerView:show_light(b)
    self:show_clock(b)
    --self.seat.highlight:SetActive(b)

    self.holder.CaoZuoZhe:SetActive(b)
end

---显示倒计时闹钟
---@param b boolean
function PlayerView:show_clock(b)
    if curTableData.isPlayBack then
        self.seat.objClock:SetActive(false)
        return
    end

    if DataHuaPai.Msg_Table_GameStateNTF and DataHuaPai.Msg_Table_GameStateNTF.result == 1 then
        self.seat.objClock:SetActive(false)
        return
    end

    self.seat.objClock:SetActive(b)
    if self.clockEventId then
        SmartTime:Kill(self.clockEventId)
        self.clockEventId = nil
    end

    if self.show_clock_coroutine then
        coroutine.stop(self.show_clock_coroutine)
        self.show_clock_coroutine = nil
    end

    if not b then
        return
    end

    local time = DataHuaPai.Msg_Table_GameStateNTF.IntrustRestTime

    local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)
    if ruleInfo.baseScore then
    else
        time = 15
    end

    self.show_clock_coroutine =
        self.module:start_lua_coroutine(
        function()
            self.indexofccsa = self.indexofccsa or 0
            self.indexofccsa = self.indexofccsa + 1

            for i = time, 1, -1 do
                self:set_clock_num(i)

                local indexofccsa = self.indexofccsa

                coroutine.wait(1)
                if indexofccsa ~= self.indexofccsa then
                    break
                end
                self.seat.objClock:SetActive(true)
                if i <= 5 then
                    SoundManager:play_clock()
                end
                if
                    DataHuaPai.Msg_Table_GameStateNTF and DataHuaPai.Msg_Table_GameStateNTF.result ~= 0 or
                        self:has_actionWhat(6)
                 then
                    self.seat.objClock:SetActive(false)
                    return
                end
            end
            if not self.module.view.openShake then
                ModuleCache.GameSDKInterface:ShakePhone(1000)
            end
            self.seat.objClock:SetActive(false)
        end
    )
end

---设置倒计时闹钟数字
---@param num number
function PlayerView:set_clock_num(num)
    self.seat.clockNum.num = num
end

---显示离线
---@param b boolean
function PlayerView:show_offline(b)
    self.seat.offline:SetActive(b)
end

--- 显示离开
--- @param b boolean
function PlayerView:show_leave(b)
    self.seat.leave:SetActive(b)
end

---显示庄家
---@param b boolean
function PlayerView:show_banker(b)
    self.seat.banker:SetActive(b)
end
---显示 duo
---@param b boolean
function PlayerView:show_ImageDuo(b)
    if self.seat.ImageDuo then
        self.seat.ImageDuo:SetActive(b)
    end
end

---显示准 备
---@param b boolean
function PlayerView:show_ready(b)
    self.seat.ready:SetActive(b)
    if DataHuaPai.Msg_Table_GameStateNTF and DataHuaPai.Msg_Table_GameStateNTF.result == 1 then
    -- self.seat.ready:SetActive(false)
    end
end

--- 显示踢人
function PlayerView:show_kick(b)
    ComponentUtil.SafeSetActive(self.seat.kick.gameObject, b)
end

function PlayerView:show_chuzhangSelf(value, playAnim)
    self.module:start_lua_coroutine(
        function()
            self:show_chuzhang(value, true)
        end
    )
    --dself.chuzhangSelf = self.chuzhang
end

---显示出张
---@param value number
---@param isZhua boolean
function PlayerView:show_chuzhang(value, playAnim)

    

    if not self.chuzhang then
        self.chuzhang = TableUtilPaoHuZi.clone(self.clone.chuzhang, self.holder.chuzhang, V3_ZERO)
        self.chuzhang.gameObject:SetActive(false)
        self.chuzhangLight1 = Manager.FindObject(self.chuzhang, "Image/1")
        self.chuzhangLight2 = Manager.FindObject(self.chuzhang, "Image/2")
    end



    
    if  DataHuaPai.chuzhangValueLocalIndex == self.localSeatID and DataHuaPai.chuzhangValue == value and value ~= 0 then
        return
    end
    

    DataHuaPai.chuzhangValue = value
    DataHuaPai.chuzhangValueLocalIndex = self.localSeatID


    DataHuaPai.ChuZhangObj = self.chuzhang

    if playAnim then
        if value ~= 0 then
            SoundManager:play_card(value, self.man)
        end
    end

    TableUtilPaoHuZi.set_card(self.chuzhang, value, nil, "ZiPai_CurPutCards")
    self.chuzhangLight1.gameObject:SetActive(false)
    self.chuzhangLight2.gameObject:SetActive(false)
    if self.dataStateoyl and self.dataStateoyl.chu_pai == 1 then
        self.chuzhangLight2.gameObject:SetActive(true)
    else
        self.chuzhangLight1.gameObject:SetActive(true)
    end

    local isPaiDui = false
        
    if self.dataStateoyl and self.dataStateoyl.chu_pai == 1 then
        isPaiDui = true
    end




    local posChuZhang = self.holder.chuzhang.transform.position
    DataHuaPai.chuzhangPosTran = self.holder.chuzhang.transform
    if not isPaiDui and self.localSeatID == 1 then
        posChuZhang = self.holder.chuzhang1.transform.position
        DataHuaPai.chuzhangPosTran = self.holder.chuzhang1.transform
    end 
    
    
   

    --ZiPai_CurPutCards  ZiPai_HandCards self.actionIDMy
    if self.module.firstGameState or not playAnim then
        self.chuzhang.transform.localScale = V3_ONE
        self.chuzhang:SetActive(true)
    else
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, true)
        local stayTime = 0
        TableUtilPaoHuZi.print("播放出张 动画")
        self.chuzhang.transform.localScale = V3_ZERO
        self.chuzhang:SetActive(true)

      
        self.chuzhang.transform.position = self.holder.chuzhang.transform.position


        local time = 0.15

        if isPaiDui then
            

            TableUtilPaoHuZi.set_card(self.chuzhang, 0, nil, "ZiPai_CurPutCards")
            self.chuzhang.transform.position = self.module.view.CenterObj.transform.position

            self.chuzhang.transform.localEulerAngles = Vector3.New(0, 0, 90)
            self.chuzhang.transform.localScale = Vector3.New(1, 1, 1)
            -- 如果 是牌堆中出来的牌    则  播放发牌动画

            self.chuzhang.transform.localScale = Vector3.New(0, 0, 1)
            self.chuzhang.transform:DOScale(Vector3.New(1.2, 1.2, 1.2), 0.4)
            coroutine.wait(0.38)
            self.chuzhang.transform:DOScale(Vector3.New(1, 1, 1), 0.15)
            coroutine.wait(0.12)

            self.chuzhang.transform:DOLocalRotate(Vector3.New(180, 0, 90), 0.25)
       
            --旋转一周
            TableUtilPaoHuZi.set_card(self.chuzhang, value, nil, "ZiPai_CurPutCards")
  

            self.chuzhang.transform.localEulerAngles = Vector3.New(0, 0, 90)
            
            -- 然后 转向  移动到  出张位置    且移动到出张位置
            self.chuzhang.transform:DOLocalRotate(Vector3.New(0, 0, 0), 0.3)
            self.chuzhang.transform:DOMove(self.holder.chuzhang.transform.position, 0.3)

            coroutine.wait(0.3)

            coroutine.wait(0.45)

  
            
        end

        if not isPaiDui then

            self.chuzhang.transform.position = self.holder.chuzhang.transform.position
            if self.localSeatID == 1 then
                self.chuzhang.transform.position = self.holder.chuzhang1.transform.position
            end
            
            self.chuzhang.transform.localScale = V3_ONE*1.2
            self.chuzhang.transform:DOScale(Vector3.New(1.5, 1.5, 1.3), 0.1)
            coroutine.wait(0.1)
            self.chuzhang.transform:DOScale(Vector3.New(1, 1, 1), 0.25)
            coroutine.wait(0.25)

            coroutine.wait(0.45)
         
            

        end

        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, false)
    end

end

function PlayerView:show_dangdi(value)
end

---隐藏出张
function PlayerView:hide_chuzhang()
    if self.chuzhang then
        self.chuzhang:SetActive(false)
        self.chuzhang.transform.localScale = V3_ZERO

        if self.module.view then
            self.chuzhang.transform.position = self.module.view.CenterObj.transform.position
        end
    end
end

--是否有出张
function PlayerView:getIsHaveChuZhang()
    if self.chuzhang then
        return self.chuzhang.gameObject.activeInHierarchy
    end
    return false
end

---添加挡抵
function PlayerView:add_dangdi()
    local qizhangSeq = self.module.view:create_sequence()
    self.chuzhang:SetActive(true)
    self.chuzhang.transform.position = self.module.view.CenterObj.transform.position
    local tw1 = Manager.Move(self.chuzhang, self.holder.chuzhang.transform.position, 0.2)
    qizhangSeq:Append(tw1)
    qizhangSeq:OnComplete(
        function()
        end
    )
    qizhangSeq:Play()
end

--- 刷新弃张
function PlayerView:refresh_qizhang(data)
    if curTableData.isPlayBack then
        self.qizhangList = nil
        Manager.DestroyChildren(self.holder.qi_zhang)
    end
    local qizhangCount = 0
    if self.qizhangList then
        qizhangCount = #self.qizhangList
    end
    if qizhangCount < #data.fan_zhang then
        for i = qizhangCount + 1, #data.fan_zhang do
            if i == #data.fan_zhang and data.chu_pai ~= 0 then
                --self:show_chuzhang(data[i], false)
            else
                self:add_qizhang(data.fan_zhang[i], false)
            end
        end
    end
end


--- 刷新弃张
function PlayerView:refresh_qizhangMy(data)
    data = self.dataStateoyl
    if not self.holder then
        return
    end

    self.qizhangList = nil
    Manager.DestroyChildren(self.holder.qi_zhang)

    for i = 1, #data.fan_zhang do
        self:add_qizhangMy(data.fan_zhang[i])
    end
end

function PlayerView:add_qizhangMy(value)
    self.qizhangList = self.qizhangList or {}
    table.insert(self.qizhangList, value)
    local x = ((#self.qizhangList - 1) % QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][1]
    local y =
        math.floor((#self.qizhangList - 1) / QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][2]
    local pos = Vector3.New(x, y, 0)
    ---@type UnityEngine.GameObject
    local qi_zhang = TableUtilPaoHuZi.clone(self.clone.qi_zhang, self.holder.qi_zhang, pos)
    qi_zhang:SetActive(true)
    TableUtilPaoHuZi.set_card(qi_zhang, value, nil, "ZiPai_PlayCards")
    --ZiPai_CurPutCards  ZiPai_HandCards
    qi_zhang.transform.localScale = V3_ONE
    qi_zhang:SetActive(true)
end

---添加弃张
---@param value number
function PlayerView:add_qizhang(value, playAnim, stay)

 
    -- 同一个人  不存在 同一张牌  弃两次的情况
    if DataHuaPai.qizhangValueLocalIndex == self.localSeatID and DataHuaPai.qizhangValue == value and value ~= 0 then


       
        return
    end
    DataHuaPai.qizhangValue = value
    DataHuaPai.qizhangValueLocalIndex = self.localSeatID


    if not self.chuzhang then
        return
    end

    local stayTime = 0
    TableUtilPaoHuZi.print("添加弃张", value)
    if not self.qizhangList then
        self.qizhangList = {}
    end
    table.insert(self.qizhangList, value)
    local x = ((#self.qizhangList - 1) % QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][1]
    local y =
        math.floor((#self.qizhangList - 1) / QI_ZHANG_ROW_COUNT[self.seatIndex]) * QI_ZHANG_OFFSET[self.seatIndex][2]
    local pos = Vector3.New(x, y, 0)
    ---@type UnityEngine.GameObject
    local qi_zhang = TableUtilPaoHuZi.clone(self.clone.qi_zhang, self.holder.qi_zhang, pos)
    TableUtilPaoHuZi.set_card(qi_zhang, value, nil, "ZiPai_PlayCards")
    --ZiPai_CurPutCards  ZiPai_HandCards .transform.position = self.module.view.CenterObj.transform.position
    qi_zhang.transform.localScale = V3_ZERO

    qi_zhang:SetActive(true)
    if self.module.firstGameState or not playAnim then
        TableUtilPaoHuZi.print("没播弃张动画，执行回调 ")
        qi_zhang.transform.localScale = V3_ONE

        for i = 1, 3 do
            for i = 1, 3 do
                --self.playersViewAll[i]:hide_chuzhang()
            end
        end

        if DataHuaPai.booIsLoadAll_ZiPai then
            self:refresh_qizhangMy()
        end
    else
        TableUtilPaoHuZi.print("播放弃张动画  ")
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, true)
        local time = TimeQiZhangYiDong
        if self.qizhangSeq then
            self.qizhangSeq:Kill(false)
            self.qizhangSeq = nil
        end

     
        DataHuaPai.chuzhangPosTran = DataHuaPai.chuzhangPosTran or self.holder.chuzhang.transform

        self.qizhangSeq = self.module.view:create_sequence()
        self.qizhangSeq:AppendInterval(stayTime)

        if not self.chuzhang then
           
        end

        local pos = qi_zhang.transform.position
        if self.actionIDMy == 10 then

            
            pos = self.FanQiZhang[self.localSeatID][#self.dataStateoyl.qi_zhang].transform:Find("Image").position
            --Image
        end

        if self.actionIDMy == 13 then
            if self.localSeatID == 1 then
                pos = self.holder.playbackGrid.transform.position
            else
                pos = self.holder.xia_zhang.transform.position
            end
        end

        self.chuzhang:SetActive(true)
        self.chuzhang.transform.localScale = V3_ONE
        self.chuzhang.transform.position = DataHuaPai.chuzhangPosTran.position

        local tw1 = Manager.Move(self.chuzhang, pos, time)
        local tw2 = Manager.DoScale(self.chuzhang, 0.3, time)
        self.qizhangSeq:Append(tw1)
        self.qizhangSeq:Join(tw2)
        --seq:PrependInterval(0.05)
        self.qizhangSeq:SetAutoKill(true)

        local boolFlag = true
        self.qizhangSeq:OnComplete(
            function()
                boolFlag = false
                -- 播放完毕 弃张动画后       直接刷新所有 弃张
                self:hide_chuzhang()
                --qi_zhang.transform.localScale = V3_ONE
                TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, false)
                self:refresh_qizhangMy()
                self:refreshQiZHang()
            end
        )

        self.qizhangSeq:Play()

        for i = 1, 0 do
            coroutine.wait(0.1)
            if not boolFlag then
                break
            end
        end

        coroutine.wait(0.5)
    end
end

function PlayerView:refresh_xiazhangData(data)
    self.xiazhangList = nil
    Manager.DestroyChildren(self.holder.xia_zhang)
    self.xiazhangList = nil
    self.huxi = 0
    for i = 1, #data do
        local obj = self:add_xiazhangData(data[i])
        obj.transform.localScale = V3_ONE
    end
    self:update_huxi()
end

--- 刷新下张
function PlayerView:refresh_xiazhang(data, playAnim, actionID)
    if curTableData.isPlayBack and not playAnim then
        self.xiazhangList = nil
        self.huxi = 0
        self.xiazhangList = nil
        Manager.DestroyChildren(self.holder.xia_zhang)
        Manager.DestroyChildren(self.holder.pinzhang)
    end
    if not self.xiazhangList then
        self.xiazhangList = {}
    end

    local act = actionID
    local booIsLoadAll = act and (act == 11)

    local xia_zhang = {}

    if actionID == 11 and self.seatIndex == 1 then
        for i = #data, #self.xiazhangList + 1, -1 do
            table.insert(xia_zhang, self:add_xiazhang(data[i]))
        end
    else
        for i = #self.xiazhangList + 1, #data do
            table.insert(xia_zhang, self:add_xiazhang(data[i]))
        end

        if #xia_zhang == 0 and actionID then
            local valuesis = DataHuaPai.chuzhangValue or 0
            local kan = {}
            local pai = {}
            pai[1] = {}
            pai[1].pai = DataHuaPai.chuzhangValue
            pai[2] = {}
            pai[2].pai = DataHuaPai.chuzhangValue
            pai[3] = {}
            pai[3].pai = DataHuaPai.chuzhangValue
            pai[4] = {}
            pai[4].pai = DataHuaPai.chuzhangValue

            kan.pai = pai
            kan.des = ""
            kan.is_kua_kan = false
            kan.hu_shu = 0
            table.insert(xia_zhang, self:add_xiazhang(kan))
        end
    end

    if self.module.firstGameState or not playAnim then
        for i = 1, #xia_zhang do
            xia_zhang[i].transform.localScale = V3_ONE
        end
        Manager.DestroyChildren(self.holder.pinzhang)
    else
        self.view.transform:SetAsLastSibling()
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, true)
        local time = 0.16
        if self.xiazhangSeq then
            self.xiazhangSeq:Kill(false)
            self.xiazhangSeq = nil
        end
        self.xiazhangSeq = self.module.view:create_sequence()
        self.xiazhangSeq:AppendInterval(0.2)
        if not xia_zhang or #xia_zhang == 0 then
            self.xiazhangSeq:Kill(false)
            self.xiazhangSeq = nil
            Manager.DestroyChildren(self.holder.pinzhang)

            return
        end

        local pos = xia_zhang[1].transform.position
        if #xia_zhang > 2 then
            pos = xia_zhang[2].transform.position
        end

       

        if DataHuaPai.ChuZhangObj then
            DataHuaPai.ChuZhangObj.gameObject:SetActive(false)
        end

        if DataHuaPai.ChuZhangObj and DataHuaPai.chuzhangPosTran then
            local obj234234 = TableUtilPaoHuZi.clone(DataHuaPai.ChuZhangObj, self.holder.chuzhang, V3_ONE)
            obj234234.gameObject:SetActive(true)
            obj234234.transform.position = DataHuaPai.chuzhangPosTran.position
            local imgssss = obj234234:GetComponent("CanvasGroup")
            imgssss:DOFade(0, 0.6)
        end

        self.holder.pinzhang.transform.position = self.holder.pinzhang.transform.position
        self.holder.pinzhang.transform.localScale = V3_ONE*0.2

        self.holder.pinzhang.transform:DOScale(Vector3.New(1.1, 1.1, 1.1), 0.13)
        coroutine.wait(0.13)
        self.holder.pinzhang.transform:DOScale(Vector3.New(1, 1, 1), 0.15)
        coroutine.wait(0.25)
        self.holder.pinzhang.transform:DOScale(Vector3.New(0.5, 0.5, 0.5), 0.25)
        self.holder.pinzhang.transform:DOMove(pos, 0.25)
        coroutine.wait(0.25)


        boofalgcao = false
        self.view.transform:SetSiblingIndex(self.siblingIndex)
        --- 胡的时候把所有下张清除重新生成，规避偎、跑、       提后胡牌导致的下张显示重复问题

        if actionID == 11 or DataHuaPai.Msg_Table_GameStateNTF.result == 1 then
            self.xiazhangList = nil
            Manager.DestroyChildren(self.holder.xia_zhang)
            self.xiazhangList = nil
            self.huxi = 0
            for i = 1, #data do
                local obj = self:add_xiazhang(data[i])
                obj.transform.localScale = V3_ONE
            end
            self:update_huxi()
        else
            for i = 1, #xia_zhang do
                self.module:start_lua_coroutine(
                    function()
                        self.module:start_lua_coroutine(
                            function()
                                xia_zhang[i].transform.localScale = V3_ONE
                            end
                        )
                    end
                )
            end
        end

        Manager.DestroyChildren(self.holder.pinzhang)
        self.holder.pinzhang.transform.localScale = V3_ZERO
        self.holder.pinzhang.transform.localPosition = V3_ZERO
        TableUtilPaoHuZi.set_frame_rate(TableUtilPaoHuZi.draggingCard, false)

        coroutine.wait(0.05)
    end

    if DataHuaPai.Msg_Table_GameStateNTF.result == 1 and not playAnim or DataHuaPai.booIsLoadAll_ZiPai then
        self.xiazhangList = nil
        Manager.DestroyChildren(self.holder.xia_zhang)
        self.xiazhangList = nil
        self.huxi = 0
        for i = 1, #data do
            local obj = self:add_xiazhang(data[i])
            obj.transform.localScale = V3_ONE
        end
        self:update_huxi()
    end
end

function PlayerView:bianse()
end



function PlayerView:add_xiazhangData(cards)
    if not self.xiazhangList then
        self.xiazhangList = {}
    end

    table.insert(self.xiazhangList, cards)
    if not self.huxi then
        self.huxi = 0
    end
    self.huxi = self.huxi + cards.hu_shu

    local x = (#self.xiazhangList - 1) * XIA_ZHANG_OFFSET[self.seatIndex]
    ---@type UnityEngine.GameObject
    local xia_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, self.holder.xia_zhang, Vector3.New(x, 0, 0))


    local count = #cards.pai + 1

    for i = 1, 8 do
        local obj = Manager.FindObject(xia_zhang, tostring(i))
        local zheGePai = cards.pai[count -i]
        if zheGePai then
            local status = nil
            if DataHuaPai.Msg_Table_GameStateNTF.result == 0 then
                status = cards.is_kua_kan
            end
            GRAYYanse = GRAYYanse or Color.New(0.8, 0.8, 0.8, 1)
         
            if cards.is_kua_kan == 1 then
                TableUtilPaoHuZi.set_card(obj, zheGePai.pai, GRAYYanse, "ZiPai_PlayCards", status)
            else
                TableUtilPaoHuZi.set_card(obj, zheGePai.pai, nil, "ZiPai_PlayCards", status)
            end

            --ZiPai_CurPutCards  ZiPai_HandCards
            obj:SetActive(true)

            if #cards.pai >= 5 and i > 1 then
                local pos = obj.transform.localPosition
                pos.y = pos.y - 20 * (i - 1)
                obj.transform.localPosition = pos
            end
        else
            obj:SetActive(false)
        end
    end

    -- 如果是6张的情况 则除了第一张外  每一张 都往上移动 
   
    xia_zhang.transform.localScale = V3_ZERO
    xia_zhang:SetActive(true)

    return xia_zhang
end

---添加下张
---@param cards table
function PlayerView:add_xiazhang(cards)
    if not self.xiazhangList then
        self.xiazhangList = {}
    end

    table.insert(self.xiazhangList, cards)
    if not self.huxi then
        self.huxi = 0
    end
    self.huxi = self.huxi + cards.hu_shu

    local x = (#self.xiazhangList - 1) * XIA_ZHANG_OFFSET[self.seatIndex]
    ---@type UnityEngine.GameObject
    local xia_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, self.holder.xia_zhang, Vector3.New(x, 0, 0))
    ---@type UnityEngine.GameObject
    local pinzhang = TableUtilPaoHuZi.clone(self.clone.pinzhang, self.holder.pinzhang, V3_ZERO)
    self.holder.pinzhang.transform.localScale = V3_ZERO
    self.holder.pinzhang.transform.localPosition = V3_ZERO

    local count = #cards.pai + 1

    
    for i = 1, 4 do

        local obj = Manager.FindObject(xia_zhang, tostring(i))
        local pinObj = Manager.FindObject(pinzhang, tostring(i))
        if cards.pai[count -i] then
            local status = nil
            if DataHuaPai.Msg_Table_GameStateNTF.result == 0 then
                status = cards.is_kua_kan
            end
            GRAYYanse = GRAYYanse or Color.New(0.8, 0.8, 0.8, 1)

            if cards.is_kua_kan then
                TableUtilPaoHuZi.set_card(obj, cards.pai[count -i].pai, GRAYYanse, "ZiPai_PlayCards", status)
            else
                TableUtilPaoHuZi.set_card(obj, cards.pai[count -i].pai, nil, "ZiPai_PlayCards", status)
            end
            --ZiPai_CurPutCards  ZiPai_HandCards
            obj:SetActive(true)

            TableUtilPaoHuZi.set_card(pinObj, cards.pai[count -i].pai, nil, "ZiPai_CurPutCards")
            pinObj:SetActive(true)

        else
            obj:SetActive(false)
            pinObj:SetActive(false)
        end
    end
    xia_zhang.transform.localScale = V3_ZERO
    xia_zhang:SetActive(true)

    return xia_zhang
end



--- 添加手张
function PlayerView:add_shouzhang(data)
    Manager.DestroyChildren(self.holder.shou_zhang)

    local result = DataHuaPai.Msg_Table_GameStateNTF.result

    if self.seatIndex ~= 1 or (self.seatIndex == 1 and result == 1 and not curTableData.isPlayBack) then
        local shouzhangList = {}
        
        for i = 1, #data.shou_zhang do
            table.insert(shouzhangList, data.shou_zhang[i])
        end

        local startX = 0
        if not curTableData.isPlayBack and self.xiazhangList then
            --startX = #self.xiazhangList * XIA_ZHANG_OFFSET[self.seatIndex] + SHOU_ZHANG_OFFSET[self.seatIndex] / 2
            startX = #self.xiazhangList * XIA_ZHANG_OFFSET[self.seatIndex]
        end
        for i = 1, #shouzhangList do
            local holder, x

            if curTableData.isPlayBack then
                holder = self.holder.shou_zhang
                x = startX + (i - 1) * SHOU_ZHANG_OFFSET[self.seatIndex]
            else
                holder = self.holder.xia_zhang
                x = startX + (i - 1) * XIA_ZHANG_OFFSET[self.seatIndex]
            end
            --local shou_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, self.holder.xia_zhang, Vector3.New(x, 15, 0))
            local shou_zhang = TableUtilPaoHuZi.clone(self.clone.xia_zhang, holder, Vector3.New(x, 0, 0))

            if curTableData.isPlayBack then
            --shou_zhang.transform.localScale = Vector3.New(1.18, 1.18, 1)
            end

            --local index = 0
            for j = 1, 4 do
                --index = index + 1
                local obj = Manager.FindObject(shou_zhang, tostring(j))
                if shouzhangList[i].pai[j] then
                    local color2 = nil

                    TableUtilPaoHuZi.set_card(obj, shouzhangList[i].pai[j].pai, color2, "ZiPai_PlayCards")
                    Manager.SetActive(obj, true)
                else
                    Manager.SetActive(obj, false)
                end
            end
        end
    end
end

---显示要牌特效
---@param index number
function PlayerView:show_chutx(actionID)
    

   
    if not self.chutx then
        self.chutx = Manager.CopyObject(self.clone.chutx, self.holder.chutx)
        self.chutxImg1 = Manager.GetImage(self.chutx, "Animator/WenBen")
        self.chutxImg2 = Manager.GetImage(self.chutx, "Animator/GaoLiang")
        self.chutxImg3 = Manager.GetImage(self.chutx, "Animator/DiBu")
        self.chutxSpriteHolder = Manager.GetComponent(self.chutx, "SpriteHolder")
    end
    local sprite = self.chutxSpriteHolder:FindSpriteByName(tostring(actionID))

    self.chutxImg1.sprite = sprite
    self.chutxImg2.sprite = sprite
    self.chutxImg1:SetNativeSize()
    self.chutxImg2:SetNativeSize()
    self.chutxImg3:SetNativeSize()
    self.chutx:SetActive(false)
    self.chutx:SetActive(true)


end

--- 判断是否有动作ID
function PlayerView:has_actionWhat(id)
    local data = DataHuaPai.Msg_Table_GameStateNTF

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

--- 播放短 语
function PlayerView:play_shot_voice(index)
    if self.module.view.openVoice then
        TableUtilPaoHuZi.print("播放短语    ", index)
        SoundManager:play_shot_voice(index, self.man)
    end
end

--- 显示聊天文字
function PlayerView:show_chat_bubble(text)
    Manager.SetActive(self.seat.objBubble, true)
    self.seat.textRight.text = text
    self.seat.textLeft.text = text
    Manager.SetActive(self.seat.textRight.gameObject, self.seatIndex == 2)
    Manager.SetActive(self.seat.textLeft.gameObject, self.seatIndex ~= 2)
    self.view.transform:SetAsLastSibling()
    self:insert_callback(
        3,
        function()
            self.view.transform:SetSiblingIndex(self.siblingIndex)
            Manager.SetActive(self.seat.objBubble, false)
            Manager.SetActive(self.seat.textRight.gameObject, false)
            Manager.SetActive(self.seat.textLeft.gameObject, false)
        end
    )
end

--- 显示聊天表情
function PlayerView:show_chat_face(index)
    if not self.seat.face[index] then
        return
    end

    self.selfFaceList = self.selfFaceList or {}
    table.insert(self.selfFaceList, index)

    self.XunHuanFace_coroutine =
        self.XunHuanFace_coroutine or
        self.module:start_lua_coroutine(
            function()
                while true do
                    if #self.selfFaceList > 0 then
                        local dex = self.selfFaceList[1]
                        table.remove(self.selfFaceList, 1)

                        Manager.SetActive(self.seat.objFace, true)
                        Manager.SetActive(self.seat.face[dex], true)

                        coroutine.wait(3)

                        Manager.SetActive(self.seat.objFace, false)
                        Manager.SetActive(self.seat.face[dex], false)
                    end
                    coroutine.wait(0.05)
                end
            end
        )
end

--- 显示语音
function PlayerView:show_voice(show)
    Manager.SetActive(self.seat.speak, show)
end

function PlayerView:insert_callback(t, callback)
    local seq = self.module.view:create_sequence()
    seq:InsertCallback(
        t,
        function()
            if callback then
                callback()
            end
        end
    )
    seq:SetAutoKill(true)
    seq:Play()
end

return PlayerView
