{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_actionthread.pas: Kommandozeilenprogramme in einem eigenen Thread starten

  Copyright (c) 2004-2011 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  05.10.2011

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_actionthread.pas implementiert das Thread-Objekt, das die Kommandozeilen-
  programme ausführt und die Ausgaben in ein Memo umleitet.
  Da die Zugriffe auf das Memo über das TLogWin-Singleton erfolgen, ist die Unit
  cl_logwindow.pas zwingend notwendig.


  TActionThread

    Properties   TerminateThread
                 MessageAborted
                 MessageOk

    Methoden     Create(const CmdLine: string; const Suspended: Boolean)

  exportierte Funktionen

    DisplayDOSOutput(const lpCommandLine: string; Thread: TActionThread)
    TerminateExecution(Thread: TActionThread);

}

unit cl_actionthread;

{$I directives.inc}

interface

uses Classes, Forms, Windows, SysUtils,
     cl_lang;

type TActionThread = class(TThread)
     private
       FCommandLine: string;
       FCurrentDir : string;
       FlpCurrentDir : PChar;
       {$IFDEF ShowCmdError}
       FExitCode: Integer;
       {$ENDIF}
       FLine: string;
       FBSCount: Integer;
       FMessageOk: string;
       FMessageAborted: string;
       FHandle: THandle;    // Handle des Fensters, das das Ende-Signal erhält
       FPHandle: THandle;   // Handle des Prozesses
       FPStdIn: THandle;    // Handle der StdIn-Pipe des Prozesses
       FPID: DWORD;         // Prozess-ID
       FEnvironmentBlock: Pointer; // Zeiger zum neuen Umgebungsblock
       FWinLastError    : Integer;
       FErrorInfo       : string;
       function ProcessOutput(Line: string; var BeginNewLine: Boolean):string;
       procedure StartExecution;
     protected
       procedure Execute; override;
       procedure DAddLine;
       procedure DAddToLine;
       procedure DDeleteFromLine;
       procedure DClearLine;
       procedure DOutputErrorMessage;
       procedure SendTerminationMessage;
     public
       constructor Create(const CmdLine, CurrentDir: string; const Suspended: Boolean);
       property Commandline: string read FCommandline;
       property MessageOk: string write FMessageOk;
       property MessageAborted: string write FMessageAborted;
       property EnvironmentBlock: Pointer write FEnvironmentBlock;
       property PID: DWORD read FPID;
       property PHandle: THandle read FPHandle;
       property StdIn: THandle read FPStdIn;
     end;

procedure DisplayDOSOutput(const CommandLine: string; var Thread: TActionThread; Lang: TLang; const EnvironmentBlock: Pointer);
procedure TerminateExecution(Thread: TActionThread);
procedure SendCRToThread(Thread: TActionThread);

implementation

