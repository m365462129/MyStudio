-- ===============================================================================================--
-- data:2017.4.20 
-- author:dred
-- desc: 商城模块
-- ===============================================================================================--
-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local ShopModule = class("BullFight.ShopModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

function ShopModule:initialize(...)
	-- 开始初始化                view        model           模块数据
	ModuleBase.initialize(self, "shop_view", nil, ...)

	for k,v in ipairs(self.shopView.togglesContents) do
		self.shopView.toggles[tonumber(v.name)].onValueChanged:AddListener(function()
			if (self.shopView.toggles[tonumber(v.name)].isOn) then
				self.curPage = tonumber(v.name)
				self.shopView.switchers[tonumber(v.name)]:SwitchState("isOn")
				self.view.panelTable[tonumber(v.name)]:SetActive(true)
				-- 若无数据更新则选择不重新获取服务器数据
				if (self.shopData[tonumber(v.name)] == nil) then
					self:get_page_data()
				else
					if (self.curPage == 21) and self.isBuySometing then
						self:get_page_data()
					elseif self.curPage == 23 and self.isSendSomting then
						self:get_page_data()
					else
						self:refresh_view()
					end
				end
			else
				self.shopView.switchers[tonumber(v.name)]:SwitchState("isOff")
				self.view.panelTable[tonumber(v.name)]:SetActive(false)
			end
		end)
	end

	local onAppFocusCallback = function(eventHead, state)
		if ModuleCache.GameManager.iosAppStoreIsCheck then
			return
		end

		self._startH5Pay = false;
		if self:view_is_active() then
			self.isBuySometing = true
			--self.modelData.isNeedUpdateUserInfo = true
			if state then
				ModuleCache.ModuleManager.destroy_module("henanmj", "webview");
				ModuleCache.ModuleManager.hide_public_module("netprompt")
				self._startH5Pay = false;
				self:subscibe_time_event(1, false, 0):OnComplete(function(t)
					print("getUserNewMessage")
					self:getUserNewMessage()
				end)
				--self.shopView:refresh_role_info(self.modelData.roleData)
				self:subscibe_time_event(3.5, false, 0):OnComplete(function(t)
					print("getUserNewMessage")
					self:getUserNewMessage()
				end)
			end
		end
	end

	self:subscibe_app_focus_event(onAppFocusCallback)
end

-- 传入相应的ID转到相应的tag
function ShopModule:on_show(data)
	self.view:hide()
	if (ModuleCache.GameManager.iosAppStoreIsCheck) then
		--self:chargeByAd()
		ModuleCache.WechatManager.onAppstorePaySucess = function(data)
			print("shopmodule__onAppstorePaySucess", data)
			self:chargeByAd()
		end
		--self:chargeByAd()
		ModuleCache.GameSDKInterface:BuyAppStoreProduct(AppData.AppStoreProductName)
		return
	end

	self.curPage = 1
	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[1].gameObject, true)
	self.isBuySometing = false -- 是否在界面内购买(用以刷新记录信息)
	self.isSendSomting = false -- 是否在界面内赠送

	ModuleCache.ComponentUtil.SafeSetActive(self.view.moreShow, false)
	if (data ~= nil) then
		--if type(data) == "table" then
		--	self.curPage = data.page
		--	self.isSpecial = true
		--	self.changeId = ModuleCache.GameManager.curGameId
        --
		--	ModuleCache.ComponentUtil.SafeSetActive(self.view.moreButton, false)
		--	ModuleCache.GameManager.select_game_id(9)
		--else
			self.curPage = data
			self.isSpecial = false
			--ModuleCache.ComponentUtil.SafeSetActive(self.view.moreButton, true)
		--end
	else
		self.isSpecial = false
		--ModuleCache.ComponentUtil.SafeSetActive(self.view.moreButton, true)
	end

	print(self.modelData.isHaveShopPackge)
	if self.modelData.isHaveShopPackge then
		self.curPage = 6
	else
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[6].gameObject, false)
	end


	self.shopData = {}
	for k,v in ipairs(self.shopView.togglesContents) do
		self.shopData[tonumber(v.name)] = nil  -- 按照toggle顺序存储data 此处重置
	end


	self.view:refreshPlayMode()
	self.shopView:refresh_role_info(self.modelData.roleData)

