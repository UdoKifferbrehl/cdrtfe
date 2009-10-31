{ cl_flacinfo.pas: Funktionen für FLAC-Audio-Dateien

  Copyright (c) 2006-2009 Oliver Valencia

  letzte Änderung  31.10.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert im wesentlichen auf Informationen von:
  http://flac.sourceforge.net
  http://xiph.org/ogg/vorbis/doc/v-comment.html

  cl_flacinfo.pas stellt Funktionen für FLAC-Audio-Dateien zur Verfügung.
    * Länge in Sekunden
    * FLAC-Tags


  TFLACFile: Objekt, das die Infos über die Datei enthält

    Properties   FileName
                 LastError
                 Length
                 TagTitle
                 TagArtist
                 TagAlbum
                 TagDate
                 TagComment
                 TagTrack
                 TagGenre
                 Vendor

    Methoden     Create(Name: string)
                 GetInfo

  exportierte Funktionen/Prozeduren:

    x

}

unit cl_flacinfo;

{$I directives.inc}

interface

uses Classes, SysUtils, Windows, dialogs;

const VorbisTagCount = 7;

      VorbisTags: array [1..VorbisTagCount] of string =
        ('TITLE', 'ARTIST', 'ALBUM', 'TRACKNUMBER', 'DATE', 'GENRE', 'COMMENT');

type TFLACInfoError = (FIE_NoError, FIE_FileNotFound, FIE_InvalidFLACFile);

     TMetaDataBlockType = (MDBT_STREAMINFO, MDBT_PADDING, MDBT_APPLICATION,
                           MDBT_SEEKTABLE, MDBT_VORBIS_COMMENT, MDBT_CUESHEET,
                           MDBT_RESERVED, MDBT_INVALID);

     TFLACHeader = array[0..3] of Char;

     TMetaDataBlockHeader = packed record
       BlockType: Byte;
       Length   : array[0..2] of Byte;
     end;

     TMDBStreamInfo = packed record
       MinBlockSize: Word;
       MaxBlockSize: Word;
       MinFrameSize: array[0..2] of Byte;
       MaxFrameSize: array[0..2] of Byte;
       SampleInfo  : array[0..1] of Integer;
       MD5Sum      : array[0..3] of Integer;
     end;

     TStreamInfo = record
       MinBlockSize : Integer;
       MaxBlockSize : Integer;
       MinFrameSize : Integer;
       MaxFrameSize : Integer;
       SampleRate   : Integer;
       Channels     : Byte;
       BitsPerSample: Byte;
       Samples      : Longint;
     end;

     TFLACTags = record
       Title,
       Artist,
       Album,
       Date,
       Comment,
       Genre   : string;
       Track   : Byte;
     end;

     TFLACFile = class(TObject)
     private
       FBlockList : array[MDBT_STREAMINFO..MDBT_INVALID, 1..2] of Integer;  // ..MDBT_CUESHEET
       FFileName  : string;
       FFLACTags  : TFLACTags;
       FLastError : TFLACInfoError;
       FLength    : Extended;
       FOk        : Boolean;
       FStreamInfo: TStreamInfo;
       FVendor    : string;
       function FLACFileIsValid: Boolean;
       function GetLastError: TFLACInfoError;
       function GetMetaDataBlockType(BT: Byte): TMetaDataBlockType;
       function GetMetaDataBlockSize(MDBH: TMetaDataBlockHeader): Integer;
       function IsLastMetaDataBlock(BT: Byte): Boolean;
       procedure GetFLACTags;
       procedure GetStreamInfo;
     public
       constructor Create(const Name: string);
       destructor Destroy; override;
       procedure GetInfo;
       property FileName  : string read FFileName;
       property LastError : TFLACInfoError read GetLastError;
       property Length    : Extended read FLength;
       {Tags}
       property TagTitle  : string read FFLACTags.Title;
       property TagArtist : string read FFLACTags.Artist;
       property TagAlbum  : string read FFLACTags.Album;
       property TagDate   : string read FFLACTags.Date;
       property TagComment: string read FFLACTags.Comment;
       property TagTrack  : Byte read FFLACTags.Track;
       property TagGenre  : string read FFLACTags.Genre;
       property Vendor    : string read FVendor;
     end;

implementation

{ Hilfsfunktionen ------------------------------------------------------------ }

{ ChangeByteOrderInt -----------------------------------------------------------

  kehrt die Byte-Reihenfolge des übergebenen Integer-Wertes (4 Byte) um.       }

function ChangeByteOrderInt(const x: Integer): Integer;
begin
  Result := ((x shr 24) and $FF) or
            ((x shr 8) and $FF00) or
            ((x shl 8) and $FF0000) or
            ((x shl 24)and Integer($FF000000));
end;

