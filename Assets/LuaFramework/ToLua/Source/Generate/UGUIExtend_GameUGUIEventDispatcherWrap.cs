﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UGUIExtend_GameUGUIEventDispatcherWrap
{
	public static void Register(LuaState L)
	{
		L.BeginStaticLibs("GameUGUIEventDispatcher");
		L.RegFunction("onCustomerHandle", onCustomerHandle);
		L.RegFunction("onPressHandle", onPressHandle);
		L.RegFunction("onPressUpHandle", onPressUpHandle);
		L.RegFunction("onClickHandle", onClickHandle);
		L.RegFunction("onEndDragHandle", onEndDragHandle);
		L.RegFunction("onBeginDragHandle", onBeginDragHandle);
		L.RegFunction("onDragHandle", onDragHandle);
		L.RegFunction("onDropHandle", onDropHandle);
		L.RegFunction("onSelectHandle", onSelectHandle);
		L.RegFunction("onCancelHandle", onCancelHandle);
		L.RegFunction("RemoveAllEvents", RemoveAllEvents);
		L.RegVar("onCustomerFn", get_onCustomerFn, set_onCustomerFn);
		L.RegVar("onPressFn", get_onPressFn, set_onPressFn);
		L.RegVar("onClickFn", get_onClickFn, set_onClickFn);
		L.RegVar("onDragFn", get_onDragFn, set_onDragFn);
		L.RegVar("onEndDragFn", get_onEndDragFn, set_onEndDragFn);
		L.RegVar("onBeginDragFn", get_onBeginDragFn, set_onBeginDragFn);
		L.RegVar("onDropFn", get_onDropFn, set_onDropFn);
		L.RegVar("onSelectFn", get_onSelectFn, set_onSelectFn);
		L.RegVar("onCancelFn", get_onCancelFn, set_onCancelFn);
		L.RegVar("onPressUpFn", get_onPressUpFn, set_onPressUpFn);
		L.EndStaticLibs();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onCustomerHandle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 4 && TypeChecker.CheckTypes<UnityEngine.Vector3>(L, 4))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				UnityEngine.Vector3 arg3 = ToLua.ToVector3(L, 4);
				UGUIExtend.GameUGUIEventDispatcher.onCustomerHandle(arg0, arg1, arg2, arg3);
				return 0;
			}
			else if (count == 4 && TypeChecker.CheckTypes<object>(L, 4))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				object arg3 = ToLua.ToVarObject(L, 4);
				UGUIExtend.GameUGUIEventDispatcher.onCustomerHandle(arg0, arg1, arg2, arg3);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UGUIExtend.GameUGUIEventDispatcher.onCustomerHandle");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onPressHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onPressHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onPressUpHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onPressUpHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onClickHandle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				UGUIExtend.GameUGUIEventDispatcher.onClickHandle(arg0, arg1, arg2);
				return 0;
			}
			else if (count == 4)
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				object arg3 = ToLua.ToVarObject(L, 4);
				UGUIExtend.GameUGUIEventDispatcher.onClickHandle(arg0, arg1, arg2, arg3);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UGUIExtend.GameUGUIEventDispatcher.onClickHandle");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onEndDragHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onEndDragHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onBeginDragHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onBeginDragHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onDragHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onDragHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onDropHandle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 4 && TypeChecker.CheckTypes<UnityEngine.Vector3>(L, 4))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				UnityEngine.Vector3 arg3 = ToLua.ToVector3(L, 4);
				UGUIExtend.GameUGUIEventDispatcher.onDropHandle(arg0, arg1, arg2, arg3);
				return 0;
			}
			else if (count == 4 && TypeChecker.CheckTypes<bool>(L, 4))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				bool arg3 = LuaDLL.lua_toboolean(L, 4);
				UGUIExtend.GameUGUIEventDispatcher.onDropHandle(arg0, arg1, arg2, arg3);
				return 0;
			}
			else if (count == 4 && TypeChecker.CheckTypes<object>(L, 4))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.CheckString(L, 2);
				object arg2 = ToLua.ToVarObject(L, 3);
				object arg3 = ToLua.ToVarObject(L, 4);
				UGUIExtend.GameUGUIEventDispatcher.onDropHandle(arg0, arg1, arg2, arg3);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: UGUIExtend.GameUGUIEventDispatcher.onDropHandle");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onSelectHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onSelectHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int onCancelHandle(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			string arg0 = ToLua.CheckString(L, 1);
			string arg1 = ToLua.CheckString(L, 2);
			object arg2 = ToLua.ToVarObject(L, 3);
			object arg3 = ToLua.ToVarObject(L, 4);
			UGUIExtend.GameUGUIEventDispatcher.onCancelHandle(arg0, arg1, arg2, arg3);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveAllEvents(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 0);
			UGUIExtend.GameUGUIEventDispatcher.RemoveAllEvents();
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onCustomerFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onCustomerFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPressFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onPressFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onClickFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onClickFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDragFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onDragFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onEndDragFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onEndDragFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onBeginDragFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onBeginDragFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onDropFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onDropFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onSelectFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onSelectFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onCancelFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onCancelFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_onPressUpFn(IntPtr L)
	{
		try
		{
			ToLua.PushObject(L, UGUIExtend.GameUGUIEventDispatcher.onPressUpFn);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onCustomerFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onCustomerFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPressFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onPressFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onClickFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onClickFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDragFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onDragFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onEndDragFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onEndDragFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onBeginDragFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onBeginDragFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onDropFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onDropFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onSelectFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onSelectFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onCancelFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onCancelFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_onPressUpFn(IntPtr L)
	{
		try
		{
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			UGUIExtend.GameUGUIEventDispatcher.onPressUpFn = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

