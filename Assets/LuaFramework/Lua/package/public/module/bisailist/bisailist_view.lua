-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local BiSaiListView = Class('BiSaiListView', View)

local ModuleCache = ModuleCache
local Manager = require("manager.function_manager")
local ComponentTypeName = ModuleCache.ComponentTypeName
local ComponentUtil = ModuleCache.ComponentUtil
local CSmartTimer = ModuleCache.SmartTimer.instance
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local MatchingManager = require("package.public.matching_manager")
local ModuleEventBase = require('core.mvvm.module_event_base')
function BiSaiListView:initialize(...)
    -- 初始View
    View.initialize(self, "public/module/bisailist/public_windowbisailist.prefab", "Public_WindowBiSaiList", 1)
    View.set_1080p(self)
    self.itemList = {}
    self.rewardItemList = {}
    self.timeEvent = {}
    self.signupNum = 0
    self.goodsSpriteHolder = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "Center", "SpriteHolder");
    self.rankSpriteHolder = ModuleCache.ComponentManager.GetComponentWithPath(self.root, "SignUp/Right", "SpriteHolder");

    self.goldNum = GetComponentWithPath(self.root, "TopRight/Currency/Gold/TextNum", ComponentTypeName.Text)
    self.diamondNum = GetComponentWithPath(self.root, "TopRight/Currency/Gem/TextNum", ComponentTypeName.Text)
    self.item = GetComponentWithPath(self.root, "Center/ScrollView/Viewport/Content/item", ComponentTypeName.Transform).gameObject
    self.signup = GetComponentWithPath(self.root, "SignUp", ComponentTypeName.Transform).gameObject
    self.rankImg = GetComponentWithPath(self.root, "SignUp/Right/RankImg", ComponentTypeName.Image)
    ComponentUtil.SafeSetActive(self.item, false )
    ComponentUtil.SafeSetActive(self.signup, false )



    --报名界面
    self.signTitleText = GetComponentWithPath(self.root, "SignUp/Background/Title/Text", ComponentTypeName.Text)
    self.signNumText1 = GetComponentWithPath(self.root, "SignUp/Right/Tips/Tips1/HaveNum", ComponentTypeName.Text)
    self.signNumText2 = GetComponentWithPath(self.root, "SignUp/Right/Tips/Tips2/HaveNum", ComponentTypeName.Text)
    self.needNumText = GetComponentWithPath(self.root, "SignUp/Right/Tips/Tips1/NeedNum", ComponentTypeName.Text)
    self.uiStateSignTips = GetComponentWithPath(self.root, "SignUp/Right/Tips", "UIStateSwitcher")
    self.uiStateSignButton = GetComponentWithPath(self.root, "SignUp/Right/Button", "UIStateSwitcher")
    self.signDescText = GetComponentWithPath(self.root, "SignUp/Right/Tips/Tips2/Desc", ComponentTypeName.Text)
    self.signTimeHourText = GetComponentWithPath(self.root, "SignUp/Right/Tips/Tips2/Time/H/Text", ComponentTypeName.Text)
    self.signTimeMinText = GetComponentWithPath(self.root, "SignUp/Right/Tips/Tips2/Time/M/Text", ComponentTypeName.Text)
    self.signFeeNumText = GetComponentWithPath(self.root, "SignUp/Right/Fee/Num", ComponentTypeName.Text)
    self.signFeeIconImg = GetComponentWithPath(self.root, "SignUp/Right/Fee/Icon", ComponentTypeName.Image)
    self.signItem = GetComponentWithPath(self.root, "SignUp/Left/ScrollView/Viewport/Content/item", ComponentTypeName.Transform).gameObject
    ComponentUtil.SafeSetActive(self.signItem, false )

    self.enterText = GetComponentWithPath(self.root, "SignUp/Text", ComponentTypeName.Text)
end

function BiSaiListView:refreshPlayerInfo(roleData)
    if ((not roleData) or (not roleData.cards)) then
        return
    end
    self.diamondNum.text = Util.filterPlayerGoldNum(tonumber(roleData.cards))
    if roleData.gold then
        self.goldNum.text = Util.filterPlayerGoldNum(roleData.gold)
    else
        self.goldNum.text = "0"
    end
end

function BiSaiListView:set_name(name)
    local title = GetComponentWithPath(self.root, "Background/Title/Text", ComponentTypeName.Text)
    title.text = name
end

