using System;
using UnityEngine;
using System.Collections;
using System.Security.Permissions;

namespace GameAsset
{
    public abstract class AsyncOperation : IEnumerator
    {
        public object Current {
            get { return null; }
        }

        public bool MoveNext() {
            return !IsDone();
        }

        public void Reset() {}

        public abstract bool IsDone();
    }


    public abstract class AssetBundleAsyncOperation : AsyncOperation {
        public abstract T GetAsset<T>(string assetname, bool findIndependAssetBundles) where T : UnityEngine.Object;
        public abstract void UnLoad(bool unloadAllLoadedObjects = false);
        public virtual LoadedAssetBundle loadedAssetBundle { get; protected set; }
    }

    public class LoadedAssetBundleAsyncOperation : AssetBundleAsyncOperation
    {
        public override LoadedAssetBundle loadedAssetBundle { get; protected set; }

        private AssetBundleCreateRequest mAssetBundleCreateRequest;

        private AssetBundleRequest mLoadAssetRequest;

        private Action<LoadedAssetBundle> mLoadedAssetBundleAction;

        private bool mAssetBundleAllLoaded;
        
        private string mNeedLoadAssetName;
        

        private bool mLoadingAssetSyn;

        private bool mLoadedAsset;
           


        public LoadedAssetBundleAsyncOperation(LoadedAssetBundle assetBundle, string needLoadAssetName, Action<LoadedAssetBundle> loadedAssetBundleAction)
        {
            mLoadedAssetBundleAction = loadedAssetBundleAction;
            loadedAssetBundle = assetBundle;
            loadedAssetBundle.isAsyncLoading = true;
            loadedAssetBundle.isLoaded = false;
            mNeedLoadAssetName = needLoadAssetName;
            mAssetBundleCreateRequest = AssetBundleManager.LoadAssetBundleFromFileAsync(assetBundle.assetBundleName);
        }


        public override T GetAsset<T>(string assetname, bool findIndependAssetBundles) {
#if UNITY_EDITOR
            if (assetname.Contains(".")) {
                Debug.LogErrorFormat("获取的资源{0}含有后缀名！请去掉。", assetname);
            } 
#endif
            if (loadedAssetBundle == null) {
                return null;
            }
            return loadedAssetBundle.GetAsset<T>(assetname, true);
        }

        public override void UnLoad(bool unloadAllLoadedObjects = false)
        {
            if (!loadedAssetBundle.IsLoadedAll()) { //待完成之后就卸载
                loadedAssetBundle.onLoaded = ()=> AssetBundleManager.instance.UnLoadLoadedAssetBundle(loadedAssetBundle, unloadAllLoadedObjects);
            } else {
                AssetBundleManager.instance.UnLoadLoadedAssetBundle(loadedAssetBundle, unloadAllLoadedObjects);
                loadedAssetBundle = null;
            }
        }

        public override bool IsDone()
        {
            
            // m_DownloadingError might come from the dependency downloading.
            if (!string.IsNullOrEmpty(loadedAssetBundle.erroMsg)) {
                Debug.LogError(loadedAssetBundle.erroMsg);
                return true;
            }

            if (!loadedAssetBundle.isLoaded && mAssetBundleCreateRequest != null) {
                loadedAssetBundle.isLoaded = mAssetBundleCreateRequest.isDone;
            }

            mAssetBundleAllLoaded = loadedAssetBundle.IsLoadedAll();

            if (mAssetBundleAllLoaded)
            {
                if (!mLoadingAssetSyn)
                {                    
                    if (loadedAssetBundle.assetBundle == null)
                    {
//                        Debug.Log();
                        loadedAssetBundle.assetBundle = mAssetBundleCreateRequest.assetBundle;
                    }
                    else
                    {
                        if (mAssetBundleCreateRequest.assetBundle != null)
                        {
                            mAssetBundleCreateRequest.assetBundle.Unload(true);
                        }
                        
                        mAssetBundleCreateRequest = null;
#if DEBUG
                        Debug.LogError("已经使用同步方法加载完成" + loadedAssetBundle.assetBundleName);
#endif
                    }
                    mAssetBundleCreateRequest = null;
                    
//                    if (!string.IsNullOrEmpty(mNeedLoadAssetName))
//                    {
//                        Debug.Log("LoadAssetAsync：" + mNeedLoadAssetName);
//                        mLoadingAssetSyn = true;
//                        loadedAssetBundle.GetAssetAsync<GameObject>(mNeedLoadAssetName, false, x =>
//                        {
//                            if (!loadedAssetBundle.assetObjects.ContainsKey(mNeedLoadAssetName))
//                            {
//                                loadedAssetBundle.assetObjects.Add(mNeedLoadAssetName, x);
//                            }
//                            mLoadingAssetSyn = false;
//                        });
//                        return false;
////                        loadedAssetBundle.assetBundle.LoadAssetAsync(mNeedLoadAssetName);
//
//                    }
                    
                }
                
//                if (mLoadAssetRequest != null)
//                {
//                    if (mLoadAssetRequest.isDone)
//                    {
//                        Debug.Log("LoadAssetAsync isDone");
//                        UnityEngine.Object loadAsset;
//                        
//                        if (!loadedAssetBundle.assetObjects.TryGetValue(mNeedLoadAssetName, out loadAsset))
//                        {
//                            loadedAssetBundle.assetObjects.Add(mNeedLoadAssetName, mLoadAssetRequest.asset);
//                        }
//                      
//                    }
//                    else
//                    {
//                        return false;
//                    }
//                }
#if DEBUG
                Debug.LogFormat("异步加载完成 {0} - {1} | {2}", Time.frameCount, Time.realtimeSinceStartup, loadedAssetBundle.assetBundleName);
#endif
                if (mLoadedAssetBundleAction != null)
                {                    
                    try
                    {
                        mLoadedAssetBundleAction(loadedAssetBundle);
                    }
                    catch (Exception e)
                    {
                        
                    }
                }
            }
            return mAssetBundleAllLoaded;
        }
    }




#if UNITY_EDITOR

    public sealed class SimulateLoadedAssetBundleAsyncOperation : AssetBundleAsyncOperation
    {
        public SimulateLoadedAssetBundleAsyncOperation(LoadedAssetBundle obj) {
            loadedAssetBundle = obj;
        }

        public override T GetAsset<T>(string assetname, bool findIndependAssetBundles) {
            T asset = loadedAssetBundle.GetAsset<T>(assetname, findIndependAssetBundles);
            if (asset == null) {
                Debug.LogErrorFormat("获取{0}中的资源{1}失败！", loadedAssetBundle.assetBundleName, assetname);
            }
            return asset;
        }

        public override bool IsDone() {
            return loadedAssetBundle != null;
        }

        public override void UnLoad(bool unloadAllLoadedObjects = false) {
  
        }
    }


#endif

}
