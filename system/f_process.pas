{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_process.pas: Prozesse, Fenster, ...

  Copyright (c) 2004-2009 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  22.12.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_process.pas stellt systembezogene Funktionen zur Verfügung:
    * Instanzenmanagement
    * Prozess-Funktionen
    * Ausführen von Kommandozeilenprogrammen


  exportierte Funktionen/Prozeduren:

    DLLIsLoaded(const Name: string; var FullPath: string): Boolean
    GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean; const FastMode: Boolean; const Timeout: Integer = 0): string
    GetProcessWindow(const TargetProcessID: Cardinal): HWnd
    IsAlreadyRunning: Boolean
    IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean
    ShlExecute(const Cmd, Opt: string)

}

unit f_process;

{$I directives.inc}

interface

uses Windows, Classes, Forms, SysUtils, ShellAPI, TLHelp32, ExtCtrls;

function DLLIsLoaded(const Name: string; var FullPath: string): Boolean;
function GetChildProcessByModuleName(const Name: string; const ParentID: DWORD): DWORD;
function GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean; const FastMode: Boolean; const Timeout: Integer = 0): string;
function GetProcessWindow(const TargetProcessID: Cardinal): HWnd;
function IsAlreadyRunning: Boolean;
function IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean;
function KillProcessSoftly(const hProcess: Cardinal; var uExitCode: Cardinal): Boolean;
function KillChildProcessesByName(const Name: string; const ParentID: DWORD): Boolean;
procedure ShlExecute(const Cmd, Opt: string);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     cl_logwindow, f_wininfo, f_misc, f_helper, constant;

     {Typ-Deklarationen für die Callback-Funktion}
type PProcessWindow = ^TProcessWindow;

     TProcessWindow = record
                        TargetProcessID: Cardinal;
                        FoundWindow: HWnd;
                      end;

var MutexHandle   : THandle;
    AlreadyRunning: Boolean;   // True = andere Instanz von cdrtfe läuft bereits

{ EnumWindowsProc --------------------------------------------------------------

  Callback-Funktion für EnumWindows.                                           }

function EnumWindowsProc(const Wnd: HWnd;
                         const ProcWndInfo: PProcessWindow): Boolean; stdcall;
var  WndProcessID: Cardinal;
begin
  GetWindowThreadProcessId(Wnd, @WndProcessID);
  if WndProcessID = ProcWndInfo^.TargetProcessID then
  begin
    ProcWndInfo^.FoundWindow := Wnd;
    Result := False; // stop enumerating since we've already found a window.
  end else
  begin
    Result := True; // Keep searching
  end;
end;

{ GetProcessWindow -------------------------------------------------------------

  GetProcessWindow bestimmt das zu einem Prozeß gehörende Fenster.             }

function GetProcessWindow(const TargetProcessID: Cardinal): HWnd;
var ProcWndInfo: TProcessWindow;
begin
  ProcWndInfo.TargetProcessID := TargetProcessID;
  ProcWndInfo.FoundWindow := 0;
  EnumWindows(@EnumWindowsProc, Integer(@ProcWndInfo));
  Result := ProcWndInfo.FoundWindow;
end;

{ KillProcessSoftly ------------------------------------------------------------

  beendet einen Prozess, indem ein RemoteThread im Kontext des Prozesses ge-
  startet wird, der ExitProcess ausführt.                                      }

function KillProcessSoftly(const hProcess: Cardinal;
                           var   uExitCode: Cardinal): Boolean;
var iExitCode: Cardinal;
    iThreadId: Cardinal;
    hThread  : Cardinal;
    hKernel  : HMODULE;
    pExitProc: TFarProc;
begin
  {$IFDEF WriteLogfile}
  AddLog('  KillProcessSoftly - PHandle: ' + IntToStr(hProcess), 3);
  {$ENDIF}
  {True - Erfolg, Thread beendet}
  Result := True;

  if not GetExitCodeProcess(hProcess, iExitCode) then
  begin
    {Kein ExitCode -> irgendetwas ist nicht in Ordnung}
    Result := False
  end else
  if iExitCode <> STILL_ACTIVE then
  begin
    {Prozess schon beendet}
    uExitCode := iExitCode
  end else
  begin
    {Adresse von ExitProcess bestimmen}
    hKernel := GetModuleHandle('Kernel32');
    pExitProc := GetProcAddress(hKernel, 'ExitProcess');
    {Remote-Thread im Prozess erzeugen}
    {$IFDEF WriteLogfile}
    AddLog('  Creating RemoteThread ... ', 3);
    {$ENDIF}
    Result := False;
    hThread := CreateRemoteThread(hProcess, nil, 0, pExitProc,
                                  Pointer(uExitCode), 0, iThreadId);
    if hThread <> 0 then
    begin
      {$IFDEF WriteLogfile}
      AddLog('  waiting ... ', 3);
      {$ENDIF}
      WaitForSingleObject(hProcess, {INFINITE}1000);
      {$IFDEF WriteLogfile}
      AddLog('  Closing handle ... ', 3);
      {$ENDIF}
      CloseHandle(hThread);
      Result := True;
    end;
  end;
