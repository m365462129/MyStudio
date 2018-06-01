--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;

local list = require('list')
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
local HandPokers = class('handPokers')
local cardCommon = require('package.guandan.module.guandan_table.gamelogic_common')
local PlayerPrefs = UnityEngine.PlayerPrefs
local offsetY = 50

local prefs_key_handpoker_pos = 'GuanDan_HandPoker_Position'

function HandPokers:initialize(module)
    self.idGen = 0
    self.view = module.view
    self.prefabPoker = module.view.prefabPoker
    self.colList = {}
    self.unuseHolderQueue = list:new()
    self.usingHolderTable = {}
end

function HandPokers:repositionPokers(colList, withoutAnim, onFinish, needMakeMemory)
    self:removeEmptyList(colList)
    local totalRow
    local colCount = #colList
    local offsetX = self:calcOffsetX(colCount)
    local sequence = self.view:create_sequence()
    local duration = 0.2
    for i=1,colCount do
        for j=#colList[i],1,-1 do
            local pos = self:calcPos(offsetX, offsetY, i, j, colCount)
            local go = colList[i][j].root
            pos.z = go.transform.localPosition.z
            
            go.transform:SetAsLastSibling()
            if(withoutAnim)then
                go.transform.localPosition = pos
            else
                sequence:Join(go.transform:DOLocalMove(pos, duration, false))
            end
        end
    end
    if(needMakeMemory)then
        self:make_memory(colList)
    end
    if(colCount == 0)then
        if(onFinish)then
            onFinish()
        end
    else
        if(withoutAnim)then
            if(onFinish)then
                onFinish()
            end
        else
            sequence:OnComplete(function ()
                if(i == 1 and j == 1)then
                    if(onFinish)then
                        onFinish()
                    end
                end
            end)
        end

    end
end

function HandPokers:get_and_remove_elements(list, code, remove)
    local index
    local element
    for i = 1, #list do
        if(list[i].poker.code == code)then
            index = i
            element = list[i]
        end
    end
    if(element)then
        if(remove)then
            table.remove(list, index)
        end
    end
    return element
end

