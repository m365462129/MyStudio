--- @class SoundManager
local SoundManager = {}

local PublicSound = require("manager.sound_manager")

local PackageName = "huapai"
local SoundAssetName = "huapai/sound/"
local MsgAssetName = "huapai/sound/msg/"

local ACTION_NAME = {"chi", "peng", "wei", "pao", "ti", "hu"}

function SoundManager:getRealGameSoudName()
	if SoundManager.location_setttingPuTong == 0 then
		return "pth"
	else
		return AppData.Game_Name
	end
end

--- 播放牌的声 音
function SoundManager:play_card(id, man)
	man = not man

	print(id)
	local id1 = id % 3 

	if id % 3 == 0 then
		id1 = 3
	end

	local id2 = "1"

	if id % 3 == 0 then
		id2 = (id - id % 3) / 3 
	else
		id2 = (id - id % 3) / 3 + 1
	end

	local id3 = tostring(id2) .. tostring(id1)

	print(id3)

	local name =
		man and self:getRealGameSoudName() .. "/man/pai_" .. id3 or self:getRealGameSoudName() .. "/wowen/pai_" .. id3
	self:play_sound(name, "pai_" .. tostring(id3))
end

--- 播放闹钟倒计时 声音
function SoundManager:play_clock()
	self:play_sound("clock")
end

--- 播放动作声音
function SoundManager:play_action(actionID, man)
	man = not man
	--1:抵 2:吃 3:碰 4:绍 5:下抓 6:半挎  7:满挎 8:出 9：翻弃牌 10：出弃牌 11：胡  12: 开局 13:出张收回
	local name =
		man and self:getRealGameSoudName() .. "/man/" .. actionID or self:getRealGameSoudName() .. "/wowen/" .. actionID
	self:play_sound(name, "" .. tostring(actionID))
end

--- 播放   name
function SoundManager:play_name(name, man)
	man = not man
	local path = self:getRealGameSoudName() .. "/m_" .. name
	local namen = "m_" .. name
	if not man then
		path = self:getRealGameSoudName() .. "/f_" .. name
		namen = "f_" .. name
	end

	self:play_sound(path, namen)
end

--- 播放name
function SoundManager:play_nameroot(name)
	self:play_sound(name, name)
end

--- 播放比牌声音
function SoundManager:play_bi(man)
	man = not man
	self:play_name("bi", man)
end

--- 播放短语声音
function SoundManager:play_shot_voice(index, man)
	local dir = not man and "malesound_hn" or "femalesound_hn"
	local name = "fix_msg_" .. index

	local path = "sound/" .. dir .. "/" .. name
	local namen = name

	self:play_sound(path, namen)
end

function SoundManager:play_sound(assetName, fileName)
	local fullName = SoundAssetName .. string.lower(assetName) .. ".bytes"
	PublicSound.play_sound(PackageName, fullName, fileName or assetName)

	print("声音播放", PackageName, fullName, fileName or assetName)
end

return SoundManager
