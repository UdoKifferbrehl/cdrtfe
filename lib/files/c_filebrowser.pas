{ c_filebrowser.pas: Komponente zur Darstellung einer Explorer-Ansicht

  Copyright (c) 2009-2015 Oliver Valencia

  letzte Änderung  29.11.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  c_filebrowser.pas implementiert eine Komponente auf Basis einer TFrames, mit
  der eine explorerartigen Dateiansicht dargestellt werden kann.

  Verwendung:   Browser := TFrameFileBrowser.Create(Self);
                Browser.Parent := Panel1;
                [weitere Einstellungen setzen]
                Browser.Init;
                Browser.Show;


  TFrameFileBrowser

    Properties   x

    Methoden     Create
                 Init
                 UpdateTranslation

}

unit c_filebrowser;

{$I directives.inc}

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
     Dialogs, StdCtrls, ExtCtrls, CommCtrl, ComCtrls, ShlObj, ShellApi,
     {$IFDEF UseVirtualShellTools}
     VirtualExplorerTree, VirtualTrees
     {$ELSE}
     ShellCtrls
     {$ENDIF};

type
  TFFBSelectedEvent = procedure(Source: TObject) of object;

  TFrameFileBrowser = class(TFrame)
    Label1: TLabel;
    Panel1: TPanel;
    PanelFolder: TPanel;
    Splitter1: TSplitter;
    PanelFiles: TPanel;
  private
    { Private-Deklarationen }
    FBShellTreeView : {$IFDEF UseVirtualShellTools}
                      TVirtualExplorerTreeView
                      {$ELSE}
                      TShellTreeView
                      {$ENDIF};
    FBShellListView : {$IFDEF UseVirtualShellTools}
                      TVirtualExplorerListView
                      {$ELSE}
                      TShellListView
                      {$ENDIF};
    FLabelCaption: string;
    FColCaptionName: string;
    FColCaptionSize: string;
    FColCaptionType: string;
    FColCaptionModified: string;
    FPath: string;
    FTreeViewWidth: Integer;
    FFFBSelected: TFFBSelectedEvent;
    function GetTreeViewFocused: Boolean;
    function GetListViewFocused: Boolean;
    procedure FFBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    {$IFDEF UseVirtualShellTools}
    procedure FFBDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure FFBTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FFBStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure FFBEndDrag(Sender: TObject; Target: TObject; x: Integer; y: Integer);
    {$ELSE}
    procedure FFBTVChange(Sender: TObject; Node: TTreeNode);
    {$ENDIF}
    procedure SetPath(const NewPath: string);
  public
    { Public-Deklarationen }
    procedure Init;
    procedure UpdateTranslation;
    procedure TreeViewSetFocus;
    procedure ListViewSetFocus;
    procedure SetTreeViewStyle;
    procedure SetTreeViewItemHeight(const Height: Integer);
    property TreeViewHasFocus: Boolean read GetTreeViewFocused;
    property ListViewHasFocus: Boolean read GetListViewFocused;
    property LabelCaption: string write FLabelCaption;
    property ColCaptionName: string write FColCaptionName;
    property ColCaptionSize: string write FColCaptionSize;
    property ColCaptionType: string write FColCaptionType;
    property ColCaptionModified: string write FColCaptionModified;
    property Path: string read FPath write SetPath;
    property TreeViewWidth: Integer write FTreeViewWidth;
    property OnFFBSelected: TFFBSelectedEvent read FFFBSelected write FFFBSelected;
  end;

implementation

{$R *.dfm}

uses f_window;

{$IFDEF UseVirtualShellTools}
{ cdrtfe läßt für das gesamte Fenster Ole-Drag-Drop-Operationen aus dem Explorer
  zu. Die VirtualShellTools nutzen ebenfalls Ole-Drag-Drop. Allerdings sollen
  als Ziele nur die Tree- und Listviews zugelassen werden. Daher muß für die
  Dauer der Operation das gesamte Fenster als Ziel gesperrt werden. Die zu-
  gelassenen Ziele sind über DropFileTargets zugänglich.                       }

