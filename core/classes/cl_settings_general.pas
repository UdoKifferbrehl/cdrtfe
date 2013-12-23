{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_general.pas: Objekt für allgemeine Einstellungen

  Copyright (c) 2004-2013 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  07.12.2011

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_general.pas implemtiert ein Objekt für GUI-Settings, Flags und
  Hilfsvariablen.

  Achtung: Nach dem Laden muß FileFlags.MPlayerOk := FileExists(MPlayerCmd)
           gesetzt werden!


  TGeneralSettings

    Properties   Choice        : Byte
                 ImageRead     : Boolean
                 CDCopy        : Boolean
                 TabSheetDrive : array[1..TabSheetCount] of Byte
                 TabSheetSpeed : array[1..TabSheetCount] of Integer
                 TabSheetSMType: array[1..TabSheetCount] of Integer
                 CharSets      : TStringList
                 Mp3Qualities  : TStringList
                 XCDAddMovie   : Boolean
                 TempBoot      : Boolean
                 NoConfirm     : Boolean
                 TabFrmSettings: Byte
                 TabFrmDAE     : Byte
                 TabFrmDCDFS   : Byte
                 NoWriter      : Boolean
                 NoReader      : Boolean
                 NoDevices     : Boolean
                 LastProject   : string
                 IniFile       : string
                 TempFolder    : string
                 AskForTempDir : Boolean
                 CDTextUseTags : Boolean
                 CDTextTP      : Boolean
                 PortableMode  : Boolean
                 DetectSpeeds  : Boolean
                 DetectDiskType: Boolean
                 AutoSaveOnExit: Boolean
                 AllowFileOpen : Boolean
                 AllowDblClick : Boolean
                 UseMPlayer    : Boolean
                 MPlayerCmd    : string
                 MPlayerOpt    : string
                 FileInfoTitle : Boolean
                 SpaceMeter    : Boolean
                 DisableScrSvr : Boolean
                 ShowFolderSize: Boolean
                 WarnModified  : Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)    

}

unit cl_settings_general;

{$I directives.inc}

interface

uses Classes, IniFiles, SysUtils, cl_abstractbase, const_tabsheets;

