{ f_window.pas: Funktionnen für Fenster und Dialoge

  Copyright (c) 2004-2011 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  25.12.2011

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_window.pas stellt Hilfs-Funktionen zur Verfügung:
    * Standard-Dialog
    * Eigenschaften von Formularen ändern (Stay-on-top)


  exportierte Funktionen/Prozeduren:
    SetFont(Control: TWinControl)
    SetProgressBarMarquee(PB: TProgressBar; const Active: Boolean)
    ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer
    ShowMsgDlg(const Text, Caption: string; const DlgType: TMsgDlgType; const Buttons: TMsgDlgButtons; Sound: Boolean): Integer
    WindowStayOnTop(Handle: THandle; Value: Boolean)
}

unit f_window;

{$I directives.inc}

interface

uses Forms, SysUtils, Windows, Controls, ComCtrls, Messages, Dialogs, Classes,
     MMSystem, StdCtrls, Graphics;

function FlagIsSet(const Mask, Flag: Longint): Boolean;
function ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer; overload;
function ShowMsgDlg(const Text, Caption: string; const DlgType: TMsgDlgType; const Buttons: TMsgDlgButtons; Sound: Boolean): Integer; overload;
procedure SetButtonCaptions(const Ok, Cancel, Yes, No: string);
procedure SetFont(Control: TWinControl);
procedure SetProgressBarMarquee(PB: TProgressBar; const Active: Boolean);
procedure WindowStayOnTop(Handle: THandle; Value: Boolean);

const MB_cdrtfeDlgEx	   = $01000000;
      MB_cdrtfeDlgSnd	   = $02000000;
      MB_cdrtfeDlgExSnd  = MB_cdrtfeDlgEx or MB_cdrtfeDlgSnd;
      MB_cdrtfeInfo      = MB_OK or MB_ICONINFORMATION or MB_SYSTEMMODAL or MB_cdrtfeDlgExSnd;
      MB_cdrtfeError     = MB_OK or MB_ICONSTOP or MB_SYSTEMMODAL or MB_cdrtfeDlgExSnd;
      MB_cdrtfeWarning   = MB_OK or MB_ICONWARNING or MB_SYSTEMMODAL or MB_cdrtfeDlgExSnd;
      MB_cdrtfeWarningOC = MB_OKCANCEL or MB_ICONWARNING or MB_SYSTEMMODAL or MB_cdrtfeDlgExSnd;
      MB_cdrtfeWarningYN = MB_YESNO or MB_ICONWARNING or MB_SYSTEMMODAL or MB_cdrtfeDlgExSnd;
      MB_cdrtfeConfirm   = MB_OKCANCEL or MB_ICONQUESTION or MB_SYSTEMMODAL or MB_cdrtfeDlgExSnd;
      MB_cdrtfeConfirmS  = MB_OKCANCEL or MB_ICONQUESTION or MB_SYSTEMMODAL or MB_cdrtfeDlgEx;

implementation

uses f_wininfo, c_frametopbanner;

var StrNewOk, StrNewCancel, StrNewYes, StrNewNo: string;

{ FlagIsSet --------------------------------------------------------------------

  prüft, ob ein bestimmtes Flag bei der übergebenen Maske gesetzt ist.         }

function FlagIsSet(const Mask, Flag: Longint): Boolean;
begin
  Result := (Mask and Flag) = Flag;
end;

{ SetFont ----------------------------------------------------------------------

  SetFont sorgt unter Windows XP dafür, daß eine Schriftart verwendet wird, die
  ClearType (Kantenglättung) unterstützt.                                      }

procedure SetFont(Control: TWinControl);
var FontName: string;
begin
  FontName := 'Microsoft Sans Serif';
  if PlatformWin2kXP and (Win32MinorVersion > 0) then
  begin
    if Screen.Fonts.IndexOf(FontName) >= 0 then
    begin
      if Control is TForm then
        (Control as TForm).Font.Name := FontName;
      if Control is TFrame then
        (Control as TFrame).Font.Name := FontName;
    end;
  end;
end;

{ WindowStayOnTop --------------------------------------------------------------

  setzt die Eigenschaft 'Stay-on-top' eines Formulars.                         }

