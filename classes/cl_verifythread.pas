{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cl_verifyhread.pas: Quell- und Zieldateien vergleichen

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  22.08.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  cl_verifythread.pas implementiert das Thread-Objekt, das die gebrannten
  mit den Original-Dateien vergleicht. Der Vergleich erfolgt anhand von
  CRC32-Prüfsummen oder bitweise (je nach Kompilerdirektive).
  Außerdem kann in der Pfadliste nach mehrfach vorkommenden, identischen
  Dateien gesucht werden, um diese durch Links zur Ursprungsdatei ersetzen.
  Zudem kann für Mode2/Form2-Dateien eine Info-Datei erzeugt werden.


  TVerificationThread

    Properties   Action
                 AutoExec
                 Drive
                 ProgressBar
                 Reload
                 StatusBar
                 XCDExt
                 XCDKeepExt

    Methoden     Create(List: TStringList; Memo: TMemo; Device: string; Lang: TLang; Suspended: Boolean)

  exportierte Funktionen (ungenutzt, aus cdrtfe 0.9.x)

    StartVerifyDataCD(List: TStringList; var Thread: TVerificationThread; Memo: TMemo; Device: string; Lang: TLang)
    TerminateVerification(Thread: TVerificationThread)

}

unit cl_verifythread;

{$I directives.inc}

interface

uses Windows, SysUtils, Classes, StdCtrls, ComCtrls, Forms, FileCtrl,
     cl_lang;

