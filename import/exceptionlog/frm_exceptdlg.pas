{ frm_exceptdlg.pas:

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with the
  License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
  the specific language governing rights and limitations under the License.

  The Original Code is ExceptDlg.pas (included in the JCL).

  The Initial Developer of the Original Code is Petr Vones.
  Portions created by Petr Vones are Copyright (C) of Petr Vones.

  Contributors:
    Oliver Valencia

  ------------------------------------------------------------------------------

  Show call stack and other information when an exception occurs. Based on the
  JEDI Code Library (JCL).

  Last modified: 2010/06/11

}

unit frm_exceptdlg;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TExceptionDialog = class(TForm)
    TextLabel: TMemo;
    Bevel1: TBevel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    DetailsMemo: TMemo;
    TabSheet2: TTabSheet;
    ListView1: TListView;
    OkBtn: TButton;
    DetailsBtn: TButton;
    SaveBtn: TButton;
    SaveDialog1: TSaveDialog;
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure DetailsBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
  private
    { Private-Deklarationen }
    FErrorMessage    : string;
    FReport          : TStringList;
    FCallstackData   : TStringList;
    FDetailsVisible  : Boolean;
    FFullHeight      : Integer;
    FFullWidth       : Integer;
    FNonDetailsHeight: Integer;
    FNonDetailsWidth : Integer;
    FDefaultFileName : string;
    procedure SetErrorMessage(const Value: string);
    procedure SetDetailsVisible(const Value: Boolean);
    procedure ShowCallstackData;
    procedure UpdateTextLabelScrollbars;
    procedure CenterForm;
  public
    { Public-Deklarationen }
    property ErrorMessage: string write SetErrorMessage;
    property Report: TStringList write FReport;
    property CallstackData: TStringList write FCallstackData;
    property DetailsVisible: Boolean read FDetailsVisible write SetDetailsVisible;
    property DefaultFileName: string write FDefaultFileName;
  end;

var
  ExceptionDialog: TExceptionDialog;

implementation

{$R *.dfm}

uses JCLStrings, f_strings, f_window, f_filesystem;

{ TExceptionDialog - private }

{ SetErrorMessage --------------------------------------------------------------

  Fehlermeldung setzen und Scrollbalken anpassen.                              }

procedure TExceptionDialog.SetErrorMessage(const Value: string);
begin
  FErrorMessage := Value;
  TextLabel.Text := FErrorMessage;
  UpdateTextLabelScrollbars;
end;

{ SetDetailsVisible ------------------------------------------------------------

  Details ein-/ausschalten. Based ExceptDlg.pas by Petr Vones.                 }

procedure TExceptionDialog.SetDetailsVisible(const Value: Boolean);
var DetailsCaption: string;
begin
  FDetailsVisible := Value;
  DetailsCaption := Trim(StrRemoveChars(DetailsBtn.Caption, ['<', '>']));
  if Value then
  begin
    Constraints.MinHeight := FNonDetailsHeight + 100;
    Constraints.MaxHeight := Screen.Height;
    Constraints.MinWidth  := FNonDetailsWidth + 100;
    Constraints.MaxWidth  := Screen.Width;
    DetailsCaption := '<< ' + DetailsCaption;
    ClientHeight := FFullHeight;
    ClientWidth := FFullWidth;
    PageControl1.Height := FFullHeight - PageControl1.Top - 5;
  end else
  begin
    FFullHeight := ClientHeight;
    FFullWidth := ClientWidth;
    DetailsCaption := DetailsCaption + ' >>';
    if FNonDetailsHeight = 0 then
    begin
      ClientHeight := Bevel1.Top;
      FNonDetailsHeight := Height;
    end else
    begin
      Height := FNonDetailsHeight;
    end;
    if FNonDetailsWidth = 0 then
    begin
      ClientWidth := Bevel1.Left + Bevel1.Width;
      FNonDetailsWidth := Width;
    end else
    begin
      Width := FNonDetailsWidth;
    end;
    Constraints.MinHeight := FNonDetailsHeight;
    Constraints.MaxHeight := FNonDetailsHeight;
    Constraints.MinWidth := FNonDetailsWidth;
    Constraints.MaxWidth := FNonDetailsWidth;
  end;
  DetailsBtn.Caption := DetailsCaption;
  Bevel1.Visible := FDetailsVisible;
  CenterForm;