procedure WindowStayOnTop(Handle: THandle; Value: Boolean);
begin
  if Value then
    SetWindowPos(Handle, HWND_TOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE)
  else
    SetWindowPos(Handle, HWND_NOTOPMOST, -1, -1, -1, -1, SWP_NOMOVE + SWP_NOSIZE);
end;

{ SetButtonCaptions ------------------------------------------------------------

  ermöglicht Übersetzung der Buttonbeschriftungen bei Dialogen, die von
  CreateMessageDialog erzeugt wurden.                                          }

procedure SetButtonCaptions(const Ok, Cancel, Yes, No: string);
begin
  StrNewOk := Ok;
  StrNewCancel := Cancel;
  StrNewYes := Yes;
  StrNewNo:= No;
end;

{ TranslateMsgDlgButton --------------------------------------------------------

  übersetetzt die Buttonbeschriftungen der Message-Dialoge.                    }

procedure TranslateMsgDlgButtons(Form: TForm);
var i     : Integer;
    Button: TButton;
begin
  for i := 0 to Form.ComponentCount - 1 do
  begin
    if Form.Components[i] is TButton then
    begin
      Button := Form.Components[i] as TButton;
      if (Button.Name = 'OK') and (StrNewOk <> '') then
        Button.Caption := StrNewOk;
      if (Button.Name = 'Cancel') and (StrNewCancel <> '')  then
        Button.Caption := StrNewCancel;
      if (Button.Name = 'Yes') and (StrNewYes <> '')  then
        Button.Caption := StrNewYes;
      if (Button.Name = 'No') and (StrNewNo <> '')  then
        Button.Caption := StrNewNo;

    end;
  end;
end;

{ ShowMsgDlg -------------------------------------------------------------------

  zeigt einen Dialog an. Verwendet Application.MessageBox.

  Flags: MB_ICONSTOP             MB_OK                    MB_cdrtfe1
         MB_ICONQUESTION         MB_OKCANCEL              MB_cdrtfe2
         MB_ICONWARNING          MB_ABORTRETRYIGNORE
         MB_ICONINFORMATION      MB_YESNOCANCEL
                                 MB_YESNO
                                 MB_RETRYCANCEL
                                 MB_HELP

  Results: ID_OK, ID_CANCEL, ID_ABORT, ID_RETRY, ID_IGNORE, ID_YES, ID_NO      }

function ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer;
var Sound  : Boolean;
    DlgType: TMsgDlgType;
    Buttons: TMsgDlgButtons;
begin
  if not FlagIsSet(Flags, MB_cdrtfeDlgEx) then
  begin
    Result := Application.MessageBox(PChar(Text), PChar(Caption), Flags);
  end else
  begin
    Sound := FlagIsSet(Flags, MB_cdrtfeDlgSnd);
    case Flags and $000000F0 of
      MB_ICONSTOP       : DlgType := mtError;
      MB_ICONQUESTION   : DlgType := mtConfirmation;
      MB_ICONWARNING    : DlgType := mtWarning;
      MB_ICONINFORMATION: DlgType := mtInformation;
    else
      DlgType := mtCustom;
    end;
    case Flags and $0000000F of
      MB_OK              : Buttons := [mbOK];
      MB_OKCANCEL        : Buttons := mbOKCancel;
      MB_ABORTRETRYIGNORE: Buttons := mbAbortRetryIgnore;
      MB_YESNOCANCEL     : Buttons := mbYesNoCancel;
      MB_YESNO           : Buttons := [mbYes, mbNo];
      MB_RETRYCANCEL     : Buttons := [mbRetry, mbCancel];
      MB_HELP            : Buttons := [mbHelp];
    else
      Buttons := [mbOK];
    end;
    Result := ShowMsgDlg(Text, Caption, DlgType, Buttons, Sound);
  end;
end;

{ ShowMsgDlg -------------------------------------------------------------------

  zeigt einen Dialog an. Verwendet CreateMessageDialog.

  DlgType: mtWarning         Buttons: [mbYes], [mbNo], [mbOK], [mbCancel],
           mtError                    [mbAbort], [mbRetry], [mbIgnore], [mbAll],
           mtInformation              [mbNoToAll], [mbYesToAll], [mbHelp],
           mtConfirmation             mbYesNoCancel, mbYesAllNoAllCancel,
           mtCustom                   mbOKCancel, mbAbortRetryIgnore,
                                      mbAbortIgnore

  Results: ID_OK, ID_CANCEL, ID_ABORT, ID_RETRY, ID_IGNORE, ID_YES, ID_NO      }

