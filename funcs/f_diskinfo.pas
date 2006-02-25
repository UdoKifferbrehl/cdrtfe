{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  f_diskinfo.pas: Informationen über das eingelegte Medium ermitteln

  Copyright (c) 2006 Oliver Valencia

  letzte Änderung  15.01.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

  f_diskinfo.pas stellt Funktionen zur Ermittlung von Diskinformationen zur
  Verfügung.
    * Größe eines Rohlings, verbliebener Speicherplatz, ...


  exportierte Funktionen/Prozeduren:

    GetDiskInfo(var Disk: TDiskInfo; const Device: string; const Audio: Boolean)

}

unit f_diskinfo;

{$I directives.inc}

interface

uses Forms, StdCtrls, Controls, SysUtils;

const cDiskTypeBlocks: array[0..4, 0..1] of string =
        ((' ', '1024'),                                    // Dummyeintrag
         ('DVD-R(W) [4,38 GiByte]', '2298496'),
         ('DVD+R(W) [4,38 GiByte]', '2295104'),
         ('DVD-R/DL (-R9) [7,96 GiByte]', '4171712'),
         ('DVD+R/DL (+R9) [7,96 GiByte]', '4173824'));

type TDiskType = (DT_CD, DT_DVD_ROM, DT_DVD_R, DT_DVD_RW, DT_DVD_RDL,
                  DT_DVD_PlusR, DT_DVD_PlusRW, DT_DVD_PlusRDL, DT_Manual,
                  DT_Unknown, DT_None);

     TDiskInfo = record
       Sectors : Integer;
       Size    : Double;
       SizeUsed: Double;
       SizeFree: Double;
       Time    : Double;
       TimeFree: Double;
       MsInfo  : string;
       IsDVD   : Boolean;
       DiskType: TDiskType;
     end;

procedure GetDiskInfo(var Disk: TDiskInfo; const Device: string; const Audio: Boolean);

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     cl_lang, cl_cdrtfedata,
     f_filesystem, f_strings, f_process, f_misc, constant;

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
  for i := 0 to 4 do ComboBox.Items.Add(cDiskTypeBlocks[i, 0]);
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
  FDiskType := DT_None;
end;

{ TFormSetDVD - public }


{ GetDiskInfo-Funktionen ----------------------------------------------------- }

{ InitDiskInfo -----------------------------------------------------------------

  setzt die Variablen des TDiskInfo-Records zurück.                            }

procedure InitDiskInfo(var Disk: TDiskInfo);
begin
  Disk.Sectors  := 0;
  Disk.Size     := 0;
  Disk.SizeUsed := 0;
  Disk.SizeFree := 0;
  Disk.Time     := 0;
  Disk.TimeFree := 0;
  Disk.MsInfo   := '';
  Disk.IsDVD    := False;
  Disk.DiskType := DT_CD;
end;

{ GetAtipInfo ------------------------------------------------------------------

  GetAtipInfo liefert als Ergebins die Ausgabe von cdrecord -atip. Da vielleicht
  auch die Angaben zu den DVD-Profilen benötigt werden, wird zusätzlich die
  Option -v verwendet.                                                         }

function GetAtipInfo(const Device: string): string;
var CmdCdrecord: string;
begin
  {ATIP auslesen}
  CmdCdrecord := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  CmdCdrecord := QuotePath(CmdCdrecord);
  {$ENDIF}
  CmdCdrecord := CmdCdrecord + ' dev=' + Device + ' -atip -silent -v';
  Result := GetDosOutput(PChar(CmdCdrecord), True);
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add(CRLF + CmdCdrecord);
  AddCRStringToList(Result, FormDebug.Memo1.Lines);
  FormDebug.Memo1.Lines.Add(CRLF);
  {$ENDIF}
  Result := Trim(Result);
end;

{ GetMSInfo --------------------------------------------------------------------

  GetMSInfo liefert die Ausgabe von cdrecord -msinfo.                          }

function GetMSInfo(const Device:string): string;
var CmdCdrecord: string;
begin
  {ATIP auslesen}
  CmdCdrecord := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  CmdCdrecord := QuotePath(CmdCdrecord);
  {$ENDIF}
  CmdCdrecord := CmdCdrecord + ' dev=' + Device + ' -msinfo -silent';
  Result := GetDosOutput(PChar(CmdCdrecord), True);
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

procedure GetCDInfo(var Disk: TDiskInfo; const AtipInfo, Device: string);
var Temp   : string;
    p      : Integer;
    ATIPSec: Integer;
    LastSec: Integer;
