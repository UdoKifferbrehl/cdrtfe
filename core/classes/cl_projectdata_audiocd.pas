{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_projectdata_audiocd.pas: Datentypen zur Speicherung der Pfadlisten

  Copyright (c) 2004-2015 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.05.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_projectdata_audiocd.pas implementiert das Objekt, in dem die zu dem Projekt
  Audio-CD hinzugefügten Dateien gespeichert werden.


  TAudioCD

    Properties   CDTextLength
                 CDTextPresent
                 CDTime
                 LastError
                 CompressedFilesPresent
                 TrackCount
                 TrackPausePresent
                 AcceptMP3
                 AcceptOgg
                 AcceptFLAC
                 AcceptApe

    Methoden     AddTrack(const Name: string)
                 Create
                 CreateBurnList(List: TStringList)
                 CreateCDTextFile(const Name: string)
                 DeleteAll
                 DeleteTrack(const Index: Integer)
                 GetCDText(const Index: Integer; var Title, Performer: string)
                 GetFileList: TStringList
                 GetTrackPause(const Index: Integer): string;
                 MoveTrack(const Index: Integer; const Direction: TDirection)
                 SetCDText(const Index: Integer; const Title, Performer: string)
                 SetTrackPause(const Index: Integer; const Pause: string)
                 SortTracks

}

unit cl_projectdata_audiocd;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils, f_cdtext, const_core, userevents;

type TAudioCD = class(TObject)
     private
       FAcceptMP3: Boolean;
       FAcceptOgg: Boolean;
       FAcceptFLAC: Boolean;
       FAcceptApe: Boolean;
       FRelaxedFormatChecking: Boolean;
       FCDTime: Extended;
       FCDTimeChanged: Boolean;
       FError: Byte;
       FTrackCount: Integer;
       FTrackCountChanged: Boolean;
       FTrackList: TStringList;
       FTextInfo: TStringList;
       FPauseInfo: TStringList;
       FAlbumTitle: string;
       FAlbumPerformer: string;
       FAlbumSongwriter: string;
       FAlbumComposer: string;
       FAlbumArranger: string;
       FAlbumTextMessage: string;
       FOnProjectError: TProjectErrorEvent;
       function ExtractTimeFromEntry(const Entry: string): Extended;
       function GetLastError: Byte;
       function GetCDTextLength: Integer;
       function GetCDTextPresent: Boolean;
       function GetCDTime: Extended;
       function GetCompressedFilesPresent: Boolean;
       function GetTrackCount: Integer;
       function GetTrackPausePresent: Boolean;
       procedure AddPlaylist(const Name: string);
       procedure ExportText(CDTextData: TStringList);
       {Events}
       procedure ProjectError(const ErrorCode: Byte; const Name: string);
     public
       constructor Create;
       destructor Destroy; override;
       function GetFileList: TStringList;
       function GetCDTextList: TStringList;
       function GetTrackPause(const Index: Integer): string;
       procedure AddTrack(const Name: string);
       procedure CreateBurnList(List: TStringList);
       procedure CreateCDTextFile(const Name: string);
       procedure DeleteAll;
       procedure DeleteTrack(const Index: Integer);
       procedure GetCDText(const Index: Integer; var TextData: TCDTextTrackData);
       procedure MoveTrack(const Index: Integer; const Direction: TDirection);
       procedure SetCDText(const Index: Integer; TextData: TCDTextTrackData);
       procedure SetTrackPause(const Index: Integer; const Pause: string);
       procedure SortTracks;
       property AcceptMP3: Boolean read FAcceptMP3 write FAcceptMP3;
       property AcceptOgg: Boolean read FAcceptOgg write FAcceptOgg;
       property AcceptFLAC: Boolean read FAcceptFLAC write FAcceptFLAC;
       property AcceptApe: Boolean read FAcceptApe write FAcceptApe;
       property RelaxedFormatChecking: Boolean read FRelaxedFormatChecking write FRelaxedFormatChecking;
       property CDTextLength: Integer  read GetCDTextLength;
       property CDTextPresent: Boolean read GetCDTextPresent;
       property CDTime: Extended read GetCDTime;
       property LastError: Byte read GetLastError;
       property CompresedFilesPresent: Boolean read GetCompressedFilesPresent;
       property TrackCount: Integer read GetTrackCount;
       property TrackPausePresent: Boolean read GetTrackPausePresent;
       {Events}
       property OnProjectError: TProjectErrorEvent read FOnProjectError write FOnProjectError;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     atl_oggvorbis,
     f_filesystem, f_strings, cl_mpeginfo, cl_flacinfo, f_wininfo,
     cl_apeinfo, f_wavefiles, const_common;

