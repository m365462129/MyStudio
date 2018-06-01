-- ===============================================================================================--
-- data:2017.4.20 
-- author:dred
-- desc: 商城模块
-- ===============================================================================================--
-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MuseumShopModule = class("museumShopModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

function MuseumShopModule:initialize(...)
	-- 开始初始化                view        model           模块数据
	ModuleBase.initialize(self, "museumshop_view", nil, ...)
	
end

function MuseumShopModule:on_show()
	self.view:hide()			
	if(ModuleCache.GameManager.iosAppStoreIsCheck)then
		ModuleCache.GameSDKInterface:ShowRewardedAd(function(result)
			if(result == "Finished")then
				self:chargeByAd()
			elseif(result == "Skipped")then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("观看完整广告才能获得奖励")	
			elseif(result == "Failed")then

			else 
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("广告组件加载中...")	
			end
		end)
		return
	end
	self.view:refresh_role_info(self.modelData.roleData)
	self:get_shop_server_data()
end

function MuseumShopModule:chargeByAd()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "charge/chargeByAd?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			adid = ModuleCache.SecurityUtil.GetMd5HashFromStr("adid"..os.time()..self.modelData.roleData.userID)
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		if(retData.ret and retData.ret == 0)then
			if(retData.data)then
				local offset = retData.data.cards - self.modelData.roleData.cards
				self.modelData.roleData.cards = retData.data.cards
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("恭喜获得" .. offset .. self.modelData.consumeProductName)
				self:dispatch_module_event("hall", "Event_refresh_userinfo")
				self:dispatch_package_event("Event_Package_Refresh_Userinfo")
				self.view:refresh_role_info(self.modelData.roleData)
			end
		else
			
		end
		
	end, function(errorData)
		print(errorData.error)
	end)
end

function MuseumShopModule:get_shop_server_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getCoinProducts?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.view:show()
			self.shopData = retData.data
			self.view:set_view(self.shopData)
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

function MuseumShopModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "museumshop")
		--ModuleCache.ModuleManager.show_module("henanmj", "chessmuseum")
	elseif obj.name == "BuyGoodsBtn" then
		local data = self.view:get_data(obj.transform.parent.gameObject)
		self:buy_goods(data.id)
		-- ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("购买" .. data.productName .. "房卡")	
	elseif "ButtonBind" == obj.name then
		local inviteCode = tonumber(self.view.inputFieldInviteCode.text)
		if ((not inviteCode) or inviteCode == 0) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请输入正确格式的邀请码")	
			return
		end
		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common("是否绑定邀请码:" .. inviteCode, function()
			self:bind_invite_code(inviteCode)
		end)
	elseif obj.name == "GiveGoodsBtn" then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("此功能暂未开放")
		-- local data = self.view:get_data(obj.transform.parent.gameObject)
		-- ModuleCache.ModuleManager.show_module("henanmj", "givegoods",data)
	end
end

-- 绑定邀请码
function MuseumShopModule:bind_invite_code(inviteCode)
	
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/bindInvite?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID,
			inviteCode = inviteCode
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 and retData.data then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("绑定邀请码成功")	
			self.shopData.isBindInvite = true
			self.view:set_view(self.shopData)

			self.modelData.isNeedUpdateUserInfo = true
			self:getUserNewMessage()
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)	
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 购买房卡
function MuseumShopModule:buy_goods(id)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getWxPayParam?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID,
			productId = id
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			ModuleCache.WechatManager.recharge(retData.data, function(errCode)
				if(errCode == 0 or errCode == "0")then
					self.modelData.isNeedUpdateUserInfo = true
					self:getUserNewMessage()
				end
			end)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)	
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

function MuseumShopModule:getUserNewMessage()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "msg/getNewMsg?",
		params = {
			uid = self.modelData.roleData.userID,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.modelData.isNeedUpdateUserInfo = false
			local data = retData.data
			self.modelData.roleData.coins = data.coins
			if(data.msg)then
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(data.msg)
			end
		else

		end
	end, function(errorData)
		print(errorData.error)
	end)
end

return MuseumShopModule



