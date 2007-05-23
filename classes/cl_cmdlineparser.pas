{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cl_cmdlineparser.pas: Kommandozeilenparser

  Copyright (c) 2004-2007 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  23.05.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_cmdlineparser.pas implementiert das Objekt, das die Kommandozeilen-
  argumente auswertet und entsprechende Aktionen ausführt.


  TCommandlineParser

    Properties   Data
                 FormCaption
                 Settings

    Methoden     Clear
                 Create
                 ExecuteCommandLine
                 LastError
                 ParseCommandLine

}

unit cl_cmdlineparser;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils, Windows, Messages,
     cl_projectdata, cl_settings, cl_lang;

const CP_NoError = 0;          {Fehlercodes}
      CP_ProjectFileNotFound = 1;

type TCmdLineParser = class(TObject)
     private
       FData              : TProjectData;
       FSettings          : TSettings;
       FError             : Byte;
       FFormCaption       : string;
       FList              : TStringList;
       FListData          : TStringList;
       FListAudio         : TStringList;
       FListXCD           : TStringList;
       FListVCD           : TStringList;
       FDVDPath           : string;
       FImageFile         : string;
       FProjectFileToLoad : string;
       FLoadProject       : Boolean;
       FExecute           : Boolean;
       FExitAfterExec     : Boolean;
       FWriteLog          : Boolean;
       FNoCheck           : Boolean;
       FHide              : Boolean;
       FMinimize          : Boolean;
       FTabToActivate     : Byte;
       function GetLastError: Byte;
       procedure AddToList(const AddTo, FileName: string);
     public
       constructor Create;
       destructor Destroy; override;
       procedure Clear;
       procedure ExecuteCommandLine;
       procedure ParseCommandLine;
       property FormCaption: string write FFormCaption;
       property LastError: Byte read GetLastError;
       property Data: TProjectData write FData;
       property Settings: TSettings write FSettings;
     end;

implementation

uses constant, f_process, user_messages;

{ TCmdLineParser ------------------------------------------------------------- }

{ TCmdLineParser - private }

{ GetLastError -----------------------------------------------------------------

  GetLastError gibt den Fehlercode aus FError und setzt FError auf No_Error.   }

function TCmdLineParser.GetLastError: Byte;
begin
  Result := FError;
  FError := CP_NoError;
end;

{ AddToList --------------------------------------------------------------------

  AddToList fügt einen in der Kommandozeile gefundenen Dateinamen in eine der
  Liste der an cdrtfe zu übermittelnden Dateien an.                            }

procedure TCmdLineParser.AddToList(const AddTo, FileName: string);
begin
  if AddTo = '' then                      // für Dateinamen ohne Option
  begin
    FList.Add(FileName);
  end;
  if AddTo = 'data' then                  // /data
  begin
    FListData.Add(FileName);
  end;
  if AddTo = 'audio' then                 // /audio
  begin
    FListAudio.Add(FileName);
  end;
  if AddTo = 'xcd' then                   // /xcd
  begin
    FListXCD.Add(FileName);
  end;
  if AddTo = 'vcd' then                   // /vcd
  begin
    FListVCD.Add(FileName);
  end;
  if AddTo = 'img' then                   // /img
  begin
    FImageFile := FileName;
  end;
  if AddTo = 'dvd' then
  begin
    FDVDPath := FileName;
  end;
  if AddTo = 'load' then                  // Projekt-Datei
  begin
    FProjectFileToLoad := FileName;
  end;
end;

{ TCmdLineParser - public }

constructor TCmdLineParser.Create;
begin
  inherited Create;
  FList               := TStringList.Create;
  FListData           := TStringList.Create;
  FListAudio          := TStringList.Create;
  FListXCD            := TStringList.Create;
  FListVCD            := TStringList.Create;
  FDVDPath            := '';
  FImageFile          := '';
  FProjectFileToLoad  := '';
  FLoadProject        := False;
  FExecute            := False;
  FExitAfterExec      := False;
  FWriteLog           := False;
  FTabToActivate      := 0;
  FNoCheck            := False;
  FError              := CP_NoError;
end;

destructor TCmdLineParser.Destroy;
begin
  FList.Free;
  FListData.Free;
  FListAudio.Free;
  FListXCD.Free;
  FListVCD.Free;
  inherited Destroy;
end;

{ Clear ------------------------------------------------------------------------

  alle internen Variablen und Listen löschen.                                  }

