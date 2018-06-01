///*****************************************************
// * 作者: 刘靖 不到万不得已别找我
// * 创建时间：2014.n.n
// * 版本：1.0.0
// * 描述：GameInitInspector
// ****************************************************/

//using System;
//using UnityEngine;


//#if UNITY_EDITOR
//using UnityEditor;
//#endif
//using System.Collections;

//[CustomEditor(typeof(GameInit))]
//public class GameInitInspector : Editor
//{

//    private string mExternalDllRuntimePath = "Assets/Scripts/External/Runtime/";
//    private string mExternalDllEditorPath = "Assets/Scripts/External/Editor/";
//    private GameInit targetInstance;
//    public override void OnInspectorGUI() {
//        targetInstance = (GameInit)target;

////#if UNITY_IPHONE
////        //ConverTextBytesToGameDll();
////        if (targetInstance.loadType != GameInit.LoadType.Dll) {
////            ConverTextBytesToGameDll();
////        }
////        targetInstance.loadType = GameInit.LoadType.Dll;
////        EditorGUILayout.LabelField("IOS平台只能使用直接加载dll的方式:", targetInstance.loadType.ToString());
////        return;
////#endif

//        GUI.color = Color.cyan;
//        GUILayout.BeginHorizontal();
//        GUILayout.Label("加载方式");
//        targetInstance.loadType = (GameInit.LoadType)EditorGUILayout.EnumPopup(targetInstance.loadType);
//        GUILayout.EndHorizontal();
//        if (GUI.changed) {
//            if(targetInstance.loadType == GameInit.LoadType.TextBytes)  {
//                PlayerPrefs.SetInt("GameInit.LoadType", (int)GameInit.LoadType.TextBytes);
//                PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, "");
//                ConverGameDllToTextBytes();
//            } else if (targetInstance.loadType == GameInit.LoadType.AndroidEditor) {
//                PlayerPrefs.SetInt("GameInit.LoadType", (int)GameInit.LoadType.AndroidEditor);
//                ConverGameDllToTextBytes();
//            } else if (targetInstance.loadType == GameInit.LoadType.AndroidRuntime) {
//                PlayerPrefs.SetInt("GameInit.LoadType", (int)GameInit.LoadType.AndroidRuntime);
//                ConverGameDllToTextBytes();
//            } else if (targetInstance.loadType == GameInit.LoadType.IOSRuntime) {
//                PlayerPrefs.SetInt("GameInit.LoadType", (int)GameInit.LoadType.IOSRuntime);
//                PlayerSettings.SetScriptingDefineSymbolsForGroup(BuildTargetGroup.iOS, "USE_DLL_INIT");
//                ConverIosTextBytesToGameDll();
//            }
//        }
//        GUI.color = Color.white;
//        EditorGUILayout.LabelField("PlayerPrefs加载方式:", ((GameInit.LoadType)PlayerPrefs.GetInt("GameInit.LoadType")).ToString());

//        if (GameEditorTools.DrawHeader("统计信息")) {
//            GameEditorTools.BeginContents();
//            if (targetInstance.gameDllBuildTime.Minute > 1) {
//                GUI.color = Color.yellow;
//                //EditorGUILayout.LabelField("GameDll版本号：" + targetInstance.gameDllVersion);
//                EditorGUILayout.LabelField("GameDll编译时间：" + targetInstance.gameDllBuildTime.ToString("yy-MM-dd HH:mm:ss"));
//                if (targetInstance.gameEditorDllBuildTime.Minute > 1) {
//                    EditorGUILayout.LabelField("Editor编译时间：" + targetInstance.gameEditorDllBuildTime.ToString("yy-MM-dd HH:mm:ss"));
//                }
//                GUI.color = Color.white;
//            }
//            else {
//                GUI.color = Color.gray;
//                EditorGUILayout.LabelField("运行状态下才会有效");
//                GUI.color = Color.white;
//            }
//            GameEditorTools.EndContents();
//        }   
//        GUILayout.Label(EditorPrefs.GetString("kScriptsDefaultApp"));
//    }

