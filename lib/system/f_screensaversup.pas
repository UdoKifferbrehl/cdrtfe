{ $Id: f_screensaversup.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_screensaversup.pas: Bildschirmschoner (de-)aktivieren

  Copyright (c) 2009      Oliver Valencia

  letzte �nderung  28.08.2009

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  f_screensaversup.pas stellt Funktionen zur Verf�gung, um den Bildschirmschoner
  tempor�r zu deaktivieren. Dies funktioniert nur, wenn sich das Programm im
  Vordergrund befindet.


  exportierte Funktionen/Prozeduren:

    ActivateScreenSaver
    DeactivateScreenSaver

}

unit f_screensaversup;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils;

procedure ActivateScreenSaver;
procedure DeactivateScreenSaver;

implementation

uses JvScreenSaveSuppress;

var ScreenSaveSuppressor: TJvScreenSaveSuppressor = nil;

procedure ScreenSaverSuppressorInit(AOwner: TComponent);
begin
  if AOwner = nil then AOwner := Application.MainForm;
  ScreenSaveSuppressor := TJvScreenSaveSuppressor.Create(AOwner);
end;

procedure ActivateScreenSaver;
begin
  if ScreenSaveSuppressor <> nil then
  begin
    ScreenSaveSuppressor.Active := False;
    FreeAndNil(ScreenSaveSuppressor);
  end;
end;

procedure DeactivateScreenSaver;
begin
  if ScreenSaveSuppressor = nil then ScreenSaverSuppressorInit(nil);
  ScreenSaveSuppressor.Active := True;
end;
  
end.
