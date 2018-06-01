--
-- User: dred
-- Date: 2016/12/26
-- Time: 15:03
local ModuleCache = ModuleCache
local json = require("cjson")
local tostring = tostring

local ShareSDKManager = {}

function ShareSDKManager.init()
	if ShareSDKManager._init then
		return
	end
	--ShareSDKManager._init = true
	--require("cn.sharesdk.unity3d.ShareSDK")
	--ShareSDKManager._ShareContent = require("cn.sharesdk.unity3d.ShareContent")
	--ShareSDKManager._shareSDK = ModuleCache.ComponentManager.GetComponentWithPath(ModuleCache.GameManager.gameRoot, "ShareSDK", "cn.sharesdk.unity3d.ShareSDK")
	--ShareSDKManager._shareSDK:Init(nil, nil)
	--ShareSDKManager._shareSDK.eventCallback = function(data)
     --   print("========= ShareSDKManager: " .. data)
	--	ModuleCache.ModuleManager.show_public_module_textprompt():show_center_tips(data)
	--end
end

function ShareSDKManager.ShareContent()

	local screenShotDirPath = ModuleCache.UnityEngine.Application.persistentDataPath .. "/screenShot"
	local screenShotPath = screenShotDirPath .. "/screenShot.jpg"
    --ShareSDKManager._shareSDK
    --local shareContent = ShareSDKManager._ShareContent.New()
    --shareContent:SetTitle("测试")
    --shareContent:SetText("测试")
    --shareContent:SetShareType(1)
    --shareContent:SetImageUrl("http://ww3.sinaimg.cn/mw690/be159dedgw1evgxdt9h3fj218g0xctod.jpg")
    ----shareContent:SetHidePlatforms("24");
    ----阿里分享50 QQAndroid--24 QQiOS--998 钉钉--52
    --ShareSDKManager._shareSDK:ShareContent(52, shareContent)

	--local data = {}
	--data.shareApp = "XianLiao"
	--data.text = "测试测试"
	----data.path = path
	--data.imageUrl = "https://img.alicdn.com/tps/TB1ADGXPXXXXXcTapXXXXXXXXXX-520-280.jpg"
	--ModuleCache.GameSDKInterface:ShareUrlToWechat(json.encode(data))

	--local data = {}
	--data.shareApp = "XianLiao"
	--data.roomToken = "3123123123123123"
	--data.roomId = "123123"
	--data.title = "123123"
	--data.text = "123123"
	--data.imageUrl = "https://img.alicdn.com/tps/TB1ADGXPXXXXXcTapXXXXXXXXXX-520-280.jpg"
	--ModuleCache.GameSDKInterface:ShareUrlToWechat(json.encode(data))

	--local data = {}
	--data.shareApp = "XianLiao"
	--data.roomToken = "3123123123123123"
	--data.roomId = "123123"
	--data.title = "123123"
	--data.text = "123123"
	--data.path = screenShotPath
	--ModuleCache.GameSDKInterface:ShareImageToWechat(json.encode(data))

    --ModuleCache.GameSDKInterface:StartApp("alipay://")

	local data = {}
	data.shareApp = "Alipay"
	data.title = "测试测试"
	data.desc = "哈哈"
	data.sceneType = "0"
	data.thumbUrl = "https://img.alicdn.com/tps/TB1ADGXPXXXXXcTapXXXXXXXXXX-520-280.jpg"
	data.wepageUrl = "https://img.alicdn.com/tps/TB1ADGXPXXXXXcTapXXXXXXXXXX-520-280.jpg"
	ModuleCache.GameSDKInterface:ShareUrlToWechat(json.encode(data))
end




--ShareSDKManager.init()
return ShareSDKManager

