{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Front End

  cl_action.pas: die im GUI gewählte Aktion ausführen

  Copyright (c) 2004-2005 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte Änderung  17.07.2005

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
                 OnMessageToShow
                 ProgressBar
                 Reload
                 Settings
                 StatusBar

    Methoden     CleanUp
                 Create
                 StartAction


  Anmerkungen:

  TCDAction hieß ursprünglich TAction und wurde umbenannt, da ab Delphi 4 eine
  Komponente TAction eingeführt wurde.

  Beim Zusammenstellen der Kommandozeilen werden der Einfachheit und
  Übersichtlichkeit die verkürzten if-Statements verwendet, obwohl sie nicht dem
  Object-Pascal-Style-Guide entsprechen.

}

unit cl_action;

{$I directives.inc}

interface

uses Classes, Forms, StdCtrls, ComCtrls, Windows, SysUtils,
     cl_settings, cl_projectdata, cl_lang, cl_actionthread, cl_verifythread,
     cl_devices;

type TDiskType = (DT_CD, DT_DVD_ROM, DT_DVD_R, DT_DVD_RW, DT_DVD_PlusR,
                  DT_DVD_PlusRW, DT_DVD_PlusRWDL, DT_Unknown);

     TCDInfo = record
       Size    : Double;
       SizeUsed: Double;
       SizeFree: Double;
       Time    : Double;
       TimeFree: Double;
       MsInfo  : string;
       IsDVD   : Boolean;
       DiskType: TDiskType;
     end;

     { TCheckMediumArgs faßt einige Varaiblen zusammen, die in den verschiedenen
       Prozeduren benötigt werden, damit diese leichter an CheckMedium übergeben
       werden können.}

     TCheckMediumArgs = record
       {allgemein}
       Choice        : Byte;
       {Daten-CD}
       ForcedContinue: Boolean;
       CDSize        : {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
       {Audio-CD}
       CDTime        : Extended;
     end;

     TCDAction = class(TObject)
     private
       FAction: Byte;
       FLastAction: Byte;
       FActionThread: TActionThread;
       FVerificationThread: TVerificationThread;
       FVList: TStringList;
       FData: TProjectData;
       FDevices: TDevices;
       FReload: Boolean;
       FLang: TLang;
       // FTempBurnList: TStringList;
       FDupSize: {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF};
       FSplitOutput: Boolean;
       {Variablen zur Ausgabe}
       FFormHandle: THandle;
       FMemo: TMemo;
       FOnMessageToShow: TNotifyEvent;
       FSettings: TSettings;
       FStatusBar: TStatusBar;
       FProgressBar: TProgressBar;
       function CheckMedium(CD: TCDInfo; var Args: TCheckMediumArgs): Boolean;
       function GetAction: Byte;
       function MakePathConform(const Path: string): string;
       function MakePathEntryMkisofsConform(const Path: string): string;
       function GetSectorNumber(const MkisofsOptions: string): string;
       procedure CreateAudioCD;
       procedure CreateDataCD;
       procedure CreateVideoCD;
       procedure CreateVideoDVD;
       procedure CreateXCD;
       procedure CreateXCDInfoFile(List: TStringList);
       procedure DAEGrabTracks;
       procedure DAEReadTOC;
       procedure DeleteCDRW;
       procedure FindDuplicateFiles(List: TStringList);
       procedure GetCDInfos;
       procedure ReadCDInfo(var CD: TCDInfo; const Device: string; const Audio: Boolean);
       procedure ReadImage;
       procedure StartVerification(const Action: Byte);
       procedure WriteImage;
       procedure WriteTOC;
       {Events}
       procedure MessageToShow;
     public
       constructor Create;
       destructor Destroy; override;
       procedure AbortAction;
       procedure CleanUp(const Phase: Byte);
       procedure Reset;
       procedure StartAction;
       property Action: Byte read GetAction write FAction;
       property LastAction: Byte read FLastAction;
       property Data: TProjectData write FData;
       property Devices: TDevices write FDevices;
       property FormHandle: THandle write FFormHandle;
       property Lang: TLang write FLang;
       property Memo: TMemo read FMemo write FMemo;
       property StatusBar: TStatusBar read FStatusBar write FStatusBar;
       property ProgressBar: TProgressBar read FProgressBar write FProgressBar;
       property Reload: Boolean read FReload write FReload;
       property Settings: TSettings write FSettings;
       property DuplicateFileSize: {$IFDEF LargeFiles} Comp {$ELSE} Longint {$ENDIF} read FDupSize write FDupSize;
       {Events}
       property OnMessageToShow: TNotifyEvent read FOnMessageToShow write FOnMessageToShow;
     end;

implementation

uses {$IFDEF ShowDebugWindow} frm_debug, {$ENDIF}
     f_filesystem, f_process, f_environment, f_cygwin, f_strings, f_init,
     constant, user_messages;

{ TCDAction ------------------------------------------------------------------ }

{ TCDAction - private }

{ MessageToShow ----------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TCDAction.MessageToShow;
begin
  if Assigned(FOnMessageToShow) then FOnMessageToShow(Self);
end;

{ GetAction --------------------------------------------------------------------

  GetAction liefert den Wert von FAction und setzt ihn auf cNoAction.          }

function TCDAction.GetAction: Byte;
begin
  Result := FAction;
  FLastAction := FAction;
  FAction := cNoAction;
end;

{ FindDuplicateFiles -----------------------------------------------------------

  FindDuplicateFiles sucht in der Pfadliste nach Dateiduplikaten.              }

procedure TCDAction.FindDuplicateFiles(List: TStringList);
begin
  FProgressBar.Visible := True;
  FProgressBar.Max := 100;
  FProgressBar.Position := 0;
  {Pfadlisten in FVList laden}
  FVerificationThread := TVerificationThread.Create(List, FMemo,
                                                    FSettings.DataCD.Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cFindDuplicates;
  FVerificationThread.StatusBar := FStatusBar;
  FVerificationThread.ProgressBar := FProgressBar;
  {Thread starten}
  FVerificationThread.Resume;
end;

{ CreateXCDInfoFile ------------------------------------------------------------

  CreateXCDInfoFile erzeugt die Info-Datei xcd.crc, in der die ursprünglichen
  Dateigrößen der Form2-Dateien sowie deren CRC32-Prüfsumme gespeichert sind.  }

procedure TCDAction.CreateXCDInfoFile(List: TStringList);
begin      
  FProgressBar.Visible := True;
  FProgressBar.Max := 100;
  FProgressBar.Position := 0;
  {Pfadlisten in FVList laden}
  FVerificationThread := TVerificationThread.Create(List, FMemo,
                                                    FSettings.DataCD.Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  FVerificationThread.Action := cCreateInfoFile;
  FVerificationThread.StatusBar := FStatusBar;
  FVerificationThread.ProgressBar := FProgressBar;
  {Thread starten}
  FVerificationThread.Resume;
end;

{ MakePathConform --------------------------------------------------------------

  Bei FSettings.FileFlags.Mingw = True ist der normale Windowspfad das Ergebnis,
  andernfalls wird das Ergebnis aus MakePathCygwinConform(Path) zurückgegeben. }

function TCDAction.MakePathConform(const Path: string): string;
begin
  if FSettings.FileFlags.Mingw then
  begin
    Result := Path;
  end else
  begin
    Result := MakePathCygwinConform(Path);
  end;
end;

{ MakePathEntryMkisofsConform --------------------------------------------------

  bereitet den Pfadlisten-Eintrag für mkisofs auf, wobei die Cygwin- und Mingw-
  Version unterschiedlich behandelt werden müssen.                             }

function TCDAction.MakePathEntryMkisofsConform(const Path: string): string;
begin
  if FSettings.FileFlags.Mingw then
  begin
    Result := MakePathMingwMkisofsConform(Path);
  end else
  begin
    Result := MakePathMkisofsConform(Path);
  end;
end;

{ ReadCDInfos ------------------------------------------------------------------

  Infos über die eingelegte CD ermitteln: Gesamtkapazität, belegter Speicher,
  freier Speicher, Multisessioninfos. Kapazitäten in MiByte, Zeit in Sekunden. }

procedure TCDAction.ReadCDInfo(var CD: TCDInfo; const Device: string;
                               const Audio: Boolean);
var AtipInfo: string;
    ATIPSec: Integer;
    LastSec: Integer;

  function GetAtipInfo: string;
  var CmdCdrecord: string;
  begin
    {ATIP auslesen}
    CmdCdrecord := StartUpDir + cCdrecordBin;
    {$IFDEF QuoteCommandlinePath}
    CmdCdrecord := QuotePath(CmdCdrecord);
    {$ENDIF}
    CmdCdrecord := CmdCdrecord + ' dev=' + Device + ' -atip -silent';
    Result := GetDosOutput(PChar(CmdCdrecord), True);
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add(CRLF + CmdCdrecord);
    FormDebug.Memo1.Lines.Add(Result + CRLF);
    {$ENDIF}
    Result := Trim(Result);
  end;

  function GetMSInfo: string;
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

  function MediumIsDVD(const AtipInfo: string): Boolean;
  begin
    if (Pos('Driver flags   : DVD', AtipInfo) > 0) or    // ProDVD
       (Pos('mmc_dvd', AtipInfo) > 0) or                 // ProDVD
       (Pos('Found DVD media', AtipInfo) > 0) then       // DVD-Hack
    begin
      Result := True;
    end else
      Result := False;
  end;

  procedure GetCDInfo(const AtipInfo: string);
  var Temp: string;
      p   : Integer;
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

    {Multisessioninfos ermitteln}
    CD.MsInfo := GetMSInfo;
    {bei leerer CD MsInfo auf '' setzen.}
    if (Pos('disk', CD.MsInfo) > 0) or (Pos('session', CD.MsInfo) > 0) or
       (Pos('0,0', CD.MsInfo) > 0) then
    begin
      CD.MsInfo := '';
    end else
    {Wenn Schreibposition nicht nicht gelesen werden kann, Flag setzen.}
    if Pos('Cannot read first writable address', CD.MsInfo) > 0 then
    begin
      CD.MsInfo := 'no_address';
    end;
    {MsInfo-Ausgabe auswerten}
    Temp := CD.MsInfo;
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
    FormDebug.Memo1.Lines.Add(CD.MsInfo);
    {$ENDIF}

    {aus ATIP- und MsInfo-Werten Kapazitäten errechnen}
    if ATIPSec > 0 then
    begin
      {Größe der CD berechnen}
      CD.Size := ATIPSec / 512;
      {belegter, freier Speicher}
      CD.SizeUsed := LastSec / 512;
      CD.SizeFree := (ATIPSec - LastSec) / 512;
      CD.Time := ATIPSec / 75;
    end else
    begin
      CD.Size := 0;
      CD.SizeUsed := 0;
      CD.SizeFree := 0;
      CD.Time := 0;
    end;
  end;

  function GetDVDType(const AtipInfo: string): TDiskType;
  const BookTypeStr: string = 'book type:       DVD';
  var Temp: string;
      p   : Integer;
  begin
    Temp := AtipInfo;
    p := Pos(BookTypeStr, Temp);
    if p > 0 then
    begin
      {Info extrahieren}
      Delete(Temp, 1, p + 16);
      Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
      p := Pos(',', Temp);
      if p > 0 then Temp := Copy(Temp, 1, p - 1);
      {Auswertung}
      if Temp = 'DVD-ROM' then Result := DT_DVD_ROM    else
      if Temp = 'DVD-R'   then Result := DT_DVD_R      else
      if Temp = 'DVD-RW'  then Result := DT_DVD_RW     else
      if Temp = 'DVD+R'   then Result := DT_DVD_PlusR  else
      if Temp = 'DVD+RW'  then Result := DT_DVD_PlusRW else
      Result := DT_Unknown;
      {$IFDEF DebugReadCDInfo}
      FormDebug.Memo1.Lines.Add(Temp + ' -> ' +
                                EnumToStr(TypeInfo(TDiskType), Result));
      {$ENDIF}
    end else
      Result := DT_Unknown;
  end;

  procedure GetDVDInfo(const AtipInfo: string);
  var Temp: string;
  begin
    Temp := AtipInfo;
    CD.DiskType := GetDVDType(AtipInfo);
    if CD.DiskType = DT_DVD_ROM then
    begin
      CD.MsInfo := '-1';
      {$IFDEF DebugReadCDInfo}
      FormDebug.Memo1.Lines.Add('DVD-ROM found.' + CRLF);
      {$ENDIF}
    end else
    begin
      if CD.DiskType in [DT_DVD_R, DT_DVD_RW] then
      begin
        Delete(Temp, 1, Pos('free blocks:', Temp) + 11);
        Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
        {$IFDEF DebugReadCDInfo}
        FormDebug.Memo1.Lines.Add('DVD-R or -RW found.');
        FormDebug.Memo1.Lines.Add('Using ''free blocks''.');
        {$ENDIF}
      end else
      if CD.DiskType in [DT_DVD_PlusR, DT_DVD_PlusRW] then
      begin
        Delete(Temp, 1, Pos('phys size:...', Temp) + 12);
        Temp := Trim(Copy(Temp, 1, Pos(LF, Temp)));
        {$IFDEF DebugReadCDInfo}
        FormDebug.Memo1.Lines.Add('DVD+R or +RW found.');
        FormDebug.Memo1.Lines.Add('Using ''phys. size''.');
        {$ENDIF}
      end else
      if CD.DiskType = DT_Unknown then
      begin
        Temp := '1024';         // <- Dummy-Wert
        {$IFDEF DebugReadCDInfo}
        FormDebug.Memo1.Lines.Add('Unknown DVD-Medium found. Could be DVD+R/DL.');
        FormDebug.Memo1.Lines.Add('No size check.');
        {$ENDIF}
      end;
      ATIPSec := StrToIntDef(Temp, 0);
      CD.Size := ATIPSec / 512;
      CD.SizeFree := CD.Size;
      if CD.Size = 0 then CD.MsInfo := '-1';
      {$IFDEF DebugReadCDInfo}
      FormDebug.Memo1.Lines.Add(Temp + ' blocks');
      FormDebug.Memo1.Lines.Add(FormatFloat('####.##', CD.Size) + ' MiByte');
      FormDebug.Memo1.Lines.Add('');
      {$ENDIF}
    end;
  end;

  procedure GetAudioCDTimeFree;
  var CmdCdrecord : string;
      Output, Temp: string;
      p           : Integer;
  begin
    {$IFDEF DebugReadCDInfo}
    FormDebug.Memo1.Lines.Add('Entering GetAudioCDTimeFree');
    {$ENDIF}
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
      CD.TimeFree := (ATIPSec - StrToInt(Temp)) / 75;
    end else
    begin
      CD.TimeFree := CD.Time;
    end;
  end;

begin
  {$IFDEF DebugReadCDInfo}
  FormDebug.Memo1.Lines.Add('Entering ReadCDInfo');
  FormDebug.Memo1.Lines.Add('  Device: ' + Device);
  if Audio then FormDebug.Memo1.Lines.Add('  Audio: True');
  {$ENDIF}
  ATIPSec := 0;
  CD.Size := 0;
  CD.SizeUsed := 0;
  CD.SizeFree := 0;
  CD.Time := 0;
  CD.TimeFree := 0;
  CD.MsInfo := '';
  CD.IsDVD := False;
  CD.DiskType := DT_CD;

  {ATIP auslesen}
  AtipInfo := GetAtipInfo;

  {Handelt es sich um eine DVD?}
  CD.IsDVD := MediumIsDVD(AtipInfo);

  {Auswerten der Infos}
  if not CD.IsDVD then
  begin
    {Es ist eine CD}
    GetCDInfo(AtipInfo);
  end else
  begin
    {Es ist eine DVD.}
    GetDVDInfo(AtipInfo);
  end;

  {Restkapazität berechnen, wenn es sich um eine noch nicht fixierte Audio-CD
   handelt}
  if Audio then
  begin
    GetAudioCDTimeFree;
  end;
end;

{ CheckMedium ------------------------------------------------------------------

  liefert True, wenn die Überprüfung des eingelegten Mediums erfolgreich war.  }

function TCDAction.CheckMedium(CD: TCDInfo; var Args: TCheckMediumArgs): Boolean;
var i      : Integer;
    Temp   : string;
    Meldung: PChar;
begin
  Result := True;
  {allgemeine Fehler, unabhängig vom Projekt}
  {Fehler: keine CD eingelegt}
  if (CD.Size = 0) and (CD.MsInfo = '') then
  begin
    Application.MessageBox(PChar(FLang.GMS('eburn01')),
                           PChar(FLang.GMS('g001')),
                           MB_OK or MB_ICONEXCLAMATION);
    Result := False;
  end;
  {Fehler: nächste Schreibadresse kann nicht gelesen werden}
  if CD.MsInfo = 'no_address' then
  begin
    Application.MessageBox(PChar(FLang.GMS('eburn09')),
                           PChar(FLang.GMS('g001')),
                           MB_OK or MB_ICONEXCLAMATION);
    Result := False;
  end;
  {Fehler: fixierte CD eingelegt}
  if Pos('-1', CD.MsInfo) <> 0 then
  begin
    Application.MessageBox(PChar(FLang.GMS('eburn02')),
                           PChar(FLang.GMS('g001')),
                           MB_OK or MB_ICONEXCLAMATION);
    Result := False;
  end;

  {Fehler: Daten-CD}
  if Args.Choice = cDataCD then
  begin
    {Sessions vorhanden, aber nicht importieren}
    if Result and not FSettings.DataCD.ContinueCD and (CD.MsInfo <> '') then
    begin
      if FSettings.General.NoConfirm then
      begin
        i := Application.MessageBox(PChar(FLang.GMS('eburn03')),
                                    PChar(FLang.GMS('g004')),
                                    MB_OKCancel or MB_ICONEXCLAMATION);
        Result := i = 1;
      end else
      begin
        Application.MessageBox(PChar(FLang.GMS('eburn03')),
                               PChar(FLang.GMS('g004')),
                               MB_OK or MB_ICONEXCLAMATION);
      end;
    end;
    {wenn eine CD fortgesetzt werden soll}
    if Result and (FSettings.DataCD.Multi and FSettings.DataCD.ContinueCD) then
    begin
      {Warnung: keine Sessions gefunden}
      if CD.MsInfo = '' then
      begin
        {weitermachen oder nicht?}
        {$IFDEF Confirm}
        if not (FSettings.CmdLineFlags.ExecuteProject or
                FSettings.General.NoConfirm) then
        begin
          i := Application.MessageBox(PChar(FLang.GMS('eburn04')),
                                      PChar(FLang.GMS('eburn05')),
                                      MB_OKCANCEL or MB_ICONEXCLAMATION);
        end else
        {$ENDIF}
        begin
          i := 1;
        end;
        Result := i = 1;
        {Wenn trotzdem geschrieben werden soll, dann aber ohne -C und -M}
        if Result then
        begin
          Args.ForcedContinue := True;
          FSettings.DataCD.ContinueCD := False;
        end;
      end;
      FSettings.DataCD.MsInfo := CD.MsInfo;
    end;
    {Warnung: unbekanntes DVD-Medium, unbekannte Kapazität.}
    if Result and (CD.DiskType = DT_Unknown) then
    begin
      i := Application.MessageBox(PChar(FLang.GMS('eburn12')),
                                  PChar(FLang.GMS('g004')),
                                  MB_OKCANCEL or MB_ICONEXCLAMATION);
      Result := i = 1;
    end;
    {Fehler: zu viele Daten}
    if Result and
       not FSettings.DataCD.Overburn and not (CD.DiskType = DT_Unknown) and
       ((Args.CDSize / (1024 * 1024)) > CD.SizeFree) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('eburn07'),
                     [FormatFloat('###.##', CD.SizeFree)]);
      Meldung := PChar(Temp);
      Application.MessageBox(Meldung, PChar(FLang.GMS('g001')),
                             MB_OK or MB_ICONEXCLAMATION);
      Result := False;
    end;
    {Fehler: DVD und Multisession}
    if Result and CD.IsDVD and FSettings.DataCD.Multi then
    begin
      Result := False;
      Application.MessageBox(PChar(FLang.GMS('eburn11')),
                             PChar(FLang.GMS('g001')),
                             MB_OK or MB_ICONEXCLAMATION);
    end;
  end;

  {Fehler: Audio-CD}
  if Args.Choice = cAudioCD then
  begin
    {Fehler: Multisession-Daten-CD eingelegt -> man könnte eine Mixed-Mode-CD
     machen, aber ich weiß nicht wie.}
    if Result and (CD.MsInfo <> '') then
    begin
      Application.MessageBox(PChar(FLang.GMS('eburn08')),
                             PChar(FLang.GMS('g001')),
                             MB_OK or MB_ICONEXCLAMATION);

      Result := False;
    end;
    {Fehler: Restkapazität nicht ausreichend}
    if Result and (CD.TimeFree > 0) and (Args.CDTime > CD.TimeFree) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('mburn04'),
                     [IntToStr(Round(CD.TimeFree) div 60) + ':' +
                      FormatFloat('0#.##',
                            (CD.TimeFree - (Round(CD.TimeFree) div 60) * 60))]);
      Meldung := PChar(Temp);
      Application.MessageBox(Meldung, PChar(FLang.GMS('g001')),
                             MB_OK or MB_ICONEXCLAMATION);
      Result := False;
    end;
   {Fehler: Gesamtspielzeit zu lang}
    if Result and not FSettings.AudioCD.Overburn and
       (Args.CDTime > CD.Time) then
    begin
      Temp := FLang.GMS('eburn06') +
              Format(FLang.GMS('mburn04'),
                     [IntToStr(Round(CD.Time) div 60) + ':' +
                      FormatFloat('0#.##',
                                  (CD.Time - (Round(CD.Time) div 60) * 60))]);
      Meldung := PChar(Temp);
      Application.MessageBox(Meldung, PChar(FLang.GMS('g001')),
                             MB_OK or MB_ICONEXCLAMATION);
      Result := False;
    end;
  end;

  {DVD-Fehler}
  {Fehler: DVD und TAO/RAW}
  if Result and CD.IsDVD then
  begin
    if ((Args.Choice = cDataCD) and not FSettings.DataCD.DAO) then
    begin
      Result := False;
      Application.MessageBox(PChar(FLang.GMS('eburn10')),
                             PChar(FLang.GMS('g001')),
                             MB_OK or MB_ICONEXCLAMATION);
    end;
  end;
end;

{ GetSectorNumber --------------------------------------------------------------

  bestimmt die Länge des Datentracks in Sektoren. Nötig für DAO/RAW.           }

function TCDAction.GetSectorNumber(const MkisofsOptions: string): string;
var CmdGetSize: string;
    Sectors   : string;
    p         : Integer;
begin
  Result := '';
  CmdGetsize := StartUpDir + cMkisofsBin;
  {$IFDEF QuoteCommandlinePath}
  CmdGetSize := QuotePath(CmdGetSize);
  {$ENDIF}
  CmdGetsize := CmdGetSize + ' -print-size -quiet' + MkisofsOptions;
  Sectors := Trim(GetDosOutput(PChar(CmdGetsize), True));
  p := LastDelimiter(LF, Sectors);
  if p > 0 then Delete(Sectors, 1, p);
  if StrToIntDef(Sectors, -1) >= 0 then Result := Sectors;
end;

{ CreateDataCD -----------------------------------------------------------------

  Daten-CDs erstellen und fortsetzen.                                          }

procedure TCDAction.CreateDataCD;
var i              : Integer;
    Temp           : string;
    BurnList       : TStringList;
    CmdC, CmdM,
    CmdOnTheFly    : string;
    FHPathList,
    FHShCmd        : TextFile;
    CD             : TCDInfo;
    CMArgs         : TCheckMediumArgs;
    DummyE         : Extended;
    DummyI         : Integer;
    Ok             : Boolean;
    SimulDev       : string;
 // CDSize         : {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
 // ForcedContinue : Boolean;

begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  BurnList := TStringList.Create;
  FData.CreateBurnList(BurnList, cDataCD);
  Ok := True;
  SimulDev := 'cdr';
  CMArgs.ForcedContinue := False;
  CMArgs.Choice := cDataCD;
  {Größe der Daten ermitteln}
  FData.GetProjectInfo(DummyI, DummyI, CMArgs.CDSize, DummyE, DummyI, cDataCD);
  {Dateiduplikate aufspüren}
  {$IFDEF ShowBurnList}
  FormDebug.Memo1.Lines.Assign(FVList);
  {$ENDIF}
  if FSettings.DataCD.FindDups then
  begin
    if FVList.Count = 0 then
    begin
      FVList.Assign(BurnList);
      FindDuplicateFiles(FVList);
      Burnlist.Free;
      {wir müssen zuück in den Hauptthread, um auf den Vergleich zu warten}
      exit;
    end else
    begin
      BurnList.Clear;
      BurnList.Assign(FVList);
      FVList.Clear;
      if FDupSize > 0 then
      begin
        CMArgs.CDSize := CMArgs.CDSize - FDupSize;
        FDupSize := 0;
      end;
    end;
  end;
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}
  {Infos über eingelegte CD einlesen}
  if not FSettings.DataCD.ImageOnly or FSettings.DataCD.OnTheFly then
  begin
    ReadCDInfo(CD, FSettings.DataCD.Device, False);
    {Bei DVD als Simulationstreiber dvd_simul verwenden. Nur Überprüfung, wenn
     ProDVD verwendet wird.}
    if not CD.IsDVD then
    begin
      Ok := CheckMedium(CD, CMArgs);
    end else
    begin
      SimulDev := 'dvd';
      if FSettings.FileFlags.ProDVD then Ok := CheckMedium(CD, CMArgs);
    end;
  end;
  {Pfadliste bearbeiten}
  if FSettings.DataCD.Boot then
  begin
    BurnList.Add(ExtractFileName(FSettings.DataCD.BootImage) + ':' +
                 FSettings.DataCD.BootImage);
  end;
  for i := 0 to (BurnList.Count - 1) do
  begin
    {die Liste für die graft-points-Option von cdrecord umbauen:
     bis 0.8.x -graft-points betrifft nur Directories, Cygwin-konform genügte.
     jetzt: _alle_ Pfadangaben Cygwin-konform machen und außerdem auf '='
     achten!}
    BurnList[i] := MakePathEntryMkisofsConform(BurnList[i]);
  end;
  FSettings.DataCD.PathListName := ProgDataDir + cPathListFile;
  // BurnList.SaveToFile(PathListName);
  {Nun doch wieder mit WriteFile, wg. CR/LF-Problem: Wenn eine vollständige
   cygwin-Installation vorhanden ist, kann mkisofs keine Pfadlisten mit CR/LF
   einlesen, wie sie von SaveToFile() erzeugt werden.}
  AssignFile(FHPathList, FSettings.DataCD.PathListName);
  Rewrite(FHPathList);
  for i := 0 to (BurnList.Count - 1) do
  begin
    Write(FHPathList, BurnList[i] + LF);
  end;
  Close(FHPathList);
  {Ab 1 GiByte soll das Image geteilt werden, wenn ProDVD benutzt wird.}
  FSplitOutput := FSettings.FileFlags.ProDVD and
                  not FSettings.DataCD.OnTheFly and
                  ((CMArgs.CDSize / (1024 * 1024)) > 1024);
  {Kommandozeilen zusammenstellen, die unabhängig von on-the-fly sind, hier
   ersteinmal nur die Argumente; die Programmnamen und -pfade kommen später,
   da sie wegen sh.exe gesondert behandelt werden müssen.}
  {mkisofs}
  CmdM := ' -graft-points';
  with FSettings.DataCD, FSettings.General, FSettings.Cdrecord do
  begin
    if FindDups    then CmdM := CmdM + ' -cache-inodes';
    if Joliet      then
    if JolietLong  then CmdM := CmdM + ' -joliet-long' else
                        CmdM := CmdM + ' -joliet';                  // ' -J';
    if RockRidge   then CmdM := CmdM + ' -rock';                    // ' -R';
    if UDF         then CmdM := CmdM + ' -udf';
    if ISO31Chars  then CmdM := CmdM + ' -full-iso9660-filenames';  // ' -l';
    if ISOLevel    then CmdM := CmdM + ' -iso-level ' + IntToStr(ISOLevelNr);
    if ISOLevel and (ISOOutChar > -1)
                   then CmdM := CmdM + ' -output-charset '
                                     + CharSets[ISOOutChar];
    if ISO37Chars  then CmdM := CmdM + ' -max-iso-filenames';
    if ISONoDot    then CmdM := CmdM + ' -omit-period';             // ' -d';
    if ISOStartDot then CmdM := CmdM + ' -allow-leading-dots';      // ' -L';
    if ISOMultiDot then CmdM := CmdM + ' -allow-multidot';
    if ISOASCII    then CmdM := CmdM + ' -relaxed-filenames';
    if ISOLower    then CmdM := CmdM + ' -allow-lowercase';
    if ISONoTrans  then CmdM := CmdM + ' -no-iso-translate';
    if ISODeepDir  then CmdM := CmdM + ' -disable-deep-relocation'; // ' -D';
    if ISONoVer    then CmdM := CmdM + ' -omit-version-number';     // ' -N';
    if Boot        then
    begin
      CmdM := CmdM + ' -eltorito-boot ' + QuotePath(ExtractFileName(BootImage));
      if BootNoEmul  then CmdM := CmdM + ' -no-emul-boot';
      if BootBinHide then
      begin
        CmdM := CmdM + ' -hide ' + QuotePath(ExtractFileName(BootImage));
        if Joliet then CmdM := CmdM + ' -hide-joliet '
                                    + QuotePath(ExtractFileName(BootImage));
      end;
      if BootCatHide then
      begin
        CmdM := CmdM + ' -hide boot.catalog';
        if Joliet then CmdM := CmdM + ' -hide-joliet boot.catalog';
      end;
    end;
    if Multi then
    begin
      if ContinueCD  then CmdM := CmdM + ' -cdrecord-params ' + MsInfo
                                       + ' -prev-session ' + Device;
                                    // + ' -dev ' + Device;  ab mkisofs 2.01a22
                                    // + ' -C ' + MsInfo + ' -M ' + Device;
      if not ContinueCD and (CD.MsInfo <> '') then begin
                          MsInfo := CD.MsInfo;
                          CmdM := CmdM + ' -cdrecord-params '  + MsInfo; end;
                                      // ' -C '
    end;
    if VolId <> '' then CmdM := CmdM + ' -volid "' + VolId + '"';   // ' -V "'
    if MkisofsUseCustOpts then
      CmdM := CmdM + ' ' + MkisofsCustOpts[MkisofsCustOptsIndex];
    CmdM := CmdM + ' -path-list '
                 + QuotePath(MakePathConform(PathListName));
    if FSplitOutput then CmdM := CmdM + ' -split-output';
    {cdrecord}
    CmdC := ' gracetime=5 dev=' + Device;
    if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
    if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then CmdC := CmdC + ' driver=' + SimulDev + '_simul';
    if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
    if CdrecordUseCustOpts then
      CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then CmdC := CmdC + ' -v';
    if Dummy       then CmdC := CmdC + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        CmdC := CmdC + ' -force';
    if TAO and WritingModeRequired
                   then CmdC := CmdC + ' -tao';
    if DAO         then CmdC := CmdC + ' -dao';
    if RAW         then CmdC := CmdC + ' -' + RAWMode;
    if Overburn and (DAO or RAW) then
                        CmdC := CmdC + ' -overburn';
    if Multi       then CmdC := CmdC + ' -multi';
    {on-the-fly}
    if OnTheFly then
    begin
      {Falls OnTheFly und DAO ode RAW, muß die Sektoranzahl ermittelt werden,
       die dann cdrecord übergeben wird.
       Dies gilt auch, wenn mit cdrecord-ProDVD TAO geschrieben werden soll.
       Möglicherweise in Zukunft immer Größe ermitteln.}
      if (DAO or RAW or (TAO and FSettings.FileFlags.ProDVD)) and Ok then
      begin
        CmdC := CmdC + ' -tsize=' + GetSectorNumber(CmdM) + 's';
      end;
      {ab Win2k ist die Ausführung mit sh.exe nicht mehr nötig.}
      if FSettings.FileFlags.UseSh then
      begin
        {Shell-Kommando zusammenstellen}
        Temp := QuotePath(MakePathConform(StartUpDir + cMkisofsBin));
        CmdM := Temp + CmdM;
        Temp := QuotePath(MakePathConform(StartUpDir + cCdrecordBin));
        CmdC := Temp + CmdC + ' -';
        {Shell-Kommandos pipen}
        CmdOnTheFly := CmdM + '|' + CmdC;
        {diese Kommandozeile als Datei speichern}
        ShCmdName := ProgDataDir + cShCmdFile;
        AssignFile(FHShCmd, ShCmdName);
        Rewrite(FHShCmd);
        WriteLn(FHShCmd, CmdOnTheFly);
        CloseFile(FHShCmd);
      end else
      begin
        {Shell-Kommando zusammenstellen}
        Temp := QuotePath(StartUpDir + cMkisofsBin);
        CmdM := Temp + CmdM;
        Temp := QuotePath(StartUpDir + cCdrecordBin);
        CmdC := Temp + CmdC + ' -';
        {Shell-Kommandos pipen}
        CmdOnTheFly := CmdM + ' | ' + CmdC;
        {Befehl muß in der Windows-Shell ausgeführt werden.}
        CmdOnTheFly := GetEnvVarValue(cComSpec) +
                       ' /c ' + '"' + CmdOnTheFly + '"';
      end;
    end else
    begin
      {den Pfad für das Image anhängen}
      Temp := QuotePath(MakePathConform(IsoPath));
      CmdM := CmdM + ' -output ' + Temp;                            // ' -o '
      if not FSplitOutput then
      begin
        CmdC := CmdC + ' ' + Temp;
      end else
      begin
        for i := 0 to Trunc((CMArgs.CDSize / (1024 * 1024 * 1024))) do
        begin
          CmdC := CmdC + ' ' +
                  QuotePath(MakePathConform(IsoPath + '_' +
                                            Format('%2.2d', [i])));        
        end;
      end;
      {Pfad zu den Programmen erstellen}
      Temp := StartUpDir + cMkisofsBin;
      {$IFDEF QuoteCommandlinePath}
      Temp := QuotePath(Temp);
      {$ENDIF}
      CmdM := Temp + CmdM;
      Temp := StartUpDir + cCdrecordBin;
      {$IFDEF QuoteCommandlinePath}
      Temp := QuotePath(Temp);
      {$ENDIF}
      CmdC := Temp + CmdC;
    end;
  end;
  BurnList.Free;
  if CMArgs.ForcedContinue then
  begin
    FSettings.DataCD.ContinueCD := True;
  end;
  {Kommandos ausführen}
  if not Ok then
  begin
    i := 0;
  end else
  begin
    {$IFDEF Confirm}
    if not (FSettings.CmdLineFlags.ExecuteProject or
            FSettings.General.NoConfirm) then
    begin
      {Brennvorgang starten?}
      i := Application.MessageBox(PChar(FLang.GMS('mburn01')),
                                  PChar(FLang.GMS('mburn02')),
             MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
    end else
    {$ENDIF}
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    if FSettings.DataCD.OnTheFly then
    begin
      {ab Win2k ist die Ausführung mit sh.exe nicht mehr nötig.}
      if FSettings.FileFlags.UseSh then
      begin
        FSettings.Shared.MessageToShow := FLang.GMS('mburn03');
        MessageToShow;
        FSettings.Shared.MessageToShow := CmdOnTheFly;
        MessageToShow;
        Temp := QuotePath(MakePathConform(ProgDataDir + cShCmdFile));
        CmdOnTheFly := StartUpDir + cShBin;
        {$IFDEF QuoteCommandlinePath}
        CmdOnTheFly := QuotePath(CmdOnTheFly);
        {$ENDIF}
        CmdOnTheFly := CmdOnTheFly + ' ' + Temp;
        DisplayDOSOutput(CmdOnTheFly, FMemo, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end else
      begin
        DisplayDOSOutput(CmdOnTheFly, FMemo, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end;
    end else
    begin
      if not FSettings.DataCD.ImageOnly then
      begin
        DisplayDOSOutput(CmdM + CR + CmdC, FMemo, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end else
      begin
        DisplayDOSOutput(CmdM, FMemo, FActionThread, FLang, nil);
      end
    end;
  end else
  {falls Fehler, Button wieder aktivieren}
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.DataCD.PathListName);
    DeleteFile(FSettings.DataCD.ShCmdName);
  end;
end;

{ CreateAudioCD ----------------------------------------------------------------

  Eine Audio-CD erstellen.                                                     }

procedure TCDAction.CreateAudioCD;
var i         : Integer;
    Ok        : Boolean;
    CD        : TCDInfo;
    CMArgs    : TCheckMediumArgs;
    DummyI    : Integer;
    DummyL    : {$IFDEF LargeProject} Comp {$ELSE} Longint {$ENDIF};
    Temp      : string;
    Cmd, CmdMP: string;
    BurnList  : TStringList;
 // CDTime    : Extended;

  { PrepareMP3ToWavConversion --------------------------------------------------

    PrepareMP3ToWavConversion bereitet die Konvertierung der MP3-Dateien in
    Wave-Dateien vor, d.h. es die BurnList wird angepaßt und die entsprechenden
    Madplay-Aufrufe werden generiert. Die Namen der temporären Dateien werden in
    FVList gespeichert.                                                        }

  procedure PrepareMP3ToWavConversion;
  var j             : Integer;
      Source, Target: string;
      CmdTemp       : string;
  begin
    CmdMP := '';
    for j := 0 to BurnList.Count - 1 do
    begin
      Source := BurnList[j];
      if (LowerCase(ExtractFileExt(BurnList[j])) = '.mp3') then
      begin
        Target := FSettings.General.TempFolder + '\' +
                  ExtractFileName(Source) + '.wav';
        BurnList[j] := Target;
        CmdTemp := StartUpDir + cMadplayBin + ' -v -b 16 -R 44100 -o wave:' +
                   QuotePath(Target) + ' ' + QuotePath(Source) + CR;
        FVList.Add(Target);
      end;
      CmdMP := CmdMP + CmdTemp;
    end;
  end;

begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  BurnList := TStringList.Create;
  FData.CreateBurnList(BurnList, cAudioCD);
  CMArgs.Choice := cAudioCD;
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}
  {Spielzeit ermitteln}
  FData.GetProjectInfo(DummyI, DummyI, DummyL, CMArgs.CDTime, DummyI, cAudioCD);
  {Infos über eingelegte CD einlesen}
  ReadCDInfo(CD, FSettings.AudioCD.Device, True);
  Ok := CheckMedium(CD, CMArgs);
  {falls MP3s vorhanden, Konvertierung vorbereiten}
  if FData.MP3FilesPresent then PrepareMP3ToWavConversion;
  {Pfadliste bearbeiten}
  for i := 0 to (BurnList.Count - 1) do
  begin
    {_alle_ Pfadangaben Cygwin-konform machen!}
    BurnList[i] := MakePathConform(BurnList[i]);
  end;
  {CD-Text-Datei erstellen}
  if FSettings.AudioCD.CDText and FData.CDTextPresent then
  begin
    FSettings.AudioCD.CDTextFile := ProgDataDir + cCDTextFile;
    FData.CreateCDTextFile(FSettings.AudioCD.CDTextFile);
  end;
  {Kommandozeile für cdrecord}
  with FSettings.AudioCD, FSettings.Cdrecord do
  begin
    Cmd := StartUpDir + cCdrecordBin;
    {$IFDEF QuoteCommandlinePath}
    Cmd := QuotePath(Cmd);
    {$ENDIF}
    Cmd := Cmd + ' gracetime=5 dev=' + Device;
    if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
    if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
    if CdrecordUseCustOpts then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        Cmd := Cmd + ' -force';
    if TAO and WritingModeRequired
                   then Cmd := Cmd + ' -tao';
    if DAO         then Cmd := Cmd + ' -dao';
    if RAW         then Cmd := Cmd + ' -' + RAWMode;
    if Overburn and (DAO or RAW) then
                        Cmd := Cmd + ' -overburn';
    if Multi       then Cmd := Cmd + ' -multi';
    if not Fix     then Cmd := Cmd + ' -nofix';
    if UseInfo     then Cmd := Cmd + ' -useinfo';
    if CDText      then Cmd := Cmd + ' -text';
    if CDText and FData.CDTextPresent then
                        Cmd := Cmd + ' textfile='
                                   + QuotePath(MakePathConform(CDTextFile));
    if Preemp      then Cmd := Cmd + ' -preemp';
    if Copy        then Cmd := Cmd + ' -copy';
    if SCMS        then Cmd := Cmd + ' -scms';
    Cmd := Cmd + ' -pad';
    for i := 0 to (BurnList.Count - 1) do
    begin
      {padsize für die TrackPausen}
      if (Pause > 0) and not UseInfo then
      begin
        if Pause = 1 then Temp := PauseLength else
                          Temp := FData.GetTrackPause(i);
        if PauseSector then
        begin
          {Länge lieft bereits in Sektoren vor}
          Cmd := Cmd + ' padsize=' + Temp + 's';
        end else
        begin
          {Umrechnen: Sekunden -> Sektoren}
          Temp := IntToStr(StrToInt(Temp) * 75);
          Cmd := Cmd + ' padsize=' + Temp + 's';
        end;
      end;
      {Dateiname}
      BurnList[i] := QuotePath(BurnList[i]);
      Cmd := Cmd + ' ' + BurnList[i];
    end;
  end;
  BurnList.Free;
  {Kommando ausführen}
  if not Ok then
  begin
    i := 0;
  end else
  begin
    {$IFDEF Confirm}
    if not (FSettings.CmdLineFlags.ExecuteProject or
            FSettings.General.NoConfirm) then
    begin
      {Brennvorgang starten?}
      i := Application.MessageBox(PChar(FLang.GMS('mburn01')),
                                  PChar(FLang.GMS('mburn02')),
             MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
    end else
    {$ENDIF}
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    if CmdMP <> '' then Cmd := CmdMP + Cmd;
    DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang, nil);
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.AudioCD.CDTextFile);
  end;
end;

{ CreateXCD --------------------------------------------------------------------

  Image für eine XCD erstellen oder XCD brennen.                               }

procedure TCDAction.CreateXCD;
var i: Integer;
    CmdMode2CDMaker: string;
    CmdC: string;
    Temp: string;
    M2CDMOptions: string;
    BurnList: TStringList;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Dateiliste übernehmen}
  BurnList := TStringList.Create;
  FData.CreateBurnList(BurnList, cXCD);
  {xcd.crc erzeugen}
  if FSettings.XCD.CreateInfoFile then
  begin
    FSettings.XCD.XCDInfoFile := ProgDataDir + cXCDInfoFile;
    if FVList.Count = 0 then
    begin
      FVList.Assign(BurnList);
      CreateXCDInfoFile(FVList);
      Burnlist.Free;
      {zurück zum Hauptthread}
      exit;
    end else
    begin
      FVList.Clear;
    end;
  end;
  {Kommandozeile für mode2cdmaker zusammenstellen: bis 0.8.x wurde alles in die
   Kommandozeile geschrieben. Ab 0.9 werden alle Optionen und Dateinamen in der
   Datei xcd.txt abgelegt, die als Parameterdatei übergeben wird.}
  with FSettings.XCD, FSettings.Cdrecord, FSettings.Cdrdao do
  begin
    XCDParamFile := ProgDataDir + cXCDParamFile;
    CmdMode2CDMaker := StartUpDir + cMode2CDMakerBin;
    {$IFDEF QuoteCommandlinePath}
    CmdMode2CDMaker := QuotePath(CmdMode2CDMaker);
    {$ENDIF}
    CmdMode2CDMaker := CmdMode2CDMaker + ' -paramfile ' +
                       QuotePath(XCDParamFile);
    M2CDMOptions := cMode2CDMakerBin;
    M2CDMOptions := M2CDMOptions + ' -o "' + IsoPath + '"';
    BurnList.Insert(0, '-o');
    BurnList.Insert(1, IsoPath);
    if VolID <> '' then
    begin
      M2CDMOptions := M2CDMOptions + ' -v "' + VolID + '"';
      BurnList.Insert(0, '-v');
      BurnList.Insert(1, VolID);
    end;
    if Ext <> '' then
    begin
      M2CDMOptions := M2CDMOptions + ' -e "' + Ext + '"';
      BurnList.Insert(0, '-e');
      BurnList.Insert(1, Ext);
    end;
    if IsoLevel2 then
    begin
      M2CDMOptions := M2CDMOptions + ' -isolevel2';
      BurnList.Insert(0, '-isolevel2');
    end;
    if IsoLevel1 then
    begin
      M2CDMOptions := M2CDMOptions + ' -isolevel1';
      BurnList.Insert(0, '-isolevel1');
    end;
    if Single then
    begin
      M2CDMOptions := M2CDMOptions + ' -s';
      BurnList.Insert(0, '-s');
    end;
    if KeepExt then
    begin
      M2CDMOptions := M2CDMOptions + ' -x';
      BurnList.Insert(0, '-x');
    end;
    {Parameter-Liste speichern:}
    BurnList.SaveToFile(XCDParamFile);
    BurnList.Free;
    {Dateinamen bearbeiten}
    Temp := IsoPath + cExtCue;
    Temp := MakePathConform(Temp);
    {$IFDEF QuoteCommandlinePath}
    Temp := QuotePath(Temp);
    {$ENDIF}
    CmdC := '';
    if (FSettings.FileFlags.CdrdaoOk and WriteCueImages) or
       (FSettings.FileFlags.CdrdaoOk and not CanWriteCueImage)  then
    begin
      {Kommandozeile für cdrdao}
      CmdC := StartUpDir + cCdrdaoBin;
      {$IFDEF QuoteCommandlinePath}
      CmdC := QuotePath(CmdC);
      {$ENDIF}
      CmdC := CmdC + ' write --device ' + Device;
      if ForceGenericMmc    then CmdC := CmdC +
                                              ' --driver generic-mmc';
      if ForceGenericMmcRaw then CmdC := CmdC +
                                              ' --driver generic-mmc-raw';
      if Speed <> ''        then CmdC := CmdC + ' --speed ' + Speed;
      if Dummy              then CmdC := CmdC + ' --simulate';
      if Overburn           then CmdC := CmdC + ' --overburn';
      CmdC := CmdC + ' ' + Temp;
    end;
    if (not FSettings.FileFlags.CdrdaoOk and CanWriteCueImage) or
       (not WriteCueImages and CanWriteCueImage) then
    begin
      {Kommandozeile für cdrecord}
      CmdC := StartUpDir + cCdrecordBin;
      {$IFDEF QuoteCommandlinePath}
      CmdC := QuotePath(CmdC);
      {$ENDIF}
      CmdC := CmdC + ' gracetime=5 dev=' + Device;
      if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
      if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
      if SimulDrv    then CmdC := CmdC + ' driver=cdr_simul';
      if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
      if CdrecordUseCustOpts then
        CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
      if Verbose     then CmdC := CmdC + ' -v';
      if Dummy       then CmdC := CmdC + ' -dummy';
      if DMASpeedCheck and ForceSpeed then
                          CmdC := CmdC + ' -force';
      if Overburn    then CmdC := CmdC + ' -overburn';
      CmdC := CmdC + ' -dao cuefile=' + Temp;
    end;
  end;
  {Kommando ausführen}
  {$IFDEF Confirm}
  if not (FSettings.CmdLineFlags.ExecuteProject or
          FSettings.General.NoConfirm) then
  begin
    {Brennvorgang starten?}
    i := Application.MessageBox(PChar(FLang.GMS('mburn01')),
                                PChar(FLang.GMS('mburn02')),
           MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
  end else
  {$ENDIF}
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    FSettings.Shared.MessageToShow := FLang.GMS('mburn10');
    MessageToShow;
    FSettings.Shared.MessageToShow := M2CDMOptions;
    MessageToShow;
    if not (FSettings.XCD.ImageOnly or (CmdC = '')) then
    begin
      DisplayDOSOutput(CmdMode2CDMaker + CR + CmdC,
                       FMemo, FActionThread, FLang, nil);
    end else
    begin
      DisplayDOSOutput(CmdMode2CDMaker, FMemo, FActionThread, FLang, nil);
    end;
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.XCD.XCDParamFile);
    if DeleteFile(FSettings.XCD.XCDInfoFile) then
      FData.DeleteFromPathlistByName(ExtractFileName(FSettings.XCD.XCDInfoFile),
                                     '', cXCD);
  end;
end;

{ DeleteCDRW -------------------------------------------------------------------

  DeleteCDRW löscht CD-RWs bzw. Teile davon.                                   }

procedure TCDAction.DeleteCDRW;
var i: Integer;
    Cmd: string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  with FSettings.CDRW do
  begin
    Cmd := StartUpDir + cCdrecordBin;
    {$IFDEF QuoteCommandlinePath}
    Cmd := QuotePath(Cmd);
    {$ENDIF}
    Cmd := Cmd + ' gracetime=9 dev=' + Device;
    if All          then Cmd := Cmd + ' blank=all'     else
    if Fast         then Cmd := Cmd + ' blank=fast'    else
    if OpenSession  then Cmd := Cmd + ' blank=unclose' else
    if BlankSession then Cmd := Cmd + ' blank=session';
    if Force        then Cmd := Cmd + ' -force';
  end;
  with FSettings.Cdrecord do
  begin
    if CdrecordUseCustOpts then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
  end;
  {Kommando ausführen}
  {$IFDEF Confirm}
  if not (FSettings.CmdLineFlags.ExecuteProject or
          FSettings.General.NoConfirm) then
  begin
    {Brennvorgang starten?}
    i := Application.MessageBox(PChar(FLang.GMS('mburn05')),
                                PChar(FLang.GMS('mburn06')),
           MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
  end else
  {$ENDIF}
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
  SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ GetCDInfos -------------------------------------------------------------------

  Infos anzeigen: -scanbus, -prcap, -atip, -toc, -msinfo.                      }

procedure TCDAction.GetCDInfos;
var Cmd: string;
    Temp: string;
    Ok: Boolean;
    CD: TCDInfo;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  if not FSettings.CDInfo.CapInfo then
  begin
    Cmd := StartUpDir + cCdrecordBin;
    {$IFDEF QuoteCommandlinePath}
    Cmd := QuotePath(Cmd);
    {$ENDIF}
    with FSettings.CDInfo do
    begin
      if Scanbus then
      begin
        if FSettings.Drives.UseRSCSI then
          Cmd := Cmd + ' dev=' + FSettings.Drives.RSCSIString;
        Cmd := Cmd + ' -scanbus'
      end else
      begin
        Cmd := Cmd + ' dev=' + Device;
        if Prcap  then Cmd := Cmd + ' -prcap' else
        if Toc    then Cmd := Cmd + ' -toc'   else
        if Atip   then Cmd := Cmd + ' -atip'  else
        if MSInfo then Cmd := Cmd + ' -msinfo';
      end;
    end;
    {Kommando ausführen}
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
    Ok := True;
    {Kapazitäten des Rohlings ausgeben:
     Infos über eingelegte CD einlesen}
    ReadCDInfo(CD, FSettings.CDInfo.Device, True);
    {keine CD}
    if (CD.Size = 0) and (CD.MsInfo = '') then
    begin
      FSettings.Shared.MessageToShow := FLang.GMS('eburn01');
      MessageToShow;
      Ok := False;
    end;
    {fixierte CD}
    if Pos('-1', CD.MsInfo) <> 0 then
    begin
      FSettings.Shared.MessageToShow := FLang.GMS('mburn09');
      MessageToShow;
      Ok := False;
    end;
    {Gesamtkapazität}
    if Ok then
    begin
      Temp := Format(FLang.GMS('mburn07'),
              [FormatFloat(' ##0.##', CD.Size),
               IntToStr(Round(Int(CD.Time)) div 60),
               FormatFloat('0#.##',
                           (CD.Time - (Round(Int(CD.Time)) div 60) * 60))]);
      FSettings.Shared.MessageToShow := Temp;
      MessageToShow;
      {noch frei}
      Temp := Format(FLang.GMS('mburn08'),
              [FormatFloat(' ##0.##', CD.SizeFree),
               IntToStr(Round(Int(CD.TimeFree)) div 60),
               FormatFloat('0#.##',
                       (CD.TimeFree - (Round(Int(CD.TimeFree)) div 60) * 60))]);
      FSettings.Shared.MessageToShow := Temp;
      MessageToShow;
    end;
    FSettings.Shared.MessageToShow := '';
    MessageToShow;
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ DAEReadTOC -------------------------------------------------------------------

  DAEReadTOC liest die TOC einer AudioCD aus und speichert die Informationen
  in FData.DAE.TrackList.                                                      }

