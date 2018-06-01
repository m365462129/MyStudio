-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
---@class SetPlayModeModule : Module
local SetPlayModeModule = require("lib.middleclass")("BullFight.SetPlayModeModule", ModuleBase)
local Config = require("package.public.config.config")
TableUtil = require("package.henanmj.table_util")
local PlayModeUtil = ModuleCache.PlayModeUtil
local CSmartTimer = ModuleCache.SmartTimer.instance
local Sequence = DG.Tweening.DOTween.Sequence

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local AppData = AppData
local EaseLinear = DG.Tweening.Ease.Linear

local GameManager = ModuleCache.GameManager
local PlayerPrefs = UnityEngine.PlayerPrefs

function SetPlayModeModule:initialize(...)
	ModuleBase.initialize(self, "setplaymode_view", nil, ...)
    local list = require("list")
    -- 需要按照权重来播放,从1、2、3、4开始，还有触发的时间等等都要重新排序
    self._systemAnnounceContents = list:new()
end

-- 模块初始化完成回调，包含了view，loginModel初始化完成
function SetPlayModeModule:on_module_inited()

end



function SetPlayModeModule:on_show(data)
    self.view:setShow(false)
    ModuleCache.ModuleManager.hide_module('henanmj','setprovince')
    self.userID = PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_USERID, "0")
    self.view.showId = ModuleCache.GameManager.curGameId
    if data then
        print(tostring(type(data)))
        if type(data) == "table" then
            self.provinceId = data.id
            self.view.provinceId = data.id
            self.sssss = "ssssss"
        else
            self.provinceId = data
            self.view.provinceId = data
            self.sssss = nil
        end

    else
        print("请先选则省份！",error)
    end
    self.view.used = ModuleCache.GameManager.get_used_playMode()
    if self.view.used then
        print_table(self.view.used)
    end

    --self.callback = data
    self.province = PlayModeUtil.getProvinceById(self.provinceId)
    self.playModeData = PlayModeUtil.getSortConfig(require(self.province.modName))

    if(ModuleCache.GameManager.iosAppStoreIsCheck)then   -- 过省版本屏蔽大量玩法
        for i=1,#self.playModeData do
            if(i == 1) then
                local playMode = self.playModeData[i].playModeList
                for j=1,#playMode do
                    if(j > 2) then
                        playMode[j].isOpen = false
                    end
                end
            else
                self.playModeData[i] = nil;
            end
        end
        self.view:initLeftScrollViewList(self.playModeData)
        return
    end

    if data then
        if ModuleCache.GameManager.curProvince ~= self.provinceId then
            self.view.showId = 0 -- 如果是从选择省份进来的，和当前省份ID不一样的话不显示在那个省份选择的标签
        end
    end
    self:getIdonotKnowWhat()
    self:getGameRecommend()

    ModuleCache.ComponentUtil.SafeSetActive(self.view.normolPanel, false)
    ModuleCache.ComponentUtil.SafeSetActive(self.view.firstlPanel, false)

end

