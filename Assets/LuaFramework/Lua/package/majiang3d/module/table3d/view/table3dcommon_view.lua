--- 3D麻将 普通玩法 view
--- Created by 袁海洲
--- DateTime: 2017/12/25 14:18
---
local TableManager = TableManager
local ModuleCache = ModuleCache
local AppData = AppData
local Config = Config
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local TableUtil = TableUtil
local Vector3 = Vector3
local GameObject = UnityEngine.GameObject


local class = require("lib.middleclass")
local ViewBase = require('package.majiang3d.module.table3d.table3d_view')
--- @class Table3dCommonView:Table3dView
local Table3dCommonView = class('table3dCommonView', ViewBase)

local Mj3d = require("package.majiang3d.module.table3d.Mj3d")
local Mj3dPool = require("package.majiang3d.module.table3d.Mj3dPool")
local Mj3dDun = require("package.majiang3d.module.table3d.Mj3dDun")
local Mj3dCenterCom = require("package.majiang3d.module.table3d.Mj3dCenterCom")
local SeatHolder3D =  require('package.majiang3d.module.table3d.seat.seatholder3d')
local seatAnchors = {"BottomLeft", "Right", "Top", "Left"}
local Mj3dHelper = require("package.majiang3d.module.table3d.table3d_helper")

