{ f_logfile.pas: Funktionen zum Debuggen, Anzeigen und Schreiben eines Log-Files

  Copyright (c) 2004-2008 Oliver Valencia

  letzte Änderung  12.01.2008

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

uses Windows, Forms;

procedure AddLog(const Value: string; const Mode: Byte);
procedure AddLogCode(const Value: Integer);

implementation

uses f_filesystem, f_misc;

const cDebugDLL = 'cdrtfedbg.dll';
      cLogName  = 'cdrtfe_log.txt';

type TInitDebugForm = procedure(const AppHandle: THandle); stdcall;
     TFreeDebugForm = procedure; stdcall;
     TShowDebugForm = procedure; stdcall;
     TAddLogStr     = procedure(Value: PChar; Mode: Byte); stdcall;
     TAddLogPreDef  = procedure(Value: Integer); stdcall;
     TSetLogFile    = procedure(Value: PChar); stdcall;
     TSetAutoSave   = procedure(Value: Integer); stdcall;

var DLLName       : string;
    DebugDLLHandle: THandle;
    DLLLoaded     : Boolean = False;
    DoDebug       : Boolean = False;
    DoAutoSave    : Boolean = False;
    {Prozedurvariablen}
    InitDebugForm : TInitDebugForm = nil;
    FreeDebugForm : TFreeDebugForm = nil;
    ShowDebugForm : TShowDebugForm = nil;
    AddLogStr     : TAddLogStr     = nil;
    AddLogPreDef  : TAddLogPreDef  = nil;
    SetLogFile    : TSetLogFile    = nil;
    SetAutoSave   : TSetAutoSave   = nil;

{ InitDebugVars ----------------------------------------------------------------

  InitDebuigVars initialisiert einige der Variablen.                           }

procedure InitDebugVars;
begin
  DLLLoaded  := False;
  DLLName    := StartUpDir + '\' + cDebugDLL;
  DoAutoSave := CheckCommandLineSwitch('/debugAS');
  DoDebug    := CheckCommandLineSwitch('/debug') or DoAutosave;
end;

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
    @SetLogFile    := GetProcAddress(DebugDLLHandle, 'SetLogFile');
    @SetAutoSave   := GetProcAddress(DebugDLLHandle, 'SetAutoSave');    
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
  InitDebugVars;
  if DoDebug   then DLLLoaded := LoadDLL;
  if DLLLoaded then
  begin
    if DoAutoSave then SetAutoSave(1);
    SetLogFile(PChar(ProgDataDir + '\' + cLogName));
    InitDebugForm(Application.Handle);
    ShowDebugForm;
    AddLogCode(1010);
  end;

finalization
  AddLogCode(1011);
  UnloadDLL;

end.



