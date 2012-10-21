{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_devices.pas: Laufwerkslisten, -erkennung

  Copyright (c) 2005-2012 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  20.10.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_devices.pas bietet den Zugriff auf die Laufwerkslisten.


  TDevices: Objekt, das die Laufwerkslisten enthält und für die Erkennung
            lokaler und entfernter Laufwerke zuständig ist.

    Properties   CDDevices
                 CDReader
                 CDWriter
                 CDWriterCount
                 LocalDrives
                 UseRSCSI
                 RemoteDrives
                 RSCSIHost
                 Lang

    Variablen    -

    Methoden     Create
                 DetectDrives
                 GetDriveLetter(const Dev: string): string
                 Rescan
                 SetDummyDevices
                 UpdateSpeedLists(const Drive: string);


  TFormSelectWriter: Form Zur Auswahl der zu nutzenden Brenner

    Properties   -

    Variablen    -

    Methoden

}

unit cl_devices;

{$I directives.inc}

interface

uses Classes, SysUtils, Forms, StdCtrls, Controls, ComCtrls, cl_lang,
     c_frametopbanner, cl_imagelists;

type TDevices = class(TObject)
     private
       FLocalCDWriter      : TStringList;   // <vendor name>=h,t,l
       FLocalCDReader      : TStringList;
       FLocalCDDevices     : TStringList;
       FLocalCDDriveLetter : TStringList;   // h,t,l=<drive>
       FLocalCDSpeedList   : TStringList;   // <vendor name>[R|W]=speedlist
       FLocalDrives        : string;
       FRemoteCDWriter     : TStringList;
       FRemoteCDReader     : TStringList;
       FRemoteCDDevices    : TStringList;
       FRemoteCDDriveLetter: TStringList;
       FRemoteCDSpeedList  : TStringList;
       FRemoteDrives       : string;
       FRSCSIHost          : string;
       FUseRSCSI           : Boolean;
       FAssignManually     : Boolean;
       FForcedInterface    : string;
       FAllowMultipleWriter: Boolean;
       FMultipleWriterName : string;
       FCDWriterCount      : Integer;
       function GetCDDevices    : TStringList;
       function GetCDReader     : TStringList;
       function GetCDWriter     : TStringList;
       function GetCDDriveLetter: TStringList;
       function GetCDSpeedList  : TStringList;
       procedure AssignDriveLetters;
       procedure ClearLists;
       procedure DetectCDDrives(CDWriter, CDReader, CDDevices, CDDriveLetter, CDSpeedList: TStringList);
       procedure GetDriveSpeeds(PrcapInfo, CDSpeedList: TStringList; Dev, DevName: string; IsWriter: Boolean);
       procedure SetAllowMultipleWriter(Value: Boolean);
       {$IFDEF WriteLogfile}
       procedure WriteLog;
       {$ENDIF}
     public
       constructor Create;
       destructor Destroy; override;
       function GetDriveLetter(const Dev: string): string;
       procedure DetectDrives;
       procedure Rescan;
       procedure SetDummyDevices;
       procedure UpdateSpeedLists(const Drive: string);
       property CDDevices    : TStringList read GetCDDevices;
       property CDReader     : TStringList read GetCDReader;
       property CDWriter     : TStringList read GetCDWriter;
       property CDDriveLetter: TStringList read GetCDDriveLetter;
       property CDSpeedList  : TStringList read GetCDSpeedList;
       property LocalDrives: string read FLocalDrives write FLocalDrives;
       property RemoteDrives: string read FRemoteDrives write FRemoteDrives;
       property RSCSIHost: string read FRSCSIHost write FRSCSIHost;
       property UseRSCSI: Boolean read FUseRSCSI write FUseRSCSI;
       property AssignManually: Boolean read FAssignManually write FAssignManually;
       property ForcedInterface: string read FForcedInterface write FForcedInterface;
       property MultipleWriterName: string read FMultipleWriterName write FMultipleWriterName;
       property AllowMultipleWriter: Boolean read FAllowMultipleWriter write SetAllowMultipleWriter;
       property CDWriterCount: Integer read FCDWriterCount;
     end;

     TFormSelectWriter = class(TForm)
       StaticText  : TStaticText;
       ComboBox    : TComboBox;
       ListView    : TListView;
       ButtonOk    : TButton;
       ButtonCancel: TButton;
       FrameTopBanner1: TFrameTopBanner;
       procedure FormShow(Sender: TObject);
       procedure ButtonClick(Sender: TObject);
       procedure ButtonCancelClick(Sender: TObject);
       procedure FormDestroy(Sender: TObject);
     private
       FLang       : TLang;
       FImageLists : TImageLists;
       FCDWriter   : TStringList;
       FSelDevices : string;
     public
       procedure Init;
       property Lang           : TLang write FLang;
       property ImageLists     : TImageLists write FImageLists;
       property CDWriter       : TStringList write FCDWriter;
       property SelectedDevices: string read FSelDevices;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     cl_cdrtfedata, cl_deviceenum, const_common, f_locations, const_locations,
     f_filesystem, f_strings, f_Stringlist, f_getdosoutput, f_helper,
     f_dischelper, f_window;