--	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[1].gameObject, not (self.curPage == 2))
--	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[1].gameObject, not (self.curPage == 2))
	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[21].gameObject, not self.isSpecial)
	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[23].gameObject, not self.isSpecial)
	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[22].gameObject, not self.isSpecial)

	self:get_init_data()
	-- self:init_toggles()

	-- self:get_page_data()
end

function ShopModule:on_module_event_bind()
	self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
		self.shopView:refresh_role_info(self.modelData.roleData)
	end)

	self:subscibe_package_event("Event_Buy_Complete",function(eventHead,eventData)
		local msgDecode = ModuleCache.Json.decode(eventData.data.msg)
		if tostring(msgDecode.itemIdList[1]) == tostring(self.goodsData.itemVoList[1].itemId) then
			self.view:showBuyLibaoOk(self.goodsData, msgDecode.context)
			self:dispatch_package_event("Event_Refresh_Bag_Red")
		end
	end)
end

function ShopModule:get_init_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/isBindInvite?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			if #retData.data.products < 1 and #retData.data.discountProducts < 1 then
				ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[1].gameObject, false)
				if self.curPage == 1 then
					self.curPage = 2
				end
			end
		else
			ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[1].gameObject, false)
			if self.curPage == 1 then
				self.curPage = 2
			end
		end
		self:init_toggles()
	end, function(errorData)
		print(errorData.error)
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[1].gameObject, false)
		if self.curPage == 1 then
			self.curPage = 2
		end
		self:init_toggles()
	end)
end

function ShopModule:init_toggles( )
	local playMode = ModuleCache.PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.toggles[5].gameObject, playMode.isOpenGold)
	ModuleCache.ComponentUtil.SafeSetActive(self.view.moreButton, playMode.isOpenGold)
	ModuleCache.ComponentUtil.SafeSetActive(self.view.diamondObj,(not playMode.isOpenGold) )
	ModuleCache.ComponentUtil.SafeSetActive(self.view.goldObj, playMode.isOpenGold)

	for k,v in ipairs(self.shopView.togglesContents) do
		local i = tonumber(v.name)
		self.shopView.toggles[i].isOn = false
		if(i == self.curPage)then
			self.shopView.toggles[self.curPage].isOn = true
		end
	end
	self.view:setToggleScroll()
end

function ShopModule:get_page_data()
	if self.curPage < 20 then
		self:get_shop_products(self.curPage)
	elseif self.curPage == 21 then
		self:get_recharge_server_data()
	elseif self.curPage == 22 then
		self:get_consume_server_data()
	elseif self.curPage == 23 then
		self:get_give_server_data()
	end
end

function ShopModule:refresh_view()
	print("CurPage = "..self.curPage)
	print_table(self.shopData[self.curPage])
	if self.curPage < 20 then
		self.shopView:showShopView(self.shopData[self.curPage],self.curPage)
	else
		self.shopView:showRecordView(self.shopData[self.curPage],self.curPage)
	end
end

function ShopModule:showBuyGoodsDialog(data)
	if self.shopView.isBindInvite then
		self:buy_goods(data.id)
		return
	end
	self.goodsData = data
	self.shopView.dialogInput.text = ""
	ModuleCache.ComponentUtil.SafeSetActive(self.shopView.buyGoodsDialog,true)       
end

function ShopModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	print(obj.name)
	if obj == self.shopView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "shop")
		if ModuleCache.ModuleManager.get_module("henanmj", "hall") then
			ModuleCache.ModuleManager.get_module("henanmj", "hall"):update_userinfo()
			self:dispatch_package_event("Event_Show_Hall_Anim")
			self.view:clear_all_time_event()
		end
	elseif obj.name == "BuyGoodsBtn" then
		local data = self.shopView:get_data(obj.transform.parent.gameObject)
		self.goodsData = data
		self.isBuyLibao = false
		if(self.curPage == 1)then
			-- self:showBuyGoodsDialog(data)  按策划需求屏蔽绑定对话框，改为直接购买
			--self:buy_goods(data.id)
			self:get_pay_type(data.id)
		elseif(self.curPage == 2)then
			-- self:buy_goods(data.id) -- 体力直接购买
			self:get_pay_type(data.id)
		elseif(self.curPage == 5)then
			self:buy_gold_check(data)
		elseif self.curPage == 6 then
			self.view:showLibao(self.goodsData)
		end
	elseif obj.name == "ButtonConfirm" then
		self:bind_invite_code(self.curCode)
	elseif obj.name == "ButtonCancel" then
		self.shopView.bindInviteDialog:SetActive(false)
	elseif "ButtonBind" == obj.name then
		local inviteCode =""
	 	inviteCode =self.shopView.inputFieldInviteCode.text

		if inviteCode == "" and self.shopView.defaultInviteCode ~= inviteCode then
			inviteCode = self.shopView.defaultInviteCodedefaultInviteCode
		end
		
		if ((not inviteCode) or inviteCode == '') then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您输入的邀请码有误，请确认后重新输入")	
			self.shopView.inputFieldInviteCode.text = ""
			return
		end
		self.curCode = inviteCode
		self:get_invite_info(inviteCode)
	elseif obj.name == self.shopView.btnDlgClose.name then
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.buyGoodsDialog,false)    
	elseif obj.name == self.shopView.btnBind.name then
		local inviteCode = self.shopView.dialogInput.text
		if ((not inviteCode) or inviteCode == '') then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您输入的邀请码有误，请确认后重新输入")	
			self.shopView.dialogInput.text = ""
			return
		end
		self.curCode = inviteCode
		self:get_invite_info(inviteCode)
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.buyGoodsDialog,false)    
	elseif obj.name == self.shopView.btnBuy.name then
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.buyGoodsDialog,false)   
		if(self.goodsData ~= nil) then
			--self:buy_goods(self.goodsData.id)
			self:get_pay_type(self.goodsData.id)
		else
			print("没有获取商品信息！")
		end
	elseif obj.name == self.shopView.btnPayClose.name then
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.selectPayDialog,false)
	elseif obj.name == self.shopView.btnAli.name then
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.selectPayDialog, false)
		if (self.goodsData and self.pay_type) then
			self:dahuPay(self.goodsData.id, self.pay_type, "2")
		else
			print("没有获取商品信息！")
		end
	elseif obj.name == self.shopView.btnWechat.name then
		ModuleCache.ComponentUtil.SafeSetActive(self.shopView.selectPayDialog, false)
		if (self.goodsData and self.pay_type) then
			self:dahuPay(self.goodsData.id, self.pay_type, "1")
		else
			print("没有获取商品信息！")
		end
	elseif (obj.name == "ButtonMore") then
		self.view.moreShow:SetActive(not self.view.moreShow.activeSelf)
	elseif obj.name == "BtnCloseLibao" then
		ModuleCache.ComponentUtil.SafeSetActive(self.view.libaoDlg, false)
	elseif obj.name == "BtnBuyLibao" then
		ModuleCache.ComponentUtil.SafeSetActive(self.view.libaoDlg, false)
		self.isBuyLibao = true
		self:get_pay_type(self.goodsData.id)
	elseif obj.name == "BtnStore" then
		ModuleCache.ComponentUtil.SafeSetActive(self.view.buyCplt, false)
	elseif obj.name == "BtnUse" or obj.name == "BtnSendTo" then
		ModuleCache.ComponentUtil.SafeSetActive(self.view.buyCplt, false)
		local post = {}
		post.title = "兑换"
		local token,timestamp  = Util.get_tokenAndTimestamp(self.modelData.roleData.userID)
		local gameName = ModuleCache.AppData.get_url_game_name();
		post.link = self.goodsData.itemVoList[1].exchangeUrl.."&uid=" .. self.modelData.roleData.userID .."&timestamp="..timestamp.."&token=" .. token.."&gameName=" .. gameName.."&apiUrl="..Util.encodeURL(ModuleCache.GameManager.netAdress.httpCurApiUrl)
		ModuleCache.ModuleManager.show_module("public", "agentpage",post);
	end
end

function ShopModule:buy_gold_check(product)
	if self.modelData.roleData.coins == nil then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("体力不足，请充值体力!")
		return
	end

	if product == nil or product.productPrice == nil then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("商品信息错误!")
		return
	end

	if product.payType == 99 then
		self:get_pay_type(product.id)
		return
	end

	if self.modelData.roleData.coins < tonumber(product.productPrice) then
		--ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("体力不足，请充值体力!")
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("体力不足，请充值体力!")
		return
	end
	self:buy_gold(product.id, product.num)
end





function ShopModule:chargeByAd()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "charge/chargeByAd?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			adid = ModuleCache.SecurityUtil.GetMd5HashFromStr("adid"..os.time()..self.modelData.roleData.userID)
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		if(retData.ret and retData.ret == 0)then
			if(retData.data)then
				local offset = retData.data.cards - self.modelData.roleData.cards
				self.modelData.roleData.cards = retData.data.cards
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("充值成功!")
				self:dispatch_module_event("hall", "Event_refresh_userinfo")
				self:dispatch_package_event("Event_Package_Refresh_Userinfo")
				self.shopView:refresh_role_info(self.modelData.roleData)
			end
		else

		end

	end, function(errorData)
		print(errorData.error)
	end)
