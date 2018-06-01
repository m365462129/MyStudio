local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local MuseumRankingModule = class("museumRankingModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local GameManager = ModuleCache.GameManager

function MuseumRankingModule:initialize(...)
	-- 开始初始化                view        model           模块数据
	ModuleBase.initialize(self, "museumranking_view", nil, ...)

	self.view.roundTag.onValueChanged:AddListener(function(isCheck)
		self.view.roundPanel:SetActive(isCheck)
		self.view.roundTagCheckObj:SetActive(isCheck)

		self.view.subTags[2].isOn = true
		self.view.subTags[1].isOn = false
		self.view.subTags[5].isOn = false
		self:get_data_list(2)
	end)

	self.view.scoreTag.onValueChanged:AddListener(function(isCheck)
		self.view.scorePanel:SetActive(isCheck)
		self.view.scoreTagCheckObj:SetActive(isCheck)

		self.view.subTags[4].isOn = true
		self.view.subTags[3].isOn = false
		self.view.subTags[6].isOn = false
		self:get_data_list(4)
	end)

	for i =1, 6 do
		self.view.subTags[i].onValueChanged:AddListener(function(isCheck)
			local id = i
			self.view.subPanels[id]:SetActive(isCheck)
			if isCheck then
				self:get_data_list(id)
			end
		end)
	end


end


function MuseumRankingModule:on_show(museumData)
	UnityEngine.Application.targetFrameRate = 60
	self.museumData = museumData
	self:get_rank_config()
	self.ranksDtatTab = {}

	if museumData.showRankListType then
		self.view.scoreTag.gameObject:SetActive( museumData.playerRole == "OWNER" or museumData.playerRole == "ADMIN"
			or (museumData.playerRole == "MEMBER" and museumData.showRankListType == 2)
		)
	end
end

function MuseumRankingModule:on_hide()
	UnityEngine.Application.targetFrameRate = AppData.tableTargetFrameRate
end

function MuseumRankingModule:on_destroy()
	UnityEngine.Application.targetFrameRate = AppData.tableTargetFrameRate
end


function MuseumRankingModule:on_click(obj, arg)	
	print_debug(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.btnBack.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "museumranking")

	elseif obj.name == "loadButton" then
		for i =1, #self.view.loadButtons do
			if obj.gameObject == self.view.loadButtons[i] then
				self.ranksDtatTab[i].currentPage = self.ranksDtatTab[i].currentPage +1
				self:get_data_list(i, true)
			end
		end
	end
end

function MuseumRankingModule:dispose_rank_config(rankData)
	self.ranksID = {}
	if #rankData < 1 then
		return
	end

	local temp = nil
	for i = 1, #rankData do
		if rankData[i].title == "局数排行榜" then
			temp = rankData[i].titleList
			for k,v in ipairs(temp) do
				if v.intervalTitle == "昨日排行榜" then
					self.ranksID[1] = v.id
				elseif v.intervalTitle == "今日排行榜" then
					self.ranksID[2] = v.id
				elseif v.intervalTitle == "区间排行榜" or k == 3 then
					self.ranksID[5] = v.id
					self.view.roundThreeRankTex.text = v.intervalTitle
				end
			end

			if #temp == 2 then
				self.view.stateSwitcher_round:SwitchState("twoRanking")
			elseif #temp == 3 then
				self.view.stateSwitcher_round:SwitchState("threeRanking")
			end

		elseif rankData[i].title == "积分排行榜" then
			temp = rankData[i].titleList
			for k,v in ipairs(temp) do
				if v.intervalTitle == "昨日排行榜" then
					self.ranksID[3] = v.id
				elseif v.intervalTitle == "今日排行榜" then
					self.ranksID[4] = v.id
				elseif v.intervalTitle == "区间排行榜" or k == 3 then
					self.ranksID[6] = v.id
					self.view.scoreThreeRankTex.text = v.intervalTitle
				end
			end

			if #temp == 2 then
				self.view.stateSwitcher_score:SwitchState("twoRanking")
			elseif #temp == 3 then
				self.view.stateSwitcher_score:SwitchState("threeRanking")
			end
		end
	end

	self.view.roundTag.isOn = false
	self.view.roundTag.isOn = true
end

function MuseumRankingModule:get_rank_config()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "/parlor/list/parlorRankTitle?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorId = self.museumData.id,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.retData = retData.data

			self:dispose_rank_config(self.retData)

		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
	end)
end

function MuseumRankingModule:get_data_list(panelIdx, isloadMore)
	if self.ranksID == nil or self.ranksID[panelIdx] == nil then
		return
	end

	if self.ranksDtatTab[panelIdx] ~= nil  and not isloadMore then
		self.view:initLoopScrollViewList(self.ranksDtatTab[panelIdx], panelIdx)
		return
	end

	local curPageNum = 1
	if self.ranksDtatTab[panelIdx] and self.ranksDtatTab[panelIdx].currentPage then
		curPageNum = self.ranksDtatTab[panelIdx].currentPage
	end

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "/parlor/list/parlorRank?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorId = self.museumData.id,
			rankId = self.ranksID[panelIdx],
			pageSize = 50,
			pageNum = curPageNum,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.retData = retData.data
			if self.ranksDtatTab[panelIdx] == nil then
				self.ranksDtatTab[panelIdx] = self.retData
			else
				for i =1, #self.retData.userRankList do
					table.insert(self.ranksDtatTab[panelIdx].userRankList,#self.ranksDtatTab[panelIdx].userRankList +1, self.retData.userRankList[i])
				end
			end

			self.view:initLoopScrollViewList(self.ranksDtatTab[panelIdx], panelIdx)
		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
	end)
end

return MuseumRankingModule


