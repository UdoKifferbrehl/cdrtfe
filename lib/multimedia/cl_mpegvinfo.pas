{ cl_mpegvinfo.pas: Funktionen für MPEG-Video-Dateien

  Copyright (c) 2006-2008 Oliver Valencia

  letzte Änderung  05.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert im wesentlichen auf Informationen von:
  http://www.fr-an.de

  cl_mpegvinfo.pas stellt Funktionen für MPEG-Video-Dateien zur Verfügung.
    * Länge in Sekunden (nach verschiedenen Methoden)
    * Bitrate
    * Stream-Typ: elementary/multiplexed
    * MPEG-Version: 1/2/1-VCD/2-SVCD

  Hinweis: Diese Unit ist noch nicht komplett. Lediglich die Länge von MPEG-
           Dateien im (S)VCD-Format kann bestimmt werden.
    

  TMPEGVideoFile: Objekt, das die Infos über die Datei enthält 

    Properties   Bitrate
                 FileName
                 LastError
                 Length
                 LengthBR
                 LengthSCR
                 StreamType
                 Version

    Methoden     Create(Name: string)
                 GetInfo

}

unit cl_mpegvinfo;

interface

uses Classes, SysUtils;

type TMPEGVideoInfoError = (MVIE_NoError, MVIE_FileNotFound,
                            MVIE_InvalidMPEGFile);

     TMPEGVersion = (V_Unknown, V_MPEG1, V_MPEG2, V_MPEG1_VCD, V_MPEG2_SVCD);

     TMPEGStreamType = (ST_Unknown, ST_Elementary, ST_Multiplexed);

     TSequenceHeader = packed record
       Prefix: array[0..2] of Byte; // Pack start code prefix: $00 $00 $01
       ID    : Byte;                // ID of Pack or Sequence Header
     end;

     TMPEGVideoFile = class(TObject)
     private
       FBitrate   : Integer;
       FFileName  : string;
       FLastError : TMPEGVideoInfoError;
       FLength    : Extended;
       FLengthBR  : Extended;
       FLengthSCR : Extended;
       FOk        : Boolean;
       FSize      : Longint;
       FStreamType: TMPEGStreamType;
       FVersion   : TMPEGVersion;
//     function FindNextHeader(FileIn: TFileStream; const ID: Integer):Longint;
       function FindPreviousHeader(FileIn: TFileStream; const ID: Integer):Longint;
//     function GetGOPTimecode(FileIn: TFileStream; const Position: Integer): Extended;
       function GetMPEGVersion: TMPEGVersion;
       function GetSystemClockReference(FileIn: TFileStream; const Position: Integer; var SCREx: Word): Comp;
       function PackHeaderOK(SeqHdr: TSequenceHeader; const ID: Integer): Boolean;
       procedure GetBitrate(FileIn: TFileStream);
       procedure GetInfoFromFile;
       procedure GetLength(FileIn: TFileStream);
       {Properties}
       function GetLastError: TMPEGVideoInfoError;
     public
       constructor Create(const Name: string);
       destructor Destroy; override;
       procedure GetInfo;
       {Properties}
       property Bitrate   : Integer read FBitrate;
       property FileName  : string read FFileName;
       property LastError : TMPEGVideoInfoError read GetLastError;
       property Length    : Extended read FLength;
       property LengthBR  : Extended read FLengthBR;
       property LengthSCR : Extended read FLengthSCR;
       property StreamType: TMPEGStreamType read FStreamType;
       property Version   : TMPEGVersion read FVersion;
     end;

implementation

const IDSequenceHeader  = $B3;
      IDGOPHeader       = $B8;
      IDPackHeader      = $BA;
      IDSystemHeader    = $BB;

