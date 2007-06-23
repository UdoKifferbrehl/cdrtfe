{ f_logfile.pas: Funktionen zum Debuggen, Anzeigen und Schreiben eines Log-Files

  Copyright (c) 2004-2007 Oliver Valencia

  letzte Änderung  21.06.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_debug.pas stellt Funktionen zum Debuggen, Anzeigen und Schreiben eines
  Log-Files zur Verfügung:
    * String bzw. String-Liste an das Log-File anfügen


  exportierte Funktionen/Prozeduren:

    AddLog(const Value: string; const Show: Byte)
    AddLogAddStringList(List: TStringList)

}


unit f_logfile;

{$I directives.inc}

interface

uses Windows, Forms{, Classes, SysUtils};

procedure AddLog(const Value: string; const Mode: Byte);
procedure AddLogCode(const Value: Integer);

implementation

uses f_filesystem;

const cDebugDLL = 'cdrtfedbg.dll';
      cLogName  = 'cdrtfe_log.txt';

type TInitDebugForm = procedure(const AppHandle: THandle); stdcall;
     TFreeDebugForm = procedure; stdcall;
     TShowDebugForm = procedure; stdcall;
     TAddLogStr     = procedure(Value: PChar; Mode: Byte); stdcall;
     TAddLogPreDef  = procedure(Value: Integer); stdcall;
     TSetLogFile    = procedure(Value: PChar); stdcall;

var DLLName       : string;
    DebugDLLHandle: THandle;
    DLLLoaded     : Boolean = False;
    InitDebugForm : TInitDebugForm = nil;
    FreeDebugForm : TFreeDebugForm = nil;
    ShowDebugForm : TShowDebugForm = nil;
    AddLogStr     : TAddLogStr     = nil;
    AddLogPreDef  : TAddLogPreDef  = nil;
    SetLogFile    : TSetLogFile    = nil;

{ LoadDll ----------------------------------------------------------------------

  Debug-DLL laden und die Funktionsadressen bestimmen.                         }

function LoadDLL: Boolean;
begin
  DebugDLLHandle := LoadLibrary(PChar(DLLName));
  if DebugDLLHandle > 0 then
  begin
    @InitDebugForm := GetProcAddress(DebugDLLHandle, 'InitDebugForm');
    @FreeDebugForm := GetProcAddress(DebugDLLHandle, 'FreeDebugForm');
    @ShowDebugForm := GetProcAddress(DebugDLLHandle, 'ShowDebugForm');
    @AddLogStr     := GetProcAddress(DebugDLLHandle, 'AddLogStr');
    @AddLogPreDef  := GetProcAddress(DebugDLLHandle, 'AddLogPreDef');
    //@SetLogFile := GetProcAddress(DebugDLLHandle, 'SetLogFile');
    Result := True;
  end else
    Result := False;
end;

{ UnloadDll --------------------------------------------------------------------

  Debug-DLL entladen.                                                          }

procedure UnloadDLL;
begin
  if Assigned(FreeDebugForm) then FreeDebugForm;
  if DebugDLLHandle > 0 then FreeLibrary(DebugDllHandle);
end;

{ AddLog -----------------------------------------------------------------------

  AddLog fügt eine Zeile an das Logfile an.                                    }

procedure AddLog(const Value: string; const Mode: Byte);
begin
  if DllLoaded then AddLogStr(PChar(Value), Mode);
end;

{ AddLogCode -------------------------------------------------------------------

  AddLog fügt eine durch Value vordefinierte Zeile an das Logfile an.          }

procedure AddLogCode(const Value: Integer);
begin
  if DllLoaded then AddLogPreDef(Value);
end;

initialization
  DLLName := StartUpDir + '\' + cDebugDLL;
  DLLLoaded := LoadDLL;
  if DLLLoaded then
  begin
    InitDebugForm(Application.Handle);
    ShowDebugForm;
    AddLogCode(1010);
    //SetLogFile(PChar(StartUpDir + '\' + cLogName));
  end;

finalization
  AddLogCode(1011);
  UnloadDLL;

end.

                                             (*
{ 'statische' Variablen }
var AddLogFirstRun: Boolean;          // Flag für AddLog

{ AddLog -----------------------------------------------------------------------

  AddLog fügt eine Zeile an das Log-File an. Falls die Datei log.txt noch nicht
  existiert, wird sie angelegt. Wenn Show=0 ist, wird der Log-Eintrag nicht als
  Message-Box angezeigt.                                                       }

procedure AddLog(const Value: string; const Show: Byte);
var LogName: string;
    Log: TextFile;
begin
  LogName := StartUpDir + '\log.txt';
  if AddLogFirstRun then
  begin
    if not FileExists(LogName) then
    begin
      AssignFile(Log, LogName);
      Rewrite(Log);
    end else
    begin
      AssignFile(log, LogName);
      Append(Log);
    end;
    WriteLn(Log, '------------------------------------------------------------');
    WriteLn(Log, 'cdrtfe Log-File');
    WriteLn(Log, '');
    Close(Log);
    AddLogFirstRun := False;
  end;
  AssignFile(Log, LogName);
  Append(Log);
  WriteLn(Log, Value);
  Close(Log);
  if Show <> 0 then
  begin
    Application.MessageBox(Pchar(Value), 'Debug-Info',
                           MB_OK or MB_ICONEXCLAMATION);
  end;
end;

{ AddLogAddStringList ----------------------------------------------------------

  AddLogAddStringList schreibt den Inhalt der String-Liste ins Log-File.       }

procedure AddLogAddStringList(List: TStringList);
var i: Integer;
    LogName: string;
    Log: TextFile;
begin
  if AddLogFirstRun then
  begin
    LogName := StartUpDir + '\log.txt';
    if not FileExists(LogName) then
    begin
      AssignFile(Log, LogName);
      Rewrite(Log);
    end else
    begin
      AssignFile(log, LogName);
      Append(Log);
    end;
    WriteLn(Log, '------------------------------------------------------------');
    WriteLn(Log, 'cdrtfe Log-File');
    WriteLn(Log, '');
    Close(Log);
    AddLogFirstRun := False;
  end;
  AssignFile(Log, LogName);
  Append(Log);
  for i := 0 to List.Count - 1 do
  begin
    WriteLn(Log, List[i]);
  end;
  Close(Log);
end;

initialization
  AddLogFirstRun := True;                           *)


