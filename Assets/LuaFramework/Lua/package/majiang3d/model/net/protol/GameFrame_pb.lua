--Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
module('package.majiang.model.net.protol.GameFrame_pb')

CMD_HEARTBEAT = protobuf.Descriptor();
RSP_HEARTBEAT = protobuf.Descriptor();
CMD_LOGINSERVER = protobuf.Descriptor();
CMD_LOGINSERVER_PASSWORD_FIELD = protobuf.FieldDescriptor();
CMD_LOGINSERVER_ROOMID_FIELD = protobuf.FieldDescriptor();
CMD_LOGINSERVER_SEATID_FIELD = protobuf.FieldDescriptor();
CMD_LOGINSERVER_APPENDDATA_FIELD = protobuf.FieldDescriptor();
CMD_LOGINSERVER_PROTOVERSION_FIELD = protobuf.FieldDescriptor();
CMD_LOGINSERVER_CLIENTVERSION_FIELD = protobuf.FieldDescriptor();
RSP_LOGINSERVER = protobuf.Descriptor();
RSP_LOGINSERVER_ERROR_FIELD = protobuf.FieldDescriptor();
RSP_LOGINSERVER_CHATROOM_FIELD = protobuf.FieldDescriptor();
RSP_LOGINSERVER_ERRINFO_FIELD = protobuf.FieldDescriptor();
CMD_EXITROOM = protobuf.Descriptor();
RSP_EXITROOM = protobuf.Descriptor();
RSP_EXITROOM_ERROR_FIELD = protobuf.FieldDescriptor();
CMD_MESSAGE = protobuf.Descriptor();
CMD_MESSAGE_MESSAGE_FIELD = protobuf.FieldDescriptor();
CMD_MESSAGE_APPENDDATA_FIELD = protobuf.FieldDescriptor();
CMD_QUERYDATA = protobuf.Descriptor();
CMD_QUERYDATA_PASSWORD_FIELD = protobuf.FieldDescriptor();
CMD_QUERYDATA_QUERYID_FIELD = protobuf.FieldDescriptor();
RSP_QUERYDATA = protobuf.Descriptor();
RSP_QUERYDATA_ERROR_FIELD = protobuf.FieldDescriptor();
CMD_DISMISS = protobuf.Descriptor();
CMD_DISMISS_ACTION_FIELD = protobuf.FieldDescriptor();
CMD_KICKUSER = protobuf.Descriptor();
CMD_KICKUSER_USERID_FIELD = protobuf.FieldDescriptor();
CMD_PRIVATE_MESSAGE = protobuf.Descriptor();
CMD_PRIVATE_MESSAGE_SEATID_FIELD = protobuf.FieldDescriptor();
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD = protobuf.FieldDescriptor();
CMD_REPORTSTATE = protobuf.Descriptor();
CMD_REPORTSTATE_STATE_FIELD = protobuf.FieldDescriptor();
CMD_GET_KICKED_TIMEOUT = protobuf.Descriptor();
NTF_ROOMUSERINFO = protobuf.Descriptor();
NTF_ROOMUSERINFO_SEATID_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSERINFO_USERID_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSERINFO_APPENDDATA_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSERINFO_STATE_FIELD = protobuf.FieldDescriptor();
NTF_SAMEUSERLOGIN = protobuf.Descriptor();
NTF_SAMEUSERLOGIN_IP_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSERONLINE = protobuf.Descriptor();
NTF_ROOMUSERONLINE_SEATID_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSERONLINE_IP_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSERONLINE_APPENDDATA_FIELD = protobuf.FieldDescriptor();
NTF_ROOMUSEROFFLINE = protobuf.Descriptor();
NTF_ROOMUSEROFFLINE_SEATID_FIELD = protobuf.FieldDescriptor();
NTF_ROOMDISMISSED = protobuf.Descriptor();
NTF_MESSAGE = protobuf.Descriptor();
NTF_MESSAGE_SEATID_FIELD = protobuf.FieldDescriptor();
NTF_MESSAGE_MESSAGE_FIELD = protobuf.FieldDescriptor();
NTF_DISMISS = protobuf.Descriptor();
NTF_DISMISS_ACTION_FIELD = protobuf.FieldDescriptor();
NTF_DISMISS_TIME_FIELD = protobuf.FieldDescriptor();
NTF_KICKED = protobuf.Descriptor();
NTF_PRIVATE_MESSAGE = protobuf.Descriptor();
NTF_PRIVATE_MESSAGE_SEATID_FIELD = protobuf.FieldDescriptor();
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD = protobuf.FieldDescriptor();
NTF_REPORTSTATE = protobuf.Descriptor();
NTF_REPORTSTATE_SEATID_FIELD = protobuf.FieldDescriptor();
NTF_REPORTSTATE_STATE_FIELD = protobuf.FieldDescriptor();
NTF_RETURN_KICKED_TIMEOUT = protobuf.Descriptor();
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD = protobuf.FieldDescriptor();
NTF_ROOMAWARDMESSAGE = protobuf.Descriptor();
NTF_ROOMAWARDMESSAGE_USERID_FIELD = protobuf.FieldDescriptor();
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD = protobuf.FieldDescriptor();

CMD_HEARTBEAT.name = "CMD_HeartBeat"
CMD_HEARTBEAT.full_name = ".CMD_HeartBeat"
CMD_HEARTBEAT.nested_types = {}
CMD_HEARTBEAT.enum_types = {}
CMD_HEARTBEAT.fields = {}
CMD_HEARTBEAT.is_extendable = false
CMD_HEARTBEAT.extensions = {}
RSP_HEARTBEAT.name = "RSP_HeartBeat"
RSP_HEARTBEAT.full_name = ".RSP_HeartBeat"
RSP_HEARTBEAT.nested_types = {}
RSP_HEARTBEAT.enum_types = {}
RSP_HEARTBEAT.fields = {}
RSP_HEARTBEAT.is_extendable = false
RSP_HEARTBEAT.extensions = {}
CMD_LOGINSERVER_PASSWORD_FIELD.name = "Password"
CMD_LOGINSERVER_PASSWORD_FIELD.full_name = ".CMD_LoginServer.Password"
CMD_LOGINSERVER_PASSWORD_FIELD.number = 1
CMD_LOGINSERVER_PASSWORD_FIELD.index = 0
CMD_LOGINSERVER_PASSWORD_FIELD.label = 1
CMD_LOGINSERVER_PASSWORD_FIELD.has_default_value = false
CMD_LOGINSERVER_PASSWORD_FIELD.default_value = ""
CMD_LOGINSERVER_PASSWORD_FIELD.type = 9
CMD_LOGINSERVER_PASSWORD_FIELD.cpp_type = 9

