{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_dvdvideo.pas: DVD-Video

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_dvdvideo.pas implementiert das Objekt, das Video-DVDs schreibt oder
  erstellt.

  TCdrtfeActionDVDVideo ist ein Objekt, das die Kommandozeilen für das Erstellen
  und Schreiben von Video-DVDs erzeugt und ausführt.


  TCdrtfeActionDVDVideo

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_dvdvideo;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_verifythread,
     cl_abstractbaseaction;

type TCdrtfeActionDVDVideo = class(TCdrtfeAction)
     private
       FReload            : Boolean;
       FVList             : TStringList;
       FVerificationThread: TVerificationThread;
       procedure CreateVideoDVD;
     protected
     public
       constructor Create;
       function GetCommandLineString: string; override;
       destructor Destroy; override;
       procedure AbortAction; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
       procedure StartVerification;
       property Reload: Boolean read FReload write FReload;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper,
     f_window, cl_diskinfo, cl_cueinfo, const_tabsheets, const_common,
     f_environment;

{ TCdrtfeActionDVDVideo ------------------------------------------------------ }

{ TCdrtfeActionDVDVideo - private }

{ CreateVideoDVD ---------------------------------------------------------------

  Aus einen Quellverzeichnis eine Video-DVD erstellen. Zur Zeit nur on-the-fly,
  keine Imageerstellung.                                                       }

procedure TCdrtfeActionDVDVideo.CreateVideoDVD;
var Ok          : Boolean;
    i           : Integer;
    CmdC, CmdM,
    CmdFormat,
    CmdOnTheFly : string;
    SourceArg   : string;
    CMArgs      : TCheckMediumArgs;
    Temp        : string;
    SimulDev    : string;
    FHShCmd     : TextFile;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  Ok := True;
  CMArgs.ForcedContinue := False;
  CMArgs.Choice := cDVDVideo;
  SimulDev := 'cdr';
  {Infos über eingelegte Disk einlesen}
  if not FSettings.DVDVideo.ImageOnly or FSettings.DVDVideo.OnTheFly then
  begin
    SetPanels('<>', FLang.GMS('mburn13'));
    FDisk.GetDiskInfo(FSettings.DVDVideo.Device, False);
    SetPanels('<>', '');
  end;
  {Falls ein Vergleich stattfinden soll, benötigen wir die Dateinamen.}
  FData.SetDVDSourcePath(FSettings.DVDVideo.SourcePath);
  CmdM := ' -dvd-video';
  with FSettings.DVDVideo, FSettings.General, FSettings.Cdrecord do
  begin
    {mkisofs}
    if MkisofsUseCustOpts and (MkisofsCustOptsIndex > -1) then
      CmdM := CmdM + ' ' + MkisofsCustOpts[MkisofsCustOptsIndex];
    if VolID <> '' then CmdM := CmdM + ' -volid "' + VolID + '"';
    SourceArg := ' ' + QuotePath(MakePathConform(SourcePath));
    {Anzahl der benötigten Sektoren ermitteln}
    if not (FDisk.DiskType in [DT_None, DT_ManualNone]) then
    begin
      CMArgs.SectorsNeededS := GetSectorNumber(CmdM + SourceArg);
      CMArgs.SectorsNeededI := StrToIntDef(CMArgs.SectorsNeededS, -1);
    end;
    {Zusammenstellung prüfen}
    if not ImageOnly or OnTheFly then
    begin
      Ok := FDisk.CheckMedium(CMArgs);
      {Bei DVD als Simulationstreiber dvd_simul verwenden.}
      if FDisk.IsDVD then
      begin
        SimulDev := 'dvd';
      end;
    end;
    {Genügend Platz für Image?}
    if not OnTheFly then
      CheckSpaceForImage(Ok, IsoPath, CMArgs.SectorsNeededI, 0);
    {cdrecord}
    CmdC := ' gracetime=5 dev=' + SCSIIF(Device);
    if Erase       then CmdC := CmdC + ' blank=fast';    
    if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
    if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then CmdC := CmdC + ' driver=' + SimulDev + '_simul';
    CmdC := CmdC + GetDriverOpts;
    if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
      CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then CmdC := CmdC + ' -v';
    if Dummy       then CmdC := CmdC + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        CmdC := CmdC + ' -force';
    CmdC := CmdC + ' -dao';
    {on-the-fly}
    if FSettings.DVDVideo.OnTheFly then
    begin
      CmdM := CmdM + SourceArg;
      {DVDs werden immer in DAO geschrieben, also Sektoranzahl ermitteln}
      CmdC := CmdC + ' -tsize=' + CMArgs.SectorsNeededS + 's';
      {ab Win2k ist die Ausführung mit sh.exe nicht mehr nötig.}
      if FSettings.FileFlags.UseSh then
      begin
        {Shell-Kommando zusammenstellen}
        Temp := QuotePath(MakePathConform(StartUpDir + cMkisofsBin));
        CmdM := Temp + CmdM;
        Temp := QuotePath(MakePathConform(StartUpDir + cCdrecordBin));
        CmdC := Temp + CmdC + ' -';
        {Shell-Kommandos pipen}
        CmdOnTheFly := CmdM + '|' + CmdC;
        {diese Kommandozeile als Datei speichern}
        ShCmdName := ProgDataDir + cShCmdFile;
        AssignFile(FHShCmd, ShCmdName);
        Rewrite(FHShCmd);
        WriteLn(FHShCmd, CmdOnTheFly);
        CloseFile(FHShCmd);
      end else
      begin
        {Shell-Kommando zusammenstellen}
        Temp := QuotePath(StartUpDir + cMkisofsBin);
        CmdM := Temp + CmdM;
        Temp := QuotePath(StartUpDir + cCdrecordBin);
        CmdC := Temp + CmdC + ' -';
        {Shell-Kommandos pipen}
        CmdOnTheFly := CmdM + ' | ' + CmdC;
        {Befehl muß in der Windows-Shell ausgeführt werden.}
        CmdOnTheFly := GetEnvVarValue(cComSpec) +
                       ' /c ' + '"' + CmdOnTheFly + '"';
      end;
    end else
    begin
      {den Pfad für das Image anhängen}
      Temp := QuotePath(MakePathConform(IsoPath));
      CmdM := CmdM + ' -output ' + Temp;                            // ' -o '
      CmdC := CmdC + ' ' + Temp;
      CmdM := CmdM + ' ' + QuotePath(MakePathConform(SourcePath));
      {Pfad zu den Programmen erstellen}
      Temp := StartUpDir + cMkisofsBin;
      Temp := QuotePath(Temp);
      CmdM := Temp + CmdM;
      Temp := StartUpDir + cCdrecordBin;
      Temp := QuotePath(Temp);
      CmdC := Temp + CmdC;
    end;
  end;
  {Kommando für das Formatieren ganz neuer DVD+RWs}
  CmdFormat := GetFormatCommand;

  {Kommandos ausführen}
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
    CheckEnvironment(FSettings);
    if FSettings.DVDVideo.OnTheFly then
    begin
      {ab Win2k ist die Ausführung mit sh.exe nicht mehr nötig.}
      if FSettings.FileFlags.UseSh then
      begin
        MessageShow(FLang.GMS('mburn03'));
        MessageShow(CmdOnTheFly);
        Temp := QuotePath(MakePathConform(ProgDataDir + cShCmdFile));
        CmdOnTheFly := StartUpDir + cShBin;
        CmdOnTheFly := QuotePath(CmdOnTheFly);
        CmdOnTheFly := CmdOnTheFly + ' ' + Temp;
        DisplayDOSOutput(CmdFormat + CmdOnTheFly, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end else
      begin
        DisplayDOSOutput(CmdFormat + CmdOnTheFly, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end;
    end else
    begin
      if not FSettings.DVDVideo.ImageOnly then
      begin
        DisplayDOSOutput(CmdFormat + CmdM + CR + CmdC, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end else
      begin
        DisplayDOSOutput(CmdM, FActionThread, FLang, nil);
      end
    end;
  end else
  {falls Fehler, Button wieder aktivieren}
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.DVDVideo.ShCmdName);
  end;
end;

{ TCdrtfeActionDVDVideo - protected }

{ TCdrtfeActionDVDVideo - public }

constructor TCdrtfeActionDVDVideo.Create;
begin
  inherited Create;
  FVList := TStringList.Create;
  FReload := True;
end;

destructor TCdrtfeActionDVDVideo.Destroy;
begin
  FVList.Free;
  inherited Destroy;
end;

{ GetCommandLineString ---------------------------------------------------------

  liefert die auszuführende(n) Kommandozeile(n).                               }

function TCdrtfeActionDVDVideo.GetCommandLineString: string;
begin
  Result := '';
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCdrtfeActionDVDVideo.AbortAction;
begin
  inherited AbortAction;
  if FVerificationThread <> nil then TerminateVerification(FVerificationThread);
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionDVDVideo.CleanUp(const Phase: Byte);
begin
  {Phase 1: TForm1.WMITerminated}
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    DeleteFile(FSettings.DVDVideo.ShCmdName);
    if not (FSettings.DVDVideo.ImageOnly or FSettings.DVDVideo.KeepImage) then
    begin    (*
      if not FSplitOutput then
      begin *)
        DeleteFile(FSettings.DVDVideo.IsoPath); (*
      end else
      begin
        i := 0;
        while FileExists(FSettings.DVDVideo.IsoPath + '_' +
                         Format('%2.2d', [i])) do
        begin
          DeleteFile(FSettings.DVDVideo.IsoPath + '_' + Format('%2.2d', [i]));
          Inc(i);
        end;
      end; *)
    end;
  end;
  {Phase 3: TForm1.WMVTerminated}
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionDVDVideo.Reset;
begin
  FVList.Clear;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionDVDVideo.StartAction;
begin
  CreateVideoDVD;
end;

{ StartVerification ------------------------------------------------------------

  Vergleich der Quelldateien mit den geschriebenen Dateien. Die Prozedur
  StartVerifyDataCD wird nicht verwendet, stattdessen wird der Thread hier
  direkt gestartet, weil auch der Fortschritt angezeigt werden soll. Dafür
  müßten aber zu viele Argumente an die Prozedur übergeben werden.
  Ein Verify ist sowohl für Daten- als auch für XCDs möglich.                  }

procedure TCdrtfeActionDVDVideo.StartVerification;
var Device: string;
    Drive : string;
    CDSize: Int64;
    DummyI: Integer;
    DummyE: Extended;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Pfadlisten in FVList laden}
  FVList.Clear;
  FData.GetProjectInfo(DummyI, DummyI, CDSize, DummyE, DummyI,
                       FSettings.General.Choice);
  Device := FSettings.DVDVideo.Device;
  FData.CreateVerifyList(FVList, cDVDVideo);
  Drive := FDevices.GetDriveLetter(Device);
  {Thread starten}
  FVerificationThread := TVerificationThread.Create(FVList, Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cVerifyDVDVideo;
  FVerificationThread.TotalSize := CDSize;
  {jetzt weitere (optionale) Properties setzen}
  FVerificationThread.StatusBar := FStatusBar;
  FVerificationThread.AutoExec := FSettings.CmdLineFlags.ExecuteProject;
  FVerificationThread.Reload := FReload;
  FVerificationThread.Drive := Drive;
  {Thread starten}
  FVerificationThread.Resume;
  {Reload zurücksetzten}
  FReload := True;
end;

end.

