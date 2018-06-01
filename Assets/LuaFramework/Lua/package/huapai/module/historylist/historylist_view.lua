-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local HistoryListView = Class('historyListView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

function HistoryListView:initialize(...)
    -- 初始View
    View.initialize(self, "huapai/module/historylist/paohuzi_windowhistorylist.prefab", "PaoHuZi_WindowHistoryList", 0)


    self.buttonClose = GetComponentWithPath(self.root, "TopLeft/Child/ImageBack", ComponentTypeName.Button)
    self.buttonCheckRoundVideo = GetComponentWithPath(self.root, "TopRight/Child/LookMatch", ComponentTypeName.Button)
    -- 空数据背景实体
    self.spriteEmptyGB = GetComponentWithPath(self.root, "Top/SpriteEmpty", ComponentTypeName.Transform).gameObject;

    self.content = GetComponentWithPath(self.root, "Top/Panels/ListScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject
    self.cloneObj = GetComponentWithPath(self.root, "Top/Panels/ItemPrefabHolder/HistoryItem", ComponentTypeName.Transform).gameObject
end

function HistoryListView:on_view_init()

end

function HistoryListView:get_data(obj)
    return self.history[tonumber(obj.name)]
end

function HistoryListView:initLoopScrollViewList(historyList)

    -- 空数据,显示空数据背景
    if #historyList == 0 then
        self.spriteEmptyGB:SetActive(true);
    else
        self.spriteEmptyGB:SetActive(false);
    end

    print(#historyList)

    self.history = historyList
    self.contents = TableUtilPaoHuZi.get_all_child(self.content)
    self:reset()
    for i = 1, #historyList do

        print('我笑死')
        local obj = nil
        local item = { }
        if (i <= #self.contents) then
            obj = self.contents[i]
        else
            obj = TableUtilPaoHuZi.clone(self.cloneObj, self.content, Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)
        item.gameObject = obj
        item.data = historyList[i]
        self:fillItem(item, i)
    end
end

function HistoryListView:reset()
    for i = 1, #self.contents do
        ComponentUtil.SafeSetActive(self.contents[i], false)
    end
end

function HistoryListView:fillItem(item)
    local data = item.data
    local textRoomNum = GetComponentWithPath(item.gameObject, "Title/RoomNameLbl", ComponentTypeName.Text)
    local textTime = GetComponentWithPath(item.gameObject, "Title/TimeLbl", ComponentTypeName.Text)

    textRoomNum.text = "房号：" .. data.roomNumber
    textTime.text = data.createTime
    -- os.date("%Y-%m-%d   %H:%M", data.time)

    local redAtlas = GetComponentWithPath(item.gameObject, "RedNumbersHolder", "SpriteAtlas")
    local greenAtlas = GetComponentWithPath(item.gameObject, "GreenNumbersHolder", "SpriteAtlas")

    -- -- 名字重新排序
    for i = 1, #data.players do
        if data.players[i].userId == tonumber(self.modelData.roleData.userID) then
            local temp = data.players[1]
            data.players[1] = data.players[i]
            data.players[i] = temp
        end
    end


    for i = 1, 4 do
        local playerGo = GetComponentWithPath(item.gameObject, "Players/player" .. i, ComponentTypeName.Transform).gameObject
        if (i <= #data.players) then
            ComponentUtil.SafeSetActive(playerGo, true)
            local textPlayerName = GetComponentWithPath(playerGo, "nameLbl", ComponentTypeName.Text)
            local textWrapRedScore = GetComponentWithPath(playerGo, "redScore", "TextWrap")
            local fangzhu = GetComponentWithPath(playerGo, "Image", ComponentTypeName.Transform).gameObject
            -- 玩家头像
            local spritePlayerIcon = GetComponentWithPath(playerGo, "Mask/SpritePlayerIcon", ComponentTypeName.Image);

            local onDownLoadIcon = function(sprite)

                if sprite ~= nil then
                    -- 玩家头像
                    spritePlayerIcon.sprite = sprite;
                end
            end
            -- 下载头像
            self:startDownLoadHeadIcon(spritePlayerIcon, data.players[i].headImg, onDownLoadIcon);

            if data.players[i].playerScore >= 0 then
                textWrapRedScore.atlas = redAtlas
            else
                textWrapRedScore.atlas = greenAtlas or redAtlas
            end

            if fangzhu then
                fangzhu:SetActive(data.creatorId and data.creatorId == data.players[i].userId)
            end

            textPlayerName.text = Util.filterPlayerName(data.players[i].playerName, 10)
            if tonumber(data.players[i].userId) == tonumber(self.modelData.roleData.userID) then
                textPlayerName.color = Color.New(177 / 255, 58 / 255, 31 / 255, 1)
            end
            if (data.players[i].playerScore > 0) then
                textWrapRedScore.text = "+" .. data.players[i].playerScore


                if AppData.Game_Name == 'LDZP' or AppData.Game_Name == 'XXZP' then
                    textWrapRedScore.text = "+" .. data.players[i].playerScore/1000
                end


            else
                textWrapRedScore.text = data.players[i].playerScore

                if AppData.Game_Name == 'LDZP' or AppData.Game_Name == 'XXZP' then
                    textWrapRedScore.text = data.players[i].playerScore/1000
                end
            end
        else
            ComponentUtil.SafeSetActive(playerGo, false)
        end
    end
end

-- 下载头像
function HistoryListView:startDownLoadHeadIcon(targetImage, url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if (self) then
                    -- self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if (callback) then
                callback(tex)
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end )
end



return HistoryListView