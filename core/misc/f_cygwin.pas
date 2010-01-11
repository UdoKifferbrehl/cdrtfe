{ $Id: f_cygwin.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_cygwin.pas: cygwin-Funktionen

  Copyright (c) 2004-2010 Oliver Valencia

  letzte Änderung  12.12.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_cygwin.pas stellt Funktionen zur Verfügung, die mit der cygwin-Umgebung zu
  tun haben:
    * Zugriff auf Einstellungen der cygwin-Umgebung
    * Konvertieren von Pfadangaben


  exportierte Funktionen/Prozeduren:

    GetCygwinPathPrefix: string
    MakePathCygwinConform(Path: string):string
    MakePathMkisofsConform(const Path: string):string
    MakePathMingwMkisofsConform(const Path: string):string
    SetUseOwnCygwinDLLs(Value: Boolean);
    UseOwnCygwinDLLs: Boolean
    
}

unit f_cygwin;

{$I directives.inc}

interface

uses Windows, SysUtils, Registry, IniFiles;

function CheckForActiveCygwinDLL: Boolean;
function GetCygwinPathPrefix: string;
function MakePathCygwinConform(Path: string):string;
function MakePathMkisofsConform(const Path: string):string;
function MakePathMingwMkisofsConform(const Path: string): string;
function UseOwnCygwinDLLs: Boolean;
procedure SetUseOwnCygwinDLLs(Value: Boolean);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     cl_cdrtfedata, f_strings, f_filesystem, f_locations, const_locations;

{ 'statische' Variablen }
var CygPathPrefix : string;           // Cygwin-Mountpoint

{ GetCygwinPathPrefix ----------------------------------------------------------

  liefert den Cygwin-Mountpoint für Windowslaufwerke (normalerweise /cygdrive).}

function GetCygwinPathPrefix: string;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      {Cygwin Path Prefix zuerst in HKCU suchen}
      RootKey := HKEY_CURRENT_USER;
      OpenKey('\Software\Cygnus Solutions\Cygwin\mounts v2', False);
      try
        Result := ReadString('cygdrive prefix');
      except
        {Wenn etwas schiefgeht 'cygdrive prefix' also nicht vorhanden ist,
         setzen wir das Ergebnis aus '', damit in HKLM gesucht wird. Aufgrund
         eines Fehlers in TRegistry wird diese Exception aber nie ausgelöst, was
         kein Problem ist, da Result in diesem Fall ein Leerstring ist.}
        Result := '';
      end;
      {Wenn in HKCU nichts gefunden wird, dann vielleicht in HKLM}
      if Result = '' then
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        OpenKey('\Software\Cygnus Solutions\Cygwin\mounts v2', False);
        try
          Result := ReadString('cygdrive prefix');
        except
          Result := '';
        end;
      end;
      {Wenn das Prefix '/' ist, müssen wir mit '' arbeiten.}
      if Result = '/' then Result := '' else
      {Wenn nichts gefunden wurde, arbeiten wir mit dem cygwin-Default.}
      if Result = '' then Result := '/cygdrive';
    end;
  finally
    Reg.Free;
  end;
end;

{ MakePathCygwinConform --------------------------------------------------------

  MakePathCygwinconform wandelt Pfade so um, daß sie kompatibel sind zu den
  Konventionen der Cygwin-Umgebung.
  Wenn die Pfadangaben '=' enthalten (aus der Graft-Points-Pfadliste), wird dies
  korrekt behandelt.                                                           }

function MakePathCygwinConform(Path: string):string;
var p     : Integer;
    Target: string;
