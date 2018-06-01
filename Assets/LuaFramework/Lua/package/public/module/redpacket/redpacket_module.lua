--------------------------------------------------------------
--- 使用说明：
--- 各个玩法在牌桌中接收到红包消息时，直接show本模块，附带参数为 ｛awardMsg, position, isMe｝；进入大厅时直接show本模块，不需要传入参数
--- awardMsg为服务器数据，无需修改；position为获得红包的玩家头像的位置，需转换为世界坐标；isMe为boolean，表示该玩家是不是自己
--- 另外需要在 get_redpacket_pos 方法中添加红包停留的位置，hall表示大厅中显示的红包，table表示牌桌中显示的红包
--- {x = {"center", 240}, y = {"top", -67}} center表示坐标从中心开始，top表示坐标为距离屏幕顶部，left、right、bottom同理
--- 需要注意的是top、right对应的值为负，left、bottom对应的值为正
--------------------------------------------------------------

local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local RedpacketModule = class("Public.RedpacketModule", ModuleBase)
local Manager = require("package.public.module.function_manager")
local ModuleCache = ModuleCache

function RedpacketModule:initialize(...)
    ModuleBase.initialize(self, "redpacket_view", nil, ...)

    self.timer = { }
    -- 是否开启活动说明
    self.isOpenActivity = true;
    -- 收到抢红包类型的时间戳
    self.receiveQiangRedTimeLine = 0;
    -- 领取抢红包的时间戳
    self.getQiangRedTimeLine = 0;

    self.data = {
        -- name = "红包活动", -- 活动名称
        -- partner = "新城吾悦", -- 合作商
        -- logo = "", -- 合作商logo
        -- cdkey = "", -- 兑换码
        -- gzh = "大胡棋牌", -- 公众号
        -- ewm_url = "", -- 二维码地址
        -- ewm = "", -- 二维码
        -- cur = { -- 本次红包获得
        --    type = 2, -- 2:钻石 3:体力 4:红包
        --    count = 1, -- 数量
        --    content = "", -- 文本
        -- },
        -- info = {
        --    total = {diamond = 1, vitality = 1, redbag = 1},-- 总获得奖励
        --    received = {diamond = 1, vitality = 1, redbag = 1}, -- 已领取奖励
        --    unclaimed = {diamond = 1, vitality = 1, redbag = 1}, -- 未领取奖励
        -- },
        -- intro = {
        --    time = "", -- 活动时间
        --    details = "", -- 活动详情
        --    abstract = "", -- 领奖说明
        -- },
        -- record = {"", ""} -- 领奖记录
        isMyselfGetRed = true;
    }
end

function RedpacketModule:init_data(data)

end

function RedpacketModule:on_show(data)

    if data then
        print_table(data)
        self:show_in_table(data)
    else
        self:get_redpacket_info()
    end

    -- 动态sortOrder赋值
    self.view:setSortOrder();
end

function RedpacketModule:on_hide()
    self:show_table_btn_anim(false)
    self:show_main_view(false)
    self:show_popup_view(false)
    self:show_tips_view(false)
    self.view.weishoudaoCanvas.gameObject:SetActive(false);
    self:dispatch_package_event("Event_Refresh_Red_Status", { show = false, data = self.data })

    self.data = { }
end

function RedpacketModule:on_destroy()
    Manager.KillSmartTimer(self.timer)
    ModuleCache.WechatManager.onSendMessageToWXResp = nil
end

function RedpacketModule:get_redpacket_account()
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getRedPacketAccount?",
        -- 玩家奖励详情
        params =
        {
            uid = self.modelData.roleData.userID,
        }
    }

    self:http_get(
    requestData,
    function(data)
        print("------------------------- 玩家奖励信息 -------------------------")
        local retData = ModuleCache.Json.decode(data.www.text)
        print_table(retData)

        self.data.info = retData.data

        self:show_main_view(true)
    end ,
    function(data)
        print(data.error)
    end )
end

