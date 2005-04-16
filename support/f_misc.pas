{ f_misc.pas: unterstützende Funktionen (sonstiges)

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  13.04.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_misc.pas stellt Hilfs-Funktionen zur Verfügung:
    * allgemeine Funktionen für List- und Tree-Views
    * Log-Funktionen
    * Wave-File-Fuktionen
    * Funktionen für String-Listen
    * Funktionen zur Zeitmessung


  exportierte Funktionen/Prozeduren:

    AddLog(const Value: string; const Show: Byte)
    AddLogAddStringList(List: TStringList)
    ExportControls
    GetPathFromNode(Root: TTreeNode): string
    GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode
    GetSection(Source, Target: TSTringList; const StartTag, EndTag: string): Boolean
    GetWaveLength(const Name: string): Extended
    ListViewSelectAll(ListView: TListView)
    SelectRootIfNoneSelected(Tree: TTreeView)
    WaveIsValid(const Name: string): Boolean


  TTimeCount: Objekt zur Zeitmessung

    Properties   TimeAsInt
                 TimeAsString

    Methodes     Create

}

unit f_misc;

interface

uses Classes, Forms, Controls, ComCtrls, SysUtils, Windows;

function GetPathFromNode(Root: TTreeNode): string;
function GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode;
function GetWaveLength(const Name: string): Extended;
function GetSection(Source, Target: TSTringList; const StartTag, EndTag: string): Boolean;
function WaveIsValid(const Name: string): Boolean;
procedure AddLog(const Value: string; const Show: Byte);
procedure AddLogAddStringList(List: TStringList);
procedure ExportControls;
procedure ListViewSelectAll(ListView: TListView);
procedure SelectRootIfNoneSelected(Tree: TTreeView);

type TTimeCount = class(TObject)
     private
       FStart: Longint;
       FStop: Longint;
       function GetTimeAsInt: Longint;
       function GetTimeAsString: string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure StartTimeCount;
       procedure StopTimeCount;
       procedure Reset;
       property TimeAsInt: Longint read GetTimeAsInt;
       property TimeAsString: string read GetTimeAsString;
     end;

implementation

uses f_filesystem, w32waves;

{ 'statische' Variablen }
var AddLogFirstRun: Boolean;          // Flag für AddLog
    
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

{ AddLog -----------------------------------------------------------------------

  AddLog fügt eine Zeile an das Log-File an. Falls die Datei log.txt noch nicht
  existiert, wird sie angelegt. Wenn Show=0 ist, wird der Log-Eintrag nicht als
  Message-Box angezeigt.                                                       }

procedure AddLog(const Value: string; const Show: Byte);
var LogName: string;
    Log: TextFile;
begin
  LogName := StartUpDir + '\log.txt';
  if AddLogFirstRun then
  begin
    if not FileExists(LogName) then
    begin
      AssignFile(Log, LogName);
      Rewrite(Log);
    end else
    begin
      AssignFile(log, LogName);
      Append(Log);
    end;
    WriteLn(Log, '------------------------------------------------------------');
    WriteLn(Log, 'cdrtfe Log-File');
    WriteLn(Log, '');
    Close(Log);
    AddLogFirstRun := False;
  end;
  AssignFile(Log, LogName);
  Append(Log);
  WriteLn(Log, Value);
  Close(Log);
  if Show <> 0 then
  begin
    Application.MessageBox(Pchar(Value), 'Debug-Info',
                           MB_OK or MB_ICONEXCLAMATION);
  end;
end;

{ AddLogAddStringList ----------------------------------------------------------

  AddLogAddStringList schreibt den Inhalt der String-Liste ins Log-File.       }

procedure AddLogAddStringList(List: TStringList);
var i: Integer;
    LogName: string;
    Log: TextFile;
begin
  if AddLogFirstRun then
  begin
    LogName := StartUpDir + '\log.txt';
    if not FileExists(LogName) then
    begin
      AssignFile(Log, LogName);
      Rewrite(Log);
    end else
    begin
      AssignFile(log, LogName);
      Append(Log);
    end;
    WriteLn(Log, '------------------------------------------------------------');
    WriteLn(Log, 'cdrtfe Log-File');
    WriteLn(Log, '');
    Close(Log);
    AddLogFirstRun := False;
  end;
  AssignFile(Log, LogName);
  Append(Log);
  for i := 0 to List.Count - 1 do
  begin
    WriteLn(Log, List[i]);
  end;
  Close(Log);
end;

{ WaveIsValid ------------------------------------------------------------------

  WaveIsValid  prüft, ob die angegebene Datei eine gültige Wave-Datei ist.     }

