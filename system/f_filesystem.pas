{ f_filesystem.pas: Dateisystemfunktionen

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  09.042005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_filesystem.pas stellt Funktionen zum Dateisystem zur Verfügung:
    * Dateinamen/CD-Label überprüfen
    * Datei-/Ordnergröße ermitteln
    * Laufwerksliste erstellen
    * Datei im Suchpfad finden
    * Laufwerk auf eingelegtes Medium prüfen
    * Auswahldialog für Ordner
    * Funktionen, um bestimmte Ordner zu finden


  exportierte Funktionen/Prozeduren:

    CDLabelIsValid(const VolID: string):Boolean
    ChooseDir(const Caption: String; const OwnerHandle: HWnd): String
    DriveEmpty(const Drive: Integer): Boolean
    FilenameIsValid(const Name: string):Boolean
    FindInSearchPath(const Name: string): string
    GetDirSize(Verzeichnis: string): Longint
    GetDriveList(const DriveType: Integer; DriveList: TStringList): Byte
    GetFileSize(const Filename: string): Longint
    GetLastDirFromPath(Path: string; const Delimiter: Char):string
    GetShellFolder(ID: Integer): string
    ProgDataDir: string
    StartUpDir: string

}

unit f_filesystem;

{$I directives.inc}

interface

uses Forms, Windows, Classes, SysUtils, ShlObj, FileCtrl, ActiveX, Registry;

      {IDs für spezielle Ordner}
const CSIDL_APPDATA              = $001A; {Application Data, new for NT4}
      CSIDL_LOCAL_APPDATA        = $001C; {user\Local Settings\Application Data}
      CSIDL_COMMON_APPDATA       = $0023; {All Users\Application Data}

function CDLabelIsValid(const VolID: string):Boolean;
function ChooseDir(const Caption: String; const OwnerHandle: HWnd): String;
function DriveEmpty(const Drive: Integer): Boolean;
function FilenameIsValid(const Name: string):Boolean;
function FindInSearchPath(const Name: string): string;
function GetDirSize(Verzeichnis: string): Longint;
function GetDriveList(const DriveType: Integer; DriveList: TStringList): Byte;
function GetFileSize(const FileName: string): {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF};
function GetShellFolder(ID: Integer): string;
function GetLastDirFromPath(Path: string; const Delimiter: Char):string;
function ProgDataDir: string;
function StartUpDir: string;

implementation

uses f_largeint, f_wininfo, constant;

{ StartUpDir -------------------------------------------------------------------

  StartUpDir liefert das Verzeichnis, in dem sich cdrtfe.exe befindet.         }

function StartUpDir: string;
var Temp: string;
begin
  Temp := ExtractFileDir(ParamStr(0));
  if Temp[Length(Temp)] = '\' then
  begin
    Delete(Temp, Length(Temp), 1);
  end;
  Result := Temp;
end;

{ ProgDataDir ------------------------------------------------------------------

  ProgDataDir liefert das Verzeichnis, in dem die cdrtfe.ini und die temporären
  Dateien gespeichert werden.                                                  }

function ProgDataDir: string;
begin
  if PlatformWinNT then
  begin
    Result := GetShellFolder(CSIDL_LOCAL_APPDATA);
    if Result = '' then
    begin
      Result := GetShellFolder(CSIDL_APPDATA);
      if Result = '' then
      begin
        Result := GetShellFolder(CSIDL_COMMON_APPDATA);
      end;
    end;
    if Result = '' then
    begin
      Result := StartUpDir;
    end else
    begin
      Result := Result + cDataDir;
    end;
  end else
  begin
    Result := StartUpDir;
  end;
end;

{ GetFileSize ------------------------------------------------------------------

  GeFileSize liefert die Größe einer Datei in Byte.                            }

function GetFileSize(const Filename: string): {$IFDEF LargeFiles} Comp
                                              {$ELSE} Longint {$ENDIF};
var SR: TSearchRec;
    {$IFDEF LargeFiles}
    SizeHigh: Integer;
    SizeLow : Integer;
    {$ENDIF}
begin
  if FindFirst(Filename, faAnyFile, SR) = 0 then
  begin
    {$IFDEF LargeFiles}
    SizeHigh := SR.FindData.nFileSizeHigh;
    SizeLow  := SR.FindData.nFileSizeLow;
    Result := IntToComp(SizeLow, SizeHigh);
    {$ELSE}
    Result := SR.Size;
    {$ENDIF}
    FindClose(SR);
  end else
  begin
    Result := -1;
  end;
end;

{ GetDirSize -------------------------------------------------------------------

  GetDirSize liefert die Größe eines Ordners incl. aller Dateien und
  Unterordner.                                                                 }

function GetDirSize(Verzeichnis: string): Longint;
var SR     : TSearchRec;
    Groesse: Longint;
begin
  Groesse := 0;
  if Verzeichnis[length(Verzeichnis)] <> '\' then
  begin
    Verzeichnis := Verzeichnis + '\';
  end;
  if FindFirst(Verzeichnis + '*.*', $3F, SR) = 0 then
  begin
    repeat
      if ((SR.Attr and faDirectory) > 0) and
         (SR.Name <> '.') and
         (SR.Name <> '..') then
      begin
        Groesse:=Groesse + GetDirSize(Verzeichnis + SR.Name);
      end else
      begin
        Groesse:=Groesse + SR.Size;
      end; {
      if (SR.Name <> '.') and (SR.Name <> '..') then
      begin
        VerzListe.Add(Verzeichnis + SR.Name);
      end;  }
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  Result := Groesse;
end;

