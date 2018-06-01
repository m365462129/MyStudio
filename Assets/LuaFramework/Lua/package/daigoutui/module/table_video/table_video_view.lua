--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath

local class = require("lib.middleclass")
local View = require('package.daigoutui.module.table.base_table_view')
---@class DaiGouTuiTableVideoView:DaiGouTuiTableBaseView
local DaiGouTuiTableVideoView = class('DaiGouTuiTableVideoView', View)

function DaiGouTuiTableVideoView:initialize(...)
    View.initialize(self, 'daigoutui/module/table/daigoutui_table_video.prefab', 'DaiGouTui_Table_Video', 1)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonMic.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonSetting.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonChat.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonLocation.gameObject, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.textPingValue.transform.parent.gameObject, false)

end

function DaiGouTuiTableVideoView:initSeatHolder(seatHolder, seatRoot, index)
    View.initSeatHolder(self, seatHolder, seatRoot, index)
    seatHolder.handPokerHolder = seatHolder.left_handPokerHolder
    local dispatchCardHolder = {}
    dispatchCardHolder.root = GetComponentWithPath(self.root, "DispatchCards/"..index, ComponentTypeName.Transform).gameObject
    dispatchCardHolder.pokerHolderList = {}
    local prefabPoker = GetComponentWithPath(dispatchCardHolder.root, "Pokers/Poker", ComponentTypeName.Transform).gameObject
    for j=1,38 do
        local pokerHolder = {}
        if(j == 1)then
            pokerHolder.root = prefabPoker
        else
            pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(prefabPoker, prefabPoker.transform.parent.gameObject)
        end
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "Poker/face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "Poker/back", ComponentTypeName.Image);
        pokerHolder.goGouTuiTag = GetComponentWithPath(pokerHolder.root, "Poker/gouTuiTag", ComponentTypeName.Image).gameObject
        pokerHolder.imageServantCardTag = GetComponentWithPath(pokerHolder.root, "Poker/servantTag", ComponentTypeName.Image)

        dispatchCardHolder.pokerHolderList[j] = pokerHolder
    end
    seatHolder.dispatchCardHolder = dispatchCardHolder

    seatHolder.imagePass = GetComponentWithPath(self.root, "PassIcon/"..index.."/PassIcon/image", ComponentTypeName.Image)
end

--显示座位手牌
function DaiGouTuiTableVideoView:showSeatHandPokers(localSeatIndex, show)
    show = show or false
    if(localSeatIndex == 1)then
        self.firstViewHandPokers:show_handPokers(show, true)
        return
    end
    View.showSeatHandPokers(self, localSeatIndex, show)
end

--刷新座位手牌
function DaiGouTuiTableVideoView:refreshSeatHandPokers(localSeatIndex, codeList, servantCard)
    if(localSeatIndex == 1)then
        self.firstViewHandPokers.servantCard = servantCard
        self.firstViewHandPokers:removeAll()
        self.firstViewHandPokers:genPokerHolderList(codeList)
        self.firstViewHandPokers:show_handPokers(true, true)
        self.firstViewHandPokers:resetPokers(true)
        return
    end
    View.refreshSeatHandPokers(self, localSeatIndex, codeList, servantCard)
end




return  DaiGouTuiTableVideoView