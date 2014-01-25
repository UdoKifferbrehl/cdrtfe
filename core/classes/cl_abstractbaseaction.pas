{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_abstractbaseaction.pas: abstrakte Basisklasse für Projekt

  Copyright (c) 2004-2014 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  25.01.2014

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_abstractbaseaction.pas implementiert abstrakte Basisklassen für die
  Ausführung eines Projektes

  TCdrtfeAction ist ein Objekt, das für die einzelnen Projekte die Zusammen-
  stellung der Kommandozeilen übernimmt und die Ausführung veranlaßt.


  TCdrtfeAction

    Properties   Data: TProjectData
                 Devices: TDevices
                 FormHandle: THandle
                 Lang: TLang
                 OnMessageShow: TMessageShowEvent
                 OnUpdatePanels: TUpdatePanelsEvent
                 ProgressBar: TProgressBar
                 Settings: TSettings
                 StatusBar: TStatusBar

    Methoden     AbortAction; virtual; abstract;
                 CleanUp(const Phase: Byte); virtual; abstract;
                 Reset; virtual; abstract;
                 StartAction; virtual; abstract;

}

unit cl_abstractbaseaction;

{$I directives.inc}

interface

uses Windows, Classes, ComCtrls, SysUtils, userevents, cl_projectdata,
     cl_settings, cl_devices, cl_diskinfo, cl_lang, cl_actionthread;

type TCdrtfeAction = class(TObject)
     private
     protected
       FActionThread  : TActionThread;
       {Ausgabe}
       FFormHandle    : THandle;
       FStatusBar     : TStatusBar;
       FProgressBar   : TProgressBar;
       FOnMessageShow : TMessageShowEvent;
       FOnUpdatePanels: TUpdatePanelsEvent;
       {Daten, Einstellungen}
       FData          : TProjectData;
       FDevices       : TDevices;
       FLang          : TLang;
       FSettings      : TSettings;
       FDisk          : TDiskInfo;
       function GetDriverOpts: string;
       function GetFormatCommand: string;
       function GetSectorNumber(const MkisofsOptions: string): string;
       function MakePathConform(const Path: string): string;
       function MakePathEntryMkisofsConform(const Path: string): string;
       procedure CheckSpaceForImage(var Ok: Boolean; const Path: string; const Sectors: Integer; Size: Int64);
       procedure SetFSettings(Value: TSettings); virtual;
       procedure SetPanels(const s1, s2: string);
       procedure MessageShow(const s: string);
       procedure UpdatePanels(const s1, s2: string);
     public
       function GetCommandLineString: string; virtual; abstract;
       procedure AbortAction; virtual;
       procedure CleanUp(const Phase: Byte); virtual; abstract;
       procedure Reset; virtual; abstract;
       procedure StartAction; virtual; abstract;
       {Ausgabe}
       property FormHandle: THandle write FFormHandle;
       property StatusBar: TStatusBar read FStatusBar write FStatusBar;
       property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
       property OnMessageShow: TMessageShowEvent read FOnMessageShow write FOnMessageShow;
       property OnUpdatePanels: TUpdatePanelsEvent read FOnUpdatePanels write FOnUpdatePanels;
       {Daten, Einstellungen}
       property Data: TProjectData write FData;
       property Devices: TDevices write FDevices;
       property Lang: TLang write FLang;
       property Settings: TSettings write SetFSettings;
       property DiskInfo: TDiskInfo write FDisk;
     end;

implementation

