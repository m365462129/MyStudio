---------------------------------------------------------------------------------------------------
-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: HallModule
-- ===============================================================================================--
---------------------------------------------------------------------------------------------------
local class = require("lib.middleclass")
local Module = require("core.mvvm.module_base")

--- @class HallModule : Module
--- @field view HallView
--- @field hallView HallView
--- @field hallModel HallModel
--- @field model HallModel
local HallModule = class("hallModule", Module)

local ModuleCache = ModuleCache
local ModuleManager = ModuleCache.ModuleManager
local Sequence = DG.Tweening.DOTween.Sequence
local CSmartTimer = ModuleCache.SmartTimer.instance
local onAppFocusCallback;
local PlayerPrefs = UnityEngine.PlayerPrefs
local billboard_prefsKey = "billboard_data"
local Time = UnityEngine.Time
local audioMusic = ModuleCache.SoundManager.audioMusic
local bgMusic1 = "bgmfight1"
local bgMusic2 = "bgmfight2"
local PlayModeUtil = ModuleCache.PlayModeUtil
local EaseLinear = DG.Tweening.Ease.Linear

function HallModule:initialize(...)
    -- 开始初始化
    Module.initialize(self, "hall_view", "hall_model", ...)

    self.playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
    local list = require("list")
    -- 需要按照权重来播放,从1、2、3、4开始，还有触发的时间等等都要重新排序
    self._systemAnnounceContents = list:new()
    if (not self.modelData.noticeData) then
        self.modelData.noticeData = { }
    end
    onAppFocusCallback = function(eventHead, state)
        if not self.hallView:is_active() then
            return
        end

        if state then
            self:getUserNewMessage()
            self:get_app_asset_data_info()
            self:process_mwenter()
            if ModuleCache.GameSDKInterface:GetCurSignalType() ~= self._lastSignalType then
                self._lastSignalType = ModuleCache.GameSDKInterface:GetCurSignalType()
                self.modelData.roleData.ip = ""
                self.hallModel:get_adcontentinfo(true)
            end
        else
            self._lastSignalType = ModuleCache.GameSDKInterface:GetCurSignalType()
        end
    end
    
    ModuleCache.WechatManager.registMWEnterRoomCallback(function()
        self:process_mwenter()
    end)

    self:subscibe_app_focus_event(onAppFocusCallback)

    self._lastSignalType = ModuleCache.GameSDKInterface:GetCurSignalType()
    onAppFocusCallback(nil, true)

    self:subscibe_time_event(0.5, false, 0):OnComplete( function(...)
        self:process_mwenter()
    end )

    -- 大厅中更新位置信息
    self:begin_location()

    self:isShowHongBaoHuoDong()

    ModuleCache.ModuleManager.destroy_module("henanmj", "login")
end

