{ cdrtfe: cdrtools/Mode2CDMaker/VCDImager Frontend

  cl_logwindow.pas: Singleton für einfachen Zugriff auf das Ausgabefenster

  Copyright (c) 2006-2007 Oliver Valencia

  letzte Änderung  03.09.2007

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

uses Windows, Forms, Classes, SysUtils, StdCtrls, userevents;

type TLogWin = class(TObject)
     private
       FLog            : TStringList;
       FMemo           : TMemo;
       FMemo2          : TMemo;
       FOutWindowHandle: THandle;
       FOnUpdatePanels : TUpdatePanelsEvent;
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
       {$IFDEF ShowProgressTaskBar}
       procedure ShowProgressTaskBar;
       procedure ShowProgressTaskBarString(const s: string);
       function ProcessProgress(const s: string): string;            // wird später ausgelagert!
       {$ENDIF}
       property OutWindowHandle: THandle read FOutWindowHandle;
       property OnUpdatePanels: TUpdatePanelsEvent read FOnUpdatePanels write FOnUpdatePanels;
     end;

implementation

uses {$IFDEF WriteLogfile} f_logfile, {$ENDIF}
     f_wininfo, f_strings, constant;

{ TLogWindow ----------------------------------------------------------------- }

{ TLogWindow - private }

{ UpdatePanels -----------------------------------------------------------------

  Löst das Event OnMessageShow aus, das das Hauptfenster veranlaßt, den Text aus
  FSettings.General.MessageToShow auszugeben.                                  }

procedure TLogWin.UpdatePanels(const s1, s2: string);
begin
  if Assigned(FOnUpdatePanels) then FOnUpdatePanels(s1, s2);
end;

{ TLogWindow - protected }

constructor TLogWin.CreateInstance;
begin
  inherited Create;
  FLog := TStringList.Create;
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
end;

{ SaveLog ----------------------------------------------------------------------

  SaveLog speichert das Log in einer Textdatei.                                }

procedure TLogWin.SaveLog(Name: string);
begin
  FLog.SaveToFile(Name);
  // FMemo.Lines.SaveToFile(Name);
end;

{$IFDEF ShowProgressTaskBar}

{ ShowProgressTaskBar ----------------------------------------------------------

  zeigt den Fortschritt der Aktionen im Taskbar-Eintrag an.                    }

procedure TLogWin.ShowProgressTaskBar;
var s: string;
begin
  if FLog.Count > 0 then s := FLog[FLog.Count - 1];
  s := ProcessProgress(s);
  {$IFDEF TitleFirst}
  if s <> '' then
    Application.Title := Copy(Application.Title, 1,
                              Pos('[', Application.Title) - 2) + ' [' + s + ']';
  {$ELSE}
  if s <> '' then
    Application.Title := '[' + s + '] ' +
      Copy(Application.Title, Pos(']', Application.Title) + 2,
        Length(Application.Title) - Pos(']', Application.Title) + 2);
  {$ENDIF}
  UpdatePanels('<>', s);
end;

{ ShowProgressTaskBarString ----------------------------------------------------

  zeigt s im Taskbar-Eintrag an.                                               }

procedure TLogWin.ShowProgressTaskBarString(const s: string);
begin
  {$IFDEF TitleFirst}
  if s <> '' then
    Application.Title := Copy(Application.Title, 1,
      Pos('[', Application.Title) - 2) + ' [' + s + ']';
  {$ELSE}
  if s <> '' then
    Application.Title := '[' + s + '] ' +
      Copy(Application.Title, Pos(']', Application.Title) + 2,
        Length(Application.Title) - Pos(']', Application.Title) + 2);
  {$ENDIF}
  // UpdatePanels('<>', s);
end;

{ ProcessProgress --------------------------------------------------------------

  ermittelt aus den Ausgaben der Kommandozeilenprogramme die Fortschrittsinfos.}

function TLogWin.ProcessProgress(const s: string): string;
{$J+}
const TotalSectors: Integer = 0;
{$J-}
var Temp    : string;
    Progress: string;
    a, b    : string;
    ia, ib  : Integer;
    p       : Integer;
begin
  Progress := '';
  Temp := s;
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
    if ib > 0 then Progress := Progress + ' ' +
                               FormatFloat('##0%', (ia / ib) *100);
  end else
  {cdrecord: Fixating ...}
  if s = 'Fixating...' then
  begin
    Progress := s;
  end else
  {cdrecord: Blanking ...}
  if Pos('Blanking', Temp) > 0 then
  begin
    Progress := 'Blanking...';
  end else
  {mkisofs: ...% done}
  if Pos('done,', Temp) > 0 then
  begin
    Progress := 'I: ' + Trim(Copy(Temp, 2, Pos('%', Temp)));
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
  end else
  if Pos('addr:', Temp) = 1 then
  begin
    ia := StrToIntDef(Trim(Copy(Temp, 6, Pos('cnt', Temp) - 6)), 0);
    Progress := 'R: ' + FormatFloat('##0%', (ia / TotalSectors) *100)
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
{$ENDIF}

initialization

finalization
  ReleaseLogWindow;

end.
