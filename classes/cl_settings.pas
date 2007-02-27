{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings.pas: Einstellungen von cdrtfe

  Copyright (c) 2004-2007 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  13.02.2007

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
                 DeleteFromRegistry
                 DeleteIniFile
                 GetMaxFileNameLength: Byte
                 LoadFromFile(const Name: string)
                 LoadFromRegistry
                 SaveToFile(const Name: string)
                 SaveToRegistry

}

unit cl_settings;

{$I directives.inc}

interface

uses {$IFDEF Delphi2005Up} Windows, {$ENDIF}
     Classes, SysUtils, IniFiles, Registry, FileCtrl,
     cl_lang, userevents;

const TabSheetCount = 9;

type { GUI-Settings, Flags und Hilfsvariablen }
     TGeneralSettings = record
       Choice        : Byte;
       ImageRead     : Boolean;
       TabSheetDrive : array [1..TabSheetCount] of Byte;
       TabSheetSpeed : array [1..TabSheetCount] of Integer;
       CharSets      : TStringList;
       Mp3Qualities  : TStringList;
       XCDAddMovie   : Boolean;
       TempBoot      : Boolean;
       NoConfirm     : Boolean;
       TabFrmSettings: Byte;
       TabFrmDAE     : Byte;
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
       CdrdaoOk   : Boolean;
       Cdda2wavOk : Boolean;
       ReadcdOk   : Boolean;
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
       RrencOk    : Boolean;
       RrdecOk    : Boolean;
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
     end;

     { Einstellungen: cdrecord/mkisofs allgemein}
     TSettingsCdrecord = record
       FixDevice : string;  // Laufwerk zum fixieren, nur temporär
       Dummy     : Boolean; // gilt auch für cdrdao
       Eject     : Boolean;
       Verbose   : Boolean;
       Burnfree  : Boolean;
       SimulDrv  : Boolean;
       FIFO      : Boolean;
       FIFOSize  : Integer;
       ForceSpeed: Boolean;
       AutoErase : Boolean;
       Erase     : Boolean;
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
       VolId       : string;
       MsInfo      : string;
       FindDups    : Boolean;
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
       Bulk       : Boolean;
       Paranoia   : Boolean;
       NoInfoFile : Boolean;
       Path       : string;
       PrefixNames: Boolean;
       Prefix     : string;
       NamePattern: string;
       Tracks     : string;
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
       {$IFDEF RegistrySettings}
       function SettingsAvailable: Boolean;
       {$ENDIF}
       {$IFDEF IniSettings}
       function GetIniPath(Load: Boolean): string;
       {$ENDIF}
       procedure InitSettings;
       {Events}
       procedure ProgressBarHide;
       procedure ProgressBarShow(const Max: Integer);
       procedure ProgressBarUpdate(const Position: Integer);
       procedure UpdatePanels(const s1, s2: string);
     public
       General     : TGeneralSettings;
       WinPos      : TWinPos;
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
       {$IFDEF RegistrySettings}
       procedure DeleteFromRegistry;
       procedure LoadFromRegistry;
       procedure SaveToRegistry;
       {$ENDIF}
       {$IFDEF IniSettings}
       procedure DeleteIniFile;
       {$ENDIF}
       {$IFDEF DebugSettings}
       procedure ShowSettings;
       {$ENDIF}
       property Lang: TLang write FLang;
       {Events}
       property OnProgressBarHide: TProgressBarHideEvent read FOnProgressBarHide write FOnProgressBarHide;
       property OnProgressBarShow: TProgressBarShowEvent read FOnProgressBarShow write FOnProgressBarShow;
       property OnProgressBarUpdate: TProgressBarUpdateEvent read FOnProgressBarUpdate write FOnProgressBarUpdate;
       property OnUpdatePanels: TUpdatePanelsEvent read FOnUpdatePanels write FOnUpdatePanels;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     constant, f_filesystem, f_wininfo;

{ TSettings ------------------------------------------------------------------ }

{ TSettings - private }

{ ProgressBarHide --------------------------------------------------------------

  Löst das Event OnProgressBarHide aus, daß den Progress-Bar des Hauptfensters
  unsichtbar macht.                                                            }

procedure TSettings.ProgressBarHide;
begin
  if Assigned(FOnProgressBarHide) then FOnProgressBarHide;
end;

{ ProgressBarShow --------------------------------------------------------------

  Löst das Event OnProgressBarReset aus, daß den Progress-Bar des Hauptfensters
  sichtbar macht und zurücksetzt.                                              }

procedure TSettings.ProgressBarShow(const Max: Integer);
begin
  if Assigned(FOnProgressBarShow) then FOnProgressBarShow(Max);