procedure TCmdLineParser.Clear;
begin
  FList.Clear;
  FListData.Clear;
  FListAudio.Clear;
  FListXCD.Clear;
  FListVCD.Clear;
  FDVDPath            := '';
  FImageFile          := '';
  FProjectFileToLoad  := '';
  FLoadProject        := False;
  FExecute            := False;
  FHide               := False;
  FMinimize           := False;
end;

{ ParseCommandLine -------------------------------------------------------------

  ParseCommnadLine verarbeitet die Kommandozeile und speichert alle Infos in
  den internen Variablen und Listen.                                           }

procedure TCmdLineParser.ParseCommandLine;
var i: Integer;
    ListToAdd, ListPrev: string;
    Par, Temp: string;
begin
  Temp := '';
  ListToAdd := '';
  ListPrev := '';
  for i := 1 to ParamCount do
  begin
    Par := ParamStr(i);
    if Par[1] <> '/' then  // keine Option sondern Dateiname
    begin
      if Par[Length(Par)] = '\' then   // Pfade wie x:\ksds\ verhindern
      begin
        Delete(Par, Length(Par), 1);
      end;
      AddToList(ListToAdd, ExpandFileName(Par));
      if ListToAdd = 'load' then //ListPrev <> '' then
      begin
        ListToAdd := ListPrev;
        ListPrev := '';
      end;
    end else
    if (Par = '/data') or
       (Par = '/audio') or
       (Par = '/xcd') or
       (Par = '/vcd') then
    begin
      ListToAdd := Copy(Par, 2, Length(Par) - 1);
    end else
    if Par = '/load' then
    begin                       // sicherstellen, daß nach /load ein
      Temp := ParamStr(i + 1);  // Dateiname folgt
      if Temp <> '' then
      begin
        if Temp[1] <> '/' then
        begin
          ListPrev := ListToAdd;
          ListToAdd := 'load';
          // ListToAdd := Copy(Par, 2, Length(Par) - 1);
          FLoadProject := True;
        end;
      end;
    end else
    if Par = '/img' then
    begin                       // sicherstellen, daß nach /img ein
      Temp := ParamStr(i + 1);  // Dateiname folgt
      if Temp <> '' then
      begin
        if Temp[1] <> '/' then
        begin
          ListPrev := ListToAdd;
          ListToAdd := 'img';
          // ListToAdd := Copy(Par, 2, Length(Par) - 1);
          // FLoadProject := True;
        end;
      end;
    end else
    if Par = '/dvd' then
    begin                       // sicherstellen, daß nach /dvd ein
      Temp := ParamStr(i + 1);  // Ordnername folgt
      if Temp <> '' then
      begin
        if Temp[1] <> '/' then
        begin
          ListPrev := ListToAdd;
          ListToAdd := 'dvd';
          // ListToAdd := Copy(Par, 2, Length(Par) - 1);
          // FLoadProject := True;
        end;
      end;
    end else
    {Die Optionen /register und /unregister wurden gestrichen
    if Par = '/register' then
    begin
      ParsedCmdLine.RegisterShellEx := True;
      ParsedCmdLine.UnRegisterShellEx := False;
    end else
    if Par = '/unregister' then
    begin
      ParsedCmdLine.RegisterShellEx := False;
      ParsedCmdLine.UnRegisterShellEx := True;
    end else                                                 }
    if Par = '/execute' then
    begin
      FExecute := True;
    end;
    if Par = '/log' then
    begin
      FWriteLog := True;
    end;
    if Par = '/exit' then
    begin
      FExitAfterExec := True;
    end;
    if Par = '/nocheck' then
    begin
      FNoCheck := True;
    end;
    if Par = '/minimize' then
    begin
      FMinimize := True;
    end;
    if Par = '/hide' then
    begin
      FHide := True;
    end;
    if Par = '/portable' then
    begin
      {Ausnahme: Dieser Schalter muß sich sofort auswirken, da die entsprechende
       Einstellung schon benötigt wird, bevor ExecuteCommandLine ausgeführt
       wird.}
      FSettings.General.PortableMode := True;
    end;
  end;

  if ListToAdd = 'data' then
  begin
    FTabToActivate := cDataCD;
  end;
  if ListToAdd = 'audio' then
  begin
    FTabToActivate := cAudioCD;
  end;
  if ListToAdd = 'xcd' then
  begin
    FTabToActivate := cXCD;
  end;
  if ListToAdd = 'vcd' then
  begin
    FTabToActivate := cVideoCD;
  end;
  if ListToAdd = 'img' then
  begin
    FTabToActivate := cCDImage;
  end;
  if ListToAdd = 'dvd' then
  begin
    FTabToActivate := cDVDVideo;
  end;

  {/hide _und_ /minimize sind nicht erlaubt}
  if FHide and FMinimize then
  begin
    FHide := False;
    FMinimize := False;
  end;                           
  {Sonderfall /hide: Das entsprechende Flag muß schon nach dem Parsen zur Ver-
   fügung stehen.}
  if FHide and FExecute and FExitAfterExec then
  begin
    FSettings.CmdLineFlags.Hide := True;
  end;