end

-- 房卡商城数据获取
function ShopModule:get_shop_server_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/isBindInvite?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.view:show()
			self.shopData[1] = retData.data
			-- self.shopView:set_view(self.shopData, self.curPage)
			self:refresh_view()
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 体力商城数据获取
function ShopModule:get_shop_str_server_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getCoinProducts?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.view:show()
			self.shopData[2] = retData.data
			self:refresh_view()
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 商城数据获取
--货币类型,1-钻石 2-体力 3-元宝 4-铜钱 5-金币
function ShopModule:get_shop_products(postId)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getProduct?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			coinType = postId
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			if postId == 5 then
				self:get_gold_limit()
			end
			self.view:show()
			self.shopData[self.curPage] = retData.data
			self:refresh_view()
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

function ShopModule:get_gold_limit()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "product/getExchangeLimit?",
		showModuleNetprompt = false,
		params = {
			uid = self.modelData.roleData.userID,
			coinType = postId
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			--local data = {}
			--data.todayExchange = 100
			--data.maxExchangeNum = 300
			self.view:showGoldLimit(retData.data)
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 充值记录数据获取
function ShopModule:get_recharge_server_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "rechargeHistory/page?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID,
			pageNum = 1,
			pageSize = 50,

		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.view:show()
			self.isBuySometing = false -- 获取了记录数据后重置
			self.shopData[self.curPage] = retData.data
			self:refresh_view()
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 消费记录数据获取
function ShopModule:get_consume_server_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "consumeHistory/page?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID,
			pageNum = 1,
			pageSize = 50,

		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.view:show()
			self.shopData[self.curPage] = retData.data
			self:refresh_view()
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 赠送记录数据获取
function ShopModule:get_give_server_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "giveHistory/page?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			pageNum = 1,
			pageSize = 50,

		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.view:show()
			self.shopData[self.curPage] = retData.data
			self:refresh_view()
		end
	end, function(errorData)
		print(errorData.error)
	end)
end



function ShopModule:get_invite_info(inviteCode)
	print("inviteCode = "..inviteCode)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getSysUserByInviteCode?",
		params = {
			uid = self.modelData.roleData.userID,
			inviteCode = inviteCode
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		if retData.success ~=true then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您输入的邀请码有误，请确认后重新输入")	
			self.shopView.inputFieldInviteCode.text = ""
		else
			self.shopView.bindInviteDialog:SetActive(true)
			-- retData.data.headImg = nil
			self.shopView.bindInviteHeadImg.gameObject:SetActive(retData.data.headImg ~= nil)
			if retData.data.headImg then
				self.shopView.bindInviteNickTex.text = retData.data.realname
			else
				self.shopView.bindInviteNickTex.text = "" .. retData.data.realname
			end

			self.shopView.bindInviteInfoTex.text = "确认输入【<color=#B4381EFF>" ..retData.data.realname .. "</color>】的优惠码【<color=#B4381EFF>"..inviteCode.."</color>】？\n<color=#B4381EFF>确认后即可获得钻石赠送</color>"

			if retData.data.headImg then
				TableUtil.only_download_head_icon(self.shopView.bindInviteHeadImg, retData.data.headImg)
				self.shopView.bindInviteNickTex.transform.localPosition = Vector3.New(14, self.shopView.bindInviteNickTex.transform.localPosition.y, self.shopView.bindInviteNickTex.transform.localPosition.z)
				self.shopView.bindInviteNickTex.alignment= UnityEngine.TextAnchor.MiddleLeft
			else
				self.shopView.bindInviteNickTex.transform.localPosition = Vector3.New(-212.9, self.shopView.bindInviteNickTex.transform.localPosition.y, self.shopView.bindInviteNickTex.transform.localPosition.z)
				self.shopView.bindInviteNickTex.alignment= UnityEngine.TextAnchor.MiddleCenter
			end
		end
	end, function(wwwErrorData)
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(wwwErrorData.error)
	end)
end


