{ f_crc.pas: Berechnung der CRC-Prüfsummen, bitweiser Vergleich

  Copyright (c) 2004-2008 Oliver Valencia

  Version          1.4
  erstellt         22.08.2004
  letzte Änderung  05.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert im wesentlichen auf Informationen aus 'efg's Mathematics
  Projects -- CRC Calculator' (http://www.efg2.com/Lab/Mathematics/CRC.htm) und
  'A Painless Guide to CRC Error Detection Algorithms'
  (http://www.ross.net/crc/crcpaper.html).

  f_crc.pas stellt einige Funktionen zur Berechnung der CRC-Prüfsummen und zum
  bitweisen Vergleich zur Verfügung.
    * 16-Bit-CRC-Prüfsumme nach CCITT (X25-Standard)
    * 32-Bit-CRC-Prüfsumme (Ethernet, PKZIP)
    * 32-Bit-CRC-Prüfsumme mit variabler Lookup-Tabelle
    * 16-/32-Bit-CRC-Prüfsumme für Strings
    * bitweiser Vergleich von Speicherbereichen

  Um bei der Berechnung der CRC32-Prüfsumme PKZIP-kompatible Werte zu erhalten,
  muß -1 als Startwert verwendet und das Ergebnis der Berechnung invertiert
  werden. Bei CalcCRC32 ist zusätzlich die Tabelle TCRC32_1 anzugeben.


  exportierte Funktionen/Prozeduren:

    CalcCRC32(Init: Longint; Buffer: Pointer; count: Longint; Table: TCRC32Tables; Assemb: Boolean): Longint;
    CompareBuffer(Buffer1, Buffer2: Pointer; Count: Longint): Boolean
    CompareBufferA(Buffer1, Buffer2: Pointer; Count: Longint): Boolean
    UpdateCRC16(Init: Word; Buffer: Pointer; count: LongInt): Word
    UpdateCRC16A(Init: Word; Buffer: Pointer; count: LongInt): Word
    UpdateCRC32(Init: Longint; Buffer: Pointer; count: LongInt): Longint
    UpdateCRC32A(Init: Longint; Buffer: Pointer; count: LongInt): Longint
    StringCRC(const S: string; const CRC32: Boolean): Longint
    CRCToStr(const CRC: Longint): string

}

unit f_crc;

{$I directives.inc}

interface

uses Windows, SysUtils;

type TCRC32Tables = (TCRC32_1,   // -> CRC32Tab
                     TCRC32_2    // -> CRC32Tab2
                     );

function CalcCRC32(Init: Longint; Buffer: Pointer; count: Longint; Table: TCRC32Tables; Assemb: Boolean): Longint;                     
function CompareBuffer(Buffer1, Buffer2: Pointer; Count: Longint): Boolean;
function CompareBufferA(Buffer1, Buffer2: Pointer; Count: Longint): Boolean;
function UpdateCRC16(Init: Word; Buffer: Pointer; count: Longint): Word;
function UpdateCRC16A(Init: Word; Buffer: Pointer; count: Longint): Word;
function UpdateCRC32(Init: Longint; Buffer: Pointer; count: Longint): Longint;
function UpdateCRC32A(Init: Longint; Buffer: Pointer; count: Longint): Longint;
function StringCRC(const S: string; const CRC32: Boolean): Longint;
function CRCToStr(const CRC: Longint): string;

implementation

uses f_crc_tab;

{ UpdateCRC16 ------------------------------------------------------------------

  berechnet die CRC16-Prüfsumme nach CCITT (X25).
  Polynom : x^16 + x^12 + x^5 + 1
  Polynom : $1021
  Reversed: False                                                              }

function UpdateCRC16(Init: Word; Buffer: Pointer; count: Longint): Word;
var crc: Word;
begin
  crc := Init;
  while Count > 0 do
  begin
    crc := (crc shl 8) xor CRC16Tab[(crc shr 8) xor PByte(Buffer)^];
    count := count - 1;
    Inc(PByte(Buffer));
  end;
  Result := crc;
end;

{ UpdateCRC16A -----------------------------------------------------------------

  berechnet die CRC16-Prüfsumme nach CCITT (X25). Assembler-Variante.          }

function UpdateCRC16A(Init: Word; Buffer: Pointer; count: Longint): Word;
//                    EAX         EDX              ECX
asm
         and    edx,edx               // Buffer = 0 -> Ende
         jz     @Exit
         and    ecx,ecx               // count = 0  -> Ende
         jecxz  @Exit
         push   ebx
         push   edi
         lea    edi,[CRC16Tab]
         xor    ebx,ebx               // ebx := 0
@Loop:   mov    bl,[edx]              // Lade Datenbyte ins Register
         xor    bl,ah                 // (crc shr 8) xor Datenbyte
         shl    ax,8                  // crc shl 8
         xor    ax,[edi + ebx * 2]    // (crc shl 8) xor CRC16Tab[..]
         inc    edx
         dec    ecx
         jnz    @Loop
         pop    edi
         pop    ebx
@Exit:   ret
end;

{ UpdateCRC32 ------------------------------------------------------------------

  berechnet die CRC32-Prüfsumme (Ethernet, PKZIP).
  Polynom : x^32 + x^26 + x^23 + x^22 + x^16 + x^12 +
            x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1
  Polynom : $04C11DB7
  Reversed: True                                                               }

function UpdateCRC32(Init: Longint; Buffer: Pointer; count: Longint): Longint;
var crc: Cardinal{Longint};
begin
  crc := Init;
  while Count > 0 do
  begin
    crc := (crc shr 8) xor CRC32Tab[(crc and $000000FF) xor PByte(Buffer)^];
    count := count - 1;
    Inc(PByte(Buffer));
  end;
  Result := crc;
end;

{ UpdateCRC32 ------------------------------------------------------------------

  berechnet die CRC32-Prüfsumme (Ethernet, PKZIP). Assembler-Variante.          }

function UpdateCRC32A(Init: Longint; Buffer: Pointer; count: Longint): Longint;
//                    EAX            EDX              ECX
asm
         and    edx,edx               // Buffer = 0 -> Ende
         jz     @Exit
         and    ecx,ecx               // count = 0  -> Ende
         jecxz  @Exit
         push   ebx
         push   edi
         lea    edi,[CRC32Tab]
         xor    ebx,ebx
@Loop:   mov    bl,[edx]              // Lade Datenbyte ins Register
         xor    bl,al                 // crc  xor Datenbyte
         shr    eax,8                 // crc shr 8
         xor    eax,[edi + ebx * 4]   // (crc shr 8) xor CRC16Tab[..]
         inc    edx
         dec    ecx
         jnz    @Loop
         pop    edi
         pop    ebx
@Exit:   ret
end;

{ CalcCRC32 --------------------------------------------------------------------

  berechnet die CRC32-Prüfsumme mit der angegebenen Lookup-Tabelle, wahlweise in
  Assembler.                                                                   }  

function CalcCRC32(Init: Longint; Buffer: Pointer; count: Longint;
                   Table: TCRC32Tables; Assemb: Boolean): Longint;
var PTabCRC32: ^TCRC32Tab;

  { CalcVCRC32 -----------------------------------------------------------------

    berechnet die CRC32-Prüfsumme mit einer statischen Lookup-Tabellen, die
    vorher festgelegt werden muß.                                              }

  function CalcVCRC32(Init: Longint; Buffer: Pointer; count: Longint): Longint;
  var crc: Cardinal{Longint};
  begin
    crc := Init;
    while Count > 0 do
    begin
      crc := (crc shr 8) xor PTabCRC32[(crc and $000000FF) xor PByte(Buffer)^];
      count := count - 1;
      Inc(PByte(Buffer));
    end;
    Result := crc;
  end;

  { CalcVCRC32 -----------------------------------------------------------------

    berechnet die CRC32-Prüfsumme mit einer statischen Lookup-Tabellen, die
    vorher festgelegt werden muß. Assembler-Variante.                          }

  function CalcVCRC32A(Init: Longint; Buffer: Pointer; count: Longint): Longint;
  //                   EAX            EDX              ECX
  asm
           and    edx,edx               // Buffer = 0 -> Ende
           jz     @Exit
           and    ecx,ecx               // count = 0  -> Ende
           jecxz  @Exit
           push   ebx
           push   edi
           mov    edi,[PTabCRC32]
           xor    ebx,ebx
  @Loop:   mov    bl,[edx]              // Lade Datenbyte ins Register
           xor    bl,al                 // crc  xor Datenbyte
           shr    eax,8                 // crc shr 8
           xor    eax,[edi + ebx * 4]   // (crc shr 8) xor CRC16Tab[..]
           inc    edx
           dec    ecx
           jnz    @Loop
           pop    edi
           pop    ebx
  @Exit:   ret
  end;

begin
  case Table of
    TCRC32_1: PTabCRC32 := @CRC32Tab;
    TCRC32_2: PTabCRC32 := @CRC32Tab2;
  end;
  case Assemb of
    True : Result := CalcVCRC32A(Init, Buffer, count);
    False: Result := CalcVCRC32(Init, Buffer, count);
  else
    Result := 0;
  end;
end;

{ CompareBuffer ----------------------------------------------------------------

  führt einen byteweisen Vergleich der beiden Speicherbereiche durch und liefert
  True zurück, wenn sie übereinstimmen.                                        }

function CompareBuffer(Buffer1, Buffer2: Pointer; Count: Longint): Boolean;
begin
  Result := True;
  while Count > 0 do
  begin
    Result := Result and (PByte(Buffer1)^ = PByte(Buffer2)^);
    count := count - 1;
    Inc(PByte(Buffer1));
    Inc(PByte(Buffer2));
  end;
end;

{ CompareBuffer ----------------------------------------------------------------

  führt einen byteweisen Vergleich der beiden Speicherbereiche durch und liefert
  True zurück, wenn sie übereinstimmen. Assembler-Variante.                    }

function CompareBufferA(Buffer1, Buffer2: Pointer; Count: Longint): Boolean;
//                      EAX      EDX               ECX
asm
         and    ecx,ecx               // count = 0  -> Ende
         jecxz  @Exit
         push   ebx
         xor    ebx,ebx
@Loop:   mov    bl,[eax]              // Lade Datenbyte ins Register
         xor    bl,[edx]              // Datenbyte1 xor Datenbyte2
         jnz    @Error                // wenn nicht null, dann Fehler
         inc    eax
         inc    edx
         dec    ecx
         jnz    @Loop
         jmp    @Ok
@Error:  xor    eax,eax               // bei Fehler False zurückgeben
         jmp    @Ende
@Ok:     xor    eax,eax               // wenn ok, True zurückgeben
         inc    eax
@Ende:   pop    ebx
@Exit:   ret
end;

{ StringCRC --------------------------------------------------------------------

  berechnet die CRC-Prüfsumme für S.                                           }

function StringCRC(const S: string; const CRC32: Boolean): Longint;
begin
  Result := 0;
  case CRC32 of
    True : Result := UpdateCRC32A(-1, PChar(S), Length(S));
    False: Result := UpdateCRC16A(0, PChar(S), Length(S));
  end;
end;

{ CRCToStr ---------------------------------------------------------------------

  wandelt eine CRC-Prüfsumme in die hexadezimale Darstellung um.               }

function CRCToStr(const CRC: Longint): string;
begin
  if (CRC shr 16) = 0 then
    Result := IntToHex(CRC, 4)
  else
    Result := IntToHex(CRC, 8);
end;

end.
