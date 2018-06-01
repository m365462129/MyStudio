local Model=require('core.mvvm.model_base');
local class = require("lib.middleclass");

---@class TableShiSanZhangModel : Model
local TableShiSanZhangModel = class('tableShiSanZhangModel', Model);

function TableShiSanZhangModel:initialize( ... )
    Model.initialize(self,...);

    self.sendMsgNetClientName = "bullfight"
        self.heartbeatRequestName = "Login.PingReq"
    -- self.heartbeatResponseName = "Login.PingRsp"
    self.heartbeatResponseName = "Msg_Table_Ping"
    print(self);
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Start_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Start_Notify", retData)                               
            end
        end
    })
    -- body
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
        msgName = "Msg_Table_Surrender",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer) 
                Model.dispatch_event(self, "Event_Table_Surrender", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Ping",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                if(self.lastPingReqeustTime)then
                    self.pingDelayTime = UnityEngine.Time.realtimeSinceStartup - self.lastPingReqeustTime
                    self.lastPingReqeustTime = nil
                    if(self.pingDelayTime == 0)then
                        self.pingDelayTime = 0.06
                    end
                end
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                Model.dispatch_event(self, "Event_Table_Ping", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Enter_Room",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                print_table(retData,"---------Msg_Table_Enter_Room--------")
                Model.dispatch_event(self, "Event_Table_Enter_Room", retData)                               
            end
        end
    })
    
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Leave_Room",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                Model.dispatch_event(self, "Event_Table_Leave_Room", retData)                               
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

     Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Ready_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer) 
                Model.dispatch_event(self, "Event_Table_Ready_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Ready",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer) 
                Model.dispatch_event(self, "Event_Table_Ready_Rsp", retData)                               
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
        msgName = "Msg_Player_Surrender",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                --Model.dispatch_event(self, "Event_Table_Ping", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Start",    
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Start_Rsp", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Complete_Match",    
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Complete_Match_Rsp", retData)
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
        msgName = "Msg_Table_EnterRoom_Notify",    
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_EnterRoom_Notify", retData)
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

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Kick_Player_Notify",    
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Kick_Player_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Reconnect_Notify",    
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Reconnect_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_Disconnect_Notify",    
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_Disconnect_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Leave_Room",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Leave_Room_Rsp", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Leave_Room_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Leave_Room_Notify", retData)                               
            end
        end
    })
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Dissolve_Room",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Dissolve_Room_Rsp", retData)                               
            end
        end
    })
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Dissolve_RoomRequest_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Dissolve_RoomRequest_Notify", retData)                    
            end
        end
    })
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Dissolve_Room_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Dissolve_Room_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Temporary_Leave",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                --Model.dispatch_event(self, "Event_Table_Dissolve_Room_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Temporary_Leave_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Temporary_Leave_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Chat_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                Model.dispatch_event(self, "Event_Table_Chat_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Synchronize_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                Model.dispatch_event(self, "Event_Table_Synchronize_Notify", retData)                               
            end
        end
    })

        --位置自定义信息变化响应
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_CustomInfoChangeRsp",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                print("====位置变化响应Msg_Table_CustomInfoChangeRsp")                             
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Submit",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                print("====",retData.errno)                             
            end
        end
    })

    --位置自定义信息变化广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_CustomInfoChangeBroadcast",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                print("====位置变化广播Msg_Table_CustomInfoChangeBroadcast")  
                Model.dispatch_event(self, "Event_Table_CustomInfoChangeBroadcast", retData)                            
            end
        end
    })

    --房主易位 通知
    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_OwnerChangeBroadcast_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                
                Model.dispatch_event(self, "Event_Table_OwnerChangeBroadcast", retData)                            
            end
        end
    })

    --亲友圈 快速组局 踢人倒计时
    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_KickPlayerExpire_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                
                Model.dispatch_event(self, "Event_Table_KickPlayerExpire", retData)                            
            end
        end
    })
    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_Kick_Player",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                
                Model.dispatch_event(self, "Event_Table_KickPlayer", retData)                            
            end
        end
    })

    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_Red_Packet_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                
                Model.dispatch_event(self, "Event_Table_Red_Packet_Notify", retData)                            
            end
        end
    })
end

function TableShiSanZhangModel:request_kick_player(player_id)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Kick_Player");
    request.player_id = tonumber(player_id);
    Model.send_msg(self, msgId, request)
end

function TableShiSanZhangModel:request_ready(isReady,userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ready");
    request.isReady = isReady;
    request.userID = userID;
    Model.send_msg(self, msgId, request)
end

function TableShiSanZhangModel:request_complete_match(pokers , userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Complete_Match");
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
    -- for i=1,#pokers do
    --     request.pokers[i].Color = pokers[i].Color
    --     request.pokers[i].Color = pokers[i].Number
    -- end
    Model.send_msg(self, msgId, request) 
end

function TableShiSanZhangModel:request_ping()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ping")
    Model.send_msg(self, msgId, request) 
    if(not self.lastPingReqeustTime)then
        self.lastPingReqeustTime = Time.realtimeSinceStartup
    end
end

function TableShiSanZhangModel:request_surrender(userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Player_Surrender");
    request.userID = tonumber(userID);
    Model.send_msg(self, msgId, request); 
end

function TableShiSanZhangModel:request_temporary_leave(isLeave, userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Temporary_Leave");
    request.is_temporary_leave = isLeave;
    request.player_id = tonumber(userID);
    Model.send_msg(self, msgId, request); 
end

function TableShiSanZhangModel:request_start()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Start")
    
    Model.send_msg(self, msgId, request) 
end

function TableShiSanZhangModel:request_submit(pokers , userID, pokerType)
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
    request.poker10.Color = pokers[10].Color;
    request.poker10.Number = pokers[10].Number;
    request.poker11.Color = pokers[11].Color;
    request.poker11.Number = pokers[11].Number;
    request.poker12.Color = pokers[12].Color;
    request.poker12.Number = pokers[12].Number;
    request.poker13.Color = pokers[13].Color;
    request.poker13.Number = pokers[13].Number;
    request.pokerType = pokerType;
    request.userID = tonumber(userID);
    Model.send_msg(self, msgId, request) 
end


--解散房间请求
function TableShiSanZhangModel:request_dissolve_room(agree)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Dissolve_Room")
    request.agree = agree
    Model.send_msg(self, msgId, request)
end

function TableShiSanZhangModel:request_exit_room(userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Leave_Room")
    request.userID = userID;
    Model.send_msg(self, msgId, request)
end

--聊天相关
--//消息类型，0:快捷短语,1:表情,2:语音
--//消息内容，当msgType==0时，为快捷短语id，当msgType==1时，为表情id;当msgType==2时为语音id
function TableShiSanZhangModel:request_chat(msgType, text)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Chat")    
    request.chatMsg.msgType = msgType
    request.chatMsg.text = text
    Model.send_msg(self, msgId, request)
end
------位置信息变化请求
function TableShiSanZhangModel:request_CustomInfoChange(customInfoJsonString)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_CustomInfoChangeReq")
    request.customInfo = customInfoJsonString
    Model.send_msg(self, msgId, request)
end

return TableShiSanZhangModel;