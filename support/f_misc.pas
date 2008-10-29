{ f_misc.pas: unterstützende Funktionen (sonstiges)

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  29.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_misc.pas stellt Hilfs-Funktionen zur Verfügung:
    * allgemeine Funktionen für List- und Tree-Views
    * Log-Funktionen
    * Wave-File-Fuktionen
    * Funktionen für String-Listen
    * Funktionen zur Zeitmessung
    * Umgang mit Komponenten
    * Standard-Dialog
    * Eigenschaften von Formularen ändern (Stay-on-top)
    * Startparameter


  exportierte Funktionen/Prozeduren:

    AddCRStringToList(s: string; List: TStringList)
    CheckCommanLineSwitch(const Switch: string): Boolean
    ExportControls
    ExportFontList
    GetCompProp(Comp: TComponent; Name: string): string
    GetPathFromNode(Root: TTreeNode): string
    GetNameByValue(List: TStringList; const Value: string): string
    GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode
    GetSection(Source, Target: TSTringList; const StartTag, EndTag: string): Boolean
    GetWaveLength(const Name: string): Extended
    ItemIsFolder(Item: TListItem): Boolean
    ListViewSelectAll(ListView: TListView)
    PropertyExists(Comp: TComponent; Name: string): Boolean
    SelectRootIfNoneSelected(Tree: TTreeView)
    SetCompProp(Comp: TComponent; const Name, Value: string)
    SetFont(Form: TForm)
    SortListByValue(List: TStringList)
    ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer
    WindowStayOnTop(Handle: THandle; Value: Boolean)
    WaveIsValid(const Name: string): Boolean


  TTimeCount: Objekt zur Zeitmessung

    Properties   TimeAsInt
                 TimeAsString

    Methodes     Create

}

unit f_misc;

{$I directives.inc}

interface

uses Classes, Forms, Controls, ComCtrls, StdCtrls, ExtCtrls, Buttons, SysUtils,
     Windows, TypInfo;

function CheckCommandLineSwitch(const Switch: string): Boolean;
function GetPathFromNode(Root: TTreeNode): string;
function GetNameByValue(List: TStringList; const Value: string): string;
function GetNodeFromPath(Root: TTreeNode; Path: string): TTreeNode;
function GetWaveLength(const Name: string): Extended;
function GetSection(Source, Target: TSTringList; const StartTag, EndTag: string): Boolean;
function GetCompProp(Comp: TComponent; Name: string): string;
function ItemIsFolder(Item: TListItem): Boolean;
function PropertyExists(Comp: TComponent; Name: string): Boolean;
function ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer;
function WaveIsValid(const Name: string): Boolean;
procedure AddCRStringToList(s: string; List: TStrings);
procedure ExportControls;
procedure ExportFontList;
procedure ListViewSelectAll(ListView: TListView);
procedure SelectRootIfNoneSelected(Tree: TTreeView);
procedure SetCompProp(Comp: TComponent; const Name, Value: string);
procedure SetFont(Form: TForm);
procedure SortListByValue(List: TStringList);
procedure WindowStayOnTop(Handle: THandle; Value: Boolean);

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

const MB_cdrtfe1 = MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION;
      MB_cdrtfe2 = MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_wininfo, f_strings, w32waves, constant;

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

{ ItemIsFolder -----------------------------------------------------------------

  ergibt True, wenn Item im ListView für einen Dateiordner steht.              }

function ItemIsFolder(Item: TListItem): Boolean;
begin
  Result := (Item.SubItems[0] = '') and (Item.SubItems[2] = '');
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

{ AddCRStringToList ------------------------------------------------------------

  Fügt einen String, der mehrere durch CR(LF) getrennte Zeilen enthält an die
  Liste an.                                                                    }

procedure AddCRStringToList(s: string; List: TStrings);
var TempList: TStrings;
    i       : Integer;
begin
  TempList := TStringList.Create;
  TempList.Text := s;
  for i := 0 to TempList.Count - 1 do List.Add(TempList[i]);
  TempList.Free;
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
(*
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
*)
  {Anfang der Sektion finden}
  p := Source.IndexOf(StartTag);
  Result := p > -1;
  {Falls Sektion gefunden wurde, kopieren}
  if Result then
  begin
    i := p + 1;
    Target.Capacity := 1;
    while (i < Source.Count) and (Source[i] <> EndTag) do
    begin
      Target.Add(Source[i]);
      Inc(i);
    end;
  end;
end;

{ GetNameByValue ---------------------------------------------------------------

  liefert für eine Liste mit Einträgen der Form Name=Value zu einem gegebenen
  Wert den Namen.                                                              }

function GetNameByValue(List: TStringList; const Value: string): string;
var i         : Integer;
    Temp, Name: string;
    Found     : Boolean;
begin
  Result := '';
  Found := False;
  if List.Count > 0 then
  begin
    i := -1;
    repeat
      Inc(i);
      Name := List.Names[i];
      Temp := List.Values[Name];
      Found := Temp = Value;
    until Found or (i = List.Count - 1);
  end;
  if Found then Result := Name;
end;

{ SetFont ----------------------------------------------------------------------

  SetFont sorgt unter Windows XP dafür, daß eine Schriftart verwendet wird, die
  ClearType (Kantenglättung) unterstützt.                                      }

procedure SetFont(Form: TForm);
begin
  if PlatformWin2kXP and (Win32MinorVersion > 0) then
  begin
    if Screen.Fonts.IndexOf('Microsoft Sans Serif') >= 0 then
      Form.Font.Name := 'Microsoft Sans Serif';
  end;
end;

{ WindowStayOnTop --------------------------------------------------------------

  setzt die Eigenschaft 'Stay-on-top' eines Formulars.                         }

