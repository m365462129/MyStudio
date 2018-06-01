-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableRuleModule = class("tableRuleModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local roundNums = {4, 8, 16}
local playerNums = {4, 3}
local masterCostTips = {"消耗大赢家体力","体力均摊"}
local masterCostTips_card = {"消耗圈主钻石","","钻石均摊"}--新增需求 后台可以设置钻石 

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

function TableRuleModule:refresh_toggle_view(toggles)
	if(self.roundCount == 6) then
		self.roundCount = 4
	end
	for i=1,#toggles[1] do
		toggles[1][i].isOn = (self.roundCount == roundNums[i])
	end
	if(self.wanfaType == 1) then
		if self.playRule.BuKeJiePao then
			toggles[2][1].isOn = true
			toggles[2][2].isOn = false
		else
			toggles[2][1].isOn = false
			toggles[2][2].isOn = true
		end

		for i=1,#toggles[4] do
			if(i ~= 4) then
				toggles[4][i].isOn = (i == self.playRule.ZhaMa + 1 -3)
			else
				toggles[4][i].isOn = (self.playRule.ZhaMa == 2)
			end
		end
		toggles[3][1].isOn = self.playRule.YouLaiZi
		toggles[3][2].isOn = self.playRule.ZhiNengPengYiDui
		
		for i=1,#playerNums do
			toggles[5][i].isOn = (self.playerCount == playerNums[i])
		end

	--芜湖市- 无为
	elseif(self.wanfaType == 2) then 
		toggles[2][1].isOn = self.playRule.WuTongKaiGuan
		toggles[2][2].isOn = self.playRule.LaoXiaoWanFa

		if self.playRule.QiFanDuiZiShu == 3 then
			toggles[3][1].isOn = true
		else
			toggles[3][2].isOn = true
		end

		for i=1,#playerNums do
			toggles[4][i].isOn = (self.playerCount == playerNums[i])
		end
	--芜湖市- 南陵
	elseif(self.wanfaType == 3) then 
		toggles[2][1].isOn = self.playRule.QueYiSeKeTing
		toggles[2][2].isOn = self.playRule.JiuZhiQiHu
		toggles[2][3].isOn = self.playRule.DaXingZi
		toggles[2][4].isOn = self.playRule.FengYiSe
		toggles[2][5].isOn = self.playRule.QingYiSeDingJiu
		toggles[2][6].isOn = self.playRule.HaiLao

		if self.playRule.ZhuangJiaFen == 5 then
			toggles[3][1].isOn = true
		elseif self.playRule.ZhuangJiaFen == 10 then
			toggles[3][2].isOn = true
		else
			toggles[3][3].isOn = true
		end

		for i=1,#playerNums do
			toggles[4][i].isOn = (self.playerCount == playerNums[i])
		end

	--亳州市- 利辛 涡阳 蒙城	
	elseif(self.wanfaType == 4) then 
		toggles[2][1].isOn = self.playRule.ShuiFangPaoChuFen
		toggles[2][2].isOn = self.playRule.AnGangMingPai

		if self.playRule.HuaPaiNum == 20 then
			toggles[4][1].isOn = true
			toggles[4][2].isOn = false
		else
			toggles[4][1].isOn = false
			toggles[4][2].isOn = true
		end

		for i=1,#playerNums do
			toggles[3][i].isOn = (self.playerCount == playerNums[i])
		end
	elseif(self.wanfaType == 5) then 
		toggles[2][1].isOn = self.playRule.ShuiFangPaoChuFen
		toggles[2][2].isOn = self.playRule.AnGangMingPai

		if self.playRule.HuaPaiNum == 20 then
			toggles[4][1].isOn = true
			toggles[4][2].isOn = false
		else
			toggles[4][1].isOn = false
			toggles[4][2].isOn = true
		end

		for i=1,#playerNums do
			toggles[3][i].isOn = (self.playerCount == playerNums[i])
		end
	elseif(self.wanfaType == 6) then 
		toggles[2][1].isOn = self.playRule.ShuiFangPaoChuFen
		toggles[2][2].isOn = self.playRule.AnGangMingPai

		if self.playRule.HuaPaiNum == 20 then
			toggles[4][1].isOn = true
			toggles[4][2].isOn = false
		else
			toggles[4][1].isOn = false
			toggles[4][2].isOn = true
		end

		for i=1,#playerNums do
			toggles[3][i].isOn = (self.playerCount == playerNums[i])
		end
	elseif(self.wanfaType == 7) then 
		toggles[2][1].isOn = self.playRule.ZhuangFanBei
		toggles[2][2].isOn = self.playRule.QingYiSeJiaDiFeng

		for i=1,#playerNums do
			toggles[3][i].isOn = (self.playerCount == playerNums[i])
		end
	end
 end

function TableRuleModule:on_click(obj, arg)	
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("biji", "tablerule")
	end
end

function TableRuleModule:refreshRuleSelected()
    local ruleTable = self.rule.ruleInfo
    if(not ruleTable)then
        return nil
    end
	if(ruleTable.roundCount == 8) then
		self.view.roundSelector.toggeleEight.isOn = true
		self.view.roundSelector.toggeleSixteen.isOn = false
		self.view.roundSelector.toggeleTwentyFourteen.isOn = false
	elseif(ruleTable.roundCount == 16) then
		self.view.roundSelector.toggeleEight.isOn = false
		self.view.roundSelector.toggeleSixteen.isOn = true
		self.view.roundSelector.toggeleTwentyFourteen.isOn = false
	elseif(ruleTable.roundCount == 24) then
		self.view.roundSelector.toggeleEight.isOn = false
		self.view.roundSelector.toggeleSixteen.isOn = false
		self.view.roundSelector.toggeleTwentyFourteen.isOn = true
	end
    if(ruleTable.hasKing == true)then
        self.view.hasKingSelector.toggleDoubleKing.isOn = true
        self.view.hasKingSelector.toggleNoKing.isOn = false
    elseif(ruleTable.hasKing == false)then
        self.view.hasKingSelector.toggleDoubleKing.isOn = false
        self.view.hasKingSelector.toggleNoKing.isOn = true
    end    

	if(ruleTable.pokersNum == 9)then
        self.view.pokersNumber.toggleNine.isOn = true
        self.view.pokersNumber.toggleTen.isOn = false
    elseif(ruleTable.pokersNum == 10)then
        self.view.pokersNumber.toggleNine.isOn = false
        self.view.pokersNumber.toggleTen.isOn = true
    end

    if(ruleTable.allowHalfEnter == true)then
        self.view.halfEnterSelector.toggleNoHalfEnter.isOn = false
    elseif(ruleTable.allowHalfEnter == false)then
        self.view.halfEnterSelector.toggleNoHalfEnter.isOn = true
		
    end    
	if(ruleTable.scoreType == 0) then
		self.view.scoreMode.toggeleNormal.isOn = true;
		self.view.scoreMode.toggeleCertain.isOn = false;
	elseif(ruleTable.scoreType == 1) then
		self.view.scoreMode.toggeleNormal.isOn = false;
		self.view.scoreMode.toggeleCertain.isOn = true;
	end

	if(ruleTable.gameType == 0) then
		self.view.titleTex.text = "欢乐比鸡";
		if(ruleTable.scoreType == 0) then
			self.view.xipaiMode.normalText.text = "喜牌（总人数-1）*1\n三顺清与全三条喜牌分数加倍";
			self.view.xipaiMode.certainText.text = "清连顺/连顺/三顺清/全三条/四个头/三清*6\n双顺清/双三条/三顺子*3，全黑/全红*3";
		elseif(ruleTable.scoreType == 1) then
			self.view.xipaiMode.normalText.text = "喜牌（总人数-1）*2\n三顺清与全三条喜牌分数加倍";
			self.view.xipaiMode.certainText.text = "清连顺/连顺/三顺清/全三条/四个头/三清*12\n双顺清/双三条/三顺子*6，全黑/全红*3";
		end
	elseif(ruleTable.gameType == 1) then
		self.view.titleTex.text = "舒城比鸡";
		if(ruleTable.scoreType == 0) then
			self.view.xipaiMode.normalNewText.text = "四个头（总人数-1）*1";
			self.view.xipaiMode.certainNewText.text = "四个头*6";
		elseif(ruleTable.scoreType == 1) then
			self.view.xipaiMode.normalNewText.text = "四个头（总人数-1）*2";
			self.view.xipaiMode.certainNewText.text = "四个头*12";
		end
	end
	if(ruleTable.payType == 0) then
		self.view.payMode.toggeleAA.isOn = true;
		self.view.payMode.toggeleCreator.isOn = false;
		self.view.payMode.toggeleWinner.isOn = false;
	elseif(ruleTable.payType == 1) then
		self.view.payMode.toggeleAA.isOn = false;
		self.view.payMode.toggeleCreator.isOn = true;
		self.view.payMode.toggeleWinner.isOn = false;
	elseif(ruleTable.payType == 2) then
		self.view.payMode.toggeleAA.isOn = false;
		self.view.payMode.toggeleCreator.isOn = false;
		self.view.payMode.toggeleWinner.isOn = true;
	end
    if(type(ruleTable.extraScoreTypes) == "number")then
        local value = ruleTable.extraScoreTypes
        --for i=1,#self.view.extraScoreSelector.selectArray do
            --local num = (bit:_lshift(1 , i - 1))
            --local tmp = bit:_and(value , num)
            --self.view.extraScoreSelector.selectArray[i].isOn = tmp ~= 0
        --end
		if(value == 16) then
			self.view.xipaiMode.toggeleNormal.isOn = true;
			self.view.xipaiMode.toggeleCertain.isOn = false;
			if(ruleTable.gameType == 0) then			
				self.view.normalModeTips:SetActive(true);
				self.view.certainModeTips:SetActive(false);
				self.view.normalModeNewTips:SetActive(false);
				self.view.certainModeNewTips:SetActive(false);
			elseif(ruleTable.gameType == 1) then
				self.view.normalModeTips:SetActive(false);
				self.view.certainModeTips:SetActive(false);
				self.view.normalModeNewTips:SetActive(true);
				self.view.certainModeNewTips:SetActive(false);
			end
		elseif(value == 15) then
			self.view.xipaiMode.toggeleNormal.isOn = false;
			self.view.xipaiMode.toggeleCertain.isOn = true;
			if(ruleTable.gameType == 0) then			
				self.view.normalModeTips:SetActive(false);
				self.view.certainModeTips:SetActive(true);
				self.view.normalModeNewTips:SetActive(false);
				self.view.certainModeNewTips:SetActive(false);
			elseif(ruleTable.gameType == 1) then
				self.view.normalModeTips:SetActive(false);
				self.view.certainModeTips:SetActive(false);
				self.view.normalModeNewTips:SetActive(false);
				self.view.certainModeNewTips:SetActive(true);
			end
			
		end
    end
   


    return ruleTable
end


function TableRuleModule:on_show(rule)
	if(rule.name == "biji") then
		self.view.panelChilds[1]:SetActive(true);
		self.view.titleTex.text = "欢乐比鸡";
		self.rule = rule;
		self:refreshRuleSelected();

		self.view.payTypeObj:SetActive( not (self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0))
		--TODO XLQ 亲友圈在房间中的规则  消耗类型显示为亲友圈设置的类型   由于快速组局进入的房间不知道consumeType  所以先注销 掉此功能
		-- self.view.payTypeObj_museum.gameObject:SetActive( (self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0))
		-- if(self.modelData.roleData.HallID and self.modelData.roleData.HallID > 0) then
		-- 	if self.rule.ruleInfo.consumeType  == "CONSUME_COIN" then
		-- 		self.view.payTypeObj_museum.text = masterCostTips[self.rule.ruleInfo.PayType-1]
		-- 	else
		-- 		self.view.payTypeObj_museum.text = masterCostTips_card[self.rule.ruleInfo.PayType]
		-- 	end
		-- end

		return;
	end
end

return TableRuleModule



