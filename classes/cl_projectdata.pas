{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cl_projectdata.pas:

  Copyright (c) 2004-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  13.05.2006

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  cl_projectdata.pas stellt das Datenobjekt zur Verf�gung, das alle Dateilisten
  f�r Daten-CDs, Audio-CDs, XCDs, Video-CDs sowie die Trackliste DAE zusammen-
  fasst. 


  TProjectData

    Properties   AcceptMP3
                 AcceptOgg
                 AccpetFLAC
                 AddAsForm2
                 CompressedAudioFilesPresent
                 LastError
                 LastFolderAdded
                 OnMessageToShow
                 OnProgressBarHide
                 OnProgressBarReset
                 OnProgressBarUpdate
                 OnUpdatePanels
                 
    Variablen    DataCDFilesToSort: Boolean           Diese Flags geben an, ob
                 DataCDFilesToSortFolder: string      und welche Ordner nach
                 DataCDFoldersToSort: Boolean         Umbennennungen sortiert
                 DataCDFoldersToSortParent: string    werden m�ssen.
                 XCDFoldersToSort: Boolean
                 XCDFoldersToSortParent: string
                 ErrorListFiles                       Listen f�r fehlerhafte
                 ErrorListDir                         Datei-/Ordnernamen
                 ErrorListIgnore                      ignorierte �berlange Namen
                 IgnoreNameLengthErrors               zu lange Namen ignorieren
                 InvalidSrcFiles                      unzul�ssige Quelldateien

    Methoden     AddToPathlist(const AddName, DestPath: string; const Choice: Byte)
                 CDTextLength: Integer
                 CDTextPresent: Boolean
                 ChangeForm2Status(const Name, Path: string)
                 CheckDataCDFS(const Path: string; const MaxLength: Byte; const CheckFolder: Boolean)
                 CreateBurnList(List: TStringList; const Choice: Byte)
                 CreateCDTextFile(const Name: string)
                 CreateVerifyList(List: TStringList; const Choice: Byte)
                 DeleteAll(const Choice: Byte)
                 DeleteFolder(const Path: string; const Choice: Byte)
                 DeleteFromPathlistByIndex(const Index: Integer; const Path: string; const Choice: Byte)
                 DeleteFromPathlistByName(const Name, Path: string; const Choice: Byte)
                 ExportStructureToTreeView(const Choice: Byte; Tree: TTreeView)
                 GetCDLabel(const Choice: Byte): string
                 GetCDText(const Index: Integer; var TextData: TCDTextTrackData)
                 GetFileList(const Path: string; const Choice: Byte): TStringList
                 GetForm2FileCount: Integer
                 GetProjectInfo(var FileCount, FolderCount: Integer; var CDSize: Longint; var CDTime: Extended; var TrackCount: Integer; const Choice: Byte)
                 GetProjectMaxLevel(const Choice: Byte): Integer
                 GetSmallForm2FileCount: Integer
                 GetTrackPause(const Index: Integer): string
                 LoadFromFile(const Name: string)
                 MoveFileByIndex(const Index: Integer; const SourcePath, DestPath: string; const Choice: Byte)
                 MoveFileByName(const Name, SourcePath, DestPath: string; const Choice: Byte)
                 MoveFolder(const SourcePath, DestPath: string; const Choice: Byte)
                 MoveTrack(const Index: Integer; const Direction: TDirection; const Choice: Byte)
                 MP3FilesPresent: Boolean;
                 OggFilesPresent: Boolean;
                 NewFolder(const Path, Name: string; const Choice: Byte)
                 RenameFileByIndex(const Index: Integer; const Path, Name: string; const MaxLength, Choice: Byte)
                 RenameFileByName(const Path, OldName, Name: string; const MaxLength, Choice: Byte)
                 RenameFolder(const Path, Name :string; const MaxLength, Choice: Byte)
                 SaveToFile(const Name: string)
                 SetCDLabel(const Name: string; const Choice: Byte)
                 SetCDText(const Index: Integer;  TextData: TCDTextTrackData)
                 SetDVDSourcePath(const Path: string)
                 SetTrackPause(const Index: Integer; const Pause: string)
                 SortFileList(const Path: string; const Choice: Byte)
                 SortFolder(const Path: string; const Choice: Byte)
                 TrackPausePresen: Boolean

    exportierte Funktionen/Prozeduren:

      ExtractFileInfoFromEntry(const Entry: string; var Name, Path: string; var Size: Longint)
      ExtractTrackInfoFromEntry(const Entry: string; var Name, Path: string; var Size: Longint; var TrackLength: Extended);

}

unit cl_projectdata;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils, FileCtrl, ComCtrls,
     cl_cd, cl_lang, cl_settings, f_cdtext, constant;

     {cl_settings wird nur eingebunden, damit der Typ TShared verwendet werden
      kann. Auf keinen Fall sollte direkt auf Objekte vom Typ TSettings zuge-
      griffen werden.}

const PD_NoError = 0;          {Fehlercodes}
      PD_FolderNotUnique = 1;
      PD_FileNotUnique = 2;
      PD_FileNotFound = 3;
      PD_DestFolderIsSubFolder = 4;
      PD_NameTooLong = 5;
      PD_InvalidName = 6;
      PD_InvalidWaveFile = 7;
      PD_InvalidLabel = 8;
      PD_InvalidMpegFile = 9;
      PD_InvalidMP3File = 10;
      PD_InvalidOggFile = 11;
      PD_InvalidFLACFile = 12;
      PD_NoMP3Support = 13;
      PD_NoOggSupport = 14;
      PD_NoFLACSupport = 15;

