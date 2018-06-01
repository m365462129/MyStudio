--- @class SoundManager
local SoundManager = {}

local PublicSound = require("manager.sound_manager")

local PackageName = "paohuzi"
local SoundAssetName = "paohuzi/sound/"
local MsgAssetName = "paohuzi/sound/msg/"

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




	if AppData.Game_Name ~= "DYZP" then
		man = not  man

        if id % 2 == 0 then
            id = id / 2 + 10
        else
            id = (id + 1) / 2
		end
		
		local gameName = 1

        local name = man and self:getRealGameSoudName() .. "/m_" .. id or self:getRealGameSoudName() .. "/f_" .. id
        local qianzhui = man and "m_"  or "f_"
        self:play_sound(name, qianzhui .. tostring(id))
        
	else
		local name = man and "hbdy/n/" .. id or "hbdy/v/" .. id
		self:play_sound(name, tostring(id))
	end
end

--- 播放闹钟倒计时声音
function SoundManager:play_clock()
	self:play_sound("clock")
end

--- 播放动作声音
function SoundManager:play_action(actionID, man)

	if actionID == 14 or actionID == 15 then
		actionID = 10
	end

	
	if AppData.Game_Name ~= "DYZP" then
		man = not  man
        local name = man and self:getRealGameSoudName() .. "/m_d" .. actionID or self:getRealGameSoudName() .. "/f_d" .. actionID
        local qianzhui = man and "m_d" or "f_d"
		self:play_sound(name, qianzhui .. tostring(actionID))
	else
		if actionID > #ACTION_NAME then
			return
		end
		
		local name = man and "hbdy/n/" .. ACTION_NAME[actionID] or "hbdy/v/" .. ACTION_NAME[actionID]
		self:play_sound(name, ACTION_NAME[actionID])
	end
end


--- 播放   name
function SoundManager:play_name(name, man)
	if AppData.Game_Name ~= "DYZP" then
		man = not  man
        local path = self:getRealGameSoudName() .. "/m_" .. name
		local namen = "m_" .. name
		if not man then
			path = self:getRealGameSoudName() .. "/f_" .. name
			namen = "f_" .. name
		end	

		
		self:play_sound(path, namen)
	end
end


--- 播放name
function SoundManager:play_nameroot(name)
    self:play_sound(name, name)
end





--- 播放比牌声音
function SoundManager:play_bi(man)
	if AppData.Game_Name ~= "DYZP" then
		man = not  man
		self:play_name("bi", man)
	 else
		local name = man and "hbdy/n/bi" or "hbdy/v/bi"
		self:play_sound(name, "bi")
	 end
end

--- 播放短语声音
function SoundManager:play_shot_voice(index, man)
	local dir = not man and "malesound_hn" or "femalesound_hn"
	local name = "fix_msg_" .. index

	local path = "sound/" .. dir .. '/' .. name
	local namen = name



	self:play_sound(path, namen)
end

function SoundManager:play_sound(assetName, fileName)
	local fullName = SoundAssetName .. string.lower(assetName) .. ".bytes"
    PublicSound.play_sound(PackageName, fullName, fileName or assetName)
    
    print("声音播放",PackageName, fullName, fileName or assetName)
end


return SoundManager 