-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local JoinRoomModule = class("BullFight.JoinRoomModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine



function JoinRoomModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "joinRoom_view", "joinRoom_model", ...)

	self.strRoomNum = ''
	self.AgentParlorCount = 0
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function JoinRoomModule:on_module_inited()

end


-- 绑定module层的交互事件
function JoinRoomModule:on_module_event_bind()

end


function JoinRoomModule:on_model_event_bind()

end

function JoinRoomModule:on_show(joinData)
	if(not joinData) then
		joinData = { mode = 1 }
	end
	self.joinData = joinData
	self.joinMode = joinData.mode
	if self.joinMode == 2 then --加入亲友圈
		self.view.stateSwitcher:SwitchState("Museum")
		self.view.museumToggles[2].isOn = false
		self.view.museumToggles[2].isOn = true
		self.view.idInput.text = tostring(self.modelData.roleData.userID)
		self:get_Agent_Parlor_Count()

	elseif(self.joinMode == 1) then --加入房间
		self.view.stateSwitcher:SwitchState("JoinRoom")
	elseif(self.joinMode == 3) then --底注设定
		self.view.stateSwitcher:SwitchState("GoldEnter1")
	elseif(self.joinMode == 4 or self.joinMode == 6) then --入场设定
		self.view.stateSwitcher:SwitchState("GoldSet2")
	elseif(self.joinMode == 5) then --底分设定
		self.view.stateSwitcher:SwitchState("GoldEnter1")
	elseif(self.joinMode == 7) then --离场设定
		self.view.stateSwitcher:SwitchState("GoldEnter3")
	end
	self:cleanRoomNumAndRefreshView()
	self.view:refreshPlayMode()
end

function JoinRoomModule:cleanRoomNumAndRefreshView()
	self.strRoomNum = ''
	self.joinRoomView:refreshRoomNumText(self.strRoomNum);
	self.view:refreshGoldNumText(self.strRoomNum)
end

function JoinRoomModule:removeLastNum()
	local len = string.len(self.strRoomNum)
	if(len == 0) then
		self.strRoomNum = ''
	else
		self.strRoomNum = string.sub(self.strRoomNum, 1, len - 1)
	end
end


function JoinRoomModule:on_click(obj, arg)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.joinRoomView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")
		return
	elseif obj == self.joinRoomView.keyboardMap.buttonDelete.gameObject then
		self:removeLastNum()
		self.joinRoomView:refreshRoomNumText(self.strRoomNum)
		self.view:refreshGoldNumText(self.strRoomNum)
	elseif obj == self.joinRoomView.keyboardMap.buttonClean.gameObject then
		self:cleanRoomNumAndRefreshView();
	elseif(obj.name == "ButtonConfirm") then
		if(self.strRoomNum == "") then
			self.strRoomNum = "0"
		end
		self.view:refreshGoldNumText(self.strRoomNum)
		if(self.joinData.num ~= self.strRoomNum) then
			self:dispatch_module_event("joinroom", "Event_Update_GoldSetNum", {mode = self.joinMode, num = self.strRoomNum})
		end
		ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")

	elseif(obj.name == "createBtn") then--TODO XLQ:创建亲友圈
		if  self.view.nameInput.text == "" then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("圈名不能为空！")
		elseif self.view.idInput.text == "" then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("圈主ID不能为空！")
		else
			if self.AgentParlorCount >= 1 then
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("为了避免亲友圈资源浪费，从创建第二个亲友圈开始需要收取%s体力/钻石服务费，是否继续创建？",self.modelData.addParlorCost), function()
					self:create_museum({
						parlorName = self.view.nameInput.text,
						ownerUid = self.view.idInput.text,
						wechatNumber = self.view.wxNumInput.text,
					})
				end,nil )
			else
				self:create_museum({
					parlorName = self.view.nameInput.text,
					ownerUid = self.view.idInput.text,
					wechatNumber = self.view.wxNumInput.text,
				})
			end

		end

	else
		local len = table.getn(self.joinRoomView.keyboardMap)

		for i=0,len do
			if(obj == self.joinRoomView.keyboardMap[i].gameObject) then
				if(self.joinMode == 1 or self.joinMode == 2) then
					if(string.len(self.strRoomNum) >= 6) then
						return
					end
					self.strRoomNum = self.strRoomNum .. i

					self.joinRoomView:refreshRoomNumText(self.strRoomNum)
					if(string.len(self.strRoomNum) == 6) then
						local roomID = self:getRoomId()

						if roomID <= 99999 then
							if self.joinMode == 2 then
								self:get_museum_data(roomID)
							else
								self:getParlorRules(roomID)
							end

						else
							if self.joinMode == 2 then
								ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("圈号不存在")
							else
								self.modelData.tableCommonData.tableType = 0
								self.modelData.hallData.hideCircle = false
								TableManager:join_room(roomID)
							end
						end
						return
					end
				else
					if(string.len(self.strRoomNum) >= 8) then
						return
					end
					self.strRoomNum = self.strRoomNum .. i
					self.view:refreshGoldNumText(self.strRoomNum)
				end
			end
		end
	end
