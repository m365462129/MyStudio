// //#define _Debug_Open

// /*****************************************************
//  * 作者: DRed(龙涛) 1036409576@qq.com
//  * 创建时间：2015.3.1
//  * 版本：0.5.0
//  * 描述：TCP协议
//  ****************************************************/


// using System;
// using System.Collections.Generic;
// using System.Net.Sockets;
// using System.Threading;
// using UnityEngine;

// namespace DNet
// {

//     public class Protocol
//     {
//         // 接收的缓冲，如果一次接收的包超过这个大小，会自动做粘包处理
//         byte[] mRecvBytesTemp = new byte[8096];

//         /// <summary> 最小服务器的有效包,和服务器约定有关</summary>
//         public readonly int packetLenMin;

//         /// <summary> 包长字段在包头的偏移位置(数组的下标) </summary>
//         public readonly int packetHeadLenOffest;

//         /// <summary> 服务器与客户端的秒数差。正数代表服务器比本地时间慢，负数代表快 </summary>
//         public static int ServerTimeDiff;

//         private bool mOnReceiving;

//         /// <summary> 收取服务器的信息缓存 </summary>
//         Queue<Buffer> mNeedRece = new Queue<Buffer>();
//         /// <summary> 给服务器发送信息缓存 </summary>
//         Queue<Buffer> mNeedSend = new Queue<Buffer>();  
//         // Current incoming buffer
//         Buffer mReceiveBuffer;
//         int mExpected;
//         int mOffset;
//         Socket mSocket;
//         bool mNoDelay = false;

//         internal Action<string> onDisconnect;

//         private GameNetClient mGameNetClient;

//         /// <summary> 接收线程 </summary>
//         Thread mReceiveThread;
//         /// <summary> 发送线程 </summary>
//         Thread mSendThread;
//         /// <summary> 接收的间隔(毫秒) </summary>
//         int mReceiveThreadInterval = 2;
//         /// <summary> 发送的间隔(毫秒) </summary>
//         int mSendThreadInterval = 2;
//         /// <summary> 接收线程的状态 </summary>
//         bool mReceiveThreadState = true;
//         /// <summary> 接收线程的状态 </summary>
//         bool mSendThreadState = true;

//         int msgProtocolType = 1;

//         public Protocol(GameNetClient gameNetClient, Socket socket) {
//             mGameNetClient = gameNetClient;
//             msgProtocolType = gameNetClient.msgProtocolType;
//             if (msgProtocolType == 3) {  
//                 packetLenMin = 2;
//                 packetHeadLenOffest = 0;

//             } else {   //|命令(4)|长度(4)（只有数据长度）|数据块| 和发包不同
//                 packetLenMin = TagHeadType1.PACK_HEAD_SIZE;
//                 packetHeadLenOffest = TagHeadType1.PACK_LENGTH_OFFSET;
//             }
        
//             onDisconnect = OnDisconnect;
//             mSocket = socket;
//             SendAndReceive();
//         }

//         public bool Send(Buffer buffer) {
//             if (mSocket != null) {
//                 buffer.BeginReading();
//                 lock (mNeedSend) {
//                     mNeedSend.Enqueue(buffer); //进入队列
//                 }
//                 if (GameConfigProject.instance.netLogSendServerShow && buffer.messageName != mGameNetClient.heartMsgId) {
//                     Debug.Log(string.Format("<color=#CC99CC>C# 给【{0}】服务器发包【{1}】【{2}】</color>", mGameNetClient.clientName, buffer.messageName, buffer.size));
//                 }
//                 return true;
//             }
//             buffer.Recycle();
//             return false;
//         }

