--Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf.protobuf"
module('package.biji.model.net.protol.player_pb')
module('protol.player_pb')

GM_ROLE = protobuf.Descriptor();
GM_ROLE_ACCID_FIELD = protobuf.FieldDescriptor();
GM_ROLE_OPENID_FIELD = protobuf.FieldDescriptor();
GM_ROLE_SEX_FIELD = protobuf.FieldDescriptor();
GM_ROLE_NICKNAME_FIELD = protobuf.FieldDescriptor();
GM_ROLE_HEADURL_FIELD = protobuf.FieldDescriptor();
GM_ROLE_AREANUM_FIELD = protobuf.FieldDescriptor();
GM_ROLE_ROLEID_FIELD = protobuf.FieldDescriptor();
GM_ROLE_AVATAR_FIELD = protobuf.FieldDescriptor();
GM_ROLE_NAME_FIELD = protobuf.FieldDescriptor();
GM_ROLE_ISNEW_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGIN = protobuf.Descriptor();
GM_ROLELOGIN_ROLE_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGIN_LOGINFO_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGIN_LTIME_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN = protobuf.Descriptor();
GM_ROLELOGINRETURN_ACCID_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_ROLEID_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_NAME_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_AVATAR_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_EXP_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_LEVEL_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_VIPLEVEL_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_TIRED_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_COMBAT_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_GOLD_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_COIN_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_CHIP_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_CREATETIME_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_SERVER_TIME_FIELD = protobuf.FieldDescriptor();
GM_ROLELOGINRETURN_ISNEW_FIELD = protobuf.FieldDescriptor();
GM_COMMONINT32CHANGENOTIFY = protobuf.Descriptor();
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD = protobuf.FieldDescriptor();
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD = protobuf.FieldDescriptor();
GM_COMMONLONG64CHANGENOTIFY = protobuf.Descriptor();
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD = protobuf.FieldDescriptor();
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD = protobuf.FieldDescriptor();
GM_COMMONFLOATCHANGENOTIFY = protobuf.Descriptor();
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD = protobuf.FieldDescriptor();
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD = protobuf.FieldDescriptor();
GM_ROLEINFO = protobuf.Descriptor();
GM_ROLEINFO_ROLEID_FIELD = protobuf.FieldDescriptor();
GM_ROLEINFO_NAME_FIELD = protobuf.FieldDescriptor();
GM_ROLEINFO_LEVEL_FIELD = protobuf.FieldDescriptor();

GM_ROLE_ACCID_FIELD.name = "accid"
GM_ROLE_ACCID_FIELD.full_name = ".GM_Role.accid"
GM_ROLE_ACCID_FIELD.number = 1
GM_ROLE_ACCID_FIELD.index = 0
GM_ROLE_ACCID_FIELD.label = 2
GM_ROLE_ACCID_FIELD.has_default_value = false
GM_ROLE_ACCID_FIELD.default_value = 0
GM_ROLE_ACCID_FIELD.type = 5
GM_ROLE_ACCID_FIELD.cpp_type = 1

GM_ROLE_OPENID_FIELD.name = "openid"
GM_ROLE_OPENID_FIELD.full_name = ".GM_Role.openid"
GM_ROLE_OPENID_FIELD.number = 2
GM_ROLE_OPENID_FIELD.index = 1
GM_ROLE_OPENID_FIELD.label = 1
GM_ROLE_OPENID_FIELD.has_default_value = false
GM_ROLE_OPENID_FIELD.default_value = ""
GM_ROLE_OPENID_FIELD.type = 9
GM_ROLE_OPENID_FIELD.cpp_type = 9

GM_ROLE_SEX_FIELD.name = "sex"
GM_ROLE_SEX_FIELD.full_name = ".GM_Role.sex"
GM_ROLE_SEX_FIELD.number = 3
GM_ROLE_SEX_FIELD.index = 2
GM_ROLE_SEX_FIELD.label = 1
GM_ROLE_SEX_FIELD.has_default_value = false
GM_ROLE_SEX_FIELD.default_value = 0
GM_ROLE_SEX_FIELD.type = 5
GM_ROLE_SEX_FIELD.cpp_type = 1

