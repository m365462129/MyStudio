-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MuseumMembersView = Class('museumMembersView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentManager

function MuseumMembersView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/museummembers/henanmj_museummembers.prefab", "HeNanMJ_MuseumMembers", 1)

    self.buttonClose = GetComponentWithPath(self.root, "Bg/ButtonClose", ComponentTypeName.Button)

    self.panels = {}
    self.copyItems = {}
    self.parents ={}
    self.contentSizeFitters = {}
    self.settingToggles = {}
    self.notDataText = {}
    for i =1, 3 do
        self.panels[i] = GetComponentWithPath(self.root, "Panel"..i, ComponentTypeName.Transform).gameObject
        self.notDataText[i] = GetComponentWithPath(self.panels[i], "Text", ComponentTypeName.Transform).gameObject
        self.parents[i] = GetComponentWithPath(self.panels[i], "Scroll View/Viewport/Content", ComponentTypeName.Transform).gameObject
        self.copyItems[i] = GetComponentWithPath(self.root, "CopyItem"..i, ComponentTypeName.Transform).gameObject
        self.contentSizeFitters[i] = GetComponentWithPath(self.panels[i], "Scroll View/Viewport/Content", "UnityEngine.UI.ContentSizeFitter")
        self.settingToggles[i] = GetComponentWithPath(self.root, "Bg/Select/"..i, ComponentTypeName.Toggle)
    end

    self.stateSwitcher = ComponentUtil.GetComponent(self.root, "UIStateSwitcher")
    self.contents = {}

    self.dropDown = GetComponentWithPath(self.root, "Panel1/TopBar/Dropdown", ComponentTypeName.Dropdown)
    self.inputField = GetComponentWithPath(self.root, "Panel1/TopBar/InputField", ComponentTypeName.InputField)
end

function MuseumMembersView:refresh_view()
    for i =1, 3 do
        ComponentUtil.SafeSetActive(self.panels[i], self.settingToggles[i].isOn)
    end
end

function MuseumMembersView:initLoopScrollViewList(data, memberType,panelIdx, isReduce)    --panelIdx 1:成员  2：审核  3：消息
    self.panelIdx = panelIdx
    --self.memberType = memberType
    self:reset()

    if isReduce ~= nil then
        self.isReduce = isReduce
    end

    if panelIdx == 1 then
        self.membersData = data
        local dataList = data.members
        if(#dataList == 0) then
            if(memberType == "OWNER" or memberType == "ADMIN") then -- playerRole == "ADMIN"
                self:fillItem(self:get_item(nil, 1), 0)
            end
        else
            if(memberType == "OWNER" or memberType == "ADMIN") then
                self:fillItem(self:get_item(nil, 1), 0)
                self:fillItem(self:get_item(nil, 2), 1)
            end
            self.dataList = dataList
            for i=1,#dataList do
                if(memberType == "OWNER" or memberType == "ADMIN") then
                    self:fillItem(self:get_item(dataList[i], i + 2))
                else
                    self:fillItem(self:get_item(dataList[i], i))
                end
            end

            if data.currentPage < data.totalPage then
                if(memberType == "OWNER" or memberType == "ADMIN") then
                    self:fillItem(self:get_item(nil, #dataList +1 + 2),3)
                else
                    self:fillItem(self:get_item(nil, #dataList +1),3)
                end
            end
        end
        self.notDataText[panelIdx]:SetActive(#dataList == 0)
    elseif panelIdx == 2 then
        self.checkList = data
        for i=1,#data do
            self:fillItem1(self:get_item(data[i], i), memberType == "OWNER" or memberType == "ADMIN")
        end
        self.notDataText[panelIdx]:SetActive(#data == 0)
    elseif panelIdx == 3 then

        for i=1,#data do
            self:fillItem2(self:get_item(data[i], i))
        end
        self.notDataText[panelIdx]:SetActive(#data == 0)
    end



    self.contentSizeFitters[panelIdx].enabled = false
    self.contentSizeFitters[panelIdx].enabled = true
end


function MuseumMembersView:get_item(data, i)
    local obj = nil
    local item = {}
    if(i<=#self.contents[self.panelIdx]) then
        obj = self.contents[self.panelIdx][i]
    else
        obj = TableUtil.clone(self.copyItems[self.panelIdx],self.parents[self.panelIdx],Vector3.zero)
    end
    obj.name = "item_" .. i 
    ComponentUtil.SafeSetActive(obj, true)  
    item.gameObject = obj
    item.data = data
    return item
end

function MuseumMembersView:reset()
    self.contents[self.panelIdx] = TableUtil.get_all_child(self.parents[self.panelIdx])
    for i=1,#self.contents[self.panelIdx] do
        ComponentUtil.SafeSetActive(self.contents[self.panelIdx][i], false)
    end
end

function MuseumMembersView:fillItem2(item)
    local data = item.data
    local imageHead = GetComponentWithPath(item.gameObject, "Mask/ImageHead", ComponentTypeName.Image)
    local infoTex = GetComponentWithPath(item.gameObject, "infoTex", ComponentTypeName.Text)
    local timeTex = GetComponentWithPath(item.gameObject, "timeTex", ComponentTypeName.Text)
    if(data) then
        TableUtil.only_download_head_icon(imageHead, data.headImg)
        timeTex.text = data.createTime

        --operate (integer, optional): 操作类型1添加 2删除
        --operateCase (integer, optional): 操作情况 添加： XXX通过免审核链接加入了亲友圈。2，XXX的申请已被圈主同意，加入了亲友圈。
        --3，XXX被圈主通过游戏ID添加到了亲友圈。删除：1，XXX主动退出了亲友圈。2，XXX被圈主踢出了亲友圈。3，XXX由于更换圈主，自动移出了亲友圈。 ,
        if data.operate == 1 then
            if data.operateCase == 1 then
                infoTex.text = string.format("<color=#98951EFF>%s</color>通过免审核链接<color=#20902FFF>加入</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10))
            elseif data.operateCase == 2 then
                if not data.operateNickname or data.operateNickname == ""then
                    infoTex.text = string.format("<color=#98951EFF>%s</color>的申请已被圈主同意，<color=#20902FFF>加入</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10))
                else
                    infoTex.text = string.format("<color=#98951EFF>%s</color>的申请已被<color=#A34FD8FF>%s</color>同意，<color=#20902FFF>加入</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10),Util.filterPlayerName(data.operateNickname, 10))
                end

            elseif data.operateCase == 3 then
                if not data.operateNickname or data.operateNickname == ""then
                    infoTex.text = string.format("<color=#98951EFF>%s</color>被圈主通过游戏ID<color=#20902FFF>添加</color>到了亲友圈。",Util.filterPlayerName(data.nickname, 10))
                else
                    infoTex.text = string.format("<color=#98951EFF>%s</color>被<color=#A34FD8FF>%s</color>通过游戏ID<color=#20902FFF>添加</color>到了亲友圈。",Util.filterPlayerName(data.nickname, 10),Util.filterPlayerName(data.operateNickname, 10))
                end
            elseif data.operateCase == 4 then
                infoTex.text = string.format("<color=#98951EFF>%s</color>被圈主<color=#20902FFF>设置</color>成为管理员。",Util.filterPlayerName(data.nickname, 10))
            end
        elseif data.operate == 2 then
            if data.operateCase == 1 then
                infoTex.text = string.format("<color=#98951EFF>%s</color>主动<color=#B62C2CFF>退出</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10))
            elseif data.operateCase == 2 then
                if not data.operateNickname or data.operateNickname == ""then
                    infoTex.text = string.format("<color=#98951EFF>%s</color>被圈主<color=#B62C2CFF>踢出</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10))
                else
                    infoTex.text = string.format("<color=#98951EFF>%s</color>被<color=#A34FD8FF>%s</color><color=#B62C2CFF>踢出</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10),Util.filterPlayerName(data.operateNickname, 10))
                end

            elseif data.operateCase == 3 then

                if not data.operateNickname or data.operateNickname == ""then
                    infoTex.text = string.format("<color=#98951EFF>%s</color>由于更换圈主，自动<color=#B62C2CFF>移出</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10))
                else
                    infoTex.text = string.format("<color=#98951EFF>%s</color>由于更换<color=#A34FD8FF>%s</color>，自动<color=#B62C2CFF>移出</color>了亲友圈。",Util.filterPlayerName(data.nickname, 10),Util.filterPlayerName(data.operateNickname, 10))
                end
            elseif data.operateCase == 4 then
                infoTex.text = string.format("<color=#98951EFF>%s</color>已经被圈主<color=#20902FFF>取消</color>管理员。",Util.filterPlayerName(data.nickname, 10))
            end
        end

    end
end

function MuseumMembersView:fillItem1(item, isOwer)
    local data = item.data
    local imageHead = GetComponentWithPath(item.gameObject, "Mask/Image/ImageHead", ComponentTypeName.Image)
    local nickName = GetComponentWithPath(item.gameObject, "TextName", ComponentTypeName.Text)
    local textId = GetComponentWithPath(item.gameObject, "TextID", ComponentTypeName.Text)
    local enable = GetComponentWithPath(item.gameObject, "Enable", ComponentTypeName.Transform).gameObject
    local disable = GetComponentWithPath(item.gameObject, "Disable", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(enable, isOwer)
    ComponentUtil.SafeSetActive(disable, not isOwer)
    if(data) then
        nickName.text = Util.filterPlayerName(data.name, 10)
        TableUtil.only_download_head_icon(imageHead, data.headImg)
        textId.text = "ID:" .. data.uid
    end
end

-- showType 0 : +   1: - 或者 返回   3: 加载更多
function MuseumMembersView:fillItem(item, showType)
    local data = item.data
    local imageHead = GetComponentWithPath(item.gameObject, "Mask/Image/ImageHead", ComponentTypeName.Image)
    local nickName = GetComponentWithPath(item.gameObject, "Mask/Image/ImageHead/Image/Name", ComponentTypeName.Text)
    local tagImg = GetComponentWithPath(item.gameObject, "Tag", ComponentTypeName.Image)
    local tagSprHolder = GetComponentWithPath(item.gameObject, "Tag", "SpriteHolder")
    local objReduce = GetComponentWithPath(item.gameObject, "ImageReduce", ComponentTypeName.Transform).gameObject
    local buttonAdd = GetComponentWithPath(item.gameObject, "Mask/Image/ButtonAdd", ComponentTypeName.Button)
    local buttonReduce = GetComponentWithPath(item.gameObject, "Mask/Image/ButtonReduce", ComponentTypeName.Button)
    local buttonBack = GetComponentWithPath(item.gameObject, "Mask/Image/ButtonBack", ComponentTypeName.Button)
    local buttonLoad = GetComponentWithPath(item.gameObject, "Mask/Image/loadButton", ComponentTypeName.Button)

    ComponentUtil.SafeSetActive(buttonAdd.gameObject, false)
    ComponentUtil.SafeSetActive(buttonReduce.gameObject, false)
    ComponentUtil.SafeSetActive(buttonBack.gameObject, false)
    ComponentUtil.SafeSetActive(imageHead.gameObject, false)
    ComponentUtil.SafeSetActive(buttonAdd.gameObject, showType == 0)
    ComponentUtil.SafeSetActive(buttonReduce.gameObject, showType == 1 and not self.isReduce)
    ComponentUtil.SafeSetActive(buttonBack.gameObject, showType == 1 and self.isReduce)
    ComponentUtil.SafeSetActive(buttonLoad.gameObject, showType == 3 ) --加载更多

    ComponentUtil.SafeSetActive(imageHead.gameObject, not showType)
    ComponentUtil.SafeSetActive(objReduce, self.isReduce and not showType)
    ComponentUtil.SafeSetActive(tagImg.gameObject, false)

    if(data) then
        nickName.text = Util.filterPlayerName(data.name, 10)
        TableUtil.only_download_head_icon(imageHead, data.headImg)

        ComponentUtil.SafeSetActive(tagImg.gameObject, data.parlorUserType < 2)
        if data.parlorUserType < 2 then
            tagImg.sprite = tagSprHolder:FindSpriteByName(data.parlorUserType)
        end
    end

end

return MuseumMembersView