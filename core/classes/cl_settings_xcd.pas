{ $Id: cl_settings_xcd.pas,v 1.2 2010/08/07 13:56:55 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_xcd.pas: Objekt für Einstellungen des XCD-Projektes

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  07.08.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_xcd.pas implemtiert ein Objekt für die Einstellungen des
  Projektes XCD.


  TSettingsXCD

    Properties   XCDParamFile  : string
                 XCDInfoFile   : string
                 IsoPath       : string
                 ImageOnly     : Boolean
                 KeepImage     : Boolean
                 Verify        : Boolean
                 CreateInfoFile: Boolean
                 VolID       : string
                 Ext         : string
                 IsoLevel1   : Boolean
                 IsoLevel2   : Boolean
                 KeepExt     : Boolean
                 Single      : Boolean
                 Device      : string
                 Speed       : string
                 Overburn    : Boolean
                 XCDRrencInputFile : string
                 XCDRrencRRTFile   : string
                 XCDRrencRRDFile   : string
                 UseErrorProtection: Boolean
                 SecCount          : Integer

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_xcd;

interface

uses IniFiles, cl_abstractbase;

type TSettingsXCD = class(TCdrtfeSettings)
     private
       {allgemeine Einstellungen}
       FXCDParamFile  : string;
       FXCDInfoFile   : string;
       FIsoPath       : string;
       FImageOnly     : Boolean;
       FKeepImage     : Boolean;
       FVerify        : Boolean;
       FCreateInfoFile: Boolean;
       {Einstellungen: modecdmaker}
       FVolID       : string;
       FExt         : string;
       FIsoLevel1   : Boolean;
       FIsoLevel2   : Boolean;
       FKeepExt     : Boolean;
       FSingle      : Boolean;
       {Einstellungen: cdrdao}
       FDevice      : string;
       FSpeed       : string;
       FOverburn    : Boolean;
       {Einstellungen: rrenc}
       FXCDRrencInputFile : string;
       FXCDRrencRRTFile   : string;
       FXCDRrencRRDFile   : string;
       FUseErrorProtection: Boolean;
       FSecCount          : Integer;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property XCDParamFile  : string read FXCDParamFile write FXCDParamFile;
       property XCDInfoFile   : string read FXCDInfoFile write FXCDInfoFile;
       property IsoPath       : string read FIsoPath write FIsoPath;
       property ImageOnly     : Boolean read FImageOnly write FImageOnly;
       property KeepImage     : Boolean read FKeepImage write FKeepImage;
       property Verify        : Boolean read FVerify write FVerify;
       property CreateInfoFile: Boolean read FCreateInfoFile write FCreateInfoFile;
       property VolID       : string read FVolID write FVolID;
       property Ext         : string read FExt write FExt;
       property IsoLevel1   : Boolean read FIsoLevel1 write FIsoLevel1;
       property IsoLevel2   : Boolean read FIsoLevel2 write FIsoLevel2;
       property KeepExt     : Boolean read FKeepExt write FKeepExt;
       property Single      : Boolean read FSingle write FSingle;
       property Device      : string read FDevice write FDevice;
       property Speed       : string read FSpeed write FSpeed;
       property Overburn    : Boolean read FOverburn write FOverburn;
       property XCDRrencInputFile : string read FXCDRrencInputFile write FXCDRrencInputFile;
       property XCDRrencRRTFile   : string read FXCDRrencRRTFile write FXCDRrencRRTFile;
       property XCDRrencRRDFile   : string read FXCDRrencRRDFile write FXCDRrencRRDFile;
       property UseErrorProtection: Boolean read FUseErrorProtection write FUseErrorProtection;
       property SecCount          : Integer read FSecCount write FSecCount;
     end;

implementation


{ TSettingsXCD --------------------------------------------------------------- }

{ TSettingsXCD - private }

{ TSettingsXCD - public }

constructor TSettingsXCD.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsXCD.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsXCD.Init;
begin
  {allgemeine Einstellungen}
  FXCDParamFile   := '';
  FXCDInfoFile    := '';
  FIsoPath        := '';
  FImageOnly      := False;
  FKeepImage      := False;
  FVerify         := False;
  FCreateInfoFile := True;
  {Einstellungen: modecdmaker}
  FVolID          := 'XCD';
  FExt            := '';
  FIsoLevel1      := False;
  FIsoLevel2      := False;
  FKeepExt        := True;
  FSingle         := True;
  {Einstellungen: cdrdao}
  FDevice         := '';
  FSpeed          := '';
  FOverburn       := False;
  {Einstellungen rrenc}
  FXCDRrencInputFile  := '';
  FXCDRrencRRTFile    := '';
  FXCDRrencRRDFile    := '';
  FUseErrorProtection := False;
  FSecCount           := 3600;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsXCD.Load(MIF: TMemIniFile);
var Section: string;
    Temp   : string;
begin
  Section := 'XCD';
  with MIF do
  begin
    {allgemeine Einstellungen}
    FIsoPath := ReadString(Section, 'IsoPath', '');
    FImageOnly := ReadBool(Section, 'ImageOnly', False);
    FKeepImage := ReadBool(Section, 'KeepImage', False);
    FVerify := ReadBool(Section, 'Verify', False);
    FCreateInfoFile := ReadBool(Section, 'CreateInfoFile', True);
    {Einstellungen: modecdmaker}
    Temp := ReadString(Section, 'VolID', FVolID);
    if Temp <> '' then FVolID := Temp;
    FExt := ReadString(Section, 'Ext', '');
    FIsoLevel1 := ReadBool(Section, 'IsoLevel1', False);
    FIsoLevel2 := ReadBool(Section, 'IsoLevel2', False);
    FKeepExt := ReadBool(Section, 'KeepExt', True);
    FSingle := ReadBool(Section, 'Single', False);
    {Einstellungen: cdrdao}
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FOverburn := ReadBool(Section, 'OverBurn', False);
    {Einstellungen: rrenc}
    FUseErrorProtection := ReadBool(Section, 'UseErrorProtection', False);
    FSecCount := ReadInteger(Section, 'SecCount', 3600);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsXCD.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'XCD';
  with MIF do
  begin
    {allgemeine Einstellungen}
    WriteString(Section, 'IsoPath', FIsoPath);
    WriteBool(Section, 'ImageOnly', FImageOnly);
    WriteBool(Section, 'KeepImage', FKeepImage);
    WriteBool(Section, 'Verify', FVerify);
    WriteBool(Section, 'CreateInfoFile', FCreateInfoFile);
    {Einstellungen: modecdmaker}
    WriteString(Section, 'VolID', FVolID);
    WriteString(Section, 'Ext', FExt);
    WriteBool(Section, 'IsoLevel1', FIsoLevel1);
    WriteBool(Section, 'IsoLevel2', FIsoLevel2);
    WriteBool(Section, 'KeepExt', FKeepExt);
    WriteBool(Section, 'Single', FSingle);
    {Einstellungen: cdrdao}
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteBool(Section, 'Overburn', FOverburn);
    {Einstellung: rrenc}
    WriteBool(Section, 'UseErrorProtection', FUseErrorProtection);
    WriteInteger(Section, 'SecCount', FSecCount);
  end;
end;

end.