const DefaultSpeedList : string
                         = ',0,1,2,4,6,8,10,12,16,20,24,32,36,40,42,48,50,52';

{ TDevices ------------------------------------------------------------------- }

{ TDevices - private }

{ WriteLog ---------------------------------------------------------------------

  schreibt die Device-Listen in das Logfile.                                   }

{$IFDEF WriteLogfile}
procedure TDevices.WriteLog;
begin
  AddLogCode(1202);
  AddLogcode(1203);
  AddLog(FLocalCDDevices.Text, 13);
  AddLogCode(1204);
  AddLog(FLocalCDWriter.Text, 13);
  AddLogCode(1205);
  AddLog(FLocalCDReader.Text, 13);
  AddLogCode(1206);
  AddLog(FLocalCDDriveLetter.Text, 13);
  AddLogCode(1207);
  AddLog(FLocalCDSpeedList.Text, 13);
  AddLogCode(1208);
  AddLog(FRemoteCDDevices.Text, 13);
  AddLogCode(1209);
  AddLog(FRemoteCDWriter.Text, 13);
  AddLogCode(1210);
  AddLog(FRemoteCDReader.Text, 13);
  AddLogCode(1211);
  AddLog(FRemoteCDDriveLetter.Text, 13);
  AddLogCode(1212);
  AddLog(FRemoteCDSpeedList.Text, 13);
end;
{$ENDIF}