---初始化ui
function Table3dCommonView:init_ui()
    ViewBase.init_ui(self)
    self.gameController = GetComponentWithPath(self.root, "Center/Child/GameController", ComponentTypeName.Transform).gameObject
    self.ImageRandom = GetComponentWithPath(self.root, "Center/Child/ImageRandom", ComponentTypeName.Transform).gameObject
    self.timeDown = GetComponentWithPath(self.gameController, "TimeDown", ComponentTypeName.Transform).gameObject
    self.waitObj = GetComponentWithPath(self.gameController, "Wait", ComponentTypeName.Transform).gameObject
    self.timer1imgSprite = GetComponentWithPath(self.timeDown, "Image1", "SpriteHolder")
    self.timer2imgSprite = GetComponentWithPath(self.timeDown, "Image2", "SpriteHolder")
    self.timer1img = GetComponentWithPath(self.timeDown, "Image1", ComponentTypeName.Image)
    self.timer2img = GetComponentWithPath(self.timeDown, "Image2", ComponentTypeName.Image)
    self.pointerObj = GetComponentWithPath(self.root, "Center/Child/Pointer", ComponentTypeName.Transform).gameObject
    self.lightObj = GetComponentWithPath(self.gameController, "Light", ComponentTypeName.Transform).gameObject
    self.jushuObj = GetComponentWithPath(self.gameController, "JuShu", ComponentTypeName.Transform).gameObject
    self.jushu = GetComponentWithPath(self.gameController, "JuShu/Text", ComponentTypeName.Text)
    self.remain = GetComponentWithPath(self.gameController, "Remain/Text", ComponentTypeName.Text)
    self.remainAni = GetComponentWithPath(self.gameController, "Remain/Text", "UnityEngine.Animation")
    self.frontSpriteH = GetComponentWithPath(self.root, "Center/FrontSpriteH", "SpriteHolder")
    self.tagSpriteH = GetComponentWithPath(self.root, "Center/TagSpriteH", "SpriteHolder")
    self.ceSpriteH = GetComponentWithPath(self.root, "Center/CeSpriteH", "SpriteHolder")
    self.huTagSpriteH = GetComponentWithPath(self.root, "Center/HuTagSpriteH", "SpriteHolder")
    self.bigHuaSwitchState =  GetComponentWithPath(self.root, "Center/Child/ImageRandom", "UIStateSwitcher")
    self:on_init_ui()


    ---开始3D相关的初始化
    self.root3d = GetComponentWithPath(self.root, "Root3D", ComponentTypeName.Transform).gameObject
    self.disRtObj = GetComponentWithPath(self.root3d, "3DDisRt", ComponentTypeName.Transform).gameObject
    self.cam3d = GetComponentWithPath(self.root3d, "3DObjs/Cams/3DCam", ComponentTypeName.Camera)
    self.myHandMjCam = GetComponentWithPath(self.root3d, "3DObjs/Cams/myHandMjCam", ComponentTypeName.Camera)
    self.mj3dPoolRootTrans =  GetComponentWithPath(self.root3d, "3DObjs/Mj3dPoolRoot", ComponentTypeName.Transform)
    self.mj3dHodlerTrans =  GetComponentWithPath(self.root3d, "3DObjs/3DHodler/mj", ComponentTypeName.Transform)
    self.effectHodlerTrans =  GetComponentWithPath(self.root3d, "3DObjs/3DHodler/effect", ComponentTypeName.Transform)
    self.disOnScreenTrans = GetComponentWithPath(self.root3d, "3DObjs/Cams/DisOnScreenPoint", ComponentTypeName.Transform)
    self.disOnScreenPoints = TableUtil.get_all_child(self.disOnScreenTrans)
    self.disOnScreenCenterPointObj = GetComponentWithPath(self.root3d, "3DObjs/Cams/DisOnScreenCenterPoint", ComponentTypeName.Transform).gameObject

    Mj3d:Init() ---清空对激活麻将的清理
    local skinType = UnityEngine.PlayerPrefs.GetInt(string.format("%s_Mj3d_Skin",self.curTableData.ruleJsonInfo.GameType),1)
    Mj3d:switchAllMj3dSkinStyle(skinType)---初始化3d麻将皮肤样式

    Mj3dPool:Init(self.mj3dPoolRootTrans,self.mj3dHodlerTrans) ---初始化3D麻将子对象池
    self.Mj3dPool = Mj3dPool

    self.mj3dDunTrans =  GetComponentWithPath(self.root3d, "3DObjs/Duns", ComponentTypeName.Transform)
    Mj3dDun:Init(self,self.mj3dDunTrans) ---初始化墩控件
    self.Mj3dDun = Mj3dDun

    self.mj3dCenterComTrans =  GetComponentWithPath(self.root3d, "3DObjs/CenterCom", ComponentTypeName.Transform)
    Mj3dCenterCom:Init(self,self.mj3dCenterComTrans) ---初始化桌子中央控件
    self.Mj3dCenterCom = Mj3dCenterCom

    ---重载角标图集，使用3D麻将独立的角标，防止因为被打包在majiang图集中在真机上出现uv错乱的BUG
    self.tagSpriteH = GetComponentWithPath(self.root3d, "TagSpriteH", "SpriteHolder")

    ---左上角游戏信息
    self.gameInfoObj = GetComponentWithPath(self.root3d, "LeftTop/Child/GameInfo", ComponentTypeName.Transform).gameObject
    self.leftCountText = GetComponentWithPath(self.gameInfoObj, "LeftCountText", ComponentTypeName.Text)
    ---重载View的局数显示对象，局数显示对象在room type 中控制
    self.jushuObj = self.gameInfoObj
    self.jushu = GetComponentWithPath(self.gameInfoObj, "RoundCountText", ComponentTypeName.Text)

    self.cam3dPos = self.cam3d.transform.position
    self.cam3deulerAngles = self.cam3d.transform.eulerAngles

    local gameRoot = GameObject.Find("GameRoot")
    self.uiCamera = GetComponentWithPath(gameRoot, "Game/UIRoot/UICamera", "UnityEngine.Camera")

    ---------------同步3D摄像机与UI摄像机的rect,在一些特殊的屏幕长宽比下摄像机的rect会有变动
    self.cam3d.rect = self.uiCamera.rect
    self.myHandMjCam.rect = self.uiCamera.rect
    -----------------------------End-----------------------------------------

    ---------------适配3D摄像机在不同长宽比屏幕下的视野
    self.originWHRatio = 1280 / 720
    self.curWHRatio  = UnityEngine.Screen.width / UnityEngine.Screen.height
    if self.curWHRatio < self.originWHRatio then
        self.cam3d.fieldOfView = self.cam3d.fieldOfView * (self.originWHRatio / self.curWHRatio)
    end
    -----------------------------End-----------------------------------------
end

function Table3dCommonView:on_init_ui()
    self.bigHuaSwitchState:SwitchState("Normal")
end

