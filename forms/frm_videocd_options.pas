{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_videocd_options.pas: Video-CD: Optionen

  Copyright (c) 2005-2008 Oliver Valencia

  letzte Änderung  09.11.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_videocd_options;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {eigene Klassendefinitionen/Units}
  cl_settings, cl_lang;

type
  TFormVideoCDOptions = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    SaveDialog1: TSaveDialog;
    GroupBoxImage: TGroupBox;
    EditIsoPath: TEdit;
    ButtonImageSelect: TButton;
    CheckBoxImageOnly: TCheckBox;
    CheckBoxImageKeep: TCheckBox;
    GroupBoxVCDType: TGroupBox;
    RadioButtonVCD1: TRadioButton;
    RadioButtonVCD2: TRadioButton;
    RadioButtonSVCD: TRadioButton;
    CheckBoxOverBurn: TCheckBox;
    CheckBoxSVCDCompat: TCheckBox;
    CheckBoxSec2336: TCheckBox;
    CheckBoxVerbose: TCheckBox;
    procedure ButtonOkClick(Sender: TObject);
    procedure ButtonImageSelectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
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

uses f_misc, f_foldernamecache, constant;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormVideoCDOptions.InputOk: Boolean;
begin
  Result := True;
  if EditIsoPath.Text = '' then
  begin
    {Name für die Image-Datei fehlt}
    ShowMsgDlg(FLang.GMS('e101'), FLang.GMS('g001'), MB_cdrtfe2);
    Result := False;
  end;
end;

{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormVideoCDOptions.GetSettings;
begin
  with FSettings.VideoCD do
  begin
    EditIsoPath.Text               := IsoPath;
    CheckBoxImageOnly.Checked      := ImageOnly;
    CheckBoxImageKeep.Checked      := KeepImage;
    RadioButtonVCD1.Checked        := VCD1;
    RadioButtonVCD2.Checked        := VCD2;
    RadioButtonSVCD.Checked        := SVCD;
    CheckBoxOverBurn.Checked       := Overburn;
    CheckBoxSVCDCompat.Checked     := SVCDCompat;
    CheckBoxSec2336.Checked        := Sec2336;
    CheckBoxVerbose.Checked        := Verbose;
  end;
  {falls cdrdao nicht vorhanden ist, kann nur ein Image erzeugt werden.}
  if not (FSettings.FileFlags.CdrdaoOk or
          FSettings.Cdrecord.CanWriteCueImage) then
  begin
    CheckBoxImageOnly.Checked := True;
    CheckBoxImageOnly.Enabled := False;
    CheckBoxImageKeep.Enabled := False;
    CheckBoxOverburn.Enabled := False;
  end;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormVideoCDOptions.SetSettings;
begin
  with FSettings.VideoCD do
  begin
    IsoPath        := EditIsoPath.Text;
    ImageOnly      := CheckBoxImageOnly.Checked;
    KeepImage      := CheckBoxImageKeep.Checked;
    VCD1           := RadioButtonVCD1.Checked;
    VCD2           := RadioButtonVCD2.Checked;
    SVCD           := RadioButtonSVCD.Checked;
    Overburn       := CheckBoxOverburn.Checked;
    SVCDCompat     := CheckBoxSVCDCompat.Checked;
    Sec2336        := CheckBoxSec2336.Checked;
    Verbose        := CheckBoxVerbose.Checked;
  end;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormVideoCDOptions.CheckControls(Sender: TObject);
begin
  if Sender is TCheckBox then
  begin
    {nur Image erstellen/Image behalten}
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
  if Sender is TRadioButton then
  begin
    if (Sender as TRadioButton) = RadioButtonSVCD then
    begin
      CheckBoxSVCDCompat.Enabled := True;
    end else
    begin
      CheckBoxSVCDCompat.Enabled := False;
    end;
  end;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormVideoCDOptions.ButtonOkClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    ModalResult := mrOK;
  end;
end;

{ SelectImage }

procedure TFormVideoCDOptions.ButtonImageSelectClick(Sender: TObject);
var DialogID: TDialogID;
begin
  DialogID := DIDVideoCDImage;
  SaveDialog1 := TSaveDialog.Create(self);
  SaveDialog1.Title := FLang.GMS('m102');
  SaveDialog1.DefaultExt := '';
  SaveDialog1.Filter := FLang.GMS('f003');
  SaveDialog1.InitialDir := GetCachedFolderName(DialogID);
  SaveDialog1.Options := [ofOverwritePrompt, ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    EditIsoPath.Text := SaveDialog1.FileName;
    CacheFolderName(DialogID, SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;


{ Form-Events ---------------------------------------------------------------- }

{ OnFormShow -------------------------------------------------------------------

  Wenn das Fenster gezeigt wird, müssen die Controls den Daten in FSettings
  entsprechend gesetzt werden.                                                 }

procedure TFormVideoCDOptions.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
  GetSettings;
  CheckControls(Sender);
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.                                          }

procedure TFormVideoCDOptions.CheckBoxClick(Sender: TObject);
begin
  CheckControls(Sender);
end;

{ OnKeyPress -------------------------------------------------------------------

  ENTER soll bei Edit- und Comboxen zum nächsten Control weiterschalten.       }

procedure TFormVideoCDOptions.EditKeyPress(Sender: TObject;
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

end.
