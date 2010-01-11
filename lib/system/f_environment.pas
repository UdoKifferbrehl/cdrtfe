{ $Id: f_environment.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_environment.pas: Umgebungsvariablen

  Copyright (c) 2005, 2008 Oliver Valencia

  letzte Änderung  01.10.2008

  Dieses Programm ist freie Software. Sie können es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gewährleistungsausschluß) in license.txt, COPYING.txt.

  f_environment.pas stellt Funktionen für Umgebungsvariablen zur Verfügung:
    * Umgebungsvariablen auslesen, setzen, löschen
    * Environment Block anlegen


  exportierte Funktionen/Prozeduren:

    GetEnvVarValue(Name: string): string;
    SetEnvVarValue(const Name, Value: string): Integer
    DeleteEnvVar(const Name: string): Integer
    GetEnvVars(VarList: TStringList): Integer
    ExpandEnvVars(const S: string): string
    CreateEnvBlock(const NewVars: TStringList; const IncludeCurrent: Boolean; const Buffer: Pointer; const BufSize: Integer): Integer
    
}

unit f_environment;

{$I directives.inc}

interface

uses Windows, Classes, SysUtils;

function GetEnvVarValue(const Name: string): string;
function SetEnvVarValue(const Name, Value: string): Integer;
function DeleteEnvVar(const Name: string): Integer;
function GetEnvVars(VarList: TStringList): Integer;
function ExpandEnvVars(const S: string): string;
function CreateEnvBlock(const NewVars: TStringList; const IncludeCurrent: Boolean; const Buffer: Pointer; const BufSize: Integer): Integer;

implementation

{ GetEnvVarValue ---------------------------------------------------------------

  GetEnvVarValue liefert den Wert der Umgebungsvariablen Name als String. Wenn
  die Variable nicht existiert, wird ein leerer String zurückgegeben.          }

function GetEnvVarValue(const Name: string): string;
var BufSize: Integer;
    Buffer: PChar;
begin
  {benötigten Platz für Wert der Umgebungsvariable feststellen (incl. #0)}
  BufSize := GetEnvironmentVariable(PChar(Name), nil, 0);
  if BufSize > 0 then
  begin
    GetMem(Buffer, BufSize);
    GetEnvironmentVariable(PChar(Name), Buffer, BufSize);
    Result := string(Buffer);
    FreeMem(Buffer);
  end else
  begin
    {Variable nicht gefunden}
    Result := '';
  end;
end;

{ SetEnvVarValue ---------------------------------------------------------------

  SetEnvVarValue setzt den Wert der Umgebungsvariablen Name. Wenn die Variable
  nicht existiert, wird sie neu angelegt. Ist der neue Wert '', wird die sie
  gelöscht.                                                                    }

function SetEnvVarValue(const Name, Value: string): Integer;
begin
  if SetEnvironmentVariable(PChar(Name), PChar(Value)) then
    Result := 0
  else
    Result := GetLastError;
end;

{ DeleteEnvVar -----------------------------------------------------------------

  DeleteEnvVar löscht die Umgebungsvariable Name.                              }

function DeleteEnvVar(const Name: string): Integer;
begin
  if SetEnvironmentVariable(PChar(Name), nil) then
    Result := 0
  else
    Result := GetLastError;
end;

{ GetEnvVars -------------------------------------------------------------------

  GetEnvVars schreibt alle Umgebungsvariablen in der Form Name=Wert in die
  String-Liste VarList. Als Rückgabewert liefert die Funktion die Größe des
  gesamten Environment Blocks. Wird als Parameter nil übergeben, so gibt
  GetEnvVars nur die Größe zurück.
  Format des Blocks: String1#0String2#0String3#0#0                             }

function GetEnvVars(VarList: TStringList): Integer;
var PEnvBlock: Pointer;
    PEnvString: PChar;
begin
  {Liste, wenn vorhanden, löschen.}
  if Assigned(VarList) then VarList.Clear;
  {Adresse des Environment Blocks bestimmen.}
  PEnvBlock := GetEnvironmentStrings();
  if PEnvBlock <> nil then
  begin
    {Wir haben einen gültigen Block.}
    try
      {nun die einzelnen null-terminierten Strings holen}
      PEnvString := PEnvBlock;
      while PEnvString^ <> #0 do
      begin
        if Assigned(VarList) then VarList.Add(string(PEnvString));
        {StrLen gibt die Länge ohne #0 zurück, deshalb 1 addieren.}
        Inc(PEnvString, StrLen(PEnvString) + 1);
      end;
      {Größe des Blocks berechnen; das abschließende #0 zählt mit, 1 addieren}
      Result := (PEnvString - PEnvBlock) + 1;
    finally
      {Block freigeben}
      FreeEnvironmentStrings(PEnvBlock);
    end;
  end else
  begin
    {kein Block, Größe 0}
    Result := 0;
  end;
end;

{ ExpandEnvVars ----------------------------------------------------------------

  ExpandEnvVars ersetzt in einem String %Var% durch den Wert von Var.          }

function ExpandEnvVars(const S: string): string;
var BufSize: Integer;
    Buffer: PChar;
begin
  {benötigte Puffergröße bestimmen}
  BufSize := ExpandEnvironmentStrings(PChar(S), nil, 0);
  if BufSize > 0 then
  begin
    GetMem(Buffer, BufSize);
    ExpandEnvironmentStrings(PChar(S), Buffer, BufSize);
    Result := string(Buffer);
    FreeMem(Buffer);
  end else
  begin
    Result := '';
  end;
end;

{ CreateEnvBlock ---------------------------------------------------------------

  CreateEnvBlock erzeugt einen neuen Block von Umgebungsvariablen.
  NewStrings    : neue Variablen
  IncludeCurrent: True: aktuelle Variablen kopieren
  Buffer        : Zeiger um Speicherbereich
  BufSize       : Größe des Speicherbereichs

  Wenn Buffer nil ist, wird die Größe des neuen Blocks zurückgegeben.          }

function CreateEnvBlock(const NewVars: TStringList;
                        const IncludeCurrent: Boolean; const Buffer: Pointer;
                        const BufSize: Integer): Integer;
var Vars      : TStringList;
    i         : Integer;
    PEnvString: PChar;
begin
  Vars := TStringList.Create;
  try
    {aktuelle Variablen auslesen}
    if IncludeCurrent then GetEnvVars(Vars);
    {neue Varaiblen hinzufügen}
    {hier müßten eigentlich auch noch Laufwerksinfos hinzugefügt werden:
     =h=h:\...\...}
    if Assigned(NewVars) then Vars.AddStrings(NewVars);
    {Größe des Blocks berechnen, pro String und Blockende 1 für #0 addieren}
    Result := 0;
    for i := 0 to Vars.Count - 1 do Result := Result +  Length(Vars[i]) + 1;
    Result := Result + 1;
    {Block schreiben}
    if (Buffer <> nil) and (BufSize >= Result) then
    begin
      {Varíablen müssen sortiert sein}
      Vars.Sort;
      {jetzt die Strings kopieren}
      PEnvString := Buffer;
      for i := 0 to Vars.Count - 1 do
      begin
        // StrPCopy(PEnvString, Vars[i]);
        StrLCopy(PEnvString, PChar(Vars[i]), Length(Vars[i]));
        Inc(PEnvString, Length(Vars[i]) + 1);
      end;
      {abschließendes #0 hinzufügen}
      PEnvString^ := #0;
    end;
  finally
    Vars.Free;
  end;
end;

end.
