using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Networking;
using BestHTTP;
using System.IO;
using System.Threading;


public class AsyncFileOperationData
{
    public string filePath;
    public byte[] content;
    public string method;
    public bool drop;
    public string guid;
}

public static class AsyncFileUtil {
    private static Thread s_thread;
    private static bool s_end;
    private static List<AsyncFileOperationData> s_queue = new List<AsyncFileOperationData>();
    private static Queue<AsyncFileOperationData> s_finished_queue = new Queue<AsyncFileOperationData>();
    public static void StartFileOperationThread()
    {
        s_end = false;
        s_thread = new Thread(new ThreadStart(OperationLoop));
        s_thread.Start();
    }

    public static void EndFileOperationTread()
    {
        s_end = true;
    }

    private static void OperationLoop()
    {
        while(!s_end)
        {
            Thread.Sleep(10);
            lock(s_queue)
            {
                if(s_queue.Count > 0)
                {
                    AsyncFileOperationData operationData = s_queue[0];
                    s_queue.RemoveAt(0);
                    if(!operationData.drop)
                    {
                        if(operationData.method == "delete")
                        {
                            if(FileUtility.Exists(operationData.filePath))
                            {
                                FileUtility.Delete(operationData.filePath);
                            }
                            for(int i = 0; i < s_queue.Count; i++)
                            {
                                if(s_queue[i].filePath == operationData.filePath)
                                {
                                    s_queue[i].drop = true;
                                }
                            }
                        }
                        else if(operationData.method == "append")
                        {
                            FileUtility.SaveFile(operationData.filePath, operationData.content, true);
                        }
                        else if(operationData.method == "write")
                        {
                            FileUtility.SaveFile(operationData.filePath, operationData.content, false);
                        }
                        else if(operationData.method == "readAllBytes")
                        {
                            byte[] bytes = FileUtility.ReadAllBytes(operationData.filePath);
                            operationData.content = bytes;
                            lock(s_finished_queue)
                            {
                                s_finished_queue.Enqueue(operationData);
                            }
                        }
                    }

                }
            }
        }
    }

    public static void AddFileOperationToQueue(string filePath, byte[] content, string method, bool insert = false, string guid = null)
    {
        AsyncFileOperationData operationData = new AsyncFileOperationData();
        operationData.filePath = filePath;
        operationData.content = content;
        operationData.method = method;
        operationData.guid = guid;
        lock(s_queue)
        {
            if(insert)
            {
                s_queue.Insert(0, operationData);
            }
            else
            {
                s_queue.Add(operationData);
            }
        }

        if(s_thread == null)
        {
            StartFileOperationThread();
        }
    }

    public static AsyncFileOperationData GetFinishedAsyncFileOperationData()
    {
        lock(s_finished_queue)
        {
            if(s_finished_queue.Count > 0)
            {
                AsyncFileOperationData operationData = s_finished_queue.Dequeue();
                return operationData;
            }
            return null;
        }
    }
}

