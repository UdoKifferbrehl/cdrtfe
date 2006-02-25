{ cl_mpeginfo.pas: Funktionen für MPEG-Audio-Dateien

  Copyright (c) 2006 Oliver Valencia

  letzte Änderung  12.02.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert im wesentlichen auf Informationen von:
  http://www.multiweb.cz/twoinches/MP3inside.htm  und
  http://www.dv.co.yu/mpgscript/mpeghdr.htm

  cl_mpeginfo.pas stellt Funktionen für MPEG-Audio-Dateien zur Verfügung. Unter-
  stützt werden die Formate MPEG Version 1, 2, 2.5 Layer I, II, III.
    * Länge in Sekunden
    * ID3-Tags (V1 und V2; wenn vorhanden, haben ID3V2-Tags Vorrang)


  TMPEGFile: Objekt, das die Infos über die Datei enthält 

    Properties   FileName
                 LastError
                 Length
                 TagTitle
                 TagArtist
                 TagAlbum
                 TagYear
                 TagComment
                 TagTrack
                 TagGenre

    Methoden     Create(Name: string)
                 GetInfo

  exportierte Funktionen/Prozeduren:

    x

}

unit cl_mpeginfo;

interface

uses Classes, SysUtils, Windows, Dialogs;

type TMPEGInfoError = (MIE_NoError, MIE_FileNotFound, MIE_InvalidMPEGFile);

     TMPEGFrameInfo = record
       Header     : array[0..3] of Byte; // Frame-Header, 32 Bit
       MPEGVersion: Byte;                // MPEG Audio Version
       Layer      : Byte;                // Layer description
       Protection : Boolean;             // True - 16-Bit-CRC
       BitRate    : Longint;             // Bit rate
       SampleRate : Longint;             // Sampling rate (Hz)
       Padding    : Boolean;             // True - Frame is padded
       PrivBit    : Boolean;             // Private Bit ?
       ChannelMode: Byte;                // ChannelMode
       ModeExt    : Byte;                // Mode Extension, if ChannelMode = JS
       Copyright  : Boolean;             // True: Copyrighted
       Original   : Boolean;
       Emphasis   : Byte;
       FrameSize  : Word;                // Frame size (incl. CRC)
     end;

     TMPEGTags = record
       Title,
       Artist,
       Album,
       Year,
       Comment,
       Genre   : string;
       Track   : Byte;
     end;

     TMPEGTagID3V1RAW = packed record
       Tag    : array[1..3] of Char;
       Title  : array[1..30] of Char;
       Artist : array[1..30] of Char;
       Album  : array[1..30] of Char;
       Year   : array[1..4] of Char;
       Comment: array[1..29] of Char;
       Track  : Byte;
       Genre  : Byte;
     end;

     TMPEGID3V2FrameHeader = packed record
       Tag    : array[1..4] of Char;
       Size   : Integer;              // falsche Bytereihenfolge! array[1..4] of Byte;
       Flags  : array[1..2] of Byte;
     end;

     TMPEGFile = class(TObject)
     private
       FAudioStart: Longint;
       FFileName  : string;
       FID3V1Tag  : TMPEGTags;
       FID3V2Tag  : TMPEGTags;
       FLastError : TMPEGInfoError;
       FLength    : Extended;
       FOk        : Boolean;
       function CalcMPEGFrameSize(MPEGVersion: Byte; BitRate, SampleRate: Longint; Padding: Boolean): Longint;
       function DecodeMPEGHeader(var Frame: TMPEGFrameInfo): Boolean;
       function FindFirstMPEGHeader(FileIn: TFileStream): Longint;
       function GetID3V2Tag(Buffer: PChar; const Tag: string): string;
       function GetLastError: TMPEGInfoError;
       function GetMPEGAudioLength(const Name: string): Extended;
       function GetTagTitle: string;
       function GetTagArtist: string;
       function GetTagAlbum: string;
       function GetTagYear: string;
       function GetTagComment: string;
       function GetTagTrack: Integer;
       function GetTagGenre: string;
       procedure GetMPEGAudioTagsID3V1(const Name: string);
       procedure GetMPEGAudioTagsID3V2(const Name: string);
     public
       constructor Create(const Name: string);
       destructor Destroy; override;
       procedure GetInfo;
       property FileName  : string read FFileName;
       property LastError : TMPEGInfoError read GetLastError;
       property Length    : Extended read FLength;
       {ID3-Tags}
       property TagTitle  : string read GetTagTitle;
       property TagArtist : string read GetTagArtist;
       property TagAlbum  : string read GetTagAlbum;
       property TagYear   : string read GetTagYear;
       property TagComment: string read GetTagComment;
       property TagTrack  : Integer read GetTagTrack;
       property TagGenre  : string read GetTagGenre;
     end;