type TabSheetIntegerArray = array[1..TabSheetCount] of Integer;

     TGeneralSettings = class(TCdrtfeSettings)
     private
       FChoice        : Byte;
       FImageRead     : Boolean;
       FCDCopy        : Boolean;                     // True: 1:1-Kopie schreiben
       FTabSheetDrive : TabSheetIntegerArray;
       FTabSheetSpeed : TabSheetIntegerArray;
       FTabSheetSMType: TabSheetIntegerArray;
       FCharSets      : TStringList;
       FMp3Qualities  : TStringList;
       FXCDAddMovie   : Boolean;
       FTempBoot      : Boolean;
       FNoConfirm     : Boolean;
       FTabFrmSettings: Byte;
       FTabFrmDAE     : Byte;
       FTabFrmDCDFS   : Byte;
       FNoWriter      : Boolean;
       FNoReader      : Boolean;
       FNoDevices     : Boolean;
       FLastProject   : string;
       FIniFile       : string;
       FTempFolder    : string;
       FAskForTempDir : Boolean;
       FCDTextUseTags : Boolean;
       FCDTextTP      : Boolean;    // <title> - <performer>.mp3
       FPortableMode  : Boolean;
       FDetectSpeeds  : Boolean;
       FDetectDiskType: Boolean;
       FAutoSaveOnExit: Boolean;
       FAllowFileOpen : Boolean;
       FAllowDblClick : Boolean;
       FUseMPlayer    : Boolean;
       FMPlayerCmd    : string;
       FMPlayerOpt    : string;
       FFileInfoTitle : Boolean;
       FSpaceMeter    : Boolean;
       FDisableScrSvr : Boolean;
       FShowFolderSize: Boolean;
       FWarnModified  : Boolean;
       function GetTabSheetDrive(Index: Integer): Integer;
       function GetTabSheetSpeed(Index: Integer): Integer;
       function GetTabSheetSMType(Index: Integer): Integer;
       procedure SetTabSheetDrive(Index: Integer; const Value: Integer);
       procedure SetTabSheetSpeed(Index: Integer; const Value: Integer);
       procedure SetTabSheetSMType(Index: Integer; const Value: Integer);
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property Choice        : Byte read FChoice write FChoice;
       property ImageRead     : Boolean read FImageRead write FImageRead;
       property CDCopy        : Boolean read FCDCopy write FCDCopy;
       property TabSheetDrive[Index: Integer]: Integer read GetTabSheetDrive write SetTabSheetDrive;
       property TabSheetSpeed[Index: Integer]: Integer read GetTabSheetSpeed write SetTabSheetSpeed;
       property TabSheetSMType[Index: Integer]: Integer read GetTabSheetSMType write SetTabSheetSMType;
       property CharSets      : TStringList read FCharsets write FCharsets;
       property Mp3Qualities  : TStringList read FMp3Qualities write FMp3Qualities;
       property XCDAddMovie   : Boolean read FXCDAddMovie write FXCDAddMovie;
       property TempBoot      : Boolean read FTempBoot write FTempBoot;
       property NoConfirm     : Boolean read FNoConfirm write FNoConfirm;
       property TabFrmSettings: Byte read FTabFrmSettings write FTabFrmSettings;
       property TabFrmDAE     : Byte read FTabFrmDAE write FTabFrmDAE;
       property TabFrmDCDFS   : Byte read FTabFrmDCDFS write FTabFrmDCDFS;
       property NoWriter      : Boolean read FNoWriter write FNoWriter;
       property NoReader      : Boolean read FNoReader write FNoReader;
       property NoDevices     : Boolean read FNoDevices write FNoDevices;
       property LastProject   : string read FLastProject write FLastProject;
       property IniFile       : string read FIniFile write FIniFile;
       property TempFolder    : string read FTempFolder write FTempFolder;
       property AskForTempDir : Boolean read FAskForTempDir write FAskForTempDir;
       property CDTextUseTags : Boolean read FCDTextUseTags write FCDTextUseTags;
       property CDTextTP      : Boolean read FCDTextTP write FCDTextTP;
       property PortableMode  : Boolean read FPortableMode write FPortableMode;
       property DetectSpeeds  : Boolean read FDetectSpeeds write FDetectSpeeds;
       property DetectDiskType: Boolean read FDetectDiskType write FDetectDiskType;
       property AutoSaveOnExit: Boolean read FAutoSaveOnExit write FAutoSaveOnExit;
       property AllowFileOpen : Boolean read FAllowFileOpen write FAllowFileOpen;
       property AllowDblClick : Boolean read FAllowDblCLick write FAllowDblClick;
       property UseMPlayer    : Boolean read FUseMPlayer write FUseMPlayer;
       property MPlayerCmd    : string read FMPlayerCmd write FMPlayerCmd;
       property MPlayerOpt    : string read FMPlayerOpt write FMPlayerOpt;
       property FileInfoTitle : Boolean read FFileInfoTitle write FFileInfoTitle;
       property SpaceMeter    : Boolean read FSpaceMeter write FSpaceMeter;
       property DisableScrSvr : Boolean read FDisableScrSvr write FDisableScrSvr;
       property ShowFolderSize: Boolean read FShowFolderSize write FShowFolderSize;
       property WarnModified  : Boolean read FWarnModified write FWarnModified;
     end;

implementation

uses f_foldernamecache, f_logfile;

{ TGeneralSettings ----------------------------------------------------------- }

{ TGeneralSettings - private }

{ GetTabSheet... / SetTabSheet... ----------------------------------------------

  Getter- und Setter-Methoden für die Array-Propertier.                        }

function TGeneralSettings.GetTabSheetDrive(Index: Integer): Integer;
begin
  Result := FTabSheetDrive[Index];
end;

function TGeneralSettings.GetTabSheetSpeed(Index: Integer): Integer;
begin
  Result := FTabSheetSpeed[Index];
end;

function TGeneralSettings.GetTabSheetSMType(Index: Integer): Integer;
begin
  Result := FTabSheetSMType[Index];
end;

procedure TGeneralSettings.SetTabSheetDrive(Index: Integer;
                                            const Value: Integer);
begin
  FTabSheetDrive[Index] := Value;
end;

procedure TGeneralSettings.SetTabSheetSpeed(Index: Integer;
                                            const Value: Integer);
begin
  FTabSheetSpeed[Index] := Value;
end;

