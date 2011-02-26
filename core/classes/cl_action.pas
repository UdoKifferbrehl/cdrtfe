{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_action.pas: die im GUI gewählte Aktion ausführen

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  26.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_action.pas implementiert ein Objekt, das für das Ausführen der im GUI aus-
  gwählten Aktion zuständig ist.


  TCDAction

    Properties   Action
                 Data
                 Devices
                 FormHandle
                 Lang
                 OnMessageShow
                 OnUpdatePanels
                 ProgressBar
                 Reload
                 Settings
                 StatusBar

    Methoden     CleanUp
                 Create
                 StartAction

}

unit cl_action;

{$I directives.inc}

interface

uses cl_settings, cl_projectdata, cl_lang, cl_diskinfo, cl_devices,
     cl_abstractbaseaction, cl_action_datacd, cl_action_audiocd, cl_action_xcd,
     cl_action_erase, cl_action_cdinfo, cl_action_daereadtoc,
     cl_action_daegrabtracks, cl_action_image, cl_action_videocd,
     cl_action_dvdvideo, cl_action_fixate;

const cCACount = 11;

type TCDAction = class(TCdrtfeAction)
     private
       {CdrtfeAction-Objekte}
       FCADataCD       : TCdrtfeActionDataCD;
       FCAAudioCD      : TCdrtfeActionAudioCD;
       FCAXCD          : TCdrtfeActionXCD;
       FCAErase        : TCdrtfeActionErase;
       FCACDInfo       : TCdrtfeActionCDInfo;
       FCADAEReadTOC   : TCdrtfeActionDAEReadTOC;
       FCADAEGrabTracks: TCdrtfeActionDAEGrabTracks;
       FCAImage        : TCdrtfeActionImage;
       FCAVideoCD      : TCdrtfeActionVideoCD;
       FCADVDVideo     : TCdrtfeActionDVDVideo;
       FCAFixate       : TCdrtfeActionFixate;
       {Array für Objeke}
       FCAArray        : array[1..cCACount] of TCdrtfeAction;
       {aktuelles CdrtfeAction-Objekt}
       FCACurrent      : TCdrtfeAction;
       {weitere Variablen}
       FAction         : Byte;
       FLastAction     : Byte;
       FDiskA          : TDiskInfoA;
       FDiskM          : TDiskInfoM;
       FReload         : Boolean;
       FDupSize        : Int64;
       FSplitOutput    : Boolean;
       FEjectDevice    : string;
       function GetAction: Byte;
       procedure Eject;
       procedure SetCurrentActionObject(const Action: Byte);
       procedure SetEjectDrive;
       procedure SetFDupSize(const Value: Int64);
       procedure SetFReload(const Value: Boolean);
     protected
       procedure SetFSettings(Value: TSettings); override;
     public
       constructor Create;
       destructor Destroy; override;
       procedure AbortAction; override;
       procedure CleanUp(const Phase: Byte); override;
       procedure Init;
       procedure Reset; override;
       procedure StartAction; override;
       property Action: Byte read GetAction write FAction;
       property LastAction: Byte read FLastAction;
       property Reload: Boolean read FReload write SetFReload;
       property DuplicateFileSize: Int64 read FDupSize write SetFDupSize;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}             
     f_dischelper, const_tabsheets;

{ TCDAction ------------------------------------------------------------------ }

{ TCDAction - private }

{ SetCurrentActionObject -------------------------------------------------------

  setzt in Abhängigkeit von Action FCACurrent.                                 }

