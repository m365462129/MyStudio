-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
---@class RuleSettingView
local RuleSettingView = Class('ruleSettingView', View)

local ModuleCache = ModuleCache
local GameObject = UnityEngine.GameObject
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local PlayerPrefsManager = ModuleCache.PlayerPrefsManager
local yOffset = 75 ---纵轴的偏移
local xTotalOffset = 276 * 2 --- 一行的最大摆放宽度 依据这个进行均分 除以rowNum
local bgBeginHeight = 77 ---开始的高度 根据这个开始累加偏移
local addOffset = 10 ---偏移间隔
local tagOffset = 84 ---左边玩法按钮的偏移
local AppData = AppData
local Config = Config
local TableUtil = TableUtil
local Vector2 = Vector2
local Vector3 = Vector3
local string = string
local math = math
local table = table
local Color = Color
local color1 = Color.New(177/255,58/255,31/255,1) --- 选项选中的颜色值
local color2 = Color.New(122/255,88/255,68/255,1) --- 选项未选中的颜色值

function RuleSettingView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/rulesetting/henanmj_rulesetting.prefab", "HeNanMJ_RuleSetting", 1)

    local gameRoot = GameObject.Find("GameRoot")
    self.uicamera = GetComponentWithPath(gameRoot, "Game/UIRoot/UICamera", "UnityEngine.Camera")
    self.clickTipObj = ModuleCache.ComponentManager.FindGameObject(self.root, "ClickTip")
    self.clickTipText = GetComponentWithPath(self.clickTipObj, "Text", ComponentTypeName.Text)
    self.buttonCreate = GetComponentWithPath(self.root, "Bottom/Child/Create/CreateRoom", ComponentTypeName.Button)
    self.costText = GetComponentWithPath(self.root, "Bottom/Child/Create/CreateRoom/tag/roomCardNumText", ComponentTypeName.Text)
    self.scrollView = GetComponentWithPath(self.root, "Top/Panels/Scroll View", ComponentTypeName.ScrollRect)
    self.cloneParent = GetComponentWithPath(self.root, "Clone", ComponentTypeName.Transform).gameObject
    self.BgParent = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content", ComponentTypeName.RectTransform)
    self.tagParent = GetComponentWithPath(self.root, "Top/TagBtns/Scroll View/Viewport/Content", ComponentTypeName.RectTransform)
    self.copyTagBtn = ModuleCache.ComponentManager.FindGameObject(self.root, "Top/TagBtns/Scroll View/Viewport/Content/CopyBtn")
    self.copyBgItem = ModuleCache.ComponentManager.FindGameObject(self.root, "Top/Panels/Scroll View/Viewport/Content/BgItem")
    self.copyGroupItem = ModuleCache.ComponentManager.FindGameObject(self.copyBgItem, "GroupItem")
    self.copyToggleItem = ModuleCache.ComponentManager.FindGameObject(self.copyBgItem, "GroupItem/CopyItem")

    self.tagBtnBeginPos = self.copyTagBtn.transform.localPosition
    self.bgItemBeginPos = self.copyBgItem.transform.localPosition
    self.groupItemBeginPos = self.copyGroupItem.transform.localPosition
    self.toggleBeginPos = self.copyToggleItem.transform.localPosition
    TableUtil.move_clone(self.copyTagBtn, self.cloneParent)
    TableUtil.move_clone(self.copyToggleItem, self.cloneParent)
    TableUtil.move_clone(self.copyGroupItem, self.cloneParent)
    TableUtil.move_clone(self.copyBgItem, self.cloneParent)
    self.copyPayItem = ModuleCache.ComponentManager.FindGameObject(self.root, "Bottom/Child/Create/PayInfo/Toggles/CopyPayItem")
    self.payItemBeginPos = self.copyPayItem.transform.localPosition
    TableUtil.move_clone(self.copyPayItem, self.cloneParent)
    self.clones = TableUtil.get_all_child(self.cloneParent)

    self.create = GetComponentWithPath(self.root, "Bottom/Child/Create", ComponentTypeName.Transform).gameObject
    self.save = GetComponentWithPath(self.root, "Bottom/Child/Save", ComponentTypeName.Transform).gameObject

    self.createStateSwitch =GetComponentWithPath(self.root, "Bottom/Child/Create", "UIStateSwitcher")
    self.payInfoObj = ModuleCache.ComponentManager.FindGameObject(self.root, "Bottom/Child/Create/PayInfo")
    --self.textMuseumTip = GetComponentWithPath(self.root, "Bottom/Child/Create/MuseumTip", ComponentTypeName.Text)
    self.FreeCreatePayInfoObj = ModuleCache.ComponentManager.FindGameObject(self.root, "Bottom/Child/Create/FreeCreatePay")
    self.FreeCreatePayTypeTex = GetComponentWithPath(self.FreeCreatePayInfoObj, "TextSelect", ComponentTypeName.Text)


    self.saveTip = GetComponentWithPath(self.root, "Bottom/Child/Save/Tip", ComponentTypeName.Text)
    self.noticeToggle = GetComponentWithPath(self.root, "Bottom/Child/Save/ToNotice", ComponentTypeName.Toggle)
    self.payInfoTitle = GetComponentWithPath(self.root, "Bottom/Child/Create/PayInfo/TextTitle (1)", ComponentTypeName.Text)
    self.payInfoParent = ModuleCache.ComponentManager.FindGameObject(self.root, "Bottom/Child/Create/PayInfo/Toggles")
    ---金币结算相关
    self.goldSetObj = ModuleCache.ComponentManager.FindGameObject(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldSet")
    self.goldSetValText1 = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldSet/Set1/ButtonGoldSet1/Text", ComponentTypeName.Text)
    self.goldSetValText2 = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldSet/Set2/ButtonGoldSet2/Text", ComponentTypeName.Text)
    ---金币场相关
    self.goldEnterSetObj = ModuleCache.ComponentManager.FindGameObject(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldEnterSet")
    self.goldEnterSetValText1 = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldEnterSet/Set1/ButtonGoldEnterSet1/Text", ComponentTypeName.Text)
    self.goldEnterSetValText2 = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldEnterSet/Set2/ButtonGoldEnterSet2/Text", ComponentTypeName.Text)
    self.goldEnterSetValText3 = GetComponentWithPath(self.root, "Top/Panels/Scroll View/Viewport/Content/GoldEnterSet/Set3/ButtonGoldEnterSet3/Text", ComponentTypeName.Text)
end

--- 屏幕转世界坐标
function RuleSettingView:get_world_pos(screenPos, z)
    return self.uicamera:ScreenToWorldPoint(Vector3.New(screenPos.x, screenPos.y, z))
end

--TODO XLQ: 通过showType决定是否显示 showType 1普通创建房间 2 亲友圈创建房间 3 亲友圈保存
function RuleSettingView:by_showType_isActive(data)
    if not data.showType then
        return true
    end

    --data.showType 1普通创建房间 2 亲友圈创建房间 3 亲友圈保存      是否显示 1：正常创建房间   ,showType = {2,3} 表示 亲友圈 自由开房和设置 显示
    for i =1,#data.showType do
        if data.showType[i] == self.showType then
            return true
        end
    end

    return false
end

--- 显示非支付的选项 根据配置
function RuleSettingView:show_create(wanfaType, isChange,showType)
    self.enterBaseScore = 0
    self.wanfaType = wanfaType
    self:save_drop_values() --- 保存界面上的下拉框的偏好值
    self.goldSet = false
    self.goldSetObj:SetActive(false)
    self.goldEnterSet = false
    self.goldEnterSetObj:SetActive(false)
    TableUtil.hide_childs(self.tagParent.gameObject)
    local dataList = Config.get_list()
    self.tagBtnToggles = {}
    self.toggles = {}
    for i=1,#dataList do ---复制左边的玩法选项
        local tagItem = TableUtil.get_or_clone(i, "CopyBtn", self.tagParent.gameObject, self.tagBtnBeginPos - Vector3.New(0, tagOffset *(i - 1), 0), self.poorObjs, self.clones, true)
        tagItem.name = "CopyBtn_" .. i
        local retData = self:set_tag_toggles(tagItem,dataList[i].title or dataList[i].name,i .. "")
        retData.playerPrefsStr = AppData.get_url_game_name() .. "_wanfaType"
        retData.clickIndex = i
        retData.checkmark:SetActive(i == wanfaType)
    end
    self.tagParent.sizeDelta = Vector2.New(self.tagParent.sizeDelta.x, tagOffset*#dataList)
    local data = self.Config.createRoomTable[wanfaType]
    self.toggleTipTypes = {}
    self.bigShow = {} ---影响一组选项开关的列表
    self.smallShow = {} ---影响单个选项开关的列表
    self.onlyShowType = {} --TODO XLQ: (增加条件onlyShowType) 影响一组选项开关的列表 在哪种情况下受影响  1：正常房间  2：亲友圈自由开房  3：亲友圈设置  如： onlyShowType = {2,3}表示在亲友圈设置和自由开房显示，外面的房间不显示
    self.twoBgItems = {}
    self:handle_pay_toggles(data,wanfaType,isChange,showType)
    TableUtil.hide_childs(self.BgParent.gameObject, "BgItem")
    local bgOffset = 0
    local addI = 1
    --- 克隆底图 组和选项 计算偏移 每个选项添加用户偏好值用于保存 按钮勾选与未勾选做处理（文字颜色变化、控制另外的选项或组显示或隐藏 重新刷新此函数）
    for i=1,#data do
        local togglesData = data[i]
        local keyData = togglesData.tag
        local maxValidNum = keyData.maxValidNum ---控制一组按钮最多勾选多少的数量
        local minValidNum = keyData.minValidNum ---控制一组按钮最少勾选多少的数量

        -- TODO XLQ: keyData.showType = {2,3}  是否显示 1：正常创建房间   ｛2，3｝ 表示 亲友圈 自由开房和设置 显示
        if(not keyData.isPay and self:is_active(keyData) and self:by_showType_isActive(keyData) ) then ---底图 上面可以包括很多组的选项 开启有条件 函数内说明
            local bgHeight = bgBeginHeight
            local bgItem = TableUtil.get_or_clone(addI, "BgItem", self.BgParent.gameObject, self.bgItemBeginPos - Vector3.New(0, bgOffset, 0), self.poorObjs, self.clones)
            local moveNum = 3
            if(self.goldEnterSetObj.activeSelf) then
                moveNum = 2
            end
            if(addI < moveNum) then
                table.insert(self.twoBgItems, bgItem)
            end
            TableUtil.hide_childs(bgItem, "GroupItem")
            local groupOffset = 0
            local addNum = 1
            for j=1,#togglesData.list do ---选项组 里面有单选复选等
                local groupData = togglesData.list[j]
                local addHeight = 0
                local groupItem = TableUtil.get_or_clone(j, "GroupItem", bgItem, self.groupItemBeginPos - Vector3.New(0, groupOffset, 0), self.poorObjs, self.clones)
                TableUtil.hide_childs(groupItem)
                local addK = 1
                local singleToggleList = {}
                local singleToggleKeyList = {}
                local clickSingleToggle
                local validToggleList = {}
                local invalidToggleList = {}
                local rowNum = groupData.rowNum or keyData.rowNum
                for k=1,#groupData do
                    local toggleData = groupData[k]
                    if self:by_showType_isActive(toggleData) then   -- TODO XLQ: toggleData.showType = {2,3}  是否显示 1：正常创建房间   ｛2，3｝ 表示 亲友圈 自由开房和设置 显示
                        local xOffset = xTotalOffset / (rowNum - 1)
                        if(self:is_small_show(toggleData)) then --- 单个选项 每个选项都要保存用户偏好 所以都对应一个唯一偏好键值 开启有条件 函数内说明
                        local toggleItem = TableUtil.get_or_clone(addK, "CopyItem", groupItem, Vector3.New(0, 0, 0), self.poorObjs, self.clones, true)
                            toggleItem.name = string.format("%s_%s_%s", i,j,k)
                            local retData = self:set_toggle_data(toggleItem,toggleData,string.format("%s_%s_%s", i,j,k),wanfaType)
                            toggleItem.transform.localPosition = self.toggleBeginPos + Vector3.New(((addK - 1) % rowNum) * xOffset, math.floor((addK - 1) / rowNum) * -yOffset, 0)
                            local playerPrefsStr = string.format("%s_%s_value_%s_%s",AppData.Game_Name,wanfaType,addI,addNum)

                            self:set_new_show(retData, string.format("%s_%s_value_%s_%s_%s",AppData.Game_Name,wanfaType,i,j,k), isChange)
                            if(toggleData.toggleType == 1) then
                                playerPrefsStr = string.format("%s_%s_singlevalue_%s__%s",AppData.Game_Name,wanfaType,addI,j)
                                table.insert(singleToggleKeyList, retData.key)
                                table.insert(singleToggleList, retData)
                            end
                            if(keyData.bigShow) then
                                playerPrefsStr = playerPrefsStr .. keyData.bigShow
                            end
                            if(toggleData.smallShow) then
                                playerPrefsStr = playerPrefsStr .. toggleData.smallShow
                            end

                            if not retData.playerPrefsStr then
                                retData.playerPrefsStr ={}
                            end

                            retData.playerPrefsStr[showType] = playerPrefsStr..showType
                            local onValue = PlayerPrefsManager.GetInt(retData.playerPrefsStr[showType], -1)
                            retData.clickIndex = addK
                            if(toggleData.toggleType == 1) then
                                if(onValue == -1) then
                                    if(toggleData.toggleIsOn) then
                                        self:set_click_show(toggleData)
                                        clickSingleToggle = retData
                                    end
                                    self:refresh_textColor(retData, toggleData.toggleIsOn)
                                elseif(#groupData >= onValue) then
                                    if(addK == onValue) then
                                        self:set_click_show(toggleData)
                                        clickSingleToggle = retData
                                    end
                                    self:refresh_textColor(retData, addK == onValue)
                                else
                                    onValue = #groupData
                                    if(addK == onValue) then
                                        self:set_click_show(toggleData)
                                        clickSingleToggle = retData
                                    end
                                    self:refresh_textColor(retData, addK == onValue)
                                end
                            else
                                if(onValue == -1) then
                                    if(toggleData.toggleIsOn) then
                                        self:set_click_show(toggleData)
                                    end
                                    self:refresh_textColor(retData, toggleData.toggleIsOn)
                                else
                                    if(1 == onValue) then
                                        self:set_click_show(toggleData)
                                    end
                                    self:refresh_textColor(retData, 1 == onValue)
                                end
                                if(maxValidNum) then
                                    if(retData.isOn) then
                                        table.insert(validToggleList, retData)
                                    else
                                        table.insert(invalidToggleList, retData)
                                    end
                                end
                            end
                            addK = addK + 1
                            if(self.goldSet) then
                                addK = addK + 3
                                self:set_gold_data(toggleData, wanfaType)
                            end
                        end
                        addNum = addNum + 1
                    end
                end
                if(maxValidNum) then
                    self:update_valid_toggles(minValidNum, maxValidNum, validToggleList, invalidToggleList)
                end
                self:update_singleToggles(singleToggleList,singleToggleKeyList,clickSingleToggle)
                if(j == 1) then
                    addHeight = math.ceil((addK - 1)/rowNum - 1) * yOffset
                else
                    addHeight = math.ceil((addK - 1)/rowNum) * yOffset
                end
                bgHeight = bgHeight + addHeight
                if(addHeight == -yOffset) then
                    addHeight = -bgBeginHeight
                end
                if(j == 1) then
                    groupOffset = bgBeginHeight
                end
                groupOffset = groupOffset + addHeight
            end
            local bgTrans = GetComponentWithPath(bgItem, "Image", ComponentTypeName.RectTransform)
            bgTrans.sizeDelta = Vector2.New(bgTrans.sizeDelta.x, bgHeight)
            bgOffset = bgOffset + bgHeight + addOffset
            local bgText = GetComponentWithPath(bgItem, "TextTitle", ComponentTypeName.Text)
            bgText.text = keyData.togglesTile
            addI = addI + 1
        end
    end

    self.BgParent.sizeDelta = Vector2.New(self.BgParent.sizeDelta.x, bgOffset)
    ---ui层级调整 金币结算与金币场的UI是直接嵌入到选项组ui里面的 只是控制显示和隐藏
    if(self.goldSetObj.activeSelf) then
        self.goldSetObj.transform:SetAsFirstSibling()
        for i = #self.twoBgItems, 1, -1 do
            self.twoBgItems[i].transform:SetAsFirstSibling()
        end
    end
    if(self.goldEnterSetObj.activeSelf) then
        self.goldEnterSetObj.transform:SetAsFirstSibling()
        for i = #self.twoBgItems, 1, -1 do
            self.twoBgItems[i].transform:SetAsFirstSibling()
        end
    end
end

--- 设置金币结算相关数据 底分设定和入场设定
function RuleSettingView:set_gold_data(toggleData, wanfaType)
    self.goldSetObj:SetActive(true)
    local goldPrefsStr1 = string.format("goldSet1_%s_%s_%s", AppData.App_Name, AppData.Game_Name, wanfaType)---底分
    local goldPrefsStr2 = string.format("goldSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, wanfaType)---入场
    local goldSetVal1 = PlayerPrefsManager.GetInt(goldPrefsStr1, toggleData.goldSetVal1)
    local goldSetVal2 = PlayerPrefsManager.GetInt(goldPrefsStr2, math.min(goldSetVal1 * 30, 99999999))
    self.goldSetValText1.text = goldSetVal1 .. ""
    self.goldSetValText2.text = goldSetVal2 .. ""
    self.minGoldSetVal1 = toggleData.goldSetVal1
    self.minGoldSetVal2 = 0
    self.goldSet = false
end

--- 设置金币场选项相关数据 底分设定、入场设定和离场设定
function RuleSettingView:set_gold_enter_data(toggleData, wanfaType)
    self.goldEnterSetObj:SetActive(true)
    local goldEnterPrefsStr1 = string.format("goldEnterSet1_%s_%s_%s", AppData.App_Name, AppData.Game_Name, wanfaType)---底分
    local goldEnterPrefsStr2 = string.format("goldEnterSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, wanfaType)---入场
    local goldEnterPrefsStr3 = string.format("goldEnterSet3_%s_%s_%s", AppData.App_Name, AppData.Game_Name, wanfaType)---离场
    local goldEnterSetVal1 = PlayerPrefsManager.GetInt(goldEnterPrefsStr1, toggleData.minGoldEnterVal)
    local goldEnterSetVal2 = PlayerPrefsManager.GetInt(goldEnterPrefsStr2, math.min(goldEnterSetVal1 * toggleData.enterMulti, 99999999))
    local goldEnterSetVal3 = PlayerPrefsManager.GetInt(goldEnterPrefsStr3, goldEnterSetVal2)
    self.goldEnterSetValText1.text = goldEnterSetVal1 .. ""
    self.goldEnterSetValText2.text = goldEnterSetVal2 .. ""
    self.goldEnterSetValText3.text = goldEnterSetVal3 .. ""
    self.minGoldEnterSetVal = toggleData.minGoldEnterVal
    self.maxGoldEnterSetVal = toggleData.maxGoldEnterVal
    self.enterMulti = toggleData.enterMulti
    self.goldEnterSet = false
    self.enterBaseScore = goldEnterSetVal1
end

--- 底图 最上层是否被激活 shotType 1 普通创建房间 2 亲友圈创建房间 3 亲友圈保存 goldSet 金币结算或金币场 bigShow 控制整个组显示或隐藏的字段 跟bigShowType 对应
function RuleSettingView:is_active(keyData)
    local active = (self.showType == 1 and (keyData.goldSet == nil or keyData.goldSet)) or (self.showType ~= 1 and not keyData.goldSet)
    if(keyData.test) then
        return ModuleCache.GameManager.developmentMode
    end
    return (not keyData.bigShow or (keyData.bigShow and self:is_big_show(keyData))) and active
end

--- 显示 新 的标签
function RuleSettingView:is_big_new(createRoomTable, wanfaType)
    for i=1,#createRoomTable do
        local togglesData = createRoomTable[i]
        local keyData = togglesData.tag
        for j=1,#togglesData.list do
            local groupData = togglesData.list[j]
            for k=1,#groupData do
                local toggleData = groupData[k]
                local playerPrefsStr = "isNew_" .. string.format("%s_%s_value_%s_%s_%s",AppData.Game_Name,wanfaType,i,j,k)
                if(keyData.isPay) then
                    playerPrefsStr = "isNew_" .. string.format("%s_%s_%s_pay",AppData.Game_Name, wanfaType, k)
                end
                local value = PlayerPrefsManager.GetInt(playerPrefsStr, -1)
                if(value == -1 and toggleData.isNew) then
                    return true
                end
            end
        end
    end
    return false
end

--- 设置 新 标签的显示
function RuleSettingView:set_new_show(retData, playerPrefsStr, isChange)
    local isNewPrefsStr = "isNew_" .. playerPrefsStr
    local isNewValue = PlayerPrefsManager.GetInt(isNewPrefsStr, -1)
    if(isChange and isNewValue == -1 and retData.toggleData.isNew) then
        retData.newTick:SetActive(true)
    else
        retData.newTick:SetActive(false)
    end
    PlayerPrefsManager.SetInt(isNewPrefsStr, 1)
end

--- 选项上配置了clickBigShow 那么此选项控制组的隐藏或显示 对应被控制的加bigShow
--- 配置了clickSmallShow 那么此选项控制单个选项的隐藏或显示 对应被控制的加smallShow
function RuleSettingView:set_click_show(toggleData)
    if(toggleData.clickBigShow) then --- 点击影响整个分类显示不显示
        table.insert(self.bigShow, toggleData.clickBigShow)

        if toggleData.onlyShowType then
            table.insert( self.onlyShowType, toggleData.onlyShowType)
        end
    end
    if(toggleData.clickSmallShow) then --- 点击只影响一个toggle
        table.insert(self.smallShow, toggleData.clickSmallShow)
    end
    if(toggleData.clickTipType and string.find(toggleData.clickTipType, "_") ~= nil) then
        table.insert(self.toggleTipTypes, toggleData.clickTipType)
    end
    if(toggleData.goldSet) then
        self.goldSet = true
    end
    if(toggleData.goldEnterSet) then
        self.goldEnterSet = true
    end
end

--- 设置支付选项
function RuleSettingView:handle_pay_toggles(data,wanfaType,isChange,showType)
    TableUtil.hide_childs(self.payInfoParent)
    self.payToggles = {}
    for i=1,#data do
        local togglesData = data[i]
        local keyData = togglesData.tag
        if(keyData.isPay and self:is_active(keyData)) then
            self.payInfoTitle.text = keyData.togglesTile
            for j=1,#togglesData.list do
                local groupData = togglesData.list[j]
                local singleToggleKeyList = {}
                local clickSingleToggle
                for k=1,#groupData do
                    local xOffset = xTotalOffset / (keyData.rowNum - 1)
                    local toggleData = groupData[k]
                    local toggleItem = TableUtil.get_or_clone(k, "CopyPayItem", self.payInfoParent, Vector3.New(0, 0, 0), self.poorObjs, self.clones, true)
                    toggleItem.name = string.format("%s_%s_%s", i,j,k)
                    local showPayXOffset = 0
                    if(keyData.togglesTile == "") then
                        showPayXOffset = 120
                    end
                    local retData = self:set_toggle_data(toggleItem,toggleData,string.format("%s_%s_%s", i,j,k),wanfaType)
                    toggleItem.transform.localPosition = self.payItemBeginPos + Vector3.New(((k - 1) % keyData.rowNum) * xOffset - showPayXOffset, 0, 0)
                    table.insert(self.payToggles, retData)
                    table.insert(singleToggleKeyList, retData.key)
                    local playerPrefsStr = string.format("%s_%s_pay",AppData.Game_Name, wanfaType)
                    self:set_new_show(retData, string.format("%s_%s_%s_pay",AppData.Game_Name, wanfaType, k), isChange)
                    if not retData.playerPrefsStr then
                        retData.playerPrefsStr ={}
                    end
                    retData.playerPrefsStr[showType] = playerPrefsStr..showType
                    local onValue = PlayerPrefsManager.GetInt(retData.playerPrefsStr[showType], -1)
                    retData.clickIndex = k
                    if(onValue == -1) then
                        if(toggleData.toggleIsOn) then
                            clickSingleToggle = retData
                            self:set_click_show(toggleData)
                        end
                        self:refresh_textColor(retData, toggleData.toggleIsOn)
                    else
                        if(k == onValue) then
                            clickSingleToggle = retData
                            self:set_click_show(toggleData)
                        end
                        self:refresh_textColor(retData, k == onValue)
                    end
                    if(self.goldEnterSet) then
                        self:set_gold_enter_data(toggleData, wanfaType)
                    end
                    if(retData.drop and toggleData.dropDown) then
                        self.payDropVal = retData.drop.value
                        self.payDrop = retData.drop
                    end
                end
                self:update_singleToggles(self.payToggles,singleToggleKeyList,clickSingleToggle)
            end
        end
    end
end

--- 设置左边玩法选项相关
function RuleSettingView:set_tag_toggles(tagItem,title,toggleKey)
    local retData = self.tagBtnToggles[toggleKey]
    if(not retData) then
        retData = {}
        retData.checkmark = ModuleCache.ComponentManager.FindGameObject(tagItem, "Checkmark")
        retData.title1 = GetComponentWithPath(tagItem, "Checkmark/Label", ComponentTypeName.Text)
        retData.title2 = GetComponentWithPath(tagItem, "Background/Label", ComponentTypeName.Text)
        self.tagBtnToggles[toggleKey] = retData
    end
    retData.title1.text = title
    retData.title2.text = title
    return retData
end

--- 设置单个选项 单复选框样式 下拉框 标题
function RuleSettingView:set_toggle_data(toggleItem,toggleData,toggleKey,wanfaType)
    local retData = self.toggles[toggleKey]
    if(not retData) then
        retData = {}
        retData.uiState = GetComponentWithPath(toggleItem, "Toggle", "UIStateSwitcher")
        ---@type UnityEngine.UI.Text
        retData.toggleText = GetComponentWithPath(toggleItem, "Toggle/Select/TextSelect", ComponentTypeName.Text)
        retData.newTick = ModuleCache.ComponentManager.FindGameObject(retData.toggleText.gameObject, "btn")
        ---@type UnityEngine.UI.Dropdown
        retData.drop = GetComponentWithPath(retData.toggleText.gameObject, "drop/Dropdown", ComponentTypeName.Dropdown)
        ---@type UnityEngine.RectTransform
        retData.dropRect = GetComponentWithPath(retData.toggleText.gameObject, "drop/Dropdown/Template", ComponentTypeName.RectTransform)
        ---@type UnityEngine.UI.Text
        retData.dropText = GetComponentWithPath(retData.toggleText.gameObject, "drop/Dropdown/Label", ComponentTypeName.Text)
        self.toggles[toggleKey] = retData
    end
    if(retData.drop) then
        retData.drop.transform.parent.gameObject:SetActive(toggleData.dropDown ~= nil)
        if(toggleData.dropDown) then
            local splitStrs = string.split(toggleData.dropDown, ",")
            local splitTitles
            if(toggleData.dropDownTitles) then
                splitTitles = string.split(toggleData.dropDownTitles, ",")
            end
            retData.drop.transform.sizeDelta = Vector2(toggleData.dropDownWidth or 106,retData.drop.transform.sizeDelta.y)
            retData.dropRect.sizeDelta = Vector2(retData.dropRect.sizeDelta.x,65*#splitStrs)
            retData.drop.options:Clear()
            for i = 1, #splitStrs do
                local title = splitStrs[i] .. (toggleData.dropAddStr or "倍")
                if(splitTitles) then
                    title = splitTitles[i]
                end
                local optionData = UnityEngine.UI.Dropdown.OptionData(title)
                retData.drop.options:Add(optionData)
            end
            retData.dropKey = string.format("dropdown_%s_%s_%s_%s_%s",toggleKey,toggleData.dropDown,AppData.App_Name,AppData.Game_Name,wanfaType)
            local dropValue = PlayerPrefsManager.GetInt(retData.dropKey, toggleData.dropDefault)
            retData.dropText.text = splitStrs[dropValue + 1] .. (toggleData.dropAddStr or "倍")
            if(splitTitles) then
                retData.dropText.text = splitTitles[dropValue + 1]
            end
            retData.drop.value = dropValue
        end
    end
    retData.toggleItem = toggleItem
    retData.key = toggleKey
    retData.toggleData = toggleData
    local switchStr =  ""
    if(toggleData.toggleType == 1) then
        if(not toggleData.disable) then
            switchStr = "1"
        else
            switchStr = "1_Disable"
        end
    else
        if(not toggleData.disable) then
            switchStr = "2"
        else
            switchStr = "2_Disable"
        end
    end
    retData.uiState:SwitchState(switchStr)
    retData.checkmark = ModuleCache.ComponentManager.FindGameObject(toggleItem, "Toggle/" .. switchStr .. "/Background/Checkmark")
    retData.clickWight = GetComponentWithPath(toggleItem, "Toggle/" .. switchStr .. "/Wight", ComponentTypeName.RectTransform)
    retData.toggleText.text = toggleData.toggleTitle
    retData.clickWight.sizeDelta = Vector2.New(85+retData.toggleText.preferredWidth,retData.clickWight.sizeDelta.y)
    return retData
end

--- 显示选项的tips 按下显示
function RuleSettingView:show_click_tip(toggleObj)
    local retData = self.toggles[toggleObj.transform.parent.parent.name]
    local clickTip = self:get_click_tip(retData.toggleData)
    if(clickTip and clickTip ~= "") then
        return clickTip
    end
    return nil
end

--- 获取选项点击的tips 按下显示
function RuleSettingView:get_click_tip(toggleData)
    if(toggleData.clickTipType and not string.find(toggleData.clickTipType, "_")) then
        for i=1,#self.toggleTipTypes do
            if(string.find(self.toggleTipTypes[i],toggleData.clickTipType) ~= nil) then
                local tips = string.split(toggleData.clickTip, "|")
                local toggleTipTypes = string.split(self.toggleTipTypes[i], "_")
                return tips[tonumber(toggleTipTypes[2])]
            end
        end
    else
        return toggleData.clickTip
    end
end

--- 单个选项是否显示 smallShowType为1 代表控制的选项勾选自己就勾选 为2 代表控制的选项勾选自己就隐藏 反之亦然
function RuleSettingView:is_small_show(toggleData)
    local have = (toggleData.smallShow == nil)
    if(toggleData.smallShow) then
        for i=1,#self.smallShow do
            if(self.smallShow[i] == toggleData.smallShow) then
                have = true
            end
        end
    end
    if(toggleData.moreBaseScore) then ---通过大于底分控制显示 金币场创建房间专用
        have = have and self.enterBaseScore >= toggleData.moreBaseScore
    end
    if(toggleData.lessBaseScore) then ---通过小于底分控制显示 金币场创建房间专用
        have = have and self.enterBaseScore < toggleData.lessBaseScore
    end
    if(not toggleData.smallShow) then
        return have
    else
        return ((have and toggleData.smallShowType == 1) or (not have and toggleData.smallShowType == 2))
    end
end

--- 单个组是否显示 bigShowType为1 代表控制的选项勾选自己就显示 为2 代表控制的选项勾选自己就隐藏 反之亦然
function RuleSettingView:is_big_show(keyData)
    local haveBigShow = false
    for i=1,#self.bigShow do
        if(self.bigShow[i] == keyData.bigShow) then

            if self.onlyShowType[i] then-- 单组是否显示 增加条件 onlyShowType = {2,3} 表示在亲友圈自由开房和设置 显示，正常创建房间不显示
                for j =1,#self.onlyShowType[i] do
                    if self.onlyShowType[i][j] == self.showType then
                        haveBigShow = true
                    end
                end
            else
                haveBigShow = true
            end
        end

        if(haveBigShow and (not keyData.bigShowType or keyData.bigShowType == 1)) then
            return true
        end
    end
    if(not haveBigShow and keyData.bigShowType == 2) then
        return true
    end
    return false
end

function RuleSettingView:modify_round_num()
    
end

function RuleSettingView:get_round_data(wanfaType,museumData)
    return self:get_round_data_toggle(wanfaType,museumData)
end

--- 获取局数
function RuleSettingView:get_round_data_toggle(wanfaType,museumData)
    local round = 0
    local rule = self:get_payinfo_data(wanfaType)
    local ruleTable = ModuleCache.Json.decode(rule)

    --TODO XLQ:跑胡子房间设置没有局数（用胡息结算代替局数）
    if ruleTable.roundCount == 1 and ruleTable.JieSuanHuXi then
        ruleTable.roundCount = ruleTable.JieSuanHuXi
    end

    if(ruleTable.roundCount) then
        round = ruleTable.roundCount
        return round
    end
    if(self.toggles["1_1_1"].isOn) then
        round = 4
    elseif(self.toggles["1_1_2"].isOn) then
        round = 8
    elseif(self.toggles["1_1_3"].isOn) then
        round = 16
    end
    return round
end

--- 获取玩家数
function RuleSettingView:get_player_count(wanfaType)
    local rule = self:get_payinfo_data(wanfaType)
    local ruleTable = ModuleCache.Json.decode(rule)
    return ruleTable.playerCount or ruleTable.PlayerNum
end

--- 根据选项勾选情况获取拼凑的规则json
function RuleSettingView:get_payinfo_data(wanfaType, museumData)
    local wanfaTypeName = Config.get_wanfaType_name(wanfaType)
    local json = "{\"GameType\":\"" .. wanfaTypeName .. "\","
    local configData = self.Config.createRoomTable[wanfaType]
    if(configData.configJson) then
        json = configData.configJson
    end
    if(configData.addJson) then
        json = json .. configData.addJson
    end

    if self.toggles ~= nil then
        for k,v in pairs(self.toggles) do
            local toggleData = v.toggleData
            local toggle = v
            if(toggleData.json and toggleData.json ~= "" and (string.find(toggleData.json, "PayType") == nil and string.find(toggleData.json, "payType") == nil)) then
                if(true) then
                    if(toggle.isOn) then
                        if(toggleData.dropDown) then
                            local dropDownStrs = string.split(toggleData.dropDown, ",")
                            local dropVal = tonumber(dropDownStrs[toggle.drop.value + 1])
                            json = json .. string.format("\"%s\":%s,",toggleData.json,dropVal)
                        else
                            json = json .. toggleData.json .. ","
                        end
                        if(toggleData.addJson) then
                            json = json .. toggleData.addJson .. ","
                        end
                    elseif(toggleData.toggleType == 2) then
                        local jsonTables = string.split(toggleData.json, ",")
                        for k=1,#jsonTables do
                            local jsonStrs = string.split(jsonTables[k], ":")
                            if(jsonStrs[2] == "true") then
                                json = json .. jsonStrs[1] .. ":false,"
                            elseif(jsonStrs[2] == "false") then
                                json = json .. jsonStrs[1] .. ":true,"
                            elseif(toggleData.inverseJson) then
                                json = json .. toggleData.inverseJson .. ","
                            end
                        end
                    end
                end
            end
        end
    end

    if(self.create.activeSelf and self.payInfoObj.activeSelf) then
        for i=1,#self.payToggles do
            local toggleData = self.payToggles[i].toggleData
            local toggle = self.payToggles[i]
            if(toggleData.json and toggleData.json ~= "") then
                if(toggle.isOn) then
                    if(toggleData.dropDown) then
                        local dropDownStrs = string.split(toggleData.dropDown, ",")
                        local dropVal = tonumber(dropDownStrs[toggle.drop.value + 1])
                        json = json .. string.format("\"%s\":%s,",toggleData.json,dropVal)
                    else
                        json = json .. toggleData.json .. ","
                    end
                end
            end
        end
    else
        if museumData then
            json = json .. "\"PayType\":"..museumData.payType..","
        else
            json = json .. "\"PayType\":-1,"
        end
    end
    local gameName = Config.get_create_name(wanfaType)
    if(self.goldSetObj.activeSelf) then
        json = json .. string.format("\"baseScore\":%s,\"minJoinCoin\":%s,", tonumber(self.goldSetValText1.text), tonumber(self.goldSetValText2.text))
    elseif(self.goldEnterSetObj.activeSelf) then
        json = json .. string.format("\"baseScore\":%s,\"minJoinCoin\":%s,\"minForceExitCoin\":%s,",
            tonumber(self.goldEnterSetValText1.text), tonumber(self.goldEnterSetValText2.text), tonumber(self.goldEnterSetValText3.text))
    end
    json = json .. string.format("\"gameName\":\"%s\",\"GameID\":\"%s\"}",gameName, AppData.get_url_game_name())
    if(configData.callback) then
        local ruleTable = ModuleCache.Json.decode(json)
        ruleTable = configData.callback(ruleTable)
        return ModuleCache.Json.encode(ruleTable)
    end
    return json
end

--- 刷新价格 亲友圈保存界面不需要
function RuleSettingView:refresh_prices(showType, wanfaType)
    if(showType and showType < 3) then
        self:refresh_price(showType, wanfaType)
    end
end

--- 刷新价格
function RuleSettingView:refresh_price(showType, wanfaType)
    if(self.goldEnterSetObj.activeSelf) then
        self.needDiam = 0
        self.createStateSwitch:SwitchState("NotShowPayNum")
        return
    end
    local playerCount = self:get_player_count(wanfaType)
    local roundCount = self:get_round_data(wanfaType)
    if(#self.payToggles == 0) then -- 没有支付方式
        self.needDiam = 0
        return
    end
    local rule = self:get_payinfo_data(wanfaType)
    local ruleTable = ModuleCache.Json.decode(rule)

    local configData = self.Config.createRoomTable[wanfaType]
    local payType = ruleTable.payType
    if(payType) then
        if(payType == 0) then
            payType = 1
        elseif(payType == 1) then
            payType = 0
        end
    end
    if(configData.caculPrice) then
        self.needDiam = configData.caculPrice(roundCount, playerCount, ruleTable.PayType or payType, ruleTable.bankerType, ruleTable)
    else
        self.needDiam = Config.caculate_price(roundCount, playerCount, ruleTable.PayType or payType, ruleTable)
    end

    if self.needDiam then
        self.costText.text ="x"..self.needDiam
    end

    if(showType == 1) then
        self.createStateSwitch:SwitchState("ShowPayNum")
    end
end

--- 刷新标题文字颜色 选项勾选或隐藏时 以及下拉框的变化
function RuleSettingView:refresh_textColor(retData, isOn)
    if(isOn) then
        retData.toggleText.color = color1
    else
        retData.toggleText.color = color2
    end
    retData.checkmark:SetActive(isOn)

    retData.isOn = isOn
    if(retData.drop) then
        retData.drop.interactable = isOn
        if(isOn) then
            retData.dropText.color = color1
        else
            retData.dropText.color = color2
        end
    end
end

--- 更新单选框的数据  用于控制指定一起的单选
function RuleSettingView:update_singleToggles(toggles, toggleKeys, clickToggle)
    for i=1,#toggles do
        toggles[i].checkList = toggleKeys
        toggles[i].clickToggle = clickToggle
    end
end

--- 点击单选框更新
function RuleSettingView:click_singleToggles(toggles, toggleKeys, clickToggle)
    for i=1,#toggleKeys do
        local retData = toggles[toggleKeys[i]]

        if retData then
            retData.clickToggle = clickToggle
        else
            print(toggleKeys[i],"------click_singleToggles----------",retData)
        end
    end
end

--- 点击一个选项
function RuleSettingView:click_toggle(retData, showType, wanfaType)
    local refreshPrice = false
    local refreshToggle

    if(retData.toggleData.toggleType == 1) then
        if(retData.clickToggle ~= retData) then
            self:refresh_textColor(retData.clickToggle, false)
            refreshToggle = retData.clickToggle
            self:click_singleToggles(self.toggles, retData.checkList,retData)
            self:refresh_textColor(retData, true)
            PlayerPrefsManager.SetInt(retData.playerPrefsStr[showType], retData.clickIndex)
            refreshPrice = true
        end
    else
        self:refresh_textColor(retData, not retData.isOn)
        if(retData.isOn) then
            PlayerPrefsManager.SetInt(retData.playerPrefsStr[showType], 1)
        else
            PlayerPrefsManager.SetInt(retData.playerPrefsStr[showType], 0)
        end
    end
    if(retData.toggleData.clickBigShow or retData.toggleData.clickSmallShow or retData.toggleData.clickTipType or retData.toggleData.refreshUI
        or (refreshToggle and (refreshToggle.toggleData.clickBigShow or refreshToggle.toggleData.clickSmallShow or refreshToggle.toggleData.clickTipType))) then
        self:show_create(wanfaType,false,self.showType)
        self:refresh_prices(showType, wanfaType)
    elseif(refreshPrice) then
        self:refresh_prices(showType, wanfaType)
    end
end

--- 点击玩法选项按钮
function RuleSettingView:click_tag_toggle(retData, showType, wanfaType)
    PlayerPrefsManager.SetInt(retData.playerPrefsStr, retData.clickIndex)
    self:show_create(wanfaType,false, showType)
    self:refresh_prices(showType, wanfaType)
    if showType ~= 2 then
        if self.needDiam == 0 and showType == 1 then
            self.createStateSwitch:SwitchState("NotShowPayNum")
        elseif(showType < 3) then
            self.createStateSwitch:SwitchState("ShowPayNum")
        end
    end
end

--- 保存下拉框偏好值
function RuleSettingView:save_drop_values()
    if(not self.toggles) then
        return
    end
    for k,v in pairs(self.toggles) do
        local toggleData = v.toggleData
        local toggle = v
        if(toggleData.dropDown) then
            PlayerPrefsManager.SetInt(toggle.dropKey,toggle.drop.value)
        end
    end
end

--- 根据一组最大勾选数和最小勾选数更新整个组的选项
function RuleSettingView:update_valid_toggles(minNum, maxNum, validToggleList, invalidToggleList)
    for i = 1, #invalidToggleList do
        local toggle = invalidToggleList[i]
        if(#validToggleList >= maxNum) then
            toggle.uiState:SwitchState("2_Disable")
            toggle.checkmark = ModuleCache.ComponentManager.FindGameObject(toggle.toggleItem, "Toggle/2_Disable/Background/Checkmark")
            toggle.checkmark:SetActive(false)
        else
            toggle.uiState:SwitchState("2")
        end
    end
    for i = 1, #validToggleList do
        local toggle = validToggleList[i]
        if(#validToggleList <= minNum) then
            toggle.uiState:SwitchState("2_Disable")
            toggle.checkmark = ModuleCache.ComponentManager.FindGameObject(toggle.toggleItem, "Toggle/2_Disable/Background/Checkmark")
            toggle.checkmark:SetActive(true)
        end
    end
end

function RuleSettingView:on_destroy()
    self:save_drop_values()
end

function RuleSettingView:on_update()
    if(not self.payDrop or self.showType ~= 1 or self.goldEnterSetObj.activeSelf) then
        return
    end
    if(self.payDrop.value ~= self.payDropVal) then
        self:refresh_prices(self.showType, self.wanfaType)
        self.payDropVal = self.payDrop.value
    end
end

return RuleSettingView