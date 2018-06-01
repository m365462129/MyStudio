-- ==============================================================================
-- User: dred
-- Date: 2016/11/30
-- Time: 12:06
-- Desc: 
-- ============================================================================== 
local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next
local debug = debug
local string = string
local GameSDKInterface = LuaBridge.GameSDKInterface.instance

local Log = {}

function Log.print_pbc_table(root, text, noPrint)
	local tmpString = Log.format_pbc_table(root, text)
	if(noPrint == true)then
		return tmpString
	end
	print(tmpString)
end

function Log.format_pbc_table(root, text)
	local cache = {[root] = "."}
	local str = ""
	if text then
		str = "<color=#00ffff>" .. text .. "</color>\n<color=#00ff00>"
	else
		str = "<color=#00ff00>\n"
	end
	local info = debug.getinfo(2, "nSl")
	if info then
		str = str .. string.format("[%s : %-4d]", info.source or "", info.currentline) .. "\n"
	end

	local function _dump(t, space, name)
		local temp = {}
		for k, v in pairs(t) do
			local key = tostring(k)
			if type(k) == "table" and k.name then
				key = k.name
			else
				key = tostring(k)
			end
			if type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				if string.sub(key, 1, 1) == "_" then
					if key == "_fields" then
						tinsert(temp, _dump(v._fields or v, space, new_key))
					end
				else
					tinsert(temp, " * " .. key .. _dump(v, space ..(next(t, k) and " | " or " ") .. srep(" ", #key), new_key))
				end
			else
				if string.sub(key, 1, 1) ~= "_" then
					if cache[v] then
						tinsert(temp, " + " .. key .. " {" .. cache[v] .. "}")
					elseif type(v) == "string" then
						tinsert(temp, " + " .. key .. " = \"" .. v .. "\"")
					else
						tinsert(temp, " + " .. key .. " = " .. tostring(v))
					end
				end
			end
		end
		return tconcat(temp, "\n" .. space)
	end

	local tmpString = str .. _dump(root._fields, "", "") .. "</color>"
	return tmpString
end

function Log.print_table(root, text, noPrint)
	local cache = {[root] = "."}
	local str
	if text then
		str = "<color=#00ffff>" .. text .. "</color>\n<color=#00ff00>\n"
	else
		str = "<color=#00ff00>\n"
	end

	local info = nil
	for level = 10, 2, -1 do
		-- 打印堆栈每一层
		info = debug.getinfo(level, "nSl")
		if info then
			str = str .. string.format("[%s : %-4d]", info.source or "", info.currentline) .. "\n"
		end
	end
	
	local function _dump(t, space, name)
		local temp = {}
		local kType, vType
		for k, v in pairs(t) do
			local key = tostring(k)
			kType = type(k)
			vType = type(v)
			if kType == "table" and k.name then
				key = k.name
			elseif kType == "string" then
				key = "\"" .. k .. "\""
			else
				key = tostring(k)
			end
			if cache[v] then
				tinsert(temp, " + " .. key .. " {" .. cache[v] .. "}")
			elseif vType == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				tinsert(temp, " * " .. key .. _dump(v, space ..(next(t, k) and " | " or " ") .. srep(" ", # key), new_key))
			elseif vType == "string" then
				tinsert(temp, " + " .. key .. " = \"" .. v .. "\"")
			else
				tinsert(temp, " + " .. key .. " = " .. tostring(v))
			end
		end
		return tconcat(temp, "\n" .. space)
	end
	local tmpString = str .. _dump(root, "", "") .. "</color>"
	if(noPrint == true)then
		return tmpString
	end
	print(tmpString)
end

function Log.print_traceback(...)
	local startLevel = 2 --0表示getinfo本身,1表示调用getinfo的函数(printCallStack),2表示调用printCallStack的函数,可以想象一个getinfo(0级)在顶的栈.
	local maxLevel = 20 --最大递归10层
	local str = "<color=#00ffff>      "
	str = str .. ...
	str = str .. "</color>\r\n"
	-- print(str)
	str = "<color=#00ff00>  " .. str
	for level = startLevel, maxLevel do
		-- 打印堆栈每一层
		local info = debug.getinfo(level, "nSl")
		if info == nil then break end
		str = str .. string.format("[%s :: line : %-4d]  %-20s ", info.source or "", info.currentline, info.name or "") .. "\r\n"
		
		-- 打印该层的参数与局部变量
		local index = 1 --1表示第一个参数或局部变量, 依次类推
		while true do
			local name, value = debug.getlocal(level, index)
			if name == nil then break end
			
			local valueType = type(value)
			local valueStr
			if valueType == 'string' then
				valueStr = value
			elseif valueType == "number" then
				valueStr = string.format("%.2f", value)
			elseif valueType == "function" then
				valueStr = value
			end
			if valueStr ~= nil then
				str = str .. string.format("\t%s = %s\n", name, value)
			end
			index = index + 1
		end
	end
	str = str .. "</color>"
	print(str)
end

function Log.print_debug(...)
	-- if(true) then
	-- 	return
	-- end
	
	local startLevel = 2 --0表示getinfo本身,1表示调用getinfo的函数(printCallStack),2表示调用printCallStack的函数,可以想象一个getinfo(0级)在顶的栈.
	local maxLevel = 20 --最大递归10层
	local str = ... .. "\r\n"
	for level = startLevel, maxLevel do
		-- 打印堆栈每一层
		local info = debug.getinfo(level, "nSl")
		if info == nil then break end
		str = str .. string.format("[%s :: line : %-4d]  %-20s ", info.source or "", info.currentline, info.name or "") .. "\r\n"
	end
	print(str)
end

function Log.report_exception(name, message, stackTrace)
	if ModuleCache.GameManager.isEditor then
		print(name .. message .. stackTrace)
	else
		GameSDKInterface:ReportException(name, message, stackTrace)
	end
end

function Log.begin_id_counting(id)
	Log.socket = Log.socket or require "socket"
	Log.id = Log.socket.gettime()
end

function Log.end_id_counting(id, ...)
	print(... or "", "total elapsed time(ms)：" .. (Log.socket.gettime()- Log.id) * 1000)
end

function Log.begin_counting(step)
	Log.socket = Log.socket or require "socket"
	Log._statTime = Log.socket.gettime()
end

function Log.end_counting(...)
	print(... or "", "total elapsed time(ms)：" .. (Log.socket.gettime() - Log._statTime) * 1000)
end


Log.print = print
print_table = Log.print_table
print_pbc_table = Log.print_pbc_table
print_traceback = Log.print_traceback
print_debug = Log.print_debug

log_print = print
log_table = print_table
log_debug = print_debug
log_traceback = print_traceback
log_pbc_table = print_pbc_table



return Log

