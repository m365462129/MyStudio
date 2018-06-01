--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local class = require("lib.middleclass")
local View = require('package.daigoutui.module.onegameresult.base_result_view')
local cardCommon = require('package.daigoutui.module.table.gamelogic_common')
local OneGameResultView = class('oneGameResultView', View)

function OneGameResultView:initialize(...)
    View.initialize(self, "daigoutui/module/onegameresult/daigoutui_onegameresult.prefab", "DaiGouTui_OneGameResult", 1)
    self.textScoreInfo = GetComponentWithPath(self.goRoot, "Title/TextScoreInfo", ComponentTypeName.Text)
    self.goBottom = GetComponentWithPath(self.root, "Bottom", ComponentTypeName.Transform).gameObject
    self.buttonShare = GetComponentWithPath(self.goBottom, "BtnShare", ComponentTypeName.Button)
    self.buttonRestart = GetComponentWithPath(self.goBottom, "BtnRestart", ComponentTypeName.Button)

    self.smallCardAssetHolder = GetComponentWithPath(self.goRoot, "SmallCardAssetHolder", "SpriteHolder")
end

function OneGameResultView:initPlayerHolder(root, index)
    local holder = View.initPlayerHolder(self, root, index)
    holder.imageServant = GetComponentWithPath(root, "Role/ImageServant", ComponentTypeName.Image)
    holder.imageLord = GetComponentWithPath(root, "Role/ImageLandLord", ComponentTypeName.Image)
    holder.imageMingPai = GetComponentWithPath(root, "Role/ImageMingPai", ComponentTypeName.Image)
    holder.textBondScore = GetComponentWithPath(root, "XiQianScore/textScore", ComponentTypeName.Text)
    return holder
end

function OneGameResultView:refresh_view(data)
    View.refresh_view(self, data)
    local roomInfo = data.roomInfo
    -- 回放的时候没有roomInfo.roomTitle
    if roomInfo.roomTitle then
        self.textRoomInfo.text = string.format('%s 房号:%d 第%d/%d局',roomInfo.roomTitle or "", roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount)
    else
        self.textRoomInfo.text = string.format('房号:%d 第%d/%d局', roomInfo.roomNum, roomInfo.curRoundNum, roomInfo.totalRoundCount)
    end
    self.textScoreInfo.text = string.format( '基础分:%d 倍率:%d', data.base_score, data.multiple)
    if(data.hide_shareBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonShare.gameObject, false)
    end
    if(data.hide_restartBtn)then
        ModuleCache.ComponentUtil.SafeSetActive(self.buttonRestart.gameObject, false)
    end
end

function OneGameResultView:refreshPlayer(holder, player, isSelf)
    View.refreshPlayer(self, holder, player, isSelf)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageCreator.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageLord.gameObject, player.isLord or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageServant.gameObject, player.isServant or false)
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageMingPai.gameObject, player.isShowCard or false)
    holder.textBondScore.text = player.bond_score
end


return  OneGameResultView