type TProjectData = class(TObject)
     private
       FAcceptMP3: Boolean;
       FAcceptOgg: Boolean;
       FAcceptFLAC: Boolean;
       FLang: TLang;
       FDataCD: TCD;
       FAudioCD: TAudioCD;
       FXCD: TXCD;
       FDAE: TDAE;
       FVideoCD: TVideoCD;
       FDVDVideo: TDVDVideo;
       FError: Byte;
       FFolderAdded: string;
       FAddAsForm2: Boolean;
       FOnMessageToShow: TNotifyEvent;
       FOnProgressBarHide: TNotifyEvent;
       FOnProgressBarReset: TNotifyEvent;
       FOnProgressBarUpdate: TNotifyEvent;
       FOnUpdatePanels: TNotifyEvent;
       function GetCompressedAudioFilesPresent: Boolean;
       function GetLastError: Byte;
       function GetLastFolderAdded: string;
       procedure SetAcceptMP3(Mode: Boolean);
       procedure SetAcceptOgg(Mode: Boolean);
       procedure SetAcceptFLAC(Mode: Boolean);
       procedure SetXCDAddMode(Mode: Boolean);
       {Events}
       procedure MessageToShow;
       procedure ProgressBarHide;
       procedure ProgressBarReset;
       procedure ProgressBarUpdate;
       procedure UpdatePanels;
     public
       DataCDFilesToSort: Boolean;
       DataCDFilesToSortFolder: string;
       DataCDFoldersToSort: Boolean;
       DataCDFoldersToSortParent: string;
       XCDFoldersToSort: Boolean;
       XCDFoldersToSortParent: string;
       ErrorListFiles: TStringList;
       ErrorListDir: TStringList;
       ErrorListIgnore: TStringList;
       InvalidSrcFiles: TStringList;
       NoAccessFiles: TStringList;
       IgnoreNameLengthErrors: Boolean;
       constructor Create;
       destructor Destroy; override;
       function CDTextLength: Integer;
       function CDTextPresent: Boolean;
       function GetCDLabel(const Choice: Byte): string;
       function GetFileList(const Path: string; const Choice: Byte): TStringList;
       function GetForm2FileCount: Integer;
       function GetProjectMaxLevel(const Choice: Byte): Integer;
       function GetSmallForm2FileCount: Integer;
       function GetTrackPause(const Index: Integer): string;
       function TrackPausePresent: Boolean;
       procedure AddToPathlist(const AddName, DestPath: string; const Choice: Byte);
       procedure CheckDataCDFS(const Path: string; const MaxLength: Byte; const CheckFolder, CheckAccess: Boolean);
       procedure ChangeForm2Status(const Name, Path: string);
       procedure CreateBurnList(List: TStringList; const Choice: Byte);
       procedure CreateCDTextFile(const Name: string);
       procedure CreateVerifyList(List: TStringList; const Choice: Byte);
       procedure DeleteAll(const Choice: Byte);
       procedure DeleteFolder(const Path: string; const Choice: Byte);
       procedure DeleteFromPathlistByIndex(const Index: Integer; const Path: string; const Choice: Byte);
       procedure DeleteFromPathlistByName(const Name, Path: string; const Choice: Byte);
       procedure GetCDText(const Index: Integer; var TextData: TCDTextTrackData);
       procedure GetProjectInfo(var FileCount, FolderCount: Integer; var CDSize: {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF}; var CDTime: Extended; var TrackCount: Integer; const Choice: Byte);
       procedure ExportStructureToTreeView(const Choice: Byte; Tree: TTreeView);
       procedure LoadFromFile(const Name: string; var Shared: TShared);
       procedure MoveFileByIndex(const Index: Integer; const SourcePath, DestPath: string; const Choice: Byte);
       procedure MoveFileByName(const Name, SourcePath, DestPath: string; const Choice: Byte);
       procedure MoveFolder(const SourcePath, DestPath: string; const Choice: Byte);
       procedure MoveTrack(const Index: Integer; const Direction: TDirection; const Choice: Byte);
       procedure NewFolder(const Path, Name: string; const Choice: Byte);
       procedure RenameFileByIndex(const Index: Integer; const Path, Name: string; const MaxLength, Choice: Byte);
       procedure RenameFileByName(const Path, OldName, Name: string; const MaxLength, Choice: Byte);
       procedure RenameFolder(const Path, Name :string; const MaxLength, Choice: Byte);
       procedure SaveToFile(const Name: string);
       procedure SetCDLabel(const Name: string; const Choice: Byte);
       procedure SetCDText(const Index: Integer;  TextData: TCDTextTrackData);
       procedure SetDVDSourcePath(const Path: string);
       procedure SetTrackPause(const Index: Integer; const Pause: string);
       procedure SortFileList(const Path: string; const Choice: Byte);
       procedure SortFolder(const Path: string; const Choice: Byte);
       {$IFDEF DebugFileLists}
       function GetFolderName(const Path:string; const Choice: Byte): string;
       {$ENDIF}
(*     property DataCD: TCD read FDataCD write FDataCD;
       property AudioCD: TAudioCD read FAudioCD write FAudioCD;
       property XCD: TXCD read FXCD write FXCD; *)
       property AcceptMP3: Boolean read FAcceptMP3 write SetAcceptMP3;
       property AcceptOgg: Boolean read FAcceptOgg write SetAcceptOgg;
       property AcceptFLAC: Boolean read FAcceptFLAC write SetAcceptFLAC;
       property CompressedAudioFilesPresent: Boolean read GetCompressedAudioFilesPresent;
       property Lang: TLang write FLang;
       property LastError: Byte read GetLastError;
       property LastFolderAdded: string read GetLastFolderAdded;
       property AddAsForm2: Boolean write SetXCDAddMode;
       {Events}
       property OnMessageToShow: TNotifyEvent read FOnMessageToShow write FOnMessageToShow;
       property OnProgressBarHide: TNotifyEvent read FOnProgressBarHide write FOnProgressBarHide;
       property OnProgressBarReset: TNotifyEvent read FOnProgressBarReset write FOnProgressBarReset;
       property OnProgressBarUpdate: TNotifyEvent read FOnProgressBarUpdate write FOnProgressBarUpdate;
       property OnUpdatePanels: TNotifyEvent read FOnUpdatePanels write FOnUpdatePanels;
     end;

procedure ExtractFileInfoFromEntry(const Entry: string; var Name, Path: string; var Size: {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF});
procedure ExtractTrackInfoFromEntry(const Entry: string; var Name, Path: string; var Size: {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF}; var TrackLength: Extended);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_misc, f_strings;

{ TProjectData --------------------------------------------------------------- }

{ TProjectData - private }

