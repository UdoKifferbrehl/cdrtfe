{ cl_apeinfo.pas: Funktionen für Ape-Audio-Dateien (Monkey's Audio)

  Copyright (c) 2007 Oliver Valencia

  letzte Änderung  24.06.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert im wesentlichen auf Code aus der Audio Tools Library 2.3,
  Copyright (c) 2000-2002 by Jurgen Faul, 2003-2005 by The MAC Team.
  http://mac.sourceforge.net/atl/


  cl_apeinfo.pas stellt Funktionen für Ape-Audio-Dateien zur Verfügung.
    * Länge in Sekunden
    * Tags (Achtung: noch nicht implementiert!)


  TApeFile: Objekt, das die Infos über die Datei enthält

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

unit cl_apeinfo;

interface

uses Classes, SysUtils, Windows, f_largeint;

const {Compression level codes}
      MONKEY_COMPRESSION_FAST       = 1000;    { Fast (poor) }
      MONKEY_COMPRESSION_NORMAL     = 2000;    { Normal (good) }
      MONKEY_COMPRESSION_HIGH       = 3000;    { High (very good) }
      MONKEY_COMPRESSION_EXTRA_HIGH = 4000;    { Extra high (best) }
      MONKEY_COMPRESSION_INSANE     = 5000;    { Insane }
      MONKEY_COMPRESSION_BRAINDEAD  = 6000;    { BrainDead }

      {Compression level names}
      MONKEY_COMPRESSION: array [0..6] of string = ('Unknown', 'Fast', 'Normal',
                                                    'High', 'Extra High',
                                                    'Insane', 'BrainDead');

      { Format flags, only for Monkey's Audio <= 3.97}
      MONKEY_FLAG_8_BIT          = 1;    // Audio 8-bit
      MONKEY_FLAG_CRC            = 2;    // New CRC32 error detection
      MONKEY_FLAG_PEAK_LEVEL     = 4;    // Peak level stored
      MONKEY_FLAG_24_BIT         = 8;    // Audio 24-bit
      MONKEY_FLAG_SEEK_ELEMENTS  = 16;   // Number of seek elements stored
      MONKEY_FLAG_WAV_NOT_STORED = 32;   // WAV header not stored

      {Channel mode names}
      MONKEY_MODE: array [0..2] of string = ('Unknown', 'Mono', 'Stereo');

type TApeInfoError = (AIE_NoError, AIE_FileNotFound, AIE_InvalidApeFile);

     {Real structure of Monkey's Audio header}
     // common header for all versions
     APE_HEADER = packed record
       cID     : array[0..3] of Byte;  // should equal 'MAC '
       nVersion: Word;                 // version number * 1000 (3.81 = 3810)
     end;

     // old header for <= 3.97
     APE_HEADER_OLD = packed record
       nCompressionLevel,              // the compression level
       nFormatFlags,                   // any format flags (for future use)
       nChannels: word;                // the number of channels (1 or 2)
       nSampleRate,                    // the sample rate (typically 44100)
       nHeaderBytes,                   // the bytes after the MAC header that compose the WAV header
       nTerminatingBytes,              // the bytes after that raw data (for extended info)
       nTotalFrames,                   // the number of frames in the file
       nFinalFrameBlocks: Longword;    // the number of samples in the final frame
       qnInt            : Integer;
     end;

     // new header for >= 3.98
     APE_HEADER_NEW = packed record
       nCompressionLevel: Word;        // the compression level (see defines I.E. COMPRESSION_LEVEL_FAST)
       nFormatFlags     : Word;        // any format flags (for future use) Note: NOT the same flags as the old header!
       nBlocksPerFrame  : Longword;    // the number of audio blocks in one frame
       nFinalFrameBlocks: Longword;    // the number of audio blocks in the final frame
       nTotalFrames     : Longword;    // the total number of frames
       nBitsPerSample   : Word;        // the bits per sample (typically 16)
       nChannels        : Word;	       // the number of channels (1 or 2)
       nSampleRate      : Longword;    // the sample rate (typically 44100)
     end;

     // data descriptor for >= 3.98
     APE_DESCRIPTOR = packed record
       padded                : Word;     // padding/reserved (always empty)
       nDescriptorBytes,                 // the number of descriptor bytes (allows later expansion of this header)
       nHeaderBytes,                     // the number of header APE_HEADER bytes
       nSeekTableBytes,                  // the number of bytes of the seek table
       nHeaderDataBytes,                 // the number of header data bytes (from original file)
       nAPEFrameDataBytes,               // the number of bytes of APE frame data
       nAPEFrameDataBytesHigh,           // the high order number of APE frame data bytes
       nTerminatingDataBytes : Longword; // the terminating data of the file (not including tag data)
       cFileMD5: array[0..15] of Byte;   // the MD5 hash of the file (see notes for usage... it's a littly tricky)
     end;

     TApeTags = record
       Title,
       Artist,
       Album,
       Date,
       Comment,
       Genre   : string;
       Track   : Byte;
     end;

     TApeFile = class(TObject)
     private
       //FApeTags   : TApeTags;
       FFileName  : string;
       FLastError : TApeInfoError;
       FLength    : Extended;
       FOk        : Boolean;
       {from atl}
       FValid             : Boolean;
       // Stuff loaded from the header:
       FVersion           : Integer;
       FVersionStr        : string;
       FChannels          : Integer;
       FSampleRate        : Integer;
       FBits              : Integer;
       FPeakLevel         : Longword;
       FPeakLevelRatio    : Double;
       FTotalSamples      : Int64;
       FBitrate           : Double;
       FDuration          : Double;
       FCompressionMode   : Integer;
       FCompressionModeStr: string;
       // FormatFlags, only used with Monkey's <= 3.97
       FFormatFlags       : Integer;
       FHasPeakLevel      : Boolean;
       FHasSeekElements   : Boolean;
       FWavNotStored      : Boolean;
       // Tagging
//       FID3v1             : TID3v1;
//       FID3v2             : TID3v2;
//       FAPEtag            : TAPEtag;
       //
       FFileSize          : Int64;
       function ApeFileIsValid: Boolean;
       function FindApeHeader(FileIn: TFileStream):Longint;
       function GetLastError: TApeInfoError;
       function GetRatio: Double;
       function ReadInfo: Boolean;
       procedure ResetData;
     public
       constructor Create(const Name: string);
       destructor Destroy; override;
       procedure GetInfo;
       property FileName  : string read FFileName;
       property LastError : TApeInfoError read GetLastError;
       property Length    : Extended read FLength;
       {from atl}
       property FileSize          : Int64 read FFileSize;
       property Valid             : Boolean read FValid;
       property Version           : Integer read FVersion;
       property VersionStr        : string read FVersionStr;
       property Channels          : Integer read FChannels;
       property SampleRate        : Integer read FSamplerate;
       property Bits              : Integer read FBits;
       property Bitrate           : Double read FBitrate;
       property Duration          : Double read FDuration;
       property PeakLevel         : Longword read FPeakLevel;
       property PeakLevelRatio    : Double read FPeakLevelRatio;
       property TotalSamples      : Int64 read FTotalSamples;
       property CompressionMode   : Integer read FCompressionMode;
       property CompressionModeStr: string read FCompressionModeStr;
       // FormatFlags, only used with Monkey's <= 3.97
       property FormatFlags       : Integer read FFormatFlags;
       property HasPeakLevel      : Boolean read FHasPeakLevel;
       property HasSeekElements   : Boolean read FHasSeekElements;
       property WavNotStored      : Boolean read FWavNotStored;
       // Tagging
//       property ID3v1: TID3v1 read FID3v1;                    { ID3v1 tag data }
//       property ID3v2: TID3v2 read FID3v2;                    { ID3v2 tag data }
//       property APEtag: TAPEtag read FAPEtag;                   { APE tag data }
       property Ratio: Double read GetRatio;          { Compression ratio (%) }
     end;

implementation

{ Hilfsfunktionen ------------------------------------------------------------ }

{ TApeFile ------------------------------------------------------------------- }

{ TApeFile - private }

{ GetLastError -----------------------------------------------------------------

  liefert den aktuellen Fehlerzustand und setzt ihn zurück.                    }

function TApeFile.GetLastError: TApeInfoError;
begin
  Result := FLastError;
  FLastError := AIE_NoError;
end;

{ ResetData --------------------------------------------------------------------

  Alles zurücksetzten.                                                         }

procedure TApeFile.ResetData;
begin
  FValid              := False;
  FVersion            := 0;
  FVersionStr         := '';
  FChannels           := 0;
  FSampleRate         := 0;
  FBits               := 0;
  FPeakLevel          := 0;
  FPeakLevelRatio     := 0.0;
  FTotalSamples       := 0;
  FBitrate            := 0.0;
  FDuration           := 0.0;
  FCompressionMode    := 0;
  FCompressionModeStr := '';
  FFormatFlags        := 0;
  FHasPeakLevel       := false;
  FHasSeekElements    := false;
  FWavNotStored       := false;
  FFileSize           := 0;
  //FID3v1.ResetData;
  //FID3v2.ResetData;
  //FAPEtag.ResetData;
end;

{ FindApeHeader ----------------------------------------------------------------

  FindApeHeader sucht den ersten Ape-Audio-Header in der Datei.
  Rückgabewerte: Position des Headers in der Datei, sonst -1.                  }

function TApeFile.FindApeHeader(FileIn: TFileStream): Longint;
var Buffer       : array[0..8191] of Byte;
    BytesRead    : Integer;
    FirstFramePos: Longint;
    TempPos      : Longint;
    i            : Integer;
    Ok           : Boolean;
    Header       : APE_Header;
begin
  Result := -1;
  FirstFramePos := 0;
  repeat
    FillChar(Buffer, SizeOf(Buffer), 0);
    TempPos := FileIn.Position;
    BytesRead := FileIn.Read(Buffer, SizeOf(Buffer));
    {Header in Buffer suchen}
    i := 0;
    repeat
      Header.cID[0] := Buffer[i];
      Header.cID[1] := Buffer[i + 1];
      Header.cID[2] := Buffer[i + 2];
      Header.cID[3] := Buffer[i + 3];
      Ok := StrLComp(@Header.cID[0], 'MAC ', 4) = 0;
      Inc(i);
    until Ok or (i = SizeOf(Buffer) - 3);
    if Ok then
    begin
      FirstFramePos := TempPos + i - 1;
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

{ ReadInfo ---------------------------------------------------------------------

  Infos ermitteln.                                                             }

function TApeFile.ReadInfo: Boolean;
var f             : TFileStream;
    APE           : APE_HEADER;     // common header
    APE_OLD       : APE_HEADER_OLD; // old header   <= 3.97
    APE_NEW       : APE_HEADER_NEW; // new header   >= 3.98
    APE_DESC      : APE_DESCRIPTOR; // extra header >= 3.98
    BlocksPerFrame: Longword;
    LoadSuccess   : Boolean;
    TagSize       : Integer;
    HeaderPos     : Longint;
begin
  Result := FALSE;
  ResetData;
  TagSize := 0;
  LoadSuccess := FALSE;
  f := nil;
  try
    try
      f := TFileStream.create(FileName, fmOpenRead or fmShareDenyWrite);
      FFileSize := f.Size;
      HeaderPos := FindApeHeader(f);
      f.Seek(HeaderPos, soFromBeginning);
      FillChar(APE, SizeOf(APE), 0);
      if (f.Read(APE, SizeOf(APE)) = SizeOf(APE)) and
         (StrLComp(@APE.cID[0], 'MAC ', 4) = 0) then
      begin
        FVersion := APE.nVersion;
        Str(FVersion / 1000 : 4 : 2, FVersionStr);
        // Load New Monkey's Audio Header for version >= 3.98
        if APE.nVersion >= 3980 then
        begin
          FillChar(APE_DESC, SizeOf(APE_DESC), 0);
          if (f.Read(APE_DESC, SizeOf(APE_DESC)) = SizeOf(APE_DESC)) then
          begin
            // seek past description header
            if APE_DESC.nDescriptorBytes <> 52 then
              f.Seek(APE_DESC.nDescriptorBytes - 52, soFromCurrent);
            // load new ape_header
            if APE_DESC.nHeaderBytes > SizeOf(APE_NEW) then
              APE_DESC.nHeaderBytes := SizeOf(APE_NEW);
            FillChar(APE_NEW, sizeOf(APE_NEW), 0);
            if (Longword(f.Read(APE_NEW, APE_DESC.nHeaderBytes))
                                                  = APE_DESC.nHeaderBytes ) then
            begin
              // based on MAC SDK 3.98a1 (APEinfo.h)
              FSampleRate      := APE_NEW.nSampleRate;
              FChannels        := APE_NEW.nChannels;
              FFormatFlags     := APE_NEW.nFormatFlags;
              FBits            := APE_NEW.nBitsPerSample;
              FCompressionMode := APE_NEW.nCompressionLevel;
              // calculate total uncompressed samples
              if APE_NEW.nTotalFrames > 0 then
              begin
                FTotalSamples := (APE_NEW.nBlocksPerFrame) *
                                 (APE_NEW.nTotalFrames - 1) +
                                 (APE_NEW.nFinalFrameBlocks); 
              end;
              LoadSuccess := TRUE;
            end;
          end;
        end else
        begin
          // Old Monkey <= 3.97
          FillChar(APE_OLD, SizeOf(APE_OLD), 0);
          if (f.Read(APE_OLD, sizeof(APE_OLD)) = sizeof(APE_OLD) ) then
          begin
            FCompressionMode := APE_OLD.nCompressionLevel;
            FSampleRate      := APE_OLD.nSampleRate;
            FChannels        := APE_OLD.nChannels;
            FFormatFlags     := APE_OLD.nFormatFlags;
            FBits            := 16;
            if APE_OLD.nFormatFlags and MONKEY_FLAG_8_BIT <> 0 then FBits :=  8;
            if APE_OLD.nFormatFlags and MONKEY_FLAG_24_BIT <> 0 then FBits := 24;
            FHasSeekElements := APE_OLD.nFormatFlags and MONKEY_FLAG_PEAK_LEVEL     <> 0;
            FWavNotStored    := APE_OLD.nFormatFlags and MONKEY_FLAG_SEEK_ELEMENTS  <> 0;
            FHasPeakLevel    := APE_OLD.nFormatFlags and MONKEY_FLAG_WAV_NOT_STORED <> 0;
            if FHasPeakLevel then
            begin
              FPeakLevel := APE_OLD.qnInt;
              FPeakLevelRatio   := (FPeakLevel / (1 shl FBits) / 2.0) * 100.0;
            end;
            // based on MAC_SDK_397 (APEinfo.cpp)
            if (FVersion >= 3950) then BlocksPerFrame := 73728 * 4 else
            if (FVersion >= 3900) or ((FVersion >= 3800) and
               (APE_OLD.nCompressionLevel = MONKEY_COMPRESSION_EXTRA_HIGH)) then
              BlocksPerFrame := 73728 else
              BlocksPerFrame := 9216;
            // calculate total uncompressed samples
            if APE_OLD.nTotalFrames > 0 then
            begin
              FTotalSamples :=  (APE_OLD.nTotalFrames - 1) *
                                (BlocksPerFrame) +
                                (APE_OLD.nFinalFrameBlocks);
            end;
            LoadSuccess := TRUE;
          end;
        end;
        if LoadSuccess then
        begin
          // compression profile name
          if ((FCompressionMode mod 1000) = 0) and
             (FCompressionMode <= 6000) then
          begin
            FCompressionModeStr := MONKEY_COMPRESSION[FCompressionMode div 1000];
          end else
          begin
            FCompressionModeStr := IntToStr(FCompressionMode);
          end;
          // length
          if FSampleRate > 0 then FDuration := FTotalSamples / FSampleRate;
          // average bitrate
          if FDuration > 0 then FBitrate := (FFileSize - TagSize)* 8.0 /
                                            (FDuration/1000.0); 
          // some extra sanity checks
          FValid := (FBits > 0) and (FSampleRate > 0) and
                    (FTotalSamples > 0) and (FChannels > 0);
          Result := FValid;
        end;
      end;
    finally
      f.Free;
    end;
  except
  end;
end;

{ GetRatio ---------------------------------------------------------------------

  kompressionsrate ermitteln.                                                  }

function TApeFile.GetRatio: Double;
begin
  if FValid then
    Result := FFileSize / (FTotalSamples * (FChannels * FBits / 8) + 44) * 100
  else
    Result := 0;
end;

{ ApeFileIsValid ---------------------------------------------------------------

  ApeFileIsValid prüft, ob es sich um eine gültige Ape-Datei handelt.          }

function TApeFile.ApeFileIsValid: Boolean;
begin
  Result := ReadInfo;
end;

{ TApeFile - public }

constructor TApeFile.Create(const Name: string);
begin
  inherited Create;
  FLength := 0;
  ResetData;
  if FileExists(Name) then
  begin
    FLastError := AIE_NoError;
    FOk        := True;
    FFileName  := Name;
  end else
  begin
    FLastError := AIE_FileNotFound;
    FOk        := False;
    FFileName  := '';
  end;
end;

destructor TApeFile.Destroy;
begin
  inherited Destroy;
end;

{ GetInfo ----------------------------------------------------------------------

  GetInfo sammelt die Informationen über die MPEG-Audio-Datei.                 }

procedure TApeFile.GetInfo;
begin
  if FOk then
  begin
    if ApeFileIsValid then
    begin
      FLength := FDuration;
    end else
    begin
      FLastError := AIE_InvalidApeFile;
    end;
  end else
  begin
    FLastError := AIE_FileNotFound;
  end;
end;

end.
