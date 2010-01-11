{ $Id: f_getdosoutput.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_getdosoutput.pas: Kommandozeile ausführen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.01.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_getdosoutput.pas stellt  Funktionen zur Verfügung:
    * Ausführen von Kommandozeilenprogrammen
    * Abfangen und Auswerten der Ausgaben


  exportierte Funktionen/Prozeduren:

    GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean; const FastMode: Boolean): string

}

unit f_getdosoutput;

{$I directives.inc}

interface

uses Windows, Classes, Forms;

function GetDOSOutput(const lpCommandLine: PChar; const GetStdErr: Boolean; const FastMode: Boolean; const TimeOut: Integer = 0): string;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     cl_dosthread, cl_logwindow,
     f_window, f_process, f_helper, const_common;

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


{ TCdrtfeDOSThread ----------------------------------------------------------- }

type TCdrtfeDOSThread = class(TDOSThread)
     private
       FUserReloadDisk : Boolean;    // User soll ENTER drücken
       function GetUserReloadDisk: Boolean;
       procedure CheckOutput; override;
     protected
       procedure OutputErrorMessage; override;
     public
       property UserReloadDisk: Boolean read GetUserReloadDisk write FUserReloadDisk;
     end;

{ TDOSThread - private/protected }

{ OutputErrorMessage -----------------------------------------------------------

  gibt die Win32-Fehlermeldung aus.                                            }

procedure TCdrtfeDOSThread.OutputErrorMessage;
begin
  TLogWin.Inst.AddSysError(FWinLastError, FErrorInfo);
end;

{ GetUserReloadDisk ------------------------------------------------------------

  liefert den Wert und setzt ihn zurück.                                       }

function TCdrtfeDOSThread.GetUserReloadDisk: Boolean;
begin
  Result := FUserReloadDisk;
  FUserReloadDisk := False;
end;

{ CheckOutput ------------------------------------------------------------------

  prüft, ob in der User zu Aktionen aufgefordert wird. Entsprechende Flags
  werden gesetzt.                                                              }

procedure TCdrtfeDOSThread.CheckOutput;
begin
  if Pos('hit <CR>', FOutput) > 0 then
  begin
    FUserReloadDisk := True;
    FOutput := '';
  end;
end;

{ TCdrtfeDOSThread - public }

{ GetDOSOutputEx ---------------------------------------------------------------

  führt die Kommandozeile in einem eigenen Thread aus und ermöglicht es, Ein-
  gaben an das Programm zu senden.                                             }

function GetDOSOutputEx(const lpCommandLine: PChar;
                        const GetStdErr: Boolean;
                        const FastMode: Boolean;
                        const Timeout: Integer): string;
var Thread      : TCdrtfeDOSThread;
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
  {$ENDIF}
  CurrentDir := GetCurrentFolder(string(lpCommandLine));
  if CurrentDir <> '' then
    lpCurrentDir := PChar(CurrentDir)
  else
    lpCurrentDir := nil;
  Thread := TCdrtfeDOSThread.Create(lpCommandLine, lpCurrentDir, GetStdErr,
                                                                          True);
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

end.
