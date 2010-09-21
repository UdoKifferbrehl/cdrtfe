{ $Id: cl_settings_cdrecord.pas,v 1.2 2010/09/21 11:26:13 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_cdrecord.pas: Objekt für Einstellungen von cdrecord

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  21.09.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_cdrecord.pas implemtiert ein Objekt für die Einstellungen von
  cdrecord und mkisofs.


  TSettingsCdrecord

    Properties          FixDevice  : string
                        Dummy      : Boolean
                        Eject      : Boolean
                        Verbose    : Boolean
                        Burnfree   : Boolean
                        Audiomaster: Boolean
                        SimulDrv   : Boolean
                        FIFO       : Boolean
                        FIFOSize   : Integer
                        ForceSpeed : Boolean
                        AutoErase  : Boolean
                        Erase      : Boolean
                        AllowFormat: Boolean
                        CdrecordUseCustOpts  : Boolean
                        MkisofsUseCustOpts   : Boolean
                        CdrecordCustOpts     : TStringList
                        MkisofsCustOpts      : TStringList
                        CdrecordCustOptsIndex: Integer
                        MkisofsCustOptsIndex : Integer
                        CanWriteCueImage   : Boolean
                        WritingModeRequired: Boolean
                        DMASpeedCheck      : Boolean
                        HaveMediaInfo      : Boolean
                        HaveNLPathtables   : Boolean
                        HaveHideUDF        : Boolean
                        CanEraseDVDPlusRW  : Boolean
                        HasMultiborder     : Boolean
                        CustDriverOpts     : string

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)    

}

unit cl_settings_cdrecord;

interface

uses Classes, SysUtils, IniFiles, cl_abstractbase;

type TSettingsCdrecord = class(TCdrtfeSettings)
     private
       FFixDevice  : string;  // Laufwerk zum fixieren, nur temporär
       FDummy      : Boolean; // gilt auch für cdrdao
       FEject      : Boolean;
       FVerbose    : Boolean;
       FBurnfree   : Boolean;
       FAudiomaster: Boolean;
       FSimulDrv   : Boolean;
       FFIFO       : Boolean;
       FFIFOSize   : Integer;
       FForceSpeed : Boolean;
       FAutoErase  : Boolean;
       FErase      : Boolean;
       FAllowFormat: Boolean;
       FCustDriverOpts: string;
       {zusätzliche Kommandotzeilenoptionen}
       FCdrecordUseCustOpts  : Boolean;
       FMkisofsUseCustOpts   : Boolean;
       FCdrecordCustOpts     : TStringList;
       FMkisofsCustOpts      : TStringList;
       FCdrecordCustOptsIndex: Integer;
       FMkisofsCustOptsIndex : Integer;
       {Versionsabhängigkeiten}
       FCanWriteCueImage   : Boolean;  // 2.01a24: Cue-Image-Support ausreichend
       FWritingModeRequired: Boolean;  // 2.01a26: -tao|-dao|-raw verpflichtend
       FDMASpeedCheck      : Boolean;  // 2.01a33: DMA-Geschwindigkeitsprüfung
       FHaveMediaInfo      : Boolean;  // 2.01.01a21: -minfo
       FHaveNLPathtables   : Boolean;  // 2.01.01a31: -no-limit-pathtables
       FHaveHideUDF        : Boolean;  // 2.01.01a32: -hide-udf
       FCanEraseDVDPlusRW  : Boolean;  // 2.01.01a37: Löschen von DVD+RW
       FHasMultiborder     : Boolean;  // 2.01.01a50: DVD-R(W) Multiborder
     public
       constructor Create;
       destructor Destroy; override;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;                           
       property FixDevice  : string read FFixDevice write FFixDevice;
       property Dummy      : Boolean read FDummy write FDummy;
       property Eject      : Boolean read FEject write FEject;
       property Verbose    : Boolean read FVerbose write FVerbose;
       property Burnfree   : Boolean read FBurnFree write FBurnfree;
       property Audiomaster: Boolean read FAudiomaster write FAudiomaster;
       property SimulDrv   : Boolean read FSimulDrv write FSimulDrv;
       property FIFO       : Boolean read FFIFO write FFIFO;
       property FIFOSize   : Integer read FFIFOSize write FFIFOSize;
       property ForceSpeed : Boolean read FForceSpeed write FForceSpeed;
       property AutoErase  : Boolean read FAutoErase write FAutoErase;
       property Erase      : Boolean read FErase write FErase;
       property AllowFormat: Boolean read FAllowFormat write FAllowFormat;
       property CustDriverOpts: string read FCustDriverOpts write FCustDriverOpts;
       property CdrecordUseCustOpts  : Boolean read FCdrecordUseCustOpts write FCdrecordUseCustOpts;
       property MkisofsUseCustOpts   : Boolean read FMkisofsUseCustOpts write FMkisofsUseCustOpts;
       property CdrecordCustOpts     : TStringList read FCdrecordCustOpts write FCdrecordCustOpts;
       property MkisofsCustOpts      : TStringList read FMkisofsCustOpts write FMkisofsCustOpts;
       property CdrecordCustOptsIndex: Integer read FCdrecordCustOptsIndex write FCdrecordCustOptsIndex;
       property MkisofsCustOptsIndex : Integer read FMkisofsCustOptsIndex write FMkisofsCustOptsIndex;
       property CanWriteCueImage   : Boolean read FCanWriteCueImage write FCanWriteCueImage;
       property WritingModeRequired: Boolean read FWritingModeRequired write FWritingModeRequired;
       property DMASpeedCheck      : Boolean read FDMASpeedCheck write FDMASpeedCheck;
       property HaveMediaInfo      : Boolean read FHaveMediaInfo write FHaveMediaInfo;
       property HaveNLPathtables   : Boolean read FHaveNLPathtables write FHaveNLPathtables;
       property HaveHideUDF        : Boolean read FHaveHideUDF write FHaveHideUDF;
       property CanEraseDVDPlusRW  : Boolean read FCanEraseDVDPlusRW write FCanEraseDVDPlusRW;
       property HasMultiborder     : Boolean read FHasMultiBorder write FHasMultiBorder;
     end;

