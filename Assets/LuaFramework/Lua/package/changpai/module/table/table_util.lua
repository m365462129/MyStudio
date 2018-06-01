local Manager = require("manager.function_manager")
local ModelData = require("package.henanmj.model.model_data")
local TableUtil = require("package.henanmj.table_util")
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local ComponentUtil = ModuleCache.ComponentUtil
local ModuleCache = ModuleCache
local Vector3 = UnityEngine.Vector3

function TableUtil.get_int_def_prefs()
    local def = 1
    if(TableUtil.is_ntcp()) then
        def = 0
    end
    return def
end

---是否是南通长牌
function TableUtil.is_ntcp()
    return ModuleCache.AppData.Game_Name == "NTCP"
end

--- 新的设置长牌
---@param pai int
---@param mj GameObject|Transform
---@param fan boolean
function TableUtil.new_set_changpai(pai, mj)
    local imgObj1 = GetComponentWithPath(mj,"Image",ComponentTypeName.Transform).gameObject
    local imgObj2 = GetComponentWithPath(mj,"Image2",ComponentTypeName.Transform).gameObject
    TableUtil.set_changpai(pai,imgObj1)
    TableUtil.set_changpai(pai,imgObj2)
    local def = TableUtil.get_int_def_prefs()
    local isNew = Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT",def) == 0 -- 0:新界面 1:老界面
    if(isNew) then
        ComponentUtil.SafeSetActive(imgObj1, false)
        ComponentUtil.SafeSetActive(imgObj2, true)
    else
        ComponentUtil.SafeSetActive(imgObj1, true)
        ComponentUtil.SafeSetActive(imgObj2, false)
    end
    TableUtil.set_ting_tag_pos(imgObj1)
    TableUtil.set_ting_tag_pos(imgObj2)
end

function TableUtil.only_change_pai(mj)
    local imgObj1 = GetComponentWithPath(mj,"Image",ComponentTypeName.Transform).gameObject
    local imgObj2 = GetComponentWithPath(mj,"Image2",ComponentTypeName.Transform).gameObject
    local def = TableUtil.get_int_def_prefs()
    local isNew = Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT",def) == 0 -- 0:新界面 1:老界面
    if(isNew) then
        ComponentUtil.SafeSetActive(imgObj1, false)
        ComponentUtil.SafeSetActive(imgObj2, true)
    else
        ComponentUtil.SafeSetActive(imgObj1, true)
        ComponentUtil.SafeSetActive(imgObj2, false)
    end
    TableUtil.only_change_fanjian(imgObj1)
    TableUtil.only_change_fanjian(imgObj2)
    TableUtil.set_mj_fanzhuan(imgObj1)
    TableUtil.set_mj_fanzhuan(imgObj2)
end

function TableUtil.only_change_fanjian(imgObj)
    local fan = ModelData.fan
    local jianImage = Manager.GetImage(imgObj, "J")
    local fanImage = Manager.GetImage(imgObj, "F")
    Manager.SetActive(jianImage.gameObject, not fan)
    Manager.SetActive(fanImage.gameObject, fan)
end

--- 新的设置长牌
---@param pai int
---@param mj GameObject|Transform
---@param fan boolean
function TableUtil.set_changpai(pai,imgObj)
    local fan = ModelData.fan
    local jianImage = Manager.GetImage(imgObj, "J")
    local fanImage = Manager.GetImage(imgObj, "F")
    local jianSpriteHolder = GetComponentWithPath(imgObj,"J","SpriteHolder")
    local fanSpriteHolder = GetComponentWithPath(imgObj,"F","SpriteHolder")
    jianImage.sprite = jianSpriteHolder:FindSpriteByName(pai .. "")
    Manager.SetActive(jianImage.gameObject, not fan)
    fanImage.sprite = fanSpriteHolder:FindSpriteByName(pai .. "")
    Manager.SetActive(fanImage.gameObject, fan)
    TableUtil.set_mj_fanzhuan(imgObj)
end

--- 设置长牌的正反
---@param imgTrans GameObject|Transform
function TableUtil.set_mj_fanzhuan(imgTrans)
    local b = ModelData.upright
    local z = b and 0 or 180
    imgTrans.gameObject.transform.localEulerAngles = Manager.Vector3(0, 0, z)
    TableUtil.set_ting_tag_pos(imgTrans)
end

