{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_projectdata_xcd.pas: Datentypen zur Speicherung der Pfadlisten

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  18.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_projectdata_xcd.pas implementiert das Objekt, in dem die zu dem Projekt
  XCD hinzugefügten Dateien und Verzeichnisse gespeichert werden. Als
  Grundlage wird eine Baumstruktur verwendet, die von cl_tree.pas zur Verfügung
  gestellt wird.


  TXCD: wie TCD, zusätzlich

    Properties   AddAsForm2: Boolean
                 Form2FileCount: Integer
                 SmallForm2FileCount: Integer

    Methoden     AddFile(const AddName, DestPath: string); override;
                 ChangeForm2Status(const Name, Path: string)
                 CreateVerifyList(List: TStringList)
                 ExportDataToFile(Root: TNode; var File: TextFile)

}

unit cl_projectdata_xcd;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils, cl_tree, const_core, userevents,
     cl_projectdata_datacd;

type TXCD = class(TCD)
     private
     protected
       FAddAsForm2: Boolean;
       function CountForm2Files(Root: TNode): Integer;
       function CountSmallForm2Files(Root: TNode): Integer;
       function ExtractFileSizeFromEntry(const Entry: string): Int64; override;
       function GetForm2FileCount: Integer;
       function GetSmallForm2FileCount: Integer;
       function IsPreviousSessionFile(const Entry: string): Boolean; override;
       function IsPreviousSessionFolder(const Entry: string): Boolean; override;
       procedure NodeAddFolderRek(Name: string; Node: TNode); override;
       procedure NodeAddMovie(const Name: string; const Node: TNode);
     public
       procedure AddFile(const AddName, DestPath: string); override;
       procedure ChangeForm2Status(const Name, Path: string);
       procedure CreateBurnList(List: TStringList); override;
       procedure CreateVerifyList(List: TStringList);
       procedure ExportDataToFile(Root: TNode; var F: TextFile); override;
       property AddAsForm2: Boolean write FAddAsForm2;
       property Form2FileCount: Integer read GetForm2FileCount;
       property SmallForm2FileCount: Integer read GetSmallForm2FileCount;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_strings;

{ TXCD ----------------------------------------------------------------------- }

{ TXCD - private }

{ IsPreviousSessionFile --------------------------------------------------------

  Diese Funktion wird bei XCDs nicht benötigt und liefert daher immer False.   }

function TXCD.IsPreviousSessionFile(const Entry: string): Boolean;
begin
  Result := False;
end;

{ IsPreviousSessionFolder ------------------------------------------------------

  Diese Funktion wird bei XCDs nicht benötigt und liefert daher immer False.   }

function TXCD.IsPreviousSessionFolder(const Entry: string): Boolean;
begin
  Result := False;
end;

{ NodeAddMovie -----------------------------------------------------------------

  Pfadlisten-Eintrag: <Name der Datei auf CD>:<Quellpfad>*<Größe in Bytes>

  NodeAddMovie macht das gleiche wie NodeAddFile, setzt aber am Ende des
  Eintrags noch '>' als Flag, damit die Form1- von Form2-Dateien unterschieden
  werden können.                                                               }

procedure TXCD.NodeAddMovie(const Name: string; const Node: TNode);
begin
  TPList(Node.Data)^.Add(ExtractFileName(Name) + ':' + Name + '*' +
                         FloatToStr(GetFileSize(Name)) + '>');
end;

{ ExtractFileSizeFromEntry -----------------------------------------------------

  ermittelt die Größe der Datei aus dem Eintrag.                               }

function TXCD.ExtractFileSizeFromEntry(const Entry: string): Int64;
var Temp: string;
begin
  Temp := Entry;
  Temp := StringRight(Entry, '*');
  if Pos('>', Temp) > 0 then
  begin
    Delete(Temp, Pos('>', Temp), 1);
  end;
  Result := StrToInt64Def(Temp, 0);