-- 绑定邀请码
function ShopModule:bind_invite_code(inviteCode)
	
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/bindInvite?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID,
			inviteCode = inviteCode
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 and retData.data then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("绑定邀请码成功")	
			self.shopView.bindInviteDialog:SetActive(false)


			self.shopData[self.curPage].isBindInvite = true
			if(self.shopData[1]) then
				self.shopData[1].isBindInvite = true
			end
			if(self.shopData[2]) then
				self.shopData[2].isBindInvite = true
			end
			self.shopView:showShopView(self.shopData[self.curPage],self.curPage)

			self.modelData.isNeedUpdateUserInfo = true
			self:getUserNewMessage()
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)	
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

-- 兑换金币
function ShopModule:buy_gold(id, num)
	if not num then
		num = 0
	end
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "product/buy?",
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
			self:getUserNewMessage()
			self:refresh_view()
			if self.view.goldLimit.todayExchange then
				self.view.goldLimit.todayExchange = self.view.goldLimit.todayExchange + num
				self.view:showGoldLimit(self.view.goldLimit)
			else
				self:get_gold_limit()
			end
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end

	end, function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
				end
			end
		end
	end)
end

function ShopModule:get_pay_type(id)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getPayType?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			productId = id
		}
	}

	if ModuleCache.GameManager.customOsType == 1 then
		if not self._startH5Pay then
			requestData.params.config = 1
		else
			print("H5唤醒不起微信，先用原生了")
		end
	end
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.pay_type = retData.data
			if retData.data == "1" then
				self:buy_goods(id)
			elseif retData.data == "4" then
				self:dahuPay(id, self.pay_type, "2")
			else
				self:dahuPay(id, retData.data, "1")
			end
			--if retData.data == "2" or retData.data == "6" then
			--	-- self:buy_goods_2(id)
			--	self:dahuPay(id, retData.data, "1")
			--elseif retData.data == "3" then
			--	self.pay_type = "3"
			--	self:dahuPay(id, "3", "1")
			--elseif retData.data == "4" then
			--	self:dahuPay(id, self.pay_type, "2")
			--elseif retData.data == "5" then
			--	self:dahuPay(id, "5", "1")
			--else
			--	self:buy_goods(id)
			--end
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
				end
			end
		end
	end)
end

function ShopModule:dahuPay(id, pay_type, wap_ype)

	local sceneInfoStr = ""

	if pay_type == "3" then
		sceneInfoStr = self:create_h5_pay_scene_info()
	end

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "pay/dahuPay?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			productId = id,
			payType = pay_type,
			wapType = wap_ype,
			sceneInfo = sceneInfoStr,
			packageName = UnityEngine.Application.identifier,
			WebViewShop = "false"
		}
	}
	if ModuleCache.GameConfigProject.showPackage == "WebViewShop" then
		requestData.params.WebViewShop = "true"
	end

	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self:start_pay(retData.data)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
				end
			end
		end
	end)
end

function ShopModule:create_h5_pay_scene_info()
	local sceneInfoStr = {}
	local h5_info = {}
	sceneInfoStr.h5_info = h5_info
	if ModuleCache.GameManager.customOsType == 2 then
		h5_info.type = "IOS"
	else
		h5_info.type = "Android"
	end
	h5_info.app_name = UnityEngine.Application.productName
	h5_info.bundle_id = UnityEngine.Application.identifier

	sceneInfoStr = ModuleCache.GameUtil.table_encode_to_json(sceneInfoStr)
	return sceneInfoStr
end

-- 微信H5支付
function ShopModule:buy_goods_wexinh5(id)
	local sceneInfoStr = {}
	local h5_info = {}
	sceneInfoStr.h5_info = h5_info
	if ModuleCache.GameManager.customOsType == 2 then
		h5_info.type = "IOS"
	else
		h5_info.type = "Android"
	end
	h5_info.app_name = UnityEngine.Application.productName
	h5_info.bundle_id = UnityEngine.Application.identifier

	sceneInfoStr = ModuleCache.GameUtil.table_encode_to_json(sceneInfoStr)

	print(sceneInfoStr)

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getWxH5PayUrl?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			productId = id,
			sceneInfo = sceneInfoStr,
			packageName = UnityEngine.Application.identifier
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			--local payTable = {}
			--payTable.appId = retData.data.order.app_id
			--payTable.partnerId = retData.data.order.partner_id
			--payTable.key = retData.data.order.key
			--payTable.payType = retData.data.order.wap_type
			--payTable.money = retData.data.order.money
			--payTable.pricePointDec = retData.data.order.subject
			--payTable.subject = self.goodsData.productName
			--payTable.sign = retData.data.order.sign
			--payTable.outTradeNo = retData.data.order.out_trade_no
			--print_table(payTable)

			--ModuleCache.WechatManager.common_recharge(payTable, function(errCode)
			--	if(errCode == 0 or errCode == "0")then
			--		print("I am in pay call back------------------------------------------")
			--		self.isBuySometing = true
			--		self.modelData.isNeedUpdateUserInfo = true
			--		self:getUserNewMessage()
			--	end
			--end)
			self:start_pay(retData.data)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end

		if (self.curPage == 1) then
			self:get_shop_server_data()
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
					if (self.curPage == 1) then
						self:get_shop_server_data()
					end
				end
			end
		end
	end)
