{ cl_peheader.pas: Funktionen zum Auswerten der PE-Header einer EXE-Datei

  Copyright (c) 2004-2006 Oliver Valencia

  letzte Änderung  17.08.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit ist im wesentlichen eine angepaßte Variante der Unit pe.pas von
  K. Karthik (karthik_prg@yahoo.com). Es wurden einige Typen verändert, damit
  diese Unit auch unter Delphi 3 lauffähig ist. Weiterhin wurden Funktionen
  hinzugefügt, sowie zwei Speicherlecks entfernt.

  cl_peheader.pas stellt Funktionen zum Auslesen einiger Informationen aus den
  PE-Headern von EXE-Dateien zur Verfügung:
    * liefert in String-Listen die Sektionsnamen, importierte und exportierte
      Funktionen einer EXE- bzw. DLL-Datei.
    * prüfen, ob eine Datei (Programm oder DLL) eine bestimmte DLL benötigt


  TPEHeader:

    Properties   FileName
                 Initialized
                 LastError
                 LoadInMemory

    Methoden     Create
                 GetImportDllList(List: TStrings)
                 GetTables(ImportTable, ExportTable, SectionNames: TStrings)
                 Initialize
                 ResolveImportDllList
                 ResolveTables
                 

  exportierte Funktionen/Prozeduren:

    ImportsDll(const FileName, DllName: string): Boolean;


  Verwendung:
  
    var PEHeader: TPEHeader;

    PEHeader := TPEHeader.Create;
    PEHeader.FileName := 'i:\burn\cdrecord.exe';
    PEHeader.LoadInMemory := True;
    PEHeader.Initialize;
    PEHeader.ResolveTables;
    PEHeader.GetTables(...);
    [...]
    PEHeader.Free;

}

unit cl_peheader;

{$I directives.inc}

interface

uses Windows, Classes, Sysutils;

const IMAGE_ORDINAL_FLAG32: DWord = $80000000;

      PEH_NoError = 0;            { error codes }
      PEH_FileNotFound = 1;
      PEH_LoadError = 2;
      PEH_InvalidDOSHeader = 3;
      PEH_InvalidPEHeader = 4;
      PEH_NotInitialized = 5;
      PEH_NotResolved = 6;