procedure TCDAction.DAEReadTOC;
var Output: TStringList;
    TrackList: TStringList;
    CommandLine: string;
    Temp: string;
    i: Integer;
    p: Integer;
    Name: string;
    Seconds: Double;
    Sectors: Integer;
    Size: Double;
    SizeString: string;
    TimeString: string;
    CDPresent: Boolean;
begin
  {$IFDEF DebugReadAudioTOC}
  FormDebug.Memo1.Lines.Add('Reading TOC ...');
  {$ENDIF}
  CDPresent := False;
  Output := TStringList.Create;
  {feststellen, ob CD eingelegt ist, sonst würde cdda2wav auf Benutzereingabe
   warten}
  CommandLine := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  CommandLine := QuotePath(CommandLine);
  {$ENDIF}
  CommandLine := CommandLine + ' dev=' + FSettings.DAE.Device + ' -toc';
  Output.Text := GetDOSOutput(PChar(CommandLine), True);
  if Pos('No disk / Wrong disk!', Output.text) = 0 then
  begin
    CDPresent := True;
  end;
  {Toc auslesen}
  CommandLine := StartUpDir + cCdda2wavBin;
  {$IFDEF QuoteCommandlinePath}
  CommandLine := QuotePath(CommandLine);
  {$ENDIF}
  CommandLine := CommandLine + ' dev=' + FSettings.DAE.Device +
                 ' verbose-level=toc -gui -info-only -no-infofile';
  if CDPresent then
  begin
    Output.Text := GetDOSOutput(PChar(CommandLine), True);
  end;
  {nur die Angaben zu den Tracks sind wichtig}
  for i := Output.Count - 1 downto 0 do
  begin
    if not ((Pos('T', Output[i]) = 1) and (Pos(':', Output[i]) = 4))
       or (Pos('audio', Output[i]) = 0) then
    begin
      Output.Delete(i);
    end else
    begin
      Temp := Output[i];
      Delete(Temp, 1, 1);
      Insert('Track ', Temp, 1);
      Delete(Temp, Pos(':', Temp) + 1, 8);
      Delete(Temp, Pos('audio', Temp), Length(Temp));
      Output[i] := Temp;
    end;
  end;
  {$IFDEF DebugReadAudioTOC}
  FormDebug.Memo3.Lines.Assign(Output);
  {$ENDIF}
  {jetzt den Output zur Trackliste umbauen}
  for i := 0 to Output.Count - 1 do
  begin
    Temp := Output[i];
    {Track-Name}
    p := Pos(':', Temp);
    Name := Copy(Temp, 1, p - 1);
    Delete(Temp, 1, p);
    Temp := Trim(Temp);
    {Laufzeit}
    TimeString := Temp;
    p := Pos(':', Temp);
    Seconds := StrToIntDef(Copy(Temp, 1, p - 1), 0) * 60;
    Delete(Temp, 1, p);
    p := Pos('.', Temp);
    Seconds := Seconds + StrToIntDef(Copy(Temp, 1, p - 1), 0);
    {Größe}
    Delete(Temp, 1, p);
    Sectors := StrToIntDef(Temp, 0);
    Size := (((Seconds * 75) + Sectors) * 2352) / 1024;
    SizeString := FormatFloat('#,###,##0 KiByte', Size);
    {neuen Eintrag zusammenstellen}
    Temp := Name + ':' + TimeString + '*' + SizeString;
    Output[i] := Temp;
  end;
  {TrackListe zuweisen}
  TrackList := FData.GetFileList('', cDAE);
  TrackList.Assign(Output);
  {$IFDEF DebugReadAudioTOC}
  FormDebug.Memo2.Lines.Assign(TrackList);
  {$ENDIF}
  Output.Free;