type TVerificationThread = class(TThread)
     private
       FAction      : Byte;
       {Variablen für Ausgabe}
       FHandle      : THandle;           // Window-Handle des Formulars mit Memo
       FMemo        : TMemo;             // Memo für Ausgabe
       FStatusBar   : TStatusBar;        // für Anzeige von Status-Infos
       FProgressBar : TProgressBar;      // Fortschrittsanzeige
       FLine        : string;            // Zeile, die ausgegeben werden soll
       FPBPos       : Integer;           // Position des PorgressBars
       {Variablen für Vergleiche (Daten-/XCD}
       FDevice      : string;
       FDrive       : string;
       FAutoExec    : Boolean;           // True, wenn automatisches Brennen
       FReload      : Boolean;           // Reload druchführen oder nicht
       FReloadError : Boolean;           // True, wenn Einlesen nicht möglich
       FXCD         : Boolean;
       FXCDExt      : string;
       FXCDKeepExt  : Boolean;
       {Variablen für das Aufspüren von Duplikaten}
       FDupSize     : {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF};
       {mehrfach verwendete Variablen}
       FLang        : TLang;       
       FVerifyList  : TStringList;
       procedure CleanUpList(List: TStringList);
       procedure CreateInfoFile;
       procedure CreateInfoFileInit;
       procedure FindDuplicateFiles;
       procedure FindDuplicateFilesInit;
       procedure ReloadMedium;
       procedure Verify(const Drive: string);
       procedure VerifyInit;
       function CompareFiles(const FileName1, FileName2: string): Boolean;
       function CompareForm2Files(const FileName1, FileName2: string): Boolean;
       function GetFileCRC32(const FileName: string; var CRC32: LongInt): Boolean;
       {$IFNDEF BitwiseVerify}
       function GetForm2FileCRC32(const FileName1, FileName2: string; var CRC32: LongInt): Boolean;
       {$ENDIF}
       function GetDrive: string;
       function MakeForm2FileName(const Name: string): string;
     protected
       procedure Execute; override;
       procedure DAddLine;
       procedure DStatusBarPanel0;
       procedure DStatusBarPanel1;
       procedure DSetProgressBar;
       procedure DReloadError;
       procedure SendTerminationMessage;
     public
       constructor Create(List: TStringList; var Memo: TMemo; Device: string; Lang: TLang; Suspended: Boolean);
       property Action: Byte write FAction;
       {Properties für Ausgabe}
       property StatusBar: TStatusBar write FStatusBar;
       property ProgressBar: TProgressBar write FProgressBar;
       {Properties für Vergleiche}
       property AutoExec: Boolean write FAutoExec;
       property Reload: Boolean write FReload;
       property XCD: Boolean write FXCD;
       property XCDExt: string write FXCDExt;
       property XCDKeepExt: Boolean write FXCDKeepExt;
       property Drive: string write FDrive;
       {Properties für das Aufspüren von Duplikaten}
     end;

procedure StartVerifyDataCD(List: TStringList; var Thread: TVerificationThread; Memo: TMemo; Device: string; Lang: TLang);
procedure TerminateVerification(Thread: TVerificationThread);

implementation

uses {$IFDEF ShowVerifyTime} f_misc, {$ENDIF}
     f_filesystem, f_strings, f_largeint, f_crc, f_helper, user_messages,
     constant;

type TM2F2FileHeader = packed record  // RIFF-Header der Mode2/Form2-Dateien
       RIFF : array[0..3] of char;    // Byte  0 -  3: 'RIFF'
       Size : Integer;                // Byte  4 -  7: Dateigröße - 8
       CDXA : array[0..3] of char;    // Byte  8 - 11: 'CDXA'
       fmt  : array[0..2] of char;    // Byte 12 - 14: 'fmt'
       FData: array[0..20] of char;   // Byte 15 - 35: FData[9..12] = $15 + 'UXA'
       DATA : array[0..3] of char;    // Byte 36 - 39: 'data'
       DSize: Integer;                // Byte 40 - 43: Größe der Datensektion (Vielfaches von 2352)
     end;

     TM2F2Sector = packed record      // Mode2/Form2-Raw-Sektor
       Sync : array[0..11] of char;   // Byte  0 - 11: Synchronisation
       Hdr  : array[0..3] of char;    // Byte 12 - 15: Header: 3 Byte Sektoradresse, 1 Byte Mode
       SHdr : array[0..7] of char;    // Byte 16 - 23: Subheader -> Form1/2
       Data : array[0..2323] of char; // Daten
       EDC  : array[0..3] of char;    // 4 Byte CRC32-Prüfsumme
     end;

{ TVerificationThread -------------------------------------------------------- }

{ TVerificationThread - private/protected }

{ Methoden für den VCL-Zugriff -------------------------------------------------

  Zugriffe auf die VCL müssen über Synchronize erfolgen. Methoden, die für die
  Anzeige von Daten zuständig sind beginnen mit 'D'.                           }

procedure TVerificationThread.DAddLine;
begin
  FMemo.Lines.Add(FLine);
end;

procedure TVerificationThread.DStatusBarPanel0;
begin
  FStatusBar.Panels[0].Text := FLine;
end;

procedure TVerificationThread.DStatusBarPanel1;
begin
  FStatusBar.Panels[1].Text := FLine;
end;

procedure TVerificationThread.DSetProgressBar;
begin
  FProgressBar.Position := FPBPos;
end;

procedure TVerificationThread.DReloadError;
var REText, RECaption: string;
    i: Integer;
begin
  REText := FLang.GMS('everify03');
  RECaption := FLang.GMS('everify04');
  i := Application.MessageBox(PChar(REText), PChar(RECaption),
                             MB_OKCANCEL or MB_APPLMODAL or MB_ICONEXCLAMATION);
  if i <> 1 then
  begin
    Terminate;
    FReloadError := False;
  end;
end;

procedure TVerificationThread.SendTerminationMessage;
var SizeHigh: Integer;
    SizeLow: Integer;
begin
  FProgressBar.Visible := False;
  case FAction of
    cFindDuplicates: if Terminated then
                       SendMessage(FHandle, WM_FTerminated, -1, -1) else
                     begin
                       {$IFDEF LargeFiles}
                       SizeLow := LoComp(FDupSize);
                       SizeHigh := HiComp(FDupSize);
                       {$ELSE}
                       SizeLow := FDupSize;
                       SizeHigh := 0;
                       {$ENDIF}
                       SendMessage(FHandle, WM_FTerminated, SizeHigh, SizeLow);
                     end;
    cCreateInfoFile: if Terminated then
                       SendMessage(FHandle, WM_ITerminated, -1, -1) else
                       SendMessage(FHandle, WM_ITerminated, 0, 0);
  else
    SendMessage(FHandle, WM_VTerminated, 0, 0);
  end;
end;

{ CleanUpList ------------------------------------------------------------------

  CleanUpList entfernt aus den Listen die Dummy-Einträge für leere Ordner.     }

procedure TVerificationThread.CleanUpList(List: TStringList);
var i: Integer;
begin
  for i := (List.Count - 1) downto 0 do
    if Pos(DummyDirName, List[i]) > 0 then List.Delete(i);
end;

{ ReloadMedium -----------------------------------------------------------------

  Reload durchführen, falls FReload = True.                                    }

procedure TVerificationThread.ReloadMedium;
begin
  {$IFNDEF NoReload}
  if FReload then
  begin
    FLine := FLang.GMS('mverify04');
    Synchronize(DAddLine);
    {$IFDEF VerifyShowDetails}
    FLine := 'Device: ' + FDevice;
    Synchronize(DAddLine);
    {$ENDIF}
    FLine := '';
    Synchronize(DAddLine);
    FReloadError := ReloadDisk(FDevice);
    {damit die CD sicher erkannt wird, noch eine Sekunde warten}
    Sleep(1000);
  end;
  {$ENDIF}
  {Sollte kein Reload möglich sein, dann dem User erlauben, ein manuelles Reload
   durchzuführen oder den Vergleich abzubrechen. Dies kann bei Notebook-
   Laufwerken auftreten.}
  {$IFDEF ForceReloadError}
  FReloadError := True;
  {$ENDIF}
  if FReloadError then
  begin
    {Wenn der Fehler auftritt, MessageBox anzeigen, es sei denn, es wird auto-
     matisch gebrannt.}
    if not FAutoExec then
    begin
      Synchronize(DReloadError);
    end else
    begin
      FLine := FLang.GMS('everify05');
      Synchronize(DAddLine);
      FLine := '';
      Synchronize(DAddLine);
      Terminate;
    end;
  end;
end;

{ GetDrive ---------------------------------------------------------------------

  Wenn beim Aufruf des Threads eine Laufwerksbezeichnung angegeben wurde, wird
  diese verwendet. Ansonsten sucht GetDrive das Laufwerk, in dem die gerade
  geschriebene CD eingelegt ist, indem die ersten Datei gesucht wird, die in
  BurnList steht.                                                              }

function TVerificationThread.GetDrive: string;
var CDDrives: TStringList;
    i: Integer;
    c: Integer;
    Temp: string;
begin
  {Reload durchführen}
  ReloadMedium;
  if FDrive = '' then
  begin
    {CD-Laufwerke suchen, da FDrive leer ist.}
    CDDrives := TStringList.Create;
    {Laufwerke suchen, Format: <lw>:\ }
    GetDriveList(DRIVE_CDROM, CDDrives);
    {Laufwerk mit eingelegter CD suchen}
    for i := CDDrives.Count - 1 downto 0 do
    begin
      {$IFDEF VerifyShowDetails}
      FLine := 'Drive: ' + CDDrives[i];
      Synchronize(DAddLine);
      {$ENDIF}
      {Nummer des Laufwerks bestimmen}
      c := Ord(LowerCase(CDDrives[i])[1]) - 96;
      if DriveEmpty(c) then
      begin
        CDDrives.Delete(i);
      end;
    end;
    {Laufwerk mit den richtigen Daten suchen}
    Temp := Copy(FVerifyList[0], 1, Pos(':', FVerifyList[0]) - 1);
    {Aufpassen, falls es eine Form2-Datei ist.}
    if Pos('>', FVerifyList[0]) > 0 then Temp := MakeForm2FileName(Temp);
    for i := CDDrives.Count - 1 downto 0 do
    begin
      Temp := CDDrives[i] {+ '\'} + Temp;
      Temp := ReplaceChar(Temp, '/', '\');
      if not FileExists(Temp) and not DirectoryExists(Temp) then
      begin
        CDDrives.Delete(i);
      end;
    end;
    if CDDrives.Count > 0 then
    begin
      {CDDrives sollte jetzt nur noch ein Laufwerk enthalten, dort muß noch der
       Backslash enfernt werden.}
      Temp := CDDrives[0];
      if Temp[Length(Temp)] = '\' then Delete(Temp, Length(Temp), 1);
      Result := Temp;
    end else
    begin
      Result := '';
    end;
    CDDrives.free;
    {$IFDEF VerifyShowDetails}
    FLine := 'Drive: ' + Result;
    Synchronize(DAddLine);
    {$ENDIF}
  end else
  begin
    Temp := FDrive;
    if Temp[Length(Temp)] = '\' then Delete(Temp, Length(Temp), 1);
    Result := Temp;
    {$IFDEF VerifyShowDetails}
    FLine := 'FDrive: ' + Result;
    Synchronize(DAddLine);
    {$ENDIF}
  end;
end;

{ MakeForm2FileName ------------------------------------------------------------

  paßt den Dateinamen den Einstellungen (KeepExt, Ext) entsprechend an.        }

function TVerificationThread.MakeForm2FileName(const Name: string): string;
var Temp: string;
    p: Integer;
begin
  Temp := Name;
  if FXCDKeepExt then
  begin
    Temp := Temp + '.' + FXCDExt;
  end else
  begin
    if ExtractFileExt(Temp) <> '' then
    begin
      p := LastDelimiter('.', Temp);
      Delete(Temp, p, Length(Temp) - p + 1);
      Temp := Temp + '.' + FXCDExt;
    end else
    begin
      Temp := Temp + '.' + FXCDExt;
    end;
  end;
  Result := Temp;
end;

{ CompareFiles -----------------------------------------------------------------

  CompareFiles führt einen bitweisen Vergleich der angegebenen Dateien durch und
  liefert als Rückgabewert True, wenn die Dateien identisch sind (gilt auch für
  0-Byte-Dateien).                                                             }

function TVerificationThread.CompareFiles(const FileName1, FileName2: string):
                                          Boolean;
var File1, File2: TFileStream;
    p1, p2: Pointer;
    FSize1, FSize2: {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF};
    BSize: Integer;
    NBytes: Integer; //Number of bytes to read
begin
  File1 := nil;
  File2 := nil;
  Result := True;
  BSize := cBufSize;
  GetMem(p1, BSize);
  GetMem(p2, BSize);
  try
    try
      File1 := TFileStream.Create(FileName1, fmOpenRead);
      File2 := TFileStream.Create(FileName2, fmOpenRead);
      {$IFDEF LargeFiles}
      FSize1 := GetFileSize(FileName1);
      FSize2 := GetFileSize(FileName2);
      {$ELSE}
      FSize1 := File1.Size;
      FSize2 := File2.Size;
      {$ENDIF}
      if (FSize1 = FSize2) and (FSize1 > 0) then
      begin
        while (FSize1 <> 0) and Result and not Terminated do
        begin
          {$IFDEF LargeFiles}
          if FSize1 > BSize then NBytes := BSize else NBytes := LoComp(FSize1);
          FSize1 := FSize1 - NBytes;
          {$ELSE}
          if FSize1 > BSize then NBytes := BSize else NBytes := FSize1;
          Dec(FSize1, NBytes);
          {$ENDIF}
          File1.ReadBuffer(p1^, NBytes);
          File2.ReadBuffer(p2^, NBytes);
          Result := Result and CompareBufferA(p1, p2, NBytes);
          FPBPos := Round(((FSize2 - FSize1) / FSize2) * 100);
          Synchronize(DSetProgressBar);
        end;
      end else
      begin
        Result := (FSize1 = 0) and (FSize2 = 0);
        // if (FSize1 = 0) and (FSize2 = 0) then Result := True else
        // Result := False;
      end;
    except
      Result := False;
    end;
  finally
    File1.Free;
    File2.Free;
    FreeMem(p1, BSize);
    FreeMem(p2, BSize)
  end;
end;

{ CompareForm2Files ------------------------------------------------------------

  CompareForm2Files führt einen bitweisen Vergleich der angegebenen Form2-
  Dateien durch und liefert als Rückgabewert True, wenn die Dateien identisch
  sind.                                                                        }

function TVerificationThread.CompareForm2Files(const FileName1, FileName2:
                                                               string): Boolean;
var File1, File2: TFileStream;
    p1: Pointer;
    HBuffer: array[0..43] of char;   // Buffer for Header
    SBuffer: array[0..2351] of char; // Buffer for Sector
    FileHeader: ^TM2F2FileHeader;
    Sector: ^TM2F2Sector;
    SecCount: Integer;               // Sectors to read
    FSize1, FSize2: LongInt;
    BSize1, BSize2: Integer;
    NBytes: Integer;                 //Number of bytes to read/compare
begin
  File1 := nil;
  File2 := nil;
  Result := True;
  {Aufgrund des Dateiformates der Mode2/Form2-Dateien ist es einfacher, nicht
   mit cBufSize (2048 Bytes) als Puffergröße zu arbeiten.}
  BSize1 := 2324;
  BSize2 := SizeOf(SBuffer); // 2352 Bytes
  GetMem(p1, BSize1);
  try
    try
      File1 := TFileStream.Create(FileName1, fmOpenRead); // Form1-Datei
      File2 := TFileStream.Create(FileName2, fmOpenRead); // Form2-Datei
      FSize1 := File1.Size;
      FSize2 := FSize1;
      if (FSize1 > 0) and (FSize2 > 0) then
      begin
        {44 Byte großen Header lesen}
        ZeroMemory(@HBuffer, SizeOf(HBuffer));
        FileHeader := @HBuffer;
        File2.ReadBuffer(HBuffer, 44);
        SecCount := FileHeader^.DSize div 2352;
        ZeroMemory(@SBuffer, SizeOf(SBuffer));
        Sector := @SBuffer;
        while (FSize1 <> 0) and (SecCount > 0) and Result and not Terminated do
        begin
          {aus der Form1-Datei lesen}
          if FSize1 > BSize1 then NBytes := BSize1 else NBytes := FSize1;
          Dec(FSize1, NBytes);
          File1.ReadBuffer(p1^, NBytes);
          {aus der Form2-Datei lesen}
          File2.ReadBuffer(SBuffer, BSize2);
          Dec(SecCount);
          {Vergleichen}
          Result := Result and CompareBufferA(p1, @Sector^.Data, NBytes);
          FPBPos := Round(((FSize2 - FSize1) / FSize2) * 100);
          Synchronize(DSetProgressBar);
        end;
      end else
      begin
        Result := False;
      end;
    except
      Result := False;
    end;
  finally
    File1.Free;
    File2.Free;
    FreeMem(p1, BSize1);
  end;
end;

{ GetFileCRC32 -----------------------------------------------------------------

  GetFileCRC32 berechnet den CRC32-Wert einer Datei.
    FileName:     Dateiname (mit Pfad)
    CRC32:        CRC32-Wert, beliebiger Startwert möglich, da innerhalb der
                  Funktion sowieso mit -1 initialisiert
    Rückgabewert: True, wenn erfolgreich

  GetFileCRC32 wurde in als Methode des Thread-Objektes definiert, damit auch
  während der CRC-Berechnung der Thread abgebrochen bzw. der Fortschritt bei den
  einzelnen Dateien angezeigt werden kann.                                     }

function TVerificationThread.GetFileCRC32(const FileName: string;
                                          var CRC32: Longint): Boolean;
var FileIn : TFileStream;
    p: Pointer;
    FSize: Longint;
    FSIzeBak: Longint;
    BSize: Integer;
    NBytes: Integer; //Number of bytes to read
begin
  FileIn := nil;
  Result := True;
  {Blockgröße von 2 KiByte erscheint als schnellste Variante}
  BSize := cBufSize;
  GetMem(p, BSize);
  try
    try
      FileIn := TFileStream.Create(FileName, fmOpenRead);
      FSize := FileIn.Size;
      FSizeBak := FSize;
      if FSize > 0 then
      begin
        {Startwert -1 für PKZIP-kompatible CRC32-Werte}
        CRC32 := -1;
        while (FSize <> 0) and not Terminated {FTerminate} do
        begin
          if FSize > BSize then NBytes := BSize else NBytes := FSize;
          Dec(FSize, NBytes);
          FileIn.ReadBuffer(p^, NBytes);
          CRC32 := UpdateCRC32A(Crc32, p, NBytes);
          FPBPos := Round(((FSizeBak - FSize) / FSizeBak) * 100);
          Synchronize(DSetProgressBar);
        end;
        {für PKZIP-Kompatibilität muß Wert noch invertiert werden}
        CRC32 := not CRC32;
      end;
    except
      Result := False;
    end;
  finally
    FileIn.Free;
    FreeMem(p, BSize);
  end;
end;
(* {Variante mit BlockRead statt mit File-Stream}
var f: File;
    p: Pointer;
    FSize: LongInt;
    FSizeBak: LongInt;
    BSize: Integer;
    tmp: Word;
    OldFileMode: Integer;
begin
  OldFileMode := FileMode;
  FileMode := 0;
  FPBPos := 0;
  Synchronize(DSetProgressBar);
  {$I+}
  try
    FSize := GetFileSize(FileName);
    FSizeBak := FSize;
    AssignFile(f, FileName);
    Reset(f, 1);
    {da es nicht mit Textdateien funktioniert, wird FileSize nicht verwendet:
    FSize := FileSize(f); }
    if FSize <> 0 then
    begin
      {Blockgröße von 2 KiByte erscheint als schnellste Variante}
      BSize := cBufSize;
      {Startwert -1 für PKZIP-kompatible CRC32-Werte}
      CRC32 := -1;
      while (FSize <> 0) and not FTerminate do
      begin
        if FSize > BSize then tmp := BSize else tmp := FSize;
        Dec(FSize, tmp);
        GetMem(p, tmp);
        BlockRead(f, p^, tmp);
        CRC32 := UpdateCRC32A(Crc32, p, tmp);
        FreeMem(p, tmp);
        FPBPos := Round(((FSizeBak - FSize) / FSizeBak) * 100);
        Synchronize(DSetProgressBar);
      end;
      {für PKZIP-Kompatibilität muß Wert noch invertiert werden}
      CRC32 := not CRC32;
    end;
    Result := True;
  except
    Result := False;
  end;
  try
    CloseFile(f);
  except
  end;
  {$I-}
  FileMode := OldFileMode;
end; *)

{$IFNDEF BitwiseVerify}

{ GetForm2FileCRC32 ------------------------------------------------------------

  GetForm2FileCRC32 berechnet den CRC32-Wert einer Mode2/Form2-Datei. Ansonsten
  gilt das zu GetFileCRC32 gesagte.
  Die Originaldatei wird benötigt, um die genaue Dateigröße zu ermitteln, die
  aus der Form2-Datei nicht zu ermitteln ist.                                  }

function TVerificationThread.GetForm2FileCRC32(const FileName1, FileName2:
                                           string; var CRC32: Longint): Boolean;
var File1, File2: TFileStream;
    HBuffer: array[0..43] of char;   // Buffer for Header
    SBuffer: array[0..2351] of char; // Buffer for Sector
    FileHeader: ^TM2F2FileHeader;
    Sector: ^TM2F2Sector;
    SecCount: Integer;               // Sectors to read
    FSize1, FSize2: LongInt;
    BSize1, BSize2: Integer;
    NBytes: Integer;                 //Number of bytes to read/compare
begin
  File1 := nil;
  File2 := nil;
  Result := True;
  {Aufgrund des Dateiformates der Mode2/Form2-Dateien ist es einfacher, nicht
   mit cBufSize (2048 Bytes) als Puffergröße zu arbeiten.}
  BSize1 := 2324;
  BSize2 := SizeOf(SBuffer); // 2352 Bytes
  try
    try
      File1 := TFileStream.Create(FileName1, fmOpenRead); // Form1-Datei
      File2 := TFileStream.Create(FileName2, fmOpenRead); // Form2-Datei
      FSize1 := File1.Size;
      FSize2 := FSize1;
      if (FSize1 > 0) and (FSize2 > 0) then
      begin
        {Startwert -1 für PKZIP-kompatible CRC32-Werte}
        CRC32 := -1;
        {44 Byte großen Header lesen}
        ZeroMemory(@HBuffer, SizeOf(HBuffer));
        FileHeader := @HBuffer;
        File2.ReadBuffer(HBuffer, 44);
        SecCount := FileHeader^.DSize div 2352;
        ZeroMemory(@SBuffer, SizeOf(SBuffer));
        Sector := @SBuffer;
        while (FSize1 <> 0) and (SecCount > 0) and not Terminated do
        begin
          {simuliert aus der Form1-Datei lesen}
          if FSize1 > BSize1 then NBytes := BSize1 else NBytes := FSize1;
          Dec(FSize1, NBytes);
          {aus der Form2-Datei lesen}
          File2.ReadBuffer(SBuffer, BSize2);
          Dec(SecCount);
          {Vergleichen}
          CRC32 := UpdateCRC32A(Crc32, @Sector^.Data, NBytes);
          FPBPos := Round(((FSize2 - FSize1) / FSize2) * 100);
          Synchronize(DSetProgressBar);
        end;
        {für PKZIP-Kompatibilität muß Wert noch invertiert werden}
        CRC32 := not CRC32;        
      end else
      begin
        Result := False;
      end;
    except
      Result := False;
    end;
  finally
    File1.Free;
    File2.Free;
  end;
end;

{$ENDIF}

{ Verify -----------------------------------------------------------------------

  Eigentliche Aufgabe von TVerificationThread: Vergleichen.
  Je nach Kompilerdirektive findet ein bitweiser Vergleich bzw. ein Vergleich
  über CRC32-Prüfsummen statt. Es können sowohl Daten-CDs als auch XCDs über-
  prüft werden.                                                                }

procedure TVerificationThread.Verify(const Drive: string);
var i                     : Integer;
    p                     : Integer;
    ErrorCount            : Integer;
    SourceFile, TargetFile: string;
    IsForm2               : Boolean;
    {$IFNDEF BitwiseVerify}
    SourceCRC, TargetCRC  : LongInt;
    {$ELSE}
    Ok                    : Boolean;
    {$ENDIF}
    {$IFDEF ShowVerifyTime}
    TimeCount             : TTimeCount;
    {$ENDIF}
begin
  {$IFDEF ShowVerifyTime}
  TimeCount := TTimeCount.Create; TimeCount.StartTimeCount;
  {$ENDIF}
  i := 0;
  ErrorCount := 0;
  IsForm2 := False;
  repeat
    FLine := FLang.GMS('mverify01') + '   ' + IntToStr(i + 1) + '/' +
             IntToStr(FVerifyList.Count);
    Synchronize(DStatusBarPanel0);

    p := Pos(':', FVerifyList[i]);
    TargetFile := Copy(FVerifyList[i], 1, p - 1);
    TargetFile := Drive + '\' + TargetFile;
    TargetFile := ReplaceChar(TargetFile, '/', '\');
    SourceFile := FVerifyList[i];
    Delete(SourceFile, 1, p);
    
    {Sonderbehandlung für Form2-Dateien}
    if FXCD then
    begin
      {Form2-File?}
      IsForm2 := Pos('>', FVerifyList[i]) > 0;
      {Endung anpassen, wenn es eine Form2-Datei ist}
      if IsForm2 then
      begin
        Delete(SourceFile, Length(SourceFile), 1);
        TargetFile := MakeForm2FileName(TargetFile);
      end;
    end;

    {$IFNDEF BitwiseVerify}
    {Vergleich über CRC32-Prüfsummen}
    SourceCRC := 0;
    TargetCRC := 0;
    FLine := SourceFile;
    Synchronize(DStatusBarPanel1);
    GetFileCRC32(SourceFile, SourceCRC);
    FLine := TargetFile;
    Synchronize(DStatusBarPanel1);
    if FXCD and IsForm2 then
    begin
      GetForm2FileCRC32(SourceFile, TargetFile, TargetCRC);
    end else
    begin
      GetFileCRC32(TargetFile, TargetCRC);
    end;
    {CRC32 identisch?}
    if (SourceCRC <> TargetCRC) and not Terminated then
    begin
      ErrorCount := ErrorCount + 1;
      if not FileExists(SourceFile) then
        FLine := Format(Flang.GMS('everify06'), [SourceFile]) else
      if not FileExists(TargetFile) then
        FLine := Format(Flang.GMS('everify06'), [TargetFile])
      else
        FLine := Format(Flang.GMS('everify02'), [SourceFile, TargetFile]);
      Synchronize(DAddLine);
    end;
    {$ELSE}
    {bitweiser Vergleich}
    FLine := TargetFile;
    Synchronize(DStatusBarPanel1);
    if FXCD and IsForm2 then
    begin
      Ok := CompareForm2Files(SourceFile, TargetFile);
    end else
    begin
      Ok := CompareFiles(SourceFile, TargetFile);
    end;
    if not Ok and not Terminated then
    begin
      ErrorCount := ErrorCount + 1;
      if not FileExists(SourceFile) then
        FLine := Format(Flang.GMS('everify06'), [SourceFile]) else
      if not FileExists(TargetFile) then
        FLine := Format(Flang.GMS('everify06'), [TargetFile])
      else
        FLine := Format(Flang.GMS('everify02'), [SourceFile, TargetFile]);
      Synchronize(DAddLine);
    end;
    {$ENDIF}

    i := i + 1;
  until (i = FVerifyList.Count) or Terminated;

  if ErrorCount > 0 then
  begin
    FLine := '';
    Synchronize(DAddLine);
  end;
  FLine := Format(FLang.GMS('mverify02'), [ErrorCount]);
  Synchronize(DAddLine);
  FLine := '';
  Synchronize(DAddLine);
  if Terminated {FTerminate} then
  begin
    FLine := FLang.GMS('mverify03');
    Synchronize(DAddLine);
    FLine := '';
    Synchronize(DAddLine);
  end;
  {$IFDEF ShowVerifyTime}
  TimeCount.StopTimeCount;
  FLine := TimeCount.TimeAsString;
  Synchronize(DAddLine);
  TimeCount.Free;
  {$ENDIF}
end;

{ VerifyInit -------------------------------------------------------------------

  Feststellen, welches Laufwerk das richtige ist und den Vergleich starten.    }

procedure TVerificationThread.VerifyInit;
var Drive: string;
begin
  FLine := FLang.GMS('mverify01');
  Synchronize(DAddLine);
  FLine := '';
  Synchronize(DAddLine);
  DStatusBarPanel0;
  if FXCD then if FXCDExt = '' then FXCDExt := 'dat';
  {CD-Laufwerk mit der gerade beschriebenen CD suchen}
  Drive := GetDrive;
  if not Terminated {FTerminate} then
  begin
    if Drive = '' then
    begin
      FLine := FLang.GMS('everify01');
      Synchronize(DAddLine);
    end else
    begin
      CleanUpList(FVerifyList);
      FLine := Format(FLang.GMS('mverify05'), [FVerifyList.Count]);
      Synchronize(DAddLine);
      FLine := '';
      Synchronize(DAddLine);
      Verify(Drive);
    end;
  end else
  begin
    if not FReloadError then
    begin
      FLine := FLang.GMS('mverify03');
      Synchronize(DAddLine);
      FLine := '';
      Synchronize(DAddLine);
    end;
  end;
  Synchronize(SendTerminationMessage);
end;

{ FindDuplicateFiles -----------------------------------------------------------

  In der Liste identische Dateien suchen und mehrfach vorhandene Einträge auf
  den ersten zeigen lassen.                                                    }

procedure TVerificationThread.FindDuplicateFiles;
var i              : Integer;
    Count          : Integer;
    SourceFileSize,
    HashFileSize,
    DuplicateSize,
    TotalSize      : {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF};
    Quota          : Single;
    HashValue      : Longint;
    HashValueStr   : string;
    SourceFile,
    TargetFile,
    HashFile       : string;
    Hashtable      : TStringList;
    {$IFDEF ShowVerifyTime}
    TimeCount      : TTimeCount;
    {$ENDIF}
begin
  {$IFDEF ShowVerifyTime}
  TimeCount := TTimeCount.Create; TimeCount.StartTimeCount;
  {$ENDIF}
  i := 0;
  Count := 0;
  DuplicateSize := 0;
  TotalSize := 0;
  HashTable := TStringList.Create;
  repeat
    FLine := FLang.GMS('mdup01') + '   ' + IntToStr(i + 1) + '/' +
             IntToStr(FVerifyList.Count);
    Synchronize(DStatusBarPanel0);
    {Dateinamen aus Liste}
    SplitString(FVerifyList[i], ':', TargetFile, SourceFile);
    {Das Dummy-Verzeichnis ignorieren.}
    if SourceFile <> DummyDirName then
    begin
      HashValue := 0;
      FLine := SourceFile;
      Synchronize(DStatusBarPanel1);
      GetFileCRC32(SourceFile, HashValue);
      HashValueStr := IntToStr(HashValue);
      {Kam der Hashwert schon einmal vor?}
      HashFile := HashTable.Values[HashValueStr];
      SourceFileSize := GetFileSize(SourceFile);
      TotalSize := TotalSize + SourceFileSize;
      if HashFile = '' then
      begin
        {neuer Wert, also speichern}
        HashTable.Add(HashValueStr + '=' + SourceFile);
      end else
      begin
        {Bekannter Wert, Datei könnte identisch sein. Auch Größe muß überein-
         stimmen}
        HashFileSize   := GetFileSize(HashFile);
        if SourceFileSize = HashFileSize then
        begin
          {Pfad ersetzen}
          FVerifyList[i] := TargetFile + ':' + HashFile;
          Inc(Count);
          DuplicateSize := DuplicateSize + SourceFileSize;
          FLine := Format(Flang.GMS('mdup02'), [SourceFile, HashFile]);
          Synchronize(DAddLine);
        end;
      end;
    end;
    i := i + 1;
  until (i = FVerifyList.Count) or Terminated;
  FDupSize := DuplicateSize;
  Quota := (DuplicateSize / TotalSize) * 100;
  FLine := '';
  Synchronize(DAddLine);
  FLine := Format(FLang.GMS('mdup03'), [SizeToString(DuplicateSize),
                                        Count, FormatFloat('##.#%', Quota)]);
  Synchronize(DAddLine);
  FLine := '';
  Synchronize(DAddLine);
  if Terminated then
  begin
    FLine := FLang.GMS('mverify03');
    Synchronize(DAddLine);
    FLine := '';
    Synchronize(DAddLine);
    FVerifyList.Clear;
  end;
  HashTable.Free;
  {$IFDEF ShowVerifyTime}
  TimeCount.StopTimeCount;
  FLine := TimeCount.TimeAsString;
  Synchronize(DAddLine);
  TimeCount.Free;
  {$ENDIF}
end;

{ CreateInfoFile ---------------------------------------------------------------

  Für alle Form2-Dateien Dateigrpße und CRC32 ermitteln.                       }

procedure TVerificationThread.CreateInfoFile;
var i, j     : Integer;
    Folder   : string;
    FileName : string;
    Size     : {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF};
    CRC32    : Longint;
    InfoList : TStringList;
    Count    : Integer;
    {$IFDEF ShowVerifyTime}
    TimeCount: TTimeCount;
    {$ENDIF}
begin
  {$IFDEF ShowVerifyTime}
  TimeCount := TTimeCount.Create; TimeCount.StartTimeCount;
  {$ENDIF}
  Count := 0;
  InfoList := TStringList.Create;
  {zunächst nur Form2-Dateien und Ordnernamen behalten}
  for i := 0 to FVerifyList.Count - 1 do
    if FVerifyList[i] = '-f' then
    begin
      FVerifyList[i] := '';
      FVerifyList[i + 1] := '';
    end;
  for i := FVerifyList.Count - 1 downto 0 do
  begin
    if FVerifyList[i] = '-m' then Inc(Count);
    if FVerifyList[i] = '' then FVerifyList.Delete(i);
  end;
  {jetzt die List durchgehen}
  i := 0;
  j := 0;
  Folder := '\';
  repeat
    CRC32 := 0;
    if FVerifyList[i] = '-m' then
    begin
      Inc(j);
      FileName := FVerifyList[i + 1];
      FLine := FLang.GMS('mxcd02') + '   ' + IntToStr(j) + '/' +
               IntToStr(Count);
      Synchronize(DStatusBarPanel0);
      FLine := FileName;
      Synchronize(DStatusBarPanel1);
      
      Size := GetFileSize(FileName);
      GetFileCRC32(FileName, CRC32);
      InfoList.Add(Folder + ExtractFileName(FileName) + '|' +
                   IntToStr(LoComp(Size)) + '|' + CRCToStr(CRC32));
    end else
    if FVerifyList[i] = '-d' then
    begin
      Folder := '\' + FVerifyList[i + 1] + '\';
    end;
    Inc(i, 2);
  until (i >= FVerifyList.Count) or Terminated {FTerminate};
  InfoList.SaveToFile(ProgDataDir + cXCDInfoFile);
  InfoList.Free;
  if Terminated then
  begin
    FLine := FLang.GMS('moutput02');
    Synchronize(DAddLine);
    FLine := '';
    Synchronize(DAddLine);
    FVerifyList.Clear;
  end;
  {$IFDEF ShowVerifyTime}
  TimeCount.StopTimeCount;
  FLine := TimeCount.TimeAsString;
  Synchronize(DAddLine);
  TimeCount.Free;
  {$ENDIF}
end;

{ FindDuplicateFilesInit -------------------------------------------------------

  Suche nach identischen Dateien initialisieren und starten.                   }

procedure TVerificationThread.FindDuplicateFilesInit;
begin
  FLine := FLang.GMS('mdup01');
  Synchronize(DAddLine);
  FLine := '';
  Synchronize(DAddLine);
  DStatusBarPanel0;
  FindDuplicateFiles;
  Synchronize(SendTerminationMessage);
end;

{ CreateInfoFileInit -----------------------------------------------------------

  Info-Datei für Mode2/Form2-Dateien anlegen.                                  }

procedure TVerificationThread.CreateInfoFileInit;
begin
  FLine := FLang.GMS('mxcd01');
  Synchronize(DAddLine);
  FLine := '';
  Synchronize(DAddLine);
  DStatusBarPanel0;
  CreateInfoFile;
  Synchronize(SendTerminationMessage);
end;

{ Execute ----------------------------------------------------------------------

  Den Thread starten und mit dem Vergleich beginnen.                           }

procedure TVerificationThread.Execute;
begin
  case FAction of
    cFindDuplicates: FindDuplicateFilesInit;
    cCreateInfoFile: CreateInfoFileInit;
  else
    VerifyInit;
  end;
end;

constructor TVerificationThread.Create(List: TStringList; var Memo: TMemo;
                                       Device: string; Lang: TLang;
                                       Suspended: Boolean);
begin
  FAction := cNoAction;    // spielt beim Verify keine Rolle
  FVerifyList := List;
  FLang := Lang;
  FMemo := Memo;
  FDevice := Device;
  FDrive := '';
  FHandle := (Memo.Owner as TForm).Handle;
  FAutoExec := False;
  FXCD := False;
  FXCDExt := '';
  FXCDKeepExt := True;
  FDupSize := 0;
  inherited Create(Suspended);
end;


{ Funktionen zum einfachen Starten und Beenden eines Threads -------------------

  werden ab cdrtfe 1.0 nicht mehr verwendet.                                   }

{ StartVerifyDataCD ------------------------------------------------------------

  StartVerifyDataCD bereitet die Daten vor und startet den Vergleich. Dieser
  Aufruf verzichtet auf die Fortschrittsanzeige. Wird in diesem Programm nicht
  verwendet.                                                                   }

procedure StartVerifyDataCD(List: TStringList; var Thread: TVerificationThread;
                            Memo: TMemo; Device: string; Lang: TLang);

begin
  Thread := TVerificationThread.Create(List, Memo, Device, Lang, True);
  Thread.FreeOnTerminate := True;
  Thread.Resume;
end;

{ TerminateVerification --------------------------------------------------------

  Dem Thread signalisieren, den Vergleich schnellstmöglich abzubrechen.        }

procedure TerminateVerification(Thread: TVerificationThread);
begin
  if Thread <> nil then
  begin
    Thread.Terminate; //Thread.TerminateThread := True;
  end;
end;


end.
