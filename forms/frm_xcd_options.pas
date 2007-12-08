{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_xcd_options.pas: XCD-CD: Optionen

  Copyright (c) 2004-2007 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  08.12.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_xcd_options;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {eigene Klassendefinitionen/Units}
  cl_settings, cl_lang;

type
  TFormXCDOptions = class(TForm)
    GroupBoxImage: TGroupBox;
    EditIsoPath: TEdit;
    ButtonImageSelect: TButton;
    CheckBoxImageOnly: TCheckBox;
    CheckBoxImageKeep: TCheckBox;
    GroupBoxISO: TGroupBox;
    RadioButtonISOLevelX: TRadioButton;
    RadioButtonISOLevel1: TRadioButton;
    RadioButtonISOLevel2: TRadioButton;
    SaveDialog1: TSaveDialog;
    CheckBoxSingle: TCheckBox;
    GroupBoxOptions: TGroupBox;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    CheckBoxKeepExt: TCheckBox;
    EditExt: TEdit;
    Label1: TLabel;
    CheckBoxOverburn: TCheckBox;
    GroupBoxInfoFile: TGroupBox;
    CheckBoxCreateInfoFile: TCheckBox;
    GroupBoxErrorProtection: TGroupBox;
    CheckBoxUseErrorProtection: TCheckBox;
    LabelSecCount: TLabel;
    EditSecCount: TEdit;
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

uses f_misc, constant;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormXCDOptions.InputOk: Boolean;
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

procedure TFormXCDOptions.GetSettings;
begin
  with FSettings.XCD do
  begin
    EditIsoPath.Text                   := IsoPath;
    CheckBoxImageOnly.Checked          := ImageOnly;
    CheckBoxImageKeep.Checked          := KeepImage;
    CheckBoxSingle.Checked             := Single;
    CheckBoxKeepExt.Checked            := KeepExt;
    EditExt.Text                       := Ext;
    RadioButtonISOLevelX.Checked       := not (ISOLevel1 or ISOLevel2);
    RadioButtonISOLevel1.Checked       := IsoLevel1;
    RadioButtonISOLevel2.Checked       := IsoLevel2;
    CheckBoxOverburn.Checked           := Overburn;
    CheckBoxCreateInfoFile.Checked     := CreateInfoFile;
    CheckBoxUseErrorProtection.Checked := UseErrorProtection;
    EditSecCount.Text                  := IntToStr(SecCount);
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

procedure TFormXCDOptions.SetSettings;
begin
  with FSettings.XCD do
  begin
    IsoPath            := EditIsoPath.Text;
    ImageOnly          := CheckBoxImageOnly.Checked;
    KeepImage          := CheckBoxImageKeep.Checked;
    Single             := CheckBoxSingle.Checked;
    KeepExt            := CheckBoxKeepExt.Checked;
    Ext                := EditExt.Text;
    IsoLevel1          := RadioButtonISOLevel1.Checked;
    IsoLevel2          := RadioButtonISOLevel2.Checked;
    OverBurn           := CheckBoxOverburn.Checked;
    CreateInfoFile     := CheckBoxCreateInfoFile.Checked;
    UseErrorProtection := CheckBoxUseErrorProtection.Checked;
    SecCount           := StrToIntDef(EditSecCount.Text, 3600);
  end;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormXCDOptions.CheckControls(Sender: TObject);
begin
  if Sender is TCheckBox then
  begin
    {Info-Datei nur ohne ISO-Level 1/2}
    if ((Sender as TCheckBox) = CheckBoxCreateInfoFile) or
       ((Sender as TCheckBox) = CheckBoxUseErrorProtection) then
    begin
      if CheckBoxCreateInfoFile.Checked or
         CheckBoxUseErrorProtection.Checked then
      begin
        RadioButtonIsoLevel1.Enabled := False;
        RadioButtonIsoLevel2.Enabled := False;
      end else
      if not (CheckBoxCreateInfoFile.Checked or
              CheckBoxUseErrorProtection.Checked) then
      begin
        RadioButtonIsoLevel1.Enabled := True;
        RadioButtonIsoLevel2.Enabled := True;
      end;
    end;
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
    {bei ISO-Level 1/2 keine Info-Datei und kein rrenc}
    if RadioButtonIsoLevel1.Checked or RadioButtonIsoLevel2.Checked then
    begin
      CheckBoxCreateInfoFile.Enabled := False;
      CheckBoxUseErrorProtection.Enabled := False;
    end else
    begin
      CheckBoxCreateInfoFile.Enabled := True;
      CheckBoxUseErrorProtection.Enabled := True;;
    end;
  end;
  {Ohne rrenc keine Fehlerkorrektur}
  if Sender is TForm then
  begin
    CheckBoxUseErrorProtection.Enabled := FSettings.FileFlags.RrencOk;
    EditSecCount.Enabled := FSettings.FileFlags.RrencOk;
  end;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormXCDOptions.ButtonOkClick(Sender: TObject);
begin
  if InputOk then
  begin
    SetSettings;
    ModalResult := mrOK;
  end;
end;

{ SelectImage }

procedure TFormXCDOptions.ButtonImageSelectClick(Sender: TObject);
begin
  SaveDialog1 := TSaveDialog.Create(self);
  SaveDialog1.Title := FLang.GMS('m102');
  SaveDialog1.DefaultExt := '';
  SaveDialog1.Filter := FLang.GMS('f003');
  SaveDialog1.Options := [ofOverwritePrompt, ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    EditIsoPath.Text := SaveDialog1.FileName;
  end;
  SaveDialog1.Free;
end;


{ Form-Events ---------------------------------------------------------------- }

{ OnFormShow -------------------------------------------------------------------

  Wenn das Fenster gezeigt wird, müssen die Controls den Daten in FSettings
  entsprechend gesetzt werden.                                                 }

procedure TFormXCDOptions.FormShow(Sender: TObject);
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

procedure TFormXCDOptions.CheckBoxClick(Sender: TObject);
begin
  CheckControls(Sender);
end;

{ OnKeyPress -------------------------------------------------------------------

  ENTER soll bei Edit- und Comboxen zum nächsten Control weiterschalten.       }

procedure TFormXCDOptions.EditKeyPress(Sender: TObject;
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
    end else
    if C = EditExt then
    begin
      ButtonOk.SetFocus;
    end;
  end;
end;

end.