type TImageDOSHeader = record
       e_magic   : Word;
       e_cblp    : Word;
       e_cp      : Word;
       e_cric    : Word;
       e_cparhdr : Word;
       e_minalloc: Word;
       e_maxalloc: Word;
       e_ss      : Word;
       e_sp      : Word;
       e_csum    : Word;
       e_ip      : Word;
       e_cs      : Word;
       e_lfarlc  : Word;
       e_ovno    : Word;
       e_res     : array[0..3] of Word;
       e_oemid   : Word;
       e_oeminfo : Word;
       e_res2    : array[0..9] of Word;
       e_lfanew  : DWord;
     end;

     TDOSHeader = record
       NThdr: DWord;
       Valid: Boolean;
     end;

     PImageNTHeaders = ^TImageNTHeaders;
     PImageSectionHeader = ^TImageSectionHeader;

     TWinHeader = record
       NTHdr: PImageNTHeaders;
       Valid: Boolean;
     end;

     TImageImportDescriptor = record
       OriginalFirstThunk: DWord;
       TimeDateStamp     : DWord;
       ForwarderChain    : DWord;
       Name              : DWord;
       FirstThunk        : DWord;
     end;

     TImageImportByName = record
       Hint: Word;
       Name: Byte;
     end;

     TImageExportDirectory = record
       Characteristics      : DWord;
       TimeDateStamp        : DWord;
       MajorVersion         : Word;
       MinorVersion         : Word;
       Name                 : DWord;
       Base                 : DWord;
       NumberOfFunctions    : DWord;
       NumberOfNames        : DWord;
       AddressOfFunctions   : DWord;
       AddressOfNames       : DWord;
       AddressOfNameOrdinals: DWord;
     end;

     TPEHeader = class(TObject)
     private
       FError: Byte;
       FFileName: string;
       FInitialized: Boolean;
       FResolved: Boolean;
       FResolvedDllList: Boolean;
       FLoadInMemory: Boolean;
       FImportDllList: TStringList;
       FImportTable: TStringList;
       FExportTable: TStringList;
       FSectionNames: TStringList;
       FStream: TStream;
       FDOSHeader: TDOSHeader;
       FWinHeader: TWinHeader;
       FSectionPointer: Pointer;
       function GetDosHeader(F: TStream): TDOSHeader;
       function GetLastError: Byte;
       function GetLinearAddress(SH: PImageSectionHeader; Count: DWord; RVA: DWord): DWord;
       function GetPEHeader(F: TStream; Offset: DWord): TWinHeader;
       function GetSectionData(F: TStream; Offset, Count: DWord): Pointer;
       function LoadFile: Boolean;
       function LoadHeader: Boolean;
       procedure RetrieveImportDllList(F: TStream; Offset: DWord; PSection: PImageSectionHeader; SectionC: DWord);
       procedure RetrieveImportTable(F: TStream; Offset: DWord; PSection: PImageSectionHeader; SectionC: DWord);
       procedure RetrieveExportTable(F: TStream; Offset: DWord; PSection: PImageSectionHeader; SectionC: DWord);
       Procedure RetrieveSectionNames(F: TStream; P: PImageSectionHeader; Count: DWord);
     public
       constructor Create;
       destructor Destroy; override;
       procedure Initialize;
       procedure GetImportDllList(List: TStrings);
       procedure GetTables(ImportTable, ExportTable, SectionNames: TStrings);
       procedure ResolveImportDllList;
       procedure ResolveTables;
       property FileName: string read FFileName write FFileName;
       property Initialized: Boolean read FInitialized;
       property LastError: Byte read GetLastError;
       property LoadInMemory: Boolean read FloadInMemory write FLoadInMemory;
     end;

function ImportsDll(const FileName, DllName: string): Boolean;

implementation

{ TPEHeader ------------------------------------------------------------------ }

{ TPEHeader - private }

function TPEHeader.GetLastError: Byte;
begin
  Result := FError;
  FError := PEH_NoError;
end;

function TPEHeader.LoadFile: Boolean;
var TempStream: TFileStream;
begin
  if (FFileName = '') or not FileExists(FFileName) then
  begin
    FError := PEH_FileNotFound;
    Result := False;
  end else
  try
    if FLoadInMemory then
    begin
      TempStream := TFileStream.Create(FFileName, fmOpenRead or fmShareCompat or
                                                  fmShareDenyNone);
      FStream := TMemoryStream.Create;
      (FStream as TMemoryStream).LoadFromStream(TempStream);
      TempStream.Free;
    end else
    begin
      FStream := TFilestream.Create(FFileName, fmOpenRead or fmShareCompat or
                                               fmShareDenyNone);
    end;
    Result := True;
  except
    FInitialized := False;
    FError := PEH_LoadError;
    Result := False;
  end;
end;

function TPEHeader.LoadHeader: Boolean;
begin
  Result := True;
  FDOSHeader := GetDosHeader(FStream);
  if FDOSHeader.Valid then
  begin
    FWinHeader := GetPEHeader(FStream, FDOSHeader.NTHdr);
    if  FWinHeader.Valid then
    begin
      FSectionPointer := GetSectionData(FStream, FDOSHeader.NTHdr,
                          FWinHeader.NTHdr^.FileHeader.NumberofSections);
    end else
    begin
      Result := False;
      FError := PEH_InvalidPEHeader;
    end;
  end else
  begin
    Result := False;
    FError := PEH_InvalidDOSHeader;
  end;
end;

function TPEHeader.GetDosHeader(F: TStream): TDOSHeader;
var DHdr: TImageDOSHeader;
    Count: Integer;
    DOSHeader: TDOSHeader;