type TPackHeaderEx = packed record
       Prefix  : array[0..3] of Byte;    // Pack start header
       ID      : Byte;                   //
     end;

     TPackHeaderMPEG1 = packed record
       Prefix  : array[0..2] of Byte;   // Pack start code prefix: $00 $00 $01
       ID      : Byte;                  // ID of Pack or Sequence Header
       SCR     : array[0..4] of Byte;   // System Clock Reference
       BitRate : array[0..2] of Byte;   // Multiplex-Bitrate
     end;

     TPackHeaderMPEG2 = packed record
       Prefix  : array[0..2] of Byte;   // Pack start code prefix: $00 $00 $01
       ID      : Byte;                  // ID of Pack or Sequence Header
       SCR     : array[0..5] of Byte;   // System Clock Reference
       BitRate : array[0..2] of Byte;   // Multiplex-Bitrate
       reserved: Byte;                  // reserved
     end;

     TSequenceHeaderEx = packed record
       Prefix  : array[0..2] of Byte;   // Pack start code prefix: $00 $00 $01
       ID      : Byte;                  // ID of Pack or Sequence Header
       Size    : array[0..2] of Byte;   // Width, Height
       ARFR    : Byte;                  // Aspect Ratio / Frame Rate
       BitRate : array[0..2] of Byte;   // Bit Rate / Marker / VBV
       VBV     : Byte;                  // VBV / CPF / IM
       IM      : array[0..127] of Byte; // IM / Non-IM
     end;

     TGOPHeader = packed record
       Prefix  : array[0..2] of Byte;   // Pack start code prefix: $00 $00 $01
       ID      : Byte;                  // ID of Pack or Sequence Header
       TimeCode: array[0..3] of Byte;   // Timecode $ Flags
     end;

{ Hilfsfunktionen ------------------------------------------------------------ }

{ TMPEGVideoFile ------------------------------------------------------------- }

{ TMPEGVideoFile - private }

{ GetLastError -----------------------------------------------------------------

  liefert den aktuellen Fehlerzustand und setzt ihn zurück.                    }

function TMPEGVideoFile.GetLastError: TMPEGVideoInfoError;
begin
  Result := FLastError;
  FLastError := MVIE_NoError;
end;

{ PackHeaderOK -----------------------------------------------------------------

  True, wenn Pack Start Code Prefix in Ordnung ist ($00 $00 $01).              }

function TMPEGVideoFile.PackHeaderOK(SeqHdr: TSequenceHeader;
                                     const ID: Integer): Boolean;
begin
  Result := (SeqHdr.Prefix[0] = 0) and
            (SeqHdr.Prefix[1] = 0) and
            (SeqHdr.Prefix[2] = 1);
  if ID > -1 then
  begin
    Result := Result and (SeqHdr.ID = ID);
  end;
end;

{ FindNextHeader ---------------------------------------------------------------

  liefert die Position des Headers vom gewünschten Typ als Offset von der
  aktuellen Position.                                                          }
(*
function TMPEGVideoFile.FindNextHeader(FileIn: TFileStream;
                                       const ID: Integer):Longint;
var Buffer   : array[0..8191] of Byte;
    BytesRead: Integer;
    i        : Integer;
    Offset   : Longint;
    Ok       : Boolean;
    SeqHdr   : TSequenceHeader;
begin
  Result := -1;
  Offset := 0;
  repeat
    FillChar(Buffer, SizeOf(Buffer), 0);
    BytesRead := FileIn.Read(Buffer, SizeOf(Buffer));
    i := 0;
    {Header in Buffer suchen}
    repeat
      SeqHdr.Prefix[0] := Buffer[i];
      SeqHdr.Prefix[1] := Buffer[i + 1];
      SeqHdr.Prefix[2] := Buffer[i + 2];
      SeqHdr.ID        := Buffer[i + 3];
      Ok := PackHeaderOk(SeqHdr, ID);
      Inc(i);
    until Ok or (i = SizeOf(Buffer) - 3);
    FileIn.Seek(-3, soFromCurrent);
    Offset := Offset + i;
  until Ok or (BytesRead < SizeOf(Buffer));
  if Ok then
  begin
    Result := Offset - 1;
  end;
end; *)

{ FindPreviousHeader -----------------------------------------------------------

  liefert die Position des vorigen Headers vom gewünschten Typ als Offset von
  der aktuellen Position.                                                      }

function TMPEGVideoFile.FindPreviousHeader(FileIn: TFileStream;
                                           const ID: Integer):Longint;
var Buffer   : array[0..8191] of Byte;
    BytesRead: Integer;
    i, j     : Integer;
    Offset   : Longint;
    Ok       : Boolean;
    SeqHdr   : TSequenceHeader;