//         /// <summary> 发送消息包的线程 </summary>
//         void ThreadSend() {
// #if _Debug_Open
//             //DebugInfo(string.Format("{0}:{1}设置发包函数成功【ThreadReceive】堆栈:\n{2}", tcpEndPoint.Address, tcpEndPoint.Port, HelpFun.OutputCallStack())); 
// #endif
//             mSendThreadState = true;
//             Socket curReceiveSocket = mSocket;
//             int needSendPocketCount = 0;
//             Buffer sendBuffer;
//             try {
//                 while (mSendThreadState) {
//                     Thread.Sleep(mSendThreadInterval);
//                     do {
//                         lock (mNeedSend) {
//                             needSendPocketCount = mNeedSend.Count;
//                             if (needSendPocketCount == 0) { //是否有需要发的包
//                                 continue;
//                             }
//                             sendBuffer = mNeedSend.Dequeue();
//                         }
//                         SocketError errorCode;
//                         curReceiveSocket.Send(sendBuffer.buffer, sendBuffer.position, sendBuffer.size, SocketFlags.None, out errorCode);
//                         // Debug.Log(errorCode + " " + sendBuffer.messageName);
//                         //会写到缓存区里，但是如果缓存区满了就会阻塞
//                         if (errorCode != SocketError.Success) {
//                             if (mSocket == curReceiveSocket) {
//                             if (onDisconnect != null)
//                                 onDisconnect("socket send error, error code = " + errorCode);
//                             }
//                         }
//                         sendBuffer.Recycle();
//                     } while (needSendPocketCount > 1);
//                 }
//             } catch (SocketException e) {
//                 if (mSocket == curReceiveSocket) {
//                     if (onDisconnect != null)
//                         onDisconnect("socket send exception: " + e.ToString());
//                 }
//             }
//             mSendThreadState = false;
//         }

//         /// <summary> 接收消息包的线程 </summary>
//         void ThreadReceive() {
// #if _Debug_Open
//             //DebugInfo(string.Format("{0}:{1}设置收包函数成功【ThreadReceive】堆栈:\n{2}", tcpEndPoint.Address, tcpEndPoint.Port, HelpFun.OutputCallStack())); 
// #endif
//             mReceiveThreadState = true;
//             int receiveBytes = 0;

//             if (mReceiveBuffer != null) {
//                 mReceiveBuffer.Recycle();
//             }
//             mReceiveBuffer = null;
//             mExpected = 0;  //重新收包需要把这个置为空。但此处有个问题，比如在收某个包的时候关闭了
//             mOffset = 0;
//             Socket curReceiveSocket = mSocket;

//             try {
//                 while (mReceiveThreadState) {
//                     Thread.Sleep(mReceiveThreadInterval);
//                     //如果远程主机处于关机状态或关闭了连接，则 Available 会引发 SocketException。 如果收到 SocketException，请使用 SocketException.ErrorCode 属性获取特定的错误代码。 
//                     //建议在非阻塞模式下启用
//                     //if (mSocket.Available <= 0) {
//                     //    continue;
//                     //}
//                     receiveBytes = curReceiveSocket.Receive(mRecvBytesTemp);     //用receive方法接收的包不一定是完整包，有可能是部分包。所以需要做合包处理
//                     //Debug.LogError(string.Format("{0}:{1}接到包的字节为{2}!", tcpEndPoint.Address, tcpEndPoint.Port, receiveBytes));
//                     if (receiveBytes <= 0) {
//                         mReceiveBuffer = null;
//                         mExpected = 0;  //重新收包需要把这个置为空。但此处有个问题，比如在收某个包的时候关闭了
//                         mOffset = 0;
//                         if (mSocket == curReceiveSocket) {
//                             if (onDisconnect != null)
//                                 onDisconnect("socket error : receiveBytes == 0");
//                         }
//                     } else {
//                         ProcessBuffer(receiveBytes);
//                     }
//                 }
//             } catch (SocketException e) {
//                 if (mSocket == curReceiveSocket) {
//                     if (onDisconnect != null)
//                         onDisconnect(e.ToString());
//                 }
//             }
//             mReceiveThreadState = false;
//         }

//         public void EnqueuePacker(Buffer buffer) {
//             lock (mNeedRece) {
//                 mNeedRece.Enqueue(buffer);
//             }
//         }

//         public bool ReceivePacket(out Buffer buffer) {
//             lock (mNeedRece) {
//                 if (mNeedRece.Count != 0) {
//                     buffer = mNeedRece.Dequeue();
//                     return true;
//                 }
//             }
//             buffer = null;
//             return false;
//         }

//         public int GetNeedRecePacketsNum()
//         {
//             lock (mNeedRece)
//             {
//                 return mNeedRece.Count;
//             }
//         }


//         public void SendAndReceive() {
//             mReceiveThread = new Thread(ThreadReceive);
//             mReceiveThread.IsBackground = true;
//             mReceiveThreadState = true;
//             mReceiveThread.Start();

//             mSendThread = new Thread(ThreadSend);
//             mSendThread.IsBackground = true;
//             mSendThreadState = true;
//             mSendThread.Start(); 
//         }

