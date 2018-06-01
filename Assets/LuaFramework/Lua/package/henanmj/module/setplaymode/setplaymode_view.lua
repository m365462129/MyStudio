-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local SetPlayModeView = Class('setPlayModeView', View)

local ModuleCache = ModuleCache
local TableUtil = TableUtil

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

function SetPlayModeView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/setplaymode/henanmj_windowsetplaymode.prefab", "HeNanMJ_WindowSetPlayMode", 1)
    View.set_1080p(self)

    self.dic = {}
    self.dic["江苏省"]      = "苏"
    self.dic["安徽省"]       = "皖"
    self.dic["河南省"]       = "豫"
    self.dic["湖南省"]       = "湘"
    self.dic["湖北省"]       = "鄂"
    self.dic["广东省"]       = "粤"
    self.dic["广西省"]       = "桂"
    self.dic["贵州省"]       = "贵"
    self.dic["云南省"]       = "云"
    self.dic["陕西省"]       = "陕"
    self.dic["新疆省"]       = "新"
    self.dic["北京市"]       = "京"
    self.dic["天津市"]       = "津"
    self.dic["上海市"]       = "沪"
    self.dic["重庆市"]       = "渝"
    self.dic["河北省"]       = "冀"
    self.dic["山西省"]       = "晋"
    self.dic["辽宁省"]       = "辽"
    self.dic["吉林省"]       = "吉"
    self.dic["黑龙江省"]     = "黑"
    self.dic["浙江省"]       = "浙"
    self.dic["福建省"]       = "闽"
    self.dic["江西省"]       = "赣"
    self.dic["山东省"]       = "鲁"
    self.dic["四川省"]       = "川"
    self.dic["甘肃省"]       = "甘"
    self.dic["青海省"]       = "青"
    self.dic["西藏省"]       = "藏"
    self.dic["内蒙古省"]     = "蒙"
    self.dic["宁夏省"]       = "宁"
    self.dic["香港"]         = "港"
    self.dic["澳门"]         = "澳"


    self.uiState   = GetComponentWithPath(self.root, "Big", "UIStateSwitcher")
    self.bigPanel  = GetComponentWithPath(self.root, "Big", ComponentTypeName.Transform).gameObject
    self.smallPanel  = GetComponentWithPath(self.root, "Small", ComponentTypeName.Transform).gameObject

    self.firstTitle = GetComponentWithPath(self.bigPanel, "Title/First", ComponentTypeName.Transform).gameObject
    self.normolTitle = GetComponentWithPath(self.bigPanel, "Title/Normol", ComponentTypeName.Transform).gameObject

    self.normolPanel = GetComponentWithPath(self.bigPanel, "Normol", ComponentTypeName.Transform).gameObject
    self.firstlPanel = GetComponentWithPath(self.bigPanel, "First", ComponentTypeName.Transform).gameObject

    self.firstScroll  = GetComponentWithPath(self.bigPanel, "First/Center/rightScrollView",ComponentTypeName.ScrollRect)
    self.firstContent  = GetComponentWithPath(self.bigPanel, "First/Center/rightScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject
    self.firstCloneObj = GetComponentWithPath(self.bigPanel, "First/Center/ItemPrefabHolder/Item", ComponentTypeName.Transform).gameObject

    self.btnSug = GetComponentWithPath(self.root, "Big/Title/Normol/Button1", ComponentTypeName.Button)
    self.btnMore = GetComponentWithPath(self.root, "Big/Title/Normol/Button2", ComponentTypeName.Button)
    self.img1 = GetComponentWithPath(self.root, "Big/Title/Normol/Button1/Image", ComponentTypeName.Transform).gameObject
    self.img2 = GetComponentWithPath(self.root, "Big/Title/Normol/Button2/Image", ComponentTypeName.Transform).gameObject

    self.adContentInfo = { }
    self.adContentInfo.curIndex = 0
    self.adContentInfo.cellSize = { x = 392, y = 640 }
    self.adContentInfo.root = GetComponentWithPath(self.root, "Big/First/Left/AdContent", ComponentTypeName.Transform).gameObject
    self.adContentInfo.root:SetActive(false)
    self.adContentInfo.scrollRectAdContent = GetComponentWithPath(self.root, "Big/First/Left/AdContent/Scroll", ComponentTypeName.ScrollRect)
    self.adContentInfo.prefabItem = GetComponentWithPath(self.root, "Big/First/Left/Items/Item", ComponentTypeName.Transform).gameObject
    self.adContentInfo.prefabPageTag = GetComponentWithPath(self.root, "Big/First/Left/Items/Point", ComponentTypeName.Transform).gameObject
    self.adContentInfo.prefabPageTagParent = GetComponentWithPath(self.root, "Big/First/Left/AdContent/Tags", ComponentTypeName.Transform).gameObject

    self.systemAnnounceRoot = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "Big/First/Top/SystemAnnounce", ComponentTypeName.Transform).gameObject
    self.systemAnnounceTextTransform = self.rootTransform:Find("SystemAnnounce/Image/Mask/Text")
    self.systemAnnounceText = ModuleCache.ComponentUtil.GetComponentWithPath(self.root, "Big/First/Top/SystemAnnounce/Image/Mask/Text", ComponentTypeName.Text)
    self.systemAnnounceRoot:SetActive(false)

    self.extensionText = GetComponentWithPath(self.root, "Big/First/Bottom/BtnCopyEx/Text", ComponentTypeName.Text)
    self.backgroud = GetComponentWithPath(self.root, "Big/First/Backgroud/Panel/windowBg3", ComponentTypeName.Image)

    self.btnCopyExObj = GetComponentWithPath(self.root, "Big/First/Bottom/BtnCopyEx", ComponentTypeName.Transform).gameObject