--- 处理进入房间的BUG
function HallModule:process_mwenter()
    local mwData = ModuleCache.GameManager.get_mw_data(ModuleCache.GameSDKCallback.instance.mwEnterRoomID)
    if mwData then
        ModuleCache.FunctionManager.ClearClipBoard()
        if mwData.appName and mwData.appName ~= ModuleCache.AppData.get_app_name() then
            if ModuleCache.GameManager.change_game_buy_appName_gameName(mwData.appName, mwData.gameName) then
                if self.isOnShowFinish then
                    ModuleCache.GameManager.logout()
                else
                    self.isNeedLogOut = true
                end
            end
        else
            ModuleCache.GameSDKCallback.instance.mwEnterRoomID = "0"
            if mwData.appGameName and mwData.appGameName ~= "" then
                local curGameId = ModuleCache.GameManager.curGameId
                local curProvince = ModuleCache.GameManager.curProvince
                ModuleCache.GameManager.change_game_by_gameName(mwData.appGameName)
                if curGameId ~= ModuleCache.GameManager.curGameId or curProvince ~= ModuleCache.GameManager.curProvince then
                    self:dispatch_package_event("Event_Set_Play_Mode", nil)
                end
            end

            if mwData.roomId then
                local roomId = mwData.roomId
                -- 解决通过分享链接进入牌桌时，没有加入亲友圈时不会切到对应的游戏玩法中
                if mwData.appGameName and mwData.appGameName ~= "" then
                    local curGameId = ModuleCache.GameManager.curGameId
                    local curProvince = ModuleCache.GameManager.curProvince
                    ModuleCache.GameManager.change_game_by_gameName(mwData.appGameName)
                    if curGameId ~= ModuleCache.GameManager.curGameId or curProvince ~= ModuleCache.GameManager.curProvince then
                        self:dispatch_package_event("Event_Set_Play_Mode", nil)
                    end
                end

                -- 如果有赋值亲友圈号，那么就用亲友圈
                if mwData.parlorId and #tostring(mwData.parlorId) > 2 and mwData.roomType == 2 then
                    roomId = mwData.parlorId
                end
                local roomIdStr = tostring(roomId)
                local gameID = 0
                local gameName = ""
                if #roomIdStr > 6 then
                    local len = #roomIdStr
                    gameID = tonumber(roomIdStr:sub(len - 5, len))
                    gameName = ModuleCache.PlayModeUtil.getInfoByGameId(gameID).createName
                    roomId = roomIdStr:sub(1, len - 6)
                end

                if mwData.goldId and mwData.goldId ~= 0 and self.playMode and self.playMode.isOpenGold then
                    self:goldClick()
                end

                print(tonumber(roomId),"--------process_mwenter-------------------",gameName,mwData.gameName_full)
                if tostring(gameName):find("|") ~= nil then
                    TableManager:join_room(tonumber(roomId), mwData.gameName_full, nil, nil, mwData)
                else
                    TableManager:join_room(tonumber(roomId), gameName, nil, nil, mwData)
                end
            end
        end
    end
end


function HallModule:getUserNewMessage()

    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "msg/getNewMsg?",
        params =
        {
            uid = self.modelData.roleData.userID,
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        print_table(retData)
        if retData.ret == 0 then
            local data = retData.data
            self.modelData.roleData.cards = data.cards
            self.modelData.roleData.gold = data.gold
            if (self.modelData.roleData.nickname) then
                self.hallView:refreshPlayerInfo(self.modelData.roleData)
            end
            if (data.msg) then
                if data.msgType == 6 then
                    self:dispatch_package_event("Event_Buy_Complete", retData)
                else
                    ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button(data.msg)
                end
            end
        else

        end
    end , function(errorData)
        print(errorData.error)
    end )
end



function HallModule:on_destroy()
    ModuleCache.ModuleManager.destroy_module("public", "redpacket")
    ModuleCache.ModuleManager.destroy_module("public", "activity")
    ModuleCache.ModuleManager.destroy_module("public", "activity_redpacket")
    -- 大厅中的红包与大厅模块共存亡

    -- UpdateBeat:Remove(self.UpdateBeat, self)
    self:stop_auto_play_adcontent()
    ModuleCache.WechatManager.registMWEnterRoomCallback(nil)
end

function HallModule:on_update()
    if ModuleCache.GameManager.customOsType == 1 and ModuleCache.UnityEngine.Input.GetKeyDown(ModuleCache.UnityEngine.KeyCode.Escape) then
        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您确定要退出游戏？"), function()
            ModuleCache.UnityEngine.Application.Quit()
        end , nil)
    end
    -- if self.lastUpdateBeatTime + 1 > Time.realtimeSinceStartup then
    --    return
    -- end
    -- self.lastUpdateBeatTime = Time.realtimeSinceStartup


end

function HallModule:on_update_per_second()
    if (not self.view:is_active()) then
        return
    end
    if (not audioMusic.isPlaying) then
        if ((not audioMusic.clip) or audioMusic.clip.name ~= bgMusic1) then
            ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic1 .. ".bytes", bgMusic1)
        else
            ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic2 .. ".bytes", bgMusic2)
        end
    elseif (audioMusic.clip.name ~= bgMusic1) then
        ModuleCache.SoundManager.play_music("henanmj", "henanmj/sound/bgmmusic/" .. bgMusic1 .. ".bytes", bgMusic1)
    end
end


