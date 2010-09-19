{ $Id: f_locations.pas,v 1.2 2010/09/19 08:52:23 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_locations.pas: Funktionen, um bestimmte cdrtfe-Ordner/-Dateien zu ermitteln

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  19.09.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_locations.pas stellt Funktionen zum Dateisystem zur Verfügung:
    * Funktionen, um bestimmte Ordner zu finden


  exportierte Funktionen/Prozeduren:

    DummyDir(Mode: Boolean)
    OverrideProgDataDir(const OverrideWithStartUpDir: Boolean)
    ProgDataDir: string
    ProgDataDirCreate
    StartUpDir: string
    TempDir: string

}

unit f_locations;

{$I directives.inc}

interface

uses Forms, Windows, SysUtils;

function DummyDirName: string;
function DummyFileName: string;
function ProgDataDir: string;
function StartUpDir: string;
function TempDir: string;
procedure DummyDir(Mode: Boolean);
procedure OverrideProgDataDir(const OverrideWithStartUpDir: Boolean);
procedure ProgDataDirCreate;

implementation

uses f_wininfo, f_environment, f_filesystem, f_logfile, const_common,
     const_locations;

    {'statische' Variablen}
var ProgDataDirOverride: string;

{ StartUpDir -------------------------------------------------------------------

  StartUpDir liefert das Verzeichnis, in dem sich cdrtfe.exe befindet.         }

function StartUpDir: string;
var Temp: string;
begin
  Temp := ExtractFileDir(ParamStr(0));
  if Temp[Length(Temp)] = '\' then
  begin
    Delete(Temp, Length(Temp), 1);
  end;
  Result := Temp;
end;

{ ProgDataDir ------------------------------------------------------------------

  ProgDataDir liefert das Verzeichnis, in dem die cdrtfe.ini und die temporären
  Dateien gespeichert werden.                                                  }

function ProgDataDir: string;
begin
  if PlatformWinNT then
  begin
    Result := GetShellFolder(CSIDL_LOCAL_APPDATA);
    if Result = '' then
    begin
      Result := GetShellFolder(CSIDL_APPDATA);
      if Result = '' then
      begin
        Result := GetShellFolder(CSIDL_COMMON_APPDATA);
      end;
    end;
    if Result = '' then
    begin
      Result := StartUpDir;
    end else
    begin
      Result := Result + cDataDir;
    end;
  end else
  begin
    Result := StartUpDir;
  end;
  if ProgDataDirOverride <> '' then Result := ProgDataDirOverride;
end;

{ ProgDataDirCreate ------------------------------------------------------------

  erzeugt das Datenverzeichnis unter NT-Systemen, sofern cdrtfe nicht im
  Portable-Mode läuft.                                                         }

procedure ProgDataDirCreate;
begin
  {$IFDEF WriteLogFile}
  AddLogCode(1302);
  AddLog(ProgDataDir + CRLF + ' ', 3);
  {$ENDIF}
  {Überprüfen, ob das Daten-Verzeichnis da ist. Wenn nicht, anlegen.}
  if PlatformWinNT then
  begin
    if not DirectoryExists(ProgDataDir) then MkDir(ProgDataDir);
  end;
end;

{ TempDir ----------------------------------------------------------------------

  TempDir liefert das %Temp%- bzw. %TMP%-Verzeichnis.                          }

function TempDir: string;
begin
  Result := GetEnvVarValue('TEMP');
  if Result = '' then Result := GetEnvVarValue('TMP');
end;

{ OverrideProgDataDir ----------------------------------------------------------

  OverrideProgDataDir ermöglicht es, ein anderes Verzeichnis für die temporären
  Dateien anzugeben, damit cdrtfe auch von CD läuft.}

procedure OverrideProgDataDir(const OverrideWithStartUpDir: Boolean);
var Dir: string;
begin
  if OverrideWithStartUpDir then
  begin
    ProgDataDirOverride := StartUpDir;
  end else
  begin
    Dir := '';
    while Dir = '' do
    begin
      Dir := ChooseDir('', '', Application.Handle);
      if DirectoryExists(Dir) then ProgDataDirOverride := Dir;
    end;
  end;
end;

{ DummyDirName -----------------------------------------------------------------

  Name des Dummy-Verzeichnisses.                                               }

function DummyDirName: string;
begin
  Result := ProgDataDir + cDummyDir;
end;

{ DummyDirName -----------------------------------------------------------------

  Name des Dummy-Verzeichnisses.                                               }

function DummyFileName: string;
begin
  Result := ProgDataDir + cDummyFile;
end;

{ DummyDir ---------------------------------------------------------------------

  Um auch leere Verzeichnisse auf die CD schreiben zu können, benötigen wir ein
  leeres Dummy-Verzeichnis. Mode: True   - Verzeichnis erstellen
                                  Falae  - Verzeichnis löschen
  Zusätzlich benötigen wir noch eine Dummy-Datei, falls Dateien aus einer
  bereits vorhandenen Session versteckt werden sollen.                         }

procedure DummyDir(Mode: Boolean);
var DummyFile: TextFile;
begin
  {Dummy-Verzeichnis}
  case Mode of
    True : if not DirectoryExists(DummyDirName) then MkDir(DummyDirName);
    False: if DirectoryExists(DummyDirName) then RemoveDir(DummyDirName);
  end;
  {Dummy-Datei}
  case Mode of
    True : if not FileExists(DummyFileName) then
           begin
             AssignFile(DummyFile, DummyFileName);
             Rewrite(DummyFile);
             Close(DummyFile);
           end;
    False: if FileExists(DummyFileName) then DeleteFile(DummyFileName);
  end;

end;

initialization
  ProgDataDirOverride := '';

end.
