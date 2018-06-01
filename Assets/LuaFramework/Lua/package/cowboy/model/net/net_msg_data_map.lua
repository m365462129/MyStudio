local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
local msgName2MsgData = {}
setmetatable(msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.msgName2MsgData = msgName2MsgData

-- 此处必须与路径一致
NetMsgApi.path = "package.cowboy.model.net.protol."


NetMsgApi.msgName2MsgData.Msg_Table_Bet = {"Game.BetReq", "BetReq", "Game.BetRsp", "BetRsp", "table.game_pb", "table.game_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_ComputePoker = {"Game.ComputePokerReq", "ComputePokerReq", "Game.ComputePokerRsp", "ComputePokerRsp", "table.game_pb", "table.game_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_Deal_Poker = {"Game.DealPokerReq", "DealPokerReq", "Game.DealPokerRsp", "DealPokerRsp", "table.game_pb", "table.game_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Deal_Poker_Notify = {"", "", "Game.DealPokerBroadcast", "DealPokerBroadcast", "", "table.game_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_SynExpire_Notify = {"", "", "Room.SynExpireBroadcast", "SynExpireBroadcast", "", "table.room_pb"}

NetMsgApi.msgName2MsgData.Msg_Table_Synchronize_Notify = {"", "", "Room.SynchronizeBroadcast", "SynchronizeBroadcast", "", "table.room_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_Bet_Notify = {"", "", "Game.BetBroadcast", "BetBroadcast", "", "table.game_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_SetBanker_Notify = {"", "", "Game.SetBankerBroadcast", "SetBankerBroadcast", "", "table.game_pb"}                               --设定庄家通知
NetMsgApi.msgName2MsgData.Msg_Table_ComputePoker_Notify = {"", "", "Game.ComputePokerBroadcast", "ComputePokerBroadcast", "", "table.game_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_AgoSettleAccounts_Notify = {"", "", "Game.AgoSettleAccountsBroadcast", "AgoSettleAccountsBroadcast", "", "table.game_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_SettleAccounts_Notify = {"", "", "Game.SettleAccountsBroadcast", "SettleAccountsBroadcast", "", "table.game_pb"}                --单局结算
NetMsgApi.msgName2MsgData.Msg_Table_LastSettleAccounts_Notify = {"", "", "Game.LastSettleAccountsBroadcast", "LastSettleAccountsBroadcast", "", "table.game_pb"}    --房间结算

NetMsgApi.msgName2MsgData.Msg_Table_ScrambleBanker = {"Game.ScrambleBankerReq", "ScrambleBankerReq", "Game.ScrambleBankerRsp", "ScrambleBankerRsp", "table.game_pb", "table.game_pb"}    --房间结算
NetMsgApi.msgName2MsgData.Msg_Table_ScrambleBanker_Notify = {"", "", "Game.ScrambleBankerBroadcast", "ScrambleBankerBroadcast", "", "table.game_pb"}    --房间结算


NetMsgApi.msgName2MsgData.Msg_Table_TemporaryLeave = {"Game.TemporaryLeaveReq", "TemporaryLeaveReq", "Game.TemporaryLeaveRsp", "TemporaryLeaveRsp", "table.game_pb", "table.game_pb"}    --暂时离开
NetMsgApi.msgName2MsgData.Msg_Table_TemporaryLeave_Notify = {"", "", "Game.TemporaryLeaveBroadcast", "TemporaryLeaveBroadcast", "", "table.game_pb"}    --暂时离开广播

--炸金牛同步广播
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_Sync_Notify = {"", "", "Room.ZhaJinNiuSynchronizeBroadcast", "ZhaJinNiuSynchronizeBroadcast", "", "table.room_pb"} 
--等待玩家说话广播
NetMsgApi.msgName2MsgData.Msg_Table_WaitSpeak_Notify = {"", "", "Game.WaitSpeakBroadcast", "WaitSpeakBroadcast", "", "table.game_pb"} 
--弃牌
NetMsgApi.msgName2MsgData.Msg_Table_DropPokers = {"Game.DropPokersReq", "DropPokersReq", "Game.DropPokersRsp", "DropPokersRsp", "table.game_pb", "table.game_pb"} 
NetMsgApi.msgName2MsgData.Msg_Table_DropPokers_Notify = {"", "", "Game.DropPokersBroadcast", "DropPokersBroadcast", "", "table.game_pb"} 
--看牌
NetMsgApi.msgName2MsgData.Msg_Table_CheckPokers = {"Game.CheckPokersReq", "CheckPokersReq", "Game.CheckPokersRsp", "CheckPokersRsp", "table.game_pb", "table.game_pb"} 
NetMsgApi.msgName2MsgData.Msg_Table_CheckPokers_Notify = {"", "", "Game.CheckPokersBroadcast", "CheckPokersBroadcast", "", "table.game_pb"} 
--比牌
NetMsgApi.msgName2MsgData.Msg_Table_ComparePokers = {"Game.ComparePokersReq", "ComparePokersReq", "Game.ComparePokersRsp", "ComparePokersRsp", "table.game_pb", "table.game_pb"} 
NetMsgApi.msgName2MsgData.Msg_Table_ComparePokers_Notify = {"", "", "Game.ComparePokersBroadcast", "ComparePokersBroadcast", "", "table.game_pb"} 
--跟注
NetMsgApi.msgName2MsgData.Msg_Table_CallBet = {"Game.CallBetReq", "CallBetReq", "Game.CallBetRsp", "CallBetRsp", "table.game_pb", "table.game_pb"} 
NetMsgApi.msgName2MsgData.Msg_Table_CallBet_Notify = {"", "", "Game.CallBetBroadcast", "CallBetBroadcast", "", "table.game_pb"} 
--结算
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_AgoSettleAccounts_Notify = {"", "", "Game.ZhaJinNiu_AgoSettleAccountsBroadcast", "ZhaJinNiu_AgoSettleAccountsBroadcast", "", "table.game_pb"}
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_SettleAccounts_Notify = {"", "", "Game.ZhaJinNiu_SettleAccountsBroadcast", "ZhaJinNiu_SettleAccountsBroadcast", "", "table.game_pb"}                --单局结算
--比牌失败广播
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_CompareFail_Notify = {"", "", "Game.ComparePokersFailBroadcast", "ComparePokersFailBroadcast", "", "table.game_pb"}                --单局结算

--亲友圈 快速组局踢人倒计时
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerExpire = {"", "", "Room.KickPlayerExpire", "KickPlayerExpire", "", "table.room_pb"}
--亲友圈 快速组局 房主易位
NetMsgApi.msgName2MsgData.Msg_Table_OwnerChangeBroadcast_Notify = {"", "", "Room.OwnerChangeBroadcast", "OwnerChangeBroadcast", "", "table.room_pb"}

--踢人请求
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerReq = {"Room.KickPlayerReq", "KickPlayerReq", "", "", "table.room_pb", ""}

-- 监听踢人响应
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerBroadcast = {"", "", "Room.KickPlayerBroadcast", "KickPlayerBroadcast", "", "table.room_pb"}

-- 开始游戏
NetMsgApi.msgName2MsgData.Msg_Table_Start_Notify = {"", "", "Room.StartBroadcast", "StartBroadcast", "", "table.room_pb"}

return NetMsgApi