{ ChangeByteOrderWord ----------------------------------------------------------

  kehrt die Byte-Reihenfolge des übergebenen Words (2 Byte) um.                }

function ChangeByteOrderWord(const x: Word): Word;
begin
  Result := ((x shr 8) and $FF) or
            ((x shl 8) and $FF00);
end;

{ ByteArrayToInt ---------------------------------------------------------------

  wandelt ein 3-Byte-Array (big-endian) in einen Integer-Wert (little-endian). }

function ByteArrayToInt(ba: array of Byte): Integer;
var i: ^Integer;
    a: array[0..3] of Byte;
begin
  if High(ba) = 2 then
  begin
    a[0] := 0; a[1] := ba[0]; a[2] := ba[1]; a[3] := ba[2];
    i := @a;
    Result := ChangeByteOrderInt(i^);
  end else
    Result := 0;
end;


{ TFLACFile ------------------------------------------------------------------ }

{ TFLACFile - private }

{ GetLastError -----------------------------------------------------------------

  liefert den aktuellen Fehlerzustand und setzt ihn zurück.                    }

function TFLACFile.GetLastError: TFLACInfoError;
begin
  Result := FLastError;
  FLastError := FIE_NoError;
end;

{ GetMetaDataBlockType ---------------------------------------------------------

  bestimmt die Art des Meta-Data-Blocks.                                       }

function TFLACFile.GetMetaDataBlockType(BT: Byte): TMetaDataBlockType;
begin
  BT := BT and $7f;
  case BT of
    0: Result := MDBT_STREAMINFO;
    1: Result := MDBT_PADDING;
    2: Result := MDBT_APPLICATION;
    3: Result := MDBT_SEEKTABLE;
    4: Result := MDBT_VORBIS_COMMENT;
    5: Result := MDBT_CUESHEET;
    6..126: Result := MDBT_RESERVED;
  else
    Result := MDBT_INVALID;
  end;                                       //   ShowMessage('blocktype: '+inttostr(BT));
end;

{ GetMetaDataBlockSize ---------------------------------------------------------

  bestimmt die Größe des Meta-Data-Blocks in Byte.                             }

function TFLACFile.GetMetaDataBlockSize(MDBH: TMetaDataBlockHeader): Integer;
begin
  Result := ByteArrayToInt(MDBH.Length);      //    ShowMessage('blocksize: ' +IntToStr(Result));
end;

{ IsLastMetaDataBlock ----------------------------------------------------------

  True, wenn es der letzte Meta-Data-Block vor den Audio-Daten ist.            }

function TFLACFile.IsLastMetaDataBlock(BT: Byte): Boolean;
begin
  Result := (BT and $80) = $80;           // ShowMessage('islastblock: ' +inttostr((BT and $80)));
end;

{ FLACFileIsValid --------------------------------------------------------------

  FLACFileIsValid prüft, ob es sich um eine gültige FLAC-Datei handelt.        }

function TFLACFile.FLACFileIsValid: Boolean;
var FileIn     : TFileStream;
    FLACHeader : TFLACHeader;
    MDBHeader  : TMetaDataBlockHeader;
    BlockType  : TMetaDataBlockType;
    BlockOffset: Integer;
    BlockSize  : Integer;
begin
  FileIn := nil;
  try
    Result := False;
    FileIn := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    {Datei-Header muß 'fLaC' sein.}
    FileIn.Read(FLACHeader, 4);
    Result := FLACHeader = 'fLaC';
    {Es muß der Stream-Info-Block folgen.}
    FileIn.Read(MDBHeader, SizeOf(MDBHeader));
    BlockType := GetMetaDataBlockType(MDBHeader.BlockType);
    Result := BlockType = MDBT_STREAMINFO;
    {Wenn es der Stream-Info-Block ist, alle Blöcke suchen.}
    if Result then
    begin
      {zurück zum Anfang des Stream-Info-Blocks}
      FileIn.Seek(-SizeOf(MDBHeader), soFromCurrent);
      repeat
        {Header des Blocks lesen}
        FileIn.Read(MDBHeader, SizeOf(MDBHeader));
        BlockOffset := FileIn.Position;
        BlockType := GetMetaDataBlockType(MDBHeader.BlockType);
        BlockSize := GetMetaDataBlockSize(MDBHeader);
        {Offset und Größe des Blocks speichern}
        FBlockList[BlockType, 1] := BlockOffset;
        FBlockList[BlockType, 2] := BlockSize;
        {zum nächsten Block}
        FileIn.Seek(BlockSize, soFromCurrent);
      until IsLastMetaDataBlock(MDBHeader.BlockType);
    end;
  finally
    FileIn.Free;
  end;
end;

{ GetStreamInfo ----------------------------------------------------------------

  liest den Stream-Info-Block und extrahiert die Infos.                        }

