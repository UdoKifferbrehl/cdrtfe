; cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend
;
;  cdrtfe.iss: Inno-Setup-Skript für Inno Setup 5.2.2
;
;  Copyright (c) 2006-2008 Oliver Valencia
;
;  letzte Änderung  19.01.2008
;
;  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
;  GNU General Public License weitergeben und/oder modifizieren. Weitere
;  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.
;

#define MyAppName "cdrtools Frontend"
#define MyAppVerName "cdrtfe 1.3"
#define MyAppPublisher "Oliver Valencia"
#define MyAppURL "http://cdrtfe.sourceforge.net"
#define MyAppExeName "cdrtfe.exe"
#define MyAppCopyright "Copyright © 2002-2008  O. Valencia, O. Kutsche"

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
VersionInfoVersion=1.3
VersionInfoCopyright={#MyAppCopyright}
OutputDir=j:\
OutputBaseFilename=cdrtfe-1.3
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

[Languages]
Name: eng; MessagesFile: compiler:Default.isl; LicenseFile: H:\daten\informat\pascal\delphi\cdrtfe\doc\setup\license_en.rtf; InfoBeforeFile: H:\daten\informat\pascal\delphi\cdrtfe\doc\setup\dvd_en.rtf
Name: ger; MessagesFile: compiler:Languages\German.isl; LicenseFile: H:\daten\informat\pascal\delphi\cdrtfe\doc\setup\license_de.rtf; InfoBeforeFile: H:\daten\informat\pascal\delphi\cdrtfe\doc\setup\dvd_de.rtf

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
Source: I:\burn\cdrtfe.exe; DestDir: {app}; DestName: cdrtfe.exe; Flags: ignoreversion; Components: prog
Source: I:\burn\_cdrtfedbg.dll; DestDir: {app}; DestName: _cdrtfedbg.dll; Flags: ignoreversion; Components: prog
Source: I:\burn\cdrtfeShlEx.dll; DestDir: {app}; Flags: ignoreversion; Components: prog
Source: I:\burn\cdrtfe.jdbg; DestDir: {app}; Flags: ignoreversion; Components: prog
; Manifest
Source: I:\burn\cdrtfe.exe.manifest; DestDir: {app}; DestName: cdrtfe.exe.manifest; Flags: ignoreversion; Components: prog
; Icons/Glyphs
Source: I:\burn\icons\*; DestDir: {app}\icons; Flags: ignoreversion; Components: prog
; Language file
Source: I:\burn\_cdrtfe_lang.ini; DestDir: {app}; DestName: cdrtfe_lang.ini; Flags: ignoreversion; Components: prog\langsupport
Source: I:\burn\_cdrtfeShlEx_lang.ini; DestDir: {app}; DestName: cdrtfeShlEx_lang.ini; Flags: ignoreversion; Components: prog\langsupport
; Help files
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\help_de\cdrtfe.chm; DestDir: {app}; Flags: ignoreversion; Languages: ger
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\help_en\cdrtfe.chm; DestDir: {app}; Flags: ignoreversion; Languages: eng
; Tools: cdrtools
Source: I:\burn\tools\cdrtools\cdrecord.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cdrtools\mkisofs.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cdrtools\readcd.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cdrtools\cdda2wav.exe; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cdrtools\.mkisofsrc; DestDir: {app}\tools\cdrtools; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cdrtools\siconv\*.*; DestDir: {app}\tools\cdrtools\siconv; Flags: ignoreversion; Components: tools\cdrt
; Tools cygwin
Source: I:\burn\tools\cygwin\sh.exe; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cygwin\cygwin1.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cygwin\cygiconv-2.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cygwin\cygintl-3.dll; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt
Source: I:\burn\tools\cygwin\cygwin.ini; DestDir: {app}\tools\cygwin; Flags: ignoreversion; Components: tools\cdrt; Check: CygIniCheck; AfterInstall: CygIniSet
; Tools: mode2cdmaker
Source: I:\burn\tools\xcd\Mode2CDMaker.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\m2cdm
Source: I:\burn\tools\xcd\m2cdm.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\m2cdm\ex
Source: I:\burn\misc\cdrtfe_tools.ini; DestDir: {app}; Flags: ignoreversion; Components: tools\m2cdm\ex
; Tools: rrenc/rrdec
Source: I:\burn\tools\xcd\rrenc.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\rrenc
Source: I:\burn\tools\xcd\rrdec.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\rrenc
; Tools: XCD extraction
Source: I:\burn\tools\xcd\m2f2extract.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
Source: I:\burn\tools\xcd\d2fgui.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
Source: I:\burn\tools\xcd\dat2file.exe; DestDir: {app}\tools\xcd; Flags: ignoreversion; Components: tools\xcd
; Tools: audio tools
Source: I:\burn\tools\sound\madplay.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\burn\tools\sound\lame.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\burn\tools\sound\oggdec.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\burn\tools\sound\oggenc.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\burn\tools\sound\flac.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
; Tools: VCDImager
Source: I:\burn\tools\vcdimager\vcdimager.exe; DestDir: {app}\tools\vcdimager; Flags: ignoreversion; Components: tools\vcd
; Readme cdrtfe
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\readme_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: ger
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\readme_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: eng
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\readme_dvd_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: ger
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\readme_dvd_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: eng
; Licenses
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\license\COPYING.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\license\CDDL.Schily.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: H:\daten\informat\pascal\delphi\cdrtfe\doc\license\license_tools.txt; DestDir: {app}\doc\license; Flags: ignoreversion
; Readme m2f2extract
Source: H:\daten\informat\pascal\delphi\m2f2extract\doc\m2f2extract_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: ger; Components: tools\xcd
Source: H:\daten\informat\pascal\delphi\m2f2extract\doc\m2f2extract_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: eng; Components: tools\xcd
; source files
Source: H:\daten\informat\pascal\delphi\cdrtfe\source\*; DestDir: {app}\source\cdrtfe; Excludes: COPYING.txt,forms.pas,controls.pas,inifiles.pas; Flags: ignoreversion recursesubdirs; Components: src
Source: H:\daten\informat\pascal\delphi\cdrtfe\shellex\cdrtfeShlEx\*; DestDir: {app}\source\cdrtfeShlEx; Flags: ignoreversion recursesubdirs; Components: src
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; Program
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}
; Help file
Name: {group}\cdrtfe Hilfe; Filename: {app}\cdrtfe.chm; Languages: ger
Name: {group}\cdrtfe Help; Filename: {app}\cdrtfe.chm; Languages: eng
; Readme files
Name: {group}\Readme; Filename: {app}\doc\readme_de.txt; Languages: ger
Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_de.txt; Languages: ger
Name: {group}\Readme; Filename: {app}\doc\readme_en.txt; Languages: eng
Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_en.txt; Languages: eng
Name: {group}\Reame Icons; Filename: {app}\icons\readme.txt;
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_en.txt; Languages: eng; Components: tools\xcd
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_de.txt; Languages: ger; Components: tools\xcd
; Source files
Name: {group}\Quelltexte; Filename: {app}\source; Languages: ger; Components: src
Name: {group}\Source files; Filename: {app}\source; Languages: eng; Components: src
; Uninstall
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe}
; Desktop & Quicklaunch Icon
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon; MinVersion: 1, 0
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon\user; MinVersion: 0, 1
Name: {commondesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon\common; MinVersion: 0, 1
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: quicklaunchicon

[Run]
Filename: "{app}\doc\readme_en.txt"; Languages: eng; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_de.txt"; Languages: ger; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_dvd_en.txt"; Languages: eng; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_dvd_de.txt"; Languages: ger; Flags: shellexec postinstall skipifsilent unchecked
Filename: {app}\{#MyAppExeName}; Description: {cm:LaunchProgram,{#MyAppName}}; Flags: nowait postinstall skipifsilent

[Types]
Name: custom; Description: cdrtfe Setup; Flags: iscustom

[Components]
; cdrtfe
Name: prog; Description: {cm:CompProg}; Flags: fixed; Types: custom
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Types: custom; Languages: eng
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Languages: ger
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

procedure InitializeWizard;
begin
  { Create the page }
  CygDLLPage := CreateInputOptionPage(wpSelectTasks,
                  CustomMessage('CygwinHeader'),
                  CustomMessage('CygwinHeader2'),
                  CustomMessage('CygwinText'),
                  True, False);
  CygDLLPage.Add(CustomMessage('CygwinOpt1'));
  CygDLLPage.Add(CustomMessage('CygwinOpt2'));
  { set default or previous value }
  case GetPreviousData('CygwinDLLMode', '') of
    'installed': CygDLLPage.SelectedValueIndex := 0;
    'included' : CygDLLPage.SelectedValueIndex := 1;
  else
    CygDLLPage.SelectedValueIndex := 0;
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

[CustomMessages]
eng.CompProg={#MyAppVerName}
ger.CompProg={#MyAppVerName}
eng.CompLang=Multi language support (necessary for languages other than German)
ger.CompLang=Fremdsprachenunterstützung
eng.CompTools=Commandline tools
ger.CompTools=Kommandozeilen-Tools
CompCdrt=cdrtools
CompM2CDM=Mode2CDMaker
eng.CompM2CDMex=m2cdm (modified Mode2CDMaker)
ger.CompM2CDMex=m2cdm (modifizierter Mode2CDMaker)
eng.CompRrenc=additional XCD error protection
ger.CompRrenc=zusätzliche XCD-Fehlerkorrektur
eng.CompXCD=XCD extraction tools (dat2file, d2fgui, M2F2Extract)
ger.CompXCD=XCD-Tools (dat2file, d2fgui, M2F2Extract)
eng.CompAudio=MP3, OGG and FLAC support
ger.CompAudio=MP3-, OGG- und FLAC-Unterstützung
CompVCD=VCDImager
eng.CompSrc={#MyAppVerName} source files
ger.CompSrc=Quelltexte von {#MyAppVerName}
eng.TaskAllUsers=For all users
ger.TaskAllUsers=für alle Benutzer
eng.TaskCurrentUser=For the current user only
ger.TaskCurrentUser=für den aktuellen Benutzer
eng.CygwinHeader=Cygwin
ger.CygwinHeader=Cygwin
eng.CygwinHeader2=A cygwin1.dll has been found on your system.
ger.CygwinHeader2=Eine cygwin1.dll wurde auf Ihrem System gefunden.
eng.CygwinText=Which cygwin dll do you want to use?
ger.CygwinText=Welche cygwin-DLL soll verwendet werden?
eng.CygwinOpt1=Use the already installed DLL to avoid version conflicts.
ger.CygwinOpt1=Die bereits installierte DLL verwenden, um Versionskonflikte zu vermeiden.
eng.CygwinOpt2=Use the included DLL.
ger.CygwinOpt2=Die mitgelieferte DLL verwenden.
eng.CygwinReadyHeader=Cygwin DLLs:
ger.CygwinReadyHeader=Cygwin-DLLs:
eng.CygwinReadyUsePrev=Using cygwin DLLs found in search path.
ger.CygwinReadyUsePrev=Verwende cygwin-DLLs aus dem Suchpfad.
eng.CygwinReadyUseOwn=Using included cygwin DLLs.
ger.CygwinReadyUseOwn=Verwende mitgelieferte cygwin-DLLs.