begin
  Result := -1;
  Offset := 0;
  repeat
    FillChar(Buffer, SizeOf(Buffer), 0);
    FileIn.Seek(-SizeOf(Buffer), soFromCurrent);
    BytesRead := FileIn.Read(Buffer, SizeOf(Buffer));
    i := 8191; j := 0;
    {Header in Buffer suchen}
    repeat
      SeqHdr.Prefix[0] := Buffer[i - 3];
      SeqHdr.Prefix[1] := Buffer[i - 2];
      SeqHdr.Prefix[2] := Buffer[i - 1];
      SeqHdr.ID        := Buffer[i];
      Ok := PackHeaderOk(SeqHdr, ID);
      Dec(i); Inc(j);
    until Ok or (i = 3);
    FileIn.Seek((-2 * SizeOf(Buffer)) + 2, soFromCurrent);
    Offset := Offset + j;
  until Ok or (BytesRead < SizeOf(Buffer));
  if Ok then
  begin
    Result := Offset + 3;
  end;
end;

{ GetSystemClockReference ------------------------------------------------------

  liefert die System Clock Reference des an Position stehenden Pack Headers.   }

function TMPEGVideoFile.GetSystemClockReference(FileIn: TFileStream;
                                                const Position: Integer;
                                                var SCREx: Word): Comp;
var Buffer      : array[0..139] of Byte;
    SCRArray    : array[0..7] of Byte;
    SCRExArray  : array[0..1] of Byte;
    PackHdrMPEG1: ^TPackHeaderMPEG1;
    PackHdrMPEG2: ^TPackHeaderMPEG2;
begin
  PackHdrMPEG1 := @Buffer;
  PackHdrMPEG2 := @Buffer;
  FillChar(SCRArray, SizeOf(SCRArray), 0);
  FillChar(SCRExArray, SizeOf(SCRArray), 0);
  FileIn.Seek(Position, soFromBeginning);
  FileIn.ReadBuffer(Buffer, SizeOf(Buffer));
  if FVersion in [V_MPEG1, V_MPEG1_VCD] then
  begin
    SCRArray[0] := (PackHdrMPEG1^.SCR[4] shr 1) or
                   (PackHdrMPEG1^.SCR[3] shl 7);
    SCRArray[1] := (PackHdrMPEG1^.SCR[3] shr 1) or
                   (PackHdrMPEG1^.SCR[2] and $2) shl 6;
    SCRArray[2] := (PackHdrMPEG1^.SCR[2] shr 2) or
                   (PackHdrMPEG1^.SCR[1] shl 6);
    SCRArray[3] := (PackHdrMPEG1^.SCR[1] shr 2) or
                   (PackHdrMPEG1^.SCR[0] and $6) shl 5;
    SCRArray[4] := (PackHdrMPEG1^.SCR[0] and 8) shr 3;
  end else
  if FVersion in [V_MPEG2, V_MPEG2_SVCD] then
  begin
    SCRArray[0] := (PackHdrMPEG2^.SCR[4] shr 3) or
                   (PackHdrMPEG2^.SCR[3] shl 5);
    SCRArray[1] := (PackHdrMPEG2^.SCR[3] shr 3) or
                   ((PackHdrMPEG2^.SCR[2] and $3) shl 3) or
                   ((PackHdrMPEG2^.SCR[2] and $8) shl 4);
    SCRArray[2] := (PackHdrMPEG2^.SCR[2] shr 4) or
                   (PackHdrMPEG2^.SCR[1] shl 4);
    SCRArray[3] := (PackHdrMPEG2^.SCR[1] shr 4) or
                   ((PackHdrMPEG2^.SCR[0] and $3) shl 4) or
                   ((PackHdrMPEG2^.SCR[0] and $18) shl 3);
    SCRArray[4] := (PackHdrMPEG2^.SCR[0] and $20) shr 5;
    SCRExArray[0] := (PackHdrMPEG2^.SCR[5] shr 1) or
                     ((PackHdrMPEG2^.SCR[4] and $1) shl 7);
    SCRExArray[1] := (PackHdrMPEG2^.SCR[4] and $2) shr 1;

  end;
  Result := Comp(SCRArray);
  SCREx := Word(SCRExArray);
end;

{ GetGOPTimeCode ---------------------------------------------------------------

  liefert den Timecode in Sekunden der an Position stehenden GOP.              }