procedure WindowStayOnTop(Handle: THandle; Value: Boolean);
begin
  if Value then
    SetWindowPos(Handle, HWND_TOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE)
  else
    SetWindowPos(Handle, HWND_NOTOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE);
end;

{ ShowMsgDlg -------------------------------------------------------------------

  zeigt einen Dialog an. Verwendet Application.MessageBox.
  
  Flags: MB_ICONSTOP             MB_OK                    MB_cdrtfe1
         MB_ICONQUESTION         MB_OKCANCEL
         MB_ICONWARNING          MB_ABORTRETRYIGNORE
         MB_ICONINFORMATION      MB_YESNOCANCEL
                                 MB_YESNO
                                 MB_RETRYCANCEL
                                 MB_HELP

  Results: ID_OK, ID_CANCEL, ID_ABORT, ID_RETRY, ID_RIGNORE, ID_YES, ID_NO     }

function ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer;
begin
  Result := Application.MessageBox(PChar(Text), PChar(Caption), Flags);
end;

{ CheckCommandLineSwitch -------------------------------------------------------

  True, wenn /Switch als Startparameter übergeben wurde.                       }

function CheckCommandLineSwitch(const Switch: string): Boolean;
var i: Integer;
begin
  i := 1;
  repeat
    Result := LowerCase(Switch) = LowerCase(ParamStr(i));
    Inc(i);
  until Result or (i > ParamCount)
end;

{ SortListByValue --------------------------------------------------------------

  sortiert eine String-Liste nach den Werter.                                  }

procedure SortListByValue(List: TStringList);
var i: Integer;
begin
  for i := 0 to List.Count - 1 do
    List[i] := Format('%-15s', [List.Values[List.Names[i]]]) + '=' + List[i];
  List.Sort;
  for i := 0 to List.Count - 1 do
    List[i] := List.Values[List.Names[i]];
end;

{ Hilfsprozeduren zum Setzen/Lesen der Properties----------------------------- }

{ GetCompProp ------------------------------------------------------------------

  GetCompProp gibt den Wert von Comp.Name zurück, falls Property 'Name' vor-
  handen ist. Ist nur auf String-Properties anwendbar.                         }

function GetCompProp(Comp: TComponent; Name: string): string;
var PropInf: PPropInfo;
begin
  PropInf := GetPropInfo(Comp.ClassInfo, Name);
  if Assigned(PropInf) then
  begin
    Result := GetStrProp(Comp, PropInf);
  end else
  begin
    Result := '';
  end;
end;

{ SetCompProp ------------------------------------------------------------------

  SetCompProp setzt Comp.Name := Value. Nur für Strings.                       }

procedure SetCompProp(Comp: TComponent; const Name, Value: string);
var PropInf: PPropInfo;
begin
  if Value <> '' then
  begin
    PropInf := GetPropInfo(Comp.ClassInfo, Name);
    if Assigned(PropInf) then
    begin
      SetStrProp(Comp, PropInf, Value);
    end;
  end;
end;

{ PropertyExists ---------------------------------------------------------------

  PropertyExist liefert True, wenn Comp.Name existiert, sonst False.           }

function PropertyExists(Comp: TComponent; Name: string): Boolean;
begin
  Result := (Comp.Name <> '') and (GetPropInfo(Comp.ClassInfo, Name) <> nil);
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

{ ExportFontList ---------------------------------------------------------------

  ExportFontList schreibt eine List der verwendeten Schriftarten in eine Datei.}

procedure ExportFontList;
var i: Integer;
    List: TStringList;

  procedure ExportFontsRek(Comp: TComponent);
  var i: Integer;
      s: string;
  begin
    if (Comp.Name <> '') and PropertyExists(Comp, 'Font') then
    begin
      if Comp is TMemo        then s := (Comp as TMemo).Font.Name else
      if Comp is TLabel       then s := (Comp as TLabel).Font.Name else
      if Comp is TForm        then s := (Comp as TForm).Font.Name else
      if Comp is TGroupBox    then s := (Comp as TGroupBox).Font.Name else
      if Comp is TButton      then s := (Comp as TButton).Font.Name else
      if Comp is TRadioButton then s := (Comp as TRadioButton).Font.Name else
      if Comp is TCheckBox    then s := (Comp as TCheckBox).Font.Name else
      if Comp is TComboBox    then s := (Comp as TComboBox).Font.Name else
      if Comp is TEdit        then s := (Comp as TEdit).Font.Name else
      if Comp is TTabSheet    then s := (Comp as TTabSheet).Font.Name else
      if Comp is TPanel       then s := (Comp as TPanel).Font.Name else
      if Comp is TPageControl then s := (Comp as TPageControl).Font.Name else
      if Comp is TTreeView    then s := (Comp as TTreeView).Font.Name else
      if Comp is TListView    then s := (Comp as TListView).Font.Name else
      if Comp is TStatusBar   then s := (Comp as TStatusBar).Font.Name else
      if Comp is TStaticText  then s := (Comp as TStaticText).Font.Name else
      if Comp is TSpeedButton then s := (Comp as TSpeedButton).Font.Name;
      List.Add(s + ' <- ' + Comp.Name);
    end;
    if Comp.ComponentCount > 0 then
    begin
      for i := 0 to Comp.ComponentCount - 1 do
      begin
        ExportFontsRek(Comp.Components[i]);
      end;
    end;
  end;

begin
  List := TStringList.Create;
  for i:= 0 to Application.ComponentCount - 1 do
  begin
    if Application.Components[i] is TForm then
    begin
      ExportFontsRek(Application.Components[i]);
      List.Add('');
    end;
  end;
  List.SaveToFile(StartUpDir + '\fonts.txt');
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

end.
