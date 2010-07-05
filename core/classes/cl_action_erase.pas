{ $Id: cl_action_erase.pas,v 1.2 2010/07/05 12:34:52 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_erase.pas: Disks l�schen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  04.07.2010

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  cl_action_erase.pas implementiert das Objekt, das Disks l�scht.

  TCdrtfeActionErase ist ein Objekt, das die Kommandozeilen f�r das L�schen
  von Disks erstellt und ausf�hrt.


  TCdrtfeActionErase

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_erase;

{$I directives.inc}

interface

uses Windows, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionErase = class(TCdrtfeAction)
     private
       procedure DeleteCDRW;
     protected
     public
       constructor Create;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper,
     f_window, cl_diskinfo, const_tabsheets;

{ TCdrtfeActionErase --------------------------------------------------------- }

{ TCdrtfeActionErase - private }

{ DeleteCDRW -------------------------------------------------------------------

  DeleteCDRW l�scht CD-RWs bzw. Teile davon.                                   }

procedure TCdrtfeActionErase.DeleteCDRW;
var i     : Integer;
    Cmd   : string;
    Ok    : Boolean;
    CMArgs: TCheckMediumArgs;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  CMArgs.Choice := cCDRW;
  SetPanels('<>', FLang.GMS('mburn13'));
  FDisk.GetDiskInfo(FSettings.CDRW.Device, False);
  SetPanels('<>', '');
  Ok := FDisk.CheckMedium(CMArgs);
  {Kommandozeile zusammenstellen}
  with FSettings.CDRW do
  begin
    Cmd := StartUpDir + cCdrecordBin;
    Cmd := QuotePath(Cmd);
    Cmd := Cmd + ' gracetime=9 dev=' + SCSIIF(Device);
    if All          then Cmd := Cmd + ' blank=all'     else
    if Fast         then Cmd := Cmd + ' blank=fast'    else
    if OpenSession  then Cmd := Cmd + ' blank=unclose' else
    if BlankSession then Cmd := Cmd + ' blank=session';
    if Force        then Cmd := Cmd + ' -force';
  end;
  with FSettings.Cdrecord do
  begin
    if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
  end;
  {Kommando ausf�hren}
  if not Ok then
  begin
    i := 0;
  end else
  begin
    if not (FSettings.CmdLineFlags.ExecuteProject or
            FSettings.General.NoConfirm) then
    begin
      {Brennvorgang starten?}
      i := ShowMsgDlg(FLang.GMS('mburn05'), FLang.GMS('mburn06'),
                      MB_cdrtfeConfirmS);
    end else
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
  SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ TCdrtfeActionErase - protected }

{ TCdrtfeActionErase - public }

constructor TCdrtfeActionErase.Create;
begin
  inherited Create;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp l�scht tempor�re Dateien.                                            }

procedure TCdrtfeActionErase.CleanUp;
begin
  // wird hier nicht ben�tigt
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zur�ck.                                  }

procedure TCdrtfeActionErase.Reset;
begin
  // wird hier nicht ben�tigt
end;

{ StartAction ------------------------------------------------------------------

  StartAction f�hrt die gew�hlte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionErase.StartAction;
begin
  DeleteCDRW;
end;

end.