implementation

const { MPEG Audio Version }
      MPEG_VER_UNKNOWN      = 0; { Unknown     }
      MPEG_VER_1            = 1; { Version 1   }
      MPEG_VER_2            = 2; { Version 2   }
      MPEG_VER_25           = 3; { Version 2.5 }

      { MPEG Version Strings }
      MPEG_VERSIONS : array[0..3] of string = ('Unknown', '1.0', '2.0', '2.5');

      { Channel mode (number of channels) in MPEG file }
      MPEG_MD_STEREO        = 0; { Stereo }
      MPEG_MD_JOINT_STEREO  = 1; { Stereo }
      MPEG_MD_DUAL_CHANNEL  = 2; { Stereo }
      MPEG_MD_MONO          = 3; { Mono   }

      { Channel Mode Strings }
      MPEG_MODES : array[0..3] of string = ('Stereo', 'Joint-Stereo',
                                            'Dual-Channel', 'Single-Channel');

      { Tabelle der Mode Extension Strings
        Zugriff: MPEG_MODE_EXTENSIONS[layer_index][ext_mode_index] }
      MPEG_MODE_EXTENSIONS : array[1..3, 0..3] of string =
         { Layer III }
        (('Int: off, MS: off', 'Int: on, MS: off', 'Int: off, MS: on', 'Int: on, MS: on'),
         { Layer II  }
         ('bands 4 to 31', 'bands 8 to 31', 'bands 12 to 31', 'bands 16 to 31'),
         { Layer I  }
         ('bands 4 to 31', 'bands 8 to 31', 'bands 12 to 31', 'bands 16 to 31'));

      { Emphasis Strings }
      MPEG_EMPHASIS : array[0..3] of string =
        ('none', '50/15 ms', 'reserved', 'CCIT J.17');

      { Layer Strings }
      MPEG_LAYERS : array[0..3] of string = ('Unknown', 'III', 'II', 'I');

      { Tabelle der Sampling-Raten.
        Zugriff: MPEG_SAMPLE_RATES[mpeg_version_index][samplerate_index] }
      MPEG_SAMPLE_RATES : array[1..3, 0..3] of Word =
         { Version 1   }
        ((44100, 48000, 32000, 0),
         { Version 2   }
         (22050, 24000, 16000, 0),
         { Version 2.5 }
         (11025, 12000, 8000, 0));

      { Tabelle: Samples/Frame
        Zugriff: MPEG_SAMPLES_PER_FRAME[mpeg_version_index][layer_index] }
      MPEG_SAMPLES_PER_FRAME : array[1..3, 1..3] of Word =
         { Version 1 }
        ((1152, 1152, 384),
         { Version 2 }
         (576, 1152, 384),
         { Version 2.5 }
         (576, 1152, 384));

      { Tabelle der MPEG-Audio-Bitraten.
        Zugriff: MPEG_BIT_RATES[mpeg_version_index][layer_index][bitrate_index] }
      MPEG_BIT_RATES : array[1..3, 1..3, 0..15] of Word =
           { Version 1, Layer III   }
         (((0, 32, 40, 48,  56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 0),
           {            Layer II    }
           (0, 32, 48, 56,  64,  80,  96, 112, 128, 160, 192, 224, 256, 320, 384, 0),
           {            Layer I     }
           (0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0)),
           { Version 2, Layer III   }
          ((0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0),
           {            Layer II    }
           (0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0),
           {            Layer I     }
           (0, 32, 48, 56,  64,  80,  96, 112, 128, 144, 160, 176, 192, 224, 256, 0)),
           { Version 2.5, Layer III }
          ((0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0),
           {              Layer II  }
           (0,  8, 16, 24,  32,  40,  48,  56,  64,  80,  96, 112, 128, 144, 160, 0),
           {              Layer I   }
           (0, 32, 48, 56,  64,  80,  96, 112, 128, 144, 160, 176, 192, 224, 256, 0)));


