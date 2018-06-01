//using UnityEngine;


//#if UNITY_EDITOR
//using UnityEditor;
//#endif
//using System;
//using System.Diagnostics;
//using System.IO;
//using System.Threading;
//using System.Text;
//using System.Collections.Generic;

//public class SvnTool
//{
////     [MenuItem("Tools/Svn/ %&S", false, 1)]
////     static readonly string svnCommandLine = Path.Combine(Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName), "svn.exe");
////     public static void SvnFileCommit()
////     {
////         ProcessStartInfo statusCommand = new ProcessStartInfo();
//// 
////         statusCommand.FileName = svnCommandLine;
////         statusCommand.Arguments = "status";
////         statusCommand.WorkingDirectory = Environment.CurrentDirectory;
////         statusCommand.UseShellExecute = false;
////         statusCommand.RedirectStandardOutput = true;
//// 
////         var statusProcess = Process.Start(statusCommand);
//// 
////         Console.WriteLine("change list:");
//// 
////         string statusMessage = statusProcess.StandardOutput.ReadToEnd();
////         Console.Write(statusMessage);
//// 
////         Console.WriteLine("processing...");
//// 
////         using (var reader = new StringReader(statusMessage))
////         {
////             while (true)
////             {
////                 string message = reader.ReadLine();
////                 if (message == null)
////                     break;
//// 
////                 if (message.StartsWith("!"))
////                 {
////                     var filepath = message.Substring(1).Trim();
////                     filepath = Path.Combine(Environment.CurrentDirectory, filepath);
//// 
////                     var command = CreateSvnCommand("delete \"" + filepath + "\"");
////                     var deleteProcess = Process.Start(command);
////                     while (!deleteProcess.HasExited) Thread.Sleep(10);
//// 
////                 }
////                 else if (message.StartsWith("?"))
////                 {
////                     var filepath = message.Substring(1).Trim();
////                     filepath = Path.Combine(Environment.CurrentDirectory, filepath);
//// 
////                     var command = CreateSvnCommand("add \"" + filepath + "\"");
////                     var addProcess = Process.Start(command);
////                     while (!addProcess.HasExited) Thread.Sleep(10);
////                 }
////             }
////         }
//// 
////         var commitProcess = Process.Start(CreateSvnCommand(string.Format("commit -m \"{0}\"", Process.GetCurrentProcess().StartInfo.Arguments)));
////         while (!commitProcess.HasExited) Thread.Sleep(10);
////     }
//// 
////     private static ProcessStartInfo CreateSvnCommand(string command)
////     {
////         var start = new ProcessStartInfo(svnCommandLine, command);
////         start.UseShellExecute = false;
////         start.WorkingDirectory = Environment.CurrentDirectory;
////         return start;
////     }

//    private static string editorDllWorkPath = @"D:\Projects\Mysticall\MysticalProject\Assets\Scripts\External\Editor";
//    private static string gameDllWorkPath = @"D:\Projects\Mysticall\MysticalProject\Assets\Scripts\External\Runtime";

//    private static string editorDllPath = "Assets/Scripts/External/Editor/";
//    private static string gameDllPath = "Assets/Scripts/External/Runtime/";

