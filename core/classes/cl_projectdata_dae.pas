{ $Id: cl_projectdata_dae.pas,v 1.1 2010/05/18 17:01:59 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_projectdata_dae.pas: Datentypen zur Speicherung der Pfadlisten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  18.05.2010

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  cl_projectdata_dae.pas implementiert das Objekt, in dem die zu dem Projekt
  Audio-CD hinzugef�gten Dateien gespeichert werden.


  TDAE

    Properties   TrackCount

    Methoden     Create
                 GetTrackList: TStringList

}

unit cl_projectdata_dae;

{$I directives.inc}

interface

uses Classes, SysUtils, const_core;

type TDAE = class(TObject)
     private
       FTrackList: TStringList;
       function GetTrackCount: Integer;
     public
       constructor Create;
       destructor Destroy; override;
       function GetTrackList: TStringList;
       property TrackCount: Integer read GetTrackCount;
     end;

implementation

// uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}

{ TDAE ----------------------------------------------------------------------- }

{ TDAE - private }

{ GetTrackCount ----------------------------------------------------------------

  GetTrackCount gibt die Anzahl der Tracks zur�ck.                             }

function TDAE.GetTrackCount: Integer;
begin
  Result := FTrackList.Count;
end;

{ TDAE - public }

constructor TDAE.Create;
begin
  inherited Create;
  FTrackList := TStringList.Create;
end;

destructor TDAE.Destroy;
begin
  FTrackList.Free;
  inherited Destroy;
end;

{ GetTrackList -----------------------------------------------------------------

  GetTrackList gibt eine Referenz auf die interne TrackListe zur�ck.

  Track-Eintrag: <Name>:<Laufzeit>*<Gr��e>                                     }

function TDAE.GetTrackList: TStringList;
begin
  Result := FTrackList;
end;

end.
