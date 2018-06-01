local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
NetMsgApi.msgName2MsgData = {}
setmetatable(NetMsgApi.msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.path = "package.guandan.model.net.protol."

--上贡
NetMsgApi.msgName2MsgData.Msg_Table_Tribute = {"Game.TributeReq", "TributeReq", "Game.TributeReply", "TributeReply", "table.game_guandan_pb", "table.game_guandan_pb"}
--上贡通知
NetMsgApi.msgName2MsgData.Msg_Table_Tribute_Notify = {"", "", "Game.TributeNotify", "TributeNotify", "", "table.game_guandan_pb"}
--上贡结果通知
NetMsgApi.msgName2MsgData.Msg_Table_Tribute_Result_Notify = {"", "", "Game.TributeSummary", "TributeSummary", "", "table.game_guandan_pb"}
--出牌
NetMsgApi.msgName2MsgData.Msg_Table_Discard = {"Game.DiscardInfo", "DiscardInfo", "Game.DiscardReply", "DiscardReply", "table.game_guandan_pb", "table.game_guandan_pb"}
--出牌通知
NetMsgApi.msgName2MsgData.Msg_Table_Discard_Notify = {"", "", "Game.DiscardNotify", "DiscardNotify", "", "table.game_guandan_pb"}
--结算通知
NetMsgApi.msgName2MsgData.Msg_Table_CurrentAccount_Notify = {"", "", "Game.CurrentGameAccount", "CurrentGameAccount", "", "table.game_guandan_pb"}
--同步包
NetMsgApi.msgName2MsgData.Msg_Table_GameInfo_Notify = {"", "", "Game.GameInfo", "GameInfo", "", "table.game_guandan_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerExpire = {"", "", "Room.KickPlayerExpire", "KickPlayerExpire", "", "table.room_pb"}

return NetMsgApi