{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_settings.pas: cdrtfe - Einstellungen
             
  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  20.02.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_settings;

{$I directives.inc}

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, ExtCtrls, FileCtrl, ComCtrls,
     {eigene Klassendefinitionen/Units}
     cl_lang, cl_settings, userevents;

type
  TFormSettings = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    PageControlSettings: TPageControl;
    TabSheetCdrtfe: TTabSheet;
    GroupBoxShellExt: TGroupBox;
    CheckBoxShellExt: TCheckBox;
    StaticText4: TStaticText;
    GroupBoxConfirm: TGroupBox;
    CheckBoxNoConfirm: TCheckBox;
    StaticText2: TStaticText;
    GroupBoxSettings: TGroupBox;
    TabSheetCdrecord: TTabSheet;
    GroupBoxAdditionalCmdLineOptions: TGroupBox;
    ComboBoxCdrecordCustOpts: TComboBox;
    ComboBoxMkisofsCustOpts: TComboBox;
    CheckBoxCdrecordCustOpts: TCheckBox;
    CheckBoxMkisofsCustOpts: TCheckBox;
    StaticText1: TStaticText;
    ButtonCdrecordCustOptDelete: TButton;
    ButtonMkisofsCustOptDelete: TButton;
    TabSheetCdrdao: TTabSheet;
    GroupBoxCdrdaoDriver: TGroupBox;
    CheckBoxForceGenericMMC: TCheckBox;
    CheckBoxForceGenericMMCRaw: TCheckBox;
    StaticText5: TStaticText;
    ButtonSettingsSave: TButton;
    ButtonSettingsDelete: TButton;
    GroupBoxOptionsCdrecord: TGroupBox;
    CheckBoxCdrecordVerbose: TCheckBox;
    CheckBoxCdrecordBurnfree: TCheckBox;
    CheckBoxCdrecordSimulDrv: TCheckBox;
    TrackBarFIFOSize: TTrackBar;
    CheckBoxCdrecordFIFO: TCheckBox;
    LabelFIFOSize: TLabel;
    TabSheetCdrecord2: TTabSheet;
    GroupBoxCdrecordWritingSpeed: TGroupBox;
    CheckBoxCdrecordAllowHigherSpeed: TCheckBox;
    GroupBoxCdrdaoCue: TGroupBox;
    CheckBoxCdrdaoCueImage: TCheckBox;
    GroupBoxTempFolder: TGroupBox;
    EditTempFolder: TEdit;
    ButtonTempFolderBrowse: TButton;
    GroupBoxCdrecordEject: TGroupBox;
    CheckBoxCdrecordEject: TCheckBox;
    TabSheetAudioCD: TTabSheet;
    GroupBoxAudioCDText: TGroupBox;
    RadioButtonCDTextUseTags: TRadioButton;
    RadioButtonCDTextUseName: TRadioButton;
    PanelCDText: TPanel;
    RadioButtonCDTextPT: TRadioButton;
    RadioButtonCDTextTP: TRadioButton;
    GroupBoxAutoErase: TGroupBox;
    RadioButtonAutoEraseDisabled: TRadioButton;
    RadioButtonAutoErase: TRadioButton;
    CheckBoxAutoSaveOnExit: TCheckBox;
    GroupBoxCdrecordFormat: TGroupBox;
    CheckBoxCdrecordFormat: TCheckBox;
    GroupBoxDetectSpeeds: TGroupBox;
    TabSheetDrives: TTabSheet;
    CheckBoxDetectSpeeds: TCheckBox;
    GroupBoxSCSI: TGroupBox;
    RadioButtonSCSIAuto: TRadioButton;
    RadioButtonSCSIASPI: TRadioButton;
    RadioButtonSCSISPTI: TRadioButton;
    GroupBoxMPlayer: TGroupBox;
    EditMPlayerCmd: TEdit;
    EditMplayerOpt: TEdit;
    LabelMPlayerOpt: TLabel;
    LabelMPlayerCmd: TLabel;
    TabSheetCygwin: TTabSheet;
    GroupBoxCygwinDLL: TGroupBox;
    RadioButtonUseOwnDLL: TRadioButton;
    RadioButtonUseSearchPathDLL: TRadioButton;
    LabelUseDLL: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonSettingsSaveClick(Sender: TObject);
    procedure ButtonSettingsDeleteClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure TrackBarFIFOSizeChange(Sender: TObject);
    procedure ComboBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ComboBoxExit(Sender: TObject);
    procedure ButtonCustOptDeleteClick(Sender: TObject);
    procedure ButtonTempFolderBrowseClick(Sender: TObject);
    procedure EditTempFolderExit(Sender: TObject);
  private
    { Private declarations }
    FOnMessageShow: TMessageShowEvent;
    FSettings     : TSettings;
    FLang         : TLang;
    FShellExtIsSet: Boolean;  // Die Variablen für die ShellExtensions spielen
    FShellExtToSet: Boolean;  // nur hier eine Rolle.
    FSCSIOld      : string;
    FUseOwnDLLOld : Boolean;
    FFormHandle   : THandle;
    function GetActivePage: Byte;
    function InputOk: Boolean;
    procedure ActivateTab;
    procedure CheckControls(Sender: TObject);
    procedure GetSettings;
    procedure SetSettings;
    {Events}
    procedure MessageShow(const s: string);
  public
    { Public declarations }
    property Lang: TLang read FLang write FLang;
    property Settings: TSettings read FSettings write FSettings;
    property FormHandle: THandle read FFormHandle write FFormHandle;
    {Events}
    property OnMessageShow: TMessageShowEvent read FOnMessageShow write FOnMessageShow;
  end;

{ var }

implementation

{$R *.DFM}

uses f_shellext, f_wininfo, f_filesystem, f_misc, f_cygwin, constant,
     user_messages;

{var}

{ ActivateTab ------------------------------------------------------------------

  ActivateTab zeigt das TabSheet an, das in FSettings.General.TabFrmSettings
  angegeben ist.                                                               }

procedure TFormSettings.ActivateTab;
begin
   PageControlSettings.ActivePage :=
     PageControlSettings.Pages[FSettings.General.TabFrmSettings - 1];
end;

{ GetActivePage ----------------------------------------------------------------

  GetActivePage liefert als Ergebnis die Nummer der aktiven Registerkarte:
  cdrtfe = 1; cdrecord = 2; cdrecord(2) = 3; cdrdao = 4}

function TFormSettings.GetActivePage: Byte;
begin
  Result := PageControlSettings.ActivePage.PageIndex + 1;
end;


{ MessageToShow ----------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TFormSettings.MessageShow(const s: string);
begin
  if Assigned(FOnMessageShow) then FOnMessageShow(s);
end;


{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormSettings.InputOk: Boolean;
var Text: string;
begin
  Result := True;
  if EditMplayerCmd.Text <> '' then
  begin
    if not FileExists(EditMPlayerCmd.Text) then
    begin
      Text := Format(FLang.GMS('e113'), [EditMPlayerCmd.Text]);
      ShowMsgDlg(Text, FLang.GMS('g001'), MB_ICONSTOP or MB_OK);
      Result := False;
      FSettings.General.TabFrmSettings := cCDAudio;
      ActivateTab;
      EditMplayerCmd.SetFocus;
    end;
  end else
  begin
    FSettings.FileFlags.MPlayerOk := False;
  end;
end;


{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormSettings.GetSettings;
begin
  if not (FSettings.FileFlags.ShlExtDllOk and AccessToRegistryHKLM) then
  begin
    CheckBoxShellExt.Enabled := False;
    StaticText4.Enabled := False;
  end;
  CheckBoxAutoSaveOnExit.Checked := FSettings.General.AutoSaveOnExit;
  EditTempFolder.Text := FSettings.General.TempFolder;
  CheckBoxShellExt.Checked           := FShellExtIsSet;
  CheckBoxNoConfirm.Checked          := FSettings.General.NoConfirm;
  CheckBoxForceGenericMMC.Checked    := FSettings.Cdrdao.ForceGenericMmc;
  CheckBoxForceGenericMMCRaw.Checked := FSettings.Cdrdao.ForceGenericMmcRaw;
  CheckBoxCdrdaoCueImage.Checked     := FSettings.Cdrdao.WriteCueImages;
  with FSettings.Cdrecord do
  begin
    CheckBoxCdrecordVerbose.Checked          := Verbose;
    CheckBoxCdrecordBurnfree.Checked         := Burnfree;
    CheckBoxCdrecordSimulDrv.Checked         := SimulDrv;
    CheckBoxCdrecordFIFO.Checked             := FIFO;
    TrackBarFIFOSize.Position                := FIFOSize;
    CheckBoxCdrecordCustOpts.Checked         := CdrecordUseCustOpts;
    ComboBoxCdrecordCustOpts.Items.Assign(CdrecordCustOpts);
    ComboBoxCdrecordCustOpts.ItemIndex       := CdrecordCustOptsIndex;
    CheckBoxMkisofsCustOpts.Checked          := MkisofsUseCustOpts;
    ComboBoxMkisofsCustOpts.Items.Assign(MkisofsCustOpts);
    ComboBoxMkisofsCustOpts.ItemIndex        := MkisofsCustOptsIndex;
    CheckBoxCdrecordAllowHigherSpeed.Checked := ForceSpeed;
    CheckBoxCdrecordEject.Checked            := Eject;
    CheckBoxCdrecordFormat.Checked           := AllowFormat;
  end;
  CheckBoxDetectSpeeds.Checked := FSettings.General.DetectSpeeds;
  CheckBoxCdrdaoCueImage.Enabled := FSettings.FileFlags.CdrdaoOk and
                                    FSettings.Cdrecord.CanWriteCueImage;
  CheckBoxForceGenericMMC.Enabled := FSettings.FileFlags.CdrdaoOk;
  CheckBoxForceGenericMMCRaw.Enabled := FSettings.FileFlags.CdrdaoOk;
  RadioButtonCDTextUseTags.Checked := FSettings.General.CDTextUseTags;
  RadioButtonCDTextUseName.Checked := not FSettings.General.CDTextUseTags;
  RadioButtonCDTextPT.Checked := not FSettings.General.CDTextTP;
  RadioButtonCDTextTP.Checked := FSettings.General.CDTextTP;
  RadioButtonAutoErase.Checked := FSettings.Cdrecord.AutoErase;
  RadioButtonAutoEraseDisabled.Checked := not FSettings.Cdrecord.AutoErase;
  RadioButtonSCSIAuto.Checked := FSettings.Drives.SCSIInterface = '';
  RadioButtonSCSIASPI.Checked := FSettings.Drives.SCSIInterface = 'ASPI';
  RadioButtonSCSISPTI.Checked := FSettings.Drives.SCSIInterface = 'SPTI';
  FSCSIOld := FSettings.Drives.SCSIInterface;
  EditMPlayerCmd.Text := FSettings.General.MPlayerCmd;
  EditMPlayeropt.Text := FSettings.General.MPlayerOpt;
  RadioButtonUseOwnDLL.Checked := FSettings.FileFlags.UseOwnDLLs;
  RadioButtonUseSearchPathDLL.Checked := not FSettings.FileFlags.UseOwnDLLs;
  FUseOwnDLLOld := FSettings.FileFlags.UseOwnDLLs;
  ActivateTab;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormSettings.SetSettings;
begin
  FShellExtToSet                      := CheckBoxShellExt.Checked;
  FSettings.General.NoConfirm         := CheckBoxNoConfirm.Checked;
  FSettings.Cdrdao.ForceGenericMmc    := CheckBoxForceGenericMMC.Checked;
  FSettings.Cdrdao.ForceGenericMmcRaw := CheckBoxForceGenericMMCRaw.Checked;
  FSettings.Cdrdao.WriteCueImages     := CheckBoxCdrdaoCueImage.Checked;
  FSettings.General.AutoSaveOnExit    := CheckBoxAutoSaveOnExit.Checked;
  FSettings.General.TempFolder        := EditTempFolder.Text;
  with FSettings.Cdrecord do
  begin
    Verbose  := CheckBoxCdrecordVerbose.Checked;
    Burnfree := CheckBoxCdrecordBurnfree.Checked;
    SimulDrv := CheckBoxCdrecordSimulDrv.Checked;
    FIFO     := CheckBoxCdrecordFIFO.Checked;
    FIFOSize := TrackBarFIFOSize.Position;
    CdrecordUseCustOpts   := CheckBoxCdrecordCustOpts.Checked;
    CdrecordCustOptsIndex := ComboBoxCdrecordCustOpts.ItemIndex;
    CdrecordCustOpts.Assign(ComboBoxCdrecordCustOpts.Items);
    MkisofsUseCustOpts    := CheckBoxMkisofsCustOpts.Checked;
    MkisofsCustOptsIndex  := ComboBoxMkisofsCustOpts.ItemIndex;
    MkisofsCustOpts.Assign(ComboBoxMkisofsCustOpts.Items);
    ForceSpeed := CheckBoxCdrecordAllowHigherSpeed.Checked;
    Eject := CheckBoxCdrecordEject.Checked;
    AllowFormat := CheckBoxCdrecordFormat.Checked;
  end;
  FSettings.General.TabFrmSettings := GetActivePage;
  FSettings.General.CDTextUseTags := RadioButtonCDTextUseTags.Checked;
  FSettings.General.CDTextTP := RadioButtonCDTextTP.Checked;
  FSettings.Cdrecord.AutoErase := RadioButtonAutoErase.Checked;
  FSettings.General.DetectSpeeds := CheckBoxDetectSpeeds.Checked;
  if RadioButtonSCSIAuto.Checked then FSettings.Drives.SCSIInterface := '';
  if RadioButtonSCSIASPI.Checked then FSettings.Drives.SCSIInterface := 'ASPI';
  if RadioButtonSCSISPTI.Checked then FSettings.Drives.SCSIInterface := 'SPTI';
  FSettings.General.MPlayerCmd := EditMPlayerCmd.Text;
  FSettings.General.MPlayerOpt := EditMPlayerOpt.Text;
  FSettings.FileFlags.UseOwnDLLs := RadioButtonUseOwnDLL.Checked;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormSettings.CheckControls(Sender: TObject);
var C: TControl;
begin
  if Sender is TCheckBox then
  begin
    C := Sender as TCheckBox;
    if C = CheckBoxForceGenericMMC then
    begin
      if CheckBoxForceGenericMMC.Checked then
      begin
        CheckBoxForceGenericMMCRaw.Checked := False;
      end;
    end;
    if C = CheckBoxForceGenericMMCRaw then
    begin
      if CheckBoxForceGenericMMCRaw.Checked then
      begin
        CheckBoxForceGenericMMC.Checked := False;
      end;
    end;
    if C = CheckBoxCdrecordFIFO then
    begin
      if CheckBoxCDrecordFIFO.Checked then
      begin
        TrackBarFIFOSize.Enabled := True;
        LabelFIFOSize.Enabled := True;
      end else
      begin
        TrackBarFIFOSize.Enabled := False;
        LabelFIFOSize.Enabled := False;
      end;
    end;
    if C = CheckBoxCdrecordCustOpts then
    begin
      if CheckBoxCdrecordCustOpts.Checked then
      begin
        ComboBoxCdrecordCustOpts.Enabled := True;
        ButtonCdrecordCustOptDelete.Enabled := True;
      end else
      begin
        ComboBoxCdrecordCustOpts.Enabled := False;
        ButtonCdrecordCustOptDelete.Enabled := False;
      end;
    end else
    if C = CheckBoxMkisofsCustOpts then
    begin
      if CheckBoxMkisofsCustOpts.Checked then
      begin
        ComboBoxMkisofsCustOpts.Enabled := True;
        ButtonMkisofsCustOptDelete.Enabled := True;
      end else
      begin
        ComboBoxMkisofsCustOpts.Enabled := False;
        ButtonMkisofsCustOptDelete.Enabled := False;
      end;
    end;
  end else
  if Sender is TRadioButton then
  begin
    if RadioButtonCDTextUseName.Checked then
    begin
      RadioButtonCDTextTP.Enabled := True;
      RadioButtonCDTextPT.Enabled := True;
    end else
    begin
      RadioButtonCDTextTP.Enabled := False;
      RadioButtonCDTextPT.Enabled := False;
    end;
  end else
  if Sender is TForm then
  begin
    {Dieser Fall tritt beim ersten CheckControls ein, das von OnShow aus
     aufgerufen wird.}
    {Initialisierung des Track-Bars und des Labels}
    TrackBarFIFOSizeChange(Sender);
    if CheckBoxCDrecordFIFO.Checked then
    begin
      TrackBarFIFOSize.Enabled := True;
      LabelFIFOSize.Enabled := True;
    end else
    begin
      TrackBarFIFOSize.Enabled := False;
      LabelFIFOSize.Enabled := False;
    end;
    {Initialisierung der CustOpt-controls}
    if CheckBoxCdrecordCustOpts.Checked then
    begin
      ComboBoxCdrecordCustOpts.Enabled := True;
      ButtonCdrecordCustOptDelete.Enabled := True;
    end else
    begin
      ComboBoxCdrecordCustOpts.Enabled := False;
      ButtonCdrecordCustOptDelete.Enabled := False;
    end;
    if CheckBoxMkisofsCustOpts.Checked then
    begin
      ComboBoxMkisofsCustOpts.Enabled := True;
      ButtonMkisofsCustOptDelete.Enabled := True;
    end else
    begin
      ComboBoxMkisofsCustOpts.Enabled := False;
      ButtonMkisofsCustOptDelete.Enabled := False;
    end;
    {CheckBox für Geschwindigkeit nur ab cdrecord 2.01a33}
    CheckBoxCdrecordAllowHigherSpeed.Enabled :=
                                              FSettings.Cdrecord.DMASpeedCheck;
  end;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormSettings.ButtonOkClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    {ShellExtensions}
    if FShellExtIsSet <> FShellExtToSet then
    begin
      case FShellExtToSet of
        True : begin
                 RegisterShellExtensions;
                 MessageShow(FLang.GMS('mpref01'));
               end;
        False: begin
                 UnregisterSHellExtensions;
                 MessageShow(FLang.GMS('mpref02'));
               end;
      end;
    end;
    {SCSI-Interface}
    if FSCSIOld <> FSettings.Drives.SCSIInterface then
    begin
      PostMessage(FFormHandle, WM_DriveSettings, wmwpDrvSetSCSIChange, 0);
    end;
    {cygwin1.dll}
    if FUseOwnDLLOld <> FSettings.FileFlags.UseOwnDLLs then
    begin
      SetUseOwnCygwinDLLs(FSettings.FileFlags.UseOwnDLLs);
    end;
    ModalResult := mrOK;
  end;
end;

{ Save settings to registry }

procedure TFormSettings.ButtonSettingsSaveClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    FSettings.SaveToFile(cIniFile);
    ShowMessage(FLang.GMS('mpref05'));
  end;
end;

{ Delete settings from registry }

procedure TFormSettings.ButtonSettingsDeleteClick(Sender: TObject);
begin
  FSettings.DeleteIniFile;
  ShowMessage(FLang.GMS('mpref06'));
end;

{ Delete additional commandline options }

procedure TFormSettings.ButtonCustOptDeleteClick(Sender: TObject);
var i: Integer;
    ComboBox: TComboBox;
begin
  if (Sender as TButton) = ButtonCdrecordCustOptDelete then
  begin
    ComboBox := ComboBoxCdrecordCustOpts;
  end else
  begin
    ComboBox := ComboBoxMkisofsCustOpts;
  end;
  for i := 0 to ComboBox.Items.Count -1 do
  begin
    if ComboBox.Text = ComboBox.Items[i] then
    begin
      ComboBox.Items.Delete(i);
    end;
  end;
  ComboBox.Text := '';
end;

{ Select Temp Folder }

procedure TFormSettings.ButtonTempFolderBrowseClick(Sender: TObject);
var Dir: string;
begin
  Dir := ChooseDir(FLang.GMS('g002'), Self.Handle);
  EditTempFolder.Text := Dir;
  EditTempFolderExit(EditTempFolder)
end;


{ Form-Events ---------------------------------------------------------------- }

{ OnFormShow -------------------------------------------------------------------

  Wenn das Fenster gezeigt wird, müssen die Controls den Daten in FSettings
  entsprechend gesetzt werden.                                                 }

procedure TFormSettings.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
  StaticText5.Caption := FLang.GMS('m302');
  FShellExtIsSet := ShellExtensionsRegistered;
  GetSettings;
  CheckControls(Sender);
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.

  Diese Prozedur wird auch für das OnClick-Event der Radio-Buttuns verwendet.  }

procedure TFormSettings.CheckBoxClick(Sender: TObject);
begin
  CheckControls(Sender);
end;


{ TrackBar-Events ------------------------------------------------------------ }

{ OnChange ---------------------------------------------------------------------

  Nach einer Änderung der Zeigerposition muß auch das Label angepaßt werden.   }

procedure TFormSettings.TrackBarFIFOSizeChange(Sender: TObject);
begin
  LabelFIFOSize.Caption := IntToStr(TrackBarFIFOSize.Position) + ' MiByte';
end;


{ ComboBox-Events ------------------------------------------------------------ }

{ OnKeyPress -------------------------------------------------------------------

  Die Combo-Boxes sollen auf ENTER reagieren. Auch für Edits.                  }

procedure TFormSettings.ComboBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = EnterKey then
  begin
    Key := NoKey;
    if (Sender is TComboBox) then
    begin
      if (Sender as TComboBox) = ComboBoxCdrecordCustOpts then
      begin
        CheckBoxMkisofsCustOpts.SetFocus;
      end else
      if (Sender as TComboBox) = ComboBoxMkisofsCustOpts then
      begin
        ButtonOk.SetFocus;
      end;
    end else
    if (Sender is TEdit) then
    begin
      if (Sender as TEdit) = EditTempFolder then
      begin
        ButtonOk.SetFocus;
      end;
    end;
  end;
end;

{ OnExit -----------------------------------------------------------------------

  Wenn die Combo-Box den Eingabe-Fokus verliert, soll die Eingabe in der Item-
  List gespeichert werden, sofern er noch nicht vorhanden ist.                 }

procedure TFormSettings.ComboBoxExit(Sender: TObject);
var i: Integer;
    Ok: Boolean;
    ComboBox: TComboBox;
begin
  Ok := True;
  ComboBox := Sender as TComboBox;
  {Ist die aktuelle Eingabe schon vorhanden?}
  for i := 0 to ComboBox.Items.Count -1 do
  begin
    if ComboBox.Items[i] = ComboBox.Text then
    begin
      Ok := False;
      ComboBox.ItemIndex := i;
    end;
  end;
  {Ist die Eingabe leer?}
  if ComboBox.Text = '' then
  begin
    Ok := False;
  end;
  {Wenn alle Test in Ordnung, dann einfügen und ItemIndex entsprechend setzen}
  if ok then
  begin
    ComboBox.Items.Add(ComboBox.Text);
    ComboBox.ItemIndex := ComboBox.Items.Count - 1;
  end;
end;

{ Edit-Events ---------------------------------------------------------------- }

{ OnExit -----------------------------------------------------------------------

  Wir wollen Pfadangaben ohne Pfadtrenner am Ende und existierende Dateinamen. }

procedure TFormSettings.EditTempFolderExit(Sender: TObject);
var Text: string;
begin
  Text := (Sender as TEdit).Text;
  if LastDelimiter('\', Text) = Length(Text) then Delete(Text, Length(Text), 1);
  if DirectoryExists(Text) then
    (Sender as TEdit).Text := Text else
    (Sender as TEdit).Text := '';
end;

initialization

end.
