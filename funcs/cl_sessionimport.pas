{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_sessionimport.pas: Auswählen und Importieren von vorigen Sessions

  Copyright (c) 2008 Oliver Valencia

  letzte Änderung  10.07.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_sessionimport.pas implementiert Objekte und Funktionen, die beim Auswählen
  und Importieren von vereits vorhandenen Sessions helfen.


  TSessionImportHelper

    Properties   Device
                 Drive
                 MediumInfo
                 StartSector

    Methoden     Create
                 GetSession
                 
}


unit cl_sessionimport;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils, StdCtrls, Controls, f_largeint;

type TGetFileSysMode = (gfsmPVD, gfsmISO, gfsmRR, gfsmJoliet);

     TSessionImportHelper = class(TObject)
     private
       FDevice     : string;
       FDrive      : string;
       FHasJoliet  : Boolean;
       FHasRR      : Boolean;
       FMediumInfo : string;
       FStartSector: string;
       FSectorList : string;
       FVolID      : string;
       FSpaceUsed  : {$IFDEF LargeProject} Int64 {$ELSE} Longint {$ENDIF};
       function DiskPresent: Boolean;
       procedure CheckSession;
       procedure ConvertPathlistToTreeStructure(List, Structure: TStringList);
       procedure ExtractSessionData;
       procedure GetDiskInfo;           // -minfo
       procedure GetFileSysInfo(const Mode: TGetFileSysMode);
       procedure GetSessionContent;
       procedure GetSpaceUsed;
       procedure ParseFolder;
       procedure ParseFiles;
       procedure SelectSession;
     public
       constructor Create;
       destructor Destroy; override;
       procedure GetSession;
       procedure GetSessionUser;
       property Device     : string write FDevice;
       property Drive      : string write FDrive;
       property MediumInfo : string read FMediumInfo write FMediumInfo;
       property StartSector: string read FStartSector;
     end;

implementation

uses f_logfile, cl_cdrtfedata, cl_lang, f_misc, f_process, f_helper, f_strings,
     f_filesystem, constant, cl_cd;

const SearchDir    : string = 'Directory listing of ';
      SearchDirID  : string = 'd---------';
      SearchDirIDRR: string = ' dr-';
      SearchVolID  : string = 'Volume id: ';
      SearchJoliet : string = 'Joliet with';
      SearchRR     : string = 'Rock Ridge signatures version';

type TFormSelectSession = class(TForm)
       FLang       : TLang;
       StaticText  : TStaticText;
       ComboBox    : TComboBox;
       ButtonOk    : TButton;
       ButtonCancel: TButton;
       procedure FormShow(Sender: TObject);
       procedure ButtonClick(Sender: TObject);
       procedure ButtonCancelClick(Sender: TObject);
       procedure FormDestroy(Sender: TObject);
     private
       FStartSector: string;
       FSectorList : string;
       FSecList    : TStringList;
       procedure Init;
     public
       property Lang       : TLang write FLang;
       property StartSector: string read FStartSector;
       property SectorList : string write FSectorList;
     end;

{ TFormSelectSession --------------------------------------------------------- }

{ TFormSelectSession - private }

procedure TFormSelectSession.Init;
var i: Integer;
begin
  SetFont(Self);
  {Form}
  Caption := FLang.GMS('msess01');
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu];
  ClientHeight := 180;
  ClientWidth := 220;
  OnShow := FormShow;
  OnDestroy := FormDestroy;
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
    Caption := FLang.GMS('msess02');
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
  FSecList := TStringList.Create;
  FSecList.CommaText := FSectorList;
  for i := 0 to FSecList.Count - 1 do
  begin
    ComboBox.Items.Add(FLang.GMS('msess03') + ' ' + IntToStr(i + 1));
  end;
  ComboBox.ItemIndex := ComboBox.Items.Count - 1;
end;

procedure TFormSelectSession.FormShow(Sender: TObject);
begin
  ButtonCancel.SetFocus;
end;

procedure TFormSelectSession.ButtonClick(Sender: TObject);
begin
  ModalResult := mrOk;
  FStartSector := FSecList[ComboBox.ItemIndex];
end;

procedure TFormSelectSession.ButtonCancelClick(Sender: TObject);
begin
  FStartSector := FSecList[ComboBox.Items.Count - 1];
end;

