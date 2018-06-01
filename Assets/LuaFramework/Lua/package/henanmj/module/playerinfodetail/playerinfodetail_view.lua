-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local PlayerInfoDetailView = Class('playerInfoDetailView', View)
local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName
local ComponentUtil = ModuleCache.ComponentUtil
local GetComponentWithSimple = ModuleCache.ComponentUtil.GetComponentWithSimple
local cjson = require("cjson");

function PlayerInfoDetailView:initialize()
    -- 初始View
    View.initialize(self, "henanmj/module/playerinfodetail/henanmj_playerinfodetail.prefab", "HeNanMJ_PlayerInfoDetail", 1)
    View.set_1080p(self)

    self.spriteHolder = GetComponentWithSimple(self.root, "SpriteHolder", "SpriteHolder");

    self.buttonBack = GetComponentWithSimple(self.root, "ButtonBack", ComponentTypeName.Button);
    -- 复制按钮
    self.buttonCopy = GetComponentWithSimple(self.root, "ButtonCopy", ComponentTypeName.Button);
    -- 更换账号按钮
    self.buttonChangeAccount = GetComponentWithSimple(self.root, "ButtonChangeAccount", ComponentTypeName.Button);
    -- 退出游戏按钮
    self.buttonExitGame = GetComponentWithSimple(self.root, "ButtonExitGame", ComponentTypeName.Button);
    -- 编辑按钮
    self.buttonEdit = GetComponentWithSimple(self.root, "ButtonEdit", ComponentTypeName.Button);
    local onButtonEdit = function()
        -- 点击编辑按钮
        self:onClickEditButton();
    end
    self.buttonEdit.onClick:AddListener(onButtonEdit);
    -- 保存按钮
    self.buttonSave = GetComponentWithSimple(self.root, "ButtonSave", ComponentTypeName.Button);
    local onButtonSave = function()
        -- 点击保存按钮
        self:onClickSaveButton();
    end
    self.buttonSave.onClick:AddListener(onButtonSave);
    -- 性别图标
    self.spriteMale = GetComponentWithSimple(self.root, "SpriteMale", ComponentTypeName.Image);
    -- 头像图标
    self.spriteAvatar = GetComponentWithSimple(self.root, "SpriteAvatar", ComponentTypeName.Image);
    -- 玩家名字标签
    self.labelName = GetComponentWithSimple(self.root, "LabelName", ComponentTypeName.Text);
    -- 玩家id标签
    self.labelID = GetComponentWithSimple(self.root, "LabelID", ComponentTypeName.Text);
    -- 签名输入框
    self.inputSign = GetComponentWithSimple(self.root, "InputSign", ComponentTypeName.InputField);
    -- 功能按钮父物体
    self.buttonsParent = GetComponentWithSimple(self.root, "ButtonsGO", ComponentTypeName.Transform).gameObject;
end

function PlayerInfoDetailView:init(showType, userInfo, module)

    self.showType = showType;
    if self.showType == 1 then
        self.inputSign.interactable = true;
        self.buttonsParent:SetActive(true);
    elseif self.showType == 2 then
        self.buttonsParent:SetActive(false);
        self.inputSign.interactable = false;
    end
    -- 用户信息
    self.userInfo = userInfo;
    self.model = module.model;

    -- 更新玩家信息视图
    self:updatePlayerInfoView();

end

-- 更新玩家信息视图
function PlayerInfoDetailView:updatePlayerInfoView()

    -- 过滤玩家名字
    local filterPlayerName = Util.filterPlayerName(self.userInfo.nickname, 10);
    -- 玩家名字
    self.labelName.text = filterPlayerName;
    -- 玩家id
    self.labelID.text = "ID:" .. self.userInfo.userId;

    local onPlayerAvatar = function(sprite)
        -- 玩家头像
        self.spriteAvatar.sprite = sprite;
    end
    self:startDownLoadHeadIcon(self.userInfo.headImg, onPlayerAvatar);

    -- 男
    if self.userInfo.gender == 1 then
        self.spriteMale.sprite = self.spriteHolder:FindSpriteByName("male");
        -- 女
    elseif self.userInfo.gender == 2 then
        self.spriteMale.sprite = self.spriteHolder:FindSpriteByName("female");
    end

    -- 签名数据不为空,更新签名数据
    if self.userInfo.signature ~= "" then
        self.inputSign.text = self.userInfo.signature;
    end
end

-- 下载头像
function PlayerInfoDetailView:startDownLoadHeadIcon(url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if (err) then
            print('error down load ' .. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(url, 'http') == 1 then
                if (self) then
                    -- self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if (callback) then
                callback(tex)
            end
        end
    end , nil, true)
end

-- 点击编辑按钮
function PlayerInfoDetailView:onClickEditButton()

    --  self.inputSign.interactable = true;
end

-- 点击保存按钮
function PlayerInfoDetailView:onClickSaveButton()

    print("签名==", self.inputSign.text);
    -- 去空格
    local sign = Util.trim(self.inputSign.text);
    if sign == "" then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("签名不能为空");
        return;
    end
    -- 请求保存签名协议
    self.model:saveSign(sign);
end
return PlayerInfoDetailView;