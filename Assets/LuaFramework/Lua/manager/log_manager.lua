
local ModuleCache = ModuleCache

local logFileDirPath = UnityEngine.Application.persistentDataPath .. "/log/"

local LogManager = {}
local last_timestamp
local log_index = 1
local dateFormat = "%Y_%m_%d"
local timestampFormat1 = '%Y_%m_%d_%H_%M_%S'
local timestampFormat = "%Y/%m/%d %H:%M:%S"
local callback_table = {}

local is_uploaded_file = false

LogManager.get_format_timestamp = function(forFileName, onlyDay, timestamp)
	timestamp = timestamp or os.time()
	if(forFileName)then
		return os.date(timestampFormat1, timestamp)
	end
	if(onlyDay)then
		return os.date(dateFormat, timestamp)
	end
	if(last_timestamp and last_timestamp == timestamp)then
		log_index = log_index + 1
	else
		log_index = 1
	end
	last_timestamp = timestamp
	local str = os.date(timestampFormat, timestamp) .. '-' .. log_index
	return str
end

LogManager.format_log = function(logString, stackTrace)
	local str
	local timestamp_str = string.format('【%s】', LogManager.get_format_timestamp())
	if(stackTrace)then
		str = string.format('%s %s\n%s', timestamp_str, logString, stackTrace)
	else
		str = string.format('%s %s', timestamp_str, logString)
	end
	return str
end

LogManager.custom_Log = function(logString, stackTrace)
	if(logString)then
		local str = string.format('【Log】%s\n', LogManager.format_log(logString, stackTrace))
		LogManager.append2LogFile(str)
	end
end

LogManager.logHandle_Log = function(logString, stackTrace)
	--LogManager.custom_Log(logString, stackTrace)
end

LogManager.logHandle_Error = function(logString, stackTrace)
	if(logString)then
		local str = string.format('【Error】%s\n', LogManager.format_log(logString, stackTrace))
		LogManager.append2LogFile(str)
	end
end

LogManager.logHandle_Warning = function(logString, stackTrace)
	--if(logString)then
	--	local str = string.format('【Warning】%s\n', LogManager.format_log(logString, stackTrace))
	--	LogManager.append2LogFile(str)
	--end
end

LogManager.logHandle_Assert = function(logString, stackTrace)
	if(logString)then
		local str = string.format('【Assert】%s\n', LogManager.format_log(logString, stackTrace))
		LogManager.append2LogFile(str)
	end
end

LogManager.logHandle_Exception = function(logString, stackTrace)
	if(logString)then
		local str = string.format('【Exception】%s\n', LogManager.format_log(logString, stackTrace))
		LogManager.append2LogFile(str)
	end
end

local logHandle
logHandle = function(logType, logString, stackTrace)
	logType = logType or ''
	local handle = LogManager['logHandle_' .. logType]
	if(handle)then
		handle(logString, stackTrace)
	end
end

LogManager.logHandle = logHandle

LogManager.register = function()
	callback_table = {}
	ModuleCache.CustomerUtil.RegisterLogCallback()
	ModuleCache.CustomerUtil.logCallback = LogManager.logHandle
	ModuleCache.GameConfigProject.asyncFileOperationCallback = function(operationData)
		local guid = operationData.guid
		local callback = callback_table[guid]
		if(callback)then
			callback_table[guid] = nil
			callback(operationData)
		end
	end
end

LogManager.un_register = function()
	ModuleCache.CustomerUtil.logCallback = nil
end

