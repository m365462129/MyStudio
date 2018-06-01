-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableResultView = Class('tableResultView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local BranchPackageName = AppData.BranchZhaJinHuaName   

function TableResultView:initialize(...)
    -- 初始View
    View.initialize(self, BranchPackageName.."/module/tableresult/zhajinhua_windowtableresult.prefab", "ZhaJinHua_WindowTableResult", 1)

    self.DissolveRoomInfoRoot = GetComponentWithPath(self.root, "Center/DissolveRoomInfo", ComponentTypeName.Transform).gameObject
    self.DissolveRoomInfoName = GetComponentWithPath(self.root, "Center/DissolveRoomInfo/Name", ComponentTypeName.Text)

    self.buttonBack = GetComponentWithPath(self.root, "Center/Buttons/ButtonBack", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Center/Buttons/ButtonShare", ComponentTypeName.Button)
    self.uiStateSwitcher = GetComponentWithPath(self.root, "Center/Buttons", "UIStateSwitcher")

    self.textRoomNum = GetComponentWithPath(self.root, "Title/TextRoomNum", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Title/TimeNum", ComponentTypeName.Text)

    self.goPlayersRoot = GetComponentWithPath(self.root, "Center/Players", ComponentTypeName.Transform).gameObject
    self.prefabItem = GetComponentWithPath(self.root, "Holder/Item", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(self.prefabItem.gameObject, false)
    
    if(ModuleCache.GameManager.iosAppStoreIsCheck)then
        self.uiStateSwitcher:SwitchState("IosCheck")
    else
        self.uiStateSwitcher:SwitchState("Normal")
    end  

end

function TableResultView:on_view_init()
     
end

function TableResultView:refreshRoomInfo(roomNum, tableInfo, timestamp)

    local roomName = "飘三叶"
    self.textRoomNum.text = string.format( "房号:%d %s 第%d/%d局", roomNum,roomName,tableInfo.curRoundNum,tableInfo.totalRoundCount) 
    self.textTime.text = "结束 "..os.date("%Y-%m-%d   %H:%M", timestamp)

    self.free_sponsor = tableInfo.free_sponsor
    --self:SetDissolveRoomInfoState()
    self.endTime = timestamp
    self.roomNum = roomNum
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
    if(self.free_sponsor and self.free_sponsor == tonumber(player.uid)) then
        --self:SetDissolveRoomInfoState(Util.filterPlayerName(player.nickname))
        local ImageJieSan = GetComponentWithPath(item, "Role/ImageJieSan", ComponentTypeName.Image)
        ModuleCache.ComponentUtil.SafeSetActive(ImageJieSan.gameObject, true)
    end
    local headImage = GetComponentWithPath(item, "Role/Avatar/Avatar/Image", ComponentTypeName.Image)
    GetComponentWithPath(item, "DetailScore/WinTimes/value", ComponentTypeName.Text).text = playerResult.winTimes .. ""
    GetComponentWithPath(item, "DetailScore/LoseTimes/value", ComponentTypeName.Text).text = playerResult.loseTimes .. ""

    local imageRoomCreator = GetComponentWithPath(item, "Role/ImageRoomCreator", ComponentTypeName.Image)
    local imageWinner = GetComponentWithPath(item, "Role/ImageWinner", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(imageRoomCreator.gameObject, playerResult.isRoomCreator)
    ModuleCache.ComponentUtil.SafeSetActive(imageWinner.gameObject, playerResult.isWinner)

    local CoinRoot = GetComponentWithPath(item, "CoinRoot", ComponentTypeName.Transform).gameObject
    if(playerResult.isGoldSettle) then
        local RedBag = GetComponentWithPath(item, "CoinRoot/RedBag", ComponentTypeName.Transform).gameObject
        if(playerResult.restCoin and playerResult.restCoin ~= 0) then
            ModuleCache.ComponentUtil.SafeSetActive(RedBag.gameObject, true)
            GetComponentWithPath(item, "CoinRoot/Coin/Text", ComponentTypeName.Text).text = self:GetColorText(playerResult.allCoin)
            GetComponentWithPath(item, "CoinRoot/RedBag/Text", ComponentTypeName.Text).text = self:GetColorText(playerResult.restCoin/100)
        else
            ModuleCache.ComponentUtil.SafeSetActive(RedBag.gameObject, false)
            GetComponentWithPath(item, "CoinRoot/Coin/Text", ComponentTypeName.Text).text = self:GetColorText(playerResult.allCoin)
        end
        ModuleCache.ComponentUtil.SafeSetActive(CoinRoot, true)
    else

        if(playerResult.totalScore >= 0)then
            GetComponentWithPath(item, "TotalScore/redScore", "TextWrap").text =  "+" .. playerResult.totalScore .. ""
        else
            GetComponentWithPath(item, "TotalScore/greenScore", "TextWrap").text = playerResult.totalScore .. ""
        end
        ModuleCache.ComponentUtil.SafeSetActive(CoinRoot, false)
    end


    if(player.spriteHeadImage) then
        headImage.sprite = player.spriteHeadImage
        print("====大结算 玩家图片是传入的")
    elseif(playerResult.playerInfo and playerResult.playerInfo.headUrl) then
        print("====大结算 玩家图片是拉取的1")
        ModuleCache.TextureCacheManager:startDownLoadHeadIcon(playerResult.playerInfo.headUrl,function ( HeadIcon )
            headImage.sprite = HeadIcon
        end)
    elseif(player.headImg and player.headImg ~= "")then
        print("====大结算 玩家图片是拉取的2")
        ModuleCache.TextureCacheManager:startDownLoadHeadIcon(player.headImg,function ( HeadIcon )
            headImage.sprite = HeadIcon
        end)
    else
        print("====大结算 玩家图片没有")
        print_table(playerResult)
    end
end

function TableResultView:GetColorText(count)
    if(count >= 0) then
        return "<color=#E20C0C>".. "+" .. count .."</color>"
    else
        return "<color=#02C714>" .. count .."</color>"
    end
end

--设置解散房间的信息
function TableResultView:SetDissolveRoomInfoState(_playerName)
    --if(_playerName) then
    --    ModuleCache.ComponentUtil.SafeSetActive(self.DissolveRoomInfoRoot.gameObject,true)
    --    self.DissolveRoomInfoName.text = Util.filterPlayerName(_playerName)
    --else
    --    ModuleCache.ComponentUtil.SafeSetActive(self.DissolveRoomInfoRoot.gameObject,false)
    --end
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
            playerResult.totalScore,
        }
        table.insert(playerDatas,tmp)
        if(self.free_sponsor and self.free_sponsor == tonumber(playerResult.player.uid))then
            resultData.dissRoomPlayName = playerResult.player.nickname
        end
    end
    resultData.playerDatas = playerDatas
    return resultData
end

return TableResultView