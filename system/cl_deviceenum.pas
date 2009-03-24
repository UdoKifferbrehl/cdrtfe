{ cl_deviceenum.pas: Implementierung eines einfachen SCSI-Device-Enumerators

  Copyright (c) 2004-2005, 2007 Oliver Valencia

  Version          1.1
  erstellt         23.11.2004
  letzte Änderung  28.09.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_deviceenum.pas stellt einen einfachen SCSI-Device-Enumerator zur Verfügung.
  Der SCSI-Bus kann nach bestimmten Gerätetypen durchsucht werden. Wenn ent-
  sprechende Geräte vorhanden sind, werden diese in String-Listen eingetragen.

  Zur Zeit kann nur nach CD-ROM-Laufwerken gesucht werden.


  TSCSIDevices: SCSI-Device-Enumerator

    Properties   DeviceIDList
                 DeviceList
                 LastError
                 Layer
                 Log

    Methoden     Create
                 Init
                 Scanbus

}


unit cl_deviceenum;

{$I compiler.inc}
{$DEFINE EnableLogging}

interface

uses Classes, Windows, SysUtils;

type TSCSILayer = (L_ASPI,             // ASPI-Layer wird verwendet
                   L_SPTI,             // SPTI-Layer wird verwendet
                   L_None,             // kein SCSI-Interface gefunden
                   L_Undef);           // Interface wurde noch nicht gesucht

     TSCSIDevicesError = (SD_NoError,
                          SD_InterfaceError,
                          SD_UnknownError);
     {Geräteinformation}
     PDeviceInfo = ^DeviceInfo;
     DeviceInfo = record
       HA, ID, LUN: Byte;
       Name       : string;
       Vendor     : string;
       ProductID  : string;
       Revision   : string;
       VendorSpec : string;
       DriveLetter: string;
     end;

     TSCSIDevices = class(TObject)
     private
       FASPIHandle  : THandle;
       FASPILoaded  : Boolean;
       FDeviceIDList: TStringList;          // h,t,l=<driveletter>
       FDeviceList  : TStringList;          // h,t,l=<name>
       FLastError   : TSCSIDevicesError;
       FLayer       : TSCSILayer;
       {$IFDEF EnableLogging}
       FLog         : TStringList;
       {$ENDIF}
       function ASPIGetDiskVendor(P: PDeviceInfo): Boolean;
       function ASPIGetDriveLetter(HA, ID, LUN: Byte): string;
       function SPTIGetDriveInformation(var CurrDev: DeviceInfo): Boolean;
       function GetLastError: TSCSIDevicesError;
       function GetLayer: string;
       function GetSCSIDevID(Driveletter: string): string;
       function NonAdminSPTI: Boolean;
       procedure ASPIFree;
       procedure ASPIInit;
       procedure ASPIScanbus;
       procedure IOCTLGetDriveLetters;
       procedure SPTIInit;
       procedure SPTIScanbus;
       procedure InitSRB(P: Pointer; const Len: Word);
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init;
       procedure Scanbus;
       {Properties}
       property DeviceIDList: TStringList read FDeviceIDList;
       property DeviceList: TStringList read FDeviceList;
       property LastError: TSCSIDevicesError read GetLastError;
       property Layer: string read GetLayer;
       {$IFDEF EnableLogging}
       property Log: TStringList read FLog;
       {$ENDIF}
     end;

implementation

uses f_strings, f_wininfo, f_filesystem, wnaspi32, spti;

const DeviceTypes: array[0..9] of string =
                   ('Disk Device',
                    'Tape Device',
                    'Printer',
                    'Prozessor',
                    'WORM Device',
                    'CD-ROM Device',
                    'Scanner',
                    'Optical Memory',
                    'Medium Changer',
                    'Comunication Device');

type {SCSI-Command-Buffer}
     PSRBBuf = ^SRBBuf;
     SRBBuf  = array [0..1000] of Byte;

{ TSCSIDevices --------------------------------------------------------------- }

{ TSCSIDevices - private }

{ NonAdminSPTI -----------------------------------------------------------------

  CheckNonAdminSPTI prüft, ob wir genug Rechte besitzten, um trotzdem per SPTI
  auf Laufwerke zugreifen zu können. True, falls dies möglich ist.             }

