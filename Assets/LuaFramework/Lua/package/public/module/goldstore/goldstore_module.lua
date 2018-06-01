-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local GoldStoreModule = class("Public.GoldStoreModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function GoldStoreModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "goldstore_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function GoldStoreModule:on_module_inited()
	--local that = self
	--self.view.inputIn.onEndEdit:AddListener(function (value)
	--	if value == "" then
	--		return
	--	end
	--	--if string.sub(value, 1, 1) == "0" and #value > 1 then
	--	--	that.view.inputIn.text = "0"
	--	--	value = "0"
	--	--end
	--	if string.sub(value, 1, 1) == "0" and #value > 1 then
	--		while string.sub(value, 1, 1) == "0" and #value > 1 do
	--			--print("#value = "..#value)
	--			value = string.sub(value, 2, #value)
	--			--print("new value = "..value)
	--		end
	--		--print("that.view.inputIn.text = "..that.view.inputIn.text)
	--		--print("value = "..value)
	--		that.view.inputIn.text = value
	--		--print("new that.view.inputIn.text = "..that.view.inputIn.text)
	--	end
	--	--print("inputIn onValueChanged : "..value)
	--	if tonumber(value) > that.curStoreData.goldAmount then
	--		that.view.inputIn.text = that.curStoreData.goldAmount
	--	end
	--end)

	--self.view.inputOut.onEndEdit:AddListener(function (value)
	--	if value == "" then
	--		return
	--	end
	--	if string.sub(value, 1, 1) == "0" and #value > 1 then
	--		while string.sub(value, 1, 1) == "0" and #value > 1 do
	--			value = string.sub(value, 2, #value)
	--		end
	--		that.view.inputOut.text = value
	--	end
	--	--print("inputOut onValueChanged : "..value)
	--	if tonumber(value) > that.curStoreData.coffersAmount then
	--		that.view.inputOut.text = that.curStoreData.coffersAmount
	--	end
	--end)
end

-- 绑定module层的交互事件
function GoldStoreModule:on_module_event_bind()

end

-- 绑定Model层事件，模块内交互
function GoldStoreModule:on_model_event_bind()

end

function GoldStoreModule:on_show(data)
	self:get_init_data()
end

function GoldStoreModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj.name == self.view.btnClose.name then
		ModuleCache.ModuleManager.hide_module("public", "goldstore")
		self.view:hideMain()
	elseif obj.name == self.view.btnIn.name then
		if self.curPage ~= 1 then
			self.curPage = 1
			self.view:showUI(self.curPage)
		end
	elseif obj.name == self.view.btnOut.name then
		if self.curPage ~= 2 then
			self.curPage = 2
			self.view:showUI(self.curPage)
		end
	elseif obj.name == self.view.btnStoreIn.name then
		local inputText = tonumber(self.view.inputIn.text)
		if inputText < 1 or inputText > tonumber(self.curStoreData.goldAmount) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您输入的数值有误，请确认后重新输入!")
			return
		end
		self:store_in(inputText)
	elseif obj.name == self.view.btnStoreout.name then
		local inputText = tonumber(self.view.inputOut.text)
		if inputText < 1 or inputText > tonumber(self.curStoreData.coffersAmount) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您输入的数值有误，请确认后重新输入!")
			return
		end
		self:store_out(inputText)
	elseif obj.name == self.view.btnInMax.name then
		self.view.inputIn.text = self.curStoreData.goldAmount
	elseif obj.name == self.view.btnOutMax.name then
		self.view.inputOut.text = self.curStoreData.coffersAmount
	end
end


-- 获取初始数据
function GoldStoreModule:get_init_data()

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/getGoldInfoAccount?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
		}
	}

	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.curPage = 1
			self.curStoreData = retData.data
			self.view:refreshInfos(self.curStoreData)
			self.view:showUI(self.curPage)
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

-- 存钱
function GoldStoreModule:store_in(num)

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/userCoffersIncr?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			amount = num
		}
	}

	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			if retData.data then
				self:getUserNewMessage()
				self.curStoreData.goldAmount = self.curStoreData.goldAmount - num
				self.curStoreData.coffersAmount = self.curStoreData.coffersAmount + num
				self.view:refreshInfos(self.curStoreData)
				self.view.inputIn.text = ""
				self.view.inputOut.text = ""
			else
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("存入失败！")
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

-- 取钱
function GoldStoreModule:store_out(num)

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gold/userCoffersDecr?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			amount = num
		}
	}

	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			if retData.data then
				self:getUserNewMessage()
				self.curStoreData.goldAmount = self.curStoreData.goldAmount + num
				self.curStoreData.coffersAmount = self.curStoreData.coffersAmount - num
				self.view:refreshInfos(self.curStoreData)
				self.view.inputIn.text = ""
				self.view.inputOut.text = ""
			else
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("取出失败！")
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

function GoldStoreModule:getUserNewMessage()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "msg/getNewMsg?",
		showModuleNetprompt = false,
		params = {
			uid = self.modelData.roleData.userID,
		}
	}
	Util.http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			local data = retData.data
			self.modelData.roleData.cards = data.cards
			self.modelData.roleData.coins = data.coins
			self.modelData.roleData.gold  = data.gold
			self:dispatch_package_event("Event_Package_Refresh_Userinfo")
		else

		end
	end, function(errorData)
		print(errorData.error)
	end)
end

return GoldStoreModule



