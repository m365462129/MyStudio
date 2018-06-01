--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')
local DaiGouTuiTableModel = class('daiGouTuiTableModel', Model)


function DaiGouTuiTableModel:initialize(...)
    self.sendMsgNetClientName = "bullfight"
    Model.initialize(self, ...)

    Model.subscibe_msg_event(self, {    --明牌应答
        msgName = "Msg_Table_Show_Cards",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Show_Cards", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --明牌通知
        msgName = "Msg_Table_Show_Cards_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Show_Cards_Notify", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --叫狗腿应答
        msgName = "Msg_Table_CallServant",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_CallServant", retData)
            end
        end
    })   

    Model.subscibe_msg_event(self, {    --叫狗腿通知
        msgName = "Msg_Table_CallServant_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_CallServant_Notify", retData)
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

    Model.subscibe_msg_event(self, {    --重新发牌
        msgName = "Msg_Table_RedealCard",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_RedealCard", retData)
            end
        end
    })

    Model.subscibe_msg_event(self, {    --重新发牌通知
        msgName = "Msg_Table_RedealCard_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_RedealCard_Notify", retData)
            end
        end
    })

end



---------------------------------------------------------------------------------

--明牌请求  明牌阶段 1 摸牌前明牌 2叫牌明牌 3明牌
function DaiGouTuiTableModel:request_show_cards(show)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Show_Cards")
    request.show_or_not = show    
    Model.send_msg(self, msgId, request)
end

--叫狗腿
function DaiGouTuiTableModel:request_call_servant()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_CallServant")
    Model.send_msg(self, msgId, request)
end

--出牌请求
function DaiGouTuiTableModel:request_discard(is_pass, cards, discard_serno)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Discard")
    request.is_passed = is_pass
    request.discard_serno = discard_serno
    if(cards)then
        for i=1,#cards do
           local code = cards[i]
           table.insert(request.cards, code) 
        end
    end
    
    Model.send_msg(self, msgId, request)
end

--重新发牌
function DaiGouTuiTableModel:request_redeal_cards()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_RedealCard")
    Model.send_msg(self, msgId, request)
end

return  DaiGouTuiTableModel