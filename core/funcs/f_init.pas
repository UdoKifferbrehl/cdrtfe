{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  f_init.pas: Dateien prüfen und Laufwerke erkennen

  Copyright (c) 2004-2014 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  26.01.2014

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
    CheckMkisofsImports: Boolean;
    CheckVersion(Settings: TSettings);

}

unit f_init;

{$I directives.inc}

interface

uses Windows, Classes, Forms, SysUtils, FileCtrl, IniFiles,
     {eigene Klassendefinitionen/Units}
     cl_lang, cl_settings, cl_peheader;

function CheckFiles(Settings: TSettings; Lang: TLang): Boolean;
function CheckMkisofsImports: Boolean;
function CheckVersion(Settings: TSettings; Lang: TLang): Boolean;
procedure CheckEnvironment(Settings: TSettings);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     cl_logwindow,
     f_filesystem, f_getdosoutput, f_wininfo, f_environment, f_strings, f_cygwin,
     const_locations, f_locations, const_common, f_process, f_window;

var FLang: TLang;

{ ShowToolPath -----------------------------------------------------------------

  zeigt die Pfade aller Tools.                                                 }

{$IFDEF WriteLogFile}
procedure ShowToolPath;
begin
  AddLogCode(1253);
  AddLog('cCdrecordBin      ' + cCdrecordBin, 3);
  AddLog('cMkisofsBin       ' + cMkisofsBin, 3);
  AddLog('cCdda2wavBin      ' + cCdda2wavBin, 3);
  AddLog('cReadcdBin        ' + cReadcdBin, 3);
  AddLog('cISOInfoBin       ' + cISOInfoBin, 3);
  AddLog('cShBin            ' + cShBin, 3);
  AddLog('cMode2CDMakerBin  ' + cMode2CDMakerBin, 3);
  AddLog('cVCDImagerBin     ' + cVCDImagerBin, 3);
  AddLog('cCdrdaoBin        ' + cCdrdaoBin, 3);
  AddLog('cMPG123Bin        ' + cMPG123Bin, 3);
  AddLog('cLameBin          ' + cLameBin, 3);
  AddLog('cOggdecBin        ' + cOggdecBin, 3);
  AddLog('cOggencBin        ' + cOggencBin, 3);
  AddLog('cFLACBin          ' + cFLACBin, 3);
  AddLog('cMonkeyBin        ' + cMonkeyBin, 3);
  AddLog('cRrencBin         ' + cRrencBin, 3);
  AddLog('cRrdecBin         ' + cRrdecBin, 3);
  AddLog('cWavegainBin      ' + cWavegainBin, 3);
  AddLog('cM2F2ExtractBin   ' + cM2F2ExtractBin, 3);
  AddLog('cDat2FileBin      ' + cDat2FileBin, 3);
  AddLog('cD2FGuiBin        ' + cD2FGuiBin, 3);
  AddLog('cCygwin1Dll       ' + cCygwin1Dll, 3);
  AddLog(' ', 3);
end;
{$ENDIF}

{ CheckSysFolderCygwin ---------------------------------------------------------

  prüft, ob sich in den Windows-System-Ordnern cygwin1.dll befinden. Wenn ja,
  wird eine Warnung ausgegeben, daß die eigenen DLLs nicht benutzt werden
  können.                                                                      }

procedure CheckSysFolderCygwin;
var Temp: string;
begin
  Temp := LowerCase(FindInSearchPath('cygwin1.dll'));
  if (Pos(LowerCase(GetShellFolder(CSIDL_SYSTEM)), Temp) > 0) or
     (Pos(LowerCase(GetShellFOlder(CSIDL_WINDOWS)), Temp) > 0) then
    TLogWin.Inst.Add(FLang.GMS('einit05'));
end;

{ GetToolNames -----------------------------------------------------------------

  Die Dateinamen der Tools aus der cdrtfe_tools.ini lesen, sofern diese vor-
  handen ist.
  Für cygwin1.dll gilt: Falls sich die DLL auch im Suchpfad befindet, wird diese
  bereits vorhandene Version genutzt, ansonsten die Version aus \tools\cygwin.
  Einstellungen aus cdrtfe_tools.ini haben Vorrang.                            }

procedure GetToolNames;
const cTool: string = 'Tools';
      cPath: string = 'PATH';
