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
local cardCommon = require('package.doudizhu.module.doudizhu_table.gamelogic_common')

local offsetY = 50

function HandPokers:initialize(module)
    self.idGen = 0
    self.view = module.view
    self.prefabPoker = module.view.prefabPoker
    self.colList = {}
    self.unuseHolderQueue = list:new()
    self.usingHolderTable = {}
    self.show_mingpai_tag = false
    self.show_lord_tag = false
end

function HandPokers:repositionPokers(colList, withoutAnim, onFinish)
    colList = colList or self.colList
    self:removeEmptyList(colList)
    local totalRow
    local colCount = #colList
    local offsetX = self:calcOffsetX(colCount)
    local sequence = self.view:create_sequence()
    local duration = 0.1
    for i=1,colCount do
        for j=#colList[i],1,-1 do
            local pos = self:calcPos(offsetX, offsetY, i, j, colCount)
            local pokerHolder = colList[i][j]
            local go = pokerHolder.root
            pos.z = go.transform.localPosition.z
            
            go.transform:SetAsLastSibling()
            if(withoutAnim)then
                go.transform.localPosition = pos
            else
                sequence:Join(go.transform:DOLocalMove(pos, duration, false))
            end
            if(i == colCount and j == #colList[i])then
                self:showPokerLordTag(pokerHolder, self.show_lord_tag)
                self:showPokerMingPaiTag(pokerHolder, self.show_mingpai_tag)
            else
                self:showPokerLordTag(pokerHolder, false)
                self:showPokerMingPaiTag(pokerHolder, false)
            end
        end
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
                if(onFinish)then
                    onFinish()
                end
            end)
        end

    end
end

function HandPokers:calcOffsetX(totalColCount)
    local defaultColCount = 17
    local minOffsetX = 53.46
    local maxOffsetX = 63.46
    local fullOffsetX = 63.46
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
        table.insert( self.colList, {pokerHolder})
    end
    
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

function HandPokers:genPokerHolder(poker, show)
    local pokerHolder = self.unuseHolderQueue:pop()
    if(not pokerHolder)then
        pokerHolder = {}
        pokerHolder.root = ModuleCache.ComponentUtil.InstantiateLocal(self.prefabPoker, self.prefabPoker.transform.parent.gameObject)
        pokerHolder.face = GetComponentWithPath(pokerHolder.root, "face", ComponentTypeName.Image);
        pokerHolder.back = GetComponentWithPath(pokerHolder.root, "back", ComponentTypeName.Image);
        pokerHolder.goLordTag = GetComponentWithPath(pokerHolder.root, "tagLord", ComponentTypeName.Image).gameObject
        pokerHolder.goMingPaiTag = GetComponentWithPath(pokerHolder.root, "tagMingPai", ComponentTypeName.Image).gameObject
    end
    show = show or false
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, show)
    self:showPokerLordTag(pokerHolder, false)
    self:showPokerMingPaiTag(pokerHolder, false)
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

function HandPokers:showPokerLordTag(pokerHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.goLordTag, show or false)
end

function HandPokers:showPokerMingPaiTag(pokerHolder, show)
    ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.goMingPaiTag, show or false)
end

function HandPokers:sortList(list)
    table.sort(list, function(t1,t2)
        local name1 = t1.poker.name
        local name2 = t2.poker.name
        local color1 = t1.poker.color
        local color2 = t2.poker.color

        local result = self:sortFun(name1, color1, name2, color2)
        if(result == 0)then
            return t1.id > t2.id
        else
            return result < 0
        end
    end)
end

function HandPokers:sortFun(name1, color1, name2, color2)
    if(name1 == cardCommon.card_A)then
        name1 = cardCommon.card_K + 0.1
    elseif(name1 == cardCommon.card_2)then
        name1 = cardCommon.card_K + 0.2
    end
    if(name2 == cardCommon.card_A)then
        name2 = cardCommon.card_K + 0.1
    elseif(name2 == cardCommon.card_2)then
        name2 = cardCommon.card_K + 0.2
    end

    if(name1> name2)then
        return -1
    elseif(name1 == name2)then
        if(color1 < color2)then
            return -1
        elseif(color1 == color2)then
            return 0
        else
            return 1
        end
    else
        return 1
    end
end

