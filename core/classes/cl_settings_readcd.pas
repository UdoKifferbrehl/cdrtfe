{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_readcd.pas: Objekt für Einstellungen des CD-Image-Projektes

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  21.07.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_readcd.pas implemtiert ein Objekt für die Einstellungen des
  Projektes CD-Image (lesen).


  TSettingsReadcd

    Properties   Device  : string
                 Speed   : string
                 IsoPath : string
                 Clone   : Boolean
                 Nocorr  : Boolean
                 Noerror : Boolean
                 Range   : Boolean
                 Startsec: string
                 Endsec  : string
                 DoCopy  : Boolean
                 Retries : string

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_readcd;

interface

uses IniFiles, cl_abstractbase;

type TSettingsReadcd = class(TCdrtfeSettings)
     private
       FDevice  : string;
       FSpeed   : string;
       FIsoPath : string;
       FClone   : Boolean;
       FNocorr  : Boolean;
       FNoerror : Boolean;
       FRange   : Boolean;
       FStartsec: string;
       FEndsec  : string;
       FDoCopy  : Boolean;
       FRetries : string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device  : string read FDevice write FDevice;
       property Speed   : string read FSpeed write FSpeed;
       property IsoPath : string read FIsoPath write FIsoPath;
       property Clone   : Boolean read FClone write FClone;
       property Nocorr  : Boolean read FNocorr write FNocorr;
       property Noerror : Boolean read FNoerror write FNoerror;
       property Range   : Boolean read FRange write FRange;
       property Startsec: string read FStartsec write FStartsec;
       property Endsec  : string read FEndsec write FEndsec;
       property DoCopy  : Boolean read FDoCopy write FDoCopy;
       property Retries : string  read FRetries write FRetries;
     end;

implementation


{ TSettingsReadcd ------------------------------------------------------------ }

{ TSettingsReadcd - private }

{ TSettingsReadcd - public }

constructor TSettingsReadcd.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsReadcd.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsReadcd.Init;
begin
  FDevice   := '';
  FSpeed    := '';
  FIsoPath  := '';
  FClone    := False;
  FNocorr   := False;
  FNoerror  := False;
  FRange    := False;
  FStartsec := '';
  FEndsec   := '';
  FDoCopy   := False;
  FRetries  := '';
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsReadcd.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Readcd';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FIsoPath := ReadString(Section, 'IsoPath', '');
    FClone := ReadBool(Section, 'Clone', False);
    FNocorr := ReadBool(Section, 'Nocorr', False);
    FNoerror := ReadBool(Section, 'Noerror', False);
    FRange := ReadBool(Section, 'Range', False);
    FStartSec := ReadString(Section, 'Startsec', '');
    FEndSec := ReadString(Section, 'Endsec', '');
    FDoCopy := ReadBool(Section, 'DoCopy', False);
    FRetries := ReadString(Section, 'Retries', '');
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsReadcd.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Readcd';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteString(Section, 'IsoPath', FIsoPath);
    WriteBool(Section, 'Clone', FClone);
    WriteBool(Section, 'Nocorr', FNocorr);
    WriteBool(Section, 'Noerror', FNoerror);
    WriteBool(Section, 'Range', FRange);
    WriteString(Section, 'Startsec', FStartsec);
    WriteString(Section, 'Endsec', FEndsec);
    WriteBool(Section, 'DoCopy', FDoCopy);
    WriteString(Section, 'Retries', FRetries);
  end;
end;

end.



