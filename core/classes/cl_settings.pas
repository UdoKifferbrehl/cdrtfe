{ $Id: cl_settings.pas,v 1.7 2010/05/20 14:38:10 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings.pas: Einstellungen von cdrtfe

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  20.05.2010

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

                 General
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
                 LoadFromFile(const Name: string)
                 SaveToFile(const Name: string)

}

unit cl_settings;

{$I directives.inc}

interface

uses {$IFDEF Delphi2005Up} Windows, {$ENDIF}
     Classes, SysUtils, IniFiles, FileCtrl,
     cl_lang, f_locations, const_locations, userevents, const_core,
     const_tabsheets, const_common,
     cl_settings_audiocd, cl_settings_cdinfo, cl_settings_cdrdao,
     cl_settings_cdrecord, cl_settings_cdrw, cl_settings_cmdlineflags,
     cl_settings_dae, cl_settings_datacd, cl_settings_drives,
     cl_settings_dvdvideo, cl_settings_environment, cl_settings_fileexplorer,
     cl_settings_fileflags, cl_settings_general, cl_settings_hacks,
     cl_settings_image, cl_settings_readcd, cl_settings_videocd,
     cl_settings_winpos, cl_settings_xcd;

type { Objekt mit den Einstellungen }
     TSettings = class(TObject)
     private
       FLang: TLang;
       FOnProgressBarHide: TProgressBarHideEvent;
       FOnProgressBarShow: TProgressBarShowEvent;
       FOnProgressBarUpdate: TProgressBarUpdateEvent;
       FOnUpdatePanels: TUpdatePanelsEvent;
       {Objekte mit den einzelnen Einstellungen}
       FGeneral     : TGeneralSettings;
       FWinPos      : TWinPos;
       FFileExplorer: TFileExplorer;
       FCmdLineFlags: TCmdLineFlags;
       FFileFlags   : TFileFlags;
       FEnvironment : TEnvironment;
       FDrives      : TSettingsDrives;
       FCdrecord    : TSettingsCdrecord;
       FCdrdao      : TSettingsCdrdao;
       FDataCD      : TSettingsDataCD;
       FAudioCD     : TSettingsAudioCD;
       FXCD         : TSettingsXCD;
       FCDRW        : TSettingsCDRW;
       FCDInfo      : TSettingsCDInfo;
       FDAE         : TSettingsDAE;
       FImage       : TSettingsImage;
       FReadcd      : TSettingsReadcd;
       FVideoCD     : TSettingsVideoCD;
       FDVDVideo    : TSettingsDVDVideo;
       FHacks       : TSettingsHacks;
       function GetIniPath(Load: Boolean): string;
       procedure InitSettings;
       {Events}
       procedure ProgressBarHide;
       procedure ProgressBarShow(const Max: Integer);
       procedure ProgressBarUpdate(const Position: Integer);
       procedure UpdatePanels(const s1, s2: string);
     public
       constructor Create;
       destructor Destroy; override;
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
       {Settings}
       property General     : TGeneralSettings read FGeneral write FGeneral;
       property WinPos      : TWinPos read FWinPos write FWinPos;
       property FileExplorer: TFileExplorer read FFileExplorer write FFileExplorer;
       property CmdLineFlags: TCmdLineFlags read FCmdLineFlags write FCmdLineFlags;
       property FileFlags   : TFileFlags read FFileFlags write FFileFlags;
       property Environment : TEnvironment read FEnvironment write FEnvironment;
       property Drives      : TSettingsDrives read FDrives write FDrives;
       property Cdrecord    : TSettingsCdrecord read FCdrecord write FCdrecord;
       property Cdrdao      : TSettingsCdrdao read FCdrdao write FCdrdao;
       property DataCD      : TSettingsDataCD read FDataCD write FDataCD;
       property AudioCD     : TSettingsAudioCD read FAudioCD write FAudioCD;
       property XCD         : TSettingsXCD read FXCD write FXCD;
       property CDRW        : TSettingsCDRW read FCDRW write FCDRW;
       property CDInfo      : TSettingsCDInfo read FCDInfo write FCDInfo;
       property DAE         : TSettingsDAE read FDAE write FDAE;
       property Image       : TSettingsImage read FImage write FImage;
       property Readcd      : TSettingsReadcd read FReadcd write FReadcd;
       property VideoCD     : TSettingsVideoCD read FVideoCD write FVideoCD;
       property DVDVideo    : TSettingsDVDVideo read FDVDVideo write FDVDVideo;
       property Hacks       : TSettingsHacks read FHacks write FHacks;
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
begin
  //
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
      if FGeneral.PortableMode then
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
    if FDataCD.IsoPath     = '' then FDataCD.IsoPath     := DefaultImageFile;
    if FXCD.IsoPath        = '' then FXCD.IsoPath        := DefaultImageName;
    if FVideoCD.IsoPath    = '' then FVideoCD.IsoPath    := DefaultImageName;
    if FDVDVideo.IsoPath   = '' then FDVDVideo.IsoPath   := DefaultImageFile;
    if FGeneral.TempFolder = '' then FGeneral.TempFolder := DefaultDir;
  end;
  {Vorgabe für Wave-Dateien von CD (DAE)}
  DefaultDir := GetShellFolder(CSIDL_MyMusic);
  if (DefaultDir <> '') then
  begin
    if FDAE.Path           = '' then FDAE.Path           := DefaultDir;
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
  if FDataCD.IsoPath     = DefaultImageFile then FDataCD.IsoPath     := '';
  if FXCD.IsoPath        = DefaultImageName then FXCD.IsoPath        := '';
  if FVideoCD.IsoPath    = DefaultImageName then FVideoCD.IsoPath    := '';
  if FDVDVideo.IsoPath   = DefaultImageFile then FDVDVideo.IsoPath   := '';
  if FGeneral.TempFolder = DefaultDir       then FGeneral.TempFolder := '';
  {DAE-Pfad}
  DefaultDir := GetShellFolder(CSIDL_MyMusic);
  if FDAE.Path           = DefaultDir       then FDAE.Path           := '';
