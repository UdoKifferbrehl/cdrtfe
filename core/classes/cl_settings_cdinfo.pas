{ $Id: cl_settings_cdinfo.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_cdinfo.pas: Objekt für Einstellungen des CDInfo-Projektes

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_cdinfo.pas implemtiert ein Objekt für die Einstellungen des
  Projektes CDInfo.


  TSettingsCDInfo

    Properties   Device  : string
                 Scanbus : Boolean
                 Prcap   : Boolean
                 Toc     : Boolean
                 Atip    : Boolean
                 MSInfo  : Boolean
                 MInfo   : Boolean
                 CapInfo : Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_cdinfo;

interface

uses IniFiles, cl_abstractbase;

type TSettingsCDInfo = class(TCdrtfeSettings)
     private
       FDevice  : string;
       FScanbus : Boolean;
       FPrcap   : Boolean;
       FToc     : Boolean;
       FAtip    : Boolean;
       FMSInfo  : Boolean;
       FMInfo   : Boolean;
       FCapInfo : Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device  : string read FDevice write FDevice;
       property Scanbus : Boolean read FScanbus write FScanbus;
       property Prcap   : Boolean read FPrcap write FPrcap;
       property Toc     : Boolean read FToc write FToc;
       property Atip    : Boolean read FAtip write FAtip;
       property MSInfo  : Boolean read FMSInfo write FMSInfo;
       property MInfo   : Boolean read FMInfo write FMInfo;
       property CapInfo : Boolean read FCapInfo write FCapInfo;
     end;

implementation


{ TSettingsCDInfo ------------------------------------------------------------ }

{ TSettingsCDInfo - private }

{ TSettingsCDInfo - public }

constructor TSettingsCDInfo.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsCDInfo.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsCDInfo.Init;
begin
  FDevice   := '';
  FScanbus  := True;
  FPrcap    := False;
  FToc      := False;
  FAtip     := False;
  FMSInfo   := False;
  FMInfo    := False;
  FCapInfo  := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsCDInfo.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'CDInfo';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FScanbus := ReadBool(Section, 'Scanbus', True);
    FPrcap := ReadBool(Section, 'Prcap', False);
    FToc := ReadBool(Section, 'Toc', False);
    FAtip := ReadBool(Section, 'Atip', False);
    FMSInfo := ReadBool(Section, 'MSInfo', False);
    FMInfo := ReadBool(Section, 'MInfo', False);
    FCapInfo := ReadBool(Section, 'CapInfo', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsCDInfo.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'CDInfo';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteBool(Section, 'Scanbus', FScanbus);
    WriteBool(Section, 'Prcap', FPrcap);
    WriteBool(Section, 'Toc', FToc);
    WriteBool(Section, 'Atip', FAtip);
    WriteBool(Section, 'MSInfo', FMSInfo);
    WriteBool(Section, 'MInfo', FMInfo);
    WriteBool(Section, 'CapInfo', FCapInfo);
  end;
end;

end.

