--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--
local Manager = require("manager.function_manager")
local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local GetComponent = ModuleCache.ComponentManager.GetComponent
local CSmartTimer = ModuleCache.SmartTimer.instance
local Time = UnityEngine.Time
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local GameSDKInterface = ModuleCache.GameSDKInterface
local class = require("lib.middleclass")
local ViewBase = require('package.changpai.module.tablebase.tablecpbase_view')
local TableUtil = require("package.changpai.module.table.table_util")

local curSelectPai = nil
local TableView = class('TableView', ViewBase)
local SoundManager = ModuleCache.SoundManager
local GPSManager = ModuleCache.GPSManager
local Color = UnityEngine.Color
local totalSeat = 3
local gameState = nil
local curTableData = nil
local selectCardXOffset = 45
local selectCardYOffset = 135
local moOffset = 0 --摸牌显示偏移 新layout时+20
local maxShouPaiNum = 23 --长牌最大手牌数量
local xiaZhangWidth = { 68, 65, 65, 65 } --下张宽度
local rightWidthOffsets = --手张宽度偏移
{
    ["20"] = { 82, 35, 38, 35 },
    ["14"] = { 87, 35, 38, 35 },
    ["23"] = { -118, 0, 0, 0 }, --长牌只有自己有手牌
}
local rightWidthOffset = nil
local myHightOffset = 90  ---自己手牌排列Y方向上的偏移值
local myHandRowCount = 7 ---自己手牌单行个数
local xiaZhangScaleAll = --下张麻将比例
{
    ["20"] = { 0.6, 0.86, 0.385, 0.86 },
    ["14"] = { 1, 1, 0.5, 1 },
    ["23"] = { 1, 1, 0.5, 1 },
}
local pointerPos = {
    Vector3.New(0, -38, 0),
    Vector3.New(38, 0, 0),
    Vector3.New(0, 38, 0),
    Vector3.New(-38, 0, 0),
}
local xiaZhangScale = nil
local lastMJOffset = 18 --最后一张牌位移
local outGridCell = --弃张摆放宫格位移
{
    { 66, -40 },
    { 56, 66 },
    { 0, 0 },
    { -56, -66 },
}
local myOutGridNum = 14 --弃张每行数量，此参数在长牌中只对玩家自己有用
local outGridNum = 5 --弃张每行数量，此参数在长牌中只对上下家有用
local allCardNum = 43
local huaPaiStartX = 127 ---2、4花牌拜访起始位置
local myQiZhangSpaceNum = 7---排到7后空myQiZhangOffset
local myQiZhangOffset = 256
local allCard = {}
local colorMj = {}
local seatAnchors = { "Bottom", "Right", "Top", "Left" }

--1:吃 2:碰 3:明杠 4:暗杠 5:点杠 6:和 7:听 8:出 9:自动出 10:摸 11:开杠 12:过牌 13：安庆宿松漂花 14：辣子先补花
local mCPGHLClipName = {
    ["1"] = "chi",
    ["2"] = "peng",
    ["3"] = "gang",
    ["4"] = "gang",
    ["5"] = "gang",
    ["6"] = "hu",
    ["7"] = "tianting",
    ["8"] = "hu",
}

local mPaiClipName = {
    "1t",
    "2t",
    "3t",
    "4t",
    "5t",
    "6t",
    "7t",
    "8t",
    "9t",
    "1w",
    "2w",
    "3w",
    "4w",
    "5w",
    "6w",
    "7w",
    "8w",
    "9w",
    "1b",
    "2b",
    "3b",
    "4b",
    "5b",
    "6b",
    "7b",
    "8b",
    "9b",
    "honghua",
    "baihua",
    "qianzi",
    "fu",
    "lu",
    "shou",
    "xi",
    "cai",
}


