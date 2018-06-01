-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local HistoryListView = Class('historyListView', View)
local ModuleCache = ModuleCache

-- local xstr = require("lib.xstr")

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function HistoryListView:initialize(...)
    -- 初始View
    View.initialize(self, "cowboy/module/historylist/cowboy_windowhistorylist.prefab", "CowBoy_WindowHistoryList", 1)


    self.buttonClose = GetComponentWithPath(self.root, "Title/closeBtn", ComponentTypeName.Button)
    self.buttonCheckRoundVideo = GetComponentWithPath(self.root, "Title/checkVideoBtn", ComponentTypeName.Button)
    -- 空数据背景实体
    self.spriteEmptyGB = GetComponentWithPath(self.root, "BaseBackground/SpriteEmpty", ComponentTypeName.Transform).gameObject;
    self.loopScrollView = GetComponentWithPath(self.root, "Center/Panels/ListScrollView", "LoopScrollView")
    self.loopScrollView.OnDataChange:AddListener( function(item)
        self:fillItem(item)
    end )
    self.loopScrollView.onValueChanged:AddListener( function(value)
        self.lastScrollValue = value.y
    end )
end


function HistoryListView:on_view_init()

end

function HistoryListView:initLoopScrollViewList(historyList, indexPos)
    indexPos = indexPos or 0

    -- 空数据,显示空数据背景
    if #historyList == 0 then
        self.spriteEmptyGB:SetActive(true);
    else
        self.spriteEmptyGB:SetActive(false);
    end
    self.loopScrollView:SetData(historyList, indexPos)
end

function HistoryListView:fillItem(item)
    local data = item.data
    local textRoomNum = GetComponentWithPath(item.gameObject, "Title/RoomNameLbl", ComponentTypeName.Text)
    local textTime = GetComponentWithPath(item.gameObject, "Title/TimeLbl", ComponentTypeName.Text)
    textRoomNum.text = "房号:" .. data.roomNumber

    textTime.text = data.createTime
    -- os.date("%Y-%m-%d   %H:%M", data.time)

    --自己排在最前面
    for i=1,#data.players do
        if data.players[i].userId == tonumber(self.modelData.roleData.userID) then
            local temp = data.players[1]
             data.players[1] =data.players[i]
             data.players[i] = temp
        end
    end

    for i = 1, 6 do
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject
        if (#data.players < i) then
            ModuleCache.ComponentUtil.SafeSetActive(playerGo, false)
        else
            ModuleCache.ComponentUtil.SafeSetActive(playerGo, true)
            local textPlayerName = GetComponentWithPath(playerGo, "nameLbl", ComponentTypeName.Text)
            local textWrapGreenScore = GetComponentWithPath(playerGo, "greenScore", "TextWrap")
            local textWrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")

            -- 房主图标
            local spriteRoomCreator = GetComponentWithPath(playerGo, "SpriteRoomCreator", ComponentTypeName.Image)
            local playerData = data.players[i]

            local isShowRoomCreator = false;
            if tonumber(playerData.userId) == tonumber(data.creatorId) then
                isShowRoomCreator = true;
            end
            spriteRoomCreator.gameObject:SetActive(isShowRoomCreator);

            -- 过滤玩家名字
            local filterPlayerName = Util.filterPlayerName(playerData.playerName, 10);
            if (i == 1) then
                textPlayerName.text = filterPlayerName
            else
                textPlayerName.text = "<color=#7F5F54>" .. filterPlayerName .. "</color>"
            end
            if (playerData.playerScore < 0) then
                ModuleCache.ComponentUtil.SafeSetActive(textWrapGreenScore.gameObject, true)
                ModuleCache.ComponentUtil.SafeSetActive(textWrapRedScore.gameObject, false)
                textWrapGreenScore.text = "" .. playerData.playerScore
            else
                ModuleCache.ComponentUtil.SafeSetActive(textWrapGreenScore.gameObject, false)
                ModuleCache.ComponentUtil.SafeSetActive(textWrapRedScore.gameObject, true)
                textWrapRedScore.text = "+" .. playerData.playerScore
            end
        end


    end
end


return HistoryListView