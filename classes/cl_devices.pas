{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cl_devices.pas: Laufwerkslisten, -erkennung

  Copyright (c) 2005-2006 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  23.06.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_devices.pas bietet den Zugriff auf die Laufwerkslisten.


  TDevices: Objekt, das die Laufwerkslisten enthält und für die Erkennung
             lokaler und entfernter Laufwerke zuständig ist.

    Properties   CDDevices
                 CDReader
                 CDWriter
                 LocalDrives
                 UseRSCSI
                 RemoteDrives
                 RSCSIHost

    Variablen    -

    Methoden     Create
                 DetectDrives
                 GetDriveLetter(const Dev: string): string

}

unit cl_devices;

{$I directives.inc}

interface

uses Classes, SysUtils;

type TDevices = class(TObject)
     private
       FLocalCDWriter      : TStringList;   // <vendor name>=h,t,l
       FLocalCDReader      : TStringList;
       FLocalCDDevices     : TStringList;
       FLocalCDDriveLetter : TStringList;   // <vendor name>=<drive>
       FLocalDrives        : string;
       FRemoteCDWriter     : TStringList;
       FRemoteCDReader     : TStringList;
       FRemoteCDDevices    : TStringList;
       FRemoteCDDriveLetter: TStringList;
       FRemoteDrives       : string;
       FRSCSIHost          : string;
       FUseRSCSI           : Boolean;
       function GetCDDevices: TStringList;
       function GetCDReader : TStringList;
       function GetCDWriter : TStringList;
       procedure DetectCDDrives(CDWriter, CDReader, CDDevices, CDDriveLetter: TStringList);
       {$IFDEF DebugDeviceList}
       procedure ShowDeviceLists;
       {$ENDIF}
       {$IFDEF WriteLogfile}
       procedure WriteLog;
       {$ENDIF}
     public
       constructor Create;
       destructor Destroy; override;
       function GetDriveLetter(const Dev: string): string;
       procedure DetectDrives;
       property CDDevices: TStringList read GetCDDevices;
       property CDReader : TStringList read GetCDReader;
       property CDWriter : TStringList read GetCDWriter;
       property LocalDrives: string read FLocalDrives write FLocalDrives;
       property RemoteDrives: string read FRemoteDrives write FRemoteDrives;
       property RSCSIHost: string read FRSCSIHost write FRSCSIHost;
       property UseRSCSI: Boolean read FUseRSCSI write FUseRSCSI;       
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     constant, f_filesystem, f_strings, f_process;

{ TDevices ------------------------------------------------------------------- }

{ TDevices - private }

{ ShowDeviceLists --------------------------------------------------------------

  alle internen Listen anzeigen.                                               }

{$IFDEF DebugDeviceList}
procedure TDevices.ShowDeviceLists;
var i: Integer;
begin
  Deb('FLocalCDDevices:', 1);
  for i := 0 to FLocalCDDevices.Count - 1 do Deb(FLocalCDDevices[i], 1);
  Deb(CRLF + 'FLocalCDWriter:', 1);
  for i := 0 to FLocalCDWriter.Count - 1 do Deb(FLocalCDWriter[i], 1);
  Deb(CRLF + 'FLocalCDReader:', 1);
  for i := 0 to FLocalCDReader.Count - 1 do Deb(FLocalCDReader[i], 1);
  Deb(CRLF + 'FLocalCDDriveLetter:', 1);
  for i := 0 to FLocalCDDriveLetter.Count - 1 do Deb(FLocalCDDriveLetter[i], 1);

  Deb(CRLF + CRLF + 'FRemoteCDDevices:', 1);
  for i := 0 to FRemoteCDDevices.Count - 1 do Deb(FRemoteCDDevices[i], 1);
  Deb(CRLF + 'FRemoteCDWriter:', 1);
  for i := 0 to FRemoteCDWriter.Count - 1 do Deb(FRemoteCDWriter[i], 1);
  Deb(CRLF + 'FRemoteCDReader:', 1);
  for i := 0 to FRemoteCDReader.Count - 1 do Deb(FRemoteCDReader[i], 1);
  Deb(CRLF + 'FRemoteCDDriveLetter:', 1);
  for i := 0 to FRemoteCDDriveLetter.Count - 1 do Deb(FRemoteCDDriveLetter[i], 1);