GM_ROLE_NICKNAME_FIELD.name = "nickname"
GM_ROLE_NICKNAME_FIELD.full_name = ".GM_Role.nickname"
GM_ROLE_NICKNAME_FIELD.number = 4
GM_ROLE_NICKNAME_FIELD.index = 3
GM_ROLE_NICKNAME_FIELD.label = 1
GM_ROLE_NICKNAME_FIELD.has_default_value = false
GM_ROLE_NICKNAME_FIELD.default_value = ""
GM_ROLE_NICKNAME_FIELD.type = 9
GM_ROLE_NICKNAME_FIELD.cpp_type = 9

GM_ROLE_HEADURL_FIELD.name = "headurl"
GM_ROLE_HEADURL_FIELD.full_name = ".GM_Role.headurl"
GM_ROLE_HEADURL_FIELD.number = 5
GM_ROLE_HEADURL_FIELD.index = 4
GM_ROLE_HEADURL_FIELD.label = 1
GM_ROLE_HEADURL_FIELD.has_default_value = false
GM_ROLE_HEADURL_FIELD.default_value = ""
GM_ROLE_HEADURL_FIELD.type = 9
GM_ROLE_HEADURL_FIELD.cpp_type = 9

GM_ROLE_AREANUM_FIELD.name = "areanum"
GM_ROLE_AREANUM_FIELD.full_name = ".GM_Role.areanum"
GM_ROLE_AREANUM_FIELD.number = 6
GM_ROLE_AREANUM_FIELD.index = 5
GM_ROLE_AREANUM_FIELD.label = 1
GM_ROLE_AREANUM_FIELD.has_default_value = false
GM_ROLE_AREANUM_FIELD.default_value = 0
GM_ROLE_AREANUM_FIELD.type = 5
GM_ROLE_AREANUM_FIELD.cpp_type = 1

GM_ROLE_ROLEID_FIELD.name = "roleid"
GM_ROLE_ROLEID_FIELD.full_name = ".GM_Role.roleid"
GM_ROLE_ROLEID_FIELD.number = 7
GM_ROLE_ROLEID_FIELD.index = 6
GM_ROLE_ROLEID_FIELD.label = 1
GM_ROLE_ROLEID_FIELD.has_default_value = false
GM_ROLE_ROLEID_FIELD.default_value = 0
GM_ROLE_ROLEID_FIELD.type = 5
GM_ROLE_ROLEID_FIELD.cpp_type = 1

GM_ROLE_AVATAR_FIELD.name = "avatar"
GM_ROLE_AVATAR_FIELD.full_name = ".GM_Role.avatar"
GM_ROLE_AVATAR_FIELD.number = 8
GM_ROLE_AVATAR_FIELD.index = 7
GM_ROLE_AVATAR_FIELD.label = 1
GM_ROLE_AVATAR_FIELD.has_default_value = false
GM_ROLE_AVATAR_FIELD.default_value = 0
GM_ROLE_AVATAR_FIELD.type = 5
GM_ROLE_AVATAR_FIELD.cpp_type = 1

GM_ROLE_NAME_FIELD.name = "name"
GM_ROLE_NAME_FIELD.full_name = ".GM_Role.name"
GM_ROLE_NAME_FIELD.number = 9
GM_ROLE_NAME_FIELD.index = 8
GM_ROLE_NAME_FIELD.label = 1
GM_ROLE_NAME_FIELD.has_default_value = false
GM_ROLE_NAME_FIELD.default_value = ""
GM_ROLE_NAME_FIELD.type = 9
GM_ROLE_NAME_FIELD.cpp_type = 9

GM_ROLE_ISNEW_FIELD.name = "isnew"
GM_ROLE_ISNEW_FIELD.full_name = ".GM_Role.isnew"
GM_ROLE_ISNEW_FIELD.number = 10
GM_ROLE_ISNEW_FIELD.index = 9
GM_ROLE_ISNEW_FIELD.label = 1
GM_ROLE_ISNEW_FIELD.has_default_value = false
GM_ROLE_ISNEW_FIELD.default_value = false
GM_ROLE_ISNEW_FIELD.type = 8
GM_ROLE_ISNEW_FIELD.cpp_type = 7

