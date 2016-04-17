{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_diskinfo.pas: Zugriff auf Rohlingsinformationen und Medien-Überprüfung

  Copyright (c) 2006-2016 Oliver Valencia

  letzte Änderung  17.04.2016

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_diskinfo.pas implementiert Objekte, die Informationen über Rohlinge er-
  mitteln und testen, ob die gewünschte Schreiboperation möglich ist.


  TDiskInfo

    Properties   Sectors
                 SecFree
                 Size
                 SizeUsed
                 SizeFree
                 Time
                 TimeFree
                 MsInfo
                 IsDVD
                 IsBD
                 DiskType
                 SelectSess
                 SessOverride

    Methoden     Create
                 CheckMedium(var Args: TCheckMediumArgs): Boolean
                 GetDiskInfo(const Device: string; const Audio: Boolean)
                 
}

unit cl_diskinfo;

{$I directives.inc}

interface

uses Windows, Forms, StdCtrls, Controls, SysUtils,
     cl_settings, cl_lang, f_largeint;

const cDiskTypeBlocks: array[0..6, 0..1] of string =
        ((' ', '1024'),                                    // Dummyeintrag
         ('DVD-R(W) [4,38 GiByte]', '2298496'),
         ('DVD+R(W) [4,38 GiByte]', '2295104'),
         ('DVD-R/DL (-R9) [7,96 GiByte]', '4171712'),
         ('DVD+R/DL (+R9) [7,96 GiByte]', '4173824'),
         ('BD-R(E) [23,3 GiByte]', '12219392'),
         ('BD-R(E)/DL [46,6 GiByte]', '24438784'));

type TDiskType = (DT_CD, DT_CD_R, DT_CD_RW, DT_DVD_ROM,
                  DT_DVD_R, DT_DVD_RW, DT_DVD_RDL,
                  DT_DVD_PlusR, DT_DVD_PlusRW, DT_DVD_PlusRDL,
                  DT_BD_ROM, DT_BD_R, DT_BD_RE, DT_BD_R_DL, DT_BD_RE_DL,
                  DT_Unknown,      // unbekannte Disk
                  DT_None,         // keine Disk eingelegt
                  DT_Manual,       // manuelle Auswahl durch User
                  DT_ManualNone);  // Abbruch durch User bei Auswahl

     { TCheckMediumArgs faßt einige Variablen zusammen, die in den verschiedenen
       Prozeduren benötigt werden, damit diese leichter an CheckMedium übergeben
       werden können.}

     TCheckMediumArgs = record
       {allgemein}
       Choice        : Byte;
       {Daten-CD}
       ForcedContinue: Boolean;
       CDSize        : Int64;
       SectorsNeededS: string;
       SectorsNeededI: Integer;
       TaoEndSecCount: Integer;
       {Audio-CD}
       CDTime        : Extended;
     end;

     TDiskInfo = class(TObject)
     private
       FSettings     : TSettings;
       FLang         : TLang;
       FDevice       : string;
       FSectors      : Integer;
       FSecFree      : Integer;
       FSize         : Double;
       FSizeUsed     : Double;
       FSizeFree     : Double;
       FTime         : Double;
       FTimeFree     : Double;
       FMsInfo       : string;
       FIsDVD        : Boolean;
       FIsBD         : Boolean;
       FDiskType     : TDiskType;
       FUseProfiles  : Boolean;
       FForcedFormat : Boolean;
       FFormatCommand: string;
       FSelectSess   : Boolean;
       FSessOverride : string;
       function DiskInserted(const CDInfo: string): Boolean;
       function GetCDType(const CDInfo: string): TDiskType;
       function GetDVDType(const DVDInfo: string): TDiskType; virtual;
       function MediumIsDVD(const CDInfo: string): Boolean;
       function MediumIsBD(const CDInfo: string): Boolean;
       {$IFDEF DebugReadCDInfo}
       procedure DebugShowDiskInfo; virtual;
       {$ENDIF}
       procedure InitDiskInfo; virtual;
     public
       constructor Create;
       function CheckMedium(var Args: TCheckMediumArgs): Boolean; virtual; abstract;
       procedure GetDiskInfo(const Device: string; const Audio: Boolean); virtual; abstract;
       property Sectors      : Integer   read FSectors;
       property SecFree      : Integer   read FSecFree;
       property Size         : Double    read FSize;
       property SizeUsed     : Double    read FSizeUsed;
       property SizeFree     : Double    read FSizeFree;
       property Time         : Double    read FTime;
       property TimeFree     : Double    read FTimeFree;
       property MsInfo       : string    read FMsInfo;
       property IsDVD        : Boolean   read FIsDVD;
       property IsBD         : Boolean   read FIsBD;
       property DiskType     : TDiskType read FDiskType;
       property ForcedFormat : Boolean   read FForcedFormat; // für neue DVD+RWs
       property FormatCommand: string    read FFormatCommand;
       property SelectSess   : Boolean   write FSelectSess;
       property SessOverride : string    write FSessOverride;
     end;

     TDiskInfoA = class(TDiskInfo)
     private
       FAtipInfo: string;
       function DVDSizeInfoFound: Boolean;
       function GetAtipInfo(const vv: Boolean): string;
       function GetDVDType(const DVDInfo: string): TDiskType; override;
       function GetMSInfo: string;
       procedure GetAudioCDTimeFree;
       procedure GetCDInfo;
       procedure GetDVDInfo;
       procedure InitDiskInfo; override;
     public
       function CheckMedium(var Args: TCheckMediumArgs): Boolean; override;
       procedure GetDiskInfo(const Device: string; const Audio: Boolean); override;
     end;

     TDiskInfoM = class(TDiskinfo)
     private
       FMediumInfo    : string;
       FDiskEmpty     : Boolean;
       FDiskComplete  : Boolean;
       FDiskAppendable: Boolean;
       FSessionEmpty  : Boolean;
       function DVDSizeInfoFound: Boolean;
       function GetDVDType(const DVDInfo: string): TDiskType; override;
       function GetMediumInfo(const vv: Boolean): string;
       function GetSessionStartSec: string;
       procedure GetAudioCDTimeFree;
       procedure GetCDInfo;
       procedure GetDVDInfo;
       {$IFDEF DebugReadCDInfo}
       procedure DebugShowDiskInfo; override;
       {$ENDIF}
       {$IFDEF WriteLogfile}
       procedure WriteDiskInfoToLogfile;
       {$ENDIF}
       procedure InitDiskInfo; override;
     public
       function CheckMedium(var Args: TCheckMediumArgs): Boolean; override;
       procedure GetDiskInfo(const Device: string; const Audio: Boolean); override;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, f_stringlist,{$ENDIF}
     {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     cl_cdrtfedata, cl_sessionimport,
     f_filesystem, f_strings, f_getdosoutput, f_helper, f_window, f_locations,
     const_locations, const_common, const_tabsheets;

type TFormSelectDVD = class(TForm)
       FLang: TLang;
       StaticText: TStaticText;
       ComboBox: TComboBox;
       ButtonOk: TButton;
       ButtonCancel: TButton;
       procedure FormShow(Sender: TObject);
       procedure ButtonClick(Sender: TObject);
       procedure ButtonCancelClick(Sender: TObject);
     private
       FDiskType: TDiskType;
       FBlocks: string;
       procedure Init;
     public
       property Lang: TLang write FLang;
       property DiskType: TDiskType read FDiskType write FDiskType;
       property Blocks: string read FBlocks;
     end;

{ Hilfsfunktionen ------------------------------------------------------------ }

function ExtractInfo(const Data, SearchString, Delimiter1,
                           Delimiter2: string): string;
var p   : Integer;
    Temp: string;
begin                                       //  Deb('ExtracInfo:', 2);
  Temp := Data;                             //  Deb('  ' + SearchString, 2);
  p := Pos(SearchString, Temp);             //  Deb('   Found at position: ' + IntToStr(p), 2);
  if p > 0 then
  begin
    Delete(Temp, 1, p);                     //  Deb('  Delete(Temp, 1, p) -> "' + Temp + '"', 2);
    p := Pos(Delimiter1, Temp);             //  Deb('  Delimiter1 found at position: ' + IntToStr(p), 2);
    p := p + Length(Delimiter1) - 1;
    Delete(Temp, 1, p);                     //  Deb('  Delete(Temp, 1, p) -> "' + Temp + '"', 2);
    p := Pos(Delimiter2, Temp);             //  Deb('  Delimiter2 found at position: ' + IntToStr(p), 2);
    if p > 0 then Temp := Copy(Temp, 1, p -1);
    Temp := Trim(Temp);                     //  Deb('  Trim(Copy(Temp, 1, p -1) - > "' + Temp + '"', 2);
    Result := Temp;
  end else
  begin
    Result := '';
  end;                                      //  Deb('', 2);
end;

{ TFormSelectDVD ------------------------------------------------------------- }

{ TFormSelectDVD - private }

procedure TFormSelectDVD.Init;
var i: Integer;
begin
  FBlocks := '512';
  FDiskType := DT_Unknown;
  SetFont(Self);
  {Form}
  Caption := FLang.GMS('g004');
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu];
  ClientHeight := 180;
  ClientWidth := 220;
  OnShow := FormShow;
  {StaticText}
  StaticText := TStaticText.Create(Self);
  with StaticText do
  begin
    Parent := Self;
    Left := 8;
    Top := 8;
    AutoSize := False;
    Height := 93;
    Width := 203;
    Caption := FLang.GMS('eburn12') + CRLF + CRLF + FLang.GMS('eburn13');
  end;
  {ComboBox}
  ComboBox := TComboBox.Create(Self);
  with ComboBox do
  begin
    Parent := Self;
    Left := 8;
    Top := 109;
    Height := 98;
    Width := 203;
    Visible := True;
    Style := csDropDownList;
  end;
  {Ok-Button}
  ButtonOk := TButton.Create(Self);
  with ButtonOk do
  begin
    Parent := Self;
    Left := 56;
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
    Left := 136;
    Top := 145; // 40;
    Height := 25;
    Width := 75;
    Caption := FLang.GMS('mlang03');
    ModalResult := mrCancel;
    Cancel := True;
    OnClick := ButtonCancelClick;
  end;
  {Liste füllen}
  for i := 0 to 6 do ComboBox.Items.Add(cDiskTypeBlocks[i, 0]);
  ComboBox.ItemIndex := 0;
