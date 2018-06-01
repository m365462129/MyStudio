--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')
local GuanDanTableModel = class('guanDanTableModel', Model)


function GuanDanTableModel:initialize(...)
    self.sendMsgNetClientName = "bullfight"
    Model.initialize(self, ...)
    
    Model.subscibe_msg_event(self, {    --上贡应答
        msgName = "Msg_Table_Tribute",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Tribute", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --上贡通知
        msgName = "Msg_Table_Tribute_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Tribute_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --上贡结果通知
        msgName = "Msg_Table_Tribute_Result_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Tribute_Result_Notify", retData)
            end
        end
    })

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


    Model.subscibe_msg_event(self, {    --同步消息
        msgName = "Msg_Table_KickPlayerExpire",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_KickPlayerExpire", retData)
            end
        end
    })
end



---------------------------------------------------------------------------------

--上贡请求
function GuanDanTableModel:request_tribute(playerId, card)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Tribute")
    request.player_id = tonumber(playerId .. '')
    request.card = card
    Model.send_msg(self, msgId, request)
end

--出牌请求
function GuanDanTableModel:request_discard(is_pass, cards, logic_cards)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Discard")
    request.is_passed = is_pass
    if(cards)then
        for i=1,#cards do
           local code = cards[i]
           table.insert(request.cards, code) 
           table.insert(request.logic_cards, logic_cards[i])
        end
    end
    
    Model.send_msg(self, msgId, request)
end


return  GuanDanTableModel