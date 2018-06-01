-- UICreator 自动生成
-- 层级调整请改变 View.initialize(self, value1, value2, value3) 的Value3
-- 若是特殊UI，请自行调整

-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local ChatRoomView = Class('chatRoomView', View)

local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local GetComponent = ModuleCache.ComponentManager.GetComponent
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ComponentTypeName
local ViewUtil = ModuleCache.ViewUtil;
local ModuleCache = ModuleCache
local UserUtil = UserUtil

function ChatRoomView:initialize(...)
    -- 初始View 
    View.initialize(self, "henanmj/module/chatroom/henanmj_windowchatroom.prefab", "HeNanMJ_WindowChatRoom", 1)
    self.btnClose        = GetComponentWithPath(self.root, "Title/closeBtn",                      ComponentTypeName.Button)
    self.btnSend         = GetComponentWithPath(self.root, "Center/Button",                       ComponentTypeName.Button)
    self.btnRecv         = GetComponentWithPath(self.root, "Center/Button (1)",                   ComponentTypeName.Button)
    self.content         = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content", ComponentTypeName.Transform).gameObject
    self.cloneObj        = GetComponentWithPath(self.root, "Center/ItemParent/Item",              ComponentTypeName.Transform).gameObject
    self.scroll          = GetComponentWithPath(self.root, "Center/Scroll View",                  ComponentTypeName.ScrollRect)
    self.contentRecTrans = GetComponentWithPath(self.root, "Center/Scroll View/Viewport/Content", ComponentTypeName.RectTransform)
    self.input           = GetComponentWithPath(self.root, "Center/InputField",                   ComponentTypeName.InputField)
end

function ChatRoomView.getDeepCopyTable(copyTable)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(copyTable)
end

function ChatRoomView:showChat(chatData)
    if chatData == nil then
        print("chat data nil------ return")
        return
    end

    local showChatData = {}

    local len = #chatData
    if len > 50 then
        -- 策划说超过50条不显示啦 喜大普奔
        local sublen = len - 50
        for i = 1, 50 do
            showChatData[i] = chatData[i+sublen]
        end
    else
        showChatData = chatData
    end

    self.chatData = showChatData
    self.module = ModuleCache.ModuleManager.get_module("henanmj", "chatroom")
    local contents = TableUtil.get_all_child(self.content)
    for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end

    for i=1,#self.chatData do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(self.cloneObj,self.content.gameObject,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)
        item.gameObject = obj
        item.data = self.chatData[i]
        self:fillItem(item, i)
    end

    local setPosEnd = function()
        WaitForEndOfFrame()
        if #self.chatData > 3 then
            local height = 110 * (#self.chatData + 1)
            height = height - 362;
            self.content.transform.localPosition = Vector3.New(self.content.transform.localPosition.x, height, self.content.transform.localPosition.z)
        end
    end

    self:start_unity_coroutine(setPosEnd)

end

function ChatRoomView:fillItem(item, index)
    local data  = item.data

    local isLost = true
    if data then
        isLost = false
    end
    local left  = GetComponentWithPath(item.gameObject, "left",  ComponentTypeName.Transform).gameObject
    local right = GetComponentWithPath(item.gameObject, "right", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(left, false)
    ComponentUtil.SafeSetActive(right, false)
    local panel = left --data.userId ~= tostring(self.modleData.roleData.userId)

    if (not isLost) and tostring(data.userId) == tostring(self.modelData.roleData.userId) then
        panel = right
    end

    local icon = GetComponentWithPath(panel, "Icon",  ComponentTypeName.Image)
    local mTxt = GetComponentWithPath(panel, "Text",  ComponentTypeName.Text)
    if isLost then
        mTxt.text = "该对话已过期！"
    else
        local user = UserUtil.getDataById(data.userId)
        if user and user.headSprite then
            icon.sprite = user.headSprite
        end

        local roleData = {}
        roleData.userId   = data.userId
        roleData.nickname = data.nickname
        roleData.gender   = data.gender
        roleData.headImg  = data.headImg

        UserUtil.saveUser(roleData, function(saveData)
            if not self.isDestroy then
                icon.sprite = saveData.headSprite
            end
        end )

        mTxt.text = data.content
    end
    ComponentUtil.SafeSetActive(panel, true)
end

return ChatRoomView