---初始化所有的座位
function Table3dCommonView:init_seats()
    ViewBase.init_seats(self)
    self.pointerChilds = {}
    self.pointerObjs = TableUtil.get_all_child(self.pointerObj)
    self.lightChilds = TableUtil.get_all_child(self.lightObj)
    for i=1,4 do
        local seatPosTran = GetComponentWithPath(self.root, seatAnchors[i] .. "/Child/" .. i, ComponentTypeName.Transform).gameObject
        local seatHolder = SeatHolder3D:new(self, i)
        seatHolder:init(seatPosTran)
        self:init_seat(seatHolder, i)
        local pointerChild = GetComponentWithPath(self.pointerObjs[i], "Light", ComponentTypeName.Transform).gameObject
        table.insert(self.pointerChilds, pointerChild)
        table.insert(self.seatHolderArray, seatHolder)
    end
    ---@type Pool
    self.pool = require('package.majiang.module.tablenew.pool'):new(self.cloneParent)
end
---初始化单个座位
function Table3dCommonView:init_seat(seatHolder, seatIndex, seatPosTran)
    local point = GetComponentWithPath(self.root3d, "Center/Child/3dReadyImagePoint/"..tostring(seatIndex), ComponentTypeName.Transform).gameObject
    seatHolder.imageReady.transform.position = point.transform.position
end

---初始化自己座位事件
function Table3dCommonView:init_my_seat_event()
    self.seatHolderArray[1]:InitEvent()
end

--- 重置状态 点击继续游戏
function Table3dCommonView:reset_state()
    ViewBase.reset_state(self)
    self.Diceed = false
    Mj3dCenterCom:setTagActive(false)
    Mj3dCenterCom:setTimingText(nil)
    Mj3dDun:Clear()
end
function Table3dCommonView:update_ready_end()
    ViewBase.update_ready_end(self)
    self.gameInfoObj:SetActive(self.gameState ~= nil)
end
--- 开始刷新gameState
function Table3dCommonView:game_state_begin(gameState)
    ViewBase.game_state_begin(self, gameState)
    self.gameInfoObj:SetActive(true)
end

function Table3dCommonView:game_state_end()
    ViewBase.game_state_end(self)
    if 1 == self.gameState.Result  or 2 == self.gameState.Result then
        Mj3dHelper:getModule():begin_cache_game_state()
        self:playShowDun(self.gameState,function ()
            Mj3dHelper:getModule():end_cache_game_state()
        end)
    end

    ---判断是否需是最开始的发牌状态，如果是，就播放打色发牌动画
    if 0 ~= self.gameState.Dice1 and (not self.Diceed) then ---当Dice1非0时表示游戏刚开始，播放打筛和抓牌动画
        Mj3dHelper:getModule():begin_cache_game_state()
        Mj3dHelper:getModule():setTargetFrame(60)
        self:readyPlayDiceAndDealAni()
        self.baoPai:SetActive(false)
        Mj3dCenterCom:playDiceAni(self.gameState.Dice1,self.gameState.Dice2,function ()
            self:playDiceAndDealAni(self.gameState,function ()
                self.Diceed = true
                --self.uiCamera.gameObject:SetActive(false)
                self:playDisLaiGen(self.gameState,function ()
                    self.baoPai:SetActive(true)
                    local LaiZis = {}
                    if self.gameState.LaiZis and #self.gameState.LaiZis > 0 then
                        LaiZis = self.gameState.LaiZis
                    end
                    if #LaiZis > 0 then
                        self:displayMj3dOnScreenCenter(LaiZis,1)
                    end
                    self:playSortHandMj(self.seatHolderArray[1],function ()
                        --self.uiCamera.gameObject:SetActive(true)
                        self:endPlayDiceAndDealAni()
                        Mj3dHelper:getModule():setTargetFrame()
                        Mj3dHelper:getModule():end_cache_game_state()
                    end)
                end)
            end)
        end)
    end
end

--- 更新座位指向
function Table3dCommonView:update_seat_pointer()
    local masterSeat = self.gameState == nil and 0 or self.gameState.ZhuangJia
    Mj3dCenterCom:initWindTag(self:server_to_local_seat(masterSeat))
end

--- 手牌刷新之前
function Table3dCommonView:game_state_begin_hand(serverSeat)
    local localSeat = self:server_to_local_seat(serverSeat)
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder:begin_refresh_mj3d()
    self.dataIndexs = {}
