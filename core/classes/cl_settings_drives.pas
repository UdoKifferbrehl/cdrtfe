{ $Id: cl_settings_drives.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_drives.pas: Objekt für Einstellungen RSCSI, Laufwerke

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_drives.pas implemtiert ein Objekt für die Variablen, die Einstel-
  lungen für die Laufwerkszuordnungen/RSCSI steuern.


  TSettingsDrives

    Properties   UseRSCSI           : Boolean
                 Host               : string
                 RemoteDrives       : string
                 RSCSIString        : string
                 LocalDrives        : string
                 AssignManually     : Boolean
                 SCSIInterface      : string

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)    

}

unit cl_settings_drives;

interface

uses IniFiles, cl_abstractbase;

type TSettingsDrives = class(TCdrtfeSettings)
     private
       {Remote-SCSI}
       FUseRSCSI      : Boolean;
       FHost          : string;
       FRemoteDrives  : string;
       FRSCSIString   : string;
       {lokale Laufwerke}
       FLocalDrives   : string;
       FAssignManually: Boolean;
       FSCSIInterface : string;
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       property UseRSCSI      : Boolean read FUseRSCSI write FUseRSCSI;
       property Host          : string read FHost write FHost;
       property RemoteDrives  : string read FRemoteDrives write FRemoteDrives;
       property RSCSIString   : string read FRSCSIString write FRSCSIString;
       property LocalDrives   : string read FLocalDrives write FLocalDrives;
       property AssignManually: Boolean read FAssignManually write FAssignManually;
       property SCSIInterface : string read FSCSIInterface write FSCSIInterface;
     end;

implementation

uses f_helper;

{ TSettingsDrives ------------------------------------------------------------ }

{ TSettingsDrives - private }

{ TSettingsDrives - public }

constructor TSettingsDrives.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsDrives.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsDrives.Init;
begin
  FUseRSCSI       := False;
  FHost           := '';
  FRemoteDrives   := '';
  FRSCSIString    := '';
  FLocalDrives    := '';
  FAssignManually := False;
  FSCSIInterface  := '';
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsDrives.Load(MIF: TMemIniFile);
var Section: string;
begin
  if FAsInifile then
  begin
    Section := 'Drives';
    with MIF do
    begin
      FUseRSCSI := ReadBool(Section, 'UseRSCSI', False);
      FHost := ReadString(Section, 'Host', '');
      FRemoteDrives := ReadString(Section, 'RemoteDrives', '');
      if FUseRSCSI then FRSCSIString := 'REMOTE:' + FHost + ':' else
        FRSCSIString := '';
      FLocalDrives := ReadString(Section, 'LocalDrives', '');
      FAssignManually := ReadBool(Section, 'AssignManually', False);
      FSCSIInterface := ReadString(Section, 'SCSIInterface', '');
      if not FUseRSCSI then SetSCSIInterface(FSCSIInterface);
    end;
    FAsIniFile := False;
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsDrives.Save(MIF: TMemIniFile);
var Section: string;
begin
  if FAsInifile then
  begin
    Section := 'Drives';
    with MIF do
    begin
      WriteBool(Section, 'UseRSCSI', FUseRSCSI);
      WriteString(Section, 'Host', FHost);
      WriteString(Section, 'RemoteDrives', FRemoteDrives);
      WriteString(Section, 'LocalDrives', FLocalDrives);
      WriteBool(Section, 'AssignManually', FAssignManually);
      WriteString(Section, 'SCSIInterface', FSCSIInterface);
    end;
    FAsIniFile := False;
  end;
end;

end.