{ TAudioCD ------------------------------------------------------------------- }

{ TAudioCD - private }

{ ProjectError -----------------------------------------------------------------

  ProjectError löst ein Event aus, das vom Hauptfenster behandelt werden kann.
  Dies ist nötig, um Fehlermeldunge beim Einlesen einer Playlist nach außen zu
  geben.                                                                       }

procedure TAudioCD.ProjectError(const ErrorCode: Byte; const Name: string);
begin
  if Assigned(FOnProjectError) then FOnProjectError(ErrorCode, Name);
end;

{ GetLastError -----------------------------------------------------------------

  GetLastError gibt den Fehlercode aus FError und setzt FError auf No_Error.   }

function TAudioCD.GetLastError: Byte;
begin
  Result := FError;
  FError := CD_NoError;
end;

{ GetCDTime --------------------------------------------------------------------

  GetCDTime gibt die Gesamtspielzeit zurück.                                   }

function TAudioCD.GetCDTime: Extended;
var Time: Extended;
    i: Integer;
begin
  if FCDTimeChanged then
  begin
    {$IFDEF DebugUpdateGauges}
    FormDebug.Memo3.Lines.Add('CDTime invalid');
    {$ENDIF}
    Time := 0;
    for i := 0 to FTrackList.Count - 1 do
    begin
      Time := Time + ExtractTimeFromEntry(FTrackList[i]);
    end;
    FCDTime := Time;
    Result := FCDTime;
    FCDTimeChanged := False;
  end else
  begin
    Result := FCDTime;
  end;
end;

{ GetTrackCount ----------------------------------------------------------------

  GetTrackCount gibt die Anzahl der Tracks zurück.                             }

function TAudioCD.GetTrackCount: Integer;
begin
  if FTrackCountChanged then
  begin
    {$IFDEF DebugUpdateGauges}
    FormDebug.Memo3.Lines.Add('TrackCount invalid');
    {$ENDIF}
    FTrackCount := FTrackList.Count;
    Result := FTrackCount;
    FTrackCountChanged := False;
  end else
  begin
    Result := FTrackCount;
  end;
end;

{ GetCompressedFilesPresent ----------------------------------------------------

  True, wenn komprimierte Audio-Dateien in der Auswahl vorhanden sind.         }

function TAudioCD.GetCompressedFilesPresent: Boolean;
var i       : Integer;
    List    : TStringList;
    Ext     : string;
begin
  Result := False;
  List := TStringList.Create;
  CreateBurnList(List);
  for i := 0 to List.Count - 1 do
  begin
    Ext := LowerCase(ExtractFileExt(List[i]));
    Result := Result or (Ext = cExtMP3)
                     or (Ext = cExtOgg)
                     or (Ext = cExtFlac)
                     or (Ext = cExtApe);
  end;
  List.Free;
end;

{ ExtractTimeFromEntry ---------------------------------------------------------

  ExtractTimeFromEntry gibt die Tracklänge in Sekunden zurück.                 }

function TAudioCD.ExtractTimeFromEntry(const Entry: string): Extended;
begin
  Result := StrToFloatDef(StringRight(Entry, '*'), 0);
end;

{ GetCDTextPresent -------------------------------------------------------------

  prüft, ob CD-Text-Informationen vorhanden sind.                              }

function TAudioCD.GetCDTextPresent: Boolean;
var i: Integer;
    TrackData: TCDTextTrackData;
begin
  Result := False;
  for i := -1 to FTextInfo.Count - 1 do
  begin
    GetCDText(i, TrackData);
    with TrackData do
      Result := Result or ((Title <> '') or (Performer <> '') or
                           (Songwriter <> '') or (Composer <> '') or
                           (Arranger <> '') or (TextMessage <> ''));
  end;
end;

{ GetCDTextLength --------------------------------------------------------------

  ermittelt die Länge der formatierten CD-Text-Daten.                          }

function TAudioCD.GetCDTextLength: Integer;
var i: Integer;
    L: array[0..5] of Integer;
    TrackData: TCDTextTrackData;
