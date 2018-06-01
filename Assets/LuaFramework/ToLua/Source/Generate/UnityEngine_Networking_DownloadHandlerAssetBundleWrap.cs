﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_Networking_DownloadHandlerAssetBundleWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.Networking.DownloadHandlerAssetBundle), typeof(UnityEngine.Networking.DownloadHandler));
		L.RegFunction("GetContent", GetContent);
		L.RegFunction("New", _CreateUnityEngine_Networking_DownloadHandlerAssetBundle);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("assetBundle", get_assetBundle, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_Networking_DownloadHandlerAssetBundle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				uint arg1 = (uint)LuaDLL.luaL_checknumber(L, 2);
				UnityEngine.Networking.DownloadHandlerAssetBundle obj = new UnityEngine.Networking.DownloadHandlerAssetBundle(arg0, arg1);
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes<UnityEngine.Hash128, uint>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				UnityEngine.Hash128 arg1 = StackTraits<UnityEngine.Hash128>.To(L, 2);
				uint arg2 = (uint)LuaDLL.lua_tonumber(L, 3);
				UnityEngine.Networking.DownloadHandlerAssetBundle obj = new UnityEngine.Networking.DownloadHandlerAssetBundle(arg0, arg1, arg2);
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes<uint, uint>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				uint arg1 = (uint)LuaDLL.lua_tonumber(L, 2);
				uint arg2 = (uint)LuaDLL.lua_tonumber(L, 3);
				UnityEngine.Networking.DownloadHandlerAssetBundle obj = new UnityEngine.Networking.DownloadHandlerAssetBundle(arg0, arg1, arg2);
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else if (count == 4)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				UnityEngine.Hash128 arg2 = StackTraits<UnityEngine.Hash128>.Check(L, 3);
				uint arg3 = (uint)LuaDLL.luaL_checknumber(L, 4);
				UnityEngine.Networking.DownloadHandlerAssetBundle obj = new UnityEngine.Networking.DownloadHandlerAssetBundle(arg0, arg1, arg2, arg3);
				ToLua.PushSealed(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.Networking.DownloadHandlerAssetBundle.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetContent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.Networking.UnityWebRequest arg0 = (UnityEngine.Networking.UnityWebRequest)ToLua.CheckObject<UnityEngine.Networking.UnityWebRequest>(L, 1);
			UnityEngine.AssetBundle o = UnityEngine.Networking.DownloadHandlerAssetBundle.GetContent(arg0);
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_assetBundle(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.Networking.DownloadHandlerAssetBundle obj = (UnityEngine.Networking.DownloadHandlerAssetBundle)o;
			UnityEngine.AssetBundle ret = obj.assetBundle;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index assetBundle on a nil value");
		}
	}
}

