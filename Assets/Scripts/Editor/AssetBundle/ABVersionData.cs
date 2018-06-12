﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MyLitJson;
using System.IO;
using System.Text;

///AB编辑器显示数据 create by Jyz
namespace ABEditor{
	public enum CheckType 
	{
		None = 0,
		CantDel = 1,
	}

	[System.Serializable]
	public class ABPackageInfo{
		public string name;
		public string sizeIncremental = "N/A";
		public string sizeWhole = "N/A";
		public string lastVersion = "Original";
		public string dependPackages = "";
	}

	[System.Serializable]
	public class ABVersionData  {

		public string name;

		public string mark;

		public string flagMode;

		public string lastVersion;

		public List<ABPackageInfo> pakages = new List<ABPackageInfo>();

	}

	public class ABVersionTools{
		public static string loadPath = "";
		public static string originalVersion = "";
		public static bool isUseMd5 = false;
		public static bool isUseHash = true;
		public static string ABVersionDataPath
		{
			get{
				return DataConfigProject.externalAssetBundleVersionPath + loadPath +"/Config.txt";
			}
		} 
		
		public static void Refresh()
		{
			SaveVersionData();
			m_data = null;
		}
		public static void SetChange()
		{
			m_data = null;
		}

		public static void Dispose()
		{
			m_data = null;
			_dataPool = new Dictionary<string,ABVersionData>();
		}
		private static Dictionary<string,ABVersionData> _dataPool = new Dictionary<string,ABVersionData>();

		public static Dictionary<string,ABVersionData> dataPool
		{
			get
			{
				return _dataPool;
			}
		} 

		private static ABVersionData m_data;
		public static ABVersionData data{
			get{
				if(m_data == null)
				{
                	m_data = Load();
					_dataPool[loadPath] = m_data;
				}
                return m_data;
			}
		}

		public static void SaveVersionData()
		{
			if(m_data == null)
				return ;
			StringBuilder sb = new StringBuilder();
			sb.Append("{");
			sb.Append("\"name\":\"" + data.name + "\",");
			sb.Append("\"mark\":\"" + data.mark + "\",");
			sb.Append("\"flagMode\":\"" + data.flagMode + "\",");
			sb.Append("\"lastVersion\":\"" + data.lastVersion + "\",");
			sb.Append("\"pakages\":[");
			for(int i = 0; i < data.pakages.Count; i++)
			{
				sb.Append("{");
				sb.Append("\"name\":\""+data.pakages[i].name+"\",");
				sb.Append("\"dependPackages\":\""+data.pakages[i].dependPackages+"\",");
				sb.Append("\"sizeIncremental\":\""+data.pakages[i].sizeIncremental+"\",");
				sb.Append("\"sizeWhole\":\""+data.pakages[i].sizeWhole+"\",");
				sb.Append("\"lastVersion\":\""+data.pakages[i].lastVersion+"\"");
				sb.Append("}");
				if(i != data.pakages.Count - 1) sb.Append(",");
			}
			sb.Append("]");
			sb.Append("}");
			FileUtility.SaveFile(ABVersionDataPath,sb.ToString());

		}
		
		
		public static void SetCheckType(string mark)
		{
			if(data == null) 
			{
				Debug.LogError("没有获取编辑器配置信息！");
				return;
			}
			data.mark = mark;
		}

		public static ABVersionData GetVersionData(string iterativeVersion)
		{
			foreach(var dic in dataPool)
			{
				if(dic.Value.name.Equals(iterativeVersion))
					return dic.Value;
			}
			string path = originalVersion + "/" + iterativeVersion;
			//Debug.Log("1 " + path);
			ABVersionData getData = LoadByVersion(path);
			
			if(getData.pakages.Count > 0){
				dataPool[path] = getData;
				return getData;
			} 
			return null;
		}


		private static ABVersionData Load(string path = "")
		{
			path = path == "" ? ABVersionDataPath : path;
			string str = string.Empty;
			//Debug.LogError("加载: " + ABVersionDataPath);
			if(File.Exists(path))
				str = FileUtility.ReadAllText(path);
			//Debug.Log(path + " read txt = " + str);
			if(string.Empty == str || !str.Contains("pakages"))  //如果是旧版本的配置，则重新生成新配置
				return new ABVersionData();
			return JsonUtility.FromJson<ABVersionData>(str);
		}

		private static ABVersionData LoadByVersion(string originalVersion)
		{
			string path = DataConfigProject.externalAssetBundleVersionPath + originalVersion +"/Config.txt";
			//Debug.Log("2 " + path);
			return Load(path);
		}
	}

}