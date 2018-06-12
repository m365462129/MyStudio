﻿/*****************************************************
 * 作者: DRed(龙涛) 1036409576@qq.com
 * 创建时间：2015.2.4
 * 版本：1.0.0
 * 描述：时间工具，主要是各种格式的转换

 // C# 日期格式 
DateTime dt = DateTime.Now;

dt.ToString();//2005-11-5 13:21:25 
dt.ToFileTime().ToString();//127756416859912816 
dt.ToFileTimeUtc().ToString();//127756704859912816 
dt.ToLocalTime().ToString();//2005-11-5 21:21:25 
dt.ToLongDateString().ToString();//2005年11月5日 
dt.ToLongTimeString().ToString();//13:21:25 
dt.ToOADate().ToString();//38661.5565508218 
dt.ToShortDateString().ToString();//2005-11-5 
dt.ToShortTimeString().ToString();//13:21 
dt.ToUniversalTime().ToString();//2005-11-5 5:21:25 
dt.Year.ToString();//2005 
dt.Date.ToString();//2005-11-5 0:00:00 
dt.DayOfWeek.ToString();//Saturday 
dt.DayOfYear.ToString();//309 
dt.Hour.ToString();//13 
dt.Millisecond.ToString();//441 
dt.Minute.ToString();//30 
dt.Month.ToString();//11 
dt.Second.ToString();//28 
dt.Ticks.ToString();//632667942284412864 
dt.TimeOfDay.ToString();//13:30:28.4412864 
dt.ToString();//2005-11-5 13:47:04 
dt.AddYears(1).ToString();//2006-11-5 13:47:04 
dt.AddDays(1.1).ToString();//2005-11-6 16:11:04 
dt.AddHours(1.1).ToString();//2005-11-5 14:53:04 
dt.AddMilliseconds(1.1).ToString();//2005-11-5 13:47:04 
dt.AddMonths(1).ToString();//2005-12-5 13:47:04 
dt.AddSeconds(1.1).ToString();//2005-11-5 13:47:05 
dt.AddMinutes(1.1).ToString();//2005-11-5 13:48:10 
dt.AddTicks(1000).ToString();//2005-11-5 13:47:04 
dt.CompareTo(dt).ToString();//0 
dt.Add(?).ToString();//问号为一个时间段 
dt.Equals("2005-11-6 16:11:04").ToString();//False 
dt.Equals(dt).ToString();//True 
dt.GetHashCode().ToString();//1474088234 
dt.GetType().ToString();//System.DateTime 
dt.GetTypeCode().ToString();//DateTime 
   
dt.GetDateTimeFormats('s')[0].ToString();//2005-11-05T14:06:25 
dt.GetDateTimeFormats('t')[0].ToString();//14:06 
dt.GetDateTimeFormats('y')[0].ToString();//2005年11月 
dt.GetDateTimeFormats('D')[0].ToString();//2005年11月5日 
dt.GetDateTimeFormats('D')[1].ToString();//2005 11 05 
dt.GetDateTimeFormats('D')[2].ToString();//星期六 2005 11 05 
dt.GetDateTimeFormats('D')[3].ToString();//星期六 2005年11月5日 
dt.GetDateTimeFormats('M')[0].ToString();//11月5日 
dt.GetDateTimeFormats('f')[0].ToString();//2005年11月5日 14:06 
dt.GetDateTimeFormats('g')[0].ToString();//2005-11-5 14:06 
dt.GetDateTimeFormats('r')[0].ToString();//Sat, 05 Nov 2005 14:06:25 GMT

string.Format("{0:d}",dt);//2005-11-5 
string.Format("{0:D}",dt);//2005年11月5日 
string.Format("{0:f}",dt);//2005年11月5日 14:23 
string.Format("{0:F}",dt);//2005年11月5日 14:23:23 
string.Format("{0:g}",dt);//2005-11-5 14:23 
string.Format("{0:G}",dt);//2005-11-5 14:23:23 
string.Format("{0:M}",dt);//11月5日 
string.Format("{0:R}",dt);//Sat, 05 Nov 2005 14:23:23 GMT 
string.Format("{0:s}",dt);//2005-11-05T14:23:23 
string.Format("{0:t}",dt);//14:23 
string.Format("{0:T}",dt);//14:23:23 
string.Format("{0:u}",dt);//2005-11-05 14:23:23Z 
string.Format("{0:U}",dt);//2005年11月5日 6:23:23 
string.Format("{0:Y}",dt);//2005年11月 
string.Format("{0}",dt);//2005-11-5 14:23:23

string.Format("{0:yyyyMMddHHmmssffff}",dt);
 ****************************************************/

