{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_helper.pas: Hilfsfunktionen

  Copyright (c) 2005-2016 Oliver Valencia

  letzte Änderung  23.04.2016

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_helper.pas stellt Hilfsfunktionen zur Verfügung
    * Eingabe-Liste für rrenc erzeugen
    * DVD-Video-Quellordner prüfen
    * für Spezialfälle aktuelles Verzeichnis festlegen


  exportierte Funktionen/Prozeduren:

    ConvertXCDParamListToRrencInputList(Source, Dest: TStringList)
    DiskIsDVD(const Dev: string): Boolean
    SCSIIF(const Dev: string): string
    SetSCSIInterface(const SCSIIF: string);    
    IsValidDVDSource(const Path: string): Boolean
    GetCurrentFolder(const CommandLine: string): string

}

unit f_helper;

{$I directives.inc}

interface

uses Classes, SysUtils;

function GetCurrentFolder(const CommandLine: string): string;
function IsValidDVDSource(const Path: string): Boolean;
function SCSIIF(const Dev: string): string;
procedure ConvertXCDParamListToRrencInputList(Source, Dest: TStringList);
procedure SetSCSIInterface(const SCSIIF: string);
procedure SetIsMinGW(const Value: Boolean);

implementation

uses {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     f_locations, const_locations;

const {$J+}
      SCSIInterface: string = '';
      IsMinGW: Boolean = False;
      {$J-}

{ SetIsMinGW -------------------------------------------------------------------

  setzt die 'statische' Variable SCSIInterface.                                }

procedure SetIsMinGW(const Value: Boolean);
begin
  IsMinGW := Value;
end;

{ SetSCSIInterface -------------------------------------------------------------

  setzt die 'statische' Variable SCSIInterface.                                }

procedure SetSCSIInterface(const SCSIIF: string);
begin
  SCSIInterface := '';
  if SCSIIF <> '' then SCSIInterface := SCSIIF + ':';
end;

{ SCSIIF -----------------------------------------------------------------------

  ergänzt die Device-ID um die optionale Interface-Angabe.                     }

function SCSIIF(const Dev: string): string;
begin
  Result := SCSIInterface + Dev;
end;

{ ConvertXCDParamListToRrencInputList ------------------------------------------

  konvertiert die XCd-Pfadliste in eine Eingabeliste für rrenc.                }

procedure ConvertXCDParamListToRrencInputList(Source, Dest: TStringList);
var i   : Integer;
    Temp: string;
begin
  Dest.Clear;
  i := 0;
  while i < Source.Count do
  begin
    Temp := Source[i];
    if (Temp = '-m') or (Temp = '-f') or (Temp = '-d') then
    begin
      if Temp = '-m' then Temp := '-x ' + Source[i + 1] else
      if Temp = '-f' then Temp := '-i ' + Source[i + 1] else
      if Temp = '-d' then Temp := '-d ' + Source[i + 1];
      Dest.Add(Temp);
    end;
    Inc(i);
  end;
  Dest.Add('-d _rec_');
  Dest.Add('-@');
  Dest.Add('-r');
end;

{ IsValidDVDSoure --------------------------------------------------------------

  True:  Path ist eine gültige DVD-Quelle (enthält Video_TS)
  False: sonst

  Dies ist nur eine temporäre Lösung.                                          }

function IsValidDVDSource(const Path: string): Boolean;
var VideoTS: string;
begin
  VideoTS := Path;
  if Path[Length(Path)] <> '\' then VideoTS := VideoTS + '\';
  VideoTS := VideoTS + 'Video_TS';
  Result := DirectoryExists(VideoTS);
end;

{ GetCurrentDir ----------------------------------------------------------------

  aktuelles Verzeichnis in Abhänigkeit des Befehls für CreateProcess festlegen.}

function GetCurrentFolder(const CommandLine: string): string;
var Temp: string;
begin
  Temp := StartUpDir;
  {Workaround für MinGW-Version von mkisofs: die Zeichensatztabellen werden nur
   gefunden, wenn das aktuelle Verzeichnis <cdrtfe>\tools\cdrtools ist.}
  if IsMinGW and (Pos(cMkisofsBin, CommandLine) > 0) then
  begin
    Temp := Temp + cToolDir + cCdrtoolsDir;
  end;
  Result := Temp;
  {$IFDEF WriteLogfile}
  AddLogCode(1104);
  AddLog(Result, 12);
  {$ENDIF}
end;

end.