procedure TFormSelectSession.FormDestroy;
begin
  FSecList.Free;
end;

{ TFormSelectSession - public }


{ TSessionImportHelper ------------------------------------------------------- }

{ TSessionImportHelper - private }

{ DiskPresent ------------------------------------------------------------------

  True, wenn eine Disk eingelegt ist, False sonst.                             }

function TSessionImportHelper.DiskPresent: Boolean;
begin
  Result := Pos('Track  Sess Type', FMediumInfo) > 0;
end;

{ ConvertPathlistToTreeStructure -----------------------------------------------

  Wandelt die Liste aus Orndereinträgen in eine in TCD importierbare Liste.    }

procedure TSessionImportHelper.ConvertPathlistToTreeStructure(List, Structure:
                                                                   TStringList);
var FolderTree: TCD;

  procedure Init;
  begin
    FolderTree := TCD.Create;
  end;

  procedure Free;
  begin
    FolderTree.Free;
  end;

  procedure PrepareList(List: TStringList);
  var i, c: Integer;
      Temp: string;
  begin
    {für jeden Eintrag die Slashes zählen und Anzahl am Anfang einfügen}
    for i := 0 to List.Count - 1 do
    begin
      Temp := List[i];
      Delete(Temp, 1, 1);
      c := CountChar(Temp, '/');
      List[i] := Format('%.2d', [c]) + Temp;
    end;
    {Liste sortieren}
    List.Sort;
  end;

  procedure ConvertListToTree(List: TStringList);
  var i, p        : Integer;
      Path, Folder: string;
  begin
    for i := 0 to List.Count - 1 do
    begin
      Path := List[i];
      {Zahl und letzten Slash entfernen}
      Delete(Path, 1, 2);
      Delete(Path, Length(Path), 1);
      {Wurzelverzeichnis oder normaler Ordner?}
      if Path = '' then
      begin
        {Wurzel}
        FolderTree.SetCDLabel(FVolID);
      end else
      begin
        p := LastDelimiter('/', Path);
        if p = 0 then
        begin
          {Ordner 1.Ebene}
          Folder := Path;
          Path := '';
        end else
        begin
          {tiefere Ebene}
          Folder := Copy(Path, p + 1, Length(Path) - p);
          Path := Copy(Path, 1, p - 1);
        end;
        FolderTree.NewFolder(Path, Folder);
      end;      
    end;
  end;

begin
  Init;
  {Slashes zählen und List sortieren.}
  PrepareList(List);
  {Liste konvertieren}
  ConvertListToTree(List);
  {konvertierte List exportieren}
  FolderTree.ExportStructureToStringList(Structure);
  Free;
end;

{ GetSpaceUsed -----------------------------------------------------------------

  GetSpaceUsed ermitelt den belegten Speicherplatz.                            }

procedure TSessionImportHelper.GetSpaceUsed;
var Temp: string;
    Adr : string;
begin
  Temp := FMediumInfo;
  Delete(Temp, 1, Pos('Next writable address', Temp));
  Delete(Temp, 1, Pos(':', Temp));
  Adr := Trim(Copy(Temp, 1, Pos(LF, Temp)));
  FSpaceUsed := (StrToIntDef(Adr, 0) - 1) * 2048;
end;

{ GetDiskInfo ------------------------------------------------------------------

  GetDiskInfo ruft cdrecord -minfo auf.                                        }

procedure TSessionImportHelper.GetDiskInfo;
var Temp: string;
begin
  Temp := StartUpDir + cCdrecordBin;
  {$IFDEF QuoteCommandlinePath}
  Temp := QuotePath(Temp);
  {$ENDIF}
  Temp := Temp + ' dev=' + SCSIIF(FDevice) + ' -minfo -v';
  FMediumInfo := GetDosOutput(PChar(Temp), True, False);
end;

{ GetFileSysInfo ---------------------------------------------------------------

  GetFileSysInfo ruft isoinfo auf.                                             }

procedure TSessionImportHelper.GetFileSysInfo(const Mode: TGetFileSysMode);
var Temp: string;
begin
  Temp := StartUpDir + cISOInfoBin;
  {$IFDEF QuoteCommandlinePath}
  Temp := QuotePath(Temp);
  {$ENDIF}
  Temp := Temp + ' dev=' + SCSIIF(FDevice) + ' -T ' + FStartSector;
  case Mode of
    gfsmPVD   : Temp := Temp + ' -d';
    gfsmISO   : Temp := Temp + ' -l';
    gfsmRR    : Temp := Temp + ' -l -R';
    gfsmJoliet: Temp := Temp + ' -l -J';
  end;
  FMediumInfo := GetDosOutput(PChar(Temp), True, True);