//    void ConverTextBytesToGameDll() {
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "Android/" + "GameDll.dll", mExternalDllRuntimePath + "Android/" + "GameDll.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "Android/" + "GameDll.dll.mdb", mExternalDllRuntimePath + "Android/" + "GameDll.dll.mdb.bytes");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "GameDll.dll", mExternalDllRuntimePath + "iOS/" + "GameDll.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "GameDll.dll.mdb", mExternalDllRuntimePath + "iOS/" + "GameDll.dll.mdb.bytes");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "PBMessageSerializer.dll", mExternalDllRuntimePath + "iOS/" + "PBMessageSerializer.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "PBMessage.dll", mExternalDllRuntimePath + "iOS/" + "PBMessage.dll.bytes");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "GameDll.dll.mdb.bytes", mExternalDllRuntimePath + "GameDll.dll.mdb");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "GameDll.dll.bytes", mExternalDllRuntimePath + "GameDll.dll");
//        HelpFunEditor.RenameFile(mExternalDllEditorPath + "GameEditor.dll.mdb.bytes", mExternalDllEditorPath + "GameEditor.dll.mdb");
//        HelpFunEditor.RenameFile(mExternalDllEditorPath + "GameEditor.dll.bytes", mExternalDllEditorPath + "GameEditor.dll");
//        AssetDatabase.SaveAssets();
//        AssetDatabase.Refresh();
//    }

//    void ConverIosTextBytesToGameDll() {
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "GameDll.dll", mExternalDllRuntimePath + "GameDll.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "GameDll.dll.mdb", mExternalDllRuntimePath + "GameDll.dll.mdb.bytes");
//        HelpFunEditor.RenameFile(mExternalDllEditorPath + "GameEditor.dll", mExternalDllEditorPath + "GameEditor.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllEditorPath + "GameEditor.dll.mdb", mExternalDllEditorPath + "GameEditor.dll.mdb.bytes");

        
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "GameDll.dll.mdb.bytes", mExternalDllRuntimePath + "iOS/" + "GameDll.dll.mdb");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "GameDll.dll.bytes", mExternalDllRuntimePath + "iOS/" + "GameDll.dll");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "PBMessageSerializer.dll.bytes", mExternalDllRuntimePath + "iOS/" + "PBMessageSerializer.dll");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "PBMessage.dll.bytes", mExternalDllRuntimePath + "iOS/" + "PBMessage.dll");

//        AssetDatabase.SaveAssets();
//        AssetDatabase.Refresh();
//    }

//    void ConverGameDllToTextBytes() {
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "GameDll.dll", mExternalDllRuntimePath + "GameDll.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "GameDll.dll.mdb", mExternalDllRuntimePath + "GameDll.dll.mdb.bytes");
//        HelpFunEditor.RenameFile(mExternalDllEditorPath + "GameEditor.dll", mExternalDllEditorPath + "GameEditor.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllEditorPath + "GameEditor.dll.mdb", mExternalDllEditorPath + "GameEditor.dll.mdb.bytes");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "Android/" + "GameDll.dll", mExternalDllRuntimePath + "Android/" + "GameDll.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "Android/" + "GameDll.dll.mdb", mExternalDllRuntimePath + "Android/" + "GameDll.dll.mdb.bytes");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "GameDll.dll", mExternalDllRuntimePath + "iOS/" + "GameDll.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "GameDll.dll.mdb", mExternalDllRuntimePath + "iOS/" + "GameDll.dll.mdb.bytes");

//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "PBMessageSerializer.dll", mExternalDllRuntimePath + "iOS/" + "PBMessageSerializer.dll.bytes");
//        HelpFunEditor.RenameFile(mExternalDllRuntimePath + "iOS/" + "PBMessage.dll", mExternalDllRuntimePath + "iOS/" + "PBMessage.dll.bytes");

//        AssetDatabase.SaveAssets();
//        AssetDatabase.Refresh();
//    }
//}