function TSCSIDevices.NonAdminSPTI: Boolean;
var DriveList  : TStringList;
    i          : Integer;
    FH         : THandle;
    DriveLetter: string;
    DriveName  : array[0..31] of Char;
    dwFlags    : {$IFDEF Delphi4Up}Cardinal{$ELSE}DWORD{$ENDIF};
begin
  {$IFDEF EnableLogging}
  FLog.Add('    Checking non-Admin SPTI access');
  {$ENDIF}
  Result := False;
  dwFlags := GENERIC_READ;
  if PlatformWin2kXP then dwFlags := dwFlags or GENERIC_WRITE;
  DriveList := TStringList.Create;
  {Laufwerksliste erstellen: (Festplatten und CD-Laufwerke)}
  // GetDriveList(DRIVE_FIXED, DriveList);
  GetDriveList(DRIVE_CDROM, DriveList);
  {für jedes Laufwerk Infos abrufen}
  for i := 0 to DriveList.Count - 1 do
  begin
    DriveLetter := DriveList[i][1];
    {$IFDEF EnableLogging}
    FLog.Add('      Accessing Drive: ' + DriveLetter + ':');
    {$ENDIF}
    {Dateinamen zusammenstellen und Datei öffnen}
    StrPCopy(@DriveName, Format( '\\.\%s:', [DriveLetter]));
    FH := CreateFile(DriveName, dwFlags, FILE_SHARE_READ, nil, OPEN_EXISTING,
                     0, 0);
    if FH <> INVALID_HANDLE_VALUE then
    begin
      CloseHandle(FH);
      {$IFDEF EnableLogging}
      FLog.Add('        ok.');
      {$ENDIF}
      Result := True;
    end else
    begin
      {$IFDEF EnableLogging}
      FLog.Add('        failed.');
      {$ENDIF}
    end;
  end;
  DriveList.Free;
end;

{ GetSCSIDevID -----------------------------------------------------------------

  GetSCSIDevID ermittelt per DeviceIOControl die SCSI-ID des Laufwerks. Dies ist
  auch ohne Admin-Recht möglich, aber nur mit CD-Laufwerken.                   }

function TSCSIDevices.GetSCSIDevID(Driveletter: string): string;
var DeviceHandle   : {$IFDEF Delphi4Up}Cardinal{$ELSE}Integer{$ENDIF};
    bytesReturned  : DWORD;
    lpBytesReturned: {$IFDEF Delphi4Up}Cardinal{$ELSE}DWORD{$ENDIF};
    DeviceName     : array[0..MAX_PATH] of UCHAR;
    DataBuffer     : SCSI_ADDRESS;
    Returned       : Cardinal;
