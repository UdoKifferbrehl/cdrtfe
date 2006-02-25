{ f_process.pas: Prozesse, Fenster, ...

  Copyright (c) 2004-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  23.06.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_process.pas stellt systembezogene Funktionen zur Verfügung:
    * Instanzenmanagement
    * Prozess-Funktionen
    * Ausführen von Kommandozeilenprogrammen


  exportierte Funktionen/Prozeduren:

    GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean): string
    IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean

}

unit f_process;

{$I directives.inc}

interface

uses Windows, Classes, Forms, SysUtils;

function GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean): string;
function GetProcessWindow(const TargetProcessID: Cardinal): HWnd;
function IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     constant;

     {Typ-Deklarationen für die Callback-Funktion}
type PProcessWindow = ^TProcessWindow;

     TProcessWindow = record
                        TargetProcessID: Cardinal;
                        FoundWindow: HWnd;
                      end;

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
  EnumWindows(@EnumWindowsProc, integer(@ProcWndInfo));
  Result := ProcWndInfo.FoundWindow;
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
var hwndIDE: HWnd;
    hwndInstance: HWnd;
begin
  {find other instance, first own window handle}
  hwndInstance := FindWindow(PChar(WType), PChar(WCaption));
  {  if hwndInstance <> self.Handle then
    hwndPrevInstance := hwndInstance
  else}
  {first other instances window}
  hwndPrevInstance := FindWindowEx(0, hwndInstance, PChar(WType), PChar(WCaption));
  {Delphi IDE}
  hwndIDE := FindWindow('TAppBuilder', nil);
  if (hwndIDE <> 0) or // hwndIDE is 0 if there's no Delphi IDE running
     (hwndPrevInstance = 0) or
     (hwndPrevInstance = 65934) then // there is another instance running
  begin
    hwndPrevInstance := hwndInstance;
  end;
  if hwndInstance <> hwndPrevInstance then
  begin
    Result := False;
  end else
  begin
    Result := True;
  end;
end;

{ GetDOSOutputStd --------------------------------------------------------------

  Wird von GetDOSOutput aufgerufen: Führt die Kommandozeile aus und gibt die
  Ausgabe zurück.
  Diese Funktion erzeugt im Fehlerprotokoll von MemProof die Meldung 'Attempt to
  free unexisting resource' für die CloseHandle-Anweisungen von hReadPipe und
  hWritePipe, was keinen Einfluß auf die Funktion hat.                         }

function GetDOSOutputStd(const lpCommandLine: PChar;
                         const GetStdErr: Boolean): string;

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


{ TDOSThread ----------------------------------------------------------------- }

type TDOSThread = class(TThread)
     private
       FCommandLine    : PChar;
       FGetStdErr      : Boolean;
       FRunning        : Boolean;
       FUserReloadDisk : Boolean;    // User soll ENTER drücken
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
       procedure GetDOSOutputThreaded;
       procedure CheckOutput;
     protected
       procedure Execute; override;
       {$IFDEF DebugGetDOSOutputThread}
       procedure Debug;
       {$ENDIF}
     public
       constructor Create(const CmdLine: PChar; const GetStdErr, Suspended: Boolean);
       property Output: string read FOutput;
       property Running: Boolean read FRunning;
       property UserReloadDisk: Boolean read FUserReloadDisk write FUserReloadDisk;
     end;

{ TDOSThread - private/protected }

{$IFDEf DebugGetDOSOutputThread}
procedure TDOSThread.Debug;
begin
  Deb(FLine, 2);
end;
{$ENDIF}

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

  Wird von Excute aufgerufen: Führt die Kommandozeile aus und specihert die
  Ausgabe in FOutput.                                                          }

procedure TDOSThread.GetDOSOutputThreaded;
var lpPipeAttributes     : TSecurityAttributes;
    ReadStdOut, NewStdOut: THandle;
    WriteStdIn, NewStdIn : THandle;
    lpStartupInfo        : TStartupInfo;
    lpProcessInformation : TProcessInformation;
    lpNumberOfBytesRead  : DWORD;
    Buffer               : array[0..10] of Char;
    {$IFDEF ShowCmdError}
    ExitCode             : Integer;
    {$ENDIF}
