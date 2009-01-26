{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_helper.pas: Hilfsfunktionen

  Copyright (c) 2005-2009 Oliver Valencia

  letzte Änderung 26.01.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_helper.pas stellt Hilfsfunktionen zur Verfügung
    * Reload bei einem Laufwerk durchführen
    * Laufwerk öffenen/schließen
    * Eingabe-Liste für rrenc erzeugen
    * DVD-Video-Quellordner prüfen
    * prüfen, ob eine DVD eingelegt ist
    * für Spezialfälle aktuelles Verzeichnis festlegen


  exportierte Funktionen/Prozeduren:

    ConvertXCDParamListToRrencInputList(Source, Dest: TStringList)
    DiskIsDVD(const Dev: string): Boolean
    EjectDisk(const Dev: string)
    LoadDisk(const Dev: string)
    ReloadDisk(const Dev: string): Boolean
    SCSIIF(const Dev: string): string
    SetSCSIInterface(const SCSIIF: string);    
    IsValidDVDSource(const Path: string): Boolean
    GetCurrentFolder(const CommandLine: string): string

}

unit f_helper;

{$I directives.inc}

interface

uses Classes, FileCtrl, SysUtils;

function DiskIsDVD(const Dev: string): Boolean;
function GetCurrentFolder(const CommandLine: string): string;
function IsValidDVDSource(const Path: string): Boolean;
function ReloadDisk(const Dev: string): Boolean;
function SCSIIF(const Dev: string): string;
procedure EjectDisk(const Dev: string);
procedure LoadDisk(const Dev: string);
procedure ConvertXCDParamListToRrencInputList(Source, Dest: TStringList);
procedure SetSCSIInterface(const SCSIIF: string);

implementation

uses {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     f_filesystem, f_process, f_strings, constant;

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

  ergänzt die Device-ID um die optionale Interface-Angabe.                     }

function SCSIIF(const Dev: string): string;
begin
  Result := SCSIInterface + Dev;
end;

{ ReloadDisk -------------------------------------------------------------------

  ReloadDisk führt beim Laufwerk mit der SCSI-ID Dev einen Reload durch.       }

function ReloadDisk(const Dev: string): Boolean;
var Temp       : string;
    ReloadError: Boolean;
begin
  Temp := StartUpDir + cCdrecordBin;
  Temp := QuotePath(Temp);
  Temp := Temp + ' dev=' + SCSIIF(Dev) + ' -eject';
  Temp := GetDosOutput(PChar(Temp), True, False);
  ReloadError := (Pos('Cannot load media with this drive!', Temp) > 0) or
                 (Pos('Try to load media by hand.', Temp) > 0) or
                 (Pos('Cannot load media.', Temp) > 0);
  if not ReloadError then
  begin
    Temp := StartUpDir + cCdrecordBin;
    Temp := QuotePath(Temp);
    Temp := Temp + ' dev=' + SCSIIF(Dev) + ' -load';
    Temp := GetDosOutput(PChar(Temp), True, False);
    ReloadError := (Pos('Cannot load media with this drive!', Temp) > 0) or
                   (Pos('Try to load media by hand.', Temp) > 0) or
                   (Pos('Cannot load media.', Temp) > 0);
  end;
  Result := ReloadError;
end;

{ EjectDisk --------------------------------------------------------------------

  EjectDisk öffent das Laufwerk mit der SCSI-ID Dev.                           }

procedure EjectDisk(const Dev: string);
var Temp: string;
begin
  Temp := StartUpDir + cCdrecordBin;
  Temp := QuotePath(Temp);
  Temp := Temp + ' dev=' + SCSIIF(Dev) + ' -eject';
  Temp := GetDosOutput(PChar(Temp), True, False);
end;

{ LoadDisk ---------------------------------------------------------------------

  LoadDisk schließt das Laufwerk mit der SCSI-ID Dev.                          }

procedure LoadDisk(const Dev: string);
var Temp: string;
begin
  Temp := StartUpDir + cCdrecordBin;
  Temp := QuotePath(Temp);
  Temp := Temp + ' dev=' + SCSIIF(Dev) + ' -load';
  Temp := GetDosOutput(PChar(Temp), True, False);
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

{ DiskIsDVD --------------------------------------------------------------------

  True : eingelegte Disk ist eine DVD-ROM/-R/-RW/+R/+RW/DL
  False: Disk ist eine CD-ROM/-R/-RW oder es ist keine Disk im Laufwerk        }

function DiskIsDVD(const Dev: string): Boolean;
var Temp: string;
    p   : Integer;
begin
  Temp := StartUpDir + cCdrecordBin;
  Temp := QuotePath(Temp);
  Temp := Temp + ' dev=' + SCSIIF(Dev) + ' -checkdrive';
  Temp := GetDosOutput(PChar(Temp), True, True);
  p := Pos('Driver flags   :', Temp);
  Delete(Temp, 1, p);
  p := Pos(LF, Temp);
  Temp := Copy(Temp, 1, p);
  Result := Pos('DVD', Temp) > 0;
end;

{ GetCurrentDir ----------------------------------------------------------------

  aktuelles Verzeichnis in Abhänigkeit des Befehls für CreateProcess festlegen.}

function GetCurrentFolder(const CommandLine: string): string;
var Temp: string;
begin
  Temp := '';
  {Workaround for mkisofs 2.01.01a28 and above: Zeichensatztabellen werden im
   aktuellen Verzeicnis gesucht, wenn cygwin nicht komplett installiert ist.}
  if (Pos(cMkisofsBin, CommandLine) > 0) or
      FileExists(ProgDataDir + cShCmdFile) then
  begin
    Temp := StartupDir + cToolDir + cCdrtoolsDir + cSIconvDir;
  end;
  if not DirectoryExists(Temp) then Temp := '';
  Result := Temp;
//  {$IFDEF WriteLogfile}
//  AddLogCode(1104);
//  AddLog(Result + CRLF, 2);
//  {$ENDIF}
end;

end.
