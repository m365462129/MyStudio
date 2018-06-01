-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableRuleModule = class("tableRuleModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine

function TableRuleModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "tablerule_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function TableRuleModule:on_module_inited()

end

-- 绑定module层的交互事件
function TableRuleModule:on_module_event_bind()

end

-- 绑定loginModel层事件，模块内交互
function TableRuleModule:on_model_event_bind()
	

end

function TableRuleModule:on_show(rule)
     self.view:initVie(rule)
     self.rule = rule
     self:showToggles()
end

function TableRuleModule:showToggles()
    local ruleTable = self.rule.ruleInfo
    if(not ruleTable)then
        return nil
    end
    
     print_table(ruleTable);

    -- 局数
    print("--------- ruleTable.roundCount = "..ruleTable.roundCount)
    self.view.roundSelector.toggele8.isOn = ruleTable.roundCount == 8
    self.view.roundSelector.toggele10.isOn = ruleTable.roundCount == 10
    self.view.roundSelector.toggele16.isOn = ruleTable.roundCount == 16
    self.view.roundSelector.toggele20.isOn = ruleTable.roundCount == 20
    self.view.roundSelector.toggele30.isOn = ruleTable.roundCount == 30

    print("self.view.roundSelector.toggele16.isOn = "..tostring(self.view.roundSelector.toggele16.isOn))

    -- 花牌
    self.view.huapaiiMode.toggeleHave.isOn = ruleTable.haveJQK == 1
    self.view.huapaiiMode.toggeleNot.isOn = ruleTable.haveJQK == 0


    -- 倍率
    if ruleTable.isBigBet ~= nil then
        self.view.beiLvSelector.toggeleSmall.isOn = ruleTable.isBigBet == 0
        self.view.beiLvSelector.toggeleBig.isOn = ruleTable.isBigBet == 1

    end

    -- 坐庄
    if ruleTable.bankerType ~= nil then
        self.view.zuozhuangSelector.toggle1.isOn = ruleTable.bankerType == 0
        self.view.zuozhuangSelector.toggle2.isOn = ruleTable.bankerType == 1
        self.view.zuozhuangSelector.toggle3.isOn = ruleTable.bankerType == 2
    end

    -- 玩法
    if ruleTable.ruleType ~= nil then
        self.view.wanfaSelector.toggle1.isOn = ruleTable.ruleType == 1

    end

    -- 押注
    if ruleTable.maxBetScore ~= nil then
        self.view.yazhuSelector.toggle1.isOn = ruleTable.maxBetScore == 6
        self.view.yazhuSelector.toggle2.isOn = ruleTable.maxBetScore == 10

    end

    -- 支付
    if ruleTable.payType ~= nil then
        self.view.paySelector.toggle1.isOn = ruleTable.payType == 0
        self.view.paySelector.toggle2.isOn = ruleTable.payType == 1
        self.view.paySelector.toggle3.isOn = ruleTable.payType == 2
    end
end

function TableRuleModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("cowboy", "tablerule")
	end
end

return TableRuleModule