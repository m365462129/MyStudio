--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local GameObject = UnityEngine.GameObject
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
local TestView = class('TestView', View)
local cardCommon = require('package.guandan.module.guandan_table.gamelogic_common')

function TestView:initialize(...)
    View.initialize(self, "guandan/module/table/guandan_table.prefab", "GuanDan_Table", 0)

    self.imageBg = GetComponentWithPath(self.root, "Background/ImageBackground", ComponentTypeName.Image)
    self.textRoomNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoomID/Text", ComponentTypeName.Text)
    self.textRoundNum = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/RoundNum/Text", ComponentTypeName.Text)

    self.textOurMainCard = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/MainCard/TextOurCard", ComponentTypeName.Text)
    self.textOppoMainCard = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/MainCard/TextOppoCard", ComponentTypeName.Text)
    self.textCurMainCard = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Rate/TextCurMainCard", ComponentTypeName.Text)
    self.textRate = GetComponentWithPath(self.root, "Top/TopInfo/RoomInfo/Rate/TextRate", ComponentTypeName.Text)

    self.buttonReset = GetComponentWithPath(self.root, "Buttons/ButtonReset", ComponentTypeName.Button)
    self.buttonOneCol = GetComponentWithPath(self.root, "Buttons/ButtonOneCol", ComponentTypeName.Button)
    self.buttonShowDesktop = GetComponentWithPath(self.root, "Buttons/ButtonShowDesktop", ComponentTypeName.Button)
    self.buttonSequence = GetComponentWithPath(self.root, "Buttons/ButtonSequence", ComponentTypeName.Button)
    self.buttonChuPai = GetComponentWithPath(self.root, "Buttons/ButtonChuPai", ComponentTypeName.Button)
    self.buttonTiShi = GetComponentWithPath(self.root, "Buttons/ButtonTiShi", ComponentTypeName.Button)

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")
    self.myCardAssetHolder = GetComponentWithPath(self.root, "Holder/MyCardAssetHolder", "SpriteHolder")
    self.imageGray = GetComponentWithPath(self.root, "Holder/ImageGray", ComponentTypeName.Image)
    self._grayMat = self.imageGray.material
    self.prefabPoker = GetComponentWithPath(self.root, "Bottom/HandPokers/Poker", ComponentTypeName.Transform).gameObject
end

function TestView:getImageNameFromCode(code, majorCardLevel)
    local card = cardCommon.ResolveCardIdx(code)
    return self:getImageNameFromCard(card, majorCardLevel)
end

function TestView:getImageNameFromCard(card, majorCardLevel)
    local color = card.color
    local number = card.name
    if(number == cardCommon.card_small_king)then
        return 'little_boss'
    elseif(number == cardCommon.card_big_king)then
        return 'big_boss'
    end
    

    if(color == cardCommon.color_black_heart)then
        return 'heitao_' .. number
    elseif(color == cardCommon.color_red_heart)then
        if(majorCardLevel)then
           return 'xing_' .. number     
        end
        return 'hongtao_' .. number
    elseif(color == cardCommon.color_plum)then
        return 'meihua_' .. number
    elseif(color == cardCommon.color_square)then
        return 'fangkuai_' .. number
    else

    end
end

return  TestView