{ $Id: f_system.pas,v 1.1 2010/09/10 16:33:56 kerberos002 Exp $

  f_system.pas: allgemeine Systemfunktionen

  Copyright (c) 2010 Oliver Valencia

  letzte Änderung  10.09.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_system.pas stellt allgemeine Windows-System-Funktionen zur Verfügung:
    * Einstellen des DLL-Suchpfades


  exportierte Funktionen/Prozeduren:

    SetDLLDirectory(lpPathName:PAnsiChar): Bool

}

unit f_system;

{$I directives.inc}

interface

uses Windows, SysUtils;

function SetDLLDirectory(const Path: string): Boolean;

implementation

type TSetDLLDirectory = function(lpPathName: PAnsiChar):Bool; stdcall;

var SetDLLDirectoryInt: TSetDLLDirectory;

function SetDLLDirectory(const Path: string): Boolean;
begin
  if Assigned(SetDLLDirectoryInt) then
  begin
    Result := SetDLLDirectoryInt(PAnsiChar(Path));
  end else
    Result := False;
end;

procedure ImportSystemFunctions;
var DLL: HModule;
begin
  DLL := GetModuleHandle('kernel32.dll');
  if DLL = 0 then raise Exception.Create('kernel32 nicht geladen');
  SetDLLDirectoryInt := GetProcAddress(DLL, 'SetDllDirectoryA');
end;

initialization
  ImportSystemFunctions;

end.