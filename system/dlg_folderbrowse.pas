{ dlg_folderbrowse.pas: Auswahldialog f�r einen oder mehrere Ordner

  Copyright (c) 2007 Oliver Valencia

  letzte �nderung  12.08.2007

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  dlg_folderbrowse.pas implementiert einen Auswahldialog f�r Ordner:
    * Anzeige der verf�gbaren Ordner (auch Windows-Spezial-Ordner)
    * Auswahl der anzuzeigenden Ordner und des Startordners
    * M�glichkeit einen oder auch mehrere Ordner auszuw�hlen


  TFolderBrowser

    Properties   Caption
                 Title
                 ColCaption
                 Height
                 Left
                 Top
                 Width
                 Position
                 Multiselect
                 Root
                 SpecialRoot
                 SpecialStartIn
                 InitialDir
                 Path
                 PathList
                 Count

    Methoden     Create(AOwner: TComponent)
                 Execute: Boolean

}

unit dlg_folderbrowse;

{$I directives.inc}

interface

uses Classes, Windows, Forms, StdCtrls, Controls, FileCtrl, SysUtils, ComCtrls,
     SsBase, StShlCtl;

type TFolderBrowser = class(TComponent)
       {Dialog und dessen Komponenten}
       FBDialog        : TForm;
       FBShellTreeView : TStShellTreeView;
       FBListView      : TListView;
       FBLabelTitle    : TLabel;
       FBButtonOk      : TButton;
       FBButtonCancel  : TButton;
     private
       FPath           : string;
       FPathList       : TStringList;
       {Dialog-Form}
       FHeight         : Integer;
       FLeft           : Integer;
       FTop            : Integer;
       FWidth          : Integer;
       FPosition       : TPosition;
       FCaption        : string;
       FTitle          : string;
       FMultiselect    : Boolean;
       FColCaption     : string;
       {ShellTreeView}
       FRoot           : string;
       FSpecialRoot    : TStSpecialRootFolder;
       FSpecialStartIn : TStSpecialRootFolder;
       FInitialDir     : string;
       {Buttons}
       FButtonCapOk    : string;
       FButtonCapCancel: string;
       function GetCount: Integer;
       procedure SetInitialDir(const Value: string);
       procedure STVClick(Sender: TObject);
       procedure STVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
       procedure LVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
       procedure InsertFolder(const Path: string);
       procedure DeleteFolder(const Index: Integer);
     public
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
       function Execute: Boolean; virtual;
       {Dialog-Properties}
       property Caption       : string read FCaption write FCaption;
       property Title         : string read FTitle write FTitle;
       property ColCaption    : string read FColCaption write FColCaption;
       property Height        : Integer read FHeight write FHeight;
       property Left          : Integer read FLeft write FLeft;
       property Top           : Integer read FTop write FTop;
       property Width         : Integer read FWidth write FWidth;
       property Position      : TPosition read FPosition write FPosition;
       property Multiselect   : Boolean read FMultiselect write FMultiselect;
       {ShellTreeview-Properties}
       property Root          : string write FRoot;
       property SpecialRoot   : TStSpecialRootFolder write FSpecialRoot;
       property SpecialStartIn: TStSpecialRootFolder write FSpecialStartIn;
       property InitialDir    : string write SetInitialDir;
       {Path}
       property Path          : string read FPath;
       property PathList      : TStringList read FPathList;
       property Count         : Integer read GetCount;
     end;

implementation

{ TFolderBrowser ------------------------------------------------------------- }

{ TFolderBrowser - private }

{ GetCount ---------------------------------------------------------------------

  gibt die Anzahl der in Pfadlister vorhanden Ordner zur�ck.                   }

function TFolderBrowser.GetCount: Integer;
begin
  Result := FPathList.Count;
end;

{ SetInitialDir ----------------------------------------------------------------

  setzt das Startverzeichnis.                                                  }

procedure TFolderBrowser.SetInitialDir(const Value: string);
begin
  if DirectoryExists(Value) then FInitialDir := Value;
end;

{ InsertFolder -----------------------------------------------------------------

  f�gt der ausgw�hlten Ordner in die Liste ein, sofern er nicht schon vorhanden
  ist.                                                                         }

procedure TFolderBrowser.InsertFolder(const Path: string);
var NewItem: TListItem;
    Ok     : Boolean;
    i      : Integer;
begin
  if FMultiselect then
  begin
    Ok := True;
    for i := 0 to FPathList.Count - 1 do Ok := Ok and not (FPathList[i] = Path);
    if Ok then
    begin
      FPathList.Add(Path);
      NewItem := FBListView.Items.Add;
      NewItem.Caption := Path;
    end;
  end;
end;

{ DeleteFolder -----------------------------------------------------------------

  entfernt einen Ordner aus der Pfadliste.                                     }

procedure TFolderBrowser.DeleteFolder(const Index: Integer);
begin
  if FPathList.Count > 0 then
  begin
    if Index < FPathList.Count then FPathList.Delete(Index);
    if Index < FBListView.Items.Count then
    begin
      FBListView.Items.Delete(Index);
      if FBListView.Items.Count > 0 then
        if Index < FBListView.Items.Count then
          FBListView.ItemIndex := Index
        else
          FBListView.ItemIndex := Index - 1; 
    end;
  end;
end;

{ Ereignisbehandlungsroutinen ------------------------------------------------ }

{ ShellTreeView - OnClick ---------------------------------------------------- }

