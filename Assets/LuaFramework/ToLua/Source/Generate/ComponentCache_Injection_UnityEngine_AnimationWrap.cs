﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ComponentCache_Injection_UnityEngine_AnimationWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ComponentCache.Injection<UnityEngine.Animation>), typeof(System.Object), "Injection_UnityEngine_Animation");
		L.RegFunction("New", _CreateComponentCache_Injection_UnityEngine_Animation);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("name", get_name, set_name);
		L.RegVar("value", get_value, set_value);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateComponentCache_Injection_UnityEngine_Animation(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				ComponentCache.Injection<UnityEngine.Animation> obj = new ComponentCache.Injection<UnityEngine.Animation>();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: ComponentCache.Injection<UnityEngine.Animation>.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_name(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComponentCache.Injection<UnityEngine.Animation> obj = (ComponentCache.Injection<UnityEngine.Animation>)o;
			string ret = obj.name;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index name on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_value(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComponentCache.Injection<UnityEngine.Animation> obj = (ComponentCache.Injection<UnityEngine.Animation>)o;
			UnityEngine.Animation ret = obj.value;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index value on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_name(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComponentCache.Injection<UnityEngine.Animation> obj = (ComponentCache.Injection<UnityEngine.Animation>)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.name = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index name on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_value(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			ComponentCache.Injection<UnityEngine.Animation> obj = (ComponentCache.Injection<UnityEngine.Animation>)o;
			UnityEngine.Animation arg0 = (UnityEngine.Animation)ToLua.CheckObject(L, 2, typeof(UnityEngine.Animation));
			obj.value = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index value on a nil value");
		}
	}
}