end

function JoinRoomModule:get_Agent_Parlor_Count()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getAgentParlorCount?",
		showModuleNetprompt = true,
		params =
		{
			uid = self.modelData.roleData.userID,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if (retData.success) then
			self.AgentParlorCount = tonumber( retData.data )
		else

		end
	end , function(wwwErrorData)
		print(wwwErrorData.error)
	end )
end

function JoinRoomModule:create_museum(data)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/addParlor?",
		showModuleNetprompt = true,
		params =
		{
			uid = self.modelData.roleData.userID,
			parlorName = data.parlorName,
			ownerUid = data.ownerUid,
			wechatNumber = data.wechatNumber
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if (retData.success) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("亲友圈创建成功！")
			self:dispatch_module_event("joinroom_to_chessmuseum","Update_User_Parlor_List")
			ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
	end , function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					if retData.code == "GAME_USER_NOT_FOUND" then
						ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请输入正确的游戏ID作为圈主。")
					elseif retData.code == "USER_NOT_BIND_AGENT" then
						ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("暂时仅限代理可以创建亲友圈哦！")
					else
						ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
					end


				end
			end
		end
	end )
end

function JoinRoomModule:get_museum_data(parlorNum)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getParlorByNum?",
		-- showModuleNetprompt = true,
		params =
		{
			uid = self.modelData.roleData.userID,
			platformName = ModuleCache.GameManager.customPlatformName,
			assetVersion = ModuleCache.GameManager.appAssetVersion,
			parlorNum = parlorNum
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if (retData.success) then
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common_image_tex({
				topTex = "您确定要申请加入以下亲友圈吗？",
				rightTex1 = "圈名："..retData.data.parlorName ,
				rightTex2 = "圈号：0".. retData.data.parlorNum,
				headImg = retData.data.parlorLogo
			}, function()
				self:join_museum(parlorNum)
			end)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
	end , function(wwwErrorData)
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
	end )
end

function JoinRoomModule:join_museum(parlorNum)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/applyMember?",
		-- showModuleNetprompt = true,
		params =
		{
			uid = self.modelData.roleData.userID,
			platformName = ModuleCache.GameManager.customPlatformName,
			assetVersion = ModuleCache.GameManager.appAssetVersion,
			parlorNum = parlorNum
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if (retData.success) then
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("申请成功，请等待圈主审核", function()
				self:dispatch_module_event("chessmuseum", "Event_Update_OneChessMuseum")
				--ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")
			end )
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
			--ModuleCache.ModuleManager.hide_module("henanmj", "joinroom")
		end
	end , function(wwwErrorData)
		print(wwwErrorData.error)
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
					if tostring(retData.message):find("在亲友圈") ~= nil then
						self:dispatch_module_event("match", "Update_CurParlor_Detail")
					end
				end
			end
		end
	end )
end

function JoinRoomModule:getParlorRules(parlorId)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getParlorByNum?",
        params = {
            uid = self.modelData.roleData.userID,
			parlorNum = parlorId
        },
    }

	self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if(retData.ret and retData.ret == 0) then
			-- local retData = ModuleCache.Json.decode(retData.data)
			local playRule = TableUtil.convert_rule(retData.data.playRule)
			print_table(playRule)
			local createName=""

			if(playRule.gameName) then
				createName = playRule.gameName
			else
				createName = Config.get_create_name_by_wanfatype(playRule.GameType)
			end

			print("---------------playRule.GameType:",playRule.GameType,createName)
			if createName then
				self.modelData.tableCommonData.tableType = 0
				self.modelData.hallData.hideCircle = false
				TableManager:join_room(parlorId, createName)
			end
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

function JoinRoomModule:getRoomId()
	return tonumber(self.strRoomNum)
end


return JoinRoomModule