(*
function TMPEGVideoFile.GetGOPTimecode(FileIn: TFileStream;
                                       const Position: Integer): Extended;
var Buffer       : array[0..7] of Byte;
    GOPHdr       : ^TGOPHeader;
    Hrs, Min, Sec: Byte;
begin
  GOPHdr := @Buffer;
  FileIn.Seek(Position, soFromBeginning);
  FileIn.ReadBuffer(Buffer, SizeOf(Buffer));
  Hrs := GOPHdr^.TimeCode[0] shr 2;
  Min := ((GOPHdr^.TimeCode[0] and $3) shl 4) or (GOPHdr^.TimeCode[1] shr 4);
  Sec := ((GOPHdr^.TimeCode[1] and $7) shl 3) or (GOPHdr^.TimeCode[2] shr 5);
  Result := Sec + Min * 60 + Hrs * 60 * 60;
end; *)

{ GetMPEGVersion ---------------------------------------------------------------

  bestimmt die Art der MPEG-Datei.                                             }

function TMPEGVideoFile.GetMPEGVersion: TMPEGVersion;
var FileIn : TFileStream;
    Buffer : array[0..139] of Byte;
    SeqHdr : ^TSequenceHeader;
    PackHdr: ^TPackHeaderEx;
    Ok     : Boolean;
begin
  FileIn := nil;
  Result := V_Unknown;
  try
    try
      FileIn := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
      FSize := FileIn.Size;
      FileIn.ReadBuffer(Buffer, SizeOf(Buffer));

      SeqHdr := @Buffer;
      PackHdr := @Buffer;           
      {Pack Start Code Prefix?}
      Ok := PackHeaderOk(SeqHdr^, -1);

      {StreamType}
      case SeqHdr^.ID of
        IDSequenceHeader: FStreamType := ST_Elementary;
        IDPackHeader    : FStreamType := ST_Multiplexed;
      end;
                     
      {MPEG-Version}
      if Ok and (FStreamType = ST_Elementary) then
      begin
        // not implemented yet
      end else
      if Ok and (FStreamType = ST_Multiplexed) then
      begin
        if (PackHdr^.ID and $F0) = $20 then Result := V_MPEG1;
        if (PackHdr^.ID and $C0) = $40 then Result := V_MPEG2;
        
        {Packet size: 2048 oder 2324 Byte?}
        FileIn.Seek(2324, soFromBeginning);
        FileIn.ReadBuffer(Buffer, SizeOf(Buffer));
        if PackHeaderOk(SeqHdr^, IDPackHeader) then
        begin
          Result := Succ(Succ(Result));
        end;
      end;
    except
      {Fehler beim Lesen}
      FLastError := MVIE_FileNotFound;
    end;
  finally
    FileIn.Free;
  end;
end;

{ GetBitrate -------------------------------------------------------------------

  ermittelt die Gesamt-Bitrate der Datei.                                      }

procedure TMPEGVideoFile.GetBitrate(FileIn: TFileStream);
var Buffer      : array[0..139] of Byte;
    BitrateArray: array[0..3] of Byte;
    PackHdrMPEG1: ^TPackHeaderMPEG1;
    PackHdrMPEG2: ^TPackHeaderMPEG2;
begin
  {Bitrate}
  FillChar(BitrateArray, SizeOf(BitrateArray), 0);
  FileIn.Seek(0, soFromBeginning);
  FileIn.ReadBuffer(Buffer, SizeOf(Buffer));
  if FStreamType = ST_Elementary then
  begin
    // not implemented yet
  end else
  if FStreamType = ST_Multiplexed then
  begin
    if FVersion in [V_MPEG1, V_MPEG1_VCD] then
    begin
      PackHdrMPEG1 := @Buffer;
      BitrateArray[0] := (PackHdrMPEG1^.Bitrate[2] shr 1) or
                         (PackHdrMPEG1^.Bitrate[1] shl 7);
      BitrateArray[1] := (PackHdrMPEG1^.Bitrate[1] shr 1) or
                         (PackHdrMPEG1^.Bitrate[0] shl 7);
      BitrateArray[3] := (PackHdrMPEG1^.Bitrate[0] and $3F) shr 1;
    end else
    if FVersion in [V_MPEG2, V_MPEG2_SVCD] then
    begin
      PackHdrMPEG2 := @Buffer;
      BitrateArray[0] := (PackHdrMPEG2^.Bitrate[2] shr 2) or
                         (PackHdrMPEG2^.Bitrate[1] shl 6);
      BitrateArray[1] := (PackHdrMPEG2^.Bitrate[1] shr 2) or
                         (PackHdrMPEG2^.Bitrate[0] shl 6);
      BitrateArray[3] := (PackHdrMPEG2^.Bitrate[0] and $FC) shr 2;
    end;
  end;
  FBitrate := Integer(BitrateArray) * 400;
