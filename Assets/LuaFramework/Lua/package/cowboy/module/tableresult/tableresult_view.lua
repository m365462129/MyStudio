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
    View.initialize(self, "cowboy/module/tableresult/cowboy_windowtableresult.prefab", "CowBoy_WindowTableResult", 1)

    

    self.buttonBack = GetComponentWithPath(self.root, "Center/Buttons/ButtonBack", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Center/Buttons/ButtonShare", ComponentTypeName.Button)
    self.uiStateSwitcher = GetComponentWithPath(self.root, "Center/Buttons", "UIStateSwitcher")

    self.textRoomNum = GetComponentWithPath(self.root, "Title/TextRoomNum", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Title/TimeNum", ComponentTypeName.Text)

    self.goPlayersRoot = GetComponentWithPath(self.root, "Center/Players", ComponentTypeName.Transform).gameObject
    self.prefabItem = GetComponentWithPath(self.root, "Holder/Item", ComponentTypeName.Transform).gameObject
    
    if(ModuleCache.GameManager.iosAppStoreIsCheck)then
        self.uiStateSwitcher:SwitchState("IosCheck")
    else
        self.uiStateSwitcher:SwitchState("Normal")
    end  

end

function TableResultView:on_view_init()
     
end

function TableResultView:refreshRoomInfo(roomNum, tableInfo, timestamp)
    self.roomNum = roomNum
     local roomName = "炸金牛"
    if(tableInfo.ruleTable.bankerType == 0)then
        roomName = "轮流坐庄"
    elseif(tableInfo.ruleTable.bankerType == 1)then
        roomName = "随机坐庄"
    elseif(tableInfo.ruleTable.bankerType== 2)then
        roomName = "看牌抢庄"
    end

    if(self:isGuangDong())then
        roomName = ""
        if tableInfo.ruleTable.bankerType == 0 then
            roomName = roomName .. "轮流坐庄 "
        elseif tableInfo.ruleTable.bankerType == 1 then
            roomName = roomName .. "随机坐庄 "
        elseif tableInfo.ruleTable.bankerType == 3 then
            roomName = roomName .. "牛九上庄 "
        elseif tableInfo.ruleTable.bankerType == 4 then
            roomName = roomName .. "牛牛上庄 "
        elseif tableInfo.ruleTable.bankerType == 5 then
            roomName = roomName .. "房主当庄 "
        elseif tableInfo.ruleTable.bankerType == 2 then
            roomName = ""
        elseif not tableInfo.ruleTable.bankerType then
            roomName = "通比拼十 "
        end

        if(tableInfo.ruleTable.kanPaiCount == 3)then
            roomName = '看三张抢庄 '
        elseif(tableInfo.ruleTable.kanPaiCount == 4)then
            roomName = '看四张抢庄 '
        elseif(tableInfo.ruleTable.kanPaiCount == 0)then
            roomName = '不看牌抢庄 '
        end
    end


    self.textRoomNum.text = string.format( "房号:%d %s 第%d/%d局", roomNum,roomName,tableInfo.curRoundNum,tableInfo.totalRoundCount) 
    self.textTime.text = "结束 "..os.date("%Y-%m-%d   %H:%M", timestamp)
    self.endTime = timestamp
end

function TableResultView:init_view(playerResultList, maxScore)
    local count = #playerResultList    
    for i=1,count do
        local playerResult = playerResultList[i]
        local item = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabItem, self.goPlayersRoot)  
        item.name = "player" .. i         
        print("itemname=".. item.name)
        item:SetActive(true)
        if(maxScore > 0 and maxScore == playerResult.totalScore)then
            playerResult.isWinner = true
        end
        self:fillItem(item, playerResult)
    end
    ModuleCache.ShareManager().share_room_result_text(self:get_result_share_data(playerResultList))
end

function TableResultView:fillItem(item, playerResult)
    local textUid = GetComponentWithPath(item, "Role/ID/TextID", ComponentTypeName.Text)
    local textName = GetComponentWithPath(item, "Role/Name/TextName", ComponentTypeName.Text)
    local player = playerResult.player    
    textUid.text = player.uid .. ""    
    textName.text = Util.filterPlayerName(player.nickname) 
    local headImage = GetComponentWithPath(item, "Role/Avatar/Avatar/Image", ComponentTypeName.Image)
    GetComponentWithPath(item, "DetailScore/WinTimes/value", ComponentTypeName.Text).text = playerResult.winTimes .. ""
    GetComponentWithPath(item, "DetailScore/LoseTimes/value", ComponentTypeName.Text).text = playerResult.loseTimes .. ""
    GetComponentWithPath(item, "DetailScore/HasNiuTimes/value", ComponentTypeName.Text).text = playerResult.hasNiuTimes .. ""
    GetComponentWithPath(item, "DetailScore/NoNiuTimes/value", ComponentTypeName.Text).text = playerResult.noNiuTimes .. ""

    local imageRoomCreator = GetComponentWithPath(item, "Role/ImageRoomCreator", ComponentTypeName.Image)
    local imageDissolver = GetComponentWithPath(item, "Role/dissolver", ComponentTypeName.Image)
    local imageWinner = GetComponentWithPath(item, "Role/ImageWinner", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(imageDissolver.gameObject, playerResult.isDissolver or false)
    ModuleCache.ComponentUtil.SafeSetActive(imageRoomCreator.gameObject, playerResult.isRoomCreator)
    ModuleCache.ComponentUtil.SafeSetActive(imageWinner.gameObject, playerResult.isWinner)

    if(playerResult.totalScore >= 0)then
        GetComponentWithPath(item, "TotalScore/redScore", "TextWrap").text =  "+" .. playerResult.totalScore .. ""
    else
        GetComponentWithPath(item, "TotalScore/greenScore", "TextWrap").text = playerResult.totalScore .. ""
    end
    if(player.headImg and player.headImg ~= "")then
        self:startDownLoadHeadIcon(player.headImg, headImage)
    end
end

function TableResultView:startDownLoadHeadIcon(url, image)    
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            --print('down load '.. url .. 'failed:' .. err.error)
            if not string.find(err.error, 'Couldn') then
                if(self)then
                    --self:startDownLoadHeadIcon(url, image)
                end
            end
            
        else
            -- ModuleCache.CustomerUtil.AttachTexture2Image(image, tex)
            image.sprite = tex
        end
    end)    
end

function TableResultView:getPlayerInfo(playerId, textName, imageHead, textUID)

end

function TableResultView:isGuangDong()
    return AppData.App_Name == 'DHGDQP'
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
            playerResult.totalScore,
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