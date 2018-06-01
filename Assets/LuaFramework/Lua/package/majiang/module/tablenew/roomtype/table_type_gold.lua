
--- 麻将模式(正常 比赛场 快速组局 金币场)
local class = require("lib.middleclass")
local Base = require('package.majiang.module.tablenew.roomtype.table_type_common')
---@class TableTypeGold:TableTypeCommon
---@field view TableCommonView
local TableTypeGold = class('tableTypeGold', Base)
local ModuleCache = ModuleCache
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local ComponentTypeName = ModuleCache.ComponentTypeName
local Vector3 = Vector3
local ModuleCache = ModuleCache
local Util = Util

function TableTypeGold:on_initialize()
    ---金币场相关控件
    self.goldModeTopLeft = GetComponentWithPath(self.root, "TopLeft/Child/GoldMode", ComponentTypeName.Transform).gameObject
    self.gEixtBtn = GetComponentWithPath(self.root, "TopLeft/Child/GoldMode/GEixtBtn", ComponentTypeName.Transform).gameObject
    self.gRuleBtn = GetComponentWithPath(self.root, "TopLeft/Child/GoldMode/GRuleBtn", ComponentTypeName.Transform).gameObject
    self.gChangeBtn = GetComponentWithPath(self.root, "Bottom/Child/InviteAndExit/ButtonChange", ComponentTypeName.Transform).gameObject
    self.changeInvalidTag = GetComponentWithPath(self.root, "Bottom/Child/InviteAndExit/ButtonChange/ChangeInvalidTag", ComponentTypeName.Transform).gameObject
    self.dizhuObj = GetComponentWithPath(self.view.gameController, "DiZhu", ComponentTypeName.Transform).gameObject
    self.dizhuTxet = GetComponentWithPath(self.view.gameController, "DiZhu/Text", ComponentTypeName.Text)
    self.noIntrustbtn =  GetComponentWithPath(self.root, "Bottom1/Child/ButtonNoIntrust", ComponentTypeName.Transform).gameObject
    self.coinMatchCountdownObj =  GetComponentWithPath(self.root,"Center/Child/CoinMatchCountdown", ComponentTypeName.Transform).gameObject
    self.coinMatchCountdownTextWrap=  GetComponentWithPath(self.root,"Center/Child/CoinMatchCountdown/Image/Image",  "TextWrap")
    self.addGold = GetComponentWithPath(self.root, "Left/Child/ButtonAddGold", ComponentTypeName.Transform).gameObject
    self.changeInvalidTag:SetActive(false)
    self.view.jushuObj:SetActive(false)
    self.dizhuObj:SetActive(true)
    self.gChangeBtn:SetActive(false)
    self.view.buttonMic.gameObject:SetActive(false)
end

function TableTypeGold:can_kick(seatID, seatHolder)
    return false
end

function TableTypeGold:show_me_ready()
    self.view.buttonInvite:SetActive(false)
    self.view.buttonExit:SetActive(false)
    --self.gChangeBtn:SetActive(false)
    self.gChangeBtn.transform.anchoredPosition = Vector3.New(0, self.gChangeBtn.transform.anchoredPosition.y, 0)
end

function TableTypeGold:show_me_not_ready(readyData)
    self.view.buttonInvite:SetActive(false)
    self.view.buttonExit:SetActive(false)
    --self.gChangeBtn:SetActive(true)
    --self.gChangeBtn.transform.anchoredPosition = Vector3.New(-200, self.view.buttonBegin.transform.anchoredPosition.y, 0)
    --self.view.buttonBegin.transform.anchoredPosition = Vector3.New(200, self.view.buttonBegin.transform.anchoredPosition.y, 0)
    if(readyData.RestTime and readyData.RestTime > 0) then
        self.view:show_ready_time_down(readyData.RestTime)
    end
end

