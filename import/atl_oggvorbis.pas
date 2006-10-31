{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TOggVorbis - for extracting information from Ogg Vorbis file header   }
{                                                                             }
{ Copyright (c) 2001 by Jurgen Faul                                           }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.1 (21 October 2001)                                               }
{   - Support for UTF-8                                                       }
{   - Fixed bug with vendor info detection                                    }
{                                                                             }
{ Version 1.0 (15 August 2001)                                                }
{   - File info: file size, channel mode, sample rate, duration, bit rate     }
{   - Tag info: title, artist, album, track, date, genre, comment, vendor     }
{                                                                             }
{ *************************************************************************** }

unit atl_oggvorbis;

{$I directives.inc}

interface

uses
  Classes, SysUtils;

const
  { Used with ChannelModeID property }
  VORBIS_CM_MONO = 1;                                    { Code for mono mode }
  VORBIS_CM_STEREO = 2;                                { Code for stereo mode }

  { Channel mode names }
  VORBIS_MODE: array [0..2] of string = ('Unknown', 'Mono', 'Stereo');

type
  { Class TOggVorbis }
  TOggVorbis = class(TObject)
    private
      { Private declarations }
      FValid: Boolean;
      FFileSize: Cardinal;
      FChannelModeID: Byte;
      FSampleRate: Word;
      FBitRateNominal: Word;
      FSampleNumber: Cardinal;
      FTitle: string;
      FArtist: string;
      FAlbum: string;
      FTrack: Byte;
      FDate: string;
      FGenre: string;
      FComment: string;
      FVendor: string;
      procedure FResetData;
      function FGetChannelMode: string;
      function FGetDuration: Double;
      function FGetBitRate: Word;
      function FIsCorrupted: Boolean;
    public
      { Public declarations }
      constructor Create;                                     { Create object }
      function ReadFromFile(const FileName: string): Boolean;   { Load header }
      property Valid: Boolean read FValid;             { True if header valid }
      property FileSize: Cardinal read FFileSize;         { File size (bytes) }
      property ChannelModeID: Byte read FChannelModeID;   { Channel mode code }
      property ChannelMode: string read FGetChannelMode;  { Channel mode name }
      property SampleRate: Word read FSampleRate;          { Sample rate (hz) }
      property Title: string read FTitle;                        { Song title }
      property Artist: string read FArtist;                     { Artist name }
      property Album: string read FAlbum;                        { Album name }
      property Track: Byte read FTrack;                        { Track number }
      property Date: string read FDate;                                { Year }
      property Genre: string read FGenre;                        { Genre name }
      property Comment: string read FComment;                       { Comment }
      property Vendor: string read FVendor;                   { Vendor string }
      property Duration: Double read FGetDuration;       { Duration (seconds) }
      property BitRate: Word read FGetBitRate;             { Average bit rate }
      property Corrupted: Boolean read FIsCorrupted; { True if file corrupted }
  end;

implementation

const
  { Max. number of supported comment fields }
  VORBIS_FIELD_COUNT = 7;

  { Names of supported comment fields }
  VORBIS_FIELD: array [1..VORBIS_FIELD_COUNT] of string =
    ('TITLE', 'ARTIST', 'ALBUM', 'TRACKNUMBER', 'DATE', 'GENRE', 'COMMENT');