function HandPokers:sortCodeList(list, oppo)
    table.sort( list, function(code1, code2) 
        local card1 = cardCommon.ResolveCardIdx(code1)
        local card2 = cardCommon.ResolveCardIdx(code2)
        local result = self:sortFun(card1.name, card1.color, card2.name, card2.color)
        if(oppo)then
            return result >= 0
        end
        return result < 0
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
    self:repositionPokers(self.colList)
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
                pokerHolder.real_selected = false
                self:setGrayColor(pokerHolder, pokerHolder.selected)
                ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
            else
                j = j + 1
            end
        end
    end    
end

function HandPokers:is_the_same(codeList)
    local sortFunction = function(list)
        table.sort(list, function(t1,t2)
                return t1 > t2
        end)
    end
    local list = {}
	for i=1,#self.colList do
        for j=1,#self.colList[i] do
            local pokerHolder = self.colList[i][j]
            table.insert(list, pokerHolder.poker.code)
        end
    end   
    if(#list ~= #codeList)then
        return false
    end
    sortFunction(list)
    sortFunction(codeList)
    for i=1,#list do
        if(list[i] ~= codeList[i])then
            return false
        end
    end
    return true
end

function HandPokers:removeAll()
	for i=1,#self.colList do
        for j=1,#self.colList[i] do
            local pokerHolder = self.colList[i][j]
            self.usingHolderTable[pokerHolder.id] = nil
            self.unuseHolderQueue:push(pokerHolder)
            pokerHolder.selected = false
            pokerHolder.real_selected = false
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
        end
    end    
    self.colList = {}
end

function HandPokers:getSelectedPokers()
    local pokerHolderList = {}
    local pokerList = {}
    local codeList = {}
    local real_pokerHolderList = {}
    local real_pokerList = {}
    local real_codeList = {}
	for i=1,#self.colList do
		for j=1,#self.colList[i] do
			local pokerHolder = self.colList[i][j]
			if(pokerHolder.selected)then
				table.insert( pokerHolderList, pokerHolder)
                table.insert( pokerList, pokerHolder.poker)
                table.insert( codeList, pokerHolder.poker.code)
			end
            if(pokerHolder.real_selected)then
				table.insert( real_pokerHolderList, pokerHolder)
                table.insert( real_pokerList, pokerHolder.poker)
                table.insert( real_codeList, pokerHolder.poker.code)
            end
		end
	end
    return pokerHolderList, pokerList, codeList, real_pokerHolderList, real_pokerList, real_codeList
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


function HandPokers:selectPokers(codeList, colList)
    colList = colList or self.colList
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
        for j=1,#colList do
            for k=1,#colList[j] do
                local pokerHolder = colList[j][k]
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

function HandPokers:unSelectAllPokers(colList)
    local pokerHolderList = {}
    local colList = colList or self.colList
    for i=1,#colList do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            pokerHolder.selected = false
            pokerHolder.real_selected = false
            table.insert( pokerHolderList, pokerHolder)
        end
    end
    return pokerHolderList
end

function HandPokers:resetPokers(withoutAnim, onFinish)
    local pokerHolderList = self:unSelectAllPokers()
    self.colList = {}
    self:sortList(pokerHolderList)
    for i=1,#pokerHolderList do
        local pokerHolder = pokerHolderList[i]
        table.insert( self.colList, {pokerHolder})
    end
    
    self:repositionPokers(self.colList, withoutAnim, onFinish)
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
	if(self.is_playing_select_poker_anim or self.is_playing_fapai_anim)then
		return
	end
    local count = arg.hovered.Count
	for i=0,count - 1 do
		local go = arg.hovered[i]
		if(go and go.transform.parent and go.transform.parent == self.prefabPoker.transform.parent)then
            if(not self.firstHoverPokerObj)then
                self.firstHoverPokerObj = go
            end
            self.lastHoverPokerObj = go
            self:on_draging_pokers()
            return
		end
	end
end

function HandPokers:on_press(obj, arg)
	if(self.is_playing_select_poker_anim or self.is_playing_fapai_anim)then
		return
	end
    if(obj.transform.parent == self.prefabPoker.transform.parent)then
        self.firstHoverPokerObj = obj    
        self.lastHoverPokerObj = obj
        self:on_draging_pokers()    
    end
end

function HandPokers:on_press_up(obj, arg)
	if(self.is_playing_select_poker_anim or self.is_playing_fapai_anim)then
		return
	end
    self.lastHoverPoker = nil
    self.updateDrag = nil
    if(obj.transform.parent == self.prefabPoker.transform.parent)then
        if(not self.firstHoverPokerObj)then
            self.firstHoverPokerObj = obj
        end
        if(not self.lastHoverPokerObj)then
            self.lastHoverPokerObj = obj
        end
    end
    if(self.lastHoverPokerObj)then
        self:on_draging_pokers()
        self:on_finish_drag_pokers()
    end
end

function HandPokers:on_draging_pokers()
    self:check_drag_mark()
    self:refreshPokerMarkState()
end

function HandPokers:on_finish_drag_pokers()
    self.firstHoverPokerObj = nil
    self.lastHoverPokerObj = nil
    local markedList, selectedList = self:check_poker_selected_state()
    self:markAllPokers(false)
    self:refreshPokerMarkState()
    if(#markedList > 1 and #selectedList > 1 and self.on_finish_drag_pokers_reselect_fun)then
        self.on_finish_drag_pokers_reselect_fun()
    else
        self.is_playing_select_poker_anim = true
        self:refreshPokerSelectState(false, function()
            self.is_playing_select_poker_anim = false
        end)
    end
end

function HandPokers:check_drag_mark()
    local startObj = nil
    local isLeftPokersUnMark = false
    for i=1,#self.colList do
        for j=1,#self.colList[i] do
            local pokerHolder = self.colList[i][j]
            if(isLeftPokersUnMark)then
                pokerHolder.marked = false
            else
                if(pokerHolder.root == self.firstHoverPokerObj)then
                    pokerHolder.marked = true
                    if(startObj or pokerHolder.root == self.lastHoverPokerObj)then
                        isLeftPokersUnMark = true
                    else
                        startObj = pokerHolder.root
                    end
                elseif(pokerHolder.root == self.lastHoverPokerObj)then
                    pokerHolder.marked = true
                    if(startObj or pokerHolder.root == self.firstHoverPokerObj)then
                        isLeftPokersUnMark = true
                    else
                        startObj = pokerHolder.root
                    end
                else
                    if(startObj)then
                        pokerHolder.marked = true
                    else
                        pokerHolder.marked = false
                    end
                end
            end
			
        end
    end
end

function HandPokers:check_poker_selected_state()
    local colList = self.colList
    local markedList = {}
    local selectedList = {}
    local real_selectedList = {}
    for i=1,#colList do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            --print('-----------', pokerHolder.root.name, pokerHolder.selected, pokerHolder.marked)
            if(pokerHolder.marked)then
                pokerHolder.selected = not (pokerHolder.selected or false)
                table.insert( markedList, pokerHolder)
                if(pokerHolder.selected)then
                    table.insert( selectedList, pokerHolder)
                end
                if(pokerHolder.real_selected)then
                    table.insert( real_selectedList, pokerHolder)
                end
            end
        end
    end
    return markedList, selectedList, real_selectedList
end

function HandPokers:markAllPokers(isMark)
    isMark = isMark or false
    local colList = self.colList
    for i=1,#colList do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            pokerHolder.marked = isMark
        end
    end
end

function HandPokers:refreshPokerMarkState()
    local colList = self.colList
    for i=1,#colList do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            self:setGrayColor(pokerHolder, pokerHolder.marked)
        end
    end
end

function HandPokers:refreshPokerSelectState(withoutAnim, onFinish)
    local colList = self.colList
    local totalCount = #colList
    local finishCount = 0
    for i=1,totalCount do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            local selected = pokerHolder.selected
            self:playSelectPokerAnim(pokerHolder.root, selected, withoutAnim, function()
                if(selected)then
                    pokerHolder.real_selected = true
                else
                    pokerHolder.real_selected = false
                end
                finishCount = finishCount + 1
                if(finishCount == totalCount)then
                    if(onFinish)then
                        onFinish()
                    end
                end
            end)
        end
    end
end

function HandPokers:playSelectPokerAnim(go, selected, withoutAnim, onFinish)
    local sequence = self.view:create_sequence()
    local duration = 0.1
    local posY = 0
    if(selected)then
        posY = 32
    end
    local targetPos = go.transform.localPosition
    targetPos.y = posY
    if(withoutAnim)then
        go.transform.localPosition = targetPos
        if(onFinish)then
            onFinish()
        end
    else
        sequence:Append(go.transform:DOLocalMove(targetPos, duration, false))
        sequence:OnComplete(function()
            if(onFinish)then
                onFinish()
            end
        end)
    end
end

function HandPokers:playFaPaiAnim(onFinish)
    local colList = self.colList
    self:removeEmptyList(colList)
    local totalRow
    local colCount = #colList
    local offsetX = self:calcOffsetX(colCount)
    local sequence = self.view:create_sequence()
    local duration = 0.24
    for i=1,colCount do
        for j=#colList[i],1,-1 do
            local pos = self:calcPos(offsetX, offsetY, i, j, colCount)
            local go = colList[i][j].root
            pos.z = go.transform.localPosition.z
            
            local nextGo = nil
            if(i + 1 <= colCount)then
                nextGo = colList[i + 1][1].root
            end
            if(i == 1)then
                ModuleCache.ComponentUtil.SafeSetActive(go, true)
                go.transform.localPosition = pos
            else
                ModuleCache.ComponentUtil.SafeSetActive(go, false)
            end
            go.transform:SetAsLastSibling()
            sequence:Append(go.transform:DOLocalMove(pos, duration, false):SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
                if(nextGo)then
                    ModuleCache.ComponentUtil.SafeSetActive(nextGo, true)  
                    nextGo.transform.localPosition = pos
                end
            end))
        end
    end
    if(colCount == 0)then
        if(onFinish)then
            onFinish()
        end
    else
        self.is_playing_fapai_anim = true
        sequence:OnComplete(function ()
            self.is_playing_fapai_anim = false
            if(onFinish)then
                onFinish()
            end
        end)
    end
end

function HandPokers:show_handPokers(show, showChild)
    ModuleCache.ComponentUtil.SafeSetActive(self.prefabPoker.transform.parent.gameObject, show)  
    local colList = self.colList
    for i=1,#colList do
        for j=#colList[i],1,-1 do
            local go = colList[i][j].root
            ModuleCache.ComponentUtil.SafeSetActive(go, showChild or false)
        end
    end
end


function HandPokers:update()
    if(self.updateDrag)then
        self.updateDrag()
    end
end

return  HandPokers