{ MessageToShow ----------------------------------------------------------------

  L�st das Event OnMessageShow aus, das das Hauptfenster veranla�t, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TProjectData.MessageToShow;
begin
  if Assigned(FOnMessageToShow) then FOnMessageToShow(Self);
end;

{ ProgressBarHide --------------------------------------------------------------

  L�st das Event OnProgressBarHide aus, da� den Progress-Bar des Hauptfensters
  unsichtbar macht.                                                            }

procedure TProjectData.ProgressBarHide;
begin
  if Assigned(FOnProgressBarHide) then FOnProgressBarHide(Self);
end;

{ ProgressBarReset -------------------------------------------------------------

  L�st das Event OnProgressBarReset aus, da� den Progress-Bar des Hauptfensters
  sichtbar macht und zur�cksetzt.                                              }

procedure TProjectData.ProgressBarReset;
begin
  if Assigned(FOnProgressBarReset) then FOnProgressBarReset(Self);
end;

{ ProgressBarUpdate ------------------------------------------------------------

  L�st das Event OnProgressBarUpdate aus, da� den Progress-Bar des Hauptfensters
  aktualisiert.                                                                }

procedure TProjectData.ProgressBarUpdate;
begin
  if Assigned(FOnProgressBarUpdate) then FOnProgressBarUpdate(Self);
end;

{ UpdatePanels -----------------------------------------------------------------

  L�st das Event OnMessageShow aus, das das Hauptfenster veranla�t, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TProjectData.UpdatePanels;
begin
  if Assigned(FOnUpdatePanels) then FOnUpdatePanels(Self);
end;

{ GetLastError -----------------------------------------------------------------

  GetLastError gibt den Fehlercode aus FError und setzt FError auf No_Error.   }

function TProjectData.GetLastError: Byte;
begin
  Result := FError;
  FError := PD_NoError;
end;

{ GetLastFolderAdded -----------------------------------------------------------

  Liefert den Pfad des zuletzt eingef�gten Ordners.                            }

function TProjectData.GetLastFolderAdded: string;
begin
  Result := FFolderAdded;
  FFolderAdded := '';
end;

{ SetXCDAddMode ----------------------------------------------------------------

  Bei XCDs k�nnen auch normale Dateien als Form2-Dateien behandelt werden.
  SetXCDAddMode setzt die entsprechende Feldvariable und reicht die �nderung
  an FXCD weiter.                                                              }

procedure TProjectData.SetXCDAddMode(Mode: Boolean);
begin
  FAddAsForm2 := Mode;
  FXCD.AddAsForm2 := Mode;
end;

{ SetAcceptMP3 -----------------------------------------------------------------

  Bei Audio-CD k�nnen auch MP3s verwendet werden, es sei denn, Madplay.exe ist
  nicht vorhanden.                                                             }

procedure TProjectData.SetAcceptMP3(Mode: Boolean);
begin
  FAcceptMP3 := Mode;
  FAudioCD.AcceptMP3 := Mode;
end;

{ SetAcceptOgg -----------------------------------------------------------------

  If OggdecBin exists, then we can support Ogg files for Audio CDs.            }

procedure TProjectData.SetAcceptOgg(Mode: Boolean);
begin
  FAcceptOgg := Mode;
  FAudioCD.AcceptOgg := Mode;
end;

{ SetAcceptFLAC ----------------------------------------------------------------

  Wenn flac.exe existiert, k�nnen FLAC-Dateien verwendet werden.               }

procedure TProjectData.SetAcceptFLAC(Mode: Boolean);
begin
  FAcceptFLAC := Mode;
  FAudioCD.AcceptFLAC := Mode;
end;

{ CompressedAudioFilesPresent --------------------------------------------------

  liefert True, wenn in der Auswahl komprimierte Audio-Dateien vorhanden sind. }

function TProjectData.GetCompressedAudioFilesPresent: Boolean;
begin
  Result := FAudioCD.CompresedFilesPresent;
end;

{ TProjectData - public }

constructor TProjectData.Create;
begin
  inherited Create;
  FError := PD_NoError;
  FDataCD := TCD.Create;
  FAudioCD := TAudioCD.Create;
  FXCD := TXCD.Create;
  FDAE := TDAE.Create;
  FVideoCD := TVideoCD.Create;
  FDVDVideo := TDVDVideo.Create;
  AddAsForm2 := False; // als Property angesprochen, um �nderung durchzureichen
  ErrorListFiles := TStringList.Create;
  ErrorListDir := TStringList.Create;
  ErrorListIgnore := TStringList.Create;
  InvalidSrcFiles := TStringList.Create;
  NoAccessFiles := TStringList.Create;
  IgnoreNameLengthErrors := False;
  FAcceptMP3 := True;
  FAcceptOgg := True;
  FAcceptFLAC := True;
end;

destructor TProjectData.Destroy;
begin
  FDataCD.Free;
  FAudioCD.Free;
  FXCD.Free;
  FDAE.Free;
  FVideoCD.Free;
  FDVDVideo.Free;
  ErrorListFiles.Free;
  ErrorListDir.Free;
  ErrorListIgnore.Free;
  InvalidSrcFiles.Free;
  NoAccessFiles.Free;
  inherited Destroy;
end;

{ AddToPathlist ----------------------------------------------------------------

  F�gt eine Datei oder ein Verzeichnis zu einer der Pfadlisten hinzu.
    Name    : Datei oder Ordner
    DestPath: Ordner, in den eingef�gt wird
    Choice  : Pfdadliste, in die eingef�gt wird:
              1: Daten-CD, 2: Audio-CD, 3: XCD, 8: VideoCD                     }

procedure TProjectData.AddToPathlist(const AddName, DestPath: string;
                                     const Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD : begin
                FDataCD.AddFile(AddName, DestPath);
                ErrorCode := FDataCD.LastError;
                if ErrorCode = CD_NoError then
                begin
                  DataCDFilesToSort := False;
                  DataCDFilesToSortFolder := '';
                end;
              end;
    cAudioCD: begin
                FAudioCD.AddTrack(AddName);
                ErrorCode := FAudioCD.LastError;
              end;
    cXCD    : begin
                FXCD.AddFile(AddName, DestPath);
                ErrorCode := FXCD.LastError;
              end;
    cVideoCD: begin
                FVideoCD.AddTrack(AddName);
                ErrorCode := FVideoCD.LastError;
              end;
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FolderNotUnique: FError := PD_FolderNotUnique;
    CD_FileNotUnique: FError := PD_FileNotUnique;
    CD_FileNotFound: FError := PD_FileNotFound;
    CD_InvalidWaveFile: FError := PD_InvalidWaveFile;
    CD_InvalidMpegFile: FError := PD_InvalidMpegFile;
    CD_InvalidMP3File: FError := PD_InvalidMP3File;
    CD_InvalidOggFile: FError := PD_InvalidOggFile;
    CD_InvalidFLACFile: FError := PD_InvalidFLACFile;
    CD_NoMP3Support: FError := PD_NoMP3Support;
    CD_NoOggSupport: FError := PD_NoOggSupport;
    CD_NoFLACSupport: FError := PD_NoFLACSupport;
  end;
end;

{ SortFileList -----------------------------------------------------------------

  SortFilesList sortiert die Dateiliste des durch Path bestimmten Ordners.
  Choice legt fest, ob der Ordner in 'Daten-CD' oder 'XCD' gesucht wird.       }

procedure TProjectData.SortFileList(const Path: string; const Choice: Byte);
begin
  case Choice of
    cDataCD: FDataCD.SortFileList(Path);
    cXCD   : FXCD.SortFileList(Path);
  end;
end;

{ GetFileList ------------------------------------------------------------------

  GetFileList gibt eine Referenz auf die Dateiliste des durch Path bestimmten
  Ordners zur�ck. Im Falle von DAE wird eine Referenz auf die Trackliste
  zur�ckgegeben.                                                               }

function TProjectData.GetFileList(const Path: string;
                                  const Choice: Byte): TStringList;
begin
  case Choice of
    cDataCD : Result := FDataCD.GetFileList(Path);
    cXCD    : Result := FXCD.GetFileList(Path);
    cAudioCD: Result := FAudioCD.GetFileList;
    cDAE    : Result := FDAE.GetTrackList;
    cVideoCD: Result := FVideoCD.GetFileList;
  else
    Result := nil;
  end;
end;

{ ExportStructureToTreeView ----------------------------------------------------

  ExportStructureToTreeView ruft in Abh�ngigkeit von Choice die DataCD. oder
  XCD.ExportStructureToTreeView auf.                                           }

procedure TProjectData.ExportStructureToTreeView(const Choice: Byte;
                                                 Tree: TTreeView);
begin
  case Choice of
    cDataCD: FDataCD.ExportStructureToTreeView(Tree);
    cXCD   : FXCD.ExportStructureToTreeView(Tree);
  end;
end;

{ DeleteFromPathlistByIndex ----------------------------------------------------

  DeleteFromPathlistByIndex l�scht den (Index + 1)-ten Eintrag aus der Datei-
  liste des durch Path und Choice angegebenen Ordners.                         }

procedure TProjectData.DeleteFromPathlistByIndex(const Index: Integer;
                                                 const Path: string;
                                                 const Choice: Byte);
begin
  case Choice of
    cDataCD : FDataCD.DeleteFromPathlistByIndex(Index, Path);
    cXCD    : FXCD.DeleteFromPathlistByIndex(Index, Path);
    cAudioCD: FAudioCD.DeleteTrack(Index);
    cVideoCD: FVideoCD.DeleteTrack(Index);
  end;
end;

{ DeleteFromPathlistByName -----------------------------------------------------

  DeleteFromPathlistByName l�scht den Eintrag der Datei Name aus der Dateiliste
   es durch Path und Choice angegebenen Ordners.                               }

procedure TProjectData.DeleteFromPathlistByName(const Name, Path: string;
                                                const Choice: Byte);
begin
  case Choice of
    cDataCD: FDataCD.DeleteFromPathlistByName(Name, Path);
    cXCD   : FXCD.DeleteFromPathlistByName(Name, Path);
  end;
end;

{ DeleteFolder -----------------------------------------------------------------

  DeleteFolder l�scht den durch Path und Choice angegebenen Ordner.            }

procedure TProjectData.DeleteFolder(const Path: string; const Choice: Byte);
begin
  case Choice of
    cDataCD: FDataCD.DeleteFolder(Path);
    cXCD   : FXCD.DeleteFolder(Path);
  end;
end;

{ DeleteAll --------------------------------------------------------------------

  DeleteAll l�scht alle Daten des durch Choice bestimmten Objekts.             }

procedure TProjectData.DeleteAll(const Choice: Byte);
begin
  case Choice of
    cDataCD : FDataCD.DeleteAll;
    cXCD    : FXCD.DeleteAll;
    cAudioCD: FAudioCD.DeleteAll;
    cDAE    : FDAE.GetTrackList.Clear;
    cVideoCD: FVideoCD.DeleteAll;
  end;
end;

{ MoveFileByIndex --------------------------------------------------------------

  MoveFileByIndex verschiebt den (Index + 1)-ten Eintrag aus dem Ordner Source-
  path in den Ordner DestPath.                                                 }

procedure TProjectData.MoveFileByIndex(const Index: Integer;
                                       const SourcePath, DestPath: string;
                                       const Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.MoveFileByIndex(Index, SourcePath, DestPath);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : begin
               FXCD.MoveFileByIndex(Index, SourcePath, DestPath);
               ErrorCode := FXCD.LastError;
             end;
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FileNotUnique: FError := PD_FileNotUnique;
  end;
end;

{ MoveFileByName ---------------------------------------------------------------

  MoveFileByName verschiebt den Eintrag der Datei Name aus dem Ordner Source-
  path in den Ordner DestPath.                                                 }

procedure TProjectData.MoveFileByName(const Name, SourcePath, DestPath: string;
                                      const Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.MoveFileByName(Name, SourcePath, DestPath);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : begin
               FXCD.MoveFileByName(Name, SourcePath, DestPath);
               ErrorCode := FXCD.LastError;
             end;
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FileNotUnique: FError := PD_FileNotUnique;
  end;
end;

{ MoveFolder -------------------------------------------------------------------

  MoveFolder verschiebt den Ordner SourcePath in den Ordner DestPath.          }

procedure TProjectData.MoveFolder(const SourcePath, DestPath: string;
                                  const Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.MoveFolder(SourcePath, DestPath);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : begin
               FXCD.MoveFolder(SourcePath, DestPath);
               ErrorCode := FXCD.LastError;
             end;
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FolderNotUnique: FError := PD_FolderNotUnique;
    CD_DestFolderIsSubFolder : FError := PD_DestFolderIsSubFolder;
  end;
end;

{ SortFolder -------------------------------------------------------------------

  SortFolder sortiert die Unterordner des Ordners Path.                        }

procedure TProjectData.SortFolder(const Path: string; const Choice: Byte);
begin
  case Choice of
    cDataCD: FDataCD.SortFolder(Path);
    cXCD   : FXCD.SortFolder(Path);
  end;
end;

{ SetCDLabel -------------------------------------------------------------------

  Label der CD festlegen.                                                      }

procedure TProjectData.SetCDLabel(const Name:string; const Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.SetCDLabel(Name);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : begin
               FXCD.SetCDLabel(Name);
               ErrorCode := FXCD.LastError;
             end;
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_InvalidLabel : FError := PD_InvalidLabel;
  end;
end;

{$IFDEF DebugFileLists}
function TProjectData.GetFolderName(const Path: string;
                                    const Choice: Byte): string;
begin
  case Choice of
    cDataCD: Result := (FDataCD.GetFolderFromPath(Path)).Text;
    cXCD   : Result := (FXCD.GetFolderFromPath(Path)).Text;
  end;
end;
{$ENDIF}

{ RenameFolder -----------------------------------------------------------------

  Ordner Path umbenennen.                                                      }

procedure TProjectData.RenameFolder(const Path, Name :string;
                                    const MaxLength, Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.RenameFolder(Path, Name, MaxLength);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : begin
               FXCD.RenameFolder(Path, Name, MaxLength);
               ErrorCode := FXCD.LastError;
             end;
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FolderNotUnique: FError := PD_FolderNotUnique;
    CD_NameTooLong : FError := PD_NameTooLong;
    CD_InvalidName : FError := PD_InvalidName;
  end;
end;

{ RenameFileByIndex ------------------------------------------------------------

  Die (Index + 1)-te Datei aus der durch Path bestimmen Dateiliste umbenennen. }

procedure TProjectData.RenameFileByIndex(const Index: Integer;
                                         const Path, Name: string;
                                         const MaxLength, Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.RenameFileByIndex(Index, Path, Name, MaxLength);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : ; {momentan k�nnen bei XCDs Dateien nicht umbennant werden}
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FileNotUnique: FError := PD_FileNotUnique;
    CD_NameTooLong : FError := PD_NameTooLong;
    CD_InvalidName : FError := PD_InvalidName;
  end;
end;

{ RenameFileByName -------------------------------------------------------------

  Die Datei mit dem Namen OldName im Ordner Path wird in Name umbenannt.       }

procedure TProjectData.RenameFileByName(const Path, OldName, Name: string;
                                        const MaxLength, Choice: Byte);
var ErrorCode: Byte;
begin
  ErrorCode := PD_NoError;
  case Choice of
    cDataCD: begin
               FDataCD.RenameFileByName(Path, OldName, Name, MaxLength);
               ErrorCode := FDataCD.LastError;
             end;
    cXCD   : ; {momentan k�nnen bei XCDs Dateien nicht umbennant werden}
  end;
  case ErrorCode of
    CD_NoError : FError := PD_NoError;
    CD_FileNotUnique: FError := PD_FileNotUnique;
    CD_NameTooLong : FError := PD_NameTooLong;
    CD_InvalidName : FError := PD_InvalidName;
  end;
end;

{ ChangeForm2Status ------------------------------------------------------------

  verschiebt die Datei Name von der Datei-Liste in die MovieListe und umgekehrt.
  Da dies nur f�r XCDs relevant ist, kein Argument Choice.                     }

procedure TProjectData.ChangeForm2Status(const Name, Path: string);
begin
  FXCD.ChangeForm2Status(Name, Path);
end;

{ NewFolder --------------------------------------------------------------------

  NewFolder legt im Ordner Path einen neuen Ordner Name an.                    }

procedure TProjectData.NewFolder(const Path, Name: string; const Choice: Byte);
begin
  case Choice of
    cDataCD: begin
               FDataCD.NewFolder(Path, Name);
               FFolderAdded := FDataCD.LastFolderAdded;
             end;
    cXCD   : begin
               FXCD.NewFolder(Path, Name);
               FFolderAdded := FXCD.LastFolderAdded;
             end;  
  end;
end;

{ GetProjectInfo ---------------------------------------------------------------

  liefert in Abh�ngigkeit von Choice die Anzahl der Ordner und Dateien sowie die
  Gesamtgr��e in Bytes bzw. die Gesamtspielzeit. Da� unabh�ngig von Choice immer
  alle Variablen n�tig sind, ist unsch�n, spart aber eine zus�tzliche Prozedur.}

procedure TProjectData.GetProjectInfo(var FileCount, FolderCount: Integer;
                                      var CDSize: {$IFDEF LargeProject} Comp
                                                  {$ELSE} Longint {$ENDIF};
                                      var CDTime: Extended;
                                      var TrackCount: Integer;
                                      const Choice: Byte);
begin
  case Choice of
    cDataCD : begin
                FileCount := FDataCD.FileCount;
                FolderCount := FDataCD.FolderCount;
                CDSize := FDataCD.CDSize;
                CDTime := 0;
                TrackCOunt := 0;
              end;
    cXCD    : begin
                FileCount := FXCD.FileCount;
                FolderCount := FXCD.FolderCount;
                CDSize := FXCD.CDSize;
                CDTime := 0;
                TrackCOunt := 0;
              end;
    cAudioCD: begin
                FileCount := 0;
                FolderCount := 0;
                CDSize := 0;
                CDTime := FAudioCD.CDTime;
                TrackCount := FAudioCD.TrackCount;
              end;
    cDAE    : TrackCount := FDAE.TrackCount;
    cVideoCD: begin
                FileCount := 0;
                FolderCount := 0;
                CDSize := FVideoCD.CDSize;;
                CDTime := FVideoCD.CDTime;
                TrackCount := FVideoCD.TrackCount;
              end;
  end;
end;

{ GetProjectMaxLevel -----------------------------------------------------------

  liefert in Abh�ngigkeit von Choice die gr��te Verschachtelungstiefe von
  Ordnern.                                                                     }

function TProjectData.GetProjectMaxLevel(const Choice: Byte): Integer;
begin
  case Choice of
    cDataCD: Result := FDataCD.MaxLevel;
    cXCD   : Result := FXCD.MaxLevel;
  else
    Result := 0;
  end;
end;

{ GetForm2FileCount ------------------------------------------------------------

  liefert die Anzahl der Fomr2-Dateien. Da dies nur f�r XCDs relevant ist,
  kein Argument Choice.                                                        }

function TProjectData.GetForm2FileCount: Integer;
begin
  Result := FXCD.Form2FileCount
end;

{ GetSmallForm2FileCount -------------------------------------------------------

  liefert die Anzahl der Form2-Dateien unter 348.601 Bytes. Da dies nur f�r XCDs
  relevant ist, kein Argument Choice.                                          }

function TProjectData.GetSmallForm2FileCount: Integer;
begin
  Result := FXCD.SmallForm2FileCount
end;

{ MoveTrack --------------------------------------------------------------------

  MoveTrack verschiebt einen Audio-Track um eine Position nach oben bzw. unten.}

procedure TProjectData.MoveTrack(const Index: Integer;
                                 const Direction: TDirection;
                                 const Choice: Byte);
begin
  case Choice of
    cAudioCD: FAudioCD.MoveTrack(Index, Direction);
    cVideoCD: FVideoCD.MoveTrack(Index, Direction);
  end;
end;

{ CheckDataCDFS ----------------------------------------------------------------

  CheckDataCDFS �berpr�ft das Dateisystem der Daten-CD auf zu lange Dateinamen
  und zu tief liegende Ordner.                                                 }

procedure TProjectData.CheckDataCDFS(const Path: string; const MaxLength: Byte;
                                     const CheckFolder, CheckAccess: Boolean);
var CheckFSArgs: TCheckFSArgs;
begin
  ErrorListFiles.Clear;
  ErrorListDir.Clear;
  InvalidSrcFiles.Clear;
  NoAccessFiles.Clear;
  {Argumente zusammenstellen}
  CheckFSArgs.Path := Path;
  CheckFSArgs.MaxLength := MaxLength;
  CheckFSArgs.CheckFolder := CheckFolder;
  CheckFSArgs.CheckAccess := CheckAccess;
  CheckFSArgs.IgnoreFiles := IgnoreNameLengthErrors;
  CheckFSArgs.ErrorListFiles := ErrorListFiles;
  CheckFSArgs.ErrorListDir := ErrorListDir;
  CheckFSArgs.ErrorListIgnore := ErrorListIgnore;
  CheckFSArgs.InvalidSrcFiles := InvalidSrcFiles;
  CheckFSArgs.NoAccessFiles := NoAccessFiles;
  {Dateinamen pr�fen}
  FDataCD.CheckFS(CheckFSArgs);
end;

{ GetCDLabel -------------------------------------------------------------------

  GetCDLabel gibt das CD-Label zur�ck.                                         }

function TProjectData.GetCDLabel(const Choice: Byte): string;
begin
  case Choice of
    cDataCD: Result := FDataCD.CDLabel;
    cXCD   : REsult := FXCD.CDLabel;
  else
    Result := '';
  end;
end;

{ SaveToFile -------------------------------------------------------------------

  SaveToFile speichert die Dateilisten in einer Text-Datei.                    }

procedure TProjectData.SaveToFile(const Name: string);
var FL: TextFile; // FileList
    CDName: string;

  {lokale Prozeduren zum Speichern der Projekte: Daten-CD, XCD}
  procedure SaveCDStrukture;
  var List: TStringList;
      i: Integer;
  begin
    List := TStringList.Create;
    Writeln(FL, '<' + CDName + '>');
    {Struktur des Trees in eine String-Liste schreiben}
    if CDName = 'Data-CD' then
    begin
      FDataCD.ExportStructureToStringList(List);
    end else
    if CDName = 'XCD' then
    begin
      FXCD.ExportStructureToStringList(List);
    end;
    {Struktur aus der Liste in die Datei schreiben}
    for i := 0 to List.Count - 1 do
    begin
      Writeln(FL, List[i]);
    end;
    Writeln(FL, '</' + CDName + '>');
    Writeln(FL, '');
    List.Free;
  end;

  procedure SaveCDData;
  begin
    Writeln(FL, '<' + CDName + '-Files>');
    if CDName = 'Data-CD' then
    begin
      FDataCD.ExportDataToFile(FDataCD.GetFolderFromPath(''), FL);
    end else
    if CDName = 'XCD' then
    begin
      FXCD.ExportDataToFile(FXCD.GetFolderFromPath(''), FL);
    end;
    Writeln(FL, '</' + CDName + '-Files>');
  end;

  procedure SaveTrackList;
  var List: TStringList;
      i: Integer;
  begin
    Writeln(FL, '<' + CDName + '>');
    if CDName = 'Audio-CD' then
    begin
      List := FAudioCD.GetFileList;
    end else
    if CDName = 'DAE' then
    begin
      List := FDAE.GetTrackList;
    end else
    begin
      List := FVideoCD.GetFileList;
    end;
    {Tracks in Datei schreiben}
    for i := 0 to List.Count - 1 do
    begin
      if (CDName = 'Audio-CD') or (CDName = 'Video-CD') then
      begin
        Writeln(FL, StringLeft(List[i], '|'));
      end else
      begin
        Writeln(FL, List[i]);
      end;
    end;
    Writeln(FL, '</' + CDName + '>');
  end;

  procedure SaveTrackInfo;
  var i: Integer;
      TextTrackData: TCDTextTrackData;
  begin
    Writeln(FL, '<' + CDName + '>');
    for i := -1 to FAudioCD.TrackCount - 1 do
    begin
      if CDName = 'CD-Text' then
      begin
        FAudioCD.GetCDText(i, TextTrackData);
        Writeln(FL, TextTrackDataToString(TextTrackData));
      end else
      if (CDName = 'Pause-Info') and (i > -1) then
      begin
        Writeln(FL, FAudioCD.GetTrackPause(i));
      end;
    end;
    Writeln(FL, '</' + CDName + '>');
  end;

begin
  if (FDataCD.FileCount > 0) or (FAudioCD.TrackCount > 0) or
     (FXCD.FileCount > 0)    or (FDAE.TrackCount > 0)     then
  begin
    AssignFile(FL, Name{ + '.files'});
    Rewrite(FL);
    {Jetzt alle Listen speichern, aber nur, wenn Dateien vorhanden sind.}
    {Daten-CD}
    if FDataCD.FileCount > 0 then
    begin
      CDName := 'Data-CD';
      {erst die Ordner-Struktur speichern}
      SaveCDStrukture;
      {jetzt die Dateilisten speichern}
      SaveCDData;
      Writeln(FL, '');
    end;
    {Audio-CD}
    if FAudioCD.TrackCount > 0 then
    begin
      CDName := 'Audio-CD';
      SaveTrackList;
      Writeln(FL, '');
      {jetzt die CD-Text-Infos}
      if FAudioCD.CDTextPresent then
      begin
        CDName := 'CD-Text';
        SaveTrackInfo;
        Writeln(FL, '');
      end;
      {und noch die benutzerdefinierten Pausen}
      if FAudioCD.TrackPausePresent then
      begin
        CDName := 'Pause-Info';
        SaveTrackInfo;
        Writeln(FL, '');
      end;
    end;
    {XCD}
    if FXCD.FileCount > 0 then
    begin
      CDName := 'XCD';
      {erst die Ordner-Struktur speichern}
      SaveCDStrukture;
      {jetzt die Dateilisten speichern}
      SaveCDData;
      Writeln(FL, '');
    end;
    {DAE, ob das Sinn macht?}
    if FDAE.TrackCount > 0 then
    begin
      CDName := 'DAE';
      SaveTrackList;
      Writeln(FL, '');
    end;
    {Video-CD}
    if FVideoCD.TrackCount > 0 then
    begin
      CDName := 'Video-CD';
      SaveTrackList;
      Writeln(FL, '');
    end;
    CloseFile(FL);
  end;
end;

{ LoadFromFile -----------------------------------------------------------------

  LoadFromFile l�dt die Dateilisten aus einer Text-Datei.                      }

procedure TProjectData.LoadFromFile(const Name: string; var Shared: TShared);
var CDName: string;
    ProjectList: TStringList;
    List: TStringList;

  procedure LoadCDStrukture;
  begin
    List.Clear;
    {Tree-Struktur in Liste suchen}
    if GetSection(ProjectList, List, '<' + CDName + '>',
                                     '</' + CDName + '>') then
    begin
      {jetzt haben wird in List die Struktur des Baums, die von FDataCD bzw.
       FXCD geladen werden kann.}
      if CDName = 'Data-CD' then
      begin
        FDataCD.ImportStructureFromStringList(List);
        Shared.ProgressBarMax := FDataCD.FolderCount;
      end else
      if CDName = 'XCD' then
      begin
        FXCD.ImportStructureFromStringList(List);
        Shared.ProgressBarMax := FXCD.FolderCount;
      end;
      {Jetzt die Dateilisten erzeugen}
      Shared.Panel1 := '<>';
      Shared.Panel2 := FLang.GMS('mpref10');
      UpdatePanels;
      if CDName = 'Data-CD' then
      begin
        FDataCD.CreateFileLists;
      end else
      if CDName = 'XCD' then
      begin
        FXCD.CreateFileLists;
      end;
    end;
  end;

  procedure LoadCDData;
  var i: Integer;
      p: Integer;
      Choice: Integer;
      ErrorCode: Byte;
      Temp: string;
      TargetName: string;
      TargetPath: string;
      SourceName: string;
      SourcePath: string;
  begin
    if CDName = 'Data-CD' then
    begin
      Choice := cDataCD;
    end else
    if CDName = 'XCD' then
    begin
      Choice := cXCD;
    end else
    begin
      Choice := 0;
    end;
    {Pfadliste in Liste suchen}
    List.Clear;
    if GetSection(ProjectList, List, '<' + CDName + '-Files>',
                                     '</' + CDName + '-Files>') then
    begin
      {Dateien einf�gen}
      Shared.ProgressBarMax := List.Count - 1;
      ProgressBarReset;
      for i := 0 to List.Count -1 do
      begin
        Shared.ProgressBarPosition := i;
        ProgressBarUpdate;
        Temp := List[i];
        {den Pfadlisten-Eintrag auseinandernehmen}
        SplitString(Temp, ':', TargetName, SourcePath);
        {TargetName auseinandernehmen}
        p := LastDelimiter('/', TargetName);
        if p > 0 then
        begin
          {Einf�gen in einem Ordner}
          TargetPath := Copy(TargetName, 1, p);
          Delete(TargetName, 1, p);
        end else
        begin
          {Einf�gen in Wurzel}
          TargetPath := '';
        end;
        SourceName := ExtractFileName(SourcePath);
        if (Choice = cXCD) and (Pos('>', SourceName) > 0) then
        begin
          Delete(SourceName, Pos('>', SourceName), 1);
          Delete(SourcePath, Pos('>', SourcePath), 1);
          FXCD.AddAsForm2 := True;
        end;
        {$IFDEF DebugAddFileLoad}
        FormDebug.Memo1.Lines.Add('TargetPath: ' + TargetPath +
                                  '; TargetName: ' + TargetName);
        FormDebug.Memo3.Lines.Add('SourcePath: ' + SourcePath +
                                  '; SourceName: ' + SourceName);
        {$ENDIF}
        AddToPathlist(SourcePath, TargetPath, Choice);
        ErrorCode := GetLastError;
        case ErrorCode of
          PD_FileNotFound   : begin
                                Shared.MessageToShow :=
                                  Format(FLang.GMS('e113'), [SourcePath]);
                                MessageToShow;
                              end;
          PD_FileNotUnique  : begin
                                Shared.MessageToShow :=
                                  Format(FLang.GMS('e112'), [SourcePath]);
                                MessageToShow;
                              end;
        end;
        FXCD.AddAsForm2 := False;
        {TargetName anders als SourceName? Als maximale Dateil�nge nehmen wir
         erst einmal 255 an, da sp�ter sowieso gepr�ft wird.}
        if SourceName <> TargetName then
        begin
          RenameFileByName(TargetPath, SourceName, TargetName, 255, Choice);
        end;
        Application.ProcessMessages;
      end;
    end;
  end;

  procedure LoadTracks;
  var i: Integer;
      Choice: Integer;
      ErrorCode: Byte;
      Temp: string;
  begin
    if CDName = 'Audio-CD' then
    begin
      Choice := cAudioCD;
    end else
    if CDName = 'DAE' then
    begin
      Choice := cDAE;
    end else
    if CDName = 'Video-CD' then
    begin
      Choice := cVideoCD;
    end else
    begin
      Choice := 0;
    end;
    {TreeView-Struktur in Liste suchen}
    List.Clear;
    if GetSection(ProjectList, List, '<' + CDName + '>',
                                     '</' + CDName + '>') then
    begin
      Shared.ProgressBarMax := List.Count - 1;
      ProgressBarReset;
      for i := 0 to List.Count -1 do
      begin
        Shared.ProgressBarPosition := i;
        ProgressBarUpdate;
        Temp := List[i];
        {$IFDEF DebugAddFileLoad}
        FormDebug.Memo1.Lines.Add(IntToStr(Choice) + ' - ' + Temp);
        {$ENDIF}
        case Choice of
          cAudioCD: AddToPathlist(Temp, '', cAudioCD);
          cDAE    : (FDAE.GetTrackList).Add(Temp);
          cVideoCD: AddToPathlist(Temp, '', cVideoCD);
        end;
        {Fehlerbehandlung}
        ErrorCode := GetLastError;
        case ErrorCode of
          PD_InvalidWaveFile: begin
                                Shared.MessageToShow :=
                                  Format(FLang.GMS('eprocs01'), [Temp]);
                                MessageToShow;
                              end;
          PD_InvalidMpegFile: begin
                                Shared.MessageToShow :=
                                  Format(FLang.GMS('eprocs02'), [Temp]);
                                MessageToShow;
                              end;
          PD_FileNotFound   : begin
                                Shared.MessageToShow :=
                                  Format(FLang.GMS('e113'), [Temp]);
                                MessageToShow;
                              end;
        end;
        Application.ProcessMessages;
      end;
    end;
  end;

  procedure LoadTrackInfo;
  var i: Integer;
      TextTrackData: TCDTextTrackData;
  begin
    {TreeView-Struktur in Liste suchen}
    List.Clear;
    if GetSection(ProjectList, List, '<' + CDName + '>',
                                     '</' + CDName + '>') then
    begin
      Shared.ProgressBarMax := List.Count - 1;
      ProgressBarReset;
      for i := 0 to List.Count -1 do
      begin
        Shared.ProgressBarPosition := i;
        ProgressBarUpdate;
        if CDName = 'CD-Text' then
        begin
          StringToTextTrackData(List[i], TextTrackData);
          FAudioCD.SetCDText(i - 1, TextTrackData);
        end else
        if CDName = 'Pause-Info' then
        begin
          FAudioCD.SetTrackPause(i, List[i]);
        end;
        Application.ProcessMessages;
      end;
    end;
  end;

begin
  Shared.Panel1 := Format(FLang.GMS('mpref07'), [Name]);
  Shared.Panel2 := FLang.GMS('mpref08');
  {Event zum Aktualisieren der Panels ausl�sen}
  UpdatePanels;
  {Jetzt die Dateien laden}
  if FileExists(Name{ + '.files'}) then
  begin
    {alle Tree-/List-Views l�schen}
    DeleteAll(cDataCD);
    DeleteAll(cAudioCD);
    DeleteAll(cXCD);
    DeleteAll(cDAE);
    DeleteAll(cVideoCD);
    {Datei mit Pfadangaben komplett in den Speicher laden}
    ProjectList := TStringList.Create;
    List := TStringList.Create;
    ProjectList.LoadFromFile(Name{ + '.files'});
    {Daten-CD: Tree-Struktur laden}
    CDName := 'Data-CD';
    Shared.Panel1 := '<>';
    Shared.Panel2 := FLang.GMS('mpref09');
    UpdatePanels;
    LoadCDStrukture;
    {Daten-CD: Dateien in den Tree laden}
    Shared.Panel1 := '<>';
    Shared.Panel2 := FLang.GMS('mpref11');
    UpdatePanels;
    LoadCDData;

    {Audiotracks laden}
    CDName := 'Audio-CD';
    Shared.Panel1 := '<>';
    Shared.Panel2 := FLang.GMS('mpref12');
    UpdatePanels;
    LoadTracks;
    {CD-Text-Informationen}
    CDName := 'CD-Text';
    LoadTrackInfo;
    {Pausen-Informationen}
    CDName := 'Pause-Info';
    LoadTrackInfo;

    {XCD: Tree-Struktur laden}
    CDName := 'XCD';
    Shared.Panel1 := '<>';
    Shared.Panel2 := FLang.GMS('mpref13');
    UpdatePanels;
    LoadCDStrukture;
    {XCD: Dateien in den Tree laden}
    Shared.Panel1 := '<>';
    Shared.Panel2 := FLang.GMS('mpref14');
    UpdatePanels;
    LoadCDData;

    {Tracks (DAE) laden}
    CDName := 'DAE';
    Shared.Panel1 := '<>';
    Shared.Panel2 := '';
    UpdatePanels;
    LoadTracks;

    {Videotracks laden}
    CDName := 'Video-CD';
    Shared.Panel1 := '<>';
    Shared.Panel2 := FLang.GMS('mpref15');
    UpdatePanels;
    LoadTracks;

    ProjectList.Free;
    List.Free;
  end;
  Shared.Panel1 := '';
  Shared.Panel2 := '';
  UpdatePanels;
  ProgressBarHide;
end;

{ CreateBurnList ---------------------------------------------------------------

  CreateBurnList erzeugt die f�r die Konsolenprogramme n�tigen Pfadlisten.     }

procedure TProjectData.CreateBurnList(List: TStringList; const Choice: Byte);
begin
  case Choice of
    cDataCD : FDataCD.CreateBurnList(List);
    cAudioCD: FAudioCD.CreateBurnList(List);
    cXCD    : FXCD.CreateBurnList(List);
    cVideoCD: FVideoCD.CreateBurnList(List);
  end;
end;

{ CreateVerifyList -------------------------------------------------------------

  CreateVerifyList erzeugt die f�r den Vergleich n�tigen Pfadlisten. Diese
  Prozedure ist n�tig, da die Pfadlisten, die TXCD.CreateBurnList erstellt f�r
  die Verwendung in cl_verifythread.pas ungeeignet sind. Fur Choice = cDataCD
  ist die Liste identisch mit der von CreateBurnList.                          }

procedure TProjectData.CreateVerifyList(List: TStringList; const Choice: Byte);
begin
  case Choice of
    cDataCD  : FDataCD.CreateBurnList(List);
    cXCD     : FXCD.CreateVerifyList(List);
    cDVDVideo: FDVDVideo.CreateBurnList(List);
  end;
end;

{ SetText ----------------------------------------------------------------------

  SetText setzt die CD-Text-Informationen zum Track mit der Nummer (Index + 1).
  Ist Index = -1 (Track 0) werden die Album-Informationen gesetzt.
  Format: Title|Performer                                                      }

procedure TProjectData.SetCDText(const Index: Integer;
                                 TextData: TCDTextTrackData);
begin
  FAudioCD.SetCDText(Index, TextData);
end;

{ GetText ----------------------------------------------------------------------

  GetText liefert den Titel und Interpreten zum Track mit der Nummer (Index + 1)
  zur�ck. F�r Index= -1 werden Titel und Interpret des Album zur�ckgegeben.    }

procedure TProjectData.GetCDText(const Index: Integer;
                                 var TextData: TCDTextTrackData);
begin
  FAudioCD.GetCDText(Index, TextData);
end;

{ CDTextPresent ----------------------------------------------------------------

  liefert True, wenn irgendwelche CD-Text-Informationen vorhanden sind.        }

function TProjectData.CDTextPresent: Boolean;
begin
  Result := FAudioCD.CDTextPresent;
end;

{ CDTextLength -----------------------------------------------------------------

  ermittelt die Anzahl der Bytes, die die formatierten CD-Text-Daten belegen.  }

function TProjectData.CDTextLength: Integer;
begin
  Result := FAudioCD.CDTextLength;
end;

{ CreateCDTextFile -------------------------------------------------------------

  erzeugt aus den CD-Text-Informationen eine bin�re Datei (nach Red Book bzw.
  MMC), die an cdrecord �bergeben werden kann.                                 }

procedure TProjectData.CreateCDTextFile(const Name: string);
begin
  FAudioCD.CreateCDTextFile(Name);
end;

{ TrackPausePresent ------------------------------------------------------------

  liefert True, wenn es benutzerdefinierte Pausen gibt.                        }

function TProjectData.TrackPausePresent: Boolean;
begin
  Result := FAudioCD.TrackPausePresent;
end;

{ GetTrackPause ----------------------------------------------------------------

  liefert die beutzerdefinierte Pause zu Track (Index + 1) zur�ck.             }

function TProjectData.GetTrackPause(const Index: Integer): string;
begin
  Result := FaudioCD.GetTrackPause(Index);
end;

{ SetTrackPause ----------------------------------------------------------------

  setzt die beutzerdefinierte Pause f�r Track (Index + 1) auf Pause.           }

procedure TProjectData.SetTrackPause(const Index: Integer; const Pause: string);
begin
  FAudioCD.SetTrackPause(Index, Pause);
end;

{ SetDVDSourcePath -------------------------------------------------------------

  Quellpfad f�r DVD-Video festlegen.                                           }

procedure TProjectData.SetDVDSourcePath(const Path: string);
begin
  FDVDVideo.SourcePath := Path;
end;


{ sonstige Funktionen/Prozeduren --------------------------------------------- }

{ ExtractFileInfoFromEntry -----------------------------------------------------

  ExtractFileInfoFromEntry trennt den Pfadlisten-Eintrag (Daten-CD, XCD) in
  Ziel-Dateiname, Quell-Dateiname (inkl.Pfad) und Dateilgr��e auf. Eigentlich
  m��te diese Prozedur eine Methode der entsprechenden Pfadlisten-Objekte sein,
  aber der Einfachheit halber wird sie von cl_projectdata.pas zu Verf�gung
  gestellt, damit cl_cd.pas nicht in frm_main.pas eingebunden werden mu�.      }

procedure ExtractFileInfoFromEntry(const Entry: string;
                                   var Name, Path: string;
                                   var Size: {$IFDEF LargeFiles} Comp
                                             {$ELSE} Longint {$ENDIF});
var Temp: string;
begin
  Temp := Entry;
  {Ziel-Name ist alles _vor_ dem ':'}
  Name := StringLeft(Entry, ':');
  {Dateinamen/-pfad extrahieren}
  Path := StringLeft(StringRight(Entry, ':'), '*');
  {Dateigr��e extrahieren}
  Temp := StringRight(Entry, '*');
  if Temp[Length(Temp)] = '>' then
  begin
    Delete(Temp, Length(Temp), 1);
  end;
  {$IFDEF LargeFiles}
  Size := StrToFloatDef(Temp, 0);  
  {$ELSE}
  Size := StrToIntDef(Temp, 0);
  {$ENDIF}
end;

{ ExtractTrackInfoFromEntry ----------------------------------------------------

  trennt den Pfadlisten-Eintrag (Audio-CD) Dateiname, Dateiname (inkl. Pfad),
  Dateigr��e und Trackl�nge.                                                   }

procedure ExtractTrackInfoFromEntry(const Entry: string;
                                    var Name, Path: string;
                                    var Size: {$IFDEF LargeFiles} Comp
                                              {$ELSE} Longint {$ENDIF};
                                    var TrackLength: Extended);
begin
  {Datei-Name ist alles _vor_ dem letzen ':'}
  Path := StringLeft(Entry, '|');
  Name := ExtractFileName(Path);
  {Dateigr��e extrahieren}
  {$IFDEf LargeFiles}
  Size := StrToFloatDef(StringLeft(StringRight(Entry, '|'), '*'), 0);
  {$ELSE}
  Size := StrToIntDef(StringLeft(StringRight(Entry, '|'), '*'), 0);
  {$ENDIF}
  {L�nge der Wave-Datei}
  TrackLength := StrToFloatDef(StringRight(Entry, '*'), 0);
end;

end.