function RedpacketModule:get_redpacket_info()
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getRedPacketInfo2?",
        -- 活动信息
        params =
        {
            uid = self.modelData.roleData.userID,
        }
    }

    self:http_get(
    requestData,
    function(data)
        local retData = ModuleCache.Json.decode(data.www.text)

        local data = retData.data;
        -- 开启红包雨功能
        if data.canShow then

            if next(data.data) == nil then
                self.isOpenActivity = false;
            else
                self.isOpenActivity = true;
            end

            -- 空表
            if self.isOpenActivity == false then
                -- 没有数据,大厅显示红包按钮和文字,隐藏红包说明tab
                self.data.partner = "领红包";
                self.view.main_view.center.center.gameObject:SetActive(false);
            else
                self.data.intro = { }
                self.data.intro.time = data.data.activityTimeText
                self.data.intro.details = data.data.activityDetailText
                self.data.intro.abstract = data.data.activityInstructionsText
                self.data.gzh = data.data.activityMpName
                self.data.partner = "领红包";
                self.data.ewm_url = data.data.qrCode
                self.data.name = data.data.name

                ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(self.data.ewm_url, function(err, sprite)
                    if err then

                    else
                        self.data.ewm = sprite
                    end
                end )
                self.view.main_view.center.center.gameObject:SetActive(true);
            end
            self:show_in_hall();
        else
            -- 隐藏大厅红包雨按钮
            self:dispatch_package_event("Event_Refresh_Red_Status", { show = false, data = self.data })
        end

    end ,
    function(data)

        -- Manager.DestroyModule("public", "redpacket")
    end )
end

function RedpacketModule:get_redpacket_award()
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getRedPacketAwardPage?",
        -- 领奖记录
        params =
        {
            uid = self.modelData.roleData.userID,
            pageNum = 1,
            pageSize = 20,
        }
    }

    self:http_get(
    requestData,
    function(data)
        local retData = ModuleCache.Json.decode(data.www.text)
        self.data.record = retData.data.list
        if self.view.main_view.bottom.right.root.activeSelf then
            self:show_main_bottom_right(true)
        end
    end ,
    function(data)
        print(data.error)
    end )
end

function RedpacketModule:get_cdkey()
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/getCdKey?",
        params =
        {
            uid = self.modelData.roleData.userID,
        }
    }
    self:http_get(
    requestData,
    function(data)
        local retData = ModuleCache.Json.decode(data.www.text)
        self.data.cdkey = retData.data
        self:show_popup_view(true)
    end ,
    function(data)
        print(data.error)
    end )
end

-- 请求获取抢红包协议
function RedpacketModule:doRobAward(sign)

    local requestData = {
        params =
        {
            uid = self.modelData.roleData.userID,
            sign = sign,
            robTime = (self.getQiangRedTimeLine - self.receiveQiangRedTimeLine) .. "秒",
        },
        showModuleNetprompt = true,
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "activity/doRobAward?",
    }
    local onResponse = function(wwwOperation)

        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then

            local amount = tonumber(retData.data.amount);
            -- 未抢到红包
            if amount == 0 then
                self.view.weishoudaoCanvas.gameObject:SetActive(true);
                -- 抢到红包
            else
                self.data.curRedData = {
                    type = retData.data.amountType,
                    count = retData.data.amount,
                    content = retData.data.content,
                    isRobRed = retData.data.canRob,
                    sign = retData.data.sign,
                    name = retData.data.name,
                }
                self:show_tips_view(true)
            end

            self.data.isMyselfGetRed = true;

            self:show_table_btn_anim(false)
        else

        end
    end

    local onError = function(data)
        print(data.error);
    end

    self:http_get(requestData, onResponse, onError);
end

