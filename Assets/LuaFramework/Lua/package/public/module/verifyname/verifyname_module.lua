-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local verifynameModule = class("Public.verifynameModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function verifynameModule:initialize(...)
    -- 开始初始化                view        loginModel           模块数据
    ModuleBase.initialize(self, "verifyname_view", "verifyname_model", ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function verifynameModule:on_module_inited()

end

-- 绑定module层的交互事件
function verifynameModule:on_module_event_bind()

end

local coin = 0

-- 绑定Model层事件，模块内交互
function verifynameModule:on_model_event_bind()
    self:subscibe_model_event("Event_GetVerify", function(eventHead, eventData)
        -- 监听model层的事件反馈，事件头、事件数据
        if (eventData.result) then
            self.view:get_btn_deal(false)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("验证码发送成功")
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err)
        end
    end )
    self:subscibe_model_event("Event_SubmitVerify", function(eventHead, eventData)
        -- 监听model层的事件反馈，事件头、事件数据
        if (eventData.result) then
            ModuleCache.ModuleManager.destroy_module("public", "verifyname")

            if coin > 0 then
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(string.format("恭喜您认证成功,获得%d钻石",coin))
            else
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("恭喜您认证成功")
            end

            self.modelData.hallData.verifyData.status = 1
            self:dispatch_package_event("Event_Package_VerifyStatus")
        else
            print(eventData.err)
            self.view.inputName.interactable = true
            self.view.inputIdNum.interactable = true
            self.view.inputPhoneNum.interactable = true
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(eventData.err)
        end
    end )

end

function verifynameModule:on_show(coins)
    coin = coins
    self.view:set_desc_text(coins)
end

function verifynameModule:on_click(obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")

    local objName = obj.name
    if objName == "ButtonClose" then
        ModuleCache.ModuleManager.destroy_module("public", "verifyname")
        --ModuleCache.ModuleManager.hide_module("public", "verfiyname");
    elseif objName == "ButtonGet" then
        local name = self.view.inputName.text
        local idNum = self.view.inputIdNum.text
        local phoneNum = self.view.inputPhoneNum.text
        if string.len(name) < 1 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写姓名")
            return
        elseif string.len(idNum) ~= 18 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写正确的身份证号")
            return
        elseif string.len(phoneNum) ~= 11 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写正确的手机号")
        else
            self.model:getVerifyNum(phoneNum)
        end
    elseif objName == "ButtonVerify" then
        local verifyNum = self.view.inputVerifyNum.text
        local name = self.view.inputName.text
        local idNum = self.view.inputIdNum.text
        local phoneNum = self.view.inputPhoneNum.text
        if string.len(name) < 1 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写姓名")
            return
        elseif string.len(idNum) ~= 18 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写正确的身份证号")
            return
        elseif string.len(phoneNum) ~= 11 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写正确的手机号")
        elseif string.len(verifyNum) ~= 6 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请填写正确的验证码")
        else
            self.model:submitverify(name, idNum, phoneNum, verifyNum)
        end


    end
end





return verifynameModule



