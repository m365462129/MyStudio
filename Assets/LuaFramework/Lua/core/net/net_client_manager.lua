-- ==============================================================================
-- User: dred
-- Date: 2016/11/29
-- Time: 13:48
-- Desc: 网络管理类
-- ==============================================================================

local NetClient = require("core.net.net_client")

local NetClientManager = {
    _clientDatas = {},
    _connectSubscriberData = {}
}


function NetClientManager.init_client(name, msgProtocolType)
    local netClient = NetClientManager._clientDatas[name]
    if netClient == nil then
        netClient = NetClient()
        netClient:init(name, msgProtocolType)
        NetClientManager._clientDatas[name] = netClient
    end
    return netClient
end

function NetClientManager.get_client(name)
    return NetClientManager._clientDatas[name]
end

function NetClientManager.connect_client(name, adress, port, connectEvent)
    local netClient = NetClientManager:add_client(name)
    netClient:connect(adress);
    NetClientManager._connectSubscriberData[netClient.name] = connectEvent
end



function NetClientManager.subscibe_connect_event(netClient, callback)
    NetClientManager._connectSubscriberData[netClient.name] = callback
end

function NetClientManager.unsubscibe_connect_event(netClient, callback)
    NetClientManager._connectSubscriberData[netClient.name] = callback
end


function NetClientManager.disconnect_all_client()
    for k, client in pairs(NetClientManager._clientDatas) do
        if client then
            -- print(client.name)
            client:clear_subscibe_connect_event()
            client:close()
        end
    end
    NetClientManager._clientDatas = {}
    NetClientManager._connectSubscriberData = {}
end

return NetClientManager