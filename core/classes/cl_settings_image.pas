{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_image.pas: Objekt für Einstellungen des CD-Image-Projektes

  Copyright (c) 2004-2016 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  24.01.2016

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_image.pas implemtiert ein Objekt für die Einstellungen des
  Projektes CD-Image (schreiben).


  TSettingsImage

    Properties   Device  : string
                 Speed   : string
                 IsoPath : string
                 Overburn: Boolean
                 TAO     : Boolean
                 DAO     : Boolean
                 Clone   : Boolean
                 RAW     : Boolean
                 RAWMode : string
                 CDText  : Boolean
                 Verify  : Boolean
                 Multi   : Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_image;

interface

uses IniFiles, cl_abstractbase;

type TSettingsImage = class(TCdrtfeSettings)
     private
       FDevice  : string;
       FSpeed   : string;
       FIsoPath : string;
       FOverburn: Boolean;
       FTAO     : Boolean;
       FDAO     : Boolean;
       FClone   : Boolean;
       FRAW     : Boolean;
       FRAWMode : string;
       FCDText  : Boolean;
       FVerify  : Boolean;
       FMulti   : Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device  : string read FDevice write FDevice;
       property Speed   : string read FSpeed write FSpeed;
       property IsoPath : string read FIsoPath write FIsoPath;
       property Overburn: Boolean read FOverburn write FOverburn;
       property TAO     : Boolean read FTAO write FTAO;
       property DAO     : Boolean read FDAO write FDAO;
       property Clone   : Boolean read FClone write FClone;
       property RAW     : Boolean read FRAW write FRAW;
       property RAWMode : string read FRAWMode write FRAWMode;
       property CDText  : Boolean read FCDText write FCDText;
       property Verify  : Boolean read FVerify write FVerify;
       property Multi   : Boolean read FMulti write FMulti;
     end;

implementation


{ TSettingsImage ------------------------------------------------------------- }

{ TSettingsImage - private }

{ TSettingsImage - public }

constructor TSettingsImage.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsImage.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsImage.Init;
begin
  FDevice   := '';
  FSpeed    := '';
  FIsoPath  := '';
  FOverburn := False;
  FDAO      := False;
  FTAO      := True;
  FClone    := False;
  FRAW      := False;
  FRAWMode  := 'raw96r';
  FCDText   := False;
  FVerify   := False;
  FMulti    := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsImage.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Image';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FIsoPath := ReadString(Section, 'IsoPath', '');
    FOverburn := ReadBool(Section, 'Overburn', False);
    FDAO := ReadBool(Section, 'DAO', False);
    FTAO := ReadBool(Section, 'TAO', True);
    FClone := ReadBool(Section, 'Clone', FClone);
    FRAW := ReadBool(Section, 'RAW', False);
    FRAWMode := ReadString(Section, 'RAWMode', 'raw96r');
    FCDText := ReadBool(Section, 'CDText', False);
    FVerify := ReadBool(Section, 'Verify', False);
    FMulti := ReadBool(Section, 'Multi', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsImage.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Image';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteString(Section, 'IsoPath', FIsoPath);
    WriteBool(Section, 'OverBurn', FOverburn);
    WriteBool(Section, 'DAO', FDAO);
    WriteBool(Section, 'TAO', FTAO);
    WriteBool(Section, 'Clone', FClone);
    WriteBool(Section, 'RAW', FRAW);
    WriteString(Section, 'RAWMode', FRAWMode);
    WriteBool(Section, 'CDText', FCDText);
    WriteBool(Section, 'Verify', FVerify);
    WriteBool(Section, 'Multi', FMulti);
  end;
end;

end.


