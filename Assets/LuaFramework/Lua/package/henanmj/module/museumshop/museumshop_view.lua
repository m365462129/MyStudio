-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================
local MuseumShopView = Class('museumShopView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil

function MuseumShopView:initialize(...)
	-- 初始View
	View.initialize(self, "henanmj/module/museumshop/henanmj_museumshop.prefab", "HeNanMJ_MuseumShop", 1)
	
	self.buttonClose = GetComponentWithPath(self.root, "Title/closeBtn", ComponentTypeName.Button)
	
	self.buttonBindInviteCode = GetComponentWithPath(self.root, "Center/Panels/RoomCardGoodsScrollView/Top/PanelBindInviteCodePrompt/ButtonBind", ComponentTypeName.Button)
	self.objInviteCode = GetComponentWithPath(self.root, "Center/Panels/Top/PanelBindInviteCodePrompt", ComponentTypeName.Transform).gameObject
	self.inputFieldText = GetComponentWithPath(self.root, "Center/Panels/Top/PanelBindInviteCodePrompt/InputFieldInviteCode/Placeholder", ComponentTypeName.Text)
	self.inputFieldInviteCode = GetComponentWithPath(self.root, "Center/Panels/Top/PanelBindInviteCodePrompt/InputFieldInviteCode/Text", ComponentTypeName.Text)
	self.bindInfoText = GetComponentWithPath(self.root, "Center/Panels/Top/PanelBindInviteCodePrompt/TextBindInfo", ComponentTypeName.Text)
	self.textInfo = GetComponentWithPath(self.root, "Center/Panels/TextInfo", ComponentTypeName.Text)
	self.textInfoEx = GetComponentWithPath(self.root, "Center/Panels/TextInfoEx", ComponentTypeName.Text)
	self.content = GetComponentWithPath(self.root, "Center/Panels/RoomCardGoodsScrollView/Viewport/Content", ComponentTypeName.Transform).gameObject
	self.cloneObj = GetComponentWithPath(self.root, "Center/Panels/ItemPrefabHolder/RoomGoodsItem", ComponentTypeName.Transform).gameObject
	self.textOwnRoomCardNum = GetComponentWithPath(self.root, "Center/Panels/Top/RoomCard/TextNum", ComponentTypeName.Text)
end

function MuseumShopView:get_data(obj)
    return self.products[tonumber(obj.name)]
end

function MuseumShopView:refresh_role_info(roleData)
	self.textOwnRoomCardNum.text = roleData.coins .. ""
end

function MuseumShopView:on_view_init()
	
end

function MuseumShopView:set_view(shopData)
	shopData.isBindInvite = true
	self.textInfo.text = shopData.message
	-- self.textInfoEx.gameObject:SetActive(shopData.isBindInvite) 2017/7/24 屏蔽显示
	self.objInviteCode:SetActive(not shopData.isBindInvite)
	self.isForceBindInvite = shopData.isForceBindInvite
	self.isBindInvite = shopData.isBindInvite
	if shopData.isBindInvite then
		self.textInfoEx.text = shopData.phone
		self:init_loop_scroll_view_list(shopData.products)
	else
		self.bindInfoText.text = shopData.bindInviteMessage
		self.inputFieldText.text = shopData.bindInviteMessage2
		self:init_loop_scroll_view_list(shopData.products)
	end
end

function MuseumShopView:init_loop_scroll_view_list(productData)
	self.products = productData
    self.contents = TableUtil.get_all_child(self.content)
    for i=1,#self.contents do
        ComponentUtil.SafeSetActive(self.contents[i], false)
    end
    for i=1,#self.products do
        local obj = nil
        local item = {}
        if(i<=#self.contents) then
            obj = self.contents[i]
        else
            obj = TableUtil.clone(self.cloneObj,self.content,Vector3.zero)
        end
        obj.name = i .. ""
        ComponentUtil.SafeSetActive(obj, true)  
        item.gameObject = obj
        item.data = self.products[i] 
        self:fillItem(item, i)
    end

end

function MuseumShopView:fillItem(item,index)	
	local data = item.data
	local textRoomCardNum = GetComponentWithPath(item.gameObject, "NumLbl", ComponentTypeName.Text)
	local textRoomCardNumLeft = GetComponentWithPath(item.gameObject, "NumLbl_Left", ComponentTypeName.Text)
	local textPrice = GetComponentWithPath(item.gameObject, "Price/NumText", ComponentTypeName.Text)
	local buttonBuy = GetComponentWithPath(item.gameObject, "BuyGoodsBtn", ComponentTypeName.Button)
	local buttonGive = GetComponentWithPath(item.gameObject,"GiveGoodsBtn",ComponentTypeName.Button)
	local goods = GetComponentWithPath(item.gameObject,"goods",ComponentTypeName.Transform)
	local showGoods = GetComponentWithPath(goods.gameObject,"goods"..index,ComponentTypeName.Transform).gameObject

	local goExtenal = GetComponentWithPath(item.gameObject, "Title/Extenal", ComponentTypeName.Transform).gameObject
	local textExtenalRoomCardNum = GetComponentWithPath(goExtenal, "numLbl", ComponentTypeName.Text)

	self:hideIcons(goods)
	goExtenal:SetActive(data.giveNum > 0)
	--textRoomCardNum.gameObject:SetActive(data.giveNum <= 0)
	--textRoomCardNumLeft.gameObject:SetActive(data.giveNum > 0)
	textExtenalRoomCardNum.text = data.giveNum .. ''
	showGoods:SetActive(true)
	local btnType = not( self.isForceBindInvite and not self.isBindInvite)
	buttonBuy.interactable = btnType
	buttonGive.interactable = btnType

	textRoomCardNum.text = data.productName .. ""
	--textRoomCardNumLeft.text = data.productName .. ""
	textPrice.text = "￥" .. data.productPrice
end

function MuseumShopView:hideIcons(goods)
	for i=1,6 do
		local item = GetComponentWithPath(goods.gameObject, "goods"..i, ComponentTypeName.Transform).gameObject
		ComponentUtil.SafeSetActive(item, false)
	end
end


return MuseumShopView 