end;

{ GetChildProcessByModuleName --------------------------------------------------

  liefert den ersten Child-Prozess mit vorgegebenem Modul-Namen eines Prozesses
  mit der gegebenen ID.                                                        }

function GetChildProcessByModuleName(const Name: string;
                                     const ParentID: DWORD): DWORD;
var hSnapshot: THandle;
    Next     : Boolean;
    pe       : TProcessEntry32;
begin
  Result := 0;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnapshot <> INVALID_HANDLE_VALUE then
  begin
    FillChar(pe, SizeOf(pe), 0);
    pe.dwSize := SizeOf(pe);
    Next := Process32First(hSnapshot, pe);
    while Next do
    begin
      if (AnsiCompareText(StrPas(@pe.szExeFile), Name) = 0) {and
         (pe.th32ParentProcessID = ParentID) } then
      begin
        Result := pe.th32ProcessID;
        Next := False;
        {$IFDEF WriteLogfile}
        AddLog('  Found ChildProcess: ProcessID: ' + IntToStr(Result) +
               '; ParentProcessID: ' + IntToStr(pe.th32ParentProcessID), 3);
        {$ENDIF}
      end else
      begin
        Next := Process32Next(hSnapshot, pe);
      end;
    end;
    CloseHandle(hSnapshot);
  end;
end;

{ KillChildProcessesByName -----------------------------------------------------

  beendet alle Child-Prozesse mit dem gegebenen Modul-Namem des Parent-Prozesses
  mit der gegebenen ID.                                                        }

function KillChildProcessesByName(const Name: string;
                                  const ParentID: DWORD): Boolean;
const MaxRetry = 3;
var PID     : DWORD;
    PHandle : THandle;
    ExitCode: Cardinal;
    Count   : Integer;
begin
  {$IFDEF WriteLogfile}
  AddLog('KillChildProcessByName - Name: ' + Name, 3);
  {$ENDIF}
  Result := False;
  Count := 0;
  repeat
    Inc(Count);
    PID := GetChildProcessByModuleName(Name, ParentID);
    if PID > 0 then
    begin
      PHandle := OpenProcess(PROCESS_ALL_ACCESS, False, PID);
      if PHandle <> INVALID_HANDLE_VALUE then
      begin
        {$IFDEF WriteLogfile}
        AddLog('  Killing ProcessID: ' + IntToStr(PID) +
               '; ProcessHandle: ' + IntToStr(PHandle), 3);
        {$ENDIF}
        Result := KillProcessSoftly(PHandle, ExitCode);
      end;
      CloseHandle(PHandle);
    end;
  until (PID = 0) or (Count > MaxRetry);
end;

{ IsAlreadRunning --------------------------------------------------------------

  True, wenn bereits eine Instanz läuft.                                       }

function IsAlreadyRunning: Boolean;
begin
  Result := AlreadyRunning;
end;

{ IsFirstInstance --------------------------------------------------------------

  IsFirstInstance prüft, ob die Instanz, die diese Funktion aufruft, die erste
  Instanz von cdrtfe ist.
  Argumente:    hwndPrevInstance  Variable für die Rückgabe des Handles zur
                                  vorigen Instanz, sofern vorhanden. Wenn keine
                                  andere Instanz läuft, wird das Handle der
                                  aktuellen Instanzzurückgegeben.
                WType             Typ des Hauptfensters
                WCAption          Fenstertitel
  Rückgabewert: True, wenn keine weitere Instanz gefunden wurde, False sonst   }

function IsFirstInstance(var hwndPrevInstance: HWnd;
                         WType, WCaption: string): Boolean;
var //hwndIDE     : HWnd;
    hwndInstance: HWnd;
begin
  {find other instance, first own window handle}
  hwndInstance := FindWindow(PChar(WType), PChar(WCaption));
  {first other instances window}
  hwndPrevInstance := FindWindowEx(0, hwndInstance,
                                   PChar(WType), PChar(WCaption));
  {if no other Window -> previous window = current window}
  if hwndPrevInstance = 0 then hwndPrevInstance := hwndInstance;
  {Result depends on mutex creation result on startup}
  Result := not AlreadyRunning;
end;

