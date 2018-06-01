--
-- Author:深红dred
-- Date: 2017-03-20 03:31:24
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence;

local list = require('list')
local class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
---@class WuShiKHandPokers
---@field view WuShiKTableBaseView
local HandPokers = class('handPokers')
local CardCommon = require('package.wushik.module.table.gamelogic_common')

local offsetY = 80
local first_row_max_col_count = 27

function HandPokers:initialize(module)
    self.idGen = 0
    self.view = module.view
    self.prefabPoker = module.view.prefabPoker
    self.colList = {}
    self.unuseHolderQueue = list:new()
    self.usingHolderTable = {}
    self.show_mingpai_tag = false
    self.sort_pattern_type = UnityEngine.PlayerPrefs.GetInt('wushik_sort_pattern_type', 1)
end

function HandPokers:setMagicCards(useMagicCards, magicCards)
    self._useMagicCards = useMagicCards
    self._magicCards = {}
    for i = 1, #magicCards do
        self._magicCards[i] = magicCards[i]
    end
end

function HandPokers:isMagicCard(code)
    if(not self._useMagicCards)then
        return false
    end
    for i, v in pairs(self._magicCards) do
        if(code == v)then
            return true
        end
    end
    return false
end

function HandPokers:setTeamCard(teamCard)
    self._teamCard = teamCard
end

function HandPokers:gen_poker_id()
    self._max_poker_id = (self._max_poker_id or 0) + 1
    return self._max_poker_id
end

function HandPokers:set_sort_pattern_type(type)
    self.sort_pattern_type = type or 1
    UnityEngine.PlayerPrefs.SetInt('wushik_sort_pattern_type', self.sort_pattern_type)
end

function HandPokers:repositionPokers(colList, withoutAnim, onFinish)
    colList = colList or self.colList
    self:removeEmptyList(colList)
    local totalRow
    local colCount = #colList
    local offsetX = self:calcOffsetX(colCount)
    local sequence = self.view:create_sequence()
    local duration = 0.1
    local index = 0
    for i=1,colCount do
        for j=#colList[i],1,-1 do
            index = index + 1
            local row = j
            local col = i
            local totalColCount = colCount
            if((colCount - index) >= first_row_max_col_count)then
                row = 2
                col = index
                totalColCount = colCount - first_row_max_col_count
            else
                row = 1
                if(colCount > first_row_max_col_count)then
                    col = first_row_max_col_count - (colCount - index)
                    totalColCount = first_row_max_col_count
                else
                    col = index
                end
            end
            local pos = self:calcPos(offsetX, offsetY, col, row, totalColCount)
            local pokerHolder = colList[i][j]
            pokerHolder.original_pos = pos
            local go = pokerHolder.root
            pos.z = go.transform.localPosition.z
            
            go.transform:SetAsLastSibling()
            if(withoutAnim)then
                go.transform.localPosition = pos
            else
                sequence:Join(go.transform:DOLocalMove(pos, duration, false))
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
    local minOffsetX = 44
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
        if(pokerHolder.original_color)then
            pokerHolder.face.color = pokerHolder.original_color
        else
            pokerHolder.face.color = UnityEngine.Color(1,1,1,1)
        end
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

function HandPokers:genPoker(code)
    local poker = {}
    poker.code = code
    poker.id = self:gen_poker_id()
    local card = CardCommon.solveCard(code)
    poker.name = card.name
    poker.color = card.color
    return poker
end

function HandPokers:genPokerList(codeList)
    local pokerList = {}
    for i=1,#codeList do
        local code = codeList[i]
        table.insert(pokerList, self:genPoker(code))
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
        pokerHolder.laiZiTag = GetComponentWithPath(pokerHolder.root, "tag", ComponentTypeName.Image);
        pokerHolder.daHuTag = GetComponentWithPath(pokerHolder.root, "dahuTag", ComponentTypeName.Image);
    end
    pokerHolder.original_color = nil
    show = show or false
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.root, show)
    pokerHolder.poker = poker
    self:showPokerDaHuTag(pokerHolder, false)
    if(poker.name == CardCommon.card_5 or poker.name == CardCommon.card_10 or poker.name == CardCommon.card_K)then
        self:showPokerDaHuTag(pokerHolder, true)
    end
    self:refreshTeamCardMask(pokerHolder)
    self:showPokerLaiZiTag(pokerHolder, self:isMagicCard(poker.code))
    local spriteName = self.view:getImageNameFromCode(poker.code)
    local sprite = self.view.myCardAssetHolder:FindSpriteByName(spriteName)
    if(not sprite)then
        print(spriteName)
    end
    pokerHolder.show_code = poker.code
    pokerHolder.face.sprite = sprite
    pokerHolder.root.name = spriteName
    pokerHolder.id = self:genId()
    self.usingHolderTable[pokerHolder.id] = pokerHolder
    return pokerHolder
