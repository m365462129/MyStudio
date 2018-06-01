local require = require

local NetMsgApi = {}

NetMsgApi.protolDataCache = {}

-- 此处必须与路径一致
NetMsgApi.path = "package.public.model.net.protol."
local customPath = "package.public.model.net.protol."

function NetMsgApi:get_msg_data(msgName)
    local msgData = self.msgName2MsgData[msgName]
    return msgData
end


function NetMsgApi:get_protol(msgName, request)
    local msgData = self.msgName2MsgData[msgName]

    local pbName = request and msgData[5] or msgData[6]
    local path = msgData[7] or self.path
    local protolData = self.protolDataCache[pbName]
    if not protolData then
        protolData = require(path .. pbName)
        self.protolDataCache[pbName] = protolData
    end

    if request then
        return msgData[1], protolData[msgData[2]]
    else
        return msgData[3], protolData[msgData[4]]
    end
end

function NetMsgApi:get_protol_pbc(msgName, request)

end

function NetMsgApi:create_request_data(msgName)
    local msgId, data = self:get_protol(msgName, true)
    return msgId, data()
end

function NetMsgApi:create_ret_data(msgName)
    local msgId, data = self:get_protol(msgName, false)
    return data()
end
-- 命令名  --请求的命令ID 请求的proto结构体 收包的命令ID 收包的proto结构体 发包和收包proto结构体所在的proto文件名
NetMsgApi.msgName2MsgData = {
}



return NetMsgApi