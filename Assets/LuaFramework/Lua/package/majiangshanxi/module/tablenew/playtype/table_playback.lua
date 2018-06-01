
--- 正常和回放模式
local class = require("lib.middleclass")
local Base = require('package.majiangshanxi.module.tablenew.playtype.table_custom')
---@class TablePlayBack:TableCustom
---@field view TableCommonView
local TablePlayBack = class('tablePlayBack', Base)

function TablePlayBack:on_initialize()
    self.view.textWanFa.text = self.view.wanfaName
    if self.curTableData.videoData.roomid or self.curTableData.videoData.hallnum then
        if(self.curTableData.videoData.hallnum and self.curTableData.videoData.hallnum > 0) then
            self.view.textRoomNum1.text = AppData.MuseumName .."房号:" ..  self.curTableData.videoData.roomid
        else
            self.view.textRoomNum1.text = "房号:" ..  self.curTableData.videoData.roomid
        end
    end
    self.view.topRightObj:SetActive(false)
    self.view.buttonSetting.gameObject:SetActive(false)
    self.view.bottomRightObj:SetActive(false)
    self.view.jushuObj:SetActive(false)
    self.view.inviteAndExit:SetActive(false)
    if(self.view.ruleJsonInfo.isPrivateRoom) then
        self.view.textWanFa.text = self.view.wanfaName .. " 私人房"
    end
end

function TablePlayBack:on_init()

end

--- 显示局数
function TablePlayBack:show_round(gameState)

end

--- 显示倒计时
function TablePlayBack:show_time_down()
    self.view:show_time_down(0)
end

return  TablePlayBack