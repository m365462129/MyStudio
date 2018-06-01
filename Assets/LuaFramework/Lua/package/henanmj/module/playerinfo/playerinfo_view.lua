-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local PlayerInfoView = Class('playerInfoView', View)

local ModuleCache = ModuleCache
local CSmartTimer = ModuleCache.SmartTimer.instance
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple

function PlayerInfoView:initialize()
    -- 初始View
    View.initialize(self, "henanmj/module/playerinfo/henanmj_windowplayerinfo.prefab", "HeNanMJ_WindowPlayerInfo", 1)
    View.set_1080p(self)

    self.spriteHolder = GetComponentWithSimple(self.root, "SpriteHolder", "SpriteHolder");

    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);
    self.buttonMask = GetComponentWithSimple(self.root, "SpriteMask", ComponentTypeName.Button);
    -- 复制按钮
    self.buttonCopy = GetComponentWithSimple(self.root, "ButtonCopy", ComponentTypeName.Button);

    -- 性别图标
    self.spriteMale = GetComponentWithSimple(self.root, "SpriteMale", ComponentTypeName.Image);
    -- 头像图标
    self.spriteAvatar = GetComponentWithSimple(self.root, "SpriteAvatar", ComponentTypeName.Image);
    -- 玩家名字标签
    self.labelName = GetComponentWithSimple(self.root, "LabelName", ComponentTypeName.Text);
    -- 玩家id标签
    self.labelID = GetComponentWithSimple(self.root, "LabelID", ComponentTypeName.Text);
    -- ip标签
    self.labelIP = GetComponentWithSimple(self.root, "LabelIP", ComponentTypeName.Text);
    -- 位置标签
    self.labelLocationDoc = GetComponentWithSimple(self.root, "LabelLocationDoc", ComponentTypeName.Text);
    self.labelLocation = GetComponentWithSimple(self.root, "LabelLocation", ComponentTypeName.Text);
    -- 签名输入框
    self.inputSign = GetComponentWithSimple(self.root, "InputSign", ComponentTypeName.InputField);
    self.inputSign.interactable = false;

    self.goGiftPanel = GetComponentWithSimple(self.root, "Gifts", ComponentTypeName.Transform).gameObject
    self.giftButtonHolders = {}
    self.gift_buttonNames = {
        ButtonRose = 'rose',
        ButtonRing = 'ring',
        ButtonBomb = 'bomb',
        ButtonEgg = 'egg',
        ButtonBrick = 'brick',
        ButtonKiss = 'kiss',
    }
    for i, v in pairs(self.gift_buttonNames) do
        local holder = {}
        holder.key = v
        holder.button = GetComponentWithSimple(self.goGiftPanel, i, ComponentTypeName.Button)
        holder.mask = GetComponentWithSimple(holder.button.gameObject, 'Mask', ComponentTypeName.Image)
        self.giftButtonHolders[i] = holder
    end
    self.modelData = require("package.henanmj.model.model_data")
    print("牌桌类型：",self.modelData.tableCommonData.tableType )
    if self.modelData.tableCommonData.tableType == 1 then
        self.labelID.gameObject:SetActive(false)
        self.labelIP.gameObject:SetActive(false)
        self.labelLocationDoc.gameObject:SetActive(false)
        self.labelLocation.gameObject:SetActive(false)
    end
end

function PlayerInfoView:init(playerInfo)

    -- 用户信息
    self.playerInfo = playerInfo;

    -- 更新玩家信息视图
    self:updatePlayerInfoView();

end

function PlayerInfoView:show_gift_panel(show)
    ModuleCache.ComponentUtil.SafeSetActive(self.goGiftPanel, show or false)
    if (show) then
        local lastSendTimestamp = self:get_last_send_time()
        local interval = os.time() - lastSendTimestamp
        local realTime = UnityEngine.Time.realtimeSinceStartup
        local lastSendTime = realTime - interval
        local coolTime = 15
        if (interval < coolTime) then
            for i, v in pairs(self.giftButtonHolders) do
                local holder = v
                if (holder.timeEventId) then
                    CSmartTimer:Kill(holder.timeEventId)
                    holder.timeEventId = nil
                end
                self:set_gift_btn_mask(holder, 1)
                local timeEvent = self:subscibe_time_event(coolTime - interval, false, 1):SetIntervalTime(0.01):OnUpdate(function()
                    local val = UnityEngine.Time.realtimeSinceStartup - lastSendTime
                    val = 1 - val / coolTime
                    self:set_gift_btn_mask(holder, val)
                end)                  :OnComplete(function(t)
                    self:set_gift_btn_mask(holder, 0)
                end)
                holder.timeEventId = timeEvent.id
            end
        else
            for i, v in pairs(self.giftButtonHolders) do
                local holder = v
                if (holder.timeEventId) then
                    CSmartTimer:Kill(holder.timeEventId)
                    holder.timeEventId = nil
                end
                self:set_gift_btn_mask(holder, 0)
            end
        end
    end