end
--- 设置手牌 handData 手牌数据 localSeat 本地座位 index 位置索引 playerState 玩家整个数据 showHu 显示胡  lastMjMove 最后的牌是否偏移 dataIndex 数据索引
function Table3dCommonView:set_hand_data(params)
    local handData = params.handData
    local localSeat = params.localSeat
    local index = params.index
    local playerState = params.playerState
    local showHu = params.showHu
    local lastMjMove = params.lastMjMove
    local dataIndex = params.dataIndex

    local seatHolder = self.seatHolderArray[localSeat]
    ---添加手张
    params.mj3d = seatHolder:add_Hand_Mj(playerState,handData,index,showHu,lastMjMove,dataIndex)
end
--- 手牌刷新之后 serverSeat 服务器座位
function Table3dCommonView:game_state_end_hand(serverSeat)
    local localSeat = self:server_to_local_seat(serverSeat)
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder:end_refresh_mj3d(serverSeat,self.gameState)
end

---清空箭头标记
function Table3dCommonView:clearArrow()
    for i=1,#self.seatHolderArray do
        local hodler = self.seatHolderArray[i]
        hodler:clearArrow()
    end
end

--- 弃牌刷新之前 serverSeat 服务器座位
function Table3dCommonView:game_state_begin_out(serverSeat)
    self:clearArrow()
    local localSeat = self:server_to_local_seat(serverSeat)
    ---@type SeatHolder3D
    local seatHolder = self.seatHolderArray[localSeat]
    if(self.curTableData.isPlayBack) then
        seatHolder.mj3dHodler:clearThrow()
    end
    seatHolder:begin_update_out_mj()
end
--- 设置弃牌 outData 弃牌数据 localSeat 本地座位 outIndex 索引 showPointer 显示箭头 lastOut 最后出的一个牌 serverSeat 服务器座位 playerState 玩家数据
function Table3dCommonView:set_out_data(params)
    local outData = params.outData
    local localSeat = params.localSeat
    local outIndex = params.outIndex
    local showPointer = params.showPointer
    local lastOut = params.lastOut
    local serverSeat = params.serverSeat
    local playerState = params.playerState
    ---刷新弃张
    ---@type SeatHolder3D
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder:add_out_mj(outData,showPointer)
    if(params.lastOut) then
        self:play_voice("common/chupai")
    end
end
--- 弃牌刷新之后 serverSeat 服务器座位 curOutNum 当前弃牌数量 preOutNum 前次弃牌数量
function Table3dCommonView:game_state_end_out(params)
    local serverSeat = params.serverSeat
    local curOutNum = params.curOutNum
    local preOutNum = params.preOutNum
    local localSeat = self:server_to_local_seat(serverSeat)
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder:end_update_out_mj(curOutNum,preOutNum)
end

--- 刷新下张之前 serverSeat 服务器座位
function Table3dCommonView:game_state_begin_down(serverSeat)
    if(self.curTableData.isPlayBack) then
        local localSeat = self:server_to_local_seat(serverSeat)
        ---@type SeatHolder3D
        local seatHolder = self.seatHolderArray[localSeat]
        seatHolder.mj3dHodler:ClearKan()
    end
