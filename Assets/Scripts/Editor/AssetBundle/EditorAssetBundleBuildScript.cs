using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEditor.Callbacks;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;

public class AssetBundleBuildScript {
    const string kAssetBundlesOutputPath = "AssetBundles";

    public static bool BuildAssetBundles(bool unCompression) {
        CheckAssetBundleName();
        BuildLuaNotJitBundles();
        string compressionOutputPath = Path.Combine(kAssetBundlesOutputPath, DataConfigProject.externalAssetBundlePathCompression);

        if (!Directory.Exists(compressionOutputPath)) {
            Directory.CreateDirectory(compressionOutputPath);
        }

        //开启DisableWriteTypeTree可能造成AssetBundle对Unity版本的兼容问题，但会使Bundle更小，同时也会略微提高加载速度。
        BuildAssetBundleOptions buildAssetBundleOptions = BuildAssetBundleOptions.DeterministicAssetBundle | BuildAssetBundleOptions.ChunkBasedCompression;// | BuildAssetBundleOptions.DisableWriteTypeTree;
        var manifest = BuildPipeline.BuildAssetBundles(compressionOutputPath, buildAssetBundleOptions, EditorUserBuildSettings.activeBuildTarget);
        if (manifest == null) {
            return false;
        }

        FileUtil.DeleteFileOrDirectory(DataConfigProject.externalAssetBundlePathCompression + "asset_bundle_manifest");
        FileUtil.CopyFileOrDirectory(DataConfigProject.externalAssetBundlePathCompression + DataConfigProject.platform + "Compression", DataConfigProject.externalAssetBundlePathCompression + "asset_bundle_manifest");
        FileUtil.DeleteFileOrDirectory(DataConfigProject.externalAssetBundlePathCompression + "asset_bundle_manifest.manifest");
        FileUtil.CopyFileOrDirectory(DataConfigProject.externalAssetBundlePathCompression + DataConfigProject.platform + "Compression.manifest", DataConfigProject.externalAssetBundlePathCompression + "asset_bundle_manifest.manifest");

        return true;
        //VersionCtrlEditorTool.CustomGenerateIndexVerTxtFromLastVer(outputPath);

        //var buildMap = new AssetBundleBuild[1];
        //buildMap[0].assetBundleName = "shaders11.bytes";
        //List<string> assetNames = new List<string>();
        //var assets11 = AssetDatabase.FindAssets("t:Shader", new[] { "Assets/Game/Shader" });
        //assets11.ForEach(x => {
        //    assetNames.Add(AssetDatabase.GUIDToAssetPath(x));
        //    Debug.Log(AssetDatabase.GUIDToAssetPath(x));
        //});
        //buildMap[0].assetNames = assetNames.ToArray();
        //BuildPipeline.BuildAssetBundles(DataConfigProject.externalAssetBundlePathCompression, buildMap, BuildAssetBundleOptions.DeterministicAssetBundle, BuildTarget.StandaloneWindows);
    }


    static void BuildLuaNotJitBundles() {
        string tempDir = Application.dataPath + "/Temp/Lua";
        if (!Directory.Exists(tempDir)) {
            Directory.CreateDirectory(tempDir);
        }
        foreach (var luaFile in Directory.GetFiles(Application.dataPath + "/Temp", "*.bytes", SearchOption.AllDirectories)) {
            FileUtil.DeleteFileOrDirectory(luaFile);
        }

        CopyLuaBytesFiles(LuaConst.luaDir, tempDir);
        CopyLuaBytesFiles(LuaConst.toluaDir, tempDir);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        List<string> dirs = new List<string>();
        GetAllDirs(tempDir, dirs);

        for (int i = 0; i < dirs.Count; i++) {
            string str = dirs[i].Remove(0, tempDir.Length);
            BuildLuaBundle(str.Replace('\\', '/'), "Assets/Temp/Lua");
        }
        
        BuildLuaBundle(null, "Assets/Temp/Lua");

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

    }

    static void GetAllDirs(string dir, List<string> list) {
        string[] dirs = Directory.GetDirectories(dir);
        list.AddRange(dirs);
        for (int i = 0; i < dirs.Length; i++) {
            GetAllDirs(dirs[i], list);
        }
    }



    public static void CopyLuaBytesFiles(string sourceDir, string destDir, bool appendext = true, string searchPattern = "*.lua", SearchOption option = SearchOption.AllDirectories) {
        if (!Directory.Exists(sourceDir)) {
            return;
        }

        string[] files = Directory.GetFiles(sourceDir, searchPattern, option);
        int len = sourceDir.Length;

        if (sourceDir[len - 1] == '/' || sourceDir[len - 1] == '\\') {
            --len;
        }

        for (int i = 0; i < files.Length; i++) {
            string str = files[i].Remove(0, len);
            string dest = destDir + "/" + str;
            if (appendext) dest += ".bytes";
            string dir = Path.GetDirectoryName(dest);
            Directory.CreateDirectory(dir);
            File.Copy(files[i], dest, true);
        }
    }

    static void BuildLuaBundle(string subDir, string sourceDir) {
        string[] files = Directory.GetFiles(sourceDir + subDir, "*.bytes");
        string bundleName = subDir == null ? "lua.bytes" : "lua" + subDir.Replace('/', '_') + ".bytes";
        bundleName = "lua/" + bundleName.ToLower();

        for (int i = 0; i < files.Length; i++) {
            AssetImporter importer = AssetImporter.GetAtPath(files[i]);

            if (importer != null) {
                // importer.assetBundleName = bundleName;
                importer.SetAssetBundleNameAndVariant(bundleName, null);
                // importer.assetBundleVariant = "";
            }
        }
    }

    //检测
    public static void CheckAssetBundleName() {
        AssetDatabase.RemoveUnusedAssetBundleNames();
        var allAssetBundlesName = AssetDatabase.GetAllAssetBundleNames();
        foreach (var path in allAssetBundlesName) {
            foreach (var assetPath in AssetDatabase.GetAssetPathsFromAssetBundle(path)) {
                if (!assetPath.StartsWith("Assets/Game/PackagingResources/")) {
                    if (assetPath.StartsWith("Assets/Scripts/External/Runtime/Android/")) {
                        continue;
                    }

                    if (assetPath.Contains("/Lua/")) {
                        continue;
                    }

                    AssetImporter assetImporter = AssetImporter.GetAtPath(assetPath);
                    assetImporter.assetBundleName = "";
                    Debug.LogErrorFormat("发现冗余的AssetBundle资源：<color=yellow>{0}</color>", assetPath);
                }
            }
        }
        AssetDatabase.Refresh();
    }
}
