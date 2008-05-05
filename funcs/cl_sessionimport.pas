{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_sessionimport.pas: Auswählen und Importieren von vorigen Sessions

  Copyright (c) 2008 Oliver Valencia

  letzte Änderung  05.05.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_sessionimport.pas implementiert Objekte und Funktionen, die beim Auswählen
  und Importieren von vereits vorhandenen Sessione helfen.


  TSessionImportHelper

    Properties   Device
                 MediumInfo
                 StartSector

    Methoden     Create
                 GetSession
                 
}


unit cl_sessionimport;

{$I directives.inc}

interface

uses Forms, Classes, SysUtils, StdCtrls, Controls;

type TSessionImportHelper = class(TObject)
     private
       FDevice     : string;
       FMediumInfo : string;
       FStartSector: string;
       FSectorList : string;
       procedure ExtractSessionData;
       procedure SelectSession;
     public
       constructor Create;
       destructor Destroy; override;
       procedure GetSession;
       property Device     : string write FDevice;
       property MediumInfo : string read FMediumInfo write FMediumInfo;
       property StartSector: string read FStartSector;
     end;

implementation

uses f_logfile, cl_cdrtfedata, cl_lang, f_misc, constant;

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

{ TSessionImportHelper - public }

constructor TSessionImportHelper.Create;
begin
  inherited Create;
  FMediumInfo  := '';
  FSectorList  := '';
  FDevice      := '';
  FStartSector := '';
end;

destructor TSessionImportHelper.Destroy;
begin
  inherited Destroy;
end;

procedure TSessionImportHelper.GetSession;
begin
  if FMediumInfo = '' then ;
  ExtractSessionData;
  SelectSession;
end;

end.
