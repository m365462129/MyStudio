﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class ComponentCache_SpriteAtlas_InjectionWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(ComponentCache.SpriteAtlas_Injection), typeof(ComponentCache.Injection<SpriteAtlas>));
		L.RegFunction("New", _CreateComponentCache_SpriteAtlas_Injection);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateComponentCache_SpriteAtlas_Injection(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				ComponentCache.SpriteAtlas_Injection obj = new ComponentCache.SpriteAtlas_Injection();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: ComponentCache.SpriteAtlas_Injection.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

