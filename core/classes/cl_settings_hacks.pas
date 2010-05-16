{ $Id: cl_settings_hacks.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_hacks.pas: Objekt für Hacks

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_hacks.pas implemtiert ein Objekt für die Variablen, die Hacks steuern.


  TSettingsHacks

    Properties   DisableDVDCheck: Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_hacks;

interface

uses IniFiles, cl_abstractbase;

type TSettingsHacks = class(TCdrtfeSettings)
     private
       FDisableDVDCheck: Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property DisableDVDCheck: Boolean read FDisableDVDCheck;
     end;

implementation

{ TSettingsHacks ------------------------------------------------------------- }

{ TSettingsHacks - private }

{ TSettingsHacks - public }

constructor TSettingsHacks.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsHacks.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsHacks.Init;
begin
  FDisableDVDCheck := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsHacks.Load(MIF: TMemIniFile);
var Section: string;
begin
  if FAsInifile then
  begin
    Section := 'Hacks';
    with MIF do
    begin
      FDisableDVDCheck := ReadBool(Section, 'DisableDVDCheck', False);
    end;
    FAsInifile := False;
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsHacks.Save(MIF: TMemIniFile);
begin
  // THacks ist read-only, Einstellungen sind im Programm nicht veränderbar.
end;

end.