GM_ROLE.name = "GM_Role"
GM_ROLE.full_name = ".GM_Role"
GM_ROLE.nested_types = {}
GM_ROLE.enum_types = {}
GM_ROLE.fields = {GM_ROLE_ACCID_FIELD, GM_ROLE_OPENID_FIELD, GM_ROLE_SEX_FIELD, GM_ROLE_NICKNAME_FIELD, GM_ROLE_HEADURL_FIELD, GM_ROLE_AREANUM_FIELD, GM_ROLE_ROLEID_FIELD, GM_ROLE_AVATAR_FIELD, GM_ROLE_NAME_FIELD, GM_ROLE_ISNEW_FIELD}
GM_ROLE.is_extendable = false
GM_ROLE.extensions = {}
GM_ROLELOGIN_ROLE_FIELD.name = "role"
GM_ROLELOGIN_ROLE_FIELD.full_name = ".GM_RoleLogin.role"
GM_ROLELOGIN_ROLE_FIELD.number = 1
GM_ROLELOGIN_ROLE_FIELD.index = 0
GM_ROLELOGIN_ROLE_FIELD.label = 2
GM_ROLELOGIN_ROLE_FIELD.has_default_value = false
GM_ROLELOGIN_ROLE_FIELD.default_value = nil
GM_ROLELOGIN_ROLE_FIELD.message_type = GM_ROLE
GM_ROLELOGIN_ROLE_FIELD.type = 11
GM_ROLELOGIN_ROLE_FIELD.cpp_type = 10

GM_ROLELOGIN_LOGINFO_FIELD.name = "loginfo"
GM_ROLELOGIN_LOGINFO_FIELD.full_name = ".GM_RoleLogin.loginfo"
GM_ROLELOGIN_LOGINFO_FIELD.number = 2
GM_ROLELOGIN_LOGINFO_FIELD.index = 1
GM_ROLELOGIN_LOGINFO_FIELD.label = 2
GM_ROLELOGIN_LOGINFO_FIELD.has_default_value = false
GM_ROLELOGIN_LOGINFO_FIELD.default_value = nil
GM_ROLELOGIN_LOGINFO_FIELD.message_type = account_pb.GM_ACCOUNTLOG
GM_ROLELOGIN_LOGINFO_FIELD.type = 11
GM_ROLELOGIN_LOGINFO_FIELD.cpp_type = 10

GM_ROLELOGIN_LTIME_FIELD.name = "ltime"
GM_ROLELOGIN_LTIME_FIELD.full_name = ".GM_RoleLogin.ltime"
GM_ROLELOGIN_LTIME_FIELD.number = 3
GM_ROLELOGIN_LTIME_FIELD.index = 2
GM_ROLELOGIN_LTIME_FIELD.label = 1
GM_ROLELOGIN_LTIME_FIELD.has_default_value = false
GM_ROLELOGIN_LTIME_FIELD.default_value = 0
GM_ROLELOGIN_LTIME_FIELD.type = 3
GM_ROLELOGIN_LTIME_FIELD.cpp_type = 2

GM_ROLELOGIN.name = "GM_RoleLogin"
GM_ROLELOGIN.full_name = ".GM_RoleLogin"
GM_ROLELOGIN.nested_types = {}
GM_ROLELOGIN.enum_types = {}
GM_ROLELOGIN.fields = {GM_ROLELOGIN_ROLE_FIELD, GM_ROLELOGIN_LOGINFO_FIELD, GM_ROLELOGIN_LTIME_FIELD}
GM_ROLELOGIN.is_extendable = false
GM_ROLELOGIN.extensions = {}
GM_ROLELOGINRETURN_ACCID_FIELD.name = "accid"
GM_ROLELOGINRETURN_ACCID_FIELD.full_name = ".GM_RoleLoginReturn.accid"
GM_ROLELOGINRETURN_ACCID_FIELD.number = 1
GM_ROLELOGINRETURN_ACCID_FIELD.index = 0
GM_ROLELOGINRETURN_ACCID_FIELD.label = 2
GM_ROLELOGINRETURN_ACCID_FIELD.has_default_value = false
GM_ROLELOGINRETURN_ACCID_FIELD.default_value = 0
GM_ROLELOGINRETURN_ACCID_FIELD.type = 5
GM_ROLELOGINRETURN_ACCID_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_ROLEID_FIELD.name = "roleid"
GM_ROLELOGINRETURN_ROLEID_FIELD.full_name = ".GM_RoleLoginReturn.roleid"
GM_ROLELOGINRETURN_ROLEID_FIELD.number = 2
GM_ROLELOGINRETURN_ROLEID_FIELD.index = 1
GM_ROLELOGINRETURN_ROLEID_FIELD.label = 2
GM_ROLELOGINRETURN_ROLEID_FIELD.has_default_value = false
GM_ROLELOGINRETURN_ROLEID_FIELD.default_value = 0
GM_ROLELOGINRETURN_ROLEID_FIELD.type = 5
GM_ROLELOGINRETURN_ROLEID_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_NAME_FIELD.name = "name"
GM_ROLELOGINRETURN_NAME_FIELD.full_name = ".GM_RoleLoginReturn.name"
GM_ROLELOGINRETURN_NAME_FIELD.number = 3
GM_ROLELOGINRETURN_NAME_FIELD.index = 2
GM_ROLELOGINRETURN_NAME_FIELD.label = 1
GM_ROLELOGINRETURN_NAME_FIELD.has_default_value = false
GM_ROLELOGINRETURN_NAME_FIELD.default_value = ""
GM_ROLELOGINRETURN_NAME_FIELD.type = 9
GM_ROLELOGINRETURN_NAME_FIELD.cpp_type = 9

