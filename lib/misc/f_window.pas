{ $Id: f_window.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_window.pas: Funktionnen für Fenster und Dialoge

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.01.2010

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
    WindowStayOnTop(Handle: THandle; Value: Boolean)
}

unit f_window;

{$I directives.inc}

interface

uses Forms, SysUtils, Windows, Controls, ComCtrls, Messages;

function ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer;
procedure SetFont(Control: TWinControl);
procedure SetProgressBarMarquee(PB: TProgressBar; const Active: Boolean);
procedure WindowStayOnTop(Handle: THandle; Value: Boolean);

const MB_cdrtfe1 = MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION;
      MB_cdrtfe2 = MB_OK or MB_ICONEXCLAMATION or MB_SYSTEMMODAL;

implementation

uses f_wininfo;

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

{ ShowMsgDlg -------------------------------------------------------------------

  zeigt einen Dialog an. Verwendet Application.MessageBox.

  Flags: MB_ICONSTOP             MB_OK                    MB_cdrtfe1
         MB_ICONQUESTION         MB_OKCANCEL
         MB_ICONWARNING          MB_ABORTRETRYIGNORE
         MB_ICONINFORMATION      MB_YESNOCANCEL
                                 MB_YESNO
                                 MB_RETRYCANCEL
                                 MB_HELP

  Results: ID_OK, ID_CANCEL, ID_ABORT, ID_RETRY, ID_RIGNORE, ID_YES, ID_NO     }

function ShowMsgDlg(const Text, Caption: string; const Flags: Longint): Integer;
begin
  Result := Application.MessageBox(PChar(Text), PChar(Caption), Flags);
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
