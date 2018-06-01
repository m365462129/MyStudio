local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
NetMsgApi.msgName2MsgData = {}
setmetatable(NetMsgApi.msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.path = "package.doudizhu.model.net.protol."

local game_pb_name = "table.game_pb"
--明牌
NetMsgApi.msgName2MsgData.Msg_Table_Show_Cards = {"Game.ShowCardsReq", "ShowCardsReq", "Game.ShowCardsRet", "ShowCardsRet", game_pb_name, game_pb_name}
--明牌通知
NetMsgApi.msgName2MsgData.Msg_Table_Show_Cards_Notify = {"", "", "Game.ShowCardsNotify", "ShowCardsNotify", game_pb_name, game_pb_name}
--抢地主
NetMsgApi.msgName2MsgData.Msg_Table_GrabLandLord = {"Game.GrabLandLordReq", "GrabLandLordReq", "Game.GrabLandLordRet", "GrabLandLordRet", game_pb_name, game_pb_name}
--抢地主通知
NetMsgApi.msgName2MsgData.Msg_Table_GrabLandLord_Notify = {"", "", "Game.GrabLandLordNotify", "GrabLandLordNotify", game_pb_name, game_pb_name}
--开始抢地主通知
NetMsgApi.msgName2MsgData.Msg_Table_Start_GrabLandLord_Notify = {"", "", "Game.StartGrabLandNotify", "StartGrabLandNotify", game_pb_name, game_pb_name}
--开始抢地主结果通知
NetMsgApi.msgName2MsgData.Msg_Table_GrabLandLord_Result_Notify = {"", "", "Game.GrabResultNotify", "GrabResultNotify", game_pb_name, game_pb_name}

--出牌
NetMsgApi.msgName2MsgData.Msg_Table_Discard = {"Game.DiscardInfo", "DiscardInfo", "Game.DiscardReply", "DiscardReply", game_pb_name, game_pb_name}
--出牌通知
NetMsgApi.msgName2MsgData.Msg_Table_Discard_Notify = {"", "", "Game.DiscardNotify", "DiscardNotify", game_pb_name, game_pb_name}
--结算通知
NetMsgApi.msgName2MsgData.Msg_Table_CurrentAccount_Notify = {"", "", "Game.CurrentGameAccount", "CurrentGameAccount", game_pb_name, game_pb_name}
--同步包
NetMsgApi.msgName2MsgData.Msg_Table_GameInfo_Notify = {"", "", "Game.GameInfo", "GameInfo", game_pb_name, game_pb_name}

NetMsgApi.msgName2MsgData.Msg_Table_ShotSettle_Notify = {"", "", "Room.OneShotSettleNotify", "OneShotSettleNotify", "", "table.room_pb"}

--房主改变通知
NetMsgApi.msgName2MsgData.Msg_Table_OwnerChangeNotify = {"", "", "Game.OwnerChangeNotify", "OwnerChangeNotify", "", game_pb_name}
--取消准备通知
NetMsgApi.msgName2MsgData.Msg_Table_CancelReadyNotify = {"", "", "Game.CancelReadyNotify", "CancelReadyNotify", "", game_pb_name}
--亲友圈 快速组局 踢人倒计时
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerExpire_Notify = {"", "", "Game.KickPlayerExpire", "KickPlayerExpire", "", game_pb_name}

return NetMsgApi