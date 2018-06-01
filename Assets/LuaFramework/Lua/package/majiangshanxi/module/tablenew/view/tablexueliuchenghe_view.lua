
--- 血流成河
local class = require("lib.middleclass")
local Base = require('package.majiangshanxi.module.tablenew.view.tablecommon_view')
---@class TableXueLiuChengHeView:TableCommonView
local TableXueLiuChengHeView = class('tableXueLiuChengHeView', Base)
local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local TableUtil = TableUtil
local Vector3 = Vector3
local DG = DG
local lastMJOffset = 20
local Color = Color
---@type Mj2DManager
local MjManager = require('package.majiangshanxi.module.tablenew.mj2d_manager')
---@type Mj2D
local Mj2D = require('package.majiangshanxi.module.tablenew.mj.mj2d')

function TableXueLiuChengHeView:init_ui()
    Base.init_ui(self)
    self.xlszObj = GetComponentWithPath(self.root, "Left/Child/XLSZ", ComponentTypeName.Transform).gameObject
    self.xlszGrid = GetComponentWithPath(self.root, "Left/Child/XLSZ/Grid", ComponentTypeName.Transform).gameObject
    self.xlszChilds = TableUtil.get_all_child(self.xlszGrid)
    self.xlszTitleText = GetComponentWithPath(self.root, "Left/Child/XLSZ/ImageText", ComponentTypeName.Text)
    self.buttongHuanSZ = GetComponentWithPath(self.root, "Bottom/Child/Button_Huan", ComponentTypeName.Transform).gameObject
    self.buttongHuanSZDisable = GetComponentWithPath(self.root, "Bottom/Child/Button_HuanDisable", ComponentTypeName.Transform).gameObject
    self.huanSanzTip = GetComponentWithPath(self.root, "Center/Child/HuanTip", ComponentTypeName.Transform).gameObject
end

function TableXueLiuChengHeView:on_init_ui()
    self.bigHuaSwitchState:SwitchState("BigHua")
end

--- 初始化单个座位
function TableXueLiuChengHeView:init_seat(seatHolder, index)
    seatHolder.sanZObj = GetComponentWithPath(self.root, "Center/Child/ImageRandom/SanZ/" .. index, ComponentTypeName.Transform).gameObject
    seatHolder.sanZPos = seatHolder.sanZObj.transform.localPosition
    seatHolder.sanzObjChilds = TableUtil.get_all_child(seatHolder.sanZObj)
    if(index ~= 1) then
        seatHolder.sanzTipObj =  GetComponentWithPath(seatHolder.seatPosTran, "SanzTip", ComponentTypeName.Transform).gameObject
    end
end