procedure TGeneralSettings.SetTabSheetSMType(Index: Integer;
                                             const Value: Integer);
begin
  FTabSheetSMType[Index] := Value;
end;

{ TGeneralSettings - public }

constructor TGeneralSettings.Create;
begin
  inherited Create;
  FCharsets := TStringList.Create;
  FMp3Qualities := TStringList.Create;
  Init;
end;

destructor TGeneralSettings.Destroy;
begin
  FCharSets.Free;
  FMp3Qualities.Free;
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TGeneralSettings.Init;
var i: Integer;
begin
  {allgemeine Einstellungen/Statusvaraiblen}
  FCharSets.CommaText := ',cp437,cp737,cp775,cp850,cp852,cp855,cp857,'       +
                         'cp860,cp861,cp862,cp863,cp864,cp865,cp866,'        +
                         'cp869,cp874,cp1250,cp1251,cp10081,cp10079,'        +
                         'cp10029,cp10007,cp10006,cp10000,iso8859-1,'        +
                         'iso8859-2,iso8859-3,iso8859-4,iso8859-5,'          +
                         'iso8859-6,iso8859-7,iso8859-8,iso8859-9,'          +
                         'iso8859-14,iso8859-15,koi8-u,koi8-r,'              +
                         'cp1252,cp1253,cp1254,cp1255,cp1256,cp1257,cp1258,' +
                         'iso8859-10,iso8859-11,iso8859-13,iso8859-16,default';
  FMp3Qualities.CommaText := 'medium,standard,extreme,insane,' +
                             '320,256,224,192,160,128,112,96,80';
  FChoice := 0;
  FXCDAddMovie := False;
  FTempBoot := False;
  {aktuelles Laufwerk für jedes TabSheet}
  for i := 1 to TabSheetCount do
  begin
    FTabSheetDrive[i]  := 0;
    FTabSheetSpeed[i]  := -1;
    FTabSheetSMType[i] := 0;
  end;
  FImageRead := True;
  FCDCopy := False;
  FNoConfirm := False;
  FTabFrmSettings := cCdrtfe;
  FTabFrmDAE      := cTabDAE;
  FTabFrmDCDFS    := cTabFSGen;
  FNoWriter := False;
  FNoReader := False;
  FNoDevices := False;
  FLastProject := '';
  FIniFile := '';
  FTempFolder := '';
  FAskForTempDir := False;
  FCDTextUseTags := True;
  FCDTextTP := False;
  FPortableMode := False;
  FDetectSpeeds := False;
  FDetectDiskType := False;
  FAutoSaveOnExit := False;
  FAllowFileOpen := True;
  FAllowDblClick := True;
  FUseMPlayer := False;
  FMPlayerCmd := '';
  FMPlayerOpt := '%N';
  FFileInfoTitle := False;
  FSpaceMeter := True;
  FDisableScrSvr := False;
  FShowFolderSize := False;
  FWarnModified := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TGeneralSettings.Load(MIF: TMemIniFile);
var Section: string;
    Temp   : string;
    i      : Integer;