begin
  F.Seek(0, soFromBeginning);
  Count := F.Read(DHdr, SizeOf(DHdr));
  if (Count < SizeOf(DHdr)) or (DHdr.e_magic <> $5a4d) then
  begin
    DOSHeader.Valid := False;
  end else
  begin
   DOSHeader.NTHdr := DHdr.e_lfanew;
   DOSHeader.Valid := True;
  end;
  Result := DOSHeader;
end;

function TPEHeader.GetPEHeader(F: TStream; Offset: DWord): TWinHeader;
var WinHeader: TWinHeader;
    Count: Integer;
begin
  New(WinHeader.NTHdr); { Dispose -> TPEHeader.Destroy }
  F.Seek(Offset, soFromBeginning);
  Count := F.Read(WinHeader.NTHdr^, SizeOf(TImageNTHeaders));
  if (Count <> SizeOf(WinHeader.NTHdr^)) or
     (WinHeader.NTHdr^.Signature <> $4550) then
  begin
    WinHeader.Valid := False;
  end else
  begin
    WinHeader.Valid := True;
  end;
  Result := WinHeader;
end;

function TPEHeader.GetSectionData(F: TStream; Offset, Count: DWord): Pointer;
var SectionPointer: Pointer;
begin
  F.Seek(Offset + SizeOf(TImageNTHeaders), soFromBeginning);
  SectionPointer := AllocMem(SizeOf(TImageSectionHeader) * Count);
  {SectionPointer is freed in TPEHeader.Destroy}
  if SectionPointer <> nil then
  begin
    F.Read(SectionPointer^, SizeOf(TImageSectionHeader) * Count);
  end;
  Result := SectionPointer;
end;

function TPEHeader.GetLinearAddress(SH: PImageSectionHeader; Count: DWord;
                                    RVA: DWord): DWord;
var t: DWord{Integer};       // RVA = Relative Virtual Address
begin
  t := 0;
  Result := 0;
  while( t < Count) do
  begin
    if (RVA >= SH^.VirtualAddress) and
       (RVA < (SH^.VirtualAddress + SH^.SizeOfRawData)) then
    begin
      Result := RVA + SH^.PointertoRawData - SH^.VirtualAddress;
      Break;
    end;
    inc(t);
    SH := Pointer(DWord(SH) + SizeOf(TImageSectionHeader));
  end;
end;

procedure TPEHeader.RetrieveExportTable(F: TStream; Offset: DWord;
                                        PSection: PImageSectionHeader;
                                        SectionC: DWord);
var NT: TImageNTHeaders;
    Exp: TImageExportDirectory;
    Off, AddrN, i, LAddrN: DWord;
    Ch: char;
    S: string;
    Names, PNames: ^DWord;
begin
  F.Seek(Offset, soFromBeginning);
  F.Read(NT, SizeOf(NT));
  if NT.OptionalHeader.DataDirectory[0].VirtualAddress = 0 then
  begin
    FExportTable.Clear;
  end else
  begin
    Off := GetLinearAddress(PSection, SectionC,
                            NT.OptionalHeader.DataDirectory[0].VirtualAddress);
    F.Seek(Off, soFromBeginning);
    F.Read(Exp, SizeOf(Exp));
    AddrN := GetLinearAddress(PSection, SectionC, Exp.AddressOfNames);
    Names := AllocMem(4 * Exp.NumberOfNames);
    PNames := Names;
    F.Seek(AddrN, soFromBeginning);
    F.Read(Names^, 4 * Exp.NumberOfNames);
    for i := 1 to Exp.NumberOfNames do
    begin
      LAddrN := GetLinearAddress(PSection, SectionC, PNames^);
      F.Seek(LAddrN, soFromBeginning);
      S := '';
      Ch := 'a';
      while Ord(Ch) <> 0 do
      begin
        F.Read(Ch, SizeOf(char));
        S := S + Ch;
      end;
      FExportTable.Add(S);
      inc(PNames);
    end;
    FreeMem(Names);
  end;
