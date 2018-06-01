-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
local ShopView = Class('shopView', View)

local ModuleCache = ModuleCache
local UnityEngine = UnityEngine

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function ShopView:initialize(...)
	-- 初始View
	View.initialize(self, "henanmj/module/shop/henanmj_windowshop.prefab", "HeNanMJ_WindowShop", 1)
	View.set_1080p(self)
	self.buttonClose = GetComponentWithPath(self.root, "Top/TopLeft/closeBtn", ComponentTypeName.Button)

	self.toggleScroll  = GetComponentWithPath(self.root, "Center/Toggles/Scroll", ComponentTypeName.ScrollRect)
	self.toggleContent = GetComponentWithPath(self.root, "Center/Toggles/Scroll/Viewport/Content", ComponentTypeName.RectTransform)
	
	-- BindCode  钻石
	self.objInviteCode = GetComponentWithPath(self.root, "Top/PanelBindInviteCodePrompt", ComponentTypeName.Transform).gameObject
	self.buttonBindInviteCode = GetComponentWithPath(self.objInviteCode, "ButtonBind", ComponentTypeName.Button)
	self.inputFieldText = GetComponentWithPath(self.objInviteCode, "InputFieldInviteCode/Placeholder", ComponentTypeName.Text)
	self.inputFieldInviteCode = GetComponentWithPath(self.objInviteCode, "InputFieldInviteCode", ComponentTypeName.InputField)

	self.cashTileText = GetComponentWithPath(self.root, "Center/Panels/1/InfoImg/TextInfoEx (2)", ComponentTypeName.Text)

	-- 已弃用的text
	self.bindInfoText = GetComponentWithPath(self.root, "Center/TextBindInfo", ComponentTypeName.Text)

	-- Top TextInfo
	--self.textInfo = GetComponentWithPath(self.root, "Top/Child/TextInfo", ComponentTypeName.Text)

	-- Bottom TextInfo
	self.textInfoEx = GetComponentWithPath(self.root, "Top/TopLeft/TextInfoEx", ComponentTypeName.Text)

	-- self.content = GetComponentWithPath(self.root, "Center/Panels/RoomCardGoodsScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject

	-- roomCard
	self.diamondObj = GetComponentWithPath(self.root, "Top/TopRight/RoomCard", ComponentTypeName.Transform).gameObject
	self.goldObj    = GetComponentWithPath(self.root, "Top/TopRight/GoldCard", ComponentTypeName.Transform).gameObject
	self.textOwnRoomCardNum = GetComponentWithPath(self.root, "Top/TopRight/RoomCard/TextNum", ComponentTypeName.Text)
	self.textOwnTiliNum = GetComponentWithPath(self.root, "Top/TopRight/TiliCard/TextNum", ComponentTypeName.Text)
	self.textOwnDiamondNum = GetComponentWithPath(self.root, "Top/TopRight/TiliCard/bgShop/moreShow/text", ComponentTypeName.Text)
	self.textOwnGoldNum = GetComponentWithPath(self.root, "Top/TopRight/GoldCard/TextNum", ComponentTypeName.Text)
	self.textCardName = GetComponentWithPath(self.root, "Top/TopRight/RoomCard/TextName", ComponentTypeName.Text)
	self.textCardName.text = ""



	self.bindInviteDialog = GetComponentWithPath(self.root,"BindInviteDialog",ComponentTypeName.Transform).gameObject
	self.bindInviteHeadImg =GetComponentWithPath(self.root,"BindInviteDialog/Center/headImg",ComponentTypeName.Image)
	self.bindInviteNickTex =GetComponentWithPath(self.root,"BindInviteDialog/Center/nickTex",ComponentTypeName.Text)
	self.bindInviteInfoTex =GetComponentWithPath(self.root,"BindInviteDialog/Center/TextTipInfo",ComponentTypeName.Text)

	self.buyGoodsDialog  = GetComponentWithPath(self.root,"BuyGoodsDialog",ComponentTypeName.Transform).gameObject
	self.dialogInput     = GetComponentWithPath(self.buyGoodsDialog,"Center/Input",ComponentTypeName.InputField)
	self.btnDlgClose     = GetComponentWithPath(self.buyGoodsDialog,"Center/BtnClose",ComponentTypeName.Button)
	self.btnBind         = GetComponentWithPath(self.buyGoodsDialog,"Center/BtnBind",ComponentTypeName.Button)
	self.btnBuy          = GetComponentWithPath(self.root,"BuyGoodsDialog/Center/BtnOK",ComponentTypeName.Button)

	self.selectPayDialog = GetComponentWithPath(self.root,"SelectPayDialog",ComponentTypeName.Transform).gameObject
	self.btnAli          = GetComponentWithPath(self.selectPayDialog,"Center/BtnAli",ComponentTypeName.Button)
	self.btnWechat       = GetComponentWithPath(self.selectPayDialog,"Center/BtnWechat",ComponentTypeName.Button)
	self.btnPayClose     = GetComponentWithPath(self.selectPayDialog,"Center/BtnClosePay",ComponentTypeName.Button)

	self.slider          = GetComponentWithPath(self.root,"Center/Panels/5/PanelCool/Slider",ComponentTypeName.Slider)
	self.sliderText      = GetComponentWithPath(self.root,"Center/Panels/5/PanelCool/Slider/Text",ComponentTypeName.Text)

	self.libaoDlg        = GetComponentWithPath(self.root,"LiBaoDialog",ComponentTypeName.Transform).gameObject
	self.buyCplt         = GetComponentWithPath(self.root,"BuyComplete",ComponentTypeName.Transform).gameObject


	-- 钻石商城的显示区域需要动态改变
	self.dimScroll = GetComponentWithPath(self.root,"Center/Panels/1/Scroll",ComponentTypeName.RectTransform)
	self.tiliScroll = GetComponentWithPath(self.root,"Center/Panels/2/Scroll",ComponentTypeName.RectTransform)

	self.togglesContents = TableUtil.get_all_child(GetComponentWithPath(self.root,"Center/Toggles/Scroll/Viewport/Content", ComponentTypeName.Transform))
	self.toggles = {}
	self.switchers = {}
	for k,v in ipairs(self.togglesContents) do
		self.switchers[tonumber(v.name)] = ModuleCache.ComponentManager.GetComponent(v.gameObject, "UIStateSwitcher")
		self.toggles[tonumber(v.name)] = ModuleCache.ComponentManager.GetComponent(v.gameObject, ComponentTypeName.Toggle)--GetComponentWithPath(togglesContent.gameObject,tostring(i), ComponentTypeName.Toggle)
	end

	local panels = TableUtil.get_all_child(GetComponentWithPath(self.root,"Center/Panels", ComponentTypeName.Transform))
	self.panelTable = {}
	for k,v in ipairs(panels) do
		self.panelTable[tonumber(v.name)] = GetComponentWithPath(self.root,"Center/Panels/"..v.name, ComponentTypeName.Transform).gameObject
	end

	self.moreShow = GetComponentWithPath(self.root, "Top/TopRight/TiliCard/bgShop/moreShow", ComponentTypeName.Transform).gameObject
	self.moreButton = GetComponentWithPath(self.root, "Top/TopRight/TiliCard/ButtonMore", ComponentTypeName.Transform).gameObject

	print_table(self.toggles)
	print_table(self.panelTable)


	--self.textInfo.gameObject:SetActive(false)
	self.textInfoEx.gameObject:SetActive(false)
	self.bindInviteDialog:SetActive(false)
	self.buyGoodsDialog:SetActive(false)
end


function ShopView:showShopView(shopData, curPage)

	if(shopData == nil) then return end

	self.curPage = curPage
	local panel = self.panelTable[curPage]
	print("panelname = "..panel.name)

	--if(shopData.message) then
	--	self.textInfo.text = shopData.message
	--	self.textInfo.gameObject:SetActive(true)
	--end

	self.isBindInvite = shopData.isBindInvite

	self.objInviteCode:SetActive(not shopData.isBindInvite)
	self.inputFieldInviteCode.text = ""
	--self.textInfoEx.gameObject:SetActive(true)
	--self.textInfoEx.text = shopData.phone
	self.defaultInviteCode = ""
	--if type(shopData.defaultInviteCode) == "userdata" or shopData.defaultInviteCode == "" then
	--	self.inputFieldText.text = shopData.bindInviteMessage
	--	self.inputFieldText2.text = shopData.bindInviteMessage
	--else
	--	self.defaultInviteCode = shopData.defaultInviteCode
	--	self.inputFieldText.text = shopData.defaultInviteCode
	--	self.inputFieldText2.text = shopData.defaultInviteCode
	--	--self.inputFieldInviteCode2
	--end

	if(shopData.isBindInvite) then
		self:setShopScroll(shopData.discountProducts,panel)
	else
		--self.inputFieldText.text = shopData.bindInviteMessage2
		--self.inputFieldText2.text = shopData.bindInviteMessage2
		self:setShopScroll(shopData.products,panel)
	end

	--self.cashTileText.text = shopData.message
end

function ShopView:changeScrollValue()
	--local scroll = self.dimScroll
    --
	--if(self.curPage == 2) then
	--	scroll = self.tiliScroll
	--end
    --
	--if(self.isBindInvite) then
	--	scroll.SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, 0, 20.5);
	--else
	--	scroll.SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, 0, 132.5);
	--end
