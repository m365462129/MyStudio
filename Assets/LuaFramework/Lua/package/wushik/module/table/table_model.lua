--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')
local WuShiKTableModel = class('WuShiKTableModel', Model)


function WuShiKTableModel:initialize(...)
    self.sendMsgNetClientName = "bullfight"
    Model.initialize(self, ...)

    Model.subscibe_msg_event(self, {    --出牌应答
        msgName = "Msg_Table_Discard",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Discard", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --出牌通知
        msgName = "Msg_Table_Discard_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Discard_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --结算消息
        msgName = "Msg_Table_CurrentAccount_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_CurrentAccount_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --同步消息
        msgName = "Msg_Table_GameInfo_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_GameInfo_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --独牌
        msgName = "Msg_Table_FightAlone",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_FightAlone", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --同步消息
        msgName = "Msg_Table_FightAlone_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_FightAlone_Notify", retData)
            end
        end
    })
    Model.subscibe_msg_event(self, {    --捡分消息
        msgName = "Msg_Table_PointsPicked_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_PointsPicked_Notify", retData)
            end
        end
    })

end



---------------------------------------------------------------------------------

--独牌
function WuShiKTableModel:request_du_pai(playerId, needFightAlone)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_FightAlone")
    request.playerId = playerId
    request.needFightAlone = needFightAlone
    Model.send_msg(self, msgId, request)
end

--出牌请求
function WuShiKTableModel:request_discard(is_pass, cards, discard_serno)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Discard")
    request.is_passed = is_pass
    request.discard_serial_no = discard_serno
    if(cards)then
        for i=1,#cards do
           local code = cards[i]
           table.insert(request.cards, code) 
        end
    end
    
    Model.send_msg(self, msgId, request)
end

return  WuShiKTableModel