{ wnaspi32.pas: ASPI for Win32 definitions

  letzte Änderung  17.05.2007

  wnaspi32.pas ist eine Umsetzung von wnaspi32.h für Delphi

  benötigt wnaspi32.dll

  Ursprüngliche Copyright-Notiz von wnaspi32.h:

  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR
  PURPOSE.

  Copyright (C) 1993-95  Microsoft Corporation.  All Rights Reserved.

}

unit wnaspi32;

{$I compiler.inc}

interface

{$IFDEF Delphi7Up}
{$A4}
{$ENDIF}

type DWORD = Integer; //Cardinal;
     LPSRB = Pointer;
     PFNPOST = Pointer;

{ Wir werden die Funktionen aus wnaspi32.dll nicht statisch linken, sondern bei
  Bedarf die DLL dynamisch laden. Daher werden diese Deklarationen hier aus-
  kommentiert.}
{
function SendASPI32Command(P: LPSRB): DWORD; stdcall; external 'wnaspi32.dll';
function GetASPI32SupportInfo: DWORD; stdcall; external 'wnaspi32.dll';
}

const cWNASPI = 'wnaspi32.dll';

type TSendASPI32Command    = function(LPSRB: Pointer): DWORD; cdecl;
     TGetASPI32SupportInfo = function: DWORD; cdecl;

var SendASPI32Command   : TSendASPI32Command    = nil;
    GetASPI32SupportInfo: TGetASPI32SupportInfo = nil;

{ Konstanten-Deklaration ----------------------------------------------------- }

const SENSE_LEN                 = 14;	  // Default sense buffer length
      SRB_DIR_SCSI              = $00;	  // Direction determined by SCSI command
      SRB_DIR_IN                = $08;	  // Transfer from SCSI target to host
      SRB_DIR_OUT               = $10;	  // Transfer from host to SCSI  target
      SRB_POSTING               = $01;	  // Enable ASPI posting
      SRB_EVENT_NOTIFY          = $40;    // Enable ASPI event notification
      SRB_ENABLE_RESIDUAL_COUNT = $04;    // Enable residual byte count  reporting
      SRB_DATA_SG_LIST          = $02;	  // Data buffer points to scatter-gather list
      WM_ASPIPOST               = $4D42;  // ASPI Post message

      { Peripheral Device Type ----------------------------------------------- }
      { Alternative Deklaration, falls scsidefs.pas nicht verwendet wird.      }
      PDT_Disk_Device           = $00;    // Disk device
      PDT_Tape_Device           = $01;    // Tape device
      PDT_Printer               = $02;    // Printer
      PDT_Processor             = $03;    // Processor
      PDT_WORM                  = $04;    // Write-once read-multiple
      PDT_CDROM                 = $05;    // CD-ROM device
      PDT_Scanner               = $06;    // Scanner device
      PDT_OMD                   = $07;    // Optical memory device
      PDT_Medium_Changer        = $08;    // Medium Changer device
      PDT_Comm                  = $09;    // Communications device
      PDT_Reserved_Low          = $0a;	  // Reserved (low)
      PDT_Reserved_High         = $1e;    // Reserved (high)
      PDT_Unknown               = $1f;	  // Unknown or no device type}

      { ASPI Command Definitions --------------------------------------------- }
      SC_HA_INQUIRY             = $00;	  // Host adapter inquiry
      SC_GET_DEV_TYPE           = $01;    // Get device type
      SC_EXEC_SCSI_CMD          = $02;	  // Execute SCSI command
      SC_ABORT_SRB              = $03;	  // Abort an SRB
      SC_RESET_DEV              = $04;	  // SCSI bus device reset
      SC_GET_DISK_INFO          = $06;	  // Get Disk information

      { SRB Status ----------------------------------------------------------- }
      SS_PENDING                = $00;    // SRB being processed
      SS_COMP                   = $01;    // SRB completed without error
      SS_ABORTED                = $02;    // SRB aborted
      SS_ABORT_FAIL             = $03;    // Unable to abort SRB
      SS_ERR                    = $04;    // SRB completed with error

      SS_INVALID_CMD            = $80;    // Invalid ASPI command
      SS_INVALID_HA             = $81;    // Invalid host adapter number
      SS_NO_DEVICE              = $82;    // SCSI device not installed

      SS_INVALID_SRB            = $E0;    // Invalid parameter set in SRB
      SS_FAILED_INIT            = $E4;    // ASPI for windows failed init
      SS_ASPI_IS_BUSY           = $E5;    // No resources available to execute cmd
      SS_BUFFER_TO_BIG          = $E6;    // Buffer size to big to handle!


      { Host Adapter Status -------------------------------------------------- }
      HASTAT_OK                   = $00;  // Host adapter did not detect an error
      HASTAT_SEL_TO               = $11;  // Selection Timeout
      HASTAT_DO_DU                = $12;  // Data overrun data underrun
      HASTAT_BUS_FREE             = $13;  // Unexpected bus free
      HASTAT_PHASE_ERR            = $14;  // Target bus phase sequence failure
      HASTAT_TIMEOUT              = $09;  // Timed out while SRB was waiting to beprocessed.
      HASTAT_COMMAND_TIMEOUT      = $0B;  // While processing the SRB, the adapter timed out.
      HASTAT_MESSAGE_REJECT       = $0D;  // While processing SRB, the adapter received a MESSAGE REJECT.
      HASTAT_BUS_RESET            = $0E;  // A bus reset was detected.
      HASTAT_PARITY_ERROR         = $0F;  // A parity error was detected.
      HASTAT_REQUEST_SENSE_FAILED = $10;  // The adapter failed in issuing REQUEST SENSE.


