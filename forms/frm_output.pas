{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_output.pas: Darstellung der Ausgabe der Konsolenprogramme

  Copyright (c) 2004-2009 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  24.08.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_output;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {eigene Klassendefinitionen/Units}
  cl_lang, cl_settings, c_frametopbanner;


type
  TFormOutput = class(TForm)
    Memo1: TMemo;
    ButtonOk: TButton;
    CheckBoxAutoUpdate: TCheckBox;
    FrameTopBanner1: TFrameTopBanner;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBoxAutoUpdateClick(Sender: TObject);
  private
    { Private declarations }
    FLang: TLang;
    FSettings: TSettings;
  public
    { Public declarations }
    property Lang: TLang read FLang write FLang;
    property Settings: TSettings read FSettings write FSettings;
  end;

{ var }

implementation

uses frm_main, f_misc, cl_logwindow;

{$R *.DFM}

procedure TFormOutput.FormCreate(Sender: TObject);
begin
  SetFont(Self);
  (*
  if Screen.PixelsPerInch > 96 then
  begin
    self.Width := 756;
    self.Height := 634;
  end;*)
end;

procedure TFormOutput.FormShow(Sender: TObject);
begin
  FLang.SetFormLang(self);
  {Banner}
  FrameTopBanner1.Init(Self.Caption, FLang.GMS('desc01'), 'grad1');
  {falls vorhanden, alte Größe und Position wiederherstellen}
  with FSettings.WinPos do
  begin
    if (OutWidth <> 0) and (OutHeight <> 0) then
    begin
      self.Top := OutTop;
      self.Left := OutLeft;
      self.Width := OutWidth;
      self.Height := OutHeight;
    end else
    begin
      {Falls keine Werte vorhanden, dann Fenster zentrieren. Die muß hier
       manuell geschehen, da poScreenCenter zu Fehlern beim Setzen der
       Eigenschaften führt. Deshalb muß poDefault verwendet werden.}
      self.Top := (Screen.Height - self.Height) div 2;
      self.Left := (Screen.Width - self.Width) div 2;
    end;
    if OutMaximized then self.WindowState := wsMaximized;
  end;

  {zur ersten Zeile scrollen}
  // Memo1.Perform(EM_LineScroll, 0, -Memo1.Lines.Count - 1);
  {zur letzen Zeile scrollen}
  if FSettings.WinPos.OutScrolled then
    Memo1.Perform(EM_LineScroll, 0, Memo1.Lines.Count - 1);
  ButtonOk.SetFocus;
end;

procedure TFormOutput.FormResize(Sender: TObject);
begin      (*
  if Screen.PixelsPerInch <= 96 then
  begin
    Memo1.Width := self.ClientWidth - 16;
    Memo1.Height := self.ClientHeight - 49; {44}
    ButtonOk.Top := Memo1.Height + 14;
    ButtonOk.Left := Memo1.Width + 8 - 75;
    CheckBoxAutoUpdate.Top := Memo1.Height + 14;
  end else
  if Screen.PixelsPerInch > 96 then
  begin
    Memo1.Width := self.ClientWidth - 16;
    Memo1.Height := self.ClientHeight - 58; {53}
    ButtonOk.Top := ClientHeight - 39;
    ButtonOk.Left := ClientWidth - 8 - ButtonOk.Width;
    CheckBoxAutoUpdate.Top := ClientHeight - 39;
  end;       *)
end;

procedure TFormOutput.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with FSettings.WinPos do
  begin
    if self.WindowState = wsMaximized then
    begin
      OutMaximized := True;
    end else
    begin
      OutTop := self.Top;
      OutLeft := self.Left;
      OutWidth := self.Width;
      OutHeight := self.Height;
      OutMaximized := False;
    end;
  end;
end;

procedure TFormOutput.Memo1KeyDown(Sender: TObject; var Key: Word;
                                   Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: Close;
    Ord('A') : if ssCtrl in Shift then (Sender as TMemo).SelectAll;
  end;
end;

procedure TFormOutput.CheckBoxAutoUpdateClick(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  begin
    TLogWin.Inst.SetMemo2(Memo1);
  end else
  begin
    TLogWin.Inst.UnsetMemo2;
  end;
end;

end.
