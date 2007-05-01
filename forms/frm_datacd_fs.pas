{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_datacd_fs.pas: mkisfos-Optionen

  Copyright (c) 2004-2007 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  01.05.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_datacd_fs;

{$I directives.inc}

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls,
     {eigene Klassendefinitionen/Units}
     cl_settings, cl_lang, ComCtrls;

type
  TFormDataCDFS = class(TForm)
    ButtonCancel: TButton;
    ButtonOk: TButton;
    OpenDialog1: TOpenDialog;
    PageControlFileSystem: TPageControl;
    TabSheetGeneral: TTabSheet;
    TabSheetISO: TTabSheet;
    GroupBoxJoliet: TGroupBox;
    Label2: TLabel;
    CheckBoxJolietLong: TCheckBox;
    CheckBoxJoliet: TCheckBox;
    GroupBoxDuplicateFiles: TGroupBox;
    CheckBoxFindDups: TCheckBox;
    GroupBoxUDF: TGroupBox;
    CheckBoxUDF: TCheckBox;
    GroupBoxRockRidge: TGroupBox;
    CheckBoxRockRidge: TCheckBox;
    CheckBoxRationalRock: TCheckBox;
    GroupBoxBoot: TGroupBox;
    ButtonBootImageSelect: TButton;
    CheckBoxBoot: TCheckBox;
    CheckBoxBootCatHide: TCheckBox;
    StaticText1: TStaticText;
    EditBootImage: TEdit;
    CheckBoxBootBinHide: TCheckBox;
    CheckBoxBootNoEmul: TCheckBox;
    GroupBoxISO: TGroupBox;
    Label1: TLabel;
    CheckBoxISO31Chars: TCheckBox;
    CheckBoxISONoDot: TCheckBox;
    CheckBoxISODeepDir: TCheckBox;
    CheckBoxISO37Chars: TCheckBox;
    CheckBoxISOStartDot: TCheckBox;
    CheckBoxISOASCII: TCheckBox;
    CheckBoxISOLower: TCheckBox;
    CheckBoxISONoTrans: TCheckBox;
    CheckBoxISOMultiDot: TCheckBox;
    CheckBoxISOLevel: TCheckBox;
    ComboBoxISOLevel: TComboBox;
    CheckBoxISONoVer: TCheckBox;
    GroupBoxCharSet: TGroupBox;
    ComboBoxISOOutChar: TComboBox;
    ComboBoxISOInChar: TComboBox;
    LabelCharsetIn: TLabel;
    LabelCharsetOut: TLabel;
    CheckBoxBootInfoTable: TCheckBox;
    EditBootLoadSegAdr: TEdit;
    EditBootLoadSize: TEdit;
    LabelBootLoadSegAdr: TLabel;
    LabelBootLoadSize: TLabel;
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure ButtonBootImageSelectClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FSettings: TSettings;
    FLang: TLang;
    function GetActivePage: Byte;
    function InputOk: Boolean;
    procedure ActivateTab;
    procedure CheckControls;
    procedure GetSettings;
    procedure SetSettings;
  public
    { Public declarations }
    property Lang: TLang read FLang write FLang;
    property Settings: TSettings read FSettings write FSettings;
  end;

{ var }

implementation

{$R *.DFM}

uses constant, f_misc;

{uses ;}

{var}

{ ActivateTab ------------------------------------------------------------------

  ActivateTab zeigt das TabSheet an, das in FSettings.General.TabFrmSettings
  angegeben ist.                                                               }

procedure TFormDataCDFS.ActivateTab;
begin
   PageControlFileSystem.ActivePage :=
     PageControlFileSystem.Pages[FSettings.General.TabFrmDCDFS - 1];
end;

{ GetActivePage ----------------------------------------------------------------

  GetActivePage liefert als Ergebnis die Nummer der aktiven Registerkarte:
  Allgemein = 1; ISO = 2;                                                      }

function TFormDataCDFS.GetActivePage: Byte;
begin
  Result := PageControlFileSystem.ActivePage.PageIndex + 1;
end;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormDataCDFS.InputOk: Boolean;
begin
  Result := True;
  if CheckBoxBoot.Checked and (EditBootImage.Text = '') then
  begin
    // Fehlermeldung := 'Name für das Boot-Image fehlt!';
    Application.MessageBox(PChar(FLang.GMS('e201')), PChar(FLang.GMS('g001')),
      MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
    Result := False;
  end;
  {Wenn kein ISO-Level gewählt ist, macht es keinen Sinn, wenn ISOLevel = True
   ist.}
  if CheckBoxIsoLevel.Checked and (ComboBoxIsoLevel.ItemIndex = -1) then
  begin
    CheckBoxIsoLevel.Checked := False;
  end;
  {man muß auch die Möglichkeit haben, den Zeichensatz wieder abzuwählen}
  if ComboBoxISOOutChar.ItemIndex = 0 then
  begin
    ComboBoxISOOutChar.ItemIndex := -1;
  end;
  if ComboBoxISOInChar.ItemIndex = 0 then
  begin
    ComboBoxISOInChar.ItemIndex := -1;
  end;
end;


{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormDataCDFS.GetSettings;
begin
  with FSettings.DataCD do
  begin
    CheckBoxJoliet.Checked        := Joliet;
    CheckBoxJolietLong.Checked    := JolietLong;
    CheckBoxRockRidge.Checked     := RockRidge;
    CheckBoxRationalRock.Checked  := RationalRock;
    CheckBoxISO31Chars.Checked    := ISO31Chars;
    if ISOLevel then
    begin
      CheckBoxISOLevel.Checked    := True;
    end;
    ComboBoxISOLevel.ItemIndex    := ISOLevelNr - 1;
    ComboBoxISOOutChar.ItemIndex  := ISOOutChar;
    ComboBoxISOInChar.ItemIndex   := ISOInChar;
    CheckBoxISO37Chars.Checked    := ISO37Chars;
    CheckBoxISONoDot.Checked      := ISONoDot;
    CheckBoxISOStartDot.Checked   := ISOStartDot;
    CheckBoxISOMultiDot.Checked   := ISOMultiDot;
    CheckBoxISOASCII.Checked      := ISOASCII;
    CheckBoxISOLower.Checked      := ISOLower;
    CheckBoxISONoTrans.Checked    := ISONoTrans;
    CheckBoxISODeepDir.Checked    := ISODeepDir;
    CheckBoxISONoVer.Checked      := ISONoVer;
    CheckBoxUDF.Checked           := UDF;
    CheckBoxBoot.Checked          := Boot;
    EditBootImage.Text            := BootImage;
    CheckBoxBootCatHide.Checked   := BootCatHide;
    CheckBoxBootBinHide.Checked   := BootBinHide;
    CheckBoxBootNoEmul.Checked    := BootNoEmul;
    CheckBoxBootInfoTable.Checked := BootInfTable;
    EditBootLoadSegAdr.Text       := BootSegAdr;
    EditBootLoadSize.Text         := BootLoadSize;
    CheckBoxFindDups.Checked      := FindDups;
  end;
  ActivateTab;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormDataCDFS.SetSettings;
begin
  with FSettings.DataCD do
  begin
    Joliet        := CheckBoxJoliet.Checked;
    JolietLong    := CheckBoxJolietLong.Checked;
    RockRidge     := CheckBoxRockRidge.Checked;
    RationalRock  := CheckBoxRationalRock.Checked;
    ISO31Chars    := CheckBoxISO31Chars.Checked;
    ISOLevel      := CheckBoxIsoLevel.Checked;
    ISOLevelNr    := ComboBoxISOLevel.ItemIndex + 1;
    ISOOutChar    := ComboBoxISOOutChar.ItemIndex;
    ISOInChar     := ComboBoxISOInChar.ItemIndex;
    ISO37Chars    := CheckBoxISO37Chars.Checked;
    ISONoDot      := CheckBoxISONoDot.Checked;
    ISOStartDot   := CheckBoxISOStartDot.Checked;
    ISOMultiDot   := CheckBoxISOMultiDot.Checked;
    ISOASCII      := CheckBoxISOASCII.Checked;
    ISOLower      := CheckBoxISOLower.Checked;
    ISONoTrans    := CheckBoxISONoTrans.Checked;
    ISODeepDir    := CheckBoxISODeepDir.Checked;
    ISONoVer      := CheckBoxISONoVer.Checked;
    UDF           := CheckBoxUDF.Checked;
    Boot          := CheckBoxBoot.Checked;
    BootImage     := EditBootImage.Text;
    BootCatHide   := CheckBoxBootCatHide.Checked;
    BootBinHide   := CheckBoxBootBinHide.Checked;
    BootNoEmul    := CheckBoxBootNoEmul.Checked;
    BootInfTable  := CheckBoxBootInfoTable.Checked;
    BootSegAdr    := EditBootLoadSegAdr.Text;
    BootLoadSize  := EditBootLoadSize.Text;
    FindDups      := CheckBoxFindDups.Checked;
    {wenn kein RockRidge, dann auch kein Multisession}
    if not RockRidge then
    begin
      Multi := False;
    end;
  end;
  FSettings.General.TabFrmDCDFS := GetActivePage;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormDataCDFS.CheckControls;
var Temp: Boolean;
begin
  {Joliet-Optionen}
  if CheckBoxJoliet.Checked then
  begin
    CheckBoxJolietLong.Enabled := True;
    Label2.Enabled := True;
  end else
  begin
    CheckBoxJolietLong.Enabled := False;
    Label2.Enabled := False;
  end;
  {Rock-Ridge-Optionen}
  if CheckBoxRockRidge.Checked then
  begin
    CheckBoxRationalRock.Enabled := True;
  end else
  begin
    CheckBoxRationalRock.Enabled := False;
  end;
  {ISO-Level-Optionen}
  if CheckBoxISOLevel.Checked then
  begin
    ComboBoxISOLevel.Enabled := True;
    (* Zeichensatz-Einstellungen sind _nicht_ beschränkt auf ISO-Level 4
    if ComboBoxISOLevel.ItemIndex = 3 then
    begin
      ComboBoxISOOutChar.Enabled := True;
      Label3.Enabled := True;
    end else
    begin
      ComboBoxISOOutChar.Enabled := False;
      Label3.Enabled := False;
    end; *)
  end else
  begin
    ComboBoxISOLevel.Enabled := False;
    (*
    ComboBoxISOOutChar.Enabled := False;
    Label3.Enabled := False; *)
  end;
  {Boot-Optionen}
  if CheckBoxBoot.Checked then
  begin
    CheckBoxBootCatHide.Enabled := True;
    CheckBoxBootBinHide.Enabled := True;
    CheckBoxBootNoEmul.Enabled := True;
    CheckBoxBootInfoTable.Enabled := True;
    EditBootImage.Enabled := True;
    ButtonBootImageSelect.Enabled := True;
    StaticText1.Enabled := True;
  end else
  begin
    CheckBoxBootCatHide.Enabled := False;
    CheckBoxBootBinHide.Enabled := False;
    CheckBoxBootNoEmul.Enabled := False;
    CheckBoxBootInfoTable.Enabled := False;
    EditBootImage.Enabled := False;
    ButtonBootImageSelect.Enabled := False;
    StaticText1.Enabled := False;
  end;
  Temp := CheckBoxBoot.Checked and CheckBoxBootNoEmul.Checked;
  LabelBootLoadSegAdr.Enabled := Temp;
  LabelBootLoadSize.Enabled := Temp;
  EditBootLoadSegAdr.Enabled := Temp;
  EditBootLoadSize.Enabled := Temp;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormDataCDFS.ButtonOkClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    ModalResult := mrOK;
  end;
end;

{ Boot-CD: Select image }

procedure TFormDataCDFS.ButtonBootImageSelectClick(Sender: TObject);
begin
  OpenDialog1 := TOpenDialog.Create(self);
  OpenDialog1.Title := FLang.GMS('m202');
  OpenDialog1.Filter := FLang.GMS('f007');
  OpenDialog1.Options := [ofFileMustExist];
  if OpenDialog1.Execute then
  begin
    EditBootImage.Text := OpenDialog1.Files[0];
  end;
  OpenDialog1.Free;
end;


{ Form-Events ---------------------------------------------------------------- }

{ OnFormShow -------------------------------------------------------------------

  Wenn das Fenster gezeigt wird, müssen die Controls den Daten in FSettings
  entsprechend gesetzt werden.                                                 }

procedure TFormDataCDFS.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
  ComboBoxISOOutChar.Items.Assign(FSettings.General.Charsets);
  ComboBoxISOInChar.Items.Assign(FSettings.General.Charsets);
  GetSettings;
  CheckControls;
  {Wenn Label 'boot' geklickt wurde}
  if FSettings.General.TempBoot then CheckBoxBoot.Checked := True;
  FSettings.General.TempBoot := False;
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.

  Diese Prozedur wird auch für das OnChange-Event der Combo-Box verwendet.     }

procedure TFormDataCDFS.CheckBoxClick(Sender: TObject);
begin
  CheckControls;
end;

{ OnKeyPress -------------------------------------------------------------------

  ENTER soll bei Edit- und Comboxen zum nächsten Control weiterschalten.       }

procedure TFormDataCDFS.EditKeyPress(Sender: TObject;
                                     var Key: Char);
var C: TControl;
begin
  C := Sender as TControl;
  if Key = EnterKey then
  begin
    Key := NoKey;
    if C = ComboBoxISOLevel then
    begin
      CheckBoxISO37Chars.SetFocus;
    end else
    if C = ComboBoxISOInChar then
    begin
      ComboBoxISOOutChar.SetFocus;
    end else
    if C = ComboBoxISOOutChar then
    begin
      CheckBoxFindDups.SetFocus;
    end else
    if C = EditBootImage then
    begin
      ButtonOk.SetFocus;
    end;
  end;
end;

initialization

end.
