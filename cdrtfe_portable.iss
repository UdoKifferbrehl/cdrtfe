; cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend
;
;  cdrtfe.iss: Inno-Setup-Skript für Inno Setup 5.8.8
;
;  Copyright (c) 2006-2016 Oliver Valencia
;
;  letzte Änderung  24.02.2016
;
;  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
;  GNU General Public License weitergeben und/oder modifizieren. Weitere
;  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.
;

#define MyAppName "cdrtools Frontend portable"
#define MyAppVer "1.5.5"
#define MyAppVerName "cdrtfe " + MyAppVer + " portable"
#define MyAppPublisher "Oliver Valencia"
#define MyAppURL "http://cdrtfe.sourceforge.net"
#define MyAppExeName "cdrtfe.exe"
#define MyAppCopyright "Copyright © 2002-2016  O. Valencia, O. Kutsche"

[Setup]
; Installer
AppName={#MyAppName}
AppVerName={#MyAppVerName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={src}\cdrtfe-{#MyAppVer}portable
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
MinVersion=5.1
;make it portable
CreateUninstallRegKey=no
Uninstallable=no
DisableWelcomePage=yes
DisableReadyPage=yes
DisableFinishedPage=yes
PrivilegesRequired=lowest
AlwaysShowComponentsList=no
; Compiler
VersionInfoVersion={#MyAppVer} 
VersionInfoCopyright={#MyAppCopyright}
OutputDir=i:\cdrtfe\proto2
OutputBaseFilename=cdrtfe-{#MyAppVer}portable
; Compression
Compression=lzma2
SolidCompression=yes
; Cosmetic
WizardSmallImageFile=I:\cdrtfe\setupscript\images\cdrtfe_inno_small.bmp
WizardImageFile=I:\cdrtfe\setupscript\images\cdrtfe_inno.bmp
WindowVisible=no
AppCopyright={#MyAppCopyright}
ShowUndisplayableLanguages=yes

[Tasks]


[Files]
Source: I:\cdrtfe\proto2\cdrtfe-{#MyAppVer}portable\*; DestDir: {app}; Flags: ignoreversion recursesubdirs;  


[Messages]
SelectDirDesc=Where should [name] be extracted?
SelectDirLabel3=Setup will extract [name] into the following folder.
SelectDirBrowseLabel=To continue, click Extract. If you would like to select a different folder, click Browse.
ButtonNext=&Extract
WizardInstalling=Extracting
InstallingLabel=Please wait while Setup extracts [name] on your computer.


[Icons]


[Registry]


[Run]


[UninstallDelete]


[UninstallRun]


[Types]


[Components]


[Code]


[CustomMessages]
