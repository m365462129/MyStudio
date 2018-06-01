// /*****************************************************
//  * 作者: DRed(龙涛) 1036409576@qq.com
//  * 创建时间：2015.3.1
//  * 版本：0.5.0
//  * 描述：重构的网络库
//  ****************************************************/

// using System;
// using System.Collections.Generic;
// using System.ComponentModel;
// using System.Net;
// using System.Net.Sockets;
// using System.Threading;
// using LuaInterface;
// using UnityEngine;

// namespace DNet
// {
//     /// <summary>
//     /// network state enum
//     /// </summary>


//     // public class GameNetClient : IDisposable
//     // {
//     //     #region expose lua Event

//     //     public LuaFunction onEventChangeFn;

//     //     public LuaFunction onReceiveMessageFn;
//     //     #endregion

//     //     /// <summary>
//     //     /// netwrok changed event
//     //     /// </summary>
//     //     private Action<NetWorkState> mNetWorkStateChangedEvent;

//     //     internal readonly Queue<NetWorkState> actionQueue = new Queue<NetWorkState>();

//     //     private NetWorkState mNetWorkState = NetWorkState.Closed;   //current network state

//     //     private Socket mSocket;
//     //     private Protocol mProtocol;
//     //     private Thread mConnectCheckThread;

//     //     private float lastHeartSendTime = 0;

//     //     //是否能发送心跳包，必须玩家登陆了才能发送
//     //     public bool canSendHeartPack = false;

//     //     public int msgProtocolType = 1;

//     //     //心跳包发送ID
//     //     public string heartMsgId = "1000";

//     //     //心跳包发送间隔
//     //     public int heartSendInIntervalTime = 5;

//     //     public string clientName;

//     //     //DNS解析超时的时间
//     //     public int dnsParseTimeout = 5000;

//     //     //连接超时时间
//     //     public int connectTimeoutMSec = 5000; //connect timeout count in millisecond

//     //     public IPEndPoint ipEndPoint;

//     //     //上一次掉线的时间，如果掉线时间过长那么需要跳到主界面
//     //     public long lastDisconnectTime;

//     //     //缓存上一次需要连接的地址和端口
//     //     private string mLastConnectHost;
//     //     private int mLaseConnectPort;

//     //     /// <summary>
//     //     /// 最大连接的次数，如果此数大于0在连接失败的时候会一直尝试
//     //     /// </summary>
//     //     private int mMaxConnectTime;


//     //     /// <summary> 心跳包验证的时间，心跳包放在UI线程来判断是不准确，应为UI线程可能很卡会引起 </summary>
//     //     private const float heartBeatePacketVerifyTime = 10;

//     //     /// <summary> 上一次收到心跳包的时间 </summary>
//     //     float mLastRecHeartBeatePacket;

//     //     /// <summary>
//     //     /// 是否需要连接成功，如果是代表会一直重连（用来处理断线重连的）
//     //     /// </summary>
//     //     public bool needConnected;

//     //     private CDecompress msgDataDecompresser;

//     //     [NoToLua]
//     //     public GameNetClient(string clientName, int msgProtocolType) {
//     //         this.clientName = clientName;
//     //         this.msgProtocolType = msgProtocolType;
//     //     }

//     //     public NetWorkState netWorkState {
//     //         get { return mNetWorkState; }
//     //         set { mNetWorkState = value; }
//     //     }

//     //     /// <summary>
//     //     /// 压入一个Buffer包
//     //     /// </summary>
//     //     /// <param name="buffer"></param>
//     //     public void EnqueuePacker(Buffer buffer) {
//     //         mProtocol.EnqueuePacker(buffer);
//     //     }

//     //     /// <summary>
//     //     /// 连接服务器，用上一次的地址
//     //     /// </summary>
//     //     public void Reconnect() {
//     //         Connect(mLastConnectHost, mLaseConnectPort);
//     //     }


