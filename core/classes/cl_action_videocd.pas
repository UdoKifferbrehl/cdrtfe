{ $Id: cl_action_videocd.pas,v 1.2 2010/07/05 12:34:52 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_vcd.pas: Video-CD

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  04.07.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_vcd.pas implementiert das Objekt, das (S)VCDs erstellt.

  TCdrtfeActionVCD ist ein Objekt, das die Kommandozeilen für das Schreiben
  von VCDs erstellt und ausführt.


  TCdrtfeActionVCD

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_videocd;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionVideoCD = class(TCdrtfeAction)
     private
       FVList             : TStringList;
       procedure CreateVideoCD;
     protected
     public
       constructor Create;
       destructor Destroy; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper,
     f_window, cl_diskinfo, const_tabsheets, const_common;

{ TCdrtfeActionVideoCD ------------------------------------------------------- }

{ TCdrtfeActionVideoCD - private }

{ CreateVideoCD ----------------------------------------------------------------

  Image für eine VideoCD erstellen oder VideoCD brennen.                       }

procedure TCdrtfeActionVideoCD.CreateVideoCD;
var i       : Integer;
    CmdVCDIm: string;
    CmdC    : string;
    Temp    : string;
    CueFile : string;
    Ok      : Boolean;
    BurnList: TStringList;
    Size    : Int64;
    DummyE  : Extended;
    DummyI  : Integer;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  Ok := True;
  {Größe der Daten ermitteln}
  FData.GetProjectInfo(DummyI, DummyI, Size, DummyE, DummyI, cVideoCD);
  CheckSpaceForImage(Ok, FSettings.VideoCD.IsoPath, 0, Size);
  {Dateiliste übernehmen}
  BurnList := TStringList.Create;
  FData.CreateBurnList(BurnList, cVideoCD);
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}  
  with FSettings.VideoCD, FSettings.Cdrecord, FSettings.Cdrdao do
  begin
    {Kommandozeile für VCDImager zusammenstellen.}
    CmdVCDIm := StartUpDir + cVCDImagerBin;
    CmdVCDIm := QuotePath(CmdVCDIm);
    CmdVCDIm := CmdVCDIm + ' -p';
    if FSettings.VideoCD.Verbose then
    begin
      CmdVCDIm := CmdVCDIm + ' -v';
    end;
    CmdVCDIm := CmdVCDIm  + ' --type=';
    if VCD1 then
    begin
      CmdVCDIm := CmdVCDIm + 'vcd11';
    end else
    if VCD2 then
    begin
      CmdVCDIm := CmdVCDIm + 'vcd2';
    end else
    if SVCD then
    begin
      CmdVCDIm := CmdVCDIm + 'svcd';
    end;
    {Dateinamen bearbeiten}
    CueFile := IsoPath + cExtCue;
    CueFile := MakePathConform(CueFile);
    CueFile := QuotePath(CueFile);
    CmdVCDIm := CmdVCDIm + ' --cue-file=' + CueFile;
    Temp := IsoPath + cExtBin;
    Temp := MakePathConform(Temp);
    Temp := QuotePath(Temp);
    CmdVCDIm := CmdVCDIm + ' --bin-file=' + Temp;
    if VolID <> '' then
    begin
      CmdVCDIm := CmdVCDIm + ' --iso-volume-label="' + VolID + '"';
    end;
    if SVCD and SVCDCompat then
    begin
      CmdVCDIm := CmdVCDIm + ' --broken-svcd-mode';
    end;
    if Sec2336 then
    begin
      CmdVCDIm := CmdVCDIm + ' --sector-2336';
    end;
    {Jetzt die Tracks hinzufügen}
    {Pfadliste bearbeiten}
    for i := 0 to (BurnList.Count - 1) do
    begin
      {_alle_ Pfadangaben Cygwin-konform machen!}
      BurnList[i] := MakePathConform(BurnList[i]);
      Temp := QuotePath(BurnList[i]);
      CmdVCDIm := CmdVCDIm + ' ' + Temp;
    end;
    BurnList.Free;
    {cdrecord/cdrdao}
    CmdC := '';
    if (FSettings.FileFlags.CdrdaoOk and WriteCueImages) or
       (FSettings.FileFlags.CdrdaoOk and not CanWriteCueImage)  then
    begin
      {Kommandozeile für cdrdao}
      CmdC := StartUpDir + cCdrdaoBin;
      CmdC := QuotePath(CmdC);
      CmdC := CmdC + ' write --device ' + Device;
      if ForceGenericMmc    then CmdC := CmdC +
                                              ' --driver generic-mmc';
      if ForceGenericMmcRaw then CmdC := CmdC +
                                              ' --driver generic-mmc-raw';
      if Speed <> ''        then CmdC := CmdC + ' --speed ' + Speed;
      if Dummy              then CmdC := CmdC + ' --simulate';
      if Overburn           then CmdC := CmdC + ' --overburn';
      CmdC := CmdC + ' ' + CueFile;
    end;
    if (not FSettings.FileFlags.CdrdaoOk and CanWriteCueImage) or
       (not WriteCueImages and CanWriteCueImage) then
    begin
      {Kommandozeile für cdrecord}
      CmdC := StartUpDir + cCdrecordBin;
      CmdC := QuotePath(CmdC);
      CmdC := CmdC + ' gracetime=5 dev=' + SCSIIF(Device);
      if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
      if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
      if SimulDrv    then CmdC := CmdC + ' driver=cdr_simul';
      if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
      if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
        CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
      if Verbose     then CmdC := CmdC + ' -v';
      if Dummy       then CmdC := CmdC + ' -dummy';
      if DMASpeedCheck and ForceSpeed then
                          CmdC := CmdC + ' -force';
      if Overburn    then CmdC := CmdC + ' -overburn';
      CmdC := CmdC + ' -dao cuefile=' + CueFile;
    end;
  end;
  {Kommando ausführen}
  if not Ok then
  begin
    i := 0;
  end else
  begin
    if not (FSettings.CmdLineFlags.ExecuteProject or
            FSettings.General.NoConfirm) then
    begin
      {Brennvorgang starten?}
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'),
                      MB_cdrtfeConfirmS);
    end else
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    if not (FSettings.VideoCD.ImageOnly or (CmdC = '')) then
    begin
      DisplayDOSOutput(CmdVCDIm + CR + CmdC, FActionThread, FLang, nil);
    end else
    begin
      DisplayDOSOutput(CmdVCDIm, FActionThread, FLang, nil);
    end;
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ TCdrtfeActionVideoCD - protected }

{ TCdrtfeActionVideoCD - public }

constructor TCdrtfeActionVideoCD.Create;
begin
  inherited Create;
  FVList := TStringList.Create;
end;

destructor TCdrtfeActionVideoCD.Destroy;
begin
  FVList.Free;
  inherited Destroy;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionVideoCD.CleanUp;
begin
  {Phase 1: TForm1.WMITerminated}
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    if not (FSettings.VideoCD.ImageOnly or FSettings.VideoCD.KeepImage) then
    begin
      DeleteFile(FSettings.VideoCD.IsoPath + cExtBin);
      DeleteFile(FSettings.VideoCD.IsoPath + cExtCue);
    end;
  end;
  {Phase 3: TForm1.WMVTerminated}
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionVideoCD.Reset;
begin
  FVList.Clear;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionVideoCD.StartAction;
begin
  CreateVideoCD;
end;

end.

