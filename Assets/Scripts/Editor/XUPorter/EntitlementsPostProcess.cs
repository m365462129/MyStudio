#if UNITY_IPHONE
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using System.Collections;
using System.IO;


public class EntitlementsPostProcess : ScriptableObject
{
    public DefaultAsset m_entitlementsFile;

    [PostProcessBuild]
    public static void OnPostProcess(BuildTarget buildTarget, string buildPath)
    {
        if (buildTarget != BuildTarget.iOS)
        {
            return;
        }

        var proj = new PBXProject();

        var dummy = ScriptableObject.CreateInstance<EntitlementsPostProcess>();
        var file = dummy.m_entitlementsFile;
        ScriptableObject.DestroyImmediate(dummy);
        if (file == null)
        {
            Debug.LogError("EntitlementsFile为空");
            return;
        }

        var proj_path = PBXProject.GetPBXProjectPath(buildPath);
        proj.ReadFromFile(proj_path);

        // target_name = "Unity-iPhone"
        var target_name = PBXProject.GetUnityTargetName();
        var target_guid = proj.TargetGuidByName(target_name);
        var src = AssetDatabase.GetAssetPath(file);
        var file_name = Path.GetFileName(src);
        var dst = buildPath + "/" + target_name + "/" + file_name;
        FileUtil.CopyFileOrDirectory(src, dst);
        proj.AddFile(target_name + "/" + file_name, file_name);
        proj.AddBuildProperty(target_guid, "CODE_SIGN_ENTITLEMENTS", target_name + "/" + file_name);
        proj.AddBuildProperty(target_guid, "SystemCapabilities", "{com.apple.Push = {enabled = 1;};}");
        

        //Handle plist  
        string plistPath = buildPath + "/Info.plist";  
        PlistDocument plist = new PlistDocument();  
        plist.ReadFromString(File.ReadAllText(plistPath));  
        PlistElementDict rootDict = plist.root;  

        rootDict.SetString ("NSPhotoLibraryUsageDescription", "若不允许，您将无法使用图片上传功能");
        rootDict.SetString ("NSCameraUsageDescription", "若不允许，您将无法使用图片上传功能");
        rootDict.SetString ("NSLocationWhenInUseUsageDescription",  "若不允许，您将无法使用位置提示功能");
        rootDict.SetString ("NSMicrophoneUsageDescription", "若不允许，您将无法使用语言消息功能");
        plist.WriteToFile(plistPath);

        proj.WriteToFile(proj_path);
    }
}
#endif