--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local class = require("lib.middleclass")
local View = require('package.daigoutui.module.onegameresult.base_result_view')
local TableResultView = class('oneGameResultView', View)

function TableResultView:initialize(...)
    View.initialize(self, "daigoutui/module/tableresult/daigoutui_tableresult.prefab", "DaiGouTui_TableResult", 1)
    self.goBottom = GetComponentWithPath(self.goRoot, "Bottom", ComponentTypeName.Transform).gameObject
    self.buttonShare = GetComponentWithPath(self.goBottom, "BtnShare", ComponentTypeName.Button)
    self.buttonBack = GetComponentWithPath(self.goBottom, "ButtonBack", ComponentTypeName.Button)
end

function TableResultView:initPlayerHolder(root, index)
    local holder = View.initPlayerHolder(self, root, index)
    holder.textXiPai = GetComponentWithPath(root, "XiPai/text", ComponentTypeName.Text)
    holder.textDiZhu = GetComponentWithPath(root, "DiZhu/text", ComponentTypeName.Text)
    holder.textGouTui = GetComponentWithPath(root, "GouTui/text", ComponentTypeName.Text)
    holder.textNongMin = GetComponentWithPath(root, "NongMin/text", ComponentTypeName.Text)
    holder.textId = GetComponentWithPath(root, "Role/ID/TextID", ComponentTypeName.Text)
    holder.imageDissolver = GetComponentWithPath(root, "Role/dissolver", ComponentTypeName.Image)
    return holder
end

function TableResultView:refresh_view(data)
    local players = data.players
    for i = 1, #players do
        local player = players[i]
        if(player.playerId == data.free_sponsor)then
            player.isDissolver = true
        end
    end
    View.refresh_view(self, data)
end

function TableResultView:refreshPlayer(holder, player, isSelf)
    player.score = player.totalScore
    View.refreshPlayer(self, holder, player, isSelf)
    holder.textXiPai.text = player.xipai_times
    holder.textDiZhu.text = player.dizhu_times
    holder.textGouTui.text = player.goutui_times
    holder.textNongMin.text = player.nongmin_times
    holder.textId.text = 'ID:'..player.playerId
    ModuleCache.ComponentUtil.SafeSetActive(holder.imageDissolver.gameObject, player.isDissolver or false)
end



return  TableResultView