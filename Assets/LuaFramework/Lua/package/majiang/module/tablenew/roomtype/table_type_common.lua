
--- 麻将模式(正常 比赛场 快速组局 金币场)
local class = require("lib.middleclass")
---@class TableTypeCommon
---@field view TableCommonView
local TableTypeCommon = class('tableTypeCommon')
local Vector3 = Vector3
local ModuleCache = ModuleCache

function TableTypeCommon:initialize(view)
    self.view = view
    self.root = self.view.root
    self.curTableData = self.view.curTableData
    self:on_initialize()
end

function TableTypeCommon:on_initialize()
    self.view.beginImgObj:SetActive(true)
    self.view.beginCountDownObj:SetActive(false)
    self.view.jushuObj:SetActive(not self.view.curTableData.isPlayBack)
end

--- 显示踢人
function TableTypeCommon:show_report_kick(seatHolder)

end

--- 可以踢人
function TableTypeCommon:can_kick(seatID, seatHolder)
    return not self.view:all_is_ready() and seatID ~= 0 and self.view.mySeat == 0 and not self.view.gameState
end

--- 获取分享的数据
function TableTypeCommon:get_share_data(shareData)

end

--- 自己已经准备的显示
function TableTypeCommon:show_me_ready()
    --self.view.buttonInvite.transform.anchoredPosition = Vector3.New(-200, self.view.buttonInvite.transform.anchoredPosition.y, 0)
    --self.view.buttonExit.transform.anchoredPosition = Vector3.New(200, self.view.buttonExit.transform.anchoredPosition.y, 0)
end

--- 自己还没准备的显示
function TableTypeCommon:show_me_not_ready(readyData)
    --self.view.buttonInvite.transform.anchoredPosition = Vector3.New(-440, self.view.buttonInvite.transform.anchoredPosition.y, 0)
    --self.view.buttonExit.transform.anchoredPosition = Vector3.New(440, self.view.buttonExit.transform.anchoredPosition.y, 0)
end

--- 准备结束
function TableTypeCommon:update_ready_end(allReady)
    self.view.beginTopLeft:SetActive(allReady or self.view.gameState ~= nil)
    self.view.readyTopLeft:SetActive(not allReady and self.view.gameState == nil)
end

--- 显示局数
function TableTypeCommon:show_round(gameState)
    self.view.jushu.text = "第" .. gameState.CurRound .. "/" .. self.curTableData.RoundCount
    if(self.view.ConfigData.roundTitle and self.view.ruleJsonInfo.isDoubleQuan) then
        self.view.jushu.text = self.view.jushu.text .. self.view.ConfigData.roundTitle
    else
        self.view.jushu.text = self.view.jushu.text .. "局"
    end
end

--- 显示分数
function TableTypeCommon:show_score(playerState, localSeat, serverSeat)
    self.view:show_score(playerState, localSeat, serverSeat)
end

--- 开始刷新gameState
function TableTypeCommon:game_state_begin(gameState)

end

---开始设置玩家状态（gameState）
function TableTypeCommon:game_state_begin_set_player_state(playerState, localSeat, serverSeat)
    self:show_score(playerState, localSeat, serverSeat)
end

--- 显示准备时的错误信息
function TableTypeCommon:show_ready_error(data)
    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrInfo)
end

--- 玩家离开座位
function TableTypeCommon:player_leave_seat(seatHolder)

end

--- 玩家在座位上
function TableTypeCommon:player_on_seat(seatHolder, data)

end

--- 游戏未开始时（整个牌局） --- 此时不是所有玩家都准备了
function TableTypeCommon:set_game_not_begin_ui(seatHolder)

end

---显示牌桌预览相关操作控件
function TableTypeCommon:show_table_presettlement(show)
    self.view.preButtonChange:SetActive(false)
    self.view.preButtonBegin:SetActive(false)
    self.view.buttonBackToSettle:SetActive(true)
    self.view.buttonContinue:SetActive(true)
    if self.curTableData.needShowTotalResult then  ---如果是大结算
        self.view.buttonContinue:SetActive(false)
        self.view.buttonBackToSettle.transform.anchoredPosition =  Vector3.New(0, 92, 0)
    else
        self.view.buttonContinue:SetActive(true)
        self.view.buttonBackToSettle.transform.anchoredPosition =  Vector3.New(-200, 92, 0)
    end
end

---当牌桌右侧菜单状态变化时
function TableTypeCommon:on_right_menu_state_change(state)

end

---进入拦牌状态
function TableTypeCommon:on_game_state_wait_action()

end

return  TableTypeCommon