end;

{ DAEGrabTracks ----------------------------------------------------------------

  DAEGrabTracks liest die ausgewählte Titel aus.                               }

procedure TCDAction.DAEGrabTracks;
var TrackList, TempList: TStringList;
    i, a, b: Byte;
    Temp: string;
    CommandLine: string;
    Cmd: string;
    OutPath: string;
    Suffix: string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  TempList := TStringList.Create;
  TrackList := TStringList.Create;
  {zuerst die Trackliste verarbeiten}
  TrackList.CommaText := FSettings.DAE.Tracks;
  TempList.CommaText := FSettings.DAE.Tracks;
  {aufeinanderfolgende Tracknummern markieren}
  for i := TempList.Count - 1 downto 1 do
  begin
    a := StrToInt(TempList[i]);
    b := StrToInt(TempList[i - 1]);
    if a = b + 1 then
    begin
      TrackList[i - 1] := TrackList[i - 1] + '+';
    end;
  end;
  {aufeinanderfolgende Tracknummern zusammenführen}
  for i := TrackList.Count -1 downto 1 do
  begin
    if Pos('+', TrackList[i - 1]) > 0 then
    begin
      TrackList[i - 1] := TrackList[i - 1] + TrackList[i];
      TrackList.Delete(i);
    end;
  end;
  {Einträge für die Kommandozeile vorbereiten}
  for i := 0 to TrackList.Count - 1 do
  begin
    if Pos('+', TrackList[i]) = 0 then
    begin
      TrackList[i] := TrackList[i] + '+' + TrackList[i];
    end else
    begin
      a := 1;
      Temp := TrackList[i];
      while Pos('+', Temp) > 0 do
      begin
        a := Pos('+', Temp);
        Delete(Temp, a, 1);
        Insert('*', Temp, a);
      end;
      Insert('+', Temp, a+1);
      a := Pos('*', Temp);
      b := Pos('+', Temp);
      Delete(Temp, a, b - a);
      TrackList[i] := Temp;
    end;
  end;
  {unveränderlichen Teil der Kommandozeile zusammenstellen}
  with FSettings.DAE do
  begin
    CommandLine := StartUpDir + cCdda2wavBin;
    {$IFDEF QuoteCommandlinePath}
    CommandLine := QuotePath(CommandLine);
    {$ENDIF}
    CommandLine := CommandLine + ' dev=' + Device;
    if Speed <> '' then CommandLine := CommandLine + ' speed=' + Speed;
    CommandLine := CommandLine + ' verbose-level=summary';
    CommandLine := CommandLine + ' -gui';
    if Bulk       then CommandLine := CommandLine + ' -bulk';
    if NoInfoFile then CommandLine := CommandLine + ' -no-infofile';
    if Paranoia   then CommandLine := CommandLine + ' -paranoia';
    if Path[Length(Path)] <> '\' then Path := Path + '\';
    OutPath := MakePathConform(Path + Prefix);
  end;
  for i := 0 to TrackList.Count - 1 do
  begin
    {Sonderbehandlung für einzelne Tracks, sonst fehlt die Tracknummer}
    Suffix := '';
    a := Pos('+', TrackList[i]);
    if Copy(TrackList[i], 1, a - 1) =
       Copy(TrackList[i], a + 1, Length(TrackList[i])) then
    begin
      Temp := Copy(TrackList[i], 1, a - 1);
      if Length(Temp) = 1 then
      begin
        Insert('0', Temp, 1);
      end;
      Suffix := '_' + Temp;
    end;
    {Kommandozeile zusammenstellen}
    Cmd := Cmd + CommandLine + ' track=' + TrackList[i] + ' ' +
           QuotePath(OutPath + Suffix) + CR;
  end;
  DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang, nil);
  TrackList.Free;
  TempList.Free;
