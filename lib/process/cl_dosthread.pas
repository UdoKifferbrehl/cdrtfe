{ $Id: cl_dosthread.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  cl_dosthread.pas: Kommandozeilenprogramm ausführen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  08.01.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_dosthread.pas stellt ein Objekt zur Verfügung, das es ermöglicht, ein
  Kommandozeilenprogramm auszuführen und die Ausgabe abzufangen.


  TDOSThread

    Properties   Output: string read FOutput;
                 StdIn: THandle read FPStdIn;
                 PID: DWORD read FPID;
                 Running: Boolean read FRunning;
                 FastMode: Boolean write FFastMode;

    Methoden     Create(const CmdLine, CurrentDir: PChar; const GetStdErr, Suspended: Boolean)

}

unit cl_dosthread;

{$I directives.inc}

interface

uses Windows, Classes, Forms, ExtCtrls;

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

     TDOSThread = class(TThread)
     private
       FCommandLine    : PChar;
       FCurrentDir     : PChar;
       FGetStdErr      : Boolean;
       FRunning        : Boolean;
       FFastMode       : Boolean;
       FBuffSize       : Integer;
       FTimeout        : Integer;
       {$IFDEF ShowCmdError}
       FExitCode       : Integer;
       {$ENDIF}
       FPHandle        : THandle;    // Handle des Prozesses
       FPStdIn         : THandle;    // Handle der StdIn-Pipe des Prozesses
       FPID            : DWORD;      // Prozess-ID
       {$IFDEF DebugGetDOSOutputThread}
       FLine           : string;
       {$ENDIF}
       {Timer}
       FTimer          : TProcessTimer;
       procedure GetDOSOutputThreaded;
     protected
       FOutput         : string;
       FWinLastError   : Integer;
       FErrorInfo      : string;
       procedure CheckOutput; virtual;
       procedure Execute; override;
       procedure OutputErrorMessage; virtual;
       {$IFDEF DebugGetDOSOutputThread}
       procedure Debug;
       {$ENDIF}
     public
       constructor Create(const CmdLine, CurrentDir: PChar; const GetStdErr, Suspended: Boolean);
       property Output: string read FOutput;
       property StdIn: THandle read FPStdIn;
       property PID: DWORD read FPID;
       property Running: Boolean read FRunning;
       property FastMode: Boolean write FFastMode;
       property Timeout: Integer write FTimeout;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
      f_wininfo, const_common;

{ TProcessTimer -------------------------------------------------------------- }

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

{ TDOSThread - private/protected }

{ OutputErrorMessage -----------------------------------------------------------

  gibt die Win32-Fehlermeldung aus.                                            }

procedure TDOSThread.OutputErrorMessage;
begin
  {hier die Ausgabe der Fehlermeldung implementieren!}
end;

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
  {hier die Ausgabe des Kommandozeilenprogramms prüfen und entsprechende
   Flags setzten.}
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

end.