end;

procedure TFormSelectDVD.FormShow(Sender: TObject);
begin
  ButtonCancel.SetFocus;
end;

procedure TFormSelectDVD.ButtonClick(Sender: TObject);
begin
  ModalResult := mrOk;
  FBlocks := cDiskTypeBlocks[ComboBox.ItemIndex, 1];
  if ComboBox.ItemIndex > 0 then FDiskType := DT_Manual;
end;

procedure TFormSelectDVD.ButtonCancelClick(Sender: TObject);
begin
  FDiskType := DT_ManualNone;
end;

{ TFormSetDVD - public }


{ TDiskInfo ----------------------------------------------------------------- }

{ TDiskInfo - private }

{ DebugShowDiskInfo ------------------------------------------------------------

  zeigt die Daten von TDiskInfo an.                                            }

{$IFDEF DebugReadCDInfo}
procedure TDiskInfo.DebugShowDiskInfo;
begin
  Deb(CRLF + 'Object       : ' + Self.ClassName, 1);
  Deb('Disk.Sectors : ' + IntToStr(FSectors), 1);
  Deb('Disk.SecFree : ' + IntToStr(FSecFree), 1);
  Deb('Disk.Size    : ' + FloatToStr(FSize), 1);
  Deb('Disk.SizeUsed: ' + FloatToStr(FSizeUsed), 1);
  Deb('Disk.SizeFree: ' + FloatToStr(FSizeFree), 1);
  Deb('Disk.Time    : ' + FloatToStr(FTime), 1);
  Deb('Disk.TimeFree: ' + FloatToStr(FTimeFree), 1);
  Deb('Disk.MsInfo  : ' + FMsInfo, 1);
  if FIsDVD then Deb('Disk.IsDVD   : True', 1) else
    Deb('Disk.IsDVD   : False', 1);
  if FIsBD then Deb('Disk.IsBD    : True', 1) else
    Deb('Disk.IsBD    : False', 1);
  Deb('Disk.DiskType: ' + EnumToStr(TypeInfo(TDiskType), FDiskType)
      + CRLF, 1);
end;
{$ENDIF}

{ InitDiskInfo -----------------------------------------------------------------

  setzt die Variablen des TDiskInfo-Records zurück.                            }

procedure TDiskInfo.InitDiskInfo;
begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('  InitDiskInfo (TDiskInfo)');
  {$ENDIF}
  FDevice        := '';
  FSectors       := 0;
  FSecFree       := 0;
  FSize          := 0;
  FSizeUsed      := 0;
  FSizeFree      := 0;
  FTime          := 0;
  FTimeFree      := 0;
  FMsInfo        := '';
  FIsDVD         := False;
  FIsBD          := False;
  FDiskType      := DT_CD;
  FUseProfiles   := True;
  FForcedFormat  := False;
  FFormatCommand := '';
end;

{ DiskInserted -----------------------------------------------------------------

  True, wenn ein Medium eingelegt ist, False sonst.                            }

function TDiskInfo.DiskInserted(const CDInfo: string): Boolean;
begin
  Result := (Pos('No disk', CDInfo) = 0) and
            (Pos('Cannot load media with this drive!', CDInfo) = 0);
  {$IFDEF DebugReadCDInfo}
  if not Result then Deb('No disc inserted.' + CRLF, 1);
  {$ENDIF}
end;

{ MediumIsDVD ------------------------------------------------------------------

  MediumIsDVD liefert True, wenn die Disk eine DVD ist, False sonst.           }

function TDiskInfo.MediumIsDVD(const CDInfo: string): Boolean;
var Temp: string;
begin
{
  if (Pos('Driver flags   : DVD', CDInfo) > 0) or    // ProDVD
     (Pos('Found DVD media', CDInfo) > 0) then       // DVD-Hack
  begin
    Result := True;
  end else
    Result := False; }
  Temp := ExtractInfo(CDInfo, 'Driver flags', ':', LF);
  Result := (Pos('DVD', Temp) > 0) or                // Pro-DVD
            (Pos('Found DVD media', CDInfo) > 0);    // DVD-Hack or wodim
end;

{ MediumIsBD -------------------------------------------------------------------

  MediumIsBD liefert True, wenn die Disk eine BD ist, False sonst.             }

function TDiskInfo.MediumIsBD(const CDInfo: string): Boolean;
var Temp: string;
begin
  Temp := ExtractInfo(CDInfo, 'Driver flags', ':', LF);
  Result := (Pos('BD', Temp) > 0);
end;

{ GetDVDType -------------------------------------------------------------------

  GetDVDType ermittelt anhand des Book Types oder der aktuellen Profils die
  Art der DVD.                                                                 }

function TDiskInfo.GetDVDType(const DVDInfo: string): TDiskType;
const {$IFDEF UseCurrentProfile}
      CurrentProfileStr: string = 'Current:';
      {$ELSE}
      BookTypeStr: string = 'book type:       DVD';
      {$ENDIF}
var Temp: string;
    p   : Integer;
begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('GetDVDType (TDiskInfo)');
  {$ENDIF}
  Temp := DVDInfo;
  {$IFDEF UseCurrentProfile}
  {$IFDEF DebugReadCDInfo}
  Deb('  Using Current Profile.', 1);
  {$ENDIF}
  p := Pos(CurrentProfileStr, Temp);
  {$ELSE}
  {$IFDEF DebugReadCDInfo}
  Deb('  Using Book Type.', 1);
  {$ENDIF}
  p := Pos(BookTypeStr, Temp);
  {$ENDIF}
  if p > 0 then
  begin
    {Info extrahieren}
    {$IFDEF UseCurrentProfile}
    Delete(Temp, 1, p + 8);
    Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
    p := Pos(' ', Temp);
    if p > 0 then Temp := Copy(Temp, 1, p - 1);
    {$ELSE}
    Delete(Temp, 1, p + 16);
    Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
    p := Pos(',', Temp);
    if p > 0 then Temp := Copy(Temp, 1, p - 1);
    {$ENDIF}
    {Auswertung}
    if Temp = 'DVD-ROM'  then Result := DT_DVD_ROM     else
    if Temp = 'DVD-R'    then Result := DT_DVD_R       else
    if Temp = 'DVD-RW'   then Result := DT_DVD_RW      else
    if Temp = 'DVD-R/DL' then Result := DT_DVD_RDL     else
    if Temp = 'DVD+R'    then Result := DT_DVD_PlusR   else
    if Temp = 'DVD+RW'   then Result := DT_DVD_PlusRW  else
    if Temp = 'DVD+R/DL' then Result := DT_DVD_PlusRDL else
    if Temp = 'BD-ROM'   then Result := DT_BD_ROM      else
    if Temp = 'BD-R'     then Result := DT_BD_R        else
    if Temp = 'BD-RE'    then Result := DT_BD_RE       else
    Result := DT_Unknown;
    {$IFDEF ForceUnknownMedium}
    Result := DT_Unknown;
    {$ENDIF}
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add('  ' + Temp + ' -> ' +
                              EnumToStr(TypeInfo(TDiskType), Result));
    {$ENDIF}
  end else
    Result := DT_Unknown;
end;

{ GetCDType --------------------------------------------------------------------

  GetCDType ermittelt anhand des aktuellen Profils oder des Disk-Types die Art
  der CD.                                                                     }

function TDiskInfo.GetCDType(const CDInfo: string): TDiskType;
const CurrentProfileStr: string = 'Current:';
      DTStr            : string = 'Disk type:    ';
      ASLOStr          : string = 'start of lead out';