end

--发起支付
function ShopModule:start_pay(url)
	url = url .. "&webviewshop=true"
	local data = {
		link = url,
		showType = 1,
		hide = true
	}
	self._startH5Pay = true
	self.isBuySometing = true
	ModuleCache.ModuleManager.destroy_module("henanmj", "webview");
	ModuleCache.ModuleManager.show_module("henanmj", "webview", data);
	print("支付url:", url)
end

-- 新版本掌宜付购买房卡
function ShopModule:buy_goods_2(id, payType)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getZyPayParam?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			productId = id,
			wapType = payType,
			packageName = UnityEngine.Application.identifier
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			local payTable = {}
			payTable.appId = retData.data.order.app_id
			payTable.partnerId = retData.data.order.partner_id
			payTable.key = retData.data.order.key
			payTable.payType = retData.data.order.wap_type
			payTable.money = retData.data.order.money
			payTable.pricePointDec = retData.data.order.subject
			payTable.subject = self.goodsData.productName
			payTable.sign = retData.data.order.sign
			payTable.outTradeNo = retData.data.order.out_trade_no
			print_table(payTable)

			ModuleCache.WechatManager.common_recharge(payTable, function(errCode)
				if(errCode == 0 or errCode == "0")then
					print("I am in pay call back------------------------------------------")
					self.isBuySometing = true
					self.modelData.isNeedUpdateUserInfo = true
					self:getUserNewMessage()
				end
			end)
			-- UnityEngine.Application.OpenURL(retData.data)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end

		if(self.curPage == 1) then
			self:get_shop_server_data()
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
					if(self.curPage == 1) then
						self:get_shop_server_data()
					end
				end
			end
		end
	end)
end

-- 初始版本微信 购买房卡
function ShopModule:buy_goods(id)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getWxPayParam?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			productId = id
		}
	}
	if ModuleCache.AppData.Const_App_Bundle_ID then
		requestData.params.bundleId = ModuleCache.AppData.Const_App_Bundle_ID
	end

	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			ModuleCache.WechatManager.recharge(retData.data, function(errCode)
				if(errCode == 0 or errCode == "0")then
					self.isBuySometing = true
					self.modelData.isNeedUpdateUserInfo = true
					self:getUserNewMessage()
				end
			end)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
    
		if(self.curPage == 1) then
			self:get_shop_server_data()
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					-- ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(retData.message, function()
					-- 	print(retData.message)
					-- end)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
					if(self.curPage == 1) then
						self:get_shop_server_data()
					end
				end
			end
		end
	end)
end

function ShopModule:getUserNewMessage()
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
			self.modelData.roleData.cards = data.cards
			self.modelData.roleData.coins = data.coins
			self.modelData.roleData.gold = data.gold
			self.shopView:refresh_role_info(self.modelData.roleData)
			self:dispatch_package_event("Event_Package_Refresh_Userinfo")
			--if self.isBuyLibao then
			--	data.msg = "手动设置购买成功"
			--end
			if (data.msg) then
				if data.msgType == 6 then
					local msgDecode = ModuleCache.Json.decode(data.msg)
					if tostring(msgDecode.itemIdList[1]) == tostring(self.goodsData.itemVoList[1].itemId) then
						self.view:showBuyLibaoOk(self.goodsData, msgDecode.context)
						self:dispatch_package_event("Event_Refresh_Bag_Red")
					end
				elseif data.msgType == 1 then
					ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(data.msg)
				end

				--if self.isBuyLibao then
				--	self.view:showBuyLibaoOk(self.goodsData)
				--	self.isBuyLibao = false
				--else
				--	ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(data.msg)
				--end
			end
		else

		end
	end, function(errorData)
		print(errorData.error)
	end)
end

return ShopModule