procedure TFolderBrowser.STVClick(Sender: TObject);
begin
  //
end;

{ ShellTreeView - OnKeyDown ----------------------------------------------------

  Ordner werden mit Alt-Insert in dies Liste �bertragen.                       }

procedure TFolderBrowser.STVKeyDown(Sender: TObject; var Key: Word;
                                    Shift: TShiftState);
begin
  if  ssAlt in Shift then
  begin
    case Key of
      VK_INSERT: InsertFolder(FBShellTreeView.SelectedFolder.Path);
    end;
  end;
end;

{ Listview - OnKeyDown ---------------------------------------------------------

  Ordner werden mit Del wieder entfernt.                                       }

procedure TFolderBrowser.LVKeyDown(Sender: TObject; var Key: Word;
                                   Shift: TShiftState);
begin
  case Key of
    VK_Delete: DeleteFolder((Sender as TListView).ItemIndex);
  end;
end;

{ TFolderBrowser - public }

constructor TFolderBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHeight          := 306;
  FWidth           := 315;
  FPosition        := poScreenCenter;
  FRoot            := '';
  FSpecialRoot     := sfDesktop;
  FSpecialStartIn  := sfDrives;
  FButtonCapOk     := 'Ok';
  FButtonCapCancel := 'Abbrechen';
  FPath            := '';
  FMultiselect     := False;
  FColCaption      := 'ausgew�hlte Ordner';
  FPathList        := TStringList.Create;
end;

destructor TFolderBrowser.Destroy;
begin
  PathList.Free;
  inherited Destroy;
end;

{ Execute ----------------------------------------------------------------------

  �ffnet den eigentlichen Auswahldialog.                                       }

function TFolderBrowser.Execute: Boolean;
var NewTop   : Integer;
    NewBottom: Integer;
    LVHeight : Integer;
begin
  {Dialog erstellen}
  FBDialog              := TForm.Create(Self);
  FBDialog.ClientHeight := FHeight;
  FBDialog.Left         := FLeft;
  FBDialog.Top          := FTop;
  FBDialog.ClientWidth  := FWidth;
  FBDialog.Position     := FPosition;
  FBDialog.BorderStyle  := bsDialog;
  FBDialog.ModalResult  := mrNone;
  FBDialog.KeyPreview   := True;
  FBDialog.Caption      := FCaption;
  {Ereignisse}
  //FBDialog.OnKeyDown    := OpenDirDlgKeyDown;

  {Label}
  NewTop := 8;
  FBLabelTitle := TLabel.Create(Self);
  with FBLabelTitle do
  begin
    SetBounds(8, NewTop, FWidth - 16, 13);
    Font.Size  := Font.Size + 1;
    Parent     := FBDialog;
    Autosize   := True;
    Caption    := FTitle;
  end;
  NewTop := NewTop + 8 + FBLabelTitle.Height;

  {Cancel-Button}
  FBButtonCancel := TButton.Create(Self);
  with FBButtonCancel do
  begin
    SetBounds(FWidth - 8 - 75, FHeight - 30, 75, 25);
    Parent      := FBDialog;
    Caption     := FButtonCapCancel;
    ModalResult := mrAbort;
  end;

  {OK-Button}
  FBButtonOk := TButton.Create(Self);
  with FBButtonOk do
  begin
    SetBounds(FWidth - 8 - 2*75 - 5, FHeight - 30, 75, 25);
    Parent      := FBDialog;
    Caption     := FButtonCapOk;
    ModalResult := mrOk;
  end;
  NewBottom := FBButtonOk.Top - 8;

  {ListView}
  if FMultiselect then
  begin
    LVHeight := 120;
    FBListView := TListView.Create(Self);
    with FBListView do
    begin
      SetBounds(8, NewBottom - LVHeight, FWidth - 16, LVHeight);
      Parent             := FBDialog;
      ViewStyle          := vsReport;
      CheckBoxes         := False;
      OnKeyDown          := LVKeyDown;
      TabStop            := True;
      Columns.Add;
      Columns[0].Caption := FColCaption;
      Columns[0].Width   := FBListView.Width;
    end;
    NewBottom := FBListView.Top - 8;
  end;

  {ShellTreeView}
  FBShellTreeView := TStShellTreeView.Create(Self);
  with FBShellTreeView do
  begin
    SetBounds(8, NewTop, FWidth - 16, FHeight - NewTop - (FHeight - NewBottom));
    Parent := FBDialog;
    SpecialRootFolder := FSpecialRoot;
    if DirectoryExists(FRoot) then
    begin
      RootFolder := FRoot;
      SpecialRootFolder := sfNone;
    end;
    if Length(FInitialDir) > 0 then
    begin
      FBShellTreeView.StartInFolder := FInitialDir;
    end else
    begin
      FBShellTreeView.SpecialStartInFolder := FSpecialStartIn;
    end;
    HideSelection    := False;
    OnClick          := STVClick;
    OnKeyDown        := STVKeyDown;
  end;

  {TabOrder}
  FBShellTreeView.TabOrder := 0;
  if FMultiselect then FBListView.TabOrder      := 1;
  FBButtonOk.TabOrder      := 2;
  FBButtonCancel.TabOrder  := 3;

  Result := FBDialog.ShowModal = mrOK;
  if FBDialog.ModalResult = mrOK then
  begin
    FPath := FBShellTreeView.SelectedFolder.Path;
    if FPathList.Count = 0 then InsertFolder(FPath);                           
  end;
end;

end.