{ GetDOSOutputStd --------------------------------------------------------------

  Wird von GetDOSOutput aufgerufen: Führt die Kommandozeile aus und gibt die
  Ausgabe zurück.
  Diese Funktion erzeugt im Fehlerprotokoll von MemProof die Meldung 'Attempt to
  free unexisting resource' für die CloseHandle-Anweisungen von hReadPipe und
  hWritePipe, was keinen Einfluß auf die Funktion hat.                         }

function GetDOSOutputStd(const lpCommandLine: PChar;
                         const GetStdErr: Boolean;
                         const FastMode: Boolean): string;

var lpPipeAttributes: TSecurityAttributes;
    hReadPipe: THandle;
    hWritePipe: THandle;
    lpStartupInfo: TStartupInfo;
    lpProcessInformation: TProcessInformation;
    lpNumberOfBytesRead: DWORD;
    Buffer: array[0..1023] of Char;
begin
  Result := '';
  ZeroMemory(@lpPipeAttributes, SizeOf(TSecurityAttributes));
  lpPipeAttributes.nLength := SizeOf(TSecurityAttributes);
  lpPipeAttributes.bInheritHandle := True;
  if CreatePipe(hReadPipe, hWritePipe, @lpPipeAttributes, 0) then
  begin
    ZeroMemory(@lpStartupInfo, SizeOf(TStartupInfo));
    lpStartupInfo.cb := SizeOf(TStartupInfo);
    lpStartupInfo.dwFlags := STARTF_USESTDHANDLES;
    lpStartupInfo.hStdOutput := hWritePipe;
    if GetStdErr then
    begin
      lpStartupInfo.hStdError := hWritePipe;
    end;
    lpStartupInfo.dwFlags := lpStartupInfo.dwFlags or STARTF_USESHOWWINDOW;
    lpStartupInfo.wShowWindow := SW_hide;
    if CreateProcess(nil, lpCommandLine, nil, nil, True, CREATE_NEW_CONSOLE,
      nil, nil, lpStartupInfo, lpProcessInformation) then
      try
        CloseHandle(hWritePipe);
        Buffer[0] := #0;
        repeat
          Result := Result + Buffer;
          ZeroMemory(@Buffer, SizeOf(Buffer));
          lpNumberOfBytesRead := 0;
        until not ReadFile(hReadPipe, Buffer, SizeOf(Buffer) - 1,
                           lpNumberOfBytesRead, nil);
      finally
        CloseHandle(hReadPipe);
        CloseHandle(lpProcessInformation.hThread);
        CloseHandle(lpProcessInformation.hProcess);
      end;
  end;
end;