end;

{ ProgressBarUpdate ------------------------------------------------------------

  Löst das Event OnProgressBarUpdate aus, daß den Progress-Bar des Hauptfensters
  aktualisiert.                                                                }

procedure TSettings.ProgressBarUpdate(const Position: Integer);
begin
  if Assigned(FOnProgressBarUpdate) then FOnProgressBarUpdate(Position);
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
var i: Integer;
begin
  {allgemeine Einstellungen/Statusvaraiblen}
  with General do
  begin
    CharSets.CommaText := ',cp437,cp737,cp775,cp850,cp852,cp855,cp857,' +
                          'cp860,cp861,cp862,cp863,cp864,cp865,cp866,' +
                          'cp869,cp874,cp1250,cp1251,cp10081,cp10079,' +
                          'cp10029,cp10007,cp10006,cp10000,iso8859-1,' +
                          'iso8859-2,iso8859-3,iso8859-4,iso8859-5,'   +
                          'iso8859-6,iso8859-7,iso8859-8,iso8859-9,'   +
                          'iso8859-14,iso8859-15,koi8-u,koi8-r';
    Mp3Qualities.CommaText := 'medium,standard,extreme,insane,' +
                              '320,256,224,192,160,128,112,96,80';
    General.Choice := 0;
    XCDAddMovie := False;
    TempBoot := False;
    {aktuelles Laufwerk für jedes TabSheet}
    for i := 1 to TabSheetCount do
    begin
      TabSheetDrive[i] := 0;
      TabSheetSpeed[i] := -1;
    end;
    ImageRead := True;
    NoConfirm := False;
    TabFrmSettings := cCdrtfe;
    TabFrmDAE      := cTabDAE;
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
    CdrdaoOk    := True;
    Cdda2wavOk  := True;
    ReadcdOk    := True;
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
    RrencOk     := True;
    RrdecOk     := True;
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
    UseRSCSI     := False;
    Host         := '';
    RemoteDrives := '';
    RSCSIString  := '';
    LocalDrives  := '';
  end;                        

  {allgemeine Einstellungen: cdrecord}
  with Cdrecord do
  begin
    FixDevice  := '';
    Dummy      := False;
    Eject      := False;
    Verbose    := False;
    Burnfree   := True;
    SimulDrv   := False;
    FIFO       := False;
    FIFOSize   := 4;
    ForceSpeed := False;
    AutoErase  := False;
    Erase      := False;
    CdrecordUseCustOpts   := False;
    MkisofsUseCustOpts    := False;
    CdrecordCustOptsIndex := -1;
    MkisofsCustOptsIndex  := -1;
    CanWriteCueImage    := False;  
    WritingModeRequired := False;
    DMASpeedCheck       := False;
    HaveMediaInfo       := False;
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
    VolId        := '';
    MsInfo       := '';
    FindDups     := False;
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
    Bulk        := True;
    Paranoia    := False;
    NoInfoFile  := True;
    Path        := '';
    PrefixNames := True;
    Prefix      := 'track';
    NamePattern := '%N %P - %T';
    Tracks      := '';
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

{ SettingsAvailable ------------------------------------------------------------

  SettingsAvailable prüft, ob in der Registry Einstellungen vorhanden sind.    }

{$IFDEF RegistrySettings}
function TSettings.SettingsAvailable: Boolean;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    {$IFDEF UseRegistryKeyExists}
    Result := Reg.KeyExists('\Software\cdrtfe');
    {$ELSE}
    if Reg.OpenKey('\Software\cdrtfe\General', True) then
    begin
      Result := Reg.ValueExists('Choice');
      if not Result then
      begin
        Reg.DeleteKey('\Software\cdrtfe');
      end;
    end else
    begin
      Result := False;
    end;
    {$ENDIF}
  finally
    Reg.Free;
  end;
end;
{$ENDIF}

{ GetIniPath -------------------------------------------------------------------

  GetIniPath ermittelt den Pfad zur Ini-Datei. Wenn cdrtfe unter NT ausgeführt
  wird, werden nacheinander die Verzeichnisse CSIDL_LOCAL_APPDATA, _APPDATA und
  _COMMON_APPDATA getestet. Das erste Verzeichnis, das existiert, wird für die
  Ini-Datei verwendet.
  Unter Win9x wird die Ini-Datei im Programmverzeichnis von cdrtfe gespeichert.}

{$IFDEF IniSettings}
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
end;
{$ENDIF}

{ SetDefaultPath ---------------------------------------------------------------

  SetDefaultPaths setzt die Standardwerte für die Pfade zur Image-Datei und zum
  temporären Ordner.}

