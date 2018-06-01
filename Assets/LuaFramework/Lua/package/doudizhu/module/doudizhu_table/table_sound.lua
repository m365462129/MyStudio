
local cardCommon = require('package.doudizhu.module.doudizhu_table.gamelogic_common')
local TableSound = {}

local packageName = 'doudizhu'
local malePath = 'doudizhu/sound/man/'
local femalePath = 'doudizhu/sound/woman/'
local effectPath = 'doudizhu/sound/effect/'
local musicPath = 'doudizhu/sound/music/'

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
			if(type ~= cardCommon.danpai
			and type ~= cardCommon.duizi
			and disp_type ~= 'sanzhang')then
				self:playDaNiSound(male)
				return
			end
		end
	end

	if(type == cardCommon.type_unknown)then
		return
	elseif(type == cardCommon.danpai)then
		type = 'single_'
	elseif(type == cardCommon.shunzi)then	--顺子
		local soundName = 'shunzi'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.duizi)then
		type = 'dui'
	elseif(type == cardCommon.liandui)then		--三连对
		local soundName = 'liandui'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.sandaiyi)then		
		local soundName = 'tuple'
		if(disp_type == 'sanzhang')then			--3张
			type = 'tuple'
		elseif(disp_type == 'sandaiyi')then			--3带1
			soundName = 'sandaiyi'
			self:playSound(path .. soundName, soundName)
			return
		elseif(disp_type == 'sandaier')then		--3带2
			soundName = 'sandaiyidui'
			self:playSound(path .. soundName, soundName)
			return
		else
			return
		end
	elseif(type == cardCommon.feiji)then		--飞机
		local soundName = 'feiji'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.zhadan)then		
		local soundName = 'zhadan'
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.sidaier)then		--4带2
		local soundName = 'sidaier'
		if(disp_type == 'sidaisi')then		--4带4
			soundName = 'sidailiangdui'
		end
		self:playSound(path .. soundName, soundName)
		return
	elseif(type == cardCommon.huojian)then		--火箭
		local soundName = 'wangzha'
		self:playSound(path .. soundName, soundName)
		return
	end

	local name = cardCommon.Value2Name(pattern.value)
	if(name == cardCommon.card_unknown)then
		return
	end
	local soundName = type .. name
	self:playSound(path .. soundName, soundName)
end

--播放牌型特效音
function TableSound:playPokerTypeEffectSound(pattern)
	local type = pattern.type
	local disp_type = pattern.disp_type
	if(type == cardCommon.type_unknown)then

	elseif(type == cardCommon.shunzi)then	--顺子
		self:playShunZiEffectSound()
		return
	elseif(type == cardCommon.liandui)then		--三连对
		self:playCommonEffectSound()
		return
	elseif(type == cardCommon.feiji)then		--飞机
		self:playFeiJiEffectSound()
		return
	elseif(type == cardCommon.zhadan)then		
		self:playZhaDanEffectSound()
		return
	elseif(type == cardCommon.huojian)then		
		self:playHuoJianEffectSound()
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
	local list = {'buyao1', 'buyao2', 'buyao3', 'buyao4'}
	local soundName = list[math.random( 1,#list)]
	self:playSound(path .. soundName, soundName)
end

function TableSound:playDaNiSound(male)
	local path = femalePath .. 'action/'
	if(male)then
		path = malePath .. 'action/'
	end
	local list = {'dani1', 'dani2', 'dani3'}
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

--播放抢地主音效
function TableSound:playGrabLordSound(male, score)
	local path = femalePath .. 'action/'
	if(male)then
		path = malePath .. 'action/'
	end
	local soundName = 'score_order_'
	if(score == 0)then
		soundName = 'score_no_order'
	else
		soundName = soundName .. score
	end
	self:playSound(path .. soundName, soundName)
end

--播放定地主特效音
function TableSound:playSetLordEffectSound()
	local soundName = 'querendizhu'
	self:playSound(effectPath .. soundName, soundName)
end

--时间快到的提示音
function TableSound:playRemind()
	local soundName = 'remind'
	self:playSound(effectPath .. soundName, soundName)
end

--播放飞机特效音
function TableSound:playFeiJiEffectSound()
	local soundName = 'feiji'
	self:playSound(effectPath .. soundName, soundName)
end

--播放顺子特效音
function TableSound:playShunZiEffectSound()
	self:playCommonEffectSound()
end

--播放炸弹特效音
function TableSound:playZhaDanEffectSound()
	local soundName = 'bomb'
	self:playSound(effectPath .. soundName, soundName)
end

--播放火箭特效音
function TableSound:playHuoJianEffectSound()
	local soundName = 'bomb_new'
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
	local list = {'bg1', 'bg2', 'bg3'}
	local soundName = list[math.random( 1,#list)]
	self:playMusic(musicPath .. soundName, soundName)
end

return TableSound