//     //     /// <summary>
//     //     /// Connect Server
//     //     /// </summary>
//     //     /// <param name="host">server name or server ip (www.xxx.com/127.0.0.1/::1/localhost etc.)</param>
//     //     /// <param name="port">server port</param>
//     //     /// <param name="callback">mSocket successfully connected callback(in network thread)</param>
//     //     public void Connect(string host, int port, Action<string> callback = null) {
//     //         try {
//     //             if (mNetWorkState == NetWorkState.Connecting) {
//     //                 if (callback != null) {
//     //                     callback(mNetWorkState.ToString());
//     //                 }
//     //                 if (GameConfigProject.instance.netClientStateLogShow) {
//     //                     Debug.LogFormat("网络正在连接中，请勿重复连接：{0}:{1}", host, port);
//     //                 }
//     //                 return;
//     //             }
//     //             if (mNetWorkState == NetWorkState.Connected) {
//     //                 if (callback != null) {
//     //                     callback(mNetWorkState.ToString());
//     //                 }
//     //                 if (GameConfigProject.instance.netClientStateLogShow) {
//     //                     Debug.LogFormat("网络已连接，请勿重复连接：{0}:{1}", host, port);
//     //                 }
//     //                 return;
//     //             }
//     //             if (GameConfigProject.instance.netClientStateLogShow) {
//     //                 Debug.LogFormat("准备连接网络：{0}:{1}", host, port);
//     //             }
//     //             mLastConnectHost = host;
//     //             mLaseConnectPort = port;
//     //             netWorkState = NetWorkState.Connecting;
//     //             if (host.Contains(".com") || host.Contains(".net") || host.Contains(".cn")) {    //先从缓存中获取DNS的数据
//     //                 var asyncGetHostAddresse = Dns.BeginGetHostAddresses(host, x => {
//     //                     try {
//     //                         IPAddress ipAddress = null;
//     //                         IPAddress[] addresses = Dns.EndGetHostAddresses(x);
//     //                         if (addresses != null) {
//     //                             foreach (var item in addresses) {
//     //                                 if (item.AddressFamily == AddressFamily.InterNetwork || item.AddressFamily == AddressFamily.InterNetworkV6) {
//     //                                     ipAddress = item;
//     //                                     break;
//     //                                 }
//     //                             }
//     //                         }

//     //                         if (ipAddress == null) {
//     //                             EnqueueActionForDispatch(NetWorkState.DnsParseError);
//     //                         } else {
//     //                             string ip;
//     //                             AddressFamily ipAddressFamily;
//     //                             GameSDKInterface.instance.ProcessIpAndAddressFamily(ipAddress.ToString(), out ip, out ipAddressFamily);
//     //                             ipEndPoint = new IPEndPoint(IPAddress.Parse(ip), port);
//     //                             //Debug.LogFormat("开始连接网络(DNS获取到的IP地址)：{0}:{1}", ip, port);
//     //                             BeginConnect(ipEndPoint);
//     //                         }
//     //                     } catch (Exception e) {
//     //                         EnqueueActionForDispatch(NetWorkState.DnsParseError);
//     //                     }
//     //                 }, null);

//     //                 new Thread(x => {
//     //                     IAsyncResult result = x as IAsyncResult;
//     //                     if (!result.AsyncWaitHandle.WaitOne(dnsParseTimeout, true)) {
//     //                         EnqueueActionForDispatch(NetWorkState.DnsParseTimeout);
//     //                     }
//     //                 }).Start(asyncGetHostAddresse);

//     //             } else {
//     //                 string ip;
//     //                 AddressFamily ipAddressFamily;
//     //                 GameSDKInterface.instance.ProcessIpAndAddressFamily(mLastConnectHost, out ip, out ipAddressFamily);
//     //                 ipEndPoint = new IPEndPoint(IPAddress.Parse(ip), mLaseConnectPort);
//     //                 BeginConnect(ipEndPoint);
//     //             }
//     //         } catch (Exception) {
//     //             EnqueueActionForDispatch(NetWorkState.ConnectError);
//     //         }
//     //     }

