{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings.pas: Einstellungen von cdrtfe

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  12.02.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings.pas bietet den Zugriff auf alle Einstellungen von cdrtfe.


  TSettings: Objekt, das die Einstellungen enthält und Methoden besitzt, um
             diese zu speichern und zu laden.

    Properties   OnProgressBarHide
                 OnProgressBarShow
                 OnProgressBarUpdate
                 OnUpdatePanels

    Variablen    record General
                        WinPos
                        FileExplorer
                        CmdLineFlags
                        FileFlags
                        Environment
                        Drives
                        Cdrecord
                        Cdrdao
                        DataCD
                        AudioCD
                        XCD
                        CDRW
                        CDInfo
                        DAE
                        Image
                        Readcd
                        VideoCD
                        DVDVideo
                        Devices
                        Hacks

    Methoden     Create
                 DeleteIniFile
                 GetMaxFileNameLength: Byte
                 LoadFromFile(const Name: string)
                 SaveToFile(const Name: string)

}

unit cl_settings;

{$I directives.inc}

interface

uses {$IFDEF Delphi2005Up} Windows, {$ENDIF}
     Classes, SysUtils, IniFiles, FileCtrl,
     cl_lang, f_locations, const_locations, userevents, const_core,
     const_tabsheets, const_common;

const TabSheetCount = 9;

type { GUI-Settings, Flags und Hilfsvariablen }
     TGeneralSettings = record
       Choice        : Byte;
       ImageRead     : Boolean;
       CDCopy        : Boolean;                     // True: 1:1-Kopie schreiben
       TabSheetDrive : array[1..TabSheetCount] of Byte;
       TabSheetSpeed : array[1..TabSheetCount] of Integer;
       TabSheetSMType: array[1..TabSheetCount] of Integer;
       CharSets      : TStringList;
       Mp3Qualities  : TStringList;
       XCDAddMovie   : Boolean;
       TempBoot      : Boolean;
       NoConfirm     : Boolean;
       TabFrmSettings: Byte;
       TabFrmDAE     : Byte;
       TabFrmDCDFS   : Byte;
       NoWriter      : Boolean;
       NoReader      : Boolean;
       NoDevices     : Boolean;
       LastProject   : string;
       IniFile       : string;
       TempFolder    : string;
       AskForTempDir : Boolean;
       CDTextUseTags : Boolean;
       CDTextTP      : Boolean;    // <title> - <performer>.mp3
       PortableMode  : Boolean;
       DetectSpeeds  : Boolean;
       AutoSaveOnExit: Boolean;
       AllowFileOpen : Boolean;
       AllowDblClick : Boolean;
       UseMPlayer    : Boolean;
       MPlayerCmd    : string;
       MPlayerOpt    : string;
       FileInfoTitle : Boolean;
       SpaceMeter    : Boolean;
       DisableScrSvr : Boolean;
       ShowFolderSize: Boolean;
     end;

     TWinPos = record
       MainTop      : Integer;
       MainLeft     : Integer;
       MainHeight   : Integer;
       MainWidth    : Integer;
       MainMaximized: Boolean;
       OutTop       : Integer;
       OutLeft      : Integer;
       OutHeight    : Integer;
       OutWidth     : Integer;
       OutMaximized : Boolean;
       OutScrolled  : Boolean;
       LVColWidth   : array[0..cLVCount, 0..cLVMaxColCount] of Integer;
     end;

     TFileExplorer = record
       Showing      : Boolean;
       Path         : string;
       Height       : Integer;
     end;

     TCmdLineFlags = record
       ExecuteProject    : Boolean;
       ExitAfterExecution: Boolean;
       Hide              : Boolean;
       Minimize          : Boolean;
       WriteLogFile      : Boolean;
     end;

     TFileFlags = record
       Mingw      : Boolean;    // Mingw32-Port der cdrtools
       IniFileOk  : Boolean;
       CygwinOk   : Boolean;    // cygwin1.dll
       CdrtoolsOk : Boolean;    // cdrecord.exe, mkisofs.exe
       VerInfoOk  : Boolean;    // cdrecord -version, mkisofs -version
       CdrdaoOk   : Boolean;
       Cdda2wavOk : Boolean;
       ReadcdOk   : Boolean;
       ISOInfoOk  : BOolean;
       ShOk       : Boolean;
       ShNeeded   : Boolean;
       UseSh      : Boolean;
       M2CDMOk    : Boolean;
       VCDImOk    : Boolean;
       ShlExtDllOk: Boolean;
       ProDVD     : Boolean;
       MadplayOk  : Boolean;
       OggdecOk   : Boolean;
       OggencOk   : Boolean;
       FLACOk     : Boolean;
       LameOk     : Boolean;
       MonkeyOk   : Boolean;
       WavegainOk : Boolean;
       RrencOk    : Boolean;
       RrdecOk    : Boolean;
       MPlayerOk  : Boolean;
       UseOwnDLLs : Boolean;
       CygInPath  : Boolean;    // cygwin1.dll found in searchpath
     end;

     TEnvironment = record
       ProDVDKey       : string;
       EnvironmentBlock: Pointer;
       EnvironmentSize : Integer;
       ProcessRunning  : Boolean;
     end;

     { Einstellungen: RSCSI, Laufwerkszuordnungen}
     TSettingsDrives = record
       {Remote-SCSI}
       UseRSCSI           : Boolean;
       Host               : string;
       RemoteDrives       : string;
       RSCSIString        : string;
       {lokale Laufwerke}
       LocalDrives        : string;
       AssignManually     : Boolean;
       SCSIInterface      : string;
     end;

     { Einstellungen: cdrecord/mkisofs allgemein}
     TSettingsCdrecord = record
       FixDevice  : string;  // Laufwerk zum fixieren, nur temporär
       Dummy      : Boolean; // gilt auch für cdrdao
       Eject      : Boolean;
       Verbose    : Boolean;
       Burnfree   : Boolean;
       SimulDrv   : Boolean;
       FIFO       : Boolean;
       FIFOSize   : Integer;
       ForceSpeed : Boolean;
       AutoErase  : Boolean;
       Erase      : Boolean;
       AllowFormat: Boolean;
       {zusätzliche Kommandotzeilenoptionen}
       CdrecordUseCustOpts  : Boolean;
       MkisofsUseCustOpts   : Boolean;
       CdrecordCustOpts     : TStringList;
       MkisofsCustOpts      : TStringList;
       CdrecordCustOptsIndex: Integer;
       MkisofsCustOptsIndex : Integer;
       {Versionsabhängigkeiten}
       CanWriteCueImage   : Boolean;  // 2.01a24: Cue-Image-Support ausreichend
       WritingModeRequired: Boolean;  // 2.01a26: -tao|-dao|-raw verpflichtend
       DMASpeedCheck      : Boolean;  // 2.01a33: DMA-Geschwindigkeitsprüfung
       HaveMediaInfo      : Boolean;  // 2.01.01a21: -minfo
       HaveNLPathtables   : Boolean;  // 2.01.01a31: -no-limit-pathtables
       HaveHideUDF        : Boolean;  // 2.01.01a32: -hide-udf
       CanEraseDVDPlusRW  : Boolean;  // 2.01.01a37: Löschen von DVD+RW
       HasMultiborder     : Boolean;  // 2.01.01a50: DVD-R(W) Multiborder
     end;

     {Einstellungen: cdrdao allgemein}
     TSettingsCdrdao = record
       ForceGenericMmc   : Boolean;
       ForceGenericMmcRaw: Boolean;
       WriteCueImages    : Boolean;
     end;

     { Einstellungen: Daten-CD }
     TSettingsDataCD = record
       {allgemeine Einstellungen}
       PathListName: string;
       ShCmdName   : string;
       IsoPath     : string;
       OnTheFly    : Boolean;
       ImageOnly   : Boolean;
       KeepImage   : Boolean;
       ContinueCD  : Boolean;
       Verify      : Boolean;
       {Einstellungen: mkisofs}
       Joliet      : Boolean;
       JolietLong  : Boolean;
       RockRidge   : Boolean;   // -R -rock
       RationalRock: Boolean;   // -r -rational-rock
       ISO31Chars  : Boolean;   // -l
       ISOLevel    : Boolean;
       ISOLevelNr  : Integer;   // 1 - 4; 0 = keine Angabe
       ISOOutChar  : Integer;   // -1 = keine Auswahl, sonst Index
       ISOInChar   : Integer;
       ISO37Chars  : Boolean;   // -max-iso-filenames
       ISONoDot    : Boolean;   // -d
       ISOStartDot : Boolean;   // -L -> mkisofs 2.01a32: -allow-leading-dots
       ISOMultiDot : Boolean;   // -allow-multidot
       ISOASCII    : Boolean;   // -relaxed-filenames
       ISOLower    : Boolean;   // -allow-lowercase
       ISONoTrans  : Boolean;   // -no-iso-translate
       ISODeepDir  : Boolean;   // -D
       ISONoVer    : Boolean;   // -N
       UDF         : Boolean;
       Boot        : Boolean;
       BootImage   : string;
       BootCatHide : Boolean;
       BootBinHide : Boolean;
       BootNoEmul  : Boolean;
       BootInfTable: Boolean;
       BootSegAdr  : string;
       BootLoadSize: string;
       VolId       : string;
       MsInfo      : string;    // MS-Info, wenn vom User gewählt!
       SelectSess  : Boolean;
       FindDups    : Boolean;
       TransTBL    : Boolean;
       HideTransTBL: Boolean;
       NLPathTBL   : Boolean;
       HideRRMoved : Boolean;
       ForceMSRR   : Boolean;
       {Meta-Daten}
       UseMeta     : Boolean;
       IDPublisher : string;
       IDPreparer  : string;
       IDCopyright : string;
       IDSystem    : string;
       {Einstellungen: cdrecord}
       Device      : string;
       Speed       : string;
       Multi       : Boolean;
       LastSession : Boolean;
       DAO         : Boolean;
       TAO         : Boolean;
       RAW         : Boolean;
       RAWMode     : string;
       Overburn    : Boolean;
     end;

     { Einstellungen: Audio-CD }
     TSettingsAudioCD = record
       Device     : string;
       Speed      : string;
       Multi      : Boolean;
       Fix        : Boolean;
       DAO        : Boolean;
       TAO        : Boolean;
       RAW        : Boolean;
       RAWMode    : string;
       Overburn   : Boolean;
       Preemp     : Boolean;
       Copy       : Boolean;
       SCMS       : Boolean;
       UseInfo    : Boolean;
       CDText     : Boolean;
       CDTextFile : string;
       Pause      : Integer;    // 0 = keine; 1 = für alle gleich; 2 = separat
       PauseLength: string;    // Länge in Sekunden bzw. Sektoren
       PauseSector: Boolean;    // Länge der Pause in Sektoren
       UTFToAnsi  : Boolean;
       ReplayGain : Boolean;
       Gain       : string;
     end;

     { Einstellungen: XCD }
     TSettingsXCD = record
       {allgemeine Einstellungen}
       XCDParamFile  : string;
       XCDInfoFile   : string;
       IsoPath       : string;
       ImageOnly     : Boolean;
       KeepImage     : Boolean;
       Verify        : Boolean;
       CreateInfoFile: Boolean;
       {Einstellungen: modecdmaker}
       VolID       : string;
       Ext         : string;
       IsoLevel1   : Boolean;
       IsoLevel2   : Boolean;
       KeepExt     : Boolean;
       Single      : Boolean;
       {Einstellungen: cdrdao}
       Device      : string;
       Speed       : string;
       Overburn    : Boolean;
       {Einstellungen: rrenc}
       XCDRrencInputFile : string;
       XCDRrencRRTFile   : string;
       XCDRrencRRDFile   : string;
       UseErrorProtection: Boolean;
       SecCount          : Integer;
     end;

     { Auswahl: CDRW }
     TSettingsCDRW = record
       Device      : string;
       Fast        : Boolean;
       All         : Boolean;
       OpenSession : Boolean;
       BlankSession: Boolean;
       Force       : Boolean; 
     end;

     { Auswahl: CD-Infos }
     TSettingsCDInfo = record
       Device  : string;
       Scanbus : Boolean;
       Prcap   : Boolean;
       Toc     : Boolean;
       Atip    : Boolean;
       MSInfo  : Boolean;
       MInfo   : Boolean;
       CapInfo : Boolean;
     end;

     { Einstellungen: DAE }
     TSettingsDAE = record
       Action     : Byte;
       Device     : string;
       Speed      : string;
       SpeedW     : string;
       Bulk       : Boolean;
       Paranoia   : Boolean;
       NoInfoFile : Boolean;
       Path       : string;
       PrefixNames: Boolean;
       Prefix     : string;
       NamePattern: string;
       Tracks     : string;
       Offset     : string;
       UseCDDB    : Boolean;
       CDDBServer : string;
       CDDBPort   : string;
       MP3        : Boolean;
       Ogg        : Boolean;
       FLAC       : Boolean;
       Custom     : Boolean;
       AddTags    : Boolean;
       FlacQuality: string;
       OggQuality : string;
       LamePreset : string;
       CustomCmd  : string;
       CustomOpt  : string;
       DoCopy     : Boolean;
       HiddenTrack: Boolean;
     end;

     { Einstellungen: Image schreiben }
     TSettingsImage = record
       Device  : string;
       Speed   : string;
       IsoPath : string;
       Overburn: Boolean;
       TAO     : Boolean;
       DAO     : Boolean;
       Clone   : Boolean;
       RAW     : Boolean;
       RAWMode : string;
       CDText  : Boolean;
     end;

     { Einstellungen: Image einlesen }
     TSettingsReadcd = record
       Device  : string;
       Speed   : string;
       IsoPath : string;
       Clone   : Boolean;
       Nocorr  : Boolean;
       Noerror : Boolean;
       Range   : Boolean;
       Startsec: string;
       Endsec  : string;
       DoCopy  : Boolean;
     end;

     { Einstellungen: Video-CD }
     TSettingsVideoCD = record
       Device    : string;
       Speed     : string;
       IsoPath   : string;
       VolID     : string;
       ImageOnly : Boolean;
       KeepImage : Boolean;
       VCD1      : Boolean;
       VCD2      : Boolean;
       SVCD      : Boolean;
       Overburn  : Boolean;
       Verbose   : Boolean;
       Sec2336   : Boolean;
       SVCDCompat: Boolean;
     end;

     { Einstellungen: DVD-Video }
     TSettingsDVDVideo = record
       Device    : string;
       Speed     : string;
       SourcePath: string;
       VolID     : string;
       IsoPath   : string;
       OnTheFly  : Boolean;
       ImageOnly : Boolean;
       KeepImage : Boolean;
       Verify    : Boolean;
       ShCmdName : string;
     end;

     { Einstellungen: Hacks }
     TSettingsHacks = record
       DisableDVDCheck: Boolean;
     end;

     { Hilfsvariablen }

     { Objekt mit den Einstellungen }
     TSettings = class(TObject)
     private
       FLang: TLang;
       FOnProgressBarHide: TProgressBarHideEvent;
       FOnProgressBarShow: TProgressBarShowEvent;
       FOnProgressBarUpdate: TProgressBarUpdateEvent;
       FOnUpdatePanels: TUpdatePanelsEvent;
       function GetIniPath(Load: Boolean): string;
       procedure InitSettings;
       {Events}
       procedure ProgressBarHide;
       procedure ProgressBarShow(const Max: Integer);
       procedure ProgressBarUpdate(const Position: Integer);
       procedure UpdatePanels(const s1, s2: string);
     public
       General     : TGeneralSettings;
       WinPos      : TWinPos;
       FileExplorer: TFileExplorer;
       CmdLineFlags: TCmdLineFlags;
       FileFlags   : TFileFlags;
       Environment : TEnvironment;
       Drives      : TSettingsDrives;
       Cdrecord    : TSettingsCdrecord;
       Cdrdao      : TSettingsCdrdao;
       DataCD      : TSettingsDataCD;
       AudioCD     : TSettingsAudioCD;
       XCD         : TSettingsXCD;
       CDRW        : TSettingsCDRW;
       CDInfo      : TSettingsCDInfo;
       DAE         : TSettingsDAE;
       Image       : TSettingsImage;
       Readcd      : TSettingsReadcd;
       VideoCD     : TSettingsVideoCD;
       DVDVideo    : TSettingsDVDVideo;
       Hacks       : TSettingsHacks;
       constructor Create;
       destructor Destroy; override;
       function GetMaxFileNameLength: Byte;
       procedure LoadFromFile(const Name: string);
       procedure SaveToFile(const Name: string);
       procedure SetDefaultPaths;
       procedure UnsetDefaultPaths;
       procedure DeleteIniFile;
       property Lang: TLang write FLang;
       {Events}
       property OnProgressBarHide: TProgressBarHideEvent read FOnProgressBarHide write FOnProgressBarHide;
       property OnProgressBarShow: TProgressBarShowEvent read FOnProgressBarShow write FOnProgressBarShow;
       property OnProgressBarUpdate: TProgressBarUpdateEvent read FOnProgressBarUpdate write FOnProgressBarUpdate;
       property OnUpdatePanels: TUpdatePanelsEvent read FOnUpdatePanels write FOnUpdatePanels;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_wininfo, f_helper, f_logfile;

