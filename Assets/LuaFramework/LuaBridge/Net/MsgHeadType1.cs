// using System;
// using System.Collections.Generic;
// using System.IO;
// using System.Text;
// using System.Runtime.InteropServices;


// namespace DNet {
//     //自定义协议部分 |命令(4)|长度(4)（只有数据长度）|序号(4)|数据块|
//     public struct TagHeadType1 {
//         /// <summary> 定义消息的长度包括包头和包身 </summary>
//         public static readonly int PACK_LENGTH_OFFSET = 4;
//         /// <summary> 定义消息包id的偏移量 </summary>
//         public static readonly int PACK_MESSSAGEID_OFFSET = 0;

//         /// <summary> 定义从包头到包身的偏移 </summary>
//         public static readonly int PACK_HEAD_SIZE = 8;     //定义包头大小
//     }
// }