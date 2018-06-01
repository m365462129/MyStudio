---
--- Created by ju.
--- DateTime: 2017/10/23 14:45
---
---@class SingleResultView
local ViewBase = require("core.mvvm.view_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")

local SingleResultView = Class("SingleResult", ViewBase)

local AssetBundleName = "paohuzi/module/result/paohuzi_singleresult.prefab"
local AssetName = "PaoHuZi_SingleResult"
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")

function SingleResultView:initialize(...)
	ViewBase.initialize(self, AssetBundleName, AssetName, 1)
	
	self.bg = Manager.FindObject(self.root, "Bg")
	self.TextDaoJiShi = Manager.GetText(self.bg, "TextDaoJiShi")
	
	self.titleImg = Manager.GetImage(self.root, "Title")
	self.titleSpriteHolder = Manager.GetComponent(self.titleImg.gameObject, "SpriteHolder")
	
	self.huangzhuang = Manager.FindObject(self.root, "HuangZhuang")

	if AppData.Game_Name == "XXZP" or AppData.Game_Name == "LDZP" then
		self.huangzhuang = Manager.FindObject(self.root, "HuangZhuangXXZP")
	end
	
	self.leftObj = Manager.FindObject(self.root, "Left")
	self.paoImg = Manager.GetImage(self.leftObj, "Line1/Pao/Image")
	self.paoSpriteHolder = Manager.GetComponent(self.paoImg.gameObject, "SpriteHolder")
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
	self.winImg = Manager.GetImage(self.rightObj, "Line1/Image")
	self.winSpriteHolder = Manager.GetComponent(self.winImg.gameObject, "SpriteHolder")
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


	self.FanXingDongHuaR = Manager.FindObject(self.root, "FanXingDongHuaR")
	self.FanXingDongHuaRImgGO = Manager.FindObject(self.root, "FanXingDongHuaR/Image")
	self.FanXingDongHua = Manager.FindObject(self.root, "fanxing/FanXingDongHua")
	self.FanXingDongCHua = Manager.FindObject(self.root, "fanxing/FanXingDongCHua")
	self.FanXingZhi = Manager.FindObject(self.root, "FanXingZhi")
	self.fanxing = Manager.FindObject(self.root, "fanxing")

	self.fanxingjPos = {}
	self.fanxingjPos[1] = Manager.FindObject(self.root, "Players/1").transform.position
	self.fanxingjPos[2] = Manager.FindObject(self.root, "Players/2").transform.position
	self.fanxingjPos[3] = Manager.FindObject(self.root, "Players/3").transform.position

	print(self.FanXingZhi.name)
	self.FanXingZhiText1 = Manager.GetComponentWithPath(self.FanXingZhi, "Image/Score", "TextWrap")
	self.FanXingZhiText2 = Manager.GetComponentWithPath(self.FanXingZhi, "Image 1/Score", "TextWrap")
    self.personInfosGo = Manager.FindObject(self.root, "Right/Line3")
	self.personInfos = {}
    for i = 1, 3 do
        self.personInfos[i] = {}
        local go = Manager.FindObject(self.personInfosGo, tostring(i))
        self.personInfos[i].Go = go
        self.personInfos[i].Image = Manager.GetImage(go, "Image")
		self.personInfos[i].ScoreLose = Manager.GetComponentWithPath(go, "Score", "TextWrap")
		self.personInfos[i].ScoreWin = Manager.GetComponentWithPath(go, "Score1", "TextWrap")
		self.personInfos[i].Name = Manager.GetText(go, "Name")
        self.personInfos[i].Lv = Manager.FindObject(go, "Lv")
    end

    self.Zong = Manager.FindObject(self.leftObj, "Line1/Zong")
	self.ZongScore = Manager.GetText(self.leftObj, "Line1/Zong/Score")
	self.ZongScoreT = Manager.GetComponentWithPath(self.Zong, "Score1", "TextWrap")

	self.HuangZhuang = Manager.FindObject(self.root, "Bg/HuangZhuang")
	self.HuangZhuang.gameObject:SetActive(false)

    if AppData.Game_Name == "GLZP" then
        self.jiang.gameObject:SetActive(false)
        self.WanFaShow.gameObject:SetActive(true)
        self.paoImg.gameObject:SetActive(false)
        self.hufa.gameObject:SetActive(false)
        self.Zong.gameObject:SetActive(true)
    else
        self.WanFaShow.gameObject:SetActive(false)
        self.paoImg.gameObject:SetActive(false)
        self.hufa.gameObject:SetActive(true)
        self.Zong.gameObject:SetActive(false)
	end

	if AppData.Game_Name == "LDZP" then
		self.WanFaShow = Manager.GetText(self.leftObj, "WanFaShow1")
		self.WanFaShow.gameObject:SetActive(true)
	end
	
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