CMD_LOGINSERVER_ROOMID_FIELD.name = "RoomID"
CMD_LOGINSERVER_ROOMID_FIELD.full_name = ".CMD_LoginServer.RoomID"
CMD_LOGINSERVER_ROOMID_FIELD.number = 2
CMD_LOGINSERVER_ROOMID_FIELD.index = 1
CMD_LOGINSERVER_ROOMID_FIELD.label = 1
CMD_LOGINSERVER_ROOMID_FIELD.has_default_value = false
CMD_LOGINSERVER_ROOMID_FIELD.default_value = 0
CMD_LOGINSERVER_ROOMID_FIELD.type = 13
CMD_LOGINSERVER_ROOMID_FIELD.cpp_type = 3

CMD_LOGINSERVER_SEATID_FIELD.name = "SeatID"
CMD_LOGINSERVER_SEATID_FIELD.full_name = ".CMD_LoginServer.SeatID"
CMD_LOGINSERVER_SEATID_FIELD.number = 3
CMD_LOGINSERVER_SEATID_FIELD.index = 2
CMD_LOGINSERVER_SEATID_FIELD.label = 1
CMD_LOGINSERVER_SEATID_FIELD.has_default_value = false
CMD_LOGINSERVER_SEATID_FIELD.default_value = 0
CMD_LOGINSERVER_SEATID_FIELD.type = 13
CMD_LOGINSERVER_SEATID_FIELD.cpp_type = 3

CMD_LOGINSERVER_APPENDDATA_FIELD.name = "AppendData"
CMD_LOGINSERVER_APPENDDATA_FIELD.full_name = ".CMD_LoginServer.AppendData"
CMD_LOGINSERVER_APPENDDATA_FIELD.number = 4
CMD_LOGINSERVER_APPENDDATA_FIELD.index = 3
CMD_LOGINSERVER_APPENDDATA_FIELD.label = 1
CMD_LOGINSERVER_APPENDDATA_FIELD.has_default_value = false
CMD_LOGINSERVER_APPENDDATA_FIELD.default_value = ""
CMD_LOGINSERVER_APPENDDATA_FIELD.type = 9
CMD_LOGINSERVER_APPENDDATA_FIELD.cpp_type = 9

CMD_LOGINSERVER_PROTOVERSION_FIELD.name = "ProtoVersion"
CMD_LOGINSERVER_PROTOVERSION_FIELD.full_name = ".CMD_LoginServer.ProtoVersion"
CMD_LOGINSERVER_PROTOVERSION_FIELD.number = 5
CMD_LOGINSERVER_PROTOVERSION_FIELD.index = 4
CMD_LOGINSERVER_PROTOVERSION_FIELD.label = 1
CMD_LOGINSERVER_PROTOVERSION_FIELD.has_default_value = false
CMD_LOGINSERVER_PROTOVERSION_FIELD.default_value = 0
CMD_LOGINSERVER_PROTOVERSION_FIELD.type = 13
CMD_LOGINSERVER_PROTOVERSION_FIELD.cpp_type = 3

CMD_LOGINSERVER_CLIENTVERSION_FIELD.name = "ClientVersion"
CMD_LOGINSERVER_CLIENTVERSION_FIELD.full_name = ".CMD_LoginServer.ClientVersion"
CMD_LOGINSERVER_CLIENTVERSION_FIELD.number = 6
CMD_LOGINSERVER_CLIENTVERSION_FIELD.index = 5
CMD_LOGINSERVER_CLIENTVERSION_FIELD.label = 1
CMD_LOGINSERVER_CLIENTVERSION_FIELD.has_default_value = false
CMD_LOGINSERVER_CLIENTVERSION_FIELD.default_value = ""
CMD_LOGINSERVER_CLIENTVERSION_FIELD.type = 9
CMD_LOGINSERVER_CLIENTVERSION_FIELD.cpp_type = 9

CMD_LOGINSERVER.name = "CMD_LoginServer"
CMD_LOGINSERVER.full_name = ".CMD_LoginServer"
CMD_LOGINSERVER.nested_types = {}
CMD_LOGINSERVER.enum_types = {}
CMD_LOGINSERVER.fields = {CMD_LOGINSERVER_PASSWORD_FIELD, CMD_LOGINSERVER_ROOMID_FIELD, CMD_LOGINSERVER_SEATID_FIELD, CMD_LOGINSERVER_APPENDDATA_FIELD, CMD_LOGINSERVER_PROTOVERSION_FIELD, CMD_LOGINSERVER_CLIENTVERSION_FIELD}
CMD_LOGINSERVER.is_extendable = false
CMD_LOGINSERVER.extensions = {}
RSP_LOGINSERVER_ERROR_FIELD.name = "Error"
RSP_LOGINSERVER_ERROR_FIELD.full_name = ".RSP_LoginServer.Error"
RSP_LOGINSERVER_ERROR_FIELD.number = 1
RSP_LOGINSERVER_ERROR_FIELD.index = 0
RSP_LOGINSERVER_ERROR_FIELD.label = 1
RSP_LOGINSERVER_ERROR_FIELD.has_default_value = false
RSP_LOGINSERVER_ERROR_FIELD.default_value = 0
RSP_LOGINSERVER_ERROR_FIELD.type = 5
RSP_LOGINSERVER_ERROR_FIELD.cpp_type = 1