begin
  if CygPathPrefix = 'unknown' then CygPathPrefix := GetCygwinPathPrefix;
  {standardkonforme Pfadangaben benutzen / statt \}
  Path := ReplaceChar(Path, '\', '/');
  {Doppelpunkt bei Laufwerksangabe entfernen}
  p := Pos(':', Path);
  if p <> 0 then
  begin
    Delete(Path, p, 1);
  end;
  {Pfade für Cygwin anpassen, dabei auf das = für -graft-points achten. UNC-
   Pfade (\\server\...) können bleiben, wie sie sind.}
  p := Pos('=', Path);
  if p <> 0 then
  begin
    SplitString(Path, '=', Target, Path);
    if IsUNCPath(Path) then
    begin
      Path := Target + '=' + Path;
    end else
    begin
      Path := Target + '=' + CygPathPrefix + '/' + Path;
    end;
  end else
  begin
    if not IsUNCPath(Path) then Path := CygPathPrefix +'/' + Path;
  end;
  Result := Path;
end;

{ MakePathMkisofsConform -------------------------------------------------------

  MakePathMkisofsconform ist nötig, um das Vorkommen von '=' in Dateinamen
  richtig zu behandeln.                                                        }

function MakePathMkisofsConform(const Path: string):string;
var Temp: string;
begin
  Temp := Path;                                            {$IFDEF DebugMMkC}
                                                           Deb(Path, 2);{$ENDIF}
  {nötiger Zwischenschritt:  = -> *}
  Temp := ReplaceChar(Temp, '=', '*');                     {$IFDEF DebugMMkC}
                                                           Deb(Temp, 2);{$ENDIF}
  {erster : -> =}
  Temp := ReplaceCharFirst(Temp, ':', '=');                {$IFDEF DebugMMkC}
                                                           Deb(Temp, 2);{$ENDIF}
  {\ -> / und x: -> /cygdrive/x}
  Temp := MakePathCygwinConform(Temp);                     {$IFDEF DebugMMkC}
                                                           Deb(Temp, 2);{$ENDIF}
  {* - > \=}
  Temp := ReplaceString(Temp, '*', '\=');
  Result := Temp;                                          {$IFDEF DebugMMkC}
                                                  Deb(Temp + #13#10, 2);{$ENDIF}
end;

{ MakePathMingwMkisofsConform --------------------------------------------------

  MakePathMkisofsconform ist nötig, um das Vorkommen von '=' in Dateinamen
  richtig zu behandeln. Da die Mingw-Version von mkisofs anders mit Pfaden um
  geht, ist eine eigene Funktion nötig.                                        }

function MakePathMingwMkisofsConform(const Path: string): string;
var Temp: string;
begin
  Temp := Path;
  {nötiger Zwischenschritt:  = -> *}
  Temp := ReplaceChar(Temp, '=', '*');
  {erster : -> =}
  Temp := ReplaceCharFirst(Temp, ':', '=');
  {\ -> /}
  Temp := ReplaceChar(Temp, '\', '/');
  {* - > \=}
  Temp := ReplaceString(Temp, '*', '\=');
  Result := Temp;
end;

const cCygOwnDLLSec  : string = 'CygwinDLL';
      cCygOwnDLL     : string = 'UseOwnDLLs';
      cCygCheckActive: string = 'CheckForActiveDLL';

{ UseOwnDLLs -------------------------------------------------------------------

  Wertet die Datei tools\cygwin\cygwin.ini aus.

  True:  Die mitgelieferten DLLs sollen verwendet werden, unabhängig davon, ob
         die cygwin1.dll im Suchpfad gefunden wurde.
  False: Die mitgelieferten DLLs sollen nur verwendet werden, wenn die
         cygwin1.dll nicht im Suchpfad gefunden wurde.                         }

function UseOwnCygwinDLLs: Boolean;
var Ini : TIniFile;
    Name: string;
begin
  Name := StartUpDir + cToolDir + cCygwinDir + cIniCygwin;
  Result := False;
  if FileExists(Name) then
  begin
    {$IFDEF WriteLogFile}
    AddLogCode(1256);
    {$ENDIF}
    Ini := TIniFile.Create(Name);
    Result := Ini.ReadBool(cCygOwnDLLSec, cCygOwnDLL, False);
    Ini.Free;
  end;
  {$IFDEF WriteLogFile}
  if Result then AddLogCode(1257) else AddLogCode(1258);
  {$ENDIF}
  {Wir benötigen den Wert in FSettings, daher hier Zugrif über Singleton. Sehr
   unschöne Lösung. Demnächst mal ändern.}
  TCdrtfeData.Instance.Settings.FileFlags.UseOwnDLLs := Result;
end;

{ SetUseOwnCygwinDLLs ----------------------------------------------------------

  Setzt die Option [CygwinDLL], UseOwnDLLs in tools\cygwin\cygwin.ini.         }

procedure SetUseOwnCygwinDLLs(Value: Boolean);
var Ini : TIniFile;
    Name: string;
begin
  Name := StartUpDir + cToolDir + cCygwinDir + cIniCygwin;
  Ini := TIniFile.Create(Name);
  Ini.WriteBool(cCygOwnDLLSec, cCygOwnDLL, Value);
  Ini.Free;
end;

{ CheckForActiveCygwinDLL ------------------------------------------------------

  True: nach geladener cygwin1.dll suchen
  False: nicht nach geladener cygwin1.dll suchen                               }

function CheckForActiveCygwinDLL: Boolean;
var Ini : TIniFile;
    Name: string;
begin
  Name := StartUpDir + cToolDir + cCygwinDir + cIniCygwin;
  Result := False;
  if FileExists(Name) then
  begin
    {$IFDEF WriteLogFile}
    AddLogCode(1256);
    {$ENDIF}
    Ini := TIniFile.Create(Name);
    Result := Ini.ReadBool(cCygOwnDLLSec, cCygCheckActive, False);
    Ini.Free;
  end;
end;
                
initialization
  CygPathPrefix := 'unknown';

end.
