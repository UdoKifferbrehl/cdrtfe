{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_xcd.pas: XCDs

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_xcd.pas implementiert das Objekt, das XCD schreibt oder erstellt.

  TCdrtfeActionXCD ist ein Objekt, das die Kommandozeilen für das Erstellen
  und Schreiben von XCDs erzeugt und ausführt.


  TCdrtfeActionXCD

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_xcd;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_verifythread,
     cl_abstractbaseaction;

type TCdrtfeActionXCD = class(TCdrtfeAction)
     private
       FReload            : Boolean;
       FVList             : TStringList;
       FVerificationThread: TVerificationThread;
       procedure CreateXCD;
       procedure CreateXCDInfoFile(List: TStringList);
       procedure CreateRrencInputFile(List: TStringList);
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
     f_environment, f_filesystem, f_cygwin;

{ TCdrtfeActionXCD ----------------------------------------------------------- }

{ TCdrtfeActionXCD - private }

{ CreateXCDInfoFile ------------------------------------------------------------

  CreateXCDInfoFile erzeugt die Info-Datei xcd.crc, in der die ursprünglichen
  Dateigrößen der Form2-Dateien sowie deren CRC32-Prüfsumme gespeichert sind.  }

procedure TCdrtfeActionXCD.CreateXCDInfoFile(List: TStringList);
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

{ CreateRrencInputFile ---------------------------------------------------------

  konvertiert die Pfadliste in eine für rrenc geeignete Liste.                 }

procedure TCdrtfeActionXCD.CreateRrencInputFile(List: TStringList);
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

{ CreateXCD --------------------------------------------------------------------

  Image für eine XCD erstellen oder XCD brennen.                               }

procedure TCdrtfeActionXCD.CreateXCD;
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
      CmdC := CmdC + GetDriverOpts;
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'),
                      MB_cdrtfeConfirmS);
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

{ TCdrtfeActionXCD - protected }

{ TCdrtfeActionXCD - public }

constructor TCdrtfeActionXCD.Create;
begin
  inherited Create;
  FVList := TStringList.Create;
  FReload := True;
end;

destructor TCdrtfeActionXCD.Destroy;
begin
  FVList.Free;
  inherited Destroy;
end;

{ GetCommandLineString ---------------------------------------------------------

  liefert die auszuführende(n) Kommandozeile(n).                               }

function TCdrtfeActionXCD.GetCommandLineString: string;
begin
  Result := '';
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCdrtfeActionXCD.AbortAction;
begin
  inherited AbortAction;
  if FVerificationThread <> nil then TerminateVerification(FVerificationThread);
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionXCD.CleanUp(const Phase: Byte);
begin
  {Phase 1: TForm1.WMITerminated}
  if Phase = 1 then
  begin
    DeleteFile(FSettings.XCD.XCDInfoFile);
  end else
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
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
  end else
  {Phase 3: TForm1.WMVTerminated}
  if Phase = 3 then
  begin
    {XCD-Info-Datei löschen und aus Dateiliste entfernen}
    if DeleteFile(FSettings.XCD.XCDInfoFile) then
      FData.DeleteFromPathlistByName(ExtractFileName(FSettings.XCD.XCDInfoFile),
                                     '', cXCD);
  end;
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionXCD.Reset;
begin
  FVList.Clear;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionXCD.StartAction;
begin
  CreateXCD;
end;

{ StartVerification ------------------------------------------------------------

  Vergleich der Quelldateien mit den geschriebenen Dateien. Die Prozedur
  StartVerifyDataCD wird nicht verwendet, stattdessen wird der Thread hier
  direkt gestartet, weil auch der Fortschritt angezeigt werden soll. Dafür
  müßten aber zu viele Argumente an die Prozedur übergeben werden.
  Ein Verify ist sowohl für Daten- als auch für XCDs möglich.                  }

procedure TCdrtfeActionXCD.StartVerification;
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
  Device := FSettings.XCD.Device;
  FData.CreateVerifyList(FVList, cXCD);
  Drive := FDevices.GetDriveLetter(Device);
  {Thread starten}
  FVerificationThread := TVerificationThread.Create(FVList, Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cVerifyXCD;
  FVerificationThread.TotalSize := CDSize;
  {jetzt weitere (optionale) Properties setzen}
  FVerificationThread.XCD := True;
  FVerificationThread.XCDExt := FSettings.XCD.Ext;
  FVerificationThread.XCDKeepExt := FSettings.XCD.KeepExt;
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

