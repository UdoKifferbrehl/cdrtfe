{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action.pas: die im GUI gewählte Aktion ausführen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  06.02.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action.pas implementiert ein Objekt, das für das Ausführen der im GUI aus-
  gwählten Aktion zuständig ist.


  TCDAction

    Properties   Action
                 Data
                 Devices
                 FormHandle
                 Lang
                 OnMessageShow
                 OnUpdatePanels
                 ProgressBar
                 Reload
                 Settings
                 StatusBar

    Methoden     CleanUp
                 Create
                 StartAction


  Anmerkungen:

  TCDAction hieß ursprünglich TAction und wurde umbenannt, da ab Delphi 4 eine
  Komponente TAction eingeführt wurde.

}

unit cl_action;

{$I directives.inc}

interface

uses Classes, Forms, StdCtrls, ComCtrls, Controls, Windows, SysUtils,
     cl_settings, cl_projectdata, cl_lang, cl_actionthread, cl_verifythread,
     cl_devices, cl_diskinfo, f_largeint, userevents;

type TCDAction = class(TObject)
     private
       FAction: Byte;
       FLastAction: Byte;
       FActionThread: TActionThread;
       FVerificationThread: TVerificationThread;
       FVList: TStringList;
       FData: TProjectData;
       FDevices: TDevices;
       FDisk : TDiskInfo;
       FDiskA: TDiskInfoA;
       FDiskM: TDiskInfoM;
       FReload: Boolean;
       FLang: TLang;
       // FTempBurnList: TStringList;
       FDupSize: Int64;
       FSplitOutput: Boolean;
       FEjectDevice: string;
       {Variablen zur Ausgabe}
       FFormHandle: THandle;
       FOnMessageShow: TMessageShowEvent;
       FOnUpdatePanels: TUpdatePanelsEvent;
       FSettings: TSettings;
       FStatusBar: TStatusBar;
       FProgressBar: TProgressBar;
       function GetAction: Byte;
       function GetFormatCommand: string;
       function MakePathConform(const Path: string): string;
       function MakePathEntryMkisofsConform(const Path: string): string;
       function GetSectorNumber(const MkisofsOptions: string): string;
       procedure CheckSpaceForImage(var Ok: Boolean; const Path: string; const Sectors: Integer; Size: Int64);
       procedure CreateAudioCD;
       procedure CreateDataDisk;
       procedure CreateVideoCD;
       procedure CreateVideoDVD;
       procedure CreateXCD;
       procedure CreateXCDInfoFile(List: TStringList);
       procedure CreateRrencInputFile(List: TStringList);
       procedure DAEGrabTracks;
       procedure DAEReadTOC;
       procedure DeleteCDRW;
       procedure Eject;
       procedure FindDuplicateFiles(List: TStringList);
       procedure GetCDInfos;
       procedure ReadImage;
       procedure SetPanels(const s1, s2: string);
       procedure StartVerification(const Action: Byte);
       procedure WriteImage;
       procedure WriteImageCopy;
       procedure WriteTOC;
       procedure SetFSettings(Value: TSettings);
       {Events}
       procedure MessageShow(const s: string);
       procedure UpdatePanels(const s1, s2: string);
     public
       constructor Create;
       destructor Destroy; override;
       procedure AbortAction;
       procedure CleanUp(const Phase: Byte);
       procedure Reset;
       procedure StartAction;
       property Action: Byte read GetAction write FAction;
       property LastAction: Byte read FLastAction;
       property Data: TProjectData write FData;
       property Devices: TDevices write FDevices;
       property FormHandle: THandle write FFormHandle;
       property Lang: TLang write FLang;
       property StatusBar: TStatusBar read FStatusBar write FStatusBar;
       property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
       property Reload: Boolean read FReload write FReload;
       property Settings: TSettings write SetFSettings;
       property DuplicateFileSize: Int64 read FDupSize write FDupSize;
       {Events}
       property OnMessageShow: TMessageShowEvent read FOnMessageShow write FOnMessageShow;
       property OnUpdatePanels: TUpdatePanelsEvent read FOnUpdatePanels write FOnUpdatePanels;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}          f_logfile,
     f_filesystem, f_getdosoutput, f_environment, f_cygwin, f_strings, f_init,
     f_dischelper, cl_cueinfo, usermessages, const_tabsheets, const_common,
     f_locations, const_locations, f_helper, f_window;

{ TCDAction ------------------------------------------------------------------ }

{ TCDAction - private }

{ SetFSettings -----------------------------------------------------------------

  setzt die Eigenschaft Settings und die Feldvariable FDisk in Abhängigkeit der
  Daten in FSettings.                                                          }

procedure TCDAction.SetFSettings(Value: TSettings);
begin
  FSettings := Value;
  case FSettings.Cdrecord.HaveMediaInfo of
    True : FDisk := FDiskM;
    False: FDisk := FDiskA;
  end;
end;