procedure TFrameFileBrowser.FFBDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;
end;

procedure TFrameFileBrowser.FFBStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  DragAcceptFiles(Application.MainForm.Handle, False);
end;

procedure TFrameFileBrowser.FFBEndDrag(Sender: TObject; Target: TObject; x: Integer; y: Integer);
begin
  DragAcceptFiles(Application.MainForm.Handle, True);
end;
{$ENDIF}

procedure TFrameFileBrowser.FFBKeyDown(Sender: TObject; var Key: Word;
                                       Shift: TShiftState);
begin
  if ((ssAlt in Shift) and (Key = VK_INSERT)) or
     (Key = VK_F11) then
  begin
    if Assigned(FFFBSelected) then FFFBSelected(Sender);
  end;
end;

{$IFDEF UseVirtualShellTools}
procedure TFrameFileBrowser.FFBTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
{$ELSE}
procedure TFrameFileBrowser.FFBTVChange(Sender: TObject; Node: TTreeNode);
{$ENDIF}
begin
  {$IFDEF UseVirtualShellTools}
  FPath := FBShellTreeView.SelectedPath;
  {$ELSE}
  FPath := FBShellTreeView.Path;
  {$ENDIF}
end;

procedure TFrameFileBrowser.SetPath(const NewPath: string);
var DefaultPath  : string;
    {$IFDEF UseVirtualShellTools}
    PIDL         : PItemIDList;
    {$ELSE}
    CurrentFolder: TTreeNode;
    {$ENDIF}
begin
  if DirectoryExists(NewPath) then
  begin
    FPath := NewPath;
    {$IFDEF UseVirtualShellTools}
    FBShellTreeView.BrowseTo(NewPath, False, True, True, False);
    {$ELSE}
    FBShellTreeView.Path := NewPath;
    CurrentFolder := FBShellTreeView.Selected;
    FBShellTreeView.Selected.Parent.Selected := True;
    CurrentFolder.Selected := True;
    {$ENDIF}
  end else
  begin
    {Defaultpath ist c:\, wenn nicht vorhanden, auf aktuelles Laufwerk setzen}
    DefaultPath := 'c:\';
    if not DirectoryExists(DefaultPath) then
      DefaultPath := ExtractFileDrive(Application.ExeName) + '\';    
    {Arbeitsplatz öffnen}
    {$IFDEF UseVirtualShellTools}
    SHGetSpecialFolderLocation(Self.Handle, CSIDL_DRIVES, PIDL);
    FBShellTreeView.BrowseToByPIDL(PIDL, True, True, True, False);
    //FBShellTreeView.BrowseTo(DefaultPath, False, True, True, False);
    {$ELSE}
    FBShellTreeView.Path := DefaultPath;
    //FBShellTreeView.Selected.Expand(False);
    FBShellTreeView.Selected.Parent.Selected := True;
    {$ENDIF}
  end;
end;

function TFrameFileBrowser.GetTreeViewFocused: Boolean;
begin
  Result := FBShellTreeView.Focused;
end;

function TFrameFileBrowser.GetListViewFocused: Boolean;
begin
  Result := FBShellListView.Focused;
end;

procedure TFrameFileBrowser.TreeViewSetFocus;
begin
  FBShellTreeView.SetFocus
end;

procedure TFrameFileBrowser.ListViewSetFocus;
begin
  FBShellListView.SetFocus
end;

