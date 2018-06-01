-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--

-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local HistoryListModule = class("BullFight.HistoryListModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local GameManager = ModuleCache.GameManager

function HistoryListModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "historyList_view", nil, ...)
end


function HistoryListModule:on_show(data)
	self.historyListView:initLoopScrollViewList(data)
end


function HistoryListModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.historyListView.buttonClose.gameObject then
		ModuleCache.ModuleManager.hide_module("majiang", "historylist")
		self:dispatch_package_event("Event_Show_Hall_Anim")
	elseif obj == self.historyListView.buttonCheckRoundVideo.gameObject then
		ModuleCache.ModuleManager.show_module("henanmj", "playvideo")
	elseif obj.transform.parent.gameObject == self.historyListView.content then
		self:getRoomList(self.historyListView:get_data(obj))
	end
end


function HistoryListModule:on_begin_drag(obj, arg)	
	if(obj.transform.parent.name == "Content")then
		self.dragObj = obj
	end	
end

function HistoryListModule:on_end_drag(obj, arg)
	if(obj.transform.parent.name == "Content")then
		if(self.dragObj == obj)then
			if(self.historyListView.lastScrollValue and self.historyListView.lastScrollValue < 0)then

			end
		end
	end	
end

function HistoryListModule:getRoomList(roomInfo)
	print_table(roomInfo)
	local requestData = {
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			roomid = roomInfo.id
		},
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "gamehistory/roundlist/v3?",
	}
	
    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
			local sendData = 
			{
				roomInfo = roomInfo,
				data = retData.data,
			}
            ModuleCache.ModuleManager.show_module("majiang", "roomdetail", sendData)
        else
            
        end
    end, function(error)
        print(error.error)
    end)
end

return HistoryListModule



