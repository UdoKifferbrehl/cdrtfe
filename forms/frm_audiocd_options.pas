{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  frm_audiocd_options.pas: Audio-CD: Optionen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  10.01.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_audiocd_options;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, ExtCtrls,
     {eigene Klassendefinitionen/Units}
     cl_settings, cl_lang, c_frametopbanner;

type
  TFormAudioCDOptions = class(TForm)
    GroupBoxCD: TGroupBox;
    GroupBoxWritingMode: TGroupBox;
    RadioButtonTAO: TRadioButton;
    RadioButtonDAO: TRadioButton;
    RadioButtonRAW: TRadioButton;
    Panel1: TPanel;
    RadioButtonRaw96r: TRadioButton;
    RadioButtonRaw96p: TRadioButton;
    RadioButtonRaw16: TRadioButton;
    CheckBoxOverburn: TCheckBox;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    GroupBox1: TGroupBox;
    CheckBoxPreemphasis: TCheckBox;
    CheckBoxUseInfo: TCheckBox;
    GroupBoxCopy: TGroupBox;
    RadioButtonNoCopy: TRadioButton;
    RadioButtonCopy: TRadioButton;
    RadioButtonSCMS: TRadioButton;
    CheckBoxFix: TCheckBox;
    CheckBoxMulti: TCheckBox;
    CheckBoxCDText: TCheckBox;
    FrameTopBanner1: TFrameTopBanner;
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
  private
    { Private declarations }
    FSettings: TSettings;
    FLang: TLang;
    function InputOk: Boolean;
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

uses f_window;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormAudioCDOptions.InputOk: Boolean;
begin
  Result := True;
  (* wird momentan nicht benötigt *)
end;


{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormAudioCDOptions.GetSettings;
begin
  with FSettings.AudioCD do
  begin
    CheckBoxFix.Checked         := Fix;
    CheckboxMulti.Checked       := Multi;
    CheckBoxPreemphasis.Checked := Preemp;
    CheckBoxUseInfo.Checked     := UseInfo;
    CheckBoxCDText.Checked      := CDText;
    RadioButtonTAO.Checked      := TAO;
    RadioButtonDAO.Checked      := DAO;
    RadioButtonRAW.Checked      := RAW;
    RadioButtonNoCopy.Checked   := not (Copy or SCMS); // Standard: 1 Kopie
    RadioButtonCopy.Checked     := Copy;
    RadioButtonSCMS.Checked     := SCMS;
    if RawMode = 'raw96r' then
    begin
      RadioButtonRaw96r.Checked := True;
    end else
    if RawMode = 'raw96p' then
    begin
      RadioButtonRaw96p.Checked := True;
    end else
    if RawMode = 'raw16' then
    begin
      RadioButtonRaw16.Checked := True;
    end;
    CheckBoxOverburn.Checked := Overburn;
  end;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormAudioCDOptions.SetSettings;
begin
  with FSettings.AudioCD do
  begin
    Fix     := CheckBoxFix.Checked;
    Multi   := CheckBoxMulti.Checked;
    Preemp  := CheckBoxPreemphasis.Checked;
    UseInfo := CheckBoxUseInfo.Checked;
    CDText  := CheckBoxCDText.Checked;
    TAO     := RadioButtonTAO.Checked;
    DAO     := RadioButtonDAO.Checked;
    RAW     := RadioButtonRAW.Checked;
    Copy    := RadioButtonCopy.Checked;
    SCMS    := RadioButtonSCMS.Checked;
    if RadioButtonRaw96r.Checked then
    begin
      RawMode := 'raw96r';
    end else
    if RadioButtonRaw96p.Checked then
    begin
      RawMode := 'raw96p';
    end else
    if  RadioButtonRaw16.Checked then
    begin
      RawMode := 'raw16';
    end;
    OverBurn := CheckBoxOverburn.Checked;
  end;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormAudioCDOptions.CheckControls(Sender: TObject);
begin
  {Schreibmodus}
  if RadioButtonTAO.Checked then
  begin
    CheckBoxOverburn.Enabled := False;
    CheckBoxCDText.Enabled := False;
  end else
  begin
    CheckBoxOverburn.Enabled := True;
    CheckBoxCDText.Enabled := True;
  end;
  if RadioButtonRAW.Checked then
  begin
    RadioButtonRaw96r.Enabled := True;
    RadioButtonRaw96p.Enabled := True;
    RadioButtonRaw16.Enabled := True;
  end else
  begin
    RadioButtonRaw96r.Enabled := False;
    RadioButtonRaw96p.Enabled := False;
    RadioButtonRaw16.Enabled := False;
  end;
  if not CheckBoxFix.Checked then
  begin
    CheckBoxMulti.Checked := False;
    CheckBoxMulti.Enabled := False;
  end else
    CheckBoxMulti.Enabled := True;
  begin
  end;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormAudioCDOptions.ButtonOkClick(Sender: TObject);
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

procedure TFormAudioCDOptions.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);  
  FrameTopBanner1.Init(Self.Caption, FLang.GMS('desc04'), 'grad1');
  GetSettings;
  CheckControls(Sender);
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.

  Diese Prozedur wird auch für das OnClick-Event der Radio-Buttuns verwendet.  }

procedure TFormAudioCDOptions.RadioButtonClick(Sender: TObject);
begin
  CheckControls(Sender);
end;

end.