procedure TFrameFileBrowser.UpdateTranslation;
begin
  {Spaltennamen setzen}
  {$IFDEF UseVirtualShellTools}
    // für VirtualExplorerListView nicht notwendig
  {$ELSE}
  if (FColCaptionName <> '') and (FBShellListView.Columns.Count > 0) then
    FBShellListView.Column[0].Caption := FColCaptionName;
  if (FColCaptionSize <> '') and (FBShellListView.Columns.Count > 2) then
    FBShellListView.Column[2].Caption := FColCaptionSize;
  if (FColCaptionType <> '') and (FBShellListView.Columns.Count > 1) then
    FBShellListView.Column[1].Caption := FColCaptionType;
  if (FColCaptionModified <> '') and (FBShellListView.Columns.Count > 3)  then
    FBShellListView.Column[3].Caption := FColCaptionModified;
  {$ENDIF}
end;

procedure TFrameFileBrowser.Init;
var NewTop: Integer;
begin
  Self.TabStop := False;
  Self.Color := clBtnFace;
  Self.Align := alClient;
  Label1.Caption := FLabelCaption;
  Label1.Font.Style := [fsBold];

  NewTop := ScaleByDPI(Panel1.Top);
  Panel1.Height := Panel1.Height - (NewTop - Panel1.Top);
  Panel1.Top := NewTop;

  {FolderTreeView}
  FBShellTreeView := {$IFDEF UseVirtualShellTools}
                     TVirtualExplorerTreeView.Create(Self);
                     {$ELSE}
                     TShellTreeView.Create(Self);
                     {$ENDIF}

  with FBShellTreeView do
  begin
    Parent := PanelFolder;
    Align := alClient;
    Anchors := [akLeft, akTop, akRight, akBottom];
    DragMode := dmAutomatic;
    OnKeyDown := FFBKeyDown;
    OnChange := FFBTVChange;
    {$IFDEF UseVirtualShellTools}
    RootFolder := rfDesktop;
    Active := True;
    TreeOptions.VETShellOptions := [toDragDrop, toContextMenus, toRightAlignSizeColumn];
    OnDragOver := FFBDragOver;
    OnStartDrag := FFBStartDrag;
    OnEndDrag := FFBEndDrag;
    {$ELSE}
    HideSelection := False;
    {$ENDIF}
  end;

  {FileListView}
  FBShellListView := {$IFDEF UseVirtualShellTools}
                     TVirtualExplorerListView.Create(Self);
                     {$ELSE}
                     TShellListView.Create(Self);
                     {$ENDIF}

  with FBShellListView do
  begin
    Parent := PanelFiles;
    Align := alCLient;
    DragMode := dmAutomatic;
    OnKeyDown := FFBKeyDown;
    {$IFDEF UseVirtualShellTools}
    Active := True;
    TreeOptions.VETShellOptions := [toDragDrop, toContextMenus, toRightAlignSizeColumn];
    OnDragOver := FFBDragOver;
    OnStartDrag := FFBStartDrag;
    OnEndDrag := FFBEndDrag;
    {$ELSE}
    ViewStyle := vsReport;
    Multiselect := True;
    {$ENDIF}
  end;

  {$IFDEF UseVirtualShellTools}
  FBShellTreeView.VirtualExplorerListview := FBShellListView;
  FBShellListView.VirtualExplorerTreeview := FBShellTreeView;
  {$ELSE}
  FBShellTreeView.ShellListView := FBShellListView;
  FBShellListView.ShellTreeView := FBShellTreeView;
  {$ENDIF}

  {Anfangsverzeichnis}
  SetPath(FPath);

  if FTreeViewWidth > 0 then PanelFolder.Width := FTreeViewWidth;

  UpdateTranslation;
end;

procedure TFrameFileBrowser.SetTreeViewStyle;
begin
  {$IFDEF UseVirtualShellTools}
  {$ELSE}
  if f_window.SetTreeViewStyle(FBShellTreeView) then
    FBShellTreeView.ShowLines := False;
  {$ENDIF}
end;

procedure TFrameFileBrowser.SetTreeViewItemHeight(const Height: Integer);
begin
  {$IFDEF UseVirtualShellTools}
  {$ELSE}
  FBShellTreeView.Perform(TVM_SETITEMHEIGHT, Height, 0);
  {$ENDIF}
end;

end.