begin
  Section := 'General';
  with MIF do
  begin
    Choice := ReadInteger(Section, 'Choice', cDataCD);
    for i := 1 to TabSheetCount do
    begin                   
      FTabSheetDrive[i] := ReadInteger(Section,
                                       'TabSheetDrive' + IntToStr(i), 0);
      FTabSheetSpeed[i] := ReadInteger(Section,
                                       'TabSheetSpeed' + IntToStr(i), -1);
      FTabSheetSMType[i] := ReadInteger(Section,
                                        'TabSheetSMType' + IntToStr(i), 0);
    end;
    FImageRead := ReadBool(Section, 'ImageRead', True);
    FNoConfirm := ReadBool(Section, 'NoConfirm', False);
    FTabFrmSettings := ReadInteger(Section, 'TabFrmSettings', cCdrtfe);
    FTabFrmDAE := ReadInteger(Section, 'TabFrmDAE', cTabDAE);
    FTabFrmDCDFS := ReadInteger(Section, 'TabFrmDCDFS', cTabFSGen);
    FTempFolder := ReadString(Section, 'TempFolder', '');
    FAskForTempDir := ReadBool(Section, 'AskForTempDir', False);
    FCDTextUseTags := ReadBool(Section, 'CDTextUseTags', True);
    FCDTextTP := ReadBool(Section, 'CDTextTP', False);
    FDetectSpeeds := ReadBool(Section, 'DetectSpeeds', FDetectSpeeds);
    FDetectDiskType := ReadBool(Section, 'DetectDiskType', FDetectDiskType);
    FAutoSaveOnExit := ReadBool(Section, 'AutoSaveOnExit', False);
    FAllowFileOpen := ReadBool(Section, 'AllowFileOpen', True);
    FUseMplayer := ReadBool(Section, 'UseMPlayer', False);
    FAllowDblClick := ReadBool(Section, 'AllowDblClick', True);
    FMPlayerCmd := ReadString(Section, 'MPlayerCmd', '');
    FMPlayerOpt := ReadString(Section, 'MPlayerOpt', '');
    FFileInfoTitle := ReadBool(Section, 'FileInfoTitle', False);
    FSpaceMeter := ReadBool(Section, 'SpaceMeter', True);
    FDisableScrSvr := ReadBool(Section, 'DisableScrSvr', False);
    FShowFolderSize := ReadBool(Section, 'ShowFolderSize', False);
    FWarnModified := ReadBool(Section, 'WarnModified', False);
    if FAsInifile then
    begin
      {Defaultwerte für FolderNameCache}
      for i := 0 to FNCCount - 1 do
      begin
        Temp := ReadString(Section, 'DfltDlgFolder' + IntToStr(i), '');
        if Temp <> '' then CacheFolderName(TDialogID(i), Temp);
      end;
      if not PortableMode then
      begin
        PortableMode := ReadBool(Section, 'PortableMode', False);
        {$IFDEF WriteLogFile}
        if PortableMode then AddLogCode(1301);
        {$ENDIF}
      end;
      FAsIniFile := False;
    end;
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TGeneralSettings.Save(MIF: TMemIniFile);
var Section : string;
    i       : Integer;
begin
  Section := 'General';
  with MIF do
  begin
    WriteInteger(Section, 'Choice', FChoice);
    for i := 1 to TabSheetCount do
    begin
      WriteInteger(Section, 'TabSheetDrive' + IntToStr(i), FTabSheetDrive[i]);
      WriteInteger(Section, 'TabSheetSpeed' + IntToStr(i), FTabSheetSpeed[i]);
      WriteInteger(Section, 'TabSheetSMType' + IntToStr(i), FTabSheetSMType[i]);
    end;
    WriteBool(Section, 'ImageRead', FImageRead);
    WriteBool(Section, 'NoConfirm', FNoConfirm);
    WriteInteger(Section, 'TabFrmSettings', FTabFrmSettings);
    WriteInteger(Section, 'TabFrmDAE', FTabFrmDAE);
    WriteInteger(Section, 'TabFrmDCDFS', FTabFrmDCDFS);
    WriteString(Section, 'TempFolder', FTempFolder);
    WriteBool(Section, 'AskForTempDir', FAskForTempDir);
    WriteBool(Section, 'CDTextUseTags', FCDTextUseTags);
    WriteBool(Section, 'CDTextTP', FCDTextTP);
    WriteBool(Section, 'DetectSpeeds', FDetectSpeeds);
    WriteBool(Section, 'DetectDiskType', FDetectDiskType);
    WriteBool(Section, 'AutoSaveOnExit', FAutoSaveOnExit);
    WriteBool(Section, 'AllowFileOpen', FAllowFileOpen);
    WriteBool(Section, 'AllowDblClick', FAllowDblClick);
    WriteBool(Section, 'UseMPlayer', FUseMPlayer);
    WriteString(Section, 'MPlayerCmd', FMPlayerCmd);
    WriteString(Section, 'MPlayerOpt', FMPlayerOpt);
    WriteBool(Section, 'FileInfoTitle', FFileInfoTitle);
    WriteBool(Section, 'SpaceMeter', FSpaceMeter);
    WriteBool(Section, 'DisableScrSvr', FDisableScrSvr);
    WriteBool(Section, 'ShowFolderSize', FShowFolderSize);
    WriteBool(Section, 'WarnModified', FWarnModified);
    if FAsIniFile then
    begin
      if PortableMode then
      begin
        WriteBool(Section, 'PortableMode', PortableMode);
      end;
    end;
  end;
end;

end.

