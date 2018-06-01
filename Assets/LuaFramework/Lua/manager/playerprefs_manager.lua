local PlayerPrefs = UnityEngine.PlayerPrefs

---@class PlayerPrefsManager
local PlayerPrefsManager = {}
PlayerPrefsManager.cacheData = {}

function PlayerPrefsManager.GetInt(key, defaultVal)
    local getVal = PlayerPrefsManager.cacheData[key]
    if(getVal) then
        return getVal
    end
    if(defaultVal) then
        getVal = PlayerPrefs.GetInt(key, defaultVal)
    else
        getVal = PlayerPrefs.GetInt(key)
    end
    PlayerPrefsManager.cacheData[key] = getVal
    return getVal
end

function PlayerPrefsManager.GetString(key, defaultVal)
    local getVal = PlayerPrefsManager.cacheData[key]
    if(getVal) then
        return getVal
    end
    if(defaultVal) then
        getVal = PlayerPrefs.GetString(key, defaultVal)
    else
        getVal = PlayerPrefs.GetString(key)
    end
    PlayerPrefsManager.cacheData[key] = getVal
    return getVal
end

function PlayerPrefsManager.GetFloat(key, defaultVal)
    local getVal = PlayerPrefsManager.cacheData[key]
    if(getVal) then
        return getVal
    end
    if(defaultVal) then
        getVal = PlayerPrefs.GetFloat(key, defaultVal)
    else
        getVal = PlayerPrefs.GetFloat(key)
    end
    PlayerPrefsManager.cacheData[key] = getVal
    return getVal
end

function PlayerPrefsManager.SetInt(key, setVal)
    PlayerPrefs.SetInt(key, setVal)
    PlayerPrefsManager.cacheData[key] = setVal
end

function PlayerPrefsManager.SetString(key, setVal)
    PlayerPrefs.SetString(key, setVal)
    PlayerPrefsManager.cacheData[key] = setVal
end

function PlayerPrefsManager.SetFloat(key, setVal)
    PlayerPrefs.SetFloat(key, setVal)
    PlayerPrefsManager.cacheData[key] = setVal
end


function PlayerPrefsManager.Save()
    PlayerPrefs.Save()
end

return PlayerPrefsManager