{ MessageShow ------------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TCDAction.MessageShow(const s: string);
begin
  if Assigned(FOnMessageShow) then FOnMessageShow(s);
end;

{ UpdatePanels -----------------------------------------------------------------

  Löst das Event OnUpdatePanels aus, das das Hauptfenster veranlaßt, die Panel-
  Texte der Statusleiste zu aktualisieren.                                     }

procedure TCDAction.UpdatePanels(const s1, s2: string);
begin
  if Assigned(FOnUpdatePanels) then FOnUpdatePanels(s1, s2);
end;

{ SetPanels --------------------------------------------------------------------

  SetPanels zeigt s1 und s2 in der Statusleiste an.                            }

procedure TCDAction.SetPanels(const s1, s2: string);
begin
  UpdatePanels(s1, s2);
end;

{ GetAction --------------------------------------------------------------------

  GetAction liefert den Wert von FAction und setzt ihn auf cNoAction.          }

function TCDAction.GetAction: Byte;
begin
  Result := FAction;
  FLastAction := FAction;
  FAction := cNoAction;
end;

{ FindDuplicateFiles -----------------------------------------------------------

  FindDuplicateFiles sucht in der Pfadliste nach Dateiduplikaten.              }

procedure TCDAction.FindDuplicateFiles(List: TStringList);
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

{ CreateXCDInfoFile ------------------------------------------------------------

  CreateXCDInfoFile erzeugt die Info-Datei xcd.crc, in der die ursprünglichen
  Dateigrößen der Form2-Dateien sowie deren CRC32-Prüfsumme gespeichert sind.  }

procedure TCDAction.CreateXCDInfoFile(List: TStringList);
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
  FVerificationThread.XCD := True;
  FVerificationThread.Action := cCreateInfoFile;
  FVerificationThread.TotalSize := CDSize;
  FVerificationThread.StatusBar := FStatusBar;
  {Thread starten}
  FVerificationThread.Resume;
end;

{ MakePathConform --------------------------------------------------------------

  Bei FSettings.FileFlags.Mingw = True ist der normale Windowspfad das Ergebnis,
  andernfalls wird das Ergebnis aus MakePathCygwinConform(Path) zurückgegeben. }

function TCDAction.MakePathConform(const Path: string): string;
begin
  if FSettings.FileFlags.Mingw then
  begin
    Result := Path;
  end else
  begin
    Result := MakePathCygwinConform(Path);
  end;
end;

{ MakePathEntryMkisofsConform --------------------------------------------------

  bereitet den Pfadlisten-Eintrag für mkisofs auf, wobei die Cygwin- und Mingw-
  Version unterschiedlich behandelt werden müssen.                             }

function TCDAction.MakePathEntryMkisofsConform(const Path: string): string;
begin
  if FSettings.FileFlags.Mingw then
  begin
    Result := MakePathMingwMkisofsConform(Path);
  end else
  begin
    Result := MakePathMkisofsConform(Path);
  end;
end;

{ XCDCreateProtectionFile ------------------------------------------------------

  konvertiert die Pfadliste in eine für rrenc geeignete Liste.                 }

procedure TCDAction.CreateRrencInputFile(List: TStringList);
var RrencList: TStringList;
begin
  RrencList := TStringList.Create;
  RrencList.Capacity := 1;
  ConvertXCDParamListToRrencInputList(List, RrencList);
  List.Add('-d' + CRLF + '_rec_');
  List.Add('-f' + CRLF + FSettings.XCD.XCDRrencRRTFile);
  List.Add('-m' + CRLF + FSettings.XCD.XCDRrencRRDFile);
  { El-Gi: for adding rrenc.exe and rrdec.exe into XCD disc }
  if FSettings.FileFlags.RrencOK then begin
     List.Add( '-f' + CRLF + StartUpDir + cRrencBin + cExtExe );
     RrencList.Add( '-f ' + StartUpDir + cRrencBin + cExtExe );
  end;
  if FSettings.FileFlags.RrdecOK then begin
     List.Add( '-f' + CRLF + StartUpDir + cRrdecBin + cExtExe );
     RrencList.Add( '-f ' + StartUpDir + cRrdecBin + cExtExe );
  end;
  RrencList.SaveToFile(FSettings.XCD.XCDRrencInputFile);
  RrencList.Free;
end;

{ Eject ------------------------------------------------------------------------

  wirft, falls gewünscht, die CD/DVD aus.                                      }

procedure TCDAction.Eject;
begin
  if FSettings.Cdrecord.Eject and not FSettings.Cdrecord.Dummy then
  begin
    {Wenn nur ein Image erstellt wurde, bleibt das Laufwerk zu.}
    if ((FLastAction = cDataCD) and FSettings.DataCD.ImageOnly) or
       ((FLastAction = cXCD) and FSettings.XCD.ImageOnly) or
       ((FLAstAction = cVIdeoCD) and FSettings.VideoCD.ImageOnly) then
      FEjectDevice := '';
    if FEjectDevice <> '' then EjectDisk(FEjectDevice);
  end;
  FEjectDevice := '';
end;

{ GetSectorNumber --------------------------------------------------------------

  bestimmt die Länge des Datentracks in Sektoren. Nötig für DAO/RAW.           }

function TCDAction.GetSectorNumber(const MkisofsOptions: string): string;
var CmdGetSize: string;
    Sectors   : string;
    Temp      : string;
    Output    : TStringList;
    i, p      : Integer;
begin
  SetPanels('<>', FLang.GMS('mburn12'));
  Result := '';
  Output := TStringList.Create;
  CmdGetsize := StartUpDir + cMkisofsBin;
  CmdGetSize := QuotePath(CmdGetSize);
  CmdGetsize := CmdGetSize + ' -print-size -quiet' + MkisofsOptions;
  Output.Text := GetDosOutput(PChar(CmdGetsize), True, True);
  Sectors := Trim(Output.Text);
  p := LastDelimiter(LF, Sectors);
  if p > 0 then Delete(Sectors, 1, p);
  if StrToIntDef(Sectors, -1) >= 0 then Result := Sectors else
  begin
    Temp := ExtractFileName(cMkisofsBin);
    MessageShow(Temp + ' -print-size failed.');
    MessageShow('  Commandline was: ' + CmdGetsize);
    for i := 0 to Output.Count - 1 do
    begin
      Sectors := Output[i];
      if Pos(Temp, Sectors) > 0 then
      begin
        Delete(Sectors, 1, Pos(':', Sectors));
        MessageShow('  Errormessage   : ' + Sectors);
      end;
    end;
  end;
  Output.Free;
  SetPanels ('<>', '');
end;

{ GetFormatCommand -------------------------------------------------------------

  liefert, falls nötig die Befehlszeile zum Formatieren einer DVD+RW.          }

function TCDAction.GetFormatCommand: string;
begin
  Result := '';
  if FSettings.Cdrecord.AllowFormat then
  begin
    if FDisk.ForcedFormat and not FSettings.Cdrecord.Dummy and
       not FSettings.Cdrecord.SimulDrv then
    begin
      Result := FDisk.FormatCommand + CR;
    end;
  end;
end;

{ CheckSpaceForImage -----------------------------------------------------------

  prüft, ob genügen Platz für die Image-Datei vorhanden ist.                   } 

procedure TCDAction.CheckSpaceForImage(var Ok: Boolean; const Path: string;
                                       const Sectors: Integer; Size: Int64);
var Temp, Drive: string;
    Sectors64  : Int64;
    SizeFree   : Int64;
begin
  if Ok then
  begin
    Drive := ExtractFileDrive(Path);
    SizeFree := GetFreeSpaceDisk(Drive);
    if Size = 0 then
    begin
      Sectors64 := Sectors;
      Size := (Sectors64 * 2048);
    end;
    Ok := Size < SizeFree;
    if not Ok then
    begin
      Temp := Format(FLang.GMS('eburn20'), [Drive]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_OK or MB_ICONSTOP);
    end;
  end;
end;

{ CreateDataDisk ---------------------------------------------------------------

  Daten-CDs, -DVDs erstellen und fortsetzen.                                   }

procedure TCDAction.CreateDataDisk;
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

{ CreateAudioCD ----------------------------------------------------------------

  Eine Audio-CD erstellen.                                                     }

procedure TCDAction.CreateAudioCD;
var i         : Integer;
    Ok        : Boolean;
    CMArgs    : TCheckMediumArgs;
    DummyI    : Integer;
    DummyL    : Int64;
    Temp      : string;
    Cmd, CmdMP: string;
    CmdRG     : string;
    BurnList  : TStringList;
    CopyList  : TStringList;

  { PrepareCompressedToWavConversion -------------------------------------------

    PrepareCompressedToWavConversion bereitet die Konvertierung der MP3-, Ogg-,
    FLAC- und Ape-Dateien in Wave-Dateien vor, d.h. die BurnList wird angepaßt
    und die entsprechenden Madplay-, Oggdec- oder flac-Aufrufe werden generiert.
    Die Namen der temporären Dateien werden in FVList gespeichert.             }

  procedure PrepareCompressedToWavConversion;
  var j             : Integer;
      Source, Target: string;
      CmdTemp       : string;
      Ext           : string;
  begin
    CmdMP := '';
    for j := 0 to BurnList.Count - 1 do
    begin
      CmdTemp := '';
      Source := BurnList[j];
      Ext := LowerCase(ExtractFileExt(BurnList[j]));
      if (Ext <> cExtWav) then
      begin
        Target := FSettings.General.TempFolder + '\' +
                  ExtractFileName(Source) + cExtWav;
        BurnList[j] := Target;
        if (Ext = cExtMP3) then
        begin
          CmdTemp := StartUpDir + cMadplayBin +
                     ' -v -S -b 16 -R 44100 -o wave:' +
                     QuotePath(Target) + ' ' + QuotePath(Source) + CR
        end else
        if (Ext = cExtOgg) then
        begin
          CmdTemp := StartUpDir + cOggdecBin + ' -b 16 -o ' +
                     QuotePath(Target) + ' ' + QuotePath(Source) + CR
        end else
        if (Ext = cExtFlac) then
        begin
          CmdTemp := StartUpDir + cFLACBin + ' -d ' + QuotePath(Source) +
                     ' -o ' + QuotePath(Target) + CR
        end else
        if (Ext = cExtApe) then
        begin
          CmdTemp := StartUpDir + cMonkeyBin + ' ' + QuotePath(Source) + ' ' +
                     QuotePath(Target) + ' -d' + CR
        end;
        FVList.Add(Target);
      end;
      CmdMP := CmdMP + CmdTemp;
    end;
  end;

  { PrepareCopyWaveFiles, PrepareWaveGain, CopyWaveFiles -----------------------

    Da WaveGain die Originaldateien verändert müssen Wave-Dateien vorher kopiert
    werden.                                                                    }

  procedure PrepareCopyWaveFiles;
  var j             : Integer;
      Source, Target: string;
      Ext           : string;
  begin
    for j := 0 to BurnList.Count - 1 do
    begin
      Source := BurnList[j];
      Ext := LowerCase(ExtractFileExt(BurnList[j]));
      if (Ext = cExtWav) then
      begin
        Target := FSettings.General.TempFolder + '\' +
                  ExtractFileName(Source);
        BurnList[j] := Target;
        FVList.Add(Target);
        CopyList.Add(Source + '|' + Target);
      end;
    end;
  end;

  procedure CopyWaveFiles;
  var j             : Integer;
      Source, Target: string;
  begin
    for j := 0 to CopyList.Count - 1 do
    begin
      SplitString(CopyList[j], '|', Source, Target);
      MessageShow(FLang.GMS('m125'));
      MessageShow('  ' + Source + ' -> ' + Target + CRLF);
      Copyfile(PChar(Source), PChar(Target), False);
    end;
  end;

  procedure PrepareWaveGain;
  var j      : Integer;
      CmdTemp: string;
      GainStr: string;
  begin
    CmdRG := '';
    GainStr := '';
    if FSettings.AudioCD.Gain <> '' then
      GainStr := '-g ' + FSettings.AudioCD.Gain + ' ';
    for j := 0 to BurnList.Count - 1 do
    begin
      CmdTemp := StartUpDir + cWavegainBin + ' -c -y ' + GainStr +
                 QuotePath(BurnList[j]) + CR;
      CmdRG := CmdRG + CmdTemp;
    end;
  end;

begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  BurnList := TStringList.Create;
  CopyList := TStringList.Create;
  FData.CreateBurnList(BurnList, cAudioCD);
  CMArgs.Choice := cAudioCD;
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}
  {Spielzeit ermitteln}
  FData.GetProjectInfo(DummyI, DummyI, DummyL, CMArgs.CDTime, DummyI, cAudioCD);
  {Infos über eingelegte CD einlesen}
  SetPanels('<>', FLang.GMS('mburn13'));
  FDisk.GetDiskInfo(FSettings.AudioCD.Device, True);
  SetPanels('<>', '');
  Ok := FDisk.CheckMedium(CMArgs);
  {Falls WaveGain verwendet wird, müssen WAV-Dateien kopiert werden!}
  if FSettings.AudioCD.ReplayGain then PrepareCopyWaveFiles;
  {falls komprimierte Audio-Dateien vorhanden sind, Konvertierung vorbereiten}
  if FData.CompressedAudioFilesPresent then PrepareCompressedToWavConversion;
  {auf kopierte WAVs und konvertierte Files WaveGain anwenden}
  if FSettings.AudioCD.ReplayGain then PrepareWaveGain;
  {Pfadliste bearbeiten}
  for i := 0 to (BurnList.Count - 1) do
  begin
    {_alle_ Pfadangaben Cygwin-konform machen!}
    BurnList[i] := MakePathConform(BurnList[i]);
  end;
  {CD-Text-Datei erstellen}
  if FSettings.AudioCD.CDText and FData.CDTextPresent then
  begin
    FSettings.AudioCD.CDTextFile := ProgDataDir + cCDTextFile;
    FData.CreateCDTextFile(FSettings.AudioCD.CDTextFile);
  end;
  {Kommandozeile für cdrecord}
  with FSettings.AudioCD, FSettings.Cdrecord do
  begin
    Cmd := StartUpDir + cCdrecordBin;
    Cmd := QuotePath(Cmd);
    Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(Device);
    if Erase       then Cmd := Cmd + ' blank=fast';
    if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
    if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
    if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        Cmd := Cmd + ' -force';
    if TAO and WritingModeRequired
                   then Cmd := Cmd + ' -tao';
    if DAO         then Cmd := Cmd + ' -dao';
    if RAW         then Cmd := Cmd + ' -' + RAWMode;
    if Overburn and (DAO or RAW) then
                        Cmd := Cmd + ' -overburn';
    if Multi       then Cmd := Cmd + ' -multi';
    if not Fix     then Cmd := Cmd + ' -nofix';
    if UseInfo     then Cmd := Cmd + ' -useinfo';
    if CDText      then Cmd := Cmd + ' -text';
    if CDText and FData.CDTextPresent then
                        Cmd := Cmd + ' textfile='
                                   + QuotePath(MakePathConform(CDTextFile));
    if Preemp      then Cmd := Cmd + ' -preemp';
    if Copy        then Cmd := Cmd + ' -copy';
    if SCMS        then Cmd := Cmd + ' -scms';
    Cmd := Cmd + ' -pad';
    for i := 0 to (BurnList.Count - 1) do
    begin
      {padsize für die TrackPausen}
      if (Pause > 0) and not UseInfo then
      begin
        if Pause = 1 then Temp := PauseLength else
                          Temp := FData.GetTrackPause(i);
        if PauseSector then
        begin
          {Länge lieft bereits in Sektoren vor}
          Cmd := Cmd + ' padsize=' + Temp + 's';
        end else
        begin
          {Umrechnen: Sekunden -> Sektoren}
          Temp := IntToStr(StrToInt(Temp) * 75);
          Cmd := Cmd + ' padsize=' + Temp + 's';
        end;
      end;
      {Dateiname}
      BurnList[i] := QuotePath(BurnList[i]);
      Cmd := Cmd + ' ' + BurnList[i];
    end;
  end;
  BurnList.Free;
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'), MB_cdrtfe1);
    end else
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    if Fsettings.AudioCD.ReplayGain then CopyWaveFiles;
    if CmdRG <> '' then Cmd := CmdRG + Cmd;   
    if CmdMP <> '' then Cmd := CmdMP + Cmd;
    DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.AudioCD.CDTextFile);
  end;
  CopyList.Free;
