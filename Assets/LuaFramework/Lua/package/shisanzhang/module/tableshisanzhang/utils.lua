local skynet = require "skynet"
local M = {}
local function serialize(obj)
	local lua = ""
	local t = type(obj)
	if t == "number" then
		lua = lua .. obj
	elseif t == "boolean" then
		lua = lua .. tostring(obj)
	elseif t == "string" then
		lua = lua .. string.format("%q", obj)
	elseif t == "table" then
		lua = lua .. "{\n"
		for k, v in pairs(obj) do
			lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
		end
		local metatable = getmetatable(obj)
		if metatable ~= nil and type(metatable.__index) == "table" then
			for k, v in pairs(metatable.__index) do
				lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
			end
		end
		lua = lua .. "}"
	elseif t == "nil" then
		return "nil"
	elseif t == "userdata" then
		return "userdata"
	elseif t == "function" then
		return "function"
	else
		error("can not serialize a " .. t .. " type.")
	end
	return lua
end
function M.print(...)
	local t = {...}
	local ret = {}
	for _, v in pairs(t) do
		table.insert(ret, serialize(v))
	end
	print(table.concat(ret, ", "))
end
function M.split(str, delimiter)
	if str == nil or str == '' or delimiter == nil then
		return nil
	end
	local result = {}
	for match in(str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end
function M.hex(str)
	local len = #str
	local ret = ""
	for i = 1, len do
		local c = tonumber(str:byte(i))
		local cstr = string.format("%02X ", c)
		ret = ret .. cstr
	end
	print(ret)
end
function M.length(list)
	
	if list == nil then
		return 0
	end
	
	count = 0;
	for k, v in pairs(list) do
		count = count + 1;
	end
	return count
end
function M.cancelable_timeout(ti, func)
	local function cb()
		if func then
			func()
		end
	end
	local function cancel()
		cb()
		func = nil
	end
	local function wait()
		cb()
		func = nil
	end
	skynet.timeout(ti, cb)
	return cancel
end

function M.deepcopy(obj)	
	local InTable = {};
	local function Func(obj)
		if type(obj) ~= "table" then   --判断表中是否有表  
			return obj;
		end
		local NewTable = {};  --定义一个新表  
		InTable[obj] = NewTable;  --若表中有表，则先把表给InTable，再用NewTable去接收内嵌的表  
		for k, v in pairs(obj) do  --把旧表的key和Value赋给新表  
			NewTable[Func(k)] = Func(v);
		end
		return setmetatable(NewTable, getmetatable(obj))--赋值元表  
	end
	return Func(obj) --若表中有表，则把内嵌的表也复制了  
end

return M
