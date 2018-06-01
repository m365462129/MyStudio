-- UICreator 自动生成
-- 层级调整请改变 View.initialize(self, value1, value2, value3) 的Value3
-- 若是特殊UI，请自行调整

-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local verifynameView = Class('verifynameView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName

function verifynameView:initialize(...)
    -- 初始View 
    View.initialize(self, "public/module/verifyname/public_windowverifyname.prefab", "Public_WindowVerifyName", 1)
    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    self.buttonClose = GetComponentWithPath(self.root, "ButtonClose", ComponentTypeName.Button)
    self.buttonGet = GetComponentWithPath(self.root, "ButtonGet", ComponentTypeName.Button)
    self.buttonGrey = GetComponentWithPath(self.root, "ButtonGrey", ComponentTypeName.Button)
    self.buttonVerify = GetComponentWithPath(self.root, "ButtonVerify", ComponentTypeName.Button)
    self.textDesc = GetComponentWithPath(self.root, "Desc", ComponentTypeName.Text)
    self.inputName = GetComponentWithPath(self.root, "Name/InputField", ComponentTypeName.InputField)
    self.inputIdNum = GetComponentWithPath(self.root, "Number/InputField", ComponentTypeName.InputField)
    self.inputPhoneNum = GetComponentWithPath(self.root, "Phone/InputField", ComponentTypeName.InputField)
    self.inputVerifyNum = GetComponentWithPath(self.root, "Verify/InputField", ComponentTypeName.InputField)
    self.textGet = GetComponentWithPath(self.root, "ButtonGrey/Text", ComponentTypeName.Text)
end


function verifynameView:set_desc_text(coins)
    self.textDesc.text = string.format("填写正确的身份信息，通过验证后可获得%d钻石的奖励", coins)
end

function verifynameView:get_btn_deal(canclick)
    self.buttonGet.gameObject:SetActive(false)
    self.buttonGrey.gameObject:SetActive(true)
    self.inputName.interactable = false
    self.inputIdNum.interactable = false
    self.inputPhoneNum.interactable = false
    self:subscibe_time_event(99, false, 1):OnUpdate(
    function( t )
        self.textGet.text = string.format("%d秒后再次获取", t.surplusTimeRound)
    end
    ):OnComplete(function( t )
        self.buttonGrey.gameObject:SetActive(false)
        self.buttonGet.gameObject:SetActive(true)
        self.inputName.interactable = true
        self.inputIdNum.interactable = true
        self.inputPhoneNum.interactable = true
    end)
end

return verifynameView