//     //     void BeginConnect(IPEndPoint ipEndPoint, Action<string> callback = null) {
//     //         try {
//     //             if (mSocket != null) {
//     //                 //if (mSocket.Connected) {
//     //                 //    mSocket.Shutdown(SocketShutdown.Both); 
//     //                 //}
//     //                 mSocket.Close();
//     //             }
//     //             canSendHeartPack = false;
//     //             //Debug.LogFormat("开始连接网络，IPAdress:{0}，IPEndPoint的AddressFamily为：{1}", ipEndPoint.Address.ToString() ,ipEndPoint.AddressFamily);
//     //             mSocket = new Socket(ipEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
//     //             mSocket.NoDelay = true;
//     //             var asyncConnect = mSocket.BeginConnect(ipEndPoint, result => {
//     //                 try {
//     //                     Socket curSocket = result.AsyncState as Socket;
//     //                     if (curSocket == null || curSocket != mSocket) {
//     //                         Debug.LogError("连接超时或者连接成功的Socket与当前的Socket不相符合！");   //在mac上超时连接会触发这里
//     //                         EnqueueActionForDispatch(NetWorkState.ConnectError);
//     //                         if (curSocket != null) curSocket.EndConnect(result);
//     //                         return;
//     //                     }
//     //                     curSocket.EndConnect(result);
//     //                     if (msgProtocolType == 2) {
//     //                         msgDataDecompresser = new CDecompress();
//     //                     }
//     //                     mProtocol = new Protocol(this, curSocket);
//     //                     if (callback != null) {
//     //                         callback(NetWorkState.Connected.ToString());
//     //                     }
//     //                     lastDisconnectTime = 0;
//     //                     EnqueueActionForDispatch(NetWorkState.Connected);
//     //                     mLastRecHeartBeatePacket = 0;
//     //                 } catch (SocketException e) {
//     //                     Debug.LogError(e);
//     //                     if (mNetWorkState != NetWorkState.ConnectingTimeout) {
//     //                         EnqueueActionForDispatch(NetWorkState.ConnectError);
//     //                     }
//     //                     Dispose();
//     //                 }
//     //             }, mSocket);

//     //             if (mConnectCheckThread != null && mConnectCheckThread.IsAlive) {
//     //                 mConnectCheckThread.Abort();
//     //             }

//     //             mConnectCheckThread = new Thread(x => {
//     //                 IAsyncResult result = x as IAsyncResult;
//     //                 if (!result.AsyncWaitHandle.WaitOne(connectTimeoutMSec, true)) {
//     //                     if (mNetWorkState != NetWorkState.Connected && mNetWorkState != NetWorkState.ConnectError) {
//     //                         Dispose();
//     //                         EnqueueActionForDispatch(NetWorkState.ConnectingTimeout);
//     //                     }
//     //                 }
//     //             });
//     //             mConnectCheckThread.Start(asyncConnect);
//     //         } catch (Exception) {
//     //             EnqueueActionForDispatch(NetWorkState.ConnectError);
//     //         }
//     //     }

//     //     /// <summary>
//     //     /// 压入网络连接状态
//     //     /// </summary>
//     //     /// <param name="state"></param>
//     //     private void EnqueueActionForDispatch(NetWorkState state) {
//     //         lock (actionQueue) {
//     //             mNetWorkState = state;
//     //             //Debug.Log("EnqueueActionForDispatch：" + state);
//     //             actionQueue.Enqueue(state);
//     //         }
//     //     }

//     //     private void DequeueAction() {
//     //         lock (actionQueue) {
//     //             while (actionQueue.Count > 0) {
//     //                 NetWorkState action = actionQueue.Dequeue();
//     //                 if (mNetWorkStateChangedEvent != null) {
//     //                     mNetWorkStateChangedEvent(action);
//     //                 }
//     //                 if (onEventChangeFn != null) {
//     //                     onEventChangeFn.Call(action.ToString());
//     //                 }
//     //             }
//     //         }
//     //     }

//     //     /// <summary>
//     //     /// 网络状态变化
//     //     /// </summary>
//     //     /// <param name="state"></param>
//     //     private void NetWorkChanged(NetWorkState state)
//     //     {
//     //         if (mNetWorkState == state) return;
//     //         mNetWorkState = state;
//     //         if (mNetWorkStateChangedEvent != null) {
//     //             mNetWorkStateChangedEvent(state);
//     //         }
//     //     }

//     //     /// <summary>
//     //     /// 断开连接
//     //     /// </summary>
//     //     /// <param name="proactiveDisconnect"> 是否为主动断线，主动断线</param>
//     //     public void Disconnect(bool proactiveDisconnect = false) {
//     //         canSendHeartPack = false;
//     //         if (proactiveDisconnect) {
//     //             mMaxConnectTime = 5;
//     //             needConnected = false;
//     //             EnqueueActionForDispatch(NetWorkState.Closed);
//     //         } else {
//     //             if (mNetWorkState == NetWorkState.Connected) {
//     //                 //tmp close
//     //                 //lua tmp close lastDisconnectTime = TimeUtility.nowToTimestamp;
//     //                 EnqueueActionForDispatch(NetWorkState.Disconnected);
//     //             }
//     //         }
//     //         Dispose();
//     //     }