end

function SetPlayModeView:on_view_init() 
end

function SetPlayModeView:resetFirst()
    local contents = TableUtil.get_all_child(self.firstContent)
    for i=1,7 do
        ModuleCache.ComponentUtil.SafeSetActive(contents[i], false)
    end

end

function SetPlayModeView:showFirstView(showData, index)
    local isShow = index == 1
    self.showIndex = 1
    print(tostring(isShow))
    ModuleCache.ComponentUtil.SafeSetActive(self.normolPanel, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.firstlPanel, true)
    ModuleCache.ComponentUtil.SafeSetActive(self.img1, true)
    ModuleCache.ComponentUtil.SafeSetActive(self.img2, false)
    if(showData == nil) then
        return
    end

    self.curPlayModeList = showData
    --print("---------ni mamam a a   -------------")
    --print_table(self.curPlayModeList)
    local showCount = 7
    if #showData < showCount then showCount = #showData end
    local contents = TableUtil.get_all_child(self.firstContent)
    for i=1,8 do
        ModuleCache.ComponentUtil.SafeSetActive(contents[i], false)
    end
    for i=1,showCount do
        local obj = nil
        local item = {}
        obj = contents[i]
        obj.name = "btnPlayMode"..i
        item.gameObject = obj
        item.data = showData[i]
        self:fillFirst(item, i)
        ModuleCache.ComponentUtil.SafeSetActive(obj, true)
    end
    ModuleCache.ComponentUtil.SafeSetActive(contents[8], #showData > 7)
    --local sizeScrollR = ModuleCache.ComponentManager.GetComponent(self.firstScroll.gameObject, ComponentTypeName.RectTransform).rect
    --local contentHeight = #self.curPlayModeList * 95
    --if(#self.curPlayModeList % 3 ~= 0) then
    --    contentHeight = (#self.curPlayModeList+(3 - (#self.curPlayModeList % 3))) * 95
    --end
    --contentHeight = contentHeight + 20  -- top 20 padding
    --self.firstScroll.vertical = contentHeight >= sizeScrollR.height
end

function SetPlayModeView:fillFirst(item)
    local data          = item.data
    local title         = GetComponentWithPath(item.gameObject, "Name", ComponentTypeName.Text)
    local isProvince    = data.province.id == ModuleCache.GameManager.getCurProvinceId()
    local isGameId      = ModuleCache.GameManager.getCurGameId() == data.playMode.gameId

    local isbool        = (isProvince and isGameId)

    --if isbool then
    --    item.gameObject.name = "btnCurrent"
    --end

    --if isbool then
    --    print("---------------------------------")
    --    print_table(data.province)
    --    print("isProvince = "..tostring(isProvince))
    --    print("isGameId = "..tostring(isGameId))
    --    print_table(data)
    --end

    -- local spHolder   = GetComponentWithPath(item.gameObject, "Icon", "SpriteHolder")
    local img           = GetComponentWithPath(item.gameObject, "Icon", ComponentTypeName.Image)
    img.sprite          = ModuleCache.PlayModeUtil.getHeadIconRes(data.playMode,data.province.id) -- spHolder:FindSpriteByName(item.data.img)
    title.text          = data.playMode.name


    --local tag = data.type
    --if self.used then
    --    for i = 1, #self.used do
    --        if (tostring(self.used[i].provinceId) == tostring(data.province.id) and tostring(self.used[i].gameId) == tostring(data.playMode.gameId)) then
    --            tag = 10086
    --            break
    --        end
    --    end
    --end

    --local normolTip = GetComponentWithPath(item.gameObject, "Normol", ComponentTypeName.Transform).gameObject
    --local provinceTip = GetComponentWithPath(item.gameObject, "ProvinceTip", ComponentTypeName.Transform).gameObject
    self:setFirstBtnTag(item, data.type)

    local provinceS = GetComponentWithPath(item.gameObject, "Tag/Text", ComponentTypeName.Text)
    local province = ModuleCache.PlayModeUtil.getProvinceById(data.province.id)
    provinceS.text = ""
    if self.dic[province.name] then
        provinceS.text = self.dic[province.name]
    end
    --if data.type == 10086 then
    --    ModuleCache.ComponentUtil.SafeSetActive(normolTip, true)
    --    ModuleCache.ComponentUtil.SafeSetActive(provinceTip, false)
    --else
    --    local provinceText = GetComponentWithPath(item.gameObject, "ProvinceTip/Text", ComponentTypeName.Text)
    --    local province = ModuleCache.PlayModeUtil.getProvinceById(data.province.id)
    --    local provinceNameSub = string.split(province.name, "省")[1]
    --    provinceText.text = "推荐"
    --    if provinceNameSub and provinceNameSub ~= "" then
    --        provinceText.text = provinceNameSub
    --    end
    --    ModuleCache.ComponentUtil.SafeSetActive(normolTip, false)
    --    ModuleCache.ComponentUtil.SafeSetActive(provinceTip, true)
    --
    --end

end

function SetPlayModeView:setFirstBtnTag(obj,tag)
    local hotTip = GetComponentWithPath(obj.gameObject, "HotTip", ComponentTypeName.Transform).gameObject
    local suggestTip = GetComponentWithPath(obj.gameObject, "SuggestTip", ComponentTypeName.Transform).gameObject
    local normolTip = GetComponentWithPath(obj.gameObject, "Normol", ComponentTypeName.Transform).gameObject
    local testTip = GetComponentWithPath(obj.gameObject, "TestTip", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(hotTip, tag == 2)
    ModuleCache.ComponentUtil.SafeSetActive(suggestTip, tag == 1)
    ModuleCache.ComponentUtil.SafeSetActive(normolTip, tag == 10086)
    ModuleCache.ComponentUtil.SafeSetActive(testTip, tag == 3)
end

function SetPlayModeView:initLeftScrollViewList(locationList)
    -- print("Init------------------------")
    -- self.btnBack.gameObject:SetActive(ModuleCache.GameManager.curGameId ~= 0)


    self.showIndex = 2
    local usePanel = self.normolPanel
    self.usePanel = usePanel
    if(not ModuleCache.GameManager.iosAppStoreIsCheck) then
        ModuleCache.ComponentUtil.SafeSetActive(self.firstlPanel, false)
        ModuleCache.ComponentUtil.SafeSetActive(self.normolPanel, true)
        ModuleCache.ComponentUtil.SafeSetActive(self.img1, false)
        ModuleCache.ComponentUtil.SafeSetActive(self.img2, true)
        self.uiState:SwitchState("Big")
    else
        usePanel = self.smallPanel
        self.uiState:SwitchState("Small")
    end

    self.btnBack   = GetComponentWithPath(usePanel, "Center/closeBtn", ComponentTypeName.Button)
    self.provinceBtn = GetComponentWithPath(usePanel, "Center/provinceBtn", ComponentTypeName.Transform).gameObject

    ModuleCache.ComponentUtil.SafeSetActive(self.provinceBtn, true)--not ModuleCache.ModuleManager.module_is_active('henanmj','setprovince'))

    --左侧ListView
    self.scrollL   = GetComponentWithPath(usePanel, "Center/leftScrollView", ComponentTypeName.ScrollRect)
    self.contentL  = GetComponentWithPath(usePanel, "Center/leftScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject
    self.cloneObjL = GetComponentWithPath(usePanel, "Center/ItemPrefabHolder/LocationItem", ComponentTypeName.Transform).gameObject

    --右侧ListView
    self.scrollR   = GetComponentWithPath(usePanel, "Center/rightScrollView", ComponentTypeName.ScrollRect)
    self.contentR  = GetComponentWithPath(usePanel, "Center/rightScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject
    self.cloneObjR = GetComponentWithPath(usePanel, "Center/ItemPrefabHolder/PlayModeItem", ComponentTypeName.Transform).gameObject


    self.locationList = locationList
    self.contentsL = TableUtil.get_all_child(self.contentL)
    self:reset(self.contentsL)
    local curPlayModeList = nil
    if(ModuleCache.GameManager.getCurGameId() ~= 0) then
        curPlayModeList = ModuleCache.PlayModeUtil.getListByGameId(ModuleCache.GameManager.getCurGameId(), locationList)
        if(not curPlayModeList)then
            ModuleCache.GameManager.curGameId = 0
        end
    end

    for i=1,#locationList do
        if(self.locationList[i].isOpen) then
            local obj = nil
            local item = {}
            if(i<=#self.contentsL) then
                obj = self.contentsL[i]
            else
                obj = TableUtil.clone(self.cloneObjL,self.contentL,Vector3.zero)
            end
            obj.name = "toggle"..i
            ModuleCache.ComponentUtil.SafeSetActive(obj, true)  
            local toggle = ModuleCache.ComponentManager.GetComponent(obj.gameObject, ModuleCache.ComponentTypeName.Toggle)
            toggle.isOn = false
            if(ModuleCache.GameManager.getCurGameId() ~= 0) then
                toggle.isOn = self.locationList[i].name == curPlayModeList.name
            end

            if(ModuleCache.GameManager.getCurGameId() == 0 and i == 1)then
                toggle.isOn = true
            end
            item.gameObject = obj
            item.data = locationList[i] 
            self:fillItemL(item, i)
            if(toggle.isOn) then
            self:initRightScrollViewList(i) 
            end
        end
    end
    

    local sizeScrollL = ModuleCache.ComponentManager.GetComponent(self.scrollL.gameObject, ComponentTypeName.RectTransform).rect
    local contentHeight = #locationList * 44
    if(#locationList % 2 ~= 0) then
        contentHeight = (#locationList+1) * 44
    end
    -- print("sizeScrollL.height = "..sizeScrollL.height)
    -- print("contentHeight = "..contentHeight)
    self.scrollL.vertical = contentHeight >= sizeScrollL.height
    
end

function SetPlayModeView:initRightScrollViewList(index)  
    self.curPlayModeList = self.locationList[index].playModeList
    local contentsR = TableUtil.get_all_child(self.contentR)
    self:reset(contentsR)
    for i=1,#self.curPlayModeList do
        if(self.curPlayModeList[i].isOpen) then
        local obj = nil
        local item = {}
        if(i<=#contentsR) then
            obj = contentsR[i]
        else
            obj = TableUtil.clone(self.cloneObjR,self.contentR,Vector3.zero)
        end
        obj.name = "btnPlayMode"..i
        item.gameObject = obj
        item.data = self.curPlayModeList[i] 
        self:fillItemR(item, i)
        ModuleCache.ComponentUtil.SafeSetActive(obj, true)  
        end
    end
    local sizeScrollR = ModuleCache.ComponentManager.GetComponent(self.scrollR.gameObject, ComponentTypeName.RectTransform).rect
    local contentHeight = #self.curPlayModeList * 95
    if(#self.curPlayModeList % 2 ~= 0) then
        contentHeight = (#self.curPlayModeList+1) * 95
    end
    contentHeight = contentHeight + 20  -- top 20 padding
    self.scrollR.vertical = contentHeight >= sizeScrollR.height
    self.contentR.transform.localPosition = Vector3.New(0,0,0)
end

function SetPlayModeView:setBtnTag(obj,tag)
    local hotTip = GetComponentWithPath(obj.gameObject, "HotTip", ComponentTypeName.Transform).gameObject
    local suggestTip = GetComponentWithPath(obj.gameObject, "SuggestTip", ComponentTypeName.Transform).gameObject
    local testTip = GetComponentWithPath(obj.gameObject, "TestTip", ComponentTypeName.Transform).gameObject
    ModuleCache.ComponentUtil.SafeSetActive(hotTip, tag == 1)
    ModuleCache.ComponentUtil.SafeSetActive(suggestTip, tag == 2)
    ModuleCache.ComponentUtil.SafeSetActive(testTip, tag == 3)
end

function SetPlayModeView:reset(contents)
    for i=1,#contents do
        ModuleCache.ComponentUtil.SafeSetActive(contents[i], false)
    end
end

function SetPlayModeView:fillItemL(item)
    local data          = item.data
    local titleUnSelect = GetComponentWithPath(item.gameObject, "Background/Label", ComponentTypeName.Text)
    local titleSelect   = GetComponentWithPath(item.gameObject, "Checkmark/Label", ComponentTypeName.Text)

    titleSelect.text    = item.data.name
    titleUnSelect.text  = item.data.name
end

function SetPlayModeView:fillItemR(item)
    local data          = item.data
    local title         = GetComponentWithPath(item.gameObject, "Background/Label", ComponentTypeName.Text)
    local titleSelect   = GetComponentWithPath(item.gameObject, "Checkmark/Label", ComponentTypeName.Text)
    local toggle        = ModuleCache.ComponentManager.GetComponent(item.gameObject, ModuleCache.ComponentTypeName.Toggle)
    toggle.isOn         = (self.showId == data.gameId)
    -- local spHolder   = GetComponentWithPath(item.gameObject, "Icon", "SpriteHolder")
    local img           = GetComponentWithPath(item.gameObject, "Icon", ComponentTypeName.Image)
    local anim          = GetComponentWithPath(item.gameObject, "Icon", "UnityEngine.Animator")
    local imgTrans      = GetComponentWithPath(item.gameObject, "Icon", ComponentTypeName.RectTransform)
    img.sprite          = ModuleCache.PlayModeUtil.getIconRes(item.data,self.provinceId) -- spHolder:FindSpriteByName(item.data.img)
    title.text          = item.data.name
    titleSelect.text    = item.data.name
    imgTrans.anchoredPosition = Vector2.New(imgTrans.anchoredPosition.x, 20.5, 0);
    anim.enabled        = toggle.isOn

    self:setBtnTag(item.gameObject,data.tag)
end

function SetPlayModeView:getPlayMode(index)
    return self.curPlayModeList[index]
end

function SetPlayModeView:refreshPlayMode()
    --local GetComponent = ModuleCache.ComponentUtil.ComponentManager
    --local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    --local holder  = GetComponentWithPath(self.usePanel, "Background/windowBg1", "SpriteHolder")
    --local imageBg = GetComponent(holder.gameObject, ComponentTypeName.Image)
    --self:SetImageSpriteByGameId(imageBg,holder,ModuleCache.GameManager.curGameId)
    --
    --holder  = GetComponentWithPath(self.root, "Center/closeBtn", "SpriteHolder")
    --local imageCloseBtnBg = GetComponent(holder.gameObject, ComponentTypeName.Image)
    --self:SetImageSpriteByGameId(imageCloseBtnBg,holder,ModuleCache.GameManager.curGameId)
end

function SetPlayModeView:setPlayModeIsOnById(gameId,isOn,obj)
    local index = 0
    for i = 1,#self.curPlayModeList do
        if(self.curPlayModeList[i].gameId == gameId) then
            index = i
            break
        end
    end
    if(index ~= 0)then
        local item = GetComponentWithPath(self.contentR.gameObject,"btnPlayMode"..index,ModuleCache.ComponentTypeName.Toggle)
        item.isOn = isOn
    else
        self:unSelectPlayMode(obj)
    end
end

function SetPlayModeView:unSelectPlayMode(obj)
    local item = ModuleCache.ComponentManager.GetComponent(obj.gameObject, ModuleCache.ComponentTypeName.Toggle)
    if item then
        ModuleCache.ComponentUtil.SafeSetActive(obj, false)
        item.isOn = false
        ModuleCache.ComponentUtil.SafeSetActive(obj, true)
    end
end

function SetPlayModeView:startDownLoadBgImg(url)
    print("url = "..url)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, sprite)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if (self) then
                    -- self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if (not self.isDestroy) then
                self.backgroud.sprite = sprite
            end
        end
    end , nil, false)
end

function SetPlayModeView:refreshAdContent(ads)
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        self.adContentInfo.root:SetActive(false)
    else
        self.adContentInfo.root:SetActive(true)
    end
    self.adContentInfo.ads = ads
    self.adContentInfo.gameObjectAds = { }
    local len = #ads
    local x = len * self.adContentInfo.cellSize.x
    local y = self.adContentInfo.scrollRectAdContent.content.sizeDelta.y
    self.adContentInfo.scrollRectAdContent.content.sizeDelta = ModuleCache.CustomerUtil.ConvertVector2(x, y)
    self.adContentInfo.scrollRectAdContent.content.localPosition = Vector3.New(0, 0, 0)
    self.adContentInfo.pageSelectImageArray = { }

    for i = 1,#self.adContentInfo.gameObjectAds do
        self.adContentInfo.gameObjectAds[i]:SetActive(false)
    end

    print("-------------------len = "..len)

    self.adContentInfo.scrollRectAdContent.horizontal = len > 1;

    for i = 1, len do
        local item = self.adContentInfo.scrollRectAdContent.content.transform:Find("ad_item"..i)
        if item == nil then
            item = ModuleCache.ComponentUtil.InstantiateLocal(self.adContentInfo.prefabItem, self.adContentInfo.scrollRectAdContent.content.gameObject)
        else
            item = item.gameObject
        end
        item.name = "ad_item"..i
        local x =(i - 1) * self.adContentInfo.cellSize.x
        ModuleCache.TransformUtil.SetX(item.transform, x, true)
        ModuleCache.TransformUtil.SetY(item.transform, 0, true)
        table.insert(self.adContentInfo.gameObjectAds, item)
        self:fillAdItem(item, ads[i].content)


        
        local pageTag = self.adContentInfo.prefabPageTagParent.transform:Find("tag"..i)
        if pageTag == nil then
            pageTag = ModuleCache.ComponentUtil.InstantiateLocal(self.adContentInfo.prefabPageTag, self.adContentInfo.prefabPageTagParent)
        else
            pageTag = pageTag.gameObject
        end
        pageTag.name = "tag"..i
        ModuleCache.ComponentUtil.SafeSetActive(pageTag.gameObject, len > 1)
        local imageSelect = ModuleCache.ComponentUtil.GetComponentWithPath(pageTag.gameObject, "select", ComponentTypeName.Image)
        table.insert(self.adContentInfo.pageSelectImageArray, imageSelect)
    end
    local allImgs = TableUtil.get_all_child(self.adContentInfo.scrollRectAdContent.content.transform)
    local allPages = TableUtil.get_all_child(self.adContentInfo.prefabPageTagParent.transform)
    local allLen = #allImgs
    if #allPages > allLen then allLen = #allPages end
    for i = len + 1,allLen do
        if allImgs[i] then
            ModuleCache.ComponentUtil.SafeSetActive(allImgs[i], false)
        end
        if allPages[i] then
            ModuleCache.ComponentUtil.SafeSetActive(allPages[i], false)
        end
    end

    self:refreshAdsPageTag(1)
end

function SetPlayModeView:fillAdItem(item, url)
    local image = ModuleCache.ComponentUtil.GetComponent(item, ComponentTypeName.Image)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, sprite)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if (self) then
                    -- self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if (not self.isDestroy) then
                image.sprite = sprite
                ModuleCache.ComponentUtil.SafeSetActive(item, true)
                item.transform.parent.gameObject:SetActive(false)
                item.transform.parent.gameObject:SetActive(true)
            end
        end
    end , nil, false)
end

function SetPlayModeView:onBeginDragAdContent(obj, arg)
    self.adContentInfo.isDraging = true
end

function SetPlayModeView:onDragAdContent(obj, arg)
    self.onDragDelta = arg.delta
    local targetPos, targetIndex = self:getNearestScrollViewPos()
    self:refreshAdsPageTag(targetIndex)
end

function SetPlayModeView:onEndDragAdContent(offsetIndex, obj, arg)
    if (not self.adContentInfo.isDraging) then
        return
    end
    local targetPos, targetIndex, curPos = self:getNearestScrollViewPos()

    local offset = 0
    if (arg and self.onDragDelta.x < 0) then
        if (self.lastIndex == targetIndex) then
            if (targetPos < curPos) then
                offset = 1
            end
        else

        end
    elseif (arg and self.onDragDelta.x > 0) then
        if (self.lastIndex == targetIndex) then
            if (targetPos > curPos) then
                offset = -1
            end
        else

        end
    end

    self.adContentInfo.isDraging = false
    targetPos, targetIndex, curPos = self:getNearestScrollViewPos(offsetIndex, offset)

    ModuleCache.CustomerUtil.ToGeterSeterFloat( function()
        if not self.adContentInfo then
            print("已经销毁了")
            return
        end
        return self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition
    end ,
    function(x)
        if self.isDestroy then
            return
        end
        if self.adContentInfo and self.adContentInfo.scrollRectAdContent then
            self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition = x
            if (x == targetPos) then
                self:refreshAdsPageTag(targetIndex)
                self.lastIndex = targetIndex
            end
        end
    end ,
    targetPos, 0.2)
end

function SetPlayModeView:refreshAdsPageTag(targetIndex)
    for i = 1, #self.adContentInfo.pageSelectImageArray do
        if (targetIndex == i) then
            ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.pageSelectImageArray[i].gameObject, true)
        else
            ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.pageSelectImageArray[i].gameObject, false)
        end
    end
end

function SetPlayModeView:getNearestScrollViewPos(offsetIndex, offset)
    offsetIndex = offsetIndex or 0
    offset = offset or 0
    local curPos = self.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition
    local minOffset = 1
    local targetPosX = curPos
    local targetIndex = 1
    local len = #self.adContentInfo.gameObjectAds
    for i = 1, len do
        local pos =(i - 1) /(len - 1)
        local tmpOffset = math.abs(curPos - pos)
        if (minOffset > tmpOffset) then
            minOffset = tmpOffset
            targetPosX = math.min(math.max((i - 1 + offsetIndex + offset) /(len - 1), 0), 1)
            targetIndex = math.min(math.max(i + offsetIndex + offset, 1), len)
        end
    end
    return targetPosX, targetIndex, curPos
end

function SetPlayModeView:set_sugScroll_center()
    ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.root, false)
    self.firstScroll.transform.localPosition = Vector3.New(-625,self.firstScroll.transform.localPosition.y,0)
end

function SetPlayModeView:set_sugScroll_right()
    self.firstScroll.transform.localPosition = Vector3.New(-430,self.firstScroll.transform.localPosition.y,0)
    ModuleCache.ComponentUtil.SafeSetActive(self.adContentInfo.root, true)
end

function SetPlayModeView:setShow(isbool)
    ModuleCache.ComponentUtil.SafeSetActive(self.root, isbool)
end

return SetPlayModeView