////     [MenuItem("Tools/Svn/CommitDllBytes %&S", false, 1)]
////     public static void Test()
////     {
////         bool flag=RenameFile(gameDllPath + "GameDll.dll", gameDllPath + "GameDll.dll.bytes");
////         flag &= RenameFile(gameDllPath + "GameDll.dll.mdb", gameDllPath + "GameDll.dll.mdb.bytes");
////         flag &= RenameFile(editorDllPath + "GameEditor.dll", editorDllPath + "GameEditor.dll.bytes");
////         flag &= RenameFile(editorDllPath + "GameEditor.dll.mdb", editorDllPath + "GameEditor.dll.mdb.bytes");
////         flag &= RenameFile(gameDllPath + "GameDll.dll.meta", gameDllPath + "GameDll.dll.bytes.meta");
////         flag &= RenameFile(gameDllPath + "GameDll.dll.mdb.meta", gameDllPath + "GameDll.dll.mdb.bytes.meta");
////         flag &= RenameFile(editorDllPath + "GameEditor.dll.meta", editorDllPath + "GameEditor.dll.bytes.meta");
////         flag &= RenameFile(editorDllPath + "GameEditor.dll.mdb.meta", editorDllPath + "GameEditor.dll.mdb.bytes.meta");
//// 
////         if (!flag)
////         {
////             UnityEngine.Debug.LogError("文件格式异常!不予提交SVn");
////             return;
////         }
//// 
////         CommandLine commandLine1 = new CommandLine("svn", "commit -m  \"commit editorDll\" ", editorDllWorkPath);
////         CommandLineOutput commandLineOutput1 = commandLine1.Execute();
//// 
////         CommandLine commandLine2 = new CommandLine("svn", "commit -m  \"commit gameDll\" ", gameDllWorkPath);
////         CommandLineOutput commandLineOutput2 = commandLine2.Execute();
//// 
////         if (commandLineOutput1.Failed || commandLineOutput2.Failed)
////         {
////             UnityEngine.Debug.LogError(commandLineOutput1.ErrorStr+"   "+commandLineOutput2.ErrorStr);
////             UnityEngine.Debug.LogError("Dll CommitSvn Error!");
////         }
////         else
////         {
////             UnityEngine.Debug.LogError("<color=green>Dll CommitSvn Success!</color>");
////         }
//// 
////         RenameFile(gameDllPath + "GameDll.dll.bytes", gameDllPath + "GameDll.dll");
////         RenameFile(gameDllPath + "GameDll.dll.mdb.bytes", gameDllPath + "GameDll.dll.mdb");
////         RenameFile(editorDllPath + "GameEditor.dll.bytes", editorDllPath + "GameEditor.dll");
////         RenameFile(editorDllPath + "GameEditor.dll.mdb.bytes", editorDllPath + "GameEditor.dll.mdb");
////         RenameFile(gameDllPath + "GameDll.dll.bytes.meta", gameDllPath + "GameDll.dll.meta");
////         RenameFile(gameDllPath + "GameDll.dll.mdb.bytes.meta", gameDllPath + "GameDll.dll.mdb.meta");
////         RenameFile(editorDllPath + "GameEditor.dll.bytes.meta", editorDllPath + "GameEditor.dll.meta");
////         RenameFile(editorDllPath + "GameEditor.dll.mdb.bytes.meta", editorDllPath + "GameEditor.dll.mdb.meta");
////     }



//    //[MenuItem("Tools/Svn/CommitDllBytes ", false, 2)]
//    //public static void DllToBytes()
//    //{
//    //    bool flag = RenameFile(gameDllPath + "GameDll.dll", gameDllPath + "GameDll.dll.bytes");
//    //    flag &= RenameFile(gameDllPath + "GameDll.dll.mdb", gameDllPath + "GameDll.dll.mdb.bytes");
//    //    flag &= RenameFile(editorDllPath + "GameEditor.dll", editorDllPath + "GameEditor.dll.bytes");
//    //    flag &= RenameFile(editorDllPath + "GameEditor.dll.mdb", editorDllPath + "GameEditor.dll.mdb.bytes");
//    //    flag &= RenameFile(gameDllPath + "GameDll.dll.meta", gameDllPath + "GameDll.dll.bytes.meta");
//    //    flag &= RenameFile(gameDllPath + "GameDll.dll.mdb.meta", gameDllPath + "GameDll.dll.mdb.bytes.meta");
//    //    flag &= RenameFile(editorDllPath + "GameEditor.dll.meta", editorDllPath + "GameEditor.dll.bytes.meta");
//    //    flag &= RenameFile(editorDllPath + "GameEditor.dll.mdb.meta", editorDllPath + "GameEditor.dll.mdb.bytes.meta");

//    //    if (!flag)
//    //    {
//    //        UnityEngine.Debug.LogError("Dll--->Bytes Fail!");
//    //    }
//    //    else
//    //    {
//    //        UnityEngine.Debug.LogError("<color=green>Dll--->Bytes Success!</color>");
//    //    }
//    //}

