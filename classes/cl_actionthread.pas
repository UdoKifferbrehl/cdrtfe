{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_actionthread.pas: Kommandozeilenprogramme in einem eigenen Thread starten

  Copyright (c) 2004-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  14.06.2006

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  cl_actionthread.pas implementiert das Thread-Objekt, das die Kommandozeilen-
  programme ausf�hrt und die Ausgaben in ein Memo umleitet.
  Da die Zugriffe auf das Memo �ber das TLogWin-Singleton erfolgen, ist die Unit
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
       {$IFDEF ShowCmdError}
       FExitCode: Integer;
       {$ENDIF}
       FLine: string;
       FBSCount: Integer;
       FMessageOk: string;
       FMessageAborted: string;
       FHandle: THandle;    // Handle des Fensters, das das Ende-Signal erh�lt
       FPHandle: THandle;   // Handle des Prozesses
       FPStdIn: THandle;    // Handle der StdIn-Pipe des Prozesses
       FPID: DWORD;         // Prozess-ID
       FEnvironmentBlock: Pointer; // Zeiger zum neuen Umgebungsblock
       // FTerminate: Boolean;
       function ProcessOutput(Line: string; var BeginNewLine: Boolean):string;
       procedure StartExecution;
     protected
       procedure Execute; override;
       procedure DAddLine;
       procedure DAddToLine;
       procedure DDeleteFromLine;
       procedure DClearLine;
       procedure SendTerminationMessage;
     public
       constructor Create(const CmdLine: string; const Suspended: Boolean);
       property MessageOk: string write FMessageOk;
       property MessageAborted: string write FMessageAborted;
       property EnvironmentBlock: Pointer write FEnvironmentBlock;
       // property TerminateThread: Boolean write FTerminate;
     end;
(*
     {Typ-Deklarationen f�r die Callback-Funktion}
     PProcessWindow = ^TProcessWindow;

     TProcessWindow = record
                        TargetProcessID: Cardinal;
                        FoundWindow: HWnd;
                      end;
*)
procedure DisplayDOSOutput(const CommandLine: string; var Thread: TActionThread; Lang: TLang; const EnvironmentBlock: Pointer);
procedure TerminateExecution(Thread: TActionThread);

implementation

uses cl_logwindow, user_messages, constant, f_misc, f_process;

{ TActionThread -------------------------------------------------------------- }

{ TAction - private/protected }

{ Methoden f�r den VCL-Zugriff -------------------------------------------------

  Zugriffe auf die VCL m�ssen �ber Synchronize erfolgen. Methoden, die f�r die
  Anzeige von Daten zust�ndig sind beginnen mit 'D'.                           }

procedure TActionThread.DAddLine;
begin
  TLogWin.Inst.Add(FLine);
  {$IFDEF ShowProgressTaskBar}
  TLogWin.Inst.ShowProgressTaskBar;
  {$ENDIF}
end;

procedure TActionThread.DAddToLine;
begin
  TLogWin.Inst.AddToLine(FLine);
  {$IFDEF ShowProgressTaskBar}
  TLogWin.Inst.ShowProgressTaskBar;
  {$ENDIF}  
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
  {$IFDEF ShowCmdError}
  SendMessage(FHandle, WM_TTerminated, FExitCode, 0);
  {$ELSE}
  SendMessage(FHandle, WM_TTerminated, 0, 0);
  {$ENDIF}
end;

{ ProcessOutput ----------------------------------------------------------------

  ProcessOutput verarbeitet die von der Pipe entgegengenommenen Zeichen und gibt
  sie im angegebenen Memo aus. Sollte nicht die ganze Zeile verarbeitet werden
  k�nnen, wird der Rest wieder zur�ckgegeben.                                  }

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

  StartExecution f�hrt die Kommandozeile aus und leitet die Ausgaben an
  ProcessOutput weiter.                                                        }