begin
  ZeroMemory(@lpPipeAttributes, SizeOf(TSecurityAttributes));
  lpPipeAttributes.nLength := SizeOf(TSecurityAttributes);
  lpPipeAttributes.bInheritHandle := True;
  if (CreatePipe(ReadStdOut, NewStdOut, @lpPipeAttributes, 0)) and
     (CreatePipe(NewStdIn, WriteStdIn, @lpPipeAttributes, 0)) then
  begin
    ZeroMemory(@lpStartupInfo, SizeOf(TStartupInfo));
    ZeroMemory(@lpProcessInformation, SizeOf(TProcessInformation));
    lpStartupInfo.cb := SizeOf(TStartupInfo);
    lpStartupInfo.dwFlags := STARTF_USESTDHANDLES;
    lpStartupInfo.hStdOutput := NewStdOut;
    if FGetStdErr then  lpStartupInfo.hStdError := NewStdOut;
    {StdIn darf nicht umgeleitet werden, sonst kein Abbruch per ctrl-c}
    // lpStartupInfo.hStdInput := NewStdIn;
    lpStartupInfo.dwFlags := lpStartupInfo.dwFlags or STARTF_USESHOWWINDOW;
    lpStartupInfo.wShowWindow := SW_HIDE;
    if CreateProcess(nil, FCommandLine, nil, nil, True,
                     CREATE_NEW_CONSOLE {or CREATE_NEW_PROCESS_GROUP},
                     nil, nil,
                     lpStartupInfo, lpProcessInformation) then
      try
        CloseHandle(NewStdOut);
        CloseHandle(NewStdIn);
        FPHandle := lpProcessInformation.hProcess;
        FPStdIn := WriteStdIn;
        FPID := lpProcessInformation.dwProcessId;
        Buffer[0] := #0;
        repeat
          FOutput := FOutput + Buffer;
          CheckOutput;
          ZeroMemory(@Buffer, SizeOf(Buffer));
          lpNumberOfBytesRead := 0;
          Application.ProcessMessages;
        until not ReadFile(ReadStdOut, Buffer, SizeOf(Buffer) - 1,
                           lpNumberOfBytesRead, nil);
      finally
        {$IFDEF ShowCmdError}
        repeat
          GetExitCodeProcess(lpProcessInformation.hProcess, ExitCode);
        until ExitCode <> STILL_ACTIVE;
        if FExitCode = 0 then FExitCode := ExitCode;
        {$ENDIF}
        CloseHandle(ReadStdOut);
        CloseHandle(WriteStdIn);
        CloseHandle(lpProcessInformation.hThread);
        CloseHandle(lpProcessInformation.hProcess);
      end;
      {$IFDEF DebugGetDOSOutputThread}
      FLine := string(FCommandLine);
      Synchronize(Debug);
      FLine := FOutput + CRLF;
      Synchronize(Debug);
      {$ENDIF}
  end;
end;

{ Execute ----------------------------------------------------------------------

  wird ausgeführt, wenn der Thread gestartet wird. Ruft die eigentliche Funktion
  zum Ausführen der Kommandozeile auf.                                         }

procedure TDOSThread.Execute;
begin
  FOutput := '';
  FRunning := True;
  GetDOSOutputThreaded;
  FRunning := False;
end;

{ TDOSThread - public }

constructor TDOSThread.Create(const CmdLine: PChar;
                              const GetStdErr, Suspended: Boolean);
begin
  inherited Create(Suspended);
  FCommandLine := CmdLine;
  FGetStdErr   := GetStdErr;
  FRunning     := True;
  {$IFDEF ShowCmdError}
  FExitCode := 0;
  {$ENDIF}
end;

{ GetDOSOutputEx ---------------------------------------------------------------

  führt die Kommandozeile in einem eigenen Thread aus und ermöglicht es, Ein-
  gaben an das Programm zu senden.                                             }

function GetDOSOutputEx(const lpCommandLine: PChar;
                        const GetStdErr: Boolean): string;
var Thread  : TDOSThread;
    i       : Integer;
    Msg, Cap: string;
    Window  : HWnd;
begin
  Thread := TDOSThread.Create(lpCommandLine, GetStdErr, True);
  Thread.FreeOnTerminate := False;
  Thread.Resume;

  while Thread.Running do
  begin
    Sleep(10);
    Application.ProcessMessages;
    if Thread.UserReloadDisk then
    begin
      Msg := 'Reload disk and press <Ok>';
      Cap := 'cdrecord';
      i := Application.MessageBox(PChar(Msg), PChar(Cap),
             MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
      if i = 1 then
      begin
        {OK}
        Window := GetProcessWindow(Thread.FPID);
        SetForeGroundWindow(Window);
        Keybd_Event(13, MapVirtualKey(13,0), 0, 0);
        Keybd_Event(13, MapVirtualKey(13,0), KEYEVENTF_KEYUP, 0);
        Thread.UserReloadDisk := False;
      end else
      begin
        Window := GetProcessWindow(Thread.FPID);
        SetForeGroundWindow(Window);
        Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), 0, 0);
        Keybd_Event($43, MapVirtualKey($43,0), 0, 0);
        Keybd_Event($43, MapVirtualKey($43,0), KEYEVENTF_KEYUP, 0);
        Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), KEYEVENTF_KEYUP, 0);
      end;
    end;
  end;

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
  Fehlermeldungen ignoriert. Steuerzeichen (z.B. LF) werden nicht entfernt.    }

function GetDOSOutput(const lpCommandLine: PChar;
                      const GetStdErr: Boolean): string;
begin
  {$IFNDEF ThreadedGetDOSOutput}
  Result := GetDOSOutputStd(lpCommandLine, GetStdErr);
  {$ELSE}
  Result := GetDOSOutputEx(lpCommandLine, GetStdErr);
  {$ENDIF}
  {$IFDEF WriteLogfile}
  AddLog(string(lpCommandLine) + CRLF, 0);
  AddLog(Result + CRLF + CRLF, 0);
  {$ENDIF}
end;

end.
