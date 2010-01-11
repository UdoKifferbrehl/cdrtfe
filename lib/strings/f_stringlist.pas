{ $Id: f_stringlist.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_stringlist.pas: Funktionen f�r String-Listen

  Copyright (c) 2004-2008 Oliver Valencia
  Copyright (c) 2002-2004 Oliver Valencia, Oliver Kutsche

  letzte �nderung  02.10.2008

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.  

  f_stringlist.pas stellt Hilfs-Funktionen zur Verf�gung:
    * Funktionen f�r String-Listen


  exportierte Funktionen/Prozeduren:

    AddCRStringToList(s: string; List: TStringList)
    GetNameByValue(List: TStringList; const Value: string): string;
    GetSection(Source, Target: TSTringList; const StartTag, EndTag: string): Boolean
    SortListByValue(List: TStringList)

}

unit f_stringlist;

{$I directives.inc}

interface

uses Classes, SysUtils;

function GetNameByValue(List: TStringList; const Value: string): string;
function GetSection(Source, Target: TSTringList; const StartTag, EndTag: string): Boolean;
procedure AddCRStringToList(s: string; List: TStrings);
procedure SortListByValue(List: TStringList);

implementation

{ AddCRStringToList ------------------------------------------------------------

  F�gt einen String, der mehrere durch CR(LF) getrennte Zeilen enth�lt an die
  Liste an.                                                                    }

procedure AddCRStringToList(s: string; List: TStrings);
var TempList: TStrings;
    i       : Integer;
begin
  TempList := TStringList.Create;
  TempList.Text := s;
  for i := 0 to TempList.Count - 1 do List.Add(TempList[i]);
  TempList.Free;
end;

{ GetSection -------------------------------------------------------------------

  GetSection liefert aus der String-Liste Source den Teil, der durch die Zeilen
  StartTag und EndTag eingerahmt ist, wobei die Begrenzung nicht Teil des Ergeb-
  nisses sind. Sollte EndTag nicht gefunden werden, so wird die Liste ab
  StartTag zur�ckgegeben. Das Ergebnis wird in die Liste Target geschrieben.   }

function GetSection(Source, Target: TSTringList;
                     const StartTag, EndTag: string): Boolean;
var i, p: Integer;
begin
(*
  {Liste von Source nach Target kopieren}
  Target.Assign(Source);
  {Anfang der Sektion finden}
  p := Target.IndexOf(StartTag);
  Result := p > -1;
  if Result then
  begin
    for i := p downto 0 do
    begin
      Target.Delete(i);
    end;
    p := Target.IndexOf(EndTag);
    if p > -1 then
    begin
      for i := Target.Count - 1 downto p do
      begin
        Target.Delete(i);
      end;
    end;
  end;
*)
  {Anfang der Sektion finden}
  p := Source.IndexOf(StartTag);
  Result := p > -1;
  {Falls Sektion gefunden wurde, kopieren}
  if Result then
  begin
    i := p + 1;
    Target.Capacity := 1;
    while (i < Source.Count) and (Source[i] <> EndTag) do
    begin
      Target.Add(Source[i]);
      Inc(i);
    end;
  end;
end;

{ GetNameByValue ---------------------------------------------------------------

  liefert f�r eine Liste mit Eintr�gen der Form Name=Value zu einem gegebenen
  Wert den Namen.                                                              }

function GetNameByValue(List: TStringList; const Value: string): string;
var i         : Integer;
    Temp, Name: string;
    Found     : Boolean;
begin
  Result := '';
  Found := False;
  if List.Count > 0 then
  begin
    i := -1;
    repeat
      Inc(i);
      Name := List.Names[i];
      Temp := List.Values[Name];
      Found := Temp = Value;
    until Found or (i = List.Count - 1);
  end;
  if Found then Result := Name;
end;

{ SortListByValue --------------------------------------------------------------

  sortiert eine String-Liste nach den Werter.                                  }

procedure SortListByValue(List: TStringList);
var i: Integer;
begin
  for i := 0 to List.Count - 1 do
    List[i] := Format('%-15s', [List.Values[List.Names[i]]]) + '=' + List[i];
  List.Sort;
  for i := 0 to List.Count - 1 do
    List[i] := List.Values[List.Names[i]];
end;

end.
