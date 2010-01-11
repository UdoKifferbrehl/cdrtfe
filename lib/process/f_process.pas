{ $Id: f_process.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_process.pas: Prozesse, Fenster, ...

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.01.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_process.pas stellt systembezogene Funktionen zur Verfügung:
    * Prozess-Funktionen
    * ShlExecute
    * Prozesse beenden


  exportierte Funktionen/Prozeduren:

    DLLIsLoaded(const Name: string; var FullPath: string): Boolean
    GetChildProcessByModuleName(const Name: string; const ParentID: DWORD): DWORD
    GetProcessWindow(const TargetProcessID: Cardinal): HWnd
    KillProcessSoftly(const hProcess: Cardinal; var uExitCode: Cardinal): Boolean
    KillChildProcessesByName(const Name: string; const ParentID: DWORD): Boolean
    ShlExecute(const Cmd, Opt: string)

}

unit f_process;

{$I directives.inc}

interface

uses Windows, Forms, SysUtils, ShellAPI, TlHelp32;

function DLLIsLoaded(const Name: string; var FullPath: string): Boolean;
function GetChildProcessByModuleName(const Name: string; const ParentID: DWORD): DWORD;
function GetProcessWindow(const TargetProcessID: Cardinal): HWnd;
function KillProcessSoftly(const hProcess: Cardinal; var uExitCode: Cardinal): Boolean;
function KillChildProcessesByName(const Name: string; const ParentID: DWORD): Boolean;
procedure ShlExecute(const Cmd, Opt: string);

implementation

uses {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     const_common, f_window;

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

end.