(*
{ Alternative Variante von GetDOSOutputStd, die leider auch nicht weniger Fehler
  hat.}

function GetDOSOutputStd(const lpCommandLine: PChar;
                        const GetStdErr: Boolean): string;
var hChildStdinRd, hChildStdinWr, hChildStdinWrDup,
    hChildStdoutRd, hChildStdoutWr,
    hSaveStdin, hSaveStdout: THandle;

    saAttr: TSecurityAttributes;
    siStartInfo: TStartupInfo;
    piProcInfo: TProcessInformation;

    Success: Boolean;
    lpNumberOfBytesRead: DWORD;
    Buffer: array[0..1023] of Char;

begin
  {Pipe-Handles vererbbar machen}
  saAttr.nLength := SizeOf(TSecurityAttributes);
  saAttr.bInheritHAndle := True;
  saAttr.lpSecurityDescriptor := nil;

  {Umleitung von Stdout des Child-Prozesses:}

  {aktuellen Handle von Stdout sichern}
  hSaveStdout := GetStdHandle(STD_OUTPUT_HANDLE);

  {Pipe erzeugen für Stdout des Child-Prozesses}
  Success := CreatePipe(hChildStdoutRd, hChildStdoutWr, @saAttr, 0);
  if not Success then
    raise Exception.Create('Stdout-Pipe konnte nicht erzeugt werden!');

  {Stdout umleiten}
  Success := SetStdHandle(STD_OUTPUT_HANDLE, hChildStdoutWr);
  if not Success then
    raise Exception.Create('Umleitung von Stdout fehlgeschlagen!');

  {Umleitung von Stdin des Child-Prozesses}

  {aktuellen Handle von Stdin sichern}
  hSaveStdin := GetStdHandle(STD_INPUT_HANDLE);

  {Pipe erzeugen für Stdin des Child-Prozesses}
  Success := CreatePipe(hChildStdinRd, hChildStdinWr, @saAttr, 0);
  if not Success then
    raise Exception.Create('Stdin-Pipe konnte nicht erzeugt werden!');

  {Stdin umleiten}
  Success := SetStdHandle(STD_INPUT_HANDLE, hChildStdinRd);
  if not Success then
    raise Exception.Create('Umleitung von Stdin fehlgeschlagen!');

  {Write-Handle zur Pipe verdoppeln, damit Handle nicht vererbt wird}
  Success := DuplicateHandle(GetCurrentProcess(), hChildStdinWr,
                             GetCurrentProcess(), @hChildStdinWrDup,
                             0, False, DUPLICATE_SAME_ACCESS);
  if not Success then
    raise Exception.Create('Handle konnte nicht dupliziert werden!');
  CloseHandle(hChildStdinWr);

  {Child-Prozess erzeugen}
  siStartInfo.cb := SizeOf(TStartupInfo);
  siStartInfo.lpReserved  := nil;
  siStartInfo.lpReserved2 := nil;
  siStartInfo.cbReserved2 := 0;
  siStartInfo.lpDesktop   := nil;
  siStartInfo.dwFlags     := siStartInfo.dwFlags or STARTF_USESHOWWINDOW;
  siStartInfo.wShowWindow := SW_hide;
  if GetStdErr then
  begin
    siStartInfo.hStdError := siStartInfo.hStdOutput;
  end;
  Success := CreateProcess(nil,
                           lpCommandLine,
                           nil,
                           nil,
                           True,
                           CREATE_NEW_CONSOLE,
                           nil,
                           nil,
                           siStartInfo,
                           piProcInfo);
  if not Success then
    raise Exception.Create('Prozess konnte nicht gestartet werden!');

  {Stdin und Stdout wiederherstellen}
  Success := SetStdHandle(STD_INPUT_HANDLE, hSaveStdin);
  if not Success then
    raise Exception.Create('Wiederherstellung von Stdin fehlgeschlagen!');

  Success := SetStdHandle(STD_OUTPUT_HANDLE, hSaveStdout);
  if not Success then
    raise Exception.Create('Wiederherstellung von Stdout fehlgeschlagen!');

  {in die Input-Pipe des Child-Prozesses schreiben}
  // WriteFile(hChildStdinWrDup, ...)

  {Pipe schließen, damit der Prozess aufhört zu lesen}
  Success := CloseHandle(hChildStdinWrDup);
  if not Success then
    raise Exception.Create('Schließen der Pipe fehlgeschlagen!');

  {aus der Output-Pipe des Child-Prozesses lesen}

  {erst das Write-Ende schließen}
  Success := CloseHandle(hChildStdoutWr);
  if not Success then
    raise Exception.Create('Schließen der Pipe fehlgeschlagen!');

  {lesen}
   Buffer[0] := #0;
   repeat
     Result := Result + Buffer;
     ZeroMemory(@Buffer, SizeOf(Buffer));
     lpNumberOfBytesRead := 0;
   until not ReadFile(hChildStdoutRd, Buffer, SizeOf(Buffer) - 1,
                      lpNumberOfBytesRead, nil);

   {Aufräumen}
   CloseHandle(piProcInfo.hThread);
   CloseHandle(piProcInfo.hProcess);
   CloseHandle(hSaveStdin);
   CloseHandle(hSaveStdout);
end;                        *)


{ TProcessTimer -------------------------------------------------------------- }

type TProcessTimer = class(TTimer)
     private
       FSinceBeginning: Integer;
       FSinceLastOutput: Integer;
       procedure HandleTimerEvent(Sender: TObject);
     public
       constructor Create(AOwner: TComponent); override;
       procedure Beginning;                   // zu Beginn aufrufen
       procedure NewOutput;                   // aufrufen, wenn neue Zeile
       procedure Ending;                      // aufrufen, wenn Prozess zu Ende
       property SinceBeginning: Integer read FSinceBeginning;
       property SinceLastOutput: Integer read FSinceLastOutput;
     end;

{ TProcessTimer - private }

{ HandleTimerEvent -------------------------------------------------------------

  erhöht die Sekundenzähler um 1.                                              }

procedure TProcessTimer.HandleTimerEvent(Sender: TObject);
begin
  Inc(FSinceBeginning);
  Inc(FSinceLastOutput);
end;

{ TProcessTimer - public }

constructor TProcessTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Enabled := False; //timer is off
  OnTimer := HandleTimerEvent;
end;

{ Beginning --------------------------------------------------------------------

  startet die Zeitzählung .                                                    }

procedure TProcessTimer.Beginning;
begin
  Interval         := 1000;     //time is in sec
  FSinceBeginning  := 0;        //this is the beginning
  FSinceLastOutput := 0;
  Enabled          := True;     //set the timer on
end;