var Ini  : TIniFile;
    Path : string;
    Temp : string;
begin
  {standardmäßig sollen sich die Tools im Ordner \tools\ befinden}
  if DirectoryExists(StartUpDir + cToolDir) then
  begin
    Path := cToolDir;
    cCdrecordBin     := Path + cCdrtoolsDir  + cCdrecordBin;
    cMkisofsBin      := Path + cCdrtoolsDir  + cMkisofsBin;
    cCdda2wavBin     := Path + cCdrtoolsDir  + cCdda2wavBin;
    cReadcdBin       := Path + cCdrtoolsDir  + cReadcdBin;
    cISOInfoBin      := Path + cCdrtoolsDir  + cISOInfoBin;
    cShBin           := Path + cCygwinDir    + cShBin;
    cMode2CDMakerBin := Path + cXCDDir       + cMode2CDMakerBin;
    cVCDImagerBin    := Path + cVCDImagerDir + cVCDImagerBin;
    cCdrdaoBin       := Path + cCdrdaoDir    + cCdrdaoBin;
    cMPG123Bin       := Path + cSoundDir     + cMPG123Bin;
    cLameBin         := Path + cSoundDir     + cLameBin;
    cOggdecBin       := Path + cSoundDir     + cOggdecBin;
    cOggencBin       := Path + cSoundDir     + cOggencBin;
    cFLACBin         := Path + cSoundDir     + cFLACBin;
    cMonkeyBin       := Path + cSoundDir     + cMonkeyBin;
    cWavegainBin     := Path + cSoundDir     + cWavegainBin;
    cRrencBin        := Path + cXCDDir       + cRrencBin;
    cRrdecBin        := Path + cXCDDir       + cRrdecBin;
    cM2F2ExtractBin  := Path + cXCDDir       + cM2F2ExtractBin;
    cDat2FileBin     := Path + cXCDDir       + cDat2FileBin;
    cD2FGuiBin       := Path + cXCDDir       + cD2FGuiBin;
    cCygPathPref     := Path + cHelperDir    + cCygPathPref;
  end;
  {Angaben aus der cdrtfe_tools.ini haben jedoch Vorrang.}
  if FileExists(StartUpDir + cIniFileTools) then
  begin
    Ini := TIniFile.Create(StartUpDir + cIniFileTools);
    with Ini do
    begin
      Temp := ReadString(cTool, 'CdrecordBin', '');
      if Temp <> '' then cCdrecordBin := Temp;

      Temp := ReadString(cTool, 'MkisofsBin', '');
      if Temp <> '' then cMkisofsBin := Temp;

      Temp := ReadString(cTool, 'Cdda2wavBin', '');
      if Temp <> '' then cCdda2wavBin := Temp;

      Temp := ReadString(cTool, 'ReadcdBin', '');
      if Temp <> '' then cReadcdBin := Temp;

      Temp := ReadString(cTool, 'ISOInfoBin', '');
      if Temp <> '' then cISOInfoBin := Temp;

      Temp := ReadString(cTool, 'ShBin', '');
      if Temp <> '' then cShBin := Temp;

      Temp := ReadString(cTool, 'Mode2CDMakerBin', '');
      if Temp <> '' then cMode2CDMakerBin := Temp;

      Temp := ReadString(cTool, 'VCDImagerBin', '');
      if Temp <> '' then cVCDImagerBin := Temp;

      Temp := ReadString(cTool, 'CdrdaoBin', '');
      if Temp <> '' then cCdrdaoBin := Temp;

      Temp := ReadString(cTool, 'MPG123Bin', '');
      if Temp <> '' then cMPG123Bin := Temp;

      Temp := ReadString(cTool, 'LameBin', '');
      if Temp <> '' then cLameBin := Temp;

      Temp := ReadString(cTool, 'OggdecBin', '');
      if Temp <> '' then cOggdecBin := Temp;

      Temp := ReadString(cTool, 'OggencBin', '');
      if Temp <> '' then cOggencBin := Temp;

      Temp := ReadString(cTool, 'FLACBin', '');
      if Temp <> '' then cFLACBin := Temp;

      Temp := ReadString(cTool, 'MonkeyBin', '');
      if Temp <> '' then cMonkeyBin := Temp;

      Temp := ReadString(cTool, 'WavegainBin', '');
      if Temp <> '' then cWavegainBin := Temp;

      Temp := ReadString(cTool, 'RrencBin', '');
      if Temp <> '' then cRrencBin := Temp;

      Temp := ReadString(cTool, 'RrdecBin', '');
      if Temp <> '' then cRrdecBin := Temp;

      Temp := ReadString(cTool, 'M2F2ExtractBin', '');
      if Temp <> '' then cM2F2ExtractBin := Temp;

      Temp := ReadString(cTool, 'Dat2FileBin', '');
      if Temp <> '' then cDat2FileBin := Temp;

      Temp := ReadString(cTool, 'D2FGuiBin', '');
      if Temp <> '' then cD2FGuiBin := Temp;
    end;
    Ini.Free;
    {$IFDEF WriteLogfile} AddLogCode(1252); {$ENDIF}
  end;
  {$IFDEF WriteLogFile} ShowToolPath; {$ENDIF}
  {.mkisofsrc: Einige Versionen von mkisofs suchen diese Konfigurationsdatei,
   das kann dauern, wenn im nicht vorhandenen HOME-Verzeichnis gesucht wird.
   Daher die Umgebungsvariable setzten.}
  Temp := ExtractFilePath(StartUpDir + cMkisofsBin + cExtExe) + cMkisofsRCFile;
  if FileExists(Temp) then
  begin
    SetEnvVarValue(cMKISOFSRC, Temp);
    {$IFDEF WriteLogfile}
    AddLogCode(1254);
    AddLog('Path: ' + Temp, 3);
    AddLog(' ', 3);
    {$ENDIF}
  end;
