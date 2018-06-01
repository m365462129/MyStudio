

local GVoiceManager = {}
local manager = LuaBridge.GVoiceManager.instance
local GameSDKInterface = ModuleCache.GameSDKInterface

-- 初始化语音
function GVoiceManager.init(gameId, gameKey, openId, msTimeout)
    if(GVoiceManager.inited)then
        if GVoiceManager._onInitComplete then
            GVoiceManager._onInitComplete('')
        end
        return
    end
    if(GVoiceManager.started_init)then
        return
    end
    manager:Init(gameId, gameKey, openId, msTimeout)
    GVoiceManager.started_init = true

    manager:SetEventListener(function(fileid)
        if GVoiceManager._onUploadReccordFileComplete then
            GVoiceManager._onUploadReccordFileComplete(fileid)
        end
    end, function(filePath, fileid)
        if GVoiceManager._onDownloadRecordFileComplete then
            GVoiceManager._onDownloadRecordFileComplete(filePath, fileid)
        end
    end, function(filePath )
        if GVoiceManager._onPlayRecordFilComplete then
            GVoiceManager._onPlayRecordFilComplete(filePath)
        end

        if GVoiceManager._playFinishCallback then
            GVoiceManager._playFinishCallback(filePath)
            GVoiceManager._playFinishCallback = nil
        end
    end
    , function(err)
        if(err == '')then
            GVoiceManager.inited = true
        else
            GVoiceManager.inited = false
            GVoiceManager.started_init = false
        end
        if GVoiceManager._onInitComplete then
            GVoiceManager._onInitComplete(err)
        end
    end
    )
end

function GVoiceManager.set_event_listener(onUploadReccordFileComplete, onDownloadRecordFileComplete, onPlayRecordFilComplete, onInitComplete)
    GVoiceManager._onUploadReccordFileComplete = onUploadReccordFileComplete
    GVoiceManager._onDownloadRecordFileComplete = onDownloadRecordFileComplete
    GVoiceManager._onPlayRecordFilComplete = onPlayRecordFilComplete
    GVoiceManager._onInitComplete = onInitComplete
end


function GVoiceManager.clear_event_listener()
    GVoiceManager._onUploadReccordFileComplete = nil
    GVoiceManager._onDownloadRecordFileComplete = nil
    GVoiceManager._onPlayRecordFilComplete = nil
end

-- 开始录音
function GVoiceManager.start_recording(recordPath)
    manager:StartRecording(recordPath)
end

-- 停止录音
function GVoiceManager.stop_recording()
    manager:StopRecording()
end

-- 上传录音文件
function GVoiceManager.upload_recorded_file(recordPath, num)
    manager:UploadRecordedFile(recordPath, num)
end

-- 下载录音文件
function GVoiceManager.download_recorded_file(field, downLoadPath, num)
    manager:DownloadRecordedFile(field, downLoadPath, num)
end

-- 播放录音文件
function GVoiceManager.play_recorded_file(downLoadPath, playFinishCallback)
    if playFinishCallback then
        GVoiceManager._playFinishCallback = playFinishCallback
    end

    manager:PlayRecordedFile(downLoadPath)
end

--停止播放录音文件
function GVoiceManager.stop_play_file()
    manager:StopPlayFile()
end


return GVoiceManager