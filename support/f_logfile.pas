{ f_logfile.pas: Funktionen zum Schreiben eines Log-Files

  Copyright (c) 2004-2006 Oliver Valencia

  letzte Änderung  23.06.2006

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_logile.pas stellt Funktionen zum Schreiben eines Log-Files zur Verfügung:
    * String bzw. String-Liste an das Log-File anfügen


  exportierte Funktionen/Prozeduren:

    AddLog(const Value: string; const Show: Byte)
    AddLogAddStringList(List: TStringList)

}


unit f_logfile;

interface

uses Windows, Forms, Classes, SysUtils;

procedure AddLog(const Value: string; const Show: Byte);
procedure AddLogAddStringList(List: TStringList);

implementation

uses f_filesystem;

{ 'statische' Variablen }
var AddLogFirstRun: Boolean;          // Flag für AddLog

{ AddLog -----------------------------------------------------------------------

  AddLog fügt eine Zeile an das Log-File an. Falls die Datei log.txt noch nicht
  existiert, wird sie angelegt. Wenn Show=0 ist, wird der Log-Eintrag nicht als
  Message-Box angezeigt.                                                       }

procedure AddLog(const Value: string; const Show: Byte);
var LogName: string;
    Log: TextFile;
begin
  LogName := StartUpDir + '\log.txt';
  if AddLogFirstRun then
  begin
    if not FileExists(LogName) then
    begin
      AssignFile(Log, LogName);
      Rewrite(Log);
    end else
    begin
      AssignFile(log, LogName);
      Append(Log);
    end;
    WriteLn(Log, '------------------------------------------------------------');
    WriteLn(Log, 'cdrtfe Log-File');
    WriteLn(Log, '');
    Close(Log);
    AddLogFirstRun := False;
  end;
  AssignFile(Log, LogName);
  Append(Log);
  WriteLn(Log, Value);
  Close(Log);
  if Show <> 0 then
  begin
    Application.MessageBox(Pchar(Value), 'Debug-Info',
                           MB_OK or MB_ICONEXCLAMATION);
  end;
end;

{ AddLogAddStringList ----------------------------------------------------------

  AddLogAddStringList schreibt den Inhalt der String-Liste ins Log-File.       }

procedure AddLogAddStringList(List: TStringList);
var i: Integer;
    LogName: string;
    Log: TextFile;
begin
  if AddLogFirstRun then
  begin
    LogName := StartUpDir + '\log.txt';
    if not FileExists(LogName) then
    begin
      AssignFile(Log, LogName);
      Rewrite(Log);
    end else
    begin
      AssignFile(log, LogName);
      Append(Log);
    end;
    WriteLn(Log, '------------------------------------------------------------');
    WriteLn(Log, 'cdrtfe Log-File');
    WriteLn(Log, '');
    Close(Log);
    AddLogFirstRun := False;
  end;
  AssignFile(Log, LogName);
  Append(Log);
  for i := 0 to List.Count - 1 do
  begin
    WriteLn(Log, List[i]);
  end;
  Close(Log);
end;

initialization
  AddLogFirstRun := True;

end.
