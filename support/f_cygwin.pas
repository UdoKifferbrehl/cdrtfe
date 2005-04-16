{ f_cygwin.pas: cygwin-Funktionen

  Copyright (c) 2004 Oliver Valencia

  letzte Änderung  16.09.2004

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
    
}

unit f_cygwin;

{$I directives.inc}

interface

uses Windows, Registry;

function GetCygwinPathPrefix: string;
function MakePathCygwinConform(Path: string):string;
function MakePathMkisofsConform(const Path: string):string;
function MakePathMingwMkisofsConform(const Path: string): string;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_strings, f_misc;

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
var p: Integer;
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
  {Pfade für Cygwin anpassen, dabei auf das = für -graft-points achten}
  p := Pos('=', Path);
  if p <> 0 then
  begin
    Delete(Path, p, 1);
    // Insert('=/cygdrive/', Path, p);
    Insert('=' + CygPathPrefix + '/', Path, p);
  end else
  begin
    // Path := '/cygdrive/' + Path;
    Path := CygPathPrefix +'/' + Path;
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

initialization
  CygPathPrefix := 'unknown';

end.