var Temp: string;
    p   : Integer;
begin
  Temp := CDInfo;
  p := Pos(CurrentProfileStr, Temp);
  if p > 0 then
  begin
    FUseProfiles := True;
    {$IFDEF DebugReadCDInfo}
    Deb('Using Current Profile.', 1);
    {$ENDIF}
    {Info extrahieren}
    Delete(Temp, 1, p + 8);
    Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
    p := Pos(' ', Temp);
    if p > 0 then Temp := Copy(Temp, 1, p - 1);
    {Auswertung}
    if Temp = 'CD-ROM'  then Result := DT_CD     else
    if Temp = 'CD-R'    then Result := DT_CD_R   else
    if Temp = 'CD-RW'   then Result := DT_CD_RW  else
    Result := DT_Unknown;
    {$IFDEF ForceUnknownMedium}
    Result := DT_Unknown;
    {$ENDIF}
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add(Temp + ' -> ' +
                              EnumToStr(TypeInfo(TDiskType), Result));
    {$ENDIF}
  end else
  begin
    {kein Profile-String, älteres Laufwerk}
    FUseProfiles := False;
    {$IFDEF DebugReadCDInfo}
    Deb('Using Disk type.', 1);
    {$ENDIF}
    if ((Pos(DTStr, CDInfo) = 0) and (Pos(ASLOStr, CDInfo) = 0)) or
       (Pos(DTStr + 'unknown dye', CDInfo) > 0) then Result := DT_CD    else
    if (Pos(DTStr + 'Phase change', CDInfo) > 0) or
       (Pos('Is erasable', CDInfo) > 0)         then Result := DT_CD_RW else
    Result := DT_CD_R;
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add('Disk type: ' +
                              EnumToStr(TypeInfo(TDiskType), Result));
    {$ENDIF}
    {Achtung: Damit Auto-Erase auch mit fixierten CD-RW-Rohlingen funktioniert,
     müssen bei MS-Info = 0,-1 CD-Rs auch als CD-RWs behandelt werden. Somit
     wird auch bei CD-Rs ein Auto-Erase angeboten. Leider können fixierte CD-Rs
     nicht von fixierten CD-RWs unterschieden werden. Dies gilt nur, wenn das
     Laufwerk keine Profile kennt.
     Der Hack erfolgt in GetCDInfo.}
  end;
end;

{ TDiskInfo - public }

constructor TDiskInfo.Create;
begin
  FSettings := TCdrtfeData.Instance.Settings;
  FLang     := TCdrtfeData.Instance.Lang;
end;


{ TDiskInfoA ----------------------------------------------------------------- }

{ TDiskInfoA - private }

{ InitDiskInfo -----------------------------------------------------------------

  setzt die Variablen des TDiskInfo-Records zurück.                            }

procedure TDiskInfoA.InitDiskInfo;
begin
  inherited InitDiskInfo;
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('  InitDiskInfo (TDiskInfoA)');
  {$ENDIF}
  FAtipInfo := '';
end;

{ GetAtipInfo ------------------------------------------------------------------

  GetAtipInfo liefert als Ergebins die Ausgabe von cdrecord -atip. Da vielleicht
  auch die Angaben zu den DVD-Profilen benötigt werden, wird zusätzlich die
  Option -v verwendet.
  Für Laufwerke, die bei -v keine vernünftigen Infos zurückgeben, z.B. NEC
  ND-3550a, ND-4550, kann -vv verwendet werden. Damit werden die benötigten
  Infos ausgegeben.                                                            }

function TDiskInfoA.GetAtipInfo(const vv: Boolean): string;
var CmdCdrecord: string;
    CmdOption  : string;
    VLevel     : string;
begin
  {ATIP auslesen}
  CmdOption := '-atip';
  CmdCdrecord := StartUpDir + cCdrecordBin;
  CmdCdrecord := QuotePath(CmdCdrecord);
  case vv of
    True : VLevel := 'vv';
    False: VLevel := 'v';
  end;
  CmdCdrecord := CmdCdrecord + ' dev=' + SCSIIF(FDevice) + ' ' + CmdOption +
                 ' -silent -' + VLevel;
  Result := GetDosOutput(PChar(CmdCdrecord), True, False);
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add(CRLF + CmdCdrecord);
  AddCRStringToList(Result, FormDebug.Memo1.Lines);
  FormDebug.Memo1.Lines.Add(CRLF);
  {$ENDIF}
  Result := Trim(Result);
end;

{ GetMSInfo --------------------------------------------------------------------

  GetMSInfo liefert die Ausgabe von cdrecord -msinfo.                          }

function TDiskInfoA.GetMSInfo: string;
var CmdCdrecord: string;
begin
  {ATIP auslesen}
  CmdCdrecord := StartUpDir + cCdrecordBin;
  CmdCdrecord := QuotePath(CmdCdrecord);
  CmdCdrecord := CmdCdrecord + ' dev=' + SCSIIF(FDevice) + ' -msinfo -silent';
  Result := GetDosOutput(PChar(CmdCdrecord), True, False);
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add(CRLF + CmdCdrecord);
  FormDebug.Memo1.Lines.Add(Result + CRLF);
  {$ENDIF}
  Result := Trim(Result);
  {Reload-Meldung entfernen}
  if Pos('reload', Result) > 0 then
  begin
    Delete(Result, 1, Pos(LF, Result));
  end;
end;

{ GetCDInfo --------------------------------------------------------------------

  GetCDInfo ermittelt aus den ATIP- und MSInfo-Daten die benötigten Daten zu den
  CDs (Größe, Speicherplatz, Zeit, ...).                                       }

procedure TDiskInfoA.GetCDInfo;
var Temp   : string;
    p      : Integer;
    ATIPSec: Integer;
    LastSec: Integer;
begin
  Temp := FAtipInfo;
  FDiskType := GetCDType(FAtipInfo);
  {Es ist eine CD, ATIP-Infos auswerten:
   die für die Berechnungen nötigen Sektorzahlen extrahieren: max. Sektorzahl}
  p := Pos('ATIP start of lead out:', Temp);
  if p > 0 then
  begin
    Delete(Temp, 1, p);
    p := Pos(':', Temp);
    Delete(Temp, 1, p);
    p := Pos('(', Temp);
    Temp := Trim(Copy(Temp, 1, p -1));
    ATIPSec := StrToIntDef(Temp, 0);
  end else
  begin
    ATIPSec := 0;
  end;
  FSectors := ATIPSec;

  {Multisessioninfos ermitteln}
  FMsInfo := GetMSInfo;
  {bei leerer CD MsInfo auf '' setzen.}
  if (Pos('disk', FMsInfo) > 0) or (Pos('session', FMsInfo) > 0) or
     (Pos('0,0', FMsInfo) > 0) then
  begin
    FMsInfo := '';
  end else
  {Wenn Schreibposition nicht nicht gelesen werden kann, Flag setzen.}
  if Pos('Cannot read first writable address', FMsInfo) > 0 then
  begin
    FMsInfo := 'no_address';
  end;
  {MsInfo-Ausgabe auswerten}
  Temp := FMsInfo;
  p := Pos(',', Temp);
  {CD ist nicht leer: x,y und nicht no_address}
  if p > 0 then
  begin
    Delete(Temp, 1, p);
    Temp := Trim(Temp);
    LastSec := StrToInt(Temp);
  end else
  begin
    LastSec := 0;
  end;
  if LastSec < 0 then LastSec := ATIPSec;
  {Hack fur Auto-Erase mit CD-RWs und alten Laufwerken}
  if not FUseProfiles and
     TCdrtfeData.Instance.Settings.Cdrecord.AutoErase and
    (FDiskType = DT_CD_R) and (Pos('-1', FMsInfo) > 0) then
  begin
    FDiskType := DT_CD_RW;
    {$IFDEF DebugReadCDInfo}
    Deb('Auto-Erase: Hack for old drives without Profiles: Setting Disk type ' +
        'from DT_CD_R to DT_CD_RW.', 1);
    {$ENDIF}
  end;

  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add(FMsInfo);
  {$ENDIF}

  {aus ATIP- und MsInfo-Werten Kapazitäten errechnen}
  if ATIPSec > 0 then
  begin
    {Größe der CD berechnen}
    FSize := ATIPSec / 512;
    {belegter, freier Speicher}
    FSecFree := ATIPSec - LastSec;
    FSizeUsed := LastSec / 512;
    FSizeFree := FSecFree / 512;
    FTime := ATIPSec / 75;
  end else
  begin
    FSize := 0;
    FSizeUsed := 0;
    FSizeFree := 0;
    FTime := 0;
  end;
end;

{ GetAudioCDTimeFree -----------------------------------------------------------

  GetAudioCDTimeFree ermittelt bei noch nicht fixierten Audio-CDs die verfügbare
  Restzeit.                                                                    }

procedure TDiskInfoA.GetAudioCDTimeFree;
var CmdCdrecord : string;
    Output, Temp: string;
    ATIPSec     : Integer;
    p           : Integer;
