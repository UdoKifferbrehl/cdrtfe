{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_fixate.pas: Disks fixieren

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_fixate.pas implementiert das Objekt, das Disks fixiert.

  TCdrtfeActionFixate ist ein Objekt, das die Kommandozeilen für das Fixieren
  von Disks erstellt und ausführt.


  TCdrtfeActionFixate

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_fixate;

{$I directives.inc}

interface

uses Windows, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionFixate = class(TCdrtfeAction)
     private
       procedure WriteTOC;
     protected
     public
       constructor Create;
       function GetCommandLineString: string; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper,
     f_window;

{ TCdrtfeActionFixate -------------------------------------------------------- }

{ TCdrtfeActionFixate - private }

{ WriteTOC ---------------------------------------------------------------------

  Eine CD fixieren.                                                            }

procedure TCdrtfeActionFixate.WriteTOC;
var Cmd: string;
    i  : Integer;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Cmd := StartUpDir + cCdrecordBin;
  Cmd := QuotePath(Cmd);
  with FSettings.Cdrecord do
  begin
    Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(FixDevice);
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
    Cmd := Cmd + ' -fix';
  end;
  {Kommando ausführen}
  if not FSettings.General.NoConfirm then
  begin
    {Fixieren starten?}
    i := ShowMsgDlg(FLang.GMS('mburn11'), FLang.GMS('mburn02'),
                    MB_cdrtfeConfirmS);
  end else
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ TCdrtfeActionFixate - protected }

{ TCdrtfeActionFixate - public }

constructor TCdrtfeActionFixate.Create;
begin
  inherited Create;
end;

{ GetCommandLineString ---------------------------------------------------------

  liefert die auszuführende(n) Kommandozeile(n).                               }

function TCdrtfeActionFixate.GetCommandLineString: string;
begin
  Result := '';
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionFixate.CleanUp;
begin
  // wird hier nicht benötigt
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionFixate.Reset;
begin
  // wird hier nicht benötigt
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionFixate.StartAction;
begin
  WriteToc;
end;

end.

