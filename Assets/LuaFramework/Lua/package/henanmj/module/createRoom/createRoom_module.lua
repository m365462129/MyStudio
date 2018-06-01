-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local CreateRoomModule = class("BullFight.CreateRoomModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function CreateRoomModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "createroom_view", "createroom_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function CreateRoomModule:on_module_inited()

end

-- 绑定module层的交互事件
function CreateRoomModule:on_module_event_bind()
	self:subscibe_module_event("rulesetting", "Event_Send_WanfaType", function(eventHead, eventData)
		self.wanfaType = eventData
	end)
	self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
		self.createRoomView.roomCard.text= self.modelData.roleData.cards
	end)
end

-- 绑定loginModel层事件，模块内交互
function CreateRoomModule:on_model_event_bind()
	

end

function CreateRoomModule:set_view_values()

end

function CreateRoomModule:on_show(data)
	self.museumData = data
	self.view:refreshCoinName()
	self.view.ownRoomObj.gameObject:SetActive(data.showType == 1 or data.showType == 2)
	self.createRoomView.roomCard.text = self.modelData.roleData.cards
	self.view.powerText.text = self.modelData.roleData.coins
	self.view.moreShow:SetActive(false)

	if(data.clickType == 1) then
		ModuleCache.ModuleManager.show_module("henanmj", "rulesetting", data);
		self.createRoomView.buttonCreateRoom.gameObject:SetActive(true);
		self.createRoomView.buttonIntroduction.gameObject:SetActive(false);
	elseif(data.clickType == 2) then
		ModuleCache.ModuleManager.show_module("henanmj", "howtoplay", self.wanfaType);
		self.createRoomView.buttonCreateRoom.gameObject:SetActive(false);
		self.createRoomView.buttonIntroduction.gameObject:SetActive(true);
	end 
end

function CreateRoomModule:on_click(obj, arg)	
	print_debug(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.createRoomView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "createroom")
		ModuleCache.ModuleManager.hide_module("henanmj", "rulesetting")
		ModuleCache.ModuleManager.hide_module("henanmj", "howtoplay")
		self:dispatch_package_event("Event_Show_Hall_Anim")
		return
	elseif obj == self.createRoomView.buttonSelection.gameObject then
		local activeCreateRoom = self.createRoomView.buttonCreateRoom.gameObject.activeSelf;
		local activeIntroduction = self.createRoomView.buttonIntroduction.gameObject.activeSelf;
		if(not activeCreateRoom) then
			ModuleCache.ModuleManager.show_module("henanmj", "rulesetting", self.museumData);
			ModuleCache.ModuleManager.hide_module("henanmj", "howtoplay");
		elseif(not activeIntroduction) then
			ModuleCache.ModuleManager.show_module("henanmj", "howtoplay", self.wanfaType);
			ModuleCache.ModuleManager.hide_module("henanmj", "rulesetting");
		end
		self.createRoomView.buttonCreateRoom.gameObject:SetActive(not activeCreateRoom);
		self.createRoomView.buttonIntroduction.gameObject:SetActive(not activeIntroduction);

	elseif(obj.name == "moreShow" or obj.name == "bgShop") then
		ModuleCache.ModuleManager.show_module("henanmj", "shop")
	elseif(obj.name == "ButtonMore") then
		self.view.moreShow:SetActive(not self.view.moreShow.activeSelf)
	end
end

return CreateRoomModule



