
local class = require("lib.middleclass")
local TableDouNiuLogic = require("package/cowboy/module/table/table_douniu_logic")
--- @class TableDouNiuLogic_OneByOne:TableDouNiuLogic
---@field tableModule CowBoy_TableModule
---@field tableModel CowBoy_TableModel
---@field tableHelper CowBoy_TableHelper
---@field tableView CowBoy_TableView
local TableDouNiuLogic_OneByOne = class('tableDouNiuLogic_OneByOne', TableDouNiuLogic)
local CSmartTimer = ModuleCache.SmartTimer.instance

function TableDouNiuLogic_OneByOne :initialize(...)
	TableDouNiuLogic.initialize(self, ...)	
end

--设置庄家通知
function TableDouNiuLogic_OneByOne:on_table_setbanker_notify(data)
	TableDouNiuLogic.on_table_setbanker_notify(self, data)
	local seatInfoList = self.modelData.curTableData.roomInfo.seatInfoList
	for i=1,#seatInfoList do
		----print(seatInfoList[i].playerId, seatInfoList[i].isBanker)
		if(seatInfoList[i].isBanker)then
			seatInfoList[i].isBetting = false
		else
			seatInfoList[i].isBetting = true
		end
		self.tableView:refreshSeatState(seatInfoList[i])		
	end
end

return TableDouNiuLogic_OneByOne