function SetPlayModeModule:showUI()
    print("show UI")


    if self.sssss then
        print("dsffrvfffd")
        self.view:setShow(true)
        self.recommendData = self:sortData(self.recommendData)
        ModuleCache.ComponentUtil.SafeSetActive(self.view.firstTitle, #self.recommendData <= 0)
        ModuleCache.ComponentUtil.SafeSetActive(self.view.normolTitle, #self.recommendData > 0)
        self.view:initLeftScrollViewList(self.playModeData)
        return
    end
    --
    --local post = 2
    --if self.isBind and self.isUserFirst then
    --    post = 1
    --end
    --



    if #self.recommendData > 0 then

        --local isbool = ModuleCache.ModuleManager.module_is_active("henanmj","hall") --ModuleCache.ModuleManager.module_is_active("henanmj","setprovince") and ModuleCache.ModuleManager.module_is_active("henanmj","hall")

        --if isbool then
        --    self.view:initLeftScrollViewList(self.playModeData)
       --else
          --  self.view:showFirstView(self.recommendData, post)
       -- end
        self.view:initLeftScrollViewList(self.playModeData, #self.recommendData > 0)
    else
        print("in 22222222222222")
        self.recommendData = self:sortData(self.recommendData)
        self.view:initLeftScrollViewList(self.playModeData, #self.recommendData > 0)

    end

    ModuleCache.ComponentUtil.SafeSetActive(self.view.firstTitle, #self.recommendData <= 0)
    ModuleCache.ComponentUtil.SafeSetActive(self.view.normolTitle, #self.recommendData > 0)

    --else
    --    self.view:initLeftScrollViewList(self.playModeData)
    --end
    self.view:setShow(true)
end

function SetPlayModeModule:showNotice()
    if self.ads then
        print("-------- 推荐玩法有广告图 ---------")
        self.view:set_sugScroll_right()
        self.view:refreshAdContent(self.ads)
        self:start_auto_play_adcontent()
    else
        print("-------- 推荐玩法没有广告图 ---------")
        self.view:set_sugScroll_center()
    end

    if self.sys then
        self:remove_all_announce()
        for i = 1, #self.sys do
            self:add_system_announce(self.sys[i].content, true, 0)
        end
    end

    if self.wct then
        if self.wct.content and self.wct.content ~= "" then
            self.view.btnCopyExObj:SetActive(true)
            self.view.extensionText.text = "客服微信号: "..self.wct.content
        else
            self.view.btnCopyExObj:SetActive(false)
        end
    else
        self.view.btnCopyExObj:SetActive(false)
    end

    if self.rbg then
        self.view:startDownLoadBgImg(self.rbg.content)
    end
end

function SetPlayModeModule:getIdonotKnowWhat()
    local province = PlayModeUtil.getProvinceById(self.provinceId)

    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "notice/list?",
        showModuleNetprompt = true,
        params = {
            uid = self.userID,
            gameName = province.appName
        }
    }


    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        print_table(retData)
        self.ads = nil
        self.sys = nil
        self.wct = nil
        self.rbg = nil
        for i = 1, #retData do
            if retData[i].noticekey == "adsimg" then
                if retData[i].isShow then
                    if self.ads == nil then self.ads = {} end
                    table.insert(self.ads, retData[i])
                end
            elseif retData[i].noticekey == "notice" then
                if retData[i].isShow then
                    if self.sys == nil then self.sys = {} end
                    table.insert(self.sys, retData[i])
                end
            elseif retData[i].noticekey == "contact" then
                self.wct = retData[i]
            elseif retData[i].noticekey == "recommendimg" then
                self.rbg = retData[i]
            end
        end
        self:showNotice()
    end, function(errorData)
        print(errorData.error)
    end)
end

--function SetPlayModeModule:getIsFirstInGame()
--    local user = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "noUser")
--    local num = UnityEngine.PlayerPrefs.GetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 0)
--    return num == 0
--end

function SetPlayModeModule:sortData(data)
    local newData = {}
    local index = 1
    if self.view.used then
        for i = 1, 3 do
            local isbool = true
            for j = 1, #newData do
                if tostring(newData[j].province.id) == tostring(self.view.used[i].provinceId) and tostring(newData[j].playMode.gameId) == tostring(self.view.used[i].gameId) then
                    isbool = false
                    break
                end
            end

            if isbool then
                local provinceConf = ModuleCache.PlayModeUtil.getProvinceById(self.view.used[i].provinceId)
                local playModeConf  = PlayModeUtil.getDeepCopyTable(require(provinceConf.modName))
                local list = {}
                list.province = provinceConf
                list.playMode = PlayModeUtil.getInfoByGameId(self.view.used[i].gameId,playModeConf)
                list.type = 10086
                newData[index] = list
                index = index + 1
            end
        end
    end

    for i = 1,#data do
        local isbool = true
        if self.view.used then
            for j = 1, #self.view.used do
                if tostring(data[i].province.id) == tostring(self.view.used[j].provinceId) and tostring(data[i].playMode.gameId) == tostring(self.view.used[j].gameId) then
                    isbool = false
                    break
                end
            end
        end
        if isbool then
            newData[index] = data[i]
            index = index + 1
        end
    end
    return newData
end

function SetPlayModeModule:createRecommendData(retData)
    local data = {}
    local index = 1
    --print("----------------- start ---------------------")
    --print_table(retData)
    for i = 1, #retData do
        local provinceConf = ModuleCache.PlayModeUtil.getProvinceByAppName(retData[i].province)
        local playModeConf  = PlayModeUtil.getDeepCopyTable(require(provinceConf.modName))
        local gameName = string.split(retData[i].gameId, "_")[2]
        local list = {}
        list.province = provinceConf
        list.playMode = PlayModeUtil.getInfoByGameName(gameName,playModeConf)
        list.type = retData[i].type
        if(gameName == list.playMode.gameName)then
            data[index] = list
            index = index + 1;
        end
        --print("i = "..i)
        --print("retData[i].province = "..retData[i].province)
        --print("retData[i].gameId = "..retData[i].gameId)
        --print("retData[i].type = "..retData[i].type)
        --print_table(data[i])
    end

    --print("----------------- end ---------------------")
    return data
end


function SetPlayModeModule:getGameRecommend()
    print("--- get recommend-----")
    local province = PlayModeUtil.getProvinceById(self.provinceId)


    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "public/getGameRecommend?",
        params = {
            uid = self.userID,
            province = province.appName
        },
        --cacheDataKey = "public/getGameRecommend?uid=" .. self.userID .. province.appName
    }

    local processData = function(text)
        if text ~= "" then
            local retData = ModuleCache.Json.decode(text)
            print_table(retData)
            if retData.ret == 0 then
                self.recommendData = self:createRecommendData(retData.data)
                if #self.recommendData > 0 then
                    self.recommendData = self:sortData(self.recommendData)
                end
                self:showUI()
            end
        end
    end

    --local cacheData = UnityEngine.PlayerPrefs.GetString(requestData.cacheDataKey, "")
    --if cacheData ~= "" then
    --    processData(cacheData)
    --else
    --    requestData.showModuleNetprompt = true
    --end

    self:http_get(requestData, function(wwwData)
        processData(wwwData.www.text)
    end, --function(errorData)
        --print(errorData.error)
       -- if cacheData == "" then
            --self.view:initLeftScrollViewList(self.playModeData)
        --end
    function(wwwErrorData)
        print(wwwErrorData.error)
        if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
            if wwwErrorData.www.text then
                local retData = wwwErrorData.www.text
                retData = ModuleCache.Json.decode(retData)
                if retData.errMsg then
                    retData = ModuleCache.Json.decode(retData.errMsg)
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
                    self.recommendData = {}
                    self:showUI()
                end
            end
        end
    end)
end

--function SetPlayModeModule:getInitData()
--    local requestData = {
--        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/isBindInvite?",
--        showModuleNetprompt = false,
--        params = {
--            uid = self.userID
--        },
--        cacheDataKey = "user/isBindInvite?uid=" .. self.userID
--    }
--
--    local processData = function(text)
--        if text ~= "" then
--            local retData = ModuleCache.Json.decode(text)
--            if retData.ret == 0 then
--                self.isBind = retData.data.isBindInvite
--                --print("----print(tostring(self.isBind)) = "..tostring(self.isBind))
--                self:getGameRecommend()
--            end
--        end
--    end
--
--    local cacheData = UnityEngine.PlayerPrefs.GetString(requestData.cacheDataKey, "")
--    if cacheData ~= "" then
--        processData(cacheData)
--    else
--        requestData.showModuleNetprompt = true
--    end
--
--    self:http_get(requestData, function(wwwData)
--        if cacheData == "" then
--            processData(wwwData.www.text)
--        end
--    end, function(errorData)
--        print(errorData.error)
--        if cacheData == "" then
--            self.view:initLeftScrollViewList(self.playModeData)
--        end
--    end)
--end


function SetPlayModeModule:on_click( obj, arg)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	local _cmd = obj.name
	print(_cmd)
    if(_cmd == "closeBtn")then
        if self.isUserFirst then
            local user = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "noUser")
            UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 1)
            self.isUserFirst = false
            self.view:resetFirst()
        end
        self:stop_auto_play_adcontent()
        ModuleCache.ModuleManager.hide_module('henanmj','setplaymode')
        ModuleCache.ModuleManager.hide_module('henanmj','setprovince')
        --if(ModuleCache.ModuleManager.module_is_active('henanmj','setprovince')) then
        --    self:doCallback(not ModuleCache.ModuleManager.module_is_active('henanmj','setprovince'))
        --end
        --self:dispatch_module_event("setplaymode", "Event_Set_Play_Mode",nil)
        --self:dispatch_package_event("Event_Set_Play_Mode", nil)

    elseif _cmd == self.view.btnSug.name then
        --print("111111")