//    //[MenuItem("Tools/Svn/CommitDllBytes2 ", false, 3)]
//    //public static void BytesToDll()
//    //{
//    //    bool flag=RenameFile(gameDllPath + "GameDll.dll.bytes", gameDllPath + "GameDll.dll");
//    //    flag &=RenameFile(gameDllPath + "GameDll.dll.mdb.bytes", gameDllPath + "GameDll.dll.mdb");
//    //    flag &=RenameFile(editorDllPath + "GameEditor.dll.bytes", editorDllPath + "GameEditor.dll");
//    //    flag &=RenameFile(editorDllPath + "GameEditor.dll.mdb.bytes", editorDllPath + "GameEditor.dll.mdb");
//    //    flag &=RenameFile(gameDllPath + "GameDll.dll.bytes.meta", gameDllPath + "GameDll.dll.meta");
//    //    flag &=RenameFile(gameDllPath + "GameDll.dll.mdb.bytes.meta", gameDllPath + "GameDll.dll.mdb.meta");
//    //    flag &=RenameFile(editorDllPath + "GameEditor.dll.bytes.meta", editorDllPath + "GameEditor.dll.meta");
//    //    flag &=RenameFile(editorDllPath + "GameEditor.dll.mdb.bytes.meta", editorDllPath + "GameEditor.dll.mdb.meta");

//    //    if (!flag)
//    //    {
//    //        UnityEngine.Debug.LogError("Bytes--->Dll Fail!");
//    //    }
//    //    else
//    //    {
//    //        UnityEngine.Debug.LogError("<color=green>Bytes--->Dll Success!</color>");
//    //    }
//    //}

//    public static bool RenameFile(string sourcesFileName, string newFileName, bool deleteSameNewFileName = true)
//    {
//        string projectPath = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf('/')) + "/";

//        if (File.Exists(projectPath + sourcesFileName))
//        {
//            if (File.Exists(projectPath + newFileName))
//            {
//                File.Delete(projectPath + newFileName);
//            }
//            File.Move(projectPath + sourcesFileName, projectPath + newFileName);

//            return true;
//        }

//        return false;
//    }

//    public sealed class CommandLineOutput
//    {
//        public CommandLineOutput(string command, string arguments, string outputStr, string errorStr, int exitcode)
//        {
//            Command = command;
//            Arguments = arguments;
//            OutputStr = outputStr;
//            ErrorStr = errorStr;
//            Exitcode = exitcode;
//        }

//        public string Command { get; private set; }
//        public string Arguments { get; private set; }
//        public string OutputStr { get; private set; }
//        public string ErrorStr { get; private set; }
//        public int Exitcode { get; private set; }
//        public bool Failed { get { return (Exitcode != 0 || !string.IsNullOrEmpty(ErrorStr)); } }
//    }

//    public sealed class CommandLine : IDisposable
//    {
//        public CommandLine(
//            string command,
//            string arguments,
//            string workingDirectory,
//            string input = null,
//            Dictionary<string, string> envVars = null
//            )
//        {
//            this.command = command;
//            this.arguments = arguments;
//            this.workingDirectory = workingDirectory;
//            this.input = input;
//            if (envVars != null) this.envVars = new Dictionary<string, string>(envVars);
//            AppDomain.CurrentDomain.DomainUnload += Unload;
//            AppDomain.CurrentDomain.ProcessExit += Unload;
//        }

//        private void Unload(object sender, EventArgs args)
//        {
//            AbortProcess();
//        }

//        private void AbortProcess()
//        {
//            if (!aborted && process != null)
//            {
//                aborted = true;
//                try
//                {
//                    if (!process.HasExited)
//                        process.Kill();
//                }
//                catch (Exception) { }
//                finally
//                {
//                    process.Dispose();
//                    process = null;
//                }
//            }
//        }

//        public void Dispose()
//        {
//            AppDomain.CurrentDomain.DomainUnload -= Unload;
//            AppDomain.CurrentDomain.ProcessExit -= Unload;
//            AbortProcess();
//        }