-- 请求获取图片分享配置协议
function RedpacketModule:getImageShareConfig(timeLine)

    local requestData = {
        params =
        {
            uid = self.modelData.roleData.userID,
            customData = ModuleCache.ShareManager().get_hall_share_custom_data(),
            type = 2,
        },
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "public/getImageShareConfig?",
    }

    if ModuleCache.AppData.Const_App_Bundle_ID then
        requestData.params.gameName = AppData.get_url_game_name() .. "__" .. ModuleCache.AppData.Const_App_Bundle_ID
    end

    local onResponse = function(wwwOperation)

        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then

            local onDownLoadQR = function(spriteQR)

                if spriteQR ~= nil then

                    local onDownLoadShareBg = function(spriteShareBg)

                        -- 更新分享图片视图
                        self.view:updateShareImage(retData.data, spriteQR, spriteShareBg);
                        -- 调用微信图片分享功能
                        ModuleCache.ShareManager().shareImage(timeLine, true, false);
                        ModuleCache.WechatManager.onSendMessageToWXResp = function(data)
                            print(data, "onSendMessageToWXResp")
                            local retData = ModuleCache.Json.decode(data)
                            if (retData.errCode == 0) then

                                self.view.shareBox:SetActive(false);
                                if self:can_show_cdkey() then
                                    self:get_cdkey()
                                else
                                    self:show_popup_view(true)
                                end
                            end
                        end
                    end
                    -- 下载背景图片
                    self:startDownLoadHeadIcon(retData.data.backgroundImgUrl, onDownLoadShareBg);
                end
            end
            local url = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "public/getQrCode?url=" .. Util.encodeURL(retData.data.bindUrl);
            -- 下载二维码图片
            self:startDownLoadHeadIcon(url, onDownLoadQR);
        else

        end
    end

    local onError = function(data)
        print(data.error);
    end

    self:http_get(requestData, onResponse, onError);
end

function RedpacketModule:show_in_table(data)
    self:dispatch_package_event("Event_Refresh_Red_Status", { show = false, data = self.data })

    local retData = ModuleCache.Json.decode(data.awardMsg)
    local tempData = {
        type = retData.amountType,
        count = retData.amount,
        content = retData.content,
        isRobRed = retData.canRob,
        sign = retData.sign,
        name = retData.name,
    };
    self.data.curRedData = tempData;
    -- 关闭收到红包弹出框
    self:show_tips_view(false);
    -- 关闭未收到红包弹出框
    self.view.weishoudaoCanvas.gameObject:SetActive(false);
    -- 向我自己发红包,才赋值新的红包数据
    if data.isMe then
        self.data.myRedData = tempData;
    end
    local posLocal = self.view.root.transform:InverseTransformPoint(data.position)

    self.view.anim_hongbaoyu:SetActive(true)

    if self.timer.hongbaoyu then
        Manager.KillSmartTimer(self.timer.hongbaoyu)
    end
    if self.timer.huode then
        Manager.KillSmartTimer(self.timer.huode)
    end
    if self.timer.qianghongbao then
        Manager.KillSmartTimer(self.timer.qianghongbao)
    end

    local hongbaoyuCallback = function()
        -- 固定红包
        if retData.canRob == false then
            self.view.anim_huode:SetActive(true);
            -- 设置收到红包特效位置
            Manager.SetLocalPos(self.view.anim_huode, posLocal.x, posLocal.y, posLocal.z);
            local huodeCallback = function()
                self.view.anim_huode:SetActive(false);
            end
            -- 获得红包特效计时器
            self.timer.huode = Manager.GetSmartTimer(1, false, 0, 1, nil, huodeCallback);
            -- 玩家自己
            if data.isMe then
                -- 玩家自己没有领取红包
                self.data.isMyselfGetRed = false;
                -- 其他玩家
            else
                -- 玩家领取红包,红包雨特效消失
                if self.data.isMyselfGetRed then
                    -- 红包雨特效消失
                    self.view.anim_hongbaoyu:SetActive(false);
                end
            end
            -- 抢红包
        else
            -- 玩家自己没有领取红包
            self.data.isMyselfGetRed = false;
        end
    end
    -- 红包雨特效计时器
    self.timer.hongbaoyu = Manager.GetSmartTimer(3, false, 0, 1, nil, hongbaoyuCallback);

    local qianhongbaoCallback = function()
        -- 固定红包
        if retData.canRob == false then
            if data.isMe then
                self:show_table_btn_anim(true);
            end
            -- 抢红包
        else
            self.receiveQiangRedTimeLine = os.time();
            self:show_table_btn_anim(true);
        end
    end
    -- 抢红包特效计时器
    self.timer.qianghongbao = Manager.GetSmartTimer(4, false, 0, 1, nil, qianhongbaoCallback);
