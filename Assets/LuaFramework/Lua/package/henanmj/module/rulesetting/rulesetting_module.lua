-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local require = require
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")

---@class RuleSettingModule : Module
---@field ruleSettingView RuleSettingView
---@field view RuleSettingView
local RuleSettingModule = class("RuleSettingModule", ModuleBase)
-- 常用模块引用
local ModuleCache = ModuleCache
local UnityEngine = UnityEngine
local TableUtil = TableUtil
local TableManager = TableManager
local TableManagerPoker = TableManagerPoker

local PlayerPrefsManager = ModuleCache.PlayerPrefsManager
local masterCostTips = { "亲友圈", "大赢家", "房费均摊" }
---默认第一列的局数排列 麻将使用 选项上无对应json值时
local roundNums = { 4, 8, 16 }
local Config = require("package.public.config.config")
local AppData = AppData
local Input = UnityEngine.Input

local string = string


function RuleSettingModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "rulesetting_view", nil, ...)
	Input.multiTouchEnabled = false
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function RuleSettingModule:on_module_inited()
	--UpdateBeat:Add(self.on_update, self)
	self:subscibe_module_event("joinroom", "Event_Update_GoldSetNum", function(eventHead, eventData)
		if(eventData.mode == 3) then ---金币结算中的底分设定
			local num = math.max(self.view.minGoldSetVal1, tonumber(eventData.num))

			self.view.goldSetValText1.text = num .. ""
			local goldPrefsStr1 = string.format("goldSet1_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldPrefsStr1, num)

			num = math.min(99999999, num * 30)
			self.view.goldSetValText2.text = num .. ""
			local goldPrefsStr2 = string.format("goldSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldPrefsStr2, num)
		elseif(eventData.mode == 4) then ---金币结算中的入场设定
			local num = math.max(self.view.minGoldSetVal2, tonumber(eventData.num))

			self.view.goldSetValText2.text = num .. ""
			local goldPrefsStr2 = string.format("goldSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldPrefsStr2, num)
		elseif(eventData.mode == 5) then ---金币场中的底分设定
			local num = math.max(self.view.minGoldEnterSetVal, tonumber(eventData.num))
			num = math.min(self.view.maxGoldEnterSetVal, num)

			self.view.goldEnterSetValText1.text = num .. ""
			local goldEnterPrefsStr1 = string.format("goldEnterSet1_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldEnterPrefsStr1, num)

			num = math.min(99999999, num * self.view.enterMulti)
			self.view.goldEnterSetValText2.text = num .. ""
			local goldEnterPrefsStr2 = string.format("goldEnterSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldEnterPrefsStr2, num)

			self.view.goldEnterSetValText3.text = num .. ""
			local goldEnterPrefsStr3 = string.format("goldEnterSet3_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldEnterPrefsStr3, num)
			self.view:show_create(self.wanfaType, true,self.showType)
		elseif(eventData.mode == 6) then ---金币场中的入场设定
			local num = math.max(tonumber(self.view.goldEnterSetValText1.text) * self.view.enterMulti, tonumber(eventData.num))
			num = math.min(99999999, num)

			self.view.goldEnterSetValText2.text = num .. ""
			local goldEnterPrefsStr2 = string.format("goldEnterSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldEnterPrefsStr2, num)

			self.view.goldEnterSetValText3.text = num .. ""
			local goldEnterPrefsStr3 = string.format("goldEnterSet3_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldEnterPrefsStr3, num)
		elseif(eventData.mode == 7) then ---金币场中的离场设定
			local num = math.max(math.ceil(tonumber(self.view.goldEnterSetValText2.text) * 0.5), tonumber(eventData.num))
			num = math.min(tonumber(self.view.goldEnterSetValText2.text), num)

			self.view.goldEnterSetValText3.text = num .. ""
			local goldEnterPrefsStr3 = string.format("goldEnterSet3_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
			PlayerPrefsManager.SetInt(goldEnterPrefsStr3, num)
		end
	end)
end

--function RuleSettingModule:on_destroy()
--	UpdateBeat:Remove(self.on_update, self)
--end

function RuleSettingModule:on_update()
	if self.showTip and Input.touchCount < 1 then
		self:hide_click_tip()
	end
	self.view:on_update()
end

-- 绑定module层的交互事件
function RuleSettingModule:on_module_event_bind()
	self:subscibe_module_event("chessmuseum", "Event_Save_Data", function(eventHead, eventData)
		self.parlorName = eventData.parlorName
        self.payType = eventData.payType
        self.payNum = eventData.payNum
        self.consumeType = eventData.consumeType

        self.diamondCostVitality = eventData.diamondCostVitality
		self.qrCodeShow = eventData.qrCodeShow
		self.wechatNumber = eventData.wechatNumber
		self.showRankListType = eventData.showRankListType
		self.sendMsgType = eventData.sendMsgType
        self:save_setting(true)
	end)
end

-- 绑定loginModel层事件，模块内交互
function RuleSettingModule:on_model_event_bind()


end

function RuleSettingModule:is_press_toggle(obj)
	local name = obj.name
	return (name == "1" or name == "2" or name == "1_Disable" or name == "2_Disable")
end

function RuleSettingModule:is_click_toggle(obj)
	local name = obj.name
	return (name == "1" or name == "2")
end

function RuleSettingModule:hide_click_tip()
	self.showTip = false
	self.view.clickTipObj:SetActive(false)
	--self.view.clickTipRectTransform.anchoredPosition = Vector2.New(-1000,-2000)
end

function RuleSettingModule:on_press(obj, arg)
	if(self:is_press_toggle(obj)) then
		self.showTip = Input.touchCount > 0
		local clickTip = self.view:show_click_tip(obj)
		if(clickTip) then
			local clickPos = obj.transform.position --self.view:get_world_pos(Input.mousePosition, obj.transform.position.z)
			self.view.clickTipObj:SetActive(true)
			self.view.clickTipObj.transform.position = clickPos
			self.view.clickTipObj.transform.anchoredPosition = self.view.clickTipObj.transform.anchoredPosition + Vector3.New(-362,15,0)
			self.view.clickTipText.text = clickTip
		end
	end
end

function RuleSettingModule:on_press_up(obj, arg)
	if(not self.showTip and self:is_press_toggle(obj)) then
		self:hide_click_tip()
	end
end

function RuleSettingModule:refresh_view(data)
	self.showType = data.showType
	self.view.showType = self.showType
	self.view.create:SetActive(data.showType < 3)
	self.view.save:SetActive(data.showType == 3)

	 if data.showType == 2 then

        local diamondCostVitality = data.data.diamondCostVitality;
        -- 修改创建图标
        if diamondCostVitality == 1 then
            self.view.createStateSwitch:SwitchState("ShowPowerIcon")
        elseif diamondCostVitality == 0 then
            self.view.createStateSwitch:SwitchState("ShowPayIcon")
        end
    else
        self.view.createStateSwitch:SwitchState("ShowPayNum")
    end

	if(data.showType < 3) then -- 1为正常创建 2为亲友圈创建 3为亲友圈保存
		self.museumData = data.data

		self.view.payInfoObj:SetActive(not self.museumData)
		-- self.view.textMuseumTip.gameObject:SetActive(self.museumData ~= nil)
        self.view.FreeCreatePayInfoObj:SetActive(self.museumData ~= nil)
		if(self.museumData) then
			self.view.FreeCreatePayTypeTex.text = masterCostTips[self.museumData.payType]
            -- self.view.textMuseumTip.text = string.format("注：%s(%d)",masterCostTips[self.museumData.payType],self.museumData.payNum)

            self.lastMuseumData = self.museumData
            self.configs = self.museumData.parlorConfigs
            self.parlorChargingType = self.museumData.parlorChargingType
            self.payType = self.museumData.payType

		end
		self.totalCard = self.modelData.roleData.cards or 0
		
		self.curGameId = ModuleCache.GameManager.curGameId
		self.wanfaType = ModuleCache.PlayModeUtil.get_playmodel_data(nil,nil,self.curGameId)
		--ModuleCache.Log.report_exception("错误的wanfaType", string.format("%s_%s_%s" ,ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curProvince), "")
		if not self.wanfaType then
			ModuleCache.Log.report_exception("错误的wanfaType", string.format("%s_%s_%s" ,ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curProvince), "")
			self.wanfaType = 1
		else
			if(self.wanfaType > #self.Config.createRoomTable) then
				self.wanfaType = 1
			end
		end



		if(AppData.isPokerGame() or AppData.Game_Name == "KWX" or AppData.Game_Name == "ESMJ") then
			self.wanfaType = PlayerPrefsManager.GetInt(AppData.get_url_game_name() .. "_wanfaType", 1)
		end
		self.view:show_create(self.wanfaType, true,self.showType)
		self.view:refresh_prices(self.showType, self.wanfaType)
		 if self.showType then
            if self.showType == 2 then
                self.view.costText.text = "x" .. self:get_pay_num()
            end
        end

		if self.view.needDiam == 0 and self.showType == 1 then
			self.view.createStateSwitch:SwitchState("NotShowPayNum")
		end
		self:dispatch_module_event("rulesetting", "Event_Send_WanfaType", self.wanfaType)
	else
		local data = data.data
		self.lastMuseumData = data

		local notHaveRule = (data.playRule == "")
		if notHaveRule then
			self.wanfaType = 1
			self.view:show_create(self.wanfaType, true,self.showType)
			data.playRule = self.view:get_payinfo_data(1)
		end

		self.playRule = TableUtil.convert_rule(data.playRule)
		local gameType = self.playRule.GameType or self.playRule.gameType or self.playRule.game_type or self.playRule.bankerType
		if(not gameType) then
			self.wanfaType = 4
		else
			self.wanfaType = Config.GetWanfaIdx(gameType)
		end

		self.payType = data.payType
		self.payNum = data.payNum
		self.playerCount = data.playerCount
		self.roundCount = data.roundCount
		self.parlorNum = data.parlorNum
		self.parlorName = data.parlorName
		self.consumeType = data.consumeType
		self.configs = data.parlorConfigs
		self.parlorChargingType = data.parlorChargingType
		self.showRankListType = data.showRankListType
		self.sendMsgType = data.sendMsgType
		self.wechatNumber = data.wechatNumber

--print("------------------self.playerCount:",self.playerCount,self.roundCount,self.lastMuseumData.playRule)
		self.view.saveTip.text = string.format("注：%s(%d)", masterCostTips[self.payType], self.payNum)
		if(not notHaveRule) then
			self.view:show_create(self.wanfaType, true,self.showType)
		end
		self:refresh_toggle_view_museum(data.playRule)
	end
end

function RuleSettingModule:on_click(obj, arg)
	--print_debug(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonCreate.gameObject then
		--local rule = self.view:get_round_data(self.wanfaType)
		if(AppData.isPokerGame()) then
			self:connect_login_server()
			return
		end
		TableManager:connect_login_server(function()
			TableManager:request_login_login_server(self.modelData.roleData.userID, self.modelData.roleData.password)
		end,
		--登录成功回调
		function(data)
			if(not data.ErrorCode or data.ErrorCode == 0)then
				local createInfo =
				{
					GameName = Config.get_create_name(self.wanfaType),
					RoundCount = self.view:get_round_data(self.wanfaType,self.museumData),
					Rule = self.view:get_payinfo_data(self.wanfaType, self.museumData),
					HallID = 0,
				}
				if(self.museumData) then
					createInfo.HallID = self.museumData.parlorNum
					createInfo.Rule = ModuleCache.Json.decode(createInfo.Rule)
					createInfo.Rule.PayType = self.museumData.payType
					createInfo.Rule.consumeType = self.museumData.consumeType

					--TODO XLQ:跑胡子房间设置没有局数（用胡息结算代替局数）
					if createInfo.Rule.roundCount == 1 and createInfo.Rule.JieSuanHuXi then
						createInfo.Rule.roundCount = createInfo.Rule.JieSuanHuXi

						createInfo.RoundCount = createInfo.Rule.JieSuanHuXi
					end

					createInfo.Rule = ModuleCache.Json.encode(createInfo.Rule)
				end
				print_table(createInfo,"------------createInfo:")
				TableManager:henanmj_request_create_room(createInfo)
			else
				TableManager:disconnect_login_server()
				if data.ErrorInfo == "密码检验失败" or data.ErrorInfo == "密码校验失败" then
					ModuleCache.GameManager.logout()
				end
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
			end
		end, nil, nil, function ()
			TableManager:showNetErrDialog(nil)
		end)
	elseif(obj.name == "ButtonSave") then
		local wanfaName = ""
		local ruleName = ""
		local renshu = 4
		local ruleStr = self.view:get_payinfo_data(self.wanfaType)

		wanfaName,ruleName,renshu = TableUtil.get_rule_name(ruleStr , false)

		local tip = string.format("您当前设置的快速组局玩法：\n%s %s",wanfaName,ruleName)

		--字牌公告规则特殊处理
		if (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
			ruleName = TableUtil.get_rule_name_paohuzi(ruleStr)

			tip = string.format("您当前设置的快速组局玩法：\n %s",ruleName)
		end

		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(tip, function()
			self:save_setting()
		end)
	elseif(self:is_click_toggle(obj)) then
		local retData = self.view.toggles[obj.transform.parent.parent.name]
		self.view:click_toggle(retData, self.showType, self.wanfaType)
		if self.showType then
			if self.showType == 3 then
				self.view.saveTip.text =string.format("注：%s(%d)",masterCostTips[self.payType],self:get_pay_num())
			elseif self.showType == 2 then
				self.view.costText.text = "x".. self:get_pay_num()
			end
		end

	elseif(string.sub(obj.name, 1, 7) == "CopyBtn") then
		local array = string.split(obj.name, "_")
		local retData = self.view.tagBtnToggles[array[2]]
		self.wanfaType = tonumber(array[2])
		local gameType = Config.get_wanfaType_name(self.wanfaType)
		local playModeData = ModuleCache.PlayModeUtil.get_playmodel_data(gameType)
		if(playModeData)then
			-- 这里可以用createName吗？
			--ModuleCache.GameManager.change_game_by_gameName(playModeData.gameName, playModeData.name)
			ModuleCache.GameManager.change_game_by_gameName(playModeData.createName, true)
		end


		self.view:click_tag_toggle(retData, self.showType, self.wanfaType)
		self:dispatch_module_event("rulesetting", "Event_Send_WanfaType", self.wanfaType)
	elseif(obj.name == "ButtonGoldSet1")  then
		ModuleCache.ModuleManager.show_module("henanmj", "joinroom",{mode = 3, num = self.view.goldSetValText1.text})
	elseif(obj.name == "ButtonGoldSet2")  then
		ModuleCache.ModuleManager.show_module("henanmj", "joinroom",{mode = 4, num = self.view.goldSetValText2.text})
	elseif(obj.name == "ButtonGoldEnterSet1")  then
		ModuleCache.ModuleManager.show_module("henanmj", "joinroom",{mode = 5, num = self.view.goldEnterSetValText1.text})
	elseif(obj.name == "ButtonGoldEnterSet2")  then
		ModuleCache.ModuleManager.show_module("henanmj", "joinroom",{mode = 6, num = self.view.goldEnterSetValText2.text})
	elseif(obj.name == "ButtonGoldEnterSet3")  then
		ModuleCache.ModuleManager.show_module("henanmj", "joinroom",{mode = 7, num = self.view.goldEnterSetValText3.text})
	end
end

function RuleSettingModule:on_show(data)
	self.Config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))
	self.view.Config = self.Config
	self:refresh_view(data)
end

--- 根据亲友圈的规则反推出对应按钮的勾选与显示
function RuleSettingModule:refresh_toggle_view_museum(rule)
	local ruleTable = ModuleCache.Json.decode(rule)
	for k,v in pairs(self.view.toggles) do
		local toggleData = v.toggleData
		local toggle = v
		if (k == "1_1_1" or k == "1_1_2" or k == "1_1_3") and not string.find(toggleData.json, "roundCount") then
			local splitStrs = string.split(k, "_")
			local curRound = roundNums[tonumber(splitStrs[3])]
			if(curRound == (ruleTable.roundCount or self.roundCount)) then
				self.view:click_toggle(toggle,self.showType,self.wanfaType)
			end
		else
			local isOn, onIndex = TableUtil.check_toggle_on(toggleData, rule)
			if (isOn) then
				if(toggleData.toggleType == 1) then
					self.view:click_toggle(toggle,self.showType,self.wanfaType)
				else
					self.view:refresh_textColor(toggle, true)
				end
				if(toggleData.dropDown) then
					local splitStrs = string.split(toggleData.dropDown, ",")
					local splitTitles = nil
					if(toggleData.dropDownTitles) then
						splitTitles = string.split(toggleData.dropDownTitles, ",")
					end
					toggle.drop.transform.sizeDelta = Vector2(toggleData.dropDownWidth or 106,toggle.drop.transform.sizeDelta.y)
					toggle.dropRect.sizeDelta = Vector2(toggle.dropRect.sizeDelta.x,65*#splitStrs)
					toggle.drop.options:Clear()
					for i = 1, #splitStrs do
						local title = splitStrs[i] .. (toggleData.dropAddStr or "倍")
						if(splitTitles) then
							title = splitTitles[i]
						end
						local optionData = UnityEngine.UI.Dropdown.OptionData(title)
						toggle.drop.options:Add(optionData)
					end
					toggle.dropText.text = splitStrs[onIndex] .. (toggleData.dropAddStr or "倍")
					if(splitTitles) then
						toggle.dropText.text = splitTitles[onIndex]
					end
					toggle.drop.value = onIndex - 1
					PlayerPrefsManager.SetInt(toggle.dropKey, onIndex - 1)
				end
			elseif(toggleData.toggleType == 2) then
				self.view:refresh_textColor(toggle, false)
			end
		end
	end
	if(self.view.goldSetObj and self.view.goldSetObj.activeSelf) then
		self.view.goldSetValText1.text = ruleTable.baseScore .. ""
		self.view.goldSetValText2.text = ruleTable.minJoinCoin .. ""
		local goldPrefsStr1 = string.format("goldSet1_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
		PlayerPrefsManager.SetInt(goldPrefsStr1, ruleTable.baseScore)
		local goldPrefsStr2 = string.format("goldSet2_%s_%s_%s", AppData.App_Name, AppData.Game_Name, self.wanfaType)
		PlayerPrefsManager.SetInt(goldPrefsStr2, ruleTable.minJoinCoin)
	end
end

--- 获取下拉框的索引值
function RuleSettingModule:get_drop_index(value,dropList)
	for i = 1, #dropList do
		if(value == tonumber(dropList[i])) then
			return i
		end
	end
end

--- 保存亲友圈设置
function RuleSettingModule:save_setting(isUniversalSet)
    isUniversalSet = isUniversalSet or false

	local rule = self.view:get_payinfo_data(self.wanfaType)
	rule = ModuleCache.Json.decode(rule)
	--print_table(rule,"--------------------rule---")
	rule.PayType = self.payType
	rule.consumeType = self.consumeType

	--TODO XLQ:跑胡子房间设置没有局数（用胡息结算代替局数）
	if rule.roundCount == 1 and rule.JieSuanHuXi then
		rule.roundCount = rule.JieSuanHuXi
		self.lastMuseumData.roundCount = rule.JieSuanHuXi
	end

	--TODO XLQ 亲友圈设置界面 -   isUniversalSet ：通用设置界面  点击保存 局数和人数 保持当前亲友圈的设置的局数和人数不变
	if isUniversalSet then
		rule.roundCount = self.lastMuseumData.roundCount
		rule.playerCount = self.lastMuseumData.playerCount
		rule.PlayerNum = self.lastMuseumData.playerCount
	end


	if AppData.Game_Name == "RUNFAST" then
		if rule.game_type == 1 then --1：安徽跑得快  2：经典玩法
			rule.allow_unruled_multitriple = false --最后一手飞机可以乱带（安徽跑得快：false, 经典玩法：true）
			rule.rate = 1
			rule.tripleA_is_bomb = true
		else
			rule.allow_unruled_multitriple = true
			rule.tripleA_is_bomb = false
		end

		if rule.playerCount == 2 then
			rule.black3_on_firstloop = false
		elseif rule.playerCount == 4 then
			rule.init_card_cnt = 13
			rule.tripleA_is_bomb = false
		end

		rule.no_triple_p1 = false --最后一手三带一（安徽跑得快：false, 经典玩法：true）
		rule.ruleType = 1
		rule.bankerType = 0
	end

	rule = ModuleCache.Json.encode(rule)
	--print(self.wanfaType,"##############2######",rule)

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/room/updateParlor?",
		params = {
			uid = self.modelData.roleData.userID,
			platformName = ModuleCache.GameManager.customPlatformName,
			assetVersion = ModuleCache.GameManager.appAssetVersion,
			playRule = rule,
			parlorNum = self.parlorNum,
			playerCount = self.lastMuseumData.playerCount,
			roundCount = self.lastMuseumData.roundCount,
			payType =self.payType,
			payNum = self.payNum,
			consumeType = self.consumeType,--"CONSUME_CARD",--
			parlorName = self.parlorName,
            diamondCostVitality = self.diamondCostVitality,
			qrCodeShow = self.qrCodeShow,
			wechatNumber = self.wechatNumber,

			showRankListType = self.showRankListType,
			sendMsgType = self.sendMsgType,
		}
	}
	--local roundCount = self.view:get_round_data(self.wanfaType)
	-- if(self.payType == 3 or self.payType == 2) then
	-- 	local level = 0
	-- 	if(self.payType == 3) then
	-- 		level = self:get_pay_level(self.roundCount, self.playerCount)
	-- 	else
	-- 		level = self:get_pay_level(self.roundCount, 1)
	-- 	end
	-- 	local totalNum = self:get_total_num(roundCount, level)
	-- 	local playerCount = self.view:get_player_count(self.wanfaType)
	-- 	if(self.payType == 3) then
	-- 		requestData.params.payNum = math.ceil(totalNum/playerCount)
	-- 	else
	-- 		requestData.params.payNum = totalNum
	-- 	end
	-- elseif(self.payType == 1) then
	-- 	requestData.params.payNum = math.ceil(roundCount/8)
	-- end

	--TODO XLQ 亲友圈设置界面 -   isUniversalSet ：通用设置界面  点击保存 局数和人数 保持当前亲友圈的设置的局数和人数不变
	if isUniversalSet == false then
        requestData.params.payNum =self:get_pay_num()
		requestData.params.playerCount = self.view:get_player_count(self.wanfaType)
		requestData.params.roundCount = self.view:get_round_data(self.wanfaType,self.museumData)
    end

	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(AppData.MuseumName .."数据修改成功！")
			local wanfaName = ""
			local ruleName = ""
			local renshu = 4

			--TODO XLQ:亲友圈玩法不显示支付方式
			rule = ModuleCache.Json.decode(rule)
			rule.PayType = -1
			rule = ModuleCache.Json.encode(rule)

			wanfaName,ruleName,renshu = TableUtil.get_rule_name(rule, false)

			--字牌公告规则特殊处理
			if (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
				ruleName = TableUtil.get_rule_name_paohuzi(rule)
			end

			local data =
			{
				toNotice = self.view.noticeToggle.isOn,
				showMsg = false,
				parlorNum = self.parlorNum,
				notice = string.format("%s %s",wanfaName,ruleName)
			}

			--字牌公告不显示玩法名
			if (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
				data.notice = ruleName
			end

			self:dispatch_module_event("rulesetting", "Update_Power",self.diamondCostVitality);
			self:dispatch_module_event("chessmuseum", "Event_Update_Notice", data)
		elseif(retData.errMsg) then
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(AppData.MuseumName .. "数据修改失败！")
	end)
end

--- 获取局数
function RuleSettingModule:get_round_data(roundCount)

    for i=1,#self.configs do
        local config = self.configs[i]
        if(config.round == roundCount) then
            return config
        end
    end
    return nil
end

function RuleSettingModule:get_pay_level(roundCount, playerCount)

    local config = self:get_round_data(self.lastMuseumData.roundCount)
    local datas = string.split(config.coinNums, ",")
	local playerCount = self.lastMuseumData.playerCount
	local lastMuseumDataPayNum = self.lastMuseumData.payNum
	--TODO 根据策划要求2人与3人花费是一样的，之前没加这个有个很严重的漏洞
	if not AppData.isPokerGame() and self.lastMuseumData.parlorChargingType == 2 and playerCount == 2 then
		playerCount = 3
		lastMuseumDataPayNum = math.ceil(lastMuseumDataPayNum / 1.5)
	end
    for i = 1, #datas do
        local num = tonumber(datas[i])

        if self.lastMuseumData.parlorChargingType == 1 then
            if (self.lastMuseumData.payType == 3) then
                num = math.ceil(tonumber(datas[i]) / playerCount)
            end
        elseif self.lastMuseumData.parlorChargingType == 2 then
			-- 如果是圈主支付直接返回固定的1
			if self.payType == 1 then
				return 1
			end

            if (self.lastMuseumData.payType ~= 3) then
                num = tonumber(datas[i]) * playerCount
            end
        end

        if (lastMuseumDataPayNum == num) then
            return i
        elseif (lastMuseumDataPayNum < num) then
            if (i - 1 > 0) then
                return i - 1
            else
                return i
            end
        end

    end
    return 1
end


function RuleSettingModule:get_pay_num()
    local roundCount = self.view:get_round_data(self.wanfaType,self.museumData)

    local playerCount = self.view:get_player_count(self.wanfaType)
    local config = self:get_round_data(roundCount)
    local datas = string.split(config.coinNums, ",")
    local tempPayNum = tonumber(datas[self:get_pay_level(roundCount, playerCount)])
   --  print(self.payType,self.parlorChargingType,"--------0-----------------lv:",self:get_pay_level(roundCount, playerCount), tempPayNum,roundCount)
    if self.parlorChargingType == 1 then
        if (self.payType == 3) then
            tempPayNum = math.ceil(tempPayNum / playerCount)

        end
    elseif self.parlorChargingType == 2 then
		if (self.payType ~= 3) then
			if not  AppData.isPokerGame() and playerCount == 2 then
				tempPayNum = tonumber(tempPayNum) * 3
			else
				tempPayNum = tonumber(tempPayNum) * playerCount
			end
		elseif not  AppData.isPokerGame() and playerCount == 2 then --麻将的2人玩法都按3人收费
			tempPayNum = math.ceil(tonumber(tempPayNum *3 / 2) )
		end
    end
    -- print(self.payType,self.parlorChargingType,"-------1------------------lv:",self:get_pay_level(roundCount, playerCount), tempPayNum,roundCount)
    return tempPayNum
end

function RuleSettingModule:get_total_num(roundCount, level)
	local config = self:get_round_data(roundCount)
	local datas = string.split(config.coinNums, ",")
	print(datas[level])
	return tonumber(datas[level])
end

function RuleSettingModule:connect_login_server()
	TableManager:connect_login_server(function()
			TableManager:request_login_login_server(self.modelData.roleData.userID, self.modelData.roleData.password)
		end,
	--登录成功回调
	function(data)
		if(not data.ErrorCode or data.ErrorCode == 0)then
			if(data.RoomID ~= 0)then
				TableManager:request_join_room_login_server(data.RoomID)
				return
			end
			
			self.selectedRule = self.view:get_payinfo_data(self.wanfaType)
			local ruleTable = ModuleCache.Json.decode(self.selectedRule)
			local hallID = 0
			if(self.museumData) then
				hallID = self.museumData.parlorNum

				ruleTable.PayType =  self.museumData.payType
				ruleTable.consumeType = self.museumData.consumeType
				self.selectedRule = ModuleCache.Json.encode(ruleTable)
			end

			if AppData.Game_Name == "RUNFAST" then
				if ruleTable.game_type == 1 then --1：安徽跑得快  2：经典玩法
					ruleTable.allow_unruled_multitriple = false --最后一手飞机可以乱带（安徽跑得快：false, 经典玩法：true）
					ruleTable.rate = 1
					ruleTable.tripleA_is_bomb = true
				else
					ruleTable.allow_unruled_multitriple = true
					ruleTable.tripleA_is_bomb = false
				end

				if(ruleTable.playerCount <= 2) then
					ruleTable.every_round_black3_first = false
					ruleTable.first_must_black3 = false
					ruleTable.pay_all = false
				end

				if ruleTable.playerCount == 4 then
					ruleTable.init_card_cnt = 13
					ruleTable.tripleA_is_bomb = false
				end

				--ruleTable.wanfa = ""
				--if(ruleTable.gameName == "DHJSQP_RUNFAST_RUNFAST") then
				--	ruleTable.wanfa = "jiangsu"
				--end

				--检查参数是否存在
				ruleTable.rate = ruleTable.rate or 1
				ruleTable.no_triple_p1 = false --最后一手三带一（安徽跑得快：false, 经典玩法：true）
				ruleTable.ruleType = 1
				ruleTable.bankerType = 0
				self.selectedRule = ModuleCache.Json.encode(ruleTable)
				local createInfo = {
					GameName = AppData.Runfast_GameName,
					RoundCount = ruleTable.roundCount,
					Rule = self.selectedRule,
					HallID = hallID,
				}
				TableManager:henanmj_request_create_room(createInfo)
				return
				--TableManagerPoker:request_create_room_login_server(AppData.Runfast_GameName, ruleTable.roundCount, self.selectedRule,hallID)
			end

			--if AppData.Game_Name == "ZHAJINHUA" then
			--	print("创建房间炸金花==========")
			--	--ruleTable.gameName = "DHAHQP_ZHAJINHUA_ZHAJINHUA"
			--	-- ruleTable.roundCount = 8 --局数
			--	-- ruleTable.menNum = 0 --闷牌局数
			--	-- ruleTable.maxScore = 10 --封顶分数
			--	-- ruleTable.special = 0--特殊牌型0:散牌235大于豹子, 1:散牌235大于AAA
			--	-- ruleTable.allowEnter = false --游戏开始后允许加入
			--	-- ruleTable.addType = 0 --0:无 ,1: 豹子加分 ,2:顺金加分, 3: 豹子顺金都加分
			--	-- ruleTable.payType = 0--支付方式0:aa ,1:房主, 2:大赢家
			--	-- ruleTable.playerCount = 6
			--	if(ruleTable.leopardAddScore and ruleTable.shunKingAddScore) then
			--		ruleTable.addType = 3
			--	elseif(ruleTable.shunKingAddScore) then
			--		ruleTable.addType = 2
			--	elseif(ruleTable.leopardAddScore) then
			--		ruleTable.addType = 1
			--	else
			--		ruleTable.addType = 0
			--	end
			--	print_table(ruleTable)
			--	self.selectedRule = ModuleCache.Json.encode(ruleTable)
			--	local createInfo = {
			--		GameName = AppData.ZhaJinHua_GameName,
			--		RoundCount = ruleTable.roundCount,
			--		Rule = self.selectedRule,
			--		HallID = hallID
			--	}
			--	TableManager:henanmj_request_create_room(createInfo)
			--	return
			--	--TableManagerPoker:request_create_room_login_server(AppData.ZhaJinHua_GameName, ruleTable.roundCount, self.selectedRule,hallID)
			--end

			local isPokerGame, packageConfig = AppData.isPokerGame()
			if(isPokerGame)then
				local createInfo = {
					GameName = packageConfig:get_full_game_name(),
					RoundCount = ruleTable.roundCount,
					Rule = self.selectedRule,
					HallID = hallID
				}
				TableManager:henanmj_request_create_room(createInfo)
				--TableManagerPoker:request_create_room_login_server(packageConfig:get_full_game_name(), ruleTable.roundCount, self.selectedRule,hallID)
				return
			end
		else
			TableManager:disconnect_login_server()

			if data.ErrorInfo == "密码检验失败" or data.ErrorInfo == "密码校验失败" then
                ModuleCache.GameManager.logout()
            end
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
		end
	end,
	--创建成功回调
	function (data)
		print("创建成功回调")
		if((not data.ErrorCode or data.ErrorCode == 0) and data.RoomID ~= 0)then
			local roleData = self.modelData.roleData
			roleData.myRoomSeatInfo.Rule = self.selectedRule
			local ruleTable = ModuleCache.Json.decode(self.selectedRule)
			--ModuleCache.GameManager.set_used_playMode(ruleTable.GameID)
			if AppData.Game_Name == "RUNFAST" then
				TableManager.RunfastRuleJsonString = self.selectedRule
				print("====跑得快创建房间规则:"..self.selectedRule)
			elseif AppData.Game_Name == "ZHAJINHUA" then
				print("====炸金花创建房间规则:"..self.selectedRule)
			end
			roleData.myRoomSeatInfo.RoundCount = ruleTable.roundCount
			TableManager:disconnect_login_server()
			self:connect_game_server()
		else
			TableManager:disconnect_login_server()
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
		end
	end,
	--加入房间回调
	function (data)
		if data.ErrorCode == 0 then
			TableManager:disconnect_login_server()
			self:connect_game_server()
		else
			TableManager:disconnect_login_server()
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
		end
	end)
end

function RuleSettingModule:connect_game_server()
	TableManagerPoker.reconnectGameServerTimes = 0
	TableManagerPoker:connect_game_server(function()
		TableManagerPoker:request_login_game_server(self.modelData.roleData.userID, self.modelData.roleData.myRoomSeatInfo.Password)
	end,

	function(data)
		if(not data.err_no  or data.err_no == "0") then
			ModuleCache.ModuleManager.destroy_module("biji", "createroom")
			ModuleCache.ModuleManager.destroy_package("henanmj")
			ModuleCache.ModuleManager.destroy_package("public")
			ModuleCache.SoundManager.stop_music()

			local ruleTable = self.modelData.roleData.myRoomSeatInfo.RuleTable
			if ruleTable.gameName == AppData.CowBoy_GameName then
				if (ruleTable.name and ruleTable.name == "ZhaJinNiu") then
					ModuleCache.ModuleManager.show_module("cowboy", "table_zhajinniu")
				else
					ModuleCache.ModuleManager.show_module("cowboy", "table")
				end
				return
			end

			local isPokerGame, packageConfig = AppData.isPokerGame()
			if(isPokerGame)then
				if packageConfig.package_name == "biji" and self.wanfaType == 3 then
					ModuleCache.ModuleManager.show_module(packageConfig.package_name, "tablebijisix")
					return
				end
				ModuleCache.ModuleManager.show_module(packageConfig.package_name, packageConfig.table_module_name)
			end
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.err_no)
		end
	end)
end

function RuleSettingModule:on_hide()
	self.view:save_drop_values()
end

return RuleSettingModule