uses f_strings, f_getdosoutput, f_cygwin, f_filesystem, f_window, f_locations,
     const_locations, {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     const_common;

{ TCdrtfeAction -------------------------------------------------------------- }

{ TCdrtfeAction - private }

{ TCdrtfeAction - protected }

{ SetFSettings -----------------------------------------------------------------

  setzt die Eigenschaft Settings und die Feldvariable FDisk in Abhängigkeit der
  Daten in FSettings.                                                          }

procedure TCdrtfeAction.SetFSettings(Value: TSettings);
begin
  FSettings := Value;
end;

{ MessageShow ------------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TCdrtfeAction.MessageShow(const s: string);
begin
  if Assigned(FOnMessageShow) then FOnMessageShow(s);
end;

{ UpdatePanels -----------------------------------------------------------------

  Löst das Event OnUpdatePanels aus, das das Hauptfenster veranlaßt, die Panel-
  Texte der Statusleiste zu aktualisieren.                                     }

procedure TCdrtfeAction.UpdatePanels(const s1, s2: string);
begin
  if Assigned(FOnUpdatePanels) then FOnUpdatePanels(s1, s2);
end;

{ SetPanels --------------------------------------------------------------------

  SetPanels zeigt s1 und s2 in der Statusleiste an.                            }

procedure TCdrtfeAction.SetPanels(const s1, s2: string);
begin
  UpdatePanels(s1, s2);
end;

{ MakePathConform --------------------------------------------------------------

  Bei FSettings.FileFlags.Mingw = True ist der normale Windowspfad das Ergebnis,
  andernfalls wird das Ergebnis aus MakePathCygwinConform(Path) zurückgegeben. }

function TCdrtfeAction.MakePathConform(const Path: string): string;
begin
  if FSettings.FileFlags.Mingw then
  begin
    Result := Path;
  end else
  begin
    Result := MakePathCygwinConform(Path);
  end;
end;

{ MakePathEntryMkisofsConform --------------------------------------------------

  bereitet den Pfadlisten-Eintrag für mkisofs auf, wobei die Cygwin- und Mingw-
  Version unterschiedlich behandelt werden müssen.                             }

function TCdrtfeAction.MakePathEntryMkisofsConform(const Path: string): string;
begin
  if FSettings.FileFlags.Mingw then
  begin
    Result := MakePathMingwMkisofsConform(Path);
  end else
  begin
    Result := MakePathMkisofsConform(Path);
  end;
end;

{ CheckSpaceForImage -----------------------------------------------------------

  prüft, ob genügen Platz für die Image-Datei vorhanden ist.                   } 

procedure TCdrtfeAction.CheckSpaceForImage(var Ok: Boolean; const Path: string;
                                           const Sectors: Integer; Size: Int64);
var Temp, Drive: string;
    Sectors64  : Int64;
    SizeFree   : Int64;
begin
  if Ok then
  begin
    Drive := ExtractFileDrive(Path);
    SizeFree := GetFreeSpaceDisk(Drive);
    if Size = 0 then
    begin
      Sectors64 := Sectors;
      Size := (Sectors64 * 2048);
    end;
    Ok := Size < SizeFree;
    if not Ok then
    begin
      Temp := Format(FLang.GMS('eburn20'), [Drive]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
    end;
  end;
end;

{ GetSectorNumber --------------------------------------------------------------

  bestimmt die Länge des Datentracks in Sektoren. Nötig für DAO/RAW.           }

function TCdrtfeAction.GetSectorNumber(const MkisofsOptions: string): string;
var CmdGetSize: string;
    Sectors   : string;
    Temp      : string;
    Output    : TStringList;
    i         : Integer;
begin
  SetPanels('<>', FLang.GMS('mburn12'));
  Result := '';
  Output := TStringList.Create;
  CmdGetsize := StartUpDir + cMkisofsBin;
  CmdGetSize := QuotePath(CmdGetSize);
  CmdGetsize := CmdGetSize + ' -print-size -quiet' + MkisofsOptions;
  Output.Text := GetDosOutput(PChar(CmdGetsize), True, True);
  for i := 0 to Output.Count - 1 do
  begin
    Sectors := Trim(Output[i]);
    if StrToIntDef(Sectors, -1) >= 0 then Result := Sectors;
  end;
  {$IFDEF WriteLogfile}
  AddLog('Sectors: ' + Result, 0);
  {$ENDIF}
  if Result = '' then
  begin
    Temp := ExtractFileName(cMkisofsBin);
    MessageShow(Temp + ' -print-size failed.');
    MessageShow('  Commandline was: ' + CmdGetsize);
    for i := 0 to Output.Count - 1 do
    begin
      Sectors := Output[i];
      if Pos(Temp, Sectors) > 0 then
      begin
        Delete(Sectors, 1, Pos(':', Sectors));
        MessageShow('  Errormessage   : ' + Sectors);
      end;
    end;
  end;
  Output.Free;
  SetPanels ('<>', '');
end;

{ GetDriverOps -----------------------------------------------------------------

  liefert einen String mit den gesetzten Treiberoptionen.                      }

function TCdrtfeAction.GetDriverOpts: string;
var Temp: TStringList;
begin
  Temp := TStringList.Create;
  Result := '';
  with FSettings.Cdrecord do
  begin
    if Audiomaster then Temp.Add('audiomaster');
    if Burnfree then Temp.Add('burnfree');
    if CustDriverOpts <> '' then Temp.Add(CustDriverOpts);
  end;
  if Temp.Count > 0 then
  begin
    Result := ' driveropts=' + Temp.CommaText;
  end;
  Temp.Free;
end;

{ GetFormatCommand -------------------------------------------------------------

  liefert, falls nötig die Befehlszeile zum Formatieren einer DVD+RW.          }

function TCdrtfeAction.GetFormatCommand: string;
begin
  Result := '';
  if FSettings.Cdrecord.AllowFormat then
  begin
    if FDisk.ForcedFormat and not FSettings.Cdrecord.Dummy and
       not FSettings.Cdrecord.SimulDrv then
    begin
      Result := FDisk.FormatCommand + CR;
    end;
  end;
end;

{ TCdrtfeAction - public }

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCdrtfeAction.AbortAction;
begin
  if FActionThread <> nil then TerminateExecution(FActionThread);
end;

end.
