{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_audiocd.pas: Audio-CD

  Copyright (c) 2004-2014 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  10.12.2014

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_audiocd.pas implementiert das Objekt, das Audio-CDs erstellt.

  TCdrtfeActionAudioCD ist ein Objekt, das die Kommandozeilen für das Schreiben
  von Audio-CDs erstellt und ausführt.


  TCdrtfeActionAudioCD

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_audiocd;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionAudioCD = class(TCdrtfeAction)
     private
       FVList             : TStringList;
       function GetCommandLine(BurnList, CopyList: TStringList): string;
       procedure CreateAudioCD;
     protected
     public
       constructor Create;
       function GetCommandLineString: string; override;
       destructor Destroy; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper,
     f_window, f_environment, cl_diskinfo, const_tabsheets, const_common;

{ TCdrtfeActionAudioCD ------------------------------------------------------- }

{ TCdrtfeActionAudioCD - private }

{ GetCommandLine ---------------------------------------------------------------

  erzeugt die auszuführende Kommandozeile und nötige temporäre Dateien.        }

function TCdrtfeActionAudioCD.GetCommandLine(BurnList,
                                           CopyList: TStringList): string;
var i         : Integer;
    Temp      : string;
    Cmd, CmdMP: string;
    CmdRG     : string;

  { PrepareCompressedToWavConversion -------------------------------------------

    PrepareCompressedToWavConversion bereitet die Konvertierung der MP3-, Ogg-,
    FLAC- und Ape-Dateien in Wave-Dateien vor, d.h. die BurnList wird angepaßt
    und die entsprechenden Madplay-, Oggdec- oder flac-Aufrufe werden generiert.
    Die Namen der temporären Dateien werden in FVList gespeichert.             }

  procedure PrepareCompressedToWavConversion;
  var i, j          : Integer;
      Source, Target: string;
      Path, Name    : string;
      CmdTemp       : string;
      Ext           : string;
  begin
    CmdMP := '';
    Path := FSettings.General.TempFolder + '\';
    for j := 0 to BurnList.Count - 1 do
    begin
      CmdTemp := '';
      Source := BurnList[j];
      Ext := LowerCase(ExtractFileExt(BurnList[j]));
      if (Ext <> cExtWav) then
      begin
//        Target := FSettings.General.TempFolder + '\' +
//                  ChangeFileExt(ExtractFileName(Source), cExtWav);
        Name := ChangeFileExt(ExtractFileName(Source), '');
        Target := Path + Name + cExtWav;
        i := 2;
        while BurnList.IndexOf(Target) > -1 do
        begin
          Target := Path + Name + ' (' + IntToStr(i) + ')' + cExtWav;
          Inc(i);
        end;
        BurnList[j] := Target;
        if (Ext = cExtMP3) then
        begin
          CmdTemp := StartUpDir + cMPG123Bin +
                     ' -v --stereo -r 44100 -w ' +
                     QuotePath(Target) + ' ' + QuotePath(Source) + CR;
          if FSettings.AudioCD.CustomConvCmdMP3 <> '' then
          begin
            CmdTemp := FSettings.AudioCD.CustomConvCmdMP3 + CR;
            CmdTemp := ReplaceString(CmdTemp, '%S', QuotePath(Source));
            CmdTemp := ReplaceString(CmdTemp, '%T', QuotePath(Target));
          end;
        end else
        if (Ext = cExtOgg) then
        begin
          CmdTemp := StartUpDir + cOggdecBin + ' -b 16 -o ' +
                     QuotePath(Target) + ' ' + QuotePath(Source) + CR;
          if FSettings.AudioCD.CustomConvCmdOgg <> '' then
          begin
            CmdTemp := FSettings.AudioCD.CustomConvCmdOgg + CR;
            CmdTemp := ReplaceString(CmdTemp, '%S', QuotePath(Source));
            CmdTemp := ReplaceString(CmdTemp, '%T', QuotePath(Target));
          end;
        end else
        if (Ext = cExtFlac) then
        begin
          CmdTemp := StartUpDir + cFLACBin + ' -d ' + QuotePath(Source) +
                     ' -o ' + QuotePath(Target) + CR;
          if FSettings.AudioCD.CustomConvCmdFLAC <> '' then
          begin
            CmdTemp := FSettings.AudioCD.CustomConvCmdFLAC + CR;
            CmdTemp := ReplaceString(CmdTemp, '%S', QuotePath(Source));
            CmdTemp := ReplaceString(CmdTemp, '%T', QuotePath(Target));
          end;
        end else
        if (Ext = cExtApe) then
        begin
          CmdTemp := StartUpDir + cMonkeyBin + ' ' + QuotePath(Source) + ' ' +
                     QuotePath(Target) + ' -d' + CR;
          if FSettings.AudioCD.CustomConvCmdApe <> '' then
          begin
            CmdTemp := FSettings.AudioCD.CustomConvCmdApe + CR;
            CmdTemp := ReplaceString(CmdTemp, '%S', QuotePath(Source));
            CmdTemp := ReplaceString(CmdTemp, '%T', QuotePath(Target));
          end;
        end;
        FVList.Add(Target);
      end;
      CmdMP := CmdMP + CmdTemp;
    end;
  end;

  { PrepareCopyWaveFiles, PrepareWaveGain --------------------------------------

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

  procedure PrepareWaveGain;
  var j      : Integer;
      CmdTemp: string;
      GainStr: string;
  begin
    CmdRG := '';
    GainStr := '';
    if FSettings.AudioCD.Gain <> 0 then
    begin
      GainStr := '-g ' +
                 FloatToStrF(FSettings.AudioCD.Gain / 10, ffNumber, 3, 1) + ' ';
      GainStr := ReplaceString(GainStr, ',', '.');
    end;
    for j := 0 to BurnList.Count - 1 do
    begin
      CmdTemp := StartUpDir + cWavegainBin + ' -c -y ' + GainStr +
                 QuotePath(BurnList[j]) + CR;
      CmdRG := CmdRG + CmdTemp;
    end;
  end;

begin
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
          {Länge liegt bereits in Sektoren vor}
          Cmd := Cmd + ' padsize=' + Temp + 's';
        end else
        begin
          {Umrechnen: Sekunden -> Sektoren}
          Temp := IntToStr(StrToIntDef(Temp, 0) * 75);
          Cmd := Cmd + ' padsize=' + Temp + 's';
        end;
      end;
      {Dateiname}
      BurnList[i] := QuotePath(BurnList[i]);
      Cmd := Cmd + ' ' + BurnList[i];
    end;
  end;
  if CmdRG <> '' then Cmd := CmdRG + Cmd;
  if CmdMP <> '' then Cmd := CmdMP + Cmd;
  Result := Cmd;
end;

{ CreateAudioCD ----------------------------------------------------------------

  Eine Audio-CD erstellen.                                                     }

procedure TCdrtfeActionAudioCD.CreateAudioCD;
var i         : Integer;
    Ok        : Boolean;
    CMArgs    : TCheckMediumArgs;
    DummyI    : Integer;
    DummyL    : Int64;
    Cmd       : string;
    BurnList  : TStringList;
    CopyList  : TStringList;

  { CopyWaveFiles --------------------------------------------------------------

    Da WaveGain die Originaldateien verändert müssen Wave-Dateien vorher kopiert
    werden.                                                                    }

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

begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  BurnList := TStringList.Create;
  CopyList := TStringList.Create;
  FData.CreateBurnList(BurnList, cAudioCD);
  {$IFDEF ShowBurnList}
  FormDebug.Memo1.Lines.Assign(BurnList);
  {$ENDIF}
  CMArgs.Choice := cAudioCD;
  {Spielzeit ermitteln}
  FData.GetProjectInfo(DummyI, DummyI, DummyL, CMArgs.CDTime, DummyI, cAudioCD);
  {Infos über eingelegte CD einlesen}
  SetPanels('<>', FLang.GMS('mburn13'));
  FDisk.GetDiskInfo(FSettings.AudioCD.Device, True);
  SetPanels('<>', '');
  Ok := FDisk.CheckMedium(CMArgs);
  {Kommandozeile zusammenstellen}
  Cmd := GetCommandLine(BurnList, CopyList);
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}
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
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'),
                      MB_cdrtfeConfirmS);
    end else
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    if FSettings.AudioCD.ReplayGain then CopyWaveFiles;
    DisplayDOSOutput(Cmd, FActionThread, FLang, nil);
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.AudioCD.CDTextFile);
  end;
  CopyList.Free;
