{ f_strings.pas: String-Funktionen

  Copyright (c) 2004-2005 Oliver Valencia

  letzte Änderung  09.04.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_strings.pas stellt String-Funktionen zur Verfügung


  exportierte Funktionen/Prozeduren:

    EnumToStr(ArgType: PTypeInfo; var Arg): string
    FormatTime(const Time: Extended): string
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

}

unit f_strings;

{$I directives.inc}

interface

uses SysUtils, TypInfo;

{ 'statische' Variablen }
var UnitByte  : string = 'Byte';    // für SizeToString, damit eine Übersetzung
    UnitKiByte: string = 'KiByte';  // möglich ist, ohne cl_lang.pas einzubinden
    UnitMiByte: string = 'MiByte';
    UnitGiByte: string = 'GiByte';

function EnumToStr(ArgType: PTypeInfo; var Arg): string;
function FormatTime(const Time: Extended): string;
function QuotePath(const S: string): string;
function ReplaceChar(s: string; const SearchChar, ReplaceChar: Char): string;
function ReplaceCharFirst(s: string; const SearchChar, ReplaceChar: Char): string;
function ReplaceString(s: string; const SearchString, ReplaceString: string): string;
function SizeToString(const Size: {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF}): string;
function StringLeft(const Source, Delimiter: string): string;
function StringRight(const Source, Delimiter: string): string;
procedure SplitString(Source, Delimiter: string; var Target1, Target2: string);
procedure SizeToStringSetUnits(const B, KiB, MiB, GiB: string);

implementation

{uses}

{ SizeToString -----------------------------------------------------------------

  SizeToString erzeugt aus einem Longint einen je nach Größe in Byte, KiByte,
  MiByte oder GiByte ungerechneten und in einen String umgewandelten Wert inkl.
  Einheit.                                                                     }

function SizeToString(const Size: {$IFDEF LargeProject} Comp
                                  {$ELSE} Longint {$ENDIF}): string;
var SizeKB: Double;
    SizeMB: Double;
    SizeGB: Double;
begin
  SizeKB := Size / 1024;
  SizeMB := SizeKB / 1024;
  SizeGB := SizeMB / 1024;
  if SizeKB < 1 then
  begin
    {$IFDEF LargeProject}
    Result := FloatToStr(Size) + ' ' + UnitByte; //' Byte';
    {$ELSE}
    Result := IntToStr(Size) + ' ' + UnitByte; //' Byte';
    {$ENDIF}
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
var p: Integer;
begin
  p := Pos(SearchString, s);
  while p > 0 do
  begin
    Delete(s, p, Length(SearchString));
    Insert(ReplaceString, s, p);
    p := Pos(SearchString, s)
  end;
  Result := s;
end;

{ QuotePath --------------------------------------------------------------------

  QuotePath setzt einen String S in doppelte Anführungszeichen ("), wenn S
  Leerzeichen enthält.                                                         }

function QuotePath(const S: string): string;
begin
  if Pos(' ', S) > 0 then
  begin
    Result := '"' + S + '"';
  end else
  begin
    Result := S;
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

end.