procedure TSettings.SetDefaultPaths;
var DefaultDir      : string;
    DefaultImageName: string;
    DefaultImageFile: string;
begin
  DefaultDir       := f_filesystem.TempDir;
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
end;

{ UnsetDefaultPaths ------------------------------------------------------------

  UnsetDefaultPaths löscht die Pfadangaben für Image-Datei und temporären
  Ordner.                                                                      }

procedure TSettings.UnsetDefaultPaths;
var DefaultDir      : string;
    DefaultImageName: string;
    DefaultImageFile: string;
begin
  DefaultDir       := f_filesystem.TempDir;
  DefaultImageName := DefaultDir + cDefaultIsoName;
  DefaultImageFile := DefaultImageName + cExtIso;
  if DataCD.IsoPath     = DefaultImageFile then DataCD.IsoPath     := '';
  if XCD.IsoPath        = DefaultImageName then XCD.IsoPath        := '';
  if VideoCD.IsoPath    = DefaultImageName then VideoCD.IsoPath    := '';
  if DVDVideo.IsoPath   = DefaultImageFile then DVDVideo.IsoPath   := '';
  if General.TempFolder = DefaultDir       then General.TempFolder := '';
end;

{ TSettings - public }

constructor TSettings.Create;
begin
  inherited Create;
  General.Charsets := TStringList.Create;
  General.Mp3Qualities := TStringList.Create;
  Cdrecord.CdrecordCustOpts := TStringList.Create;
  Cdrecord.MkisofsCustOpts  := TStringList.Create;
(*  Devices.CDWriter  := TStringList.Create;
  Devices.CDReader  := TStringList.Create;
  Devices.CDDevices := TStringList.Create; *)
  InitSettings;
end;

destructor TSettings.Destroy;
begin
  General.CharSets.Free;
  General.Mp3Qualities.Free;
  Cdrecord.CdrecordCustOpts.Free;
  Cdrecord.MkisofsCustOpts.Free;
//  Devices.CDWriter.Free;
//  Devices.CDReader.Free;
//  Devices.CDDevices.Free;
  inherited Destroy;
end;

{ ShowSettings -----------------------------------------------------------------

  zeigt alle internen Einstellungen an. Nur für Debugging.                     }

{$IFDEF DebugSettings}
procedure TSettings.ShowSettings;
var Temp: string;
    i: Integer;
