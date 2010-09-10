{ $Id: f_helper.pas,v 1.2 2010/09/10 16:33:56 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_helper.pas: Hilfsfunktionen

  Copyright (c) 2005-2008 Oliver Valencia

  letzte �nderung  04.10.2008

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  f_helper.pas stellt Hilfsfunktionen zur Verf�gung
    * Eingabe-Liste f�r rrenc erzeugen
    * DVD-Video-Quellordner pr�fen
    * f�r Spezialf�lle aktuelles Verzeichnis festlegen


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

implementation

uses f_locations, const_locations;

const {$J+}
      SCSIInterface: string = '';
      {$J-}

{ SetSCSIInterface -------------------------------------------------------------

  setzt die 'statische' Variable SCSIInterface.                                }

procedure SetSCSIInterface(const SCSIIF: string);
begin
  SCSIInterface := '';
  if SCSIIF <> '' then SCSIInterface := SCSIIF + ':';
end;

{ SCSIIF -----------------------------------------------------------------------

  erg�nzt die Device-ID um die optionale Interface-Angabe.                     }

function SCSIIF(const Dev: string): string;
begin
  Result := SCSIInterface + Dev;
end;

{ ConvertXCDParamListToRrencInputList ------------------------------------------

  konvertiert die XCd-Pfadliste in eine Eingabeliste f�r rrenc.                }

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

  True:  Path ist eine g�ltige DVD-Quelle (enth�lt Video_TS)
  False: sonst

  Dies ist nur eine tempor�re L�sung.                                          }

function IsValidDVDSource(const Path: string): Boolean;
var VideoTS: string;
begin
  VideoTS := Path;
  if Path[Length(Path)] <> '\' then VideoTS := VideoTS + '\';
  VideoTS := VideoTS + 'Video_TS';
  Result := DirectoryExists(VideoTS);
end;

{ GetCurrentDir ----------------------------------------------------------------

  aktuelles Verzeichnis in Abh�nigkeit des Befehls f�r CreateProcess festlegen.}

function GetCurrentFolder(const CommandLine: string): string;
var Temp: string;
begin
  Temp := StartUpDir; //'';
  {Workaround for mkisofs 2.01.01a28 and above: Zeichensatztabellen werden im
   aktuellen Verzeicnis gesucht, wenn cygwin nicht komplett installiert ist.}
  if Pos(cMkisofsBin, CommandLine) > 0 then
  begin
    Temp := ExtractFilePath(CommandLine);
    Delete(Temp, Length(Temp), 1);
    Temp := Temp + cSiconvDir;
  end;
  if not DirectoryExists(Temp) then Temp := '';  
  Result := Temp;
  {$IFDEF WriteLogfile}
  // AddLogCode(1104);
  // AddLog(Result + CRLF, 2);
  {$ENDIF}
end;

end.
