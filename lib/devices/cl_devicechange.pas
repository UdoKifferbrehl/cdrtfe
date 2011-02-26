{ cl_devicechange.pas: Device change notifier

  Copyright (c) 2006, 2008 Oliver Valencia

  letzte Änderung  01.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  Diese Unit basiert auf einer Prozedur von Christian Novak, gefunden in
  de.comp.lang.delphi.misc sowie auf DiskNotifier.pas von Paul Fisher & Andrew
  Semack.

  cl_devicechange.pas implementiert eine Komponente, die auf die Message
  WM_DeviceChange reagiert.


  TDeviceChangeNotifier

    Properties   OnDiskInserted
                 OnDiskRemoved

    Methoden     Create(AOwner: TComponent)

}


unit cl_devicechange;

{$I directives.inc}

interface

uses Windows, Classes, Forms, Messages, SysUtils;

type TCDInsertDiskStatusEvent = procedure(Drive: string) of object;
     TCDRemoveDiskStatusEvent = procedure(Drive: string) of object;

     TDeviceChangeNotifier = class(TComponent)
     private
       FWindowHandle     : HWND;
       FOnNewDiskInserted: TCDInsertDiskStatusEvent;
       FOnDiskRemoved    : TCDRemoveDiskStatusEvent;
       function GetDriveLetter(UnitMask: Longint): string;
       procedure WndProc(var Msg: TMessage);
     protected
       procedure WMDeviceChange(var Msg: TMessage); dynamic;
     public
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
     published
       property OnDiskInserted: TCDInsertDiskStatusEvent read FOnNewDiskInserted write FOnNewDiskInserted;
       property OnDiskRemoved : TCDRemoveDiskStatusEvent read FOnDiskRemoved write FOnDiskRemoved;
     end;

implementation

const DBT_DEVICEARRIVAL           = $8000; // system detected a new device
      DBT_DEVICEQUERYREMOVE       = $8001; // wants to remove, may fail
      DBT_DEVICEQUERYREMOVEFAILED = $8002; // removal aborted
      DBT_DEVICEREMOVEPENDING     = $8003; // about to remove, still avail
      DBT_DEVICEREMOVECOMPLETE    = $8004; // device is gone
      DBT_DEVICETYPESPECIFIC      = $8005; // type specific event 
      DBT_DEVTYP_VOLUME           = $0002; // Logical volume
      DBTF_MEDIA                  = $0001; // change affects media in drive
      DBTF_NET                    = $0002; // logical volume is network volume

type PDevBroadcastHdr = ^TDevBroadcastHdr;
     TDevBroadcastHdr = packed record
       dbcd_size       : DWord;
       dbcd_devicetype : DWord;
       dbcd_reserved   : DWord;
     end;

     PDevBroadcastVolume = ^TDevBroadcastVolume;
     TDevBroadcastVolume = packed record
       dbcv_size       : DWord;
       dbcv_devicetype : DWord;
       dbcv_reserved   : DWord;
       dbcv_unitmask   : DWord;
       dbcv_flags      : Word;
     end;

     PDevBroadcastDeviceInterface = ^DEV_BROADCAST_DEVICEINTERFACE;
     DEV_BROADCAST_DEVICEINTERFACE = record
       dbcc_size       : DWORD;
       dbcc_devicetype : DWORD;
       dbcc_reserved   : DWORD;
       dbcc_classguid  : TGUID;
       dbcc_name       : Short;
     end;

{ TDeviceChangeNotifier ------------------------------------------------------ }

{ TDeviceChangeNotifier - private }

function TDeviceChangeNotifier.GetDriveLetter(UnitMask: Longint): string;
var DriveLetter: Shortint;
begin
  DriveLetter := Ord('A');
  while (UnitMask and 1) = 0 do begin
    UnitMask := UnitMask shr 1;
    Inc(DriveLetter);
  end;
  Result := LowerCase(Char(DriveLetter));
end;

procedure TDeviceChangeNotifier.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_DEVICECHANGE) then
  begin
    try
      WMDeviceChange(Msg);
    except
      Application.HandleException(Self);
    end;
  end else
    Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;

{ TDeviceChangeNotifier - protected }

{ WMDeviceChange ---------------------------------------------------------------

  reagiert auf die Message WM_DEVICECHANGE.
  Original von Christian Novak, gefunden in de.comp.lang.delphi.misc.          }

procedure TDeviceChangeNotifier.WMDeviceChange(var Msg: TMessage);
var Drive: string;
    bv   : PDevBroadcastVolume;
begin
  if Msg.lParam <> 0 then 
  if PDevBroadcastHdr(Msg.lParam)^.dbcd_devicetype = DBT_DEVTYP_VOLUME then
  begin
    bv := PDevBroadcastVolume(Msg.lParam);
    Drive := GetDriveLetter(bv.dbcv_unitmask);
    case Msg.wParam of
      DBT_DEVICEARRIVAL:
      begin
        if Assigned(FOnNewDiskInserted) then FOnNewDiskInserted(Drive);
      end;
      DBT_DEVICEREMOVECOMPLETE:
      begin
        if Assigned(FOnDiskRemoved) then FOnDiskRemoved(Drive);
      end;
    end;
  end;
end;

{ TDeviceChangeNotifier - public }

constructor TDeviceChangeNotifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TDeviceChangeNotifier.Destroy;
begin
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;

end.
