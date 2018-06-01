--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('core.mvvm.model_base')
--- @class CowBoy_TableModel
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
                --print("Event_Table_Enter_Room")      
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
                --print("Msg_Table_SetBanker_Notify")         
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
                --print("Msg_Table_ScrambleBanker_Notify")         
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

    --亲友圈 快速组局 踢人倒计时
    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_KickPlayerExpire",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                print("---------------------Msg_Table_KickPlayerExpire.expire=",retData.expire)
                Model.dispatch_event(self, "Event_Table_KickPlayerExpire", retData)
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

    -- 玩家金币变化通知
    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_ShotSettle_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_ShotSettle_Notify", retData)
            end
        end
    })

end



---------------------------------------------------------------------------------


function TableModel:request_ping()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ping")
    Model.send_msg(self, msgId, request) 
    if(not self.lastPingReqeustTime)then
        self.lastPingReqeustTime = Time.realtimeSinceStartup
    end
end


function TableModel:request_exit_room()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Leave_Room")
    Model.send_msg(self, msgId, request)
end


function TableModel:request_ready()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Ready")
    request.isReady = 1
    Model.send_msg(self, msgId, request)
end

function TableModel:request_start()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Start")
    Model.send_msg(self, msgId, request)
end

function TableModel:request_bet_custom(score)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Bet")
    request.bet_type = score;
    Model.send_msg(self, msgId, request)
end

function TableModel:request_bet(bet)
    local roomInfo = self.modelData.curTableData.roomInfo
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Bet")
    if(roomInfo.ruleTable.isBigBet == 1)then
        if(bet == 3)then
            request.bet_type = 1
        elseif(bet == 4)then
            request.bet_type = 2
        elseif(bet == 5)then
            request.bet_type = 5
        elseif(bet == 8 or bet == 10)then
            request.bet_type = 4
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("错误的倍率")
            return
        end
    else
        if(bet == 2)then
            request.bet_type = 1
        elseif(bet == 3)then
            request.bet_type = 2
        elseif(bet == 4)then
            request.bet_type = 3
        elseif(bet == 5)then
            request.bet_type = 5
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("错误的倍率")
            return
        end
    end
    --request.bet_type = betType;				--倍数选择 1:2倍  2:3倍 3:4倍 4:10倍 
    Model.send_msg(self, msgId, request)
end

function TableModel:request_scrambleBanker(is_scramble, multiple)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_ScrambleBanker")
    request.is_scramble = is_scramble;				--是否抢庄
    if(multiple)then
        request.multiple = multiple
    end
    Model.send_msg(self, msgId, request)
end

function TableModel:request_compute_poker()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_ComputePoker")    
    Model.send_msg(self, msgId, request)
end

--踢人请求
function TableModel:request_KickPlayerReq(_player_id)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_KickPlayerReq")
    request.player_id = _player_id
    Model.send_msg(self, msgId, request)
end


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

--刷新玩家金币数请求
function TableModel:request_refresh_user_coin()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_RefreshCoinBalance")
    Model.send_msg(self, msgId, request)
end

return  TableModel