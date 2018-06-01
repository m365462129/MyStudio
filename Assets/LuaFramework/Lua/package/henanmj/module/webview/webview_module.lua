-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local WebViewModule = class("BullFight.WebViewModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

function WebViewModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "webview_view", nil, ...)
end

-- 	if (mWebView == null) {
--             mWebView = HelpFun.AddChild<UniWebView>(view.webViewParentGameObject);
--             //mWebView.OnReceivedMessage += OnReceivedMessage;
--             //mWebView.OnLoadComplete += OnLoadComplete;
--             //mWebView.OnWebViewShouldClose += OnWebViewShouldClose;
--             //mWebView.OnEvalJavaScriptFinished += OnEvalJavaScriptFinished;
--             mWebView.backButtonEnable = false;
--             mWebView.SetBackgroundColor(new Color(0f, 0f, 0f, 0f));
--             mWebView.SetShowSpinnerWhenLoading(false);
--             mWebView.immersiveMode = false;
--             //mWebView.InsetsForScreenOreitation += InsetsForScreenOreitation;
--             float left = ComponentBuffer.instance.ui.uiCamera.WorldToScreenPoint(view.windowTrans.Find("Pos/Left").position).x;
--             float right = ComponentBuffer.instance.ui.uiCamera.WorldToScreenPoint(view.windowTrans.Find("Pos/Right").position).x;
--             float top = ComponentBuffer.instance.ui.uiCamera.WorldToScreenPoint(view.windowTrans.Find("Pos/Top").position).y;
--             float bottom = ComponentBuffer.instance.ui.uiCamera.WorldToScreenPoint(view.windowTrans.Find("Pos/Bottom").position).y;

--             mWebViewRect[0] = Screen.height - (int)top;
--             mWebViewRect[1] = (int)left;
--             mWebViewRect[2] = (int)bottom;
--             mWebViewRect[3] = Screen.width - (int)right;

-- #if UNITY_IPHONE
--             if (Application.platform != RuntimePlatform.OSXEditor) {
--                 mWebViewRect[0] /= 2;
--                 mWebViewRect[1] /= 2;
--                 mWebViewRect[2] /= 2;
--                 mWebViewRect[3] /= 2;
--             }
-- #endif
--             //Debug.Log(string.Format("height:{0} - width:{1}", Screen.height, Screen.width));
-- #if DEBUG
--             //Debug.Log(string.Format("UniWebView left:{0} - right:{1} - top:{2} - bottom:{3} -- Screen.height:{4} -- Screen.width:{5}", left, right, top, bottom, Screen.height, Screen.width));
--             //Debug.Log(string.Format("UniWebView top:{0} - left:{1} - bottom:{2} - right:{3}", mWebViewRect[0], mWebViewRect[1], mWebViewRect[2], mWebViewRect[3]));
-- #endif
--             mWebView.insets = new UniWebViewEdgeInsets(mWebViewRect[0], mWebViewRect[1], mWebViewRect[2], mWebViewRect[3]);
--             //Debug.Log(string.Format("top:{0}, left:{1}, bottom:{2}, right:{3}", top, left, bottom, right));


function WebViewModule:on_show(intentData)
	if intentData then
		ModuleCache.ModuleManager.show_public_module("netprompt")
		print("打开链接" .. intentData.link)
		self.webViewView:initUniWebView(intentData.showType,intentData.style)
		self:subscibe_time_event(12, false, 0):OnComplete(function(t)
			ModuleCache.ModuleManager.hide_public_module("netprompt")
		end)
		self.webViewView.webview:Load(intentData.link)
		self.webViewView.webview.onLoadComplete = function( ... )
			print("加载完成")
			ModuleCache.ModuleManager.hide_public_module("netprompt")
			self.webViewView.webview:Show()
		end

		if intentData.hide then
			self.view:hide_view()
		end
	end
end




function WebViewModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.webViewView.buttonClose.gameObject then
        if self.onBackButton then
            self.onBackButton();
            self.onBackButton = nil;
        end
        self.webViewView.webview:Hide()
        ModuleCache.ModuleManager.destroy_module("henanmj", "webview")
    end
end

-- 添加返回按钮监听
function WebViewModule:addBackButtonListener(callback)

    self.onBackButton = callback;
end

return WebViewModule