end;

{ CountForm2Files --------------------------------------------------------------

  CountForm2Files liefert die Anzahl aller Form2-Dateien, die sich in den
  Dateilisten befinden.}

function TXCD.CountForm2Files(Root: TNode): Integer;
var Node: TNode;
    i: Integer;
    c: Integer;
begin
  if (Root <> nil) and (Root.Data <> nil) then
  begin
    c := 0;
    for i := 0 to TPList(Root.Data)^.Count - 1 do
    begin
      if Pos('>', TPList(Root.Data)^[i]) > 0 then
      begin
        c := c + 1;
      end;
    end;
    Result := c;
  end else
  begin
    Result := 0;
  end;
  {nächster Knoten}
  Node := Root.GetFirstChild;
  while Node <> nil do
  begin
    Result := Result + CountForm2Files(Node);
    Node := Root.GetNextChild(Node);
  end;
end;

{ GetForm2FileCount ------------------------------------------------------------

  GetForm2FileCount gibt die Anzahl der Form2-Dateien an das Property
  Form2FileCount.                                                              }

function TXCD.GetForm2FileCount: Integer;
begin
  Result := CountForm2Files(FRoot);
end;

{ CountSmallForm2Files ---------------------------------------------------------

  CountSmallForm2Files ermittelt die Anzahl der Form2-Dateien mit weniger als
  348.601 Bytes.}

function TXCD.CountSmallForm2Files(Root: TNode): Integer;
var Node: TNode;
    c   : Integer;
    i   : Integer;
    Temp: string;
begin
  if (Root <> nil) and (Root.Data <> nil) then
  begin
    c := 0;
    for i := 0 to TPList(Root.Data)^.Count - 1 do
    begin
      if Pos('>', TPList(Root.Data)^[i]) > 0 then
      begin
        Temp := TPList(Root.Data)^[i];
        Delete(Temp, 1, Pos('*', Temp));
        Delete(Temp, Pos('>', Temp), 1);
        if StrToFloatDef(Temp, 0) < 348601 then
        begin
          c := c + 1;
        end;
      end;
    end;
    Result := c;
  end else
  begin
    Result := 0;
  end;
  {nächster Knoten}
  Node := Root.GetFirstChild;
  while Node <> nil do
  begin
    Result := Result + CountSmallForm2Files(Node);
    Node := Root.GetNextChild(Node);
  end;
end;

{ GetSmallForm2FileCount -------------------------------------------------------

  GetSmallForm2FileCount gibt die Anzahl der Form2-Dateien an das Property
  Form2FileCount.                                                              }

function TXCD.GetSmallForm2FileCount: Integer;
begin
  Result := CountSmallForm2Files(FRoot);
end;

{ TXCD - public }

procedure TXCD.ExportDataToFile(Root: TNode; var F: TextFile);
var Node: TNode;
    i: Integer;
    q: Integer;
    Path: string;
    Temp: string;
begin
  {Pfad innerhalb des Trees bestimmen}
  Path := GetPathFromFolder(Root);
  {Dateiliste speichern}
  if (Root <> nil) and (Root.Data <> nil) then
  begin
    for i := 0 to TPList(Root.Data)^.Count - 1 do
    begin
      Temp := Path + TPList(Root.Data)^[i];
      q := Pos('>', Temp);
      Temp := StringLeft(Temp, '*');
      if q > 0 then
      begin
        Temp := Temp + '>';
      end;
      Writeln(F, Temp);
    end;
  end;
  {nächster Knoten}
  Node := Root.GetFirstChild;
  while Node <> nil do
  begin
    ExportDataToFile(Node, F);
    Node := Root.GetNextChild(Node);
  end;
end;

{ NodeAddFolderRek -------------------------------------------------------------

  NodeAddFolderRek ist eigentliche rekursive Prozedure, die das Einfügen der
  Ordner vornimmt.                                                             }