end

function PlayerInfoView:set_gift_btn_mask(holder, val)
    if (val <= 0) then
        holder.button.enabled = true
        holder.mask.fillAmount = 0
    else
        holder.button.enabled = false
        holder.mask.fillAmount = math.min(1, val)
    end
end

function PlayerInfoView:get_last_send_time()
    return UnityEngine.PlayerPrefs.GetInt("Last_Send_Gift_Timestamp", 0)
end

function PlayerInfoView:set_last_send_time(time)
    time = time or os.time()
    return UnityEngine.PlayerPrefs.SetInt("Last_Send_Gift_Timestamp", time)
end

-- 更新玩家信息视图
function PlayerInfoView:updatePlayerInfoView()

    self.inputSign.text = "";
    -- 过滤玩家名字
    -- local filterPlayerName = Util.filterPlayerName(self.userInfo.nickname, 10);
    -- 玩家名字
    print_table(self.playerInfo, "wanjia shu ju")
    if (self.playerInfo.textPlayerName) then
        self.labelName.text = Util.filterPlayerName(self.playerInfo.textPlayerName.text, 10)
    elseif self.playerInfo.nickname then
        self.labelName.text = Util.filterPlayerName(self.playerInfo.nickname, 10)
    else
        self.labelName.text = Util.filterPlayerName(self.playerInfo.playerName, 10)
    end
    -- 玩家id
    if self.playerInfo.playerId then
        self.labelID.text = "ID:" .. self.playerInfo.playerId
    else
        self.labelID.text = "ID:" .. self.playerInfo.userId
    end

    -- 玩家头像
    if (self.playerInfo.imagePlayerHead) then
        self.spriteAvatar.sprite = self.playerInfo.imagePlayerHead.sprite
    elseif (self.playerInfo.spriteHeadImage) then
        self.spriteAvatar.sprite = self.playerInfo.spriteHeadImage
    else
        self:startDownLoadHeadIcon(self.spriteAvatar, self.playerInfo.headImg)
    end

    local locationData = self.playerInfo.locationData;
    if (locationData) then
        if (locationData.address) then
            self.labelLocation.text = self:format_location_address(locationData.address)
        else
            self.labelLocation.text = "位置获取失败";
        end
    else
        self.labelLocation.text = "位置获取中";
    end
    local isGoldRoomType = TableManager:cur_game_is_gold_room_type()
    ModuleCache.ComponentUtil.SafeSetActive(self.labelLocationDoc.gameObject, not isGoldRoomType)
    ModuleCache.ComponentUtil.SafeSetActive(self.labelLocation.gameObject, not isGoldRoomType)
    -- ip
    if (self.playerInfo.ip) and (not isGoldRoomType) then
        self.labelIP.text = "IP:" .. self.playerInfo.ip;
    else
        self.labelIP.text = "";
    end

    -- 男
    if self.playerInfo.gender == 1 then
        self.spriteMale.sprite = self.spriteHolder:FindSpriteByName("male");
        -- 女
    elseif self.playerInfo.gender == 2 then
        self.spriteMale.sprite = self.spriteHolder:FindSpriteByName("female");
    end
end


-- 下载头像
function PlayerInfoView:startDownLoadHeadIcon(targetImage, url)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (not err) then
            if targetImage then
                targetImage.sprite = tex
                -- targetImage:SetNativeSize();
            end
        end
    end)
end

function PlayerInfoView:format_location_address(address)
    local str = address
    local startPos, endPos = string.find(address, '市')
    if (endPos and endPos > 1) then
        str = string.sub(address, 1, endPos)
    end
    --print(address, startPos, endPos, str)
    return str
end

-- 更新个人签名视图
function PlayerInfoView:updateSignView(userInfo)

    -- 签名数据不为空,更新签名数据
    if userInfo.signature ~= "" then
        self.inputSign.text = userInfo.signature;
    end
end

return PlayerInfoView