function HallModule:start_auto_play_adcontent()
    self.autoPlayAdTimeEventID = self:subscibe_time_event(3, false, 0):OnComplete( function(t)
        if (self.hallView.adContentInfo.isDraging) then
            return
        end

        if (self.hallView.lastIndex == 1) then
            self.auto_play_offset = 1
        elseif (self.hallView.lastIndex == #self.hallView.adContentInfo.pageSelectImageArray) then
            self.auto_play_offset = -1
        end
        if (not self.auto_play_offset) then
            self.auto_play_offset = 1
        end

        self.hallView.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition = self.hallView.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition + 0.01 * self.auto_play_offset

        self.hallView:onBeginDragAdContent()
        self.hallView:onEndDragAdContent(self.auto_play_offset)
        self:stop_auto_play_adcontent()
        self:start_auto_play_adcontent()
    end ).id
end

function HallModule:stop_auto_play_adcontent()
    if (self.autoPlayAdTimeEventID) then
        CSmartTimer:Kill(self.autoPlayAdTimeEventID)
        self.autoPlayAdTimeEventID = nil
    end
end

function HallModule:check_need_show_billboard(data)
    local newBillBoardData = self:find_billboardContent(data)
    local oldBillBoardData = self:find_billboardContent(self.modelData.noticeData[AppData.Game_Name])
    if (not oldBillBoardData) then
        oldBillBoardData = { }
        oldBillBoardData.content = UnityEngine.PlayerPrefs.GetString(billboard_prefsKey .. '_' .. AppData.Game_Name, "")
    end
    if (not newBillBoardData) then
        return
    end

    UnityEngine.PlayerPrefs.SetString(billboard_prefsKey .. '_' .. AppData.Game_Name, newBillBoardData.content)

    if (not ModuleCache.GameManager.iosAppStoreIsCheck and oldBillBoardData.content ~= newBillBoardData.content) then
        ModuleCache.ModuleManager.show_module("henanmj", "billboard", newBillBoardData.content)
        return
    end
end


function HallModule:find_billboardContent(data)
    if (not data) then
        return nil
    end
    for i, v in ipairs(data) do
        if (v.noticekey == "popnotice") then
            return v
        end
    end
    return nil
end

-- 绑定model层事件，模块内交互    model层初始化结束后自动调用
function HallModule:on_model_event_bind()
    self:subscibe_model_event("Event_Hall_GetUserInfo", function(eventHead, eventData)
        -- 监听model层的事件反馈，事件头、事件数据
        if (eventData.ret == 0) then
            self.hallView:refreshPlayerInfo(self.modelData.roleData)
            self:dispatch_package_event("Event_Package_GetUserInfo", self.modelData.roleData)
        end
    end )

    self:subscibe_model_event("Event_Hall_GetAppGlobalConfig", function(eventHead, eventData)
        -- 监听model层的事件反馈，事件头、事件数据
        if (eventData.err) then
            -- self.hallModel:get_adcontentinfo()
        else
            -- self.hallView:refreshAdContent(self.modelData.AppGlobalConfig.sys_ads)
            -- self:start_auto_play_adcontent()
        end
    end )

    self:subscibe_model_event("Event_Hall_GetActivityList", function(eventHead, eventData)
        
        -- 监听model层的事件反馈，事件头、事件数据
        local activityList = self.modelData.hallData.activityList;

        if activityList == nil then
            self.view.buttonFreeDiamond.gameObject:SetActive(false);
        else
             -- 更新奖励视图
            self.hallView:updateRewardView(activityList, "share");
        end

    end )
    -- 实名认证状态获取回包
    self:subscibe_model_event("Event_Hall_GetVerifyStatus", function(eventHead, eventData)
        if eventData then
            self.view:updateVerifyStatus(self.modelData.hallData.verifyData.status == 0)
        end
    end )

    -- 实名认证状态获取回包
    self:subscibe_model_event("Event_Hall_GetMainRedPoint", function(eventHead, eventData)
        -- 更新主界面红点(此方法目前只有背包)
        self.view:updateMainRedPoint(eventData);
    end )


end

function HallModule:on_module_event_bind()
    self:subscibe_package_event("Event_Package_Refresh_Userinfo", function(eventHead, eventData)
        self.hallView:refreshPlayerInfo(self.modelData.roleData)
    end )

    self:subscibe_module_event("hall", "Event_refresh_userinfo", function(eventHead, eventData)
        print("subscibe_module_event -------------")
        self.hallView:refreshPlayerInfo(self.modelData.roleData)
        self:process_mwenter()
    end )

    self:subscibe_module_event("hall", "Event_Hall_GetActivityList", function(eventHead, eventData)
        if activityList == nil then
            self.view.buttonFreeDiamond.gameObject:SetActive(false);
        else
             -- 更新奖励视图
            self.hallView:updateRewardView(activityList, "share");
        end
    end )

    self:subscibe_package_event("Event_Package_VerifyStatus", function(eventHead, eventData)
        -- 更新实名认证状态
        print("更新实名认证状态", self.modelData.hallData.verifyData.status)
        self.model:get_userinfo()
        self.view:updateVerifyStatus(self.modelData.hallData.verifyData.status == 0)
    end )

    self:subscibe_package_event("Event_Set_Play_Mode", function(eventHead, eventData)
        if eventData then
            self.playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
            self:on_show()
        end

    end )
    self:subscibe_package_event("Event_Package_NeedRefreshUserInfo", function(eventHead, eventData)
        self.hallModel:get_userinfo()
    end)
    self:subscibe_package_event("Event_Show_Hall_Anim", function(eventHead, eventData)
        self.view.root:SetActive(false)
        self.view.root:SetActive(true)
    end )

    self:subscibe_package_event("Event_Refresh_Red_Status", function(eventHead, eventData)
        self:updateRedInfo(eventData)
    end )

    -- 刷新大厅背包红点
    self:subscibe_package_event("Event_Refresh_Bag_Red", function(eventHead, eventData)
        -- 请求大厅红点协议
        self.hallModel:getMainRedPoint();
    end )
end

function HallModule:on_module_inited()
    self.view:show(true)
end

function HallModule:on_show(intentData)
    if (self.isDestroy) then
        return
    end
    -- 请求大厅红点协议
    self.hallModel:getMainRedPoint();


    ModuleCache.ModuleManager.show_module("public", "redpacket")
    -- 大厅中的红包与大厅模块共存亡
    ModuleCache.UnityEngine.Application.targetFrameRate = 30
    self.hallModel:get_userinfo()
    self.hallView:refreshPlayerInfo(self.modelData.roleData)

    if ModuleCache.GameManager.iosAppStoreIsCheck then
        self.isOnShowFinish = true
        return
    end

    self.hallModel:get_notice_list( function(data)
        if self.isDestroy then
            return
        end

        self.modelData.noticeData[AppData.Game_Name] = data
        self:remove_all_announce()
        for i = 1, #data do
            if (data[i].noticekey == "notice") then
                --self:add_system_announce(data[i].content, true, 0)
            end
            if (data[i].noticekey == "parlor") then
                self.modelData.parlorWeiXin = data[i].content
                --local showMuseum = PlayerPrefs.GetInt("showMuseum", 0)
                --if (showMuseum == 1) then
                --    self:get_museum_list()
                --end
            end
        end
    end )

    if ( PlayerPrefs.GetInt("showMuseum", 0) == 1) then
        self:get_museum_list()
    end

    -- 这个一定不能注释掉的
    self.hallModel:get_adcontentinfo();

    self:get_app_asset_data_info();

    self.hallView:refreshPlayMode()


    self.modelData.hallData.activityList = nil;
    self.modelData.shareData.isShare = false;
    -- 请求获取活动奖励协议
    self.hallModel:getActivityList();
    -- 获取实名认证数据
    self.hallModel:getVerrifyStatus();

    -- ios过审模式
    if ModuleCache.GameManager.iosAppStoreIsCheck then

        self.view.buttonActivity.gameObject:SetActive(false);
        -- self.view.buttonBillboard.gameObject:SetActive(false);
    else
        self.view.buttonActivity.gameObject:SetActive(true);
        -- self.view.buttonBillboard.gameObject:SetActive(false);
        -- 打开活动界面
        local object = 
        {
        showRegionType = "hall",
        showType="Auto",
        }
        ModuleCache.ModuleManager.show_public_module("activity", object);
    end
    self.isOnShowFinish = true
    if self.isNeedLogOut then
        ModuleCache.GameManager.logout()
    end

    self:get_shop_products(6,function(data)
        if data.isBindInvite and #data.discountProducts > 0 then
            self.modelData.isHaveShopPackge = true
        elseif (not data.isBindInvite) and #data.products > 0 then
            self.modelData.isHaveShopPackge = true
        else
            self.modelData.isHaveShopPackge = false
        end
    end)

    local hallLastOpenHall = ModuleCache.UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_LAST_HALL_OPEN_MODULE, "");
    print("===上一次打开的模块====", hallLastOpenHall)
    if hallLastOpenHall ~= "" then
        hallLastOpenHall = string.split(hallLastOpenHall, '_')
        ModuleCache.ModuleManager.show_module(hallLastOpenHall[1], hallLastOpenHall[2])
    end


    self:isShowHongBaoHuoDong()
