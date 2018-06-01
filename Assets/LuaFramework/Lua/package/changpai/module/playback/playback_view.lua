local require = require
local Manager = require("manager.function_manager")

-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local PlayBackView = Class('PlayBackView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function PlayBackView:initialize(...)
    -- 初始View
    View.initialize(self, "changpai/module/playback/changpai_playback.prefab", "ChangPai_PlayBack", 1)
    self.ButtonExit = GetComponentWithPath(self.root, "TopRight/Child/ButtonExit", ComponentTypeName.Button).gameObject
    self.ButtonReset = GetComponentWithPath(self.root, "TopRight/Child/ButtonReset", ComponentTypeName.Button).gameObject
    self.ButtonPause = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonPause", ComponentTypeName.Button).gameObject
    self.ButtonUnPause = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonUnPause", ComponentTypeName.Button).gameObject
    self.ButtonFront = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonFront", ComponentTypeName.Button).gameObject
    self.ButtonBack = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonBack", ComponentTypeName.Button).gameObject
end

function PlayBackView:on_inited()
    self.switchers_1 = Manager.GetComponent(self.root, "UIStateSwitcher", "TopRight/Child")
    self.switchers_1:SwitchState("ChangPai")

    self.switchers_2 = Manager.GetComponent(self.root, "UIStateSwitcher", "BottomRight/Child/Action")
    self.switchers_2:SwitchState("ChangPai")

    self.panel_chupai = Manager.FindObject(self.root, "PanelChuPai")

    self.base_changpai = Manager.FindObject(self.panel_chupai, "BaseChangPai")

    local gameEventCollector = Manager.GetComponent(self.root, "UGUIExtend.GameEventCollector")
    gameEventCollector.packageName = "changpai"
    gameEventCollector.moduleName = "playback"

    self.players = {}
    for i = 1, 3 do
        local player = {}

        player.root = Manager.FindObject(self.panel_chupai, "Child/Player" .. i)
        player.avatar = Manager.GetImage(player.root, "PlayerInfo/Avatar/Mask/Image")
        player.highlight = Manager.FindObject(player.root, "PlayerInfo/Avatar/HighLight")
        player.name = Manager.GetText(player.root, "PlayerInfo/Text")
        player.banker = Manager.FindObject(player.root, "Banker")
        player.grid = Manager.FindObject(player.root, "Grid")
        player.changpai_table = {}

        self.players[i] = player
    end
end

function PlayBackView:get_changpai_clone(index)
    local player = self.players[index]
    local parent = player.grid

    local obj = {}
    obj.root = Manager.CloneObject(self.base_changpai, parent)
    obj.imageJ = Manager.GetImage(obj.root, "J")
    obj.spritesJ = Manager.GetComponent(obj.root, "SpriteHolder", "J")
    obj.imageF = Manager.GetImage(obj.root, "F")
    obj.spritesF = Manager.GetComponent(obj.root, "SpriteHolder", "F")

    player.changpai_table[#player.changpai_table + 1] = obj

    return obj
end

return PlayBackView