procedure TFLACFile.GetStreamInfo;
var FileIn     : TFileStream;
    BlockOffset: Integer;
    BlockSize  : Integer;
    MDBSI      : ^TMDBStreamInfo;
    Buffer     : array[0..33] of Byte;
    Temp       : Integer;
begin
  FileIn := nil;
  BlockOffset := FBlockList[MDBT_STREAMINFO, 1];
  BlockSize := FBlockList[MDBT_STREAMINFO, 2];
  try
    {Stream-Info-Block lesen}
    FileIn := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    FileIn.Seek(BlockOffset, soFromBeginning);
    FileIn.ReadBuffer(Buffer, BlockSize);
    {Stream-Info-Block auswerten}
    MDBSI := @Buffer;
    with FStreamInfo do
    begin
      Temp := ChangeByteOrderInt(MDBSI^.SampleInfo[0]);
      MinBlockSize  := ChangeByteOrderWord(MDBSI^.MinBlockSize);
      MaxBlockSize  := ChangeByteOrderWord(MDBSI^.MaxBlockSize);
      MinFrameSize  := ByteArrayToInt(MDBSI^.MinFrameSize);
      MaxFrameSize  := ByteArrayToInt(MDBSI^.MaxFrameSize);
      SampleRate    := (Temp shr 12) and $1FFFFF;
      Channels      := ((Temp shr 9) and $7) + 1;
      BitsPerSample := ((Temp shr 4) and $1F) + 1;
      {Achtung: Hier werden nur 32 von 36 Bit für die Anzahl der Samples be-
       rücksichtigt. Die restlichen 4 Bits stecken in SampleInfo[0].}
      Samples       := ChangeByteOrderInt(MDBSI.SampleInfo[1]);
      FLength       := Samples/SampleRate; 
    end;
  finally
    FileIn.Free;
  end;
end;

{ GetFLACTags ------------------------------------------------------------------

  liest die Tags aus dem Vorbis-Comment-Block.                                 }

procedure TFLACFile.GetFLACTags;
var FileIn     : TFileStream;
    BlockOffset: Integer;
    TagCount   : Integer;
    i          : Integer;
    TagList    : array[1..VorbisTagCount] of string;

    function GetTag: string;
    var Tag      : PChar;
        TagLength: Integer;
    begin
      FileIn.Read(TagLength, 4);
      GetMem(Tag, TagLength + 1);
      FillChar(Tag^, TagLength + 1, 0);
      FileIn.Read(Tag^, TagLength);
      Result := string(Tag);
      FreeMem(Tag);
    end;

    procedure GetTagData(const s: string);
    var p, i          : Integer;
        TagID, TagData: string;
    begin
      TagData := s;
      p := Pos('=', TagData);
      TagID := Copy(s, 1, p - 1);
      Delete(TagData, 1, p);
      for i := 1 to VorbisTagCount do
        if UpperCase(TagID) = VorbisTags[i] then TagList[i] := TagData;
    end;

    procedure SetTagProperties;
    begin
      FFLACTags.Title   := TagList[1];
      FFLACTags.Artist  := TagList[2];
      FFLACTags.Album   := TagList[3];
      FFLACTags.Track   := StrToIntDef(TagList[4], 0);
      FFLACTags.Date    := TagList[5];
      FFLACTags.Genre   := TagList[6];
      FFLACTags.Comment := TagList[7];
    end;

begin
  FileIn := nil;
  BlockOffset := FBlockList[MDBT_VORBIS_COMMENT, 1];
  try
    FileIn := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
    FileIn.Seek(BlockOffset, soFromBeginning);
    {Vendor-Info}
    FVendor := GetTag;
    {Tags}
    FileIn.Read(TagCount, 4);
    for i := 1 to TagCount do
    begin
      GetTagData(GetTag);
    end;
    SetTagProperties;
  finally
    FileIn.Free;
  end;
end;

{ TFLACFile - public }

constructor TFLACFile.Create(const Name: string);
begin
  inherited Create;
  ZeroMemory(@FBlockList, SizeOf(FBlockList));
  FLength := 0;
  if FileExists(Name) then
  begin
    FLastError := FIE_NoError;
    FOk        := True;
    FFileName  := Name;
  end else
  begin
    FLastError := FIE_FileNotFound;
    FOk        := False;
    FFileName  := '';
  end;
end;

destructor TFLACFile.Destroy;
begin
  inherited Destroy;
end;

{ GetInfo ----------------------------------------------------------------------

  GetInfo sammelt die Informationen über die MPEG-Audio-Datei.                 }

procedure TFLACFile.GetInfo;
begin
  if FOk then
  begin
    if FLACFileIsValid then
    begin
      GetStreamInfo;
      GetFLACTags;
    end else
    begin
      FLastError := FIE_InvalidFLACFile;
    end;
  end else
  begin
    FLastError := FIE_FileNotFound;
  end;
end;

end.