begin
  FormDebug.Memo1.Lines.Clear;
  FormDebug.Memo2.Lines.Clear;
  FormDebug.Memo3.Lines.Clear;
  with General, FormDebug.Memo3.Lines do
  begin
    Add('TSettings.General:');
    Add('  Choice       : ' + IntToStr(Choice));
    if ImageRead then Add('  ImageRead    : True') else Add('  ImageRead    : False');
    if XCDAddMovie then Add('  XCDAddMovie  : True') else Add('  XCDAddMovie  : False');
    // if CdrdaoFilesOk then Add('  CdrdaoFilesOk: True') else Add('  CdrdaoFilesOk: False');
    if NoConfirm then Add('  NoConfirm    : True') else Add('  NoConfirm    : False');
    Temp := '';
    for i := 1 to TabSheetCount do
    begin
      Temp := Temp + IntToStr(TabSheetDrive[i]) + ' ';
    end;
    Add('  TabSheetDrive: ' + Temp);
    Temp := '';
    for i := 1 to TabSheetCount do
    begin
      Temp := Temp + IntToStr(TabSheetSpeed[i]) + ' ';
    end;
    Add('  TabSheetSpeed: ' + Temp);
    Add('  TabFrmSet.   : ' + IntToStr(TabFrmSettings));
    Add('');
  end;

  with Cdrecord, FormDebug.Memo2.Lines do
  begin
    Add('TSettings.Cdrecord:');
    if Dummy then Add('  Dummy     : True') else Add('  Dummy     : False');
    if Verbose then Add('  Verbose   : True') else Add('  Verbose   : False');
    if Burnfree then Add('  Burnfree  : True') else Add('  Burnfree  : False');
    if SimulDrv then Add('  SimulDrv  : True') else Add('  SimulDrv  : False');
    if FIFO then Add('  FIFO      : True') else Add('  FIFO      : False');
    Add('  Fifo-Size : ' + IntToStr(FIFOSize));
    if ForceSpeed then Add('  Forcespeed: True') else Add('  ForceSpeed: False');
    if CdrecordUseCustOpts then Add('  CdrecordCO: True') else Add('  CdrecordCO: False');
    if MkisofsUseCustOpts then Add('  MkisofsCO : True') else Add('  MkisofsCO : False');
    Add('  CdrCOIndex: ' + IntToStr(CdrecordCustOptsIndex));
    Add('  MkiCOIndex: ' + IntToStr(MkisofsCustOptsIndex));
    Add('');
  end;

  with Cdrdao, FormDebug.Memo2.Lines do
  begin
    Add('TSettings.Cdrdao:');
    if ForceGenericMmc then Add('  ForceGenericMMC   : True') else Add('  ForceGenericMMC   : False');
    if ForceGenericMmcRaw then Add('  ForceGenericMMCRAW: True') else Add('  ForceGenericMMCRAW: False');
    if WriteCueImages then Add('  WriteCueImages    : True') else Add('  WriteCueImages    : False');
    Add('');
  end;

  with DataCD, FormDebug.Memo1.Lines do
  begin
    Add('TSettings.DataCD:');
    {allgemeine Einstellungen}
    Add('  IsoPath    : ' + IsoPath);
    if OnTheFly then Add('  OnTheFly   : True') else Add('  OnTheFly   : False');
    if ImageOnly then Add('  ImageOnly  : True') else Add('  ImageOnly  : False');
    if KeepImage then Add('  KeepImage  : True') else Add('  KeepImage  : False');
    if ContinueCD then Add('  ContinueCD : True') else Add('  ContinueCD : False');
    if Verify then Add('  Verify     : True') else Add('  Verify     : False');
    {Einstellungen: mkisofs}
    if Joliet then Add('  Joliet     : True') else Add('  Joliet     : False');
    if JolietLong then Add('  JolietLong : True') else Add('  JolietLong : False');
    if RockRidge then Add('  RockRidge  : True') else Add('  RockRidge  : False');
    if ISO31Chars then Add('  ISO31Chars : True') else Add('  ISO31Chars : False');
    if ISOLEvel then Add('  ISOLevel   : True') else Add('  ISOLevel   : False');
    Add('  ISOLevelNr : ' + IntToStr(ISOLevelNr));
    Add('  ISOOutChar : ' + IntToStr(ISOOutChar));
    if ISO37Chars then Add('  ISO37Chars : True') else Add('  ISO37Chars : False');
    if ISONoDot then Add('  ISONoDot   : True') else Add('  ISONoDot   : False');
    if ISOStartDot then Add('  ISOStartDot: True') else Add('  ISOStartDot: False');
    if ISOMultiDot then Add('  ISOMultiDot: True') else Add('  ISOMultiDot: False');
    if ISOASCII then Add('  ISOASCII   : True') else Add('  ISOASCII   : False');
    if ISOLower then Add('  ISOLower   : True') else Add('  ISOLower   : False');
    if ISONoTrans then Add('  ISONoTrans : True') else Add('  ISONoTrans : False');
    if ISODeepDir then Add('  ISODeepDir : True') else Add('  ISODeepDir : False');
    if ISONoVer then Add('  ISONoVer   : True') else Add('  ISONoVer   : False');
    if UDF then Add('  UDF        : True') else Add('  UDF        : False');
    if Boot then Add('  Boot       : True') else Add('  Boot       : False');
    Add('  BootImage  : ' + BootImage);
    if BootCatHide then Add('  BootCatHide: True') else Add('  BootCatHide: False');
    if BootBinHide then Add('  BootBinHide: True') else Add('  BootBinHide: False');
    if BootNoEmul then Add('  BootNoEmul : True') else Add('  BootNoEmul : False');
    Add('  VolId      : ' + VolId);
    Add('  MsInfo     : ' + MsInfo);
    {Einstellungen: cdrecord}
    Add('  Device     : ' + Device);
    Add('  Speed      : ' + Speed);
    if Multi then Add('  Multi      : True') else Add('  Multi      : False');
    if DAO then Add('  DAO        : True') else Add('  DAO        : False');
    if TAO then Add('  TAO        : True') else Add('  TAO        : False');
    if RAW then Add('  RAW        : True') else Add('  RAW        : False');
    Add('  RAWMode    : ' + RAWMode);
    if Overburn then Add('  Overburn   : True') else Add('  Overburn   : False');
  end;

  with AudioCD, FormDebug.Memo3.Lines do
  begin
    Add('TSettings.AudioCD:');
    Add('  Device     : ' + Device);
    Add('  Speed      : ' + Speed);
    if Multi then Add('  Multi      : True') else Add('  Multi      : False');
    if Fix then Add('  Fix        : True') else Add ('  Fix        : False');
    if DAO then Add('  DAO        : True') else Add('  DAO        : False');
    if TAO then Add('  TAO        : True') else Add('  TAO        : False');
    if RAW then Add('  RAW        : True') else Add('  RAW        : False');
    Add('  RAWMode    : ' + RAWMode);
    if Overburn then Add('  Overburn   : True') else Add('  Overburn   : False');
    if Preemp then Add('  Preemp     : True') else Add('  Preemp     : False');
    if Copy then Add('  Copy       : True') else Add('  Copy       : False');
    if SCMS then Add('  SCMS       : True') else Add('  SCMS       : False');
    if UseInfo then Add('  UseInfo    : True') else Add('  UseInfo    : False');
    if CDText then Add('  CDText     : True') else Add('  CDText     : False');
    Add('  Pause      : ' + Pause);
    Add('  Pausenlänge: ' + PauseLength);
    if PauseSector then Add('  Pause      : Sektoren') else
                        Add('  Pause      : Sekunden'); end;
    Add('');
  end;

  with XCD, FormDebug.Memo2.Lines do
  begin
    Add('TSettings.XCD:');
    {allgemeine Einstellungen}
    Add('  IsoPath    : ' + IsoPath);
    if ImageOnly then Add('  ImageOnly  : True') else Add('  ImageOnly  : False');
    if KeepImage then Add('  KeepImage  : True') else Add('  KeepImage  : False');
    {Einstellungen: modecdmaker}
    Add('  VolID      : ' + VolID);
    Add('  Ext        : ' + Ext);
    if IsoLevel1 then Add('  IsoLevel1  : True') else Add('  IsoLevel1  : False');
    if IsoLevel2 then Add('  IsoLevel2  : True') else Add('  IsoLevel2  : False');
    if KeepExt then Add('  KeepExt    : True') else Add('  KeepExt    : False');
    if Single then Add('  Single     : True') else Add('  Single     : False');
    {Einstellungen: cdrdao}
    Add('  Device     : ' + Device);
    Add('  Speed      : ' + Speed);
    if Dummy then Add('  Dummy      : True') else Add('  Dummy      : False');
    if Overburn then Add('  Overburn   : True') else Add('  Overburn   : False');
    Add('');
  end;

  with CDRW, FormDebug.Memo3.Lines do
  begin
    Add('TSettings.CDRW:');
    if All then Add('  All          : True') else Add('  All          : False');
    if Fast then Add('  Fast         : True') else Add('  Fast         : False');
    if OpenSession then Add('  OpenSession  : True') else Add('  OpenSession  : False');
    if BlankSession then Add('  BlankSession : True') else Add('  BlankSession : False');
    if Force then Add('  Force        : True') else Add('  Force        : False');
    Add('  Device       : ' + Device);
    Add('');
  end;

  with CDInfo, FormDebug.Memo3.Lines do
  begin
    Add('TSettings.CDInfos:');
    if Scanbus then Add('  Scanbus      : True') else Add('  Scanbus      : False');
    if Prcap then Add('  Prcap        : True') else Add('  Prcap        : False');
    if Toc then Add('  Toc          : True') else Add('  Toc          : False');
    if Atip then Add('  Atip         : True') else Add('  Atip         : False');
    if MSInfo then Add('  MSInfo       : True') else Add('  MSInfo       : False');
    if CapInfo then Add('  Capacity     : True') else Add('  Capacity     : False');
    Add('  Device       : ' + Device);
    Add('');
  end;

  with DAE, FormDebug.Memo3.Lines do
  begin
    Add('TSettings.DAE:');
    Add('  Action     : ' + IntToStr(Action));
    Add('  Device     : ' + Device);
    Add('  Speed      : ' + Speed);
    if Bulk then Add('  Bulk       : True') else Add('  Bulk       : False');
    if Paranoia then Add('  Paranoia   : True') else Add('  Paranoia   : False');
    if NoINfoFile then Add('  NoInfoFile : True') else Add('  NoInfoFile : False');
    Add('  Path       : ' + Path);
    Add('  Prefix     : ' + Prefix);
    Add('  Tracks     : ' + Tracks)
  end;

  with Image, FormDebug.Memo2.Lines do
  begin
    Add('TSettings.Image:');
    Add('  Device     : ' + Device);
    Add('  Speed      : ' + Speed);
    Add('  IsoPath    : ' + IsoPath);
    if Overburn then Add('  Overburn   : True') else Add('  Overburn   : False');
    if DAO then Add('  DAO        : True') else Add('  DAO        : False');
    if TAO then Add('  TAO        : True') else Add('  TAO        : False');    
    if Clone then Add('  Clone      : True') else Add('  Clone      : False');
    if RAW then Add('  RAW        : True') else Add('  RAW        : False');
    Add('  RAWMode    : ' + RAWMode);
    Add('');
  end;

  with Readcd, FormDebug.Memo2.Lines do
  begin
    Add('TSettings.Readcd:');
    Add('  Device     : ' + Device);
    Add('  Speed      : ' + Speed);
    Add('  IsoPath    : ' + IsoPath);
    if Clone then Add('  Clone      : True') else Add('  Clone      : False');
    if Nocorr then Add('  Nocorr     : True') else Add('  Nocorr     : False');
    if Noerror then Add('  Noerror    : True') else Add('  NoError    : False');
    if Range then Add('  Range      : True') else Add('  Range      : False');
    Add('  Startsec   : ' + Startsec);
    Add('  Endsec     : ' + Endsec);
  end;

