{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_cdrw.pas: Objekt für Einstellungen des CDRW-Projektes

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_cdrw.pas implemtiert ein Objekt für die Einstellungen des
  Projektes CDRW.


  TSettingsCDRW

    Properties   Device      : string
                 Fast        : Boolean
                 All         : Boolean
                 OpenSession : Boolean
                 BlankSession: Boolean
                 Force       : Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_cdrw;

interface

uses IniFiles, cl_abstractbase;

type TSettingsCDRW = class(TCdrtfeSettings)
     private
       FDevice      : string;
       FFast        : Boolean;
       FAll         : Boolean;
       FOpenSession : Boolean;
       FBlankSession: Boolean;
       FForce       : Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device      : string read FDevice write FDevice;
       property Fast        : Boolean read FFast write FFast;
       property All         : Boolean read FAll write FAll;
       property OpenSession : Boolean read FOpenSession write FOpenSession;
       property BlankSession: Boolean read FBlankSession write FBlankSession;
       property Force       : Boolean read FForce write FForce;
     end;

implementation


{ TSettingsCDRW -------------------------------------------------------------- }

{ TSettingsCDRW - private }

{ TSettingsCDRW - public }

constructor TSettingsCDRW.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsCDRW.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsCDRW.Init;
begin
  FDevice       := '';
  FFast         := True;
  FAll          := False;
  FOpenSession  := False;
  FBlankSession := False;
  FForce        := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsCDRW.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'CDRW';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FFast := ReadBool(Section, 'Fast', True);
    FAll := ReadBool(Section, 'All', False);
    FOpenSession := ReadBool(Section, 'OpenSession', False);
    FBlankSession :=ReadBool(Section, 'BlankSession', False);
    FForce := ReadBool(Section, 'Force', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsCDRW.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'CDRW';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteBool(Section, 'Fast', FFast);
    WriteBool(Section, 'All', FAll);
    WriteBool(Section, 'OpenSession', FOpenSession);
    WriteBool(Section, 'BlankSession', FBlankSession);
    WriteBool(Section, 'Force', FForce);
  end;
end;

end.

