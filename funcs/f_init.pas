{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_init.pas: Dateien prüfen und Laufwerke erkennen

  Copyright (c) 2004-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  25.05.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_init.pas stellt Funktionen und Prozeduren zur Verfügung, die beim Start
  von cdrtfe benötigt werden:
    * Prüfen, ob alle benötigten Dateien vorhanden sind
    * Version von cdrecord, ... bestimmen
    * Environment Block prüfen


  exportierte Funktionen/Prozeduren:

    CheckEnvironment(Settings: TSettings)
    CheckFiles(Settings: TSettings; Lang: TLang): Boolean
    CheckVersion(Settings: TSettings);

}

unit f_init;

{$I directives.inc}

interface

uses Windows, Classes, Forms, SysUtils, Dialogs, FileCtrl, IniFiles,
     {eigene Klassendefinitionen/Units}
     cl_lang, cl_settings, cl_peheader;

function CheckFiles(Settings: TSettings; Lang: TLang): Boolean;
procedure CheckEnvironment(Settings: TSettings);
procedure CheckVersion(Settings: TSettings);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     cl_logwindow,
     f_filesystem, f_process, f_wininfo, f_environment, f_strings, constant;

{ GetToolNames -----------------------------------------------------------------

  Die Dateinamen der Tools aus der cdrtfe_tools.ini lesen, sofern diese vor-
  handen ist.                                                                  }