end;

{ TSettings - public }

constructor TSettings.Create;
begin
  inherited Create;
  FGeneral      := TGeneralSettings.Create;
  FWinPos       := TWinPos.Create;
  FFileExplorer := TFileExplorer.Create;
  FCmdLineFlags := TCmdLineFlags.Create;
  FFileFlags    := TFileFlags.Create;
  FEnvironment  := TEnvironment.Create;
  FDrives       := TSettingsDrives.Create;
  FCdrecord     := TSettingsCdrecord.Create;
  FCdrdao       := TSettingsCdrdao.Create;
  FDataCD       := TSettingsDataCD.Create;
  FAudioCD      := TSettingsAudioCD.Create;
  FXCD          := TSettingsXCD.Create;
  FCDRW         := TSettingsCDRW.Create;
  FCDInfo       := TSettingsCDInfo.Create;
  FDAE          := TSettingsDAE.Create;
  FImage        := TSettingsImage.Create;
  FReadcd       := TSettingsReadcd.Create;
  FVideoCD      := TSettingsVideoCD.Create;
  FDVDVideo     := TSettingsDVDVideo.Create;
  FHacks        := TSettingsHacks.Create;
  InitSettings;
end;

destructor TSettings.Destroy;
begin
  FGeneral.Free;
  FWinPos.Free;
  FFileExplorer.Free;
  FCmdLineFlags.Free;
  FFileFlags.Free;
  FEnvironment.Free;
  FDrives.Free;
  FCdrecord.Free;
  FCdrdao.Free;
  FDataCD.Free;
  FAudioCD.Free;
  FXCD.Free;
  FCDRW.Free;
  FCDInfo.Free;
  FDAE.Free;
  FImage.Free;
  FReadcd.Free;
  FVideoCD.Free;
  FDVDVideo.Free;
  FHacks.Free;
  inherited Destroy;
end;

{ SaveToFile -------------------------------------------------------------------

  SaveToFile speichert (fast) alle Einstellungen in einer Ini-Datei.           }