end;

{ TCdrtfeActionAudioCD - protected }

{ TCdrtfeActionAudioCD - public }

constructor TCdrtfeActionAudioCD.Create;
begin
  inherited Create;
  FVList := TStringList.Create;
end;

destructor TCdrtfeActionAudioCD.Destroy;
begin
  FVList.Free;
  inherited Destroy;
end;

{ GetCommandLineString ---------------------------------------------------------

  liefert die auszuführende(n) Kommandozeile(n).                               }

function TCdrtfeActionAudioCD.GetCommandLineString: string;
var Cmd       : string;
    BurnList  : TStringList;
    CopyList  : TStringList;

  function GetCopyCommand: string;
  var j             : Integer;
      Source, Target: string;
      CmdCopy       : string;
      Temp          : string;
  begin
    CmdCopy := '';
    Temp := GetEnvVarValue(cComSpec) + ' /c ';
    for j := 0 to CopyList.Count - 1 do
    begin
      SplitString(CopyList[j], '|', Source, Target);
      CmdCopy := Temp + '"' + 'copy /y ' + QuotePath(Source) + ' ' + QuotePath(Target) + '"' + CR;
    end;
    Result := CmdCopy;
  end;

begin
  BurnList := TStringList.Create;
  CopyList := TStringList.Create;
  FData.CreateBurnList(BurnList, cAudioCD);
  Cmd := GetCommandLine(BurnList, CopyList);
  if FSettings.AudioCD.ReplayGain then Cmd := GetCopyCommand + Cmd;
  BurnList.Free;
  CopyList.Free;
  Result := Cmd;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionAudioCD.CleanUp;
var i   : Integer;
begin
  {Phase 1: TForm1.WMITerminated}
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    DeleteFile(FSettings.AudioCD.CDTextFile);
    {temporäre Wave-Dateien löschen}
    if FVList.Count > 0 then
    begin
      for i := 0 to FVList.Count - 1 do DeleteFile(FVList[i]);
    end;
  end;
  {Phase 3: TForm1.WMVTerminated}
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionAudioCD.Reset;
begin
  FVList.Clear;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionAudioCD.StartAction;
begin
  CreateAudioCD;
end;

end.

