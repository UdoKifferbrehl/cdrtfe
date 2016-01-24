{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_image.pas: Disk-Images

  Copyright (c) 2004-2016 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  24.01.2016

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  cl_action_image.pas implementiert das Objekt, das Disk-Images schreibt oder
  erstellt.

  TCdrtfeActionImage ist ein Objekt, das die Kommandozeilen f�r das Erstellen
  und Schreiben von Disk-Images erzeugt und ausf�hrt.


  TCdrtfeActionImage

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_image;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_verifythread,
     cl_abstractbaseaction;

type TCdrtfeActionImage = class(TCdrtfeAction)
     private
       FReload            : Boolean;
       FVList             : TStringList;
       FVerificationThread: TVerificationThread;
       function GetCommandLine: string;
       function GetCommandLineWriteImage: string;
       function GetCommandLineReadImage: string;
       procedure ReadImage;
       procedure WriteImage;
       procedure WriteImageCopy;
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
     f_window, cl_diskinfo, cl_cueinfo, const_tabsheets, const_common;

{ TCdrtfeActionImage --------------------------------------------------------- }

{ TCdrtfeActionImage - private }

{ GetCommandLine ---------------------------------------------------------------

  erzeugt die auszuf�hrende Kommandozeile.                                     }

function TCdrtfeActionImage.GetCommandLine: string;
begin
  case FSettings.General.ImageRead of
    True : case FSettings.General.CDCopy of
             True: begin
                     // Result := GetCommandLineWriteImageCopy;
                     FSettings.General.CDCopy := False;
                   end;
             False: Result := GetCommandLineReadImage;
           end;
    False: Result := GetCommandLineWriteImage;
  end;
end;

{ GetCommandLineReadImage ------------------------------------------------------

  erzeugt die Kommandozeile zum Lesen eines Images von Disk.                   }

function TCdrtfeActionImage.GetCommandLineReadImage;
var Cmd: string;
begin
  Cmd := StartUpDir + cReadcdBin;
  Cmd := QuotePath(Cmd);
  with FSettings.Readcd do
  begin
    FSettings.General.CDCopy := DoCopy;
    Cmd := Cmd + ' dev=' + SCSIIF(Device);
    if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
    if DoCopy  then
    begin
      Cmd := Cmd + ' retries=1';
    end else
    begin
      if Retries <> '' then Cmd := Cmd + ' retries=' + Retries;
    end;
    if Clone   then Cmd := Cmd + ' -clone';
    if Nocorr  then Cmd := Cmd + ' -nocorr';
    if Noerror then Cmd := Cmd + ' -noerror';
    if Range   then Cmd := Cmd + ' sectors=' + Startsec + '-' + Endsec;
    Cmd := Cmd + ' f=' + QuotePath(MakePathConform(IsoPath));
  end;
  Result := Cmd;
end;

{ GetCommandLineWriteImage -----------------------------------------------------

  erzeugt die Kommandozeile zum Schreiben eines Images auf Disk.               }

function TCdrtfeActionImage.GetCommandLineWriteImage: string;
var i         : Integer;
    Cmd,
    Temp, Name: string;
    CueFile   : TCueFile;
begin
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
      Cmd := Cmd + GetDriverOpts;
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
      if Multi       then Cmd := Cmd + ' -multi';
      if Overburn and (DAO or RAW) then
                          Cmd := Cmd + ' -overburn';
      if Clone and RAW then
                          Cmd := Cmd + ' -clone';
      if ExtractFileExt(IsoPath) = cExtIso then
      begin
        Cmd := Cmd + ' ' + QuotePath(MakePathConform(IsoPath));
      end else
      begin
        {gesplittetes Image zusammenf�gen}
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
      {Kommandozeile f�r cdrdao}
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
        {Kommandozeile f�r cdrecord}
        Cmd := StartUpDir + cCdrecordBin;
        Cmd := QuotePath(Cmd);
        Cmd := Cmd + ' gracetime=5 dev=' + SCSIIF(Device);
        if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
        if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
        if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
        Cmd := Cmd + GetDriverOpts;
        if CdrecordUseCustOpts and (CdrecordCustOptsIndex > -1) then
          Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
        if Verbose     then Cmd := Cmd + ' -v';
        if Dummy       then Cmd := Cmd + ' -dummy';
        if DMASpeedCheck and ForceSpeed then
                            Cmd := Cmd + ' -force';
        if Overburn    then Cmd := Cmd + ' -overburn';
        if Multi       then Cmd := Cmd + ' -multi';
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
    {im Falle eines ung�ltigen CUE-Sheets leeres Kommando zur�ckgeben}
    if not CUEFile.CueOk then Result := '';    
    // Ok := Ok and CueFile.CueOk;
    CueFile.Free;
  end;
  Result := Cmd;
end;

{ ReadImage --------------------------------------------------------------------

  Image von einer CD erstellen.                                                }

procedure TCdrtfeActionImage.ReadImage;
var Cmd: string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Cmd := GetCommandLineReadImage;
  DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
end;

{ WriteImage -------------------------------------------------------------------

  ISO- oder CUE-Images aud CD schreiben.                                       }

procedure TCdrtfeActionImage.WriteImage;
var i         : Integer;
    Cmd       : string;
    CMArgs    : TCheckMediumArgs;
    Ok        : Boolean;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  CMArgs.ForcedContinue := False;
  CMArgs.Choice := cCDImage;
  {Gr��e der Daten ermitteln}
  //FData.GetProjectInfo(Count, DummyI, CMArgs.CDSize, DummyE, DummyI, cDataCD);
  {Infos �ber eingelegte CD einlesen}
  SetPanels('<>', FLang.GMS('mburn13'));
  FDisk.GetDiskInfo(FSettings.Image.Device, False);
  SetPanels('<>', '');
  {Zusammenstellung pr�fen}
  Ok := FDisk.CheckMedium(CMArgs);
  {Kommandozeile zusammenstellen}
  Cmd := GetCommandLineWriteImage;
  {falls das CUE-File ung�ltig war, wird ein leeres Kommando zur�ckgegeben}
  Ok := Ok and (Cmd <> '');
  {Bei DVD als Simulationstreiber dvd_simul verwenden.}
  if Ok and FSettings.Cdrecord.SimulDrv then
  begin
    if FDisk.IsDVD then Cmd := ReplaceString(Cmd, 'cdr_simul', 'dvd_simul');
    if FDisk.IsBD  then Cmd := ReplaceString(Cmd, 'cdr_simul', 'bd_simul');
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
    DisplayDOSOutput(Cmd, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
    CleanUp(2);
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ WriteImageCopy ---------------------------------------------------------------

  schreibt das Image beim 1:1-Kopieren auf die Disk.                           }

procedure TCdrtfeActionImage.WriteImageCopy;
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
    Cmd := Cmd + GetDriverOpts;
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
      i := ShowMsgDlg(FLang.GMS('mburn16'), FLang.GMS('mburn02'),
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

{ TCdrtfeActionImage - protected }

{ TCdrtfeActionImage - public }

constructor TCdrtfeActionImage.Create;
begin
  inherited Create;
  FVList := TStringList.Create;
  FReload := True;
end;

destructor TCdrtfeActionImage.Destroy;
begin
  FVList.Free;
  inherited Destroy;
end;

{ GetCommandLineString ---------------------------------------------------------

  liefert die auszuf�hrende(n) Kommandozeile(n).                               }

function TCdrtfeActionImage.GetCommandLineString: string;
begin
  Result := GetCommandLine;
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCdrtfeActionImage.AbortAction;
begin
  inherited AbortAction;
  if FVerificationThread <> nil then TerminateVerification(FVerificationThread);
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp l�scht tempor�re Dateien.                                            }

procedure TCdrtfeActionImage.CleanUp(const Phase: Byte);
var i   : Integer;
begin
  {Phase 1: TForm1.WMITerminated}
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    DeleteFile(FSettings.AudioCD.CDTextFile);
    {tempor�re Wave-Dateien l�schen}
    // if FData.CompressedAudioFilesPresent then
    begin
      for i := 0 to FVList.Count - 1 do DeleteFile(FVList[i]);
    end;
  end;
  {Phase 3: TForm1.WMVTerminated}
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zur�ck.                                  }