{ Hilfsfunktionen ------------------------------------------------------------ }

{ FindInBuffer -----------------------------------------------------------------

  sucht Tag in Buffer und gibt als Ergebnis den Offset an (-1, wenn Tag nicht
  gefunden wurde).                                                             }

function FindInBuffer(Buffer: PChar; const Tag: string;
                      const Size: Integer): Integer;
var i, j, l : Integer;
    Found   : Boolean;
    Temp    : PChar;
begin
  Found := False;
  i := 0;
  l := Length(Tag);
  GetMem(Temp, l + 1);
  j := Size - l;
  while (i <= j) and not Found do
  begin
    StrLCopy(Temp, Buffer, l);
    Found := string(Temp) = Tag;
    Inc(Buffer);
    Inc(i);
  end;
  FreeMem(Temp);
  if Found then
    Result := i - 1
  else
    Result := -1;
end;

{ ChangeByteOrderInt -----------------------------------------------------------

  kehrt die Byte-Reihenfolge des übergebenen Integer-Wertes (4 Byte) um.       }

function ChangeByteOrderInt(const x: Integer): Integer;
begin
  Result := ((x shr 24) and $FF) or
            ((x shr 8) and $FF00) or
            ((x shl 8) and $FF0000) or
            ((x shl 24)and $FF000000);
end;

{ TMPEGFile ------------------------------------------------------------------ }

{ TMPEGFile - private }

{ GetLastError -----------------------------------------------------------------

  liefert den aktuellen Fehlerzustand und setzt ihn zurück.                    }

function TMPEGFile.GetLastError: TMPEGInfoError;
begin
  Result := FLastError;
  FLastError := MIE_NoError;
end;

{ GetTag... --------------------------------------------------------------------

  liefert die ID3-Tag-Daten. Sofern vorhanden haben die ID3V2-Tags Vorrang.    }

function TMPEGFile.GetTagTitle: string;
begin
  if FID3V2Tag.Title = '' then
    Result := FID3V1Tag.Title
  else
    Result := FID3V2Tag.Title;
end;

function TMPEGFile.GetTagArtist: string;
begin
  if FID3V2Tag.Artist = '' then
    Result := FID3V1Tag.Artist
  else
    Result := FID3V2Tag.Artist;
end;

function TMPEGFile.GetTagAlbum: string;
begin
  if FID3V2Tag.Album = '' then
    Result := FID3V1Tag.Album
  else
    Result := FID3V2Tag.Album;
end;

function TMPEGFile.GetTagYear: string;
begin
  if FID3V2Tag.Year = '' then
    Result := FID3V1Tag.Year
  else
    Result := FID3V2Tag.Year;
end;

function TMPEGFile.GetTagComment: string;
begin
  if FID3V2Tag.Comment = '' then
    Result := FID3V1Tag.Comment
  else
    Result := FID3V2Tag.Comment
end;

function TMPEGFile.GetTagTrack: Integer;
begin
  if FID3V2Tag.Track = 0 then
    Result := FID3V1Tag.Track
  else
    Result := FID3V2Tag.Track
end;

function TMPEGFile.GetTagGenre: string;
begin
  if FID3V2Tag.Genre = '' then
    Result := FID3V1Tag.Genre
  else
    Result := FID3V2Tag.Genre;
