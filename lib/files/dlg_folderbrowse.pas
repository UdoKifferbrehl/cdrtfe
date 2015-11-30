{ dlg_folderbrowse.pas: Auswahldialog für einen oder mehrere Ordner

  Copyright (c) 2007-2015 Oliver Valencia

  letzte Änderung  29.11.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  dlg_folderbrowse.pas implementiert einen Auswahldialog für Ordner:
    * Anzeige der verfügbaren Ordner (auch Windows-Spezial-Ordner)
    * Auswahl der anzuzeigenden Ordner und des Startordners
    * Möglichkeit einen oder auch mehrere Ordner auszuwählen
    * Statt der ShellShock-Komponenten verwendet der Dialog jetzt die Delphi-
      ShellControls oder die VirtualShellTools
    * Die Verwendung der ShellShock-Komponenten setzt die Datei comctl32.dll in
      der Version 5.81 oder höher voraus. Bei niedrigeren Versionen wird der
      Standard-Auswahldialog für einen einzelnen Ordner verwendet.


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
                 InitialDir
                 Path
                 PathList
                 Count
                 OwnerHandle
                 InitOk

    Methoden     Create(AOwner: TComponent)
                 Execute: Boolean

}

unit dlg_folderbrowse;

{$I directives.inc}

interface

uses Classes, Windows, Forms, StdCtrls, Controls, FileCtrl, SysUtils, ComCtrls,
     CommCtrl, ShlObj, ActiveX,
     {$IFDEF UseVirtualShellTools}
     VirtualExplorerTree
     {$ELSE}
     ShellCtrls
     {$ENDIF};

type TFolderBrowser = class(TComponent)
       {Dialog und dessen Komponenten}
       FBDialog        : TForm;
       FBShellTreeView : {$IFDEF UseVirtualShellTools}
                         TVirtualExplorerTreeView
                         {$ELSE}
                         TShellTreeView
                         {$ENDIF};
       FBListView      : TListView;
       FBLabelTitle    : TLabel;
       FBButtonOk      : TButton;
       FBButtonCancel  : TButton;
       procedure FormShow(Sender: TObject);
     private
       FPath           : string;
       FPathList       : TStringList;
       FInitOk         : Boolean;
       FOwnerHandle    : HWnd;
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
       FInitialDir     : string;
       {Buttons}
       FButtonCapOk    : string;
       FButtonCapCancel: string;
       function GetCount: Integer;
       function SelectSingleFolder(const Caption: string; const OwnerHandle: HWnd): string;
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
       property InitOk: Boolean read FInitOk;
       property OwnerHandle: HWnd write FOwnerHandle;
       {Dialog-Properties}
       property Caption       : string read FCaption write FCaption;
       property Title         : string read FTitle write FTitle;
       property ColCaption    : string read FColCaption write FColCaption;
       property OkCaption     : string read FButtonCapOk write FButtonCapOk;
       property CancelCaption : string read FButtonCapCancel write FButtonCapCancel;
       property Height        : Integer read FHeight write FHeight;
       property Left          : Integer read FLeft write FLeft;
       property Top           : Integer read FTop write FTop;
       property Width         : Integer read FWidth write FWidth;
       property Position      : TPosition read FPosition write FPosition;
       property Multiselect   : Boolean read FMultiselect write FMultiselect;
       {ShellTreeview-Properties}
       property Root          : string write FRoot;
       property InitialDir    : string write SetInitialDir;
       {Path}
       property Path          : string read FPath;
       property PathList      : TStringList read FPathList;
       property Count         : Integer read GetCount;
     end;

implementation

uses f_window, f_treelistfuncs;

const cComCtl32Name      : string   = 'comctl32.dll';
      cComCtl32MinVersion: Cardinal = $00050051;           // >=5.81

{ TFolderBrowser ------------------------------------------------------------- }

{ TFolderBrowser - Events }

procedure TFolderBrowser.FormShow(Sender: TObject);
var ItemHeight: Integer;
    r         : TRect;
begin
  if IsHighDPI then
  begin
    {$IFDEF UseVirtualShellTools}
    // not possible to adjust item height?
    {$ELSE}
    r := FBShellTreeView.Items[0].DisplayRect(False);
    ItemHeight := r.Bottom - r.Top;
    FBShellTreeView.Perform(TVM_SETITEMHEIGHT, ScaleByDPI(ItemHeight), 0);
    {$ENDIF}
  end;
end;

{ TFolderBrowser - private }

{ SelectSingleFolder -----------------------------------------------------------

  zeigt einen Auswahldialog für Verzeichnisse an. Ein einzelner Ordner kann
  gewählt werden. Diese Funktioen wird verwendet, wenn die Version der
  comctl32.dll nicht mindesten 5.81 ist.                                       }

