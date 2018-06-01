-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: 登录模块
-- ===============================================================================================--
-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local ChatHelper = require("package/henanmj/module/chessmuseum/chessmuseum_chat_helper")
local Jpush_manager = require("manager.jpush_manager")

---@class ChessMuseumModule
---@field view ChessMuseumView
local ChessMuseumModule = class("chessMuseumModule",ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager
local UnityEngine = UnityEngine
local GameManager = ModuleCache.GameManager
local PlayerPrefsManager = ModuleCache.PlayerPrefsManager
local CSmartTimer = ModuleCache.SmartTimer.instance
local Time = UnityEngine.Time

local onAppFocusCallback

local GVoiceManager = ModuleCache.GVoiceManager
local Application = UnityEngine.Application

function ChessMuseumModule:initialize(...)
	ModuleBase.initialize(self, "chessmuseum_view", nil, ...)
	self.ChatHelper = ChatHelper:new(self)



	self.view.extendToggle.onValueChanged:AddListener(function(isCheck)
		if(self:is_join()) then
			self.view:extend_roomListPanel(isCheck)

			if isCheck then
				PlayerPrefsManager.SetInt(tostring(self.modelData.roleData.userID) ,1)
			else
				PlayerPrefsManager.SetInt(tostring(self.modelData.roleData.userID),0)
			end
			PlayerPrefsManager.Save()
		end
	end)

	self.view.openTopMsg.onValueChanged:AddListener(function(isCheck)
		if(self:is_join()) then
			if isCheck then
				self.topMsgState = true
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("下一条消息将置顶发送")

			elseif self.topMsgState == true then
				self.topMsgState = false
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("已取消发送置顶消息")
			end
		end
 	end	)


	self.view.input.onValueChanged:AddListener(function(isCheck)
		if(self:is_join()) then
			if self.view.changeVoiceToggle.isOn then
				self.view.chatBarStateSwither:SwitchState("voice")
			else
				if self.view.input.text and self.view.input.text ~= "" then
					self.view.chatBarStateSwither:SwitchState("wordsSend")
				else
					self.view.chatBarStateSwither:SwitchState("words+")
				end
			end
		end

	end	)

	self.view.input.onEndEdit:AddListener(function(isCheck)
		if(self:is_join()) then
			if self.view.changeVoiceToggle.isOn then
				self.view.chatBarStateSwither:SwitchState("voice")
			else
				if self.view.input.text and self.view.input.text ~= "" then
					self.view.chatBarStateSwither:SwitchState("wordsSend")
				else
					self.view.chatBarStateSwither:SwitchState("words+")
				end
			end

			if (  UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.Return) or UnityEngine.Input.GetKeyDown(UnityEngine.KeyCode.KeypadEnter)) then
				self.ChatHelper:send_msg_fun(1)
			end
		end

	end	)

	self.view.changeVoiceToggle.onValueChanged:AddListener(function(isCheck)
		if(self:is_join()) then
			if self.view.changeVoiceToggle.isOn then
				self.view.chatBarStateSwither:SwitchState("voice")
			else
				if self.view.input.text and self.view.input.text ~= "" then
					self.view.chatBarStateSwither:SwitchState("wordsSend")
				else
					self.view.chatBarStateSwither:SwitchState("words+")
				end
			end
		end

	end )

	self.view.emoticonToggle.onValueChanged:AddListener(function(isCheck)
		if(self:is_join()) then
			self.ChatHelper:Init_faces()
			self.view.facePanel:SetActive(isCheck)
		end

	end )
end

function ChessMuseumModule:on_destroy()
	self.ChatHelper.chatMgr.removeEventListener(self.ChatHelper.recvTextMsg, self.ChatHelper.chatMgr.msgTag.groupTag)
	self.ChatHelper.chatMgr.removeEventListener(self.ChatHelper.onRecvOfflineMsg,self.ChatHelper.chatMgr.msgTag.groupTag,true)
print("---------------------进入牌桌删除亲友圈大厅-----------------------------",self.ChatHelper.initFaces)
	self.ChatHelper.initFaces = nil
	self.ChatHelper:on_destroy()
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function ChessMuseumModule:on_module_inited()	
	--[[self.view.inputSearch.onEndEdit:AddListener(function(text)
		self:get_search_results()
	end)]]

	onAppFocusCallback = function(eventHead, eventData)
		if not self.view:is_active() then
			return
		end
		print("onAppFocusCallback : "..tostring(eventData))
		if eventData then
			if self.ChatHelper.chatMgr.isLogin and self.selectDetailData and self.selectDetailData.id and self.ChatHelper.imChatRoom then
				self.ChatHelper:getInitChatData()
			end
		end
	end

	self:subscibe_app_focus_event(onAppFocusCallback)
end