GM_ROLELOGINRETURN_AVATAR_FIELD.name = "avatar"
GM_ROLELOGINRETURN_AVATAR_FIELD.full_name = ".GM_RoleLoginReturn.avatar"
GM_ROLELOGINRETURN_AVATAR_FIELD.number = 4
GM_ROLELOGINRETURN_AVATAR_FIELD.index = 3
GM_ROLELOGINRETURN_AVATAR_FIELD.label = 1
GM_ROLELOGINRETURN_AVATAR_FIELD.has_default_value = false
GM_ROLELOGINRETURN_AVATAR_FIELD.default_value = 0
GM_ROLELOGINRETURN_AVATAR_FIELD.type = 5
GM_ROLELOGINRETURN_AVATAR_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_EXP_FIELD.name = "exp"
GM_ROLELOGINRETURN_EXP_FIELD.full_name = ".GM_RoleLoginReturn.exp"
GM_ROLELOGINRETURN_EXP_FIELD.number = 5
GM_ROLELOGINRETURN_EXP_FIELD.index = 4
GM_ROLELOGINRETURN_EXP_FIELD.label = 1
GM_ROLELOGINRETURN_EXP_FIELD.has_default_value = false
GM_ROLELOGINRETURN_EXP_FIELD.default_value = 0
GM_ROLELOGINRETURN_EXP_FIELD.type = 3
GM_ROLELOGINRETURN_EXP_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_LEVEL_FIELD.name = "level"
GM_ROLELOGINRETURN_LEVEL_FIELD.full_name = ".GM_RoleLoginReturn.level"
GM_ROLELOGINRETURN_LEVEL_FIELD.number = 6
GM_ROLELOGINRETURN_LEVEL_FIELD.index = 5
GM_ROLELOGINRETURN_LEVEL_FIELD.label = 1
GM_ROLELOGINRETURN_LEVEL_FIELD.has_default_value = false
GM_ROLELOGINRETURN_LEVEL_FIELD.default_value = 0
GM_ROLELOGINRETURN_LEVEL_FIELD.type = 5
GM_ROLELOGINRETURN_LEVEL_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_VIPLEVEL_FIELD.name = "viplevel"
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.full_name = ".GM_RoleLoginReturn.viplevel"
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.number = 7
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.index = 6
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.label = 1
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.has_default_value = false
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.default_value = 0
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.type = 5
GM_ROLELOGINRETURN_VIPLEVEL_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_TIRED_FIELD.name = "tired"
GM_ROLELOGINRETURN_TIRED_FIELD.full_name = ".GM_RoleLoginReturn.tired"
GM_ROLELOGINRETURN_TIRED_FIELD.number = 8
GM_ROLELOGINRETURN_TIRED_FIELD.index = 7
GM_ROLELOGINRETURN_TIRED_FIELD.label = 1
GM_ROLELOGINRETURN_TIRED_FIELD.has_default_value = false
GM_ROLELOGINRETURN_TIRED_FIELD.default_value = 0
GM_ROLELOGINRETURN_TIRED_FIELD.type = 5
GM_ROLELOGINRETURN_TIRED_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_COMBAT_FIELD.name = "combat"
GM_ROLELOGINRETURN_COMBAT_FIELD.full_name = ".GM_RoleLoginReturn.combat"
GM_ROLELOGINRETURN_COMBAT_FIELD.number = 9
GM_ROLELOGINRETURN_COMBAT_FIELD.index = 8
GM_ROLELOGINRETURN_COMBAT_FIELD.label = 1
GM_ROLELOGINRETURN_COMBAT_FIELD.has_default_value = false
GM_ROLELOGINRETURN_COMBAT_FIELD.default_value = 0
GM_ROLELOGINRETURN_COMBAT_FIELD.type = 5
GM_ROLELOGINRETURN_COMBAT_FIELD.cpp_type = 1

