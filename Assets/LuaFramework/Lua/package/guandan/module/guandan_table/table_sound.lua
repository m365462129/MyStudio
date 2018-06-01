
local cardCommon = require('package.guandan.module.guandan_table.gamelogic_common')
local TableSound = {}

local packageName = 'guandan'
local malePath = 'guandan/sound/man/'
local femalePath = 'guandan/sound/woman/'
local commonPath = 'guandan/sound/common/'

--播放牌型音效
function TableSound:playPokerTypeSound(male, pattern, srcPattern)
	local maleStr = ''
	local path = femalePath
	if(male)then
		maleStr = 'm_'
		path = malePath
	end
	local type = pattern.type
	if(srcPattern)then
		if(srcPattern.type == type)then
			if(type ~= cardCommon.type_single
			and type ~= cardCommon.type_double
			and type ~= cardCommon.type_three)then
				self:playDaNiSound(male)
				return
			end
		end
	end

	if(type == cardCommon.type_unknown)then
		return
	elseif(type == cardCommon.type_single)then
		type = '1z'
	elseif(type == cardCommon.type_single_5)then	--顺子
		local soundName = maleStr .. 'pokershunzi'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_double)then
		type = '1d'
	elseif(type == cardCommon.type_triple2)then		--三连对
		local soundName = maleStr .. 'pokerliandui'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_three)then		--三张
		type = '3z'
	elseif(type == cardCommon.type_three_p2)then		--三带2
		local soundName = maleStr .. 'poker3d2'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_double3)then		--飞机
		local soundName = maleStr .. 'pokerfeiji'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_four)then		
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_five)then		
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_five_same_color)then		--同花顺
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_six)then		
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_seven)then
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_eight)then
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.type_four_king)then
		local soundName = maleStr .. 'pokerzhadan'
		self:playSound(path .. soundName, soundName)
		return
	end

	local name = cardCommon.Value2Name(pattern.value)
	if(name == cardCommon.card_unknown)then
		return
	elseif(name == cardCommon.card_small_king)then
		name = 'xiaowang'
	elseif(name == cardCommon.card_big_king)then
		name = 'dawang'
	end
	local soundName = maleStr .. type .. name
	self:playSound(path .. soundName, soundName)
end

--播放牌型特效音
function TableSound:playPokerTypeEffectSound(pattern)
	local type = pattern.type

	if(type == cardCommon.type_unknown)then
	elseif(type == cardCommon.type_single)then
	elseif(type == cardCommon.type_single_5)then	--顺子
		self:playShunZiEffectSound()
		return
	elseif(type == cardCommon.type_double)then
	elseif(type == cardCommon.type_triple2)then		--三连对
		self:playCommonEffectSound()
		return
	elseif(type == cardCommon.type_three)then		--三张
	elseif(type == cardCommon.type_three_p2)then		--三带2
	elseif(type == cardCommon.type_double3)then		--飞机
		self:playFeiJiEffectSound()
		return
	elseif(type == cardCommon.type_four)then		
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.type_five)then		
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.type_five_same_color)then		--同花顺
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.type_six)then
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.type_seven)then
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.type_eight)then
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.type_four_king)then
		self:playZhaDanEffectSound()
		return
	end
end

--播放过牌音效
function TableSound:playPassSound(male)
	local maleStr = ''
	local path = femalePath
	if(male)then
		maleStr = 'm_'
		path = malePath
	end
	local list = {'voicebuyao', 'voiceguo'}
	local soundName = maleStr .. list[math.random( 1,2)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playDaNiSound(male)
	local maleStr = ''
	local path = femalePath
	if(male)then
		maleStr = 'm_'
		path = malePath
	end
	local list = {'voicedani', 'voiceguanshang'}
	local soundName = maleStr .. list[math.random( 1,2)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playFaPaiSound()
	local soundName = 'fapai'
	self:playSound(commonPath .. soundName, soundName)
end


--播放警告音效
function TableSound:playWarningSound(play)
	local soundName = 'baojing'
	self:playSound(commonPath .. soundName, soundName)
end

--播放读秒
function TableSound:playTickSound()
	local soundName = 'daojishi'
	self:playSound(commonPath .. soundName, soundName)
end

--播放飞机特效音
function TableSound:playFeiJiEffectSound()
	local soundName = 'poker_feiji'
	self:playSound(commonPath .. soundName, soundName)
end

--播放顺子特效音
function TableSound:playShunZiEffectSound()
	local soundName = 'poker_shunzi'
	self:playSound(commonPath .. soundName, soundName)
end

--播放炸弹特效音
function TableSound:playZhaDanEffectSound()
	local soundName = 'poker_zhadan'
	self:playSound(commonPath .. soundName, soundName)
end


function TableSound:playCommonEffectSound()
	local soundName = 'poker_common'
	self:playSound(commonPath .. soundName, soundName)
end

function TableSound:playGameLoseSound()
	local soundName = 'gamelose'
	self:playSound(commonPath .. soundName, soundName)
end

function TableSound:playGameWinSound()
	local soundName = 'gamewin'
	self:playSound(commonPath .. soundName, soundName)
end

function TableSound:playMathWinSound()
	local soundName = 'mathwin'
	self:playSound(commonPath .. soundName, soundName)
end

function TableSound:playSound(fullpath, soundName)
	ModuleCache.SoundManager.play_sound(packageName, fullpath .. ".bytes", soundName)
end

function TableSound:playMusic(fullpath, soundName)
	ModuleCache.SoundManager.play_music(packageName, fullpath .. ".bytes", soundName)
end

--播放背景音乐
function TableSound:playBgm()
	local soundName = 'game_bg_normal'
	self:playMusic(commonPath .. soundName, soundName)
end

return TableSound