type
  { File header data - for internal use }
  HeaderInfo = record
    { Real structure of parameter header packet }
    ID: array [1..7] of Char;                          { Always #1 + "vorbis" }
    BitstreamVersion: array [1..4] of Byte;        { Bitstream version number }
    ChannelMode: Byte;                                   { Number of channels }
    SampleRate: Cardinal;                                  { Sample rate (hz) }
    BitRateMaximal: Cardinal;                          { Bit rate upper limit }
    BitRateNominal: Cardinal;                              { Nominal bit rate }
    BitRateMinimal: Cardinal;                          { Bit rate lower limit }
    BlockSize: Byte;                   { Coded size for small and long blocks }
    StopFlag: Byte;                                                { Always 1 }
    { Extended data }
    FileSize: Cardinal;                                   { File size (bytes) }
    Tag: array [0..VORBIS_FIELD_COUNT] of string;           { Tag information }
  end;

{ ********************* Auxiliary functions & procedures ******************** }

function ReadHeader(const FileName: string; var Header: HeaderInfo): Boolean;
var
  SourceFile: file;
  Transferred: Integer;
begin
  try
    Result := true;
    { Set read-access and open file }
    AssignFile(SourceFile, FileName);
    FileMode := 0;
    Reset(SourceFile, 1);
    Seek(SourceFile, 28);
    { Read parameter header and get file size }
    BlockRead(SourceFile, Header, 30, Transferred);
    Header.FileSize := FileSize(SourceFile);
    CloseFile(SourceFile);
    { if transfer is not complete }
    if Transferred < 30 then Result := false;
  except
    { Error }
    Result := false;
  end;
end;

{ --------------------------------------------------------------------------- }

function GetChannelModeID(const Header: HeaderInfo): Byte;
begin
  { Extract channel mode from header }
  Result := 0;
  if Header.ChannelMode in [VORBIS_CM_MONO, VORBIS_CM_STEREO] then
    Result := Header.ChannelMode;
end;

{ --------------------------------------------------------------------------- }

function GetSampleRate(const Header: HeaderInfo): Word;
begin
  { Extract sample rate from header }
  Result := 0;
  if (Header.SampleRate >= 8000) or (Header.SampleRate <= 48000) then
    Result := Header.SampleRate;
end;

{ --------------------------------------------------------------------------- }

function GetBitRateNominal(const Header: HeaderInfo): Word;
begin
  { Extract nominal bit rate from header }
  Result := Header.BitRateNominal div 1000;
  if (Result < 16) and (Result > 350) then Result := 0;
end;

{ --------------------------------------------------------------------------- }

function GetTagPosition(const Data: array of Char): Byte;
var
  Iterator: Integer;
begin
  { Get first byte of tag info }
  Result := 0;
  for Iterator := 0 to SizeOf(Data) - 7 do
    if (Data[Iterator] = #3) and
      (Data[Iterator + 1] = 'v') and
      (Data[Iterator + 2] = 'o') and
      (Data[Iterator + 3] = 'r') and
      (Data[Iterator + 4] = 'b') and
      (Data[Iterator + 5] = 'i') and
      (Data[Iterator + 6] = 's') then
    begin
      Result := Iterator + 7;
      break;
    end;
end;

{ --------------------------------------------------------------------------- }

procedure SetTagItem(Data: string; var Header: HeaderInfo);
var
  Mark, Iterator: Byte;
  FieldID, FieldData: string;
begin
  { Set tag item if supported comment field found }
  Mark := Pos('=', Data);
  if Mark > 0 then
  begin
    FieldID := UpperCase(Copy(Data, 1, Mark - 1));
    FieldData := Copy(Data, Mark + 1, Length(Data) - Length(FieldID));
    for Iterator := 1 to VORBIS_FIELD_COUNT do
      if VORBIS_FIELD[Iterator] = FieldID then
        Header.Tag[Iterator] := FieldData;
  end
  else
    if Header.Tag[0] = '' then Header.Tag[0] := Data;
end;

{ --------------------------------------------------------------------------- }

procedure ReadTag(const FileName: string; var Header: HeaderInfo);
var
  SourceFile: file;
  Iterator, DataSize, FieldNumber: Integer;
  Data: array [1..250] of Char;
begin
  try
    { Set read-access, open file }
    AssignFile(SourceFile, FileName);
    FileMode := 0;
    Reset(SourceFile, 1);
    { Seek to tag info }
    BlockRead(SourceFile, Data, SizeOf(Data));
    Seek(SourceFile, GetTagPosition(Data));
    { Read all comment fields }
    Iterator := 0;
    repeat
      FillChar(Data, SizeOf(Data), 0);
      BlockRead(SourceFile, DataSize, 4);
      BlockRead(SourceFile, Data, DataSize);
      SetTagItem(Data, Header);
      if Iterator = 0 then BlockRead(SourceFile, FieldNumber, 4);
      Inc(Iterator);
    until Iterator > FieldNumber;
    CloseFile(SourceFile);
  except
  end;
end;

{ --------------------------------------------------------------------------- }

function GetTrack(const TrackString: string): Byte;
var
  Index, Value, Code: Integer;
begin
  { Extract track from string }
  Index := Pos('/', TrackString);
  if Index = 0 then Val(Trim(TrackString), Value, Code)
  else Val(Copy(Trim(TrackString), 1, Index), Value, Code);
  if Code = 0 then Result := Value
  else Result := 0;
end;

{ --------------------------------------------------------------------------- }

function OggFound(const Data: array of Char; var Index: Integer): Boolean;
var
  Iterator: Integer;
begin
  { Search for Ogg packet and get position if found }
  Result := false;
  for Iterator := 0 to SizeOf(Data) - 10 do
    if (Data[Iterator] = 'O') and
      (Data[Iterator + 1] = 'g') and
      (Data[Iterator + 2] = 'g') and
      (Data[Iterator + 3] = 'S') then
    begin
      Index := Iterator;
      Result := true;
      break;
    end;
end;

{ --------------------------------------------------------------------------- }

function GetSampleNumber(const FileName: string): Cardinal;
var
  SourceFile: file;
  Iterator, DataIndex, OggIndex: Integer;
  Data: array [1..250] of Char;
begin
  try
    Result := 0;
    { Set read-access, open file }
    AssignFile(SourceFile, FileName);
    FileMode := 0;
    Reset(SourceFile, 1);
    { Search for last Ogg packet - max. 50 x 250 bytes }
    for Iterator := 1 to 50 do
    begin
      DataIndex := FileSize(SourceFile) - (SizeOf(Data) - 10) * Iterator - 10;
      Seek(SourceFile, DataIndex);
      BlockRead(SourceFile, Data, SizeOf(Data));
      { Get number of PCM samples if Ogg packet header found }
      if OggFound(Data, OggIndex) then
      begin
        Seek(SourceFile, DataIndex + OggIndex + 6);
        BlockRead(SourceFile, Result, 4);
        break;
      end;
    end;
    CloseFile(SourceFile);
  except
  end;
end;

{ --------------------------------------------------------------------------- }

function DecodeUTF8(const Source: string): string;
var
  Iterator, SourceLength, FChar, NChar: Cardinal;
begin
  { Convert UTF-8 string to ANSI string }
  Result := '';
  Iterator := 0;
  SourceLength := Length(Source);
  while Iterator < SourceLength do
  begin
    Inc(Iterator);
    FChar := Ord(Source[Iterator]);
    if FChar >= $80 then
    begin
      Inc(Iterator);
      if Iterator > SourceLength then exit;
      FChar := FChar and $3F;
      if (FChar and $20) <> 0 then
      begin
        NChar := Ord(Source[Iterator]);
        if (NChar and $C0) <> $80 then  exit;
        FChar := (FChar shl 6) or (NChar and $3F);
        Inc(Iterator);
        if Iterator > SourceLength then exit;
      end;
      NChar := Ord(Source[Iterator]);
      if (NChar and $C0) <> $80 then exit;
      Result := Result + WideChar((FChar shl 6) or (NChar and $3F));
    end
    else
      Result := Result + WideChar(FChar);
  end;
end;

{ ********************** Private functions & procedures ********************* }

procedure TOggVorbis.FResetData;
begin
  { Reset variables }
  FValid := false;
  FFileSize := 0;
  FChannelModeID := 0;
  FSampleRate := 0;
  FBitRateNominal := 0;
  FSampleNumber := 0;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FTrack := 0;
  FDate := '';
  FGenre := '';
  FComment := '';
  FVendor := '';
end;

{ --------------------------------------------------------------------------- }

function TOggVorbis.FGetChannelMode: string;
begin
  { Get channel mode name }
  Result := VORBIS_MODE[FChannelModeID];
end;

{ --------------------------------------------------------------------------- }

function TOggVorbis.FGetDuration: Double;
begin
  { Calculate duration time }
  if FSampleNumber > 0 then
    if FSampleRate > 0 then
      Result := FSampleNumber / FSampleRate
    else
      Result := 0
  else
    if (FBitRateNominal > 0) and (FChannelModeID > 0) then
      Result := FFileSize / FBitRateNominal / FChannelModeID / 125 * 2
    else
      Result := 0;
end;

{ --------------------------------------------------------------------------- }

function TOggVorbis.FGetBitRate: Word;
begin
  { Calculate average bit rate }
  Result := 0;
  if FGetDuration > 0 then Result := Round(FFileSize / FGetDuration / 125);
end;

{ --------------------------------------------------------------------------- }

function TOggVorbis.FIsCorrupted: Boolean;
begin
  { Check for file corruption }
  Result := (FValid) and
    ((FChannelModeID = 0) or
    (FSampleRate = 0) or
    (FGetDuration < 0.1) or
    (FGetBitRate = 0));
end;

{ ********************** Public functions & procedures ********************** }

constructor TOggVorbis.Create;
begin
  { Create object }
  inherited;
  FResetData;
end;

{ --------------------------------------------------------------------------- }

function TOggVorbis.ReadFromFile(const FileName: string): Boolean;
var
  Header: HeaderInfo;
begin
  { Reset data and load parameter header from file to variable }
  FResetData;
  FillChar(Header, SizeOf(Header), 0);
  Result := ReadHeader(FileName, Header);
  { Process data if loaded and header valid }
  if (Result) and (Header.ID = #1 + 'vorbis') then
  begin
    FValid := true;
    { Fill properties with header data }
    FFileSize := Header.FileSize;
    FChannelModeID := GetChannelModeID(Header);
    FSampleRate := GetSampleRate(Header);
    FBitRateNominal := GetBitRateNominal(Header);
    { Get tag information and fill properties }
    ReadTag(FileName, Header);
    FTitle := DecodeUTF8(Header.Tag[1]);
    FArtist := DecodeUTF8(Header.Tag[2]);
    FAlbum := DecodeUTF8(Header.Tag[3]);
    FTrack := GetTrack(Header.Tag[4]);
    FDate := DecodeUTF8(Header.Tag[5]);
    FGenre := DecodeUTF8(Header.Tag[6]);
    FComment := DecodeUTF8(Header.Tag[7]);
    FVendor := DecodeUTF8(Header.Tag[0]);
    { Get total number of encoded PCM samples }
    FSampleNumber := GetSampleNumber(FileName);
  end;
end;

end.