RSP_LOGINSERVER_CHATROOM_FIELD.name = "ChatRoom"
RSP_LOGINSERVER_CHATROOM_FIELD.full_name = ".RSP_LoginServer.ChatRoom"
RSP_LOGINSERVER_CHATROOM_FIELD.number = 2
RSP_LOGINSERVER_CHATROOM_FIELD.index = 1
RSP_LOGINSERVER_CHATROOM_FIELD.label = 1
RSP_LOGINSERVER_CHATROOM_FIELD.has_default_value = false
RSP_LOGINSERVER_CHATROOM_FIELD.default_value = ""
RSP_LOGINSERVER_CHATROOM_FIELD.type = 9
RSP_LOGINSERVER_CHATROOM_FIELD.cpp_type = 9

RSP_LOGINSERVER_ERRINFO_FIELD.name = "ErrInfo"
RSP_LOGINSERVER_ERRINFO_FIELD.full_name = ".RSP_LoginServer.ErrInfo"
RSP_LOGINSERVER_ERRINFO_FIELD.number = 3
RSP_LOGINSERVER_ERRINFO_FIELD.index = 2
RSP_LOGINSERVER_ERRINFO_FIELD.label = 1
RSP_LOGINSERVER_ERRINFO_FIELD.has_default_value = false
RSP_LOGINSERVER_ERRINFO_FIELD.default_value = ""
RSP_LOGINSERVER_ERRINFO_FIELD.type = 9
RSP_LOGINSERVER_ERRINFO_FIELD.cpp_type = 9

RSP_LOGINSERVER.name = "RSP_LoginServer"
RSP_LOGINSERVER.full_name = ".RSP_LoginServer"
RSP_LOGINSERVER.nested_types = {}
RSP_LOGINSERVER.enum_types = {}
RSP_LOGINSERVER.fields = {RSP_LOGINSERVER_ERROR_FIELD, RSP_LOGINSERVER_CHATROOM_FIELD, RSP_LOGINSERVER_ERRINFO_FIELD}
RSP_LOGINSERVER.is_extendable = false
RSP_LOGINSERVER.extensions = {}
CMD_EXITROOM.name = "CMD_ExitRoom"
CMD_EXITROOM.full_name = ".CMD_ExitRoom"
CMD_EXITROOM.nested_types = {}
CMD_EXITROOM.enum_types = {}
CMD_EXITROOM.fields = {}
CMD_EXITROOM.is_extendable = false
CMD_EXITROOM.extensions = {}
RSP_EXITROOM_ERROR_FIELD.name = "Error"
RSP_EXITROOM_ERROR_FIELD.full_name = ".RSP_ExitRoom.Error"
RSP_EXITROOM_ERROR_FIELD.number = 1
RSP_EXITROOM_ERROR_FIELD.index = 0
RSP_EXITROOM_ERROR_FIELD.label = 1
RSP_EXITROOM_ERROR_FIELD.has_default_value = false
RSP_EXITROOM_ERROR_FIELD.default_value = 0
RSP_EXITROOM_ERROR_FIELD.type = 5
RSP_EXITROOM_ERROR_FIELD.cpp_type = 1

RSP_EXITROOM.name = "RSP_ExitRoom"
RSP_EXITROOM.full_name = ".RSP_ExitRoom"
RSP_EXITROOM.nested_types = {}
RSP_EXITROOM.enum_types = {}
RSP_EXITROOM.fields = {RSP_EXITROOM_ERROR_FIELD}
RSP_EXITROOM.is_extendable = false
RSP_EXITROOM.extensions = {}
CMD_MESSAGE_MESSAGE_FIELD.name = "Message"
CMD_MESSAGE_MESSAGE_FIELD.full_name = ".CMD_Message.Message"
CMD_MESSAGE_MESSAGE_FIELD.number = 1
CMD_MESSAGE_MESSAGE_FIELD.index = 0
CMD_MESSAGE_MESSAGE_FIELD.label = 1
CMD_MESSAGE_MESSAGE_FIELD.has_default_value = false
CMD_MESSAGE_MESSAGE_FIELD.default_value = ""
CMD_MESSAGE_MESSAGE_FIELD.type = 9
CMD_MESSAGE_MESSAGE_FIELD.cpp_type = 9

CMD_MESSAGE_APPENDDATA_FIELD.name = "AppendData"
CMD_MESSAGE_APPENDDATA_FIELD.full_name = ".CMD_Message.AppendData"
CMD_MESSAGE_APPENDDATA_FIELD.number = 2
CMD_MESSAGE_APPENDDATA_FIELD.index = 1
CMD_MESSAGE_APPENDDATA_FIELD.label = 1
CMD_MESSAGE_APPENDDATA_FIELD.has_default_value = false
CMD_MESSAGE_APPENDDATA_FIELD.default_value = ""
CMD_MESSAGE_APPENDDATA_FIELD.type = 9
CMD_MESSAGE_APPENDDATA_FIELD.cpp_type = 9

CMD_MESSAGE.name = "CMD_Message"
CMD_MESSAGE.full_name = ".CMD_Message"
CMD_MESSAGE.nested_types = {}
CMD_MESSAGE.enum_types = {}
CMD_MESSAGE.fields = {CMD_MESSAGE_MESSAGE_FIELD, CMD_MESSAGE_APPENDDATA_FIELD}
CMD_MESSAGE.is_extendable = false
CMD_MESSAGE.extensions = {}
CMD_QUERYDATA_PASSWORD_FIELD.name = "Password"
CMD_QUERYDATA_PASSWORD_FIELD.full_name = ".CMD_QueryData.Password"
CMD_QUERYDATA_PASSWORD_FIELD.number = 1
CMD_QUERYDATA_PASSWORD_FIELD.index = 0
CMD_QUERYDATA_PASSWORD_FIELD.label = 1
CMD_QUERYDATA_PASSWORD_FIELD.has_default_value = false
CMD_QUERYDATA_PASSWORD_FIELD.default_value = ""
CMD_QUERYDATA_PASSWORD_FIELD.type = 9
CMD_QUERYDATA_PASSWORD_FIELD.cpp_type = 9