end;
{$ENDIF}

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
var PF: TIniFile; // ProjectFile
    {$IFDEF IniSettings}
    IniPath: string;
    {$ENDIF}

  {lokale Prozedur, die die Einstellungen in die Datei PF schreibt, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure SaveSettings;
  var Section: string;
      i: Integer;
  begin
    {allgemeine Einstellungen/Statusvaraiblen}
    Section := 'General';
    with PF, General do
    begin
      WriteInteger(Section, 'Choice', Choice);
      for i := 1 to TabSheetCount do
      begin
        WriteInteger(Section, 'TabSheetDrive' + IntToStr(i), TabSheetDrive[i]);
        WriteInteger(Section, 'TabSheetSpeed' + IntToStr(i), TabSheetSpeed[i]);
      end;
      WriteBool(Section, 'ImageRead', ImageRead);
      WriteBool(Section, 'NoConfirm', NoConfirm);
      WriteInteger(Section, 'TabFrmSettings', TabFrmSettings);
      WriteInteger(Section, 'TabFrmDAE', TabFrmDAE);
      WriteString(Section, 'TempFolder', TempFolder);
      WriteBool(Section, 'AskForTempDir', AskForTempDir);
      WriteBool(Section, 'CDTextUseTags', CDTextUseTags);
      WriteBool(Section, 'CDTextTP', CDTextTP);
      WriteBool(Section, 'DetectSpeeds', DetectSpeeds);
    end;

    {Die Fensterpositionen und Drive-Settings sollen nicht in 'normalen'
     Projekt-Dateien gesichert werden.}
    {$IFDEF IniSettings}
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
      end;

      Section := 'Drives';
      with PF, Drives do
      begin
        WriteBool(Section, 'UseRSCSI', UseRSCSI);
        WriteString(Section, 'Host', Host);
        WriteString(Section, 'RemoteDrives', RemoteDrives);
        WriteString(Section, 'LocalDrives', LocalDrives);
      end;
    end;
    {$ENDIF}

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
      WriteString(Section, 'VolId', VolId);
      WriteBool(Section, 'FindDups', FindDups);
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
      WriteBool(Section, 'Bulk', Bulk);
      WriteBool(Section, 'Paranoia', Paranoia);
      WriteBool(Section, 'NoInfoFile', NoInfoFile);
      WriteString(Section, 'Path', Path);
      WriteBool(Section, 'PrefixNames', PrefixNames);
      WriteString(Section, 'Prefix', Prefix);
      WriteString(Section, 'NamePattern', NamePattern);
      WriteString(Section, 'Tracks', Tracks);
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
  end;

begin
  {$IFDEF IniSettings}
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
  {$ENDIF}
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
var PF: TIniFile; // ProjectFile
    {$IFDEF IniSettings}
    IniPath: string;
    {$ENDIF}

  {lokale Prozedur, die die Einstellungen aus der Datei PF liest, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure LoadSettings;
  var Section  : string;
      i        : Integer;
      c        : Integer;
  begin
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
      end;
      ImageRead := ReadBool(Section, 'ImageRead', True);
      NoConfirm := ReadBool(Section, 'NoConfirm', False);
      TabFrmSettings := ReadInteger(Section, 'TabFrmSettings', cCdrtfe);
      TabFrmDAE := ReadInteger(Section, 'TabFrmDAE', cTabDAE);
      TempFolder := ReadString(Section, 'TempFolder', '');
      AskForTempDir := ReadBool(Section, 'AskForTempDir', False);
      CDTextUseTags := ReadBool(Section, 'CDTextUseTags', True);
      CDTextTP := ReadBool(Section, 'CDTextTP', False);
      DetectSpeeds := ReadBool(Section, 'DetectSpeeds', DetectSpeeds);
    end;
    ProgressBarUpdate(1);

    {Einstellung, die nur in der cdrtfe.ini vorkommen.}
    {$IFDEF IniSettings}
    if Name = cIniFile then
    begin
      Section := 'General';
      with PF, General do
      begin
        {read-only}
        if not PortableMode then
          PortableMode := ReadBool(Section, 'PortableMode', False);      
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
      end;
      {Hacks}
      Section := 'Hacks';
      with PF, Hacks do
      begin
        DisableDVDCheck := ReadBool(Section, 'DisableDVDCheck', False);
      end;
    end;
    {$ENDIF}

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
      VolId := ReadString(Section, 'VolId', '');
      FindDups := ReadBool(Section, 'FindDups', False);
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
      Bulk := ReadBool(Section, 'Bulk', True);
      Paranoia := ReadBool(Section, 'Paranoia', False);
      NoInfoFile := ReadBool(Section, 'NoInfoFile', True);
      Path := ReadString(Section, 'Path', '');
      PrefixNames := ReadBool(Section, 'PrefixNames', True);
      Prefix := ReadString(Section, 'Prefix', 'track');
      NamePattern := ReadString(Section, 'NamePattern', '');
      Tracks := ReadString(Section, 'Tracks', '');
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
  end;

begin
  {$IFDEF IniSettings}
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
  {$ENDIF}
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

{ SaveToRegistry ---------------------------------------------------------------

  SaveToFile speichert (fast) alle Einstellungen in die Registry.              }

{$IFDEF RegistrySettings}
procedure TSettings.SaveToRegistry;
var PF: TRegIniFile; // ProjectFile

  {lokale Prozedur, die die Einstellungen in die Datei PF schreibt, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure SaveSettings;
  var Section: string;
      i: Integer;
  begin
    {allgemeine Einstellungen/Statusvaraiblen}
    Section := 'General';
    with PF, General do
    begin
      WriteInteger(Section, 'Choice', Choice);
      for i := 1 to TabSheetCount do
      begin
        WriteInteger(Section, 'TabSheetDrive' + IntToStr(i), TabSheetDrive[i]);
        WriteInteger(Section, 'TabSheetSpeed' + IntToStr(i), TabSheetSpeed[i]);
      end;
      WriteBool(Section, 'ImageRead', ImageRead);
      WriteBool(Section, 'NoConfirm', NoConfirm);
      WriteInteger(Section, 'TabFrmSettings', TabFrmSettings);
      WriteInteger(Section, 'TabFrmDAE', TabFrmDAE);
      WriteString(Section, 'TempFolder', TempFolder);
      WriteBool(Section, 'AskForTempDir', AskForTempDir);
      WriteBool(Section, 'CDTextUseTags', CDTextUseTags);
      WriteBool(Section, 'CDTextTP', CDTextTP);
      WriteBool(Section, 'DetectSpeeds', DetectSpeeds);
    end;

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
      WriteBool(Section, 'UseRSCSI', UseRSCSI);
      WriteString(Section, 'Host', Host);
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
      WriteString(Section, 'VolId', VolId);
      WriteBool(Section, 'FindDups', FindDups);
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
      WriteBool(Section, 'Dummy', Dummy);
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
      WriteBool(Section, 'Bulk', Bulk);
      WriteBool(Section, 'Paranoia', Paranoia);
      WriteBool(Section, 'NoInfoFile', NoInfoFile);
      WriteString(Section, 'Path', Path);
      WriteBool(Section, 'PrefixNames', PrefixNames);
      WriteString(Section, 'Prefix', Prefix);
      WriteString(Section, 'NamePattern', NamePattern);
      WriteString(Section, 'Tracks', Tracks);
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
      WriteBool(Section, 'OnTheFly', OnTheFly);
      WriteBool(Section, 'ImageOnly', ImageOnly);
      WriteBool(Section, 'KeepImage', KeepImage);
      WriteBool(Section, 'Verify', Verify);      
    end;
  end;

begin
  PF := TRegIniFile.Create('Software\cdrtfe');
  {Default-Pfade nicht speichern, also löschen}
  UnsetDefaultPaths;
  SaveSettings;
  {Default-Pfade wiederherstellen}
  SetDefaultPaths;
  PF.Free;
end;
{$ENDIF}

{ LoadFromRegistry -------------------------------------------------------------

  LoadFromFile Einstellungen aus der Registry.                                 }

{$IFDEF RegistrySettings}
procedure TSettings.LoadFromRegistry;
var PF: TRegIniFile; // ProjectFile

  {lokale Prozedur, die die Einstellungen aus der Datei PF liest, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure LoadSettings;
  var Section: string;
      i: Integer;
      c: Integer;
  begin
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
      end;
      ImageRead := ReadBool(Section, 'ImageRead', True);
      NoConfirm := ReadBool(Section, 'NoConfirm', False);
      TabFrmSettings := ReadInteger(Section, 'TabFrmSettings', cCdrtfe);
      TabFrmDAE := ReadIntegr(Section, 'TabFrmDAE', cTabDAE);
      TempFolder := ReadString(Section, 'TempFolder', '');
      AskForTempDir := ReadBool(Section, 'AskForTempDir', False);
      CDTextUseTags := ReadBool(Section, 'CDTextUseTags', True);
      CDTextTP := ReadBool(Section, 'CDTextTP', False);
      DetectSpeeds := ReadBool(Section, 'DetectSpeeds', DetectSpeeds);
    end;
    Shared.ProgressBarPosition := 1;
    ProgressBarUpdate;

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
      UseRSCSI := ReadBool(Section, 'UseRSCSI', False);
      Host := ReadString(Section, 'Host', '');
      if UseRSCSI then RSCSIString := RSCSIString + Host + ':' else
        RSCSIString := '';
    end;
    Shared.ProgressBarPosition := 2;
    ProgressBarUpdate;

    {allgemeine Einstellungen: cdrdao}
    Section := 'cdrdao';
    with PF, Cdrdao do
    begin
      ForceGenericMmc := ReadBool(Section, 'ForceGenericMmc', False);
      ForceGenericMmcRaw := ReadBool(Section, 'ForceGenericMmcRaw', False);
      WriteCueImages := ReadBool(Section, 'WriteCueImages', False);
    end;
    Shared.ProgressBarPosition := 3;
    ProgressBarUpdate;

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
      VolId := ReadString(Section, 'VolId', '');
      FindDups := ReadBool(Section, 'FindDups', False);
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
    Shared.ProgressBarPosition := 4;
    ProgressBarUpdate;

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
    end;
    Shared.ProgressBarPosition := 5;
    ProgressBarUpdate;

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
      Dummy := ReadBool(Section, 'Dummy', False);
      Overburn := ReadBool(Section, 'OverBurn', False);
      {Einstellungen: rrenc}
      UseErrorProtection := ReadBool(Section, 'UseErrorProtection', False);
      SecCount := ReadInteger(Section, 'SecCount', 3600);
    end;
    Shared.ProgressBarPosition := 6;
    ProgressBarUpdate;

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
    Shared.ProgressBarPosition := 7;
    ProgressBarUpdate;

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
    Shared.ProgressBarPosition := 8;
    ProgressBarUpdate;

    {DAE}
    Section := 'DAE';
    with PF, DAE do
    begin
      Action := ReadInteger(Section, 'Action', 0);
      Device := ReadString(Section, 'Device', '');
      Speed := ReadString(Section, 'Speed', '');
      Bulk := ReadBool(Section, 'Bulk', True);
      Paranoia := ReadBool(Section, 'Paranoia', False);
      NoInfoFile := ReadBool(Section, 'NoInfoFile', True);
      Path := ReadString(Section, 'Path', '');
      PrefixNames := ReadBool(Section, 'PrefixNames', True);
      Prefix := ReadString(Section, 'Prefix', 'track');
      NamePattern := ReadString(Section, 'NamePattern', '');
      Tracks := ReadString(Section, 'Tracks', '');
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
      CustomOpt := ReadString(Section, 'CustemOpt', '');
    end;
    Shared.ProgressBarPosition := 9;
    ProgressBarUpdate;

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
    end;
    Shared.ProgressBarPosition := 10;
    ProgressBarUpdate;

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
    end;
    Shared.ProgressBarPosition := 11;
    ProgressBarUpdate;

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
    Shared.ProgressBarPosition := 12;
    ProgressBarUpdate;

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
    Shared.ProgressBarPosition := 13;
    ProgressBarUpdate;
  end;

begin
  if SettingsAvailable then
  begin
    {Einstellungen aus der Registry laden}
    PF := TRegIniFile.Create('Software\cdrtfe');
    {Einstellungen laden}
    LoadSettings;
    PF.Free;
  end;
  {Vorbelegungen für Pfade zum Image und temporären Ordner}
  SetDefaultPaths;
end;
{$ENDIF}

{ DeleteFromRegistry -----------------------------------------------------------

  Löscht alle Einstellungen aus der Registry.                                  }

{$IFDEF RegistrySettings}
procedure TSettings.DeleteFromRegistry;
var Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    with Reg do
    begin
      DeleteKey('\Software\cdrtfe');
    end;
  finally
    Reg.Free;
  end;
end;
{$ENDIF}

{ DeleteIniFile ----------------------------------------------------------------

  DeleteIniFile löscht die Ini-Datei mit den gespeicherten Einstellungen.      }

{$IFDEF IniSettings}
procedure TSettings.DeleteIniFile;
begin
  DeleteFile(General.IniFile);
end;
{$ENDIF}

end.
