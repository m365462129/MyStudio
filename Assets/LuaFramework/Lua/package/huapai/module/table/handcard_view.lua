--
-- Created by IntelliJ IDEA.
-- User: Jufeng01
-- Date: 2016/12/10
-- Time: 15:28
-- To change this template use File | Settings | File Templates.
-- 手牌处理视图

---@class HandCardView
local HandCardView = {}

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.huapai.module.tablebase.table_util")

local Input = UnityEngine.Input

local LINE_COUNT = 9 -- 手牌最大列数
local ROW_COUNT = 12 -- 手牌最大行数
local DEFAULT_CARD_VALUE = -1 -- 默认值

--- 限制自由拖动一列可摆放的最大张数
--- 如果一列最多只能摆放3张，将此参数修改为3即可
local ROW_COUNT = 12

local GRAY = Color.New(0.6, 0.6, 0.6, 1)
local WHITE = Color.New(1, 1, 1, 1)
local WHITE_ALPHA = Color.New(1, 1, 1, 0.5)

local gridLa = nil

--- 初始化视图
---@param module TableModule 绑定module层
---@param view UnityEngine.GameObject 绑定手牌根节点
---@param cloneRoot UnityEngine.GameObject 克隆根节点
function HandCardView:bind_view(module, view, cloneRoot, line)
    self.module = module

    self.gridGoVTa = self.gridGoVTa or {}
    for j = 1, LINE_COUNT do
        self.gridGoVTa[j] = Manager.FindObject(self.module.view.gridRoot, tostring(j))
    end
    --- 牌的父节点，用于排列牌的显示次序
    self.cardParent = {}
    for i = 1, 12 do
        self.cardParent[i] = Manager.FindObject(view, "CardsParent/" .. tostring(i)).transform
    end

    local grid = self.module.view.gridRoot


    --- 初始化LINE_COUNT * ROW_COUNT的网格节点以及牌的空列表
    self.grid = {}
    self.cardds = {}
    for i = 1, LINE_COUNT do
        self.grid[i] = {}
        self.cardds[i] = {}
        for j = 1, ROW_COUNT do
            self.cardds[i][j] = {}
            self.cardds[i][j].id = DEFAULT_CARD_VALUE
            self.cardds[i][j].enable = false
            local obj = Manager.FindObject(grid, tostring(i) .. "/" .. tostring(j))
            self.grid[i][j] = obj.transform
        end
    end

    --- 计算节点的宽高
    self.gridWidth = (self.grid[2][1].position.x - self.grid[1][1].position.x) / 2
    self.gridHeight = (self.grid[1][2].position.y - self.grid[1][1].position.y) / 2

    --- 拖动时牌的显示
    self.dragImg = Manager.GetImage(view, "Drag/Image")
    self.dragSpriteHolder = Manager.GetComponent(self.dragImg.gameObject, "SpriteHolder")

    --- 手牌的本体
    self.clone = Manager.FindObject(cloneRoot, "ShouZhang")

    --- 左上、右下节点，用来判断出牌范围
    local lt = Manager.FindObject(view, "LT")
    local rb = Manager.FindObject(view, "RB")
    self.lt, self.rb = {}, {}
    self.lt.x, self.lt.y = lt.transform.position.x, lt.transform.position.y
    self.rb.x, self.rb.y = rb.transform.position.x, rb.transform.position.y

    --- 提示出牌动画
    self.readyOut = {
        obj = Manager.FindObject(view, "ReadyOut"),
        finger = Manager.FindObject(view, "ReadyOut/Finger")
    }
    self:set_line_obj(line)

    gridLa = Manager.GetComponent(self.module.view.gridRoot.gameObject, ComponentTypeName.GridLayoutGroup) 
end