procedure TSettings.SaveToFile(const Name: string);
var PF     : TMemIniFile; // ProjectFile
    IniPath: string;

  {lokale Prozedur, die die Einstellungen in die Datei PF schreibt, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure SaveSettings;
  var AsIniFile: Boolean;
  begin
    AsIniFile := Name = cIniFile;

    FGeneral.AsInifile := AsIniFile;
    FGeneral.Save(PF);

    FWinPos.AsInifile := AsIniFile;
    FWinPos.Save(PF);

    FFileExplorer.AsInifile := AsIniFile;
    FFileExplorer.Save(PF);

    FDrives.AsInifile := AsIniFile;
    FDrives.Save(PF);

    FCdrecord.AsInifile := AsIniFile;
    FCdrecord.Save(PF);

    FCdrdao.AsInifile := AsIniFile;
    FCdrdao.Save(PF);

    FDataCD.AsInifile := AsIniFile;
    FDataCD.Save(PF);

    FAudioCD.AsInifile := AsIniFile;
    FAudioCD.Save(PF);

    FXCD.AsInifile := AsIniFile;
    FXCD.Save(PF);

    FCDRW.AsInifile := AsIniFile;
    FCDRW.Save(PF);

    FCDInfo.AsInifile := AsIniFile;
    FCDInfo.Save(PF);

    FDAE.AsInifile := AsIniFile;
    FDAE.Save(PF);

    FImage.AsInifile := AsIniFile;
    FImage.Save(PF);

    FReadCD.AsInifile := AsIniFile;
    FReadCD.Save(PF);

    FVideoCD.AsInifile := AsIniFile;
    FVideoCD.Save(PF);

    FDVDVideo.AsInifile := AsIniFile;
    FDVDVideo.Save(PF);

  end;

begin
  if Name = cIniFile then
  begin
    {Ini-Datei}
    if FGeneral.IniFile = '' then
    begin
      {es gab noch keine Ini, also neue anlegen}
      IniPath := GetIniPath(False);
    end else
    begin
      {Pfad der vorhandenen Ini verwenden}
      IniPath := ExtractFilePath(General.IniFile);
    end;
    {Datei speichern}
    PF := TMemIniFile.Create(IniPath + Name);
    FGeneral.IniFile := IniPath + Name;
    {Default-Pfade nicht speichern, also löschen}
    UnsetDefaultPaths;
    SaveSettings;
    {Default-Pfade wiederherstellen}
    SetDefaultPaths;
    PF.UpdateFile;
    PF.Free;
    FileFlags.IniFileOk := True;
  end else
  begin
    {Projekt-Datei speichern}
    PF := TMemIniFile.Create(Name);
    SaveSettings;
    PF.UpdateFile;
    PF.Free;
  end;
end;

{ LoadFromFile -----------------------------------------------------------------

  LoadFromFile speichert (fast) alle Einstellungen in einer Ini-Datei.         }

procedure TSettings.LoadFromFile(const Name: string);
var PF     : TMemIniFile; // ProjectFile
    IniPath: string;

  {lokale Prozedur, die die Einstellungen aus der Datei PF liest, wobei PF
   entweder eine Ini-Datei oder auch die Registry sein kann.}
  procedure LoadSettings;
  var AsIniFile: Boolean;
  begin
    AsIniFile := Name = cIniFile;

    FGeneral.AsInifile := AsIniFile;
    FGeneral.Load(PF);
    ProgressBarUpdate(1);

    FWinPos.AsInifile := AsIniFile;
    FWinPos.Load(PF);
    ProgressBarUpdate(2);

    FFileExplorer.AsInifile := AsIniFile;
    FFileExplorer.Load(PF);
    ProgressBarUpdate(3);

    FDrives.AsInifile := AsIniFile;
    FDrives.Load(PF);
    ProgressBarUpdate(4);

    FCdrecord.AsInifile := AsIniFile;
    FCdrecord.Load(PF);
    ProgressBarUpdate(5);

    FCdrdao.AsInifile := AsIniFile;
    FCdrdao.Load(PF);
    ProgressBarUpdate(6);

    FDataCD.AsInifile := AsIniFile;
    FDataCD.Load(PF);
    ProgressBarUpdate(7);

    FAudioCD.AsInifile := AsIniFile;
    FAudioCD.Load(PF);
    ProgressBarUpdate(8);

    FXCD.AsInifile := AsIniFile;
    FXCD.Load(PF);
    ProgressBarUpdate(9);

    FCDRW.AsInifile := AsIniFile;
    FCDRW.Load(PF);
    ProgressBarUpdate(10);

    FCDInfo.AsInifile := AsIniFile;
    FCDInfo.Load(PF);
    ProgressBarUpdate(11);

    FDAE.AsInifile := AsIniFile;
    FDAE.Load(PF);
    ProgressBarUpdate(12);

    FImage.AsInifile := AsIniFile;
    FImage.Load(PF);
    ProgressBarUpdate(13);

    FReadCD.AsInifile := AsIniFile;
    FReadCD.Load(PF);
    ProgressBarUpdate(14);

    FVideoCD.AsInifile := AsIniFile;
    FVideoCD.Load(PF);
    ProgressBarUpdate(15);

    FDVDVideo.AsInifile := AsIniFile;
    FDVDVideo.Load(PF);
    ProgressBarUpdate(16);

    FHacks.AsInifile := AsIniFile;
    FHacks.Load(PF);
    ProgressBarUpdate(17);

  end;

  {lokale Prozedur, die die Abhängigkeiten von Einstellungen unterschiedlicher
   Objekte prüft.}

  procedure CheckDependencies;
  begin
    FFileFlags.MPlayerOk := FileExists(FGeneral.MPlayerCmd);
    FDataCD.OnTheFly := FDataCD.OnTheFly and
                       (FFileFlags.ShOk or not FFileFlags.ShNeeded);
    FDVDVideo.OnTheFly := FDVDVideo.OnTheFly and
                         (FFileFlags.ShOk or not FFileFlags.ShNeeded);
    FAudioCD.ReplayGain := FAudioCD.ReplayGain and FFileFlags.WavegainOk;
    FDAE.MP3 := FDAE.MP3 and FFileFlags.LameOk and
                (FFileFlags.ShOk or not FFileFlags.ShNeeded);
    FDAE.Ogg := FDAE.Ogg and FileFlags.OggencOk and
                (FFileFlags.ShOk or not FFileFlags.ShNeeded);
    FDAE.FLAC := FDAE.FLAC and FileFlags.FlacOk and
                 (FFileFlags.ShOk or not FFileFlags.ShNeeded);
  end;

begin
  if Name = cIniFile then
  begin
    {Einstellungen aus Ini laden}
    IniPath := GetIniPath(True);
    if IniPath <> '' then
    begin
      PF := TMemIniFile.Create(IniPath);
      LoadSettings;
      PF.Free;
      FGeneral.IniFile := IniPath;
    end else
    begin
      FFileFlags.IniFileOk := False;
    end;
    {Vorbelegungen für Pfade zum Image und temporären Ordner}
    SetDefaultPaths;
  end else
  begin
    {Einstellungen aus einer Projekt-Datei laden}
    PF := TMemIniFile.Create(Name);
    {Namen merken für Log-File}
    FGeneral.LastProject := Name;
    {Event zum Aktualisieren der Panels auslösen}
    UpdatePanels(Format(FLang.GMS('mpref07'), [Name]), FLang.GMS('mpref08'));
    {Reset der Progress-Bars}
    ProgressBarShow(17);
    {Einstellungen laden}
    LoadSettings;
    ProgressBarHide;
    PF.Free;
  end;
  CheckDependencies;
end;

{ DeleteIniFile ----------------------------------------------------------------

  DeleteIniFile löscht die Ini-Datei mit den gespeicherten Einstellungen.      }

procedure TSettings.DeleteIniFile;
begin
  DeleteFile(General.IniFile);
end;

end.
