-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MuseumInfoModule = class("museumInfoModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local GameManager = ModuleCache.GameManager
local roundNums = {6, 8, 16}
local playerNums = {4, 3}
local masterCostStrs = { "亲友圈", "大赢家", "房费均摊" }
local consumeTypes = {"CONSUME_COIN", "CONSUME_COIN", "CONSUME_COIN"}
local PlayModeUtil = ModuleCache.PlayModeUtil

function MuseumInfoModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "museuminfo_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function MuseumInfoModule:on_module_inited()	

	for i=1,#self.view.settingToggles do
		self.view.settingToggles[i].onValueChanged:AddListener(function(isCheck)
		ModuleCache.ComponentManager.GetComponent(self.view.masterCostToggles[1].transform.parent.gameObject, ModuleCache.ComponentTypeName.ToggleGroup).allowSwitchOff = false
		if(isCheck) then 
			self.view:refresh_master_panel(self.selectData)
		end
		end)
	end

	for i=1,#self.view.masterCostToggles do
		self.view.masterCostToggles[i].onValueChanged:AddListener(function(isCheck)
			if(isCheck and self.isShow) then
				if i ~= 1 then
					self:get_cost_power(i)--ModuleCache.ModuleManager.show_module("henanmj", "museumcostpower", self:get_cost_power(i))
				else
					--设置圈主消耗 默认设置最低档
					self.oneDataNum = tonumber(string.split(self:get_round_data().coinNums, ",")[1])
					if self.parlorChargingType == 1 then
						self.payNum = self.oneDataNum
					elseif self.parlorChargingType == 2 then
						self.payNum = self.oneDataNum * self.playerCount

						if self.isMjGame and self.playerCount == 2 then
							self.payNum = self.oneDataNum * 3
						end
					end

					self.payType = 1
					self:refresh_cost_tips(self.payType)
				end

			end
		end)
	end

	for i = 1, #self.view.powerCostToggles do
		self.view.powerCostToggles[i].onValueChanged:AddListener( function(isCheck)
			if (isCheck and self.isShow) then
				self:onPowerToggle(i)
				-- ModuleCache.ModuleManager.show_module("henanmj", "museumcostpower", self:get_cost_power(i))
				-- self:refresh_cost_tips(i)
			end
		end )
	end
	
	for i = 1, #self.view.showQRCodeToggles do
		self.view.showQRCodeToggles[i].onValueChanged:AddListener( function(isCheck)
			if (isCheck and self.isShow) then
				-- 是否弹出二维码
				if i == 1 then
					if self.selectData.qrCodeImg and  self.selectData.qrCodeImg ~="" then
						self.qrCodeShow = 1
					else
						ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请先在代理后台上传群二维码。")
						self.view.showQRCodeToggles[2].isOn = true;
						self.qrCodeShow = 0
					end
					
				elseif i == 2 then
					self.qrCodeShow = 0
				end
			end
		end )
	end

	for i = 1, #self.view.ScoreboardToggles do
		self.view.ScoreboardToggles[i].onValueChanged:AddListener( function(isCheck)
			if (isCheck and self.isShow) then
				self.showRankListType = i;
				self.view.sendData.data.showRankListType = i
			end
		end )
	end

	for i = 1, #self.view.ChatAuthToggles do
		self.view.ChatAuthToggles[i].onValueChanged:AddListener( function(isCheck)
			if (isCheck and self.isShow) then
				self.sendMsgType = i
				self.view.sendData.data.sendMsgType = i
			end
		end )
	end
end

function MuseumInfoModule:get_round_data()
	for i=1,#self.configs do
		local config = self.configs[i]
		if(config.round == self.roundCount) then
			return config
		end
	end
	return nil
end

function MuseumInfoModule:onPowerToggle(i)

    -- 允许消耗体力
    if i == 1 then

        self.diamondCostVitality = 1;
        -- 不允许消耗体力
    elseif i == 2 then
        self.diamondCostVitality = 0;
    end
end

function MuseumInfoModule:get_cost_power(i)
	self.payType = i
	local powerData = 
	{	
		payNum = self.payNum,
		payType = self.payType,
		baseNum = self.baseNum,
		roundCount = self.roundCount,
		configs = self.configs,
		playerCount = self.playerCount,
        parlorChargingType = self.parlorChargingType--1以房间为基准 2以人数为基准

	}

	ModuleCache.ModuleManager.show_module("henanmj", "museumcostpower", powerData)
	return powerData
end

function MuseumInfoModule:refresh_cost_tips(index, isInit)
	self.payType = index
    self.view.sendData.data.payType = self.payType
	self.view.sendData.data.payNum = self.payNum

    for i = 1, #self.view.masterCostToggles do
        if i == index then
            self.view.masterCostTexts[i].text = string.format("%s(%d)", masterCostStrs[index], self.payNum)
        else
            self.view.masterCostTexts[i].text = string.format("%s", masterCostStrs[i])
        end

    end

end

-- 绑定module层的交互事件
function MuseumInfoModule:on_module_event_bind()
	self:subscibe_module_event("chessmuseumcostpower", "Event_Update_Power", function(eventHead, eventData)
		self.payNum = eventData
		self:refresh_cost_tips(self.payType)
	end)
end

-- 绑定loginModel层事件，模块内交互
function MuseumInfoModule:on_model_event_bind()
	
end

function MuseumInfoModule:on_hide()
	self.isShow = false
end

function MuseumInfoModule:on_show(data)
	print_table(data)

	self.isMjGame = not AppData.isPokerGame()

	self.selectData = data
	self.playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
	self.view.sendData = 
	{
		showType = 3,
		data = TableUtil.copy_data(data)
	}

	self.view.settingToggles[1].isOn = true

	self:get_user_data()
	self.isCoinPay = data.isCoinPay
	self.payType = data.payType
	
	self.baseNum = data.baseNum
	self.payNum = data.payNum
	self.playerCount = data.playerCount
	self.memberCount = data.memberCount
	self.roundCount = data.roundCount
	self.parlorNum = data.parlorNum
	self.configs = data.parlorConfigs
	self.parlorChargingType = data.parlorChargingType
	self.diamondCostVitality = data.diamondCostVitality
	self.qrCodeShow = data.qrCodeShow

	self.showRankListType = data.showRankListType or 1
	self.sendMsgType = data.sendMsgType or 2

	self:refresh_cost_tips(self.payType, true)
	
	 for i = 1, #self.view.masterCostToggles do
        self.view.masterCostToggles[i].isOn =(i == data.payType)
    end

    -- 允许消耗体力
    if data.diamondCostVitality == 1 then
        self.view.powerCostToggles[1].isOn = true;
        self.view.powerCostToggles[2].isOn = false;
        -- 不允许消耗体力
    elseif data.diamondCostVitality == 0 then
        self.view.powerCostToggles[1].isOn = false;
        self.view.powerCostToggles[2].isOn = true;
    end
print("---------------------data.qrCodeShow:",data.qrCodeShow)
	 -- 强制弹出群二维码
    if data.qrCodeShow == 1 then
        self.view.showQRCodeToggles[1].isOn = true;
        self.view.showQRCodeToggles[2].isOn = false;
    elseif data.qrCodeShow == 0 then
        self.view.showQRCodeToggles[1].isOn = false;
        self.view.showQRCodeToggles[2].isOn = true;
    end


	for i = 1, #self.view.ScoreboardToggles do
		self.view.ScoreboardToggles[i].isOn = data.showRankListType == i
	end

	for i = 1, #self.view.ChatAuthToggles do
		self.view.ChatAuthToggles[i].isOn = data.sendMsgType == i
	end
	
	self.isShow = true
	
	ModuleCache.ModuleManager.show_module("henanmj", "rulesetting", self.view.sendData)
	ModuleCache.ModuleManager.hide_module("henanmj", "rulesetting")
	self.view:refresh_view(data)
	
    self.view.ownRoomObj:SetActive(true)
    self.view.roomCard.text = self.modelData.roleData.cards
    self.view.powerText.text = self.modelData.roleData.coins
    self.view.moreShow:SetActive(false)

	if self.selectData.playRule == "" and (self.selectData.playerRole == "OWNER" or self.selectData.playerRole == "ADMIN") then
		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("请您先对亲友圈消耗方式、消耗数量、玩法规则进行设置，完成后“保存设置”即可体验亲友圈。", nil)
	end

end

function MuseumInfoModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject or obj.name == "ButtonClose" then
		if self.selectData.playRule == "" and (self.selectData.playerRole == "OWNER" or self.selectData.playerRole == "ADMIN") then
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("您尚未保存设置，保存设置后即可体验亲友圈。", function()
				local sendData =
				{
					payType = self.payType,
					payNum = self.payNum,
					consumeType = self.consumeType,
					parlorName = string.match(self.view.inputFieldName.text,"%s*(.-)%s*$"),
					diamondCostVitality = self.diamondCostVitality,
					qrCodeShow = self.qrCodeShow,
					wechatNumber = self.view.inputFieldWXNum.text,
					showRankListType = self.showRankListType,
					sendMsgType = self.sendMsgType,
				}

				self:dispatch_module_event("chessmuseum", "Event_Save_Data", sendData)
			end)

		else
			self.isShow = false
			ModuleCache.ModuleManager.hide_module("henanmj", "museuminfo")
			ModuleCache.ModuleManager.hide_module("henanmj", "rulesetting")
		end


	elseif(obj.name == "ButtonAdd") then
		self.selectData.type = 3
		ModuleCache.ModuleManager.show_module("henanmj", "share", self.selectData)
	elseif(obj.name == "RoomCard") then
		ModuleCache.ModuleManager.show_module("henanmj", "shop",2)
	elseif(obj.name == "ButtonExit") then
		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common_image_tex({
			topTex = "您确定要退出以下亲友圈吗？\n（退出后不能再加入该亲友圈牌局）",
			rightTex1 = "圈名："..self.selectData.parlorName ,
			rightTex2 = "圈号：0".. self.selectData.parlorNum,
			headImg = self.selectData.imageHead
		}, function()
			self:exit_museum()
		end)
	elseif(obj.name == "ButtonSave") then
		local sendData =
		{
			payType = self.payType,
			payNum = self.payNum,
			consumeType = self.consumeType,
			parlorName = string.match(self.view.inputFieldName.text,"%s*(.-)%s*$"),
			diamondCostVitality = self.diamondCostVitality,
			qrCodeShow = self.qrCodeShow,
			wechatNumber = self.view.inputFieldWXNum.text,
			showRankListType = self.showRankListType,
			sendMsgType = self.sendMsgType,
		}
		self:dispatch_module_event("chessmuseum", "Event_Save_Data", sendData)

	elseif(obj.name == "ButtonNext") then
		self.view.settingToggles[2].isOn = false
		self.view.settingToggles[2].isOn = true
    elseif(obj.name == "moreShow" or obj.name == "bgShop") then
        ModuleCache.ModuleManager.show_module("henanmj", "shop")
    elseif(obj.name == "ButtonMore") then
        self.view.moreShow:SetActive(not self.view.moreShow.activeSelf)
	elseif(obj.name == "ButtonEditor_ID") then
		if tonumber(self.modelData.roleData.userID) == tonumber(self.view.inputFieldID.text) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("该玩家已是圈主！")
		else
			self:get_user_info(self.view.inputFieldID.text)
		end

	end
end

function MuseumInfoModule:get_user_info(userID)
	print("---------------userID:",userID)
	if userID == nil or userID == "" then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请先输入玩家ID")
		return
	end

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
		showModuleNetprompt = true,
		params = {
			uid = userID,
		}
	}

	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			if retData.data then
				ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common_image_tex({
					topTex = "您确定将亲友圈转让给以下玩家吗？",
					rightTex1 = retData.data.nickname ,
					rightTex2 = "ID：".. retData.data.userId,
					headImg = retData.data.headImg
				}, function()
					self:change_museum_owner(userID)
				end)
			end
		else
			if  retData.errMsg then

			end
		end
	end, function(wwwErrorData)
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