implementation


{ TSettingsCdrecord ---------------------------------------------------------- }

{ TSettingsCdrecord - private }

{ TSettingsCdrecord - public }

constructor TSettingsCdrecord.Create;
begin
  inherited Create;
  FCdrecordCustOpts := TStringList.Create;
  FMkisofsCustOpts  := TStringList.Create;
  Init;
end;

destructor TSettingsCdrecord.Destroy;
begin
  FCdrecordCustOpts.Free;
  FMkisofsCustOpts.Free;
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsCdrecord.Init;
begin
  FFixDevice   := '';
  FDummy       := False;
  FEject       := False;
  FVerbose     := True;
  FBurnfree    := True;
  FAudiomaster := False;
  FSimulDrv    := False;
  FFIFO        := False;
  FFIFOSize    := 4;
  FForceSpeed  := False;
  FAutoErase   := False;
  FErase       := False;
  FAllowFormat := False;
  FCustDriverOpts := '';
  FCdrecordUseCustOpts   := False;
  FMkisofsUseCustOpts    := False;
  FCdrecordCustOptsIndex := -1;
  FMkisofsCustOptsIndex  := -1;
  FCanWriteCueImage    := False;
  FWritingModeRequired := False;
  FDMASpeedCheck       := False;
  FHaveMediaInfo       := False;
  FHaveNLPathtables    := False;
  FHaveHideUDF         := False;
  FCanEraseDVDPlusRW   := False;
  FHasMultiborder      := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsCdrecord.Load(MIF: TMemIniFile);
var Section: string;
    i, c   : Integer;
