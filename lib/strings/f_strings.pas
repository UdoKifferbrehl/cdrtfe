{ f_strings.pas: String-Funktionen

  Copyright (c) 2004-2013Oliver Valencia

  letzte Änderung  29.06.2013

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_strings.pas stellt String-Funktionen zur Verfügung


  exportierte Funktionen/Prozeduren:

    CountChar(const s: string; const c: Char): Integer
    EnumToStr(ArgType: PTypeInfo; var Arg): string
    FormatTime(const Time: Extended): string
    GetValueFromString(const s: string): string
    IsQuoted(const S: string): Boolean
    Quote(const S: string): string
    QuotePath(const S: string): string
    ReplaceChar(s: string; const SearchChar, ReplaceChar: Char): string
    ReplaceCharFirst(s: string; const SearchChar, ReplaceChar: Char): string
    ReplaceString(s: string; const SearchString, ReplaceString: string): string
    SizeToString(const Size: Longint): string
    SizeToStringSetUnits(const B, KiB, MiB, GiB: string);
    SplitString(Source, Delimiter: string; var Target1, Target2: string)
    StringLeft(const Source, Delimiter: string): string;
    StringRight(const Source, Delimiter: string): string;
    StrToFloatDef(const S: string; Default: Extended): Extended
    TryUTF8ToAnsi(const S: string): string
    UnescapeString(s: string): string
    UnQuote(const S: string): string

}

unit f_strings;

{$I directives.inc}

interface

uses SysUtils, TypInfo,
     f_largeint;

{ 'statische' Variablen }
var UnitByte  : string = 'Byte';    // für SizeToString, damit eine Übersetzung
    UnitKiByte: string = 'KiByte';  // möglich ist, ohne cl_lang.pas einzubinden
    UnitMiByte: string = 'MiByte';
    UnitGiByte: string = 'GiByte';

function CountChar(const s: string; const c: Char): Integer;
function EnumToStr(ArgType: PTypeInfo; var Arg): string;
function FormatTime(const Time: Extended): string;
function GetValueFromString(const s: string): string;
function IsQuoted(const S: string): Boolean;
function Quote(const S: string): string;
function QuotePath(const S: string): string;
function ReplaceChar(s: string; const SearchChar, ReplaceChar: Char): string;
function ReplaceCharFirst(s: string; const SearchChar, ReplaceChar: Char): string;
function ReplaceString(s: string; const SearchString, ReplaceString: string): string;
function SizeToString(const Size: Int64): string;
function StringLeft(const Source, Delimiter: string): string;
function StringRight(const Source, Delimiter: string): string;
function StrToFloatDef(const S: string; Default: Extended): Extended;
function TryUTF8ToAnsi(const S: string): string;
function UnescapeString(s: string): string;
function UnQuote(const S: string): string;
procedure SplitString(Source, Delimiter: string; var Target1, Target2: string);
procedure SizeToStringSetUnits(const B, KiB, MiB, GiB: string);

implementation

{uses}

{ SizeToString -----------------------------------------------------------------

  SizeToString erzeugt aus einem Longint einen je nach Größe in Byte, KiByte,
  MiByte oder GiByte ungerechneten und in einen String umgewandelten Wert inkl.
  Einheit.                                                                     }

function SizeToString(const Size: Int64): string;
var SizeKB: Double;
    SizeMB: Double;
    SizeGB: Double;
begin
  SizeKB := Size / 1024;
  SizeMB := SizeKB / 1024;
  SizeGB := SizeMB / 1024;
  if SizeKB < 1 then
  begin
    Result := FloatToStr(Size) + ' ' + UnitByte; //' Byte';
  end else
  if SizeMB < 1 then
  begin
    Result := FormatFloat('#,###.##', SizeKB) + ' ' + UnitKiByte; //' KiByte';
  end else
  if SizeGB < 1 then
  begin
    Result := FormatFloat('#,###.##', SizeMB) + ' ' + UnitMiByte; //' MiByte';
  end else
  begin
    Result := FormatFloat('#,###.##', SizeGB) + ' ' + UnitGiByte; //' GiByte';
  end;
