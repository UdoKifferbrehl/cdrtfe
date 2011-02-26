{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_dvdvideo.pas: Objekt für Einstellungen des DVDVideo-Projektes

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  16.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_dvdvideo.pas implemtiert ein Objekt für die Einstellungen des
  Projektes DVDVideo.

    Achtung: Nach dem Laden muß OnTheFly in Abhängigkeit einiger FileFlags
             gesetzt werden!  


  TSettingsDVDVideo

    Properties   Device    : string
                 Speed     : string
                 SourcePath: string
                 VolID     : string
                 IsoPath   : string
                 OnTheFly  : Boolean
                 ImageOnly : Boolean
                 KeepImage : Boolean
                 Verify    : Boolean
                 ShCmdName : string

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)

}

unit cl_settings_dvdvideo;

interface

uses IniFiles, cl_abstractbase;

type TSettingsDVDVideo = class(TCdrtfeSettings)
     private
       FDevice    : string;
       FSpeed     : string;
       FSourcePath: string;
       FVolID     : string;
       FIsoPath   : string;
       FOnTheFly  : Boolean;
       FImageOnly : Boolean;
       FKeepImage : Boolean;
       FVerify    : Boolean;
       FShCmdName : string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Device    : string read FDevice write FDevice;
       property Speed     : string read FSpeed write FSpeed;
       property SourcePath: string read FSourcePath write FSourcePath;
       property VolID     : string read FVolID write FVolID;
       property IsoPath   : string read FIsoPath write FIsoPath;
       property OnTheFly  : Boolean read FOnTheFly write FOnTheFly;
       property ImageOnly : Boolean read FImageOnly write FImageOnly;
       property KeepImage : Boolean read FKeepImage write FKeepImage;
       property Verify    : Boolean read FVerify write FVerify;
       property ShCmdName : string read FShCmdName write FShCmdName;
     end;

implementation


{ TSettingsDVDVideo ---------------------------------------------------------- }

{ TSettingsDVDVideo - private }

{ TSettingsDVDVideo - public }

constructor TSettingsDVDVideo.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsDVDVideo.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsDVDVideo.Init;
begin
  FDevice     := '';
  FSpeed      := '';
  FSourcePath := '';
  FVolID      := '';
  FIsoPath    := '';
  FOnTheFly   := True;
  FImageOnly  := False;
  FKeepImage  := False;
  FVerify     := False;
  FShCmdName  := '';
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsDVDVideo.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'DVDVideo';
  with MIF do
  begin
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FSourcePath := ReadString(Section, 'SourcePath', '');
    FVolID := ReadString(Section, 'VolID', '');
    FIsoPath := ReadString(Section, 'IsoPath', '');
    FOnTheFly := ReadBool(Section, 'OnTheFly', True); // and
                 // (FileFlags.ShOk or not FileFlags.ShNeeded);
    FImageOnly := ReadBool(Section, 'ImageOnly', False);
    FKeepImage := ReadBool(Section, 'KeepImage', False);
    FVerify := ReadBool(Section, 'Verify', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsDVDVideo.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'DVDVideo';
  with MIF do
  begin
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteString(Section, 'SourcePath', FSourcePath);
    WriteString(Section, 'VolID', FVolID);
    WriteString(Section, 'IsoPath', FIsoPath);
    WriteBool(Section, 'OnTheFly', FOnTheFly);
    WriteBool(Section, 'ImageOnly', FImageOnly);
    WriteBool(Section, 'KeepImage', FKeepImage);
    WriteBool(Section, 'Verify', FVerify);
  end;
end;

end.