--        if self.view.showIndex ~= 1 then
--            self.view:showFirstView(self.recommendData)
--        end
        ModuleCache.ModuleManager.hide_module('henanmj','setplaymode');
    elseif _cmd == self.view.btnMore.name then
        --print("22222")
        if self.view.showIndex ~= 2 then
            self.view:initLeftScrollViewList(self.playModeData, #self.recommendData > 0)
        end
    elseif _cmd == "btnCurrent" then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("选择的是当前玩法，无需切换！")
    elseif(_cmd == 'provinceBtn') then
        --ModuleCache.ModuleManager.hide_module('henanmj','setplaymode')

        if self.isUserFirst then
            local user = UnityEngine.PlayerPrefs.GetString(ModuleCache.AppData.PLAYER_PREFS_KEY_ACCOUNT, "noUser")
            UnityEngine.PlayerPrefs.SetInt(AppData.PLAYER_PREFS_KEY_PLAY_MODE_SET.."_"..user, 1)
            self.isUserFirst = false
            self.view:resetFirst()
        end
        self:stop_auto_play_adcontent()
        ModuleCache.ModuleManager.show_module('henanmj','setprovince')
    elseif _cmd == "BtnCopyEx" then
        if self.wct and self.wct.content then
            ModuleCache.GameSDKInterface:CopyToClipboard(self.wct.content)
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已复制到剪切板！")
        end
    elseif(string.find( _cmd,"toggle") ~= nil)then
        self.view:initRightScrollViewList(tonumber(string.sub(_cmd,7,string.len(_cmd))))
    elseif(string.find(_cmd,"btnPlayMode")) then
        local data = self.view:getPlayMode(tonumber(string.sub(_cmd,12,string.len(_cmd))))

        local playMode = data
        if data.province then
            --print("data.province")
            self.provinceId = data.province.id
            playMode = data.playMode
        end
        self.view:unSelectPlayMode(obj)
        self:sendWhilt(self.provinceId,playMode,obj)



    end
end

function SetPlayModeModule:sendWhilt(provinceId,playMode,obj)
    local province = ModuleCache.PlayModeUtil.getProvinceById(provinceId)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "/user/isWhiteList?",
        showModuleNetprompt = true,
        params =
        {
            uid = self.userID,
            gameName = province.appName.."_"..playMode.gameName,
        }
    }
    self:http_get(requestData, function(wwwData)
        local retData = ModuleCache.Json.decode(wwwData.www.text)
        print_table(retData)
        if retData.ret == 0 then
            self:setPlayMode(playMode,obj)
        end
    end , function(errorData)
        print(errorData.error)
        if tostring(errorData.error):find("500") ~= nil or tostring(errorData.error):find("error") ~= nil then
            if errorData.www.text then
                local retData = errorData.www.text
                retData = ModuleCache.Json.decode(retData)
                if retData.errMsg then
                    retData = ModuleCache.Json.decode(retData.errMsg)
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
                end
            end
        end
        if not ModuleCache.GameManager.deviceIsMobile then
            self:setPlayMode(playMode,obj)
        end
    end )