function TableView:initialize(...)
    gameState = nil
    curTableData = TableManager.curTableData
    ViewBase.initialize(self, "changpai/module/table/changpai_table.prefab", "ChangPai_Table", 0)
    ViewBase.set_1080p(self)

    local UIStateSwitcher = ModuleCache.ComponentManager.GetComponent(self.root, "UIStateSwitcher")
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        UIStateSwitcher:SwitchState("IosCheck")
    else
        UIStateSwitcher:SwitchState("Normal")
    end
    xiaZhangScale = xiaZhangScaleAll[maxShouPaiNum .. ""]
    rightWidthOffset = rightWidthOffsets[maxShouPaiNum .. ""]
    TableManager.seatNumTable = { 0, 1, 2, 3 }

    --self:initChuPaiPanel()--初始化出牌页面

    -- 用于叫牌、撂龙特效播放
    self.nmb = {}

    self.tableBackgroundSprite = GetComponentWithPath(self.root, "Center/ImageBackground", ComponentTypeName.Image).sprite
    self.tableBackgroundSprite2 = GetComponentWithPath(self.root, "Center/ImageBackground2", ComponentTypeName.Image).sprite
    self.tableBackgroundSprite3 = GetComponentWithPath(self.root, "Center/ImageBackground3", ComponentTypeName.Image).sprite

    self.widthText = GetComponentWithPath(self.root, "WidthText", ComponentTypeName.Text)
    self.topRightObj = GetComponentWithPath(self.root, "TopRight", ComponentTypeName.Transform).gameObject
    self.topLeftObj = GetComponentWithPath(self.root, "TopLeft", ComponentTypeName.Transform).gameObject
    self.bottomRightObj = GetComponentWithPath(self.root, "BottomRight", ComponentTypeName.Transform).gameObject
    self.buttonSetting = GetComponentWithPath(self.root, "LeftMenu/Grid/ButtonSettings", ComponentTypeName.Button)
    if TableManager.curTableData.isPlayBack then
        Manager.SetActive(self.buttonSetting, false)
    end
    self.buttonWarning = GetComponentWithPath(self.root, "LeftMenu/Grid/ButtonWarning", ComponentTypeName.Button)
    self.buttonJianFan = GetComponentWithPath(self.root, "LeftMenu/Grid/ButtonJianFan", ComponentTypeName.Button)
    self.jianObj = GetComponentWithPath(self.buttonJianFan.gameObject, "J", ComponentTypeName.Transform).gameObject
    self.fanObj = GetComponentWithPath(self.buttonJianFan.gameObject, "F", ComponentTypeName.Transform).gameObject
    --设置面板的切换显示layout
    self.buttonLayout = GetComponentWithPath(self.root, "LeftMenu/Grid/ButtonLayout", ComponentTypeName.Button)
    self.buttonFanzhuan = GetComponentWithPath(self.root, "LeftMenu/Grid/ButtonFanzhuan", ComponentTypeName.Button)
    local def = TableUtil.get_int_def_prefs()
    local fan = Manager.GetPlayerPrefsInt("NTCP_FAN", def) == 0--0繁 1简
    ComponentUtil.SafeSetActive(self.buttonFanzhuan.gameObject, fan or self.isNewLayout())

    ---倒计时 新加
    self.clockObj = GetComponentWithPath(self.root, "Center/Clock", ComponentTypeName.Transform).gameObject
    self.clockImageObj = GetComponentWithPath(self.root, "Center/Clock/Image", ComponentTypeName.Transform).gameObject
    self.clockTimeText = GetComponentWithPath(self.root, "Center/Clock/Time", ComponentTypeName.Text)

    self.buttonMic = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonMic", ComponentTypeName.Button)
    self.buttonChat = GetComponentWithPath(self.root, "BottomRight/Child/Action/ButtonChat", ComponentTypeName.Button)
    self.textRoomNum1 = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/RoomIDText", ComponentTypeName.Text)
    self.textWanFa = GetComponentWithPath(self.root, "TopLeft/Child/Begin/WanFa", ComponentTypeName.Text)
    self.textRoomNum2 = GetComponentWithPath(self.root, "TopRight/Child/BatteryTime/RoomIDText", ComponentTypeName.Text)
    self.textRoomRule = GetComponentWithPath(self.root, "Top/Child/RoomInfo/Text", ComponentTypeName.Text)
    self.gameController = GetComponentWithPath(self.root, "Center/Child/GameController", ComponentTypeName.Transform).gameObject
    self.ImageRandom = GetComponentWithPath(self.root, "Center/Child/ImageRandom", ComponentTypeName.Transform).gameObject
    self.inviteAndExit = GetComponentWithPath(self.root, "Center/Child/InviteAndExit", ComponentTypeName.Transform).gameObject
    self.buttonInvite = GetComponentWithPath(self.inviteAndExit, "ButtonInvite", ComponentTypeName.Transform).gameObject
    self.buttonExit = GetComponentWithPath(self.inviteAndExit, "ButtonExit", ComponentTypeName.Transform).gameObject
    self.buttonBegin = GetComponentWithPath(self.inviteAndExit, "ButtonBegin", ComponentTypeName.Transform).gameObject
    self.buttonBegin_countDownTex = GetComponentWithPath(self.inviteAndExit, "ButtonBegin/Count down/Text", ComponentTypeName.Text)
    self.selectZun = GetComponentWithPath(self.root, "Bottom/Child/SelectZun", ComponentTypeName.Transform).gameObject
    self.selectHua = GetComponentWithPath(self.root, "Bottom/Child/SelectHua", ComponentTypeName.Transform).gameObject
    self.waitAction = GetComponentWithPath(self.root, "Bottom/Child/WaitAction", ComponentTypeName.Transform).gameObject
    self.waitActions = TableUtil.get_all_child(self.waitAction)
    --self.waitActions[#self.waitActions + 1] = GetComponentWithPath(self.root, "Bottom/Child/Button_Guo", ComponentTypeName.Transform).gameObject
    self.sanKouObj = GetComponentWithPath(self.root, "Bottom/Child/SanKou", ComponentTypeName.Transform).gameObject
    self.openSanKouObj = GetComponentWithPath(self.root, "Bottom/Child/SanKou/Image1", ComponentTypeName.Transform).gameObject
    self.closeSanKouObj = GetComponentWithPath(self.root, "Bottom/Child/SanKou/Image2", ComponentTypeName.Transform).gameObject
    self.timeDown = GetComponentWithPath(self.gameController, "TimeDown", ComponentTypeName.Transform).gameObject
    self.waitObj = GetComponentWithPath(self.gameController, "Wait", ComponentTypeName.Transform).gameObject
    self.timer1imgSprite = GetComponentWithPath(self.timeDown, "Image1", "SpriteHolder")
    self.timer2imgSprite = GetComponentWithPath(self.timeDown, "Image2", "SpriteHolder")
    self.timer1img = GetComponentWithPath(self.timeDown, "Image1", ComponentTypeName.Image)
    self.timer2img = GetComponentWithPath(self.timeDown, "Image2", ComponentTypeName.Image)
    self.pointerObj = GetComponentWithPath(self.root, "Center/Child/Pointer", ComponentTypeName.Transform).gameObject
    self.lightObj = GetComponentWithPath(self.gameController, "Light", ComponentTypeName.Transform).gameObject
    self.jushuObj = GetComponentWithPath(self.root, "Top/Child/Info/JuShu", ComponentTypeName.Transform).gameObject
    self.jushu = GetComponentWithPath(self.root, "Top/Child/Info/JuShu/Text", ComponentTypeName.Text)
    self.remain = GetComponentWithPath(self.root, "Top/Child/Info/YuZhang/Text", ComponentTypeName.Text)
    self.remainAni = GetComponentWithPath(self.gameController, "Remain/Text", "UnityEngine.Animation")
    self.cloneParent = GetComponentWithPath(self.root, "Clone", ComponentTypeName.Transform).gameObject
    self.cloneSeat = GetComponentWithPath(self.cloneParent, "Seat", ComponentTypeName.Transform).gameObject


    self.selectCardPanel = GetComponentWithPath(self.root, "Bottom/Child/SelectCardPanel", ComponentTypeName.Transform).gameObject
    self.selectCardClone2 = GetComponentWithPath(self.selectCardPanel, "2_SelectCard", ComponentTypeName.Transform).gameObject
    self.selectCardClone3 = GetComponentWithPath(self.selectCardPanel, "3_SelectCard", ComponentTypeName.Transform).gameObject
    self.selectCardClone4 = GetComponentWithPath(self.selectCardPanel, "4_SelectCard", ComponentTypeName.Transform).gameObject
    self.selectCardClone2Pos = self.selectCardClone2.transform.localPosition
    self.selectCardClone3Pos = self.selectCardClone3.transform.localPosition
    self.selectCardClone4Pos = self.selectCardClone4.transform.localPosition
    self.tingGridParent = GetComponentWithPath(self.root, "Bottom/Child/TingGrid", ComponentTypeName.Transform).gameObject
    self.huGridParent = GetComponentWithPath(self.root, "Bottom/Child/HuGrid", ComponentTypeName.Transform).gameObject
    self.tingGrid = GetComponentWithPath(self.tingGridParent, "Normal/Grid", ComponentTypeName.Transform).gameObject
    self.tingJianZiHu = GetComponentWithPath(self.tingGridParent, "JianZiHu", ComponentTypeName.Transform).gameObject
    self.huGrid = GetComponentWithPath(self.huGridParent, "Grid", ComponentTypeName.Transform).gameObject
    self.huGridLayoutGroup = GetComponentWithPath(self.huGridParent, "Grid", ComponentTypeName.GridLayoutGroup)
    self.huGridRectTransform = GetComponentWithPath(self.huGridParent, "Grid", ComponentTypeName.RectTransform)

    self.jianZiHu = GetComponentWithPath(self.huGridParent, "JianZiHu", ComponentTypeName.Transform).gameObject
    self.readyTopLeft = GetComponentWithPath(self.root, "TopLeft/Child/Ready", ComponentTypeName.Transform).gameObject
    self.beginTopLeft = GetComponentWithPath(self.root, "TopLeft/Child/Begin", ComponentTypeName.Transform).gameObject

    self.MaiMaPanel = GetComponentWithPath(self.root, "MaiMa", ComponentTypeName.Transform).gameObject
    self.MaiMaCopyParent = GetComponentWithPath(self.root, "MaiMa/vector", ComponentTypeName.Transform).gameObject
    self.MaiMaCopyItem = GetComponentWithPath(self.root, "MaiMa/vector/MaiMaPai", ComponentTypeName.Transform).gameObject

    self.topInfoObj = GetComponentWithPath(self.root, "Top/Child/Info", ComponentTypeName.Transform).gameObject
    self.jiangPaiObj = GetComponentWithPath(self.topInfoObj, "JiangPai", ComponentTypeName.Transform).gameObject
    ---new add
    self.jiangPaiBgRect = GetComponentWithPath(self.topInfoObj, "Image", ComponentTypeName.RectTransform)
    self.jiangWordObj = GetComponentWithPath(self.jiangPaiObj, "Image", ComponentTypeName.Transform).gameObject
    self.yuZhangObj = GetComponentWithPath(self.topInfoObj, "YuZhang", ComponentTypeName.RectTransform).gameObject
    self.jushuObj = GetComponentWithPath(self.topInfoObj, "JuShu", ComponentTypeName.RectTransform).gameObject

    self.jiangPai = {}
    self.jiangPai[1] = GetComponentWithPath(self.jiangPaiObj, "Layout/1", ComponentTypeName.Transform).gameObject
    self.jiangPai[2] = GetComponentWithPath(self.jiangPaiObj, "Layout/2", ComponentTypeName.Transform).gameObject

    self.centerTipsObj = GetComponentWithPath(self.root, "CenterTips", ComponentTypeName.Transform).gameObject
    self.centerTipsText = GetComponentWithPath(self.centerTipsObj, "BG/Text", ComponentTypeName.Text)
    self.root_rect = Manager.GetRect(self.root)
    self.buttonBegin_image = GetComponentWithPath(self.buttonBegin, "Image", ComponentTypeName.Transform).gameObject
    self.buttonBegin_countDown = GetComponentWithPath(self.buttonBegin, "Count down", ComponentTypeName.Transform).gameObject
    self:readyBtn_showCountDown(false)

    self.chuPosObj = GetComponentWithPath(self.root, "Bottom/Child/ChuPos", ComponentTypeName.Transform).gameObject
    self.chuMJPosAnchorObj = GetComponentWithPath(self.root, "Center/Child/ChuMJPosAnchor", ComponentTypeName.Transform).gameObject
    self.leftMenuObj = GetComponentWithPath(self.root, "LeftMenu", ComponentTypeName.Transform).gameObject
    self.buttonLeftMenu = GetComponentWithPath(self.root, "TopLeft/Child/ButtonLeftMenu", ComponentTypeName.Transform).gameObject
    ---new add
    self.buttonChuPai = GetComponentWithPath(self.root, "TopLeft/Child/ButtonChuPai", ComponentTypeName.Transform).gameObject
    self.buttonActivity = GetComponentWithPath(self.root, "TopLeft/Child/ButtonActivity", ComponentTypeName.Transform).gameObject
    self.spriteActivityRedPoint =  GetComponentWithPath(self.buttonActivity, "spriteActivityRedPoint", ComponentTypeName.Transform).gameObject

    self.leftMenuEventMask = GetComponentWithPath(self.root, "LeftMenu/EventMask", ComponentTypeName.Transform).gameObject
    self.leftButtonBackText = GetComponentWithPath(self.root, "LeftMenu/Grid/ButtonBack/Text", ComponentTypeName.Text)


    self:check_play_back()
    self.colorChange = Color.New(255 / 255, 121 / 255, 0 / 255)
    TableUtil.move_clone(self.selectCardClone2, self.cloneParent)
    TableUtil.move_clone(self.selectCardClone3, self.cloneParent)
    TableUtil.move_clone(self.selectCardClone4, self.cloneParent)
    self.pointerObjs = TableUtil.get_all_child(self.pointerObj)
    self.lightChilds = TableUtil.get_all_child(self.lightObj)
    self.selectZunChilds = TableUtil.get_all_child(self.selectZun)
    self.seatHolderArray = {}
    self.pointerChilds = {}
    for i = 1, 4 do
        local seatHolder = {}
        local seatPosTran = GetComponentWithPath(self.root, seatAnchors[i] .. "/Child/" .. i, ComponentTypeName.Transform).gameObject
        self:init_seat(seatHolder, i, seatPosTran)
        self.seatHolderArray[i] = seatHolder
        TableUtil.move_clone(seatHolder.outCloneMJ, self.cloneParent)
        seatHolder.outCloneMJ.transform.localScale = Vector3.New(1, 1, 1)
        TableUtil.move_clone(seatHolder.huaCloneMJ, self.cloneParent)
        seatHolder.huaCloneMJ.transform.localScale = Vector3.New(1, 1, 1)
        local pointerChild = GetComponentWithPath(self.pointerObjs[i], "Light", ComponentTypeName.Transform).gameObject
        table.insert(self.pointerChilds, pointerChild)
    end
    curTableData.totalSeat = totalSeat
    curTableData.seatHolderArray = self.seatHolderArray
    self.clones = TableUtil.get_all_child(self.cloneParent)

    self:reset_mj(true)

    self.mySeat = curTableData.SeatID
    if (not curTableData.isPlayBack) then
        local mySeatData = {
            UserID = curTableData.modelData.roleData.userID,
            SeatID = self.mySeat
        }
        self:refresh_seat_info(mySeatData)
    end

    self.allShowCards = {}

    --- 初始化桌面
    self:refresh_table_bg()
    self:newViewLayout()

end

---初始化出牌页面
--function TableView:initChuPaiPanel()
--    self.chuPai_Panel = GetComponentWithPath(self.root, "ChuPaiPanel", ComponentTypeName.Transform).gameObject
--    self.chuPai_Panel:SetActive(false)
--    self.chuPai_closeBtn = GetComponentWithPath(self.chuPai_Panel, "BaseBackground/Chupai_Button_Close", ComponentTypeName.Button).gameObject
--    self.chuPai_infoArray = {}
--    for i = 1, 4 do
--        local info = {}
--        self.chuPai_infoArray[i] = info
--        info.iconImage = GetComponentWithPath(self.chuPai_Panel, "Center/" .. i .. "/User/Avatar/Mask/Image", ComponentTypeName.Image)
--        info.leaveStateObj = GetComponentWithPath(self.chuPai_Panel, "Center/" .. i .. "/User/Avatar/ImageStateLeave", ComponentTypeName.Transform).gameObject
--        info.leaveStateObj:SetActive(false)
--        info.disconnectStateObj = GetComponentWithPath(self.chuPai_Panel, "Center/" .. i .. "/User/Avatar/ImageStateDisconnect", ComponentTypeName.Transform).gameObject
--        info.disconnectStateObj:SetActive(false)
--        info.nameText = GetComponentWithPath(self.chuPai_Panel, "Center/" .. i .. "/User/TextName", ComponentTypeName.Text)
--        info.outPaiTrans = GetComponentWithPath(self.chuPai_Panel, "Center/" .. i .. "/OutPai", ComponentTypeName.Transform).gameObject
--    end
--end


--新老的界面显示切换对位置的设置
function TableView:newViewLayout()
    local myHandPs = Vector3.New(0, 0, 0)--自己手牌HandMJ显示位置
    local myHandSc = Vector3.New(1, 1, 1)
    local isNew = self:isNewLayout() -- 0:老界面 1:新界面
    local ov = self.seatHolderArray[2].outPoint.transform.localPosition
    local faguangV2 = Vector2.New(123, 288)
    local jiaopaiFaguangV2 = Vector2.New(126, 297)
    local jiaoPaiPtPs = Vector3.New(-812, -112, 0)
    local jiaoPaiPtRt = Vector3.New(0, 0, 0)
    local myHuaPt = Vector3.New(-916, -322, 0)
    local myHuaRt = Vector3.New(0, 0, 0)
    local myLeftPs = Vector3.New(-548, -194, 0)
    local myOutPs = Vector3.New(-425, 235, 0)
    if (isNew) then
        lastMJOffset = 4
        rightWidthOffsets[maxShouPaiNum .. ""][1] = -76
        myHandPs = Vector3.New(-94, 160, 0)--自己手牌HandMJ显示位置
        myHandSc = Vector3.New(1.02, 1.02, 1)
        moOffset = 23
        outGridNum = 6
        outGridCell[1][1] = 42
        outGridCell[2][2] = 42
        outGridCell[4][2] = -42
        faguangV2 = Vector2.New(92, 298)
        jiaopaiFaguangV2 = Vector2.New(93, 300)
        myOutGridNum = 14---自己已出牌排列
        myHuaPt = Vector3.New(822, 132, 0)
        myHuaRt = Vector3.New(0, 0, 90)
        jiaoPaiPtPs = Vector3.New(-750, 132, 0)
        jiaoPaiPtRt = Vector3.New(0, 0, 90)
        myLeftPs = Vector3.New(-648, -165, 0)
        xiaZhangWidth = { 54, 44, 44, 44 } --下张宽度
        myOutPs = Vector3.New(-400, 292, 0)
        myQiZhangSpaceNum = 7
        self.seatHolderArray[2].outPoint.transform.localPosition = Vector3.New(-205, 141, 0)
    else
        lastMJOffset = 18
        rightWidthOffsets[maxShouPaiNum .. ""][1] = -118
        moOffset = 0
        outGridNum = 5
        outGridCell[1][1] = 66
        outGridCell[2][2] = 66
        outGridCell[4][2] = -66
        myOutGridNum = 10
        xiaZhangWidth = { 65, 65, 65, 65 } --下张宽度
        myQiZhangSpaceNum = 5
        self.seatHolderArray[2].outPoint.transform.localPosition = Vector3.New(-205, 88, 0)
    end
    rightWidthOffset = rightWidthOffsets[maxShouPaiNum .. ""]
    self.seatHolderArray[1].rightPoint.transform.localPosition = myHandPs
    self.seatHolderArray[1].rightPoint.transform.localScale = myHandSc
    self.seatHolderArray[1].huaPoint.transform.localPosition = myHuaPt
    self.seatHolderArray[1].huaPoint.transform.localEulerAngles = myHuaRt
    self.seatHolderArray[1].jiaopai.transform.localPosition = jiaoPaiPtPs
    self.seatHolderArray[1].jiaopai.transform.localEulerAngles = jiaoPaiPtRt
    self.seatHolderArray[1].leftPoint.transform.localPosition = myLeftPs
    self.seatHolderArray[1].outPoint.transform.localPosition = myOutPs
    self:showHugridState(isNew)
    self:showJiangState(isNew)
    ---修改已生成的发光圈
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        if (seatHolder.chuMJPos.transform.childCount > 0) then
            local faguang = GetComponentWithPath(seatHolder.chuMJPos, "ChuMJ/Bg/Anim_CHangPaiXuanZhong/Animator/FaGuang", ComponentTypeName.RectTransform)
            faguang.sizeDelta = faguangV2
        end
    end
    ---修改clone预制发光圈
    local cloneChuMJ = GetComponentWithPath(self.cloneParent, "ChuMJ/Bg/Anim_CHangPaiXuanZhong/Animator/FaGuang", ComponentTypeName.RectTransform)
    cloneChuMJ.sizeDelta = faguangV2
    ---修改叫牌 撩龙弹窗的发光圈大小
    local jiaoPaiFG = GetComponentWithPath(self.root, "Bottom/Child/NanTongJiaoOrLiao/Anim_CHangPaiXuanZhong/Animator/FaGuang", ComponentTypeName.RectTransform)
    jiaoPaiFG.sizeDelta = jiaopaiFaguangV2
end

---修改出牌页面grid的cellsize
--function TableView:changeChuPaiGridsState(isNew)
--    local gridSize = Vector2.New(68, 100)
--    if (isNew) then
--        gridSize.x = 46
--    end
--    for i = 1, #self.chuPai_infoArray do
--        local info = self.chuPai_infoArray[i]
--        local grid = info.outPaiTrans.gameObject:GetComponent(ComponentTypeName.GridLayoutGroup)
--        grid.cellSize = gridSize
--    end
--end

---seatAnchors 到谁出牌显示倒计时
function TableView:showClockState(index)
    self.clockObj:SetActive(true)
    if (index == 1) then
        self.clockImageObj.transform.localEulerAngles = Vector3.New(0, 0, 0)
        self.clockImageObj.transform.localPosition = Vector3.New(0, 0, 0)
    elseif (index == 2) then
        self.clockImageObj.transform.localEulerAngles = Vector3.New(0, 0, 90)
        self.clockImageObj.transform.localPosition = Vector3.New(12, 12, 0)
    elseif (index == 4) then
        self.clockImageObj.transform.localEulerAngles = Vector3.New(0, 0, -90)
        self.clockImageObj.transform.localPosition = Vector3.New(-12, 12, 0)
    end
end

---胡牌grid显示修改
function TableView:showHugridState(isNew)
    local size = self.huGridRectTransform.sizeDelta
    if (isNew) then
        self.huGridParent.transform.localPosition = Vector3.New(833, -47, 0)
        self.huGridLayoutGroup.cellSize = Vector2.New(72, 59)
        size.y = 239
        self.huGridRectTransform.sizeDelta = size
    else
        self.huGridParent.transform.localPosition = Vector3.New(833, -47, 0)
        --self.huGridParent.transform.localPosition = Vector3.New(950, -146, 0)
        self.huGridLayoutGroup.cellSize = Vector2.New(81, 59)
        size.y = 192
        self.huGridRectTransform.sizeDelta = size
    end
end

function TableView:refresh_jiaoPaiPos(seatHolder,localSeat,huaCount)
    local y = 385
    local jiaoPos = seatHolder.jiaopai.transform.localPosition
    if(localSeat~=1) then
        if(huaCount>0) then
            jiaoPos.y = y - xiaZhangWidth[2]
        else
            jiaoPos.y = y
        end
    end
    seatHolder.jiaopai.transform.localPosition = jiaoPos
end

---叫牌位置相对花牌位移
function TableView:change_jiaopai_pos()
    self:refresh_jiaoPaiPos(self.seatHolderArray[2], 2, self.seatHolderArray[2].huaPoint.transform.childCount)
    self:refresh_jiaoPaiPos(self.seatHolderArray[4], 4, self.seatHolderArray[4].huaPoint.transform.childCount)
end

---修改将牌layout
function TableView:showJiangState(isNew)
    local size = self.jiangPaiBgRect.sizeDelta
    if (isNew) then
        self.jiangWordObj.transform.localPosition = Vector3.New(-56, -3, 0)
        self.yuZhangObj.transform.localPosition = Vector3.New(92, -23, 0)
        self.jushuObj.transform.localPosition = Vector3.New(92, 13, 0)
        size.x = 595
        self.jiangPaiBgRect.sizeDelta = size
    else
        self.jiangWordObj.transform.localPosition = Vector3.New(-20, -3, 0)
        self.yuZhangObj.transform.localPosition = Vector3.New(57, -23, 0)
        self.jushuObj.transform.localPosition = Vector3.New(57, 13, 0)
        size.x = 541
        self.jiangPaiBgRect.sizeDelta = size
    end
end

---打开关闭出牌页面
function TableView:showChuPaiPanel(isShow)
    self.chuPai_Panel:SetActive(isShow)
end

---设置活动按钮显示
function TableView:showActivityBtn(isShow)
    self.buttonActivity.gameObject:SetActive(isShow)
end


function TableView:getJIaoCount()
    local count = 0
    local childs = TableUtil.get_all_child(self.seatHolderArray[1].jiaopai)
    for i = 1, #childs do
        if (childs[i].gameObject.activeSelf) then
            count = count + 1
        end
    end
    return count
end

--是否是新界面显示
function TableView:isNewLayout()
    local def = TableUtil.get_int_def_prefs()
    local isNew = Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT", def) == 0 -- 0:新界面 0:老界面
    return isNew
end

--切换layout显示存值
function TableView:changeSaveLayout()
    local def = TableUtil.get_int_def_prefs()
    if (Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT", def) == 1) then
        Manager.SetPlayerPrefsInt("NTCP_NEW_LAYOUT", 0)
    else
        Manager.SetPlayerPrefsInt("NTCP_NEW_LAYOUT", 1)
    end
end

function TableView:readyBtn_showCountDown(showCountDown)
    self.buttonBegin_image:SetActive(not showCountDown)
    self.buttonBegin_countDown:SetActive(showCountDown)
end

function TableView:check_play_back()
    if (curTableData.isPlayBack) then
        self.gamerule = curTableData.videoData.gamerule
        self.wanfaName, self.ruleName = TableUtil.get_rule_name(curTableData.videoData.gamerule, curTableData.videoData.hallnum == 0)
        curTableData.HallID = curTableData.videoData.hallnum
    else
        ----TODO XLQ 亲友圈分享不显示支付方式
        if curTableData.RoomType == 2 then
            curTableData.Rule = ModuleCache.Json.decode(curTableData.Rule)

            curTableData.Rule.PayType = -1
            curTableData.Rule = ModuleCache.Json.encode(curTableData.Rule)
        end

        self.gamerule = curTableData.Rule

        self.wanfaName, self.ruleName = TableUtil.get_rule_name(curTableData.Rule, curTableData.HallID == 0)
    end
    curTableData.wanfaName = self.wanfaName
    self.ruleJsonInfo = TableUtil.convert_rule(self.gamerule)
    curTableData.ruleJsonInfo = self.ruleJsonInfo
    self.textRoomRule.text = string.format("%s %s", self.wanfaName, self.ruleName)
    ComponentUtil.SafeSetActive(self.topRightObj, not curTableData.isPlayBack)
    -- if not curTableData.isPlayBack then
    --     ComponentUtil.SafeSetActive(self.topLeftObj, true)
    --  --    回放显示房间id  临时注销
    -- --elseif curTableData.videoData.roomid or curTableData.videoData.hallnum then
    -- --     ComponentUtil.SafeSetActive(self.topLeftObj, true)
    -- else
    --      ComponentUtil.SafeSetActive(self.topLeftObj, false)
    -- end

    ComponentUtil.SafeSetActive(self.bottomRightObj, not curTableData.isPlayBack)
    ComponentUtil.SafeSetActive(self.jushuObj, not curTableData.isPlayBack)
    ComponentUtil.SafeSetActive(self.inviteAndExit, not curTableData.isPlayBack)
    --ComponentUtil.SafeSetActive(self.ImageRandom, not curTableData.isPlayBack)
    if (not curTableData.isPlayBack) then
        if (curTableData.HallID > 0) then
            self.textRoomNum1.text = AppData.MuseumName .. "房号:" .. curTableData.RoomID
        else
            self.textRoomNum1.text = "房号:" .. curTableData.RoomID
        end

        self.textWanFa.text = self.wanfaName
        self.textRoomNum2.text = self.textRoomNum1.text --.. " " .. self.wanfaName
    else
        self.textWanFa.text = self.wanfaName
        if curTableData.videoData.roomid or curTableData.videoData.hallnum then
            if (curTableData.videoData.hallnum and curTableData.videoData.hallnum > 0) then
                self.textRoomNum1.text = AppData.MuseumName .. "房号:" .. curTableData.videoData.roomid
            else
                self.textRoomNum1.text = "房号:" .. curTableData.videoData.roomid
            end
        end
    end
end
-- 隐藏碰杠列表以及吃法列表
function TableView:hide_wait_action_select_card()
    self.showWaitAction = false
    ComponentUtil.SafeSetActive(self.waitAction, false)
    ComponentUtil.SafeSetActive(self.sanKouObj, false)
    ComponentUtil.SafeSetActive(self.waitActions[#self.waitActions], false)
    self:hide_select_card_childs()
end
-- 显示吃法列表
function TableView:show_chigrid()

    for i = 1, #gameState.KeChi do
        local xAddOffset = 0
        for j = 1, #gameState.KeChi[i].ChiFa do
            local target = TableUtil.poor("3_SelectCard", self.selectCardPanel,
            self.selectCardClone3Pos + Vector3.New(xAddOffset, (i - 1) * selectCardYOffset, 0), self.poorObjs, self.clones)
            local childs = TableUtil.get_all_child(target)
            local curPai = gameState.KeChi[i].Pai
            local index = #gameState.KeChi[i].ChiFa - j + 1
            for k = 1, #childs do
                local mj = childs[k]
                local pai = gameState.KeChi[i].ChiFa[index] + (k - 1)
                if (pai == curPai) then
                    TableUtil.set_changpai_color(mj, Color.yellow)
                else
                    TableUtil.set_changpai_color(mj, Color.white)
                end
                TableUtil.new_set_changpai(pai, mj)
            end
            target.name = "Chi" .. "_3_" .. gameState.KeChi[i].ChiFa[index] .. "_" .. gameState.KeChi[i].Pai
            xAddOffset = xAddOffset - selectCardXOffset * 3 - 10
        end
    end
    ComponentUtil.SafeSetActive(self.selectCardPanel, true)
end

--function TableView:set_mj_color(mj, color)
--    local childs = TableUtil.get_all_child(mj)
--    for i = 1, #childs do
--        local image = ModuleCache.ComponentManager.GetComponent(childs[i], ComponentTypeName.Image)
--        if (image) then
--            image.color = color
--        end
--    end
--end

-- 显示碰法列表
function TableView:show_penggrid()

    local xAddOffset = 0
    for i = 1, #gameState.KePeng do
        local target = TableUtil.poor("3_SelectCard", self.selectCardPanel, self.selectCardClone3Pos + Vector3.New(xAddOffset, 0, 0), self.poorObjs, self.clones)
        local childs = TableUtil.get_all_child(target)
        local index = #gameState.KePeng - i + 1
        for k = 1, #childs do
            local mj = childs[k]
            local pai = gameState.KePeng[index]
            TableUtil.set_changpai_color(mj, Color.white)
            TableUtil.new_set_changpai(pai, mj)
        end
        target.name = "Peng" .. "_3_" .. gameState.KePeng[index]
        xAddOffset = xAddOffset - selectCardXOffset * 3 - 10
    end
    ComponentUtil.SafeSetActive(self.selectCardPanel, true)
end

-- 显示杠法列表
function TableView:show_ganggrid()

    local xAddOffset = 0
    for i = 1, #gameState.KeGang do
        local target = TableUtil.poor("4_SelectCard", self.selectCardPanel, self.selectCardClone4Pos + Vector3.New(xAddOffset, 0, 0), self.poorObjs, self.clones)
        local childs = TableUtil.get_all_child(target)
        local index = #gameState.KeGang - i + 1
        for k = 1, #childs do
            local mj = childs[k]
            local pai = gameState.KeGang[index]
            TableUtil.set_changpai_color(mj, Color.white)
            TableUtil.new_set_changpai(pai, mj)
        end
        target.name = "Gang" .. "_4_" .. gameState.KeGang[index]
        xAddOffset = xAddOffset - selectCardXOffset * 4 - 10
    end
    ComponentUtil.SafeSetActive(self.selectCardPanel, true)
end

-- 显示钓对列表
function TableView:show_diaogrid()

    local xAddOffset = 0
    for i = 1, #gameState.KeDiaoDui do
        local target = TableUtil.poor("2_SelectCard", self.selectCardPanel, self.selectCardClone2Pos + Vector3.New(xAddOffset, 0, 0), self.poorObjs, self.clones)
        local childs = TableUtil.get_all_child(target)
        local index = #gameState.KeDiaoDui - i + 1
        for k = 1, #childs do
            local mj = childs[k]
            local pai = gameState.KeDiaoDui[index]
            TableUtil.set_changpai_color(mj, Color.white)
            TableUtil.new_set_changpai(pai, mj)
        end
        target.name = "Diao" .. "_2_" .. gameState.KeDiaoDui[index]
        xAddOffset = xAddOffset - selectCardXOffset * 2 - 10
    end
    ComponentUtil.SafeSetActive(self.selectCardPanel, true)
end

function TableView:hide_select_hua()
    ComponentUtil.SafeSetActive(self.selectHua, false)
end

-- 牌局还原到初始状态
function TableView:reset_mj(refreshState)
    --gameState = nil
    self.showStrategy = false
    self.isMeMoPai = false
    self.timerSum = -1
    self.timer = 0
    self.haveTing = false
    self.curSelectPai = nil
    curTableData.dismiss = false
    self.colorPai = nil
    self.refreshState = refreshState

    colorMj = {}
    ComponentUtil.SafeSetActive(self.selectZun, false)
    ComponentUtil.SafeSetActive(self.selectHua, false)
    ComponentUtil.SafeSetActive(self.clockObj, false)
    for i = 1, #self.seatHolderArray do
        self:reset_seat(i)
    end
    self:reset_seat_all_mj()
end

-- 隐藏选牌
function TableView:hide_select_card_childs()
    local childs = TableUtil.get_all_child(self.selectCardPanel)
    for i = 1, #childs do
        if (childs[i].name ~= "BtnNoSelectCard") then
            local array = string.split(childs[i].name, "_")
            if (array[2] == "3") then
                childs[i].name = "3_SelectCard"
            elseif (array[2] == "4") then
                childs[i].name = "4_SelectCard"
            elseif (array[2] == "2") then
                childs[i].name = "2_SelectCard"
            end
            self.poorObjs = TableUtil.add_poor(childs[i], self.poorObjs, self.cloneParent)
        end
    end
    ComponentUtil.SafeSetActive(self.selectCardPanel, false)
end

-- 初始化座位信息
function TableView:init_seat(seatHolder, seatIndex, seatPosTran)
    local seatParent = GetComponentWithPath(seatPosTran, "Holder", ComponentTypeName.Transform).gameObject
    TableUtil.clone(self.cloneSeat, seatParent, Vector3.zero)
    local root = GetComponentWithPath(seatPosTran, "Holder/Seat", ComponentTypeName.Transform).gameObject
    local rootSwitcher = GetComponentWithPath(seatPosTran, "Holder/Seat", "UIStateSwitcher")
    if seatIndex == 1 or seatIndex == 4 then
        rootSwitcher:SwitchState("Left")
    elseif seatIndex == 2 then
        rootSwitcher:SwitchState("Right")
    elseif seatIndex == 3 then
        rootSwitcher:SwitchState("Top")
    end

    local seatNumObj14 = GetComponentWithPath(seatPosTran, "14", ComponentTypeName.Transform).gameObject
    local seatNumObj20 = GetComponentWithPath(seatPosTran, "20", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(seatNumObj14, maxShouPaiNum == 14)
    ComponentUtil.SafeSetActive(seatNumObj20, maxShouPaiNum == 20)
    seatHolder.centerRandom = GetComponentWithPath(self.root, "Center/Child/ImageRandom/" .. seatIndex, ComponentTypeName.Transform).gameObject
    seatHolder.tingObj = GetComponentWithPath(self.root, "Center/Child/Ting/" .. seatIndex, ComponentTypeName.Transform).gameObject

    seatHolder.seatRoot = root
    seatHolder.seatParent = seatParent
    seatHolder.readySeatHolder = GetComponentWithPath(seatHolder.centerRandom, "Holder", ComponentTypeName.Transform)
    seatHolder.buttonNotSeatDown = GetComponentWithPath(root, "NotSeatDown", ComponentTypeName.Transform).gameObject
    seatHolder.goSeatInfo = GetComponentWithPath(root, "Info", ComponentTypeName.Transform).gameObject
    seatHolder.buttonKick = GetComponentWithPath(root, "Info/ButtonKick", ComponentTypeName.Transform).gameObject--踢人
    seatHolder.imagePlayerHead = GetComponentWithPath(root, "Info/Avatar/Mask/Image", ComponentTypeName.Image)
    seatHolder.textPlayerName = GetComponentWithPath(root, "Info/TextName", ComponentTypeName.Text)
    seatHolder.textScore = GetComponentWithPath(root, "Info/Point/Text", ComponentTypeName.Text)
    seatHolder.imageDisconnect = GetComponentWithPath(root, "Info/Avatar/ImageStateDisconnect", ComponentTypeName.Image).gameObject
    seatHolder.imageLeave = GetComponentWithPath(root, "Info/Avatar/ImageStateLeave", ComponentTypeName.Image).gameObject

    seatHolder.imageReady = GetComponentWithPath(root, "State/Group/ImageReady", ComponentTypeName.Transform).gameObject
    if(seatIndex==2) then
        seatHolder.imageReady.transform.localPosition = Vector3.New(-81,28,0)
    else
        seatHolder.imageReady.transform.localPosition = Vector3.New(81,28,0)
    end
    seatHolder.imageSanKou = GetComponentWithPath(root, "Info/ImageSanKou", ComponentTypeName.Transform).gameObject
    seatHolder.paiMJ = GetComponentWithPath(seatHolder.centerRandom, "PaiMJ", ComponentTypeName.Image).gameObject
    seatHolder.piaoZun = GetComponentWithPath(root, "Info/PiaoZun", ComponentTypeName.Transform).gameObject
    seatHolder.piaoZun:SetActive(false)
    seatHolder.piaoSprite = GetComponentWithPath(root, "Info/PiaoZun/PiaoBg/Image", ComponentTypeName.Image)
    seatHolder.zunSprite = GetComponentWithPath(root, "Info/PiaoZun/ZunBg/Image", ComponentTypeName.Image)
    seatHolder.piaoSH = GetComponentWithPath(root, "Info/PiaoZun/PiaoBg/Image", "SpriteHolder")
    seatHolder.ZunSH = GetComponentWithPath(root, "Info/PiaoZun/ZunBg/Image", "SpriteHolder")
    seatHolder.showAdd1 = GetComponentWithPath(root, "Info/ShowAdd/1", ComponentTypeName.Transform).gameObject
    seatHolder.showAdd2 = GetComponentWithPath(root, "Info/ShowAdd/2", ComponentTypeName.Transform).gameObject
    seatHolder.showAdd1Text = GetComponentWithPath(root, "Info/ShowAdd/1/Text", ComponentTypeName.Text)
    seatHolder.showAdd2Text = GetComponentWithPath(root, "Info/ShowAdd/2/Text", ComponentTypeName.Text)
    seatHolder.imageBanker = GetComponentWithPath(root, "Info/ImageBanker", ComponentTypeName.Image).gameObject
    seatHolder.remainBankerText = GetComponentWithPath(seatHolder.imageBanker, "Text", "TextWrap")
    seatHolder.piao = GetComponentWithPath(root, "Info/Piao", ComponentTypeName.Transform).gameObject
    seatHolder.textPiao = GetComponentWithPath(root, "Info/Piao/Image/Text", ComponentTypeName.Text)
    seatHolder.di = GetComponentWithPath(root, "Info/DiAndTuo/ImageDi", ComponentTypeName.Image).gameObject
    seatHolder.tuo = GetComponentWithPath(root, "Info/DiAndTuo/ImageTuo", ComponentTypeName.Image).gameObject
    seatHolder.huaAnimation = GetComponentWithPath(seatPosTran, "HuaTXPos", ComponentTypeName.Transform).gameObject
    seatHolder.goSpeak = GetComponentWithPath(root, "State/Group/Speak", ComponentTypeName.Transform).gameObject
    seatHolder.waiZun = GetComponentWithPath(root, "Info/TextWaitZun", ComponentTypeName.Transform).gameObject
    seatHolder.beginUI = GetComponentWithPath(root, "Begin", ComponentTypeName.Transform).gameObject

    --手牌父节点
    seatHolder.rightPoint = GetComponentWithPath(seatPosTran, maxShouPaiNum .. "/RightPoint/HandMJ", ComponentTypeName.Transform).gameObject
    seatHolder.leftPoint = GetComponentWithPath(seatPosTran, maxShouPaiNum .. "/LeftPoint", ComponentTypeName.Transform).gameObject
    --花牌父节点
    seatHolder.huaPoint = GetComponentWithPath(seatHolder.centerRandom, "HuaPoint", ComponentTypeName.Transform).gameObject
    --已出牌父节点
    seatHolder.outPoint = GetComponentWithPath(seatHolder.centerRandom, "OutPoint", ComponentTypeName.Transform).gameObject
    --seatHolder.outPoint = self.chuPai_infoArray[seatIndex].outPaiTrans
    seatHolder.chuMJPos = GetComponentWithPath(seatPosTran, "ChuMJPos", ComponentTypeName.Transform).gameObject
    seatHolder.chuMJPos.transform.position = self.chuMJPosAnchorObj.transform.position
    seatHolder.randomMJPos = GetComponentWithPath(seatHolder.centerRandom, "RandomPos", ComponentTypeName.Transform).gameObject
    seatHolder.chuTXPos = GetComponentWithPath(seatPosTran, "ChuTXPos", ComponentTypeName.Transform).gameObject

    local switch = Manager.GetComponent(seatPosTran, "UIStateSwitcher", maxShouPaiNum .. "")
    seatHolder.handPoint = Manager.FindObject(seatPosTran, maxShouPaiNum .. "/HandPoint")

    seatHolder.huaCloneMJ = GetComponentWithPath(seatHolder.huaPoint, seatIndex .. "_HuaMJ", ComponentTypeName.Transform).gameObject
    seatHolder.huaMjBeginPos = seatHolder.huaCloneMJ.transform.localPosition
    seatHolder.outCloneMJ = GetComponentWithPath(seatHolder.outPoint, seatIndex .. "_OutMJ", ComponentTypeName.Transform).gameObject
    --seatHolder.outCloneMJ = GetComponentWithPath(self.root, "Clone/OutPai_All", ComponentTypeName.Transform).gameObject

    seatHolder.outMjBeginPos = seatHolder.outCloneMJ.transform.localPosition
    seatHolder.inCloneMJ = GetComponentWithPath(seatHolder.rightPoint, seatIndex .. "_InMJ", ComponentTypeName.Transform).gameObject

    seatHolder.inMjBeginPos = seatHolder.inCloneMJ.transform.localPosition
    seatHolder.maiZhuang = GetComponentWithPath(root, "Info/MaiZhuang", ComponentTypeName.Transform).gameObject
    seatHolder.highLight = GetComponentWithPath(root, "Info/Avatar/HighLight", ComponentTypeName.Transform).gameObject
    ------------------------ 南通长牌 start ------------------------
    seatHolder.jiaopai = GetComponentWithPath(seatHolder.centerRandom, "JiaoPaiPoint", ComponentTypeName.Transform)
    seatHolder.huShuText = GetComponentWithPath(root, "Info/HuShu", ComponentTypeName.Text)
    ------------------------ 南通长牌 end ------------------------

    if curTableData.isPlayBack then
        if switch then
            switch:SwitchState("ChangPai")
        end
        Manager.SetActive(seatHolder.outPoint, false)
        local offset = nil
        if 2 == seatIndex then
            offset = Vector3.New(-400, 0, 0)
        elseif 4 == seatIndex then
            offset = Vector3.New(400, 0, 0)
        end
        if offset then
            seatHolder.huaPoint.transform.localPosition = seatHolder.huaPoint.transform.localPosition + offset
            seatHolder.leftPoint.transform.localPosition = seatHolder.leftPoint.transform.localPosition + offset
            seatHolder.jiaopai.transform.localPosition = seatHolder.jiaopai.transform.localPosition + offset
        end
    end

    for i = 1, maxShouPaiNum - 1 do
        TableUtil.clone(seatHolder.inCloneMJ, seatHolder.rightPoint, Vector3.zero)
    end
    seatHolder.enable = not (totalSeat == 3 and seatIndex == 3)
    ComponentUtil.SafeSetActive(seatHolder.centerRandom, seatHolder.enable)
    ComponentUtil.SafeSetActive(seatPosTran, seatHolder.enable)
end

-- 座位重置
function TableView:reset_seat(index)
    local seatHolder = self.seatHolderArray[index]
    seatHolder.ready = false
    ComponentUtil.SafeSetActive(seatHolder.imageReady, false)
    ComponentUtil.SafeSetActive(seatHolder.buttonKick, false)
    ComponentUtil.SafeSetActive(seatHolder.imageBanker, false)
    --ComponentUtil.SafeSetActive(seatHolder.imageCreator, false)
    --ComponentUtil.SafeSetActive(seatHolder.imageLeave, false)
    --ComponentUtil.SafeSetActive(seatHolder.imageDisconnect, false)
    --ComponentUtil.SafeSetActive(seatHolder.piao, false)
    ComponentUtil.SafeSetActive(seatHolder.di, false)
    ComponentUtil.SafeSetActive(seatHolder.tuo, false)
    --ComponentUtil.SafeSetActive(seatHolder.paiMJ, gameState == nil)
    --ComponentUtil.SafeSetActive(seatHolder.piaoSprite.transform.parent.gameObject, false)
    --ComponentUtil.SafeSetActive(seatHolder.zunSprite.transform.parent.gameObject, false)
    seatHolder.remainBankerText.text = ""
    ComponentUtil.SafeSetActive(seatHolder.maiZhuang, false)
    ComponentUtil.SafeSetActive(seatHolder.highLight, false)
    --ComponentUtil.SafeSetActive(seatHolder.clockObj, false)
end

--小结算点击继续游戏调用
function TableView:reset_seat_mj(index)
    local seatHolder = self.seatHolderArray[index]
    local leftChilds = TableUtil.get_all_child(seatHolder.leftPoint)
    local outChilds = TableUtil.get_all_child(seatHolder.outPoint)
    local huaChilds = TableUtil.get_all_child(seatHolder.huaPoint)
    for i = 1, #leftChilds do
        TableUtil.set_changpai_color(leftChilds[i], Color.white)
        self.poorObjs = TableUtil.add_poor(leftChilds[i], self.poorObjs, self.cloneParent)
    end
    for i = 1, #outChilds do
        --local movePointer = GetComponentWithPath(outChilds[i], "MovePointer", ComponentTypeName.Transform).gameObject
        --ComponentUtil.SafeSetActive(movePointer, false)
        TableUtil.set_changpai_color(outChilds[i], Color.white)
        self.poorObjs = TableUtil.add_poor(outChilds[i], self.poorObjs, self.cloneParent)
    end
    for i = 1, #huaChilds do
        TableUtil.set_changpai_color(huaChilds[i], Color.white)
        self.poorObjs = TableUtil.add_poor(huaChilds[i], self.poorObjs, self.cloneParent)
    end
    ------------------------ 南通长牌 start ------------------------
    local jiaopaiChildren = TableUtil.get_all_child(seatHolder.jiaopai)
    for i = 1, #jiaopaiChildren do
        TableUtil.set_changpai_color(jiaopaiChildren[i], Color.white)
        self.poorObjs = TableUtil.add_poor(jiaopaiChildren[i], self.poorObjs, self.cloneParent)
    end
    seatHolder.huShuText.text = ""  ---小结算继续游戏后，清空胡数显示
    ------------------------ 南通长牌 end ------------------------
    --seatHolder.leftPoint.transform.localPosition = seatHolder.leftBeginPos
    --seatHolder.rightPoint.transform.localPosition = seatHolder.rightBeginPos
    ComponentUtil.SafeSetActive(seatHolder.rightPoint, false)
    ComponentUtil.SafeSetActive(seatHolder.leftPoint, false)
    ComponentUtil.SafeSetActive(seatHolder.outPoint, false)
    ComponentUtil.SafeSetActive(seatHolder.huaPoint, false)

    ComponentUtil.SafeSetActive(seatHolder.tingObj, false)
    ComponentUtil.SafeSetActive(seatHolder.imageSanKou, false)
    ComponentUtil.SafeSetActive(seatHolder.maiZhuang, false)
    ComponentUtil.SafeSetActive(seatHolder.highLight, false)
    --ComponentUtil.SafeSetActive(seatHolder.clockObj, false)
    self:show_current_mj(false, nil, nil)
end

function TableView:reset_seat_all_mj()
    ComponentUtil.SafeSetActive(self.gameController, false)
    for i = 1, #self.seatHolderArray do
        self:reset_seat_mj(i)
    end
    for i = 1, #self.lightChilds do
        ComponentUtil.SafeSetActive(self.lightChilds[i], false)
    end
    for i = 1, #self.pointerChilds do
        ComponentUtil.SafeSetActive(self.pointerChilds[i], false)
    end

    --Manager.SetActive(self.jushuObj, false)
    Manager.SetActive(self.remain.gameObject, false)
    Manager.SetActive(self.jiangPaiObj, false)

    ComponentUtil.SafeSetActive(self.tingGridParent, false)
    ComponentUtil.SafeSetActive(self.huGridParent, false)
    --ComponentUtil.SafeSetActive(self.baoPai, false)
    self:hide_select_card_childs()
    self:hide_all_move_pointer()
end

-- 隐藏所有指示指标
function TableView:hide_all_move_pointer()
    --for i = 1, #self.seatHolderArray do
    --    local seatHolder = self.seatHolderArray[i]
    --    local outChilds = TableUtil.get_all_child(seatHolder.outPoint)
    --    for j = 1, #outChilds do
    --        local movePointer = GetComponentWithPath(outChilds[j], "MovePointer", ComponentTypeName.Transform).gameObject
    --        ComponentUtil.SafeSetActive(movePointer, false)
    --    end
    --end
end

-- 实时刷新游戏状态
function TableView:refresh_game_state(data)
    if not self.changpai_game_state then
        self.changpai_game_state = {}
    end
    table.insert(self.changpai_game_state, data)
    if self.changpai_interval or self.do_animation then
        -- 当前处于刷新间隔中，或者在播放动画
        return
    end

    local abc = table.remove(self.changpai_game_state, 1)
    self:refresh_changpai(abc)
end

function TableView:get_refresh_changpai_data()
    Manager.GetSmartTimer(0.2, false, 0, 0, nil, function()
        self.changpai_interval = false
        if self.changpai_interval or self.do_animation then
            -- 当前处于刷新间隔中，或者在播放动画
            return
        end
        if not Manager.IsTableEmpty(self.changpai_game_state) then
            self.changpai_interval = false
        else
            local data = table.remove(self.changpai_game_state, 1)
            self:refresh_changpai(data)
        end
    end)
end
---刷新 初始化叫牌
function TableView:refresh_changpai(data)
    self:get_refresh_changpai_data()

    self.changpai_interval = true
    -- 回放时，如果中间有出的牌，再重播，不会被清除，所以加这个
    if curTableData.isPlayBack then
        self:show_current_mj()
    end

    self.isChuMJ = false
    gameState = data
    if curTableData.RoomType == 3 then
        self.timerSum = data.IntrustRestTime
        self:show_time()
    end

    curTableData.gameState = gameState
    curTableData.totalSeat = totalSeat
    if (self.diceShow or self.randomSeat or not self.refreshState or gameState.Result == 2) then
        return
    end
    ComponentUtil.SafeSetActive(self.buttonWarning.gameObject, false)
    ComponentUtil.SafeSetActive(self.inviteAndExit, false)
    ComponentUtil.SafeSetActive(self.selectZun, false)
    ComponentUtil.SafeSetActive(self.gameController, true)
    self:refresh_wait_action()
    self:refresh_timedown_clock()
    if (not curTableData.isPlayBack) then
        if (curTableData.RoomType == 3) then
            self.jushu.text = "第" .. gameState.CurRound .. "局"
        else
            self.jushu.text = "第" .. gameState.CurRound .. "/" .. curTableData.RoundCount .. "局"
        end
    end
    local remainNum = #gameState.Dun
    if (self.wanfaName == "望江正宗") then
        remainNum = remainNum - 14
    end
    if (not self.remainNum) then
        self.remainNum = remainNum
        self.remain.text = "剩余" .. #gameState.Dun .. "张"
    end
    if (self.remainNum ~= remainNum) then
        if (remainNum < 10) then
            if (self.remainAni.isPlaying) then
                self.remainAni:Stop()
                self.remain.color = Color.New(self.remain.color.r, self.remain.color.g, self.remain.color.b, 1)
                self.remain.transform.localScale = Vector3.New(1, 1, 1)
            end
            self.remainAni:Play()
            self:subscibe_time_event(0.49, false, 0):OnComplete(function(t)
                self.remainAni:Stop()
                self.remain.text = "剩余" .. #gameState.Dun .. "张"
                self.remain.color = Color.New(self.remain.color.r, self.remain.color.g, self.remain.color.b, 1)
                self.remain.transform.localScale = Vector3.New(1, 1, 1)
            end)
        else
            if (self.remainAni.isPlaying) then
                self.remainAni:Stop()
                self.remain.color = Color.New(self.remain.color.r, self.remain.color.g, self.remain.color.b, 1)
                self.remain.transform.localScale = Vector3.New(1, 1, 1)
            end
            self.remain.text = "剩余" .. #gameState.Dun .. "张"
        end
        self.remainNum = remainNum
    end

    ------------------------ 南通长牌 start ------------------------
    -- 刷新将牌
    Manager.SetActive(self.buttonJianFan.gameObject, true)
    --Manager.SetActive(self.buttonFanZhuan.gameObject, true)
    Manager.SetActive(self.jushuObj, true)
    Manager.SetActive(self.jiangPaiObj, true)
    Manager.SetActive(self.remain.gameObject, true)
    self:update_back_button_state()
    for i, v in ipairs(self.jiangPai) do
        if gameState.JiangPai and gameState.JiangPai[i] and 0 ~= gameState.JiangPai[i] then
            Manager.SetActive(v, true)
            TableUtil.new_set_changpai(gameState.JiangPai[i], v)
        else
            Manager.SetActive(v, false)
        end
    end

    -- 刷新所有玩家已叫牌/撂龙
    local liaoLonging = false  ---是否正在撂龙中
    local liaolongMySelf = false ---是否是自己撂龙
    for i, v in ipairs(gameState.Player) do
        -- 玩家位置
        local PlayerSeat = TableUtil.get_local_seat(i - 1, self.mySeat, totalSeat)
        -- 玩家视图
        local PlayerPanel = self.seatHolderArray[PlayerSeat]

        if v.KeJiaoPai and 0 < #v.KeJiaoPai then
            if PlayerSeat == 1 then
                ---如果是玩家自己，则处理撂龙界面状态
                local panel = self:get_jiaopai_liaolong_panel()
                TableUtil.new_set_changpai(v.KeJiaoPai[1], panel.root)
                ComponentUtil.SafeSetActive(panel.root, true)
                liaolongMySelf = true
            else
                liaoLonging = true
            end
        else
            if PlayerSeat == 1 then
                local panel = self:get_jiaopai_liaolong_panel()
                ComponentUtil.SafeSetActive(panel.root, false)
            end
        end
        --
        local children = TableUtil.get_all_child(PlayerPanel.jiaopai)
        if not self.nmb[i] then
            self.nmb[i] = {}
        end
        if not self.nmb[i].jiaopai then
            self.nmb[i].jiaopai = 0
        end
        if not self.nmb[i].liaolong then
            self.nmb[i].liaolong = 0
        end
        if v.LiaoLong and v.JiaoPai and #children ~= #v.LiaoLong + #v.JiaoPai then
            -- 先清除之前的叫牌/撂龙
            for index = 1, #children do
                Manager.DestroyObject(children[index])
            end
            local cloneJiaoPai = GetComponentWithPath(self.cloneParent, PlayerSeat .. "_JiaoPai", ComponentTypeName.Transform).gameObject
            local count = 0
            local angles = 0
            local py = -116
            if (self:isNewLayout()) then
                angles = -90
                py = -84
            end
            local startY = -30
            local offset = -20

            -- 全盘刷新撂龙
            for _, v2 in ipairs(v.LiaoLong) do
                local view = TableUtil.clone(cloneJiaoPai, PlayerPanel.jiaopai.gameObject, Vector3.zero)
                if 1 == PlayerSeat then
                    if (self:isNewLayout()) then
                        view.transform.localPosition = Vector3.New(0, -260 * count, 0)
                    else
                        view.transform.localPosition = Vector3.New(xiaZhangWidth[1] * count, 0, 0)
                    end
                elseif 2 == PlayerSeat then
                    view.transform.localPosition = Vector3.New(0, -xiaZhangWidth[2] * count, 0)
                elseif 4 == PlayerSeat then
                    view.transform.localPosition = Vector3.New(0, -xiaZhangWidth[4] * count, 0)
                end
                count = count + 1
                for k = 0, 3 do
                    local index = 4 == PlayerSeat and k or k
                    local imageObj = GetComponentWithPath(view, "Pai/" .. index, ComponentTypeName.Transform).gameObject
                    if k <= #v2.Pai - 1 then
                        TableUtil.new_set_changpai(v2.Pai[1], imageObj, true)
                        ComponentUtil.SafeSetActive(imageObj, true)
                    else
                        ComponentUtil.SafeSetActive(imageObj, false)
                    end
                    if (self:isNewLayout() and 1 == PlayerSeat ) then
                        local jiaopai = GetComponentWithPath(view, "Pai/" .. k, ComponentTypeName.Transform).gameObject
                        local jianImage = GetComponentWithPath(view, "Image", ComponentTypeName.Transform).gameObject
                        jiaopai.transform.localPosition = Vector3.New(0, startY + (k * offset), 0)
                        jianImage.transform.localEulerAngles = Vector3.New(0, 0, angles)
                        jianImage.transform.localPosition = Vector3.New(0, py, 0)
                    end
                end
                local s = GetComponentWithPath(view, "Image", "SpriteHolder")
                local image = GetComponentWithPath(view, "Image", ComponentTypeName.Image)
                image.sprite = s:FindSpriteByName("" .. 2)
            end
            -- 全盘刷新叫牌
            --count =0
            for _, v2 in ipairs(v.JiaoPai) do
                local view = TableUtil.clone(cloneJiaoPai, PlayerPanel.jiaopai.gameObject, Vector3.zero)
                if 1 == PlayerSeat then
                    if (self:isNewLayout()) then
                        view.transform.localPosition = Vector3.New(0, -260 * count, 0)
                    else
                        view.transform.localPosition = Vector3.New(xiaZhangWidth[1] * count, 0, 0)
                    end
                elseif 2 == PlayerSeat then
                    view.transform.localPosition = Vector3.New(0, -xiaZhangWidth[2] * count, 0)
                elseif 4 == PlayerSeat then
                    view.transform.localPosition = Vector3.New(0, -xiaZhangWidth[4] * count, 0)
                end
                count = count + 1
                for k = 0, 3 do
                    local index = 4 == PlayerSeat and k or k
                    local imageObj = GetComponentWithPath(view, "Pai/" .. index, ComponentTypeName.Transform).gameObject
                    if k <= #v2.Pai - 1 then
                        TableUtil.new_set_changpai(v2.Pai[1], imageObj, true)
                        ComponentUtil.SafeSetActive(imageObj, true)
                    else
                        ComponentUtil.SafeSetActive(imageObj, false)
                    end
                    if (self:isNewLayout() and 1 == PlayerSeat ) then
                        local jiaopai = GetComponentWithPath(view, "Pai/" .. k, ComponentTypeName.Transform).gameObject
                        local jianImage = GetComponentWithPath(view, "Image", ComponentTypeName.Transform).gameObject
                        jiaopai.transform.localPosition = Vector3.New(0, startY + (k * offset), 0)
                        jianImage.transform.localEulerAngles = Vector3.New(0, 0, angles)
                        jianImage.transform.localPosition = Vector3.New(0, py, 0)
                    end
                end
                local s = GetComponentWithPath(view, "Image", "SpriteHolder")
                local image = GetComponentWithPath(view, "Image", ComponentTypeName.Image)
                image.sprite = s:FindSpriteByName("" .. 1)
            end
        end

        if curTableData.isPlayBack and PlayerPanel.handPoint then
            Manager.DestroyChildren(PlayerPanel.handPoint)
            for j, p in ipairs(v.ShouZhang) do
                local mj = TableUtil.poor(PlayerSeat .. "_OutMJ", PlayerPanel.handPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
                TableUtil.new_set_changpai(p.Pai, mj)
            end
        end
    end
    if liaoLonging and not liaolongMySelf then
        ComponentUtil.SafeSetActive(self.centerTipsObj, true)
        self.centerTipsText.text = "等待其他玩家撂龙中..."
    else
        ComponentUtil.SafeSetActive(self.centerTipsObj, false)
    end
    --self:change_jiaopai_layout()---改变叫牌内部间隔和Image旋转
    ------------------------ 南通长牌 end ------------------------
end

------------------------ 南通长牌 start ------------------------
-- 南通长牌 叫牌/撂龙面板
function TableView:get_jiaopai_liaolong_panel()
    if self.panel_nantong then
        return self.panel_nantong
    end

    self.panel_nantong = {}
    self.panel_nantong.root = GetComponentWithPath(self.root, "Bottom/Child/NanTongJiaoOrLiao", ComponentTypeName.Transform).gameObject
    self.panel_nantong.text = GetComponentWithPath(self.panel_nantong.root, "Text", ComponentTypeName.Text)
    self.panel_nantong.image = GetComponentWithPath(self.panel_nantong.root, "Image", ComponentTypeName.Transform).gameObject
    self.panel_nantong.quxiao = GetComponentWithPath(self.panel_nantong.root, "NanTongQuXiao", ComponentTypeName.Button)
    self.panel_nantong.jiaopai = GetComponentWithPath(self.panel_nantong.root, "NanTongJiaoPai", ComponentTypeName.Button)
    self.panel_nantong.liaolong = GetComponentWithPath(self.panel_nantong.root, "NanTongLiaoLong", ComponentTypeName.Button)

    return self.panel_nantong
end
------------------------ 南通长牌 end ------------------------

function TableView:update_seat_pointer()
    local masterSeat = 0
    local localZhuangJia = TableUtil.get_local_seat(masterSeat, self.mySeat, totalSeat)
    local addNum = 0
    for i = 1, 4 do
        local index = localZhuangJia + i - 1
        if (totalSeat == 4) then
            if (index > 4) then
                index = index - 4
            end
            self.pointerObjs[i].transform.localPosition = pointerPos[index]
        elseif (totalSeat == 3) then
            ComponentUtil.SafeSetActive(self.pointerObjs[i], i <= totalSeat)
            if (i <= totalSeat) then
                if (index == 3) then
                    addNum = 1
                end
                index = index + addNum
                if (index > 4) then
                    index = index - 4
                end
                self.pointerObjs[i].transform.localPosition = pointerPos[index]
            end
        end
    end
end

-- 更新牌局倒计时
function TableView:refresh_timedown_clock()
    local isTimeDown = false
    for i = 1, #self.seatHolderArray do
        ComponentUtil.SafeSetActive(self.seatHolderArray[i].imageBanker, false)
        ComponentUtil.SafeSetActive(self.seatHolderArray[i].imageReady, false)
        ComponentUtil.SafeSetActive(self.seatHolderArray[i].buttonKick, false)
    end

    self:update_seat_pointer()

    if gameState.CurPlayer == 0xffffffff then

    elseif gameState.CurPlayer == 0xffffffff - 1 and curTableData.RoomType ~= 3 then
        -- 比赛场 拦牌 显示倒计时，不显示方向
        isTimeDown = false
        for i = 1, #self.pointerChilds do
            ComponentUtil.SafeSetActive(self.pointerChilds[i], false)
        end
        for i = 1, #self.lightChilds do
            ComponentUtil.SafeSetActive(self.lightChilds[i], false)
        end
        ComponentUtil.SafeSetActive(self.timeDown, false)
        --ComponentUtil.SafeSetActive(self.waitObj, true)
        if (TableUtil.is_ntcp()) then
            for i = 1, #self.seatHolderArray do
                ComponentUtil.SafeSetActive(self.seatHolderArray[i].highLight, false)
                --ComponentUtil.SafeSetActive(self.seatHolderArray[i].clockObj, false)
            end
            ComponentUtil.SafeSetActive(self.clockObj, false)
        end
    else
        isTimeDown = true
        --ComponentUtil.SafeSetActive(self.timeDown, true)
        ComponentUtil.SafeSetActive(self.waitObj, false)
        ComponentUtil.SafeSetActive(self.timer1img.gameObject, false)
        ComponentUtil.SafeSetActive(self.timer2img.gameObject, false)
        if (curTableData.isPlayBack) then
            isTimeDown = false
            --self.timer1img.sprite = self.timer1imgSprite:FindSpriteByName("0")
            --self.timer2img.sprite = self.timer2imgSprite:FindSpriteByName("0")
            --for i = 1, #self.seatHolderArray do
            --    ComponentUtil.SafeSetActive(self.seatHolderArray[i].clockObj, false)
            --end
            ComponentUtil.SafeSetActive(self.clockObj, false)
        end
        if gameState.CurPlayer == 0xffffffff - 1 then
            -- 0xffffffff - 1  = -2 拦牌  比赛场 拦牌 显示倒计时，不显示方向
            for i = 1, #self.pointerChilds do
                ComponentUtil.SafeSetActive(self.pointerChilds[i], false)
            end
            for i = 1, #self.lightChilds do
                ComponentUtil.SafeSetActive(self.lightChilds[i], false)
            end
            if (TableUtil.is_ntcp()) then
                for i = 1, #self.seatHolderArray do
                    ComponentUtil.SafeSetActive(self.seatHolderArray[i].highLight, false)
                    --ComponentUtil.SafeSetActive(self.seatHolderArray[i].clockObj, false)
                end
                ComponentUtil.SafeSetActive(self.clockObj, false)
            end
        else
            local localTargetSeat = TableUtil.get_local_seat(gameState.CurPlayer, 0, totalSeat)
            for i = 1, #self.pointerChilds do
                ComponentUtil.SafeSetActive(self.pointerChilds[i], i == localTargetSeat or (localTargetSeat == 4 and totalSeat == 3 and i == 3))
            end
            local localSeat = TableUtil.get_local_seat(gameState.CurPlayer, self.mySeat, totalSeat)
            --for i = 1, #self.lightChilds do
            --    ComponentUtil.SafeSetActive(self.lightChilds[i], i == localSeat)
            --end
            --高亮该哪家出牌
            for i = 1, #self.seatHolderArray do
                ComponentUtil.SafeSetActive(self.seatHolderArray[i].highLight, i == localSeat)
                --ComponentUtil.SafeSetActive(self.seatHolderArray[i].clockObj, i == localSeat and not curTableData.isPlayBack)
            end
            if (not curTableData.isPlayBack) then
                self:showClockState(localSeat)
            end
        end
    end
    if gameState.Result == 1 or gameState.Result == 2 or gameState.Result == 3 then
        if curTableData.RoomType ~= 3 then
            self.timerSum = -1
        end
    else
        if isTimeDown then
            if curTableData.RoomType ~= 3 then
                self.timerSum = 15
            end
            self:show_time()
        else
            if curTableData.RoomType ~= 3 then
                self.timerSum = -1
            end
        end
    end

    if (gameState.Dice1 ~= 0) then
        self:play_voice("common/startgame")
    end

    -- 统计所有麻将
    for i = 1, allCardNum do
        allCard[i] = 0
    end
    for i = 1, #gameState.Player do
        local playerState = gameState.Player[i]
        for j = 1, #playerState.ShouZhang do
            local pai = playerState.ShouZhang[j].Pai
            if (pai ~= 0) then
                allCard[pai] = allCard[pai] + 1
            end
        end
        for j = 1, #playerState.QiZhang do
            local pai = playerState.QiZhang[j]
            if (pai ~= 0) then
                allCard[pai] = allCard[pai] + 1
            end
        end
        for j = 1, #playerState.XiaZhang do
            local pais = playerState.XiaZhang[j].Pai
            if (#pais == 4) then
                local pai = pais[4]
                if (pai ~= 0) then
                    allCard[pai] = allCard[pai] + 4
                end
            else
                for k = 1, #pais do
                    local pai = pais[k]
                    if (pai ~= 0) then
                        allCard[pai] = allCard[pai] + 1
                    end
                end
            end
        end
    end

    if (gameState.LaiGen and gameState.LaiGen ~= 0 and allCard[gameState.LaiGen] and allCard[gameState.LaiGen] < 4) then
        allCard[gameState.LaiGen] = allCard[gameState.LaiGen] + 1
    end

    self:update_hu_list(allCard)

    self:hide_all_move_pointer()
    ComponentUtil.SafeSetActive(self.selectHua, gameState.KePiaoHua)

    local isChu = {}
    for i = 1, #gameState.Player do
        isChu[i] = false
    end

    for i = 1, #gameState.Action do
        local action = gameState.Action[i]
        --1:吃 2:碰 3:明杠 4:暗杠 5:点杠 6:和 7:听 8:出 9:自动出 10:摸 11:开杠 12:过牌 13：安庆宿松漂花 14：辣子先补花
        if action.Action == 2 or action.Action == 3 or action.Action == 4 or action.Action == 5 or action.Action == 14 then
            self:show_current_mj(false)
        end
        if (9 == action.Action or (8 == action.Action and (curTableData.isPlayBack or action.SeatID ~= self.mySeat))) then
            isChu[action.SeatID + 1] = true
        end

        if (action.Action < 8 or (curTableData.isPlayBack and action.Action == 12)) then
            local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(action.SeatID, self.mySeat, totalSeat)]
            if action.Action < 8 and 6 ~= action.Action then
                -- 胡的音效，在module播放
                self:play_action_sound(action.Action, seatHolder)
            end
            self:chu_tx(action.SeatID, action.Action)
        elseif (action.Action == 11) then
            self:play_voice("common/liangpai")
        elseif (action.Action == 14) then
            --补花
            local seatInfo = self.seatHolderArray[TableUtil.get_local_seat(action.SeatID, self.mySeat, totalSeat)]
            if (seatInfo.gender == 1) then
                self:play_voice("malesound_ntcp/man_buhua")
            else
                self:play_voice("femalesound_ntcp/women_buhua")
            end
            ComponentUtil.SafeSetActive(seatInfo.huaAnimation, true)
            local buhua = TableUtil.poor("BuHuaTX", seatInfo.huaAnimation, Vector3.zero, self.poorObjs, self.clones)
            self:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
                self.poorObjs = TableUtil.add_poor(buhua, self.poorObjs, self.cloneParent)
            end)
        elseif 7 == action.Action then
            -- 天听
            --local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat, 3)
            local seatInfo = self.seatHolderArray[TableUtil.get_local_seat(action.SeatID, self.mySeat, totalSeat)]
            if (seatInfo.gender and seatInfo.gender == 1) then
                self:play_voice("malesound_ntcp/" .. "man_tianting")
            else
                self:play_voice("femalesound_ntcp/" .. "man_tianting")
            end
        elseif 15 == action.Action then
            -- 叫牌
            local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(action.SeatID, self.mySeat, totalSeat)]
            local tx_jiaopai = TableUtil.poor("Anim_JiaoLong", seatHolder.chuTXPos, Vector3.zero, self.poorObjs, self.clones)
            Manager.SetActive(tx_jiaopai, true)
            if not self.timerEventId then
                self.timerEventId = {}
            end
            self.timerEventId[#self.timerEventId + 1] = Manager.GetSmartTimer(2, false, 0, 0, nil,
            function()
                Manager.SetActive(tx_jiaopai, false)
                self.poorObjs = TableUtil.add_poor(tx_jiaopai, self.poorObjs, self.cloneParent)
            end)
        elseif 16 == action.Action then
            -- 撂龙
            local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(action.SeatID, self.mySeat, totalSeat)]
            local tx_liaolong = TableUtil.poor("Anim_LiaoLong", seatHolder.chuTXPos, Vector3.zero, self.poorObjs, self.clones)
            Manager.SetActive(tx_liaolong, true)
            if not self.timerEventId then
                self.timerEventId = {}
            end
            self.timerEventId[#self.timerEventId + 1] = Manager.GetSmartTimer(2, false, 0, 0, nil,
            function()
                Manager.SetActive(tx_liaolong, false)
                self.poorObjs = TableUtil.add_poor(tx_liaolong, self.poorObjs, self.cloneParent)
            end)
        elseif 17 == action.Action then
            self.tianhu_sound = true
            Manager.GetSmartTimer(2, false, 0, 0, nil, function()
                self.tianhu_sound = false
            end)
            local seatInfo = self.seatHolderArray[TableUtil.get_local_seat(action.SeatID, self.mySeat, totalSeat)]
            if (seatInfo.gender and seatInfo.gender == 1) then
                self:play_voice("malesound_ntcp/man_tianhu")
            else
                self:play_voice("femalesound_ntcp/woman_tianhu")
            end
        end
    end
    self.readyOutMJ = nil
    self:set_player_states(gameState, isChu)
    if (self.readyOutMJ) then
        self:change_mj_color(self:get_mj_pai(self.readyOutMJ))
        self:show_ting_hu_grid(self:get_mj_pai(self.readyOutMJ))
    end
end

function TableView:refresh_table_bg()
    local tableBg = Manager.GetPlayerPrefsInt(string.format("%s_MJBackground", self.ruleJsonInfo.GameType), 1)
    if (tableBg == 0) then
        tableBg = 1
    end
    ModuleCache.ComponentUtil.SafeSetActive(self.tableBg1, tableBg == 1)
    ModuleCache.ComponentUtil.SafeSetActive(self.tableBg2, tableBg == 2)
    ModuleCache.ComponentUtil.SafeSetActive(self.tableBg3, tableBg == 3)
end

function TableView:set_player_states(newGameState, isChu)
    colorMj = {}
    self.grayMJ = {}
    for i = 1, #newGameState.Player do
        self:set_player_state(TableUtil.get_local_seat(i - 1, self.mySeat, totalSeat), newGameState.Player[i], isChu[i], i, newGameState)
    end
end

-- 出牌的特效
function TableView:chu_tx(seatId, pai)
    local seatInfo = self.seatHolderArray[TableUtil.get_local_seat(seatId, self.mySeat, totalSeat)]
    local newChuTX = TableUtil.poor("ChuTX", seatInfo.chuTXPos, Vector3.zero, self.poorObjs, self.clones)
    local chuimage = GetComponentWithPath(newChuTX, "Image", ComponentTypeName.Image)
    local imageSprite = GetComponentWithPath(newChuTX, "", "SpriteHolder")
    local chuimage1 = GetComponentWithPath(newChuTX, "Image 1", ComponentTypeName.Image)
    chuimage.sprite = imageSprite:FindSpriteByName(pai .. "")
    chuimage1.sprite = imageSprite:FindSpriteByName(pai .. "")
    chuimage:SetNativeSize()
    chuimage1:SetNativeSize()
    self:subscibe_time_event(1, false, 0):OnComplete(function(t)
        self.poorObjs = TableUtil.add_poor(newChuTX, self.poorObjs, self.cloneParent)
    end)
end

-- 显示听胡列表
function TableView:show_ting_hu_grid(pai)
    if (#gameState.KeLiang > 0) then
        self.haveTing = false
        for i = 1, #gameState.KeLiang[1].KeChu do
            if (pai == gameState.KeLiang[1].KeChu[i].ChuPai) then
                self.tingPaiNum = #gameState.KeLiang[1].KeChu[i].TingPai
                if (self.tingPaiNum >= 26) then
                    self.haveTing = true
                    ComponentUtil.SafeSetActive(self.huGridParent, false)
                    ComponentUtil.SafeSetActive(self.tingJianZiHu, true)
                else
                    local tinglist = {}
                    for j = 1, #gameState.KeLiang[1].KeChu[i].TingPai do
                        local setPai = gameState.KeLiang[1].KeChu[i].TingPai[j]
                        ComponentUtil.SafeSetActive(self.huGridParent, false)
                        ComponentUtil.SafeSetActive(self.tingJianZiHu, false)
                        self.haveTing = true
                        table.insert(tinglist, setPai)
                    end
                    self:update_hu_list(nil, tinglist)
                end
            end
        end
        if (not self.haveTing) then
            self:hide_ting_hu_grid()
        end
    else
        self:hide_ting_hu_grid()
    end
end

-- 更新胡牌列表
function TableView:update_hu_list(allCard, overCard)

    if overCard then
        ComponentUtil.SafeSetActive(self.huGridParent, true)
        ComponentUtil.SafeSetActive(self.huGrid, true)
        ComponentUtil.SafeSetActive(self.jianZiHu, false)
        self:Refreash_hu_list_data(overCard);
    else
        -- 不显示胡牌列表
        ComponentUtil.SafeSetActive(self.huGridParent, #gameState.YiTing > 0)
        ComponentUtil.SafeSetActive(self.huGrid, #gameState.YiTing < 26 and #gameState.YiTing > 0)
        ComponentUtil.SafeSetActive(self.jianZiHu, #gameState.YiTing >= 26)
        if (#gameState.YiTing < 26 and #gameState.YiTing > 0) then
            self:Refreash_hu_list_data(gameState.YiTing);
        end
    end
end

function TableView:Refreash_hu_list_data(list)
    local allHuChilds = TableUtil.get_all_child(self.huGrid)
    local huChilds = {}
    for i = 2, #allHuChilds do
        ComponentUtil.SafeSetActive(allHuChilds[i], false)
        table.insert(huChilds, allHuChilds[i])
    end
    for i = 1, #list do
        local mj = nil
        local setPai = list[i]
        if (i <= #huChilds) then
            mj = huChilds[i]
        else
            mj = TableUtil.poor("HuMJ", self.huGrid, Vector3.zero, self.poorObjs, self.clones)
        end
        TableUtil.new_set_changpai(setPai, mj)
        ComponentUtil.SafeSetActive(mj, true)
        TableUtil.new_set_mj_jian_fan(mj)
    end
end

-- 隐藏听胡列表
function TableView:hide_ting_hu_grid(showHu)
    ComponentUtil.SafeSetActive(self.tingGridParent, false)
end
-- 准备出牌时改变相关麻将颜色
function TableView:change_mj_color(pai)
    if self.colorPai then
        self:change_mj_white(self.colorPai)
        self.colorPai = nil
    end
    if gameState and pai ~= gameState.LaiZi then
        local mjs = colorMj[pai .. ""]

        if (mjs) then
            self.colorPai = pai
            for i = 1, #mjs do
                TableUtil.set_changpai_color(mjs[i], self.colorChange)
            end
        end
    end
end
-- 对应麻将变白
function TableView:change_mj_white(pai)
    if (pai ~= gameState.LaiZi) then
        local mjs = colorMj[pai .. ""]
        if (mjs) then
            for i = 1, #mjs do
                TableUtil.set_changpai_color(mjs[i], Color.white)
            end
        end
    end
end

-- 复位拖动的麻将
function TableView:reset_drag_mj()
    if (self.colorPai) then
        self:change_mj_white(self.colorPai)
        self.colorPai = nil
    end
end
-- 准备拖动
function TableView:ready_drag_mj(obj, isDrag)
    if (not isDrag) then
        return
    end
    self:change_mj_color(self:get_mj_pai(obj))
    local seatHolder = self.seatHolderArray[1]
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    for i = 1, #rightChildren do
        local mj = rightChildren[i]
        if (mj ~= obj and mj.activeSelf) then
            mj.name = "inMJ_" .. self:get_mj_pai(mj)
            --mj.transform.localPosition = Vector3.New(mj.transform.localPosition.x, 0, mj.transform.localPosition.z)
        else

        end
    end
end


-- 准备出牌
function TableView:ready_chu_mj(obj, isProceeLayout)
    curSelectPai = obj
    if nil == isProceeLayout then
        isProceeLayout = true
    end
    self:play_voice("common/xuanpai")
    local seatHolder = self.seatHolderArray[1]
    local playerState = gameState.Player[self.mySeat + 1]
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    local xCount = 1
    local yCount = 1
    local jiaoPaiOffset = #playerState.JiaoPai
    local liaoLongOffset = #playerState.LiaoLong
    if (self:isNewLayout()) then
        jiaoPaiOffset = 0
        liaoLongOffset = 0
    end

    local handCenterOffset = (liaoLongOffset + jiaoPaiOffset + #playerState.XiaZhang - 2) * xiaZhangWidth[1]
    if handCenterOffset < 0 then
        handCenterOffset = 0
    end
    local hasMoZhang = (seatHolder.mopai or #playerState.HuPai ~= 0)
    local mySelfHandData = TableUtil.processMyHandMjData(playerState.ShouZhang, hasMoZhang, self:isNewLayout())

    local temp = {}
    for i = #rightChildren, 1, -1 do
        table.insert(temp, rightChildren[i])
    end
    rightChildren = temp

    local isEnd = false
    for i = 1, #rightChildren do
        local mj = rightChildren[i]
        if isEnd then
            ComponentUtil.SafeSetActive(mj, false)
        else
            ComponentUtil.SafeSetActive(mj, true)
            local pai = self:get_mj_pai(mj)
            local shouZhangInfo = mySelfHandData[xCount]
            local xOffset = (xCount - 1) * rightWidthOffset[1] + handCenterOffset
            local yOffset = (yCount - 1) * myHightOffset
            local subCount = hasMoZhang and 2 or 1
            local totalOffset = (#mySelfHandData - subCount) * rightWidthOffset[1]
            if true == isProceeLayout then
                mj.transform.localPosition = seatHolder.inMjBeginPos + Vector3.New(xOffset, yOffset, 0) - Vector3.New(totalOffset / 2, 0, 0)
            end
            local isLastMoZhang = xCount == #mySelfHandData and (seatHolder.mopai or #playerState.HuPai ~= 0)
            if isLastMoZhang then
                if ((not playerState.HuPai or #playerState.HuPai == 0) and self:is_me_chu_mj(mj)) then
                    if true == isProceeLayout then
                        mj.transform.position = self.chuPosObj.transform.position
                        mj.transform.localPosition = mj.transform.localPosition + Vector3.New(0, moOffset, 0)
                    end
                end
            end
            if (mj == obj) then
                if (self:is_me_chu_mj()) then
                    self:change_mj_color(pai)
                    if not self:is_liaolong_state() then
                        mj.name = "readyChuMJ_" .. pai
                    else
                        mj.name = "inMJ_" .. pai
                    end
                    self:show_ting_hu_grid(pai)
                else
                    mj.name = "inMJ_" .. pai
                end
                if true == isProceeLayout then
                    mj.transform.localPosition = mj.transform.localPosition + Vector3.New(0, 20, 0)
                end
            else
                mj.name = "inMJ_" .. pai
            end
            yCount = yCount + 1
            if yCount > #shouZhangInfo then
                yCount = 1
                xCount = xCount + 1
                if xCount > #mySelfHandData then
                    isEnd = true
                end
            end
        end
    end
end

---是否处于撂龙阶段
function TableView:is_liaolong_state()
    local isLiaoLongState = false  ---是否正在撂龙状态
    for k, v in ipairs(gameState.Player) do
        if v.KeJiaoPai and 0 < #v.KeJiaoPai then
            isLiaoLongState = true
            break
        end
    end
    return isLiaoLongState
end

-- 获取自己麻将的牌数
function TableView:get_mj_pai(obj)
    local names = string.split(obj.name, "_")
    return tonumber(names[2])
end

function TableView:insert_mj_by_pai(mjTable, pai, mj)
    local paiStr = pai .. ""
    if (not mjTable[paiStr]) then
        mjTable[paiStr] = {}
    end
    table.insert(mjTable[paiStr], mj)
end

function TableView:is_gray(obj)
    if (curTableData.isPlayBack) then
        return 0
    end
    if (self.grayMJ) then
        for i = 1, #self.grayMJ do
            if (obj == self.grayMJ[i]) then

                return i
            end
        end
    end
    return nil
end

-- 是否是我出牌
function TableView:is_me_chu_mj(obj)
    return not self.isChuMJ and self.isMeMoPai and self:is_gray(obj) == nil and gameState
    and gameState.Result == 0 and self:is_ting_gray(obj) == nil
end

-- 设置玩家状态  ---数据刷新 每次数据刷新都走这里
function TableView:set_player_state(localSeat, playerState, isChu, index, newGameState)
    local upStr = "Up"
    local seatHolder = self.seatHolderArray[localSeat]

    if(TableUtil.is_ntcp()) then
        if(localSeat==1) then
            if(playerState.mai_zhuang~=nil and self.ruleJsonInfo.MaiZhuang>0) then
                self.selectHua:SetActive(playerState.mai_zhuang<0)
            else
                self.selectHua:SetActive(false)
            end
        end
        ModuleCache.ComponentUtil.SafeSetActive(seatHolder.piaoZun, playerState.mai_zhuang==1)
    end

    seatHolder.tingObj:SetActive(#playerState.YiTing > 0)
    seatHolder.seatID = index - 1
    seatHolder.textScore.text = playerState.ZongBeiShu .. ""
    seatHolder.huShuText.text = "胡数:" .. tostring(playerState.FanBeiShu)
    if (playerState.lianzhuangnum > 1) then
        seatHolder.remainBankerText.text = "x" .. playerState.lianzhuangnum
    end
    if (playerState.piaohuacfgnew and playerState.piaohuacfgnew >= 2) then
        ComponentUtil.SafeSetActive(seatHolder.piaoSprite.transform.parent.gameObject, true)
        seatHolder.piaoSprite.sprite = seatHolder.piaoSH:FindSpriteByName((playerState.piaohuacfgnew - 1) .. "")
    end
    ComponentUtil.SafeSetActive(seatHolder.imageSanKou, playerState.BaoPaiJingGao ~= nil and playerState.BaoPaiJingGao)
    ComponentUtil.SafeSetActive(seatHolder.rightPoint, true)
    ComponentUtil.SafeSetActive(seatHolder.leftPoint, true)
    ComponentUtil.SafeSetActive(seatHolder.outPoint, not curTableData.isPlayBack)
    ComponentUtil.SafeSetActive(seatHolder.huaPoint, true)
    ComponentUtil.SafeSetActive(seatHolder.di, seatHolder.seatID ~= newGameState.ZhuangJia and playerState.DiTuo)
    ComponentUtil.SafeSetActive(seatHolder.tuo, seatHolder.seatID == newGameState.ZhuangJia and playerState.DiTuo)
    ComponentUtil.SafeSetActive(seatHolder.imageBanker, seatHolder.seatID == newGameState.ZhuangJia)
    ComponentUtil.SafeSetActive(seatHolder.maiZhuang, newGameState.MaiZhuang and newGameState.MaiZhuang == 1) --显示买庄

    local moSeat = (TableUtil.get_local_seat(newGameState.CurPlayer, self.mySeat, totalSeat) == localSeat) --刚摸牌的座位
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    ---此处添加 #playerState.ShouZhang==maxShouPaiNum 判断
    seatHolder.mopai = (seatHolder.seatID == newGameState.CurPlayer or #playerState.ShouZhang==maxShouPaiNum)
    local newChilds = {}
    local rightOffset = 0
    local xCount = 1
    local yCount = 1
    local mySelfHandData = nil
    local hasMoZhang = (seatHolder.mopai or #playerState.HuPai ~= 0)
    if localSeat == 1 then---是自己
        mySelfHandData = TableUtil.processMyHandMjData(playerState.ShouZhang, hasMoZhang, self:isNewLayout())
        local temp = {}
        for i = #rightChildren, 1, -1 do
            table.insert(temp, rightChildren[i])
        end
        rightChildren = temp
    end
    local isEnd = false
    for i = 1, #rightChildren do
        -- 手张
        if localSeat == 1 then
            --自己
            local jiaoPaiOffset = #playerState.JiaoPai
            local liaoLongOffset = #playerState.LiaoLong
            if (self:isNewLayout()) then
                jiaoPaiOffset = 0
                liaoLongOffset = 0
            end
            local handCenterOffset = (liaoLongOffset + jiaoPaiOffset + #playerState.XiaZhang - 2) * xiaZhangWidth[1]
            if handCenterOffset < 0 then
                handCenterOffset = 0
            end
            local otherOffset = Vector3.New(0, 0, 0)---当23张手牌撩龙阶段不能出牌偏移37
            if (self:is_liaolong_state() and #playerState.ShouZhang == maxShouPaiNum) then
                otherOffset = Vector3.New(37, 0, 0)
            end
            self.isMeMoPai = seatHolder.mopai
            local mj = rightChildren[i]
            if isEnd then
                ComponentUtil.SafeSetActive(mj, false)
            else
                ComponentUtil.SafeSetActive(mj, true)
                local shouZhangInfo = mySelfHandData[xCount]
                local shouZhangData = shouZhangInfo[yCount]
                local xOffset = (xCount - 1) * rightWidthOffset[localSeat] + handCenterOffset
                local yOffset = (yCount - 1) * myHightOffset
                local subCount = hasMoZhang and 2 or 1
                local totalOffset = (#mySelfHandData - subCount) * rightWidthOffset[localSeat]
                mj.transform.localPosition = seatHolder.inMjBeginPos + otherOffset + Vector3.New(xOffset, yOffset, 0) - Vector3.New(totalOffset / 2, 0, 0)
                local downObj = GetComponentWithPath(mj, "Down", ComponentTypeName.Transform).gameObject
                local upObj = GetComponentWithPath(mj, upStr, ComponentTypeName.Transform).gameObject
                local mjObj = nil
                local showHu = #playerState.HuPai ~= 0 and i == #playerState.ShouZhang
                if (#playerState.HuPai ~= 0) then
                    mjObj = upObj
                    ComponentUtil.SafeSetActive(downObj, false)
                    ComponentUtil.SafeSetActive(upObj, true)
                else
                    mjObj = upObj
                    ComponentUtil.SafeSetActive(downObj, false)
                    ComponentUtil.SafeSetActive(upObj, true)
                end
                TableUtil.new_set_changpai(shouZhangData.Pai, mjObj)
                TableUtil.set_changpai_color(mjObj, Color.white)
                if (shouZhangData.Gray) then
                    TableUtil.set_changpai_color(mjObj, Color.gray)
                    table.insert(self.grayMJ, mj)
                else
                    self.guoYangHuaMJ = self:get_hua(shouZhangData.Pai, mj)
                end
                if (shouZhangData.Pai == newGameState.LaiZi) then
                    TableUtil.set_changpai_color(mjObj, Color.yellow)
                end

                local tagJ = Manager.GetImage(mjObj, "Image/J/Tag")
                local tagF = Manager.GetImage(mjObj, "Image/F/Tag")
                local tagJ2 = Manager.GetImage(mjObj, "Image2/J/Tag")
                local tagF2 = Manager.GetImage(mjObj, "Image2/F/Tag")
                local b = self:show_ting(shouZhangData.Pai)
                Manager.SetActive(tagJ, b)
                Manager.SetActive(tagF, b)
                Manager.SetActive(tagJ2, b)
                Manager.SetActive(tagF2, b)
                mj.transform.localScale = Vector3.New(1, 1, 1)
                local isLastMoZhang = xCount == #mySelfHandData and (seatHolder.mopai or #playerState.HuPai ~= 0)
                mj.name = "inMJ_" .. shouZhangData.Pai
                if (isLastMoZhang) then
                    -- 最后一张
                    if ((not playerState.HuPai or #playerState.HuPai == 0) and self:is_me_chu_mj(mj)) then
                        if not self:is_liaolong_state() then
                            --等待其他玩家撩龙中不能出牌
                            mj.name = "readyChuMJ_" .. shouZhangData.Pai
                        end
                        mj.transform.position = self.chuPosObj.transform.position
                        mj.transform.localPosition = mj.transform.localPosition + Vector3.New(0, 20 + moOffset, 0)
                        self.readyOutMJ = mj
                    end
                end
                yCount = yCount + 1
                if yCount > #shouZhangInfo then
                    yCount = 1
                    xCount = xCount + 1
                    if xCount > #mySelfHandData then
                        isEnd = true
                    end
                end
            end
        else --非自己
            local mj = rightChildren[i]
            if (localSeat ~= 3) then
                mj.transform.localPosition = seatHolder.inMjBeginPos + Vector3.New(0, rightOffset, 0)
            else
                mj.transform.localPosition = seatHolder.inMjBeginPos + Vector3.New(rightOffset, 0, 0)
            end
            local downObj = GetComponentWithPath(mj, "Down", ComponentTypeName.Transform).gameObject
            local upObj = GetComponentWithPath(mj, upStr, ComponentTypeName.Transform).gameObject
            local shouZhangData = nil
            local showHu = false
            ComponentUtil.SafeSetActive(mj, i <= #playerState.ShouZhang)
            if (mj.activeSelf) then
                shouZhangData = playerState.ShouZhang[i]
                showHu = #playerState.HuPai ~= 0 and i == #playerState.ShouZhang
                if (i == #playerState.ShouZhang and (seatHolder.mopai or #playerState.HuPai ~= 0)) then
                    -- 最后一张
                    if (localSeat == 3) then
                        mj.transform.localPosition = mj.transform.localPosition-- + Vector3.New(-lastMJOffset, 0, 0)
                    elseif (localSeat == 4) then
                        mj.transform.localPosition = mj.transform.localPosition-- + Vector3.New(0, -lastMJOffset * 0.5, 0)
                    else
                        mj.transform.localPosition = mj.transform.localPosition --+ Vector3.New(0, lastMJOffset * 0.5, 0)
                    end
                end
            end
            if localSeat == 2 then
                rightOffset = rightOffset + rightWidthOffset[localSeat]
            elseif localSeat == 3 then
                rightOffset = rightOffset - rightWidthOffset[localSeat]
            else
                rightOffset = rightOffset - rightWidthOffset[localSeat]
            end
            if (shouZhangData and (curTableData.isPlayBack or (shouZhangData.Pai ~= 0 and #playerState.HuPai ~= 0) or shouZhangData.State == 2)) then
                if (mj.activeSelf) then
                    table.insert(newChilds, mj)
                end

                local tag = GetComponentWithPath(downObj, "Image/Tag", ComponentTypeName.Transform).gameObject
                local tagImage = GetComponentWithPath(downObj, "Image/Tag", ComponentTypeName.Image)
                local tagSH = GetComponentWithPath(downObj, "Image/Tag", "SpriteHolder")
                ComponentUtil.SafeSetActive(tag, false)
                if (showHu) then
                    ComponentUtil.SafeSetActive(tag, true)
                    tagImage.sprite = tagSH:FindSpriteByName("2")
                end
            else
                if (maxShouPaiNum == 20) then
                    if localSeat == 2 then
                        rightOffset = rightOffset - 5
                    elseif localSeat == 4 then
                        rightOffset = rightOffset + 5
                    end
                end
                if (mj.activeSelf) then
                    table.insert(newChilds, mj)
                end
                ComponentUtil.SafeSetActive(downObj, false)
                ComponentUtil.SafeSetActive(upObj, true)
            end
        end
    end
    if (localSeat == 2) then
        TableUtil.invert_mj_pos_hand(newChilds)
    end
    local outChilds = TableUtil.get_all_child(seatHolder.outPoint)
    for i = 1, #outChilds do
        ComponentUtil.SafeSetActive(outChilds[i], false)
    end
    newChilds = {}
    for i = 1, #playerState.QiZhang do
        -- 弃张
        local mj = nil
        if (i <= #outChilds) then
            mj = outChilds[i]
        else
            mj = TableUtil.poor(localSeat .. "_OutMJ", seatHolder.outPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
            --mj = TableUtil.poor("OutPai_All", seatHolder.outPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
        end
        if (localSeat == 1 or localSeat == 3) then
            local myXPos = outGridCell[localSeat][1] * ((i - 1) % myOutGridNum)
            local space = (i-1)%myOutGridNum
            if(space>=myQiZhangSpaceNum) then
                myXPos = myXPos+myQiZhangOffset
            end
            mj.transform.localPosition = seatHolder.outMjBeginPos + Vector3.New(myXPos,
            outGridCell[localSeat][2] * math.floor((i - 1) / myOutGridNum), 0)
        else
            mj.transform.localPosition = seatHolder.outMjBeginPos + Vector3.New(outGridCell[localSeat][1] * math.floor((i - 1) / outGridNum),
            outGridCell[localSeat][2] * ((i - 1) % outGridNum), 0)
        end
        ComponentUtil.SafeSetActive(mj, true)
        if mj.activeSelf then
            table.insert(newChilds, mj)
            local qiZhangData = playerState.QiZhang[i]
            -- self:insert_mj_by_pai(colorMj, qiZhangData, mj)
            TableUtil.new_set_changpai(qiZhangData, mj)
        end
    end
    -- 这里是不是有BUG啊，这里会重排位置的
    local newIndexs = TableUtil.invert_mj_pos(newChilds, #newChilds, playerState.QiZhang, false)
    for i = 1, #newIndexs do
        local mj = newChilds[i]
        local mjValue = playerState.QiZhang[newIndexs[i]]
        self:add_qi_zhang(index - 1, mj, newIndexs[i] > #playerState.QiZhang - playerState.ChuPaiCnt, isChu, mjValue .. "")
        -- 哥哥你位置改了啊
        self:insert_mj_by_pai(colorMj, mjValue, mj)
    end

    --不反转每次进来都要颠倒设置位置
    local huaChilds = {}
    local huaChildObjs = TableUtil.get_all_child(seatHolder.huaPoint)
    local huaCount = 1
    for i = #huaChildObjs, 1, -1 do
        huaChilds[huaCount] = huaChildObjs[i]
        huaCount = huaCount + 1
        ComponentUtil.SafeSetActive(huaChildObjs[i], false)
    end
    --local huaChilds = TableUtil.get_all_child(seatHolder.huaPoint)
    --for i = 1, #huaChilds do
    -- ComponentUtil.SafeSetActive(huaChilds[i], false)
    --end
    newChilds = {}

    self:refresh_jiaoPaiPos(seatHolder, localSeat, #playerState.HuaPai)
    for i = 1, #playerState.HuaPai do
        -- 花牌
        local mj = nil
        if (i <= #huaChilds) then
            mj = huaChilds[i]
        else
            mj = TableUtil.poor(localSeat .. "_HuaMJ", seatHolder.huaPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
        end
        if (localSeat == 1) then
            local space = 60
            mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(0, space * (i - 1), 0)
            mj.transform:SetSiblingIndex(0)
        elseif (localSeat == 2) then
            local space = 30
            mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(huaPaiStartX -space * (i - 1), 0, 0)
            mj.transform:SetSiblingIndex(0)
        elseif (localSeat == 3) then
            --mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(0, space * (i - 1), 0)
        elseif (localSeat == 4) then
            local space = 30
            mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(space * (i - 1), 0, 0)
            mj.transform:SetSiblingIndex(0)
        end
        ComponentUtil.SafeSetActive(mj, true)
        if mj.activeSelf then
            table.insert(newChilds, mj)
            local huapaiData = playerState.HuaPai[i]
            TableUtil.new_set_changpai(huapaiData, mj)
        end
    end
    -- 你都重新排序了，那值也变了
    newIndexs = TableUtil.invert_mj_pos(newChilds, #newChilds, playerState.HuaPai, false)
    for i = 1, #newIndexs do
        local mj = newChilds[i]
        local mjValue = playerState.HuaPai[newIndexs[i]]
        self:insert_mj_by_pai(colorMj, mjValue, mj)
    end

    local leftChilds = TableUtil.get_all_child(seatHolder.leftPoint)
    for i = 1, #leftChilds do
        ComponentUtil.SafeSetActive(leftChilds[i], false)
    end

    --local offsetWidth = (#playerState.JiaoPai + #playerState.LiaoLong) * xiaZhangWidth[localSeat] * xiaZhangScale[localSeat]
    --local leftWidth = offsetWidth  ---下张相对与撂龙叫牌的偏移
    local leftWidth = 0

    for i = 1, #playerState.XiaZhang do
        --下张摆放位置更新
        local xiaZhangData = playerState.XiaZhang[i]
        if (#xiaZhangData.Pai <= 4) then
            local needGray = false
            local pais = {}
            local mj = nil
            if (i < #leftChilds) then
                mj = leftChilds[i]
                ComponentUtil.SafeSetActive(mj, true)
            else
                mj = TableUtil.poor(localSeat .. "_4MJ", seatHolder.leftPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
            end
            if (localSeat == 1) then
                mj.transform.localPosition = Vector3.New(leftWidth, 0, 0)
            elseif (localSeat == 2) then
                mj.transform.localPosition = Vector3.New(0, -leftWidth, 0)
            elseif (localSeat == 3) then
                mj.transform.localPosition = Vector3.New(-leftWidth, 0, 0)
            elseif (localSeat == 4) then
                mj.transform.localPosition = Vector3.New(0, -leftWidth, 0)
            end
            local mjChilds = {}
            local tempChilds = TableUtil.get_all_child(mj)  ---反向排序下张组件中牌对象的顺寻，实现从下至上增涨
            for j = #tempChilds, 1, -1 do
                table.insert(mjChilds, tempChilds[j])
            end
            for j = 1, #mjChilds do
                if (j <= #playerState.XiaZhang[i].Pai) then
                    local pai = nil
                    if true then
                        --if (localSeat ~= 2) then  --todo:以前的残留逻辑，测试完成后需要删除
                        pai = playerState.XiaZhang[i].Pai[j]
                        ComponentUtil.SafeSetActive(mjChilds[j], true)
                        self:insert_mj_by_pai(colorMj, pai, mjChilds[j])
                        TableUtil.new_set_changpai(pai, mjChilds[j])
                        if (j - 1 == xiaZhangData.JinZhang) then
                            if (#xiaZhangData.Pai > 2) then
                                needGray = true
                            end
                        end
                        table.insert(pais, mjChilds[j])
                        TableUtil.set_changpai_color(mjChilds[j], Color.white)
                    else
                        local curIndex = #mjChilds - j + 1
                        if (#mjChilds == 4) then
                            if (j == 4) then
                                curIndex = j
                            else
                                curIndex = #mjChilds - j
                            end
                        end
                        ComponentUtil.SafeSetActive(mjChilds[curIndex], true)
                        pai = playerState.XiaZhang[i].Pai[j]
                        if (pai == 0) then
                            TableUtil.set_mj_bg(2, mjChilds[curIndex])
                        else
                            TableUtil.set_mj_bg(1, mjChilds[curIndex])
                        end
                        self:insert_mj_by_pai(colorMj, pai, mjChilds[curIndex])
                        TableUtil.new_set_changpai(pai, mjChilds[curIndex])
                        if (j - 1 == xiaZhangData.JinZhang) then
                            if (#xiaZhangData.Pai > 2) then
                                needGray = true
                            end
                        end
                        table.insert(pais, mjChilds[curIndex])
                        TableUtil.set_changpai_color(mjChilds[curIndex], Color.white)
                    end
                else
                    if true then
                        --todo:以前的残留逻辑，测试完成后需要删除
                        ComponentUtil.SafeSetActive(mjChilds[j], false)
                    else
                        local curIndex = #mjChilds - j + 1
                        if (#mjChilds == 4) then
                            if (j == 4) then
                                curIndex = j
                            else
                                curIndex = #mjChilds - j
                            end
                        end
                        ComponentUtil.SafeSetActive(mjChilds[curIndex], false)
                    end
                end
            end
            if (needGray) then
                local xiaZhangSeat = TableUtil.get_local_seat(xiaZhangData.Seat, index - 1, totalSeat)
                local mj = nil
                if (xiaZhangSeat == 2) then
                    if (#xiaZhangData.Pai == 4) then
                        mj = pais[3]
                    else
                        mj = pais[#pais]
                    end
                elseif (xiaZhangSeat == 3) then
                    if (#xiaZhangData.Pai == 4) then
                        mj = pais[4]
                    else
                        mj = pais[2]
                    end
                elseif (xiaZhangSeat == 4) then
                    mj = pais[1]
                else

                end
            end
            local num = 1
            leftWidth = leftWidth + xiaZhangWidth[localSeat] * xiaZhangScale[localSeat] * num
        else
            local pais = {}
            local childs = {}
            for j = 1, #xiaZhangData.Pai do
                local mj = TableUtil.poor(localSeat .. "_4MJ", seatHolder.leftPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
                local showIndex = 1
                if (localSeat == 1) then
                    mj.transform.localPosition = Vector3.New(leftWidth, 0, 0)
                elseif (localSeat == 2) then
                    showIndex = 3
                    mj.transform.localPosition = Vector3.New(0, leftWidth, 0)
                elseif (localSeat == 3) then
                    mj.transform.localPosition = Vector3.New(-leftWidth, 0, 0)
                elseif (localSeat == 4) then
                    mj.transform.localPosition = Vector3.New(0, -leftWidth, 0)
                end
                local pai = xiaZhangData.Pai[j]
                table.insert(pais, pai)
                local mjChilds = TableUtil.get_all_child(mj)
                for k = 1, #mjChilds do
                    ComponentUtil.SafeSetActive(mjChilds[k], k == showIndex)
                    if (k == showIndex) then
                        table.insert(childs, mjChilds[showIndex])
                        self:insert_mj_by_pai(colorMj, pai, mjChilds[showIndex])
                        TableUtil.new_set_changpai(pai, mjChilds[showIndex])
                        TableUtil.set_changpai_color(mjChilds[showIndex], Color.white)
                    end
                end
                local num = 1
                leftWidth = leftWidth + xiaZhangWidth[localSeat] * xiaZhangScale[localSeat] * num
            end
            leftWidth = leftWidth + lastMJOffset
        end
    end
    self:change_jiaopai_layout()
    self:change_xiazhang_layout()
end

-- 显示听的牌
function TableView:show_ting(pai)
    local showTing = false
    if (#gameState.KeLiang > 0) then
        for j = 1, #gameState.KeLiang[1].KeChu do
            if (pai == gameState.KeLiang[1].KeChu[j].ChuPai) then
                showTing = true
                break
            end
        end
    end
    return showTing
end

function TableView:show_not_ting(isGray)
    self.tingGray = {}
    local seatHolder = self.seatHolderArray[1]
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    local playerState = gameState.Player[self.mySeat + 1]

    for i = 1, #rightChildren do
        -- 手张
        local mj = rightChildren[i]
        local downObj = GetComponentWithPath(mj, "Down", ComponentTypeName.Transform).gameObject
        local upObj = GetComponentWithPath(mj, "Up", ComponentTypeName.Transform).gameObject
        local shouZhangData = playerState.ShouZhang[i]

        if mj.activeSelf and not self:show_ting(shouZhangData.Pai) then
            local mjObj = nil
            if (#playerState.HuPai ~= 0) then
                mjObj = upObj
            else
                mjObj = upObj
            end

            if isGray then
                TableUtil.set_changpai_color(mjObj, Color.gray)
                table.insert(self.tingGray, mj)
            else
                TableUtil.set_changpai_color(mjObj, Color.white)
            end

        end
    end

    if not isGray then
        self.tingGray = nil
    end
end

function TableView:is_ting_gray(obj)

    if (curTableData.isPlayBack) then
        return 0
    end
    if (self.tingGray) then
        for i = 1, #self.tingGray do
            if (obj == self.tingGray[i]) then
                return i
            end
        end
    end
    return nil
end

-- 添加弃张
function TableView:add_qi_zhang(seatId, mj, showPointer, isChu, pai)
    -- print("add_qi_zhang", seatId, mj, showPointer, isChu, pai)
    local playerState = gameState.Player[seatId + 1]
    local showBuHua = true
    if (playerState and playerState.piaohuacfgnew == 2) then
        showBuHua = false
    end
    local localSeat = TableUtil.get_local_seat(seatId, self.mySeat, totalSeat)
    if (mj) then
        if (pai == gameState.LaiZi .. "") then
            TableUtil.set_changpai_color(mj, Color.yellow)
        else
            TableUtil.set_changpai_color(mj, Color.white)
        end
        TableUtil.set_changpai_color(mj, Color.white)
    end
    if (showPointer) then
        if (mj) then
            if (playerState.showArrow == nil or playerState.showArrow) then
                self.movePointerMj = mj
                --local movePointer = ComponentUtil.Find(mj, "MovePointer")
                --ComponentUtil.SafeSetActive(movePointer, true)
            end
        end
        if (isChu) then
            local seatInfo = self.seatHolderArray[localSeat]
            local isHuaPai = false
            for i = 1, #gameState.HuaPai do
                if (pai == gameState.HuaPai[i] .. "" and showBuHua) then
                    isHuaPai = true
                    if (seatInfo.gender == 1) then
                        self:play_voice("malesound_ntcp/man_buhua")
                    else
                        self:play_voice("femalesound_ntcp/woman_buhua")
                    end
                    ComponentUtil.SafeSetActive(seatInfo.huaAnimation, true)
                    local buhua = TableUtil.poor("BuHuaTX", seatInfo.huaAnimation, Vector3.zero, self.poorObjs, self.clones)
                    self:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
                        self.poorObjs = TableUtil.add_poor(buhua, self.poorObjs, self.cloneParent)
                    end)
                    break
                end
            end
            if (not isHuaPai) then
                if (mPaiClipName[tonumber(pai)]) then
                    if (seatInfo.gender == 1) then
                        self:play_voice("malesound_ntcp/man" .. string.lower(mPaiClipName[tonumber(pai)]))
                    else
                        self:play_voice("femalesound_ntcp/woman" .. string.lower(mPaiClipName[tonumber(pai)]))
                    end
                end
                self:show_current_mj(true, pai, localSeat)
                --for i = 1, #self.seatHolderArray do
                --    local newChuMJ = TableUtil.poor("ChuMJ", self.seatHolderArray[i].chuMJPos, Vector3.zero, self.poorObjs, self.clones)
                --    if i == localSeat then
                --        TableUtil.set_changpai(pai, newChuMJ)
                --    else
                --        TableUtil.add_poor(newChuMJ, self.poorObjs, self.cloneParent)
                --    end
                --end
                --local newChuMJ = TableUtil.poor("ChuMJ", seatInfo.chuMJPos, Vector3.zero, self.poorObjs, self.clones)
                --TableUtil.set_changpai(pai, newChuMJ)
                --self:subscibe_time_event(0.5, false, 0):OnComplete(function(t)
                --    self.poorObjs = TableUtil.add_poor(newChuMJ, self.poorObjs, self.cloneParent)
                --end)
            end
        end
    end
end

function TableView:show_current_mj(show, pai, localSeat)
    for i = 1, #self.seatHolderArray do
        local chuMJ = GetComponentWithPath(self.seatHolderArray[i].chuMJPos, "ChuMJ", ComponentTypeName.Transform)
        --    Manager.DoScale(chuMJ, 0.1, 0)
        --    Manager.DoScale(chuMJ, 1, 0.25)
        if show and i == localSeat then
            if not chuMJ then
                chuMJ = TableUtil.poor("ChuMJ", self.seatHolderArray[i].chuMJPos, Vector3.zero, self.poorObjs, self.clones)
            end
            TableUtil.new_set_changpai(pai, chuMJ.gameObject)
            ComponentUtil.SafeSetActive(chuMJ.gameObject, true)
            if localSeat == 1 and self.feipai_pos then
                self.do_animation = true
                UnityEngine.Application.targetFrameRate = 120
                Manager.SetPos(chuMJ, self.feipai_pos)
                self.feipai_pos = nil
                local light = Manager.FindObject(chuMJ, "Bg")
                Manager.SetActive(light, false)
                Manager.Delay(0.1, function()
                    Manager.LocalMove(chuMJ, Vector3.zero, 0.2)
                end)
                Manager.Delay(0.3, function()
                    self.do_animation = false
                    self:get_refresh_changpai_data()
                    UnityEngine.Application.targetFrameRate = 30
                    Manager.SetActive(light, true)
                end)
            end
        else
            if chuMJ then
                ComponentUtil.SafeSetActive(chuMJ.gameObject, false)
            end
        end
    end
end

---当前是否可以出牌  可杠、可胡的时候不能出牌 只判断南通长牌
function TableView:can_chu_mj()
    if (TableUtil.is_ntcp() == false) then
        return true
    end
    if (gameState) then
        local seatHolder = self.seatHolderArray[1]
        if(seatHolder.seatID ~= gameState.CurPlayer) then
            return false
        else
            if (#gameState.KeGang > 0 or #gameState.KeHu > 0) then
                if (self.showWaitAction == true) then
                    --有扛胡听action显示后不能出牌
                    return false
                end
            else
            end
        end
    end
    return true
end


-- 出牌
function TableView:chu_mj(mj, pai)
    self:play_voice("common/chupai")
    ComponentUtil.SafeSetActive(mj, false)
    self.isChuMJ = true
    self:hide_ting_hu_grid(true)
    self:hide_wait_action_select_card()
    -- 加快
    -- pai = gameState.HuaPai[1] .. ""
    self:chu_pai_add_qi_zhang(pai)
    self:simulate_chu_mj()
    -- if not self:chu_pai_add_qi_zhang_huapai(pai) then
    -- end
    -- self:add_qi_zhang(self.mySeat, nil, true, true, pai .. "")
    if (self.colorPai) then
        self:change_mj_white(self.colorPai)
        self.colorPai = nil
    end
end

-- 出牌的时候先落地
function TableView:chu_pai_add_qi_zhang(pai)
    local newChilds = {}
    local seatHolder = self.seatHolderArray[1]
    local localSeat = 1
    local outChilds = TableUtil.get_all_child(seatHolder.outPoint)
    local index = 1

    --if self.movePointerMj then
    --    local movePointer = ComponentUtil.Find(self.movePointerMj, "MovePointer")
    --    ComponentUtil.SafeSetActive(movePointer, false)
    --end

    local playerState = gameState.Player[self.mySeat + 1]
    table.insert(playerState.QiZhang, pai)
    for i = 1, #playerState.QiZhang do
        -- 弃张
        local mj = nil
        if (i <= #outChilds) then
            mj = outChilds[i]
        else
            mj = TableUtil.poor(localSeat .. "_OutMJ", seatHolder.outPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
            --mj = TableUtil.poor("OutPai_All", seatHolder.outPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
             mj.name = mj.name .. tostring(playerState.QiZhang[i])
        end
        if (localSeat == 1 or localSeat == 3) then
            local myXPos = outGridCell[localSeat][1] * ((i - 1) % myOutGridNum)
            local space = (i-1)%myOutGridNum
            if(space>=myQiZhangSpaceNum) then
                myXPos = myXPos+myQiZhangOffset
            end
            mj.transform.localPosition = seatHolder.outMjBeginPos + Vector3.New(myXPos,
            outGridCell[localSeat][2] * math.floor((i - 1) / myOutGridNum), 0)
        else
            mj.transform.localPosition = seatHolder.outMjBeginPos + Vector3.New(outGridCell[localSeat][1] * math.floor((i - 1) / outGridNum),
            outGridCell[localSeat][2] * ((i - 1) % outGridNum), 0)
        end
        ComponentUtil.SafeSetActive(mj, true)
        if mj.activeSelf then
            table.insert(newChilds, mj)
            local qiZhangData = playerState.QiZhang[i]
            -- self:insert_mj_by_pai(colorMj, qiZhangData, mj)
            TableUtil.new_set_changpai(qiZhangData, mj)
        end
    end
    -- 这里是不是有BUG啊，这里会重排位置的
    --local newIndexs = TableUtil.invert_mj_pos(newChilds, #newChilds, playerState.QiZhang, localSeat ~= 3 and localSeat ~= 4)
    local newIndexs = TableUtil.invert_mj_pos(newChilds, #newChilds, playerState.QiZhang, false)
    for i = 1, #newIndexs do
        local mj = newChilds[i]
        local mjValue = playerState.QiZhang[newIndexs[i]]
        if pai == mjValue then
            -- 偶尔会出现两个箭头显示的一起显示
            self:add_qi_zhang(self.mySeat, mj, newIndexs[i] > #playerState.QiZhang - (playerState.ChuPaiCnt + 1), true, mjValue .. "")
        end
        -- 哥哥你位置改了啊
        -- self:insert_mj_by_pai(colorMj, mjValue, mj)
    end
end

-- 出牌的时候先落地，补花。有可能别人会胡
function TableView:chu_pai_add_qi_zhang_huapai(pai)
    -- pai = gameState.HuaPai[1] .. ""
    local newChilds = {}
    local seatHolder = self.seatHolderArray[1]
    local localSeat = 1
    local huaChilds = TableUtil.get_all_child(seatHolder.huaPoint)
    local index = 1
    local seatInfo = self.seatHolderArray[localSeat]
    local isHuaPai = false

    if self.movePointerMj then
        local movePointer = ComponentUtil.Find(self.movePointerMj, "MovePointer")
        ComponentUtil.SafeSetActive(movePointer, false)
    end

    local showBuHua = true
    if (playerState and playerState.piaohuacfgnew == 2) then
        showBuHua = false
    end

    for i = 1, #gameState.HuaPai do
        if (pai .. "" == gameState.HuaPai[i] .. "" and showBuHua) then
            isHuaPai = true
            if (seatInfo.gender == 1) then
                self:play_voice("malesound_ntcp/man_buhua")
            else
                self:play_voice("femalesound_ntcp/woman_buhua")
            end
            ComponentUtil.SafeSetActive(seatInfo.huaAnimation, true)
            local buhua = TableUtil.poor("BuHuaTX", seatInfo.huaAnimation, Vector3.zero, self.poorObjs, self.clones)
            self:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
                self.poorObjs = TableUtil.add_poor(buhua, self.poorObjs, self.cloneParent)
            end)
            break
        end
    end

    if isHuaPai then
        local playerState = gameState.Player[self.mySeat + 1]
        table.insert(playerState.HuaPai, pai)
        for i = 1, #playerState.HuaPai do
            -- 花牌
            local mj = nil
            if (i <= #huaChilds) then
                mj = huaChilds[i]
            else
                mj = TableUtil.poor(localSeat .. "_HuaMJ", seatHolder.huaPoint, Vector3.New(0, 0, 0), self.poorObjs, self.clones)
            end
            mj.transform.localPosition = seatHolder.huaMjBeginPos + Vector3.New(-outGridCell[localSeat][1] * (i - 1), 0, 0)

            ComponentUtil.SafeSetActive(mj, true)
            if mj.activeSelf then
                table.insert(newChilds, mj)
                --TableUtil.set_changpai_color(mj, Color.New(180 / 255, 255 / 255, 0 / 255, 0.9))
                local huapaiData = playerState.HuaPai[i]
                self:insert_mj_by_pai(colorMj, huapaiData, mj)
                TableUtil.new_set_changpai(huapaiData, mj)
            end
        end

        --TableUtil.invert_mj_pos(newChilds, #newChilds, playerState.HuaPai, localSeat == 4)
    end

    return isHuaPai
end

-- 模拟出牌，用于减少手中牌。为了避免闪的情况，并且客户端不好排序，所以打出去的牌先空一个位置
function TableView:simulate_chu_mj()
    --[[local seatHolder = self.seatHolderArray[1]
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    local index = 1
    for i = 1, #rightChildren do
        -- 手张
        local mj = rightChildren[i]
        if (mj.activeSelf) then
            mj.transform.localPosition = seatHolder.inMjBeginPos + Vector3.New((index - 1) * rightWidthOffset[1], 0, 0)
            index = index + 1
        end
    end--]]
end

-- 显示吃碰杠等按钮
function TableView:refresh_wait_action()
    self.showWaitAction = false
    self.canHu = false
    self.TingPaiState = 0 -- TingPaiState = 1 开局可听    TingPaiState = 2 牌局过程中的可以听
    ComponentUtil.SafeSetActive(self.waitAction, false)
    for i = 1, #self.waitActions do
        ComponentUtil.SafeSetActive(self.waitActions[i], false)
    end

    if #gameState.KeChi > 0 then
        ComponentUtil.SafeSetActive(self.waitActions[4], true)
        self.showWaitAction = true
    end
    if #gameState.KePeng > 0 then
        ComponentUtil.SafeSetActive(self.waitActions[5], true)
        self.showWaitAction = true
    end
    if #gameState.KeGang > 0 then
        ComponentUtil.SafeSetActive(self.waitActions[6], true)
        self.showWaitAction = true
    end
    if #gameState.KeBuHua > 0 then
        ComponentUtil.SafeSetActive(self.waitActions[7], true)
        self.showWaitAction = true
    end
    if #gameState.KeHu > 0 then
        ComponentUtil.SafeSetActive(self.waitActions[1], true)
        self.showWaitAction = true
        self.canHu = true
    end
    --KeTingBeg  开局可听    KeLiang 牌局过程中的可以听
    if (gameState.KeTingBeg or (#gameState.KeLiang > 0 and (self.wanfaName == "利辛麻将" or self.wanfaName == "涡阳麻将" or self.wanfaName == "蒙城麻将"))) then
        ComponentUtil.SafeSetActive(self.waitActions[2], true)
        self.showWaitAction = true
        if gameState.KeTingBeg then
            self.TingPaiState = 1
        else
            self.TingPaiState = 2
        end
    end
    if self.showWaitAction then
        ComponentUtil.SafeSetActive(self.waitAction, true)
        ComponentUtil.SafeSetActive(self.waitActions[#self.waitActions], true)
    end
    --[[if gameState.KeDiaoDui and #gameState.KeDiaoDui > 0 then
        ComponentUtil.SafeSetActive(self.waitActions[3], true)
        self.showWaitAction = true
    end]]
    ComponentUtil.SafeSetActive(self.sanKouObj, gameState.bpcs and #gameState.bpcs > 0)
    if (gameState.bpcs and #gameState.bpcs > 0) then
        ComponentUtil.SafeSetActive(self.openSanKouObj, self:sankou_is_open())
        ComponentUtil.SafeSetActive(self.closeSanKouObj, not self:sankou_is_open())
    end
end

function TableView:sankou_is_open()
    for i = 1, #gameState.bpcs do
        local sanKouData = gameState.bpcs[i]
        if (sanKouData.change) then
            return true
        end
    end
    return false
end

--- 实时刷新牌局
function TableView:show_time()
    if self.kickedTimeId then
        CSmartTimer:Kill(self.kickedTimeId)
        self.kickedTimeId = nil
    end
    local localSeat = TableUtil.get_local_seat(gameState.CurPlayer, self.mySeat, totalSeat)
    if (not curTableData.isPlayBack) then
        self:showClockState(localSeat)
    end
    if(self.timerSum>0) then
        self.kickedTimeId = self:subscibe_time_event(self.timerSum, false, 1):OnUpdate(function(t)
            t = t.surplusTimeRound
            self.clockTimeText.text = string.format("%02d", t)
            if (t == 3) then
                if (gameState.Result == 0) then
                    self:play_voice("common/timedown")
                end
            end
            local isKeChu = gameState and gameState.KeChu
            if t == 0 and isKeChu then
                if (self.openShake) then
                    ModuleCache.GameSDKInterface:ShakePhone(1000)
                end
            end
            if(t < 0) then
                self.clockTimeText.text = "00"
            end
            --end
        end):OnComplete(function(t)
        end).id
    else
        self.clockTimeText.text = "00"
    end
end

-- 房间内用户上线
function TableView:refresh_user_online(data)
    local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(data.SeatID, self.mySeat, totalSeat, TableManager.seatNumTable)]
    --ComponentUtil.SafeSetActive(seatHolder.imageDisconnect, false)
    --ComponentUtil.SafeSetActive(seatHolder.imageLeave, false)
    --seatHolder.ip = data.IP
    --seatHolder.appendData = data.AppendData]]
    if (data.AppendData and data.AppendData ~= "") then
        local locationStr = string.split(data.AppendData, ",")
        if (not seatHolder.locationData and #locationStr > 0) then
            seatHolder.locationData = {
                latitude = tonumber(locationStr[1]),
                longitude = tonumber(locationStr[2]),
                address = locationStr[3],
            }
        end
    end
    self:update_gps()
end

-- 房间内用户离线
function TableView:refresh_user_offline(data)
    --[[local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(data.SeatID, self.mySeat, totalSeat, TableManager.seatNumTable)]
    ComponentUtil.SafeSetActive(seatHolder.imageDisconnect, true)
    ComponentUtil.SafeSetActive(seatHolder.imageLeave, false)
    seatHolder.ip = 0]]
end

function TableView:look_player_info(obj)
    local seatHolder = self:get_click_local_seat(obj)
    if (seatHolder) then
        if (curTableData.isPlayBack) then
            self:play_back_switch_player(seatHolder)
            return
        end
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfo", seatHolder)
    end
end

function TableView:get_click_local_seat(obj)
    for i = 1, #self.seatHolderArray do
        if (self.seatHolderArray[i].imagePlayerHead.gameObject == obj) then
            return self.seatHolderArray[i]
        end
    end
    return nil
end

-- 上传玩家状态
function TableView:refresh_report_state(data)
    local localSeat = TableUtil.get_local_seat(data.SeatID, self.mySeat, totalSeat, TableManager.seatNumTable)
    local seatHolder = self.seatHolderArray[localSeat]
    ComponentUtil.SafeSetActive(seatHolder.imageLeave, localSeat ~= 1 and data.State and data.State == 1)
    ComponentUtil.SafeSetActive(seatHolder.imageDisconnect, localSeat ~= 1 and data.State and data.State == 2)

    --self.chuPai_infoArray[localSeat].disconnectStateObj:SetActive(localSeat ~= 1 and data.State and data.State == 2)
    --self.chuPai_infoArray[localSeat].leaveStateObj:SetActive(localSeat ~= 1 and data.State and data.State == 1)

    if (curTableData.RoomType == 2) then
        ComponentUtil.SafeSetActive(seatHolder.buttonKick, localSeat ~= 1 and data.State and data.State == 2 and (not gameState or (gameState and gameState.CurRound == 0) ) )
    end
end

-- 刷新用户状态
function TableView:refresh_user_state(data)
    self:update_ready(data)
    curTableData.serverIsNew = true --(data.randomseat == 1) 全是新版本了
    self.openRandomSeat = (data.randomseat == 1 and gameState == nil)
    local randomType = data.msgtype
    self:update_back_button_state()
    if (randomType == 1) then
        print("随机中 。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。")
        --ComponentUtil.SafeSetActive(self.ImageRandom, true)
        self.randomSeat = true
        for i = 1, #data.State do
            local newSeatID = data.State[i].SeatID
            local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(i - 1, self.mySeat, totalSeat)]
            local randomMJ = TableUtil.poor("RandomMJ", seatHolder.randomMJPos, Vector3.zero, self.poorObjs, self.clones)
            TableUtil.new_set_changpai(newSeatID, randomMJ)
            ComponentUtil.SafeSetActive(seatHolder.paiMJ, false)
            ComponentUtil.SafeSetActive(seatHolder.imageReady, false)
            self:ready_random_seat()
            self:subscibe_time_event(3.4, false, 0):OnComplete(function(t)
                self.poorObjs = TableUtil.add_poor(randomMJ, self.poorObjs, self.cloneParent)
                if (self.randomSeat) then
                    self.randomSeat = false
                    self:delay_random_user_state(data)
                    if (gameState) then
                        self:refresh_game_state(gameState)
                    end
                    self:show_zun(data.State[i], i)
                end
            end)
        end
    else
        self:delay_random_user_state(data)
    end
end

function TableView:ready_random_seat()
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        ComponentUtil.SafeSetActive(seatHolder.piaoSprite.transform.parent.gameObject, false)
        ComponentUtil.SafeSetActive(seatHolder.zunSprite.transform.parent.gameObject, false)
        ComponentUtil.SafeSetActive(seatHolder.waiZun, false)
        seatHolder.textScore.text = ""
        seatHolder.huShuText.text = ""
        seatHolder.seatRoot.transform:SetParent(seatHolder.readySeatHolder)
        ComponentUtil.SafeSetActive(seatHolder.beginUI, false)
        seatHolder.textPlayerName.transform.anchoredPosition = Vector3.New(0, -12, 0)
        seatHolder.seatRoot.transform.anchoredPosition = Vector3.New(0, 0, 0)
    end
end

function TableView:update_ready(data)
    for i = 1, #data.State do
        local SeatID = data.State[i].SeatID
        local localSeat = TableUtil.get_local_seat(SeatID, self.mySeat, totalSeat)
        local seatHolder = self.seatHolderArray[localSeat]
        seatHolder.ready = data.State[i].Ready
        ComponentUtil.SafeSetActive(seatHolder.imageReady, data.State[i].Ready)
        print(tostring(SeatID).."是否准备："..tostring(seatHolder.ready))
        if (seatHolder.ready) then
            if (SeatID == self.mySeat) then
                if (gameState and gameState.Result == 1) then
                    self:reset_seat_all_mj()
                    ModuleCache.SoundManager.stop_all_sound()
                end
                ComponentUtil.SafeSetActive(self.buttonBegin, false)
                self.buttonInvite.transform.anchoredPosition = Vector3.New(-200, self.buttonInvite.transform.anchoredPosition.y, 0)
                self.buttonExit.transform.anchoredPosition = Vector3.New(200, self.buttonExit.transform.anchoredPosition.y, 0)
            end
        elseif (SeatID == self.mySeat and gameState == nil) then
            ComponentUtil.SafeSetActive(self.inviteAndExit, true)
            ComponentUtil.SafeSetActive(self.buttonBegin, true)
            self.buttonInvite.transform.anchoredPosition = Vector3.New(-440, self.buttonInvite.transform.anchoredPosition.y, 0)
            self.buttonExit.transform.anchoredPosition = Vector3.New(440, self.buttonExit.transform.anchoredPosition.y, 0)
        end
    end
    local allReady = self:all_is_ready()
    if (self.inviteAndExit.activeSelf) then
        ComponentUtil.SafeSetActive(self.inviteAndExit, not allReady)
    end
    self:update_gps()
    for i = 1, #data.State do
        local SeatID = data.State[i].SeatID
        local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(SeatID, self.mySeat, totalSeat)]
        if (allReady) then
            ComponentUtil.SafeSetActive(seatHolder.buttonKick, false)
        end
    end
end

function TableView:show_zun(state, i)
    if (self.wanfaName == "宿松麻将" and state.SeatID == self.mySeat and state.PiaoType == 1) then
        local zunCount = 0
        if (gameState) then
            zunCount = gameState.zunnum
        end
        if (zunCount < 5) then
            ComponentUtil.SafeSetActive(self.selectZun, true)
            for i = 1, 6 do
                ComponentUtil.SafeSetActive(self.selectZunChilds[i + 6], i - 1 < zunCount)
                ComponentUtil.SafeSetActive(self.selectZunChilds[i], not (i - 1 < zunCount))
            end
        end
    end
    if (state.SeatID == self.mySeat and state.PiaoType == 1) then
        if (self.wanfaName == "青阳平胡" or self.wanfaName == "青阳辣子") then
            ModuleCache.ModuleManager.show_module("majiang", "tablepop")
        end
    end
end

-- 等待随机座位结束
function TableView:delay_random_user_state(data)
    self.userState = data
    print("我之前的座位：" .. self.mySeat)
    print(totalSeat)
    local isRandom = false
    for i = 1, #data.State do
        if (TableManager.seatNumTable[i] ~= data.State[i].SeatID) then
            TableManager.seatNumTable[i] = data.State[i].SeatID
            isRandom = true
        end
    end
    if (isRandom) then
        self.mySeat = TableManager.seatNumTable[self.mySeat + 1]
        curTableData.SeatID = self.mySeat
        print("我之后的座位：" .. self.mySeat)
    end
    curTableData.seatUserIdInfo = {}
    self:update_seat_pointer()
    for i = 1, #data.State do
        local SeatID = data.State[i].SeatID
        if (data.State[i].UserID ~= "0") then
            curTableData.seatUserIdInfo[SeatID .. ""] = data.State[i].UserID
        end
        self:refresh_seat_info(data.State[i], self.mySeat)
        local localSeat = TableUtil.get_local_seat(SeatID, self.mySeat, totalSeat)
        local seatHolder = self.seatHolderArray[localSeat]
        --ComponentUtil.SafeSetActive(seatHolder.paiMJ, self.openRandomSeat)
        if (seatHolder.ready) then
            if (data.State[i].PiaoType == 0) then
                if (SeatID == self.mySeat) then
                    ComponentUtil.SafeSetActive(self.selectZun, false)
                    if (ModuleCache.ModuleManager.module_is_active("majiang", "tablepop")) then
                        ModuleCache.ModuleManager.hide_module("majiang", "tablepop")
                    end
                end
            elseif (not self.randomSeat) then
                self:show_zun(data.State[i], i)
            end
        end
    end
    local allReady = self:all_is_ready()
    -- if(not self.randomSeat) then
    --     ComponentUtil.SafeSetActive(self.ImageRandom, not allReady)
    -- end
    ComponentUtil.SafeSetActive(self.beginTopLeft, allReady or gameState ~= nil)
    ComponentUtil.SafeSetActive(self.readyTopLeft, not allReady and gameState == nil)
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        if (allReady or gameState ~= nil) then
            seatHolder.seatRoot.transform:SetParent(seatHolder.seatParent.transform)
            ComponentUtil.SafeSetActive(seatHolder.beginUI, true)
            seatHolder.textPlayerName.transform.anchoredPosition = Vector3.New(0, -40, 0)
        else
            seatHolder.textScore.text = ""
            seatHolder.huShuText.text = ""
            seatHolder.seatRoot.transform:SetParent(seatHolder.readySeatHolder)
            ComponentUtil.SafeSetActive(seatHolder.beginUI, false)
            seatHolder.textPlayerName.transform.anchoredPosition = Vector3.New(0, -12, 0)
        end
        seatHolder.seatRoot.transform.anchoredPosition = Vector3.New(0, 0, 0)
    end
    for i = 1, #data.State do
        local SeatID = data.State[i].SeatID
        local seatHolder = self.seatHolderArray[TableUtil.get_local_seat(SeatID, self.mySeat, totalSeat)]
        --ComponentUtil.SafeSetActive(seatHolder.piaoSprite.transform.parent.gameObject, false)
        ComponentUtil.SafeSetActive(seatHolder.zunSprite.transform.parent.gameObject, false)
        ComponentUtil.SafeSetActive(seatHolder.showAdd1.gameObject, false)
        ComponentUtil.SafeSetActive(seatHolder.showAdd2.gameObject, false)
        if (allReady) then
            ComponentUtil.SafeSetActive(seatHolder.buttonKick, false)
            if (data.State[i].PiaoType == 0) then
                if (self.wanfaName == "宿松麻将" and data.State[i].PiaoNum ~= -1) then
                    ComponentUtil.SafeSetActive(seatHolder.zunSprite.transform.parent.gameObject, true)
                    seatHolder.zunSprite.sprite = seatHolder.ZunSH:FindSpriteByName(data.State[i].PiaoNum .. "")
                    seatHolder.zunSprite:SetNativeSize()
                end
                if ((self.ruleJsonInfo.YouPao or self.ruleJsonInfo.XiaPao) and data.State[i].Pao ~= -1 and data.State[i].Pao < 100000) then
                    ComponentUtil.SafeSetActive(seatHolder.showAdd1, true)
                    seatHolder.showAdd1Text.text = data.State[i].Pao .. "跑"
                end
            end
        end
        ComponentUtil.SafeSetActive(seatHolder.waiZun, self.wanfaName == "宿松麻将" and allReady and data.State[i].PiaoType == 1)
    end

    --self.diceShow = false
    --if (data.DiceType) then
    --    self.diceShow = true
    --    ComponentUtil.SafeSetActive(self.diceObj, true)
    --    ComponentUtil.SafeSetActive(self.diceAni.gameObject, true)
    --    ComponentUtil.SafeSetActive(self.diceImage1.gameObject, false)
    --    ComponentUtil.SafeSetActive(self.diceImage2.gameObject, false)
    --    self.diceAni:Play(0)
    --    self:subscibe_time_event(self.diceAni.duration + 0.1, false, 0):OnComplete(function(t)
    --        ComponentUtil.SafeSetActive(self.diceAni.gameObject, false)
    --        ComponentUtil.SafeSetActive(self.diceImage1.gameObject, true)
    --        ComponentUtil.SafeSetActive(self.diceImage2.gameObject, true)
    --        if (gameState) then
    --            self.diceImage1.sprite = self.diceImage1SH:FindSpriteByName(gameState.Dice1 .. "")
    --            self.diceImage2.sprite = self.diceImage2SH:FindSpriteByName(gameState.Dice2 .. "")
    --            self:subscibe_time_event(1.2, false, 0):OnComplete(function(t)
    --                ComponentUtil.SafeSetActive(self.diceObj, false)
    --                self.diceShow = false
    --                self:refresh_game_state(gameState)
    --            end)
    --        else
    --            ComponentUtil.SafeSetActive(self.diceObj, false)
    --        end
    --    end)
    --end

end

-- 所有人都准备好了
function TableView:all_is_ready()
    local allReady = true
    for i = 1, #self.seatHolderArray do
        if (not self.seatHolderArray[i].ready and self.seatHolderArray[i].enable) then
            allReady = false
            break
        end
    end
    return allReady
end

-- 获取被踢者的名字
function TableView:get_kick_player_name(obj)
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        if (obj == seatHolder.buttonKick) then
            return seatHolder.playerId, seatHolder.textPlayerName.text
        end
    end
end

-- 刷新座位信息
function TableView:refresh_seat_info(data, mySeat)
    if (not mySeat) then
        mySeat = self.mySeat
    end
    local localSeat = TableUtil.get_local_seat(data.SeatID, mySeat, totalSeat)
    local seatHolder = self.seatHolderArray[localSeat]
    --local chuPaiInfo = self.chuPai_infoArray[localSeat]
    seatHolder.SeatID = data.SeatID
    seatHolder.playerId = data.UserID or "0"
    if (not data.UserID or data.UserID == "0") then
        ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, false)
        ComponentUtil.SafeSetActive(seatHolder.imageReady, false)
        ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown, true)
        seatHolder.locationData = nil
        self:update_gps()
    else
        if (not curTableData.seatUserIdInfo) then
            curTableData.seatUserIdInfo = {}
        end
        curTableData.seatUserIdInfo[data.SeatID .. ""] = data.UserID
        if (curTableData.isPlayBack) then
            seatHolder.seatRoot.transform:SetParent(seatHolder.seatParent.transform)
            ComponentUtil.SafeSetActive(seatHolder.beginUI, true)
            seatHolder.textPlayerName.transform.anchoredPosition = Vector3.New(0, -40, 0)
        end

        if localSeat == 1 then
            ComponentUtil.SafeSetActive(seatHolder.imageLeave, false)
            ComponentUtil.SafeSetActive(seatHolder.imageDisconnect, false)
            --chuPaiInfo.leaveStateObj:SetActive(false)
            --chuPaiInfo.disconnectStateObj:SetActive(false)
        else
            -- 侯哥又帮你解决个BUG
            -- 这个函数会被多次调用，有时是没有data.State值的
            if data.State then
                ComponentUtil.SafeSetActive(seatHolder.imageLeave, data.State == 1)
                ComponentUtil.SafeSetActive(seatHolder.imageDisconnect, data.State == 2)
                --chuPaiInfo.leaveStateObj:SetActive(data.State == 1)
                --chuPaiInfo.disconnectStateObj:SetActive(data.State == 2)
            end
        end
        ComponentUtil.SafeSetActive(seatHolder.goSeatInfo, true)
        ComponentUtil.SafeSetActive(seatHolder.buttonNotSeatDown, false)
        --curTableData.RoomType == 2为快速组局，快速组局没有踢人功能   curTableData.RoomType == 3为比赛场，没有踢人
        if (data.SeatID ~= 0 and mySeat == 0 and gameState == nil and curTableData.RoomType ~= 2 and curTableData.RoomType ~= 3) then
            ComponentUtil.SafeSetActive(seatHolder.buttonKick, true)
        end
        if (data.AppendData and data.AppendData ~= "") then
            local locationStr = string.split(data.AppendData, ",")
            if (not seatHolder.locationData and #locationStr > 0) then
                seatHolder.locationData = {
                    latitude = tonumber(locationStr[1]),
                    longitude = tonumber(locationStr[2]),
                    address = locationStr[3],
                }
            end
        end
        TableUtil.download_seat_detail_info(data.UserID, function(playerInfo)
            if self.isDestroy then
                -- 要注意缓存回调时有可能view已经销毁了
                return
            end
            seatHolder.imagePlayerHead.sprite = playerInfo.headImage
            --chuPaiInfo.iconImage.sprite = playerInfo.headImage
        end, function(playerInfo)
            if self.isDestroy then
                -- 要注意缓存回调时有可能view已经销毁了
                return
            end
            seatHolder.textPlayerName.text = Util.filterPlayerName(playerInfo.playerName, 10)
            --chuPaiInfo.nameText.text = seatHolder.textPlayerName.text
            seatHolder.gender = playerInfo.gender
            seatHolder.ip = playerInfo.ip
            self:update_gps()
        end)
    end
end

function TableView:update_back_button_state()
    self.leftButtonBackText.text = self:check_is_exit_room() and "退出房间" or "解散房间"
end
---检测是否是 可退出房间状态还是可解散房间状态
function TableView:check_is_exit_room()
    local state = (gameState == nil or gameState.CurRound <= 0) and not self:all_is_ready()
    return state
end

function TableView:update_gps()
    if self.isDestroy then
        -- 要注意缓存回调时有可能view已经销毁了
        return
    end
    if (self.ruleJsonInfo.anticheat and not self:all_is_ready()) then
        return
    end
    local data = {}
    data.gameType = "majiang"
    data.seatHolderArray = self.seatHolderArray
    data.buttonLocation = self.buttonWarning
    data.roomID = curTableData.RoomID
    data.tableCount = totalSeat
    data.isPlay = self:all_is_ready()
    data.isShowLocation = false
    ModuleCache.ModuleManager.show_module("henanmj", "tablelocation", data);
end

-- 计算距离
function TableView:caculate_distance(seatInfo1, seatInfo2)
    if (seatInfo1.locationData.latitude ~= 0 and seatInfo2.locationData.latitude ~= 0) then
        local distance = TableUtil.caculate_distance(seatInfo1.locationData.latitude, seatInfo1.locationData.longitude,
        seatInfo2.locationData.latitude, seatInfo2.locationData.longitude)

        local distanceShow = math.ceil(distance) .. "米"
        if distance < 10 then
            distanceShow = "小于10米"
        end
        if distance >= 1000 then
            distanceShow = string.format("%.0f", distance / 1000) .. "公里"
        end
        --print("距离：------- " .. distance)
        local tip = "玩家:<color=#b13a1f>" .. seatInfo1.textPlayerName.text .. "</color>与<color=#b13a1f>" .. seatInfo2.textPlayerName.text .. "</color>距离为:" .. distanceShow .. "\n"
        return tip
    end
    return ""
end

function TableView:get_gps_warn_text(checkPlayer)
    local showText = ""
    local tipText = ""
    local distanceText = ""
    local tip = ""
    if (#checkPlayer == 2) then
        local index1 = checkPlayer[1]
        local index2 = checkPlayer[2]
        local seatInfo1 = self.seatHolderArray[index1]
        seatInfo1.locationData = self:check_location_data(seatInfo1.locationData)
        if (seatInfo1.locationData.latitude == 0) then
            tip = "玩家:<color=#b13a1f>" .. seatInfo1.textPlayerName.text .. "</color>" .. seatInfo1.locationData.address .. "\n"
            showText = showText .. tip
            tipText = tipText .. tip
        end
        local seatInfo2 = self.seatHolderArray[index2]
        seatInfo2.locationData = self:check_location_data(seatInfo2.locationData)
        if (seatInfo2.locationData.latitude == 0) then
            tip = "玩家:<color=#b13a1f>" .. seatInfo2.textPlayerName.text .. "</color>" .. seatInfo2.locationData.address .. "\n"
            showText = showText .. tip
            tipText = tipText .. tip
        end

        if seatInfo1.ip == seatInfo2.ip then
            tip = "玩家:<color=#b13a1f>" .. seatInfo1.textPlayerName.text .. "</color>与<color=#b13a1f>" .. seatInfo2.textPlayerName.text .. "</color> IP地址相同\n"
            showText = showText .. tip
            tipText = tipText .. tip
        end
        tip = self:caculate_distance(seatInfo1, seatInfo2)
        distanceText = distanceText .. tip
        showText = showText .. tip

    elseif (#checkPlayer == 3) then
        for i = 2, #checkPlayer do
            local seatInfo1 = self.seatHolderArray[i]
            seatInfo1.locationData = self:check_location_data(seatInfo1.locationData)
            if (seatInfo1.locationData.latitude == 0 and i == 2) then
                tip = "玩家:<color=#b13a1f>" .. seatInfo1.textPlayerName.text .. "</color>" .. seatInfo1.locationData.address .. "\n"
                showText = showText .. tip
                tipText = tipText .. tip
            end
            for j = i + 1, #checkPlayer + 1 do
                local seatInfo2 = self.seatHolderArray[j]
                seatInfo2.locationData = self:check_location_data(seatInfo2.locationData)

                if seatInfo1.ip == seatInfo2.ip then
                    tip = "玩家:<color=#b13a1f>" .. seatInfo1.textPlayerName.text .. "</color>与<color=#b13a1f>" .. seatInfo2.textPlayerName.text .. "</color> IP地址相同\n"
                    showText = showText .. tip
                    tipText = tipText .. tip
                end
                tip = self:caculate_distance(seatInfo1, seatInfo2)
                distanceText = distanceText .. tip
                showText = showText .. tip
            end
        end
    end
    if (tipText == "") then
        tipText = "没有IP地址相同的玩家\n所有玩家已开启位置信息。"
    end
    if (distanceText == "") then
        distanceText = "没有位置距离信息"
    end
    return showText, tipText, distanceText
end

function TableView:check_location_data(data)
    if (not data) then
        data = {}
    end
    if (not data.address) then
        data.address = "未开启获取位置功能"
        data.latitude = 0
        data.longitude = 0
    end
    return data
end

function TableView:show_chat_bubble(seat, content)
    print("123123")
    local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat, TableManager.seatNumTable)
    local seatInfo = self.seatHolderArray[seat]
    local seatRoot = seatInfo.seatRoot
    local chatBubble = GetComponentWithPath(seatRoot, "State/Group/ChatBubble", ComponentTypeName.RectTransform).gameObject
    local chatFace = GetComponentWithPath(seatRoot, "State/Group/ChatFace", ComponentTypeName.RectTransform).gameObject
    local chatText = nil
    print("3453543")
    if seat == 1 or seat == 4 then
        chatText = GetComponentWithPath(chatBubble, "TextBgLeft/Text", ComponentTypeName.Text)
    elseif seat == 2 or seat == 3 then
        chatText = GetComponentWithPath(chatBubble, "TextBgRight/Text", ComponentTypeName.Text)
    end
    print("chatText : " .. chatText.transform.name)
    chatText.text = TableUtil.cut_text(self.widthText, content, 400)
    print("67867887")
    chatBubble:SetActive(true)
    chatFace:SetActive(false)
    if seatInfo.timeChatEventId then
        CSmartTimer:Kill(seatInfo.timeChatEventId)
        seatInfo.timeChatEventId = nil
    end
    seatInfo.timeChatEventId = self:subscibe_time_event(3, false, 0):OnComplete(function(t)
        chatBubble:SetActive(false)
    end).id
    print("0000000")
end

function TableView:update_seat_location(seat, locationData)
    local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat)
    local seatInfo = self.seatHolderArray[seat]
    seatInfo.locationData = locationData
    self:update_gps()
end

function TableView:show_chat_face(seat, content)
    local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat, TableManager.seatNumTable)
    local seatInfo = self.seatHolderArray[seat]
    local seatRoot = seatInfo.seatRoot
    local chatBubble = GetComponentWithPath(seatRoot, "State/Group/ChatBubble", ComponentTypeName.RectTransform).gameObject
    local chatFace = GetComponentWithPath(seatRoot, "State/Group/ChatFace", ComponentTypeName.RectTransform).gameObject
    local image = ModuleCache.ComponentManager.GetComponent(chatFace, ComponentTypeName.Image)
    local spriteHolder = ModuleCache.ComponentManager.GetComponent(chatFace, "SpriteHolder")
    -- if(spriteHolder) then
    --    image.sprite = spriteHolder:FindSpriteByName((content - 1) .. "")
    --end
    local faceObj = TableUtil.get_all_child(chatFace)

    for i = 1, #faceObj do
        faceObj[i]:SetActive(i == content)
    end

    chatFace:SetActive(true)
    chatBubble:SetActive(false)
    if seatInfo.timeChatEventId then
        CSmartTimer:Kill(seatInfo.timeChatEventId)
        seatInfo.timeChatEventId = nil
    end
    seatInfo.timeChatEventId = self:subscibe_time_event(3, false, 0):OnComplete(function(t)
        chatFace:SetActive(false)
    end).id
end

function TableView:show_voice(seat)
    local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat, TableManager.seatNumTable)
    local seatInfo = self.seatHolderArray[seat]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(true)
end

function TableView:hide_voice(seat)
    local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat, TableManager.seatNumTable)
    local seatInfo = self.seatHolderArray[seat]
    local seatRoot = seatInfo.seatRoot
    local voice = GetComponentWithPath(seatRoot, "State/Group/Speak", ComponentTypeName.RectTransform).gameObject
    voice:SetActive(false)
end

function TableView:show_shot_voice(index, seat)
    local seat = TableUtil.get_local_seat(seat, self.mySeat, totalSeat, TableManager.seatNumTable)
    local seatInfo = self.seatHolderArray[seat]
    local voiceName = ""
    if (seatInfo.gender and seatInfo.gender == 1) then
        self:play_voice("femalesound_ntcp/" .. "fix_msg_" .. index)
    else
        self:play_voice("malesound_ntcp/" .. "fix_msg_" .. index)
    end
end

function TableView:play_voice(path)
    local array = string.split(path, "/")
    ModuleCache.SoundManager.play_sound("changpai", "changpai/sound/" .. path .. ".bytes", array[#array])
end

function TableUtil:play_common_voice(path)
    local array = string.split(path, "/")
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/" .. path .. ".bytes", array[#array])
end

function TableView:inviteWeChatFriend()
    if (ModuleCache.GameManager.iosAppStoreIsCheck) then
        return
    end
    local shareData = {}
    shareData.type = 2
    shareData.roomId = curTableData.RoomID .. ""
    shareData.rule = self.gamerule
    shareData.ruleName = curTableData.RoundCount .. "局 " .. self.ruleName
    shareData.title = self.wanfaName
    shareData.userID = self.modelData.roleData.userID
    if (curTableData.HallID > 0) then
        shareData.parlorId = curTableData.HallID .. ""
        shareData.roomType = curTableData.RoomType
    else
        shareData.roomType = 0
    end

    if (curTableData.RoomType == 3) then
        -- 比赛场分享
        shareData.type = 4
        shareData.matchId = curTableData.MatchID
    elseif curTableData.RoomType == 2 then
        --快速组局
        shareData.parlorId = shareData.parlorId .. string.format("%03d", ModuleCache.GameManager.curGameId)
    end
    shareData.totalPlayer = curTableData.totalSeat
    shareData.totalGames = curTableData.RoundCount
    shareData.curPlayer = curTableData.curPlayer
    shareData.comeIn = 0

    print("--------------share-----------shareData.type:", shareData.type, shareData.parlorId, shareData.matchId)
    ModuleCache.ShareManager().shareRoomNum(shareData, false)
end

function TableView:play_action_sound(action, seatInfo)
    local sound = mCPGHLClipName["" .. action]
    --local sound = sounds[math.random(#sounds)]
    print(action, "-------------play_action_sound:", sound)

    if 6 == action or 8 == action then

    end

    if (seatInfo.gender == 1) then
        self:play_voice("malesound_ntcp/man_" .. sound)
    else
        self:play_voice("femalesound_ntcp/woman_" .. sound)
    end
end

function TableView:get_seat_id(seatInfo)
    for i = 1, #self.seatHolderArray do
        if (seatInfo == self.seatHolderArray[i]) then
            return i
        end
    end
end

-- 回放选择玩家显示数据
function TableView:play_back_switch_player(seatHolder)
    local seatID = seatHolder.SeatID
    self.mySeat = seatID
    curTableData.SeatID = seatID
    self:refresh_user_state(self.userState)
    self:refresh_game_state(gameState)
end

function TableView:Init_MaiMaPanel(data)
    self.contents = TableUtil.get_all_child(self.MaiMaCopyParent)
    local item = {}
    item[1] = nil
    for i = 2, #self.contents do
        UnityEngine.GameObject.Destroy(self.contents[i])
        item[i] = nil
    end
    self.MaiMaPanel:SetActive(true)
    for i = 1, #data.MaiMa do
        item[i] = TableUtil.clone(self.MaiMaCopyItem, self.MaiMaCopyParent, UnityEngine.Vector3.zero)
        local anim = GetComponent(item[i].gameObject, "UnityEngine.Animator")
        TableUtil.new_set_changpai(data.MaiMa[i], item[i])
        self:subscibe_time_event(i * 0.1, false, 0):OnComplete(function(t)
            anim.enabled = true
            for j = 1, #data.ZhongMa do
                local idx = data.ZhongMa[j] + 1
                if idx == i then
                    self:subscibe_time_event(0.05, false, 0):OnComplete(function(t)
                        GetComponentWithPath(item[idx], "HighLight", ComponentTypeName.Transform).gameObject:SetActive(true)
                    end)
                end
            end
        end)
    end
end

function TableView:get_hua(pai, mj)
    if (self.guoYangHuaMJ) then
        return self.guoYangHuaMJ
    end
    for i = 1, #gameState.HuaPai do
        if (pai == gameState.HuaPai[i]) then
            return mj
        end
    end
    return nil
end

---切换牌显示新牌老牌
function TableView:change_pai_layout(mj)
    local imgObj1 = GetComponentWithPath(mj, "Image", ComponentTypeName.Transform).gameObject
    local imgObj2 = GetComponentWithPath(mj, "Image2", ComponentTypeName.Transform).gameObject
    if (self:isNewLayout()) then
        ComponentUtil.SafeSetActive(imgObj1, false)
        ComponentUtil.SafeSetActive(imgObj2, true)
    else
        ComponentUtil.SafeSetActive(imgObj1, true)
        ComponentUtil.SafeSetActive(imgObj2, false)
    end
    TableUtil.set_ting_tag_pos(imgObj1)
    TableUtil.set_ting_tag_pos(imgObj2)
end


---对牌的表现切换操作 obj:是image/image2的父对象
---@param obj UnityEngine.GameObject
---@param op number
function TableView:change_opration(obj, op)
    if (op == 1) then
        --切换布局
        self:change_pai_layout(obj)
    elseif (op == 2) then
        --切换简繁
        TableUtil.new_set_mj_jian_fan(obj)
    elseif (op == 3) then
        --切换翻转
        TableUtil.new_set_mj_fanzhuan(obj)
    end
end

---@param op number
function TableView:change_info(op)
    local shoupaiPath = "Up"
    local shoupai = TableUtil.get_all_child(self.seatHolderArray[1].rightPoint)
    --- 自己手牌
    for i = 1, #shoupai do
        local upObj = GetComponentWithPath(shoupai[i], shoupaiPath, ComponentTypeName.Transform).gameObject
        self:change_opration(upObj, op)
    end
    for i = 1, #self.seatHolderArray do
        --- 下张
        local leftCards = TableUtil.get_all_child(self.seatHolderArray[i].leftPoint)
        for j = 1, #leftCards do
            local childs = TableUtil.get_all_child(leftCards[j])
            for k = 1, #childs do
                self:change_opration(childs[k], op)
            end
        end
        --- 弃张
        local outCards = TableUtil.get_all_child(self.seatHolderArray[i].outPoint)
        for j = 1, #outCards do
            self:change_opration(outCards[j], op)
        end
        --- 当前出的牌
        local curCard = GetComponentWithPath(self.seatHolderArray[i].chuMJPos, "ChuMJ", ComponentTypeName.Transform)
        if curCard then
            self:change_opration(curCard.gameObject, op)
        end
        -- 特殊牌没有简繁区别
        ---- 花牌（喜牌）
        local xipai = TableUtil.get_all_child(self.seatHolderArray[i].huaPoint)
        for j = 1, #xipai do
            self:change_opration(xipai[j], op)
        end
        --- 叫牌或撂龙
        ------------------------ 南通长牌 start ------------------------
        local jiaopaiChildren = TableUtil.get_all_child(self.seatHolderArray[i].jiaopai)
        for j = 1, #jiaopaiChildren do
            for k = 0, 3 do
                local jiaopai = GetComponentWithPath(jiaopaiChildren[j], "Pai/" .. k, ComponentTypeName.Transform).gameObject
                self:change_opration(jiaopai, op)
            end
        end

        if curTableData.isPlayBack and self.seatHolderArray[i].handPoint then
            local handChildren = TableUtil.get_all_child(self.seatHolderArray[i].handPoint)
            for j = 1, #handChildren do
                self:change_opration(handChildren[j], op)
            end
        end
        ------------------------ 南通长牌 end ------------------------
    end
    ------------------------ 南通长牌 start ------------------------
    for i = 1, #self.jiangPai do
        self:change_opration(self.jiangPai[i], op)
    end

    local huChildren = TableUtil.get_all_child(self.huGrid)
    for i = 2, #huChildren do
        self:change_opration(huChildren[i], op)
    end
    ------------------------ 南通长牌 end ------------------------
    self:change_jiaopai_panel_layout()
end

---叫牌位置修改   --花牌的数据修改在set_player_state
function TableView:change_jiaopai_layout()
    local angles = 0
    local py = -116
    local startY = -30
    local offset = -60
    local otherOffset = -48
    if (self:isNewLayout()) then
        angles = -90
        py = -84
        offset = -20
    end
    for i = 1, #self.seatHolderArray do
        if (i == 1) then
            local jiaopaiChildren = TableUtil.get_all_child(self.seatHolderArray[1].jiaopai)
            for j = 1, #jiaopaiChildren do
                local jiaoP = jiaopaiChildren[j]
                if (self.isNewLayout()) then
                    jiaoP.transform.localPosition = Vector3.New(0, -260 * (j - 1), 0)
                else
                    jiaoP.transform.localPosition = Vector3.New(xiaZhangWidth[1] * (j - 1), 0, 0)
                end
                for k = 0, 3 do
                    local jiaopai = GetComponentWithPath(jiaopaiChildren[j], "Pai/" .. k, ComponentTypeName.Transform).gameObject
                    local jianImage = GetComponentWithPath(jiaopaiChildren[j], "Image", ComponentTypeName.Transform).gameObject
                    jiaopai.transform.localPosition = Vector3.New(0, startY + (k * offset), 0)
                    jianImage.transform.localEulerAngles = Vector3.New(0, 0, angles)
                    jianImage.transform.localPosition = Vector3.New(0, py, 0)
                end
            end
        elseif (i == 2 or i == 4) then
            local jiaopaiChildren = TableUtil.get_all_child(self.seatHolderArray[i].jiaopai)
            for j = 1, #jiaopaiChildren do
                local jiaoP = jiaopaiChildren[j]
                jiaoP.transform.localPosition = Vector3.New(0, -xiaZhangWidth[i] * (j - 1), 0)
                --for k = 0, 3 do
                --    local jiaopai = GetComponentWithPath(jiaopaiChildren[j], "Pai/" .. k, ComponentTypeName.Transform).gameObject
                --    jiaopai.transform.localPosition = Vector3.New(0, (3-k)*otherOffset, 0)
                --end
            end
        end
    end
end


---刷新弃牌位置
function TableView:change_qipai_layout()
    for i = 1, #self.seatHolderArray do
        local seatHolder = self.seatHolderArray[i]
        local outChilds = TableUtil.get_all_child(seatHolder.outPoint)
        for j = 1, #outChilds do
            local mj = outChilds[j]
            if (i == 1 or i == 3) then
                local myXPos = outGridCell[i][1] * ((j - 1) % myOutGridNum)
                local space = (j-1)%myOutGridNum
                if(space>=myQiZhangSpaceNum) then
                    myXPos = myXPos+myQiZhangOffset
                end
                mj.transform.localPosition = seatHolder.outMjBeginPos + Vector3.New(myXPos,
                outGridCell[i][2] * math.floor((j - 1) / myOutGridNum), 0)
            else
                mj.transform.localPosition = seatHolder.outMjBeginPos + Vector3.New(outGridCell[i][1] * math.floor((j - 1) / outGridNum),
                outGridCell[i][2] * ((j - 1) % outGridNum), 0)
            end
        end
    end
end

---切换手牌显示位置
function TableView:change_hand_pai_layout()
    local playerState = gameState.Player[self.mySeat + 1]
    local seatHolder = self.seatHolderArray[1]
    local rightChildren = TableUtil.get_all_child(seatHolder.rightPoint)
    local xCount = 1
    local yCount = 1
    local jiaoPaiOffset = #playerState.JiaoPai
    local liaoLongOffset = #playerState.LiaoLong
    if (self.isNewLayout()) then
        jiaoPaiOffset = 0
        liaoLongOffset = 0
    end

    local handCenterOffset = (liaoLongOffset + jiaoPaiOffset + #playerState.XiaZhang - 2) * xiaZhangWidth[1]
    if handCenterOffset < 0 then
        handCenterOffset = 0
    end
    local hasMoZhang = (self.seatHolderArray[1].mopai or #playerState.HuPai ~= 0)
    local mySelfHandData = TableUtil.processMyHandMjData(playerState.ShouZhang, hasMoZhang, self:isNewLayout())
    local temp = {}
    for i = #rightChildren, 1, -1 do
        table.insert(temp, rightChildren[i])
    end
    rightChildren = temp

    for i = 1, #rightChildren do
        local mj = rightChildren[i]
        if (mj.activeSelf) then
            local pai = self:get_mj_pai(mj)
            local shouZhangInfo = mySelfHandData[xCount]
            local xOffset = (xCount - 1) * rightWidthOffset[1] + handCenterOffset
            local yOffset = (yCount - 1) * myHightOffset
            local subCount = hasMoZhang and 2 or 1
            local totalOffset = (#mySelfHandData - subCount) * rightWidthOffset[1]
            mj.transform.localPosition = seatHolder.inMjBeginPos + Vector3.New(xOffset, yOffset, 0) - Vector3.New(totalOffset / 2, 0, 0)
            local isLastMoZhang = xCount == #mySelfHandData and (seatHolder.mopai or #playerState.HuPai ~= 0)
            if isLastMoZhang then
                if ((not playerState.HuPai or #playerState.HuPai == 0) and self:is_me_chu_mj(mj)) then
                    mj.transform.position = self.chuPosObj.transform.position
                    mj.transform.localPosition = mj.transform.localPosition + Vector3.New(0, moOffset, 0)
                end
            end
            if (string.find(mj.name, "readyChuMJ_")) then
                mj.transform.localPosition = mj.transform.localPosition + Vector3.New(0, 20, 0)
            end
            yCount = yCount + 1
            if yCount > #shouZhangInfo then
                yCount = 1
                xCount = xCount + 1
            end
        end
    end
end

function TableView:change_xiazhang_layout()
    for i = 1, #gameState.Player do
        local playerState = gameState.Player[i]
        local localSeat = TableUtil.get_local_seat(i - 1, self.mySeat, totalSeat)
        local seatHolder = self.seatHolderArray[localSeat]
        if (localSeat == 1) then
            local playerState = gameState.Player[i]
            local jiaoPaiOffset = #playerState.JiaoPai
            local liaoLongOffset = #playerState.LiaoLong
            if (self.isNewLayout()) then
                jiaoPaiOffset = 0
                liaoLongOffset = 0
            end
            local leftChilds = TableUtil.get_all_child(seatHolder.leftPoint)
            local count = 0
            --TableUtil.print_obj_root_path(seatHolder.leftPoint)
            for j = 1, #leftChilds do
                if (leftChilds[j].gameObject.activeSelf) then
                    local x = (liaoLongOffset + jiaoPaiOffset + count) * xiaZhangWidth[1] * xiaZhangScale[1]
                    leftChilds[j].transform.localPosition = Vector3.New(x, 0, 0)
                    count = count + 1
                end
            end
        else
            local leftChilds = TableUtil.get_all_child(seatHolder.leftPoint)
            local huaOffset = 0
            if(#playerState.HuaPai>0) then
                huaOffset = 1
            end
            local count = #playerState.JiaoPai+#playerState.LiaoLong+huaOffset
            for j = 1, #leftChilds do
                if (leftChilds[j].gameObject.activeSelf) then
                    local y = (count) * xiaZhangWidth[localSeat] * xiaZhangScale[1]
                    leftChilds[j].transform.localPosition = Vector3.New(0, -y, 0)
                    count = count + 1
                end
            end
        end
    end
end

function TableView:change_jiaopai_panel_layout()
    local jiaoPaiPanel = GetComponentWithPath(self.root, "Bottom/Child/NanTongJiaoOrLiao", ComponentTypeName.RectTransform).gameObject
    TableUtil.only_change_pai(jiaoPaiPanel)
end


---根据布局方式显示牌
function TableView:change_layout()
    if (gameState == nil) then
        return
    end
    self:newViewLayout()
    self:change_hand_pai_layout()---刷新手牌位置
    self:change_qipai_layout()---刷新弃牌位置
    self:change_jiaopai_layout()
    self:change_xiazhang_layout()
    self:change_jiaopai_pos()
    ComponentUtil.SafeSetActive(self.jianObj, self.modelData.fan)
    ComponentUtil.SafeSetActive(self.fanObj, not self.modelData.fan)
    ComponentUtil.SafeSetActive(self.buttonFanzhuan.gameObject, self.modelData.fan or self.isNewLayout())
    self:change_info(1)
end


--- 切换简繁体
function TableView:change_jian_fan()
    ComponentUtil.SafeSetActive(self.jianObj, self.modelData.fan)
    ComponentUtil.SafeSetActive(self.fanObj, not self.modelData.fan)
    ComponentUtil.SafeSetActive(self.buttonFanzhuan.gameObject, self.modelData.fan or self.isNewLayout())
    self:change_info(2)
end

--- 翻转长牌
function TableView:fanzhuan()
    self:change_info(3)
end

---@return  获取桌面所有已显示的牌，包括自己的手牌
function TableView:get_all_show_cards()

end

function TableView:on_destroy()
    Manager.KillSmartTimer(self.timerEventId)
end

return TableView