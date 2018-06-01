//using UnityEngine;
//using System.Collections;
//
//public class ApplicationLogManager
//{
//    static Application.LogCallback mLogCallBack;
//    private static bool _logMessageReceivedInit = false;
//
//    static void HandleLog(string theLogString, string theStackTrace, LogType theLogType) {
//        if (mLogCallBack != null) {
//            mLogCallBack(theLogString, theStackTrace, theLogType);
//        }
//    }
//
//    static public void RegisterLogCallback(Application.LogCallback logCallBack, bool append = true) {
//        if (append) {
//            if (OnRegisterLogCallback(logCallBack)) {
//                mLogCallBack += logCallBack;
//            }
//
//        } else {
//            mLogCallBack = logCallBack;
//        }
//        if (!_logMessageReceivedInit) {
//            Application.logMessageReceived += HandleLog;
//        }
//        _logMessageReceivedInit = true;
//
//    }
//
//    static bool OnRegisterLogCallback(Application.LogCallback logCallBack) {
//        if (mLogCallBack == null) {
//            return true;
//        }
//        System.Delegate[] arry = mLogCallBack.GetInvocationList();
//        for (int i = 0, count = arry.Length; i < count; ++i) {
//            if (arry[i] == logCallBack) {
//                Debug.LogError(string.Format("已经有完全相同监听者，监听者【{0}】", logCallBack.ToString()));
//                return false;
//            }
//        }
//        return true;
//    }
//
//    static bool OnUnRegisterLogCallback(Application.LogCallback logCallBack) {
//        if (mLogCallBack == null) {
//            Debug.LogError(string.Format("不包含此监听者，监听者【{0}】", logCallBack.ToString()));
//            return false;
//        }
//        System.Delegate[] arry = mLogCallBack.GetInvocationList();
//        for (int i = 0, count = arry.Length; i < count; ++i) {
//            if (arry[i] == logCallBack) {
//                return true;
//            }
//        }
//        Debug.LogError(string.Format("不包含此监听者，监听者【{0}】", logCallBack.ToString()));
//        return false;
//    }
//
//    static public void UnRegisterLogCallback(Application.LogCallback logCallBack) {
//        if (logCallBack == null) {
//            mLogCallBack = null;
//        } else {
//            if (OnUnRegisterLogCallback(logCallBack)) {
//                mLogCallBack -= logCallBack;
//            }
//        }
//        //Application.logMessageReceived -= HandleLog;
//        //_logMessageReceivedInit = false;
//    }
//
//
//
//}
