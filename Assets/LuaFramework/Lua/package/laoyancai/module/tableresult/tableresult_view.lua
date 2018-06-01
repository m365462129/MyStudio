-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableResultView = Class('tableResultView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function TableResultView:initialize(...)
    -- 初始View
    View.initialize(self, "laoyancai/module/tableresult/laoyancai_windowtableresult.prefab", "LaoYanCai_WindowTableResult", 1)

    

    self.buttonBack = GetComponentWithPath(self.root, "Center/Buttons/ButtonBack", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Center/Buttons/ButtonShare", ComponentTypeName.Button)
    self.buttonOnceMore = GetComponentWithPath(self.root, "Center/Buttons/ButtonOnceMore", ComponentTypeName.Button)

    self.textRoomNum = GetComponentWithPath(self.root, "Title/TextRoomNum", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Title/TimeNum", ComponentTypeName.Text)
    self.textHallNum = GetComponentWithPath(self.root, "Title/HallNum", ComponentTypeName.Text)

    self.goPlayersRoot = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content", ComponentTypeName.Transform).gameObject


    
end

function TableResultView:on_view_init()
     
end

function TableResultView:refreshRoomInfo(roomNum,name,curRoundNum,totalRoundNum,startTime,endTime)
    self.textRoomNum.text = "房号:"..roomNum.."  ".."云南捞腌菜".."  第"..curRoundNum.."/"..totalRoundNum.."局";
    self.textTime.text = "开始 "..startTime.."\n结束 "..endTime
   
    --self.textHallNum.gameObject:SetActive(self.modelData.roleData.HallID > 0)
    --if(self.modelData.roleData.HallID > 0) then
        --self.textHallNum.text = "圈号:"..self.modelData.roleData.HallID
    --end
end


function TableResultView:getPlayerInfo(playerId, textName, imageHead, textUID)

end

return TableResultView