end

function HandPokers:refreshTeamCardMask(pokerHolder)
    local poker = pokerHolder.poker
    if(poker.code == self._teamCard)then
        pokerHolder.original_color = UnityEngine.Color.New(0xc8/0xff, 0xd2/0xff, 0xe9/0xff, 1)
        pokerHolder.face.color = pokerHolder.original_color
    end
end

function HandPokers:refreshAllPokerFace()
    for i, v in pairs(self.usingHolderTable) do
        local pokerHolder = v
        if(pokerHolder.show_code)then
            local spriteName = self.view:getImageNameFromCode(pokerHolder.show_code)
            local sprite = self.view.myCardAssetHolder:FindSpriteByName(spriteName)
            pokerHolder.face.sprite = sprite
        end
    end
end

function HandPokers:showPokerLaiZiTag(pokerHolder, show)
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.laiZiTag.gameObject, show or false)
end

function HandPokers:showPokerDaHuTag(pokerHolder, show)
    ModuleCache.ComponentManager.SafeSetActive(pokerHolder.daHuTag.gameObject, show or false)
end

function HandPokers:sortList(list)
    if(true)then    --使用服务器的排序
        return
    end
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
    if(name1 == CardCommon.card_A)then
        name1 = CardCommon.card_K + 0.1
    elseif(name1 == CardCommon.card_2)then
        name1 = CardCommon.card_K + 0.2
    end
    if(name2 == CardCommon.card_A)then
        name2 = CardCommon.card_K + 0.1
    elseif(name2 == CardCommon.card_2)then
        name2 = CardCommon.card_K + 0.2
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