function BiSaiListView:viewList(data, havebaoming)
    for _, obj in pairs(self.itemList) do
        if obj then
            ComponentUtil.SafeSetActive(obj, false )
        end

    end
    for i = 1, #data do
        local info = data[i]

        local target
        if not self.itemList[i] then
            target = self:clone(i .. "", self.item, self.item.transform.parent)
            self.itemList[i] = target


        else
            target = self.itemList[i]
        end
        local matchIconImg = GetComponentWithPath(target, "Icon", ComponentTypeName.Image)
        local rewardIconImg = GetComponentWithPath(target, "Reward/Icon", ComponentTypeName.Image)

        local matchNameText = GetComponentWithPath(target, "Name", ComponentTypeName.Text)
        local firstRewardText = GetComponentWithPath(target, "Reward/Reward", ComponentTypeName.Text)

        self:startDownLoadHeadIcon(matchIconImg, info.matchImg)
        matchNameText.text = info.matchName
        MatchingManager:goodsNameAndIcon(info.awards[1].awardType, rewardIconImg, firstRewardText,
                info.awards[1].awardNum, info.awards[1].awardItemName, info.awards[1].awardItemIcon, info.awards[1].awardOther, info.awards[1].awardOtherImg, self.goodsSpriteHolder )
        local uiStateTips = GetComponentWithPath(target, "Tips", "UIStateSwitcher")
        uiStateTips:SwitchState(info.matchStartModel .. "")
        ComponentUtil.SafeSetActive(target, true )
        local uiStateBaoMing = GetComponentWithPath(target, "BaoMing", "UIStateSwitcher")
        local descText = GetComponentWithPath(target, "Tips/Tips1/desc", ComponentTypeName.Text)
        local personNumText = GetComponentWithPath(target, "Num/Text", ComponentTypeName.Text)
        if info.matchStartModel == 1 then
            descText = GetComponentWithPath(target, "Tips/Tips1/desc", ComponentTypeName.Text)
            local numText = GetComponentWithPath(target, "Tips/Tips1/Num", ComponentTypeName.Text)
            numText.text = "人数" .. info.currentEntryNum .. "/" .. info.minUserNum
        elseif info.matchStartModel == 2 then
            descText = GetComponentWithPath(target, "Tips/Tips2/desc", ComponentTypeName.Text)
            local timeHourText = GetComponentWithPath(target, "Tips/Tips2/Time/H/Text", ComponentTypeName.Text)
            local timeMinText = GetComponentWithPath(target, "Tips/Tips2/Time/M/Text", ComponentTypeName.Text)
            --倒计时  info.startTimeSecond
            if info.stageStatus == 1 then
                --报名
                if info.entryEndTimeSecond - info.serviceTimeSecond > 0 then
                    self:daojishi(target, timeHourText, timeMinText, info.entryEndTimeSecond, info.serviceTimeSecond)
                else
                    self:daojishi(target, timeHourText, timeMinText, info.startTimeSecond, info.serviceTimeSecond)
                end
            elseif info.stageStatus == 6 or info.stageStatus == 8 then
                if info.preEntryEndTimeSecond - info.serviceTimeSecond > 0 then
                    self:daojishi(target, timeHourText, timeMinText, info.preEntryEndTimeSecond, info.serviceTimeSecond)
                else
                    self:daojishi(target, timeHourText, timeMinText, info.entryStartTimeSecond, info.serviceTimeSecond)
                end

            end
        end
        local baomingText = GetComponentWithPath(target, "BaoMing/BaoMing2/Text", ComponentTypeName.Text)
        local baomingBtn = GetComponentWithPath(target, "BaoMing/BaoMing2", ComponentTypeName.Button)
        if info.stageStatus == 1 then
            personNumText.text = "报名人数 " .. info.currentEntryNum
            if info.matchStartModel == 1 then
                descText.text = "即将开赛"
            else
                descText.text = "报名剩余时间"
            end

            local feeText = GetComponentWithPath(target, "BaoMing/BaoMing1/Fee/Text", ComponentTypeName.Text)
            local feeIconImg = GetComponentWithPath(target, "BaoMing/BaoMing1/Fee/Icon", ComponentTypeName.Image)
            MatchingManager:goodsNameAndIcon(info.entryConditions[1].entryFeeType, feeIconImg, feeText,
                    info.entryConditions[1].entryFeeNum, info.entryConditions[1].entryItemName, info.entryConditions[1].entryItemIcon, nil, nil, self.goodsSpriteHolder)
            if info.matchStartModel == 1 and info.currentEntryNum >= info.maxUserNum then
                uiStateBaoMing:SwitchState("3")
            else
                if info.entryEndTimeSecond - info.serviceTimeSecond > 0 or info.matchStartModel == 1 then
                    uiStateBaoMing:SwitchState("1")
                else
                    uiStateBaoMing:SwitchState("3")
                end

            end

        elseif info.stageStatus == 6 then
            descText.text = "即将报名"
            personNumText.text = "报名人数 " .. info.currentEntryNum
            local feeText = GetComponentWithPath(target, "BaoMing/BaoMing3/Fee/Text", ComponentTypeName.Text)
            local feeIconImg = GetComponentWithPath(target, "BaoMing/BaoMing3/Fee/Icon", ComponentTypeName.Image)
            MatchingManager:goodsNameAndIcon(info.entryConditions[1].entryFeeType, feeIconImg, feeText,
                    info.entryConditions[1].entryFeeNum, info.entryConditions[1].entryItemName, info.entryConditions[1].entryItemIcon, nil, nil, self.goodsSpriteHolder)

            uiStateBaoMing:SwitchState("3")
        elseif info.stageStatus == 8 then
            descText.text = "即将报名"
            if info.isPreEntry then
                personNumText.text = "预约人数 " .. info.preEntryNum
                if info.isUserPreEntry then
                    baomingText.text = "已预约"
                    baomingBtn.enabled = false
                else
                    baomingText.text = "预约"
                    baomingBtn.enabled = true
                end
                local feeText = GetComponentWithPath(target, "BaoMing/BaoMing2/Fee/Text", ComponentTypeName.Text)
                local feeIconImg = GetComponentWithPath(target, "BaoMing/BaoMing2/Fee/Icon", ComponentTypeName.Image)
                MatchingManager:goodsNameAndIcon(info.entryConditions[1].entryFeeType, feeIconImg, feeText,
                        info.entryConditions[1].entryFeeNum, info.entryConditions[1].entryItemName, info.entryConditions[1].entryItemIcon, nil, nil, self.goodsSpriteHolder)

                if info.preEntryEndTimeSecond - info.serviceTimeSecond > 0 then
                    uiStateBaoMing:SwitchState("2")
                else
                    uiStateBaoMing:SwitchState("3")
                end
                --uiStateBaoMing:SwitchState("2")
            else
                personNumText.text = "报名人数 " .. info.currentEntryNum
                local feeText = GetComponentWithPath(target, "BaoMing/BaoMing3/Fee/Text", ComponentTypeName.Text)
                local feeIconImg = GetComponentWithPath(target, "BaoMing/BaoMing3/Fee/Icon", ComponentTypeName.Image)
                MatchingManager:goodsNameAndIcon(info.entryConditions[1].entryFeeType, feeIconImg, feeText,
                        info.entryConditions[1].entryFeeNum, info.entryConditions[1].entryItemName, info.entryConditions[1].entryItemIcon, nil, nil, self.goodsSpriteHolder)

                uiStateBaoMing:SwitchState("3")
            end
        end

    end
