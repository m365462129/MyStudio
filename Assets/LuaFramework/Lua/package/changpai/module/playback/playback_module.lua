local require = require
local Manager = require("manager.function_manager")
-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local PlayBackModule = class("PlayBackModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local ComponentUtil = ModuleCache.ComponentUtil
local curTableData = nil


function PlayBackModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "playback_view", nil, ...)
    curTableData = TableManager.curTableData
    self.lastTime = 0
    self.curFrame = 1
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function PlayBackModule:on_module_inited()

end



-- 绑定module层的交互事件
function PlayBackModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function PlayBackModule:on_model_event_bind()

end

function PlayBackModule:on_show()
    --UpdateBeat:Add(self.UpdateBeat, self)
    self:set_per_update_time(1.5)
    local gamestates = curTableData.gamestates
    local players = curTableData.players
    local videoData = curTableData.videoData
    self.players = players
    self.gameStates = gamestates
    local userState = {}
    userState.State = {}
    for i = 1, #players do
        local seatInfo = {}
        seatInfo.SeatID = players[i].seatId
        if (videoData.seatmap) then
            seatInfo.SeatID = videoData.seatmap[seatInfo.SeatID + 1]
        end
        seatInfo.UserID = players[seatInfo.SeatID + 1].userId
        seatInfo.PiaoType = 0
        seatInfo.Ready = true
        if (videoData.piaonum) then
            seatInfo.PiaoNum = videoData.piaonum[i]
        else
            seatInfo.PiaoNum = -1
        end
        if (videoData.paonum) then
            seatInfo.Pao = videoData.paonum[i]
        else
            seatInfo.Pao = -1
        end
        seatInfo.DiTuo = false
        table.insert(userState.State, seatInfo)
    end
    if (videoData.seatmap) then
        userState.randomseat = 1
    else
        userState.randomseat = 0
    end
    userState.msgtype = 0
    if "NTCP"  == AppData.Game_Name or "HMCP" == AppData.Game_Name or "RDCP" == AppData.Game_Name then
        -- 南通长牌，已经不属于同一个package
        self.userState = userState
        self:dispatch_package_event("Event_Msg_Table_UserStateNTF", userState)
    else
        self:dispatch_module_event("playback", "Event_Msg_Table_UserStateNTF", userState)
    end
    self:play_frame()
end

function PlayBackModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.ButtonExit then
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.destroy_package("changpai")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
    elseif obj == self.view.ButtonPause then
        self:play()
    elseif obj == self.view.ButtonReset then
        self:reset()
    elseif obj == self.view.ButtonUnPause then
        self:play()
    elseif obj == self.view.ButtonFront then
        self:play_front()
    elseif obj == self.view.ButtonBack then
        self:play_back()
    else
        if self.other_click then
            self:other_click(obj, arg)
        end
    end
end

function PlayBackModule:on_update_per_second()
    if (not self.view.root.activeSelf) then
        return
    end
    if (self.view.ButtonUnPause.activeSelf) then
        return
    end
    if (not self:next_frame()) then
        self:play()
    else
        self.lastTime = Time.timeSinceLevelLoad
    end
end

function PlayBackModule:next_frame()
    if (self.curFrame == #self.gameStates) then
        return false
    end
    self.curFrame = self.curFrame + 1
    self:play_frame()
    return true
end

function PlayBackModule:reset()
    ComponentUtil.SafeSetActive(self.view.ButtonUnPause, false)
    ComponentUtil.SafeSetActive(self.view.ButtonPause, true)
    ModuleCache.ModuleManager.destroy_module("changpai", "onegameresult")
    self.curFrame = 1
    self.lastTime = Time.timeSinceLevelLoad
    self:play_frame()
end

function PlayBackModule:play_front()
    self:next_frame()
end

function PlayBackModule:play()
    if (self.view.ButtonUnPause.activeSelf) then
        self.lastTime = Time.timeSinceLevelLoad
        ComponentUtil.SafeSetActive(self.view.ButtonUnPause, false)
        ComponentUtil.SafeSetActive(self.view.ButtonPause, true)
    else
        ComponentUtil.SafeSetActive(self.view.ButtonUnPause, true)
        ComponentUtil.SafeSetActive(self.view.ButtonPause, false)
    end
end

function PlayBackModule:play_back()
    ModuleCache.ModuleManager.destroy_module("changpai", "onegameresult")
    self.curFrame = self.curFrame - 1
    if (self.curFrame == 1) then
        return
    end
    self.curFrame = self.curFrame - 1
    self:play_frame()
end

function PlayBackModule:play_frame()
    if "NTCP" == AppData.Game_Name or "HMCP" == AppData.Game_Name or "RDCP" == AppData.Game_Name then
        -- 南通长牌已经不是同一个package
        self:dispatch_package_event("Event_PlayBackFrame", self.gameStates[self.curFrame])
    else
        self:dispatch_module_event("playback", "Event_PlayBackFrame", self.gameStates[self.curFrame])
    end
end

-- 点击事件
function PlayBackModule:other_click(obj, arg)
    if "ButtonChuPai" == obj.name then
        Manager.SetActive(self.view.ButtonUnPause, true)
        Manager.SetActive(self.view.ButtonPause, false)
        self:show_chupai(true)
    elseif "ButtonClosePanel" == obj.name then
        self:show_chupai()
    end
end

-- 出牌面板
function PlayBackModule:show_chupai(show)
    if not show then
        Manager.SetActive(self.view.panel_chupai, false)
        return
    end

    Manager.SetActive(self.view.panel_chupai, true)
    local data = self.gameStates[self.curFrame]
    local def = TableUtil.get_int_def_prefs()
    self.fan = Manager.GetPlayerPrefsInt("NTCP_FAN",def) == 0 -- 0:繁体 1:简体
    self.upright = Manager.GetPlayerPrefsInt("NTCP_UPRIGHT",def) == 1 -- 0:倒立 1:正立

    for i, v in ipairs(self.view.players) do
        -- 头像
        ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(self.players[i].headImg, function(err, sprite)
            if not err then
                v.avatar.sprite = sprite
            end
        end)
        -- 昵称
        v.name.text = self.players[i].playerName
        -- 弃牌
        local max = Manager.Max(#data.Player[i].QiZhang, #v.changpai_table)
        for j = 1, max do
            if data.Player[i].QiZhang[j] then
                local tab = v.changpai_table[j]
                if not tab then
                    tab = self.view:get_changpai_clone(i)
                end
                Manager.SetActive(tab.root, true)
                self:set_changpai(tab, data.Player[i].QiZhang[j])
            else
                local tab = v.changpai_table[j]
                if tab then
                    Manager.SetActive(tab.root, false)
                end
            end
        end
    end
end

--- 设置已经出的牌
function PlayBackModule:set_changpai(tab, pai)
    Manager.SetActive(tab.imageJ, not self.fan)
    tab.imageJ.sprite = tab.spritesJ:FindSpriteByName(pai .. "")

    Manager.SetActive(tab.imageF, self.fan)
    tab.imageF.sprite = tab.spritesF:FindSpriteByName(pai .. "")

    local z = self.upright and 0 or 180
    tab.root.transform.localEulerAngles = Vector3.New(0, 0, z)
end

return PlayBackModule