procedure GetToolNames;
const T : string = 'Tools';
var Ini: TIniFile;
begin
  if FileExists(StartUpDir + cIniFileTools) then
  begin
    Ini := TIniFile.Create(StartUpDir + cIniFileTools);
    {Namen lesen}
    with Ini do
    begin
      cCdrecordBin     := ReadString(T, 'CdrecordBin', cCdrecordBin);
      cMkisofsBin      := ReadString(T, 'MkisofsBin', cMkisofsBin);
      cCdda2wavBin     := ReadString(T, 'Cdda2wavBin', cCdda2wavBin);
      cReadcdBin       := ReadString(T, 'ReadcdBin', cReadcdBin);
      cShBin           := ReadString(T, 'ShBin', cShBin);
      cMode2CDMakerBin := ReadString(T, 'Mode2CDMakerBin', cMode2CDMakerBin);
      cVCDImagerBin    := ReadString(T, 'VCDImagerBin', cVCDImagerBin);
      cCdrdaoBin       := ReadString(T, 'CdrdaoBin', cCdrdaoBin);
      cMadplayBin      := ReadString(T, 'MadplayBin', cMadplayBin);
      CLameBin         := ReadString(T, 'LameBin', cLameBin);
      cOggdecBin       := ReadString(T, 'OggdecBin', cOggdecBin);
      cOggencBin       := ReadString(T, 'OggencBin', cOggencBin);
      cFLACBin         := ReadString(T, 'FLACBin', cFLACBin);
      cRrencBin        := ReadString(T, 'RrencBin', cRrencBin);
      cRrdecBin        := ReadString(T, 'RrdecBin', cRrdecBin);
      cM2F2ExtractBin  := ReadString(T, 'M2F2ExtractBin', cM2F2ExtractBin);
      cDat2FileBin     := ReadString(T, 'Dat2FileBin', cDat2FileBin);
      cD2FGuiBin       := ReadString(T, 'D2FGuiBin', cD2FGuiBin);
      {cygwin1.dll}
      cCygwin1Dll      := ExtractFilePath(cCdrecordBin) + cCygwin1Dll;
      if Pos('\', cCygwin1Dll) = 1 then Delete(cCygwin1Dll, 1, 1);
    end;
    Ini.Free;
  end;
end;

{ CheckFiles -------------------------------------------------------------------

  Prüfen, ob alle benötigten Dateien vorhanden sind. Von den cdrtools werden
  benötigt: cdrecord.exe, mkisofs.exe, readcd.exe, sh.exe, cygwin1.dll.
  Es wird angenommen, daß sich dieses Programm im Verzeichnis der cdrtools
  befindet. Sind alle Dateien vorhanden, ist FilesOk True.
  Die Versionsprüfung findet seit cdrtfe 1.0.2.0 nun auch hier statt.          }

function CheckFiles(Settings: TSettings; Lang:TLang): Boolean;
var Ok: Boolean;
begin
  GetToolNames;
  with Settings.FileFlags do
  begin
    {Sind die cdrtools da?}
    CdrtoolsOk := FileExists(StartUpDir + cCdrecordBin + cExtExe) and
                  FileExists(StartUpDir + cMkisofsBin + cExtExe);
    {Haben wir es mit der Mingw32-Version zu tun?}
    Mingw := not ImportsDll(StartUpDir + cCdrecordBin + cExtExe,
                            ExtractFileName(cCygwin1Dll));
    {Ist die cygwin1.dll im cdrtfe-Verzeichnis oder Suchpfad?}
    CygwinOk := FileExists(StartUpDir + '\' + cCygwin1Dll) or
                (FindInSearchPath(cCygwin1Dll) <> '');
    {Weitermachen, wenn cdrtools + cygwin oder Mingw32-cdrtools vorhanden sind.}
    Ok := CdrtoolsOk and (CygwinOk or Mingw);
    Result := Ok;
    {Ohne cdrtools oder cygwin1.dll können wir uns den Rest sparen.}
    if not Ok then
    begin
      if not CdrtoolsOk then
        MessageBox(Application.Handle, PChar(Lang.GMS('einit01')),
                   PChar(Lang.GMS('g001')), MB_OK or MB_ICONEXCLAMATION) else
        MessageBox(Application.Handle, PChar(Lang.GMS('einit02')),
                   PChar(Lang.GMS('g001')), MB_OK or MB_ICONEXCLAMATION);
      {Programm abbrechen!}
      Application.ShowMainForm:= False;
      Application.Terminate;
    end else
    begin
      {Ist cdda2wav da? Wenn nicht, dann kein DAE.}
      Cdda2wavOk := FileExists(StartUpDir + cCdda2wavBin + cExtExe);
      if not Cdda2wavOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit01'));
      end;
      {Ist readcd da? Wenn nicht, dann kein Image lesen.}
      ReadcdOk := FileExists(StartUpDir + cReadcdBin + cExtExe);
      if not ReadcdOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit06'));
      end;
      {Ist sh.exe da? Wenn nicht, dann kein DAO, es sei denn sh.exe wird nicht
       benötig (Win2k/WinXP).}
      ShNeeded := not PlatformWin2kXP;
      {wenn Mingw, dann darf ShOk nicht True sein.}
      ShOk := FileExists(StartUpDir + cShBin + cExtExe) and not Mingw;
      if not ShOk and ShNeeded then
      begin
        if not Mingw then
          TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit02')) else
          TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit07'));
      end;
      {sh.exe wird benutzt, wenn vorhanden (und nötig) ist, aber keinesfallse,
       wenn eine Mingw-Version verwendet wird.}
      UseSh := (ShNeeded or ShOk) and not Mingw;
      {Ist der Mode2CDmaker da? Falls nicht, Menüpunkt XCD deaktivieren.}
      M2CDMOk := FileExists(StartUpDir + cMode2CDMakerBin + cExtExe);
      if not M2CDMOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit03'));
      end;
      {Ist rrenc/rrdec da? Falls nicht, keine Fehlerkorrektur bei XCDs.}
      RrencOk := FileExists(StartUpDir + cRrencBin + cExtExe);
      RrdecOk := FileExists(StartUpDir + cRrdecBin + cExtExe);
      {Ist der VCDImager da? Falls nicht, Menüpunkt VideoCD deaktivieren.}
      VCDImOk := FileExists(StartUpDir + cVCDImagerBin + cExtExe);
      if not VCDImOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit08'));
      end;
      {Ist Madplay da? Falls nicht, MP3-Dateien ignorieren.}
      MadplayOk := FileExists(StartUpDir + cMadplayBin + cExtExe);
      if not MadplayOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit09'));
      end;
      {Ist Lame da? Falls nicht, kann nicht nach mp3 encodiert werden.}
      LameOk := FileExists(StartUpDir + cLameBin + cExtExe);
      {Ist Oggdec da? Falls nicht, Ogg-Dateien ignorieren.}
      OggdecOk := FileExists(StartUpDir + cOggdecBin + cExtExe);
      if not OggdecOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit10'));
      end;
      {Ist Oggenc da? Falls nicht, kann nicht nach ogg encodiert werden.}
      OggencOk := FileExists(StartUpDir + cOggencBin + cExtExe);
      {Ist FLAC da? Falls nicht, FLAC-Dateien ignorieren. Kein Encodieren.}
      FLACOk := FileExists(StartUpDir + cFLACBin + cExtExe);
      if not FLACOk then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit11'));
      end;
      {Version von cdrecord/mkisofs prüfen.}
      CheckVersion(Settings);
      {Ist cdrdao.exe da? Falls nicht, keine XCDs und keine CUE-Images, es sei
       denn, cdrecord ab Version 2.01a24 ist vorhanden.}
      CdrdaoOk := FileExists(StartUpDir + cCdrdaoBin + cExtExe);
      if not (CdrdaoOk or Settings.Cdrecord.CanWriteCueImage) then
      begin
        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit04'));
      end;
      {wenn nur cdrdao CUE-Images schreiben kann, Option erzwingen.}
      Settings.Cdrdao.WriteCueImages := CdrdaoOk and
                                        not Settings.Cdrecord.CanWriteCueImage;
      {Ist cdrtfeShlEx.dll da? Falls nicht, entsrpechende Optione deaktivieren.}
      ShlExtDllOk := FileExists(StartUpDir + cCdrtfeShlExDll);
    end;
  end;
end;

{ CheckVersion -----------------------------------------------------------------

  Ermittelt die Version von cdrecord. Ab cdrecord 2.01a26 ist die Angabe des
  Schreibmodus verpflichtend.                                                  }

procedure CheckVersion(Settings: TSettings);
var Output: string;
    VersionString: string;
    VersionValue: Integer;
    Cmd: string;
    //p: Integer;

  function GetVersionString(Source: string): string;
  var p: Integer;
  begin
    {die Versionsnummer ist das 2. Wort in der Ausgabe}
    p := Pos(' ', Source);
    Delete(Source, 1, p);
    p := Pos(' ', Source);
    Result := Copy(Source, 1, p - 1);
(*
    {Sonderbehandlung für Mingw32-Version der cdrtools: 2.01-bootcd.ru}
    if Settings.FileFlags.Mingw then
    begin
      p := Pos('-', Result);
      Result := Copy(Result, 1, p - 1);
    end;
    {dafür sorgen, daß die Finalversionen (ohne a__) als neuer erkannt werden:
     Kennzeichnung durch ein angehängtes f (z.B. 2.01f).}
    if Pos('a', Result) = 0 then Result := Result + 'f';
*)
  end;

  { GetVersionValue ------------------------------------------------------------

    erzeugt zu einer Versionsnummer einen einfach vergleichbaren Integerwert.
    Format der Versionsnummer:
      <MajorVersion>.<MinorVersion>[.<Release>][a|b<ab-Release>][-addition]
    Berechnung:
      Value :=   <MajorVersion> * 100.000.000
               + <MinorVersion> *   1.000.000
               + <Release>      *      10.000
               + <ab-Release>   *          10 (wenn a__ oder b__)
               +                        1.000
               -                          999 (wenn a__)
               -                          998 (wenn b__)                       }

  function GetVersionValue(const Source: string): Integer;
  var Value: Integer;
      Temp: string;
      VerNumStr: string;
      VerNumInt: Integer;
      p: Integer;
  begin
    Value := 1000;
    Temp := Source;
    {Zusatz entfernen}
    p := Pos('-', Temp);
    if p > 0 then
    begin
      Temp := Copy(Temp, 1, p - 1);
    end;
    {alpha-Version?}
    p := Pos('a', Temp);
    if p = Length(Temp) - 2 then
    begin
      VerNumStr := Temp;
      Delete(VerNumStr, 1, p);
      Delete(Temp, p, 3);
      VerNumInt := StrToIntDef(VerNumStr, 0);
      Value := Value - 999 + VerNumInt * 10;
    end;
    {beta-Version?}
    p := Pos('b', Temp);
    if p = Length(Temp) - 2 then
    begin
      VerNumStr := Temp;
      Delete(VerNumStr, 1, p);
      Delete(Temp, p, 3);
      VerNumInt := StrToIntDef(VerNumStr, 0);
      Value := Value - 998 + VerNumInt * 10;
    end;
    {MajorVersion}
    p := Pos('.', Temp);
    if p > 0 then
    begin
      VerNumStr := Copy(Temp, 1, p - 1);
      Delete(Temp, 1, p);
      VerNumInt := StrToIntDef(VerNumStr, 0);
      Value := Value + VerNumInt * 100000000;
    end;
    {MinorVersion}
    p := Pos('.', Temp);
    if p > 0 then
    begin
      {wenn es noch eine Release-Nummer gibt}
      VerNumStr := Copy(Temp, 1, p - 1);
      Delete(Temp, 1, p);
    end else
    begin
      {MinorVersion ist letzte Nummer}
      VerNumStr := Temp;
      Temp := '';
    end;
    VerNumInt := StrToIntDef(VerNumStr, 0);
    Value := Value + VerNumInt * 1000000;
    {Release}
    if Temp <> '' then
    begin
      VerNumInt := StrToIntDef(Temp, 0);
      Value := Value + VerNumInt * 10000;
    end;
    Result := Value;
  end;  

begin
  {cdrecord-Version}
  Cmd := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  Cmd := QuotePath(Cmd);
  {$ENDIF}
  Cmd := Cmd + ' -version';
  Output := GetDosOutput(PChar(Cmd), True);
  VersionString := GetVersionString(Output);
  VersionValue := GetVersionValue(VersionString);
  {ab cdrecord 2.01a24 ist die CUE-Image-Unterstützung ausreichend}
  Settings.Cdrecord.CanWriteCueImage :=
    VersionValue >= GetVersionValue('2.01a24');
  {ab cdrecord 2.01a26 ist die Angabe des Schreibmodus verpflichtend}
  Settings.Cdrecord.WritingModeRequired :=
    VersionValue >= GetVersionValue('2.01a26');
  {ab cdrecord 2.01a33 wird die DMA-Geschwindigkeit geprüft}
  Settings.Cdrecord.DMASpeedCheck :=
    VersionValue >= GetVersionValue('2.01a33');
  {haben wir es cdrecord-ProDVD zu tun?}
  Settings.FileFlags.ProDVD := Pos('-ProDVD-', Output) > 0;
(*
  {mkisofs-Version}
  Cmd := StartUpDir + cMkisofsBin;
  {$IFDEF QuoteCommandlinePath}
  Cmd := QuotePath(Cmd);
  {$ENDIF}
  Cmd := Cmd + ' -version';
  Output := GetDosOutput(PChar(Cmd), True);
  VersionString := GetVersionString(Output);
*)
end;

{ CheckEnvironment -------------------------------------------------------------

  Wenn in TSettings.Environment keine Infos gefunden werden (EnvironmentSize = 0
  und EnvironmentBlock = nil) fügt CheckEnvironment die Umgebungsvariable
  CDR_SECURITY ein, wenn der Key (aus cdrtfe.ini) bekannt ist und noch nicht im
  aktuellen Environment Block gespeichert ist.
  Nach Ablauf des Threads muß der Block wieder freigegeben werden! Dies kann
  durch einen Aufruf von CheckEnvironment erfolgen, wenn EnvironmentBlock nicht
  nil ist und EnvironmentSize > 0.                                             }

procedure CheckEnvironment(Settings: TSettings);
var NewVars: TStringList;
begin
  {$IFDEF DebugCheckEnv}Deb('CheckEnvironment:', 1);{$ENDIF}
  if not Assigned(Settings.Environment.EnvironmentBlock) and
     (Settings.Environment.EnvironmentSize = 0) then
  begin
    with Settings.Environment do
    begin
      //{$IFDEF DebugCheckEnv}Deb('  Key: ' + ProDVDKey, 1);{$ENDIF}
      {Das ganze nur, wenn cdrecord-ProDVD und ein Lizenzkey aus der cdrtfe.ini
       vorhanden sind und das Environment noch keinen Schlüssel enthält.}
      if Settings.FileFlags.ProDVD and
        (GetEnvVarValue(cCDRSEC) = '') and (ProDVDKey <> '') then
      begin
        {$IFDEF DebugCheckEnv}Deb('  Key: ' + ProDVDKey, 1);{$ENDIF}
        NewVars := TStringList.Create;
        NewVars.Add(cCDRSEC + '=' + ProDVDKey);
        {Größe des neuen Blocks bestimmen}
        EnvironmentSize := CreateEnvBlock(NewVars, True, nil, 0);
        {Block erzeugen}
        GetMem(EnvironmentBlock, EnvironmentSize);
        CreateEnvBlock(NewVars, True, EnvironmentBlock, EnvironmentSize);
        {$IFDEF DebugCheckEnv}
        Deb('  Environment block created (' +
            IntToStr(Settings.Environment.EnvironmentSize) + ' Bytes).', 1);
        {$ENDIF}
        NewVars.Free;
      end;
    end;
  end else
  begin
    with Settings.Environment do
    begin
      FreeMem(EnvironmentBlock, EnvironmentSize);
      EnvironmentBlock := nil;
      EnvironmentSize := 0;
    end;
    {$IFDEF DebugCheckEnv}
    Deb('  Environment block freed (' +
        IntToStr(Settings.Environment.EnvironmentSize) + ' Bytes).', 1);
    {$ENDIF}
  end;
end;

end.