end

function BiSaiListView:refreshSignupNum(num)
    if num and num ~= self.signupNum then
        self.signNumText1.text = num .. ""
        self.signNumText2.text = num .. ""
        self.signupNum = num
    end
end

function BiSaiListView:daojishi(obj, hText, mText, time, servertime)
    if not servertime then
        servertime = os.time()
    end
    local surTime = time - servertime
    print("倒计时时间", surTime, time, servertime)
    if surTime > 0 then
        local h = math.floor(surTime / 3600)
        if h > 0 then
            local m = math.ceil((surTime - h * 3600) / 60)
            hText.text = self:paraseNumber(h)
            mText.text = self:paraseNumber(m)
        else
            local m = math.floor((surTime - h * 3600) / 60)
            local s = math.ceil(surTime % 60)
            hText.text = self:paraseNumber(m)
            mText.text = self:paraseNumber(s)
        end
        if self.timeEvent[obj] then
            CSmartTimer:Kill(self.timeEvent[obj].id)
        end
        self.timeEvent[obj] = self:subscibe_time_event(surTime, false, 1):SetIntervalTime(1,
                function( t )
                    if t.surplusTime > 0 then
                        local h = math.floor(t.surplusTime / 3600)
                        local s = math.ceil(t.surplusTime % 60)
                        if h > 0 then
                            local m = math.ceil((t.surplusTime - h * 3600) / 60)
                            hText.text = self:paraseNumber(h)
                            mText.text = self:paraseNumber(m)
                        else
                            local m = math.floor((t.surplusTime - h * 3600) / 60)
                            hText.text = self:paraseNumber(m)
                            mText.text = self:paraseNumber(s)
                        end
                    end
                end
        )                         :OnComplete(function( t )
            hText.text = "00"
            mText.text = "00"

            ModuleEventBase.dispatch_package_event(self, 'Event_Refresh_Matching', obj ~= self.signup)
        end)
    else
        hText.text = "00"
        mText.text = "00"
        ModuleEventBase.dispatch_package_event(self, 'Event_Refresh_Matching', obj ~= self.signup)
    end
