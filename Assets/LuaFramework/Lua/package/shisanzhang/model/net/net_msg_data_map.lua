local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
NetMsgApi.msgName2MsgData = {}
setmetatable(NetMsgApi.msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.path = "package.shisanzhang.model.net.protol."

-- 此处必须与路径一致
NetMsgApi.path = "package.shisanzhang.model.net.protol."

NetMsgApi.msgName2MsgData.Msg_Table_Enter_Room = {"Room.EnterReq", "EnterReq", "Room.EnterRsp", "EnterRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Ready = {"Room.ReadyReq", "ReadyReq", "Room.ReadyRsp", "ReadyRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Start = {"Room.StartReq", "StartReq", "Room.StartRsp", "StartRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Leave_Room = {"Room.LeaveReq", "LeaveReq", "Room.LeaveRsp", "LeaveRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Leave_Room_Notify = {"", "", "Room.LeaveBroadcast", "LeaveBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room = {"Room.FreeReq", "FreeReq", "Room.FreeRsp", "FreeRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_RoomRequest_Notify = {"", "", "Room.FreeBroadcast", "FreeBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room_Notify = {"", "", "Room.FreeSuccessBroadcast", "FreeSuccessBroadcast", "", "table.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_Confirm = {"", "", "Room.ConfirmBroadcast", "ConfirmBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Get_Pokers = {"", "", "Room.PokersOfPlayer", "PokersOfPlayer", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Player_Surrender = {"Room.SurrenderReq", "SurrenderReq", "Room.SurrenderRsp", "SurrenderRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Surrender = {"", "", "Room.TableSurrender", "TableSurrender", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Complete_Match = {"Room.PokersOfMatchingReq", "PokersOfMatchingReq", "Room.PokersOfMatchingRsp", "PokersOfMatchingRsp","table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Submit = {"Room.PokersOfSubmitReq", "PokersOfSubmitReq", "Room.PokersOfSubmitRsp", "PokersOfSubmitRsp", "table.room_pb", ""}
NetMsgApi.msgName2MsgData.Msg_Table_Get_Result = {"", "", "Room.ResultOfComparing", "ResultOfComparing", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Kick_Player = {"Room.KickPlayerReq", "KickPlayerReq", "Room.KickPlayerRsp", "KickPlayerRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Kick_Player_Notify = {"", "", "Room.KickPlayerNotify", "KickPlayerNotify", "", "table.room_pb"}    
NetMsgApi.msgName2MsgData.Msg_Table_Red_Packet_Notify = {"", "", "Room.RoomAwardMessage", "RoomAwardMessage", "", "table.room_pb"}  

NetMsgApi.msgName2MsgData.Msg_Table_Reconnect = {"", "", "Room.ReconnectInfo", "ReconnectInfo", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Temporary_Leave = {"Room.TemporaryLeaveReq", "TemporaryLeaveReq", "Room.TemporaryLeaveRsp", "TemporaryLeaveRsp", "table.room_pb", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Temporary_Leave_Notify = {"", "", "Room.TemporaryLeaveBroadcast", "TemporaryLeaveBroadcast", "", "table.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room = {"Room.FreeReq", "FreeReq", "Room.FreeRsp", "FreeRsp", "table.room_pb", "table.room_pb"}    --请求解散房间
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_RoomRequest_Notify = {"", "", "Room.FreeBroadcast", "FreeBroadcast", "", "table.room_pb"}    --请求解散房间通知
NetMsgApi.msgName2MsgData.Msg_Table_Dissolve_Room_Notify = {"", "", "Room.FreeSuccessBroadcast", "FreeSuccessBroadcast", "", "table.room_pb"}    --解散房间通知

NetMsgApi.msgName2MsgData.Msg_Table_SynExpire_Notify = {"", "", "Room.SynExpireBroadcast", "SynExpireBroadcast", "", "table.room_pb"}



NetMsgApi.msgName2MsgData.Msg_Table_EnterRoom_Notify = {"", "", "Room.EnterBroadcast", "EnterBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Reconnect_Notify = {"", "", "Room.ReconnBroadcast", "ReconnBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Disconnect_Notify = {"", "", "Room.DisconnBroadcast", "DisconnBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Ready_Notify = {"", "", "Room.ReadyBroadcast", "ReadyBroadcast", "", "table.room_pb"}


NetMsgApi.msgName2MsgData.Msg_Table_Reset_Notify = {"", "", "Room.ResetBroadcast", "ResetBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Synchronize_Notify = {"", "", "Room.SynchronizeBroadcast", "SynchronizeBroadcast", "", "table.room_pb"}
--大结算广播
NetMsgApi.msgName2MsgData.Msg_Table_LastSettleAccounts_Notify = {"", "", "Room.LastSettleAccountsBroadcast", "LastSettleAccountsBroadcast", "", "table.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_OwnerChangeBroadcast_Notify = {"", "", "Room.OwnerChangeBroadcast", "OwnerChangeBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerExpire_Notify = {"", "", "Room.KickPlayerExpire", "KickPlayerExpire", "", "table.room_pb"}

return NetMsgApi