function TFolderBrowser.SelectSingleFolder(const Caption: string;
                                           const OwnerHandle: HWnd): string;
var lpItemID   : PItemIDList;
    Malloc     : IMalloc;
    BrowseInfo : TBrowseInfo;
    DisplayName: array[0..MAX_PATH] of Char;
    TempPath   : array[0..MAX_PATH] of Char;
    NewPath    : string;
begin
  Result := '';
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  ShGetMalloc(Malloc);
  with BrowseInfo do
  begin
    hwndOwner      := OwnerHandle;
    pszDisplayName := @DisplayName;
    lpszTitle      := PChar(Caption);
    ulFlags        := 0;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    NewPath := TempPath;
    Malloc.Free(lpItemId);
  end;
  if DirectoryExists(NewPath) then Result := NewPath;
end;

{ GetCount ---------------------------------------------------------------------

  gibt die Anzahl der in Pfadlister vorhanden Ordner zurück.                   }

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

  fügt der ausgwählten Ordner in die Liste ein, sofern er nicht schon vorhanden
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

  Ordner werden mit Alt-Insert in dies Liste übertragen.                       }

procedure TFolderBrowser.STVKeyDown(Sender: TObject; var Key: Word;
                                    Shift: TShiftState);
begin
  (*
  if  ssAlt in Shift then
  begin
    case Key of
      VK_INSERT: InsertFolder(FBShellTreeView.SelectedFolder.Path);
    end;
  end;
  *)
  if ((ssAlt in Shift) and (Key = VK_INSERT)) or
     (Key = VK_F11) then
    {$IFDEF UseVirtualShellTools}
    InsertFolder(FBShellTreeView.SelectedPath);
    {$ELSE}
    InsertFolder(FBShellTreeView.SelectedFolder.PathName);
    {$ENDIF}
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
  FInitialDir      := '';
  FButtonCapOk     := 'Ok';
  FButtonCapCancel := 'Abbrechen';
  FPath            := '';
  FMultiselect     := False;
  FColCaption      := 'ausgewählte Ordner';
  FPathList        := TStringList.Create;
  {Die ShellShock-Kompoenten funktioniern nur mit comctl32.dll in der Version
   5.81 oder höher korrekt. Sonst treten Access Violations auf.}
  FInitOk := GetFileVersion(cComCtl32Name) >= cComCtl32MinVersion;
  FOwnerHandle := 0;
end;

destructor TFolderBrowser.Destroy;
begin
  PathList.Free;
  inherited Destroy;
end;

{ Execute ----------------------------------------------------------------------

  öffnet den eigentlichen Auswahldialog.                                       }

function TFolderBrowser.Execute: Boolean;
var NewTop     : Integer;
    NewBottom  : Integer;
    LVHeight   : Integer;
    DefaultPath: string;
