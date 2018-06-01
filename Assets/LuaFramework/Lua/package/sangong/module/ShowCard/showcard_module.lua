--- 搓牌 module
--- Created by 袁海洲
--- DateTime: 2017/12/19 14:05
---
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local ShowCardModule = class("sangong.ShowCardModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local cjson = require("cjson");
local Input = UnityEngine.Input
local DOTween = DG.Tweening.DOTween



function ShowCardModule:initialize(...)
    ModuleBase.initialize(self, "showcard_view", "showcard_model", ...)
end

---打开搓牌界面的正确姿势
--[[
        local initData = {}
        initData.card = data.cards[#data.cards]  ---搓的牌的牌面
        initData.topCards = data.Cards  ---顶部显示的牌
        initData.onComplate = function () ---当搓牌完成
            ModuleCache.ModuleManager.destroy_module("sangong", "showcard")
        end
        ModuleCache.ModuleManager.show_module("sangong", "showcard",initData)
--]]

function ShowCardModule:on_show(data)
    self.view:setCard(data.card) ---设置牌面信息
    self.view:setShowCardProcee(0) ---重置动画
    self.onComplate = data.onComplate
    self.isOver = false  ---开牌流程是否已经结束，用来标记玩家是否能够继续进行操作
    self.isComplate = false ---开牌是否完成
    if data.topCards then
        self.view:setTopHandCards(data.topCards)
    end
end

---立即开牌
function ShowCardModule:immediateShowCard()
    if not self.lastPoint then
        self.view:setShowCardProcee(0)
    end
    self.view:playCardAni(true)
    self.isOver = true
end

function ShowCardModule:on_press_up(obj, arg)
    self.lastPoint = nil
    if self.view:getCurProcess() < 0.8 then
        self.view:playCardAni(false)
        self.isOver = false
    else
        self.view:playCardAni(true)
        self.isOver = true
    end
end

function ShowCardModule:on_drag(obj, arg)
    if  self.lastPoint
        and not self.isOver then
        local curPoint = Input.mousePosition
        local yOffset = curPoint.y - self.lastPoint.y
        self.lastPoint = curPoint
        self.view:setShowCardProcee(self.view:getCurProcess() + yOffset / 700)
    end
end

function ShowCardModule:on_press(obj, arg)
    if obj == self.view.cardRtRawImageObj then
        self.lastPoint = Input.mousePosition
    end
end

function ShowCardModule:on_update()
    if not self.isComplate then
        self.view:proceeDisObjPosOffset(self.view:getCurProcess())
    end
    if not self.isComplate and self.view:getCurProcess() >= 1 then
        self.isOver = true
        self.isComplate = true
        self.view:proceeDisObjPosOffset(1)
        local color = Color.New(1,1,1,0)
        DOTween.ToAlpha(function ()
            return color
        end,function (color)
            self.view:setNumColor(color)
        end,1,0.5):OnComplete(function()
            if self.onComplate then
                self.onComplate()
            end
        end):SetDelay(0.25)
    end
end

function ShowCardModule:on_destroy()
    self.isOver = false
end


return ShowCardModule