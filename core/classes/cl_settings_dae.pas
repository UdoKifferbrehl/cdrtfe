{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_dae.pas: Objekt für Einstellungen des DAE-Projektes

  Copyright (c) 2004-2015 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  25.10.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_dae.pas implemtiert ein Objekt für die Einstellungen des
  Projektes DAE.

    Achtung: Nach dem Laden muß MP3, OGG, FLAC in Abhängigkeit einiger FileFlags
             gesetzt werden!


  TSettingsDAE

    Properties   Action        : Byte
                 Device        : string
                 Speed         : string
                 SpeedW        : string
                 Bulk          : Boolean
                 Paranoia      : Boolean
                 NoInfoFile    : Boolean
                 Path          : string
                 PrefixNames   : Boolean
                 Prefix        : string
                 NamePattern   : string
                 Tracks        : string
                 Offset        : string
                 UseCDDB       : Boolean
                 CDDBServer    : string
                 CDDBPort      : string
                 MP3           : Boolean
                 Ogg           : Boolean
                 FLAC          : Boolean
                 Custom        : Boolean
                 AddTags       : Boolean
                 FlacQuality   : string
                 OggQuality    : string
                 LamePreset    : string
                 CustomCmd     : string
                 CustomOpt     : string
                 DoCopy        : Boolean
                 HiddenTrack   : Boolean
                 UseParaOpts   : Boolean
                 ParaProof     : Boolean
                 ParaDisable   : Boolean
                 ParaC2check   : Boolean
                 ParaNoVerify  : Boolean
                 ParaRetries   : string
                 ParaReadahead : string
                 ParaOverlap   : string
                 ParaMinoverlap: string
                 ParaMaxoverlap: string

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_dae;

interface

uses IniFiles, cl_abstractbase;

type TSettingsDAE = class(TCdrtfeSettings)
     private
       FAction        : Byte;
       FDevice        : string;
       FSpeed         : string;
       FSpeedW        : string;
       FBulk          : Boolean;
       FParanoia      : Boolean;
       FNoInfoFile    : Boolean;
       FPath          : string;
       FPrefixNames   : Boolean;
       FPrefix        : string;
       FNamePattern   : string;
       FTracks        : string;
       FOffset        : string;
       FUseCDDB       : Boolean;
       FCDDBServer    : string;
       FCDDBPort      : string;
       FMP3           : Boolean;
       FOgg           : Boolean;
       FFLAC          : Boolean;
       FCustom        : Boolean;
       FAddTags       : Boolean;
       FFlacQuality   : string;
       FOggQuality    : string;
       FLamePreset    : string;
       FCustomCmd     : string;
       FCustomOpt     : string;
       FDoCopy        : Boolean;
       FHiddenTrack   : Boolean;
       FUseParaOpts   : Boolean;
       FParaProof     : Boolean;
       FParaDisable   : Boolean;
       FParaC2check   : Boolean;
       FParaNoVerify  : Boolean;
       FParaRetries   : string;
       FParaReadahead : string;
       FParaOverlap   : string;
       FParaMinoverlap: string;
       FParaMaxoverlap: string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Action        : Byte read FAction write FAction;
       property Device        : string read FDevice write FDevice;
       property Speed         : string read FSpeed write FSpeed;
       property SpeedW        : string read FSpeedW write FSpeedW;
       property Bulk          : Boolean read FBulk write FBulk;
       property Paranoia      : Boolean read FParanoia write FParanoia;
       property NoInfoFile    : Boolean read FNoInfoFile write FNoInfoFile;
       property Path          : string read FPath write FPath;
       property PrefixNames   : Boolean read FPrefixNames write FPrefixNames;
       property Prefix        : string read FPrefix write FPrefix;
       property NamePattern   : string read FNamePattern write FNamePattern;
       property Tracks        : string read FTracks write FTracks;
       property Offset        : string read FOffset write FOffset;
       property UseCDDB       : Boolean read FUseCDDB write FUseCDDB;
       property CDDBServer    : string read FCDDBServer write FCDDBServer;
       property CDDBPort      : string read FCDDBPort write FCDDBPort;
       property MP3           : Boolean read FMP3 write FMP3;
       property Ogg           : Boolean read FOgg write FOgg;
       property FLAC          : Boolean read FFLAC write FFLAC;
       property Custom        : Boolean read FCustom write FCustom;
       property AddTags       : Boolean read FAddTags write FAddTags;
       property FlacQuality   : string read FFlacQuality write FFlacQuality;
       property OggQuality    : string read FOggQuality write FOggQuality;
       property LamePreset    : string read FLamePreset write FLamePreset;
       property CustomCmd     : string read FCustomCmd write FCustomCmd;
       property CustomOpt     : string read FCustomOpt write FCustomOpt;
       property DoCopy        : Boolean read FDoCopy write FDoCopy;
       property HiddenTrack   : Boolean read FHiddenTrack write FHiddenTrack;
       property UseParaOpts   : Boolean read FUseParaOpts write FUseParaOpts;
       property ParaProof     : Boolean read FParaProof write FParaProof;
       property ParaDisable   : Boolean read FParaDisable write FParaDisable;
       property ParaC2check   : Boolean read FParaC2check write FParaC2check;
       property ParaNoVerify  : Boolean read FParaNoVerify write FParaNoVerify;
       property ParaRetries   : string read FParaRetries write FParaRetries;
       property ParaReadahead : string read FParaReadahead write FParaReadahead;
       property ParaOverlap   : string read FParaOverlap write FParaOverlap;
       property ParaMinoverlap: string read FParaMinoverlap write FParaMinoverlap;
       property ParaMaxoverlap: string read FParaMaxoverlap write FParaMaxoverlap;
     end;

implementation


{ TSettingsDAE --------------------------------------------------------------- }

{ TSettingsDAE - private }

{ TSettingsDAE - public }

constructor TSettingsDAE.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsDAE.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsDAE.Init;
begin
  FAction         := 0;
  FDevice         := '';
  FSpeed          := '';
  FSpeedW         := '';
  FBulk           := True;
  FParanoia       := False;
  FNoInfoFile     := True;
  FPath           := '';
  FPrefixNames    := True;
  FPrefix         := 'track';
  FNamePattern    := '%N %P - %T';
  FTracks         := '';
  FOffset         := '';
  FUseCDDB        := False;
  FCDDBServer     := '';
  FCDDBPort       := '';
  FMP3            := False;
  FOgg            := False;
  FFLAC           := False;
  FCustom         := False;
  FAddTags        := True;
  FFlacQuality    := '5';
  FOggQuality     := '6';
  FLamePreset     := 'standard';
  FCustomCmd      := '';
  FCustomOpt      := '';
  FDoCopy         := False;
  FHiddenTrack    := False;
  FUseParaOpts    := False;
  FParaProof      := True;
  FParaDisable    := False;
  FParaC2check    := False;
  FParaNoVerify   := False;
  FParaRetries    := '';
  FParaReadahead  := '';
  FParaOverlap    := '';
  FParaMinoverlap := '';
  FParaMaxoverlap := '';
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsDAE.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'DAE';
  with MIF do
  begin
    FAction := ReadInteger(Section, 'Action', 0);
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FSpeedW := ReadString(Section, 'SpeedW', '');
    FBulk := ReadBool(Section, 'Bulk', True);
    FParanoia := ReadBool(Section, 'Paranoia', False);
    FNoInfoFile := ReadBool(Section, 'NoInfoFile', True);
    FPath := ReadString(Section, 'Path', '');
    FPrefixNames := ReadBool(Section, 'PrefixNames', True);
    FPrefix := ReadString(Section, 'Prefix', 'track');
    FNamePattern := ReadString(Section, 'NamePattern', '');
    FTracks := ReadString(Section, 'Tracks', '');
    FOffset := ReadString(Section, 'Offset', '');
    FUseCDDB := ReadBool(Section, 'UseCDDB', False);
    FCDDBServer := ReadString(Section, 'CDDBServer', '');
    FCDDBPort := ReadString(Section, 'CDDBPort', '');
    FMP3 := ReadBool(Section, 'MP3', False); // and FileFlags.LameOk and
            //(FileFlags.ShOk or not FileFlags.ShNeeded);
    FOgg := ReadBool(Section, 'Ogg', False); // and FileFlags.OggencOk and
            //(FileFlags.ShOk or not FileFlags.ShNeeded);
    FFLAC := ReadBool(Section, 'FLAC', False); // and FileFlags.FlacOk and
            //(FileFlags.ShOk or not FileFlags.ShNeeded);
    FCustom := ReadBool(Section, 'Custom', False);
    FAddTags := ReadBool(Section, 'AddTags', True);
    FFlacQuality := ReadString(Section, 'FlacQuality', '5');
    FOggQuality := ReadString(Section, 'OggQuality', '6');
    FLamePreset := ReadString(Section, 'LamePreset', 'standard');
    FCustomCmd := ReadString(Section, 'CustomCmd', '');
    FCustomOpt := ReadString(Section, 'CustomOpt', '');
    FDoCopy := ReadBool(Section, 'DoCopy', False);
    FUseParaOpts := ReadBool(Section, 'UseParaOpts', False);
    FParaProof := ReadBool(Section, 'ParaProof', True);
    FParaDisable := ReadBool(Section, 'ParaDisable', False);
    FParaC2check := ReadBool(Section, 'ParaC2check', False);
    FParaNoVerify := ReadBool(Section, 'ParaNoVerify', False);
    FParaRetries := ReadString(Section, 'ParaRetries', '');
    FParaReadahead := ReadString(Section, 'ParaReadahead', '');
    FParaOverlap := ReadString(Section, 'ParaOverlap', '');
    FParaMinoverlap := ReadString(Section, 'ParaMinoverlap', '');
    FParaMaxoverlap := ReadString(Section, 'ParaMaxoverlap', '');
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsDAE.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'DAE';
  with MIF do
  begin
    WriteInteger(Section, 'Action', FAction);
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteString(Section, 'SpeedW', FSpeedW);
    WriteBool(Section, 'Bulk', FBulk);
    WriteBool(Section, 'Paranoia', FParanoia);
    WriteBool(Section, 'NoInfoFile', FNoInfoFile);
    WriteString(Section, 'Path', FPath);
    WriteBool(Section, 'PrefixNames', FPrefixNames);
    WriteString(Section, 'Prefix', FPrefix);
    WriteString(Section, 'NamePattern', FNamePattern);
    WriteString(Section, 'Tracks', FTracks);
    WriteString(Section, 'Offset', FOffset);
    WriteBool(Section, 'UseCDDB', FUseCDDB);
    WriteString(Section, 'CDDBServer', FCDDBServer);
    WriteString(Section, 'CDDBPort', FCDDBPort);
    WriteBool(Section, 'MP3', FMP3);
    WriteBool(Section, 'Ogg', FOgg);
    WriteBool(Section, 'FLAC', FFLAC);
    WriteBool(Section, 'Custom', FCustom);
    WriteBool(Section, 'AddTags', FAddTags);
    WriteString(Section, 'FlacQuality', FFlacQuality);
    WriteString(Section, 'OggQuality', FOggQuality);
    WriteString(Section, 'LamePreset', FLamePreset);
    WriteString(Section, 'CustomCmd', FCustomCmd);
    WriteString(Section, 'CustomOpt', FCustomOpt);
    WriteBool(Section, 'DoCopy', FDoCopy);
    WriteBool(Section, 'UseParaOpts', FUseParaOpts);
    WriteBool(Section, 'ParaProof', FParaProof);
    WriteBool(Section, 'ParaDisable', FParaDisable);
    WriteBool(Section, 'ParaC2check', FParaC2check);
    WriteBool(Section, 'ParaNoVerify', FParaNoVerify);
    WriteString(Section, 'ParaRetries', FParaRetries);
    WriteString(Section, 'ParaReadahead', FParaReadahead);
    WriteString(Section, 'ParaOverlap', FParaOverlap);
    WriteString(Section, 'ParaMinoverlap', FParaMinoverlap);
    WriteString(Section, 'ParaMaxoverlap', FParaMaxoverlap);
  end;
end;

end.

