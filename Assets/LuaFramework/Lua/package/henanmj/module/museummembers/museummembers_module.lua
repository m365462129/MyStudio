-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MuseumMembersModule = class("museumMembersModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local GameManager = ModuleCache.GameManager

function MuseumMembersModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "museummembers_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function MuseumMembersModule:on_module_inited()		
	for i=1,#self.view.settingToggles do
		self.view.settingToggles[i].onValueChanged:AddListener(function(isCheck)
		if(isCheck) then 
			self.view:refresh_view()
			if(i == 1) then
				self:get_data_list(self.selectData)
			elseif(i == 2) then
				self:get_check_list(self.selectData)
			elseif(i == 3) then
				self:get_user_record(self.selectData)
			end
		end
		end)
	end

	self.view.dropDown.onValueChanged:AddListener(function(idx)
		--_dropdown.value :0      1:
		self.memberDataTab = nil
		self:get_data_list(self.selectData)
	end )
end



-- 绑定module层的交互事件
function MuseumMembersModule:on_module_event_bind()
	self:subscibe_module_event("share","Update_museumMembers",function( eventHead, eventData )
		self.memberDataTab = nil
		self:get_data_list(self.selectData)
	end)
end

-- 绑定loginModel层事件，模块内交互
function MuseumMembersModule:on_model_event_bind()
	
end

function MuseumMembersModule:on_show(data)
	self.selectData = data
	self.memberDataTab = nil

	if data.playerRole == "OWNER" or data.playerRole == "ADMIN" then
		self.view.stateSwitcher:SwitchState("Owner")
	else
		self.view.stateSwitcher:SwitchState("Member")
	end

	self.view.dropDown.value = 0
	self.view.inputField.text = ""

	--TODO XLQ 必须要在 self.memberDataTab = nil 之后调用
	self.view.settingToggles[1].isOn = false
	self.view.settingToggles[1].isOn = true
end

function MuseumMembersModule:on_hide()
	self.view:reset()
end

function MuseumMembersModule:get_user_record(data)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/getParlorUserRecord?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorId = data.id
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.retData = retData.data
			self.view:initLoopScrollViewList(retData.data, self.selectData.playerRole,3)
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
	end)
end

function MuseumMembersModule:get_check_list(data)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/getApprovalMember?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = data.parlorNum
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.retData = retData.data
			self.view:initLoopScrollViewList(retData.data, self.selectData.playerRole,2)
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)
end

function MuseumMembersModule:get_data_list(data, isReduce,isloadMore)
	isReduce = isReduce or false
	self.isReduce = isReduce

	if self.memberDataTab ~= nil and not isloadMore then
		self.view:initLoopScrollViewList(self.memberDataTab, self.selectData.playerRole,1, isReduce)
		return
	end

	local curPageNum = 1
	if self.memberDataTab and self.memberDataTab.currentPage then
		curPageNum = self.memberDataTab.currentPage
	end


	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/getMembers?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = data.parlorNum,
			pageSize = 50,
			pageNum = curPageNum,
			keyword = self.view.inputField.text,
			parlorUseType = self.view.dropDown.value,

		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.retData = retData.data

			if isloadMore and self.memberDataTab then
				for i =1, #retData.data.members do
					table.insert(self.memberDataTab.members,#self.memberDataTab.members +1, retData.data.members[i])
				end
			else
				self.memberDataTab = retData.data
			end

			self.view:initLoopScrollViewList(self.memberDataTab, self.memberDataTab.memberType,1, isReduce)
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)
end

function MuseumMembersModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "museummembers")
	elseif(obj.name == "ButtonReduce") then
		self:get_data_list(self.selectData, true)
	elseif(obj.name == "ButtonBack") then
		self:get_data_list(self.selectData)
	elseif(obj.name == "ButtonAdd") then
		self.selectData.type = 3
		ModuleCache.ModuleManager.show_module("henanmj", "share", self.selectData)
	elseif(obj.name == "ImageHead") then

		local parentName = obj.transform.parent.parent.parent.gameObject.name
		if(string.sub(parentName, 1, 4) == "item") then
			local array = string.split(parentName, "_")
			if self.isReduce then
				self:delete_member(tonumber(array[2]))
			else
				if self.selectData.playerRole == "OWNER" then
					local data = self.memberDataTab.members[tonumber(array[2]) -2 ]
					if tonumber(self.modelData.roleData.userID) ~= tonumber(data.uid)  then
						local confirmText = ""
						if data.parlorUserType == 2 then
							confirmText = "设为管理员"
						elseif data.parlorUserType == 1 then
							confirmText = "撤销管理员"
						end

						ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common_image_tex({
							topTex = "",
							rightTex1 = "昵称："..data.name ,
							rightTex2 = "ID：".. data.uid,
							headImg = data.headImg,
							confirmText = confirmText,
							cancelText = "取消",
						}, function()
							if data.parlorUserType == 2 then
								self:change_userType(data,1)
							elseif data.parlorUserType == 1 then
								self:change_userType(data,2)
							end

						end)
					end
				end
			end

		end
	elseif(obj.name == "ButtonAgree") then
		local parentName = obj.transform.parent.parent.gameObject.name
		if(string.sub(parentName, 1, 4) == "item") then
			local array = string.split(parentName, "_")
			self:check_member(tonumber(array[2]), true)
			--self:validateApproval(tonumber(array[2]) )
		end
	elseif(obj.name == "ButtonRefuse") then
		local parentName = obj.transform.parent.parent.gameObject.name
		if(string.sub(parentName, 1, 4) == "item") then
			local array = string.split(parentName, "_")
			self:check_member(tonumber(array[2]), false)
		end
	elseif(obj.name == "loadButton") then
		self.memberDataTab.currentPage = self.memberDataTab.currentPage +1
		self:get_data_list(self.selectData, self.isReduce, true)
	elseif(obj.name == "SearchButton") then
		--if self.view.inputField.text ~= "" then
			self.memberDataTab = nil
			self:get_data_list(self.selectData)
		--else
		--	ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请输入昵称或ID进行搜索")
		--end

	end
