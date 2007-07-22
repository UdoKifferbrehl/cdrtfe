{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  f_logstrings.pas: vordefinierte Strings

  Copyright (c) 2007 Oliver Valencia

  letzte Änderung  22.07.2007

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
    {f_process.pas}
    Add('1100=GetDOSOutputEx:');
    Add('1101=Running commandline');
    Add('1102=Commandline executed');
    Add('1103=Commandline output:');
    {cl_devices.pas}
    Add('1200=Entering TDevices.DetectDrives -----------------------------------------------------------');
    Add('1201=Leaving TDevices.DetectDrives ------------------------------------------------------------');
    Add('1202=Device-Lists:');
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
    {f_init.pas}
    Add('1250=cygwin1.dll found in search path.');
    Add('1251=cygwin1.dll not found in search path, using DLL from cdrtfe installation');
    Add('1252=Using file paths from cdrtfe_tools.ini.');
    Add('1253=Tool paths:');
    {cl_cueinfo.pas}
    Add('1270=Creating temporary cue file');
  end;
end;

initialization
  LogStrings := TStringList.Create;
  InitLogStrings;

finalization
  LogStrings.Free;

end.