---设置长牌上听字翻转位置
function TableUtil.set_ting_tag_pos(imgTrans)
    local b = ModelData.upright
    local s = b and 1 or -1
    local z = b and 0 or 180
    local jianTag = GetComponentWithPath(imgTrans,"J/Tag",ComponentTypeName.Transform).gameObject
    local fanTag = GetComponentWithPath(imgTrans,"F/Tag",ComponentTypeName.Transform).gameObject
    jianTag.transform.localEulerAngles = Manager.Vector3(0, 0, z)
    fanTag.transform.localEulerAngles = Manager.Vector3(0, 0, z)
    local fanPos = Vector3.New(3,106,0)
    local jianPos = Vector3.New(20,101,0)
    local def = TableUtil.get_int_def_prefs()
    local isNew = Manager.GetPlayerPrefsInt("NTCP_NEW_LAYOUT",def) == 0 -- 0:新界面 1:老界面
    if(isNew) then
        jianTag.transform.localPosition = fanPos*s
        fanTag.transform.localPosition = fanPos*s
    else
        jianTag.transform.localPosition = jianPos*s
        fanTag.transform.localPosition = jianPos*s
    end
end

--- 新的设置长牌的正反
---@param imgTrans GameObject|Transform
function TableUtil.new_set_mj_fanzhuan(mjObj)
    local imgObj1 =GetComponentWithPath(mjObj,"Image", ComponentTypeName.Transform).gameObject
    local imgObj2 = GetComponentWithPath(mjObj,"Image2",ComponentTypeName.Transform).gameObject
    TableUtil.set_mj_fanzhuan(imgObj1)
    TableUtil.set_mj_fanzhuan(imgObj2)
end

--- 设置长牌的简/繁
---@param imgObj GameObject|TransformMode
function TableUtil.set_mj_jian_fan(imgObj)
    local fan = ModelData.fan
    local jianObj = Manager.FindObject(imgObj, "J")
    if not jianObj then jianObj = Manager.FindObject(imgObj, "J") end
    local fanObj = Manager.FindObject(imgObj, "F")
    if not fanObj then fanObj = Manager.FindObject(imgObj, "F") end
    Manager.SetActive(jianObj, not fan)
    Manager.SetActive(fanObj, fan)
end

---新的设置长牌的简、繁
---@param imgObj GameObject|TransformMode
function TableUtil.new_set_mj_jian_fan(mjObj)
    local imgObj1 =GetComponentWithPath(mjObj,"Image", ComponentTypeName.Transform).gameObject
    local imgObj2 = GetComponentWithPath(mjObj,"Image2",ComponentTypeName.Transform).gameObject
    TableUtil.set_mj_jian_fan(imgObj1)
    TableUtil.set_mj_jian_fan(imgObj2)
end

-- 设置牌颜色
function TableUtil.set_changpai_color(mj, color)
    local children = TableUtil.get_all_child(mj)
    for i = 1, #children do
        local image = Manager.GetImage(children[i])
        if (image) then
            local c = Manager.Color().New(color.r, color.g, color.b, image.color.a) -- 保存原来的透明度
            image.color = c
        end
    end

    local parent = Manager.FindObject(mj, "Image")
    if parent then
        local children2 = TableUtil.get_all_child(parent)
        for i = 1, #children2 do
            local image = Manager.GetImage(children2[i])
            if (image) then
                local c = Manager.Color().New(color.r, color.g, color.b, image.color.a) -- 保存原来的透明度
                image.color = c
            end
        end
    end

    parent = Manager.FindObject(mj, "Image2")
    if parent then
        local children2 = TableUtil.get_all_child(parent)
        for i = 1, #children2 do
            local image = Manager.GetImage(children2[i])
            if (image) then
                local c = Manager.Color().New(color.r, color.g, color.b, image.color.a) -- 保存原来的透明度
                image.color = c
            end
        end
    end
end

---打印obj的绝对路径
function TableUtil.print_obj_root_path(obj)
    local str = tostring(obj.name)
    local trans = obj.transform
    while(trans.parent~=nil) do
        trans = trans.parent
        str = str .."/".. trans.gameObject.name
    end
    print(str)
end


