﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class BestHttpUtilWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("BestHttpUtil");
		L.RegFunction("Create", Create);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Create(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			System.Collections.Generic.Dictionary<string,string> arg2 = (System.Collections.Generic.Dictionary<string,string>)ToLua.CheckObject(L, 3, typeof(System.Collections.Generic.Dictionary<string,string>));
			float arg3 = (float)LuaDLL.luaL_checknumber(L, 4);
			BestHttpOperation o = BestHttpUtil.Create(arg0, arg1, arg2, arg3);
			ToLua.PushObject(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

