{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_cdtext.pas: CD-Text-Funktionen

  Copyright (c) 2004-2005 Oliver Valencia

  letzte Änderung  25.05.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.
  
  Diese Unit basiert im wesentlichen auf Informationen aus dem MMC3-Standard,
  Revsion 01, Anhang J. Weitere Informationen stammen aus cdtext.c, cdtext.h,
  die Teil des cdrtools-Quellcodes (Copyright 1998-2004 J. Schilling, zu finden
  unter ftp.berlios.de/pub/cdrecord) sind.

  f_cdtext.pas stellt CD-Text-Funktionen zu Verfügung
    * Erzeugung einer Datei, die den CD-Text in einer für cdrecord geeigneten
      Form enthält
    * Hilfsfunktionen für die internen Zugriffe auf CD-Text-Daten


  exportierte Funktionen/Prozeduren:

    TextTrackDataToString(const TextData: TCDTextTrackData): string
    CreateCDTextFile(const Name: string; TextData: TStringList)
    StringToTextTrackData(const S: string; var TextData: TCDTextTrackData)


  Erläuterungen:
  ==============

  CD-Text-Informationen werden sich wiederholend im Lead-In-Bereich gespeichert.
  Die sich wiederholden Daten heißen Textgruppe (Text Group). Die Textgruppe
  besteht aus bis zu 8 Blöcken (Blocks). Jeder Block repräsentiert eine Sprache
  und besteht aus bis zu 255 Datenpaketen (Pack Data).

  Ein Datenpaket ist 18 Bytes lang: 4 Bytes Headerinformationen, 12 Bytes Text-
  daten, 2 Bytes Prüfsumme:

    Byte 0: Header Field ID1: Pack Type Indicator: $80 bis $87
            $80: Album Titel, wenn ID2 = $00
                 Track Titel, wenn ID2 = $01 - $63
            $81: Album Performer, wenn ID2 = $00;
                 Track Performer, wenn ID2 = $01 - $63
            $82: Songwriter
            $83: Composer
            $84: Arranger
            $85: Message
            $86 - $8E: hier nicht verwendet
            $8F: Größeninformation über Block (3 Packs, s. Beispiel)

    Byte 1: Header Field ID2: Pack Type Indicator: Extension Flag/Track Number
            Track, zu dem der Texteintrag gehört. Die übrigen Funktionen
            spielen hier keine Rolle.

    Byte 2: Header Field ID3: Pack Type Indicator: Sequence Number
            Mit jedem Paket innerhalb einer Blocks wird die Sequenznummer um 1
            erhöht, von $00 bis $FF.

    Byte 3: Header Field ID4: Block Number, Character Position
            Bit 7 (MSB): 0 = Single Byte Character Code
                         1 = Double Byte Character Code
            Bit 4 - 6  : Blocknummer. Hier immer Null, da cdrtfe nur eine
                         Sprache unterstützt.
            Bit 0 - 3  : Anzahl der Zeichen aus dem vorigen Paket, die zu diesem
                         gehören. 15 gibt an, daß das erste Zeichen des Pakets
                         zum Vor-Vorgänger gehört. (?)
                         Das Nullzeichen wird mitgezählt.

    Bytes 4 - 15: Textdaten in ASCII. Das Nullzeichen (#0) zeigt das Ende eines
            Strings an. Ein String muß weniger als 160 Zeichen haben. Wenn
            ein String nicht in das Textfeld eines Pakets paßt, wird er im
            nächsten Paket fortgeführt. Der nächste String folgt dann direkt auf
            die Endmarkierung (#0) des Vorgängers.
            Nicht genutzte Bytes eines Textfeldes sollten mit Nullzeichen aufge-
            füllt werden.

    Bytes 16, 17: CRC16-Prüfsumme über Bytes 0 bis 15.

  Beispiel:
  =========

  Album Name - Performer  :    Test-Sampler           -  Various  
  Track Title - Performer : 1  To Be With You (live)  -  Westlife
                            2  Alla fiera dell'est    -  Angelo Branduardi

  Byte
  0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16  17

  +-Pack Type
  |   +-Track Number
  |   |   +-Sequence Number
  |   |   |   +-Block Number, Character Position
  |   |   |   |   +-----------------Text Data-------------------+ +CRC16+
  ID1 ID2 ID3 ID4 |                                             | |     |
  $80 $00 $00 $00 $54 $65 $73 $74 $2D $53 $61 $6D $70 $6C $65 $72 $15 $E3
                    T   e   s   t   -   S   a   m   p   l   e   r

  $80 $00 $01 $0C $00 $54 $6F $20 $42 $65 $20 $57 $69 $74 $68 $20 $84 $44
                   #0   T   o       B   e       W   i   t   h

  $80 $01 $02 $0B $59 $6F $75 $20 $28 $6C $69 $76 $65 $29 $00 $41 $A0 $0C
                    Y   o   u       (   l   i   v   e   )  #0   A

  $80 $02 $03 $01 $6C $6C $61 $20 $66 $69 $65 $72 $61 $20 $64 $65 $CB $37
                    l   l   a       f   i   e   r   a       d   e

  $80 $02 $04 $0D $6C $6C $27 $65 $73 $74 $00 $00 $00 $00 $00 $00 $23 $5C
                    l   l   '   e   s   t  #0  #0  #0  #0  #0  #0


  $81 $00 $05 $00 $56 $61 $72 $69 $6F $75 $73 $00 $57 $65 $73 $74 $20 $00
                    V   a   r   i   o   u   s  #0   W   e   s   t

  $81 $01 $06 $04 $6C $69 $66 $65 $00 $41 $6E $67 $65 $6C $6F $20 $89 $FC
                    l   i   f   e  #0   A   n   g   e   l   o

  $81 $02 $07 $07 $42 $72 $61 $6E $64 $75 $61 $72 $64 $69 $00 $00 $6D $81
                    B   r   a   n   d   u   a   r   d   i  #0  #0


  $8F $00 $08 $00 $00 $01 $02 $00 $05 $03 $00 $00 $00 $00 $00 $00 $F3 $00
                  |   |   |   |   |   |
                  |   |   |   |   |   |
                  |   |   |   |   |   +-Number of sequences for pack type $81
                  |   |   |   |   +-Number of sequences for pack type $80
                  |   |   |   +-Copyright flags
                  |   |   +-Last track
                  |   +-First track
                  +-Charcode

  $8F $01 $09 $00 $00 $00 $00 $00 $00 $00 $00 $03 $0A $00 $00 $00 $36 $1B
                                              |   |
                                              |   +-Last sequence number
                                              |+-Number of Size Packs

  $8F $02 $0A $00 $00 $00 $00 $00 $09 $00 $00 $00 $00 $00 $00 $00 $87 $ED
                                  |
                                  +- Language code

}

unit f_cdtext;

{$I directives.inc}

interface

uses Classes, Windows, SysUtils;

type TCDTextTrackData = record
       Title      : string;
       Performer  : string;
       Songwriter : string;
       Composer   : string;
       Arranger   : string;
       TextMessage: string;
     end;

function TextTrackDataToString(const TextTrackData: TCDTextTrackData): string;
procedure CreateCDTextFile(const Name: string; TextData: TStringList);
procedure StringToTextTrackData(const S: string; var TextTrackData: TCDTextTrackData);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_strings, f_crc;

const {Pack Type Indicator}
      PTI_TITLE       = $80; // Album name and Track titles
      PTI_PERFORMER   = $81; // Singer/player/conductor/orchestra
      PTI_SONGWRITER  = $82; // Name of the songwriter
      PTI_COMPOSER    = $83; // Name of the composer
      PTI_ARRANGER    = $84; // Name of the arranger
      PTI_MESSAGE     = $85; // Message from content provider or artist
      PTI_DISK_ID     = $86; // Disk identification information
      PTI_GENRE       = $87; // Genre identification / information
      PTI_TOC	      = $88; // TOC information
      PTI_TOC2        = $89; // Second TOC
      PTI_RES_8A      = $8A; // Reserved 8A
      PTI_RES_8B      = $8B; // Reserved 8B
      PTI_RES_8C      = $8C; // Reserved 8C
      PTI_CLOSED_INFO = $8D; // For internal use by content provider
      PTI_ISRC        = $8E; // UPC/EAN code of album and ISRC for tracks
      PTI_SIZE        = $8F; // Size information of the block

      {Character Codes}
      CC_8859_1       = $00; // ISO 8859-1
      CC_ASCII        = $01; // ISO 646, ASCII (7 bit)
      CC_RESERVED_02  = $02; // Reserved codes 0x02..0x7f
      CC_KANJI        = $80; // Music Shift-JIS Kanji
      CC_KOREAN       = $81; // Korean
      CC_CHINESE      = $82; // Mandarin Chinese
      CC_RESERVED_83  = $83; // Reserved codes 0x83..0xFF

      {Language Codes}
      LANG_ENGLISH    = 9;

{ Typentsprechungen:
  C                 Delphi
  -----------------------------
  unsigned char     Byte
  char              Shortint                                                   }

type TTextPack = packed record
       PackType   : Byte;                       // Pack Type Indicator
       TrackNo    : Shortint;                   // Track Number (0..99)
       SeqNumber  : Shortint;                   // Sequence Number
       BlockNumber: Shortint;	                // Block # / Char pos
       Text       : array[0..11] of char;       // CD-Text Data field
       CRC        : array[0..1] of Byte;        // CRC 16
     end;

     TTextSizeInfo = packed record
       CharCode     : Shortint;                 // Character Code
       FirstTrack   : Shortint;                 // Number of first track
       LastTrack    : Shortint;                 // Number of last track
       CopyrFlags   : Shortint;                 // Copyright flags
       PackCount    : array[0..15] of Shortint; // Number of packs for each packtype $80 - $8E, $8F: number of packs
       LastSeqNum   : array[0..7] of Shortint;  // LastSeqNum[0] = Last Sequence Number of Block
       LanguageCodes: array[0..7] of Shortint;  // Language
     end;

     TTextArgs = packed record
       TextPack    : ^TTextPack;                // Pointer to current text pack
       TextSizeInfo: ^TTextSizeInfo;            // Poiter to Record with size information
       TargetPos   : PChar;                     // Pointer to current position in the text field of a text pack
       SeqNumber   : Integer;                   // Number of sequences
     end;


{ DisplayTextPack --------------------------------------------------------------

  Zeigt das aktuelle Text Pack in hexadezimaler Darstellung an.                }

{$IFDEF DebugCreateCDText}
procedure DisplayTextPack(TextArgs: TTextArgs);
var i, value: Byte;
    s1, s2, s3, Temp: string;
begin
  {Hex-Werte ausgeben}
  s1 := '';
  s2 := '';
  s3 := '';
  for i := 0 to 17 do
  begin
    value := Byte(Ptr(Integer(TextArgs.TextPack) +  i)^);
    s1 := s1 + '$' + IntToHex(value, 2) + ' ';
    if (i > 3) and (i < 16) then              // Ausgabe nur für Textbereich
    begin
      if value = 0 then                       // Endmarkierung
      begin
       s2 := s2 + ' #0 ';
       s3 := s3 + ' ';
      end else
      if (value > 31) and (value < 128) then  // druckbare ASCII-Zeichen
      begin
        s2 := s2 + '  ' + Chr(value) + ' ';
        s3 := s3 + Chr(value);
      end else
      s2 := s2 + '    ';
    end else
    s2 := s2 + '    ';
  end;
  with TextArgs.TextPack^ do
  begin
    Temp := Temp + 'PT: $' + IntToHex(PackType, 2) + '; ';
    Temp := Temp + 'Track: ' + Format('%.2d', [TrackNo]) + '; ';
    Temp := Temp + 'Seq: ' + Format('%.2d', [Byte(SeqNumber)]) + ': ' + s3;
  end;
  FormDebug.Memo1.Lines.Add(Temp);
  FormDebug.Memo2.Lines.Add(s1 + #13#10 + s2);
end;

procedure DisplayText(Text: PChar; Track: Integer; PackType: Integer);
begin
  if Track = 0 then
  begin
    case PackType of
      $80: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Album Title: ' + string(Text));
      $81: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Album Performer: ' + string(Text));
      $82: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Album Songwriter: ' + string(Text));
      $83: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Album Composer: ' + string(Text));
      $84: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Album Arranger: ' + string(Text));
      $85: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Album Message: ' + string(Text));
    end;
  end else
  begin
    case PackType of
      $80: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Performer: ' + string(Text));
      $81: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Title: ' + string(Text));
      $82: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Songwriter: ' + string(Text));
      $83: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Composer: ' + string(Text));
      $84: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Arranger: ' + string(Text));
      $85: FormDebug.Memo3.Lines.Add('Track ' + IntToStr(Track) +
                                     ': Message: ' + string(Text));
    end;
  end;
end;
{$ENDIF}

{ GetCDTextByType --------------------------------------------------------------

  liefert den PackType entsprechenden Eintrag aus den Track-Informationen.     }

function GetCDTextByType(const TrackText: string; PackType: Integer): string;
var TextTrackData: TCDTextTrackData;
begin
  StringToTextTrackData(TrackText, TextTrackData);
  with TextTrackData do
  begin
    case PackType of
      $80: Result := Title;
      $81: Result := Performer;
      $82: Result := Songwriter;
      $83: Result := Composer;
      $84: Result := Arranger;
      $85: Result := TextMessage;
    else
      Result := '';
    end;
  end;
end;

{ CDTextAvailable --------------------------------------------------------------

  ergibt True, wenn zum angegebenen Pack Type Textdatan gefunden wurden.       }

function CDTextAvailable(TextData: TStringList; PackType: Integer): Boolean;
var i: Integer;
begin
  Result := False;
  for i := 0 to TextData.Count - 1 do
  begin
    Result := Result or (GetCDTextByType(TextData[i], PackType) <> '');
  end;
end;

{ FillCRC ----------------------------------------------------------------------

  das aktuelle Text Pack mit einer CRC Prüfsumme versehen. Die Prüfsumme wird
  über die ersten 16 Byte gebildet, dann invertiert und in die letzen beiden
  Bytes geschrieben.                                                           }

procedure FillCRC(var TextArgs: TTextArgs);
var CRC: Word;
begin
   CRC := UpdateCRC16A(0, TextArgs.TextPack, 16);
   CRC := not CRC;
   TextArgs.TextPack^.CRC[0] := Hi(CRC); // (CRC shr 8) and $FF;
   TextArgs.TextPack^.CRC[1] := Lo(CRC); // CRC and $FF;
   {Debuggung: fertiges Text Pack anzeigen}
   {$IFDEF DebugCreateCDText}
   DisplayTextPack(TextArgs);
   {$ENDIF}
end;

{ FillupPack -------------------------------------------------------------------

  FillupPack füllt, falls nötig, das letzte Pack eines Pack Types auf.         }

procedure FillupPack(var TextArgs: TTextArgs);
var TargetPointer: PChar;
begin
  TargetPointer := TextArgs.TargetPos;
  if TargetPointer <> nil then
  begin
    while TargetPointer <= @TextArgs.TextPack^.Text[11] do
    begin
      TargetPointer^ := #0;
      inc(TargetPointer);
    end;
    if TargetPointer > @TextArgs.TextPack^.Text[11] then
    begin
      FillCRC(TextArgs);
      inc(TextArgs.TextPack);
      TargetPointer := nil;
      TextArgs.TargetPos := TargetPointer;
    end;
  end;
end;

{ FillPacks --------------------------------------------------------------------

  FillPacks zerlegt den String in einzelne Packs.                              }

procedure FillPacks(var TextArgs: TTextArgs; Source: PChar;
                    len, TrackNumber, PackType: Byte);
var CharPos : Integer;
    TargetPointer: PChar;  // Adresse der aktuellen Position im Textfeld
    SourcePointer: PChar;  // Adresse der aktuellen Position im Quellstring
begin
  CharPos := 0;
  {Alte Position im Textfeld holen; falls das letzte Feld komplett gefüllt
   wurde ist TargetPointer nil.}
  TargetPointer := TextArgs.TargetPos;
  {SourcePointer auf Anfangsadresse des Quellstrings setzen}
  SourcePointer := Source;
  repeat
    {Wenn das letzte Feld vollständig gefüllt wurde, zeigt TextPack bereits auf
     den nachfolgenden Speicherbereich. Es müssen aber noch die Header-Felder
     gesetzt werden.}
    if TargetPointer = nil then
    begin
      {TargetPointer auf den Anfang des Textfeldes innerhalb des Packs setzen.}
      TargetPointer := TextArgs.TextPack^.Text;
      TextArgs.TextPack^.PackType  := PackType;
      TextArgs.TextPack^.TrackNo   := TrackNumber;
      TextArgs.TextPack^.SeqNumber := TextArgs.SeqNumber;
      inc(TextArgs.SeqNumber);
      if PackType <> $8F then
      begin
        inc(TextArgs.TextSizeInfo^.PackCount[PackType - $80]);
      end;
      if CharPos < 15 then
        TextArgs.TextPack^.BlockNumber := CharPos
      else
        TextArgs.TextPack^.BlockNumber := 15;
    end;
    {Solange das Ende des Textfeldes nicht erreicht ist (die aktuelle Adresse
     kleiner oder gleich der Adresse der letzen Position im Textfeld ist) oder
     noch Zeichen im Quellstring sind (len > 0), Zeichen aus dem Quellstring ins
     Textfeld kopieren.}
    while (len > 0) and (TargetPointer <= @TextArgs.TextPack^.Text[11]) do
    begin
      TargetPointer^ := SourcePointer^;
      dec(len);
      inc(TargetPointer);
      inc(SourcePointer);
      inc(CharPos);
    end;
    {Ist das Textfeld gefüllt, muß noch die Prüfsumme berechnet werden. Dann
     den Record zum nächsten Text Pack verschieben.}
    if TargetPointer > @TextArgs.TextPack^.Text[11] then
    begin
      FillCRC(TextArgs);
      {inc erhöht die Adresse um die Größe des Typs TTextPack (= 18 Byte)}
      inc(TextArgs.TextPack);
      TargetPointer := nil;
    end;
  until len = 0;
  {Aktuelle Position im Textfeld sichern.}
  TextArgs.TargetPos := TargetPointer;
end;

{ PackText ---------------------------------------------------------------------

  CD-Text formatieren.                                                         }

procedure PackText(var TextArgs: TTextArgs; TextData: TStringList);
var PackType: Integer;
    i       : Integer;
    s       : array[0..255] of Char;
begin
  {Initialisierungen}
  with TextArgs.TextSizeInfo^ do
  begin
    CharCode         := CC_8859_1;        // ISO-8859-1 Zeichensatz
    FirstTrack       := 1;                // cdrtfe fängt immer mit Track 1 an
    LastTrack        := TextData.Count - 1;
    CopyrFlags       := 0;                // keine Einschränkungen
    PackCount[15]    := 3;                // 3 size packs
    LastSeqNum[0]    := 0;                // Startwert
    LanguageCodes[0] := LANG_ENGLISH;
  end;

  {CD-Text formatieren: Normalerweise müßten wir über alle Pack-Types iterieren,
   aber cdrtfe verwendet nur Pack-Types $80 bis $85 (Title, Performer,
   Songwriter, Composer, Arranger, Message).}
  for PackType := $80 to $85 do
  begin
    {Wenn Textdaten vorhanden sind,}
    if CDTextAvailable(TextData, PackType) then
    {alle Tracks durchgehen}
    for i := 0 to TextData.Count - 1 do
    begin
      ZeroMemory(@s, SizeOf(s));
      {in Abhängigkeit von PackType benötigen wir Titel oder Performer}
      StrPCopy(s, GetCDTextByType(TextData[i], PackType));
      if StrLen(s) > 0 then
      begin
        {Wir übergeben eine Länge von StrLen(s) + 1, weil wir auch das #0 in
         das Text Pack übernehmen müssen.}
        FillPacks(TextArgs, s, StrLen(s) + 1, i, PackType);
      end else
      begin
        FillPacks(TextArgs, '', 1, i, PackType);
      end;
      {$IFDEF DebugCreateCDText}
      DisplayText(s, i, PackType);
      {$ENDIf}
    end;
    FillupPack(TextArgs);
  end;

  {Der CD-Text liegt jetzt formatiert in Paketen im Puffer. Nun müssen noch die
   Informationen über Größe, Zeichensatz usw. hinzugefügt werden. Das sind ins-
   gesamt 3 Sequenzen, TextArgs.SeqNumber ist um 1 voraus, fehlen noch 2.      }
  TextArgs.TextSizeInfo^.LastSeqNum[0] := TextArgs.SeqNumber + 2;
  
  {Nun wird der Inhalt von TextSizeInfo (36 Bytes) in 3 Paketen zu je 12 Bytes
   als Text an FillPacks übergeben. PackType ist $87.
   FillPacks erwartet eigentlich einen String vom Typ PChar, aber da auch eine
   Längenangabe übergeben wird, brauchen wir das #0 nicht und können trotzdem
   einfach die Adresse der als Text anzusehen Daten angeben.                   }
  for i := 0 to 2 do
  begin
    FillPacks(TextArgs, @PChar(TextArgs.TextSizeInfo)[i * 12], 12, i, $8F);
  end;

end;

{ CreateCDTextFile -------------------------------------------------------------

  erzeugt eine Datei mit CD-Text-Informationen, die cdrecord verwenden kann.
  Name     : Dateiname
  TextData : CD-Text-Daten in einer String-Liste:
             TextData[0]    :  Albuminformationen
             TextData[1..99]:  Trackinformationen
             Format: Title|Performer|Songwriter|Composer|Arranger|Message
  Die aufbereiteten Daten werden direkt im Speicher in SeqBuffer gehalten. Um
  den Zugriff auf einzelne Text-Packs zu vereinfachen, wird ein Record vom Typ
  TTextPack verwendet. Zu Beginn zeigen Record und SeqBuffer auf die gleiche
  Adresse. Der Record wird als Schablone verwendet, und für jedes neue Text-Pack
  wird seine Anfangsadresse über den Puffer um die Größe des Records (18 Bytes)
  verschoben.
  Ein Block besteht aus bis zu 255 Text-Packs, wobei 3 Pakete Größeninfos ent-
  halten. Somit stehen für die CD-Text-Daten noch 252 Pakete zur Verfügung. Das
  aufrufende Programm hat dafür zu sorgen, daß die CD-Text-Daten nicht größer
  als 255*12 Byte sind, wobei für jeden String ein zusätzliches Nullzeichen
  (#0) als Endmarkierung mitgezählt werden muß.
  Ebenso muß der Aufrufer dafür sorgen, daß jeder einzelne String kürzer als
  160 Zeichen ist.                                                             }

procedure CreateCDTextFile(const Name: string; TextData: TStringList);
var SeqBuffer   : array[0..256*18] of Byte;
    OutFile     : TFileStream;
    TextSizeInfo: TTextSizeInfo;
    TextArgs    : TTextArgs;
begin
  ZeroMemory(@TextSizeInfo, SizeOf(TextSizeInfo));
  ZeroMemory(@SeqBuffer, SizeOf(SeqBuffer));
  {Variablen zusammenstellen}
  TextArgs.TextPack     := @SeqBuffer;
  TextArgs.TextSizeInfo := @TextSizeInfo;
  TextArgs.TargetPos    := nil;
  TextArgs.SeqNumber    := 0;
  {CD-Text formatieren}
  PackText(TextArgs, TextData);
  {Datei erzeugen}
  OutFile := TFileStream.Create(Name, fmCreate);
  OutFile.WriteBuffer(SeqBuffer, TextArgs.SeqNumber * 18);
  OutFile.Free;
end;

{ TextTrackDataToString --------------------------------------------------------

  setzt die Daten aus dem Record zu einem String zusammen.                     }

function TextTrackDataToString(const TextTrackData: TCDTextTrackData): string;
begin
  with TextTrackData do
  Result := Title + '|' + Performer + '|' + Songwriter + '|' +
            Composer + '|' + Arranger + '|' + TextMessage;
end;

{ StringToTextTrackData --------------------------------------------------------

  setzt die Daten aus dem Record zu einem String zusammen.                     }

procedure StringToTextTrackData(const S: string;
                                var TextTrackData: TCDTextTrackData);
var Temp: string;
begin
  with TextTrackData do
  begin
    SplitString(S, '|', Title, Temp);
    SplitString(Temp, '|', Performer, Temp);
    SplitString(Temp, '|', Songwriter, Temp);
    SplitString(Temp, '|', Composer, Temp);
    SplitString(Temp, '|', Arranger, TextMessage);
  end;
end;

end.