CMD_QUERYDATA_QUERYID_FIELD.name = "QueryID"
CMD_QUERYDATA_QUERYID_FIELD.full_name = ".CMD_QueryData.QueryID"
CMD_QUERYDATA_QUERYID_FIELD.number = 2
CMD_QUERYDATA_QUERYID_FIELD.index = 1
CMD_QUERYDATA_QUERYID_FIELD.label = 1
CMD_QUERYDATA_QUERYID_FIELD.has_default_value = false
CMD_QUERYDATA_QUERYID_FIELD.default_value = 0
CMD_QUERYDATA_QUERYID_FIELD.type = 4
CMD_QUERYDATA_QUERYID_FIELD.cpp_type = 4

CMD_QUERYDATA.name = "CMD_QueryData"
CMD_QUERYDATA.full_name = ".CMD_QueryData"
CMD_QUERYDATA.nested_types = {}
CMD_QUERYDATA.enum_types = {}
CMD_QUERYDATA.fields = {CMD_QUERYDATA_PASSWORD_FIELD, CMD_QUERYDATA_QUERYID_FIELD}
CMD_QUERYDATA.is_extendable = false
CMD_QUERYDATA.extensions = {}
RSP_QUERYDATA_ERROR_FIELD.name = "Error"
RSP_QUERYDATA_ERROR_FIELD.full_name = ".RSP_QueryData.Error"
RSP_QUERYDATA_ERROR_FIELD.number = 1
RSP_QUERYDATA_ERROR_FIELD.index = 0
RSP_QUERYDATA_ERROR_FIELD.label = 1
RSP_QUERYDATA_ERROR_FIELD.has_default_value = false
RSP_QUERYDATA_ERROR_FIELD.default_value = 0
RSP_QUERYDATA_ERROR_FIELD.type = 5
RSP_QUERYDATA_ERROR_FIELD.cpp_type = 1

RSP_QUERYDATA.name = "RSP_QueryData"
RSP_QUERYDATA.full_name = ".RSP_QueryData"
RSP_QUERYDATA.nested_types = {}
RSP_QUERYDATA.enum_types = {}
RSP_QUERYDATA.fields = {RSP_QUERYDATA_ERROR_FIELD}
RSP_QUERYDATA.is_extendable = false
RSP_QUERYDATA.extensions = {}
CMD_DISMISS_ACTION_FIELD.name = "Action"
CMD_DISMISS_ACTION_FIELD.full_name = ".CMD_Dismiss.Action"
CMD_DISMISS_ACTION_FIELD.number = 1
CMD_DISMISS_ACTION_FIELD.index = 0
CMD_DISMISS_ACTION_FIELD.label = 1
CMD_DISMISS_ACTION_FIELD.has_default_value = false
CMD_DISMISS_ACTION_FIELD.default_value = 0
CMD_DISMISS_ACTION_FIELD.type = 5
CMD_DISMISS_ACTION_FIELD.cpp_type = 1

CMD_DISMISS.name = "CMD_Dismiss"
CMD_DISMISS.full_name = ".CMD_Dismiss"
CMD_DISMISS.nested_types = {}
CMD_DISMISS.enum_types = {}
CMD_DISMISS.fields = {CMD_DISMISS_ACTION_FIELD}
CMD_DISMISS.is_extendable = false
CMD_DISMISS.extensions = {}
CMD_KICKUSER_USERID_FIELD.name = "UserID"
CMD_KICKUSER_USERID_FIELD.full_name = ".CMD_KickUser.UserID"
CMD_KICKUSER_USERID_FIELD.number = 1
CMD_KICKUSER_USERID_FIELD.index = 0
CMD_KICKUSER_USERID_FIELD.label = 1
CMD_KICKUSER_USERID_FIELD.has_default_value = false
CMD_KICKUSER_USERID_FIELD.default_value = 0
CMD_KICKUSER_USERID_FIELD.type = 4
CMD_KICKUSER_USERID_FIELD.cpp_type = 4

CMD_KICKUSER.name = "CMD_KickUser"
CMD_KICKUSER.full_name = ".CMD_KickUser"
CMD_KICKUSER.nested_types = {}
CMD_KICKUSER.enum_types = {}
CMD_KICKUSER.fields = {CMD_KICKUSER_USERID_FIELD}
CMD_KICKUSER.is_extendable = false
CMD_KICKUSER.extensions = {}
CMD_PRIVATE_MESSAGE_SEATID_FIELD.name = "SeatID"
CMD_PRIVATE_MESSAGE_SEATID_FIELD.full_name = ".CMD_Private_Message.SeatID"
CMD_PRIVATE_MESSAGE_SEATID_FIELD.number = 1
CMD_PRIVATE_MESSAGE_SEATID_FIELD.index = 0
CMD_PRIVATE_MESSAGE_SEATID_FIELD.label = 1
CMD_PRIVATE_MESSAGE_SEATID_FIELD.has_default_value = false
CMD_PRIVATE_MESSAGE_SEATID_FIELD.default_value = 0
CMD_PRIVATE_MESSAGE_SEATID_FIELD.type = 13
CMD_PRIVATE_MESSAGE_SEATID_FIELD.cpp_type = 3

CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.name = "Message"
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.full_name = ".CMD_Private_Message.Message"
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.number = 2
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.index = 1
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.label = 1
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.has_default_value = false
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.default_value = ""
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.type = 9
CMD_PRIVATE_MESSAGE_MESSAGE_FIELD.cpp_type = 9

