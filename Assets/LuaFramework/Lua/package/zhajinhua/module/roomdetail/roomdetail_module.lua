-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
local BranchPackageName = AppData.BranchZhaJinHuaName
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RoomDetailModule = class("RoomDetailModule", ModuleBase)
local ModuleCache = ModuleCache


function RoomDetailModule:initialize(...)
    ModuleBase.initialize(self, "roomDetail_view", nil, ...)
end

function RoomDetailModule:on_show(data)

    self.roomDetailView:init(data)
end


function RoomDetailModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.roomDetailView.buttonBack.gameObject then
        ModuleCache.ModuleManager.destroy_module(BranchPackageName, "roomdetail");
        return
    elseif obj == self.roomDetailView.buttonLookMatch.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "playvideo", function(data)
            if (data.ret and data.ret == 0) then
                ModuleCache.ModuleManager.destroy_module("henanmj", "playvideo")
                local recordID = data.data.recordId
                self:playVideo(recordID)
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("回放码错误！请填写正确的回放码")
            end
        end )
    end
end

return RoomDetailModule