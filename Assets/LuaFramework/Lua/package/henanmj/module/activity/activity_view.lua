-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local ActivityView = Class('activityView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function ActivityView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/activity/henanmj_windowactivity.prefab", "HeNanMJ_WindowActivity", 1)

    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath

    self.btnClose = GetComponentWithPath(self.root, "Center/closeBtn", ComponentTypeName.Button)
    self.toggleActivity = GetComponentWithPath(self.root, "Center/TitlePanel/ActivityBtn", ComponentTypeName.Toggle)
    self.toggleNotice = GetComponentWithPath(self.root, "Center/TitlePanel/NoticeBtn", ComponentTypeName.Toggle)
    self.dailyActivityPanel = GetComponentWithPath(self.root, "Center/rightScrollView/Viewport/Content/DailyActivityPanel", ComponentTypeName.Transform).gameObject
    self.inviteActivityPanel = GetComponentWithPath(self.root, "Center/rightScrollView/Viewport/Content/InviteActivityPanel", ComponentTypeName.Transform).gameObject
    self.noticePanel = GetComponentWithPath(self.root, "Center/rightScrollView/Viewport/Content/NoticePanel", ComponentTypeName.Transform).gameObject
    self.btnGetDiamond = GetComponentWithPath(self.dailyActivityPanel, "CenterPanel/DiamondBtn", ComponentTypeName.Button)
    self.btnGetGold = GetComponentWithPath(self.dailyActivityPanel, "BottomPanel/GoldBtn", ComponentTypeName.Button)
    self.btnShare   = GetComponentWithPath(self.inviteActivityPanel, "ShareBtn", ComponentTypeName.Button)
    -- local go = GetComponentWithPath(self.dailyActivityPanel, "TopPanel/WebView", ComponentTypeName.Transform).gameObject
    -- self.goLeftTop = GetComponentWithPath(self.dailyActivityPanel, "TopPanel/LeftTop", ComponentTypeName.Transform).gameObject
    -- self.uiCamera = GetComponentWithPath(UnityEngine.GameObject.Find("GameRoot"), "Game/UIRoot/UICamera", "UnityEngine.Camera")
    -- self.goRightBottom = GetComponentWithPath(self.dailyActivityPanel, "TopPanel/RightBottom", ComponentTypeName.Transform).gameObject
    -- self.webview = ModuleCache.ComponentUtil.AddComponent(go, "UniWebViewEx")

    self.scroll = GetComponentWithPath(self.root, "Center/rightScrollView", ComponentTypeName.ScrollRect)

    local go = GetComponentWithPath(self.scroll.gameObject, "Viewport/Content/WebViewPanel/WebView", ComponentTypeName.Transform).gameObject
    self.goLeftTop = GetComponentWithPath(self.scroll.gameObject, "Viewport/Content/WebViewPanel/LeftTop", ComponentTypeName.Transform).gameObject
    self.uiCamera = GetComponentWithPath(UnityEngine.GameObject.Find("GameRoot"), "Game/UIRoot/UICamera", "UnityEngine.Camera")
    self.goRightBottom = GetComponentWithPath(self.scroll.gameObject, "Viewport/Content/WebViewPanel/RightBottom", ComponentTypeName.Transform).gameObject
    self.webview = ModuleCache.ComponentManager.AddComponent(go, "UniWebViewEx")

    self.toggles = {}
    for i=1,5 do
        table.insert(self.toggles,
            GetComponentWithPath(self.root, "Center/leftPanel/Btn0"..i, ComponentTypeName.Toggle)
        )
    end
end

function ActivityView:showUI()
    self:showActivity()
end

function ActivityView:showActivity()
    local panelIndex = self:getIsOnToggle()
    self.scroll.enabled = false
    self:setToggle(self.toggles[1],"每日活动")
    self:setToggle(self.toggles[2],"邀请有奖")
    if(panelIndex == 1)then
        self:showDailyActivity()
    elseif(panelIndex == 2)then    
        self:showInviteActivity()
    end
end

function ActivityView:resetLeftToggles( ... )
    for i=1,5 do
        self.toggles[i].isOn = (i==1)
        self.toggles[i].gameObject:SetActive(i==1)
    end
end

function ActivityView:setToggle(toggle,title)
    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    local toggleText1 = GetComponentWithPath(toggle.gameObject, "Background/Label", ComponentTypeName.Text)
    local toggleText2 = GetComponentWithPath(toggle.gameObject, "Checkmark/Label", ComponentTypeName.Text)
    toggleText1.text = title
    toggleText2.text = title
    toggle.gameObject:SetActive(true)
end

function ActivityView:hideAllPanel()
    self.dailyActivityPanel:SetActive(false)
    self.inviteActivityPanel:SetActive(false)
    self.noticePanel:SetActive(false)
end

function ActivityView:showDailyActivity( ... )
    self:hideAllPanel()
    self.dailyActivityPanel:SetActive(true)
end


function ActivityView:showInviteActivity( ... )
    self:hideAllPanel()
    self.inviteActivityPanel:SetActive(true)
end

function ActivityView:showNotice( ... )
    self:setToggle(self.toggles[1],"游戏公告")
    self.scroll.enabled = true
    self:hideAllPanel()
    self.noticePanel:SetActive(true)
end

function ActivityView:getIsOnToggle()
    for i=1,5 do
        if(self.toggles[i].isOn)then
            return i
        end
    end
    return 1
end

function ActivityView:getIsShowPanel()
    if(self.toggleActivity.isOn)then return 1; end
    if(self.toggleNotice.isOn) then return 2; end
end

function ActivityView:initUniWebView()
    self.webview:Init()
    self.webview:SetEdgeInsets(self.uiCamera, self.goLeftTop, self.goRightBottom)
end

return ActivityView