begin
  Temp := AtipInfo;
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
  Disk.Sectors := ATIPSec;

  {Multisessioninfos ermitteln}
  Disk.MsInfo := GetMSInfo(Device);
  {bei leerer CD MsInfo auf '' setzen.}
  if (Pos('disk', Disk.MsInfo) > 0) or (Pos('session', Disk.MsInfo) > 0) or
     (Pos('0,0', Disk.MsInfo) > 0) then
  begin
    Disk.MsInfo := '';
  end else
  {Wenn Schreibposition nicht nicht gelesen werden kann, Flag setzen.}
  if Pos('Cannot read first writable address', Disk.MsInfo) > 0 then
  begin
    Disk.MsInfo := 'no_address';
  end;
  {MsInfo-Ausgabe auswerten}
  Temp := Disk.MsInfo;
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
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add(Disk.MsInfo);
  {$ENDIF}

  {aus ATIP- und MsInfo-Werten Kapazitäten errechnen}
  if ATIPSec > 0 then
  begin
    {Größe der CD berechnen}
    Disk.Size := ATIPSec / 512;
    {belegter, freier Speicher}
    Disk.SizeUsed := LastSec / 512;
    Disk.SizeFree := (ATIPSec - LastSec) / 512;
    Disk.Time := ATIPSec / 75;
  end else
  begin
    Disk.Size := 0;
    Disk.SizeUsed := 0;
    Disk.SizeFree := 0;
    Disk.Time := 0;
  end;
end;

{ GetAudioCDTimeFree -----------------------------------------------------------

  GetAudioCDTimeFree ermittelt bei noch nicht fixierten Audio-CDs die verfügbare
  Restzeit.                                                                    }

procedure GetAudioCDTimeFree(var Disk: TDiskInfo; const Device: string);
var CmdCdrecord : string;
    Output, Temp: string;
    ATIPSec     : Integer;
    p           : Integer;
begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Entering GetAudioCDTimeFree');
  {$ENDIF}
  ATIPSec := Disk.Sectors;
  CmdCdrecord := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  CmdCdrecord := QuotePath(CmdCdrecord);
  {$ENDIF}
  CmdCdrecord := CmdCdrecord + ' dev=' + Device + ' -toc -silent';
  Output := GetDosOutput(PChar(CmdCdrecord), True);
  p := Pos('track:lout lba:', Output);
  if p > 0 then
  begin
    Delete(Output, 1, p + 14);
    p := Pos('(', Output);
    Temp := Trim(Copy(Output, 1, p - 1));
    Disk.TimeFree := (ATIPSec - StrToInt(Temp)) / 75;
  end else
  begin
    Disk.TimeFree := Disk.Time;
  end;
end;

{ MediumIsDVD ------------------------------------------------------------------

  MediumIsDVD liefert True, wenn die Disk eine DVD ist, False sonst.           }

function MediumIsDVD(const AtipInfo: string): Boolean;
begin
  if (Pos('Driver flags   : DVD', AtipInfo) > 0) or    // ProDVD
     (Pos('Found DVD media', AtipInfo) > 0) then       // DVD-Hack
  begin
    Result := True;
  end else
    Result := False;
end;

{ GetDVDType -------------------------------------------------------------------

  GetDVDType ermittelt anhand des Book Types oder der aktuellen Profils die
  Art der DVD.                                                                 }

function GetDVDType(const AtipInfo: string): TDiskType;
const {$IFDEF UseCurrentProfile}
      CurrentProfileStr: string = 'Current:';
      {$ELSE}
      BookTypeStr: string = 'book type:       DVD';
      {$ENDIF}
var Temp: string;
    p   : Integer;
begin
  Temp := AtipInfo;
  {$IFDEF UseCurrentProfile}
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Using Current Profile.');
  {$ENDIF}
  p := Pos(CurrentProfileStr, Temp);
  {$ELSE}
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Using Book Type.');
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
    if Temp = 'DVD+R'    then Result := DT_DVD_PlusR   else
    if Temp = 'DVD+RW'   then Result := DT_DVD_PlusRW  else
    if Temp = 'DVD+R/DL' then Result := DT_DVD_PlusRDL else
    Result := DT_Unknown;
    {$IFDEF ForceUnknownMedium}
    Result := DT_Unknown;
    {$ENDIF}
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add(Temp + ' -> ' +
                              EnumToStr(TypeInfo(TDiskType), Result));
    {$ENDIF}
  end else
    Result := DT_Unknown;
end;

