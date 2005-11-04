{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  frm_audiocd_tracks.pas: Audio-CD: Track-Eigenschaften

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  26.09.2005

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

}

unit frm_audiocd_tracks;

{$I directives.inc}

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
     StdCtrls, Grids,
     {eigene Klassendefinitionen/Units}
     cl_projectdata, cl_settings, cl_lang;

type
  TFormAudioCDTracks = class(TForm)
    ButtonOk: TButton;
    ButtonCancel: TButton;
    GroupBoxCDText: TGroupBox;
    GridTextData: TStringGrid;
    EditAlbumTitle: TEdit;
    EditAlbumPerformer: TEdit;
    LabelAlbumTitle: TLabel;
    LabelAlbumPerformer: TLabel;
    CheckBoxSampler: TCheckBox;
    GroupBoxPause: TGroupBox;
    RadioButtonNoPause: TRadioButton;
    RadioButtonPause: TRadioButton;
    RadioButtonUserdefinedPause: TRadioButton;
    EditPause: TEdit;
    ComboBoxPause: TComboBox;
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FData: TProjectData;
    FSettings: TSettings;
    FLang: TLang;
    FTrackCount: Integer;
    function InputOk: Boolean;
    procedure CheckControls(Sender: TObject);
    procedure GetSettings;
    procedure SetGridTextData(const UserdefPause: Boolean);
    procedure SetSettings;
  public
    { Public declarations }
    property Data: TProjectData read FData write FData;
    property Lang: TLang read FLang write FLang;
    property Settings: TSettings read FSettings write FSettings;
  end;

{ var }


implementation

{$R *.DFM}

uses constant, f_cdtext, f_misc;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormAudioCDTracks.InputOk: Boolean;
begin
  Result := True;
  {Eingabe für Pausenlänge überprüfen}
  if StrToIntDef(EditPause.Text, -1) = -1 then
  begin
    Application.MessageBox(PChar(FLang.GMS('epause01')),
      PChar(FLang.GMS('g001')), MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL);  
    Result := False;
    EditPause.SetFocus;
    EditPause.SelectAll;
  end;
end;


{ InitStringGrid ---------------------------------------------------------------

  String-Grid initialisieren bzw. je nach Auswahl anpassen.                    }

procedure TFormAudioCDTracks.SetGridTextData(const UserdefPause: Boolean);
var i: Integer;
    ColPauseWidth: Integer;
{    DummyScrollBar: TScrollBar;
    ScrollBarWidth: Integer;}
begin
  with GridTextData do
  begin
    {Zeilen}
    RowCount := FTrackCount + 1;
    if RowCount = 1 then RowCount := 2;
    FixedRows := 1;

    {Bei benutzerdefinierten Pausen ist eine weitere Spalte nötig.}
    if UserdefPause then
    begin
      ColCount := 4;
      ColPauseWidth := 40;
    end else
    begin
      ColCount := 3;
      ColPauseWidth := 0;
    end;

    {Spaltenüberschriften}
    Cells[1, 0] := FLang.GMS('ccdtext01');
    Cells[2, 0] := FLang.GMS('ccdtext02');
    if UserdefPause then
    begin
      Cells[3, 0] := FLang.GMS('ccdtext03');
    end;
    for i := 1 to FTrackCount do
    begin
      Cells[0, i] := 'Track ' + IntToStr(i);
    end;

    {Spaltenbreite}
{    ScrollBarWidth := 0;
    if GridHeight > ClientHeight then
    begin
    end;}
    ColWidths[1] := (ClientWidth - 3 - ColPauseWidth -
                     {ScrollBarWidth -} ColWidths[0]) div 2;
    ColWidths[2] := ColWidths[1];
    if UserdefPause then
    begin
      ColWidths[3] := ColPauseWidth;
      {CD-Text-Daten}
      for i := 0 to FTrackCount - 1 do
      begin
        GridTextData.Cells[3, i + 1] := FData.GetTrackPause(i);
      end;
    end;
    DefaultRowHeight := EditAlbumTitle.Height;

  end;
end;

{ GetSettings ------------------------------------------------------------------

  GetSettings setzt die Controls des Fensters entsprechend den Daten in
  FSettings.                                                                   }