procedure TXCD.NodeAddFolderRek(Name: string; Node: TNode);
var SearchRec  : TSearchRec;
    NodeTemp   : TNode;
    PList      : TPList;
begin
  {$IFDEF DebugAddFiles}
  with FormDebug.Memo3.Lines do
  begin
    Add('');
    Add('  Enter NodeAddFolderRek: ' + Name + ', ' + Node.Text);
  end;
  {$ENDIF}
  if Name[Length(Name)] <> '\' then
  begin
    Name := Name + '\';
  end;
  if FindFirst(Name + '*.*', faDirectory or faAnyFile, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Attr and faDirectory = faDirectory) and
         (SearchRec.Name[1] <> '.') then
      begin {es ist ein Verzeichnis}
        if (SearchRec.Attr and faDirectory > 0) then
        begin
          {Dateiliste für neuen Knoten erstellen}
          New(PList);
          PList^ := TStringList.Create;
          {neuen Knoten im aktuellen einfügen, neuer wird aktueller Knoten}
          Node := Node.Items.AddChild(SearchRec.Name);
          Node.Data := PList;
          PList := nil;
          Dispose(PList);
        end;
        {ursprünglichen Knoten merken}
        NodeTemp := Node.Parent;
        {auf Untereinträge prüfen}
        {$IFDEF DebugAddFiles}
        FormDebug.Memo3.Lines.Add('    calling TXCD.NodeAddFolderRek: ' + Name +
                                  SearchRec.Name + ', ' + Node.Text);
        {$ENDIF}
        NodeAddFolderRek(Name + SearchRec.Name, Node);
        {ursprünglichen Knoten wieder zum aktuellen machen}
        Node := NodeTemp;
      end else
      begin {es ist eine Datei}
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          {Dateinamen in die Dateiliste des aktuellen Knotens einfügen}
          if (Pos('.avi', LowerCase(SearchRec.Name)) > 0) or FAddAsForm2 then
          begin
            NodeAddMovie(Name + SearchRec.Name, Node);
          end else
          begin
            NodeAddFile(Name + SearchRec.Name, Node);
          end;
        end;
      end;
      Application.ProcessMessages;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
    TPList(Node.Data)^.Sort;
//    CDEFilesToSort := False;
//    CDEFilesToSortFolder := '';
  end;
end;

{ AddFile ----------------------------------------------------------------------

  Fügt eine Datei oder ein Verzeichnis zur Pfadliste hinzu.
    Name    : Datei oder Ordner
    DestPath: Ordner, in den eingefügt wird                                    }

procedure TXCD.AddFile(const AddName, DestPath: string);
var IsFile, IsDir: Boolean;
    Name: string;
    DestFolder: TNode;