{ GetDVDInfo -------------------------------------------------------------------

  GetDVDInfo ermittelt die auf der DVD zur Verfügung stehende Kapazität. Derzeit
  funktioniert dies nur mit cdrecord-ProDVD. Wenn ein anderes cdrecord verwendet
  wird oder der DVD-Type unbekannt ist, kann der User manuell einen Typ angeben
  oder ohne Angabe fortfahren.                                                 }

procedure GetDVDInfo(var Disk: TDiskInfo; const AtipInfo: string);
var Temp         : string;
    ATIPSec      : Integer;
    FormSelectDVD: TFormSelectDVD;
begin
  Temp := AtipInfo;
  Disk.DiskType := GetDVDType(AtipInfo);
  if Disk.DiskType = DT_DVD_ROM then
  begin
    Disk.MsInfo := '-1';
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add('DVD-ROM found.' + CRLF);
    {$ENDIF}
  end else
  begin
    if Disk.DiskType in [DT_DVD_R, DT_DVD_RW] then
    begin
      Delete(Temp, 1, Pos('free blocks:', Temp) + 11);
      Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
      {$IFDEF DebugReadCDInfo}
      FormDebug.Memo1.Lines.Add('DVD-R or -RW found.');
      FormDebug.Memo1.Lines.Add('Using ''free blocks''.');
      {$ENDIF}
    end else
    if Disk.DiskType in [DT_DVD_PlusR, DT_DVD_PlusRW] then
    begin
      Delete(Temp, 1, Pos('phys size:...', Temp) + 12);
      Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
      {$IFDEF DebugReadCDInfo}
      FormDebug.Memo1.Lines.Add('DVD+R or +RW found.');
      FormDebug.Memo1.Lines.Add('Using ''phys. size''.');
      {$ENDIF}
    end else
    if Disk.DiskType = DT_Unknown then
    begin
      {$IFDEF DebugReadCDInfo}
      FormDebug.Memo1.Lines.Add('Unknown DVD-Medium found. Could be DVD+R/DL.');
      FormDebug.Memo1.Lines.Add('Ask user to select a medium or work with unknown size.');
      FormDebug.Memo1.Lines.Add('No size check, if no medium not specified.');
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
          Disk.DiskType := FormSelectDVD.DiskType;
        finally
          FormSelectDVD.Release;
        end;
      end else
      begin
        {$IFDEF DebugReadCDInfo}
        FormDebug.Memo1.Lines.Add('Auto-executing project. Choosing ''unknown medium type''.');
        {$ENDIF}
        Temp := '2048'; // <- Dummy
      end;
      {$IFDEF DebugReadCDInfo}
      if Disk.DiskType = DT_Unknown then
      FormDebug.Memo1.Lines.Add('Continuing with unknown medium type.');
      if Disk.DiskType = DT_Manual then
      FormDebug.Memo1.Lines.Add('Continuing with user specified medium type.');
      {$ENDIF}

    end;
    ATIPSec := StrToIntDef(Temp, 0);
    Disk.Size := ATIPSec / 512;
    Disk.SizeFree := Disk.Size;
    if Disk.Size = 0 then Disk.MsInfo := '-1';
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add(Temp + ' blocks');
    FormDebug.Memo1.Lines.Add(FormatFloat('####.##', Disk.Size) + ' MiByte');
    FormDebug.Memo1.Lines.Add('');
    {$ENDIF}
  end;
end;

{ GetDiskInfo ------------------------------------------------------------------

  Infos über den eingelegten Rohling ermitteln: Gesamtkapazität, belegter
  Speicher, freier Speicher, Multisessioninfos. Kapazitäten in MiByte, Zeit in
  Sekunden, ... }

procedure GetDiskInfo(var Disk: TDiskInfo; const Device: string;
                      const Audio: Boolean);
var AtipInfo: string;
begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Entering GetDiskInfo');
  FormDebug.Memo1.Lines.Add('  Device: ' + Device);
  if Audio then FormDebug.Memo1.Lines.Add('  Audio: True');
  {$ENDIF}

  {Variablen initialisieren}
  InitDiskInfo(Disk);

  {ATIP auslesen}
  AtipInfo := GetAtipInfo(Device);

  {Handelt es sich um eine DVD?}
  Disk.IsDVD := MediumIsDVD(AtipInfo);

  {Auswerten der Infos}
  if not Disk.IsDVD then
  begin
    {Es ist eine CD}
    GetCDInfo(Disk, AtipInfo, Device);
  end else
  begin
    {Es ist eine DVD.}
    GetDVDInfo(Disk, AtipInfo);
  end;

  {Restkapazität berechnen, wenn es sich um eine noch nicht fixierte Audio-CD
   handelt}
  if Audio then
  begin
    GetAudioCDTimeFree(Disk, Device);
  end;
end;


end.