end;
{$ENDIF}

{ WriteLog ---------------------------------------------------------------------

  schreibt die Device-Listen in das Logfile.                                   }

{$IFDEF WriteLogfile}
procedure TDevices.WriteLog;
var i: Integer;
begin
  AddLog('Device-Lists:' + CRLF, 0);
  AddLog('FLocalCDDevices:', 0);
  for i := 0 to FLocalCDDevices.Count - 1 do AddLog('  ' + FLocalCDDevices[i], 0);
  AddLog(CRLF + 'FLocalCDWriter:', 0);
  for i := 0 to FLocalCDWriter.Count - 1 do AddLog('  ' + FLocalCDWriter[i], 0);
  AddLog(CRLF + 'FLocalCDReader:', 0);
  for i := 0 to FLocalCDReader.Count - 1 do AddLog('  ' + FLocalCDReader[i], 0);
  AddLog(CRLF + 'FLocalCDDriveLetter:', 0);
  for i := 0 to FLocalCDDriveLetter.Count - 1 do AddLog('  ' + FLocalCDDriveLetter[i], 0);

  AddLog(CRLF + CRLF + 'FRemoteCDDevices:', 0);
  for i := 0 to FRemoteCDDevices.Count - 1 do AddLog('  ' + FRemoteCDDevices[i], 0);
  AddLog(CRLF + 'FRemoteCDWriter:', 0);
  for i := 0 to FRemoteCDWriter.Count - 1 do AddLog('  ' + FRemoteCDWriter[i], 0);
  AddLog(CRLF + 'FRemoteCDReader:', 0);
  for i := 0 to FRemoteCDReader.Count - 1 do AddLog('  ' + FRemoteCDReader[i], 0);
  AddLog(CRLF + 'FRemoteCDDriveLetter:', 0);
  for i := 0 to FRemoteCDDriveLetter.Count - 1 do AddLog('  ' + FRemoteCDDriveLetter[i], 0);
  AddLog(CRLF + CRLF, 0);
end;
{$ENDIF}

{ GetCD[Devices|Reader|Writer] -------------------------------------------------

  Diese Funktionen geben eine Referenz auf die jeweilige Device-Liste zurück.  }

function TDevices.GetCDDevices: TStringList;
begin
  Result := nil;
  case FUseRSCSI of
    False: Result := FLocalCDDevices;
    True : Result := FRemoteCDDevices;
  end;
end;

function TDevices.GetCDReader: TStringList;
begin
  Result := nil;
  case FUseRSCSI of
    False: Result := FLocalCDReader;
    True : Result := FRemoteCDReader;
  end;
end;

function TDevices.GetCDWriter: TStringList;
begin
  Result := nil;
  case FUseRSCSI of
    False: Result := FLocalCDWriter;
    True : Result := FRemoteCDWriter;
  end;
end;

{ DetectCDDrives ---------------------------------------------------------------

  DetectCDDrives sucht alle vorhandenen CD-Laufwerke und die dazugehörigen
  Device-IDs. Die Prozedur erhält als Argumente Referenzen auf String-Listen,
  in denen die Laufwerks-IDs und die Bezeichnungen gespeichert werden.         }

procedure TDevices.DetectCDDrives(CDWriter, CDReader, CDDevices, CDDriveLetter:
                                  TStringList);
var CommandLine        : string;
    SearchString       : string;
    Dev, DevName       : string;
    IsWriter           : Boolean;
    Output, DeviceList : TStringList;
    DriveLetters       : TStringList;
    i                  : Integer;

  function GetDeviceName(s: string): string;
  var p         : Integer;
      DeviceName: string;
      Delimiter : Char;
  begin
    Delimiter := Chr(39);
    p := Pos(Delimiter, s);
    Delete(s, 1, p);
    p := Pos(Delimiter, s);
    DeviceName := Trim(Copy(s, 1, p - 1));
    Delete(s, 1, p);
    p := Pos(Delimiter, s);
    Delete(s, 1, p);
    p := Pos(Delimiter, s);
    DeviceName := DeviceName + ' ' + Trim(Copy(s, 1, p - 1));
    Result := DeviceName;
  end;