CMD_PRIVATE_MESSAGE.name = "CMD_Private_Message"
CMD_PRIVATE_MESSAGE.full_name = ".CMD_Private_Message"
CMD_PRIVATE_MESSAGE.nested_types = {}
CMD_PRIVATE_MESSAGE.enum_types = {}
CMD_PRIVATE_MESSAGE.fields = {CMD_PRIVATE_MESSAGE_SEATID_FIELD, CMD_PRIVATE_MESSAGE_MESSAGE_FIELD}
CMD_PRIVATE_MESSAGE.is_extendable = false
CMD_PRIVATE_MESSAGE.extensions = {}
CMD_REPORTSTATE_STATE_FIELD.name = "State"
CMD_REPORTSTATE_STATE_FIELD.full_name = ".CMD_ReportState.State"
CMD_REPORTSTATE_STATE_FIELD.number = 1
CMD_REPORTSTATE_STATE_FIELD.index = 0
CMD_REPORTSTATE_STATE_FIELD.label = 1
CMD_REPORTSTATE_STATE_FIELD.has_default_value = false
CMD_REPORTSTATE_STATE_FIELD.default_value = 0
CMD_REPORTSTATE_STATE_FIELD.type = 5
CMD_REPORTSTATE_STATE_FIELD.cpp_type = 1

CMD_REPORTSTATE.name = "CMD_ReportState"
CMD_REPORTSTATE.full_name = ".CMD_ReportState"
CMD_REPORTSTATE.nested_types = {}
CMD_REPORTSTATE.enum_types = {}
CMD_REPORTSTATE.fields = {CMD_REPORTSTATE_STATE_FIELD}
CMD_REPORTSTATE.is_extendable = false
CMD_REPORTSTATE.extensions = {}
CMD_GET_KICKED_TIMEOUT.name = "CMD_GET_KICKED_TIMEOUT"
CMD_GET_KICKED_TIMEOUT.full_name = ".CMD_GET_KICKED_TIMEOUT"
CMD_GET_KICKED_TIMEOUT.nested_types = {}
CMD_GET_KICKED_TIMEOUT.enum_types = {}
CMD_GET_KICKED_TIMEOUT.fields = {}
CMD_GET_KICKED_TIMEOUT.is_extendable = false
CMD_GET_KICKED_TIMEOUT.extensions = {}
NTF_ROOMUSERINFO_SEATID_FIELD.name = "SeatID"
NTF_ROOMUSERINFO_SEATID_FIELD.full_name = ".NTF_RoomUserInfo.SeatID"
NTF_ROOMUSERINFO_SEATID_FIELD.number = 1
NTF_ROOMUSERINFO_SEATID_FIELD.index = 0
NTF_ROOMUSERINFO_SEATID_FIELD.label = 1
NTF_ROOMUSERINFO_SEATID_FIELD.has_default_value = false
NTF_ROOMUSERINFO_SEATID_FIELD.default_value = 0
NTF_ROOMUSERINFO_SEATID_FIELD.type = 13
NTF_ROOMUSERINFO_SEATID_FIELD.cpp_type = 3

NTF_ROOMUSERINFO_USERID_FIELD.name = "UserID"
NTF_ROOMUSERINFO_USERID_FIELD.full_name = ".NTF_RoomUserInfo.UserID"
NTF_ROOMUSERINFO_USERID_FIELD.number = 2
NTF_ROOMUSERINFO_USERID_FIELD.index = 1
NTF_ROOMUSERINFO_USERID_FIELD.label = 1
NTF_ROOMUSERINFO_USERID_FIELD.has_default_value = false
NTF_ROOMUSERINFO_USERID_FIELD.default_value = 0
NTF_ROOMUSERINFO_USERID_FIELD.type = 4
NTF_ROOMUSERINFO_USERID_FIELD.cpp_type = 4

NTF_ROOMUSERINFO_APPENDDATA_FIELD.name = "AppendData"
NTF_ROOMUSERINFO_APPENDDATA_FIELD.full_name = ".NTF_RoomUserInfo.AppendData"
NTF_ROOMUSERINFO_APPENDDATA_FIELD.number = 3
NTF_ROOMUSERINFO_APPENDDATA_FIELD.index = 2
NTF_ROOMUSERINFO_APPENDDATA_FIELD.label = 1
NTF_ROOMUSERINFO_APPENDDATA_FIELD.has_default_value = false
NTF_ROOMUSERINFO_APPENDDATA_FIELD.default_value = ""
NTF_ROOMUSERINFO_APPENDDATA_FIELD.type = 9
NTF_ROOMUSERINFO_APPENDDATA_FIELD.cpp_type = 9

NTF_ROOMUSERINFO_STATE_FIELD.name = "State"
NTF_ROOMUSERINFO_STATE_FIELD.full_name = ".NTF_RoomUserInfo.State"
NTF_ROOMUSERINFO_STATE_FIELD.number = 4
NTF_ROOMUSERINFO_STATE_FIELD.index = 3
NTF_ROOMUSERINFO_STATE_FIELD.label = 1
NTF_ROOMUSERINFO_STATE_FIELD.has_default_value = false
NTF_ROOMUSERINFO_STATE_FIELD.default_value = 0
NTF_ROOMUSERINFO_STATE_FIELD.type = 5
NTF_ROOMUSERINFO_STATE_FIELD.cpp_type = 1

NTF_ROOMUSERINFO.name = "NTF_RoomUserInfo"
NTF_ROOMUSERINFO.full_name = ".NTF_RoomUserInfo"
NTF_ROOMUSERINFO.nested_types = {}
NTF_ROOMUSERINFO.enum_types = {}
NTF_ROOMUSERINFO.fields = {NTF_ROOMUSERINFO_SEATID_FIELD, NTF_ROOMUSERINFO_USERID_FIELD, NTF_ROOMUSERINFO_APPENDDATA_FIELD, NTF_ROOMUSERINFO_STATE_FIELD}
NTF_ROOMUSERINFO.is_extendable = false
NTF_ROOMUSERINFO.extensions = {}
NTF_SAMEUSERLOGIN_IP_FIELD.name = "IP"
NTF_SAMEUSERLOGIN_IP_FIELD.full_name = ".NTF_SameUserLogin.IP"
NTF_SAMEUSERLOGIN_IP_FIELD.number = 1
NTF_SAMEUSERLOGIN_IP_FIELD.index = 0
NTF_SAMEUSERLOGIN_IP_FIELD.label = 1
NTF_SAMEUSERLOGIN_IP_FIELD.has_default_value = false
NTF_SAMEUSERLOGIN_IP_FIELD.default_value = 0
NTF_SAMEUSERLOGIN_IP_FIELD.type = 13
NTF_SAMEUSERLOGIN_IP_FIELD.cpp_type = 3

