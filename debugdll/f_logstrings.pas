{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  f_logstrings.pas: vordefinierte Strings

  Copyright (c) 2007-2009 Oliver Valencia

  letzte Änderung  08.12.2009

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_logstrings.pas stellt die vordefinierten Strings für das Log zur Verfügung
    *


  exportierte Funktionen/Prozeduren:

    x

}

unit f_logstrings;

interface

uses Classes;

var LogStrings: TStringList;

implementation

procedure InitLogStrings;
begin
  with LogStrings do
  begin
    {Application}
    Add('1000=Application.Initialize');
    Add('1001=Application.CreateForm1');
    Add('1002=Application.Run');
    {f_debug}
    Add('1010=f_debug initialization');
    Add('1011=f_debug finalization');
    {frm_main.pas}
    Add('1050=frm_main.pas initialization');
    Add('1051=TForm1.FormCreate');
    Add('1052=TForm1.FormDestroy');
    Add('1053=TForm1.FormShow');
    Add('1054=TForm1.FormActivate');
    Add('1055=TForm1.FormClose');
    Add('1056=frm_main.pas finalization');
    Add('1057=Received Message: WM_DriveSettings');
    Add('1058=UserOpenFile: Open audio or video track with special program.');
    Add('1059=UserOpenFile: Open file with standard program.');
    {f_process.pas/cl_actionthread.pas}
    Add('1100=GetDOSOutputEx:');
    Add('1101=Running commandline');
    Add('1102=Commandline executed');
    Add('1103=Commandline output:');
    Add('1104=Current Directory:');
    Add('1105=Terminating commandline processes');
    Add('1106=Sending Ctrl-c to processes');
    Add('1107=Killing process softly');
    Add('1108=Killing child processes');
    Add('1109=Calling ShellExecute:');
    {cl_devices.pas}
    Add('1200=Entering TDevices.DetectDrives -----------------------------------------------------------');
    Add('1201=Leaving TDevices.DetectDrives ------------------------------------------------------------');
    Add('1202=Device lists:');
    Add('1203=FLocalCDDevices:');
    Add('1204=FLocalCDWriter:');
    Add('1205=FLocalCDReader:');
    Add('1206=FLocalCDDriveLetter:');
    Add('1207=FLocalCDSpeedList:');
    Add('1208=FRemoteCDDevices:');
    Add('1209=FRemoteCDWriter:');
    Add('1210=FRemoteCDReader:');
    Add('1211=FRemoteCDDriveLetter:');
    Add('1212=FRemoteCDSpeedList:');
    Add('1213=Scanning Devices via SCSI Interface');
    Add('1214=DriveLetters according to cdrtfe.ini, [Drives], LocalDrives');
    Add('1215=Entering TDevices.GetDriveSpeeds ***********                                       -------');
    Add('1216=Leaving TDevices.GetDriveSpeeds ************                                       -------');
    Add('1217=Device can write discs, getting write speeds ...');
    Add('1218=No speed list, getting max. write speed ...');
    Add('1219=Getting read speeds ...');
    Add('1220=Entering TDevices.UpdateSpeedLists ***********                                     -------');
    Add('1221=Leaving TDevices.UpdateSpeedLists ************                                     -------');
    Add('1222=Rescanning SCSI bus');
    {f_init.pas, f_cygwin.pas}
    Add('1250=cygwin1.dll found in search path.');
    Add('1251=Using DLL from cdrtfe installation, setting PATH variable ...');
    Add('1252=Using file paths from cdrtfe_tools.ini.');
    Add('1253=Tool paths:');
    Add('1254=Using .mkisofsrc');
    Add('1255=Checking mkisofs imports');
    Add('1256=tools\cygwin\cygwin.ini found.');
    Add('1257=Ignore cygwin DLLs found in search path, use the included DLLs.');
    Add('1258=Use cygwin DLLs found in search path if possible.');
    Add('1259=cygwin1.dll not found in search path.');
    Add('1260=cygwin1.dll path:');
    Add('1261=An active cygwin1.dll has been found. Overriding path setting...');
    {cl_cueinfo.pas}
    Add('1270=Creating temporary cue file');
    {cl_settings.pas}
    Add('1300=Path to cdrtfe.ini');
    Add('1301=Portable Mode activated via cdrtfe.ini.');
    {cl_lang.pas}
    Add('1400=\translation\cdrtfe_lang.ini found.');
    Add('1401=\translation\<lang>\cdrtfe_lang.ini found.');
  end;
end;

initialization
  LogStrings := TStringList.Create;
  InitLogStrings;

finalization
  LogStrings.Free;

end.