end;

{ ExtractSessionData -----------------------------------------------------------

  ExtractSessionData ermittelt aus der Ausgabe von cdrecord -minfo die Start-
  adressen der bereits vorhandenen Sessions.                                   }

procedure TSessionImportHelper.ExtractSessionData;
var MInfo  : TStringList;
    SecList: TStringList;
    i, p   : Integer;
    Addr   : string;
begin
  MInfo := TStringList.Create;
  SecList := TStringList.Create;
  {unnötiges wegwerfen}
  Delete(FMediumInfo, 1, Pos('Track  Sess Type', FMediumInfo));
  Delete(FMediumInfo, 1, Pos('    1', FMediumInfo) - 1);
  p := Pos('Last session', FMediumInfo);
  if p = 0 then p := Pos('Next', FMediumInfo);
  FMediumInfo := Copy(FMediumInfo, 1, p - 1);
  MInfo.Text := FMediumInfo;
  {leere Disk?}
  if Pos('BLANK', MInfo[0]) > 0 then
  begin
    FStartSector := '0';
  end else
  begin
    i := 0;
    while (i < MInfo.Count) do
    begin
      Addr := '';
      if Pos('Data', MInfo[i]) > 0 then Addr := Trim(Copy(MInfo[i], 20, 10));
      Inc(i);
      if Addr <> '' then SecList.Add(Addr);
    end;
    {nur eine Session vorhanden?}
    if SecList.Count = 1 then
      FStartSector := SecList[0]
    else
      FSectorList := SecList.CommaText;
  end;
  MInfo.Free;
  SecList.Free;
end;

{ SelectSession ----------------------------------------------------------------

  SelectSession erzeugt einen Auswahldialog, über den eine der vorhandenen
  Sessions selektiert werden kann.                                             }

procedure TSessionImportHelper.SelectSession;
var FormSelectSession: TFormSelectSession;
    Temp             : string;
begin
  if FSectorList <> '' then
  begin
    {Den User nur fragen, wenn kein Projekt automatisch ausgeführt wird.}
    if not TCdrtfeData.Instance.Settings.CmdLineFlags.ExecuteProject then
    begin
      FormSelectSession := TFormSelectsession.CreateNew(nil);
      try
        FormSelectSession.Lang := TCdrtfeData.Instance.Lang;
        FormSelectSession.SectorList := FSectorList;
        FormSelectSession.Init;
        FormSelectSession.ShowModal;
        FStartSector := FormSelectSession.StartSector;
      finally
        FormSelectSession.Release;
      end;
    end else
    begin
      Temp := FSectorList;
      Delete(Temp, 1, LastDelimiter(',', FSectorList));
      FStartSector := Temp;
    end;
  end;
end;

{ CheckSession -----------------------------------------------------------------

  CheckSession  prüft, welche Dateisysteme vorhanden sind und ermittelt die
  VolID.                                                                       }

procedure TSessionImportHelper.CheckSession;
var Temp: string;
    p   : Integer;
begin
  {Get Primary VOlume Descriptor}
  GetFileSysInfo(gfsmPVD);
  {Extract Volume ID}
  Temp := FMediumInfo;
  p := Pos(SearchVolID, Temp);
  Delete(Temp, 1, p + 10);
  p := Pos(LF, Temp);
  FVolID := Copy(Temp, 1, p - 1);
  {vorhandene Dateisysteme}
  FHasJoliet := Pos(SearchJoliet, FMediumInfo) > 0;
  FHasRR     := Pos(SearchRR, FMediumInfo) > 0;
end;

{ GetSessionContent ------------------------------------------------------------

  GetSessionContent liet den Inhalt (die Ordnerstruktur und Dateinamen) ein.   }

procedure TSessionImportHelper.GetSessionContent;
var Mode: TGetFileSysMode;
begin
  if FHasJoliet then Mode := gfsmJoliet else
  if FHasRR     then Mode := gfsmRR else
                     Mode := gfsmISO;
  {Inhalt der Session einlesen}
  GetFileSysInfo(Mode);