end;

{ ReadImage --------------------------------------------------------------------

  Image von einer CD erstellen.                                                }

procedure TCDAction.ReadImage;
var Cmd: string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Cmd := StartUpDir + cReadcdBin;
  {$IFDEF QuoteCommandlinePath}
  Cmd := QuotePath(Cmd);
  {$ENDIF}
  with FSettings.Readcd do
  begin
    Cmd := Cmd + ' dev=' + Device;
    if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
    if Clone   then Cmd := Cmd + ' -clone';
    if Nocorr  then Cmd := Cmd + ' -nocorr';
    if Noerror then Cmd := Cmd + ' -noerror';
    if Range   then Cmd := Cmd + ' sectors=' + Startsec + '-' + Endsec;
    IsoPath := MakePathConform(IsoPath);
    {$IFDEF QuoteCommandlinePath}
    IsoPath := QuotePath(IsoPath);
    {$ENDIF}
    Cmd := Cmd + ' f=' + IsoPath;
  end;
  DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang, nil);
end;

{ WriteImage -------------------------------------------------------------------

  ISO- oder CUE-Images aud CD schreiben.                                       }

procedure TCDAction.WriteImage;
var i: Integer;
    Cmd: string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
//  if Pos(cExtIso, LowerCase(FSettings.Image.IsoPath)) > 0 then
  if Pos(cExtCue, LowerCase(FSettings.Image.IsoPath)) = 0 then
  begin
    with FSettings.Cdrecord, FSettings.Image do
    begin
      Cmd := StartUpDir + cCdrecordBin;
      {$IFDEF QuoteCommandlinePath}
      Cmd := QuotePath(Cmd);
      {$ENDIF}
      Cmd := Cmd + ' gracetime=5 dev=' + Device;
      if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
      if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
      if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
      if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
      if CdrecordUseCustOpts then
        Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
      if Verbose     then Cmd := Cmd + ' -v';
      if Dummy       then Cmd := Cmd + ' -dummy';
      if DMASpeedCheck and ForceSpeed then
                          Cmd := Cmd + ' -force';
      if TAO and WritingModeRequired
                     then Cmd := Cmd + ' -tao';
      if DAO         then Cmd := Cmd + ' -dao';
      if RAW         then Cmd := Cmd + ' -' + RAWMode;
      if Overburn and (DAO or RAW) then
                          Cmd := Cmd + ' -overburn';
      if Clone and RAW then
                          Cmd := Cmd + ' -clone';
      Cmd := Cmd + ' ' + QuotePath(MakePathConform(IsoPath));
    end;
  end else
  begin
    with FSettings.Image, FSettings.Cdrdao, FSettings.Cdrecord do
    begin
      {Kommandozeile für cdrdao}
      if (FSettings.FileFlags.CdrdaoOk and WriteCueImages) or
         (FSettings.FileFlags.CdrdaoOk and not CanWriteCueImage) then
      begin
        Cmd := StartUpDir + cCdrdaoBin;
        {$IFDEF QuoteCommandlinePath}
        Cmd := QuotePath(Cmd);
        {$ENDIF}
        Cmd := Cmd + ' write --device ' + Device;
        if ForceGenericMmc          then Cmd := Cmd + ' --driver generic-mmc' else
        if ForceGenericMmcRaw       then Cmd := Cmd + ' --driver generic-mmc-raw';
        if Speed <> ''              then Cmd := Cmd + ' --speed ' + Speed;
        if FSettings.Cdrecord.Dummy then Cmd := Cmd + ' --simulate';
        if Overburn                 then Cmd := Cmd + ' --overburn';
        Cmd := Cmd + ' ' + QuotePath(MakePathConform(IsoPath));
      end;
      if (not FSettings.FileFlags.CdrdaoOk and CanWriteCueImage) or
         (not WriteCueImages and CanWriteCueImage) then
      begin
        {Kommandozeile für cdrecord}
        Cmd := StartUpDir + cCdrecordBin;
        {$IFDEF QuoteCommandlinePath}
        Cmd := QuotePath(Cmd);
        {$ENDIF}
        Cmd := Cmd + ' gracetime=5 dev=' + Device;
        if Speed <> '' then Cmd := Cmd + ' speed=' + Speed;
        if FIFO        then Cmd := Cmd + ' fs=' + IntToStr(FIFOSize) + 'm';
        if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
        if Burnfree    then Cmd := Cmd + ' driveropts=burnfree';
        if CdrecordUseCustOpts then
          Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
        if Verbose     then Cmd := Cmd + ' -v';
        if Dummy       then Cmd := Cmd + ' -dummy';
        if DMASpeedCheck and ForceSpeed then
                            Cmd := Cmd + ' -force';
        if Overburn    then Cmd := Cmd + ' -overburn';
        Cmd := Cmd + ' -dao cuefile=' +
                     QuotePath(MakePathConform(IsoPath));
      end;

    end;
  end;
  {Kommando ausführen}
  {$IFDEF Confirm}
  if not (FSettings.CmdLineFlags.ExecuteProject or
          FSettings.General.NoConfirm) then
  begin
    {Brennvorgang starten?}
    i := Application.MessageBox(PChar(FLang.GMS('mburn01')),
                                PChar(FLang.GMS('mburn02')),
           MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
  end else
  {$ENDIF}
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang,
                     FSettings.Environment.EnvironmentBlock);
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ WriteTOC ---------------------------------------------------------------------

  Eine CD fixieren.                                                            }

