{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  f_dllfuncs.pas: Exportierte Funktionen der Debug-DLL

  Copyright (c) 2007 Oliver Valencia

  letzte �nderung  22.06.2007

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  f_dllfuncs.pas stellt Funktionen dieser DLL nach au�en hin zur Verf�gung:
    * Debug-Fenster erstellen und freigeben
    * Strings bzw. String-Listen ans Logfile anh�ngen
    * vordefinierte Strings ans Logfile anh�ngen


  exportierte Funktionen/Prozeduren:

    InitDebugForm(const AppHandle: THandle)
    FreeDebugForm
    ShowDebugForm
    AddLogStr(Value: PChar; Mode: Byte)
    AddLogPreDef(Value: Integer)

}

unit f_dllfuncs;

interface

uses Windows, Forms;

procedure InitDebugForm(const AppHandle: THandle); stdcall;
procedure FreeDebugForm;
procedure ShowDebugForm;
procedure AddLogStr(Value: PChar; Mode: Byte); stdcall;
procedure AddLogPreDef(Value: Integer); stdcall;

implementation

uses frm_dbg, f_log;

var FormDebug     : TFormDebug;
    OldHandle     : THandle;

{ exportierte DLL-Funktionen ------------------------------------------------- }

{ InitDebugForm ----------------------------------------------------------------

  Debug-Fenster erstellen und Handles entsprechen setzten.                     }

procedure InitDebugForm(const AppHandle: THandle); stdcall;
begin
  OldHandle := Application.Handle;
  Application.Handle := AppHandle;
  FormDebug := TFormDebug.Create(Application);
end;

{ FreeDebugForm ----------------------------------------------------------------

  Debug-Fenster freigeben und urspr�nlgiches Handle wiederherstellen.          }

procedure FreeDebugForm;
begin
  FormDebug.Release;
  Application.Handle := OldHandle;
end;

{ ShowDebugForm ----------------------------------------------------------------

  Debug-Fenster anzeigen.                                                      }

procedure ShowDebugForm;
begin
  try
    FormDebug.Show;
  except
  end;
end;

{ AddLogStr --------------------------------------------------------------------

  AddLog f�gt eine Zeile an das Log-File an.                                   }

procedure AddLogStr(Value: PChar; Mode: Byte); stdcall;
begin
  AddLogStrInt(string(Value), Mode, FormDebug.MemoLog.Lines);
end;

{ AddLogPreDef -----------------------------------------------------------------

  AddLogPreDef f�gt die durch Value bestimmte Zeige an das Log-File an.        }

procedure AddLogPreDef(Value: Integer); stdcall;
begin
  AddLogPreDefInt(Value, FormDebug.MemoLog.Lines);
end;

end.
