{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action_cdinfo.pas: Infos über Disks und Laufwerke

  Copyright (c) 2004-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  27.05.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action_cdinfo.pas implementiert das Objekt, das Infos über Laufwerke und
  Disks ausgibt.

  TCdrtfeActionCDInfo ist ein Objekt, das die Kommandozeilen für die Ausgabe von
  Disk- und Laufwerksinformationen erzeugt und ausführt.


  TCdrtfeActionCDInfo

    Properties   x

    Methoden     AbortAction
                 CleanUp(const Phase: Byte)
                 Reset
                 StartAction

}

unit cl_action_cdinfo;

{$I directives.inc}

interface

uses Windows, SysUtils, cl_actionthread, cl_abstractbaseaction;

type TCdrtfeActionCDInfo = class(TCdrtfeAction)
     private
       procedure GetCDInfos;
     protected
     public
       constructor Create;
       function GetCommandLineString: string; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Reset; override;
       procedure StartAction; override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}         
     f_strings, f_init, usermessages, f_locations, const_locations, f_helper;

{ TCdrtfeActionCDInfo -------------------------------------------------------- }

{ TCdrtfeActionCDInfo - private }

{ GetCDInfos -------------------------------------------------------------------

  Infos anzeigen: -scanbus, -prcap, -atip, -toc, -msinfo.                      }

procedure TCdrtfeActionCDInfo.GetCDInfos;
var Cmd : string;
    Temp: string;
    Ok  : Boolean;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  if not FSettings.CDInfo.CapInfo then
  begin
    Cmd := StartUpDir + cCdrecordBin;
    Cmd := QuotePath(Cmd);
    with FSettings.CDInfo do
    begin
      if MetaInfo then
      begin
        Cmd := StartUpDir + cIsoInfoBin;
        Cmd := QuotePath(Cmd);
        Cmd := Cmd + ' dev=' + SCSIIF(Device) + ' -d -debug';
      end else
      if Scanbus then
      begin
        if FSettings.Drives.UseRSCSI then
          Cmd := Cmd + ' dev=' + FSettings.Drives.RSCSIString;
        if SCSIIF('') <> '' then Cmd := Cmd + ' dev=' + SCSIIF('');
        Cmd := Cmd + ' -scanbus'
      end else
      begin
        Cmd := Cmd + ' dev=' + SCSIIF(Device);
        if Prcap  then Cmd := Cmd + ' -prcap'  else
        if Toc    then Cmd := Cmd + ' -toc'    else
        if Atip   then Cmd := Cmd + ' -atip'   else
        if MSInfo then Cmd := Cmd + ' -msinfo' else
        if MInfo  then Cmd := Cmd + ' -minfo';
      end;
      if FSettings.Cdrecord.Verbose and not MetaInfo then Cmd := Cmd + ' -v';      
    end;
    {Kommando ausführen}
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
    Ok := True;
    {Kapazitäten des Rohlings ausgeben:
     Infos über eingelegte CD einlesen}
    SetPanels('<>', FLang.GMS('mburn13'));
    FDisk.GetDiskInfo(FSettings.CDInfo.Device, True);
    SetPanels('<>', '');
    {keine CD}
    if (FDisk.Size = 0) and (FDisk.MsInfo = '') then
    begin
      MessageShow(FLang.GMS('eburn01'));
      Ok := False;
    end;
    {fixierte CD}
    if Pos('-1', FDisk.MsInfo) <> 0 then
    begin
      MessageShow(FLang.GMS('mburn09'));
      Ok := False;
    end;
    {Gesamtkapazität}
    if Ok then
    begin
      Temp := Format(FLang.GMS('mburn07'),
              [FormatFloat(' ##0.##', FDisk.Size),
               IntToStr(Round(Int(FDisk.Time)) div 60),
               FormatFloat('0#.##',
                         (FDisk.Time - (Round(Int(FDisk.Time)) div 60) * 60))]);
      MessageShow(Temp);
      {noch frei}
      Temp := Format(FLang.GMS('mburn08'),
              [FormatFloat(' ##0.##', FDisk.SizeFree),
               IntToStr(Round(Int(FDisk.TimeFree)) div 60),
               FormatFloat('0#.##',
                  (FDisk.TimeFree - (Round(Int(FDisk.TimeFree)) div 60) * 60))]);
      MessageShow(Temp);
    end;
    MessageShow('');
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ TCdrtfeActionCDInfo - protected }

{ TCdrtfeActionCDInfo - public }

constructor TCdrtfeActionCDinfo.Create;
begin
  inherited Create;
end;

{ GetCommandLineString ---------------------------------------------------------

  liefert die auszuführende(n) Kommandozeile(n).                               }

function TCdrtfeActionCDInfo.GetCommandLineString: string;
begin
  Result := '';
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCdrtfeActionCDInfo.CleanUp;
begin
  // wird hier nicht benötigt
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCdrtfeActionCDInfo.Reset;
begin
  // wird hier nicht benötigt
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCdrtfeActionCDInfo.StartAction;
begin
  GetCDInfos;
end;

end.