LogManager.append2LogFile = function(appendStr)
	local dataTimeString = LogManager.get_format_timestamp(nil, true)
	local dir = LogManager.get_dir_path()
	local filePath = string.format('%s%s', dir, LogManager.get_format_timestamp(true))
	local matchFiles = LogManager.match_file_name(logFileDirPath, {dir, dataTimeString})
	if(#matchFiles > 0)then
		filePath = matchFiles[1]
	end
	LogManager.append2File(filePath, appendStr)
end

LogManager.append2File = function(filePath, appendStr)
	ModuleCache.AsyncFileUtil.AddFileOperationToQueue(filePath, appendStr, 'append')
	--ModuleCache.FileUtility.SaveFile(filePath, appendStr, true)
end

LogManager.get_dir_path = function(uid)
	uid = uid or LogManager.uid or 0
	return string.format('%s%s/%s/', logFileDirPath, ModuleCache.AppData.Game_Name or "main", uid..'')
end

LogManager.match_file_name = function(dirPath, filters)
	local result = {}
	if(not ModuleCache.FileUtility.DirectoryExists(dirPath))then
		return result
	end
	local files = ModuleCache.FileUtility.GetDirectoryFiles(dirPath, nil)
	if(files.Count > 0)then
		local len = files.Count - 1
		for i = 0, len do
			local file = files[i]
			local isMatch = LogManager.is_match(file, filters)
			if(isMatch)then
				table.insert(result, file)
			end
		end
	end
	return result
end

LogManager.is_match = function(filePath, filters)
	local file = filePath
	file = string.gsub(file, '\\', '/')
	file = string.gsub(file, '-', '_')
	local isMatch = true
	for j, v in ipairs(filters) do
		v = string.gsub(v, '-', '_')
		local match = string.find(file, v)
		--print(match, file, v)
		if(match and match >=1)then
			isMatch = isMatch and true
		else
			isMatch = false
		end
	end
	return isMatch
end

LogManager.upload_files = function()
	if(is_uploaded_file)then
		return
	end
	is_uploaded_file = true
	local dir = LogManager.get_dir_path(0)
	local matchFiles = LogManager.match_file_name(logFileDirPath, {dir})
	--print_table(matchFiles)
	for i = 1, #matchFiles do
		LogManager.upload(matchFiles[i])
	end
	if(LogManager.uid and LogManager.uid ~= 0)then
		dir = LogManager.get_dir_path()
		matchFiles = LogManager.match_file_name(logFileDirPath, {dir})
		--print_table(matchFiles)
		for i = 1, #matchFiles do
			LogManager.upload(matchFiles[i])
		end
	end
end

LogManager.start_fileOperation = function(filePath, content, method, onFinish, insert)
	local guid = Util.guid()
	callback_table[guid] = onFinish
	ModuleCache.AsyncFileUtil.AddFileOperationToQueue(filePath, content, method, insert or false, guid)
end

LogManager.upload = function(filePath)
	print_table({}, '1111111111111111111111111111111111111111111')
	local relativePath = string.gsub(filePath, logFileDirPath, '')
	relativePath = string.gsub(relativePath, '\\', '/')
	if(not relativePath)then
		return
	end
	LogManager.start_fileOperation(filePath, nil, 'readAllBytes', function(operationData)
		local bytes = operationData.content
		local key = string.format('huanle/%s-%s-%s.log',relativePath, LogManager.uid or '0', math.random(0,999999) .. '')
		ModuleCache.OssManager.upload_file(key, nil, bytes, function(key, tmpfilePath, bytes, url)
			LogManager.tell_api_server(url, filePath)
		end)
	end)
end

LogManager.tell_api_server = function(url, filePath)
	local requestData = {
		baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "dataProcess/saveLog?",
		params = {
			uid = LogManager.uid,
			gameId = ModuleCache.AppData.Game_Name,
			url = url,
		},
	}

	ModuleCache.GameUtil.http_get(requestData, function(wwwOperation)
		local www = wwwOperation.www;
		local retData = ModuleCache.Json.decode(www.text)
		if retData.ret and retData.ret == 0 then    --OK
			ModuleCache.AsyncFileUtil.AddFileOperationToQueue(filePath, nil, 'delete', true)
		else

		end
	end, function(error)
		print(error.error)
		LogManager.tell_api_server(url)
	end)
end

LogManager.clear_expire_logs = function()
	if(true)then
		return
	end
	if(not ModuleCache.FileUtility.DirectoryExists(logFileDirPath))then
		return
	end
	local files = ModuleCache.FileUtility.GetDirectoryFiles(logFileDirPath, nil)
	if(files.Count == 0)then
		return
	end
	local stay = {}
	local now = os.time()
	for i = 7, 0, -1 do
		local timestamp = now - i * 3600 * 24
		local dataTimeString = LogManager.get_format_timestamp(nil, true, timestamp)
		table.insert(stay, dataTimeString)
	end
	local needClearFiles = {}
	local len = files.Count - 1
	for i = 0, len do
		local isMatch = false
		for j = 1, #stay do
			local match = string.find(files[i], stay[j])
			if(match and match >=1)then
				isMatch = true
			end
		end
		if(not isMatch)then
			table.insert(needClearFiles, files[i])
		end
	end

	for i = 1, #needClearFiles do
		if(ModuleCache.FileUtility.Exists(needClearFiles[i]))then
			ModuleCache.FileUtility.Delete(needClearFiles[i])
		end
	end
end

LogManager.clear_expire_logs()

return LogManager