end


function HallModule:get_app_asset_data_info()
    if ModuleCache.GameManager.lockAssetUpdate then
        return
    end
    ModuleCache.GameManager.get_app_asset_data_info( function(appAssetVersionUpdateData)
        if self.isDestroy then
            -- 要注意缓存回调时有可能view已经销毁了
            return
        end
        --print_table(appAssetVersionUpdateData)
        if appAssetVersionUpdateData.appData then
            if ModuleCache.GameManager.deviceIsMobile and appAssetVersionUpdateData.appData.forceUpgrade and appAssetVersionUpdateData.appData.forceUpgrade == 1 then
                -- 是否强制更新
                ModuleCache.GameManager.logout()
            end
            self.hallView.goUpdateVersionBubble:SetActive(true)
        else
            local config = PlayModeUtil.getInfoByGameId(ModuleCache.GameManager.curGameId)
            --先全部强制更新吧 and appAssetVersionUpdateData.assetData.isForceUpdate
            if ModuleCache.GameManager.deviceIsMobile and appAssetVersionUpdateData.assetData then
                -- 是否强制更新
                if config then
                    ModuleCache.PackageManager.update_package_version(config.package, function()
                    end)
                end
            end
                local updatePackageAssetData = ModuleCache.PackageManager.get_app_package_update_info("public")
                if not updatePackageAssetData and config then
                    updatePackageAssetData = ModuleCache.PackageManager.get_app_package_update_info(config.package)
                end
                self.hallView.goUpdateVersionBubble:SetActive(false)
        end
    end)
