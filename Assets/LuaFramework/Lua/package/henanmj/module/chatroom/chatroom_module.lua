-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local ChatRoomModule = class("HeNanMJ.ChatRoomModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local chatMgr = ModuleCache.JMsgManager
local onAppFocusCallback


function ChatRoomModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "chatroom_view", nil, ...)

	self.recvTextMsg = function(data)
		if self.chatDataList == nil then
			self.chatDataList = {}
		end
		table.insert(self.chatDataList, data)
		self.view:showChat(self.chatDataList)
	end

	chatMgr.addEventListener(self.recvTextMsg,chatMgr.msgTag.groupTag)

	self.onRecvOfflineMsg = function()
		if chatMgr.isLogin and self.parlorId and self.imChatRoom then
			print("------------- offline action start-------------")
			self:getInitChatData()
			print("------------- offline action end-------------")
		end
	end

	chatMgr.addEventListener(self.onRecvOfflineMsg,chatMgr.msgTag.groupTag,true)
end

function ChatRoomModule:on_destroy()
	chatMgr.removeEventListener(self.recvTextMsg, chatMgr.msgTag.groupTag)
	chatMgr.removeEventListener(self.onRecvOfflineMsg,chatMgr.msgTag.groupTag,true)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function ChatRoomModule:on_module_inited()
	onAppFocusCallback = function(eventHead, eventData)
		if not self.view:is_active() then
			return
		end
		print("onAppFocusCallback : "..tostring(eventData))
		if eventData then
			if chatMgr.isLogin and self.parlorId and self.imChatRoom then
				self:getInitChatData()
			end
		end
	end

	self:subscibe_app_focus_event(onAppFocusCallback)
end

-- 绑定module层的交互事件
function ChatRoomModule:on_module_event_bind()

end

-- 绑定Model层事件，模块内交互
function ChatRoomModule:on_model_event_bind()
	

end

function ChatRoomModule:on_show(data)
	if data == nil or data.parlorId == nil then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("玩家没有加入亲友圈，没有可用聊天室！")
		return
	end

	self.parlorId = data.parlorId
	self.museumData = data

	if chatMgr.isLogin then
		self:get_group_id(self.parlorId)
	else
		self:get_user_name()
	end
end


function ChatRoomModule:get_user_name()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "im/getImUser?",
		showModuleNetprompt = true,
		params = {
			bundleID = Util.identifier,
			uid = self.modelData.roleData.userID,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			chatMgr.login(retData.data.imUserName,self.modelData.roleData.unionId, function(data)
				print_table(data)
				if data.result == "0" or data.result == 0 then
					chatMgr.setLoginData(retData.data.imUserName, self.modelData.roleData.unionId)
					--ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("登录成功！")
					self:get_group_id(self.parlorId)
				else
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.desc)
				end
			end)
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

function ChatRoomModule:get_group_id(mParlorId)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "im/getImGroup?",
		params = {
			parlorId = mParlorId,
			uid = self.modelData.roleData.userID,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		if retData.ret == 0 then
			self.imChatRoom = retData.data.groupId
			chatMgr.setCurChatRoom(self.imChatRoom,self.museumData)
			self:getInitChatData(self.parlorId)
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

function ChatRoomModule:getInitChatData(mParlorId)
	--local requestData = {
	--	baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "im/getLast20ParlorMessage?",
	--	showModuleNetprompt = false,
	--	params = {
	--		parlorId = mParlorId,
	--		uid = self.modelData.roleData.userID,
	--	}
	--}
	--Util.http_get(requestData, function(wwwData)
	--	local retData = ModuleCache.Json.decode(wwwData.www.text)
	--	print_table(retData)
	--	if retData.ret == 0 then
	--		self.chatDataList = {}
	--		for i=1,#retData.data do
	--			if retData.data[i].msgType == "custom" then  -- 暂时只处理这一种消息 图片文件语音暂时不处理
	--				table.insert(self.chatDataList, retData.data[i].msgBody) -- 这是一个json 与发送的一样，在jmsg_mgr 的send group中
	--			end
	--		end
	--		self.view:showChat(self.chatDataList)
	--	end
	--end, function(errorData)
	--	print(errorData.error)
	--end)

	chatMgr.getGroupTalk(function(messages)

		self.chatDataList = {}
		for i=1,#messages do
			if type(messages[i]) == "table" then
				table.insert(self.chatDataList, messages[i])
			else
				table.insert(self.chatDataList, ModuleCache.Json.decode(messages[i]))
			end
		end
		print("------- get group talk ----------")
		print_table(self.chatDataList)
		self.view:showChat(self.chatDataList)
	end)

end


function ChatRoomModule:send_text(content)
	chatMgr.sendGroupTextMsg(content, self.modelData.roleData,function(data)
		if data.result == "0" or data.result == 0 then
			self.view.input.text = ""
			if self.chatDataList == nil then
				self.chatDataList = {}
			end
			table.insert(self.chatDataList, data)
			self.view:showChat(self.chatDataList)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.desc)
		end
	end)
end


function ChatRoomModule:on_click(obj, arg)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.btnClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "chatroom")
	elseif obj == self.view.btnSend.gameObject then
		if self.view.input.text and self.view.input.text ~= "" then
			self:send_text(self.view.input.text)
		end
	elseif obj == self.view.btnRecv.gameObject then
		chatMgr.TestRecvText()
	end
end

return ChatRoomModule