using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Xml.Serialization;
using UnityEngine;
using UnityEngineInternal;


static public class TimeUtility
{
    public struct Units
    {
        public int hours;
        public int minutes;
        public int seconds;
        public int deciSeconds;     // a.k.a. 'tenths of a second'
        public int centiSeconds;    // a.k.a. 'hundredths of a second'
        public int milliSeconds;

    }

    /// <summary>
    /// 转成DataTime
    /// </summary>
    /// <param name="timeStamp"> 时间戳</param>
    public static DateTime ToDataTime(long timeStamp)
    {
        DateTime dtStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        //TimeSpan now = new TimeSpan(timeStamp);
        dtStart = dtStart.AddSeconds(timeStamp);
        return dtStart;
    }

    /// <summary>
    /// 获取Unix 时间戳
    /// </summary>
    /// <param name="dataTime"></param>
    public static long ToTimestamp(DateTime dataTime)
    {
        long time = (dataTime.ToUniversalTime().Ticks - 621355968000000000) / 10000000;
        return time;
    }

    /// <summary>
    /// 获取Unix 时间戳
    /// </summary>
    public static long nowToTimestamp
    {
        get { return (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000; }
    }

    /// <summary>
    /// 获取下一整点时刻Unix时间戳
    /// </summary>
    public static long nextWholeTimestamp
    {
        get
        {
            DateTime now = DateTime.Now;
            int second = (59 - now.Minute) * 60;
            second += 60 - now.Second;
            now = now.AddSeconds(second);
            return ToTimestamp(now);
        }
    }

    /// <summary>
    /// 获取某一时刻的Unix时间戳，如果是隔天，hour+24
    /// </summary>
    /// <param name="hour">时</param>
    /// <param name="minute">分</param>
    /// <param name="second">秒</param>
    /// <returns></returns>
    public static long somTimestamp(int hour = 0, int minute = 0, int second = 0)
    {
        DateTime now = DateTime.Now;
        int seconds = (hour - now.Hour - 1) * 3600 + (59 - now.Minute) * 60 + second - now.Second;
        now = now.AddSeconds(seconds);
        return ToTimestamp(now);
    }

    /// <summary>
    /// 获取下一个0点时刻Unix时间戳
    /// </summary>
    public static long nextZeroTimestamp
    {
        get
        {
            DateTime now = DateTime.Now;
            int second = (23 - now.Hour) * 3600 + (59 - now.Minute) * 60;
            second += 60 - now.Second;
            now = now.AddSeconds(second);
            return ToTimestamp(now);
        }
    }

    /// <summary>
    /// 获取上一个0点时刻Unix时间戳
    /// </summary>
    public static long lastZeroTimestamp
    {
        get
        {
            return nextZeroTimestamp - 24 * 3600;
        }
    }


    public static Units TimeToUnits(float timeInSeconds)
    {
        if (timeInSeconds < 0) {
            timeInSeconds = 0;
        }
        Units iTime = new Units();

        iTime.hours = ((int)timeInSeconds) / 3600;
        iTime.minutes = (((int)timeInSeconds) - (iTime.hours * 3600)) / 60;
        iTime.seconds = ((int)timeInSeconds) % 60;

        iTime.deciSeconds = (int)((timeInSeconds - iTime.seconds) * 10) % 60;
        iTime.centiSeconds = (int)((timeInSeconds - iTime.seconds) * 100 % 600);
        iTime.milliSeconds = (int)((timeInSeconds - iTime.seconds) * 1000 % 6000);

        return iTime;

    }


    /// <summary>
    /// takes a 'Units' struct and returns a floating point uptime in
    /// seconds.
    /// </summary>
    public static float UnitsToSeconds(Units units)
    {

        float seconds = 0.0f;

        seconds += units.hours * 3600;
        seconds += units.minutes * 60;
        seconds += units.seconds;

        seconds += units.deciSeconds * 0.1f;
        seconds += units.centiSeconds / 100;
        seconds += units.milliSeconds / 1000;

        return seconds;

    }



    public static string TimeToString(long timeInSeconds, bool showHours = true, bool showMinutes = true, bool showSeconds = true, char delimiter = ':')
    {
        Units iTime = TimeToUnits(timeInSeconds);
        StringBuilder text = new StringBuilder();
        if (showHours)
        {
            showMinutes = true;
            text.Append(iTime.hours.ToString("0#"));
            text.Append(delimiter);
        }
        if (showMinutes)
        {
            showSeconds = true;
            text.Append(iTime.minutes.ToString("0#"));
            text.Append(delimiter);
        }

        if (showSeconds)
        {
            text.Append(iTime.seconds.ToString("0#"));
        }
        return text.ToString();
    }

    //传入的是时间差
    public static string TimeToChineseString(int timeInSeconds)
    {
        TimeSpan timeSpan = new TimeSpan(0, 0, 0, timeInSeconds);
        StringBuilder text = new StringBuilder();
        bool show = false;
        if (timeSpan.Days > 0)
        {
            show = true;
            text.Append(timeSpan.Days.ToString("0#"));
            text.Append("天");
        }
        if (show || timeSpan.Hours > 0)
        {
            show = true;
            text.Append(timeSpan.Hours.ToString("0#"));
            text.Append("时");
        }
        if (show || timeSpan.Minutes > 0)
        {
            show = true;
            text.Append(timeSpan.Minutes.ToString("0#"));
            text.Append("分");
        }
        text.Append(timeSpan.Seconds.ToString("0#"));
        text.Append("秒");
        return text.ToString();
    }
    public static string StampToTime(int timeInSeconds)
    {
        DateTime dateTimeStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        return dateTimeStart.AddSeconds(timeInSeconds).ToString("yyyy年MM月dd日");

    }

    public static string StampToTimeTable(int timeInSeconds)
    {
        TimeSpan timeSpan = new TimeSpan(0, 0, 0, timeInSeconds);
        return timeSpan.ToString();

    }
    public static string StampToTime2(int timeInSeconds)
    {
        DateTime dateTimeStart = TimeZone.CurrentTimeZone.ToLocalTime(new DateTime(1970, 1, 1));
        return dateTimeStart.AddSeconds(timeInSeconds).ToString("yyyy年MM月dd日hh时mm分ss秒");

    }

    public static Units SystemTimeToUnits(System.DateTime systemTime)
    {

        Units iTime = new Units();

        iTime.hours = systemTime.Hour;
        iTime.minutes = systemTime.Minute;
        iTime.seconds = systemTime.Second;
        iTime.deciSeconds = (int)(systemTime.Millisecond / 100.0f);
        iTime.centiSeconds = (int)(systemTime.Millisecond / 10);
        iTime.milliSeconds = systemTime.Millisecond;

        return iTime;

    }


    public static Units SystemTimeToUnits()
    {
        return SystemTimeToUnits(System.DateTime.Now);
    }


    public static float SystemTimeToSeconds(System.DateTime systemTime)
    {

        return UnitsToSeconds(SystemTimeToUnits(systemTime));

    }

    public static float SystemTimeToSeconds()
    {
        return SystemTimeToSeconds(System.DateTime.Now);
    }

    /// <summary>
    /// 聊天时间格式  12：22， 4-2 12：22
    /// </summary>
    /// <param name="t"></param>
    /// <returns></returns>
    public static string ChatTimeFormat(long t)
    {
        DateTime dataTime = SmartTimer.instance.StampToDateTime(t);
        int chatday = int.Parse(dataTime.ToString("dd"));

        long nowstamp = nowToTimestamp - SmartTimer.instance.serverTimeDiff;
        DateTime nowTime = SmartTimer.instance.StampToDateTime(nowstamp);
        int nowday = int.Parse(nowTime.ToString("dd"));
        return dataTime.ToString(nowday == chatday ? "HH:mm" : "MM-dd HH:mm");
    }

    /// <summary>
    /// email时间格式  2016-06-21
    /// </summary>
    /// <param name="t"></param>
    public static string EmailTimeFomat(long t)
    {
        DateTime dataTime = SmartTimer.instance.StampToDateTime(t);
        return dataTime.ToString("yyyy-MM-dd HH:mm");
    }

    /// <summary>
    ///牌局实时数据格式 hh:mm:ss
    /// </summary>
    /// <param name="t"></param>
    public static string RealTimeFomat(int t)
    {
        TimeSpan timeSpan = new TimeSpan(0, 0, 0, t);
        return timeSpan.ToString();
        //DateTime dataTime = new DateTime(t);
        //return dataTime.ToString("HH:mm:ss");
    }
    /// <summary>
    /// 创建mtt时间格式
    /// </summary>
    /// <param name="t"></param>
    public static string[] CreatMttTimeFomat(long t)
    {
        DateTime dataTime = SmartTimer.instance.StampToDateTime(t);
        return new[] { dataTime.ToString("yyyy-MM-dd"), dataTime.ToString("HH:mm") };
    }
    /// <summary>
    /// 创建mtt时间格式
    /// </summary>
    /// <param name="t"></param>
    public static int[] CreatMttTimeFomatToInt(long t)
    {
        DateTime dataTime = SmartTimer.instance.StampToDateTime(t);
        return new[] { int.Parse(dataTime.ToString("yyyy")), int.Parse(dataTime.ToString("MM")), int.Parse(dataTime.ToString("dd")), int.Parse(dataTime.ToString("HH")), int.Parse(dataTime.ToString("mm")) };
    }

    public static long CreatMttTimeIntToStamp(int[] s)
    {
        DateTime dateTime = new DateTime(s[0], s[1], s[2], s[3], s[4], 0);
        return ToTimestamp(dateTime);
    }
    public static long RecordTimeIntToStamp(int[] s)
    {
        DateTime dateTime = new DateTime(s[0], s[1], s[2], 0, 0, 0);
        return ToTimestamp(dateTime);
    }
    public static string RecordTimeFormat(long t)
    {
        DateTime dataTime = SmartTimer.instance.StampToDateTime(t);
        return dataTime.ToString("yy/MM/dd");
    }

    public static int MonthsHaveDays(int year, int month)
    {
        //DateTime dtNow = DateTime.Now;

        return DateTime.DaysInMonth(year, month);
    }


    ///// <summary>
    ///// 秒转时间格式  xx小时xx分钟
    ///// </summary>
    ///// <param name="t"></param>
    ///// <returns></returns>
    //public static string ChineseTimeFormat(int t)
    //{
    //    int s = t % 60;  //剩余秒
    //    int allm = t / 60;  //剩余所有分钟
    //    int m = allm % 60;  //剩余分钟
    //    int h = allm / 60; //剩余小时
    //    return h == 0
    //        ? string.Format(DataConfig.instance.getLocalization(ModuleID.Game, "Time1"), m > 0 ? m : 1)
    //        : string.Format(DataConfig.instance.getLocalization(ModuleID.Game, "Time2"), h, m);
    //}


    public static long TimestampToDayStamp(long timestamp)
    {
        int year = SmartTimer.instance.StampToDateTime(timestamp).Year;
        int month = SmartTimer.instance.StampToDateTime(timestamp).Month;
        int day = SmartTimer.instance.StampToDateTime(timestamp).Day;
        DateTime dateTime = new DateTime(year, month, day);
        return ToTimestamp(dateTime);
    }
}