end

function RedpacketModule:get_app_name()
    if not self.app_name then
        -- 每个工程都不一样，需要手动设置
        self.app_name = {
            default = "大胡棋牌游戏",
            DHAHQP = "大胡棋牌游戏",
        }
    end

    if self.app_name[AppData.App_Name] then
        return self.app_name[AppData.App_Name]
    else
        return self.app_name.default
    end
end

function RedpacketModule:show_in_hall()
    self:show_table_btn_anim(false)
    self:dispatch_package_event("Event_Refresh_Red_Status", { show = true, data = self.data })

    self.view.anim_hongbaoyu:SetActive(false)
    self.view.anim_huode:SetActive(false)
    -- local hall = ModuleCache.ModuleManager.get_module("henanmj","hall")
    -- if hall then
    --    hall.view.buttonRed.gameObject:SetActive(true)
    -- end

end

function RedpacketModule:show_table_btn_anim(show)
    self.view.qianghongbaoCanvas.gameObject:SetActive(show)

    if self.data.curRedData then
        -- 抢红包类型
        if self.data.curRedData.isRobRed then
            self.view.qianghongbaoLabel.text = "抢";
        else
            self.view.qianghongbaoLabel.text = "开";
        end
    end
end

function RedpacketModule:show_hall_btn_anim(show)
    local hall = ModuleCache.ModuleManager.get_module("henanmj", "hall")
    if hall then
        local hallredbtn = hall.view.buttonRed
        local hallredbtnname = hall.view.buttonRedName
        hallredbtn.gameObject:SetActive(show)
        if self.data.partner then
            hallredbtnname.gameObject:SetActive(true)
            hallredbtnname.text = self.data.partner
        else
            hallredbtnname.gameObject:SetActive(false)
        end
    end
end

function RedpacketModule:show_main_view(show)
    local view = self.view.main_view

    if not show then
        view.root:SetActive(false)
        return
    end

    view.root:SetActive(true)
    self:show_main_top()
    self:show_main_center()
    self:show_main_bottom()
end

function RedpacketModule:show_main_top()
    local view = self.view.main_view.top

    if self.data.partner and self.data.logo then
        view.logo.gameObject:SetActive(true)
        view.name.gameObject:SetActive(true)
        view.logo.texture = self.data.logo
        view.name.text = self.data.partner

        view.caishen:SetActive(false)
        view.title:SetActive(false)
    else
        view.caishen:SetActive(true)
        view.title:SetActive(true)
        view.logo.gameObject:SetActive(false)
        view.name.gameObject:SetActive(false)
    end
end

function RedpacketModule:show_main_center(arg)
    local view = self.view.main_view.center
    local choose = arg or 1

    view.left.isOn = choose == 1
    self.view.main_view.center.left_text:SetActive(choose == 1)

    view.center.isOn = choose == 2
    self.view.main_view.center.center_text:SetActive(choose == 2)

    view.right.isOn = choose == 3
    self.view.main_view.center.right_text:SetActive(choose == 3)
end

function RedpacketModule:show_main_bottom(arg)
    local choose = arg or 1

    self:show_main_bottom_left(choose == 1)
    self:show_main_bottom_center(choose == 2)
    self:show_main_bottom_right(choose == 3)
end

function RedpacketModule:show_main_bottom_left(show)
    local view = self.view.main_view.bottom.left
    if not show then
        view.root:SetActive(false)
        return
    end

    view.root:SetActive(true)

    local info = self.data.info
    if info and Manager.IsTableEmpty(info) then
        view.tips:SetActive(false)
    else
        view.tips:SetActive(true)
        return
    end

    if info.total and Manager.IsTableEmpty(info.total) then
        view.total.root:SetActive(true)
        for k, v in pairs(info.total) do
            view.total[k].root:SetActive(true)
            view.total[k].text.text = v
        end
    else
        view.total.root:SetActive(false)
    end

    if info.received and Manager.IsTableEmpty(info.received) then
        view.received.root:SetActive(true)
        for k, v in pairs(info.received) do
            view.received[k].root:SetActive(true)
            view.received[k].text.text = v
        end
    else
        view.received.root:SetActive(false)
    end

    if info.unclaimed and Manager.IsTableEmpty(info.unclaimed) then
        view.unclaimed.root:SetActive(true)
        for k, v in pairs(info.unclaimed) do
            if "redbag" == k then
                -- 只显示未领取的红包
                if 0 >= Manager.ToNumber(v) then
                    -- 如果未领取的红包余额为0，则整栏不显示
                    view.unclaimed.root:SetActive(false)
                else
                    view.unclaimed[k].root:SetActive(true)
                    view.unclaimed[k].text.text = v
                end
            else
                view.unclaimed[k].root:SetActive(false)
            end
        end
    else
        view.unclaimed.root:SetActive(false)
    end
