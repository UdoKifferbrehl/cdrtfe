{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_audiocd_tracks.pas: Audio-CD: Track-Eigenschaften

  Copyright (c) 2004-2009 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  29.12.2009

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
     cl_projectdata, cl_settings, cl_lang, f_largeint, c_frametopbanner;

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
    FrameTopBanner1: TFrameTopBanner;
    LabelCDTextRemaining: TLabel;
    LabelRemainingChars: TLabel;
    procedure ButtonOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure GridTextDataKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ExitTabSpecial(Sender: TObject);
    procedure GridTextDataEnter(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure GridTextDataKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GridTextDataDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
    FData: TProjectData;
    FSettings: TSettings;
    FLang: TLang;
    FTrackCount: Integer;
    function InputOk: Boolean;
    procedure CheckCDText;
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

var PreviousControl: TObject;

{ InputOk ----------------------------------------------------------------------

  InputOk überprüft die Eingaben auf Gültigkeit bzw. ob alle nötigen Infos
  vorhanden sind.                                                              }

function TFormAudioCDTracks.InputOk: Boolean;
begin
  Result := True;
  {Eingabe für Pausenlänge überprüfen}
  if StrToIntDef(EditPause.Text, -1) = -1 then
  begin
    ShowMsgDlg(FLang.GMS('epause01'), FLang.GMS('g001'), MB_cdrtfe2);
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
    DummyL: Int64;
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
    CheckCDText;
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

{ CheckCDText ------------------------------------------------------------------

  prüft die Anzahl der verbleibenden Zeichen.                                  }

procedure TFormAudioCDTracks.CheckCDText;
var CharRemain: Integer;
    CharUsed  : Integer;
    CharMax   : Integer;
    i         : Integer;
    L         : array[0..5] of Integer;
//  TrackData : TCDTextTrackData;
begin
  CharUsed := 0;
  CharMax  := 3024;
         (*
  if EditAlbumTitle.Text <> '' then
    CharUsed := CharUsed + Length(EditAlbumTitle.Text) + 1;
  if EditAlbumPerformer.Text <> '' then
    CharUsed := CharUsed +Length(EditAlbumTitle.Text) + 1;

  for i := 0 to FTrackCount - 1 do
  begin
    {Title}
    Temp := GridTextData.Cells[1, i + 1];
    if Temp <> '' then CharUsed := CharUsed + Length(Temp) + 1;
    {Performer}
    Temp := GridTextData.Cells[2, i + 1];
    if Temp <> '' then CharUsed := CharUsed + Length(Temp) + 1;
  end; *)
      
  for i := 0 to 5 do L[i] := 0;
  for i := -1 to FTrackCount - 1 do
  begin
    // FData.GetCDText(i, TrackData);
    if i = -1 then
    begin
      L[0] := L[0] + Length(EditAlbumTitle.Text) + 1;
      L[1] := L[1] + Length(EditAlbumPerformer.Text) + 1;
    end else
    begin 
      L[0] := L[0] + Length(GridTextData.Cells[1, i + 1]) + 1;
      L[1] := L[1] + Length(GridTextData.Cells[2, i + 1]) + 1; (*
      with TrackData do
      begin      
        L[2] := L[2] + Length(Songwriter) + 1;
        L[3] := L[3] + Length(Composer) + 1;
        L[4] := L[4] + Length(Arranger) + 1;
        L[5] := L[5] + Length(TextMessage) + 1;              
      end;                                                   *)
    end;
  end;
  for i := 0 to 5 do
  begin
    {wenn für einen Pack-Type keine Daten vorhanden sind, Länge auf Null setzen}
    if L[i] = FTrackCount + 1 then L[i] := 0;
    {Auffüllen des letzten Packs berücksichtigen}
    if L[i] > 0 then
    begin
      CharUsed := CharUsed + (L[i] div 12) * 12;
      if L[i] mod 12 > 0 then CharUsed := CharUsed + 12;
    end;
  end;
  CharRemain := CharMax - CharUsed;
  if CharRemain < 0 then LabelRemainingChars.Font.Color := clRed else
    LabelRemainingChars.Font.Color := clWindowText;
  
  LabelRemainingChars.Caption := IntToStr(CharRemain) + '/' + IntToStr(CharMax);

//  LabelCDTextRemaining.Caption := 'Zeichen: (' + IntToStr(FData.CDTextLength) 
//   + ')[' + IntToStr(CharUsed) + ']';
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
  FrameTopBanner1.Init(Self.Caption, FLang.GMS('desc05'), 'grad1');
  GetSettings;
  CheckControls(Sender);
  CheckCDText;
end;


{ Edit-Events ---------------------------------------------------------------- }

{ OnChange ---------------------------------------------------------------------

  Texteingabe in die Editfelder.                                               }

procedure TFormAudioCDTracks.EditChange(Sender: TObject);
begin
  CheckCDText;
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

{ StringGrid-Events ---------------------------------------------------------- }

{ OnKeyDown --------------------------------------------------------------------

  bei F3 sollen die Zelleninhalte Titel und Interpret vertauscht werden. Zu-
  sätzllich Tab-Navigation aus dem StringGrid heraus ermöglichen.              }

procedure TFormAudioCDTracks.GridTextDataKeyDown(Sender: TObject; var Key: Word;
                                                 Shift: TShiftState);
var Title,
    Performer: string;
    Row      : Integer;
    Grid     : TStringGrid;
begin
  case Key of
    VK_F3 : begin
              Row := GridTextData.Row;
              Title := GridTextData.Cells[1, Row];
              Performer := GridTextData.Cells[2, Row];
              GridTextData.Cells[1, Row] := Performer;
              GridTextData.Cells[2, Row] := Title;
            end;
    VK_F4 : begin
              Row := GridTextData.Row;
              if (GridTextData.ColCount > 1) and
                 (GridTextData.Cells[2, Row] <> '') and
                 not CheckBoxSampler.Checked then
                EditAlbumPerformer.Text := GridTextData.Cells[2, Row];               
            end;
    VK_F5 : begin
              if ssShift in Shift then             
                for Row := 1 to GridTextData.RowCount - 1 do
                  GridTextData.Cells[2, Row] := '';
            end;
    VK_TAB: begin
              Grid := Sender as TStringGrid;
              if not (ssShift in Shift) then
              begin
                if (Grid.Col = Grid.ColCount - 1) and
                   (Grid.Row = Grid.RowCount - 1) then
                begin
                  Key := 0;
                  Self.Perform(WM_NEXTDLGCTL, 0, 0);
                end;
              end else
              begin
                if (Grid.Col = 1) and
                   (Grid.Row = 1) then
                begin
                  Key := 0;
                  Self.Perform(WM_NEXTDLGCTL, 1, 0);
                end;
              end;
            end;
    VK_ESCAPE: Close;
  end;
end;

{ OnKeyUp ----------------------------------------------------------------------

  nach jedem Tastendruck muß die Lönge des CD-Textes ermittelt werden.         }

procedure TFormAudioCDTracks.GridTextDataKeyUp(Sender: TObject; var Key: Word;
                                               Shift: TShiftState);
begin
  CheckCDText;
end;

{ OnDrawCell -------------------------------------------------------------------

  überlange Einträge markieren.                                                }

procedure TFormAudioCDTracks.GridTextDataDrawCell(Sender: TObject; ACol,
                             ARow: Integer; Rect: TRect; State: TGridDrawState);
begin    
  if (ACol > 0) and (ARow > 0) and
     (Length((Sender as TStringGrid).Cells[ACol, ARow]) > 159) then
  begin
    (Sender as TStringGrid).Canvas.Font.Color := clRed;
    (Sender as TStringGrid).Canvas.FillRect(Rect);
    (Sender as TStringGrid).Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, 
                                     (Sender as TStringGrid).Cells[ACol, ARow]); 
  end;
           
end;


{ Workaround für eine bessere Keyboard-Navigation ---------------------------- }

{ OnExit -----------------------------------------------------------------------

  merkt sich die letzte Komponente.                                            }

procedure TFormAudioCDTracks.ExitTabSpecial(Sender: TObject);
begin
  PreviousControl := Sender;
end;

{ OnEnter ----------------------------------------------------------------------

  markiert die erste bzw. letze Zelle des StringGrids.                         }

procedure TFormAudioCDTracks.GridTextDataEnter(Sender: TObject);
var Sel: TGridRect;
begin
  if PreviousControl is TCheckBox then
  begin
    if ((PreviousControl as TCheckBox) = CheckBoxSampler) then
    begin
      Sel.Left := 1;
      Sel.Top := 1;
      Sel.Right := 1;
      Sel.Bottom := 1;
      GridTextData.Selection := Sel;
    end;
  end else
  if PreviousControl is TRadioButton then
  begin
    if ((PreviousControl as TRadioButton) = RadioButtonNoPause) or
       ((PreviousControl as TRadioButton) = RadioButtonPause) or
       ((PreviousControl as TRadioButton) = RadioButtonUserdefinedPause) then
    begin
      Sel.Left := GridTextData.ColCount - 1;
      Sel.Top := GridTextData.RowCount - 1;
      Sel.Right := GridTextData.ColCount - 1;
      Sel.Bottom := GridTextData.RowCount - 1;
      GridTextData.Selection := Sel;
    end;
  end;
end;

end.
