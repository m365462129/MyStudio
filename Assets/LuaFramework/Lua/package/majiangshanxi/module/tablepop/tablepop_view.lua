-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TablePopView = Class('tablePopView', View)

local ModuleCache = ModuleCache
local TableUtil = TableUtil
local AppData = AppData
local TableManager = TableManager
local Config = Config
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local PlayerPrefs = UnityEngine.PlayerPrefs

function TablePopView:initialize(...)
    -- 初始View
    View.initialize(self, "majiangshanxi/module/tablepop/henanmj_tablepop.prefab", "HeNanMJ_TablePop", 0)

    local config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))
    local wanfaType = Config.GetWanfaIdx(TableManager.curTableData.ruleJsonInfo.GameType)
    if(wanfaType > #config.createRoomTable) then
        wanfaType = 1
    end
    self.ConfigData = config.createRoomTable[wanfaType]
    
    self.pao = GetComponentWithPath(self.root, "Bottom/Child/SelectPao", ComponentTypeName.Transform).gameObject
    self.paoList = TableUtil.get_all_child(self.pao)
    self.UIStateSwitcher_maiMa = GetComponentWithPath(self.root,"Bottom/Child/MaiMa","UIStateSwitcher")
    self.maiMaKaWuXing = GetComponentWithPath(self.root, "Bottom/Child/MaiMaKaWuXing", ComponentTypeName.Transform).gameObject
    self.selects = {}
    for i = 1, #self.paoList do
        local buttonImage = GetComponentWithPath(self.paoList[i],"Image",ComponentTypeName.RectTransform)
        local isSelectObj = GetComponentWithPath(self.paoList[i],"IsSelect",ComponentTypeName.RectTransform).gameObject
        local selectObj = GetComponentWithPath(self.paoList[i],"IsSelect/Select",ComponentTypeName.RectTransform).gameObject
        table.insert(self.selects, {image = buttonImage, isSelect = isSelectObj, select = selectObj})
    end
end

function TablePopView:kawuxing_piao()
    local selectIndex = PlayerPrefs.GetInt(string.format("%s_kawuxing_piao",TableManager.curTableData.ruleJsonInfo.GameType), 1)
    TableManager.curTableData.kaWuXingPiao = selectIndex - 1
    for i = 1, #self.selects do
        self.selects[i].isSelect:SetActive(true)
        self.selects[i].image.sizeDelta = Vector2.New(223, self.selects[i].image.sizeDelta.y)
        self.selects[i].select:SetActive(i == selectIndex)
    end
end

function TablePopView:refresh_view(maiMaData)
    self.curTableData = TableManager.curTableData
    self.wanfaName = TableUtil.get_rule_name(self.curTableData.Rule or self.curTableData.videoData.gamerule)
    ComponentUtil.SafeSetActive(self.UIStateSwitcher_maiMa.gameObject, false)
    ComponentUtil.SafeSetActive(self.maiMaKaWuXing, false)
    ComponentUtil.SafeSetActive(self.pao, false)
    if not maiMaData then
        self.pao:SetActive(true)
        TableUtil.hide_childs(self.pao)
        local titleStrs = string.split(self.ConfigData.PaoTitles, "|")
        for i = 1, #titleStrs do
            self.paoList[i]:SetActive(true)
            ---@type UnityEngine.UI.Text
            local text = GetComponentWithPath(self.paoList[i], "Text", ComponentTypeName.Text)
            text.text = titleStrs[i]
        end
        if(self.ConfigData.isKaWuXing) then
            self:kawuxing_piao()
        end
    else
        self:refresh_mj_color_scale()
        if(self.ConfigData.isKaWuXing) then
            ComponentUtil.SafeSetActive(self.maiMaKaWuXing, true)
            self.kwxTitle = GetComponentWithPath(self.maiMaKaWuXing, "Image/ImageText", ComponentTypeName.Text)
            self.kwxScore = GetComponentWithPath(self.maiMaKaWuXing, "TextScore", "TextWrap")
            self.kwxGrid = GetComponentWithPath(self.maiMaKaWuXing, "Grid", ComponentTypeName.Transform).gameObject
            self.kwxChilds = TableUtil.get_all_child(self.kwxGrid)
            local huIndex = self:get_hu_player(maiMaData)
            local playerId = TableManager.curTableData.seatUserIdInfo[(huIndex - 1) .. ""]
            if(huIndex - 1 ~= TableManager.curTableData.SeatID) then
                self.canMaiMa = false
                self.kwxTitle.text = ""
                TableUtil.download_seat_detail_info(playerId, nil, function(playerInfo)
                    self.kwxTitle.text = Util.filterPlayerName(playerInfo.playerName, 10) .. "正在买马！"
                end)
            else
                self.canMaiMa = true
                self.kwxTitle.text = "请选择一个买马的牌！"
            end
            self.kwxScore.text = "+0f"
            for i = 1, #self.kwxChilds do
                local mj = self.kwxChilds[i]
                if(i <= #maiMaData.MaiMa) then
                    mj:SetActive(true)
                    TableUtil.set_mj_bg(2, mj, self.mjColorSet)
                    GetComponentWithPath(mj, "HighLight", ComponentTypeName.Transform).gameObject:SetActive(false)
                else
                    mj:SetActive(false)
                end
            end
        else
            ComponentUtil.SafeSetActive(self.UIStateSwitcher_maiMa.gameObject, true)
            local maNum = 6
            if(#maiMaData.MaiMa <= 6) then
                maNum = 6
            elseif(#maiMaData.MaiMa > 6 and #maiMaData.MaiMa <= 12) then
                maNum = 12
            elseif(#maiMaData.MaiMa > 12 and #maiMaData.MaiMa <= 20) then
                maNum = 20
            elseif(#maiMaData.MaiMa > 20) then
                maNum = 56
            end
            if(maNum == 6 and self.ConfigData.pnShowResult) then
                maNum = 12
            end
            self.UIStateSwitcher_maiMa:SwitchState(maNum .. "Ma")
            self.MaiMaCopyParent = GetComponentWithPath(self.root, string.format("Bottom/Child/MaiMa/vector_%sma",maNum), ComponentTypeName.Transform).gameObject
            self.MaiMaCopyItem = GetComponentWithPath(self.MaiMaCopyParent, "MaiMaPai", ComponentTypeName.Transform).gameObject
            ---@type UnityEngine.UI.Image
            self.maiMaTitleSprite = GetComponentWithPath(self.root, "Bottom/Child/MaiMa/bg/Image (1)/icon_6ma", ComponentTypeName.Image)
            self.maiMaTitleSprite1 = GetComponentWithPath(self.root, "Bottom/Child/MaiMa/bg/Image (1)/icon_12ma", ComponentTypeName.Image)
            self.maiMaTitleSH = GetComponentWithPath(self.root, "Bottom", "SpriteHolder")
            if(self.ConfigData.isChangSha) then
                self.maiMaTitleSprite.sprite = self.maiMaTitleSH:FindSpriteByName("2")
                self.maiMaTitleSprite1.sprite = self.maiMaTitleSH:FindSpriteByName("2")
            elseif(self.ConfigData.isLiuZhou) then
                self.maiMaTitleSprite.sprite = self.maiMaTitleSH:FindSpriteByName("3")
                self.maiMaTitleSprite1.sprite = self.maiMaTitleSH:FindSpriteByName("3")
            else
                self.maiMaTitleSprite.sprite = self.maiMaTitleSH:FindSpriteByName("1")
                self.maiMaTitleSprite1.sprite = self.maiMaTitleSH:FindSpriteByName("1")
            end
            self.maiMaTitleSprite:SetNativeSize()
            self.maiMaTitleSprite1:SetNativeSize()
            self:Init_MaiMaPanel(maiMaData)
        end
    end
   
end

function TablePopView:Init_MaiMaPanel(data) 
    self.contents = TableUtil.get_all_child(self.MaiMaCopyParent)
    local item = {}
    item[1] = nil
    for i=2,#self.contents do
        UnityEngine.GameObject.Destroy(self.contents[i])
        item[i] = nil
    end

    local maiMa = data.MaiMa
    if(self.ConfigData.isLiuZhou) then
        maiMa = data.Player[TableManager.curTableData.SeatID + 1].MaPai
        data = data.Player[TableManager.curTableData.SeatID + 1]
    end

    for i=1, #maiMa do
        item[i] = TableUtil.clone(self.MaiMaCopyItem,self.MaiMaCopyParent,UnityEngine.Vector3.zero)
        local anim = ModuleCache.ComponentManager.GetComponent(item[i].gameObject,"UnityEngine.Animator")
        TableUtil.set_mj(maiMa[i], item[i], self.mjScaleSet)
        TableUtil.set_mj_bg(1, item[i], self.mjColorSet)
        self:subscibe_time_event(i*0.1, false, 0):OnComplete(function(t)
             anim.enabled = true
             for j=1, #data.ZhongMa do
                local idx = data.ZhongMa[j]+1
                if idx == i then
                     self:subscibe_time_event(0.05, false, 0):OnComplete(function(t)
                        GetComponentWithPath(item[idx], "HighLight", ComponentTypeName.Transform).gameObject:SetActive(true)
                    end)
                end
            end
        end)
    end
end

function TablePopView:refresh_mj_color_scale()
    local config = ModuleCache.PlayModeUtil.get_playmodel_data(TableManager.curTableData.ruleJsonInfo.GameType)
    local defaultScale = 0
    local defaultColor = 0
    if(config.cardTheame) then
        local strs = string.split(config.cardTheame, "|")
        defaultScale = tonumber(strs[1])
        defaultColor = tonumber(strs[2])
    end
    self.mjScaleSet = PlayerPrefs.GetInt(string.format("%s_MJScale",TableManager.curTableData.ruleJsonInfo.GameType), defaultScale)
    self.mjColorSet = PlayerPrefs.GetInt(string.format("%s_MJColor",TableManager.curTableData.ruleJsonInfo.GameType), defaultColor)
end

function TablePopView:get_hu_player(gameState)
    for i = 1, #gameState.Player do
        if(#gameState.Player[i].HuPai > 0) then
            return i
        end
    end
    return 1
end

return TablePopView