{ $Id: cl_settings_videocd.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_videocd.pas: Objekt für Einstellungen des (S)VCD-Projektes

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  16.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_videocd.pas implemtiert ein Objekt für die Einstellungen des
  Projektes (S)VCD-Image.


  TSettingsVideoCD

    Properties   Device    : string
                 Speed     : string
                 IsoPath   : string
                 VolID     : string
                 ImageOnly : Boolean
                 KeepImage : Boolean
                 VCD1      : Boolean
                 VCD2      : Boolean
                 SVCD      : Boolean
                 Overburn  : Boolean
                 Verbose   : Boolean
                 Sec2336   : Boolean
                 SVCDCompat: Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_videocd;

interface

uses IniFiles, cl_abstractbase;

type TSettingsVideoCD = class(TCdrtfeSettings)
     private
       FDevice    : string;
       FSpeed     : string;
       FIsoPath   : string;
       FVolID     : string;
       FImageOnly : Boolean;
       FKeepImage : Boolean;
       FVCD1      : Boolean;
       FVCD2      : Boolean;
       FSVCD      : Boolean;
       FOverburn  : Boolean;
       FVerbose   : Boolean;
       FSec2336   : Boolean;
       FSVCDCompat: Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device    : string read FDevice write FDevice;
       property Speed     : string read FSpeed write FSpeed;
       property IsoPath   : string read FIsoPath write FIsoPath;
       property VolID     : string read FVolID write FVolID;
       property ImageOnly : Boolean read FImageOnly write FImageOnly;
       property KeepImage : Boolean read FKeepImage write FKeepImage;
       property VCD1      : Boolean read FVCD1 write FVCD1;
       property VCD2      : Boolean read FVCD2 write FVCD2;
       property SVCD      : Boolean read FSVCD write FSVCD;
       property Overburn  : Boolean read FOverburn write FOverburn;
       property Verbose   : Boolean read FVerbose write FVerbose;
       property Sec2336   : Boolean read FSec2336 write FSec2336;
       property SVCDCompat: Boolean read FSVCDCompat write FSVCDCompat;
     end;

implementation


{ TSettingsVideoCD ----------------------------------------------------------- }

{ TSettingsVideoCD - private }

{ TSettingsVideoCD - public }

constructor TSettingsVideoCD.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsVideoCD.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsVideoCD.Init;
begin
    FDevice     := '';
    FSpeed      := '';
    FIsoPath    := '';
    FVolID      := '';
    FImageOnly  := False;
    FKeepImage  := False;
    FVCD1       := False;
    FVCD2       := True;
    FSVCD       := False;
    FOverburn   := False;
    FVerbose    := True;
    FSec2336    := False;
    FSVCDCompat := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsVideoCD.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'VideoCD';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FIsoPath := ReadString(Section, 'IsoPath', '');
    FVolID := ReadString(Section, 'VolID', '');
    FImageOnly := ReadBool(Section, 'ImageOnly', False);
    FKeepImage := ReadBool(Section, 'KeepImage', False);
    FVCD1 := ReadBool(Section, 'VCD1', False);
    FVCD2 := ReadBool(Section, 'VCD2', True);
    FSVCD := ReadBool(Section, 'SVCD', False);
    FOverburn := ReadBool(Section, 'Overburn', False);
    FVerbose := ReadBool(Section, 'Verbose', True);
    FSec2336 := ReadBool(Section, 'Sec2336', False);
    FSVCDCompat := ReadBool(Section, 'SVCDCompat', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsVideoCD.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'VideoCD';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteString(Section, 'IsoPath', FIsoPath);
    WriteString(Section, 'VolID', FVolID);
    WriteBool(Section, 'ImageOnly', FImageOnly);
    WriteBool(Section, 'KeepImage', FKeepImage);
    WriteBool(Section, 'VCD1', FVCD1);
    WriteBool(Section, 'VCD2', FVCD2);
    WriteBool(Section, 'SVCD', FSVCD);
    WriteBool(Section, 'Overburn', FOverburn);
    WriteBool(Section, 'Verbose', FVerbose);
    WriteBool(Section, 'Sec2336', FSec2336);
    WriteBool(Section, 'SVCDCompat', FSVCDCompat);
  end;
end;

end.



