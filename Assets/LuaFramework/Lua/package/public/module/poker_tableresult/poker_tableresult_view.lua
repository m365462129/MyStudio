-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableResultView = Class('tableResultView', View)
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function TableResultView:initialize(...)
    View.initialize(self, "publictable/module/tableresult/public_windowtableresult.prefab", "Public_WindowTableResult", 1)
    self.buttonBack = GetComponentWithPath(self.root, "Center/Buttons/ButtonBack", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Center/Buttons/ButtonShare", ComponentTypeName.Button)
    self.textRoomInfo = GetComponentWithPath(self.root, "Title/TextRoomInfo", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Title/TimeNum", ComponentTypeName.Text)
    self.goPlayersRoot = GetComponentWithPath(self.root, "Center/Players", ComponentTypeName.Transform).gameObject
    self.prefabItem = GetComponentWithPath(self.root, "Holder/Item", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.prefabItem,false)
end

function TableResultView:on_view_init()
end

function TableResultView:refreshRoomInfo(roomNum, roomDesc, timestamp, curRound, totalRound)
    self.roomNum = roomNum
    self.textRoomInfo.text = string.format( "房号：%d %s 第%d/%d局", roomNum, roomDesc, curRound, totalRound)
    self.textTime.text = os.date("%Y-%m-%d  %H:%M", timestamp)
    self.endTime = timestamp
end

function TableResultView:init_view(playerResultList, maxScore)
    local count = #playerResultList    
    for i=1,count do
        local playerResult = playerResultList[i]
        local item = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabItem, self.goPlayersRoot)  
        item.name = "player" .. i         
        item:SetActive(true)
        if(maxScore > 0 and maxScore == playerResult.score)then
            playerResult.isWinner = true
        end
        self:fillItem(item, playerResult)
    end

    ModuleCache.ShareManager().share_room_result_text(self:get_result_share_data(playerResultList))
end

function TableResultView:fillItem(item, playerResult)
    local imageSelfBg = GetComponentWithPath(item, "bg/MyselfBg", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(imageSelfBg.gameObject, playerResult.isSelf or false)
    local textUid = GetComponentWithPath(item, "Role/ID/TextID", ComponentTypeName.Text)
    local textName = GetComponentWithPath(item, "Role/Name/TextName", ComponentTypeName.Text)
    local player = playerResult.player    
    textUid.text = "ID:" .. player.uid
    textName.text = Util.filterPlayerName(player.nickname) 
    local headImage = GetComponentWithPath(item, "Role/Avatar/Avatar/Image", ComponentTypeName.Image)
    GetComponentWithPath(item, "WinTimes/value", ComponentTypeName.Text).text = playerResult.win_cnt .. ""
    GetComponentWithPath(item, "LoseTimes/value", ComponentTypeName.Text).text = playerResult.lost_cnt .. ""

    if(playerResult.bomb_cnt)then
        local textBomb_cnt = GetComponentWithPath(item, "ZaDanTimes/value", ComponentTypeName.Text)
        textBomb_cnt.text = playerResult.bomb_cnt .. ""
    else
        local textBomb_cnt = GetComponentWithPath(item, "ZaDanTimes/value", ComponentTypeName.Text)
        ModuleCache.ComponentUtil.SafeSetActive(textBomb_cnt.gameObject, false)
    end
    

    local imageRoomCreator = GetComponentWithPath(item, "Role/ImageRoomCreator", ComponentTypeName.Image)
    local imageDissolver = GetComponentWithPath(item, "Role/dissolver", ComponentTypeName.Image)
    local imageWinner = GetComponentWithPath(item, "Role/ImageWinner", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(imageRoomCreator.gameObject, playerResult.isRoomCreator)
    ModuleCache.ComponentUtil.SafeSetActive(imageWinner.gameObject, playerResult.isWinner)
    ModuleCache.ComponentUtil.SafeSetActive(imageDissolver.gameObject, playerResult.isDissolver or false)

    if(playerResult.score >= 0)then
        GetComponentWithPath(item, "TotalScore/redScore", "TextWrap").text ="+" .. tostring(playerResult.score)
    else
        GetComponentWithPath(item, "TotalScore/greenScore", "TextWrap").text = tostring(playerResult.score)
    end
    if(player.headImg and player.headImg ~= "")then
        self:startDownLoadHeadIcon(headImage, player.headImg,function(headsprite)
            -- body
        end)
    end
end

function TableResultView:startDownLoadHeadIcon(targetImage, url,callback)    
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            --print('down load '.. url .. 'failed:' .. err)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if(self)then
                    --self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if(callback) then
                callback(tex)
            end
        end
    end)    
end

function TableResultView:getPlayerInfo(playerId, textName, imageHead, textUID)
end

function TableResultView:get_result_share_data(list)
    local resultData = {
        roomID = self.roomNum,
        hallID = self.modelData.roleData.HallID,
    }

    if(self.endTime)then
        resultData.endTime = os.date("%Y/%m/%d %H:%M:%S", self.endTime)
    end

    local playerDatas = {}
    local count = #list
    for i=1,count do
        local playerResult = list[i]
        local tmp = {
            playerResult.player.nickname,
            playerResult.score,
        }
        table.insert(playerDatas,tmp)
        if(playerResult.isDissolver)then
            resultData.dissRoomPlayName = playerResult.player.nickname
        end
    end
    resultData.playerDatas = playerDatas
    return resultData
end

return TableResultView