procedure TCDAction.SetCurrentActionObject(const Action: Byte);
begin
  case Action of
    cDataCD         : FCACurrent := FCADataCD;
    cAudioCD        : FCACurrent := FCAAudioCD;
    cXCD            : FCACurrent := FCAXCD;
    cCDRW           : FCACurrent := FCAErase;
    cCDInfos        : FCACurrent := FCACDInfo;
    cDAE            : FCACurrent := FCADAEGrabTracks;
    cDAEReadTOC     : FCACurrent := FCADAEReadToc;
    cCDImage        : FCACurrent := FCAImage;
    cVideoCD        : FCACurrent := FCAVideoCD;
    cDVDVideo       : FCACurrent := FCADVDVideo;
    cFixCD          : FCACurrent := FCAFixate;
    cVerify         : FCACurrent := FCADataCD;
    cVerifyXCD      : FCACurrent := FCAXCD;
    cFindDuplicates : FCACurrent := FCADataCD;
    cCreateInfoFile : FCACurrent := FCAXCD;
    cVerifyDVDVideo : FCACurrent := FCADVDVideo;
    cVerifyISOImage : FCACurrent := FCAImage;
  end;
end;

{ SetEjectDrive ----------------------------------------------------------------

  setzt in Abhängigkeit von FLastAction das zu öffnende Laufwerk.              }

procedure TCDAction.SetEjectDrive;
begin
  case LastAction of
    cDataCD        : FEjectDevice := FSettings.DataCD.Device;
    cAudioCD       : FEjectDevice := FSettings.AudioCD.Device;
    cXCD           : FEjectDevice := FSettings.XCD.Device;
    cCDImage       : FEjectDevice := FSettings.Image.Device;
    cDVDVideo      : FEjectDevice := FSettings.DVDVideo.Device;
    cVideoCD       : FEjectDevice := FSettings.VideoCD.Device;
    cCDRW          : FEjectDevice := FSettings.CDRW.Device;
    cVerify        : FEjectDevice := FSettings.DataCD.Device;
    cVerifyXCD     : FEjectDevice := FSettings.XCD.Device;
    cVerifyDVDVideo: FEjectDevice := FSettings.DVDVideo.Device;
    cVerifyISOImage: FEjectDevice := FSettings.Image.Device;
  end;
end;

{ SetFDupSize ------------------------------------------------------------------

  setzt die Eigenschaft DuplicateFileSize für FCADataCD.                       }

procedure TCDAction.SetFDupSize(const Value: Int64);
begin
  FDupSize := Value;
  FCADataCD.DuplicateFileSize := Value;
end;

{ SetFReload -------------------------------------------------------------------

  setzt die Eigenschaft Reload für die Unterobjekte.                           }

procedure TCDAction.SetFReload(const Value: Boolean);
begin
  FReload := Value;
  FCADataCD.Reload := FReload;
  FCAXCD.Reload := FReload;
  FCADVDVideo.Reload := FReload;
  FCAImage.Reload := FReload;
end;

{ SetFSettings -----------------------------------------------------------------

  setzt die Eigenschaft Settings und die Feldvariable FDisk in Abhängigkeit der
  Daten in FSettings.                                                          }

procedure TCDAction.SetFSettings(Value: TSettings);
begin
  inherited SetFSettings(Value);
  case FSettings.Cdrecord.HaveMediaInfo of
    True : FDisk := FDiskM;
    False: FDisk := FDiskA;
  end;
end;

{ GetAction --------------------------------------------------------------------

  GetAction liefert den Wert von FAction und setzt ihn auf cNoAction.          }

function TCDAction.GetAction: Byte;
begin
  Result := FAction;
  FLastAction := FAction;
  FAction := cNoAction;
end;

{ Eject ------------------------------------------------------------------------

  wirft, falls gewünscht, die CD/DVD aus.                                      }

procedure TCDAction.Eject;
begin
  if FSettings.Cdrecord.Eject and not FSettings.Cdrecord.Dummy then
  begin
    {Wenn nur ein Image erstellt wurde, bleibt das Laufwerk zu.}
    if ((FLastAction = cDataCD) and FSettings.DataCD.ImageOnly) or
       ((FLastAction = cXCD) and FSettings.XCD.ImageOnly) or
       ((FLAstAction = cVIdeoCD) and FSettings.VideoCD.ImageOnly) then
      FEjectDevice := '';
    if FEjectDevice <> '' then EjectDisk(FEjectDevice);
  end;
  FEjectDevice := '';
end;

{ TCDAction - public }