end;

{ CreateXCD --------------------------------------------------------------------

  Image für eine XCD erstellen oder XCD brennen.                               }

procedure TCDAction.CreateXCD;
var i              : Integer;
    CmdMode2CDMaker: string;
    CmdRrenc       : string;
    CmdC           : string;
    Temp           : string;
    M2CDMOptions   : string;
    Ok             : Boolean;
    BurnList       : TStringList;
    Size           : Int64;
    DummyE         : Extended;
    DummyI         : Integer;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  Ok := True;
  {Größe der Daten ermitteln}
  FData.GetProjectInfo(DummyI, DummyI, Size, DummyE, DummyI, cXCD);
  CheckSpaceForImage(Ok, FSettings.XCD.IsoPath, 0, Size);
  {Dateiliste übernehmen}
  BurnList := TStringList.Create;
  FData.CreateBurnList(BurnList, cXCD);
  {xcd.crc erzeugen}
  if FSettings.XCD.CreateInfoFile  and Ok then
  begin
    FSettings.XCD.XCDInfoFile := ProgDataDir + cXCDInfoFile;
    if FVList.Count = 0 then
    begin
      FVList.Assign(BurnList);
      CreateXCDInfoFile(FVList);
      Burnlist.Free;
      {zurück zum Hauptthread}
      Exit;
    end else
    begin
      FVList.Clear;
    end;
  end;
  {Kommandozeile für mode2cdmaker zusammenstellen: bis 0.8.x wurde alles in die
   Kommandozeile geschrieben. Ab 0.9 werden alle Optionen und Dateinamen in der
   Datei xcd.txt abgelegt, die als Parameterdatei übergeben wird.}
  with FSettings.XCD, FSettings.Cdrecord, FSettings.Cdrdao do
  begin
    XCDParamFile := ProgDataDir + cXCDParamFile;
    XCDRrencInputFile := ProgDataDir + cRrencInputFile;
    XCDRrencRRTFile := ProgDataDir + cRrencRRTFile;
    XCDRrencRRDFile := ProgDataDir + cRrencRRDFile;
    CmdMode2CDMaker := StartUpDir + cMode2CDMakerBin;
    CmdMode2CDMaker := QuotePath(CmdMode2CDMaker);
    CmdMode2CDMaker := CmdMode2CDMaker + ' -paramfile ';
    if (UseErrorProtection and FSettings.FileFlags.RrencOk) then
      { El-Gi: mode2cdmaker's input from rrenc }
      CmdMode2CDMaker := CmdMode2CDMaker + QuotePath(IsoPath + cExtUm2) else
      CmdMode2CDMaker := CmdMode2CDMaker + QuotePath(XCDParamFile);
    M2CDMOptions := cMode2CDMakerBin;
    M2CDMOptions := M2CDMOptions + ' -o "' + IsoPath + '"';
    BurnList.Insert(0, '-o');
    BurnList.Insert(1, IsoPath);
    if VolID <> '' then
    begin
      M2CDMOptions := M2CDMOptions + ' -v "' + VolID + '"';
      BurnList.Insert(0, '-v');
      BurnList.Insert(1, VolID);
    end;
    if Ext <> '' then
    begin
      M2CDMOptions := M2CDMOptions + ' -e "' + Ext + '"';
      BurnList.Insert(0, '-e');
      BurnList.Insert(1, Ext);
    end;
    if IsoLevel2 then
    begin
      M2CDMOptions := M2CDMOptions + ' -isolevel2';
      BurnList.Insert(0, '-isolevel2');
    end;
    if IsoLevel1 then
    begin
      M2CDMOptions := M2CDMOptions + ' -isolevel1';
      BurnList.Insert(0, '-isolevel1');
    end;
    if Single then
    begin
      M2CDMOptions := M2CDMOptions + ' -s';
      BurnList.Insert(0, '-s');
    end;
    if KeepExt then
    begin
      M2CDMOptions := M2CDMOptions + ' -x';
      BurnList.Insert(0, '-x');
    end;
    {XCD-Error-Protection mit rrenc}
    if UseErrorProtection and FSettings.FileFlags.RrencOk then
    begin
      CreateRrencInputFile(BurnList);
      Temp := '';
      if Verbose    then Temp := Temp + 'v';
      { El-Gi: slightly reorder command-line options for rrenc }
      if KeepExt    then Temp := Temp + 'x';
      if not Single then Temp := Temp + 'u';
      if Ext = ''   then Temp := Temp + 'e dat' else
                         Temp := Temp + 'e ' + Ext;
      { El-Gi: for debug under MS Visual Studio }
      CmdRrenc := { 'msdev ' + } StartUpDir + cRrencBin + { '.exe' + }
      { El-Gi: --ansi-charset }
                  ' -awid' + Temp +
                  ' -@ ' + QuotePath(XCDRrencInputFile) +
                  ' -o ' + QuotePath(IsoPath) +
                  ' -l "' + VolID + '" ' +
                  {'-r ' + StartUpDir + '\rrd_head.mkv' + ' ' +}
                  IntToStr(SecCount) + ' ' + QuotePath(XCDRrencRRTFile) + ' ' +
                  QuotePath(XCDRrencRRDFile);
                  CmdMode2CDMaker := CmdRrenc + CR + CmdMode2CDMaker;
    end;
    {Parameter-Liste speichern:}
    BurnList.SaveToFile(XCDParamFile);
    BurnList.Free;
    {Dateinamen bearbeiten}
    Temp := IsoPath + cExtCue;
    Temp := MakePathConform(Temp);
    Temp := QuotePath(Temp);
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
      CmdC := CmdC + ' ' + Temp;
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
      CmdC := CmdC + ' -dao cuefile=' + Temp;
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'), MB_cdrtfe1);
    end else
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    MessageShow(FLang.GMS('mburn10'));
    MessageShow(M2CDMOptions);
    if not (FSettings.XCD.ImageOnly or (CmdC = '')) then
    begin
      DisplayDOSOutput(CmdMode2CDMaker + CR + CmdC, FActionThread, FLang, nil);
    end else
    begin
      DisplayDOSOutput(CmdMode2CDMaker, FActionThread, FLang, nil);
    end;
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.XCD.XCDParamFile);
    DeleteFile(FSettings.XCD.XCDRrencInputFile);
    if DeleteFile(FSettings.XCD.XCDInfoFile) then
      FData.DeleteFromPathlistByName(ExtractFileName(FSettings.XCD.XCDInfoFile),
                                     '', cXCD);
  end;
