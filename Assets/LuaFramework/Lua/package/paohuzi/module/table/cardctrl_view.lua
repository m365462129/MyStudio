--
-- Created by IntelliJ IDEA.
-- User: Jufeng01
-- Date: 2016/12/14
-- Time: 12:00
-- To change this template use File | Settings | File Templates.
--

---@class CardCtrlView
local CardCtrlView = {}

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")
local ComponentUtil = ModuleCache.ComponentUtil
local ComponentTypeName = ComponentTypeName



local CHI_TYPE = { "左吃", "中吃", "右吃", "小小大", "小大大", "二七十", }

--- 绑定视图
--- @param module TableModule
--- @param view UnityEngine.GameObject
--- @param cloneRoot UnityEngine.GameObject
function CardCtrlView:bind_view(module, view, cloneRoot)
    self.module = module
    self.view = view
    self.ctrl = {}
    self.ctrl.obj = Manager.FindObject(view, "Ctrl" .. AppData.Game_Name)
    self.ctrl.guo = Manager.GetButton(view, "Ctrl" .. AppData.Game_Name .. "/Guo")
    self.ctrl.guo.onClick:AddListener(function()
        self:on_click_guo()
    end)
    self.ctrl.chi = Manager.GetButton(view, "Ctrl" .. AppData.Game_Name .. "/Chi")
    self.ctrl.chi.onClick:AddListener(function()
        if not self.BipaiFlagShow then
            self:on_click_chi()
        else
            self.Bipai:SetActive(true)
            self.BipaiFlagShow = nil
        end
    end)


    self.ctrl.BgButton = Manager.GetButton(view, "Bipai/Bg")
    self.ctrl.BgButton.onClick:AddListener(function()
        self.Bipai:SetActive(false)
        self.BipaiFlagShow = true
    end)

    self.ctrl.peng = Manager.GetButton(view, "Ctrl" .. AppData.Game_Name .. "/Peng")
    self.ctrl.peng.onClick:AddListener(function()
        self:on_click_peng()
    end)
    self.ctrl.hu = Manager.GetButton(view, "Ctrl" .. AppData.Game_Name .. "/Hu")
    self.ctrl.hu.onClick:AddListener(function()
        self:on_click_hu()
    end)

    self.Bipai = Manager.FindObject(view, "Bipai")
    self.chipai = {}
    self.chipai.obj = Manager.FindObject(view, "Bipai/Chi")
    self.chipai.img = Manager.GetImage(self.chipai.obj, "Image")
    self.chipai.clone = Manager.FindObject(cloneRoot, "Chi")
    self.chipai.light = Manager.FindObject(view, "Bipai/Chi/Highlight")
    self.chipai.layout = Manager.GetComponent(self.chipai.img.gameObject, ComponentTypeName.GridLayoutGroup)

    self.bipai = {}
    for i = 1, 2 do
        local obj = Manager.FindObject(view, "Bipai/Bi" .. i)
        self.bipai[i] = {
            obj = obj,
            scroll = Manager.GetRect(obj, "Scroll View"),
            content = Manager.GetRect(obj, "Scroll View/Viewport/Content"),
            light = Manager.FindObject(obj, "Highlight"),
        }
    end

    self:set_active(false)
end

--- 清除
function CardCtrlView:clear()
    self:set_active(false)
    self.chiShowing = false
    self.chiDataList = nil
    self.ctrl.obj:SetActive(false)
    self:reset_bi_light()
    self.bipai[1].obj:SetActive(false)
    self.bipai[2].obj:SetActive(false)
    self.chipai.obj:SetActive(false)
    self.chipai.light:SetActive(false)
end

--- 显示或隐藏
function CardCtrlView:set_active(b)
    if self.view then
        self.view:SetActive(b)
    end
end