function WaveIsValid(const Name: string): Boolean;
var PWavInfo: PWaveInformation;
begin
  New(PWavInfo);
  GetWaveInformationFromFile(Name, PWavInfo);
  {Bedingungen: PCM-Format (WaveFormat = 1),
                stereo     (Chennels = 2),
                44.1 kHz   (SampleRate = 44100),
                16 Bit     (BitPerSample = 16)}
  with PWavInfo^ do
  begin
    if (WaveFormat = 1) and (Channels = 2) and (SampleRate = 44100) and
       (BitsPerSample = 16) and ValidWave then
    begin
      Result := True;
    end else
    begin
      Result := False;
    end;
  end;
  Dispose(PWavInfo);
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

{ GetWaveLength ----------------------------------------------------------------

  GetWaveLength bestimmt die Länge einer Wave-Datei in Sekunden.               }

function GetWaveLength(const Name: string): Extended;
var PWavInfo: PWaveInformation;
    TotalTime: Extended; // Time in seconds
begin
  TotalTime := 0;

  New(PWavInfo);
  GetWaveInformationFromFile(Name, PWavInfo);
  {Bedingungen: PCM-Format (WaveFormat = 1),
                stereo     (Chennels = 2),
                44.1 kHz   (SampleRate = 44100),
                16 Bit     (BitPerSample = 16)}
  with PWavInfo^ do
  begin
    if (WaveFormat = 1) and (Channels = 2) and (SampleRate = 44100) and
       (BitsPerSample = 16) and ValidWave then
    begin
      TotalTime := TotalTime + Length;
    end else
    begin
      TotalTime := 0;
    end;
  end;
  Dispose(PWavInfo);
  Result := TotalTime;
end;

{ GetSection -------------------------------------------------------------------

  GetSection liefert aus der String-Liste Source den Teil, der durch die Zeilen
  StartTag und EndTag eingerahmt ist, wobei die Begrenzung nicht Teil des Ergeb-
  nisses sind. Sollte EndTag nicht gefunden werden, so wird die Liste ab
  StartTag zurückgegeben. Das Ergebnis wird in die Liste Target geschrieben.   }

function GetSection(Source, Target: TSTringList;
                     const StartTag, EndTag: string): Boolean;
var i, p: Integer;
begin
  {Liste von Source nach Target kopieren}
  Target.Assign(Source);
  {Anfang der Sektion finden}
  p := Target.IndexOf(StartTag);
  Result := p > -1;
  if Result then
  begin
    for i := p downto 0 do
    begin
      Target.Delete(i);
    end;
    p := Target.IndexOf(EndTag);
    if p > -1 then
    begin
      for i := Target.Count - 1 downto p do
      begin
        Target.Delete(i);
      end;
    end;
  end;
end;

{ ExportControls ---------------------------------------------------------------

  ExportControls schreibt die Position und Größe alle Controls in eine Datei.  }

procedure ExportControls;
var i: Integer;
    List: TStringList;

  procedure ExportControlsRek(Comp: TComponent);
  var i: Integer;
  begin
    if Comp.Name <> '' then
    begin
      List.Add(Comp.Name +
               '.Top := ' + IntToStr((Comp as TControl).Top) + ';');
      List.Add(Comp.Name +
               '.Left := ' + IntToStr((Comp as TControl).Left) + ';');
      List.Add(Comp.Name +
               '.Width := ' + IntToStr((Comp as TControl).Width) + ';');
      List.Add(Comp.Name +
               '.Height := ' + IntToStr((Comp as TControl).Height) + ';');
    end;
    if Comp.ComponentCount > 0 then
    begin
      for i := 0 to Comp.ComponentCount - 1 do
      begin
        ExportControlsRek(Comp.Components[i]);
      end;
    end;
  end;

begin
  List := TStringList.Create;
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    if Application.Components[i] is TForm then
    begin
      ExportControlsRek(Application.Components[i]);
      List.Add('');
    end;
  end;
  List.SaveToFile(StartUpDir + '\controls.txt');
  List.Free;
end;

{ TTimeCounter --------------------------------------------------------------- }

{ TTimeCounter - private }

function TTimeCount.GetTimeAsInt: Longint;
begin
  Result := FStop - FStart;
end;

function TTimeCount.GetTimeAsString: string;
begin
  Result := Format('%f Sekunden', [(FStop - FStart) / 1000]);
end;

{ TTimeCounter - public }

constructor TTimeCount.Create;
begin
  inherited Create;
  FStart := 0;
  FStop := 0;
end;

destructor TTimeCount.Destroy;
begin
  inherited Destroy;
end;

procedure TTimeCount.StartTimeCount;
begin
  FStart := GetTickCount;
end;

procedure TTimeCount.StopTimeCount;
begin
  FStop := GetTickCount;
end;

procedure TTimeCount.Reset;
begin
  FStart := 0;
  FStop := 0;
end;


initialization
  AddLogFirstRun := True;

end.