end;

{ CalcMPEGFrameSize ------------------------------------------------------------

  berechnet die Größe des MPEG-Audio-Frames.                                   }

function TMPEGFile.CalcMPEGFrameSize(MPEGVersion: Byte;
                                     BitRate, SampleRate: Longint;
                                     Padding: Boolean): Longint;
var c: Byte;
begin
  Result := 0;
  case MPEGVersion of
    MPEG_Ver_2,
    MPEG_Ver_25: c :=  72;
    MPEG_Ver_1 : c := 144;
  else
    c := 0;
  end;
  if SampleRate > 0 then
    Result := Trunc(c * BitRate * 1000 / SampleRate + Integer(Padding));
end;

{ DecodeMPEGHeader -------------------------------------------------------------

  DecodeMP3Header extrahiert Informationen aus einem MPEG-Audio-Frame-Header.
  Rückgabewert ist True, wenn es ein gültiger Frame-Header ist.                }

function TMPEGFile.DecodeMPEGHeader(var Frame: TMPEGFrameInfo): Boolean;
var Ok   : Boolean;
    Index: Byte;
begin
  {Frame Sync}
  Ok := (Frame.Header[0] = $ff) and ((Frame.Header[1] and $e0) = $e0);
  {MPEG Audio Version}
  Index := (Frame.Header[1] and $18) shr $3;
  case Index of
    0: Frame.MPEGVersion := MPEG_VER_25;
    1: Frame.MPEGVersion := MPEG_VER_UNKNOWN;
    2: Frame.MPEGVersion := MPEG_VER_2;
    3: Frame.MPEGVersion := MPEG_VER_1;
  end;
  {Layer}
  Frame.Layer := (Frame.Header[1] and $6) shr $1;
  {Protection}
  Frame.Protection := (Frame.Header[1] and $1) = 0;
  {Bit Rate}
  Index := (Frame.Header[2] and $f0) shr 4;
  Frame.BitRate := MPEG_BIT_RATES[Frame.MPEGVersion, Frame.Layer, Index];
  {Sampling Rate}
  Index := (Frame.Header[2] and $c) shr 2;
  Frame.SampleRate := MPEG_SAMPLE_RATES[Frame.MPEGVersion, Index];
  {Padding}
  Frame.Padding := ((Frame.Header[2] and $2) shr 1) = 1;
  {Private Bit}
  Frame.PrivBit := (Frame.Header[2] and $1) = 1;
  {Channel Mode}
  Frame.ChannelMode := (Frame.Header[3] and $c0) shr 6;
  {Mode Extension}
  Frame.ModeExt := (Frame.Header[3] and $30) shr 4;
  {Copyright}
  Frame.Copyright := ((Frame.Header[3] and $8) shr 3) = 1;
  {Original}
  Frame.Original := ((Frame.Header[3] and $4) shr 2) = 1;
  {Emphasis}
  Frame.Emphasis := Frame.Header[3] and $3;
  {Frame Size}
  Frame.FrameSize := CalcMPEGFrameSize(Frame.MPEGVersion, Frame.BitRate,
                                       Frame.SampleRate, Frame.Padding);
  {Frame gültig?}
  Result := Ok and (Frame.MPEGVersion > 0)
               and (Frame.Layer > 0)
               and (Frame.SampleRate > 0)
               and (Frame.BitRate > 0);
end;

{ FindFirstMPEGHeader ----------------------------------------------------------

  FindFirstMPEGHeader sucht den ersten gültigen MPEG-Audio-Header in der Datei.
  Rückgabewerte: Position des Headers in der Datei, sonst -1.
  MaxHeader legt fest, wieviele aufeinanderfolgende Frames gültig sein müssen,
  damit die Datei als gültige MPEG-Audio akzeptiert wird.                      }

function TMPEGFile.FindFirstMPEGHeader(FileIn: TFileStream):Longint;
const MaxHeader = 4;
var Buffer       : array[0..8191] of Byte;
    BytesRead    : Integer;
    FirstFramePos: Longint;
    TempPos      : Longint;
    i, Count     : Integer;
    Ok           : Boolean;
    Frame        : TMPEGFrameInfo;
