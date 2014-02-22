; cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend
;
;  cdrtfe.iss: Inno-Setup-Skript f�r Inno Setup 5.4.3
;
;  Copyright (c) 2006-2014 Oliver Valencia
;
;  letzte �nderung  22.02.2014
;
;  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
;  GNU General Public License weitergeben und/oder modifizieren. Weitere
;  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.
;

#define MyAppName "cdrtools Frontend"
#define MyAppVer "1.5.2"
#define MyAppVerName "cdrtfe " + MyAppVer
#define MyAppPublisher "Oliver Valencia"
#define MyAppURL "http://cdrtfe.sourceforge.net"
#define MyAppExeName "cdrtfe.exe"
#define MyAppCopyright "Copyright � 2002-2014  O. Valencia, O. Kutsche"

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
;Unistaller
SignedUninstaller=yes
SignedUninstallerDir=I:\cdrtfe\setupscript\inno\signeduninstaller
; Compiler
VersionInfoVersion={#MyAppVer} 
VersionInfoCopyright={#MyAppCopyright}
OutputDir=i:\cdrtfe\proto2
;OutputDir=J:\shared\cdrtfe
OutputBaseFilename=cdrtfe-{#MyAppVer}
; Compression
;Compression=none
Compression=lzma2
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
Name: nl; MessagesFile: compiler:Languages\Dutch.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_en.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_en.rtf
Name: ptbr; MessagesFile: compiler:Languages\BrazilianPortuguese.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_pt-br.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_pt-br.rtf
Name: el; MessagesFile: compiler:Languages\Greek.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_en.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_el.rtf
Name: sv; MessagesFile: compiler:Languages\Swedish.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_en.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_sv.rtf
Name: kr; MessagesFile: compiler:Languages\Korean.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\info\license_kr.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info\info_en.rtf

[Tasks]
; Desktop icon
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked; MinVersion: 1, 0
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; MinVersion: 0, 1
Name: desktopicon\common; Description: {cm:TaskAllUsers}; GroupDescription: {cm:AdditionalIcons}; Flags: exclusive; MinVersion: 0, 1
Name: desktopicon\user; Description: {cm:TaskCurrentUser}; GroupDescription: {cm:AdditionalIcons}; Flags: exclusive unchecked; MinVersion: 0, 1
; Quicklaunch icon
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
; Copy cygwin files
Name: copycyg; Description: {cm:CopyCygwin}; GroupDescription: {cm:SpecialTask}; Flags: unchecked

[Files]
; Main program file
Source: I:\cdrtfe\proto\cdrtfe.exe; DestDir: {app}; DestName: cdrtfe.exe; Flags: ignoreversion; Components: prog
Source: I:\cdrtfe\proto\cdrtfedbg.dll; DestDir: {app}; DestName: cdrtfedbg.dll; Flags: ignoreversion; Components: prog
Source: I:\cdrtfe\proto\cdrtfeShlEx.dll; DestDir: {app}; Flags: ignoreversion; Components: prog
Source: I:\cdrtfe\proto\cdrtfeShlEx64.dll; DestDir: {app}; Flags: ignoreversion; Components: prog; Check: IsWin64;
Source: I:\cdrtfe\proto\cdrtfe.jdbg; DestDir: {app}; Flags: ignoreversion; Components: prog
; Manifest - seit Version 1.4 nicht mehr ben�tigt
; Source: I:\cdrtfe\proto\cdrtfe.exe.manifest; DestDir: {app}; DestName: cdrtfe.exe.manifest; Flags: ignoreversion; Components: prog
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
Source: I:\cdrtfe\proto\tools\cygwin\cygpopt-0.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\vcd
Source: I:\cdrtfe\proto\tools\cygwin\cygwin.ini; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt; Check: CygIniCheck; AfterInstall: CygIniSet
; Tools helper
Source: I:\cdrtfe\proto\tools\helper\cygpathprefix.exe; DestDir: {app}\tools\helper; Flags: ignoreversion; Components: tools\cdrt
; Tools: mode2cdmaker
Source: I:\cdrtfe\proto\tools\xcd\Mode2CDMaker.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\m2cdm
Source: I:\cdrtfe\proto\tools\xcd\m2cdm.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\m2cdm\ex
Source: I:\cdrtfe\misc\misc\cdrtfe_tools.ini; DestDir: {app}; Flags: ignoreversion; Components: tools\m2cdm\ex
; Tools: rrenc/rrdec
Source: I:\cdrtfe\proto\tools\xcd\rrenc.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\rrenc
Source: I:\cdrtfe\proto\tools\xcd\rrdec.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\rrenc
; Tools: XCD extraction
Source: I:\cdrtfe\proto\tools\xcd\m2f2extract.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
Source: I:\cdrtfe\proto\tools\xcd\d2fgui.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
Source: I:\cdrtfe\proto\tools\xcd\dat2file.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
; Tools: audio tools
Source: I:\cdrtfe\proto\tools\sound\mpg123.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\lame.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\oggdec.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\oggenc.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\flac.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\wavegain.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
; Tools: VCDImager
Source: I:\cdrtfe\proto\tools\vcdimager\vcdimager.exe; DestDir: {app}\tools\vcdimager; Flags: ignoreversion; Components: tools\vcd
; Commandline Scripts
Source: I:\cdrtfe\misc\scripts\cmdshell.cmd; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellSet; MinVersion: 0, 1
Source: I:\cdrtfe\misc\scripts\cmdshellinit.cmd; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellInitSet; MinVersion: 0, 1
Source: I:\cdrtfe\misc\scripts\cmdshell.bat; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellSet; MinVersion: 1, 0
Source: I:\cdrtfe\misc\scripts\cmdshellinit.bat; DestDir: {app}\tools\scripts; Flags: ignoreversion; Components: tools\cdrt; AfterInstall: CmdShellInitSet; MinVersion: 1, 0
Source: I:\cdrtfe\misc\scripts\makeiso.cmd; DestDir: {app}\tools\scripts
Source: I:\cdrtfe\misc\scripts\copycyg.bat; DestDir: {tmp}; Tasks: copycyg
; Readme cdrtfe
Source: I:\cdrtfe\cdrtfe\doc\readme_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de
Source: I:\cdrtfe\cdrtfe\doc\readme_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr it pl nl ptbr el sv kr
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_el.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: el
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr it pl nl ptbr sv kr
Source: I:\cdrtfe\cdrtfe\doc\changes\changes.txt; DestDir: {app}\doc; Flags: ignoreversion;
; Licenses
Source: I:\cdrtfe\cdrtfe\doc\license\COPYING.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: I:\cdrtfe\cdrtfe\doc\license\CDDL.Schily.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: I:\cdrtfe\cdrtfe\doc\license\license_tools.txt; DestDir: {app}\doc\license; Flags: ignoreversion
; Readme m2f2extract
Source: I:\delphi\m2f2extract\doc\m2f2extract_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de; Components: tools\xcd
Source: I:\delphi\m2f2extract\doc\m2f2extract_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr it pl nl ptbr el sv kr; Components: tools\xcd
; source files
Source: I:\cdrtfe\cdrtfe\source\*; DestDir: {app}\source\cdrtfe; Excludes: COPYING.txt,forms.pas,controls.pas,inifiles.pas; Flags: ignoreversion recursesubdirs; Components: src
Source: I:\cdrtfe\cdrtfe\shellex\cdrtfeShlEx\*; DestDir: {app}\source\cdrtfeShlEx; Flags: ignoreversion recursesubdirs; Components: src
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; Program
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}
Name: {group}\cdrtfe (debug mode); Filename: {app}\{#MyAppExeName}; Parameters: "/debug"
; CommandShell
Name: {group}\CommandShell; Filename: {app}\tools\scripts\cmdshell.cmd; MinVersion: 0, 1
Name: {group}\CommandShell; Filename: {app}\tools\scripts\cmdshell.bat; MinVersion: 1, 0
; Help file
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_german.chm; Languages: de
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_english.chm; Languages: en pl nl ptbr sv kr
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_french.chm; Languages: fr
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_italian.chm; Languages: it
Name: {group}\{cm:IconHelpFile}; Filename: {app}\help\cdrtfe_greek.chm; Languages: el
; Readme files
Name: {group}\Changes; Filename: {app}\doc\changes.txt;
;Name: {group}\Readme; Filename: {app}\doc\readme_de.txt; Languages: de
;Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_de.txt; Languages: de
;Name: {group}\Readme; Filename: {app}\doc\readme_en.txt; Languages: en fr it pl ptbr
;Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_en.txt; Languages: en fr it pl nl ptbr sv kr
;Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_el.txt; Languages: el
;Name: {group}\Readme Icons; Filename: {app}\icons\readme.txt;
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_de.txt; Languages: de; Components: tools\xcd
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_en.txt; Languages: en fr it pl nl ptbr el sv kr; Components: tools\xcd
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
Filename: "{tmp}\copycyg.bat"; Parameters: """{app}"""; Tasks: copycyg
;Filename: "{app}\doc\readme_en.txt"; Languages: en fr it pl nl ptbr; Flags: shellexec postinstall skipifsilent unchecked
;Filename: "{app}\doc\readme_de.txt"; Languages: de; Flags: shellexec postinstall skipifsilent unchecked
;Filename: "{app}\doc\readme_dvd_en.txt"; Languages: en fr it pl nl ptbr; Flags: shellexec postinstall skipifsilent unchecked
;Filename: "{app}\doc\readme_dvd_de.txt"; Languages: de; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\changes.txt"; Flags: shellexec postinstall skipifsilent unchecked
Filename: {app}\{#MyAppExeName}; Description: {cm:LaunchProgram,{#MyAppName}}; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\tools\cdrtools\*.dll"; Tasks: copycyg
Type: files; Name: "{app}\tools\cdrtools\*.cmd"; Tasks: copycyg

[Types]
Name: custom; Description: cdrtfe Setup; Flags: iscustom

[Components]
; cdrtfe
Name: prog; Description: {cm:CompProg}; Flags: fixed; Types: custom
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Types: custom; Languages: en fr it pl nl ptbr el sv kr
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Languages: de
; Tools
Name: tools; Description: {cm:CompTools}; Flags: fixed; Types: custom;
Name: tools\cdrt; Description: {cm:CompCdrt}; Flags: fixed; Types: custom;
Name: tools\m2cdm; Description: {cm:CompM2CDM}; Flags: dontinheritcheck checkablealone; Types: custom;
Name: tools\m2cdm\ex; Description: {cm:CompM2CDMex}; Flags: dontinheritcheck;
Name: tools\rrenc; Description: {cm:CompRrenc}; Flags: dontinheritcheck; Types: custom;
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
  SetIniBool('CygwinDLL', 'CheckForActiveDLL', False, ExpandConstant(CurrentFileName));
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
  if not UsingWinNT then
  begin
    if Pos(' ', ToolPath) > 0 then
    begin
      ToolPath := '"' + ToolPath + '"';
      DllPath := '"' + DllPath + '"';
      ScriptPath := '"' + ScriptPath + '"';
    end;
  end;
  l := Length(PathVar) + Length(ToolPath) + Length(DllPath) + 2;
  if l < 2048 then
  begin
    StartCmd := 'set path=' + ToolPath + ';' + DllPath + ';' + ScriptPath + '";%PATH%';
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
    {Pr�fen, ob eine �ltere Version vorhanden ist, die erst deinstalliert werden mu�.
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
nl.LangSuffix=Lang3
pl.LangSuffix=Lang4
fr.LangSuffix=Lang5
it.LangSuffix=Lang8
ptbr.LangSuffix=Lang14
el.LangSuffix=Lang16
sv.LangSuffix=Lang18
kr.LangSuffix=Lang20
; Common
CompProg={#MyAppVerName}
CompCdrt=cdrtools
CompM2CDM=Mode2CDMaker
CompVCD=VCDImager
; German
de.CompLang=Fremdsprachenunterst�tzung
de.CompTools=Kommandozeilen-Tools
de.CompM2CDMex=m2cdm (modifizierter Mode2CDMaker)
de.CompRrenc=zus�tzliche XCD-Fehlerkorrektur
de.CompXCD=XCD-Tools (dat2file, d2fgui, M2F2Extract)
de.CompAudio=MP3-, OGG- und FLAC-Unterst�tzung
de.CompSrc=Quelltexte von {#MyAppVerName}
de.TaskAllUsers=f�r alle Benutzer
de.TaskCurrentUser=f�r den aktuellen Benutzer
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
de.OldVersionError=Eine �ltere Version wurde gefunden. Bitte zuerst deinstallieren.
de.IconHelpFile=cdrtfe Hilfe
de.IconSourceFiles=Quelltexte
de.SpecialTask=spezielle Aufgaben:
de.CopyCygwin=Cygwin-DLLs und Skripte kopieren (nur f�r Experten, nicht empfohlen)
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
en.SpecialTask=special Tasks:
en.CopyCygwin=Copy Cygwin DLLs and scripts (only for experts, not recommended)
; French
fr.CompLang=Prise en charge multilingue (n�cessaire pour d'autres langues que l'allemand)
fr.CompTools=Outils en ligne de commande
fr.CompM2CDMex=m2cdm (Mode2CDMaker modifi�)
fr.CompRrenc=Correction d'erreur XCD suppl�mentaire
fr.CompXCD=Outils d'extraction XCD (dat2file, d2fgui, M2F2Extract)
fr.CompAudio=Prise en charge de MP3, OGG et FLAC
fr.CompSrc=Fichiers sources de {#MyAppVerName}
fr.TaskAllUsers=Pour tous les utilisateurs
fr.TaskCurrentUser=Pour l'utilisateur actuel seulement
fr.CygwinHeader=Cygwin
fr.CygwinHeader2=Un fichier cygwin1.dll a �t� trouv� sur votre syst�me.
fr.CygwinText=Quelle dll cygwin voulez-vous utiliser ?
fr.CygwinText2=Remarque : les fichiers cygiconv-2.dll et cygintl-3.dll sont introuvables dans votre chemin d'acc�s.
fr.CygwinText3=Attention : le fichier cygwin1.dll a �t� trouv� dans un dossier syst�me de Windows. L'utilisation de la dll fournie ne peut pas �tre forc�e.
fr.CygwinOpt1=Utiliser la dll d�j� install�e pour �viter un conflit de version.
fr.CygwinOpt2=Utiliser la dll fournie.
fr.CygwinReadyHeader=Dll cygwin :
fr.CygwinReadyUsePrev=Utilisation des dll cygwin trouv�es dans le chemin d'acc�s.
fr.CygwinReadyUseOwn=Utilisation des dll fournies.
fr.OldVersionError=Une ancienne version a �t� trouv�e. Veuillez d'abord la d�sinstaller.
fr.IconHelpFile=Aide de cdrtfe
fr.IconSourceFiles=Fichiers sources
fr.SpecialTask=T�ches sp�ciales :
fr.CopyCygwin=Copier les dll cygwin et les scripts (pour expert seulement, non recommand�)
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
it.CygwinHeader2=Un file cygwin1.dll � stato trovato nel sistema.
it.CygwinText=Quale dll cygwin deve essere usata?
it.CygwinText2=Nota: I file cygiconv-2.dll e cygintl-3.dll non sono stati trovati nel percorso di ricerca.
it.CygwinText3=Attenzione: Il file cygwin1.dll � stato trovato in una cartella di sistema. L'utilizzo della DDL inclusa non pu� essere forzato.
it.CygwinOpt1=Usare la DLL gi� installata per evitare conflitti di versione.
it.CygwinOpt2=Usare la DLL inclusa.
it.CygwinReadyHeader=DLL Cygwin:
it.CygwinReadyUsePrev=Si stanno usando le DLL cygwin trovate nel percorso di ricerca.
it.CygwinReadyUseOwn=Si stanno usando le DLL cygwin incluse.
it.OldVersionError=E' stata trovata una versione meno recente: si deve prima disinstallarla.
it.IconHelpFile=Help di cdrtfe
it.IconSourceFiles=File sorgente
it.SpecialTask=special Tasks:
it.CopyCygwin=Copy Cygwin DLLs and scripts (only for experts, not recommended)
; Polish
pl.CompLang=Dodatkowe j�zyki (dla innych wersji j�zykowych ni� niemiecki)
pl.CompTools=Narz�dzia wiersza polece�
pl.CompM2CDMex=m2cdm (zmodyfikowany Mode2CDMaker)
pl.CompRrenc=dodatkowa ochrona b��d�w XCD
pl.CompXCD=Narz�dzia rozpakowania XCD (dat2file, d2fgui, M2F2Extract)
pl.CompAudio=obs�uga MP3, OGG i FLAC
pl.CompSrc=Pliki �r�d�owe {#MyAppVerName}
pl.TaskAllUsers=Dla wszystkich u�ytkownik�w
pl.TaskCurrentUser=Dla aktualnego u�ytkownika
pl.CygwinHeader=Cygwin
pl.CygwinHeader2=Znaleziono plik cygwin1.dll w twoim systemie.
pl.CygwinText=Kt�ry plik cygwin ma by� u�ywany?
pl.CygwinText2=Wskaz�wka: Nie znaleziono pilik�w cygiconv-2.dll i cygintl-3.dll  w �cie�ce wyszukiwania.
pl.CygwinText3=Uwaga: Plik cygwin1.dll zosta� znaleziony w katalogu Windows. Nie jest mo�liwe wymuszenie u�ycia wewn�trznej biblioteki DLL.
pl.CygwinOpt1=U�ywaj ju� zainstalowanego pliku DLL aby unikn�� konfliktu pomi�dzy wersjami.
pl.CygwinOpt2=U�yj za��czony plik DLL.
pl.CygwinReadyHeader=Pliki Cygwin DLL:
pl.CygwinReadyUsePrev=U�ywaj pliki cygwin DLL znalezione w �cie�ce wyszukiwania.
pl.CygwinReadyUseOwn=U�ywam za��czone pliki cygwin DLL.
pl.OldVersionError=Znaleziono star� wersje programu. Najpierw j� odinstaluj.
pl.IconHelpFile=Pomoc cdrtfe
pl.IconSourceFiles=Pliki �r�d�owe
pl.SpecialTask=special Tasks:
pl.CopyCygwin=Copy Cygwin DLLs and scripts (only for experts, not recommended)
; Dutch
nl.CompLang=Meertalige ondersteuning (nodig voor andere talen dan Duits)
nl.CompTools=Opdrachtregel-tools
nl.CompM2CDMex=m2cdm (gewijzigde Mode2CDMaker)
nl.CompRrenc=aanvullende XCD-foutbescherming
nl.CompXCD=XCD-extractiegereedschap (dat2file, d2fgui, M2F2Extract)
nl.CompAudio=MP3-, OGG- en FLAC-ondersteuning
nl.CompSrc={#MyAppVerName} bronbestanden
nl.TaskAllUsers=Voor alle gebruikers
nl.TaskCurrentUser=Alleen voor deze gebruiker
nl.CygwinHeader=Cygwin
nl.CygwinHeader2=Cygwin1.dll werd op uw systeem gevonden.
nl.CygwinText=Welke cygwin dll wilt u gebruiken?
nl.CygwinText2=Opmerking: de bestanden cygiconv-2.dll en cygintl-3.dll konden niet teruggevonden worden in het zoekpad.
nl.CygwinText3=Waarschuwing: het bestand cygwin1.dll werd teruggevonden in een Windows-systeemmap. Het gebruik van de bijgeleverde dll kan niet geforceerd worden.
nl.CygwinOpt1=Gebruik de reeds ge�nstalleerde dll om versieconflicten te vermijden.
nl.CygwinOpt2=Gebruik de bijgeleverde dll.
nl.CygwinReadyHeader=Cygwin dll's:
nl.CygwinReadyUsePrev=Cygwin dll's van zoekpad gebruiken.
nl.CygwinReadyUseOwn=Bijgeleverde cygwin dll's gebruiken.
nl.OldVersionError=Er werd een oudere versie gevonden. Gelieve deze eerst te de�nstalleren.
nl.IconHelpFile=cdrtfe Help
nl.IconSourceFiles=Bronbestanden
nl.SpecialTask=speciale taken:
nl.CopyCygwin=Cygwin dll's en scripts kopi�ren (alleen voor experts, niet aangeraden)
; Brazilian-portuguese
ptbr.CompLang=Suporte a m�ltiplas linguagens (necess�rio para outras linguagens al�m do alem�o)
ptbr.CompTools=Ferramentas em linha de comando
ptbr.CompM2CDMex=m2cdm (Mode2CDMaker modificado)
ptbr.CompRrenc=Prote��o adicional aos erros do XCD
ptbr.CompXCD=Ferramentas de extra��o XCD (dat2file, d2fgui, M2F2Extract)
ptbr.CompAudio=Suporte a MP3, OGG e FLAC
ptbr.CompSrc=C�digo fonte do {#MyAppVerName}
ptbr.TaskAllUsers=Para todos os usu�rios
ptbr.TaskCurrentUser=Apenas para este usu�rio
ptbr.CygwinHeader=Cygwin
ptbr.CygwinHeader2=O arquivo cygwin1.dll foi encontrado.
ptbr.CygwinText=Qual dll do cygwin voc� deseja usar?
ptbr.CygwinText2=Nota: Os arquivos cygiconv-2.dll e cygintl-3.dll n�o puderam ser encontrados no diret�rio pesquisado.
ptbr.CygwinText3=Aviso: O arquivo cygwin1.dll foi encontrado numa pasta de sistema do Windows. Imposs�vel for�ar o uso da DLL inclu�da.
ptbr.CygwinOpt1=Use a DLL j� instalada para evitar conflitos entre vers�es.
ptbr.CygwinOpt2=Use a DLL inclu�da.
ptbr.CygwinReadyHeader=DLLs do Cygwin:
ptbr.CygwinReadyUsePrev=Usando DLLs do cygwin encontrado no diret�rio pesquisado.
ptbr.CygwinReadyUseOwn=Usando DLLs inclu�das do cygwin.
ptbr.OldVersionError=Uma vers�o mais antiga foi encontrada. Por favor, desinstale-o primeiro.
ptbr.IconHelpFile=Ajuda do cdrtfe
ptbr.IconSourceFiles=C�digos fonte
ptbr.SpecialTask=Tarefas especiais:
ptbr.CopyCygwin=Copiar os scripts e as DLLs do Cygwin (apenas para usu�rios avan�ados, n�o recomendado)
; Greek
el.CompLang=������������� ���������� (���������� ��� ������� ����� ��� ����������)
el.CompTools=�������� ��� ������� �������
el.CompM2CDMex=m2cdm (modified Mode2CDMaker)
el.CompRrenc=�������� XCD ��������� ������
el.CompXCD=XCD �������� �������� (dat2file, d2fgui, M2F2Extract)
el.CompAudio=MP3, OGG ��� FLAC ����������
el.CompSrc={#MyAppVerName} ������ ������
el.TaskAllUsers=��� ����� ���� �������
el.TaskCurrentUser=��� ��� ������ ������ ����
el.CygwinHeader=Cygwin
el.CygwinHeader2=�� cygwin1.dll ������� ��� ������� ���.
el.CygwinText=���� cygwin dll ������ �� ��������������� ;
el.CygwinText2=��������: �� ������ cygiconv-2.dll ��� cygintl-3.dll ��� �������� ������ �� ������� ��� �������� ����������.
el.CygwinText3=Warning: �� ������ cygwin1.dll ����������� �� ��� ������ ��� ���������� ��� Windows. � ����� ��� ������������������� DLL ��� ������ �� ���������.
el.CygwinOpt1=����� ����� ��� ��� �������������� DLL ���� �������� ���������� ��� ��������.
el.CygwinOpt2=����� ����� ��� ������������������� DLL.
el.CygwinReadyHeader=Cygwin DLLs:
el.CygwinReadyUsePrev=��������������� cygwin DLLs ��� �������� ��� �������� ����������.
el.CygwinReadyUseOwn=��������������� �� ������������������ cygwin DLLs.
el.OldVersionError=��� ���������� ������ �������. ����������� ����� ������������� �����.
el.IconHelpFile=cdrtfe �������
el.IconSourceFiles=������ ������
el.SpecialTask=������ ����:
el.CopyCygwin=��������� ��� Cygwin DLLs ��� ��� scripts (���� ��� experts, ��� ����������)
; Swedish
sv.CompLang=Spr�kst�d (N�dv�ndigt f�r andra spr�k �n Tyska)
sv.CompTools=Kommandoradsverktyg
sv.CompM2CDMex=m2cdm (modifierad Mode2CDMaker)
sv.CompRrenc=Extra XCD felskydd
sv.CompXCD=XCD extraheringsverktyg (dat2file, d2fgui, M2F2Extract)
sv.CompAudio=MP3-, OGG- och FLAC-st�d
sv.CompSrc={#MyAppVerName} k�llfiler
sv.TaskAllUsers=F�r alla anv�ndare
sv.TaskCurrentUser=Endast f�r mig
sv.CygwinHeader=Cygwin
sv.CygwinHeader2=En befintlig cygwin1.dll har uppt�ckts i systemet.
sv.CygwinText=Vilken cygwin dll vill du anv�nda?
sv.CygwinText2=Notis: cygiconv-2.dll och cygintl-3.dll kan inte hittas i systemet.
sv.CygwinText3=Varning! cygwin1.dll har hittats i Windows systemkatalog. Anv�ndning av den, i installationsprogrammet, inkluderade DLL-filen kan inte genomf�ras.
sv.CygwinOpt1=Anv�nd den redan installerade DLL-filen f�r att undvika versionskonflikter.
sv.CygwinOpt2=Anv�nd den, i installationsprogrammet, inkluderade DLL-filen.
sv.CygwinReadyHeader=Cygwin DLL-filer:
sv.CygwinReadyUsePrev=Anv�nder redan installerade cygwin DLL-filer.
sv.CygwinReadyUseOwn=Anv�nder installationsprogrammets cygwin DLL-filer.
sv.OldVersionError=En �ldre version har hittats. Avinstallera den f�rst.
sv.IconHelpFile=cdrtfe Hj�lp
sv.IconSourceFiles=K�llfiler
sv.SpecialTask=S�rskilda uppgifter:
sv.CopyCygwin=Kopiera Cygwin DLL-filer och script (endast f�r experter, rekommenderas inte)
; Korean
kr.CompLang=���� ��� ���� (���Ͼ� �̿��� �� ���� �ʿ���)
kr.CompTools=����� ����
kr.CompM2CDMex=m2cdm (modified Mode2CDMaker)
kr.CompRrenc=additional XCD error protection
kr.CompXCD=XCD extraction tools (dat2file, d2fgui, M2F2Extract)
kr.CompAudio=MP3, OGG and FLAC support
kr.CompSrc={#MyAppVerName} �ҽ� ����
kr.TaskAllUsers=��� ����ڿ� ����
kr.TaskCurrentUser=���� ����ڿ� ���ؼ���
kr.CygwinHeader=Cygwin
kr.CygwinHeader2=cygwin1.dll�� �ý��ۿ��� �߰ߵǾ����ϴ�.
kr.CygwinText=cygwin dll�� ����Ͻðڽ��ϱ�?
kr.CygwinText2=����: cygiconv-2.dll,cygintl-3.dll������ �˻� ��ο��� ã�� �� �����ϴ�.
kr.CygwinText3=���: Windows �ý��� ������ ���� cygwin1.dll �߰� �Ǿ����ϴ�. ���� �� DLL�� ����� ���� �� �����ϴ�.
kr.CygwinOpt1=���� �浹�� ���ϱ� ���� �̹� ��ġ�� DLL�� ����մϴ�.
kr.CygwinOpt2=���Ե� DLL�� ����մϴ�.
kr.CygwinReadyHeader=Cygwin DLLs:
kr.CygwinReadyUsePrev=�˻� ��ο��� ã�� cygwin DLL�� ����մϴ�.
kr.CygwinReadyUseOwn=cygwin DLL�� �����Ͽ� ����մϴ�.
kr.OldVersionError=���� ������ �߰ߵǾ����ϴ�. ���� �����Ͻñ� �ٶ��ϴ�.
kr.IconHelpFile=cdrtfe ����
kr.IconSourceFiles=�ҽ� ����
kr.SpecialTask=Ư�� �۾�:
kr.CopyCygwin=Cygwin ���� DLL �� ��ũ��Ʈ (�� �������� �������� ����)