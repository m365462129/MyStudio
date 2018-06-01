

local TableData = {}

local tableState = {}
tableState.waitReady = "waitReady"      --等待准备
tableState.waitStart = "waitStart"      --等待开始
tableState.waitConfirmNiu = "waitConfirmNiu"    --等待选牛
TableData.constTableState = tableState

function TableData:init()
    self.config = {}
    self.config.roomid = nil     -- 房间id
    self.config.type = nil       -- 牌桌类型：0-线下，1-金币，2-比赛
    self.config.round = nil     -- 局数：0-10局，1-20局
    self.config.person = nil     -- 人数：0-3人，1-2人，2-4人
    self.config.first = nil      -- 先手：0-上游先手，1-黑桃3先手
    self.config.ruleDescribe = "斗牛 轮流做庄 有花牌 花样玩法"
    self.seatDataList = {}
    
    self.curTableState = self.constTableState.waitReady
end



return TableData