constructor TCDAction.Create;
begin
  inherited Create;
  {CdrtfeAction-Objekte}
  FCADataCD        := TCdrtfeActionDataCD.Create;
  FCAAudioCD       := TCdrtfeActionAudioCD.Create;
  FCAXCD           := TCdrtfeActionXCD.Create;
  FCAErase         := TCdrtfeActionErase.Create;
  FCACDInfo        := TCdrtfeActionCDInfo.Create;
  FCADAEReadTOC    := TCdrtfeActionDAEReadTOC.Create;
  FCADAEGrabTracks := TCdrtfeActionDAEGrabTracks.Create;
  FCAImage         := TCdrtfeActionImage.Create;
  FCAVideoCD       := TCdrtfeActionVideoCD.Create;
  FCADVDVideo      := TCdrtfeActionDVDVideo.Create;
  FCAFixate        := TCdrtfeActionFixate.Create;
  {CdrtfeAction-Array}
  FCAArray[1]  := FCADataCD;
  FCAArray[2]  := FCAAudioCD;
  FCAArray[3]  := FCAXCD;
  FCAArray[4]  := FCAErase;
  FCAArray[5]  := FCACDInfo;
  FCAArray[6]  := FCADAEReadTOC;
  FCAArray[7]  := FCADAEGrabTracks;
  FCAArray[8]  := FCAImage;
  FCAArray[9]  := FCAVideoCD;
  FCAArray[10] := FCADVDVideo;
  FCAArray[11] := FCAFixate;
  {Felder}
  FAction := cNoAction;
  FLastAction := cNoAction;
  FReload := True;
  FDupSize := 0;
  FSplitOutput := False;
  FEjectDevice := '';
  {DiskInfo-Object}
  FDiskA := TDiskInfoA.Create;
  FDiskM := TDiskInfoM.Create;
  FDisk := FDiskA;
end;

destructor TCDAction.Destroy;
var i: Integer;
begin
  for i := 1 to cCACount do FCAArray[i].Free;
  FDiskA.Free;
  FDiskM.Free;
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Init reicht die Properties an die Unterobjekte weiter.                       }

procedure TCDAction.Init;
var i: Integer;
begin
  for i := 1 to cCACount do
  begin
    FCAArray[i].FormHandle     := FFormHandle;
    FCAArray[i].StatusBar      := FStatusBar;
    FCAArray[i].ProgressBar    := FProgressBar;
    FCAArray[i].OnMessageShow  := FOnMessageShow;
    FCAArray[i].OnUpdatePanels := FOnUpdatePanels;
    FCAArray[i].Data           := FData;
    FCAArray[i].Devices        := FDevices;
    FCAArray[i].Lang           := FLang;
    FCAArray[i].Settings       := FSettings;
    FCAArray[i].DiskInfo       := FDisk;
  end;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCDAction.StartAction;
var TempAction: Byte;
begin
  TempAction := Action;
  SetCurrentActionObject(TempAction);
  case TempAction of
    cDataCD,
    cAudioCD,
    cXCD,
    cCDRW,
    cCDInfos,
    cDAE,
    cCDImage,
    cVideoCD,
    cDVDVideo,
    cDAEReadTOC,
    cFixCD         : FCACurrent.StartAction;
    cVerify        : (FCACurrent as TCdrtfeActionDataCD).StartVerification;
    cVerifyXCD     : (FCACurrent as TCdrtfeActionXCD).StartVerification;
    cVerifyDVDVideo: (FCACurrent as TCdrtfeActionDVDVideo).StartVerification;
    cVerifyISOImage: (FCACurrent as TCdrtfeActionImage).StartVerification;
  end;
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCDAction.AbortAction;
begin
  FCACurrent.AbortAction;
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCDAction.Reset;
var i: Integer;
begin
  for i := 1 to cCACount do FCAArray[i].Reset;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCDAction.CleanUp(const Phase: Byte);
begin
  FCACurrent.CleanUp(Phase);
  if Phase = 3 then
  begin
    SetEjectDrive;
    Eject;
    FLastAction := cNoAction;
  end;
end;

end.
