-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local BiSaiModule = class("Public.BiSaiModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function BiSaiModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "bisai_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function BiSaiModule:on_module_inited()

end

-- 绑定module层的交互事件
function BiSaiModule:on_module_event_bind()
    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.view:refreshPlayerInfo(self.modelData.roleData)
    end)
end

-- 绑定loginModel层事件，模块内交互
function BiSaiModule:on_model_event_bind()


end

function BiSaiModule:set_view_values()

end

function BiSaiModule:on_show(data)
    self.view:refreshPlayerInfo(self.modelData.roleData)

end

function BiSaiModule:on_click(obj, arg)
    print("点击", obj.name, obj.transform.parent.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj.name == "ImageBack" then
        ModuleCache.ModuleManager.hide_module("public", "bisai")
        return
    elseif obj.name == "Gold"  then
        ModuleCache.ModuleManager.show_module("public", "shopbase")
    elseif obj.name == "Gem" then
        ModuleCache.ModuleManager.show_module("public", "shopbase", 1)
    elseif obj.name == "BtnEnter" then
        local t = tonumber(obj.transform.parent.name)
        if t > 2 then
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(
                    "敬请期待",
                    nil)
        else
            ModuleCache.ModuleManager.show_module("public", "bisailist", { id = t })
        end
           elseif obj.name == "BtnRecord" then
        ModuleCache.ModuleManager.show_module("public", "matchrecord")
    end
end





return BiSaiModule



