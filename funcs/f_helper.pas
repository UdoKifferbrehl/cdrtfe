{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_helper.pas: Hilfsfunktionen

  Copyright (c) 2005-2006 Oliver Valencia

  letzte Änderung  26.07.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_helper.pas stellt Hilfsfunktionen zur Verfügung
    * Reload bei einem Laufwerk durchführen
    * Laufwerk öffenen/schließen
    * Eingabe-Liste für rrenc erzeugen
    * DVD-Video-Quellordner prüfen
    * prüfen, ob eine DVD eingelegt ist


  exportierte Funktionen/Prozeduren:

    ConvertXCDParamListToRrencInputList(Source, Dest: TStringList)
    DiskIsDVD(const Dev: string): Boolean
    EjectDisk(const Dev: string);
    LoadDisk(const Dev: string);
    ReloadDisk(const Dev: string): Boolean;
    IsValidDVDSource(const Path: string): Boolean;

}

unit f_helper;

{$I directives.inc}

interface

uses Classes, FileCtrl;

function DiskIsDVD(const Dev: string): Boolean;
function IsValidDVDSource(const Path: string): Boolean;
function ReloadDisk(const Dev: string): Boolean;
procedure EjectDisk(const Dev: string);
procedure LoadDisk(const Dev: string);
procedure ConvertXCDParamListToRrencInputList(Source, Dest: TStringList);

implementation

uses f_filesystem, f_process, f_strings, constant;

{ ReloadDisk -------------------------------------------------------------------

  ReloadDisk führt beim Laufwerk mit der SCSI-ID Dev einen Reload durch.       }

function ReloadDisk(const Dev: string): Boolean;
var Temp       : string;
    ReloadError: Boolean;
begin
  Temp := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  Temp := QuotePath(Temp);
  {$ENDIF}
  Temp := Temp + ' dev=' + Dev + ' -eject';
  Temp := GetDosOutput(PChar(Temp), True);
  ReloadError := (Pos('Cannot load media with this drive!', Temp) > 0) or
                 (Pos('Try to load media by hand.', Temp) > 0) or
                 (Pos('Cannot load media.', Temp) > 0);
  if not ReloadError then
  begin
    Temp := StartUpDir + cCdrecordBin;
    {$IFDEF QuoteCommandlinePath}
    Temp := QuotePath(Temp);
    {$ENDIF}
    Temp := Temp + ' dev=' + Dev + ' -load';
    Temp := GetDosOutput(PChar(Temp), True);
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
  {$IFDEF QuoteCommandlinePath}
  Temp := QuotePath(Temp);
  {$ENDIF}
  Temp := Temp + ' dev=' + Dev + ' -eject';
  Temp := GetDosOutput(PChar(Temp), True);
end;

{ LoadDisk ---------------------------------------------------------------------

  LoadDisk schließt das Laufwerk mit der SCSI-ID Dev.                          }

procedure LoadDisk(const Dev: string);
var Temp: string;
begin
  Temp := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  Temp := QuotePath(Temp);
  {$ENDIF}
  Temp := Temp + ' dev=' + Dev + ' -load';
  Temp := GetDosOutput(PChar(Temp), True);
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
  {$IFDEF QuoteCommandlinePath}
  Temp := QuotePath(Temp);
  {$ENDIF}
  Temp := Temp + ' dev=' + Dev + ' -checkdrive';
  Temp := GetDosOutput(PChar(Temp), True);
  p := Pos('Driver flags   :', Temp);
  Delete(Temp, 1, p);
  p := Pos(LF, Temp);
  Temp := Copy(Temp, 1, p);
  Result := Pos('DVD', Temp) > 0;
end;

end.