function HandPokers:sortCodeList(list)
    table.sort( list, function(code1, code2) 
        local card1 = CardCommon.solveCard(code1)
        local card2 = CardCommon.solveCard(code2)
        local result = self:sortFun(card1.name, card1.color, card2.name, card2.color)
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
        if(t1.poker.name == CardCommon.card_A)then
            name1 = CardCommon.card_K + 0.1
        end
        if(t2.poker.name == CardCommon.card_A)then
            name2 = CardCommon.card_K + 0.1
        end

        --if(t1.poker.majorCardLevel == 1)then
        --    name1 = CardCommon.card_small_king - 0.2
        --end
        --if(t1.poker.majorCardLevel == 2)then
        --    name1 = CardCommon.card_small_king - 0.1
        --end
        --if(t2.poker.majorCardLevel == 1)then
        --    name2 = CardCommon.card_small_king - 0.2
        --end
        --if(t2.poker.majorCardLevel == 2)then
        --    name2 = CardCommon.card_small_king - 0.1
        --end
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
                pokerHolder.selected_time = 0
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
                pokerHolder.selected_time = 0
                pokerHolder.real_selected = false
                pokerHolder.real_selected_time = 0
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
            pokerHolder.selected = false
            pokerHolder.selected_time = 0
            pokerHolder.real_selected = false
            pokerHolder.real_selected_time = 0
            ModuleCache.ComponentUtil.SafeSetActive(pokerHolder.root, false)
        end
    end    
    self.colList = {}
end

function HandPokers:getSelectedPokers()
    local pokerHolderList = {}
    local pokerList = {}
    local codeList = {}
    local idList = {}
    local real_pokerHolderList = {}
    local real_pokerList = {}
    local real_codeList = {}
    local realIdList = {}
	for i=1,#self.colList do
		for j=1,#self.colList[i] do
			local pokerHolder = self.colList[i][j]
			if(pokerHolder.selected)then
				table.insert( pokerHolderList, pokerHolder)
                table.insert( pokerList, pokerHolder.poker)
                table.insert( codeList, pokerHolder.poker.code)
                table.insert( idList, pokerHolder.poker.id)
			end
            if(pokerHolder.real_selected)then
				table.insert( real_pokerHolderList, pokerHolder)
                table.insert( real_pokerList, pokerHolder.poker)
                table.insert( real_codeList, pokerHolder.poker.code)
                table.insert( realIdList, pokerHolder.poker.id)
            end
		end
	end
    --print_table(pokerList, 'pokerList')
    --print_table(real_pokerList, 'real_pokerList')
    return pokerHolderList, pokerList, codeList, idList, real_pokerHolderList, real_pokerList, real_codeList, realIdList
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


function HandPokers:selectPokers(codeList, idList, colList)
    colList = colList or self.colList
    local pokerHolderList = {}
    local selectCodeList = {}
    local waitSelectedCodeCountTable = {}
    local selectedCodeCountTable = {}

    local useIdFind = idList and #idList > 0
    local tmpList = codeList
    if(useIdFind)then
        tmpList = idList
    end


    for i=1,#tmpList do
        local index = tmpList[i]
        if(not waitSelectedCodeCountTable[index])then
            waitSelectedCodeCountTable[index] = 0
        end
        waitSelectedCodeCountTable[index] = waitSelectedCodeCountTable[index] + 1
        selectedCodeCountTable[index] = 0
    end

    self:unSelectAllPokers()
    for i=1,#tmpList do
        local index = tmpList[i]
        for j=1,#colList do
            for k=1,#colList[j] do
                local pokerHolder = colList[j][k]
                local pokerIndex = pokerHolder.poker.code
                if(useIdFind)then
                    pokerIndex = pokerHolder.poker.id
                end
                if(pokerIndex == index and (not pokerHolder.selected))then
                    if(waitSelectedCodeCountTable[index] > selectedCodeCountTable[index])then
                        selectedCodeCountTable[index] = selectedCodeCountTable[index] + 1
                        pokerHolder.selected = true
                        pokerHolder.selected_time = self:getTimeIndex()
                        table.insert( pokerHolderList, pokerHolder)
                        table.insert( selectCodeList, pokerHolder.poker.code)
                    end
                end
            end
        end
    end
    return pokerHolderList
end

function HandPokers:selectPokerHolders(target_pokerHolderList, colList)
    colList = colList or self.colList
    local pokerHolderList = {}
    local selectCodeList = {}
    local waitSelectedCodeCountTable = {}
    local selectedCodeCountTable = {}
    for i=1,#target_pokerHolderList do
        local code = target_pokerHolderList[i].poker.code
        if(not waitSelectedCodeCountTable[code])then
            waitSelectedCodeCountTable[code] = 0
        end
        waitSelectedCodeCountTable[code] = waitSelectedCodeCountTable[code] + 1
        selectedCodeCountTable[code] = 0
    end

    self:unSelectAllPokers()
    for i=1,#target_pokerHolderList do
        local target_pokerHolder = target_pokerHolderList[i]
        local code = target_pokerHolder.poker.code
        for j=1,#colList do
            for k=1,#colList[j] do
                local pokerHolder = colList[j][k]

                if(pokerHolder == target_pokerHolder and (not pokerHolder.selected))then
                    if(waitSelectedCodeCountTable[code] > selectedCodeCountTable[code])then
                        selectedCodeCountTable[code] = selectedCodeCountTable[code] + 1
                        pokerHolder.selected = true
                        pokerHolder.selected_time = self:getTimeIndex()
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
            pokerHolder.selected_time = 0
            pokerHolder.real_selected = false
            pokerHolder.real_selected_time = 0
            table.insert( pokerHolderList, pokerHolder)
        end
    end
    return pokerHolderList
end

function HandPokers:resetPokers(withoutAnim, onFinish)
    local pokerHolderList = self:unSelectAllPokers()
    self.colList = {}
    --self:sortList(pokerHolderList)
    for i=1,#pokerHolderList do
        local pokerHolder = pokerHolderList[i]
        table.insert( self.colList, {pokerHolder})
    end
    
    self:repositionPokers(self.colList, withoutAnim, function()
        if(onFinish)then
            onFinish()
        end
        if(self.on_select_pokers_changed)then
            self.on_select_pokers_changed()
        end
    end)
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
                if(pokerHolder.selected)then
                    pokerHolder.selected_time = self:getTimeIndex()
                else
                    pokerHolder.selected_time = 0
                end
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
	if(self.is_playing_select_poker_anim  or self.is_playing_fapai_anim)then
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
    if(self.custom_on_finish_drag_pokers_fun)then
        self.custom_on_finish_drag_pokers_fun()
        return
    end
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
                    pokerHolder.selected_time = self:getTimeIndex()
                else
                    pokerHolder.selected_time = 0
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

function HandPokers:refreshAllPokerTeamCardMask()
    local colList = self.colList
    for i=1,#colList do
        for j=1,#colList[i] do
            local pokerHolder = colList[i][j]
            self:refreshTeamCardMask(pokerHolder)
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
            self:playSelectPokerAnim(pokerHolder.root, pokerHolder.original_pos, selected, withoutAnim, function()
                if(selected)then
                    pokerHolder.real_selected = true
                    pokerHolder.real_selected_time = self:getTimeIndex()
                else
                    pokerHolder.real_selected = false
                    pokerHolder.real_selected_time = 0
                end
                finishCount = finishCount + 1
                if(finishCount == totalCount)then
                    if(onFinish)then
                        onFinish()
                    end
                    if(self.on_select_pokers_changed)then
                        self.on_select_pokers_changed()
                    end
                end
            end)
        end
    end
end

function HandPokers:playSelectPokerAnim(go, original_pos, selected, withoutAnim, onFinish)
    local sequence = self.view:create_sequence()
    local duration = 0.1
    local posY = 0
    if(selected)then
        posY = 29
    end
    local targetPos = go.transform.localPosition
    targetPos.y = original_pos.y + posY
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

function HandPokers:playFaPaiAnim(onFinish, playFaPaiSoundFun)
    local colList = self.colList
    self:removeEmptyList(colList)
    local totalRow
    local colCount = #colList
    local offsetX = self:calcOffsetX(colCount)
    local sequence = self.view:create_sequence()
    local duration = 0.075
    local index = 0
    for i=1,colCount do
        for j=#colList[i],1,-1 do
            index = index + 1
            local row = j
            local col = i
            local isFirstOne = i == 1
            local keep_original = i == 1
            local totalColCount = colCount
            if((colCount - index) >= first_row_max_col_count)then
                row = 2
                col = index
                totalColCount = colCount - first_row_max_col_count
            else
                row = 1
                if(colCount > first_row_max_col_count)then
                    col = first_row_max_col_count - (colCount - index)
                    totalColCount = first_row_max_col_count
                else
                    col = index
                end
                if(col == 1)then
                    keep_original = true
                end
            end
            local pos = self:calcPos(offsetX, offsetY, col, row, totalColCount)
            local pokerHolder = colList[i][j]
            pokerHolder.original_pos = pos
            local go = pokerHolder.root
            pos.z = go.transform.localPosition.z
            
            local nextGo = nil
            if(i + 1 <= colCount)then
                nextGo = colList[i + 1][1]
            end
            if(isFirstOne)then
                ModuleCache.ComponentUtil.SafeSetActive(go, true)
                go.transform.localPosition = pos
            else
                ModuleCache.ComponentUtil.SafeSetActive(go, false)
                if(keep_original)then
                    go.transform.localPosition = pos
                    pokerHolder.keep_original = true
                end
            end
            go.transform:SetAsLastSibling()
            sequence:Append(go.transform:DOLocalMove(pos, duration, false):SetEase(DG.Tweening.Ease.Linear):OnComplete(function()
                if(playFaPaiSoundFun)then
                    playFaPaiSoundFun()
                end
                if(nextGo)then
                    ModuleCache.ComponentUtil.SafeSetActive(nextGo.root, true)  
                    if(not nextGo.keep_original)then
                        nextGo.root.transform.localPosition = pos
                    end
                end
            end)):OnStart(function()

            end)
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

function HandPokers:getTimeIndex()
    self.timeIndex = self.timeIndex or 0
    self.timeIndex = self.timeIndex + 1
    return self.timeIndex
end

return  HandPokers