begin
  Section := 'cdrecord';
  with MIF do
  begin
    FDummy := ReadBool(Section, 'Dummy', False);
    FEject := ReadBool(Section, 'Eject', False);
    FVerbose := ReadBool(Section, 'Verbose', False);
    FBurnfree := ReadBool(Section, 'Burnfree', False);
    FAudiomaster := ReadBool(Section, 'Audiomaster', False);
    FSimulDrv := ReadBool(Section, 'SimulDrv', False);
    FFIFO := ReadBool(Section, 'FIFO', False);
    FFIFOSize := ReadInteger(Section, 'FIFOSize', 4);
    FForceSpeed := ReadBool(Section, 'ForceSpeed', False);
    FAutoErase := ReadBool(Section, 'AutoErase', False);
    FAllowFormat := ReadBool(Section, 'AllowFormat', False);
    FCustDriverOpts := ReadString(Section, 'CustDriverOpts', '');
    FCdrecordUseCustOpts := ReadBool(Section, 'CdrecordUseCustOpts', False);
    FCdrecordCustOptsIndex := ReadInteger(Section,
                                          'CdrecordCustOptsIndex', -1);
    c := ReadInteger(Section, 'CdrecordCustOptsCount', 0);
    FCdrecordCustOpts.Clear;
    for i := 0 to c - 1 do
    begin
      FCdrecordCustOpts.Add(ReadString(Section,
                                       'CdrecordCustOpts' + IntToStr(i), ''));
    end;
    FMkisofsUseCustOpts := ReadBool(Section, 'MkisofsUseCustOpts', False);
    FMkisofsCustOptsIndex := ReadInteger(Section,
                                        'MkisofsCustOptsIndex', -1);
    c := ReadInteger(Section, 'MkisofsCustOptsCount', 0);
    FMkisofsCustOpts.Clear;
    for i := 0 to c - 1 do
    begin
      FMkisofsCustOpts.Add(ReadString(Section,
                                     'MkisofsCustOpts' + IntToStr(i), ''));
    end;
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsCdrecord.Save(MIF: TMemIniFile);
var Section: string;
    i      : Integer;
begin
  Section := 'cdrecord';
  with MIF do
  begin
    WriteBool(Section, 'Dummy', FDummy);
    WriteBool(Section, 'Eject', FEject);
    WriteBool(Section, 'Verbose', FVerbose);
    WriteBool(Section, 'Burnfree', FBurnfree);
    WriteBool(Section, 'Audiomaster', FAudiomaster);
    WriteBool(Section, 'SimulDrv', FSimulDrv);
    WriteBool(Section, 'FIFO', FFIFO);
    WriteInteger(Section, 'FIFOSize', FFIFOSize);
    WriteBool(Section, 'ForceSpeed', FForceSpeed);
    WriteBool(Section, 'AutoErase', FAutoErase);
    WriteBool(Section, 'AllowFormat', FAllowFormat);
    WriteString(Section, 'CustDriverOpts', FCustDriverOpts);
    WriteBool(Section, 'CdrecordUseCustOpts', FCdrecordUseCustOpts);
    WriteInteger(Section, 'CdrecordCustOptsIndex', FCdrecordCustOptsIndex);
    WriteInteger(Section, 'CdrecordCustOptsCount', FCdrecordCustOpts.Count);
    for i := 0 to FCdrecordCustOpts.Count - 1 do
    begin
      WriteString(Section, 'CdrecordCustOpts' + IntToStr(i),
                  FCdrecordCustOpts[i]);
    end;
    WriteBool(Section, 'MkisofsUseCustOpts', FMkisofsUseCustOpts);
    WriteInteger(Section, 'MkisofsCustOptsIndex', FMkisofsCustOptsIndex);
    WriteInteger(Section, 'MkisofsCustOptsCount', FMkisofsCustOpts.Count);
    for i := 0 to FMkisofsCustOpts.Count - 1 do
    begin
      WriteString(Section, 'MkisofsCustOpts' + IntToStr(i),
                  FMkisofsCustOpts[i]);
    end;
  end;
end;

end.