//     //     [NoToLua]
//     //     public void Dispose()
//     //     {
//     //         if (mProtocol != null) {
//     //             mProtocol.Dispose();
//     //             mProtocol = null;
//     //         }
//     //         try {
//     //             if (mSocket != null) {
//     //                 //if (mSocket.Connected) {
//     //                 //    mSocket.Shutdown(SocketShutdown.Both);    //在完成数据接收后再关闭，有可能在编辑器模式下造成卡死
//     //                 //}
//     //                 mSocket.Close();
//     //                 mSocket = null;
//     //             }
//     //         } catch (Exception ex) {

//     //             //todo : 有待确定这里是否会出现异常，这里是参考之前官方github上pull request。emptyMsg
//     //             Debug.LogException(ex);
//     //         }
//     //     }

        


//     //     /// <summary>
//     //     /// 给服务器发包
//     //     /// </summary>
//     //     /// <param name="bufferTmp">包的数据内容</param>
//     //     public bool SendPacket(Buffer bufferTmp) {
//     //         if (mNetWorkState != NetWorkState.Connected)
//     //         {
//     //             Debug.LogErrorFormat("给 {0} 服务器发包【{1}】。但有可能失败，当前连接状态为：{2}", clientName, bufferTmp.messageName, mNetWorkState);
//     //             // return false;
//     //         }
//     //         bool sendState = false;
//     //         if (mProtocol != null) {
//     //             sendState = mProtocol.Send(bufferTmp);
//     //         }
//     //         return sendState;
//     //     }

//     //     private void SendHeartPack() {
//     //         if (canSendHeartPack && Time.realtimeSinceStartup - lastHeartSendTime > heartSendInIntervalTime) {
//     //             lastHeartSendTime = Time.realtimeSinceStartup;
//     //             Buffer buffer = Buffer.Create(msgProtocolType);
//     //             buffer.WriteBufferMsgProtolType2(null, heartMsgId.ToString(), 0);   //心跳包协议
//     //             SendPacket(buffer);
//     //         }
//     //     }

//     //     [NoToLua]
//     //     public void ProcessAndHandOutPackets() {
//     //         if (mProtocol != null) {
//     //             Buffer buffer;
//     //             int retCode = ProcessPackets(out buffer);   //需要先收完收到的所有包
//     //             if (retCode == -1) {
//     //                 EnqueueActionForDispatch(NetWorkState.HeartTimeout);
//     //             }
//     //             else if(retCode == 1) {
//     //                 if (buffer != null && onReceiveMessageFn != null) {
//     //                     onReceiveMessageFn.Call(buffer);
//     //                 }
//     //             }
//     //         }

//     //         DequeueAction();
//     //         if (netWorkState == NetWorkState.Connected || netWorkState == NetWorkState.HeartTimeout) {
//     //             SendHeartPack();
//     //         }
//     //     }

//     //     //0代表没有收到包
//     //     //1代表收到包
//     //     //-1代表连接超时
//     //     int ProcessPackets(out Buffer buffer) {
//     //         if (mLastRecHeartBeatePacket < 1) {
//     //             mLastRecHeartBeatePacket = Time.realtimeSinceStartup;
//     //         }

//     //         while (mProtocol.ReceivePacket(out buffer))      //一次读取一个包
//     // 		{
//     //             mLastRecHeartBeatePacket = Time.realtimeSinceStartup;
//     //             buffer.SetMessageName(msgDataDecompresser, "1001");
//     //             //心跳包的处理,组ID和字命令都为0
//     //             if (buffer.messageName == heartMsgId) {
//     //                 buffer.Recycle();
//     //                 continue;
//     //             }
//     //             if (GameConfigProject.instance.netLogSendServerShow) {
//     //                 Debug.LogFormat("<color=#CC99CC>C#收到服务器包：【{0}] -命令组:{1} -包长:{2} -ret:{3}</color>-- 服务器端口:{4}", clientName, buffer.messageName, buffer.size, buffer.msgRetCode, ipEndPoint.Address); 
//     //             }

// 	// 	        return 1;
//     //         }
//     //         //如果x秒内没有收到心跳包也没有任何包，那么
//     //         if (Time.realtimeSinceStartup - mLastRecHeartBeatePacket > heartBeatePacketVerifyTime) {
//     //             mLastRecHeartBeatePacket = Time.realtimeSinceStartup;
//     //             return -1;
//     //         }
//     //         return 0;
//     //     }
//     // }
// }