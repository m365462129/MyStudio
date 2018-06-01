---
--- Created by tanqiang.
--- DateTime: 2018/5/8 15:47
---
local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')
local TableBiJiSixModel = class('TableBiJiSixModel', Model)

function TableBiJiSixModel:initialize(...)
    self.sendMsgNetClientName = "bullfight"
    Model.initialize(self, ...)

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Get_Pokers",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Get_Poker", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Confirm",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Comfirm", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Get_Result",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Get_Result", retData)
            end
        end
    })

    --大结算
    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_LastSettleAccounts_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_LastSettleAccounts_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Reconnect",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Reconnect", retData)
            end
        end
    })

    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_ExpiresInfo_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)

                Model.dispatch_event(self, "Event_Table_ExpiresInfo_Notify", retData)
            end
        end
    })

    --踢人广播
    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Kick_Player_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Kick_Player_Notify", retData)
            end
        end
    })
end

--离开房间请求
function TableBiJiSixModel:request_exit_room(userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Leave_Room")
    request.userID = userID;
    Model.send_msg(self, msgId, request)
end

--准备请求
function TableBiJiSixModel:request_ready(userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ready")
    request.isReady = 1
    request.userID = userID
    Model.send_msg(self, msgId, request)
end

--投降请求
function TableBiJiSixModel:request_surrender(userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Player_Surrender");
    request.userID = userID
    Model.send_msg(self, msgId, request);
end

--解散房间请求
function TableBiJiSixModel:request_dissolve_room(agree)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Dissolve_Room")
    request.agree = agree
    Model.send_msg(self, msgId, request)
end

--踢人
function TableBiJiSixModel:request_kick_player(player_id)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Kick_Player");
    request.player_id = tonumber(player_id);
    Model.send_msg(self, msgId, request)
end



function TableBiJiSixModel:request_submit(pokers , userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Submit")
    request.poker1.Color = pokers[1].Color;
    request.poker1.Number = pokers[1].Number;
    request.poker2.Color = pokers[2].Color;
    request.poker2.Number = pokers[2].Number;
    request.poker3.Color = pokers[3].Color;
    request.poker3.Number = pokers[3].Number;
    request.poker4.Color = pokers[4].Color;
    request.poker4.Number = pokers[4].Number;
    request.poker5.Color = pokers[5].Color;
    request.poker5.Number = pokers[5].Number;
    request.poker6.Color = pokers[6].Color;
    request.poker6.Number = pokers[6].Number;
    request.poker7.Color = pokers[7].Color;
    request.poker7.Number = pokers[7].Number;
    request.poker8.Color = pokers[8].Color;
    request.poker8.Number = pokers[8].Number;
    request.poker9.Color = pokers[9].Color;
    request.poker9.Number = pokers[9].Number;
    request.userID = tonumber(userID);
    Model.send_msg(self, msgId, request)
end


return TableBiJiSixModel