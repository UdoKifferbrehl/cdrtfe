{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_helper.pas: Hilfsfunktionen

  Copyright (c) 2005 Oliver Valencia

  letzte Änderung  28.09.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_helper.pas stellt Hilfsfunktionen zur Verfügung
    * Reload bei einem Laufwerk durchführen
    * Laufwerk öffenen/schließen


  exportierte Funktionen/Prozeduren:

    EjectDisk(const Dev: string);
    LoadDisk(const Dev: string);
    ReloadDisk(const Dev: string): Boolean;

}

unit f_helper;

{$I directives.inc}

interface

function ReloadDisk(const Dev: string): Boolean;
procedure EjectDisk(const Dev: string);
procedure LoadDisk(const Dev: string);

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

end.
