
--- 宿松麻将
local class = require("lib.middleclass")
local Base = require('package.majiangshanxi.module.tablenew.view.tablecommon_view')
---@class TableSuSongView:TableCommonView
local TableSuSongView = class('tableSuSongView', Base)
local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local TableUtil = TableUtil

function TableSuSongView:init_ui()
    Base.init_ui(self)
    self.selectZun = GetComponentWithPath(self.root, "Bottom/Child/SelectZun", ComponentTypeName.Transform).gameObject
    self.selectZunChilds = TableUtil.get_all_child(self.selectZun)
end

--- 初始化单个座位
function TableSuSongView:init_seat(seatHolder, index)
    seatHolder.waitZun = GetComponentWithPath(seatHolder.seatRoot, "Info/TextWaitZun", ComponentTypeName.Text)
end

--- 开始刷新gameState
function TableSuSongView:game_state_begin(gameState)
    Base.game_state_begin(self, gameState)
    self.selectZun:SetActive(false)
end

function TableSuSongView:show_table_pop(userState, i)
    Base.show_table_pop(self, userState, i)
    local state = userState.State[i]
    if(self:is_me(nil, state.SeatID) and state.PiaoType == 1) then
        local zunCount = 0
        if(self.gameState) then
            zunCount = self.gameState.zunnum
        end
        if(zunCount < 5) then
            self.selectZun:SetActive(true)
            for i=1,6 do
                self.selectZunChilds[i + 6]:SetActive(i - 1 < zunCount)
                self.selectZunChilds[i]:SetActive(not (i - 1 < zunCount))
            end
        end
    end
end

--- 隐藏牌桌额外弹窗（选跑漂等）
function TableSuSongView:hide_table_pop()
    Base.hide_table_pop(self)
    self.selectZun:SetActive(false)
end

--- 别个已经准备的显示
function TableSuSongView:show_other_ready(localSeat, seatData)
    local allReady = self:all_is_ready()
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder.waitZun.gameObject:SetActive(allReady and seatData.PiaoType == 1)
end

return  TableSuSongView