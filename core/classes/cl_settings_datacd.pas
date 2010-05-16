{ $Id: cl_settings_datacd.pas,v 1.1 2010/05/16 15:25:38 kerberos002 Exp $

  cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_settings_datacd.pas: Objekt für Einstellungen für Projekt Daten-CD

  Copyright (c) 2004-2010 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  15.05.2010

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_settings_datacd.pas implemtiert ein Objekt für die Einstellungen des
  Projektes Daten-CD/DVD.

    Achtung: Nach dem Laden muß OnTheFly in Abhängigkeit einiger FileFlags
             gesetzt werden!


  TSettingsDataCD

    Properties                 PathListName: string
                               ShCmdName   : string
                               IsoPath     : string
                               OnTheFly    : Boolean
                               ImageOnly   : Boolean
                               KeepImage   : Boolean
                               ContinueCD  : Boolean
                               Verify      : Boolean
                               Joliet      : Boolean
                               JolietLong  : Boolean
                               RockRidge   : Boolean
                               RationalRock: Boolean
                               ISO31Chars  : Boolean
                               ISOLevel    : Boolean
                               ISOLevelNr  : Integer
                               ISOOutChar  : Integer
                               ISOInChar   : Integer
                               ISO37Chars  : Boolean
                               ISONoDot    : Boolean
                               ISOStartDot : Boolean
                               ISOMultiDot : Boolean
                               ISOASCII    : Boolean
                               ISOLower    : Boolean
                               ISONoTrans  : Boolean
                               ISODeepDir  : Boolean
                               ISONoVer    : Boolean
                               UDF         : Boolean
                               Boot        : Boolean
                               BootImage   : string
                               BootCatHide : Boolean
                               BootBinHide : Boolean
                               BootNoEmul  : Boolean
                               BootInfTable: Boolean
                               BootSegAdr  : string
                               BootLoadSize: string
                               VolId       : string
                               MsInfo      : string
                               SelectSess  : Boolean
                               FindDups    : Boolean
                               TransTBL    : Boolean
                               HideTransTBL: Boolean
                               NLPathTBL   : Boolean
                               HideRRMoved : Boolean
                               ForceMSRR   : Boolean
                               UseMeta     : Boolean
                               IDPublisher : string
                               IDPreparer  : string
                               IDCopyright : string
                               IDSystem    : string
                               Device      : string
                               Speed       : string
                               Multi       : Boolean
                               LastSession : Boolean
                               DAO         : Boolean
                               TAO         : Boolean
                               RAW         : Boolean
                               RAWMode     : string
                               Overburn    : Boolean

    Methoden     Init
                 Load(MIF: TMemIniFile)
                 Save(MIF: TMemIniFile)
                 GetMaxFileNameLength: Byte

}

unit cl_settings_datacd;

interface

uses Classes, SysUtils, IniFiles, cl_abstractbase;

