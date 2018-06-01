/*****************************************************
 * 作者：DRed(龙涛) 1036409576@qq.com
 * 创建时间：2015.9.5
 * 版本：0.1.0
 * 描述：游戏Build工具选项
 ****************************************************/

using System;
using UnityEngine;
using System.Collections;
using System.IO;
using UnityEditor;
using Object = UnityEngine.Object;
using System.Collections.Generic;

[System.Flags]
public enum GameBuildResTag
{
    biji = 1,
    henanmj = 2,
    majiang = 4,
    publictable = 8,
    runfast = 16,
    // cowboy = 32,
    guandan = 64,
    doudizhu = 128,
    changpai = 256,
    paohuzi = 512,
    // zhajinhua = 1024,
    // laoyancai = 1024 * 2,
    daigoutui = 1024 * 2 * 2,
    // sangong = 1024 * 2 * 2 * 2,
    // baibazhang = 1024 * 2 * 2 * 2 * 2,
    // shisanzhang = 1024 * 2 * 2 * 2 * 2 * 2,
    majiang3d = 1024 * 2 * 2 * 2 * 2 * 2 * 2,
    majiangshanxi = 1024 * 2 * 2 * 2 * 2 * 2 * 2 * 2,
    majiangshanxi3d = 1024 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2,
    wushik = 1024 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2,
    huapai = 1024 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2 * 2,
    end,
}

public class GameConfig {    
    public string gameName;
    public string appName;
    
}

public class EditorGameBuildConfigurations  {

    //上传Version名字
	public string gameName = "DHGDQP_RUNFAST";

    // 打包的名字    
    public string mAppBuildName = "DHQPYX";

    private string mAppExportPath;

    private string mBuildTime = "";

    public bool isMaster = false;

    public void SetBuildTime() {
        mBuildTime = DateTime.Now.ToLocalTime().ToString("yyyy-MMdd-HHmm");
    }

