-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local PlayBackModule = class("playbackModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local ComponentUtil = ModuleCache.ComponentUtil
local UnityEngine = UnityEngine
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

--function PlayBackModule:on_hide()
--	UpdateBeat:Remove(self.UpdateBeat, self)
--end
--
--function PlayBackModule:on_destroy()
--	UpdateBeat:Remove(self.UpdateBeat, self)
--end

--function PlayBackModule:UpdateBeat()
--	if(not self.view.root.activeSelf)then
--		return
--	end
--	self:update_beat()
--end

function PlayBackModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.playBackView.ButtonExit then
        ModuleCache.ModuleManager.hide_public_module("netprompt")
        ModuleCache.ModuleManager.destroy_package("henanmj")
        ModuleCache.ModuleManager.destroy_package("changpai")
        ModuleCache.ModuleManager.destroy_package("majiangshanxi")
        ModuleCache.ModuleManager.destroy_package("majiangshanxi3d")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
    elseif obj == self.playBackView.ButtonPause then
        self:play()
    elseif obj == self.playBackView.ButtonReset then
        self:reset()
    elseif obj == self.playBackView.ButtonUnPause then
        self:play()
    elseif obj == self.playBackView.ButtonFront then
        self:play_front()
    elseif obj == self.playBackView.ButtonBack then
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
    if (self.playBackView.ButtonUnPause.activeSelf) then
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
    ComponentUtil.SafeSetActive(self.playBackView.ButtonUnPause, false)
    ComponentUtil.SafeSetActive(self.playBackView.ButtonPause, true)
    if (ModuleCache.ModuleManager.module_is_active("majiangshanxi", "onegameresult")) then
        ModuleCache.ModuleManager.destroy_module("majiangshanxi", "onegameresult")
    end
    if (ModuleCache.ModuleManager.module_is_active("majiangshanxi", "onegameresultpuning")) then
        ModuleCache.ModuleManager.destroy_module("majiangshanxi", "onegameresultpuning")
    end
    if (ModuleCache.ModuleManager.module_is_active("changpai", "onegameresult")) then
        ModuleCache.ModuleManager.destroy_module("changpai", "onegameresult")
    end
    self.curFrame = 1
    self.lastTime = Time.timeSinceLevelLoad
    self:play_frame()
end

function PlayBackModule:play_front()
    self:next_frame()
end

function PlayBackModule:play()
    if (self.playBackView.ButtonUnPause.activeSelf) then
        self.lastTime = Time.timeSinceLevelLoad
        ComponentUtil.SafeSetActive(self.playBackView.ButtonUnPause, false)
        ComponentUtil.SafeSetActive(self.playBackView.ButtonPause, true)
    else
        ComponentUtil.SafeSetActive(self.playBackView.ButtonUnPause, true)
        ComponentUtil.SafeSetActive(self.playBackView.ButtonPause, false)
    end
end

function PlayBackModule:play_back()
    if (ModuleCache.ModuleManager.module_is_active("majiangshanxi", "onegameresult")) then
        ModuleCache.ModuleManager.destroy_module("majiangshanxi", "onegameresult")
        self.curFrame = self.curFrame - 1
    end
    if (ModuleCache.ModuleManager.module_is_active("majiangshanxi", "onegameresultpuning")) then
        ModuleCache.ModuleManager.destroy_module("majiangshanxi", "onegameresultpuning")
        self.curFrame = self.curFrame - 1
    end
    if (ModuleCache.ModuleManager.module_is_active("changpai", "onegameresult")) then
        ModuleCache.ModuleManager.destroy_module("changpai", "onegameresult")
        self.curFrame = self.curFrame - 1
    end
    if (ModuleCache.ModuleManager.module_is_active("majiangshanxi", "tablepop")) then
        ModuleCache.ModuleManager.hide_module("tablepop", "tablepop")
    end
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

return PlayBackModule