---开始设置玩家状态（gameState）
function TableXueLiuChengHeView:game_state_begin_set_player_state(playerState, localSeat, serverSeat)
    Base.game_state_begin_set_player_state(self, playerState, localSeat, serverSeat)
    local seatHolder = self.seatHolderArray[localSeat]
    seatHolder.sanZObj:SetActive(self.gameState.SanZhangType == 0 and #playerState.SanZhang > 0)
    if(seatHolder.sanZObj.activeSelf) then
        seatHolder.sanZObj.transform.localPosition = seatHolder.sanZPos
        for i = 1, #seatHolder.sanzObjChilds do
            local mj = Mj2D:new(0, nil, {gameObject = seatHolder.sanzObjChilds[i]})
            mj.state = 1
            mj:set_skin(self.mjColorSet, self.mjScaleSet)
            MjManager.insert(mj, MjManager.mjType.custom)
        end
        if(localSeat == 1) then
            self.buttongHuanSZ:SetActive(false)
            self.buttongHuanSZDisable:SetActive(false)
            self.huanSanzTip:SetActive(false)
        end
    end
    if(localSeat == 1) then
        if(playerState.SanZhangToOther and #playerState.SanZhangToOther > 0) then
            self.xlszObj:SetActive(true)
            local titles = {"换下家","换上家","换对家"}
            local huanType = 1
            for j = 1, #playerState.SanZhangToOther do
                local data = playerState.SanZhangToOther[j]
                huanType = data.type
                ---@type Mj2D
                local mj = Mj2D:new(data.pai, nil, {gameObject = self.xlszChilds[j], spriteHolder = self.frontSpriteH})
                mj:set_skin(self.mjColorSet, self.mjScaleSet)
                MjManager.insert(mj, MjManager.mjType.custom)
            end
            self.xlszTitleText.text = titles[huanType]
        end
    end
    self.selectSanZ = false --- 我在选三张（不能刷新自己的手牌）
    if(self.gameState.HuanSanZhang and #playerState.SanZhang == 0) then
        if(localSeat == 1) then
            self.selectSanZ = true
        else
            seatHolder.sanzTipObj:SetActive(true)
        end
    elseif(localSeat ~= 1) then
        seatHolder.sanzTipObj:SetActive(false)
    end
end

--- 手牌刷新之前 serverSeat 服务器座位
function TableXueLiuChengHeView:game_state_begin_hand(serverSeat)
    if(not self.beginGame and self.selectSanZ and serverSeat == self.mySeat) then
        return
    end
    Base.game_state_begin_hand(self, serverSeat)
end

--- 设置手牌 handData 手牌数据 localSeat 本地座位 index 位置索引 playerState 玩家整个数据 showHu 显示胡  lastMjMove 最后的牌是否偏移 dataIndex 数据索引
function TableXueLiuChengHeView:set_hand_data(params)
    if(not self.beginGame and self.selectSanZ and params.localSeat == 1) then
        return
    end
    Base.set_hand_data(self, params)
end

function TableXueLiuChengHeView:get_action_tx(action)
    if(action == self.actions.mingGang or action == self.actions.anGang or action == self.actions.dianGang) then
        return 200 + action
    end
    return Base.get_action_tx(self, action)
end

---显示听牌标志
function TableXueLiuChengHeView:show_ting_pai_tag(localSeat, show)

end

--- 设置花牌 huaData 花牌数据 localSeat 本地座位 huaIndex 索引 playerState 玩家数据
function TableXueLiuChengHeView:set_hua_data(params)
    self:set_common_data(params)
    local mj = params.seatHolder.mjHeapHua:add_mj(params)
    if(self:is_laizi(mj.pai)) then
        mj:set_lai_zi(false, self.ConfigData.laiziTag or 4)
    else
        local huTagImage = GetComponentWithPath(mj.gameObject, "HuTag/Image", ComponentTypeName.Image)
        local huTag = GetComponentWithPath(mj.gameObject, "HuTag", ComponentTypeName.Transform).gameObject
        huTag:SetActive(true)
        local isZiMo = params.playerState.hupais[params.huaIndex].zimo
        if(isZiMo) then
            huTagImage.sprite = self.huTagSpriteH:FindSpriteByName("0")
        else
            huTagImage.sprite = self.huTagSpriteH:FindSpriteByName(params.playerState.hupais[params.huaIndex].pao .. "")
        end
        huTagImage:SetNativeSize()
    end
end

--- 小结算时需要播放胡音效
function TableXueLiuChengHeView:play_hu_sound_on_result()
    return false
end

--- 可以显示过
function TableXueLiuChengHeView:can_show_guo()
    return not (#self.gameState.Player[self.mySeat + 1].HuaPai > 0 and self.actionHu.activeSelf)
end

--- 是否是观察者模式
function TableXueLiuChengHeView:is_observer_mode()
    return self.isHuanSanZhang or Base.is_observer_mode(self)
end

--- 换三张 callback 刚换完牌之后的回调 callback1 我换来的三张牌插入动画之后的回调
function TableXueLiuChengHeView:huan_san_zhang(gameState, callback, callback1)
    local height = 224
    self.isHuanSanZhang = true
    self.waitHSZ = false
    if(gameState.SanZhangType == 1) then --顺时针
        for i = 1, #self.seatHolderArray do
            local seatHolder = self.seatHolderArray[i]
            local pathVectors = {}
            for j = 1, 5 do
                local x,y=0
                if(i == 1) then
                    y = -height+(height/5)*j
                    x = -self:get_ellipse_x(y)
                elseif(i == 2) then
                    y = -(height/5)*j
                    x = self:get_ellipse_x(y)
                elseif(i == 3) then
                    y = height-(height/5)*j
                    x = self:get_ellipse_x(y)
                elseif(i == 4) then
                    y = (height/5)*j
                    x = -self:get_ellipse_x(y)
                end
                table.insert(pathVectors, Vector3.New(x,y,0))
            end
            seatHolder.sanZObj.transform:DOLocalPath(pathVectors, 1, DG.Tweening.PathType.CatmullRom)
        end
    elseif(gameState.SanZhangType == 2) then
        for i = 1, #self.seatHolderArray do
            local seatHolder = self.seatHolderArray[i]
            local pathVectors = {}
            for j = 1, 5 do
                local x,y=0
                if(i == 1) then
                    y = -height+(height/5)*j
                    x = self:get_ellipse_x(y)
                elseif(i == 2) then
                    y = (height/5)*j
                    x = self:get_ellipse_x(y)
                elseif(i == 3) then
                    y = height-(height/5)*j
                    x = -self:get_ellipse_x(y)
                elseif(i == 4) then
                    y = -(height/5)*j
                    x = -self:get_ellipse_x(y)
                end
                table.insert(pathVectors, Vector3.New(x,y,0))
            end
            seatHolder.sanZObj.transform:DOLocalPath(pathVectors, 1, DG.Tweening.PathType.CatmullRom)
        end
    elseif(gameState.SanZhangType == 3) then
        for i = 1, #self.seatHolderArray do
            local seatHolder = self.seatHolderArray[i]
            if(i == 1) then
                seatHolder.sanZObj.transform:DOLocalMove(self.seatHolderArray[3].sanZPos, 1, false)
            elseif(i == 2) then
                seatHolder.sanZObj.transform:DOLocalMove(self.seatHolderArray[4].sanZPos, 1, false)
            elseif(i == 3) then
                seatHolder.sanZObj.transform:DOLocalMove(self.seatHolderArray[1].sanZPos, 1, false)
            elseif(i == 4) then
                seatHolder.sanZObj.transform:DOLocalMove(self.seatHolderArray[2].sanZPos, 1, false)
            end
        end
    end
    self:subscibe_time_event(1.5, false, 0):OnComplete(function(t)
        if(callback) then
            callback()
        end
        self:add_san_zhang_animation(callback1)
    end)
end

--- 添加三张动画
function TableXueLiuChengHeView:add_san_zhang_animation(callback)
    local aniObjs = {}
    local mjs = self:get_my_hand_mjs()
    for i = 1, #mjs do
        ---@type Mj2D
        local mj = mjs[i]
        if(mj.redPoint and mj.redPoint.gameObject.activeSelf) then
            table.insert(aniObjs, mj.gameObject)
            mj.transform.localPosition = Vector3.New(mj.transform.localPosition.x, lastMJOffset, 0)
        end
    end
    for i = 1, #aniObjs do
        aniObjs[i].transform:DOLocalMoveY(0, 0.8, false)
    end
    self:subscibe_time_event(0.8, false, 0):OnComplete(function(t)
        self.isHuanSanZhang = false
        if(callback) then
            callback()
        end
    end)
end

--- 计算椭圆的x值
function TableXueLiuChengHeView:get_ellipse_x(y)
    local width = 382
    local height = 224
    return math.sqrt((1-(y*y)/(height*height))*(width*width))
end

---定缺条件
function TableXueLiuChengHeView:can_ding_que()
    return not self.isHuanSanZhang and not self.gameState.HuanSanZhang
end

--- 初始化换三张的牌
function TableXueLiuChengHeView:init_hsz()
    self.huanSanZhangPais = {}
    local mjs = self:get_my_hand_mjs()
    for i = 1, #mjs do
        ---@type Mj2D
        local mj = mjs[i]
        local pai = mj.pai
        if(mj.gameObject.activeSelf) then
            local isGray = not self:not_need_gray(pai)
            mj:set_disable(isGray)
            if(isGray) then
                mj:set_color(Color.gray, mj.skinObj)
            else
                mj:set_color(Color.white, mj.skinObj)
            end
        end
    end
end

--- 点击选择换三张
function TableXueLiuChengHeView:click_select(selectMj)
    local pai = self:get_mj(selectMj).pai
    if(selectMj.transform.localPosition.y < lastMJOffset and #self.huanSanZhangPais < 3) then
        selectMj.transform.localPosition = Vector3.New(selectMj.transform.localPosition.x, lastMJOffset, selectMj.transform.localPosition.z)
        table.insert(self.huanSanZhangPais, pai)
    elseif(selectMj.transform.localPosition.y > 0) then
        selectMj.transform.localPosition = Vector3.New(selectMj.transform.localPosition.x, 0, selectMj.transform.localPosition.z)
        TableUtil.remove_table_index(self.huanSanZhangPais, pai)
    end
    if(#self.huanSanZhangPais == 0) then
        self:init_hsz()
    else
        local paiType = 0
        local upPai = self.huanSanZhangPais[1]
        if(upPai >= 1 and upPai <= 9) then
            paiType = 1
        elseif(upPai >= 10 and upPai <= 18) then
            paiType = 2
        elseif(upPai >= 19 and upPai <= 27) then
            paiType = 3
        end
        local mjs = self:get_my_hand_mjs()
        for i = 1, #mjs do
            ---@type Mj2D
            local mj = mjs[i]
            local pai = mj.pai
            if(mj.gameObject.activeSelf) then
                local isGray = not self:not_need_gray_select(pai, paiType)
                mj:set_disable(isGray)
                if(isGray) then
                    mj:set_color(Color.gray, mj.skinObj)
                else
                    mj:set_color(Color.white, mj.skinObj)
                end
            end
        end
        self.buttongHuanSZ:SetActive(#self.huanSanZhangPais == 3)
        self.buttongHuanSZDisable:SetActive(#self.huanSanZhangPais ~= 3)
    end
end

--- 选三张时不需要灰显的牌
function TableXueLiuChengHeView:not_need_gray_select(pai, paiType)
    return (pai >= 1 and pai <= 9 and paiType == 1) or (pai >= 10 and pai <= 18 and paiType == 2) or (pai >= 19 and pai <= 27 and paiType == 3)
end

--- 换三张初始化不需要灰显的牌
function TableXueLiuChengHeView:not_need_gray(pai)
    local table1 = {}
    local table2 = {}
    local table3 = {}
    local mjs = self:get_my_hand_mjs()
    for i = 1, #mjs do
        ---@type Mj2D
        local mj = mjs[i]
        if(mj.gameObject.activeSelf) then
            local pai = mj.pai
            if(pai >= 1 and pai <= 9) then
                table.insert(table1, pai)
            end
            if(pai >= 10 and pai <= 18) then
                table.insert(table2, pai)
            end
            if(pai >= 19 and pai <= 27) then
                table.insert(table3, pai)
            end
        end
    end
    return (pai >= 1 and pai <= 9 and #table1 >= 3) or (pai >= 10 and pai <= 18 and #table2 >= 3) or (pai >= 19 and pai <= 27 and #table3 >= 3)
end

--- 开始游戏
function TableXueLiuChengHeView:begin_game(gameState)
    Base.begin_game(self, gameState)
    self.beginGame = true
end

---结束刷新gameState
function TableXueLiuChengHeView:game_state_end()
    Base.game_state_end(self)
    if(self.beginGame and self.gameState.HuanSanZhang and #self.gameState.Player[self.mySeat + 1].SanZhang == 0) then
        self.buttongHuanSZDisable:SetActive(true)
        self.huanSanzTip:SetActive(true)
        self:init_hsz()
    end
    self.beginGame = false
end

return  TableXueLiuChengHeView