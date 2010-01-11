{ $Id: f_environment.pas,v 1.1 2010/01/11 06:37:39 kerberos002 Exp $

  f_environment.pas: Umgebungsvariablen

  Copyright (c) 2005, 2008 Oliver Valencia

  letzte �nderung  01.10.2008

  Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der
  GNU General Public License weitergeben und/oder modifizieren. Weitere
  Informationen (Lizenz, Gew�hrleistungsausschlu�) in license.txt, COPYING.txt.

  f_environment.pas stellt Funktionen f�r Umgebungsvariablen zur Verf�gung:
    * Umgebungsvariablen auslesen, setzen, l�schen
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
  die Variable nicht existiert, wird ein leerer String zur�ckgegeben.          }

function GetEnvVarValue(const Name: string): string;
var BufSize: Integer;
    Buffer: PChar;
begin
  {ben�tigten Platz f�r Wert der Umgebungsvariable feststellen (incl. #0)}
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
  gel�scht.                                                                    }

function SetEnvVarValue(const Name, Value: string): Integer;
begin
  if SetEnvironmentVariable(PChar(Name), PChar(Value)) then
    Result := 0
  else
    Result := GetLastError;
end;

{ DeleteEnvVar -----------------------------------------------------------------

  DeleteEnvVar l�scht die Umgebungsvariable Name.                              }

function DeleteEnvVar(const Name: string): Integer;
begin
  if SetEnvironmentVariable(PChar(Name), nil) then
    Result := 0
  else
    Result := GetLastError;
end;

{ GetEnvVars -------------------------------------------------------------------

  GetEnvVars schreibt alle Umgebungsvariablen in der Form Name=Wert in die
  String-Liste VarList. Als R�ckgabewert liefert die Funktion die Gr��e des
  gesamten Environment Blocks. Wird als Parameter nil �bergeben, so gibt
  GetEnvVars nur die Gr��e zur�ck.
  Format des Blocks: String1#0String2#0String3#0#0                             }

function GetEnvVars(VarList: TStringList): Integer;
var PEnvBlock: Pointer;
    PEnvString: PChar;
begin
  {Liste, wenn vorhanden, l�schen.}
  if Assigned(VarList) then VarList.Clear;
  {Adresse des Environment Blocks bestimmen.}
  PEnvBlock := GetEnvironmentStrings();
  if PEnvBlock <> nil then
  begin
    {Wir haben einen g�ltigen Block.}
    try
      {nun die einzelnen null-terminierten Strings holen}
      PEnvString := PEnvBlock;
      while PEnvString^ <> #0 do
      begin
        if Assigned(VarList) then VarList.Add(string(PEnvString));
        {StrLen gibt die L�nge ohne #0 zur�ck, deshalb 1 addieren.}
        Inc(PEnvString, StrLen(PEnvString) + 1);
      end;
      {Gr��e des Blocks berechnen; das abschlie�ende #0 z�hlt mit, 1 addieren}
      Result := (PEnvString - PEnvBlock) + 1;
    finally
      {Block freigeben}
      FreeEnvironmentStrings(PEnvBlock);
    end;
  end else
  begin
    {kein Block, Gr��e 0}
    Result := 0;
  end;
end;

{ ExpandEnvVars ----------------------------------------------------------------

  ExpandEnvVars ersetzt in einem String %Var% durch den Wert von Var.          }

function ExpandEnvVars(const S: string): string;
var BufSize: Integer;
    Buffer: PChar;
begin
  {ben�tigte Puffergr��e bestimmen}
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
  BufSize       : Gr��e des Speicherbereichs

  Wenn Buffer nil ist, wird die Gr��e des neuen Blocks zur�ckgegeben.          }

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
    {neue Varaiblen hinzuf�gen}
    {hier m��ten eigentlich auch noch Laufwerksinfos hinzugef�gt werden:
     =h=h:\...\...}
    if Assigned(NewVars) then Vars.AddStrings(NewVars);
    {Gr��e des Blocks berechnen, pro String und Blockende 1 f�r #0 addieren}
    Result := 0;
    for i := 0 to Vars.Count - 1 do Result := Result +  Length(Vars[i]) + 1;
    Result := Result + 1;
    {Block schreiben}
    if (Buffer <> nil) and (BufSize >= Result) then
    begin
      {Var�ablen m�ssen sortiert sein}
      Vars.Sort;
      {jetzt die Strings kopieren}
      PEnvString := Buffer;
      for i := 0 to Vars.Count - 1 do
      begin
        // StrPCopy(PEnvString, Vars[i]);
        StrLCopy(PEnvString, PChar(Vars[i]), Length(Vars[i]));
        Inc(PEnvString, Length(Vars[i]) + 1);
      end;
      {abschlie�endes #0 hinzuf�gen}
      PEnvString^ := #0;
    end;
  finally
    Vars.Free;
  end;
end;

end.