//         private bool ProcessBuffer(int bytes) {
//             if (mReceiveBuffer == null) {
//                 mReceiveBuffer = Buffer.Create(msgProtocolType);
//                 mReceiveBuffer.BeginWriting(false).Write(mRecvBytesTemp, 0, bytes);
//             } else {
//                 mReceiveBuffer.BeginWriting(true).Write(mRecvBytesTemp, 0, bytes);      //如果之前的包没处理完全，则继续添加
//             }
//             // Debug.LogFormat("ProcessBuffer bytes={0} expected={1}", bytes,  mExpected);
//             //首先判断是否收满了一个完整包的最小长度
//             for (int available = mReceiveBuffer.size - mOffset; mReceiveThreadState && available >= packetLenMin;) {
//                 //计算一个完整包的长度，包括包头和包尾
//                 if (mExpected == 0) {
//                     if (msgProtocolType == 1 || msgProtocolType == 2) {
//                         mExpected = (int)mReceiveBuffer.PeekUInt32(mOffset + packetHeadLenOffest) + packetLenMin;    //收到的包第3-7个字节为包的长度(不包括包头)             
//                         // Debug.LogWarning(string.Format("cmd: {3}  -- mExpected大小：{0}  --  available大小：{1} -- packetLenMin{2}", mExpected, available,  packetLenMin, mReceiveBuffer.PeekUInt32(0)));
//                     } else {
//                         mExpected = mReceiveBuffer.PeekUInt16(mOffset + packetHeadLenOffest, true) + packetLenMin;               //收到的包第0-1个字节为整个包包的长度
//                         // Debug.LogFormat("bytes={0} expected={1}", bytes,  mExpected);
//                     }
//                 }
                

//                 //正好是一个完整包
//                 if (available == mExpected) {
//                     if (mOffset > 0) {  //如果是多个包的最后一个包
//                         // Extract the packet and move past its size component
//                         mReceiveBuffer.BeginWriting(false).Write(mReceiveBuffer.buffer, mOffset, (int)mExpected);
//                     }

//                     //mReceiveBuffer.buffer[mReceiveBuffer.size] = 0;
//                     EnqueuePacker(mReceiveBuffer);
//                     mReceiveBuffer = null;
//                     mExpected = 0;
//                     mOffset = 0;
//                     break;
//                 }
//                 if (available > mExpected)     //收到大于一个包
//                 {
//                     int realSize = mExpected;
//                     Buffer temp = Buffer.Create(msgProtocolType);

//                     // Extract the packet and move past its size component
//                     temp.BeginWriting(false).Write(mReceiveBuffer.buffer, mOffset, realSize);

//                     // This packet is now ready to be processed
//                     EnqueuePacker(temp);

//                     temp = null;
//                     available -= mExpected;
//                     mOffset += realSize;
//                     //Debug.Log(string.Format("TCP一次收包大于1个包数据:mExpected:{0}available:{1}moffest:{2}mReceiveBuffer.size:{3}，服务器地址:{4}:{5}!包的内容【{6}】", mExpected, available, mOffset, mReceiveBuffer.size, tcpEndPoint.Address, tcpEndPoint.Port, ArrayToString(mReceiveBuffer.buffer)));
//                     mExpected = 0;
//                 } else {
//                     //DebugInfo(string.Format("TCP不够一个包的数据:mExpected:{0}available:{1}moffest:{2}mReceiveBuffer.size:{3}，服务器地址:{4}:{5}!包的内容【{6}】", mExpected, available, mOffset, mReceiveBuffer.size, tcpEndPoint.Address, tcpEndPoint.Port, ArrayToString(mReceiveBuffer.buffer)));
//                     break;
//                 }
//             }
//             return true;
//         }

//         public void Dispose() {
//             mReceiveThreadState = false;
//             mSendThreadState = false;
//             if (mReceiveThread != null && mReceiveThread.IsAlive) {
//                 mReceiveThread.Abort();
//                 mReceiveThread = null;
//             }
//             if (mSendThread != null && mSendThread.IsAlive) {
//                 mSendThread.Abort();
//                 mSendThread = null;
//             }
//         }

//         private void OnDisconnect(string error) {
//             mReceiveThreadState = false;
//             mSendThreadState = false;
//             Debug.LogError(string.Format("netclient【{0}】disconnect, erro：【{1}】", mGameNetClient.clientName, error));
//             mGameNetClient.Disconnect();
//         }


//     }


// }