end;

{ GetLength --------------------------------------------------------------------

  bestimmt die Länge der MPEG-Datei in Sekunden.
  SCR: System Clock Reference (90kHz), System Clock Reference Extension (27MHz)}

procedure TMPEGVideoFile.GetLength(FileIn: TFileStream);
var TimeBR        : Extended;
    TimeSCR       : Extended;
//  TimeGOP       : Extended;
//  GOP1, GOP2    : Extended;
    SCR1, SCR2    : Comp;
    SCR1Ex, SCR2Ex: Word;
    Position      : Integer;
begin
  TimeBR := 0;
  TimeSCR := 0;
  {Bestimmung über Dateigröße und Gesamt-Bitrate}
  if FBitrate > 0 then
  begin
    TimeBR := FSize / FBitrate * 8;
  end;

  {Dauer nach System Clock Reference}
  if FStreamType = ST_Multiplexed then
  begin
    {SCR des ersten Pack Headers}
    SCR1 := GetSystemClockReference(FileIn, 0, SCR1Ex);
    {SCR des letzten Pack Headers}
    FileIn.Seek(0, soFromEnd);
    Position := FindPreviousHeader(FileIn, IDPackHeader);
    SCR2 := GetSystemClockReference(FileIn, FSize - Position, SCR2Ex);
    if FVersion in [V_MPEG1, V_MPEG1_VCD] then
    begin
      TimeSCR := (SCR2 - SCR1) / 90000;
    end else
    if FVersion in [V_MPEG2, V_MPEG2_SVCD] then
    begin
      SCR1 := SCR1 * 300 + SCR1Ex;
      SCR2 := SCR2 * 300 + SCR2Ex;
      TimeSCR := (SCR2 - SCR1) / 27000000;
    end;
  end;

  FLengthBR := TimeBR;
  FLengthSCR := TimeSCR;
  {Wir nehmen als Länge das Maximum der beiden Werte.}
  if FLengthBR > FLengthSCR then
    FLength := FLengthBR else
    FLength := FLengthSCR;
end;

{ GetInfoFromFile --------------------------------------------------------------

  sammelt die Informationen über die MPEG-Datei.                               }

procedure TMPEGVideoFile.GetInfoFromFile;
var FileIn: TFileStream;
begin
  FileIn := nil;
  try
    try
      FileIn := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
      GetBitrate(FileIn);
      GetLength(FileIn);
    except
    end;
  finally
    FileIn.Free;
  end;
end;

{ TMPEGVideoFile - public }

constructor TMPEGVideoFile.Create(const Name: string);
begin
  inherited Create;
  FBitrate    := 0;
  FLength     := 0;
  FSize       := 0;
  FStreamType := ST_Unknown;
  FVersion    := V_Unknown;
  if FileExists(Name) then
  begin
    FLastError := MVIE_NoError;
    FOk        := True;
    FFileName  := Name;
  end else
  begin
    FLastError := MVIE_FileNotFound;
    FOk        := False;
    FFileName  := '';
  end;
end;

destructor TMPEGVideoFile.Destroy;
begin
  inherited Destroy;
end;

{ GetInfo ----------------------------------------------------------------------

  GetInfo sammelt die Informationen über die MPEG-Video-Datei.                 }

procedure TMPEGVideoFile.GetInfo;
begin
  if FOk then
  begin
    FVersion := GetMPEGVersion;
    if FVersion = V_Unknown then
    begin
      FLastError := MVIE_InvalidMPEGFile;
    end else
    begin
      GetInfoFromFile;
    end;
  end;
end;

end.