begin
  Result := 0;
  for i := 0 to 5 do L[i] := 0;
  for i := -1 to FTextInfo.Count - 1 do
  begin
    GetCDText(i, TrackData);
    with TrackData do
    begin
      L[0] := L[0] + Length(Title) + 1;
      L[1] := L[1] + Length(Performer) + 1;
      L[2] := L[2] + Length(Songwriter) + 1;
      L[3] := L[3] + Length(Composer) + 1;
      L[4] := L[4] + Length(Arranger) + 1;
      L[5] := L[5] + Length(TextMessage) + 1;
    end;
  end;
  for i := 0 to 5 do
  begin
    {wenn für einen Pack-Type keine Daten vorhanden sind, Länge auf Null setzen}
    if L[i] = FTextInfo.Count + 1 then L[i] := 0;
    if L[i] > 0 then
    begin
      Result := Result + (L[i] div 12) * 12;
      if L[i] mod 12 > 0 then Result := Result + 12;
    end;
  end;
end;

{ GetTrackPausePresent ---------------------------------------------------------

  prüft, ob Pausen-Informationen für die Tracks vorhanden sind.                }

function TAudioCD.GetTrackPausePresent: Boolean;
var i: Integer;
begin
  Result := False;
  for i := 0 to FPauseInfo.Count - 1 do
  begin
    Result := Result or (GetTrackPause(i) <> '');
  end;
end;

{ AddPlaylist ------------------------------------------------------------------

  AddPlaylist fügt alle Titel aus der Playlist <Name> zum Projekt hinzu, sofern
  das Dateiformat unterstützt wird.                                            }

procedure TAudioCD.AddPlaylist(const Name: string);
var List     : TStringList;
    i        : Integer;
    ErrorCode: Byte;
    Path     : string;
    Drive    : string;
    TrackName: string;
begin
  Path := ExtractFilePath(Name);
  Drive := ExtractFileDrive(Name);
  List := TStringList.Create;
  List.LoadFromFile(Name);
  for i := 0 to List.Count - 1 do
  begin
    if Pos('#', List[i]) <> 1 then
    begin
      TrackName := List[i];
      {relativer Pfad?}
      if ExtractFileDrive(TrackName) = '' then
      begin
        if TrackName[1] = '\' then
        begin
          {Pfad relativ zum Laufwerk der Playliste}
          TrackName := Drive + TrackName;
        end else
        begin
          {Pfad relativ zur Playliste}
          TrackName := Path + TrackName;
        end;
      end;
      AddTrack(TrackName);
      ErrorCode := GetLastError;
      if ErrorCode <> CD_NoError then ProjectError(ErrorCode, TrackName);
    end;
  end;
  List.Free
end;

{ ExportText -------------------------------------------------------------------

  ExportText liefert die CD-Text-Daten in zwei String-Listen zurück.           }

procedure TAudioCD.ExportText(CDTextData: TStringList);
var i: Integer;
    TextTrackData: TCDTextTrackData;
begin
  {Die Album-Infos als Daten für Track 0 hinzufügen}
  with TextTrackData do
  begin
    Title := FAlbumTitle;
    Performer := FAlbumPerformer;
    Songwriter :=  FAlbumSongwriter;
    Composer := FAlbumComposer;
    Arranger := FAlbumArranger;
    TextMessage := FAlbumTextMessage;
  end;
  CDTextData.Add(TextTrackDataToString(TextTrackData));
  for i := 0 to FTextInfo.Count - 1 do
  begin
    CDTextData.Add(FTextInfo[i]);
  end;
end;

{ TAudioCD - public }

constructor TAudioCD.Create;
begin
  inherited Create;
  FTrackList := TStringList.Create;
  FTextInfo := TStringList.Create;
  FPauseInfo := TStringList.Create;
  FAlbumTitle := '';
  FAlbumPerformer := '';
  FAlbumSongwriter := '';
  FAlbumComposer := '';
  FAlbumArranger := '';
  FAlbumTextMessage := '';
  FError := CD_NoError;
  FTrackCount := 0;
  FTrackCountChanged := False;
  FCDTime := 0;
  FCDTimeChanged := False;
  FAcceptMP3 := True;
  FAcceptOgg := True;
  FAcceptFLAC := True;
  FAcceptApe := True;
end;

destructor TAudioCD.Destroy;
begin
  FTrackList.Free;
  FTextInfo.Free;
  FPauseInfo.Free;
  inherited Destroy;
