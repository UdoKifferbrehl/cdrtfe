{ spti.pas: SPTI and IOCTL definitions

  letzte Änderung  04.01.2012

}

unit spti;

{$I compiler.inc}

interface
uses Windows;

{$IFDEF Delphi7Up}
{$A4}
{$ENDIF}

{ Typ-Deklaration ------------------------------------------------------------ }

type SCSI_PASS_THROUGH = record
       Length             : Word;
       ScsiStatus         : Byte;
       PathId             : Byte;
       TargetId           : Byte;
       Lun                : Byte;
       CdbLength          : Byte;
       SenseInfoLength    : Byte;
       DataIn             : Byte;
       DataTransferLength : ULONG;
       TimeOutValue       : ULONG;
       DataBufferOffset   : ULONG;
       SenseInfoOffset    : ULONG;
       Cdb                : array[0..16 - 1] of Byte;
     end;

     PSCSI_PASS_THROUGH = ^SCSI_PASS_THROUGH;

     PVOID = Pointer;

     SCSI_PASS_THROUGH_DIRECT = record
       Length             : Word;
       ScsiStatus         : Byte;
       PathId             : Byte;
       TargetId           : Byte;
       Lun                : Byte;
       CdbLength          : Byte;
       SenseInfoLength    : Byte;
       DataIn             : Byte;
       DataTransferLength : ULONG;
       TimeOutValue       : ULONG;
       DataBuffer         : PVOID;
       SenseInfoOffset    : ULONG;
       Cdb                : array[0..16 - 1] of Byte;
     end;

     PSCSI_PASS_THROUGH_DIRECT = ^SCSI_PASS_THROUGH_DIRECT;

     SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER = record
       spt                : SCSI_PASS_THROUGH_DIRECT;
       Filler             : ULONG;
       ucSenseBuf         : array[0..32 - 1] of Byte;
     end;

     PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER = ^SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;

     SCSI_ADDRESS = record
       Length     : LongInt;
       PortNumber : Byte;
       PathId     : Byte;
       TargetId   : Byte;
       Lun        : Byte;
     end;

     PSCSI_ADDRESS = ^SCSI_ADDRESS;

     SCSI_BUS_DATA = record
       NumberOfLogicalUnits: Byte;
       InitiatorBusId      : Byte;
       InquiryDataOffset   : Cardinal;
     end;

     SCSI_ADAPTER_BUS_INFO = record
       NumberOfBusses: Byte;
       BusData       : SCSI_BUS_DATA;
     end;

     PSCSI_ADAPTER_BUS_INFO = ^SCSI_ADAPTER_BUS_INFO;

     STORAGE_QUERY_TYPE = (PropertyStandardQuery = 0,
                           PropertyExistsQuery,
                           PropertyMaskQuery,
                           PropertyQueryMaxDefined);

     STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0,
                            StorageAdapterProperty);

     STORAGE_PROPERTY_QUERY = packed record
       PropertyId          : STORAGE_PROPERTY_ID;
       QueryType           : STORAGE_QUERY_TYPE;
       AdditionalParameters: array[0..9] of AnsiChar;
     end;

     STORAGE_BUS_TYPE = (BusTypeUnknown = 0,
                         BusTypeScsi,
                         BusTypeAtapi,
                         BusTypeAta,
                         BusType1394,
                         BusTypeSsa,
                         BusTypeFibre,
                         BusTypeUsb,
                         BusTypeRAID,
                         BusTypeiScsi,
                         BusTypeSas,
                         BusTypeSata,
                         BusTypeMaxReserved = $7F);

     STORAGE_DEVICE_DESCRIPTOR = packed record
       Version              : DWORD;
       Size                 : DWORD;
       DeviceType           : Byte;
       DeviceTypeModifier   : Byte;
       RemovableMedia       : Boolean;
       CommandQueueing      : Boolean;
       VendorIdOffset       : DWORD;
       ProductIdOffset      : DWORD;
       ProductRevisionOffset: DWORD;
       SerialNumberOffset   : DWORD;
       BusType              : STORAGE_BUS_TYPE;
       RawPropertiesLength  : DWORD;
       RawDeviceProperties  : array[0..0] of AnsiChar;
     end;


{ Konstanten-Deklaration ----------------------------------------------------- }

const { Method constants ----------------------------------------------------- }
      METHOD_BUFFERED = 0;
      METHOD_IN_DIRECT = 1;
      METHOD_OUT_DIRECT = 2;
      METHOD_NEITHER = 3;

      { File access values --------------------------------------------------- }
      FILE_ANY_ACCESS = 0;
      FILE_READ_ACCESS = $0001;
      FILE_WRITE_ACCESS = $0002;
      IOCTL_CDROM_BASE = $00000002;
      IOCTL_SCSI_BASE = $00000004;

      { constants for DataIn member of SCSI_PASS_THROUGH structures ---------- }
      SCSI_IOCTL_DATA_OUT = 0;
      SCSI_IOCTL_DATA_IN = 1;
      SCSI_IOCTL_DATA_UNSPECIFIED = 2;

      { Standard IOCTL codes ------------------------------------------------- }
      IOCTL_CDROM_READ_TOC = $24000;
      IOCTL_CDROM_GET_LAST_SESSION = $24038;
      IOCTL_SCSI_PASS_THROUGH = $4D004;
      IOCTL_SCSI_MINIPORT = $4D008;
      IOCTL_SCSI_GET_INQUIRY_DATA = $4100C;
      IOCTL_SCSI_GET_CAPABILITIES = $41010;
      IOCTL_SCSI_PASS_THROUGH_DIRECT = $4D014;
      IOCTL_SCSI_GET_ADDRESS = $41018;
      IOCTL_STORAGE_QUERY_PROPERTY = $002D1400;

implementation

end.