uses cl_logwindow, usermessages, const_common, f_process, f_wininfo,
    {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     f_helper;

const {+J}
      FirstAbort: Boolean = True;
      {-J}

{ TActionThread -------------------------------------------------------------- }

{ TAction - private/protected }

{ Methoden für den VCL-Zugriff -------------------------------------------------

  Zugriffe auf die VCL müssen über Synchronize erfolgen. Methoden, die für die
  Anzeige von Daten zuständig sind beginnen mit 'D'.                           }

procedure TActionThread.DOutputErrorMessage;
begin
  TLogWin.Inst.AddSysError(FWinLastError, FErrorInfo);
end;

procedure TActionThread.DAddLine;
begin
  TLogWin.Inst.Add(FLine);
  TLogWin.Inst.ShowProgressTaskBar;
end;

procedure TActionThread.DAddToLine;
begin
  TLogWin.Inst.AddToLine(FLine);
  TLogWin.Inst.ShowProgressTaskBar;
end;

procedure TActionThread.DDeleteFromLine;
begin
  TLogWin.Inst.DeleteFromLine(FBSCount);
end;

procedure TActionThread.DClearLine;
begin
  TLogWin.Inst.ClearLine;
end;

procedure TActionThread.SendTerminationMessage;
begin
  // TLogWin.Inst.ProgressBarHide(1); --> TCdrtfeMainForm.WMTTerminated
  TLogWin.Inst.ProgressBarHide(2);
  {$IFDEF ShowCmdError}
  SendMessage(FHandle, WM_TTerminated, FExitCode, 0);
  {$ELSE}
  SendMessage(FHandle, WM_TTerminated, 0, 0);
  {$ENDIF}
end;

{ ProcessOutput ----------------------------------------------------------------

  ProcessOutput verarbeitet die von der Pipe entgegengenommenen Zeichen und gibt
  sie im angegebenen Memo aus. Sollte nicht die ganze Zeile verarbeitet werden
  können, wird der Rest wieder zurückgegeben.                                  }

function TActionThread.ProcessOutput(Line: string;
                                     var BeginNewLine: Boolean):string;
var c, p, q, l, b, i, BSCount: Integer;
    OnlyBS: Boolean;
begin
  b := Pos(BckSp, Line);
  c := Pos(CRLF, Line);
  p := Pos(CR, Line);
  q := Pos(LF, Line);
  l := Length(Line);

  if BeginNewLine then
  begin
    FLine := '';
    Synchronize(DAddLine);
    BeginNewLine := False;
  end;

  if (b > 0) and                              // Backspace gefunden
     (((c = 0) or (b < c)) and ((p = 0) or (b < p)) and
      ((p = 0) or (b < p))) then
  begin
    if b > 1 then                             // nicht als erstes Zeichen
    begin
      FLine := Copy(Line, 1, b - 1);
      Synchronize(DAddToLine);
      Delete(Line, 1, b - 1);
    end else
    if b = 1 then                             // als erstes Zeichen
    begin
      {feststellen, ob nur Backspaces in Line sind}
      OnlyBS := True;
      BSCount := 1;
      i := 1;
      while OnlyBS and (i <= l) do
      begin
        if Line[i] <> BckSP then
        begin
          OnlyBS := False;
          BSCount := i - 1;
        end;
        inc(i);
      end;
      if not OnlyBS then
      begin
        FBSCount := BSCount;
        Synchronize(DDeleteFromLine);
        Delete(Line, 1, BSCount);
      end;
    end;
  end;

  if (p = 0) and (q = 0) and (b = 0) then     // keine Steuerzeichen -> ausgeben
  begin
    FLine := Line;
    Synchronize(DAddToLine);
    Line := '';
  end else

  if c = 1 then                               // CR/LF am Anfang
  begin
    while c = 1 do
    begin
      FLine := '';
      Synchronize(DAddLine);
      Delete(Line, 1, 2);
      c := Pos(CRLF, Line);
    end;
  end else
  if q = 1 then                               // LF am Anfang
  begin
    FLine := '';
    Synchronize(DAddLine);
    Delete(Line, 1, 1);
  end else
  if p = 1 then                               // CR am Anfang
  begin
    Synchronize(DClearLine);
    Delete(Line, 1, 1);
  end else

  if (p = 0) and (q = l) then                 // LF am Ende des Strings
  begin
    FLine := Copy(Line, 1, l - 1);
    Synchronize(DAddToLine);
    Delete(Line, 1, l - 1);
  end else
  if (p = l) and (q = 0) then                 // CR am Ende des Strings
  begin
    FLine := Copy(Line, 1, l - 1);
    Synchronize(DAddToLine);
    Delete(Line, 1, l - 1);
  end else
                                              // LF mittendrin, vor CR
  if (q < l) and (q > 0) and ((q < p) or (p = 0)) then
  begin
    FLine := Copy(Line, 1, q - 1);
    Synchronize(DAddToLine);
    Delete(Line, 1, q - 1);
  end else
                                              // CR mittendrin, vor LF
  if (p < l) and (p > 0) and ((p < q) or (q = 0)) then
  begin                                       // (auch CR/LF mittendrin)
    fLine := Copy(Line, 1, p - 1);
    Synchronize(DAddToLine);
    Delete(Line, 1, p - 1);
  end;
  Result := Line;
end;

{ StartExecution ---------------------------------------------------------------

  StartExecution führt die Kommandozeile aus und leitet die Ausgaben an
  ProcessOutput weiter.                                                        }

procedure TActionThread.StartExecution;
var lpPipeAttributes     : TSecurityAttributes;
    ReadStdOut, NewStdOut: THandle;
    WriteStdIn, NewStdIn : THandle;
    lpStartupInfo        : TStartupInfo;
    lpProcessInformation : TProcessInformation;
    lpNumberOfBytesRead  : DWORD;
    lpNumberOfBytesAvail : DWORD;
    BytesToRead          : DWORD;
    Buffer               : array[0..10] of Char;
    Temp                 : string;
    StartWithNewLine     : Boolean;
    OnlyBS               : Boolean;
    {$IFDEF ShowCmdError}
    ExitCode             : Cardinal;
    {$ENDIF}
begin
  FLine := FCommandLine;
  Synchronize(DAddLine);
  StartWithNewLine := True;
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
    lpStartupInfo.hStdError := NewStdOut;
    {StdIn darf nicht umgeleitet werden, sonst kein Abbruch per ctrl-c}
    // lpStartupInfo.hStdInput := NewStdIn;
    lpStartupInfo.dwFlags := lpStartupInfo.dwFlags or STARTF_USESHOWWINDOW;
    lpStartupInfo.wShowWindow := SW_HIDE;
    if CreateProcess(nil, PChar(FCommandLine), nil, nil, True,
                     CREATE_NEW_CONSOLE {or CREATE_NEW_PROCESS_GROUP},
                     FEnvironmentBlock, PChar(FlpCurrentDir),
                     lpStartupInfo, lpProcessInformation) then
    begin
      try
        CloseHandle(NewStdOut);
        CloseHandle(NewStdIn);
        FPHandle := lpProcessInformation.hProcess;
        FPStdIn := WriteStdIn;
        FPID := lpProcessInformation.dwProcessId;
        Buffer[0] := #0;
        Temp := '';
        repeat
          Temp := Temp + Buffer;

          PeekNamedPipe(ReadStdOut, @Buffer, SizeOf(Buffer) - 1,
                        @lpNumberOfBytesRead, @lpNumberOfBytesAvail, nil);
          if (lpNumberOfBytesAvail < SizeOf(Buffer) - 1) then
            BytesToRead := 1
          else
            BytesToRead := SizeOf(Buffer) - 1;
          {jetzt Zeichen verarbeiten und anzeigen}
          Temp := ProcessOutput(Temp, StartWithNewLine);

          ZeroMemory(@Buffer, SizeOf(Buffer));
          lpNumberOfBytesRead := 0;
          // Application.ProcessMessages;

          {Abbrechen, wenn gewünscht, radikale Variante}   {
          if ETerminate then
          begin
            TerminateProcess(lpProcessInformation.hProcess, 0);
          end;                                                 }

        until not ReadFile(ReadStdOut, Buffer, BytesToRead,
                           lpNumberOfBytesRead, nil);

        {Falls noch Reste in Temp stehen, diese verarbeiten und ausgeben}
        OnlyBS := False;
        repeat
          Temp := ProcessOutput(Temp, StartWithNewLine);
          if Length(Temp) > 0 then
          begin
            if (Temp[1] = BckSp) and (Temp[Length(Temp)] = BckSP) then
            begin
              OnlyBS := True;
            end;
          end;
        until (Temp = '') or OnlyBS;
        if not Terminated {FTerminate} then
        begin
          // Ausführung beendet.
          FLine := FMessageOk; // FLine := GMS('moutput01');
        end else
        begin
          // Ausführung durch Anwender abgebrochen.
          FLine := FMessageAborted; // FLine := GMS('moutput02');
        end;
        Synchronize(DAddLine);
        FLine := '';
        Synchronize(DAddLine);
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
    end else
    begin
      FWinLastError := GetLastError;
      FErrorInfo := cCreateProcess + CRLF + FCommandLine;
      Synchronize(DOutputErrorMessage);
    end;
  end;
end;

{ Execute ----------------------------------------------------------------------

  Den Thread starten und nacheinander die angegebenen Kommandaozeilen ausführen.
  Sollte FTernimate True sein, werden noch nocht ausgeführte Kommandozeilen
  übergangen.                                                                  }

procedure TActionThread.Execute;
var CommandLineList: TStringList;
    i: Integer;
begin
  CommandLineList := TStringList.Create;
  CommandLineList.Text := FCommandLine;
  for i := 0 to CommandLineList.Count - 1 do
  begin
    if not Terminated {FTerminate} and (FExitCode = 0) then
    begin
      FCommandLine := CommandLineList[i];
      StartExecution;
    end;
  end;
  {dem Hauptfenster mitteilen, daß der Thread beendet ist. Zur Sicherheit auch
   unter Verwendung von Synchronize.}
  Synchronize(SendTerminationMessage);
  CommandLineList.Free;
end;

{ TActionThread - public }

constructor TActionThread.Create(const CmdLine, CurrentDir: string;
                                 const Suspended: Boolean);
begin
  inherited Create(Suspended);
  FMessageOk := '';
  FMessageAborted := '';
  FHandle := TLogWin.Inst.OutWindowHandle;
  FCommandLine := CmdLine;
  FEnvironmentBlock := nil;
  FWinLastError := 0;
  FErrorInfo := '';
  FCurrentDir := CurrentDir;
  if FCurrentDir <> '' then
    FlpCurrentDir := PChar(FCurrentDir)
  else
    FlpCurrentDir := nil;
  {$IFDEF ShowCmdError}
  FExitCode := 0;
  {$ENDIF}
end;


{ Funktionen zum einfachen Starten und Beenden eines Threads ----------------- }

{ DisplayDOSOutput -------------------------------------------------------------

  leitet die Ausgaben einer Konsolenanwendung in ein Memo um, das über das
  TlogWin-Singleton angesprochen wird. Es können beliebig viele Kommandozeilen-
  Aufrufe durch CR getrennt angegeben werden.                                  }

procedure DisplayDOSOutput(const CommandLine: string;
                           var Thread: TActionThread; Lang: TLang;
                           const EnvironmentBlock: Pointer);
var CurrentDir: string;
begin
  FirstAbort := True;
  CurrentDir := GetCurrentFolder(CommandLine);
  Thread := TActionThread.Create(CommandLine, CurrentDir, True);
  Thread.MessageOk := Lang.GMS('moutput01');
  Thread.MessageAborted := Lang.GMS('moutput02');
  Thread.FreeOnTerminate := True;
  if Assigned(EnvironmentBlock) then
    Thread.EnvironmentBlock := EnvironmentBlock;
  Thread.Resume;
end;

{ TerminateExecution -----------------------------------------------------------

  TerminateExecution bricht die Ausführung der Kommandozeilenprogramme ab,
  indem das unsichtbare Fenster den Keyboard-Focus erhält und per keyb_event
  die Tastatur-Kombination Ctrl-c simuliert wird. Ein Abbruch mittles
  TermintaProcess ist nicht empfehlenswert, das Übermitteln von ctrl-c über
  StdIn hat nicht fdunktioniert.
  Unter WinXP ist mit der Cygwin1-DLL ab Version 1.5.20 eine andere Vorgehens-
  weise nötig, da das simulierte Ctrl-C nicht mehr funktioniert. Der Prozess
  (und die möglicherweise vorhandenen Child-Prozesse) werden per Remote-Thread
  beendet.                                                                     }

procedure TerminateExecution(Thread: TActionThread);
var Window  : Hwnd;
    ExitCode: Cardinal;
begin
  {$IFDEF WriteLogfile}
  AddLog(' ', 2);
  AddLogCode(1105);
  {$ENDIF}
  if (Thread <> nil) and FirstAbort then
  begin
    FirstAbort := False;
    {Dem Thread signalisieren, daß er die noch ausstehenden Kommandozeilen -
     sofern vorhanden - nicht ausführen soll.}
    Thread.Terminate;
    if PlatformWin2kXP {and cygwinver > 1.5.19} then
    begin
      {$IFDEF WriteLogfile}
      AddLogCode(1107);
      AddLog('ProcessID: ' + IntToStr(Thread.PID) +
             '; ProcessHandle: ' + IntToStr(Thread.PHandle), 3);
      {$ENDIF}
      {Prozess beenden}
      KillProcessSoftly(Thread.PHandle, ExitCode);
      {$IFDEF WriteLogfile}
      AddLog(' ', 2); AddLogCode(1108);
      {$ENDIF}
      {Child-Prozesse beenden: cdrecord, mkisofs}
      KillChildProcessesByName('cdrecord.exe', Thread.PID);
      KillChildProcessesByName('lame.exe', Thread.PID);
      KillChildProcessesByName('flac.exe', Thread.PID);
      KillChildProcessesByName('oggenc.exe', Thread.PID);
    end else
    begin
      {$IFDEF WriteLogfile}
      AddLogCode(1106);
      {$ENDIF}
      {Dem Kommandozeilenprogramm ein Ctrl-C senden.}
      Window := GetProcessWindow(Thread.PID);
      SetForeGroundWindow(Window);
      Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), 0, 0);
      Keybd_Event($43, MapVirtualKey($43,0), 0, 0);
      Keybd_Event($43, MapVirtualKey($43,0), KEYEVENTF_KEYUP, 0);
      Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), KEYEVENTF_KEYUP, 0);
    end;
  end else
  begin
    {$IFDEF WriteLogfile}
    AddLogCode(1110);
    {$ENDIF}
    Thread.Terminate;
    TerminateProcess(Thread.PHandle, 0);
  end;
  {$IFDEF WriteLogfile}
  AddLog(' ', 2);
  {$ENDIF}
end;

{ SendCRToThread ---------------------------------------------------------------

  sendet ein CRLF an den im Thread laufenden Prozess.                          }

procedure SendCRToThread(Thread: TActionThread);
var Buffer      : array[0..1] of Char;
    BytesWritten: Cardinal;
begin
  if Thread <> nil then
  begin                               
    Buffer[0] := #13;
    Buffer[1] := #10;
    WriteFile(Thread.StdIn, Buffer, SizeOf(Buffer), BytesWritten, nil);
  end;
end;

end.
