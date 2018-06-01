﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class DNet_VideoDataWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(DNet.VideoData), typeof(System.Object));
		L.RegFunction("New", _CreateDNet_VideoData);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("frames", get_frames, set_frames);
		L.RegVar("rule", get_rule, set_rule);
		L.RegVar("headData", get_headData, set_headData);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateDNet_VideoData(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				DNet.VideoData obj = new DNet.VideoData();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: DNet.VideoData.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_frames(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			DNet.VideoData obj = (DNet.VideoData)o;
			System.Collections.Generic.List<DNet.VideoFrameData> ret = obj.frames;
			ToLua.PushSealed(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index frames on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_rule(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			DNet.VideoData obj = (DNet.VideoData)o;
			string ret = obj.rule;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rule on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_headData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			DNet.VideoData obj = (DNet.VideoData)o;
			byte[] ret = obj.headData;
			LuaDLL.tolua_pushlstring(L, ret, ret.Length);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index headData on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_frames(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			DNet.VideoData obj = (DNet.VideoData)o;
			System.Collections.Generic.List<DNet.VideoFrameData> arg0 = (System.Collections.Generic.List<DNet.VideoFrameData>)ToLua.CheckObject(L, 2, typeof(System.Collections.Generic.List<DNet.VideoFrameData>));
			obj.frames = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index frames on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_rule(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			DNet.VideoData obj = (DNet.VideoData)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.rule = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index rule on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_headData(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			DNet.VideoData obj = (DNet.VideoData)o;
			byte[] arg0 = ToLua.CheckByteBuffer(L, 2);
			obj.headData = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index headData on a nil value");
		}
	}
}

