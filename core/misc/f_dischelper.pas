{ $Id: f_dischelper.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_dischelper.pas: Hilfsfunktionen

  Copyright (c) 2005-2009 Oliver Valencia

  letzte Änderung  04.04.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_dischelper.pas stellt Hilfsfunktionen zur Verfügung
    * Reload bei einem Laufwerk durchführen
    * Laufwerk öffenen/schließen
    * prüfen, ob eine DVD eingelegt ist


  exportierte Funktionen/Prozeduren:

    DiskInserted(const Dev: string): Boolean
    DiskIsDVD(const Dev: string): Boolean
    EjectDisk(const Dev: string)
    LoadDisk(const Dev: string)
    ReloadDisk(const Dev: string): Boolean
}

unit f_dischelper;

{$I directives.inc}

interface

function DiskInserted(const Dev: string): Boolean;
function DiskIsDVD(const Dev: string): Boolean;
function ReloadDisk(const Dev: string): Boolean;
procedure EjectDisk(const Dev: string);
procedure LoadDisk(const Dev: string);

implementation

uses f_locations, f_strings, f_helper, f_getdosoutput,
     const_locations, const_common;

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

{ DiskInserted -----------------------------------------------------------------

  True : Es ist eine Disk im Laufwerk.
  False: Das Laufwerk ist leer.                                                }

function DiskInserted(const Dev: string): Boolean;
var CommandLine: string;
    Output     : string;
begin
  CommandLine := StartUpDir + cCdrecordBin;
  CommandLine := QuotePath(CommandLine);
  CommandLine := CommandLine + ' dev=' + Dev + ' -toc';
  Output := GetDOSOutput(PChar(CommandLine), True, False);
  Result := (Pos('No disk / Wrong disk!', Output) = 0) and
            (Pos('Cannot load media with this drive', Output) = 0);
end;

end.