end;

{ AddTrack ---------------------------------------------------------------------

  AddTrack fügt die Audio-Datei Name in die TrackList ein.

  Pfadlisten-Eintrag: <Quellpfad>|<Größe in Bytes>*<Länge in Sekunden>         }

procedure TAudioCD.AddTrack(const Name: string);
var Size              : Int64;
    TrackLength       : Extended;
    Temp, CDText      : string;
    CDTextArgs        : TAutoCDText;
    Ok, Wave, MP3,
    Ogg, FLAC, Ape,
    M3u               : Boolean;
    MPEGFile          : TMPEGFile;
    OggFile           : TOggVorbis;
    FLACFile          : TFLACFile;
    ApeFile           : TApeFile;
begin
  if FileExists(Name) then
  begin
    Wave := LowerCase(ExtractFileExt(Name)) = cExtWav;
    MP3  := LowerCase(ExtractFileExt(Name)) = cExtMP3;
    Ogg  := LowerCase(ExtractFileExt(Name)) = cExtOgg;
    FLAC := LowerCase(ExtractFileExt(Name)) = cExtFlac;
    Ape  := LowerCase(ExtractFileExt(Name)) = cExtApe;
    M3u  := LowerCase(ExtractFileExt(Name)) = cExtM3u;
    Ok := False;
    Size := GetFileSize(Name);
    TrackLength := 0;
    CDText := '|||||';
    if Wave then
    begin
      if WaveIsValid(Name) then
      begin
        TrackLength := GetWaveLength(Name);
        CDTextArgs.Title := '';
        CDTextArgs.Performer :='';
        CDTextArgs.FileName := Name;
        CDTextArgs.IsWave := Wave;
        CDText := AutoCDText(CDTextArgs);
        Ok := True;
      end else
      begin
        FError := CD_InvalidWaveFile;
      end;
    end else
    if MP3 then
    begin
      if FAcceptMP3 then
      begin
        {Bestimmung der Länge könnte etwas dauern}
        Application.ProcessMessages;
        MPEGFile := TMPEGFile.Create(Name);
        MPEGFile.GetInfo;
        TrackLength := MPEGFile.Length;
        CDTextArgs.Title := MPEGFile.TagTitle;
        CDTextArgs.Performer := MPEGFile.TagArtist;
        CDTextArgs.FileName := Name;
        CDTextArgs.IsWave := Wave;
        CDText := AutoCDText(CDTextArgs);
        MPEGFile.Free;
        Ok := TrackLength > 0;
        if not Ok then
        begin
          FError := CD_InvalidMP3File;
        end;
      end else
      begin
        FError := CD_NoMP3Support;
      end;
    end;
    if Ogg then
    begin
      if FAcceptOgg then
      begin
        {Bestimmung der Länge könnte etwas dauern}
        Application.ProcessMessages;
        OggFile := TOggVorbis.Create;
        if OggFile.ReadFromFile(Name) then
        begin
          if OggFile.Valid then
          begin
            TrackLength := StrToInt(FormatFloat('0', OggFile.Duration));
            CDTextArgs.Title := Trim(OggFile.Title);
            CDTextArgs.Performer := Trim(OggFile.Artist);
            CDTextArgs.FileName := Name;
            CDTextArgs.IsWave := Wave;
            CDText := AutoCDText(CDTextArgs);
          end;
        end;
        Ok := (OggFile.SampleRate = 44100) and (Oggfile.ChannelModeID = 2) and
              (TrackLength > 0);
        OggFile.Free;
        if not Ok then
        begin
          FError := CD_InvalidOggFile;
        end;
      end else
      begin
        FError := CD_NoOggSupport;
      end;
    end else
    if FLAC then
    begin
      if FAcceptFLAC then
      begin
        {Bestimmung der Länge könnte etwas dauern}
        Application.ProcessMessages;
        FLACFile := TFLACFile.Create(Name);
        FLACFile.GetInfo;
        TrackLength := FLACFile.Length;
        CDTextArgs.Title := FLACFile.TagTitle;
        CDTextArgs.Performer := FLACFile.TagArtist;
        CDTextArgs.FileName := Name;
        CDTextArgs.IsWave := Wave;
        CDText := AutoCDText(CDTextArgs);
        Ok := (FLACFile.IsCDFormat or FRelaxedFormatChecking) and
              (TrackLength > 0);
        FLACFile.Free;
        if not Ok then
        begin
          FError := CD_InvalidFLACFile;
        end;
      end else
      begin
        FError := CD_NoFLACSupport;
      end;
    end else
    if Ape then
    begin
      if FAcceptApe then
      begin
        {Bestimmung der Länge könnte etwas dauern}
        Application.ProcessMessages;
        ApeFile := TApeFile.Create(Name);
        ApeFile.GetInfo;
        TrackLength := ApeFile.Length;
        CDTextArgs.Title := ''; //ApeFile.TagTitle;
        CDTextArgs.Performer := ''; //ApeFile.TagArtist;
        CDTextArgs.FileName := Name;
        CDTextArgs.IsWave := Wave;
        CDText := AutoCDText(CDTextArgs);
        Ok := (ApeFile.SampleRate = 44100) and (ApeFile.Channels = 2) and
              (ApeFile.Bits = 16) and (TrackLength > 0);
        ApeFile.Free;
        if not Ok then
        begin
          FError := CD_InvalidApeFile;
        end;
      end else
      begin
        FError := CD_NoApeSupport;
      end;
    end;
    if Ok then
    begin
      Temp := Name + '|' + FloatToStr(Size) + '*' +  FloatToStr(TrackLength);
      FTrackList.Add(Temp);
      FTextInfo.Add(CDText);                  // Eintrag für CD-Text
      FPauseInfo.Add('');                 // leerer Eintrag für Pausen-Info
      FTrackCountChanged := True;
      FCDTimeChanged := True;
    end;
    if M3u then AddPlaylist(Name);
  end else
  begin
    FError := CD_FileNotFound;
  end;
