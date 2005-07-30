{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  frm_datacd_fs_error.pas: Dialog zum Korrigieren von zu langen Dateinamen

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_datacd_fs_error;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ShellAPI, StdCtrls, Menus, ExtCtrls,
  {eigene Klassendefinitionen/Units}
  cl_projectdata, cl_lang, cl_imagelists, cl_settings;

type
  TFSEMode = (mFiles, mFolders, mInvalidFiles);

  TFormDataCDFSError = class(TForm)
    ListView: TListView;
    Label1: TLabel;
    PopupMenu: TPopupMenu;
    Rename: TMenuItem;
    GroupBox1: TGroupBox;
    StaticText1: TStaticText;
    ButtonIgnore: TButton;
    ButtonOk: TButton;
    StaticText2: TStaticText;
    Hinweis: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonIgnoreClick(Sender: TObject);
    procedure ListViewEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure ListViewEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure RenameClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FData: TProjectData;
    FDirCheck: Boolean;
    FImageLists: TImageLists;
    FItemToDelete: Integer;
    FLang: TLang;
    FLongestName: Byte;
    FMaxLength: Byte;
    FMode: TFSEMode;
    FSettings: TSettings;
    procedure AddErrorItemToListView(const Item: string; ListView: TListView);
    procedure SetCorrectionMode(Mode: TFSEMode);
    procedure SetForFilenames;
    procedure SetForFolders;
    procedure SetForInvalidFiles;
    procedure ShowErrorList;
    procedure ShowErrorListDir;
    procedure ShowInvalidList;
  public
    { Public declarations }
    property Data: TProjectData write FData;
    property ImageLists: TImageLists write FImageLists;
    property Lang: TLang write FLang;
    property Mode: TFSEMode write SetCorrectionMode;    // darf erst gesetzt werden, wenn Settings initialisiert wurde
    property Settings: TSettings read FSettings write FSettings;
  end;

{ var }

implementation

{$R *.DFM}

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_strings, f_filesystem, constant;

{var}

{ SetCorretionMode -------------------------------------------------------------

  Set CorrectionMode wird ausgelöst, wenn das Property Mode gesetzt wird. Dem
  entsprechend werden die Controls angepaßt.                                   }

procedure TFormDataCDFSError.SetCorrectionMode(Mode: TFSEMode);
begin
  FMode := Mode;
  case FMode of
    mFiles       : SetForFilenames;
    mFolders     : SetForFolders;
    mInvalidFiles: SetForInvalidFiles;
  end;
end;

{ SetForFilenames---------------------------------------------------------------

  Wenn der Dialog für die zu langen Dateinamen gezeigt werden soll.            }

procedure TFormDataCDFSError.SetForFilenames;
begin
  FDirCheck := False;
  FLongestName := 0;

  {Dialog anpassen}
  Rename.Visible := True;
  Caption := FLang.GMS('c501');
  ListView.Columns[0].Width := 350;
  ListView.Columns[1].Width := 50;
  ListView.Columns[2].Width := 600;
  ListView.ReadOnly := False;
  StaticText1.Visible := True;
  StaticText2.Visible := True;
  ButtonIgnore.Visible := True;

  {maximale Länge entsprechend den Einstellungen feststelle}
  FMaxLength := FSettings.GetMaxFileNameLength;

  {wieviele Namen müssen geändert werden?}
  Label1.Caption := Format(FLang.GMS('m502'), [FMaxLength]);
  Label2.Caption := Format(FLang.GMS('m501'), [FData.ErrorListFiles.Count]);

  {Hinweise/Vorschläge}
  if (FMaxLength = 12) and (FLongestName < 32) then
  begin
    Label3.Caption := FLang.GMS('m504');
  end else
  if (FMaxLength <= 31) and (FLongestName < 38) then
  begin
    Label3.Caption := FLang.GMS('m505');
  end else
  if (FMaxLength <= 37) and (FLongestName < 65) then
  begin
    Label3.Caption := FLang.GMS('m506');
  end else
  if (FMaxLength <= 64) and (FLongestName < 104) then
  begin
    Label3.Caption := FLang.GMS('m507');
  end else
  if (FMaxLength <= 103) and (FLongestName < 208) then
  begin
    Label3.Caption := FLang.GMS('m508');
  end else
  if (FMaxLength <= 197) and (FLongestName < 208) then
  begin
    Label3.Caption := FLang.GMS('m509');
  end else
  if (FMaxLength <= 207) and (FLongestName < 248) then
  begin
    Label3.Caption := FLang.GMS('m510');
  end else
  if (FMaxLength <= 247) and (FLongestName > 247) then
  begin
    Label3.Caption := FLang.GMS('m511');
  end else
  begin
    Label3.Caption := '';
  end;

  ListView.TabStop := True;
end;

{ SetForFolders ----------------------------------------------------------------

  Wenn der Dialog für zu tief verschachtelte Ordner angezeigt werden soll.     }

procedure TFormDataCDFSError.SetForFolders;
begin
  FDirCheck := True;
  {Dialog anpassen}
  Rename.Visible := False;
  Caption := FLang.GMS('c502');
  ListView.Columns[0].Width := 600;
  ListView.Columns[1].Width := 0;
  ListView.Columns[2].Width := 0;
  StaticText1.Visible := False;
  StaticText2.Visible := False;
  ButtonIgnore.Visible := False;

  {worum es geht}
  Label1.Caption := FLang.GMS('m503') + ':';
  Label2.Caption := '';

  {Hinweis}
  Label3.Caption := FLang.GMS('m512');

  ListView.TabStop := False;
end;

{ SetForInvalidFiles -----------------------------------------------------------

  Wenn der Dialog für ungültige Quelldateien genutzt werden soll.              }

procedure TFormDataCDFSError.SetForInvalidFiles;
begin
  FDirCheck := True;
  {Dialog anpassen}
  Rename.Visible := False;
  Caption := FLang.GMS('c503');
  ListView.Columns[0].Width := 600;
  ListView.Columns[1].Width := 0;
  ListView.Columns[2].Width := 0;
  StaticText1.Visible := False;
  StaticText2.Visible := False;
  ButtonIgnore.Visible := False;

  {worum es geht}
  Label1.Caption := FLang.GMS('m513') + ':';
  Label2.Caption := '';

  {Hinweis}
  Label3.Caption := FLang.GMS('m514');

  ListView.TabStop := False;
end;

{ AddErrorItemToListView -------------------------------------------------------

  Die in der ErrorList gespeicherten Dateien im ListView angezeigen.           }

procedure TFormDataCDFSError.AddErrorItemToListView(const Item: string;
                                                    ListView: TListView);
var NewItem  : TListItem;
    Info     : TSHFileInfo;
    SearchRec: TSearchRec;
    p        : Integer;
    Name     : string;
    Caption  : string;
begin
  if FMode = mFiles then
  begin
    Name := Item;
    {Caption ist alles _vor_ dem ':'}
    Caption := Copy(Name, 1, Pos(':', Name) - 1);
    {Datei oder Order?}
    if LastDelimiter('/', Caption) = Length(Caption) then
    begin
      Delete(Caption, LastDelimiter('/', Caption), 1);
      Delete(Caption, 1, LastDelimiter('/', Caption));
      NewItem := ListView.Items.Add;
      NewItem.Caption := Caption;
      SHGetFileInfo(PChar(StartupDir), 0, Info,
                    SizeOf(TSHFileInfo),
                    SHGFI_SYSIconIndex or SHGFI_TYPENAME);
      NewItem.ImageIndex:=Info.IIcon;
      NewItem.SubItems.Add(IntToStr(Length(Caption)));
      NewItem.SubItems.Add(Name);
    end else
    begin
      {Pfad entfernen}
      Delete(Caption, 1, LastDelimiter('/', Caption));
      {Dateinamen extrahieren}
      Delete(Name, 1, Pos(':', Name));
      p := Pos('*', Name);
      Delete(Name, p, Length(Name) - p + 1);
      {Infos ermitteln}
      if FindFirst(Name, faAnyFile, SearchRec) = 0 then
      begin
        if (Length(SearchRec.Name) > 0) and (SearchRec.Name[1] <> '.') then
        begin
          NewItem := ListView.Items.Add;
          NewItem.Caption := Caption;
          SHGetFileInfo(PChar(Name), 0, Info,
                        SizeOf(TSHFileInfo),
                        SHGFI_SYSIconIndex or SHGFI_TYPENAME);
          NewItem.ImageIndex:=Info.IIcon;
          NewItem.SubItems.Add(IntToStr(Length(Caption)));
          NewItem.SubItems.Add(Name);
          {Wie lang ist der längste Name?}
          if FLongestName < Length(Caption) then
          begin
            FLongestName := Length(Caption);
          end;
        end;
        FindClose(SearchRec);
      end;
    end;
  end else                   // ErrorListDir
  if FMode = mFolders then
  begin
    NewItem := ListView.Items.Add;
    NewItem.Caption := Item;
    SHGetFileInfo(PChar(StartupDir), 0, Info,
                  SizeOf(TSHFileInfo),
                  SHGFI_SYSIconIndex or SHGFI_TYPENAME);
    NewItem.ImageIndex:=Info.IIcon;
  end else
  if FMode = mInvalidFiles then
  begin
    NewItem := ListView.Items.Add;
    NewItem.Caption := Item;
    SHGetFileInfo(PChar(Item), 0, Info,
                  SizeOf(TSHFileInfo),
                  SHGFI_SYSIconIndex or SHGFI_TYPENAME);
    NewItem.ImageIndex:=Info.IIcon;
  end;
end;

{ ShowErrorList ----------------------------------------------------------------

  Die Liste mit den zu langen Dateinamen anzeigen.                             }

procedure TFormDataCDFSError.ShowErrorList;
var i: Integer;
begin
  for i := 0 to FData.ErrorListFiles.Count - 1 do
  begin
    AddErrorItemToListView(FData.ErrorListFiles[i], ListView);
  end;
end;

{ ShowErrorListDir -------------------------------------------------------------

  Die Liste mit den zu tiefen Ordnern anzeigen.                                }

procedure TFormDataCDFSError.ShowErrorListDir;
var i: Integer;
begin
  for i := 0 to FData.ErrorListDir.Count - 1 do
  begin
    AddErrorItemToListView(FData.ErrorListDir[i], ListView);
  end;
end;

{ ShowInvalidList --------------------------------------------------------------

  Die Liste mit den unzulässigen Dateien zeigen.                               }

procedure TFormDataCDFSError.ShowInvalidList;
var i: Integer;
begin
  for i := 0 to FData.InvalidSrcFiles.Count - 1 do
  begin
    AddErrorItemToListView(FData.InvalidSrcFiles[i], ListView);
  end;
end;



{ Form-Events ---------------------------------------------------------------- }

{ OnCreate ---------------------------------------------------------------------

  Die Variable FItemToDelete initialiseren.                                    }

procedure TFormDataCDFSError.FormCreate(Sender: TObject);
begin
  FItemToDelete := -1;
end;

{ OnShow -----------------------------------------------------------------------

  Sprache anpassen, und den List-View mit Icons versorgen und füllen.          }

procedure TFormDataCDFSError.FormShow(Sender: TObject);
begin
  ListView.LargeImages := FImageLists.LargeImages;
  ListView.SmallImages := FImageLists.SmallImages;
  FLang.SetFormLang(self);
  {Liste anzeigen}
  ListView.Items.Clear;
  case FMode of
    mFiles       : begin
                     ShowErrorList;
                     ListView.Selected := ListView.Items[0];
                   end;
    mFolders     : ShowErrorListDir;
    mInvalidFiles: ShowInvalidList;
  end;
end;

{ OnDestroy ------------------------------------------------------------------ }

procedure TFormDataCDFSError.FormDestroy(Sender: TObject);
begin
  {$IFDEF ManualFreeListView}
  ListView.Free;
  {$ENDIF}
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormDataCDFSError.ButtonOkClick(Sender: TObject);
var i: Integer;
begin
  {nicht korrigierte Dateinamen in Ignore-List übernehmen}
  for i := 0 to FData.ErrorListFiles.Count - 1 do
  begin
    FData.ErrorListIgnore.Add(FData.ErrorListFiles[i]);
  end;
  {Fenster schließen}
  ModalResult := mrOk;
end;

{ Ignore }

procedure TFormDataCDFSError.ButtonIgnoreClick(Sender: TObject);
begin
  FData.IgnoreNameLengthErrors := True;
  ModalResult := mrOk;
end;


{ ListView-Events ------------------------------------------------------------ }

{ OnEdited ---------------------------------------------------------------------

  Wenn ein Name geändert wurde, überprüfen, ob Name gültig ist, ob er kurz
  genug ist und ob er nicht schon vorhanden ist.                               }

procedure TFormDataCDFSError.ListViewEdited(Sender: TObject; Item: TListItem;
                                            var S: String);
var Temp: string;
    Path: string;
    Name: string;
    ErrorCode: Byte;
begin
  Temp := FData.ErrorListFiles[Item.Index];
  {Zielpfad auf dem Eintrag extrahieren: Path ist alles _vor_ dem ':'}
  SplitString(Temp, ':', Path, Temp);
  if LastDelimiter('/', Path) = Length(Path) then      // Ordner
  begin
    FData.RenameFolder(Path, S, FSettings.GetMaxFileNameLength,
                       FSettings.General.Choice);
    ErrorCode := FData.LastError;
    if ErrorCode = PD_NoError then
    begin
      {Änderungen im GUI nachvollziehen}
      Item.Caption := S;
      FItemToDelete := Item.Index;
      {Parent-Folder müßte noch sortiert werden, geschieht in CheckDataCDFs}
    end else
    begin
      Temp := S;
      S := Item.Caption;
      Item.Caption := S;
      if ErrorCode = PD_FolderNotUnique then
      begin
        {Fehlermeldung nur ausgeben, wenn der neue Name sich wirklich vom
         alten unterscheidet.}
        if Temp <> Item.Caption then
        begin
          Application.MessageBox(PChar(Format(FLang.GMS('e111'), [Temp])),
                                 PChar(FLang.GMS('g001')),
                                 MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
        end;
      end else
      if ErrorCode = PD_InvalidName then
      begin
        Application.MessageBox(PChar(FLang.GMS('e110')),
                               PChar(FLang.GMS('g001')),
                               MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end else
      if ErrorCode = PD_NameTooLong then
      begin
        Application.MessageBox(PChar(FLang.GMS('e501')),
                               PChar(FLang.GMS('g001')),
                               MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end else                                             // Datei
  begin
    {jetzt den Ziel-Dateinamen und Pfad trennen}
    Name := Copy(Path, LastDelimiter('/', Path) + 1,
                 Length(Path) - LastDelimiter('/', Path) + 1);
    if Pos('/', Path) > 0 then
    begin
      Delete(Path, LastDelimiter('/', Path),
                   Length(Path) - LastDelimiter('/', Path) + 1);
    end else
      {Wenn die Datei im Wurzel-Verzeichnis ist, muß der Pfad leer sein.}
      Path := '';
    {Umbenennen}
    FData.RenameFileByName(Path, Name, S, FMaxLength, cDataCD);
    ErrorCode := FData.LastError;
    if ErrorCode = PD_NoError then
    begin
      {Änderungen im GUI nachvollziehen}
      Item.Caption := S;
      FItemToDelete := Item.Index;
      {Liste muß jetzt sortiert werden}
      FData.SortFileList(Path, cDataCD);
    end else
    begin
      Temp := S;
      S := Item.Caption;
      Item.Caption := S;
      if ErrorCode = PD_FileNotUnique then
      begin
        {Fehlermeldung nur ausgeben, wenn der neue Name sich wirklich vom
         alten unterscheidet.}
        if Temp <> Item.Caption then
        begin
          Application.MessageBox(PChar(Format(FLang.GMS('e112'), [Temp])),
                                 PChar(FLang.GMS('g001')),
                                 MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
        end;
      end else
      if ErrorCode = PD_InvalidName then
      begin
        Application.MessageBox(PChar(FLang.GMS('e110')),
                               PChar(FLang.GMS('g001')),
                               MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end else
      if ErrorCode = PD_NameTooLong then
      begin
        Application.MessageBox(PChar(FLang.GMS('e501')),
                               PChar(FLang.GMS('g001')),
                               MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
      end;
    end;
  end;
end;

{ OnEditing --------------------------------------------------------------------

  Wenn es um zu tief liegende Ordner geht, ist das Umbenennen nicht erlaubt.   }

procedure TFormDataCDFSError.ListViewEditing(Sender: TObject; Item: TListItem;
                                             var AllowEdit: Boolean);
begin
  if FDirCheck then
  begin
    AllowEdit := False;
  end;
end;

{ OnKeyDown --------------------------------------------------------------------

  Mit F2 kann das Umbenennen eingeleitet werden.                               }

procedure TFormDataCDFSError.ListViewKeyDown(Sender: TObject; var Key: Word;
                                             Shift: TShiftState);
begin
  case Key of
    vk_F2: if ListView.Selected <> nil then
           begin
             ListView.Selected.EditCaption;
           end;
  end;
end;


{ Timer-Events --------------------------------------------------------------- }

{ OnTimer ----------------------------------------------------------------------

  Dirty Trick: Da im ListView-Item-Event das gerade aktuelle Item nicht gelöscht
  werden kann, muß das Löschen eben in einem Item-unabhängigen Event passieren.
  Hierfür wird ein Timer-Event verwendet, das alle 200ms ausgelöst wird.       }

procedure TFormDataCDFSError.Timer1Timer(Sender: TObject);
begin
  if FItemToDelete >= 0 then
  begin
    ListView.Items.Delete(FItemToDelete);
    ListView.UpdateItems(0, ListView.Items.Count);
    FData.ErrorListFiles.Delete(FItemToDelete);
    FItemToDelete := -1;
    Label2.Caption := Format(FLang.GMS('m501'), [FData.ErrorListFiles.Count]);
    if FData.ErrorListFiles.Count = 0 then
    begin
      Timer1.Enabled := False;
      ModalResult := mrOk;
    end else
    begin
      ListView.Selected := ListView.Items[0];
    end;
  end;
end;

{ Kontextmenü-Event ---------------------------------------------------------- }

procedure TFormDataCDFSError.RenameClick(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    ListView.Selected.EditCaption;
  end;
end;

initialization

end.