NTF_SAMEUSERLOGIN.name = "NTF_SameUserLogin"
NTF_SAMEUSERLOGIN.full_name = ".NTF_SameUserLogin"
NTF_SAMEUSERLOGIN.nested_types = {}
NTF_SAMEUSERLOGIN.enum_types = {}
NTF_SAMEUSERLOGIN.fields = {NTF_SAMEUSERLOGIN_IP_FIELD}
NTF_SAMEUSERLOGIN.is_extendable = false
NTF_SAMEUSERLOGIN.extensions = {}
NTF_ROOMUSERONLINE_SEATID_FIELD.name = "SeatID"
NTF_ROOMUSERONLINE_SEATID_FIELD.full_name = ".NTF_RoomUserOnline.SeatID"
NTF_ROOMUSERONLINE_SEATID_FIELD.number = 1
NTF_ROOMUSERONLINE_SEATID_FIELD.index = 0
NTF_ROOMUSERONLINE_SEATID_FIELD.label = 1
NTF_ROOMUSERONLINE_SEATID_FIELD.has_default_value = false
NTF_ROOMUSERONLINE_SEATID_FIELD.default_value = 0
NTF_ROOMUSERONLINE_SEATID_FIELD.type = 13
NTF_ROOMUSERONLINE_SEATID_FIELD.cpp_type = 3

NTF_ROOMUSERONLINE_IP_FIELD.name = "IP"
NTF_ROOMUSERONLINE_IP_FIELD.full_name = ".NTF_RoomUserOnline.IP"
NTF_ROOMUSERONLINE_IP_FIELD.number = 2
NTF_ROOMUSERONLINE_IP_FIELD.index = 1
NTF_ROOMUSERONLINE_IP_FIELD.label = 1
NTF_ROOMUSERONLINE_IP_FIELD.has_default_value = false
NTF_ROOMUSERONLINE_IP_FIELD.default_value = 0
NTF_ROOMUSERONLINE_IP_FIELD.type = 13
NTF_ROOMUSERONLINE_IP_FIELD.cpp_type = 3

NTF_ROOMUSERONLINE_APPENDDATA_FIELD.name = "AppendData"
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.full_name = ".NTF_RoomUserOnline.AppendData"
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.number = 3
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.index = 2
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.label = 1
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.has_default_value = false
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.default_value = ""
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.type = 9
NTF_ROOMUSERONLINE_APPENDDATA_FIELD.cpp_type = 9

NTF_ROOMUSERONLINE.name = "NTF_RoomUserOnline"
NTF_ROOMUSERONLINE.full_name = ".NTF_RoomUserOnline"
NTF_ROOMUSERONLINE.nested_types = {}
NTF_ROOMUSERONLINE.enum_types = {}
NTF_ROOMUSERONLINE.fields = {NTF_ROOMUSERONLINE_SEATID_FIELD, NTF_ROOMUSERONLINE_IP_FIELD, NTF_ROOMUSERONLINE_APPENDDATA_FIELD}
NTF_ROOMUSERONLINE.is_extendable = false
NTF_ROOMUSERONLINE.extensions = {}
NTF_ROOMUSEROFFLINE_SEATID_FIELD.name = "SeatID"
NTF_ROOMUSEROFFLINE_SEATID_FIELD.full_name = ".NTF_RoomUserOffline.SeatID"
NTF_ROOMUSEROFFLINE_SEATID_FIELD.number = 1
NTF_ROOMUSEROFFLINE_SEATID_FIELD.index = 0
NTF_ROOMUSEROFFLINE_SEATID_FIELD.label = 1
NTF_ROOMUSEROFFLINE_SEATID_FIELD.has_default_value = false
NTF_ROOMUSEROFFLINE_SEATID_FIELD.default_value = 0
NTF_ROOMUSEROFFLINE_SEATID_FIELD.type = 13
NTF_ROOMUSEROFFLINE_SEATID_FIELD.cpp_type = 3

NTF_ROOMUSEROFFLINE.name = "NTF_RoomUserOffline"
NTF_ROOMUSEROFFLINE.full_name = ".NTF_RoomUserOffline"
NTF_ROOMUSEROFFLINE.nested_types = {}
NTF_ROOMUSEROFFLINE.enum_types = {}
NTF_ROOMUSEROFFLINE.fields = {NTF_ROOMUSEROFFLINE_SEATID_FIELD}
NTF_ROOMUSEROFFLINE.is_extendable = false
NTF_ROOMUSEROFFLINE.extensions = {}
NTF_ROOMDISMISSED.name = "NTF_RoomDismissed"
NTF_ROOMDISMISSED.full_name = ".NTF_RoomDismissed"
NTF_ROOMDISMISSED.nested_types = {}
NTF_ROOMDISMISSED.enum_types = {}
NTF_ROOMDISMISSED.fields = {}
NTF_ROOMDISMISSED.is_extendable = false
NTF_ROOMDISMISSED.extensions = {}
NTF_MESSAGE_SEATID_FIELD.name = "SeatID"
NTF_MESSAGE_SEATID_FIELD.full_name = ".NTF_Message.SeatID"
NTF_MESSAGE_SEATID_FIELD.number = 1
NTF_MESSAGE_SEATID_FIELD.index = 0
NTF_MESSAGE_SEATID_FIELD.label = 1
NTF_MESSAGE_SEATID_FIELD.has_default_value = false
NTF_MESSAGE_SEATID_FIELD.default_value = 0
NTF_MESSAGE_SEATID_FIELD.type = 13
NTF_MESSAGE_SEATID_FIELD.cpp_type = 3

