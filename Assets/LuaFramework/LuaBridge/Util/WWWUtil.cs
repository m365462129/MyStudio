using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Networking;

public static class WWWUtil {

    //不带超时机制的WWW请求
    public static WWWOperation Get(string url) {
        var wwwData = new WWWOperation(url, 0);
        MonoBehaviourDispatcher.instance.AddCoroutine(wwwData);
        return wwwData;
    }

    //带有超时机制的请求
    public static WWWOperation GetSafe(string url, float overTime) {
        var wwwData = new WWWOperation(url, overTime);
        MonoBehaviourDispatcher.instance.AddCoroutine(wwwData);
        return wwwData;
    }

    public static WWWOperation Post(string url, WWWForm content, UnityAction<float> progress = null) {
        var wwwData = new WWWOperation(url, content, 0);
        MonoBehaviourDispatcher.instance.AddCoroutine(wwwData);
        return wwwData;
    }

    public static WWWOperation Post_Data(string url, byte[] postData, Dictionary<string, string> headers) {
        var wwwData = new WWWOperation(url, postData, headers, 0);
        MonoBehaviourDispatcher.instance.AddCoroutine(wwwData);
        return wwwData;
    }

    /// <summary>
    /// 并发请求
    /// </summary>
    /// <param name="urls">请求的地址</param>
    /// <param name="timeOut">超时时间</param>
    /// <param name="onComplete"></param>
    /// <param name="onError"></param>
    public static void GetConcurrence(string[] urls, float timeOut, Action<WWWOperation> onComplete, Action<WWWOperation> onError)
    {
        var wwwConcurrence = new WWWConcurrence();
        wwwConcurrence.Get(urls, timeOut, onComplete, onError);
    }
}



public class WWWOperation : IEnumerator {

    private float mRequestTime;
    private float mOverTime;

    private string mCustomError;

    private Action<WWWOperation> mOnNext;
    private Action<WWWOperation> mOnError;
    private Action<WWWOperation> mOnProgress;

    private bool m_isBreak;

    public WWW www;

     [NoToLua]
    public WWWOperation(float timeOut)
    {
        mRequestTime = Time.realtimeSinceStartup;
        mOverTime = timeOut;
    }

    [NoToLua]
    public WWWOperation(string url, float overTime) {
        www = new WWW(url);
        mRequestTime = Time.realtimeSinceStartup;
        mOverTime = overTime;
        // #if DEBUG
        //     Debugger.Log(string.Format("<color=gray>http get \n {0}</color>", www.url));
        // #endif
    }



    [NoToLua]
    public WWWOperation(string url, WWWForm wwwForm, float overTime) {
        www = new WWW(url, wwwForm);
        mRequestTime = Time.realtimeSinceStartup;
        mOverTime = overTime;
        mOverTime = overTime;
    }

        [NoToLua]
        public WWWOperation(string url, byte[] postData, Dictionary<string, string> headers, float overTime) {
            www = new WWW(url, postData, headers);
            mRequestTime = Time.realtimeSinceStartup;
            mOverTime = overTime;
            mOverTime = overTime;
        }

    public string error {
        get {
            if (!string.IsNullOrEmpty(mCustomError)) {
                return mCustomError;
            }
            return www.error;
        }
    }

    public string text {
        get {
            return www.text;
        }
    }

    public Texture texture {
        get {
            return www.texture;
        }
    }

    public bool isBreak{
        get{
            return m_isBreak;
        }
        set{m_isBreak = value;}
    }

    [NoToLua]
    public object Current {
        get { return null; }
    }

    [NoToLua]
    public bool MoveNext() {
        if(m_isBreak){
            if(www != null)
            return false;
        }
        if (mOnProgress != null) {
            mOnProgress(this);
        }
        if (www.isDone) {
            try {
                if (!string.IsNullOrEmpty(www.error)) {
                    #if DEBUG
                        Debugger.Log(string.Format("<color=red>{0} | {1}</color>", www.url, error));
                    #endif
                    if (mOnError != null) {
                        mOnError(this);
                    }
                } else {
                    //很怪，为什么在Mac上断开了Wifi，www.error为空，并且www.text也为空
                    if (www.bytes != null && www.bytes.Length == 0) {
                        #if DEBUG
                            Debugger.Log(string.Format("<color=red>{0} | {1}</color>", www.url, "Empty Data"));
                        #endif
                        if (mOnError != null) {
                            mCustomError = "Empty Data";
                            mOnError(this);
                            www.Dispose();
                            return false;
                        }
                    }

                    if (mOnNext != null) {
                        #if DEBUG
                            if (GameConfigProject.instance.developmentMode) {
                                if (www.url.EndsWith(".png") || www.url.EndsWith(".jpg")) {
                                    Debugger.Log(string.Format("{0} \n\n {1}", www.url, "图片下载"));
                                } else {
                                    Debugger.Log(string.Format("{0} \n\n {1}", www.url, www.text));
                                }
                            }
                        #endif
                        mOnNext(this);
                    }
                }
            } catch (Exception ex) {
                    // if (mOnError != null) {
                    //     mOnError(ex.toString());
                    // }
                    // #if DEBUG
                    //     Debugger.Log(string.Format("<color=yellow>{0} \n {1}</color>", www.url, www.text));
                    // #endif
            }
            www.Dispose();
            return false;
        }
        
        if (mOverTime > 0.1f && Time.realtimeSinceStartup - mRequestTime >= mOverTime) {
            mCustomError = "Network Timeout";
            if (mOnError != null) {
                mOnError(this);
            }
            #if DEBUG
                Debug.LogError(mCustomError + "! url = " + www.url);
            #endif
            www.Dispose();
            return false;
        }    
        return true;
    }

    [NoToLua]
    public void Reset() {

    }

    public WWWOperation Subscribe(Action<WWWOperation> onComplete, Action<WWWOperation> onError = null) {
        mOnNext = onComplete;
        mOnError = onError;
        return this;
    }

    public WWWOperation SubscribeWithProgress(Action<WWWOperation> onComplete, Action<WWWOperation> onError = null, Action<WWWOperation> onProgress = null) {
        mOnNext = onComplete;
        mOnError = onError;
        mOnProgress = onProgress;
        return this;
    }
}

//并发请求
public class WWWConcurrence
{
    private List<WWWOperation> mWWWOperationList = new List<WWWOperation>();

    private Action<WWWOperation> mOnComplete;

    private Action<WWWOperation> mOnError;

    //是否已经处理
    private bool mFinish;


    public void Get(string[] baseUrls, float timeOut, Action<WWWOperation> onComplete, Action<WWWOperation> onError)
    {
        mFinish = false;
        mOnComplete = onComplete;
        mOnError = onError;
        for (int i = 0; i < baseUrls.Length; ++i)
        {
            var wwwData = new WWWOperation(timeOut);

            mWWWOperationList.Add(wwwData);
            wwwData.www = new WWW(baseUrls[i]);
            #if DEBUG
                Debug.Log("WWWConcurrenceEx Url = " + wwwData.www.url);
            #endif
            MonoBehaviourDispatcher.instance.AddCoroutine(wwwData);
            wwwData.Subscribe(OnComplete, OnError);
        }
    }

    private void OnComplete(WWWOperation data)
    {
        if (mFinish || mOnComplete == null) return;
        mFinish = true;
        mWWWOperationList.Clear();
        mOnComplete(data);
    }

    private void OnError(WWWOperation data)
    {
        mWWWOperationList.Remove(data);
        if (mWWWOperationList.Count != 0) return;
        if (mFinish || mOnError == null) return;
        mFinish = true;
        mOnError(data);
    }
}
