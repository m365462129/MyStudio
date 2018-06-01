-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local PlayerInfoView = Class('playerInfoView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function PlayerInfoView:initialize()
    -- 初始View
    View.initialize(self, "biji/module/playerinfo/bullfight_windowplayerinfo.prefab", "BullFight_WindowPlayerInfo", 1)

    local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
        
    self.buttonClose = GetComponentWithPath(self.root, "BaseBackground/closeBtn", ComponentTypeName.Button)
    self.imageHead = GetComponentWithPath(self.root, "Center/PlayerInfo/Avatar/Mask/Image", ComponentTypeName.Image)
    self.imageMale = GetComponentWithPath(self.root, "Center/PlayerInfo/Avatar/sex/male", ComponentTypeName.Image)
    self.imageFemale = GetComponentWithPath(self.root, "Center/PlayerInfo/Avatar/sex/female", ComponentTypeName.Image)
    self.textName = GetComponentWithPath(self.root, "Center/PlayerInfo/Name/TextName", ComponentTypeName.Text)
    
    self.textID = GetComponentWithPath(self.root, "Center/DetailInfo/ID/Text", ComponentTypeName.Text)
    self.textTotalScore = GetComponentWithPath(self.root, "Center/DetailInfo/TotalScore/Text", ComponentTypeName.Text)
    self.textWinTimes = GetComponentWithPath(self.root, "Center/DetailInfo/WinResult/Win/Text", ComponentTypeName.Text)
    self.textLoseTimes = GetComponentWithPath(self.root, "Center/DetailInfo/WinResult/Lose/Text", ComponentTypeName.Text)
    self.textDrawTimes = GetComponentWithPath(self.root, "Center/DetailInfo/WinResult/Draw/Text", ComponentTypeName.Text)
    self.textWinRate = GetComponentWithPath(self.root, "Center/DetailInfo/WinRate/Text", ComponentTypeName.Text)
    self.textOfflineRate = GetComponentWithPath(self.root, "Center/DetailInfo/OfflineRate/Text", ComponentTypeName.Text)

    self:resetView()
end


function PlayerInfoView:resetView()    
    ModuleCache.ComponentUtil.SafeSetActive(self.imageMale.gameObject, false)   
    ModuleCache.ComponentUtil.SafeSetActive(self.imageFemale.gameObject, false)   
    self.textName.text = ""
    self.textID.text = ""
    self.textTotalScore.text = ""
    self.textWinTimes.text = ""
    self.textLoseTimes.text = ""
    self.textDrawTimes.text = ""
    self.textWinRate.text = ""
    self.textOfflineRate.text = ""
    
end

function PlayerInfoView:refreshView(playerInfo)        
    if(playerInfo)then
        self:setPlayerInfo(playerInfo)
    end        
end

--填写玩家基本信息
function PlayerInfoView:setPlayerInfo(playerInfo)
    if(playerInfo.playerId ~= 0)then
        self.textID.text = playerInfo.userId .. ''
        self.textName.text = Util.filterPlayerName(playerInfo.nickname)
        self.textTotalScore.text = playerInfo.score .. ''
        self.textWinTimes.text = playerInfo.winCount .. ''
        self.textLoseTimes.text = playerInfo.lostCount .. ''
        self.textDrawTimes.text = playerInfo.tieCount .. ''

        local totalCount = playerInfo.winCount + playerInfo.lostCount + playerInfo.tieCount
        if(totalCount == 0)then
            totalCount = 1
        end
        self.textWinRate.text = string.format( "%0.2f",(playerInfo.winCount / totalCount) * 100) .. "%"
        self.textOfflineRate.text = playerInfo.breakRate

        self:startDownLoadHeadIcon(self.imageHead, playerInfo.headImg)
        local isMale = playerInfo.gender == 1
        ModuleCache.ComponentUtil.SafeSetActive(self.imageMale.gameObject, isMale)   
        ModuleCache.ComponentUtil.SafeSetActive(self.imageFemale.gameObject, not isMale)  
    else
        return
    end
    
end

--下载头像
function PlayerInfoView:StartDownLoadHeadIcon(targetImage, url)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            print('=====down load '.. url .. 'failed:')
            if string.find(err.error, 'Network Timeout') and string.find(err.error, 'http') == 1 then
                if(self) then
                    --self:StartDownLoadHeadIcon(targetImage, url)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end)    
end

return PlayerInfoView