--- 初始化手牌数据
--- @param data table 手牌数据
--- @param slowly boolean 是否开场慢慢显示
--- @param callback function 回调函数
function HandCardView:init_data(data)

    if not self.module.view then
        return
    end
  
    for j = 1, LINE_COUNT do
        self.gridGoVTa[j]:SetActive(false)
    end

    for j, v in ipairs(data.cards) do
        self.gridGoVTa[j]:SetActive(true)
    end

    for i = 1, LINE_COUNT do
        for j = 1, ROW_COUNT do
            self.cardds[i][j].id = DEFAULT_CARD_VALUE
            self.cardds[i][j].enable = false
        end
    end


    gridLa = gridLa or Manager.GetComponent(self.module.view.gridRoot.gameObject, ComponentTypeName.GridLayoutGroup) 
    gridLa.enabled = true
    coroutine.wait(0.01)
    gridLa.enabled = false
    coroutine.wait(0.01)

    for k, v in ipairs(data.cards) do
        for i, j in ipairs(v.pai) do

           
            self.cardds[k][i].id = j.pai

            local go = nil

            if self.cardds[k][i].obj == nil then
                go = Manager.CopyObject(self.clone, self.cardParent[i])
            end

            if go == nil then
                go = self.cardds[k][i].objOyl
            end

            local RectTransform = go.transform:Find("Image"):GetComponent("RectTransform")
            self.Vector2_140 = self.Vector2_140 or UnityEngine.Vector2.New(77, 93)
            RectTransform.sizeDelta = self.Vector2_140
            TableUtilPaoHuZi.set_card(go, j.pai, nil, "ZiPai_HandCards")

            Manager.SetPos(go, self.grid[k][i].position.x, self.grid[k][i].position.y, self.grid[k][i].position.z)

            go:SetActive(false)
            self.cardds[k][i].obj = go
            self.cardds[k][i].objOyl = go
            self.cardds[k][i].enable = not j.is_gray
            self.cardds[k][i].cachePos = self.grid[k][i].position

            go.name = k .. "__" .. i
        end
    end

    self:refresh_cardsHao()
end

--- 设置出牌提示的线
--- @param obj UnityEngine.GameObject
function HandCardView:set_line_obj(obj)
    self.line = obj
    self:show_line(false)
end

--- 显示出牌提示的线
--- @param show boolean
function HandCardView:show_line(show)
    if self.line then
        self.line:SetActive(show)
    end
end

--- 清除数据
function HandCardView:clear()
    self.gudingCount = 0
    self.oldDataList = nil
    self.dragEnable = false
    self.enable = false
    self.downFlag = false
    self.chupaiX = nil
    self.chupaiY = nil
    self.dragObj = nil
    self.dragImg.gameObject:SetActive(false)
end

--- 设置是否能出牌
--- @param b boolean
function HandCardView:set_out_card_enable(b)
    self.enable = b
    self:show_ready_out(b)
end

--- 设置是否可拖动
--- @param b boolean
function HandCardView:set_drag_enable(b)
    self.dragEnable = b
end

--- 显示出牌提示动画
--- @param b boolean
function HandCardView:show_ready_out(b)
    if b then
        print("啊  无语")
    end

    self.readyOut.obj:SetActive(b)

    if self.readyOut.seq then
        self.readyOut.seq:Kill(false)
        self.readyOut.seq = nil
    end

    self.readyOut.finger.transform.localPosition = Vector3.New(self.readyOut.finger.transform.localPosition.x, -40, 0)
    if b then
        self.readyOut.seq = self.module:create_sequence()
        local tw1 = self.readyOut.finger.transform:DOLocalMoveY(40, 1, false)
        local tw2 = self.readyOut.finger.transform:DOLocalMoveY(-40, 0.3, false)
        self.readyOut.seq:Append(tw1)
        self.readyOut.seq:AppendInterval(0.2)
        self.readyOut.seq:Append(tw2)
        self.readyOut.seq:SetAutoKill(true)
        self.readyOut.seq:OnComplete(
            function()
            end
        )
        self.readyOut.seq:SetLoops(-1)
        self.readyOut.seq:Play()
    --else
    --    self.readyOut.finger.transform.localPosition = Vector3.New(self.readyOut.finger.transform.localPosition.x, -40, 0)
    end
end