-- 绑定module层的交互事件
function ChessMuseumModule:on_module_event_bind()
	self:subscibe_module_event("chessmuseum", "Event_Update_Notice", function(eventHead, eventData)
		self:get_data_list(self.view.selectIndex)
		if(eventData.toNotice) then
			self:update_notice(eventData)
		end
		ModuleCache.ModuleManager.hide_module("henanmj", "museuminfo")
		ModuleCache.ModuleManager.hide_module("henanmj", "rulesetting")
	end)
	self:subscibe_module_event("chessmuseum", "Event_Update_OneChessMuseum", function(eventHead, eventData)
		self.view:select_item(self.view.selectIndex,function(data)
			if(data) then
				self.selectData = data
				self:get_detail(data)
			end
		end)
	end)

	self:subscibe_module_event("match","Update_CurParlor_Detail",function( eventHead, eventData )
		self:get_data_list(self.view.selectIndex, function( )
			self:dispatch_module_event("match","Event_Updata_Parlor_Detail",self.selectDetailData)
		end)
		
	end)

	self:subscibe_module_event("rulesetting", "Update_Power", function(eventHead, eventData)
       self.selectDetailData.diamondCostVitality=eventData;
    end )

	self:subscibe_module_event("museumroominfo_to_chessmuseum", "Event_Update_roomList", function(eventHead, eventData)
		self:getRoomList(eventData)
	end )

	self:subscibe_module_event("joinroom_to_chessmuseum","Update_User_Parlor_List",function( eventHead, eventData )
		self:get_data_list(self.view.selectIndex)
	end)

	self:subscibe_package_event("alertDialog_toggle_inOn",function( eventHead, eventData )
		self.alertDialog_toggle_inOn = eventData
	end)

	self:subscibe_module_event("jPush_manager","jPush_recv_msg",function( eventHead, eventData )
		print_table(eventData, "-------------------jPush_recv_msg----"..eventData.type)
		local roomInfo = ModuleCache.Json.decode(eventData.message)

		if eventData.type == "parlor_top_message_change" then
			--获取置顶消息
			self.ChatHelper:get_top_msg()
		elseif eventData.type == "parlor_room_change_add" then
			--self.roomDataTab.roomTab[eventData.data.roomId] = eventData.data

			if # self.roomDataTab.list == 1 and tonumber(self.roomDataTab.list[1].roomId) <100000 then
				table.remove(self.roomDataTab.list,1)
			end
			self.roomDataTab.list[#self.roomDataTab.list+1] = roomInfo

			self:RefreshRoomShow()
		elseif eventData.type == "parlor_room_change_update" then
			--self.roomDataTab.roomTab[eventData.data.roomId] = eventData.data

			for i = 1,#self.roomDataTab.list do
				local data = self.roomDataTab.list[i]
				if tonumber(data.roomId) == tonumber(roomInfo.roomId) then
					self.roomDataTab.list[i] = roomInfo
					break
				end
			end

			self:RefreshRoomShow()
		elseif eventData.type == "parlor_room_change_delete" then
			--self.roomDataTab.roomTab[eventData.data.roomId] = nil

			for i = 1,#self.roomDataTab.list do
				local data = self.roomDataTab.list[i]
				if tonumber(data.roomId) == tonumber(roomInfo.roomId) then
					table.remove(self.roomDataTab.list,i)
					break
				end
			end

			self:RefreshRoomShow()
		end


	end)
end

function ChessMuseumModule:RefreshRoomShow()
	if not self.roomDataTab  then
		--请求显示房间列表
		self:getRoomList(self.selectDetailData.parlorNum)
		return
	end

	self:disposeRoomList(self.roomDataTab.list)
	print_table(self.roomDataTab, "----------initLoopScrollViewList_roomList-----------------".. #self.roomDataTab)
	self.view:initLoopScrollViewList_roomList(self.roomDataTab)
end

-- 绑定loginModel层事件，模块内交互
function ChessMuseumModule:on_model_event_bind()
	
end

function ChessMuseumModule:on_show(data)
	self.museumData = data.museumData
	self.roomDataTab = nil
	
    self.view.selectIndex = self:get_index_by_parlorId( PlayerPrefsManager.GetInt("museumIndex", 1) )
   -- print("---------------get------------ self.view.selectIndex:", self.view.selectIndex,PlayerPrefsManager.GetInt("museumIndex", 1))

	self.playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)
	self.view.parlorWeiXin = self.modelData.parlorWeiXin or ""
	PlayerPrefsManager.SetInt("showMuseum", 1)
	PlayerPrefsManager.Save()

	if(not self.view.selectIndex) then
		self.view.selectIndex = 1
	end
	self.selectDetailData = data.museumDetailData
	self.view:initLoopScrollViewList(data.museumData)
	self.view:select_item(self.view.selectIndex, function(data)
		if(data) then
			self.selectData = data

			if(self.selectData.parlorLogo) then
				self.selectDetailData.imageHead = self.selectData.parlorLogo
			else
				self.selectDetailData.imageHead = self.selectData.headImg
			end

			--self.selectDetailData.headImgList = self.selectData.headImgList
			-- 打开棋牌馆的群二维码分享
			if self.selectDetailData.qrCodeShow == 1 and self.selectDetailData.playerRole ~= "VISITOR" and self.selectDetailData.playerRole ~= "APPLYING" then
				self:InitShareMuseum()
			end

			--print("------on_show-----self.selectDetailData.playRule:",self.selectDetailData.playRule,self.selectDetailData.playerRole)
			if self.selectDetailData.playRule == "" and self.selectDetailData.playerRole == "OWNER" then
				ModuleCache.ModuleManager.show_module("henanmj", "museuminfo", self.selectDetailData)
			end

			self.view:get_detail(self.selectDetailData)

			self:get_approval_member(self.selectDetailData.parlorNum)

			--请求显示房间列表
			self:getRoomList(self.selectDetailData.parlorNum)
			--获取置顶消息
			self.ChatHelper:get_top_msg()

			Jpush_manager.setTagWithPyq(self.selectDetailData.parlorNum)

			if self.selectDetailData and self.selectDetailData.id then

				if self.ChatHelper.chatMgr.isLogin then
					self.ChatHelper:get_group_id()
				else
					self.ChatHelper:get_user_name()
				end
			end
		end
	end)

	self:get_parlor_cost()
	self.lastUpdateBeatTime =  Time.realtimeSinceStartup
end


function ChessMuseumModule:on_update_per_second()
	if self.modelData and self.modelData.roomRequest == 1 and self.modelData.roomRequestTime >0 then
		if self.lastUpdateBeatTime and self.lastUpdateBeatTime + self.modelData.roomRequestTime > Time.realtimeSinceStartup then
			return
		end

		self.lastUpdateBeatTime = Time.realtimeSinceStartup
		if self.selectDetailData then
			self:getRoomList(self.selectDetailData.parlorNum,false,false)--请求刷新房间列表
		end
	end

end

function ChessMuseumModule:get_index_by_parlorId(parlorId)
    for i, v in ipairs(self.museumData) do
        if v.parlorId == parlorId then
            return i
        end
    end
    return 1
end

function ChessMuseumModule:on_press(obj, arg)
	if obj.name == "ButtonMic" then
		self.ChatHelper:press_voice( obj, arg)
	end
end

function ChessMuseumModule:on_press_up(obj, arg)
	if(obj and obj.name == "ButtonMic") then
		self.ChatHelper:press_up_voice( obj, arg)
	end

end

function ChessMuseumModule:on_drag(obj, arg)
	if(obj and obj.name == "ButtonMic") then
		self.ChatHelper:on_drag_voice( obj, arg)
	end
end

function ChessMuseumModule:on_click(obj, arg)	
	print("--------------click obj:",obj.name)
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	if obj == self.view.buttonClose.gameObject then
		PlayerPrefsManager.SetInt("showMuseum", 0)
		PlayerPrefsManager.Save()

		self:dispatch_package_event("Event_Show_Hall_Anim")
		ModuleCache.ModuleManager.hide_module("henanmj", "chessmuseum")

	elseif(obj.name == "AddItem") then
		ModuleCache.ModuleManager.show_module("henanmj", "joinroom",{mode =2})
	elseif(obj.name == "clickMuseumObj") then
		local parentName = obj.transform.parent.gameObject.name
		if(string.sub(parentName, 1, 4) == "item") then
			local array = string.split(parentName, "_")
			self.view:select_item(tonumber(array[2]),function(data)
				if(data) then
					self.selectData = data
					self:get_detail(data)
				end
			end)
		end

	elseif(obj.name == "ButtonPlayer") then
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_module("henanmj", "museummembers", self.selectDetailData)
		end
	elseif(obj.name == "ButtonSetting") then
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_module("henanmj", "museuminfo", self.selectDetailData)
		end
	elseif(obj.name == "ButtonInfo") then
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_module("henanmj", "museuminfo", self.selectDetailData)
		end
	elseif(obj.name == "ButtonFightLog") then
		if(self:is_join()) then
			self:getHistoryList()
		end

	elseif(obj.name == "FreeCreateBtn") then
		if(self:is_join()) then
			local sendData =
			{
				clickType = 1,
				showType = 2,
				data = self.selectDetailData
			}
			ModuleCache.ModuleManager.show_module("henanmj", "createroom", sendData)
		end
	elseif(obj.name == "clickRoomObj") then
		if(self:is_join()) then
			local array = string.split(obj.transform.parent.gameObject.name, "_")
			local idx = tonumber(array[2])
			local roomData = self.view:get_room_data(idx)

			if self.selectDetailData.playerRole ~= "OWNER" and self.selectDetailData.playerRole ~= "ADMIN" and self.view:get_room_data(idx).roomType == 2 then
				if roomData.roleFull == 0 then -- 房间人满了
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("房间已满")
				else
					local playRule = TableUtil.convert_rule(self.selectDetailData.playRule)
					local gameName = ""
					local roomData = roomData
					self:getRoomList(self.selectDetailData.parlorNum)

					if playRule.gameName and playRule.gameName ~= "" then
						gameName = playRule.gameName
					else--有得rule里没有 playRule.gameName
						local wanfaType = Config.GetWanfaIdx(playRule.GameType)
						gameName = Config.get_create_name(wanfaType)
					end

					if(roomData.roomType == 1) then
						TableManager:join_room(roomData.roomId, nil, nil, nil, playRule)
					else
						if tonumber(roomData.roomId) <100000 then--客户端显示的假房间 显示的是馆号
							TableManager:join_room(self.selectDetailData.parlorNum, gameName, nil, nil, playRule)
						else
							TableManager:join_room(roomData.roomId, nil, nil, nil, playRule)
						end
					end

					print("--------self.selectDetailData.parlorNum:",self.selectDetailData.parlorNum,gameName)
				end
			else
				ModuleCache.ModuleManager.show_module("henanmj", "museumroominfo", {
					data = roomData,
					museumData = self.selectDetailData,
					callback = function()
						local playRule = TableUtil.convert_rule(self.selectDetailData.playRule)
						local gameName = ""
						local roomData = roomData
						self:getRoomList(self.selectDetailData.parlorNum)

						if playRule.gameName and playRule.gameName ~= "" then
							gameName = playRule.gameName
						else--有得rule里没有 playRule.gameName
							local wanfaType = Config.GetWanfaIdx(playRule.GameType)
							gameName = Config.get_create_name(wanfaType)
						end

						if(roomData.roomType == 1) then
							TableManager:join_room(roomData.roomId, nil, nil, nil, playRule)
						else
							if tonumber(roomData.roomId) <100000 then --客户端显示的假房间 显示的是馆号
								TableManager:join_room(self.selectDetailData.parlorNum, gameName, nil, nil, playRule)--默认房间
							else
								TableManager:join_room(roomData.roomId, nil, nil, nil, playRule)
							end
						end

						print("--------self.selectDetailData.parlorNum:",self.selectDetailData.parlorNum,gameName)
					end
				})
			end
		end

	elseif(obj.name == "NoticeBtn") then
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_module("henanmj", "museumnotice", self.selectDetailData)
		end

	elseif(obj.name == "ButtonRanking") then
		--TODO 排行榜
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_module("henanmj", "museumranking",self.selectDetailData)
		end

	elseif(obj.name == "RefreshListBtn") then
		if(self:is_join()) then
			self.view.refreshListBtn.interactable = false
			self.view.refreshList_disableObj:SetActive(true)
			self:getRoomList(self.selectDetailData.parlorNum)

			if self.kickedTimeId then
				CSmartTimer:Kill(self.kickedTimeId)
			end

			self.kickedTimeId = self:subscibe_time_event(3, false, 0):OnUpdate(function(t)
				t = t.surplusTimeRound
				self.view.refreshList_countDownTex.text = t
			end):OnComplete(function(t)
				self.view.refreshListBtn.interactable = true
				self.view.refreshList_disableObj:SetActive(false)
			end).id
		end
	elseif(obj.name == "qrCodeBtn") then
		if(self:is_join()) then
			-- 打开棋牌馆的群二维码分享
			if self.selectDetailData.qrCodeImg and self.selectDetailData.qrCodeImg ~= "" then
				self:InitShareMuseum()
			else
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("圈主尚未上传群二维码")
			end

		end
	elseif obj.name == "loadButton" then
		self.roomDataTab.currentPage = self.roomDataTab.currentPage +1
		self:getRoomList(self.selectDetailData.parlorNum , true)
	elseif obj.name == "sendBtn" then
		if(self:is_join()) then
			self.ChatHelper:send_msg_fun(1)
		end

	elseif obj.name == "deleteButton_self" or  obj.name == "deleteButton_other" or  obj.name == "deleteButton" then
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您确认要删除此条置顶消息吗？"), function()
				local array = string.split(obj.transform.parent.parent.gameObject.name, "_")
				if # array < 2 then
					array = string.split(obj.transform.parent.parent.parent.gameObject.name, "_")
				end

				if # array < 2 then
					array = string.split(obj.transform.parent.parent.parent.parent.gameObject.name, "_")
				end
				local idx = tonumber(array[2])

				self.ChatHelper:delete_top_msg( self.view:get_top_msg_data(idx))
			end, nil)
		end
	elseif obj.name == "msgTex" or obj.name == "msgTex_zj" then--聊天泡泡
		if(self:is_join()) then
			local array = string.split(obj.transform.parent.gameObject.name, "_")
			local idx = tonumber(array[2])

			local msgData = nil
			if obj.transform.parent.parent.parent.parent.gameObject.name == "ListScrollView_topMsg" then
				msgData = self.view:get_top_msg_data(idx)
			elseif obj.transform.parent.parent.parent.parent.gameObject.name == "ListScrollView_chatMsg" then
				msgData = self.view:get_chat_msg_data(idx)
			end

			if msgData then
				print(msgData.msgType,"---------msgData.msgType-----------msgData.content:",msgData.content)

				if tonumber(msgData.msgType) == 1 then
					ModuleCache.GameSDKInterface:CopyToClipboard(msgData.content)
					ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("文字消息复制成功")
				elseif tonumber(msgData.msgType) == 2 then
					--下载语音播放
					self.ChatHelper:on_click_voice_bubble(msgData.content)
					if self.playVoiceAnim then
						self.playVoiceAnim(false)
					end

					self.playVoiceAnim = function(isPlay)
						if tostring(msgData.userId) == tostring(self.modelData.roleData.userId) then
							ModuleCache.ComponentManager.GetComponentWithPath(obj.gameObject,"voicePop/voiceIcon_self/imageAnimation", ModuleCache.ComponentTypeName.Transform).gameObject:SetActive(isPlay)
							ModuleCache.ComponentManager.GetComponentWithPath(obj.gameObject,"voicePop/voiceIcon_self", ModuleCache.ComponentTypeName.Image).enabled = not isPlay
						else
							ModuleCache.ComponentManager.GetComponentWithPath(obj.gameObject,"voicePop/voiceIcon_other/imageAnimation", ModuleCache.ComponentTypeName.Transform).gameObject:SetActive(isPlay)
							ModuleCache.ComponentManager.GetComponentWithPath(obj.gameObject,"voicePop/voiceIcon_other", ModuleCache.ComponentTypeName.Image).enabled = not isPlay
						end
					end

					PlayerPrefsManager.SetInt(msgData.id, 1)
					PlayerPrefsManager.Save()

					if tostring(msgData.userId) == tostring(self.modelData.roleData.userId) then
						ModuleCache.ComponentManager.GetComponentWithPath(obj.gameObject,"voicePop/self/voiceLength_self/Image", ModuleCache.ComponentTypeName.Transform).gameObject:SetActive(false)
					else
						ModuleCache.ComponentManager.GetComponentWithPath(obj.gameObject,"voicePop/other/voiceLength_other/Image", ModuleCache.ComponentTypeName.Transform).gameObject:SetActive(false)
					end

				end
			end
		end

	elseif(obj.name == "faceImg") then
		if(self:is_join()) then
			self.view.emoticonToggle.isOn = false
			self.view.input.text = obj.transform.parent.gameObject.name
			self.ChatHelper:send_msg_fun(3)
		end

	elseif(obj.name == "otherBtn") then
		if(self:is_join()) then
			--ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("敬请期待！")

			if ModuleCache.GameManager.runtimePlatform == "OSXEditor" or ModuleCache.GameManager.runtimePlatform == "WindowsEditor" then
				local data
				if math.random()< 0.3 then
					data =ModuleCache.FileUtility.ReadAllBytes(Application.dataPath .. "/Resources/h.png")
				elseif math.random()< 0.6 then
					data =ModuleCache.FileUtility.ReadAllBytes(Application.dataPath .. "/Resources/w.png")
				else
					data =ModuleCache.FileUtility.ReadAllBytes(Application.dataPath .. "/Resources/xiaotu.png")
				end

				ModuleCache.CustomImageManager.upload_image_file(data)
			elseif ModuleCache.GameManager.runtimePlatform == "Android" then
				local Json = {
					maxWidth = 1280,
					maxHeight = 720,
					compressQuality = 60
				}
				ModuleCache.GameSDKInterface:OpenPick(ModuleCache.GameUtil.table_encode_to_json(Json))
			else
				ModuleCache.GameSDKInterface:OpenPick("")
			end
		end
	elseif(obj.name == "Image_msg") then
		if(self:is_join()) then
			local rawImg = ModuleCache.ComponentManager.GetComponent(obj.gameObject, ModuleCache.ComponentTypeName.RawImage)

			self.view.originalImg.texture = rawImg.texture

			self.view.originalImgObj:SetActive(true)
			self.view.originalImgRectTran.sizeDelta = ModuleCache.CustomerUtil.GetTexture2dSize(self.view.originalImg.texture)
			--self.view.originalImgRectTran.sizeDelta = Vector2.New(rawImg.texture.width,rawImg.texture.height) --ModuleCache.CustomerUtil.GetTexture2d_w_h(rawImg.texure)

			local array = string.split(obj.transform.parent.gameObject.name, "_")
			local idx = tonumber(array[2])

			--if obj.transform.parent.parent.parent.parent.gameObject.name == "ListScrollView_topMsg" then
			--	self.curOpenImgData = self.view:get_top_msg_data(idx)
			--elseif obj.transform.parent.parent.parent.parent.gameObject.name == "ListScrollView_chatMsg" then
				self.curOpenImgData = self.view:get_chat_msg_data(idx)
			--end
		end
	elseif(obj.name == "OriginalImg") then
		if(self:is_join()) then
			self.view.originalImgObj:SetActive(false)
		end
	elseif(obj.name == "shareImgBtn") then
		if(self:is_join()) then
			if self.curOpenImgData then
				local arr = string.split(self.curOpenImgData.content, "_")
				local key =""
				if # arr > 2 then
					key = arr[1]
				end
				ModuleCache.WechatManager.share_image(0, "大胡亲友圈", ModuleCache.CustomImageManager.CachesTexture[key])
			end

		end
	elseif(obj.name == "AccBtn") then
		if(self:is_join()) then
			ModuleCache.ModuleManager.show_module("henanmj", "museumacc", self.selectDetailData)
		end
	end