end;

procedure TPEHeader.RetrieveImportDllList(F: TStream; Offset: DWord;
                                          PSection: PImageSectionHeader;
                                          SectionC: DWord);
var NT: TImageNTHeaders;
    Import: TImageImportDescriptor;
    Off: DWord;
    S: string;
    Ch: char;
begin
  F.Seek(Offset, soFromBeginning);
  F.Read(NT, SizeOf(NT));
  Off := GetLinearAddress(PSection, SectionC,
                          NT.OptionalHeader.DataDirectory[1].VirtualAddress);
  F.Seek(Off, soFromBeginning);
  F.Read(import, SizeOf(Import));
  while not((Import.OriginalFirstThunk = 0) and (Import.FirstThunk = 0) and
            (Import.TimeDateStamp = 0) and (Import.Name = 0) and
            (Import.ForwarderChain = 0)) do
  begin
    F.Seek(GetLinearAddress(PSection, SectionC, Import.Name), soFromBeginning);
    S := '';
    Ch := 'a';
    while Ord(Ch) <> 0 do
    begin
      F.Read(Ch, SizeOf(char));
      S := S + Ch;
    end;
    FImportDllList.Add(LowerCase(Trim(S)));
    Off := Off + SizeOf(TImageImportDescriptor);
    F.Seek(Off, soFromBeginning);
    F.Read(Import, SizeOf(Import));
  end;
end;

procedure TPEHeader.RetrieveImportTable(F: TStream; Offset: DWord;
                                        PSection: PImageSectionHeader;
                                        SectionC: DWord);
var NT: TImageNTHeaders;
    Import: TImageImportDescriptor;
    Off, Thunk: DWord;
    S: string;
    Ch: char;
    addr, pos1: DWord;
    hint: Word;
begin
  F.Seek(Offset, soFromBeginning);
  F.Read(NT, SizeOf(NT));
  Off := GetLinearAddress(PSection, SectionC,
                          NT.OptionalHeader.DataDirectory[1].VirtualAddress);
  F.Seek(Off, soFromBeginning);
  F.Read(import, SizeOf(import));
  while not((Import.OriginalFirstThunk = 0) and (Import.FirstThunk = 0) and
            (Import.TimeDateStamp = 0) and (Import.Name = 0) and
            (Import.ForwarderChain = 0)) do
  begin
    F.Seek(GetLinearAddress(PSection, SectionC, Import.Name), soFromBeginning);
    S := '';
    Ch := 'a';
    while Ord(Ch) <> 0 do
    begin
      F.Read(Ch, SizeOf(char));
      S := S + Ch;
    end;
    FImportTable.Add(S);
    FImportTable.Add('');
    Thunk := Import.OriginalFirstThunk;
    if Thunk = 0 then
    begin
      Thunk := Import.FirstThunk;
    end;
    F.Seek(GetLinearAddress(PSection, SectionC, Thunk), soFromBeginning);
    F.Read(addr, SizeOf(DWord));
    Pos1 := F.Position;
    while addr <> 0 do
    begin
      if ((addr or IMAGE_ORDINAL_FLAG32) = addr) then
      begin
        FImportTable.Add(IntToStr(Lo(addr)) + '    (ordinal)');
      end else
      begin
        F.Seek(GetLinearAddress(PSection, SectionC, addr), soFromBeginning);
        F.Read(hint, SizeOf(Word));
        Ch := 'a';
        S := '';
        while Ord(Ch) <> 0 do
        begin
          F.Read(Ch, SizeOf(char));
          S := S + Ch;
        end;
        FImportTable.Add(IntToStr(hint) + '    ' + S);
      end;
      F.Seek(Pos1, soFromBeginning);
      F.Read(addr, SizeOf(DWord));
      Pos1 := F.Position;
    end;
    Off := Off + SizeOf(TImageImportDescriptor);
    F.Seek(Off, soFromBeginning);
    F.Read(Import, SizeOf(Import));
    FImportTable.Add('');
    FImportTable.Add('');
  end;
