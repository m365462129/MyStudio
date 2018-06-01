﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class GameAsset_AssetBundleManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(GameAsset.AssetBundleManager), typeof(SingletonProject<GameAsset.AssetBundleManager>));
		L.RegFunction("Initialize", Initialize);
		L.RegFunction("GetFullManifest", GetFullManifest);
		L.RegFunction("GetLoadedAssetBundleDic", GetLoadedAssetBundleDic);
		L.RegFunction("Reset", Reset);
		L.RegFunction("ResetPackage", ResetPackage);
		L.RegFunction("PackageHaveLoad", PackageHaveLoad);
		L.RegFunction("GetPackageHaveLoadeds", GetPackageHaveLoadeds);
		L.RegFunction("UnLoadAssetBundle", UnLoadAssetBundle);
		L.RegFunction("GetDependPackages", GetDependPackages);
		L.RegFunction("AssetBundleExist", AssetBundleExist);
		L.RegFunction("LoadAssetBundle", LoadAssetBundle);
		L.RegFunction("LoadAssetBundleAsync", LoadAssetBundleAsync);
		L.RegFunction("UnLoadLoadedAssetBundle", UnLoadLoadedAssetBundle);
		L.RegFunction("RemoveFromLoadedDic", RemoveFromLoadedDic);
		L.RegFunction("LoadBytesFromStreamingAssets", LoadBytesFromStreamingAssets);
		L.RegFunction("AssetBundleIsLoaded", AssetBundleIsLoaded);
		L.RegFunction("LuaAssetBundleIsLoaded", LuaAssetBundleIsLoaded);
		L.RegFunction("AssetBundlesIsLoadedOnly", AssetBundlesIsLoadedOnly);
		L.RegFunction("AssetBundleIsLoadedOnly", AssetBundleIsLoadedOnly);
		L.RegFunction("LoadAssetBundleFromFile", LoadAssetBundleFromFile);
		L.RegFunction("LoadAssetBundleFromFileAsync", LoadAssetBundleFromFileAsync);
		L.RegFunction("New", _CreateGameAsset_AssetBundleManager);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateGameAsset_AssetBundleManager(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				GameAsset.AssetBundleManager obj = new GameAsset.AssetBundleManager();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: GameAsset.AssetBundleManager.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Initialize(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			obj.Initialize();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetFullManifest(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			UnityEngine.AssetBundleManifest o = obj.GetFullManifest();
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetLoadedAssetBundleDic(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			System.Collections.Generic.Dictionary<string,GameAsset.LoadedAssetBundle> o = obj.GetLoadedAssetBundleDic();
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Reset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.Reset(arg0);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ResetPackage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
			obj.ResetPackage(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int PackageHaveLoad(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
			bool o = obj.PackageHaveLoad(arg0, arg1);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetPackageHaveLoadeds(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
			System.Collections.Generic.List<string> o = obj.GetPackageHaveLoadeds(arg0, arg1);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UnLoadAssetBundle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				obj.UnLoadAssetBundle(arg0);
				return 0;
			}
			else if (count == 3)
			{
				GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				obj.UnLoadAssetBundle(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: GameAsset.AssetBundleManager.UnLoadAssetBundle");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetDependPackages(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			System.Collections.Generic.List<string> o = obj.GetDependPackages(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AssetBundleExist(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.AssetBundleExist(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetBundle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			GameAsset.LoadedAssetBundle o = obj.LoadAssetBundle(arg0);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetBundleAsync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string arg1 = ToLua.CheckString(L, 3);
			System.Action<GameAsset.LoadedAssetBundle> arg2 = (System.Action<GameAsset.LoadedAssetBundle>)ToLua.CheckDelegate<System.Action<GameAsset.LoadedAssetBundle>>(L, 4);
			GameAsset.LoadedAssetBundle o = obj.LoadAssetBundleAsync(arg0, arg1, arg2);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UnLoadLoadedAssetBundle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
				GameAsset.LoadedAssetBundle arg0 = (GameAsset.LoadedAssetBundle)ToLua.CheckObject<GameAsset.LoadedAssetBundle>(L, 2);
				obj.UnLoadLoadedAssetBundle(arg0);
				return 0;
			}
			else if (count == 3)
			{
				GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
				GameAsset.LoadedAssetBundle arg0 = (GameAsset.LoadedAssetBundle)ToLua.CheckObject<GameAsset.LoadedAssetBundle>(L, 2);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				obj.UnLoadLoadedAssetBundle(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
				GameAsset.LoadedAssetBundle arg0 = (GameAsset.LoadedAssetBundle)ToLua.CheckObject<GameAsset.LoadedAssetBundle>(L, 2);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				bool arg2 = LuaDLL.luaL_checkboolean(L, 4);
				obj.UnLoadLoadedAssetBundle(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: GameAsset.AssetBundleManager.UnLoadLoadedAssetBundle");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveFromLoadedDic(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			GameAsset.LoadedAssetBundle arg0 = (GameAsset.LoadedAssetBundle)ToLua.CheckObject<GameAsset.LoadedAssetBundle>(L, 2);
			bool o = obj.RemoveFromLoadedDic(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadBytesFromStreamingAssets(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			byte[] o = GameAsset.AssetBundleManager.LoadBytesFromStreamingAssets(arg0, arg1);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AssetBundleIsLoaded(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.AssetBundleIsLoaded(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaAssetBundleIsLoaded(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.LuaAssetBundleIsLoaded(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AssetBundlesIsLoadedOnly(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string[] arg0 = ToLua.CheckStringArray(L, 2);
			bool o = obj.AssetBundlesIsLoadedOnly(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AssetBundleIsLoadedOnly(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			GameAsset.AssetBundleManager obj = (GameAsset.AssetBundleManager)ToLua.CheckObject<GameAsset.AssetBundleManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.AssetBundleIsLoadedOnly(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetBundleFromFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			UnityEngine.AssetBundle o = GameAsset.AssetBundleManager.LoadAssetBundleFromFile(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAssetBundleFromFileAsync(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			string arg0 = ToLua.CheckString(L, 1);
			UnityEngine.AssetBundleCreateRequest o = GameAsset.AssetBundleManager.LoadAssetBundleFromFileAsync(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

