{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  frm_maoutput.pas: Darstellung der Ausgabe der Konsolenprogramme wenn mehrere
                    Brenner gleichzeitig verwendet werden

  Copyright (c) 2012 Oliver Valencia

  letzte Änderung  02.06.2012

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
  cl_lang, cl_action, cl_actionthread, cl_devices, cl_imagelists,
  c_frametopbanner, const_core, usermessages;
  
type
  TFormMAOutput = class(TForm)
    FrameTopBanner1: TFrameTopBanner;
    Memo1: TMemo;
    Button1: TButton;
    PageControl: TPageControl;
    ButtonStart: TButton;
    ButtonAbort: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonAbortClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
    FAction          : TCDAction;
    FLang            : TLang;
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
    FThreadRunning   : Array of Boolean;
    FPrepNeeded      : Boolean;
    FTerminatedByUser: Boolean;
    procedure CreateControls;
    procedure CreateCommandLines;
    procedure CreateThreads;
    procedure StartThreads;
    procedure TerminateThreads;
    procedure ResetStatus;
    procedure SetButtons(const Status: TOnOff);
    procedure WMTTerminated(var Msg: TMessage); message WM_TTerminated;
  public
    { Public-Deklarationen }
    procedure StartActionShowModal;
    function SelectDevices: Boolean;
    property CDAction  : TCDAction write FAction;
    property Lang      : TLang write FLang;
    property ImageLists: TImageLists write FImageLists;
    property Devices   : TDevices write FDevices;
  end;

implementation

uses f_window, f_strings, f_helper, const_common;

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
    Memo1.Lines.Add(Temp);
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
    FAction.CleanUp(2);
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
  FTerminatedByUser := False;
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
begin
  //
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
end;

{ FormShow ---------------------------------------------------------------------

  Hier werden Dinge erledigt, die vor dem ersten Anzeigen des Fensters nötig
  sind, aber in FormCreate noch nicht ausgeführt werden können.                }

procedure TFormMAOutput.FormShow(Sender: TObject);
begin
  SetFont(Self);
  FLang.SetFormLang(Self);
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

procedure TFormMAOutput.Button1Click(Sender: TObject);
begin
  CreateCommandLines;
  FAction.CleanUp(2);
end;

procedure TFormMAOutput.ButtonStartClick(Sender: TObject);
begin
  SetButtons(oOff);
  ResetStatus;
  CreateCommandLines;
  CreateThreads;
  StartThreads;
end;

procedure TFormMAOutput.ButtonAbortClick(Sender: TObject);
begin
  TerminateThreads;
end;

{ TFormMAOutput - private }

{ SetButtons -------------------------------------------------------------------

  (de)aktiviert die Buttons.                                                   }

procedure TFormMAOutput.SetButtons(const Status: TOnOff);
begin
  if Status = oOff then
  begin
    ButtonStart.Enabled := False;
    ButtonAbort.Visible := True;
  end else
  begin
    ButtonStart.Enabled := True;
    ButtonAbort.Visible := False;
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
  for i := 0 to FSelDevCount - 1 do
  begin
    {TabSheet}
    TabSheet := TTabSheet.Create(Self);
    TabSheet.Parent := PageControl;
    TabSheet.PageControl := PageControl;
    TabSheet.Caption := FLang.GMS('c003') + ' ' + IntToStr(i);
    {Label}
    DevLabel := TLabel.Create(Self);
    DevLabel.Parent := TabSheet;
    DevLabel.Top := 4;
    DevLabel.Left := 4;
    DevLabel.Caption := FLang.GMS('c003') + ' ' +
                          FDevices.GetDriveLetter(FSelectedDevices[i]) +
                          ' (' + FSelectedDevices[i] + ')';
    {Memo}
    Memo := TMemo.Create(Self);
    Memo.Parent := TabSheet;
    Memo.Top := DevLabel.Top + DevLabel.Height + 4;
    Memo.Left := 4;
    Memo.Width := TabSheet.ClientWidth - 8;
    Memo.Height := TabSheet.ClientHeight - Memo.Top - 4;
    Memo.ScrollBars := ssBoth;
    FMemoList.Add(Memo);
  end;
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
  if FCommandLinesPrep.Count > 0 then
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
    FThreadPrep.OutputMemo := (FMemoList[0] as TMemo);
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
  if FPrepNeeded then
  begin
    FThreadPrep.Resume;
  end else
  begin
    for i := 0 to FSelDevCount - 1 do
    begin
      (FThreadList[i] as TActionThreadEx).Resume;
      FThreadRunning[i] := True;
    end;
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