end
function SetPlayModeModule:setPlayMode(playMode, obj)
    --if(playMode.isOnline == nil or playMode.isOnline == false) then
    --    if(playMode.isOpenUrl) then
    --        UnityEngine.Application.OpenURL(playMode.openUrl)
    --    else
    --        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("玩法即将发布，敬请期待！！！")
    --    end
    --    self.view:setPlayModeIsOnById(ModuleCache.GameManager.curGameId,true,obj)
    --    return nil
    --end
    self.isUserFirst = false
    --ModuleCache.PreLoadManager.preLoad(playMode.package)

    if(self.provinceId == ModuleCache.GameManager.curProvince and playMode.gameId == ModuleCache.GameManager.curGameId)then
        ModuleCache.GameManager.select_game_id(playMode.gameId)
        ModuleCache.JpushManager.setTag()
    else
        self:stop_auto_play_adcontent()
        local lastAppName, needRenameAppName = AppData.get_app_name()
        if not needRenameAppName then
            lastAppName = ""
        end

        ModuleCache.GameManager.select_province_id(self.provinceId)
        ModuleCache.GameManager.select_game_id(playMode.gameId)
        ModuleCache.GameManager.curLocation = playMode.location
        ModuleCache.JpushManager.setTag()

        local curAppName, needRenameAppName = AppData.get_app_name()
        if not needRenameAppName then
            curAppName = ""
        end

        if curAppName ~= lastAppName then
            ModuleCache.GameManager.logout(true)
            return
        end
    end

    --ModuleCache.GameManager.set_used_playMode(self.provinceId, playMode.gameId)

    ModuleCache.PackageManager.update_package_version(playMode.package, function()
        -- 更新完所有资源再去检测是否有apk、ipa需要更新
        ModuleCache.ModuleManager.hide_module('henanmj','setplaymode')
        ModuleCache.ModuleManager.hide_module("public", "operate");

        self:dispatch_package_event("Event_Set_Play_Mode", playMode)
        if not ModuleCache.ModuleManager.module_is_active("henanmj", "hall") then
            ModuleCache.ModuleManager.show_module("henanmj", "hall")
        end
        ModuleCache.GameManager.set_used_playMode(ModuleCache.GameManager.curProvince, ModuleCache.GameManager.curGameId)
    end)