{ Typ-Deklaration ------------------------------------------------------------ }

type
     { SRB - HOST ADAPTER INQUIRY - SC_HA_INQUIRY ---------------------------- }
     SRB_HAInquiry = record
       SRB_Cmd       : Byte;                  // ASPI command code = SC_HA_INQUIRY
       SRB_Status    : Byte;                  // ASPI command status byte
       SRB_HaId      : Byte;                  // ASPI host adapter number
       SRB_Flags     : Byte;                  // ASPI request flags
       SRB_Hdr_Rsvd  : DWORD;                 // Reserved, MUST = 0
       HA_Count      : Byte;                  // Number of host adapters present
       HA_SCSI_ID    : Byte;                  // SCSI ID of host adapter
       HA_ManagerId  : array [0..15] of Byte; // String describing the manager
       HA_Identifier : array[0..15] of Byte;  // String describing the host adapter
       HA_Unique     : array[0..15] of Byte;  // Host Adapter Unique parameters
       HA_Rsvd1      : Word;
     end;

     PSRB_HAInquiry = ^SRB_HAInquiry;
     TSRB_HAInquiry = SRB_HAInquiry;

     { SRB - GET DEVICE TYPE - SC_GET_DEV_TYPE ------------------------------- }
     SRB_GDEVBlock = record
       SRB_Cmd        : Byte;          // ASPI command code = SC_GET_DEV_TYPE
       SRB_Status     : Byte;          // ASPI command status byte
       SRB_HaId       : Byte;          // ASPI host adapter number
       SRB_Flags      : Byte;          // Reserved
       SRB_Hdr_Rsvd   : DWORD;         // Reserved
       SRB_Target     : Byte;          // Target's SCSI ID
       SRB_Lun        : Byte;          // Target's LUN number
       SRB_DeviceType : Byte;          // Target's peripheral device type
       SRB_Rsvd1      : Byte;
     end;

     PSRB_GDEVBlock = ^SRB_GDEVBlock;
     TSRB_GDEVBlock = SRB_GDEVBlock;

     { SRB - EXECUTE SCSI COMMAND - SC_EXEC_SCSI_CMD ------------------------- }
     SRB_ExecSCSICmd = record
       SRB_Cmd        : Byte;          // ASPI command code = SC_EXEC_SCSI_CMD
       SRB_Status     : Byte;          // ASPI command status byte
       SRB_HaId       : Byte;          // ASPI host adapter number
       SRB_Flags      : Byte;          // ASPI request flags
       SRB_Hdr_Rsvd   : DWORD;         // Reserved
       SRB_Target     : Byte;          // Target's SCSI ID
       SRB_Lun        : Byte;          // Target's LUN number
       SRB_Rsvd1      : Word;          // Reserved for Alignment
       SRB_BufLen     : DWORD;         // Data Allocation Length
       SRB_BufPointer : Pointer;       // Data Buffer Pointer
       SRB_SenseLen   : Byte;          // Sense Allocation Length
       SRB_CDBLen     : Byte;          // CDB Length
       SRB_HaStat     : Byte;          // Host Adapter Status
       SRB_TargStat   : Byte;          // Target Status
       SRB_PostProc   : POINTER;       // Post routine
       SRB_Rsvd2      : POINTER;       // Reserved
       SRB_Rsvd3      : array [0..15] of Byte;          // Reserved for alignment
       CDBByte        : array [0..15] of Byte;          // SCSI CDB
       SenseArea      : array [0..SENSE_LEN+1] of Byte; // Request Sense buffer
     end;

     PSRB_ExecSCSICmd = ^SRB_ExecSCSICmd;
     TSRB_ExecSCSICmd = SRB_ExecSCSICmd;

     { SRB - ABORT AN SRB - SC_ABORT_SRB ------------------------------------- }
     SRB_Abort = record
       SRB_Cmd      : Byte;            // ASPI command code = SC_EXEC_SCSI_CMD
       SRB_Status   : Byte;            // ASPI command status byte
       SRB_HaId     : Byte;            // ASPI host adapter number
       SRB_Flags    : Byte;            // Reserved
       SRB_Hdr_Rsvd : DWORD;           // Reserved
       SRB_ToAbort  : Pointer;         // Pointer to SRB to abort
     end;

     PSRB_Abort = ^SRB_Abort;
     TSRB_Abort = SRB_Abort;

     { SRB - BUS DEVICE RESET - SC_RESET_DEV --------------------------------- }
     SRB_BusDeviceReset = record
       SRB_Cmd      : Byte;                  // ASPI command code = SC_EXEC_SCSI_CMD
       SRB_Status   : Byte;                  // ASPI command status byte
       SRB_HaId     : Byte;                  // ASPI host adapter number
       SRB_Flags    : Byte;                  // Reserved
       SRB_Hdr_Rsvd : DWORD;                 // Reserved
       SRB_Target   : Byte;                  // Target's SCSI ID
       SRB_Lun      : Byte;                  // Target's LUN number
       SRB_Rsvd1    : array [0..11] of Byte; // Reserved for Alignment
       SRB_HaStat   : Byte;                  // Host Adapter Status
       SRB_TargStat : Byte;                  // Target Status
       SRB_PostProc : Pointer;	             // Post routine
       SRB_Rsvd2    : Pointer;	             // Reserved
       SRB_Rsvd3    : array[0..15] of Byte;  // Reserved
       CDBByte      : array[0..15] of Byte;  // SCSI CDB  end;
     end;

     PSRB_BusDeviceReset = ^SRB_BusDeviceReset;
     TSRB_BusDeviceReset = SRB_BusDeviceReset;

     { SRB - GET DISK INFORMATION - SC_GET_DISK_INFO ------------------------- }
     SRB_GetDiskInfo = record
       SRB_Cmd             : Byte;     // ASPI command code = SC_EXEC_SCSI_CMD
       SRB_Status          : Byte;     // ASPI command status byte
       SRB_HaId            : Byte;     // ASPI host adapter number
       SRB_Flags           : Byte;     // Reserved
       SRB_Hdr_Rsvd        : DWORD;    // Reserved
       SRB_Target          : Byte;     // Target's SCSI ID
       SRB_Lun             : Byte;     // Target's LUN number
       SRB_DriveFlags      : Byte;     // Driver flags
       SRB_Int13HDriveInfo : Byte;     // Host Adapter Status
       SRB_Heads           : Byte;     // Preferred number of heads translation
       SRB_Sectors         : Byte;     // Preferred number of sectors translation
       SRB_Rsvd1           : array[0..9] of Byte; // Reserved
     end;

     PSRB_GetDiskInfo = ^SRB_GetDiskInfo;
     TSRB_GetDiskInfo = SRB_GetDiskInfo;

implementation

end.