type TSettingsDataCD = class(TCdrtfeSettings)
     private
       {allgemeine Einstellungen}
       FPathListName: string;
       FShCmdName   : string;
       FIsoPath     : string;
       FOnTheFly    : Boolean;
       FImageOnly   : Boolean;
       FKeepImage   : Boolean;
       FContinueCD  : Boolean;
       FVerify      : Boolean;
       {Einstellungen: mkisofs}
       FJoliet      : Boolean;
       FJolietLong  : Boolean;
       FRockRidge   : Boolean;   // -R -rock
       FRationalRock: Boolean;   // -r -rational-rock
       FISO31Chars  : Boolean;   // -l
       FISOLevel    : Boolean;
       FISOLevelNr  : Integer;   // 1 - 4; 0 = keine Angabe
       FISOOutChar  : Integer;   // -1 = keine Auswahl, sonst Index
       FISOInChar   : Integer;
       FISO37Chars  : Boolean;   // -max-iso-filenames
       FISONoDot    : Boolean;   // -d
       FISOStartDot : Boolean;   // -L -> mkisofs 2.01a32: -allow-leading-dots
       FISOMultiDot : Boolean;   // -allow-multidot
       FISOASCII    : Boolean;   // -relaxed-filenames
       FISOLower    : Boolean;   // -allow-lowercase
       FISONoTrans  : Boolean;   // -no-iso-translate
       FISODeepDir  : Boolean;   // -D
       FISONoVer    : Boolean;   // -N
       FUDF         : Boolean;
       FBoot        : Boolean;
       FBootImage   : string;
       FBootCatHide : Boolean;
       FBootBinHide : Boolean;
       FBootNoEmul  : Boolean;
       FBootInfTable: Boolean;
       FBootSegAdr  : string;
       FBootLoadSize: string;
       FVolId       : string;
       FMsInfo      : string;    // MS-Info, wenn vom User gewählt!
       FSelectSess  : Boolean;
       FFindDups    : Boolean;
       FTransTBL    : Boolean;
       FHideTransTBL: Boolean;
       FNLPathTBL   : Boolean;
       FHideRRMoved : Boolean;
       FForceMSRR   : Boolean;
       {Meta-Daten}
       FUseMeta     : Boolean;
       FIDPublisher : string;
       FIDPreparer  : string;
       FIDCopyright : string;
       FIDSystem    : string;
       {Einstellungen: cdrecord}
       FDevice      : string;
       FSpeed       : string;
       FMulti       : Boolean;
       FLastSession : Boolean;
       FDAO         : Boolean;
       FTAO         : Boolean;
       FRAW         : Boolean;
       FRAWMode     : string;
       FOverburn    : Boolean;
     public
       constructor Create;
       destructor Destroy; override;
       function GetMaxFileNameLength: Byte;
       procedure Init; override;
       procedure Load(MIF: TMemIniFile); override;
       procedure Save(MIF: TMemIniFile); override;
       {allgemeine Einstellungen}
       property PathListName: string read FPathListName write FPathListName;
       property ShCmdName   : string read FShCmdName write FShCmdName;
       property IsoPath     : string read FIsoPath write FIsoPath;
       property OnTheFly    : Boolean read FOnTheFly write FOnTheFly;
       property ImageOnly   : Boolean read FImageOnly write FImageOnly;
       property KeepImage   : Boolean read FKeepImage write FKeepImage;
       property ContinueCD  : Boolean read FContinueCD write FContinueCD;
       property Verify      : Boolean read FVerify write FVerify;
       {Einstellungen: mkisofs}
       property Joliet      : Boolean read FJoliet write FJoliet;
       property JolietLong  : Boolean read FJolietLong write FJolietLong;
       property RockRidge   : Boolean read FRockRidge write FRockRidge;
       property RationalRock: Boolean read FRationalRock write FRationalRock;
       property ISO31Chars  : Boolean read FISO31Chars write FISO31Chars;
       property ISOLevel    : Boolean read FISOLevel write FISOLevel;
       property ISOLevelNr  : Integer read FISOLevelNr write FISOLevelNr;
       property ISOOutChar  : Integer read FISOOutChar write FISOOutChar;
       property ISOInChar   : Integer read FISOInChar write FISOInChar;
       property ISO37Chars  : Boolean read FISO37Chars write FISO37Chars;
       property ISONoDot    : Boolean read FISONoDot write FISONoDot;
       property ISOStartDot : Boolean read FISOStartDot write FISOStartDot;
       property ISOMultiDot : Boolean read FISOMultiDot write FISOMultiDot;
       property ISOASCII    : Boolean read FISOASCII write FISOASCII;
       property ISOLower    : Boolean read FISOLower write FISOLower;
       property ISONoTrans  : Boolean read FISONoTrans write FISONoTrans;
       property ISODeepDir  : Boolean read FISODeepDir write FISODeepDir;
       property ISONoVer    : Boolean read FISONoVer write FISONoVer;
       property UDF         : Boolean read FUDF write FUDF;
       property Boot        : Boolean read FBoot write FBoot;
       property BootImage   : string read FBootImage write FBootImage;
       property BootCatHide : Boolean read FBootCatHide write FBootCatHide;
       property BootBinHide : Boolean read FBootBinHide write FBootBinHide;
       property BootNoEmul  : Boolean read FBootNoEmul write FBootNoEmul;
       property BootInfTable: Boolean read FBootInfTable write FBootInfTable;
       property BootSegAdr  : string read FBootSegAdr write FBootSegAdr;
       property BootLoadSize: string read FBootLoadSize write FBootLoadSize;
       property VolId       : string read FVolId write FVolId;
       property MsInfo      : string read FMsInfo write FMsInfo;
       property SelectSess  : Boolean read FSelectSess write FSelectSess;
       property FindDups    : Boolean read FFindDups write FFindDups;
       property TransTBL    : Boolean read FTransTBL write FTransTBL;
       property HideTransTBL: Boolean read FHideTransTBL write FHideTransTBL;
       property NLPathTBL   : Boolean read FNLPathTBL write FNLPathTBL;
       property HideRRMoved : Boolean read FHideRRMoved write FHideRRMoved;
       property ForceMSRR   : Boolean read FForceMSRR write FForceMSRR;
       {Meta-Daten}
       property UseMeta     : Boolean read FUseMeta write FUseMeta;
       property IDPublisher : string read FIDPublisher write FIDPublisher;
       property IDPreparer  : string read FIDPreparer write FIDPreparer;
       property IDCopyright : string read FIDCopyright write FIDCopyright;
       property IDSystem    : string read FIDSystem write FIDSystem;
       {Einstellungen: cdrecord}
       property Device      : string read FDevice write FDevice;
       property Speed       : string read FSpeed write FSpeed;
       property Multi       : Boolean read FMulti write FMulti;
       property LastSession : Boolean read FLastSession write FLastSession;
       property DAO         : Boolean read FDAO write FDAO;
       property TAO         : Boolean read FTAO write FTAO;
       property RAW         : Boolean read FRAW write FRAW;
       property RAWMode     : string read FRAWMode write FRAWMode;
       property Overburn    : Boolean read FOverburn write FOverburn;
     end;