--- 显示对应按钮
--- @param data GameState
function CardCtrlView:show_btns(data)
    self.module:start_lua_coroutine(function ()

        coroutine.wait(0.3)
        print('MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM')
        --- 可出可不出，只显示过按钮
        if data.ke_chu == 1 then
            TableUtilPaoHuZi.print("只显示过，可出可不出")
            self:show_guo()
            return
        end
        --- 没有任何操作
        if (not data.ke_chi or #data.ke_chi <= 0) and not data.ke_peng and not data.ke_hu then
            self.paizhi = -1
            self:set_active(false)
            return
        end
    
        self:clear()
    
        self.paizhi = -1
        --- 找出吃的牌的值
        for i = 1, #data.player do
            if data.player[i].chu_pai then
                self.paizhi = data.player[i].qi_zhang[#data.player[i].qi_zhang]
            end
        end
    
        self:set_chi_list(data.ke_chi)
    
        if AppData.Game_Name == "GLZP" then
            self.ctrl.guo.gameObject:SetActive(not data.ke_hu)
        else

            if AppData.Game_Name == 'XXZP' then
                self.ctrl.guo.gameObject:SetActive(data.ke_guo)
            else
                self.ctrl.guo.gameObject:SetActive(true)
            end
        end
        self.ctrl.hu.gameObject:SetActive(data.ke_hu)
        self.ctrl.peng.gameObject:SetActive(data.ke_peng)
        self:set_active(true)
        self.ctrl.obj:SetActive(true)
    end)
end

--- 只显示过，存在可出牌也可不出牌的情况才使用
function CardCtrlView:show_guo()
    self:clear()
    ComponentUtil.SafeSetActive(self.ctrl.obj, true)
    ComponentUtil.SafeSetActive(self.ctrl.guo.gameObject, true)
    ComponentUtil.SafeSetActive(self.ctrl.peng.gameObject, false)
    ComponentUtil.SafeSetActive(self.ctrl.chi.gameObject, false)
    ComponentUtil.SafeSetActive(self.ctrl.hu.gameObject, false)
    self:set_active(true)
end

function CardCtrlView:on_click_guo()

    if DataPaoHuZi.Msg_Table_GameStateNTF.ke_hu and (AppData.Game_Name == 'XXZP' or AppData.Game_Name == 'LDZP') then
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("确定过胡吗？", function()
            self.module.model:request_guo()
            self:set_active(false)
            self.ctrl.obj:SetActive(false)
        end, function() 
        end, true, "确 认", "取 消")  
    else
        self.module.model:request_guo()
        self:set_active(false)
        self.ctrl.obj:SetActive(false)
    end
end

function CardCtrlView:on_click_chi()
    if self.chiShowing then
        return
    end

    self.chiShowing = true
    self.chipai.obj:SetActive(true)
    self:refresh_chi_position()
end

function CardCtrlView:on_click_peng()

    if DataPaoHuZi.Msg_Table_GameStateNTF.ke_hu and DataPaoHuZi.Msg_Table_GameStateNTF.ke_peng then
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_other_confirm_cancel("确定碰牌吗？ ", function()
            self.module.model:request_peng()
            self:set_active(false)
            self.ctrl.obj:SetActive(false)
        end, function() 
        end, true, "确 认", "取 消")  
    else
        self.module.model:request_peng()
        self:set_active(false)
        self.ctrl.obj:SetActive(false)
    end





    
end

function CardCtrlView:on_click_hu()
    self.module.model:request_hu()
    self:set_active(false)
end

--- 设置吃牌列表
--- @param data GameState
function CardCtrlView:set_chi_list(data)
    self.ctrl.chi.gameObject:SetActive(data and #data > 0)

    if not data then
        return
    end

    self.operateData = data

    Manager.DestroyChildren(self.chipai.img.gameObject)
    for i = 1, 2 do
        Manager.DestroyChildren(self.bipai[i].content.gameObject)
    end

    self.chiDataList = {}
    self.chiTable = {}

    --- 添加一级吃（最多六种）
    for i = 1, #data do
        for j = 1, #data[i].type do
            local findFlag = false
            for k = 1, #self.chiTable do
                if data[i].type[j] == self.chiTable[k].first then
                    findFlag = true
                    break
                end
            end
            --- 一级吃列表里面没有才添加
            if not findFlag then
                table.insert(self.chiTable, { first = data[i].type[j] })
            end
        end
    end

    --- 对一级吃进行排序
    table.sort(self.chiTable, function(a, b)
        return a.first < b.first
    end)

    --- 添加二级比
    if #self.chiTable >= 1 then
        for i = 1, #data do
            for j = 1, #self.chiTable do
                local findIndex = 0
                for k = 1, #data[i].type do
                    --- 先找出包含吃法的Index
                    if data[i].type[k] == self.chiTable[j].first then
                        findIndex = k
                        break
                    end
                end
                if findIndex > 0 then
                    local temp = {}
                    for k = 1, #data[i].type do
                        --- 过滤吃法的Index，添加到临时二级比列表中
                        if k ~= findIndex then
                            table.insert(temp, data[i].type[k])
                        end
                    end
                    if #temp > 0 then
                        --- 遍历临时二级比列表，对比保存的二级比列表中没有的比法并添加
                        for k = 1, #temp do
                            if not self.chiTable[j].second then
                                self.chiTable[j].second = {}
                            end
                            local findFlag = false
                            for m = 1, #self.chiTable[j].second do
                                if temp[k] == self.chiTable[j].second[m].first then
                                    findFlag = true
                                end
                            end
                            if not findFlag then
                                table.insert(self.chiTable[j].second, { first = temp[k] })
                            end
                        end
                    end
                end
                --- 对保存的二级比列表进行排序
                if self.chiTable[j].second and #self.chiTable[j].second > 1 then
                    table.sort(self.chiTable[j].second, function(a, b)
                        return a.first < b.first
                    end)
                end
            end
        end
    end

    --- 添加三级比，找出同时包含一级吃和二级比的数据组，并添加到三级比列表中
    for i = 1, #self.chiTable do
        local first = self.chiTable[i].first
        if self.chiTable[i].second then
            for j = 1, #self.chiTable[i].second do
                local second = self.chiTable[i].second[j].first
                local third = {}
                for k = 1, #data do
                    local findFirst = false
                    local findSecond = false
                    local findFirstIndex = 0
                    local findSecondIndex = 0
                    for m = 1, #data[k].type do
                        if data[k].type[m] == first then
                            findFirst = true
                            findFirstIndex = m
                            break
                        end
                    end
                    if findFirst then
                        for m = 1, #data[k].type do
                            if m ~= findFirstIndex and data[k].type[m] == second then
                                findSecond = true
                                findSecondIndex = m
                                break
                            end
                        end
                    end
                    if findSecond then
                        for m = 1, #data[k].type do
                            if m ~= findFirstIndex and m ~= findSecondIndex then
                                table.insert(third, data[k].type[m])
                            end
                        end
                    end
                end
                if #third > 0 then
                    for k = 1, #third do
                        if not self.chiTable[i].second[j].second then
                            self.chiTable[i].second[j].second = {}
                        end
                        table.insert(self.chiTable[i].second[j].second, third[k])
                    end
                    if self.chiTable[i].second[j].second and #self.chiTable[i].second[j].second > 1 then
                        table.sort(self.chiTable[i].second[j].second, function(a, b)
                            return a < b
                        end)
                    end
                end
            end
        end
    end

    --- 遍历吃法列表，并拷贝物体对象
    for i = 1, #self.chiTable do
        local first = self.chiTable[i].first
        --print("一级吃", first)
        local obj1 = Manager.CopyObject(self.chipai.clone, self.chipai.img.gameObject)
        obj1.name = tostring(first)
        self:set_chi_obj(obj1, first)
        Manager.AddButtonListener(Manager.GetButton(obj1), function()
            self:select_chi(obj1)
        end)
        obj1:SetActive(true)
        if self.chiTable[i].second then
            for j = 1, #self.chiTable[i].second do
                local second = self.chiTable[i].second[j].first
                --print("二级比", second)
                local obj2 = Manager.CopyObject(self.chipai.clone, self.bipai[1].content.gameObject)
                obj2.name = tostring(first * 10 + second)
                self:set_chi_obj(obj2, second)
                Manager.AddButtonListener(Manager.GetButton(obj2), function()
                    self:select_bi1(obj2)
                end)
                if self.chiTable[i].second[j].second then
                    for k = 1, #self.chiTable[i].second[j].second do
                        local third = self.chiTable[i].second[j].second[k]
                        --print("三级比", third)
                        local obj3 = Manager.CopyObject(self.chipai.clone, self.bipai[2].content.gameObject)
                        obj3.name = tostring(first * 100 + second * 10 + third)
                        self:set_chi_obj(obj3, third)
                        Manager.AddButtonListener(Manager.GetButton(obj3), function()
                            self:select_bi2(obj3)
                        end)
                    end
                end
            end
        end
    end

    local x = #self.chiTable * 55 + 35 * (#self.chiTable - 1) + 40
    self.chipai.img.rectTransform.sizeDelta = Vector2.New(x, 200)
end

--- 设置吃牌物体
--- @param obj UnityEngine.GameObject
--- @param type number
function CardCtrlView:set_chi_obj(obj, type)
    local cards = self:get_chi_cards(type)
    for i = 1, 3 do
        local cardObj = Manager.FindObject(obj, "Card/" .. i)
        TableUtilPaoHuZi.set_card(cardObj, cards[i],nil,'ZiPai_PlayCards')--ZiPai_CurPutCards  ZiPai_HandCards
    end
end

--- 根据吃牌方式获取对应的数组
--- @param type number
--- @return table
function CardCtrlView:get_chi_cards(type)
    local cards = {}

    if type >= 1 and type <= 3 then
        --- 左、中、右吃
        for i = 1, 3 do
            cards[i] = self.paizhi + (i - type) * 2
        end
    elseif type == 4 then
        --- 小小大
        if self.paizhi % 2 == 0 then
            cards = { self.paizhi - 1, self.paizhi - 1, self.paizhi }
        else
            cards = { self.paizhi, self.paizhi, self.paizhi + 1 }
        end
    elseif type == 5 then
        --- 小大大
        if self.paizhi % 2 == 0 then
            cards = { self.paizhi - 1, self.paizhi, self.paizhi }
        else
            cards = { self.paizhi, self.paizhi + 1, self.paizhi + 1 }
        end
    else
        if self.paizhi % 2 == 0 then
            cards = { 4, 14, 20 }   --- 贰柒拾
        else
            cards = { 3, 13, 19 }   --- 二七十
        end
    end

    return cards
end

--- 选择一级吃
--- @param obj UnityEngine.GameObject
function CardCtrlView:select_chi(obj)
    self.chipai.light.transform.position = obj.transform.position
    local num = tonumber(obj.name)
    if self.chiDataList and self.chiDataList[1] and self.chiDataList[1] == num then
        return
    end

    if not self.chiDataList then
        self.chiDataList = {}
    end
    self.chiDataList[1] = num
    self.chipai.light:SetActive(true)
    self:reset_bi_light()
    self.bipai[2].obj:SetActive(false)
    self:show_bi(1, num)
end

--- 选择二级比
--- @param obj UnityEngine.GameObject
function CardCtrlView:select_bi1(obj)
    self.bipai[1].light.transform:SetParent(obj.transform)
    self.bipai[1].light:SetActive(true)
    self.bipai[1].light.transform.localPosition = Vector3.New(0, 0, 0)

    local num = tonumber(obj.name)
    self.chiDataList[2] = num % 10
    self:show_bi(2, num)
end

--- 选择三级比
--- @param obj UnityEngine.GameObject
function CardCtrlView:select_bi2(obj)
    local num = tonumber(obj.name)
    self.chiDataList[3] = num % 10
    self:request_chi()
end

--- 显示比牌
--- @param index number
--- @param num number
function CardCtrlView:show_bi(index, num)
    local child = TableUtilPaoHuZi.get_all_child(self.bipai[index].content)
    if #child > 0 then
        local count = 0
        for i = 1, #child do
            local id = tonumber(child[i].name)

            if math.floor(id / 10) == num then
                child[i]:SetActive(true)
                count = count + 1
            else
                child[i]:SetActive(false)
            end
        end

        if count > 0 then
            local x1 = count * 55 + 35 * (count - 1) + 52
            local x2 = count <= 3 and x1 + 34 or 290



            self.bipai[index].scroll.sizeDelta = Vector2.New(x1, 200)
            self.bipai[index].content.sizeDelta = Vector2.New(x1 - 30, self.bipai[index].content.sizeDelta.y)
            self.bipai[index].obj:SetActive(true)
            self:refresh_chi_position()
            return
        end
    end

    self.bipai[index].obj:SetActive(false)
    self:request_chi()
end

--- 刷新位置
function CardCtrlView:refresh_chi_position()
    self.withPingMu = self.withPingMu or self.module.view.tableBg1:GetComponent('RectTransform').rect.width/2

    if not self.withPingMu then
        self.withPingMu = 640
    end

   
 
    local withPingMu = self.withPingMu


    local spacing = 30
    local width1 = self.chipai.img.rectTransform.sizeDelta.x
    local width2 = self.bipai[1].scroll.sizeDelta.x
    local width3 = self.bipai[2].scroll.sizeDelta.x

    if self.chipai.obj.activeSelf and self.bipai[1].obj.activeSelf and self.bipai[2].obj.activeSelf then
        local localPos = self.bipai[1].obj.transform.localPosition
        localPos.x = withPingMu - (width1/2 + width2 + width3 + 200 + 90) 
        self.chipai.obj.transform.localPosition = localPos
        localPos.x = withPingMu - (width2/2 + width3 + 200 + 60)  
        self.bipai[1].obj.transform.localPosition = localPos
        localPos.x = withPingMu - (width3/2 + 200 + 30)  
        self.bipai[2].obj.transform.localPosition = localPos
    elseif self.chipai.obj.activeSelf and self.bipai[1].obj.activeSelf then
        local localPos = self.bipai[1].obj.transform.localPosition
        localPos.x = withPingMu - (width1/2 + width2 + 200 + 60 ) 

      
        self.chipai.obj.transform.localPosition = localPos
        localPos.x = withPingMu - (width2/2 + 200 + 30)  
        self.bipai[1].obj.transform.localPosition = localPos
    elseif self.chipai.obj.activeSelf then
        local pos = self.chipai.obj.transform.position
        self.chipai.obj.transform.position = Vector3.New(self.ctrl.chi.transform.position.x, pos.y, pos.z)
    end
end

--- 重置比牌高亮物体
function CardCtrlView:reset_bi_light()
    self.bipai[1].light:SetActive(false)
    self.bipai[1].light.transform:SetParent(self.bipai[1].obj.transform)
end

--- 请求吃牌
function CardCtrlView:request_chi()
    self:reset_bi_light()
    table.sort(self.chiDataList, function(a, b)
        return a < b
    end)
    local SeqNo = -1
    for i = 1, #self.operateData do
        SeqNo = SeqNo + 1
        local findIndex = 0
        for j = 1, #self.chiDataList do
            if #self.operateData[i].type == #self.chiDataList then
                if self.chiDataList[j] == self.operateData[i].type[j] then
                    findIndex = findIndex + 1
                end
            end
        end
        if findIndex == #self.operateData[i].type then
            break
        end
    end

    print("请求吃牌序号", SeqNo)
    self.module.model:request_chi(SeqNo)

    self:set_active(false)
end

return CardCtrlView