end;

procedure TPEHeader.RetrieveSectionNames(F: TStream; P: PImageSectionHeader;
                                         Count: DWord);
var s: string;
    i: Integer;
    k: DWord;
begin
  k := 0;
  while k < Count do
  begin
    s := '';
    for i := 0 to 7 do
    begin
      s := s + char(p^.Name[i]);
    end;
    FSectionNames.Add(s);
    P := Pointer(DWord(P) + SizeOf(TImageSectionHeader));
    inc(k);
  end;
end;

{ TPEHeader - public }

constructor TPEHeader.Create;
begin
  inherited Create;
  FError := PEH_NoError;
  FFileName := '';
  FInitialized := False;
  FResolved := False;
  FResolvedDllList := False;
  FLoadInMemory := False;
  FImportDllList := TStringList.Create;
  FImportTable := TStringList.Create;
  FExportTable := TStringList.Create;
  FSectionNames := TStringList.Create;
end;

destructor TPEHeader.Destroy;
begin
  FImportDllList.Free;
  FImportTable.Free;
  FExportTable.Free;
  FSectionNames.Free;
  if FStream <> nil then FStream.Free;
  if FSectionPointer <> nil then Freemem(FSectionPointer);
  if FWinHeader.NTHdr <> nil then Dispose(FWinHeader.NTHdr);
  inherited Destroy;
end;

procedure TPEHeader.Initialize;
begin
  if LoadFile then
    if LoadHeader then
      FInitialized := True;
end;

procedure TPEHeader.ResolveImportDllList;
begin
  if FInitialized then
  begin
    RetrieveImportDllList(FStream, FDOSHeader.NTHdr, FSectionPointer,
                          FWinHeader.NTHdr^.FileHeader.NumberofSections);
    FResolvedDllList := True;
  end else
  begin
    FError := PEH_NotInitialized;
  end;
end;

procedure TPEHeader.ResolveTables;
begin
  if FInitialized then
  begin
    RetrieveSectionNames(FStream, FSectionPointer,
                         FWinHeader.NTHdr^.FileHeader.NumberofSections);
    RetrieveImportTable(FStream, FDOSHeader.NTHdr, FSectionPointer,
                        FWinHeader.NTHdr^.FileHeader.NumberofSections);
    RetrieveExportTable(FStream, FDOSHeader.NTHdr, FSectionPointer,
                        FWinHeader.NTHdr^.FileHeader.NumberofSections);
    FResolved := True;
  end else
  begin
    FError := PEH_NotInitialized;
  end;
end;

procedure TPEHeader.GetTables(ImportTable,
                              ExportTable, SectionNames: TStrings);
begin
  if FResolved then
  begin
    ExportTable.Assign(FExportTable);
    ImportTable.Assign(FImportTable);
    SectionNames.Assign(FSectionNames);
  end else
  begin
    FError := PEH_NotResolved;
  end;
end;

procedure TPEHeader.GetImportDllList(List: TStrings);
begin
  if FResolvedDllList then
  begin
    List.Assign(FImportDllList);
  end else
  begin
    FError := PEH_NotResolved;
  end;
end;


{ ImportsDll -------------------------------------------------------------------

  True, if FileName imports DllName.                                           }

function ImportsDll(const FileName, DllName: string): Boolean;
var PEHeader: TPEHeader;
    DllList: TStringList;
begin
  if FileExists(FileName) then
  begin
    DllList := TStringList.Create;
    PEHeader := TPEHeader.Create;
    PEHeader.FileName := FileName;
    PEHeader.LoadInMemory := True;
    PEHeader.Initialize;
    PEHeader.ResolveImportDllList;
    PEHeader.GetImportDllList(DllList);
    PEHeader.Free;
    Result := DllList.IndexOf(LowerCase(DllName)) > -1;
    DllList.Free;
  end else
  begin
    Result := False;
  end;
end;

end.