begin
  {$IFDEF DebugReadCDInfo}
  Deb('Entering GetAudioCDTimeFree', 1);
  {$ENDIF}
  ATIPSec := FSectors;
  CmdCdrecord := StartUpDir + cCdrecordBin;
  CmdCdrecord := QuotePath(CmdCdrecord);
  CmdCdrecord := CmdCdrecord + ' dev=' + SCSIIF(FDevice) + ' -toc -silent';
  Output := GetDosOutput(PChar(CmdCdrecord), True, False);
  p := Pos('track:lout lba:', Output);
  if p > 0 then
  begin
    Delete(Output, 1, p + 14);
    p := Pos('(', Output);
    Temp := Trim(Copy(Output, 1, p - 1));
    FTimeFree := (ATIPSec - StrToInt(Temp)) / 75;
  end else
  begin
    FTimeFree := FTime;
  end;
end;

{ DVDSizeInfoFound -------------------------------------------------------------

  True, wenn 'free blocks' oder 'phys. size' gefunden; False sonst.            }

function TDiskInfoA.DVDSizeInfoFound: Boolean;
begin
  Result := (Pos('free blocks:', FAtipInfo) > 0) or
            (Pos('phys size:...', FAtipInfo) > 0);
  {$IFDEF DebugReadCDInfo}
  if not Result then Deb('No size information found.', 1);
  {$ENDIF}
end;

{ GetDVDType -------------------------------------------------------------------

  GetDVDType ermittelt anhand des Book Types oder der aktuellen Profils die
  Art der DVD.                                                                 }

function TDiskInfoA.GetDVDType(const DVDInfo: string): TDiskType;
begin
  Result := inherited GetDVDType(DVDInfo);
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('GetDVDType (TDiskInfoA)');
  {$ENDIF}
  {An dieser Stelle wurde cdrecord -atip mit -v oder -vv aufgerufen. Wenn auch
   jetzt keine Größeninformationen vorhanden sind, muß der User selbst den Disk-
   Type auswählen, es sei denn, es ist eine DVD-ROM.}
  // if (Result <> DT_DVD_ROM) and not DVDSizeInfoFound then
  if not (Result in [DT_DVD_ROM, DT_BD_ROM]) and not DVDSizeInfoFound then  
  begin
    Result := DT_Unknown;
    {$IFDEF DebugReadCDInfo}
    Deb('  No size information found. Disk type set to DT_Unknown.', 1);
    {$ENDIF}
  end;
  {Hack für Laufwerke, die überhaupt keine vernünftigen Infos zurückgeben. Damit
   der Rohline überhaupt beschrieben werden kann, wird ein unbekannter Typ vor-
   getäuscht.}
  if TCdrtfeData.Instance.Settings.Hacks.DisableDVDCheck then
  begin
    Result := DT_Unknown;
    {$IFDEF DebugReadCDInfo}
    Deb('  DT_Unknown forced by DisableDVDCheck=1.', 1);
    {$ENDIF}
  end;
  {$IFDEF DebugReadCDInfo}
  Deb('', 1);
  {$ENDIF}
end;

{ GetDVDInfo -------------------------------------------------------------------

  GetDVDInfo ermittelt die auf der DVD zur Verfügung stehende Kapazität. Derzeit
  funktioniert dies nur mit cdrecord-ProDVD. Wenn ein anderes cdrecord verwendet
  wird oder der DVD-Type unbekannt ist, kann der User manuell einen Typ angeben
  oder ohne Angabe fortfahren.                                                 }

procedure TDiskInfoA.GetDVDInfo;
var Temp         : string;
    ATIPSec      : Integer;
    FormSelectDVD: TFormSelectDVD;
begin
  Temp := FAtipInfo;
  FDiskType := GetDVDType(FAtipInfo);
  if FDiskType = DT_DVD_ROM then
  begin
    FMsInfo := '-1';
    {$IFDEF DebugReadCDInfo}
    Deb('DVD-ROM found.' + CRLF, 1);
    {$ENDIF}
  end else
  begin
    if FDiskType in [DT_DVD_R, DT_DVD_RW, DT_DVD_RDL, DT_BD_R, DT_BD_RE] then
    begin
      Delete(Temp, 1, Pos('free blocks:', Temp) + 11);
      Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
      {$IFDEF DebugReadCDInfo}
      Deb('DVD-R(W) or BD-R(E) found.', 1);
      Deb('Using ''free blocks''.', 1);
      {$ENDIF}
    end else
    if FDiskType in [DT_DVD_PlusR, DT_DVD_PlusRW, DT_DVD_PlusRDL] then
    begin
      Delete(Temp, 1, Pos('phys size:...', Temp) + 12);
      Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
      {$IFDEF DebugReadCDInfo}
      Deb('DVD+R or +RW found.', 1);
      Deb('Using ''phys. size''.', 1);
      {$ENDIF}
    end else
    if FDiskType = DT_Unknown then
    begin
      {$IFDEF DebugReadCDInfo}
      Deb('Unknown DVD-Medium found. Could be DVD+R/DL.', 1);
      Deb('Ask user to select a medium or work with unknown size.', 1);
      Deb('No size check, if no medium specified.', 1);
      {$ENDIF}
      {Den User nur fragen, wenn kein Projekt automatisch ausgeführt wird.}
      if not TCdrtfeData.Instance.Settings.CmdLineFlags.ExecuteProject then
      begin
        FormSelectDVD := TFormSelectDVD.CreateNew(nil);
        try
          FormSelectDVD.Lang := TCdrtfeData.Instance.Lang;
          FormSelectDVD.Init;
          FormSelectDVD.ShowModal;
          Temp := FormSelectDVD.Blocks;
          FDiskType := FormSelectDVD.DiskType;
        finally
          FormSelectDVD.Release;
        end;
      end else
      begin
        {$IFDEF DebugReadCDInfo}
        Deb('Auto-executing project. Choosing ''unknown medium type''.', 1);
        {$ENDIF}
        Temp := '2048'; // <- Dummy
      end;
      {$IFDEF DebugReadCDInfo}
      if FDiskType = DT_Unknown then
        Deb('Continuing with unknown medium type.', 1);
      if FDiskType = DT_Manual then
        Deb('Continuing with user specified medium type.', 1);
      {$ENDIF}

    end;
    ATIPSec := StrToIntDef(Temp, 0);
    FSectors := ATIPSec;
    FSize := ATIPSec / 512;
    FSizeFree := FSize;
    FSecFree := FSectors;
    if FSize = 0 then FMsInfo := '-1';
    {$IFDEF DebugReadCDInfo}
    Deb(Temp + ' blocks', 1);
    Deb(FormatFloat('####.##', FSize) + ' MiByte', 1);
    Deb('', 1);
    {$ENDIF}
  end;
end;

{ TDiskInfoA - public }

{ GetDiskInfo ------------------------------------------------------------------

  Infos über den eingelegten Rohling ermitteln: Gesamtkapazität, belegter
  Speicher, freier Speicher, Multisessioninfos. Kapazitäten in MiByte, Zeit in
  Sekunden, ... }

procedure TDiskInfoA.GetDiskInfo(const Device: string; const Audio: Boolean);
begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Entering TDiskInfoA.GetDiskInfo');
  FormDebug.Memo1.Lines.Add('  Device: ' + Device);
  if Audio then FormDebug.Memo1.Lines.Add('  Audio: True');
  {$ENDIF}

  {Variablen initialisieren}
  InitDiskInfo;
  FDevice := Device;

  {ATIP auslesen}
  FAtipInfo := GetAtipInfo(False);

  {Auswerten der Infos, wenn Medium eingelegt ist.}
  if DiskInserted(FAtipInfo) then
  begin
    {Handelt es sich um eine DVD?}
    FIsDVD := MediumIsDVD(FAtipInfo);
    FIsBD  := MediumIsBD(FAtipInfo);
    if not FIsDVD then
    begin
      {Es ist eine CD}
      GetCDInfo;
    end else
    begin
      {Es ist eine DVD.}                               
      if not DVDSizeInfoFound then
        FAtipInfo := GetAtipInfo(True);
      GetDVDInfo;
    end;
  end else
  begin
    FDiskType := DT_None;
  end;

  {Restkapazität berechnen, wenn es sich um eine noch nicht fixierte Audio-CD
   handelt}
  if Audio then
  begin
    GetAudioCDTimeFree;
  end;

  {$IFDEF DebugReadCDInfo}
  DebugShowDiskInfo;
  {$ENDIF}
end;

{ CheckMedium ------------------------------------------------------------------

  liefert True, wenn die Überprüfung des eingelegten Mediums erfolgreich war.  }

function TDiskInfoA.CheckMedium(var Args: TCheckMediumArgs): Boolean;
var i   : Integer;
    Temp: string;
