
local ModuleCache = ModuleCache
local UserUtil = {}
UserUtil.saveData = nil
-- 将已获取的用户数据存储在内存中
-- param:data -> 服务端发送来的用户数据
-- key: userId
-- value:
-- userId     -> 用户ID
-- nickname   -> 用户昵称
-- gender     -> 性别
-- headSprite -> 头像sprite
function UserUtil.saveUser(data,finishCallback)
    if(not UserUtil.saveData) then UserUtil.saveData = {} end
    local key = tostring(data.userId)
    UserUtil.saveData[key] = {}
    UserUtil.saveData[key].userId     = data.userId
    UserUtil.saveData[key].nickname   = data.nickname
    UserUtil.saveData[key].gender     = data.gender
    UserUtil.saveData[key].headSprite = nil

    if(data.headImg and data.headImg ~= nil)then
        ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(data.headImg, function(err, sprite)
            if(err) then
                --print('down load '.. data.headImg .. 'failed:')
            else
                UserUtil.saveData[key].headSprite = sprite
            end
            if(type(finishCallback) == "function")then
                finishCallback(UserUtil.saveData[key])
            end
        end)    
    end
end

function UserUtil.getDataById( userId )     
    if(UserUtil.saveData) then
        return UserUtil.saveData[tostring(userId)]
    end
    return nil
end

function UserUtil.IsContainsUser(userId)
    if(UserUtil.saveData)then
        local key = tostring(userId)
        return (UserUtil.saveData[key] ~= nil)
    end
    return false
end

function UserUtil.Dispose( )
    if(UserUtil.saveData) then
        UserUtil.saveData = nil
    end
end


return UserUtil;