begin
  DriveLetters := TStringList.Create;
  if FUseRSCSI then DriveLetters.CommaText := FRemoteDrives
               else DriveLetters.CommaText := FLocalDrives;
  {alle CD-Laufwerke finden}
  SearchString := 'CD-ROM';
  Output := TStringList.Create;
  CommandLine := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  CommandLine := QuotePath(CommandLine);
  {$ENDIF}
  if FUseRSCSI then CommandLine := CommandLine + ' dev=' + FRSCSIHost;
  CommandLine := CommandLine + ' -scanbus';
  Output.Text := GetDOSOutput(PChar(CommandLine), True);
  {$IFDEF DebugDriveDetection}
  Deb(CommandLine, 2);
  {$ENDIF}
  for i := (Output.Count - 1) downto 0 do
  begin
    if Pos(SearchString, Output.Strings[i]) = 0 then
    begin
      Output.Delete(i);
    end else
    begin
      Output.Strings[i] := TrimLeft(Output.Strings[i]);
    end;
  end;
  DeviceList := TStringList.Create;
  DeviceList.Text := Output.Text;
  {$IFDEF UseDummyDevices}
  if FUseRSCSI then DeviceList.Text := '0,0,0     0) ''SONY    '' ''CD-RW  ' +
    'CRX100E  '' ''1.0j'' Removable CD-ROM';
  {$ENDIF}
  {$IFDEF NoDevice}
  DeviceList.Clear;
  {$ENDIF}
  {Brenner und Lesegeräte unterscheiden}
  SearchString := 'Does write CD-R media';
  for i := 0 to (DeviceList.Count - 1) do
  begin
    {SCSI-ID extrahieren}
    Dev := Copy(DeviceList.Strings[i], 0, 5);
    if FUseRSCSI  then Dev := FRSCSIHost + Dev;
    CommandLine := StartUpDir + cCdrecordBin;
    {$IFDEF QuoteCommandlinePath}
    CommandLine := QuotePath(CommandLine);
    {$ENDIF}
    CommandLine := CommandLine + ' dev=' + Dev + ' -prcap';
    Output.Clear;
    Output.Text := GetDOSOutput(PChar(CommandLine), True);
    {$IFDEF DebugDriveDetection}
    Deb(CommandLine, 2);
    {$ENDIF}
    IsWriter := False;
    {$IFDEF UseDummyDevices}
    if FUseRSCSI then IsWriter:=true;
    {$ENDIF}
    {Nur wenn die Ausgabe von cdrecord -prcap 'Does write CD-R media' enthält,
     ist das Gerät ein Brenner. Damit werden virtuelle Laufwerke als normale
     CD-ROM-Laufwerke behandelt.}
    if Pos(SearchString, Output.Text) > 0 then
    begin
      IsWriter := True;
    end;
    DevName := GetDeviceName(DeviceList[i]);
    if FUseRSCSI then DevName := DevName + ' (r)';
                {else DevName := DevName + ' (local)';}
    CDDevices.Add(DevName + '=' + Dev);
    if IsWriter then
    begin
      CDWriter.Add(DevName + '=' + Dev);
    end else
    begin
      CDReader.Add(DevName + '=' + Dev);
    end;
    if Assigned(CDDriveLetter) then
    begin
      if i < DriveLetters.Count then
        CDDriveLetter.Add(Dev + '=' + DriveLetters[i]);
    end;
  end;
  Output.Free;
  DeviceList.Free;
  DriveLetters.Free;
  { Beispiel für den Zugriff auf die Devicedaten:
    CDReader.Names[i]    : Gerätenamen
    CDReader.Values[name]: Device-ID, name ist CDReader.Name[i]
      s := 'dev='+CDReader.Values[CDReader.Names[i]]+': '+CDReader.Names[i];  }
  { Sollten keine Laufwerke gefunden werden, Listen mit Dummyeinträgen füllen
    Flag setzten.}
  if CDWriter.Count = 0 then
  begin
    CDWriter.Add('');
  end;
  if CDReader.Count = 0 then
  begin
    CDReader.Add('');
  end;
  if CDDevices.Count = 0 then
  begin
    CDDevices.Add('');
  end;
  {$IFDEF UseDummyDevices}
  if (CDDevices.Count = 1) and (CDDevices[0] = '') then
  begin
    CDWriter.Clear;
    CDReader.Clear;
    CDDevices.Clear;
  end;
  if FUseRSCSI then Dev := FRSCSIHost else Dev := '';
  CDDevices.Add('dummyw 0=' + Dev + '2,0,0');
  CDDevices.Add('dummyw 1=' + Dev + '2,0,1');
  CDDevices.Add('dummyw 2=' + Dev + '2,0,2');
  CDDevices.Add('dummyr 0=' + Dev + '2,0,3');
  CDDevices.Add('dummyr 1=' + Dev + '2,0,4');
  CDDevices.Add('dummyr 2=' + Dev + '2,0,5');
  CDWriter.Add('dummyw 0=' + Dev + '2,0,0');
  CDWriter.Add('dummyw 1=' + Dev + '2,0,1');
  CDWriter.Add('dummyw 2=' + Dev + '2,0,2');
  CDReader.Add('dummyr 0=' + Dev + '2,0,3');
  CDReader.Add('dummyr 1=' + Dev + '2,0,4');
  CDReader.Add('dummyr 2=' + Dev + '2,0,5');
  {$ENDIF}
