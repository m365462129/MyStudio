-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TablePopModule = class("tablePopModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local TableUtil = TableUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local aniTime = 0.15
local PlayerPrefs = UnityEngine.PlayerPrefs

function TablePopModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "tablepop_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function TablePopModule:on_module_inited()
    
end

-- 绑定module层的交互事件
function TablePopModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function TablePopModule:on_model_event_bind()
	

end


function TablePopModule:on_click(obj, arg)	
	if(string.sub(obj.name, 1, 9) == "ButtonPao") then
		local pao = tonumber(string.sub(obj.name, 10, 10)) - 1
		if(self.view.ConfigData.isKaWuXing) then
			PlayerPrefs.SetInt(string.format("%s_kawuxing_piao",TableManager.curTableData.ruleJsonInfo.GameType), pao + 1)
			self.view:kawuxing_piao()
			return
		end
		local showPao = self.view.ConfigData.isShowPao
		local showPiao = self.view.ConfigData.isShowPiao
		local sendData = {}
		sendData.xiaojiScore = -1
		sendData.paoScore = -1
		if(showPao) then
			sendData.paoScore = pao
		end
		if(showPiao) then
			sendData.xiaojiScore = pao
		end
		if(self.view.ConfigData.isQYLaZi) then
			sendData.paoScore = pao * 10
		end
		if(self.view.ConfigData.isDongHai) then
			sendData.xiaojiScore = pao + 1
		end
		if(self.view.ConfigData.isJJHK) then
			if 1 == pao then
				local jiamai = TableManager.curTableData.ruleJsonInfo.JiaMai
				sendData.xiaojiScore = tonumber(jiamai)
			end
		end
		--ModuleCache.ModuleManager.hide_module("majiang", "tablepop")
		self:dispatch_module_event("tablestrategy", "Event_TableStragy_BeginGame", sendData)
	elseif(string.sub(obj.name,1,2) == "MJ" and not self.doAnimation and self.view.canMaiMa) then
		local index = tonumber(string.sub(obj.name, 3, 3)) - 1
		self:dispatch_module_event("tablepop", "Event_MaiMa", index)
	end
end


function TablePopModule:on_show(maiMaData)
	self.view:refresh_view(maiMaData)
	if(not maiMaData) then
		return
	end
	self.oneResultState = nil
	if(maiMaData.Result == 1) then
		self.oneResultState = maiMaData
	end
	if(self.oneResultState and self.view.ConfigData.isKaWuXing) then
		self.doAnimation = true
		local zhongMaIndex = self.oneResultState.ZhongMa[1] + 1
		local zhongMaChild = self.view.kwxChilds[zhongMaIndex]
		local sequence = self:create_sequence()
		sequence:Append(zhongMaChild.transform:DOScaleX(0,0.25):OnComplete(function()
			TableUtil.set_mj(self.oneResultState.MaiMa[zhongMaIndex], zhongMaChild, self.view.mjScaleSet)
			TableUtil.set_mj_bg(1, zhongMaChild, self.view.mjColorSet)
		end))
		sequence:Append(zhongMaChild.transform:DOScaleX(1,0.25):OnComplete(function()
			GetComponentWithPath(zhongMaChild, "HighLight", ComponentTypeName.Transform).gameObject:SetActive(true)
			self.view.kwxScore.gameObject:SetActive(true)
			self.view.kwxTitle.text = "买马完成！"
			self.view.kwxScore.text = "+" .. self:get_score(self.oneResultState.MaiMa[zhongMaIndex]) .. "f"
		end))
		sequence:OnComplete(function()
			self:become_small_animation(self.oneResultState, zhongMaIndex)
		end)
	end
end

function TablePopModule:become_small_animation(maiMaData, zhongMaIndex)
	local sequence = self:create_sequence()
	for i = 1, #maiMaData.MaiMa do
		local child = self.view.kwxChilds[i]
		if(i ~= zhongMaIndex) then
			sequence:Join(child.transform:DOScaleX(0,aniTime):OnComplete(function()
				TableUtil.set_mj(maiMaData.MaiMa[i], child, self.view.mjScaleSet)
				TableUtil.set_mj_bg(1, child, self.view.mjColorSet)
			end))
		end
	end
	sequence:OnComplete(function()
		self:become_big_animation(self.oneResultState, zhongMaIndex)
	end)
end

function TablePopModule:become_big_animation(maiMaData, zhongMaIndex)
	local sequence = self:create_sequence()
	for i = 1, #maiMaData.MaiMa do
		local child = self.view.kwxChilds[i]
		if(i ~= zhongMaIndex) then
			sequence:Join(child.transform:DOScaleX(1,aniTime))
		end
	end
	sequence:OnComplete(function()
		self:subscibe_time_event(1, false, 0):OnComplete(function(t)
			if(self.oneResultState) then
				self.doAnimation = false
				if(ModuleCache.ModuleManager.module_is_active("majiang", "tablepop")) then
					ModuleCache.ModuleManager.hide_module("majiang", "tablepop")
				end
				ModuleCache.ModuleManager.show_module("majiang", "onegameresult", maiMaData)
			end
		end)
	end)
end

function TablePopModule:get_score(pai)
	if(pai >= 28) then
		return 10
	elseif(pai % 9 == 0) then
		return 9
	else
		return pai % 9
	end
end

return TablePopModule