{ NewOutput --------------------------------------------------------------------

  setzt den Timer für die Zeit seit dem letzten Output zurück.                 }

procedure TProcessTimer.NewOutput;
begin
  FSinceLastOutput := 0;        //a new output has been caught
end;

{ Ending -----------------------------------------------------------------------

  beendet die Zeitzählung.                                                     }

procedure TProcessTimer.Ending;
begin
  Enabled := False;             //set the timer off
end;


{ TDOSThread ----------------------------------------------------------------- }

type TDOSThread = class(TThread)
     private
       FCommandLine    : PChar;
       FCurrentDir     : PChar;
       FGetStdErr      : Boolean;
       FRunning        : Boolean;
       FUserReloadDisk : Boolean;    // User soll ENTER drücken
       FFastMode       : Boolean;
       FBuffSize       : Integer;
       FWinLastError   : Integer;
       FErrorInfo      : string;
       FTimeout        : Integer;
       {$IFDEF ShowCmdError}
       FExitCode       : Integer;
       {$ENDIF}
       FOutput         : string;
       FPHandle        : THandle;    // Handle des Prozesses
       FPStdIn         : THandle;    // Handle der StdIn-Pipe des Prozesses
       FPID            : DWORD;      // Prozess-ID
       {$IFDEF DebugGetDOSOutputThread}
       FLine           : string;
       {$ENDIF}
       {Timer}
       FTimer                 : TProcessTimer;
       function GetUserReloadDisk: Boolean;
       procedure GetDOSOutputThreaded;
       procedure CheckOutput;
     protected
       procedure Execute; override;
       procedure OutputErrorMessage;
       {$IFDEF DebugGetDOSOutputThread}
       procedure Debug;
       {$ENDIF}
     public
       constructor Create(const CmdLine, CurrentDir: PChar; const GetStdErr, Suspended: Boolean);
       property Output: string read FOutput;
       property StdIn: THandle read FPStdIn;
       property PID: DWORD read FPID;
       property Running: Boolean read FRunning;
       property UserReloadDisk: Boolean read GetUserReloadDisk write FUserReloadDisk;
       property FastMode: Boolean write FFastMode;
       property Timeout: Integer write FTimeout;
     end;

{ TDOSThread - private/protected }

{ OutputErrorMessage -----------------------------------------------------------

  gibt die Win32-Fehlermeldung aus.                                            }

procedure TDOSThread.OutputErrorMessage;
begin
  TLogWin.Inst.AddSysError(FWinLastError, FErrorInfo);
end;

{$IFDEf DebugGetDOSOutputThread}
procedure TDOSThread.Debug;
begin
  Deb(FLine, 2);
end;
{$ENDIF}

{ GetUserReloadDisk ------------------------------------------------------------

  liefert den Wert und setzt ihn zurück.                                       }

function TDOSThread.GetUserReloadDisk: Boolean;
begin
  Result := FUserReloadDisk;
  FUserReloadDisk := False;
end;

{ CheckOutput ------------------------------------------------------------------

  prüft, ob in der User zu Aktionen aufgefordert wird. Entsprechende Flags
  werden gesetzt.                                                              }

procedure TDOSThread.CheckOutput;
begin
  if Pos('hit <CR>', FOutput) > 0 then
  begin
    FUserReloadDisk := True;
    FOutput := '';
  end;
end;

{ GetDOSOutputThreaded ---------------------------------------------------------

  Wird von Excute aufgerufen: Führt die Kommandozeile aus und speichert die
  Ausgabe in FOutput.                                                          }

procedure TDOSThread.GetDOSOutputThreaded;
const SECURITY_DESCRIPTOR_REVISION = 1;
var lpPipeAttributes        : TSecurityAttributes;
    ReadStdOut, NewStdOut   : THandle;
    WriteStdIn, NewStdIn    : THandle;
    lpStartupInfo           : TStartupInfo;
    lpProcessInformation    : TProcessInformation;
    lpSecurityDescriptor    : TSecurityDescriptor;
    lpNumberOfBytesRead     : DWORD;
    lpNumberOfBytesAvailable: DWORD;
//  Buffer                  : array[0..10] of Char;
    Buffer                  : PChar;
    Temp                    : string;
    Changed                 : Boolean;
    ExitCode                : Cardinal;