implementation


{ TSettingsDataCD ------------------------------------------------------------ }

{ TSettingsDataCD - private }

{ TSettingsDataCD - public }

constructor TSettingsDataCD.Create;
begin
  inherited Create;
  Init;
end;

destructor TSettingsDataCD.Destroy;
begin
  inherited Destroy;
end;

{ Init -------------------------------------------------------------------------

  Alle Variablen initialisieren und auf Standardwerte setzen.                  }

procedure TSettingsDataCD.Init;
begin
  {allgemeine Einstellungen}
  FPathListName := '';
  FShCmdName    := '';
  FIsoPath      := '';
  FOnTheFly     := False;
  FImageOnly    := False;
  FKeepImage    := False;
  FContinueCD   := False;
  FVerify       := False;
  {Einstellungen: mkisofs}
  FJoliet       := True;
  FJolietLong   := False;
  FRockRidge    := False;
  FRationalRock := True;
  FISO31Chars   := False;
  FISOLevel     := False;
  FISOLevelNr   := 0;
  FISOOutChar   := -1;
  FISOInChar    := -1;
  FISO37Chars   := False;
  FISONoDot     := False;
  FISOStartDot  := False;
  FISOMultiDot  := False;
  FISOASCII     := False;
  FISOLower     := False;
  FISONoTrans   := False;
  FISODeepDir   := False;
  FISONoVer     := False;
  FUDF          := False;
  FBoot         := False;
  FBootImage    := '';
  FBootCatHide  := False;
  FBootBinHide  := False;
  FBootNoEmul   := False;
  FBootInfTable := False;
  FBootSegAdr   := '';
  FBootLoadSize := '';
  FVolId        := '';
  FMsInfo       := '';
  FSelectSess   := False;
  FFindDups     := False;
  FTransTBL     := False;
  FHideTransTBL := True;
  FNLPathTBL    := False;
  FHideRRMoved  := False;
  FForceMSRR    := True;
  {Meta-Daten}
  FUseMeta      := False;
  FIDPublisher  := '';
  FIDPreparer   := '';
  FIDCopyright  := '';
  FIDSystem     := '';
  {Einstellungen: cdrecord}
  FDevice       := '';
  FSpeed        := '';
  FMulti        := False;
  FLastSession  := False;
  FDAO          := False;
  FTAO          := True;
  FRAW          := False;
  FRAWMode      := 'raw96r';
  FOverburn     := False;
end;

{ Load -------------------------------------------------------------------------

  Variablen aus der Ini- bzw. cfp-Datei laden.                                 }