end;

{ GetFileList ------------------------------------------------------------------

  GetFileList gibt eine Referenz auf die interne TrackListe zurück.            }

function TAudioCD.GetFileList: TStringList;
begin
  Result := FTrackList;
end;

{ GetCDTextList ----------------------------------------------------------------

  GetCDTextList gibt eine Referenz auf die interne Liste mit den CD-Text-
  Informationen zurück.                                                        }

function TAudioCD.GetCDTextList: TStringList;
begin
  Result := FTextInfo;
end;

{ MoveTrack --------------------------------------------------------------------

  MoveTrack verschiebt einen Audio-Track um eine Position nach oben bzw. unten.}

procedure TAudioCD.MoveTrack(const Index: Integer; const Direction: TDirection);
begin
  if Direction = dUp then
  begin
    if Index > 0 then
    begin
      FTrackList.Exchange(Index, Index - 1);
      FTextInfo.Exchange(Index, Index - 1);
      FPauseInfo.Exchange(Index, Index - 1);
    end;
  end else
  if Direction = dDown then
  begin
    if Index < FTrackList.Count - 1 then
    begin
      FTrackList.Exchange(Index, Index + 1);
      FTextInfo.Exchange(Index, Index + 1);
      FPauseInfo.Exchange(Index, Index + 1);
    end;
  end;
end;

{ DeleteTrack ------------------------------------------------------------------

  DeleteTrack entfernt den (Index + 1)-ten Track aus der Liste.                }

procedure TAudioCD.DeleteTrack(const Index: Integer);
begin
  FTrackList.Delete(Index);          // Track löschen
  FTextInfo.Delete(Index);           // Textinformation löschen
  FPauseInfo.Delete(Index);          // Pausen-Information löschen
  FTrackCountChanged := True;
  FCDTimeChanged := True;
end;

{ CreateBurnList ---------------------------------------------------------------

  CreateBurnList erzeugt die Pfadliste mit den zu schreibenden Tracks.         }

procedure TAudioCD.CreateBurnList(List: TStringList);
var i: Integer;
begin
  for i := 0 to FTrackList.Count - 1 do
  begin
    List.Add(StringLeft(FTrackList[i], '|'));
  end;
end;

{ SetText ----------------------------------------------------------------------

  SetText setzt die CD-Text-Informationen zum Track mit der Nummer (Index + 1).
  Ist Index = -1 (Track 0) werden die Album-Informationen gesetzt.
  Format: <Title>|<Performer>|<Songwriter>|<Composer>|<Arranger>|<Message>     }

