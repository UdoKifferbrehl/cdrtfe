{ cdrtfedbg: cdrtools/Mode2CDMaker/VCDImager Frontend, Debug-DLL

  f_log.pas: Strings an das Log anfügen

  Copyright (c) 2007 Oliver Valencia

  letzte Änderung  22.06.2007

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_log.pas stellt interne Funktionen für das Log zur Verfügung
    * Strings bzw. String-Listen ans Logfile anhängen
    * vordefinierte Strings ans Logfile anhängen


  exportierte Funktionen/Prozeduren:

    AddLogStrInt(Text: string; Mode: Byte; List: TStrings)
    AddLogPreDefInt(Vallue: Integer; List TStrings)

}

unit f_log;

interface

uses Classes, SysUtils;

procedure AddLogStrInt(Text: string; Mode: Byte; List: TStrings);
procedure AddLogPreDefInt(Value: Integer; List: TStrings);

implementation

uses frm_dbg, f_logstrings, f_timer;

const CRLF = #13#10;
      CR   = #13;
      LF   = #10;

var AddLogFirstRun: Boolean;          // Flag für AddLog
    TimeCounter   : TTimeCount;

{ AddLogStrInt -----------------------------------------------------------------

  AddLogInt fügt eine Zeile an das Log-File an.

  Mode: 0 - <Zeit>: <Text>
        1 - <Zeit>:   <Text>
        2 -         <Text>
        3 -           <Text>                                                   }

procedure AddLogStrInt(Text: string; Mode: Byte; List: TStrings);
const TIEmpty = '          ';
var i       : Integer;
    AddLine : Boolean;
    TempList: TStringList;
    TimeInfo: string;
begin
  AddLine := Mode > 9;
  if Mode > 9 then Mode := Mode - 10;
  if AddLogFirstRun then
  begin
    List.Add('----------------------------------------------------------------------------------------------------');
    List.Add('cdrtfe Log-File');
    List.Add('  Date: ' + DateToStr(Now));
    List.Add('  Time: ' + TimeToStr(Now));
    List.Add('');
    AddLogFirstRun := False;
  end;
  if LastDelimiter(CRLF, Text) > 0 then
  begin
    TempList := TStringList.Create;
    TempList.Text := Text;
    for i := 0 to TempList.Count - 1 do
    begin
      if i > 0 then TimeInfo := TIEmpty else
        TimeInfo := TimeCounter.CurrentTimeAsString + ': ';
      case Mode of
        0: ;
        1: TimeInfo := TimeInfo + '  ';
        2: TimeInfo := TIEmpty;
        3: TimeInfo := TIEmpty + '  ';
      end;
      List.Add(TimeInfo + TempList[i]);
    end;
    TempList.Free;
  end else
  begin
    if Text = '' then TimeInfo := TIEmpty else
      TimeInfo := TimeCounter.CurrentTimeAsString + ': ';
    case Mode of
      0: ;
      1: TimeInfo := TIEmpty;
      2: TimeInfo := TimeInfo + '  ';
    end;
    List.Add(TimeInfo + Text);
  end;
  if AddLine then List.Add('');
end;

{ AddLogPreDefInt --------------------------------------------------------------

  AddLogPreDefInt fügt vordefinierte Strings an das Log an.                    }

procedure AddLogPreDefInt(Value: Integer; List: TStrings);
begin
  AddLogStrInt(LogStrings.Values[IntToStr(Value)], 0, List);
  AddLogStrInt('', 0, List);
end;

initialization
  AddLogFirstRun := True;
  TimeCounter := TTimeCount.Create;
  TimeCounter.Reset;
  TimeCounter.StartTimeCount;

finalization
  TimeCounter.StopTimeCount;
  TimeCounter.Free;

end.
