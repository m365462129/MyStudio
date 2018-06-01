---@type WuShiK_CardCommon
local CardCommon = require('package.wushik.module.table.gamelogic_common')
local TableSound = {}

local packageName = 'wushik'
local malePath = 'wushik/sound/man/'
local femalePath = 'wushik/sound/woman/'
local malePath_common = 'wushik/sound/common/man/'
local femalePath_common = 'wushik/sound/common/woman/'
local effectPath = 'wushik/sound/effect/'
local musicPath = 'wushik/sound/music/'



local do_not_use_sound = true

function TableSound:init(getLocationLangFun)
	self._getLocationLangFun = getLocationLangFun
end

function TableSound:getCurLocationSetting()
	if(self._getLocationLangFun)then
		return self._getLocationLangFun()
	end
	return 0
end

--播放牌型音效
function TableSound:playPokerTypeSound(male, pattern, srcPattern)
	local tmpFemalePath = femalePath
	local tmpMalePath = malePath

	if(self:getCurLocationSetting() == 0)then
		tmpFemalePath = femalePath_common
		tmpMalePath = malePath_common
	end

	local path = tmpFemalePath
	if(male)then
		path = tmpMalePath
	end
	local type = pattern.type
	local disp_type = pattern.disp_type
	if(srcPattern)then
		-- print(srcPattern.type, type, disp_type)
		if(srcPattern.type == type)then
			if(type ~= CardCommon.PT_SINGLE
			and type ~= CardCommon.PT_PAIR)then
				self:playDaNiSound(male)
				return
			end
		end
	end

	if(type == CardCommon.PT_UNKNOWN)then
		return
	elseif(type == CardCommon.PT_SINGLE)then
		type = 'single_'
	elseif(type == CardCommon.PT_PAIR)then
		type = 'double_'
	elseif(type == CardCommon.PT_CPAIR)then		--三对
		local soundName = 'double_straight'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_STRAIGHT)then		--顺子
		local soundName = 'shunzi'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB3)then		--3炸
		local soundName = 'bomb_3'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB4)then		--4炸
		local soundName = 'bomb_4'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB5)then		--5炸
		local soundName = 'bomb_5'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB6)then		--6炸
		local soundName = 'bomb_6'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB7)then		--7炸
		local soundName = 'bomb_7'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB8)then		--8炸
		local soundName = 'bomb_8'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_N510K)then		--杂50k
		local soundName = '510k'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_P510K)then		--正50k
		local soundName = '510k'
		local color = pattern.color
		if(color == CardCommon.color_black_heart)then
			soundName = soundName .. '_heitao'
		elseif(color == CardCommon.color_red_heart)then
			soundName = soundName .. '_hongtao'
		elseif(color == CardCommon.color_plum)then
			soundName = soundName .. '_meihua'
		elseif(color == CardCommon.color_square)then
			soundName = soundName .. '_fangkuai'
		end
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB_KING2)then		--对王炸
		local soundName = 'king_bomb'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB_KING3)then		--3王炸
		local soundName = 'king_bomb'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == CardCommon.PT_BOMB_KING4)then		--4王炸
		local soundName = 'king_bomb'
		self:playSound(path .. soundName, soundName)
		return
	end

	local name
	local code = pattern.cards[1]
	if(CardCommon.isBigKingCard(code))then
		name = 'dawang'
	elseif(CardCommon.isLittleKingCard(code))then
		name = 'xiaowang'
	else
		name = CardCommon.getCardName(pattern.cards[1])
		if(name == CardCommon.card_unknown)then
			return
		end
	end

	local soundName = type .. name
	print(type, name)
	if(soundName == 'double_14' or soundName == 'double_15')then
		return
	end
	self:playSound(path .. soundName, soundName)
end

--播放牌型特效音
function TableSound:playPokerTypeEffectSound(pattern)
	local type = pattern.type
	if(type == CardCommon.PT_UNKNOWN)then

	elseif(type == CardCommon.PT_CPAIR)then		--连对
		self:playCommonEffectSound()
		return
	elseif(type == CardCommon.PT_STRAIGHT)then		--顺子
		self:playCommonEffectSound()
		return
	elseif(type == CardCommon.PT_N510K)then		--副50k
		self:playZhaDanEffectSound()
		return
	elseif(type == CardCommon.PT_P510K)then		--正50k
		self:playZhaDanEffectSound()
		return
	elseif(type == CardCommon.PT_BOMB_KING2
	or type == CardCommon.PT_BOMB_KING3
	or type == CardCommon.PT_BOMB_KING4)then		--王炸
		self:playWangZhaEffectSound()
		return
	elseif(type == CardCommon.PT_BOMB3
	or type == CardCommon.PT_BOMB3
	or type == CardCommon.PT_BOMB4
	or type == CardCommon.PT_BOMB5
	or type == CardCommon.PT_BOMB6
	or type == CardCommon.PT_BOMB7
	or type == CardCommon.PT_BOMB8)then
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
	local tmpFemalePath = femalePath
	local tmpMalePath = malePath
	if(self:getCurLocationSetting() == 0)then
		tmpFemalePath = femalePath_common
		tmpMalePath = malePath_common
	end
	local path = tmpFemalePath .. 'action/'
	if(male)then
		path = tmpMalePath .. 'action/'
	end
	local list = {'buyao1', 'buyao2', 'buyao3'}
	local soundName = list[math.random( 1,#list)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playDaNiSound(male)
	local tmpFemalePath = femalePath
	local tmpMalePath = malePath
	if(self:getCurLocationSetting() == 0)then
		tmpFemalePath = femalePath_common
		tmpMalePath = malePath_common
	end
	local path = tmpFemalePath .. 'action/'
	if(male)then
		path = tmpMalePath .. 'action/'
	end
	local list = {'dani1', 'dani2'}
	local soundName = list[math.random( 1,#list)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playFaPaiSound()
	local soundName = 'fapai'
	self:playSound(effectPath .. soundName, soundName)
end

--播放叫鸡音效
function TableSound:playFriendEffectSound()
	local soundName = 'mingji'
	self:playSound(effectPath .. soundName, soundName)
end

--播放独牌音效
function TableSound:playDuPaiEffectSound(male)
	local soundName = 'friend'
	self:playSound(effectPath .. soundName, soundName)
	local tmpFemalePath = femalePath
	local tmpMalePath = malePath
	if(self:getCurLocationSetting() == 0)then
		tmpFemalePath = femalePath_common
		tmpMalePath = malePath_common
	end
	local path = tmpFemalePath
	if(male)then
		path = tmpMalePath
	end
	local soundName = 'dupai'
	self:playSound(path .. soundName, soundName)
end

--播放叫牌音效
function TableSound:playJiaoPaiEffectSound()
	local soundName = 'friend'
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


--时间快到的提示音
function TableSound:playRemind()
	local soundName = 'remind'
	self:playSound(effectPath .. soundName, soundName)
end


--播放炸弹特效音
function TableSound:playZhaDanEffectSound()
	local soundName = 'bomb'
	self:playSound(effectPath .. soundName, soundName)
end

--播放王炸特效音
function TableSound:playWangZhaEffectSound()
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