end;

{ ParseFolder ------------------------------------------------------------------

  ParseFolder ermittelt die Ordnerstruktur der ausgewählten Session un überträgt
  sie in die Projektansicht.                                                   }

procedure TSessionImportHelper.ParseFolder;
var i              : Integer;
    List           : TStringList;
    FolderList     : TStringList;
    FolderStructure: TStringList;
begin
  List := TStringList.Create;
  FolderList := TStringList.Create;
  FolderStructure := TStringList.Create;
  List.Text := FMediumInfo;
  for i := 0 to List.Count - 1 do
  begin
    if Pos(SearchDir, List[i]) > 0 then
      FolderList.Add(Trim(Copy(List[i], 22, Length(List[i]) - 21)));
  end;
  ConvertPathListToTreeStructure(FolderList, FolderStructure);                                      
  TCdrtfeData.Instance.Data.MultisessionCDImportFolder(FolderStructure);
  List.Free;
  FolderList.Free;
  FolderStructure.Free;
end;

{ ParseFiles -------------------------------------------------------------------

  ParseFiles trägt die in der Session vorhandenen Dateien in das Projekt ein.  }

procedure TSessionImportHelper.ParseFiles;
var i, p            : Integer;
    List            : TStringList;
    Path, Size, Name: string;
begin
  List := TStringList.Create;
  List.Text := FMediumInfo;
  Path := '';
  for i := 0 to List.Count - 1 do
  begin
    if Pos(SearchDir, List[i]) > 0 then
    begin
      Path := Trim(Copy(List[i], 22, Length(List[i]) - 21));
      if Path[1] = '/' then Delete(Path, 1, 1);
    end else
    if (Pos(SearchDirID, List[i]) = 0) and
       (Pos(SearchDirIDRR, List[i]) = 0) and (List[i] <> '') then
    begin
      if not FHasJoliet and FHasRR then
      begin
        Size := Trim(Copy(List[i], 37, 10));
      end else
      begin
        Size := Trim(Copy(List[i], 26, 10));
      end;
      p := Pos(']', List[i]);
      Name := Trim(Copy(List[i], p + 1, Length(List[i]) - p));
      TCdrtfeData.Instance.Data.MultisessionCDImportFile(Path, Name, Size,
                                                                        FDrive);
    end;
  end;
  List.Free;
  {belegter Speicherplatz}
  TCdrtfeData.Instance.Data.MultisessionCDImportSetSizeUsed(FSpaceUsed);
end;

{ TSessionImportHelper - public }

constructor TSessionImportHelper.Create;
begin
  inherited Create;
  FMediumInfo  := '';
  FSectorList  := '';
  FDevice      := '';
  FStartSector := '';
  FHasJoliet   := True;
  FHasRR       := True;
  FSpaceUsed   := 0;
end;

destructor TSessionImportHelper.Destroy;
begin
  inherited Destroy;
end;

{ GetSession -------------------------------------------------------------------

  GetSession wird aus TDiskInfoM.GetCDInfo heraus aufgerufen, wenn der User noch
  keine Session ausgewählt hat, aber SelectSession = True ist. In diesem Falle,
  muß die gesamte Ausgabe von cdrecord -minfo mit übergeben werden. Die ausge-
  wählte Session wird mittels StartSector zurückgegeben (genauer: die Start-
  adresse.                                                                     }

procedure TSessionImportHelper.GetSession;
begin
  if DiskPresent then
  begin
    ExtractSessionData;
    SelectSession;
  end;
end;

{ GetSessionUser ---------------------------------------------------------------

  GetSessionUser wird direkt vom Benutzer ausgelöst, wenn er eine Multisession-
  CD importieren möchte (per Rechtsklick vom Hauptfenster aus). Im Gegensatz zu
  GetSession wird nicht nur der Startsektor der zu importierenden Session er-
  mittelt, es wird auch das entsprechende Inhaltsverzeichnis eingelesen und dar-
  gestellt.                                                                    }

procedure TSessionImportHelper.GetSessionUser;
begin
  GetDiskInfo;
  if DiskPresent then
  begin
    GetSpaceUsed;
    GetSession;
    CheckSession;
    GetSessionContent;
    ParseFolder;
    ParseFiles;
  end;
end;

end.
