{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  frm_datacd_options.pas: Daten-CD: Optionen, DVD-Video: Image-Optionen

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  16.10.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_datacd_options;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  {eigene Klassendefinitionen/Units}
  cl_settings, cl_lang;

type
  TFormDataCDOptions = class(TForm)
    GroupBoxCD: TGroupBox;
    GroupBoxWritingMode: TGroupBox;
    CheckBoxMulti: TCheckBox;
    CheckBoxContinue: TCheckBox;
    RadioButtonTAO: TRadioButton;
    RadioButtonDAO: TRadioButton;
    RadioButtonRAW: TRadioButton;
    Panel1: TPanel;
    RadioButtonRaw96r: TRadioButton;
    RadioButtonRaw96p: TRadioButton;
    RadioButtonRaw16: TRadioButton;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    GroupBoxImage: TGroupBox;
    RadioButtonImage: TRadioButton;
    RadioButtonOnTheFly: TRadioButton;
    EditIsoPath: TEdit;
    ButtonImageSelect: TButton;
    CheckBoxImageOnly: TCheckBox;
    CheckBoxImageKeep: TCheckBox;
    SaveDialog1: TSaveDialog;
    CheckBoxOverburn: TCheckBox;
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure ButtonImageSelectClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FSettings: TSettings;
    FLang: TLang;
    FDVDOptions: Boolean;
    function InputOk: Boolean;
    procedure CheckControls(Sender: TObject);
    procedure GetSettings;
    procedure SetSettings;    
  public
    { Public declarations }
    property Lang: TLang read FLang write FLang;
    property Settings: TSettings read FSettings write FSettings;
    property DVDOptions: Boolean read FDVDOptions write FDVDOptions;    
  end;

{ var }

implementation

{$R *.DFM}

uses constant, f_misc;

{var}

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormDataCDOptions.InputOk: Boolean;
begin
  Result := True;
  if RadioButtonImage.Checked and (EditIsoPath.Text = '') then
  begin
    // Fehlermeldung := 'Name für die Image-Datei fehlt!';
    Application.MessageBox(PChar(FLang.GMS('e101')), PChar(FLang.GMS('g001')),
      MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);
    Result := False;
  end;
end;

{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormDataCDOptions.GetSettings;
begin
  if not FDVDOptions then
  begin
    if FSettings.FileFlags.ShNeeded and not FSettings.FileFlags.ShOk then
    begin
      FSettings.DataCD.OnTheFly := False;
      RadioButtonOnTheFly.Enabled := False;
    end;
    with FSettings.DataCD do
    begin
      CheckBoxMulti.Checked     := Multi;
      CheckBoxContinue.Checked  := ContinueCD;
      CheckBoxImageOnly.Checked := ImageOnly;
      CheckBoxImageKeep.Checked := KeepImage;
      EditIsoPath.Text          := IsoPath;
      if OnTheFly then
      begin
        RadioButtonOnTheFly.Checked := True;
      end else
      begin
        RadioButtonImage.Checked := True;
      end;
      RadioButtonTAO.Checked    := TAO;
      RadioButtonDAO.Checked    := DAO;
      RadioButtonRAW.Checked    := RAW;
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
  end else
  begin
    if FSettings.FileFlags.ShNeeded and not FSettings.FileFlags.ShOk then
    begin
      FSettings.DVDVideo.OnTheFly := False;
      RadioButtonOnTheFly.Enabled := False;
    end;
    with FSettings.DVDVideo do
    begin
      CheckBoxImageOnly.Checked := ImageOnly;
      CheckBoxImageKeep.Checked := KeepImage;
      EditIsoPath.Text          := IsoPath;
      if OnTheFly then
      begin
        RadioButtonOnTheFly.Checked := True;
      end else
      begin
        RadioButtonImage.Checked := True;
      end;
    end;
  end;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormDataCDOptions.SetSettings;
begin
  if not FDVDOptions then
  begin
    with FSettings.DataCD do
    begin
      Multi      := CheckBoxMulti.Checked;
      ContinueCD := CheckBoxContinue.Checked;
      ImageOnly  := CheckBoxImageOnly.Checked;
      KeepImage  := CheckBoxImageKeep.Checked;
      IsoPath    := EditIsoPath.Text;
      OnTheFly   := RadioButtonOnTheFly.Checked;
      TAO        := RadioButtonTAO.Checked;
      DAO        := RadioButtonDAO.Checked;
      RAW        := RadioButtonRAW.Checked;
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
      {wenn Multisession, dann muß auch Rockridge aktiviert werden}
      if Multi then
      begin
        RockRidge := True;
      end;
    end;
  end else
  begin
    with FSettings.DVDVideo do
    begin
      ImageOnly  := CheckBoxImageOnly.Checked;
      KeepImage  := CheckBoxImageKeep.Checked;
      IsoPath    := EditIsoPath.Text;
      OnTheFly   := RadioButtonOnTheFly.Checked;
    end;
  end;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormDataCDOptions.CheckControls(Sender: TObject);
begin
  {Multisession-Optionen}
  if CheckBoxMulti.Checked then
  begin
    CheckBoxContinue.Enabled := True;
  end else
  begin
    CheckBoxContinue.Enabled := False;
  end;
  {Image oder otf}
  if RadioButtonImage.Checked then
  begin
    EditIsoPath.Enabled := True;
    ButtonImageSelect.Enabled := True;
    CheckBoxImageOnly.Enabled := True;
    CheckBoxImageKeep.Enabled := True;
  end else
  begin
    EditIsoPath.Enabled := False;
    ButtonImageSelect.Enabled := False;
    CheckBoxImageOnly.Enabled := False;
    CheckBoxImageKeep.Enabled := False;
  end;
  {nur Image erstellen/Image behalten}
  if Sender is TCheckBox then
  begin
    if (Sender as TCheckBox) = CheckBoxImageOnly then
    begin
      if CheckBoxImageOnly.Checked then
      begin
        CheckBoxImageKeep.Checked := False;
      end;
    end;
    if (Sender as TCheckBox) = CheckBoxImageKeep then
    begin
      if CheckBoxImageKeep.Checked then
      begin
        CheckBoxImageOnly.Checked := False;
      end;
    end;
  end;
  {Schreibmodus}
  if RadioButtonTAO.Checked then
  begin
    CheckBoxOverburn.Enabled := False;
  end else
  begin
    CheckBoxOverburn.Enabled := True;
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
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormDataCDOptions.ButtonOkClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    ModalResult := mrOK;
  end;
end;

{ Select image }

procedure TFormDataCDOptions.ButtonImageSelectClick(Sender: TObject);
begin
  SaveDialog1 := TSaveDialog.Create(self);
  SaveDialog1.Title := FLang.GMS('m102');
  SaveDialog1.DefaultExt := 'iso';
  SaveDialog1.Filter := FLang.GMS('f002');
  SaveDialog1.Options := [ofOverwritePrompt, ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    EditIsoPath.Text := SaveDialog1.FileName;
  end;
  SaveDialog1.Free;
end;


{ Form-Events ---------------------------------------------------------------- }

{ OnCreate ---------------------------------------------------------------------

  Standardmäßig soll dies der Daten-CD-Dialog sein.                            }

procedure TFormDataCDOptions.FormCreate(Sender: TObject);
begin
  FDVDOptions := False;
end;  

{ OnFormShow -------------------------------------------------------------------

  Wenn das Fenster gezeigt wird, müssen die Controls den Daten in FSettings
  entsprechend gesetzt werden.                                                 }

procedure TFormDataCDOptions.FormShow(Sender: TObject);
var Diff: Integer;
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
  GetSettings;
  CheckControls(Sender);
  {Falls DVD-Optionen, Fenster anpassen}
  if FDVDOptions then
  begin
    GroupBoxCD.Visible := not FDVDOptions;
    GroupBoxWritingMode.Visible := not FDVDOptions;
    Diff := (GroupBoxWritingMode.Left + GroupBoxWritingMode.Width) -
            (GroupBoxImage.Left + GroupBoxImage.Width);
    ButtonOk.Left := ButtonOk.Left - Diff;
    ButtonCancel.Left := ButtonCancel.Left - Diff;
    Self.Width := Self.Width - Diff;
    Self.Caption := FLang.GMS('c201');
  end;
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.

  Diese Prozedur wird auch für das OnClick-Event der Radio-Buttuns verwendet.  }

procedure TFormDataCDOptions.CheckBoxClick(Sender: TObject);
begin
  CheckControls(Sender);
end;

{ OnKeyPress -------------------------------------------------------------------

  ENTER soll bei Edit- und Comboxen zum nächsten Control weiterschalten.       }
  
procedure TFormDataCDOptions.EditKeyPress(Sender: TObject;
                                          var Key: Char);
var C: TControl;
begin
  C := Sender as TControl;
  if Key = EnterKey then
  begin
    Key := NoKey;
    if C = EditIsoPath then
    begin
      CheckBoxImageOnly.SetFocus;
    end;
  end;
end;

initialization

end.