end;

{ SizeToStringSetUnits ---------------------------------------------------------

  ermöglicht es, die Bezeichnungen für die Einheiten zu ändern. Damit können die
  Einheiten übersetzt werden, ohne cl_lang.pas einzubinden.                    }

procedure SizeToStringSetUnits(const B, KiB, MiB, GiB: string);
begin
  UnitByte   := B;
  UnitKiByte := KiB;
  UnitMiByte := MiB;
  UnitGiByte := GiB;
end;

{ FormatTime -------------------------------------------------------------------

  wandelt eine in Sekunden übergebene Zeit in einen String um. Format: min:sek.}

function FormatTime(const Time: Extended): string;
var Minuten: Integer;
    Sekunden: Double;
begin
  Minuten := Round(Int(Time)) div 60;
  Sekunden := Time - (Minuten * 60);
  Result := IntToStr(Minuten) + ':' + FormatFloat('00.00', Sekunden);
end;

{ ReplaceChar ------------------------------------------------------------------

  ReplaceChar ersetzt im String s alle SearchChar durch ReplaceChar.           }

function ReplaceChar(s: string; const SearchChar, ReplaceChar: Char): string;
var i: Integer;
begin
  for i := 1 to Length(s) do
  begin
    if s[i] = SearchChar then
    begin
      s[i] := ReplaceChar;
    end;
  end;
  Result := s;
end;

{ ReplaceCharFirst -------------------------------------------------------------

  ReplaceCharFirst ersetzt im String s das erste Vokommen von SearchChar durch
  ReplaceChar.                                                                 }

function ReplaceCharFirst(s: string;
                          const SearchChar, ReplaceChar: Char): string;
var p: Integer;
begin
  p := Pos(SearchChar, s);
  if p > 0 then
  begin
    Delete(s, p, 1);
    Insert(ReplaceChar, s, p);
  end;
  Result := s;
end;

{ ReplaceString ----------------------------------------------------------------

  ReplaceString ersetzt im String s alle Vorkommen von SearchString durch
  ReplaceString.                                                               }

function ReplaceString(s: string;
                       const SearchString, ReplaceString: string): string;
begin
  Result := StringReplace(s, SearchString, ReplaceString, [rfReplaceAll]);
end;