begin
  Buffer := nil;
  ZeroMemory(@lpPipeAttributes, SizeOf(TSecurityAttributes));
  lpPipeAttributes.nLength := SizeOf(TSecurityAttributes);
  lpPipeAttributes.bInheritHandle := True;

  if PlatformWinNT then
  begin
    InitializeSecurityDescriptor(@lpSecurityDescriptor,
                                 SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(@lpSecurityDescriptor, True, nil, False);
    lpPipeAttributes.lpSecurityDescriptor := @lpSecurityDescriptor;
  end else
  begin
    lpPipeAttributes.lpSecurityDescriptor := nil;
  end;

  if (CreatePipe(ReadStdOut, NewStdOut, @lpPipeAttributes, 0)) and
     (CreatePipe(NewStdIn, WriteStdIn, @lpPipeAttributes, 0)) then
  begin
    ZeroMemory(@lpStartupInfo, SizeOf(TStartupInfo));
    ZeroMemory(@lpProcessInformation, SizeOf(TProcessInformation));
    lpStartupInfo.cb := SizeOf(TStartupInfo);
    lpStartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    lpStartupInfo.hStdOutput := NewStdOut;
    if FGetStdErr then lpStartupInfo.hStdError := NewStdOut;
    lpStartupInfo.hStdInput := NewStdIn;
    lpStartupInfo.wShowWindow := SW_HIDE;
    if CreateProcess(nil, PChar(FCommandLine), nil, nil, True,
                     CREATE_NEW_CONSOLE {or CREATE_NEW_PROCESS_GROUP},
                     nil, PChar(FCurrentDir),
                     lpStartupInfo, lpProcessInformation) then
    begin
      try
        {Timer starten}
        FTimer := TProcessTimer.Create(nil);
        FTimer.Beginning;
        FPHandle := lpProcessInformation.hProcess;
        FPStdIn := WriteStdIn;
        FPID := lpProcessInformation.dwProcessId;
//      Buffer[0] := #0;
        GetMem(Buffer, FBuffSize);
        ZeroMemory(Buffer, FBuffSize);
        Temp := '';
        Changed := True;
        repeat
          GetExitCodeProcess(lpProcessInformation.hProcess, ExitCode);
          if Changed then
          begin
            FOutput := FOutput + Buffer;
            CheckOutput;
          end;

//        ZeroMemory(@Buffer, SizeOf(Buffer));
          ZeroMemory(Buffer, FBuffSize);
          lpNumberOfBytesRead := 0;
          Application.ProcessMessages;

          {ReadSuccess := }
//        PeekNamedPipe(ReadStdout, @Buffer, SizeOf(Buffer),
          PeekNamedPipe(ReadStdout, Buffer, FBuffSize,
                        @lpNumberOfBytesRead,
                        @lpNumberOfBytesAvailable, nil);

          Changed := lpNumberOfBytesAvailable > 0;
          if lpNumberOfBytesAvailable <> 0 then
          begin
//          ZeroMemory(@Buffer, SizeOf(Buffer));
            ZeroMemory(Buffer, FBuffSize);
            {ReadSuccess :=}
//          ReadFile(ReadStdOut, Buffer, SizeOf(Buffer) - 1,
            ReadFile(ReadStdOut, Buffer^, FBuffSize - 1,
                     lpNumberOfBytesRead, nil);

          end else
          begin
            {nach StdIn schreiben}
          end;
          Sleep(1);
          {Timeout}
          if ((FTimer.FSinceBeginning >= FTimeout) and (FTimeout > 0)) then
          begin
              break;
          end;

        until (ExitCode <> STILL_ACTIVE) and (lpNumberOfBytesAvailable = 0);

      finally
        {Nach Abbruch oder Timeout Prozess gewaltsam beenden.}
         if (ExitCode = STILL_ACTIVE) then
           TerminateProcess(lpProcessInformation.hProcess, 0);
        {$IFDEF ShowCmdError}
        repeat
          GetExitCodeProcess(lpProcessInformation.hProcess, ExitCode);
        until ExitCode <> STILL_ACTIVE;
        if FExitCode = 0 then FExitCode := ExitCode;
        {$ENDIF}
        {Timer anhalten}
        FTimer.Ending;
        FTimer.Free;
        CloseHandle(NewStdIn);
        CloseHandle(NewStdOut);
        CloseHandle(ReadStdOut);
        CloseHandle(WriteStdIn);
        CloseHandle(lpProcessInformation.hThread);
        CloseHandle(lpProcessInformation.hProcess);
        FreeMem(Buffer);
      end;
    end else
    begin
      FWinLastError := GetLastError;
      FErrorInfo := cCreateProcess + CRLF + string(FCommandLine);
      Synchronize(OutputErrorMessage);
    end;
  end;
end;

{ Execute ----------------------------------------------------------------------

  wird ausgeführt, wenn der Thread gestartet wird. Ruft die eigentliche Funktion
  zum Ausführen der Kommandozeile auf.                                         }

procedure TDOSThread.Execute;
begin
  case FFastMode of
    True : FBuffSize := 512;
    False: FBuffSize := 11;
  end;
  FOutput := '';
  FRunning := True;
  GetDOSOutputThreaded;
  FRunning := False;
end;

{ TDOSThread - public }

constructor TDOSThread.Create(const CmdLine, CurrentDir: PChar;
                              const GetStdErr, Suspended: Boolean);
begin
  inherited Create(Suspended);
  FCommandLine  := CmdLine;
  FCurrentDir   := CurrentDir;
  FGetStdErr    := GetStdErr;
  FWinLastError := 0;
  FErrorInfo    := '';
  FRunning      := True;
  FTimeout      := 0;
  {$IFDEF ShowCmdError}
  FExitCode     := 0;
  {$ENDIF}
end;

{ GetDOSOutputEx ---------------------------------------------------------------

  führt die Kommandozeile in einem eigenen Thread aus und ermöglicht es, Ein-
  gaben an das Programm zu senden.                                             }

function GetDOSOutputEx(const lpCommandLine: PChar;
                        const GetStdErr: Boolean;
                        const FastMode: Boolean;
                        const Timeout: Integer): string;
var Thread      : TDOSThread;
    i           : Integer;
    BytesWritten: Cardinal;
    Msg, Cap    : string;
    Window      : HWnd;
    Buffer      : array[0..1] of Char;
    lpCurrentDir: PChar;
    CurrentDir  : string;
begin
  {$IFDEF WriteLogfile}
  AddLogCode(1100);
  case FastMode of
    True : AddLog('FastMode: True  -> BuffSize = 512' + CRLF, 12);
    False: AddLog('FastMode: False -> BuffSize = 10' + CRLF, 12);
  end;
  Addlog('Timeout: ' + IntToStr(Timeout) + CRLF, 12);
  {$ENDIF}
  CurrentDir := GetCurrentFolder(string(lpCommandLine));
  if CurrentDir <> '' then
    lpCurrentDir := PChar(CurrentDir)
  else
    lpCurrentDir := nil;
  Thread := TDOSThread.Create(lpCommandLine, lpCurrentDir, GetStdErr, True);
  Thread.FreeOnTerminate := False;
  Thread.FastMode := FastMode;
  Thread.Timeout := Timeout;
  {$IFDEF WriteLogfile}
  AddLogCode(1101);
  AddLog(string(lpCommandLine) + CRLF, 12);
  {$ENDIF}
  Thread.Resume;

  while Thread.Running do
  begin
    Sleep(10);
    Application.ProcessMessages;
    if Thread.UserReloadDisk then
    begin
      Msg := 'Reload disk and press <Ok>';
      Cap := 'cdrecord';
      i := ShowMsgDlg(Msg, Cap,
                      MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
      if i = 1 then
      begin
        {OK}
        if Thread <> nil then
        begin
          Buffer[0] := #13;
          Buffer[1] := #10;
          WriteFile(Thread.StdIn, Buffer, SizeOf(Buffer), BytesWritten, nil);
        end;
      end else
      begin
        Window := GetProcessWindow(Thread.PID);
        SetForeGroundWindow(Window);
        Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), 0, 0);
        Keybd_Event($43, MapVirtualKey($43,0), 0, 0);
        Keybd_Event($43, MapVirtualKey($43,0), KEYEVENTF_KEYUP, 0);
        Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), KEYEVENTF_KEYUP, 0);
      end;
    end;
  end;
  {$IFDEF WriteLogfile}AddLogCode(1102);{$ENDIF}

  Result := Thread.Output;
  {$IFDEF DebugGetDOSOutputThread}
  Deb(Result + CRLF, 1);
  {$ENDIF}
  Thread.Free;
