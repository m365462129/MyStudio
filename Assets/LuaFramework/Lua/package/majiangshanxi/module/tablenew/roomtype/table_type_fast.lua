
--- 麻将模式(正常 比赛场 快速组局 金币场)
local class = require("lib.middleclass")
local Base = require('package.majiangshanxi.module.tablenew.roomtype.table_type_common')
---@class TableTypeFast:TableTypeCommon
---@field view TableCommonView
local TableTypeFast = class('tableTypeFast', Base)

function TableTypeFast:show_report_kick(seatHolder)
    if not self.view:all_is_ready() and not self.gameState then
        --快速组局 牌局没开始前 如果有玩家离线 显示踢人按钮
        seatHolder.buttonKick:SetActive(seatHolder.imageDisconnect.activeSelf)
    end
end

function TableTypeFast:can_kick(seatID, seatHolder)
    return not self.view:all_is_ready() and seatHolder.imageDisconnect.activeSelf
end

return  TableTypeFast