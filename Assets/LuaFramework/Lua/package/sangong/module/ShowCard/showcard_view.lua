--- 搓牌 view
--- Created by 袁海洲
--- DateTime: 2017/12/19 14:06
---
-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local ShowCardView = Class('ShowCardView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath
local cardCommon = require('package.sangong.module.table.sangong_cardCommon')
local AssetBundleManager = ModuleCache.AssetBundleManager

function ShowCardView:initialize(...)
    View.initialize(self, "sangong/module/showcard/sangong_showcard01.prefab", "SanGong_ShowCard01", 0)

    self.backAni = GetComponentWithPath(self.root, "Card/back", "UnityEngine.Animation")
    self.faceAni = GetComponentWithPath(self.root, "Card/face", "UnityEngine.Animation")
    self.numAni = GetComponentWithPath(self.root, "Card/num", "UnityEngine.Animation")

    self.faceMeshRenderer = GetComponentWithPath(self.root, "Card/face/Plane001","UnityEngine.SkinnedMeshRenderer")
    self.numMeshRenderer = GetComponentWithPath(self.root, "Card/num/Plane001","UnityEngine.SkinnedMeshRenderer")

    self.holder = GetComponentWithPath(self.root, "Holder",ComponentTypeName.Transform).gameObject

    --self.pokerHodler = GetComponentWithPath(self.root, "Holder/Poker",ComponentTypeName.Transform).gameObject
    --self.pokerMats = TableUtil.get_all_child(self.pokerHodler)
    --self.numHodler = GetComponentWithPath(self.root, "Holder/Num",ComponentTypeName.Transform).gameObject
    --self.numMats = TableUtil.get_all_child(self.numHodler)

    self.cardRtRawImageObj = GetComponentWithPath(self.root, "RawImage",ComponentTypeName.Transform).gameObject

    self.cardAssetHolder = GetComponentWithPath(self.root, "Holder/CardAssetHolder", "SpriteHolder")

    self.numRawImage = GetComponentWithPath(self.root, "NumRawImage", "UnityEngine.UI.RawImage")

    self.myHandPokers = {}
    for i=1,5 do
        local poker = {}
        poker.root = GetComponentWithPath(self.root,"HandPokers/"..i, ComponentTypeName.Transform)
        poker.face =  GetComponentWithPath(self.root,"HandPokers/"..i.."/face", ComponentTypeName.Image)
        table.insert(self.myHandPokers,poker)
    end

end

---设置牌面
function ShowCardView:setCard(card)
    local matName = cardCommon:getImageNameFromCode(card)

    local numpath = "sangong/effect/showcard/prefab/num/"..matName..".prefab"
    local pokerpath = "sangong/effect/showcard/prefab/poker/"..matName..".prefab"
    local numPrefab = AssetBundleManager:LoadAssetBundle(numpath):GetAsset(matName, false)
    local pokerPrefab = AssetBundleManager:LoadAssetBundle(pokerpath):GetAsset(matName, false)

    local cardMat = nil
    local numMat = nil

    if numPrefab then
        local image = GetComponentWithPath(numPrefab, "",ComponentTypeName.Image)
        numMat = image.material
    end
    if pokerPrefab then
        local image = GetComponentWithPath(pokerPrefab, "",ComponentTypeName.Image)
        cardMat = image.material
    end

    self.faceMeshRenderer.material = cardMat
    self.numMeshRenderer.material = numMat
    self.numRawImage.color = Color.New(1,1,1,0)
end

---设置顶部牌显示
function ShowCardView:setTopHandCards(cards)
    local cardNum = #cards
    for i=1,#self.myHandPokers do
        if i > cardNum then
            ModuleCache.ComponentUtil.SafeSetActive(self.myHandPokers[i].root.gameObject,false)
        else
            ModuleCache.ComponentUtil.SafeSetActive(self.myHandPokers[i].root.gameObject,true)
            local spriteName = cardCommon:getImageNameFromCode(cards[i])
            self.myHandPokers[i].face.sprite = self.cardAssetHolder:FindSpriteByName(spriteName)
        end
    end
end

---设置翻牌的动画进度
function ShowCardView:setShowCardProcee(process)
    process = process > 1 and 1 or process
    process = process < 0 and 0 or process
    local enumerator = self.backAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        state.normalizedTime = process
        state.speed = 0
    end
    self.backAni:Play()

    enumerator = self.faceAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        state.normalizedTime = process
        state.speed = 0
    end
    self.faceAni:Play()

    enumerator = self.numAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        state.normalizedTime = process
        state.speed = 0
    end
    self.numAni:Play()
end


---处理牌开牌后动画发生位移，需求需要开牌后牌的位置无变化
function ShowCardView:proceeDisObjPosOffset(process)
    local yOffset = 0
    if process >= 0.8 then
        yOffset =  yOffset - ((process - 0.8) / 0.2 * 10)
    end
    self.cardRtRawImageObj.transform.anchoredPosition = Vector3.New(0,yOffset,0)
    self.numRawImage.transform.anchoredPosition = Vector3.New(0,yOffset,0)
end

function ShowCardView:setNumColor(color)
    self.numRawImage.color = color
end

---获取卡牌动画播放进度
function ShowCardView:getCurProcess()
    local enumerator = self.backAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        return state.normalizedTime
    end
end

function ShowCardView:playCardAni(isforward)
    local speed = isforward and 2 or -2

    local enumerator = self.backAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        state.speed = speed
    end
    self.backAni:Play()

    enumerator = self.faceAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        state.speed = speed
    end
    self.faceAni:Play()

    enumerator = self.numAni:GetEnumerator()
    while(enumerator:MoveNext()) do
        local state = enumerator.Current
        state.speed = speed
    end
    self.numAni:Play()
end

return ShowCardView

