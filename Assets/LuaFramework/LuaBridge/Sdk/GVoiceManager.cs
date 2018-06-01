using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using gcloud_voice;
using System;
using LuaInterface;

[Serializable]
public class GVoiceManagerAction {
    public string eventName;
    public string data;
    public string code;
}

public class GVoiceManager : MonoBehaviour
{
    IGCloudVoice mVoiceengine;

    Action<string> onUploadReccordFileComplete;
    Action<string, string> onDownloadRecordFileComplete;
    Action<string> onPlayRecordFilComplete;
    Action<string> onInitComplete;


    public LuaFunction onAction;

    void OnApplyMessageKeyComplete(IGCloudVoice.GCloudVoiceCompleteCode code)
    {
        if (onAction != null) {
            onAction.Call("onAction", JsonUtility.ToJson(new GVoiceManagerAction() {
                eventName = "OnApplyMessageKeyComplete",
                code = code.ToString()
            }));
        }

        if (code == IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC)
        {
            Debug.Log("OnApplyMessageKeyComplete succ11");
            if (onInitComplete != null) onInitComplete(string.Empty);
        }
        else
        {
            Debug.Log("OnApplyMessageKeyComplete error");
            if (onInitComplete != null) onInitComplete(code + "");
        }
    }

    void OnUploadReccordFileComplete(IGCloudVoice.GCloudVoiceCompleteCode code, string filepath, string fileid)
    {
        if (onAction != null) {
            onAction.Call("onAction", JsonUtility.ToJson(new GVoiceManagerAction() {
                eventName = "OnUploadReccordFileComplete",
                code = code.ToString(),
                data = fileid
            }));
        }

        Debug.Log("OnUploadReccordFileComplete c# callback" + code + " filepath " + filepath + " fileid " + fileid);
        if (code == IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE)
        {
            Debug.Log("OnUploadReccordFileComplete succ11");
            //int ret = m_voiceengine.DownloadRecordedFile(m_fileid, m_downloadpath, 60000);
            //广播给其他玩家
            if (onUploadReccordFileComplete != null) onUploadReccordFileComplete(fileid);
        }
        else
        {
            //如果上传失败了需要
            Debug.Log("OnUploadReccordFileComplete error");
        }
    }

    void OnDownloadRecordFileComplete(IGCloudVoice.GCloudVoiceCompleteCode code, string filepath, string fileid)
    {
        if (onAction != null) {
            onAction.Call("onAction", JsonUtility.ToJson(new GVoiceManagerAction() {
                eventName = "OnDownloadRecordFileComplete",
                code = code.ToString(),
                data = filepath + "|" + fileid
            }));
        }

        Debug.Log("OnDownloadRecordFileComplete c# callback");
        if (code == IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE)
        {
            Debug.Log("OnDownloadRecordFileComplete succ, filepath:" + filepath + " fileid:" + fileid);
            if (onDownloadRecordFileComplete != null) onDownloadRecordFileComplete(filepath, fileid);
            //暂停背景音乐
        }
        else
        {
            Debug.Log("OnDownloadRecordFileComplete error");
        }
    }

    void OnPlayRecordFilComplete(IGCloudVoice.GCloudVoiceCompleteCode code, string filepath)
    {
        if (onAction != null) {
            onAction.Call("onAction", JsonUtility.ToJson(new GVoiceManagerAction() {
                eventName = "OnPlayRecordFilComplete",
                code = code.ToString(),
                data = filepath
            }));
        }

        Debug.Log("OnPlayRecordFilComplete c# callback");
        if (code == IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_PLAYFILE_DONE)
        {
            if (onPlayRecordFilComplete != null) onPlayRecordFilComplete(filepath);
            Debug.Log("OnPlayRecordFilComplete succ, filepath:" + filepath);
        }
        else
        {
            Debug.Log("OnPlayRecordFilComplete error");
        }
    }

    void Awake()
    {
        _instance = this;
    }

    void Start()
    {
        if (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.Android || Application.platform == RuntimePlatform.IPhonePlayer)
        {
            Debug.Log("GVoiceManager 事件初始化");
            if (mVoiceengine == null)
            {
                mVoiceengine = GCloudVoice.GetEngine();
            }
            mVoiceengine.OnApplyMessageKeyComplete += OnApplyMessageKeyComplete;
            mVoiceengine.OnUploadReccordFileComplete += OnUploadReccordFileComplete;
            mVoiceengine.OnDownloadRecordFileComplete += OnDownloadRecordFileComplete;
            mVoiceengine.OnPlayRecordFilComplete += OnPlayRecordFilComplete;
        }

    }

