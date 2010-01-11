{ $Id: cl_timecount.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  cl_timecount.pas: Zeitmessung

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  02.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_timecount.pas stellt Hilfs-Funktionen zur Verfügung:
    * Funktionen zur Zeitmessung


  TTimeCount: Objekt zur Zeitmessung

    Properties   TimeAsInt
                 TimeAsString

    Methodes     Create

}

unit cl_timecount;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils;

type TTimeCount = class(TObject)
     private
       FStart: Longint;
       FStop: Longint;
       function GetTimeAsInt: Longint;
       function GetTimeAsString: string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure StartTimeCount;
       procedure StopTimeCount;
       procedure Reset;
       property TimeAsInt: Longint read GetTimeAsInt;
       property TimeAsString: string read GetTimeAsString;
     end;

implementation

{ TTimeCounter --------------------------------------------------------------- }

{ TTimeCounter - private }

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
