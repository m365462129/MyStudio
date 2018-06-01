-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MuseumInfoView = Class('museumInfoView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local PlayModeUtil = ModuleCache.PlayModeUtil
local Manager = require("manager.function_manager")

function MuseumInfoView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/museuminfo/henanmj_museuminfo.prefab", "HeNanMJ_MuseumInfo", 1)
    self.UIStateSwitcher = ModuleCache.ComponentManager.GetComponent(self.root, "UIStateSwitcher")
    self.buttonClose = GetComponentWithPath(self.root, "Top/Child/ImageClose", ComponentTypeName.Button)
    self.imageHead = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/Mask/Head", ComponentTypeName.Image)
    self.textPowerNum = GetComponentWithPath(self.root, "Top/Child/RoomCard/TextNum", ComponentTypeName.Text)
    self.inputFieldNum = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/InputFieldNum", ComponentTypeName.InputField)
    self.inputFieldMember = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/InputFieldMember", ComponentTypeName.InputField)
    self.inputFieldName = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/InputFieldName", ComponentTypeName.InputField)
    self.inputFieldID = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/InputFieldID", ComponentTypeName.InputField)
    self.inputFieldIDBtn = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/InputFieldID/ButtonEditor_ID", ComponentTypeName.Button)

    self.inputFieldWXNum = GetComponentWithPath(self.root, "Top/CustomSetting/InfoBg/InputFieldWXNum", ComponentTypeName.InputField)

    self.custormSettings = {}
    self.custormSettings[1] = GetComponentWithPath(self.root, "Top/CustomSetting", ComponentTypeName.Transform).gameObject
    self.custormSettings[2] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting", ComponentTypeName.Transform).gameObject
    self.settingToggles = {}
    self.settingToggles[1] = GetComponentWithPath(self.root, "Top/Child/Master/1", ComponentTypeName.Toggle)
    self.settingToggles[2] = GetComponentWithPath(self.root, "Top/Child/Master/2", ComponentTypeName.Toggle)
    self.masterCostToggles = { }
    self.masterCostToggles[1] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/MasterCost/1", ComponentTypeName.Toggle)
    self.masterCostToggles[2] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/MasterCost/2", ComponentTypeName.Toggle)
    self.masterCostToggles[3] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/MasterCost/3", ComponentTypeName.Toggle)

    self.powerCostToggles = { }
    self.powerCostToggles[1] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/PowerCost/1", ComponentTypeName.Toggle)
    self.powerCostToggles[2] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/PowerCost/2", ComponentTypeName.Toggle)

    self.showQRCodeToggles = { }
    self.showQRCodeToggles[1] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/showQRCode/1", ComponentTypeName.Toggle)
    self.showQRCodeToggles[2] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/showQRCode/2", ComponentTypeName.Toggle)


    self.ScoreboardToggles = { }
    self.ScoreboardToggles[1] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/Scoreboard/1", ComponentTypeName.Toggle)
    self.ScoreboardToggles[2] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/Scoreboard/2", ComponentTypeName.Toggle)

    self.ChatAuthToggles = { }
    self.ChatAuthToggles[1] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/ChatAuth/1", ComponentTypeName.Toggle)
    self.ChatAuthToggles[2] = GetComponentWithPath(self.root, "Bottom/Child/CustomSetting/Master/ChatAuth/2", ComponentTypeName.Toggle)

    self.masterCostTexts = { }
    for i = 1, #self.masterCostToggles do
        local costText = GetComponentWithPath(self.masterCostToggles[i].gameObject, "bg/text", ComponentTypeName.Text)
        table.insert(self.masterCostTexts, costText)
    end
    self.settingToggleBg = GetComponentWithPath(self.root, "Top/Child/Master/Image", ComponentTypeName.Transform)

    self.playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)

    self.ownRoomObj = GetComponentWithPath(self.root, "Top/Child/OwnRoomCard", ComponentTypeName.Transform).gameObject
    self.powerText = GetComponentWithPath(self.root, "Top/Child/OwnRoomCard/text", ComponentTypeName.Text)
    self.moreShow = GetComponentWithPath(self.root, "Top/Child/OwnRoomCard/bgShop/moreShow", ComponentTypeName.Transform).gameObject
    self.roomCard = GetComponentWithPath(self.root, "Top/Child/OwnRoomCard/bgShop/moreShow/text", ComponentTypeName.Text)

