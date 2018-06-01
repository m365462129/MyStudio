
local cardCommon = require('package.daigoutui.module.table.gamelogic_common')
local TableSound = {}

local packageName = 'daigoutui'
local malePath = 'daigoutui/sound/man/'
local femalePath = 'daigoutui/sound/woman/'
local effectPath = 'daigoutui/sound/effect/'
local musicPath = 'daigoutui/sound/music/'

local do_not_use_sound = true

--播放牌型音效
function TableSound:playPokerTypeSound(male, pattern, srcPattern)
	local path = femalePath
	if(male)then
		path = malePath
	end
	local type = pattern.type
	local disp_type = pattern.disp_type
	if(srcPattern)then
		-- print(srcPattern.type, type, disp_type)
		if(srcPattern.type == type)then
			if(type ~= cardCommon.type_single
			and type ~= cardCommon.type_double)then
				self:playDaNiSound(male)
				return
			end
		end
	end

	if(type == cardCommon.type_unknown)then
		return
	elseif(type == cardCommon.type_single)then
		type = 'single_'
	elseif(type == cardCommon.type_double)then
		type = 'dui'
	elseif(type == cardCommon.type_sequence_double)then		--三连对
		local soundName = 'liandui'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_triple)then		
		local soundName = 'sanzhang'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_triple_p2)then		
		local soundName = 'sandaidui'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_sequence_triple)then		--3顺
		local soundName = '3shun'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_sequence_triple_p2)then		--蝴蝶
		local soundName = 'butterfly'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_sequence_single)then		--顺子
		local soundName = 'shunzi'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_bomb)then		
		local soundName = 'zhadan'
		self:playSound(path .. soundName, soundName)
		return
	end
	
	local name = cardCommon.Value2Name(pattern.value)
	if(name == cardCommon.card_unknown)then
		return
	end
	local soundName = type .. name
	print(type, name)
	if(soundName == 'dui14' or soundName == 'dui15')then
		return
	end
	self:playSound(path .. soundName, soundName)
end

--播放牌型特效音
function TableSound:playPokerTypeEffectSound(pattern)
	local type = pattern.type
	if(type == cardCommon.type_unknown)then

	elseif(type == cardCommon.type_sequence_double)then		--连对
		self:playCommonEffectSound()
		return
	elseif(type == cardCommon.type_triple_p2)then		--3带2
		self:playCommonEffectSound()
		return
	elseif(type == cardCommon.type_sequence_triple)then		--三顺
		self:playCommonEffectSound()
		return
	elseif(type == cardCommon.type_sequence_triple_p2)then		--蝴蝶
		self:playHuDieEffectSound()
		return
	elseif(type == cardCommon.type_sequence_single)then		--顺子
		self:playCommonEffectSound()
		return
	elseif(type == cardCommon.type_bomb)then		
		self:playZhaDanEffectSound()
		return
	else
		self:playPiaEffectSound()
	end
end

--播放‘pia’
function TableSound:playPiaEffectSound()
	local soundName = 'special_give'
	self:playSound(effectPath .. soundName, soundName)
end

--播放过牌音效
function TableSound:playPassSound(male)
	local path = femalePath .. 'action/'
	if(male)then
		path = malePath .. 'action/'
	end
	local list = {'buyao1', 'buyao2', 'buyao3'}
	local soundName = list[math.random( 1,#list)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playDaNiSound(male)
	local path = femalePath .. 'action/'
	if(male)then
		path = malePath .. 'action/'
	end
	local list = {'dani1', 'dani2'}
	local soundName = list[math.random( 1,#list)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playFaPaiSound()
	local soundName = 'fapai'
	self:playSound(effectPath .. soundName, soundName)
end


--播放警告音效
function TableSound:playWarningSound(male, single)
	local path = femalePath .. 'action/'
	if(male)then
		path = malePath .. 'action/'
	end
	local soundName = 'baojing1'
	if(not single)then
		soundName = 'baojing2'
	end
	self:playSound(path .. soundName, soundName)
end

--播放明牌音效
function TableSound:playMingPaiSound(male)
	local path = femalePath .. 'action/'
	if(male)then
		path = malePath .. 'action/'
	end
	local soundName = 'share'
	self:playSound(path .. soundName, soundName)
end

--时间快到的提示音
function TableSound:playRemind()
	local soundName = 'remind'
	self:playSound(effectPath .. soundName, soundName)
end

--播放蝴蝶特效音
function TableSound:playHuDieEffectSound()
	local soundName = 'hudie'
	self:playSound(effectPath .. soundName, soundName)
end

--播放炸弹特效音
function TableSound:playZhaDanEffectSound()
	local soundName = 'bomb'
	self:playSound(effectPath .. soundName, soundName)
end


function TableSound:playCommonEffectSound()
	local soundName = 'common'
	self:playSound(effectPath .. soundName, soundName)
end

function TableSound:playGameLoseSound()
	local soundName = 'gamelose'
	self:playSound(effectPath .. soundName, soundName)
end

function TableSound:playGameWinSound()
	local soundName = 'gamewin'
	self:playSound(effectPath .. soundName, soundName)
end

function TableSound:playMathWinSound()
	local soundName = 'gamewin'
	self:playSound(effectPath .. soundName, soundName)
end

--播放选牌音效
function TableSound:playSelectCardEffectSound()
	local soundName = 'select_card'
	self:playSound(effectPath .. soundName, soundName)
end

--播放狗腿牌亮相音效
function TableSound:playServantCardShowEffectSound()
	local soundName = 'servant_card_show'
	self:playSound(effectPath .. soundName, soundName)
end

function TableSound:playSound(fullpath, soundName)
	if(false)then
		return
	end
	--print(fullpath, soundName)
	ModuleCache.SoundManager.play_sound(packageName, fullpath .. ".bytes", soundName)
end

function TableSound:playMusic(fullpath, soundName)
	if(false)then
		return
	end
	ModuleCache.SoundManager.play_music(packageName, fullpath .. ".bytes", soundName)
end

--播放背景音乐
function TableSound:playBgm()
	local list = {'bg1'}
	local soundName = list[math.random( 1,#list)]
	self:playMusic(musicPath .. soundName, soundName)
end

return TableSound