end;

{ CenterForm -------------------------------------------------------------------

  Dialogfenster zentrieren.                                                    }

procedure TExceptionDialog.CenterForm;
begin
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
end;

{ UpdateTextLabelScrollbars ----------------------------------------------------

  from ExceptDlg.pas by Petr Vones                                             }

procedure TExceptionDialog.UpdateTextLabelScrollbars;
begin
  Canvas.Font := TextLabel.Font;
  if TextLabel.Lines.Count * Canvas.TextHeight('Wg') > TextLabel.ClientHeight
                                                                            then
    TextLabel.ScrollBars := ssVertical
  else
    TextLabel.ScrollBars := ssNone;
end;

{ ShowCallstackData ------------------------------------------------------------

  die Call-Stack-Daten in den ListView eintragen.                              }

procedure TExceptionDialog.ShowCallstackData;
var i      : Integer;
    Temp, s: string;
    NewItem: TListItem;
begin
  for i := 0 to FCallstackData.Count - 1 do
  begin
    Temp := FCallstackData[i];
    NewItem := ListView1.Items.Add;
    SplitString(Temp, '|', s, Temp);
    NewItem.Caption := s;
    SplitString(Temp, '|', s, Temp);
    NewItem.SubItems.Add(s);
    SplitString(Temp, '|', s, Temp);
    NewItem.SubItems.Add(s);
    SplitString(Temp, '|', s, Temp);
    NewItem.SubItems.Add(s);
    SplitString(Temp, '|', s, Temp);
    NewItem.SubItems.Add(s);
    // SplitString(Temp, '|', s, Temp);
    NewItem.SubItems.Add(Temp);
  end;
end;


{ TExceptionDialog - Events -------------------------------------------------- }

{ FormPaint --------------------------------------------------------------------

  from ExceptDlg.pas by Petr Vones                                             }

procedure TExceptionDialog.FormPaint(Sender: TObject);
begin
  DrawIcon(Canvas.Handle, TextLabel.Left - GetSystemMetrics(SM_CXICON) - 15,
    TextLabel.Top, LoadIcon(0, IDI_ERROR));
end;

{ FormCreate -------------------------------------------------------------------

  Anzeigen initialisieren.                                                     }

procedure TExceptionDialog.FormCreate(Sender: TObject);
begin
  SetFont(Self);
  FFullHeight := ClientHeight;
  FFullWidth := ClientWidth;
  DetailsVisible := False;
end;

{ FormShow ---------------------------------------------------------------------

  Anzeigen initialisieren.                                                     }

procedure TExceptionDialog.FormShow(Sender: TObject);
begin
  DetailsMemo.Lines.Assign(FReport);
  ShowCallstackData;
  DetailsBtn.SetFocus;
end;

{ ListViewCustumDraw[Sub]Item --------------------------------------------------

  Spalten einfärben.                                                           }

procedure TExceptionDialog.ListView1CustomDrawItem(Sender: TCustomListView;
       Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Brush.Color := RGB(240, 248, 255);
end;

procedure TExceptionDialog.ListView1CustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if (SubItem = 1) or (SubItem = 3) or (SubItem = 5) then
    Sender.Canvas.Brush.Color := clWhite else
  if (SubItem = 2) then
    Sender.Canvas.Brush.Color := RGB(255, 248, 210) else
  if SubItem = 4 then
    Sender.Canvas.Brush.Color := RGB(255, 244, 244);
end;

{ ButtonClick ------------------------------------------------------------------

  auf Button-Klick reagieren.                                                  }

procedure TExceptionDialog.DetailsBtnClick(Sender: TObject);
begin
  DetailsVisible := not DetailsVisible;
end;

procedure TExceptionDialog.SaveBtnClick(Sender: TObject);
begin
  SaveDialog1 := TSaveDialog.Create(Self);
  SaveDialog1.Title := 'Save report';
  SaveDialog1.DefaultExt := '.log';
  SaveDialog1.FileName := FDefaultFileName;
  SaveDialog1.InitialDir := GetShellFolder(CSIDL_DESKTOP);
  SaveDialog1.Options := [ofOverwritePrompt,ofHideReadOnly];
  if SaveDialog1.Execute then
  begin
    FReport.SaveToFile(SaveDialog1.FileName);
  end;
  SaveDialog1.Free;
end;

{ TExceptionDialog - public }

end.
