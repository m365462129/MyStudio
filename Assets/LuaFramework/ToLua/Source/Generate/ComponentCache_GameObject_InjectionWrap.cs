﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ComponentCache_GameObject_InjectionWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ComponentCache.GameObject_Injection), typeof(ComponentCache.Injection<UnityEngine.GameObject>));
		L.RegFunction("New", _CreateComponentCache_GameObject_Injection);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateComponentCache_GameObject_Injection(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				ComponentCache.GameObject_Injection obj = new ComponentCache.GameObject_Injection();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: ComponentCache.GameObject_Injection.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