--- 所有人都准备的显示
function TableTypeGold:update_ready_end(allReady)
    self.goldModeTopLeft:SetActive(false)
    self.view.beginTopLeft:SetActive(false)
    self.view.readyTopLeft:SetActive(false)

    for i=1,#self.view.seatHolderArray do
        ---@types SeatHolder2D
        local seatHolder = self.view.seatHolderArray[i]
        seatHolder:show_ready(false)
    end
end

--- 显示局数
function TableTypeGold:show_round(gameState)
    self.dizhuTxet.text = "底分:"..tostring(gameState.BaseCoinScore)
    if gameState.FeeNum and 0 ~= gameState.FeeNum then
        local text = "本局服务费"..gameState.FeeNum.."金币"
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(text)
    end
end

--- 显示分数
function TableTypeGold:show_score(playerState, localSeat, serverSeat)
    local gameState = self.view.gameState
    ---@type SeatHolder2D
    local seatHolder = self.view.seatHolderArray[localSeat]
    seatHolder:show_gold_balance(Util.filterPlayerGoldNum(playerState.Balance)) ---金币场剩余金币
    if(gameState.ScoreSettle) then
        for i=1,#gameState.ScoreSettle do
            local scoresettle = gameState.ScoreSettle[i]
            if scoresettle.SeatID == seatHolder.serverSeat then
                seatHolder:play_score_change_text(scoresettle.ActualAmount)
                break
            end
        end
    end
end

--- 显示托管
function TableTypeGold:show_instrust(playerState, localSeat)
    local gameState = self.view.gameState
    if(self.view:is_me(localSeat)) then
        self.noIntrustbtn:SetActive(playerState.IntrustState == 1)
        if #gameState.MaiMa > 0 then
            self.noIntrustbtn:SetActive(false) ---买马不显示取消托管按钮
        end
    end
end

---开始设置玩家状态（gameState）
function TableTypeGold:game_state_begin_set_player_state(playerState, localSeat, serverSeat)
    self:show_score(playerState, localSeat, serverSeat)
    self:show_instrust(playerState, localSeat)
end

--- 显示准备时的错误信息
function TableTypeGold:show_ready_error(data)
    if data.ErrCode == -888 then
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("您的金币不足，是否立即补充金币继续游戏？", function()
            ModuleCache.ModuleManager.show_module("public", "goldadd")
        end, nil, true, "确 认", "取 消")
    else
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrInfo)
    end
end

--- 玩家离开座位
function TableTypeGold:player_leave_seat(seatHolder)
    if(not self.view.gameState) then
        seatHolder:show_gold_balance()
    end
end

--- 玩家在座位上
function TableTypeGold:player_on_seat(seatHolder, data)
    if(not self.view.gameState) then
        seatHolder:set_score("")
        seatHolder:show_gold_balance(Util.filterPlayerGoldNum(data.Balance))
    end
end

--- 游戏未开始时（整个牌局） --- 此时不是所有玩家都准备了
function TableTypeGold:set_game_not_begin_ui(seatHolder)
    seatHolder:set_game_begin_ui()
end

---显示牌桌预览相关操作控件
function TableTypeGold:show_table_presettlement(show)
    self.view.preButtonChange:SetActive(false)
    self.view.preButtonBegin:SetActive(true)
    self.view.buttonBackToSettle:SetActive(false)
    self.view.buttonContinue:SetActive(false)
    self.view.preSettlementObj:SetActive(show)
end

---当牌桌右侧菜单状态变化时
function TableTypeGold:on_right_menu_state_change(state)
    Base.on_right_menu_state_change(self,state)
    self.view.rbuttonExit.gameObject:SetActive(true)
    self.view.rbuttonExitText.text = "退出"
end

---进入拦牌状态
function TableTypeGold:on_game_state_wait_action()
    Base.on_game_state_wait_action(self)
    self.view.timeDown:SetActive(true)
    self.view.waitObj:SetActive(false)
    self.view.playType:show_time_down()
end

return  TableTypeGold