end

function ChessMuseumModule:InitShareMuseum()
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(self.selectDetailData.qrCodeImg, function(err, tex)
        if err then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("加载失败！")
        else
			self.selectDetailData.qrCodeSpr = tex
			ModuleCache.ModuleManager.show_module("henanmj", "sharemuseum",self.selectDetailData)
        end
    end )
end

function ChessMuseumModule:get_parlor_cost()
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getParlorCost?",
		--showModuleNetprompt = true,
		params =
		{
			uid = self.modelData.roleData.userID,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if (retData.success) then
			self.modelData.addParlorCost =retData.data.addCost	--创建亲友圈费用
			self.modelData.topMessageCost =retData.data.topMessageCost--亲友圈置顶消息费用

			self.modelData.roomRequest =retData.data.roomRequest	--自动刷新房间列表开关    0关  1开
			self.modelData.roomRequestTime =retData.data.roomRequestTime--自动刷新房间列表时间

			self.modelData.timeStampOffset = retData.data.serverTime - os.time()
			self.modelData.getServerTime = function()
				if self.modelData.timeStampOffset then
					if self.modelData.timeStampOffset > 0 then
						return os.date("%Y-%m-%d %H:%M:%S", os.time() + self.modelData.timeStampOffset )
					else
						return os.date("%Y-%m-%d %H:%M:%S", os.time() - self.modelData.timeStampOffset )
					end

				else
					return os.date("%Y-%m-%d %H:%M:%S")
				end

			end

			self.modelData.getTimeStamp = function()
				if self.modelData.timeStampOffset then
					if self.modelData.timeStampOffset > 0 then
						return os.time() + self.modelData.timeStampOffset
					else
						return os.time() - self.modelData.timeStampOffset
					end

				else
					return os.time()
				end

			end
		else

		end
	end , function(wwwErrorData)
		print(wwwErrorData.error)
	end )