--排序所有的牌 并将牌按规则堆叠
function TableUtil.processMyHandMjData(ShouZhang,hasMoZhang,isNew)
    local origin = {}
    local shouZhangCount = #ShouZhang
    for i=1,#ShouZhang do
        table.insert(origin,ShouZhang[i])
    end
    local moZhang = nil
    if true == hasMoZhang then
        moZhang = {}
        table.insert(moZhang,origin[#origin])
        table.remove(origin,#origin)
    end

    if(isNew == false) then
        local data = {}
        ---处理四张，三张，两张，一样的分组
        while #origin > 0 do
            local cur = origin[1]
            table.remove(origin,1)
            local has = false
            for j=1,#data do
                if data[j][1].Pai  == cur.Pai then  --data[j][1].Pai < 28 and
                    table.insert(data[j],cur)
                    has = true
                    break
                end
            end
            if not has then
                local info = {}
                table.insert(info,cur)
                table.insert(data,info)
            end
        end

        ---处理顺子
        local single = {}
        for i=#data,1,-1 do
            local info = data[i]
            if #info == 1 then
                table.insert(single,info)
                table.remove(data,i)
            end
        end

        --[[if shouZhangCount < 15 then
            for i=#data,1,-1 do
                local info = data[i]
                if #info == 2 then
                    local t = info[2]
                    local newInfo = {}
                    table.insert(newInfo,t)
                    table.insert(data,newInfo)
                    table.remove(info,2)
                end
            end
        end--]]

        ---处理所有的单身狗
        local sortFun = function(infoA,infoB)
            return infoA[1].Pai > infoB[1].Pai
        end
        if #single > 1 then
            table.sort(single,sortFun) ---对单身狗进行排序
        end
        ---查找顺子，解决最后一批单身狗的问题，如果还是单身狗，这辈子也就是单身狗了
        for i=#single,1,-1 do
            local cur = single[i]
            local mid = single[i - 1]
            local last = single[i - 2]
            local addMid = false
            local addLast = false
            if cur --[[and cur[1].Pai < 28--]] and (mid or last) then
                local curRange = math.floor((cur[1].Pai - 1 )/ 9)
                local midRange = mid and math.floor((mid[1].Pai - 1 )/ 9)
                local lastRange = last and math.floor((last[1].Pai - 1 )/ 9)
                if curRange == midRange and  (cur[1].Pai == mid[1].Pai - 1) then
                    addMid = true;
                end
                if  curRange == lastRange and  (cur[1].Pai == last[1].Pai - 2) then
                    addLast = true
                end
            end
            --[[local isOk = true
            if addMid and (not addLast) and shouZhangCount < 15 then  ---两张顺子的情况下
                isOk = false
            end--]]
            if addMid then
                table.insert(cur,mid[1])
                table.remove(single,i - 1)
            end
            if addLast then
                table.insert(cur,last[1])
                table.remove(single,i - 2)
            end
        end
        for i=#single,1,-1 do
            local info = single[i]
            if #info > 1 then
                table.insert(data,info)
                table.remove(single,i)
            end
        end

        ---牌面值相差2的同花色
        if shouZhangCount >= 15 then
            for i=#single,1,-1 do
                local cur = single[i]
                local mid = single[i - 1]
                local addMid = false
                if cur and cur[1].Pai < 28 and mid then
                    local curRange = math.floor((cur[1].Pai - 1 )/ 9)
                    local midRange = mid and math.floor((mid[1].Pai - 1 )/ 9)
                    if curRange == midRange and  math.abs(cur[1].Pai - mid[1].Pai) == 2 then
                        addMid = true
                    end
                end
                if addMid then
                    table.insert(cur,mid[1])
                    table.remove(single,i - 1)
                end
            end
            for i=#single,1,-1 do
                local info = single[i]
                if #info > 1 then
                    table.insert(data,info)
                    table.remove(single,i)
                end
            end
        end

        ---千字，红花，白花的特殊处理
        if shouZhangCount >= 15 then
            for i=#single,1,-1 do
                local cur = single[i]
                local mid = single[i - 1]
                local last = single[i - 2]
                local processCur = cur and (cur[1].Pai >= 28 and  cur[1].Pai <= 30)
                local addMid = mid and (mid[1].Pai >= 28 and  mid[1].Pai <= 30)
                local addLast = last and (last[1].Pai >= 28 and  last[1].Pai <= 30)
                if processCur then
                    if addMid then
                        table.insert(cur,mid[1])
                        table.remove(single,i - 1)
                    end
                    if addLast then
                        table.insert(cur,last[1])
                        table.remove(single,i - 2)
                    end
                end
            end
            for i=#single,1,-1 do
                local info = single[i]
                if #info > 1 then
                    table.insert(data,info)
                    table.remove(single,i)
                end
            end
        end

        ---将最后单个的牌组加入到data
        for i=1,#single do
            table.insert(data,single[i])
        end

        local sortData = function(infoA,infoB)
            return infoA[1].Pai > infoB[1].Pai
        end
        table.sort(data,sortData)
        if moZhang then
            table.insert(data,moZhang)
        end
        return data
    else
        data={}
        for i=1,#origin do
            local info = {}
            table.insert(info,origin[i])
            table.insert(data,info)
        end
        local sortData = function(infoA,infoB)
             return infoA[1].Pai > infoB[1].Pai
        end
        table.sort(data,sortData)
        if moZhang then
            table.insert(data,moZhang)
        end
        return data
    end

end

return TableUtil