begin
  Result := -1;
  FirstFramePos := 0;
  repeat
    FillChar(Buffer, SizeOf(Buffer), 0);
    TempPos := FileIn.Position;
    BytesRead := FileIn.Read(Buffer, SizeOf(Buffer));
    {Frame in Buffer suchen}
    i := 0;
    repeat
      Frame.Header[0] := Buffer[i];
      Frame.Header[1] := Buffer[i + 1];
      Frame.Header[2] := Buffer[i + 2];
      Frame.Header[3] := Buffer[i + 3];
      Ok := DecodeMPEGHeader(Frame);
      Inc(i);
    until Ok or (i = SizeOf(Buffer) - 3);
    if Ok then
    begin
      FirstFramePos := TempPos + i - 1;
      Count := 1;
      {Einen Header haben wir, daß heißt aber noch nichts. Daher prüfen, ob
       weitere Header im richtigen Abstand folgen.}
      FileIn.Seek(FirstFramePos, soFromBeginning);
      FileIn.Seek(Frame.FrameSize, soFromCurrent);
      repeat
        {BytesRead := }FileIn.Read(Frame.Header, 4);
        Ok := DecodeMPEGHeader(Frame);
        if Ok then
        begin
          Inc(Count);
          FileIn.Seek(Frame.FrameSize - 4, soFromCurrent);
        end else
        begin
          FileIn.Seek(FirstFramePos + 1, soFromBeginning);
          Count := 0;
        end;
      until (Count = MaxHeader) or not Ok;
    end else
    begin
      {in Buffer war kein Frame}
      FileIn.Seek(-4, soFromCurrent);
    end;
  until Ok or (BytesRead < SizeOf(Buffer));
  if Ok then
  begin
    Result := FirstFramePos;
  end;
end;

(*
function TMPEGFile.FindFirstMPEGHeader(FileIn: TFileStream): Longint;
const MaxHeader = 4;
var Frame        : TMPEGFrameInfo;
    FirstFramePos: Longint;
    BytesRead    : Integer;
    Ok           : Boolean;
    Count        : Integer;
begin
  Result := -1;
  FirstFramePos := 0;
  {Suche ersten Frame-Sync}
   repeat
     BytesRead := FileIn.Read(Frame.Header, 4);
     Ok := DecodeMPEGHeader(Frame);
     if Ok then
     begin
       FirstFramePos := FileIn.Position - 4;
       Count := 1;
       {Einen Header haben wir, daß heißt aber noch nichts. Daher prüfen, ob
        weitere Header im richtigen Abstand folgen.}
       while Ok and (Count < MaxHeader) and (BytesRead = 4) do
       begin
         FileIn.Seek(Frame.FrameSize - 4, soFromCurrent);
         BytesRead := FileIn.Read(Frame.Header, 4);
         Ok := DecodeMPEGHeader(Frame);
         if Ok then
         begin
           Inc(Count);
         end else
         begin
           FileIn.Seek(FirstFramePos + 1, soFromBeginning);
           Count := 0;
         end;
       end;
     end else
     begin
       FileIn.Seek(-3, soFromCurrent);
     end;
   until Ok or (BytesRead < 4);
   if Ok then
   begin
     Result := FirstFramePos;
   end;
end;
*)

{ GetMPEGAudioLength -----------------------------------------------------------

  GetMPEGAudioLength bestimmt die Länge der Datei Name. Die Datei muß eine MPEG-
  Audio-Datei Version 1, 2 oder 2.5, Layer I, II oder III sein.
  Rückgabewert: Länge in Sekunden
                0       -> Datei ungültig
                negativ -> Datei nicht gefunden                                }