end

function MuseumInfoView:refresh_view(data) --data.playerRole OWNER-馆主,MEMBER-成员,VISITOR-游客,APPLYING-审核中,ADMIN-管理员
    self.inputFieldNum.interactable = false
    self.inputFieldMember.interactable = false
    self.inputFieldName.interactable = (data.playerRole == "OWNER" or data.playerRole == "ADMIN")
    self.inputFieldID.interactable = (data.playerRole == "OWNER")
    self.inputFieldWXNum.interactable = (data.playerRole == "OWNER" or data.playerRole == "ADMIN")

    if(data.playerRole == "OWNER") then
        self.UIStateSwitcher:SwitchState("Master")
        Manager.SetButtonEnable(self.inputFieldIDBtn,true,false,true)
    elseif(data.playerRole == "MEMBER") then
        self.UIStateSwitcher:SwitchState("Custom")
    elseif(data.playerRole == "VISITOR" or data.playerRole == "APPLYING") then
        self.UIStateSwitcher:SwitchState("Visitor")
    elseif(data.playerRole == "ADMIN") then --管理员
        --ButtonEditor_ID
        self.UIStateSwitcher:SwitchState("Master")
        Manager.SetButtonEnable(self.inputFieldIDBtn,false,true,false)
    end
    self:refresh_master_panel(data)
    self.inputFieldNum.text = data.parlorNum .. ""
    self.inputFieldMember.text = data.memberCount .. ""
    self.inputFieldName.text = data.parlorName
    self.inputFieldID.text = data.ownerUid ..""
    self.inputFieldWXNum.text = data.wechatNumber .. ""

    TableUtil.only_download_head_icon(self.imageHead, data.imageHead)
    self:set_image_fill(self.imageHead,204)
end

function MuseumInfoView:refresh_master_panel(data)
    if(self.settingToggles[1].isOn) then
        self.settingToggleBg.localPosition = Vector3.New(63, self.settingToggleBg.localPosition.y, self.settingToggleBg.localPosition.z)
    else
        self.settingToggleBg.localPosition = Vector3.New(-85, self.settingToggleBg.localPosition.y, self.settingToggleBg.localPosition.z)
    end
    for i=1,#self.custormSettings do
        ComponentUtil.SafeSetActive(self.custormSettings[i], self.settingToggles[1].isOn or (data.playerRole ~= "OWNER" and data.playerRole ~= "ADMIN"))
    end
    if(self.settingToggles[2].isOn and (data.playerRole == "OWNER" or data.playerRole == "ADMIN")) then
        --if self.inputFieldName.text ~=""then
        --    self.inputFieldName.text = "  "
        --    self.sendData.data.parlorName = string.match(self.inputFieldName.text,"%s*(.-)%s*$")
        --end
        --
        --if self.inputFieldWXNum.text ~=""then
        --    self.inputFieldWXNum.text = "  "
        --    self.sendData.data.wechatNumber = string.match( self.inputFieldWXNum.text,"%s*(.-)%s*$")
        --end
        self.sendData.data.parlorName = string.match(self.inputFieldName.text,"%s*(.-)%s*$")
        self.sendData.data.wechatNumber = string.match( self.inputFieldWXNum.text,"%s*(.-)%s*$")

        ModuleCache.ModuleManager.show_module("henanmj", "rulesetting", self.sendData) 
    else
        ModuleCache.ModuleManager.hide_module("henanmj", "rulesetting") 
    end
end

function MuseumInfoView:update_user_data(data)
    self.textPowerNum.text = data.coins .. ""
end

return MuseumInfoView