NTF_MESSAGE_MESSAGE_FIELD.name = "Message"
NTF_MESSAGE_MESSAGE_FIELD.full_name = ".NTF_Message.Message"
NTF_MESSAGE_MESSAGE_FIELD.number = 2
NTF_MESSAGE_MESSAGE_FIELD.index = 1
NTF_MESSAGE_MESSAGE_FIELD.label = 1
NTF_MESSAGE_MESSAGE_FIELD.has_default_value = false
NTF_MESSAGE_MESSAGE_FIELD.default_value = ""
NTF_MESSAGE_MESSAGE_FIELD.type = 9
NTF_MESSAGE_MESSAGE_FIELD.cpp_type = 9

NTF_MESSAGE.name = "NTF_Message"
NTF_MESSAGE.full_name = ".NTF_Message"
NTF_MESSAGE.nested_types = {}
NTF_MESSAGE.enum_types = {}
NTF_MESSAGE.fields = {NTF_MESSAGE_SEATID_FIELD, NTF_MESSAGE_MESSAGE_FIELD}
NTF_MESSAGE.is_extendable = false
NTF_MESSAGE.extensions = {}
NTF_DISMISS_ACTION_FIELD.name = "Action"
NTF_DISMISS_ACTION_FIELD.full_name = ".NTF_Dismiss.Action"
NTF_DISMISS_ACTION_FIELD.number = 1
NTF_DISMISS_ACTION_FIELD.index = 0
NTF_DISMISS_ACTION_FIELD.label = 3
NTF_DISMISS_ACTION_FIELD.has_default_value = false
NTF_DISMISS_ACTION_FIELD.default_value = {}
NTF_DISMISS_ACTION_FIELD.type = 5
NTF_DISMISS_ACTION_FIELD.cpp_type = 1

NTF_DISMISS_TIME_FIELD.name = "Time"
NTF_DISMISS_TIME_FIELD.full_name = ".NTF_Dismiss.Time"
NTF_DISMISS_TIME_FIELD.number = 2
NTF_DISMISS_TIME_FIELD.index = 1
NTF_DISMISS_TIME_FIELD.label = 1
NTF_DISMISS_TIME_FIELD.has_default_value = false
NTF_DISMISS_TIME_FIELD.default_value = 0
NTF_DISMISS_TIME_FIELD.type = 13
NTF_DISMISS_TIME_FIELD.cpp_type = 3

NTF_DISMISS.name = "NTF_Dismiss"
NTF_DISMISS.full_name = ".NTF_Dismiss"
NTF_DISMISS.nested_types = {}
NTF_DISMISS.enum_types = {}
NTF_DISMISS.fields = {NTF_DISMISS_ACTION_FIELD, NTF_DISMISS_TIME_FIELD}
NTF_DISMISS.is_extendable = false
NTF_DISMISS.extensions = {}
NTF_KICKED.name = "NTF_Kicked"
NTF_KICKED.full_name = ".NTF_Kicked"
NTF_KICKED.nested_types = {}
NTF_KICKED.enum_types = {}
NTF_KICKED.fields = {}
NTF_KICKED.is_extendable = false
NTF_KICKED.extensions = {}
NTF_PRIVATE_MESSAGE_SEATID_FIELD.name = "SeatID"
NTF_PRIVATE_MESSAGE_SEATID_FIELD.full_name = ".NTF_Private_Message.SeatID"
NTF_PRIVATE_MESSAGE_SEATID_FIELD.number = 1
NTF_PRIVATE_MESSAGE_SEATID_FIELD.index = 0
NTF_PRIVATE_MESSAGE_SEATID_FIELD.label = 1
NTF_PRIVATE_MESSAGE_SEATID_FIELD.has_default_value = false
NTF_PRIVATE_MESSAGE_SEATID_FIELD.default_value = 0
NTF_PRIVATE_MESSAGE_SEATID_FIELD.type = 13
NTF_PRIVATE_MESSAGE_SEATID_FIELD.cpp_type = 3

NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.name = "Message"
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.full_name = ".NTF_Private_Message.Message"
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.number = 2
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.index = 1
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.label = 1
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.has_default_value = false
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.default_value = ""
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.type = 9
NTF_PRIVATE_MESSAGE_MESSAGE_FIELD.cpp_type = 9

NTF_PRIVATE_MESSAGE.name = "NTF_Private_Message"
NTF_PRIVATE_MESSAGE.full_name = ".NTF_Private_Message"
NTF_PRIVATE_MESSAGE.nested_types = {}
NTF_PRIVATE_MESSAGE.enum_types = {}
NTF_PRIVATE_MESSAGE.fields = {NTF_PRIVATE_MESSAGE_SEATID_FIELD, NTF_PRIVATE_MESSAGE_MESSAGE_FIELD}
NTF_PRIVATE_MESSAGE.is_extendable = false
NTF_PRIVATE_MESSAGE.extensions = {}
NTF_REPORTSTATE_SEATID_FIELD.name = "SeatID"
NTF_REPORTSTATE_SEATID_FIELD.full_name = ".NTF_ReportState.SeatID"
NTF_REPORTSTATE_SEATID_FIELD.number = 1
NTF_REPORTSTATE_SEATID_FIELD.index = 0
NTF_REPORTSTATE_SEATID_FIELD.label = 2
NTF_REPORTSTATE_SEATID_FIELD.has_default_value = false
NTF_REPORTSTATE_SEATID_FIELD.default_value = 0
NTF_REPORTSTATE_SEATID_FIELD.type = 13
NTF_REPORTSTATE_SEATID_FIELD.cpp_type = 3