end;

{ DeleteCDRW -------------------------------------------------------------------

  DeleteCDRW löscht CD-RWs bzw. Teile davon.                                   }

procedure TCDAction.DeleteCDRW;
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
      i := ShowMsgDlg(FLang.GMS('mburn05'), FLang.GMS('mburn06'), MB_cdrtfe1);
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

{ GetCDInfos -------------------------------------------------------------------

  Infos anzeigen: -scanbus, -prcap, -atip, -toc, -msinfo.                      }

procedure TCDAction.GetCDInfos;
var Cmd: string;
    Temp: string;
    Ok: Boolean;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  if not FSettings.CDInfo.CapInfo then
  begin
    Cmd := StartUpDir + cCdrecordBin;
    Cmd := QuotePath(Cmd);
    with FSettings.CDInfo do
    begin
      if Scanbus then
      begin
        if FSettings.Drives.UseRSCSI then
          Cmd := Cmd + ' dev=' + FSettings.Drives.RSCSIString;
        if SCSIIF('') <> '' then Cmd := Cmd + ' dev=' + SCSIIF('');
        Cmd := Cmd + ' -scanbus'
      end else
      begin
        Cmd := Cmd + ' dev=' + SCSIIF(Device);
        if Prcap  then Cmd := Cmd + ' -prcap'  else
        if Toc    then Cmd := Cmd + ' -toc'    else
        if Atip   then Cmd := Cmd + ' -atip'   else
        if MSInfo then Cmd := Cmd + ' -msinfo' else
        if MInfo  then Cmd := Cmd + ' -minfo';
      end;
    end;
    if FSettings.Cdrecord.Verbose then Cmd := Cmd + ' -v';
    {Kommando ausführen}
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
    Ok := True;
    {Kapazitäten des Rohlings ausgeben:
     Infos über eingelegte CD einlesen}
    SetPanels('<>', FLang.GMS('mburn13'));
    FDisk.GetDiskInfo(FSettings.CDInfo.Device, True);
    SetPanels('<>', '');
    {keine CD}
    if (FDisk.Size = 0) and (FDisk.MsInfo = '') then
    begin
      MessageShow(FLang.GMS('eburn01'));
      Ok := False;
    end;
    {fixierte CD}
    if Pos('-1', FDisk.MsInfo) <> 0 then
    begin
      MessageShow(FLang.GMS('mburn09'));
      Ok := False;
    end;
    {Gesamtkapazität}
    if Ok then
    begin
      Temp := Format(FLang.GMS('mburn07'),
              [FormatFloat(' ##0.##', FDisk.Size),
               IntToStr(Round(Int(FDisk.Time)) div 60),
               FormatFloat('0#.##',
                         (FDisk.Time - (Round(Int(FDisk.Time)) div 60) * 60))]);
      MessageShow(Temp);
      {noch frei}
      Temp := Format(FLang.GMS('mburn08'),
              [FormatFloat(' ##0.##', FDisk.SizeFree),
               IntToStr(Round(Int(FDisk.TimeFree)) div 60),
               FormatFloat('0#.##',
                  (FDisk.TimeFree - (Round(Int(FDisk.TimeFree)) div 60) * 60))]);
      MessageShow(Temp);
    end;
    MessageShow('');
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ DAEReadTOC -------------------------------------------------------------------

  DAEReadTOC liest die TOC einer AudioCD aus und speichert die Informationen
  in FData.DAE.TrackList.                                                      }