begin
  DestFolder := GetFolderFromPath(DestPath);
  {$IFDEF DebugAddFiles}
  with FormDebug.Memo3.Lines do
  begin
    Add('');
    Add('Enter AddFile   : ' + AddName + ', ' + self.ClassName);
    Add('      DestPath  : ' + DestPath);
    Add('      DestFolder: ' + DestFolder.Text);
  end;
  {$ENDIF}
  IsFile := FileExists(AddName);
  IsDir := DirectoryExists(AddName);
  if IsFile or IsDir then
  begin
    if IsDir then
    begin
      Name := AddName;
      Delete(Name, 1, LastDelimiter('\', Name));
      if FolderIsUnique(Name, DestFolder) then
      begin
        NodeAddFolder(AddName, DestFolder);
        DestFolder.AlphaSortRek;
        InvalidateCounters;
      end else
      begin
        FError := CD_FolderNotUnique;
      end;
    end;
    if IsFile then
    begin
      Name := AddName;
      Delete(Name, 1, LastDelimiter('\', Name));
      if FileIsUnique(Name, DestFolder) then
      begin
        if (Pos('.avi', LowerCase(AddName)) > 0) or FAddAsForm2 then
        begin
          NodeAddMovie(AddName, DestFolder);
        end else
        begin
          NodeAddFile(AddName, DestFolder);
        end;
        InvalidateCounters;
      end else
      begin
        FError := CD_FileNotUnique;
      end;
    end;
  end else
  begin
    FError := CD_FileNotFound;
  end;
end;

{ ChangeForm2Status ------------------------------------------------------------

  verschiebt Dateien von der Datei-Liste in die Movie-Liste und umgekehrt.     }

procedure TXCD.ChangeForm2Status(const Name, Path: string);
var Index: Integer;
    FileList: TStringList;
    Temp: string;
begin
  Index := GetIndexOfFile(Name, Path);
  FileList := GetFileList(Path);
  Temp := FileList[Index];
  if Temp[Length(Temp)] = '>' then
  begin
    Delete(Temp, Length(Temp), 1);
  end else
  begin
    Temp := Temp + '>';
  end;
  FileList[Index] := Temp;
end;

{ CreateBurnList ---------------------------------------------------------------

  CreateBurnList erzeugt aus den Daten in der Baumstruktur die Pfadliste, die an
  mode2cdmaker übergeben wird.                                                 }

procedure TXCD.CreateBurnList(List: TStringList);

  procedure CreateXCDBurnList(Root: TNode);
  var Node: TNode;
      i: Integer;
      Temp: string;
      Path: string;
  begin
    {Pfadangabe für -graft-points bestimmen}
    Path := GetPathFromFolder(Root);
    Delete(Path, Length(Path), 1);
    Path := ReplaceChar(Path, '/', '\');
    if Path <> '' then
    begin
      List.Add('-d');
      List.Add(Path);
    end;
    {Dateiliste des Ordners kopieren}
    for i := 0 to TPList(Root.Data)^.Count - 1 do
    begin
      Temp := TPList(Root.Data)^[i];
      {Form1 oder Form2?}
      if Pos('>', Temp) > 0 then
      begin
        List.Add('-m');
      end else
      begin
        List.Add('-f');
      end;
      {Zusatzinfos entfernen}
      Temp := StringLeft(Temp, '*');
      {graft-points-Infos entfernen, mode2cdmaker kann nichts damit anfangen}
      Temp := StringRight(Temp, ':');
      List.Add(Temp);
    end;
    {nächster Knoten}
    Node := Root.GetFirstChild;
    while Node <> nil do
    begin
      CreateXCDBurnList(Node);
      Node := Root.GetNextChild(Node);
    end;
  end;

begin
  CreateXCDBurnList(FRoot);
end;

{ CreateVerifyList -------------------------------------------------------------

  CreateVerifyList erzeugt aus den Daten in der Baumstruktur die Pfadliste für
  den abschließenden Vergleich.                                                }

procedure TXCD.CreateVerifyList(List: TStringList);

  procedure CreateVerifyListRek(Root: TNode);
  var Node: TNode;
      i: Integer;
      Temp: string;
      Path: string;
      IsForm2: Boolean;
  begin
    {Pfadangabe für -graft-points bestimmen}
    Path := GetPathFromFolder(Root);
    // Path := ReplaceChar(Path, '/', '\');
    {Dateiliste des Ordners kopieren}
    for i := 0 to TPList(Root.Data)^.Count - 1 do
    begin
      Temp := Path + TPList(Root.Data)^[i];
      IsForm2 := Pos('>', Temp) > 0;
      {Zusatzinfos entfernen, bis auf Form2-Flag}
      Temp := StringLeft(Temp, '*');
      if IsForm2 then Temp := Temp + '>';
      List.Add(Temp);
    end;
    {nächster Knoten}
    Node := Root.GetFirstChild;
    while Node <> nil do
    begin
      CreateVerifyListRek(Node);
      Node := Root.GetNextChild(Node);
    end;
  end;

begin
  CreateVerifyListRek(FRoot);
end;

end.
