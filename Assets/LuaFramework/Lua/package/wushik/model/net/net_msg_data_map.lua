local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
NetMsgApi.msgName2MsgData = {}
setmetatable(NetMsgApi.msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.path = "package.wushik.model.net.protol."

local game_pb_name = "game_pb"
----明牌
--NetMsgApi.msgName2MsgData.Msg_Table_Show_Cards = {"Game.ShowCardReq", "ShowCardReq", "Game.ShowCardReply", "ShowCardReply", game_pb_name, game_pb_name}
----明牌通知
--NetMsgApi.msgName2MsgData.Msg_Table_Show_Cards_Notify = {"", "", "Game.ShowCardNotify", "ShowCardNotify", game_pb_name, game_pb_name}
----叫狗腿
--NetMsgApi.msgName2MsgData.Msg_Table_CallServant = {"Game.CallServantReq", "CallServantReq", "Game.CallServantReply", "CallServantReply", game_pb_name, game_pb_name}
----叫狗腿通知
--NetMsgApi.msgName2MsgData.Msg_Table_CallServant_Notify = {"", "", "Game.CallServantNotify", "CallServantNotify", game_pb_name, game_pb_name}
----重新发牌
--NetMsgApi.msgName2MsgData.Msg_Table_RedealCard = {"Game.RedealCardReq", "RedealCardReq", "Game.RedealCardReply", "RedealCardReply", game_pb_name, game_pb_name}
----重新发牌通知
--NetMsgApi.msgName2MsgData.Msg_Table_RedealCard_Notify = {"", "", "Game.RedealCardNotify", "RedealCardNotify", game_pb_name, game_pb_name}

--同步包
NetMsgApi.msgName2MsgData.Msg_Table_GameInfo_Notify = {"", "", "Game.GameInfo", "GameInfo", game_pb_name, game_pb_name}
--独牌
NetMsgApi.msgName2MsgData.Msg_Table_FightAlone = {"Game.FightAloneReq", "FightAloneReq", "Game.FightAloneRsp", "FightAloneRsp", game_pb_name, game_pb_name}
--独牌
NetMsgApi.msgName2MsgData.Msg_Table_FightAlone_Notify = {"", "", "Game.FightAloneNotify", "FightAloneNotify", game_pb_name, game_pb_name}
--出牌
NetMsgApi.msgName2MsgData.Msg_Table_Discard = {"Game.DiscardReq", "DiscardReq", "Game.DiscardRsp", "DiscardRsp", game_pb_name, game_pb_name}
--出牌通知
NetMsgApi.msgName2MsgData.Msg_Table_Discard_Notify = {"", "", "Game.DiscardNotify", "DiscardNotify", game_pb_name, game_pb_name}
--捡分通知
NetMsgApi.msgName2MsgData.Msg_Table_PointsPicked_Notify = {"", "", "Game.PointsPickedNotify", "PointsPickedNotify", game_pb_name, game_pb_name}
--结算通知
NetMsgApi.msgName2MsgData.Msg_Table_CurrentAccount_Notify = {"", "", "Game.SettleInfo", "SettleInfo", game_pb_name, game_pb_name}
return NetMsgApi