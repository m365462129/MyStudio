local class = require("lib.middleclass")
local ModelBase = require("core.mvvm.model_base")
local verifynameModel = class("Public.verifyname", ModelBase)
local Model = require("core.mvvm.model_base")
local ModuleCache = ModuleCache

function verifynameModel:initialize(...)
    ModelBase.initialize(self, ...)
end



-- 请求获取验证码
function verifynameModel:getVerifyNum(phone)
    local requestData = {
        --baseUrl = "http://114.55.99.139:9021/swagger-ui.html#!/real-name-auth-endpoint/qeryAuthUsingGET",
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "realNameAuth/getVilidateCode?",
        params = {
            uid = self.modelData.roleData.userID,
            phone = phone,
        }
    }
    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        print("获取验证码回复", retData.ret)
        if retData.ret and retData.ret == 0 then
            -- OK
            Model.dispatch_event(self, "Event_GetVerify", { result = true })
        else
            Model.dispatch_event(self, "Event_GetVerify", { result = false, err = retData.errMsg })
        end
    end, function(error)
        local msg =  ModuleCache.Json.decode(error.www.text)
        local errormsg = ModuleCache.Json.decode(msg.errMsg)
        Model.dispatch_event(self, "Event_GetVerify", { result = false, err = errormsg.message })
    end)
end
--提交验证
function verifynameModel:submitverify(name, idNum, phoneNum, verifyNum)
    local requestData = {
        --baseUrl = "http://114.55.99.139:9021/swagger-ui.html#!/real-name-auth-endpoint/qeryAuthUsingGET",
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "realNameAuth/auth?",
        params = {
            uid = self.modelData.roleData.userID,
            phone = phoneNum,
            name = name,
            idCardNo = idNum,
            code = verifyNum,
        }
    }
    print("提交验证，url", requestData.baseUrl)
    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        print("提交验证回复", retData.ret)
        if retData.ret and retData.ret == 0 then
            -- OK
            Model.dispatch_event(self, "Event_SubmitVerify", { result = true })
        else
            Model.dispatch_event(self, "Event_SubmitVerify", { result = false, err = retData.errMsg })
        end
    end, function(error)
        local msg =  ModuleCache.Json.decode(error.www.text)
        local errormsg = ModuleCache.Json.decode(msg.errMsg)
        Model.dispatch_event(self, "Event_SubmitVerify", { result = false, err = errormsg.message })
    end  )
end

return verifynameModel