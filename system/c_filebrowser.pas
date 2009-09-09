{ c_filebrowser.pas: Komponente zur Darstellung einer Explorer-Ansicht

  Copyright (c) 2009 Oliver Valencia

  letzte �nderung  21.06.2009

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

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

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  ShellCtrls;

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
    FBShellTreeView : TShellTreeView;
    FBShellListView : TShellListView;
    FLabelCaption: string;
    FColCaptionName: string;
    FColCaptionSize: string;
    FColCaptionType: string;
    FColCaptionModified: string;
    FTreeViewWidth: Integer;
    FFFBSelected: TFFBSelectedEvent;
    procedure FFBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    { Public-Deklarationen }
    procedure Init;
    procedure UpdateTranslation;
    property LabelCaption: string write FLabelCaption;
    property ColCaptionName: string write FColCaptionName;
    property ColCaptionSize: string write FColCaptionSize;
    property ColCaptionType: string write FColCaptionType;
    property ColCaptionModified: string write FColCaptionModified;
    property TreeViewWidth: Integer write FTreeViewWidth;
    property OnFFBSelected: TFFBSelectedEvent read FFFBSelected write FFFBSelected;
  end;

implementation

{$R *.dfm}

procedure TFrameFileBrowser.FFbKeyDown(Sender: TObject; var Key: Word;
                                       Shift: TShiftState);
begin
  if ((ssAlt in Shift) and (Key = VK_INSERT)) or
     (Key = VK_F11) then
  begin
    if Assigned(FFFBSelected) then FFFBSelected(Sender);
  end;
end;

procedure TFrameFileBrowser.UpdateTranslation;
begin
  {Spaltennamen setzen}
  if FColCaptionName <> '' then
    FBShellListView.Column[0].Caption := FColCaptionName;
  if FColCaptionSize <> '' then
    FBShellListView.Column[2].Caption := FColCaptionSize;
  if FColCaptionType <> '' then
    FBShellListView.Column[1].Caption := FColCaptionType;
  if FColCaptionModified <> '' then
    FBShellListView.Column[3].Caption := FColCaptionModified;
end;

procedure TFrameFileBrowser.Init;
begin
  Self.Color := clBtnFace;
  Self.Align := alClient;
  Label1.Caption := FLabelCaption;
  Label1.Font.Style := [fsBold];

  {FolderTreeView}
  FBShellTreeView := TShellTreeView.Create(Self);
  with FBShellTreeView do
  begin
    Parent := PanelFolder;
    Align := alClient;
    Anchors := [akLeft, akTop, akRight, akBottom];
    HideSelection := False;
    DragMode := dmAutomatic;
    OnKeyDown := FFBKeyDown;
  end;

  {FileListView}
  FBShellListView := TShellListView.Create(Self);
  with FBShellListView do
  begin
    Parent := PanelFiles;
    Align := alCLient;
    ViewStyle := vsReport;
    Multiselect := True;
    DragMode := dmAutomatic;
    OnKeyDown := FFBKeyDown;
  end;

  FBShellTreeView.ShellListView := FBShellListView;
  FBShellListView.ShellTreeView := FBShellTreeView;

  {Arbeitsplatz �ffnen}
  FBShellTreeView.Path := 'c:\';
  //FBShellTreeView.Selected.Expand(False);
  FBShellTreeView.Selected.Parent.Selected := True;

  if FTreeViewWidth > 0 then PanelFolder.Width := FTreeViewWidth;

  UpdateTranslation;
end;

end.