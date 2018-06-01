-- 初始化
local class = require("lib.middleclass")
local ModuleBase = require("core.mvvm.module_base")
local EnterGameDlgModule = class("Public.EnterGameDlgModule", ModuleBase)

-- 常用模块引用
local ModuleCache = ModuleCache
local NetClientManager = ModuleCache.net.NetClientManager

function EnterGameDlgModule:initialize(...)
	-- 开始初始化                view        loginModel           模块数据
	ModuleBase.initialize(self, "entergamedlg_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，Model初始化完成
function EnterGameDlgModule:on_module_inited()

end

-- 绑定module层的交互事件
function EnterGameDlgModule:on_module_event_bind()

end

-- 绑定Model层事件，模块内交互
function EnterGameDlgModule:on_model_event_bind()
	

end

function EnterGameDlgModule:on_show(data)
	if data then
		self.data = data
	else
		ModuleCache.ModuleManager.destroy_module("public", "entergamedlg")
		return
	end
	local rules = string.split(data.rule, ";")
	local title = rules[1]
	local content = rules[2]
	local subCode = string.sub(data.code, 2, #data.code - 1)
	print("sub code = " .. subCode)

	local procvinceStr = string.match(subCode, "x[%d]y")
	self.provinceId = tonumber( string.sub(procvinceStr, 2,   #procvinceStr -1))
	print("procvinceStr = "..procvinceStr)

	local gameIdStr = string.match(subCode, "y[%d]O")
	self.gameId = tonumber( string.sub(gameIdStr, 2,   #gameIdStr -1))
	print("gameIdStr = "..gameIdStr)

	local roomIdStr = string.match(subCode, "O(.+)")
	self.roomId = ModuleCache.GameManager.decodeRoomId( roomIdStr)
	print("roomIdStr = "..roomIdStr)

	print("provinceId = "..self.provinceId)
	print("gameId = "..self.gameId)
	print("roomId = "..self.roomId)

	self.view.title.text = title
	self.view.contentTxt.text = "收到房间号【"..self.roomId.."】的牌局邀请:                     \n\n"..content

	if data.enter then
		local gameName = ModuleCache.PlayModeUtil.getInfoByGameId(tonumber(self.gameId)).createName
		self:connect_login_server(tonumber(self.roomId), gameName)
	end

end

function EnterGameDlgModule:on_click(obj, arg)	
	ModuleCache.SoundManager.play_sound("henanmj", "henanmj/sound/button.bytes", "button")
	--ModuleCache.FunctionManager.ClearClipBoard()
	if obj.name == self.view.btnOK.name then
		if ModuleCache.GameManager.curProvince ~= self.provinceId and self.provinceId ~= 12 then
			local text = ModuleCache.GameSDKInterface:GetTextFromClipboard()
			text = text.."O0enter0O"
			ModuleCache.GameSDKInterface:CopyToClipboard(text)
			ModuleCache.GameManager.select_province_id(tonumber(self.provinceId))
			ModuleCache.GameManager.select_game_id(tonumber(self.gameId))
			ModuleCache.GameManager.logout()
		else
			ModuleCache.FunctionManager.ClearClipBoard()
			ModuleCache.GameManager.select_game_id(tonumber(self.gameId))
			local gameName = ModuleCache.PlayModeUtil.getInfoByGameId(tonumber(self.gameId)).createName
			self:connect_login_server(tonumber(self.roomId), gameName)
		end
	else
		ModuleCache.FunctionManager.ClearClipBoard()
	end
	print("ModuleCache.GameSDKInterface:GetTextFromClipboard() = "..ModuleCache.GameSDKInterface:GetTextFromClipboard())
	ModuleCache.ModuleManager.destroy_module("public", "entergamedlg")
end

function EnterGameDlgModule:connect_login_server(roomId, gameName)
	TableManager:connect_login_server( function(state)
		TableManager:request_login_login_server(self.modelData.roleData.userID, self.modelData.roleData.password)
	end,
	-- 登录回调
	function(data)
		if (not data.ErrorCode or data.ErrorCode == 0) then
			if (data.RoomID ~= 0) then
				roomId = data.RoomID
			end
			TableManager:request_join_room_login_server(roomId, gameName)
		else
			TableManager:disconnect_login_server()
			if data.ErrorInfo == "密码检验失败" or data.ErrorInfo == "密码校验失败" then
				ModuleCache.GameManager.logout()
			end
			ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips(data.ErrorInfo)
		end
	end
	,
	nil, nil)
end

return EnterGameDlgModule



