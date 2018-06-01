--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('core.mvvm.model_base')
---@class PaoHuZiTableBaseModel
local TableBaseModel = class('tablelBaseModel', Model)
local NetClientManager = ModuleCache.net.NetClientManager
local Time = Time


function TableBaseModel:initialize(...)
    Model.initialize(self, ...)
    self.sendMsgNetClientName = "gameServer"
    self.SeqNo = 0

    DataHuaPai = self

    self.heartbeatRequestName = "1"
    -- self.heartbeatResponseName = "Login.PingRsp"
    self.heartbeatResponseName = "Msg_Heart_Beat"

    Model.subscibe_msg_event(self, {    --游戏状态推送
        msgName = "Msg_Heart_Beat",
        callback = function(msgName, msgBuffer)
            if(self.lastPingReqeustTime)then
                self.pingDelayTime = UnityEngine.Time.realtimeSinceStartup - self.lastPingReqeustTime
                self.lastPingReqeustTime = nil
                if(self.pingDelayTime == 0)then
                    self.pingDelayTime = 0.06
                end
            end
            -- self.lastReceiveHeartPackTime = Time.realtimeSinceStartup
            -- local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)    
            -- self.pingDelayTime = Time.realtimeSinceStartup - self.lastPingReqeustTime
            -- print('延迟:'..self.pingDelayTime * 1000)
            -- Model.dispatch_event(self, "Event_Msg_Heart_Beat", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --游戏状态推送
        msgName = "Msg_Table_GameStateNTF",
        callback = function(msgName, msgBuffer)
            print('游戏状态推送')
            if self.NoJieXiGameState then
                return
            end
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)   
            self.SeqNo = retData.SeqNo

            self.Msg_Table_GameStateNTFNew = retData
            Model.dispatch_event(self, "Event_Msg_Table_GameStateNTF", retData)

            self:clear_share_room_info_text()
        end
    })

    Model.subscibe_msg_event(self, {    --游戏重新开始
        msgName = "Msg_Table_Restart",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)     
            Model.dispatch_event(self, "Event_Msg_Table_Restart", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --用户信息推送
        msgName = "Msg_RoomUserInfoNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Msg_RoomUserInfoNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --用户状态推送
        msgName = "Msg_Table_UserStateNTF",
        callback = function(msgName, msgBuffer)
            print('用户状态推送')
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)  
            self.Msg_Table_UserStateNTF = retData
            local num = 0
            for key, v in pairs(retData.State) do
                if v.UserID ~= "0" and v.UserID ~= nil and v.Ready then
                    num = num + 1
                end
            end
            self.Msg_Table_UserStateNTFNumPrep = num


            local numo = 0
            for key, v in pairs(retData.State) do
                if v.UserID ~= "0" and v.UserID ~= nil then
                    numo = numo + 1
                end
            end
            self.Msg_Table_UserStateNTFNumAll = numo


            for key, v in pairs(retData.State) do
                if v.UserID == self.modelData.roleData.userID then
                    self.Msg_Table_UserStateNTF_Self = v
                    TableManager.phzTableData.SeatID = v.SeatID
                end
            end

            if self.Msg_Table_UserStateNTF_Self.ErrInfo ~= nil and self.Msg_Table_UserStateNTF_Self.ErrInfo ~= "" then
                ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(self.Msg_Table_UserStateNTF_Self.ErrInfo)
            end

            if tonumber(self.Msg_Table_UserStateNTF_Self.ErrCode) == -888 then
               
            else
                Model.dispatch_event(self, "Event_Msg_Table_UserStateNTF", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --房间内玩家上线
        msgName = "Msg_RoomUserOnlineNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Msg_RoomUserOnlineNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --房间内玩家离线
        msgName = "Msg_RoomUserOfflineNTF",
        callback = function(msgName, msgBuffer)
            


            self.Msg_Table_UserStateNTFNumPrep = self.Msg_Table_UserStateNTFNumPrep or 0
            self.Msg_Table_UserStateNTFNumPrep = self.Msg_Table_UserStateNTFNumPrep - 1


            self.Msg_Table_UserStateNTFNumAll = self.Msg_Table_UserStateNTFNumAll or 0
            self.Msg_Table_UserStateNTFNumAll = self.Msg_Table_UserStateNTFNumAll - 1

            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Msg_RoomUserOfflineNTF", retData)


    
        end
    })

    Model.subscibe_msg_event(self, {    --房间解散状态回应
        msgName = "Msg_DismissNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)      
            self.Msg_DismissNTF = retData
            Model.dispatch_event(self, "Event_Msg_DismissNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --房间内玩家被踢出
        msgName = "Msg_KickedNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Msg_KickedNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --相同用户已在另一地点登录，当前用户已被迫下线
        msgName = "Msg_SameUserLoginNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Msg_SameUserLoginNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --房间已解散
        msgName = "Msg_RoomDismissedNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)     
            self.Msg_RoomDismissedNTF = retData      
            Model.dispatch_event(self, "Event_Msg_RoomDismissedNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --玩家即时反馈的状态
        msgName = "Msg_ReportStateNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
            self.Msg_ReportStateNTF_Table = self.Msg_ReportStateNTF_Table or {}
            self.Msg_ReportStateNTF_Table[retData.SeatID] = retData
            Model.dispatch_event(self, "Event_Msg_ReportStateNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --单独聊天信息
        msgName = "Private_MessageNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Private_MessageNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --聊天信息
        msgName = "Msg_MessageNTF",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)    
            Model.dispatch_event(self, "Event_Msg_MessageNTF", retData)
        end
    })

    Model.subscibe_msg_event(self, {    --退出房间
        msgName = "Msg_Exit_Room",
        callback = function(msgName, msgBuffer)
            local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
            Model.dispatch_event(self, "Event_Msg_Exit_Room", retData)
        end
    })

    Model.subscibe_msg_event(self, {     --还剩多少秒踢人
        msgName = "Msg_ReturnKickedTimeOutNTF",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Msg_ReturnKickedTimeOutNTF", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {     --房间奖励信息
        msgName = "Msg_RoomAwardMessageNTF",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Msg_RoomAwardMessageNTF", retData)
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

end

function TableBaseModel:request_exit_roomJinBi(userID)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Leave_Room")
    request.userID = userID;
    Model.send_msg(self, msgId, request)
end

function TableBaseModel:request_heartbeat()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Heart_Beat")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
    if(not self.lastPingReqeustTime)then
        self.lastPingReqeustTime = Time.realtimeSinceStartup
    end
end

function TableBaseModel:request_exit_room()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Exit_Room")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_chupai(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_ChuPai")
    request.pai = pai
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_kai_ju_ting_mj()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_TING")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_chi()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Chi")
    --request.Pai = pai
    --request.id = SeqNo
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
    print('Msg_Table_Chi')
end

function TableBaseModel:request_peng()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Peng")
    --request.Pai = pai
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
    print('Msg_Table_Peng')
end

function TableBaseModel:request_di()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Di")
    --request.Pai = pai
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)

    print('Msg_Table_Di')
end



function TableBaseModel:request_zhua()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Zhua")
    --request.Pai = pai
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
    print('Msg_Table_Zhua')
end

function TableBaseModel:request_gang_mj(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Gang")
    request.Pai = pai
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_hu()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Hu")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_guo()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Guo")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_restart()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Restart")
    --request.Piao = data.Piao
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_pailie_shoupai(data)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_PaiLieShouPai")
    print_table(data)
    request.horizontal_id_old = data.horizontal_id_old
    request.vertical_id_old = data.vertical_id_old
    request.horizontal_id_new = data.horizontal_id_new
    request.vertical_id_new = data.vertical_id_new
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_maima_mj(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_MaiMa")
    request.Pai = pai
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_kaigang_mj()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_KaiGang")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_mopai_mj()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_MoPai")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_piaohua_mj()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_PiaoHua")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

-- 聊天信息（包括文字、表情、语音等）
function TableBaseModel:request_chat(msg)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Message")
    request.Message = ModuleCache.Json.encode(msg)
    if msg.chatType == 4 then
        request.AppendData = request.Message
    end
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

-- 1:申请解散 2:同意解散 3:拒绝解散
function TableBaseModel:request_dissolve_room(action)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Dismiss")
    request.Action = action
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

------位置信息变化请求
function TableBaseModel:request_CustomInfoChange(customInfoJsonString)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_CustomInfoChangeReq")
    request.customInfo = customInfoJsonString
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end


-- 踢出用户
function TableBaseModel:request_kick_player(playerId)
    local msgId, request = self.netMsgApi:create_request_data("Msg_KickUser")
    request.UserID = playerId
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

-- 上报状态 0 =正常 1=离开 
function TableBaseModel:request_report_player(state)
    local client = NetClientManager.get_client("gameServer")
    if(not client) then
        return
    end
    local msgId, request = self.netMsgApi:create_request_data("Msg_ReportState")
    request.State = state
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

-- 获取踢人倒计时
function TableBaseModel:request_get_kicked_timeout()
    local msgId, request = self.netMsgApi:create_request_data("Msg_GetKickedTimeOut")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

-- 补花
function TableBaseModel:request_buhua_mj()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_BuHua")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableBaseModel:request_Msg_ACTION_PIAO(PiaoNum)
    local msgId, request = self.netMsgApi:create_request_data("Msg_ACTION_PIAO")
    request.PiaoNum = PiaoNum


    --required int32 PiaoNum = 1;	//漂、尊的分数  PiaoNum
	--optional int32 Pao = 2;		//跑分
	--optional bool DiTuo = 3;
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end


-- 取消托管
function TableBaseModel:request_quxiaoTuoGuan(type)
    type = type or 2
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Intrust")
    request.type = type
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end


--
-- 请求刷新金币
function TableBaseModel:request_ACTION_REFRESH_COINS()
    local msgId, request = self.netMsgApi:create_request_data("ACTION_REFRESH_COINS")
    Model.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end




return  TableBaseModel