procedure TCDAction.WriteTOC;
var Cmd: string;
    i: Integer;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Kommandozeile zusammenstellen}
  Cmd := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  Cmd := QuotePath(Cmd);
  {$ENDIF}
  with FSettings.Cdrecord do
  begin
    Cmd := Cmd + ' gracetime=5 dev=' + FixDevice;
    if SimulDrv    then Cmd := Cmd + ' driver=cdr_simul';
    if CdrecordUseCustOpts then
      Cmd := Cmd + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then Cmd := Cmd + ' -v';
    if Dummy       then Cmd := Cmd + ' -dummy';
    Cmd := Cmd + ' -fix';
  end;
  {Kommando ausführen}
  {$IFDEF Confirm}
  if not FSettings.General.NoConfirm then
  begin
    {Fixieren starten?}
    i := Application.MessageBox(PChar(FLang.GMS('mburn11')),
                                PChar(FLang.GMS('mburn02')),
           MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
  end else
  {$ENDIF}
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    DisplayDOSOutput(Cmd, FMemo, FActionThread, FLang, nil);
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ StartVerification ------------------------------------------------------------

  Vergleich der Quelldateien mit den geschriebenen Dateien. Die Prozedur
  StartVerifyDataCD wird nicht verwendet, stattdessen wird der Thread hier
  direkt gestartet, weil auch der Fortschritt angezeigt werden soll. Dafür
  müßten aber zu viele Argumente an die Prozedur übergeben werden.
  Ein Verify ist sowohl für Daten- als auch für XCDs möglich.                  }

