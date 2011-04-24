{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_foldernamecache.pas: Ordnernamen merken

  Copyright (c) 2008-2001 Oliver Valencia

  letzte Änderung  24.04.2011

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_foldernamecache.pas stellt Funktionen zur Verfügung, um Ordnernamen für 
  verschiedene Dialoge zwischenzuspeichern.


  exportierte Funktionen/Prozeduren:

    CacheFolderName(const DialogID: TDialogID; const Folder: string)
    GetCachedFolderName(const DialogID: TDialogID): string

}

unit f_foldernamecache;

{$I directives.inc}

interface

uses SysUtils, FileCtrl;

const FNCCount = 21;

type TDialogID = (DIDDataCDFile,
                  DIDDataCDFolder,
                  DIDDataCDImage,
                  DIDXCDFile,
                  DIDXCDFile2,
                  DIDXCDFolder,
                  DIDXCDImage,
                  DIDAudioCDTrack,
                  DIDVideoCDTrack,
                  DIDVideoCDImage,
                  DIDDAEFolder,
                  DIDCDImage,
                  DIDSaveImage,
                  DIDVideoDVDFolder,
                  DIDVideoDVDImage,
                  DIDLoadProject,      // & save
                  DIDLoadList,         // & save
                  DIDBootImage,
                  DIDSaveLog,
                  DIDTempFolder,
                  DIDDummy);

function GetCachedFolderName(const DialogID: TDialogID): string;
procedure CacheFolderName(const DialogID: TDialogID; const Folder: string);

implementation

type TFolderNameCache = array[0..FNCCount - 1] of string;

var FolderNameCache: TFolderNameCache;

{ CacheFolderName --------------------------------------------------------------

  speichert Folder entsprechend der Dialog-ID ab. Statt Ordnernamen können auch
  Dateinamen übergeben werden. In diesem Fall wird vorher der Ordnername er-
  mittelt.                                                                     }

procedure CacheFolderName(const DialogID: TDialogID; const Folder: string);
begin
  if DirectoryExists(Folder) then
  begin
    FolderNameCache[Integer(DialogID)] := Folder;
  end else
  if FileExists(Folder) then
  begin
    FolderNameCache[Integer(DialogID)] := ExtractFileDir(Folder);
  end else
  begin
    {Save-Dialoge: Ziel könnte noch nicht existieren, daher ist noch eine
     Entscheidung nötig, ob Datei oder Ordner}
    FolderNameCache[Integer(DialogID)] := ExtractFileDir(Folder);
  end;
end;

{ GetCachedFolderName ----------------------------------------------------------

  liefert zu einer Dialog-ID den gespeicherten Ordnernamen.                    }

function GetCachedFolderName(const DialogID: TDialogID): string;
var Folder: string;
begin
  Folder := FolderNameCache[Integer(DialogID)];
  if not DirectoryExists(Folder) then Result := '';
  Result := Folder;
end;

{ InitFolderCache --------------------------------------------------------------

  setzt alle Einträge des Caches auf ''.                                       }

procedure InitFolderCache;
var i: Integer;
begin
  for i := 0 to FNCCount - 1 do FolderNameCache[i] := '';
end;

initialization
  InitFolderCache;

end.