const CSIDL_MyMusic = $000d;

{ TSettings ------------------------------------------------------------------ }

{ TSettings - private }

{ ProgressBarHide --------------------------------------------------------------

  Löst das Event OnProgressBarHide aus, daß den Progress-Bar des Hauptfensters
  unsichtbar macht.                                                            }

procedure TSettings.ProgressBarHide;
begin
  if Assigned(FOnProgressBarHide) then FOnProgressBarHide(1);
end;

{ ProgressBarShow --------------------------------------------------------------

  Löst das Event OnProgressBarReset aus, daß den Progress-Bar des Hauptfensters
  sichtbar macht und zurücksetzt.                                              }

procedure TSettings.ProgressBarShow(const Max: Integer);
begin
  if Assigned(FOnProgressBarShow) then FOnProgressBarShow(1, Max);
end;

{ ProgressBarUpdate ------------------------------------------------------------

  Löst das Event OnProgressBarUpdate aus, daß den Progress-Bar des Hauptfensters
  aktualisiert.                                                                }

procedure TSettings.ProgressBarUpdate(const Position: Integer);
begin
  if Assigned(FOnProgressBarUpdate) then FOnProgressBarUpdate(1, Position);
end;

{ UpdatePanels -----------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TSettings.UpdatePanels(const s1, s2: string);
begin
  if Assigned(FOnUpdatePanels) then FOnUpdatePanels(s1, s2);
end;

{ InitSettings -----------------------------------------------------------------

  InitSettings initialisiert alle Variablen des Objekt TSettings. Hier werden
  auch Vorbelgungen für Optionen vorgenommen.                                  }

procedure TSettings.InitSettings;
var i, j: Integer;
begin
  {allgemeine Einstellungen/Statusvaraiblen}
  with General do
  begin
    CharSets.CommaText := ',cp437,cp737,cp775,cp850,cp852,cp855,cp857,'       +
                          'cp860,cp861,cp862,cp863,cp864,cp865,cp866,'        +
                          'cp869,cp874,cp1250,cp1251,cp10081,cp10079,'        +
                          'cp10029,cp10007,cp10006,cp10000,iso8859-1,'        +
                          'iso8859-2,iso8859-3,iso8859-4,iso8859-5,'          +
                          'iso8859-6,iso8859-7,iso8859-8,iso8859-9,'          +
                          'iso8859-14,iso8859-15,koi8-u,koi8-r,'              +
                          'cp1252,cp1253,cp1254,cp1255,cp1256,cp1257,cp1258,' +
                          'iso8859-10,iso8859-11,iso8859-13,iso8859-16,default';
    Mp3Qualities.CommaText := 'medium,standard,extreme,insane,' +
                              '320,256,224,192,160,128,112,96,80';
    General.Choice := 0;
    XCDAddMovie := False;
    TempBoot := False;
    {aktuelles Laufwerk für jedes TabSheet}
    for i := 1 to TabSheetCount do
    begin
      TabSheetDrive[i]  := 0;
      TabSheetSpeed[i]  := -1;
      TabSheetSMType[i] := 0;
    end;
    ImageRead := True;
    CDCopy := False;
    NoConfirm := False;
    TabFrmSettings := cCdrtfe;
    TabFrmDAE      := cTabDAE;
    TabFrmDCDFS    := cTabFSGen; 
    NoWriter := False;
    NoReader := False;
    NoDevices := False;
    LastProject := '';
    IniFile := '';
    TempFolder := '';
    AskForTempDir := False;
    CDTextUseTags := True;
    CDTextTP := False;
    PortableMode := False;
    DetectSpeeds := False;
    AutoSaveOnExit := False;
    AllowFileOpen := True;
    AllowDblClick := True;
    UseMPlayer := False;
    MPlayerCmd := '';
    MPlayerOpt := '%N';
    FileInfoTitle := False;
    SpaceMeter := True;
    DisableScrSvr := False;
    ShowFolderSize := False;
  end;

  with WinPos do
  begin
    MainTop       := 0;
    MainLeft      := 0;
    MainHeight    := 0;
    MainWidth     := 0;
    MainMaximized := False;
    OutTop        := 0;
    OutLeft       := 0;
    OutHeight     := 0;
    OutWidth      := 0;
    OutMaximized  := False;
    OutScrolled   := True;
    for i := 0 to cLVCount do
      for j := 0 to cLVMaxColCount  do
        LVColWidth[i, j] := -1;
  end;

  with FileExplorer do
  begin
    Height := 192;
    Showing := False;
    Path := '';
  end;

  with CmdLineFlags do
  begin
    ExecuteProject     := False;
    ExitAfterExecution := False;
    Hide               := False;
    Minimize           := False;
    WriteLogFile       := False;
  end;

  with FileFlags do
  begin
    Mingw       := False;
    IniFileOk   := True;
    CygwinOk    := True;
    CdrtoolsOk  := True;
    VerInfoOk   := True;
    CdrdaoOk    := True;
    Cdda2wavOk  := True;
    ReadcdOk    := True;
    ISOInfoOk   := True;
    ShOk        := True;
    ShNeeded    := True;
    UseSh       := True;
    M2CDMOk     := True;
    VCDImOk     := True;
    ShlExtDllOk := True;
    ProDVD      := False;
    MadplayOK   := True;
    LameOk      := True;
    OggdecOk    := True;
    OggencOk    := True;
    FLACOk      := True;
    MonkeyOk    := True;
    WavegainOk  := True;
    RrencOk     := True;
    RrdecOk     := True;
    MPlayerOk   := True;
    UseOwnDLLs  := True;
    CygInPath   := False;
  end;

  with Environment do
  begin
    ProDVDKey        := '';
    EnvironmentBlock := nil;
    EnvironmentSize  := 0;
    ProcessRunning   := False;
  end;

  with Drives do
  begin
    UseRSCSI       := False;
    Host           := '';
    RemoteDrives   := '';
    RSCSIString    := '';
    LocalDrives    := '';
    AssignManually := False;
    SCSIInterface  := '';
  end;                        

  {allgemeine Einstellungen: cdrecord}
  with Cdrecord do
  begin
    FixDevice   := '';
    Dummy       := False;
    Eject       := False;
    Verbose     := True;
    Burnfree    := True;
    SimulDrv    := False;
    FIFO        := False;
    FIFOSize    := 4;
    ForceSpeed  := False;
    AutoErase   := False;
    Erase       := False;
    AllowFormat := False;
    CdrecordUseCustOpts   := False;
    MkisofsUseCustOpts    := False;
    CdrecordCustOptsIndex := -1;
    MkisofsCustOptsIndex  := -1;
    CanWriteCueImage    := False;  
    WritingModeRequired := False;
    DMASpeedCheck       := False;
    HaveMediaInfo       := False;
    HaveNLPathtables    := False;
    HaveHideUDF         := False;
    CanEraseDVDPlusRW   := False;
    HasMultiborder      := False;
  end;

  {allgemeine Einstellungen: cdrdao}
  with Cdrdao do
  begin
    ForceGenericMmc    := False;
    ForceGenericMmcRaw := False;
    WriteCueImages     := False;
  end;

  {Daten-CD}
  with DataCD do
  begin
    {allgemeine Einstellungen}
    PathListName := '';
    ShCmdName    := '';
    IsoPath      := '';
    OnTheFly     := False;
    ImageOnly    := False;
    KeepImage    := False;
    ContinueCD   := False;
    Verify       := False;
    {Einstellungen: mkisofs}
    Joliet       := True;
    JolietLong   := False;
    RockRidge    := False;
    RationalRock := True;
    ISO31Chars   := False;
    ISOLevel     := False;
    ISOLevelNr   := 0;
    ISOOutChar   := -1;
    ISOInChar    := -1;
    ISO37Chars   := False;
    ISONoDot     := False;
    ISOStartDot  := False;
    ISOMultiDot  := False;
    ISOASCII     := False;
    ISOLower     := False;
    ISONoTrans   := False;
    ISODeepDir   := False;
    ISONoVer     := False;
    UDF          := False;
    Boot         := False;
    BootImage    := '';
    BootCatHide  := False;
    BootBinHide  := False;
    BootNoEmul   := False;
    BootInfTable := False;
    BootSegAdr   := '';
    BootLoadSize := '';
    VolId        := '';
    MsInfo       := '';
    SelectSess   := False;
    FindDups     := False;
    TransTBL     := False;
    HideTransTBL := True;
    NLPathTBL    := False;
    HideRRMoved  := False;
    ForceMSRR    := True;
    {Meta-Daten}
    UseMeta      := False;
    IDPublisher  := '';
    IDPreparer   := '';
    IDCopyright  := '';
    IDSystem     := '';
    {Einstellungen: cdrecord}
    Device       := '';
    Speed        := '';
    Multi        := False;
    LastSession  := False;
    DAO          := False;
    TAO          := True;
    RAW          := False;
    RAWMode      := 'raw96r';
    Overburn     := False;
  end;

  {Audio-CD}
  with AudioCD do
  begin
    Device      := '';
    Speed       := '';
    Multi       := False;
    Fix         := True;
    DAO         := True;
    TAO         := False;
    RAW         := False;
    RAWMode     := 'raw96r';
    Overburn    := False;
    Preemp      := False;
    Copy        := False;
    SCMS        := False;
    UseInfo     := False;
    CDText      := False;
    CDTextFile  := '';
    Pause       := 1;       // für alle Tracks gleiche Pausenlänge
    PauseLength := '2';     // Länge 2
    PauseSector := False;   // Länge in Sekunden
    UTFToAnsi   := False;
    ReplayGain  := False;
    Gain        := '';
  end;

  {XCD}
  with XCD do
  begin
    {allgemeine Einstellungen}
    XCDParamFile   := '';
    XCDInfoFile    := '';
    IsoPath        := '';
    ImageOnly      := False;
    KeepImage      := False;
    Verify         := False;
    CreateInfoFile := True;
    {Einstellungen: modecdmaker}
    VolID          := '';
    Ext            := '';
    IsoLevel1      := False;
    IsoLevel2      := False;
    KeepExt        := True;
    Single         := True;
    {Einstellungen: cdrdao}
    Device         := '';
    Speed          := '';
    Overburn       := False;
    {Einstellungen rrenc}
    XCDRrencInputFile  := '';
    XCDRrencRRTFile    := '';
    XCDRrencRRDFile    := '';
    UseErrorProtection := False;
    SecCount           := 3600;
  end;

  {CDRW}
  with CDRW do
  begin
    Device       := '';
    Fast         := True;
    All          := False;
    OpenSession  := False;
    BlankSession := False;
    Force        := False;
  end;

  {CDInfo}
  with CDInfo do
  begin
    Device   := '';
    Scanbus  := True;
    Prcap    := False;
    Toc      := False;
    Atip     := False;
    MSInfo   := False;
    MInfo    := False;
    CapInfo  := False;
  end;

  {DAE}
  with DAE do
  begin
    Action      := 0;
    Device      := '';
    Speed       := '';
    SpeedW      := '';
    Bulk        := True;
    Paranoia    := False;
    NoInfoFile  := True;
    Path        := '';
    PrefixNames := True;
    Prefix      := 'track';
    NamePattern := '%N %P - %T';
    Tracks      := '';
    Offset      := '';
    UseCDDB     := False;
    CDDBServer  := '';
    CDDBPort    := '';
    MP3         := False;
    Ogg         := False;
    FLAC        := False;
    Custom      := False;
    AddTags     := True;
    FlacQuality := '5';
    OggQuality  := '6';
    LamePreset  := 'standard';
    CustomCmd   := '';
    CustomOpt   := '';
    DoCopy      := False;
    HiddenTrack := False;
  end;

  {Image schreiben}
  with Image do
  begin
    Device   := '';
    Speed    := '';
    IsoPath  := '';
    Overburn := False;
    DAO      := False;
    TAO      := True;
    Clone    := False;
    RAW      := False;
    RAWMode  := 'raw96r';
    CDText   := False;
  end;

  {Image einlesen}
  with Readcd do
  begin
    Device   := '';
    Speed    := '';
    IsoPath  := '';
    Clone    := False;
    Nocorr   := False;
    Noerror  := False;
    Range    := False;
    Startsec := '';
    Endsec   := '';
    DoCopy   := False;
  end;

  {Video-CD}
  with VideoCD do
  begin
    Device     := '';
    Speed      := '';
    IsoPath    := '';
    VolID      := '';
    ImageOnly  := False;
    KeepImage  := False;
    VCD1       := False;
    VCD2       := True;
    SVCD       := False;
    Overburn   := False;
    Verbose    := True;
    Sec2336    := False;
    SVCDCompat := False;

  end;

  {DVD-Video}
  with DVDVideo do
  begin
    Device     := '';
    Speed      := '';
    SourcePath := '';
    VolID      := '';
    IsoPath    := '';
    OnTheFly   := True;
    ImageOnly  := False;
    KeepImage  := False;
    Verify     := False;
    ShCmdName  := '';
  end;

  {Hacks}
  with Hacks do
  begin
    DisableDVDCheck := False;
  end;
end;

{ GetIniPath -------------------------------------------------------------------

  GetIniPath ermittelt den Pfad zur Ini-Datei. Wenn cdrtfe unter NT ausgeführt
  wird, werden nacheinander die Verzeichnisse CSIDL_LOCAL_APPDATA, _APPDATA und
  _COMMON_APPDATA getestet. Das erste Verzeichnis, das existiert, wird für die
  Ini-Datei verwendet.
  Unter Win9x wird die Ini-Datei im Programmverzeichnis von cdrtfe gespeichert.}

function TSettings.GetIniPath(Load: Boolean): string;
var Temp: string;
    Name: string;
begin
  if not Load then
  begin
    {eine neue Ini anlegen, wir brauchen das Daten-Verzeichnis}
    Result := ProgDataDir;
  end else
  begin
    {Ini-Datei laden, allemöglichen Verzeichnisse ausprobieren}
    Name := cDataDir + cIniFile;
    if PlatformWinNT then
    begin
      Temp := GetShellFolder(CSIDL_LOCAL_APPDATA) + Name;
      if not FileExists(Temp) then
      begin
        Temp := GetShellFolder(CSIDL_APPDATA) + Name;
        if not FileExists(Temp) then
        begin
          Temp := GetShellFolder(CSIDL_COMMON_APPDATA) + Name;
          if not FileExists(Temp) then
          begin
            Temp := StartUpDir + cIniFile;
            if not FileExists(Temp) then
            begin
              Temp := '';
            end;
          end;
        end;
      end;
      {Sonderbehanldung, wenn cdrtfe im Portable-Mode ist}
      if General.PortableMode then
      begin
        Temp := StartUpDir + cIniFile;
        if not FileExists(Temp) then
        begin
          Temp := '';
        end;
      end;
      Result := Temp;
    end else
    begin
      Temp := StartUpDir + cIniFile;
      if not FileExists(Temp) then
      begin
        Temp := '';
      end;
      Result := Temp;
    end;
  end;
  {$IFDEF WriteLogFile}
  AddLogCode(1300);
  AddLog(Temp + CRLF + ' ', 3);
  {$ENDIF}
end;

{ SetDefaultPath ---------------------------------------------------------------

  SetDefaultPaths setzt die Standardwerte für die Pfade zur Image-Datei und zum
  temporären Ordner.}

procedure TSettings.SetDefaultPaths;
var DefaultDir      : string;
    DefaultImageName: string;
    DefaultImageFile: string;
begin
  {Vorgaben für Images und temporäre Ordner}
  DefaultDir       := f_locations.TempDir;
  DefaultImageName := DefaultDir + cDefaultIsoName;
  DefaultImageFile := DefaultImageName + cExtIso;
  if DefaultDir <> '' then
  begin
    if DataCD.IsoPath     = '' then DataCD.IsoPath     := DefaultImageFile;
    if XCD.IsoPath        = '' then XCD.IsoPath        := DefaultImageName;
    if VideoCD.IsoPath    = '' then VideoCD.IsoPath    := DefaultImageName;
    if DVDVideo.IsoPath   = '' then DVDVideo.IsoPath   := DefaultImageFile;
    if General.TempFolder = '' then General.TempFolder := DefaultDir;
  end;
  {Vorgabe für Wave-Dateien von CD (DAE)}
  DefaultDir := GetShellFolder(CSIDL_MyMusic);
  if (DefaultDir <> '') then
  begin
    if DAE.Path           = '' then DAE.Path           := DefaultDir;
  end;
end;

{ UnsetDefaultPaths ------------------------------------------------------------

  UnsetDefaultPaths löscht die Pfadangaben für Image-Datei und temporären
  Ordner.                                                                      }

procedure TSettings.UnsetDefaultPaths;
var DefaultDir      : string;
    DefaultImageName: string;
    DefaultImageFile: string;
begin
  {Images und temporäre Verzeichnisse}
  DefaultDir       := f_locations.TempDir;
  DefaultImageName := DefaultDir + cDefaultIsoName;
  DefaultImageFile := DefaultImageName + cExtIso;
  if DataCD.IsoPath     = DefaultImageFile then DataCD.IsoPath     := '';
  if XCD.IsoPath        = DefaultImageName then XCD.IsoPath        := '';
  if VideoCD.IsoPath    = DefaultImageName then VideoCD.IsoPath    := '';
  if DVDVideo.IsoPath   = DefaultImageFile then DVDVideo.IsoPath   := '';
  if General.TempFolder = DefaultDir       then General.TempFolder := '';
  {DAE-Pfad}
  DefaultDir := GetShellFolder(CSIDL_MyMusic);
  if DAE.Path           = DefaultDir       then DAE.Path           := '';
end;

{ TSettings - public }

constructor TSettings.Create;
begin
  inherited Create;
  General.Charsets := TStringList.Create;
  General.Mp3Qualities := TStringList.Create;
  Cdrecord.CdrecordCustOpts := TStringList.Create;
  Cdrecord.MkisofsCustOpts  := TStringList.Create;
  InitSettings;
end;

destructor TSettings.Destroy;
begin
  General.CharSets.Free;
  General.Mp3Qualities.Free;
  Cdrecord.CdrecordCustOpts.Free;
  Cdrecord.MkisofsCustOpts.Free;
  inherited Destroy;
end;

{ GetMaxFileNameLength ---------------------------------------------------------

  GetMaxFileNameLength liefert die maximale Länge für Dateinamen in Abhängigkeit
  der aktuellen Dateisystemeinstellungen.                                      }

function TSettings.GetMaxFileNameLength: Byte;
begin
  with DataCD do
  begin
    if not Joliet and not ISOLevel and UDF then
    begin
      Result := 247;  // UDF
    end else
    if Joliet and not JolietLong then
    begin
      Result := 64;   // Joliet
    end else
    if Joliet and JolietLong then
    begin
      Result := 103;  // Joliet-long
    end else
    if ISOLevel and (ISOLevelNr = 4) and not RockRidge then
    begin
      Result := 207;  // ISO9660:1999
    end else
    if ISOLevel and (ISOLevelNr = 4) and RockRidge then
    begin
      Result := 197;  // ISO9660:1999 + RockRidge
    end else
    if ISO37chars then
    begin
      Result := 37;   // ISO9660 + Allow 37 chars
    end else
    if ISO31chars or (ISOLevel and (ISOLevelNr < 4) and (ISOLevelNr > 1)) then
    begin
      Result := 31;   // ISO9660 Level 2-3 + Allow 31 chars
    end else
    begin
      Result := 12;   // ISO9660 (Level 1), 8.3-Format
    end;
  end;
end;

{ SaveToFile -------------------------------------------------------------------

  SaveToFile speichert (fast) alle Einstellungen in einer Ini-Datei.           }

procedure TSettings.SaveToFile(const Name: string);
var PF     : TIniFile; // ProjectFile
    IniPath: string;

  {lokale Prozedur, die die Einstellungen in die Datei PF schreibt, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure SaveSettings;
  var Section : string;
      TempList: TStringList;
      i, j    : Integer;
  begin
    TempList := TStringList.Create;
    {allgemeine Einstellungen/Statusvaraiblen}
    Section := 'General';
    with PF, General do
    begin
      WriteInteger(Section, 'Choice', Choice);
      for i := 1 to TabSheetCount do
      begin
        WriteInteger(Section, 'TabSheetDrive' + IntToStr(i), TabSheetDrive[i]);
        WriteInteger(Section, 'TabSheetSpeed' + IntToStr(i), TabSheetSpeed[i]);
        WriteInteger(Section, 'TabSheetSMType' + IntToStr(i), TabSheetSMType[i]);
      end;
      WriteBool(Section, 'ImageRead', ImageRead);
      WriteBool(Section, 'NoConfirm', NoConfirm);
      WriteInteger(Section, 'TabFrmSettings', TabFrmSettings);
      WriteInteger(Section, 'TabFrmDAE', TabFrmDAE);
      WriteInteger(Section, 'TabFrmDCDFS', TabFrmDCDFS);
      WriteString(Section, 'TempFolder', TempFolder);
      WriteBool(Section, 'AskForTempDir', AskForTempDir);
      WriteBool(Section, 'CDTextUseTags', CDTextUseTags);
      WriteBool(Section, 'CDTextTP', CDTextTP);
      WriteBool(Section, 'DetectSpeeds', DetectSpeeds);
      WriteBool(Section, 'AutoSaveOnExit', AutoSaveOnExit);
      WriteBool(Section, 'AllowFileOpen', AllowFileOpen);
      WriteBool(Section, 'AllowDblClick', AllowDblClick);
      WriteBool(Section, 'UseMPlayer', UseMPlayer);
      WriteString(Section, 'MPlayerCmd', MPlayerCmd);
      WriteString(Section, 'MPlayerOpt', MPlayerOpt);
      WriteBool(Section, 'FileInfoTitle', FileInfoTitle);
      WriteBool(Section, 'SpaceMeter', SpaceMeter);
      WriteBool(Section, 'DisableScrSvr', DisableScrSvr);
      WriteBool(Section, 'ShowFolderSize', ShowFolderSize);
    end;

    {Die Fensterpositionen und Drive-Settings sollen nicht in 'normalen'
     Projekt-Dateien gesichert werden.}
    if Name = cIniFile then
    begin
      Section := 'WinPos';
      with PF, WinPos do
      begin
        WriteInteger(Section, 'MainTop', MainTop);
        WriteInteger(Section, 'MainLeft', MainLeft);
        WriteInteger(Section, 'MainWidth', MainWidth);
        WriteInteger(Section, 'MainHeight', MainHeight);
        WriteBool(Section, 'MainMaximized', MainMaximized);
        WriteInteger(Section, 'OutTop', OutTop);
        WriteInteger(Section, 'OutLeft', OutLeft);
        WriteInteger(Section, 'OutWidth', OutWidth);
        WriteInteger(Section, 'OutHeight', OutHeight);
        WriteBool(Section, 'OutMaximized', OutMaximized);
        WriteBool(Section, 'OutScrolled', OutScrolled);
        for i := 0 to cLVCount do
        begin
          TempList.Clear;
          for j := 0 to cLVMaxColCount do
            TempList.Add(IntToStr(LVColWidth[i, j]));
          WriteString(Section, 'LVCols' + IntToStr(i), TempList.CommaText);
        end;
      end;

      Section := 'FileExplorer';
      with PF, FileExplorer do
      begin
        WriteBool(Section, 'Showing', Showing);
        WriteString(Section, 'Path', Path);
      end;

      Section := 'Drives';
      with PF, Drives do
      begin
        WriteBool(Section, 'UseRSCSI', UseRSCSI);
        WriteString(Section, 'Host', Host);
        WriteString(Section, 'RemoteDrives', RemoteDrives);
        WriteString(Section, 'LocalDrives', LocalDrives);
        WriteBool(Section, 'AssignManually', AssignManually);
        WriteString(Section, 'SCSIInterface', SCSIInterface);
      end;
    end;

    {allgemeine Einstellungen: cdrecord}
    Section := 'cdrecord';
    with PF, Cdrecord do
    begin
      WriteBool(Section, 'Dummy', Dummy);
      WriteBool(Section, 'Eject', Eject);
      WriteBool(Section, 'Verbose', Verbose);
      WriteBool(Section, 'Burnfree', Burnfree);
      WriteBool(Section, 'SimulDrv', SimulDrv);
      WriteBool(Section, 'FIFO', FIFO);
      WriteInteger(Section, 'FIFOSize', FIFOSize);
      WriteBool(Section, 'ForceSpeed', ForceSpeed);
      WriteBool(Section, 'AutoErase', AutoErase);
      WriteBool(Section, 'AllowFormat', AllowFormat);
      WriteBool(Section, 'CdrecordUseCustOpts', CdrecordUseCustOpts);
      WriteInteger(Section, 'CdrecordCustOptsIndex', CdrecordCustOptsIndex);
      WriteInteger(Section, 'CdrecordCustOptsCount', CdrecordCustOpts.Count);
      for i := 0 to CdrecordCustOpts.Count - 1 do
      begin
        WriteString(Section, 'CdrecordCustOpts' + IntToStr(i),
                    CdrecordCustOpts[i]);
      end;
      WriteBool(Section, 'MkisofsUseCustOpts', MkisofsUseCustOpts);
      WriteInteger(Section, 'MkisofsCustOptsIndex', MkisofsCustOptsIndex);
      WriteInteger(Section, 'MkisofsCustOptsCount', MkisofsCustOpts.Count);
      for i := 0 to MkisofsCustOpts.Count - 1 do
      begin
        WriteString(Section, 'MkisofsCustOpts' + IntToStr(i),
                    MkisofsCustOpts[i]);
      end;
    end;

    {allgemeine Einstellungen: cdrdao}
    Section := 'cdrdao';
    with PF, Cdrdao do
    begin
      WriteBool(Section, 'ForceGenericMmc', ForceGenericMmc);
      WriteBool(Section, 'ForceGenericMmcRaw', ForceGenericMmcRaw);
      WriteBool(Section, 'WriteCueImages', WriteCueImages);
    end;

    {Daten-CD}
    Section := 'Data-CD';
    with PF, DataCD do
    begin
      {allgemeine Einstellungen}
      WriteString(Section, 'IsoPath', IsoPath);
      WriteBool(Section, 'OnTheFly', OnTheFly);
      WriteBool(Section, 'ImageOnly', ImageOnly);
      WriteBool(Section, 'KeepImage', KeepImage);
      WriteBool(Section, 'ContinueCD', ContinueCD);
      WriteBool(Section, 'Verify', Verify);
      {Einstellungen: mkisofs}
      WriteBool(Section, 'Joliet', Joliet);
      WriteBool(Section, 'JolietLong', JolietLong);
      WriteBool(Section, 'RockRidge', RockRidge);
      WriteBool(Section, 'RationalRock', RationalRock);
      WriteBool(Section, 'ISO31Chars', ISO31Chars);
      WriteBool(Section, 'ISOLevel', ISOLevel);
      WriteInteger(Section, 'ISOLevelNr', ISOLevelNr);
      WriteInteger(Section, 'ISOOutChar', ISOOutChar);
      WriteInteger(Section, 'ISOInChar', ISOInChar);
      WriteBool(Section, 'ISO37Chars', ISO37Chars);
      WriteBool(Section, 'ISONoDot', ISONoDot);
      WriteBool(Section, 'ISOStartDot', ISOStartDot);
      WriteBool(Section, 'ISOMultiDot', ISOMultiDot);
      WriteBool(Section, 'ISOASCII', ISOASCII);
      WriteBool(Section, 'ISOLower', ISOLower);
      WriteBool(Section, 'ISONoTrans', ISONoTrans);
      WriteBool(Section, 'ISODeepDir', ISODeepDir);
      WriteBool(Section, 'ISONoVer', ISONoVer);
      WriteBool(Section, 'UDF', UDF);
      WriteBool(Section, 'Boot', Boot);
      WriteString(Section, 'BootImage', BootImage);
      WriteBool(Section, 'BootCatHide', BootCatHide);
      WriteBool(Section, 'BootBinHide', BootBinHide);
      WriteBool(Section, 'BootNoEmul', BootNoEmul);
      WriteBool(Section, 'BootInfTable', BootInfTable);
      WriteString(Section, 'BootSegAdr', BootSegAdr);
      WriteString(Section, 'BootLoadSize', BootLoadSize);
      WriteString(Section, 'VolId', VolId);
      WriteBool(Section, 'FindDups', FindDups);
      WriteBool(Section, 'TransTBL', TransTBL);
      WriteBool(Section, 'HideTransTBL', HideTransTBL);
      WriteBool(Section, 'NLPathTBL', NLPathTBL);
      WriteBool(Section, 'HideRRMoved', HideRRMoved);
      WriteBool(Section, 'SelectSess', SelectSess);
      WriteBool(Section, 'ForceMSRR', ForceMSRR);
      {Meta-Daten}
      WriteBool(Section, 'UseMeta', UseMeta);
      WriteString(Section, 'Publisher', IDPublisher);
      WriteString(Section, 'Preparer', IDPreparer);
      WriteString(Section, 'Copyright', IDCopyright);
      WriteString(Section, 'System', IDSystem);
      {Einstellungen: cdrecord}
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteBool(Section, 'Multi', Multi);
      WriteBool(Section, 'DAO', DAO);
      WriteBool(Section, 'TAO', TAO);
      WriteBool(Section, 'RAW', RAW);
      WriteString(Section, 'RAWMode', RAWMode);
      WriteBool(Section, 'Overburn', Overburn);
    end;

    {Audio-CD}
    Section := 'Audio-CD';
    with PF, AudioCD do
    begin
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteBool(Section, 'Multi', Multi);
      WriteBool(Section, 'Fix', Fix);
      WriteBool(Section, 'DAO', DAO);
      WriteBool(Section, 'TAO', TAO);
      WriteBool(Section, 'RAW', RAW);
      WriteString(Section, 'RAWMode', RAWMode);
      WriteBool(Section, 'Overburn', Overburn);
      WriteBool(Section, 'Preemp', Preemp);
      WriteBool(Section, 'Copy', Copy);
      WriteBool(Section, 'SCMS', SCMS);
      WriteBool(Section, 'UseInfo', UseInfo);
      WriteBool(Section, 'CDText', CDText);
      WriteInteger(Section, 'Pause', Pause);
      WriteString(Section, 'PauseLength', PauseLength);
      WriteBool(Section, 'PauseSector', PauseSector);
      WriteBool(Section, 'UTFToAnsi', UTFToAnsi);
      WriteBool(Section, 'ReplayGain', ReplayGain);
      WriteString(Section, 'Gain', Gain);
    end;

    {XCD}
    Section := 'XCD';
    with PF, XCD do
    begin
      {allgemeine Einstellungen}
      WriteString(Section, 'IsoPath', IsoPath);
      WriteBool(Section, 'ImageOnly', ImageOnly);
      WriteBool(Section, 'KeepImage', KeepImage);
      WriteBool(Section, 'Verify', Verify);
      WriteBool(Section, 'CreateInfoFile', CreateInfoFile);
      {Einstellungen: modecdmaker}
      WriteString(Section, 'VolID', VolID);
      WriteString(Section, 'Ext', Ext);
      WriteBool(Section, 'IsoLevel1', IsoLevel1);
      WriteBool(Section, 'IsoLevel2', IsoLevel2);
      WriteBool(Section, 'KeepExt', KeepExt);
      WriteBool(Section, 'Single', Single);
      {Einstellungen: cdrdao}
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteBool(Section, 'Overburn', Overburn);
      {Einstellung: rrenc}
      WriteBool(Section, 'UseErrorProtection', UseErrorProtection);
      WriteInteger(Section, 'SecCount', SecCount);
    end;

    {CDRW}
    Section := 'CDRW';
    with PF, CDRW do
    begin
      WriteString(Section, 'Device', Device);
      WriteBool(Section, 'Fast', Fast);
      WriteBool(Section, 'All', All);
      WriteBool(Section, 'OpenSession', OpenSession);
      WriteBool(Section, 'BlankSession', BlankSession);
      WriteBool(Section, 'Force', Force);
    end;

    {CDInfo}
    Section := 'CDInfo';
    with PF, CDInfo do
    begin
      WriteString(Section, 'Device', Device);
      WriteBool(Section, 'Scanbus', Scanbus);
      WriteBool(Section, 'Prcap', Prcap);
      WriteBool(Section, 'Toc', Toc);
      WriteBool(Section, 'Atip', Atip);
      WriteBool(Section, 'MSInfo', MSInfo);
      WriteBool(Section, 'MInfo', MInfo);
      WriteBool(Section, 'CapInfo', CapInfo);
    end;

    {DAE}
    Section := 'DAE';
    with PF, DAE do
    begin
      WriteInteger(Section, 'Action', Action);
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteString(Section, 'SpeedW', SpeedW);
      WriteBool(Section, 'Bulk', Bulk);
      WriteBool(Section, 'Paranoia', Paranoia);
      WriteBool(Section, 'NoInfoFile', NoInfoFile);
      WriteString(Section, 'Path', Path);
      WriteBool(Section, 'PrefixNames', PrefixNames);
      WriteString(Section, 'Prefix', Prefix);
      WriteString(Section, 'NamePattern', NamePattern);
      WriteString(Section, 'Tracks', Tracks);
      WriteString(Section, 'Offset', Offset);
      WriteBool(Section, 'UseCDDB', UseCDDB);
      WriteString(Section, 'CDDBServer', CDDBServer);
      WriteString(Section, 'CDDBPort', CDDBPort);
      WriteBool(Section, 'MP3', MP3);
      WriteBool(Section, 'Ogg', Ogg);
      WriteBool(Section, 'FLAC', FLAC);
      WriteBool(Section, 'Custom', Custom);
      WriteBool(Section, 'AddTags', AddTags);
      WriteString(Section, 'FlacQuality', FlacQuality);
      WriteString(Section, 'OggQuality', OggQuality);
      WriteString(Section, 'LamePreset', LamePreset);
      WriteString(Section, 'CustomCmd', CustomCmd);
      WriteString(Section, 'CustomOpt', CustomOpt);
      WriteBool(Section, 'DoCopy', DoCopy);
    end;

    {Image schreiben}
    Section := 'Image';
    with PF, Image do
    begin
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteString(Section, 'IsoPath', IsoPath);
      WriteBool(Section, 'OverBurn', Overburn);
      WriteBool(Section, 'DAO', DAO);
      WriteBool(Section, 'TAO', TAO);
      WriteBool(Section, 'Clone', Clone);
      WriteBool(Section, 'RAW', RAW);
      WriteString(Section, 'RAWMode', RAWMode);
      WriteBool(Section, 'CDText', CDText);
    end;

    {Image einlesen}
    Section := 'Readcd';
    with PF, Readcd do
    begin
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteString(Section, 'IsoPath', IsoPath);
      WriteBool(Section, 'Clone', Clone);
      WriteBool(Section, 'Nocorr', Nocorr);
      WriteBool(Section, 'Noerror', Noerror);
      WriteBool(Section, 'Range', Range);
      WriteString(Section, 'Startsec', Startsec);
      WriteString(Section, 'Endsec', Endsec);
      WriteBool(Section, 'DoCopy', DoCopy);
    end;

    {VideoCD}
    Section := 'VideoCD';
    with PF, VideoCD do
    begin
      {allgemeine Einstellungen}
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteString(Section, 'IsoPath', IsoPath);
      WriteString(Section, 'VolID', VolID);
      WriteBool(Section, 'ImageOnly', ImageOnly);
      WriteBool(Section, 'KeepImage', KeepImage);
      WriteBool(Section, 'VCD1', VCD1);
      WriteBool(Section, 'VCD2', VCD2);
      WriteBool(Section, 'SVCD', SVCD);
      WriteBool(Section, 'Overburn', Overburn);
      WriteBool(Section, 'Verbose', Verbose);
      WriteBool(Section, 'Sec2336', Sec2336);
      WriteBool(Section, 'SVCDCompat', SVCDCompat);
    end;

    {DVD-Video}
    Section := 'DVDVideo';
    with PF, DVDVideo do
    begin
      WriteString(Section, 'Device', Device);
      WriteString(Section, 'Speed', Speed);
      WriteString(Section, 'SourcePath', SourcePath);
      WriteString(Section, 'VolID', VolID);
      WriteString(Section, 'IsoPath', IsoPath);
      WriteBool(Section, 'OnTheFly', OnTheFly);
      WriteBool(Section, 'ImageOnly', ImageOnly);
      WriteBool(Section, 'KeepImage', KeepImage);
      WriteBool(Section, 'Verify', Verify);
    end;
    TempList.Free;
  end;

begin
  if Name = cIniFile then
  begin
    {Ini-Datei}
    if General.IniFile = '' then
    begin
      {es gab noch keine Ini, also neue anlegen}
      IniPath := GetIniPath(False);
      (* nicht mehr nötig, da Daten-Verzeichnis beim Start angelegt wird:
      if IniPath <> StartUpDir then
      begin
        IniPath := IniPath + '\cdrtfe';
        if not DirectoryExists(IniPath) then
        begin
          MkDir(IniPath);
        end;
      end; *)
    end else
    begin
      {Pfad der vorhandenen Ini verwenden}
      IniPath := ExtractFilePath(General.IniFile);
    end;
    {Datei speichern}
    PF := TIniFile.Create(IniPath + Name);
    General.IniFile := IniPath + Name;
    {Default-Pfade nicht speichern, also löschen}
    UnsetDefaultPaths;
    SaveSettings;
    {Default-Pfade wiederherstellen}
    SetDefaultPaths;
    PF.Free;
    FileFlags.IniFileOk := True;
  end else
  begin
    {Projekt-Datei speichern}
    PF := TIniFile.Create(Name);
    SaveSettings;
    PF.Free;
  end;
end;

{ LoadFromFile -----------------------------------------------------------------

  LoadFromFile speichert (fast) alle Einstellungen in einer Ini-Datei.         }

procedure TSettings.LoadFromFile(const Name: string);
var PF     : TIniFile; // ProjectFile
    IniPath: string;

  {lokale Prozedur, die die Einstellungen aus der Datei PF liest, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure LoadSettings;
  var Section  : string;
      TempList : TStringList;
      i, j     : Integer;
      c        : Integer;
  begin
    TempList := TStringList.Create;
    {allgemeine Einstellungen/Statusvaraiblen}
    Section := 'General';
    with PF, General do
    begin
      Choice := ReadInteger(Section, 'Choice', cDataCD);
      for i := 1 to TabSheetCount do
      begin
        TabSheetDrive[i] := ReadInteger(Section,
                                        'TabSheetDrive' + IntToStr(i), 0);
        TabSheetSpeed[i] := ReadInteger(Section,
                                        'TabSheetSpeed' + IntToStr(i), -1);
        TabSheetSMType[i] := ReadInteger(Section,
                                         'TabSheetSMType' + IntToStr(i), 0);
      end;
      ImageRead := ReadBool(Section, 'ImageRead', True);
      NoConfirm := ReadBool(Section, 'NoConfirm', False);
      TabFrmSettings := ReadInteger(Section, 'TabFrmSettings', cCdrtfe);
      TabFrmDAE := ReadInteger(Section, 'TabFrmDAE', cTabDAE);
      TabFrmDCDFS := ReadInteger(Section, 'TabFrmDCDFS', cTabFSGen);
      TempFolder := ReadString(Section, 'TempFolder', '');
      AskForTempDir := ReadBool(Section, 'AskForTempDir', False);
      CDTextUseTags := ReadBool(Section, 'CDTextUseTags', True);
      CDTextTP := ReadBool(Section, 'CDTextTP', False);
      DetectSpeeds := ReadBool(Section, 'DetectSpeeds', DetectSpeeds);
      AutoSaveOnExit := ReadBool(Section, 'AutoSaveOnExit', False);
      AllowFileOpen := ReadBool(Section, 'AllowFileOpen', True);
      UseMplayer := ReadBool(Section, 'UseMPlayer', False);
      AllowDblClick := ReadBool(section, 'AllowDblClick', True);
      MPlayerCmd := ReadString(Section, 'MPlayerCmd', '');
      MPlayerOpt := ReadString(Section, 'MPlayerOpt', '');
      FileFlags.MPlayerOk := FileExists(MPlayerCmd);
      FileInfoTitle := ReadBool(Section, 'FileInfoTitle', False);
      SpaceMeter := ReadBool(Section, 'SpaceMeter', True);
      DisableScrSvr := ReadBool(Section, 'DisableScrSvr', False);
      ShowFolderSize := ReadBool(Section, 'ShowFolderSize', False);
    end;
    ProgressBarUpdate(1);

    {Einstellung, die nur in der cdrtfe.ini vorkommen.}
    if Name = cIniFile then
    begin
      Section := 'General';
      with PF, General do
      begin
        {read-only}
        if not PortableMode then
        begin
          PortableMode := ReadBool(Section, 'PortableMode', False);
          {$IFDEF WriteLogFile}
          if PortableMode then AddLogCode(1301);
          {$ENDIF}
        end;
      end;
      {Fensterpositionen}
      Section := 'WinPos';
      with PF, WinPos do
      begin
        MainTop := ReadInteger(Section, 'MainTop', 0);
        MainLeft := ReadInteger(Section, 'MainLeft', 0);
        MainWidth := ReadInteger(Section, 'MainWidth', 0);
        MainHeight := ReadInteger(Section, 'MainHeight', 0);
        MainMaximized := ReadBool(Section, 'MainMaximized', False);
        OutTop := ReadInteger(Section, 'OutTop', 0);
        OutLeft := ReadInteger(Section, 'OutLeft', 0);
        OutWidth := ReadInteger(Section, 'OutWidth', 0);
        OutHeight := ReadInteger(Section, 'OutHeight', 0);
        OutMaximized := ReadBool(Section, 'OutMaximized', False);
        OutScrolled := ReadBool(Section, 'OutScrolled', True);
        for i := 0 to cLVCount do
        begin
          TempList.Clear;
          TempList.CommaText := ReadString(Section, 'LVCols' + IntToStr(i), '');
          for j := 0 to TempList.Count - 1 do
            LVColWidth[i, j] := StrToIntDef(TempList[j], -1); 
        end;
      end;
      Section := 'FileExplorer';
      with PF, FileExplorer do
      begin
        Showing := ReadBool(Section, 'Showing', False);
        Path := ReadString(Section, 'Path', '');
      end;
      {ProDVD-Schlüssel aus cdrtfe.ini lesen, read-only}
       Environment.ProDVDKey := PF.ReadString('ProDVD', cCDRSEC, '');
      {Drive-Settings}
      Section := 'Drives';
      with PF, Drives do
      begin
        UseRSCSI := ReadBool(Section, 'UseRSCSI', False);
        Host := ReadString(Section, 'Host', '');
        RemoteDrives := ReadString(Section, 'RemoteDrives', '');
        if UseRSCSI then RSCSIString := 'REMOTE:' + Host + ':' else
          RSCSIString := '';
        LocalDrives := ReadString(Section, 'LocalDrives', '');
        AssignManually := ReadBool(Section, 'AssignManually', False);
        SCSIInterface := ReadString(Section, 'SCSIInterface', '');
        if not UseRSCSI then SetSCSIInterface(SCSIInterface);
      end;
      {Hacks}
      Section := 'Hacks';
      with PF, Hacks do
      begin
        DisableDVDCheck := ReadBool(Section, 'DisableDVDCheck', False);
      end;
    end;

    {allgemeine Einstellungen: cdrecord}
    Section := 'cdrecord';
    with PF, Cdrecord do
    begin
      Dummy := ReadBool(Section, 'Dummy', False);
      Eject := ReadBool(Section, 'Eject', False);
      Verbose := ReadBool(Section, 'Verbose', False);
      Burnfree := ReadBool(Section, 'Burnfree', False);
      SimulDrv := ReadBool(Section, 'SimulDrv', False);
      FIFO := ReadBool(Section, 'FIFO', False);
      FIFOSize := ReadInteger(Section, 'FIFOSize', 4);
      ForceSpeed := ReadBool(Section, 'ForceSpeed', False);
      AutoErase := ReadBool(Section, 'AutoErase', False);
      AllowFormat := ReadBool(Section, 'AllowFormat', False);
      CdrecordUseCustOpts := ReadBool(Section, 'CdrecordUseCustOpts', False);
      CdrecordCustOptsIndex := ReadInteger(Section,
                                           'CdrecordCustOptsIndex', -1);
      c := ReadInteger(Section, 'CdrecordCustOptsCount', 0);
      CdrecordCustOpts.Clear;
      for i := 0 to c - 1 do
      begin
        CdrecordCustOpts.Add(ReadString(Section,
                                        'CdrecordCustOpts' + IntToStr(i), ''));
      end;
      MkisofsUseCustOpts := ReadBool(Section, 'MkisofsUseCustOpts', False);
      MkisofsCustOptsIndex := ReadInteger(Section,
                                          'MkisofsCustOptsIndex', -1);
      c := ReadInteger(Section, 'MkisofsCustOptsCount', 0);
      MkisofsCustOpts.Clear;
      for i := 0 to c - 1 do
      begin
        MkisofsCustOpts.Add(ReadString(Section,
                                       'MkisofsCustOpts' + IntToStr(i), ''));
      end;
    end;
    ProgressBarUpdate(2);

    {allgemeine Einstellungen: cdrdao}
    Section := 'cdrdao';
    with PF, Cdrdao do
    begin
      ForceGenericMmc := ReadBool(Section, 'ForceGenericMmc', False);
      ForceGenericMmcRaw := ReadBool(Section, 'ForceGenericMmcRaw', False);
      WriteCueImages := ReadBool(Section, 'WriteCueImages', False);
    end;
    ProgressBarUpdate(3);

    {Daten-CD}
    Section := 'Data-CD';
    with PF, DataCD do
    begin
      {allgemeine Einstellungen}
      IsoPath := ReadString(Section, 'IsoPath', '');
      OnTheFly := ReadBool(Section, 'OnTheFly', False) and
                  (FileFlags.ShOk or not FileFlags.ShNeeded);
      ImageOnly := ReadBool(Section, 'ImageOnly', False);
      KeepImage := ReadBool(Section, 'KeepImage', False);
      ContinueCD := ReadBool(Section, 'ContinueCD', False);
      Verify := ReadBool(Section, 'Verify', False);
      {Einstellungen: mkisofs}
      Joliet := ReadBool(Section, 'Joliet', True);
      JolietLong := ReadBool(Section, 'JolietLong', False);
      RockRidge := ReadBool(Section, 'RockRidge', False);
      RationalRock := ReadBool(Section, 'RationalRock', True);
      ISO31Chars := ReadBool(Section, 'ISO31Chars', False);
      ISOLevel := ReadBool(Section, 'ISOLevel', False);
      ISOLevelNr := ReadInteger(Section, 'ISOLevelNr', 0);
      ISOOutChar := ReadInteger(Section, 'ISOOutChar', -1);
      ISOInChar := ReadInteger(Section, 'ISOInChar', -1);
      ISO37Chars := ReadBool(Section, 'ISO37Chars', False);
      ISONoDot := ReadBool(Section, 'ISONoDot', False);
      ISOStartDot := ReadBool(Section, 'ISOStartDot', False);
      ISOMultiDot := ReadBool(Section, 'ISOMultiDot', False);
      ISOASCII := ReadBool(Section, 'ISOASCII', False);
      ISOLower := ReadBool(Section, 'ISOLower', False);
      ISONoTrans := ReadBool(Section, 'ISONoTrans', False);
      ISODeepDir := ReadBool(Section, 'ISODeepDir', False);
      ISONoVer := ReadBool(Section, 'ISONoVer', False);
      UDF := ReadBool(Section, 'UDF', False);
      Boot := ReadBool(Section, 'Boot', False);
      BootImage := ReadString(Section, 'BootImage', '');
      BootCatHide := ReadBool(Section, 'BootCatHide', False);
      BootBinHide := ReadBool(Section, 'BootBinHide', False);
      BootNoEmul := ReadBool(Section, 'BootNoEmul', False);
      BootInfTable := ReadBool(Section, 'BootInfTable', False);
      BootSegAdr := ReadString(Section, 'BootSegAdr', '');
      BootLoadSize := ReadString(Section, 'BootLoadSize', '');
      VolId := ReadString(Section, 'VolId', '');
      FindDups := ReadBool(Section, 'FindDups', False);
      TransTBL := ReadBool(Section, 'TransTBL', False);
      HideTransTBL := ReadBool(Section, 'HideTransTBL', True);
      NLPathTBL := ReadBool(Section, 'NLPathTBL', False);
      HideRRMoved := ReadBool(Section, 'HideRRMoved', False);
      SelectSess := ReadBool(Section, 'SelectSess', False);
      ForceMSRR := ReadBool(Section, 'ForceMSRR', True);
      {Meta-Daten}
      UseMeta := ReadBool(Section, 'UseMeta', False);
      IDPublisher := ReadString(Section, 'Publisher', '');
      IDPreparer := ReadString(Section, 'Preparer', '');
      IDCopyright := ReadString(Section, 'Copyright', '');
      IDSystem := ReadString(Section, 'System', '');
      {Einstellungen: cdrecord}
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      Multi := ReadBool(Section, 'Multi', False);
      DAO := ReadBool(Section, 'DAO', False);
      TAO := ReadBool(Section, 'TAO', True);
      RAW := ReadBool(Section, 'RAW', False);
      RAWMode := ReadString(Section, 'RAWMode', 'raw96r');
      Overburn := ReadBool(Section, 'Overburn', False);
    end;
    ProgressBarUpdate(4);

    {Audio-CD}
    Section := 'Audio-CD';
    with PF, AudioCD do
    begin
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      Multi := ReadBool(Section, 'Multi', False);
      Fix := ReadBool(Section, 'Fix', True);
      DAO := ReadBool(Section, 'DAO', False);
      TAO := ReadBool(Section, 'TAO', True);
      RAW := ReadBool(Section, 'RAW', False);
      RAWMode := ReadString(Section, 'RAWMode', 'raw96r');
      Overburn := ReadBool(Section, 'Overburn', False);
      Preemp := ReadBool(Section, 'Preemp', False);
      Copy := ReadBool(Section, 'Copy', False);
      SCMS := ReadBool(Section, 'SCMS', False);
      UseInfo := ReadBool(Section, 'UseInfo', False);
      CDText := ReadBool(Section, 'CDText', False);
      Pause := ReadInteger(Section, 'Pause', 1);
      PauseLength := ReadString(Section, 'PauseLength', '2');
      PauseSector := ReadBool(Section, 'PauseSector', False);
      UTFToAnsi := ReadBool(Section, 'UTFToAnsi', False);
      ReplayGain := ReadBool(Section, 'ReplayGain', False) and
                    FileFlags.WavegainOk;
      Gain       := ReadString(Section, 'Gain', '');
    end;
    ProgressBarUpdate(5);

    {XCD}
    Section := 'XCD';
    with PF, XCD do
    begin
      {allgemeine Einstellungen}
      IsoPath := ReadString(Section, 'IsoPath', '');
      ImageOnly := ReadBool(Section, 'ImageOnly', False);
      KeepImage := ReadBool(Section, 'KeepImage', False);
      Verify := ReadBool(Section, 'Verify', False);
      CreateInfoFile := ReadBool(Section, 'CreateInfoFile', True);
      {Einstellungen: modecdmaker}
      VOlID := ReadString(Section, 'VolID', '');
      Ext := ReadString(Section, 'Ext', '');
      IsoLevel1 := ReadBool(Section, 'IsoLevel1', False);
      IsoLevel2 := ReadBool(Section, 'IsoLevel2', False);
      KeepExt := ReadBool(Section, 'KeepExt', True);
      Single := ReadBool(Section, 'Single', False);
      {Einstellungen: cdrdao}
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      Overburn := ReadBool(Section, 'OverBurn', False);
      {Einstellungen: rrenc}
      UseErrorProtection := ReadBool(Section, 'UseErrorProtection', False);
      SecCount := ReadInteger(Section, 'SecCount', 3600);
    end;
    ProgressBarUpdate(6);

    {CDRW}
    Section := 'CDRW';
    with PF, CDRW do
    begin
      Device := ReadString(Section, 'Device', '');
      Fast := ReadBool(Section, 'Fast', True);
      All := ReadBool(Section, 'All', False);
      OpenSession := ReadBool(Section, 'OpenSession', False);
      BlankSession :=ReadBool(Section, 'BlankSession', False);
      Force := ReadBool(Section, 'Force', False);
    end;
    ProgressBarUpdate(7);

    {CDInfo}
    Section := 'CDInfo';
    with PF, CDInfo do
    begin
      Device := ReadString(Section, 'Device', '');
      Scanbus := ReadBool(Section, 'Scanbus', True);
      Prcap := ReadBool(Section, 'Prcap', False);
      Toc := ReadBool(Section, 'Toc', False);
      Atip := ReadBool(Section, 'Atip', False);
      MSInfo := ReadBool(Section, 'MSInfo', False);
      MInfo := ReadBool(Section, 'MInfo', False);
      CapInfo := ReadBool(Section, 'CapInfo', False);
    end;
    ProgressBarUpdate(8);

    {DAE}
    Section := 'DAE';
    with PF, DAE do
    begin
      Action := ReadInteger(Section, 'Action', 0);
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      SpeedW := ReadString(Section, 'SpeedW', '');
      Bulk := ReadBool(Section, 'Bulk', True);
      Paranoia := ReadBool(Section, 'Paranoia', False);
      NoInfoFile := ReadBool(Section, 'NoInfoFile', True);
      Path := ReadString(Section, 'Path', '');
      PrefixNames := ReadBool(Section, 'PrefixNames', True);
      Prefix := ReadString(Section, 'Prefix', 'track');
      NamePattern := ReadString(Section, 'NamePattern', '');
      Tracks := ReadString(Section, 'Tracks', '');
      Offset := ReadString(Section, 'Offset', '');
      UseCDDB := ReadBool(Section, 'UseCDDB', False);
      CDDBServer := ReadString(Section, 'CDDBServer', '');
      CDDBPort := ReadString(Section, 'CDDBPort', '');
      MP3 := ReadBool(Section, 'MP3', False) and FileFlags.LameOk and
             (FileFlags.ShOk or not FileFlags.ShNeeded);
      Ogg := ReadBool(Section, 'Ogg', False) and FileFlags.OggencOk and
             (FileFlags.ShOk or not FileFlags.ShNeeded);
      FLAC := ReadBool(Section, 'FLAC', False) and FileFlags.FlacOk and
              (FileFlags.ShOk or not FileFlags.ShNeeded);
      Custom := ReadBool(Section, 'Custom', False);
      AddTags := ReadBool(Section, 'AddTags', True);
      FlacQuality := ReadString(Section, 'FlacQuality', '5');
      OggQuality := ReadString(Section, 'OggQuality', '6');
      LamePreset := ReadString(Section, 'LamePreset', 'standard');
      CustomCmd := ReadString(Section, 'CustomCmd', '');
      CustomOpt := ReadString(Section, 'CustomOpt', '');
      DoCopy := ReadBool(Section, 'DoCopy', False);
    end;
    ProgressBarUpdate(9);

    {Image schreiben}
    Section := 'Image';
    with PF, Image do
    begin
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      IsoPath := ReadString(Section, 'IsoPath', '');
      Overburn := ReadBool(Section, 'Overburn', False);
      DAO := ReadBool(Section, 'DAO', False);
      TAO := ReadBool(Section, 'TAO', True);
      Clone := ReadBool(Section, 'Clone', Clone);
      RAW := ReadBool(Section, 'RAW', False);
      RAWMode := ReadString(Section, 'RAWMode', 'raw96r');
      CDText := ReadBool(Section, 'CDText', False);
    end;
    ProgressBarUpdate(10);

    {Image einlesen}
    Section := 'Readcd';
    with PF, Readcd do
    begin
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      IsoPath := ReadString(Section, 'IsoPath', '');
      Clone := ReadBool(Section, 'Clone', False);
      Nocorr := ReadBool(Section, 'Nocorr', False);
      Noerror := ReadBool(Section, 'Noerror', False);
      Range := ReadBool(Section, 'Range', False);
      StartSec := ReadString(Section, 'Startsec', '');
      EndSec := ReadString(Section, 'Endsec', '');
      DoCopy := ReadBool(Section, 'DoCopy', False);
    end;
    ProgressBarUpdate(11);

    {VideoCD}
    Section := 'VideoCD';
    with PF, VideoCD do
    begin
      {allgemeine Einstellungen}
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      IsoPath := ReadString(Section, 'IsoPath', '');
      VolID := ReadString(Section, 'VolID', '');
      ImageOnly := ReadBool(Section, 'ImageOnly', False);
      KeepImage := ReadBool(Section, 'KeepImage', False);
      VCD1 := ReadBool(Section, 'VCD1', False);
      VCD2 := ReadBool(Section, 'VCD2', True);
      SVCD := ReadBool(Section, 'SVCD', False);
      Overburn := ReadBool(Section, 'Overburn', False);
      Verbose := ReadBool(Section, 'Verbose', True);
      Sec2336 := ReadBool(Section, 'Sec2336', False);
      SVCDCompat := ReadBool(Section, 'SVCDCompat', False);
    end;
    ProgressBarUpdate(12);

    {DVD-Video}
    Section := 'DVDVideo';
    with PF, DVDVideo do
    begin
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      SourcePath := ReadString(Section, 'SourcePath', '');
      VolID := ReadString(Section, 'VolID', '');
      IsoPath := ReadString(Section, 'IsoPath', '');
      OnTheFly := ReadBool(Section, 'OnTheFly', True) and
                  (FileFlags.ShOk or not FileFlags.ShNeeded);
      ImageOnly := ReadBool(Section, 'ImageOnly', False);
      KeepImage := ReadBool(Section, 'KeepImage', False);
      Verify := ReadBool(Section, 'Verify', False);
    end;
    ProgressBarUpdate(13);
    TempList.Free;
  end;

begin
  if Name = cIniFile then
  begin
    {Einstellungen aus Ini laden}
    IniPath := GetIniPath(True);
    if IniPath <> '' then
    begin
      PF := TIniFile.Create(IniPath);
      LoadSettings;
      PF.Free;
      General.IniFile := IniPath;
    end else
    begin
      FileFlags.IniFileOk := False;
    end;
    {Vorbelegungen für Pfade zum Image und temporären Ordner}
    SetDefaultPaths;
  end else
  begin
    {Einstellungen aus einer Projekt-Datei laden}
    PF := TIniFile.Create(Name);
    {Namen merken für Log-File}
    General.LastProject := Name;
    {Event zum Aktualisieren der Panels auslösen}
    UpdatePanels(Format(FLang.GMS('mpref07'), [Name]), FLang.GMS('mpref08'));
    {Reset der Progress-Bars}
    ProgressBarShow(13);
    {Einstellungen laden}
    LoadSettings;
    ProgressBarHide;
    PF.Free;
  end;
end;

{ DeleteIniFile ----------------------------------------------------------------

  DeleteIniFile löscht die Ini-Datei mit den gespeicherten Einstellungen.      }

procedure TSettings.DeleteIniFile;
begin
  DeleteFile(General.IniFile);
end;

end.