end;
               
{ GetDOSOutput -----------------------------------------------------------------

  GetDOSOutput führt die Kommandozeile lpCommandline aus und leitet die Ausgaben
  der Konsolenanwendung in eine Stringvariable um. Diese Funktion stammt aus dem
  Internet und wurde ein wenig verändert. Wenn GetStdErr = False, dann werden
  Fehlermeldungen ignoriert. Steuerzeichen (z.B. LF) werden nicht entfernt. Bei
  FastMode = True wird die Puffergröße hochgesetzt. Dadurch steht die Ausgabe
  schneller zur Verfügung, allerdings kann es zu Problemen kommen, falls eine
  Eingabe nötig wird.                                                          }

function GetDOSOutput(const lpCommandLine: PChar;
                      const GetStdErr: Boolean;
                      const FastMode: Boolean;
                      const TimeOut: Integer = 0): string;
begin
  {$IFNDEF ThreadedGetDOSOutput}
  Result := GetDOSOutputStd(lpCommandLine, GetStdErr, FastMode);
  {$ELSE}
  Result := GetDOSOutputEx(lpCommandLine, GetStdErr, FastMode, Timeout);
  {$ENDIF}
  {$IFDEF WriteLogfile}
  AddLogCode(1103);
  AddLog(Result, 12);
  {$ENDIF}