begin
  StrCopy(@DeviceName, '\\.\');
  StrCat(@DeviceName, PChar(Driveletter));

  DeviceHandle := CreateFile(@deviceName, GENERIC_READ,
                             FILE_SHARE_READ or FILE_SHARE_WRITE,
                             nil, OPEN_EXISTING, 0, 0);
  if INVALID_HANDLE_VALUE <> DeviceHandle then
  begin
    ZeroMemory(Addr(dataBuffer), sizeof(dataBuffer));
    lpBytesReturned := DWORD( Addr(bytesReturned));
    if DeviceIoControl(DeviceHandle, IOCTL_SCSI_GET_ADDRESS, nil, 0,
                       @DataBuffer, SizeOf(SCSI_ADDRESS),
                       lpBytesReturned, nil) then
    begin
      Result := Format('%d,%d,%d',
                       [dataBuffer.PortNumber,
                        dataBuffer.TargetId,
                        dataBuffer.Lun]);
    end else
    begin
      Result := '';
      {$IFDEF EnableLogging}
      FLog.Add('  IOCTL_SCSI_GET_ADDRESS failed.');
      {$ENDIF}
    end;
    CloseHandle(DeviceHandle);
  end else
  begin
    Result := '';
    {$IFDEF EnableLogging}
    Returned := Windows.GetLastError;
    FLog.Add('     Invalid device handle.');
    FLog.Add('     GetLastError: ' + IntToStr(Returned));
    FLog.Add('     ErrorMessage: ' + SysErrorMessage(Returned)  + #13#10);
    {$ENDIF}
  end;
end;

{ IOCTLGetDriveLetters ---------------------------------------------------------

  IOCTLGetDriveLetters geht die Liste der Laufwerksbuchstaben durch und
  ermittelt für jeden die SCSI-ID und vergleicht diese mit den vorhandenen, um
  die Laufwerksbuchstaben zuzuordnen. SPTI wird nicht verwendet, damit das auch
  ohne Admin-Recht funktioniert. Scheint nur mit CD-Laufwerken möglich zu sein.}

procedure TSCSIDevices.IOCTLGetDriveLetters;
var DriveList  : TStringList;
    i          : Integer;
    DriveLetter: string;
    DevID      : string;
begin
  {$IFDEF EnableLogging}
  FLog.Add('   Getting drive letter for SCSI-ID');
  {$ENDIF}
  DriveList := TStringList.Create;
  {Laufwerksliste erstellen: (Festplatten und CD-Laufwerke)}
  // GetDriveList(DRIVE_FIXED, DriveList);
  GetDriveList(DRIVE_CDROM, DriveList);
  {für jedes Laufwerk Infos abrufen}
  for i := 0 to DriveList.Count - 1 do
  begin
    DriveLetter := DriveList[i][1];
    DevID := GetSCSIDevID(DriveLetter + ':');
    {$IFDEF EnableLogging}
    FLog.Add('     Drive: ' + DriveLetter + ': <- ' + DevID);
    {$ENDIF}
    if DevID <> '' then FDeviceIDList.Values[DevID] := DriveLetter;
  end;
  DriveList.Free;
end;

{ SPTIGetDriveInformation ------------------------------------------------------

  SPTIGetDriveInformation ermittelt Informationen über ein Laufwerk.           }

function TSCSIDevices.SPTIGetDriveInformation(var CurrDev: DeviceInfo): Boolean;
var FH         : THandle;
    DriveName  : array[0..31] of char;
    Buffer     : array[0..1023] of char;
    inqData    : array[0..99] of char;
    Ok         : Bool;
    PSWB       : PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
    pscsiAddr  : PSCSI_ADDRESS;
    Length     : Integer;
    Returned   : {$IFDEF Delphi4Up}Cardinal{$ELSE}Integer{$ENDIF};
    dwFlags    : {$IFDEF Delphi4Up}Cardinal{$ELSE}DWORD{$ENDIF};
    DriveString: PChar;
    s          : string;
begin
  {$IFDEF EnableLogging}
  FLog.Add(Format('   SPTIGetDriveInformation for drive %s',
                  [CurrDev.DriveLetter]));
  {$ENDIF}
  dwFlags := GENERIC_READ;
  if PlatformWin2kXP then dwFlags := dwFlags or GENERIC_WRITE;
  {Dateinamen zusammenstellen und Datei öffnen}
  StrPCopy(@DriveName, Format( '\\.\%s:', [CurrDev.DriveLetter]));
  FH := CreateFile(DriveName, dwFlags, FILE_SHARE_READ, nil, OPEN_EXISTING,
                   0, 0);
  if FH <> INVALID_HANDLE_VALUE then
  begin
    {$IFDEF EnableLogging}
    FLog.Add('     CreateFile ... ok');
    {$ENDIF}
    {Drive Inquiry Data ermitteln}
    ZeroMemory(@Buffer, 1024);
    ZeroMemory(@inqData, 100);
    PSWB := PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER(@Buffer);
    PSWB^.spt.Length             := SizeOf(SCSI_PASS_THROUGH);
    PSWB^.spt.CdbLength          := 6;
    PSWB^.spt.SenseInfoLength    := 24;
    PSWB^.spt.DataIn             := SCSI_IOCTL_DATA_IN;
    PSWB^.spt.DataTransferLength := 100;
    PSWB^.spt.TimeOutValue       := 2;
    PSWB^.spt.DataBuffer         := @inqData;
    PSWB^.spt.SenseInfoOffset    := SizeOf(PSWB^.spt) + SizeOf(PSWB^.Filler);
    PSWB^.spt.Cdb[0]             := $12;
    PSWB^.spt.Cdb[4]             := 100;
    Length := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);
    Ok := DeviceIoControl(FH, IOCTL_SCSI_PASS_THROUGH_DIRECT,
                          PSWB, Length, PSWB, Length, Returned, nil );
    if OK then
    begin
      {$IFDEF EnableLogging}
      FLog.Add('     Get drive inquiry data ... ok');
      {$ENDIF}
      DriveString := @inqData;
      Inc(DriveString, 8);
      {Infos: Vendor, Product-ID, Revision, Vendor-Spec}
      CurrDev.Vendor     := Copy(DriveString, 1, 8);
      CurrDev.ProductID  := Copy(DriveString, 8 + 1, 16);
      CurrDev.Revision   := Copy(DriveString, 24 + 1, 4);
      CurrDev.VendorSpec := Copy(DriveString, 28 + 1, 20);
      CurrDev.Name       := Trim(CurrDev.Vendor) + ' ' +
                            Trim(CurrDev.ProductID) + ' ' +
                            Trim(CurrDev.Revision);
      {Adresse (path/tgt/lun) des Laufwerks mit IOCTL_SCSI_GET_ADDRESS}
      ZeroMemory(@Buffer, 1024);
      pscsiAddr         := PSCSI_ADDRESS(@Buffer);
      pscsiAddr^.Length := SizeOf(SCSI_ADDRESS);
      if DeviceIoControl(FH, IOCTL_SCSI_GET_ADDRESS, nil, 0,
                         pscsiAddr, SizeOf(SCSI_ADDRESS), Returned, nil) then
      begin
        CurrDev.HA  := pscsiAddr^.PortNumber;
        CurrDev.ID  := pscsiAddr^.TargetId;
        CurrDev.LUN := pscsiAddr^.Lun;
        Result := True;
        {$IFDEF EnableLogging}
        s := IntToStr(CurrDev.HA) + ',' +
             IntToStr(CurrDev.ID) + ',' +
             IntToStr(CurrDev.LUN);
        FLog.Add('     Get SCSI address ... ok');
        FLog.Add('       Device ID        : ' + s);
        FLog.Add('       Device Vendor    : ' + CurrDev.Vendor);
        FLog.Add('       Device ProductID : ' + CurrDev.ProductID);
        FLog.Add('       Device Revision  : ' + CurrDev.Revision);
        FLog.Add('       Device VendorSpec: ' + CurrDev.VendorSpec + #13#10);
       {$ENDIF}
      end else
      begin
        {$IFDEF EnableLogging}
        FLog.Add('     Get SCSI address ... failed' + #13#10);
       {$ENDIF}
        Result := False;
      end;
      CloseHandle(FH);
    end else
    begin
      {$IFDEF EnableLogging}
      Returned := Windows.GetLastError;
      FLog.Add('     Get drive inquiry data ... failed');
      FLog.Add('     GetLastError: ' + IntToStr(Returned));
      FLog.Add('     ErrorMessage: ' + SysErrorMessage(Returned)  + #13#10);
      {$ENDIF}
      CloseHandle(FH);
      Result := False;
    end;
  end else
  begin
    {$IFDEF EnableLogging}
    Returned := Windows.GetLastError;    
    FLog.Add('   CreateFile ... failed');
    FLog.Add('   GetLastError: ' + IntToStr(Returned));
    FLog.Add('   ErrorMessage: ' + SysErrorMessage(Returned)  + #13#10);
    {$ENDIF}
    {Device konnte nicht geöffnet werden (z.B. keine Admin-Rechte vorhanden)}
    Result := False;
  end;
end;

{ InitSRB ----------------------------------------------------------------------

  InitSRB initialisiert den SCSI-Command-Buffer mit 0.                         }

procedure TSCSIDevices.InitSRB(P: Pointer; const Len: Word);
var i : word;
    Pt: PSRBBuf;
begin
  Pt := P;
  for i := 0 to Len - 1 do Pt^[i] := 0;
end;

{ ASPIGetDiskVendor ------------------------------------------------------------

  ermittelt den Hersteller des Gerätes.                                        }

function TSCSIDevices.ASPIGetDiskVendor(P: PDeviceInfo): Boolean;
var Buffer: PSRBBuf;
    SRB   : PSRB_ExecSCSICmd;
    i     : Integer;
begin
  Result := False;
  SRB := New(PSRB_ExecSCSICmd);
  Buffer := New(PSRBBuf);
  InitSRB(SRB, SizeOf(SRB^));
  SRB^.SRB_CMD        := SC_EXEC_SCSI_CMD;
  SRB^.SRB_Flags      := 8;
  SRB^.SRB_HAId       := P^.HA;
  SRB^.SRB_Target     := P^.ID;
  SRB^.SRB_Lun        := P^.LUN;
  SRB^.SRB_BufPointer := Buffer;
  SRB^.SRB_Buflen     := 36;
  SRB^.SRB_SenseLen   := 14;
  SRB^.SRB_CDBLen     := 6;
  SRB^.CDBByte[0]     := $12;
  SRB^.CDBByte[1]     := P^.Lun * 32;
  SRB^.CDBByte[4]     := 36; {Length of SCSI-command}
  SendASPI32Command(SRB);
  while SRB^.SRB_Status = SS_PENDING do;
  if SRB^.SRB_Status = SS_COMP then
  begin
    P^.Vendor :='';
    for i := 8 to 15 do
      if Buffer[i] <> 0 then P^.Vendor := P^.Vendor + char(Buffer[i]);
    P^.ProductID := '';
    for i := 16 to 31 do
      if Buffer[i] <> 0 then P^.ProductID := P^.ProductID + char (Buffer[i]);
    P^.Revision := '';
    for i := 32 to 35 do
      if Buffer[i] <> 0 then P^.Revision := P^.Revision + char (Buffer[i]);
    P^.Name := Trim(P^.Vendor) + ' ' + Trim(P^.ProductID) + ' ' +
               Trim(P^.Revision);
    Result := True;
  end;
  Dispose(SRB);
  Dispose(Buffer);
 end;

{ ASPIGetDriveLetter -----------------------------------------------------------

  ASPIGetDriveLetter bestimmt den Laufwerksbuchstaben eines Gerätes.           }

function TSCSIDevices.ASPIGetDriveLetter(HA, ID, LUN: Byte): string;
var SRB: PSRB_GetDiskInfo;
begin
  SRB := New(PSRB_GetDiskInfo);
  SRB^.SRB_Cmd := SC_GET_DISK_INFO;
  SRB^.SRB_HaId := HA;
  SRB^.SRB_Target := ID;
  SRB^.SRB_Lun := LUN;
  SendASPI32Command(SRB);
  while SRB^.SRB_Status = SS_PENDING do;
  Result := Chr(Ord('A') + (SRB.SRB_Int13HDriveInfo));
  if not (Result[1] in ['C'..'Z', 'c'..'z']) then Result := '';
  Dispose(SRB);
  {$IFDEF EnableLogging}
  FLog.Add('      Int13HInfo : ' + IntToStr(SRB.SRB_Int13HDriveInfo));
  {$ENDIF}
end;

{ GetLastError -----------------------------------------------------------------

  GetLastError gibt den zuletzt aufgetretenen Fehler zurück.                   }

function TSCSIDevices.GetLastError: TSCSIDevicesError;
begin
  Result := FLastError;
  FLastError := SD_NoError;
end;

{ GetLayer ---------------------------------------------------------------------

  GetLayer gibt als String den verwendeten ASPI-Layer zurück.                  }

function TSCSIDevices.GetLayer: string;
begin
  Result := EnumToStr(TypeInfo(TSCSILayer), FLayer)
end;

{ SPTIInit ---------------------------------------------------------------------

  SPTIInit prüft, ob wir SPTI verwenden können.                                }

procedure TSCSIDevices.SPTIInit;
begin
  {$IFDEF EnableLogging}
  FLog.Add('    Checking system ...');
  {$ENDIF}
  if PlatformWin2kXP then
  begin
    {$IFDEF EnableLogging}
    FLog.Add('    System is Win2k/XP');
    {$ENDIF}
    if IsAdmin then
    begin
      {$IFDEF EnableLogging}
      FLog.Add('    Admin privileges ... ok. SPTI ok.');
      {$ENDIF}
      FLayer := L_SPTI;
      FLastError := SD_NoError;
    end else
    begin
      {$IFDEF EnableLogging}
      FLog.Add('    No Admin privileges, try SPTI anyway.');
      {$ENDIF}
      if NonAdminSPTI then
      begin
        {$IFDEF EnableLogging}
        FLog.Add('    SPTI ok.');
        {$ENDIF}
        FLayer := L_SPTI;
        FLastError := SD_NoError;
      end else
      begin
        {$IFDEF EnableLogging}
        FLog.Add('    Cannot use SPTI.');
        {$ENDIF}
        FLayer := L_Undef;
        FLastError := SD_InterfaceError;
      end;
    end;
  end else
  begin
    {$IFDEF EnableLogging}
    FLog.Add('    Cannot use SPTI (not Win2k/XP).');
    {$ENDIF}
    FLayer := L_Undef;
    FLastError := SD_InterfaceError;
  end;
end;

{ SPTIScanbus ------------------------------------------------------------------

  SPTIScanbus geht die Liste der Laufwerksbuchstaben durch und ermittelt für
  jeden die SCSI-ID.                                                           }

procedure TSCSIDevices.SPTIScanbus;
var DriveList: TStringList;
    i        : Integer;
    Ok       : Boolean;
    Drive    : DeviceInfo;
    DevID    : string;
begin
  FDeviceIDList.Clear;
  FDeviceList.Clear;
  DriveList := TStringList.Create;
  {Laufwerksliste erstellen: (Festplatten und CD-Laufwerke)}
  // GetDriveList(DRIVE_FIXED, DriveList);
  GetDriveList(DRIVE_CDROM, DriveList);
  {für jedes Laufwerk Infos abrufen}
  for i := 0 to DriveList.Count - 1 do
  begin
    Drive.DriveLetter := DriveList[i][1];
    Ok := SPTIGetDriveInformation(Drive);
    if Ok then
    begin
      DevID := IntToStr(Drive.HA) + ',' +
               IntToStr(Drive.ID) + ',' +
               IntToStr(Drive.LUN);
      {jede ID nur einmal in die Liste schreiben}
      if FDeviceIDList.Values[DevID] = '' then
      begin
        FDeviceIDList.Add(DevID + '=' + Drive.DriveLetter);
        FDeviceList.Add(DevID + '=' + Drive.Name);
      end;
    end;
  end;
  DriveList.Free;
end;

{ ASPIInit ---------------------------------------------------------------------

  ASPIInit lädt wnaspi32.dll.                                                  }

procedure TSCSIDevices.ASPIInit;
begin
  {$IFDEF EnableLogging}
  FLog.Add('    Loading wnaspi32.dll ...');
  {$ENDIF}
  FASPIHandle := LoadLibrary(PChar(cWNASPI));
  if FASPIHandle > 0 then
  begin
    FASPILoaded := True;
    FLastError := SD_NoError;
    @SendASPI32Command := GetProcAddress(FASPIHandle, 'SendASPI32Command');
    @GetASPI32SupportInfo := GetProcAddress(FASPIHandle, 'GetASPI32SupportInfo');
    {$IFDEF EnableLogging}
    FLog.Add('    Loading wnaspi32.dll ... ok');
    {$ENDIF}
  end else
  begin
    FASPILoaded := False;
    FLastError := SD_InterfaceError;
    {$IFDEF EnableLogging}
    FLog.Add('    Loading wnaspi32.dll ... failed');
    {$ENDIF}
  end;  
end;

{ FreeASPI ---------------------------------------------------------------------

  FreeASPI entfernt wnaspi32.dll aus dem Speicher.                             }

procedure TSCSIDevices.ASPIFree;
begin                
  if FASPILoaded then
  begin
    FASPILoaded := FreeLibrary(FASPIHandle);
    FASPIHandle := 0;
    @SendASPI32Command := nil;
    @GetASPI32SupportInfo := nil;
  end;
end;

{ ASPIScanbus ------------------------------------------------------------------

  ASPIScanbus durchsucht den SCSI-Bus nach Geräten, Interface: ASPI.           }

procedure TSCSIDevices.ASPIScanbus;
var NumAdap: Longint;              // Anzahl Hostadapter
    HA_Num : Integer;              // aktueller Hostadapter
    ID     : Integer;              // Geräte-ID
    s      : string;
    j      : Integer;
    InqSRB : PSRB_HAInquiry;
    DeTSRB : PSRB_GDEVBlock;
    CurrDev: PDeviceInfo;          // aktuelles Device
begin
  FDeviceIDList.Clear;
  FDeviceList.Clear;
  {Anzahl Host-Adapter, ASPI-Manager initialisieren}
  NumAdap := GetAspi32SupportInfo;
  if HiByte(LoWord(NumAdap)) = SS_COMP then
  begin
    InqSRB := New(PSRB_HAInquiry);
    InitSRB(InqSRB, SizeOf(InqSRB^));
    DetSRB := New(PSRB_GDEVBlock);
    InitSRB(DetSRB, SizeOf(DetSRB^));
    NumAdap := NumAdap and 255;
    {aller Hostadapter durchsuchen}
    for HA_Num := 0 to NumAdap - 1 do
    begin
      {With hostadapter-inquiry successive ask all of then
       At existing hostadapter with TestUnitReady
       shake all ID´s. LUN=0 is expected. Restriction applys to RAID-Servers}
      InqSrb^.SRB_Cmd   := 0;
      InqSrb^.SRB_HaId  := HA_Num;
      InqSrb^.SRB_Flags := 0;
      SendASPI32Command(InqSrb);
      while InqSrb^.SRB_Status = SS_PENDING do;
      if InqSrb^.SRB_Status = SS_INVALID_HA { $81} then
      begin
        {$IFDEF EnableLogging}
        FLog.Add(Format('   ASPI Error at Hostadapter %d', [HA_Num]));
        {$ENDIF}
      end else
      begin
        {Namen des Hostadapters auslesen}
        s := '';
        for j := 0 to 15 do
        begin
          if (InqSrb^.HA_Identifier[j] <> 0) then
          begin
            s := s + char(InqSrb^.HA_Identifier[j]);
          end;
        end;
        {$IFDEF EnableLogging}
        FLog.Add(Format('   Hostadapter ' + s + ' AspiNum: %d, SCSI-ID: %d',
                        [HA_Num, InqSrb^.HA_SCSI_ID]) + #13#10);
        {$ENDIF}

        {Geräte an diesem Hostadpter suchen}
        for ID := 0 to 7 do
        begin
          DetSrb^.SRB_CMD    := SC_Get_Dev_Type;
          DetSrb^.SRB_HaId   := HA_Num;
          DetSrb^.SRB_Flags  := 0;
          DetSrb^.SRB_Target := ID;
          DetSrb^.SRB_Lun    := 0;
          SendASPI32Command(DetSrb);
          while DetSrb^.SRB_Status = SS_PENDING do;
          if DetSrb^.SRB_Status = SS_COMP then
          begin
            {Geräte-Typ bestimmen}
            j := DetSrb^.SRB_DeviceType;
            if j in [PDT_DISK_DEVICE..PDT_COMM] then
              s := DeviceTypes[j] else
              s:='';
            {$IFDEF EnableLogging}
            FLog.Add(Format('   Device ID %d, Type %d (%s)', [ID, j, s]));
            {$ENDIF}
            {von CD-ROM-Laufwerken Vendor-Info ermitteln}
            if j in [PDT_DISK_DEVICE..PDT_COMM] {PDT_CDROM} then
            begin
              CurrDev := New(PDeviceInfo);
              CurrDev^.HA          := HA_Num;
              CurrDev^.ID          := ID;
              CurrDev^.Lun         := 0;
              {Unter Win2k/XP funktioniert dies nicht:}
              if not PlatformWin2kXP then
              CurrDev^.DriveLetter := ASPIGetDriveLetter(CurrDev^.HA,
                                                         CurrDev^.ID,
                                                         CurrDev^.LUN);
              if ASPIGetDiskVendor(CurrDev) then
              begin
                s := IntToStr(CurrDev^.HA) + ',' +
                     IntToStr(CurrDev^.ID) + ',' +
                     IntToStr(CurrDev^.LUN) + '=';
                FDeviceIDList.Add(s + CurrDev^.DriveLetter);
                FDeviceList.Add(s + CurrDev^.Name);
                {$IFDEF EnableLogging}
                FLog.Add('      Device Vendor    : ' + CurrDev.Vendor);
                FLog.Add('      Device ProductID : ' + CurrDev.ProductID);
                FLog.Add('      Device Revision  : ' + CurrDev.Revision);
                FLog.Add('      Driveletter: ' + CurrDev^.DriveLetter + #13#10);
                {$ENDIF}
              end else
              begin
                {$IFDEF EnableLogging}
                FLog.Add('  Inquiry failed ...?' + #13#10);
                {$ENDIF}
              end;
              Dispose(CurrDev);
            end;
          end;
        end;
      end;
    end;
    Dispose(InqSRB);
    Dispose(DetSRB);
  end else
  begin
    FLastError := SD_InterfaceError;
  end;
end;

{ TSCSIDevices - public }

{ Init -------------------------------------------------------------------------

  Init prüft, welches Interface/Layer verwendet werden kann (Win9x: ASPI; Win2k,
  WinXP: SPTI (default) oder ASPI) und initialisiert es.                       }

procedure TSCSIDevices.Init;
begin
  {$IFDEF EnableLogging}
  FLog.Add(#13#10 + 'TSCSIDevices - Log');
  FLog.Add('------------------');
  FLog.Add('  Checking for SCSI Interface');
  {$ENDIF}
  {Können wir SPTI verwenden?}
  if FLayer = L_Undef then
  begin
    {$IFDEF EnableLogging}
    FLog.Add('  Initializing SPTI');
    {$ENDIF}
    FLayer := L_SPTI;
    {SPTI initialisieren}
    SPTIInit;
    {SPTI-Fehler}
    if FLastError <> SD_NoError then FLayer := L_Undef;
  end;
  {Wenn nicht, dann ASPI versuchen.}
  if FLayer = L_Undef then
  begin
    {$IFDEF EnableLogging}
    FLog.Add('  Initializing ASPI');
    {$ENDIF}
    FLayer := L_ASPI;
    {ASPI initialiseren}
    ASPIInit;
    {ASPI-Fehler}
    if FLastError <> SD_NoError then FLayer := L_None;
  end;
end;

{ Scanbus ----------------------------------------------------------------------

  Scanbus sucht nach SCSI-Geräten.                                             }

procedure TSCSIDevices.Scanbus;
begin
  {$IFDEF EnableLogging}
  FLog.Add(#13#10 + '   Scanning SCSI bus');
  {$ENDIF}
  case FLayer of
    L_ASPI: begin
              if FASPILoaded then
              begin
                ASPIScanbus;
                {Unter Win2k/XP haben wir jetzt die IDs aber nicht die Zuordnung
                 zu den Laufwerksbuchstaben}
                if PlatformWin2kXP then IOCTLGetDriveLetters;
              end;
            end;
    L_SPTI: SPTIScanbus;
  else
    FLastError := SD_InterfaceError;
  end;
end;

constructor TSCSIDevices.Create;
begin
  inherited Create;
  FASPIHandle   := 0;
  FASPILoaded   := False;
  FDeviceIDList := TStringList.Create;
  FDeviceList   := TStringList.Create;
  FLastError    := SD_NoError;
  FLayer        := L_Undef;
  {$IFDEF EnableLogging}
  FLog          := TStringList.Create;
  {$ENDIF}
end;

destructor TSCSIDevices.Destroy;
begin
  {$IFDEF EnableLogging}
  FLog.Free;
  {$ENDIF}
  ASPIFree;
  FDeviceIDList.Free;
  FDeviceList.Free;
  inherited Destroy;
end;

end.
