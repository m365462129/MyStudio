---
--- Created by ju.
--- DateTime: 2017/10/23 14:45
---
---@class SingleResultView
local ViewBase = require("core.mvvm.view_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")

local SingleResultView = Class("SingleResult", ViewBase)

local AssetBundleName = "huapai/module/result/paohuzi_singleresult.prefab"
local AssetName = "PaoHuZi_SingleResult"
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

function SingleResultView:initialize(...)
	ViewBase.initialize(self, AssetBundleName, AssetName, 1)
	
	self.bg = Manager.FindObject(self.root, "Bg")
	self.TextDaoJiShi = Manager.GetText(self.bg, "TextDaoJiShi")
	
	print(Manager.FindObject(self.root, "Title"))
	self.titleImg = Manager.GetImage(self.root, "Title")
	self.titleSpriteHolder = Manager.GetComponent(self.titleImg.gameObject, "SpriteHolder")
	
	self.huangzhuang = Manager.FindObject(self.root, "HuangZhuang")

	if AppData.Game_Name == "XXZP" or AppData.Game_Name == "LDZP" then
		self.huangzhuang = Manager.FindObject(self.root, "HuangZhuangXXZP")
	end
	
	self.leftObj = Manager.FindObject(self.root, "Left")
	self.hufa = Manager.GetText(self.leftObj, "Line1/HuFa/Text")
	self.jiang = Manager.FindObject(self.leftObj, "Line1/Jiang")
    self.xiazhangParent = Manager.FindObject(self.leftObj, "Line2")
    self.WanFaShow = Manager.GetText(self.leftObj, "WanFaShow")
	self.xiazhangSample = Manager.FindObject(self.xiazhangParent, "0")
	Manager.SetActive(self.xiazhangSample, false)
	self.dipaiParent = Manager.FindObject(self.leftObj, "Line3/Layout")
	self.dipaiSample = Manager.FindObject(self.dipaiParent, "0")
	Manager.SetActive(self.dipaiSample, false)
	
	self.rightObj = Manager.FindObject(self.root, "Right")
	--self.winImg = Manager.GetImage(self.rightObj, "Line1/Image")
	--self.winSpriteHolder = Manager.GetComponent(self.winImg.gameObject, "SpriteHolder")
	self.winScore = Manager.GetText(self.rightObj, "Line1/Text")
	self.winScoreRed = Manager.GetComponentWithPath(self.rightObj, "Line1/ScoreRed", "TextWrap")
	self.winScoreGreen = Manager.GetComponentWithPath(self.rightObj, "Line1/ScoreGreen", "TextWrap")
	self.suanfenParent = Manager.FindObject(self.rightObj, "Line2")
	self.suanfenParent1 = Manager.FindObject(self.rightObj, "Line4")
	self.suanfenSample = Manager.FindObject(self.suanfenParent, "0")
	self.suanfenSample1 = Manager.FindObject(self.suanfenParent1, "0")
	Manager.SetActive(self.suanfenSample, false)
	
	self.btnShow = Manager.GetButton(self.root, "Bottom/Show")
	self.btnHide = Manager.GetButton(self.root, "Bottom/Hide")
	Manager.SetActive(self.btnHide.gameObject, false)
	self.btnNext = Manager.GetButton(self.root, "Bottom/Next")

	if Manager.FindObject(self.root, "Bottom/Next/TextDaoJiShi") then
		self.TextDaoJiShi = Manager.GetText(self.root, "Bottom/Next/TextDaoJiShi")
	end

	self.btnNextText = Manager.GetText(self.root, "Bottom/Next/Text")

	self.btnTotal = Manager.GetButton(self.root, "Bottom/Total")
	self.btnBack = Manager.GetButton(self.root, "Bottom/Back")
	self.btnExit = Manager.GetButton(self.root, "btnExit")


	self.TextRoomNum = Manager.GetText(self.root, "Bg/Title1/TextRoomNum")
	self.TextPlayInfo = Manager.GetText(self.root, "Bg/Title1/TextPlayInfo")
	self.TextRoundNum = Manager.GetText(self.root, "Bg/Title1/TextRoundNum")

	self.TextPlayInfoPai = Manager.GetText(self.root, "Bg/Title1/TextPlayInfoPai")
	self.StartTime = Manager.GetText(self.root, "Bg/Title1/StartTime")

	self.EndTime = Manager.GetText(self.root, "Bg/Title1/EndTime")
	

	

    self.personInfosGo = Manager.FindObject(self.root, "Right/Line3")
	self.personInfos = {}
    for i = 1, 3 do
        self.personInfos[i] = {}
        local go = self.personInfosGo.transform:GetChild(i - 1).gameObject
        self.personInfos[i].Go = go
        self.personInfos[i].Image = Manager.GetImage(go, "Image")
		self.personInfos[i].ScoreLose = Manager.GetComponentWithPath(go, "Score", "TextWrap")
		self.personInfos[i].ScoreWin = Manager.GetComponentWithPath(go, "Score1", "TextWrap")
		self.personInfos[i].Name = Manager.GetText(go, "Name")
		self.personInfos[i].Lv = Manager.FindObject(go, "Lv")

		self.personInfos[i].HuShu = Manager.GetText(go, "HuShu")
		self.personInfos[i].QiangShu = Manager.GetText(go, "QiangShu")
		
		local XiaZhangHolder = Manager.FindObject(go, "XiaZhangHolder")
		self.personInfos[i].XiaZhang = {}
		self.personInfos[i].XiaZhangHolder = XiaZhangHolder
		for j=1,10 do
			self.personInfos[i].XiaZhang[j] = {}
			local paiGo = XiaZhangHolder.transform:GetChild(j - 1).gameObject
			self.personInfos[i].XiaZhang[j].go = paiGo

			self.personInfos[i].XiaZhang[j].Name = Manager.GetText(paiGo, "Name")
			self.personInfos[i].XiaZhang[j].FenShu = Manager.GetText(paiGo, "FenShu")

			local paimenGo = Manager.FindObject(paiGo, "XiaZhang")
			self.personInfos[i].XiaZhang[j].paimenGo = paimenGo
			self.personInfos[i].XiaZhang[j].paimen = {}

			for k=1,8 do
				self.personInfos[i].XiaZhang[j].paimen[k] = paimenGo.transform:GetChild(k - 1).gameObject
			end
		end
    end

	self.HuangZhuang = Manager.FindObject(self.root, "Bg/HuangZhuang")
	self.HuangZhuang.gameObject:SetActive(false)

  

	
	if self.btnExit then
		local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)
		if ruleInfo.baseScore then
			self.btnExit.gameObject.transform.localScale = Vector3.New(1, 1, 1)
		else
			self.btnExit.gameObject.transform.localScale = Vector3.New(0, 0, 1)
		end
	else
		self.btnExit = UnityEngine.GameObject.New()
	end
end

return SingleResultView 