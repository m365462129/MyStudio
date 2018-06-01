-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

---@class ChessMuseumView
local ChessMuseumView = Class('chessMuseumView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentManager
local PlayerPrefsManager = ModuleCache.PlayerPrefsManager
local UserUtil = UserUtil
local CSmartTimer = ModuleCache.SmartTimer.instance
local CustomImageManager = ModuleCache.CustomImageManager
local Application = UnityEngine.Application

function ChessMuseumView:initialize(...)
    -- 初始View    
    View.initialize(self, "henanmj/module/chessmuseum/henanmj_chessmuseum.prefab", "HeNanMJ_ChessMuseum", 0)
    View.set_1080p(self)

    self.buttonClose = GetComponentWithPath(self.root, "Top/Child/ImageClose", ComponentTypeName.Button)

    self.buttonSetting = GetComponentWithPath(self.root, "TopRight/Child/TopBar/ButtonSetting", ComponentTypeName.Button)
    self.buttonInfo = GetComponentWithPath(self.root, "TopRight/Child/TopBar/ButtonInfo", ComponentTypeName.Button)

    self.freeCreateBtn = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Image/FreeCreateBtn", ComponentTypeName.Button)
    self.refreshListBtn = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Image/RefreshListBtn", ComponentTypeName.Button)
    self.refreshList_disableObj = GetComponentWithPath(self.refreshListBtn.gameObject, "disableObj", ComponentTypeName.Transform).gameObject
    self.refreshList_countDownTex = GetComponentWithPath(self.refreshList_disableObj,"Text",ComponentTypeName.Text)

    self.textNotice = GetComponentWithPath(self.root,"TopRight/Child/ListScrollView/Image/NoticeBtn/Text",ComponentTypeName.Text)
    self.textChessName = GetComponentWithPath(self.root, "TopRight/Child/TopBar/chessName", ComponentTypeName.Text)

    self.addItem = GetComponentWithPath(self.root, "TopLeft/Panels/ListScrollView/Viewport/Content/AddItem", ComponentTypeName.Transform).gameObject
    self.loadButton =GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Viewport/Content/loadButton", ComponentTypeName.Transform).gameObject
    self.loadButton_extend =GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Viewport/Content_extend/loadButton", ComponentTypeName.Transform).gameObject

    self.copyItem ={}   --type 1 ：亲友圈列表    2 ：房间列表     3:扩展模式的房间列表      4:置顶消息      5：聊天消息
    self.copyItem[1] = GetComponentWithPath(self.root, "TopLeft/Panels/ItemPrefabHolder/CopyItem", ComponentTypeName.Transform).gameObject
    self.copyItem[2] = GetComponentWithPath(self.root, "TopRight/Child/ItemPrefabHolder/CopyItem", ComponentTypeName.Transform).gameObject
    self.copyItem[3] = GetComponentWithPath(self.root, "TopRight/Child/ItemPrefabHolder/CopyItem_extend", ComponentTypeName.Transform).gameObject
    self.copyItem[4] = GetComponentWithPath(self.root, "TopRight/Child/ItemPrefabHolder/Msg", ComponentTypeName.Transform).gameObject
    self.copyItem[5] = GetComponentWithPath(self.root, "TopRight/Child/ItemPrefabHolder/Msg", ComponentTypeName.Transform).gameObject

    self.copyParent = {}    --type 1 ：亲友圈列表    2 ：房间列表     3:扩展模式的房间列表      4:置顶消息      5：聊天消息
    self.copyParent[1] = GetComponentWithPath(self.root, "TopLeft/Panels/ListScrollView/Viewport/Content", ComponentTypeName.RectTransform)
    self.copyParent[2] = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Viewport/Content", ComponentTypeName.RectTransform)
    self.copyParent[3] = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Viewport/Content_extend", ComponentTypeName.RectTransform)
    self.copyParent[4] = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg/Viewport/Content", ComponentTypeName.RectTransform)
    self.copyParent[5] = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_chatMsg/Viewport/Content", ComponentTypeName.RectTransform)

    self.noSelectTex = GetComponentWithPath(self.root, "Center/Child/Text", ComponentTypeName.Text)

    self.UIStateSwitcher = ComponentUtil.GetComponent(self.root, "UIStateSwitcher")

    self.membersNewMsgObj = GetComponentWithPath(self.root, "TopRight/Child/TopBar/ButtonPlayer/NewMsg", ComponentTypeName.Transform).gameObject
    self.membersNewMsgTex = GetComponentWithPath(self.root, "TopRight/Child/TopBar/ButtonPlayer/NewMsg/Text", ComponentTypeName.Text)

    self.defaultHeadSpr =  GetComponentWithPath(self.root, "Center/Child/defaultlHead", ComponentTypeName.Image).sprite
    self.defaultHeadSpr_extend =  GetComponentWithPath(self.root, "Center/Child/defaultlHead (1)", ComponentTypeName.Image).sprite
    self.contents = {}

    self.extendToggle = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Image/ExtendToggle", ComponentTypeName.Toggle)
    self.extendToggleBg_rectTran = GetComponentWithPath(self.extendToggle.gameObject, "Background", ComponentTypeName.RectTransform)

    self.roomList_scrollRect = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView", ComponentTypeName.ScrollRect)
    self.roomList_rectTransform = GetComponentWithPath(self.root, "TopRight/Child/ListScrollView", ComponentTypeName.RectTransform)
    self.roomList_gridLayoutGroup =GetComponentWithPath(self.root, "TopRight/Child/ListScrollView/Viewport/Content", ComponentTypeName.GridLayoutGroup)

    self.topMsg_scr = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg", ComponentTypeName.RectTransform)
    self.topMsg_rectTran = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg/Viewport/Content", ComponentTypeName.RectTransform)
    self.topMsg_fengexian = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg/Image", ComponentTypeName.Transform).gameObject
    self.topMsg_fengexian:SetActive(false)
    
    self.chatMsg_scr = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_chatMsg", ComponentTypeName.RectTransform)
    self.input = GetComponentWithPath(self.root, "BottomRight/Child/ChatBar/InputField", ComponentTypeName.InputField)

    self.openTopMsg = GetComponentWithPath(self.root, "BottomRight/Child/ChatBar/openTopMsg", ComponentTypeName.Toggle)

    self.topMsgScrollRect = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg", ComponentTypeName.ScrollRect)
    self.chatMsgScrollRect = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_chatMsg", ComponentTypeName.ScrollRect)
    self.topMsgCsf = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg/Viewport/Content", ComponentTypeName.ContentSizeFitter)
    self.chatMsgCsf = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_chatMsg/Viewport/Content", ComponentTypeName.ContentSizeFitter)
    self.topMsgVlg = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_topMsg/Viewport/Content", ComponentTypeName.VerticalLayoutGroup)
    self.chatMsgVlg = GetComponentWithPath(self.root, "TopRight/Child/MsgPanel/ListScrollView_chatMsg/Viewport/Content", ComponentTypeName.VerticalLayoutGroup)

    self.chatBarStateSwither = GetComponentWithPath(self.root, "BottomRight/Child/ChatBar", "UIStateSwitcher")
    self.changeVoiceToggle = GetComponentWithPath(self.root, "BottomRight/Child/ChatBar/changeVoice", ComponentTypeName.Toggle)
    self.emoticonToggle = GetComponentWithPath(self.root, "BottomRight/Child/ChatBar/emoticonBtn", ComponentTypeName.Toggle)
    self.facePanel = GetComponentWithPath(self.root, "Bottom/Child/PanelFace", ComponentTypeName.Transform).gameObject

    self.originalImgObj =  GetComponentWithPath(self.root, "Bottom/OriginalImg", ComponentTypeName.Transform).gameObject
    self.originalImg = GetComponentWithPath(self.root, "Bottom/OriginalImg/RawImage", ComponentTypeName.RawImage)
    self.originalImgRectTran = GetComponentWithPath(self.root, "Bottom/OriginalImg/RawImage", ComponentTypeName.RectTransform)

    self.AccNumTex = GetComponentWithPath(self.root,"Top/Child/AccBtn/Text",ComponentTypeName.Text)

    --self.rootRectTran = ComponentUtil.GetComponent(self.root, ComponentTypeName.RectTransform)
    self.adjustVule =  0--self.rootRectTran.sizeDelta.x - 1920
    --self.roomList_gridLayoutGroup.constraintCount = self.roomList_gridLayoutGroup.constraintCount + math.modf(self.adjustVule / self.roomList_gridLayoutGroup.cellSize.x)

end

local topMsgHeight = 0
local notTopMsg = false
function ChessMuseumView:setMsgPanel()
    --设置消息item的大小 准备排序
    if self.resetSizeDeltaId then
        CSmartTimer:Kill(self.resetSizeDeltaId)
    end

    self.resetSizeDeltaId = self:subscibe_time_event(0.3, false, 0):OnComplete(function(t)
        --self.contents_top= TableUtil.get_all_child(self.copyParent[4].gameObject)
        --for i=1,#self.contents_top do
        --
        --    local array = string.split(self.contents_top[i].gameObject.name, "_")
        --    local idx = tonumber(array[2])
        --    local showTimeTexHeight = 82
        --
        --    local curData = self:get_top_msg_data(idx)
        --    local nextData = self:get_top_msg_data(idx+ 1)
        --    if curData and tonumber(curData.msgType) == 2 and nextData and nextData.showTimeTex and tonumber(nextData.msgType) == 2 then
        --        showTimeTexHeight = showTimeTexHeight +30
        --    end
        --
        --    if nextData and nextData.showTimeTex then
        --        showTimeTexHeight = showTimeTexHeight+ 50
        --    end
        --
        --    local msgRectTran = GetComponentWithPath(self.contents_top[i].gameObject, "msgTex", ComponentTypeName.RectTransform)
        --    local itemRectTran = ModuleCache.ComponentManager.GetComponent(self.contents_top[i].gameObject,ComponentTypeName.RectTransform)
        --    local msgContenSF = GetComponentWithPath(self.contents_top[i].gameObject, "msgTex", ComponentTypeName.ContentSizeFitter)
        --
        --    if curData and tonumber(curData.msgType) == 4 then
        --        if not curData.isSelfSend then
        --            showTimeTexHeight = showTimeTexHeight+ 20
        --        end
        --        if curData.w and curData.h then
        --            if curData.w > curData.h then
        --                showTimeTexHeight = showTimeTexHeight+ 50
        --            else
        --                showTimeTexHeight = showTimeTexHeight+ 100
        --            end
        --        end
        --    end
        --
        --    if msgRectTran.sizeDelta.x < 417 then
        --        msgContenSF.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize
        --    else
        --        msgContenSF.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.Unconstrained
        --        msgRectTran.sizeDelta = Vector2.New(417,  msgRectTran.sizeDelta.y)
        --    end
        --
        --    local setPosEnd = function()
        --        --Yield(0)
        --        WaitForEndOfFrame()
        --        if itemRectTran then
        --            itemRectTran.sizeDelta = Vector2.New(itemRectTran.sizeDelta.x, msgRectTran.sizeDelta.y+showTimeTexHeight)
        --
        --        end
        --    end
        --
        --    self:start_unity_coroutine(setPosEnd)
        --
        --end

        self.contents_chatMsg= TableUtil.get_all_child(self.copyParent[5].gameObject)
        for i=1,#self.contents_chatMsg do
            if self.contents_chatMsg[i].gameObject.activeSelf then
                local array = string.split(self.contents_chatMsg[i].gameObject.name, "_")
                local idx = tonumber(array[2])
                local showTimeTexHeight = 82

                local curData = self:get_chat_msg_data(idx)
                local nextData = self:get_chat_msg_data(idx+ 1)
                if curData and tonumber(curData.msgType) == 2 and nextData and nextData.showTimeTex and tonumber(nextData.msgType) == 2 then
                    showTimeTexHeight = showTimeTexHeight +30
                end

                if nextData and nextData.showTimeTex then
                    showTimeTexHeight = showTimeTexHeight+ 50
                end

                local msgRectTran = GetComponentWithPath(self.contents_chatMsg[i].gameObject, "msgTex", ComponentTypeName.RectTransform)
                if curData and tonumber(curData.msgType) == 1 and not msgRectTran.gameObject.activeSelf then
                    msgRectTran = GetComponentWithPath(self.contents_chatMsg[i].gameObject, "msgTex_zj", ComponentTypeName.RectTransform)
                end

                local itemRectTran = ModuleCache.ComponentManager.GetComponent(self.contents_chatMsg[i].gameObject,ComponentTypeName.RectTransform)
                local msgContenSF =  ModuleCache.ComponentManager.GetComponent(msgRectTran.gameObject, ComponentTypeName.ContentSizeFitter)

                msgContenSF:SetLayoutHorizontal()--强制计算一下msgRectTran.sizeDelta
                if curData and tonumber(curData.msgType) == 4 then
                    if not curData.isSelfSend then
                        showTimeTexHeight = showTimeTexHeight+ 20
                    end

                    if curData.w and curData.h then
                        if curData.w > curData.h then
                            showTimeTexHeight = showTimeTexHeight+ 50
                        else
                            showTimeTexHeight = showTimeTexHeight+ 100
                        end
                    end
                end
                --print(msgRectTran.sizeDelta.x,"@@@@@@@@@@@@@@@@@@@@@@",curData.content)

                if msgRectTran.sizeDelta.x < 417 then
                    msgContenSF.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize
                else
                    msgContenSF.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.Unconstrained
                    msgRectTran.sizeDelta = Vector2.New(417,  msgRectTran.sizeDelta.y)
                end

                local setPosEnd = function()
                    --Yield(0)
                    WaitForEndOfFrame()
                    if not self.isDestroy then
                        if itemRectTran and itemRectTran.sizeDelta then
                            itemRectTran.sizeDelta = Vector2.New(itemRectTran.sizeDelta.x, msgRectTran.sizeDelta.y+showTimeTexHeight)
                        end
                    end
                end

                self:start_unity_coroutine(setPosEnd)
            end
        end

        local setPosEnd = function()
            Yield(0)
            --Yield(0)
            --Yield(0)
            --WaitForEndOfFrame()
            --WaitForSeconds(1)
            if not self.isDestroy then
                self.topMsgVlg:SetLayoutVertical()
                self.chatMsgVlg:SetLayoutVertical()

                self.topMsgCsf.enabled = false
                self.topMsgCsf.enabled = true

                self.chatMsgCsf.enabled = false
                self.chatMsgCsf.enabled = true
                WaitForEndOfFrame()
                self.topMsgScrollRect.verticalNormalizedPosition = 0
                self.chatMsgScrollRect.verticalNormalizedPosition = 0
            end
        end

        self:start_unity_coroutine(setPosEnd)--设置显示最新消息（拉到最底部）
    end).id


    ----重置聊天消息区域和置顶消息区域 大小和位置
    --if self.kickedTimeId then
    --    CSmartTimer:Kill(self.kickedTimeId)
    --end
    --
    --self.kickedTimeId = self:subscibe_time_event(0.2, false, 0):OnComplete(function(t)
    --    topMsgHeight = self.topMsg_rectTran.sizeDelta.y
    --    if topMsgHeight > 365 then
    --        topMsgHeight = 365
    --    end
    --
    --    notTopMsg = topMsgHeight == 10--  self.topMsg_rectTran.transform.childCount == 0
    --
    --    self.topMsg_scr.sizeDelta = Vector2.New(716.6, topMsgHeight )
    --
    --    self.topMsg_fengexian:SetActive(not notTopMsg)
    --    if notTopMsg then
    --        self.chatMsg_scr.anchoredPosition = Vector2.New(358.6, 360 - topMsgHeight)
    --
    --        self.chatMsg_scr.sizeDelta = Vector2.New(716.6, 725 - topMsgHeight )
    --    else
    --        self.chatMsg_scr.anchoredPosition = Vector2.New(358.6, 360 - topMsgHeight -20)
    --
    --        self.chatMsg_scr.sizeDelta = Vector2.New(716.6, 725 - topMsgHeight -20 )
    --    end
    --
    --
    --end).id
end

--初始化聊天消息列表
function ChessMuseumView:initLoopScrollViewList_chatMsg(chatData,topMsg)
    local tempData = {}
    if(chatData and #chatData > 0) then
        for i=1,#chatData do
            if os.time() - chatData[i].messageCreateSeconds <= 86400 then -- 86400 = 24 *60*60   24小时
                table.insert(tempData,chatData[i])
            end
        end

        chatData = tempData
    end

    local panelIdx = 5
    if topMsg then
        panelIdx = 4
        self.topMsgList = chatData

    else
        self.chatMsgList = chatData
    end

    if not chatData  or (chatData and #chatData < 1 ) then
        self:reset(panelIdx)
        self:setMsgPanel()
        --print("----------$$$$$$$$$$$$$$$$$$$$$$$----",panelIdx, topMsg)
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

    self:reset(panelIdx)

    if(#self.chatData > 0) then
        for i=1,#self.chatData do
            if i == 1 or (i % 20 == 0 ) or  (self.chatData[i].messageCreateSeconds -  PlayerPrefsManager.GetInt("ShowTimeTex"..self.museumData.id,0) >= 300) then   --messageCreateSeconds 时间戳 （秒）  距上条显示时间 差5分钟 显示时间
                self.chatData[i].showTimeTex = true
                PlayerPrefsManager.SetInt("ShowTimeTex"..self.museumData.id, self.chatData[i].messageCreateSeconds)
            end

            self:fillItem_chatMsg(self:get_item(self.chatData[i], i,panelIdx), topMsg)
        end
    end
    self:setMsgPanel()
end

--初始化亲友圈列表
function ChessMuseumView:initLoopScrollViewList(dataList, isSearch)
    if not dataList then
        return
    end
    self.noSelectTex.text = self.parlorWeiXin

    self:reset(1)
    self.toggles = {}
    self.dataList = dataList
    self.AccNumTex.transform.parent.gameObject:SetActive(#dataList ~= 0)
    if(#dataList == 0) then
        self.UIStateSwitcher:SwitchState("NoSelect")
    else
        self.UIStateSwitcher:SwitchState("Select")
        for i=1,#dataList do
            self:fillItem(self:get_item(dataList[i], i,1))
        end
    end
    --if(not isSearch) then
    --    TableUtil.clone(self.addItem,self.copyParent[1],Vector3.zero):SetActive(true)
    --end
    self.addItem:SetActive(true)
    self.addItem.transform:SetAsLastSibling()

    self.input.text = ""
    self.chatBarStateSwither:SwitchState("words+")
end

--初始化房间列表
function ChessMuseumView:initLoopScrollViewList_roomList(data)
    --print_traceback("--@@@-------###initLoopScrollViewList_roomList--------------".. #data.list)
    self:reset(2)
    self:reset(3)

    local dataList = data.list
    if # dataList < 1 then
        return
    end
    self.roomListData = dataList

    table.sort(dataList, function(a,b)
        local r
        if a.roleFull == b.roleFull then
            r = a.roomType > b.roomType
        else
            r = a.roleFull > b.roleFull
        end
        return r
    end)

    if(#dataList > 0) then
        for i=1,#dataList do
            self:fillItem_roomList(self:get_item(dataList[i], i,2))
            self:fillItem_roomList_extend(self:get_item(dataList[i], i,3))
        end
    end

    self.loadButton:SetActive(data.currentPage < data.totalPage)
    self.loadButton.transform:SetAsLastSibling()

    self.loadButton_extend:SetActive(data.currentPage < data.totalPage)
    self.loadButton_extend.transform:SetAsLastSibling()
end

--获取房间数据
function ChessMuseumView:get_room_data(idx)

    return self.roomListData[idx]
end

--获取置顶消息数据
function ChessMuseumView:get_top_msg_data(idx)

    return self.topMsgList[idx]
end

--获取聊天消息数据
function ChessMuseumView:get_chat_msg_data(idx)

    return self.chatMsgList[idx]
end

function ChessMuseumView:get_item(data, i,type) --type 1 ：亲友圈列表    2 ：房间列表     3:扩展模式的房间列表      4:置顶消息      5：聊天消息
    local obj = nil
    local item = {}
    if(i<=#self.contents[type] and self.contents[type][i].name ~= "AddItem" and self.contents[type][i].name ~= "loadButton" ) then
        obj = self.contents[type][i]
    else
        obj = TableUtil.clone(self.copyItem[type],self.copyParent[type].gameObject,Vector3.zero)
    end
    obj.name = "item_" .. i 
    ComponentUtil.SafeSetActive(obj, true)  
    item.gameObject = obj
    item.data = data
    return item
end

function ChessMuseumView:reset(type)  --type 1 ：亲友圈列表    2 ：房间列表     3:扩展模式的房间列表      4:置顶消息      5：聊天消息
    self.contents[type] = TableUtil.get_all_child(self.copyParent[type].gameObject)
    for i=1,#self.contents[type] do
        ComponentUtil.SafeSetActive(self.contents[type][i], false)
    end
end

function ChessMuseumView:fillItem_chatMsg(item, topMsg)--msgType	1 文字	2 语音	3 表情   4 图片
    local data = item.data

    local stateSwitcher =  ModuleCache.ComponentManager.GetComponent(item.gameObject,"UIStateSwitcher")
    local msgSpriteHolderImg        = GetComponentWithPath(item.gameObject, "msgTex", ComponentTypeName.Image)
    local msgTex_zj = GetComponentWithPath(item.gameObject, "msgTex_zj", ComponentTypeName.Transform)

    --msgSpriteHolderImg.gameObject:SetActive(tonumber(data.msgType) <3)

    --if data and tonumber(data.msgType) == 1 and not msgSpriteHolderImg.gameObject.activeSelf then
    --    msgSpriteHolderImg = GetComponentWithPath(item.gameObject, "msgTex_zj", ComponentTypeName.Image)
    --end


    local msgSpriteHolder = ModuleCache.ComponentManager.GetComponent(msgSpriteHolderImg.gameObject,  "SpriteHolder")
    local imageHead = GetComponentWithPath(item.gameObject, "player/Mask/Head", ComponentTypeName.Image)
    local msgTex = GetComponentWithPath(msgSpriteHolderImg.gameObject, "Text", ComponentTypeName.Text)
    local voicePop = GetComponentWithPath(msgSpriteHolderImg.gameObject, "voicePop", ComponentTypeName.Text)
    local timeTex = GetComponentWithPath(item.gameObject, "time", ComponentTypeName.Text)
    local nickTex = GetComponentWithPath(item.gameObject, "player/nick", ComponentTypeName.Text)

    local wordTopIcon = GetComponentWithPath(msgSpriteHolderImg.gameObject, "Text/Image", ComponentTypeName.RectTransform)
    local faceItemImg = GetComponentWithPath(item.gameObject, "FaceItem", ComponentTypeName.Image)
    item.textureMsg = GetComponentWithPath(item.gameObject, "Image_msg", ComponentTypeName.RawImage)
    item.textureMsgTran = ModuleCache.ComponentManager.GetComponent(item.textureMsg.gameObject,ComponentTypeName.RectTransform)
    item.texture_download = GetComponentWithPath(item.textureMsg.gameObject,"ImageDelay",ComponentTypeName.Transform).gameObject

    --local faceItemSpriteHolder = GetComponentWithPath(item.gameObject, "FaceItem", "SpriteHolder")

    local msgContenSF = ModuleCache.ComponentManager.GetComponent(msgSpriteHolderImg.gameObject, ComponentTypeName.ContentSizeFitter)
    msgContenSF.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize


    data.isSelfSend = tostring(data.userId) == tostring(self.modelData.roleData.userId) -- math.random()< 0.5
    if not data then
        --print("-------------fillItem_chatMsg--------data = nil -----------------------------------")

        if topMsg then
            stateSwitcher:SwitchState("system_top")
        else
            stateSwitcher:SwitchState("system")
        end

        msgTex.text = "该对话已过期！"

        return
    end

    local deleteObjList ={
        GetComponentWithPath(item.gameObject, "msgTex/Text/deleteButton_self", ComponentTypeName.Transform).gameObject,
        GetComponentWithPath(item.gameObject, "msgTex/voicePop/self/deleteButton_self", ComponentTypeName.Transform).gameObject,
        GetComponentWithPath(item.gameObject, "msgTex/Text/deleteButton_other", ComponentTypeName.Transform).gameObject,
        GetComponentWithPath(item.gameObject, "msgTex/voicePop/other/deleteButton_other", ComponentTypeName.Transform).gameObject,
        GetComponentWithPath(item.gameObject, "FaceItem/deleteButton", ComponentTypeName.Transform).gameObject,
        GetComponentWithPath(item.gameObject, "Image_msg/deleteButton", ComponentTypeName.Transform).gameObject
    }

    for i =1,6 do
        deleteObjList[i]:SetActive(false)
    end

    local voicePop_self = GetComponentWithPath(item.gameObject, "msgTex/voicePop/self", ComponentTypeName.Transform).gameObject
    local voicePop_other = GetComponentWithPath(item.gameObject, "msgTex/voicePop/other", ComponentTypeName.Transform).gameObject
    local voicePop_topIcon_self = GetComponentWithPath(item.gameObject, "msgTex/voicePop/self/topIcon_self", ComponentTypeName.Transform).gameObject
    local voicePop_topIcon_other = GetComponentWithPath(item.gameObject, "msgTex/voicePop/topIcon_other", ComponentTypeName.Transform).gameObject
    
    voicePop_self:SetActive( data.isSelfSend)
    voicePop_other:SetActive( not data.isSelfSend )
    voicePop_topIcon_self:SetActive( data.isSelfSend and topMsg)
    voicePop_topIcon_other:SetActive(not data.isSelfSend and topMsg)
    


    local deleteObj = nil
    local voiceLeng = nil
    if  data.isSelfSend then
        voiceLeng = GetComponentWithPath(item.gameObject, "msgTex/voicePop/self/voiceLength_self", ComponentTypeName.Text)

        if tonumber(data.msgType) == 1 then
            deleteObj = deleteObjList[1]
        elseif tonumber(data.msgType) == 2 then
            deleteObj = deleteObjList[2]
        elseif tonumber(data.msgType) == 3 then
            deleteObj = deleteObjList[5]
        elseif tonumber(data.msgType) == 4 then
            deleteObj = deleteObjList[6]
        end

    else
        voiceLeng = GetComponentWithPath(item.gameObject, "msgTex/voicePop/other/voiceLength_other", ComponentTypeName.Text)

        if tonumber(data.msgType) == 1 then
            deleteObj = deleteObjList[3]
        elseif tonumber(data.msgType) == 2 then
            deleteObj = deleteObjList[4]
        elseif tonumber(data.msgType) == 3 then
            deleteObj = deleteObjList[5]
        elseif tonumber(data.msgType) == 4 then
            deleteObj = deleteObjList[6]
        end

        nickTex.text = data.nickname
    end

    local voiceReadState = GetComponentWithPath(voiceLeng.gameObject, "Image", ComponentTypeName.Transform).gameObject
    local msgTexRectTran = GetComponentWithPath(item.gameObject, "msgTex", ComponentTypeName.RectTransform)

    data.id = data.id or  data.userId .. os.date("%Y-%m-%d %H:%M:%S")    --消息id
    voiceReadState:SetActive(PlayerPrefsManager.GetInt(data.id, 0) == 0 and not data.isSelfSend)

    timeTex.gameObject:SetActive(data.showTimeTex == true)
    if data.showTimeTex then
        timeTex.text = os.date("%Y-%m-%d %H:%M:%S", data.messageCreateSeconds )
    end

    data.msgType =  data.msgType or 1
    msgTex.gameObject:SetActive(tonumber(data.msgType) == 1)
    voicePop.gameObject:SetActive(tonumber(data.msgType) == 2)

    voiceLeng.text = (data.voiceLength or 0) .."\""
    if data.voiceLength then
        voicePop.text = string.rep(" ",math.min(5 + data.voiceLength,25) )
    end

    if  data.isSelfSend then
        msgSpriteHolderImg.sprite = msgSpriteHolder:FindSpriteByName("self")
        msgTexRectTran.pivot = Vector2.New(1, 1)
        item.textureMsgTran.pivot = Vector2.New(1,1)

        if topMsg then
            stateSwitcher:SwitchState("self_top")

            wordTopIcon.anchoredPosition = Vector2.New(-16, wordTopIcon.anchoredPosition.y)
        else
            stateSwitcher:SwitchState("self")
        end

    else
        msgSpriteHolderImg.sprite = msgSpriteHolder:FindSpriteByName("other")
        msgTexRectTran.pivot = Vector2.New(0,1)
        item.textureMsgTran.pivot = Vector2.New(0,1)

        if topMsg then
            stateSwitcher:SwitchState("other_top")

            wordTopIcon.anchoredPosition = Vector2.New(-8.7, wordTopIcon.anchoredPosition.y)
        else
            stateSwitcher:SwitchState("other")
        end

    end

    msgSpriteHolderImg.gameObject:SetActive(tonumber(data.msgType) <3)
    faceItemImg.gameObject:SetActive(tonumber(data.msgType) == 3)
    if tonumber(data.msgType) == 3 then
        --faceItemImg.sprite = faceItemSpriteHolder:FindSpriteByName(tonumber(data.content)-1)
        for i=1,20 do
            local goEmoji = GetComponentWithPath( faceItemImg.gameObject, "" .. (i-1), ComponentTypeName.Transform).gameObject
            if(goEmoji) then
                ModuleCache.ComponentUtil.SafeSetActive(goEmoji, i  == tonumber(data.content))
            end
        end
    end

    if deleteObj then
        if topMsg then
            deleteObj:SetActive( tonumber(self.museumData.ownerUid) == tonumber(self.modelData.roleData.userID))
        else
            deleteObj:SetActive( false)
        end
    end

    local user = UserUtil.getDataById(data.userId)
    if user and user.headSprite then
        imageHead.sprite = user.headSprite
    end

    local roleData = {}
    roleData.userId   = data.userId
    roleData.nickname = data.nickname
    roleData.gender   = data.gender
    roleData.headImg  = data.headImg

    UserUtil.saveUser(roleData, function(saveData)
        if not self.isDestroy then
            imageHead.sprite = saveData.headSprite
        end
    end )

    local timeArr = string.split(data.content, "\n查看详情：")
    if # timeArr < 2 then
        timeArr = string.split(data.content, "查看详情：")
    end

    msgTex.text = timeArr[1]-- data.content

    msgTex_zj.gameObject:SetActive(false)
    ----战绩消息
    if # timeArr == 2 then
        local arr = string.split(timeArr[1], "【")
        if #arr >= 3 then
            GetComponentWithPath(item.gameObject, "msgTex", ComponentTypeName.Image).gameObject:SetActive(false)

            msgSpriteHolderImg = GetComponentWithPath(item.gameObject, "msgTex_zj", ComponentTypeName.Image)
            msgTexRectTran = GetComponentWithPath(item.gameObject, "msgTex_zj", ComponentTypeName.RectTransform)

            local texTop = GetComponentWithPath(item.gameObject, "msgTex_zj/Text", ComponentTypeName.Text)
            local texLeft = GetComponentWithPath(item.gameObject, "msgTex_zj/Text/Text_name", ComponentTypeName.Text)
            local texRight = GetComponentWithPath(item.gameObject, "msgTex_zj/Text/Text_score", ComponentTypeName.Text)
            msgTex_zj.gameObject:SetActive(true)


            if  data.isSelfSend then
                msgSpriteHolderImg.sprite = msgSpriteHolder:FindSpriteByName("self")
                msgTexRectTran.pivot = Vector2.New(1, 1)
            else
                msgSpriteHolderImg.sprite = msgSpriteHolder:FindSpriteByName("other")
                msgTexRectTran.pivot = Vector2.New(0,1)
            end



            local leftStr =""
            local rightStr =""
            for i = 2,#arr do
                local temp = string.split(arr[i], "】")
                local tempS = string.match(temp[2],"%s*(.-)%s*$")
                if i < #arr then

                    if not tonumber(tempS)  then
                        leftStr = leftStr .."【" ..string.match(temp[1],"%s*(.-)%s*$").."】" .."\n -----------\n"
                        rightStr = rightStr .. tempS .."\n-------\n"
                    elseif  (tonumber(tempS) and i == 2) then
                        leftStr = leftStr .." -----------\n【" ..string.match(temp[1],"%s*(.-)%s*$").."】" .."\n"
                        rightStr = rightStr .."-------\n".. tempS .."\n"
                    else
                        leftStr = leftStr .."【" ..string.match(temp[1],"%s*(.-)%s*$").."】" .."\n"
                        rightStr = rightStr .. tempS .."\n"
                    end


                else
                    leftStr = leftStr .."【" ..string.match(temp[1],"%s*(.-)%s*$").."】"
                    rightStr = rightStr .. tempS
                end


            end

            --从ios贴出来的换行符变成了空格   亲友圈75450 房号513982 结束时间：05/29 16:29 【答你所愿1】 -6 【Y】 -4 【Y】 10 查看详情：http:// bt.sincebest.com/es/c43c508086958e2c
            local topArr = string.split(arr[1], "结束时间：")
            texTop.text = string.match(topArr[1],"%s*(.-)%s*$").."\n".."结束时间："..topArr[2]

            texLeft.text = leftStr
            texRight.text = rightStr

        end
    end

    item.textureMsg.gameObject:SetActive(tonumber(data.msgType) == 4)
    if tonumber(data.msgType) == 4 then
        item.texture_download:SetActive(true)
        item.textureMsg.texture = nil
        local arr = string.split(data.content, "_")
        if # arr > 2 then
            data.w = tonumber(arr[2])
            data.h = tonumber(arr[3])
            if data.w  >  data.h then
                item.textureMsgTran.sizeDelta = Vector2.New(math.min( data.w,175), math.min( data.h,100))
            else
                item.textureMsgTran.sizeDelta = Vector2.New(math.min( data.w,80), math.min( data.h,150))
            end
            data.resetImgSize = true
        end

        CustomImageManager.download_image_file(data.content, Application.persistentDataPath .. "/" .. data.content .. ".jpg", function(imagePath)
            -- 读取显示照片
            item.texture_download:SetActive(false)
            print(data.resetImgSize,"@@@@@@@@@@@@@@@收到照片消息",imagePath)

            local _texture = ModuleCache.TextureCacheManager._get_local_chat_texture(imagePath)
            if not data.resetImgSize then

                local v2 = ModuleCache.CustomerUtil.GetTexture2dSize(_texture)
                if v2.x  > v2.y then
                    item.textureMsgTran.sizeDelta = Vector2.New(math.min(v2.x,175), math.min(v2.y,100))
                else
                    item.textureMsgTran.sizeDelta = Vector2.New(math.min(v2.x,80), math.min(v2.y,150))
                end
            end

            item.textureMsg.texture =  _texture

        end)
    end
end

function ChessMuseumView:fillItem(item, isEmpty)
    local itemObj = {}
    local data = item.data

    local tag = GetComponentWithPath(item.gameObject, "Full/Tag", ComponentTypeName.Image)
    local tagSpriteHolder = GetComponentWithPath(item.gameObject, "Full/Tag", "SpriteHolder")
    local imageHead = GetComponentWithPath(item.gameObject, "headIcon/HeadBG", ComponentTypeName.Image)

  --  itemObj.stateSwitcher =  ModuleCache.ComponentManager.GetComponent(item.gameObject,"UIStateSwitcher")
    itemObj.textNum = GetComponentWithPath(item.gameObject, "bg (1)/Text2", ComponentTypeName.Text)
    itemObj.toggle = ModuleCache.ComponentManager.GetComponent(item.gameObject, ComponentTypeName.Toggle)
    itemObj.headImgs = {}

    --if #data.headImgList < 9 then
    --    itemObj.stateSwitcher:SwitchState(tostring(#data.headImgList)  )
    --else
    --    itemObj.stateSwitcher:SwitchState("9")
    --end

    --for i =1, 9 do
    --    if i <= #data.headImgList then
    --        itemObj.headImgs[i] = GetComponentWithPath(item.gameObject, "players/player ("..i..")/HeadBG", ComponentTypeName.Image)
    --
    --        TableUtil.only_download_head_icon(itemObj.headImgs[i], data.headImgList[i])
    --    end
    --end

    if(data) then
        ComponentUtil.SafeSetActive(tag.gameObject, data.tag ~= nil and data.tag ~="")
        if(data.tag ~= nil and data.tag ~="") then
            tag.sprite = tagSpriteHolder:FindSpriteByName(data.tag)
        end
        table.insert(self.toggles, itemObj)
        if(data.parlorNum) then
            itemObj.textNum.text ="0".. data.parlorNum
        end
        if(data.parlorLogo) then
            data.imageHead = data.parlorLogo
        else
            data.imageHead = data.headImg
        end
        TableUtil.only_download_head_icon(imageHead, data.imageHead)

        self:set_image_fill(imageHead,182)
    end
end

function ChessMuseumView:fillItem_roomList_extend(item)
    local itemObj = {}
    local data = item.data

    itemObj.headImgs = {}
    itemObj.nicks = {}
    itemObj.headObjs = {}
    for i =1, 6 do
        itemObj.headImgs[i] = GetComponentWithPath(item.gameObject, "players/player ("..i..")/mask/HeadBG/Head (1)", ComponentTypeName.Image)
        itemObj.headImgs[i].sprite = self.defaultHeadSpr_extend
        itemObj.nicks[i] = GetComponentWithPath(item.gameObject, "players/player ("..i..")/Text", ComponentTypeName.Text)
        itemObj.nicks[i].gameObject:SetActive(false)

        itemObj.headObjs[i] =GetComponentWithPath(item.gameObject, "players/player ("..i..")", ComponentTypeName.Transform).gameObject
        itemObj.headObjs[i].gameObject:SetActive(false)
    end
    itemObj.wanfa = GetComponentWithPath(item.gameObject, "Text1", ComponentTypeName.Text)
    itemObj.fanghao = GetComponentWithPath(item.gameObject, "Text2", ComponentTypeName.Text)
    itemObj.jushu = GetComponentWithPath(item.gameObject, "Text3", ComponentTypeName.Text)


    local ju = "局"

    if data.playRule ~= "" then
        local wanfaName = ""
        local ruleName = ""
        local renshu = 4
        local rule = ModuleCache.Json.decode(data.playRule)
        rule.PayType = -1

        if rule.roundCount and rule.roundCount >= 100 then
            ju = "胡"
        end

        rule = ModuleCache.Json.encode(rule)
        wanfaName,ruleName,renshu = TableUtil.get_rule_name(rule , false)
        itemObj.wanfa.text = "玩法:".. ruleName
    end

    itemObj.fanghao.text = "房号:"..data.roomId
    if data.curRound and data.curRound >0 then

        itemObj.jushu.text = data.curRound.."/"..data.roundCount
    else
        if(data.roomType == 1) then
            itemObj.jushu.text = "自由开房("..data.roundCount ..ju..")"
        else
            itemObj.jushu.text = "快速组局("..data.roundCount ..ju..")"
        end
    end

    for i= 1, data.playerCount do
        itemObj.headObjs[i].gameObject:SetActive(true)
    end

    for i= 1, #data.players do
        TableUtil.only_download_head_icon(itemObj.headImgs[i], data.players[i].headImg)

        itemObj.nicks[i].gameObject:SetActive(true)
        itemObj.nicks[i].text =Util.filterPlayerName(data.players[i].playerName, 10)
    end

end

function ChessMuseumView:fillItem_roomList(item)
    local itemObj = {}
    local data = item.data

    local ju = "局"
    if data.playRule ~= "" then
        local rule = ModuleCache.Json.decode(data.playRule)
        if rule.roundCount and rule.roundCount >= 100 then
            ju = "胡"
        end
    end

    itemObj.stateSwitcher =  ModuleCache.ComponentManager.GetComponent(item.gameObject,"UIStateSwitcher")
    itemObj.readyTex = GetComponentWithPath(item.gameObject, "Text1", ComponentTypeName.Text)
    itemObj.startTex = GetComponentWithPath(item.gameObject, "Text2", ComponentTypeName.Text)
    itemObj.headImgs = {}
    for i =1, 9 do
        itemObj.headImgs[i] = GetComponentWithPath(item.gameObject, "players/player ("..i..")/HeadBG/Head (1)", ComponentTypeName.Image)
        itemObj.headImgs[i].sprite = self.defaultHeadSpr
    end

    itemObj.readyTex.gameObject:SetActive(not data.curRound or data.curRound == 0)
    itemObj.startTex.gameObject:SetActive(data.curRound and data.curRound > 0)
    if data.curRound and data.curRound >0 then
        itemObj.startTex.text = data.curRound.."/"..data.roundCount
    else
        if(data.roomType == 1) then
            itemObj.readyTex.text = "自由开房("..data.roundCount ..ju..")"
        else
            itemObj.readyTex.text = "快速组局("..data.roundCount ..ju..")"
        end
    end

    itemObj.stateSwitcher:SwitchState(tostring(data.playerCount))

    for i= 1, #data.players do
        TableUtil.only_download_head_icon(itemObj.headImgs[i], data.players[i].headImg)
    end

end

function ChessMuseumView:select_item(index, callback)
    if(#self.dataList == 0) then
        return
    end
    if(index > #self.toggles) then
        index = 1
    end
    self.selectIndex = index

    for i=1,#self.toggles do
        self.toggles[i].toggle.isOn = (i==index)
    end
    local data = self.dataList[index]
    PlayerPrefsManager.SetInt("museumIndex", data.parlorId)
    PlayerPrefsManager.Save()
    -- print("---------------save------------ self.view.selectIndex:", self.selectIndex,PlayerPrefsManager.GetInt("museumIndex", 1))

    if(callback) then
        callback(data)
    end
end

function ChessMuseumView:get_detail(data)
    self.museumData = data

    --self.textNotice.text = self.museumData.notice

    ----TODO XLQ 中文换算成两个字节
    --local str,count = string.gsub(data.parlorName, "[%z\1-\127\194-\244][\128-\191]", "")
    --local num = count*2 + (#str - count)

    if #data.parlorName >24 then
        self.textChessName.text = data.parlorName:sub(1,30) .. "...".."("..data.memberCount..")"
    else
        self.textChessName.text = data.parlorName .. "("..data.memberCount..")"
    end

    self.AccNumTex.text = Util.filterPlayerGoldNum(tonumber(data.cards) + tonumber(data.coins))

    ComponentUtil.SafeSetActive(self.buttonSetting.gameObject, false)
    ComponentUtil.SafeSetActive(self.buttonInfo.gameObject, false)
    ComponentUtil.SafeSetActive(self.buttonSetting.gameObject, data.playerRole == "OWNER" or data.playerRole == "ADMIN")
    ComponentUtil.SafeSetActive(self.buttonInfo.gameObject, data.playerRole ~= "OWNER" and data.playerRole ~= "ADMIN")

    for i = 1,#data.siteInfo do
        if data.siteInfo[i].siteType == "FREE_SITE" then
            self.freeCreateEnable = data.siteInfo[i].enable
            self.freeCreateBtn.gameObject:SetActive(data.siteInfo[i].enable)
        end
    end

    if self.extendToggle.isOn ==  (PlayerPrefsManager.GetInt(tostring(self.modelData.roleData.userID), 0) == 1) then
        self:extend_roomListPanel(PlayerPrefsManager.GetInt(tostring(self.modelData.roleData.userID),0) == 1)
    else
        self.extendToggle.isOn = PlayerPrefsManager.GetInt(tostring(self.modelData.roleData.userID),0) == 1
    end
end

function ChessMuseumView:extend_roomListPanel(isExtend)
    --self.roomList_rectTransform.anchorMin = Vector2.New(1,0)

    if isExtend then
        self.textNotice.text = Util.filterPlayerName(self.museumData.notice, 60)

        --self.extendToggleBg_rectTran.gameObject:SetActive(true)
        --self.extendToggleBg_rectTran.sizeDelta = Vector2.New(488.7,926.4)
        --self.extendToggleBg_rectTran.transform.localPosition =  Vector3.New(-258,24.6,0)

        self.roomList_rectTransform.sizeDelta = Vector2.New(1184 + self.adjustVule,self.roomList_rectTransform.sizeDelta.y)

        self.roomList_scrollRect.content = self.copyParent[3]
        self.copyParent[3].gameObject:SetActive(true)
        self.copyParent[2].gameObject:SetActive(false)

        --self.roomList_gridLayoutGroup.constraintCount = 4
        --self.roomList_gridLayoutGroup.spacing = Vector2.New(41, 41)

        --if self.freeCreateEnable then
        --    self.refreshListBtn.transform.localPosition =  Vector3.New(334.6,-420.2,0)
        --else
        --    self.refreshListBtn.transform.localPosition =  Vector3.New(-212.9,-420.2,0)
        --end

    else
        self.textNotice.text = Util.filterPlayerName(self.museumData.notice, 43)

        --self.extendToggleBg_rectTran.gameObject:SetActive(fasle)
        --self.extendToggleBg_rectTran.sizeDelta = Vector2.New(84,926.4)
        --self.extendToggleBg_rectTran.transform.localPosition =  Vector3.New(-55.8,24.6,0)


        self.roomList_rectTransform.sizeDelta = Vector2.New(878.7 + self.adjustVule,self.roomList_rectTransform.sizeDelta.y)

        self.roomList_scrollRect.content = self.copyParent[2]
        self.copyParent[2].gameObject:SetActive(true)
        self.copyParent[3].gameObject:SetActive(false)

        --self.roomList_gridLayoutGroup.constraintCount = 3
        --self.roomList_gridLayoutGroup.spacing = Vector2.New(23.7, 23.7)
        --
        --if self.freeCreateEnable then
        --    self.refreshListBtn.transform.localPosition =  Vector3.New(11.7,-420.2,0)
        --else
        --    self.refreshListBtn.transform.localPosition =  Vector3.New(-193.3,-420.2,0)
        --end
    end
end

return ChessMuseumView