procedure TCDAction.StartVerification(const Action: Byte);
var Device: string;
    Drive : string;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  FProgressBar.Visible := True;
  FProgressBar.Max := 100;
  FProgressBar.Position := 0;
  {Pfadlisten in FVList laden}
  FVList.Clear;
  case Action of
    cVerify   : begin
                  Device := FSettings.DataCD.Device;
                  FData.CreateVerifyList(FVList, cDataCD);
                end;
    cVerifyXCD: begin
                  Device := FSettings.XCD.Device;
                  FData.CreateVerifyList(FVList, cXCD);
                end;
  end;
  Drive := FDevices.GetDriveLetter(Device);
  {Thread starten}
  FVerificationThread := TVerificationThread.Create(FVList, FMemo, Device,
                                                    FLang, True);
  FVerificationThread.FreeOnTerminate := True;
  {jetzt weitere (optionale) Properties setzen}
  if Action = cVerifyXCD then
  begin
    FVerificationThread.XCD := True;
    FVerificationThread.XCDExt := FSettings.XCD.Ext;
    FVerificationThread.XCDKeepExt := FSettings.XCD.KeepExt;
  end;
  FVerificationThread.StatusBar := FStatusBar;
  FVerificationThread.ProgressBar := FProgressBar;
  FVerificationThread.AutoExec := FSettings.CmdLineFlags.ExecuteProject;
  FVerificationThread.Reload := FReload;
  FVerificationThread.Drive := Drive;
  {Thread starten}
  FVerificationThread.Resume;
  {Reload zurücksetzten}
  FReload := True;
