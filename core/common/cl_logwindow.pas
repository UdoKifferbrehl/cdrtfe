{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_logwindow.pas: Singleton für einfachen Zugriff auf das Ausgabefenster

  Copyright (c) 2006-2012 Oliver Valencia

  letzte Änderung  23.11.2012

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  cl_logwindow.pas implementiert ein Singleton-Objekt, das einen einfachen Zu-
  griff auf das Ausgabefenster ermöglicht.

  Verwendung: TLogWin.Inst.SetObjects(...);
              TLogWin.Inst.Add('test...');

  TLogWindow

    Properties   OutWindowHandle
                 OnUpdatePanels
                 OnProgressBarHide
                 OnProgressBarShow
                 OnProgressBarUpdate

    Methoden     Add(s: string)
                 AddToLine(s: string)
                 Clear
                 ClearLine
                 Create
                 DeleteFromLine(i: Integer)
                 Inst: TLogWin
                 ReleaseInstance
                 SaveLog(Name: string)
                 SetMemo(Memo: TMemo)
                 SetMemo2(Memo: TMemo)
                 ShowProgressTaskBar

}

unit cl_logwindow;

{$I directives.inc}

interface

uses Windows, Forms, Classes, SysUtils, StdCtrls,
     {$IFDEF Win7Comp} dwProgressBar, {$ENDIF}
     userevents;

type TLogWin = class(TObject)
     private
       FLog                     : TStringList;
       FMemo                    : TMemo;
       FMemo2                   : TMemo;
       FOutWindowHandle         : THandle;
       {$IFDEF Win7Comp}
       FTaskBarProgressIndicator: TdwTaskbarProgressIndicator;
       {$ENDIF}
       FOnUpdatePanels          : TUpdatePanelsEvent;
       FOnProgressBarDoMarquee  : TProgressBarDoMarqueeEvent;
       FOnProgressBarHide       : TProgressBarHideEvent;
       FOnProgressBarShow       : TProgressBarShowEvent;
       FOnProgressBarUpdate     : TProgressBarUpdateEvent;
       FProgressBarShowing      : array[1..2] of Boolean;
       procedure UpdatePanels(const s1, s2: string);
     protected
       constructor CreateInstance;
       class function AccessInstance(Request: Integer): TLogWin;
     public
       constructor Create;
       destructor Destroy; override;
       class function Inst: TLogWin;
       class procedure ReleaseInstance;
       procedure SaveLog(Name: string);
       procedure SetMemo(Memo: TMemo);
       procedure SetMemo2(Memo: TMemo);
       procedure UnsetMemo2;
       procedure Add(s: string);
       procedure AddToLine(s: string);
       procedure AddSysError(const Error: Integer; const Info: string);
       procedure Clear;
       procedure ClearLine;
       procedure DeleteFromLine(i: Integer);
       procedure ProgressBarHide(const PB: Integer);
       procedure ProgressBarShow(const PB, Max: Integer);
       procedure ProgressBarUpdate(const PB, Position: Integer);
       procedure ProgressBarDoMarquee(const Active: Boolean);
       procedure ShowProgressTaskBar;
       procedure ShowProgressTaskBarString(const s: string);
       {$IFDEF Win7Comp}
       procedure TaskBarProgressIndicatorInit;
       procedure TaskBarProgressIndicatorHide;
       procedure TaskBarProgressIndicatorShow;
       procedure TaskBarProgressIndicatorDoMarquee;
       procedure TaskBarProgressIndicatorUpdate(const Position: Integer);
       {$ENDIF}
       function ProcessProgress(const s: string): string;
       property OutWindowHandle: THandle read FOutWindowHandle;
       property OnUpdatePanels: TUpdatePanelsEvent read FOnUpdatePanels write FOnUpdatePanels;
       property OnProgressBarDoMarquee: TProgressBarDoMarqueeEvent read FOnProgressBarDoMarquee write FOnProgressBarDoMarquee;
       property OnProgressBarHide: TProgressBarHideEvent read FOnProgressBarHide write FOnProgressBarHide;
       property OnProgressBarShow: TProgressBarShowEvent read FOnProgressBarShow write FOnProgressBarShow;
       property OnProgressBarUpdate: TProgressBarUpdateEvent read FOnProgressBarUpdate write FOnProgressBarUpdate;
     end;

implementation