begin
  if FInitOk then
  begin
    {Dialog erstellen}
    FBDialog              := TForm.Create(Self);
    FBDialog.ClientHeight := ScaleByDPI(FHeight);
    FBDialog.Left         := FLeft;
    FBDialog.Top          := FTop;
    FBDialog.ClientWidth  := ScaleByDPI(FWidth);
    FBDialog.Position     := FPosition;
    FBDialog.BorderStyle  := bsDialog;
    FBDialog.ModalResult  := mrNone;
    FBDialog.KeyPreview   := True;
    FBDialog.Caption      := FCaption;
    FBDialog.OnShow       := FormShow;
    {Ereignisse}
    //FBDialog.OnKeyDown    := OpenDirDlgKeyDown;

    {Label}
    NewTop := ScaleByDPI(8);
    FBLabelTitle := TLabel.Create(Self);
    with FBLabelTitle do
    begin
      SetBounds(ScaleByDPI(8), NewTop,
                ScaleByDPI(FWidth) - ScaleByDPI(16), ScaleByDPI(13));
      // Font.Size  := Font.Size + 1;
      Parent     := FBDialog;
      Autosize   := True;
      Caption    := FTitle;
    end;
    NewTop := NewTop + ScaleByDPI(8) + FBLabelTitle.Height;

    {Cancel-Button}
    FBButtonCancel := TButton.Create(Self);
    with FBButtonCancel do
    begin
      SetBounds(ScaleByDPI(FWidth) - ScaleByDPI(8) - ScaleByDPI(75),
                ScaleByDPI(FHeight) - ScaleByDPI(30), ScaleByDPI(75),
                ScaleByDPI(25));
      Parent      := FBDialog;
      Caption     := FButtonCapCancel;
      ModalResult := mrAbort;
      Cancel      := True;
    end;

    {OK-Button}
    FBButtonOk := TButton.Create(Self);
    with FBButtonOk do
    begin
      SetBounds(ScaleByDPI(FWidth) - ScaleByDPI(8) - ScaleByDPI(2*75) -
                ScaleByDPI(5),
                ScaleByDPI(FHeight) - ScaleByDPI(30),
                ScaleByDPI(75), ScaleByDPI(25));
      Parent      := FBDialog;
      Caption     := FButtonCapOk;
      ModalResult := mrOk;
    end;
    NewBottom := FBButtonOk.Top - ScaleByDPI(8);

    {ListView}
    if FMultiselect then
    begin
      LVHeight := ScaleByDPI(120);
      FBListView := TListView.Create(Self);
      with FBListView do
      begin
        SetBounds(ScaleByDPI(8), NewBottom - LVHeight,
                  ScaleByDPI(FWidth) - ScaleByDPI(16), LVHeight);
        Parent             := FBDialog;
        ViewStyle          := vsReport;
        CheckBoxes         := False;
        OnKeyDown          := LVKeyDown;
        TabStop            := True;
        Columns.Add;
        Columns[0].Caption := FColCaption;
        Columns[0].Width   := FBListView.Width - 20;
      end;
      NewBottom := FBListView.Top - ScaleByDPI(8);
    end;

    {ShellTreeView}
    FBShellTreeView := {$IFDEF UseVirtualShellTools}
                       TVirtualExplorerTreeView.Create(Self);
                       {$ELSE}
                       TShellTreeView.Create(Self);
                       {$ENDIF}
    with FBShellTreeView do
    begin
      SetBounds(ScaleByDPI(8), NewTop, ScaleByDPI(FWidth) - ScaleByDPI(16),
                ScaleByDPI(FHeight) - NewTop - (ScaleByDPI(FHeight) - NewBottom));
      Parent := FBDialog;
      {$IFDEF UseVirtualShellTools}
      RootFolder := rfDesktop;
      Active := True;
      {$ELSE}
      HideSelection    := False;
      ObjectTypes      := [otFolders, otHidden];
      {$ENDIF}
      OnClick          := STVClick;
      OnKeyDown        := STVKeyDown;
      if DirectoryExists(FRoot) then
      begin
        Root := FRoot;
      end;
      if Length(FInitialDir) > 0 then
      begin
        {$IFDEF UseVirtualShellTools}
        FBShellTreeView.BrowseTo(FInitialDir, False, False, True, False);
        {$ELSE}
        FBShellTreeView.Path := FInitialDir;
        FBShellTreeView.Selected.Expand(False);
        {$ENDIF}
      end else
      begin
        DefaultPath := 'c:\';
        if not DirectoryExists(DefaultPath) then
          DefaultPath := ExtractFileDrive(Application.ExeName) + '\';
        {$IFDEF UseVirtualShellTools}
        FBShellTreeView.BrowseTo(DefaultPath, False, False, True, False);
        {$ELSE}
        FBShellTreeView.Path := DefaultPath;
        FBShellTreeView.Selected.Parent.Selected := True;
        {$ENDIF}
      end;                                                    
    end;
    SetFont(FBDialog);
    {$IFDEF UseVirtualShellTools}
    {$ELSE}
    if SetTreeViewStyle(FBShellTreeView) then
      FBShellTreeView.ShowLines := False;
    {$ENDIF}

    {TabOrder}
    FBShellTreeView.TabOrder := 0;
    if FMultiselect then FBListView.TabOrder      := 1;
    FBButtonOk.TabOrder      := 2;
    FBButtonCancel.TabOrder  := 3;

    Result := FBDialog.ShowModal = mrOK;
    if FBDialog.ModalResult = mrOK then
    begin
      {$IFDEF UseVirtualShellTools}
      FPath := FBShellTreeView.SelectedPath;
      {$ELSE}
      FPath := FBShellTreeView.SelectedFolder.PathName;
      {$ENDIF}
      if FPathList.Count = 0 then InsertFolder(FPath);
    end;
  end else
  begin
    {Wenn comctl32.dll nicht mindesten in Version 5.81 vorliegt, verursachen die
     ShelShock-Komponenten beim Freigeben des Dialogs Access-Violations. Daher
     als Fallback den normalen Dialog verwenden.}
    FPath := SelectSingleFolder(FCaption, FOwnerHandle);
    if FPathList.Count = 0 then FPathList.Add(FPath);
    Result := FPath <> '';
  end;
end;

end.
