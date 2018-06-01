local AppData = AppData
local BranchPackageName = AppData.BranchZhaJinHuaName
local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, { __index = baseNetMsgApi });
local msgName2MsgData = {}
setmetatable(msgName2MsgData, { __index = baseNetMsgApi.msgName2MsgData });
NetMsgApi.msgName2MsgData = msgName2MsgData

-- 此处必须与路径一致AppData.BranchZhaJinHuaName
NetMsgApi.path = "package.zhajinhua.model.net.protol."
print("炸金花====protol")

NetMsgApi.msgName2MsgData.Msg_Table_Bet = { "Game.BetReq", "BetReq", "Game.BetRsp", "BetRsp", "table.game_pb", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_ComputePoker = { "Game.ComputePokerReq", "ComputePokerReq", "Game.ComputePokerRsp", "ComputePokerRsp", "table.game_pb", "table.game_pb" }

NetMsgApi.msgName2MsgData.Msg_Table_Deal_Poker = { "Game.DealPokerReq", "DealPokerReq", "Game.DealPokerRsp", "DealPokerRsp", "table.game_pb", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_Deal_Poker_Notify = { "", "", "Game.DealPokerBroadcast", "DealPokerBroadcast", "", "table.game_pb" }

NetMsgApi.msgName2MsgData.Msg_Table_SynExpire_Notify = { "", "", "Room.SynExpireBroadcast", "SynExpireBroadcast", "", "table.room_pb" }

NetMsgApi.msgName2MsgData.Msg_Table_Synchronize_Notify = { "", "", "Room.SynchronizeBroadcast", "SynchronizeBroadcast", "", "table.room_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_Bet_Notify = { "", "", "Game.BetBroadcast", "BetBroadcast", "", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_SetBanker_Notify = { "", "", "Game.SetBankerBroadcast", "SetBankerBroadcast", "", "table.game_pb" }                               --设定庄家通知
NetMsgApi.msgName2MsgData.Msg_Table_ComputePoker_Notify = { "", "", "Game.ComputePokerBroadcast", "ComputePokerBroadcast", "", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_AgoSettleAccounts_Notify = { "", "", "Game.AgoSettleAccountsBroadcast", "AgoSettleAccountsBroadcast", "", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_SettleAccounts_Notify = { "", "", "Game.SettleAccountsBroadcast", "SettleAccountsBroadcast", "", "table.game_pb" }                --单局结算
NetMsgApi.msgName2MsgData.Msg_Table_LastSettleAccounts_Notify = { "", "", "Game.LastSettleAccountsBroadcast", "LastSettleAccountsBroadcast", "", "table.game_pb" }    --房间结算

NetMsgApi.msgName2MsgData.Msg_Table_ScrambleBanker = { "Game.ScrambleBankerReq", "ScrambleBankerReq", "Game.ScrambleBankerRsp", "ScrambleBankerRsp", "table.game_pb", "table.game_pb" }    --房间结算
NetMsgApi.msgName2MsgData.Msg_Table_ScrambleBanker_Notify = { "", "", "Game.ScrambleBankerBroadcast", "ScrambleBankerBroadcast", "", "table.game_pb" }    --房间结算


NetMsgApi.msgName2MsgData.Msg_Table_TemporaryLeave = { "Game.TemporaryLeaveReq", "TemporaryLeaveReq", "Game.TemporaryLeaveRsp", "TemporaryLeaveRsp", "table.game_pb", "table.game_pb" }    --暂时离开
NetMsgApi.msgName2MsgData.Msg_Table_TemporaryLeave_Notify = { "", "", "Game.TemporaryLeaveBroadcast", "TemporaryLeaveBroadcast", "", "table.game_pb" }    --暂时离开广播

--炸金牛同步广播
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_Sync_Notify = { "", "", "Room.ZhaJinNiuSynchronizeBroadcast", "ZhaJinNiuSynchronizeBroadcast", "", "table.room_pb" }
--等待玩家说话广播
NetMsgApi.msgName2MsgData.Msg_Table_WaitSpeak_Notify = { "", "", "Game.WaitSpeakBroadcast", "WaitSpeakBroadcast", "", "table.game_pb" }
--弃牌
NetMsgApi.msgName2MsgData.Msg_Table_DropPokers = { "Game.DropPokersReq", "DropPokersReq", "Game.DropPokersRsp", "DropPokersRsp", "table.game_pb", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_DropPokers_Notify = { "", "", "Game.DropPokersBroadcast", "DropPokersBroadcast", "", "table.game_pb" }
--看牌
NetMsgApi.msgName2MsgData.Msg_Table_CheckPokers = { "Game.CheckPokersReq", "CheckPokersReq", "Game.CheckPokersRsp", "CheckPokersRsp", "table.game_pb", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_CheckPokers_Notify = { "", "", "Game.CheckPokersBroadcast", "CheckPokersBroadcast", "", "table.game_pb" }
--比牌
NetMsgApi.msgName2MsgData.Msg_Table_ComparePokers = { "Game.ComparePokersReq", "ComparePokersReq", "Game.ComparePokersRsp", "ComparePokersRsp", "table.game_pb", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_ComparePokers_Notify = { "", "", "Game.ComparePokersBroadcast", "ComparePokersBroadcast", "", "table.game_pb" }
--跟注
NetMsgApi.msgName2MsgData.Msg_Table_CallBet = { "Game.CallBetReq", "CallBetReq", "Game.CallBetRsp", "CallBetRsp", "table.game_pb", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_CallBet_Notify = { "", "", "Game.CallBetBroadcast", "CallBetBroadcast", "", "table.game_pb" }
--结算
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_AgoSettleAccounts_Notify = { "", "", "Game.ZhaJinNiu_AgoSettleAccountsBroadcast", "ZhaJinNiu_AgoSettleAccountsBroadcast", "", "table.game_pb" }
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_SettleAccounts_Notify = { "", "", "Game.ZhaJinNiu_SettleAccountsBroadcast", "ZhaJinNiu_SettleAccountsBroadcast", "", "table.game_pb" }                --单局结算
--比牌失败广播
NetMsgApi.msgName2MsgData.Msg_Table_ZhaJinNiu_CompareFail_Notify = { "", "", "Game.ComparePokersFailBroadcast", "ComparePokersFailBroadcast", "", "table.game_pb" }                --单局结算




---------------------------------------炸金花新的 start----------------------------------------------------------------
--游戏信息 登录或者断线重连时发送
NetMsgApi.msgName2MsgData.Msg_Table_GameInfo = { "", "", "Game.GameInfo", "GameInfo", "", "mytable.game_pb" }
--扣除底注发牌通知
NetMsgApi.msgName2MsgData.Msg_Table_DeductNotify = { "", "", "Game.DeductNotify", "DeductNotify", "", "mytable.game_pb" }
--开始操作通知
NetMsgApi.msgName2MsgData.Msg_Table_StartOperationNotify = { "", "", "Game.StartOperationNotify", "StartOperationNotify", "", "mytable.game_pb" }
--操作请求
NetMsgApi.msgName2MsgData.Msg_Table_OperationReq = { "Game.OperationReq", "OperationReq", "", "", "mytable.game_pb", "" }
--操作回复
NetMsgApi.msgName2MsgData.Msg_Table_OperationRet = { "", "", "Game.OperationRet", "OperationRet", "", "mytable.game_pb" }
--操作通知
NetMsgApi.msgName2MsgData.Msg_Table_OperationNotify = { "", "", "Game.OperationNotify", "OperationNotify", "", "mytable.game_pb" }
--比牌玩家列表请求
NetMsgApi.msgName2MsgData.Msg_Table_CompareListReq = { "Game.CompareListReq", "CompareListReq", "", "", "mytable.game_pb", "" }
--比牌玩家列表返回
NetMsgApi.msgName2MsgData.Msg_Table_CompareListRet = { "", "", "Game.CompareListRet", "CompareListRet", "", "mytable.game_pb" }
--封顶轮数比牌通知
NetMsgApi.msgName2MsgData.Msg_Table_MaxCircleNotify = { "", "", "Game.MaxCircleNotify", "MaxCircleNotify", "", "mytable.game_pb" }
--广播 结算信息 一把打玩发送
NetMsgApi.msgName2MsgData.Msg_Table_CurrentGameAccount = { "", "", "Game.CurrentGameAccount", "CurrentGameAccount", "", "mytable.game_pb" }
--即使结算通知
NetMsgApi.msgName2MsgData.Msg_Table_OneShotSettleNotify = { "", "", "Game.OneShotSettleNotify", "OneShotSettleNotify", "", "mytable.game_pb" }
--托管请求
NetMsgApi.msgName2MsgData.Msg_Table_IntrustReq = { "Room.IntrustReq", "IntrustReq", "", "", "mytable.room_pb", "" }
--托管回应
NetMsgApi.msgName2MsgData.Msg_Table_IntrustRsp = { "", "", "Room.IntrustRsp", "IntrustRsp", "", "mytable.room_pb" }
--托管通知
NetMsgApi.msgName2MsgData.Msg_Table_IntrustNotify = { "", "", "Room.IntrustNotify", "IntrustNotify", "", "mytable.room_pb" }
--踢人请求
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerReq = { "Room.KickPlayerReq", "KickPlayerReq", "", "", "mytable.room_pb", "" }
--踢人回馈
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerRsp = { "", "", "Room.KickPlayerRsp", "KickPlayerRsp", "", "mytable.room_pb" }
--踢人广播
NetMsgApi.msgName2MsgData.Msg_Table_KickPlayerBroadcast = { "", "", "Room.KickPlayerBroadcast", "KickPlayerBroadcast", "", "mytable.room_pb" }
--金币不足通知
NetMsgApi.msgName2MsgData.Msg_Table_GoldNotEnoughNotify = { "", "", "Game.GoldNotEnoughNotify", "GoldNotEnoughNotify", "", "mytable.game_pb" }
--请求更新余额
NetMsgApi.msgName2MsgData.Msg_Table_UserCoinBalanceReq = { "Room.UserCoinBalanceReq", "UserCoinBalanceReq", "", "", "mytable.room_pb", "" }
--请求补充金币
NetMsgApi.msgName2MsgData.Msg_Table_UserRechargeReq = { "Game.RechargeRet", "RechargeRet", "", "", "mytable.game_pb", "" }
--补充金币通知
NetMsgApi.msgName2MsgData.Msg_Table_UserRechargeNotify = { "", "", "Game.RechargeNotify", "RechargeNotify", "", "mytable.game_pb" }
--血拼比牌通知
NetMsgApi.msgName2MsgData.Msg_Table_AllInCompareNotify = { "", "", "Game.AllInCompareNotify", "AllInCompareNotify", "", "mytable.game_pb" }

--房主改变通知
NetMsgApi.msgName2MsgData.Msg_Table_OwnerChangeNotify = {"", "", "Game.OwnerChangeNotify", "OwnerChangeNotify", "", "mytable.game_pb"}
--取消准备通知
NetMsgApi.msgName2MsgData.Msg_Table_CancelReadyNotify = {"", "", "Game.CancelReadyNotify", "CancelReadyNotify", "", "mytable.game_pb"}
---------------------------------------炸金花新的 end------------------------------------------------------------------

return NetMsgApi