end

function ChessMuseumModule:get_data_list(index, act)
	if(not index) then
		index = 1
	end


	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getUserParlorList?",
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.view:initLoopScrollViewList(retData.data)
			-- print(index,"---------------get------------ self.view.selectIndex:", self.view.selectIndex)
			--TODO XLQ 修复 修改亲友圈设置 重新获取亲友圈列表时记录上次选择的亲友圈 不正确的bug
			self.museumData = retData.data
			self.view.selectIndex = self:get_index_by_parlorId( PlayerPrefsManager.GetInt("museumIndex", 1) )
			index = self.view.selectIndex
			-- print(index,"---------------get------------ self.view.selectIndex:", self.view.selectIndex,PlayerPrefsManager.GetInt("museumIndex", 1))

			self.view:select_item(index,function(data)
				if(data) then
					self.selectData = data
					self:get_detail(data, act)
				end
			end)
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)
end


function ChessMuseumModule:get_search_results()
	 if self.view.inputSearch.text == nil or self.view.inputSearch.text == "" then
        ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("请联系代理询问圈号")
        return
    end

    self:join_museum(tonumber(self.view.inputSearch.text))
	-- local requestData = {
	-- 	baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/search?",
	-- 	--showModuleNetprompt = true,
	-- 	params = {
	-- 		uid = self.modelData.roleData.userID,
	-- 		platformName = GameManager.customPlatformName,
	-- 		assetVersion = GameManager.appAssetVersion,
	-- 		page = 1,
	-- 		rows = 20,
	-- 		searchText = self.view.inputSearch.text
	-- 	}
	-- }
	-- self:http_get(requestData, function(wwwData)
	-- 	local retData = wwwData.www.text
	-- 	retData = ModuleCache.Json.decode(retData)
	-- 	if(retData.success) then
	-- 		self.view:initLoopScrollViewList(retData.data.rows, true)
	-- 		self.view:select_item(1,function(data)
	-- 			if(data) then
	-- 				self.selectData = data
	-- 				self:get_detail(data)
	-- 			end
	-- 		end)
	-- 	end
	-- end, function(wwwErrorData)
    --     print(wwwErrorData.error)
	-- end)