end

function RedpacketModule:show_main_bottom_center(show)
    local view = self.view.main_view.bottom.center

    if not show then
        view.root:SetActive(false)
        return
    end

    local intro = self.data.intro

    local str = ""
    if intro and intro.time then
        str = intro.time
    end
    view.time.text = str
    local time_heigh = 85 + view.time.preferredHeight - 36
    view.time_rect.sizeDelta = Manager.Vector2(612, time_heigh)

    str = ""
    if intro and intro.details then
        str = intro.details
    end
    view.details.text = str
    local details_heigh = 85 + view.details.preferredHeight - 36
    view.details_rect.sizeDelta = Manager.Vector2(612, details_heigh)

    str = ""
    if intro and intro.abstract then
        str = intro.abstract
    end
    view.abstract.text = str
    local abstract_heigh = 85 + view.abstract.preferredHeight - 36
    view.abstract_rect.sizeDelta = Manager.Vector2(612, abstract_heigh)

    local heigh = time_heigh + details_heigh + abstract_heigh + 28
    heigh = heigh > 414 and heigh or 414

    view.root:SetActive(true)
end

function RedpacketModule:show_main_bottom_right(show)
    local view = self.view.main_view.bottom.right
    if not show then
        view.root:SetActive(false)
        return
    end

    view.root:SetActive(true)
    -- 更新红包记录视图
    self.view:updateRedRecordView(self.data.record);
end

function RedpacketModule:can_show_cdkey()
    if not(self.data.info and self.data.info.unclaimed) then
        return false
    end

    for k, v in pairs(self.data.info.unclaimed) do
        if "redbag" == k and Manager.ToNumber(v) >= 1 then
            return true
        end
    end

    return false
end

function RedpacketModule:show_popup_view(show)
    local view = self.view.popup_view

    if not show then
        view.root:SetActive(false)
        return
    end

    view.root:SetActive(true)

    if self:can_show_cdkey() then
        self.data.gzh = self.data.gzh or "大胡游戏"
        view.text.text = "1、关注微信公众号“" .. self.data.gzh .. "”；\n2、进入公众号兑奖页面；\n3、填入兑奖码；\n4、领取奖励。"
        view.cdkey.text = "本次兑换码：" .. self.data.cdkey
        view.tips.text = ""
        view.btn_copy.gameObject:SetActive(true)
        view.btn_sure.gameObject:SetActive(false)
    else
        view.tips.text = "可领取余额不足1元，无法领取。"
        view.text.text = ""
        view.cdkey.text = ""
        view.btn_copy.gameObject:SetActive(false)
        view.btn_sure.gameObject:SetActive(true)
    end
end

function RedpacketModule:show_tips_view(show)
    local view = self.view.tips_view

    if not show then
        view.root:SetActive(false)
        return
    end

    local isRobRed = self.data.curRedData.isRobRed;
    local tempRedData = nil;
    -- 固定红包
    if isRobRed == false then
        tempRedData = self.data.myRedData;
        -- 抢红包
    else
        tempRedData = self.data.curRedData;
    end
    view.root:SetActive(true)

    if self.data.partner and self.data.logo then
        view.logo.gameObject:SetActive(true)
        view.name.gameObject:SetActive(true)
        view.logo.texture = self.data.logo
        view.name.text = self.data.partner
        view.title:SetActive(false)
    else
        view.title:SetActive(true)
        view.logo.gameObject:SetActive(false)
        view.name.gameObject:SetActive(false)
    end

    view.icon.sprite = self.view.sprites:FindSpriteByName("" .. tempRedData.type)
    -- Manager.SetNativeSize(view.icon)
    -- 道具类型,取name字段显示内容
    if tempRedData.type == 10 then
        local itemName = Util.decodeBase64(tempRedData.name);
        --超过5个字显示四个字...
        local itemNameFilter = Util.filterPlayerName(itemName, 10);
        view.count.text = itemNameFilter .. "×" .. tempRedData.count;
    else
        view.count.text = tempRedData.count
    end

    -- view.text.text = "现金红包请通过公众号领取"