function TMPEGFile.GetMPEGAudioLength(const Name: string): Extended;
var FileIn       : TFileStream;
    FSize        : Longint;
    BSize        : Integer;
    NBytes       : Integer;
    FrameLength  : Extended;
    Buffer       : array[0..2048] of Byte;
    MPEGFrameInfo: TMPEGFrameInfo;
    FirstFramePos: Longint;
    i            : Integer;
    Ok           : Boolean;
begin
  FileIn := nil;
  Ok := True;
  FrameLength := 0;
  i := 0;
  try
    try
      FileIn := TFileStream.Create(Name, fmOpenRead or fmShareDenyNone);
      FSize := FileIn.Size;
      {nur weiter, wenn Datei mehr als einen Frame-Header enthält}
      if FSize > 4 then
      begin
        {ersten gültigen Header suchen}
        FirstFramePos := FindFirstMPEGHeader(FileIn);
        FAudioStart := FirstFramePos;
        FSize := FSize - FirstFramePos;
        {ersten gültigen Header lesen}
        if FirstFramePos > 0 then
          FileIn.Seek(FirstFramePos, soFromBeginning)
        else
          FileIn.Seek(0, soFromBeginning);
        FileIn.ReadBuffer(MPEGFrameInfo.Header, 4);
        Dec(FSize, 4);
        if not DecodeMPEGHeader(MPEGFrameInfo) then
        begin
          {Frame-Header ungültig, Größe auf Null setzen -> Abbruch}
          FSize := 0;
        end else
        begin
          {gültiger Frame-Header gefunden, Länge berechnen}
          FrameLength := MPEG_SAMPLES_PER_FRAME[MPEGFrameInfo.MPEGVersion,
                                                MPEGFrameInfo.Layer] /
                         MPEGFrameInfo.SampleRate;
          {jetzt den Rest des Frames lesen}
          BSize := MPEGFrameInfo.FrameSize - 4;
          if FSize > BSize then NBytes := BSize else NBytes := FSize;
          Dec(FSize, NBytes);
          FileIn.ReadBuffer(Buffer, NBytes);
          Inc(i);
        end;
        {jetzt alle restlichen Frames zählen}
        while (FSize > 3) and Ok do
        begin
          {nächsten Header lesen}
          FileIn.ReadBuffer(MPEGFrameInfo.Header, 4);
          Dec(FSize, 4);
          if not DecodeMPEGHeader(MPEGFrameInfo) then
          begin
            {Kein Header -> Abbruch}
            Ok := False;
          end else
          begin
            BSize := MPEGFrameInfo.FrameSize - 4;
            if FSize > BSize then NBytes := BSize else NBytes := FSize;
            Dec(FSize, NBytes);
            FileIn.ReadBuffer(Buffer, NBytes);
            Inc(i);
          end;
        end;
      end else
      begin
        {Datei zu kurz}
        i := 0;
      end;
    except
      i := -1;
      FrameLength := 1;
    end;
  finally
    FileIn.Free;
  end;
  {Länge: Anzahl Frames * FrameLength}
  Result := i * FrameLength;
end;

{ GetMPEGAudioTagsID3V1 --------------------------------------------------------

  liest, sofern vorhanden, die ID3V1 Tags ein.                                 }

procedure TMPEGFile.GetMPEGAudioTagsID3V1(const Name: string);
var FileIn       : TFileStream;
    Buffer       : array[0..127] of Char;
    RawData      : ^TMPEGTagID3V1Raw;
begin
  FileIn := nil;
  RawData := @Buffer;
  try
    FileIn := TFileStream.Create(Name, fmOpenRead or fmShareDenyNone);
    FileIn.Seek(-128, soFromEnd);
    FileIn.ReadBuffer(Buffer, 128);
  finally
    FileIn.Free;
  end;
  {Tags: ID3V1}
  if RawData^.Tag = 'TAG' then
  begin
    FID3V1Tag.Title   := Trim(RawData.Title);
    FID3V1Tag.Artist  := Trim(RawData.Artist);
    FID3V1Tag.Album   := Trim(RawData.Album);
    FID3V1Tag.Year    := Trim(RawData.Year);
    FID3V1Tag.Comment := Trim(RawData.Comment);
    FID3V1Tag.Track   := RawData.Track;
    FID3V1Tag.Genre   := Trim(IntToStr(RawData.Genre));
  end;
