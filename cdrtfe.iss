; cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend
;
;  cdrtfe.iss: Inno-Setup-Skript für Inno Setup 5.2.2
;
;  Copyright (c) 2006-2008 Oliver Valencia
;
;  letzte Änderung  08.08.2008
;
;  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
;  GNU General Public License weitergeben und/oder modifizieren. Weitere
;  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.
;

#define MyAppName "cdrtools Frontend"
#define MyAppVerName "cdrtfe 1.3.2"
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
VersionInfoVersion=1.3.2
VersionInfoCopyright={#MyAppCopyright}
OutputDir=i:\cdrtfe\proto2
;OutputDir=J:\shared\cdrtfe
OutputBaseFilename=cdrtfe-1.3.2
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
Name: en; MessagesFile: compiler:Default.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\license_en.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info_en.rtf
Name: de; MessagesFile: compiler:Languages\German.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\license_de.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info_de.rtf
Name: fr; MessagesFile: compiler:Languages\French.isl; LicenseFile: I:\cdrtfe\cdrtfe\doc\setup\license_fr.rtf; InfoBeforeFile: I:\cdrtfe\cdrtfe\doc\setup\info_fr.rtf

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
Source: I:\cdrtfe\proto\tools\sound\madplay.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\lame.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\oggdec.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\oggenc.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
Source: I:\cdrtfe\proto\tools\sound\flac.exe; DestDir: {app}\tools\sound; Flags: ignoreversion; Components: tools\audio
; Tools: VCDImager
Source: I:\cdrtfe\proto\tools\vcdimager\vcdimager.exe; DestDir: {app}\tools\vcdimager; Flags: ignoreversion; Components: tools\vcd
; Readme cdrtfe
Source: I:\cdrtfe\cdrtfe\doc\readme_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de
Source: I:\cdrtfe\cdrtfe\doc\readme_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de
Source: I:\cdrtfe\cdrtfe\doc\readme_dvd_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr
; Licenses
Source: I:\cdrtfe\cdrtfe\doc\license\COPYING.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: I:\cdrtfe\cdrtfe\doc\license\CDDL.Schily.txt; DestDir: {app}\doc\license; Flags: ignoreversion
Source: I:\cdrtfe\cdrtfe\doc\license\license_tools.txt; DestDir: {app}\doc\license; Flags: ignoreversion
; Readme m2f2extract
Source: I:\delphi\m2f2extract\doc\m2f2extract_de.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: de; Components: tools\xcd
Source: I:\delphi\m2f2extract\doc\m2f2extract_en.txt; DestDir: {app}\doc; Flags: ignoreversion; Languages: en fr; Components: tools\xcd
; source files
Source: I:\cdrtfe\cdrtfe\source\*; DestDir: {app}\source\cdrtfe; Excludes: COPYING.txt,forms.pas,controls.pas,inifiles.pas; Flags: ignoreversion recursesubdirs; Components: src
Source: I:\cdrtfe\cdrtfe\shellex\cdrtfeShlEx\*; DestDir: {app}\source\cdrtfeShlEx; Flags: ignoreversion recursesubdirs; Components: src
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
; Program
Name: {group}\{#MyAppName}; Filename: {app}\{#MyAppExeName}
; Help file
Name: {group}\{cm:IconHelpFile}; Filename: {app}\cdrtfe_german.chm; Languages: de
Name: {group}\{cm:IconHelpFile}; Filename: {app}\cdrtfe_english.chm; Languages: en
Name: {group}\{cm:IconHelpFile}; Filename: {app}\cdrtfe_french.chm; Languages: fr
; Readme files
Name: {group}\Readme; Filename: {app}\doc\readme_de.txt; Languages: de
Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_de.txt; Languages: de
Name: {group}\Readme; Filename: {app}\doc\readme_en.txt; Languages: en fr
Name: {group}\Readme DVD; Filename: {app}\doc\readme_dvd_en.txt; Languages: en fr
Name: {group}\Readme Icons; Filename: {app}\icons\readme.txt;
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_en.txt; Languages: en fr; Components: tools\xcd
Name: {group}\Readme M2F2Extract; Filename: {app}\doc\m2f2extract_de.txt; Languages: de; Components: tools\xcd
; Source files
Name: {group}\{cm:IconSourceFiles}; Filename: {app}\source; Components: src
; Uninstall
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe}
; Desktop & Quicklaunch Icon
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon; MinVersion: 1, 0
Name: {userdesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon\user; MinVersion: 0, 1
Name: {commondesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: desktopicon\common; MinVersion: 0, 1
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}; Filename: {app}\{#MyAppExeName}; Tasks: quicklaunchicon

[Run]
Filename: "{app}\doc\readme_en.txt"; Languages: en fr; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_de.txt"; Languages: de; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_dvd_en.txt"; Languages: en fr; Flags: shellexec postinstall skipifsilent unchecked
Filename: "{app}\doc\readme_dvd_de.txt"; Languages: de; Flags: shellexec postinstall skipifsilent unchecked
Filename: {app}\{#MyAppExeName}; Description: {cm:LaunchProgram,{#MyAppName}}; Flags: nowait postinstall skipifsilent

[Types]
Name: custom; Description: cdrtfe Setup; Flags: iscustom

[Components]
; cdrtfe
Name: prog; Description: {cm:CompProg}; Flags: fixed; Types: custom
Name: prog\langsupport; Description: {cm:CompLang}; Flags: dontinheritcheck; Types: custom; Languages: en fr
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
fr.LangSuffix=Lang5
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
fr.CompLang=Multi language support (necessary for languages other than German)
fr.CompTools=Commandline tools
fr.CompM2CDMex=m2cdm (modified Mode2CDMaker)
fr.CompRrenc=additional XCD error protection
fr.CompXCD=XCD extraction tools (dat2file, d2fgui, M2F2Extract)
fr.CompAudio=MP3, OGG and FLAC support
fr.CompSrc={#MyAppVerName} source files
fr.TaskAllUsers=For all users
fr.TaskCurrentUser=For the current user only
fr.CygwinHeader=Cygwin
fr.CygwinHeader2=A cygwin1.dll has been found on your system.
fr.CygwinText=Which cygwin dll do you want to use?
fr.CygwinText2=Note: The files cygiconv-2.dll and cygintl-3.dll could not be found in the search path.
fr.CygwinText3=Warning: The file cygwin1.dll has been found in a Windows system folder. The use of the included DLL cannot be forced.
fr.CygwinOpt1=Use the already installed DLL to avoid version conflicts.
fr.CygwinOpt2=Use the included DLL.
fr.CygwinReadyHeader=Cygwin DLLs:
fr.CygwinReadyUsePrev=Using cygwin DLLs found in search path.
fr.CygwinReadyUseOwn=Using included cygwin DLLs.
fr.OldVersionError=An older version has been found. Please uninstall first.
fr.IconHelpFile=cdrtfe Help
fr.IconSourceFiles=Source files

