{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_dae_options.pas: DAE: Optionen

  Copyright (c) 2006-2015 Oliver Valencia

  letzte Änderung  30.11.2015

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_dae_options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {eigene Klassendefinitionen/Units}
  cl_settings, cl_lang, ComCtrls, c_frametopbanner;

type
  TFormDAEOptions = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    PageControlDAE: TPageControl;
    TabSheetDAE: TTabSheet;
    GroupBoxFileNames: TGroupBox;
    RadioButtonDAEUsePrefix: TRadioButton;
    RadioButtonDAEUseNamePattern: TRadioButton;
    EditDAEPrefix: TEdit;
    EditDAENamePattern: TEdit;
    GroupBoxOptions: TGroupBox;
    CheckBoxDAEBulk: TCheckBox;
    CheckBoxDAELibParanoia: TCheckBox;
    CheckBoxDAENoInfofiles: TCheckBox;
    TabSheetCDDB: TTabSheet;
    GroupBox1: TGroupBox;
    CheckBoxDAEUseCDDB: TCheckBox;
    EditDAECDDBServer: TEdit;
    EditDAECDDBPort: TEdit;
    LabelCDDBServer: TLabel;
    LabelCDDBPort: TLabel;
    GroupBoxDAEFormat: TGroupBox;
    RadioButtonDAEWav: TRadioButton;
    RadioButtonDAEMp3: TRadioButton;
    RadioButtonDAEOgg: TRadioButton;
    RadioButtonDAEFlac: TRadioButton;
    TabSheetCompression: TTabSheet;
    GroupBoxDAETags: TGroupBox;
    CheckBoxDAETags: TCheckBox;
    GroupBoxDAEFlac: TGroupBox;
    TrackBarFlac: TTrackBar;
    LabelDAEFlacCurQuality: TLabel;
    LabelDAEFlac1: TLabel;
    GroupBoxDAEOgg: TGroupBox;
    TrackBarOgg: TTrackBar;
    LabelDAEOggCurQuality: TLabel;
    LabelDAEOgg1: TLabel;
    GroupBoxDAEMp3: TGroupBox;
    ComboBoxDAEMp3Quality: TComboBox;
    RadioButtonDAECustom: TRadioButton;
    GroupBoxDAECustom: TGroupBox;
    EditCustomCmd: TEdit;
    EditCustomOpt: TEdit;
    LabelCustomCmd: TLabel;
    LabelCustomOpt: TLabel;
    CheckBoxDAEWriteCopy: TCheckBox;
    ComboBoxSpeedW: TComboBox;
    LabelSpeedW: TLabel;
    FrameTopBanner1: TFrameTopBanner;
    TabSheetParanoia: TTabSheet;
    GroupBox2: TGroupBox;
    CheckBoxDAEUseParaOpts: TCheckBox;
    RadioButtonDAEUseParanoiaPresetProof: TRadioButton;
    RadioButtonDAEUseParanoiaUserdefined: TRadioButton;
    CheckBoxDAEDisableParanoia: TCheckBox;
    CheckBoxDAEParanoiaC2check: TCheckBox;
    CheckBoxDAEParanoiaNoVerify: TCheckBox;
    EditDAEParaRetries: TEdit;
    EditDAEParaReadahead: TEdit;
    EditDAEParaOverlap: TEdit;
    EditDAEParaMinOverlap: TEdit;
    EditDAEParaMaxOverlap: TEdit;
    LabelDAEParaRetries: TLabel;
    LabelDAEParaReadahead: TLabel;
    LabelDAEParaOverlap: TLabel;
    LabelDAEParaMinOverlap: TLabel;
    LabelDAEParaMaxOverlap: TLabel;
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure TrackBarChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
  private
    { Private declarations }
    FSettings: TSettings;
    FLang: TLang;
    function GetActivePage: Byte;
    function InputOk: Boolean;
    procedure ActivateTab;
    procedure CheckControls(Sender: TObject);
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

uses f_window, const_common;

const DefaultSpeedList : string
                         = ',0,1,2,4,6,8,10,12,16,20,24,32,36,40,42,48,50,52';

{ ActivateTab ------------------------------------------------------------------

  ActivateTab zeigt das TabSheet an, das in FSettings.General.TabFrmSettings
  angegeben ist.                                                               }

procedure TFormDAEOptions.ActivateTab;
begin
   PageControlDAE.ActivePage :=
     PageControlDAE.Pages[FSettings.General.TabFrmDAE - 1];
end;

{ GetActivePage ----------------------------------------------------------------

  GetActivePage liefert als Ergebnis die Nummer der aktiven Registerkarte.     }

function TFormDAEOptions.GetActivePage: Byte;
begin
  Result := PageControlDAE.ActivePage.PageIndex + 1;
end;


{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormDAEOptions.InputOk: Boolean;
begin
  Result := True;

end;

{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormDAEOptions.GetSettings;
begin
  if FSettings.FileFlags.ShNeeded and not FSettings.FileFlags.ShOk then
  begin
    RadioButtonDAEMp3.Enabled := False;
    RadioButtonDAEOgg.Enabled := False;
    RadioButtonDAEFlac.Enabled := False;
    RadioButtonDAECustom.Enabled := False;
  end else
  begin
    RadioButtonDAEMp3.Enabled := FSettings.FileFlags.LameOk;
    RadioButtonDAEOgg.Enabled := FSettings.FileFlags.OggencOk;
    RadioButtonDAEFlac.Enabled := FSettings.FileFlags.FlacOk;
    RadioButtonDAECustom.Enabled := FileExists(FSettings.DAE.CustomCmd);
  end;
  with FSettings.DAE do
  begin
    CheckBoxDAEBulk.Checked              := Bulk;
    CheckBoxDAELibParanoia.Checked       := Paranoia;
    CheckBoxDAENoInfofiles.Checked       := NoInfoFile;
    CheckBoxDAEWriteCopy.Checked         := DoCopy;
    EditDAEPrefix.Text                   := Prefix;
    EditDAENamePattern.Text              := NamePattern;
    RadioButtonDAEUsePrefix.Checked      := PrefixNames;
    RadioButtonDAEUseNamePattern.Checked := not PrefixNames;
    CheckBoxDAEUseCDDB.Checked           := UseCDDB;
    EditDAECDDBServer.Text               := CDDBServer;
    EditDAECDDBPort.Text                 := CDDBPort;
    RadioButtonDAEMp3.Checked            := Mp3;
    RadioButtonDAEOgg.Checked            := Ogg;
    RadioButtonDAEFlac.Checked           := Flac;
    RadioButtonDAECustom.Checked         := Custom;
    RadioButtonDAEWav.Checked            := not (MP3 or Ogg or Flac or Custom);
    CheckBoxDAETags.Checked              := AddTags;
    TrackBarFlac.Position                := StrToIntDef(FlacQuality, 5);
    TrackBarOgg.Position                 := StrToIntDef(OggQuality, 6);
    EditCustomCmd.Text                   := CustomCmd;
    EditCustomOpt.Text                   := CustomOpt;                                        
    ComboBoxDAEMp3Quality.ItemIndex :=
                                ComboBoxDAEMp3Quality.Items.IndexOf(LamePreset);
    ComboBoxSpeedW.ItemIndex := ComboBoxSpeedW.Items.IndexOf(SpeedW);
    CheckBoxDAEUseParaOpts.Checked       := UseParaOpts;
    RadioButtonDAEUseParanoiaPresetProof.Checked := ParaProof;
    RadioButtonDAEUseParanoiaUserdefined.Checked := not ParaProof;
    CheckBoxDAEDisableParanoia.Checked   := ParaDisable;
    CheckBoxDAEParanoiaC2check.Checked   := ParaC2check;
    CheckBoxDAEParanoiaNoVerify.Checked  := ParaNoVerify;
    EditDAEParaRetries.Text              := ParaRetries;
    EditDAEParaReadahead.Text            := ParaReadahead;
    EditDAEParaOverlap.Text              := ParaOverlap;
    EditDAEParaMinOverlap.Text           := ParaMinoverlap;
    EditDAEParaMaxOverlap.Text           := ParaMaxoverlap;
  end;
  ActivateTab;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormDAEOptions.SetSettings;
begin
  with FSettings.DAE do
  begin
    Bulk        := CheckBoxDAEBulk.Checked;
    Paranoia    := CheckBoxDAELibParanoia.Checked;
    NoInfoFile  := CheckBoxDAENoInfofiles.Checked;
    DoCopy      := CheckBoxDAEWriteCopy.Checked;
    Prefix      := EditDAEPrefix.Text;
    NamePattern := EditDAENamePattern.Text;
    PrefixNames := RadioButtonDAEUsePrefix.Checked;
    UseCDDB     := CheckBoxDAEUseCDDB.Checked;
    CDDBServer  := EditDAECDDBServer.Text;
    CDDBPort    := EditDAECDDBPort.Text;
    MP3         := RadioButtonDAEMp3.Checked;
    Ogg         := RadioButtonDAEOgg.Checked;
    Flac        := RadioButtonDAEFlac.Checked;
    Custom      := RadioButtonDAECustom.Checked;
    AddTags     := CheckBoxDAETags.Checked;
    FlacQuality := IntToStr(TrackBarFLAC.Position);
    OggQuality  := IntToStr(TrackBarOgg.Position);
    CustomCmd   := EditCustomCmd.Text;
    CustomOpt   := EditCustomOpt.Text;
    LamePreset  := ComboBoxDAEMp3Quality.Items[ComboBoxDAEMp3Quality.ItemIndex];
    SpeedW      := ComboBoxSpeedW.Items[ComboBoxSpeedW.ItemIndex];
    UseParaOpts    := CheckBoxDAEUseParaOpts.Checked;
    ParaProof      := RadioButtonDAEUseParanoiaPresetProof.Checked;
    ParaDisable    := CheckBoxDAEDisableParanoia.Checked;
    ParaC2check    := CheckBoxDAEParanoiaC2check.Checked;
    ParaNoVerify   := CheckBoxDAEParanoiaNoVerify.Checked;
    ParaRetries    := EditDAEParaRetries.Text;
    ParaReadahead  := EditDAEParaReadahead.Text;
    ParaOverlap    := EditDAEParaOverlap.Text;
    ParaMinoverlap := EditDAEParaMinOverlap.Text;
    ParaMaxoverlap := EditDAEParaMaxOverlap.Text;
  end;
  FSettings.General.TabFrmDAE := GetActivePage;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormDAEOptions.CheckControls(Sender: TObject);
var Temp: Boolean;
begin
  EditDAEPrefix.Enabled := RadioButtonDAEUsePrefix.Checked;
  EditDAENamePattern.Enabled := RAdioButtonDAEUseNamePattern.Checked;
  EditDAECDDBServer.Enabled := CheckBoxDAEUseCDDB.Checked;
  EditDAECDDBPort.Enabled := CheckBoxDAEUseCDDB.Checked;
  Temp := CheckBoxDAEUseParaOpts.Checked;
  RadioButtonDAEUseParanoiaPresetProof.Enabled := Temp;
  RadioButtonDAEUseParanoiaUserdefined.Enabled := Temp;
  Temp := Temp and RadioButtonDAEUseParanoiaUserdefined.Checked;
  CheckBoxDAEDisableParanoia.Enabled := Temp;
  CheckBoxDAEParanoiaC2check.Enabled := Temp;
  CheckBoxDAEParanoiaNoVerify.Enabled := Temp;
  EditDAEParaRetries.Enabled := Temp;
  EditDAEParaReadahead.Enabled := Temp;
  EditDAEParaOverlap.Enabled := Temp;
  EditDAEParaMinOverlap.Enabled := Temp;
  EditDAEParaMaxOverlap.Enabled := Temp;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormDAEOptions.ButtonOkClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    ModalResult := mrOK;
  end;
end;


{ Form-Events ---------------------------------------------------------------- }

{ OnFormShow -------------------------------------------------------------------

  Wenn das Fenster gezeigt wird, müssen die Controls den Daten in FSettings
  entsprechend gesetzt werden.                                                 }

procedure TFormDAEOptions.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);  
  FrameTopBanner1.Init(Self.Caption, FLang.GMS('desc07'), 'grad1');
  ComboBoxDAEMp3Quality.Items.Assign(FSettings.General.Mp3Qualities);
  ComboBoxSpeedW.Items.CommaText := DefaultSpeedList;
  GetSettings;
  CheckControls(Sender);
  LabelDAEFlacCurQuality.Caption := IntToStr(TrackBarFlac.Position);
  LabelDAEOggCurQuality.Caption := IntToStr(TrackBarOgg.Position);
  LabelSpeedW.Caption := FLang.GMS('c001');
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.                                          }

procedure TFormDAEOptions.CheckBoxClick(Sender: TObject);
begin
  CheckControls(Sender);
end;

{ OnKeyPress -------------------------------------------------------------------

  ENTER soll bei Edit- und Comboxen zum nächsten Control weiterschalten.       }

procedure TFormDAEOptions.EditKeyPress(Sender: TObject;
                                           var Key: Char);
var C: TControl;
begin
  C := Sender as TControl;
  if Key = EnterKey then
  begin
    Key := NoKey;
    if (C = EditDAEPrefix) or (C = EditDAENamePattern) then
    begin
      CheckBoxDAEBulk.SetFocus;
    end else
    if C = EditDAECDDBServer then
    begin
      EditDAECDDBPort.SetFocus;
    end else
    if C = EditDAECDDBPort then
    begin
      ButtonOk.SetFocus;
    end else
    if C = EditCustomCmd then
    begin
      EditCustomOpt.SetFocus;
    end else
    if c= EditCustomOpt then
    begin
      ButtonOk.SetFocus;
    end;
  end;
end;


{ TrackBar-Events ------------------------------------------------------------ }

{ OnChange ---------------------------------------------------------------------

  Anzeige aktualisieren.                                                       }

procedure TFormDAEOptions.TrackBarChange(Sender: TObject);
begin
  if Sender as TTrackBar = TrackBarFLAC then
  begin
    LabelDAEFlacCurQuality.Caption := IntToStr(TrackBarFlac.Position);
  end else
  if Sender as TTrackBar = TrackBarOgg then
  begin
    LabelDAEOggCurQuality.Caption := IntToStr(TrackBarOgg.Position);
  end;
end;


{ Edit-Events ---------------------------------------------------------------- }

{ OnExit -----------------------------------------------------------------------

  Eingabe prüfen.                                                              }

procedure TFormDAEOptions.EditExit(Sender: TObject);
begin
  if Sender as TEdit = EditCustomCmd then
  begin
    if not FileExists((Sender as TEdit).Text) then
    begin
      (Sender as TEdit).Text := '';
      RadioButtonDAECustom.Enabled := False;
    end else
      RadioButtonDAECustom.Enabled := True;
  end;
end;

end.