end

function ChessMuseumModule:join_museum(parlorNum)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/applyMember?",
         showModuleNetprompt = true,
        params =
        {
            uid = self.modelData.roleData.userID,
            platformName = GameManager.customPlatformName,
            assetVersion = GameManager.appAssetVersion,
            parlorNum = parlorNum
        }
    }
	self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            ModuleCache.ModuleManager.show_public_module("alertdialog"):show_center_button("申请成功，请等待圈主审核", function()
                self:dispatch_module_event("chessmuseum", "Event_Update_OneChessMuseum")
                ModuleCache.ModuleManager.hide_module("henanmj", "museumjoin")
            end )
        else
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.errMsg)
            ModuleCache.ModuleManager.hide_module("henanmj", "museumjoin")
        end
    end , function(wwwErrorData)
        print(wwwErrorData.error)
        if tostring(wwwErrorData.error):find("500") ~= nil or tostring(wwwErrorData.error):find("error") ~= nil then
            if wwwErrorData.www.text then
                local retData = wwwErrorData.www.text
                retData = ModuleCache.Json.decode(retData)
                if retData.errMsg then
                    retData = ModuleCache.Json.decode(retData.errMsg)
                    ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(retData.message)
                    if tostring(retData.message):find("在亲友圈") ~= nil then
                        self:get_data_list(self.view.selectIndex)
                    end
                end
            end
        end
    end )