end

function BiSaiListView:paraseNumber(num)
    if num < 10 then
        return "0" .. num
    else
        return num .. ""
    end
end

function BiSaiListView:match_info_change(id, data, matchdata)
    if self.itemList[id] then
        local obj = self.itemList[id]
        local personNumText = GetComponentWithPath(obj, "Num/Text", ComponentTypeName.Text)
        if matchdata.matchStartModel == 1 then
            local numText = GetComponentWithPath(obj, "Tips/Tips1/Num", ComponentTypeName.Text)
            numText.text = "人数" .. data.currentEntryNum .. "/" .. matchdata.minUserNum
        end
        if matchdata.stageStatus == 1 then
            personNumText.text = "报名人数 " .. data.currentEntryNum
        elseif matchdata.stageStatus == 6 then
            personNumText.text = "报名人数 " .. data.currentEntryNum
        elseif matchdata.stageStatus == 8 then
            if matchdata.isPreEntry then
                personNumText.text = "预约人数 " .. data.preEntryNum
            else
                personNumText.text = "报名人数 " .. data.currentEntryNum
            end
        end
        self:refreshSignupNum(data.currentEntryNum)
    end
end

function BiSaiListView:baoming(info, state)

    self.signTitleText.text = info.matchName
    self.uiStateSignTips:SwitchState(info.matchStartModel .. "")
    self.signupNum = info.currentEntryNum
    if info.matchStartModel == 1 then
        self.signNumText1.text = info.currentEntryNum
        self.needNumText.text = info.minUserNum
    elseif info.matchStartModel == 2 then
        --倒计时  info.startTimeSecond
        self.signNumText2.text = info.currentEntryNum
        self:daojishi(self.signup, self.signTimeHourText, self.signTimeMinText, info.startTimeSecond, info.serviceTimeSecond)
    end
    MatchingManager:goodsNameAndIcon(info.entryConditions[1].entryFeeType, self.signFeeIconImg, self.signFeeNumText,
            info.entryConditions[1].entryFeeNum, info.entryConditions[1].entryItemName, info.entryConditions[1].entryItemIcon, nil, nil, self.goodsSpriteHolder)
    self.uiStateSignButton:SwitchState(state)
    for i = 1, #self.rewardItemList do
        ComponentUtil.SafeSetActive(self.rewardItemList[i], false )
    end
    for i = 1, #info.awards do
        local awards = info.awards[i]
        local item
        if not self.rewardItemList[awards.rank] then
            item = self:clone(awards.awardId, self.signItem, self.signItem.transform.parent)
            self.rewardItemList[awards.rank] = item
        else
            item = self.rewardItemList[awards.rank]
        end
        local rankText = GetComponentWithPath(item, "Rank", ComponentTypeName.Text)
        local feeText = GetComponentWithPath(item, "Fee/Num", ComponentTypeName.Text)
        local iconImg = GetComponentWithPath(item, "Fee/Icon", ComponentTypeName.Image)
        rankText.text = "第" .. awards.rank .. "名"
        MatchingManager:goodsNameAndIcon(awards.awardType, iconImg, feeText, awards.awardNum, awards.itemName, awards.itemIcon, awards.awardOther, awards.awardOtherImg, self.goodsSpriteHolder)
        ComponentUtil.SafeSetActive(item, true )
    end
    ComponentUtil.SafeSetActive(self.enterText.transform.gameObject, false )
end

function BiSaiListView:enter_text()
    ComponentUtil.SafeSetActive(self.enterText.transform.gameObject, true )
end

function BiSaiListView:baoming_success()
    self.uiStateSignButton:SwitchState("1")
end

function BiSaiListView:tuisai_success()
    self.uiStateSignButton:SwitchState("2")
end

function BiSaiListView:signUpView(view)
    ComponentUtil.SafeSetActive(self.signup, view)
end

function BiSaiListView:maxRank(rank)
    if rank > 0 and rank < 4 then
        self.rankImg.sprite = self.rankSpriteHolder:FindSpriteByName(rank .. "")
    end
end


--下载头像
function BiSaiListView:startDownLoadHeadIcon(targetImage, url)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (not err) then
            if targetImage then
                targetImage.sprite = tex
                targetImage:SetNativeSize()
            end
        end
    end)
end

function BiSaiListView:clone(name, obj, parent)
    local target = ComponentUtil.InstantiateLocal(obj, Vector3.zero)
    if not parent then
        parent = obj.transform.parent
    end
    target.transform:SetParent(parent.transform)
    target.transform.localScale = Vector3.one
    target.name = tostring(name)
    ComponentUtil.SafeSetActive(target, true)
    return target
end

return BiSaiListView