procedure TSettingsDataCD.Load(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Data-CD';
  with MIF do
  begin
    {allgemeine Einstellungen}
    FIsoPath := ReadString(Section, 'IsoPath', '');
    FOnTheFly := ReadBool(Section, 'OnTheFly', False);  // and
                // (FileFlags.ShOk or not FileFlags.ShNeeded);
    FImageOnly := ReadBool(Section, 'ImageOnly', False);
    FKeepImage := ReadBool(Section, 'KeepImage', False);
    FContinueCD := ReadBool(Section, 'ContinueCD', False);
    FVerify := ReadBool(Section, 'Verify', False);
    {Einstellungen: mkisofs}
    FJoliet := ReadBool(Section, 'Joliet', True);
    FJolietLong := ReadBool(Section, 'JolietLong', False);
    FRockRidge := ReadBool(Section, 'RockRidge', False);
    FRationalRock := ReadBool(Section, 'RationalRock', True);
    FISO31Chars := ReadBool(Section, 'ISO31Chars', False);
    FISOLevel := ReadBool(Section, 'ISOLevel', False);
    FISOLevelNr := ReadInteger(Section, 'ISOLevelNr', 0);
    FISOOutChar := ReadInteger(Section, 'ISOOutChar', -1);
    FISOInChar := ReadInteger(Section, 'ISOInChar', -1);
    FISO37Chars := ReadBool(Section, 'ISO37Chars', False);
    FISONoDot := ReadBool(Section, 'ISONoDot', False);
    FISOStartDot := ReadBool(Section, 'ISOStartDot', False);
    FISOMultiDot := ReadBool(Section, 'ISOMultiDot', False);
    FISOASCII := ReadBool(Section, 'ISOASCII', False);
    FISOLower := ReadBool(Section, 'ISOLower', False);
    FISONoTrans := ReadBool(Section, 'ISONoTrans', False);
    FISODeepDir := ReadBool(Section, 'ISODeepDir', False);
    FISONoVer := ReadBool(Section, 'ISONoVer', False);
    FUDF := ReadBool(Section, 'UDF', False);
    FBoot := ReadBool(Section, 'Boot', False);
    FBootImage := ReadString(Section, 'BootImage', '');
    FBootCatHide := ReadBool(Section, 'BootCatHide', False);
    FBootBinHide := ReadBool(Section, 'BootBinHide', False);
    FBootNoEmul := ReadBool(Section, 'BootNoEmul', False);
    FBootInfTable := ReadBool(Section, 'BootInfTable', False);
    FBootSegAdr := ReadString(Section, 'BootSegAdr', '');
    FBootLoadSize := ReadString(Section, 'BootLoadSize', '');
    FVolId := ReadString(Section, 'VolId', '');
    FFindDups := ReadBool(Section, 'FindDups', False);
    FTransTBL := ReadBool(Section, 'TransTBL', False);
    FHideTransTBL := ReadBool(Section, 'HideTransTBL', True);
    FNLPathTBL := ReadBool(Section, 'NLPathTBL', False);
    FHideRRMoved := ReadBool(Section, 'HideRRMoved', False);
    FSelectSess := ReadBool(Section, 'SelectSess', False);
    FForceMSRR := ReadBool(Section, 'ForceMSRR', True);
    {Meta-Daten}
    FUseMeta := ReadBool(Section, 'UseMeta', False);
    FIDPublisher := ReadString(Section, 'Publisher', '');
    FIDPreparer := ReadString(Section, 'Preparer', '');
    FIDCopyright := ReadString(Section, 'Copyright', '');
    FIDSystem := ReadString(Section, 'System', '');
    {Einstellungen: cdrecord}
    FDevice := ReadString(Section, 'Device', '');
    FSpeed := ReadString(Section, 'Speed', '');
    FMulti := ReadBool(Section, 'Multi', False);
    FDAO := ReadBool(Section, 'DAO', False);
    FTAO := ReadBool(Section, 'TAO', True);
    FRAW := ReadBool(Section, 'RAW', False);
    FRAWMode := ReadString(Section, 'RAWMode', 'raw96r');
    FOverburn := ReadBool(Section, 'Overburn', False);
  end;
end;

{ Save -------------------------------------------------------------------------

  Variablen in einer Ini- bzw. cfp-Datei speichern.                            }

procedure TSettingsDataCD.Save(MIF: TMemIniFile);
var Section: string;
begin
  Section := 'Data-CD';
  with MIF do
  begin
    {allgemeine Einstellungen}
    WriteString(Section, 'IsoPath', FIsoPath);
    WriteBool(Section, 'OnTheFly', FOnTheFly);
    WriteBool(Section, 'ImageOnly', FImageOnly);
    WriteBool(Section, 'KeepImage', FKeepImage);
    WriteBool(Section, 'ContinueCD', FContinueCD);
    WriteBool(Section, 'Verify', FVerify);
    {Einstellungen: mkisofs}
    WriteBool(Section, 'Joliet', FJoliet);
    WriteBool(Section, 'JolietLong', FJolietLong);
    WriteBool(Section, 'RockRidge', FRockRidge);
    WriteBool(Section, 'RationalRock', FRationalRock);
    WriteBool(Section, 'ISO31Chars', FISO31Chars);
    WriteBool(Section, 'ISOLevel', FISOLevel);
    WriteInteger(Section, 'ISOLevelNr', FISOLevelNr);
    WriteInteger(Section, 'ISOOutChar', FISOOutChar);
    WriteInteger(Section, 'ISOInChar', FISOInChar);
    WriteBool(Section, 'ISO37Chars', FISO37Chars);
    WriteBool(Section, 'ISONoDot', FISONoDot);
    WriteBool(Section, 'ISOStartDot', FISOStartDot);
    WriteBool(Section, 'ISOMultiDot', FISOMultiDot);
    WriteBool(Section, 'ISOASCII', FISOASCII);
    WriteBool(Section, 'ISOLower', FISOLower);
    WriteBool(Section, 'ISONoTrans', FISONoTrans);
    WriteBool(Section, 'ISODeepDir', FISODeepDir);
    WriteBool(Section, 'ISONoVer', FISONoVer);
    WriteBool(Section, 'UDF', FUDF);
    WriteBool(Section, 'Boot', FBoot);
    WriteString(Section, 'BootImage', FBootImage);
    WriteBool(Section, 'BootCatHide', FBootCatHide);
    WriteBool(Section, 'BootBinHide', FBootBinHide);
    WriteBool(Section, 'BootNoEmul', FBootNoEmul);
    WriteBool(Section, 'BootInfTable', FBootInfTable);
    WriteString(Section, 'BootSegAdr', FBootSegAdr);
    WriteString(Section, 'BootLoadSize', FBootLoadSize);
    WriteString(Section, 'VolId', FVolId);
    WriteBool(Section, 'FindDups', FFindDups);
    WriteBool(Section, 'TransTBL', FTransTBL);
    WriteBool(Section, 'HideTransTBL', FHideTransTBL);
    WriteBool(Section, 'NLPathTBL', FNLPathTBL);
    WriteBool(Section, 'HideRRMoved', FHideRRMoved);
    WriteBool(Section, 'SelectSess', FSelectSess);
    WriteBool(Section, 'ForceMSRR', FForceMSRR);
    {Meta-Daten}
    WriteBool(Section, 'UseMeta', FUseMeta);
    WriteString(Section, 'Publisher', FIDPublisher);
    WriteString(Section, 'Preparer', FIDPreparer);
    WriteString(Section, 'Copyright', FIDCopyright);
    WriteString(Section, 'System', FIDSystem);
    {Einstellungen: cdrecord}
    WriteString(Section, 'Device', FDevice);
    WriteString(Section, 'Speed', FSpeed);
    WriteBool(Section, 'Multi', FMulti);
    WriteBool(Section, 'DAO', FDAO);
    WriteBool(Section, 'TAO', FTAO);
    WriteBool(Section, 'RAW', FRAW);
    WriteString(Section, 'RAWMode', FRAWMode);
    WriteBool(Section, 'Overburn', FOverburn);
  end;
end;

{ GetMaxFileNameLength ---------------------------------------------------------

  GetMaxFileNameLength liefert die maximale Länge für Dateinamen in Abhängigkeit
  der aktuellen Dateisystemeinstellungen.                                      }

function TSettingsDataCD.GetMaxFileNameLength: Byte;
begin
  if not FJoliet and not FISOLevel and FUDF then
  begin
    Result := 247;  // UDF
  end else
  if FJoliet and not FJolietLong then
  begin
    Result := 64;   // Joliet
  end else
  if FJoliet and FJolietLong then
  begin
    Result := 103;  // Joliet-long
  end else
  if FISOLevel and (FISOLevelNr = 4) and not FRockRidge then
  begin
    Result := 207;  // ISO9660:1999
  end else
  if FISOLevel and (FISOLevelNr = 4) and FRockRidge then
  begin
    Result := 197;  // ISO9660:1999 + RockRidge
  end else
  if FISO37chars then
  begin
    Result := 37;   // ISO9660 + Allow 37 chars
  end else
  if FISO31chars or (FISOLevel and (FISOLevelNr < 4) and (FISOLevelNr > 1)) then
  begin
    Result := 31;   // ISO9660 Level 2-3 + Allow 31 chars
  end else
  begin
    Result := 12;   // ISO9660 (Level 1), 8.3-Format
  end;
end;

end.