procedure TFormAudioCDTracks.GetSettings;
var i: Integer;
    DummyI, TrackCount: Integer;
    DummyL: {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
    DummyE: Extended;
    TrackData: TCDTextTrackData;
begin
  {Anzahl der Tracks bestimmen}
  FData.GetProjectInfo(DummyI, DummyI, DummyL, DummyE, TrackCount, cAudioCD);
  FTrackCount := TrackCount;
  {Stringgrid initialisieren}
  SetGridTextData(FSettings.AudioCD.Pause = 2);
  {CD-Text-Daten}
  for i := -1 to FTrackCount - 1 do
  begin
    FData.GetCDText(i, TrackData);
    if i = -1 then
    begin
      EditAlbumTitle.Text := TrackData.Title;
      EditAlbumPerformer.Text := TrackData.Performer;
      CheckBoxSampler.Checked := TrackData.Performer = 'Various';
    end else
    begin
      GridTextData.Cells[1, i + 1] := TrackData.Title;
      GridTextData.Cells[2, i + 1] := TrackData.Performer;
    end;
  end;

  with FSettings.AudioCD do
  begin
     RadioButtonNoPause.Checked := Pause = 0;
     RadioButtonPause.Checked := Pause = 1;
     RadioButtonUserdefinedPause.Checked := Pause = 2;
     EditPause.Text := PauseLength;
     if PauseSector then
     begin
       ComboBoxPause.ItemIndex := 1;
     end else
     begin
       ComboBoxPause.ItemIndex := 0;
     end;
  end;
end;

{ SetSettings ------------------------------------------------------------------

  SetSettings übernimmt die Einstellungen der Controls in FSettings.           }

procedure TFormAudioCDTracks.SetSettings;
var i: Integer;
    TrackData: TCDTextTrackData;
begin
  {CD-Text-Daten}
  for i := -1 to FTrackCount - 1 do
  begin
    {erst alle Daten holen}
    FData.GetCDText(i, TrackData);
    {jetzt die neuen setzen, ohne die alten zu verändern}
    if i = -1 then
    begin
      TrackData.Title     := EditAlbumTitle.Text;
      TrackData.Performer := EditAlbumPerformer.Text;
    end else
    begin
      TrackData.Title     := GridTextData.Cells[1, i + 1];
      TrackData.Performer := GridTextData.Cells[2, i + 1];
    end;
    FData.SetCDText(i, TrackData);
  end;

  {benutzerdefinierte Pausen}
  if RadioButtonUserdefinedPause.Checked then
  begin
    for i := 0 to FTrackCount - 1 do
    begin
      FData.SetTrackPause(i, GridTextData.Cells[3, i + 1])
    end;
  end;

  with FSettings.AudioCD do
  begin
     if RadioButtonNoPause.Checked then Pause := 0;
     if RadioButtonPause.Checked then Pause := 1;
     if RadioButtonUserdefinedPause.Checked then Pause := 2;
     PauseLength := EditPause.Text;
     PauseSector := ComboBoxPause.ItemIndex = 1;
  end;
end;

{ CheckControls ----------------------------------------------------------------

  CheckControls sorgt dafür, daß bei den Controls keine inkonsistenten
  Einstellungen vorkommen.                                                     }

procedure TFormAudioCDTracks.CheckControls(Sender: TObject);
begin
  if CheckBoxSampler.Checked then
  begin
    EditAlbumPerformer.Text := 'Various';
    EditAlbumPerformer.Enabled := False;
  end else
  begin
    EditAlbumPerformer.Enabled := True;
  end;
  EditPause.Enabled := RadioButtonPause.Checked;
  ComboBoxPause.Enabled := RadioButtonPause.Checked or
                           RadioButtonUserdefinedPause.Checked;
  if RadioButtonUserDefinedPause.Checked then
  begin
    SetGridTextData(True);
  end else
  begin
    SetGridTextData(False);
  end;
end;


{ Button-Events -------------------------------------------------------------- }

{ Ok }

procedure TFormAudioCDTracks.ButtonOkClick(Sender: TObject);
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

procedure TFormAudioCDTracks.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
  GetSettings;
  CheckControls(Sender);
end;


{ CheckBox-Events ------------------------------------------------------------ }

{ OnClick ----------------------------------------------------------------------

  Nach einen Klick auf eine Check-Box muß sichergestellt sein, daß die Controls
  in einem konsistenten Zustand sind.

  Diese Prozedur wird auch für das OnClick-Event der Radio-Buttuns verwendet.  }

procedure TFormAudioCDTracks.CheckBoxClick(Sender: TObject);
begin
  CheckControls(Sender);
end;

{ OnKeyPress -------------------------------------------------------------------

  ENTER soll bei Edit- und Comboxen zum nächsten Control weiterschalten.       }

procedure TFormAudioCDTracks.EditKeyPress(Sender: TObject;
                                          var Key: Char);
var C: TControl;
begin
  C := Sender as TControl;
  if Key = EnterKey then
  begin
    Key := NoKey;
    if C = EditAlbumTitle then
    begin
      EditAlbumPerformer.SetFocus;
    end else
    if C = EditAlbumPerformer then
    begin
      CheckBoxSampler.SetFocus;
    end else
    if C = EditPause then
    begin
      ComboBoxPause.SetFocus;
    end else
    if C = ComboBoxPause then
    begin
      ButtonOk.SetFocus;
    end;
  end;
end;


end.