procedure TAudioCD.SetCDText(const Index: Integer; TextData: TCDTextTrackData);
begin
  if Index < FTextInfo.Count then
  begin
    if Index = -1 then
    begin
      with TextData do
      begin
        FAlbumTitle := Title;
        FAlbumPerformer := Performer;
        FAlbumSongwriter := Songwriter;
        FAlbumComposer := Composer;
        FAlbumArranger := Arranger;
        FAlbumTextMessage := TextMessage;
      end;
    end else
    begin
      FTextInfo[Index] := TextTrackDataToString(TextData);
    end;
  end;
end;

{ GetText ----------------------------------------------------------------------

  GetText liefert den Titel und Interpreten zum Track mit der Nummer (Index + 1)
  zurück. Für Index = -1 werden Titel und Interpret des Album zurückgegeben.   }

procedure TAudioCD.GetCDText(const Index: Integer;
                             var TextData: TCDTextTrackData);
begin
  with TextData do
  begin
    if Index = -1 then
    begin
      Title := FAlbumTitle;
      Performer := FAlbumPerformer;
      Songwriter :=  FAlbumSongwriter;
      Composer := FAlbumComposer;
      Arranger := FAlbumArranger;
      TextMessage := FAlbumTextMessage;
    end else
    begin
      StringToTextTrackData(FTextInfo[Index], TextData);
    end;
  end;
end;

{ CreateCDTextFile -------------------------------------------------------------

  erzeugt aus den CD-Text-Informationen eine binäre Datei (nach Red Book bzw.
  MMC), die an cdrecord übergeben werden kann.                                 }

procedure TAudioCD.CreateCDTextFile(const Name: string);
var CDTextData: TStringList;
begin
  CDTextData := TStringList.Create;
  ExportText(CDTextData);
  f_cdtext.CreateCDTextFile(Name, CDTextData);
  CDTextData.Free;
end;

{ SetTrackPause ----------------------------------------------------------------

  SetTrackPause setzt die Länge der Pause des (Index + 1)-ten Tracks.          }

procedure TAudioCD.SetTrackPause(const Index: Integer; const Pause: string);
begin
  if Index < FTextInfo.Count then
  begin
      FPauseInfo[Index] := Pause;
  end;
end;

{ GetTrackPause ----------------------------------------------------------------

  GetTrackPause liefert die Pauseninformation des (Index + 1)-ten Tracks.      }

function TAudioCD.GetTrackPause(const Index: Integer): string;
begin
  Result := FPauseInfo[Index];
end;

{ DeleteAll --------------------------------------------------------------------

  Alle Datei- und Info-Listen löschen.                                         }

procedure TAudioCD.DeleteAll;
begin
  FTrackList.Clear;
  FTextInfo.Clear;
  FPauseInfo.Clear;
  FAlbumTitle := '';
  FAlbumPerformer := '';
  FAlbumSongwriter := '';
  FAlbumComposer := '';
  FAlbumArranger := '';
  FAlbumTextMessage := '';
  FTrackCount := 0;
  FCDTime := 0;
end;

{ SortTracks -------------------------------------------------------------------

  sortiert die Trackliste nach den Dateinamen.                                 }

procedure TAudioCD.SortTracks;
var NameList: TStringList;
    i       : Integer;

  procedure AddSortPrefixToList(List: TStringList);
  var Index: Integer;
  begin
    for Index := 0 to List.Count - 1 do
    begin
      List[Index] := NameList[Index] + '>' + List[Index];
    end;
  end;

  procedure RemoveSortPrefixToList(List: TStringList);
  var Index: Integer;
      Temp : string;
  begin
    for Index := 0 to List.Count - 1 do
    begin
      Temp := List[Index];
      Delete(Temp, 1, Pos('>', Temp));
      List[Index] := Temp;
    end;
  end;

begin
  NameList := TStringList.Create;
  for i := 0 to FTrackList.Count - 1 do
  begin
    NameList.Add(
      ChangeFileExt(ExtractFileName(StringLeft(FTrackList[i], '|')), ''));
  end;
  AddSortPrefixToList(FTrackList);
  AddSortPrefixToList(FTextInfo);
  AddSortPrefixToList(FPauseInfo);
  NameList.Free;
  FTrackList.Sort;
  FTextInfo.Sort;
  FPauseInfo.Sort;
  RemoveSortPrefixToList(FTrackList);
  RemoveSortPrefixToList(FTextInfo);
  RemoveSortPrefixToList(FPauseInfo);
end;

end.
