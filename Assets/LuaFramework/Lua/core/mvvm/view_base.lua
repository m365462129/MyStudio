local class = require("lib.middleclass")
local ViewUtil = ModuleCache.ViewUtil

local MVVMBase = require('core.mvvm.mvvm_base')
---@class View : MVVMBase
local View = class('View', MVVMBase)
local UnityEngine = UnityEngine
local ModuleCache = ModuleCache

function View:initialize(assetBundleName, mainAssetName, sortingLayer, registerPreLoad)
    MVVMBase.initialize(self)

    local layer = sortingLayer or 0
    if(self.packageName and self.moduleName)then
        if(registerPreLoad)then
            --ModuleCache.PreLoadManager.registerPreLoad(self.packageName, self.moduleName, assetBundleName, mainAssetName)
        end
    end
    --ModuleCache.Log.begin_counting()
    self.root = ViewUtil.InitViewGameObject(assetBundleName, mainAssetName, layer); --同步加载
    self.rootTransform = self.root.transform
    self.canvas = ModuleCache.ComponentManager.GetComponent(self.root, "UnityEngine.Canvas");
    --ModuleCache.Log.end_counting("InitViewGameObject", mainAssetName)
    --local rootComponentCache = ModuleCache.ComponentManager.GetComponent(self.root, "test");
    --if(rootComponentCache)then
    --    self._componentCache = (require('core.mvvm.component_cache')):new()
    --    self._componentCache:bindComponent(rootComponentCache)
    --end
    self:hide()
    if self.on_inited then
        self:on_inited()
    end
end


---InstantiateGameObjectAsync
---@param parentGameObject string 父物体
---@param assetBundleName string  AssetBundle路径
---@param mainAssetName string    主Asset
---@param instantiateCallback table
function View:InstantiateGameObjectAsync(parentGameObject, assetBundleName, mainAssetName, instantiateCallback)
    ModuleCache.AssetBundleManager:LoadAssetBundleAsync(assetBundleName, mainAssetName, function (loadAssetBundle)
        if not self.isDestroy then
            if loadAssetBundle then
                local asset = loadAssetBundle:GetAsset(mainAssetName, false)
                local gameRoot = ModuleCache.ComponentUtil.InstantiateLocal(asset, parentGameObject)
                gameRoot:SetActive(true)
            end
        end
    end)
end



-- 显示
function View:show(showTop)
    --ModuleCache.Log.begin_counting()
    self._active = true
    self.rootTransform:SetAsLastSibling()
    ViewUtil.ShowTop(self.root)
    --ModuleCache.Log.end_counting("View:show(showTop)")
end

--设置1080分辨率
function View:set_1080p()
    self.rootTransform.sizeDelta = self.rootTransform.sizeDelta * 1.5
    self.rootTransform.localScale = self.rootTransform.localScale * 0.666666
end

--设置image填满
function View:set_image_fill(image,size)
    --image.preserveAspect = true
    ----print("---------------image:",image.gameObject.name)
    ----print("---------------image.sprite:",image.sprite)
    ----print("---------------image.sprite.rect.width:",image.sprite.rect.width)
    --if image.sprite ~= nil  then
    --    local w = image.sprite.rect.width
    --    local h = image.sprite.rect.height
    --    local tectTransf = ModuleCache.ComponentManager.GetComponent(image.gameObject,"UnityEngine.RectTransform")
    --    if w > h then
    --        tectTransf.sizeDelta = Vector2.New( w/h *size,size)
    --    else
    --        tectTransf.sizeDelta = Vector2.New( size,h/w *size)
    --    end
    --end
end

function View:hide()
--    print('self.root', self.root)
    self._active = false
    if self.root then
        self.canvas.sortingOrder = 0
        self.root:SetActive(false)
    end
end

function View:is_active()
    return self._active
end





-- 通过游戏ID设置Image组件的sprite
function View:SetImageSpriteByGameId(_targetImage,_targetSpriteHolder,_targetGameId)
    -- local sprite = _targetSpriteHolder:FindSpriteByName(tostring(_targetGameId)) 
    -- if(sprite == nil) then
    --     sprite = _targetSpriteHolder:FindSpriteByName("1") 
    -- end
    -- _targetImage.sprite = sprite
end

--销
function View:destroy()
    MVVMBase.base_destroy(self)
    self.isDestroy = true

    if self.on_destroy then
        self:on_destroy()
    end
    self._is_destroyed = true
    if self.root then
        self.canvas.sortingOrder = 0
        UnityEngine.GameObject.Destroy(self.root)
    end
end



return View