--
-- Created by IntelliJ IDEA.
-- User: 朱腾芳
-- Date: 2016/12/7
-- Time: 18:17
-- To change this template use File | Settings | File Templates.
--
local class = require("lib.middleclass")
local ViewBase = require('package.paohuzi.module.tablebase.tablebase_view')

---@class PaoHuZiTableView:TableBaseView
local TableView = class("PaoHuZi.TableView", ViewBase)

local Manager = require("package.public.module.function_manager")
local ModuleCache = ModuleCache

function TableView:initialize(...)
    ViewBase.initialize(self, "paohuzi/module/table/paohuzi_table.prefab", "PaoHuZi_Table", 0)

    --- 克隆根节点
    self.cloneRoot = Manager.FindObject(self.root, "Clone")
    self.chuzhangObj = Manager.FindObject(self.cloneRoot, "ChuZhang")
    self.QiZhangObj = Manager.FindObject(self.cloneRoot, "QiZhang")
    self.chuTX = Manager.FindObject(self.cloneRoot, "ChuTX" .. AppData.Game_Name)

    self.ButtonActivity = Manager.GetButton(self.root, "ButtonActivity")

    self.spriteRedPoint = Manager.FindObject(self.root, "ButtonActivity/RedPoint")

    --- 右边布局：聊天、语音
    self.RightBtn = Manager.FindObject(self.root, "RightBtn")
    self.btnChat = Manager.GetButton(self.root, "RightBtn/Chat")
    self.btnVoice = Manager.GetButton(self.root, "RightBtn/Voice")

    self.ImageAnticheat = Manager.FindObject(self.root, "ImageAnticheat")
    

    --- 右上角布局：设置
    self.btnSettings = Manager.GetButton(self.root, "TopRight/Child/BatteryTime/Settings")

    --- 中间布局：离开房间、邀请好友、开始游戏
    self.centerBtnHolder = Manager.FindObject(self.root, "CenterBtn")
    self.btnLeave = Manager.GetButton(self.root, "CenterBtn/Leave")
    self.btnInvite = Manager.GetButton(self.root, "CenterBtn/Invite")
    self.btnStart = Manager.GetButton(self.root, "CenterBtn/Start")
    self.btnStartHui = Manager.GetButton(self.root, "CenterBtn/StartHui")
    self.btnStartZhunBei = Manager.GetButton(self.root, "CenterBtn/btnStartZhunBei")

    
    

    --- 中间布局：余张、将牌
    self.remainderCardObj = Manager.FindObject(self.root, "Center/Remainder")
    self.PaiBeiMen = Manager.FindObject(self.root, "Center/Remainder/PaiBeiMen")
    self.PaiBeiMen1 = Manager.FindObject(self.root, "Center/Remainder/PaiBeiMen")
    self.PaiBeiMen2 = Manager.FindObject(self.root, "Center/Remainder/PaiBeiMen1")
    self.PaiBeiMenChildren = {}
    for i=1,6 do
        self.PaiBeiMenChildren[i] = Manager.FindObject(self.PaiBeiMen, i .. "/Image")
    end


    self.remainderCardImg = Manager.GetImage(self.remainderCardObj, "Image")
    self.remainderCardSpriteHolder = Manager.GetComponent(self.remainderCardImg.gameObject, "SpriteHolder")
    self.remainderCardNum = Manager.GetText(self.remainderCardObj, "Num")
    self.jiangpaiObj = Manager.FindObject(self.root, "Center/JiangPai")
    self.jiangpaiImg = Manager.GetImage(self.jiangpaiObj, "Image")
    self.jiangpaiBg = Manager.FindObject(self.jiangpaiObj, "Bg")
    self.jiangpaiTag = Manager.FindObject(self.jiangpaiObj, "Tag")
    self.jiangpaiSpriteHolder = Manager.GetComponent(self.jiangpaiImg.gameObject, "SpriteHolder")
    self.CenterPos = Manager.FindObject(self.root, "Center/CenterPos").transform.position
    self.TopPos = Manager.FindObject(self.root, "Center/TopPos").transform.position

    --- 出牌标识线
    self.line = Manager.FindObject(self.root, "Center/Line")
    self.bgSprite1 = Manager.GetImage(self.tableBg1).sprite
    self.bgSprite2 = Manager.GetImage(self.tableBg2).sprite
    self.bgSprite3 = Manager.GetImage(self.tableBg3).sprite

    --- 顶部布局：玩法、局数
    self.txtWanFa = Manager.GetText(self.root, "Top/Image/WanFa")
    --self.RoomIDHuiFang = Manager.GetText(self.root, "Top/Image/RoomIDHuiFang")
    self.txtJushu = Manager.GetText(self.root, "Top/Image/JuShu")
    self.txtWanFaShow = Manager.GetText(self.root, "Center/WanFaShow")
    self.buttonWarning = Manager.GetButton(self.root, "Top/Image/ButtonWarning")

    self.GpsErr = Manager.FindObject(self.root, "Top/GpsErr")
    self.GpsErrText = Manager.GetText(self.root, "Top/GpsErr/Text")



    --- 左上角布局：房号、玩法规则
    self.txtRoomID = Manager.GetText(self.root, "TopRight/Child/BatteryTime/RoomID/Text")
    if self.txtRoomID == nil then
        self.txtRoomID = Manager.GetText(self.root, "TopLeft/Child/Begin/RoomID/ImageBackground/Text")
    end


    self.btnRule = Manager.GetButton(self.root, "TopLeft/Child/Begin/ButtonRule")



    --- 玩家布局：座位信息、手牌
    self.playersHolder = {}
    for i = 1, 3 do
        self.playersHolder[i] = Manager.FindObject(self.root, "Players/" .. i)
    end
    self.handcardHolder = Manager.FindObject(self.root, "Players/HandView")
    self.ctrlHolder = Manager.FindObject(self.root, "Control")

    self.ctrlHolder.transform.localPosition = Vector3.New(-100, 0, 0)

    self.FaPai = {}
    self.FaPaiGo = Manager.FindObject(self.root, "Center/FaPai")
    
    for i=1,3 do
        self.FaPai[i] = {}
        self.FaPai[i].position = Manager.FindObject(self.FaPaiGo, "Item"..i).transform.position
        for j=1,3 do
            self.FaPai[i][j] = Manager.FindObject(self.FaPaiGo, "Item"..i.."/Image"..j)
        end
    end

    --- 测试环境
    self.btnReconnect = Manager.GetButton(self.root, "Reconnect")

    self.objRightTop = Manager.FindObject(self.root, "TopRight")

    self.FaPaiTeXiao = Manager.FindObject(self.root, "FaPai")
    self.FaPaiTeXiao1 = Manager.FindObject(self.root, "FaPai")
    self.FaPaiTeXiao2 = Manager.FindObject(self.root, "FaPai1")
    
    if AppData.Game_Name == "GLZP" then
        self.jiangpaiBg.gameObject:SetActive(false)
        self.jiangpaiTag.gameObject:SetActive(false)
        self.jiangpaiImg.gameObject:SetActive(false)
        self.jiangpaiImg = Manager.GetImage(self.jiangpaiObj, "Image1")
        self.jiangpaiImg.gameObject:SetActive(false)
    end

 



    self.ShiFouDaTuo = Manager.FindObject(self.root, "ShiFouDaTuo")

    self.ButtonDaTuo = Manager.GetButton(self.root, "ShiFouDaTuo/ButtonDaTuo")
    self.ButtonBuDaTuo = Manager.GetButton(self.root, "ShiFouDaTuo/ButtonBuDaTuo")

    if not self.ButtonDaTuo then
        self.ButtonDaTuo = UnityEngine.GameObject.New()
        self.ButtonBuDaTuo = UnityEngine.GameObject.New()
    end


    self.LeftRoot1 = Manager.FindObject(self.root, "TopLeft1/Root")
    if self.LeftRoot1 then

        
        self.BtnLeftClose = Manager.GetButton(self.LeftRoot1, "LeftRoot/BtnLeftClose")
        self.BtnLeftClose.onClick:AddListener(
        function()
            self.LeftRoot1.gameObject:SetActive(false)
        end
        )
        
        self.BtnLeftOpen = Manager.GetButton(self.root, "TopLeft1/BtnLeftOpen")
        self.BtnLeftOpen.onClick:AddListener(
            function()
                
                self.LeftRoot1.gameObject:SetActive(true)
            end
        )
        
        self.JinBiChangMatch = Manager.FindObject(self.LeftRoot1, "LeftRoot/Bg/JinBiChangMatch")

        self.btnSettings1 = Manager.GetButton(self.JinBiChangMatch, "BtnSetting")
        self.btnLeave1 = Manager.GetButton(self.JinBiChangMatch, "ButtonJinBiChangExit")
        self.ButtonRuleExplain1 = Manager.GetButton(self.JinBiChangMatch, "ButtonRuleExplain")

        self.ButtonRule1 = Manager.GetButton(self.root, "TopRight/Child/BatteryTime/ButtonRule")
    end


    
    if TableManager.phzTableData.isPlayBack then
        self.btnInvite.gameObject.transform.localScale = Vector3.New(0, 0, 0)
        self.btnLeave.gameObject.transform.localScale = Vector3.New(0, 0, 0)
        self.ButtonActivity.gameObject.transform.localScale = Vector3.New(0, 0, 0)
        self.BtnLeftOpen.gameObject.transform.localScale = Vector3.New(0, 0, 0)
    else
        self.btnInvite.gameObject.transform.localScale = Vector3.New(1, 1, 1)
        self.btnLeave.gameObject.transform.localScale = Vector3.New(1, 1, 1)
    end

    -- 以下为金币场 逻辑
    self.LeftRoot = Manager.FindObject(self.root, "TopLeft/Child/NewUI/LeftRoot")

    if self.LeftRoot == nil then
        return
    end
    
    self.ButtonRule = Manager.GetButton(self.root, "TopRight/Child/BatteryTime/ButtonRule")
    

    self.btnStartZhunBeiText = Manager.GetText(self.root, "CenterBtn/btnStartZhunBei/Text")
    self.btnTuoGuan = Manager.GetButton(self.root, "btnTuoGuan")
    self.BtnLeftOpen = Manager.GetButton(self.root, "TopLeft/Child/NewUI/BtnLeftOpen")
    self.BtnLeftClose = Manager.GetButton(self.root, "TopLeft/Child/NewUI/LeftRoot/BtnLeftClose")

    
    self.JinBiChangMatch = Manager.FindObject(self.root, "TopLeft/Child/NewUI/LeftRoot/Bg/JinBiChangMatch")

    self.ButtonJinBiChangExit = Manager.GetButton(self.JinBiChangMatch, "ButtonJinBiChangExit")
    self.ButtonSettings = Manager.GetButton(self.JinBiChangMatch, "ButtonSettings")
    self.ButtonRuleExplain = Manager.GetButton(self.JinBiChangMatch, "ButtonRuleExplain")

    self.ButtonShop = Manager.GetButton(self.root, "TopLeft/Child/NewUI/ButtonShop")

    self.Public_WindowGoldHowToPlay = Manager.FindObject(self.root, "Public_WindowGoldHowToPlay")
    self.Public_WindowGoldHowToPlayT = Manager.FindObject(self.Public_WindowGoldHowToPlay, "Center/Child/Panels/Panel/Text")
    self.Public_WindowGoldHowToPlayText = self.Public_WindowGoldHowToPlayT.gameObject:GetComponent('Text')
    self.Public_WindowGoldHowToPlayClose = Manager.GetButton(self.root, "Public_WindowGoldHowToPlay/ButtonClose")
    

    local Config = require(string.format("package.public.config.%s.config_%s",AppData.App_Name,AppData.Game_Name))
    self.Public_WindowGoldHowToPlayText.text = Config.HowToPlayTexts[1]


    self.BtnLeftOpen.onClick:AddListener(
        function()
            self.LeftRoot.gameObject:SetActive(true)
        end
    )

    self.Public_WindowGoldHowToPlayClose.onClick:AddListener(
        function()
            self.Public_WindowGoldHowToPlay.gameObject:SetActive(false)
        end
    )


    self.BtnLeftClose.onClick:AddListener(
        function()
            self.LeftRoot.gameObject:SetActive(false)
        end
    )


    local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)
    if ruleInfo.baseScore then
        self.ButtonShop.gameObject.transform.localScale = Vector3.New(1, 1, 1)
    else
        self.ButtonShop.gameObject.transform.localScale = Vector3.New(0, 0, 0)
    end


    if TableManager.phzTableData.isPlayBack then
        self.btnInvite.gameObject.transform.localScale = Vector3.New(0, 0, 0)
        self.btnLeave.gameObject.transform.localScale = Vector3.New(0, 0, 0)
        self.BtnLeftOpen.gameObject.transform.localScale = Vector3.New(0, 0, 0)
        
    else
        self.btnInvite.gameObject.transform.localScale = Vector3.New(1, 1, 1)
        self.btnLeave.gameObject.transform.localScale = Vector3.New(1, 1, 1)
    end

    
end

return TableView