--- 设置拖动的牌
--- @param value number 牌值
function HandCardView:set_drag_img(value)
    TableUtilPaoHuZi.set_card(self.dragImg.transform.parent.gameObject, value, nil, "ZiPai_CurPutCards")
    --self.dragImg.sprite = self.dragSpriteHolder:FindSpriteByName(value)
end

--- 开始拖动
--- @param obj UnityEngine.GameObject 单元格中的obj
function HandCardView:on_drag_begin(obj)
    if not self.dragEnable or self.dragObj then
        return
    end

    --- 根据点击选中的obj获取对应的单元格坐标
    local i, j = self:get_xy(obj)
    --- 对应单元格中存在牌且牌是可拖动状态才开始拖动
    if self.cardds[i][j].obj and self.cardds[i][j].enable then
        self.YiDonQianWeiZhi = self.cardds[i][j].obj.transform.position
        print("选中单元格", i, j)
        self:show_line(true)
        self.downFlag = true
        --- 记录当前点击位置
        self.downX, self.downY = i, j
        self.dragObj = self.cardds[i][j].obj
        --- 透明化选中的牌
        local img = Manager.GetImage(self.cardds[i][j].obj, "Image")
        img.color = WHITE_ALPHA
        self:set_drag_img(self.cardds[i][j].id)
        --- 这里必须先设置为显示状态再更新坐标，否则下次拖动会出现按下时坐标改变了，但显示位置还在原来的地方
        self.dragImg.gameObject:SetActive(true)
        self:on_drag_update()
    end
end

--- 更新拖动
function HandCardView:on_drag_update()
    if self.downFlag and self.dragObj then
        if Input.touchCount > 0 then
            self.dragImg.transform.position =
                self.module.view:get_world_pos(Input.GetTouch(0).position, self.dragImg.transform.position.z)
        else
            self.dragImg.transform.position =
                self.module.view:get_world_pos(Input.mousePosition, self.dragImg.transform.position.z)
        end
    end
end

function HandCardView:on_drag_end()
    self.module:start_lua_coroutine(
        function()
            self:on_drag_endReal()
        end
    )
end

--- 结束拖动
function HandCardView:on_drag_endReal()

    print('我就不信了')
    self:show_line(false)
    if self.downFlag and self.dragObj then
        --- 拖动物体不存在或不对应
        if not self.cardds[self.downX][self.downY].obj or self.dragObj ~= self.cardds[self.downX][self.downY].obj then
            self.downFlag = false
            self.dragObj = nil
            self:reset_drag_img()
            self:refresh_cardsHao()
            return
        end

        --- 把拖动的牌的坐标值赋给选中的牌
        local pos = self.dragImg.transform.position
        --Manager.SetPos(self.cardds[self.downX][self.downY].obj, pos.x, pos.y, pos.z)

        for i = 1, 10 do
            print(self.dragImg.transform.localPosition.y)
        end

        
        --- 出牌范围
        if pos.y > 0 then
            local enable_ke_chu = DataHuaPai.Msg_Table_GameStateNTF.ke_chu ~= 0
            --- 可出牌
            if
                enable_ke_chu and self.cardds[self.downX][self.downY].obj and
                    self.cardds[self.downX][self.downY].obj == self.dragObj
             then
                self.chupaiX, self.chupaiY = self.downX, self.downY

                local value = self.cardds[self.downX][self.downY].id
                self.module.model:request_chupai(value)
            else
            end
        else
            -- 把牌还原
            --self.dragImg.gameObject.transform:DOMove(self.YiDonQianWeiZhi, 0.1)
            --coroutine.wait(0.1)
        end
    end

    self:reset_drag_img()

    self:refresh_cardsHao()

    self.downFlag = false
    self.dragObj = nil
end

--- 重置拖动显示的牌
function HandCardView:reset_drag_img()
    self.dragImg.gameObject:SetActive(false)
    Manager.SetLocalPos(self.dragImg.gameObject, 0, 0, 0)
end