end

function ShopView:setShopScroll(productData,panel)
	print_table(productData)
	self.products = productData
	local content = GetComponentWithPath(panel.gameObject,"Scroll/Viewport/Content",ComponentTypeName.Transform)

	local noneTips = GetComponentWithPath(panel.gameObject,"NoneTips",ComponentTypeName.Transform).gameObject
	ComponentUtil.SafeSetActive(noneTips, false)
	print(content.name)
	local contents = TableUtil.get_all_child(content)
	local cloneObj = GetComponentWithPath(panel.gameObject,"ItemPrefabHolder/Item", ComponentTypeName.Transform).gameObject

	print(cloneObj.name)

	-- if(#contens > 0 and not isNeedChange)then return end  -- 售卖物品短期内不会有变化

	for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end
    for i=1,#self.products do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(cloneObj,content.gameObject,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)  
        item.gameObject = obj
        item.data = self.products[i] 
        self:fillShopItem(item, i)
    end

	ComponentUtil.SafeSetActive(noneTips, #self.products <= 0)

end

function ShopView:fillShopItem(item, index)
	local data = item.data
	local textRoomCardNum = GetComponentWithPath(item.gameObject, "NumLbl", ComponentTypeName.Text)
	local textPrice = GetComponentWithPath(item.gameObject, "Price/NumText", ComponentTypeName.Text)
	local buttonBuy = GetComponentWithPath(item.gameObject, "BuyGoodsBtn", ComponentTypeName.Button)
	local buttonBg = GetComponentWithPath(item.gameObject, "BuyGoodsBtn/bg", ComponentTypeName.Transform).gameObject
	local goods = GetComponentWithPath(item.gameObject, "goods", ComponentTypeName.Transform).gameObject

	local limitPanel = GetComponentWithPath(item.gameObject, "Limit", ComponentTypeName.Transform).gameObject
	local limitText = GetComponentWithPath(item.gameObject, "Limit/Text", ComponentTypeName.Text)

	local uiState = GetComponentWithPath(item.gameObject, "Limit", "UIStateSwitcher")
	ComponentUtil.SafeSetActive(limitPanel, false)  

	if(data.isLimitNum or data.isLimitTime) then
	 	-- 先判断字段 若服务器没有同步到所有玩法，也不至于游戏崩溃
		ComponentUtil.SafeSetActive(limitPanel, (data.isLimitNum or data.isLimitTime))
		if(data.isLimitNum)then
			uiState:SwitchState("Num")
			-- limitText.text = data.limitBuyNum.."次"
		end
		if(data.isLimitTime) then
			uiState:SwitchState("Time")
			local curTime = os.time()
			local endTime = self:getDateByString(data.activityEndTime)
			if endTime then
				local sec = tonumber(endTime) - tonumber(curTime)
				ComponentUtil.SafeSetActive(limitPanel, sec > 0)
				if(sec > 0) then
					self:subscibe_time_event(sec, false, 1):OnUpdate(function(t)
						t = t.surplusTimeRound
						limitText.text = self:getTimeString(t)
					end):OnComplete(function(...)
						ModuleCache.ModuleManager.get_module("henanmj","shop"):get_shop_server_data()
					end)
				end
			end

		end
	end

	self:clearGoods(goods)
	if(index > 6) then index = 6 end
	local goodsIndex = index
	if(string.find(data.productName,"体力"))then
		goodsIndex = goodsIndex + 6
	elseif(string.find(data.productName,"金币"))then
		if data.num >= 50000 then
			goodsIndex = 6
		elseif data.num >= 20000  then
			goodsIndex = 5
		elseif data.num >= 10000  then
			goodsIndex = 4
		elseif data.num >= 5000  then
			goodsIndex = 3
		elseif data.num >= 2000  then
			goodsIndex = 2
		else
			goodsIndex = 1
		end
	end

	local goodsItem = GetComponentWithPath(goods, "goods"..goodsIndex, ComponentTypeName.Transform).gameObject
	--local goodsImg = ModuleCache.ComponentUtil.GetComponent(goodsItem, ComponentTypeName.Image)
	ComponentUtil.SafeSetActive(goodsItem, true)  

	local goExtenal = GetComponentWithPath(item.gameObject, "Title/Extenal", ComponentTypeName.Transform).gameObject
	local textExtenalRoomCardNum = GetComponentWithPath(goExtenal, "numLbl", ComponentTypeName.Text)
	local diamon = GetComponentWithPath(goExtenal, "icon1", ComponentTypeName.Transform).gameObject
	local tili = GetComponentWithPath(goExtenal, "icon2", ComponentTypeName.Transform).gameObject

	goExtenal:SetActive(data.giveNum > 0)
	--print("---------------------data.giveType:",data.giveType,data.giveNum)
	if(data.giveType) then
		-- print(tostring(data.giveType))
		-- print(tostring(data.giveType == 1))

		if(data.giveType == 2) then
			ComponentUtil.SafeSetActive(diamon, false)
			ComponentUtil.SafeSetActive(tili, true)
		else
			ComponentUtil.SafeSetActive(diamon, true)
			ComponentUtil.SafeSetActive(tili, false)
		end

	end

	textExtenalRoomCardNum.text = data.giveNum .. ''

	textRoomCardNum.text = data.productName .. ""
	--textRoomCardNumLeft.text = data.productName .. ""
	if data.productPrice then
		textPrice.text = "￥" .. data.productPrice
	end
	if data.salePrice then
		textPrice.text = "￥" .. data.salePrice
	end

	if data.payType == 1 then
		textPrice.text = data.salePrice.."钻石"
	elseif data.payType == 2 then
		textPrice.text = data.salePrice.."体力"
	end
	if self.curPage == 5 then
		buttonBuy.interactable = false
		local cantBuy = GetComponentWithPath(item.gameObject, "cantBuy", ComponentTypeName.Transform).gameObject
		if self.goldLimit then
			local isOverBuy = data.num + self.goldLimit.todayExchange > self.goldLimit.maxExchangeNum
			buttonBuy.interactable = not isOverBuy
			ComponentUtil.SafeSetActive(cantBuy, isOverBuy)
		end
	end


	if self.curPage ~= 6 then
		local th = GetComponentWithPath(item.gameObject, "Price/TH", ComponentTypeName.Transform).gameObject
		local saleText = GetComponentWithPath(th, "Image/Text", ComponentTypeName.Text)
		local priceT = GetComponentWithPath(th, "NumText", ComponentTypeName.Text)
		local textObj = GetComponentWithPath(item.gameObject, "Price/NumText", ComponentTypeName.Transform).gameObject
		if type(data.saleTag) == "userdata" or data.saleTag == "" or data.saleTag == nil then
			ComponentUtil.SafeSetActive(textObj, true)
			ComponentUtil.SafeSetActive(th, false)
		else
			ComponentUtil.SafeSetActive(textObj, false)
			ComponentUtil.SafeSetActive(th, true)
			saleText.text = data.saleTag
			priceT.text = textPrice.text
		end
	elseif self.curPage == 6 then
		local priceT = GetComponentWithPath(item.gameObject, "BuyGoodsBtn/text", ComponentTypeName.Text)
		priceT.text = "充<size=56>"..data.salePrice.."</size>元获得"
	end

	-- local config = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)
	-- if(config.coinName ~= nil) then
	-- 	if(#config.coinName > 6)then
	-- 		name3.text = config.coinName
	-- 	else
	-- 		name2.text = config.coinName
	-- 	end
	-- end
	--if self.curPage == 6 then

		local urlObj = GetComponentWithPath(item.gameObject, "urlImg", ComponentTypeName.Transform).gameObject
		local ex = GetComponentWithPath(item.gameObject, "Title/Extenal", ComponentTypeName.Transform).gameObject
		local gua = GetComponentWithPath(item.gameObject, "Limit", ComponentTypeName.Transform).gameObject
        --
		if urlObj then ComponentUtil.SafeSetActive(urlObj, false) end
		if gua then ComponentUtil.SafeSetActive(gua, false) end
		ComponentUtil.SafeSetActive(urlObj, false)
		if data.attachList then


			for i = 1, #data.attachList do
				local attach = data.attachList[i]
				if not attach.disabled then
					if attach.attachType == 1 then
						if ex then
							local iImg = GetComponentWithPath(ex, "Image", ComponentTypeName.Image)
							self:downImg(attach.url,function(sprite)
								iImg.sprite = sprite
								ComponentUtil.SafeSetActive(diamon, false)
								ComponentUtil.SafeSetActive(tili, false)
								ComponentUtil.SafeSetActive(ex, true)
								ComponentUtil.SafeSetActive(iImg.gameObject, true)
							end)
						end
					elseif attach.attachType == 2 then
						if gua then
							local guaImg = ModuleCache.ComponentUtil.GetComponent(gua, ComponentTypeName.Image)
							self:downImg(attach.url,function(sprite)
								guaImg.sprite = sprite
								ComponentUtil.SafeSetActive(gua, true)
							end)
						end
					elseif attach.attachType == 3 then
						if urlObj then
							local urlImg = ModuleCache.ComponentUtil.GetComponent(urlObj, ComponentTypeName.Image)
							self:downImg(attach.url,function(sprite)
								urlImg.sprite = sprite
								ComponentUtil.SafeSetActive(goodsItem, false)
								ComponentUtil.SafeSetActive(urlObj, true)
							end)
						end

					end
				end
			end
		end
	--end

end

function ShopView:downImg(url,callback)
	ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, sprite)
		if (err) then
			print('error down load ' .. url .. 'failed:' .. err.error)
			if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
				if (self) then
					-- self:startDownLoadHeadIcon(targetImage, url, callback)
				end
			end
		else
			if (not self.isDestroy) then
				if callback then
					callback(sprite)
				end
			end
		end
	end , nil, false)