GM_ROLELOGINRETURN_GOLD_FIELD.name = "gold"
GM_ROLELOGINRETURN_GOLD_FIELD.full_name = ".GM_RoleLoginReturn.gold"
GM_ROLELOGINRETURN_GOLD_FIELD.number = 10
GM_ROLELOGINRETURN_GOLD_FIELD.index = 9
GM_ROLELOGINRETURN_GOLD_FIELD.label = 1
GM_ROLELOGINRETURN_GOLD_FIELD.has_default_value = false
GM_ROLELOGINRETURN_GOLD_FIELD.default_value = 0
GM_ROLELOGINRETURN_GOLD_FIELD.type = 3
GM_ROLELOGINRETURN_GOLD_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_COIN_FIELD.name = "coin"
GM_ROLELOGINRETURN_COIN_FIELD.full_name = ".GM_RoleLoginReturn.coin"
GM_ROLELOGINRETURN_COIN_FIELD.number = 11
GM_ROLELOGINRETURN_COIN_FIELD.index = 10
GM_ROLELOGINRETURN_COIN_FIELD.label = 1
GM_ROLELOGINRETURN_COIN_FIELD.has_default_value = false
GM_ROLELOGINRETURN_COIN_FIELD.default_value = 0
GM_ROLELOGINRETURN_COIN_FIELD.type = 3
GM_ROLELOGINRETURN_COIN_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_CHIP_FIELD.name = "chip"
GM_ROLELOGINRETURN_CHIP_FIELD.full_name = ".GM_RoleLoginReturn.chip"
GM_ROLELOGINRETURN_CHIP_FIELD.number = 12
GM_ROLELOGINRETURN_CHIP_FIELD.index = 11
GM_ROLELOGINRETURN_CHIP_FIELD.label = 1
GM_ROLELOGINRETURN_CHIP_FIELD.has_default_value = false
GM_ROLELOGINRETURN_CHIP_FIELD.default_value = 0
GM_ROLELOGINRETURN_CHIP_FIELD.type = 3
GM_ROLELOGINRETURN_CHIP_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_CREATETIME_FIELD.name = "createtime"
GM_ROLELOGINRETURN_CREATETIME_FIELD.full_name = ".GM_RoleLoginReturn.createtime"
GM_ROLELOGINRETURN_CREATETIME_FIELD.number = 13
GM_ROLELOGINRETURN_CREATETIME_FIELD.index = 12
GM_ROLELOGINRETURN_CREATETIME_FIELD.label = 1
GM_ROLELOGINRETURN_CREATETIME_FIELD.has_default_value = false
GM_ROLELOGINRETURN_CREATETIME_FIELD.default_value = 0
GM_ROLELOGINRETURN_CREATETIME_FIELD.type = 3
GM_ROLELOGINRETURN_CREATETIME_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.name = "last_login_time"
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.full_name = ".GM_RoleLoginReturn.last_login_time"
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.number = 14
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.index = 13
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.label = 1
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.has_default_value = false
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.default_value = 0
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.type = 3
GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.name = "last_logout_time"
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.full_name = ".GM_RoleLoginReturn.last_logout_time"
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.number = 15
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.index = 14
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.label = 1
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.has_default_value = false
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.default_value = 0
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.type = 3
GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_SERVER_TIME_FIELD.name = "server_time"
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.full_name = ".GM_RoleLoginReturn.server_time"
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.number = 16
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.index = 15
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.label = 1
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.has_default_value = false
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.default_value = 0
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.type = 3
GM_ROLELOGINRETURN_SERVER_TIME_FIELD.cpp_type = 2

GM_ROLELOGINRETURN_ISNEW_FIELD.name = "isnew"
GM_ROLELOGINRETURN_ISNEW_FIELD.full_name = ".GM_RoleLoginReturn.isnew"
GM_ROLELOGINRETURN_ISNEW_FIELD.number = 17
GM_ROLELOGINRETURN_ISNEW_FIELD.index = 16
GM_ROLELOGINRETURN_ISNEW_FIELD.label = 1
GM_ROLELOGINRETURN_ISNEW_FIELD.has_default_value = false
GM_ROLELOGINRETURN_ISNEW_FIELD.default_value = false
GM_ROLELOGINRETURN_ISNEW_FIELD.type = 8
GM_ROLELOGINRETURN_ISNEW_FIELD.cpp_type = 7

