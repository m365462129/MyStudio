--- 三公通信协议ID定义
--- Created by a.
--- DateTime: 2017/11/20 10:24
---
local require = require
local class = require("lib.middleclass")
local baseNetMsgApi = require("package.public.model.net.net_msg_data_base"):new()
local NetMsgApi = {}
setmetatable(NetMsgApi, {__index = baseNetMsgApi});
NetMsgApi.msgName2MsgData = {}
setmetatable(NetMsgApi.msgName2MsgData, {__index = baseNetMsgApi.msgName2MsgData});
NetMsgApi.path = "package.sangong.model.net.protol."

local game_pb_name = "table.game_pb"

---下注
NetMsgApi.msgName2MsgData.Msg_Table_Stake =
{
    "Game.StakeReq","StakeReq","Game.StakeReply","StakeReply",
    game_pb_name,game_pb_name
}
---下注通知
NetMsgApi.msgName2MsgData.Msg_Table_Stake_Notify =
{
    "","","Game.StakeNotify","StakeNotify",
    game_pb_name,game_pb_name
}
---抢庄
NetMsgApi.msgName2MsgData.Msg_Table_Banker =
{
    "Game.BankerReq","BankerReq","Game.BankerReply","BankerReply",
    game_pb_name,game_pb_name
}
---抢庄通知
NetMsgApi.msgName2MsgData.Msg_Table_Banker_Notify =
{
    "","","Game.BankerNotify","BankerNotify",
    game_pb_name,game_pb_name
}
---抢庄结果通知
NetMsgApi.msgName2MsgData.Msg_Table_BankerResult_Notify =
{
    "","","Game.BankerResultNotify","BankerResultNotify",
    game_pb_name,game_pb_name
}
---亮牌
NetMsgApi.msgName2MsgData.Msg_Table_Show_Card =
{
    "Game.ShowCardReq","ShowCardReq","Game.ShowCardReply","ShowCardReply",
    game_pb_name,game_pb_name
}
---手牌通知 所有人开牌后、下注后都会广播
NetMsgApi.msgName2MsgData.Msg_Table_Handcard_Notify =
{
    "","","Game.HandcardNotify","HandcardNotify",
    game_pb_name,game_pb_name
}
---单播 游戏信息 登录或者断线重连时发送
NetMsgApi.msgName2MsgData.Msg_Table_GameInfo =
{
    "","","Game.GameInfo","GameInfo",
    game_pb_name,game_pb_name
}
---广播 结算信息 一把打玩发送
NetMsgApi.msgName2MsgData.Msg_Table_CurrentGameAccount =
{
    "","","Game.CurrentGameAccount","CurrentGameAccount",
    game_pb_name,game_pb_name
}

---超时通知
NetMsgApi.msgName2MsgData.Msg_Table_TimeoutNotify =
{
    "","","Game.TimeoutNotify","TimeoutNotify",
    game_pb_name,game_pb_name
}

---取牌请求
NetMsgApi.msgName2MsgData.Msg_Table_GetCard =
{
    "Game.GetCardReq","GetCardReq","Game.GetCardReply","GetCardReply",
    game_pb_name,game_pb_name
}

---亮牌广播
NetMsgApi.msgName2MsgData.Msg_Table_ShowCardNotify =
{
    "","","Game.ShowCardNotify","ShowCardNotify",
    game_pb_name,game_pb_name
}

---房主变更广播消息
NetMsgApi.msgName2MsgData.Msg_Table_RoomOwnerChangeMsg =
{
    "","","Game.RoomOwnerChangeMsg","RoomOwnerChangeMsg",
    game_pb_name,game_pb_name
}

return NetMsgApi