begin
  Result := True;
  FSettings.Cdrecord.Erase := False;
  {allgemeine Fehler, unabhängig vom Projekt}
  {Fehler: keine CD eingelegt}
  if FDiskType = DT_None then
  begin
    ShowMsgDlg(FLang.GMS('eburn01'), FLang.GMS('g001'), MB_cdrtfeError);
    Result := False;
  end;
  {Fehler: nächste Schreibadresse kann nicht gelesen werden}
  if FMsInfo = 'no_address' then
  begin
    if (FDiskType in [DT_CD_RW, DT_DVD_RW]) and
       FSettings.Cdrecord.AutoErase then
    begin
      i := ShowMsgDlg(FLang.GMS('eburn09') + CRLF + CRLF + FLang.GMS('eburn16'),
                      FLang.GMS('g001'), MB_cdrtfeWarningOC);
      Result := i = ID_OK;
      FSettings.Cdrecord.Erase := Result;
      FMsInfo := '';
    end else
    begin
      ShowMsgDlg(FLang.GMS('eburn09'), FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;
  {Fehler: fixierte CD eingelegt}
  if Pos('-1', FMsInfo) <> 0 then
  begin
    if (FDiskType in [DT_CD_RW, DT_DVD_RW]) and
       FSettings.Cdrecord.AutoErase then
    begin
      i := ShowMsgDlg(FLang.GMS('eburn02') + CRLF + CRLF + FLang.GMS('eburn16'),
                      FLang.GMS('g001'), MB_cdrtfeWarningOC);
      Result := i = ID_OK;
      FSettings.Cdrecord.Erase := Result;
      FMsInfo := '';
      FSecFree := FSectors;
      FSizeFree := FSize;
      FSizeUsed := 0;
    end else
    begin
      ShowMsgDlg(FLang.GMS('eburn02'), FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;

  {Fehler, die bei mehreren Projekten auftreten können.}
  if (Args.Choice = cDataCD) or (Args.Choice = cDVDVideo) then
  begin
    {Fehler: mkisofs fehlgeschlagen}
    if Args.SectorsNeededI = -1 then
    begin
      Result := False;
    end;
    {Fehler: unbekanntes DVD-Medium, unbekannte Kapazität. Abbruch.}
    if (FDiskType = DT_ManualNone) then
    begin
      Result := False;
    end;
  end;

  {Fehler: Daten-CD}
  if Args.Choice = cDataCD then
  begin
    {Sessions vorhanden, aber nicht importieren}
    if Result and not FSettings.DataCD.ContinueCD and (FMsInfo <> '') then
    begin
      if not FSettings.General.NoConfirm then
      begin
        i := ShowMsgDlg(FLang.GMS('eburn03'), FLang.GMS('g004'),
                        MB_cdrtfeWarningOC);
        Result := i = ID_OK;
      end;
    end;
    {wenn eine CD fortgesetzt werden soll}
    if Result and (FSettings.DataCD.Multi and FSettings.DataCD.ContinueCD) then
    begin
      {Warnung: keine Sessions gefunden}
      if FMsInfo = '' then
      begin
        {weitermachen oder nicht?}
        if not (FSettings.CmdLineFlags.ExecuteProject or
                FSettings.General.NoConfirm) then
        begin
          i := ShowMsgDlg(FLang.GMS('eburn04'), FLang.GMS('eburn05'),
                          MB_cdrtfeWarningOC);
        end else
        begin
          i := ID_OK;
        end;
        Result := i = ID_OK;
        {Wenn trotzdem geschrieben werden soll, dann aber ohne -C und -M}
        if Result then
        begin
          Args.ForcedContinue := True;
        end;
      end;
    end;
    {Fehler: zu viele Daten}
    if Result and
       (not FSettings.DataCD.ImageOnly or FSettings.DataCD.OnTheFly) and
       not FSettings.DataCD.Overburn and not (FDiskType = DT_Unknown) and
       (((Args.CDSize / (1024 * 1024)) > FSizeFree) or
        ((Args.SectorsNeededI + Args.TaoEndSecCount) > FSecFree)) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('eburn07'),
                     [FormatFloat('###.###', FSizeFree)]);
      if ((Args.SectorsNeededI + Args.TaoEndSecCount) > FSecFree) and
         ((Args.CDSize / (1024 * 1024)) < FSizeFree) then
        Temp := Temp +
                Format(FLang.GMS('eburn15'),
                       [FormatFloat('##0.###',
                                    (Args.SectorsNeededI +
                                     Args.TaoEndSecCount) / 512)]) +
                Format(FLang.GMS('eburn14'),
                       [FormatFloat('##0.###',
                                    ((Args.SectorsNeededI + Args.TaoEndSecCount
                                      - FSecFree) / 512)),
                        Args.SectorsNeededI + Args.TaoEndSecCount -
                          FSecFree]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
    {Fehler: DVD und Multisession}
    if Result and FIsDVD and FSettings.DataCD.Multi then
    begin
      Result := False;
      ShowMsgDlg(FLang.GMS('eburn11'), FLang.GMS('g001'), MB_cdrtfeError);
    end;
  end;

  {Fehler: Audio-CD}
  if Args.Choice = cAudioCD then
  begin
    {Fehler: Multisession-Daten-CD eingelegt -> man könnte eine Mixed-Mode-CD
     machen.}
    if Result and (MsInfo <> '') then
    begin
      ShowMsgDlg(FLang.GMS('eburn08'), FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
    {Fehler: Restkapazität nicht ausreichend}
    if Result and (FTimeFree > 0) and (Args.CDTime > FTimeFree)
              and not FSettings.AudioCD.Overburn then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('mburn04'),
                     [IntToStr(Round(FTimeFree) div 60) + ':' +
                      FormatFloat('0#.##',
                        (FTimeFree - (Round(FTimeFree) div 60) * 60))]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
   {Fehler: Gesamtspielzeit zu lang}
    if Result and not FSettings.AudioCD.Overburn and
       (Args.CDTime > FTime) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('mburn04'),
                     [IntToStr(Round(FTime) div 60) + ':' +
                      FormatFloat('0#.##',
                                (FTime - (Round(FTime) div 60) * 60))]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;

  {Fehler: Medium löschen}
  if Args.Choice = cCDRW then
  begin
    {Fehler: DVD+RW kann nicht gelöscht werden. Wird überschrieben.}
    if (FDiskType = DT_DVD_PlusRW) and
       not FSettings.Cdrecord.CanEraseDVDPlusRW then
    begin
      ShowMsgDlg(FLang.GMS('mburn15'), FLang.GMS('g004'),
                 MB_cdrtfeError);
      Result := False;
    end;
  end;

  {DVD-Video-Fehler}
  if Args.Choice = cDVDVideo then
  begin
    {Fehler: zu viele Daten}
    if Result and not (FDiskType = DT_Unknown) and
       (Args.SectorsNeededI > FSecFree) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('eburn07'),
                     [FormatFloat('###.###', SizeFree)]) +
              Format(FLang.GMS('eburn15'),
                     [FormatFloat('##0.###', (Args.SectorsNeededI / 512))]) +
              Format(FLang.GMS('eburn14'),
                     [FormatFloat('##0.###',
                                  ((Args.SectorsNeededI - FSecFree) / 512)),
                      Args.SectorsNeededI - FSecFree]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;

  {DVD-Fehler}
  {Fehler: DVD und TAO/RAW}
  if Result and FIsDVD then
  begin
    if ((Args.Choice = cDataCD) and not FSettings.DataCD.DAO) then
    begin
      Result := False;
      ShowMsgDlg(FLang.GMS('eburn10'), FLang.GMS('g001'), MB_cdrtfeError);
    end;
    if (FDiskType in [DT_DVD_PlusRW, DT_DVD_PlusR]) and
       FSettings.Cdrecord.Dummy then
    begin
      Result := False;
      ShowMsgDlg(FLang.GMS('eburn19'), FLang.GMS('g001'), MB_cdrtfeError);
    end;    
  end;
end;


{ TDiskInfoM ----------------------------------------------------------------- }

{ TDiskInfoM - private }

{ DebugShowDiskInfo ------------------------------------------------------------

  zeigt die Daten von TDiskInfo an.                                            }

{$IFDEF DebugReadCDInfo}
procedure TDiskInfoM.DebugShowDiskInfo;
begin
  inherited DebugShowDiskInfo;
  if FDiskEmpty then Deb('Disk.Empty   : True', 1) else
    Deb('Disk.Empty   : False', 1);
  if FDiskComplete then Deb('Disk.Complete: True', 1) else
    Deb('Disk.Complete: False', 1);
  if FDiskAppendable then Deb('Disk.Append. : True', 1) else
    Deb('Disk.Append. : False', 1);
  if FSessionEmpty then Deb('Disk.SessEmp.: True' + CRLF, 1) else
    Deb('Disk.SessEmp.: False' + CRLF, 1);
end;
{$ENDIF}

{$IFDEF WriteLogfile}
procedure TDiskInfoM.WriteDiskInfoToLogfile;
begin
  AddLog('DiskInfo:', 0);
  AddLog('=========', 2);
  AddLog('Disk Type      : ' + EnumToStr(TypeInfo(TDiskType), FDiskType), 3);
  AddLog('Sectors        : ' + IntToStr(FSectors), 3);
  AddLog('Sectors Free   : ' + IntToStr(FSecFree), 3);
  AddLog('Size (MiB)     : ' + FloatToStr(FSize), 3);
  AddLog('SizeUsed (MiB) : ' + FloatToStr(FSizeUsed), 3);
  AddLog('SizeFree (MiB) : ' + FloatToStr(FSizeFree), 3);
  AddLog('', 2);
end;
{$ENDIF}

{ InitDiskInfo -----------------------------------------------------------------

  setzt die Variablen des TDiskInfo-Records zurück.                            }

procedure TDiskInfoM.InitDiskInfo;
begin
  inherited InitDiskInfo;
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('  InitDiskInfo (TDiskInfoM)');
  {$ENDIF}
  FMediumInfo := '';
  FDiskEmpty     := True;
  FDiskComplete  := False;
  FDiskAppendable:= True;
  FSessionEmpty  := True;
end;

{ GetSessionData ---------------------------------------------------------------

  GetSessionData ermöglicht die Auswahl der zu importierenden Session.         }

function TDiskInfoM.GetSessionStartSec: string;
var SessionImporter: TSessionImportHelper;
begin
  if FSelectSess and not FDiskComplete then
  begin
    if FSessOverride <> '' then
    begin
      {Der User hat schon eine Session importiert.}
      Result := FSessOverride;
    end else
    begin
      SessionImporter := TSessionImportHelper.Create;
      SessionImporter.MediumInfo := FMediumInfo;
      SessionImporter.GetSession;
      Result := SessionImporter.StartSector;
      SessionImporter.Free;
    end;
  end else
  begin
    Result := ExtractInfo(FMediumInfo, 'Last session start address', ':', LF);
  end;
end;

{ GetMediumInfo ----------------------------------------------------------------

  GetMediumInfo liefert als Ergebins die Ausgabe von cdrecord -minfo. Da auch
  die Angaben zu den DVD-Profilen benötigt werden, wird zusätzlich die
  Option -v verwendet.
  Für Laufwerke, die bei -v keine vernünftigen Infos zurückgeben, z.B. NEC
  ND-3550a, ND-4550, kann -vv verwendet werden. Damit werden die benötigten
  Infos ausgegeben.                                                            }

function TDiskInfoM.GetMediumInfo(const vv: Boolean): string;
var CmdCdrecord: string;
    CmdOption  : string;
    VLevel     : string;
begin
  {Medieninfo auslesen}
  CmdOption := '-minfo';
  CmdCdrecord := StartUpDir + cCdrecordBin;
  CmdCdrecord := QuotePath(CmdCdrecord);
  case vv of
    True : VLevel := 'vv';
    False: VLevel := 'v';
  end;
  CmdCdrecord := CmdCdrecord + ' dev=' + SCSIIF(FDevice) + ' ' + CmdOption +
                 ' -silent -' + VLevel;
  Result := GetDosOutput(PChar(CmdCdrecord), True, False);
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add(CRLF + CmdCdrecord);
  AddCRStringToList(Result, FormDebug.Memo1.Lines);
  FormDebug.Memo1.Lines.Add(CRLF);
  {$ENDIF}
  Result := Trim(Result);
end;

{ GetCDInfo --------------------------------------------------------------------

  GetCDInfo ermittelt aus den ATIP- und MSInfo-Daten die benötigten Daten zu den
  CDs (Größe, Speicherplatz, Zeit, ...).                                       }

procedure TDiskInfoM.GetCDInfo;
var Temp    : string;
    StartSec: string;
    LastSec : string;
    LastSecI: Integer;
    ATIPSec : Integer;
begin
  FDiskType := GetCDType(FMediumInfo);
  {max. Anzahl von Sektoren}
  Temp := ExtractInfo(FMediumInfo, 'ATIP start of lead out', ':', '(');
  ATIPSec := StrToIntDef(Temp, 0);
  FSectors := ATIPSec - 2; // ? -minfo zeigt beim freien Speicher ATIPSec - 2 an
  {Anzahl freier Sektoren}
  Temp := ExtractInfo(FMediumInfo, 'Remaining writable size', ':', LF);
  FSecFree := StrToIntDef(Temp, 0);
  {CD leer? Fortsetzbar?}
  Temp := ExtractInfo(FMediumInfo, 'disk status', ':', LF);
  FDiskEmpty := Temp = 'empty';
  FDiskComplete := Temp = 'complete';
  FDiskAppendable := Temp = 'incomplete/appendable';
  {Session offen?}
  Temp := ExtractInfo(FMediumInfo, 'session status', ':', LF);
  FSessionEmpty := Temp = 'empty';
  {Multisessioninfo ermitteln}
  StartSec := GetSessionStartSec;
  (*
  if FSelectSess and not FDiskComplete then
  begin
    if FSessOverride <> '' then
    begin
      {Der User hat schon eine Session importiert.}
      StartSec := FSessOverride;
    end else
    begin
      SessionImporter := TSessionImportHelper.Create;
      SessionImporter.MediumInfo := FMediumInfo;
      SessionImporter.GetSession;
      StartSec := SessionImporter.StartSector;
      SessionImporter.Free;
    end;
  end else
  begin
    StartSec := ExtractInfo(FMediumInfo, 'Last session start address', ':', LF);
  end;
  *)
  LastSec  := ExtractInfo(FMediumInfo, 'Next writable address', ':', LF);
  LastSecI := StrToIntDef(LastSec, 0);
  if FDiskEmpty then
    FMsInfo := ''
  else
    FMsInfo :=  StartSec + ',' + LastSec;
  {Kapazitäten berechnen}
  if ATIPSec > 0 then
  begin
    {Größe der CD berechnen}
    FSize := ATIPSec / 512;
    FSizeUsed := LastSecI / 512;
    FSizeFree := FSecFree / 512;
    FTime := ATIPSec / 75;
  end else
  begin
    FSize := 0;
    FSizeUsed := 0;
    FSizeFree := 0;
    FTime := 0;
  end;
end;

{ GetAudioCDTimeFree -----------------------------------------------------------

  GetAudioCDTimeFree ermittelt bei noch nicht fixierten Audio-CDs die verfügbare
  Restzeit.                                                                    }

procedure TDiskInfoM.GetAudioCDTimeFree;
var LastSec : string;
    LastSecI: Integer;
begin
  {$IFDEF DebugReadCDInfo}
  Deb('Entering GetAudioCDTimeFree', 1);
  {$ENDIF}
  LastSec  := ExtractInfo(FMediumInfo, 'Next writable address', ':', LF);
  LastSecI := StrToIntDef(LastSec, -1);
  if LastSecI < 0 then
    FTimeFree := 0
  else
    FTimeFree := (FSectors - LastSecI) / 75;
end;

{ DVDSizeInfoFound -------------------------------------------------------------

  True, wenn 'free blocks' oder 'phys. size' gefunden; False sonst.            }

function TDiskInfoM.DVDSizeInfoFound: Boolean;
begin
  Result := (Pos('free blocks:', FMediumInfo) > 0) or
            (Pos('phys size:...', FMediumInfo) > 0);
  {$IFDEF DebugReadCDInfo}
  if not Result then Deb('No size information found.', 1);
  {$ENDIF}
end;

{ GetDVDType -------------------------------------------------------------------

  GetDVDType ermittelt anhand des Book Types oder der aktuellen Profils die
  Art der DVD.                                                                 }

function TDiskInfoM.GetDVDType(const DVDInfo: string): TDiskType;
begin
  Result := inherited GetDVDType(DVDInfo);
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('GetDVDType (TDiskInfoM)');
  {$ENDIF}
  {An dieser Stelle sollte eigentlich auch die Größe der Disk bekannt sein. Wenn
   nicht, muß der User gefragt werden.}
  // if (Result <> DT_DVD_ROM) and not DVDSizeInfoFound then
  if not (Result in [DT_DVD_ROM, DT_BD_ROM]) and not DVDSizeInfoFound then
  begin
    Result := DT_Unknown;
    {$IFDEF DebugReadCDInfo}
    Deb('  No size information found. Disk type set to DT_Unknown.', 1);
    {$ENDIF}
  end;                     (*
  {Hack für Laufwerke, die überhaupt keine vernünftigen Infos zurückgeben. Damit
   der Rohline überhaupt beschrieben werden kann, wird ein unbekannter Typ vor-
   getäuscht.}
  if TCdrtfeData.Instance.Settings.Hacks.DisableDVDCheck then
  begin
    Result := DT_Unknown;
    {$IFDEF DebugReadCDInfo}
    Deb('  DT_Unknown forced by DisableDVDCheck=1.', 1);
    {$ENDIF}
  end;                        *)
  {$IFDEF DebugReadCDInfo}
  Deb('', 1);
  {$ENDIF}
end;

{ GetDVDInfo -------------------------------------------------------------------

  GetDVDInfo ermittelt die auf der DVD zur Verfügung stehende Kapazität. Derzeit
  funktioniert dies nur mit cdrecord-ProDVD. Wenn ein anderes cdrecord verwendet
  wird oder der DVD-Type unbekannt ist, kann der User manuell einen Typ angeben
  oder ohne Angabe fortfahren.                                                 }

procedure TDiskInfoM.GetDVDInfo;
var Temp         : string;
    StartSec     : string;
    LastSec      : string;
    LastSecI     : Integer;
    FormSelectDVD: TFormSelectDVD;
begin
  FDiskType := GetDVDType(FMediumInfo);
  {Gesamtspeicher anhand des Disk-Typs}
  case FDiskType of
    DT_DVD_ROM, DT_BD_ROM      : FSectors := 0;
    DT_DVD_R, DT_DVD_RW        : FSectors := StrToInt(cDiskTypeBlocks[1, 1]);
    DT_DVD_RDL                 : FSectors := StrToInt(cDiskTypeBlocks[3, 1]);
    DT_DVD_PlusR, DT_DVD_PlusRW: FSectors := StrToInt(cDiskTypeBlocks[2, 1]);
    DT_DVD_PlusRDL             : FSectors := StrToInt(cDiskTypeBlocks[4, 1]);
    DT_BD_R, DT_BD_RE          : FSectors := StrToInt(cDiskTypeBlocks[5, 1]);
    DT_BD_R_DL, DT_BD_RE_DL    : FSectors := StrToInt(cDiskTypeBlocks[6, 1]);
  end;
  {Dvd leer? Fortsetzbar?}
  Temp := ExtractInfo(FMediumInfo, 'disk status', ':', LF);
  FDiskEmpty := Temp = 'empty';
  FDiskComplete := Temp = 'complete';
  FDiskAppendable := Temp = 'incomplete/appendable';  
  {Anzahl freier Sektoren}
  Temp := ExtractInfo(FMediumInfo, 'Remaining writable size', ':', LF);
  {Sonderbehandlung für unformatierte DVD+RW}
  if (FDIskType = DT_DVD_PlusRW) and (Temp = '') and FDiskEmpty then
  begin
    Temp := ExtractInfo(FMediumInfo, 'phys size', '...', LF);
    FForcedFormat := True;
    FFormatCommand := QuotePath(StartUpDir + cCdrecordBin) +
                      ' gracetime=5 dev=' + SCSIIF(FDevice) + ' -v -format';
    {$IFDEF DebugReadCDInfo}
    Deb('This seems to be an empty (maiden) DVD+RW.', 1);
    {$ENDIF}
  end;
  FSecFree := StrToIntDef(Temp, 0);
  {Sonderbehandllung: Disk-Typ BD-R(E)/DL: nicht am Profil erkennbar, daher mit
   FSecFree überprüfen}
  if (FDiskType in [DT_BD_R, DT_BD_RE]) and (FSecFree > FSectors)then
  begin
    FSectors := StrToInt(cDiskTypeBlocks[6, 1]);
    case FDiskType of
      DT_BD_R : FDiskType := DT_BD_R_DL;
      DT_BD_RE: FDiskType := DT_BD_RE_DL;
    end;
    {$IFDEF DebugReadCDInfo}
    Deb('This seems to be an BD-R(E)/DL.', 1);
    {$ENDIF}
  end;
  {Multiborderinfo ermitteln}
  // StartSec := ExtractInfo(FMediumInfo, 'Last session start address', ':', LF);  
  StartSec := GetSessionStartSec;
  LastSec  := ExtractInfo(FMediumInfo, 'Next writable address', ':', LF);
  LastSecI := StrToIntDef(LastSec, 0);
  if FDiskEmpty then
    FMsInfo := ''
  else
    FMsInfo :=  StartSec + ',' + LastSec;
  {unbekannter Disk-Typ -> User fragen}
  if FDiskType = DT_Unknown then
  begin
    {$IFDEF DebugReadCDInfo}
    Deb('Unknown DVD/BD-Medium found.', 1);
    Deb('Ask user to select a medium or work with unknown size.', 1);
    Deb('No size check, if no medium specified.', 1);
    {$ENDIF}
    FDiskEmpty := True;
    FDiskAppendable := True;
    FDiskComplete := False;
    FMsInfo := '';
    {Den User nur fragen, wenn kein Projekt automatisch ausgeführt wird.}
    if not TCdrtfeData.Instance.Settings.CmdLineFlags.ExecuteProject then
    begin
      FormSelectDVD := TFormSelectDVD.CreateNew(nil);
      try
        FormSelectDVD.Lang := TCdrtfeData.Instance.Lang;
        FormSelectDVD.Init;
        FormSelectDVD.ShowModal;
        FSectors := StrToInt(FormSelectDVD.Blocks);
        FDiskType := FormSelectDVD.DiskType;
      finally
        FormSelectDVD.Release;
      end;
    end else
    begin
      {$IFDEF DebugReadCDInfo}
      Deb('Auto-executing project. Choosing ''unknown medium type''.', 1);
      {$ENDIF}
      FSectors := 2048; // <- Dummy
    end;
    {$IFDEF DebugReadCDInfo}
    if FDiskType = DT_Unknown then
      Deb('Continuing with unknown medium type.', 1);
    if FDiskType = DT_Manual then
      Deb('Continuing with user specified medium type.', 1);
    {$ENDIF}
  end;
  {Kapazitäten berechnen}
  FSize := FSectors / 512;
  FSizeUsed := LastSecI / 512;
  FSizeFree := FSecFree / 512;
  {unbekannte Disk}
  if FDiskType in [DT_Unknown, DT_Manual] then
  begin
    FSizeFree := FSize;
    FSecFree := FSectors;
  end;

  {$IFDEF DebugReadCDInfo}
  Deb(IntToStr(FSectors) + ' blocks', 1);
  Deb(FormatFloat('####.##', FSize) + ' MiByte', 1);
  Deb('', 1);
  {$ENDIF}

end;

{ TDiskInfoM - public }

{ GetDiskInfo ------------------------------------------------------------------

  Infos über den eingelegten Rohling ermitteln: Gesamtkapazität, belegter
  Speicher, freier Speicher, Multisessioninfos. Kapazitäten in MiByte, Zeit in
  Sekunden, ... }

procedure TDiskInfoM.GetDiskInfo(const Device: string; const Audio: Boolean);
begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Entering TDiskInfoM.GetDiskInfo');
  FormDebug.Memo1.Lines.Add('  Device: ' + Device);
  if Audio then FormDebug.Memo1.Lines.Add('  Audio: True');
  {$ENDIF}

  {Variablen initialisieren}
  InitDiskInfo;
  FDevice := Device;
  FForcedFormat  := False;
  FFormatCommand := '';  

  {ATIP auslesen}
  FMediumInfo := GetMediumInfo(False);

  {Auswerten der Infos, wenn Medium eingelegt ist.}
  if DiskInserted(FMediumInfo) then
  begin
    {Handelt es sich um eine DVD?}
    FIsDVD := MediumIsDVD(FMediumInfo);
    FIsBD  := MediumIsBD(FMediumInfo);
    if FIsBD then FIsDVD := True;
    if not FIsDVD then
    begin
      {Es ist eine CD}
      GetCDInfo;
    end else
    begin
      {Es ist eine DVD.}
      // if not DVDSizeInfoFound then
      //  FMediumInfo := GetAtipInfo(True);
      GetDVDInfo;
    end;
  end else
  begin
    FDiskType := DT_None;
  end;

  {Restkapazität berechnen, wenn es sich um eine noch nicht fixierte Audio-CD
   handelt}
  if Audio then
  begin
    GetAudioCDTimeFree;
  end;

  {$IFDEF DebugReadCDInfo}
  DebugShowDiskInfo;
  {$ENDIF}
  {$IFDEF WriteLogfile}
  WriteDiskInfoToLogfile;
  {$ENDIF}

  {Variablen löschen für den nächsten Aufruf.}
  FSelectSess    := False;
  FSessOverride  := '';
end;

{ CheckMedium ------------------------------------------------------------------

  liefert True, wenn die Überprüfung des eingelegten Mediums erfolgreich war.  }

function TDiskInfoM.CheckMedium(var Args: TCheckMediumArgs): Boolean;
var i   : Integer;
    Temp: string;
begin
  Result := True;
  FSettings.Cdrecord.Erase := False;
  {allgemeine Fehler, unabhängig vom Projekt}
  {Fehler: keine CD eingelegt}
  if FDiskType = DT_None then
  begin
    ShowMsgDlg(FLang.GMS('eburn01'), FLang.GMS('g001'), MB_cdrtfeError);
    Result := False;
  end;
  {Fehler: nächste Schreibadresse kann nicht gelesen werden} (*
  if FMsInfo = 'no_address' then
  begin
    if (FDiskType in [DT_CD_RW, DT_DVD_RW]) and
       FSettings.Cdrecord.AutoErase then
    begin
      i := ShowMsgDlg(FLang.GMS('eburn09') + CRLF + CRLF + FLang.GMS('eburn16'),
                      FLang.GMS('g001'), MB_cdrtfeWarningOC);
      Result := i = ID_OK;
      FSettings.Cdrecord.Erase := Result;
      FMsInfo := '';
    end else
    begin
      ShowMsgDlg(FLang.GMS('eburn09'), FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;                                                     *)
  {Fehler: fixierte CD eingelegt}
  if FDiskComplete and (Args.Choice <> cCDRW)then
  begin
    if (FDiskType in [DT_CD_RW, DT_DVD_RW, DT_BD_RE, DT_BD_RE_DL]) and
       FSettings.Cdrecord.AutoErase then
    begin
      i := ShowMsgDlg(FLang.GMS('eburn02') + CRLF + CRLF + FLang.GMS('eburn16'),
                      FLang.GMS('g001'), MB_cdrtfeWarningOC);
      Result := i = ID_OK;
      FSettings.Cdrecord.Erase := Result;
      FMsInfo := '';
      FSecFree := FSectors;
      FSizeFree := FSize;
      FSizeUsed := 0;
    end else
    {Warnung: DVD+RW überschreiben?}
    if FDiskType in [DT_DVD_PlusRW] then
    begin
      if not (FSettings.CmdLineFlags.ExecuteProject or
              FSettings.General.NoConfirm) then
      begin
        i := ShowMsgDlg(FLang.GMS('eburn17'), FLang.GMS('g001'),
                        MB_cdrtfeWarningOC);
      end else
      begin
        i := ID_OK;
      end;
      Result := i = ID_OK;
      FMsInfo := '';
      FSecFree := FSectors;
      FSizeFree := FSize;
      FSizeUsed := 0;
    end else
    begin
      ShowMsgDlg(FLang.GMS('eburn02'), FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;

  {Fehler, die bei mehreren Projekten auftreten können.}
  if (Args.Choice = cDataCD) or (Args.Choice = cDVDVideo) then
  begin
    {Fehler: mkisofs fehlgeschlagen}
    if Args.SectorsNeededI = -1 then
    begin
      Result := False;
    end;
    {Fehler: unbekanntes DVD-Medium, unbekannte Kapazität. Abbruch.}
    if (FDiskType = DT_ManualNone) then
    begin
      Result := False;
    end;    
  end;

  {Fehler: Daten-CD}
  if Args.Choice = cDataCD then
  begin
    {Sessions vorhanden, aber nicht importieren}
    if Result and not FSettings.DataCD.ContinueCD and (FMsInfo <> '') then
    begin
      if not FSettings.General.NoConfirm then
      begin
        i := ShowMsgDlg(FLang.GMS('eburn03'), FLang.GMS('g004'),
                        MB_cdrtfeWarningOC);
        Result := i = ID_OK;
      end;
    end;
    {wenn eine CD fortgesetzt werden soll}
    if Result and (FSettings.DataCD.Multi and FSettings.DataCD.ContinueCD) then
    begin
      {Warnung: keine Sessions gefunden}
      if FMsInfo = '' then
      begin
        {weitermachen oder nicht?}
        if not (FSettings.CmdLineFlags.ExecuteProject or
                FSettings.General.NoConfirm) then
        begin
          i := ShowMsgDlg(FLang.GMS('eburn04'), FLang.GMS('eburn05'),
                          MB_cdrtfeWarningOC);
        end else
        begin
          i := ID_OK;
        end;
        Result := i = ID_OK;
        {Wenn trotzdem geschrieben werden soll, dann aber ohne -C und -M}
        if Result then
        begin
          Args.ForcedContinue := True;
        end;
      end;
    end;
    {Fehler: zu viele Daten}
    if Result and
       (not FSettings.DataCD.ImageOnly or FSettings.DataCD.OnTheFly) and
       not FSettings.DataCD.Overburn and not (FDiskType = DT_Unknown) and
       (((Args.CDSize / (1024 * 1024)) > FSizeFree) or
        ((Args.SectorsNeededI + Args.TaoEndSecCount) > FSecFree)) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('eburn07'),
                     [FormatFloat('###.###', FSizeFree)]);
      if ((Args.SectorsNeededI + Args.TaoEndSecCount) > FSecFree) and
         ((Args.CDSize / (1024 * 1024)) < FSizeFree) then
        Temp := Temp +
                Format(FLang.GMS('eburn15'),
                       [FormatFloat('##0.###',
                                    (Args.SectorsNeededI +
                                     Args.TaoEndSecCount) / 512)]) +
                Format(FLang.GMS('eburn14'),
                       [FormatFloat('##0.###',
                                    ((Args.SectorsNeededI + Args.TaoEndSecCount
                                      - FSecFree) / 512)),
                        Args.SectorsNeededI + Args.TaoEndSecCount -
                          FSecFree]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
    {Warnung: CD, Multisession und DAO}
    if Result and FSettings.DataCD.Multi and
       FSettings.DataCD.DAO and not FIsDVD then
    begin
      i := ShowMsgDlg(FLang.GMS('eburn21'), FLang.GMS('g004'),
                      MB_cdrtfeWarningOC);
      Result := i = ID_OK;
    end;
    {Fehler: DVD und Multisession}
    if Result and FSettings.DataCD.Multi and FIsDVD and
       (not FSettings.Cdrecord.HasMultiborder or
        (FDiskType in [DT_DVD_PlusR, DT_DVD_PlusRW])) then
    begin
      Result := False;
      ShowMsgDlg(FLang.GMS('eburn11'), FLang.GMS('g001'), MB_cdrtfeError);
    end;
  end;

  {Fehler: Audio-CD}
  if Args.Choice = cAudioCD then
  begin
    {Fehler: Multisession-Daten-CD eingelegt -> man könnte eine Mixed-Mode-CD
     machen.}
    if Result and (MsInfo <> '') and FSessionEmpty then
    begin
      ShowMsgDlg(FLang.GMS('eburn08'), FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
    {Fehler: Restkapazität nicht ausreichend}
    if Result and (FTimeFree > 0) and (Args.CDTime > FTimeFree)
              and not FSettings.AudioCD.Overburn then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('mburn04'),
                     [IntToStr(Round(FTimeFree) div 60) + ':' +
                      FormatFloat('0#.##',
                        (FTimeFree - (Round(FTimeFree) div 60) * 60))]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
   {Fehler: Gesamtspielzeit zu lang}
    if Result and not FSettings.AudioCD.Overburn and
       (Args.CDTime > FTime) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('mburn04'),
                     [IntToStr(Round(FTime) div 60) + ':' +
                      FormatFloat('0#.##',
                                (FTime - (Round(FTime) div 60) * 60))]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;

  {Fehler: Medium löschen}
  if Args.Choice = cCDRW then
  begin
    {Fehler: DVD+RW kann nicht gelöscht werden. Wird überschrieben.}
    if (FDiskType = DT_DVD_PlusRW) and
       not FSettings.Cdrecord.CanEraseDVDPlusRW then
    begin
      ShowMsgDlg(FLang.GMS('mburn15'), FLang.GMS('g004'),
                 MB_cdrtfeError);
      Result := False;
    end;
  end;

  {Fehler: Image schreiben}
  if Args.Choice = cCDImage then
  begin
    // zur Zeit testen wir auf keine weiteren Fehler
  end;

  {DVD-Video-Fehler}
  if Args.Choice = cDVDVideo then
  begin
    {Fehler: zu viele Daten}
    if Result and not (FDiskType = DT_Unknown) and
       (Args.SectorsNeededI > FSecFree) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('eburn07'),
                     [FormatFloat('###.###', SizeFree)]) +
              Format(FLang.GMS('eburn15'),
                     [FormatFloat('##0.###', (Args.SectorsNeededI / 512))]) +
              Format(FLang.GMS('eburn14'),
                     [FormatFloat('##0.###',
                                  ((Args.SectorsNeededI - FSecFree) / 512)),
                      Args.SectorsNeededI - FSecFree]);
      ShowMsgDlg(Temp, FLang.GMS('g001'), MB_cdrtfeError);
      Result := False;
    end;
  end;

  {DVD-Fehler}
  {Fehler: DVD und TAO/RAW}
  if Result and FIsDVD then
  begin
    if ((Args.Choice = cDataCD) and not FSettings.DataCD.DAO) or
       ((Args.Choice = cCDImage) and not FSettings.Image.DAO) then
    begin
      Result := False;
      ShowMsgDlg(FLang.GMS('eburn10'), FLang.GMS('g001'), MB_cdrtfeError);
    end;
    if (FDiskType in [DT_DVD_PlusRW, DT_DVD_PlusR]) and
       FSettings.Cdrecord.Dummy then
    begin
      Result := False;
      ShowMsgDlg(FLang.GMS('eburn19'), FLang.GMS('g001'), MB_cdrtfeError);
    end;
  end;
end;

end.