procedure TCDAction.DAEReadTOC;
var Output     : TStringList;
    TrackList  : TStringList;
    CommandLine: string;
    CDPresent  : Boolean;

  { UnescapeString -------------------------------------------------------------

    UnescapeString entfernt Anführungszeichen am Anfang und Ende sowie '\' als
    Esacpe-Zeichen.                                                            }

  function UnescapeString(s: string): string;
  begin
    if Pos('''', s) = 1 then Delete(s, 1, 1);
    if s[Length(s)] = '''' then Delete(s, Length(s), 1);
    while Pos('\', s) > 0 do
    begin
      Delete(s, Pos('\', s), 1);
    end;
    Result := s;
  end;

  { ExtractTrackInfo -----------------------------------------------------------

    ExtractTrackInfo baut die einzelnen Zeilen der cdda2wav-Ausgabe um.        }

  procedure ExtractTrackInfo(List: TStringList);
  var i         : Integer;
      Temp      : string;
      p         : Integer;
      Seconds   : Double;
      Sectors   : Integer;
      Size      : Double;
      APerformer: string;
      Performer : string;
      Title     : string;
      NameString: string;
      SizeString: string;
      TimeString: string;
  begin
    {Album-Performer}
    Temp := List.Text;
    Delete(Temp, 1, Pos('Album title:', Temp));
    Temp := Trim(Copy(Temp, 1, Pos(CR, Temp)));
    Delete(Temp, 1, Pos('from', Temp) + 4);
    APerformer := UnescapeString(Temp);
    {$IFDEF DebugReadAudioTOC}
    FormDebug.Memo1.Lines.Add(APerformer);
    FormDebug.Memo1.Lines.Add('');
    {$ENDIF}
    {Alles Löschen, was keine Trackinfos sind.}
    for i := List.Count - 1 downto 0 do
    begin
      if not ((Pos('T', List[i]) = 1) and (Pos(':', List[i]) = 4)) or
         (Pos('audio', List[i]) = 0) then
      begin
        List.Delete(i);
      end
    end;
    {$IFDEF DebugReadAudioTOC}
    AddCRStringToList(Output.Text, FormDebug.Memo1.Lines);
    FormDebug.Memo1.Lines.Add('');
    {$ENDIF}
    {Für jeden Track die Infos zusammenstellen.}
    for i := 0 to List.Count - 1 do
    begin
      {Laufzeit}
      TimeString := Trim(Copy(List[i], 13, 9));
      Temp := TimeString;
      p := Pos(':', Temp);
      Seconds := StrToIntDef(Copy(Temp, 1, p - 1), 0) * 60;
      Delete(Temp, 1, p);
      p := Pos('.', Temp);
      Seconds := Seconds + StrToIntDef(Copy(Temp, 1, p - 1), 0);
      {Größe}
      Delete(Temp, 1, p);
      Sectors := StrToIntDef(Temp, 0);
      Size := (((Seconds * 75) + Sectors) * 2352) / 1024;
      SizeString := FormatFloat('#,###,##0 KiByte', Size);
      {Titel und Interpret}
      Temp := List[i];
      p := Pos('title', Temp);
      Delete(Temp, 1, p + 5);
      p := Pos('from', Temp);
      Title := UnescapeString(Copy(Temp, 1, p - 2));
      Delete(Temp, 1, p + 4);
      Performer := UnescapeString(Trim(Temp));
      if (Performer = '') and (Title <> '') then Performer := APerformer;
      {Trackname}
      NameString := Format('Track %.2d', [i + 1]);
      {Neuen Eintrag zusammenstellen.}
      List[i] :=  NameString + ':' + TimeString + '*' + SizeString +
                  '|' + Title + '|' + Performer;
    end;
  end;

begin
  {$IFDEF DebugReadAudioTOC}
  FormDebug.Memo1.Lines.Add('Reading TOC ...');
  {$ENDIF}
  Output := TStringList.Create;
  {feststellen, ob CD eingelegt ist, sonst würde cdda2wav auf Benutzereingabe
   warten}
  CDPresent := DiskInserted(SCSIIF(FSettings.DAE.Device));
  {Toc auslesen}
  CommandLine := StartUpDir + cCdda2wavBin;
  CommandLine := QuotePath(CommandLine);
  CommandLine := CommandLine + ' dev=' + SCSIIF(FSettings.DAE.Device) +
                 ' verbose-level=toc -gui -info-only -no-infofile';
  if FSettings.DAE.UseCDDB then
  begin
    CommandLine := CommandLine + ' cddb=1';
    if FSettings.DAE.CDDBServer <> '' then
      CommandLine := CommandLine + ' -cddbp-server=' + FSettings.DAE.CDDBServer;
    if FSettings.DAE.CDDBPort <> '' then
      CommandLine := CommandLine + ' -cddbp-port=' + FSettings.DAE.CDDBPort;
  end;
  if CDPresent then
  begin
    Output.Text := GetDOSOutput(PChar(CommandLine), True, False);
    {$IFDEF DebugReadAudioTOC}
    AddCRStringToList(Output.Text, FormDebug.Memo1.Lines);
    FormDebug.Memo1.Lines.Add('');
    {$ENDIF}
    {TrackListe zuweisen}
    TrackList := FData.GetFileList('', cDAE);
    TrackList.Assign(Output);
    {Aus der cdda2wav-Ausgabe die Infos herausholen.}
    ExtractTrackInfo(TrackList);
    {$IFDEF DebugReadAudioTOC}
    FormDebug.Memo2.Lines.Assign(TrackList);
    {$ENDIF}
    if TrackList.Count = 0 then
    begin
      ShowMsgDlg(FLang.GMS('everify04'), FLang.GMS('g001'),
                 MB_OK or MB_ICONWARNING);
    end;
  end else
      ShowMsgDlg(FLang.GMS('eburn01'), FLang.GMS('g001'),
                 MB_OK or MB_ICONWARNING);
  Output.Free;
end;

{ DAEGrabTracks ----------------------------------------------------------------

  DAEGrabTracks liest die ausgewählte Titel aus.                               }

procedure TCDAction.DAEGrabTracks;
var Compressed: Boolean;

  { GetCustomName --------------------------------------------------------------

    erzeugt aus dem Pattern und den CD-Infos den Dateinamen.                   }

  function GetCustomName(const Info: string; Index: Integer;
                         var Title, Performer, Name: string): string;
  var NameTemp,
      TitleTemp,
      PerformerTemp,
      Temp      : string;
  begin
    {Infos ermitteln.}
    NameTemp := StringLeft(Info, ':');
    SplitString(Info, '|', TitleTemp, TitleTemp);
    PerformerTemp := TitleTemp;
    TitleTemp := StringLeft(TitleTemp, '|');
    PerformerTemp := StringRight(PerformerTemp, '|');
    {Aus dem Pattern den Dateinamen machen.}
    Temp := FSettings.DAE.NamePattern;
    Temp := ReplaceString(Temp, '%T', TitleTemp);
    Temp := ReplaceString(Temp, '%P', PerformerTemp);
    Temp := ReplaceString(Temp, '%N', Format('%.2d', [Index + 1]));
    if (TitleTemp = '') and (PerformerTemp = '') then Temp := NameTemp;
    Title := TitleTemp;
    Performer := PerformerTemp;
    Name := NameTemp;
    Result := Temp;
  end;

  { Cdda2wavStdCmdLine ---------------------------------------------------------

    erzeugt die unveränderlichen Bestandteile der Kommandozeile.               }

  function Cdda2wavStdCmdLine: string;
  var CommandLine : string;
      VerboseLEvel: string;
  begin
    case FSettings.DAE.DoCopy of
      True : VerboseLevel := 'all';
      False: VerboseLevel := 'summary';
    end;
    {unveränderlichen Teil der Kommandozeile zusammenstellen}
    with FSettings.DAE do
    begin
      CommandLine := ' dev=' + SCSIIF(Device);
      if Speed <> ''    then CommandLine := CommandLine + ' speed=' + Speed;
      CommandLine := CommandLine + ' verbose-level=' + VerboseLevel; //'summary'
      CommandLine := CommandLine + ' -gui';
      if Paranoia       then CommandLine := CommandLine + ' -paranoia';
      if Bulk or DoCopy then CommandLine := CommandLine + ' -bulk';
      if NoInfoFile
         and not DoCopy then CommandLine := CommandLine + ' -no-infofile';
      if Offset <> ''   then CommandLine := CommandLine + ' -offset ' + Offset;
    end;
    Result := CommandLine;
  end;

  { GetCommandLineCompress -----------------------------------------------------

    erzeugt den Aufruf für das Komprimierungstool.                             }

  function GetCommandLineCompress(const Info: string; Index: Integer): string;
  var Cmd      : string;
      OutName  : string;
      CustExt  : string;
      CustOpt  : string;
      Ext      : string;
      Name,
      Title,
      Performer: string;
  begin
    Cmd := '';
    OutName := GetCustomName(Info, Index, Title, Performer, Name);
    if FSettings.DAE.PrefixNames then
      OutName := FSettings.DAE.Prefix + Format('_%.2d', [Index + 1]);
    if FSettings.DAE.MP3 then
    begin
      Cmd := StartUpDir + cLameBin;
      Ext := cExtMP3;
    end;
    if FSettings.DAE.Ogg then
    begin
      Cmd := StartUpDir + cOggencBin;
      Ext := cExtOgg;
    end;
    if FSettings.DAE.FLAC then
    begin
      Cmd := StartUpDir + cFLACBin;
      Ext := cExtFLAC;
      end;
    if FSettings.DAE.Custom then
    begin
      Cmd := FSettings.DAE.CustomCmd;
      SplitString(FSettings.DAE.CustomOpt, '|', CustOpt, CustExt);
      Ext := CustExt;
    end;
    OutName := FSettings.DAE.Path + OutName + Ext;
    if FSettings.FileFlags.UseSh then
    begin
      Cmd := MakePathConform(Cmd);
      OutName := Quote(OutName);
    end else
    begin
      OutName := QuotePath(OutName);
    end;
    Cmd := QuotePath(Cmd);
    {Jetzt die Optionen anhängen.}
    if FSettings.DAE.MP3 then
    begin
      Cmd := Cmd + ' --nohist --preset ' + FSettings.DAE.LamePreset;
      if FSettings.DAE.AddTags then
      begin
        Cmd := Cmd + ' --add-id3v2';
        if Title <> '' then Cmd := Cmd + ' --tt "' + Title +'"';
        if Performer <> '' then Cmd := Cmd + ' --ta "' + Performer + '"';
      end;
      Cmd := Cmd + ' - ' + OutName;
    end;
    if FSettings.DAE.Ogg then
    begin
      Cmd := Cmd + ' -q ' + FSettings.DAE.OggQuality;
      if FSettings.DAE.AddTags then
      begin
        if Title <> '' then Cmd := Cmd + ' -t "' + Title +'"';
        if Performer <> '' then Cmd := Cmd + ' -a "' + Performer + '"';
      end;
      Cmd := Cmd + ' -o ' + OutName + ' -';
    end;
    if FSettings.DAE.FLAC then
    begin
      Cmd := Cmd + ' -f -s -' + FSettings.DAE.FlacQuality;
      if FSettings.DAE.AddTags then
      begin
        if Title <> '' then Cmd := Cmd + ' -T "TITLE=' + Title +'"';
        if Performer <> '' then Cmd := Cmd + ' -T "ARTIST=' + Performer + '"';
      end;
      Cmd := Cmd + ' -o ' + OutName + ' -';
    end;
    if FSettings.DAE.Custom then
    begin
      {Platzhalter: %F - Dateiname, %T - Titel, %P - Performer}
      CustOpt := ReplaceString(CustOpt, '%F', OutName);
      CustOpt := ReplaceString(CustOpt, '%T', Title);
      CustOpt := ReplaceString(CustOpt, '%P', Performer);
      Cmd := Cmd + ' ' + CustOpt;
    end;
    Result := Cmd;
  end;

  { DAEGrabTracksSimple --------------------------------------------------------

    Dies ist die alte Routine (bis 1.2pre1). Die Dateinamen werden durch das
    Präfix und die Tracknummer bestimmt. Keine Kompression.                    }

  procedure DAEGrabTracksSimple;
  var TrackList, TempList: TStringList;
      i, a, b            : Byte;
      Temp               : string;
      CommandLine        : string;
      Cmd                : string;
      OutPath            : string;
      Suffix             : string;
  begin
    SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
    TempList := TStringList.Create;
    TrackList := TStringList.Create;
    {zuerst die Trackliste verarbeiten}
    TrackList.CommaText := FSettings.DAE.Tracks;
    TempList.CommaText := FSettings.DAE.Tracks;
    {aufeinanderfolgende Tracknummern markieren}
    for i := TempList.Count - 1 downto 1 do
    begin
      a := StrToInt(TempList[i]);
      b := StrToInt(TempList[i - 1]);
      if a = b + 1 then
      begin
        TrackList[i - 1] := TrackList[i - 1] + '+';
      end;
    end;
    {aufeinanderfolgende Tracknummern zusammenführen}
    for i := TrackList.Count -1 downto 1 do
    begin
      if Pos('+', TrackList[i - 1]) > 0 then
      begin
        TrackList[i - 1] := TrackList[i - 1] + TrackList[i];
        TrackList.Delete(i);
      end;
    end;
    {Einträge für die Kommandozeile vorbereiten}
    for i := 0 to TrackList.Count - 1 do
    begin
      if Pos('+', TrackList[i]) = 0 then
      begin
        TrackList[i] := TrackList[i] + '+' + TrackList[i];
      end else
      begin
        a := 1;
        Temp := TrackList[i];
        while Pos('+', Temp) > 0 do
        begin
          a := Pos('+', Temp);
          Delete(Temp, a, 1);
          Insert('*', Temp, a);
        end;
        Insert('+', Temp, a+1);
        a := Pos('*', Temp);
        b := Pos('+', Temp);
        Delete(Temp, a, b - a);
        TrackList[i] := Temp;
      end;
    end;
    {unveränderlichen Teil der Kommandozeile zusammenstellen}
    with FSettings.DAE do
    begin
      CommandLine := StartUpDir + cCdda2wavBin;
      CommandLine := QuotePath(CommandLine);
      CommandLine := CommandLine + Cdda2wavStdCmdLine;
      if Path[Length(Path)] <> '\' then Path := Path + '\';
      OutPath := MakePathConform(Path + Prefix);
    end;
    for i := 0 to TrackList.Count - 1 do
    begin
      {Sonderbehandlung für einzelne Tracks, sonst fehlt die Tracknummer}
      Suffix := '';
      a := Pos('+', TrackList[i]);
      if Copy(TrackList[i], 1, a - 1) =
         Copy(TrackList[i], a + 1, Length(TrackList[i])) then
      begin
        Temp := Copy(TrackList[i], 1, a - 1);
        if Length(Temp) = 1 then
        begin
          Insert('0', Temp, 1);
        end;
        Suffix := '_' + Temp;
      end;
      {Kommandozeile zusammenstellen}
      Cmd := Cmd + CommandLine + ' track=' + TrackList[i] + ' ' +
             QuotePath(OutPath + Suffix) + CR;
    end;
    DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
    TrackList.Free;
    TempList.Free;
  end;

  { DAEGrabTracksEx ------------------------------------------------------------

    Dies ist die erweiterte Variante, die automatische Benennung der Dateien
    sowie das direkte Komprimieren ermöglicht.                                 }

  procedure DAEGrabTracksEx;
  var TrackList, InfoList: TStringList;
      i, Index           : Integer;
      OutPath            : string;
      Cmd, ShCmd         : string;
      PipedCmd           : string;
      ShCmdFile          : string;
      CmdDAE, CmdComp    : string;
      Temp, Dummy        : string;
      FHShCmd            : TextFile;
  begin
    SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
    {Trackliste erstellen}
    InfoList := FData.GetFileList('', cDAE);
    TrackList := TStringList.Create;
    TrackList.CommaText := FSettings.DAE.Tracks;
    CmdDAE := StartUpDir + cCdda2wavBin;
    CmdDAE := QuotePath(CmdDAE);
    if Compressed then
    begin
      MessageShow(FLang.GMS('mburn03'));
    end;
    with FSettings.DAE do
    begin
      if Path[Length(Path)] <> '\' then Path := Path + '\';
      OutPath := MakePathConform(Path);
      Cmd := '';
      {Kommandozeile für jeden Track zusammenstellen}
      for i := 0 to TrackList.Count - 1 do
      begin
        {Nummer des aktuellen Tracks - 1}
        Index := StrToIntDef(TrackList[i], 0) - 1;
        {Dateinamen bestimmen.}
        if not PrefixNames then
        begin
          Temp := GetCustomName(InfoList[Index], Index, Dummy, Dummy, Dummy);
        end else
        begin
          {PrefixNames muß berücksichtigt werden für den Fall, daß komprimierte
           Dateien solche Namen erhalten sollen.}
          Temp := Prefix + Format('_%.2d', [Index + 1]);
        end;
        {Kommandozeile anhängen.}
        if not Compressed then
        begin
          Cmd := Cmd + CmdDAE + Cdda2wavStdCmdLine + ' track=' + TrackList[i] +
                 '+' + TrackList[i] + ' ' + QuotePath(OutPath + Temp) + CR;
        end else
        begin
          Temp := Cdda2wavStdCmdLine + ' track=' + TrackList[i] + '+' +
                    TrackList[i] + ' - ';
          {Kommandozeile für das Komprimierungstool zusammenstellen}
          CmdComp := GetCommandLineCompress(InfoList[Index], Index);
          {Kommandozeilen pipen}
          if FSettings.FileFlags.UseSh then
          begin
            PipedCmd := MakePathConform(CmdDAE) + Temp + '|' + CmdComp;
            {diese Kommandozeile als Datei speichern}
            ShCmdFile := ProgDataDir +
                         cShCmdFile + '_' + Format('%.2d', [Index + 1]);
            AssignFile(FHShCmd, ShCmdFile);
            Rewrite(FHShCmd);
            WriteLn(FHShCmd, PipedCmd);
            CloseFile(FHShCmd);
            {Shell-Aufruf}
            ShCmd := StartUpDir + cShBin;
            ShCmd := QuotePath(ShCmd);
            Cmd := Cmd + ShCmd + ' ' +
                   QuotePath(MakePathConform(ShCmdFile)) + CR;
            MessageShow(PipedCmd);
          end else
          begin
            PipedCmd := CmdDAE + Temp + '|' + CmdComp;
            Cmd := Cmd + GetEnvVarValue(cComSpec) +
                   ' /c ' + '"' + PipedCmd + '"' + CR;
          end;
        end;
      end;
    end;
    DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
    TrackList.Free;
  end;

  { DAEGrabTracksCopy ----------------------------------------------------------

    Dies ist die vereinfachte Variante für das Auslesen der Tracks bei einer
    1:1-Kopie einer Audio-CD.                                                  }

  procedure DAEGrabTracksCopy;
  var CommandLine        : string;
      Cmd                : string;
      OutPath            : string;
  begin
    SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
    with FSettings.DAE do
    begin
      CommandLine := StartUpDir + cCdda2wavBin;
      CommandLine := QuotePath(CommandLine);
      CommandLine := CommandLine + Cdda2wavStdCmdLine;
      if Path[Length(Path)] <> '\' then Path := Path + '\';
      OutPath := MakePathConform(Path + Prefix);
    end;
    Cmd := Cmd + CommandLine + ' ' + QuotePath(OutPath);
    DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
  end;

  { DAEWriteTracks -------------------------------------------------------------

    Tracks schreiben für 1:1-Kopie.                                            }

  procedure DAEWriteTracks;
  var i         : Integer;
      Cmd       : string;
      OutPath   : string;
      Ok        : Boolean;
  begin
    SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
    {Kommandozeile zusammenstellen}
    Ok := True;
    with FSettings.DAE, FSettings.Cdrecord do
    begin
      if Path[Length(Path)] <> '\' then Path := Path + '\';
      OutPath := QuotePath(MakePathConform(Path)) + Prefix + '*.wav';
      Cmd := StartUpDir + cCdrecordBin;
      Cmd := QuotePath(Cmd);
      Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(Device);
      if SpeedW <> '' then Cmd := Cmd + ' speed=' + SpeedW;
      if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
      if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
      if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
      if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
        Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
      if Verbose     then Cmd := Cmd + ' -v';
      if Dummy       then Cmd := Cmd + ' -dummy';
      if DMASpeedCheck and ForceSpeed then
                          Cmd := Cmd + ' -force';
      Cmd := Cmd + ' -sao -audio -useinfo -text ' + OutPath;
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
        i := ShowMsgDlg(FLang.GMS('mburn16'), FLang.GMS('mburn02'), MB_cdrtfe1);
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
      SendMessage(FFormHandle, {WM_ButtonsOn}WM_VTerminated, 0, 0);
    end;

  end;

begin
  with FSettings.DAE do
  begin
    if not DoCopy then
    begin
      Compressed := Mp3 or Ogg or Flac or Custom;
      if PrefixNames and not Compressed then
      begin
        DAEGrabTracksSimple;
      end else
      begin
        DAEGrabTracksEx;
      end;
    end else
    begin
      if FSettings.General.CDCopy then
      begin
        DAEWriteTracks;
        FSettings.General.CDCopy := False;
      end else
      begin
        FSettings.General.CDCopy := DoCopy;
        DAEGrabTracksCopy;
      end;
    end;
  end;
end;

{ ReadImage --------------------------------------------------------------------

  Image von einer CD erstellen.                                                }

procedure TCDAction.ReadImage;
var Cmd: string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Cmd := StartUpDir + cReadcdBin;
  Cmd := QuotePath(Cmd);
  with FSettings.Readcd do
  begin
    FSettings.General.CDCopy := DoCopy;
    Cmd := Cmd + ' dev=' + SCSIIF(Device);
    if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
    if DoCopy  then Cmd := Cmd + ' retries=1';
    if Clone   then Cmd := Cmd + ' -clone';
    if Nocorr  then Cmd := Cmd + ' -nocorr';
    if Noerror then Cmd := Cmd + ' -noerror';
    if Range   then Cmd := Cmd + ' sectors=' + Startsec + '-' + Endsec;
    Cmd := Cmd + ' f=' + QuotePath(MakePathConform(IsoPath));
  end;
  DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
end;

{ WriteImage -------------------------------------------------------------------

  ISO- oder CUE-Images aud CD schreiben.                                       }

procedure TCDAction.WriteImage;
var i         : Integer;
    Cmd,
    Temp, Name: string;
    CueFile   : TCueFile;
    Ok        : Boolean;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Ok := True;
  if Pos(cExtCue, LowerCase(FSettings.Image.IsoPath)) = 0 then
  begin
    with FSettings.Cdrecord, FSettings.Image do
    begin
      Cmd := StartUpDir + cCdrecordBin;
      Cmd := QuotePath(Cmd);
      Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(Device);
      if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
      if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
      if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
      if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
      if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
        Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
      if Verbose     then Cmd := Cmd + ' -v';
      if Dummy       then Cmd := Cmd + ' -dummy';
      if DMASpeedCheck and ForceSpeed then
                          Cmd := Cmd + ' -force';
      if TAO and WritingModeRequired
                     then Cmd := Cmd + ' -tao';
      if DAO         then Cmd := Cmd + ' -dao';
      if RAW         then Cmd := Cmd + ' -' + RAWMode;
      if Overburn and (DAO or RAW) then
                          Cmd := Cmd + ' -overburn';
      if Clone and RAW then
                          Cmd := Cmd + ' -clone';
      if ExtractFileExt(IsoPath) = cExtIso then
      begin
        Cmd := Cmd + ' ' + QuotePath(MakePathConform(IsoPath));
      end else
      begin
        {gesplittetes Image zusammenfügen}
        Temp := Copy(IsoPath, 1, LastDelimiter('_', IsoPath) - 1);
        i := 0;
        Name := IsoPath;
        while FileExists(Name) do
        begin
          Cmd := Cmd + ' ' + QuotePath(MakePathConform(Name));
          Inc(i);
          Name := Temp + '_' + Format('%2.2d', [i]);
        end;
      end;
    end;
  end else
  begin
    {Es ist ein CUE-Image, Infos ermitteln}
    CueFile := TCueFile.Create(FSettings.Image.IsoPath);
    CueFile.Settings := FSettings;
    CueFile.Lang := FLang;
    CueFile.GetInfo;
    if CueFile.CompressedFilesPresent then
    begin
      CueFile.SaveTempCueFile;
      FVList.Assign(CueFile.TempFiles);
    end;
    with FSettings.Image, FSettings.Cdrdao, FSettings.Cdrecord do
    begin
      {Kommandozeile für cdrdao}
      if (FSettings.FileFlags.CdrdaoOk and WriteCueImages) or
         (FSettings.FileFlags.CdrdaoOk and not CanWriteCueImage) then
      begin
        Cmd := StartUpDir + cCdrdaoBin;
        Cmd := QuotePath(Cmd);
        Cmd := Cmd + ' write --device ' + Device;
        if ForceGenericMmc          then Cmd := Cmd + ' --driver generic-mmc' else
        if ForceGenericMmcRaw       then Cmd := Cmd + ' --driver generic-mmc-raw';
        if Speed <> ''              then Cmd := Cmd + ' --speed ' + Speed;
        if FSettings.Cdrecord.Dummy then Cmd := Cmd + ' --simulate';
        if Overburn                 then Cmd := Cmd + ' --overburn';
        if CueFile.CompressedFilesPresent then
          Cmd := CueFile.CommandLines +
                 Cmd + ' ' + QuotePath(MakePathConform(CueFile.TempFileName))
        else
          Cmd := Cmd + ' ' + QuotePath(MakePathConform(IsoPath));
      end;
      if (not FSettings.FileFlags.CdrdaoOk and CanWriteCueImage) or
         (not WriteCueImages and CanWriteCueImage) then
      begin
        {Kommandozeile für cdrecord}
        Cmd := StartUpDir + cCdrecordBin;
        Cmd := QuotePath(Cmd);
        Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(Device);
        if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
        if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
        if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
        if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
        if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
          Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
        if Verbose     then Cmd := Cmd + ' -v';
        if Dummy       then Cmd := Cmd + ' -dummy';
        if DMASpeedCheck and ForceSpeed then
                            Cmd := Cmd + ' -force';
        if Overburn    then Cmd := Cmd + ' -overburn';
        if CueFile.IsAudio then
        begin
          Cmd := Cmd + ' -pad';
          if FSettings.Image.CDText then Cmd := Cmd + ' -text';
        end;
        Cmd := Cmd + ' -dao cuefile=';
        if CueFile.CompressedFilesPresent then
          Cmd := CueFile.CommandLines + 
                 Cmd + QuotePath(MakePathConform(CueFile.TempFileName))
        else
          Cmd := Cmd + QuotePath(MakePathConform(IsoPath));

      end;
    end;
    Ok := CueFile.CueOk;
    CueFile.Free;
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'), MB_cdrtfe1);
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

{ WriteImageCopy ---------------------------------------------------------------

  schreibt das Image beim 1:1-Kopieren auf die Disk.                           }

procedure TCDAction.WriteImageCopy;
var i         : Integer;
    Cmd       : string;
    Ok        : Boolean;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Ok := True;
  with FSettings.Cdrecord, FSettings.ReadCD do
  begin
    Cmd := StartUpDir + cCdrecordBin;
    Cmd := QuotePath(Cmd);
    Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(Device);
    if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
    if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
    if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        Cmd := Cmd + ' -force';
    if Clone       then Cmd := Cmd + ' -clone -' + FSettings.Image.RAWMode else
                        Cmd := Cmd + ' -sao';
    Cmd := Cmd + ' ' + QuotePath(MakePathConform(IsoPath));
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
      i := ShowMsgDlg(FLang.GMS('mburn16'), FLang.GMS('mburn02'), MB_cdrtfe1);
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

{ WriteTOC ---------------------------------------------------------------------

  Eine CD fixieren.                                                            }

procedure TCDAction.WriteTOC;
var Cmd: string;
    i: Integer;
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
    i := ShowMsgDlg(FLang.GMS('mburn11'), FLang.GMS('mburn02'), MB_cdrtfe1);
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

{ StartVerification ------------------------------------------------------------

  Vergleich der Quelldateien mit den geschriebenen Dateien. Die Prozedur
  StartVerifyDataCD wird nicht verwendet, stattdessen wird der Thread hier
  direkt gestartet, weil auch der Fortschritt angezeigt werden soll. Dafür
  müßten aber zu viele Argumente an die Prozedur übergeben werden.
  Ein Verify ist sowohl für Daten- als auch für XCDs möglich.                  }

procedure TCDAction.StartVerification(const Action: Byte);
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
  case Action of
    cVerify        : begin
                       Device := FSettings.DataCD.Device;
                       FData.CreateVerifyList(FVList, cDataCD);
                     end;
    cVerifyXCD     : begin
                       Device := FSettings.XCD.Device;
                       FData.CreateVerifyList(FVList, cXCD);
                     end;
    cVerifyDVDVideo: begin
                       Device := FSettings.DVDVideo.Device;
                       FData.CreateVerifyList(FVList, cDVDVideo);
                     end;
  end;
  Drive := FDevices.GetDriveLetter(Device);
  {Thread starten}
  FVerificationThread := TVerificationThread.Create(FVList, Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := Action;
  FVerificationThread.TotalSize := CDSize;
  {jetzt weitere (optionale) Properties setzen}
  if Action = cVerifyXCD then
  begin
    FVerificationThread.XCD := True;
    FVerificationThread.XCDExt := FSettings.XCD.Ext;
    FVerificationThread.XCDKeepExt := FSettings.XCD.KeepExt;
  end;
  FVerificationThread.StatusBar := FStatusBar;
  FVerificationThread.AutoExec := FSettings.CmdLineFlags.ExecuteProject;
  FVerificationThread.Reload := FReload;
  FVerificationThread.Drive := Drive;
  {Thread starten}
  FVerificationThread.Resume;
  {Reload zurücksetzten}
  FReload := True;
end;

{ CreateVideoCD ----------------------------------------------------------------

  Image für eine VideoCD erstellen oder VideoCD brennen.                       }

procedure TCDAction.CreateVideoCD;
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'), MB_cdrtfe1);
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

{ CreateVideoDVD ---------------------------------------------------------------

  Aus einen Quellverzeichnis eine Video-DVD erstellen. Zur Zeit nur on-the-fly,
  keine Imageerstellung.                                                       }

procedure TCDACtion.CreateVideoDVD;
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
    if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'), MB_cdrtfe1);
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

{ TAction - public }

constructor TCDAction.Create;
begin
  inherited Create;
  FAction := cNoAction;
  FLastAction := cNoAction;
  FVList := TSTringList.Create;
  // FTempBurnList := TStringList.Create;
  FReload := True;
  FDupSize := 0;
  FSplitOutput := False;
  FEjectDevice := '';
  {DiskInfo-Object}
  FDiskA := TDiskInfoA.Create;
  FDiskM := TDiskInfoM.Create;
  FDisk := FDiskA;
end;

destructor TCDAction.Destroy;
begin
  FVList.Free;
  FDiskA.Free;
  FDiskM.Free;
  // FTempBurnList.Free;
  inherited Destroy;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCDAction.StartAction;
var TempAction: Byte;

  procedure StartImageAction;
  begin
    case FSettings.General.ImageRead of
      True : case FSettings.General.CDCopy of
               True: begin
                       WriteImageCopy;
                       FSettings.General.CDCopy := False;
                     end;
               False: ReadImage;
             end;
      False: WriteImage;
    end;
  end;

begin
  TempAction := Action;
  case TempAction of
    cDataCD        : CreateDataDisk;
    cAudioCD       : CreateAudioCD;
    cXCD           : CreateXCD;
    cCDRW          : DeleteCDRW;
    cCDInfos       : GetCDInfos;
    cDAE           : DAEGrabTracks;
    cCDImage       : StartImageAction;
    cVideoCD       : CreateVideoCD;
    cDVDVideo      : CreateVideoDVD;
    cDAEReadTOC    : DAEReadTOC;
    cFixCD         : WriteTOC;
    cVerify,
    cVerifyXCD,
    cVerifyDVDVideo: StartVerification(TempAction);
  end;
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCDAction.AbortAction;
begin
  if FActionThread <> nil then TerminateExecution(FActionThread);
  if FVerificationThread <> nil then TerminateVerification(FVerificationThread);
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCDAction.Reset;
begin
  FVList.Clear;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCDAction.CleanUp(const Phase: Byte);
var i   : Integer;
    Temp: string;
    Path: string;
begin
  {Phase 1: TForm1.WMITerminated}
  if Phase = 1 then
  begin
    DeleteFile(FSettings.XCD.XCDInfoFile);
  end else
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    if FLastAction = cDataCD then
    begin
      FEjectDevice := FSettings.DataCD.Device;
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

    if FLastAction = cAudioCD then
    begin
      FEjectDevice := FSettings.AudioCD.Device;
      DeleteFile(FSettings.AudioCD.CDTextFile);
      {temporäre Wave-Dateien löschen}
      if {FData.CompressedAudioFilesPresent} FVList.Count > 0 then
      begin
        for i := 0 to FVList.Count - 1 do DeleteFile(FVList[i]);
      end;
    end;

    if FLastAction = cXCD then
    begin
      FEjectDevice := FSettings.XCD.Device;
      DeleteFile(FSettings.XCD.XCDParamFile);
      DeleteFile(FSettings.XCD.XCDRrencInputFile);
      DeleteFile(FSettings.XCD.XCDRrencRRTFile);
      DeleteFile(FSettings.XCD.XCDRrencRRDFile);
      if not (FSettings.XCD.ImageOnly or FSettings.XCD.KeepImage) then
      begin
        DeleteFile(FSettings.XCD.IsoPath + cExtBin);
        DeleteFile(FSettings.XCD.IsoPath + cExtToc);
        DeleteFile(FSettings.XCD.IsoPath + cExtCue);
        DeleteFile(FSettings.XCD.IsoPath + cExtUm2);
      end;
    end;

    if FLastAction = cDAE then
    begin
      for i := 0 to 98 do
      begin
        Temp := ProgDataDir + cShCmdFile + '_' + Format('%.2d', [i + 1]);
        if FileExists(Temp) then DeleteFile(Temp);
      end;
    end;

    if FLastAction = cCDImage then
    begin
      FEjectDevice := FSettings.Image.Device;
      DeleteFile(FSettings.AudioCD.CDTextFile);
      {temporäre Wave-Dateien löschen}
      // if FData.CompressedAudioFilesPresent then
      begin
        for i := 0 to FVList.Count - 1 do DeleteFile(FVList[i]);
      end;
    end;

    if FLastAction = cDVDVideo then
    begin
      FEjectDevice := FSettings.DVDVideo.Device;
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

    if FLastAction = cVideoCD then
    begin
      FEjectDevice := FSettings.VideoCD.Device;
      if not (FSettings.VideoCD.ImageOnly or FSettings.VideoCD.KeepImage) then
      begin
        DeleteFile(FSettings.VideoCD.IsoPath + cExtBin);
        DeleteFile(FSettings.VideoCD.IsoPath + cExtCue);
      end;
    end;

    if FLastAction = cCDRW then
    begin
      FEjectDevice := FSettings.CDRW.Device;
    end;

    if (FLastAction = cCDImage) and not FSettings.General.ImageRead then
    begin
      FEjectDevice := FSettings.Image.Device;
    end;

  end else
  {Phase 3: TForm1.WMVTerminated}
  if Phase = 3 then
  begin
    if FLastAction = cXCD then
    begin
      {XCD-Info-Datei löschen und aus Dateiliste entfernen}
      if DeleteFile(FSettings.XCD.XCDInfoFile) then
        FData.DeleteFromPathlistByName(ExtractFileName(FSettings.XCD.XCDInfoFile),
                                       '', cXCD);
    end;

    if FLastAction = cDAE then
    begin
      if FSettings.DAE.DoCopy then
      begin
        for i := 1 to 99 do
        begin
          Path := FSettings.DAE.Path;
          if Path[Length(Path)] <> '\' then Path := Path + '\';
          Path := Path + FSettings.DAE.Prefix + '_';
          Temp := Path + Format('%.2d', [i]) + '.wav';
          if FileExists(Temp) then DeleteFile(Temp);
          Temp := Path + Format('%.2d', [i]) + '.inf';
          if FileExists(Temp) then DeleteFile(Temp);
        end;
      end;
    end;

    Eject;
    FLastAction := cNoAction;
  end;
end;

end.