end;

{ TDevices - public }

{ GetDriveLetter ---------------------------------------------------------------

  GetDriveLetter ermittelt aus einer SCSI-ID den zugehörigen Windows-Laufwerks-
  namen (<drive>:\).                                                           }

function TDevices.GetDriveLetter(const Dev: string): string;
begin
  Result := '';
  if Pos('REMOTE', Dev) > 0 then
  begin
    Result := FRemoteCDDriveLetter.Values[Dev];
  end else
  begin
    Result := FLocalCDDriveLetter.Values[Dev];
  end;
  if Result <> '' then Result := Result + ':\';
end;

{ DetectDrives -----------------------------------------------------------------

  DetectDrives sucht verfügbare CD-Laufwerke.                                  }

procedure TDevices.DetectDrives;
begin
  case FUseRSCSI of
    False: DetectCDDrives(FLocalCDWriter, FLocalCDReader, FLocalCDDevices,
                          FLocalCDDriveLetter);
    True : DetectCDDrives(FRemoteCDWriter, FRemoteCDReader, FRemoteCDDevices,
                          FRemoteCDDriveLetter);
  end;
  {$IFDEF DebugDeviceList}
  ShowDeviceLists;
  {$ENDIF}
  {$IFDEF WriteLogfile}
  WriteLog;
  {$ENDIF}
end;

constructor TDevices.Create;
begin
  inherited Create;
  FLocalCDWriter       := TStringList.Create;
  FLocalCDReader       := TStringList.Create;
  FLocalCDDevices      := TStringList.Create;
  FLocalCDDriveLetter  := TSTringList.Create;
  FLocalDrives         := '';
  FRemoteCDWriter      := TStringList.Create;
  FRemoteCDReader      := TStringList.Create;
  FRemoteCDDevices     := TStringList.Create;
  FRemoteCDDriveLetter := TStringList.Create;
  FRemoteDrives        := '';
  FRSCSIHost           := '';
  FUseRSCSI            := False;
end;

destructor TDevices.Destroy;
begin
  FLocalCDWriter.Free;
  FLocalCDReader.Free;
  FLocalCDDevices.Free;
  FLocalCDDriveLetter.Free;
  FRemoteCDWriter.Free;
  FRemoteCDReader.Free;
  FRemoteCDDevices.Free;
  FRemoteCDDriveLetter.Free;
  inherited Destroy;
end;

end.
