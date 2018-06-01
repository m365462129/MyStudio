-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local RoomSettingView = Class('roomSettingView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local GetComponent = ModuleCache.ComponentManager.GetComponent
local ComponentUtil = ModuleCache.ComponentUtil
local PlayerPrefs = UnityEngine.PlayerPrefs

function RoomSettingView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/roomsetting/henanmj_windowroomsetting.prefab", "HeNanMJ_WindowRoomSetting", 1)

    self._parent = GetComponentWithPath(self.root, "Center", ComponentTypeName.Transform)

    self.curTableData = TableManager.curTableData

    self.buttonClose         = GetComponentWithPath(self.root, "BaseBackground/closeBtn", ComponentTypeName.Button)
    self.buttonDissolveRoom  = GetComponentWithPath(self.root, "Center/ButtonDissolveRoom", ComponentTypeName.Button)
    self.buttonExitRoom      = GetComponentWithPath(self.root, "Center/Buttons/ButtonExitRoom", ComponentTypeName.Button)
    self.toggleYuYin         = GetComponentWithPath(self.root, "Center/Sound/ToggleYuYin", ComponentTypeName.Toggle)
    self.toggleZhenDong      = GetComponentWithPath(self.root, "Center/Game/ToggleZhenDong", ComponentTypeName.Toggle)
    self.toggleGuoHu         = GetComponentWithPath(self.root, "Center/Game/ToggleGuoHu", ComponentTypeName.Toggle)
    self.toggleRecomOut      = GetComponentWithPath(self.root, "Center/Game/ToggleRecomOut", ComponentTypeName.Toggle)
    self.toggleMusic         = GetComponentWithPath(self.root, "Center/Sound/ToggleMusic", ComponentTypeName.Toggle)
    self.toggleSound         = GetComponentWithPath(self.root, "Center/Sound/ToggleSound", ComponentTypeName.Toggle)
    self.toggleFast          = GetComponentWithPath(self.root, "Center/Game/ToggleFast", ComponentTypeName.Toggle)
    self.textAppLv           = GetComponentWithPath(self.root, "Center/AppLv", ComponentTypeName.Text)
    self.textResLv           = GetComponentWithPath(self.root, "Center/ResLv", ComponentTypeName.Text)
    self.packageResLv        = GetComponentWithPath(self.root, "Center/PackageLv", ComponentTypeName.Text)


    self.ButtonBg1            = GetComponentWithPath(self.root, "Center/Background/ButtonBg1", ComponentTypeName.Transform).gameObject
    self.ButtonBg2            = GetComponentWithPath(self.root, "Center/Background/ButtonBg2", ComponentTypeName.Transform).gameObject
    self.ButtonBg3            = GetComponentWithPath(self.root, "Center/Background/ButtonBg3", ComponentTypeName.Transform).gameObject
    self.ImageBg1            = GetComponentWithPath(self.root, "Center/Background/ButtonBg1/bg", ComponentTypeName.Image)
    self.ImageBg2            = GetComponentWithPath(self.root, "Center/Background/ButtonBg2/bg", ComponentTypeName.Image)
    self.ImageBg3            = GetComponentWithPath(self.root, "Center/Background/ButtonBg3/bg", ComponentTypeName.Image)
    self.goBgSelect1         = ModuleCache.ComponentUtil.Find(self.root, "Center/Background/ButtonBg1/ImageSelect")
    self.goBgSelect2         = ModuleCache.ComponentUtil.Find(self.root, "Center/Background/ButtonBg2/ImageSelect")
    self.goBgSelect3         = ModuleCache.ComponentUtil.Find(self.root, "Center/Background/ButtonBg3/ImageSelect")
    self.goGameSetting       = GetComponentWithPath(self.root, "Center/Game", ComponentTypeName.Transform).gameObject

    ---2D ,3D 麻将切换相关——————Begin
    self.goSelect2d         = ModuleCache.ComponentUtil.Find(self.root, "Center/Background/Button2d/ImageSelect")
    self.goSelect3d         = ModuleCache.ComponentUtil.Find(self.root, "Center/Background/Button3d/ImageSelect")
    self.Image2d            = GetComponentWithPath(self.root, "Center/Background/Button2d/bg", ComponentTypeName.Image)
    self.Image3d            = GetComponentWithPath(self.root, "Center/Background/Button3d/bg", ComponentTypeName.Image)
    self.Button2d           = GetComponentWithPath(self.root, "Center/Background/Button2d", ComponentTypeName.Transform).gameObject
    self.Button3d           = GetComponentWithPath(self.root, "Center/Background/Button3d", ComponentTypeName.Transform).gameObject
    -------------------------------End



    self.goSoundSetting      = GetComponentWithPath(self.root, "Center/Sound", ComponentTypeName.Transform).gameObject
    self.goBackgroundSetting = GetComponentWithPath(self.root, "Center/Background", ComponentTypeName.Transform).gameObject

    self.labelMajiang        = GetComponentWithPath(self.root, "Center/Buttons/Panel/MaJiangSetting/Checkmark", ComponentTypeName.Transform).gameObject
    self.labelBackground     = GetComponentWithPath(self.root, "Center/Buttons/Panel/BackgroundSetting/Checkmark", ComponentTypeName.Transform).gameObject
    self.labelMusic          = GetComponentWithPath(self.root, "Center/Buttons/Panel/MusicSetting/Checkmark", ComponentTypeName.Transform).gameObject
    self.labelGame           = GetComponentWithPath(self.root, "Center/Buttons/Panel/GameSetting/Checkmark", ComponentTypeName.Transform).gameObject
    self.labelZiPai           = GetComponentWithPath(self.root, "Center/Buttons/Panel/ZiPaiSetting/Checkmark", ComponentTypeName.Transform).gameObject
    self.sliderMusic         = GetComponentWithPath(self.root, "Center/Sound/ToggleMusic/Slider", ComponentTypeName.Slider)
    self.sliderSound         = GetComponentWithPath(self.root, "Center/Sound/ToggleSound/Slider", ComponentTypeName.Slider)
    self.sliderYuYin         = GetComponentWithPath(self.root, "Center/Sound/ToggleYuYin/Slider", ComponentTypeName.Slider)
    self.labelRunfast        = GetComponentWithPath(self.root, "Center/Buttons/Panel/RunfastSetting/Checkmark", ComponentTypeName.Transform).gameObject
    self.labelCommonPoker        = GetComponentWithPath(self.root, "Center/Buttons/Panel/CommonPokerSetting/Checkmark", ComponentTypeName.Transform).gameObject

    ---普通话，方言切换相关------------Begin
    self.goLocationSetting = GetComponentWithPath(self.goSoundSetting, "LocationSetting", ComponentTypeName.Transform).gameObject
    self.commonCheckMark = GetComponentWithPath(self.goLocationSetting, "Common/Toggle/Checkmark", ComponentTypeName.Transform).gameObject
    self.locationCheckMark = GetComponentWithPath(self.goLocationSetting, "Location/Toggle/Checkmark", ComponentTypeName.Transform).gameObject
    ----------------------------------End

    ---推荐出牌相关------------------Begin
    self.goRecommendOutPaiSetting = GetComponentWithPath(self.goGameSetting, "ToggleRecomOut", ComponentTypeName.Transform).gameObject
    self.RecommendOkCheckMark = GetComponentWithPath(self.goRecommendOutPaiSetting, "select", ComponentTypeName.Transform).gameObject
    self.RecommendNoCheckMark = GetComponentWithPath(self.goRecommendOutPaiSetting, "unselect", ComponentTypeName.Transform).gameObject
    ---------------------------------End

    ----通用扑克切换牌面
    self.goCommonPokerFaceSetting = GetComponentWithPath(self.root, "Center/CommonPokerFaceSetting", ComponentTypeName.Transform).gameObject
    self.toggle_commonPokerFace = GetComponentWithPath(self.goCommonPokerFaceSetting, "Size/ToggleGroup/Toggle1", ComponentTypeName.Toggle)
    --self:refreshVolumes()

end



function RoomSettingView:refreshView(intentData)
    self.intentData = intentData
    self.majiangPackageName = intentData.majiangPackageName
    if(self.curTableData and self.curTableData.ruleJsonInfo) then
        local config = ModuleCache.PlayModeUtil.get_playmodel_data(self.curTableData.ruleJsonInfo.GameType)
        local defaultScale = 0
        local defaultColor = 0
        local defaultBg = 1
        if(config.cardTheame) then
            local strs = string.split(config.cardTheame, "|")
            if(strs[1]) then
                defaultScale = tonumber(strs[1])
            end
            if(strs[2]) then
                defaultColor = tonumber(strs[2])
            end
            if(strs[3]) then
                defaultBg = tonumber(strs[3])
            end
        end
        self.mjScaleSet = PlayerPrefs.GetInt(string.format("%s_MJScale",self.curTableData.ruleJsonInfo.GameType), defaultScale)
        self.mjColorSet = PlayerPrefs.GetInt(string.format("%s_MJColor",self.curTableData.ruleJsonInfo.GameType), defaultColor)
        self.mj3dSkinType = PlayerPrefs.GetInt(string.format("%s_Mj3d_Skin",self.curTableData.ruleJsonInfo.GameType),1)
        self.bgSetKey = string.format("%s_MJBackground",self.curTableData.ruleJsonInfo.GameType)
        self.mjBgSet = PlayerPrefs.GetInt(self.bgSetKey, defaultBg)

        ---2d,3d麻将切换相关 ----- Begin -----------------------
        if  self.intentData.is3D == 1 then ---开放了2D和3D切换
            local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
            self.mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",gameType)
            local GameID = AppData.get_app_and_game_name()
            self.default2dOr3d = Config.get_mj3dSetting(GameID).def3dOr2d
            self.mj2dOr3d = PlayerPrefs.GetInt(self.mj2dOr3dSetKey,self.default2dOr3d)
        else  --- 不能切换到3D  ，使用新麻将框架的2D麻将，或者使用了老框架的2D麻将
            self.default2dOr3d = 0
            self.mj2dOr3d = 0
        end
        -------------------------End----------------------------
    end
    --self:refreshVolumes()

    if intentData.tableBackgroundSprite then
        self.ImageBg1.transform.parent.gameObject:SetActive(true)
        self.ImageBg1.sprite = intentData.tableBackgroundSprite
    else
        self.ImageBg1.transform.parent.gameObject:SetActive(false)
    end

    if intentData.tableBackgroundSprite2 then
        self.ImageBg2.transform.parent.gameObject:SetActive(true)
        self.ImageBg2.sprite = intentData.tableBackgroundSprite2
    else
        self.ImageBg2.transform.parent.gameObject:SetActive(false)
    end

    if intentData.tableBackgroundSprite3 then
        self.ImageBg3.transform.parent.gameObject:SetActive(true)
        self.ImageBg3.sprite = intentData.tableBackgroundSprite3
    else
        self.ImageBg3.transform.parent.gameObject:SetActive(false)
    end

    if intentData.tableBackground2d then
        self.Image2d.transform.parent.gameObject:SetActive(true)
        self.Image2d.sprite = intentData.tableBackground2d
    else
        self.Image2d.transform.parent.gameObject:SetActive(false)
    end

    if intentData.tableBackground3d then
        self.Image3d.transform.parent.gameObject:SetActive(true)
        self.Image3d.sprite = intentData.tableBackground3d
    else
        self.Image3d.transform.parent.gameObject:SetActive(false)
    end

    self.toggleGuoHu.gameObject:SetActive(intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_MJ")
    --self.toggleFast.gameObject:SetActive(intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_MJ")
    local switcher = GetComponentWithPath(self.root, "Center/Buttons/Panel", "UIStateSwitcher")
    local othersActive = self:GetOtherWindowActiveState();

    if intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_PHZ" then
        if not self.zipaiInit then
            local zipai =  ModuleCache.ViewUtil.InitViewGameObject("paohuzi/module/setting/zipai.prefab", "ZiPai", 1); --同步加载
            zipai.name = "ZiPai"
            zipai.transform.parent =self._parent

            self.goZiPai       = GetComponentWithPath(self.root, "Center/ZiPai", ComponentTypeName.Transform).gameObject
            self.togleZiPaiMen = {}
            self.togleZiPaiMen[1] = GetComponentWithPath(self.root, "Center/ZiPai/Size/ToggleGroup/Toggle1", ComponentTypeName.Toggle)
            self.togleZiPaiMen[2] = GetComponentWithPath(self.root, "Center/ZiPai/Size/ToggleGroup/Toggle2", ComponentTypeName.Toggle)
            self.togleZiPaiMen[3] = GetComponentWithPath(self.root, "Center/ZiPai/Size/ToggleGroup/Toggle3", ComponentTypeName.Toggle)
            self.goZiPai_ZheDang       = GetComponentWithPath(self.root, "Center/ZiPai/ZheDang", ComponentTypeName.Button)

            self.zipaiInit = true
        end


        switcher:SwitchState("ZiPai");
    elseif intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_MJ" then
        if not self.majiangInit then
            local packageName = self.majiangPackageName or 'majiang'
            local majong =  ModuleCache.ViewUtil.InitViewGameObject( packageName .. "/module/setting/majong.prefab", "MaJong", 1); --同步加载
            majong.name = "MaJong"
            majong.transform.parent = self._parent

            self.goMajongSetting     = GetComponentWithPath(self.root, "Center/MaJong", ComponentTypeName.Transform).gameObject

            self.greenPanel          = GetComponentWithPath(self.root, "Center/MaJong/Size/MaJongShow/Green", ComponentTypeName.Transform).gameObject
            self.yellowPanel         = GetComponentWithPath(self.root, "Center/MaJong/Size/MaJongShow/Yellow", ComponentTypeName.Transform).gameObject
            self.type3TextPanel          = GetComponentWithPath(self.root, "Center/MaJong/Size/MaJongShow/Type3", ComponentTypeName.Transform).gameObject

            self.smallPanel          = GetComponentWithPath(self.root, "Center/MaJong/Color/MajongShow/Small", ComponentTypeName.Transform).gameObject
            self.bigPanel            = GetComponentWithPath(self.root, "Center/MaJong/Color/MajongShow/Big", ComponentTypeName.Transform).gameObject
            self.type3ColorPanel     = GetComponentWithPath(self.root, "Center/MaJong/Color/MajongShow/Type3", ComponentTypeName.Transform).gameObject

            self.togleMajongTextBig  = GetComponentWithPath(self.root, "Center/MaJong/Size/ToggleGroup/ToggleBig", ComponentTypeName.Toggle)
            self.togleMajongTextSmall= GetComponentWithPath(self.root, "Center/MaJong/Size/ToggleGroup/ToggleSmall", ComponentTypeName.Toggle)
            self.togleMajongTextType3 = GetComponentWithPath(self.root, "Center/MaJong/Size/ToggleGroup/ToggleType3", ComponentTypeName.Toggle)

            self.togleMajongGreen    = GetComponentWithPath(self.root, "Center/MaJong/Color/ToggleGroup/ToggleGreen", ComponentTypeName.Toggle)
            self.togleMajongYellow   = GetComponentWithPath(self.root, "Center/MaJong/Color/ToggleGroup/ToggleYellow", ComponentTypeName.Toggle)
            self.togleMajongType3 = GetComponentWithPath(self.root, "Center/MaJong/Color/ToggleGroup/ToggleType3", ComponentTypeName.Toggle)

            self.mj3dSkin = GetComponentWithPath(self.root, "Center/MaJong/3dSkin", ComponentTypeName.Transform).gameObject
            self.sizeObj = GetComponentWithPath(self.root, "Center/MaJong/Size", ComponentTypeName.Transform).gameObject
            self.colorObj = GetComponentWithPath(self.root, "Center/MaJong/Color", ComponentTypeName.Transform).gameObject

            self.mj3dSkinType1 = GetComponentWithPath(self.root, "Center/MaJong/3dSkin/ToggleGroup/ToggleType1", ComponentTypeName.Toggle)
            self.mj3dSkinType2 = GetComponentWithPath(self.root, "Center/MaJong/3dSkin/ToggleGroup/ToggleType2", ComponentTypeName.Toggle)
            self.mj3dSkinType3 = GetComponentWithPath(self.root, "Center/MaJong/3dSkin/ToggleGroup/ToggleType3", ComponentTypeName.Toggle)

            if self.mj2dOr3d == 1 then
                self.mj3dSkin:SetActive(true)
                self.sizeObj:SetActive(false)
                self.colorObj:SetActive(false)
            else
                self.mj3dSkin:SetActive(false)
                self.sizeObj:SetActive(true)
                self.colorObj:SetActive(true)
            end

            --self.mj2dOr3d
            self.majiangInit = true
        end

        switcher:SwitchState("Majong");
        self:ShowWindow(2)
        self:SetLabel(2)
    elseif intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_RUNFAST" then
        if not self.RunfastInit then
            local Runfast =  ModuleCache.ViewUtil.InitViewGameObject("runfast/module/roomsetting/runfastpokersetting.prefab", "RunfastPokerSetting", 1); --同步加载
            Runfast.name = "Runfast"
            Runfast.transform.parent = self._parent
            self.GoRunfast = GetComponentWithPath(self.root, "Center/"..Runfast.name, ComponentTypeName.Transform).gameObject
            self.togleCount_Runfast = 2
            self.togleRunfastArr = {}
            for i = 1, self.togleCount_Runfast do
                self.togleRunfastArr[i] = GetComponentWithPath(self.root, "Center/"..Runfast.name.."/Size/ToggleGroup/Toggle"..i, ComponentTypeName.Toggle)
            end
            self.RunfastInit = true
        end
        switcher:SwitchState("RUNFAST")
        self:ShowWindow(6)
        self:SetLabel(6)
    elseif(intentData.openCommonPokerFaceChange)then
        switcher:SwitchState("CommonPoker")
        self:SetLabel(7)
        self:ShowWindow(7)
        self:RefreshCommonPokerFaceSettingPanel()
    end

    if(not othersActive) then
        if( intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_MJ") then
            if not self.majiangInit then
                local packageName = self.majiangPackageName or 'majiang'
                local majong =  ModuleCache.ViewUtil.InitViewGameObject(packageName .. "/module/setting/majong.prefab", "MaJong", 1); --同步加载
                majong.name = "MaJong"
                majong.transform.parent = self._parent

                self.goMajongSetting     = GetComponentWithPath(self.root, "Center/MaJong", ComponentTypeName.Transform).gameObject

                self.greenPanel          = GetComponentWithPath(self.root, "Center/MaJong/Size/MaJongShow/Green", ComponentTypeName.Transform).gameObject
                self.yellowPanel         = GetComponentWithPath(self.root, "Center/MaJong/Size/MaJongShow/Yellow", ComponentTypeName.Transform).gameObject
                self.type3TextPanel          = GetComponentWithPath(self.root, "Center/MaJong/Size/MaJongShow/Type3", ComponentTypeName.Transform).gameObject

                self.smallPanel          = GetComponentWithPath(self.root, "Center/MaJong/Color/MajongShow/Small", ComponentTypeName.Transform).gameObject
                self.bigPanel            = GetComponentWithPath(self.root, "Center/MaJong/Color/MajongShow/Big", ComponentTypeName.Transform).gameObject
                self.type3ColorPanel       = GetComponentWithPath(self.root, "Center/MaJong/Color/MajongShow/Type3", ComponentTypeName.Transform).gameObject

                self.togleMajongTextBig  = GetComponentWithPath(self.root, "Center/MaJong/Size/ToggleGroup/ToggleBig", ComponentTypeName.Toggle)
                self.togleMajongTextSmall= GetComponentWithPath(self.root, "Center/MaJong/Size/ToggleGroup/ToggleSmall", ComponentTypeName.Toggle)
                self.togleMajongTextType3 = GetComponentWithPath(self.root, "Center/MaJong/Size/ToggleGroup/ToggleType3", ComponentTypeName.Toggle)

                self.togleMajongGreen    = GetComponentWithPath(self.root, "Center/MaJong/Color/ToggleGroup/ToggleGreen", ComponentTypeName.Toggle)
                self.togleMajongYellow   = GetComponentWithPath(self.root, "Center/MaJong/Color/ToggleGroup/ToggleYellow", ComponentTypeName.Toggle)
                self.togleMajongType3 = GetComponentWithPath(self.root, "Center/MaJong/Color/ToggleGroup/ToggleType3", ComponentTypeName.Toggle)

                self.mj3dSkin = GetComponentWithPath(self.root, "Center/MaJong/3dSkin", ComponentTypeName.Transform).gameObject
                self.sizeObj = GetComponentWithPath(self.root, "Center/MaJong/Size", ComponentTypeName.Transform).gameObject
                self.colorObj = GetComponentWithPath(self.root, "Center/MaJong/Color", ComponentTypeName.Transform).gameObject

                self.mj3dSkinType1 = GetComponentWithPath(self.root, "Center/MaJong/3dSkin/ToggleGroup/ToggleType1", ComponentTypeName.Toggle)
                self.mj3dSkinType2 = GetComponentWithPath(self.root, "Center/MaJong/3dSkin/ToggleGroup/ToggleType2", ComponentTypeName.Toggle)

                if self.mj2dOr3d == 1 then
                    self.mj3dSkin:SetActive(true)
                    self.sizeObj:SetActive(false)
                    self.colorObj:SetActive(false)
                else
                    self.mj3dSkin:SetActive(false)
                    self.sizeObj:SetActive(true)
                    self.colorObj:SetActive(true)
                end

                self.majiangInit = true
            end

            switcher:SwitchState("Majong");
            self:ShowWindow(1)
            self:SetLabel(1)
        elseif intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_PHZ" then
            if not self.zipaiInit then
                local zipai =  ModuleCache.ViewUtil.InitViewGameObject("paohuzi/module/setting/zipai.prefab", "ZiPai", 1); --同步加载
                zipai.name = "ZiPai"
                zipai.transform.parent =self._parent

                self.goZiPai       = GetComponentWithPath(self.root, "Center/ZiPai", ComponentTypeName.Transform).gameObject
                self.togleZiPaiMen = {}
                self.togleZiPaiMen[1] = GetComponentWithPath(self.root, "Center/ZiPai/Size/ToggleGroup/Toggle1", ComponentTypeName.Toggle)
                self.togleZiPaiMen[2] = GetComponentWithPath(self.root, "Center/ZiPai/Size/ToggleGroup/Toggle2", ComponentTypeName.Toggle)
                self.togleZiPaiMen[3] = GetComponentWithPath(self.root, "Center/ZiPai/Size/ToggleGroup/Toggle3", ComponentTypeName.Toggle)
                self.goZiPai_ZheDang       = GetComponentWithPath(self.root, "Center/ZiPai/ZheDang", ComponentTypeName.Button)

                self.zipaiInit = true
            end

            switcher:SwitchState("ZiPai");
        elseif intentData.tableBackgroundSpriteSetName == "RoomSetting_TableBackground_Name_RUNFAST" then
            if not self.RunfastInit then
                local Runfast =  ModuleCache.ViewUtil.InitViewGameObject("runfast/module/roomsetting/runfastpokersetting.prefab", "RunfastPokerSetting", 1); --同步加载
                Runfast.name = "Runfast"
                Runfast.transform.parent = self._parent
                self.GoRunfast = GetComponentWithPath(self.root, "Center/"..Runfast.name, ComponentTypeName.Transform).gameObject
                self.togleCount_Runfast = 2
                self.togleRunfastArr = {}
                for i = 1, self.togleCount_Runfast do
                    self.togleRunfastArr[i] = GetComponentWithPath(self.root, "Center/"..Runfast.name.."/Size/ToggleGroup/Toggle"..i, ComponentTypeName.Toggle)
                end
                self.RunfastInit = true
            end
            switcher:SwitchState("RUNFAST")
            self:ShowWindow(6)
            self:SetLabel(6)
        elseif(intentData.openCommonPokerFaceChange)then
            switcher:SwitchState("CommonPoker")
            self:SetLabel(7)
            self:ShowWindow(7)
            self:RefreshCommonPokerFaceSettingPanel()
        else
            switcher:SwitchState("Poker");
            self:SetLabel(2)
        end
    end

    ModuleCache.ComponentUtil.SafeSetActive(self.buttonExitRoom.gameObject, intentData.canExitRoom)
    ModuleCache.ComponentUtil.SafeSetActive(self.buttonDissolveRoom.gameObject, intentData.canDissolveRoom)
    local tableBg = self.mjBgSet or PlayerPrefs.GetInt(intentData.tableBackgroundSpriteSetName, 1)

    if self.intentData.is3D == 1 then
        local GameID = AppData.get_app_and_game_name()
        local def3dOr2d = Config.get_mj3dSetting(GameID).def3dOr2d
        local gameType = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId).wanfaType
        local mj2dOr3dSetKey = string.format("%s_MJ2dOr3d",gameType)
        self.mj2dOr3d = PlayerPrefs.GetInt(mj2dOr3dSetKey, def3dOr2d)
    else
        self.mj2dOr3d = 0
    end

    self:refresh_bg(tableBg)
    self:refresh_mj_3d_or_2d(self.mj2dOr3d)

    self:refresh_zipai()

    self:refreshVolumes()
end

function RoomSettingView:GetOtherWindowActiveState()
    if(self.goGameSetting.activeSelf) then
        return true;
    elseif(self.goSoundSetting.activeSelf) then
        return true;
    elseif(self.goBackgroundSetting.activeSelf) then
        return true;
    end
    return false;
end

function RoomSettingView:refresh_bg(tableBg,is3D)
    ComponentUtil.SafeSetActive(self.goBgSelect1, tableBg == 1)
    ComponentUtil.SafeSetActive(self.goBgSelect2, tableBg == 2)
    ComponentUtil.SafeSetActive(self.goBgSelect3, tableBg == 3)
end

function RoomSettingView:refresh_mj_3d_or_2d(is3D)
    if 0 == is3D then
        local pos = self.ButtonBg1.transform.localPosition
        pos.y = 12
        self.ButtonBg1.transform.localPosition = pos
        pos = self.ButtonBg2.transform.localPosition
        pos.y = 12
        self.ButtonBg2.transform.localPosition = pos
        pos = self.ButtonBg3.transform.localPosition
        pos.y = 12
        self.ButtonBg3.transform.localPosition = pos
    end
    ComponentUtil.SafeSetActive(self.Button2d, is3D ~= 0)
    ComponentUtil.SafeSetActive(self.Button3d, is3D ~= 0)
    ComponentUtil.SafeSetActive(self.goSelect3d, is3D == 1)
    ComponentUtil.SafeSetActive(self.goSelect2d, is3D == 2)
end

function RoomSettingView:refresh_zipai()
    if self.intentData.tableBackgroundSpriteSetName ~= "RoomSetting_TableBackground_Name_PHZ" then
        return
    end

    local zipai = PlayerPrefs.GetInt('ZP_ZPPaiLei' .. AppData.Game_Name, 1)

    for i=1,#self.togleZiPaiMen do
        self.togleZiPaiMen[i].isOn = false

    end
    self.togleZiPaiMen[zipai].isOn = true


end

function RoomSettingView:refreshVolumes()
    self:refresh_music_volume()
    self:refresh_sound_volume()
    self:refresh_location_settting()
    self:refresh_recommend_out_pai_setting()
    self:refresh_Majong()
    self:refresh_YuYin()
    self:refresh_ZhenDong()
    self:refresh_guo_hu()
    self:refresh_fast()
    self:refreshAppdata()
end

function RoomSettingView:refresh_Majong()
    if(not self.curTableData or self.intentData.tableBackgroundSpriteSetName ~= "RoomSetting_TableBackground_Name_MJ") then
        return
    end

    self:SetMajongColor(self.mjColorSet)
    self:SetMajongTextSize(self.mjScaleSet)

    self.togleMajongGreen.isOn = self.mjColorSet == 0;
    self.togleMajongYellow.isOn = self.mjColorSet == 1;
    self.togleMajongType3.isOn =  self.mjColorSet == 2;

    self.togleMajongTextBig.isOn = self.mjScaleSet == 0;
    self.togleMajongTextSmall.isOn = self.mjScaleSet == 1;
    self.togleMajongTextType3.isOn = self.mjScaleSet == 2;

    self.mj3dSkinType1.isOn = self.mj3dSkinType == 1;
    self.mj3dSkinType2.isOn = self.mj3dSkinType == 2;
    self.mj3dSkinType3.isOn = self.mj3dSkinType == 3;

end

function RoomSettingView:refresh_fast()
    local openFast = (PlayerPrefs.GetInt("openFast", 1) == 1)
    local select = GetComponentWithPath(self.toggleFast.gameObject, "select", ComponentTypeName.Transform).gameObject
    local unselect = GetComponentWithPath(self.toggleFast.gameObject, "unselect", ComponentTypeName.Transform).gameObject
    self.toggleFast.isOn = not openFast
    ComponentUtil.SafeSetActive(select, not openFast)
    ComponentUtil.SafeSetActive(unselect, openFast)
end

function RoomSettingView:refresh_guo_hu()
    local openGuoHu = (PlayerPrefs.GetInt("openGuoHu", self.intentData.defGuoHu or 1) == 1)
    local select = GetComponentWithPath(self.toggleGuoHu.gameObject, "select", ComponentTypeName.Transform).gameObject
    local unselect = GetComponentWithPath(self.toggleGuoHu.gameObject, "unselect", ComponentTypeName.Transform).gameObject
    --self.toggleGuoHu.isOn = not openGuoHu
    ComponentUtil.SafeSetActive(select, not openGuoHu)
    ComponentUtil.SafeSetActive(unselect, openGuoHu)
end

function RoomSettingView:refresh_YuYin()
    local value = PlayerPrefs.GetFloat("openVoiceVolume", 0.5)
    local select = GetComponentWithPath(self.toggleYuYin.gameObject, "select", ComponentTypeName.Transform).gameObject
    local unselect = GetComponentWithPath(self.toggleYuYin.gameObject, "unselect", ComponentTypeName.Transform).gameObject
    self.toggleYuYin.isOn = (value <= 0)
    ComponentUtil.SafeSetActive(select, value <= 0)
    ComponentUtil.SafeSetActive(unselect, value > 0)
    self.sliderYuYin.value = value
end

function RoomSettingView:refresh_ZhenDong()
    local openShake = (PlayerPrefs.GetInt("openShake", 1) == 1)
    local select = GetComponentWithPath(self.toggleZhenDong.gameObject, "select", ComponentTypeName.Transform).gameObject
    local unselect = GetComponentWithPath(self.toggleZhenDong.gameObject, "unselect", ComponentTypeName.Transform).gameObject
    self.toggleZhenDong.isOn = not openShake
    ComponentUtil.SafeSetActive(select, not openShake)
    ComponentUtil.SafeSetActive(unselect, openShake)
end

function RoomSettingView:refresh_music_volume()
    local value = ModuleCache.SoundManager.get_music_volume()
    local select = GetComponentWithPath(self.toggleMusic.gameObject, "select", ComponentTypeName.Transform).gameObject
    local unselect = GetComponentWithPath(self.toggleMusic.gameObject, "unselect", ComponentTypeName.Transform).gameObject
    self.toggleMusic.isOn = (value <= 0)
    ComponentUtil.SafeSetActive(select, value <= 0)
    ComponentUtil.SafeSetActive(unselect, value > 0)
    self.sliderMusic.value = value;
end

---刷新方言设置相关设置
function RoomSettingView:refresh_location_settting()
    local isOpen = self.intentData.isOpenLocationSetting
    local defSetting = self.intentData.defLocationSetting  or 0
    if isOpen then
        self.goLocationSetting:SetActive(true)
        local key = string.format("%s_LocationSetting",ModuleCache.GameManager.curGameId)
        local curLocationSetting = PlayerPrefs.GetInt(key,defSetting)
        if 0 ==  curLocationSetting then
            self.commonCheckMark:SetActive(true)
            self.locationCheckMark:SetActive(false)
        elseif 1 == curLocationSetting then
            self.commonCheckMark:SetActive(false)
            self.locationCheckMark:SetActive(true)
        end
    else
        self.goLocationSetting:SetActive(false)
    end
end

---刷新推荐出牌相关控件状态
function RoomSettingView:refresh_recommend_out_pai_setting()
    local isOpen = self.intentData.IsOpenRecommendOutPaiSetting
    local defSetting = self.intentData.defRecommendOutPaiSetting  or 0
    if isOpen then
        self.goRecommendOutPaiSetting:SetActive(true)
        local key = string.format("%s_IsRecommendOutPai",ModuleCache.GameManager.curGameId)
        local curRecommendOutPaiSetting = PlayerPrefs.GetInt(key,defSetting)
        if 0 ==  curRecommendOutPaiSetting then
            self.RecommendNoCheckMark:SetActive(true)
            self.RecommendOkCheckMark:SetActive(false)
        elseif 1 == curRecommendOutPaiSetting then
            self.RecommendNoCheckMark:SetActive(false)
            self.RecommendOkCheckMark:SetActive(true)
        end
    else
        self.goRecommendOutPaiSetting:SetActive(false)
    end
end

function RoomSettingView:refresh_sound_volume()
    local value = ModuleCache.SoundManager.get_sound_volume()
    local select = GetComponentWithPath(self.toggleSound.gameObject, "select", ComponentTypeName.Transform).gameObject
    local unselect = GetComponentWithPath(self.toggleSound.gameObject, "unselect", ComponentTypeName.Transform).gameObject
    self.toggleSound.isOn = (value <= 0)
    ComponentUtil.SafeSetActive(select, value <= 0)
    ComponentUtil.SafeSetActive(unselect, value > 0)
    self.sliderSound.value = value;
end

function RoomSettingView:refreshAppdata()
    self.textAppLv.text = "App版本号: "..ModuleCache.GameManager.appVersion
    self.textResLv.text = "Res版本号: "..(ModuleCache.GameManager.appAssetVersion or "0")
    self.packageResLv.text = "Package版本号: "..(ModuleCache.GameManager.get_cur_package_version() or "0")
end

function RoomSettingView:HideAllWindows()
    if self.goMajongSetting then
        self.goMajongSetting:SetActive(false);
    end

    self.goSoundSetting:SetActive(false)
    self.goGameSetting:SetActive(false)
    self.goBackgroundSetting:SetActive(false)
    if self.goZiPai then
        self.goZiPai:SetActive(false)
    end
    if(self.GoRunfast) then
        self.GoRunfast:SetActive(false)
    end
    if(self.goCommonPokerFaceSetting) then
        self.goCommonPokerFaceSetting:SetActive(false)
    end
end

function RoomSettingView:ShowWindow(index)
    self:HideAllWindows();
    if(index == 1) then
        if self.goMajongSetting then
            self.goMajongSetting:SetActive(true);
        end
    elseif(index == 2) then
        self.goBackgroundSetting:SetActive(true)
    elseif(index == 3) then
        self.goSoundSetting:SetActive(true)
        self:InitSoundSilders();
    elseif(index == 4) then
        self.goGameSetting:SetActive(true)
    elseif(index == 5) then
        if self.goZiPai then
            self.goZiPai:SetActive(true)
        end
    elseif(index == 6) then
        if(self.GoRunfast) then
            self.GoRunfast:SetActive(true)
        end
    elseif(index == 7) then
        if(self.goCommonPokerFaceSetting) then
            self.goCommonPokerFaceSetting:SetActive(true)
        end
    end
    print(" index : "..tostring(index))
end

function RoomSettingView:InitSoundSilders()
    local soundValue = ModuleCache.SoundManager.get_sound_volume();
    local musicValue = ModuleCache.SoundManager.get_music_volume();
    self.sliderMusic.value = musicValue;
    self.sliderSound.value = soundValue;
end

function RoomSettingView:ResetAllLabels()
    self.labelMajiang:SetActive(false);
    self.labelBackground:SetActive(false);
    self.labelMusic:SetActive(false);
    self.labelGame:SetActive(false);
    if self.labelZiPai then
        self.labelZiPai:SetActive(false);
    end
    self.labelRunfast:SetActive(false);
    self.labelCommonPoker:SetActive(false);
end

function RoomSettingView:SetLabel(index)
    self:ResetAllLabels();
    if(index == 1) then
        self.labelMajiang:SetActive(true);
    elseif(index == 2) then
        self.labelBackground:SetActive(true);
    elseif(index == 3) then
        self.labelMusic:SetActive(true);
    elseif(index == 4) then
        self.labelGame:SetActive(true);
    elseif(index == 5) then
        self.labelZiPai:SetActive(true);
    elseif(index == 6) then
        self.labelRunfast:SetActive(true);
    elseif(index == 7) then
        self.labelCommonPoker:SetActive(true);
    end
end

function RoomSettingView:SetMajongColor(colorIndex) -- 0为绿色 1为黄色 --2为Type3
    if(colorIndex == 0) then
        self.greenPanel:SetActive(true)
        self.yellowPanel:SetActive(false)
        self.type3TextPanel:SetActive(false)
    elseif(colorIndex == 1) then
        self.greenPanel:SetActive(false)
        self.yellowPanel:SetActive(true)
        self.type3TextPanel:SetActive(false)
    elseif(colorIndex == 2) then
        self.greenPanel:SetActive(false)
        self.yellowPanel:SetActive(false)
        self.type3TextPanel:SetActive(true)
    end
end

function RoomSettingView:SetMajongTextSize(sizeIndex) --0为大，1为小 2为Type3
    if(sizeIndex == 1) then
        self.smallPanel:SetActive(true)
        self.bigPanel:SetActive(false)
        self.type3ColorPanel:SetActive(false)
    elseif(sizeIndex == 0) then
        self.smallPanel:SetActive(false)
        self.bigPanel:SetActive(true)
        self.type3ColorPanel:SetActive(false)
    elseif (sizeIndex == 2) then
        self.smallPanel:SetActive(false)
        self.bigPanel:SetActive(false)
        self.type3ColorPanel:SetActive(true)
    end
end

function RoomSettingView:SetRunfastInitToggle(StyleType)
    local togleRunfastArr = self.togleRunfastArr
    for i = 1, #togleRunfastArr do
        local togle = togleRunfastArr[i]
        togle.isOn = (i == StyleType)
    end
end

function RoomSettingView:RefreshCommonPokerFaceSettingPanel(toggle)
    local intentData = self.intentData
    if(intentData.openCommonPokerFaceChange)then
        local commonPokerSettingData = intentData.commonPokerSettingData
        local lastAssetHolder = commonPokerSettingData.lastAssetHolder
        if(not self.commponPokerSettingHolderList)then
            self.commponPokerSettingHolderList = {}
            local codeList = commonPokerSettingData.pokerCodeList
            local get_sprite_by_code_fun = commonPokerSettingData.get_sprite_by_code_fun
            local on_change_poker_face = commonPokerSettingData.on_change_poker_face
            local pokerDataList = commonPokerSettingData.pokerDataList
            for i = 1, #pokerDataList do
                local pokerData = pokerDataList[i]
                local holder = {}
                holder.on_change_poker_face = on_change_poker_face
                holder.assetHolder = pokerData.assetHolder
                ComponentUtil.SafeSetActive(self.toggle_commonPokerFace.gameObject, false)
                local go = ModuleCache.ComponentUtil.InstantiateLocal(self.toggle_commonPokerFace.gameObject, self.toggle_commonPokerFace.transform.parent.gameObject)
                ComponentUtil.SafeSetActive(go, true)
                holder.root = go
                holder.toggle = go:GetComponent(ComponentTypeName.Toggle)
                local goPoker = GetComponentWithPath(go, "Pokers/Poker", ComponentTypeName.Transform).gameObject
                ComponentUtil.SafeSetActive(goPoker, false)
                for j = 1, #codeList do
                    local tmpGoPoker = ModuleCache.ComponentUtil.InstantiateLocal(goPoker, goPoker.transform.parent.gameObject)
                    ComponentUtil.SafeSetActive(tmpGoPoker, true)
                    local image = GetComponentWithPath(tmpGoPoker, "Image", ComponentTypeName.Image)
                    image.sprite = get_sprite_by_code_fun(codeList[j], holder.assetHolder)
                end
                table.insert(self.commponPokerSettingHolderList, holder)
            end
        end
        for i = 1, #self.commponPokerSettingHolderList do
            local holder = self.commponPokerSettingHolderList[i]
            if(not toggle and lastAssetHolder and lastAssetHolder == holder.assetHolder)then
                toggle = holder.toggle
            end
            holder.toggle.isOn = holder.toggle == toggle
        end
        if(not toggle)then
            local holder = self.commponPokerSettingHolderList[1]
            if(holder)then
                holder.toggle.isOn = true
            end
        end
    end
end

return RoomSettingView