procedure TCdrtfeActionImage.Reset;
begin
  FVList.Clear;
end;

{ StartAction ------------------------------------------------------------------

  StartAction f�hrt die gew�hlte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionImage.StartAction;
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

{ StartVerification ------------------------------------------------------------

  Vergleich der Quelldateien mit den geschriebenen Dateien. Die Prozedur
  StartVerifyDataCD wird nicht verwendet, stattdessen wird der Thread hier
  direkt gestartet, weil auch der Fortschritt angezeigt werden soll. Daf�r
  m��ten aber zu viele Argumente an die Prozedur �bergeben werden.
  Ein Verify ist sowohl f�r Daten- als auch f�r XCDs m�glich.                  }

procedure TCdrtfeActionImage.StartVerification;
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
  Device := FSettings.Image.Device;
  FVList.Add(FSettings.Image.IsoPath);
  Drive := FDevices.GetDriveLetter(Device);
  {Thread starten}
  FVerificationThread := TVerificationThread.Create(FVList, Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cVerifyISOImage;
  FVerificationThread.TotalSize := CDSize;
  FVerificationThread.ISOImage := True;
  FVerificationThread.StatusBar := FStatusBar;
  FVerificationThread.AutoExec := FSettings.CmdLineFlags.ExecuteProject;
  FVerificationThread.Reload := FReload;
  FVerificationThread.Drive := Drive;
  {Thread starten}
  FVerificationThread.Resume;
  {Reload zur�cksetzten}
  FReload := True;
end;

end.