GM_ROLELOGINRETURN.name = "GM_RoleLoginReturn"
GM_ROLELOGINRETURN.full_name = ".GM_RoleLoginReturn"
GM_ROLELOGINRETURN.nested_types = {}
GM_ROLELOGINRETURN.enum_types = {}
GM_ROLELOGINRETURN.fields = {GM_ROLELOGINRETURN_ACCID_FIELD, GM_ROLELOGINRETURN_ROLEID_FIELD, GM_ROLELOGINRETURN_NAME_FIELD, GM_ROLELOGINRETURN_AVATAR_FIELD, GM_ROLELOGINRETURN_EXP_FIELD, GM_ROLELOGINRETURN_LEVEL_FIELD, GM_ROLELOGINRETURN_VIPLEVEL_FIELD, GM_ROLELOGINRETURN_TIRED_FIELD, GM_ROLELOGINRETURN_COMBAT_FIELD, GM_ROLELOGINRETURN_GOLD_FIELD, GM_ROLELOGINRETURN_COIN_FIELD, GM_ROLELOGINRETURN_CHIP_FIELD, GM_ROLELOGINRETURN_CREATETIME_FIELD, GM_ROLELOGINRETURN_LAST_LOGIN_TIME_FIELD, GM_ROLELOGINRETURN_LAST_LOGOUT_TIME_FIELD, GM_ROLELOGINRETURN_SERVER_TIME_FIELD, GM_ROLELOGINRETURN_ISNEW_FIELD}
GM_ROLELOGINRETURN.is_extendable = false
GM_ROLELOGINRETURN.extensions = {}
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.name = "property"
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.full_name = ".GM_Commonint32ChangeNotify.property"
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.number = 1
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.index = 0
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.label = 2
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.has_default_value = false
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.default_value = 0
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.type = 5
GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD.cpp_type = 1

GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.name = "value"
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.full_name = ".GM_Commonint32ChangeNotify.value"
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.number = 2
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.index = 1
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.label = 2
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.has_default_value = false
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.default_value = 0
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.type = 5
GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD.cpp_type = 1

GM_COMMONINT32CHANGENOTIFY.name = "GM_Commonint32ChangeNotify"
GM_COMMONINT32CHANGENOTIFY.full_name = ".GM_Commonint32ChangeNotify"
GM_COMMONINT32CHANGENOTIFY.nested_types = {}
GM_COMMONINT32CHANGENOTIFY.enum_types = {}
GM_COMMONINT32CHANGENOTIFY.fields = {GM_COMMONINT32CHANGENOTIFY_PROPERTY_FIELD, GM_COMMONINT32CHANGENOTIFY_VALUE_FIELD}
GM_COMMONINT32CHANGENOTIFY.is_extendable = false
GM_COMMONINT32CHANGENOTIFY.extensions = {}
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.name = "property"
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.full_name = ".GM_CommonLONG64ChangeNotify.property"
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.number = 1
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.index = 0
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.label = 2
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.has_default_value = false
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.default_value = 0
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.type = 5
GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD.cpp_type = 1

GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.name = "value"
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.full_name = ".GM_CommonLONG64ChangeNotify.value"
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.number = 2
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.index = 1
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.label = 2
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.has_default_value = false
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.default_value = 0
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.type = 3
GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD.cpp_type = 2

GM_COMMONLONG64CHANGENOTIFY.name = "GM_CommonLONG64ChangeNotify"
GM_COMMONLONG64CHANGENOTIFY.full_name = ".GM_CommonLONG64ChangeNotify"
GM_COMMONLONG64CHANGENOTIFY.nested_types = {}
GM_COMMONLONG64CHANGENOTIFY.enum_types = {}
GM_COMMONLONG64CHANGENOTIFY.fields = {GM_COMMONLONG64CHANGENOTIFY_PROPERTY_FIELD, GM_COMMONLONG64CHANGENOTIFY_VALUE_FIELD}
GM_COMMONLONG64CHANGENOTIFY.is_extendable = false
GM_COMMONLONG64CHANGENOTIFY.extensions = {}
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.name = "property"
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.full_name = ".GM_CommonfloatChangeNotify.property"
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.number = 1
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.index = 0
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.label = 2
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.has_default_value = false
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.default_value = 0
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.type = 5
GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD.cpp_type = 1

GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.name = "value"
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.full_name = ".GM_CommonfloatChangeNotify.value"
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.number = 2
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.index = 1
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.label = 2
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.has_default_value = false
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.default_value = 0.0
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.type = 2
GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD.cpp_type = 6

GM_COMMONFLOATCHANGENOTIFY.name = "GM_CommonfloatChangeNotify"
GM_COMMONFLOATCHANGENOTIFY.full_name = ".GM_CommonfloatChangeNotify"
GM_COMMONFLOATCHANGENOTIFY.nested_types = {}
GM_COMMONFLOATCHANGENOTIFY.enum_types = {}
GM_COMMONFLOATCHANGENOTIFY.fields = {GM_COMMONFLOATCHANGENOTIFY_PROPERTY_FIELD, GM_COMMONFLOATCHANGENOTIFY_VALUE_FIELD}
GM_COMMONFLOATCHANGENOTIFY.is_extendable = false
GM_COMMONFLOATCHANGENOTIFY.extensions = {}
GM_ROLEINFO_ROLEID_FIELD.name = "roleid"
GM_ROLEINFO_ROLEID_FIELD.full_name = ".GM_RoleInfo.roleid"
GM_ROLEINFO_ROLEID_FIELD.number = 1
GM_ROLEINFO_ROLEID_FIELD.index = 0
GM_ROLEINFO_ROLEID_FIELD.label = 2
GM_ROLEINFO_ROLEID_FIELD.has_default_value = false
GM_ROLEINFO_ROLEID_FIELD.default_value = 0
GM_ROLEINFO_ROLEID_FIELD.type = 5
GM_ROLEINFO_ROLEID_FIELD.cpp_type = 1

GM_ROLEINFO_NAME_FIELD.name = "name"
GM_ROLEINFO_NAME_FIELD.full_name = ".GM_RoleInfo.name"
GM_ROLEINFO_NAME_FIELD.number = 2
GM_ROLEINFO_NAME_FIELD.index = 1
GM_ROLEINFO_NAME_FIELD.label = 2
GM_ROLEINFO_NAME_FIELD.has_default_value = false
GM_ROLEINFO_NAME_FIELD.default_value = ""
GM_ROLEINFO_NAME_FIELD.type = 9
GM_ROLEINFO_NAME_FIELD.cpp_type = 9

GM_ROLEINFO_LEVEL_FIELD.name = "level"
GM_ROLEINFO_LEVEL_FIELD.full_name = ".GM_RoleInfo.level"
GM_ROLEINFO_LEVEL_FIELD.number = 3
GM_ROLEINFO_LEVEL_FIELD.index = 2
GM_ROLEINFO_LEVEL_FIELD.label = 2
GM_ROLEINFO_LEVEL_FIELD.has_default_value = false
GM_ROLEINFO_LEVEL_FIELD.default_value = 0
GM_ROLEINFO_LEVEL_FIELD.type = 5
GM_ROLEINFO_LEVEL_FIELD.cpp_type = 1

GM_ROLEINFO.name = "GM_RoleInfo"
GM_ROLEINFO.full_name = ".GM_RoleInfo"
GM_ROLEINFO.nested_types = {}
GM_ROLEINFO.enum_types = {}
GM_ROLEINFO.fields = {GM_ROLEINFO_ROLEID_FIELD, GM_ROLEINFO_NAME_FIELD, GM_ROLEINFO_LEVEL_FIELD}
GM_ROLEINFO.is_extendable = false
GM_ROLEINFO.extensions = {}

GM_CommonLONG64ChangeNotify = protobuf.Message(GM_COMMONLONG64CHANGENOTIFY)
GM_CommonfloatChangeNotify = protobuf.Message(GM_COMMONFLOATCHANGENOTIFY)
GM_Commonint32ChangeNotify = protobuf.Message(GM_COMMONINT32CHANGENOTIFY)
GM_Role = protobuf.Message(GM_ROLE)
GM_RoleInfo = protobuf.Message(GM_ROLEINFO)
GM_RoleLogin = protobuf.Message(GM_ROLELOGIN)
GM_RoleLoginReturn = protobuf.Message(GM_ROLELOGINRETURN)

