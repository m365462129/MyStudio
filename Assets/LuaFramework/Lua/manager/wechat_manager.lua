--
-- User: dred
-- Date: 2016/12/26
-- Time: 15:03
-- 微信管理接口  https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317853&token=&lang=zh_CN
local ModuleCache = ModuleCache
local PlayerPrefs = UnityEngine.PlayerPrefs
local json = require("cjson")
local tostring = tostring

--local OPEN_ID = "WechatOpenId"
--function CoExample()
--    WaitForSeconds(1)
--    print('WaitForSeconds end time: ' .. UnityEngine.Time.time)
--    WaitForFixedUpdate()
--    print('WaitForFixedUpdate end frameCount: ' .. UnityEngine.Time.frameCount)
--    WaitForEndOfFrame()
--    print('WaitForEndOfFrame end frameCount: ' .. UnityEngine.Time.frameCount)
--    Yield(null)
--    print('yield null end frameCount: ' .. UnityEngine.Time.frameCount)
--    Yield(0)
--    print('yield(0) end frameCime: ' .. UnityEngine.Time.frameCount)
--    local www = UnityEngine.WWW('http://www.baidu.com')
--    Yield(www)
--    print('yield(www) end time: ' .. UnityEngine.Time.time)
--    local s = tolua.tolstring(www.bytes)
--    print(s:sub(1, 128))
--    print('coroutine over')
--end

local WechatManager = {}

ModuleCache.GameSDKCallback.instance.gameSdkCallback = function(eventName, data)
	--print("wechat recv eventName = "..eventName)
	local fun = WechatManager[eventName]
	if fun then
		fun(data)
	end
	WechatManager.jMsgCallback(eventName, data)
end



-- 微信登录
function WechatManager.login(onLoginSucess, onLoginError)
	WechatManager._onLoginSucess = onLoginSucess
	WechatManager._onLoginError = onLoginError
	ModuleCache.GameSDKInterface:LoginWechat()
end

-- ModuleCache.GameSDKCallback.instance.gameSdkCallback 中的回调函数，采用C#那边的命名规则
function WechatManager.onLoginWechatResult(data)
	local jsonRet = json.decode(data)
	if jsonRet and (jsonRet.result== 0 ) and WechatManager._onLoginSucess then
		WechatManager._onLoginSucess(jsonRet)
	else
		print("微信获取参数失败，或者没有监听函数：" .. data)
	end
end

-- 微信充值返回参数
-- ERR_OK = 0;
-- ERR_COMM = -1;
-- ERR_USER_CANCEL = -2;
-- ERR_SENT_FAILED = -3;
-- ERR_AUTH_DENIED = -4;
-- ERR_UNSUPPORT = -5;
-- ERR_BAN = -6;
function WechatManager.onWechatRecharge(errorCode)
	if WechatManager._onRecharge then
		WechatManager._onRecharge(errorCode)
	end
end

--- 分享链接
-- @param sceneType 0为好友/群 1为朋友圈
-- @param title 标题 
-- @param content 内容 
-- @param url 链接
function WechatManager.share_url(sceneType, title, content, url)
	--print_traceback("===")
	local data = {}
	data.sceneType = tostring(sceneType)
	data.title = title 
	data.content = content 
	data.url = url
	ModuleCache.GameSDKInterface:ShareUrlToWechat(json.encode(data))
end

--- 分享图片
-- @param type 0为好友/群 1为朋友圈
function WechatManager.share_image(sceneType, title, path)
	local data = {}
	data.sceneType = tostring(sceneType)
	data.title = title
	data.path = path
	ModuleCache.GameSDKInterface:ShareImageToWechat(json.encode(data))
end

-- 分享文本
-- @param type 0为好友/群 1为朋友圈
function WechatManager.share_text(sceneType, title,content)
	local data = {}
	data.sceneType = tostring(sceneType)
	data.title = title
	data.content = content
	ModuleCache.GameSDKInterface:ShareText(json.encode(data))
end

function WechatManager.recharge(data, onRecharge)
	WechatManager._onRecharge = onRecharge
	ModuleCache.GameSDKInterface:WechatRecharge(json.encode(data))
end

function WechatManager.common_recharge(data,onRecharge)
	WechatManager._onRecharge = onRecharge
	ModuleCache.GameSDKInterface:CommonRecharge(json.encode(data))
end

function WechatManager.registMWEnterRoomCallback(callback)
	WechatManager._onMWEnterRoom = callback
end


function WechatManager.onMWEnterRoom(roomId)
	if(WechatManager._onMWEnterRoom)then
		WechatManager._onMWEnterRoom(roomId)
	end
end

function WechatManager.onBeginLocation(isRegeocode, callback)
	WechatManager._onBeginLocation = callback
	-- 做一个优化点，先停止位置获取，再开始
	ModuleCache.GameSDKInterface:StopLocation()
	ModuleCache.GameSDKInterface:BeginLocation(isRegeocode)
end

function WechatManager.caculate_distance(latitude1, longitude1, latitude2, longitude2)
	return ModuleCache.GameSDKInterface:CaculateDistance(latitude1, longitude1, latitude2, longitude2)
end

function WechatManager.onGetLocationResult(data)
	if WechatManager._onBeginLocation then
		if data == "" then
			WechatManager._onBeginLocation({})
		else
			WechatManager._onBeginLocation(json.decode(data))
		end
	end
end

function WechatManager.onGetIpsByHttpDNSResult(data)
	if WechatManager._onGetIpsByHttpDNSResult then
		WechatManager._onGetIpsByHttpDNSResult(data)
	end
end


function WechatManager.setCallBabk(eventName, callback)
	print("setCallBabk ====", eventName, callback)
	WechatManager.eventName = callback
end

function WechatManager.jMsgCallback(eventName, data)
	ModuleCache.JMsgManager.recvCallback(eventName, data)
end

function WechatManager.OnShowPhotoCallback(data)
	if WechatManager.ImageSizeV2 then
		ModuleCache.CustomImageManager.upload_image_file(data, WechatManager.ImageSizeV2)
	else
		print("###########没有收到图片尺寸#########")
		ModuleCache.CustomImageManager.upload_image_file(data)
	end

end

function WechatManager.OnSendImageSizeCallback(width,hight)
	WechatManager.ImageSizeV2 = Vector2.New(width,hight)
	print("================OnSendImageSizeCallback===========",width,hight,WechatManager.ImageSizeV2.x,WechatManager.ImageSizeV2.y)
end


function WechatManager.onXianLiaoShareResp(eventData, callback)
	print("onXianLiaoShareResp ====", eventData, callback)

	ModuleCache.ModuleManager.show_public_module_textprompt():show_center_tips(eventData)
end

function WechatManager.onAlipayResp(eventName, callback)
	print("onAlipayResp ====", eventName, callback)
	ModuleCache.ModuleManager.show_public_module_textprompt():show_center_tips(eventData)
end

ModuleCache.GameSDKInterface:InitWechat(AppData.WECHAT_APPID)

return WechatManager

