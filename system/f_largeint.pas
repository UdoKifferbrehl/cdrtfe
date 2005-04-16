{ f_largeint.pas: 64-Bit-Integer

  Copyright (c) 2004-2005 Oliver Valencia

  letzte Änderung  08.01.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_largeint.pas stellt 64-Bit-Integer-Funktionen zur Verfügung:
    * Konvertierungsfunktionen: Integer <-> Comp


  exportierte Funktionen/Prozeduren:

    HiComp(const Value: Comp): Integer
    IntToComp(const LowInt, HighInt: Integer): Comp
    LoComp(const Value: Comp): Integer

}

unit f_largeint;

{$I directives.inc}

interface

uses Windows;

function HiComp(const Value: Comp): Integer;
function IntToComp(const LowInt, HighInt: Integer): Comp;
function LoComp(const Value: Comp): Integer;

implementation

{ IntToComp --------------------------------------------------------------------

  erzeugt aus zwei Integerwerten einen 64-Bit-Integerwert.                     }

function IntToComp(const LowInt, HighInt: Integer): Comp;
var Value64: TLargeInteger;
begin
  Value64.LowPart:= LowInt;
  Value64.HighPart := HighInt;
  Result := Value64.QuadPart;
end;

{ HiComp -----------------------------------------------------------------------

  liefert das high order longword eines Comp-Wertes.                           }

function HiComp(const Value: Comp): Integer;
var Value64: TLargeInteger;
begin
  Value64.QuadPart := Value;
  Result := Value64.HighPart;
end;

{ LoComp -----------------------------------------------------------------------

  liefert das low order longword eines Comp-Wertes.                            }

function LoComp(const Value: Comp): Integer;
var Value64: TLargeInteger;
begin
  Value64.QuadPart := Value;
  Result := Value64.LowPart;
end;

end.
