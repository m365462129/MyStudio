--- 三公玩法model
--- Created by 袁海洲
--- DateTime: 2017/11/17 11:06
---
---
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')

---@class TableSanGongModel : Model
local TableSanGongModel = class('tableSanGongModel', Model);

function TableSanGongModel:initialize(...)
    self.sendMsgNetClientName = "bullfight"
    Model.initialize(self, ...)

    Model.subscibe_msg_event(self, {    --下注回复
        msgName = "Msg_Table_Stake",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Stake", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --下注通知
        msgName = "Msg_Table_Stake_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Stake_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --抢庄回复
        msgName = "Msg_Table_Banker",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Banker", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --抢庄通知
        msgName = "Msg_Table_Banker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Banker_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --抢庄结果通知
        msgName = "Msg_Table_BankerResult_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_BankerResult_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --开牌
        msgName = "Msg_Table_Show_Card",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Show_Card", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --手牌通知 所有人开牌后、下注后都会广播
        msgName = "Msg_Table_Handcard_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Handcard_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --单播 游戏信息 登录或者断线重连时发送
        msgName = "Msg_Table_GameInfo",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_GameInfo", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --广播 结算信息
        msgName = "Msg_Table_CurrentGameAccount",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_CurrentGameAccount", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --广播 超时
        msgName = "Msg_Table_TimeoutNotify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_TimeoutNotify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --取牌请求回复
        msgName = "Msg_Table_GetCard",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_GetCard", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --玩家亮牌广播
        msgName = "Msg_Table_ShowCardNotify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_ShowCardNotify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --房主变更广播消息
        msgName = "Msg_Table_RoomOwnerChangeMsg",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_RoomOwnerChangeMsg", retData)
            end
        end
    })

end

---申请下注
--- stake 下注数量
function TableSanGongModel:request_stake(stake)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Stake")
    request.stake = stake
    Model.send_msg(self, msgId, request)
    print("下注数 "..stake)
end

---申请抢庄
---banker_rate 等于0表示 不抢，其他表示倍率
function TableSanGongModel:request_getbanker(banker_rate)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Banker")
    request.banker_rate = banker_rate
    Model.send_msg(self, msgId, request)
end

---申请开牌
function TableSanGongModel:request_showcard()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Show_Card")
    Model.send_msg(self, msgId, request)
end
---申请自己的手牌，只有在开牌阶段有效
function TableSanGongModel:request_getcard()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_GetCard")
    Model.send_msg(self, msgId, request)
end

return TableSanGongModel