end;

{ ExecuteCommandLine -----------------------------------------------------------

  ExecuteCommandLine verarbeitet die beim Start übergebenen Paramter. Sollte
  bereits eine Instanz des Programms aktiv sein, werden die Parameter an diese
  übergeben. Die zweite Instanz wird dann geschlossen.                         }

procedure TCmdLineParser.ExecuteCommandLine;
var i: integer;
    Instance: HWnd;
    aCopyData: TCopyDataStruct;
    pcBuffer: PChar;
    IsFirst: Boolean;
begin
  {Handle der vorigen Instanz holen: der Befehlsblock zur Erkennung der vorigen
  Instanz ist in die Funktion FirstInstance in Unit feprocs.pas gewandert.}
  IsFirst := IsFirstInstance(Instance, 'TForm1', FFormCaption);

  {diese Optionen nur, wenn die 1. Instanz startet}
  if IsFirst then
  begin
    {Laden einer Projekt-Datei}
    if FLoadProject then
    begin
      // FSettings.LoadFromFile(FProjectFileToLoad);
      FSettings.General.LastProject := FProjectFileToLoad;
      if not FileExists(FProjectFileToLoad) then
      begin
        FError := CP_ProjectFileNotFound;
        // 'Projekt-Datei nicht gefunden: '
        // Form1.Memo1.Lines.Add(Format(GMS('epref01'),
        //                             [ParsedCmdLine.ProjectFileToLoad]));
      end else
      begin
        {Projekt laden}
        FSettings.LoadFromFile(FProjectFileToLoad);
        FData.LoadFromFile(FProjectFileToLoad + '.files');
      end;
    end;
    {gestrichen ShellExtensions registrieren/löschen?
    if ParsedCmdLine.RegisterShellEx and not NoShellExtDll then
    begin
      RegisterShellExtensions('register');
    end;
    if ParsedCmdLine.UnRegisterShellEx then
    begin
      RegisterShellExtensions('unregister');
    end;                                             }
  end;

  {Dateien ohne Option hinzufügen}
  if FList.Count > 0 then
  begin
    for i := 0 to FList.Count -1 do
    begin
      pcBuffer := PChar(FList[i]);
      with aCopyData do
      begin
        dwData := 0;
        cbData := StrLen(pcBuffer) + 1;
        lpData := pcBuffer;
      end;
      SendMessage(Instance, WM_COPYDATA,
                            Longint(Application.Handle), Longint(@aCopyData));
    end;
    {Dateisystem prüfen}
    if not FNoCheck then
    begin
      SendMessage(Instance, WM_CheckDataFS, 0, 0);
    end;
  end;
  {Dateien mit /data hinzufügen}
  if FListData.Count > 0 then
  begin
    SendMessage(Instance, WM_ACTIVATEDATATAB, 0, 0);
    for i := 0 to FListData.Count -1 do
    begin
      pcBuffer := PChar(FListData[i]);
      with aCopyData do
      begin
        dwData := 0;
        cbData := StrLen(pcBuffer) + 1;
        lpData := pcBuffer;
      end;
      SendMessage(Instance, WM_COPYDATA,
                            Longint(Application.Handle), Longint(@aCopyData));
    end;
    {Dateisystem prüfen}
    if not FNoCheck then
    begin
      SendMessage(Instance, WM_CheckDataFS, 0, 0);
    end;
  end;
  {Dateien mit /audio hinzufügen}
  if FListAudio.Count > 0 then
  begin
    SendMessage(Instance, WM_ACTIVATEAUDIOTAB, 0, 0);
    for i := 0 to FListAudio.Count -1 do
    begin
      pcBuffer := PChar(FListAudio[i]);
      with aCopyData do
      begin
        dwData := 0;
        cbData := StrLen(pcBuffer) + 1;
        lpData := pcBuffer;
      end;
      SendMessage(Instance, WM_COPYDATA,
                            Longint(Application.Handle), Longint(@aCopyData));
    end;
  end;
  {Dateien mit /xcd}
  if FListXCD.Count > 0 then
  begin
    SendMessage(Instance, WM_ACTIVATEXCDTAB, 0, 0);
    for i := 0 to FListXCD.Count -1 do
    begin
      pcBuffer := PChar(FListXCD[i]);
      with aCopyData do
      begin
        dwData := 0;
        cbData := StrLen(pcBuffer) + 1;
        lpData := pcBuffer;
      end;
      SendMessage(Instance, WM_COPYDATA,
                            Longint(Application.Handle), Longint(@aCopyData));
    end;
  end;
  {Dateien mit /vcd}
  if FListVCD.Count > 0 then
  begin
    SendMessage(Instance, WM_ACTIVATEVCDTAB, 0, 0);
    for i := 0 to FListVCD.Count -1 do
    begin
      pcBuffer := PChar(FListVCD[i]);
      with aCopyData do
      begin
        dwData := 0;
        cbData := StrLen(pcBuffer) + 1;
        lpData := pcBuffer;
      end;
      SendMessage(Instance, WM_COPYDATA,
                            Longint(Application.Handle), Longint(@aCopyData));
    end;
  end;
  {Image-Datei mit /img}
  if FImageFile <> '' then
  begin
    SendMessage(Instance, WM_ACTIVATEIMGTAB, 0, 0);
    pcBuffer := PChar(FImageFile);
    with aCopyData do
    begin
      dwData := 0;
      cbData := StrLen(pcBuffer) + 1;
      lpData := pcBuffer;
    end;
    SendMessage(Instance, WM_COPYDATA,
                          Longint(Application.Handle), Longint(@aCopyData));
  end;
  {Video-DVD mit /dvd}
  if FDVDPath <> '' then
  begin
    SendMessage(Instance, WM_ACTIVATEDVDTAB, 0, 0);
    pcBuffer := PChar(FDVDPath);
    with aCopyData do
    begin
      dwData := 0;
      cbData := StrLen(pcBuffer) + 1;
      lpData := pcBuffer;
    end;
    SendMessage(Instance, WM_COPYDATA,
                          Longint(Application.Handle), Longint(@aCopyData));
  end;
  {update kilobyte/time display}
  SendMessage(Instance, WM_UPDATEGAUGES, 0, 0);
  {aktivate last TabSheet}
  case FTabToActivate of
    cDataCD  : SendMessage(Instance, WM_ACTIVATEDATATAB, 0, 0);
    cAudioCD : SendMessage(Instance, WM_ACTIVATEAUDIOTAB, 0, 0);
    cXCD     : SendMessage(Instance, WM_ACTIVATEXCDTAB, 0, 0);
    cVideoCD : SendMessage(Instance, WM_ACTIVATEVCDTAB, 0, 0);
    cCDImage : SendMessage(Instance, WM_ACTIVATEIMGTAB, 0, 0);
    cDVDVideo: SendMessage(Instance, WM_ACTIVATEDVDTAB, 0, 0);
  end;
  {automatisches Starten}
  if FExecute then
  begin
    if IsFirst then
    begin
      FSettings.CmdLineFlags.Minimize := FMinimize;
      FSettings.CmdLineFlags.Hide := FHide;
      FSettings.CmdLineFlags.ExecuteProject := FExecute;
      FSettings.CmdLineFlags.ExitAfterExecution := FExitAfterExec;
      FSettings.CmdLineFlags.WriteLogFile := FWriteLog;
    end else
    begin
      {Programm beenden nach Brennvorgang}
      if FExitAfterExec then
      begin
        SendMessage(Instance, WM_ExitAfterExec, 0, 0);
      end;
      {LogFile schreiben}
      if FWriteLog then
      begin
        SendMessage(Instance, WM_WriteLog, 0, 0);
      end;
      {Fenster zur Ausführung minimieren}
      if FMinimize then
      begin
        SendMessage(Instance, WM_Minimize, 0, 0);
      end;
      SendMessage(Instance, WM_EXECUTE, 0, 0);
    end;
  end;
  {die abgearbeiteten Kommandozeilenoptionen löschen}
  self.Clear;
  {if this was the second instance, exit this one and only leave the other
   one open}
  if not IsFirst then
  begin
    Application.Terminate;
  end;
end;

end.
