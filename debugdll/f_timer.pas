{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  f_timer.pas: Funktionen zur Zeitmessung

  Copyright (c) 2002-2007 Oliver Valencia

  letzte Änderung  18.06.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_timer.pas stellt Funktionen zur Zeitmessung zur Verfügung:
    * Timer


  exportierte Funktionen/Prozeduren:

    x

  TTimeCount: Objekt zur Zeitmessung

    Properties   TimeAsInt
                 TimeAsString
                 CurrentTimeAsInt
                 CurrentTimeAsString

    Methodes     Create
                 StartTimeCount
                 StopTimeCount
                 Reset

}

unit f_timer;

interface

uses Windows, SysUtils;

type TTimeCount = class(TObject)
     private
       FStart: Longint;
       FStop: Longint;
       function GetCurrentTimeAsInt: Longint;
       function GetCurrentTimeAsString: string;
       function GetTimeAsInt: Longint;
       function GetTimeAsString: string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure StartTimeCount;
       procedure StopTimeCount;
       procedure Reset;
       property CurrentTimeAsInt: Longint read GetCurrentTimeAsInt;
       property CurrentTimeAsString: string read GetCurrentTimeAsString;
       property TimeAsInt: Longint read GetTimeAsInt;
       property TimeAsString: string read GetTimeAsString;
     end;

implementation

{ Hilfsfunktionen ------------------------------------------------------------ }

function FormatTime(const Time: Extended): string;
var Minuten: Integer;
    Sekunden: Double;
begin
  Minuten := Round(Int(Time)) div 60;
  Sekunden := Time - (Minuten * 60);
  Result := Format('%.2d', [Minuten]) + ':' + FormatFloat('00.00', Sekunden);
end;

{ TTimeCounter --------------------------------------------------------------- }

{ TTimeCounter - private }

function TTimeCount.GetCurrentTimeAsInt: Longint;
begin
  Result := GetTickCount - FStart;
end;

function TTimeCount.GetCurrentTimeAsString: string;
begin
  Result := FormatTime(GetCurrentTimeAsInt/1000);
end;

function TTimeCount.GetTimeAsInt: Longint;
begin
  Result := FStop - FStart;
end;

function TTimeCount.GetTimeAsString: string;
begin
  Result := Format('%f Sekunden', [(FStop - FStart) / 1000]);
end;

{ TTimeCounter - public }

constructor TTimeCount.Create;
begin
  inherited Create;
  FStart := 0;
  FStop := 0;
end;

destructor TTimeCount.Destroy;
begin
  inherited Destroy;
end;

procedure TTimeCount.StartTimeCount;
begin
  FStart := GetTickCount;
end;

procedure TTimeCount.StopTimeCount;
begin
  FStop := GetTickCount;
end;

procedure TTimeCount.Reset;
begin
  FStart := 0;
  FStop := 0;
end;

end.
