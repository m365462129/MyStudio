-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local ActivityModule = class("BullFight.ActivityModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function ActivityModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "activity_view", "activity_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function ActivityModule:on_module_inited()

end

-- 绑定module层的交互事件
function ActivityModule:on_module_event_bind()

end

-- 绑定Model层事件，模块内交互
function ActivityModule:on_model_event_bind()
	

end

function ActivityModule:set_view_values()

end

function ActivityModule:on_show(data)
    --self.view:showUI()
    self.view:initUniWebView()
    self.view.webview:Load("www.baidu.com")--"file:///Users/apple/UnityProject/CrazyCrowBoyCollection/Assets/StreamingAssets/index.html")
    self.view.webview.onLoadComplete = function( ... )
        print("加载完成")
        self.view.webview:Show()

        self.view.webview:EvaluatingJavaScript("document.getElementById('testDiv').innerHTML='<a href=#>生成的内容1</a>'")
        self.view.webview.onEvalJavaScriptFinished = function(data)
            print("run script finish")
        end
        -- body
    end

    self.view.webview.onReceivedMessage = function(data)
        print("webView recv message ---------------------------------")
        print_table(data)
        print(data.scheme)
        print(data.direction)
    end
    self.view.webview.onReceivedKeyCode = function( ... )
        print("keycode")
    end
end

function ActivityModule:on_click(obj, arg)	
	print_debug(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if(obj == self.view.btnClose.gameObject) then
        ModuleCache.ModuleManager.hide_module("henanmj","activity")
    elseif(obj == self.view.toggleActivity.gameObject)then
        -- self.view:resetLeftToggles()
        -- self.view:showActivity()
    elseif(obj == self.view.toggleNotice.gameObject) then
        -- self.view:resetLeftToggles()
        -- self.view:showNotice()
    elseif(obj == self.view.btnGetDiamond.gameObject) then
        -- do something
    elseif(obj == self.view.btnGetGold.gameObject) then
        -- do something
    elseif(obj == self.view.btnShare.gameObject) then
        -- do something
    elseif(obj == self.view.toggles[1].gameObject) then
        local panelIndex = self.view:getIsShowPanel()
        -- if(panelIndex == 1) then
        --     --每日活动
        --     self.view:showActivity()
        -- elseif(panelIndex == 2) then
        --     --游戏公告
        --     self.view:showNotice()
        -- end
    elseif(obj == self.view.toggles[2].gameObject) then
        -- self.view:showInviteActivity()
    end
end

return ActivityModule