--- 根据世界坐标换算所在单元格坐标
--- @param pos Vector3
--- @return number, number
function HandCardView:get_grid_xy(pos)
    local x, y = 0, 0
    if pos.x < self.grid[1][1].position.x - self.gridWidth then
        x = 1
    elseif pos.x >= self.grid[LINE_COUNT][1].position.x + self.gridWidth then
        x = LINE_COUNT
    else
        for i = 1, LINE_COUNT do
            if
                pos.x >= self.grid[i][1].position.x - self.gridWidth and
                    pos.x < self.grid[i][1].position.x + self.gridWidth
             then
                x = i
                break
            end
        end
    end
    if pos.y < self.grid[1][1].position.y - self.gridHeight then
        y = 1
    elseif pos.y >= self.grid[1][ROW_COUNT].position.y + self.gridHeight then
        y = ROW_COUNT
    else
        for i = 1, ROW_COUNT do
            if
                pos.y >= self.grid[1][i].position.y - self.gridHeight and
                    pos.y < self.grid[1][i].position.y + self.gridHeight
             then
                y = i
                break
            end
        end
    end

    return x, y
end

function HandCardView:refresh_cardsHao(slowly, callback)
    for i = 1, LINE_COUNT do
        for j = 1, ROW_COUNT do
            if self.cardds[i][j].obj then
                self.cardds[i][j].obj:SetActive(false)
            end
        end
    end

    local isFaPai = false
    if self.module:has_actionWhat(12) then
        isFaPai = true
    end

    for i = 1, LINE_COUNT do
        for j = 1, ROW_COUNT do
            if self.cardds[i][j].id ~= DEFAULT_CARD_VALUE then
                self.cardds[i][j].obj.transform:SetParent(self.cardParent[j])
                Manager.SetScale(self.cardds[i][j].obj, 1, 1, 1)
                local pos = self.grid[i][j].position
                self.cardds[i][j].obj.transform.position = pos

                

                local img = Manager.GetImage(self.cardds[i][j].obj, "Image")
                --local color = img.color
                img.color = self.cardds[i][j].enable and WHITE or GRAY
                self.cardds[i][j].obj:SetActive(true)

                if isFaPai then
                    local pos1 = pos
                    pos1.x = self.module.view.gridRoot.transform.position.x
                    self.cardds[i][j].obj.transform.position = pos1

                    self.cardds[i][j].obj.transform:DOMove(self.grid[i][j].position, 0.7)
                end

            end
        end
        self:refresh_cardOneLie(self.cardds[i])
    end
end

function HandCardView:refresh_cardOneLie(cardds_i)
    for i = 1, ROW_COUNT do
        local pai = cardds_i[i]

        if pai then
            pai.isJiang = false
        end
    end

    local num = 0
    local id = 0
    local flag = false
    -- 查看 是否相邻三个  有 是相同ID
    for i = 1, #cardds_i do
        local pai = cardds_i[i]
        if id == pai.id then
            num = num + 1
        else
            num = 0
        end
        id = pai.id

        if num >= 2 then
            cardds_i[i - 1].isJiang = true
            cardds_i[i].isJiang = true
            cardds_i[i - 1].isJiangNum = num
            cardds_i[i].isJiangNum = num
            flag = true
        end
    end

    if flag then
        for i = 1, #cardds_i do
            local pai = cardds_i[i]
            if pai.isJiang == true and pai.obj then
                -- 包括 这张牌在内 所有牌  全部下降
                for j = i, #cardds_i do
                    local paia = cardds_i[j]
                    if paia.obj then
                        local weizhi = paia.obj.transform.localPosition
                        weizhi.y = weizhi.y - 68 / pai.isJiangNum
                        paia.obj.transform.localPosition = weizhi
                    end
                end
            end
        end
    end
end

--- 获取父节点
--- @param obj UnityEngine.GameObject
--- @return UnityEngine.GameObject
function HandCardView:get_parent_obj(obj)
    local parent = obj.transform.parent.gameObject
    return parent
end

--- 根据单元格节点获取单元格坐标
--- @param obj UnityEngine.GameObject
--- @return number, number
function HandCardView:get_xy(obj)
    local result = string.split(obj.name, "__")
    local x = tonumber(result[1])
    local y = tonumber(result[2])

    return x, y
end

return HandCardView