end;

{ GetCygwinPath ----------------------------------------------------------------

  setzt den Pfad zur cygwin1.dll.                                              }

procedure GetCygwinPath;
const cTool: string = 'Tools';
      cPath: string = 'PATH';
var Path, OldPath: string;
    Temp         : string;
    Found        : Boolean;
begin
  if DirectoryExists(StartUpDir + cToolDir) then
  begin
    Path := cToolDir;
    Temp := cCygwin1Dll;
    cCygwin1Dll      := Path + cCygwinDir + '\' + cCygwin1Dll;
    if Pos('\', cCygwin1Dll) = 1 then Delete(cCygwin1Dll, 1, 1);
    Found := (FindInSearchPath(Temp) <> '');
    {$IFDEF WriteLogFile}
    AddLogCode(1260);
    AddLog(FindInSearchPath(Temp) + CRLF + ' ', 3);
    {$ENDIF}
    if Found and not UseOwnCygwinDLLs then
    begin
      cCygwin1Dll := Temp;
      {$IFDEF WriteLogfile} AddLogCode(1250); {$ENDIF}
    end else
    {Pfad zu cygwin1.dll in den Suchpfad eintragen, sofern die Datei exisitert.}
    if FileExists(StartUpDir + '\' + cCygwin1Dll) then
    begin
      {$IFDEF WriteLogFile} if not Found then AddLogCode(1259); {$ENDIF}
      {$IFDEF WriteLogfile} AddLogCode(1251); {$ENDIF}
      Path := GetEnvVarValue(cPath);
      OldPath := Path;
      {$IFDEF WriteLogFile} AddLog(Path + CRLF + ' ', 3); {$ENDIF}
      Path := StartUpDir + cToolDir + cCygwinDir + ';' + Path;
      SetEnvVarValue(cPath, Path);
      {$IFDEF WriteLogFile} AddLog(GetEnvVarValue(cPath) + CRLF + ' ', 3); {$ENDIF}
      {Prüfen, ob cygwin1.dll in Systemordnern ist. Falls ja, warnen}
      if UseOwnCygwinDLLs then CheckSysFolderCygwin;
    end;
  end;
  {Sonderbehandlung: Gibt es eine aktive cygwin1.dll?}
  if CheckForActiveCygwinDLL then
  begin
    {$IFDEF WriteLogfile} AddLogCode(1262); {$ENDIF}
    if DLLIsLoaded('cygwin1.dll', Temp) then
    begin
      Path := ExtractFilePath(Temp) + ';' + OldPath;
      SetEnvVarValue(cPath, Path);
      cCygwin1Dll := Temp;
      {$IFDEF WriteLogfile}
      AddLogCode(1261);
      AddLog(GetEnvVarValue(cPath) + CRLF + ' ', 3);
      {$ENDIF}
    end;
  end;
end;

{ CheckMkisofsImports ----------------------------------------------------------

  Mkisofs kann je nach Version noch zuästzliche DLLs importieren.
  True: alle benötigten DLLs vorhanden                                         }

function CheckMkisofsImports: Boolean;
var DllList: TStringList;
    i      : Integer;
    DllPath: string;
    DllOk  : Boolean;
    s      : string;
begin
  Result := True;
  DllPath := ExtractFilePath(StartUpDir + '\' + cCygwin1Dll);
  {$IFDEF WriteLogfile}
  AddLogCode(1255);
  AddLog('DLL Path: ' + DllPath, 3);
  {$ENDIF}
  DllList := TStringList.Create;
  GetImportList(StartUpDir + cMkisofsBin + cExtExe, DllList);
  {Testen, ob die cygwin-DLLs vorhanden sind}
  for i := 0 to DllList.Count - 1 do
  begin
    if Pos('cyg', DllList[i]) > 0 then
    begin
      DllOk := (FileExists(DllPath + DllList[i])) or
               (FindInSearchPath(DllList[i]) <> '');
      Result := Result and DllOk;      
      {$IFDEF WriteLogfile}
      if DllOk then s := 'ok' else s := 'not found';
      AddLog('Checking ' + DllList[i] + ' ... ' +  s, 3);
     {$ENDIF}
    end;
  end;
  DllList.Free;
  {$IFDEF WriteLogfile}
  AddLog(' ', 3);
  {$ENDIF}
end;

{ CheckFiles -------------------------------------------------------------------

  Prüfen, ob alle benötigten Dateien vorhanden sind. Von den cdrtools werden
  benötigt: cdrecord.exe, mkisofs.exe, readcd.exe, sh.exe, cygwin1.dll.
  Es wird angenommen, daß sich dieses Programm im Verzeichnis der cdrtools
  befindet. Sind alle Dateien vorhanden, ist FilesOk True.
  Die Versionsprüfung findet seit cdrtfe 1.0.2.0 nun auch hier statt.          }

function CheckFiles(Settings: TSettings; Lang:TLang): Boolean;
var Ok       : Boolean;
    MkisofsOk: Boolean;
begin
  FLang := Lang;
  Settings.FileFlags.CygInPath := (FindInSearchPath(cCygwin1Dll) <> '');
  GetToolNames;
  GetCygwinPath;
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
    {Weitermachen, wenn cdrtools + cygwin oder Mingw32-cdrtools vorhanden sind.
     Für vcdimager spielt es keine Rolle.}
    Ok := CdrtoolsOk and (CygwinOk or Mingw);
    {Weitere Tests für mkisofs}
    MkisofsOk := CheckMkisofsImports;
    Ok := Ok and MkisofsOk;
    Result := Ok;
    {Ohne cdrtools oder cygwin1.dll können wir uns den Rest sparen.}
    if not Ok then
    begin
      if not CdrtoolsOk then
        ShowMsgDlg(Lang.GMS('einit01'), Lang.GMS('g001'), MB_cdrtfeError) else
      if not CygwinOk then
        ShowMsgDlg(Lang.GMS('einit02'), Lang.GMS('g001'), MB_cdrtfeError) else
      if not MkisofsOk then
        ShowMsgDlg(Lang.GMS('einit03'), Lang.GMS('g001'), MB_cdrtfeError);
      {Programm abbrechen!}
      Application.ShowMainForm:= False;
      Application.Terminate;
    end else
    begin
      {Cygwin Path Prefix initialisieren}
      if not Mingw then InitCygwinPathPrefix;
      {Version und Lauffähigkeit von cdrecord/mkisofs prüfen.}
      Result := Result and CheckVersion(Settings, Lang);
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
      {Ist isoinfo.exe da? Wenn nicht, kein erweiterter Multisession-Import.}
      ISOInfoOk := FileExists(StartUpDir + cISOInfoBin + cExtExe);
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
      MPG123Ok := FileExists(StartUpDir + cMPG123Bin + cExtExe);
      if not MPG123Ok then
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
      {Ist Monkey da? Falls nicht, Ape-Dateien ignorieren.}
      MonkeyOk := FileExists(StartUpDir + cMonkeyBin + cExtExe);
      if not MonkeyOk then
      begin
//        TLogWin.Inst.Add(Lang.GMS('g003') + CRLF + Lang.GMS('minit12'));
      end;
      {Ist WaveGain vorhanden?}
      WavegainOk := FileExists(StartUpDir + cWavegainBin + cExtExe);
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
      if IsWow64 then ShlExtDllOk := FileExists(StartUpDir + cCdrtfeShlExDll64);
      {Ist cdrtfeHelper.exe da?}
      HelperOk := FileExists(StartUpDir + cCdrtfeHelper);
    end;
  end;
end;

{ CheckVersion -----------------------------------------------------------------

  Ermittelt die Version von cdrecord. Ab cdrecord 2.01a26 ist die Angabe des
  Schreibmodus verpflichtend.                                                  }

function CheckVersion(Settings: TSettings; Lang: TLang): Boolean;
var Output       : string;
    VersionString: string;
    VersionValue : Integer;
    Cmd          : string;

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
  var Value    : Integer;
      Temp     : string;
      VerNumStr: string;
      VerNumInt: Integer;
      p        : Integer;
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

  { CdrtoolsWorking ------------------------------------------------------------

    CdrtoolsWorking prüft, ob die Versionsinfos ermittelt werden konnten. Wenn
    nicht, deutet dies auf Probleme mit den Binaries oder der cygwin-DLL hin.  }

  function CdrtoolsWorking(const s: string): Boolean;
  begin
    Result := True;
    if (s = '') or
       (Pos('[main]', s) > 0) or
       (Pos('shared memory', s) > 0) or
       (Pos('heap', s) > 0) then
    begin
      Result := False;
      ShowMsgDlg(Lang.GMS('einit04'), Lang.GMS('g001'), MB_cdrtfeError);
    end;
  end;

begin
  {cdrecord-Version}
  Cmd := StartUpDir + cCdrecordBin;
  Cmd := QuotePath(Cmd);
  Cmd := Cmd + ' -version';
  Output := GetDosOutput(PChar(Cmd),True, True, 3);
  if Pos('Cdrecord-', Output) > 1 then
    Delete(Output, 1, Pos('Cdrecord-', Output) - 1);
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
  {ab cdrecord 2.01.01a21 gibt es die Option -minfo}
  Settings.Cdrecord.HaveMediaInfo :=
    VersionValue >= GetVersionValue('2.01.01a21');
  {ab cdrecord 2.01.01a37 können DVD+RWs gelöscht werden}
  Settings.Cdrecord.CanEraseDVDPlusRW :=
    VersionValue >= GetVersionValue('2.01.01a37');
  {ab cdrecord 2.01.01a50 können Multiborder-DVDs (-R, -RW) geschieben werden.}
  Settings.Cdrecord.HasMultiborder :=
    VersionValue >= GetVersionValue('2.01.01a50');
  {haben wir es cdrecord-ProDVD zu tun?}
  Settings.FileFlags.ProDVD := Pos('-ProDVD-', Output) > 0;
  {Prüfen, ob cdrecord funktionierte}
  Result := CdrtoolsWorking(Output);

  {mkisofs-Version}
  if Result then
  begin
    Cmd := StartUpDir + cMkisofsBin;
    Cmd := QuotePath(Cmd);
    Cmd := Cmd + ' -version';
    Output := GetDosOutput(PChar(Cmd), True, True, 3);
//    if Output <> '' then
//      if Output[1] <> 'mkisofs ' then Delete(Output, 1, Pos(LF, Output));
    if Pos('mkisofs ', Output) > 1 then
      Delete(Output, 1, Pos('mkisofs ', Output) - 1);
    VersionString := GetVersionString(Output);
    VersionValue := GetVersionValue(VersionString);
    {ab mkisofs 2.01.01a31 gibt es -no-limit-pathtables}
    Settings.Cdrecord.HaveNLPathtables :=
      VersionValue >= GetVersionValue('2.01.01a31');
    {ab mkisofs 2.01.01a32 gibt es -hide-udf}
    Settings.Cdrecord.HaveHideUDF :=
      VersionValue >= GetVersionValue('2.01.01a32');
    {Prüfen, ob mkisofs funktionierte}
    Result := Result and CdrtoolsWorking(Output);
  end;                                             
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