NTF_REPORTSTATE_STATE_FIELD.name = "State"
NTF_REPORTSTATE_STATE_FIELD.full_name = ".NTF_ReportState.State"
NTF_REPORTSTATE_STATE_FIELD.number = 2
NTF_REPORTSTATE_STATE_FIELD.index = 1
NTF_REPORTSTATE_STATE_FIELD.label = 2
NTF_REPORTSTATE_STATE_FIELD.has_default_value = false
NTF_REPORTSTATE_STATE_FIELD.default_value = 0
NTF_REPORTSTATE_STATE_FIELD.type = 5
NTF_REPORTSTATE_STATE_FIELD.cpp_type = 1

NTF_REPORTSTATE.name = "NTF_ReportState"
NTF_REPORTSTATE.full_name = ".NTF_ReportState"
NTF_REPORTSTATE.nested_types = {}
NTF_REPORTSTATE.enum_types = {}
NTF_REPORTSTATE.fields = {NTF_REPORTSTATE_SEATID_FIELD, NTF_REPORTSTATE_STATE_FIELD}
NTF_REPORTSTATE.is_extendable = false
NTF_REPORTSTATE.extensions = {}
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.name = "Time"
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.full_name = ".NTF_RETURN_KICKED_TIMEOUT.Time"
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.number = 1
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.index = 0
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.label = 2
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.has_default_value = false
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.default_value = 0
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.type = 13
NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD.cpp_type = 3

NTF_RETURN_KICKED_TIMEOUT.name = "NTF_RETURN_KICKED_TIMEOUT"
NTF_RETURN_KICKED_TIMEOUT.full_name = ".NTF_RETURN_KICKED_TIMEOUT"
NTF_RETURN_KICKED_TIMEOUT.nested_types = {}
NTF_RETURN_KICKED_TIMEOUT.enum_types = {}
NTF_RETURN_KICKED_TIMEOUT.fields = {NTF_RETURN_KICKED_TIMEOUT_TIME_FIELD}
NTF_RETURN_KICKED_TIMEOUT.is_extendable = false
NTF_RETURN_KICKED_TIMEOUT.extensions = {}
NTF_ROOMAWARDMESSAGE_USERID_FIELD.name = "UserID"
NTF_ROOMAWARDMESSAGE_USERID_FIELD.full_name = ".NTF_RoomAwardMessage.UserID"
NTF_ROOMAWARDMESSAGE_USERID_FIELD.number = 1
NTF_ROOMAWARDMESSAGE_USERID_FIELD.index = 0
NTF_ROOMAWARDMESSAGE_USERID_FIELD.label = 2
NTF_ROOMAWARDMESSAGE_USERID_FIELD.has_default_value = false
NTF_ROOMAWARDMESSAGE_USERID_FIELD.default_value = 0
NTF_ROOMAWARDMESSAGE_USERID_FIELD.type = 4
NTF_ROOMAWARDMESSAGE_USERID_FIELD.cpp_type = 4

NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.name = "Message"
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.full_name = ".NTF_RoomAwardMessage.Message"
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.number = 2
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.index = 1
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.label = 2
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.has_default_value = false
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.default_value = ""
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.type = 9
NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD.cpp_type = 9

NTF_ROOMAWARDMESSAGE.name = "NTF_RoomAwardMessage"
NTF_ROOMAWARDMESSAGE.full_name = ".NTF_RoomAwardMessage"
NTF_ROOMAWARDMESSAGE.nested_types = {}
NTF_ROOMAWARDMESSAGE.enum_types = {}
NTF_ROOMAWARDMESSAGE.fields = {NTF_ROOMAWARDMESSAGE_USERID_FIELD, NTF_ROOMAWARDMESSAGE_MESSAGE_FIELD}
NTF_ROOMAWARDMESSAGE.is_extendable = false
NTF_ROOMAWARDMESSAGE.extensions = {}

CMD_Dismiss = protobuf.Message(CMD_DISMISS)
CMD_ExitRoom = protobuf.Message(CMD_EXITROOM)
CMD_GET_KICKED_TIMEOUT = protobuf.Message(CMD_GET_KICKED_TIMEOUT)
CMD_HeartBeat = protobuf.Message(CMD_HEARTBEAT)
CMD_KickUser = protobuf.Message(CMD_KICKUSER)
CMD_LoginServer = protobuf.Message(CMD_LOGINSERVER)
CMD_Message = protobuf.Message(CMD_MESSAGE)
CMD_Private_Message = protobuf.Message(CMD_PRIVATE_MESSAGE)
CMD_QueryData = protobuf.Message(CMD_QUERYDATA)
CMD_ReportState = protobuf.Message(CMD_REPORTSTATE)
NTF_Dismiss = protobuf.Message(NTF_DISMISS)
NTF_Kicked = protobuf.Message(NTF_KICKED)
NTF_Message = protobuf.Message(NTF_MESSAGE)
NTF_Private_Message = protobuf.Message(NTF_PRIVATE_MESSAGE)
NTF_RETURN_KICKED_TIMEOUT = protobuf.Message(NTF_RETURN_KICKED_TIMEOUT)
NTF_ReportState = protobuf.Message(NTF_REPORTSTATE)
NTF_RoomAwardMessage = protobuf.Message(NTF_ROOMAWARDMESSAGE)
NTF_RoomDismissed = protobuf.Message(NTF_ROOMDISMISSED)
NTF_RoomUserInfo = protobuf.Message(NTF_ROOMUSERINFO)
NTF_RoomUserOffline = protobuf.Message(NTF_ROOMUSEROFFLINE)
NTF_RoomUserOnline = protobuf.Message(NTF_ROOMUSERONLINE)
NTF_SameUserLogin = protobuf.Message(NTF_SAMEUSERLOGIN)
RSP_ExitRoom = protobuf.Message(RSP_EXITROOM)
RSP_HeartBeat = protobuf.Message(RSP_HEARTBEAT)
RSP_LoginServer = protobuf.Message(RSP_LOGINSERVER)
RSP_QueryData = protobuf.Message(RSP_QUERYDATA)