end
--- 刷新下张之后 changeType 0 不变 1 增加 2 减少 serverSeat 服务器座位
function Table3dCommonView:game_state_end_down(serverSeat, changeType)
    if 1 == changeType then
        local localSeat = self:server_to_local_seat(serverSeat)
        local seatHolder = self.seatHolderArray[localSeat]
        local kan =seatHolder.mj3dHodler.Kan[#seatHolder.mj3dHodler.Kan]
        --kan:playAddKanAni()
        self:play_add_down_effect(kan)
    end
end
--- 设置下张牌堆 downData 下张数据 localSeat 本地座位 serverSeat 服务器座位 downIndex 索引
function Table3dCommonView:set_down_data(params)
    local downData = params.downData
    local localSeat = params.localSeat
    local serverSeat = params.serverSeat
    local downIndex = params.downIndex
    ---刷新下张
    ---@type SeatHolder3D
    local seatHolder = self.seatHolderArray[localSeat]
    local playerState = self.gameState.Player[serverSeat + 1]  ---服务器的下标从0开始
    seatHolder:update_down_mj(playerState,localSeat)
end

---播放添加下张特效
function Table3dCommonView:play_add_down_effect(kan)
    local addKanEffectTemplate = GetComponentWithPath(self.effectHodlerTrans.gameObject,"chihupenggang", ComponentTypeName.Transform).gameObject
    local obj = GameObject.Instantiate(addKanEffectTemplate)
    obj.transform.parent = kan.gameObject.transform.parent
    obj.transform.position = kan.gameObject.transform.position
    obj.transform.localScale = Vector3(20,20,20)
    self:subscibe_time_event(1, false, 0):OnComplete(function()
        GameObject.Destroy(obj)
    end)
end

--- 花刷新之前 serverSeat 服务器座位
function Table3dCommonView:game_state_begin_hua(serverSeat)

end
--- 花牌刷新之后 serverSeat 服务器座位 curHuaNum 当前花牌数量 preHuaNum 前次花牌数量
function Table3dCommonView:game_state_end_hua(params)

end
--- 设置花牌 huaData 花牌数据 localSeat 本地座位 huaIndex 索引 playerState 玩家数据
function Table3dCommonView:set_hua_data(params)
    local huaData = params.huaData
    local localSeat = params.localSeat
    local huaIndex = params.huaIndex
    local playerState = params.playerState
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder:update_hua_mj(playerState)
end

---本地模拟添加花牌
function Table3dCommonView:local_simulation_add_hua(localSeat,pai)

end

---设置墩
function Table3dCommonView:game_state_dun()
    ---刷新墩
    local Dun = self.gameState.Dun
    self.leftCountText.text = tostring(#Dun)
    local TotalCount = self.gameState.TotalCount
    local DunStart = self.gameState.DunStart
    local dice1 =  self.gameState.Dice1
    local dice2 =  self.gameState.Dice2
    local serverIndex = self.gameState.ZhuangJia
    local leftDunCount = dice1 >= dice2 and dice2 or dice1 ---留墩的数量
    local isPlayDelAni = true
    Mj3dDun:refreshDuns(Dun,TotalCount,DunStart,serverIndex,leftDunCount,isPlayDelAni)
end

---回放模式下倒计时相关
function Table3dCommonView:game_state_pointer_play_back()
    Mj3dCenterCom:setTimingText(0,0)
end
---拦牌状态
function Table3dCommonView:game_state_wait_action()
    Mj3dCenterCom:setTimingText(nil)
    self:end_time_down()
    self.roomType:on_game_state_wait_action()
end
---光标指向对应玩家
function Table3dCommonView:game_state_pointer_player()
    local localTargetSeat = self:server_to_local_seat(self.gameState.CurPlayer)
    Mj3dCenterCom:refreshWindTagState(localTargetSeat)
    Mj3dCenterCom:setTagActive(true)
    self:begin_time_down(15, function (t)
        self:show_time_down(t)
        if(t == 3) then
            if(self.gameState.Result == 0) then
                self:play_voice("common/timedown")
            end
        end
        if t == 0 and self.gameState and self.gameState.KeChu then
            if(self.openShake) then
                ModuleCache.GameSDKInterface:ShakePhone(1000)
            end
        end
    end)
end
--- 显示倒计时
function Table3dCommonView:show_time_down(t)
    local tenValue  = math.floor(t/10)
    local unitValue = t % 10
    Mj3dCenterCom:setTimingText(tenValue,unitValue)
end

--- 打出普通牌
function Table3dCommonView:play_custom(pai, localSeat)
    local seatInfo = self.seatHolderArray[localSeat]
    if(self.mjSounds[tonumber(pai)]) then
        if(seatInfo.gender == 1) then
            self:play_voice("femalesound_hn/" .. string.lower(self.mjSounds[tonumber(pai)]))
        else
            self:play_voice("malesound_hn/" .. string.lower(self.mjSounds[tonumber(pai)]))
        end
    end
end

---准备播放发牌和打色动画
function Table3dCommonView:readyPlayDiceAndDealAni()
    for i=1,#self.seatHolderArray do
        local seat = self.seatHolderArray[i]
        seat.mj3dHodler:hideAllHandMj()
    end
    Mj3dDun:optDunMjs(1,#Mj3dDun.dunMj3ds,function (mj3d)
        mj3d:setMj3Active(true)
    end)
    self.guoBtnState = self.actionGuo.activeSelf
    self.waitActionState = self.waitAction.activeSelf
    self.actionGuo:SetActive(false)
    self.waitAction:SetActive(false)
end

function Table3dCommonView:endPlayDiceAndDealAni()
    self.actionGuo:SetActive(self.guoBtnState)
    self.waitAction:SetActive(self.waitActionState)
end

---播放打色，发牌动画
function Table3dCommonView:playDiceAndDealAni(gameState,callBack)
    local handMjCountInfo = {}
    local ZhuangJia = gameState.ZhuangJia
    local count = ZhuangJia + 1 ---服务器的座位下标从0开始
    for i=1,#gameState.Player do
        if count > #gameState.Player then
            count = 1
        end
        local player = gameState.Player[count]
        count = count + 1
        local info = {}
        info.count = #player.ShouZhang
        info.localSeatIndex = self:server_to_local_seat(count)
        info.optInidex = 1
        info.isCompate = false
        table.insert(handMjCountInfo,info)
    end
    local dunAniSpaceingTime = 0.02
    local indexOffset = gameState.DunStart
    count = 0
    local totalMjCount = #Mj3dDun.dunMj3ds - #gameState.Dun ---被玩家抓出去的牌
    local dunAniTotalTime = dunAniSpaceingTime * totalMjCount
    Mj3dDun:optDunMjs(indexOffset,indexOffset + totalMjCount,function (mj3d)
        mj3d:setMj3Active(true)
        self:subscibe_time_event(dunAniSpaceingTime * count, false, 0):OnComplete(function()
            mj3d:setMj3Active(false)
        end)
        count = count + 1
    end,true,true)
    for i=1,#handMjCountInfo do
        local info = handMjCountInfo[i]
        local seat = self.seatHolderArray[info.localSeatIndex]
        self:subscibe_time_event(0.2 * (i-1), false, 0):OnComplete(function()
            self:playOneSeatDealAni(seat)
        end)
    end
    self:subscibe_time_event(dunAniTotalTime + 0.5, false, 0):OnComplete(function()
        if callBack then
            callBack()
        end
    end)
end
---播放每个玩家单独发牌动画
function Table3dCommonView:playOneSeatDealAni(tableSeat)
    local handMj = tableSeat.mj3dHodler.HandMj
    local spaceing = 4
    local spaceingCount = 0
    local count = 0
    local dur = 0.2

    local hasMoZhang = false
    for i=1,#handMj do
        ---@type Mj3d
        local mj3d = handMj[i]
        if mj3d.transform.localPosition.y > 0 then
            hasMoZhang = true
            break
        end
    end
    tableSeat.mj3dHodler:showAllHandMj()
    handMj = tableSeat.mj3dHodler:disorderHandMj(hasMoZhang) ---乱序玩家手牌
    for i=1,#handMj do
        if count >= spaceing then
            count = 0
            spaceingCount = spaceingCount + 1
        end
        ---@type Mj3d
        local mj3d = handMj[i]
        mj3d:setMj3Active(false)
        mj3d:setTagState(false)
        local index  = count
        if mj3d.transform.localPosition.y <= 0 then
            self:subscibe_time_event(dur * spaceingCount, false, 0):OnComplete(function()
                mj3d:setMj3Active(true)
                mj3d.meshRootObj.transform.localEulerAngles = Vector3(-90,0,0)
                mj3d.meshRootObj.transform:DOLocalRotate(Vector3(0,0,0),dur)
                if 1 == tableSeat.seatId and 0 == index then
                    self:play_voice("common/fapai")
                end
            end)
        end
        count = count + 1
    end
    if hasMoZhang then
        spaceingCount = spaceingCount + 1
        self:subscibe_time_event(dur * spaceingCount, false, 0):OnComplete(function()
            local moZhangMj3d = tableSeat.mj3dHodler.HandMj[#tableSeat.mj3dHodler.HandMj]
            moZhangMj3d:setMj3Active(true)
            local transform = moZhangMj3d.meshRootObj.transform
            transform.localPosition = transform.localPosition + Vector3(0,-6,0)
            transform.localEulerAngles = Vector3(0,-20,0)
            transform:DOLocalMove(Vector3(0,0,0),0.25)
            transform:DOLocalRotate(Vector3(0,0,0),0.15)
        end)
        if 1 == tableSeat.seatId then
            self:subscibe_time_event(dur * spaceingCount, false, 0):OnComplete(function()
                self:play_voice("common/fapai")
            end)
        end
    end
end
----播放整理手牌排序动效
function Table3dCommonView:playSortHandMj(tableSeat,callBack)
    local handMj = tableSeat.mj3dHodler.HandMj
    local hasMoZhang = false
    for i=1,#handMj do
        if handMj[i].transform.localPosition.y > 0 then
            hasMoZhang = true
            break
        end
    end
    local total = #handMj
    for i=1,#handMj do
        local index = i
        local mj3d = handMj[index]
        if mj3d.transform.localPosition.y <= 0 then ---至少会有一张手牌
            mj3d.meshRootObj.transform.localEulerAngles = Vector3(0,0,0)
            mj3d.meshRootObj.transform:DOLocalRotate(Vector3(-90,0,0),0.25):OnComplete(function ()
                tableSeat.mj3dHodler:processHandMjLayout(hasMoZhang)
                mj3d:setTagState(true)
                mj3d.meshRootObj.transform:DOLocalRotate(Vector3(0,0,0),0.25)
            end)
        end
    end
    self:play_voice("common/lipai")
    self:subscibe_time_event(0.6, false, 0):OnComplete(function()
        if callBack then
            callBack()
        end
    end)
end

---在屏幕中间展示麻将 ,如果不传入time ，则不会触发callBack
function Table3dCommonView:displayMj3dOnScreenCenter(paiTable,time,callBack)
    self:hideDisplayMj3dOnScreenCenter() ---清理之前的数据
    local pos = self.disOnScreenCenterPointObj.transform.position --todo:获取屏幕中央展示麻将的锚点坐标
    local spaceing = 2.8 ---麻将横向摆放的间距
    local leftOffset = (#paiTable - 1) * (spaceing / 2)
    self.disOnScreenj3ds = {} ---缓存屏幕中央展示得麻将对象
    for i=1,#paiTable do
        local pai = paiTable[i]
        local curPos = Vector3((i-1) * spaceing - leftOffset,0,0)
        local mj3d = Mj3d:Create(pai,self.disOnScreenCenterPointObj.transform)
        mj3d.transform.localPosition = curPos
        local eulerAngles = self.myHandMjCam.transform.eulerAngles
        eulerAngles.x = eulerAngles.x - 110
        mj3d.gameObject.transform.eulerAngles = eulerAngles
        mj3d:setLayer(14)
        mj3d:setKuangEffectState(true)
        table.insert(self.disOnScreenj3ds,mj3d)
    end
    if time then
        self:subscibe_time_event(time, false, 0):OnComplete(function()
            self:hideDisplayMj3dOnScreenCenter()
            if callBack then
                callBack()
            end
        end)
    end
end
---隐藏屏幕中央展示的麻将
function Table3dCommonView:hideDisplayMj3dOnScreenCenter()
    if self.disOnScreenj3ds then
        for i=1,#self.disOnScreenj3ds do
            Mj3dHelper:clearMj3d(self.disOnScreenj3ds[i])
        end
    end
    self.disOnScreenj3ds = nil
end

---播放番癞子动画
function Table3dCommonView:playDisLaiGen(gameState,callBack)
    local laiGen = 0
    if gameState.LaiGens and #gameState.LaiGens > 0 then
        laiGen = gameState.LaiGens[1]
    end
    if 0 == laiGen then
        if callBack then
            callBack()
        end
        return
    end
    local lastIndex = Mj3dDun:getLastDelDunMjIndex()
    if 0 == lastIndex % 2 then
        lastIndex = lastIndex + 1
        if lastIndex >  #Mj3dDun.dunMj3ds then
            lastIndex = 1
        end
    end
    local anchorMj = Mj3dDun.dunMj3ds[lastIndex]
    ---@type Mj3d
    local disMj3d = Mj3d:Create(laiGen,Mj3dDun.rootTrans)
    disMj3d.transform.position = anchorMj.transform.position
    disMj3d.transform.eulerAngles = anchorMj.transform.eulerAngles
    disMj3d:setMj3dState(Mj3d.mj3dState.hlight)
    local effectObj = self:play_3d_effect("DaPai",nil,disMj3d.transform.position,Mj3dDun.rootTrans)
    self.cam3d.gameObject.transform.position = disMj3d.transform.position

    if "2" == anchorMj.transform.parent.parent.name then
        self.cam3d.gameObject.transform.localPosition = self.cam3d.gameObject.transform.localPosition + Vector3(15,13,5)
        self.cam3d.gameObject.transform.eulerAngles = Vector3(34,-110,0)
    elseif "3" == anchorMj.transform.parent.parent.name then
        self.cam3d.gameObject.transform.localPosition = self.cam3d.gameObject.transform.localPosition + Vector3(0,18,-23)
        self.cam3d.gameObject.transform.eulerAngles = Vector3(34,0,0)
    else
        self.cam3d.gameObject.transform.localPosition = self.cam3d.gameObject.transform.localPosition + Vector3(8,18,-23)
        self.cam3d.gameObject.transform.eulerAngles = Vector3(34,-20,0)
    end

    self.seatHolderArray[1].mj3dHodler:hideAllHandMj()
    self:subscibe_time_event(2,false, 0):OnComplete(function()
        self.cam3d.gameObject.transform.position = self.cam3dPos
        self.cam3d.gameObject.transform.eulerAngles = self.cam3deulerAngles
        self.seatHolderArray[1].mj3dHodler:showAllHandMj()
        Mj3dHelper:clearMj3d(disMj3d)
        GameObject.Destroy(effectObj)
        if callBack then
            callBack()
        end
    end)
end
---播放3D特效 ,time 多长时间后删除特效 不传则永不删除， worldPos 为世界坐标系 , parent 特效被创建后的父级对象
function Table3dCommonView:play_3d_effect(effectName,time,worldPos,parent)
    local effect = GetComponentWithPath(self.effectHodlerTrans.gameObject,effectName, ComponentTypeName.Transform).gameObject
    local obj = GameObject.Instantiate(effect)
    obj.transform.parent = parent
    obj.transform.position = worldPos
    obj.transform.localScale = Vector3.one
    if time then
        self:subscibe_time_event(time, false, 0):OnComplete(function()
            GameObject.Destroy(obj)
        end)
    end
    return obj
end

---播放结算是否展示墩的动效
Table3dCommonView.showDunTimeSpaceing = 0.05
function Table3dCommonView:playShowDun(gameState,callback)
    local dun = gameState.Dun
    local OptSeats = {1,2,3,4}
    --[[if 2 == self.curTableData.ruleJsonInfo.PlayerNum then
        OptSeats = {1,3}
    elseif 3 == self.curTableData.ruleJsonInfo.PlayerNum then
        OptSeats = {1,2,4}
    elseif 4 == self.curTableData.ruleJsonInfo.PlayerNum then
        OptSeats = {1,2,3,4}
    end--]]
    --OptSeats = {1,2,3,4}
    local curSeat = 1
    local dunTotal = #dun
    local lastDelDunMjIndex =  Mj3dDun:getLastDelDunMjIndex()
    for i=1,dunTotal do
        local index = i
        local pai = dun[index]
        ---@type SeatHolder3D
        local seatHolder = self.seatHolderArray[OptSeats[curSeat]]
        self:subscibe_time_event(self.showDunTimeSpaceing * (i-1), false, 0):OnComplete(function()
            ---@type Mj3dThrowMj
            local mj3dthrow = seatHolder.mj3dHodler.Throw
            ---@type Mj3d
            local mj3d = mj3dthrow:AddThrowMj(pai,false)
            mj3d:setMj3dState(Mj3d.mj3dState.gray)
            mj3dthrow:processLayout(seatHolder.mj3dHodler.thorwMjRowMaxCount)
            local realIndex = lastDelDunMjIndex - index
            if realIndex < 1 then
                realIndex = gameState.TotalCount + realIndex
            end
            Mj3dDun:delDunMj(realIndex)
            if index == dunTotal then
                if callback then
                    callback()
                end
            end
        end)
        curSeat = curSeat + 1
        if curSeat > #OptSeats then
            curSeat = 1
        end
    end
end

return Table3dCommonView
