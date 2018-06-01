--
-- Author:深红dred {email}
-- Date: 2017-03-21 09:56:36
-- Describe: 
--

local ModuleCache = ModuleCache

local class = require("lib.middleclass")
local ModuleBase = require('core.mvvm.module_base')
local TotalGameResultModule = class('totalGameResultModule', ModuleBase)
local PlayerPrefs = UnityEngine.PlayerPrefs
local PlayerPrefsManager = ModuleCache.PlayerPrefsManager

local curTableData = nil

function TotalGameResultModule:initialize(...)
    ModuleBase.initialize(self, "totalgameresult_view", nil, ...)
	self.netClient = self.modelData.bullfightClient	
	curTableData =TableManager.curTableData 
	self.netClient = self.modelData.bullfightClient		    
	self.exitRoom = false

	--self.shareTypeToggle.isOn = PlayerPrefsManager.GetInt("shareTypeToggle", 0) == 1  -- shareTypeToggle ： 0 是分享图片   1 分享文字
	self.view.shareTypeToggle.onValueChanged:AddListener(function(isCheck)
		if isCheck then
			PlayerPrefsManager.SetInt("shareTypeToggle" ,1)
		else
			PlayerPrefsManager.SetInt("shareTypeToggle",0)
		end
	end	)

	if curTableData.RoomType == 3 then
		
		local localSeat = nil
		local seatHolder = nil
		local ranking  = 1
		local rankingShowTex = ""
		local dialogData = {}
		local PlayerSort = {}
		for k,v in ipairs(curTableData.gameState.Player) do 
			PlayerSort[k] = v
		end

		table.sort( PlayerSort, function ( a,b )
			return a.ZongBeiShu > b.ZongBeiShu
		end )
		
		--没有分出胜负 
		if PlayerSort[1].ZongBeiShu == PlayerSort[2].ZongBeiShu or PlayerSort[2].ZongBeiShu == PlayerSort[3].ZongBeiShu then
			return
		end

		for i,v in ipairs(curTableData.gameState.Player) do
			localSeat = TableUtil.get_local_seat(i - 1, curTableData.SeatID, curTableData.totalSeat)
			seatHolder = curTableData.seatHolderArray[localSeat]
			--print(i,v.ZongBeiShu,"----------------------------------0000-------------seatHolder.playerId:",seatHolder.playerId,self.modelData.roleData.userID)
			if seatHolder.playerId == self.modelData.roleData.userID then
				
				for k,d in ipairs(curTableData.gameState.Player) do
					if(v.ZongBeiShu < d.ZongBeiShu) then
						ranking = ranking +1
					end
				end
				
				dialogData = {}
				if(ranking == 1) then
					dialogData.btnType = 2
					dialogData.infoStr = "恭喜您，在本次比赛中获得冠军，请快点领取属于您的奖励！"
					dialogData.bottomStr = "请查看比赛记录获取兑奖码领取奖励"
					dialogData.onCallback = function()
						-- 跳转到 亲友圈-》比赛场-》-》比赛记录
						
						ModuleCache.ModuleManager.hide_public_module("netprompt")
						ModuleCache.ModuleManager.destroy_package("henanmj")
						ModuleCache.ModuleManager.destroy_package("majiang")
						ModuleCache.ModuleManager.destroy_package("majiang3d")
						ModuleCache.ModuleManager.show_module("henanmj", "hall")

						PlayerPrefs.SetInt("NeedJumpMatchHistory", 1)
					end
				elseif(ranking == 2) then
					dialogData.btnType = 2
					dialogData.infoStr = "恭喜您，在本次比赛中获得亚军，请快点领取属于您的奖励！"
					dialogData.bottomStr = "请查看比赛记录获取兑奖码领取奖励"
					dialogData.onCallback  = function()
						-- 跳转到 亲友圈-》比赛场-》-》比赛记录
						ModuleCache.ModuleManager.hide_public_module("netprompt")
						ModuleCache.ModuleManager.destroy_package("henanmj")
						ModuleCache.ModuleManager.destroy_package("majiang")
						ModuleCache.ModuleManager.destroy_package("majiang3d")
						ModuleCache.ModuleManager.show_module("henanmj", "hall")

						PlayerPrefs.SetInt("NeedJumpMatchHistory", 1)
					end
				else
					dialogData.btnType = 1
					if( #curTableData.gameState.Player == 3) then
						dialogData.infoStr = "很遗憾，您在本次比赛中获得第3名，没有奖励，下次加油哦！"
					elseif( #curTableData.gameState.Player == 4) then
						if PlayerSort[3].ZongBeiShu == PlayerSort[4].ZongBeiShu then
							dialogData.infoStr = "很遗憾，您在本次比赛中获得第3名，没有奖励，下次加油哦！"
						else
							dialogData.infoStr = string.format( "很遗憾，您在本次比赛中获得第%d名，没有奖励，下次加油哦！",ranking) 
						end
					end
					
					
				end 

				ModuleCache.ModuleManager.show_module("henanmj","matchdialog", dialogData)
			end
		end

	end
end


function TotalGameResultModule:on_module_inited()

end

function TotalGameResultModule:on_module_event_bind()
	self:subscibe_module_event("roomsetting", "Event_Receive_Msg_Exit_Room", function(eventHead, eventData)
		self.exitRoom = true
	end)
end

function TotalGameResultModule:on_click(obj, arg)
	print(obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if(self.lastClickInviteTime and self.lastClickInviteTime + 1 > Time.realtimeSinceStartup)then
		return
	end
	if(obj.name == "BtnReturnHall") then
		if not self.exitRoom then
			self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
		else
			self:dispatch_package_event("Event_Package_Table_LoginAndExit", true)
			ModuleCache.ModuleManager.hide_public_module("netprompt")
			ModuleCache.ModuleManager.destroy_package("henanmj")
			ModuleCache.ModuleManager.destroy_package("majiang")
			ModuleCache.ModuleManager.destroy_package("majiang3d")
			ModuleCache.ModuleManager.show_module("henanmj", "hall")
		end
	elseif(obj.name == "BtnShare") then
		-- shareTypeToggle ： 0 是分享图片   1 分享文字
		if PlayerPrefsManager.GetInt("shareTypeToggle", 0) == 1 then
			ModuleCache.WechatManager.share_text(0, "", ModuleCache.ShareManager().copyText or "获取内容异常~-~")
		else
			ModuleCache.ShareManager().shareImage(false)
		end

	end
end

-- 如果收到点击和自动跳转同时生效就会出问题
function TotalGameResultModule:on_show()
	-- 当结算界面出来后，可以给服务器发包断开连接
	self:dispatch_module_event("roomsetting", "Event_RoomSetting_ExitRoom")
	-- 先去掉，这里难道会有BUG?	
	self.exitRoom = false
end


function TotalGameResultModule:reconnect()
	self.totalGameResultModel.clientConnected = false
	self.totalGameResultModel:connect_server()
end


return  TotalGameResultModule