end

function ShopView:on_hide()
	self:clear_all_time_event()
end

function ShopView:getDateByString(dateStr)
	if(#dateStr < 16) then return nil end
	local Y  = string.sub(dateStr,1,4)
	local M  = string.sub(dateStr,6,7)
	local D  = string.sub(dateStr,9,10)
	local H  = string.sub(dateStr,12,13)
	local MM = string.sub(dateStr,15,16)
	local dateTime = os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=0}  
	return dateTime
end

function ShopView:clearGoods(goods)
	for i=1,12 do
		local obj = GetComponentWithPath(goods, "goods"..i, ComponentTypeName.Transform).gameObject
		ComponentUtil.SafeSetActive(obj, false)  
	end
end

-- 将秒数时间转换为 00:00:00
function ShopView:getTimeString(second)
	local day  = math.floor(second/86400)
	local hour = math.fmod(math.floor(second/3600), 24)
	local min  = math.fmod(math.floor(second/60), 60)
	local sec  = math.fmod(second, 60)
	if(#tostring(hour) == 1) then hour = "0"..hour end
	if(#tostring(min) == 1) then min = "0"..min end
	if(#tostring(sec) == 1) then sec = "0"..sec end
	local str = hour..":"..min..":"..sec
	if day > 0 then
		str = day.."天 "..hour..":"..min..":"..sec
	end

	--if self.curPage == 6 then
		str = "限时".. str
	--end

	return str
end

-- 显示记录类界面
function ShopView:showRecordView(recordData, curPage)
	ComponentUtil.SafeSetActive(self.diamondObj, not (curPage == 7))
	ComponentUtil.SafeSetActive(self.goldObj,  curPage == 7)
	if(recordData == nil) then return end
	self.curPage = curPage
	local panel = self.panelTable[curPage]
	print(panel.name)
	self:setRecordView(recordData.list, panel)
end

function ShopView:setRecordView(recordList, panel)
	ModuleCache.ModuleManager.show_public_module("netprompt")
	local content = GetComponentWithPath(panel.gameObject,"Scroll/Viewport/Content",ComponentTypeName.Transform)
	print(content.name)
	local contents = TableUtil.get_all_child(content)
	local cloneObj = GetComponentWithPath(panel.gameObject,"ItemPrefabHolder/Item", ComponentTypeName.Transform).gameObject

	local noneTips = GetComponentWithPath(panel.gameObject,"NoneTips",ComponentTypeName.Transform).gameObject
	ComponentUtil.SafeSetActive(noneTips, false)

	for i=1,#contents do
        ComponentUtil.SafeSetActive(contents[i], false)
    end
    for i=1,#recordList do
        local obj = nil
        local item = {}
        if(i<=#contents) then
            obj = contents[i]
        else
            obj = TableUtil.clone(cloneObj,content.gameObject,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)  
        item.gameObject = obj
        item.data = recordList[i]
        self:fillRecordItem(item, i)
    end
	ModuleCache.ModuleManager.hide_public_module("netprompt")
	ComponentUtil.SafeSetActive(noneTips, #recordList <= 0)
end

function ShopView:fillRecordItem(item, index)
	local txtTitle = GetComponentWithPath(item.gameObject, "Title", ComponentTypeName.Text)
	local txtTime  = GetComponentWithPath(item.gameObject, "Time", ComponentTypeName.Text)
	local txtInfo  = GetComponentWithPath(item.gameObject, "Info", ComponentTypeName.Text)
	local data     = item.data
	txtTitle.text  = data.title
	txtTime.text   = data.time
	txtInfo.text   = data.content
end

function ShopView:showGoldLimit(data)
	--if self.slider.value > data.todayExchange then
	--	self.slider.value = 0
	--end
	self.goldLimit = data
	self.sliderText.text = data.todayExchange.."/"..data.maxExchangeNum
	self.slider.value = data.todayExchange/data.maxExchangeNum
	self:setShopScroll(self.products,self.panelTable[self.curPage])
	--local sequence = self:create_sequence();
	--sequence:Append(self.slider.DOValue( data.todayExchange/data.maxExchangeNum,1,false))
end


function ShopView:get_data(obj)
    return self.products[tonumber(obj.name)]
end

function ShopView:refresh_role_info(roleData)
	if(roleData.cards) then
		self.textOwnRoomCardNum.text = roleData.cards .. ""
		self.textOwnDiamondNum.text = roleData.cards .. ""
	end

	if roleData.coins then
		self.textOwnTiliNum.text = roleData.coins..""
	end

	if roleData.gold then
		self.textOwnGoldNum.text = roleData.gold..""
	end
end


function ShopView:refreshPlayMode()
	-- local GetComponent = ModuleCache.ComponentUtil.GetComponent
    -- local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
	-- local playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)
    -- local holder  = GetComponentWithPath(self.root, "BaseBackground/bg", "SpriteHolder")
    -- local imageBg = GetComponent(holder.gameObject, ComponentTypeName.Image)
    -- self:SetImageSpriteByGameId(imageBg,holder,playMode.color)
	-- self.textCardName.text = ""
	-- if(playMode.coinName ~= nil) then
	-- 	self.textCardName.text = playMode.coinName
	-- end
end

--随便命名算了
function ShopView:showLibao(libao)
	local title = GetComponentWithPath(self.libaoDlg, "Background/bg/more",ComponentTypeName.Text)
	local cloneInfo = GetComponentWithPath(self.libaoDlg, "Center/lbNima",ComponentTypeName.Transform).gameObject
	local contentI = GetComponentWithPath(self.libaoDlg, "Center/Scroll View/Viewport/Content",ComponentTypeName.Transform)
	local tips = GetComponentWithPath(self.libaoDlg, "Center/lbTips", ComponentTypeName.Text)
	local icon = GetComponentWithPath(self.libaoDlg, "Center/IconFrame/icon", ComponentTypeName.Image)
	local iconObj = GetComponentWithPath(self.libaoDlg, "Center/IconFrame/icon", ComponentTypeName.Transform).gameObject
	local money = GetComponentWithPath(self.libaoDlg, "Center/BtnBuyLibao/text", ComponentTypeName.Text)
	title.text = libao.productName

	local texts = libao.market.split(libao.market,"\n")
	local allContent = TableUtil.get_all_child(contentI)
	for i=1,#allContent do
		ComponentUtil.SafeSetActive(allContent[i], false)
	end
	for i = 1, #texts do
		local obj = nil
		if(i<=#allContent) then
			obj = allContent[i]
		else
			obj = TableUtil.clone(cloneInfo,contentI.gameObject,Vector3.zero)
		end
		obj.name = i .. ""
		ComponentUtil.SafeSetActive(obj, true)
		local info = ModuleCache.ComponentUtil.GetComponent(obj, ComponentTypeName.Text)
		info.text = texts[i]
	end

	local t1 = "￥"
	local t2 = "元"
	if libao.payType == 1 then
		t1 = "钻石"
		t2 = "钻石"
	elseif libao.payType == 2 then
		t1 = "体力"
		t2 = "体力"
	end
	tips.text = "价值：<size=45>"..t1..libao.productPrice.."</size>"
	money.text = libao.salePrice..t2.."购买"
	--print("-------查看礼包详情-------")
	--print_table(libao)
	if libao.attachList then
		for i = 1, #libao.attachList do
			local attach = libao.attachList[i]
			if attach.attachType == 3 then
				self:downImg(attach.url,function(sprite)
					icon.sprite = sprite
					ComponentUtil.SafeSetActive(iconObj, true)
				end)
			end
		end
	end
	ComponentUtil.SafeSetActive(self.libaoDlg, true)
end

function ShopView:showBuyLibaoOk(libao, showText)
	local goodName = GetComponentWithPath(self.buyCplt, "Center/IconFrame/Text",ComponentTypeName.Text)
	local tips = GetComponentWithPath(self.buyCplt, "Center/info", ComponentTypeName.Text)
	local icon = GetComponentWithPath(self.buyCplt, "Center/IconFrame/icon", ComponentTypeName.Image)
	local iconObj = GetComponentWithPath(self.buyCplt, "Center/IconFrame/icon", ComponentTypeName.Transform).gameObject
	local obj1 = GetComponentWithPath(self.buyCplt, "Center/1", ComponentTypeName.Transform).gameObject
	local obj2 = GetComponentWithPath(self.buyCplt, "Center/2", ComponentTypeName.Transform).gameObject
	local obj3 = GetComponentWithPath(self.buyCplt, "Center/3", ComponentTypeName.Transform).gameObject
	local btnText = GetComponentWithPath(obj1, "BtnStore", ComponentTypeName.Text)

	local item = libao.itemVoList[1]
	local btnTypes = string.split(item.itemButtonType, ",")
	if btnTypes == nil then btnTypes = {} end
	--btnText.text = "确  定"

	ComponentUtil.SafeSetActive(obj1, #btnTypes < 2)
	ComponentUtil.SafeSetActive(obj2, #btnTypes == 2)
	ComponentUtil.SafeSetActive(obj3, #btnTypes == 3)


	goodName.text = item.itemName
	tips.text = showText

	self:downImg(item.itemIcon,function(sprite)
		icon.sprite = sprite
		ComponentUtil.SafeSetActive(iconObj, true)
	end)

	--if btnTypes == 1 then
	--	if btnTypes[1] == "2" then btnText.text = "确  定"
	--end


	ComponentUtil.SafeSetActive(self.buyCplt, true)
end


function ShopView:setToggleScroll()
	print("-------- set Toggole scroll Start -----------------")

	local activeObjs = 0
	for k,v in ipairs(self.togglesContents) do
		if v.gameObject.activeSelf then
			activeObjs = activeObjs+1
		end
	end

	print("active child: "..activeObjs)
	print("x: "..(278 * (activeObjs - 6)))

	self.toggleScroll.horizontal = activeObjs > 6
	self.toggleContent.anchoredPosition = Vector2.New(278 * (activeObjs - 6),self.toggleContent.anchoredPosition.y)
end

return ShopView 