function MuseumInfoModule:change_museum_owner(userID)
	print("---------------userID:",userID)
	if userID == nil or userID == "" then
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请先输入玩家ID")
		return
	end

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/changeParlorOwnerUid?",
		showModuleNetprompt = true,
		params = {
			uid = userID,
			ownerUid = userID,
			parlorId = self.selectData.id
		}
	}

	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("亲友圈转让成功！")
			ModuleCache.ModuleManager.hide_module("henanmj", "museuminfo")
			self:dispatch_module_event("joinroom_to_chessmuseum","Update_User_Parlor_List")
		else
			if  retData.errMsg then

			end
		end
	end, function(wwwErrorData)
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

function MuseumInfoModule:exit_museum()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/exit?",
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = self.parlorNum,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(string.format("退出%s成功！",AppData.MuseumName))
			local data =
			{
				toNotice = false,
				showMsg = false,
				parlorNum = self.parlorNum,
			}
			self:dispatch_module_event("chessmuseum", "Event_Update_Notice", data)
		elseif(retData.errMsg) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(string.format("退出%s失败！",AppData.MuseumName))
	end)
end

function MuseumInfoModule:get_user_data()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "msg/getNewMsg?",
		--showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.view:update_user_data(retData.data)
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)
end


return MuseumInfoModule



