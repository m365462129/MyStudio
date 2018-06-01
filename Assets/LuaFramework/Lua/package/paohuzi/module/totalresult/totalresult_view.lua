---
--- Created by ju.
--- DateTime: 2017/10/23 14:47
---

---@class TotalResultView

local ViewBase = require("core.mvvm.view_base")
local Class = require("lib.middleclass")

local Manager = require("package.public.module.function_manager")

local TotalResultView = Class("TotalResultView", ViewBase)

local AssetBundleName = "paohuzi/module/result/paohuzi_totalresult.prefab"
local AssetName = "PaoHuZi_TotalResult"
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")


local AssetBundleName2 = "paohuzi/module/result/paohuzi_totalresult2.prefab"
local AssetName2 = "PaoHuZi_TotalResult2"



function TotalResultView:initialize(...)
    

    ViewBase.initialize(self, AssetBundleName, AssetName, 1)

    

    self.roomID = Manager.GetText(self.root, "Title/TextRoomNum")
    self.wanfa = Manager.GetText(self.root, "Title/TextPlayInfo")
    self.round = Manager.GetText(self.root, "Title/TextPlayInfo/TextRoundNum")
    self.startTime = Manager.GetText(self.root, "Title/StartTime")
    self.endTime = Manager.GetText(self.root, "Title/EndTime")

    self.playersHolder = Manager.FindObject(self.root, "Center/Players")
    self.btnShare = Manager.GetButton(self.root, "Center/Buttons/ButtonShare")
    self.btnBack = Manager.GetButton(self.root, "Center/Buttons/ButtonBack")

    if AppData.Game_Name == "GLZP" then
        self.ButtonNext = Manager.GetButton(self.root, "Center/Buttons/ButtonNext")
        self.ButtonNextText = Manager.GetText(self.root, "Center/Buttons/ButtonNext/Text")
    else
        self.ButtonNext = UnityEngine.GameObject.New()
    end

    if AppData.Game_Name == "GLZP" then
        self.ButtonNext.gameObject:SetActive(true)
    end


    self.textJieSan = Manager.GetText(self.root, "textJieSan")

    self.item = Manager.FindObject(self.root, "Holder/Item")
    self.items = {}
    self.items[1] = Manager.FindObject(self.root, "Holder/Item")
    self.items[2] = Manager.FindObject(self.root, "Holder/Item1")
    self.items[3] = Manager.FindObject(self.root, "Holder/Item2")
    Manager.SetActive(self.item, false)
end

return TotalResultView