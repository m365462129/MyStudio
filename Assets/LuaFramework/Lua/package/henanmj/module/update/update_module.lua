---------------------------------------------------------------------------------------------------
-- ===============================================================================================--
-- data:2016.11.25
-- author:dred
-- desc: viewmodel
-- ===============================================================================================--
---------------------------------------------------------------------------------------------------
-- 初始化
local class = require("lib.middleclass")
local Module = require("core.mvvm.module_base")
---@class UpdateModule
---@field view UpdateView
local UpdateModule = class("Hall.UpdateModule", Module)

-- 常用模块引用
local ModuleCache = ModuleCache
local GameManager = ModuleCache.GameManager
local UnityEngine = UnityEngine


function UpdateModule:initialize(...)
	-- 开始初始化                view        model           模块数据
	Module.initialize(self, "update_view", nil, ...)
end

-- 模块初始化完成回调，包含了view，model初始化完成
function UpdateModule:on_module_inited()
	-- 更新错误次数
	self.update_error_count = 0
	self.update_apk_error_count = 0
	self.view.sliderProgress.value = 0
	self.view.textVersion.text = ModuleCache.GameManager.appVersion .. "|" .. ModuleCache.GameManager.appAssetVersion
end

function UpdateModule:on_show(intentData)
    self.update_error_count = 0
	self.updateIntentData = intentData
	print_table(intentData, "updateIntentData")
	if intentData and intentData.assetVersion then
		self._assetVersionData = intentData.assetVersion
		self._updateSuccessCallback = intentData.updateSuccessCallback
		self._updateFinishCallback = intentData.updateFinishCallback
		self._updateFailureCallback = intentData.updateFailureCallback
		self:_update_server_asset(self._assetVersionData)
	elseif(intentData and intentData.appData)then		--更新apk
		self._updateSuccessCallback = intentData.updateSuccessCallback
		self._updateFailureCallback = intentData.updateFailureCallback
		if ModuleCache.FileUtility.Exists(intentData.appData.saveFilePath) then
			ModuleCache.FileUtility.Delete(intentData.appData.saveFilePath)
		end
		self:_update_apk(intentData.appData)
	end
	
end

function UpdateModule:on_click(obj, arg)
	if "ButtonUpdateApkRetry" == obj.name then
		UnityEngine.Application.OpenURL(self._intentData.appData.url)
	end
end

function UpdateModule:_update_server_asset(assetVersionData)
    self.updateView.textInfo.text = "资源更新"
    local assetsDownloadFilePath = ModuleCache.AppData.ASSETS_DOWNLOAD_ROOT .. assetVersionData.fileName

	local downFiles = function()
		ModuleCache.FileUtility.DownloadFile(assetVersionData.filePath, assetsDownloadFilePath, function(result)
			print(result, assetVersionData.filePath)
			if result == "download sucess" then
            	-- self.view.textSliderInfo.text = ""
				ModuleCache.FileUtility.Decompress7ZipAsync(assetsDownloadFilePath, ModuleCache.AppData.ASSETS_DATA_ROOT, false, true, function(result)
					if result == 1 then

					else
						print("解压资源失败：" .. result)
						self.view.textInfo.text = "解压资源失败：" .. result
						ModuleCache.FileUtility.DirectoryDelete(ModuleCache.AppData.ASSETS_DATA_ROOT, true)
						ModuleCache.GameManager.reboot()
						return
					end

					if (self._updateFinishCallback) then
						self._updateFinishCallback(self.updateIntentData)
					else
						ModuleCache.GameManager.reboot()
					end
				end, function(decompressProgress)
					self.view.textInfo.text = "资源解压中(不消耗流量)..."
					-- print(decompressProgress, "decompress progress")
				end)
				if self.view and self.view.textInfo then
					self.view.textInfo.text = "资源下载完成，开始解压"
				end
			else
				print("下载失败需要重试：" .. result)
				self.update_error_count = self.update_error_count + 1
				if self.update_error_count > 3 then
					-- self:update_error_prompt("下载失败: " .. result)
                	if self._updateFailureCallback then
                    	self._updateFailureCallback(result)
                	end
				else
					self:_update_server_asset(assetVersionData)
				end
			end
		end, function(downloadProgress)
			if self.view then
				self.view.textSliderInfo.text = string.format("资源下载中:%d", downloadProgress * 100) .. "%"
				self.view.sliderProgress.value = downloadProgress
			end
			-- print(downloadProgress, "downloadProgress progress")
		end)
	end
	downFiles()
end

function UpdateModule:_update_apk(appData)
	--local fileSize = "25M"
    self.updateView.textInfo.text = "检测到新版本，需要更新"
    local url = appData.url
	local saveFilePath = appData.saveFilePath
	local install_apk
	local downFiles = function()
		print(url, saveFilePath)
		self:downLoadFile(url, saveFilePath, function(error)
			if not error then
				install_apk(saveFilePath)
			else
				print("安装包下载失败需要重试：" .. error)
				self.update_error_count = self.update_error_count + 1
				if self.update_error_count > 3 then
                	if self._updateFailureCallback then
                    	self._updateFailureCallback(error)
                	end
				else
					self:_update_apk(appData)
				end
			end
		end, function(wwwData)
			local downloadProgress = wwwData.www.progress
			if self.view then
				self.view.textSliderInfo.text = string.format("安装包下载中:%d", downloadProgress * 100) .. "%"
				self.view.sliderProgress.value = downloadProgress
			end
		end)
	end

	install_apk = function(filePath)
		self:subscibe_time_event(7, false, 0):OnComplete(function(t)
			self.view.goButtonUpdateApkRetry:SetActive(true)
		end)

		self.view.textInfo.text = "安装包下载完成，开始安装"
		self.view.sliderProgress.value = 80
		self.view.textSliderInfo.text = string.format("正在安装:%d", 80) .. "% "


		local onAppFocusCallback
		onAppFocusCallback = function ( eventHead, eventData )
			if(eventData)then
				self.update_apk_error_count = self.update_apk_error_count + 1
				if self.update_apk_error_count < 3 then
					self:_update_apk(appData)
				else
					ApplicationEvent.unsubscibe_app_focus_event(onAppFocusCallback)
				end
			end
		end
		ApplicationEvent.subscibe_app_focus_event(onAppFocusCallback)
		UnityEngine.Application.OpenURL(filePath)
	end

	if(ModuleCache.FileUtility.Exists(saveFilePath))then
		install_apk(saveFilePath)
		return
	end

	downFiles()

end

function UpdateModule:downLoadFile(url, savePath, onComplete, onProgress)
	print("start down ", url, savePath)
	ModuleCache.WWWUtil.Get(url):SubscribeWithProgress(function(wwwData)
        -- 因为之前的WWWUtil错误的时候，不会抛出错误，所以打了个补丁
        if wwwData.www.error ~= nil then
			if(onComplete)then
				onComplete(wwwData.www.error)
			end
        else
            ModuleCache.FileUtility.SaveFile(savePath, wwwData.www.bytes, false)
			if(onComplete)then
				onComplete(nil)
			end
        end
    end, function(wwwData)
		if(onComplete)then
			onComplete(wwwData.www.error)
		end
	end, onProgress)
end


return UpdateModule



