{ f_system.pas: allgemeine Systemfunktionen

  Copyright (c) 2010-2013 Oliver Valencia

  letzte Änderung  26.06.2013

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_system.pas stellt allgemeine Windows-System-Funktionen zur Verfügung:
    * Einstellen des DLL-Suchpfades


  exportierte Funktionen/Prozeduren:

    SetDLLDirectory(Path: string): Boolean

}

unit f_system;

{$I directives.inc}

interface

uses Windows, SysUtils;

function SetDLLDirectory(const Path: string): Boolean;

implementation

type TSetDLLDirectory = function(lpPathName: PChar):Bool; stdcall;

var SetDLLDirectoryInt: TSetDLLDirectory;

function SetDLLDirectory(const Path: string): Boolean;
begin
  if Assigned(SetDLLDirectoryInt) then
  begin
    Result := SetDLLDirectoryInt(PChar(Path));
  end else
    Result := False;
end;

procedure ImportSystemFunctions;
var DLL: HModule;
begin
  DLL := GetModuleHandle('kernel32.dll');
  if DLL = 0 then raise Exception.Create('kernel32 nicht geladen');
  {$IFDEF Unicode}
  SetDLLDirectoryInt := GetProcAddress(DLL, 'SetDllDirectoryW');  
  {$ELSE}
  SetDLLDirectoryInt := GetProcAddress(DLL, 'SetDllDirectoryA');
  {$ENDIF}
end;

initialization
  ImportSystemFunctions;

end.