end



function HallModule:on_begin_drag(obj, arg)
    if (obj.name == "ad_item") then
        self:stop_auto_play_adcontent()
        self.hallView:onBeginDragAdContent(obj, arg)
    end
end

function HallModule:on_drag(obj, arg)
    self.hallView:onDragAdContent(obj, arg)
end

function HallModule:on_end_drag(obj, arg)
    if (self.view and obj.name == "ad_item") then
        self.hallView:onEndDragAdContent(nil, obj, arg)
        self:start_auto_play_adcontent()
    end
end

-- 点击事件 因为效率的问题不能用C#中绑定Button的方式，
function HallModule:on_click(obj, arg)
    local _cmd = obj.name
    print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    self:dispatch_module_event("login", "hall_show", "hall_show")
    if "ad_item" == _cmd then
        local gameObjectArray = self.hallView.adContentInfo.gameObjectAds
        for i = 1, #gameObjectArray do
            if (obj == gameObjectArray[i]) then
                local adInfo = self.hallView.adContentInfo.ads[i]
                if adInfo.link and adInfo.link ~= "" then
                    ModuleCache.ModuleManager.show_module("henanmj", "webview", { link = adInfo.link, showType = 0 })
                end
                return
            end
        end
    elseif obj == self.view.buttonCreateRoom.gameObject then
        local sendData = {
            showType = 1,
            clickType = 1,
            data = nil
        }
        local str = self.playMode.package
        ModuleCache.ModuleManager.show_module("henanmj", "createroom", sendData)
    elseif obj == self.view.buttonJoinRoom.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "joinroom", { mode = 1 })
    elseif obj == self.view.buttonCheckResult.gameObject then
        self:getHistoryList()
    elseif obj == self.view.buttonShare.gameObject then
        local share = ModuleCache.ModuleManager.show_module("henanmj", "share","hall")

        -- elseif obj == self.view.buttonPlayingInstrution.gameObject then
        --    local str = self.playMode.package
        --    ModuleCache.ModuleManager.show_module("henanmj", "howtoplay", nil)
        -- 个人信息按钮
    elseif obj == self.view.buttonSetting.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "setting")
        -- elseif obj == self.view.buttonBillboard.gameObject then
        --    local content = UnityEngine.PlayerPrefs.GetString(billboard_prefsKey .. '_' .. AppData.Game_Name, "")
        --    ModuleCache.ModuleManager.show_module("henanmj", "billboard", content)
    elseif obj == self.view.buttonRanking.gameObject then
        if self.playMode.isOpenGold then
            ModuleCache.ModuleManager.show_module("henanmj", "rank");
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
        end
        --幸运转盘
    elseif obj == self.view.buttonLucky.gameObject then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
        --比赛场
    elseif obj == self.view.buttonMatch.gameObject then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
        -- 活动按钮
    elseif obj == self.view.buttonActivity.gameObject then
       local object = 
        {
        showRegionType = "hall",
        showType="Manual",
        }
        ModuleCache.ModuleManager.show_public_module("activity", object);
        -- 免费领钻按钮
    elseif obj == self.view.buttonFreeDiamond.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "freediamond");
        -- 红白雨按钮
    elseif _cmd == "ActivityHongBao" then
        local redpacket = ModuleCache.ModuleManager.get_module("public", "redpacket")
        if redpacket then
            redpacket:hall_click_redpacket()
        end
        -- 实名认证按钮
    elseif obj == self.view.buttonVerify.gameObject then
        if self.modelData.hallData.verifyData.status == 0 then
            ModuleCache.ModuleManager.show_module("public", "verifyname", self.modelData.hallData.verifyData.coins);
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("您已实名认证，无需再次实名认证！")
        end
        -- 客服按钮
    elseif obj == self.view.buttonCustomerService.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "customerservice");
        -- 背包按钮
    elseif obj == self.view.buttonBag.gameObject then
        local data =
        {
            showType = 1,
        };
        ModuleCache.ModuleManager.show_module("public", "bag", data);

    elseif obj == self.view.buttonRole.gameObject then
        -- ModuleCache.ModuleManager.show_module("henanmj", "setting")
        local data = {
            showType = 1,
            uid = self.modelData.roleData.userID,
        }
        ModuleCache.ModuleManager.show_module("henanmj", "playerinfodetail", data)
    elseif obj == self.view.buttonAddRoomCard.gameObject or obj == self.view.buttonShop.gameObject then
        ModuleCache.ModuleManager.show_module("henanmj", "shop",2)
    elseif obj.name == "Gold" then
        ModuleCache.ModuleManager.show_module("henanmj", "shop",5)
    elseif (obj.name == "PaiYouQuan") then
        print("-------------------")
        self:get_museum_list(true)
    elseif (obj.name == "Switch") then
       -- ModuleCache.ModuleManager.show_module('henanmj', "setplaymode", ModuleCache.GameManager.curProvince)
        ModuleCache.ModuleManager.show_public_module("operate", true);
    elseif (obj.name == "buttonHongBaoHuoDong") then
        local url = self.HongBaoHuoDongUrl
        local data = {
            link = url,
            showType = 0,
            style = 2
        }
        ModuleCache.ModuleManager.show_module("henanmj", "webview", data);
    elseif (obj.name == "Quit") then