procedure TActionThread.StartExecution;
var lpPipeAttributes: TSecurityAttributes;
    ReadStdOut, NewStdOut: THandle;
    WriteStdIn, NewStdIn: THandle;
    lpStartupInfo: TStartupInfo;
    lpProcessInformation: TProcessInformation;
    lpNumberOfBytesRead: DWORD;
    Buffer: array[0..10] of Char;
    Temp: string;
    StartWithNewLine: Boolean;
    OnlyBS: Boolean;
    {$IFDEF ShowCmdError}
    ExitCode: Integer;
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
                     FEnvironmentBlock, nil,
                     lpStartupInfo, lpProcessInformation) then
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

          {jetzt Zeichen verarbeiten und anzeigen}
          Temp := ProcessOutput(Temp, StartWithNewLine);

          ZeroMemory(@Buffer, SizeOf(Buffer));
          lpNumberOfBytesRead := 0;
          Application.ProcessMessages;

          {Abbrechen, wenn gew�nscht, radikale Variante}   (*
          if ETerminate then
          begin
            TerminateProcess(lpProcessInformation.hProcess, 0);
          end;                                                 *)

        until not ReadFile(ReadStdOut, Buffer, SizeOf(Buffer) - 1,
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
          // Ausf�hrung beendet.
          FLine := FMessageOk; // FLine := GMS('moutput01');
        end else
        begin
          // Ausf�hrung durch Anwender abgebrochen.
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
        // CloseHandle(hReadPipe);
        // CloseHandle(NewStdIn);
        // CloseHandle(NewStdOut);
        CloseHandle(ReadStdOut);
        CloseHandle(WriteStdIn);
        CloseHandle(lpProcessInformation.hThread);
        CloseHandle(lpProcessInformation.hProcess);
      end;
  end;
end;

{ Execute ----------------------------------------------------------------------

  Den Thread starten und nacheinander die angegebenen Kommandaozeilen ausf�hren.
  Sollte FTernimate True sein, werden noch nocht ausgef�hrte Kommandozeilen
  �bergangen.                                                                  }

procedure TActionThread.Execute;
var CommandLineList: TStringList;
    i: Integer;
begin
  CommandLineList := TStringList.Create;
  CommandLineList.Text := FCommandLine;
  for i := 0 to CommandLineList.Count - 1 do
  begin
    if not Terminated {FTerminate} then
    begin
      FCommandLine := CommandLineList[i];
      StartExecution;
    end;
  end;
  {dem Hauptfenster mitteilen, da� der Thread beendet ist. Zur Sicherheit auch
   unter Verwendung von Synchronize.}
  Synchronize(SendTerminationMessage);
  CommandLineList.Free;
end;

{ TActionThread - public }

constructor TActionThread.Create(const CmdLine: string;
                                 const Suspended: Boolean);
begin
  inherited Create(Suspended);
  FMessageOk := '';
  FMessageAborted := '';
  FHandle := TLogWin.Inst.OutWindowHandle;
  FCommandLine := CmdLine;
  FEnvironmentBlock := nil;
  {$IFDEF ShowCmdError}
  FExitCode := 0;
  {$ENDIF}
end;


{ Funktionen zum einfachen Starten und Beenden eines Threads ----------------- }

{ DisplayDOSOutput -------------------------------------------------------------

  leitet die Ausgaben einer Konsolenanwendung in ein Memo um, das �ber das
  TlogWin-Singleton angesprochen wird. Es k�nnen beliebig viele Kommandozeilen-
  Aufrufe durch CR getrennt angegeben werden.                                  }

procedure DisplayDOSOutput(const CommandLine: string;
                           var Thread: TActionThread; Lang: TLang;
                           const EnvironmentBlock: Pointer);
begin
  Thread := TActionThread.Create(CommandLine, True);
  Thread.MessageOk := Lang.GMS('moutput01');
  Thread.MessageAborted := Lang.GMS('moutput02');
  Thread.FreeOnTerminate := True;
  if Assigned(EnvironmentBlock) then
    Thread.EnvironmentBlock := EnvironmentBlock;
  Thread.Resume;
end;
          (*
{ EnumWindowsProc --------------------------------------------------------------

  Callback-Funktion f�r EnumWindows.                                           }

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

  GetProcessWindow bestimmt das zu einem Proze� geh�rende Fenster.             }

function GetProcessWindow(const TargetProcessID: Cardinal): HWnd;
var ProcWndInfo: TProcessWindow;
begin
  ProcWndInfo.TargetProcessID := TargetProcessID;
  ProcWndInfo.FoundWindow := 0;
  EnumWindows(@EnumWindowsProc, integer(@ProcWndInfo));
  Result := ProcWndInfo.FoundWindow;
end;                            *)

{ TerminateExecution -----------------------------------------------------------

  TerminateExecution bricht die Ausf�hrung der Kommandozeilenprogramme ab,
  indem das unsichtbare Fenster den Keyboard-Focus erh�lt und per keyb_event
  die Tastatur-Kombination crtl-c simuliert wird. Ein Abbruch mittles
  TermintaProcess ist nicht empfehlenswert, das �bermitteln von ctrl-c �ber
  SrdIn hat nicht fdunktioniert.                                               }

procedure TerminateExecution(Thread: TActionThread);
var Window: Hwnd;

begin
  if Thread <> nil then
  begin
    {Dem Thread signalisieren, da� er die noch ausstehenden Kommandozeilen -
     sofern vorhanden - nicht ausf�hren soll.}
    Thread.Terminate; //Thread.TerminateThread := True;
    {Dem Kommandozeilenprogramm ein Ctrl-C senden. Es soll schlie�lich geordnet
     abgebrochen werden. Ein gewaltsamer Abbruch mit TerminateProcess k�nnte
     negative Auswirkungen (Speicherlecks usw.) haben.}
    Window := GetProcessWindow(Thread.FPID);
    SetForeGroundWindow(Window);
    Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), 0, 0);
    Keybd_Event($43, MapVirtualKey($43,0), 0, 0);
    Keybd_Event($43, MapVirtualKey($43,0), KEYEVENTF_KEYUP, 0);
    Keybd_Event(vk_Control, MapVirtualKey(vk_Control,0), KEYEVENTF_KEYUP, 0);
  end;
end;

end.