{ GetCD[Devices|Reader|Writer|DriveLetterSpeedList] ----------------------------

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

function TDevices.GetCDDriveLetter: TStringList;
begin
  Result := nil;
  case FUseRSCSI of
    False: Result := FLocalCDDriveLetter;
    True : Result := FRemoteCDDriveLetter;
  end;
end;

function TDevices.GetCDSpeedList: TStringList;
begin
  Result := nil;
  case FUseRSCSI of
    False: Result := FLocalCDSpeedList;
    True : Result := FRemoteCDSpeedList;
  end;
end;

{ ClearLists -------------------------------------------------------------------

  löscht die Listen vor einem Rescan.                                          }

procedure TDevices.ClearLists;
begin
  FLocalCDWriter.Clear;
  FLocalCDReader.Clear;
  FLocalCDDevices.Clear;
  FLocalCDDriveLetter.Clear;
  FLocalCDSpeedList.Clear;
  FRemoteCDWriter.Clear;
  FRemoteCDReader.Clear;
  FRemoteCDDevices.Clear;
  FRemoteCDDriveLetter.Clear;
  FRemoteCDSpeedList.Clear;
end;

{ GetDriveSpeeds ---------------------------------------------------------------

  GetDriveSpeeds ermittelt die verfügbaren Geschwindigkeiten.                  }

procedure TDevices.GetDriveSpeeds(PrcapInfo, CDSpeedList: TStringList;
                                  Dev, DevName: string; IsWriter: Boolean);
const StdSpeed : string = ',0';
var i, p         : Integer;
    Offset       : Integer;
    SpeedCount   : Integer;
    DVD          : Boolean;
    Temp         : string;
    CDSpeeds,
    DVDSpeeds    : string;
    MaxCD, MaxDVD: string;
begin
  {$IFDEF WriteLogfile}
  AddLogCode(1215);
  SpeedCount := 0;
  {$ENDIF}
  CDSpeeds  := StdSpeed;
  DVDSpeeds := StdSpeed;
  {CD oder DVD?}
  DVD := DiskIsDVD(Dev);
  {Schreibgeschwindigkeiten}
  if IsWriter then
  begin
    {$IFDEF WriteLogfile}
    AddLogCode(1217);
    {$ENDIF}
    Offset := -1;
    repeat
      Inc(Offset);
      p := Pos('speeds: ', PrcapInfo[Offset]);
    until (p > 0) or (Offset = PrcapInfo.Count - 1);
    if p > 0 then
    begin
      Temp := PrcapInfo[Offset];
      Delete(Temp, 1, LastDelimiter(' ', Temp));
      SpeedCount := StrToIntDef(Trim(Temp), 0);
      for i := SpeedCount downto 1 do
      begin
        CDSpeeds  := CDSpeeds  + ',' + Trim(Copy(PrcapInfo[Offset + i], 45, 2));
        DVDSpeeds := DVDSpeeds + ',' + Trim(Copy(PrcapInfo[Offset + i], 54, 2));
      end;
    end else
    begin
      {$IFDEF WriteLogFile}
      AddLogCode(1218);
      {$ENDIF}
      Offset := -1;
      repeat
        Inc(Offset);
        p := Pos('Maximum write speed', PrcapInfo[Offset]);
      until (p > 0) or (Offset = PrcapInfo.Count - 1);
      if p > 0 then
      begin
        MaxCD  := Trim(Copy(PrcapInfo[Offset], 40, 2));
        MaxDVD := Trim(Copy(PrcapInfo[Offset], 49, 2));
        CDSpeeds := DefaultSpeedList;
        DVDSpeeds := DefaultSpeedList;
        p := Pos(MaxCD, CDSpeeds);
        if p > 0 then CDSpeeds := Copy(CDSpeeds, 1, p + Length(MaxCD) - 1);
        p := Pos(MaxDVD, DVDSpeeds);
        if p > 0 then DVDSpeeds := Copy(DVDSpeeds, 1, p + Length(MaxDVD) - 1);
      end;
    end;
    if DVD then CDSpeedList.Add(DevName + '[W]=' + DVDSpeeds) else
                CDSpeedList.Add(DevName + '[W]=' + CDSpeeds);
    {$IFDEF WriteLogfile}
    AddLog('    Number of write speeds: ' + IntToStr(SpeedCount), 2);
    AddLog('    MaxCDSpeed            : ' + MaxCD, 2);
    AddLog('    MaxDVDSpeed           : ' + MaxDVD, 2);
    AddLog('    CDSpeeds              : ' + CDSpeeds, 2);
    AddLog('    DVDSpeeds             : ' + DVDSpeeds, 2);
    AddLog('', 2);
    {$ENDIF}
  end;

  {Lesegeschwindigkeiten}
  {$IFDEF WriteLogfile}
  AddLogCode(1219);
  {$ENDIF}
  Offset := -1;
  repeat
    Inc(Offset);
    p := Pos('Maximum read  speed', PrcapInfo[Offset]);
  until (p > 0) or (Offset = PrcapInfo.Count - 1);
  if p > 0 then
  begin
    MaxCD  := Trim(Copy(PrcapInfo[Offset], 40, 2));
    MaxDVD := Trim(Copy(PrcapInfo[Offset], 49, 2));
    CDSpeeds := DefaultSpeedList;
    DVDSpeeds := DefaultSpeedList;
    p := Pos(MaxCD, CDSpeeds);
    if p > 0 then CDSpeeds := Copy(CDSpeeds, 1, p + Length(MaxCD) - 1);
    p := Pos(MaxDVD, DVDSpeeds);
    if p > 0 then DVDSpeeds := Copy(DVDSpeeds, 1, p + Length(MaxDVD) - 1);
  end;
  if DVD then CDSpeedList.Add(DevName + '[R]=' + DVDSpeeds) else
              CDSpeedList.Add(DevName + '[R]=' + CDSpeeds);
  {$IFDEF WriteLogfile}
  AddLog('    MaxCDSpeed            : ' + MaxCD, 2);
  AddLog('    MaxDVDSpeed           : ' + MaxDVD, 2);
  AddLog('    CDSpeeds              : ' + CDSpeeds, 2);
  AddLog('    DVDSpeeds             : ' + DVDSpeeds, 2);
  AddLog(CRLF, 2);
  if DVD then AddLog('    Using DVDSpeeds.', 2) else
              AddLog('    Using CDSpeeds.', 2);
  AddLog(CRLF, 2);
  AddLogCode(1216);
  {$ENDIF}
end;

{ AssignDriveLetters -----------------------------------------------------------

  Diese Prozedur ordnet jedem durch cdrecord gefundenen Laufwerk den Windows-
  Laufwerksbuchstaben zu. Zunächst wird versucht, dies durch einen eigenen
  Scan-Lauf zu erledigen.
    FAssignManually = 1   ->  nur Zuweisungen laut LocalDrives
    FAssignManually = 0   ->  Zuweisungen laut Scan, es sei denn es gibt in
                              LocalDrives einen Buchstaben für das Laufwerk
    FAssignManually = 0 &
    LocalDrives lees      ->  nur Zuweisungen laut Scan                        }

procedure TDevices.AssignDriveLetters;
var SCSIDevices: TSCSIDevices;
    i          : Integer;
    Found      : Boolean;
    DeviceID   : string;
    DriveLetter: string;
    Temp       : string;
begin
  {$IFDEF WriteLogFile}
  AddLogCode(1214);
  AddLog(FLocalCDDriveLetter.Text + CRLF, 3);
  AddLogCode(1213);
  {$ENDIF}
  SCSIDevices := TSCSIDevices.Create;
  if FForcedInterface = 'ASPI' then SCSIDevices.ForcedLayer := L_ASPI else
  if FForcedInterface = 'SPTI' then SCSIDevices.ForcedLayer := L_SPTI else
                                    SCSIDevices.ForcedLayer := L_Undef;
  SCSIDevices.Init;
  SCSIDevices.Scanbus;
  {$IFDEF WriteLogFile}
  AddLogCode(1202);
  AddLog(SCSIDevices.Log.Text, 3);
  AddLog(SCSIDevices.DeviceIDList.Text + CRLF +
         SCSIDevices.DeviceList.Text + CRLF +
         SCSIDevices.DeviceListNoID.Text + CRLF, 3);
  {$ENDIF}
  {Zuweisungen der Buchstaben}
  for i := 0 to FLocalCDDevices.Count - 1 do
  begin
    DeviceID := FLocalCDDevices[i];
    Delete(DeviceID, 1, LastDelimiter('=', DeviceID));
    {Ist diese DeviceID schon vorhanden? Wenn ja, vorhanden DriveLetter holen.}
    Found := Pos(DeviceID, FLocalCDDriveLetter.Text) > 0;
    if Found then Temp := FLocalCDDriveLetter.Values[DeviceID];
    {neuen DriveLetter laut SCSI-Scan holen}
    DriveLetter := SCSIDevices.DeviceIDList.Values[DeviceID];
    {Wenn es keinen DriveLetter nach ID gibt, dann nach Namen suchen (USB-LW).
     Dieser Workaround funktioniert nur, wenn die Laufwerke ohne ID unter-
     schiedliche Name haben!}
    if DriveLetter = '' then DriveLetter :=
      SCSIDevices.DeviceListNoID.Values[(FLocalCDDevices.Names[i])];
    {DriveLetter ersetzen bzw. hinzufügen}
    if Found then
    begin
      if not FAssignManually and (Temp = '') then
        FLocalCDDriveLetter.Values[DeviceID] := LowerCase(DriveLetter);
    end else
    begin
      FLocalCDDriveLetter.Add(DeviceID + '=' + LowerCase(DriveLetter));
    end;
  end;
  SCSIDevices.Free;
end;

{ DetectCDDrives ---------------------------------------------------------------

  DetectCDDrives sucht alle vorhandenen CD-Laufwerke und die dazugehörigen
  Device-IDs. Die Prozedur erhält als Argumente Referenzen auf String-Listen,
  in denen die Laufwerks-IDs und die Bezeichnungen gespeichert werden.         }

procedure TDevices.DetectCDDrives(CDWriter, CDReader, CDDevices, CDDriveLetter,
                                  CDSpeedList: TStringList);
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
  CommandLine := QuotePath(CommandLine);
  if FUseRSCSI then CommandLine := CommandLine + ' dev=' + FRSCSIHost;
  if SCSIIF('') <> '' then CommandLine := CommandLine + ' dev=' + SCSIIF('');
  CommandLine := CommandLine + ' -scanbus';
  Output.Text := GetDOSOutput(PChar(CommandLine), True, True);
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
    Dev := Copy(DeviceList.Strings[i], 0, Pos(#9, DeviceList.Strings[i]) - 1);
    if FUseRSCSI  then Dev := FRSCSIHost + Dev;
    CommandLine := StartUpDir + cCdrecordBin;
    CommandLine := QuotePath(CommandLine);
    CommandLine := CommandLine + ' dev=' + SCSIIF(Dev) + ' -prcap';
    Output.Clear;
    Output.Text := GetDOSOutput(PChar(CommandLine), True, True);
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
    if not FUseRSCSI and
       TCdrtfeData.Instance.Settings.General.DetectSpeeds then
      GetDriveSpeeds(Output, CDSpeedList, Dev, DevName, IsWriter)
    else
    begin
      CDSpeedList.Add(DevName + '[W]=' + DefaultSpeedList);
      CDSpeedList.Add(DevName + '[R]=' + DefaultSpeedList);
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
  FCDWriterCount := CDWriter.Count;
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
  CDDevices.Add('dummyw 2=' + Dev + '2,0,6');
  CDWriter.Add('dummyw 0=' + Dev + '2,0,0');
  CDWriter.Add('dummyw 1=' + Dev + '2,0,1');
  CDWriter.Add('dummyw 2=' + Dev + '2,0,2');
  CDReader.Add('dummyr 0=' + Dev + '2,0,3');
  CDReader.Add('dummyr 1=' + Dev + '2,0,4');
  CDReader.Add('dummyr 2=' + Dev + '2,0,5');
  CDWriter.Add('dummyw 2=' + Dev + '2,0,6');
  {$ENDIF}
end;

{ SetAllowMultipleWrite --------------------------------------------------------

  setzt oder löscht den Eintrag für gleichzeitiges Schreiben auf mehrere
  Brenner.                                                                     }

procedure TDevices.SetAllowMultipleWriter(Value: Boolean);
var i: Integer;
begin
  if Value then
  begin
    if (CDWriterCount > 1) and not FAllowMultipleWriter then
      CDWriter.Add(FMultipleWriterName + '=mult');
  end else
  begin
    i := CDWriter.IndexOf(FMultipleWriterName + '=mult');
    if i >= 0 then CDWriter.Delete(i);
  end;
  FAllowMultipleWriter := Value;
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
  {$IFDEF WriteLogfile} AddLogCode(1200); {$ENDIF}
  case FUseRSCSI of
    False: begin
             DetectCDDrives(FLocalCDWriter, FLocalCDReader, FLocalCDDevices,
                            FLocalCDDriveLetter, FLocalCDSpeedList);
             AssignDriveLetters;
           end;
    True : DetectCDDrives(FRemoteCDWriter, FRemoteCDReader, FRemoteCDDevices,
                          FRemoteCDDriveLetter, FRemoteCDSpeedList);
  end;
  {$IFDEF WriteLogfile}
  WriteLog;
  AddLogCode(1201);
  {$ENDIF}
end;

{ Rescan -----------------------------------------------------------------------

  Rescan sucht erneut nach Laufwerken.                                         }

procedure TDevices.Rescan;
begin
  {$IFDEF WriteLogFile} AddLogCode(1222); {$ENDIF}
  ClearLists;
  DetectDrives;
end;

{ SetDummyDevices --------------------------------------------------------------

  belegt die Laufwerkslisten mit jeweils einem Leerstring.                     }

procedure TDevices.SetDummyDevices;
begin
  CDWriter.Add('');
  CDReader.Add('');
  CDDevices.Add('');
end;

{ UpdateSpeedLists -------------------------------------------------------------

  UpdateSpeedLists aktualisiert die Liste der Geschwindigkeiten.               }

procedure TDevices.UpdateSpeedLists(const Drive: string);
var DriveName: string;
    DriveID  : string;
    Output   : TStringList;
    IsWriter : Boolean;
    i        : Integer;

  procedure GetDriveNameID(const Drive: string; var ID, Name: string);
  begin
    {nach Laufwerks-ID und -Namen suchen}
    ID := GetNameByValue(CDDriveLetter, Drive);
    Name := GetNameByValue(CDDevices, ID);
    {$IFDEF WriteLogfile}
    if ID <> '' then
    begin
      AddLog('Drive ID  : ' + ID, 2);
      AddLog('Drive Name: ' + Name, 2);
    end else
      AddLog('Drive ID  : not found in list.', 2);
    AddLog('', 2);
    {$ENDIF}
  end;

  procedure DeleteSpeedEntry(const Name: string; List: TStringList);
  var i: Integer;
  begin
    for i := List.Count -1 downto 0 do
      if Pos(Name, List[i]) > 0 then List.Delete(i);
  end;

  procedure GetPrcapInfo(Output: TStringList; const Dev: string);
  var CommandLine: string;
  begin
    CommandLine := StartUpDir + cCdrecordBin;
    CommandLine := QuotePath(CommandLine);
    CommandLine := CommandLine + ' dev=' + SCSIIF(Dev) + ' -prcap';
    Output.Clear;
    Output.Text := GetDOSOutput(PChar(CommandLine), True, True);
  end;

begin
  {$IFDEF WriteLogfile}
  AddLogCode(1220);
  AddLog('Drive     : ' + Drive + ':' + CRLF, 2);
  {$ENDIF}
  Output := TStringList.Create;
  GetDriveNameID(Drive, DriveID, DriveName);
  if (DriveID <> '') and (DriveName <> '') then
  begin
    IsWriter := CDWriter.Values[DriveName] <> '';
    if IsWriter then
    begin
      DeleteSpeedEntry(DriveName, CDSpeedList);
      GetPrcapInfo(Output, DriveID);
      GetDriveSpeeds(Output, CDSpeedList, DriveID, DriveName, IsWriter);
    end;
  end else
  begin
    for i := 0 to CDWriter.Count - 1 do
    begin
      DriveName := CDWriter.Names[i];
      DriveID := CDWriter.Values[DriveName];
      DeleteSpeedEntry(DriveName, CDSpeedList);
      GetPrcapInfo(Output, DriveID);
      GetDriveSpeeds(Output, CDSpeedList, DriveID, DriveName, True);
    end;
  end;
  Output.Free;
  {$IFDEF WriteLogfile}
  AddLogCode(1221);
  {$ENDIF}
end;

constructor TDevices.Create;
begin
  inherited Create;
  FLocalCDWriter       := TStringList.Create;
  FLocalCDReader       := TStringList.Create;
  FLocalCDDevices      := TStringList.Create;
  FLocalCDDriveLetter  := TStringList.Create;
  FLocalCDSpeedList    := TStringList.Create;
  FLocalDrives         := '';
  FRemoteCDWriter      := TStringList.Create;
  FRemoteCDReader      := TStringList.Create;
  FRemoteCDDevices     := TStringList.Create;
  FRemoteCDDriveLetter := TStringList.Create;
  FRemoteCDSpeedList   := TStringList.Create;
  FRemoteDrives        := '';
  FRSCSIHost           := '';
  FUseRSCSI            := False;
  FAssignManually      := False;
  FAllowMultipleWriter := False;
  FMultipleWriterName  := 'Multiple Writers';
  FCDWriterCount       := 0;
end;

destructor TDevices.Destroy;
begin
  FLocalCDWriter.Free;
  FLocalCDReader.Free;
  FLocalCDDevices.Free;
  FLocalCDDriveLetter.Free;
  FLocalCDSpeedList.Free;
  FRemoteCDWriter.Free;
  FRemoteCDReader.Free;
  FRemoteCDDevices.Free;
  FRemoteCDDriveLetter.Free;
  FRemoteCDSpeedList.Free;
  inherited Destroy;
end;


{ TFormSelectWriter ---------------------------------------------------------- }

{ TFormSelectWriter - private }

procedure TFormSelectWriter.Init;
var i      : Integer;
    NewItem: TListItem;
begin
  FSelDevices := '';
  SetFont(Self);
  {Form}
  Caption := FLang.GMS('mselw01');
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu];
  ClientHeight := 180;
  ClientWidth := 280;
  OnShow := FormShow;
  OnDestroy := FormDestroy;
  {Banner}
  FrameTopBanner1 := TFrameTopBanner.Create(Self);
  FrameTopBanner1.Parent := Self;
  FrameTopBanner1.Top := 0;
  FrameTopBanner1.Left := 0;
  FrameTopBanner1.Width := ClientWidth;
  FrameTopBanner1.Init(Self.Caption, FLang.GMS('mselw02'), 'grad1');
  {ListView}
  ListView := TListView.Create(Self);
  with ListView do
  begin
    Parent := Self;
    Left := 8;
    Top := 61;
    Height := 76;
    Width := 264;
    CheckBoxes := True;
    Visible := True;
    ViewStyle := vsReport;
    ShowColumnHeaders := False;
    Columns.Add;
    Columns.Items[0].AutoSize := True;
    SmallImages := FImageLists.IconImages;
  end;
  {Ok-Button}
  ButtonOk := TButton.Create(Self);
  with ButtonOk do
  begin
    Parent := Self;
    Left := 117;
    Top := 145;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang02');
    OnClick := ButtonClick;
  end;
  {Cancel-Button}
  ButtonCancel := TButton.Create(Self);
  with ButtonCancel do
  begin
    Parent := Self;
    Left := 197;
    Top := 145; // 40;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang03');
    ModalResult := mrCancel;
    Cancel := True;
    OnClick := ButtonCancelClick;
  end;
  {ListView füllen}
  for i := 0 to FCDWriter.Count - 2 do
  begin
    NewItem := ListView.Items.Add;
    NewItem.Caption := FCDWriter.Names[i] + ' (' + FCDWriter.ValueFromIndex[i] + ')';
    NewItem.ImageIndex := FImageLists.IconCDDrive;
  end;
end;

procedure TFormSelectWriter.FormShow(Sender: TObject);
begin
  ButtonCancel.SetFocus;
end;

procedure TFormSelectWriter.ButtonClick(Sender: TObject);
var i   : Integer;
    Temp: TStringList;
begin
  ModalResult := mrOk;
  Temp := TStringList.Create;
  for i := 0 to ListView.Items.Count - 1 do
  begin
    if ListView.Items[i].Checked then Temp.Add(FCDWriter.ValueFromIndex[i]);
  end;
  FSelDevices := Temp.Text;
  Temp.Free;
end;

procedure TFormSelectWriter.ButtonCancelClick(Sender: TObject);
begin

end;

procedure TFormSelectWriter.FormDestroy;
begin

end;

{ TFormSelectWriter - public }

end.
