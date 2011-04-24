{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_daegrabtracks.pas: Audio-CD auslesen

  Copyright (c) 2004-2011 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  24.04.2011

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_daegrabtracks.pas implementiert das Objekt, das Tracks einer Audio-
  CD ausliest.

  TCdrtfeActionDAEGrabTracks ist ein Objekt, das die Kommandozeilen für das Aus-
  lesen von Audio-Tracks


  TCdrtfeActionDAEGrabTracks

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_daegrabtracks;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionDAEGrabTracks = class(TCdrtfeAction)
     private
       FCompressed: Boolean;
       function Cdda2wavStdCmdLine: string;
       function GetCommandLineCompress(const Info: string; Index: Integer): string;
       function GetCustomName(const Info: string; Index: Integer; var Title, Performer, Name: string): string;
       procedure CorrectTrackList(List: TStringList);
       procedure DAEGrabTracks;
       procedure DAEGrabTracksEx;
       procedure DAEGrabTracksSimple;
       procedure DAEGrabTracksCopy;
       procedure DAEWriteTracks;
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
     f_dischelper, f_window, f_environment, cl_diskinfo, f_filesystem,
     const_tabsheets, const_common;

{ TCdrtfeActionDAEGrabTracks ------------------------------------------------- }

{ TCdrtfeActionDAEGrabTracks - private }

{ GetCustomName ----------------------------------------------------------------

  erzeugt aus dem Pattern und den CD-Infos den Dateinamen.                     }

function TCdrtfeActionDAEGrabTracks.GetCustomName(const Info: string;
                    Index: Integer; var Title, Performer, Name: string): string;
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
  {Dateinamen auf ungültige Zeichen prüfen, ggf. diese entfernen}
  if not FilenameIsValid(Temp) then
  begin
    Temp := MakeFileNameValid(Temp);
  end;
  Result := Temp;
end;

{ Cdda2wavStdCmdLine -----------------------------------------------------------

  erzeugt die unveränderlichen Bestandteile der Kommandozeile.                 }

function TCdrtfeActionDAEGrabTracks.Cdda2wavStdCmdLine: string;
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

{ GetCommandLineCompress -------------------------------------------------------

  erzeugt den Aufruf für das Komprimierungstool.                               }

function TCdrtfeActionDAEGrabTracks.GetCommandLineCompress(const Info: string;
                                                        Index: Integer): string;
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

{ CorrectTrackList -------------------------------------------------------------

  Bei CDs mit Hidden Track verschieben sich die Tracknummern.                  }

procedure TCdrtfeActionDAEGrabTracks.CorrectTrackList(List: TStringList);
var i, a: Integer;
begin
  if FSettings.DAE.HiddenTrack then
  begin
    for i := 0 to List.Count - 1 do
    begin
      a := StrToInt(List[i]) - 1;
      List[i] := IntToStr(a);
    end;
  end;
end;

{ DAEGrabTracksSimple ----------------------------------------------------------

  Dies ist die alte Routine (bis 1.2pre1). Die Dateinamen werden durch das
  Präfix und die Tracknummer bestimmt. Keine Kompression.                      }

procedure TCdrtfeActionDAEGrabTracks.DAEGrabTracksSimple;
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
  {bei einem Hidden Track verschieben sich die Tracknummern}
  CorrectTrackList(TrackList);
  CorrectTrackList(TempList);
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

{ DAEGrabTracksEx --------------------------------------------------------------

  Dies ist die erweiterte Variante, die automatische Benennung der Dateien
  sowie das direkte Komprimieren ermöglicht.                                   }

procedure TCdrtfeActionDAEGrabTracks.DAEGrabTracksEx;
var TrackList, InfoList: TStringList;
    i, Index           : Integer;
    OutPath            : string;
    Cmd, ShCmd         : string;
    PipedCmd           : string;
    ShCmdFile          : string;
    CmdDAE, CmdComp    : string;
    Temp, Dummy        : string;
    FHShCmd            : TextFile;
    HiddenTrckOff      : Integer;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  if FSettings.DAE.HiddenTrack then HiddenTrckOff := 1 else HiddenTrckOff := 0;
  {Trackliste erstellen}
  InfoList := FData.GetFileList('', cDAE);
  TrackList := TStringList.Create;
  TrackList.CommaText := FSettings.DAE.Tracks;
  {bei einem Hidden Track verschieben sich die Tracknummern}
  CorrectTrackList(TrackList);
  CmdDAE := StartUpDir + cCdda2wavBin;
  CmdDAE := QuotePath(CmdDAE);
  if FCompressed then
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
        Temp := GetCustomName(InfoList[Index  + HiddenTrckOff],
                                                  Index, Dummy, Dummy, Dummy);
      end else
      begin
        {PrefixNames muß berücksichtigt werden für den Fall, daß komprimierte
         Dateien solche Namen erhalten sollen.}
        Temp := Prefix + Format('_%.2d', [Index{ + 1}]);
      end;
      {Kommandozeile anhängen.}
      if not FCompressed then
      begin
        Cmd := Cmd + CmdDAE + Cdda2wavStdCmdLine + ' track=' + TrackList[i] +
               '+' + TrackList[i] + ' ' + QuotePath(OutPath + Temp) + CR;
      end else
      begin
        Temp := Cdda2wavStdCmdLine + ' track=' + TrackList[i] + '+' +
                  TrackList[i] + ' - ';
        {Kommandozeile für das Komprimierungstool zusammenstellen}
        CmdComp := GetCommandLineCompress(InfoList[Index + HiddenTrckOff],
                                           Index);
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

{ DAEGrabTracksCopy ------------------------------------------------------------

  Dies ist die vereinfachte Variante für das Auslesen der Tracks bei einer
  1:1-Kopie einer Audio-CD.                                                    }

procedure TCdrtfeActionDAEGrabTracks.DAEGrabTracksCopy;
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

{ DAEWriteTracks ---------------------------------------------------------------

  Tracks schreiben für 1:1-Kopie.                                              }

procedure TCdrtfeActionDAEGrabTracks.DAEWriteTracks;
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
    Cmd := Cmd + GetDriverOpts;
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
    SendMessage(FFormHandle, {WM_ButtonsOn}WM_VTerminated, 0, 0);
  end;
end;

{ DAEGrabTracks ----------------------------------------------------------------

  DAEGrabTracks liest die ausgewählte Titel aus.                               }

procedure TCdrtfeActionDAEGrabTracks.DAEGrabTracks;
begin
  with FSettings.DAE do
  begin
    if not DoCopy then
    begin
      FCompressed := Mp3 or Ogg or Flac or Custom;
      if PrefixNames and not FCompressed then
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

{ TCdrtfeActionDAEGrabTracks - protected }

{ TCdrtfeActionDAEGrabTracks - public }

constructor TCdrtfeActionDAEGrabTracks.Create;
begin
  inherited Create;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionDAEGrabTracks.CleanUp(const Phase: Byte);
var i   : Integer;
    Temp: string;
    Path: string;
begin
  {Phase 1: TForm1.WMITerminated}
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    for i := 0 to 98 do
    begin
      Temp := ProgDataDir + cShCmdFile + '_' + Format('%.2d', [i + 1]);
      if FileExists(Temp) then DeleteFile(Temp);
    end;
  end else
  {Phase 3: TForm1.WMVTerminated}
  if Phase = 3 then
  begin
    if FSettings.DAE.DoCopy then
    begin
      for i := 0 to 99 do
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
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionDAEGrabTracks.Reset;
begin
  // wird hier nicht benötigt
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionDAEGrabTracks.StartAction;
begin
  DAEGrabTracks;
end;

end.

