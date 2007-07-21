{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_cueinfo.pas: Infos �ber Cue-Dateien

  Copyright (c) 2007 Oliver Valencia

  letzte �nderung  21.07.2007

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  cl_cueinfo.pas implementiert ein Objekt, das Informationen �ber Cue-Dateien
  ermittelt:
    * Audio-Tracks


  TCueFile

    Properties   Name
                 IsAudio

    Methoden     Create
                 GetInfo
                 
}

unit cl_cueinfo;

interface

uses Classes, SysUtils;

type TCueFile = class(TObject)
     private
       FFileName: string;
       FCueFile : TStringList;
       FIsAudio : Boolean;
       function GetIsAudio: Boolean;
     public
       constructor Create(const CueFile: string);
       destructor Destroy; override;
       procedure GetInfo;
       property IsAudio: Boolean read FIsAudio;
     end;

implementation

{ TCueFile ------------------------------------------------------------------- }

{ TCueFile - private }

function TCueFile.GetIsAudio: Boolean;
begin
  Result := (Pos('audio', FCueFile.Text) > 0) or
            (Pos('AUDIO', FCueFile.Text) > 0);
end;

{ TCueFile - public }

constructor TCueFile.Create(const CueFile: string);
begin
  FFileName := CueFile;
  FCueFile := TStringList.Create;
  FIsAudio := False;
end;

destructor TCueFile.Destroy;
begin
  FCueFile.Free;
end;

{ GetInfo ----------------------------------------------------------------------

  l�dt die Cue-Datei und ermittelt die Informationen.                          }

procedure TCueFile.GetInfo;
begin
  if FileExists(FFileName) then
  begin
    FCueFile.LoadFromFile(FFileName);
    FIsAudio := GetIsAudio;
  end;
end;

end.