end;

{ GetID3V2Tag ------------------------------------------------------------------

  liefert den Inhalt des Tags als String zurück.                               }

function TMPEGFile.GetID3V2Tag(Buffer: PChar; const Tag: string): string;
var Offset : Integer;
    Size   : Integer;
    i      : Integer;
    TempStr: string;
    Hdr    : ^TMPEGID3V2FrameHeader;
begin
  Offset := FindInBuffer(Buffer, Tag, FAudioStart);
  if Offset > 0 then
  begin
    {Frame-Header}
    Inc(Buffer, Offset);
    Hdr := Pointer(Buffer);
    Size := ChangeByteOrderInt(Hdr^.Size);
    {Header überspringen: 10 Byte Header + 1 Null-Byte}
    Inc(Buffer, 11);
    {(Size - 1) Zeichen von Buffer in TempStr übertragen}
    TempStr := '';
    for i := 1 to (Size - 1) do
    begin
      if Buffer^ <> #0 then TempStr := TempStr + Buffer^;
      Inc(Buffer);
    end;
    Trim(TempStr);
    Result := TempStr;
  end else
  begin
    Result := '';
  end;
end;

{ GetMPEGAudioTagsID3V2 --------------------------------------------------------

  liest, sofern vorhanden, die ID3V2 Tags ein.                                 }

procedure TMPEGFile.GetMPEGAudioTagsID3V2(const Name: string);
var FileIn       : TFileStream;
    Buffer       : PChar;
begin
  FileIn := nil;
  if FAudioStart > 0 then
  begin
    GetMem(Buffer, FAudioStart);
    try
      FileIn := TFileStream.Create(Name, fmOpenRead or fmShareDenyNone);
      FileIn.ReadBuffer(Buffer^, FAudioStart);
    finally
      FileIn.Free;
    end;
    {Tags: ID3V2}
    if FindInBuffer(Buffer, 'ID3', FAudioStart) > -1 then
    begin
      FID3V2Tag.Title   := GetID3V2Tag(Buffer, 'TIT2');
      FID3V2Tag.Artist  := GetID3V2Tag(Buffer, 'TPE1');
      FID3V2Tag.Album   := GetID3V2Tag(Buffer, 'TALB');
      FID3V2Tag.Year    := GetID3V2Tag(Buffer, 'TYER');
      FID3V2Tag.Comment := GetID3V2Tag(Buffer, 'COMM');
      FID3V2Tag.Track   := StrToIntDef(GetID3V2Tag(Buffer, 'TRCK'), 0);
      FID3V2Tag.Genre   := GetID3V2Tag(Buffer, 'TCON');
    end;

    FreeMem(Buffer);
  end;
end;

{ TMPEGFile - public }

constructor TMPEGFile.Create(const Name: string);
begin
  inherited Create;
  FLength := 0;
  FAudioStart := 0;
  if FileExists(Name) then
  begin
    FLastError := MIE_NoError;
    FOk        := True;
    FFileName  := Name;
  end else
  begin
    FLastError := MIE_FileNotFound;
    FOk        := False;
    FFileName  := '';
  end;
end;

destructor TMPEGFile.Destroy;
begin
  inherited Destroy;
end;

{ GetInfo ----------------------------------------------------------------------

  GetInfo sammelt die Informationen über die MPEG-Audio-Datei.                 }

procedure TMPEGFile.GetInfo;
begin
  if FOk then
  begin
    FLength := GetMPEGAudioLength(FFileName);
    if FLength  = 0 then FLastError := MIE_InvalidMPEGFile;
    if FLastError = MIE_NoError then
    begin
      GetMPEGAudioTagsID3V1(FFileName);
      GetMPEGAudioTagsID3V2(FFileName);
    end;
  end else
  begin
    FLastError := MIE_FileNotFound;
  end;
end;

end.