function ShowMsgDlg(const Text, Caption: string;
                    const DlgType: TMsgDlgType;
                    const Buttons: TMsgDlgButtons;
                    Sound: Boolean): Integer;
const BannerHeight = 33;
var Dlg           : TForm;
    FrameTopBanner: TFrameTopBanner;
    Component     : TComponent;
    MessageLabel  : TStaticText;
    i             : Integer;
    SoundString   : string;
    BannerCap     : string;
    BannerBG      : string;
    DlgLabel      : TLabel;
begin
  BannerBG := 'grad1';
  case DlgType of
    mtWarning     : begin
                      SoundString := 'SystemExclamation';
                      BannerBG := 'grad2';
                    end;
    mtError       : begin
                      SoundString := 'SystemHand';
                      BannerBG := 'grad3';
                    end;
    mtInformation : SoundString := 'SystemNotification';
    mtConfirmation: SoundString := 'SystemQuestion';
  else
    SoundString := '';
  end;
  if SoundString = '' then Sound := False;
  Dlg := CreateMessageDialog(Text, DlgType, Buttons);
  try

    Dlg.BorderStyle := bsSingle;
    Dlg.BorderIcons := [biSystemMenu];
    if Caption = '' then BannerCap := Dlg.Caption else BannerCap := Caption;
    Dlg.Caption := Application.MainForm.Caption;
    if Dlg.Caption = '' then Dlg.Caption := Application.Title;
    Dlg.Height := Dlg.Height + BannerHeight;
    for i := 0 to Dlg.ComponentCount - 1 do
    begin
      Component := Dlg.Components[i];
      if Component is TWinControl then
       (Component as TWinControl).Top :=
         (Component as TWinControl).Top + BannerHeight;
      if Component is TGraphicControl then
       (Component as TGraphicControl).Top :=
         (Component as TGraphicControl).Top + BannerHeight;
      {Workaround für Screenreader wie NVDA, kann manche Label nicht lesen}
      if Component is TLabel then
      begin
        DlgLabel := Component as TLabel;
      end;

    end;
    FrameTopBanner := TFrameTopBanner.Create(nil);
    FrameTopBanner.Parent := Dlg;
    FrameTopBanner.Top := 0;
    FrameTopBanner.Left := 0;
    FrameTopBanner.Width := Dlg.ClientWidth;
    FrameTopBanner.Height := BannerHeight;
    FrameTopBanner.Image2.Left := 0;
    FrameTopBanner.Image2.Width := FrameTopBanner.ClientWidth;
    FrameTopBanner.Init(BannerCap, '', BannerBG);
    if Sound then PlaySound(PChar(SoundString), 0, SND_ALIAS or SND_ASYNC);
    TranslateMsgDlgButtons(Dlg);
    {Workaround für Screenreader wie NVDA, kann manche Label nicht lesen}
    DlgLabel.Visible := False;
    MessageLabel := TStaticText.Create(Dlg);
    MessageLabel.Parent := Dlg;
    MessageLabel.Caption := Text;
    MessageLabel.Top := DlgLabel.Top;
    MessageLabel.Left :=DlgLabel.Left;
    MessageLabel.Width := DlgLabel.Width;
    MessageLabel.Height :=DlgLabel.Height;

    Dlg.ShowModal;
    Result := Dlg.ModalResult
  finally
    Dlg.Release;
  end;
end;

{ SetProgressBarMarquee --------------------------------------------------------

  versetzt einen ProgressBar in den Marquee-Modus.                             }

procedure SetProgressBarMarquee(PB: TProgressBar; const Active: Boolean);
const PBS_MARQUEE  = $08;
      PBM_SETMARQUEE = WM_USER + 10;
var cs: LongInt;
begin
  cs := GetWindowLong(PB.Handle, GWL_STYLE);
  if Active then
  begin
    SetWindowLong(PB.Handle, GWL_STYLE, cs or PBS_MARQUEE);
    SendMessage(PB.Handle, PBM_SETMARQUEE, 1, 50);
  end else
  begin
    SetWindowLong(PB.Handle, GWL_STYLE, cs and not PBS_MARQUEE);
  end;
end;

end.