end

function ChessMuseumModule:get_detail(data, act)
	self.view:initLoopScrollViewList_chatMsg({},false)

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/list/getParlorDetail?",
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			page = 1,
			rows = 20,
			id = data.id
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			self.selectDetailData = retData.data
			if(self.selectData.parlorLogo) then
				self.selectDetailData.imageHead = self.selectData.parlorLogo
			else
				self.selectDetailData.imageHead = self.selectData.headImg
			end

			--self.selectDetailData.headImgList = self.selectData.headImgList
			--弹出二维码
			if self.selectDetailData.qrCodeShow == 1 and self.selectDetailData.playerRole ~= "VISITOR" and self.selectDetailData.playerRole ~= "APPLYING" then
				self:InitShareMuseum()
			end
			--print("-----------self.selectDetailData.playRule:",self.selectDetailData.playRule,self.selectDetailData.playerRole)
			if self.selectDetailData.playRule == "" and self.selectDetailData.playerRole == "OWNER" then
				ModuleCache.ModuleManager.show_module("henanmj", "museuminfo", self.selectDetailData)
			end

			self.view:get_detail(retData.data)

			self:get_approval_member(retData.data.parlorNum)

			--请求显示房间列表
			self:getRoomList(retData.data.parlorNum)
			--获取置顶消息
			self.ChatHelper:get_top_msg()

			Jpush_manager.setTagWithPyq(retData.data.parlorNum)

			--print("-----------------self.selectDetailData:",self.selectDetailData,self.selectDetailData.id)
			if self.selectDetailData and self.selectDetailData.id then

				if self.ChatHelper.chatMgr.isLogin then
					self.ChatHelper:get_group_id()
				else
					self.ChatHelper:get_user_name()
				end
			end

			if act then
				act()
			end
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)
end