{ QuotePath --------------------------------------------------------------------

  QuotePath setzt einen String S in doppelte Anführungszeichen ("), wenn S
  Leerzeichen enthält.                                                         }

function QuotePath(const S: string): string;
begin
  if (Pos(' ', S) > 0) or (Pos('''', S) > 0) then
  begin
    Result := Quote (S); // '"' + S + '"';
  end else
  begin
    Result := S;
  end;
end;

{ Quote ------------------------------------------------------------------------

  Quote setzt einen String S in doppelte Anführungszeichen (").                }

function Quote(const S: string): string;
begin
  Result := '"' + S + '"';
end;

{ IsQuoted ---------------------------------------------------------------------

  IsQuoted prüft, ob der Strins S in doppelten Anführungszeichen (") steht.    }

function IsQuoted(const S: string): Boolean;
var Len: Integer;
begin
  Len := Length(S);
  if Len > 0 then
    Result := (S[1] = '"') and (S[Len] = '"')
  else
    Result := False;
end;

{ UnQuote ----------------------------------------------------------------------

  UnQuote entfernt doppelte Anführungszeichen (") am Anfang und am Ende von S. }

function UnQuote(const S: string): string;
var Len: Integer;
begin
  Len := Length(S);
  Result := S;
  if Len > 0 then
  begin
    if Result[Len] = '"' then Delete(Result, Len, 1);
    if Result[1]   = '"' then Delete(Result, 1, 1);
  end;
end;

{ SplitString ------------------------------------------------------------------

  teilt Source an Delimiter. Target1 enthält dann den linken Teilstring, Target2
  den rechten. Delimiter kommt nicht mehr im Ergebnis vor.                     }

procedure SplitString(Source, Delimiter: string; var Target1, Target2: string);
var p: Integer;
begin
  p := Pos(Delimiter, Source);
  if p > 0 then
  begin
    Target1 := Copy(Source, 1, p - 1);
    Delete(Source, 1, p);
    Target2 := Source;
  end;
end;

{ StringLeft -------------------------------------------------------------------

  gibt den Teilstring zurück, der sich links von Delimiter befindet.           }

function StringLeft(const Source, Delimiter: string): string;
var p: Integer;
begin
  p := Pos(Delimiter, Source);
  Result := Copy(Source, 1, p - 1);
end;

{ StringRight ------------------------------------------------------------------

  gibt den Teilstring zurück, der sich rechts von Delimiter befindet.          }

function StringRight(const Source, Delimiter: string): string;
var p: Integer;
    Temp: string;
begin
  Temp := Source;
  p := Pos(Delimiter, Temp);
  Delete(Temp, 1, p);
  Result := Temp;
end;

{ StrToFloatDef ----------------------------------------------------------------

  wandelt analog zur Delphi-Funktion StrToIntDef einen String in eine Gleit-
  kommazahl um. Sollte der String eine ungültige Zahl sein, wird der Default-
  Wert zurückgegeben.                                                          }

function StrToFloatDef(const S: string; Default: Extended): Extended;
begin
  if not TextToFloat(PChar(S), Result, fvExtended) then
    Result := Default;
end;

{ EnumToStr --------------------------------------------------------------------

  wandelt ein Element eines Aufzählungstyps in einen String.                   }

function EnumToStr(ArgType: PTypeInfo; var Arg): string;
begin
   case (GetTypeData(ArgType))^.OrdType of
      otSByte, otUByte: Result := GetEnumName(ArgType, Byte(Arg));
      otSWord, otUWord: Result := GetEnumName(ArgType, Word(Arg));
      otSLong         : Result := GetEnumName(ArgType, Longint(Arg));
   end;
end;

{ GetValueFromString -----------------------------------------------------------

  GetValaueFromString liefert bei Strings der Form 'Name=Wert' 'Wert' als
  Ergebnis.                                                                    }

function GetValueFromString(const s: string): string;
begin
  Result := Copy(s, Pos('=', s) + 1, MaxInt);
end;

{ CountChar --------------------------------------------------------------------

  CountChar liefert als Ergebis, wie of c in s vorkommt.                       }

function CountChar(const s: string; const c: Char): Integer;
var i: Integer;
begin
  Result := 0;
  for i := 1 to Length(s) do if s[i] = c then Inc(Result);
end;

{ TryUTF8ToAnsi ----------------------------------------------------------------

  wandelt einen UTF-8-String in einen ANSI-String um. Tritt dabei ein Fehler
  auf (UTF8ToAnsi ergibt einen leeren String), wird der ursprüngliche String
  zurückgegeben.                                                               }

function TryUTF8ToAnsi(const s: string): string;
begin
  Result := UTF8ToAnsi(s);
  if Result = '' then Result := s;
end;

{ UnescapeString ---------------------------------------------------------------

  UnescapeString entfernt Anführungszeichen am Anfang und Ende sowie '\' als
  Esacpe-Zeichen.                                                              }

function UnescapeString(s: string): string;
begin
  if Pos('''', s) = 1 then Delete(s, 1, 1);
  if s[Length(s)] = '''' then Delete(s, Length(s), 1);
  while Pos('\', s) > 0 do
  begin
    Delete(s, Pos('\', s), 1);
  end;
  Result := s;
end;

end.
