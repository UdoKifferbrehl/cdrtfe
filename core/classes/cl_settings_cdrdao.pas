{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_cdrdao.pas: Objekt für Einstellungen von cdrdao

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_cdrdao.pas implemtiert ein Objekt für die Einstellungen von cdrdao.


  TSettingsCdrdao

    Properties   ForceGenericMmc   : Boolean
                 ForceGenericMmcRaw: Boolean
                 WriteCueImages    : Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_cdrdao;

interface

uses IniFiles, cl_abstractbase;

type TSettingsCdrdao = class(TCdrtfeSettings)
     private
       FForceGenericMmc   : Boolean;
       FForceGenericMmcRaw: Boolean;
       FWriteCueImages    : Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property ForceGenericMmc   : Boolean read FForceGenericMmc write FForceGenericMmc;
       property ForceGenericMmcRaw: Boolean read FForceGenericMmcRaw write FForceGenericMmcRaw;
       property WriteCueImages    : Boolean read FWriteCueImages write FWriteCueImages;
     end;

implementation


{ TSettingsCdrdao ------------------------------------------------------------ }

{ TSettingsCdrdao - private }

{ TSettingsCdrdao - public }

constructor TSettingsCdrdao.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsCdrdao.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsCdrdao.Init;
begin
  FForceGenericMmc    := False;
  FForceGenericMmcRaw := False;
  FWriteCueImages     := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsCdrdao.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'cdrdao';
  with MIF do
  begin
    FForceGenericMmc := ReadBool(Section, 'ForceGenericMmc', False);
    FForceGenericMmcRaw := ReadBool(Section, 'ForceGenericMmcRaw', False);
    FWriteCueImages := ReadBool(Section, 'WriteCueImages', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsCdrdao.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'cdrdao';
  with MIF do
  begin
    WriteBool(Section, 'ForceGenericMmc', FForceGenericMmc);
    WriteBool(Section, 'ForceGenericMmcRaw', FForceGenericMmcRaw);
    WriteBool(Section, 'WriteCueImages', FWriteCueImages);
  end;  
end;

end.

