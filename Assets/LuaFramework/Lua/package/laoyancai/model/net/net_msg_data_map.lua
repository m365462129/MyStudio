local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
NetMsgApi.path = "package.laoyancai.model.net.protol."

--单播 游戏信息 登录或者断线重连时发送
NetMsgApi.msgName2MsgData.Msg_Table_GameInfo = {"", "", "Game.GameInfo", "GameInfo", "", "table.game_pb"}
--广播 结算信息 一把打完发送
NetMsgApi.msgName2MsgData.Msg_Table_CurrentGameAccount = {"", "", "Game.CurrentGameAccount", "CurrentGameAccount", "", "table.game_pb"}
--开始抢庄通知
NetMsgApi.msgName2MsgData.Msg_Table_Start_Banker_Notify = {"", "", "Game.StartQiangZhuangNotify", "StartQiangZhuangNotify", "", "table.game_pb"}
--抢庄
NetMsgApi.msgName2MsgData.Msg_Table_Knock_Banker = {"Game.QiangZhuangReq", "QiangZhuangReq", "Game.QiangZhuangRet", "QiangZhuangRet", "table.game_pb", "table.game_pb"}
--抢庄通知
NetMsgApi.msgName2MsgData.Msg_Table_Knock_Banker_Notify = {"", "", "Game.QiangZhuangNotify", "QiangZhuangNotify", "", "table.game_pb"}
--定庄发牌通知（收到通知后发两张牌并开始选择下分）
NetMsgApi.msgName2MsgData.Msg_Table_Confirm_Banker_Notify = {"", "", "Game.FaPaiNotify", "FaPaiNotify", "", "table.game_pb"}
--下分
NetMsgApi.msgName2MsgData.Msg_Table_Chip_Off = {"Game.XiaFenReq", "XiaFenReq", "Game.XiaFenRet", "XiaFenRet", "table.game_pb", "table.game_pb"}
--下分通知
NetMsgApi.msgName2MsgData.Msg_Table_Chip_Off_Notify = {"", "", "Game.XiaFenNotify", "XiaFenNotify", "", "table.game_pb"}
--开始操作通知
NetMsgApi.msgName2MsgData.Msg_Table_Start_Operation_Notify= {"", "", "Game.StartOperationNotify", "StartOperationNotify", "", "table.game_pb"}
--操作
NetMsgApi.msgName2MsgData.Msg_Table_Operation = {"Game.OperationReq", "OperationReq", "Game.OperationRet", "OperationRet", "table.game_pb", "table.game_pb"}
--操作通知
NetMsgApi.msgName2MsgData.Msg_Table_Operation_Notify= {"", "", "Game.OperationNotify", "OperationNotify", "", "table.game_pb"}
--比牌通知
NetMsgApi.msgName2MsgData.Msg_Table_Compare_Notify= {"", "", "Game.CompareNotify", "CompareNotify", "", "table.game_pb"}
--查看其它玩家牌请求，只有轮到庄家操作时才可以看闲家的牌
NetMsgApi.msgName2MsgData.Msg_Table_View_Card= {"Game.ViewcardReq", "ViewcardReq", "Game.ViewcardRet", "ViewcardRet", "table.game_pb", "table.game_pb"}
--轮庄
NetMsgApi.msgName2MsgData.Msg_Table_Queue_Banker= {"Game.QueueZhuangReq", "QueueZhuangReq", "Game.QueueZhuangRet", "QueueZhuangRet", "table.game_pb", "table.game_pb"}
--轮庄通知
NetMsgApi.msgName2MsgData.Msg_Table_Queue_Banker_Notify= {"", "", "Game.QueueZhuangNotify", "QueueZhuangNotify", "", "table.game_pb"}

return NetMsgApi