function ChessMuseumModule:is_join()
	if(self.selectDetailData.playerRole == "APPLYING" ) then
		self.view:select_item(self.view.selectIndex,function(data)
			if(data) then
				self.selectData = data
				self:get_detail(data)
			end
		end)
		ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("正在审核中，请稍后！")
	elseif(self.selectDetailData.playerRole == "VISITOR" ) then
		ModuleCache.ModuleManager.show_public_module("alertdialog"):show_common(string.format("您尚未加入此亲友圈，是否申请加入？"), function()
			ModuleCache.ModuleManager.show_module("henanmj", "museumjoin", self.selectData.parlorNum)
		end, nil)
	end
	return self.selectDetailData.playerRole ~= "VISITOR" and self.selectDetailData.playerRole ~= "APPLYING"
end

function ChessMuseumModule:update_notice(data)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/room/updateNotice?",
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = data.parlorNum,
			notice = data.notice
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			if(data.showMsg) then
				ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(AppData.MuseumName .."公告修改成功")
			end
		else
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(AppData.MuseumName .."公告修改失败")
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)
end

function ChessMuseumModule:getHistoryList()
 	self.playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId, ModuleCache.GameManager.curLocation)
	local addStr = "gamehistory/roomlist/parlor?"
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. addStr,
		showModuleNetprompt = true,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = ModuleCache.GameManager.customPlatformName,
			assetVersion = ModuleCache.GameManager.appAssetVersion,
			parlorId = self.selectDetailData.id
		}
	}
	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
            ModuleCache.ModuleManager.show_module(self.playMode.package, "historylist", self:get_new_list(retData.data.list))
		end
	end, function(wwwErrorData)
        print(wwwErrorData.error)
	end)

end

