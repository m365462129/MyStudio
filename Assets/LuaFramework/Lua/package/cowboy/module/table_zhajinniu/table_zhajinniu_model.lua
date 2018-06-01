--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('core.mvvm.model_base')
---@class TableModel_ZhaJinNiu:Model
local TableModel = class('tableModel', Model)


function TableModel:initialize(...)
    Model.initialize(self, ...)
    self.sendMsgNetClientName = "bullfight"
    self.heartbeatRequestName = "Login.PingReq"
    -- self.heartbeatResponseName = "Login.PingRsp"
    self.heartbeatResponseName = "Msg_Table_Ping"

    Model.subscibe_msg_event(self, {    --登录回调
        msgName = "Msg_Table_Login",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Login", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --登录回调
        msgName = "Msg_Table_Enter_Room",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                print("Event_Table_Enter_Room")      
                Model.dispatch_event(self, "Event_Table_Enter_Room", retData)                        
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
        msgName = "Msg_Table_Ready",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Ready_Rsp", retData)                               
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
        msgName = "Msg_Table_AgoSettleAccounts_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_AgoSettleAccounts_Notify", retData)                               
            end
        end
    })



    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Bet",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Bet", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Bet_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Bet_Notify", retData)                                        
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Deal_Poker",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                --Model.dispatch_event(self, "Event_Table_Deal_Poker_Rsp", retData)   
                Model.dispatch_event(self, "Event_Table_Deal_Poker_Notify", retData)                               
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
        msgName = "Msg_Table_Ready_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Ready_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Start_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Start_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Deal_Poker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Deal_Poker_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ComputePoker",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ComputePoker", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ComputePoker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ComputePoker_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_SettleAccounts_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_SettleAccounts_Notify", retData)                               
            end
        end
    })

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
        msgName = "Msg_Table_Reset_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_Reset_Notify", retData)                               
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
        msgName = "Msg_Table_SetBanker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                print("Msg_Table_SetBanker_Notify")         
                Model.dispatch_event(self, "Event_Table_SetBanker_Notify", retData)                               
            end
        end
    })

    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ScrambleBanker",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ScrambleBanker", retData)                               
            end
        end
    })

     Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ScrambleBanker_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
                print("Msg_Table_ScrambleBanker_Notify")         
                Model.dispatch_event(self, "Event_Table_ScrambleBanker_Notify", retData)                               
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
        msgName = "Msg_Table_SynExpire_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                Model.dispatch_event(self, "Event_Table_SynExpire_Notify", retData)                               
            end
        end
    })



    --聊天相关
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_Chat",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                         
                Model.dispatch_event(self, "Event_Table_Chat", retData)                               
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

    --解散房间相关
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

     --暂时离开
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_TemporaryLeave",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_TemporaryLeave", retData)                               
            end
        end
    })
    --暂时离开
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_TemporaryLeave_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_TemporaryLeave_Notify", retData)                               
            end
        end
    })

    -----------------------------------------------------------
    --等待玩家说话广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ZhaJinNiu_Sync_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ZhaJinNiu_Sync_Notify", retData)                               
            end
        end
    })

    --等待玩家说话广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_WaitSpeak_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_WaitSpeak_Notify", retData)                               
            end
        end
    })

    --弃牌
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_DropPokers",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_DropPokers", retData)                               
            end
        end
    })

    --弃牌广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_DropPokers_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_DropPokers_Notify", retData)                               
            end
        end
    })

    --看牌
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_CheckPokers",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_CheckPokers", retData)                               
            end
        end
    })

    --看牌广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_CheckPokers_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_CheckPokers_Notify", retData)                               
            end
        end
    })

    --比牌
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ComparePokers",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ComparePokers", retData)                               
            end
        end
    })

    --比牌广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ComparePokers_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ComparePokers_Notify", retData)                               
            end
        end
    })

    --跟注
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_CallBet",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_CallBet", retData)                               
            end
        end
    })

    --跟注广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_CallBet_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_CallBet_Notify", retData)                               
            end
        end
    })

    --单局结算
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ZhaJinNiu_SettleAccounts_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ZhaJinNiu_SettleAccounts_Notify", retData)                               
            end
        end
    })

    --上一局结算
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ZhaJinNiu_AgoSettleAccounts_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ZhaJinNiu_AgoSettleAccounts_Notify", retData)                               
            end
        end
    })

    --比牌失败广播
    Model.subscibe_msg_event(self, {   
        msgName = "Msg_Table_ZhaJinNiu_CompareFail_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)                
                Model.dispatch_event(self, "Event_Table_ZhaJinNiu_CompareFail_Notify", retData)                               
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

    -- 监听踢人响应
    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_KickPlayerBroadcast",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)

                Model.dispatch_event(self, "Event_Table_KickPlayerBroadcast", retData)
            end
        end
    })
end



---------------------------------------------------------------------------------

--心跳包请求
function TableModel:request_ping()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ping")
    Model.send_msg(self, msgId, request) 
    if(not self.lastPingReqeustTime)then
        self.lastPingReqeustTime = Time.realtimeSinceStartup
    end
end

--退出房间请求
function TableModel:request_exit_room()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Leave_Room")
    Model.send_msg(self, msgId, request)
end

--准备请求
function TableModel:request_ready()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ready")
    request.isReady = 1
    Model.send_msg(self, msgId, request)
end

--开始请求
function TableModel:request_start()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Start")
    Model.send_msg(self, msgId, request)
end

--跟注请求
function TableModel:request_call_bet(betScore)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_CallBet")
    request.betScore = betScore;				
    Model.send_msg(self, msgId, request)
end

--比牌请求
function TableModel:request_compare_pokers(player_id)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_ComparePokers")
    if(type(player_id) == "string")then
        player_id = tonumber(player_id)
    end
    request.target_player_id = player_id;				--比牌的目标玩家
    Model.send_msg(self, msgId, request)
end

--看牌请求
function TableModel:request_check_pokers()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_CheckPokers")    
    Model.send_msg(self, msgId, request)
end

--弃牌请求
function TableModel:request_drop_pokers()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_DropPokers")    
    Model.send_msg(self, msgId, request)
end
-------------------------------------------------------------------------

--聊天相关
--//消息类型，0:快捷短语,1:表情,2:语音
--//消息内容，当msgType==0时，为快捷短语id，当msgType==1时，为表情id;当msgType==2时为语音id
function TableModel:request_chat(msgType, text)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Chat")    
    request.chatMsg.msgType = msgType
    request.chatMsg.text = text
    Model.send_msg(self, msgId, request)
end

--解散房间请求
function TableModel:request_dissolve_room(agree)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Dissolve_Room")
    request.agree = agree
    Model.send_msg(self, msgId, request)
end

--暂时离开
function TableModel:request_TempLeave(leave)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_TemporaryLeave")
    request.is_temporary_leave = leave
    Model.send_msg(self, msgId, request) 
end

------位置信息变化请求
function TableModel:request_CustomInfoChange(customInfoJsonString)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_CustomInfoChangeReq")
    request.customInfo = customInfoJsonString
    Model.send_msg(self, msgId, request)
end

--踢人请求
function TableModel:request_KickPlayerReq(_player_id)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_KickPlayerReq")
    request.player_id = _player_id
    Model.send_msg(self, msgId, request)
end

return  TableModel