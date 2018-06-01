local class = require("lib.middleclass")
local ModelBase = require('package.changpai.module.tablebase.tablecpbase_model')

local TableModel = class('tableModel', ModelBase)


function TableModel:initialize(...)
    ModelBase.initialize(self, ...)
end

function TableModel:request_restart_mj(data)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Restart")
    --[[request.DiTuo = data.DiTuo
    request.NeiPiao = data.NeiPiao
    request.WaiPiao = data.WaiPiao]]
    if(data) then
        request.Piao = data
    end
    ModelBase.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableModel:request_diao_dui(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_DiaoDui")
    request.Pai = pai
    ModelBase.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableModel:request_piao()
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_PiaoHua")
    ModelBase.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

function TableModel:request_select_piao(data)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Piao")
    request.PiaoNum = data.xiaojiScore
    request.Pao = data.paoScore
    request.DiTuo = false
    ModelBase.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

-- 不叫牌/撂龙当前牌
function TableModel:request_quxiao(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_QuXiao")
    request.Pai = pai
    self:send_msg(msgId, request, "gameServer", self.SeqNo)
end

-- 叫牌
function TableModel:request_jiaopai(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_JiaoPai")
    request.Pai = pai
    self:send_msg(msgId, request, "gameServer", self.SeqNo)
end

-- 撂龙
function TableModel:request_liaolong(pai)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_LiaoLong")
    request.Pai = pai
    self:send_msg(msgId, request, "gameServer", self.SeqNo)
end

---其他长牌用买庄
function TableModel:request_maizhuang(t)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_Piao")
    request.PiaoNum = t
    request.Pao = 0
    request.DiTuo = false
    ModelBase.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

---南通长牌专用买庄
function TableModel:request_new_maizhuang(t)
    local msgId, request = self.netMsgApi:create_request_data("Msg_Table_MaiZhuang")
    request.Num = t
    ModelBase.send_msg(self, msgId, request, "gameServer", self.SeqNo)
end

return  TableModel