--        ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common("确定退出游戏？", function()
--            UnityEngine.Application.Quit()
--        end , nil, false)         
            ModuleCache.ModuleManager.show_public_module("operate");
    elseif (obj.name == "GoldBtn") then
        if self.playMode and self.playMode.isOpenGold then
            if ModuleCache.GameManager.player_switch_majiang3D() then
                ModuleCache.PackageManager.update_package_version("majiang3d", function()
                    ModuleCache.ModuleManager.show_module("public", "goldentrance")
                end)
            else
                ModuleCache.ModuleManager.show_module("public", "goldentrance")
            end
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
        end
    elseif (obj.name == "CopyId") then
        ModuleCache.GameSDKInterface:CopyToClipboard(self.view.textPlayerID.text:sub(4, #self.view.textPlayerID.text))
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("游戏ID复制成功")
    elseif (obj.name == "ButtonStore") then
        print("self.playMode.isOpenGold = " .. tostring(self.playMode.isOpenGold))
        if self.playMode and self.playMode.isOpenGold then
            -- ModuleCache.ModuleManager.show_module("public", "goldstore", 1)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
        end
    elseif obj.name == "WebViewTestBtn" then
        self:webviewtest()
    end
end

function HallModule:update_userinfo()
    self.hallModel:get_userinfo()
end

-- 金币场点击
function HallModule:goldClick(tag)
    --if ModuleCache.AppData.get_app_name() ~= "DHAMQP" then
    --    self.modelData.hallData.normalAppName = ModuleCache.AppData.get_app_name()
    --    self.modelData.hallData.normalGameName = ModuleCache.AppData.get_app_and_game_name()
    --    self.modelData.hallData.normalProvinceId = ModuleCache.GameManager.curProvince
    --    self.modelData.hallData.normalGameId = ModuleCache.GameManager.curGameId
    --    print("当前所在省份与游戏：", ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)
    --end
    --
    --ModuleCache.UnityEngine.PlayerPrefs.SetString(ModuleCache.AppData.PLAYER_PREFS_KEY_LAST_PROVINCE_GAME,
    --ModuleCache.GameManager.curProvince .. "_" .. ModuleCache.GameManager.curGameId)
    --ModuleCache.GameManager.select_province_id_not_record(12)
    ---- 设置澳门省
    --local gamename = ModuleCache.AppData.Game_Name
    --local playmodel_data = ModuleCache.PlayModeUtil.getConfigByGameName(gamename)
    --if playmodel_data then
    --    -- 根据gamename找到澳门省对应gamename的gameid
    --    local gameId = playmodel_data.gameId
    --    ModuleCache.GameManager.select_game_id_not_record(gameId)
    --    ModuleCache.ModuleManager.show_module("public", "goldentrance", tag)
    --    if self.isCliclGold then
    --        self.isCliclGold = false
    --        ModuleCache.ModuleManager.show_module("henanmj", "shop", 5)
    --    end
    --else
    --    -- 找不到gameid
    --    ModuleCache.GameManager.select_province_id(self.modelData.hallData.normalProvinceId)
    --    ModuleCache.GameManager.select_game_id(self.modelData.hallData.normalGameId)
    --    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")
    --end
end


function HallModule:webviewtest()
    local url = self.modelData.roleData.agentUrl
    local data = {
        link = url,
        showType = 0,
        style = 2
    }
    ModuleCache.ModuleManager.show_module("henanmj", "webview", data);
end

function HallModule:updateRedInfo(eventData)
    self.view:updateRedStatus(eventData.show, eventData.data)
end

-- 显示系统跑马灯
function HallModule:add_system_announce(content, loop)
    local holder = { }
    holder.loop = loop
    holder.content = content

    if self.systemAnnounceIsShow then
        self._systemAnnounceContents:push(holder)
        return
    end
    self.systemAnnounceIsShow = true
    self:_show_system_announce(content, loop)
end

function HallModule:remove_all_announce()
    self._systemAnnounceContents:clear()
end

function HallModule:_show_system_announce(content, loop, delayTime)
    delayTime = delayTime or 3
    self.view.systemAnnounceRoot:SetActive(true)
    local textTips = self.view.systemAnnounceText
    local textTipsTransform = textTips.transform
    textTips.text = content
    local textPreferredWidth = textTips.preferredWidth
    ModuleCache.TransformUtil.SetSizeDeltaX(textTipsTransform, textPreferredWidth + 30)
    ModuleCache.TransformUtil.SetX(textTipsTransform,(560 + textPreferredWidth / 2) + 20, true)
    local endPosX = 0 -(560 + textPreferredWidth / 2)
    local time = 20 * textPreferredWidth /(textPreferredWidth + 30)
    local sequence = self:create_sequence();
    sequence:Append(textTipsTransform:DOLocalMoveX(endPosX, time, false):SetEase(EaseLinear):OnComplete( function()
        if (loop) then
            local holder = { }
            holder.loop = loop
            holder.content = content
            self._systemAnnounceContents:push(holder)
        end
        local entity = self:_get_need_show_system_entity()
        if entity then
            self:_show_system_announce(entity.content, entity.loop)
        else
            self.systemAnnounceIsShow = false
            self.view.systemAnnounceRoot:SetActive(false)
        end
    end ))


end


function HallModule:isShowHongBaoHuoDong()


    -- 上报 服务器  成功后 刷新界面  buttonHongBaoHuoDong   GET /packetShow/getUrl
    local requestData = {
        params =
        {
            uid = self.modelData.roleData.userID,
            gameId = ModuleCache.GameManager.curGameId
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "packetShow/getUrl?",
    }


    local onResponse = function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.success then
            self.view.buttonHongBaoHuoDong.gameObject:SetActive(true);
            self.HongBaoHuoDongUrl = retData.data
        else
            self.view.buttonHongBaoHuoDong.gameObject:SetActive(false);
        end
    end

    local onError = function(data)
        print(data.error);
    end

    self:http_get(requestData, onResponse, onError);
end

function HallModule:_get_need_show_system_entity()
    return self._systemAnnounceContents:shift()
end


function HallModule:getHistoryList()
    local addStr = "gamehistory/roomlist/v3?"
    self.playMode = PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
        showModuleNetprompt = true,
        params =
        {
            uid = self.modelData.roleData.userID,
            platformName = ModuleCache.GameManager.customPlatformName,
            assetVersion = ModuleCache.GameManager.appAssetVersion,
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        print_table(retData);
        if (retData.success) then
            local openPackage = self.playMode.package
            ModuleCache.ModuleManager.show_module(openPackage, "historylist", self:get_new_list(retData.data.list))
        end
    end , function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

function HallModule:get_new_list(list)
    local newList = { }
    local maxNum = 20
    if (#list < maxNum) then
        return list
    else
        for i = 1, maxNum do
            table.insert(newList, list[i])
        end
        print(#newList)
        return newList
    end
end

function HallModule:get_museum_list(click)

    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getUserParlorList?",
        showModuleNetprompt = click,
        params =
        {
            uid = self.modelData.roleData.userID,
            platformName = ModuleCache.GameManager.customPlatformName,
            assetVersion = ModuleCache.GameManager.appAssetVersion
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            self.dataList = retData.data
            self.selectIndex = self:get_index_by_parlorId(PlayerPrefs.GetInt("museumIndex", 1))

            if (#self.dataList == 0) then
                local sendData = {
                    museumData = self.dataList,
                    museumDetailData = nil
                }
                print_table(sendData)
                ModuleCache.ModuleManager.show_module("henanmj", "chessmuseum", sendData)
            else
                self:select_item(self.selectIndex, function(data)
                    if (data) then
                        self:get_detail(data)
                    end
                end )
            end
        end
    end , function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

function HallModule:get_index_by_parlorId(parlorId)
    for i, v in ipairs(self.dataList) do
        if v.parlorId == parlorId then
            return i
        end
    end
    return 1
end

function HallModule:select_item(index, callback)
    if (#self.dataList == 0) then
        return
    end
    if (index > #self.dataList) then
        index = 1
    end
    self.selectIndex = index

    local data = self.dataList[index]
    PlayerPrefs.SetInt("museumIndex", data.parlorId)
    PlayerPrefs.Save()
    if (callback) then
        callback(data)
    end
end

function HallModule:get_detail(data)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getParlorDetail?",
        params =
        {
            uid = self.modelData.roleData.userID,
            platformName = ModuleCache.GameManager.customPlatformName,
            assetVersion = ModuleCache.GameManager.appAssetVersion,
            page = 1,
            rows = 20,
            id = data.id
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            local sendData = {
                museumData = self.dataList,
                museumDetailData = retData.data
            }
            print_table(sendData)
            ModuleCache.ModuleManager.show_module("henanmj", "chessmuseum", sendData)
        end
    end , function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

-- 获取商城某个东西是否有
function HallModule:get_shop_products(postId,callback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/getProduct?",
        --showModuleNetprompt = true,
        params = {
            uid = self.modelData.roleData.userID,
            coinType = postId
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        if retData.ret == 0 then
            if callback and type(callback) == "function" then
                callback(retData.data)
            end
        end
    end, function(errorData)
        print(errorData.error)
    end)
end

return HallModule