uses {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     {$IFDEF Win7Comp} f_process, {$ENDIF}
     f_wininfo, f_strings, const_common;

{ TLogWindow ----------------------------------------------------------------- }

{ TLogWindow - private }

{ TaskBarProgressIndicatorInit -------------------------------------------------

  für Windows 7 die TaskBar-Fortschrittsanzeige initialisieren.                }

{$IFDEF Win7Comp}
procedure TLogWin.TaskBarProgressIndicatorInit;
begin
  {Unter Windows7 PE könnte dies fehlschlagen, daher Exception abfanngen und
   im Fehlerfalle auf nil setzten. Alle weiteren Zugriffe dürfen nur nach
   Prüfung mit Assigned() stattfinden.}
  try
    FTaskBarProgressIndicator := TdwTaskbarProgressIndicator.Create(nil);
  except
    FTaskBarProgressIndicator := nil;
  end;
  if Assigned(FTaskBarProgressIndicator) then
  begin
    FTaskBarProgressIndicator.Min := 0;
    FTaskBarProgressIndicator.Max := 100;
    FTaskBarProgressIndicator.ShowInTaskbar := False;
  end;
end;
{$ENDIF}

{ UpdatePanels -----------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TLogWin.UpdatePanels(const s1, s2: string);
begin
  if Assigned(FOnUpdatePanels) then FOnUpdatePanels(s1, s2);
end;

{ TLogWindow - protected }

constructor TLogWin.CreateInstance;
var Temp: string;
begin
  inherited Create;
  FTaskBarProgressIndicator := nil;
  FLog := TStringList.Create;
  {$IFDEF Win7Comp}
  if not DLLIsLoaded('bbLeanSkinEng.dll', Temp) then
    TaskBarProgressIndicatorInit;
  {$ENDIF}
  FProgressBarShowing[1] := False;
  FProgressBarShowing[2] := False;
end;

class function TLogWin.AccessInstance(Request: Integer): TLogWin;
{$J+}
const FInstance: TLogWin = nil;
{$J-}
begin
  case Request of
    0: ;
    1: if not Assigned(FInstance) then FInstance := CreateInstance;
    2: FInstance := nil;
  else
    raise Exception.CreateFmt('Illegal request %d in AccesInstance!',
                              [Request]);
  end;
  Result := FInstance;
end;

{ TCdrtfeData - public }

constructor TLogWin.Create;
begin
  inherited Create;
  raise Exception.CreateFmt('Access class %s through instance only!',
                            [ClassName]);
end;

destructor TLogWin.Destroy;
begin
  if AccessInstance(0) = Self then AccessInstance(2);
  FLog.Free;
  {$IFDEF Win7Comp}
  if Assigned(FTaskBarProgressIndicator) then FTaskBarProgressIndicator.Free;
  {$ENDIF}
  inherited Destroy;
end;

class function TLogWin.Inst: TLogWin;
begin
  Result := AccessInstance(1);
end;

class procedure TLogWin.ReleaseInstance;
begin
  AccessInstance(0).Free;
end;

procedure ReleaseLogWindow;
begin
  TLogWin.ReleaseInstance;
end;

{ ProgressBar[Hide|Show|Update] ------------------------------------------------

  Löst die Events OnProgressBar[Hide|Show|Update] aus, die das Hauptfenster ver-
  anlassen, die entsprechende Aktion im ProgressBar auszuführen.}

procedure TLogWin.ProgressBarHide(const PB: Integer);
begin
  if Assigned(FOnProgressBarHide) and FProgressBarShowing[PB] then
  begin
    FOnProgressBarHide(PB);
    FProgressBarShowing[PB] := False;
  end;
  {$IFDEF Win7Comp}
  if PB = 2 then TaskBarProgressIndicatorHide;
  {$ENDIF}
end;

procedure TLogWin.ProgressBarShow(const PB, Max: Integer);
begin
  if Assigned(FOnProgressBarShow) and not FProgressBarShowing[PB] then
  begin
    FOnProgressBarShow(PB, Max);
    FProgressBarShowing[PB] := True;
  end;
  {$IFDEF Win7Comp}
  if PB = 2 then TaskBarProgressIndicatorShow;
  {$ENDIF}
end;

procedure TLogWin.ProgressBarUpdate(const PB, Position: Integer);
begin
  if Assigned(FOnProgressBarUpdate) and FProgressBarShowing[PB] then
    FOnProgressBarUpdate(PB, Position);
  {$IFDEF Win7Comp}
  if PB = 2 then TaskBarProgressIndicatorUpdate(Position);
  {$ENDIF}
end;

procedure TLogWin.ProgressBarDoMarquee(const Active: Boolean);
begin
  if Active then
  begin
    ProgressBarShow(1, 100);
    if Assigned(FOnProgressBarDoMarquee) and FProgressBarShowing[1] then
      FOnProgressBarDoMarquee(1, Active);
  end else
  begin
    if Assigned(FOnProgressBarDoMarquee) and FProgressBarShowing[1] then
      FOnProgressBarDoMarquee(1, Active);
    ProgressBarHide(1);
  end;
end;

{ TaskBarProgressIndicator[Hide|Show|Update] -----------------------------------

  steuern die Foprtschrittsanzeige in der TaskBar (ab Win7).                   }

{$IFDEF Win7Comp}
procedure TLogWin.TaskBarProgressIndicatorHide;
begin
  if Assigned(FTaskBarProgressIndicator) then
    FTaskBarProgressIndicator.ShowInTaskbar := False;
end;

procedure TLogWin.TaskBarProgressIndicatorShow;
begin
  if Assigned(FTaskBarProgressIndicator) then
  begin
    FTaskBarProgressIndicator.Position := 0;
    FTaskBarProgressIndicator.MarqueeEnabled := False;
    FTaskBarProgressIndicator.ProgressBarState := pbstNormal;
    FTaskBarProgressIndicator.ShowInTaskbar := True;
  end;
end;

procedure TLogWin.TaskBarProgressIndicatorUpdate(const Position: Integer);
begin
  if Assigned(FTaskBarProgressIndicator) then
    FTaskBarProgressIndicator.Position := Position;
end;

procedure TLogWin.TaskBarProgressIndicatorDoMarquee;
begin
  TaskBarProgressIndicatorShow;
  if Assigned(FTaskBarProgressIndicator) then
  begin
    FTaskBarProgressIndicator.MarqueeEnabled := True;
    FTaskBarProgressIndicator.ProgressBarState := pbstMarquee;
  end;
end;
{$ENDIF}

{ SetMemo ----------------------------------------------------------------------

  SetMemo setzt den internen Zeiger auf das zu verwendende Memo und bestimmt das
  Handle zum Formular.                                                         }

procedure TLogWin.SetMemo(Memo: TMemo);
begin
  FMemo := Memo;
  FMemo2 := nil;
  FOutWindowHandle := (FMemo.Owner as TForm).Handle;
end;

{ SetMemo2 ---------------------------------------------------------------------

  SetMemo2 erlaubt es, ein zweites Memo für die Anzeige zu definieren.         }

procedure TLogWin.SetMemo2(Memo: TMemo);
begin
  FMemo2 := Memo;
  FMemo2.Lines.Assign(FMemo.Lines);
end;

{ UnsetMemo2 -------------------------------------------------------------------

  UnsetMemo2 entfernt den Verweis auf das zweite Memo.                         }

procedure TLogWin.UnsetMemo2;
begin
  FMemo2 := nil;
end;

{ AddSysError ------------------------------------------------------------------

  AddSysError zeigt die zu einem Win32-Errorcode gehörende Meldung an.         }

procedure TLogWin.AddSysError(const Error: Integer; const Info: string);
var i    : Integer;
    Temp : string;
    List : TStringList;
begin
  Temp := '  Info   : ';
  Add('A Win32 API error has occurred:');
  Add('  Code   : ' + IntToStr(Error));
  Add('  Message: ' + SysErrorMessage(Error));
  List := TStringList.Create;
  List.Text := Info;
  for i := 0 to List.Count - 1 do
  begin
    Add(Temp + List[i]);
    Temp := '           ';    
  end;
  List.Free;
  Add('');
end;

{ Add --------------------------------------------------------------------------

  Add fügt den String s als neue Zeile zum Memo hinzu.                         }

procedure TLogWin.Add(s: string);
begin
  {$IFDEF WriteLogfile}
  if FLog.Count > 0 then AddLog('> ' + FLog[FLog.Count - 1], 0);
  {$ENDIF}
  
  {Wenn nötig, Platz schaffen}
  if not PlatformWin2kXP and (Length(FMemo.Lines.Text) > 25000) then
  begin
    FMemo.Clear;
    if Assigned(FMemo2) then FMemo2.Clear;
    Add('');
  end;

  FLog.Add(s);
  FMemo.Lines.Add(s);
  if Assigned(FMemo2) then FMemo2.Lines.Add(s);
end;

{ AddToLine --------------------------------------------------------------------

  AddToLine fügt den String s an die letzte Zeile des Memos an.                }

procedure TLogWin.AddToLine(s: string);
begin
  FLog[Flog.Count - 1] := FLog[Flog.Count - 1] + s;
  FMemo.Lines[FMemo.Lines.Count - 1] := FMemo.Lines[FMemo.Lines.Count - 1] + s;
  if Assigned(FMemo2) then
     FMemo2.Lines[FMemo2.Lines.Count - 1] :=
                                       FMemo2.Lines[FMemo2.Lines.Count - 1] + s;
end;

{ DeleteFromLine ---------------------------------------------------------------

  DeleteFromLine löscht die letzte i Zeichen aus der letzten Zeile des Memos.  }

procedure TLogWin.DeleteFromLine(i: Integer);
var Temp: string;
begin
  Temp := Copy(FMemo.Lines[FMemo.Lines.Count - 1], 1,
               Length(FMemo.Lines[FMemo.Lines.Count - 1]) - i);
  FLog[FLog.Count - 1] := Temp;
  FMemo.Lines[FMemo.Lines.Count - 1] := Temp;
  if Assigned(FMemo2) then   FMemo2.Lines[FMemo2.Lines.Count - 1] := Temp;
end;

{ ClearLine --------------------------------------------------------------------

  Clear Line löscht die letzte Zeile im Memo.                                  }

procedure TLogWin.ClearLine;
begin
  FLog[FLog.Count - 1] := '';
  FMemo.Lines[FMemo.Lines.Count - 1] := '';
  if Assigned(FMemo2) then FMemo2.Lines[FMemo2.Lines.Count - 1] := '';
end;

{ Clear ------------------------------------------------------------------------

  Clear löscht den Inhalt aller Memos.                                         }

procedure TLogWin.Clear;
begin
  FLog.Clear;
  FMemo.Clear;
  if Assigned(FMemo2) then FMemo2.Clear;
  Add('');
end;

{ SaveLog ----------------------------------------------------------------------

  SaveLog speichert das Log in einer Textdatei.                                }

procedure TLogWin.SaveLog(Name: string);
begin
  FLog.SaveToFile(Name);
  // FMemo.Lines.SaveToFile(Name);
end;


{ ShowProgressTaskBar ----------------------------------------------------------

  zeigt den Fortschritt der Aktionen im Taskbar-Eintrag an.                    }

procedure TLogWin.ShowProgressTaskBar;
var s: string;
begin
  if FLog.Count > 0 then s := FLog[FLog.Count - 1];
  s := ProcessProgress(s);
  if s <> '' then
  begin
    Application.Title := '[' + s + '] ' +
      Copy(Application.Title, Pos(']', Application.Title) + 2,
        Length(Application.Title) - Pos(']', Application.Title) + 2);
    UpdatePanels('<>', s);
  end;
end;

{ ShowProgressTaskBarString ----------------------------------------------------

  zeigt s im Taskbar-Eintrag an.                                               }

procedure TLogWin.ShowProgressTaskBarString(const s: string);
begin
  if s <> '' then
    Application.Title := '[' + s + '] ' +
      Copy(Application.Title, Pos(']', Application.Title) + 2,
        Length(Application.Title) - Pos(']', Application.Title) + 2);
  // UpdatePanels('<>', s);
end;

{ ProcessProgress --------------------------------------------------------------

  ermittelt aus den Ausgaben der Kommandozeilenprogramme die Fortschrittsinfos.}

function TLogWin.ProcessProgress(const s: string): string;
{$J+}
const TotalSectors: Integer = 0;
      OldProgress : Extended = 0;
      TotalSize   : Integer = 0;
      SumWritten  : Integer = 0;
      OldSector   : Integer = 0;
{$J-}
var Temp    : string;
    Progress: string;
    a, b    : string;
    ia, ib  : Integer;
    ProgF   : Extended;
    ProgTF  : Extended;
    p       : Integer;
begin
  Progress := '';
  Temp := s;
  ProgF := 0;
  {cdrecord: Gesamtgrösse}
  if Pos('Total size:', Temp) > 0 then
  begin
    p := Pos(':', Temp);
    TotalSize := StrToIntDef(Trim(Copy(Temp, p + 1, 9)), 1);
    SumWritten := 0;
    ProgressBarShow(2, 100);
  end else
  {cdrecord: Track-Progress}
  if (Pos('Track', Temp) > 0) and (Pos('of', Temp) > 0) then
  begin
    p := Pos(':', Temp);             // Track 01:    5 of   40 MB written
    Progress := Copy(Temp, 1, p);
    Delete(Progress, 2, 5);
    Delete(Temp, 1, p);
    Temp := Copy(Temp, 1, Pos('MB', Temp) - 1);
    a := StringLeft(Temp, 'o');
    b := StringRight(Temp, 'f');
    a := Trim(a); b := Trim(b);
    ia := StrToIntDef(a, 0); ib := StrToIntDef(b, 1);
    if ib > 0 then
    begin
      ProgF := (ia / ib) * 100;
      Progress := Progress + ' ' + FormatFloat('##0%', ProgF);
    end;
    if ProgF > OldProgress then
    begin
      if ia = ib then
      begin
        SumWritten := SumWritten + ia;
        ia := 0;
      end;
      ProgTF := ((SumWritten + ia) / TotalSize) * 100; // Fortschritt über alle Tracks
      ProgressBarUpdate(1, Round(ProgF));
      ProgressBarUpdate(2, Round(ProgTF));
      OldProgress := ProgF;
    end else
      Progress := '';
  end else
  {cdrecord: Fixating ...}
  if s = 'Fixating...' then
  begin
    Progress := s;
    ProgressBarDoMarquee(True);
    {$IFDEF Win7Comp}
    TaskBarProgressIndicatorDoMarquee;
    {$ENDIF}
  end else
  {cdrecord: Blanking time}
  if Pos('Blanking time', Temp) > 0 then
  begin
    ProgressBarDoMarquee(False);
    ProgressBarShow(1, 100);
  end else  
  {cdrecord: Blanking ...}
  if Pos('Blanking ', Temp) = 1 then   // Blanking PMA, TOC, pregap
  begin
    Progress := 'Blanking...';
    ProgressBarDoMarquee(True);
    {$IFDEF Win7Comp}
    TaskBarProgressIndicatorDoMarquee;
    {$ENDIF}
  end else
  {mkisofs: ...% done}
  if Pos('done,', Temp) > 0 then
  begin
    a := Trim(Copy(Temp, 2, Pos('%', Temp)));
    Progress := 'I: ' + a;
    if not FProgressBarShowing[2] then
      ProgressBarShow(2, 100)
    else
    begin
      a := Copy(a, 1, Pos('.', a) - 1);
      ia := StrToIntDef(a, 0);
      ProgressBarUpdate(2, ia);
    end;
  end else
  {mode2cdmaker: [Progress...]}
  if Pos('[Pro', Temp) > 0 then
  begin
    Progress := 'I: ' + Trim(Copy(Temp, 11, Pos('%', Temp) - 10));
  end else
  {readcd: [end: ...] + [addr: ...]}
  if Pos('end:', Temp) = 1 then
  begin
    Delete(Temp, 1, 4);
    TotalSectors := StrToIntDef(Trim(Temp), 1);
    OldSector := 0;
    ProgressBarShow(2, 100);
  end else
  if Pos('addr:', Temp) = 1 then
  begin
    ia := StrToIntDef(Trim(Copy(Temp, 6, Pos('cnt', Temp) - 6)), 0);
    if ia > OldSector then
    begin
      ProgTF := (ia / TotalSectors) * 100;
      Progress := 'R: ' + FormatFloat('##0%', (ia / TotalSectors) *100);
      OldSector := ia;
      ProgressBarUpdate(2, Round(ProgTF));
    end;
  end else
  {ProgressBar sichtbar machen}
  if Pos('Starting new track', Temp) = 1 then
  begin
    ProgressBarHide(1);
    ProgressBarShow(1, 100);
    OldProgress := 0;
  end else
  {ProgressBar unsichtbar machen}
  if Pos('Writing  time', Temp) = 1 then
  begin
    ProgressBarHide(1);
    ProgressBarHide(2);
  end;
  {cdrdao: wrote x of y ...} (*
  if Pos('Wrote', Temp > 0 then
  begin
    Temp :=
    a := StringLeft(Temp, 'o');
    b := StringRight(Temp, 'f');
    a := Trim(a); b := Trim(b);
    ia := StrToIntDef(a, 0); ib := StrToIntDef(b, 1);
    Progress := Progress + ' ' + FormatFloat('##0%', (ia / ib) *100);
  end;                    *)
  {Ausführung beendet} (*
  if Temp = FLang.GMS('moutput01') then
  begin
  end;                   *)
  Result := Progress;
end;

initialization

finalization
  ReleaseLogWindow;

end.
