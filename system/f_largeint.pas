{ f_largeint.pas: 64-Bit-Integer

  Copyright (c) 2004-2007 Oliver Valencia

  letzte Änderung  24.06.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_largeint.pas stellt 64-Bit-Integer-Funktionen zur Verfügung:
    * Unter Delphi 3 wird Int64 als Comp definiert. Somit kann durchgängig Int64
      benutzt werden.
    * Konvertierungsfunktionen: 2 Integer <-> Comp bzw. Int64


  exportierte Funktionen/Prozeduren:

    HiComp(const Value: Comp): Integer
    IntToComp(const LowInt, HighInt: Integer): Comp
    LoComp(const Value: Comp): Integer

}

unit f_largeint;

{$I directives.inc}

interface

{ uses Windows; }

{$IFNDEF Delphi4Up}
type Int64    = Comp;
     Longword = Longint;
{$ENDIF}

function HiComp(const Value: Int64): Integer;
function IntToComp(const LowInt, HighInt: Integer): Int64;
function LoComp(const Value: Int64): Integer;

implementation

{ Es wird eine eigene Typ-Deklaration benötigt, da TLargeInteger aus Delphi 3 in
  späteren Versionen geändert wird.                                            }

type TLargeInt = record
       case Integer of
       0: (LowPart : Integer;
           HighPart: Integer);
       1: (QuadPart: Int64);
     end;

{ IntToComp --------------------------------------------------------------------

  erzeugt aus zwei Integerwerten einen 64-Bit-Integerwert.                     }

function IntToComp(const LowInt, HighInt: Integer): Int64;
var Value64: TLargeInt;
begin
  Value64.LowPart := LowInt;
  Value64.HighPart := HighInt;
  Result := Value64.QuadPart;
end;

{ HiComp -----------------------------------------------------------------------

  liefert das high order longword eines Comp-Wertes.                           }

function HiComp(const Value: Int64): Integer;
var Value64: TLargeInt;
begin
  Value64.QuadPart := Value;
  Result := Value64.HighPart;
end;

{ LoComp -----------------------------------------------------------------------

  liefert das low order longword eines Comp-Wertes.                            }

function LoComp(const Value: Int64): Integer;
var Value64: TLargeInt;
begin
  Value64.QuadPart := Value;
  Result := Value64.LowPart;
end;

end.