end;

{ ShlExecute -------------------------------------------------------------------

  vereinfachter Zugriff auf ShellExecute.                                      }

procedure ShlExecute(const Cmd, Opt: string);
var ErrorCode: Integer;
    Msg, Msg2: string;
begin
  {$IFDEF WriteLogfile}
  AddLogCode(1109);
  if Cmd = '' then
  begin
    AddLog('ShellExecute(' + IntToStr(Application.MainForm.Handle) +
           ', ''open'', ' + Opt + ', nil, nil, SW_SHOWNORMAL);', 2);
  end else
  begin
    AddLog('ShellExecute(' + IntToStr(Application.MainForm.Handle) +
           ', nil, ' + Cmd + ', ' + Opt + ', nil, SW_SHOWNORMAL);', 2);
  end;
  AddLog('', 2);
  {$ENDIF}
  if Cmd = '' then
  begin
    ErrorCode := ShellExecute(Application.MainForm.Handle, 'open',
                                PChar(Opt), nil, nil, SW_SHOWNORMAL);
  end else
  begin
    ErrorCode := ShellExecute(Application.MainForm.Handle, nil,
                                PChar(Cmd), PChar(Opt), nil, SW_SHOWNORMAL);
  end;
  if ErrorCode <= 32 then
  begin
    case ErrorCode of
       2: Msg2 := 'File not found.';
       3: Msg2 := 'Path not found.';
       5: Msg2 := 'Access denied.';
       8: Msg2 := 'Out of memory.';
      26: Msg2 := 'Sharing violation.';
      27: Msg2 := 'Incomplete or invalid file name association.';
      28: Msg2 := 'DDE transaction timed out.';
      29: Msg2 := 'DDE transaction failed.';
      30: Msg2 := 'DDE busy.';
      31: Msg2 := 'No file name association for file type.';
      32: Msg2 := 'DLL not found.';
    else
      Msg2 := 'unknown';
    end;
    Msg := 'ShellExecute failed.' + CRLF +
           'Error code: ' + IntToStr(ErrorCode) + CRLF +
           'Error message: ' + Msg2;
    ShowMsgDlg(Msg, 'Error', MB_OK or MB_ICONWARNING);
  end;
end;

{ DLLIsLoaded ------------------------------------------------------------------

  True, wenn die DLL Name bereits geladen ist. In diesem Fallm enthält FullPath
  den komletten Pfad zur Datei.                                                }

function DLLIsLoaded(const Name: string; var FullPath: string): Boolean;
type TProcessData = packed record
                      UsageCnt: Word;
                      RelocateCnt: Word;
                    end;
var SnapProcHandle,
    SnapModuleHandle: THandle;
    ProcessEntry    : TProcessEntry32;
    ModuleEntry     : TModuleEntry32;
    ProcessNext,
    ModuleNext      : Boolean;
    Found           : Boolean;
    Path            : string;
begin
  Found := False;
  SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if SnapProcHandle <> INVALID_HANDLE_VALUE then
  begin
    ProcessEntry.dwSize := Sizeof(ProcessEntry);
    ProcessNext := Process32First(SnapProcHandle, ProcessEntry);
    while ProcessNext and not Found do
    begin
      SnapModuleHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,
                                                    ProcessEntry.th32ProcessID);
      if SnapModuleHandle <> INVALID_HANDLE_VALUE then
      begin
        ModuleEntry.dwSize := Sizeof(ModuleEntry);
        ModuleNext := Module32First(SnapModuleHandle, ModuleEntry);
        while ModuleNext and not Found do
        begin
          Path := ExtractFileName(ModuleEntry.szExePath);
          if LowerCase(Path) = LowerCase(Name) then
          begin
            Found := True;
            FullPath := ModuleEntry.szExePath;
          end;
          ModuleNext := Module32Next(SnapModuleHandle, ModuleEntry);
        end;
        CloseHandle(SnapModuleHandle);
      end;
      ProcessNext := Process32Next(SnapProcHandle, ProcessEntry);
    end;
    CloseHandle(SnapProcHandle);
  end;
  Result := Found;
end;

initialization
  MutexHandle := CreateMutex(nil, True,
                             PChar(ExtractFileName(Application.ExeName)));
  AlreadyRunning := GetLastError = ERROR_ALREADY_EXISTS;

finalization
  if MutexHandle <> 0 then CloseHandle(MutexHandle);

end.