    public string appbuildName {
        get { 
            string name;
            if (mBuildTime.IsNullOrEmpty()) {
                SetBuildTime();
            }
            if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS) {
                
                if (GameConfigProject.instance.isIosEnterprise) {
                    name = string.Format("XcodeProject_{0}_IosEnterprise_v{1}_{2}", mAppBuildName, Application.version, mBuildTime);         
                } else {
                    name = string.Format("XcodeProject_{0}_v{1}_{2}", mAppBuildName, Application.version, mBuildTime);         
                }

            } else {
                string extendName = "" ;
                if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android) {
                    extendName = ".apk";
                } else if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneOSX || EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneOSXIntel || EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneOSXIntel64) {
                    extendName = ".app";
                } else if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneWindows || EditorUserBuildSettings.activeBuildTarget == BuildTarget.StandaloneWindows64) {
                    extendName = ".exe";
                }
                name = string.Format("{0}_v{1}_{2}{3}", mAppBuildName, Application.version, mBuildTime, extendName);
            }
            return name;
        }
    }
    

    
    public string appExportPath {
        get { return mAppExportPath; }
    }

    public GameConfigProject mConfig;

    public string resourcesUploadServerHost = "http://test.sincebest.com/oms-bullfight";

    public bool buildAppAutoIncreaseVersion = false;

    public GameBuildResTag gameBuildResTag;
    private bool[] gameBuildResBools;

    private GameConfigNet.IPAdress resourcesIpAdress;
    
    //上传资源服务器的地址
    public string assetVersionUploadServerName = "";

    public Dictionary<GameConfigNet.IPAdress, string> resourcesIpDatas = new Dictionary<GameConfigNet.IPAdress, string>();
    

    Dictionary<string, string[]> mPlayerSettingAndroid = new Dictionary<string, string[]>();

    public void OpenAllGameBuildResBools() {
        // int count = (int)GameBuildResTag.end - 1;
        // int packageNum = 0;
        // do {
        //     packageNum += 1;
        //     count = count / 2;
        // } while(count != 1);

        // for (int i = 1; i <= packageNum; i++) {
        //     gameBuildResBools[(int)GameBuildResTag.] = true;
        // }
        gameBuildResBools[(int)GameBuildResTag.biji] = true;
        gameBuildResBools[(int)GameBuildResTag.henanmj] = true;
        gameBuildResBools[(int)GameBuildResTag.majiang] = true;
        gameBuildResBools[(int)GameBuildResTag.publictable] = true;
        gameBuildResBools[(int)GameBuildResTag.runfast] = true;
        // gameBuildResBools[(int)GameBuildResTag.cowboy] = true;
        gameBuildResBools[(int)GameBuildResTag.guandan] = true;
        gameBuildResBools[(int)GameBuildResTag.doudizhu] = true;
        gameBuildResBools[(int)GameBuildResTag.changpai] = true;
        gameBuildResBools[(int)GameBuildResTag.paohuzi] = true;
        // gameBuildResBools[(int)GameBuildResTag.zhajinhua] = true;
        // gameBuildResBools[(int)GameBuildResTag.laoyancai] = true;
        gameBuildResBools[(int)GameBuildResTag.daigoutui] = true;
        // gameBuildResBools[(int)GameBuildResTag.sangong] = true;
        // gameBuildResBools[(int)GameBuildResTag.baibazhang] = true;
        // gameBuildResBools[(int)GameBuildResTag.shisanzhang] = true;
        gameBuildResBools[(int)GameBuildResTag.majiang3d] = true;
        gameBuildResBools[(int)GameBuildResTag.majiangshanxi] = true;
        gameBuildResBools[(int)GameBuildResTag.majiangshanxi3d] = true;

        gameBuildResBools[(int)GameBuildResTag.wushik] = true;
        gameBuildResBools[(int)GameBuildResTag.huapai] = true;




        gameBuildResTag |= GameBuildResTag.biji;
        gameBuildResTag |= GameBuildResTag.henanmj;
        gameBuildResTag |= GameBuildResTag.majiang;
        gameBuildResTag |= GameBuildResTag.publictable;
        gameBuildResTag |= GameBuildResTag.runfast;
        // gameBuildResTag |= GameBuildResTag.cowboy;
        gameBuildResTag |= GameBuildResTag.guandan;
        gameBuildResTag |= GameBuildResTag.doudizhu;
        gameBuildResTag |= GameBuildResTag.changpai;
        gameBuildResTag |= GameBuildResTag.paohuzi;
        // gameBuildResTag |= GameBuildResTag.zhajinhua;
        // gameBuildResTag |= GameBuildResTag.laoyancai;
        gameBuildResTag |= GameBuildResTag.daigoutui;
        // gameBuildResTag |= GameBuildResTag.sangong;
        // gameBuildResTag |= GameBuildResTag.baibazhang;
        // gameBuildResTag |= GameBuildResTag.shisanzhang;
        gameBuildResTag |= GameBuildResTag.majiang3d;
        gameBuildResTag |= GameBuildResTag.majiangshanxi;
        gameBuildResTag |= GameBuildResTag.majiangshanxi3d;
        gameBuildResTag |= GameBuildResTag.wushik;
        gameBuildResTag |= GameBuildResTag.huapai;

    }

    public void ResetGameBuildResBools() {
        gameBuildResBools = new bool[(int)GameBuildResTag.end];
        if(Application.identifier == "com.sincebestgames.dahuqipaiyouxi")
        {
            gameBuildResBools[(int)GameBuildResTag.henanmj] = true;
            // gameBuildResBools[(int)GameBuildResTag.majiang] = true;
            #if UNITY_IPHONE
                gameBuildResBools[(int)GameBuildResTag.runfast] = true;
                gameBuildResBools[(int)GameBuildResTag.publictable] = true;
            #endif
            resourcesIpAdress = GameConfigNet.IPAdress.DHAHQPTest;
        }
    }

    public EditorGameBuildConfigurations() {
        if (mConfig == null) {
            mConfig = Object.FindObjectOfType<GameConfigProject>();
        }
        resourcesIpAdress = GameConfigNet.IPAdress.Userdefined;
        ResetGameBuildResBools();

        if (EditorPrefs.GetString("GameBuildIsMaster", "false") == "true") {
            isMaster = true;
        } 

        resourcesIpDatas.Add(GameConfigNet.IPAdress.DHAHQPTest, "http://114.55.99.139:9029");
        resourcesIpDatas.Add(GameConfigNet.IPAdress.DHAHQPProduction, "http://commons.sincebest.com");

        string host;
        mAppExportPath = EditorPrefs.GetString("GameAppbuildPath", "");
        
        if (resourcesIpDatas.TryGetValue(resourcesIpAdress, out host)) {
            resourcesUploadServerHost = host;
        }

        // appid                                                                    路径名字             keystorePass  keyaliasName     keyaliasPass
        mPlayerSettingAndroid.Add("com.sincebest.jisukwx", new string[]{"jskawuxing.keystore", "jskawuxing", "jskwx", "jskawuxing"});
        mPlayerSettingAndroid.Add("com.sincebest.dahuanqingmajiang", new string[] { "duomimj.keystore", "hnduomimj", "dahuwangjiang", "dhwjmj" });
        mPlayerSettingAndroid.Add("common", new string[] { "sincebest.keystore", "sincebest", "sincebest", "sincebest" });


        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Android, "BESTHTTP_DISABLE_COOKIES;BESTHTTP_DISABLE_CACHING;BESTHTTP_DISABLE_SERVERSENT_EVENTS;BESTHTTP_DISABLE_SIGNALR;BESTHTTP_DISABLE_SOCKETIO;BESTHTTP_DISABLE_ALTERNATE_SSL;");
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, "BESTHTTP_DISABLE_COOKIES;BESTHTTP_DISABLE_CACHING;BESTHTTP_DISABLE_SERVERSENT_EVENTS;BESTHTTP_DISABLE_SIGNALR;BESTHTTP_DISABLE_SOCKETIO;BESTHTTP_DISABLE_ALTERNATE_SSL;");
        PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.Standalone, "BESTHTTP_DISABLE_COOKIES;BESTHTTP_DISABLE_CACHING;BESTHTTP_DISABLE_SERVERSENT_EVENTS;BESTHTTP_DISABLE_SIGNALR;BESTHTTP_DISABLE_SOCKETIO;BESTHTTP_DISABLE_ALTERNATE_SSL;");
        PlayerSettings.stripEngineCode = true;
    }

    public void SetAndroidKeystore() {
        string[] settingData;
        if (!mPlayerSettingAndroid.TryGetValue(Application.identifier, out settingData)){
            mPlayerSettingAndroid.TryGetValue("common", out settingData);
        }

        if (settingData != null){
            if (Application.platform == RuntimePlatform.OSXEditor) {
                PlayerSettings.Android.keystoreName = settingData[0];
            } else {
                PlayerSettings.Android.keystoreName = Application.dataPath + "/../" + settingData[0];
            }
            PlayerSettings.Android.keystorePass = settingData[1];
            PlayerSettings.Android.keyaliasName = settingData[2];
            PlayerSettings.Android.keyaliasPass = settingData[3];
        } 
    }


    public bool OnGUI() {
        if (GameConfigProject.instance == null) {
            return true;
        }
        GUILayout.BeginVertical();
        GUILayout.Width(200);
        if (GameEditorTools.DrawHeader("游戏设置", true)) {
            GameEditorTools.BeginContents();
            GUI.color = Color.yellow;
            GameConfigProject.instance.assetBundleFilePathEncrypt = GUILayout.Toggle(GameConfigProject.instance.assetBundleFilePathEncrypt, "资源路径加密");
            EditorGUILayout.BeginHorizontal();
            GameConfigProject.instance.developmentMode = GUILayout.Toggle(GameConfigProject.instance.developmentMode, "开启开发者模式");
            #if UNITY_IPHONE
            GameConfigProject.instance.isIosEnterprise = GUILayout.Toggle(GameConfigProject.instance.isIosEnterprise, "iOS企业包");
            #endif
            EditorGUILayout.EndHorizontal();
            GUI.color = Color.cyan;
            EditorGUILayout.BeginHorizontal();
            PlayerSettings.bundleVersion = EditorGUILayout.TextField("游戏版本号：", Application.version);
            if (EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS) {
                PlayerSettings.iOS.buildNumber = EditorGUILayout.TextField("BuildNumber", PlayerSettings.iOS.buildNumber);
            } else {
                PlayerSettings.Android.bundleVersionCode = EditorGUILayout.IntField("BuildNumber", PlayerSettings.Android.bundleVersionCode);
            }
           
            EditorGUILayout.EndHorizontal();
            buildAppAutoIncreaseVersion = EditorGUILayout.Toggle("Build自增App版本号：", buildAppAutoIncreaseVersion);
#if  UNITY_ANDROID
            GUI.color = Color.yellow;
            ScriptingImplementation scriptingImplementation = PlayerSettings.GetScriptingBackend(BuildTargetGroup.Android);
            scriptingImplementation = (ScriptingImplementation)EditorGUILayout.EnumPopup("StripEngineCode", scriptingImplementation);
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, scriptingImplementation);
#endif
            GUI.color = Color.cyan;
            PlayerSettings.stripEngineCode = EditorGUILayout.Toggle("StripEngineCode", PlayerSettings.stripEngineCode);
            //EditorGUILayout.TextField("AndroidDll生成时间：", File.GetLastWriteTime(Application.dataPath + "/Scripts/External/Runtime/Android/GameDll.dll.bytes").ToString("yy-MM-dd HH:mm:ss"));
            GUI.enabled = true;
            GUI.color = Color.white;
            GUILayout.BeginHorizontal();
            GUILayout.Label("服务器地址");
            mConfig.net.ipAdressType = (GameConfigNet.IPAdress)EditorGUILayout.Popup((int)mConfig.net.ipAdressType, mConfig.net.ipAdressTypeName);
            GUILayout.EndHorizontal();
            if (mConfig.net.ipAdressType == GameConfigNet.IPAdress.Userdefined) {
                mConfig.net.loginServerIp = EditorGUILayout.TextField("服务器IP", mConfig.net.loginServerIp);
                mConfig.net.loginPort = EditorGUILayout.IntField("服务器Port", mConfig.net.loginPort);
            } else {
                GUI.enabled = false;
                EditorGUILayout.TextField("服务器IP", mConfig.net.loginServerIp);
                EditorGUILayout.IntField("服务器Port", mConfig.net.loginPort);
                GUI.enabled = true;
            }
            GameEditorTools.EndContents();
        }

        if (GameEditorTools.DrawHeader("Build设置", true)) {
            GUILayout.BeginHorizontal();

            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            EditorGUILayout.TextField("App导出路径", Path.Combine(appExportPath, appbuildName));
            if (GUILayout.Button("选择")) {
                string buildPath = EditorUtility.SaveFolderPanel("Build路径", mAppExportPath, "");
                if (buildPath.Length != 0) {
                    mAppExportPath = buildPath;
                    EditorPrefs.SetString("GameAppbuildPath", buildPath);
                }
            }
            GUILayout.EndHorizontal();

            EditorUserBuildSettings.development = EditorGUILayout.Toggle("Development Build", EditorUserBuildSettings.development);
            if (EditorUserBuildSettings.development) {
                EditorUserBuildSettings.connectProfiler = EditorGUILayout.Toggle("OpenProfiler", EditorUserBuildSettings.connectProfiler);
                EditorUserBuildSettings.allowDebugging = EditorGUILayout.Toggle("ScriptDebug", EditorUserBuildSettings.allowDebugging);
            }
        }
        if (GameEditorTools.DrawHeader("上传设置")) {
            GUI.color = Color.yellow;
            bool isMasterTmp = EditorGUILayout.Toggle("Master分支", isMaster);
            if (isMasterTmp != isMaster) {
                isMaster = isMasterTmp;
                EditorPrefs.SetString("GameBuildIsMaster", isMaster ? "true" : "false");
            }
            GUI.color = Color.white;
            GUILayout.BeginHorizontal();
            GUILayout.Label("上传资源服务器地址");
            resourcesIpAdress = (GameConfigNet.IPAdress)EditorGUILayout.Popup((int)resourcesIpAdress, mConfig.net.ipAdressTypeName);
            assetVersionUploadServerName = mConfig.net.ipAdressTypeName[(int)resourcesIpAdress];
            GUILayout.EndHorizontal();
            if (GUI.changed) {
                string host;
                if (resourcesIpDatas.TryGetValue(resourcesIpAdress, out host)) {
                    resourcesUploadServerHost = host;
                }
            }
            if (resourcesIpAdress == GameConfigNet.IPAdress.Userdefined) {
                resourcesUploadServerHost = EditorGUILayout.TextField("服务器Host", resourcesUploadServerHost);
            } else {
                GUI.enabled = false;
                EditorGUILayout.TextField("服务器Host", resourcesUploadServerHost);
                GUI.enabled = true;
            }
        }

		GameEditorTools.DrawHeader("资源打包设置");
        gameBuildResTag = 0;
        EditorGUILayout.BeginHorizontal();
        int allNum = Enum.GetNames(typeof(GameBuildResTag)).ToDynList().Count;
        int tagNum = 0;
        int curNum = 0;
        foreach (GameBuildResTag tag in Enum.GetValues(typeof(GameBuildResTag))) {
            if(tagNum == 0) EditorGUILayout.BeginVertical();
            if (tag != GameBuildResTag.end) {
                ToggleGameBuildResTag(tag.ToString(), tag);
            }
            tagNum++;
            if(tagNum == 4) EditorGUILayout.EndVertical();
            curNum++;
            if(curNum == allNum && tagNum != 4)  EditorGUILayout.EndVertical();
            if(tagNum == 4) tagNum = 0;
        }
        EditorGUILayout.EndHorizontal();
        GUI.backgroundColor = Color.gray;
        if (GUILayout.Button("Player Settings")) {
            EditorApplication.ExecuteMenuItem("Edit/Project Settings/Player");
        }
        GUI.backgroundColor = Color.white;
        GUILayout.EndVertical();
        return true;
    }

    private void ToggleGameBuildResTag(string title, GameBuildResTag tag) {
        GUILayout.BeginHorizontal();
        EditorGUILayout.LabelField(title, GUILayout.Width(50));
        if(tag == GameBuildResTag.henanmj)
        {
            gameBuildResBools[(int)tag] = true;
            gameBuildResTag |= GameBuildResTag.henanmj;
            EditorGUI.BeginDisabledGroup(true);
            EditorGUILayout.Toggle(true, GUILayout.Width(50));
            EditorGUI.EndDisabledGroup();
        }
        else
        {

            gameBuildResBools[(int)tag] = EditorGUILayout.Toggle(gameBuildResBools[(int)tag], GUILayout.Width(50));
            if(gameBuildResBools[(int)tag])
            {
                gameBuildResTag |= tag;
            }
        }
        gameBuildResTag |= GameBuildResTag.henanmj;
        GUILayout.EndHorizontal();
    } 

    public void ResetKeystore() {
        PlayerSettings.Android.keystoreName = "";
        PlayerSettings.Android.keystorePass = "";
        PlayerSettings.Android.keyaliasName = "";
        PlayerSettings.Android.keyaliasPass = "";
    }
}
