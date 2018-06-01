local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local GiveGoodsModule = class("giveGoodsModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

function GiveGoodsModule:initialize(...)
	-- 开始初始化                view        model           模块数据
	ModuleBase.initialize(self, "givegoods_view", nil, ...)
	
end

function GiveGoodsModule:on_show(data)
    self.giveUserId = nil
    self.goodsData  = data.goodsData
    self.curPage    = data.curPage
    -- print_table(data)
    self.view:refresh_view(data)
end

function GiveGoodsModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("henanmj", "givegoods")
    elseif obj == self.view.btnCheck.gameObject then
        if(self:checkIdFail()) then return nil end
        self:get_userinfo(self.view.inputText.text)
    elseif obj == self.view.btnGive.gameObject then
        if(self:checkIdFail()) then return nil end
        if(self.giveUserId == nil) then
            self:get_userinfo(self.view.inputText.text,function()
                self:buy_goods(self.goodsData.id)
            end)
        else
            self:buy_goods(self.goodsData.id)
        end
	end
end

-- 检查输入框输入的ID是否非法 true:非法，无法进行赠送
function GiveGoodsModule:checkIdFail()
    if(self.view.inputText.text == nil or self.view.inputText.text == "") then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请输入正确的用户ID！")
        return true
    end
    if(self.modelData.roleData.userID == self.view.inputText.text) then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("赠送体力需填入他人ID！")
        return true
    end
    return false
end


function GiveGoodsModule:get_userinfo(userId,callback)         
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = userId,
        },
        cacheDataKey = "user/info?uid=" .. userId
    }

    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
            print("retData:")
            print_table(retData)
            self.view:showPlayer(retData.data)
            self.giveUserId = retData.data.userId
            if(callback ~= nil and type(callback) == "function") then
                callback()
            end
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("用户不存在")	
        end
    end, function(error)
        print(error.error)
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then    --OK
            print("cacheData:")
            print_table(retData)
            self.view:showPlayer(retData.data)
            self.giveUserId = retData.data.userId
        else
            -- ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("用户不存在")	
        end
    end)
end

-- 购买赠送
function GiveGoodsModule:buy_goods(id)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getWxPayParam?",
		showModuleNetprompt = true,	   
		params = {
			uid = self.modelData.roleData.userID,
			productId = id,
            type = 2,
            targetUserId = self.giveUserId
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			ModuleCache.WechatManager.recharge(retData.data, function(errCode)
				if(errCode == 0 or errCode == "0")then
					self.modelData.isNeedUpdateUserInfo = true
					self:getUserNewMessage()
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("支付成功")
                    ModuleCache.ModuleManager.hide_module("henanmj", "givegoods")
                else

				end
			end)
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)	
		end
	end, function(errorData)
		print(errorData.error)
	end)
end

function GiveGoodsModule:getUserNewMessage()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "msg/getNewMsg?",
		params = {
			uid = self.modelData.roleData.userID,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = ModuleCache.Json.decode(wwwData.www.text)
		print_table(retData)
		if retData.ret == 0 then
			self.modelData.isNeedUpdateUserInfo = false
			local data = retData.data
			self.modelData.roleData.coins = data.coins
			-- if(data.msg)then
			-- 	ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(data.msg)
			-- end
		else

		end
	end, function(errorData)
		print(errorData.error)
	end)
end

return GiveGoodsModule