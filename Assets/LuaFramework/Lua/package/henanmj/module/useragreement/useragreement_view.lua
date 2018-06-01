-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local UserAgreementView = Class('userAgreementView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName


function UserAgreementView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/useragreement/henanmj_windowuseragreement.prefab", "HeNanMJ_WindowUserAgreement", 1)

    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    

    self.buttonClose = GetComponentWithPath(self.root, "Title/closeBtn", ComponentTypeName.Button)
    self.textUserAgreement = GetComponentWithPath(self.root, "Center/Panels/Agreenment/Text", ComponentTypeName.Text)
    self:initPanelUserAgreementText()
    self.gameObjectPanelText = ModuleCache.ComponentUtil.Find(self.root, "Center/Panels/Agreenment")
    self.gameObjectPanelTest = ModuleCache.ComponentUtil.Find(self.root, "Center/Panels/PanelTest")
    self.gameObjectPanelTestVerify = ModuleCache.ComponentUtil.Find(self.root, "Center/Panels/PanelTestVerify")
    self.inputTestVerify = GetComponentWithPath(self.root, "Center/Panels/PanelTestVerify/InputField", ComponentTypeName.InputField)
    self.toggleClear = ModuleCache.ComponentUtil.Find(self.root, "Center/Panels/PanelTest")

    self.toggleOpenDevelopModel = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "Center/Panels/PanelTest/ToggleOpenDevelopModel", ComponentTypeName.Toggle)
    self.toggleLockAsset = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "Center/Panels/PanelTest/ToggleLockAsset", ComponentTypeName.Toggle)
    self.toggleLockAsset.isOn = ModuleCache.GameManager.lockAssetUpdate

    self.toggleLockAsset.onValueChanged:AddListener(function(state)
        ModuleCache.GameManager.lockAssetUpdate = state
        if state then
            ModuleCache.UnityEngine.PlayerPrefs.SetInt(ModuleCache.AppData.PLAYER_PREFS_KEY_LOCK_ASSET, 1)
        else
            ModuleCache.UnityEngine.PlayerPrefs.SetInt(ModuleCache.AppData.PLAYER_PREFS_KEY_LOCK_ASSET, 0)
        end
    end)
end

function UserAgreementView:initPanelUserAgreementText()
    
end



return UserAgreementView