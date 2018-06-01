-- ===============================================================================================--
-- data: 2016.11
-- author: dred
-- desc: 模块的全局管理类
-- ===============================================================================================--
local require = require
local string = string
--local ModuleCache = ModuleCache

---@class ModuleManager
local ModuleManager = {
    _packageModuleDatas = { },
    -- 公用模块
    _publicModuleDatas = { }
}



---@return ModuleBase
function ModuleManager.add_module(package, moduleName)
    local moduleData = ModuleManager.get_module(package, moduleName)
    if not moduleData then
        local packageData = ModuleManager._packageModuleDatas[package]
        if not packageData then
            packageData = { }
            ModuleManager._packageModuleDatas[package] = packageData
        end
        local modulePath = string.format("package.%s.module.%s", package, moduleName)
        local packageModuleSimpleData = {
            packageName = package,
            moduleName = moduleName,
            modulePath = modulePath
        }
        moduleData = require(string.format("%s.%s_module", modulePath, moduleName)):new(packageModuleSimpleData)
        moduleData:base_init_end(packageModuleSimpleData)
        packageData[moduleName] = moduleData
        -- print("init module: ", package, moduleName)
    end
    --print("add_module", package, moduleName)
    return moduleData
end

--- 显示module，没有注册的module会先注册, intentData 意图数据
function ModuleManager.show_module(package, moduleName, intentData)
    ModuleCache.Log.print("show_module", package, moduleName)
    local module = ModuleManager.add_module(package, moduleName)
    if module then
        module:show(intentData)
    end
    return module
end

--- package是否已经被加载
function ModuleManager.package_is_loaded(package)
    local packageData = ModuleManager._packageModuleDatas[package]
    if not packageData then
        return false
    end
    return true
end

--- 模块是否被显示
function ModuleManager.module_is_active(package, moduleName)
    local module = ModuleManager.get_module(package, moduleName)
    if module then
        return module:view_is_active()
    end
    return false
end



-- 只显示module模块，其他的全部隐藏
function ModuleManager.show_module_only(package, moduleName, intentData)
    ModuleManager.hide_package(package)
    ModuleManager.show_module(package, moduleName, intentData)
end




function ModuleManager.get_module(package, moduleName)
    local packageData = ModuleManager._packageModuleDatas[package]
    if packageData then
        return packageData[moduleName]
    end
    return nil
end

function ModuleManager.destroy_module(package, moduleName)
    local packageData = ModuleManager._packageModuleDatas[package]
    if packageData then
        local moduleData = packageData[moduleName]
        if moduleData then
            packageData[moduleName] = nil
            moduleData:destroy()
        end
    end
    ModuleCache.CustomerUtil.UnloadUnusedAssets()
    lua_gc()
    --    print_table(packageData)
end

-- 销毁puglicpackage, 是否排除清除静态Module
function ModuleManager.destroy_public_package(excludeStaticModule)
    local moduleDatas = ModuleManager._packageModuleDatas["public"]
    if moduleDatas then
        ModuleManager._packageModuleDatas["public"] = { }
        for k, v in pairs(moduleDatas) do
            if excludeStaticModule then
                if not v.staticModule then
                    v:destroy()
                else
                    ModuleManager._packageModuleDatas["public"][v.moduleName] = v
                end
            else
                v:destroy()
            end

        end
        print_table(ModuleManager._packageModuleDatas["public"])
    end
    lua_gc()
    ModuleCache.CustomerUtil.UnloadUnusedAssets()
end

-- 销毁package, 包括其中包含的所有module
function ModuleManager.destroy_package(package)
    local moduleDatas = ModuleManager._packageModuleDatas[package]
    if moduleDatas then
        for k, v in pairs(moduleDatas) do
            v:destroy()
        end
        ModuleManager._packageModuleDatas[package] = { }
    end
    lua_gc()
    ModuleCache.CustomerUtil.UnloadUnusedAssets()
end

-- 隐藏当前的package，会隐藏所有的模块
function ModuleManager.hide_package(package)
    local moduleDatas = ModuleManager._packageModuleDatas[package]
    if moduleDatas then
        for k, v in pairs(moduleDatas) do
            v:hide()
        end
    end
end

function ModuleManager.hide_module(package, moduleName)
    local module = ModuleManager.get_module(package, moduleName)
    if module then
        module:hide()
    end
end


function ModuleManager.show_public_module(moduleName, intentData)
    print("show_public_module", moduleName)
    local module = ModuleManager.add_module("public", moduleName)
    if module then
        module:show(intentData)
    end
    return module
end

---@return TextPromptModule
function ModuleManager.show_public_module_textprompt(intentData)
    local module = ModuleManager.add_module("public", "textprompt")
    if module then
        module:show(intentData)
    end
    return module
end

---@return AlertDialogModule
function ModuleManager.show_public_module_alertdialog(intentData)
    local module = ModuleManager.add_module("public", "alertdialog")
    if module then
        module:show(intentData)
    end
    return module
end

function ModuleManager.hide_public_module_textprompt(intentData)
    local module = ModuleManager.hide_module("public", "textprompt")
    if module then
        module:show(intentData)
    end
    return module
end

function ModuleManager.hide_public_module_alertdialog(intentData)
    local module = ModuleManager.hide_module("public", "alertdialog")
    if module then
        module:show(intentData)
    end
    return module
end


function ModuleManager.hide_public_module(moduleName)
    local module = ModuleManager.add_module("public", moduleName)
    if module then
        module:hide()
    end
    return module
end



return ModuleManager