//        public override string ToString()
//        {
//            return workingDirectory + " " + command + " " + arguments;
//        }
//        const int BUFFER_SIZE = 2048;
//        Encoding encoding = Encoding.UTF8;
//        public event Action<string> OutputReceived;
//        public event Action<string> ErrorReceived;
//        string output;
//        string error;
//        string input;
//        int exitcode;
//        volatile bool aborted;
//        readonly string command;
//        readonly string arguments;
//        readonly string workingDirectory;
//        Dictionary<string, string> envVars = new Dictionary<string, string>();
//        Process process;

//        public CommandLineOutput Execute()
//        {
//            aborted = false;
//            try
//            {
//                ProcessStartInfo psi = new ProcessStartInfo()
//                {
//                    FileName = command,
//                    Arguments = arguments,
//                    WorkingDirectory = workingDirectory,
//                    CreateNoWindow = true,
//                    UseShellExecute = false,
//                    RedirectStandardError = true,
//                    RedirectStandardOutput = true,
//                    RedirectStandardInput = true,
//                    StandardOutputEncoding = encoding,
//                    StandardErrorEncoding = encoding,
//                    ErrorDialog = false
//                };
//                // set env vars
//                foreach (KeyValuePair<string, string> kvp in envVars) { psi.EnvironmentVariables.Add(kvp.Key, kvp.Value); }
//                process = Process.Start(psi);
//                encoding = process.StandardOutput.CurrentEncoding;

//                if (!String.IsNullOrEmpty(input))
//                {
//                    StreamWriter myStreamWriter = process.StandardInput;
//                    BinaryWriter writer = new BinaryWriter(myStreamWriter.BaseStream);
//                    writer.Write(System.Text.Encoding.UTF8.GetBytes(input));
//                    myStreamWriter.Close();
//                }

//                /*if (psi.Arguments.Contains("ExceptionTest.txt"))
//                {
//                    throw new System.ApplicationException("Test Exception cast due to ExceptionTest.txt being a part of arguments");
//                }*/

//                var sbOutput = new StringBuilder();
//                byte[] buffer = new byte[BUFFER_SIZE];
//                Decoder decoder = encoding.GetDecoder();
//                while (true)
//                {
//                    var asyncResult = process.StandardOutput.BaseStream.BeginRead(buffer, 0, BUFFER_SIZE, null, null);
//                    asyncResult.AsyncWaitHandle.WaitOne();
//                    var bytesRead = process.StandardOutput.BaseStream.EndRead(asyncResult);
//                    if (bytesRead > 0)
//                    {
//                        int charactersRead = decoder.GetCharCount(buffer, 0, bytesRead);
//                        char[] chars = new char[charactersRead];
//                        charactersRead = decoder.GetChars(buffer, 0, bytesRead, chars, 0);
//                        string result = ConvertEncoding(chars, encoding, Encoding.UTF8);
//                        if (OutputReceived != null && !string.IsNullOrEmpty(result))
//                            OutputReceived(result);
//                        sbOutput.Append(result);
//                    }
//                    else
//                    {
//                        process.WaitForExit();
//                        break;
//                    }
//                }

//                if (!aborted)
//                {
//                    output = sbOutput.ToString();
//                    error = process.StandardError.ReadToEnd();
//                    if (ErrorReceived != null)
//                        ErrorReceived(error);
//                    exitcode = process.ExitCode;
//                }
//            }
//            finally
//            {
//                if (process != null)
//                    process.Dispose();
//                process = null;
//            }
//            return new CommandLineOutput(command, arguments, output, error, exitcode);
//        }

//        public static string ConvertEncoding(char[] source, Encoding sourceEncoding, Encoding targetEncoding)
//        {
//            if (sourceEncoding == targetEncoding)
//                return new string(source);
//            byte[] sourceEncodingBytes = sourceEncoding.GetBytes(source);
//            byte[] targetEncodingBytes = Encoding.Convert(sourceEncoding, targetEncoding, sourceEncodingBytes);
//            return targetEncoding.GetString(targetEncodingBytes);
//        }

//    }

//}
