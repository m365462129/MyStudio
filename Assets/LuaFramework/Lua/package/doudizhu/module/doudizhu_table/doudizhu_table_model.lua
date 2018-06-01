--
-- 版权所有:个人
-- Author:深红dred
-- Date: 2017-03-21 10:20:51
--

local ModuleCache = ModuleCache
local ComponentTypeName = ModuleCache.ComponentTypeName

local class = require("lib.middleclass")
local Model = require('package.public.module.table_poker.base_table_model')
local DouDiZhuTableModel = class('douDiZhuTableModel', Model)


function DouDiZhuTableModel:initialize(...)
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

    Model.subscibe_msg_event(self, {    --抢地主应答
        msgName = "Msg_Table_GrabLandLord",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_GrabLandLord", retData)
            end
        end
    })   

    Model.subscibe_msg_event(self, {    --抢地主通知
        msgName = "Msg_Table_GrabLandLord_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_GrabLandLord_Notify", retData)
            end
        end
    })   

    Model.subscibe_msg_event(self, {    --开始抢地主通知
        msgName = "Msg_Table_Start_GrabLandLord_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_Start_GrabLandLord_Notify", retData)
            end
        end
    })  


    Model.subscibe_msg_event(self, {    --抢地主结果通知
        msgName = "Msg_Table_GrabLandLord_Result_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)          
                Model.dispatch_event(self, "Event_Table_GrabLandLord_Result_Notify", retData)
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

    --亲友圈快速组局 房主改变
    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_OwnerChangeNotify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                print("------------------------亲友圈快速组局 房主改变",retData.new_ownerid)
                Model.dispatch_event(self, "Msg_Table_OwnerChangeNotify", retData)
            end
        end
    })

    --取消准备通知
    Model.subscibe_msg_event(self, {
        msgName = "Msg_Table_CancelReadyNotify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)

                Model.dispatch_event(self, "Msg_Table_CancelReadyNotify", retData)
            end
        end
    })

    --亲友圈 快速组局 踢人倒计时
    Model.subscibe_msg_event(self,{
        msgName = "Msg_Table_KickPlayerExpire_Notify",
        callback = function(msgName, msgBuffer)
            if msgBuffer.msgRetCode == 0 then
                local retData, error = Model.unpack_msg(self, msgName, msgBuffer.dataBuffer)
                Model.dispatch_event(self, "Event_Table_KickPlayerExpire", retData)
            end
        end
    })

end



---------------------------------------------------------------------------------

--明牌请求  明牌阶段 1 摸牌前明牌 2叫牌明牌 3明牌
function DouDiZhuTableModel:request_show_cards(stage)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Show_Cards")
    request.stage = stage    
    Model.send_msg(self, msgId, request)
end

--抢地主请求 >0 叫分 0不抢
function DouDiZhuTableModel:request_grablord(score)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_GrabLandLord")
    request.score = score    
    Model.send_msg(self, msgId, request)
end

--出牌请求
function DouDiZhuTableModel:request_discard(is_pass, cards)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Discard")
    request.is_passed = is_pass
    if(cards)then
        for i=1,#cards do
           local code = cards[i]
           table.insert(request.cards, code) 
        end
    end
    
    Model.send_msg(self, msgId, request)
end

return  DouDiZhuTableModel