-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local CreateRoomView = Class('createRoomView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function CreateRoomView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/createroom/henanmj_windowcreateroom.prefab", "HeNanMJ_WindowCreateRoom", 1)

    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    

    self.buttonClose = GetComponentWithPath(self.root, "TopLeft/Child/ImageBack", ComponentTypeName.Button)
   -- self.buttonRecharge = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard/ButtonAdd", ComponentTypeName.Button)
    -- self.ownRoomObj = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard", ComponentTypeName.Transform).gameObject
    -- self.roomCard = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard/text", ComponentTypeName.Text)
    self.coinName = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard/bgShop/moreShow/TextName", ComponentTypeName.Text)
    self.buttonCreateRoom = GetComponentWithPath(self.root,"Top/Child/Title/ImageButton1",ComponentTypeName.Image);
    self.buttonIntroduction = GetComponentWithPath(self.root,"Top/Child/Title/ImageButton2",ComponentTypeName.Image);
    self.buttonSelection = GetComponentWithPath(self.root,"Top/Child/Title/Background",ComponentTypeName.Image);
  
    self.ownRoomObj = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard", ComponentTypeName.Transform).gameObject
    self.powerText = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard/text", ComponentTypeName.Text)
    ---@type UnityEngine.GameObject
    self.moreShow = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard/bgShop/moreShow", ComponentTypeName.Transform).gameObject
    self.roomCard = GetComponentWithPath(self.root, "TopRight/Child/Tips/OwnRoomCard/bgShop/moreShow/text", ComponentTypeName.Text)

    if ModuleCache.GameManager.isTestUser then
        -- 是否开启服务器灰度测试
        self.toggleGameServerGradationTest = GetComponentWithPath(self.root, "TopLeft/Child/ToggleGameServerGradationTest", ComponentTypeName.Toggle)
        self.toggleGameServerGradationTest.gameObject:SetActive(true)
        self.toggleGameServerGradationTest.isOn = ModuleCache.GameManager.openGameServerGradationTest
        self.toggleGameServerGradationTest.onValueChanged:AddListener(function(state)
            ModuleCache.GameManager.openGameServerGradationTest = state
            self.toggleGameServerGradationTest.isOn = ModuleCache.GameManager.openGameServerGradationTest
        end)
    end
end

function CreateRoomView:refreshCoinName( )
    local playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)
    self.coinName.text = "专属"
	--if(playMode.coinName ~= nil) then
	--	self.coinName.text = playMode.coinName
	--end
end

return CreateRoomView