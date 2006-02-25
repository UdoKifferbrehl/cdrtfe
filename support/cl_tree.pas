{ cl_tree.pas: Implementierung einer einfachen Baum-Struktur

  Copyright (c) 2004-2006 Oliver Valencia

  Version          1.0
  erstellt         11.02.2004
  letzte Änderung  17.01.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_tree.pas stellt eine einfache baumartige Datenstruktur zur Verfügung, die
  der bei einem TTreeView verwendeten ähnlich ist.


  TNodes: Liste, die Knoten vom Typ TNode enthält

    Properties   Count: Integer
                 Item[Index: Integer]: TNode
                 Owner: TNode

    Methoden     AddChild(const S: string): TNode
                 AlphaSort
                 AlphaSortRek
                 Clear
                 Create(Node: TNode)
                 DeleteChild(const Index: Integer)
                 Destroy
                 IndexOf(Node: TNode): Integer


  TNode: Knoten

    Properties   ChildCount: Integer
                 Data: Pointer
                 HasChildren: Boolean
                 Items: TNodes
                 Level: Integer
                 Parent: TNode
                 Text: string

    Methoden     AlphaSort
                 AlphaSortRek
                 Create(Node: TNode)
                 Delete
                 Destroy
                 GetFirstChild: TNode
                 GetNextChild(Node: TNode): TNode
                 GetNextSibling: TNode;
                 GetPath: string;
                 GetPrevSibling: TNode;
                 HasAsParent(Node: TNode): Boolean;
                 LoadStructureFromStream(Stream: TStream)
                 MoveTo(Destination: TNode)
                 SaveStructureToStream(Stream: TStream)

}

unit cl_tree;

interface

uses Classes, SysUtils;

type TNode = class;

     TNodes = class(TObject)
     private
       FItems: TList;
       FOwner: TNode;
       function GetNode(Index: Integer): TNode;
       function GetCount: Integer;
       procedure SetNode(Index: Integer; Node: TNode);
     public
       constructor Create(Node: TNode);
       destructor Destroy; override;
       function IndexOf(Node: TNode): Integer;
       function AddChild(const S: string): TNode;
       procedure DeleteChild(const Index: Integer);
       procedure Clear;
       procedure AlphaSort;
       procedure AlphaSortRek;
       property Item[Index: Integer]: TNode read GetNode write SetNode; default;
       property Owner: TNode read FOwner;
       property Count: Integer read GetCount;
     end;

     TNode = class(TObject)
     private
       FText: string;
       FData: Pointer;
       FNodes: TNodes;
       FParent: TNode;
       function GetLevel: Integer;
       function GetChildren: Boolean;
       function GetCount: Integer;
       procedure SetText(const S: string);
       procedure SetData(P: Pointer);
     public
       constructor Create(Node: TNode);
       destructor Destroy; override;
       function GetFirstChild: TNode;
       function GetNextChild(Node: TNode): TNode;
       function GetNextSibling: TNode;
       function GetPath: string;
       function GetPrevSibling: TNode;
       function HasAsParent(Node: TNode): Boolean;
       procedure Delete;
       procedure AlphaSort;
       procedure AlphaSortRek;
       procedure LoadStructureFromStream(Stream: TStream);
       procedure SaveStructureToStream(Stream: TStream);
       procedure MoveTo(Destination: TNode);
       property Text: string read FText write SetText;
       property Data: Pointer read FData write SetData;
       property Level: Integer read GetLevel;
       property Parent: TNode read FParent;
       property HasChildren: Boolean read GetChildren;
       property ChildCount: Integer read GetCount;
       property Items: TNodes read FNodes;
     end;

implementation

{ TListSortCompare ----------------------------------------------------------- }

