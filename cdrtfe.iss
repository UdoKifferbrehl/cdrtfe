; cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend
;
;  cdrtfe.iss: Inno-Setup-Skript für Inno Setup 5.3.5
;
;  Copyright (c) 2006-2009 Oliver Valencia
;
;  letzte Änderung  07.12.2009
;
;  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
;  GNU General Public License weitergeben und/oder modifizieren. Weitere
;  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.
;

#define MyAppName "cdrtools Frontend"
#define MyAppVerName "cdrtfe 1.3.6"
#define MyAppPublisher "Oliver Valencia"
#define MyAppURL "http://cdrtfe.sourceforge.net"
#define MyAppExeName "cdrtfe.exe"
#define MyAppCopyright "Copyright © 2002-2009  O. Valencia, O. Kutsche"

[Setup]
; Installer
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\cdrtfe
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
UninstallFilesDir={app}\uninst
ShowLanguageDialog=yes
PrivilegesRequired=admin
; Compiler
VersionInfoVersion=1.3.6
VersionInfoCopyright={#MyAppCopyright}
OutputDir=i:\cdrtfe\proto2
;OutputDir=J:\shared\cdrtfe
OutputBaseFilename=cdrtfe-1.3.6
; Compression
;Compression=none
Compression=lzma
SolidCompression=yes
; Cosmetic
;WizardSmallImageFile=compiler:wizmodernsmallimage-IS.bmp
;WizardImageFile=compiler:wizmodernimage-IS.bmp
WizardSmallImageFile=compiler:images\SetupModernSmall19.bmp
WizardImageFile=compiler:images\SetupModern19.bmp
WindowVisible=no
AppCopyright={#MyAppCopyright}
ShowUndisplayableLanguages=yes

[Languages]
Name: en; MessagesFile: compiler:Default.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_en.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_en.rtf
Name: de; MessagesFile: compiler:Languages\German.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_de.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_de.rtf
Name: fr; MessagesFile: compiler:Languages\French.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_fr.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_fr.rtf
Name: it; MessagesFile: compiler:Languages\Italian.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_it.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_it.rtf
Name: pl; MessagesFile: compiler:Languages\Polish.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_pl.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_pl.rtf

[Tasks]
; Desktop icon
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked; MinVersion: 1, 0
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; MinVersion: 0, 1
Name: desktopicon\common; Description: {cm:TaskAllUsers}; GroupDescription: {cm:AdditionalIcons}; Flags: exclusive; MinVersion: 0, 1
Name: desktopicon\user; Description: {cm:TaskCurrentUser}; GroupDescription: {cm:AdditionalIcons}; Flags: exclusive unchecked; MinVersion: 0, 1
; Quicklaunch icon
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked

[Files]
; Main program file
Source: I:\cdrtfe\proto\cdrtfe.exe; DestDir: {app}; DestName: cdrtfe.exe; Flags: ignoreversion; Components: prog
Source: I:\cdrtfe\proto\cdrtfedbg.dll; DestDir: {app}; DestName: cdrtfedbg.dll; Flags: ignoreversion; Components: prog
Source: I:\cdrtfe\proto\cdrtfeShlEx.dll; DestDir: {app}; Flags: ignoreversion; Components: prog
Source: I:\cdrtfe\proto\cdrtfe.jdbg; DestDir: {app}; Flags: ignoreversion; Components: prog
; Manifest
Source: I:\cdrtfe\proto\cdrtfe.exe.manifest; DestDir: {app}; DestName: cdrtfe.exe.manifest; Flags: ignoreversion; Components: prog
; Icons/Glyphs
Source: I:\cdrtfe\proto\icons\*; DestDir: {app}\icons; Flags: ignoreversion; Components: prog
; Language files
Source: I:\cdrtfe\proto\translations\*; Excludes: _cdrtfe_lang.ini; DestDir: {app}\translations; Flags: ignoreversion recursesubdirs; Components: prog\langsupport
Source: I:\cdrtfe\proto\translations\_cdrtfe_lang.ini; DestDir: {app}\translations; DestName: cdrtfe_lang.ini; Flags: ignoreversion; Components: prog\langsupport; AfterInstall: LangIniSet
; Help files
Source: I:\cdrtfe\proto\help\*; DestDir: {app}\help; Flags: ignoreversion;
; Tools: cdrtools
Source: I:\cdrtfe\proto\tools\cdrtools\cdrecord.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cdrtools\mkisofs.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cdrtools\readcd.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cdrtools\cdda2wav.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cdrtools\isoinfo.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cdrtools\.mkisofsrc; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cdrtools\siconv\*.*; DestDir: {app}\tools\cdrtools\siconv; Flags: ignoreversion; Components: tools\cdrt
; Tools cygwin
Source: I:\cdrtfe\proto\tools\cygwin\sh.exe; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cygwin\cygwin1.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cygwin\cygiconv-2.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cygwin\cygintl-3.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\cdrtfe\proto\tools\cygwin\cygwin.ini; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt; Check: CygIniCheck; AfterInstall: CygIniSet
; Tools: mode2cdmaker
Source: I:\cdrtfe\proto\tools\xcd\Mode2CDMaker.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\m2cdm
;Source: I:\cdrtfe\proto\tools\xcd\m2cdm.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\m2cdm\ex
;Source: I:\cdrtfe\misc\misc\cdrtfe_tools.ini; DestDir: {app}; Flags: ignoreversion; Components: tools\m2cdm\ex
; Tools: rrenc/rrdec
;Source: I:\cdrtfe\proto\tools\xcd\rrenc.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\rrenc
;Source: I:\cdrtfe\proto\tools\xcd\rrdec.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\rrenc
; Tools: XCD extraction
Source: I:\cdrtfe\proto\tools\xcd\m2f2extract.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
Source: I:\cdrtfe\proto\tools\xcd\d2fgui.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
Source: I:\cdrtfe\proto\tools\xcd\dat2file.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
; Tools: audio tools
Source: I:\cdrtfe\proto\tools\sound\madplay.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\lame.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\oggdec.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\oggenc.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\flac.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
; Tools: VCDImager
Source: I:\cdrtfe\proto\tools\vcdimager\vcdimager.exe; DestDir: {app}\tools\vcdimager; Flags: ignoreversion; Components: tools\vcd
; Commandline Scripts
Source: I:\cdrtfe\misc\scripts\cmdshell.cmd; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellSet; MinVersion: 0, 1
Source: I:\cdrtfe\misc\scripts\cmdshellinit.cmd; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellInitSet; MinVersion: 0, 1
Source: I:\cdrtfe\misc\scripts\cmdshell.bat; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellSet; MinVersion: 1, 0
Source: I:\cdrtfe\misc\scripts\cmdshellinit.bat; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellInitSet; MinVersion: 1, 0
Source: I:\cdrtfe\misc\scripts\makeiso.cmd; DestDir: {app}\tools\scripts
; Readme cdrtfe
Source: I:\cdrtfe\cdrtfe\doc\readme_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de
Source: I:\cdrtfe\cdrtfe\doc\readme_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr it pl
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr it pl
Source: I:\cdrtfe\cdrtfe\doc\changes\changes.txt; DestDir: {app}\doc; Flags: ignoreversion;
; Licenses
Source: I:\cdrtfe\cdrtfe\doc\license\COPYING.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: I:\cdrtfe\cdrtfe\doc\license\CDDL.Schily.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: I:\cdrtfe\cdrtfe\doc\license\license_tools.txt; DestDir: {app}\doc\license; Flags: ignoreversion
; Readme m2f2extract
Source: I:\delphi\m2f2extract\doc\m2f2extract_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de; Components: tools\xcd
Source: I:\delphi\m2f2extract\doc\m2f2extract_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr it pl; Components: tools\xcd
; source files
Source: I:\cdrtfe\cdrtfe\source\*; DestDir: {app}\source\cdrtfe; Excludes: COPYING.txt,forms.pas,controls.pas,inifiles.pas; Flags: ignoreversion recursesubdirs; Components: src
Source: I:\cdrtfe\cdrtfe\shellex\cdrtfeShlEx\*; DestDir: {app}\source\cdrtfeShlEx; Flags: ignoreversion recursesubdirs; Components: src
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; Program
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}
; CommandShell
Name: {group}\CommandShell; Filename: {app}\tools\scripts\cmdshell.cmd; MinVersion: 0, 1
Name: {group}\CommandShell; Filename: {app}\tools\scripts\cmdshell.bat; MinVersion: 1, 0
; Help file
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_german.chm; Languages: de
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_english.chm; Languages: en pl
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_french.chm; Languages: fr
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_italian.chm; Languages: it
; Readme files
Name: {group}\Changes; Filename: {app}\doc\changes.txt;
Name: {group}\Readme; Filename: {app}\doc\readme_de.txt; Languages: de
Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_de.txt; Languages: de
Name: {group}\Readme; Filename: {app}\doc\readme_en.txt; Languages: en fr it pl
Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_en.txt; Languages: en fr it pl
Name: {group}\Readme Icons; Filename: {app}\icons\readme.txt;
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_de.txt; Languages: de; Components: tools\xcd
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_en.txt; Languages: en fr it pl; Components: tools\xcd
; Source files
Name: {group}\{cm:IconSourceFiles}; Filename: {app}\source; Components: src
; Uninstall
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe}
; Desktop & Quicklaunch Icon
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon; MinVersion: 1, 0
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon\user; MinVersion: 0, 1
Name: {commondesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon\common; MinVersion: 0, 1
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: quicklaunchicon

[Registry]
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\cdrtfe.exe"; ValueType: string; ValueName: ""; ValueData: "{app}\cdrtfe.exe"; Flags: uninsdeletevalue uninsdeletekeyifempty; Components: tools\cdrt;
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\cdrt.cmd"; ValueType: string; ValueName: ""; ValueData: "{app}\tools\scripts\cmdshell.cmd"; Flags: uninsdeletevalue uninsdeletekeyifempty; Components: tools\cdrt; MinVersion: 0, 1
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\cdrt.cmd"; ValueType: string; ValueName: ""; ValueData: "{app}\tools\scripts\cmdshell.bat"; Flags: uninsdeletevalue uninsdeletekeyifempty; Components: tools\cdrt; MinVersion: 1, 0

[Run]
Filename: "{app}\doc\readme_en.txt"; Languages: en fr it pl; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_de.txt"; Languages: de; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_dvd_en.txt"; Languages: en fr it pl; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_dvd_de.txt"; Languages: de; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\changes.txt"; Flags: shellexec postinstall skipifsilent unchecked
Filename: {app}\{#MyAppExeName}; Description: {cm:LaunchProgram,{#MyAppName}}; Flags: nowait postinstall skipifsilent

[Types]
Name: custom; Description: cdrtfe Setup; Flags: iscustom

[Components]
; cdrtfe
Name: prog; Description: {cm:CompProg}; Flags: fixed; Types: custom
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Types: custom; Languages: en fr it pl
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Languages: de
; Tools
Name: tools; Description: {cm:CompTools}; Flags: fixed; Types: custom;
Name: tools\cdrt; Description: {cm:CompCdrt}; Flags: fixed; Types: custom;
Name: tools\m2cdm; Description: {cm:CompM2CDM}; Flags: dontinheritcheck checkablealone; Types: custom;
;Name: tools\m2cdm\ex; Description: {cm:CompM2CDMex}; Flags: dontinheritcheck;
;Name: tools\rrenc; Description: {cm:CompRrenc}; Flags: dontinheritcheck; Types: custom;
Name: tools\xcd; Description: {cm:CompXCD}; Flags: dontinheritcheck; Types: custom;
Name: tools\audio; Description: {cm:CompAudio}; Flags: dontinheritcheck; Types: custom;
Name: tools\vcd; Description: {cm:CompVCD}; Flags: dontinheritcheck; Types: custom;
; source files
Name: src; Description: {cm:CompSrc};

[Code]
var CygDLLPage: TInputOptionWizardPage;

function IsInSearchPath(const Name: string): Boolean;
var Path: string;
begin
  Path := GetEnv('PATH');
  Result := FileSearch(Name, Path) <> '';
end;

function IsInSysDir(const Name: string): Boolean;
begin
  Result := FileExists(ExpandConstant('{sys}') + '\' + Name) or
            FileExists(ExpandConstant('{win}') + '\' + Name);
end;

function CygIniCheck(): Boolean;
begin
  Result := IsInSearchPath('cygwin1.dll');
end;

procedure CygIniSet();
begin
  case CygDLLPage.SelectedValueIndex of
    0: SetIniBool('CygwinDLL', 'UseOwnDLLs', False, ExpandConstant(CurrentFileName));
    1: SetIniBool('CygwinDLL', 'UseOwnDLLs', True, ExpandConstant(CurrentFileName));
  end;
end;

procedure CmdShellSet();
var FileName  : string;
    FileExt   : string;
    ScriptPath: string;
    StartCmd  : string;
    ScriptFile: TStringList;
begin
  FileName := ExpandConstant(CurrentFileName);
  FileExt := ExtractFileExt(FileName);
  ScriptPath := ExtractFilePath(FileName);
  if FileExt = '.cmd' then
  begin
    StartCmd := 'cmd.exe /k call "' + ScriptPath + 'cmdshellinit.cmd"';
  end else
  begin
    StartCmd := 'command /e:30000 /k call "' + ScriptPath + 'cmdshellinit.bat"';
  end;
  ScriptFile := TStringList.Create;
  ScriptFile.LoadFromFile(FileName);
  ScriptFile[1] :=  StartCmd;
  ScriptFile.SaveToFile(FileName);
  ScriptFile.Free;
end;

procedure CmdShellInitSet();
var FileName  : string;
    PathVar   : string;
    ToolPath  : string;
    DllPath   : string;
    ScriptPath: string;
    StartCmd  : string;
    ScriptFile: TStringList;
    l         : Integer;
begin
  FileName := ExpandConstant(CurrentFileName);
  PathVar := GetEnv('PATH');
  ToolPath := ExpandConstant('{app}') + '\tools\cdrtools';
  DllPath := ExpandConstant('{app}') + '\tools\cygwin';
  ScriptPath := ExtractFilePath(FileName);
  l := Length(PathVar) + Length(ToolPath) + Length(DllPath) + 2;
  if l < 1023 then
  begin
    StartCmd := 'set path=' + ToolPath + ';' + DllPath + ';' + ScriptPath + ';%PATH%';
  end else
  begin
    StartCmd := 'set path=' + ToolPath + ';' + DllPath + ';' + ScriptPath;
  end;
  ScriptFile := TStringList.Create;
  ScriptFile.LoadFromFile(FileName);
  ScriptFile[1] := StartCmd;
  ScriptFile.SaveToFile(FileName);
  ScriptFile.Free;
end;

procedure LangIniSet();
var LangSuffix: string;
begin
  LangSuffix := CustomMessage('LangSuffix');
  SetIniString('Languages', 'Default', LangSuffix, ExpandConstant(CurrentFileName));
end;

procedure InitializeWizard;
var CygTextMsg      : string;
    MkisofsDLLsFound: Boolean;
    CygFoundInSysDir: Boolean;
begin
  { Create the page - Cygwin options}
  MkisofsDLLsFound := IsInSearchPath('cygiconv-2.dll') and IsInSearchPath('cygintl-3.dll');
  CygFoundInSysDir := IsInSysDir('cygwin1.dll');
  if MkisofsDLLsFound then
  begin
    CygTextMsg := CustomMessage('CygwinText');
  end else
  begin
    CygTextMsg := CustomMessage('CygwinText') + #13#10 + #13#10 + CustomMessage('CygwinText2');
  end;
  if IsInSysDir('cygwin1.dll') then
  begin
    CygTextMsg := CygTextMsg + #13#10 + #13#10 + CustomMessage('CygwinText3');
  end;
  CygDLLPage := CreateInputOptionPage(wpSelectTasks,
                  CustomMessage('CygwinHeader'),
                  CustomMessage('CygwinHeader2'),
                  CygTextMsg,
                  True, False);
  CygDLLPage.Add(CustomMessage('CygwinOpt1'));
  CygDLLPage.Add(CustomMessage('CygwinOpt2'));
  { set default or previous value }
  case GetPreviousData('CygwinDLLMode', '') of
    'installed': CygDLLPage.SelectedValueIndex := 0;
    'included' : CygDLLPage.SelectedValueIndex := 1;
  else
    case MkisofsDLLsFound of
      True : CygDLLPage.SelectedValueIndex := 0;
      False: CygDLLPage.SelectedValueIndex := 1;
    end;
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
var CygwinDLLMode: string;
begin
  { Store the settings so we can restore them next time }
  case CygDLLPage.SelectedValueIndex of
    0: CygwinDLLMode := 'installed';
    1: CygwinDLLMode := 'included';
  end;
  SetPreviousData(PreviousDataKey, 'CygwinDLLMode', CygwinDLLMode);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  { Skip pages that shouldn't be shown }
  if (PageID = CygDLLPage.ID) and not IsInSearchPath('cygwin1.dll') then
    Result := True
  else
    Result := False;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
                         MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var S: string;
begin
  { Fill the 'Ready Memo' with the normal settings and the custom settings }
  S := '';
  if MemoUserInfoInfo <> ''   then S := S + MemoUserInfoInfo + NewLine + NewLine;
  if MemoDirInfo <> ''        then S := S + MemoDirInfo + NewLine + NewLine;
  if MemoTypeInfo <> ''       then S := S + MemoTypeInfo + NewLine + NewLine;
  if MemoComponentsInfo <> '' then S := S + MemoComponentsInfo + NewLine + NewLine;
  
  if CygIniCheck then
  begin
    S := S + CustomMessage('CygwinReadyHeader') + NewLine;
    case CygDLLPage.SelectedValueIndex of
      0: S := S + Space + CustomMessage('CygwinReadyUsePrev');
      1: S := S + Space + CustomMessage('CygwinReadyUseOwn');
    end;
    S := S + NewLine + NewLine;
  end;
  
  if MemoGroupInfo <> ''      then S := S + MemoGroupInfo + NewLine + NewLine;
  if MemoTasksInfo <> ''      then S := S + MemoTasksInfo + NewLine + NewLine;
  Result := S;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var OldInstall: Boolean;
begin
  if CurStep = ssInstall then
  begin
    {Prüfen, ob eine ältere Version vorhanden ist, die erst deinstalliert werden muß.
     Dies ist bei allen Versionen der Fall, die noch die alte Ordnerstruktur haben.}
    OldInstall := FileExists(WizardDirValue + '\cdrecord.exe');
    if OldInstall then
    begin
      MsgBox(CustomMessage('OldVersionError'), mbCriticalError, MB_OK);
      Abort;
    end;
  end;
end;

[CustomMessages]
; LangSuffix (from cdrtfe_lang.ini)
de.LangSuffix=Lang1
en.LangSuffix=Lang2
pl.LangSuffix=Lang4
fr.LangSuffix=Lang5
it.LangSuffix=Lang8
; Common
CompProg={#MyAppVerName}
CompCdrt=cdrtools
CompM2CDM=Mode2CDMaker
CompVCD=VCDImager
; German
de.CompLang=Fremdsprachenunterstützung
de.CompTools=Kommandozeilen-Tools
de.CompM2CDMex=m2cdm (modifizierter Mode2CDMaker)
de.CompRrenc=zusätzliche XCD-Fehlerkorrektur
de.CompXCD=XCD-Tools (dat2file, d2fgui, M2F2Extract)
de.CompAudio=MP3-, OGG- und FLAC-Unterstützung
de.CompSrc=Quelltexte von {#MyAppVerName}
de.TaskAllUsers=für alle Benutzer
de.TaskCurrentUser=für den aktuellen Benutzer
de.CygwinHeader=Cygwin
de.CygwinHeader2=Eine cygwin1.dll wurde auf Ihrem System gefunden.
de.CygwinText=Welche cygwin-DLL soll verwendet werden?
de.CygwinText2=Hinweis: Die Dateien cygiconv-2.dll und cygintl-3.dll wurden nicht im Suchpfad gefunden.
de.CygwinText3=Warnung: Die Datei cygwin1.dll wurde in einem Windows-System-Ordner gefunden. Daher kann die Nutzung der mitgelieferten DLL nicht erzwungen werden.
de.CygwinOpt1=Die bereits installierte DLL verwenden, um Versionskonflikte zu vermeiden.
de.CygwinOpt2=Die mitgelieferte DLL verwenden.
de.CygwinReadyHeader=Cygwin-DLLs:
de.CygwinReadyUsePrev=Verwende cygwin-DLLs aus dem Suchpfad.
de.CygwinReadyUseOwn=Verwende mitgelieferte cygwin-DLLs.
de.OldVersionError=Eine ältere Version wurde gefunden. Bitte zuerst deinstallieren.
de.IconHelpFile=cdrtfe Hilfe
de.IconSourceFiles=Quelltexte
; English
en.CompLang=Multi language support (necessary for languages other than German)
en.CompTools=Commandline tools
en.CompM2CDMex=m2cdm (modified Mode2CDMaker)
en.CompRrenc=additional XCD error protection
en.CompXCD=XCD extraction tools (dat2file, d2fgui, M2F2Extract)
en.CompAudio=MP3, OGG and FLAC support
en.CompSrc={#MyAppVerName} source files
en.TaskAllUsers=For all users
en.TaskCurrentUser=For the current user only
en.CygwinHeader=Cygwin
en.CygwinHeader2=A cygwin1.dll has been found on your system.
en.CygwinText=Which cygwin dll do you want to use?
en.CygwinText2=Note: The files cygiconv-2.dll and cygintl-3.dll could not be found in the search path.
en.CygwinText3=Warning: The file cygwin1.dll has been found in a Windows system folder. The use of the included DLL cannot be forced.
en.CygwinOpt1=Use the already installed DLL to avoid version conflicts.
en.CygwinOpt2=Use the included DLL.
en.CygwinReadyHeader=Cygwin DLLs:
en.CygwinReadyUsePrev=Using cygwin DLLs found in search path.
en.CygwinReadyUseOwn=Using included cygwin DLLs.
en.OldVersionError=An older version has been found. Please uninstall first.
en.IconHelpFile=cdrtfe Help
en.IconSourceFiles=Source files
; French
fr.CompLang=Support multilingue (nécessaire pour les langues autres que l'allemand)
fr.CompTools=Outils en ligne de commande
fr.CompM2CDMex=m2cdm (Mode2CDMaker modifié)
fr.CompRrenc=Additif pour correction d'erreur XCD
fr.CompXCD=Outils d'extraction XCD (dat2file, d2fgui, M2F2Extract)
fr.CompAudio=Prise en charge MP3, OGG, FLAC et Monkey's Audio
fr.CompSrc=Fichiers sources de {#MyAppVerName}
fr.TaskAllUsers=Pour tous les utilisateurs
fr.TaskCurrentUser=Pour l'utilisateur actuel seulement
fr.CygwinHeader=Cygwin
fr.CygwinHeader2=Un fichier cygwin1.dll a été trouvé sur votre système.
fr.CygwinText=Quelle dll cygwin voulez-vous utiliser ?
fr.CygwinText2=Remarque : les fichiers cygiconv-2.dll et cygintl-3.dll sont introuvables dans votre chemin d'accès.
fr.CygwinText3=Attention : le fichier cygwin1.dll a été trouvé dans un dossier système de Windows. L'utilisation de la DLL fournie ne peut pas être forcée.
fr.CygwinOpt1=Utiliser la DLL déjà installée pour éviter un conflit de version.
fr.CygwinOpt2=Utiliser la DLL fournie.
fr.CygwinReadyHeader=DLL Cygwin :
fr.CygwinReadyUsePrev=Utilisation des DLL cygwin trouvées dans le chemin d'accès.
fr.CygwinReadyUseOwn=Utilisation des DLL fournies.
fr.OldVersionError=Une ancienne version a été trouvée. Veuillez d'abord la désinstaller.
fr.IconHelpFile=Aide de cdrtfe
fr.IconSourceFiles=Fichiers sources
; Italian
it.CompLang=Supporto multilingue (necessario per lingue diverse dal tedesco)
it.CompTools=Strumenti a riga di comando
it.CompM2CDMex=m2cdm (Mode2CDMaker modificato)
it.CompRrenc=protezione d'errore supplementare XCD
it.CompXCD= strumenti di estrazione XCD (dat2file, d2fgui, M2F2Extract)
it.CompAudio=supporto MP3, OGG e FLAC
it.CompSrc=file sorgenti {#MyAppVerName}
it.TaskAllUsers=Per tutti gli utenti
it.TaskCurrentUser=Solo per l'utente corrente
it.CygwinHeader=Cygwin
it.CygwinHeader2=Un file cygwin1.dll è stato trovato nel sistema.
it.CygwinText=Quale dll cygwin deve essere usata?
it.CygwinText2=Nota: I file cygiconv-2.dll e cygintl-3.dll non sono stati trovati nel percorso di ricerca.
it.CygwinText3=Attenzione: Il file cygwin1.dll è stato trovato in una cartella di sistema. L'utilizzo della DDL inclusa non può essere forzato.
it.CygwinOpt1=Usare la DLL già installata per evitare conflitti di versione.
it.CygwinOpt2=Usare la DLL inclusa.
it.CygwinReadyHeader=DLL Cygwin:
it.CygwinReadyUsePrev=Si stanno usando le DLL cygwin trovate nel percorso di ricerca.
it.CygwinReadyUseOwn=Si stanno usando le DLL cygwin incluse.
it.OldVersionError=E' stata trovata una versione meno recente: si deve prima disinstallarla.
it.IconHelpFile=Help di cdrtfe
it.IconSourceFiles=File sorgente
; Polish
pl.CompLang=Dodatkowe jêzyki (dla innych wersji jêzykowych ni¿ niemiecki)
pl.CompTools=Narzêdzia wiersza poleceñ
pl.CompM2CDMex=m2cdm (zmodyfikowany Mode2CDMaker)
pl.CompRrenc=dodatkowa ochrona b³êdów XCD
pl.CompXCD=Narzêdzia rozpakowania XCD (dat2file, d2fgui, M2F2Extract)
pl.CompAudio=obs³uga MP3, OGG i FLAC
pl.CompSrc=Pliki Ÿród³owe {#MyAppVerName}
pl.TaskAllUsers=Dla wszystkich u¿ytkowników
pl.TaskCurrentUser=Dla aktualnego u¿ytkownika
pl.CygwinHeader=Cygwin
pl.CygwinHeader2=Znaleziono plik cygwin1.dll w twoim systemie.
pl.CygwinText=Który plik cygwin ma byæ u¿ywany?
pl.CygwinText2=Wskazówka: Nie znaleziono pilików cygiconv-2.dll i cygintl-3.dll  w œcie¿ce wyszukiwania.
pl.CygwinText3=Uwaga: Plik cygwin1.dll zosta³ znaleziony w katalogu Windows. Nie jest mo¿liwe wymuszenie u¿ycia wewnêtrznej biblioteki DLL.
pl.CygwinOpt1=U¿ywaj ju¿ zainstalowanego pliku DLL aby unikn¹æ konfliktu pomiêdzy wersjami.
pl.CygwinOpt2=U¿yj za³¹czony plik DLL.
pl.CygwinReadyHeader=Pliki Cygwin DLL:
pl.CygwinReadyUsePrev=U¿ywaj pliki cygwin DLL znalezione w œcie¿ce wyszukiwania.
pl.CygwinReadyUseOwn=U¿ywam za³¹czone pliki cygwin DLL.
pl.OldVersionError=Znaleziono star¹ wersje programu. Najpierw j¹ odinstaluj.
pl.IconHelpFile=Pomoc cdrtfe
pl.IconSourceFiles=Pliki Ÿród³owe