end

function SetPlayModeModule:doCallback(isNeedCallBack,isSameId)
    if(self.callback ~= nil and type(self.callback == "function")) then
        self.callback(isNeedCallBack,isSameId)
    end
end

-- 绑定module层的交互事件
function SetPlayModeModule:on_module_event_bind()
	
end

-- 绑定loginModel层事件，模块内交互
function SetPlayModeModule:on_model_event_bind()
	
end

function SetPlayModeModule:on_destroy()
    self:stop_auto_play_adcontent()
end

function SetPlayModeModule:on_begin_drag(obj, arg)
    if (string.find(obj.name, "ad_item") == 1 ) then
        self:stop_auto_play_adcontent()
        self.view:onBeginDragAdContent(obj, arg)
    end
end

function SetPlayModeModule:on_drag(obj, arg)
    self.view:onDragAdContent(obj, arg)
end

function SetPlayModeModule:on_end_drag(obj, arg)
    if (self.view and string.find(obj.name, "ad_item") == 1) then
        self.view:onEndDragAdContent(nil, obj, arg)
        self:start_auto_play_adcontent()
    end
end

function SetPlayModeModule:start_auto_play_adcontent()
    self.autoPlayAdTimeEventID = self:subscibe_time_event(3, false, 0):OnComplete( function(t)
        if (self.view.adContentInfo.isDraging) then
            return
        end

        if (self.view.lastIndex == 1) then
            self.auto_play_offset = 1
        elseif (self.view.lastIndex == #self.view.adContentInfo.pageSelectImageArray) then
            self.auto_play_offset = -1
        end
        if (not self.auto_play_offset) then
            self.auto_play_offset = 1
        end

        self.view.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition = self.view.adContentInfo.scrollRectAdContent.horizontalNormalizedPosition + 0.01 * self.auto_play_offset

        self.view:onBeginDragAdContent()
        self.view:onEndDragAdContent(self.auto_play_offset)
        self:stop_auto_play_adcontent()
        self:start_auto_play_adcontent()
    end ).id
end

function SetPlayModeModule:stop_auto_play_adcontent()
    if (self.autoPlayAdTimeEventID) then
        CSmartTimer:Kill(self.autoPlayAdTimeEventID)
        self.autoPlayAdTimeEventID = nil
    end
end


function SetPlayModeModule:add_system_announce(content, loop)
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

function SetPlayModeModule:remove_all_announce()
    self._systemAnnounceContents:clear()
end

function SetPlayModeModule:_show_system_announce(content, loop, delayTime)
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
    local sequence = Sequence();
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

function SetPlayModeModule:_get_need_show_system_entity()
    return self._systemAnnounceContents:pop()
end


return SetPlayModeModule