function ChessMuseumModule:get_new_list(list)
	local newList = {}
	local maxNum = 0
	if(not self.selectDetailData or (self.selectDetailData and self.selectDetailData.playerRole ~= "OWNER")) then
		maxNum = 20
	else
		maxNum = 100
	end
	if(#list < maxNum) then
		return list
	else
		for i=1,maxNum do
			table.insert(newList,list[i])
		end
		return newList
	end
end

function ChessMuseumModule:get_approval_member(parlorNum)
    self.view.membersNewMsgObj:SetActive(false)
    if self.selectDetailData and self.selectDetailData.playerRole ~= "OWNER" then
        return
    end

    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "parlor/member/getApprovalMember?",
        -- showModuleNetprompt = true,
        params =
        {
            uid = self.modelData.roleData.userID,
            platformName = GameManager.customPlatformName,
            assetVersion = GameManager.appAssetVersion,
            parlorNum = parlorNum
        }
    }
	self:http_get(requestData, function(wwwData)
        local retData = wwwData.www.text
        retData = ModuleCache.Json.decode(retData)
        if (retData.success) then
            self.retData = retData.data

            self.view.membersNewMsgObj:SetActive(#self.retData > 0)
            self.view.membersNewMsgTex.text = #self.retData
        end
    end , function(wwwErrorData)
        print(wwwErrorData.error)
    end )
end

--获取亲友圈房间列表
function ChessMuseumModule:getRoomList(parlorNum, isloadMore,showModuleNetprompt)
	if not isloadMore then
		self.roomDataTab = nil
	end
	--print_traceback(parlorNum.."---------###getRoomList--------------")
	if self.roomDataTab ~= nil  and not isloadMore then
		self.view:initLoopScrollViewList_roomList(self.roomDataTab)
		return
	end

	local curPageNum = 1
	if self.roomDataTab and self.roomDataTab.currentPage then
		curPageNum = self.roomDataTab.currentPage
	end

	if showModuleNetprompt == nil then
		showModuleNetprompt = true
	end

	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .."parlor/room/allPage?",
		showModuleNetprompt = showModuleNetprompt,
		params = {
			uid = self.modelData.roleData.userID,
			platformName = GameManager.customPlatformName,
			assetVersion = GameManager.appAssetVersion,
			parlorNum = parlorNum,
			pageSize = 15,
			pageNum = curPageNum,
		}
	}

	self:http_get(requestData, function(wwwData)
		local retData = wwwData.www.text
		retData = ModuleCache.Json.decode(retData)
		if(retData.success) then
			--TODO XLQ :修复自动刷新房间列表请求收到回包前 切换了亲友圈 房间列表显示上一个亲友圈房间列表的问题
			if parlorNum ~= self.selectDetailData.parlorNum then
				return
			end

			if not isloadMore then
				self:disposeRoomList(retData.data.list)
			end

			if self.roomDataTab == nil then
				self.roomDataTab = retData.data
			elseif isloadMore then
				for i =1, #retData.data.list do
					table.insert(self.roomDataTab.list,#self.roomDataTab.list +1, retData.data.list[i])
				end
			end

			--for i = 1,#self.roomDataTab.list do
			--	local data = self.roomDataTab.list[i]
			--	if self.roomDataTab.roomTab ~= nil then
			--		self.roomDataTab.roomTab[data.roomId] = data
			--	else
			--		self.roomDataTab.roomTab = {}
			--		self.roomDataTab.roomTab[data.roomId] = data
			--	end
			--
			--end

			self.view:initLoopScrollViewList_roomList(self.roomDataTab)

		end
	end, function(wwwErrorData)
		print(wwwErrorData.error)
		ModuleCache.ModuleManager.hide_public_module("netprompt")
	end)

end

--获取亲友圈房间列表
function ChessMuseumModule:disposeRoomList(roomList)
	if #roomList == 0 then
		roomList[1] = {
			roomType =2,
			curRound = 0,
			roundCount =self.selectDetailData.roundCount,
			playerCount = self.selectDetailData.playerCount,
			players = {},
			playRule = self.selectDetailData.playRule,
			roomId = "0"..self.selectDetailData.parlorNum
		}
	else
		--local allFull = true
		--local hasCanJoinFastRoom = false
		----TODO XLQ:可以中途加入的游戏在开局后 需要创建一个新房间
		--local needCreateNewRoom = (AppData.Game_Name == "ZHAJINHUA" or AppData.Game_Name == "BIJI" or AppData.Game_Name == "BULLFIGHT" or AppData.Game_Name == "SANGONG")
        --
		--for i = 1, #roomList do
		--	if roomList[i].playerCount > #roomList[i].players then
		--		allFull = false
		--		if roomList[i].roomType == 2 then
		--			hasCanJoinFastRoom = true
		--		end
		--	end
        --
		--	if roomList[i].curRound  == 0  then
		--		needCreateNewRoom = false
		--	end
		--end
        --
		--if allFull or not hasCanJoinFastRoom or needCreateNewRoom then
		--	table.insert(roomList,1,{
		--		roomType =2,
		--		curRound = 0,
		--		roundCount =self.selectDetailData.roundCount,
		--		playerCount = self.selectDetailData.playerCount,
		--		players = {},
		--		playRule = self.selectDetailData.playRule,
		--		roomId = "0"..self.selectDetailData.parlorNum
		--	})
		--end

		local notNullRoom = true

		for i = 1, #roomList do
			if #roomList[i].players == 0 then
				notNullRoom = false
			end
		end

		if notNullRoom then
			table.insert(roomList,1,{
				roomType =2,
				curRound = 0,
				roundCount =self.selectDetailData.roundCount,
				playerCount = self.selectDetailData.playerCount,
				players = {},
				playRule = self.selectDetailData.playRule,
				roomId = "0"..self.selectDetailData.parlorNum
			})
		end
	end

	for i = 1, #roomList do
		if roomList[i].playerCount == #roomList[i].players then
			roomList[i].roleFull = 0
		else
			roomList[i].roleFull = 1
		end
	end
end


return ChessMuseumModule



