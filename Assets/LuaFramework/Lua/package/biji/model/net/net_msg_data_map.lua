local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
local msgName2MsgData = {}
setmetatable(msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.msgName2MsgData = msgName2MsgData

-- 此处必须与路径一致
NetMsgApi.path = "package.biji.model.net.protol."

NetMsgApi.msgName2MsgData.Msg_Table_Enter_Room = {"Room.EnterReq", "EnterReq", "Room.EnterRsp", "EnterRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Ready = {"Room.ReadyReq", "ReadyReq", "Room.ReadyRsp", "ReadyRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Start = {"Room.StartReq", "StartReq", "Room.StartRsp", "StartRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Leave_Room = {"Room.LeaveReq", "LeaveReq", "Room.LeaveRsp", "LeaveRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Leave_Room_Notify = {"", "", "Room.LeaveBroadcast", "LeaveBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room = {"Room.FreeReq", "FreeReq", "Room.FreeRsp", "FreeRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_RoomRequest_Notify = {"", "", "Room.FreeBroadcast", "FreeBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room_Notify = {"", "", "Room.FreeSuccessBroadcast", "FreeSuccessBroadcast", "", "bijitable.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_Confirm = {"", "", "Room.ConfirmBroadcast", "ConfirmBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Get_Pokers = {"", "", "Room.PokersOfPlayer", "PokersOfPlayer", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Player_Surrender = {"Room.SurrenderReq", "SurrenderReq", "Room.SurrenderRsp", "SurrenderRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Surrender = {"", "", "Room.TableSurrender", "TableSurrender", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Complete_Match = {"Room.PokersOfMatchingReq", "PokersOfMatchingReq", "Room.PokersOfMatchingRsp", "PokersOfMatchingRsp","bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Submit = {"Room.PokersOfSubmitReq", "PokersOfSubmitReq", "", "", "bijitable.room_pb", ""}
NetMsgApi.msgName2MsgData.Msg_Table_Get_Result = {"", "", "Room.ResultOfComparing", "ResultOfComparing", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Kick_Player = {"Room.KickPlayerReq", "KickPlayerReq", "Room.KickPlayerRsp", "KickPlayerRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Kick_Player_Notify = {"", "", "Room.KickPlayerNotify", "KickPlayerNotify", "", "bijitable.room_pb"}    
NetMsgApi.msgName2MsgData.Msg_Table_Red_Packet_Notify = {"", "", "Room.RoomAwardMessage", "RoomAwardMessage", "", "bijitable.room_pb"}  

NetMsgApi.msgName2MsgData.Msg_Table_Reconnect = {"", "", "Room.ReconnectInfo", "ReconnectInfo", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Temporary_Leave = {"Room.TemporaryLeaveReq", "TemporaryLeaveReq", "Room.TemporaryLeaveRsp", "TemporaryLeaveRsp", "bijitable.room_pb", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Temporary_Leave_Notify = {"", "", "Room.TemporaryLeaveBroadcast", "TemporaryLeaveBroadcast", "", "bijitable.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room = {"Room.FreeReq", "FreeReq", "Room.FreeRsp", "FreeRsp", "bijitable.room_pb", "bijitable.room_pb"}    --请求解散房间
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_RoomRequest_Notify = {"", "", "Room.FreeBroadcast", "FreeBroadcast", "", "bijitable.room_pb"}    --请求解散房间通知
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room_Notify = {"", "", "Room.FreeSuccessBroadcast", "FreeSuccessBroadcast", "", "bijitable.room_pb"}    --解散房间通知

NetMsgApi.msgName2MsgData.Msg_Table_SynExpire_Notify = {"", "", "Room.SynExpireBroadcast", "SynExpireBroadcast", "", "bijitable.room_pb"}

--同步到期信息(state 0:房间等待准备状态 1:定庄状态 2:下注状态 3:等待结算状态, 4:准备倒计时， 5：配牌倒计时)
NetMsgApi.msgName2MsgData.Msg_Table_ExpiresInfo_Notify = {"", "", "Room.ExpiresInfo", "ExpiresInfo", "", "bijitable.room_pb"}


NetMsgApi.msgName2MsgData.Msg_Table_EnterRoom_Notify = {"", "", "Room.EnterBroadcast", "EnterBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Reconnect_Notify = {"", "", "Room.ReconnBroadcast", "ReconnBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Disconnect_Notify = {"", "", "Room.DisconnBroadcast", "DisconnBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Ready_Notify = {"", "", "Room.ReadyBroadcast", "ReadyBroadcast", "", "bijitable.room_pb"}


NetMsgApi.msgName2MsgData.Msg_Table_Reset_Notify = {"", "", "", "", "", ""}
NetMsgApi.msgName2MsgData.Msg_Table_Synchronize_Notify = {"", "", "Room.SynchronizeBroadcast", "SynchronizeBroadcast", "", "bijitable.room_pb"}
--大结算广播
NetMsgApi.msgName2MsgData.Msg_Table_LastSettleAccounts_Notify = {"", "", "Room.LastSettleAccountsBroadcast", "LastSettleAccountsBroadcast", "", "bijitable.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_OwnerChangeBroadcast_Notify = {"", "", "Room.OwnerChangeBroadcast", "OwnerChangeBroadcast", "", "bijitable.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerExpire_Notify = {"", "", "Room.KickPlayerExpire", "KickPlayerExpire", "", "bijitable.room_pb"}

return NetMsgApi