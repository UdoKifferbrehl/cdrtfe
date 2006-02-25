{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_helper.pas: Hilfsfunktionen

  Copyright (c) 2005 Oliver Valencia

  letzte �nderung  28.09.2005

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  f_helper.pas stellt Hilfsfunktionen zur Verf�gung
    * Reload bei einem Laufwerk durchf�hren
    * Laufwerk �ffenen/schlie�en
    * Eingabe-Liste f�r rrenc erzeugen


  exportierte Funktionen/Prozeduren:

    EjectDisk(const Dev: string);
    LoadDisk(const Dev: string);
    ReloadDisk(const Dev: string): Boolean;

}

unit f_helper;

{$I directives.inc}

interface

uses Classes;

function ReloadDisk(const Dev: string): Boolean;
procedure EjectDisk(const Dev: string);
procedure LoadDisk(const Dev: string);
procedure ConvertXCDParamListToRrencInputList(Source, Dest: TStringList);

implementation

uses f_filesystem, f_process, f_strings, constant;

{ ReloadDisk -------------------------------------------------------------------

  ReloadDisk f�hrt beim Laufwerk mit der SCSI-ID Dev einen Reload durch.       }

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

  EjectDisk �ffent das Laufwerk mit der SCSI-ID Dev.                           }

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

  LoadDisk schlie�t das Laufwerk mit der SCSI-ID Dev.                          }

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

end.