{ FilenameIsValid --------------------------------------------------------------

  FileNameIsValid prüft, ob im Dateinamen unerlaubte Zeichnen vorkommen. Nicht
  erlaubt sind: \ / : * ? " < > ;
  Dies gilt nur für Dateinamen auf CDs.                                        }

function FilenameIsValid(const Name: string):Boolean;
begin
  Result := not ((LastDelimiter('\/:*?"<>|;', Name) > 0) or (Name = ''));
end;

{ CDLabelIsValid ---------------------------------------------------------------

  CDLabelIsValid prüft, ob die Volume-ID gültig ist.                           }

function CDLabelIsValid(const VolID: string):Boolean;
begin
  Result := Length(VolID) < 33;
end;

{ GetLastDirFromPath -----------------------------------------------------------

  GetLastDirFromPath ermittelt den letzten Ordners im angegebenen Pfad. Diese
  Funktion sollte nur auf Verzeichnisnamen angewendet werden. Delimiter ist der
  Pfadtrenner (\ oder /).                                                      }

function GetLastDirFromPath(Path: string; const Delimiter: Char):string;
var p: Integer;
begin
  p :=  Pos(Delimiter, Path);
  while p > 0 do
  begin
    Delete(Path, 1, p);
    p := Pos(Delimiter, Path);
  end;
  Result := Path;
end;

{ ChooseDir --------------------------------------------------------------------

  zeigt einen Auswahldialog für Verzeichnisse an.                              }

function ChooseDir(const Caption: String; const OwnerHandle: HWnd): String;
var
  lpItemID: PItemIDList;
  Malloc: IMalloc;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of char;
  TempPath: array[0..MAX_PATH] of char;
  NewPath: String ;
begin
  Result := '' ;
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  ShGetMalloc(Malloc);
  with BrowseInfo do begin
    hwndOwner := OwnerHandle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar (Caption) ;
    ulFlags := 0 ;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    SHGetPathFromIDList(lpItemID, TempPath);
    NewPath := TempPath;
    Malloc.Free(lpItemId)
  end;
  if DirectoryExists (NewPath) then
    Result := (NewPath) ;
end;

{ FindInSearchPath -------------------------------------------------------------

  FindInSearchPath sucht die Datei Name im Suchpfad. Zurückgegeben wird der
  gesamte Pfad, falls die Datei gefunden wurde. Andernfalls ist ein leerer
  String das Ergebnis.                                                         }

function FindInSearchPath(const Name: string): string;
var FileNamePath  : PChar;
    FileName      : PChar;
    r: Integer;
begin
  GetMem(FileNamePath, 1024);

  r := SearchPath(nil, PChar(Name), nil, 1024, FileNamePath, FileName);

  if r <> 0 then
  begin
    Result := string(FileNamePath);
  end else
  begin
    Result := '';
  end;
  FreeMem(FileNamePath);
end;

{ GetDriveList -----------------------------------------------------------------

  GetDriveList liefert eine Liste der Laufwerksbuchstaben, die einem bestimmten
  Laufwerkstyp entsprechen. Auch die Anzahl der gefundenen Laufwerke wird
  zurückgegeben. Laufwerkstypen: DRIVE_REMOVABLE, DRIVE_FIXED, DRIVE_REMOTE,
  DRIVE_CDROM, DRIVE_RAMDISK. Format: <drive>:\                                }

function GetDriveList(const DriveType: Integer; DriveList: TStringList): Byte;
var Drives     :  array [0..105] of char;
    TempList   : TStringList;
    DriveString: PChar;
    i          : Byte;
begin
  Result := 0;
  TempList := TStringList.Create;
  DriveString := Drives;
  {Alle Laufwerke ermitteln}
  GetLogicalDriveStrings(106, @Drives);
  while DriveString^ <> #0 do
  begin
    TempList.Add(string(DriveString));
    Inc(DriveString, StrLen(DriveString) + 1);
  end;
  {Laufwerke des gesuchten Typs ermitteln}
  for i := 0 to TempList.Count - 1 do
  begin
    if GetDriveType(PChar(TempList[i])) = DriveType then
    begin
      DriveList.Add(TempList[i]);
      Result := Result + 1;
    end;
  end;
  TempList.Free;
end;

{ DriveEmpty -------------------------------------------------------------------

  DriveEmpty gibt True zurück, wenn kein Datenträger im Laufwerk ist.
  a: -> 1, b: - > 2, ...                                                       }

function DriveEmpty(const Drive: Integer): Boolean;
var ErrorMode: Word;
begin
  {Meldung eines kritischen Systemfehlers vehindern}
  ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
  try
    if DiskSize(Drive) = -1 then
    begin
      Result := True;
    end else
    begin
      Result := False;
    end;
  finally
    {ErrorMode auf den alten Wert setzen}
    SetErrorMode(ErrorMode);
  end;
end;

{ GetShellFolder ---------------------------------------------------------------

  GetShellFolder liefert den der ID entsprechenden Ordnernamen zurück.         }

function GetShellFolder(ID: Integer): string;
var S: string;
    ItemIDList: PItemIDList;
    SystemHeap: IMalloc;
begin
  Result := EmptyStr;
  if SHGetSpecialFolderLocation(Application.Handle, ID, ItemIDList)
                                                                  = NOERROR then
  begin
    try
      SetLength(S, MAX_PATH);
      if SHGetPathFromIDList(ItemIDList, PChar(S)) then
      begin
        Result:= Copy(S, 1, Pos(#0, S) - 1);
      end;
    finally
      {Von der Shell reservierten Speicher freigeben}
      if SHGetMalloc(SystemHeap) = NOERROR then
      begin
        SystemHeap.Free(ItemIDList);
      end;
    end;
  end;
end;

end.
