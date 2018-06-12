--
-- Created by IntelliJ IDEA.
-- User: dred
-- Date: 2016/12/4
-- Time: 下午6:31
-- 静态数据表
--
local require = require
local DataConfig = {}

function DataConfig.new()
    DataConfig = {}
end

-- 获取配置表
function DataConfig.get_localization(module, key)
    local localizationData = DataConfig.localizationData
    if not localizationData then
        localizationData = require("package.bullfight.config.localization")
        DataConfig.localizationData = localizationData
    end
    print(localizationData, module, key)
    return localizationData[module][key]
end

function DataConfig.get_msgerror(key)
    local msgErrorData = DataConfig.msgErrorData
    if not msgErrorData then
        msgErrorData = require("package.bullfight.config.msgerror")
        DataConfig.msgErrorData = msgErrorData
    end
    return msgErrorData[key]
end

return DataConfig

-- 获取某一个模块变量