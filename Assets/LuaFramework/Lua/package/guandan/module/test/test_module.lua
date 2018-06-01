--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local ModuleBase = require('core.mvvm.module_base')
local TestModule = class('TestModule', ModuleBase)
local CardCommon = require('package.guandan.module.guandan_table.gamelogic_common')
local CardPattern = require('package.guandan.module.guandan_table.gamelogic_pattern')
local CardSet = require('package.guandan.module.guandan_table.gamelogic_set')

function TestModule:initialize(...)
	ModuleBase.initialize(self, "test_view", nil, ...)
	self.packageName = "guandan"
	self.moduleName = "test"
	self.config = require('package.guandan.config')
	self.myHandPokers = (require("package/guandan/module/guandan_table/handpokers")):new(self)
	self:init()
	--UpdateBeat:Add(self.UpdateBeat, self)
end


function TestModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if(obj == self.view.buttonSequence.gameObject)then
		self:on_click_tishi_btn(obj, arg)
	end

end

function TestModule:init()
	self.lastPattern = nil
	self.major_card = CardCommon.card_2
	local codeList = {       CardCommon.FormatCardIndex(CardCommon.card_big_king,1)
                    ,CardCommon.FormatCardIndex(2,3)
                    ,CardCommon.FormatCardIndex(2,2)
                    ,CardCommon.FormatCardIndex(1,4)
                    ,CardCommon.FormatCardIndex(1,4)
                    ,CardCommon.FormatCardIndex(13,2)
                    ,CardCommon.FormatCardIndex(12,1)
                    ,CardCommon.FormatCardIndex(12,3)
                    ,CardCommon.FormatCardIndex(12,3)
                    ,CardCommon.FormatCardIndex(12,4)
                    ,CardCommon.FormatCardIndex(11,1)
                    ,CardCommon.FormatCardIndex(11,2)
                    ,CardCommon.FormatCardIndex(9,2)
                    ,CardCommon.FormatCardIndex(8,2)
                    ,CardCommon.FormatCardIndex(7,1)
                    ,CardCommon.FormatCardIndex(7,1)
                    ,CardCommon.FormatCardIndex(7,2)
                    ,CardCommon.FormatCardIndex(7,2)
                    ,CardCommon.FormatCardIndex(6,3)
                    ,CardCommon.FormatCardIndex(5,1)
                    ,CardCommon.FormatCardIndex(5,2)
                    ,CardCommon.FormatCardIndex(4,4)
                    ,CardCommon.FormatCardIndex(4,4)
                    ,CardCommon.FormatCardIndex(4,3)
                    ,CardCommon.FormatCardIndex(4,3)
                    ,CardCommon.FormatCardIndex(3,3)
                    ,CardCommon.FormatCardIndex(3,3)
                    
                    }
	-- self.handCardSet = CardSet.new(codeList);
	-- self.myHandPokers:genPokerHolderList(codeList, self.major_card, false)
	-- self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
	-- self.myHandPokers:resetPokers()	
	-- self.tiShiFunction = self.handCardSet:hintIterator(self.lastPattern)

	codeList = {
		45,
		47,
		49,
		51,
		3,
		4,
	}
	local logic_cards = {
		0,
		0,
		0,
		0,
		0,
	}
	local list = CardPattern.new(codeList, logic_cards)
	self:sort_pattern_by_type(list[1])

	codeList = list[1].sorted_cards
	print_table(codeList)
	self.handCardSet = CardSet.new(codeList);
	self.myHandPokers:genPokerHolderList(codeList, self.major_card, false)
	self.myHandPokers:repositionPokers(self.myHandPokers.colList, true)
	--self.myHandPokers:resetPokers()	
	self.tiShiFunction = self.handCardSet:hintIterator(self.lastPattern)

end

function TestModule:on_click_tishi_btn(obj, arg)

	
	local pattern = self.tiShiFunction()
	if(pattern)then
		print_table(pattern)
	end
	
	self.myHandPokers:selectPokers(pattern.cards)
	self.myHandPokers:refreshPokersState(self.myHandPokers.colList)
end


function TestModule:sort_pattern_by_type(pattern)
	local cardCommon = CardCommon
	local sortedCardHolderList = {}
	local name_count_table = {}
	for i=1,#pattern.cards do
		local holder = {}
		holder.cardCode = pattern.cards[i]
		holder.logic_cardCode = pattern.logic_cards[i]
		if(pattern.logic_cards[i] and pattern.logic_cards[i] ~= 0)then
			holder.card = CardCommon.ResolveCardIdx(pattern.logic_cards[i])
		else
			holder.card = CardCommon.ResolveCardIdx(pattern.cards[i])
		end
		if(not name_count_table[holder.card.name])then
			name_count_table[holder.card.name] = 0
		end
		name_count_table[holder.card.name] = name_count_table[holder.card.name] + 1
		holder.id = i
		sortedCardHolderList[i] = holder
	end
	print_table(sortedCardHolderList)
	print_table(name_count_table)
	local type = pattern.type
	table.sort( sortedCardHolderList, function(t1,t2) 
		if(t1.card.name == t2.card.name)then
			if(t1.card.color == t2.card.color)then
				return t1.id > t2.id
			end
			return t1.card.color > t2.card.color
		else
			if(type == CardCommon.type_three_p2)then
				return name_count_table[t1.card.name] > name_count_table[t2.card.name]
			else
				if(type == CardCommon.type_five_same_color
				or type == CardCommon.type_single_5
				or type == CardCommon.type_triple2
				or type == CardCommon.type_double3)then
					if(t1.card.name == cardCommon.card_A and t2.card.name ~= cardCommon.card_A)then
						if(name_count_table[cardCommon.card_K] and name_count_table[cardCommon.card_K] ~= 0)then
							local result = t1.card.name < t2.card.name
							return result
						end
					elseif(t2.card.name == cardCommon.card_A and t1.card.name ~= cardCommon.card_A)then
						if(name_count_table[cardCommon.card_K] and name_count_table[cardCommon.card_K] ~= 0)then
							local result = t1.card.name < t2.card.name
							return result
						end
					end

				end
				return t1.card.name > t2.card.name
			end
			
		end
	end)
	pattern.sorted_cards = {}
	pattern.sorted_logic_cards = {}
	for i=1,#sortedCardHolderList do
		pattern.sorted_cards[i] = sortedCardHolderList[i].cardCode
		pattern.sorted_logic_cards[i] = sortedCardHolderList[i].logic_cardCode
	end
end

function TestModule:on_update()
	local codeList = self:RandomCodeList(math.random( 1,8 ))
	local patternList = CardPattern.new(codeList)
	if(not patternList)then
		print_table(codeList)
	end
end

function TestModule:RandomCodeList(len)
	local codeList = {}
	local codeNumTable = {}
	local count = 0
	while count < len do
		local code = CardCommon.FormatCardIndex(math.random(1, 13),math.random(1, 4))
		if(not codeNumTable[code])then
			codeNumTable[code] = 0
		end
		if(codeNumTable[code] < 2)then
			table.insert( codeList, code)
			codeNumTable[code] = codeNumTable[code] + 1
			count = count + 1
		end
	end
	return codeList
end

return  TestModule