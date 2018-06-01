-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local MuseumRoomInfoView = Class('museumroominfoView', View)

local ModuleCache = ModuleCache
local ViewUtil = ModuleCache.ViewUtil;
local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
local TableUtil = TableUtil

function MuseumRoomInfoView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/museumroominfo/henanmj_museumroominfo.prefab", "HeNanMJ_MuseumRoomInfo", 1)
    View.set_1080p(self)

    self.stateSwitcher = ModuleCache.ComponentManager.GetComponent(self.root, "UIStateSwitcher")

    self.buttonClose = GetComponentWithPath(self.root, "Center/Child/Bg/closeBtn", ComponentTypeName.Button)

    self.buttonShare = GetComponentWithPath(self.root, "Center/Child/bottom/ButtonShare", ComponentTypeName.Button)
    self.buttonDismiss = GetComponentWithPath(self.root, "Center/Child/bottom/ButtonDismiss", ComponentTypeName.Button)
    self.buttonCancel = GetComponentWithPath(self.root, "Center/Child/bottom/ButtonCancel", ComponentTypeName.Button)
    self.buttonJoinRoom = GetComponentWithPath(self.root, "Center/Child/bottom/ButtonJoinRoom", ComponentTypeName.Button)

    self.roomTypeTex = GetComponentWithPath( self.root, "Center/Child/panel/RoomType/text",ComponentTypeName.Text)
    self.roomNumberTex = GetComponentWithPath( self.root, "Center/Child/panel/RoomNumber/text",ComponentTypeName.Text)
    self.roomWanFaTex = GetComponentWithPath( self.root, "Center/Child/panel/RoomWanFa/text",ComponentTypeName.Text)
end

function MuseumRoomInfoView:init_view(data)
    self.data = data
    local data = data.data

    local wanfaName = ""
    local ruleName = ""
    local renshu = 4
    
    local rule = ModuleCache.Json.decode(data.playRule)
    rule.PayType = -1
    rule = ModuleCache.Json.encode(rule)
    wanfaName,ruleName,renshu = TableUtil.get_rule_name(rule , false)

    self.roomWanFaTex.text = ruleName
    self.buttonDismiss.gameObject:SetActive(false)

    if tonumber(data.roomId) <100000 then
        self.roomNumberTex.text = data.roomId.."(不可解散)"
    else
        self.roomNumberTex.text = data.roomId
        if self.data.museumData.playerRole == "OWNER" or self.data.museumData.playerRole == "ADMIN" then
            self.buttonDismiss.gameObject:SetActive(true)
        end
    end

    if(data.roomType == 1) then
        self.roomTypeTex.text = "自由开房"
    else
        self.roomTypeTex.text = "快速组局"
    end
end



return MuseumRoomInfoView