function HandPokers:sort_as_memory_queue()
    local memory_table = self:get_memory()
    if(not memory_table or #memory_table == 0)then
        return
    end
    local colList = self.colList
    local unuse_list = {}
    for i = 1, #colList do
        for j = 1, #colList[i] do
            table.insert(unuse_list, colList[i][j])
        end
    end

    local newColList = {}
    for i = 1, #memory_table do
        for j = 1, #memory_table[i] do
            local pokerHolder = self:get_and_remove_elements(unuse_list, memory_table[i][j], true)
            if(pokerHolder)then
                if(not newColList[i])then
                    newColList[i] = {}
                end
                table.insert(newColList[i], pokerHolder)
            end
        end
        if(newColList[i])then
            self:sortList(newColList[i])
        end
    end

    if(#unuse_list ~= 0)then
        self:sortList(unuse_list)
        table.insert(newColList, unuse_list)
    end

    self.colList = newColList
end

function HandPokers:get_memory_key()
    return self.roomNum .. '_' .. self.curRoundNum
end

function HandPokers:get_prefs_key()
    return prefs_key_handpoker_pos .. '_' .. (self.userID or '')
end

function HandPokers:get_memory()
    local jsonStr = PlayerPrefs.GetString(self:get_prefs_key(), '')
    local table = {}

    if(jsonStr ~= '')then
        table = ModuleCache.Json.decode(jsonStr)
        if(table.key ~= self:get_memory_key())then
            self:clean_memory()
            return nil
        end
    end
    return table.list
end

function HandPokers:make_memory(colList)
    local table = {}
    for i = 1, #colList do
        for j = 1, #colList[i] do
            local pokerHolder = colList[i][j]
            local code = pokerHolder.poker.code
            if(not table[i])then
                table[i] = {}
            end
            table[i][j] = code
        end
    end
    local jsonStr
    if(#table == 0)then
        jsonStr = ''
    else
        jsonStr = ModuleCache.Json.encode({list=table,key=self:get_memory_key()})
    end
    PlayerPrefs.SetString(self:get_prefs_key(), jsonStr)
end

function HandPokers:clean_memory()
    PlayerPrefs.SetString(self:get_prefs_key(), '')
end

function HandPokers:calcOffsetX(totalColCount)
    local defaultColCount = 8
    local minOffsetX = 37.5
    local maxOffsetX = 138
    local fullOffsetX = 127
    local tmpOffsetX = (defaultColCount - 1) * maxOffsetX  / (totalColCount - 1)
    if(tmpOffsetX > fullOffsetX)then
        return fullOffsetX
    elseif(tmpOffsetX < minOffsetX)then
        return minOffsetX
    else
        return tmpOffsetX
    end
end

function HandPokers:calcPos(offsetX, offsetY, col, row, totalCol)
    local centerCol = ( (totalCol + 1) * 0.5)
    local pos = {}
    pos.x = offsetX * (col - centerCol)
    pos.y = offsetY * (row - 1)
    return pos
end

function HandPokers:refreshPokersState(colList)
    for i=1,#colList do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            self:setGrayColor(pokerHolder, pokerHolder.selected)
        end
    end
end

function HandPokers:setGrayColor(pokerHolder, gray)
    gray = gray or false
    if(gray)then
        pokerHolder.face.color = UnityEngine.Color(0.51,0.51,0.51,1)
    else
        pokerHolder.face.color = UnityEngine.Color(1,1,1,1)
    end
    
end


function HandPokers:genPokerHolderList(codeList, major_card_name, append)
    if(not append)then
        self:removeAll()
    end
    local list = {}
    local pokerList = self:genPokerList(codeList, major_card_name)
    for i=1,#pokerList do
        local poker = pokerList[i]
        local pokerHolder = self:genPokerHolder(poker)
        table.insert( list, pokerHolder)
    end
    table.insert( self.colList,list )
    return list
end

function HandPokers:genPoker(code, major_card_name)
    local poker = {}
    poker.code = code
    local card = cardCommon.ResolveCardIdx(code)
    poker.name = card.name
    if(card.name == major_card_name)then
        if(card.color == cardCommon.color_red_heart)then
            poker.majorCardLevel = 2        --红心主牌
        else
            poker.majorCardLevel = 1        --一般主牌
        end
        
    end
    poker.color = card.color
    return poker
end

function HandPokers:genPokerList(codeList, major_card_name)
    local pokerList = {}
    for i=1,#codeList do
        local code = codeList[i]
        table.insert(pokerList, self:genPoker(code, major_card_name))
    end
    return pokerList
end

function HandPokers:genPokerHolder(poker)
    local pokerHolder = self.unuseHolderQueue:pop()
    if(not pokerHolder)then
        pokerHolder = {}
        pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabPoker, self.prefabPoker.transform.parent.gameObject)
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);
    end
    pokerHolder.root:SetActive(true)
    pokerHolder.poker = poker
    local spriteName = self.view:getImageNameFromCode(poker.code, poker.majorCardLevel)
    local sprite = self.view.myCardAssetHolder:FindSpriteByName(spriteName)
    if(not sprite)then
        print(spriteName)
    end
    pokerHolder.face.sprite = sprite
    pokerHolder.root.name = spriteName
    pokerHolder.id = self:genId() 
    self.usingHolderTable[pokerHolder.id] = pokerHolder
    return pokerHolder
end

function HandPokers:sortList(list)
    table.sort(list, function(t1,t2)
        local name1 = t1.poker.name
        local name2 = t2.poker.name

        if(t1.poker.name == cardCommon.card_A)then
            name1 = cardCommon.card_K + 0.1
        end
        if(t2.poker.name == cardCommon.card_A)then
            name2 = cardCommon.card_K + 0.1
        end

        if(t1.poker.majorCardLevel == 1)then
            name1 = cardCommon.card_small_king - 0.1
        end
        if(t1.poker.majorCardLevel == 2)then
            name1 = cardCommon.card_small_king - 0.1
        end
        if(t2.poker.majorCardLevel == 1)then
            name2 = cardCommon.card_small_king - 0.1
        end
        if(t2.poker.majorCardLevel == 2)then
            name2 = cardCommon.card_small_king - 0.1
        end

        if(name1> name2)then
            return true
        elseif(name1 == name2)then
            if(t1.poker.color < t2.poker.color)then
                return true
            elseif(t1.poker.color == t2.poker.color)then
                return t1.id > t2.id
            else
                return false
            end
        else
            return false
        end
    end)
end

function HandPokers:sortColList()
    for i=1,#self.colList do
        self:sortList(self.colList[i])
    end
    table.sort( self.colList, function(t1,t2)
        local holder1 = t1[1]
        local holder2 = t2[1]
        local name1 = holder1.poker.name
        local name2 = holder2.poker.name
        if(t1.poker.name == cardCommon.card_A)then
            name1 = cardCommon.card_K + 0.1
        end
        if(t2.poker.name == cardCommon.card_A)then
            name2 = cardCommon.card_K + 0.1
        end

        if(t1.poker.majorCardLevel == 1)then
            name1 = cardCommon.card_small_king - 0.2
        end
        if(t1.poker.majorCardLevel == 2)then
            name1 = cardCommon.card_small_king - 0.1
        end
        if(t2.poker.majorCardLevel == 1)then
            name2 = cardCommon.card_small_king - 0.2
        end
        if(t2.poker.majorCardLevel == 2)then
            name2 = cardCommon.card_small_king - 0.1
        end
        if(name1 > name2)then
            return true
        elseif(name1 == name2)then
            if(holder1.poker.color < holder2.poker.color)then
                return true
            elseif(holder1.poker.color == holder2.poker.color)then
                return holder1.id > holder2.id
            else
                return false
            end
        else
            return false
        end
    end )
end

function HandPokers:sortSelected2OneCol()
    local selectedPokerHolderList = {}
    local i,j = 1,1
    while i <= #self.colList do
        j = 1
        while j <= #self.colList[i] do
            local pokerHolder = self.colList[i][j]
            if(pokerHolder.selected)then
                pokerHolder.selected = false
                table.insert( selectedPokerHolderList, pokerHolder)
                table.remove( self.colList[i], j )
            else
                j = j + 1
            end
        end
        if(#self.colList[i] == 0)then
            table.remove( self.colList, i )
            --print(i,#self.colList)
        else
            i = i + 1
        end
    end

    if(#selectedPokerHolderList ~= 0)then
        self:sortList(selectedPokerHolderList)
        table.insert( self.colList, selectedPokerHolderList)
    end
    self:removeEmptyList(self.colList)
    --self:sortColList()
    self:repositionPokers(self.colList, false, nil, true)
    self:refreshPokersState(self.colList)
end

function HandPokers:removePokerHolders(pokerHolderList)
    pokerHolderList = pokerHolderList or {}
    local contansFun = function(id, list)
        for k,v in pairs(list) do
            if(v.id== id)then
                return true
            end
        end
        return false
    end

	for i=1,#self.colList do
        local j = 1
        while j <= #self.colList[i] do
            local pokerHolder = self.colList[i][j]
            if(contansFun(pokerHolder.id, pokerHolderList))then
                table.remove( self.colList[i], j)
                self.usingHolderTable[pokerHolder.id] = nil
                self.unuseHolderQueue:push(pokerHolder)
                pokerHolder.selected = false
                self:setGrayColor(pokerHolder, pokerHolder.selected)
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
            else
                j = j + 1
            end
        end
    end    
end

function HandPokers:removeAll()
	for i=1,#self.colList do
        for j=1,#self.colList[i] do
            local pokerHolder = self.colList[i][j]
            self.usingHolderTable[pokerHolder.id] = nil
            self.unuseHolderQueue:push(pokerHolder)
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
        end
    end    
    self.colList = {}
end

function HandPokers:getSelectedPokers()
    local pokerHolderList = {}
    local pokerList = {}
    local codeList = {}
	for i=1,#self.colList do
		for j=1,#self.colList[i] do
			local pokerHolder = self.colList[i][j]
			if(pokerHolder.selected)then
				table.insert( pokerHolderList, pokerHolder)
                table.insert( pokerList, pokerHolder.poker)
                table.insert( codeList, pokerHolder.poker.code)
			end
		end
	end
    return pokerHolderList, pokerList, codeList
end

function HandPokers:removeEmptyList(colList)
    local i = 1
    while i <= #colList do
        if(#self.colList[i] == 0)then
            table.remove( self.colList, i )
        else
            i = i + 1
        end
    end
end


function HandPokers:selectPokers(codeList)
    local pokerHolderList = {}
    local selectCodeList = {}
    local waitSelectedCodeCountTable = {}
    local selectedCodeCountTable = {}
    for i=1,#codeList do
        local code = codeList[i]
        if(not waitSelectedCodeCountTable[code])then
            waitSelectedCodeCountTable[code] = 0
        end
        waitSelectedCodeCountTable[code] = waitSelectedCodeCountTable[code] + 1
        selectedCodeCountTable[code] = 0
    end

    self:unSelectAllPokers()
    for i=1,#codeList do
        local code = codeList[i]
        for j=1,#self.colList do
            for k=1,#self.colList[j] do
                local pokerHolder = self.colList[j][k]
                if(pokerHolder.poker.code == code and (not pokerHolder.selected))then
                    if(waitSelectedCodeCountTable[code] > selectedCodeCountTable[code])then
                        selectedCodeCountTable[code] = selectedCodeCountTable[code] + 1
                        pokerHolder.selected = true
                        table.insert( pokerHolderList, pokerHolder)
                        table.insert( selectCodeList, code )
                    end
                end
            end
        end
    end
    return pokerHolderList
end

function HandPokers:unSelectAllPokers()
    local pokerHolderList = {}
    for i=1,#self.colList do
        for j=1,#self.colList[i] do
            local pokerHolder = self.colList[i][j]
            pokerHolder.selected = false
            table.insert( pokerHolderList, pokerHolder)
        end
    end
    return pokerHolderList
end

function HandPokers:resetPokers(withoutAnim, useMemory)
    local pokerHolderList = self:unSelectAllPokers()
    self.colList = {}
    self:sortList(pokerHolderList)
    local lastCode = 0
    local list = nil
    for i=1,#pokerHolderList do
        local pokerHolder = pokerHolderList[i]
        if(lastCode ~= pokerHolder.poker.name)then
            table.insert( self.colList, list )
            list = {}
        end
        lastCode = pokerHolder.poker.name
        table.insert( list, pokerHolder)
    end
    table.insert( self.colList, list )
    if(useMemory)then
        self:sort_as_memory_queue()
    end
    self:repositionPokers(self.colList, withoutAnim, nil, true)
    self:refreshPokersState(self.colList)
end

function HandPokers:genId()
    self.idGen = self.idGen + 1
    return self.idGen
end

function HandPokers:on_select_poker(obj)
	for i=1,#self.colList do
		for j=1,#self.colList[i] do
			local pokerHolder = self.colList[i][j]
			if(pokerHolder.root == obj)then
				pokerHolder.selected = pokerHolder.selected or false
				pokerHolder.selected = not pokerHolder.selected
                --print('on_select_poker', pokerHolder.root.name, pokerHolder.selected)
			end
			
		end
	end
end


function HandPokers:on_click(obj, arg)

end

function HandPokers:on_drag(obj, arg)
    local count = arg.hovered.Count
	for i=0,count - 1 do
		local go = arg.hovered[i]
		if(go and go.transform.parent and go.transform.parent == self.prefabPoker.transform.parent)then
			if(go ~= self.lastHoverPoker)then
				self.lastHoverPoker = go
				self:on_select_poker(go)
				self:refreshPokersState(self.colList)
			end
		end
	end
end

function HandPokers:on_press(obj, arg)
    if(obj.transform.parent == self.prefabPoker.transform.parent)then
        self.lastHoverPoker = obj
        self:on_select_poker(obj)
        self:refreshPokersState(self.colList)
    end
end

function HandPokers:on_press_up(obj, arg)
    self.lastHoverPoker = nil
end

function HandPokers:show_handPokers(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.prefabPoker.transform.parent.gameObject, show)  
end



return  HandPokers