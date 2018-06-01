--- 三公结算module
--- Created by a.
--- DateTime: 2017/11/28 11:31
---
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local TableResultModule = class("tableResultSanGongModule", ModuleBase)

local ModuleCache = ModuleCache

function TableResultModule:initialize(...)
    -- 开始初始化
    ModuleBase.initialize(self, "tableresult_view", "tableresult_model", ...)

end

---模块初始化完成回调，包含了view，Model初始化完成
function TableResultModule:on_module_inited()

end

---绑定module层的交互事件
function TableResultModule:on_module_event_bind()

end

---绑定loginModel层事件，模块内交互
function TableResultModule:on_model_event_bind()

end

function TableResultModule:on_show(initData)
    local players = initData.players

    self.roomInfo = self.modelData.curTableData.roomInfo
    local seatInfoList = self.roomInfo.seatInfoList

    local WinerIndex = nil
    local maxScore = nil
    for i=1,#players do
        local player = players[i]
        self.view:refreshPlayerResultInfo(player,i)
        ---设置房主标记
        self.view:SetRoomCreator(i,self.roomInfo.CreatorId ==  player.player_id)
        self.view:SetDisbanderTag(i,initData.free_sponsor ==  player.player_id)
        if not maxScore or maxScore <  player.score then
            maxScore = player.score
            WinerIndex = i
        end
        self.view:SetWinerTag(i,false)
    end

    if WinerIndex then
        self.view:SetWinerTag(WinerIndex,true) ---设置赢家标记
    end

    local game_count = initData.game_count --总局数
    local is_summary_account = initData.is_summary_account --是否是总结算
    local startTime = initData.startTime --牌局开始时间
    local endTime = initData.endTime --牌局结束时间

    local startTimeText = os.date("%Y-%m-%d %H:%M:%S", tonumber(startTime))
    local endTimeText = os.date("%Y-%m-%d %H:%M:%S",  tonumber(endTime))
    self.view.textRoomNum.text = "房号:"..self.roomInfo.roomNum
    self.view.textTime.text = "开始 "..startTimeText.."\n结束 "..endTimeText

    self.view.textHallNum.gameObject:SetActive(self.modelData.roleData.HallID > 0)
    if(self.modelData.roleData.HallID > 0) then
        self.view.textHallNum.text = "圈号:"..self.modelData.roleData.HallID
    end

    self:copy_result_Info(initData)
end

function TableResultModule:copy_result_Info(initData)
    local tryCopy = function()
        local data = self:get_result_share_data(initData)
        if data then
            ModuleCache.ShareManager().share_room_result_text(data)
        end
    end
    local players = initData.players
    self.userInfos = {}
    for i=1,#players do
        local player = players[i]
        self.view:get_userinfo(player.player_id,function (err,playerinfo)
            self.userInfos[player.player_id] = playerinfo
            tryCopy()
        end)
    end
end

---构建房间结算分享信息
function TableResultModule:get_result_share_data(initData)
    local resultData = {
        roomID = self.roomInfo.roomNum,
        hallID = self.modelData.roleData.HallID,
    }

    if(initData.startTime)then
        resultData.startTime = os.date("%Y/%m/%d %H:%M:%S", tonumber(initData.startTime))
    end
    if(initData.endTime)then
        resultData.endTime = os.date("%Y/%m/%d %H:%M:%S", tonumber(initData.endTime))
    end

    local playerDatas = {}
    local count = #initData.players
    for i=1,count do
        local playerResult = initData.players[i]
        local tmp = {
            playerResult.player_id,
            playerResult.score,
        }
        local playerInfo = self.userInfos[playerResult.player_id]
        if(not  playerInfo )then
            return nil
        end
        tmp[1] = playerInfo.nickname
        table.insert(playerDatas,tmp)
        if(initData.free_sponsor and  playerResult.player_id == initData.free_sponsor )then
            resultData.dissRoomPlayName = playerInfo.nickname
        end
    end
    resultData.playerDatas = playerDatas
    return resultData
end

function TableResultModule:on_click(obj, arg)
    print(obj.name)
    ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
    if obj == self.view.buttonBack.gameObject then
        self.modelData.curTableData.roomInfo = nil
        ModuleCache.ModuleManager.destroy_package("sangong")
        ModuleCache.ModuleManager.show_module("henanmj", "hall")
        return
    elseif obj == self.view.buttonShare.gameObject then
        ModuleCache.ShareManager().shareImage(false)
        return
    elseif obj == self.view.buttonOnceMore.gameObject then

    end
end

return TableResultModule