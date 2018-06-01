--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')
local LaoYanCaiTableModel = class('laoYanCaiTableModel', Model)


function LaoYanCaiTableModel:initialize(...)
    self.sendMsgNetClientName = "bullfight"
    self.heartbeatResponseName = "Msg_Table_Ping"
    Model.initialize(self, ...)

    Model.subscibe_msg_event(self, {    --单播 游戏信息 登录或者断线重连时发送
        msgName = "Msg_Table_GameInfo",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_GameInfo", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --单播 游戏信息 登录或者断线重连时发送
        msgName = "Msg_Table_CurrentGameAccount",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_CurrentGameAccount", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --抢庄
        msgName = "Msg_Table_Knock_Banker",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Knock_Banker", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --开始抢庄通知
        msgName = "Msg_Table_Start_Banker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Start_Banker_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --抢庄通知
        msgName = "Msg_Table_Knock_Banker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Knock_Banker_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --定庄发牌通知（收到通知后发两张牌并开始选择下分）
        msgName = "Msg_Table_Confirm_Banker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Confirm_Banker_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --下分
        msgName = "Msg_Table_Chip_Off",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Chip_Off", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --下分通知
        msgName = "Msg_Table_Chip_Off_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Chip_Off_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --开始操作通知
        msgName = "Msg_Table_Start_Operation_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Start_Operation_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --操作
        msgName = "Msg_Table_Operation",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Operation", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --操作通知
        msgName = "Msg_Table_Operation_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Operation_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --比牌通知
        msgName = "Msg_Table_Compare_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Compare_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --看牌通知
        msgName = "Msg_Table_View_Card",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_View_Card_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --上贡应答
        msgName = "Msg_Table_Queue_Banker",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Queue_Banker", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --上贡应答
        msgName = "Msg_Table_Queue_Banker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Queue_Banker_Notify", retData)
            end
        end
    })
end

function LaoYanCaiTableModel:request_knock_banker(isKnock)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Knock_Banker")
    request.qiang = isKnock
    Model.send_msg(self, msgId, request)
end

function LaoYanCaiTableModel:request_chip_off(chipValue)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Chip_Off")
    request.fen = tonumber(chipValue)
    Model.send_msg(self, msgId, request)
end

function LaoYanCaiTableModel:request_operation(operationID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Operation")
    request.op = tonumber(operationID)
    Model.send_msg(self, msgId, request)
end

function LaoYanCaiTableModel:request_queue_banker(joinType)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Queue_Banker")
    request.join = tonumber(joinType)
    Model.send_msg(self, msgId, request)
end

function LaoYanCaiTableModel:request_view_card(viewPlayerID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_View_Card")
    request.playerid = tonumber(viewPlayerID)
    Model.send_msg(self, msgId, request)
end

return LaoYanCaiTableModel