end;

{ CreateVideoCD ----------------------------------------------------------------

  Image für eine VideoCD erstellen oder VideoCD brennen.                       }

procedure TCDAction.CreateVideoCD;
var i: Integer;
    CmdVCDIm: string;
    CmdC: string;
    Temp: string;
    CueFile: string;
    BurnList: TStringList;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  {Dateiliste übernehmen}
  BurnList := TStringList.Create;
  FData.CreateBurnList(BurnList, cVideoCD);
  {$IFDEF ShowBurnList}
  FormDebug.Memo2.Lines.Assign(BurnList);
  {$ENDIF}  
  with FSettings.VideoCD, FSettings.Cdrecord, FSettings.Cdrdao do
  begin
    {Kommandozeile für VCDImager zusammenstellen.}
    CmdVCDIm := StartUpDir + cVCDImagerBin;
    {$IFDEF QuoteCommandlinePath}
    CmdVCDIm := QuotePath(CmdVCDIm);
    {$ENDIF}
    CmdVCDIm := CmdVCDIm + ' -p';
    if FSettings.VideoCD.Verbose then
    begin
      CmdVCDIm := CmdVCDIm + ' -v';
    end;
    CmdVCDIm := CmdVCDIm  + ' --type=';
    if VCD1 then
    begin
      CmdVCDIm := CmdVCDIm + 'vcd11';
    end else
    if VCD2 then
    begin
      CmdVCDIm := CmdVCDIm + 'vcd2';
    end else
    if SVCD then
    begin
      CmdVCDIm := CmdVCDIm + 'svcd';
    end;
    {Dateinamen bearbeiten}
    CueFile := IsoPath + cExtCue;
    CueFile := MakePathConform(CueFile);
    {$IFDEF QuoteCommandlinePath}
    CueFile := QuotePath(CueFile);
    {$ENDIF}
    CmdVCDIm := CmdVCDIm + ' --cue-file=' + CueFile;
    Temp := IsoPath + cExtBin;
    Temp := MakePathConform(Temp);
    {$IFDEF QuoteCommandlinePath}
    Temp := QuotePath(Temp);
    {$ENDIF}
    CmdVCDIm := CmdVCDIm + ' --bin-file=' + Temp;
    if VolID <> '' then
    begin
      CmdVCDIm := CmdVCDIm + ' --iso-volume-label="' + VolID + '"';
    end;
    if SVCD and SVCDCompat then
    begin
      CmdVCDIm := CmdVCDIm + ' --broken-svcd-mode';
    end;
    if Sec2336 then
    begin
      CmdVCDIm := CmdVCDIm + ' --sector-2336';
    end;
    {Jetzt die Tracks hinzufügen}
    {Pfadliste bearbeiten}
    for i := 0 to (BurnList.Count - 1) do
    begin
      {_alle_ Pfadangaben Cygwin-konform machen!}
      BurnList[i] := MakePathConform(BurnList[i]);
      {$IFDEF QuoteCommandlinePath}
      Temp := QuotePath(BurnList[i]);
      {$ENDIF}
      CmdVCDIm := CmdVCDIm + ' ' + Temp;
    end;
    BurnList.Free;
    {cdrecord/cdrdao}
    CmdC := '';
    if (FSettings.FileFlags.CdrdaoOk and WriteCueImages) or
       (FSettings.FileFlags.CdrdaoOk and not CanWriteCueImage)  then
    begin
      {Kommandozeile für cdrdao}
      CmdC := StartUpDir + cCdrdaoBin;
      {$IFDEF QuoteCommandlinePath}
      CmdC := QuotePath(CmdC);
      {$ENDIF}
      CmdC := CmdC + ' write --device ' + Device;
      if ForceGenericMmc    then CmdC := CmdC +
                                              ' --driver generic-mmc';
      if ForceGenericMmcRaw then CmdC := CmdC +
                                              ' --driver generic-mmc-raw';
      if Speed <> ''        then CmdC := CmdC + ' --speed ' + Speed;
      if Dummy              then CmdC := CmdC + ' --simulate';
      if Overburn           then CmdC := CmdC + ' --overburn';
      CmdC := CmdC + ' ' + CueFile;
    end;
    if (not FSettings.FileFlags.CdrdaoOk and CanWriteCueImage) or
       (not WriteCueImages and CanWriteCueImage) then
    begin
      {Kommandozeile für cdrecord}
      CmdC := StartUpDir + cCdrecordBin;
      {$IFDEF QuoteCommandlinePath}
      CmdC := QuotePath(CmdC);
      {$ENDIF}
      CmdC := CmdC + ' gracetime=5 dev=' + Device;
      if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
      if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
      if SimulDrv    then CmdC := CmdC + ' driver=cdr_simul';
      if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
      if CdrecordUseCustOpts then
        CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
      if Verbose     then CmdC := CmdC + ' -v';
      if Dummy       then CmdC := CmdC + ' -dummy';
      if DMASpeedCheck and ForceSpeed then
                          CmdC := CmdC + ' -force';
      if Overburn    then CmdC := CmdC + ' -overburn';
      CmdC := CmdC + ' -dao cuefile=' + CueFile;
    end;
  end;
  {Kommando ausführen}
  {$IFDEF Confirm}
  if not (FSettings.CmdLineFlags.ExecuteProject or
          FSettings.General.NoConfirm) then
  begin
    {Brennvorgang starten?}
    i := Application.MessageBox(PChar(FLang.GMS('mburn01')),
                                PChar(FLang.GMS('mburn02')),
           MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
  end else
  {$ENDIF}
  begin
    i := 1;
  end;
  if i = 1 then
  begin
    if not (FSettings.VideoCD.ImageOnly or (CmdC = '')) then
    begin
      DisplayDOSOutput(CmdVCDIm + CR + CmdC,
                       FMemo, FActionThread, FLang, nil);
    end else
    begin
      DisplayDOSOutput(CmdVCDIm, FMemo, FActionThread, FLang, nil);
    end;
  end else
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
  end;
end;

{ CreateVideoDVD ---------------------------------------------------------------

  Aus einen Quellverzeichnis eine Video-DVD erstellen. Zur Zeit nur on-the-fly,
  keine Imageerstellung.                                                       }

procedure TCDACtion.CreateVideoDVD;
var Ok: Boolean;
    i: Integer;
    CmdC, CmdM, CmdOnTheFly: string;
    Temp: string;
    SimulDev: string;
    FHShCmd: TextFile;
begin
  SendMessage(FFormHandle, WM_ButtonsOff, 0, 0);
  Ok := True;
  if FSettings.FileFlags.ProDVD then SimulDev := 'dvd' else SimulDev := 'cdr';
  {Hier sollte noch beispielsweise das Medium überprüft werden ...}

  CmdM := ' -dvd-video';
  with FSettings.DVDVideo, FSettings.General, FSettings.Cdrecord do
  begin
    {mkisofs}
    if MkisofsUseCustOpts then
      CmdM := CmdM + ' ' + MkisofsCustOpts[MkisofsCustOptsIndex];
    CmdM := CmdM + ' ' + QuotePath(MakePathConform(SourcePath));
    {cdrecord}
    CmdC := ' gracetime=5 dev=' + Device;
    if Speed <> '' then CmdC := CmdC + ' speed=' + Speed;
    if FIFO        then CmdC := CmdC + ' fs=' + IntToStr(FIFOSize) + 'm';
    if SimulDrv    then CmdC := CmdC + ' driver=' + SimulDev + '_simul';
    if Burnfree    then CmdC := CmdC + ' driveropts=burnfree';
    if CdrecordUseCustOpts then
      CmdC := CmdC + ' ' + CdrecordCustOpts[CdrecordCustOptsIndex];
    if Verbose     then CmdC := CmdC + ' -v';
    if Dummy       then CmdC := CmdC + ' -dummy';
    if DMASpeedCheck and ForceSpeed then
                        CmdC := CmdC + ' -force';
    CmdC := CmdC + ' -dao';

    {on-the-fly}
    if True {FSettings.DVDVideo.OnTheFly} then
    begin
      {DVDs werden immer in DAO geschrieben, also Sektoranzahl ermitteln}
      CmdC := CmdC + ' -tsize=' + GetSectorNumber(CmdM) + 's';
      {ab Win2k ist die Ausführung mit sh.exe nicht mehr nötig.}
      if FSettings.FileFlags.UseSh then
      begin
        {Shell-Kommando zusammenstellen}
        Temp := QuotePath(MakePathConform(StartUpDir + cMkisofsBin));
        CmdM := Temp + CmdM;
        Temp := QuotePath(MakePathConform(StartUpDir + cCdrecordBin));
        CmdC := Temp + CmdC + ' -';
        {Shell-Kommandos pipen}
        CmdOnTheFly := CmdM + '|' + CmdC;
        {diese Kommandozeile als Datei speichern}
        ShCmdName := ProgDataDir + cShCmdFile;
        AssignFile(FHShCmd, ShCmdName);
        Rewrite(FHShCmd);
        WriteLn(FHShCmd, CmdOnTheFly);
        CloseFile(FHShCmd);
      end else
      begin
        {Shell-Kommando zusammenstellen}
        Temp := QuotePath(StartUpDir + cMkisofsBin);
        CmdM := Temp + CmdM;
        Temp := QuotePath(StartUpDir + cCdrecordBin);
        CmdC := Temp + CmdC + ' -';
        {Shell-Kommandos pipen}
        CmdOnTheFly := CmdM + ' | ' + CmdC;
        {Befehl muß in der Windows-Shell ausgeführt werden.}
        CmdOnTheFly := GetEnvVarValue(cComSpec) +
                       ' /c ' + '"' + CmdOnTheFly + '"';
      end;
    end else
    begin
      (*
      {den Pfad für das Image anhängen}
      Temp := QuotePath(MakePathConform(IsoPath));
      CmdM := CmdM + ' -output ' + Temp;                            // ' -o '
      CmdC := CmdC + ' ' + Temp;
      {Pfad zu den Programmen erstellen}
      Temp := StartUpDir + cMkisofsBin;
      {$IFDEF QuoteCommandlinePath}
      Temp := QuotePath(Temp);
      {$ENDIF}
      CmdM := Temp + CmdM;
      Temp := StartUpDir + cCdrecordBin;
      {$IFDEF QuoteCommandlinePath}
      Temp := QuotePath(Temp);
      {$ENDIF}
      CmdC := Temp + CmdC;
      *)
    end;
  end;

  {Kommandos ausführen}
  if not Ok then
  begin
    i := 0;
  end else
  begin
    {$IFDEF Confirm}
    if not (FSettings.CmdLineFlags.ExecuteProject or
            FSettings.General.NoConfirm) then
    begin
      {Brennvorgang starten?}
      i := Application.MessageBox(PChar(FLang.GMS('mburn01')),
                                  PChar(FLang.GMS('mburn02')),
             MB_OKCANCEL or MB_SYSTEMMODAL or MB_ICONQUESTION);
    end else
    {$ENDIF}
    begin
      i := 1;
    end;
  end;
  if i = 1 then
  begin
    CheckEnvironment(FSettings);
    {Zur Zeir nichts anderes als otf möglich!}
    if True {FSettings.DVDVideo.OnTheFly} then
    begin
      CheckEnvironment(FSettings);
      {ab Win2k ist die Ausführung mit sh.exe nicht mehr nötig.}
      if FSettings.FileFlags.UseSh then
      begin
        FSettings.Shared.MessageToShow := FLang.GMS('mburn03');
        MessageToShow;
        FSettings.Shared.MessageToShow := CmdOnTheFly;
        MessageToShow;
        Temp := QuotePath(MakePathConform(ProgDataDir + cShCmdFile));
        CmdOnTheFly := StartUpDir + cShBin;
        {$IFDEF QuoteCommandlinePath}
        CmdOnTheFly := QuotePath(CmdOnTheFly);
        {$ENDIF}
        CmdOnTheFly := CmdOnTheFly + ' ' + Temp;
        DisplayDOSOutput(CmdOnTheFly, FMemo, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end else
      begin
        DisplayDOSOutput(CmdOnTheFly, FMemo, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end;
    end else
    begin
      {
      if not FSettings.DVDVideo.ImageOnly then
      begin
        DisplayDOSOutput(CmdM + CR + CmdC, FMemo, FActionThread, FLang,
                         FSettings.Environment.EnvironmentBlock);
      end else
      begin
        DisplayDOSOutput(CmdM, FMemo, FActionThread, FLang, nil);
      end
      }
    end;
  end else
  {falls Fehler, Button wieder aktivieren}
  begin
    SendMessage(FFormHandle, WM_ButtonsOn, 0, 0);
    DeleteFile(FSettings.DataCD.ShCmdName);
  end;
end;

{ TAction - public }

constructor TCDAction.Create;
begin
  inherited Create;
  FAction := cNoAction;
  FLastAction := cNoAction;
  FVList := TSTringList.Create;
  // FTempBurnList := TStringList.Create;
  FReload := True;
  FDupSize := 0;
  FSplitOutput := False;
end;

destructor TCDAction.Destroy;
begin
  FVList.Free;
  // FTempBurnList.Free;
  inherited Destroy;
end;

{ StartAction ------------------------------------------------------------------

  StartAction führt die gewählte Aktion aus. Die Aktion wird mit der Eigenschaft
  Action festgelegt.                                                           }

procedure TCDAction.StartAction;
var TempAction: Byte;
begin
  TempAction := Action;
  case TempAction of
    cDataCD    : CreateDataCD;
    cAudioCD   : CreateAudioCD;
    cXCD       : CreateXCD;
    cCDRW      : DeleteCDRW;
    cCDInfos   : GetCDInfos;
    cDAE       : DAEGrabTracks;
    cCDImage   : begin
                   case FSettings.General.ImageRead of
                     True : ReadImage;
                     False: WriteImage;
                   end;
                 end;
    cVideoCD   : CreateVideoCD;
    cDVDVideo  : CreateVideoDVD;
    cDAEReadTOC: DAEReadTOC;
    cFixCD     : WriteTOC;
    cVerify,
    cVerifyXCD : StartVerification(TempAction);
  end;
end;

{ AbortAction ------------------------------------------------------------------

  AbortAction bricht den laufenden Thread ab.                                  }

procedure TCDAction.AbortAction;
begin
  if FActionThread <> nil then TerminateExecution(FActionThread);
  if FVerificationThread <> nil then TerminateVerification(FVerificationThread);
end;

{ Reset ------------------------------------------------------------------------

  setzt einige der internen Variablen zurück.                                  }

procedure TCDAction.Reset;
begin
  FVList.Clear;
end;

{ CleanUp ----------------------------------------------------------------------

  CleanUp löscht temporäre Dateien.                                            }

procedure TCDAction.CleanUp(const Phase: Byte);
var i: Integer;
begin
  {Phase 1: TForm1.WMITerminated}
  if Phase = 1 then
  begin
    DeleteFile(FSettings.XCD.XCDInfoFile);
  end else
  {Phase 2: TForm1.WMTTerminated}
  if Phase = 2 then
  begin
    if FLastAction = cDataCD then
    begin
      DeleteFile(FSettings.DataCD.PathListName);
      DeleteFile(FSettings.DataCD.ShCmdName);
      if not (FSettings.DataCD.ImageOnly or FSettings.DataCD.KeepImage) then
      begin
        if not FSplitOutput then
        begin
          DeleteFile(FSettings.DataCD.IsoPath);
        end else
        begin
          i := 0;
          while FileExists(FSettings.DataCD.IsoPath + '_' +
                           Format('%2.2d', [i])) do
          begin
            DeleteFile(FSettings.DataCD.IsoPath + '_' + Format('%2.2d', [i]));
            Inc(i);
          end;
        end;
      end;
    end;

    if FLastAction = cAudioCD then
    begin
      DeleteFile(FSettings.AudioCD.CDTextFile);
      {temporäre Wave-Dateien löschen}
      if FData.MP3FilesPresent then
      begin
        for i := 0 to FVList.Count - 1 do DeleteFile(FVList[i]);
      end;
    end;

    if FLastAction = cXCD then
    begin
      DeleteFile(FSettings.XCD.XCDParamFile);
      if not (FSettings.XCD.ImageOnly or FSettings.XCD.KeepImage) then
      begin
        DeleteFile(FSettings.XCD.IsoPath + cExtBin);
        DeleteFile(FSettings.XCD.IsoPath + cExtToc);
        DeleteFile(FSettings.XCD.IsoPath + cExtCue);
      end;
    end;

    if FLastAction = cDVDVideo then
    begin
      DeleteFile(FSettings.DVDVideo.ShCmdName);
    end;

    if FLastAction = cVideoCD then
    begin
      if not (FSettings.VideoCD.ImageOnly or FSettings.VideoCD.KeepImage) then
      begin
        DeleteFile(FSettings.VideoCD.IsoPath + cExtBin);
        DeleteFile(FSettings.VideoCD.IsoPath + cExtCue);
      end;
    end;

  end else
  {Phase 3: TForm1.WMVTerminated}
  if Phase = 3 then
  begin
    if FLastAction = cXCD then
    begin
      {XCD-Info-Datei löschen und aus Dateiliste entfernen}
      if DeleteFile(FSettings.XCD.XCDInfoFile) then
        FData.DeleteFromPathlistByName(ExtractFileName(FSettings.XCD.XCDInfoFile),
                                       '', cXCD);
    end;
    FLastAction := cNoAction;
  end;
end;

end.
