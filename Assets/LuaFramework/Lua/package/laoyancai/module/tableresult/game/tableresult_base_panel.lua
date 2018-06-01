-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
-- ==========================================================================
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

local TableResult_BasePanel = Class("tableResult_BasePanel")

function TableResult_BasePanel:initialize(module)
    self.module = module
    self.view = module.view
    self:initPanel()
end

function TableResult_BasePanel:initPanel()
    
end

function TableResult_BasePanel:refreshPanel(playerResultList, maxScore,dissolverId)
    local count = #playerResultList    
    for i=1,count do
        local playerResult = playerResultList[i]
        local item = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabItem, self.view.goPlayersRoot)  
        item.name = "player" .. i         
        --print("itemname=".. item.name)
        item:SetActive(true)
        if(maxScore > 0 and maxScore == playerResult.totalScore)then
            playerResult.isWinner = true
        end
        self:fillItem(item, playerResult,dissolverId)
    end
end

function TableResult_BasePanel:fillItem(item, playerResult,dissolverId)
    local textUid = GetComponentWithPath(item, "Role/ID/TextID", ComponentTypeName.Text)
    local textName = GetComponentWithPath(item, "Role/Name/TextName", ComponentTypeName.Text)
    local player = playerResult.player    
    textUid.text = player.uid .. ""    
    textName.text = Util.filterPlayerName(player.nickname) 
    local headImage = GetComponentWithPath(item, "Role/Avatar/Avatar/Image", ComponentTypeName.Image)
    if(player.headImg and player.headImg ~= "")then
        self:startDownLoadHeadIcon(player.headImg, headImage)
    end

    local imageRoomCreator = GetComponentWithPath(item, "Role/ImageRoomCreator", ComponentTypeName.Image)
    local imageWinner = GetComponentWithPath(item, "Role/ImageWinner", ComponentTypeName.Image)
    local imageDissolver = GetComponentWithPath(item, "Role/ImageRoomDissolver", ComponentTypeName.Image)
    ModuleCache.ComponentUtil.SafeSetActive(imageRoomCreator.gameObject, playerResult.isRoomCreator)
    ModuleCache.ComponentUtil.SafeSetActive(imageWinner.gameObject, playerResult.isWinner)
    if(dissolverId and dissolverId ~= 0) then
        local isDissolver = tonumber(player.uid) == tonumber(dissolverId);
        ModuleCache.ComponentUtil.SafeSetActive(imageDissolver.gameObject, isDissolver)
    end
    if(playerResult.totalScore >= 0)then
        GetComponentWithPath(item, "TotalScore/redScore", "TextWrap").text = "+"..playerResult.totalScore
    else
        GetComponentWithPath(item, "TotalScore/greenScore", "TextWrap").text = playerResult.totalScore .. ""
    end
    
end

function TableResult_BasePanel:startDownLoadHeadIcon(url, image)    
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            --print('down load '.. url .. 'failed:' .. err)
            --self:startDownLoadHeadIcon(url, image)
        else
            if image then
                image.sprite = tex
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(image, tex)
        end
    end)    
end

return TableResult_BasePanel