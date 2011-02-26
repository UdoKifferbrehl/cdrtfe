{ f_instance.pas: Instanzen-Management

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  02.10.2008

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  f_instance.pas stellt systembezogene Funktionen zur Verf�gung:
    * Instanzenmanagement


  exportierte Funktionen/Prozeduren:

    IsAlreadyRunning: Boolean
    IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean

}

unit f_instance;

{$I directives.inc}

interface

uses Windows, Classes, Forms, SysUtils, ShellAPI, TlHelp32;

function IsAlreadyRunning: Boolean;
function IsFirstInstance(var hwndPrevInstance: HWnd; WType, WCaption: string): Boolean;

implementation

var MutexHandle   : THandle;
    AlreadyRunning: Boolean;   // True = andere Instanz von cdrtfe l�uft bereits

{ IsAlreadRunning --------------------------------------------------------------

  True, wenn bereits eine Instanz l�uft.                                       }

function IsAlreadyRunning: Boolean;
begin
  Result := AlreadyRunning;
end;

{ IsFirstInstance --------------------------------------------------------------

  IsFirstInstance pr�ft, ob die Instanz, die diese Funktion aufruft, die erste
  Instanz von cdrtfe ist.
  Argumente:    hwndPrevInstance  Variable f�r die R�ckgabe des Handles zur
                                  vorigen Instanz, sofern vorhanden. Wenn keine
                                  andere Instanz l�uft, wird das Handle der
                                  aktuellen Instanzzur�ckgegeben.
                WType             Typ des Hauptfensters
                WCAption          Fenstertitel
  R�ckgabewert: True, wenn keine weitere Instanz gefunden wurde, False sonst   }

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

initialization
  MutexHandle := CreateMutex(nil, True,
                             PChar(ExtractFileName(Application.ExeName)));
  AlreadyRunning := GetLastError = ERROR_ALREADY_EXISTS;

finalization
  if MutexHandle <> 0 then CloseHandle(MutexHandle);

end.