end

-- 新的分享功能更新后，可判断分享成功与否
function RedpacketModule:share_callback()
    -- Manager.ShowTextPrompt("分享完成")
    self:get_cdkey()
    -- Manager.ShowTextPrompt("分享结果，data = ", data)
    -- local retData = ModuleCache.Json.decode(data)
    -- if retData.errCode == 0 then
    --    Manager.ShowTextPrompt("分享成功，请求获取兑换码")
    --    self:get_cdkey()
    -- else
    --    Manager.ShowTextPrompt("分享失败")
    -- end
end

-- 大厅点击红包雨按钮（红包雨按钮挪到大厅后点击的响应事件）
function RedpacketModule:hall_click_redpacket()
    self:get_redpacket_account()
    self:get_redpacket_award()
end


function RedpacketModule:on_click(obj, arg)
    local objName = obj.name
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")

    if "BtnClose" == objName then
        self:show_main_view(false)

    elseif "BtnMask" == objName then
        self:show_popup_view(false)
        -- 分享遮罩按钮
    elseif "ButtonShareMask" == objName then
        self.view.shareBox:SetActive(false);
        -- 分享朋友圈按钮
    elseif "ButtonShare" == objName then
        -- 请求获取图片分享配置协议
        self:getImageShareConfig(true);
        -- 抢红包或开红包按钮
    elseif "ButtonRobRedpacket" == objName then
        -- 抢红包类型
        if self.data.curRedData.isRobRed then
            self.getQiangRedTimeLine = os.time();
            -- 请求获取抢红包协议
            self:doRobAward(self.data.curRedData.sign);

            -- 固定红包类型
        else
            self.data.isMyselfGetRed = true;
            self:show_tips_view(true)
            self:show_table_btn_anim(false)
        end

        -- 领取按钮
    elseif "BtnGet" == objName then
        -- 大于1块钱才可以领红包,否则弹出领取条件弹出框
        if self:can_show_cdkey() then
            self.view.shareBox:SetActive(true);
        else
            self:show_popup_view(true)
        end
    elseif "BtnCopy" == objName then
        if self.data.cdkey then
            ModuleCache.GameSDKInterface:CopyToClipboard(self.data.cdkey)
            Manager.ShowTextPrompt("兑奖码复制成功")
            self:show_popup_view(false)
        end

    elseif "BtnSure" == objName then
        self:show_popup_view(false)

        -- 收到红包确定按钮
    elseif "BtnTipsSure" == objName then
        self:show_tips_view(false)
        -- 红包雨特效消失
        self.view.anim_hongbaoyu:SetActive(false);
        -- 未收到红包确定按钮
    elseif "BtnFailTipsSure" == objName then
        self.view.weishoudaoCanvas.gameObject:SetActive(false);
        -- 红包雨特效消失
        self.view.anim_hongbaoyu:SetActive(false);

    elseif "Left" == objName then
        self:show_main_center(1)
        self:show_main_bottom(1)

    elseif "Center" == objName then
        self:show_main_center(2)
        self:show_main_bottom(2)

    elseif "Right" == objName then
        self:show_main_center(3)
        self:show_main_bottom(3)
        self:get_redpacket_award()

    else
        print("objName = ", objName)

    end
end

-- 下载头像
function RedpacketModule:startDownLoadHeadIcon(url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if (callback and(not self.isDestroy)) then
                callback(tex)
            end
        else

            if (callback and(not self.isDestroy)) then
                callback(tex)
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end , nil, true)
end

return RedpacketModule