    /// <summary>
    /// This function is called when the MonoBehaviour will be destroyed.
    /// </summary>
    void OnDestroy()
    {
        if (mVoiceengine != null)
        {
            Debug.Log("GVoiceManager 重制事件");
            mVoiceengine.OnApplyMessageKeyComplete -= OnApplyMessageKeyComplete; 
            mVoiceengine.OnUploadReccordFileComplete -= OnUploadReccordFileComplete;
            mVoiceengine.OnDownloadRecordFileComplete -= OnDownloadRecordFileComplete;
            mVoiceengine.OnPlayRecordFilComplete -= OnPlayRecordFilComplete;
        }
    }

    //初始化语音
    public void Init(string gameId, string gameKey, string openId, int msTimeout)
    {
        if (mVoiceengine == null) {
            mVoiceengine = GCloudVoice.GetEngine();
        }
        mVoiceengine.SetAppInfo(gameId, gameKey, openId);
        mVoiceengine.Init();
        mVoiceengine.ApplyMessageKey(msTimeout);
        mVoiceengine.SetMode(GCloudVoiceMode.Messages);
        int ret1 = mVoiceengine.SetMaxMessageLength(60000);
        Debug.Log("SetMaxMessageLength ret==" + ret1);
    }

    //设置监听函数
    public void SetEventListener(Action<string> onUploadReccordFileComplete, Action<string, string> onDownloadRecordFileComplete, Action<string> onPlayRecordFilComplete, Action<string> onInitComplete)
    {
        this.SetEventListener(onUploadReccordFileComplete, onDownloadRecordFileComplete, onPlayRecordFilComplete);
        this.onInitComplete = onInitComplete;
    }

    //设置监听函数
    public void SetEventListener(Action<string> onUploadReccordFileComplete, Action<string, string> onDownloadRecordFileComplete, Action<string> onPlayRecordFilComplete)
    {
        this.onUploadReccordFileComplete = onUploadReccordFileComplete;
        this.onDownloadRecordFileComplete = onDownloadRecordFileComplete;
        this.onPlayRecordFilComplete = onPlayRecordFilComplete;
    }

    //清空监听函数
    public void ClearEventListener()
    {
        this.onUploadReccordFileComplete = null;
        this.onDownloadRecordFileComplete = null;
        this.onPlayRecordFilComplete = null;
    }


    public void StartRecording(string recordPath)
    {
        Debug.Log("startrecord btn click, recordpath=" + recordPath);
        mVoiceengine.StartRecording(recordPath);

    }
    public void StopRecording()
    {
        Debug.Log("stoprecord btn click");
        mVoiceengine.StopRecording();
    }
    public void UploadRecordedFile(string recordPath, int num)
    {
        int ret1 = mVoiceengine.UploadRecordedFile(recordPath, num);
        Debug.Log("Click_btnUploadFile file with ret==" + ret1);
    }

    public void DownloadRecordedFile(string fileid, string downLoadPath, int num)
    {
        int ret = mVoiceengine.DownloadRecordedFile(fileid, downLoadPath, num);
        Debug.Log("\r\n download file with ret==" + ret + " fileid=" + fileid + " downpath" + downLoadPath);
    }
    public void PlayRecordedFile(string downloadPath)
    {
        int err;
        err = mVoiceengine.PlayRecordedFile(downloadPath);
        Debug.Log("playrecord file with ret=" + err);
    }
    public void StopPlayFile()
    {
        mVoiceengine.StopPlayFile();
    }

    // Update is called once per frame
    void Update()
    {
        if (mVoiceengine != null)
        {
            mVoiceengine.Poll();
        }
    }


    void OnApplicationPause(bool pauseStatus)
    {
        // Debug.Log("Voice OnApplicationPause: " + pauseStatus);
        if (pauseStatus)
        {
            if (mVoiceengine == null)
            {
                return;
            }
            mVoiceengine.Pause();
        }
        else
        {
            if (mVoiceengine == null)
            {
                return;
            }
            mVoiceengine.Resume();
        }
    }

    #region static   
    private static GVoiceManager _instance;

    public static GVoiceManager instance
    {
        get
        {
            if (_instance == null)
            {
                var gam = new GameObject("GVoiceManager");
                _instance = gam.AddComponent<GVoiceManager>();
                DontDestroyOnLoad(_instance);
            }
            return _instance;
        }
    }
    #endregion
}