function ListAlphaSort(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareText(TNode(Item1).Text, TNode(Item2).Text);
end;


{ TNodes --------------------------------------------------------------------- }

{ TNodes - private }

function TNodes.GetNode(Index: Integer): TNode;
begin
  if FItems.Count > Index then
  begin
    Result := FItems[Index];
  end else
  begin
    Result := nil;
  end;
end;

function TNodes.GetCount: Integer;
begin
  Result := FItems.Count;
end;

procedure TNodes.SetNode(Index: Integer; Node: TNode);
begin
  if FItems.Count > Index then
  begin
    TNode(FItems[Index]).Free;
    FItems[Index] := Node;
  end else
  begin
    FItems.Add(Node);
  end;
  Node.FParent := FOwner;
end;

{ TNodes - public }

constructor TNodes.Create(Node: TNode);
begin
  inherited Create;
  FOwner := Node;
  FItems := TList.Create;
end;

destructor TNodes.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TNodes.IndexOf(Node: TNode): Integer;
begin
  Result :=  FItems.IndexOf(Node);
end;

function TNodes.AddChild(const S: string): TNode;
var NewNode: TNode;
begin
  NewNode := TNode.Create(FOwner);
  NewNode.Text := S;
  FItems.Add(NewNode);
  Result := NewNode;
end;

procedure TNodes.DeleteChild(const Index: Integer);
begin
  if FItems.Count > Index then
  begin
    TNode(FItems[Index]).Free;
    FItems.Delete(Index);
  end;
end;

procedure TNodes.Clear;
begin
  while FItems.Count > 0 do
  begin
    DeleteChild(0);
  end;
end;

procedure TNodes.AlphaSort;
begin
  FItems.Sort(@ListAlphaSort);
end;

procedure TNodes.AlphaSortRek;
var i: Integer;
    Node: TNode;
begin
  FItems.Sort(@ListAlphaSort);
  for i := 0 to FItems.Count - 1 do
  begin
    Node := GetNode(i);
    if Node.ChildCount > 0 then
    begin
      Node.AlphaSortRek;
    end;
  end;
end;


{ TNode ---------------------------------------------------------------------- }

{ Hilfprozeduren für TNode }

procedure GetNameLevelFromString(var s: string; var Level: Integer);
begin
  Level := 0;
  while s[1] in [' ', #9] do
  begin
    Delete(s, 1, 1);
    Level := Level + 1;
  end;
end;

function GetNameLevelIndent(Node: TNode; LevelCorr: Integer): string;
const Tab = #9;
var s: string;
    i: Integer;
begin
  for i := 0 to (Node.Level - LevelCorr - 1) do s := s + Tab;
  s := s + Node.Text;
  Result := s;
end;

procedure ExportStructureToStream(Root: TNode; Level: Integer; Stream: TStream);
const EOL = #13#10;
var Node: TNode;
    s: string;
begin
  if (Root <> nil) then
  begin
    s := GetNameLevelIndent(Root, Level) + EOL;
    Stream.Write(Pointer(s)^, Length(s));
    {nächster Knoten}
    Node := Root.GetFirstChild;
    while Node <> nil do
    begin
      ExportStructureToStream(Node, Level, Stream);
      Node := Root.GetNextChild(Node);
    end;
  end;
end;

{ TNode - private }

function TNode.GetLevel: Integer;
var Node: TNode;
begin
  Result := 0;
  Node := Parent;
  while Node <> nil do
  begin
    Result := Result + 1;
    Node := Node.Parent;
  end;
end;

function TNode.GetChildren: Boolean;
begin
  Result := FNodes.Count > 0;
end;

function TNode.GetCount: Integer;
begin
  Result := FNodes.FItems.Count;
end;

procedure TNode.SetText(const S: string);
begin
  FText := S;
end;

procedure TNode.SetData(P: Pointer);
begin
  FData := P;
end;

{ TNode - public }

constructor TNode.Create(Node: TNode);
begin
  inherited Create;
  FParent := Node;
  FText := '';
  FData := nil;
  FNodes := TNodes.Create(self);
end;

destructor TNode.Destroy;
begin
  FNodes.Clear;
  FNodes.Free;
  inherited Destroy;
end;

function TNode.GetFirstChild: TNode;
begin
  if FNodes.Count > 0 then
  begin
    Result := FNodes[0];
  end else
  begin
    Result := nil;
  end;
end;

function TNode.GetNextChild(Node: TNode): TNode;
var i: Integer;
begin
  i := FNodes.IndexOf(Node);
  Result := FNodes[i + 1];
end;

function TNode.GetNextSibling: TNode;
var i: Integer;
begin
  if FParent <> nil then
  begin
    i := FParent.Items.IndexOf(self);
    i := i + 1;
    if i < FParent.Items.Count then
    begin
      Result := FParent.Items.GetNode(i);
    end else
    begin
      Result := nil;
    end;
  end else
  begin
    Result := nil;
  end;
end;

function TNode.GetPrevSibling: TNode;
var i: Integer;
begin
  if FParent <> nil then
  begin
    i := FParent.Items.IndexOf(self);
    i := i - 1;
    if i > -1 then
    begin
      Result := FParent.Items.GetNode(i);
    end else
    begin
      Result := nil;
    end;
  end else
  begin
    Result := nil;
  end;
end;

function TNode.HasAsParent(Node: TNode): Boolean;
begin
  if Node <> nil then
  begin
    if Parent = nil then
    begin
      Result := False;
    end else
    if Parent = Node then
    begin
      Result := True
    end else
    begin
      Result := Parent.HasAsParent(Node);
    end;
  end else
  begin
    Result := True;
  end;
end;


procedure TNode.Delete;
var i: Integer;
begin
  if Parent <> nil then
  begin
    i := Parent.FNodes.IndexOf(self);
    Parent.FNodes.FItems[i] := nil;
    Parent.FNodes.DeleteChild(i); // Parent.FNodes.FItems.Delete(i); ??
  end;
  Free;
end;

procedure TNode.AlphaSort;
begin
  FNodes.AlphaSort;
end;

procedure TNode.AlphaSortRek;
begin
  FNodes.AlphaSortRek;
end;

procedure TNode.LoadStructureFromStream(Stream: TStream);
var List: TStringList;
    Node: TNode;
    Level, i: Integer;
    s: string;
begin
  List := TStringList.Create;
  FNodes.Clear;
  try
    List.Capacity := 1;
    List.LoadFromStream(Stream);
    Node := self;
    s := List[0];
    Level := 0;
    GetNameLevelFromString(s, Level);
    self.FText := s;
    for i := 1 to List.Count - 1 do
    begin
      s := List[i];
      GetNameLevelFromString(s, Level);
      if Node.Level = Level then
      begin
        Node := Node.Parent.Items.AddChild(s);
      end else
      if Node.Level = (Level - 1) then
      begin
        Node := Node.Items.AddChild(s)
      end else
      if Node.Level > Level then
      begin
        Node := Node.Parent;
        while Node.Level > Level do
        begin
          Node := Node.Parent;
        end;
        Node := Node.Parent.Items.AddChild(s);
      end;
    end;
  finally
    List.Free;
  end;
end;

procedure TNode.SaveStructureToStream(Stream: TStream);
begin
  ExportStructureToStream(self, self.Level, Stream);
end;

procedure TNode.MoveTo(Destination: TNode);
var i: Integer;
begin
  {nur verschieben, wenn Ziel nicht Unterknoten des aktuellen Knotens ist}
  if not Destination.HasAsParent(self) and (Destination <> self) then
  begin
    {Knoten aus der Parent-Liste löschen}
    if Parent <> nil then
    begin
      i := Parent.FNodes.IndexOf(self);
      Parent.FNodes.FItems[i] := nil;
      Parent.FNodes.FItems.Delete(i);
    end;
    {Knoten in die Liste des Zielknotens einfügen}
    if Destination <> nil then
    begin
      Destination.Items[Destination.Items.Count] := self;
      FParent := Destination;
    end;
  end;
end;

function TNode.GetPath: string;
var Path: string;
begin
  Path := '';
  while self.Level > 0 {Parent <> nil} do
  begin
    Insert(self.Text + '/', Path, 1);
    self := self.Parent;
  end;
  Result := Path;
end;

end.
