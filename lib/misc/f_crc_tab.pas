{ f_crc_tab.pas: statische Lookup-Tabellen für die Berechnung der CRC-Prüfsummen

  Copyright (c) 2005-2008 Oliver Valencia

  Version          1.3
  erstellt         31.01.2005
  letzte Änderung  05.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert im wesentlichen auf Informationen aus 'efg's Mathematics
  Projects -- CRC Calculator' (http://www.efg2.com/Lab/Mathematics/CRC.htm) und
  'A Painless Guide to CRC Error Detection Algorithms'
  (http://www.ross.net/crc/crcpaper.html).

  f_crc_tab.pas stellt verschiedene statische Lookup-Tabellen für die Berechnung
  der CRC-Prüfsummen zur Verfügung.

}

unit f_crc_tab;

interface

uses Windows;

type TCRC16Tab = array[0..$FF] of Word;
     TCRC32Tab = array[0..255] of DWORD;

const {statische Lookup-Tabellen}

      {CRC16 nach CCITT (X25):
	 Polynom : x^16 + x^12 + x^5 + 1
	 Polynom : $1021
	 Reversed: False                                                       }

      Crc16Tab: TCRC16Tab = (
        $00000, $01021, $02042, $03063, $04084, $050a5, $060c6, $070e7,
        $08108, $09129, $0a14a, $0b16b, $0c18c, $0d1ad, $0e1ce, $0f1ef,
        $01231, $00210, $03273, $02252, $052b5, $04294, $072f7, $062d6,
        $09339, $08318, $0b37b, $0a35a, $0d3bd, $0c39c, $0f3ff, $0e3de,
        $02462, $03443, $00420, $01401, $064e6, $074c7, $044a4, $05485,
        $0a56a, $0b54b, $08528, $09509, $0e5ee, $0f5cf, $0c5ac, $0d58d,
        $03653, $02672, $01611, $00630, $076d7, $066f6, $05695, $046b4,
        $0b75b, $0a77a, $09719, $08738, $0f7df, $0e7fe, $0d79d, $0c7bc,
        $048c4, $058e5, $06886, $078a7, $00840, $01861, $02802, $03823,
        $0c9cc, $0d9ed, $0e98e, $0f9af, $08948, $09969, $0a90a, $0b92b,
        $05af5, $04ad4, $07ab7, $06a96, $01a71, $00a50, $03a33, $02a12,
        $0dbfd, $0cbdc, $0fbbf, $0eb9e, $09b79, $08b58, $0bb3b, $0ab1a,
        $06ca6, $07c87, $04ce4, $05cc5, $02c22, $03c03, $00c60, $01c41,
        $0edae, $0fd8f, $0cdec, $0ddcd, $0ad2a, $0bd0b, $08d68, $09d49,
        $07e97, $06eb6, $05ed5, $04ef4, $03e13, $02e32, $01e51, $00e70,
        $0ff9f, $0efbe, $0dfdd, $0cffc, $0bf1b, $0af3a, $09f59, $08f78,
        $09188, $081a9, $0b1ca, $0a1eb, $0d10c, $0c12d, $0f14e, $0e16f,
        $01080, $000a1, $030c2, $020e3, $05004, $04025, $07046, $06067,
        $083b9, $09398, $0a3fb, $0b3da, $0c33d, $0d31c, $0e37f, $0f35e,
        $002b1, $01290, $022f3, $032d2, $04235, $05214, $06277, $07256,
        $0b5ea, $0a5cb, $095a8, $08589, $0f56e, $0e54f, $0d52c, $0c50d,
        $034e2, $024c3, $014a0, $00481, $07466, $06447, $05424, $04405,
        $0a7db, $0b7fa, $08799, $097b8, $0e75f, $0f77e, $0c71d, $0d73c,
        $026d3, $036f2, $00691, $016b0, $06657, $07676, $04615, $05634,
        $0d94c, $0c96d, $0f90e, $0e92f, $099c8, $089e9, $0b98a, $0a9ab,
        $05844, $04865, $07806, $06827, $018c0, $008e1, $03882, $028a3,
        $0cb7d, $0db5c, $0eb3f, $0fb1e, $08bf9, $09bd8, $0abbb, $0bb9a,
        $04a75, $05a54, $06a37, $07a16, $00af1, $01ad0, $02ab3, $03a92,
        $0fd2e, $0ed0f, $0dd6c, $0cd4d, $0bdaa, $0ad8b, $09de8, $08dc9,
        $07c26, $06c07, $05c64, $04c45, $03ca2, $02c83, $01ce0, $00cc1,
        $0ef1f, $0ff3e, $0cf5d, $0df7c, $0af9b, $0bfba, $08fd9, $09ff8,
        $06e17, $07e36, $04e55, $05e74, $02e93, $03eb2, $00ed1, $01ef0);

      {CRC32 nach Ethernet, PKZIP:
       Polynom : x^32 + x^26 + x^23 + x^22 + x^16 + x^12 +
                 x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x^1 + 1
       Polynom : $04C11DB7
       Reversed: True                                                          }

      CRC32Tab: TCRC32Tab = (
        $00000000, $77073096, $EE0E612C, $990951BA,
        $076DC419, $706AF48F, $E963A535, $9E6495A3,
        $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
        $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
        $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
        $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
        $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
        $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
        $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
        $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
        $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
        $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
        $26D930AC, $51DE003A, $C8D75180, $BFD06116,
        $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
        $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
        $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,

        $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
        $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
        $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
        $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
        $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
        $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
        $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
        $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
        $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
        $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
        $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
        $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
        $5005713C, $270241AA, $BE0B1010, $C90C2086,
        $5768B525, $206F85B3, $B966D409, $CE61E49F,
        $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
        $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,

        $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
        $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
        $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
        $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
        $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
        $F762575D, $806567CB, $196C3671, $6E6B06E7,
        $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
        $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
        $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
        $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
        $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
        $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
        $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
        $CC0C7795, $BB0B4703, $220216B9, $5505262F,
        $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
        $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,

        $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
        $9C0906A9, $EB0E363F, $72076785, $05005713,
        $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
        $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
        $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
        $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
        $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
        $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
        $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
        $A7672661, $D06016F7, $4969474D, $3E6E77DB,
        $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
        $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
        $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
        $BAD03605, $CDD70693, $54DE5729, $23D967BF,
        $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
        $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

      {CRC32 für CD-Sektoren:
       Polynom : $8001801B
       Reversed: True                                                          }

      Crc32Tab2: TCRC32Tab = (
        $00000000, $90910101, $91210201, $01B00300, 
        $92410401, $02D00500, $03600600, $93F10701, 
        $94810801, $04100900, $05A00A00, $95310B01, 
        $06C00C00, $96510D01, $97E10E01, $07700F00, 
        $99011001, $09901100, $08201200, $98B11301, 
        $0B401400, $9BD11501, $9A611601, $0AF01700, 
        $0D801800, $9D111901, $9CA11A01, $0C301B00, 
        $9FC11C01, $0F501D00, $0EE01E00, $9E711F01, 
        $82012001, $12902100, $13202200, $83B12301, 
        $10402400, $80D12501, $81612601, $11F02700, 
        $16802800, $86112901, $87A12A01, $17302B00, 
        $84C12C01, $14502D00, $15E02E00, $85712F01, 
        $1B003000, $8B913101, $8A213201, $1AB03300, 
        $89413401, $19D03500, $18603600, $88F13701, 
        $8F813801, $1F103900, $1EA03A00, $8E313B01, 
        $1DC03C00, $8D513D01, $8CE13E01, $1C703F00, 

        $B4014001, $24904100, $25204200, $B5B14301, 
        $26404400, $B6D14501, $B7614601, $27F04700, 
        $20804800, $B0114901, $B1A14A01, $21304B00, 
        $B2C14C01, $22504D00, $23E04E00, $B3714F01, 
        $2D005000, $BD915101, $BC215201, $2CB05300, 
        $BF415401, $2FD05500, $2E605600, $BEF15701, 
        $B9815801, $29105900, $28A05A00, $B8315B01, 
        $2BC05C00, $BB515D01, $BAE15E01, $2A705F00, 
        $36006000, $A6916101, $A7216201, $37B06300, 
        $A4416401, $34D06500, $35606600, $A5F16701, 
        $A2816801, $32106900, $33A06A00, $A3316B01, 
        $30C06C00, $A0516D01, $A1E16E01, $31706F00, 
        $AF017001, $3F907100, $3E207200, $AEB17301, 
        $3D407400, $ADD17501, $AC617601, $3CF07700, 
        $3B807800, $AB117901, $AAA17A01, $3A307B00, 
        $A9C17C01, $39507D00, $38E07E00, $A8717F01, 

        $D8018001, $48908100, $49208200, $D9B18301, 
        $4A408400, $DAD18501, $DB618601, $4BF08700, 
        $4C808800, $DC118901, $DDA18A01, $4D308B00, 
        $DEC18C01, $4E508D00, $4FE08E00, $DF718F01, 
        $41009000, $D1919101, $D0219201, $40B09300, 
        $D3419401, $43D09500, $42609600, $D2F19701, 
        $D5819801, $45109900, $44A09A00, $D4319B01, 
        $47C09C00, $D7519D01, $D6E19E01, $46709F00, 
        $5A00A000, $CA91A101, $CB21A201, $5BB0A300, 
        $C841A401, $58D0A500, $5960A600, $C9F1A701, 
        $CE81A801, $5E10A900, $5FA0AA00, $CF31AB01, 
        $5CC0AC00, $CC51AD01, $CDE1AE01, $5D70AF00, 
        $C301B001, $5390B100, $5220B200, $C2B1B301, 
        $5140B400, $C1D1B501, $C061B601, $50F0B700, 
        $5780B800, $C711B901, $C6A1BA01, $5630BB00, 
        $C5C1BC01, $5550BD00, $54E0BE00, $C471BF01, 

        $6C00C000, $FC91C101, $FD21C201, $6DB0C300, 
        $FE41C401, $6ED0C500, $6F60C600, $FFF1C701, 
        $F881C801, $6810C900, $69A0CA00, $F931CB01, 
        $6AC0CC00, $FA51CD01, $FBE1CE01, $6B70CF00, 
        $F501D001, $6590D100, $6420D200, $F4B1D301, 
        $6740D400, $F7D1D501, $F661D601, $66F0D700, 
        $6180D800, $F111D901, $F0A1DA01, $6030DB00, 
        $F3C1DC01, $6350DD00, $62E0DE00, $F271DF01, 
        $EE01E001, $7E90E100, $7F20E200, $EFB1E301, 
        $7C40E400, $ECD1E501, $ED61E601, $7DF0E700, 
        $7A80E800, $EA11E901, $EBA1EA01, $7B30EB00, 
        $E8C1EC01, $7850ED00, $79E0EE00, $E971EF01, 
        $7700F000, $E791F101, $E621F201, $76B0F300, 
        $E541F401, $75D0F500, $7460F600, $E4F1F701, 
        $E381F801, $7310F900, $72A0FA00, $E231FB01, 
        $71C0FC00, $E151FD01, $E0E1FE01, $7070FF00);

implementation

end.