end

function MuseumMembersModule:change_userType(data,parlorUserType) -- parlorUserType 1管理员 2圈友
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/changeParlorUserType?",
		showModuleNetprompt = true,
		params = {
			parlorNum = self.selectData.parlorNum,
			uid = self.modelData.roleData.userID,
			playerId = data.uid,
			parlorUserType = parlorUserType,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			if(parlorUserType == 1) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("成功设置"..data.name.."为管理员。")
			elseif(parlorUserType == 2) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您已取消"..data.name.."的管理员。")
			end
			self.memberDataTab = nil
			self:get_data_list(self.selectData)
		else
			if(parlorUserType == 1) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("管理员设置失败。")
			elseif(parlorUserType == 2) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("取消管理员失败。")
			end
		end
	end, function(wwwErrorData)
		-- print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",wwwErrorData.www.text)

		-- android  wwwErrorData.error = 500 Internal Server Error      ios = internal server error
		if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(retData.message, function()
						print(retData.message)
					end)
				end
			end
		end
	end)
end

function MuseumMembersModule:check_member(index, agree)
	local data = self.view.checkList[index]
	local addstr = ""
	if(agree) then
		addstr = "agree=true&"
	else
		addstr = "agree=false&"
	end

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/approvalMember?" .. addstr,
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = self.selectData.parlorNum,
			memberUid = data.uid,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			if(agree) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.name .. "加入了" .. AppData.MuseumName)
				self:dispatch_module_event("museummem","Updata_Coin_Show")--TODO XLQ:加入棋牌馆后刷新体力 （玩家已绑定其他代理，进入亲友圈需要扣除您%d体力）
			else
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您拒绝了" .. data.name .. "的申请")
			end
			self:get_check_list(self.selectData)
		else
			self:get_check_list(self.selectData)
		end
	end, function(wwwErrorData)
		-- print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$",wwwErrorData.www.text)

		-- android  wwwErrorData.error = 500 Internal Server Error      ios = internal server error
		 if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
			if wwwErrorData.www.text then
				local retData = wwwErrorData.www.text
				retData = ModuleCache.Json.decode(retData)
				if retData.errMsg then
					retData = ModuleCache.Json.decode(retData.errMsg)
					ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(retData.message, function()
						print(retData.message)
					end)
				end
			end
		end
	end)
end

function MuseumMembersModule:delete_member(index)
	local data = self.memberDataTab.members[index - 2]

	if self.memberDataTab.memberType == "ADMIN" and data.parlorUserType == 1 then -- 当前玩家是管理员
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("不允许删除管理员哦！")
		return
	end

	if(data.uid == self.memberDataTab.ownerId) then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("不允许删除馆主哦！")	
	else
		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common("您确定要删除此成员吗？", function()
			local requestData = {
				baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/deleteMember?",
				showModuleNetprompt = true,
				params = {
					uid = self.modelData.roleData.userID,
					platformName = GameManager.customPlatformName,
					assetVersion = GameManager.appAssetVersion,
					parlorNum = self.memberDataTab.parlorNum,
					memberUid = data.uid
				}
			}
			self:http_get(requestData, function(wwwData)
				local retData = wwwData.www.text
				retData = ModuleCache.Json.decode(retData)
				if(retData.success) then
					self.memberDataTab = nil
					self:get_data_list(self.selectData)
				end
			end, function(wwwErrorData)
				print(wwwErrorData.error)
			end)

		end, nil)
	end
end

--圈主拉绑定了其他代理的玩家进圈时会  弹出二次确认框
function MuseumMembersModule:validateApproval(index)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/validateApproval?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = self.selectData.parlorNum,
			memberUid = self.view.checkList[index].uid,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			if retData.data.validateResult == false then
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format( "该玩家已绑定其他代理，进入亲友圈需要扣除您%d体力\n赠送给该玩家，是否继续？",retData.data.amount), function()
					self:check_member(index, true)
				end,nil)
			else
				self:check_member(index, true)
			end
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
	end)

end

return MuseumMembersModule



