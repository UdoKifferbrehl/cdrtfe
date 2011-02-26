{ f_treelistfuncs.pas: List- und Treeview-Funktionen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  05.01.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_treelistfuncs.pas stellt Hilfs-Funktionen zur Verfügung:
    * allgemeine Funktionen für List- und Tree-Views


  exportierte Funktionen/Prozeduren:
    GetPathFromNode(Root: TTreeNode): string
    GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode
    ItemIsFolder(Item: TListItem): Boolean
    ListViewSelectAll(ListView: TListView)
    SelectRootIfNoneSelected(Tree: TTreeView)

}

unit f_treelistfuncs;

{$I directives.inc}

interface

uses Classes, ComCtrls;

function GetPathFromNode(Root: TTreeNode): string;
function GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode;
function ItemIsFolder(Item: TListItem): Boolean;
procedure ListViewSelectAll(ListView: TListView);
procedure SelectRootIfNoneSelected(Tree: TTreeView);

implementation

{ GetPathFromNode --------------------------------------------------------------

  GetPathFromNode bestimmt den Pfad des angegebenen Knotens ausgehend von der
  Wurzel.                                                                      }

function GetPathFromNode(Root: TTreeNode): string;
var Parent: TTreeNode;
    Path: string;
begin
  Parent := Root;
  Path := '';
  while Parent.Level > 0 {Parent <> nil} do
  begin
    Insert(Parent.Text + '/', Path, 1);
    Parent := Parent.Parent;
  end;
  Result := Path;
end;

{ GetNodeFromPath --------------------------------------------------------------

  GetNodeFromPath geht ausgehend vom Knoten Root den angegebenen Pfad und
  liefert den Zielknoten als Ergebnis. Pfadtrenner ist '/'; kein Pfadtrenner am
  Anfang erlaubt. Bei leerer Pfadangabe wird der Knoten Root zurückgegeben.
  Bei einem inkorrektem Pfad wird nil zurückgegeben.                           }

function GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode;
var Node: TTreeNode;
    p: Integer;
    List: TSTringList;
    ok: Boolean;
begin
  if Path <> '' then
  begin
    if Path[Length(Path)] <> '/' then
    begin
      Path := Path + '/';
    end;
    {Pfad auftrennen}
    List := TSTringList.Create;
    p := Pos('/', Path);
    while p <> 0 do
    begin
      List.Add(Copy(Path, 1, p - 1));
      Delete(Path, 1, p);
      p := Pos('/', Path);
    end;
    p := 0;
    ok := True;
    while (p < List.Count) and ok do
    begin
      Node := Root.GetFirstChild;
      while (Node <> nil) and (Node.Text <> List[p]) do
      begin
        Node := Root.GetNextChild(Node);
      end;
      if Node = nil then {Pfad war falsch, kein Knoten gefunden}
      begin
        ok := False;
      end;
      Root := Node;
      p := p + 1;
    end;
    List.Free;
  end;
  Result := Root;
end;

{ ListViewSelectAll ------------------------------------------------------------

  ListViewSelectAll selektiert alle Elemtente eines ListViews.                 }

procedure ListViewSelectAll(ListView: TListView);
var i: Integer;
begin
  for i := 0 to ListView.Items.Count - 1 do
  begin
    ListView.Items[i].Selected := True;
  end;
end;

{ SelectRootIfNoneSelected -----------------------------------------------------

  SelecteRootIfNoneSelected selektiert den Wurzelknoten eines TreeView, wenn
  kein anderer Knoten ausgewählt ist.                                          }

procedure SelectRootIfNoneSelected(Tree: TTreeView);
begin
  if Tree.Selected = nil then
  begin
    Tree.Selected := Tree.Items[0];
  end;
end;

{ ItemIsFolder -----------------------------------------------------------------

  ergibt True, wenn Item im ListView für einen Dateiordner steht.              }

function ItemIsFolder(Item: TListItem): Boolean;
begin
  Result := False;
  if (Item <> nil) and (Item.SubItems.Count > 2) then
    Result := {(Item.SubItems[0] = '') and} (Item.SubItems[2] = '');
end;

end.
