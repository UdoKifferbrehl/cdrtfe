{ $Id: cl_action_datacd.pas,v 1.1 2010/05/23 18:51:56 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_datacd.pas: Daten-Disk

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  23.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_datacd.pas implementiert das Objekt, das Daten-Disks schreibt oder
  erstellt.

  TCdrtfeActionDataCD ist ein Objekt, das die Kommandozeilen für das Erstellen
  und Schreiben von Daten-Disks erzeugt und ausführt.


  TCdrtfeActionDataCD

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_datacd;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_verifythread,
     cl_abstractbaseaction;

type TCdrtfeActionDataCD = class(TCdrtfeAction)
     private
       FReload            : Boolean;
       FVList             : TStringList;
       FVerificationThread: TVerificationThread;
       FDupSize           : Int64;
       FSplitOutput       : Boolean;
       procedure CreateDataDisk;
       procedure FindDuplicateFiles(List: TStringList);
     protected
     public
       constructor Create;
       destructor Destroy; override;
       procedure AbortAction; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
       procedure StartVerification;
       property DuplicateFileSize: Int64 read FDupSize write FDupSize;
       property Reload: Boolean read FReload write FReload;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper,
     f_window, cl_diskinfo, cl_cueinfo, const_tabsheets, const_common,
     f_environment, f_filesystem, f_cygwin;

{ TCdrtfeActionDataCD -------------------------------------------------------- }

{ TCdrtfeActionDataCD - private }

{ FindDuplicateFiles -----------------------------------------------------------

  FindDuplicateFiles sucht in der Pfadliste nach Dateiduplikaten.              }

procedure TCdrtfeActionDataCD.FindDuplicateFiles(List: TStringList);
var CDSize: Int64;
    DummyI: Integer;
    DummyE: Extended;
begin
  FData.GetProjectInfo(DummyI, DummyI, CDSize, DummyE, DummyI,
                       FSettings.General.Choice);
  {Pfadlisten in FVList laden}
  FVerificationThread := TVerificationThread.Create(List,
                                                    FSettings.DataCD.Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cFindDuplicates;
  FVerificationThread.TotalSize := CDSize;
  FVerificationThread.StatusBar := FStatusBar;
  {Thread starten}
  FVerificationThread.Resume;
end;

{ CreateDataDisk ---------------------------------------------------------------

  Daten-CDs, -DVDs erstellen und fortsetzen.                                   }

procedure TCdrtfeActionDataCD.CreateDataDisk;
var i              : Integer;
    Temp, MetaTemp : string;
    BurnList       : TStringList;
    CmdC, CmdM,
    CmdOnTheFly,
    CmdFormat      : string;
    FHPathList,
    FHShCmd        : TextFile;
    CMArgs         : TCheckMediumArgs;
    DummyE         : Extended;
    DummyI         : Integer;
    Ok             : Boolean;
    SimulDev       : string;
    Count          : Integer;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  BurnList := TStringList.Create;
  DummyDir(True);
  FData.CreateBurnList(BurnList, cDataCD);
  Ok := True;
  SimulDev := 'cdr';
  CMArgs.ForcedContinue := False;
  CMArgs.Choice := cDataCD;
  {Größe der Daten ermitteln}
  FData.GetProjectInfo(Count, DummyI, CMArgs.CDSize, DummyE, DummyI, cDataCD);
  {Dateiduplikate aufspüren}
  {$IFDEF ShowBurnList}
  FormDebug.Memo1.Lines.Assign(FVList);
  {$ENDIF}
  if FSettings.DataCD.FindDups and (Count > 0) then
  begin
    if FVList.Count = 0 then
    begin
      FVList.Assign(BurnList);
      FindDuplicateFiles(FVList);
      Burnlist.Free;
      {wir müssen zuück in den Hauptthread, um auf den Vergleich zu warten}
      exit;
    end else
    begin
      BurnList.Clear;
      BurnList.Assign(FVList);
      FVList.Clear;
      if FDupSize > 0 then
      begin
        CMArgs.CDSize := CMArgs.CDSize - FDupSize;
        FDupSize := 0;
      end;
    end;
  end;
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}
  {Infos über eingelegte CD einlesen}
  if not FSettings.DataCD.ImageOnly or FSettings.DataCD.OnTheFly then
  begin
    SetPanels('<>', FLang.GMS('mburn13'));
    FDisk.SelectSess := FSettings.DataCD.ContinueCD and
                        FSettings.DataCD.SelectSess;
    FDisk.SessOverride := FSettings.DataCD.MsInfo;
    FDisk.GetDiskInfo(FSettings.DataCD.Device, False);
    SetPanels('<>', '');
  end;
  {Pfadliste bearbeiten}
  if FSettings.DataCD.Boot then
  begin
    BurnList.Add(ExtractFileName(FSettings.DataCD.BootImage) + ':' +
                 FSettings.DataCD.BootImage);
  end;
  for i := 0 to (BurnList.Count - 1) do
  begin
    {die Liste für die graft-points-Option von cdrecord umbauen:
     bis 0.8.x -graft-points betrifft nur Directories, Cygwin-konform genügte.
     jetzt: _alle_ Pfadangaben Cygwin-konform machen und außerdem auf '='
     achten!}
    BurnList[i] := MakePathEntryMkisofsConform(BurnList[i]);
  end;
  FSettings.DataCD.PathListName := ProgDataDir + cPathListFile;
  // BurnList.SaveToFile(PathListName);
  {Nun doch wieder mit WriteFile, wg. CR/LF-Problem: Wenn eine vollständige
   cygwin-Installation vorhanden ist, kann mkisofs keine Pfadlisten mit CR/LF
   einlesen, wie sie von SaveToFile() erzeugt werden.}
  AssignFile(FHPathList, FSettings.DataCD.PathListName);
  Rewrite(FHPathList);
  for i := 0 to (BurnList.Count - 1) do
  begin
    Write(FHPathList, BurnList[i] + LF);
  end;
  Close(FHPathList);
  {Ab 1 GiByte soll das Image geteilt werden, wenn ProDVD benutzt wird und das
   Ziellaufwerk FAT oder FAT32 formatiert ist.}
  FSplitOutput := FSettings.FileFlags.ProDVD and
                  FileSystemIsFAT(FSettings.DataCD.IsoPath) and
                  not FSettings.DataCD.OnTheFly and
                  ((CMArgs.CDSize / (1024 * 1024)) > 1024);                // 10
  {Kommandozeilen zusammenstellen, die unabhängig von on-the-fly sind, hier
   ersteinmal nur die Argumente; die Programmnamen und -pfade kommen später,
   da sie wegen sh.exe gesondert behandelt werden müssen.}
  {mkisofs-Kommandozeile zusammenstellen}
  CmdM := ' -graft-points';
  with FSettings.DataCD, FSettings.General, FSettings.Cdrecord do
  begin
    if FindDups     then CmdM := CmdM + ' -cache-inodes';
    if Joliet       then
    if JolietLong   then CmdM := CmdM + ' -joliet-long' else
                         CmdM := CmdM + ' -joliet';                  // ' -J';
    if RockRidge    then
    if RationalRock then CmdM := CmdM + ' -rational-rock' else       // ' -r';
                         CmdM := CmdM + ' -rock';                    // ' -R';
    if UDF          then CmdM := CmdM + ' -udf';
    if ISOInChar > -1
                    then CmdM := CmdM + ' -input-charset '
                                      + CharSets[ISOInChar];
    if ISOOutChar > -1
                    then CmdM := CmdM + ' -output-charset '
                                      + CharSets[ISOOutChar];
    if ISO31Chars   then CmdM := CmdM + ' -full-iso9660-filenames';  // ' -l';
    if ISOLevel     then CmdM := CmdM + ' -iso-level ' + IntToStr(ISOLevelNr);
    if ISO37Chars   then CmdM := CmdM + ' -max-iso9660-filenames';
    if ISONoDot     then CmdM := CmdM + ' -omit-period';             // ' -d';
    if ISOStartDot  then CmdM := CmdM + ' -allow-leading-dots';      // ' -L';
    if ISOMultiDot  then CmdM := CmdM + ' -allow-multidot';
    if ISOASCII     then CmdM := CmdM + ' -relaxed-filenames';
    if ISOLower     then CmdM := CmdM + ' -allow-lowercase';
    if ISONoTrans   then CmdM := CmdM + ' -no-iso-translate';
    if ISODeepDir   then CmdM := CmdM + ' -disable-deep-relocation'; // ' -D';
    if ISONoVer     then CmdM := CmdM + ' -omit-version-number';     // ' -N';
    if TransTBL     then
    begin
      CmdM := CmdM + ' -T';
      if Joliet and HideTransTBL then CmdM := CmdM + ' -hide-joliet-trans-tbl';
    end;
    if NLPathTBL and HaveNLPathtables then
                         CmdM := CmdM + ' -no-limit-pathtables';
    if Boot         then
    begin
      CmdM := CmdM + ' -eltorito-boot ' + QuotePath(ExtractFileName(BootImage));
      if BootInfTable then CmdM := CmdM + ' -boot-info-table';
      if BootNoEmul   then
      begin
        CmdM := CmdM + ' -no-emul-boot';
        if BootSegAdr <> '' then CmdM := CmdM + ' -boot-load-seg '
                                              + BootSegAdr;
        if BootLoadSize <> '' then CmdM := CmdM + ' -boot-load-size '
                                                + BootLoadSize;
      end;
      if BootBinHide  then
      begin
        CmdM := CmdM + ' -hide ' + QuotePath(ExtractFileName(BootImage));
        if Joliet then CmdM := CmdM + ' -hide-joliet '
                                    + QuotePath(ExtractFileName(BootImage));
        if UDF and HaveHideUDF then CmdM := CmdM + ' -hide-udf '
                                    + QuotePath(ExtractFileName(BootImage));
      end;
      if BootCatHide  then
      begin
        CmdM := CmdM + ' -hide boot.catalog';
        if Joliet then CmdM := CmdM + ' -hide-joliet boot.catalog';
        if UDF and HaveHideUDF then CmdM := CmdM + ' -hide-udf boot.catalog';
      end;
    end;
    if FData.DataCDFilesToDelete then
    begin
      Temp := QuotePath(MakePathCygwinConform(DummyFileName));
      CmdM := CmdM + ' -hide ' + Temp;
      CmdM := CmdM + ' -hide-joliet ' + Temp;
      if HaveHideUDF then CmdM := CmdM + ' -hide-udf ' + Temp;
    end;
    if HideRRMoved and RockRidge then
                        CmdM := CmdM + ' -hide-rr-moved';
    if VolId <> '' then CmdM := CmdM + ' -volid ' + QuotePath(VolId);
    if UseMeta then
    begin
      MetaTemp := '';
      if IDPublisher <> '' then
        MetaTemp := MetaTemp + ' -publisher ' + QuotePath(IDPublisher);
      if IDPreparer <> '' then
        MetaTemp := MetaTemp + ' -p ' + QuotePath(IDPreparer);
      if IDCopyright <> '' then
        MetaTemp := MetaTemp + ' -copyright ' + QuotePath(IDCopyright);
      if IDSystem <> '' then
        MetaTemp := MetaTemp + ' -sysid ' + QuotePath(IDSystem);
      CmdM := CmdM + MetaTemp;
    end;
    if MkisofsUseCustOpts and (MkisofsCustOptsIndex > -1) then
      CmdM := CmdM + ' ' + MkisofsCustOpts[MkisofsCustOptsIndex];
    CmdM := CmdM + ' -path-list '
                 + QuotePath(MakePathConform(PathListName));
    if FSplitOutput then CmdM := CmdM + ' -split-output';
    {Anzahl der benötigten Sektoren ermitteln}
    if not (FDisk.DiskType in [DT_None, DT_ManualNone]) then
    begin
      CMArgs.SectorsNeededS := GetSectorNumber(CmdM);
      CMArgs.SectorsNeededI := StrToIntDef(CMArgs.SectorsNeededS, -1);
      {Wenn TAO, kommen am Ende noch 2 Sektoren dazu.}
      CMArgs.TaoEndSecCount := Integer(FSettings.DataCD.TAO) * 2;
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
    {Bei ContinueCD = True ohne vorige Sessions, also bei ForcedContinue = True,
     dürfen diese Parameter nicht verwendet werden.}
    if Multi and not CMArgs.ForcedContinue then
    begin
      if ContinueCD  then CmdM := CmdM + ' -cdrecord-params ' + FDisk.MsInfo
                                       + ' -prev-session ' + SCSIIF(Device);
      if not ContinueCD and (FDisk.MsInfo <> '') then
                          CmdM := CmdM + ' -cdrecord-params '  + FDisk.MsInfo;

    end;
    {cdrecord-Kommandozeile zusammenstellen}
    CmdC := ' gracetime=5 dev=' + SCSIIF(Device);
    if Erase       then CmdC := CmdC + ' blank=fast';       
    if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
    if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then CmdC := CmdC + ' driver=' + SimulDev + '_simul';
    if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
    if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
      CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then CmdC := CmdC + ' -v';
    if Dummy       then CmdC := CmdC + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        CmdC := CmdC + ' -force';
    if TAO and WritingModeRequired
                   then CmdC := CmdC + ' -tao';
    if DAO         then CmdC := CmdC + ' -dao';
    if RAW         then CmdC := CmdC + ' -' + RAWMode;
    if Overburn and (DAO or RAW) then
                        CmdC := CmdC + ' -overburn';
    if Multi and not LastSession
                   then CmdC := CmdC + ' -multi';
    {on-the-fly}
    if OnTheFly then
    begin
      {Falls OnTheFly und DAO ode RAW, muß die Sektoranzahl an cdrecord über-
       geben werden.
       Dies gilt auch, wenn mit cdrecord-ProDVD TAO geschrieben werden soll.}
      if (DAO or RAW or (TAO and FSettings.FileFlags.ProDVD)) and Ok then
      begin
        CmdC := CmdC + ' -tsize=' + CMArgs.SectorsNeededS + 's';
      end;
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
      if not FSplitOutput then
      begin
        CmdC := CmdC + ' ' + Temp;
      end else
      begin
        for i := 0 to Trunc((CMArgs.CDSize / (1024 * 1024 * 1024))) do   // 4
        begin
          CmdC := CmdC + ' ' +
                  QuotePath(MakePathConform(IsoPath + '_' +
                                            Format('%2.2d', [i])));
        end;
      end;
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
  BurnList.Free;
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
      Temp := FLang.GMS('mburn01');
      if (FDisk.DiskType <> DT_Unknown) and
         (not FSettings.DataCD.ImageOnly or FSettings.DataCD.OnTheFly) then
        Temp := Format(FLang.GMS('mburn14'),
                [FormatFloat('##0.###', CMArgs.SectorsNeededI / 512),
                  FormatFloat('##0.###', (FDisk.SecFree -
                      (CMArgs.SectorsNeededI + CMArgs.TaoEndSecCount)) / 512)])
                + Temp;
      i := ShowMsgDlg(Temp, FLang.GMS('mburn02'), MB_cdrtfe1);
    end else
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    if FSettings.DataCD.OnTheFly then
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
      if not FSettings.DataCD.ImageOnly then
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
    DeleteFile(FSettings.DataCD.PathListName);
    DeleteFile(FSettings.DataCD.ShCmdName);
    DummyDir(False);
  end;
end;

{ TCdrtfeActionDataCD - protected }

{ TCdrtfeActionDataCD - public }

constructor TCdrtfeActionDataCD.Create;
begin
  inherited Create;
  FVList := TStringList.Create;
  FReload := True;
  FDupSize := 0;
  FSplitOutput := False;
end;

destructor TCdrtfeActionDataCD.Destroy;
begin
  FVList.Free;
  inherited Destroy;
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCdrtfeActionDataCD.AbortAction;
begin
  inherited AbortAction;
  if FVerificationThread <> nil then TerminateVerification(FVerificationThread);
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionDataCD.CleanUp(const Phase: Byte);
var i   : Integer;
begin
  {Phase 1: TForm1.WMITerminated}
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    DeleteFile(FSettings.DataCD.PathListName);
    DeleteFile(FSettings.DataCD.ShCmdName);
    DummyDir(False);
    if not (FSettings.DataCD.ImageOnly or FSettings.DataCD.KeepImage) then
    begin
      if not FSplitOutput then
      begin
        DeleteFile(FSettings.DataCD.IsoPath);
      end else
      begin
        i := 0;
        while FileExists(FSettings.DataCD.IsoPath + '_' +
                         Format('%2.2d', [i])) do
        begin
          DeleteFile(FSettings.DataCD.IsoPath + '_' + Format('%2.2d', [i]));
          Inc(i);
        end;
      end;
    end;
  end;
  {Phase 3: TForm1.WMVTerminated}
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionDataCD.Reset;
begin
  FVList.Clear;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionDataCD.StartAction;
begin
  CreateDataDisk;
end;

{ StartVerification ------------------------------------------------------------

  Vergleich der Quelldateien mit den geschriebenen Dateien. Die Prozedur
  StartVerifyDataCD wird nicht verwendet, stattdessen wird der Thread hier
  direkt gestartet, weil auch der Fortschritt angezeigt werden soll. Dafür
  müßten aber zu viele Argumente an die Prozedur übergeben werden.
  Ein Verify ist sowohl für Daten- als auch für XCDs möglich.                  }

procedure TCdrtfeActionDataCD.StartVerification;
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
  Device := FSettings.DataCD.Device;
  FData.CreateVerifyList(FVList, cDataCD);
  Drive := FDevices.GetDriveLetter(Device);
  {Thread starten}
  FVerificationThread := TVerificationThread.Create(FVList, Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cVerify;
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

