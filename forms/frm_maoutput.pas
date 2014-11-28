{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_maoutput.pas: Darstellung der Ausgabe der Konsolenprogramme wenn mehrere
                    Brenner gleichzeitig verwendet werden

  Copyright (c) 2012-2014 Oliver Valencia

  letzte Änderung  28.11.2014

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.  

}

unit frm_maoutput;

{$I directives.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Contnrs,
  {eigene Klassendefinitionen/Units}
  cl_lang, cl_settings, cl_action, cl_actionthread, cl_devices, cl_diskinfo,
  cl_imagelists, c_frametopbanner, const_core, usermessages;
  
type
  TFormMAOutput = class(TForm)
    FrameTopBanner1: TFrameTopBanner;
    Memo1: TMemo;
    ButtonCancel: TButton;
    PageControl: TPageControl;
    ButtonStart: TButton;
    ButtonAbort: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonAbortClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
    FAction          : TCDAction;
    FLang            : TLang;
    FSettings        : TSettings;
    FDevices         : TDevices;
    FImageLists      : TImageLists;
    FSelectedDevices : TStringList;
    FSelDevCount     : Integer;
    FCommandLines    : TStringList;
    FCommandLinesPrep: TStringList;
    FThreadList      : TObjectList;
    FThreadPrep      : TActionThreadEx;
    FMemoList        : TObjectList;
    FProcessRunning  : Boolean;
    FThreadRunning   : array of Boolean;
    FCMArgList       : array of TCheckMediumArgs;
    FSimulDrvList    : array of string;
    FPrepNeeded      : Boolean;
    FTerminatedByUser: Boolean;
    FFirstRun        : Boolean;
    FDoCleanUp       : Boolean;
    FDisk            : TDiskInfo;
    FDiskA           : TDiskInfoA;
    FDiskM           : TDiskInfoM;
    function CheckDisks: Boolean;
    procedure CreateControls;
    procedure CreateCommandLines;
    procedure CreateThreads;
    procedure StartThreads;
    procedure TerminateThreads;
    procedure ResetStatus;
    procedure SetButtons(const Status: TOnOff);
    procedure SetFDisk;
    procedure WMTTerminated(var Msg: TMessage); message WM_TTerminated;
  public
    { Public-Deklarationen }
    procedure StartActionShowModal;
    function SelectDevices: Boolean;
    property CDAction  : TCDAction write FAction;
    property Lang      : TLang write FLang;
    property ImageLists: TImageLists write FImageLists;
    property Devices   : TDevices write FDevices;
    property Settings  : TSettings write FSettings;
  end;

implementation

uses f_window, f_strings, f_helper, cl_logwindow, const_common;

{$R *.dfm}

{ Messagehandler ------------------------------------------------------------- }

{ WMTTerminated ----------------------------------------------------------------

  Wenn WM_TTerminated empfangen wird, ist der zweite Thread beendet worden.    }

procedure TFormMAOutput.WMTTerminated(var Msg: TMessage);
var //Ok           : Boolean;
    ActiveThreads: Boolean;
    ID, ExitCode : Integer;
    i            : Integer;
    Temp, Info   : string;
begin
  {$IFDEF ShowCmdError}
  ExitCode := Msg.wParam;
  // Ok := ExitCode = 0;
  {$ENDIF}
  ID := Msg.LParam;
  if FTerminatedByUser then Temp := FLang.GMS('moutput02') else
    Temp := FLang.GMS('moutput01');
  Temp := Temp + ' ExitCode: ' + IntToStr(ExitCode);
  if ID <> 100 then
  begin
    FThreadRunning[ID] := False;
    ActiveThreads := False;
    for i := 0 to FSelDevCount - 1 do
      ActiveThreads := ActiveThreads or FThreadRunning[i];
    FProcessRunning := ActiveThreads;
    Info := FLang.GMS('c003') + ' ' +
            FDevices.GetDriveLetter(FSelectedDevices[ID]) + ' (' +
            FSelectedDevices[ID] + '): ' + Temp;
    Memo1.Lines.Add(Info);
  end else
  begin
    Memo1.Lines.Add(FLang.GMS('maoutput02') + ': ' + Temp);
    FPrepNeeded := False;
    if not FTerminatedByUser then
    begin
      StartThreads;
    end else
    begin
      FProcessRunning := False;
    end;
  end;
  if not FProcessRunning then
  begin
    Memo1.Lines.Add('');
    //FAction.CleanUp(2);
    SetButtons(oOn);
  end;
end;

{ Form-Events ---------------------------------------------------------------- }

{ FormCreate -------------------------------------------------------------------

  Diese Prozedur wird beim Erzeugen des Fensters abgearbeitet. Hier werden not-
  wendige Initialisierungen vorgenommen.                                       }

procedure TFormMAOutput.FormCreate(Sender: TObject);
begin
  FSelectedDevices := TStringList.Create;
  FCommandLines := TStringList.Create;
  FCommandLinesPrep := TStringList.Create;
  FMemoList := TObjectList.Create;
  FMemoList.OwnsObjects := False;
  FThreadList := TObjectList.Create;
  FThreadList.OwnsObjects := True;
  FProcessRunning := False;
  FPrepNeeded := False;
  FFirstRun := True;
  FDoCleanUp := False;
  FTerminatedByUser := False;
  FDiskA := TDiskInfoA.Create;
  FDiskM := TDiskInfoM.Create;
end;

{ FormCloseQuery ---------------------------------------------------------------

  Schließen nur erlaubt, wenn keine Threads mehr laufen.                       }

procedure TFormMAOutput.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FProcessRunning then
    CanClose := ShowMsgDlg(FLang.GMS('eburn18'), FLang.GMS('g003'),
                           MB_cdrtfeWarningYN) = ID_YES;
end;

{ FormClose --------------------------------------------------------------------

  die Infos aus den Memos ind das Memo des Hauptfenster übernehmen.            }

procedure TFormMAOutput.FormClose(Sender: TObject; var Action: TCloseAction);
var i   : Integer;
    Temp: string;
begin
  if FDoCleanUp then FAction.CleanUp(2);
  if Memo1.Lines.Count > 0 then
  begin
    TLogWin.Inst.Add(Memo1.Lines.Text);
    TLogWin.Inst.Add('');
  end;
  for i := 0 to FMemoList.Count - 1 do
  begin
    if (FMemoList[i] as TMemo).Lines.Count > 0 then
    begin
      if i < FMemoList.Count - 1 then
      begin
        Temp := Temp + (FMemoList[i] as TMemo).Lines.Text + CRLF;
      end else
      begin
        Temp := (FMemoList[i] as TMemo).Lines.Text + CRLF + Temp;
      end;
    end;
  end;
  if Temp <> '' then TLogWin.Inst.Add(Temp);
end;


{ FormDestroy ------------------------------------------------------------------

  Hier werden die in FormCreate erzeugten Objekte wieder freigegeben.          }

procedure TFormMAOutput.FormDestroy(Sender: TObject);
begin
  FSelectedDevices.Free;
  FCommandLines.Free;
  FCommandLinesPrep.Free;
  FMemoList.Free;
  FThreadList.Free;
  FDiskA.Free;
  FDiskM.Free;
end;

{ FormShow ---------------------------------------------------------------------

  Hier werden Dinge erledigt, die vor dem ersten Anzeigen des Fensters nötig
  sind, aber in FormCreate noch nicht ausgeführt werden können.                }

procedure TFormMAOutput.FormShow(Sender: TObject);
var Temp: string;
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
  {Button caption aus CdrtfeMainForm übernehmen}
  Temp := FLang.GCS('CdrtfeMainForm.ButtonStart.Caption');
  if Temp <> '' then ButtonStart.Caption := Temp;
  Temp := FLang.GCS('CdrtfeMainForm.ButtonAbort.Caption');
  if Temp <> '' then ButtonAbort.Caption := Temp;
  Temp := FLang.GCS('CdrtfeMainForm.ButtonCancel.Caption');
  if Temp <> '' then ButtonCancel.Caption := Temp;
  {Banner}
  FrameTopBanner1.Init(Self.Caption, ''{FLang.GMS('desc01')}, 'grad1');
//  {falls vorhanden, alte Größe und Position wiederherstellen}
//  with FSettings.WinPos do
//  begin
//    if (OutWidth <> 0) and (OutHeight <> 0) then
//    begin
//      self.Top := OutTop;
//      self.Left := OutLeft;
//      self.Width := OutWidth;
//      self.Height := OutHeight;
//    end else
//    begin
//      {Falls keine Werte vorhanden, dann Fenster zentrieren. Die muß hier
//       manuell geschehen, da poScreenCenter zu Fehlern beim Setzen der
//       Eigenschaften führt. Deshalb muß poDefault verwendet werden.}
//      self.Top := (Screen.Height - self.Height) div 2;
//      self.Left := (Screen.Width - self.Width) div 2;
//    end;
//    if OutMaximized then self.WindowState := wsMaximized;
end;

{ PageControl-Events --------------------------------------------------------- }

procedure TFormMAOutput.PageControlChange(Sender: TObject);
var i   : Integer;
    Memo: TMemo;
begin
  i := (Sender as TPageControl).ActivePageIndex;
  Memo := FMemoList[i] as TMemo;
  Memo.Perform(EM_LineScroll, 0, Memo.Lines.Count - 1)
end;

{ Button-Events -------------------------------------------------------------- }

procedure TFormMAOutput.ButtonCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFormMAOutput.ButtonStartClick(Sender: TObject);
var i: Integer;
    Ok: Boolean;
begin
  i := 1;
  SetButtons(oOff);
  ResetStatus;
  Ok := CheckDisks;
  if Ok then
  begin
    if not FSettings.General.NoConfirm then
    begin
      {Brennvorgang starten?}
      i := ShowMsgDlg(FLang.GMS('mburn01'), FLang.GMS('mburn02'),
           MB_cdrtfeConfirmS);
    end;
    if i = 1 then
    begin
      CreateCommandLines;
      CreateThreads;
      StartThreads;
      FDoCleanUp := True;
    end;
  end;
  if not Ok or (i <> 1) then SetButtons(oOn);
end;

procedure TFormMAOutput.ButtonAbortClick(Sender: TObject);
begin
  if FProcessRunning then TerminateThreads;
end;

{ TFormMAOutput - private }

{ SetButtons -------------------------------------------------------------------

  (de)aktiviert die Buttons.                                                   }

procedure TFormMAOutput.SetButtons(const Status: TOnOff);
begin
  if Status = oOff then
  begin
    ButtonStart.Enabled := False;
    ButtonCancel.Enabled := False;
    ButtonAbort.Visible := True;
  end else
  begin
    ButtonStart.Enabled := True;
    ButtonCancel.Enabled := True;
    ButtonAbort.Visible := False;
  end;
end;

{ SetFDisk ---------------------------------------------------------------------

  wähl je nach cdrecord-Fähigkeiten das passende FDisk[A|M].                   }

procedure TFormMAOutput.SetFDisk;
begin
  case FSettings.Cdrecord.HaveMediaInfo of
    True : FDisk := FDiskM;
    False: FDisk := FDiskA;
  end;
end;

{ CreateControls ---------------------------------------------------------------

  CreateControls erzeugt in Abhängigkeit der Anzahl der ausgewählten Laufwerke
  Controls zur Anzeige der Ausgabe.                                            }

procedure TFormMAOutput.CreateControls;
var i       : Integer;
    TabSheet: TTabSheet;
    Memo    : TMemo;
    DevLabel: TLabel;
begin
  for i := 0 to FSelDevCount {- 1} do
  begin
    {TabSheet}
    TabSheet := TTabSheet.Create(Self);
    TabSheet.Parent := PageControl;
    TabSheet.PageControl := PageControl;
    if i < FSelDevCount then
      TabSheet.Caption := FLang.GMS('c003') + ' ' + IntToStr(i)
    else
      TabSheet.Caption := FLang.GMS('maoutput01');
    {Label}
    DevLabel := TLabel.Create(Self);
    DevLabel.Parent := TabSheet;
    DevLabel.Top := 4;
    DevLabel.Left := 4;
    if i < FselDevCount then
      DevLabel.Caption := FLang.GMS('c003') + ' ' +
                            FDevices.GetDriveLetter(FSelectedDevices[i]) +
                            ' (' + FSelectedDevices[i] + ')'
    else
      DevLabel.Caption := FLang.GMS('maoutput02');
    {Memo}
    Memo := TMemo.Create(Self);
    Memo.Parent := TabSheet;
    Memo.Top := DevLabel.Top + DevLabel.Height + 4;
    Memo.Left := 4;
    Memo.Width := TabSheet.ClientWidth - 8;
    Memo.Height := TabSheet.ClientHeight - Memo.Top - 4;
    Memo.ScrollBars := ssBoth;
    Memo.Anchors := [akLeft,akTop,akRight,akBottom];
    FMemoList.Add(Memo);
  end;
end;

{ CheckDisks -------------------------------------------------------------------

  prüft für jedes gewählte Laufwerk die eingelegte Disk.                       }

function TFormMAOutput.CheckDisks: Boolean;
var i   : Integer;
    Ok  : Boolean;
    Temp: string;
begin
  SetLength(FCMArgList, FSelDevCount);
  SetLength(FSimulDrvList, FSelDevCount);
  Ok := True;
  i := 0;
  while (i < FSelDevCount) and Ok do
  begin
    Temp := FLang.GMS('c003') + ' ' +
            FDevices.GetDriveLetter(FSelectedDevices[i]) + ' (' +
            FSelectedDevices[i] + '): ' + FLang.GMS('mburn13');
    FCMArgList[i].ForcedContinue := False;
    FCMArgList[i].Choice := FSettings.General.Choice; //cCDImage;
    {Größe der Daten ermitteln}
    //FData.GetProjectInfo(Count, DummyI, CMArgs.CDSize, DummyE, DummyI, cDataCD);
    {Infos über eingelegte CD einlesen}
    Memo1.Lines.Add(Temp);
    FDisk.GetDiskInfo(FSelectedDevices[i], False);
    FSimulDrvList[i] := '';
    if FDisk.IsDVD then FSimulDrvList[i] := 'dvd_simul';
    if FDisk.IsBD then FSimulDrvList[i] := 'bd_simul';
    {Zusammenstellung prüfen}
    Ok := FDisk.CheckMedium(FCMArgList[i]);
    Inc(i);
  end;
  Result := Ok;
  Memo1.Lines.Add('');
end;

{ CreateCommandLines -----------------------------------------------------------

  erzeugt die Kommandozeilen für die gleichzeitige Ausführung.                 }

procedure TFormMAOutput.CreateCommandLines;
var i       : Integer;
    CmdLine : string;
    Temp    : string;
begin
  {gemeinsame Kommandzeile erzeugen}
  CmdLine := FAction.GetCommandLineString;
  {falls mehrere Kommandozeilen enthalten sind, müssen diese getrennt werden}
  if Pos(CR, CmdLine) > 0 then
  begin
    FCommandLinesPrep.Text := CmdLine;
    i := FCommandLinesPrep.Count;
    if i > 1 then
    begin
      CmdLine := FCommandLinesPrep[i - 1];
      FCommandLinesPrep.Delete(i - 1);
    end;
  end;
  {für jedes Laufwerk anpassen}
  for i := 0 to FSelDevCount - 1 do
  begin
    Temp := ReplaceString(CmdLine, 'dev=mult', 'dev=' + FSelectedDevices[i]);
    if FSettings.Cdrecord.SimulDrv then
    begin
      if FSimulDrvList[i] <> '' then
        Temp := ReplaceString(Temp, 'cdr_simul', FSimulDrvList[i]);
    end;
    FCommandLines.Add(Temp);
  end;

  {debug}
  Memo1.Lines.Add('FCommandLinesPrep.Count: ' + IntToStr(FCommandLinesPrep.Count));
  for i := 0 to FCommandLinesPrep.Count - 1 do Memo1.Lines.Add(FCommandLinesPrep[i]);
  Memo1.Lines.Add('');
  Memo1.Lines.Add('FCommandLines.Count    : ' + IntToStr(FCommandLines.Count));
  for i := 0 to FCommandLines.Count - 1 do Memo1.Lines.Add(FCommandLines[i]);
  Memo1.Lines.Add('');  
end;

{ CreateThreads ----------------------------------------------------------------

  erzeugt die Threads für die gleichzeitige Ausführung.                        }

procedure TFormMAOutput.CreateThreads;
var i         : Integer;
    Thread    : TActionThreadEx;
    Cmd       : string;
    CurrentDir: string;
begin
  SetLength(FThreadRunning, FSelDevCount);
  for i := 0 to FSelDevCount - 1 do
  begin
    Cmd := FCommandLines[i];
    CurrentDir := GetCurrentFolder(Cmd);
    Thread := TActionThreadEx.Create(Cmd, CurrentDir, True);
    Thread.MessageOk := FLang.GMS('moutput01');
    Thread.MessageAborted := FLang.GMS('moutput02');
    Thread.ThreadID := i;
    Thread.MessageHandle := Self.Handle;
    Thread.OutputMemo := (FMemoList[i] as TMemo);
    // Thread.FreeOnTerminate := True;
    FThreadList.Add(Thread);
  end;
  if (FCommandLinesPrep.Count > 0) and FFirstRun then
  begin
    Cmd := '';
    for i := 0 to FCommandLinesPrep.Count - 1 do
    begin
      Cmd := Cmd + FCommandLinesPrep[i];
      if i < (FCommandLinesPrep.Count - 1) then Cmd := Cmd + CR;
    end;
    FThreadPrep := TActionThreadEx.Create(Cmd, CurrentDir, True);
    FThreadPrep.MessageOk := FLang.GMS('moutput01');
    FThreadPrep.MessageAborted := FLang.GMS('moutput02');
    FThreadPrep.ThreadID := 100;
    FThreadPrep.MessageHandle := Self.Handle;
    FThreadPrep.OutputMemo := (FMemoList[FSelDevCount] as TMemo);
    FThreadPrep.FreeOnTerminate := True;
    FPrepNeeded := True;
  end;
end;

{ StartThreads -----------------------------------------------------------------

  startet die Threads zur gleichzeitigen Ausführung.                           }

procedure TFormMAOutput.StartThreads;
var i         : Integer;
begin
  FTerminatedByUser := False;
  if FPrepNeeded and FFirstRun then
  begin
    PageControl.ActivePageIndex := FSelDevCount;
    FThreadPrep.Resume;
  end else
  begin
    PageControl.ActivePageIndex := 0;
    for i := 0 to FSelDevCount - 1 do
    begin
      (FThreadList[i] as TActionThreadEx).Resume;
      FThreadRunning[i] := True;
    end;
    FFirstRun := False;
  end;
  FProcessRunning := True;
end;

{ TerminateThreads -------------------------------------------------------------

  beendet die Threads.                                                         }

procedure TFormMAOutput.TerminateThreads;
var i         : Integer;
begin
  FTerminatedByUser := True;
  if FPrepNeeded then
  begin
    TerminateExecution(FThreadPrep);
  end;
  for i := 0 to FSelDevCount - 1 do
  begin
    TerminateExecution(FThreadList[i] as TActionThreadEx);
  end;
end;

{ ResetStatus ------------------------------------------------------------------

  setzt die Variablen zurück, so daß ein weiterer Durchlauf gestartet werden
  kann.                                                                        }

procedure TFormMAOutput.ResetStatus;
begin
  FCommandLines.Clear;
  FCommandLinesPrep.Clear;
  FThreadList.Clear;
  FProcessRunning := False;
  FPrepNeeded := False;
  FTerminatedByUser := False;
end;

{ TFormMAOutput - public }

{ StartActionShowModal ---------------------------------------------------------

  startet den Brennvorgang und zeigt das Ausgabefenster an.                    }

procedure TFormMAOutput.StartActionShowModal;
begin
  CreateControls;
  SetFDisk;
  Self.ShowModal;
end;

{ SelectDevices ----------------------------------------------------------------

  SelectDevices ruft einen Dialog zur Auswahl der Brenner auf.                 }

function TFormMAOutput.SelectDevices: Boolean;
var FormSelectWriter: TFormSelectWriter;
begin
  FormSelectWriter := TFormSelectWriter.CreateNew(nil);
  try
    FormSelectWriter.Lang := FLang;
    FormSelectWriter.ImageLists := FImageLists;
    FormSelectWriter.Devices := FDevices;
    FormSelectWriter.CDWriter := FDevices.CDWriter;
    FormSelectWriter.Init;
    FormSelectWriter.ShowModal;
    FSelectedDevices.Text := FormSelectWriter.SelectedDevices;
  finally
    FormSelectWriter.Release;
  end;
  FSelDevCount := FSelectedDevices.Count;
  Result := FSelDevCount > 0;
end;

end.
