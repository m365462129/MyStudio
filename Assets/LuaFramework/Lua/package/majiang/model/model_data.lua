--
-- User: dred
-- Date: 2016/12/3
-- Time: 21:18
-- package中的内部数据

local ModelData = { }

local roleData = { }
roleData.hasBindInviteCode = nil          -- 是否绑定了邀请码
roleData.userID = nil
roleData.password = nil
roleData.GameName = nil
ModelData.roleData = { }

local shareData = { };
-- 是否分享了朋友圈或者是好友圈
shareData.isShare = false;
ModelData.shareData = shareData;

local hallData = { };
-- 活动列表
hallData.activityList = nil;
--金币场数据
hallData.goldData = {}
-- 牌桌的一般数据
local tableCommonData = {}
tableCommonData.isGoldTable = nil
tableCommonData.isGoldSettle = nil
tableCommonData.isGoldUnlimited = nil
tableCommonData.isGoldMatchingTable = nil
tableCommonData.isGoldFriendTable = nil

--金币场点击记录
hallData.goldClickRecord = {};
hallData.normalProvinceId = nil;
hallData.normalGameId = nil;

ModelData.hallData = hallData;
ModelData.tableCommonData = tableCommonData
local AppGlobalConfig = { }
AppGlobalConfig.alipay_enable = false
AppGlobalConfig.card_conis = 0
AppGlobalConfig.cards_config = { }
AppGlobalConfig.coin_price = 0
AppGlobalConfig.log_enable = false
AppGlobalConfig.sys_ads = { }
AppGlobalConfig.wechatpay_enable = false
ModelData.AppGlobalConfig = AppGlobalConfig

ModelData.curTableData = nil
-- 当开启审核显示房卡
ModelData.consumeProductName = "钻石"

function ModelData.reset()
    local roleData = { }
    roleData.hasBindInviteCode = nil
    -- 是否绑定了邀请码
    roleData.userID = nil
    roleData.password = nil
    roleData.GameName = nil
    ModelData.roleData = { }
    local AppGlobalConfig = { }

    AppGlobalConfig.alipay_enable = false
    AppGlobalConfig.card_conis = 0
    AppGlobalConfig.cards_config = { }
    AppGlobalConfig.coin_price = 0
    AppGlobalConfig.log_enable = false
    AppGlobalConfig.sys_ads = { }
    AppGlobalConfig.wechatpay_enable = false
    ModelData.AppGlobalConfig = AppGlobalConfig
    ModelData.curTableData = nil

    local shareData = { };
    shareData.isShare = false;
    ModelData.shareData = shareData;

    local hallData = { };
    hallData.activityList = nil;
    hallData.goldData = {};
    hallData.goldClickRecord = {};
    hallData.normalProvinceId = nil;
    hallData.normalGameId = nil;
    ModelData.hallData = hallData;

    ModelData.tableCommonData = {}
end

return ModelData