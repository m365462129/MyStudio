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
    View.initialize(self, "biji/module/tableresult/biji_windowtableresult.prefab", "BiJi_WindowTableResult", 1)

    

    self.buttonBack = GetComponentWithPath(self.root, "Center/Buttons/ButtonBack", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Center/Buttons/ButtonShare", ComponentTypeName.Button)
    self.buttonOnceMore = GetComponentWithPath(self.root, "Center/Buttons/ButtonOnceMore", ComponentTypeName.Button)

    self.textRoomNum = GetComponentWithPath(self.root, "Title/TextRoomNum", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Title/TimeNum", ComponentTypeName.Text)
    self.textHallNum = GetComponentWithPath(self.root, "Title/HallNum", ComponentTypeName.Text)

    self.goPlayersRoot = GetComponentWithPath(self.root, "Center/Players", ComponentTypeName.Transform).gameObject

    self.btnSelectText = GetComponentWithPath(self.root, "Center/Buttons/SelectTextShare/SelectTextBtn", ComponentTypeName.Button)
    self.selectTextGou = GetComponentWithPath(self.root, "Center/Buttons/SelectTextShare/SelectTextGou", ComponentTypeName.Transform).gameObject
    self.btnSelectShareObj  = GetComponentWithPath(self.root, "Center/Buttons/SelectTextShare", ComponentTypeName.Transform).gameObject
    
end

function TableResultView:on_view_init()
     
end

function TableResultView:refreshRoomInfo(roomNum,name,curRoundNum,totalRoundNum,startTime,endTime)
    self.textRoomNum.text = "房号:"..roomNum.."  "..name.."  第"..curRoundNum.."/"..totalRoundNum.."局";
    self.textTime.text = "开始 "..startTime.."\n结束 "..endTime
   
    self.textHallNum.gameObject:SetActive(self.modelData.roleData.HallID > 0)
    if(self.modelData.roleData.HallID > 0) then
        self.textHallNum.text = "圈号:"..self.modelData.roleData.HallID
    end
end

--显示选中文字分享
function TableResultView:showShareText(isShareText)
    self.selectTextGou:SetActive(isShareText)
end


function TableResultView:getPlayerInfo(playerId, textName, imageHead, textUID)

end

return TableResultView